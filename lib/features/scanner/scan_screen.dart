import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/alerts.dart';
import '../../app/theme.dart';
import '../../data/local/app_db.dart';
import '../auth/auth_controller.dart';
import '../../data/remote/health_api.dart';
import '../../sync/sync_service.dart';
import '../../sync/sync_state.dart';
import 'widgets/sop_progress_header.dart';

typedef _ScanHandlerResult = ({bool accepted, String? rejectMessage});

/// SOP: Deposit (admit + rack + confirm) vs Retrieve (admit only + show rack + confirm return).
enum SopOperation { deposit, retrieve }

enum _FirstScan { candidate, rack }

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, required this.operation});

  final SopOperation operation;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _camera;
  BarcodeScanner? _scanner;
  bool _isProcessing = false;
  int _frameCount = 0;
  String? _initError;

  late final SopOperation _operation;

  _FirstScan? _depositFirst;
  String? _depositCandidateId;
  String? _depositRackId;

  _FirstScan? _retrieveFirst;
  String? _retrieveCandidateId;
  String? _retrieveRackId;
  Booking? _retrieveResolvedBooking;

  Timer? _pendingTimer;
  DateTime? _cooldownUntil;
  bool _didAutoSyncConflict = false;
  int _feedbackSeq = 0;
  ({
    bool success,
    String? message,
    int seq,
    String? displayCandidate,
    String? displayRack,
  })?
  _feedbackFlash;

  /// After each decoded barcode, pause MLKit until the operator taps to continue (avoids repeat reads).
  bool _scanAwaitingTap = false;

  int _activeStepIndex() {
    if (_operation == SopOperation.deposit) {
      final n =
          (_depositCandidateId != null ? 1 : 0) +
          (_depositRackId != null ? 1 : 0);
      if (n <= 0) return 0;
      if (n == 1) return 1;
      return 2;
    }
    final n =
        (_retrieveCandidateId != null ? 1 : 0) +
        (_retrieveRackId != null ? 1 : 0);
    if (n <= 0) return 0;
    if (n == 1) return 1;
    return 2;
  }

  List<String> _stepsFor(SopOperation op) {
    final first = op == SopOperation.deposit ? _depositFirst : _retrieveFirst;
    final a = first == _FirstScan.rack ? 'Rack ID' : 'Candidate ID';
    final b = first == _FirstScan.rack ? 'Candidate ID' : 'Rack ID';
    return [a, b, 'Confirm'];
  }

  void _logScan(String message) {
    if (kReleaseMode) return;
    debugPrint('scanner $message');
  }

  Future<void> _alert(
    String msg, {
    AppAlertLevel level = AppAlertLevel.info,
  }) async {
    if (!mounted) return;
    await showAppAlert(context, ref: ref, message: msg, level: level);
  }

  Future<void> _runRefreshSync() async {
    final stage = ValueNotifier<String>('Checking server…');

    if (!mounted) return;
    // ignore: unawaited_futures
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Syncing…'),
            content: ValueListenableBuilder<String>(
              valueListenable: stage,
              builder: (context, value, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pushing local changes and pulling latest bookings…',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(value)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    final health = await ref
        .read(healthApiProvider)
        .isHealthy()
        .catchError((_) => false);
    if (!health) {
      ref.read(syncStateProvider.notifier).setError('server unhealthy');
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      stage.dispose();
      await _alert(
        'Server is unavailable. Try again shortly.',
        level: AppAlertLevel.warning,
      );
      return;
    }

    stage.value = 'Syncing…';
    try {
      await ref.read(syncServiceProvider).syncOnce(trigger: SyncTrigger.manual);
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      stage.dispose();
    }
  }

  void _resetAllFlow() {
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _depositFirst = null;
    _depositCandidateId = null;
    _depositRackId = null;
    _retrieveFirst = null;
    _retrieveCandidateId = null;
    _retrieveRackId = null;
    _retrieveResolvedBooking = null;
    _cooldownUntil = null;
    _didAutoSyncConflict = false;
    _scanAwaitingTap = false;
    _feedbackFlash = null;
  }

  Future<void> _logActivity({
    required String bookingId,
    required String eventType,
    Map<String, Object?>? metadata,
  }) async {
    // booking_activities table removed; keep scan_events + booking state only.
    // No-op to preserve call sites.
  }

  Future<void> _logScanEvent({
    required SopOperation operation,
    required String eventType,
    String? candidateId,
    String? rackId,
    Map<String, Object?>? metadata,
  }) async {
    final session = ref
        .read(authControllerProvider)
        .maybeWhen(data: (s) => s, orElse: () => null);
    final operatorId = session?.operator.phone;
    if (operatorId == null || operatorId.isEmpty) return;
    final db = ref.read(appDbProvider);
    await db.insertScanEvent(
      id: const Uuid().v4(),
      operatorId: operatorId,
      operation: operation == SopOperation.deposit ? 'deposit' : 'retrieve',
      eventType: eventType,
      candidateId: candidateId,
      rackId: rackId,
      occurredAt: DateTime.now(),
      metadataJson: metadata == null ? null : jsonEncode(metadata),
    );
  }

  // (removed) old picker-based retrieval disambiguation — retrieval now requires
  // scanning both IDs and escalates to admin when ambiguous.

  @override
  void initState() {
    super.initState();
    _operation = widget.operation;
    _init();
  }

  bool get _blockCameraProcessing {
    if (_operation == SopOperation.deposit) {
      return _depositCandidateId != null && _depositRackId != null;
    }
    return _retrieveCandidateId != null &&
        _retrieveRackId != null &&
        _retrieveResolvedBooking != null;
  }

  String _hintText() {
    if (_operation == SopOperation.deposit) {
      if (_depositCandidateId == null && _depositRackId == null) {
        return 'DEPOSIT: Scan Candidate ID or Rack ID';
      }
      if (_depositCandidateId == null) return 'Scan Candidate ID';
      if (_depositRackId == null) return 'Scan Rack ID';
      return 'Place bag in rack, then confirm';
    }
    if (_retrieveCandidateId == null && _retrieveRackId == null) {
      return 'RETRIEVE: Scan Candidate ID or Rack ID';
    }
    if (_retrieveCandidateId == null) {
      final expected = _retrieveResolvedBooking?.candidateId;
      return expected != null && expected.isNotEmpty
          ? 'Scan Candidate ID (expected: $expected)'
          : 'Scan Candidate ID';
    }
    if (_retrieveRackId == null) {
      final expected = _retrieveResolvedBooking?.rackId;
      return expected != null && expected.isNotEmpty
          ? 'Scan Rack ID (expected: $expected)'
          : 'Scan Rack ID';
    }
    return 'Verify bag, then confirm return';
  }

  Future<_ScanHandlerResult> _onDepositCandidateScanned(
    String candidateId,
  ) async {
    final db = ref.read(appDbProvider);
    final flagged = await db.isCandidateFlagged(candidateId);
    if (flagged) {
      return (accepted: false, rejectMessage: 'Booking flagged');
    }

    final dups = await db.findActiveBookingsByCandidateId(candidateId);
    if (dups.isNotEmpty) {
      return (accepted: false, rejectMessage: 'Candidate already deposited');
    }

    _depositFirst ??= _FirstScan.candidate;
    await _logScanEvent(
      operation: SopOperation.deposit,
      eventType: 'candidate_scanned',
      candidateId: candidateId,
      metadata: {'phase': 'deposit'},
    );

    setState(() {
      _depositCandidateId = candidateId;
    });
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
    return (accepted: true, rejectMessage: null);
  }

  Future<_ScanHandlerResult> _onDepositRackScanned(String rackId) async {
    final db = ref.read(appDbProvider);
    final flagged = await db.isRackFlagged(rackId);
    if (flagged) {
      return (accepted: false, rejectMessage: 'Booking flagged');
    }

    final rackDups = await db.findActiveBookingsByRackId(rackId);
    if (rackDups.isNotEmpty) {
      return (accepted: false, rejectMessage: 'Rack already in use');
    }

    _depositFirst ??= _FirstScan.rack;
    await _logScanEvent(
      operation: SopOperation.deposit,
      eventType: 'rack_scanned',
      rackId: rackId,
      metadata: {'phase': 'deposit'},
    );

    setState(() {
      _depositRackId = rackId;
    });
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 800));
    return (accepted: true, rejectMessage: null);
  }

  Future<void> _confirmDeposit() async {
    final roll = _depositCandidateId;
    final rack = _depositRackId;
    if (roll == null || rack == null) return;

    final session = ref
        .read(authControllerProvider)
        .maybeWhen(data: (s) => s, orElse: () => null);
    final operatorId = session?.operator.phone;
    if (operatorId == null || operatorId.isEmpty) {
      await _alert('Not logged in.', level: AppAlertLevel.error);
      return;
    }

    final db = ref.read(appDbProvider);
    final flaggedCandidate = await db.isCandidateFlagged(roll);
    if (flaggedCandidate) {
      await _alert(
        'This Candidate ID ($roll) is in a FLAGGED booking. Deposit is blocked — contact an admin.',
        level: AppAlertLevel.error,
      );
      return;
    }

    final flaggedRack = await db.isRackFlagged(rack);
    if (flaggedRack) {
      await _alert(
        'Rack ID ($rack) is in a FLAGGED booking. Deposit is blocked — contact an admin.',
        level: AppAlertLevel.error,
      );
      return;
    }

    final candidateActive = await db.findActiveBookingsByCandidateId(roll);
    if (candidateActive.isNotEmpty) {
      await _alert(
        'An active booking already exists for Candidate ID ($roll). Deposit is blocked — contact an admin.',
        level: AppAlertLevel.error,
      );
      return;
    }

    final rackActive = await db.findActiveBookingsByRackId(rack);
    if (rackActive.isNotEmpty) {
      await _alert(
        'An active booking already exists for Rack ID ($rack). Deposit is blocked — contact an admin.',
        level: AppAlertLevel.error,
      );
      return;
    }

    final now = DateTime.now();
    final bookingId = const Uuid().v4();

    // If we already know locally that the candidate is flagged, block deposit creation.
    // Otherwise allow deposit creation and let the server flag conflicts if needed.

    await _logActivity(
      bookingId: bookingId,
      eventType: 'deposit_confirmed',
      metadata: {'rackId': rack, 'candidateId': roll},
    );

    await db.upsertBooking(
      id: bookingId,
      rackId: rack,
      candidateId: roll,
      operatorId: operatorId,
      status: 'active',
      startedAt: now,
      endedAt: null,
      pushedStart: false,
      pushedFinish: false,
    );

    setState(_resetAllFlow);
    unawaited(
      _alert(
        'Deposit saved (Deposited). Push to DB when online.',
        level: AppAlertLevel.success,
      ),
    );
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
  }

  Future<String?> _attemptResolveRetrieve({
    required _FirstScan lastScanned,
  }) async {
    final candidate = _retrieveCandidateId;
    final rack = _retrieveRackId;
    final db = ref.read(appDbProvider);

    if (candidate != null && rack != null) {
      final byCandidate = await db.findOpenBookingsByCandidateId(candidate);
      final byRack = await db.findOpenBookingsByRackId(rack);

      final byRackIds = {for (final b in byRack) b.id};
      final intersection = byCandidate
          .where((b) => byRackIds.contains(b.id))
          .toList();

      if (intersection.isEmpty) {
        if (!_didAutoSyncConflict) {
          _didAutoSyncConflict = true;
          await ref
              .read(syncServiceProvider)
              .syncOnce(trigger: SyncTrigger.autoTimer);
          return _attemptResolveRetrieve(lastScanned: lastScanned);
        }

        for (final b in [...byCandidate, ...byRack]) {
          final flagged = await db.isBookingFlagged(b.id);
          if (flagged) {
            setState(() {
              if (lastScanned == _FirstScan.candidate) {
                _retrieveCandidateId = null;
              } else {
                _retrieveRackId = null;
              }
              _retrieveResolvedBooking = null;
            });
            return 'Booking flagged';
          }
        }

        setState(() {
          if (lastScanned == _FirstScan.candidate) {
            _retrieveCandidateId = null;
          } else {
            _retrieveRackId = null;
          }
          _retrieveResolvedBooking = null;
        });
        return 'Roll No. and rack don\'t match';
      }
      if (intersection.length > 1) {
        setState(() => _retrieveResolvedBooking = null);
        return 'Multiple bookings match this roll and rack';
      }

      final resolved = intersection.single;
      final isFlagged =
          resolved.status == 'flagged' ||
          await db.isBookingFlagged(resolved.id);
      if (isFlagged) {
        setState(() => _retrieveResolvedBooking = null);
        return 'Booking flagged';
      }

      setState(() => _retrieveResolvedBooking = resolved);
      return null;
    }

    if (candidate != null) {
      final matches = await db.findOpenBookingsByCandidateId(candidate);
      if (matches.isEmpty && !_didAutoSyncConflict) {
        _didAutoSyncConflict = true;
        await ref
            .read(syncServiceProvider)
            .syncOnce(trigger: SyncTrigger.autoTimer);
        return _attemptResolveRetrieve(lastScanned: lastScanned);
      }
      if (matches.isEmpty) {
        setState(() => _retrieveResolvedBooking = null);
        return 'No active booking for this roll';
      }
      if (matches.length == 1) {
        final flagged = await db.isBookingFlagged(matches.single.id);
        if (flagged) {
          setState(() {
            _retrieveCandidateId = null;
            _retrieveResolvedBooking = null;
          });
          return 'Booking flagged';
        }
        setState(() => _retrieveResolvedBooking = matches.single);
        return null;
      }
      if (matches.length > 1) {
        setState(() {
          _retrieveCandidateId = null;
          _retrieveResolvedBooking = null;
        });
        return 'Multiple bookings for this roll';
      }
    }
    if (rack != null) {
      final matches = await db.findOpenBookingsByRackId(rack);
      if (matches.isEmpty && !_didAutoSyncConflict) {
        _didAutoSyncConflict = true;
        await ref
            .read(syncServiceProvider)
            .syncOnce(trigger: SyncTrigger.autoTimer);
        return _attemptResolveRetrieve(lastScanned: lastScanned);
      }
      if (matches.isEmpty) {
        setState(() => _retrieveResolvedBooking = null);
        return 'No active booking for this rack';
      }
      if (matches.length == 1) {
        final flagged = await db.isBookingFlagged(matches.single.id);
        if (flagged) {
          setState(() {
            _retrieveRackId = null;
            _retrieveResolvedBooking = null;
          });
          return 'Booking flagged';
        }
        setState(() => _retrieveResolvedBooking = matches.single);
        return null;
      }
      if (matches.length > 1) {
        setState(() {
          _retrieveRackId = null;
          _retrieveResolvedBooking = null;
        });
        return 'Multiple bookings for this rack';
      }
    }
    return null;
  }

  Future<_ScanHandlerResult> _onRetrieveCandidateScanned(
    String candidateId,
  ) async {
    final db = ref.read(appDbProvider);
    final flagged = await db.isCandidateFlagged(candidateId);
    if (flagged) {
      return (accepted: false, rejectMessage: 'Booking flagged');
    }
    final dups = await db.findOpenBookingsByCandidateId(candidateId);
    if (dups.length > 1) {
      setState(() {
        _retrieveCandidateId = null;
        _retrieveResolvedBooking = null;
      });
      return (
        accepted: false,
        rejectMessage: 'Multiple bookings for this roll',
      );
    }

    _retrieveFirst ??= _FirstScan.candidate;
    await _logScanEvent(
      operation: SopOperation.retrieve,
      eventType: 'candidate_scanned',
      candidateId: candidateId,
      metadata: {'phase': 'retrieve'},
    );
    setState(() {
      _retrieveCandidateId = candidateId;
      _retrieveResolvedBooking = null;
    });

    final resolveErr = await _attemptResolveRetrieve(
      lastScanned: _FirstScan.candidate,
    );
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
    if (resolveErr != null) {
      return (accepted: false, rejectMessage: resolveErr);
    }
    return (accepted: true, rejectMessage: null);
  }

  Future<_ScanHandlerResult> _onRetrieveRackScanned(String rackId) async {
    final db = ref.read(appDbProvider);
    final flagged = await db.isRackFlagged(rackId);
    if (flagged) {
      return (accepted: false, rejectMessage: 'Booking flagged');
    }
    final dups = await db.findOpenBookingsByRackId(rackId);
    if (dups.length > 1) {
      setState(() {
        _retrieveRackId = null;
        _retrieveResolvedBooking = null;
      });
      return (
        accepted: false,
        rejectMessage: 'Multiple bookings for this rack',
      );
    }

    _retrieveFirst ??= _FirstScan.rack;
    await _logScanEvent(
      operation: SopOperation.retrieve,
      eventType: 'rack_scanned',
      rackId: rackId,
      metadata: {'phase': 'retrieve'},
    );
    setState(() {
      _retrieveRackId = rackId;
      _retrieveResolvedBooking = null;
    });

    final resolveErr = await _attemptResolveRetrieve(
      lastScanned: _FirstScan.rack,
    );
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
    if (resolveErr != null) {
      return (accepted: false, rejectMessage: resolveErr);
    }
    return (accepted: true, rejectMessage: null);
  }

  Future<void> _confirmReturn() async {
    final booking = _retrieveResolvedBooking;
    if (booking == null) return;
    if (booking.status == 'flagged') {
      await _alert(
        'This booking is flagged as conflicting. Contact admin.',
        level: AppAlertLevel.warning,
      );
      return;
    }

    final session = ref
        .read(authControllerProvider)
        .maybeWhen(data: (s) => s, orElse: () => null);
    final operatorId = session?.operator.phone;
    if (operatorId == null || operatorId.isEmpty) {
      await _alert('Not logged in.', level: AppAlertLevel.error);
      return;
    }

    final now = DateTime.now();
    final db = ref.read(appDbProvider);

    await _logActivity(
      bookingId: booking.id,
      eventType: 'return_confirmed',
      metadata: {'rackId': booking.rackId, 'candidateId': booking.candidateId},
    );

    await db.upsertBooking(
      id: booking.id,
      rackId: booking.rackId,
      candidateId: booking.candidateId,
      operatorId: booking.operatorId,
      status: 'complete',
      startedAt: booking.startedAt,
      endedAt: now,
      pushedFinish: false,
    );

    setState(_resetAllFlow);
    unawaited(
      _alert(
        'Return confirmed (Retrieved). Push to DB when online.',
        level: AppAlertLevel.success,
      ),
    );
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
  }

  void _cancelDepositSummary() {
    unawaited(
      _logScanEvent(
        operation: SopOperation.deposit,
        eventType: 'deposit_cancelled',
        candidateId: _depositCandidateId,
        rackId: _depositRackId,
      ),
    );
    setState(() {
      _depositFirst = null;
      _depositCandidateId = null;
      _depositRackId = null;
      _scanAwaitingTap = false;
      _feedbackFlash = null;
    });
  }

  void _cancelRetrieve() {
    unawaited(
      _logScanEvent(
        operation: SopOperation.retrieve,
        eventType: 'retrieve_cancelled',
        candidateId: _retrieveCandidateId,
        rackId: _retrieveRackId,
      ),
    );
    setState(() {
      _retrieveFirst = null;
      _retrieveCandidateId = null;
      _retrieveRackId = null;
      _retrieveResolvedBooking = null;
      _scanAwaitingTap = false;
      _feedbackFlash = null;
    });
  }

  void _flashScanFeedback({
    required bool success,
    String? message,
    String? displayCandidate,
    String? displayRack,
  }) {
    if (!mounted) return;
    _feedbackSeq += 1;
    final seq = _feedbackSeq;
    if (success) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _feedbackFlash = (
        success: success,
        message: message,
        seq: seq,
        displayCandidate: displayCandidate,
        displayRack: displayRack,
      );
    });
  }

  Future<void> _onBarcodeScanned(String trimmed) async {
    // Only accept:
    // - Candidate ID: exactly 10 digits
    // - Rack ID: R + 3 digits (case-insensitive; normalized to uppercase)
    final candidateId = _parseCandidateId(trimmed);
    final rackId = _parseRackId(trimmed);

    _ScanHandlerResult? result;
    if (_operation == SopOperation.deposit) {
      if (candidateId != null) {
        result = await _onDepositCandidateScanned(candidateId);
      } else if (rackId != null) {
        result = await _onDepositRackScanned(rackId);
      }
    } else {
      if (candidateId != null) {
        result = await _onRetrieveCandidateScanned(candidateId);
      } else if (rackId != null) {
        result = await _onRetrieveRackScanned(rackId);
      }
    }

    if (!mounted || trimmed.isEmpty) return;

    final dispCand = _operation == SopOperation.deposit
        ? _depositCandidateId
        : _retrieveCandidateId;
    final dispRack = _operation == SopOperation.deposit
        ? _depositRackId
        : _retrieveRackId;

    if (candidateId == null && rackId == null) {
      _flashScanFeedback(
        success: false,
        message: 'Wrong format — use 10-digit roll or rack like R042',
      );
    } else if (result != null) {
      if (result.accepted) {
        _flashScanFeedback(
          success: true,
          displayCandidate: dispCand,
          displayRack: dispRack,
        );
      } else {
        // Track rejected scans (duplicates/flagged/mismatch/no-booking/etc).
        // Intentionally DO NOT track wrong-format scans to avoid noise.
        unawaited(
          _logScanEvent(
            operation: _operation,
            eventType: 'scan_rejected',
            candidateId: candidateId,
            rackId: rackId,
            metadata: <String, Object?>{
              'reason': result.rejectMessage ?? 'Scan not accepted',
              if (candidateId != null) 'scanned': 'candidate',
              if (rackId != null) 'scanned': 'rack',
            },
          ),
        );
        _flashScanFeedback(
          success: false,
          message: result.rejectMessage ?? 'Scan not accepted',
          displayCandidate: candidateId,
          displayRack: rackId,
        );
      }
    }
  }

  Future<void> _init() async {
    try {
      // BarcodeFormat.all: QR, Code128, EAN, etc. — roll and rack scans accept QR or linear barcodes.
      _scanner = BarcodeScanner(formats: [BarcodeFormat.all]);
      _logScan('[INIT] MLKit BarcodeScanner initialized (all formats)');

      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      _logScan(
        '[INIT] Camera ready (id=${back.name}, orientation=${back.sensorOrientation}, format=${controller.value.previewPauseOrientation})',
      );

      await controller.startImageStream((image) async {
        if (_isProcessing) return;
        if (_blockCameraProcessing) return;
        if (_scanAwaitingTap) return;
        final until = _cooldownUntil;
        if (until != null && DateTime.now().isBefore(until)) return;
        _isProcessing = true;
        _frameCount++;
        if (_frameCount % 60 == 0) {
          _logScan(
            '[FRAME] #$_frameCount ${image.width}x${image.height} planes=${image.planes.length} bytesPerRow=${image.planes.isNotEmpty ? image.planes.first.bytesPerRow : '—'}',
          );
        }
        try {
          final input = _toInputImage(
            image,
            rotationDegrees: back.sensorOrientation,
          );
          final barcodes = await _scanner!.processImage(input);
          if (barcodes.isEmpty) return;
          final first = barcodes.first;
          final raw = first.rawValue;
          if (raw == null || raw.trim().isEmpty || !mounted) return;

          final trimmed = raw.trim();
          final preview = trimmed.length <= 80
              ? trimmed
              : '${trimmed.substring(0, 80)}…';
          _logScan('[DETECT] format=${first.format} value="$preview"');

          await _onBarcodeScanned(trimmed);
          if (mounted) {
            setState(() {
              if (_blockCameraProcessing) {
                // Confirm sheet is showing — no "next scan" gate; don't cover UI.
                _scanAwaitingTap = false;
                _feedbackFlash = null;
              } else {
                _scanAwaitingTap = true;
              }
            });
          }
        } catch (e) {
          _logScan('[ERR] $e');
        } finally {
          _isProcessing = false;
        }
      });

      if (!mounted) return;
      setState(() {
        _initError = null;
        _camera = controller;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = switch (e) {
        CameraException(:final code, :final description) =>
          code == 'CameraAccessDenied'
              ? 'Camera permission denied. Enable camera permission in Settings and reopen the scanner.'
              : 'Camera error ($code): ${description ?? 'Unknown error'}',
        _ => 'Scanner init failed: $e',
      };
      setState(() => _initError = msg);
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    _scanner?.close();
    _pendingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initError = _initError;
    if (initError != null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 44),
                const SizedBox(height: 10),
                Text(
                  initError,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _initError = null);
                    _init();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(child: CameraPreview(camera)),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.30),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
          ),
          // Mode selection happens on the previous screen (ModeSelectScreen).
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: SopProgressHeader(
              steps: _stepsFor(_operation),
              activeIndex: _activeStepIndex(),
              subline: _operation == SopOperation.deposit
                  ? 'Deposit flow'
                  : 'Retrieve flow',
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: IconButton(
                tooltip: 'Sync / Refresh',
                icon: const Icon(Icons.sync, color: Colors.white),
                onPressed: _runRefreshSync,
              ),
            ),
          ),
          if (_feedbackFlash != null)
            Positioned.fill(
              child: IgnorePointer(
                child: _ScanResultFlash(
                  key: ValueKey<int>(_feedbackFlash!.seq),
                  success: _feedbackFlash!.success,
                  message: _feedbackFlash!.message,
                  displayCandidate: _feedbackFlash!.displayCandidate,
                  displayRack: _feedbackFlash!.displayRack,
                ),
              ),
            ),
          if (_operation == SopOperation.deposit &&
              _depositCandidateId != null &&
              _depositRackId != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 96,
              child: _ActionSheet(
                title: 'Confirm deposit',
                subtitle: 'Place the bag in the rack, then confirm.',
                lines: [
                  _KeyValueLine(label: 'Roll', value: _depositCandidateId!),
                  _KeyValueLine(label: 'Rack', value: _depositRackId!),
                ],
                primaryLabel: 'Confirm deposit',
                primaryIcon: Icons.check_circle_outline,
                onPrimary: _confirmDeposit,
                secondaryLabel: 'Cancel',
                onSecondary: _cancelDepositSummary,
              ),
            ),
          if (_operation == SopOperation.retrieve &&
              _retrieveCandidateId != null &&
              _retrieveRackId != null &&
              _retrieveResolvedBooking != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 96,
              child: _RetrieveConfirmSheet(
                booking: _retrieveResolvedBooking!,
                onConfirm: _confirmReturn,
                onCancel: _cancelRetrieve,
              ),
            ),
          if (_scanAwaitingTap && !_blockCameraProcessing)
            Positioned(
              left: 16,
              right: 16,
              bottom: 80,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(14),
                color: AppPalette.card,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      _scanAwaitingTap = false;
                      _cooldownUntil = null;
                      _feedbackFlash = null;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap when ready for the next scan',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppPalette.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _HintStrip(text: _hintText()),
          ),
        ],
      ),
    );
  }
}

class _RetrieveConfirmSheet extends ConsumerWidget {
  const _RetrieveConfirmSheet({
    required this.booking,
    required this.onConfirm,
    required this.onCancel,
  });

  final Booking booking;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: ref.read(appDbProvider).isBookingFlagged(booking.id),
      builder: (context, snap) {
        final flagged = snap.data == true;
        return _ActionSheet(
          tone: _ActionTone.attention,
          title: 'Bag location',
          subtitle: flagged
              ? 'This booking is FLAGGED for admin review (duplicate candidate or rack). '
                    'Go to the rack only if you are sure, then confirm return.'
              : 'Go to the rack and locate the bag, then confirm return.',
          lines: [
            _KeyValueLine(
              label: 'Rack',
              value: booking.rackId,
              emphasize: true,
            ),
            _KeyValueLine(label: 'Roll', value: booking.candidateId),
          ],
          primaryLabel: 'Confirm return',
          primaryIcon: Icons.check_circle_outline,
          onPrimary: onConfirm,
          secondaryLabel: 'Cancel',
          onSecondary: onCancel,
        );
      },
    );
  }
}

class _HintStrip extends StatelessWidget {
  const _HintStrip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanResultFlash extends StatefulWidget {
  const _ScanResultFlash({
    super.key,
    required this.success,
    this.message,
    this.displayCandidate,
    this.displayRack,
  });

  final bool success;
  final String? message;
  final String? displayCandidate;
  final String? displayRack;

  @override
  State<_ScanResultFlash> createState() => _ScanResultFlashState();
}

class _ScanResultFlashState extends State<_ScanResultFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    final fade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );

    final bg = widget.success ? AppPalette.success : AppPalette.danger;
    final icon = widget.success ? Icons.check_rounded : Icons.close_rounded;

    String fmt(String? v) {
      final t = v?.trim();
      return (t == null || t.isEmpty) ? '—' : t;
    }

    final cand = widget.displayCandidate;
    final rack = widget.displayRack;
    final showValues =
        widget.success ||
        (cand?.trim().isNotEmpty == true) ||
        (rack?.trim().isNotEmpty == true);

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.12),
      child: Center(
        child: FadeTransition(
          opacity: fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: scale,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: bg.withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 44),
                ),
              ),
              if (widget.message != null && widget.message!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
              if (showValues) ...[
                const SizedBox(height: 14),
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _FlashScanValueRow(label: 'Roll', value: fmt(cand)),
                      const SizedBox(height: 8),
                      _FlashScanValueRow(label: 'Rack', value: fmt(rack)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashScanValueRow extends StatelessWidget {
  const _FlashScanValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDash = value == '—';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppPalette.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDash ? AppPalette.textSecondary : AppPalette.textPrimary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

enum _ActionTone { normal, attention }

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({
    this.tone = _ActionTone.normal,
    required this.title,
    required this.subtitle,
    required this.lines,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final _ActionTone tone;
  final String title;
  final String subtitle;
  final List<Widget> lines;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = switch (tone) {
      _ActionTone.normal => AppPalette.card,
      _ActionTone.attention => AppPalette.navSelectedPill,
    };
    final border = switch (tone) {
      _ActionTone.normal => AppPalette.border,
      _ActionTone.attention => cs.primary.withValues(alpha: 0.35),
    };

    return Card(
      color: bg,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  tone == _ActionTone.attention
                      ? Icons.location_on_outlined
                      : Icons.task_alt,
                  color: cs.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppPalette.textSecondary),
            ),
            const SizedBox(height: 14),
            ...lines,
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onPrimary,
              icon: Icon(primaryIcon),
              label: Text(primaryLabel.toUpperCase()),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel)),
          ],
        ),
      ),
    );
  }
}

class _KeyValueLine extends StatelessWidget {
  const _KeyValueLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppPalette.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: emphasize
                  ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    )
                  : Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _parseCandidateId(String raw) {
  final s = raw.trim();
  return RegExp(r'^\d{10}$').hasMatch(s) ? s : null;
}

String? _parseRackId(String raw) {
  final s = raw.trim().toUpperCase();
  final m = RegExp(r'^R(\d{3})$').firstMatch(s);
  if (m == null) return null;
  return 'R${m.group(1)}';
}

InputImage _toInputImage(CameraImage image, {required int rotationDegrees}) {
  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  // Prefer the actual camera image format when available.
  final format =
      InputImageFormatValue.fromRawValue(image.format.raw) ??
      (Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888);

  // Prefer explicit rotation mapping; ML Kit is sensitive to incorrect rotation.
  final rotation =
      InputImageRotationValue.fromRawValue(rotationDegrees) ??
      InputImageRotation.rotation0deg;

  final metadata = InputImageMetadata(
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    format: format,
    bytesPerRow: image.planes.first.bytesPerRow,
  );

  return InputImage.fromBytes(bytes: bytes, metadata: metadata);
}

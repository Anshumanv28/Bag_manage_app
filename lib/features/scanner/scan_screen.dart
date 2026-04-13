import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/alerts.dart';
import '../../app/theme.dart';
import '../../data/local/app_db.dart';
import '../auth/auth_controller.dart';
import 'widgets/sop_progress_header.dart';

/// SOP: Deposit (admit + rack + confirm) vs Retrieve (admit only + show rack + confirm return).
enum SopOperation { deposit, retrieve }

enum _DepositPhase { scanRoll, rollAwaitingOk, scanRack, confirmDeposit }

enum _RetrievePhase { scanRoll, confirmReturn }

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

  late final SopOperation _operation;
  _DepositPhase _depositPhase = _DepositPhase.scanRoll;
  _RetrievePhase _retrievePhase = _RetrievePhase.scanRoll;

  String? _depositRoll;
  String? _depositRack;
  Booking? _retrieveBooking;

  Timer? _pendingTimer;
  DateTime? _cooldownUntil;

  int _activeStepIndex() {
    if (_operation == SopOperation.deposit) {
      return switch (_depositPhase) {
        _DepositPhase.scanRoll => 0,
        _DepositPhase.rollAwaitingOk => 0,
        _DepositPhase.scanRack => 1,
        _DepositPhase.confirmDeposit => 2,
      };
    }
    return switch (_retrievePhase) {
      _RetrievePhase.scanRoll => 0,
      _RetrievePhase.confirmReturn => 1,
    };
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

  void _resetAllFlow() {
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _depositPhase = _DepositPhase.scanRoll;
    _retrievePhase = _RetrievePhase.scanRoll;
    _depositRoll = null;
    _depositRack = null;
    _retrieveBooking = null;
    _cooldownUntil = null;
  }

  @override
  void initState() {
    super.initState();
    _operation = widget.operation;
    _init();
  }

  bool get _blockCameraProcessing {
    if (_operation == SopOperation.deposit) {
      return _depositPhase == _DepositPhase.rollAwaitingOk ||
          _depositPhase == _DepositPhase.confirmDeposit;
    }
    return _retrievePhase == _RetrievePhase.confirmReturn;
  }

  String _hintText() {
    if (_operation == SopOperation.deposit) {
      return switch (_depositPhase) {
        _DepositPhase.scanRoll => 'DEPOSIT: Scan admit card (roll number)',
        _DepositPhase.rollAwaitingOk => 'Review roll number, tap OK',
        _DepositPhase.scanRack => 'Scan rack QR or barcode',
        _DepositPhase.confirmDeposit => 'Place bag in rack, then confirm',
      };
    }
    return switch (_retrievePhase) {
      _RetrievePhase.scanRoll => 'RETRIEVE: Scan admit card (roll number)',
      _RetrievePhase.confirmReturn => 'Go to rack and locate bag',
    };
  }

  Future<void> _onDepositRollScanned(String roll) async {
    final db = ref.read(appDbProvider);
    final existing = await db.findActiveBookingByCandidateId(roll);
    if (existing != null) {
      await _alert(
        'Deposit already exists for this Candidate ID.',
        level: AppAlertLevel.warning,
      );
      _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
      return;
    }
    setState(() {
      _depositRoll = roll;
      _depositPhase = _DepositPhase.rollAwaitingOk;
    });
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
  }

  void _onDepositRollOk() {
    final roll = _depositRoll;
    if (roll == null) return;
    setState(() {
      _depositPhase = _DepositPhase.scanRack;
    });
    // Fire-and-forget: do not block UI progression.
    unawaited(_alert('Now scan Rack ID (QR or barcode).'));
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 800));
  }

  Future<void> _onDepositRackScanned(String rackId) async {
    final roll = _depositRoll;
    if (roll == null) return;

    final db = ref.read(appDbProvider);
    final rackInUse = await db.findActiveBookingByRackId(rackId);
    if (rackInUse != null) {
      await _alert(
        'Rack already in use (one bag per rack).',
        level: AppAlertLevel.warning,
      );
      _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
      return;
    }
    final rollAgain = await db.findActiveBookingByCandidateId(roll);
    if (rollAgain != null) {
      await _alert(
        'Deposit already exists for this Candidate ID.',
        level: AppAlertLevel.warning,
      );
      _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
      return;
    }

    setState(() {
      _depositRack = rackId;
      _depositPhase = _DepositPhase.confirmDeposit;
    });
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 800));
  }

  Future<void> _confirmDeposit() async {
    final roll = _depositRoll;
    final rack = _depositRack;
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
    final rackInUse = await db.findActiveBookingByRackId(rack);
    if (rackInUse != null) {
      await _alert('Rack already in use.', level: AppAlertLevel.warning);
      return;
    }
    if (await db.findActiveBookingByCandidateId(roll) != null) {
      await _alert(
        'Deposit already exists for this Candidate ID.',
        level: AppAlertLevel.warning,
      );
      return;
    }

    final now = DateTime.now();
    final bookingId = const Uuid().v4();
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

  Future<void> _onRetrieveRollScanned(String roll) async {
    final db = ref.read(appDbProvider);
    final booking = await db.findActiveBookingByCandidateId(roll);
    if (booking == null) {
      await _alert(
        'No deposit record for this Candidate ID. Escalate to supervisor.',
        level: AppAlertLevel.warning,
      );
      _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
      return;
    }
    setState(() {
      _retrieveBooking = booking;
      _retrievePhase = _RetrievePhase.confirmReturn;
    });
    _cooldownUntil = DateTime.now().add(const Duration(milliseconds: 1200));
  }

  Future<void> _confirmReturn() async {
    final booking = _retrieveBooking;
    if (booking == null) return;

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

    await db.upsertBooking(
      id: booking.id,
      rackId: booking.rackId,
      candidateId: booking.candidateId,
      operatorId: operatorId,
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
    setState(() {
      _depositPhase = _DepositPhase.scanRoll;
      _depositRoll = null;
      _depositRack = null;
    });
  }

  void _cancelRetrieve() {
    setState(() {
      _retrievePhase = _RetrievePhase.scanRoll;
      _retrieveBooking = null;
    });
  }

  Future<void> _onBarcodeScanned(String trimmed) async {
    // Only accept:
    // - Candidate ID: exactly 10 digits
    // - Rack ID: R + 3 digits (case-insensitive; normalized to uppercase)
    final candidateId = _parseCandidateId(trimmed);
    final rackId = _parseRackId(trimmed);

    if (_operation == SopOperation.deposit) {
      switch (_depositPhase) {
        case _DepositPhase.scanRoll:
          if (candidateId == null) return;
          await _onDepositRollScanned(candidateId);
        case _DepositPhase.rollAwaitingOk:
        case _DepositPhase.confirmDeposit:
          break;
        case _DepositPhase.scanRack:
          if (rackId == null) return;
          await _onDepositRackScanned(rackId);
      }
    } else {
      if (_retrievePhase == _RetrievePhase.scanRoll) {
        if (candidateId == null) return;
        await _onRetrieveRollScanned(candidateId);
      }
    }
  }

  Future<void> _init() async {
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
        final input = _toInputImage(image, back.sensorOrientation);
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
      } catch (e) {
        _logScan('[ERR] $e');
      } finally {
        _isProcessing = false;
      }
    });

    if (!mounted) return;
    setState(() => _camera = controller);
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
              steps: _operation == SopOperation.deposit
                  ? const ['Candidate ID', 'Rack ID', 'Confirm']
                  : const ['Candidate ID', 'Confirm'],
              activeIndex: _activeStepIndex(),
              subline: _operation == SopOperation.deposit
                  ? 'Deposit flow'
                  : 'Retrieve flow',
            ),
          ),
          // (removed) current values strip
          if (_operation == SopOperation.deposit &&
              _depositPhase == _DepositPhase.scanRack &&
              _depositRoll != null)
            Positioned(
              left: 8,
              right: 8,
              top: 184,
              child: _ScanPill(
                icon: Icons.badge_outlined,
                title: 'Candidate ID scanned',
                value: _depositRoll!,
              ),
            ),
          if (_operation == SopOperation.deposit &&
              _depositPhase == _DepositPhase.rollAwaitingOk &&
              _depositRoll != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 96,
              child: _ActionSheet(
                title: 'Candidate ID',
                subtitle: 'Confirm the roll number before scanning rack ID.',
                lines: [
                  _KeyValueLine(label: 'Roll', value: _depositRoll!),
                ],
                primaryLabel: 'OK',
                primaryIcon: Icons.check,
                onPrimary: _onDepositRollOk,
                secondaryLabel: 'Rescan',
                onSecondary: _cancelDepositSummary,
              ),
            ),
          if (_operation == SopOperation.deposit &&
              _depositPhase == _DepositPhase.confirmDeposit &&
              _depositRoll != null &&
              _depositRack != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 96,
              child: _ActionSheet(
                title: 'Confirm deposit',
                subtitle: 'Place the bag in the rack, then confirm.',
                lines: [
                  _KeyValueLine(label: 'Roll', value: _depositRoll!),
                  _KeyValueLine(label: 'Rack', value: _depositRack!),
                ],
                primaryLabel: 'Confirm deposit',
                primaryIcon: Icons.check_circle_outline,
                onPrimary: _confirmDeposit,
                secondaryLabel: 'Cancel',
                onSecondary: _cancelDepositSummary,
              ),
            ),
          if (_operation == SopOperation.retrieve &&
              _retrievePhase == _RetrievePhase.confirmReturn &&
              _retrieveBooking != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 96,
              child: _ActionSheet(
                tone: _ActionTone.attention,
                title: 'Bag location',
                subtitle: 'Go to the rack and locate the bag, then confirm return.',
                lines: [
                  _KeyValueLine(
                    label: 'Rack',
                    value: _retrieveBooking!.rackId,
                    emphasize: true,
                  ),
                  _KeyValueLine(label: 'Roll', value: _retrieveBooking!.candidateId),
                ],
                primaryLabel: 'Confirm return',
                primaryIcon: Icons.check_circle_outline,
                onPrimary: _confirmReturn,
                secondaryLabel: 'Cancel',
                onSecondary: _cancelRetrieve,
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
            Icon(Icons.qr_code_scanner, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanPill extends StatelessWidget {
  const _ScanPill({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 1.5,
      borderRadius: BorderRadius.circular(16),
      color: AppPalette.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppPalette.navSelectedPill,
              foregroundColor: cs.primary,
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                  tone == _ActionTone.attention ? Icons.location_on_outlined : Icons.task_alt,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textSecondary,
                  ),
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
            OutlinedButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyValueLine extends StatelessWidget {
  const _KeyValueLine({required this.label, required this.value, this.emphasize = false});
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
                  ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)
                  : Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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

InputImage _toInputImage(CameraImage image, int rotationDegrees) {
  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final format = Platform.isAndroid
      ? InputImageFormat.nv21
      : InputImageFormat.bgra8888;

  final metadata = InputImageMetadata(
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: switch (rotationDegrees) {
      0 => InputImageRotation.rotation0deg,
      90 => InputImageRotation.rotation90deg,
      180 => InputImageRotation.rotation180deg,
      270 => InputImageRotation.rotation270deg,
      _ => InputImageRotation.rotation0deg,
    },
    format: format,
    bytesPerRow: image.planes.first.bytesPerRow,
  );

  return InputImage.fromBytes(bytes: bytes, metadata: metadata);
}

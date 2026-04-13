import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/alerts.dart';
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
    if (_operation == SopOperation.deposit) {
      switch (_depositPhase) {
        case _DepositPhase.scanRoll:
          await _onDepositRollScanned(trimmed);
        case _DepositPhase.rollAwaitingOk:
        case _DepositPhase.confirmDeposit:
          break;
        case _DepositPhase.scanRack:
          await _onDepositRackScanned(trimmed);
      }
    } else {
      if (_retrievePhase == _RetrievePhase.scanRoll) {
        await _onRetrieveRollScanned(trimmed);
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
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Candidate ID scanned',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              _depositRoll!,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_operation == SopOperation.deposit &&
              _depositPhase == _DepositPhase.rollAwaitingOk &&
              _depositRoll != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 96,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Roll number scanned',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _depositRoll!,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _onDepositRollOk,
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
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
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Confirm deposit',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Roll: $_depositRoll'),
                      Text('Rack: $_depositRack'),
                      const SizedBox(height: 8),
                      Text(
                        'Place the bag in the rack, then confirm.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _confirmDeposit,
                        child: const Text('CONFIRM DEPOSIT'),
                      ),
                      TextButton(
                        onPressed: _cancelDepositSummary,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_operation == SopOperation.retrieve &&
              _retrievePhase == _RetrievePhase.confirmReturn &&
              _retrieveBooking != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 96,
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bag location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rack: ${_retrieveBooking!.rackId}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text('Roll: ${_retrieveBooking!.candidateId}'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _confirmReturn,
                        child: const Text('CONFIRM RETURN'),
                      ),
                      TextButton(
                        onPressed: _cancelRetrieve,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_hintText())),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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

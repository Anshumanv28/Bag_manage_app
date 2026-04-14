import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_db.g.dart';

class Bookings extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get rackId => text()();
  TextColumn get candidateId => text()();
  TextColumn get operatorId => text()();
  TextColumn get status => text()(); // active/complete
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get pushedStart => boolean().withDefault(const Constant(false))();
  BoolColumn get pushedFinish => boolean().withDefault(const Constant(false))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Synced from server `/sync/pull` `flagged_upsert` (ambiguous active mappings).
class FlaggedBookings extends Table {
  TextColumn get id => text()();
  TextColumn get bookingId => text()();
  TextColumn get reason => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local scan / confirm timeline; `activity_log` sync mutations until `pushed`.
class BookingActivities extends Table {
  TextColumn get id => text()();
  TextColumn get bookingId => text()();
  TextColumn get operatorId => text()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get eventType => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get metadataJson => text().nullable()();
  BoolColumn get pushed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Every scan/cancel is logged here (syncs via `scan_event` mutations), even when no booking exists.
class ScanEvents extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get operatorId => text()();
  TextColumn get operation => text()(); // deposit/retrieve
  TextColumn get eventType => text()(); // enum values on backend
  TextColumn get candidateId => text().nullable()();
  TextColumn get rackId => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get metadataJson => text().nullable()();
  BoolColumn get pushed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Bookings, FlaggedBookings, BookingActivities, ScanEvents])
class AppDb extends _$AppDb {
  AppDb() : super(driftDatabase(name: 'baggage_management'));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            await customStatement(
              'ALTER TABLE bookings ADD COLUMN pushed_start INTEGER NOT NULL DEFAULT 0',
            );
            await customStatement(
              'ALTER TABLE bookings ADD COLUMN pushed_finish INTEGER NOT NULL DEFAULT 0',
            );
            await customStatement('ALTER TABLE bookings ADD COLUMN last_error TEXT');
            await customStatement('DROP TABLE IF EXISTS locks');
            await customStatement('DROP TABLE IF EXISTS sync_states');
            await customStatement('DROP TABLE IF EXISTS mutation_queue');
          }
          if (from < 4) {
            await customStatement(
              'ALTER TABLE bookings RENAME COLUMN lock_id TO rack_id',
            );
            await customStatement('ALTER TABLE bookings DROP COLUMN table_id');
          }
          if (from < 5) {
            await customStatement(
              'ALTER TABLE bookings RENAME COLUMN customer_id TO candidate_id',
            );
          }
          if (from < 6) {
            await m.createTable(flaggedBookings);
            await m.createTable(bookingActivities);
          }
          if (from < 7) {
            await m.createTable(scanEvents);
          }
        },
      );

  Stream<List<Booking>> watchBookings({String? status}) {
    final q = select(bookings);
    if (status != null) {
      q.where((t) => t.status.equals(status));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return q.watch();
  }

  Stream<List<Booking>> watchBookingsByStatuses(List<String> statuses) {
    final q = select(bookings)..where((t) => t.status.isIn(statuses));
    q.orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return q.watch();
  }

  Future<Booking?> findActiveBookingByCandidateId(String candidateId) async {
    final rows = await findActiveBookingsByCandidateId(candidateId);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Booking>> findActiveBookingsByCandidateId(String candidateId) {
    return (select(bookings)
          ..where((t) => t.candidateId.equals(candidateId))
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
  }

  Future<Booking?> findActiveBookingByRackId(String rackId) async {
    final rows = await findActiveBookingsByRackId(rackId);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Booking>> findActiveBookingsByRackId(String rackId) {
    return (select(bookings)
          ..where((t) => t.rackId.equals(rackId))
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
  }

  Future<bool> isBookingFlagged(String bookingId) async {
    final row = await (select(flaggedBookings)
          ..where((t) => t.bookingId.equals(bookingId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> upsertFlaggedBooking({
    required String id,
    required String bookingId,
    required String reason,
    required DateTime createdAt,
  }) async {
    await into(flaggedBookings).insertOnConflictUpdate(
      FlaggedBookingsCompanion(
        id: Value(id),
        bookingId: Value(bookingId),
        reason: Value(reason),
        createdAt: Value(createdAt),
      ),
    );
  }

  Future<void> clearFlagsForBooking(String bookingId) async {
    await (delete(flaggedBookings)..where((t) => t.bookingId.equals(bookingId))).go();
  }

  Future<void> insertBookingActivity({
    required String id,
    required String bookingId,
    required String operatorId,
    String? deviceId,
    required String eventType,
    required DateTime occurredAt,
    String? metadataJson,
  }) async {
    await into(bookingActivities).insert(
      BookingActivitiesCompanion.insert(
        id: id,
        bookingId: bookingId,
        operatorId: operatorId,
        deviceId: Value(deviceId),
        eventType: eventType,
        occurredAt: occurredAt,
        metadataJson: Value(metadataJson),
        pushed: const Value(false),
      ),
    );
  }

  Future<List<BookingActivity>> listActivitiesNeedingPushForBooking(String bookingId) {
    return (select(bookingActivities)
          ..where((t) => t.bookingId.equals(bookingId))
          ..where((t) => t.pushed.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .get();
  }

  Future<void> markActivityPushed(String activityId) async {
    await (update(bookingActivities)..where((t) => t.id.equals(activityId))).write(
      const BookingActivitiesCompanion(pushed: Value(true)),
    );
  }

  Future<void> insertScanEvent({
    required String id,
    required String operatorId,
    required String operation,
    required String eventType,
    String? candidateId,
    String? rackId,
    required DateTime occurredAt,
    String? metadataJson,
  }) async {
    await into(scanEvents).insert(
      ScanEventsCompanion.insert(
        id: id,
        operatorId: operatorId,
        operation: operation,
        eventType: eventType,
        candidateId: Value(candidateId),
        rackId: Value(rackId),
        occurredAt: occurredAt,
        metadataJson: Value(metadataJson),
        pushed: const Value(false),
      ),
    );
  }

  Future<List<ScanEvent>> listScanEventsNeedingPush({int limit = 200}) {
    return (select(scanEvents)
          ..where((t) => t.pushed.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)])
          ..limit(limit))
        .get();
  }

  Future<void> markScanEventPushed(String scanEventId) async {
    await (update(scanEvents)..where((t) => t.id.equals(scanEventId))).write(
      const ScanEventsCompanion(pushed: Value(true)),
    );
  }

  Future<void> upsertLocalBooking({
    required String id,
    required String rackId,
    required String candidateId,
    required String operatorId,
    required String status,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    await upsertBooking(
      id: id,
      rackId: rackId,
      candidateId: candidateId,
      operatorId: operatorId,
      status: status,
      startedAt: startedAt ?? DateTime.now(),
      endedAt: endedAt,
    );
  }

  Future<void> upsertBooking({
    required String id,
    required String rackId,
    required String candidateId,
    required String operatorId,
    required String status,
    required DateTime startedAt,
    DateTime? endedAt,
    bool? pushedStart,
    bool? pushedFinish,
    String? lastError,
  }) async {
    await into(bookings).insertOnConflictUpdate(
      BookingsCompanion(
        id: Value(id),
        rackId: Value(rackId),
        candidateId: Value(candidateId),
        operatorId: Value(operatorId),
        status: Value(status),
        startedAt: Value(startedAt),
        endedAt: Value(endedAt),
        pushedStart: pushedStart == null ? const Value.absent() : Value(pushedStart),
        pushedFinish: pushedFinish == null ? const Value.absent() : Value(pushedFinish),
        lastError: lastError == null ? const Value.absent() : Value(lastError),
      ),
    );
  }

  Future<void> deleteBooking(String id) async {
    await (delete(bookings)..where((t) => t.id.equals(id))).go();
  }

  Future<int> _countBookingPushPending() async {
    final q = select(bookings)
      ..where(
        (t) =>
            t.pushedStart.equals(false) |
            (t.status.equals('complete') & t.pushedFinish.equals(false)),
      );
    final rows = await q.get();
    return rows.length;
  }

  Future<int> _countActivityPushPending() async {
    final q = select(bookingActivities)..where((t) => t.pushed.equals(false));
    final rows = await q.get();
    return rows.length;
  }

  Future<int> _countScanEventPushPending() async {
    final q = select(scanEvents)..where((t) => t.pushed.equals(false));
    final rows = await q.get();
    return rows.length;
  }

  Future<int> countPendingPush() async {
    final b = await _countBookingPushPending();
    final a = await _countActivityPushPending();
    final s = await _countScanEventPushPending();
    return b + a + s;
  }

  Stream<int> watchPendingPushCount() {
    return Stream<int>.multi((controller) {
      Future<void> emit() async {
        if (controller.isClosed) return;
        try {
          final n = await countPendingPush();
          if (!controller.isClosed) controller.add(n);
        } catch (e, st) {
          if (!controller.isClosed) controller.addError(e, st);
        }
      }

      unawaited(emit());
      final sub1 = select(bookings).watch().listen((_) => emit());
      final sub2 = select(bookingActivities).watch().listen((_) => emit());
      final sub3 = select(scanEvents).watch().listen((_) => emit());
      controller.onCancel = () {
        sub1.cancel();
        sub2.cancel();
        sub3.cancel();
      };
    });
  }

  Future<List<Booking>> listBookingsNeedingPush({int limit = 200}) {
    final q = select(bookings)
      ..where(
        (t) =>
            t.pushedStart.equals(false) |
            (t.status.equals('complete') & t.pushedFinish.equals(false)),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.startedAt)])
      ..limit(limit);
    return q.get();
  }

  /// Bookings that need start/finish push, plus any booking with unpushed activity rows.
  Future<List<Booking>> listBookingsForOutboxPush({int limit = 200}) async {
    final needPush = await listBookingsNeedingPush(limit: limit);
    final byId = {for (final b in needPush) b.id: b};
    final unpushedAct = await (select(bookingActivities)
          ..where((t) => t.pushed.equals(false)))
        .get();
    for (final a in unpushedAct) {
      if (byId.containsKey(a.bookingId)) continue;
      final row = await (select(bookings)..where((t) => t.id.equals(a.bookingId)))
          .getSingleOrNull();
      if (row != null) {
        byId[row.id] = row;
      }
    }
    final merged = byId.values.toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    if (merged.length <= limit) return merged;
    return merged.take(limit).toList();
  }

  Future<Booking?> getBookingById(String id) {
    return (select(bookings)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> markBookingStartPushed(String bookingId) async {
    await (update(bookings)..where((t) => t.id.equals(bookingId))).write(
      const BookingsCompanion(
        pushedStart: Value(true),
        lastError: Value(null),
      ),
    );
  }

  Future<void> markBookingFinishPushed(String bookingId) async {
    await (update(bookings)..where((t) => t.id.equals(bookingId))).write(
      const BookingsCompanion(
        pushedFinish: Value(true),
        lastError: Value(null),
      ),
    );
  }

  Future<void> markBookingPushFailed(String bookingId, String error) async {
    await (update(bookings)..where((t) => t.id.equals(bookingId))).write(
      BookingsCompanion(
        lastError: Value(error),
      ),
    );
  }
}

final appDbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(db.close);
  return db;
});

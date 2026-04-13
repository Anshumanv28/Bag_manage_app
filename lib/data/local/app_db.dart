import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_db.g.dart';

class Bookings extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get rackId => text()();
  TextColumn get candidateId => text()();
  TextColumn get operatorId => text()();
  TextColumn get status => text()(); // active/ended/cancelled
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  // Local-only sync bookkeeping (single-table outbox).
  BoolColumn get pushedStart => boolean().withDefault(const Constant(false))();
  BoolColumn get pushedFinish => boolean().withDefault(const Constant(false))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Bookings])
class AppDb extends _$AppDb {
  AppDb() : super(driftDatabase(name: 'baggage_management'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Local DB is single-table: `bookings`.
          // We migrate by:
          // - adding new columns to existing bookings (if present)
          // - dropping obsolete tables (locks/sync_states/mutation_queue)
          if (from < 3) {
            await customStatement(
              'ALTER TABLE bookings ADD COLUMN pushed_start INTEGER NOT NULL DEFAULT 0',
            );
            await customStatement(
              'ALTER TABLE bookings ADD COLUMN pushed_finish INTEGER NOT NULL DEFAULT 0',
            );
            await customStatement('ALTER TABLE bookings ADD COLUMN last_error TEXT');

            // Best-effort drops (tables may not exist in fresh installs).
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
        },
      );

  // ---- Bookings ----
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

  Future<Booking?> findActiveBookingByCandidateId(String candidateId) {
    return (select(bookings)
          ..where((t) => t.candidateId.equals(candidateId))
          ..where((t) => t.status.equals('active'))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Booking?> findActiveBookingByRackId(String rackId) {
    return (select(bookings)
          ..where((t) => t.rackId.equals(rackId))
          ..where((t) => t.status.equals('active'))
          ..limit(1))
        .getSingleOrNull();
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

  // Pending pushes are derived from bookings flags (single-table outbox).
  Stream<int> watchPendingPushCount() {
    final q = select(bookings)
      ..where(
        (t) =>
            t.pushedStart.equals(false) |
            (t.status.equals('complete') & t.pushedFinish.equals(false)),
      );
    return q.watch().map((rows) => rows.length);
  }

  Future<int> countPendingPush() async {
    final q = select(bookings)
      ..where(
        (t) =>
            t.pushedStart.equals(false) |
            (t.status.equals('complete') & t.pushedFinish.equals(false)),
      );
    final rows = await q.get();
    return rows.length;
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

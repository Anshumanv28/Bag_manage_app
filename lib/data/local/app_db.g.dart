// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $BookingsTable extends Bookings with TableInfo<$BookingsTable, Booking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rackIdMeta = const VerificationMeta('rackId');
  @override
  late final GeneratedColumn<String> rackId = GeneratedColumn<String>(
    'rack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _candidateIdMeta = const VerificationMeta(
    'candidateId',
  );
  @override
  late final GeneratedColumn<String> candidateId = GeneratedColumn<String>(
    'candidate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operatorIdMeta = const VerificationMeta(
    'operatorId',
  );
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
    'operator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pushedStartMeta = const VerificationMeta(
    'pushedStart',
  );
  @override
  late final GeneratedColumn<bool> pushedStart = GeneratedColumn<bool>(
    'pushed_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pushed_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pushedFinishMeta = const VerificationMeta(
    'pushedFinish',
  );
  @override
  late final GeneratedColumn<bool> pushedFinish = GeneratedColumn<bool>(
    'pushed_finish',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pushed_finish" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rackId,
    candidateId,
    operatorId,
    status,
    startedAt,
    endedAt,
    pushedStart,
    pushedFinish,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Booking> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rack_id')) {
      context.handle(
        _rackIdMeta,
        rackId.isAcceptableOrUnknown(data['rack_id']!, _rackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rackIdMeta);
    }
    if (data.containsKey('candidate_id')) {
      context.handle(
        _candidateIdMeta,
        candidateId.isAcceptableOrUnknown(
          data['candidate_id']!,
          _candidateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_candidateIdMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
        _operatorIdMeta,
        operatorId.isAcceptableOrUnknown(data['operator_id']!, _operatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('pushed_start')) {
      context.handle(
        _pushedStartMeta,
        pushedStart.isAcceptableOrUnknown(
          data['pushed_start']!,
          _pushedStartMeta,
        ),
      );
    }
    if (data.containsKey('pushed_finish')) {
      context.handle(
        _pushedFinishMeta,
        pushedFinish.isAcceptableOrUnknown(
          data['pushed_finish']!,
          _pushedFinishMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Booking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Booking(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      rackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rack_id'],
      )!,
      candidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_id'],
      )!,
      operatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      pushedStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pushed_start'],
      )!,
      pushedFinish: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pushed_finish'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $BookingsTable createAlias(String alias) {
    return $BookingsTable(attachedDatabase, alias);
  }
}

class Booking extends DataClass implements Insertable<Booking> {
  final String id;
  final String rackId;
  final String candidateId;
  final String operatorId;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool pushedStart;
  final bool pushedFinish;
  final String? lastError;
  const Booking({
    required this.id,
    required this.rackId,
    required this.candidateId,
    required this.operatorId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.pushedStart,
    required this.pushedFinish,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rack_id'] = Variable<String>(rackId);
    map['candidate_id'] = Variable<String>(candidateId);
    map['operator_id'] = Variable<String>(operatorId);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['pushed_start'] = Variable<bool>(pushedStart);
    map['pushed_finish'] = Variable<bool>(pushedFinish);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  BookingsCompanion toCompanion(bool nullToAbsent) {
    return BookingsCompanion(
      id: Value(id),
      rackId: Value(rackId),
      candidateId: Value(candidateId),
      operatorId: Value(operatorId),
      status: Value(status),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      pushedStart: Value(pushedStart),
      pushedFinish: Value(pushedFinish),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory Booking.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Booking(
      id: serializer.fromJson<String>(json['id']),
      rackId: serializer.fromJson<String>(json['rackId']),
      candidateId: serializer.fromJson<String>(json['candidateId']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      pushedStart: serializer.fromJson<bool>(json['pushedStart']),
      pushedFinish: serializer.fromJson<bool>(json['pushedFinish']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rackId': serializer.toJson<String>(rackId),
      'candidateId': serializer.toJson<String>(candidateId),
      'operatorId': serializer.toJson<String>(operatorId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'pushedStart': serializer.toJson<bool>(pushedStart),
      'pushedFinish': serializer.toJson<bool>(pushedFinish),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  Booking copyWith({
    String? id,
    String? rackId,
    String? candidateId,
    String? operatorId,
    String? status,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    bool? pushedStart,
    bool? pushedFinish,
    Value<String?> lastError = const Value.absent(),
  }) => Booking(
    id: id ?? this.id,
    rackId: rackId ?? this.rackId,
    candidateId: candidateId ?? this.candidateId,
    operatorId: operatorId ?? this.operatorId,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    pushedStart: pushedStart ?? this.pushedStart,
    pushedFinish: pushedFinish ?? this.pushedFinish,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  Booking copyWithCompanion(BookingsCompanion data) {
    return Booking(
      id: data.id.present ? data.id.value : this.id,
      rackId: data.rackId.present ? data.rackId.value : this.rackId,
      candidateId: data.candidateId.present
          ? data.candidateId.value
          : this.candidateId,
      operatorId: data.operatorId.present
          ? data.operatorId.value
          : this.operatorId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      pushedStart: data.pushedStart.present
          ? data.pushedStart.value
          : this.pushedStart,
      pushedFinish: data.pushedFinish.present
          ? data.pushedFinish.value
          : this.pushedFinish,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Booking(')
          ..write('id: $id, ')
          ..write('rackId: $rackId, ')
          ..write('candidateId: $candidateId, ')
          ..write('operatorId: $operatorId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('pushedStart: $pushedStart, ')
          ..write('pushedFinish: $pushedFinish, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rackId,
    candidateId,
    operatorId,
    status,
    startedAt,
    endedAt,
    pushedStart,
    pushedFinish,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Booking &&
          other.id == this.id &&
          other.rackId == this.rackId &&
          other.candidateId == this.candidateId &&
          other.operatorId == this.operatorId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.pushedStart == this.pushedStart &&
          other.pushedFinish == this.pushedFinish &&
          other.lastError == this.lastError);
}

class BookingsCompanion extends UpdateCompanion<Booking> {
  final Value<String> id;
  final Value<String> rackId;
  final Value<String> candidateId;
  final Value<String> operatorId;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<bool> pushedStart;
  final Value<bool> pushedFinish;
  final Value<String?> lastError;
  final Value<int> rowid;
  const BookingsCompanion({
    this.id = const Value.absent(),
    this.rackId = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.pushedStart = const Value.absent(),
    this.pushedFinish = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingsCompanion.insert({
    required String id,
    required String rackId,
    required String candidateId,
    required String operatorId,
    required String status,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.pushedStart = const Value.absent(),
    this.pushedFinish = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       rackId = Value(rackId),
       candidateId = Value(candidateId),
       operatorId = Value(operatorId),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<Booking> custom({
    Expression<String>? id,
    Expression<String>? rackId,
    Expression<String>? candidateId,
    Expression<String>? operatorId,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<bool>? pushedStart,
    Expression<bool>? pushedFinish,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rackId != null) 'rack_id': rackId,
      if (candidateId != null) 'candidate_id': candidateId,
      if (operatorId != null) 'operator_id': operatorId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (pushedStart != null) 'pushed_start': pushedStart,
      if (pushedFinish != null) 'pushed_finish': pushedFinish,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingsCompanion copyWith({
    Value<String>? id,
    Value<String>? rackId,
    Value<String>? candidateId,
    Value<String>? operatorId,
    Value<String>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<bool>? pushedStart,
    Value<bool>? pushedFinish,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return BookingsCompanion(
      id: id ?? this.id,
      rackId: rackId ?? this.rackId,
      candidateId: candidateId ?? this.candidateId,
      operatorId: operatorId ?? this.operatorId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      pushedStart: pushedStart ?? this.pushedStart,
      pushedFinish: pushedFinish ?? this.pushedFinish,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rackId.present) {
      map['rack_id'] = Variable<String>(rackId.value);
    }
    if (candidateId.present) {
      map['candidate_id'] = Variable<String>(candidateId.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (pushedStart.present) {
      map['pushed_start'] = Variable<bool>(pushedStart.value);
    }
    if (pushedFinish.present) {
      map['pushed_finish'] = Variable<bool>(pushedFinish.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingsCompanion(')
          ..write('id: $id, ')
          ..write('rackId: $rackId, ')
          ..write('candidateId: $candidateId, ')
          ..write('operatorId: $operatorId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('pushedStart: $pushedStart, ')
          ..write('pushedFinish: $pushedFinish, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $BookingsTable bookings = $BookingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [bookings];
}

typedef $$BookingsTableCreateCompanionBuilder =
    BookingsCompanion Function({
      required String id,
      required String rackId,
      required String candidateId,
      required String operatorId,
      required String status,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<bool> pushedStart,
      Value<bool> pushedFinish,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$BookingsTableUpdateCompanionBuilder =
    BookingsCompanion Function({
      Value<String> id,
      Value<String> rackId,
      Value<String> candidateId,
      Value<String> operatorId,
      Value<String> status,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<bool> pushedStart,
      Value<bool> pushedFinish,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$BookingsTableFilterComposer extends Composer<_$AppDb, $BookingsTable> {
  $$BookingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rackId => $composableBuilder(
    column: $table.rackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pushedStart => $composableBuilder(
    column: $table.pushedStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pushedFinish => $composableBuilder(
    column: $table.pushedFinish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingsTableOrderingComposer
    extends Composer<_$AppDb, $BookingsTable> {
  $$BookingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rackId => $composableBuilder(
    column: $table.rackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pushedStart => $composableBuilder(
    column: $table.pushedStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pushedFinish => $composableBuilder(
    column: $table.pushedFinish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingsTableAnnotationComposer
    extends Composer<_$AppDb, $BookingsTable> {
  $$BookingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rackId =>
      $composableBuilder(column: $table.rackId, builder: (column) => column);

  GeneratedColumn<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<bool> get pushedStart => $composableBuilder(
    column: $table.pushedStart,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pushedFinish => $composableBuilder(
    column: $table.pushedFinish,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$BookingsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BookingsTable,
          Booking,
          $$BookingsTableFilterComposer,
          $$BookingsTableOrderingComposer,
          $$BookingsTableAnnotationComposer,
          $$BookingsTableCreateCompanionBuilder,
          $$BookingsTableUpdateCompanionBuilder,
          (Booking, BaseReferences<_$AppDb, $BookingsTable, Booking>),
          Booking,
          PrefetchHooks Function()
        > {
  $$BookingsTableTableManager(_$AppDb db, $BookingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> rackId = const Value.absent(),
                Value<String> candidateId = const Value.absent(),
                Value<String> operatorId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> pushedStart = const Value.absent(),
                Value<bool> pushedFinish = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingsCompanion(
                id: id,
                rackId: rackId,
                candidateId: candidateId,
                operatorId: operatorId,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                pushedStart: pushedStart,
                pushedFinish: pushedFinish,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String rackId,
                required String candidateId,
                required String operatorId,
                required String status,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> pushedStart = const Value.absent(),
                Value<bool> pushedFinish = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingsCompanion.insert(
                id: id,
                rackId: rackId,
                candidateId: candidateId,
                operatorId: operatorId,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                pushedStart: pushedStart,
                pushedFinish: pushedFinish,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BookingsTable,
      Booking,
      $$BookingsTableFilterComposer,
      $$BookingsTableOrderingComposer,
      $$BookingsTableAnnotationComposer,
      $$BookingsTableCreateCompanionBuilder,
      $$BookingsTableUpdateCompanionBuilder,
      (Booking, BaseReferences<_$AppDb, $BookingsTable, Booking>),
      Booking,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$BookingsTableTableManager get bookings =>
      $$BookingsTableTableManager(_db, _db.bookings);
}

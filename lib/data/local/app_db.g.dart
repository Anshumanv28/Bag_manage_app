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

class $FlaggedBookingsTable extends FlaggedBookings
    with TableInfo<$FlaggedBookingsTable, FlaggedBooking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlaggedBookingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookingIdMeta = const VerificationMeta(
    'bookingId',
  );
  @override
  late final GeneratedColumn<String> bookingId = GeneratedColumn<String>(
    'booking_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bookingId, reason, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flagged_bookings';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlaggedBooking> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('booking_id')) {
      context.handle(
        _bookingIdMeta,
        bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlaggedBooking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlaggedBooking(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FlaggedBookingsTable createAlias(String alias) {
    return $FlaggedBookingsTable(attachedDatabase, alias);
  }
}

class FlaggedBooking extends DataClass implements Insertable<FlaggedBooking> {
  final String id;
  final String bookingId;
  final String reason;
  final DateTime createdAt;
  const FlaggedBooking({
    required this.id,
    required this.bookingId,
    required this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['booking_id'] = Variable<String>(bookingId);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FlaggedBookingsCompanion toCompanion(bool nullToAbsent) {
    return FlaggedBookingsCompanion(
      id: Value(id),
      bookingId: Value(bookingId),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory FlaggedBooking.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlaggedBooking(
      id: serializer.fromJson<String>(json['id']),
      bookingId: serializer.fromJson<String>(json['bookingId']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookingId': serializer.toJson<String>(bookingId),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FlaggedBooking copyWith({
    String? id,
    String? bookingId,
    String? reason,
    DateTime? createdAt,
  }) => FlaggedBooking(
    id: id ?? this.id,
    bookingId: bookingId ?? this.bookingId,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  FlaggedBooking copyWithCompanion(FlaggedBookingsCompanion data) {
    return FlaggedBooking(
      id: data.id.present ? data.id.value : this.id,
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlaggedBooking(')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookingId, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlaggedBooking &&
          other.id == this.id &&
          other.bookingId == this.bookingId &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class FlaggedBookingsCompanion extends UpdateCompanion<FlaggedBooking> {
  final Value<String> id;
  final Value<String> bookingId;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FlaggedBookingsCompanion({
    this.id = const Value.absent(),
    this.bookingId = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlaggedBookingsCompanion.insert({
    required String id,
    required String bookingId,
    required String reason,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookingId = Value(bookingId),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<FlaggedBooking> custom({
    Expression<String>? id,
    Expression<String>? bookingId,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookingId != null) 'booking_id': bookingId,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlaggedBookingsCompanion copyWith({
    Value<String>? id,
    Value<String>? bookingId,
    Value<String>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FlaggedBookingsCompanion(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookingId.present) {
      map['booking_id'] = Variable<String>(bookingId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlaggedBookingsCompanion(')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookingActivitiesTable extends BookingActivities
    with TableInfo<$BookingActivitiesTable, BookingActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookingIdMeta = const VerificationMeta(
    'bookingId',
  );
  @override
  late final GeneratedColumn<String> bookingId = GeneratedColumn<String>(
    'booking_id',
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
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pushedMeta = const VerificationMeta('pushed');
  @override
  late final GeneratedColumn<bool> pushed = GeneratedColumn<bool>(
    'pushed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pushed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookingId,
    operatorId,
    deviceId,
    eventType,
    occurredAt,
    metadataJson,
    pushed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'booking_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingActivity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('booking_id')) {
      context.handle(
        _bookingIdMeta,
        bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
        _operatorIdMeta,
        operatorId.isAcceptableOrUnknown(data['operator_id']!, _operatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('pushed')) {
      context.handle(
        _pushedMeta,
        pushed.isAcceptableOrUnknown(data['pushed']!, _pushedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookingActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingActivity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_id'],
      )!,
      operatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      pushed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pushed'],
      )!,
    );
  }

  @override
  $BookingActivitiesTable createAlias(String alias) {
    return $BookingActivitiesTable(attachedDatabase, alias);
  }
}

class BookingActivity extends DataClass implements Insertable<BookingActivity> {
  final String id;
  final String bookingId;
  final String operatorId;
  final String? deviceId;
  final String eventType;
  final DateTime occurredAt;
  final String? metadataJson;
  final bool pushed;
  const BookingActivity({
    required this.id,
    required this.bookingId,
    required this.operatorId,
    this.deviceId,
    required this.eventType,
    required this.occurredAt,
    this.metadataJson,
    required this.pushed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['booking_id'] = Variable<String>(bookingId);
    map['operator_id'] = Variable<String>(operatorId);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['pushed'] = Variable<bool>(pushed);
    return map;
  }

  BookingActivitiesCompanion toCompanion(bool nullToAbsent) {
    return BookingActivitiesCompanion(
      id: Value(id),
      bookingId: Value(bookingId),
      operatorId: Value(operatorId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      eventType: Value(eventType),
      occurredAt: Value(occurredAt),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      pushed: Value(pushed),
    );
  }

  factory BookingActivity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingActivity(
      id: serializer.fromJson<String>(json['id']),
      bookingId: serializer.fromJson<String>(json['bookingId']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      pushed: serializer.fromJson<bool>(json['pushed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookingId': serializer.toJson<String>(bookingId),
      'operatorId': serializer.toJson<String>(operatorId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'eventType': serializer.toJson<String>(eventType),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'pushed': serializer.toJson<bool>(pushed),
    };
  }

  BookingActivity copyWith({
    String? id,
    String? bookingId,
    String? operatorId,
    Value<String?> deviceId = const Value.absent(),
    String? eventType,
    DateTime? occurredAt,
    Value<String?> metadataJson = const Value.absent(),
    bool? pushed,
  }) => BookingActivity(
    id: id ?? this.id,
    bookingId: bookingId ?? this.bookingId,
    operatorId: operatorId ?? this.operatorId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    eventType: eventType ?? this.eventType,
    occurredAt: occurredAt ?? this.occurredAt,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    pushed: pushed ?? this.pushed,
  );
  BookingActivity copyWithCompanion(BookingActivitiesCompanion data) {
    return BookingActivity(
      id: data.id.present ? data.id.value : this.id,
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      operatorId: data.operatorId.present
          ? data.operatorId.value
          : this.operatorId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      pushed: data.pushed.present ? data.pushed.value : this.pushed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingActivity(')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('operatorId: $operatorId, ')
          ..write('deviceId: $deviceId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('pushed: $pushed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookingId,
    operatorId,
    deviceId,
    eventType,
    occurredAt,
    metadataJson,
    pushed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingActivity &&
          other.id == this.id &&
          other.bookingId == this.bookingId &&
          other.operatorId == this.operatorId &&
          other.deviceId == this.deviceId &&
          other.eventType == this.eventType &&
          other.occurredAt == this.occurredAt &&
          other.metadataJson == this.metadataJson &&
          other.pushed == this.pushed);
}

class BookingActivitiesCompanion extends UpdateCompanion<BookingActivity> {
  final Value<String> id;
  final Value<String> bookingId;
  final Value<String> operatorId;
  final Value<String?> deviceId;
  final Value<String> eventType;
  final Value<DateTime> occurredAt;
  final Value<String?> metadataJson;
  final Value<bool> pushed;
  final Value<int> rowid;
  const BookingActivitiesCompanion({
    this.id = const Value.absent(),
    this.bookingId = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.pushed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingActivitiesCompanion.insert({
    required String id,
    required String bookingId,
    required String operatorId,
    this.deviceId = const Value.absent(),
    required String eventType,
    required DateTime occurredAt,
    this.metadataJson = const Value.absent(),
    this.pushed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookingId = Value(bookingId),
       operatorId = Value(operatorId),
       eventType = Value(eventType),
       occurredAt = Value(occurredAt);
  static Insertable<BookingActivity> custom({
    Expression<String>? id,
    Expression<String>? bookingId,
    Expression<String>? operatorId,
    Expression<String>? deviceId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredAt,
    Expression<String>? metadataJson,
    Expression<bool>? pushed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookingId != null) 'booking_id': bookingId,
      if (operatorId != null) 'operator_id': operatorId,
      if (deviceId != null) 'device_id': deviceId,
      if (eventType != null) 'event_type': eventType,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (pushed != null) 'pushed': pushed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? bookingId,
    Value<String>? operatorId,
    Value<String?>? deviceId,
    Value<String>? eventType,
    Value<DateTime>? occurredAt,
    Value<String?>? metadataJson,
    Value<bool>? pushed,
    Value<int>? rowid,
  }) {
    return BookingActivitiesCompanion(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      operatorId: operatorId ?? this.operatorId,
      deviceId: deviceId ?? this.deviceId,
      eventType: eventType ?? this.eventType,
      occurredAt: occurredAt ?? this.occurredAt,
      metadataJson: metadataJson ?? this.metadataJson,
      pushed: pushed ?? this.pushed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookingId.present) {
      map['booking_id'] = Variable<String>(bookingId.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (pushed.present) {
      map['pushed'] = Variable<bool>(pushed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('operatorId: $operatorId, ')
          ..write('deviceId: $deviceId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('pushed: $pushed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanEventsTable extends ScanEvents
    with TableInfo<$ScanEventsTable, ScanEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rackIdMeta = const VerificationMeta('rackId');
  @override
  late final GeneratedColumn<String> rackId = GeneratedColumn<String>(
    'rack_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pushedMeta = const VerificationMeta('pushed');
  @override
  late final GeneratedColumn<bool> pushed = GeneratedColumn<bool>(
    'pushed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pushed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operatorId,
    operation,
    eventType,
    candidateId,
    rackId,
    occurredAt,
    metadataJson,
    pushed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
        _operatorIdMeta,
        operatorId.isAcceptableOrUnknown(data['operator_id']!, _operatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('candidate_id')) {
      context.handle(
        _candidateIdMeta,
        candidateId.isAcceptableOrUnknown(
          data['candidate_id']!,
          _candidateIdMeta,
        ),
      );
    }
    if (data.containsKey('rack_id')) {
      context.handle(
        _rackIdMeta,
        rackId.isAcceptableOrUnknown(data['rack_id']!, _rackIdMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('pushed')) {
      context.handle(
        _pushedMeta,
        pushed.isAcceptableOrUnknown(data['pushed']!, _pushedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      candidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_id'],
      ),
      rackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rack_id'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      pushed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pushed'],
      )!,
    );
  }

  @override
  $ScanEventsTable createAlias(String alias) {
    return $ScanEventsTable(attachedDatabase, alias);
  }
}

class ScanEvent extends DataClass implements Insertable<ScanEvent> {
  final String id;
  final String operatorId;
  final String operation;
  final String eventType;
  final String? candidateId;
  final String? rackId;
  final DateTime occurredAt;
  final String? metadataJson;
  final bool pushed;
  const ScanEvent({
    required this.id,
    required this.operatorId,
    required this.operation,
    required this.eventType,
    this.candidateId,
    this.rackId,
    required this.occurredAt,
    this.metadataJson,
    required this.pushed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operator_id'] = Variable<String>(operatorId);
    map['operation'] = Variable<String>(operation);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || candidateId != null) {
      map['candidate_id'] = Variable<String>(candidateId);
    }
    if (!nullToAbsent || rackId != null) {
      map['rack_id'] = Variable<String>(rackId);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['pushed'] = Variable<bool>(pushed);
    return map;
  }

  ScanEventsCompanion toCompanion(bool nullToAbsent) {
    return ScanEventsCompanion(
      id: Value(id),
      operatorId: Value(operatorId),
      operation: Value(operation),
      eventType: Value(eventType),
      candidateId: candidateId == null && nullToAbsent
          ? const Value.absent()
          : Value(candidateId),
      rackId: rackId == null && nullToAbsent
          ? const Value.absent()
          : Value(rackId),
      occurredAt: Value(occurredAt),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      pushed: Value(pushed),
    );
  }

  factory ScanEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanEvent(
      id: serializer.fromJson<String>(json['id']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      operation: serializer.fromJson<String>(json['operation']),
      eventType: serializer.fromJson<String>(json['eventType']),
      candidateId: serializer.fromJson<String?>(json['candidateId']),
      rackId: serializer.fromJson<String?>(json['rackId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      pushed: serializer.fromJson<bool>(json['pushed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operatorId': serializer.toJson<String>(operatorId),
      'operation': serializer.toJson<String>(operation),
      'eventType': serializer.toJson<String>(eventType),
      'candidateId': serializer.toJson<String?>(candidateId),
      'rackId': serializer.toJson<String?>(rackId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'pushed': serializer.toJson<bool>(pushed),
    };
  }

  ScanEvent copyWith({
    String? id,
    String? operatorId,
    String? operation,
    String? eventType,
    Value<String?> candidateId = const Value.absent(),
    Value<String?> rackId = const Value.absent(),
    DateTime? occurredAt,
    Value<String?> metadataJson = const Value.absent(),
    bool? pushed,
  }) => ScanEvent(
    id: id ?? this.id,
    operatorId: operatorId ?? this.operatorId,
    operation: operation ?? this.operation,
    eventType: eventType ?? this.eventType,
    candidateId: candidateId.present ? candidateId.value : this.candidateId,
    rackId: rackId.present ? rackId.value : this.rackId,
    occurredAt: occurredAt ?? this.occurredAt,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    pushed: pushed ?? this.pushed,
  );
  ScanEvent copyWithCompanion(ScanEventsCompanion data) {
    return ScanEvent(
      id: data.id.present ? data.id.value : this.id,
      operatorId: data.operatorId.present
          ? data.operatorId.value
          : this.operatorId,
      operation: data.operation.present ? data.operation.value : this.operation,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      candidateId: data.candidateId.present
          ? data.candidateId.value
          : this.candidateId,
      rackId: data.rackId.present ? data.rackId.value : this.rackId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      pushed: data.pushed.present ? data.pushed.value : this.pushed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanEvent(')
          ..write('id: $id, ')
          ..write('operatorId: $operatorId, ')
          ..write('operation: $operation, ')
          ..write('eventType: $eventType, ')
          ..write('candidateId: $candidateId, ')
          ..write('rackId: $rackId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('pushed: $pushed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operatorId,
    operation,
    eventType,
    candidateId,
    rackId,
    occurredAt,
    metadataJson,
    pushed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanEvent &&
          other.id == this.id &&
          other.operatorId == this.operatorId &&
          other.operation == this.operation &&
          other.eventType == this.eventType &&
          other.candidateId == this.candidateId &&
          other.rackId == this.rackId &&
          other.occurredAt == this.occurredAt &&
          other.metadataJson == this.metadataJson &&
          other.pushed == this.pushed);
}

class ScanEventsCompanion extends UpdateCompanion<ScanEvent> {
  final Value<String> id;
  final Value<String> operatorId;
  final Value<String> operation;
  final Value<String> eventType;
  final Value<String?> candidateId;
  final Value<String?> rackId;
  final Value<DateTime> occurredAt;
  final Value<String?> metadataJson;
  final Value<bool> pushed;
  final Value<int> rowid;
  const ScanEventsCompanion({
    this.id = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.operation = const Value.absent(),
    this.eventType = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.rackId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.pushed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanEventsCompanion.insert({
    required String id,
    required String operatorId,
    required String operation,
    required String eventType,
    this.candidateId = const Value.absent(),
    this.rackId = const Value.absent(),
    required DateTime occurredAt,
    this.metadataJson = const Value.absent(),
    this.pushed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operatorId = Value(operatorId),
       operation = Value(operation),
       eventType = Value(eventType),
       occurredAt = Value(occurredAt);
  static Insertable<ScanEvent> custom({
    Expression<String>? id,
    Expression<String>? operatorId,
    Expression<String>? operation,
    Expression<String>? eventType,
    Expression<String>? candidateId,
    Expression<String>? rackId,
    Expression<DateTime>? occurredAt,
    Expression<String>? metadataJson,
    Expression<bool>? pushed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operatorId != null) 'operator_id': operatorId,
      if (operation != null) 'operation': operation,
      if (eventType != null) 'event_type': eventType,
      if (candidateId != null) 'candidate_id': candidateId,
      if (rackId != null) 'rack_id': rackId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (pushed != null) 'pushed': pushed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? operatorId,
    Value<String>? operation,
    Value<String>? eventType,
    Value<String?>? candidateId,
    Value<String?>? rackId,
    Value<DateTime>? occurredAt,
    Value<String?>? metadataJson,
    Value<bool>? pushed,
    Value<int>? rowid,
  }) {
    return ScanEventsCompanion(
      id: id ?? this.id,
      operatorId: operatorId ?? this.operatorId,
      operation: operation ?? this.operation,
      eventType: eventType ?? this.eventType,
      candidateId: candidateId ?? this.candidateId,
      rackId: rackId ?? this.rackId,
      occurredAt: occurredAt ?? this.occurredAt,
      metadataJson: metadataJson ?? this.metadataJson,
      pushed: pushed ?? this.pushed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (candidateId.present) {
      map['candidate_id'] = Variable<String>(candidateId.value);
    }
    if (rackId.present) {
      map['rack_id'] = Variable<String>(rackId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (pushed.present) {
      map['pushed'] = Variable<bool>(pushed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanEventsCompanion(')
          ..write('id: $id, ')
          ..write('operatorId: $operatorId, ')
          ..write('operation: $operation, ')
          ..write('eventType: $eventType, ')
          ..write('candidateId: $candidateId, ')
          ..write('rackId: $rackId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('pushed: $pushed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $BookingsTable bookings = $BookingsTable(this);
  late final $FlaggedBookingsTable flaggedBookings = $FlaggedBookingsTable(
    this,
  );
  late final $BookingActivitiesTable bookingActivities =
      $BookingActivitiesTable(this);
  late final $ScanEventsTable scanEvents = $ScanEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookings,
    flaggedBookings,
    bookingActivities,
    scanEvents,
  ];
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
typedef $$FlaggedBookingsTableCreateCompanionBuilder =
    FlaggedBookingsCompanion Function({
      required String id,
      required String bookingId,
      required String reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FlaggedBookingsTableUpdateCompanionBuilder =
    FlaggedBookingsCompanion Function({
      Value<String> id,
      Value<String> bookingId,
      Value<String> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FlaggedBookingsTableFilterComposer
    extends Composer<_$AppDb, $FlaggedBookingsTable> {
  $$FlaggedBookingsTableFilterComposer({
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

  ColumnFilters<String> get bookingId => $composableBuilder(
    column: $table.bookingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlaggedBookingsTableOrderingComposer
    extends Composer<_$AppDb, $FlaggedBookingsTable> {
  $$FlaggedBookingsTableOrderingComposer({
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

  ColumnOrderings<String> get bookingId => $composableBuilder(
    column: $table.bookingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlaggedBookingsTableAnnotationComposer
    extends Composer<_$AppDb, $FlaggedBookingsTable> {
  $$FlaggedBookingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookingId =>
      $composableBuilder(column: $table.bookingId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FlaggedBookingsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $FlaggedBookingsTable,
          FlaggedBooking,
          $$FlaggedBookingsTableFilterComposer,
          $$FlaggedBookingsTableOrderingComposer,
          $$FlaggedBookingsTableAnnotationComposer,
          $$FlaggedBookingsTableCreateCompanionBuilder,
          $$FlaggedBookingsTableUpdateCompanionBuilder,
          (
            FlaggedBooking,
            BaseReferences<_$AppDb, $FlaggedBookingsTable, FlaggedBooking>,
          ),
          FlaggedBooking,
          PrefetchHooks Function()
        > {
  $$FlaggedBookingsTableTableManager(_$AppDb db, $FlaggedBookingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlaggedBookingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlaggedBookingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlaggedBookingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookingId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlaggedBookingsCompanion(
                id: id,
                bookingId: bookingId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookingId,
                required String reason,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FlaggedBookingsCompanion.insert(
                id: id,
                bookingId: bookingId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlaggedBookingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $FlaggedBookingsTable,
      FlaggedBooking,
      $$FlaggedBookingsTableFilterComposer,
      $$FlaggedBookingsTableOrderingComposer,
      $$FlaggedBookingsTableAnnotationComposer,
      $$FlaggedBookingsTableCreateCompanionBuilder,
      $$FlaggedBookingsTableUpdateCompanionBuilder,
      (
        FlaggedBooking,
        BaseReferences<_$AppDb, $FlaggedBookingsTable, FlaggedBooking>,
      ),
      FlaggedBooking,
      PrefetchHooks Function()
    >;
typedef $$BookingActivitiesTableCreateCompanionBuilder =
    BookingActivitiesCompanion Function({
      required String id,
      required String bookingId,
      required String operatorId,
      Value<String?> deviceId,
      required String eventType,
      required DateTime occurredAt,
      Value<String?> metadataJson,
      Value<bool> pushed,
      Value<int> rowid,
    });
typedef $$BookingActivitiesTableUpdateCompanionBuilder =
    BookingActivitiesCompanion Function({
      Value<String> id,
      Value<String> bookingId,
      Value<String> operatorId,
      Value<String?> deviceId,
      Value<String> eventType,
      Value<DateTime> occurredAt,
      Value<String?> metadataJson,
      Value<bool> pushed,
      Value<int> rowid,
    });

class $$BookingActivitiesTableFilterComposer
    extends Composer<_$AppDb, $BookingActivitiesTable> {
  $$BookingActivitiesTableFilterComposer({
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

  ColumnFilters<String> get bookingId => $composableBuilder(
    column: $table.bookingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pushed => $composableBuilder(
    column: $table.pushed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingActivitiesTableOrderingComposer
    extends Composer<_$AppDb, $BookingActivitiesTable> {
  $$BookingActivitiesTableOrderingComposer({
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

  ColumnOrderings<String> get bookingId => $composableBuilder(
    column: $table.bookingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pushed => $composableBuilder(
    column: $table.pushed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingActivitiesTableAnnotationComposer
    extends Composer<_$AppDb, $BookingActivitiesTable> {
  $$BookingActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookingId =>
      $composableBuilder(column: $table.bookingId, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pushed =>
      $composableBuilder(column: $table.pushed, builder: (column) => column);
}

class $$BookingActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BookingActivitiesTable,
          BookingActivity,
          $$BookingActivitiesTableFilterComposer,
          $$BookingActivitiesTableOrderingComposer,
          $$BookingActivitiesTableAnnotationComposer,
          $$BookingActivitiesTableCreateCompanionBuilder,
          $$BookingActivitiesTableUpdateCompanionBuilder,
          (
            BookingActivity,
            BaseReferences<_$AppDb, $BookingActivitiesTable, BookingActivity>,
          ),
          BookingActivity,
          PrefetchHooks Function()
        > {
  $$BookingActivitiesTableTableManager(
    _$AppDb db,
    $BookingActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingActivitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookingId = const Value.absent(),
                Value<String> operatorId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<bool> pushed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingActivitiesCompanion(
                id: id,
                bookingId: bookingId,
                operatorId: operatorId,
                deviceId: deviceId,
                eventType: eventType,
                occurredAt: occurredAt,
                metadataJson: metadataJson,
                pushed: pushed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookingId,
                required String operatorId,
                Value<String?> deviceId = const Value.absent(),
                required String eventType,
                required DateTime occurredAt,
                Value<String?> metadataJson = const Value.absent(),
                Value<bool> pushed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingActivitiesCompanion.insert(
                id: id,
                bookingId: bookingId,
                operatorId: operatorId,
                deviceId: deviceId,
                eventType: eventType,
                occurredAt: occurredAt,
                metadataJson: metadataJson,
                pushed: pushed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BookingActivitiesTable,
      BookingActivity,
      $$BookingActivitiesTableFilterComposer,
      $$BookingActivitiesTableOrderingComposer,
      $$BookingActivitiesTableAnnotationComposer,
      $$BookingActivitiesTableCreateCompanionBuilder,
      $$BookingActivitiesTableUpdateCompanionBuilder,
      (
        BookingActivity,
        BaseReferences<_$AppDb, $BookingActivitiesTable, BookingActivity>,
      ),
      BookingActivity,
      PrefetchHooks Function()
    >;
typedef $$ScanEventsTableCreateCompanionBuilder =
    ScanEventsCompanion Function({
      required String id,
      required String operatorId,
      required String operation,
      required String eventType,
      Value<String?> candidateId,
      Value<String?> rackId,
      required DateTime occurredAt,
      Value<String?> metadataJson,
      Value<bool> pushed,
      Value<int> rowid,
    });
typedef $$ScanEventsTableUpdateCompanionBuilder =
    ScanEventsCompanion Function({
      Value<String> id,
      Value<String> operatorId,
      Value<String> operation,
      Value<String> eventType,
      Value<String?> candidateId,
      Value<String?> rackId,
      Value<DateTime> occurredAt,
      Value<String?> metadataJson,
      Value<bool> pushed,
      Value<int> rowid,
    });

class $$ScanEventsTableFilterComposer
    extends Composer<_$AppDb, $ScanEventsTable> {
  $$ScanEventsTableFilterComposer({
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

  ColumnFilters<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rackId => $composableBuilder(
    column: $table.rackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pushed => $composableBuilder(
    column: $table.pushed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanEventsTableOrderingComposer
    extends Composer<_$AppDb, $ScanEventsTable> {
  $$ScanEventsTableOrderingComposer({
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

  ColumnOrderings<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rackId => $composableBuilder(
    column: $table.rackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pushed => $composableBuilder(
    column: $table.pushed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanEventsTableAnnotationComposer
    extends Composer<_$AppDb, $ScanEventsTable> {
  $$ScanEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
    column: $table.operatorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get candidateId => $composableBuilder(
    column: $table.candidateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rackId =>
      $composableBuilder(column: $table.rackId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pushed =>
      $composableBuilder(column: $table.pushed, builder: (column) => column);
}

class $$ScanEventsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ScanEventsTable,
          ScanEvent,
          $$ScanEventsTableFilterComposer,
          $$ScanEventsTableOrderingComposer,
          $$ScanEventsTableAnnotationComposer,
          $$ScanEventsTableCreateCompanionBuilder,
          $$ScanEventsTableUpdateCompanionBuilder,
          (ScanEvent, BaseReferences<_$AppDb, $ScanEventsTable, ScanEvent>),
          ScanEvent,
          PrefetchHooks Function()
        > {
  $$ScanEventsTableTableManager(_$AppDb db, $ScanEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operatorId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> candidateId = const Value.absent(),
                Value<String?> rackId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<bool> pushed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanEventsCompanion(
                id: id,
                operatorId: operatorId,
                operation: operation,
                eventType: eventType,
                candidateId: candidateId,
                rackId: rackId,
                occurredAt: occurredAt,
                metadataJson: metadataJson,
                pushed: pushed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operatorId,
                required String operation,
                required String eventType,
                Value<String?> candidateId = const Value.absent(),
                Value<String?> rackId = const Value.absent(),
                required DateTime occurredAt,
                Value<String?> metadataJson = const Value.absent(),
                Value<bool> pushed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanEventsCompanion.insert(
                id: id,
                operatorId: operatorId,
                operation: operation,
                eventType: eventType,
                candidateId: candidateId,
                rackId: rackId,
                occurredAt: occurredAt,
                metadataJson: metadataJson,
                pushed: pushed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ScanEventsTable,
      ScanEvent,
      $$ScanEventsTableFilterComposer,
      $$ScanEventsTableOrderingComposer,
      $$ScanEventsTableAnnotationComposer,
      $$ScanEventsTableCreateCompanionBuilder,
      $$ScanEventsTableUpdateCompanionBuilder,
      (ScanEvent, BaseReferences<_$AppDb, $ScanEventsTable, ScanEvent>),
      ScanEvent,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$BookingsTableTableManager get bookings =>
      $$BookingsTableTableManager(_db, _db.bookings);
  $$FlaggedBookingsTableTableManager get flaggedBookings =>
      $$FlaggedBookingsTableTableManager(_db, _db.flaggedBookings);
  $$BookingActivitiesTableTableManager get bookingActivities =>
      $$BookingActivitiesTableTableManager(_db, _db.bookingActivities);
  $$ScanEventsTableTableManager get scanEvents =>
      $$ScanEventsTableTableManager(_db, _db.scanEvents);
}

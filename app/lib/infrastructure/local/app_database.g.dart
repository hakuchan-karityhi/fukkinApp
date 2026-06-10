// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProgressEntriesTable extends UserProgressEntries
    with TableInfo<$UserProgressEntriesTable, UserProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _totalExpMeta = const VerificationMeta(
    'totalExp',
  );
  @override
  late final GeneratedColumn<int> totalExp = GeneratedColumn<int>(
    'total_exp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _absStageMeta = const VerificationMeta(
    'absStage',
  );
  @override
  late final GeneratedColumn<int> absStage = GeneratedColumn<int>(
    'abs_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPenaltyCheckDateMeta =
      const VerificationMeta('lastPenaltyCheckDate');
  @override
  late final GeneratedColumn<String> lastPenaltyCheckDate =
      GeneratedColumn<String>(
        'last_penalty_check_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    totalExp,
    level,
    absStage,
    lastPenaltyCheckDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('total_exp')) {
      context.handle(
        _totalExpMeta,
        totalExp.isAcceptableOrUnknown(data['total_exp']!, _totalExpMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('abs_stage')) {
      context.handle(
        _absStageMeta,
        absStage.isAcceptableOrUnknown(data['abs_stage']!, _absStageMeta),
      );
    }
    if (data.containsKey('last_penalty_check_date')) {
      context.handle(
        _lastPenaltyCheckDateMeta,
        lastPenaltyCheckDate.isAcceptableOrUnknown(
          data['last_penalty_check_date']!,
          _lastPenaltyCheckDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      totalExp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_exp'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      absStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}abs_stage'],
      )!,
      lastPenaltyCheckDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_penalty_check_date'],
      ),
    );
  }

  @override
  $UserProgressEntriesTable createAlias(String alias) {
    return $UserProgressEntriesTable(attachedDatabase, alias);
  }
}

class UserProgressEntry extends DataClass
    implements Insertable<UserProgressEntry> {
  final int id;
  final int totalExp;
  final int level;
  final int absStage;
  final String? lastPenaltyCheckDate;
  const UserProgressEntry({
    required this.id,
    required this.totalExp,
    required this.level,
    required this.absStage,
    this.lastPenaltyCheckDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['total_exp'] = Variable<int>(totalExp);
    map['level'] = Variable<int>(level);
    map['abs_stage'] = Variable<int>(absStage);
    if (!nullToAbsent || lastPenaltyCheckDate != null) {
      map['last_penalty_check_date'] = Variable<String>(lastPenaltyCheckDate);
    }
    return map;
  }

  UserProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserProgressEntriesCompanion(
      id: Value(id),
      totalExp: Value(totalExp),
      level: Value(level),
      absStage: Value(absStage),
      lastPenaltyCheckDate: lastPenaltyCheckDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPenaltyCheckDate),
    );
  }

  factory UserProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressEntry(
      id: serializer.fromJson<int>(json['id']),
      totalExp: serializer.fromJson<int>(json['totalExp']),
      level: serializer.fromJson<int>(json['level']),
      absStage: serializer.fromJson<int>(json['absStage']),
      lastPenaltyCheckDate: serializer.fromJson<String?>(
        json['lastPenaltyCheckDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'totalExp': serializer.toJson<int>(totalExp),
      'level': serializer.toJson<int>(level),
      'absStage': serializer.toJson<int>(absStage),
      'lastPenaltyCheckDate': serializer.toJson<String?>(lastPenaltyCheckDate),
    };
  }

  UserProgressEntry copyWith({
    int? id,
    int? totalExp,
    int? level,
    int? absStage,
    Value<String?> lastPenaltyCheckDate = const Value.absent(),
  }) => UserProgressEntry(
    id: id ?? this.id,
    totalExp: totalExp ?? this.totalExp,
    level: level ?? this.level,
    absStage: absStage ?? this.absStage,
    lastPenaltyCheckDate: lastPenaltyCheckDate.present
        ? lastPenaltyCheckDate.value
        : this.lastPenaltyCheckDate,
  );
  UserProgressEntry copyWithCompanion(UserProgressEntriesCompanion data) {
    return UserProgressEntry(
      id: data.id.present ? data.id.value : this.id,
      totalExp: data.totalExp.present ? data.totalExp.value : this.totalExp,
      level: data.level.present ? data.level.value : this.level,
      absStage: data.absStage.present ? data.absStage.value : this.absStage,
      lastPenaltyCheckDate: data.lastPenaltyCheckDate.present
          ? data.lastPenaltyCheckDate.value
          : this.lastPenaltyCheckDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressEntry(')
          ..write('id: $id, ')
          ..write('totalExp: $totalExp, ')
          ..write('level: $level, ')
          ..write('absStage: $absStage, ')
          ..write('lastPenaltyCheckDate: $lastPenaltyCheckDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, totalExp, level, absStage, lastPenaltyCheckDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressEntry &&
          other.id == this.id &&
          other.totalExp == this.totalExp &&
          other.level == this.level &&
          other.absStage == this.absStage &&
          other.lastPenaltyCheckDate == this.lastPenaltyCheckDate);
}

class UserProgressEntriesCompanion extends UpdateCompanion<UserProgressEntry> {
  final Value<int> id;
  final Value<int> totalExp;
  final Value<int> level;
  final Value<int> absStage;
  final Value<String?> lastPenaltyCheckDate;
  const UserProgressEntriesCompanion({
    this.id = const Value.absent(),
    this.totalExp = const Value.absent(),
    this.level = const Value.absent(),
    this.absStage = const Value.absent(),
    this.lastPenaltyCheckDate = const Value.absent(),
  });
  UserProgressEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.totalExp = const Value.absent(),
    this.level = const Value.absent(),
    this.absStage = const Value.absent(),
    this.lastPenaltyCheckDate = const Value.absent(),
  });
  static Insertable<UserProgressEntry> custom({
    Expression<int>? id,
    Expression<int>? totalExp,
    Expression<int>? level,
    Expression<int>? absStage,
    Expression<String>? lastPenaltyCheckDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (totalExp != null) 'total_exp': totalExp,
      if (level != null) 'level': level,
      if (absStage != null) 'abs_stage': absStage,
      if (lastPenaltyCheckDate != null)
        'last_penalty_check_date': lastPenaltyCheckDate,
    });
  }

  UserProgressEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? totalExp,
    Value<int>? level,
    Value<int>? absStage,
    Value<String?>? lastPenaltyCheckDate,
  }) {
    return UserProgressEntriesCompanion(
      id: id ?? this.id,
      totalExp: totalExp ?? this.totalExp,
      level: level ?? this.level,
      absStage: absStage ?? this.absStage,
      lastPenaltyCheckDate: lastPenaltyCheckDate ?? this.lastPenaltyCheckDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (totalExp.present) {
      map['total_exp'] = Variable<int>(totalExp.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (absStage.present) {
      map['abs_stage'] = Variable<int>(absStage.value);
    }
    if (lastPenaltyCheckDate.present) {
      map['last_penalty_check_date'] = Variable<String>(
        lastPenaltyCheckDate.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressEntriesCompanion(')
          ..write('id: $id, ')
          ..write('totalExp: $totalExp, ')
          ..write('level: $level, ')
          ..write('absStage: $absStage, ')
          ..write('lastPenaltyCheckDate: $lastPenaltyCheckDate')
          ..write(')'))
        .toString();
  }
}

class $StreakStateEntriesTable extends StreakStateEntries
    with TableInfo<$StreakStateEntriesTable, StreakStateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakStateEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastWorkoutDateMeta = const VerificationMeta(
    'lastWorkoutDate',
  );
  @override
  late final GeneratedColumn<String> lastWorkoutDate = GeneratedColumn<String>(
    'last_workout_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _todayCompletedMeta = const VerificationMeta(
    'todayCompleted',
  );
  @override
  late final GeneratedColumn<bool> todayCompleted = GeneratedColumn<bool>(
    'today_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("today_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentStreak,
    longestStreak,
    lastWorkoutDate,
    todayCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_state_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakStateEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_workout_date')) {
      context.handle(
        _lastWorkoutDateMeta,
        lastWorkoutDate.isAcceptableOrUnknown(
          data['last_workout_date']!,
          _lastWorkoutDateMeta,
        ),
      );
    }
    if (data.containsKey('today_completed')) {
      context.handle(
        _todayCompletedMeta,
        todayCompleted.isAcceptableOrUnknown(
          data['today_completed']!,
          _todayCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreakStateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakStateEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      lastWorkoutDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_workout_date'],
      ),
      todayCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}today_completed'],
      )!,
    );
  }

  @override
  $StreakStateEntriesTable createAlias(String alias) {
    return $StreakStateEntriesTable(attachedDatabase, alias);
  }
}

class StreakStateEntry extends DataClass
    implements Insertable<StreakStateEntry> {
  final int id;
  final int currentStreak;
  final int longestStreak;
  final String? lastWorkoutDate;
  final bool todayCompleted;
  const StreakStateEntry({
    required this.id,
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    required this.todayCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastWorkoutDate != null) {
      map['last_workout_date'] = Variable<String>(lastWorkoutDate);
    }
    map['today_completed'] = Variable<bool>(todayCompleted);
    return map;
  }

  StreakStateEntriesCompanion toCompanion(bool nullToAbsent) {
    return StreakStateEntriesCompanion(
      id: Value(id),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      lastWorkoutDate: lastWorkoutDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWorkoutDate),
      todayCompleted: Value(todayCompleted),
    );
  }

  factory StreakStateEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakStateEntry(
      id: serializer.fromJson<int>(json['id']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      lastWorkoutDate: serializer.fromJson<String?>(json['lastWorkoutDate']),
      todayCompleted: serializer.fromJson<bool>(json['todayCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'lastWorkoutDate': serializer.toJson<String?>(lastWorkoutDate),
      'todayCompleted': serializer.toJson<bool>(todayCompleted),
    };
  }

  StreakStateEntry copyWith({
    int? id,
    int? currentStreak,
    int? longestStreak,
    Value<String?> lastWorkoutDate = const Value.absent(),
    bool? todayCompleted,
  }) => StreakStateEntry(
    id: id ?? this.id,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastWorkoutDate: lastWorkoutDate.present
        ? lastWorkoutDate.value
        : this.lastWorkoutDate,
    todayCompleted: todayCompleted ?? this.todayCompleted,
  );
  StreakStateEntry copyWithCompanion(StreakStateEntriesCompanion data) {
    return StreakStateEntry(
      id: data.id.present ? data.id.value : this.id,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      lastWorkoutDate: data.lastWorkoutDate.present
          ? data.lastWorkoutDate.value
          : this.lastWorkoutDate,
      todayCompleted: data.todayCompleted.present
          ? data.todayCompleted.value
          : this.todayCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakStateEntry(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastWorkoutDate: $lastWorkoutDate, ')
          ..write('todayCompleted: $todayCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentStreak,
    longestStreak,
    lastWorkoutDate,
    todayCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakStateEntry &&
          other.id == this.id &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.lastWorkoutDate == this.lastWorkoutDate &&
          other.todayCompleted == this.todayCompleted);
}

class StreakStateEntriesCompanion extends UpdateCompanion<StreakStateEntry> {
  final Value<int> id;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<String?> lastWorkoutDate;
  final Value<bool> todayCompleted;
  const StreakStateEntriesCompanion({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastWorkoutDate = const Value.absent(),
    this.todayCompleted = const Value.absent(),
  });
  StreakStateEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastWorkoutDate = const Value.absent(),
    this.todayCompleted = const Value.absent(),
  });
  static Insertable<StreakStateEntry> custom({
    Expression<int>? id,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<String>? lastWorkoutDate,
    Expression<bool>? todayCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastWorkoutDate != null) 'last_workout_date': lastWorkoutDate,
      if (todayCompleted != null) 'today_completed': todayCompleted,
    });
  }

  StreakStateEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<String?>? lastWorkoutDate,
    Value<bool>? todayCompleted,
  }) {
    return StreakStateEntriesCompanion(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      todayCompleted: todayCompleted ?? this.todayCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastWorkoutDate.present) {
      map['last_workout_date'] = Variable<String>(lastWorkoutDate.value);
    }
    if (todayCompleted.present) {
      map['today_completed'] = Variable<bool>(todayCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakStateEntriesCompanion(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastWorkoutDate: $lastWorkoutDate, ')
          ..write('todayCompleted: $todayCompleted')
          ..write(')'))
        .toString();
  }
}

class $WorkoutRecordEntriesTable extends WorkoutRecordEntries
    with TableInfo<$WorkoutRecordEntriesTable, WorkoutRecordEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutRecordEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plankTypeIdMeta = const VerificationMeta(
    'plankTypeId',
  );
  @override
  late final GeneratedColumn<String> plankTypeId = GeneratedColumn<String>(
    'plank_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetSecondsMeta = const VerificationMeta(
    'targetSeconds',
  );
  @override
  late final GeneratedColumn<int> targetSeconds = GeneratedColumn<int>(
    'target_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedExpMeta = const VerificationMeta(
    'earnedExp',
  );
  @override
  late final GeneratedColumn<int> earnedExp = GeneratedColumn<int>(
    'earned_exp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIndexOfDayMeta = const VerificationMeta(
    'sessionIndexOfDay',
  );
  @override
  late final GeneratedColumn<int> sessionIndexOfDay = GeneratedColumn<int>(
    'session_index_of_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    plankTypeId,
    targetSeconds,
    earnedExp,
    completedAt,
    sessionIndexOfDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_record_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutRecordEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('plank_type_id')) {
      context.handle(
        _plankTypeIdMeta,
        plankTypeId.isAcceptableOrUnknown(
          data['plank_type_id']!,
          _plankTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plankTypeIdMeta);
    }
    if (data.containsKey('target_seconds')) {
      context.handle(
        _targetSecondsMeta,
        targetSeconds.isAcceptableOrUnknown(
          data['target_seconds']!,
          _targetSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetSecondsMeta);
    }
    if (data.containsKey('earned_exp')) {
      context.handle(
        _earnedExpMeta,
        earnedExp.isAcceptableOrUnknown(data['earned_exp']!, _earnedExpMeta),
      );
    } else if (isInserting) {
      context.missing(_earnedExpMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('session_index_of_day')) {
      context.handle(
        _sessionIndexOfDayMeta,
        sessionIndexOfDay.isAcceptableOrUnknown(
          data['session_index_of_day']!,
          _sessionIndexOfDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionIndexOfDayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutRecordEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutRecordEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      plankTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plank_type_id'],
      )!,
      targetSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_seconds'],
      )!,
      earnedExp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earned_exp'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      sessionIndexOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_index_of_day'],
      )!,
    );
  }

  @override
  $WorkoutRecordEntriesTable createAlias(String alias) {
    return $WorkoutRecordEntriesTable(attachedDatabase, alias);
  }
}

class WorkoutRecordEntry extends DataClass
    implements Insertable<WorkoutRecordEntry> {
  final String id;
  final String date;
  final String plankTypeId;
  final int targetSeconds;
  final int earnedExp;
  final DateTime completedAt;
  final int sessionIndexOfDay;
  const WorkoutRecordEntry({
    required this.id,
    required this.date,
    required this.plankTypeId,
    required this.targetSeconds,
    required this.earnedExp,
    required this.completedAt,
    required this.sessionIndexOfDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['plank_type_id'] = Variable<String>(plankTypeId);
    map['target_seconds'] = Variable<int>(targetSeconds);
    map['earned_exp'] = Variable<int>(earnedExp);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['session_index_of_day'] = Variable<int>(sessionIndexOfDay);
    return map;
  }

  WorkoutRecordEntriesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutRecordEntriesCompanion(
      id: Value(id),
      date: Value(date),
      plankTypeId: Value(plankTypeId),
      targetSeconds: Value(targetSeconds),
      earnedExp: Value(earnedExp),
      completedAt: Value(completedAt),
      sessionIndexOfDay: Value(sessionIndexOfDay),
    );
  }

  factory WorkoutRecordEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutRecordEntry(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      plankTypeId: serializer.fromJson<String>(json['plankTypeId']),
      targetSeconds: serializer.fromJson<int>(json['targetSeconds']),
      earnedExp: serializer.fromJson<int>(json['earnedExp']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      sessionIndexOfDay: serializer.fromJson<int>(json['sessionIndexOfDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'plankTypeId': serializer.toJson<String>(plankTypeId),
      'targetSeconds': serializer.toJson<int>(targetSeconds),
      'earnedExp': serializer.toJson<int>(earnedExp),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'sessionIndexOfDay': serializer.toJson<int>(sessionIndexOfDay),
    };
  }

  WorkoutRecordEntry copyWith({
    String? id,
    String? date,
    String? plankTypeId,
    int? targetSeconds,
    int? earnedExp,
    DateTime? completedAt,
    int? sessionIndexOfDay,
  }) => WorkoutRecordEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    plankTypeId: plankTypeId ?? this.plankTypeId,
    targetSeconds: targetSeconds ?? this.targetSeconds,
    earnedExp: earnedExp ?? this.earnedExp,
    completedAt: completedAt ?? this.completedAt,
    sessionIndexOfDay: sessionIndexOfDay ?? this.sessionIndexOfDay,
  );
  WorkoutRecordEntry copyWithCompanion(WorkoutRecordEntriesCompanion data) {
    return WorkoutRecordEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      plankTypeId: data.plankTypeId.present
          ? data.plankTypeId.value
          : this.plankTypeId,
      targetSeconds: data.targetSeconds.present
          ? data.targetSeconds.value
          : this.targetSeconds,
      earnedExp: data.earnedExp.present ? data.earnedExp.value : this.earnedExp,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      sessionIndexOfDay: data.sessionIndexOfDay.present
          ? data.sessionIndexOfDay.value
          : this.sessionIndexOfDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRecordEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('plankTypeId: $plankTypeId, ')
          ..write('targetSeconds: $targetSeconds, ')
          ..write('earnedExp: $earnedExp, ')
          ..write('completedAt: $completedAt, ')
          ..write('sessionIndexOfDay: $sessionIndexOfDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    plankTypeId,
    targetSeconds,
    earnedExp,
    completedAt,
    sessionIndexOfDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutRecordEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.plankTypeId == this.plankTypeId &&
          other.targetSeconds == this.targetSeconds &&
          other.earnedExp == this.earnedExp &&
          other.completedAt == this.completedAt &&
          other.sessionIndexOfDay == this.sessionIndexOfDay);
}

class WorkoutRecordEntriesCompanion
    extends UpdateCompanion<WorkoutRecordEntry> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> plankTypeId;
  final Value<int> targetSeconds;
  final Value<int> earnedExp;
  final Value<DateTime> completedAt;
  final Value<int> sessionIndexOfDay;
  final Value<int> rowid;
  const WorkoutRecordEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.plankTypeId = const Value.absent(),
    this.targetSeconds = const Value.absent(),
    this.earnedExp = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sessionIndexOfDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutRecordEntriesCompanion.insert({
    required String id,
    required String date,
    required String plankTypeId,
    required int targetSeconds,
    required int earnedExp,
    required DateTime completedAt,
    required int sessionIndexOfDay,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       plankTypeId = Value(plankTypeId),
       targetSeconds = Value(targetSeconds),
       earnedExp = Value(earnedExp),
       completedAt = Value(completedAt),
       sessionIndexOfDay = Value(sessionIndexOfDay);
  static Insertable<WorkoutRecordEntry> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? plankTypeId,
    Expression<int>? targetSeconds,
    Expression<int>? earnedExp,
    Expression<DateTime>? completedAt,
    Expression<int>? sessionIndexOfDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (plankTypeId != null) 'plank_type_id': plankTypeId,
      if (targetSeconds != null) 'target_seconds': targetSeconds,
      if (earnedExp != null) 'earned_exp': earnedExp,
      if (completedAt != null) 'completed_at': completedAt,
      if (sessionIndexOfDay != null) 'session_index_of_day': sessionIndexOfDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutRecordEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? date,
    Value<String>? plankTypeId,
    Value<int>? targetSeconds,
    Value<int>? earnedExp,
    Value<DateTime>? completedAt,
    Value<int>? sessionIndexOfDay,
    Value<int>? rowid,
  }) {
    return WorkoutRecordEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      plankTypeId: plankTypeId ?? this.plankTypeId,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      earnedExp: earnedExp ?? this.earnedExp,
      completedAt: completedAt ?? this.completedAt,
      sessionIndexOfDay: sessionIndexOfDay ?? this.sessionIndexOfDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (plankTypeId.present) {
      map['plank_type_id'] = Variable<String>(plankTypeId.value);
    }
    if (targetSeconds.present) {
      map['target_seconds'] = Variable<int>(targetSeconds.value);
    }
    if (earnedExp.present) {
      map['earned_exp'] = Variable<int>(earnedExp.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (sessionIndexOfDay.present) {
      map['session_index_of_day'] = Variable<int>(sessionIndexOfDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRecordEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('plankTypeId: $plankTypeId, ')
          ..write('targetSeconds: $targetSeconds, ')
          ..write('earnedExp: $earnedExp, ')
          ..write('completedAt: $completedAt, ')
          ..write('sessionIndexOfDay: $sessionIndexOfDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProgressEntriesTable userProgressEntries =
      $UserProgressEntriesTable(this);
  late final $StreakStateEntriesTable streakStateEntries =
      $StreakStateEntriesTable(this);
  late final $WorkoutRecordEntriesTable workoutRecordEntries =
      $WorkoutRecordEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProgressEntries,
    streakStateEntries,
    workoutRecordEntries,
  ];
}

typedef $$UserProgressEntriesTableCreateCompanionBuilder =
    UserProgressEntriesCompanion Function({
      Value<int> id,
      Value<int> totalExp,
      Value<int> level,
      Value<int> absStage,
      Value<String?> lastPenaltyCheckDate,
    });
typedef $$UserProgressEntriesTableUpdateCompanionBuilder =
    UserProgressEntriesCompanion Function({
      Value<int> id,
      Value<int> totalExp,
      Value<int> level,
      Value<int> absStage,
      Value<String?> lastPenaltyCheckDate,
    });

class $$UserProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressEntriesTable> {
  $$UserProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalExp => $composableBuilder(
    column: $table.totalExp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get absStage => $composableBuilder(
    column: $table.absStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPenaltyCheckDate => $composableBuilder(
    column: $table.lastPenaltyCheckDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressEntriesTable> {
  $$UserProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalExp => $composableBuilder(
    column: $table.totalExp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get absStage => $composableBuilder(
    column: $table.absStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPenaltyCheckDate => $composableBuilder(
    column: $table.lastPenaltyCheckDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressEntriesTable> {
  $$UserProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalExp =>
      $composableBuilder(column: $table.totalExp, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get absStage =>
      $composableBuilder(column: $table.absStage, builder: (column) => column);

  GeneratedColumn<String> get lastPenaltyCheckDate => $composableBuilder(
    column: $table.lastPenaltyCheckDate,
    builder: (column) => column,
  );
}

class $$UserProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressEntriesTable,
          UserProgressEntry,
          $$UserProgressEntriesTableFilterComposer,
          $$UserProgressEntriesTableOrderingComposer,
          $$UserProgressEntriesTableAnnotationComposer,
          $$UserProgressEntriesTableCreateCompanionBuilder,
          $$UserProgressEntriesTableUpdateCompanionBuilder,
          (
            UserProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $UserProgressEntriesTable,
              UserProgressEntry
            >,
          ),
          UserProgressEntry,
          PrefetchHooks Function()
        > {
  $$UserProgressEntriesTableTableManager(
    _$AppDatabase db,
    $UserProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalExp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> absStage = const Value.absent(),
                Value<String?> lastPenaltyCheckDate = const Value.absent(),
              }) => UserProgressEntriesCompanion(
                id: id,
                totalExp: totalExp,
                level: level,
                absStage: absStage,
                lastPenaltyCheckDate: lastPenaltyCheckDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalExp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> absStage = const Value.absent(),
                Value<String?> lastPenaltyCheckDate = const Value.absent(),
              }) => UserProgressEntriesCompanion.insert(
                id: id,
                totalExp: totalExp,
                level: level,
                absStage: absStage,
                lastPenaltyCheckDate: lastPenaltyCheckDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressEntriesTable,
      UserProgressEntry,
      $$UserProgressEntriesTableFilterComposer,
      $$UserProgressEntriesTableOrderingComposer,
      $$UserProgressEntriesTableAnnotationComposer,
      $$UserProgressEntriesTableCreateCompanionBuilder,
      $$UserProgressEntriesTableUpdateCompanionBuilder,
      (
        UserProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $UserProgressEntriesTable,
          UserProgressEntry
        >,
      ),
      UserProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$StreakStateEntriesTableCreateCompanionBuilder =
    StreakStateEntriesCompanion Function({
      Value<int> id,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<String?> lastWorkoutDate,
      Value<bool> todayCompleted,
    });
typedef $$StreakStateEntriesTableUpdateCompanionBuilder =
    StreakStateEntriesCompanion Function({
      Value<int> id,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<String?> lastWorkoutDate,
      Value<bool> todayCompleted,
    });

class $$StreakStateEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $StreakStateEntriesTable> {
  $$StreakStateEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastWorkoutDate => $composableBuilder(
    column: $table.lastWorkoutDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get todayCompleted => $composableBuilder(
    column: $table.todayCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakStateEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakStateEntriesTable> {
  $$StreakStateEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastWorkoutDate => $composableBuilder(
    column: $table.lastWorkoutDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get todayCompleted => $composableBuilder(
    column: $table.todayCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakStateEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakStateEntriesTable> {
  $$StreakStateEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastWorkoutDate => $composableBuilder(
    column: $table.lastWorkoutDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get todayCompleted => $composableBuilder(
    column: $table.todayCompleted,
    builder: (column) => column,
  );
}

class $$StreakStateEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakStateEntriesTable,
          StreakStateEntry,
          $$StreakStateEntriesTableFilterComposer,
          $$StreakStateEntriesTableOrderingComposer,
          $$StreakStateEntriesTableAnnotationComposer,
          $$StreakStateEntriesTableCreateCompanionBuilder,
          $$StreakStateEntriesTableUpdateCompanionBuilder,
          (
            StreakStateEntry,
            BaseReferences<
              _$AppDatabase,
              $StreakStateEntriesTable,
              StreakStateEntry
            >,
          ),
          StreakStateEntry,
          PrefetchHooks Function()
        > {
  $$StreakStateEntriesTableTableManager(
    _$AppDatabase db,
    $StreakStateEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakStateEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakStateEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakStateEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<String?> lastWorkoutDate = const Value.absent(),
                Value<bool> todayCompleted = const Value.absent(),
              }) => StreakStateEntriesCompanion(
                id: id,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastWorkoutDate: lastWorkoutDate,
                todayCompleted: todayCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<String?> lastWorkoutDate = const Value.absent(),
                Value<bool> todayCompleted = const Value.absent(),
              }) => StreakStateEntriesCompanion.insert(
                id: id,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastWorkoutDate: lastWorkoutDate,
                todayCompleted: todayCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakStateEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakStateEntriesTable,
      StreakStateEntry,
      $$StreakStateEntriesTableFilterComposer,
      $$StreakStateEntriesTableOrderingComposer,
      $$StreakStateEntriesTableAnnotationComposer,
      $$StreakStateEntriesTableCreateCompanionBuilder,
      $$StreakStateEntriesTableUpdateCompanionBuilder,
      (
        StreakStateEntry,
        BaseReferences<
          _$AppDatabase,
          $StreakStateEntriesTable,
          StreakStateEntry
        >,
      ),
      StreakStateEntry,
      PrefetchHooks Function()
    >;
typedef $$WorkoutRecordEntriesTableCreateCompanionBuilder =
    WorkoutRecordEntriesCompanion Function({
      required String id,
      required String date,
      required String plankTypeId,
      required int targetSeconds,
      required int earnedExp,
      required DateTime completedAt,
      required int sessionIndexOfDay,
      Value<int> rowid,
    });
typedef $$WorkoutRecordEntriesTableUpdateCompanionBuilder =
    WorkoutRecordEntriesCompanion Function({
      Value<String> id,
      Value<String> date,
      Value<String> plankTypeId,
      Value<int> targetSeconds,
      Value<int> earnedExp,
      Value<DateTime> completedAt,
      Value<int> sessionIndexOfDay,
      Value<int> rowid,
    });

class $$WorkoutRecordEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutRecordEntriesTable> {
  $$WorkoutRecordEntriesTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plankTypeId => $composableBuilder(
    column: $table.plankTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSeconds => $composableBuilder(
    column: $table.targetSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earnedExp => $composableBuilder(
    column: $table.earnedExp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionIndexOfDay => $composableBuilder(
    column: $table.sessionIndexOfDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutRecordEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutRecordEntriesTable> {
  $$WorkoutRecordEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plankTypeId => $composableBuilder(
    column: $table.plankTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSeconds => $composableBuilder(
    column: $table.targetSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earnedExp => $composableBuilder(
    column: $table.earnedExp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionIndexOfDay => $composableBuilder(
    column: $table.sessionIndexOfDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutRecordEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutRecordEntriesTable> {
  $$WorkoutRecordEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get plankTypeId => $composableBuilder(
    column: $table.plankTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetSeconds => $composableBuilder(
    column: $table.targetSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get earnedExp =>
      $composableBuilder(column: $table.earnedExp, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionIndexOfDay => $composableBuilder(
    column: $table.sessionIndexOfDay,
    builder: (column) => column,
  );
}

class $$WorkoutRecordEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutRecordEntriesTable,
          WorkoutRecordEntry,
          $$WorkoutRecordEntriesTableFilterComposer,
          $$WorkoutRecordEntriesTableOrderingComposer,
          $$WorkoutRecordEntriesTableAnnotationComposer,
          $$WorkoutRecordEntriesTableCreateCompanionBuilder,
          $$WorkoutRecordEntriesTableUpdateCompanionBuilder,
          (
            WorkoutRecordEntry,
            BaseReferences<
              _$AppDatabase,
              $WorkoutRecordEntriesTable,
              WorkoutRecordEntry
            >,
          ),
          WorkoutRecordEntry,
          PrefetchHooks Function()
        > {
  $$WorkoutRecordEntriesTableTableManager(
    _$AppDatabase db,
    $WorkoutRecordEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutRecordEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutRecordEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkoutRecordEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> plankTypeId = const Value.absent(),
                Value<int> targetSeconds = const Value.absent(),
                Value<int> earnedExp = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> sessionIndexOfDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutRecordEntriesCompanion(
                id: id,
                date: date,
                plankTypeId: plankTypeId,
                targetSeconds: targetSeconds,
                earnedExp: earnedExp,
                completedAt: completedAt,
                sessionIndexOfDay: sessionIndexOfDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String date,
                required String plankTypeId,
                required int targetSeconds,
                required int earnedExp,
                required DateTime completedAt,
                required int sessionIndexOfDay,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutRecordEntriesCompanion.insert(
                id: id,
                date: date,
                plankTypeId: plankTypeId,
                targetSeconds: targetSeconds,
                earnedExp: earnedExp,
                completedAt: completedAt,
                sessionIndexOfDay: sessionIndexOfDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutRecordEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutRecordEntriesTable,
      WorkoutRecordEntry,
      $$WorkoutRecordEntriesTableFilterComposer,
      $$WorkoutRecordEntriesTableOrderingComposer,
      $$WorkoutRecordEntriesTableAnnotationComposer,
      $$WorkoutRecordEntriesTableCreateCompanionBuilder,
      $$WorkoutRecordEntriesTableUpdateCompanionBuilder,
      (
        WorkoutRecordEntry,
        BaseReferences<
          _$AppDatabase,
          $WorkoutRecordEntriesTable,
          WorkoutRecordEntry
        >,
      ),
      WorkoutRecordEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProgressEntriesTableTableManager get userProgressEntries =>
      $$UserProgressEntriesTableTableManager(_db, _db.userProgressEntries);
  $$StreakStateEntriesTableTableManager get streakStateEntries =>
      $$StreakStateEntriesTableTableManager(_db, _db.streakStateEntries);
  $$WorkoutRecordEntriesTableTableManager get workoutRecordEntries =>
      $$WorkoutRecordEntriesTableTableManager(_db, _db.workoutRecordEntries);
}

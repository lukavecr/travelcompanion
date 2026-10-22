// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetMeta = const VerificationMeta('budget');
  @override
  late final GeneratedColumn<double> budget = GeneratedColumn<double>(
    'budget',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mainCurrencyMeta = const VerificationMeta(
    'mainCurrency',
  );
  @override
  late final GeneratedColumn<String> mainCurrency = GeneratedColumn<String>(
    'main_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CZK'),
  );
  static const VerificationMeta _countriesMeta = const VerificationMeta(
    'countries',
  );
  @override
  late final GeneratedColumn<String> countries = GeneratedColumn<String>(
    'countries',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    name,
    startDate,
    endDate,
    notes,
    budget,
    mainCurrency,
    countries,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('budget')) {
      context.handle(
        _budgetMeta,
        budget.isAcceptableOrUnknown(data['budget']!, _budgetMeta),
      );
    }
    if (data.containsKey('main_currency')) {
      context.handle(
        _mainCurrencyMeta,
        mainCurrency.isAcceptableOrUnknown(
          data['main_currency']!,
          _mainCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('countries')) {
      context.handle(
        _countriesMeta,
        countries.isAcceptableOrUnknown(data['countries']!, _countriesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      budget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}budget'],
      ),
      mainCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}main_currency'],
      )!,
      countries: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}countries'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final double? budget;
  final String mainCurrency;
  final String countries;
  const Trip({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.name,
    this.startDate,
    this.endDate,
    this.notes,
    this.budget,
    required this.mainCurrency,
    required this.countries,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || budget != null) {
      map['budget'] = Variable<double>(budget);
    }
    map['main_currency'] = Variable<String>(mainCurrency);
    map['countries'] = Variable<String>(countries);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      name: Value(name),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      budget: budget == null && nullToAbsent
          ? const Value.absent()
          : Value(budget),
      mainCurrency: Value(mainCurrency),
      countries: Value(countries),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      budget: serializer.fromJson<double?>(json['budget']),
      mainCurrency: serializer.fromJson<String>(json['mainCurrency']),
      countries: serializer.fromJson<String>(json['countries']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'notes': serializer.toJson<String?>(notes),
      'budget': serializer.toJson<double?>(budget),
      'mainCurrency': serializer.toJson<String>(mainCurrency),
      'countries': serializer.toJson<String>(countries),
    };
  }

  Trip copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
    String? name,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<double?> budget = const Value.absent(),
    String? mainCurrency,
    String? countries,
  }) => Trip(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    name: name ?? this.name,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    notes: notes.present ? notes.value : this.notes,
    budget: budget.present ? budget.value : this.budget,
    mainCurrency: mainCurrency ?? this.mainCurrency,
    countries: countries ?? this.countries,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      budget: data.budget.present ? data.budget.value : this.budget,
      mainCurrency: data.mainCurrency.present
          ? data.mainCurrency.value
          : this.mainCurrency,
      countries: data.countries.present ? data.countries.value : this.countries,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('budget: $budget, ')
          ..write('mainCurrency: $mainCurrency, ')
          ..write('countries: $countries')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    name,
    startDate,
    endDate,
    notes,
    budget,
    mainCurrency,
    countries,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.notes == this.notes &&
          other.budget == this.budget &&
          other.mainCurrency == this.mainCurrency &&
          other.countries == this.countries);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<String> name;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> notes;
  final Value<double?> budget;
  final Value<String> mainCurrency;
  final Value<String> countries;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.budget = const Value.absent(),
    this.mainCurrency = const Value.absent(),
    this.countries = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String name,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.budget = const Value.absent(),
    this.mainCurrency = const Value.absent(),
    this.countries = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? notes,
    Expression<double>? budget,
    Expression<String>? mainCurrency,
    Expression<String>? countries,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notes != null) 'notes': notes,
      if (budget != null) 'budget': budget,
      if (mainCurrency != null) 'main_currency': mainCurrency,
      if (countries != null) 'countries': countries,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<String>? name,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? notes,
    Value<double?>? budget,
    Value<String>? mainCurrency,
    Value<String>? countries,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      budget: budget ?? this.budget,
      mainCurrency: mainCurrency ?? this.mainCurrency,
      countries: countries ?? this.countries,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (budget.present) {
      map['budget'] = Variable<double>(budget.value);
    }
    if (mainCurrency.present) {
      map['main_currency'] = Variable<String>(mainCurrency.value);
    }
    if (countries.present) {
      map['countries'] = Variable<String>(countries.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('budget: $budget, ')
          ..write('mainCurrency: $mainCurrency, ')
          ..write('countries: $countries, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlacesTable extends Places with TableInfo<$PlacesTable, Place> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _mapUrlMeta = const VerificationMeta('mapUrl');
  @override
  late final GeneratedColumn<String> mapUrl = GeneratedColumn<String>(
    'map_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    tripId,
    name,
    lat,
    lng,
    type,
    mapUrl,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places';
  @override
  VerificationContext validateIntegrity(
    Insertable<Place> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('map_url')) {
      context.handle(
        _mapUrlMeta,
        mapUrl.isAcceptableOrUnknown(data['map_url']!, _mapUrlMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Place map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Place(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      mapUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}map_url'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PlacesTable createAlias(String alias) {
    return $PlacesTable(attachedDatabase, alias);
  }
}

class Place extends DataClass implements Insertable<Place> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final String tripId;
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String? mapUrl;
  final String? note;
  const Place({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.tripId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    this.mapUrl,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || mapUrl != null) {
      map['map_url'] = Variable<String>(mapUrl);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PlacesCompanion toCompanion(bool nullToAbsent) {
    return PlacesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      tripId: Value(tripId),
      name: Value(name),
      lat: Value(lat),
      lng: Value(lng),
      type: Value(type),
      mapUrl: mapUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mapUrl),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Place.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Place(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      type: serializer.fromJson<String>(json['type']),
      mapUrl: serializer.fromJson<String?>(json['mapUrl']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'type': serializer.toJson<String>(type),
      'mapUrl': serializer.toJson<String?>(mapUrl),
      'note': serializer.toJson<String?>(note),
    };
  }

  Place copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
    String? tripId,
    String? name,
    double? lat,
    double? lng,
    String? type,
    Value<String?> mapUrl = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Place(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    type: type ?? this.type,
    mapUrl: mapUrl.present ? mapUrl.value : this.mapUrl,
    note: note.present ? note.value : this.note,
  );
  Place copyWithCompanion(PlacesCompanion data) {
    return Place(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      type: data.type.present ? data.type.value : this.type,
      mapUrl: data.mapUrl.present ? data.mapUrl.value : this.mapUrl,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Place(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('type: $type, ')
          ..write('mapUrl: $mapUrl, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    tripId,
    name,
    lat,
    lng,
    type,
    mapUrl,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Place &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.type == this.type &&
          other.mapUrl == this.mapUrl &&
          other.note == this.note);
}

class PlacesCompanion extends UpdateCompanion<Place> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<String> tripId;
  final Value<String> name;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> type;
  final Value<String?> mapUrl;
  final Value<String?> note;
  final Value<int> rowid;
  const PlacesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.type = const Value.absent(),
    this.mapUrl = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlacesCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String tripId,
    required String name,
    required double lat,
    required double lng,
    this.type = const Value.absent(),
    this.mapUrl = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name),
       lat = Value(lat),
       lng = Value(lng);
  static Insertable<Place> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? type,
    Expression<String>? mapUrl,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (type != null) 'type': type,
      if (mapUrl != null) 'map_url': mapUrl,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlacesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<String>? tripId,
    Value<String>? name,
    Value<double>? lat,
    Value<double>? lng,
    Value<String>? type,
    Value<String?>? mapUrl,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PlacesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      type: type ?? this.type,
      mapUrl: mapUrl ?? this.mapUrl,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (mapUrl.present) {
      map['map_url'] = Variable<String>(mapUrl.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('type: $type, ')
          ..write('mapUrl: $mapUrl, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrStatusMeta = const VerificationMeta(
    'ocrStatus',
  );
  @override
  late final GeneratedColumn<String> ocrStatus = GeneratedColumn<String>(
    'ocr_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _extractedJsonMeta = const VerificationMeta(
    'extractedJson',
  );
  @override
  late final GeneratedColumn<String> extractedJson = GeneratedColumn<String>(
    'extracted_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    tripId,
    type,
    localPath,
    remoteUrl,
    ocrStatus,
    extractedJson,
    rawText,
    title,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Document> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('ocr_status')) {
      context.handle(
        _ocrStatusMeta,
        ocrStatus.isAcceptableOrUnknown(data['ocr_status']!, _ocrStatusMeta),
      );
    }
    if (data.containsKey('extracted_json')) {
      context.handle(
        _extractedJsonMeta,
        extractedJson.isAcceptableOrUnknown(
          data['extracted_json']!,
          _extractedJsonMeta,
        ),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      ocrStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_status'],
      )!,
      extractedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_json'],
      ),
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final String tripId;
  final String type;
  final String localPath;
  final String? remoteUrl;
  final String ocrStatus;
  final String? extractedJson;
  final String? rawText;
  final String? title;
  const Document({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.tripId,
    required this.type,
    required this.localPath,
    this.remoteUrl,
    required this.ocrStatus,
    this.extractedJson,
    this.rawText,
    this.title,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['trip_id'] = Variable<String>(tripId);
    map['type'] = Variable<String>(type);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    map['ocr_status'] = Variable<String>(ocrStatus);
    if (!nullToAbsent || extractedJson != null) {
      map['extracted_json'] = Variable<String>(extractedJson);
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      tripId: Value(tripId),
      type: Value(type),
      localPath: Value(localPath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      ocrStatus: Value(ocrStatus),
      extractedJson: extractedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedJson),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
    );
  }

  factory Document.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      tripId: serializer.fromJson<String>(json['tripId']),
      type: serializer.fromJson<String>(json['type']),
      localPath: serializer.fromJson<String>(json['localPath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      ocrStatus: serializer.fromJson<String>(json['ocrStatus']),
      extractedJson: serializer.fromJson<String?>(json['extractedJson']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      title: serializer.fromJson<String?>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'tripId': serializer.toJson<String>(tripId),
      'type': serializer.toJson<String>(type),
      'localPath': serializer.toJson<String>(localPath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'ocrStatus': serializer.toJson<String>(ocrStatus),
      'extractedJson': serializer.toJson<String?>(extractedJson),
      'rawText': serializer.toJson<String?>(rawText),
      'title': serializer.toJson<String?>(title),
    };
  }

  Document copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
    String? tripId,
    String? type,
    String? localPath,
    Value<String?> remoteUrl = const Value.absent(),
    String? ocrStatus,
    Value<String?> extractedJson = const Value.absent(),
    Value<String?> rawText = const Value.absent(),
    Value<String?> title = const Value.absent(),
  }) => Document(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    tripId: tripId ?? this.tripId,
    type: type ?? this.type,
    localPath: localPath ?? this.localPath,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    ocrStatus: ocrStatus ?? this.ocrStatus,
    extractedJson: extractedJson.present
        ? extractedJson.value
        : this.extractedJson,
    rawText: rawText.present ? rawText.value : this.rawText,
    title: title.present ? title.value : this.title,
  );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      type: data.type.present ? data.type.value : this.type,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      ocrStatus: data.ocrStatus.present ? data.ocrStatus.value : this.ocrStatus,
      extractedJson: data.extractedJson.present
          ? data.extractedJson.value
          : this.extractedJson,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('tripId: $tripId, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('extractedJson: $extractedJson, ')
          ..write('rawText: $rawText, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    tripId,
    type,
    localPath,
    remoteUrl,
    ocrStatus,
    extractedJson,
    rawText,
    title,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.tripId == this.tripId &&
          other.type == this.type &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.ocrStatus == this.ocrStatus &&
          other.extractedJson == this.extractedJson &&
          other.rawText == this.rawText &&
          other.title == this.title);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<String> tripId;
  final Value<String> type;
  final Value<String> localPath;
  final Value<String?> remoteUrl;
  final Value<String> ocrStatus;
  final Value<String?> extractedJson;
  final Value<String?> rawText;
  final Value<String?> title;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.tripId = const Value.absent(),
    this.type = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    this.extractedJson = const Value.absent(),
    this.rawText = const Value.absent(),
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String tripId,
    required String type,
    required String localPath,
    this.remoteUrl = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    this.extractedJson = const Value.absent(),
    this.rawText = const Value.absent(),
    this.title = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       type = Value(type),
       localPath = Value(localPath);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? tripId,
    Expression<String>? type,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<String>? ocrStatus,
    Expression<String>? extractedJson,
    Expression<String>? rawText,
    Expression<String>? title,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (tripId != null) 'trip_id': tripId,
      if (type != null) 'type': type,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (ocrStatus != null) 'ocr_status': ocrStatus,
      if (extractedJson != null) 'extracted_json': extractedJson,
      if (rawText != null) 'raw_text': rawText,
      if (title != null) 'title': title,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<String>? tripId,
    Value<String>? type,
    Value<String>? localPath,
    Value<String?>? remoteUrl,
    Value<String>? ocrStatus,
    Value<String?>? extractedJson,
    Value<String?>? rawText,
    Value<String?>? title,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      tripId: tripId ?? this.tripId,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      ocrStatus: ocrStatus ?? this.ocrStatus,
      extractedJson: extractedJson ?? this.extractedJson,
      rawText: rawText ?? this.rawText,
      title: title ?? this.title,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (ocrStatus.present) {
      map['ocr_status'] = Variable<String>(ocrStatus.value);
    }
    if (extractedJson.present) {
      map['extracted_json'] = Variable<String>(extractedJson.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('tripId: $tripId, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('extractedJson: $extractedJson, ')
          ..write('rawText: $rawText, ')
          ..write('title: $title, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMainMeta = const VerificationMeta(
    'amountMain',
  );
  @override
  late final GeneratedColumn<double> amountMain = GeneratedColumn<double>(
    'amount_main',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fxRateMeta = const VerificationMeta('fxRate');
  @override
  late final GeneratedColumn<double> fxRate = GeneratedColumn<double>(
    'fx_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _spentAtMeta = const VerificationMeta(
    'spentAt',
  );
  @override
  late final GeneratedColumn<DateTime> spentAt = GeneratedColumn<DateTime>(
    'spent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptDocumentIdMeta = const VerificationMeta(
    'receiptDocumentId',
  );
  @override
  late final GeneratedColumn<String> receiptDocumentId =
      GeneratedColumn<String>(
        'receipt_document_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES documents (id)',
        ),
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    tripId,
    amount,
    currency,
    amountMain,
    fxRate,
    category,
    spentAt,
    country,
    receiptDocumentId,
    source,
    note,
    receiptPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('amount_main')) {
      context.handle(
        _amountMainMeta,
        amountMain.isAcceptableOrUnknown(data['amount_main']!, _amountMainMeta),
      );
    }
    if (data.containsKey('fx_rate')) {
      context.handle(
        _fxRateMeta,
        fxRate.isAcceptableOrUnknown(data['fx_rate']!, _fxRateMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('spent_at')) {
      context.handle(
        _spentAtMeta,
        spentAt.isAcceptableOrUnknown(data['spent_at']!, _spentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_spentAtMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('receipt_document_id')) {
      context.handle(
        _receiptDocumentIdMeta,
        receiptDocumentId.isAcceptableOrUnknown(
          data['receipt_document_id']!,
          _receiptDocumentIdMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      amountMain: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_main'],
      ),
      fxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fx_rate'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      spentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}spent_at'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      receiptDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_document_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final String tripId;
  final double amount;
  final String currency;
  final double? amountMain;
  final double? fxRate;
  final String category;
  final DateTime spentAt;
  final String? country;
  final String? receiptDocumentId;
  final String source;
  final String? note;
  final String? receiptPath;
  const Expense({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.tripId,
    required this.amount,
    required this.currency,
    this.amountMain,
    this.fxRate,
    required this.category,
    required this.spentAt,
    this.country,
    this.receiptDocumentId,
    required this.source,
    this.note,
    this.receiptPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['trip_id'] = Variable<String>(tripId);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || amountMain != null) {
      map['amount_main'] = Variable<double>(amountMain);
    }
    if (!nullToAbsent || fxRate != null) {
      map['fx_rate'] = Variable<double>(fxRate);
    }
    map['category'] = Variable<String>(category);
    map['spent_at'] = Variable<DateTime>(spentAt);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || receiptDocumentId != null) {
      map['receipt_document_id'] = Variable<String>(receiptDocumentId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      tripId: Value(tripId),
      amount: Value(amount),
      currency: Value(currency),
      amountMain: amountMain == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMain),
      fxRate: fxRate == null && nullToAbsent
          ? const Value.absent()
          : Value(fxRate),
      category: Value(category),
      spentAt: Value(spentAt),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      receiptDocumentId: receiptDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptDocumentId),
      source: Value(source),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      tripId: serializer.fromJson<String>(json['tripId']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      amountMain: serializer.fromJson<double?>(json['amountMain']),
      fxRate: serializer.fromJson<double?>(json['fxRate']),
      category: serializer.fromJson<String>(json['category']),
      spentAt: serializer.fromJson<DateTime>(json['spentAt']),
      country: serializer.fromJson<String?>(json['country']),
      receiptDocumentId: serializer.fromJson<String?>(
        json['receiptDocumentId'],
      ),
      source: serializer.fromJson<String>(json['source']),
      note: serializer.fromJson<String?>(json['note']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'tripId': serializer.toJson<String>(tripId),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'amountMain': serializer.toJson<double?>(amountMain),
      'fxRate': serializer.toJson<double?>(fxRate),
      'category': serializer.toJson<String>(category),
      'spentAt': serializer.toJson<DateTime>(spentAt),
      'country': serializer.toJson<String?>(country),
      'receiptDocumentId': serializer.toJson<String?>(receiptDocumentId),
      'source': serializer.toJson<String>(source),
      'note': serializer.toJson<String?>(note),
      'receiptPath': serializer.toJson<String?>(receiptPath),
    };
  }

  Expense copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
    String? tripId,
    double? amount,
    String? currency,
    Value<double?> amountMain = const Value.absent(),
    Value<double?> fxRate = const Value.absent(),
    String? category,
    DateTime? spentAt,
    Value<String?> country = const Value.absent(),
    Value<String?> receiptDocumentId = const Value.absent(),
    String? source,
    Value<String?> note = const Value.absent(),
    Value<String?> receiptPath = const Value.absent(),
  }) => Expense(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    tripId: tripId ?? this.tripId,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    amountMain: amountMain.present ? amountMain.value : this.amountMain,
    fxRate: fxRate.present ? fxRate.value : this.fxRate,
    category: category ?? this.category,
    spentAt: spentAt ?? this.spentAt,
    country: country.present ? country.value : this.country,
    receiptDocumentId: receiptDocumentId.present
        ? receiptDocumentId.value
        : this.receiptDocumentId,
    source: source ?? this.source,
    note: note.present ? note.value : this.note,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      amountMain: data.amountMain.present
          ? data.amountMain.value
          : this.amountMain,
      fxRate: data.fxRate.present ? data.fxRate.value : this.fxRate,
      category: data.category.present ? data.category.value : this.category,
      spentAt: data.spentAt.present ? data.spentAt.value : this.spentAt,
      country: data.country.present ? data.country.value : this.country,
      receiptDocumentId: data.receiptDocumentId.present
          ? data.receiptDocumentId.value
          : this.receiptDocumentId,
      source: data.source.present ? data.source.value : this.source,
      note: data.note.present ? data.note.value : this.note,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('tripId: $tripId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('amountMain: $amountMain, ')
          ..write('fxRate: $fxRate, ')
          ..write('category: $category, ')
          ..write('spentAt: $spentAt, ')
          ..write('country: $country, ')
          ..write('receiptDocumentId: $receiptDocumentId, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('receiptPath: $receiptPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    tripId,
    amount,
    currency,
    amountMain,
    fxRate,
    category,
    spentAt,
    country,
    receiptDocumentId,
    source,
    note,
    receiptPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.tripId == this.tripId &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.amountMain == this.amountMain &&
          other.fxRate == this.fxRate &&
          other.category == this.category &&
          other.spentAt == this.spentAt &&
          other.country == this.country &&
          other.receiptDocumentId == this.receiptDocumentId &&
          other.source == this.source &&
          other.note == this.note &&
          other.receiptPath == this.receiptPath);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<String> tripId;
  final Value<double> amount;
  final Value<String> currency;
  final Value<double?> amountMain;
  final Value<double?> fxRate;
  final Value<String> category;
  final Value<DateTime> spentAt;
  final Value<String?> country;
  final Value<String?> receiptDocumentId;
  final Value<String> source;
  final Value<String?> note;
  final Value<String?> receiptPath;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.tripId = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.amountMain = const Value.absent(),
    this.fxRate = const Value.absent(),
    this.category = const Value.absent(),
    this.spentAt = const Value.absent(),
    this.country = const Value.absent(),
    this.receiptDocumentId = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String tripId,
    required double amount,
    required String currency,
    this.amountMain = const Value.absent(),
    this.fxRate = const Value.absent(),
    this.category = const Value.absent(),
    required DateTime spentAt,
    this.country = const Value.absent(),
    this.receiptDocumentId = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       amount = Value(amount),
       currency = Value(currency),
       spentAt = Value(spentAt);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? tripId,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<double>? amountMain,
    Expression<double>? fxRate,
    Expression<String>? category,
    Expression<DateTime>? spentAt,
    Expression<String>? country,
    Expression<String>? receiptDocumentId,
    Expression<String>? source,
    Expression<String>? note,
    Expression<String>? receiptPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (tripId != null) 'trip_id': tripId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (amountMain != null) 'amount_main': amountMain,
      if (fxRate != null) 'fx_rate': fxRate,
      if (category != null) 'category': category,
      if (spentAt != null) 'spent_at': spentAt,
      if (country != null) 'country': country,
      if (receiptDocumentId != null) 'receipt_document_id': receiptDocumentId,
      if (source != null) 'source': source,
      if (note != null) 'note': note,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<String>? tripId,
    Value<double>? amount,
    Value<String>? currency,
    Value<double?>? amountMain,
    Value<double?>? fxRate,
    Value<String>? category,
    Value<DateTime>? spentAt,
    Value<String?>? country,
    Value<String?>? receiptDocumentId,
    Value<String>? source,
    Value<String?>? note,
    Value<String?>? receiptPath,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      tripId: tripId ?? this.tripId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountMain: amountMain ?? this.amountMain,
      fxRate: fxRate ?? this.fxRate,
      category: category ?? this.category,
      spentAt: spentAt ?? this.spentAt,
      country: country ?? this.country,
      receiptDocumentId: receiptDocumentId ?? this.receiptDocumentId,
      source: source ?? this.source,
      note: note ?? this.note,
      receiptPath: receiptPath ?? this.receiptPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (amountMain.present) {
      map['amount_main'] = Variable<double>(amountMain.value);
    }
    if (fxRate.present) {
      map['fx_rate'] = Variable<double>(fxRate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (spentAt.present) {
      map['spent_at'] = Variable<DateTime>(spentAt.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (receiptDocumentId.present) {
      map['receipt_document_id'] = Variable<String>(receiptDocumentId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('tripId: $tripId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('amountMain: $amountMain, ')
          ..write('fxRate: $fxRate, ')
          ..write('category: $category, ')
          ..write('spentAt: $spentAt, ')
          ..write('country: $country, ')
          ..write('receiptDocumentId: $receiptDocumentId, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeIdMeta = const VerificationMeta(
    'placeId',
  );
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
    'place_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES places (id)',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id)',
    ),
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES expenses (id)',
    ),
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindMinutesMeta = const VerificationMeta(
    'remindMinutes',
  );
  @override
  late final GeneratedColumn<int> remindMinutes = GeneratedColumn<int>(
    'remind_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    tripId,
    date,
    sortOrder,
    title,
    placeId,
    documentId,
    expenseId,
    endDate,
    startMinutes,
    remindMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('place_id')) {
      context.handle(
        _placeIdMeta,
        placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta),
      );
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    }
    if (data.containsKey('remind_minutes')) {
      context.handle(
        _remindMinutesMeta,
        remindMinutes.isAcceptableOrUnknown(
          data['remind_minutes']!,
          _remindMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      placeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_id'],
      ),
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      ),
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      ),
      remindMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_minutes'],
      ),
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEvent extends DataClass implements Insertable<CalendarEvent> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final String tripId;
  final DateTime date;
  final int sortOrder;
  final String title;
  final String? placeId;
  final String? documentId;
  final String? expenseId;
  final DateTime? endDate;
  final int? startMinutes;
  final int? remindMinutes;
  const CalendarEvent({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.tripId,
    required this.date,
    required this.sortOrder,
    required this.title,
    this.placeId,
    this.documentId,
    this.expenseId,
    this.endDate,
    this.startMinutes,
    this.remindMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['trip_id'] = Variable<String>(tripId);
    map['date'] = Variable<DateTime>(date);
    map['sort_order'] = Variable<int>(sortOrder);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || placeId != null) {
      map['place_id'] = Variable<String>(placeId);
    }
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    if (!nullToAbsent || expenseId != null) {
      map['expense_id'] = Variable<String>(expenseId);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || startMinutes != null) {
      map['start_minutes'] = Variable<int>(startMinutes);
    }
    if (!nullToAbsent || remindMinutes != null) {
      map['remind_minutes'] = Variable<int>(remindMinutes);
    }
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      tripId: Value(tripId),
      date: Value(date),
      sortOrder: Value(sortOrder),
      title: Value(title),
      placeId: placeId == null && nullToAbsent
          ? const Value.absent()
          : Value(placeId),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      expenseId: expenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseId),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      startMinutes: startMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinutes),
      remindMinutes: remindMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(remindMinutes),
    );
  }

  factory CalendarEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEvent(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      tripId: serializer.fromJson<String>(json['tripId']),
      date: serializer.fromJson<DateTime>(json['date']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      title: serializer.fromJson<String>(json['title']),
      placeId: serializer.fromJson<String?>(json['placeId']),
      documentId: serializer.fromJson<String?>(json['documentId']),
      expenseId: serializer.fromJson<String?>(json['expenseId']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      startMinutes: serializer.fromJson<int?>(json['startMinutes']),
      remindMinutes: serializer.fromJson<int?>(json['remindMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'tripId': serializer.toJson<String>(tripId),
      'date': serializer.toJson<DateTime>(date),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'title': serializer.toJson<String>(title),
      'placeId': serializer.toJson<String?>(placeId),
      'documentId': serializer.toJson<String?>(documentId),
      'expenseId': serializer.toJson<String?>(expenseId),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'startMinutes': serializer.toJson<int?>(startMinutes),
      'remindMinutes': serializer.toJson<int?>(remindMinutes),
    };
  }

  CalendarEvent copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
    String? tripId,
    DateTime? date,
    int? sortOrder,
    String? title,
    Value<String?> placeId = const Value.absent(),
    Value<String?> documentId = const Value.absent(),
    Value<String?> expenseId = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> startMinutes = const Value.absent(),
    Value<int?> remindMinutes = const Value.absent(),
  }) => CalendarEvent(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    tripId: tripId ?? this.tripId,
    date: date ?? this.date,
    sortOrder: sortOrder ?? this.sortOrder,
    title: title ?? this.title,
    placeId: placeId.present ? placeId.value : this.placeId,
    documentId: documentId.present ? documentId.value : this.documentId,
    expenseId: expenseId.present ? expenseId.value : this.expenseId,
    endDate: endDate.present ? endDate.value : this.endDate,
    startMinutes: startMinutes.present ? startMinutes.value : this.startMinutes,
    remindMinutes: remindMinutes.present
        ? remindMinutes.value
        : this.remindMinutes,
  );
  CalendarEvent copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEvent(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      date: data.date.present ? data.date.value : this.date,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      title: data.title.present ? data.title.value : this.title,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      remindMinutes: data.remindMinutes.present
          ? data.remindMinutes.value
          : this.remindMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEvent(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('tripId: $tripId, ')
          ..write('date: $date, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('title: $title, ')
          ..write('placeId: $placeId, ')
          ..write('documentId: $documentId, ')
          ..write('expenseId: $expenseId, ')
          ..write('endDate: $endDate, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('remindMinutes: $remindMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    tripId,
    date,
    sortOrder,
    title,
    placeId,
    documentId,
    expenseId,
    endDate,
    startMinutes,
    remindMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEvent &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.tripId == this.tripId &&
          other.date == this.date &&
          other.sortOrder == this.sortOrder &&
          other.title == this.title &&
          other.placeId == this.placeId &&
          other.documentId == this.documentId &&
          other.expenseId == this.expenseId &&
          other.endDate == this.endDate &&
          other.startMinutes == this.startMinutes &&
          other.remindMinutes == this.remindMinutes);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEvent> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<String> tripId;
  final Value<DateTime> date;
  final Value<int> sortOrder;
  final Value<String> title;
  final Value<String?> placeId;
  final Value<String?> documentId;
  final Value<String?> expenseId;
  final Value<DateTime?> endDate;
  final Value<int?> startMinutes;
  final Value<int?> remindMinutes;
  final Value<int> rowid;
  const CalendarEventsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.tripId = const Value.absent(),
    this.date = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.title = const Value.absent(),
    this.placeId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.remindMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String tripId,
    required DateTime date,
    this.sortOrder = const Value.absent(),
    required String title,
    this.placeId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.remindMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       date = Value(date),
       title = Value(title);
  static Insertable<CalendarEvent> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? tripId,
    Expression<DateTime>? date,
    Expression<int>? sortOrder,
    Expression<String>? title,
    Expression<String>? placeId,
    Expression<String>? documentId,
    Expression<String>? expenseId,
    Expression<DateTime>? endDate,
    Expression<int>? startMinutes,
    Expression<int>? remindMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (tripId != null) 'trip_id': tripId,
      if (date != null) 'date': date,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (title != null) 'title': title,
      if (placeId != null) 'place_id': placeId,
      if (documentId != null) 'document_id': documentId,
      if (expenseId != null) 'expense_id': expenseId,
      if (endDate != null) 'end_date': endDate,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (remindMinutes != null) 'remind_minutes': remindMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<String>? tripId,
    Value<DateTime>? date,
    Value<int>? sortOrder,
    Value<String>? title,
    Value<String?>? placeId,
    Value<String?>? documentId,
    Value<String?>? expenseId,
    Value<DateTime?>? endDate,
    Value<int?>? startMinutes,
    Value<int?>? remindMinutes,
    Value<int>? rowid,
  }) {
    return CalendarEventsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      sortOrder: sortOrder ?? this.sortOrder,
      title: title ?? this.title,
      placeId: placeId ?? this.placeId,
      documentId: documentId ?? this.documentId,
      expenseId: expenseId ?? this.expenseId,
      endDate: endDate ?? this.endDate,
      startMinutes: startMinutes ?? this.startMinutes,
      remindMinutes: remindMinutes ?? this.remindMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (remindMinutes.present) {
      map['remind_minutes'] = Variable<int>(remindMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('tripId: $tripId, ')
          ..write('date: $date, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('title: $title, ')
          ..write('placeId: $placeId, ')
          ..write('documentId: $documentId, ')
          ..write('expenseId: $expenseId, ')
          ..write('endDate: $endDate, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('remindMinutes: $remindMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TicketsTable extends Tickets with TableInfo<$TicketsTable, Ticket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id)',
    ),
  );
  static const VerificationMeta _carrierMeta = const VerificationMeta(
    'carrier',
  );
  @override
  late final GeneratedColumn<String> carrier = GeneratedColumn<String>(
    'carrier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookingRefMeta = const VerificationMeta(
    'bookingRef',
  );
  @override
  late final GeneratedColumn<String> bookingRef = GeneratedColumn<String>(
    'booking_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _departAtMeta = const VerificationMeta(
    'departAt',
  );
  @override
  late final GeneratedColumn<DateTime> departAt = GeneratedColumn<DateTime>(
    'depart_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arriveAtMeta = const VerificationMeta(
    'arriveAt',
  );
  @override
  late final GeneratedColumn<DateTime> arriveAt = GeneratedColumn<DateTime>(
    'arrive_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromPlaceMeta = const VerificationMeta(
    'fromPlace',
  );
  @override
  late final GeneratedColumn<String> fromPlace = GeneratedColumn<String>(
    'from_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toPlaceMeta = const VerificationMeta(
    'toPlace',
  );
  @override
  late final GeneratedColumn<String> toPlace = GeneratedColumn<String>(
    'to_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qrDataMeta = const VerificationMeta('qrData');
  @override
  late final GeneratedColumn<String> qrData = GeneratedColumn<String>(
    'qr_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeDataMeta = const VerificationMeta(
    'barcodeData',
  );
  @override
  late final GeneratedColumn<String> barcodeData = GeneratedColumn<String>(
    'barcode_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeFormatMeta = const VerificationMeta(
    'barcodeFormat',
  );
  @override
  late final GeneratedColumn<String> barcodeFormat = GeneratedColumn<String>(
    'barcode_format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    documentId,
    carrier,
    number,
    bookingRef,
    departAt,
    arriveAt,
    fromPlace,
    toPlace,
    qrData,
    barcodeData,
    barcodeFormat,
    price,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tickets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ticket> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('carrier')) {
      context.handle(
        _carrierMeta,
        carrier.isAcceptableOrUnknown(data['carrier']!, _carrierMeta),
      );
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('booking_ref')) {
      context.handle(
        _bookingRefMeta,
        bookingRef.isAcceptableOrUnknown(data['booking_ref']!, _bookingRefMeta),
      );
    }
    if (data.containsKey('depart_at')) {
      context.handle(
        _departAtMeta,
        departAt.isAcceptableOrUnknown(data['depart_at']!, _departAtMeta),
      );
    }
    if (data.containsKey('arrive_at')) {
      context.handle(
        _arriveAtMeta,
        arriveAt.isAcceptableOrUnknown(data['arrive_at']!, _arriveAtMeta),
      );
    }
    if (data.containsKey('from_place')) {
      context.handle(
        _fromPlaceMeta,
        fromPlace.isAcceptableOrUnknown(data['from_place']!, _fromPlaceMeta),
      );
    }
    if (data.containsKey('to_place')) {
      context.handle(
        _toPlaceMeta,
        toPlace.isAcceptableOrUnknown(data['to_place']!, _toPlaceMeta),
      );
    }
    if (data.containsKey('qr_data')) {
      context.handle(
        _qrDataMeta,
        qrData.isAcceptableOrUnknown(data['qr_data']!, _qrDataMeta),
      );
    }
    if (data.containsKey('barcode_data')) {
      context.handle(
        _barcodeDataMeta,
        barcodeData.isAcceptableOrUnknown(
          data['barcode_data']!,
          _barcodeDataMeta,
        ),
      );
    }
    if (data.containsKey('barcode_format')) {
      context.handle(
        _barcodeFormatMeta,
        barcodeFormat.isAcceptableOrUnknown(
          data['barcode_format']!,
          _barcodeFormatMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ticket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ticket(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      carrier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}carrier'],
      ),
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      ),
      bookingRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_ref'],
      ),
      departAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}depart_at'],
      ),
      arriveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrive_at'],
      ),
      fromPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_place'],
      ),
      toPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_place'],
      ),
      qrData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_data'],
      ),
      barcodeData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_data'],
      ),
      barcodeFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_format'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
    );
  }

  @override
  $TicketsTable createAlias(String alias) {
    return $TicketsTable(attachedDatabase, alias);
  }
}

class Ticket extends DataClass implements Insertable<Ticket> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final String documentId;
  final String? carrier;
  final String? number;
  final String? bookingRef;
  final DateTime? departAt;
  final DateTime? arriveAt;
  final String? fromPlace;
  final String? toPlace;
  final String? qrData;
  final String? barcodeData;
  final String? barcodeFormat;
  final double? price;
  final String? currency;
  const Ticket({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.documentId,
    this.carrier,
    this.number,
    this.bookingRef,
    this.departAt,
    this.arriveAt,
    this.fromPlace,
    this.toPlace,
    this.qrData,
    this.barcodeData,
    this.barcodeFormat,
    this.price,
    this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['document_id'] = Variable<String>(documentId);
    if (!nullToAbsent || carrier != null) {
      map['carrier'] = Variable<String>(carrier);
    }
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<String>(number);
    }
    if (!nullToAbsent || bookingRef != null) {
      map['booking_ref'] = Variable<String>(bookingRef);
    }
    if (!nullToAbsent || departAt != null) {
      map['depart_at'] = Variable<DateTime>(departAt);
    }
    if (!nullToAbsent || arriveAt != null) {
      map['arrive_at'] = Variable<DateTime>(arriveAt);
    }
    if (!nullToAbsent || fromPlace != null) {
      map['from_place'] = Variable<String>(fromPlace);
    }
    if (!nullToAbsent || toPlace != null) {
      map['to_place'] = Variable<String>(toPlace);
    }
    if (!nullToAbsent || qrData != null) {
      map['qr_data'] = Variable<String>(qrData);
    }
    if (!nullToAbsent || barcodeData != null) {
      map['barcode_data'] = Variable<String>(barcodeData);
    }
    if (!nullToAbsent || barcodeFormat != null) {
      map['barcode_format'] = Variable<String>(barcodeFormat);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    return map;
  }

  TicketsCompanion toCompanion(bool nullToAbsent) {
    return TicketsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      documentId: Value(documentId),
      carrier: carrier == null && nullToAbsent
          ? const Value.absent()
          : Value(carrier),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      bookingRef: bookingRef == null && nullToAbsent
          ? const Value.absent()
          : Value(bookingRef),
      departAt: departAt == null && nullToAbsent
          ? const Value.absent()
          : Value(departAt),
      arriveAt: arriveAt == null && nullToAbsent
          ? const Value.absent()
          : Value(arriveAt),
      fromPlace: fromPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(fromPlace),
      toPlace: toPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(toPlace),
      qrData: qrData == null && nullToAbsent
          ? const Value.absent()
          : Value(qrData),
      barcodeData: barcodeData == null && nullToAbsent
          ? const Value.absent()
          : Value(barcodeData),
      barcodeFormat: barcodeFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(barcodeFormat),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
    );
  }

  factory Ticket.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ticket(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      documentId: serializer.fromJson<String>(json['documentId']),
      carrier: serializer.fromJson<String?>(json['carrier']),
      number: serializer.fromJson<String?>(json['number']),
      bookingRef: serializer.fromJson<String?>(json['bookingRef']),
      departAt: serializer.fromJson<DateTime?>(json['departAt']),
      arriveAt: serializer.fromJson<DateTime?>(json['arriveAt']),
      fromPlace: serializer.fromJson<String?>(json['fromPlace']),
      toPlace: serializer.fromJson<String?>(json['toPlace']),
      qrData: serializer.fromJson<String?>(json['qrData']),
      barcodeData: serializer.fromJson<String?>(json['barcodeData']),
      barcodeFormat: serializer.fromJson<String?>(json['barcodeFormat']),
      price: serializer.fromJson<double?>(json['price']),
      currency: serializer.fromJson<String?>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'documentId': serializer.toJson<String>(documentId),
      'carrier': serializer.toJson<String?>(carrier),
      'number': serializer.toJson<String?>(number),
      'bookingRef': serializer.toJson<String?>(bookingRef),
      'departAt': serializer.toJson<DateTime?>(departAt),
      'arriveAt': serializer.toJson<DateTime?>(arriveAt),
      'fromPlace': serializer.toJson<String?>(fromPlace),
      'toPlace': serializer.toJson<String?>(toPlace),
      'qrData': serializer.toJson<String?>(qrData),
      'barcodeData': serializer.toJson<String?>(barcodeData),
      'barcodeFormat': serializer.toJson<String?>(barcodeFormat),
      'price': serializer.toJson<double?>(price),
      'currency': serializer.toJson<String?>(currency),
    };
  }

  Ticket copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
    String? documentId,
    Value<String?> carrier = const Value.absent(),
    Value<String?> number = const Value.absent(),
    Value<String?> bookingRef = const Value.absent(),
    Value<DateTime?> departAt = const Value.absent(),
    Value<DateTime?> arriveAt = const Value.absent(),
    Value<String?> fromPlace = const Value.absent(),
    Value<String?> toPlace = const Value.absent(),
    Value<String?> qrData = const Value.absent(),
    Value<String?> barcodeData = const Value.absent(),
    Value<String?> barcodeFormat = const Value.absent(),
    Value<double?> price = const Value.absent(),
    Value<String?> currency = const Value.absent(),
  }) => Ticket(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    documentId: documentId ?? this.documentId,
    carrier: carrier.present ? carrier.value : this.carrier,
    number: number.present ? number.value : this.number,
    bookingRef: bookingRef.present ? bookingRef.value : this.bookingRef,
    departAt: departAt.present ? departAt.value : this.departAt,
    arriveAt: arriveAt.present ? arriveAt.value : this.arriveAt,
    fromPlace: fromPlace.present ? fromPlace.value : this.fromPlace,
    toPlace: toPlace.present ? toPlace.value : this.toPlace,
    qrData: qrData.present ? qrData.value : this.qrData,
    barcodeData: barcodeData.present ? barcodeData.value : this.barcodeData,
    barcodeFormat: barcodeFormat.present
        ? barcodeFormat.value
        : this.barcodeFormat,
    price: price.present ? price.value : this.price,
    currency: currency.present ? currency.value : this.currency,
  );
  Ticket copyWithCompanion(TicketsCompanion data) {
    return Ticket(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      carrier: data.carrier.present ? data.carrier.value : this.carrier,
      number: data.number.present ? data.number.value : this.number,
      bookingRef: data.bookingRef.present
          ? data.bookingRef.value
          : this.bookingRef,
      departAt: data.departAt.present ? data.departAt.value : this.departAt,
      arriveAt: data.arriveAt.present ? data.arriveAt.value : this.arriveAt,
      fromPlace: data.fromPlace.present ? data.fromPlace.value : this.fromPlace,
      toPlace: data.toPlace.present ? data.toPlace.value : this.toPlace,
      qrData: data.qrData.present ? data.qrData.value : this.qrData,
      barcodeData: data.barcodeData.present
          ? data.barcodeData.value
          : this.barcodeData,
      barcodeFormat: data.barcodeFormat.present
          ? data.barcodeFormat.value
          : this.barcodeFormat,
      price: data.price.present ? data.price.value : this.price,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ticket(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('documentId: $documentId, ')
          ..write('carrier: $carrier, ')
          ..write('number: $number, ')
          ..write('bookingRef: $bookingRef, ')
          ..write('departAt: $departAt, ')
          ..write('arriveAt: $arriveAt, ')
          ..write('fromPlace: $fromPlace, ')
          ..write('toPlace: $toPlace, ')
          ..write('qrData: $qrData, ')
          ..write('barcodeData: $barcodeData, ')
          ..write('barcodeFormat: $barcodeFormat, ')
          ..write('price: $price, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    documentId,
    carrier,
    number,
    bookingRef,
    departAt,
    arriveAt,
    fromPlace,
    toPlace,
    qrData,
    barcodeData,
    barcodeFormat,
    price,
    currency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ticket &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.documentId == this.documentId &&
          other.carrier == this.carrier &&
          other.number == this.number &&
          other.bookingRef == this.bookingRef &&
          other.departAt == this.departAt &&
          other.arriveAt == this.arriveAt &&
          other.fromPlace == this.fromPlace &&
          other.toPlace == this.toPlace &&
          other.qrData == this.qrData &&
          other.barcodeData == this.barcodeData &&
          other.barcodeFormat == this.barcodeFormat &&
          other.price == this.price &&
          other.currency == this.currency);
}

class TicketsCompanion extends UpdateCompanion<Ticket> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<String> documentId;
  final Value<String?> carrier;
  final Value<String?> number;
  final Value<String?> bookingRef;
  final Value<DateTime?> departAt;
  final Value<DateTime?> arriveAt;
  final Value<String?> fromPlace;
  final Value<String?> toPlace;
  final Value<String?> qrData;
  final Value<String?> barcodeData;
  final Value<String?> barcodeFormat;
  final Value<double?> price;
  final Value<String?> currency;
  final Value<int> rowid;
  const TicketsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.documentId = const Value.absent(),
    this.carrier = const Value.absent(),
    this.number = const Value.absent(),
    this.bookingRef = const Value.absent(),
    this.departAt = const Value.absent(),
    this.arriveAt = const Value.absent(),
    this.fromPlace = const Value.absent(),
    this.toPlace = const Value.absent(),
    this.qrData = const Value.absent(),
    this.barcodeData = const Value.absent(),
    this.barcodeFormat = const Value.absent(),
    this.price = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TicketsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String documentId,
    this.carrier = const Value.absent(),
    this.number = const Value.absent(),
    this.bookingRef = const Value.absent(),
    this.departAt = const Value.absent(),
    this.arriveAt = const Value.absent(),
    this.fromPlace = const Value.absent(),
    this.toPlace = const Value.absent(),
    this.qrData = const Value.absent(),
    this.barcodeData = const Value.absent(),
    this.barcodeFormat = const Value.absent(),
    this.price = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId);
  static Insertable<Ticket> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? documentId,
    Expression<String>? carrier,
    Expression<String>? number,
    Expression<String>? bookingRef,
    Expression<DateTime>? departAt,
    Expression<DateTime>? arriveAt,
    Expression<String>? fromPlace,
    Expression<String>? toPlace,
    Expression<String>? qrData,
    Expression<String>? barcodeData,
    Expression<String>? barcodeFormat,
    Expression<double>? price,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (documentId != null) 'document_id': documentId,
      if (carrier != null) 'carrier': carrier,
      if (number != null) 'number': number,
      if (bookingRef != null) 'booking_ref': bookingRef,
      if (departAt != null) 'depart_at': departAt,
      if (arriveAt != null) 'arrive_at': arriveAt,
      if (fromPlace != null) 'from_place': fromPlace,
      if (toPlace != null) 'to_place': toPlace,
      if (qrData != null) 'qr_data': qrData,
      if (barcodeData != null) 'barcode_data': barcodeData,
      if (barcodeFormat != null) 'barcode_format': barcodeFormat,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TicketsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<String>? documentId,
    Value<String?>? carrier,
    Value<String?>? number,
    Value<String?>? bookingRef,
    Value<DateTime?>? departAt,
    Value<DateTime?>? arriveAt,
    Value<String?>? fromPlace,
    Value<String?>? toPlace,
    Value<String?>? qrData,
    Value<String?>? barcodeData,
    Value<String?>? barcodeFormat,
    Value<double?>? price,
    Value<String?>? currency,
    Value<int>? rowid,
  }) {
    return TicketsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      documentId: documentId ?? this.documentId,
      carrier: carrier ?? this.carrier,
      number: number ?? this.number,
      bookingRef: bookingRef ?? this.bookingRef,
      departAt: departAt ?? this.departAt,
      arriveAt: arriveAt ?? this.arriveAt,
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      qrData: qrData ?? this.qrData,
      barcodeData: barcodeData ?? this.barcodeData,
      barcodeFormat: barcodeFormat ?? this.barcodeFormat,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (carrier.present) {
      map['carrier'] = Variable<String>(carrier.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (bookingRef.present) {
      map['booking_ref'] = Variable<String>(bookingRef.value);
    }
    if (departAt.present) {
      map['depart_at'] = Variable<DateTime>(departAt.value);
    }
    if (arriveAt.present) {
      map['arrive_at'] = Variable<DateTime>(arriveAt.value);
    }
    if (fromPlace.present) {
      map['from_place'] = Variable<String>(fromPlace.value);
    }
    if (toPlace.present) {
      map['to_place'] = Variable<String>(toPlace.value);
    }
    if (qrData.present) {
      map['qr_data'] = Variable<String>(qrData.value);
    }
    if (barcodeData.present) {
      map['barcode_data'] = Variable<String>(barcodeData.value);
    }
    if (barcodeFormat.present) {
      map['barcode_format'] = Variable<String>(barcodeFormat.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('documentId: $documentId, ')
          ..write('carrier: $carrier, ')
          ..write('number: $number, ')
          ..write('bookingRef: $bookingRef, ')
          ..write('departAt: $departAt, ')
          ..write('arriveAt: $arriveAt, ')
          ..write('fromPlace: $fromPlace, ')
          ..write('toPlace: $toPlace, ')
          ..write('qrData: $qrData, ')
          ..write('barcodeData: $barcodeData, ')
          ..write('barcodeFormat: $barcodeFormat, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _placeIdMeta = const VerificationMeta(
    'placeId',
  );
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
    'place_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES places (id)',
    ),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    placeId,
    localPath,
    remoteUrl,
    lat,
    lng,
    takenAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('place_id')) {
      context.handle(
        _placeIdMeta,
        placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_placeIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      placeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final String placeId;
  final String localPath;
  final String? remoteUrl;
  final double? lat;
  final double? lng;
  final DateTime? takenAt;
  final String? note;
  const Photo({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.placeId,
    required this.localPath,
    this.remoteUrl,
    this.lat,
    this.lng,
    this.takenAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['place_id'] = Variable<String>(placeId);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<DateTime>(takenAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      placeId: Value(placeId),
      localPath: Value(localPath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      placeId: serializer.fromJson<String>(json['placeId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      takenAt: serializer.fromJson<DateTime?>(json['takenAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'placeId': serializer.toJson<String>(placeId),
      'localPath': serializer.toJson<String>(localPath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'takenAt': serializer.toJson<DateTime?>(takenAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  Photo copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
    String? placeId,
    String? localPath,
    Value<String?> remoteUrl = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<DateTime?> takenAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Photo(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    placeId: placeId ?? this.placeId,
    localPath: localPath ?? this.localPath,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    takenAt: takenAt.present ? takenAt.value : this.takenAt,
    note: note.present ? note.value : this.note,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('placeId: $placeId, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('takenAt: $takenAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    placeId,
    localPath,
    remoteUrl,
    lat,
    lng,
    takenAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.placeId == this.placeId &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.takenAt == this.takenAt &&
          other.note == this.note);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<String> placeId;
  final Value<String> localPath;
  final Value<String?> remoteUrl;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<DateTime?> takenAt;
  final Value<String?> note;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.placeId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String placeId,
    required String localPath,
    this.remoteUrl = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       placeId = Value(placeId),
       localPath = Value(localPath);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? placeId,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<DateTime>? takenAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (placeId != null) 'place_id': placeId,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (takenAt != null) 'taken_at': takenAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<String>? placeId,
    Value<String>? localPath,
    Value<String?>? remoteUrl,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<DateTime?>? takenAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      placeId: placeId ?? this.placeId,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      takenAt: takenAt ?? this.takenAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('placeId: $placeId, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('takenAt: $takenAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultItemsTable extends VaultItems
    with TableInfo<$VaultItemsTable, VaultItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedBlobMeta = const VerificationMeta(
    'encryptedBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedBlob =
      GeneratedColumn<Uint8List>(
        'encrypted_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    type,
    encryptedBlob,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('encrypted_blob')) {
      context.handle(
        _encryptedBlobMeta,
        encryptedBlob.isAcceptableOrUnknown(
          data['encrypted_blob']!,
          _encryptedBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedBlobMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      encryptedBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_blob'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
    );
  }

  @override
  $VaultItemsTable createAlias(String alias) {
    return $VaultItemsTable(attachedDatabase, alias);
  }
}

class VaultItem extends DataClass implements Insertable<VaultItem> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  final String type;
  final Uint8List encryptedBlob;
  final DateTime? expiresAt;
  const VaultItem({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.type,
    required this.encryptedBlob,
    this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['type'] = Variable<String>(type);
    map['encrypted_blob'] = Variable<Uint8List>(encryptedBlob);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  VaultItemsCompanion toCompanion(bool nullToAbsent) {
    return VaultItemsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      type: Value(type),
      encryptedBlob: Value(encryptedBlob),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory VaultItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultItem(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      type: serializer.fromJson<String>(json['type']),
      encryptedBlob: serializer.fromJson<Uint8List>(json['encryptedBlob']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
      'type': serializer.toJson<String>(type),
      'encryptedBlob': serializer.toJson<Uint8List>(encryptedBlob),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  VaultItem copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
    String? type,
    Uint8List? encryptedBlob,
    Value<DateTime?> expiresAt = const Value.absent(),
  }) => VaultItem(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    type: type ?? this.type,
    encryptedBlob: encryptedBlob ?? this.encryptedBlob,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
  );
  VaultItem copyWithCompanion(VaultItemsCompanion data) {
    return VaultItem(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      type: data.type.present ? data.type.value : this.type,
      encryptedBlob: data.encryptedBlob.present
          ? data.encryptedBlob.value
          : this.encryptedBlob,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultItem(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('type: $type, ')
          ..write('encryptedBlob: $encryptedBlob, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    type,
    $driftBlobEquality.hash(encryptedBlob),
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultItem &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.type == this.type &&
          $driftBlobEquality.equals(other.encryptedBlob, this.encryptedBlob) &&
          other.expiresAt == this.expiresAt);
}

class VaultItemsCompanion extends UpdateCompanion<VaultItem> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<String> type;
  final Value<Uint8List> encryptedBlob;
  final Value<DateTime?> expiresAt;
  final Value<int> rowid;
  const VaultItemsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.type = const Value.absent(),
    this.encryptedBlob = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultItemsCompanion.insert({
    required String id,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String type,
    required Uint8List encryptedBlob,
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       encryptedBlob = Value(encryptedBlob);
  static Insertable<VaultItem> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? type,
    Expression<Uint8List>? encryptedBlob,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (type != null) 'type': type,
      if (encryptedBlob != null) 'encrypted_blob': encryptedBlob,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<String>? type,
    Value<Uint8List>? encryptedBlob,
    Value<DateTime?>? expiresAt,
    Value<int>? rowid,
  }) {
    return VaultItemsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      type: type ?? this.type,
      encryptedBlob: encryptedBlob ?? this.encryptedBlob,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (encryptedBlob.present) {
      map['encrypted_blob'] = Variable<Uint8List>(encryptedBlob.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultItemsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('type: $type, ')
          ..write('encryptedBlob: $encryptedBlob, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $PlacesTable places = $PlacesTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $TicketsTable tickets = $TicketsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $VaultItemsTable vaultItems = $VaultItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trips,
    places,
    documents,
    expenses,
    calendarEvents,
    tickets,
    photos,
    vaultItems,
  ];
}

typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required String name,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String?> notes,
  Value<double?> budget,
  Value<String> mainCurrency,
  Value<String> countries,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<String> name,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<String?> notes,
  Value<double?> budget,
  Value<String> mainCurrency,
  Value<String> countries,
  Value<int> rowid,
});

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, Trip> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlacesTable, List<Place>> _placesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.places,
    aliasName: 'trips__id__places__trip_id',
  );

  $$PlacesTableProcessedTableManager get placesRefs {
    final manager = $$PlacesTableTableManager(
      $_db,
      $_db.places,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_placesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentsTable, List<Document>>
  _documentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: 'trips__id__documents__trip_id',
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'trips__id__expenses__trip_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CalendarEventsTable, List<CalendarEvent>>
  _calendarEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.calendarEvents,
    aliasName: 'trips__id__calendar_events__trip_id',
  );

  $$CalendarEventsTableProcessedTableManager get calendarEventsRefs {
    final manager = $$CalendarEventsTableTableManager(
      $_db,
      $_db.calendarEvents,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get budget => $composableBuilder(
    column: $table.budget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mainCurrency => $composableBuilder(
    column: $table.mainCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countries => $composableBuilder(
    column: $table.countries,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> placesRefs(
    Expression<bool> Function($$PlacesTableFilterComposer f) f,
  ) {
    final $$PlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableFilterComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> calendarEventsRefs(
    Expression<bool> Function($$CalendarEventsTableFilterComposer f) f,
  ) {
    final $$CalendarEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableFilterComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get budget => $composableBuilder(
    column: $table.budget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mainCurrency => $composableBuilder(
    column: $table.mainCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countries => $composableBuilder(
    column: $table.countries,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get budget =>
      $composableBuilder(column: $table.budget, builder: (column) => column);

  GeneratedColumn<String> get mainCurrency => $composableBuilder(
    column: $table.mainCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countries =>
      $composableBuilder(column: $table.countries, builder: (column) => column);

  Expression<T> placesRefs<T extends Object>(
    Expression<T> Function($$PlacesTableAnnotationComposer a) f,
  ) {
    final $$PlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> calendarEventsRefs<T extends Object>(
    Expression<T> Function($$CalendarEventsTableAnnotationComposer a) f,
  ) {
    final $$CalendarEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, $$TripsTableReferences),
          Trip,
          PrefetchHooks Function({
            bool placesRefs,
            bool documentsRefs,
            bool expensesRefs,
            bool calendarEventsRefs,
          })
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> budget = const Value.absent(),
                Value<String> mainCurrency = const Value.absent(),
                Value<String> countries = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                budget: budget,
                mainCurrency: mainCurrency,
                countries: countries,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required String name,
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> budget = const Value.absent(),
                Value<String> mainCurrency = const Value.absent(),
                Value<String> countries = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                budget: budget,
                mainCurrency: mainCurrency,
                countries: countries,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripsTable, Trip>(table),
                  $$TripsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                placesRefs = false,
                documentsRefs = false,
                expensesRefs = false,
                calendarEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (placesRefs) db.places,
                    if (documentsRefs) db.documents,
                    if (expensesRefs) db.expenses,
                    if (calendarEventsRefs) db.calendarEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (placesRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, Place>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._placesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(db, table, p0).placesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentsRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, Document>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._documentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, Expense>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (calendarEventsRefs)
                        await $_getPrefetchedData<
                          Trip,
                          $TripsTable,
                          CalendarEvent
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._calendarEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, $$TripsTableReferences),
      Trip,
      PrefetchHooks Function({
        bool placesRefs,
        bool documentsRefs,
        bool expensesRefs,
        bool calendarEventsRefs,
      })
    >;
typedef $$PlacesTableCreateCompanionBuilder = PlacesCompanion Function({
  required String id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required String tripId,
  required String name,
  required double lat,
  required double lng,
  Value<String> type,
  Value<String?> mapUrl,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$PlacesTableUpdateCompanionBuilder = PlacesCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<String> tripId,
  Value<String> name,
  Value<double> lat,
  Value<double> lng,
  Value<String> type,
  Value<String?> mapUrl,
  Value<String?> note,
  Value<int> rowid,
});

final class $$PlacesTableReferences
    extends BaseReferences<_$AppDatabase, $PlacesTable, Place> {
  $$PlacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('places__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CalendarEventsTable, List<CalendarEvent>>
  _calendarEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.calendarEvents,
    aliasName: 'places__id__calendar_events__place_id',
  );

  $$CalendarEventsTableProcessedTableManager get calendarEventsRefs {
    final manager = $$CalendarEventsTableTableManager(
      $_db,
      $_db.calendarEvents,
    ).filter((f) => f.placeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhotosTable, List<Photo>> _photosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.photos,
    aliasName: 'places__id__photos__place_id',
  );

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager(
      $_db,
      $_db.photos,
    ).filter((f) => f.placeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlacesTableFilterComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mapUrl => $composableBuilder(
    column: $table.mapUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> calendarEventsRefs(
    Expression<bool> Function($$CalendarEventsTableFilterComposer f) f,
  ) {
    final $$CalendarEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableFilterComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> photosRefs(
    Expression<bool> Function($$PhotosTableFilterComposer f) f,
  ) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableFilterComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlacesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapUrl => $composableBuilder(
    column: $table.mapUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get mapUrl =>
      $composableBuilder(column: $table.mapUrl, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> calendarEventsRefs<T extends Object>(
    Expression<T> Function($$CalendarEventsTableAnnotationComposer a) f,
  ) {
    final $$CalendarEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> photosRefs<T extends Object>(
    Expression<T> Function($$PhotosTableAnnotationComposer a) f,
  ) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlacesTable,
          Place,
          $$PlacesTableFilterComposer,
          $$PlacesTableOrderingComposer,
          $$PlacesTableAnnotationComposer,
          $$PlacesTableCreateCompanionBuilder,
          $$PlacesTableUpdateCompanionBuilder,
          (Place, $$PlacesTableReferences),
          Place,
          PrefetchHooks Function({
            bool tripId,
            bool calendarEventsRefs,
            bool photosRefs,
          })
        > {
  $$PlacesTableTableManager(_$AppDatabase db, $PlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> mapUrl = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                tripId: tripId,
                name: name,
                lat: lat,
                lng: lng,
                type: type,
                mapUrl: mapUrl,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required String tripId,
                required String name,
                required double lat,
                required double lng,
                Value<String> type = const Value.absent(),
                Value<String?> mapUrl = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                tripId: tripId,
                name: name,
                lat: lat,
                lng: lng,
                type: type,
                mapUrl: mapUrl,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlacesTable, Place>(table),
                  $$PlacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripId = false,
                calendarEventsRefs = false,
                photosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (calendarEventsRefs) db.calendarEvents,
                    if (photosRefs) db.photos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tripId,
                            referencedTable: $$PlacesTableReferences
                                ._tripIdTable(db),
                            referencedColumn: $$PlacesTableReferences
                                ._tripIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (calendarEventsRefs)
                        await $_getPrefetchedData<
                          Place,
                          $PlacesTable,
                          CalendarEvent
                        >(
                          currentTable: table,
                          referencedTable: $$PlacesTableReferences
                              ._calendarEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlacesTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.placeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (photosRefs)
                        await $_getPrefetchedData<Place, $PlacesTable, Photo>(
                          currentTable: table,
                          referencedTable: $$PlacesTableReferences
                              ._photosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlacesTableReferences(db, table, p0).photosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.placeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlacesTable,
      Place,
      $$PlacesTableFilterComposer,
      $$PlacesTableOrderingComposer,
      $$PlacesTableAnnotationComposer,
      $$PlacesTableCreateCompanionBuilder,
      $$PlacesTableUpdateCompanionBuilder,
      (Place, $$PlacesTableReferences),
      Place,
      PrefetchHooks Function({
        bool tripId,
        bool calendarEventsRefs,
        bool photosRefs,
      })
    >;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required String tripId,
  required String type,
  required String localPath,
  Value<String?> remoteUrl,
  Value<String> ocrStatus,
  Value<String?> extractedJson,
  Value<String?> rawText,
  Value<String?> title,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<String> tripId,
  Value<String> type,
  Value<String> localPath,
  Value<String?> remoteUrl,
  Value<String> ocrStatus,
  Value<String?> extractedJson,
  Value<String?> rawText,
  Value<String?> title,
  Value<int> rowid,
});

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, Document> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('documents__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'documents__id__expenses__receipt_document_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
      (f) => f.receiptDocumentId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CalendarEventsTable, List<CalendarEvent>>
  _calendarEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.calendarEvents,
    aliasName: 'documents__id__calendar_events__document_id',
  );

  $$CalendarEventsTableProcessedTableManager get calendarEventsRefs {
    final manager = $$CalendarEventsTableTableManager(
      $_db,
      $_db.calendarEvents,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TicketsTable, List<Ticket>> _ticketsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tickets,
    aliasName: 'documents__id__tickets__document_id',
  );

  $$TicketsTableProcessedTableManager get ticketsRefs {
    final manager = $$TicketsTableTableManager(
      $_db,
      $_db.tickets,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrStatus => $composableBuilder(
    column: $table.ocrStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedJson => $composableBuilder(
    column: $table.extractedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.receiptDocumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> calendarEventsRefs(
    Expression<bool> Function($$CalendarEventsTableFilterComposer f) f,
  ) {
    final $$CalendarEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableFilterComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ticketsRefs(
    Expression<bool> Function($$TicketsTableFilterComposer f) f,
  ) {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableFilterComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrStatus => $composableBuilder(
    column: $table.ocrStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedJson => $composableBuilder(
    column: $table.extractedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get ocrStatus =>
      $composableBuilder(column: $table.ocrStatus, builder: (column) => column);

  GeneratedColumn<String> get extractedJson => $composableBuilder(
    column: $table.extractedJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.receiptDocumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> calendarEventsRefs<T extends Object>(
    Expression<T> Function($$CalendarEventsTableAnnotationComposer a) f,
  ) {
    final $$CalendarEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ticketsRefs<T extends Object>(
    Expression<T> Function($$TicketsTableAnnotationComposer a) f,
  ) {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          Document,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (Document, $$DocumentsTableReferences),
          Document,
          PrefetchHooks Function({
            bool tripId,
            bool expensesRefs,
            bool calendarEventsRefs,
            bool ticketsRefs,
          })
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String> ocrStatus = const Value.absent(),
                Value<String?> extractedJson = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                tripId: tripId,
                type: type,
                localPath: localPath,
                remoteUrl: remoteUrl,
                ocrStatus: ocrStatus,
                extractedJson: extractedJson,
                rawText: rawText,
                title: title,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required String tripId,
                required String type,
                required String localPath,
                Value<String?> remoteUrl = const Value.absent(),
                Value<String> ocrStatus = const Value.absent(),
                Value<String?> extractedJson = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                tripId: tripId,
                type: type,
                localPath: localPath,
                remoteUrl: remoteUrl,
                ocrStatus: ocrStatus,
                extractedJson: extractedJson,
                rawText: rawText,
                title: title,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentsTable, Document>(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripId = false,
                expensesRefs = false,
                calendarEventsRefs = false,
                ticketsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expensesRefs) db.expenses,
                    if (calendarEventsRefs) db.calendarEvents,
                    if (ticketsRefs) db.tickets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tripId,
                            referencedTable: $$DocumentsTableReferences
                                ._tripIdTable(db),
                            referencedColumn: $$DocumentsTableReferences
                                ._tripIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.receiptDocumentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (calendarEventsRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          CalendarEvent
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._calendarEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ticketsRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          Ticket
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._ticketsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).ticketsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      Document,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (Document, $$DocumentsTableReferences),
      Document,
      PrefetchHooks Function({
        bool tripId,
        bool expensesRefs,
        bool calendarEventsRefs,
        bool ticketsRefs,
      })
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required String tripId,
  required double amount,
  required String currency,
  Value<double?> amountMain,
  Value<double?> fxRate,
  Value<String> category,
  required DateTime spentAt,
  Value<String?> country,
  Value<String?> receiptDocumentId,
  Value<String> source,
  Value<String?> note,
  Value<String?> receiptPath,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<String> tripId,
  Value<double> amount,
  Value<String> currency,
  Value<double?> amountMain,
  Value<double?> fxRate,
  Value<String> category,
  Value<DateTime> spentAt,
  Value<String?> country,
  Value<String?> receiptDocumentId,
  Value<String> source,
  Value<String?> note,
  Value<String?> receiptPath,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('expenses__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentsTable _receiptDocumentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('expenses__receipt_document_id__documents__id');

  $$DocumentsTableProcessedTableManager? get receiptDocumentId {
    final $_column = $_itemColumn<String>('receipt_document_id');
    if ($_column == null) return null;
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receiptDocumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CalendarEventsTable, List<CalendarEvent>>
  _calendarEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.calendarEvents,
    aliasName: 'expenses__id__calendar_events__expense_id',
  );

  $$CalendarEventsTableProcessedTableManager get calendarEventsRefs {
    final manager = $$CalendarEventsTableTableManager(
      $_db,
      $_db.calendarEvents,
    ).filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_calendarEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountMain => $composableBuilder(
    column: $table.amountMain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get spentAt => $composableBuilder(
    column: $table.spentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableFilterComposer get receiptDocumentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptDocumentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> calendarEventsRefs(
    Expression<bool> Function($$CalendarEventsTableFilterComposer f) f,
  ) {
    final $$CalendarEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableFilterComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountMain => $composableBuilder(
    column: $table.amountMain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fxRate => $composableBuilder(
    column: $table.fxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get spentAt => $composableBuilder(
    column: $table.spentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableOrderingComposer get receiptDocumentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptDocumentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get amountMain => $composableBuilder(
    column: $table.amountMain,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fxRate =>
      $composableBuilder(column: $table.fxRate, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get spentAt =>
      $composableBuilder(column: $table.spentAt, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableAnnotationComposer get receiptDocumentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptDocumentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> calendarEventsRefs<T extends Object>(
    Expression<T> Function($$CalendarEventsTableAnnotationComposer a) f,
  ) {
    final $$CalendarEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.calendarEvents,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({
            bool tripId,
            bool receiptDocumentId,
            bool calendarEventsRefs,
          })
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double?> amountMain = const Value.absent(),
                Value<double?> fxRate = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> spentAt = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> receiptDocumentId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                tripId: tripId,
                amount: amount,
                currency: currency,
                amountMain: amountMain,
                fxRate: fxRate,
                category: category,
                spentAt: spentAt,
                country: country,
                receiptDocumentId: receiptDocumentId,
                source: source,
                note: note,
                receiptPath: receiptPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required String tripId,
                required double amount,
                required String currency,
                Value<double?> amountMain = const Value.absent(),
                Value<double?> fxRate = const Value.absent(),
                Value<String> category = const Value.absent(),
                required DateTime spentAt,
                Value<String?> country = const Value.absent(),
                Value<String?> receiptDocumentId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                tripId: tripId,
                amount: amount,
                currency: currency,
                amountMain: amountMain,
                fxRate: fxRate,
                category: category,
                spentAt: spentAt,
                country: country,
                receiptDocumentId: receiptDocumentId,
                source: source,
                note: note,
                receiptPath: receiptPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, Expense>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripId = false,
                receiptDocumentId = false,
                calendarEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (calendarEventsRefs) db.calendarEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tripId,
                            referencedTable: $$ExpensesTableReferences
                                ._tripIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._tripIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (receiptDocumentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.receiptDocumentId,
                            referencedTable: $$ExpensesTableReferences
                                ._receiptDocumentIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._receiptDocumentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (calendarEventsRefs)
                        await $_getPrefetchedData<
                          Expense,
                          $ExpensesTable,
                          CalendarEvent
                        >(
                          currentTable: table,
                          referencedTable: $$ExpensesTableReferences
                              ._calendarEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpensesTableReferences(
                                db,
                                table,
                                p0,
                              ).calendarEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.expenseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({
        bool tripId,
        bool receiptDocumentId,
        bool calendarEventsRefs,
      })
    >;
typedef $$CalendarEventsTableCreateCompanionBuilder =
    CalendarEventsCompanion Function({
      required String id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncState,
      required String tripId,
      required DateTime date,
      Value<int> sortOrder,
      required String title,
      Value<String?> placeId,
      Value<String?> documentId,
      Value<String?> expenseId,
      Value<DateTime?> endDate,
      Value<int?> startMinutes,
      Value<int?> remindMinutes,
      Value<int> rowid,
    });
typedef $$CalendarEventsTableUpdateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncState,
      Value<String> tripId,
      Value<DateTime> date,
      Value<int> sortOrder,
      Value<String> title,
      Value<String?> placeId,
      Value<String?> documentId,
      Value<String?> expenseId,
      Value<DateTime?> endDate,
      Value<int?> startMinutes,
      Value<int?> remindMinutes,
      Value<int> rowid,
    });

final class $$CalendarEventsTableReferences
    extends BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent> {
  $$CalendarEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('calendar_events__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlacesTable _placeIdTable(_$AppDatabase db) =>
      db.places.createAlias('calendar_events__place_id__places__id');

  $$PlacesTableProcessedTableManager? get placeId {
    final $_column = $_itemColumn<String>('place_id');
    if ($_column == null) return null;
    final manager = $$PlacesTableTableManager(
      $_db,
      $_db.places,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_placeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('calendar_events__document_id__documents__id');

  $$DocumentsTableProcessedTableManager? get documentId {
    final $_column = $_itemColumn<String>('document_id');
    if ($_column == null) return null;
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias('calendar_events__expense_id__expenses__id');

  $$ExpensesTableProcessedTableManager? get expenseId {
    final $_column = $_itemColumn<String>('expense_id');
    if ($_column == null) return null;
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CalendarEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindMinutes => $composableBuilder(
    column: $table.remindMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableFilterComposer get placeId {
    final $$PlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableFilterComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableFilterComposer get expenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindMinutes => $composableBuilder(
    column: $table.remindMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableOrderingComposer get placeId {
    final $$PlacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableOrderingComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableOrderingComposer get expenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableOrderingComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remindMinutes => $composableBuilder(
    column: $table.remindMinutes,
    builder: (column) => column,
  );

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlacesTableAnnotationComposer get placeId {
    final $$PlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableAnnotationComposer get expenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CalendarEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarEventsTable,
          CalendarEvent,
          $$CalendarEventsTableFilterComposer,
          $$CalendarEventsTableOrderingComposer,
          $$CalendarEventsTableAnnotationComposer,
          $$CalendarEventsTableCreateCompanionBuilder,
          $$CalendarEventsTableUpdateCompanionBuilder,
          (CalendarEvent, $$CalendarEventsTableReferences),
          CalendarEvent,
          PrefetchHooks Function({
            bool tripId,
            bool placeId,
            bool documentId,
            bool expenseId,
          })
        > {
  $$CalendarEventsTableTableManager(
    _$AppDatabase db,
    $CalendarEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> placeId = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<String?> expenseId = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> remindMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                tripId: tripId,
                date: date,
                sortOrder: sortOrder,
                title: title,
                placeId: placeId,
                documentId: documentId,
                expenseId: expenseId,
                endDate: endDate,
                startMinutes: startMinutes,
                remindMinutes: remindMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required String tripId,
                required DateTime date,
                Value<int> sortOrder = const Value.absent(),
                required String title,
                Value<String?> placeId = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<String?> expenseId = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> remindMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                tripId: tripId,
                date: date,
                sortOrder: sortOrder,
                title: title,
                placeId: placeId,
                documentId: documentId,
                expenseId: expenseId,
                endDate: endDate,
                startMinutes: startMinutes,
                remindMinutes: remindMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarEventsTable, CalendarEvent>(table),
                  $$CalendarEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripId = false,
                placeId = false,
                documentId = false,
                expenseId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.tripId,
                            referencedTable: $$CalendarEventsTableReferences
                                ._tripIdTable(db),
                            referencedColumn: $$CalendarEventsTableReferences
                                ._tripIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (placeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.placeId,
                            referencedTable: $$CalendarEventsTableReferences
                                ._placeIdTable(db),
                            referencedColumn: $$CalendarEventsTableReferences
                                ._placeIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (documentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.documentId,
                            referencedTable: $$CalendarEventsTableReferences
                                ._documentIdTable(db),
                            referencedColumn: $$CalendarEventsTableReferences
                                ._documentIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (expenseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.expenseId,
                            referencedTable: $$CalendarEventsTableReferences
                                ._expenseIdTable(db),
                            referencedColumn: $$CalendarEventsTableReferences
                                ._expenseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CalendarEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarEventsTable,
      CalendarEvent,
      $$CalendarEventsTableFilterComposer,
      $$CalendarEventsTableOrderingComposer,
      $$CalendarEventsTableAnnotationComposer,
      $$CalendarEventsTableCreateCompanionBuilder,
      $$CalendarEventsTableUpdateCompanionBuilder,
      (CalendarEvent, $$CalendarEventsTableReferences),
      CalendarEvent,
      PrefetchHooks Function({
        bool tripId,
        bool placeId,
        bool documentId,
        bool expenseId,
      })
    >;
typedef $$TicketsTableCreateCompanionBuilder = TicketsCompanion Function({
  required String id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required String documentId,
  Value<String?> carrier,
  Value<String?> number,
  Value<String?> bookingRef,
  Value<DateTime?> departAt,
  Value<DateTime?> arriveAt,
  Value<String?> fromPlace,
  Value<String?> toPlace,
  Value<String?> qrData,
  Value<String?> barcodeData,
  Value<String?> barcodeFormat,
  Value<double?> price,
  Value<String?> currency,
  Value<int> rowid,
});
typedef $$TicketsTableUpdateCompanionBuilder = TicketsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<String> documentId,
  Value<String?> carrier,
  Value<String?> number,
  Value<String?> bookingRef,
  Value<DateTime?> departAt,
  Value<DateTime?> arriveAt,
  Value<String?> fromPlace,
  Value<String?> toPlace,
  Value<String?> qrData,
  Value<String?> barcodeData,
  Value<String?> barcodeFormat,
  Value<double?> price,
  Value<String?> currency,
  Value<int> rowid,
});

final class $$TicketsTableReferences
    extends BaseReferences<_$AppDatabase, $TicketsTable, Ticket> {
  $$TicketsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('tickets__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TicketsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carrier => $composableBuilder(
    column: $table.carrier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get departAt => $composableBuilder(
    column: $table.departAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arriveAt => $composableBuilder(
    column: $table.arriveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromPlace => $composableBuilder(
    column: $table.fromPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toPlace => $composableBuilder(
    column: $table.toPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrData => $composableBuilder(
    column: $table.qrData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcodeData => $composableBuilder(
    column: $table.barcodeData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcodeFormat => $composableBuilder(
    column: $table.barcodeFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carrier => $composableBuilder(
    column: $table.carrier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get departAt => $composableBuilder(
    column: $table.departAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arriveAt => $composableBuilder(
    column: $table.arriveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromPlace => $composableBuilder(
    column: $table.fromPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toPlace => $composableBuilder(
    column: $table.toPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrData => $composableBuilder(
    column: $table.qrData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcodeData => $composableBuilder(
    column: $table.barcodeData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcodeFormat => $composableBuilder(
    column: $table.barcodeFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get carrier =>
      $composableBuilder(column: $table.carrier, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get departAt =>
      $composableBuilder(column: $table.departAt, builder: (column) => column);

  GeneratedColumn<DateTime> get arriveAt =>
      $composableBuilder(column: $table.arriveAt, builder: (column) => column);

  GeneratedColumn<String> get fromPlace =>
      $composableBuilder(column: $table.fromPlace, builder: (column) => column);

  GeneratedColumn<String> get toPlace =>
      $composableBuilder(column: $table.toPlace, builder: (column) => column);

  GeneratedColumn<String> get qrData =>
      $composableBuilder(column: $table.qrData, builder: (column) => column);

  GeneratedColumn<String> get barcodeData => $composableBuilder(
    column: $table.barcodeData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcodeFormat => $composableBuilder(
    column: $table.barcodeFormat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TicketsTable,
          Ticket,
          $$TicketsTableFilterComposer,
          $$TicketsTableOrderingComposer,
          $$TicketsTableAnnotationComposer,
          $$TicketsTableCreateCompanionBuilder,
          $$TicketsTableUpdateCompanionBuilder,
          (Ticket, $$TicketsTableReferences),
          Ticket,
          PrefetchHooks Function({bool documentId})
        > {
  $$TicketsTableTableManager(_$AppDatabase db, $TicketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String?> carrier = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<String?> bookingRef = const Value.absent(),
                Value<DateTime?> departAt = const Value.absent(),
                Value<DateTime?> arriveAt = const Value.absent(),
                Value<String?> fromPlace = const Value.absent(),
                Value<String?> toPlace = const Value.absent(),
                Value<String?> qrData = const Value.absent(),
                Value<String?> barcodeData = const Value.absent(),
                Value<String?> barcodeFormat = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                documentId: documentId,
                carrier: carrier,
                number: number,
                bookingRef: bookingRef,
                departAt: departAt,
                arriveAt: arriveAt,
                fromPlace: fromPlace,
                toPlace: toPlace,
                qrData: qrData,
                barcodeData: barcodeData,
                barcodeFormat: barcodeFormat,
                price: price,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required String documentId,
                Value<String?> carrier = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<String?> bookingRef = const Value.absent(),
                Value<DateTime?> departAt = const Value.absent(),
                Value<DateTime?> arriveAt = const Value.absent(),
                Value<String?> fromPlace = const Value.absent(),
                Value<String?> toPlace = const Value.absent(),
                Value<String?> qrData = const Value.absent(),
                Value<String?> barcodeData = const Value.absent(),
                Value<String?> barcodeFormat = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                documentId: documentId,
                carrier: carrier,
                number: number,
                bookingRef: bookingRef,
                departAt: departAt,
                arriveAt: arriveAt,
                fromPlace: fromPlace,
                toPlace: toPlace,
                qrData: qrData,
                barcodeData: barcodeData,
                barcodeFormat: barcodeFormat,
                price: price,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TicketsTable, Ticket>(table),
                  $$TicketsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentId,
                        referencedTable: $$TicketsTableReferences
                            ._documentIdTable(db),
                        referencedColumn: $$TicketsTableReferences
                            ._documentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TicketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TicketsTable,
      Ticket,
      $$TicketsTableFilterComposer,
      $$TicketsTableOrderingComposer,
      $$TicketsTableAnnotationComposer,
      $$TicketsTableCreateCompanionBuilder,
      $$TicketsTableUpdateCompanionBuilder,
      (Ticket, $$TicketsTableReferences),
      Ticket,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required String placeId,
  required String localPath,
  Value<String?> remoteUrl,
  Value<double?> lat,
  Value<double?> lng,
  Value<DateTime?> takenAt,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<String> placeId,
  Value<String> localPath,
  Value<String?> remoteUrl,
  Value<double?> lat,
  Value<double?> lng,
  Value<DateTime?> takenAt,
  Value<String?> note,
  Value<int> rowid,
});

final class $$PhotosTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTable, Photo> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlacesTable _placeIdTable(_$AppDatabase db) =>
      db.places.createAlias('photos__place_id__places__id');

  $$PlacesTableProcessedTableManager get placeId {
    final $_column = $_itemColumn<String>('place_id')!;

    final manager = $$PlacesTableTableManager(
      $_db,
      $_db.places,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_placeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$PlacesTableFilterComposer get placeId {
    final $$PlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableFilterComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlacesTableOrderingComposer get placeId {
    final $$PlacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableOrderingComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$PlacesTableAnnotationComposer get placeId {
    final $$PlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.places,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.places,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, $$PhotosTableReferences),
          Photo,
          PrefetchHooks Function({bool placeId})
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> placeId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<DateTime?> takenAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                placeId: placeId,
                localPath: localPath,
                remoteUrl: remoteUrl,
                lat: lat,
                lng: lng,
                takenAt: takenAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required String placeId,
                required String localPath,
                Value<String?> remoteUrl = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<DateTime?> takenAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                placeId: placeId,
                localPath: localPath,
                remoteUrl: remoteUrl,
                lat: lat,
                lng: lng,
                takenAt: takenAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, Photo>(table),
                  $$PhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({placeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (placeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.placeId,
                        referencedTable: $$PhotosTableReferences._placeIdTable(
                          db,
                        ),
                        referencedColumn: $$PhotosTableReferences
                            ._placeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, $$PhotosTableReferences),
      Photo,
      PrefetchHooks Function({bool placeId})
    >;
typedef $$VaultItemsTableCreateCompanionBuilder = VaultItemsCompanion Function({
  required String id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  required String type,
  required Uint8List encryptedBlob,
  Value<DateTime?> expiresAt,
  Value<int> rowid,
});
typedef $$VaultItemsTableUpdateCompanionBuilder = VaultItemsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncState,
  Value<String> type,
  Value<Uint8List> encryptedBlob,
  Value<DateTime?> expiresAt,
  Value<int> rowid,
});

class $$VaultItemsTableFilterComposer
    extends Composer<_$AppDatabase, $VaultItemsTable> {
  $$VaultItemsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedBlob => $composableBuilder(
    column: $table.encryptedBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $VaultItemsTable> {
  $$VaultItemsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedBlob => $composableBuilder(
    column: $table.encryptedBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaultItemsTable> {
  $$VaultItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptedBlob => $composableBuilder(
    column: $table.encryptedBlob,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$VaultItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaultItemsTable,
          VaultItem,
          $$VaultItemsTableFilterComposer,
          $$VaultItemsTableOrderingComposer,
          $$VaultItemsTableAnnotationComposer,
          $$VaultItemsTableCreateCompanionBuilder,
          $$VaultItemsTableUpdateCompanionBuilder,
          (
            VaultItem,
            BaseReferences<_$AppDatabase, $VaultItemsTable, VaultItem>,
          ),
          VaultItem,
          PrefetchHooks Function()
        > {
  $$VaultItemsTableTableManager(_$AppDatabase db, $VaultItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<Uint8List> encryptedBlob = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultItemsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                type: type,
                encryptedBlob: encryptedBlob,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required String type,
                required Uint8List encryptedBlob,
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultItemsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                type: type,
                encryptedBlob: encryptedBlob,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VaultItemsTable, VaultItem>(table),
                  BaseReferences<_$AppDatabase, $VaultItemsTable, VaultItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaultItemsTable,
      VaultItem,
      $$VaultItemsTableFilterComposer,
      $$VaultItemsTableOrderingComposer,
      $$VaultItemsTableAnnotationComposer,
      $$VaultItemsTableCreateCompanionBuilder,
      $$VaultItemsTableUpdateCompanionBuilder,
      (VaultItem, BaseReferences<_$AppDatabase, $VaultItemsTable, VaultItem>),
      VaultItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$PlacesTableTableManager get places =>
      $$PlacesTableTableManager(_db, _db.places);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$TicketsTableTableManager get tickets =>
      $$TicketsTableTableManager(_db, _db.tickets);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$VaultItemsTableTableManager get vaultItems =>
      $$VaultItemsTableTableManager(_db, _db.vaultItems);
}

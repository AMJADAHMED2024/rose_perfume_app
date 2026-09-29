// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StorefrontCacheTable extends StorefrontCache
    with TableInfo<$StorefrontCacheTable, StorefrontCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StorefrontCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storefront_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<StorefrontCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StorefrontCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StorefrontCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StorefrontCacheTable createAlias(String alias) {
    return $StorefrontCacheTable(attachedDatabase, alias);
  }
}

class StorefrontCacheData extends DataClass
    implements Insertable<StorefrontCacheData> {
  final String id;
  final String payload;
  final DateTime updatedAt;
  const StorefrontCacheData(
      {required this.id, required this.payload, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StorefrontCacheCompanion toCompanion(bool nullToAbsent) {
    return StorefrontCacheCompanion(
      id: Value(id),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory StorefrontCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StorefrontCacheData(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StorefrontCacheData copyWith(
          {String? id, String? payload, DateTime? updatedAt}) =>
      StorefrontCacheData(
        id: id ?? this.id,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StorefrontCacheData copyWithCompanion(StorefrontCacheCompanion data) {
    return StorefrontCacheData(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StorefrontCacheData(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorefrontCacheData &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class StorefrontCacheCompanion extends UpdateCompanion<StorefrontCacheData> {
  final Value<String> id;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StorefrontCacheCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StorefrontCacheCompanion.insert({
    required String id,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<StorefrontCacheData> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StorefrontCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? payload,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return StorefrontCacheCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StorefrontCacheCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCartItemsTable extends LocalCartItems
    with TableInfo<$LocalCartItemsTable, LocalCartItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCartItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productPayloadMeta =
      const VerificationMeta('productPayload');
  @override
  late final GeneratedColumn<String> productPayload = GeneratedColumn<String>(
      'product_payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [productId, productPayload, quantity, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_cart_items';
  @override
  VerificationContext validateIntegrity(Insertable<LocalCartItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_payload')) {
      context.handle(
          _productPayloadMeta,
          productPayload.isAcceptableOrUnknown(
              data['product_payload']!, _productPayloadMeta));
    } else if (isInserting) {
      context.missing(_productPayloadMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  LocalCartItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCartItem(
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productPayload: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}product_payload'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalCartItemsTable createAlias(String alias) {
    return $LocalCartItemsTable(attachedDatabase, alias);
  }
}

class LocalCartItem extends DataClass implements Insertable<LocalCartItem> {
  final String productId;
  final String productPayload;
  final int quantity;
  final DateTime updatedAt;
  const LocalCartItem(
      {required this.productId,
      required this.productPayload,
      required this.quantity,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['product_payload'] = Variable<String>(productPayload);
    map['quantity'] = Variable<int>(quantity);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalCartItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalCartItemsCompanion(
      productId: Value(productId),
      productPayload: Value(productPayload),
      quantity: Value(quantity),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalCartItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCartItem(
      productId: serializer.fromJson<String>(json['productId']),
      productPayload: serializer.fromJson<String>(json['productPayload']),
      quantity: serializer.fromJson<int>(json['quantity']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'productPayload': serializer.toJson<String>(productPayload),
      'quantity': serializer.toJson<int>(quantity),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalCartItem copyWith(
          {String? productId,
          String? productPayload,
          int? quantity,
          DateTime? updatedAt}) =>
      LocalCartItem(
        productId: productId ?? this.productId,
        productPayload: productPayload ?? this.productPayload,
        quantity: quantity ?? this.quantity,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalCartItem copyWithCompanion(LocalCartItemsCompanion data) {
    return LocalCartItem(
      productId: data.productId.present ? data.productId.value : this.productId,
      productPayload: data.productPayload.present
          ? data.productPayload.value
          : this.productPayload,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCartItem(')
          ..write('productId: $productId, ')
          ..write('productPayload: $productPayload, ')
          ..write('quantity: $quantity, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(productId, productPayload, quantity, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCartItem &&
          other.productId == this.productId &&
          other.productPayload == this.productPayload &&
          other.quantity == this.quantity &&
          other.updatedAt == this.updatedAt);
}

class LocalCartItemsCompanion extends UpdateCompanion<LocalCartItem> {
  final Value<String> productId;
  final Value<String> productPayload;
  final Value<int> quantity;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalCartItemsCompanion({
    this.productId = const Value.absent(),
    this.productPayload = const Value.absent(),
    this.quantity = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCartItemsCompanion.insert({
    required String productId,
    required String productPayload,
    required int quantity,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : productId = Value(productId),
        productPayload = Value(productPayload),
        quantity = Value(quantity),
        updatedAt = Value(updatedAt);
  static Insertable<LocalCartItem> custom({
    Expression<String>? productId,
    Expression<String>? productPayload,
    Expression<int>? quantity,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (productPayload != null) 'product_payload': productPayload,
      if (quantity != null) 'quantity': quantity,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCartItemsCompanion copyWith(
      {Value<String>? productId,
      Value<String>? productPayload,
      Value<int>? quantity,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalCartItemsCompanion(
      productId: productId ?? this.productId,
      productPayload: productPayload ?? this.productPayload,
      quantity: quantity ?? this.quantity,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productPayload.present) {
      map['product_payload'] = Variable<String>(productPayload.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCartItemsCompanion(')
          ..write('productId: $productId, ')
          ..write('productPayload: $productPayload, ')
          ..write('quantity: $quantity, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, payload, retryCount, createdAt, nextAttemptAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_operations';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOperation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
    );
  }

  @override
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }
}

class SyncOperation extends DataClass implements Insertable<SyncOperation> {
  final String id;
  final String type;
  final String payload;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? nextAttemptAt;
  const SyncOperation(
      {required this.id,
      required this.type,
      required this.payload,
      required this.retryCount,
      required this.createdAt,
      this.nextAttemptAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      id: Value(id),
      type: Value(type),
      payload: Value(payload),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
    );
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperation(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
    };
  }

  SyncOperation copyWith(
          {String? id,
          String? type,
          String? payload,
          int? retryCount,
          DateTime? createdAt,
          Value<DateTime?> nextAttemptAt = const Value.absent()}) =>
      SyncOperation(
        id: id ?? this.id,
        type: type ?? this.type,
        payload: payload ?? this.payload,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt ?? this.createdAt,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
      );
  SyncOperation copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperation(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperation(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, payload, retryCount, createdAt, nextAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperation &&
          other.id == this.id &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperation> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> nextAttemptAt;
  final Value<int> rowid;
  const SyncOperationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    required String id,
    required String type,
    required String payload,
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncOperation> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOperationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? payload,
      Value<int>? retryCount,
      Value<DateTime>? createdAt,
      Value<DateTime?>? nextAttemptAt,
      Value<int>? rowid}) {
    return SyncOperationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentSessionsTable extends PaymentSessions
    with TableInfo<$PaymentSessionsTable, PaymentSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paymentTypeMeta =
      const VerificationMeta('paymentType');
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
      'payment_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceUrlMeta =
      const VerificationMeta('invoiceUrl');
  @override
  late final GeneratedColumn<String> invoiceUrl = GeneratedColumn<String>(
      'invoice_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceStatusMeta =
      const VerificationMeta('invoiceStatus');
  @override
  late final GeneratedColumn<String> invoiceStatus = GeneratedColumn<String>(
      'invoice_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shipmentIdMeta =
      const VerificationMeta('shipmentId');
  @override
  late final GeneratedColumn<String> shipmentId = GeneratedColumn<String>(
      'shipment_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _labelUrlMeta =
      const VerificationMeta('labelUrl');
  @override
  late final GeneratedColumn<String> labelUrl = GeneratedColumn<String>(
      'label_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastCheckedAtMeta =
      const VerificationMeta('lastCheckedAt');
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>('last_checked_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        invoiceId,
        orderId,
        paymentType,
        invoiceUrl,
        invoiceStatus,
        shipmentId,
        labelUrl,
        createdAt,
        lastCheckedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<PaymentSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('payment_type')) {
      context.handle(
          _paymentTypeMeta,
          paymentType.isAcceptableOrUnknown(
              data['payment_type']!, _paymentTypeMeta));
    }
    if (data.containsKey('invoice_url')) {
      context.handle(
          _invoiceUrlMeta,
          invoiceUrl.isAcceptableOrUnknown(
              data['invoice_url']!, _invoiceUrlMeta));
    }
    if (data.containsKey('invoice_status')) {
      context.handle(
          _invoiceStatusMeta,
          invoiceStatus.isAcceptableOrUnknown(
              data['invoice_status']!, _invoiceStatusMeta));
    }
    if (data.containsKey('shipment_id')) {
      context.handle(
          _shipmentIdMeta,
          shipmentId.isAcceptableOrUnknown(
              data['shipment_id']!, _shipmentIdMeta));
    }
    if (data.containsKey('label_url')) {
      context.handle(_labelUrlMeta,
          labelUrl.isAcceptableOrUnknown(data['label_url']!, _labelUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
          _lastCheckedAtMeta,
          lastCheckedAt.isAcceptableOrUnknown(
              data['last_checked_at']!, _lastCheckedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {invoiceId};
  @override
  PaymentSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentSession(
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      paymentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_type']),
      invoiceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_url']),
      invoiceStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_status']),
      shipmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shipment_id']),
      labelUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastCheckedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_checked_at']),
    );
  }

  @override
  $PaymentSessionsTable createAlias(String alias) {
    return $PaymentSessionsTable(attachedDatabase, alias);
  }
}

class PaymentSession extends DataClass implements Insertable<PaymentSession> {
  final String invoiceId;
  final int orderId;
  final String? paymentType;
  final String? invoiceUrl;
  final String? invoiceStatus;
  final String? shipmentId;
  final String? labelUrl;
  final DateTime createdAt;
  final DateTime? lastCheckedAt;
  const PaymentSession(
      {required this.invoiceId,
      required this.orderId,
      this.paymentType,
      this.invoiceUrl,
      this.invoiceStatus,
      this.shipmentId,
      this.labelUrl,
      required this.createdAt,
      this.lastCheckedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['invoice_id'] = Variable<String>(invoiceId);
    map['order_id'] = Variable<int>(orderId);
    if (!nullToAbsent || paymentType != null) {
      map['payment_type'] = Variable<String>(paymentType);
    }
    if (!nullToAbsent || invoiceUrl != null) {
      map['invoice_url'] = Variable<String>(invoiceUrl);
    }
    if (!nullToAbsent || invoiceStatus != null) {
      map['invoice_status'] = Variable<String>(invoiceStatus);
    }
    if (!nullToAbsent || shipmentId != null) {
      map['shipment_id'] = Variable<String>(shipmentId);
    }
    if (!nullToAbsent || labelUrl != null) {
      map['label_url'] = Variable<String>(labelUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    return map;
  }

  PaymentSessionsCompanion toCompanion(bool nullToAbsent) {
    return PaymentSessionsCompanion(
      invoiceId: Value(invoiceId),
      orderId: Value(orderId),
      paymentType: paymentType == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentType),
      invoiceUrl: invoiceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceUrl),
      invoiceStatus: invoiceStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceStatus),
      shipmentId: shipmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(shipmentId),
      labelUrl: labelUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(labelUrl),
      createdAt: Value(createdAt),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
    );
  }

  factory PaymentSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentSession(
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      orderId: serializer.fromJson<int>(json['orderId']),
      paymentType: serializer.fromJson<String?>(json['paymentType']),
      invoiceUrl: serializer.fromJson<String?>(json['invoiceUrl']),
      invoiceStatus: serializer.fromJson<String?>(json['invoiceStatus']),
      shipmentId: serializer.fromJson<String?>(json['shipmentId']),
      labelUrl: serializer.fromJson<String?>(json['labelUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'invoiceId': serializer.toJson<String>(invoiceId),
      'orderId': serializer.toJson<int>(orderId),
      'paymentType': serializer.toJson<String?>(paymentType),
      'invoiceUrl': serializer.toJson<String?>(invoiceUrl),
      'invoiceStatus': serializer.toJson<String?>(invoiceStatus),
      'shipmentId': serializer.toJson<String?>(shipmentId),
      'labelUrl': serializer.toJson<String?>(labelUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
    };
  }

  PaymentSession copyWith(
          {String? invoiceId,
          int? orderId,
          Value<String?> paymentType = const Value.absent(),
          Value<String?> invoiceUrl = const Value.absent(),
          Value<String?> invoiceStatus = const Value.absent(),
          Value<String?> shipmentId = const Value.absent(),
          Value<String?> labelUrl = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> lastCheckedAt = const Value.absent()}) =>
      PaymentSession(
        invoiceId: invoiceId ?? this.invoiceId,
        orderId: orderId ?? this.orderId,
        paymentType: paymentType.present ? paymentType.value : this.paymentType,
        invoiceUrl: invoiceUrl.present ? invoiceUrl.value : this.invoiceUrl,
        invoiceStatus:
            invoiceStatus.present ? invoiceStatus.value : this.invoiceStatus,
        shipmentId: shipmentId.present ? shipmentId.value : this.shipmentId,
        labelUrl: labelUrl.present ? labelUrl.value : this.labelUrl,
        createdAt: createdAt ?? this.createdAt,
        lastCheckedAt:
            lastCheckedAt.present ? lastCheckedAt.value : this.lastCheckedAt,
      );
  PaymentSession copyWithCompanion(PaymentSessionsCompanion data) {
    return PaymentSession(
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      paymentType:
          data.paymentType.present ? data.paymentType.value : this.paymentType,
      invoiceUrl:
          data.invoiceUrl.present ? data.invoiceUrl.value : this.invoiceUrl,
      invoiceStatus: data.invoiceStatus.present
          ? data.invoiceStatus.value
          : this.invoiceStatus,
      shipmentId:
          data.shipmentId.present ? data.shipmentId.value : this.shipmentId,
      labelUrl: data.labelUrl.present ? data.labelUrl.value : this.labelUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentSession(')
          ..write('invoiceId: $invoiceId, ')
          ..write('orderId: $orderId, ')
          ..write('paymentType: $paymentType, ')
          ..write('invoiceUrl: $invoiceUrl, ')
          ..write('invoiceStatus: $invoiceStatus, ')
          ..write('shipmentId: $shipmentId, ')
          ..write('labelUrl: $labelUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastCheckedAt: $lastCheckedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(invoiceId, orderId, paymentType, invoiceUrl,
      invoiceStatus, shipmentId, labelUrl, createdAt, lastCheckedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentSession &&
          other.invoiceId == this.invoiceId &&
          other.orderId == this.orderId &&
          other.paymentType == this.paymentType &&
          other.invoiceUrl == this.invoiceUrl &&
          other.invoiceStatus == this.invoiceStatus &&
          other.shipmentId == this.shipmentId &&
          other.labelUrl == this.labelUrl &&
          other.createdAt == this.createdAt &&
          other.lastCheckedAt == this.lastCheckedAt);
}

class PaymentSessionsCompanion extends UpdateCompanion<PaymentSession> {
  final Value<String> invoiceId;
  final Value<int> orderId;
  final Value<String?> paymentType;
  final Value<String?> invoiceUrl;
  final Value<String?> invoiceStatus;
  final Value<String?> shipmentId;
  final Value<String?> labelUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastCheckedAt;
  final Value<int> rowid;
  const PaymentSessionsCompanion({
    this.invoiceId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.invoiceUrl = const Value.absent(),
    this.invoiceStatus = const Value.absent(),
    this.shipmentId = const Value.absent(),
    this.labelUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentSessionsCompanion.insert({
    required String invoiceId,
    required int orderId,
    this.paymentType = const Value.absent(),
    this.invoiceUrl = const Value.absent(),
    this.invoiceStatus = const Value.absent(),
    this.shipmentId = const Value.absent(),
    this.labelUrl = const Value.absent(),
    required DateTime createdAt,
    this.lastCheckedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : invoiceId = Value(invoiceId),
        orderId = Value(orderId),
        createdAt = Value(createdAt);
  static Insertable<PaymentSession> custom({
    Expression<String>? invoiceId,
    Expression<int>? orderId,
    Expression<String>? paymentType,
    Expression<String>? invoiceUrl,
    Expression<String>? invoiceStatus,
    Expression<String>? shipmentId,
    Expression<String>? labelUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastCheckedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (orderId != null) 'order_id': orderId,
      if (paymentType != null) 'payment_type': paymentType,
      if (invoiceUrl != null) 'invoice_url': invoiceUrl,
      if (invoiceStatus != null) 'invoice_status': invoiceStatus,
      if (shipmentId != null) 'shipment_id': shipmentId,
      if (labelUrl != null) 'label_url': labelUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentSessionsCompanion copyWith(
      {Value<String>? invoiceId,
      Value<int>? orderId,
      Value<String?>? paymentType,
      Value<String?>? invoiceUrl,
      Value<String?>? invoiceStatus,
      Value<String?>? shipmentId,
      Value<String?>? labelUrl,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastCheckedAt,
      Value<int>? rowid}) {
    return PaymentSessionsCompanion(
      invoiceId: invoiceId ?? this.invoiceId,
      orderId: orderId ?? this.orderId,
      paymentType: paymentType ?? this.paymentType,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      shipmentId: shipmentId ?? this.shipmentId,
      labelUrl: labelUrl ?? this.labelUrl,
      createdAt: createdAt ?? this.createdAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (invoiceUrl.present) {
      map['invoice_url'] = Variable<String>(invoiceUrl.value);
    }
    if (invoiceStatus.present) {
      map['invoice_status'] = Variable<String>(invoiceStatus.value);
    }
    if (shipmentId.present) {
      map['shipment_id'] = Variable<String>(shipmentId.value);
    }
    if (labelUrl.present) {
      map['label_url'] = Variable<String>(labelUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentSessionsCompanion(')
          ..write('invoiceId: $invoiceId, ')
          ..write('orderId: $orderId, ')
          ..write('paymentType: $paymentType, ')
          ..write('invoiceUrl: $invoiceUrl, ')
          ..write('invoiceStatus: $invoiceStatus, ')
          ..write('shipmentId: $shipmentId, ')
          ..write('labelUrl: $labelUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderHistorySnapshotsTable extends OrderHistorySnapshots
    with TableInfo<$OrderHistorySnapshotsTable, OrderHistorySnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderHistorySnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [userId, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_history_snapshots';
  @override
  VerificationContext validateIntegrity(
      Insertable<OrderHistorySnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  OrderHistorySnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderHistorySnapshot(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $OrderHistorySnapshotsTable createAlias(String alias) {
    return $OrderHistorySnapshotsTable(attachedDatabase, alias);
  }
}

class OrderHistorySnapshot extends DataClass
    implements Insertable<OrderHistorySnapshot> {
  final int userId;
  final String payload;
  final DateTime updatedAt;
  const OrderHistorySnapshot(
      {required this.userId, required this.payload, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrderHistorySnapshotsCompanion toCompanion(bool nullToAbsent) {
    return OrderHistorySnapshotsCompanion(
      userId: Value(userId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrderHistorySnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderHistorySnapshot(
      userId: serializer.fromJson<int>(json['userId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OrderHistorySnapshot copyWith(
          {int? userId, String? payload, DateTime? updatedAt}) =>
      OrderHistorySnapshot(
        userId: userId ?? this.userId,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  OrderHistorySnapshot copyWithCompanion(OrderHistorySnapshotsCompanion data) {
    return OrderHistorySnapshot(
      userId: data.userId.present ? data.userId.value : this.userId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderHistorySnapshot(')
          ..write('userId: $userId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderHistorySnapshot &&
          other.userId == this.userId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class OrderHistorySnapshotsCompanion
    extends UpdateCompanion<OrderHistorySnapshot> {
  final Value<int> userId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  const OrderHistorySnapshotsCompanion({
    this.userId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OrderHistorySnapshotsCompanion.insert({
    this.userId = const Value.absent(),
    required String payload,
    required DateTime updatedAt,
  })  : payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<OrderHistorySnapshot> custom({
    Expression<int>? userId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OrderHistorySnapshotsCompanion copyWith(
      {Value<int>? userId,
      Value<String>? payload,
      Value<DateTime>? updatedAt}) {
    return OrderHistorySnapshotsCompanion(
      userId: userId ?? this.userId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderHistorySnapshotsCompanion(')
          ..write('userId: $userId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationSnapshotsTable extends NotificationSnapshots
    with TableInfo<$NotificationSnapshotsTable, NotificationSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [userId, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_snapshots';
  @override
  VerificationContext validateIntegrity(
      Insertable<NotificationSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  NotificationSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSnapshot(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $NotificationSnapshotsTable createAlias(String alias) {
    return $NotificationSnapshotsTable(attachedDatabase, alias);
  }
}

class NotificationSnapshot extends DataClass
    implements Insertable<NotificationSnapshot> {
  final int userId;
  final String payload;
  final DateTime updatedAt;
  const NotificationSnapshot(
      {required this.userId, required this.payload, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotificationSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return NotificationSnapshotsCompanion(
      userId: Value(userId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory NotificationSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSnapshot(
      userId: serializer.fromJson<int>(json['userId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NotificationSnapshot copyWith(
          {int? userId, String? payload, DateTime? updatedAt}) =>
      NotificationSnapshot(
        userId: userId ?? this.userId,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  NotificationSnapshot copyWithCompanion(NotificationSnapshotsCompanion data) {
    return NotificationSnapshot(
      userId: data.userId.present ? data.userId.value : this.userId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSnapshot(')
          ..write('userId: $userId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSnapshot &&
          other.userId == this.userId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class NotificationSnapshotsCompanion
    extends UpdateCompanion<NotificationSnapshot> {
  final Value<int> userId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  const NotificationSnapshotsCompanion({
    this.userId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotificationSnapshotsCompanion.insert({
    this.userId = const Value.absent(),
    required String payload,
    required DateTime updatedAt,
  })  : payload = Value(payload),
        updatedAt = Value(updatedAt);
  static Insertable<NotificationSnapshot> custom({
    Expression<int>? userId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotificationSnapshotsCompanion copyWith(
      {Value<int>? userId,
      Value<String>? payload,
      Value<DateTime>? updatedAt}) {
    return NotificationSnapshotsCompanion(
      userId: userId ?? this.userId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSnapshotsCompanion(')
          ..write('userId: $userId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StorefrontCacheTable storefrontCache =
      $StorefrontCacheTable(this);
  late final $LocalCartItemsTable localCartItems = $LocalCartItemsTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final $PaymentSessionsTable paymentSessions =
      $PaymentSessionsTable(this);
  late final $OrderHistorySnapshotsTable orderHistorySnapshots =
      $OrderHistorySnapshotsTable(this);
  late final $NotificationSnapshotsTable notificationSnapshots =
      $NotificationSnapshotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        storefrontCache,
        localCartItems,
        syncOperations,
        paymentSessions,
        orderHistorySnapshots,
        notificationSnapshots
      ];
}

typedef $$StorefrontCacheTableCreateCompanionBuilder = StorefrontCacheCompanion
    Function({
  required String id,
  required String payload,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$StorefrontCacheTableUpdateCompanionBuilder = StorefrontCacheCompanion
    Function({
  Value<String> id,
  Value<String> payload,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$StorefrontCacheTableFilterComposer
    extends FilterComposer<_$AppDatabase, $StorefrontCacheTable> {
  $$StorefrontCacheTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$StorefrontCacheTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $StorefrontCacheTable> {
  $$StorefrontCacheTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$StorefrontCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StorefrontCacheTable,
    StorefrontCacheData,
    $$StorefrontCacheTableFilterComposer,
    $$StorefrontCacheTableOrderingComposer,
    $$StorefrontCacheTableCreateCompanionBuilder,
    $$StorefrontCacheTableUpdateCompanionBuilder,
    (
      StorefrontCacheData,
      BaseReferences<_$AppDatabase, $StorefrontCacheTable, StorefrontCacheData>
    ),
    StorefrontCacheData,
    PrefetchHooks Function()> {
  $$StorefrontCacheTableTableManager(
      _$AppDatabase db, $StorefrontCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$StorefrontCacheTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$StorefrontCacheTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StorefrontCacheCompanion(
            id: id,
            payload: payload,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String payload,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StorefrontCacheCompanion.insert(
            id: id,
            payload: payload,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StorefrontCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StorefrontCacheTable,
    StorefrontCacheData,
    $$StorefrontCacheTableFilterComposer,
    $$StorefrontCacheTableOrderingComposer,
    $$StorefrontCacheTableCreateCompanionBuilder,
    $$StorefrontCacheTableUpdateCompanionBuilder,
    (
      StorefrontCacheData,
      BaseReferences<_$AppDatabase, $StorefrontCacheTable, StorefrontCacheData>
    ),
    StorefrontCacheData,
    PrefetchHooks Function()>;
typedef $$LocalCartItemsTableCreateCompanionBuilder = LocalCartItemsCompanion
    Function({
  required String productId,
  required String productPayload,
  required int quantity,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LocalCartItemsTableUpdateCompanionBuilder = LocalCartItemsCompanion
    Function({
  Value<String> productId,
  Value<String> productPayload,
  Value<int> quantity,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalCartItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LocalCartItemsTable> {
  $$LocalCartItemsTableFilterComposer(super.$state);
  ColumnFilters<String> get productId => $state.composableBuilder(
      column: $state.table.productId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get productPayload => $state.composableBuilder(
      column: $state.table.productPayload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$LocalCartItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LocalCartItemsTable> {
  $$LocalCartItemsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get productId => $state.composableBuilder(
      column: $state.table.productId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get productPayload => $state.composableBuilder(
      column: $state.table.productPayload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$LocalCartItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCartItemsTable,
    LocalCartItem,
    $$LocalCartItemsTableFilterComposer,
    $$LocalCartItemsTableOrderingComposer,
    $$LocalCartItemsTableCreateCompanionBuilder,
    $$LocalCartItemsTableUpdateCompanionBuilder,
    (
      LocalCartItem,
      BaseReferences<_$AppDatabase, $LocalCartItemsTable, LocalCartItem>
    ),
    LocalCartItem,
    PrefetchHooks Function()> {
  $$LocalCartItemsTableTableManager(
      _$AppDatabase db, $LocalCartItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LocalCartItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LocalCartItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> productId = const Value.absent(),
            Value<String> productPayload = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCartItemsCompanion(
            productId: productId,
            productPayload: productPayload,
            quantity: quantity,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String productId,
            required String productPayload,
            required int quantity,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCartItemsCompanion.insert(
            productId: productId,
            productPayload: productPayload,
            quantity: quantity,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalCartItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalCartItemsTable,
    LocalCartItem,
    $$LocalCartItemsTableFilterComposer,
    $$LocalCartItemsTableOrderingComposer,
    $$LocalCartItemsTableCreateCompanionBuilder,
    $$LocalCartItemsTableUpdateCompanionBuilder,
    (
      LocalCartItem,
      BaseReferences<_$AppDatabase, $LocalCartItemsTable, LocalCartItem>
    ),
    LocalCartItem,
    PrefetchHooks Function()>;
typedef $$SyncOperationsTableCreateCompanionBuilder = SyncOperationsCompanion
    Function({
  required String id,
  required String type,
  required String payload,
  Value<int> retryCount,
  required DateTime createdAt,
  Value<DateTime?> nextAttemptAt,
  Value<int> rowid,
});
typedef $$SyncOperationsTableUpdateCompanionBuilder = SyncOperationsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> payload,
  Value<int> retryCount,
  Value<DateTime> createdAt,
  Value<DateTime?> nextAttemptAt,
  Value<int> rowid,
});

class $$SyncOperationsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get retryCount => $state.composableBuilder(
      column: $state.table.retryCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get nextAttemptAt => $state.composableBuilder(
      column: $state.table.nextAttemptAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SyncOperationsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get retryCount => $state.composableBuilder(
      column: $state.table.retryCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get nextAttemptAt => $state.composableBuilder(
      column: $state.table.nextAttemptAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$SyncOperationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOperationsTable,
    SyncOperation,
    $$SyncOperationsTableFilterComposer,
    $$SyncOperationsTableOrderingComposer,
    $$SyncOperationsTableCreateCompanionBuilder,
    $$SyncOperationsTableUpdateCompanionBuilder,
    (
      SyncOperation,
      BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperation>
    ),
    SyncOperation,
    PrefetchHooks Function()> {
  $$SyncOperationsTableTableManager(
      _$AppDatabase db, $SyncOperationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SyncOperationsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SyncOperationsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOperationsCompanion(
            id: id,
            type: type,
            payload: payload,
            retryCount: retryCount,
            createdAt: createdAt,
            nextAttemptAt: nextAttemptAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String payload,
            Value<int> retryCount = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOperationsCompanion.insert(
            id: id,
            type: type,
            payload: payload,
            retryCount: retryCount,
            createdAt: createdAt,
            nextAttemptAt: nextAttemptAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOperationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncOperationsTable,
    SyncOperation,
    $$SyncOperationsTableFilterComposer,
    $$SyncOperationsTableOrderingComposer,
    $$SyncOperationsTableCreateCompanionBuilder,
    $$SyncOperationsTableUpdateCompanionBuilder,
    (
      SyncOperation,
      BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperation>
    ),
    SyncOperation,
    PrefetchHooks Function()>;
typedef $$PaymentSessionsTableCreateCompanionBuilder = PaymentSessionsCompanion
    Function({
  required String invoiceId,
  required int orderId,
  Value<String?> paymentType,
  Value<String?> invoiceUrl,
  Value<String?> invoiceStatus,
  Value<String?> shipmentId,
  Value<String?> labelUrl,
  required DateTime createdAt,
  Value<DateTime?> lastCheckedAt,
  Value<int> rowid,
});
typedef $$PaymentSessionsTableUpdateCompanionBuilder = PaymentSessionsCompanion
    Function({
  Value<String> invoiceId,
  Value<int> orderId,
  Value<String?> paymentType,
  Value<String?> invoiceUrl,
  Value<String?> invoiceStatus,
  Value<String?> shipmentId,
  Value<String?> labelUrl,
  Value<DateTime> createdAt,
  Value<DateTime?> lastCheckedAt,
  Value<int> rowid,
});

class $$PaymentSessionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PaymentSessionsTable> {
  $$PaymentSessionsTableFilterComposer(super.$state);
  ColumnFilters<String> get invoiceId => $state.composableBuilder(
      column: $state.table.invoiceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get orderId => $state.composableBuilder(
      column: $state.table.orderId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get paymentType => $state.composableBuilder(
      column: $state.table.paymentType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get invoiceUrl => $state.composableBuilder(
      column: $state.table.invoiceUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get invoiceStatus => $state.composableBuilder(
      column: $state.table.invoiceStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shipmentId => $state.composableBuilder(
      column: $state.table.shipmentId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get labelUrl => $state.composableBuilder(
      column: $state.table.labelUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastCheckedAt => $state.composableBuilder(
      column: $state.table.lastCheckedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PaymentSessionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PaymentSessionsTable> {
  $$PaymentSessionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get invoiceId => $state.composableBuilder(
      column: $state.table.invoiceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get orderId => $state.composableBuilder(
      column: $state.table.orderId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get paymentType => $state.composableBuilder(
      column: $state.table.paymentType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get invoiceUrl => $state.composableBuilder(
      column: $state.table.invoiceUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get invoiceStatus => $state.composableBuilder(
      column: $state.table.invoiceStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shipmentId => $state.composableBuilder(
      column: $state.table.shipmentId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get labelUrl => $state.composableBuilder(
      column: $state.table.labelUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastCheckedAt => $state.composableBuilder(
      column: $state.table.lastCheckedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$PaymentSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentSessionsTable,
    PaymentSession,
    $$PaymentSessionsTableFilterComposer,
    $$PaymentSessionsTableOrderingComposer,
    $$PaymentSessionsTableCreateCompanionBuilder,
    $$PaymentSessionsTableUpdateCompanionBuilder,
    (
      PaymentSession,
      BaseReferences<_$AppDatabase, $PaymentSessionsTable, PaymentSession>
    ),
    PaymentSession,
    PrefetchHooks Function()> {
  $$PaymentSessionsTableTableManager(
      _$AppDatabase db, $PaymentSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PaymentSessionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PaymentSessionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> invoiceId = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<String?> paymentType = const Value.absent(),
            Value<String?> invoiceUrl = const Value.absent(),
            Value<String?> invoiceStatus = const Value.absent(),
            Value<String?> shipmentId = const Value.absent(),
            Value<String?> labelUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastCheckedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentSessionsCompanion(
            invoiceId: invoiceId,
            orderId: orderId,
            paymentType: paymentType,
            invoiceUrl: invoiceUrl,
            invoiceStatus: invoiceStatus,
            shipmentId: shipmentId,
            labelUrl: labelUrl,
            createdAt: createdAt,
            lastCheckedAt: lastCheckedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String invoiceId,
            required int orderId,
            Value<String?> paymentType = const Value.absent(),
            Value<String?> invoiceUrl = const Value.absent(),
            Value<String?> invoiceStatus = const Value.absent(),
            Value<String?> shipmentId = const Value.absent(),
            Value<String?> labelUrl = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastCheckedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentSessionsCompanion.insert(
            invoiceId: invoiceId,
            orderId: orderId,
            paymentType: paymentType,
            invoiceUrl: invoiceUrl,
            invoiceStatus: invoiceStatus,
            shipmentId: shipmentId,
            labelUrl: labelUrl,
            createdAt: createdAt,
            lastCheckedAt: lastCheckedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentSessionsTable,
    PaymentSession,
    $$PaymentSessionsTableFilterComposer,
    $$PaymentSessionsTableOrderingComposer,
    $$PaymentSessionsTableCreateCompanionBuilder,
    $$PaymentSessionsTableUpdateCompanionBuilder,
    (
      PaymentSession,
      BaseReferences<_$AppDatabase, $PaymentSessionsTable, PaymentSession>
    ),
    PaymentSession,
    PrefetchHooks Function()>;
typedef $$OrderHistorySnapshotsTableCreateCompanionBuilder
    = OrderHistorySnapshotsCompanion Function({
  Value<int> userId,
  required String payload,
  required DateTime updatedAt,
});
typedef $$OrderHistorySnapshotsTableUpdateCompanionBuilder
    = OrderHistorySnapshotsCompanion Function({
  Value<int> userId,
  Value<String> payload,
  Value<DateTime> updatedAt,
});

class $$OrderHistorySnapshotsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $OrderHistorySnapshotsTable> {
  $$OrderHistorySnapshotsTableFilterComposer(super.$state);
  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OrderHistorySnapshotsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $OrderHistorySnapshotsTable> {
  $$OrderHistorySnapshotsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$OrderHistorySnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderHistorySnapshotsTable,
    OrderHistorySnapshot,
    $$OrderHistorySnapshotsTableFilterComposer,
    $$OrderHistorySnapshotsTableOrderingComposer,
    $$OrderHistorySnapshotsTableCreateCompanionBuilder,
    $$OrderHistorySnapshotsTableUpdateCompanionBuilder,
    (
      OrderHistorySnapshot,
      BaseReferences<_$AppDatabase, $OrderHistorySnapshotsTable,
          OrderHistorySnapshot>
    ),
    OrderHistorySnapshot,
    PrefetchHooks Function()> {
  $$OrderHistorySnapshotsTableTableManager(
      _$AppDatabase db, $OrderHistorySnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$OrderHistorySnapshotsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$OrderHistorySnapshotsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> userId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              OrderHistorySnapshotsCompanion(
            userId: userId,
            payload: payload,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> userId = const Value.absent(),
            required String payload,
            required DateTime updatedAt,
          }) =>
              OrderHistorySnapshotsCompanion.insert(
            userId: userId,
            payload: payload,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderHistorySnapshotsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $OrderHistorySnapshotsTable,
        OrderHistorySnapshot,
        $$OrderHistorySnapshotsTableFilterComposer,
        $$OrderHistorySnapshotsTableOrderingComposer,
        $$OrderHistorySnapshotsTableCreateCompanionBuilder,
        $$OrderHistorySnapshotsTableUpdateCompanionBuilder,
        (
          OrderHistorySnapshot,
          BaseReferences<_$AppDatabase, $OrderHistorySnapshotsTable,
              OrderHistorySnapshot>
        ),
        OrderHistorySnapshot,
        PrefetchHooks Function()>;
typedef $$NotificationSnapshotsTableCreateCompanionBuilder
    = NotificationSnapshotsCompanion Function({
  Value<int> userId,
  required String payload,
  required DateTime updatedAt,
});
typedef $$NotificationSnapshotsTableUpdateCompanionBuilder
    = NotificationSnapshotsCompanion Function({
  Value<int> userId,
  Value<String> payload,
  Value<DateTime> updatedAt,
});

class $$NotificationSnapshotsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $NotificationSnapshotsTable> {
  $$NotificationSnapshotsTableFilterComposer(super.$state);
  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$NotificationSnapshotsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $NotificationSnapshotsTable> {
  $$NotificationSnapshotsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$NotificationSnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationSnapshotsTable,
    NotificationSnapshot,
    $$NotificationSnapshotsTableFilterComposer,
    $$NotificationSnapshotsTableOrderingComposer,
    $$NotificationSnapshotsTableCreateCompanionBuilder,
    $$NotificationSnapshotsTableUpdateCompanionBuilder,
    (
      NotificationSnapshot,
      BaseReferences<_$AppDatabase, $NotificationSnapshotsTable,
          NotificationSnapshot>
    ),
    NotificationSnapshot,
    PrefetchHooks Function()> {
  $$NotificationSnapshotsTableTableManager(
      _$AppDatabase db, $NotificationSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$NotificationSnapshotsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$NotificationSnapshotsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> userId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              NotificationSnapshotsCompanion(
            userId: userId,
            payload: payload,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> userId = const Value.absent(),
            required String payload,
            required DateTime updatedAt,
          }) =>
              NotificationSnapshotsCompanion.insert(
            userId: userId,
            payload: payload,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationSnapshotsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $NotificationSnapshotsTable,
        NotificationSnapshot,
        $$NotificationSnapshotsTableFilterComposer,
        $$NotificationSnapshotsTableOrderingComposer,
        $$NotificationSnapshotsTableCreateCompanionBuilder,
        $$NotificationSnapshotsTableUpdateCompanionBuilder,
        (
          NotificationSnapshot,
          BaseReferences<_$AppDatabase, $NotificationSnapshotsTable,
              NotificationSnapshot>
        ),
        NotificationSnapshot,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StorefrontCacheTableTableManager get storefrontCache =>
      $$StorefrontCacheTableTableManager(_db, _db.storefrontCache);
  $$LocalCartItemsTableTableManager get localCartItems =>
      $$LocalCartItemsTableTableManager(_db, _db.localCartItems);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
  $$PaymentSessionsTableTableManager get paymentSessions =>
      $$PaymentSessionsTableTableManager(_db, _db.paymentSessions);
  $$OrderHistorySnapshotsTableTableManager get orderHistorySnapshots =>
      $$OrderHistorySnapshotsTableTableManager(_db, _db.orderHistorySnapshots);
  $$NotificationSnapshotsTableTableManager get notificationSnapshots =>
      $$NotificationSnapshotsTableTableManager(_db, _db.notificationSnapshots);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
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
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
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
    defaultValue: Constant(DateTime.now()),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    createdAt,
    updatedAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSession extends DataClass implements Insertable<ChatSession> {
  int id;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive;
  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
    );
  }

  factory ChatSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSession(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  factory ChatSession.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => ChatSession.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  ChatSession copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => ChatSession(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
  );
  ChatSession copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSession(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSession(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, updatedAt, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSession &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSession> {
  Value<int> id;
  Value<String> title;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  Value<bool> isActive;
  ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : title = Value(title);
  static Insertable<ChatSession> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
    });
  }

  ChatSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
  }) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_sessions (id)',
    ),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  static const VerificationMeta _referencesMeta = const VerificationMeta(
    'references',
  );
  @override
  late final GeneratedColumn<String> references = GeneratedColumn<String>(
    'references',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    message,
    messageType,
    timestamp,
    references,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('references')) {
      context.handle(
        _referencesMeta,
        references.isAcceptableOrUnknown(data['references']!, _referencesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      references: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}references'],
      ),
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageData extends DataClass implements Insertable<ChatMessageData> {
  int id;
  int sessionId;
  String message;
  String messageType;
  DateTime timestamp;
  String? references;
  ChatMessageData({
    required this.id,
    required this.sessionId,
    required this.message,
    required this.messageType,
    required this.timestamp,
    this.references,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['message'] = Variable<String>(message);
    map['message_type'] = Variable<String>(messageType);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || references != null) {
      map['references'] = Variable<String>(references);
    }
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      message: Value(message),
      messageType: Value(messageType),
      timestamp: Value(timestamp),
      references: references == null && nullToAbsent
          ? const Value.absent()
          : Value(references),
    );
  }

  factory ChatMessageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      message: serializer.fromJson<String>(json['message']),
      messageType: serializer.fromJson<String>(json['messageType']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      references: serializer.fromJson<String?>(json['references']),
    );
  }
  factory ChatMessageData.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => ChatMessageData.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'message': serializer.toJson<String>(message),
      'messageType': serializer.toJson<String>(messageType),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'references': serializer.toJson<String?>(references),
    };
  }

  ChatMessageData copyWith({
    int? id,
    int? sessionId,
    String? message,
    String? messageType,
    DateTime? timestamp,
    Value<String?> references = const Value.absent(),
  }) => ChatMessageData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    message: message ?? this.message,
    messageType: messageType ?? this.messageType,
    timestamp: timestamp ?? this.timestamp,
    references: references.present ? references.value : this.references,
  );
  ChatMessageData copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      message: data.message.present ? data.message.value : this.message,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      references: data.references.present
          ? data.references.value
          : this.references,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('message: $message, ')
          ..write('messageType: $messageType, ')
          ..write('timestamp: $timestamp, ')
          ..write('references: $references')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, message, messageType, timestamp, references);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.message == this.message &&
          other.messageType == this.messageType &&
          other.timestamp == this.timestamp &&
          other.references == this.references);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageData> {
  Value<int> id;
  Value<int> sessionId;
  Value<String> message;
  Value<String> messageType;
  Value<DateTime> timestamp;
  Value<String?> references;
  ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.message = const Value.absent(),
    this.messageType = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.references = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String message,
    required String messageType,
    this.timestamp = const Value.absent(),
    this.references = const Value.absent(),
  }) : sessionId = Value(sessionId),
       message = Value(message),
       messageType = Value(messageType);
  static Insertable<ChatMessageData> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? message,
    Expression<String>? messageType,
    Expression<DateTime>? timestamp,
    Expression<String>? references,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (message != null) 'message': message,
      if (messageType != null) 'message_type': messageType,
      if (timestamp != null) 'timestamp': timestamp,
      if (references != null) 'references': references,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? message,
    Value<String>? messageType,
    Value<DateTime>? timestamp,
    Value<String?>? references,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      references: references ?? this.references,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (references.present) {
      map['references'] = Variable<String>(references.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('message: $message, ')
          ..write('messageType: $messageType, ')
          ..write('timestamp: $timestamp, ')
          ..write('references: $references')
          ..write(')'))
        .toString();
  }
}

class $GoalPresetsTable extends GoalPresets
    with TableInfo<$GoalPresetsTable, GoalPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
    'goal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultTargetCountMeta =
      const VerificationMeta('defaultTargetCount');
  @override
  late final GeneratedColumn<int> defaultTargetCount = GeneratedColumn<int>(
    'default_target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 6,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRecommendedMeta = const VerificationMeta(
    'isRecommended',
  );
  @override
  late final GeneratedColumn<bool> isRecommended = GeneratedColumn<bool>(
    'is_recommended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recommended" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
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
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalType,
    title,
    description,
    defaultTargetCount,
    icon,
    color,
    isRecommended,
    isActive,
    isCustom,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_goalTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('default_target_count')) {
      context.handle(
        _defaultTargetCountMeta,
        defaultTargetCount.isAcceptableOrUnknown(
          data['default_target_count']!,
          _defaultTargetCountMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_recommended')) {
      context.handle(
        _isRecommendedMeta,
        isRecommended.isAcceptableOrUnknown(
          data['is_recommended']!,
          _isRecommendedMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      defaultTargetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_target_count'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      isRecommended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recommended'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GoalPresetsTable createAlias(String alias) {
    return $GoalPresetsTable(attachedDatabase, alias);
  }
}

class GoalPreset extends DataClass implements Insertable<GoalPreset> {
  int id;
  String goalType;
  String title;
  String description;
  int defaultTargetCount;
  String icon;
  String color;
  bool isRecommended;
  bool isActive;
  bool isCustom;
  DateTime createdAt;
  DateTime updatedAt;
  GoalPreset({
    required this.id,
    required this.goalType,
    required this.title,
    required this.description,
    required this.defaultTargetCount,
    required this.icon,
    required this.color,
    required this.isRecommended,
    required this.isActive,
    required this.isCustom,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_type'] = Variable<String>(goalType);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['default_target_count'] = Variable<int>(defaultTargetCount);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['is_recommended'] = Variable<bool>(isRecommended);
    map['is_active'] = Variable<bool>(isActive);
    map['is_custom'] = Variable<bool>(isCustom);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalPresetsCompanion toCompanion(bool nullToAbsent) {
    return GoalPresetsCompanion(
      id: Value(id),
      goalType: Value(goalType),
      title: Value(title),
      description: Value(description),
      defaultTargetCount: Value(defaultTargetCount),
      icon: Value(icon),
      color: Value(color),
      isRecommended: Value(isRecommended),
      isActive: Value(isActive),
      isCustom: Value(isCustom),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GoalPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalPreset(
      id: serializer.fromJson<int>(json['id']),
      goalType: serializer.fromJson<String>(json['goalType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      defaultTargetCount: serializer.fromJson<int>(json['defaultTargetCount']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      isRecommended: serializer.fromJson<bool>(json['isRecommended']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  factory GoalPreset.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => GoalPreset.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalType': serializer.toJson<String>(goalType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'defaultTargetCount': serializer.toJson<int>(defaultTargetCount),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'isRecommended': serializer.toJson<bool>(isRecommended),
      'isActive': serializer.toJson<bool>(isActive),
      'isCustom': serializer.toJson<bool>(isCustom),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GoalPreset copyWith({
    int? id,
    String? goalType,
    String? title,
    String? description,
    int? defaultTargetCount,
    String? icon,
    String? color,
    bool? isRecommended,
    bool? isActive,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GoalPreset(
    id: id ?? this.id,
    goalType: goalType ?? this.goalType,
    title: title ?? this.title,
    description: description ?? this.description,
    defaultTargetCount: defaultTargetCount ?? this.defaultTargetCount,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isRecommended: isRecommended ?? this.isRecommended,
    isActive: isActive ?? this.isActive,
    isCustom: isCustom ?? this.isCustom,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GoalPreset copyWithCompanion(GoalPresetsCompanion data) {
    return GoalPreset(
      id: data.id.present ? data.id.value : this.id,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      defaultTargetCount: data.defaultTargetCount.present
          ? data.defaultTargetCount.value
          : this.defaultTargetCount,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isRecommended: data.isRecommended.present
          ? data.isRecommended.value
          : this.isRecommended,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalPreset(')
          ..write('id: $id, ')
          ..write('goalType: $goalType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('defaultTargetCount: $defaultTargetCount, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isRecommended: $isRecommended, ')
          ..write('isActive: $isActive, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalType,
    title,
    description,
    defaultTargetCount,
    icon,
    color,
    isRecommended,
    isActive,
    isCustom,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalPreset &&
          other.id == this.id &&
          other.goalType == this.goalType &&
          other.title == this.title &&
          other.description == this.description &&
          other.defaultTargetCount == this.defaultTargetCount &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isRecommended == this.isRecommended &&
          other.isActive == this.isActive &&
          other.isCustom == this.isCustom &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalPresetsCompanion extends UpdateCompanion<GoalPreset> {
  Value<int> id;
  Value<String> goalType;
  Value<String> title;
  Value<String> description;
  Value<int> defaultTargetCount;
  Value<String> icon;
  Value<String> color;
  Value<bool> isRecommended;
  Value<bool> isActive;
  Value<bool> isCustom;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  GoalPresetsCompanion({
    this.id = const Value.absent(),
    this.goalType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.defaultTargetCount = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isRecommended = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GoalPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String goalType,
    required String title,
    required String description,
    this.defaultTargetCount = const Value.absent(),
    required String icon,
    required String color,
    this.isRecommended = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : goalType = Value(goalType),
       title = Value(title),
       description = Value(description),
       icon = Value(icon),
       color = Value(color);
  static Insertable<GoalPreset> custom({
    Expression<int>? id,
    Expression<String>? goalType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? defaultTargetCount,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isRecommended,
    Expression<bool>? isActive,
    Expression<bool>? isCustom,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalType != null) 'goal_type': goalType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (defaultTargetCount != null)
        'default_target_count': defaultTargetCount,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isRecommended != null) 'is_recommended': isRecommended,
      if (isActive != null) 'is_active': isActive,
      if (isCustom != null) 'is_custom': isCustom,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GoalPresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? goalType,
    Value<String>? title,
    Value<String>? description,
    Value<int>? defaultTargetCount,
    Value<String>? icon,
    Value<String>? color,
    Value<bool>? isRecommended,
    Value<bool>? isActive,
    Value<bool>? isCustom,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return GoalPresetsCompanion(
      id: id ?? this.id,
      goalType: goalType ?? this.goalType,
      title: title ?? this.title,
      description: description ?? this.description,
      defaultTargetCount: defaultTargetCount ?? this.defaultTargetCount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRecommended: isRecommended ?? this.isRecommended,
      isActive: isActive ?? this.isActive,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (defaultTargetCount.present) {
      map['default_target_count'] = Variable<int>(defaultTargetCount.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isRecommended.present) {
      map['is_recommended'] = Variable<bool>(isRecommended.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalPresetsCompanion(')
          ..write('id: $id, ')
          ..write('goalType: $goalType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('defaultTargetCount: $defaultTargetCount, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isRecommended: $isRecommended, ')
          ..write('isActive: $isActive, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DailyGoalsTable extends DailyGoals
    with TableInfo<$DailyGoalsTable, DailyGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<int> presetId = GeneratedColumn<int>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goal_presets (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentCountMeta = const VerificationMeta(
    'currentCount',
  );
  @override
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
    'current_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _customNoteMeta = const VerificationMeta(
    'customNote',
  );
  @override
  late final GeneratedColumn<String> customNote = GeneratedColumn<String>(
    'custom_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
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
    defaultValue: Constant(DateTime.now()),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    presetId,
    title,
    description,
    targetCount,
    currentCount,
    status,
    date,
    isActive,
    customNote,
    createdAt,
    updatedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    }
    if (data.containsKey('current_count')) {
      context.handle(
        _currentCountMeta,
        currentCount.isAcceptableOrUnknown(
          data['current_count']!,
          _currentCountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('custom_note')) {
      context.handle(
        _customNoteMeta,
        customNote.isAcceptableOrUnknown(data['custom_note']!, _customNoteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preset_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      currentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      customNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $DailyGoalsTable createAlias(String alias) {
    return $DailyGoalsTable(attachedDatabase, alias);
  }
}

class DailyGoal extends DataClass implements Insertable<DailyGoal> {
  int id;
  String goalId;
  int presetId;
  String title;
  String description;
  int targetCount;
  int currentCount;
  String status;
  DateTime date;
  bool isActive;
  String? customNote;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? completedAt;
  DailyGoal({
    required this.id,
    required this.goalId,
    required this.presetId,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.currentCount,
    required this.status,
    required this.date,
    required this.isActive,
    this.customNote,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<String>(goalId);
    map['preset_id'] = Variable<int>(presetId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['target_count'] = Variable<int>(targetCount);
    map['current_count'] = Variable<int>(currentCount);
    map['status'] = Variable<String>(status);
    map['date'] = Variable<DateTime>(date);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || customNote != null) {
      map['custom_note'] = Variable<String>(customNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DailyGoalsCompanion toCompanion(bool nullToAbsent) {
    return DailyGoalsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      presetId: Value(presetId),
      title: Value(title),
      description: Value(description),
      targetCount: Value(targetCount),
      currentCount: Value(currentCount),
      status: Value(status),
      date: Value(date),
      isActive: Value(isActive),
      customNote: customNote == null && nullToAbsent
          ? const Value.absent()
          : Value(customNote),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory DailyGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyGoal(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<String>(json['goalId']),
      presetId: serializer.fromJson<int>(json['presetId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      currentCount: serializer.fromJson<int>(json['currentCount']),
      status: serializer.fromJson<String>(json['status']),
      date: serializer.fromJson<DateTime>(json['date']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      customNote: serializer.fromJson<String?>(json['customNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  factory DailyGoal.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => DailyGoal.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<String>(goalId),
      'presetId': serializer.toJson<int>(presetId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'targetCount': serializer.toJson<int>(targetCount),
      'currentCount': serializer.toJson<int>(currentCount),
      'status': serializer.toJson<String>(status),
      'date': serializer.toJson<DateTime>(date),
      'isActive': serializer.toJson<bool>(isActive),
      'customNote': serializer.toJson<String?>(customNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  DailyGoal copyWith({
    int? id,
    String? goalId,
    int? presetId,
    String? title,
    String? description,
    int? targetCount,
    int? currentCount,
    String? status,
    DateTime? date,
    bool? isActive,
    Value<String?> customNote = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => DailyGoal(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    presetId: presetId ?? this.presetId,
    title: title ?? this.title,
    description: description ?? this.description,
    targetCount: targetCount ?? this.targetCount,
    currentCount: currentCount ?? this.currentCount,
    status: status ?? this.status,
    date: date ?? this.date,
    isActive: isActive ?? this.isActive,
    customNote: customNote.present ? customNote.value : this.customNote,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  DailyGoal copyWithCompanion(DailyGoalsCompanion data) {
    return DailyGoal(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      currentCount: data.currentCount.present
          ? data.currentCount.value
          : this.currentCount,
      status: data.status.present ? data.status.value : this.status,
      date: data.date.present ? data.date.value : this.date,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      customNote: data.customNote.present
          ? data.customNote.value
          : this.customNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoal(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('presetId: $presetId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetCount: $targetCount, ')
          ..write('currentCount: $currentCount, ')
          ..write('status: $status, ')
          ..write('date: $date, ')
          ..write('isActive: $isActive, ')
          ..write('customNote: $customNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalId,
    presetId,
    title,
    description,
    targetCount,
    currentCount,
    status,
    date,
    isActive,
    customNote,
    createdAt,
    updatedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyGoal &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.presetId == this.presetId &&
          other.title == this.title &&
          other.description == this.description &&
          other.targetCount == this.targetCount &&
          other.currentCount == this.currentCount &&
          other.status == this.status &&
          other.date == this.date &&
          other.isActive == this.isActive &&
          other.customNote == this.customNote &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}

class DailyGoalsCompanion extends UpdateCompanion<DailyGoal> {
  Value<int> id;
  Value<String> goalId;
  Value<int> presetId;
  Value<String> title;
  Value<String> description;
  Value<int> targetCount;
  Value<int> currentCount;
  Value<String> status;
  Value<DateTime> date;
  Value<bool> isActive;
  Value<String?> customNote;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  Value<DateTime?> completedAt;
  DailyGoalsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.presetId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.status = const Value.absent(),
    this.date = const Value.absent(),
    this.isActive = const Value.absent(),
    this.customNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  DailyGoalsCompanion.insert({
    this.id = const Value.absent(),
    required String goalId,
    required int presetId,
    required String title,
    required String description,
    this.targetCount = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime date,
    this.isActive = const Value.absent(),
    this.customNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : goalId = Value(goalId),
       presetId = Value(presetId),
       title = Value(title),
       description = Value(description),
       date = Value(date);
  static Insertable<DailyGoal> custom({
    Expression<int>? id,
    Expression<String>? goalId,
    Expression<int>? presetId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? targetCount,
    Expression<int>? currentCount,
    Expression<String>? status,
    Expression<DateTime>? date,
    Expression<bool>? isActive,
    Expression<String>? customNote,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (presetId != null) 'preset_id': presetId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (targetCount != null) 'target_count': targetCount,
      if (currentCount != null) 'current_count': currentCount,
      if (status != null) 'status': status,
      if (date != null) 'date': date,
      if (isActive != null) 'is_active': isActive,
      if (customNote != null) 'custom_note': customNote,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  DailyGoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? goalId,
    Value<int>? presetId,
    Value<String>? title,
    Value<String>? description,
    Value<int>? targetCount,
    Value<int>? currentCount,
    Value<String>? status,
    Value<DateTime>? date,
    Value<bool>? isActive,
    Value<String?>? customNote,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
  }) {
    return DailyGoalsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      presetId: presetId ?? this.presetId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      status: status ?? this.status,
      date: date ?? this.date,
      isActive: isActive ?? this.isActive,
      customNote: customNote ?? this.customNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<int>(presetId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (customNote.present) {
      map['custom_note'] = Variable<String>(customNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('presetId: $presetId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetCount: $targetCount, ')
          ..write('currentCount: $currentCount, ')
          ..write('status: $status, ')
          ..write('date: $date, ')
          ..write('isActive: $isActive, ')
          ..write('customNote: $customNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $GoalProgressTable extends GoalProgress
    with TableInfo<$GoalProgressTable, GoalProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dailyGoalIdMeta = const VerificationMeta(
    'dailyGoalId',
  );
  @override
  late final GeneratedColumn<int> dailyGoalId = GeneratedColumn<int>(
    'daily_goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES daily_goals (id)',
    ),
  );
  static const VerificationMeta _incrementValueMeta = const VerificationMeta(
    'incrementValue',
  );
  @override
  late final GeneratedColumn<int> incrementValue = GeneratedColumn<int>(
    'increment_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyGoalId,
    incrementValue,
    note,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_goal_id')) {
      context.handle(
        _dailyGoalIdMeta,
        dailyGoalId.isAcceptableOrUnknown(
          data['daily_goal_id']!,
          _dailyGoalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyGoalIdMeta);
    }
    if (data.containsKey('increment_value')) {
      context.handle(
        _incrementValueMeta,
        incrementValue.isAcceptableOrUnknown(
          data['increment_value']!,
          _incrementValueMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailyGoalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_id'],
      )!,
      incrementValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}increment_value'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $GoalProgressTable createAlias(String alias) {
    return $GoalProgressTable(attachedDatabase, alias);
  }
}

class GoalProgressData extends DataClass
    implements Insertable<GoalProgressData> {
  int id;
  int dailyGoalId;
  int incrementValue;
  String? note;
  DateTime timestamp;
  GoalProgressData({
    required this.id,
    required this.dailyGoalId,
    required this.incrementValue,
    this.note,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_goal_id'] = Variable<int>(dailyGoalId);
    map['increment_value'] = Variable<int>(incrementValue);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  GoalProgressCompanion toCompanion(bool nullToAbsent) {
    return GoalProgressCompanion(
      id: Value(id),
      dailyGoalId: Value(dailyGoalId),
      incrementValue: Value(incrementValue),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      timestamp: Value(timestamp),
    );
  }

  factory GoalProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalProgressData(
      id: serializer.fromJson<int>(json['id']),
      dailyGoalId: serializer.fromJson<int>(json['dailyGoalId']),
      incrementValue: serializer.fromJson<int>(json['incrementValue']),
      note: serializer.fromJson<String?>(json['note']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  factory GoalProgressData.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => GoalProgressData.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyGoalId': serializer.toJson<int>(dailyGoalId),
      'incrementValue': serializer.toJson<int>(incrementValue),
      'note': serializer.toJson<String?>(note),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  GoalProgressData copyWith({
    int? id,
    int? dailyGoalId,
    int? incrementValue,
    Value<String?> note = const Value.absent(),
    DateTime? timestamp,
  }) => GoalProgressData(
    id: id ?? this.id,
    dailyGoalId: dailyGoalId ?? this.dailyGoalId,
    incrementValue: incrementValue ?? this.incrementValue,
    note: note.present ? note.value : this.note,
    timestamp: timestamp ?? this.timestamp,
  );
  GoalProgressData copyWithCompanion(GoalProgressCompanion data) {
    return GoalProgressData(
      id: data.id.present ? data.id.value : this.id,
      dailyGoalId: data.dailyGoalId.present
          ? data.dailyGoalId.value
          : this.dailyGoalId,
      incrementValue: data.incrementValue.present
          ? data.incrementValue.value
          : this.incrementValue,
      note: data.note.present ? data.note.value : this.note,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalProgressData(')
          ..write('id: $id, ')
          ..write('dailyGoalId: $dailyGoalId, ')
          ..write('incrementValue: $incrementValue, ')
          ..write('note: $note, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dailyGoalId, incrementValue, note, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalProgressData &&
          other.id == this.id &&
          other.dailyGoalId == this.dailyGoalId &&
          other.incrementValue == this.incrementValue &&
          other.note == this.note &&
          other.timestamp == this.timestamp);
}

class GoalProgressCompanion extends UpdateCompanion<GoalProgressData> {
  Value<int> id;
  Value<int> dailyGoalId;
  Value<int> incrementValue;
  Value<String?> note;
  Value<DateTime> timestamp;
  GoalProgressCompanion({
    this.id = const Value.absent(),
    this.dailyGoalId = const Value.absent(),
    this.incrementValue = const Value.absent(),
    this.note = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  GoalProgressCompanion.insert({
    this.id = const Value.absent(),
    required int dailyGoalId,
    this.incrementValue = const Value.absent(),
    this.note = const Value.absent(),
    this.timestamp = const Value.absent(),
  }) : dailyGoalId = Value(dailyGoalId);
  static Insertable<GoalProgressData> custom({
    Expression<int>? id,
    Expression<int>? dailyGoalId,
    Expression<int>? incrementValue,
    Expression<String>? note,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyGoalId != null) 'daily_goal_id': dailyGoalId,
      if (incrementValue != null) 'increment_value': incrementValue,
      if (note != null) 'note': note,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  GoalProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? dailyGoalId,
    Value<int>? incrementValue,
    Value<String?>? note,
    Value<DateTime>? timestamp,
  }) {
    return GoalProgressCompanion(
      id: id ?? this.id,
      dailyGoalId: dailyGoalId ?? this.dailyGoalId,
      incrementValue: incrementValue ?? this.incrementValue,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyGoalId.present) {
      map['daily_goal_id'] = Variable<int>(dailyGoalId.value);
    }
    if (incrementValue.present) {
      map['increment_value'] = Variable<int>(incrementValue.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalProgressCompanion(')
          ..write('id: $id, ')
          ..write('dailyGoalId: $dailyGoalId, ')
          ..write('incrementValue: $incrementValue, ')
          ..write('note: $note, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $GoalHistoryTable extends GoalHistory
    with TableInfo<$GoalHistoryTable, GoalHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
    'goal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedCountMeta = const VerificationMeta(
    'achievedCount',
  );
  @override
  late final GeneratedColumn<int> achievedCount = GeneratedColumn<int>(
    'achieved_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasCompletedMeta = const VerificationMeta(
    'wasCompleted',
  );
  @override
  late final GeneratedColumn<bool> wasCompleted = GeneratedColumn<bool>(
    'was_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _streakCountMeta = const VerificationMeta(
    'streakCount',
  );
  @override
  late final GeneratedColumn<int> streakCount = GeneratedColumn<int>(
    'streak_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalType,
    title,
    date,
    targetCount,
    achievedCount,
    wasCompleted,
    streakCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_goalTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('achieved_count')) {
      context.handle(
        _achievedCountMeta,
        achievedCount.isAcceptableOrUnknown(
          data['achieved_count']!,
          _achievedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievedCountMeta);
    }
    if (data.containsKey('was_completed')) {
      context.handle(
        _wasCompletedMeta,
        wasCompleted.isAcceptableOrUnknown(
          data['was_completed']!,
          _wasCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wasCompletedMeta);
    }
    if (data.containsKey('streak_count')) {
      context.handle(
        _streakCountMeta,
        streakCount.isAcceptableOrUnknown(
          data['streak_count']!,
          _streakCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      achievedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_count'],
      )!,
      wasCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_completed'],
      )!,
      streakCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalHistoryTable createAlias(String alias) {
    return $GoalHistoryTable(attachedDatabase, alias);
  }
}

class GoalHistoryData extends DataClass implements Insertable<GoalHistoryData> {
  int id;
  String goalType;
  String title;
  DateTime date;
  int targetCount;
  int achievedCount;
  bool wasCompleted;
  int streakCount;
  DateTime createdAt;
  GoalHistoryData({
    required this.id,
    required this.goalType,
    required this.title,
    required this.date,
    required this.targetCount,
    required this.achievedCount,
    required this.wasCompleted,
    required this.streakCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_type'] = Variable<String>(goalType);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['target_count'] = Variable<int>(targetCount);
    map['achieved_count'] = Variable<int>(achievedCount);
    map['was_completed'] = Variable<bool>(wasCompleted);
    map['streak_count'] = Variable<int>(streakCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalHistoryCompanion toCompanion(bool nullToAbsent) {
    return GoalHistoryCompanion(
      id: Value(id),
      goalType: Value(goalType),
      title: Value(title),
      date: Value(date),
      targetCount: Value(targetCount),
      achievedCount: Value(achievedCount),
      wasCompleted: Value(wasCompleted),
      streakCount: Value(streakCount),
      createdAt: Value(createdAt),
    );
  }

  factory GoalHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalHistoryData(
      id: serializer.fromJson<int>(json['id']),
      goalType: serializer.fromJson<String>(json['goalType']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      achievedCount: serializer.fromJson<int>(json['achievedCount']),
      wasCompleted: serializer.fromJson<bool>(json['wasCompleted']),
      streakCount: serializer.fromJson<int>(json['streakCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  factory GoalHistoryData.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => GoalHistoryData.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalType': serializer.toJson<String>(goalType),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'targetCount': serializer.toJson<int>(targetCount),
      'achievedCount': serializer.toJson<int>(achievedCount),
      'wasCompleted': serializer.toJson<bool>(wasCompleted),
      'streakCount': serializer.toJson<int>(streakCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalHistoryData copyWith({
    int? id,
    String? goalType,
    String? title,
    DateTime? date,
    int? targetCount,
    int? achievedCount,
    bool? wasCompleted,
    int? streakCount,
    DateTime? createdAt,
  }) => GoalHistoryData(
    id: id ?? this.id,
    goalType: goalType ?? this.goalType,
    title: title ?? this.title,
    date: date ?? this.date,
    targetCount: targetCount ?? this.targetCount,
    achievedCount: achievedCount ?? this.achievedCount,
    wasCompleted: wasCompleted ?? this.wasCompleted,
    streakCount: streakCount ?? this.streakCount,
    createdAt: createdAt ?? this.createdAt,
  );
  GoalHistoryData copyWithCompanion(GoalHistoryCompanion data) {
    return GoalHistoryData(
      id: data.id.present ? data.id.value : this.id,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      achievedCount: data.achievedCount.present
          ? data.achievedCount.value
          : this.achievedCount,
      wasCompleted: data.wasCompleted.present
          ? data.wasCompleted.value
          : this.wasCompleted,
      streakCount: data.streakCount.present
          ? data.streakCount.value
          : this.streakCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalHistoryData(')
          ..write('id: $id, ')
          ..write('goalType: $goalType, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('targetCount: $targetCount, ')
          ..write('achievedCount: $achievedCount, ')
          ..write('wasCompleted: $wasCompleted, ')
          ..write('streakCount: $streakCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalType,
    title,
    date,
    targetCount,
    achievedCount,
    wasCompleted,
    streakCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalHistoryData &&
          other.id == this.id &&
          other.goalType == this.goalType &&
          other.title == this.title &&
          other.date == this.date &&
          other.targetCount == this.targetCount &&
          other.achievedCount == this.achievedCount &&
          other.wasCompleted == this.wasCompleted &&
          other.streakCount == this.streakCount &&
          other.createdAt == this.createdAt);
}

class GoalHistoryCompanion extends UpdateCompanion<GoalHistoryData> {
  Value<int> id;
  Value<String> goalType;
  Value<String> title;
  Value<DateTime> date;
  Value<int> targetCount;
  Value<int> achievedCount;
  Value<bool> wasCompleted;
  Value<int> streakCount;
  Value<DateTime> createdAt;
  GoalHistoryCompanion({
    this.id = const Value.absent(),
    this.goalType = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.achievedCount = const Value.absent(),
    this.wasCompleted = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String goalType,
    required String title,
    required DateTime date,
    required int targetCount,
    required int achievedCount,
    required bool wasCompleted,
    this.streakCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : goalType = Value(goalType),
       title = Value(title),
       date = Value(date),
       targetCount = Value(targetCount),
       achievedCount = Value(achievedCount),
       wasCompleted = Value(wasCompleted);
  static Insertable<GoalHistoryData> custom({
    Expression<int>? id,
    Expression<String>? goalType,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<int>? targetCount,
    Expression<int>? achievedCount,
    Expression<bool>? wasCompleted,
    Expression<int>? streakCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalType != null) 'goal_type': goalType,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (targetCount != null) 'target_count': targetCount,
      if (achievedCount != null) 'achieved_count': achievedCount,
      if (wasCompleted != null) 'was_completed': wasCompleted,
      if (streakCount != null) 'streak_count': streakCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? goalType,
    Value<String>? title,
    Value<DateTime>? date,
    Value<int>? targetCount,
    Value<int>? achievedCount,
    Value<bool>? wasCompleted,
    Value<int>? streakCount,
    Value<DateTime>? createdAt,
  }) {
    return GoalHistoryCompanion(
      id: id ?? this.id,
      goalType: goalType ?? this.goalType,
      title: title ?? this.title,
      date: date ?? this.date,
      targetCount: targetCount ?? this.targetCount,
      achievedCount: achievedCount ?? this.achievedCount,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      streakCount: streakCount ?? this.streakCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (achievedCount.present) {
      map['achieved_count'] = Variable<int>(achievedCount.value);
    }
    if (wasCompleted.present) {
      map['was_completed'] = Variable<bool>(wasCompleted.value);
    }
    if (streakCount.present) {
      map['streak_count'] = Variable<int>(streakCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalHistoryCompanion(')
          ..write('id: $id, ')
          ..write('goalType: $goalType, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('targetCount: $targetCount, ')
          ..write('achievedCount: $achievedCount, ')
          ..write('wasCompleted: $wasCompleted, ')
          ..write('streakCount: $streakCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GoalNotificationsTable extends GoalNotifications
    with TableInfo<$GoalNotificationsTable, GoalNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<int> presetId = GeneratedColumn<int>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goal_presets (id)',
    ),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderDaysMeta = const VerificationMeta(
    'reminderDays',
  );
  @override
  late final GeneratedColumn<String> reminderDays = GeneratedColumn<String>(
    'reminder_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customMessageMeta = const VerificationMeta(
    'customMessage',
  );
  @override
  late final GeneratedColumn<String> customMessage = GeneratedColumn<String>(
    'custom_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDailyMeta = const VerificationMeta(
    'isDaily',
  );
  @override
  late final GeneratedColumn<bool> isDaily = GeneratedColumn<bool>(
    'is_daily',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_daily" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
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
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    presetId,
    isEnabled,
    reminderTime,
    reminderDays,
    customMessage,
    isDaily,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderTimeMeta);
    }
    if (data.containsKey('reminder_days')) {
      context.handle(
        _reminderDaysMeta,
        reminderDays.isAcceptableOrUnknown(
          data['reminder_days']!,
          _reminderDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderDaysMeta);
    }
    if (data.containsKey('custom_message')) {
      context.handle(
        _customMessageMeta,
        customMessage.isAcceptableOrUnknown(
          data['custom_message']!,
          _customMessageMeta,
        ),
      );
    }
    if (data.containsKey('is_daily')) {
      context.handle(
        _isDailyMeta,
        isDaily.isAcceptableOrUnknown(data['is_daily']!, _isDailyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preset_id'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      )!,
      reminderDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_days'],
      )!,
      customMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_message'],
      ),
      isDaily: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_daily'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GoalNotificationsTable createAlias(String alias) {
    return $GoalNotificationsTable(attachedDatabase, alias);
  }
}

class GoalNotification extends DataClass
    implements Insertable<GoalNotification> {
  int id;
  int presetId;
  bool isEnabled;
  String reminderTime;
  String reminderDays;
  String? customMessage;
  bool isDaily;
  DateTime createdAt;
  DateTime updatedAt;
  GoalNotification({
    required this.id,
    required this.presetId,
    required this.isEnabled,
    required this.reminderTime,
    required this.reminderDays,
    this.customMessage,
    required this.isDaily,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['preset_id'] = Variable<int>(presetId);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['reminder_time'] = Variable<String>(reminderTime);
    map['reminder_days'] = Variable<String>(reminderDays);
    if (!nullToAbsent || customMessage != null) {
      map['custom_message'] = Variable<String>(customMessage);
    }
    map['is_daily'] = Variable<bool>(isDaily);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalNotificationsCompanion toCompanion(bool nullToAbsent) {
    return GoalNotificationsCompanion(
      id: Value(id),
      presetId: Value(presetId),
      isEnabled: Value(isEnabled),
      reminderTime: Value(reminderTime),
      reminderDays: Value(reminderDays),
      customMessage: customMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(customMessage),
      isDaily: Value(isDaily),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GoalNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalNotification(
      id: serializer.fromJson<int>(json['id']),
      presetId: serializer.fromJson<int>(json['presetId']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      reminderTime: serializer.fromJson<String>(json['reminderTime']),
      reminderDays: serializer.fromJson<String>(json['reminderDays']),
      customMessage: serializer.fromJson<String?>(json['customMessage']),
      isDaily: serializer.fromJson<bool>(json['isDaily']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  factory GoalNotification.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => GoalNotification.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'presetId': serializer.toJson<int>(presetId),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'reminderTime': serializer.toJson<String>(reminderTime),
      'reminderDays': serializer.toJson<String>(reminderDays),
      'customMessage': serializer.toJson<String?>(customMessage),
      'isDaily': serializer.toJson<bool>(isDaily),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GoalNotification copyWith({
    int? id,
    int? presetId,
    bool? isEnabled,
    String? reminderTime,
    String? reminderDays,
    Value<String?> customMessage = const Value.absent(),
    bool? isDaily,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GoalNotification(
    id: id ?? this.id,
    presetId: presetId ?? this.presetId,
    isEnabled: isEnabled ?? this.isEnabled,
    reminderTime: reminderTime ?? this.reminderTime,
    reminderDays: reminderDays ?? this.reminderDays,
    customMessage: customMessage.present
        ? customMessage.value
        : this.customMessage,
    isDaily: isDaily ?? this.isDaily,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GoalNotification copyWithCompanion(GoalNotificationsCompanion data) {
    return GoalNotification(
      id: data.id.present ? data.id.value : this.id,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      reminderDays: data.reminderDays.present
          ? data.reminderDays.value
          : this.reminderDays,
      customMessage: data.customMessage.present
          ? data.customMessage.value
          : this.customMessage,
      isDaily: data.isDaily.present ? data.isDaily.value : this.isDaily,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalNotification(')
          ..write('id: $id, ')
          ..write('presetId: $presetId, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('reminderDays: $reminderDays, ')
          ..write('customMessage: $customMessage, ')
          ..write('isDaily: $isDaily, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    presetId,
    isEnabled,
    reminderTime,
    reminderDays,
    customMessage,
    isDaily,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalNotification &&
          other.id == this.id &&
          other.presetId == this.presetId &&
          other.isEnabled == this.isEnabled &&
          other.reminderTime == this.reminderTime &&
          other.reminderDays == this.reminderDays &&
          other.customMessage == this.customMessage &&
          other.isDaily == this.isDaily &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalNotificationsCompanion extends UpdateCompanion<GoalNotification> {
  Value<int> id;
  Value<int> presetId;
  Value<bool> isEnabled;
  Value<String> reminderTime;
  Value<String> reminderDays;
  Value<String?> customMessage;
  Value<bool> isDaily;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  GoalNotificationsCompanion({
    this.id = const Value.absent(),
    this.presetId = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.reminderDays = const Value.absent(),
    this.customMessage = const Value.absent(),
    this.isDaily = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GoalNotificationsCompanion.insert({
    this.id = const Value.absent(),
    required int presetId,
    this.isEnabled = const Value.absent(),
    required String reminderTime,
    required String reminderDays,
    this.customMessage = const Value.absent(),
    this.isDaily = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : presetId = Value(presetId),
       reminderTime = Value(reminderTime),
       reminderDays = Value(reminderDays);
  static Insertable<GoalNotification> custom({
    Expression<int>? id,
    Expression<int>? presetId,
    Expression<bool>? isEnabled,
    Expression<String>? reminderTime,
    Expression<String>? reminderDays,
    Expression<String>? customMessage,
    Expression<bool>? isDaily,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (presetId != null) 'preset_id': presetId,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (reminderDays != null) 'reminder_days': reminderDays,
      if (customMessage != null) 'custom_message': customMessage,
      if (isDaily != null) 'is_daily': isDaily,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GoalNotificationsCompanion copyWith({
    Value<int>? id,
    Value<int>? presetId,
    Value<bool>? isEnabled,
    Value<String>? reminderTime,
    Value<String>? reminderDays,
    Value<String?>? customMessage,
    Value<bool>? isDaily,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return GoalNotificationsCompanion(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      customMessage: customMessage ?? this.customMessage,
      isDaily: isDaily ?? this.isDaily,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<int>(presetId.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (reminderDays.present) {
      map['reminder_days'] = Variable<String>(reminderDays.value);
    }
    if (customMessage.present) {
      map['custom_message'] = Variable<String>(customMessage.value);
    }
    if (isDaily.present) {
      map['is_daily'] = Variable<bool>(isDaily.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('presetId: $presetId, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('reminderDays: $reminderDays, ')
          ..write('customMessage: $customMessage, ')
          ..write('isDaily: $isDaily, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GoalStatisticsTable extends GoalStatistics
    with TableInfo<$GoalStatisticsTable, GoalStatistic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalStatisticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
    'goal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalGoalsMeta = const VerificationMeta(
    'totalGoals',
  );
  @override
  late final GeneratedColumn<int> totalGoals = GeneratedColumn<int>(
    'total_goals',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedGoalsMeta = const VerificationMeta(
    'completedGoals',
  );
  @override
  late final GeneratedColumn<int> completedGoals = GeneratedColumn<int>(
    'completed_goals',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _lastCompletedDateMeta = const VerificationMeta(
    'lastCompletedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastCompletedDate =
      GeneratedColumn<DateTime>(
        'last_completed_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _firstGoalDateMeta = const VerificationMeta(
    'firstGoalDate',
  );
  @override
  late final GeneratedColumn<DateTime> firstGoalDate =
      GeneratedColumn<DateTime>(
        'first_goal_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _completionRateMeta = const VerificationMeta(
    'completionRate',
  );
  @override
  late final GeneratedColumn<double> completionRate = GeneratedColumn<double>(
    'completion_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalType,
    totalGoals,
    completedGoals,
    currentStreak,
    longestStreak,
    lastCompletedDate,
    firstGoalDate,
    completionRate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_statistics';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalStatistic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_goalTypeMeta);
    }
    if (data.containsKey('total_goals')) {
      context.handle(
        _totalGoalsMeta,
        totalGoals.isAcceptableOrUnknown(data['total_goals']!, _totalGoalsMeta),
      );
    }
    if (data.containsKey('completed_goals')) {
      context.handle(
        _completedGoalsMeta,
        completedGoals.isAcceptableOrUnknown(
          data['completed_goals']!,
          _completedGoalsMeta,
        ),
      );
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
    if (data.containsKey('last_completed_date')) {
      context.handle(
        _lastCompletedDateMeta,
        lastCompletedDate.isAcceptableOrUnknown(
          data['last_completed_date']!,
          _lastCompletedDateMeta,
        ),
      );
    }
    if (data.containsKey('first_goal_date')) {
      context.handle(
        _firstGoalDateMeta,
        firstGoalDate.isAcceptableOrUnknown(
          data['first_goal_date']!,
          _firstGoalDateMeta,
        ),
      );
    }
    if (data.containsKey('completion_rate')) {
      context.handle(
        _completionRateMeta,
        completionRate.isAcceptableOrUnknown(
          data['completion_rate']!,
          _completionRateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalStatistic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalStatistic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_type'],
      )!,
      totalGoals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_goals'],
      )!,
      completedGoals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_goals'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      lastCompletedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_date'],
      ),
      firstGoalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_goal_date'],
      ),
      completionRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}completion_rate'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GoalStatisticsTable createAlias(String alias) {
    return $GoalStatisticsTable(attachedDatabase, alias);
  }
}

class GoalStatistic extends DataClass implements Insertable<GoalStatistic> {
  int id;
  String goalType;
  int totalGoals;
  int completedGoals;
  int currentStreak;
  int longestStreak;
  DateTime? lastCompletedDate;
  DateTime? firstGoalDate;
  double completionRate;
  DateTime updatedAt;
  GoalStatistic({
    required this.id,
    required this.goalType,
    required this.totalGoals,
    required this.completedGoals,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    this.firstGoalDate,
    required this.completionRate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_type'] = Variable<String>(goalType);
    map['total_goals'] = Variable<int>(totalGoals);
    map['completed_goals'] = Variable<int>(completedGoals);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastCompletedDate != null) {
      map['last_completed_date'] = Variable<DateTime>(lastCompletedDate);
    }
    if (!nullToAbsent || firstGoalDate != null) {
      map['first_goal_date'] = Variable<DateTime>(firstGoalDate);
    }
    map['completion_rate'] = Variable<double>(completionRate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalStatisticsCompanion toCompanion(bool nullToAbsent) {
    return GoalStatisticsCompanion(
      id: Value(id),
      goalType: Value(goalType),
      totalGoals: Value(totalGoals),
      completedGoals: Value(completedGoals),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      lastCompletedDate: lastCompletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedDate),
      firstGoalDate: firstGoalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(firstGoalDate),
      completionRate: Value(completionRate),
      updatedAt: Value(updatedAt),
    );
  }

  factory GoalStatistic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalStatistic(
      id: serializer.fromJson<int>(json['id']),
      goalType: serializer.fromJson<String>(json['goalType']),
      totalGoals: serializer.fromJson<int>(json['totalGoals']),
      completedGoals: serializer.fromJson<int>(json['completedGoals']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      lastCompletedDate: serializer.fromJson<DateTime?>(
        json['lastCompletedDate'],
      ),
      firstGoalDate: serializer.fromJson<DateTime?>(json['firstGoalDate']),
      completionRate: serializer.fromJson<double>(json['completionRate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  factory GoalStatistic.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => GoalStatistic.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalType': serializer.toJson<String>(goalType),
      'totalGoals': serializer.toJson<int>(totalGoals),
      'completedGoals': serializer.toJson<int>(completedGoals),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'lastCompletedDate': serializer.toJson<DateTime?>(lastCompletedDate),
      'firstGoalDate': serializer.toJson<DateTime?>(firstGoalDate),
      'completionRate': serializer.toJson<double>(completionRate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GoalStatistic copyWith({
    int? id,
    String? goalType,
    int? totalGoals,
    int? completedGoals,
    int? currentStreak,
    int? longestStreak,
    Value<DateTime?> lastCompletedDate = const Value.absent(),
    Value<DateTime?> firstGoalDate = const Value.absent(),
    double? completionRate,
    DateTime? updatedAt,
  }) => GoalStatistic(
    id: id ?? this.id,
    goalType: goalType ?? this.goalType,
    totalGoals: totalGoals ?? this.totalGoals,
    completedGoals: completedGoals ?? this.completedGoals,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastCompletedDate: lastCompletedDate.present
        ? lastCompletedDate.value
        : this.lastCompletedDate,
    firstGoalDate: firstGoalDate.present
        ? firstGoalDate.value
        : this.firstGoalDate,
    completionRate: completionRate ?? this.completionRate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GoalStatistic copyWithCompanion(GoalStatisticsCompanion data) {
    return GoalStatistic(
      id: data.id.present ? data.id.value : this.id,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      totalGoals: data.totalGoals.present
          ? data.totalGoals.value
          : this.totalGoals,
      completedGoals: data.completedGoals.present
          ? data.completedGoals.value
          : this.completedGoals,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      lastCompletedDate: data.lastCompletedDate.present
          ? data.lastCompletedDate.value
          : this.lastCompletedDate,
      firstGoalDate: data.firstGoalDate.present
          ? data.firstGoalDate.value
          : this.firstGoalDate,
      completionRate: data.completionRate.present
          ? data.completionRate.value
          : this.completionRate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalStatistic(')
          ..write('id: $id, ')
          ..write('goalType: $goalType, ')
          ..write('totalGoals: $totalGoals, ')
          ..write('completedGoals: $completedGoals, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastCompletedDate: $lastCompletedDate, ')
          ..write('firstGoalDate: $firstGoalDate, ')
          ..write('completionRate: $completionRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalType,
    totalGoals,
    completedGoals,
    currentStreak,
    longestStreak,
    lastCompletedDate,
    firstGoalDate,
    completionRate,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalStatistic &&
          other.id == this.id &&
          other.goalType == this.goalType &&
          other.totalGoals == this.totalGoals &&
          other.completedGoals == this.completedGoals &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.lastCompletedDate == this.lastCompletedDate &&
          other.firstGoalDate == this.firstGoalDate &&
          other.completionRate == this.completionRate &&
          other.updatedAt == this.updatedAt);
}

class GoalStatisticsCompanion extends UpdateCompanion<GoalStatistic> {
  Value<int> id;
  Value<String> goalType;
  Value<int> totalGoals;
  Value<int> completedGoals;
  Value<int> currentStreak;
  Value<int> longestStreak;
  Value<DateTime?> lastCompletedDate;
  Value<DateTime?> firstGoalDate;
  Value<double> completionRate;
  Value<DateTime> updatedAt;
  GoalStatisticsCompanion({
    this.id = const Value.absent(),
    this.goalType = const Value.absent(),
    this.totalGoals = const Value.absent(),
    this.completedGoals = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.firstGoalDate = const Value.absent(),
    this.completionRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GoalStatisticsCompanion.insert({
    this.id = const Value.absent(),
    required String goalType,
    this.totalGoals = const Value.absent(),
    this.completedGoals = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.firstGoalDate = const Value.absent(),
    this.completionRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : goalType = Value(goalType);
  static Insertable<GoalStatistic> custom({
    Expression<int>? id,
    Expression<String>? goalType,
    Expression<int>? totalGoals,
    Expression<int>? completedGoals,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<DateTime>? lastCompletedDate,
    Expression<DateTime>? firstGoalDate,
    Expression<double>? completionRate,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalType != null) 'goal_type': goalType,
      if (totalGoals != null) 'total_goals': totalGoals,
      if (completedGoals != null) 'completed_goals': completedGoals,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastCompletedDate != null) 'last_completed_date': lastCompletedDate,
      if (firstGoalDate != null) 'first_goal_date': firstGoalDate,
      if (completionRate != null) 'completion_rate': completionRate,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GoalStatisticsCompanion copyWith({
    Value<int>? id,
    Value<String>? goalType,
    Value<int>? totalGoals,
    Value<int>? completedGoals,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<DateTime?>? lastCompletedDate,
    Value<DateTime?>? firstGoalDate,
    Value<double>? completionRate,
    Value<DateTime>? updatedAt,
  }) {
    return GoalStatisticsCompanion(
      id: id ?? this.id,
      goalType: goalType ?? this.goalType,
      totalGoals: totalGoals ?? this.totalGoals,
      completedGoals: completedGoals ?? this.completedGoals,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      firstGoalDate: firstGoalDate ?? this.firstGoalDate,
      completionRate: completionRate ?? this.completionRate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (totalGoals.present) {
      map['total_goals'] = Variable<int>(totalGoals.value);
    }
    if (completedGoals.present) {
      map['completed_goals'] = Variable<int>(completedGoals.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastCompletedDate.present) {
      map['last_completed_date'] = Variable<DateTime>(lastCompletedDate.value);
    }
    if (firstGoalDate.present) {
      map['first_goal_date'] = Variable<DateTime>(firstGoalDate.value);
    }
    if (completionRate.present) {
      map['completion_rate'] = Variable<double>(completionRate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalStatisticsCompanion(')
          ..write('id: $id, ')
          ..write('goalType: $goalType, ')
          ..write('totalGoals: $totalGoals, ')
          ..write('completedGoals: $completedGoals, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastCompletedDate: $lastCompletedDate, ')
          ..write('firstGoalDate: $firstGoalDate, ')
          ..write('completionRate: $completionRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $QuranDataTableTable extends QuranDataTable
    with TableInfo<$QuranDataTableTable, QuranDataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranDataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _identifierMeta = const VerificationMeta(
    'identifier',
  );
  @override
  late final GeneratedColumn<String> identifier = GeneratedColumn<String>(
    'identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _englishNameMeta = const VerificationMeta(
    'englishName',
  );
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
    'english_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
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
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    identifier,
    language,
    name,
    englishName,
    format,
    type,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_data_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranDataTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('identifier')) {
      context.handle(
        _identifierMeta,
        identifier.isAcceptableOrUnknown(data['identifier']!, _identifierMeta),
      );
    } else if (isInserting) {
      context.missing(_identifierMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('english_name')) {
      context.handle(
        _englishNameMeta,
        englishName.isAcceptableOrUnknown(
          data['english_name']!,
          _englishNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishNameMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuranDataTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranDataTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      identifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identifier'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      englishName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuranDataTableTable createAlias(String alias) {
    return $QuranDataTableTable(attachedDatabase, alias);
  }
}

class QuranDataTableData extends DataClass
    implements Insertable<QuranDataTableData> {
  int id;
  String identifier;
  String language;
  String name;
  String englishName;
  String format;
  String type;
  DateTime createdAt;
  DateTime updatedAt;
  QuranDataTableData({
    required this.id,
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['identifier'] = Variable<String>(identifier);
    map['language'] = Variable<String>(language);
    map['name'] = Variable<String>(name);
    map['english_name'] = Variable<String>(englishName);
    map['format'] = Variable<String>(format);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuranDataTableCompanion toCompanion(bool nullToAbsent) {
    return QuranDataTableCompanion(
      id: Value(id),
      identifier: Value(identifier),
      language: Value(language),
      name: Value(name),
      englishName: Value(englishName),
      format: Value(format),
      type: Value(type),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuranDataTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranDataTableData(
      id: serializer.fromJson<int>(json['id']),
      identifier: serializer.fromJson<String>(json['identifier']),
      language: serializer.fromJson<String>(json['language']),
      name: serializer.fromJson<String>(json['name']),
      englishName: serializer.fromJson<String>(json['englishName']),
      format: serializer.fromJson<String>(json['format']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  factory QuranDataTableData.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => QuranDataTableData.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'identifier': serializer.toJson<String>(identifier),
      'language': serializer.toJson<String>(language),
      'name': serializer.toJson<String>(name),
      'englishName': serializer.toJson<String>(englishName),
      'format': serializer.toJson<String>(format),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuranDataTableData copyWith({
    int? id,
    String? identifier,
    String? language,
    String? name,
    String? englishName,
    String? format,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => QuranDataTableData(
    id: id ?? this.id,
    identifier: identifier ?? this.identifier,
    language: language ?? this.language,
    name: name ?? this.name,
    englishName: englishName ?? this.englishName,
    format: format ?? this.format,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuranDataTableData copyWithCompanion(QuranDataTableCompanion data) {
    return QuranDataTableData(
      id: data.id.present ? data.id.value : this.id,
      identifier: data.identifier.present
          ? data.identifier.value
          : this.identifier,
      language: data.language.present ? data.language.value : this.language,
      name: data.name.present ? data.name.value : this.name,
      englishName: data.englishName.present
          ? data.englishName.value
          : this.englishName,
      format: data.format.present ? data.format.value : this.format,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranDataTableData(')
          ..write('id: $id, ')
          ..write('identifier: $identifier, ')
          ..write('language: $language, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('format: $format, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    identifier,
    language,
    name,
    englishName,
    format,
    type,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranDataTableData &&
          other.id == this.id &&
          other.identifier == this.identifier &&
          other.language == this.language &&
          other.name == this.name &&
          other.englishName == this.englishName &&
          other.format == this.format &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class QuranDataTableCompanion extends UpdateCompanion<QuranDataTableData> {
  Value<int> id;
  Value<String> identifier;
  Value<String> language;
  Value<String> name;
  Value<String> englishName;
  Value<String> format;
  Value<String> type;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  QuranDataTableCompanion({
    this.id = const Value.absent(),
    this.identifier = const Value.absent(),
    this.language = const Value.absent(),
    this.name = const Value.absent(),
    this.englishName = const Value.absent(),
    this.format = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QuranDataTableCompanion.insert({
    this.id = const Value.absent(),
    required String identifier,
    required String language,
    required String name,
    required String englishName,
    required String format,
    required String type,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : identifier = Value(identifier),
       language = Value(language),
       name = Value(name),
       englishName = Value(englishName),
       format = Value(format),
       type = Value(type);
  static Insertable<QuranDataTableData> custom({
    Expression<int>? id,
    Expression<String>? identifier,
    Expression<String>? language,
    Expression<String>? name,
    Expression<String>? englishName,
    Expression<String>? format,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (identifier != null) 'identifier': identifier,
      if (language != null) 'language': language,
      if (name != null) 'name': name,
      if (englishName != null) 'english_name': englishName,
      if (format != null) 'format': format,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QuranDataTableCompanion copyWith({
    Value<int>? id,
    Value<String>? identifier,
    Value<String>? language,
    Value<String>? name,
    Value<String>? englishName,
    Value<String>? format,
    Value<String>? type,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return QuranDataTableCompanion(
      id: id ?? this.id,
      identifier: identifier ?? this.identifier,
      language: language ?? this.language,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      format: format ?? this.format,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (identifier.present) {
      map['identifier'] = Variable<String>(identifier.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranDataTableCompanion(')
          ..write('id: $id, ')
          ..write('identifier: $identifier, ')
          ..write('language: $language, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('format: $format, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SurahTableTable extends SurahTable
    with TableInfo<$SurahTableTable, SurahTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _englishNameMeta = const VerificationMeta(
    'englishName',
  );
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
    'english_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishNameTranslationMeta =
      const VerificationMeta('englishNameTranslation');
  @override
  late final GeneratedColumn<String> englishNameTranslation =
      GeneratedColumn<String>(
        'english_name_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _revelationTypeMeta = const VerificationMeta(
    'revelationType',
  );
  @override
  late final GeneratedColumn<String> revelationType = GeneratedColumn<String>(
    'revelation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quranDataIdMeta = const VerificationMeta(
    'quranDataId',
  );
  @override
  late final GeneratedColumn<int> quranDataId = GeneratedColumn<int>(
    'quran_data_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quran_data_table (id)',
    ),
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
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
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
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    name,
    englishName,
    englishNameTranslation,
    revelationType,
    quranDataId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surah_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurahTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('english_name')) {
      context.handle(
        _englishNameMeta,
        englishName.isAcceptableOrUnknown(
          data['english_name']!,
          _englishNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishNameMeta);
    }
    if (data.containsKey('english_name_translation')) {
      context.handle(
        _englishNameTranslationMeta,
        englishNameTranslation.isAcceptableOrUnknown(
          data['english_name_translation']!,
          _englishNameTranslationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishNameTranslationMeta);
    }
    if (data.containsKey('revelation_type')) {
      context.handle(
        _revelationTypeMeta,
        revelationType.isAcceptableOrUnknown(
          data['revelation_type']!,
          _revelationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revelationTypeMeta);
    }
    if (data.containsKey('quran_data_id')) {
      context.handle(
        _quranDataIdMeta,
        quranDataId.isAcceptableOrUnknown(
          data['quran_data_id']!,
          _quranDataIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quranDataIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SurahTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      englishName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name'],
      )!,
      englishNameTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name_translation'],
      )!,
      revelationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_type'],
      )!,
      quranDataId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quran_data_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SurahTableTable createAlias(String alias) {
    return $SurahTableTable(attachedDatabase, alias);
  }
}

class SurahTableData extends DataClass implements Insertable<SurahTableData> {
  int id;
  int number;
  String name;
  String englishName;
  String englishNameTranslation;
  String revelationType;
  int quranDataId;
  DateTime createdAt;
  DateTime updatedAt;
  SurahTableData({
    required this.id,
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.quranDataId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<int>(number);
    map['name'] = Variable<String>(name);
    map['english_name'] = Variable<String>(englishName);
    map['english_name_translation'] = Variable<String>(englishNameTranslation);
    map['revelation_type'] = Variable<String>(revelationType);
    map['quran_data_id'] = Variable<int>(quranDataId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SurahTableCompanion toCompanion(bool nullToAbsent) {
    return SurahTableCompanion(
      id: Value(id),
      number: Value(number),
      name: Value(name),
      englishName: Value(englishName),
      englishNameTranslation: Value(englishNameTranslation),
      revelationType: Value(revelationType),
      quranDataId: Value(quranDataId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SurahTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahTableData(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      name: serializer.fromJson<String>(json['name']),
      englishName: serializer.fromJson<String>(json['englishName']),
      englishNameTranslation: serializer.fromJson<String>(
        json['englishNameTranslation'],
      ),
      revelationType: serializer.fromJson<String>(json['revelationType']),
      quranDataId: serializer.fromJson<int>(json['quranDataId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  factory SurahTableData.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => SurahTableData.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<int>(number),
      'name': serializer.toJson<String>(name),
      'englishName': serializer.toJson<String>(englishName),
      'englishNameTranslation': serializer.toJson<String>(
        englishNameTranslation,
      ),
      'revelationType': serializer.toJson<String>(revelationType),
      'quranDataId': serializer.toJson<int>(quranDataId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SurahTableData copyWith({
    int? id,
    int? number,
    String? name,
    String? englishName,
    String? englishNameTranslation,
    String? revelationType,
    int? quranDataId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SurahTableData(
    id: id ?? this.id,
    number: number ?? this.number,
    name: name ?? this.name,
    englishName: englishName ?? this.englishName,
    englishNameTranslation:
        englishNameTranslation ?? this.englishNameTranslation,
    revelationType: revelationType ?? this.revelationType,
    quranDataId: quranDataId ?? this.quranDataId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SurahTableData copyWithCompanion(SurahTableCompanion data) {
    return SurahTableData(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      name: data.name.present ? data.name.value : this.name,
      englishName: data.englishName.present
          ? data.englishName.value
          : this.englishName,
      englishNameTranslation: data.englishNameTranslation.present
          ? data.englishNameTranslation.value
          : this.englishNameTranslation,
      revelationType: data.revelationType.present
          ? data.revelationType.value
          : this.revelationType,
      quranDataId: data.quranDataId.present
          ? data.quranDataId.value
          : this.quranDataId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahTableData(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('englishNameTranslation: $englishNameTranslation, ')
          ..write('revelationType: $revelationType, ')
          ..write('quranDataId: $quranDataId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    name,
    englishName,
    englishNameTranslation,
    revelationType,
    quranDataId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahTableData &&
          other.id == this.id &&
          other.number == this.number &&
          other.name == this.name &&
          other.englishName == this.englishName &&
          other.englishNameTranslation == this.englishNameTranslation &&
          other.revelationType == this.revelationType &&
          other.quranDataId == this.quranDataId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SurahTableCompanion extends UpdateCompanion<SurahTableData> {
  Value<int> id;
  Value<int> number;
  Value<String> name;
  Value<String> englishName;
  Value<String> englishNameTranslation;
  Value<String> revelationType;
  Value<int> quranDataId;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  SurahTableCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.name = const Value.absent(),
    this.englishName = const Value.absent(),
    this.englishNameTranslation = const Value.absent(),
    this.revelationType = const Value.absent(),
    this.quranDataId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SurahTableCompanion.insert({
    this.id = const Value.absent(),
    required int number,
    required String name,
    required String englishName,
    required String englishNameTranslation,
    required String revelationType,
    required int quranDataId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : number = Value(number),
       name = Value(name),
       englishName = Value(englishName),
       englishNameTranslation = Value(englishNameTranslation),
       revelationType = Value(revelationType),
       quranDataId = Value(quranDataId);
  static Insertable<SurahTableData> custom({
    Expression<int>? id,
    Expression<int>? number,
    Expression<String>? name,
    Expression<String>? englishName,
    Expression<String>? englishNameTranslation,
    Expression<String>? revelationType,
    Expression<int>? quranDataId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (name != null) 'name': name,
      if (englishName != null) 'english_name': englishName,
      if (englishNameTranslation != null)
        'english_name_translation': englishNameTranslation,
      if (revelationType != null) 'revelation_type': revelationType,
      if (quranDataId != null) 'quran_data_id': quranDataId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SurahTableCompanion copyWith({
    Value<int>? id,
    Value<int>? number,
    Value<String>? name,
    Value<String>? englishName,
    Value<String>? englishNameTranslation,
    Value<String>? revelationType,
    Value<int>? quranDataId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SurahTableCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      englishNameTranslation:
          englishNameTranslation ?? this.englishNameTranslation,
      revelationType: revelationType ?? this.revelationType,
      quranDataId: quranDataId ?? this.quranDataId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (englishNameTranslation.present) {
      map['english_name_translation'] = Variable<String>(
        englishNameTranslation.value,
      );
    }
    if (revelationType.present) {
      map['revelation_type'] = Variable<String>(revelationType.value);
    }
    if (quranDataId.present) {
      map['quran_data_id'] = Variable<int>(quranDataId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahTableCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('englishNameTranslation: $englishNameTranslation, ')
          ..write('revelationType: $revelationType, ')
          ..write('quranDataId: $quranDataId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AyahTableTable extends AyahTable
    with TableInfo<$AyahTableTable, AyahTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioMeta = const VerificationMeta('audio');
  @override
  late final GeneratedColumn<String> audio = GeneratedColumn<String>(
    'audio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioSecondaryMeta = const VerificationMeta(
    'audioSecondary',
  );
  @override
  late final GeneratedColumn<String> audioSecondary = GeneratedColumn<String>(
    'audio_secondary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textArMeta = const VerificationMeta('textAr');
  @override
  late final GeneratedColumn<String> textAr = GeneratedColumn<String>(
    'text_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberInSurahMeta = const VerificationMeta(
    'numberInSurah',
  );
  @override
  late final GeneratedColumn<int> numberInSurah = GeneratedColumn<int>(
    'number_in_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  @override
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
    'juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textEnMeta = const VerificationMeta('textEn');
  @override
  late final GeneratedColumn<String> textEn = GeneratedColumn<String>(
    'text_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textBnMeta = const VerificationMeta('textBn');
  @override
  late final GeneratedColumn<String> textBn = GeneratedColumn<String>(
    'text_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transliterationMeta = const VerificationMeta(
    'transliteration',
  );
  @override
  late final GeneratedColumn<String> transliteration = GeneratedColumn<String>(
    'transliteration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES surah_table (id)',
    ),
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
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
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
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    audio,
    audioSecondary,
    textAr,
    numberInSurah,
    juz,
    textEn,
    textBn,
    transliteration,
    surahId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyahTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('audio')) {
      context.handle(
        _audioMeta,
        audio.isAcceptableOrUnknown(data['audio']!, _audioMeta),
      );
    } else if (isInserting) {
      context.missing(_audioMeta);
    }
    if (data.containsKey('audio_secondary')) {
      context.handle(
        _audioSecondaryMeta,
        audioSecondary.isAcceptableOrUnknown(
          data['audio_secondary']!,
          _audioSecondaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioSecondaryMeta);
    }
    if (data.containsKey('text_ar')) {
      context.handle(
        _textArMeta,
        textAr.isAcceptableOrUnknown(data['text_ar']!, _textArMeta),
      );
    } else if (isInserting) {
      context.missing(_textArMeta);
    }
    if (data.containsKey('number_in_surah')) {
      context.handle(
        _numberInSurahMeta,
        numberInSurah.isAcceptableOrUnknown(
          data['number_in_surah']!,
          _numberInSurahMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numberInSurahMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
        _juzMeta,
        juz.isAcceptableOrUnknown(data['juz']!, _juzMeta),
      );
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('text_en')) {
      context.handle(
        _textEnMeta,
        textEn.isAcceptableOrUnknown(data['text_en']!, _textEnMeta),
      );
    } else if (isInserting) {
      context.missing(_textEnMeta);
    }
    if (data.containsKey('text_bn')) {
      context.handle(
        _textBnMeta,
        textBn.isAcceptableOrUnknown(data['text_bn']!, _textBnMeta),
      );
    } else if (isInserting) {
      context.missing(_textBnMeta);
    }
    if (data.containsKey('transliteration')) {
      context.handle(
        _transliterationMeta,
        transliteration.isAcceptableOrUnknown(
          data['transliteration']!,
          _transliterationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transliterationMeta);
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AyahTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      audio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio'],
      )!,
      audioSecondary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_secondary'],
      )!,
      textAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_ar'],
      )!,
      numberInSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_in_surah'],
      )!,
      juz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz'],
      )!,
      textEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_en'],
      )!,
      textBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_bn'],
      )!,
      transliteration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transliteration'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AyahTableTable createAlias(String alias) {
    return $AyahTableTable(attachedDatabase, alias);
  }
}

class AyahTableData extends DataClass implements Insertable<AyahTableData> {
  int id;
  int number;
  String audio;
  String audioSecondary;
  String textAr;
  int numberInSurah;
  int juz;
  String textEn;
  String textBn;
  String transliteration;
  int surahId;
  DateTime createdAt;
  DateTime updatedAt;
  AyahTableData({
    required this.id,
    required this.number,
    required this.audio,
    required this.audioSecondary,
    required this.textAr,
    required this.numberInSurah,
    required this.juz,
    required this.textEn,
    required this.textBn,
    required this.transliteration,
    required this.surahId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<int>(number);
    map['audio'] = Variable<String>(audio);
    map['audio_secondary'] = Variable<String>(audioSecondary);
    map['text_ar'] = Variable<String>(textAr);
    map['number_in_surah'] = Variable<int>(numberInSurah);
    map['juz'] = Variable<int>(juz);
    map['text_en'] = Variable<String>(textEn);
    map['text_bn'] = Variable<String>(textBn);
    map['transliteration'] = Variable<String>(transliteration);
    map['surah_id'] = Variable<int>(surahId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AyahTableCompanion toCompanion(bool nullToAbsent) {
    return AyahTableCompanion(
      id: Value(id),
      number: Value(number),
      audio: Value(audio),
      audioSecondary: Value(audioSecondary),
      textAr: Value(textAr),
      numberInSurah: Value(numberInSurah),
      juz: Value(juz),
      textEn: Value(textEn),
      textBn: Value(textBn),
      transliteration: Value(transliteration),
      surahId: Value(surahId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AyahTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahTableData(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      audio: serializer.fromJson<String>(json['audio']),
      audioSecondary: serializer.fromJson<String>(json['audioSecondary']),
      textAr: serializer.fromJson<String>(json['textAr']),
      numberInSurah: serializer.fromJson<int>(json['numberInSurah']),
      juz: serializer.fromJson<int>(json['juz']),
      textEn: serializer.fromJson<String>(json['textEn']),
      textBn: serializer.fromJson<String>(json['textBn']),
      transliteration: serializer.fromJson<String>(json['transliteration']),
      surahId: serializer.fromJson<int>(json['surahId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  factory AyahTableData.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => AyahTableData.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<int>(number),
      'audio': serializer.toJson<String>(audio),
      'audioSecondary': serializer.toJson<String>(audioSecondary),
      'textAr': serializer.toJson<String>(textAr),
      'numberInSurah': serializer.toJson<int>(numberInSurah),
      'juz': serializer.toJson<int>(juz),
      'textEn': serializer.toJson<String>(textEn),
      'textBn': serializer.toJson<String>(textBn),
      'transliteration': serializer.toJson<String>(transliteration),
      'surahId': serializer.toJson<int>(surahId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AyahTableData copyWith({
    int? id,
    int? number,
    String? audio,
    String? audioSecondary,
    String? textAr,
    int? numberInSurah,
    int? juz,
    String? textEn,
    String? textBn,
    String? transliteration,
    int? surahId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AyahTableData(
    id: id ?? this.id,
    number: number ?? this.number,
    audio: audio ?? this.audio,
    audioSecondary: audioSecondary ?? this.audioSecondary,
    textAr: textAr ?? this.textAr,
    numberInSurah: numberInSurah ?? this.numberInSurah,
    juz: juz ?? this.juz,
    textEn: textEn ?? this.textEn,
    textBn: textBn ?? this.textBn,
    transliteration: transliteration ?? this.transliteration,
    surahId: surahId ?? this.surahId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AyahTableData copyWithCompanion(AyahTableCompanion data) {
    return AyahTableData(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      audio: data.audio.present ? data.audio.value : this.audio,
      audioSecondary: data.audioSecondary.present
          ? data.audioSecondary.value
          : this.audioSecondary,
      textAr: data.textAr.present ? data.textAr.value : this.textAr,
      numberInSurah: data.numberInSurah.present
          ? data.numberInSurah.value
          : this.numberInSurah,
      juz: data.juz.present ? data.juz.value : this.juz,
      textEn: data.textEn.present ? data.textEn.value : this.textEn,
      textBn: data.textBn.present ? data.textBn.value : this.textBn,
      transliteration: data.transliteration.present
          ? data.transliteration.value
          : this.transliteration,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahTableData(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('audio: $audio, ')
          ..write('audioSecondary: $audioSecondary, ')
          ..write('textAr: $textAr, ')
          ..write('numberInSurah: $numberInSurah, ')
          ..write('juz: $juz, ')
          ..write('textEn: $textEn, ')
          ..write('textBn: $textBn, ')
          ..write('transliteration: $transliteration, ')
          ..write('surahId: $surahId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    audio,
    audioSecondary,
    textAr,
    numberInSurah,
    juz,
    textEn,
    textBn,
    transliteration,
    surahId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahTableData &&
          other.id == this.id &&
          other.number == this.number &&
          other.audio == this.audio &&
          other.audioSecondary == this.audioSecondary &&
          other.textAr == this.textAr &&
          other.numberInSurah == this.numberInSurah &&
          other.juz == this.juz &&
          other.textEn == this.textEn &&
          other.textBn == this.textBn &&
          other.transliteration == this.transliteration &&
          other.surahId == this.surahId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AyahTableCompanion extends UpdateCompanion<AyahTableData> {
  Value<int> id;
  Value<int> number;
  Value<String> audio;
  Value<String> audioSecondary;
  Value<String> textAr;
  Value<int> numberInSurah;
  Value<int> juz;
  Value<String> textEn;
  Value<String> textBn;
  Value<String> transliteration;
  Value<int> surahId;
  Value<DateTime> createdAt;
  Value<DateTime> updatedAt;
  AyahTableCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.audio = const Value.absent(),
    this.audioSecondary = const Value.absent(),
    this.textAr = const Value.absent(),
    this.numberInSurah = const Value.absent(),
    this.juz = const Value.absent(),
    this.textEn = const Value.absent(),
    this.textBn = const Value.absent(),
    this.transliteration = const Value.absent(),
    this.surahId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AyahTableCompanion.insert({
    this.id = const Value.absent(),
    required int number,
    required String audio,
    required String audioSecondary,
    required String textAr,
    required int numberInSurah,
    required int juz,
    required String textEn,
    required String textBn,
    required String transliteration,
    required int surahId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : number = Value(number),
       audio = Value(audio),
       audioSecondary = Value(audioSecondary),
       textAr = Value(textAr),
       numberInSurah = Value(numberInSurah),
       juz = Value(juz),
       textEn = Value(textEn),
       textBn = Value(textBn),
       transliteration = Value(transliteration),
       surahId = Value(surahId);
  static Insertable<AyahTableData> custom({
    Expression<int>? id,
    Expression<int>? number,
    Expression<String>? audio,
    Expression<String>? audioSecondary,
    Expression<String>? textAr,
    Expression<int>? numberInSurah,
    Expression<int>? juz,
    Expression<String>? textEn,
    Expression<String>? textBn,
    Expression<String>? transliteration,
    Expression<int>? surahId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (audio != null) 'audio': audio,
      if (audioSecondary != null) 'audio_secondary': audioSecondary,
      if (textAr != null) 'text_ar': textAr,
      if (numberInSurah != null) 'number_in_surah': numberInSurah,
      if (juz != null) 'juz': juz,
      if (textEn != null) 'text_en': textEn,
      if (textBn != null) 'text_bn': textBn,
      if (transliteration != null) 'transliteration': transliteration,
      if (surahId != null) 'surah_id': surahId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AyahTableCompanion copyWith({
    Value<int>? id,
    Value<int>? number,
    Value<String>? audio,
    Value<String>? audioSecondary,
    Value<String>? textAr,
    Value<int>? numberInSurah,
    Value<int>? juz,
    Value<String>? textEn,
    Value<String>? textBn,
    Value<String>? transliteration,
    Value<int>? surahId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AyahTableCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      audio: audio ?? this.audio,
      audioSecondary: audioSecondary ?? this.audioSecondary,
      textAr: textAr ?? this.textAr,
      numberInSurah: numberInSurah ?? this.numberInSurah,
      juz: juz ?? this.juz,
      textEn: textEn ?? this.textEn,
      textBn: textBn ?? this.textBn,
      transliteration: transliteration ?? this.transliteration,
      surahId: surahId ?? this.surahId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (audio.present) {
      map['audio'] = Variable<String>(audio.value);
    }
    if (audioSecondary.present) {
      map['audio_secondary'] = Variable<String>(audioSecondary.value);
    }
    if (textAr.present) {
      map['text_ar'] = Variable<String>(textAr.value);
    }
    if (numberInSurah.present) {
      map['number_in_surah'] = Variable<int>(numberInSurah.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (textEn.present) {
      map['text_en'] = Variable<String>(textEn.value);
    }
    if (textBn.present) {
      map['text_bn'] = Variable<String>(textBn.value);
    }
    if (transliteration.present) {
      map['transliteration'] = Variable<String>(transliteration.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahTableCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('audio: $audio, ')
          ..write('audioSecondary: $audioSecondary, ')
          ..write('textAr: $textAr, ')
          ..write('numberInSurah: $numberInSurah, ')
          ..write('juz: $juz, ')
          ..write('textEn: $textEn, ')
          ..write('textBn: $textBn, ')
          ..write('transliteration: $transliteration, ')
          ..write('surahId: $surahId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RecentlyReadEntriesTable extends RecentlyReadEntries
    with TableInfo<$RecentlyReadEntriesTable, RecentlyReadEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentlyReadEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseIdMeta = const VerificationMeta(
    'verseId',
  );
  @override
  late final GeneratedColumn<int> verseId = GeneratedColumn<int>(
    'verse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surahId,
    verseId,
    source,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recently_read_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentlyReadEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('verse_id')) {
      context.handle(
        _verseIdMeta,
        verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentlyReadEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentlyReadEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      verseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $RecentlyReadEntriesTable createAlias(String alias) {
    return $RecentlyReadEntriesTable(attachedDatabase, alias);
  }
}

class RecentlyReadEntry extends DataClass
    implements Insertable<RecentlyReadEntry> {
  int id;
  int surahId;
  int verseId;
  String source;
  DateTime timestamp;
  RecentlyReadEntry({
    required this.id,
    required this.surahId,
    required this.verseId,
    required this.source,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_id'] = Variable<int>(surahId);
    map['verse_id'] = Variable<int>(verseId);
    map['source'] = Variable<String>(source);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  RecentlyReadEntriesCompanion toCompanion(bool nullToAbsent) {
    return RecentlyReadEntriesCompanion(
      id: Value(id),
      surahId: Value(surahId),
      verseId: Value(verseId),
      source: Value(source),
      timestamp: Value(timestamp),
    );
  }

  factory RecentlyReadEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentlyReadEntry(
      id: serializer.fromJson<int>(json['id']),
      surahId: serializer.fromJson<int>(json['surahId']),
      verseId: serializer.fromJson<int>(json['verseId']),
      source: serializer.fromJson<String>(json['source']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  factory RecentlyReadEntry.fromJsonString(
    String encodedJson, {
    ValueSerializer? serializer,
  }) => RecentlyReadEntry.fromJson(
    DataClass.parseJson(encodedJson) as Map<String, dynamic>,
    serializer: serializer,
  );
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahId': serializer.toJson<int>(surahId),
      'verseId': serializer.toJson<int>(verseId),
      'source': serializer.toJson<String>(source),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  RecentlyReadEntry copyWith({
    int? id,
    int? surahId,
    int? verseId,
    String? source,
    DateTime? timestamp,
  }) => RecentlyReadEntry(
    id: id ?? this.id,
    surahId: surahId ?? this.surahId,
    verseId: verseId ?? this.verseId,
    source: source ?? this.source,
    timestamp: timestamp ?? this.timestamp,
  );
  RecentlyReadEntry copyWithCompanion(RecentlyReadEntriesCompanion data) {
    return RecentlyReadEntry(
      id: data.id.present ? data.id.value : this.id,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      source: data.source.present ? data.source.value : this.source,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentlyReadEntry(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('verseId: $verseId, ')
          ..write('source: $source, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, surahId, verseId, source, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentlyReadEntry &&
          other.id == this.id &&
          other.surahId == this.surahId &&
          other.verseId == this.verseId &&
          other.source == this.source &&
          other.timestamp == this.timestamp);
}

class RecentlyReadEntriesCompanion extends UpdateCompanion<RecentlyReadEntry> {
  Value<int> id;
  Value<int> surahId;
  Value<int> verseId;
  Value<String> source;
  Value<DateTime> timestamp;
  RecentlyReadEntriesCompanion({
    this.id = const Value.absent(),
    this.surahId = const Value.absent(),
    this.verseId = const Value.absent(),
    this.source = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  RecentlyReadEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int surahId,
    required int verseId,
    this.source = const Value.absent(),
    this.timestamp = const Value.absent(),
  }) : surahId = Value(surahId),
       verseId = Value(verseId);
  static Insertable<RecentlyReadEntry> custom({
    Expression<int>? id,
    Expression<int>? surahId,
    Expression<int>? verseId,
    Expression<String>? source,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahId != null) 'surah_id': surahId,
      if (verseId != null) 'verse_id': verseId,
      if (source != null) 'source': source,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  RecentlyReadEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? surahId,
    Value<int>? verseId,
    Value<String>? source,
    Value<DateTime>? timestamp,
  }) {
    return RecentlyReadEntriesCompanion(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      verseId: verseId ?? this.verseId,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<int>(verseId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentlyReadEntriesCompanion(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('verseId: $verseId, ')
          ..write('source: $source, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $GoalPresetsTable goalPresets = $GoalPresetsTable(this);
  late final $DailyGoalsTable dailyGoals = $DailyGoalsTable(this);
  late final $GoalProgressTable goalProgress = $GoalProgressTable(this);
  late final $GoalHistoryTable goalHistory = $GoalHistoryTable(this);
  late final $GoalNotificationsTable goalNotifications =
      $GoalNotificationsTable(this);
  late final $GoalStatisticsTable goalStatistics = $GoalStatisticsTable(this);
  late final $QuranDataTableTable quranDataTable = $QuranDataTableTable(this);
  late final $SurahTableTable surahTable = $SurahTableTable(this);
  late final $AyahTableTable ayahTable = $AyahTableTable(this);
  late final $RecentlyReadEntriesTable recentlyReadEntries =
      $RecentlyReadEntriesTable(this);
  late final ChatDao chatDao = ChatDao(this as AppDatabase);
  late final GoalsDao goalsDao = GoalsDao(this as AppDatabase);
  late final QuranDao quranDao = QuranDao(this as AppDatabase);
  late final RecentlyReadDao recentlyReadDao = RecentlyReadDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chatSessions,
    chatMessages,
    goalPresets,
    dailyGoals,
    goalProgress,
    goalHistory,
    goalNotifications,
    goalStatistics,
    quranDataTable,
    surahTable,
    ayahTable,
    recentlyReadEntries,
  ];
}

typedef $$ChatSessionsTableCreateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<int> id,
      required String title,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
    });
typedef $$ChatSessionsTableUpdateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
    });

final class $$ChatSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSession> {
  $$ChatSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessageData>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: $_aliasNameGenerator(
      db.chatSessions.id,
      db.chatMessages.sessionId,
    ),
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatSessionsTable,
          ChatSession,
          $$ChatSessionsTableFilterComposer,
          $$ChatSessionsTableOrderingComposer,
          $$ChatSessionsTableAnnotationComposer,
          $$ChatSessionsTableCreateCompanionBuilder,
          $$ChatSessionsTableUpdateCompanionBuilder,
          (ChatSession, $$ChatSessionsTableReferences),
          ChatSession,
          PrefetchHooks Function({bool chatMessagesRefs})
        > {
  $$ChatSessionsTableTableManager(_$AppDatabase db, $ChatSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => ChatSessionsCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => ChatSessionsCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatMessagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chatMessagesRefs) db.chatMessages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chatMessagesRefs)
                    await $_getPrefetchedData<
                      ChatSession,
                      $ChatSessionsTable,
                      ChatMessageData
                    >(
                      currentTable: table,
                      referencedTable: $$ChatSessionsTableReferences
                          ._chatMessagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ChatSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).chatMessagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ChatSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatSessionsTable,
      ChatSession,
      $$ChatSessionsTableFilterComposer,
      $$ChatSessionsTableOrderingComposer,
      $$ChatSessionsTableAnnotationComposer,
      $$ChatSessionsTableCreateCompanionBuilder,
      $$ChatSessionsTableUpdateCompanionBuilder,
      (ChatSession, $$ChatSessionsTableReferences),
      ChatSession,
      PrefetchHooks Function({bool chatMessagesRefs})
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required int sessionId,
      required String message,
      required String messageType,
      Value<DateTime> timestamp,
      Value<String?> references,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> message,
      Value<String> messageType,
      Value<DateTime> timestamp,
      Value<String?> references,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageData> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.chatSessions.createAlias(
        $_aliasNameGenerator(db.chatMessages.sessionId, db.chatSessions.id),
      );

  $$ChatSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
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

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get references => $composableBuilder(
    column: $table.references,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatSessionsTableFilterComposer get sessionId {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get references => $composableBuilder(
    column: $table.references,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatSessionsTableOrderingComposer get sessionId {
    final $$ChatSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get references => $composableBuilder(
    column: $table.references,
    builder: (column) => column,
  );

  $$ChatSessionsTableAnnotationComposer get sessionId {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessageData,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessageData, $$ChatMessagesTableReferences),
          ChatMessageData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> references = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                message: message,
                messageType: messageType,
                timestamp: timestamp,
                references: references,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String message,
                required String messageType,
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> references = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                message: message,
                messageType: messageType,
                timestamp: timestamp,
                references: references,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessageData,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessageData, $$ChatMessagesTableReferences),
      ChatMessageData,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$GoalPresetsTableCreateCompanionBuilder =
    GoalPresetsCompanion Function({
      Value<int> id,
      required String goalType,
      required String title,
      required String description,
      Value<int> defaultTargetCount,
      required String icon,
      required String color,
      Value<bool> isRecommended,
      Value<bool> isActive,
      Value<bool> isCustom,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$GoalPresetsTableUpdateCompanionBuilder =
    GoalPresetsCompanion Function({
      Value<int> id,
      Value<String> goalType,
      Value<String> title,
      Value<String> description,
      Value<int> defaultTargetCount,
      Value<String> icon,
      Value<String> color,
      Value<bool> isRecommended,
      Value<bool> isActive,
      Value<bool> isCustom,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$GoalPresetsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalPresetsTable, GoalPreset> {
  $$GoalPresetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DailyGoalsTable, List<DailyGoal>>
  _dailyGoalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyGoals,
    aliasName: $_aliasNameGenerator(db.goalPresets.id, db.dailyGoals.presetId),
  );

  $$DailyGoalsTableProcessedTableManager get dailyGoalsRefs {
    final manager = $$DailyGoalsTableTableManager(
      $_db,
      $_db.dailyGoals,
    ).filter((f) => f.presetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyGoalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalNotificationsTable, List<GoalNotification>>
  _goalNotificationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.goalNotifications,
        aliasName: $_aliasNameGenerator(
          db.goalPresets.id,
          db.goalNotifications.presetId,
        ),
      );

  $$GoalNotificationsTableProcessedTableManager get goalNotificationsRefs {
    final manager = $$GoalNotificationsTableTableManager(
      $_db,
      $_db.goalNotifications,
    ).filter((f) => f.presetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _goalNotificationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalPresetsTable> {
  $$GoalPresetsTableFilterComposer({
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

  ColumnFilters<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTargetCount => $composableBuilder(
    column: $table.defaultTargetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecommended => $composableBuilder(
    column: $table.isRecommended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dailyGoalsRefs(
    Expression<bool> Function($$DailyGoalsTableFilterComposer f) f,
  ) {
    final $$DailyGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyGoals,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyGoalsTableFilterComposer(
            $db: $db,
            $table: $db.dailyGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalNotificationsRefs(
    Expression<bool> Function($$GoalNotificationsTableFilterComposer f) f,
  ) {
    final $$GoalNotificationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalNotifications,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalNotificationsTableFilterComposer(
            $db: $db,
            $table: $db.goalNotifications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalPresetsTable> {
  $$GoalPresetsTableOrderingComposer({
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

  ColumnOrderings<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTargetCount => $composableBuilder(
    column: $table.defaultTargetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecommended => $composableBuilder(
    column: $table.isRecommended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalPresetsTable> {
  $$GoalPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultTargetCount => $composableBuilder(
    column: $table.defaultTargetCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isRecommended => $composableBuilder(
    column: $table.isRecommended,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> dailyGoalsRefs<T extends Object>(
    Expression<T> Function($$DailyGoalsTableAnnotationComposer a) f,
  ) {
    final $$DailyGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyGoals,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalNotificationsRefs<T extends Object>(
    Expression<T> Function($$GoalNotificationsTableAnnotationComposer a) f,
  ) {
    final $$GoalNotificationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.goalNotifications,
          getReferencedColumn: (t) => t.presetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GoalNotificationsTableAnnotationComposer(
                $db: $db,
                $table: $db.goalNotifications,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GoalPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalPresetsTable,
          GoalPreset,
          $$GoalPresetsTableFilterComposer,
          $$GoalPresetsTableOrderingComposer,
          $$GoalPresetsTableAnnotationComposer,
          $$GoalPresetsTableCreateCompanionBuilder,
          $$GoalPresetsTableUpdateCompanionBuilder,
          (GoalPreset, $$GoalPresetsTableReferences),
          GoalPreset,
          PrefetchHooks Function({
            bool dailyGoalsRefs,
            bool goalNotificationsRefs,
          })
        > {
  $$GoalPresetsTableTableManager(_$AppDatabase db, $GoalPresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> goalType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> defaultTargetCount = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isRecommended = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalPresetsCompanion(
                id: id,
                goalType: goalType,
                title: title,
                description: description,
                defaultTargetCount: defaultTargetCount,
                icon: icon,
                color: color,
                isRecommended: isRecommended,
                isActive: isActive,
                isCustom: isCustom,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String goalType,
                required String title,
                required String description,
                Value<int> defaultTargetCount = const Value.absent(),
                required String icon,
                required String color,
                Value<bool> isRecommended = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalPresetsCompanion.insert(
                id: id,
                goalType: goalType,
                title: title,
                description: description,
                defaultTargetCount: defaultTargetCount,
                icon: icon,
                color: color,
                isRecommended: isRecommended,
                isActive: isActive,
                isCustom: isCustom,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalPresetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({dailyGoalsRefs = false, goalNotificationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dailyGoalsRefs) db.dailyGoals,
                    if (goalNotificationsRefs) db.goalNotifications,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dailyGoalsRefs)
                        await $_getPrefetchedData<
                          GoalPreset,
                          $GoalPresetsTable,
                          DailyGoal
                        >(
                          currentTable: table,
                          referencedTable: $$GoalPresetsTableReferences
                              ._dailyGoalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GoalPresetsTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyGoalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.presetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (goalNotificationsRefs)
                        await $_getPrefetchedData<
                          GoalPreset,
                          $GoalPresetsTable,
                          GoalNotification
                        >(
                          currentTable: table,
                          referencedTable: $$GoalPresetsTableReferences
                              ._goalNotificationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GoalPresetsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalNotificationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.presetId == item.id,
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

typedef $$GoalPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalPresetsTable,
      GoalPreset,
      $$GoalPresetsTableFilterComposer,
      $$GoalPresetsTableOrderingComposer,
      $$GoalPresetsTableAnnotationComposer,
      $$GoalPresetsTableCreateCompanionBuilder,
      $$GoalPresetsTableUpdateCompanionBuilder,
      (GoalPreset, $$GoalPresetsTableReferences),
      GoalPreset,
      PrefetchHooks Function({bool dailyGoalsRefs, bool goalNotificationsRefs})
    >;
typedef $$DailyGoalsTableCreateCompanionBuilder =
    DailyGoalsCompanion Function({
      Value<int> id,
      required String goalId,
      required int presetId,
      required String title,
      required String description,
      Value<int> targetCount,
      Value<int> currentCount,
      Value<String> status,
      required DateTime date,
      Value<bool> isActive,
      Value<String?> customNote,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
    });
typedef $$DailyGoalsTableUpdateCompanionBuilder =
    DailyGoalsCompanion Function({
      Value<int> id,
      Value<String> goalId,
      Value<int> presetId,
      Value<String> title,
      Value<String> description,
      Value<int> targetCount,
      Value<int> currentCount,
      Value<String> status,
      Value<DateTime> date,
      Value<bool> isActive,
      Value<String?> customNote,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
    });

final class $$DailyGoalsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyGoalsTable, DailyGoal> {
  $$DailyGoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalPresetsTable _presetIdTable(_$AppDatabase db) =>
      db.goalPresets.createAlias(
        $_aliasNameGenerator(db.dailyGoals.presetId, db.goalPresets.id),
      );

  $$GoalPresetsTableProcessedTableManager get presetId {
    final $_column = $_itemColumn<int>('preset_id')!;

    final manager = $$GoalPresetsTableTableManager(
      $_db,
      $_db.goalPresets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_presetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GoalProgressTable, List<GoalProgressData>>
  _goalProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.goalProgress,
    aliasName: $_aliasNameGenerator(
      db.dailyGoals.id,
      db.goalProgress.dailyGoalId,
    ),
  );

  $$GoalProgressTableProcessedTableManager get goalProgressRefs {
    final manager = $$GoalProgressTableTableManager(
      $_db,
      $_db.goalProgress,
    ).filter((f) => f.dailyGoalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DailyGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableFilterComposer({
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

  ColumnFilters<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customNote => $composableBuilder(
    column: $table.customNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalPresetsTableFilterComposer get presetId {
    final $$GoalPresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.goalPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPresetsTableFilterComposer(
            $db: $db,
            $table: $db.goalPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> goalProgressRefs(
    Expression<bool> Function($$GoalProgressTableFilterComposer f) f,
  ) {
    final $$GoalProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalProgress,
      getReferencedColumn: (t) => t.dailyGoalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalProgressTableFilterComposer(
            $db: $db,
            $table: $db.goalProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableOrderingComposer({
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

  ColumnOrderings<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customNote => $composableBuilder(
    column: $table.customNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalPresetsTableOrderingComposer get presetId {
    final $$GoalPresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.goalPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPresetsTableOrderingComposer(
            $db: $db,
            $table: $db.goalPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get customNote => $composableBuilder(
    column: $table.customNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$GoalPresetsTableAnnotationComposer get presetId {
    final $$GoalPresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.goalPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.goalPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> goalProgressRefs<T extends Object>(
    Expression<T> Function($$GoalProgressTableAnnotationComposer a) f,
  ) {
    final $$GoalProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalProgress,
      getReferencedColumn: (t) => t.dailyGoalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.goalProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyGoalsTable,
          DailyGoal,
          $$DailyGoalsTableFilterComposer,
          $$DailyGoalsTableOrderingComposer,
          $$DailyGoalsTableAnnotationComposer,
          $$DailyGoalsTableCreateCompanionBuilder,
          $$DailyGoalsTableUpdateCompanionBuilder,
          (DailyGoal, $$DailyGoalsTableReferences),
          DailyGoal,
          PrefetchHooks Function({bool presetId, bool goalProgressRefs})
        > {
  $$DailyGoalsTableTableManager(_$AppDatabase db, $DailyGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> goalId = const Value.absent(),
                Value<int> presetId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> customNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DailyGoalsCompanion(
                id: id,
                goalId: goalId,
                presetId: presetId,
                title: title,
                description: description,
                targetCount: targetCount,
                currentCount: currentCount,
                status: status,
                date: date,
                isActive: isActive,
                customNote: customNote,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String goalId,
                required int presetId,
                required String title,
                required String description,
                Value<int> targetCount = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime date,
                Value<bool> isActive = const Value.absent(),
                Value<String?> customNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DailyGoalsCompanion.insert(
                id: id,
                goalId: goalId,
                presetId: presetId,
                title: title,
                description: description,
                targetCount: targetCount,
                currentCount: currentCount,
                status: status,
                date: date,
                isActive: isActive,
                customNote: customNote,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyGoalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({presetId = false, goalProgressRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (goalProgressRefs) db.goalProgress,
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
                        if (presetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.presetId,
                                    referencedTable: $$DailyGoalsTableReferences
                                        ._presetIdTable(db),
                                    referencedColumn:
                                        $$DailyGoalsTableReferences
                                            ._presetIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (goalProgressRefs)
                        await $_getPrefetchedData<
                          DailyGoal,
                          $DailyGoalsTable,
                          GoalProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$DailyGoalsTableReferences
                              ._goalProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DailyGoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dailyGoalId == item.id,
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

typedef $$DailyGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyGoalsTable,
      DailyGoal,
      $$DailyGoalsTableFilterComposer,
      $$DailyGoalsTableOrderingComposer,
      $$DailyGoalsTableAnnotationComposer,
      $$DailyGoalsTableCreateCompanionBuilder,
      $$DailyGoalsTableUpdateCompanionBuilder,
      (DailyGoal, $$DailyGoalsTableReferences),
      DailyGoal,
      PrefetchHooks Function({bool presetId, bool goalProgressRefs})
    >;
typedef $$GoalProgressTableCreateCompanionBuilder =
    GoalProgressCompanion Function({
      Value<int> id,
      required int dailyGoalId,
      Value<int> incrementValue,
      Value<String?> note,
      Value<DateTime> timestamp,
    });
typedef $$GoalProgressTableUpdateCompanionBuilder =
    GoalProgressCompanion Function({
      Value<int> id,
      Value<int> dailyGoalId,
      Value<int> incrementValue,
      Value<String?> note,
      Value<DateTime> timestamp,
    });

final class $$GoalProgressTableReferences
    extends
        BaseReferences<_$AppDatabase, $GoalProgressTable, GoalProgressData> {
  $$GoalProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DailyGoalsTable _dailyGoalIdTable(_$AppDatabase db) =>
      db.dailyGoals.createAlias(
        $_aliasNameGenerator(db.goalProgress.dailyGoalId, db.dailyGoals.id),
      );

  $$DailyGoalsTableProcessedTableManager get dailyGoalId {
    final $_column = $_itemColumn<int>('daily_goal_id')!;

    final manager = $$DailyGoalsTableTableManager(
      $_db,
      $_db.dailyGoals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dailyGoalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalProgressTableFilterComposer
    extends Composer<_$AppDatabase, $GoalProgressTable> {
  $$GoalProgressTableFilterComposer({
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

  ColumnFilters<int> get incrementValue => $composableBuilder(
    column: $table.incrementValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$DailyGoalsTableFilterComposer get dailyGoalId {
    final $$DailyGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyGoalId,
      referencedTable: $db.dailyGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyGoalsTableFilterComposer(
            $db: $db,
            $table: $db.dailyGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalProgressTable> {
  $$GoalProgressTableOrderingComposer({
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

  ColumnOrderings<int> get incrementValue => $composableBuilder(
    column: $table.incrementValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$DailyGoalsTableOrderingComposer get dailyGoalId {
    final $$DailyGoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyGoalId,
      referencedTable: $db.dailyGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyGoalsTableOrderingComposer(
            $db: $db,
            $table: $db.dailyGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalProgressTable> {
  $$GoalProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get incrementValue => $composableBuilder(
    column: $table.incrementValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$DailyGoalsTableAnnotationComposer get dailyGoalId {
    final $$DailyGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dailyGoalId,
      referencedTable: $db.dailyGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalProgressTable,
          GoalProgressData,
          $$GoalProgressTableFilterComposer,
          $$GoalProgressTableOrderingComposer,
          $$GoalProgressTableAnnotationComposer,
          $$GoalProgressTableCreateCompanionBuilder,
          $$GoalProgressTableUpdateCompanionBuilder,
          (GoalProgressData, $$GoalProgressTableReferences),
          GoalProgressData,
          PrefetchHooks Function({bool dailyGoalId})
        > {
  $$GoalProgressTableTableManager(_$AppDatabase db, $GoalProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyGoalId = const Value.absent(),
                Value<int> incrementValue = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => GoalProgressCompanion(
                id: id,
                dailyGoalId: dailyGoalId,
                incrementValue: incrementValue,
                note: note,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dailyGoalId,
                Value<int> incrementValue = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => GoalProgressCompanion.insert(
                id: id,
                dailyGoalId: dailyGoalId,
                incrementValue: incrementValue,
                note: note,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dailyGoalId = false}) {
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
                    if (dailyGoalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dailyGoalId,
                                referencedTable: $$GoalProgressTableReferences
                                    ._dailyGoalIdTable(db),
                                referencedColumn: $$GoalProgressTableReferences
                                    ._dailyGoalIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$GoalProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalProgressTable,
      GoalProgressData,
      $$GoalProgressTableFilterComposer,
      $$GoalProgressTableOrderingComposer,
      $$GoalProgressTableAnnotationComposer,
      $$GoalProgressTableCreateCompanionBuilder,
      $$GoalProgressTableUpdateCompanionBuilder,
      (GoalProgressData, $$GoalProgressTableReferences),
      GoalProgressData,
      PrefetchHooks Function({bool dailyGoalId})
    >;
typedef $$GoalHistoryTableCreateCompanionBuilder =
    GoalHistoryCompanion Function({
      Value<int> id,
      required String goalType,
      required String title,
      required DateTime date,
      required int targetCount,
      required int achievedCount,
      required bool wasCompleted,
      Value<int> streakCount,
      Value<DateTime> createdAt,
    });
typedef $$GoalHistoryTableUpdateCompanionBuilder =
    GoalHistoryCompanion Function({
      Value<int> id,
      Value<String> goalType,
      Value<String> title,
      Value<DateTime> date,
      Value<int> targetCount,
      Value<int> achievedCount,
      Value<bool> wasCompleted,
      Value<int> streakCount,
      Value<DateTime> createdAt,
    });

class $$GoalHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $GoalHistoryTable> {
  $$GoalHistoryTableFilterComposer({
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

  ColumnFilters<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedCount => $composableBuilder(
    column: $table.achievedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasCompleted => $composableBuilder(
    column: $table.wasCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalHistoryTable> {
  $$GoalHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievedCount => $composableBuilder(
    column: $table.achievedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasCompleted => $composableBuilder(
    column: $table.wasCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalHistoryTable> {
  $$GoalHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get achievedCount => $composableBuilder(
    column: $table.achievedCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasCompleted => $composableBuilder(
    column: $table.wasCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GoalHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalHistoryTable,
          GoalHistoryData,
          $$GoalHistoryTableFilterComposer,
          $$GoalHistoryTableOrderingComposer,
          $$GoalHistoryTableAnnotationComposer,
          $$GoalHistoryTableCreateCompanionBuilder,
          $$GoalHistoryTableUpdateCompanionBuilder,
          (
            GoalHistoryData,
            BaseReferences<_$AppDatabase, $GoalHistoryTable, GoalHistoryData>,
          ),
          GoalHistoryData,
          PrefetchHooks Function()
        > {
  $$GoalHistoryTableTableManager(_$AppDatabase db, $GoalHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> goalType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<int> achievedCount = const Value.absent(),
                Value<bool> wasCompleted = const Value.absent(),
                Value<int> streakCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalHistoryCompanion(
                id: id,
                goalType: goalType,
                title: title,
                date: date,
                targetCount: targetCount,
                achievedCount: achievedCount,
                wasCompleted: wasCompleted,
                streakCount: streakCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String goalType,
                required String title,
                required DateTime date,
                required int targetCount,
                required int achievedCount,
                required bool wasCompleted,
                Value<int> streakCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalHistoryCompanion.insert(
                id: id,
                goalType: goalType,
                title: title,
                date: date,
                targetCount: targetCount,
                achievedCount: achievedCount,
                wasCompleted: wasCompleted,
                streakCount: streakCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalHistoryTable,
      GoalHistoryData,
      $$GoalHistoryTableFilterComposer,
      $$GoalHistoryTableOrderingComposer,
      $$GoalHistoryTableAnnotationComposer,
      $$GoalHistoryTableCreateCompanionBuilder,
      $$GoalHistoryTableUpdateCompanionBuilder,
      (
        GoalHistoryData,
        BaseReferences<_$AppDatabase, $GoalHistoryTable, GoalHistoryData>,
      ),
      GoalHistoryData,
      PrefetchHooks Function()
    >;
typedef $$GoalNotificationsTableCreateCompanionBuilder =
    GoalNotificationsCompanion Function({
      Value<int> id,
      required int presetId,
      Value<bool> isEnabled,
      required String reminderTime,
      required String reminderDays,
      Value<String?> customMessage,
      Value<bool> isDaily,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$GoalNotificationsTableUpdateCompanionBuilder =
    GoalNotificationsCompanion Function({
      Value<int> id,
      Value<int> presetId,
      Value<bool> isEnabled,
      Value<String> reminderTime,
      Value<String> reminderDays,
      Value<String?> customMessage,
      Value<bool> isDaily,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$GoalNotificationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GoalNotificationsTable,
          GoalNotification
        > {
  $$GoalNotificationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GoalPresetsTable _presetIdTable(_$AppDatabase db) =>
      db.goalPresets.createAlias(
        $_aliasNameGenerator(db.goalNotifications.presetId, db.goalPresets.id),
      );

  $$GoalPresetsTableProcessedTableManager get presetId {
    final $_column = $_itemColumn<int>('preset_id')!;

    final manager = $$GoalPresetsTableTableManager(
      $_db,
      $_db.goalPresets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_presetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalNotificationsTable> {
  $$GoalNotificationsTableFilterComposer({
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

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderDays => $composableBuilder(
    column: $table.reminderDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customMessage => $composableBuilder(
    column: $table.customMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalPresetsTableFilterComposer get presetId {
    final $$GoalPresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.goalPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPresetsTableFilterComposer(
            $db: $db,
            $table: $db.goalPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalNotificationsTable> {
  $$GoalNotificationsTableOrderingComposer({
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

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderDays => $composableBuilder(
    column: $table.reminderDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customMessage => $composableBuilder(
    column: $table.customMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalPresetsTableOrderingComposer get presetId {
    final $$GoalPresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.goalPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPresetsTableOrderingComposer(
            $db: $db,
            $table: $db.goalPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalNotificationsTable> {
  $$GoalNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderDays => $composableBuilder(
    column: $table.reminderDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customMessage => $composableBuilder(
    column: $table.customMessage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDaily =>
      $composableBuilder(column: $table.isDaily, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GoalPresetsTableAnnotationComposer get presetId {
    final $$GoalPresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.goalPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.goalPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalNotificationsTable,
          GoalNotification,
          $$GoalNotificationsTableFilterComposer,
          $$GoalNotificationsTableOrderingComposer,
          $$GoalNotificationsTableAnnotationComposer,
          $$GoalNotificationsTableCreateCompanionBuilder,
          $$GoalNotificationsTableUpdateCompanionBuilder,
          (GoalNotification, $$GoalNotificationsTableReferences),
          GoalNotification,
          PrefetchHooks Function({bool presetId})
        > {
  $$GoalNotificationsTableTableManager(
    _$AppDatabase db,
    $GoalNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalNotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> presetId = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<String> reminderTime = const Value.absent(),
                Value<String> reminderDays = const Value.absent(),
                Value<String?> customMessage = const Value.absent(),
                Value<bool> isDaily = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalNotificationsCompanion(
                id: id,
                presetId: presetId,
                isEnabled: isEnabled,
                reminderTime: reminderTime,
                reminderDays: reminderDays,
                customMessage: customMessage,
                isDaily: isDaily,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int presetId,
                Value<bool> isEnabled = const Value.absent(),
                required String reminderTime,
                required String reminderDays,
                Value<String?> customMessage = const Value.absent(),
                Value<bool> isDaily = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalNotificationsCompanion.insert(
                id: id,
                presetId: presetId,
                isEnabled: isEnabled,
                reminderTime: reminderTime,
                reminderDays: reminderDays,
                customMessage: customMessage,
                isDaily: isDaily,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalNotificationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({presetId = false}) {
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
                    if (presetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.presetId,
                                referencedTable:
                                    $$GoalNotificationsTableReferences
                                        ._presetIdTable(db),
                                referencedColumn:
                                    $$GoalNotificationsTableReferences
                                        ._presetIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$GoalNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalNotificationsTable,
      GoalNotification,
      $$GoalNotificationsTableFilterComposer,
      $$GoalNotificationsTableOrderingComposer,
      $$GoalNotificationsTableAnnotationComposer,
      $$GoalNotificationsTableCreateCompanionBuilder,
      $$GoalNotificationsTableUpdateCompanionBuilder,
      (GoalNotification, $$GoalNotificationsTableReferences),
      GoalNotification,
      PrefetchHooks Function({bool presetId})
    >;
typedef $$GoalStatisticsTableCreateCompanionBuilder =
    GoalStatisticsCompanion Function({
      Value<int> id,
      required String goalType,
      Value<int> totalGoals,
      Value<int> completedGoals,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> lastCompletedDate,
      Value<DateTime?> firstGoalDate,
      Value<double> completionRate,
      Value<DateTime> updatedAt,
    });
typedef $$GoalStatisticsTableUpdateCompanionBuilder =
    GoalStatisticsCompanion Function({
      Value<int> id,
      Value<String> goalType,
      Value<int> totalGoals,
      Value<int> completedGoals,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> lastCompletedDate,
      Value<DateTime?> firstGoalDate,
      Value<double> completionRate,
      Value<DateTime> updatedAt,
    });

class $$GoalStatisticsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalStatisticsTable> {
  $$GoalStatisticsTableFilterComposer({
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

  ColumnFilters<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalGoals => $composableBuilder(
    column: $table.totalGoals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedGoals => $composableBuilder(
    column: $table.completedGoals,
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

  ColumnFilters<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstGoalDate => $composableBuilder(
    column: $table.firstGoalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get completionRate => $composableBuilder(
    column: $table.completionRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalStatisticsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalStatisticsTable> {
  $$GoalStatisticsTableOrderingComposer({
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

  ColumnOrderings<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalGoals => $composableBuilder(
    column: $table.totalGoals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedGoals => $composableBuilder(
    column: $table.completedGoals,
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

  ColumnOrderings<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstGoalDate => $composableBuilder(
    column: $table.firstGoalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get completionRate => $composableBuilder(
    column: $table.completionRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalStatisticsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalStatisticsTable> {
  $$GoalStatisticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<int> get totalGoals => $composableBuilder(
    column: $table.totalGoals,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedGoals => $composableBuilder(
    column: $table.completedGoals,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstGoalDate => $composableBuilder(
    column: $table.firstGoalDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get completionRate => $composableBuilder(
    column: $table.completionRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GoalStatisticsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalStatisticsTable,
          GoalStatistic,
          $$GoalStatisticsTableFilterComposer,
          $$GoalStatisticsTableOrderingComposer,
          $$GoalStatisticsTableAnnotationComposer,
          $$GoalStatisticsTableCreateCompanionBuilder,
          $$GoalStatisticsTableUpdateCompanionBuilder,
          (
            GoalStatistic,
            BaseReferences<_$AppDatabase, $GoalStatisticsTable, GoalStatistic>,
          ),
          GoalStatistic,
          PrefetchHooks Function()
        > {
  $$GoalStatisticsTableTableManager(
    _$AppDatabase db,
    $GoalStatisticsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalStatisticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalStatisticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalStatisticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> goalType = const Value.absent(),
                Value<int> totalGoals = const Value.absent(),
                Value<int> completedGoals = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> lastCompletedDate = const Value.absent(),
                Value<DateTime?> firstGoalDate = const Value.absent(),
                Value<double> completionRate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalStatisticsCompanion(
                id: id,
                goalType: goalType,
                totalGoals: totalGoals,
                completedGoals: completedGoals,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastCompletedDate: lastCompletedDate,
                firstGoalDate: firstGoalDate,
                completionRate: completionRate,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String goalType,
                Value<int> totalGoals = const Value.absent(),
                Value<int> completedGoals = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> lastCompletedDate = const Value.absent(),
                Value<DateTime?> firstGoalDate = const Value.absent(),
                Value<double> completionRate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalStatisticsCompanion.insert(
                id: id,
                goalType: goalType,
                totalGoals: totalGoals,
                completedGoals: completedGoals,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastCompletedDate: lastCompletedDate,
                firstGoalDate: firstGoalDate,
                completionRate: completionRate,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalStatisticsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalStatisticsTable,
      GoalStatistic,
      $$GoalStatisticsTableFilterComposer,
      $$GoalStatisticsTableOrderingComposer,
      $$GoalStatisticsTableAnnotationComposer,
      $$GoalStatisticsTableCreateCompanionBuilder,
      $$GoalStatisticsTableUpdateCompanionBuilder,
      (
        GoalStatistic,
        BaseReferences<_$AppDatabase, $GoalStatisticsTable, GoalStatistic>,
      ),
      GoalStatistic,
      PrefetchHooks Function()
    >;
typedef $$QuranDataTableTableCreateCompanionBuilder =
    QuranDataTableCompanion Function({
      Value<int> id,
      required String identifier,
      required String language,
      required String name,
      required String englishName,
      required String format,
      required String type,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$QuranDataTableTableUpdateCompanionBuilder =
    QuranDataTableCompanion Function({
      Value<int> id,
      Value<String> identifier,
      Value<String> language,
      Value<String> name,
      Value<String> englishName,
      Value<String> format,
      Value<String> type,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$QuranDataTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $QuranDataTableTable,
          QuranDataTableData
        > {
  $$QuranDataTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SurahTableTable, List<SurahTableData>>
  _surahTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.surahTable,
    aliasName: $_aliasNameGenerator(
      db.quranDataTable.id,
      db.surahTable.quranDataId,
    ),
  );

  $$SurahTableTableProcessedTableManager get surahTableRefs {
    final manager = $$SurahTableTableTableManager(
      $_db,
      $_db.surahTable,
    ).filter((f) => f.quranDataId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_surahTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuranDataTableTableFilterComposer
    extends Composer<_$AppDatabase, $QuranDataTableTable> {
  $$QuranDataTableTableFilterComposer({
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

  ColumnFilters<String> get identifier => $composableBuilder(
    column: $table.identifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> surahTableRefs(
    Expression<bool> Function($$SurahTableTableFilterComposer f) f,
  ) {
    final $$SurahTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.surahTable,
      getReferencedColumn: (t) => t.quranDataId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahTableTableFilterComposer(
            $db: $db,
            $table: $db.surahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuranDataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QuranDataTableTable> {
  $$QuranDataTableTableOrderingComposer({
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

  ColumnOrderings<String> get identifier => $composableBuilder(
    column: $table.identifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranDataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuranDataTableTable> {
  $$QuranDataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get identifier => $composableBuilder(
    column: $table.identifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> surahTableRefs<T extends Object>(
    Expression<T> Function($$SurahTableTableAnnotationComposer a) f,
  ) {
    final $$SurahTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.surahTable,
      getReferencedColumn: (t) => t.quranDataId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahTableTableAnnotationComposer(
            $db: $db,
            $table: $db.surahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuranDataTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuranDataTableTable,
          QuranDataTableData,
          $$QuranDataTableTableFilterComposer,
          $$QuranDataTableTableOrderingComposer,
          $$QuranDataTableTableAnnotationComposer,
          $$QuranDataTableTableCreateCompanionBuilder,
          $$QuranDataTableTableUpdateCompanionBuilder,
          (QuranDataTableData, $$QuranDataTableTableReferences),
          QuranDataTableData,
          PrefetchHooks Function({bool surahTableRefs})
        > {
  $$QuranDataTableTableTableManager(
    _$AppDatabase db,
    $QuranDataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranDataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranDataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranDataTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> identifier = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> englishName = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => QuranDataTableCompanion(
                id: id,
                identifier: identifier,
                language: language,
                name: name,
                englishName: englishName,
                format: format,
                type: type,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String identifier,
                required String language,
                required String name,
                required String englishName,
                required String format,
                required String type,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => QuranDataTableCompanion.insert(
                id: id,
                identifier: identifier,
                language: language,
                name: name,
                englishName: englishName,
                format: format,
                type: type,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuranDataTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({surahTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (surahTableRefs) db.surahTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (surahTableRefs)
                    await $_getPrefetchedData<
                      QuranDataTableData,
                      $QuranDataTableTable,
                      SurahTableData
                    >(
                      currentTable: table,
                      referencedTable: $$QuranDataTableTableReferences
                          ._surahTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$QuranDataTableTableReferences(
                            db,
                            table,
                            p0,
                          ).surahTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.quranDataId == item.id,
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

typedef $$QuranDataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuranDataTableTable,
      QuranDataTableData,
      $$QuranDataTableTableFilterComposer,
      $$QuranDataTableTableOrderingComposer,
      $$QuranDataTableTableAnnotationComposer,
      $$QuranDataTableTableCreateCompanionBuilder,
      $$QuranDataTableTableUpdateCompanionBuilder,
      (QuranDataTableData, $$QuranDataTableTableReferences),
      QuranDataTableData,
      PrefetchHooks Function({bool surahTableRefs})
    >;
typedef $$SurahTableTableCreateCompanionBuilder =
    SurahTableCompanion Function({
      Value<int> id,
      required int number,
      required String name,
      required String englishName,
      required String englishNameTranslation,
      required String revelationType,
      required int quranDataId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$SurahTableTableUpdateCompanionBuilder =
    SurahTableCompanion Function({
      Value<int> id,
      Value<int> number,
      Value<String> name,
      Value<String> englishName,
      Value<String> englishNameTranslation,
      Value<String> revelationType,
      Value<int> quranDataId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$SurahTableTableReferences
    extends BaseReferences<_$AppDatabase, $SurahTableTable, SurahTableData> {
  $$SurahTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuranDataTableTable _quranDataIdTable(_$AppDatabase db) =>
      db.quranDataTable.createAlias(
        $_aliasNameGenerator(db.surahTable.quranDataId, db.quranDataTable.id),
      );

  $$QuranDataTableTableProcessedTableManager get quranDataId {
    final $_column = $_itemColumn<int>('quran_data_id')!;

    final manager = $$QuranDataTableTableTableManager(
      $_db,
      $_db.quranDataTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quranDataIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AyahTableTable, List<AyahTableData>>
  _ayahTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ayahTable,
    aliasName: $_aliasNameGenerator(db.surahTable.id, db.ayahTable.surahId),
  );

  $$AyahTableTableProcessedTableManager get ayahTableRefs {
    final manager = $$AyahTableTableTableManager(
      $_db,
      $_db.ayahTable,
    ).filter((f) => f.surahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ayahTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SurahTableTableFilterComposer
    extends Composer<_$AppDatabase, $SurahTableTable> {
  $$SurahTableTableFilterComposer({
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

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishNameTranslation => $composableBuilder(
    column: $table.englishNameTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$QuranDataTableTableFilterComposer get quranDataId {
    final $$QuranDataTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quranDataId,
      referencedTable: $db.quranDataTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuranDataTableTableFilterComposer(
            $db: $db,
            $table: $db.quranDataTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ayahTableRefs(
    Expression<bool> Function($$AyahTableTableFilterComposer f) f,
  ) {
    final $$AyahTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ayahTable,
      getReferencedColumn: (t) => t.surahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahTableTableFilterComposer(
            $db: $db,
            $table: $db.ayahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SurahTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SurahTableTable> {
  $$SurahTableTableOrderingComposer({
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

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishNameTranslation => $composableBuilder(
    column: $table.englishNameTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuranDataTableTableOrderingComposer get quranDataId {
    final $$QuranDataTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quranDataId,
      referencedTable: $db.quranDataTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuranDataTableTableOrderingComposer(
            $db: $db,
            $table: $db.quranDataTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SurahTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurahTableTable> {
  $$SurahTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get englishName => $composableBuilder(
    column: $table.englishName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get englishNameTranslation => $composableBuilder(
    column: $table.englishNameTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$QuranDataTableTableAnnotationComposer get quranDataId {
    final $$QuranDataTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quranDataId,
      referencedTable: $db.quranDataTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuranDataTableTableAnnotationComposer(
            $db: $db,
            $table: $db.quranDataTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ayahTableRefs<T extends Object>(
    Expression<T> Function($$AyahTableTableAnnotationComposer a) f,
  ) {
    final $$AyahTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ayahTable,
      getReferencedColumn: (t) => t.surahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahTableTableAnnotationComposer(
            $db: $db,
            $table: $db.ayahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SurahTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SurahTableTable,
          SurahTableData,
          $$SurahTableTableFilterComposer,
          $$SurahTableTableOrderingComposer,
          $$SurahTableTableAnnotationComposer,
          $$SurahTableTableCreateCompanionBuilder,
          $$SurahTableTableUpdateCompanionBuilder,
          (SurahTableData, $$SurahTableTableReferences),
          SurahTableData,
          PrefetchHooks Function({bool quranDataId, bool ayahTableRefs})
        > {
  $$SurahTableTableTableManager(_$AppDatabase db, $SurahTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> englishName = const Value.absent(),
                Value<String> englishNameTranslation = const Value.absent(),
                Value<String> revelationType = const Value.absent(),
                Value<int> quranDataId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SurahTableCompanion(
                id: id,
                number: number,
                name: name,
                englishName: englishName,
                englishNameTranslation: englishNameTranslation,
                revelationType: revelationType,
                quranDataId: quranDataId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int number,
                required String name,
                required String englishName,
                required String englishNameTranslation,
                required String revelationType,
                required int quranDataId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SurahTableCompanion.insert(
                id: id,
                number: number,
                name: name,
                englishName: englishName,
                englishNameTranslation: englishNameTranslation,
                revelationType: revelationType,
                quranDataId: quranDataId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SurahTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({quranDataId = false, ayahTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (ayahTableRefs) db.ayahTable],
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
                        if (quranDataId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.quranDataId,
                                    referencedTable: $$SurahTableTableReferences
                                        ._quranDataIdTable(db),
                                    referencedColumn:
                                        $$SurahTableTableReferences
                                            ._quranDataIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ayahTableRefs)
                        await $_getPrefetchedData<
                          SurahTableData,
                          $SurahTableTable,
                          AyahTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SurahTableTableReferences
                              ._ayahTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SurahTableTableReferences(
                                db,
                                table,
                                p0,
                              ).ayahTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.surahId == item.id,
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

typedef $$SurahTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SurahTableTable,
      SurahTableData,
      $$SurahTableTableFilterComposer,
      $$SurahTableTableOrderingComposer,
      $$SurahTableTableAnnotationComposer,
      $$SurahTableTableCreateCompanionBuilder,
      $$SurahTableTableUpdateCompanionBuilder,
      (SurahTableData, $$SurahTableTableReferences),
      SurahTableData,
      PrefetchHooks Function({bool quranDataId, bool ayahTableRefs})
    >;
typedef $$AyahTableTableCreateCompanionBuilder =
    AyahTableCompanion Function({
      Value<int> id,
      required int number,
      required String audio,
      required String audioSecondary,
      required String textAr,
      required int numberInSurah,
      required int juz,
      required String textEn,
      required String textBn,
      required String transliteration,
      required int surahId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AyahTableTableUpdateCompanionBuilder =
    AyahTableCompanion Function({
      Value<int> id,
      Value<int> number,
      Value<String> audio,
      Value<String> audioSecondary,
      Value<String> textAr,
      Value<int> numberInSurah,
      Value<int> juz,
      Value<String> textEn,
      Value<String> textBn,
      Value<String> transliteration,
      Value<int> surahId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$AyahTableTableReferences
    extends BaseReferences<_$AppDatabase, $AyahTableTable, AyahTableData> {
  $$AyahTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SurahTableTable _surahIdTable(_$AppDatabase db) =>
      db.surahTable.createAlias(
        $_aliasNameGenerator(db.ayahTable.surahId, db.surahTable.id),
      );

  $$SurahTableTableProcessedTableManager get surahId {
    final $_column = $_itemColumn<int>('surah_id')!;

    final manager = $$SurahTableTableTableManager(
      $_db,
      $_db.surahTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_surahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AyahTableTableFilterComposer
    extends Composer<_$AppDatabase, $AyahTableTable> {
  $$AyahTableTableFilterComposer({
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

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audio => $composableBuilder(
    column: $table.audio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioSecondary => $composableBuilder(
    column: $table.audioSecondary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textAr => $composableBuilder(
    column: $table.textAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberInSurah => $composableBuilder(
    column: $table.numberInSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textEn => $composableBuilder(
    column: $table.textEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textBn => $composableBuilder(
    column: $table.textBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SurahTableTableFilterComposer get surahId {
    final $$SurahTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahId,
      referencedTable: $db.surahTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahTableTableFilterComposer(
            $db: $db,
            $table: $db.surahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AyahTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AyahTableTable> {
  $$AyahTableTableOrderingComposer({
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

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audio => $composableBuilder(
    column: $table.audio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioSecondary => $composableBuilder(
    column: $table.audioSecondary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textAr => $composableBuilder(
    column: $table.textAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberInSurah => $composableBuilder(
    column: $table.numberInSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textEn => $composableBuilder(
    column: $table.textEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textBn => $composableBuilder(
    column: $table.textBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SurahTableTableOrderingComposer get surahId {
    final $$SurahTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahId,
      referencedTable: $db.surahTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahTableTableOrderingComposer(
            $db: $db,
            $table: $db.surahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AyahTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AyahTableTable> {
  $$AyahTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get audio =>
      $composableBuilder(column: $table.audio, builder: (column) => column);

  GeneratedColumn<String> get audioSecondary => $composableBuilder(
    column: $table.audioSecondary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textAr =>
      $composableBuilder(column: $table.textAr, builder: (column) => column);

  GeneratedColumn<int> get numberInSurah => $composableBuilder(
    column: $table.numberInSurah,
    builder: (column) => column,
  );

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<String> get textEn =>
      $composableBuilder(column: $table.textEn, builder: (column) => column);

  GeneratedColumn<String> get textBn =>
      $composableBuilder(column: $table.textBn, builder: (column) => column);

  GeneratedColumn<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SurahTableTableAnnotationComposer get surahId {
    final $$SurahTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahId,
      referencedTable: $db.surahTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahTableTableAnnotationComposer(
            $db: $db,
            $table: $db.surahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AyahTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AyahTableTable,
          AyahTableData,
          $$AyahTableTableFilterComposer,
          $$AyahTableTableOrderingComposer,
          $$AyahTableTableAnnotationComposer,
          $$AyahTableTableCreateCompanionBuilder,
          $$AyahTableTableUpdateCompanionBuilder,
          (AyahTableData, $$AyahTableTableReferences),
          AyahTableData,
          PrefetchHooks Function({bool surahId})
        > {
  $$AyahTableTableTableManager(_$AppDatabase db, $AyahTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> audio = const Value.absent(),
                Value<String> audioSecondary = const Value.absent(),
                Value<String> textAr = const Value.absent(),
                Value<int> numberInSurah = const Value.absent(),
                Value<int> juz = const Value.absent(),
                Value<String> textEn = const Value.absent(),
                Value<String> textBn = const Value.absent(),
                Value<String> transliteration = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AyahTableCompanion(
                id: id,
                number: number,
                audio: audio,
                audioSecondary: audioSecondary,
                textAr: textAr,
                numberInSurah: numberInSurah,
                juz: juz,
                textEn: textEn,
                textBn: textBn,
                transliteration: transliteration,
                surahId: surahId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int number,
                required String audio,
                required String audioSecondary,
                required String textAr,
                required int numberInSurah,
                required int juz,
                required String textEn,
                required String textBn,
                required String transliteration,
                required int surahId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AyahTableCompanion.insert(
                id: id,
                number: number,
                audio: audio,
                audioSecondary: audioSecondary,
                textAr: textAr,
                numberInSurah: numberInSurah,
                juz: juz,
                textEn: textEn,
                textBn: textBn,
                transliteration: transliteration,
                surahId: surahId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AyahTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({surahId = false}) {
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
                    if (surahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.surahId,
                                referencedTable: $$AyahTableTableReferences
                                    ._surahIdTable(db),
                                referencedColumn: $$AyahTableTableReferences
                                    ._surahIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$AyahTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AyahTableTable,
      AyahTableData,
      $$AyahTableTableFilterComposer,
      $$AyahTableTableOrderingComposer,
      $$AyahTableTableAnnotationComposer,
      $$AyahTableTableCreateCompanionBuilder,
      $$AyahTableTableUpdateCompanionBuilder,
      (AyahTableData, $$AyahTableTableReferences),
      AyahTableData,
      PrefetchHooks Function({bool surahId})
    >;
typedef $$RecentlyReadEntriesTableCreateCompanionBuilder =
    RecentlyReadEntriesCompanion Function({
      Value<int> id,
      required int surahId,
      required int verseId,
      Value<String> source,
      Value<DateTime> timestamp,
    });
typedef $$RecentlyReadEntriesTableUpdateCompanionBuilder =
    RecentlyReadEntriesCompanion Function({
      Value<int> id,
      Value<int> surahId,
      Value<int> verseId,
      Value<String> source,
      Value<DateTime> timestamp,
    });

class $$RecentlyReadEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentlyReadEntriesTable> {
  $$RecentlyReadEntriesTableFilterComposer({
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

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseId => $composableBuilder(
    column: $table.verseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentlyReadEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentlyReadEntriesTable> {
  $$RecentlyReadEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseId => $composableBuilder(
    column: $table.verseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentlyReadEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentlyReadEntriesTable> {
  $$RecentlyReadEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get verseId =>
      $composableBuilder(column: $table.verseId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$RecentlyReadEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentlyReadEntriesTable,
          RecentlyReadEntry,
          $$RecentlyReadEntriesTableFilterComposer,
          $$RecentlyReadEntriesTableOrderingComposer,
          $$RecentlyReadEntriesTableAnnotationComposer,
          $$RecentlyReadEntriesTableCreateCompanionBuilder,
          $$RecentlyReadEntriesTableUpdateCompanionBuilder,
          (
            RecentlyReadEntry,
            BaseReferences<
              _$AppDatabase,
              $RecentlyReadEntriesTable,
              RecentlyReadEntry
            >,
          ),
          RecentlyReadEntry,
          PrefetchHooks Function()
        > {
  $$RecentlyReadEntriesTableTableManager(
    _$AppDatabase db,
    $RecentlyReadEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentlyReadEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentlyReadEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecentlyReadEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<int> verseId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => RecentlyReadEntriesCompanion(
                id: id,
                surahId: surahId,
                verseId: verseId,
                source: source,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahId,
                required int verseId,
                Value<String> source = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => RecentlyReadEntriesCompanion.insert(
                id: id,
                surahId: surahId,
                verseId: verseId,
                source: source,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentlyReadEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentlyReadEntriesTable,
      RecentlyReadEntry,
      $$RecentlyReadEntriesTableFilterComposer,
      $$RecentlyReadEntriesTableOrderingComposer,
      $$RecentlyReadEntriesTableAnnotationComposer,
      $$RecentlyReadEntriesTableCreateCompanionBuilder,
      $$RecentlyReadEntriesTableUpdateCompanionBuilder,
      (
        RecentlyReadEntry,
        BaseReferences<
          _$AppDatabase,
          $RecentlyReadEntriesTable,
          RecentlyReadEntry
        >,
      ),
      RecentlyReadEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$GoalPresetsTableTableManager get goalPresets =>
      $$GoalPresetsTableTableManager(_db, _db.goalPresets);
  $$DailyGoalsTableTableManager get dailyGoals =>
      $$DailyGoalsTableTableManager(_db, _db.dailyGoals);
  $$GoalProgressTableTableManager get goalProgress =>
      $$GoalProgressTableTableManager(_db, _db.goalProgress);
  $$GoalHistoryTableTableManager get goalHistory =>
      $$GoalHistoryTableTableManager(_db, _db.goalHistory);
  $$GoalNotificationsTableTableManager get goalNotifications =>
      $$GoalNotificationsTableTableManager(_db, _db.goalNotifications);
  $$GoalStatisticsTableTableManager get goalStatistics =>
      $$GoalStatisticsTableTableManager(_db, _db.goalStatistics);
  $$QuranDataTableTableTableManager get quranDataTable =>
      $$QuranDataTableTableTableManager(_db, _db.quranDataTable);
  $$SurahTableTableTableManager get surahTable =>
      $$SurahTableTableTableManager(_db, _db.surahTable);
  $$AyahTableTableTableManager get ayahTable =>
      $$AyahTableTableTableManager(_db, _db.ayahTable);
  $$RecentlyReadEntriesTableTableManager get recentlyReadEntries =>
      $$RecentlyReadEntriesTableTableManager(_db, _db.recentlyReadEntries);
}

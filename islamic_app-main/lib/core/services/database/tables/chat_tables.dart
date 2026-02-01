import 'package:drift/drift.dart';

// Chat session table to store different chat histories
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

// Chat messages table to store all messages
@DataClassName('ChatMessageData')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ChatSessions, #id)();
  TextColumn get message => text()();
  TextColumn get messageType => text()(); // 'user' or 'bot'
  DateTimeColumn get timestamp => dateTime().withDefault(Constant(DateTime.now()))();
  TextColumn get references => text().nullable()(); // Storing references as JSON string
} 
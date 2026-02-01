import 'package:drift/drift.dart';
import 'package:deenhub/core/services/database/app_database.dart';
import 'package:deenhub/core/services/database/tables/chat_tables.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [ChatSessions, ChatMessages])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  // Get all chat sessions
  Future<List<ChatSession>> getAllChatSessions() {
    return (select(chatSessions)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
  }

  // Get a specific chat session with its messages
  Future<List<ChatMessageData>> getSessionMessages(int sessionId) {
    return (select(chatMessages)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  // Create a new chat session
  Future<int> createChatSession(String title) async {
    return into(chatSessions).insert(
      ChatSessionsCompanion.insert(
        title: title,
      ),
    );
  }

  // Update chat session title
  Future<int> updateChatSessionTitle(int id, String title) async {
    return (update(chatSessions)..where((t) => t.id.equals(id)))
        .write(ChatSessionsCompanion(title: Value(title)));
  }

  // Update chat session timestamp
  Future<int> updateChatSessionTimestamp(int id) async {
    return (update(chatSessions)..where((t) => t.id.equals(id)))
        .write(ChatSessionsCompanion(updatedAt: Value(DateTime.now())));
  }

  // Delete a chat session and its messages
  Future<void> deleteChatSession(int sessionId) async {
    // Use a transaction to ensure both operations succeed or fail together
    await transaction(() async {
      // Delete all messages for the session
      await (delete(chatMessages)..where((t) => t.sessionId.equals(sessionId))).go();
      // Delete the session
      await (delete(chatSessions)..where((t) => t.id.equals(sessionId))).go();
    });
  }

  // Add a new message to a session
  Future<int> addMessage(int sessionId, String message, String messageType, String? references) {
    return into(chatMessages).insert(
      ChatMessagesCompanion.insert(
        sessionId: sessionId,
        message: message,
        messageType: messageType,
        references: Value(references),
      ),
    );
  }

  // Get the most recent session
  Future<ChatSession?> getMostRecentSession() async {
    final query = select(chatSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
      ..limit(1);

    final results = await query.get();
    if (results.isEmpty) {
      return null;
    }
    return results.first;
  }
} 
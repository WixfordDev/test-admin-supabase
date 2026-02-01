import 'dart:convert';

import 'package:deenhub/core/services/database/app_database.dart';
import 'package:deenhub/core/services/database/daos/chat_dao.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/chat_message.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/reference_detector.dart';
import 'package:flutter/foundation.dart';

/// Service class for managing chat history using drift database
class ChatHistoryService {
  final AppDatabase _database;

  ChatHistoryService(this._database);

  // Get the DAO
  ChatDao get _chatDao => _database.chatDao;

  // Create a new chat session with initial message if provided
  Future<int> createChatSession({String title = "New Chat", ChatMessage? initialMessage}) async {
    final sessionId = await _chatDao.createChatSession(title);
    
    if (initialMessage != null) {
      await addMessageToSession(sessionId, initialMessage);
    }
    
    return sessionId;
  }

  // Get all chat sessions
  Future<List<ChatSession>> getAllChatSessions() async {
    return await _chatDao.getAllChatSessions();
  }

  // Get messages for a specific session
  Future<List<ChatMessage>> getSessionMessages(int sessionId) async {
    final dbMessages = await _chatDao.getSessionMessages(sessionId);
    
    // Convert from database model to domain model
    return dbMessages.map((dbMessage) {
      List<IslamicReference> references = [];
      
      // Parse references if they exist
      if (dbMessage.references != null) {
        try {
          final refsJson = jsonDecode(dbMessage.references!) as List;
          references = refsJson
              .map((ref) => IslamicReference.fromJson(ref))
              .toList();
        } catch (e) {
          debugPrint('Error parsing references: $e');
        }
      }
      
      return ChatMessage(
        message: dbMessage.message,
        type: dbMessage.messageType == 'user' ? MessageType.user : MessageType.bot,
        timestamp: dbMessage.timestamp,
        references: references,
      );
    }).toList();
  }

  // Add a message to an existing session
  Future<void> addMessageToSession(int sessionId, ChatMessage message) async {
    // Convert references to JSON
    String? referencesJson;
    if (message.references.isNotEmpty) {
      referencesJson = jsonEncode(
        message.references.map((ref) => ref.toJson()).toList()
      );
    }
    
    // Add message to database
    await _chatDao.addMessage(
      sessionId,
      message.message,
      message.isUser ? 'user' : 'bot',
      referencesJson,
    );
    
    // Update session timestamp
    await _chatDao.updateChatSessionTimestamp(sessionId);
  }

  // Get the most recent session
  Future<ChatSession?> getMostRecentSession() async {
    return await _chatDao.getMostRecentSession();
  }

  // Delete a chat session
  Future<void> deleteChatSession(int sessionId) async {
    await _chatDao.deleteChatSession(sessionId);
  }

  // Update a chat session title
  Future<void> updateSessionTitle(int sessionId, String title) async {
    await _chatDao.updateChatSessionTitle(sessionId, title);
  }

  // Save a list of messages to a new or existing session
  Future<int> saveChatHistory(List<ChatMessage> messages, {int? existingSessionId, String? title}) async {
    int sessionId;
    
    if (existingSessionId != null) {
      // Use existing session
      sessionId = existingSessionId;
      
      // Delete all existing messages for this session using deleteSession and recreating it
      final session = (await _chatDao.getAllChatSessions())
        .firstWhere((s) => s.id == sessionId);
        
      await _chatDao.deleteChatSession(sessionId);
      sessionId = await _chatDao.createChatSession(session.title);
    } else {
      // Create new session
      sessionId = await _chatDao.createChatSession(title ?? "Chat ${DateTime.now().toIso8601String()}");
    }
    
    // Add all messages
    for (final message in messages) {
      await addMessageToSession(sessionId, message);
    }
    
    return sessionId;
  }
} 
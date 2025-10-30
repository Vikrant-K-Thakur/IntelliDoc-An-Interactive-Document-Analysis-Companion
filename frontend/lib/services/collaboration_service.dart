import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:docuverse/shared/models/models.dart';

class CollaborationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserName => _auth.currentUser?.displayName ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';

  // User Management
  Future<void> createUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoURL: user.photoURL,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        isOnline: true,
      );
      await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore());
    }
  }

  Future<void> updateUserOnlineStatus(bool isOnline) async {
    if (currentUserId.isEmpty) return;
    await _firestore.collection('users').doc(currentUserId).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .where('email', isNotEqualTo: currentUserEmail)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    final snapshot = await _firestore
        .collection('users')
        .where('email', isNotEqualTo: currentUserEmail)
        .get();
    
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => 
            user.displayName.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Friend Request Management
  Future<void> sendFriendRequest(String receiverId, String receiverName, String receiverEmail) async {
    if (currentUserId.isEmpty) return;

    // Check if request already exists
    final existingRequest = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequest.docs.isNotEmpty) return;

    final request = FriendRequestModel(
      id: '',
      senderId: currentUserId,
      receiverId: receiverId,
      senderName: currentUserName,
      senderEmail: currentUserEmail,
      status: FriendRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('friendRequests').add(request.toFirestore());
  }

  Stream<List<FriendRequestModel>> getReceivedFriendRequests() {
    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequestModel.fromFirestore(doc))
            .toList());
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    final requestDoc = await _firestore.collection('friendRequests').doc(requestId).get();
    if (!requestDoc.exists) return;

    final request = FriendRequestModel.fromFirestore(requestDoc);
    
    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': accept ? 'accepted' : 'rejected',
      'respondedAt': Timestamp.fromDate(DateTime.now()),
    });

    if (accept) {
      // Create friendship
      await _createFriendship(request.senderId, request.receiverId);
    }
  }

  Future<void> _createFriendship(String userId1, String userId2) async {
    final batch = _firestore.batch();
    
    // Add to user1's friends
    batch.set(_firestore.collection('users').doc(userId1).collection('friends').doc(userId2), {
      'friendId': userId2,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    
    // Add to user2's friends
    batch.set(_firestore.collection('users').doc(userId2).collection('friends').doc(userId1), {
      'friendId': userId1,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    
    await batch.commit();
  }

  Stream<List<UserModel>> getFriends() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
      List<UserModel> friends = [];
      for (var doc in snapshot.docs) {
        final friendDoc = await _firestore.collection('users').doc(doc.id).get();
        if (friendDoc.exists) {
          friends.add(UserModel.fromFirestore(friendDoc));
        }
      }
      return friends;
    });
  }

  // Chat Management
  Future<String> createOrGetChat(String friendId, String friendName) async {
    final participants = [currentUserId, friendId]..sort();
    final chatId = participants.join('_');

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!chatDoc.exists) {
      final chat = ChatModel(
        id: chatId,
        participants: participants,
        participantNames: {
          currentUserId: currentUserName,
          friendId: friendName,
        },
        createdAt: DateTime.now(),
        unreadCount: {currentUserId: 0, friendId: 0},
      );
      await _firestore.collection('chats').doc(chatId).set(chat.toFirestore());
    }
    
    return chatId;
  }

  Stream<List<ChatModel>> getUserChats() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromFirestore(doc))
            .toList());
  }

  Future<void> sendMessage(String chatId, String content, {MessageType type = MessageType.text, String? fileUrl, String? fileName, String? fileType}) async {
    final message = ChatMessageModel(
      id: '',
      chatId: chatId,
      senderId: currentUserId,
      senderName: currentUserName,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
    );

    await _firestore.collection('messages').add(message.toFirestore());

    // Update chat with last message
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      'lastMessageSender': currentUserId,
    });
  }

  Stream<List<ChatMessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList());
  }

  Future<bool> areFriends(String userId) async {
    final friendDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(userId)
        .get();
    return friendDoc.exists;
  }

  Future<bool> hasPendingRequest(String userId) async {
    final request = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();
    return request.docs.isNotEmpty;
  }
}
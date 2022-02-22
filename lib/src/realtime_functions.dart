/// Creates a chat group room with [users]. Creator is automatically
/// added to the group. [name] is required and will be used as
/// a group name. Add an optional [imageUrl] that will be a group avatar
/// and [metadata] for any additional custom data.
///
///
///
///

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'utils/realtime_util.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class RealTimeFunctions {
  User? firebaseUser;
  FirebaseDatabase firebaseRealTime;
  FirebaseChatCoreConfig config;
  RealTimeFunctions(
      {this.firebaseUser,
      required this.firebaseRealTime,
      required this.config});

  Future<types.Room> createGroupRoom({
    String? imageUrl,
    Map<String, dynamic>? metadata,
    required String name,
    required List<types.User> users,
  }) async {
    if (firebaseUser == null) return Future.error('User does not exist');

    final currentUser = await fetchUser(
      firebaseRealTime,
      firebaseUser!.uid,
      config.usersCollectionName,
    );

    final roomUsers = [types.User.fromJson(currentUser)] + users;

    final room = await firebaseRealTime.ref(config.roomsCollectionName).set({
      'imageUrl': imageUrl,
      'metadata': metadata,
      'name': name,
      'type': types.RoomType.group.toShortString(),
      'userIds': roomUsers.map((u) => u.id).toList(),
      'userRoles': roomUsers.fold<Map<String, String?>>(
        {},
        (previousValue, user) => {
          ...previousValue,
          user.id: user.role?.toShortString(),
        },
      ),
    });

    return types.Room(
      id: '',
      imageUrl: imageUrl,
      metadata: metadata,
      name: name,
      type: types.RoomType.group,
      users: roomUsers,
    );
  }

  /// Creates a direct chat for 2 people. Add [metadata] for any additional
  /// custom data.
  Future<types.Room> createRoom(
    types.User otherUser, {
    Map<String, dynamic>? metadata,
  }) async {
    // final fu = firebaseUser;

    // if (fu == null) return Future.error('User does not exist');

    // final query = await firebaseRealTime
    //     .ref(config.roomsCollectionName)
    //     // .where('userIds', arrayContains: fu.uid)
    //     .get();

    // final rooms = await processRoomsQuery(
    //   fu,
    //   firebaseRealTime,
    //   query,
    //   config.usersCollectionName,
    // );

    // try {
    //   return rooms.firstWhere((room) {
    //     if (room.type == types.RoomType.group) return false;

    //     final userIds = room.users.map((u) => u.id);
    //     return userIds.contains(fu.uid) && userIds.contains(otherUser.id);
    //   });
    // } catch (e) {
    //   // Do nothing if room does not exist
    //   // Create a new room instead
    // }

    // final currentUser = await fetchUser(
    //   firebaseRealTime,
    //   fu.uid,
    //   config.usersCollectionName,
    // );

    // final users = [types.User.fromJson(currentUser), otherUser];

    // final room = await firebaseRealTime.ref(config.roomsCollectionName).set({
    //   // 'createdAt': FieldValue.serverTimestamp(),
    //   'imageUrl': null,
    //   'metadata': metadata,
    //   'name': null,
    //   'type': types.RoomType.direct.toShortString(),
    //   //'updatedAt': FieldValue.serverTimestamp(),
    //   'userIds': users.map((u) => u.id).toList(),
    //   'userRoles': null,
    // });

    // return types.Room(
    //   id: '',
    //   metadata: metadata,
    //   type: types.RoomType.direct,
    //   users: users,
    // );
    return null!;
  }

  /// Creates [types.User] in Firebase to store name and avatar used on
  /// rooms list
  Future<void> createUserInRealTimeDB(types.User user) async {
    await firebaseRealTime.ref(config.usersCollectionName).child(user.id).set({
      //'createdAt': FieldValue.serverTimestamp(),
      'firstName': user.firstName,
      'imageUrl': user.imageUrl,
      'lastName': user.lastName,
      'lastSeen': user.lastSeen,
      'metadata': user.metadata,
      'role': user.role?.toShortString(),
      //'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes message document
  Future<void> deleteMessage(String roomId, String messageId) async {
    await firebaseRealTime
        .ref('${config.roomsCollectionName}/$roomId/messages')
        .child(messageId)
        .remove();
  }

  /// Removes room document
  Future<void> deleteRoom(String roomId) async {
    await firebaseRealTime
        .ref(config.roomsCollectionName)
        .child(roomId)
        .remove();
  }

  /// Removes [types.User] from `users` collection in Firebase
  Future<void> deleteUserFromFirestore(String userId) async {
    await firebaseRealTime
        .ref(config.usersCollectionName)
        .child(userId)
        .remove();
  }

  /// Returns a stream of messages from Firebase for a given room
  Stream<List<types.Message>> messages(
    types.Room room, {
    List<Object?>? endAt,
    List<Object?>? endBefore,
    int? limit,
    List<Object?>? startAfter,
    List<Object?>? startAt,
  }) {
    var query = firebaseRealTime
        .ref('${config.roomsCollectionName}/${room.id}/messages');

    //.orderBy('createdAt', descending: true);

    // if (endAt != null) {
    //   query = query.endAt(endAt);
    // }

    // if (endBefore != null) {
    //   query = query.endBefore(endBefore);
    // }

    // if (limit != null) {
    //   query = query.limit(limit);
    // }

    // if (startAfter != null) {
    //   query = query.startAfter(startAfter);
    // }

    // if (startAt != null) {
    //   query = query.startAt(startAt);
    // }

    // return query.on().map(
    //   (snapshot) {
    //     return snapshot.docs.fold<List<types.Message>>(
    //       [],
    //       (previousValue, doc) {
    //         final data = doc.data();
    //         final author = room.users.firstWhere(
    //           (u) => u.id == data['authorId'],
    //           orElse: () => types.User(id: data['authorId'] as String),
    //         );

    //         data['author'] = author.toJson();
    //         data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
    //         data['id'] = doc.id;
    //         data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

    //         return [...previousValue, types.Message.fromJson(data)];
    //       },
    //     );
    //   },
    // );
    return Stream.empty();
  }

  /// Returns a stream of changes in a room from Firebase
  Stream<types.Room> room(String roomId) {
    // final fu = firebaseUser;

    // if (fu == null) return const Stream.empty();

    // return firebaseRealTime
    //     .ref(config.roomsCollectionName)
    //     .child(roomId)
    //     .onValue
    //     .asyncMap(
    //       (doc) => processRoomDocument(
    //         doc,
    //         fu,
    //         firebaseRealTime,
    //         config.usersCollectionName,
    //       ),
    //     );
    return Stream.empty();
  }

  /// Returns a stream of rooms from Firebase. Only rooms where current
  /// logged in user exist are returned. [orderByUpdatedAt] is used in case
  /// you want to have last modified rooms on top, there are a couple
  /// of things you will need to do though:
  /// 1) Make sure `updatedAt` exists on all rooms
  /// 2) Write a Cloud Function which will update `updatedAt` of the room
  /// when the room changes or new messages come in
  /// 3) Create an Index (Firestore Database -> Indexes tab) where collection ID
  /// is `rooms`, field indexed are `userIds` (type Arrays) and `updatedAt`
  /// (type Descending), query scope is `Collection`
  Stream<List<types.Room>> rooms({bool orderByUpdatedAt = false}) {
    // final fu = firebaseUser;

    // if (fu == null) return const Stream.empty();

    // final collection = orderByUpdatedAt
    //     ? firebaseRealTime
    //         .ref(config.roomsCollectionName)
    //         // .where('userIds', arrayContains: fu.uid)
    //         .orderByChild('updatedAt')
    //     : firebaseRealTime.ref(config.roomsCollectionName);
    // //.where('userIds', arrayContains: fu.uid);

    // return collection.get().asStream().asyncMap(
    //       (query) => processRoomsQuery(
    //         fu,
    //         firebaseRealTime,
    //         query as DataSnapshot,
    //         config.usersCollectionName,
    //       ),
    //     );
    return Stream.empty();
  }

  /// Sends a message to the Firestore. Accepts any partial message and a
  /// room ID. If arbitraty data is provided in the [partialMessage]
  /// does nothing.
  void sendMessage(dynamic partialMessage, String roomId) async {
    if (firebaseUser == null) return;

    types.Message? message;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialText: partialMessage,
      );
    }

    if (message != null) {
      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = firebaseUser!.uid;
      // messageMap['createdAt'] = FieldValue.serverTimestamp();
      // messageMap['updatedAt'] = FieldValue.serverTimestamp();

      await firebaseRealTime
          .ref('${config.roomsCollectionName}/$roomId/messages')
          .set(messageMap);
    }
  }

  /// Updates a message in the Firestore. Accepts any message and a
  /// room ID. Message will probably be taken from the [messages] stream.
  void updateMessage(types.Message message, String roomId) async {
    if (firebaseUser == null) return;
    if (message.author.id != firebaseUser!.uid) return;

    final messageMap = message.toJson();
    messageMap.removeWhere(
        (key, value) => key == 'author' || key == 'createdAt' || key == 'id');
    messageMap['authorId'] = message.author.id;
    // messageMap['updatedAt'] = FieldValue.serverTimestamp();

    await firebaseRealTime
        .ref('${config.roomsCollectionName}/$roomId/messages')
        .child(message.id)
        .update(messageMap);
  }

  /// Updates a room in the Firestore. Accepts any room.
  /// Room will probably be taken from the [rooms] stream.
  void updateRoom(types.Room room) async {
    if (firebaseUser == null) return;

    final roomMap = room.toJson();
    roomMap.removeWhere((key, value) =>
        key == 'createdAt' ||
        key == 'id' ||
        key == 'lastMessages' ||
        key == 'users');

    if (room.type == types.RoomType.direct) {
      roomMap['imageUrl'] = null;
      roomMap['name'] = null;
    }

    roomMap['lastMessages'] = room.lastMessages?.map((m) {
      final messageMap = m.toJson();

      messageMap.removeWhere((key, value) =>
          key == 'author' ||
          key == 'createdAt' ||
          key == 'id' ||
          key == 'updatedAt');

      messageMap['authorId'] = m.author.id;

      return messageMap;
    }).toList();
    // roomMap['updatedAt'] = FieldValue.serverTimestamp();
    roomMap['userIds'] = room.users.map((u) => u.id).toList();

    await firebaseRealTime
        .ref(config.roomsCollectionName)
        .child(room.id)
        .update(roomMap);
  }

  /// Returns a stream of all users from Firebase
  Stream<List<types.User>> users() {
    if (firebaseUser == null) return const Stream.empty();
    return firebaseRealTime
        .ref(config.usersCollectionName)
        .get()
        .asStream()
        .map(
          (snapshot) => snapshot.children.fold<List<types.User>>(
            [],
            (previousValue, doc) {
              if (firebaseUser!.uid == doc.key) return previousValue;

              final data = doc.value as Map<String, dynamic>;

              data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
              data['id'] = '';
              data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
              data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

              return [...previousValue, types.User.fromJson(data)];
            },
          ),
        );
  }
}

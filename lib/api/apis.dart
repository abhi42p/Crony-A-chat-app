import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crony/models/chat_user.dart';
import 'package:crony/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class APIs{
  // For authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For storing self info
  static late ChatUser me;

  // To return current user
  static User get user => auth.currentUser!;

  // For accessing firebase messaging services
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // For getting firebase messging token
  static Future<void> getFirebaseMessagingToken()async{
    await fMessaging.requestPermission();
    
    await fMessaging.getToken().then((t){
      if(t != null){
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  // For accessing Cloud Firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For checking if user is exist or not ?
  static Future<bool> userExist()async{
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .get()
     ).exists;
  }

  static Future<void> getSefInfo()async{
    await firestore
        .collection('users')
        .doc(user.uid)
        .get().then((user) async {
          if(user.exists){
            me = ChatUser.fromJson(user.data()!);
            await getFirebaseMessagingToken();
            log('My Data: ${user.data()}');
          }
          else{
            await createUser().then((value) => getSefInfo());
          }
    });
  }

  // For creating a new user
  static Future<void> createUser()async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: 'Hey, ',
        name: user.displayName.toString(),
        createdAt: time,
        isOnline: false,
        id: user.uid,
        lastActive: time,
        email: user.email.toString(),
        pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(){
    return firestore.collection('users').where('id', isNotEqualTo: user.uid).snapshots();
  }

  // For updating user info

  static Future<void> updateUserInfo()async{
    await firestore
        .collection('users')
        .doc(user.uid).update({'name': me.name, 'about': me.about});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser){
    return firestore.collection('users').where('id', isEqualTo: chatUser.id).snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline)async{
    firestore
        .collection('users')
        .doc(user.uid)
        .update({'is_online': isOnline, 'last_active': DateTime.now().millisecondsSinceEpoch.toString(), 'push_token': me.pushToken});
  }


//   -----------chatScreen related Api's------------------------

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';


  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages').snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg)async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(toId: chatUser.id, msg: msg, read: '', type: Type.text, fromId: user.uid, sent: time);

    final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages');

    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message)async{
    firestore.collection('chats/${getConversationID(message.fromId)}/messages').doc(message.sent).update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user){
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

}
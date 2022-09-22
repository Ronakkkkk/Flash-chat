import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final users = _auth.currentUser;
      if (users != null) {
        loggedInUser = users;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0D0702),
      // appBar: AppBar(
      //   leading: null,
      //   actions: <Widget>[
      //     IconButton(
      //         icon: Icon(Icons.close),
      //         onPressed: () {
      //           _auth.signOut();
      //           Navigator.pop(context);
      //         }),
      //   ],
      //   title: Text(
      //     'School Group',
      //     style: TextStyle(color: Color(0xffFBF1D1)),
      //   ),
      //   backgroundColor: Color(0xff0D0702),
      // ),
      body: SafeArea(
          child: Container(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Container(
                  color: Color(0xff0D0702),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff2E3030),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_outlined)),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xffFCF4D2),
                            radius: 25,
                            child: SizedBox(
                              height: 32,
                              width: 32,
                              child:
                                  Image(image: AssetImage('images/beard.png')),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nishant Shahi',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffFFFFFF)),
                              ),
                              Text(
                                'Online',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xff716C6A)),
                              )
                            ],
                          )
                        ],
                      ),
                      Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff2E3030),
                          ),
                          child: Icon(Icons.more_vert_outlined))
                    ],
                  ),
                )),
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50)),
                        color: Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        MessagesStream(),
                        Container(
                          margin: EdgeInsets.all(20),
                          height: 70,
                          width: 330,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Color(0xffF1F1F2)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffD8CCF4)),
                                child: TextButton(
                                    onPressed: () {
                                      messageTextController.clear();
                                      _firestore.collection('messages').add({
                                        'text': messageText,
                                        'sender': loggedInUser.email,
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.mic_outlined,
                                          color: Color(0xff8E69DB),
                                        ),
                                      ],
                                    )),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: messageTextController,
                                  onChanged: (value) {
                                    messageText = value;
                                  },
                                  decoration: kMessageTextFieldDecoration,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffc8e9ff)),
                                child: TextButton(
                                    onPressed: () {
                                      messageTextController.clear();
                                      _firestore.collection('messages').add({
                                        'text': messageText,
                                        'sender': loggedInUser.email,
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.send_outlined,
                                          color: Color(0xff6DB1E3),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   sender,
          //   style: TextStyle(
          //     fontSize: 12.0,
          //     color: Colors.blueGrey,
          //   ),
          // ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Color(0xffD1D0D5) : Color(0xffFBF1D1),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

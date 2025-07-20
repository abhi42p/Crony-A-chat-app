import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crony/api/apis.dart';
import 'package:crony/helper/my_date_util.dart';
import 'package:crony/main.dart';
import 'package:crony/models/chat_user.dart';
import 'package:crony/models/message.dart';
import 'package:crony/screens/view_profile_screen.dart';
import 'package:crony/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {

  List<Message> _list = [];

  final _textController = TextEditingController();

  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    // Set the status bar color and brightness
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness: Brightness.light, // Set icons to light (white)
    ));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, __) {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return;
            }
            // some delay before pop
            Future.delayed(const Duration(milliseconds: 100), () {
              try {
                if (Navigator.canPop(context)) Navigator.pop(context);
              } catch (e) {
                log('ErrorPop: $e');
              }
            });
          },
          child: Scaffold(
            extendBodyBehindAppBar: true, // Extend the body behind the app bar
            appBar: AppBar(
              backgroundColor: Colors.transparent, // Make app bar transparent
              elevation: 0, // Remove shadow
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.blue,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top:60),
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                          stream: APIs.getAllMessages(widget.user),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                            //if data is loading
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const SizedBox();
          
                            //if some or all data is loaded then show it
                              case ConnectionState.active:
                              case ConnectionState.done:
          
                                final data = snapshot.data?.docs;
                                _list = data?.map((e) => Message.fromJson(e.data())).toList()??[];
          
                                if(_list.isNotEmpty){
                                  return ListView.builder(itemCount: _list.length,padding: EdgeInsets.only(top: mq.height * 0.01),physics: BouncingScrollPhysics(),itemBuilder: (context , index){
                                    return MessageCard(message: _list[index],);
                                  });
                                }
                                else{
                                  return const Center(child: Text('Say Hii! 👋',style: TextStyle(fontSize: 25,color: Colors.white),));
                                }
                            }
                          },
                      ),
                    ),
                    _chatMsg(),
          if(_showEmoji)
          SizedBox(
            height: mq.height *.35,
            child: EmojiPicker(
            textEditingController: _textController,
            config: Config(
              height: 256,
              checkPlatformCompatibility: true,
              emojiViewConfig: EmojiViewConfig(
                backgroundColor: Colors.grey,
                emojiSizeMax: 28 *
                    (Platform.isIOS
                        ?  1.20
                        :  1.0),
              ),
            ),
                ),
          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(stream: APIs.getUserInfo(widget.user), builder: (context, snapshot){

        final data = snapshot.data?.docs;
        final list = data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];
        // if(list.isNotEmpty){
        //   _message = list[0];
        // }

        return Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back on press
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: mq.width * .02),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: mq.width * .13,
                  height: mq.height * .06,
                  fit: BoxFit.cover,
                  imageUrl: list.isNotEmpty?list[0].image: widget.user.image,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list.isNotEmpty ? list[0].name : widget.user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  list.isNotEmpty ? list[0].isOnline ? 'Online' : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive) : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
  Widget _chatMsg(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height * .01,horizontal: mq.width * .02),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.black12,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(child: TextField(
                    onTap: (){
                      if(_showEmoji) {
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Type Something...',
                      border: InputBorder.none
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,

                  )),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(onPressed: (){
            if(_textController.text.isNotEmpty){
              APIs.sendMessage(widget.user, _textController.text);
              _textController.text = '';
            }
          },minWidth: 0 ,padding: EdgeInsets.only(top: 10,bottom: 10,right: 5, left: 10),shape: const CircleBorder(),color: Colors.blue,child: Icon(Icons.send),)
        ],
      ),
    );
  }
}
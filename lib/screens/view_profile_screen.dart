import 'package:cached_network_image/cached_network_image.dart';
import 'package:crony/helper/my_date_util.dart';
import 'package:crony/main.dart';
import 'package:crony/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  ViewProfileScreenState createState() => ViewProfileScreenState();
}

class ViewProfileScreenState extends State<ViewProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
          centerTitle: true,
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined on: ',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
            Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true),
                style: const TextStyle(
                    color: Colors.black, fontSize: 19)),
            SizedBox(height: mq.height * .1,)
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(width: mq.width, height: mq.height * 0.05,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .3),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: mq.height * .2,
                    width: mq.height * .2,
                    imageUrl: widget.user.image,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                    const CircleAvatar(child: Icon(CupertinoIcons.person),),
                  ),
                ),
                SizedBox(height: mq.height * .05,),
                Text(
                  widget.user.email, style: TextStyle(color: Colors.black,fontSize: 20),),
                SizedBox(height: mq.height * .03,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About: ',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    ),
                    Text(widget.user.about,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 19)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
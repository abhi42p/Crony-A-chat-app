import 'package:cached_network_image/cached_network_image.dart';
import 'package:crony/api/apis.dart';
import 'package:crony/helper/my_date_util.dart';
import 'package:crony/main.dart';
import 'package:crony/models/chat_user.dart';
import 'package:crony/models/message.dart';
import 'package:crony/screens/chat_screen.dart';
import 'package:crony/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  ChatUserCardState createState() => ChatUserCardState();
}

class ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 5),
      elevation: 2,
      color: colorScheme.surface, // ✅ theme-aware background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data
                  ?.map((e) => Message.fromJson(e.data()))
                  .toList() ??
                  [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(user: widget.user),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.width * .13,
                      height: mq.height * .06,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
                title: Text(
                  widget.user.name,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _message != null ? _message!.msg : widget.user.about,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                    _message!.fromId != APIs.user.uid
                    ? Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
                    : Text(
                  MyDateUtil.getLastMessageTime(
                    context: context,
                    time: _message!.sent,
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color
                        ?.withOpacity(0.7),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
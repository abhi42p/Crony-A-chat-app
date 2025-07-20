import 'package:cached_network_image/cached_network_image.dart';
import 'package:crony/main.dart';
import 'package:crony/models/chat_user.dart';
import 'package:crony/screens/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatefulWidget{
  const ProfileDialog ({super.key, required this.user});
  ProfileDialogState createState() => ProfileDialogState();
  final ChatUser user;
}
class ProfileDialogState extends State<ProfileDialog>{
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .8,
        height: mq.height * .35,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .06,vertical: mq.height * .01),
              child: Text(widget.user.name,style: TextStyle(color: Colors.white,fontSize: 25,),),
            ),
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  height: mq.height * .25,
                  width: mq.height * .25,
                  imageUrl: widget.user.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
                ),
              ),
            ),
            Align(alignment: Alignment.topRight,child: MaterialButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (_)=> ViewProfileScreen(user: widget.user)));
            },child: Icon(Icons.info_outlined,color: Colors.white,size: 35),))
          ],
        ),
      ),
    );
  }
}
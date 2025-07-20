import 'package:crony/api/apis.dart';
import 'package:crony/helper/my_date_util.dart';
import 'package:crony/main.dart';
import 'package:crony/models/message.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget{
  const MessageCard({super.key,required this.message});

  final Message message;

  @override
  MessageCardState createState() => MessageCardState();
}

class MessageCardState extends State<MessageCard>{
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId ? _sender() : _receiver();
  }
  Widget _sender(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .05,),

            // double tick blue
            if(widget.message.read.isNotEmpty)
            const Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),
            const SizedBox(width: 5,),
            Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),style: const TextStyle(fontSize: 13,color: Colors.white60),),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.height * .02),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04,vertical: mq.height * .01),
            decoration: BoxDecoration(color: Colors.teal,border: Border.all(color: Colors.white),borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30),bottomLeft: Radius.circular(30))),
            child: Text(widget.message.msg,style: const TextStyle(fontSize: 15,color: Colors.white),),
          ),
        ),
      ],
    );
  }
  Widget _receiver(){
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.height * .02),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04,vertical: mq.height * .01),
            decoration: BoxDecoration(color: Colors.blue,border: Border.all(color: Colors.white),borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30),bottomRight: Radius.circular(30))),
            child: Text(widget.message.msg,style: const TextStyle(fontSize: 15,color: Colors.white),),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),style: const TextStyle(fontSize: 13,color: Colors.white60),),
        )
      ],
    );
  }
}
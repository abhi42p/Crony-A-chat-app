import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crony/api/apis.dart';
import 'package:crony/helper/dialogs.dart';
import 'package:crony/main.dart';
import 'package:crony/models/chat_user.dart';
import 'package:crony/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: true,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            onPressed: ()async{
              Dialogs.showProgressbar(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value)async{
                await GoogleSignIn().signOut().then((value){
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                });
              });

            },icon: const Icon(Icons.logout),label: const Text('Logout'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * 0.05,),
                  Stack(
                    children: [
                      _image != null?
                          //local image
                      ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .3),
              child: Image.file(
                File(_image!),
                fit: BoxFit.cover,
                height: mq.height * .2,
                width: mq.height * .2,
              ),
            ):
                          //image from server
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .3),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: mq.height * .2,
                          width: mq.height * .2,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
                        ),
                      ),
                      Positioned(bottom: 0,right: 0 ,child: MaterialButton(onPressed: (){
                        _showBottomSheet();
                      },shape: const CircleBorder(),color: Colors.teal,child: Icon(Icons.edit,color: Colors.white,),))
                    ],
                  ),
                  SizedBox(height: mq.height * .04,),
                  Text(widget.user.email, style: TextStyle(color: Colors.black54,fontSize: 18),),
                  SizedBox(height: mq.height * .05,),
                  TextFormField(
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.name,
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.person, color: CupertinoColors.activeBlue,),border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),hintText: 'eg. Sinchan',labelText: 'Name'),
                  ),
                  SizedBox(height: mq.height * .03,),
                  TextFormField(
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.info_outline, color: CupertinoColors.activeBlue,),border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),hintText: 'eg. Feeling Happy',labelText: 'About'),
                  ),
                  SizedBox(height: mq.height * .03,),
                  ElevatedButton.icon(onPressed: (){
                    if(_formKey.currentState!.validate()){
                      _formKey.currentState!.save();
                      APIs.updateUserInfo().then((value){
                        Dialogs.showSnackbar(context, 'Profile Updated Successfully');
                      });
                    }
                  },icon: Icon(Icons.edit), label: Text('Update'), )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))),
      context: context, builder: (_){
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: mq.height * .03 , bottom: mq.height * .05),
          children: [
            const Text('Pick Profile Picture',textAlign: TextAlign.center, style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
            SizedBox(height: mq.height * .02,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white,shape: const CircleBorder(),fixedSize: Size(mq.width * .3, mq.height * .15)),onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if(image != null){
                    log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                    setState(() {
                      _image = image.path;
                    });
                    Navigator.pop(context);
                  }
                }, child: Image.asset('images/add_image.png')),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white,shape: const CircleBorder(),fixedSize: Size(mq.width * .3, mq.height * .15)),onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if(image != null){
                    log('Image Path: ${image.path}');
                    setState(() {
                      _image = image.path;
                    });
                    Navigator.pop(context);
                  }
                }, child: Image.asset('images/camera.png')),
              ],
            ),
          ],
        );
      }
    );
  }
}
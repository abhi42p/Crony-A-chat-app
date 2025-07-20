import 'dart:developer';
import 'package:crony/api/apis.dart';
import 'package:crony/main.dart';
import 'package:crony/models/chat_user.dart';
import 'package:crony/screens/profile_screen.dart';
import 'package:crony/screens/setting_screen.dart';
import 'package:crony/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSefInfo();
    APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler(
      (message) {
        log('message is $message');
        if (APIs.auth.currentUser != null) {
          if (message.toString().contains('resume')) {
            APIs.updateActiveStatus(true);
          }
          if (message.toString().contains('pause')) {
            APIs.updateActiveStatus(false);
          }
        }
        return Future.value(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, __) {
            if (_isSearching) {
              setState(() => _isSearching = !_isSearching);
              return;
            }
            // some delay before pop
            Future.delayed(
              const Duration(milliseconds: 200),
              SystemNavigator.pop,
            );
          },
          child: Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name, Email, ...',
                      ),
                      autofocus: true,
                      cursorColor: Colors.white,
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          letterSpacing: 0.5),
                      onChanged: (val) {
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : Text(
                      'Home',
                      style: TextStyle(
                          fontFamily: GoogleFonts.badScript().fontFamily,
                          fontSize: 25),
                    ),
              centerTitle: true,
              leading: Icon(CupertinoIcons.home),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(
                      () {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchList
                              .clear(); // Clear search list when exiting search mode
                        }
                      },
                    );
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search),
                ),
                PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: ListTile(
                          title: Text("PROFILE"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  user: APIs.me,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          title: Text("SETTINGS"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                onPressed: () {},
                child: Icon(Icons.add_comment_rounded,color: ColorScheme.of(context).inversePrimary,),
              ),
            ),
            body: StreamBuilder(
                stream: APIs.getAllUsers(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _isSearching
                                ? _searchList.length
                                : _list.length,
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                user: _isSearching
                                    ? _searchList[index]
                                    : _list[index],
                              );
                              // return Text('Name: ${list[index]}');
                            });
                      } else {
                        return const Center(
                            child: Text(
                          'No Connection Found',
                          style: TextStyle(fontSize: 20),
                        ));
                      }
                  }
                }),
          ),
        ),
      ),
    );
  }
}

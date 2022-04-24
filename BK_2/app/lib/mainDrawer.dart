import 'package:flutter/material.dart';


// NOTE: This file used to be called MainScreen, because I tried to 
// make it a template, but it turned out to work better to 
// do it another way, so all that's left here is the MainDrawer. 
// Sorry for the confusion if there is any.


// information/instructions: The drawer pulls out when the user
// clicks on the menu icon found in the appBar. This Widget is 
// rendered in the appBar under the "endDrawer" attribute. 
// @params: no params
// @return: nothing returned
// [bugs]:
// TODOs:decide which items should be in the menu.
// TODO: The items listed in the drawer will be changed to links.
// Suggestions: exit app, sign out, edit profile, 
// settings (if we have any). 

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({ Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(
            child: Text('Menu'),
          ),
          // TODO: The items below will be changed to links
          // that navigate to whevever we want them to.
          Text('Item 1'),
          Text('Item 2'),
        ]
      )
    ); 
  }
}


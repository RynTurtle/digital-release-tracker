import 'package:flutter/material.dart';

void main() => runApp(const TabBarApp());

class TabBarApp extends StatelessWidget {
  const TabBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainTabBar());
  }
}

class MainTabBar extends StatefulWidget {
  const MainTabBar({super.key});

  @override
  State<MainTabBar> createState() => _MainTabBarState();
}


class _MainTabBarState extends State<MainTabBar> {
  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
          appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(indicatorColor: Colors.blue,
          unselectedLabelColor: Color.fromARGB(255, 49, 49, 49),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          tabs: <Widget>[
              Tab(icon: Icon(
                Icons.calendar_month,
                size: 40,
                // if current index is the first one then change colour to amber else dont 
                color: _currentIndex == 0 ? Colors.blue:null,
              )),

              Tab(icon: Icon(
                Icons.notifications,
                size: 40,
                color: _currentIndex == 1 ? Colors.amber:null,
              )),

              Tab(icon: Icon(
                Icons.settings,
                size: 40,
                color: _currentIndex == 2 ? const Color.fromARGB(255, 0, 0, 0):null,

              )),
            ],
          ),
        ),

        body: const TabBarView(
          children: <Widget>[
            Center(child: Text("1")),
            Center(child: Text("2")),
            Center(child: Text("3")),
          ],
        ),
      ),
    );
  }
}
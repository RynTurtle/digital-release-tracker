import 'package:flutter/material.dart';

/// Flutter code sample for [TabBar].

void main() => runApp(const TabBarApp());

class TabBarApp extends StatelessWidget {
  const TabBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TabBarExample());
  }
}

class TabBarExample extends StatelessWidget {
  const TabBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.calendar_month,size: 40)),
              Tab(icon: Icon(Icons.notifications_outlined,size: 40)),
              Tab(icon: Icon(Icons.settings,size: 40)),
            ],
          ),
        ),

        body: const TabBarView(
          children: <Widget>[
            Center(child: Text("1")),
            Center(child: Text("2")),
            Center(child: Text("3")),
            Center(child: Text("4")),

          ],
        ),
      ),
    );
  }
}
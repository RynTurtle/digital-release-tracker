import 'package:flutter/material.dart';
import 'notification.dart';
import 'calendar.dart';

void main() => runApp(const TabBarApp());

class TabBarApp extends StatelessWidget {
  const TabBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainTabBar(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabBar extends StatefulWidget {
  const MainTabBar({super.key});

  @override
  State<MainTabBar> createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1)
      ..addListener(() {
        // update current index when swiping
        if (!_tabController.indexIsChanging) {
          setState(() {
            _currentIndex = _tabController.index;
          });
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,

          tabs: [
            Icon(
              Icons.calendar_month,
              size: 40,
              // if the current index is the first then change colour to blue, else change color to default 
              color: _currentIndex == 0 ? Colors.blue : const Color.fromARGB(255, 53, 52, 52),
            ),
            Icon(
              Icons.notifications,
              size: 40,
              color: _currentIndex == 1 ? Colors.amber : const Color.fromARGB(255, 53, 52, 52),
            ),
            Icon(
              Icons.settings,
              size: 40,
              color: _currentIndex == 2 ? Colors.black : const Color.fromARGB(255, 53, 52, 52),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TableBasicsExample(),
          SearchBarApp(),
          Center(child: Text("3")),
        ],
      ),
    );
  }
}

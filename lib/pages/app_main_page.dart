import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/core/i18n/i18n.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/pages/dashboard_page.dart';
import 'package:onepanel_mobile/pages/containers_page.dart';
import 'package:onepanel_mobile/pages/websites_page.dart';
import 'package:onepanel_mobile/pages/databases_page.dart';
import 'package:onepanel_mobile/pages/files_page.dart';
import 'package:onepanel_mobile/pages/monitor_page.dart';
import 'package:onepanel_mobile/pages/settings_page.dart';
import 'package:onepanel_mobile/pages/server_list_page.dart';

class AppMainPage extends StatefulWidget {
  const AppMainPage({super.key});

  @override
  State<AppMainPage> createState() => _AppMainPageState();
}

class _AppMainPageState extends State<AppMainPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  final List<Widget> _pages = const [
    DashboardPage(),
    ContainersPage(),
    WebsitesPage(),
    DatabasesPage(),
    FilesPage(),
    MonitorPage(),
    SettingsPage(),
  ];

  String t(String key) => I18n.tr(context, key);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _tabController.animateTo(index);
    Navigator.of(context).pop(); // 从抽屉进入时收起抽屉
  }

  @override
  Widget build(BuildContext context) {
    final serverService = Provider.of<ServerService>(context);
    final currentServer = serverService.currentServer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentServer != null ? currentServer.name : t('appName'),
        ),
        actions: [
          IconButton(
            tooltip: t('serverList'),
            icon: const Icon(Icons.dns),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ServerListPage()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, serverService),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer(BuildContext context, ServerService serverService) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  t('appName'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  serverService.currentServer?.name ?? t('noServerSelected'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard, t('dashboard'), 0),
          _drawerItem(Icons.storage, t('containers'), 1),
          _drawerItem(Icons.web, t('websites'), 2),
          _drawerItem(Icons.category, t('databases'), 3),
          _drawerItem(Icons.folder, t('files'), 4),
          _drawerItem(Icons.assessment, t('monitor'), 5),
          const Divider(),
          _drawerItem(Icons.settings, t('settings'), 6),
          ListTile(
            leading: const Icon(Icons.dns),
            title: Text(t('serverList')),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ServerListPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: _selectedIndex == index,
      onTap: () => _onItemTapped(index),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: [
        NavigationDestination(icon: const Icon(Icons.dashboard), label: t('dashboard')),
        NavigationDestination(icon: const Icon(Icons.storage), label: t('containers')),
        NavigationDestination(icon: const Icon(Icons.web), label: t('websites')),
        NavigationDestination(icon: const Icon(Icons.category), label: t('databases')),
        NavigationDestination(icon: const Icon(Icons.folder), label: t('files')),
        NavigationDestination(icon: const Icon(Icons.assessment), label: t('monitor')),
        NavigationDestination(icon: const Icon(Icons.settings), label: t('settings')),
      ],
    );
  }
}

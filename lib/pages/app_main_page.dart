import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/core/services/logger_service.dart';
import 'package:onepanel_mobile/api/v2/api_client.dart';
import 'package:onepanel_mobile/pages/dashboard_page.dart';
import 'package:onepanel_mobile/pages/containers_page.dart';
import 'package:onepanel_mobile/pages/websites_page.dart';
import 'package:onepanel_mobile/pages/databases_page.dart';
import 'package:onepanel_mobile/pages/files_page.dart';
import 'package:onepanel_mobile/pages/monitor_page.dart';
import 'package:onepanel_mobile/pages/settings_page.dart';
import 'package:onepanel_mobile/pages/server_list_page.dart';
import 'package:onepanel_mobile/widgets/server_selector.dart';

class AppMainPage extends StatefulWidget {
  const AppMainPage({super.key});

  @override
  State<AppMainPage> createState() => _AppMainPageState();
}

class _AppMainPageState extends State<AppMainPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  late OnePanelApiClient _apiClient;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ContainersPage(),
    const WebsitesPage(),
    const DatabasesPage(),
    const FilesPage(),
    const MonitorPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _apiClient = OnePanelApiClient(
      serverService: Provider.of<ServerService>(context, listen: false),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final serverService = Provider.of<ServerService>(context);
    final currentServer = serverService.currentServer;

    return Scaffold(
      appBar: AppBar(
        title: currentServer != null
          ? Text(currentServer.name)
          : const Text('1Panel Client'),
        actions: [
          IconButton(
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
      child: Column(
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
                  '1Panel Client',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  serverService.currentServer?.name ?? 'No server selected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: _selectedIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Containers'),
            selected: _selectedIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('Websites'),
            selected: _selectedIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Databases'),
            selected: _selectedIndex == 3,
            onTap: () => _onItemTapped(3),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Files'),
            selected: _selectedIndex == 4,
            onTap: () => _onItemTapped(4),
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Monitor'),
            selected: _selectedIndex == 5,
            onTap: () => _onItemTapped(5),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: _selectedIndex == 6,
            onTap: () => _onItemTapped(6),
          ),
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('Server List'),
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

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.storage),
          label: 'Containers',
        ),
        NavigationDestination(
          icon: Icon(Icons.web),
          label: 'Websites',
        ),
        NavigationDestination(
          icon: Icon(Icons.storage),
          label: 'DB',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder),
          label: 'Files',
        ),
        NavigationDestination(
          icon: Icon(Icons.assessment),
          label: 'Monitor',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

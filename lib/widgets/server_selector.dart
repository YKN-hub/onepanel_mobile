import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanel_mobile/core/services/server_service.dart';
import 'package:onepanel_mobile/data/models/server_info.dart';

class ServerSelector extends StatelessWidget {
  final ValueChanged<ServerInfo> onSelected;

  const ServerSelector({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final serverService = Provider.of<ServerService>(context);
    final servers = serverService.servers;
    final currentServer = serverService.currentServer;

    if (servers.isEmpty) {
      return const SizedBox();
    }

    return DropdownButton<ServerInfo>(
      value: currentServer,
      items: servers.map((server) {
        return DropdownMenuItem<ServerInfo>(
          value: server,
          child: Text(server.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onSelected(value);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'models/device.dart';
import 'services/discovery_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Remote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DeviceDiscoveryPage(),
    );
  }
}


class DeviceDiscoveryPage extends StatefulWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  State<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends State<DeviceDiscoveryPage> {
  final List<Device> _devices = [];
  bool _scanning = false;

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _devices.clear();
    });

    final discovery = DiscoveryService();
    final results = await discovery.discoverDevices();

    setState(() {
      _devices.addAll(results);
      _scanning = false;
    });
  }

  void _openRemote(Device device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RemoteControlPage(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TV Discovery')),
      body: Column(
        children: [
          if (_scanning) const LinearProgressIndicator(),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: _scanning
                        ? const Text('Scanning for devices...')
                        : const Text('No devices found.'),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        title: Text(device.name),
                        subtitle: Text(device.address),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openRemote(device),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanning ? null : _scan,
        icon: const Icon(Icons.search),
        label: const Text('Scan for TVs'),
      ),
    );
  }
}

class RemoteControlPage extends StatelessWidget {
  final Device device;
  const RemoteControlPage({super.key, required this.device});

  void _sendCommand(String command) {
    debugPrint('Send command $command to ${device.address}');
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _RemoteControlButton(
        icon: Icons.volume_up,
        label: 'Vol +',
        onPressed: () => _sendCommand('volume_up'),
      ),
      _RemoteControlButton(
        icon: Icons.volume_down,
        label: 'Vol -',
        onPressed: () => _sendCommand('volume_down'),
      ),
      _RemoteControlButton(
        icon: Icons.arrow_drop_up,
        label: 'Chan +',
        onPressed: () => _sendCommand('channel_up'),
      ),
      _RemoteControlButton(
        icon: Icons.arrow_drop_down,
        label: 'Chan -',
        onPressed: () => _sendCommand('channel_down'),
      ),
      _RemoteControlButton(
        icon: Icons.apps,
        label: 'Apps',
        onPressed: () => _sendCommand('apps'),
      ),
      _RemoteControlButton(
        icon: Icons.menu,
        label: 'Menu',
        onPressed: () => _sendCommand('menu'),
      ),
      _RemoteControlButton(
        icon: Icons.reply,
        label: 'Last',
        onPressed: () => _sendCommand('last_channel'),
      ),
      _RemoteControlButton(
        icon: Icons.power_settings_new,
        label: 'Power',
        onPressed: () => _sendCommand('power'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: buttons,
        ),
      ),
    );
  }
}

class _RemoteControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _RemoteControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

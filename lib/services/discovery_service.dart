import 'package:multicast_dns/multicast_dns.dart';
import 'package:upnp/upnp.dart';

import '../models/device.dart';

class DiscoveryService {
  Future<List<Device>> discoverDevices() async {
    final devices = <Device>[];

    // Discover UPnP devices via SSDP.
    final discoverer = DeviceDiscoverer();
    await discoverer.start(ipv6: false);
    await for (final client in discoverer.quickDiscoverClients()) {
      try {
        final dev = await client.getDevice();
        final uri = Uri.tryParse(client.location);
        final host = uri?.host;
        if (host != null) {
          devices.add(Device(name: dev.friendlyName ?? 'UPnP Device', address: host));
        }
      } catch (_) {
        // Ignore broken devices.
      }
    }

    // Discover mDNS services for specific TV brands.
    final mdns = MDnsClient();
    await mdns.start();
    const services = [
      '_samsungmsf._tcp.local',
      '_lgsmarttv._tcp.local',
      '_sony._tcp.local',
    ];
    for (final service in services) {
      await for (final ptr in mdns.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(service))) {
        await for (final srv in mdns.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))) {
          devices.add(Device(name: service.split('._').first, address: srv.target));
        }
      }
    }
    mdns.stop();

    return devices;
  }
}

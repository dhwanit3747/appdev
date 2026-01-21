import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/linux_distro.dart';

class DetailScreen extends StatelessWidget {
  final LinuxDistro distro;

  const DetailScreen({super.key, required this.distro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(distro.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(distro.description),
            const SizedBox(height: 20),
            Text("Base: ${distro.base}"),
            Text("ISO Size: ${distro.isoSize} GB"),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Official Download"),
              onPressed: () async {
                final uri = Uri.parse(distro.download);
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

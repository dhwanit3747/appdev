import 'package:flutter/material.dart';
import '../models/linux_distro.dart';
import '../screens/detail_screen.dart';

class DistroCard extends StatelessWidget {
  final LinuxDistro distro;

  const DistroCard({super.key, required this.distro});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(distro: distro),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                    const Icon(Icons.laptop, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(distro.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge),
                        const SizedBox(height: 6),
                        Text(
                          distro.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text("${distro.isoSize} GB"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

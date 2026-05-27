import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/linux_distro.dart';
import '../providers/distro_provider.dart';

class DetailScreen extends StatelessWidget {
  final LinuxDistro distro;

  const DetailScreen({super.key, required this.distro});

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return DistroProvider.familyColor(distro.family);
    }
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    if (urlString.isEmpty) return;
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening link: $e"), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final distroColor = _parseColor(distro.color);
    final familyColor = DistroProvider.familyColor(distro.family);
    final provider = Provider.of<DistroProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing App Bar with Hero
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: distroColor.withOpacity(isDark ? 0.4 : 0.9),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      distroColor.withOpacity(isDark ? 0.3 : 0.7),
                      distroColor.withOpacity(isDark ? 0.15 : 0.4),
                      isDark ? const Color(0xFF0B0518) : const Color(0xFFF4F0FA),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          distroColor.withOpacity(0.9),
                          distroColor.withOpacity(0.6),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: distroColor.withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        distro.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              // Favorite
              IconButton(
                icon: Icon(
                  provider.isFavorite(distro.name)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: provider.isFavorite(distro.name) ? Colors.redAccent : Colors.white,
                ),
                onPressed: () => provider.toggleFavorite(distro.name),
              ),
              // Add to compare
              IconButton(
                icon: Icon(
                  provider.isInCompare(distro.name)
                      ? Icons.compare_arrows_rounded
                      : Icons.add_chart_rounded,
                  color: provider.isInCompare(distro.name) ? Colors.greenAccent : Colors.white,
                ),
                onPressed: () {
                  final added = provider.toggleCompare(distro.name);
                  if (!added) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Maximum 3 distros for comparison"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              distro.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              distro.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tags Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTag(DistroProvider.familyDisplayName(distro.family), familyColor),
                      _buildTag(distro.releaseModel, const Color(0xFF00897B)),
                      _buildTag("Since ${distro.firstRelease}", const Color(0xFF5C6BC0)),
                      _buildTag(distro.latestVersion, distroColor),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quick Specs Grid
                  _buildSectionTitle("Quick Specs", Icons.dashboard_rounded),
                  const SizedBox(height: 12),
                  _buildSpecsGrid(context, isDark, distroColor),

                  const SizedBox(height: 24),

                  // About
                  _buildSectionTitle("About", Icons.info_outline_rounded),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF150D2E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black08,
                      ),
                    ),
                    child: Text(
                      distro.longDescription,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Desktop Environments
                  _buildSectionTitle("Desktop Environments", Icons.desktop_windows_rounded),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: distro.availableDesktops.map((de) {
                      final isDefault = de == distro.defaultDesktop;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDefault
                              ? distroColor.withOpacity(isDark ? 0.25 : 0.12)
                              : (isDark ? const Color(0xFF150D2E) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: isDefault
                              ? Border.all(color: distroColor.withOpacity(0.5), width: 1.5)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monitor_rounded,
                              size: 16,
                              color: isDefault ? distroColor : (isDark ? Colors.white54 : Colors.black45),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              de,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isDefault ? FontWeight.w700 : FontWeight.w500,
                                color: isDefault ? distroColor : null,
                              ),
                            ),
                            if (isDefault) ...[
                              const SizedBox(width: 4),
                              Text(
                                "default",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: distroColor.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Use Cases
                  _buildSectionTitle("Use Cases", Icons.category_rounded),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: distro.useCases.map((uc) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF150D2E) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_useCaseIcon(uc), size: 16, color: distroColor),
                            const SizedBox(width: 6),
                            Text(uc, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Pros & Cons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildProsCons(context, "Pros", distro.pros, Colors.green, Icons.thumb_up_rounded, isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildProsCons(context, "Cons", distro.cons, Colors.red, Icons.thumb_down_rounded, isDark)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Target Audience
                  _buildSectionTitle("Target Audience", Icons.people_rounded),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: distro.targetAudience.map((ta) {
                      return Chip(
                        label: Text(ta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        avatar: Icon(Icons.person_rounded, size: 16, color: distroColor),
                        backgroundColor: distroColor.withOpacity(isDark ? 0.15 : 0.08),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.language_rounded),
                          label: const Text("Website"),
                          onPressed: distro.website.isNotEmpty
                              ? () => _launchUrl(context, distro.website)
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: distroColor, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download_rounded),
                          label: const Text("Download"),
                          onPressed: distro.download.isNotEmpty
                              ? () => _launchUrl(context, distro.download)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: distroColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _parseColor(distro.color)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsGrid(BuildContext context, bool isDark, Color color) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _specTile("ISO Size", distro.formattedIsoSize, Icons.sd_card_rounded, isDark, color),
        _specTile("Package Manager", distro.packageManager, Icons.inventory_2_rounded, isDark, color),
        _specTile("Init System", distro.initSystem, Icons.settings_rounded, isDark, color),
        _specTile("Base", distro.base, Icons.foundation_rounded, isDark, color),
      ],
    );
  }

  Widget _specTile(String label, String value, IconData icon, bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF150D2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black38,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProsCons(BuildContext context, String title, List<String> items, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF150D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  title == "Pros" ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
                  size: 12,
                  color: color.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  IconData _useCaseIcon(String useCase) {
    switch (useCase.toLowerCase()) {
      case 'desktop': return Icons.desktop_windows_rounded;
      case 'server': return Icons.dns_rounded;
      case 'cloud': return Icons.cloud_rounded;
      case 'gaming': return Icons.sports_esports_rounded;
      case 'security': return Icons.security_rounded;
      case 'penetration testing': return Icons.bug_report_rounded;
      case 'privacy': return Icons.shield_rounded;
      case 'development': return Icons.code_rounded;
      case 'education': return Icons.school_rounded;
      case 'iot': return Icons.devices_rounded;
      case 'creative': return Icons.palette_rounded;
      case 'containers': return Icons.inventory_rounded;
      case 'old hardware': return Icons.memory_rounded;
      case 'enterprise': return Icons.business_rounded;
      case 'hpc': return Icons.speed_rounded;
      case 'learning': return Icons.menu_book_rounded;
      case 'forensics': return Icons.search_rounded;
      case 'audio production': return Icons.headphones_rounded;
      case 'video editing': return Icons.movie_rounded;
      case 'embedded': return Icons.developer_board_rounded;
      case 'portable': return Icons.usb_rounded;
      case 'recovery': return Icons.restore_rounded;
      case 'database': return Icons.storage_rounded;
      case 'business': return Icons.work_rounded;
      case 'journalism': return Icons.newspaper_rounded;
      case 'benchmarking': return Icons.speed_rounded;
      case 'sap': return Icons.business_center_rounded;
      case 'offline use': return Icons.wifi_off_rounded;
      default: return Icons.category_rounded;
    }
  }
}

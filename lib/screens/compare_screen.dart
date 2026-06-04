import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/linux_distro.dart';
import '../providers/distro_provider.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  Color _parseColor(String hex, String family) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return DistroProvider.familyColor(family);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final distroProvider = Provider.of<DistroProvider>(context);
    final compareList = distroProvider.compareDistros;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Compare Distributions"),
        actions: [
          if (compareList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: "Clear All",
              onPressed: () {
                distroProvider.clearCompare();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Comparison list cleared"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
        ],
      ),
      body: compareList.isEmpty
          ? _buildEmptyState(context, isDark)
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: isDark ? const Color(0xFF1E133F).withValues(alpha: 0.3) : Colors.grey.shade100,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Comparing ${compareList.length} of max 3 distributions. Swipe horizontally to view all specs.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Label Column
                            _buildLabelColumn(context, isDark),
                            // Distro Columns
                            ...compareList.map((distro) => _buildDistroColumn(context, distro, distroProvider, isDark)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E133F).withValues(alpha: 0.4) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.compare_arrows_rounded,
                size: 64,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No distros selected to compare",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Add up to 3 distributions to compare side-by-side using the comparison icon on their detail page.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white30 : Colors.black45,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text("Go Back"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: const Color(0xFF7B3FE4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelColumn(BuildContext context, bool isDark) {
    const labels = [
      "Family",
      "Base System",
      "First Release",
      "Latest Version",
      "Popularity Rank",
      "Package Manager",
      "Default Desktop",
      "ISO Size",
      "Release Model",
      "Init System",
      "Key Pros",
      "Key Cons",
    ];

    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0724) : Colors.grey.shade50,
        border: Border(
          right: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header placeholder space
          const SizedBox(height: 150),
          ...labels.map((label) => Container(
                height: label == "Key Pros" || label == "Key Cons" ? 120 : 60,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDistroColumn(
    BuildContext context,
    LinuxDistro distro,
    DistroProvider provider,
    bool isDark,
  ) {
    final distroColor = _parseColor(distro.color, distro.family);

    return Container(
      width: 180,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Column(
        children: [
          // Header Card
          Container(
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  distroColor.withValues(alpha: isDark ? 0.2 : 0.08),
                  distroColor.withValues(alpha: isDark ? 0.05 : 0.02),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 2),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      provider.toggleCompare(distro.name);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              distroColor.withValues(alpha: 0.9),
                              distroColor.withValues(alpha: 0.6),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            distro.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        distro.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Values
          _buildSpecCell(distro.family.toUpperCase(), isDark),
          _buildSpecCell(distro.base, isDark),
          _buildSpecCell(distro.firstRelease, isDark),
          _buildSpecCell(distro.latestVersion, isDark),
          _buildPopularityCell(distro, provider, isDark),
          _buildSpecCell(distro.packageManager, isDark),
          _buildSpecCell(distro.defaultDesktop, isDark),
          _buildIsoSizeCell(distro, provider, isDark),
          _buildSpecCell(distro.releaseModel, isDark),
          _buildSpecCell(distro.initSystem, isDark),

          // Pros
          _buildListCell(distro.pros, Colors.green, isDark),
          // Cons
          _buildListCell(distro.cons, Colors.red, isDark),
        ],
      ),
    );
  }

  Widget _buildSpecCell(String text, bool isDark) {
    return Container(
      height: 60,
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPopularityCell(LinuxDistro distro, DistroProvider provider, bool isDark) {
    final color = _parseColor(distro.color, distro.family);
    final maxRank = provider.maxPopularityRank;
    final fillFactor = maxRank > 1
        ? (1.0 - ((distro.popularityRank - 1) / (maxRank - 1))).clamp(0.1, 1.0)
        : 1.0;

    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "#${distro.popularityRank}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              width: 100,
              color: color.withValues(alpha: isDark ? 0.15 : 0.08),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fillFactor,
                  child: Container(color: color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIsoSizeCell(LinuxDistro distro, DistroProvider provider, bool isDark) {
    final color = _parseColor(distro.color, distro.family);
    final maxIso = provider.maxIsoSize;
    final fillFactor = maxIso > 0 ? (distro.isoSize / maxIso).clamp(0.1, 1.0) : 0.0;

    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            distro.formattedIsoSize,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              width: 100,
              color: color.withValues(alpha: isDark ? 0.15 : 0.08),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fillFactor,
                  child: Container(color: color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCell(List<String> items, Color color, bool isDark) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: items.isEmpty
          ? const Center(child: Text("-", style: TextStyle(color: Colors.grey)))
          : ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: items
                  .take(3) // show max 3 to fit
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, size: 6, color: color.withValues(alpha: 0.8)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 10, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/linux_distro.dart';
import '../providers/distro_provider.dart';
import '../providers/theme_provider.dart';

import '../widgets/distro_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/visual_chart_widgets.dart';
import 'detail_screen.dart';
import '../screens/settings_screen.dart';
import 'compare_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAnalytics = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distroProvider = Provider.of<DistroProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Linux Explorer"),
        actions: [
          // View toggle
          IconButton(
            icon: Icon(
              distroProvider.viewMode == ViewMode.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
            ),
            onPressed: () {
              distroProvider.setViewMode(
                distroProvider.viewMode == ViewMode.grid
                    ? ViewMode.list
                    : ViewMode.grid,
              );
            },
            tooltip: "Toggle View",
          ),
          // Sort menu
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: "Sort",
            onSelected: distroProvider.setSortOption,
            itemBuilder: (context) => [
              _sortMenuItem(SortOption.alphabetical, "A → Z", Icons.sort_by_alpha_rounded, distroProvider),
              _sortMenuItem(SortOption.popularity, "Popularity", Icons.trending_up_rounded, distroProvider),
              _sortMenuItem(SortOption.isoSize, "ISO Size", Icons.sd_card_rounded, distroProvider),
              _sortMenuItem(SortOption.releaseYear, "Release Year", Icons.calendar_today_rounded, distroProvider),
            ],
          ),
          // Compare action
          IconButton(
            icon: Badge(
              label: Text('${distroProvider.compareList.length}'),
              isLabelVisible: distroProvider.compareList.isNotEmpty,
              backgroundColor: Colors.greenAccent.shade700,
              textColor: Colors.white,
              child: const Icon(Icons.compare_arrows_rounded),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompareScreen(),
                ),
              );
            },
            tooltip: "Compare Distributions",
          ),
          // Theme toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: themeProvider.toggleTheme,
            tooltip: "Toggle Theme",
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            tooltip: "Settings",
          ),
        ],
      ),
      body: distroProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Dashboard
                _buildStatsDashboard(context, distroProvider),

                // Analytics dashboard
                _buildAnalyticsSection(context, distroProvider, isDark),

                // Search Bar
                _buildSearchBar(context, distroProvider, isDark),

                // Family Filter Chips
                _buildFamilyChips(context, distroProvider),

                // Results count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        "${distroProvider.filteredDistros.length} distributions",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const Spacer(),
                      if (distroProvider.selectedUseCase != 'All')
                        ActionChip(
                          label: Text(
                            distroProvider.selectedUseCase,
                            style: const TextStyle(fontSize: 11),
                          ),
                          avatar: const Icon(Icons.close, size: 14),
                          onPressed: () => distroProvider.setUseCase('All'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),

                // Distro Grid/List
                Expanded(
                  child: _buildDistroView(context, distroProvider, isDark),
                ),
              ],
            ),
    );
  }

  PopupMenuItem<SortOption> _sortMenuItem(
    SortOption option,
    String label,
    IconData icon,
    DistroProvider provider,
  ) {
    final isSelected = provider.sortOption == option;
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Theme.of(context).primaryColor : null),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check_rounded, size: 18, color: Theme.of(context).primaryColor),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(BuildContext context, DistroProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.apps_rounded,
              label: "Distros",
              value: "${provider.totalDistros}",
              color: const Color(0xFF7B3FE4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              icon: Icons.account_tree_rounded,
              label: "Families",
              value: "${provider.familyCounts.length}",
              color: const Color(0xFF00BCD4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              },
              child: StatCard(
                icon: Icons.favorite_rounded,
                label: "Favorites",
                value: "${provider.favorites.length}",
                color: const Color(0xFFE91E63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, DistroProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setSearchQuery,
        decoration: InputDecoration(
          hintText: "Search distros, package managers, desktops...",
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E133F).withValues(alpha: 0.5) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyChips(BuildContext context, DistroProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: provider.allFamilies.length,
        itemBuilder: (context, index) {
          final family = provider.allFamilies[index];
          final isSelected = provider.selectedFamily == family;
          final color = family == 'All'
              ? Theme.of(context).primaryColor
              : DistroProvider.familyColor(family);

          final Color textColor;
          if (isSelected) {
            textColor = color.computeLuminance() > 0.6 ? Colors.black87 : Colors.white;
          } else {
            textColor = isDark ? color.withValues(alpha: 0.9) : color;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(
                family == 'All'
                    ? 'All'
                    : DistroProvider.familyDisplayName(family),
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => provider.setFamily(family),
              selectedColor: color.withValues(alpha: 0.85),
              backgroundColor: color.withValues(alpha: 0.15),
              checkmarkColor: color.computeLuminance() > 0.6 ? Colors.black87 : Colors.white,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDistroView(BuildContext context, DistroProvider provider, bool isDark) {
    final distros = provider.filteredDistros;

    if (distros.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              "No distributions found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search or filters",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.viewMode == ViewMode.list) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 80),
        itemCount: distros.length,
        itemBuilder: (context, index) {
          final distro = distros[index];
          return DistroListTile(
            distro: distro,
            isFavorite: provider.isFavorite(distro.name),
            onTap: () => _navigateToDetail(context, distro),
            onFavoriteTap: () => provider.toggleFavorite(distro.name),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
      itemCount: distros.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final distro = distros[index];
        return DistroCard(
          distro: distro,
          isFavorite: provider.isFavorite(distro.name),
          onTap: () => _navigateToDetail(context, distro),
          onFavoriteTap: () => provider.toggleFavorite(distro.name),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, LinuxDistro distro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(distro: distro),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, DistroProvider provider, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
            onTap: () {
              setState(() {
                _showAnalytics = !_showAnalytics;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showAnalytics ? Icons.analytics_rounded : Icons.analytics_outlined,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showAnalytics ? "Hide Visual Analytics" : "Show Visual Analytics",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Icon(
                    _showAnalytics ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showAnalytics) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedFamilyChart(
              familyCounts: provider.familyCounts,
              totalCount: provider.totalDistros,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.sd_card_rounded, color: Color(0xFF00BCD4), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Average ISO Footprint: ${provider.averageIsoSize.toStringAsFixed(1)} GB across all distributions.",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

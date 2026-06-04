import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/distro_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/distro_card.dart';
import '../screens/detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final distroProvider = Provider.of<DistroProvider>(context);
    final favorites = distroProvider.favoriteDistros;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                'No favorites yet.',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final distro = favorites[index];
                return DistroCard(
                  distro: distro,
                  isFavorite: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(distro: distro)),
                  ),
                  onFavoriteTap: () => distroProvider.toggleFavorite(distro.name),
                );
              },
            ),
    );
  }
}

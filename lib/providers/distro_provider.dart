import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../models/linux_distro.dart';

enum SortOption { alphabetical, popularity, isoSize, releaseYear }
enum ViewMode { grid, list }

class DistroProvider extends ChangeNotifier {
  List<LinuxDistro> _allDistros = [];
  List<LinuxDistro> _filteredDistros = [];
  final Set<String> _favorites = {};
  final Set<String> _compareList = {};
  String _searchQuery = '';
  String _selectedFamily = 'All';
  String _selectedUseCase = 'All';
  SortOption _sortOption = SortOption.alphabetical;
  ViewMode _viewMode = ViewMode.grid;
  bool _isLoading = true;

  AuthUser? _currentUser;
  String? _lastUid; // Track last UID to prevent infinite reloads

  DistroProvider() {
    loadDistros();
  }

  // ---------- Getters ----------
  List<LinuxDistro> get allDistros => _allDistros;
  List<LinuxDistro> get filteredDistros => _filteredDistros;
  Set<String> get favorites => _favorites;
  Set<String> get compareList => _compareList;
  String get searchQuery => _searchQuery;
  String get selectedFamily => _selectedFamily;
  String get selectedUseCase => _selectedUseCase;
  SortOption get sortOption => _sortOption;
  ViewMode get viewMode => _viewMode;
  bool get isLoading => _isLoading;

  List<LinuxDistro> get favoriteDistros =>
      _allDistros.where((d) => _favorites.contains(d.name)).toList();

  List<LinuxDistro> get compareDistros =>
      _allDistros.where((d) => _compareList.contains(d.name)).toList();

  int get totalDistros => _allDistros.length;

  double get maxIsoSize {
    if (_allDistros.isEmpty) return 1.0;
    return _allDistros.map((d) => d.isoSize).reduce((a, b) => a > b ? a : b);
  }

  double get minIsoSize {
    if (_allDistros.isEmpty) return 0.0;
    return _allDistros.map((d) => d.isoSize).reduce((a, b) => a < b ? a : b);
  }

  double get averageIsoSize {
    if (_allDistros.isEmpty) return 0.0;
    final total = _allDistros.map((d) => d.isoSize).reduce((a, b) => a + b);
    return total / _allDistros.length;
  }

  int get maxPopularityRank {
    if (_allDistros.isEmpty) return 100;
    return _allDistros.map((d) => d.popularityRank).reduce((a, b) => a > b ? a : b);
  }

  List<String> get allFamilies {
    final families = _allDistros.map((d) => d.family).toSet().toList();
    families.sort();
    return ['All', ...families];
  }

  List<String> get allUseCases {
    final useCases = <String>{};
    for (final d in _allDistros) {
      useCases.addAll(d.useCases);
    }
    final list = useCases.toList()..sort();
    return ['All', ...list];
  }

  Map<String, int> get familyCounts {
    final counts = <String, int>{};
    for (final d in _allDistros) {
      counts[d.family] = (counts[d.family] ?? 0) + 1;
    }
    return counts;
  }

  /// Family display names
  static String familyDisplayName(String family) {
    switch (family.toLowerCase()) {
      case 'debian':
        return 'Debian';
      case 'redhat':
        return 'Red Hat';
      case 'arch':
        return 'Arch';
      case 'suse':
        return 'SUSE';
      case 'gentoo':
        return 'Gentoo';
      case 'slackware':
        return 'Slackware';
      case 'android':
        return 'Android';
      case 'independent':
        return 'Independent';
      default:
        return family[0].toUpperCase() + family.substring(1);
    }
  }

  /// Family colors
  static Color familyColor(String family) {
    switch (family.toLowerCase()) {
      case 'debian':
        return const Color(0xFFA80030);
      case 'redhat':
        return const Color(0xFFEE0000);
      case 'arch':
        return const Color(0xFF1793D1);
      case 'suse':
        return const Color(0xFF73BA25);
      case 'gentoo':
        return const Color(0xFF54487A);
      case 'slackware':
        return const Color(0xFF4458A0);
      case 'android':
        return const Color(0xFF3DDC84);
      case 'independent':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF7B3FE4);
    }
  }

  // ---------- Update user (called by ProxyProvider) ----------
  /// Only reloads data when the user actually changes (prevents infinite loop).
  void updateUser(AuthUser? user) {
    final newUid = user?.uid;
    if (newUid == _lastUid) return; // Same user — skip reload.
    _lastUid = newUid;
    _currentUser = user;

    if (_currentUser == null) {
      // User logged out — clear favorites
      _favorites.clear();
      notifyListeners();
    } else {
      // New user — reload favorites
      _loadFavorites();
    }
  }

  // ---------- Load data ----------
  Future<void> loadDistros() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await rootBundle.loadString('assets/data/distros.json');
      final List decoded = json.decode(data);
      _allDistros = decoded.map((item) => LinuxDistro.fromJson(item)).toList();
      _applyFilters();

      // Load favorites if user is logged in
      if (_currentUser != null) {
        await _loadFavorites();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading distros: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load favorites from local storage.
  Future<void> _loadFavorites() async {
    if (_currentUser == null) return;
    _favorites.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('favorites_${_currentUser!.uid}') ?? [];
      _favorites.addAll(saved);
    } catch (e) {
      debugPrint("Local favorites load failed: $e");
    }
    notifyListeners();
  }

  // ---------- Search ----------
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // ---------- Family filter ----------
  void setFamily(String family) {
    _selectedFamily = family;
    _applyFilters();
    notifyListeners();
  }

  // ---------- Use case filter ----------
  void setUseCase(String useCase) {
    _selectedUseCase = useCase;
    _applyFilters();
    notifyListeners();
  }

  // ---------- Sort ----------
  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFilters();
    notifyListeners();
  }

  // ---------- View mode ----------
  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  // ---------- Favorites ----------
  bool isFavorite(String name) => _favorites.contains(name);

  void toggleFavorite(String name) async {
    if (_favorites.contains(name)) {
      _favorites.remove(name);
    } else {
      _favorites.add(name);
    }
    notifyListeners();

    // Persist — only if user is logged in
    if (_currentUser == null) return;
    final uid = _currentUser!.uid;

    // Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites_$uid', _favorites.toList());
    } catch (e) {
      debugPrint('Error saving favorites to preferences: $e');
    }
  }

  // ---------- Compare ----------
  bool isInCompare(String name) => _compareList.contains(name);

  bool toggleCompare(String name) {
    if (_compareList.contains(name)) {
      _compareList.remove(name);
      notifyListeners();
      return true;
    } else if (_compareList.length < 3) {
      _compareList.add(name);
      notifyListeners();
      return true;
    }
    return false; // Max 3
  }

  void clearCompare() {
    _compareList.clear();
    notifyListeners();
  }

  // ---------- Internal filter & sort ----------
  void _applyFilters() {
    var result = List<LinuxDistro>.from(_allDistros);

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((d) =>
          d.name.toLowerCase().contains(q) ||
          d.base.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q) ||
          d.family.toLowerCase().contains(q) ||
          d.packageManager.toLowerCase().contains(q) ||
          d.defaultDesktop.toLowerCase().contains(q)).toList();
    }

    // Family filter
    if (_selectedFamily != 'All') {
      result = result.where((d) => d.family == _selectedFamily).toList();
    }

    // Use case filter
    if (_selectedUseCase != 'All') {
      result = result.where((d) => d.useCases.contains(_selectedUseCase)).toList();
    }

    // Sort
    switch (_sortOption) {
      case SortOption.alphabetical:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.popularity:
        result.sort((a, b) => a.popularityRank.compareTo(b.popularityRank));
        break;
      case SortOption.isoSize:
        result.sort((a, b) => a.isoSize.compareTo(b.isoSize));
        break;
      case SortOption.releaseYear:
        result.sort((a, b) {
          final yearA = int.tryParse(a.firstRelease) ?? 9999;
          final yearB = int.tryParse(b.firstRelease) ?? 9999;
          return yearA.compareTo(yearB);
        });
        break;
    }

    _filteredDistros = result;
  }
}

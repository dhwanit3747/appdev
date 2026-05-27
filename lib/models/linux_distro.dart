class LinuxDistro {
  final String name;
  final String description;
  final String longDescription;
  final String website;
  final String download;
  final double isoSize;
  final String base;
  final String family;
  final String logo;
  final String firstRelease;
  final String latestVersion;
  final String packageManager;
  final String defaultDesktop;
  final List<String> availableDesktops;
  final String releaseModel;
  final List<String> targetAudience;
  final List<String> useCases;
  final String initSystem;
  final List<String> pros;
  final List<String> cons;
  final int popularityRank;
  final String color;

  LinuxDistro({
    required this.name,
    required this.description,
    required this.longDescription,
    required this.website,
    required this.download,
    required this.isoSize,
    required this.base,
    required this.family,
    required this.logo,
    required this.firstRelease,
    required this.latestVersion,
    required this.packageManager,
    required this.defaultDesktop,
    required this.availableDesktops,
    required this.releaseModel,
    required this.targetAudience,
    required this.useCases,
    required this.initSystem,
    required this.pros,
    required this.cons,
    required this.popularityRank,
    required this.color,
  });

  factory LinuxDistro.fromJson(Map<String, dynamic> json) {
    return LinuxDistro(
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      longDescription: json['long_description'] ?? json['description'] ?? '',
      website: json['website'] ?? '',
      download: json['download'] ?? '',
      isoSize: (json['iso_size'] as num?)?.toDouble() ?? 0.0,
      base: json['base'] ?? 'Independent',
      family: json['family'] ?? 'independent',
      logo: json['logo'] ?? '',
      firstRelease: json['first_release'] ?? 'Unknown',
      latestVersion: json['latest_version'] ?? 'Unknown',
      packageManager: json['package_manager'] ?? 'Unknown',
      defaultDesktop: json['default_desktop'] ?? 'Unknown',
      availableDesktops: _toStringList(json['available_desktops']),
      releaseModel: json['release_model'] ?? 'Unknown',
      targetAudience: _toStringList(json['target_audience']),
      useCases: _toStringList(json['use_cases']),
      initSystem: json['init_system'] ?? 'Unknown',
      pros: _toStringList(json['pros']),
      cons: _toStringList(json['cons']),
      popularityRank: (json['popularity_rank'] as num?)?.toInt() ?? 50,
      color: json['color'] ?? '#7B3FE4',
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  /// Returns the age of the distro in years
  int get age {
    final year = int.tryParse(firstRelease);
    if (year == null) return 0;
    return DateTime.now().year - year;
  }

  /// Returns human-readable ISO size
  String get formattedIsoSize {
    if (isoSize < 1.0) {
      return '${(isoSize * 1024).toStringAsFixed(0)} MB';
    }
    return '${isoSize.toStringAsFixed(1)} GB';
  }
}

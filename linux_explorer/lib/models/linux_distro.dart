class LinuxDistro {
  final String name;
  final String description;
  final String website;
  final String download;
  final double isoSize;
  final String base;
  final String logo;

  LinuxDistro({
    required this.name,
    required this.description,
    required this.website,
    required this.download,
    required this.isoSize,
    required this.base,
    required this.logo,
  });

  factory LinuxDistro.fromJson(Map<String, dynamic> json) {
    return LinuxDistro(
      name: json['name'],
      description: json['description'],
      website: json['website'],
      download: json['download'],
      isoSize: json['iso_size'],
      base: json['base'],
      logo: json['logo'],
    );
  }
}

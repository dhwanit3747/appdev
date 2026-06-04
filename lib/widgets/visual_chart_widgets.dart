// import 'dart:math'; // Unused import removed
import 'package:flutter/material.dart';

class CircularRankGauge extends StatelessWidget {
  final int rank;
  final int maxRank;
  final Color color;
  final double size;

  const CircularRankGauge({
    super.key,
    required this.rank,
    required this.maxRank,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    // Standardize calculation: rank 1 should be 100% full, maxRank should be almost empty
    final double value = maxRank > 1 
        ? (1.0 - ((rank - 1) / (maxRank - 1))).clamp(0.05, 1.0)
        : 1.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: isDark ? 0.15 : 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "#$rank",
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  "RANK",
                  style: TextStyle(
                    fontSize: size * 0.1,
                    fontWeight: FontWeight.w800,
                    color: color.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VisualProgressBar extends StatefulWidget {
  final double value;
  final double maxValue;
  final Color color;
  final String label;
  final String valueText;

  const VisualProgressBar({
    super.key,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.label,
    required this.valueText,
  });

  @override
  State<VisualProgressBar> createState() => _VisualProgressBarState();
}

class _VisualProgressBarState extends State<VisualProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    final targetValue = widget.maxValue > 0 ? (widget.value / widget.maxValue).clamp(0.0, 1.0) : 0.0;
    _animation = Tween<double>(begin: 0, end: targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant VisualProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.maxValue != widget.maxValue) {
      final targetValue = widget.maxValue > 0 ? (widget.value / widget.maxValue).clamp(0.0, 1.0) : 0.0;
      _animation = Tween<double>(begin: _animation.value, end: targetValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            Text(
              widget.valueText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 10,
                width: double.infinity,
                color: widget.color.withValues(alpha: isDark ? 0.15 : 0.08),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color,
                            widget.color.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SegmentedFamilyChart extends StatelessWidget {
  final Map<String, int> familyCounts;
  final int totalCount;

  const SegmentedFamilyChart({
    super.key,
    required this.familyCounts,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 0) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sort families by count descending
    final sortedFamilies = familyCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Distribution Families Breakdown",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            // The segment bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: sortedFamilies.map((entry) {
                    final percentage = entry.value / totalCount;
                    final color = _getFamilyColor(entry.key);
                    return Expanded(
                      flex: (percentage * 1000).toInt().clamp(1, 1000),
                      child: Container(
                        color: color,
                        child: Tooltip(
                          message: "${entry.key}: ${entry.value} distros (${(percentage * 100).toStringAsFixed(1)}%)",
                          child: const SizedBox.expand(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: sortedFamilies.map((entry) {
                final percentage = entry.value / totalCount;
                final color = _getFamilyColor(entry.key);
                final displayName = _getFamilyDisplayName(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$displayName (${(percentage * 100).toStringAsFixed(0)}%)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFamilyColor(String family) {
    switch (family.toLowerCase()) {
      case 'debian': return const Color(0xFFA80030);
      case 'redhat': return const Color(0xFFEE0000);
      case 'arch': return const Color(0xFF1793D1);
      case 'suse': return const Color(0xFF73BA25);
      case 'gentoo': return const Color(0xFF54487A);
      case 'slackware': return const Color(0xFF4458A0);
      case 'independent': return const Color(0xFF607D8B);
      default: return const Color(0xFF7B3FE4);
    }
  }

  String _getFamilyDisplayName(String family) {
    switch (family.toLowerCase()) {
      case 'debian': return 'Debian';
      case 'redhat': return 'Red Hat';
      case 'arch': return 'Arch';
      case 'suse': return 'SUSE';
      case 'gentoo': return 'Gentoo';
      case 'slackware': return 'Slackware';
      case 'independent': return 'Independent';
      default: return family[0].toUpperCase() + family.substring(1);
    }
  }
}

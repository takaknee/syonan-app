import 'package:flutter/material.dart';

import '../models/coming_soon_feature.dart';

/// 実装済み機能を表示するカードウィジェット
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.feature,
    required this.onTap,
  });

  final ComingSoonFeature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featureColor = Color(feature.color);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                featureColor.withValues(alpha: 0.05),
                featureColor.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: featureColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: featureColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  feature.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                feature.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: featureColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                feature.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: featureColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: featureColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: featureColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '利用可能',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: featureColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

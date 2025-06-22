import 'package:flutter/material.dart';

import '../models/coming_soon_feature.dart';
import '../utils/responsive_utils.dart';

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
          padding: EdgeInsets.all(ResponsiveUtils.getVerticalPadding(context)),
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
                padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 12.0 : 16.0),
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
                  style: TextStyle(fontSize: ResponsiveUtils.isMobile(context) ? 24 : 28),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, factor: 0.8)),
              Text(
                feature.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: featureColor,
                  fontSize: ResponsiveUtils.isMobile(context) ? 14.0 : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, factor: 0.2)),
              Text(
                feature.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: ResponsiveUtils.isMobile(context) ? 11.0 : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, factor: 0.6)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.isMobile(context) ? 8.0 : 12.0,
                  vertical: ResponsiveUtils.isMobile(context) ? 4.0 : 6.0,
                ),
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
                      size: ResponsiveUtils.isMobile(context) ? 14 : 16,
                      color: featureColor,
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, factor: 0.2)),
                    Text(
                      '利用可能',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: featureColor,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.isMobile(context) ? 10.0 : null,
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

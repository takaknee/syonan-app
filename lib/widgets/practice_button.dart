import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// 練習選択ボタンウィジェット
class PracticeButton extends StatelessWidget {
  const PracticeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.getVerticalPadding(context)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  size: ResponsiveUtils.isMobile(context) ? 24.0 : 32.0, 
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, factor: 0.8)),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: ResponsiveUtils.isMobile(context) ? 16.0 : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, factor: 0.2)),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: ResponsiveUtils.isMobile(context) ? 12.0 : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

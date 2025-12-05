import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppTheme.accentBlue.withOpacity(0.15),
              AppTheme.cardBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: _getStreakColor(),
                  size: 32,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Streak',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Streaks
            Row(
              children: [
                Expanded(
                  child: _buildStreakItem(
                    'Current',
                    currentStreak,
                    _getStreakColor(),
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: AppTheme.textHint.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStreakItem(
                    'Longest',
                    longestStreak,
                    AppTheme.accentBlue,
                  ),
                ),
              ],
            ),

            // Motivation message
            if (currentStreak > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStreakColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStreakMessage(),
                    style: TextStyle(
                      color: _getStreakColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 36,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value == 1 ? 'day' : 'days',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textHint,
          ),
        ),
      ],
    );
  }

  Color _getStreakColor() {
    if (currentStreak >= 30) {
      return const Color(0xFFFFD700); // Gold
    } else if (currentStreak >= 14) {
      return const Color(0xFFFF6B35); // Orange
    } else if (currentStreak >= 7) {
      return AppTheme.caloriesColor; // Orange-Red
    } else if (currentStreak >= 3) {
      return AppTheme.stepsColor; // Green
    } else {
      return AppTheme.accentBlue; // Blue
    }
  }

  String _getStreakMessage() {
    if (currentStreak >= 30) {
      return '🏆 Legendary! 30+ day streak!';
    } else if (currentStreak >= 14) {
      return '🔥 On fire! 2 weeks strong!';
    } else if (currentStreak >= 7) {
      return '💪 Great! One week streak!';
    } else if (currentStreak >= 3) {
      return '✨ Keep it going!';
    } else {
      return '🚀 You\'re getting started!';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_card.dart';
import '../widgets/streak_widget.dart';
import '../widgets/trend_chart.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().initialize();
      context.read<AnalyticsProvider>().trackScreenView('AnalyticsDashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDarkBlue,
            AppTheme.darkBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Consumer<AnalyticsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Analytics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryDarkBlue,
                            AppTheme.primaryBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Streak Widget
                        StreakWidget(
                          currentStreak: provider.healthAnalytics.currentStreak,
                          longestStreak: provider.healthAnalytics.longestStreak,
                        ),
                        const SizedBox(height: 20),

                        // Insights Section
                        _buildInsightsSection(provider),
                        const SizedBox(height: 20),

                        // Health Analytics
                        _buildSectionHeader('Health Stats'),
                        const SizedBox(height: 12),
                        _buildHealthStats(provider),
                        const SizedBox(height: 20),

                        // Weekly Trend
                        _buildSectionHeader('Weekly Trend'),
                        const SizedBox(height: 12),
                        TrendChart(weeklyData: provider.weeklyTrend),
                        const SizedBox(height: 20),

                        // App Usage
                        _buildSectionHeader('App Usage'),
                        const SizedBox(height: 12),
                        _buildAppUsageStats(provider),
                        const SizedBox(height: 20),

                        // Screen Views
                        _buildSectionHeader('Most Viewed Screens'),
                        const SizedBox(height: 12),
                        _buildScreenViews(provider),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Icon(
          Icons.analytics,
          color: AppTheme.accentBlue,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(AnalyticsProvider provider) {
    if (provider.insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppTheme.accentBlue),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...provider.insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          insight,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStats(AnalyticsProvider provider) {
    final analytics = provider.healthAnalytics;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: '7-Day Avg Steps',
                value: '${analytics.avgSteps7d}',
                icon: Icons.directions_walk,
                color: AppTheme.stepsColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsCard(
                title: '7-Day Avg Calories',
                value: '${analytics.avgCalories7d}',
                icon: Icons.local_fire_department,
                color: AppTheme.caloriesColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: '7-Day Avg Water',
                value: analytics.formattedWaterAverage,
                icon: Icons.water_drop,
                color: AppTheme.waterColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsCard(
                title: 'Total Records',
                value: '${analytics.totalRecords}',
                icon: Icons.assignment,
                color: AppTheme.accentBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppUsageStats(AnalyticsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total Sessions', '${provider.sessionCount}'),
            const Divider(height: 24),
            _buildStatRow('Total Time', provider.formattedTotalDuration),
            const Divider(height: 24),
            _buildStatRow('Most Viewed', provider.mostViewedScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenViews(AnalyticsProvider provider) {
    final screens = provider.screenViewCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (screens.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No screen views tracked yet',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: screens.take(5).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.accentBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_record_provider.dart';
import '../widgets/summary_card.dart';
import '../../../core/theme/app_theme.dart';
import 'add_record_screen.dart';
import 'records_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthRecordProvider>().initialize();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _DashboardContent(),
      const RecordsListScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppTheme.cardBackground,
        selectedItemColor: AppTheme.accentBlue,
        unselectedItemColor: AppTheme.textHint,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Records',
          ),
        ],
      ),

    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

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
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'HealthMate',
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
                    // Today's Summary Header
                    Row(
                      children: [
                        const Icon(
                          Icons.today,
                          color: AppTheme.accentBlue,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Today's Summary",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Summary Cards
                    Consumer<HealthRecordProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final summary = provider.todaySummary;
                        
                        return Column(
                          children: [
                            // Steps Card
                            SummaryCard(
                              title: 'Steps Walked',
                              value: '${summary['steps'] ?? 0}',
                              icon: Icons.directions_walk,
                              color: AppTheme.stepsColor,
                              iconBackgroundColor: AppTheme.stepsColor,
                            ),
                            const SizedBox(height: 16),

                            // Calories and Water Row
                            Row(
                              children: [
                                // Calories Card
                                Expanded(
                                  child: SummaryCard(
                                    title: 'Calories',
                                    value: '${summary['calories'] ?? 0}',
                                    icon: Icons.local_fire_department,
                                    color: AppTheme.caloriesColor,
                                    iconBackgroundColor: AppTheme.caloriesColor,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Water Card
                                Expanded(
                                  child: SummaryCard(
                                    title: 'Water Intake',
                                    value: '${((summary['water'] ?? 0) / 1000).toStringAsFixed(1)} L',
                                    icon: Icons.water_drop,
                                    color: AppTheme.waterColor,
                                    iconBackgroundColor: AppTheme.waterColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Quick Stats
                    _buildQuickStatsSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    return Consumer<HealthRecordProvider>(
      builder: (context, provider, child) {
        final totalRecords = provider.records.length;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.insights,
                      color: AppTheme.accentBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Stats',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildStatRow('Total Records', '$totalRecords'),
                const Divider(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBadge(
                        icon: Icons.trending_up,
                        label: 'Track Daily',
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBadge(
                        icon: Icons.favorite,
                        label: 'Stay Healthy',
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

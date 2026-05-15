import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ipo_provider.dart';
import '../models/ipo_model.dart';
import '../models/ipo_summary.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import 'past_ipos_screen.dart';
import 'upcoming_ipos_screen.dart';
import 'ipo_detail_screen.dart';

/// Pantalla principal de l'aplicació
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar dades en iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IPOProvider>().loadInitialData();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<IPOProvider>().refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HKEX IPO Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Actualitzar dades',
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Canviar tema',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh_all') {
                context.read<IPOProvider>().forceFullRefresh();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh_all',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Refresc complet'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<IPOProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allIPOs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.allIPOs.isEmpty) {
            return _buildErrorView(provider);
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              children: [
                _buildHeaderCard(provider),
                const SizedBox(height: 16),
                _buildSummaryCards(provider.summary),
                const SizedBox(height: 16),
                _buildQuickAccessButtons(provider),
                const SizedBox(height: 16),
                _buildRecentIPOsSection(provider),
                if (provider.upcomingIPOs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildUpcomingSection(provider),
                ],
                const SizedBox(height: 16),
                _buildLastSyncInfo(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(IPOProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.error ?? AppConstants.errorDataLoad,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<IPOProvider>().loadInitialData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(IPOProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.show_chart,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mercat HKEX',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.summary?.totalIPOs ?? 0} IPOs analitzades',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (provider.isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(IPOSummary? summary) {
    if (summary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resum General',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total IPOs',
                '${summary.totalIPOs}',
                Icons.business,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Properes',
                '${summary.upcomingIPOs}',
                Icons.schedule,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Positives 1r dia',
                '${summary.positiveFirstDay}',
                Icons.trending_up,
                AppConstants.positiveColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Rend. 1r dia',
                Formatters.formatReturn(summary.averageFirstDayReturn),
                Icons.percent,
                summary.averageFirstDayReturn >= 0
                    ? AppConstants.positiveColor
                    : AppConstants.negativeColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Rend. 1a set.',
                Formatters.formatReturn(summary.averageFirstWeekReturn),
                Icons.trending_up,
                summary.averageFirstWeekReturn >= 0
                    ? AppConstants.positiveColor
                    : AppConstants.negativeColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Capital recaptat',
                Formatters.formatCompactCurrency(summary.totalFundsRaised),
                Icons.account_balance,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButtons(IPOProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'IPOs Passades',
            Icons.history,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PastIPOsScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            'Properes IPOs',
            Icons.upcoming,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UpcomingIPOsScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentIPOsSection(IPOProvider provider) {
    final recent = provider.pastIPOs.take(5).toList();
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Últimes IPOs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PastIPOsScreen(),
                ),
              ),
              child: const Text('Veure totes'),
            ),
          ],
        ),
        ...recent.map((ipo) => _buildIPOListTile(ipo)),
      ],
    );
  }

  Widget _buildIPOListTile(IPOModel ipo) {
    final firstDayReturn = ipo.firstDayReturn;
    final color = firstDayReturn != null && firstDayReturn >= 0
        ? AppConstants.positiveColor
        : AppConstants.negativeColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IPODetailScreen(ipo: ipo),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: ipo.exchange == 'Main Board'
              ? Colors.blue[100]
              : Colors.orange[100],
          child: Text(
            ipo.ticker,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: ipo.exchange == 'Main Board'
                  ? Colors.blue[800]
                  : Colors.orange[800],
            ),
          ),
        ),
        title: Text(
          ipo.companyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${Formatters.formatDate(ipo.listingDate)} · ${ipo.sector ?? 'N/A'}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Formatters.formatReturn(firstDayReturn),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
            Text(
              '1r dia',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(IPOProvider provider) {
    final upcoming = provider.upcomingIPOs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Properes IPOs 🚀',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UpcomingIPOsScreen(),
                ),
              ),
              child: const Text('Veure totes'),
            ),
          ],
        ),
        ...upcoming.map((ipo) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: const Icon(Icons.schedule, color: Colors.green),
                ),
                title: Text(ipo.companyName),
                subtitle: Text(
                  '${Formatters.formatDate(ipo.listingDate)} · Preu: ${Formatters.formatCurrency(ipo.ipoPrice)}',
                ),
                trailing: Chip(
                  label: Text(
                    ipo.sector ?? 'N/A',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.blue[50],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildLastSyncInfo(IPOProvider provider) {
    if (provider.lastSyncDate == null) return const SizedBox.shrink();

    return Center(
      child: Text(
        'Última sincronització: ${Formatters.formatDateTime(provider.lastSyncDate!)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ipo_model.dart';
import '../services/ipo_provider.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

/// Pantalla de detall d'una IPO específica amb tots els càlculs de rendibilitat
class IPODetailScreen extends StatefulWidget {
  final IPOModel ipo;

  const IPODetailScreen({super.key, required this.ipo});

  @override
  State<IPODetailScreen> createState() => _IPODetailScreenState();
}

class _IPODetailScreenState extends State<IPODetailScreen> {
  late IPOModel _ipo;

  @override
  void initState() {
    super.initState();
    _ipo = widget.ipo;
  }

  Future<void> _refreshData() async {
    final provider = context.read<IPOProvider>();
    await provider.refreshData();

    // Buscar la versió actualitzada de la IPO
    final updated = provider.allIPOs.where(
      (i) => i.ticker == _ipo.ticker,
    ).firstOrNull;
    if (updated != null) {
      setState(() => _ipo = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_ipo.ticker} - ${_ipo.companyName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Actualitzar',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (!_ipo.isUpcoming) ...[
            _buildReturnsSection(),
            const SizedBox(height: 16),
            _buildComparisonChart(),
          ],
          const SizedBox(height: 16),
          _buildDetailsSection(),
          if (!_ipo.isUpcoming && _ipo.hasCompleteReturns) ...[
            const SizedBox(height: 16),
            _buildPerformanceSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalReturn = _ipo.totalReturn;
    final returnColor = totalReturn != null && totalReturn >= 0
        ? AppConstants.positiveColor
        : AppConstants.negativeColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo placeholder i ticker
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue[100],
              child: Text(
                _ipo.ticker,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _ipo.companyName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (_ipo.companyNameZH != null) ...[
              const SizedBox(height: 4),
              Text(
                _ipo.companyNameZH!,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Preu IPO i preu actual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPriceColumn('Preu IPO', _ipo.ipoPrice),
                if (_ipo.currentPrice != null)
                  _buildPriceColumn('Preu Actual', _ipo.currentPrice!),
                if (!_ipo.isUpcoming)
                  Column(
                    children: [
                      Text(
                        'Rendibilitat Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatReturn(totalReturn),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: returnColor,
                        ),
                      ),
                      Text(
                        '${_ipo.daysSinceListing} dies',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceColumn(String label, double price) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Formatters.formatCurrency(price),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildReturnsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rendibilitat per període',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildReturnRow('1r Dia', _ipo.firstDayReturn),
            const Divider(),
            _buildReturnRow('2n Dia', _ipo.secondDayReturn),
            const Divider(),
            _buildReturnRow('1a Setmana (5 dies)', _ipo.firstWeekReturn),
            const Divider(),
            _buildReturnRow('2a Setmana (10 dies)', _ipo.secondWeekReturn),
            if (_ipo.totalReturn != null) ...[
              const Divider(),
              _buildReturnRow('Total', _ipo.totalReturn, isTotal: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReturnRow(String label, double? value, {bool isTotal = false}) {
    final color = value != null && value >= 0
        ? AppConstants.positiveColor
        : AppConstants.negativeColor;
    final bgColor = value != null && value >= 0
        ? Colors.green[50]
        : Colors.red[50];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 15 : 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null) ...[
                  Icon(
                    value >= 0 ? Icons.trending_up : Icons.trending_down,
                    size: 18,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  Formatters.formatReturn(value),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: isTotal ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart() {
    // Gràfic de barres comparatiu senzill
    final returns = [
      _ipo.firstDayReturn,
      _ipo.secondDayReturn,
      _ipo.firstWeekReturn,
      _ipo.secondWeekReturn,
    ];

    final labels = ['1r Dia', '2n Dia', '1a Set', '2a Set'];
    final maxReturn = returns
            .where((r) => r != null)
            .cast<double>()
            .fold(0.0, (max, r) => r.abs() > max ? r.abs() : max) *
        1.3;

    if (maxReturn == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparativa visual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _ReturnsChartPainter(
                  returns: returns,
                  labels: labels,
                  maxValue: maxReturn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalls de l\'IPO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Ticker', _ipo.ticker),
            _buildDetailRow('Mercat', _ipo.exchange),
            _buildDetailRow('Data de sortida',
                Formatters.formatDate(_ipo.listingDate)),
            _buildDetailRow('Preu de sortida (HKD)',
                Formatters.formatCurrency(_ipo.ipoPrice)),
            _buildDetailRow(
              'Capital recaptat',
              '${Formatters.formatCompactCurrency(_ipo.fundsRaised)} HKD',
            ),
            if (_ipo.sector != null)
              _buildDetailRow('Sector', _ipo.sector!),
            _buildDetailRow(
              'Dies cotitzant',
              '${_ipo.daysSinceListing} dies',
            ),
            _buildDetailRow(
              'Última actualització',
              Formatters.formatDateTime(_ipo.lastUpdated),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    final bestReturn = _ipo.bestReturn;
    final worstReturn = _ipo.worstReturn;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resum de rendiment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    'Millor retorn',
                    Formatters.formatReturn(bestReturn),
                    bestReturn != null && bestReturn >= 0
                        ? AppConstants.positiveColor
                        : AppConstants.negativeColor,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStat(
                    'Pitjor retorn',
                    Formatters.formatReturn(worstReturn),
                    worstReturn != null && worstReturn >= 0
                        ? AppConstants.positiveColor
                        : AppConstants.negativeColor,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter personalitzat per al gràfic de rendibilitat
class _ReturnsChartPainter extends CustomPainter {
  final List<double?> returns;
  final List<String> labels;
  final double maxValue;

  _ReturnsChartPainter({
    required this.returns,
    required this.labels,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - 40;
    final chartHeight = size.height - 40;
    final barWidth = chartWidth / (returns.length * 2 + 1);
    final centerY = size.height / 2 + 10;

    // Dibuixar línia base
    final basePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(20, centerY),
      Offset(size.width - 20, centerY),
      basePaint,
    );

    for (int i = 0; i < returns.length; i++) {
      final value = returns[i];
      if (value == null) continue;

      final x = 20 + barWidth + (barWidth * 2) * i;
      final barHeight = (value / maxValue) * (chartHeight / 2);
      final isPositive = value >= 0;

      final paint = Paint()
        ..color = isPositive ? AppConstants.positiveColor : AppConstants.negativeColor
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, isPositive ? centerY - barHeight / 2 : centerY + barHeight / 2),
          width: barWidth,
          height: barHeight.abs(),
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);

      // Etiqueta
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

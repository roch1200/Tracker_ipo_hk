import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ipo_provider.dart';
import '../models/ipo_model.dart';
import '../models/ipo_model.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

/// Pantalla que mostra les properes IPOs a sortir al mercat de Hong Kong
class UpcomingIPOsScreen extends StatelessWidget {
  const UpcomingIPOsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properes IPOs'),
      ),
      body: Consumer<IPOProvider>(
        builder: (context, provider, child) {
          final upcoming = provider.upcomingIPOs;

          if (upcoming.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'No hi ha properes IPOs programades',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les dades s\'actualitzen automàticament',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Banner informatiu
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${upcoming.length} IPO${upcoming.length > 1 ? 's' : ''} propera${upcoming.length > 1 ? 's' : ''} a sortir al mercat de Hong Kong',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Llista de properes IPOs
              ...upcoming.map((ipo) => _buildUpcomingCard(context, ipo)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, IPOModel ipo) {
    final daysUntilListing = ipo.listingDate.difference(DateTime.now()).inDays;
    final isSoon = daysUntilListing <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSoon ? Colors.red[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isSoon ? '🚀 Molt proper!' : '📅 Properament',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSoon ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  ipo.ticker,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Nom empresa
            Text(
              ipo.companyName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (ipo.companyNameZH != null) ...[
              const SizedBox(height: 4),
              Text(
                ipo.companyNameZH!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Detalls
            Row(
              children: [
                _buildInfoChip(
                  Icons.calendar_today,
                  Formatters.formatDate(ipo.listingDate),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.timer,
                  '$daysUntilListing dies',
                  isSoon ? Colors.red : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  Icons.monetization_on,
                  'Preu: ${Formatters.formatCurrency(ipo.ipoPrice)}',
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.account_balance,
                  'Recaptació: ${Formatters.formatCompactCurrency(ipo.fundsRaised)}',
                  Colors.purple,
                ),
              ],
            ),
            if (ipo.sector != null) ...[
              const SizedBox(height: 8),
              _buildInfoChip(
                Icons.category,
                ipo.sector!,
                Colors.teal,
              ),
            ],
            const SizedBox(height: 16),
            // Compte enrere visual
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: isSoon ? daysUntilListing / 7 : null,
                backgroundColor: Colors.grey[200],
                color: isSoon ? Colors.red : Colors.blue,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSoon
                  ? 'Sortida imminent!'
                  : 'Falten $daysUntilListing dies per la sortida',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}



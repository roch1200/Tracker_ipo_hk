import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ipo_provider.dart';
import '../models/ipo_model.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';
import 'ipo_detail_screen.dart';

/// Pantalla que mostra totes les IPOs passades amb opcions de filtre i cerca
class PastIPOsScreen extends StatefulWidget {
  const PastIPOsScreen({super.key});

  @override
  State<PastIPOsScreen> createState() => _PastIPOsScreenState();
}

class _PastIPOsScreenState extends State<PastIPOsScreen> {
  String _sortBy = 'date_desc';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPOs Passades'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              context.read<IPOProvider>().sortIPOs(value);
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'date_desc',
                checked: _sortBy == 'date_desc',
                child: const Text('Data (més recent)'),
              ),
              CheckedPopupMenuItem(
                value: 'date_asc',
                checked: _sortBy == 'date_asc',
                child: const Text('Data (més antic)'),
              ),
              CheckedPopupMenuItem(
                value: 'return_desc',
                checked: _sortBy == 'return_desc',
                child: const Text('Millor rendiment 1r dia'),
              ),
              CheckedPopupMenuItem(
                value: 'return_asc',
                checked: _sortBy == 'return_asc',
                child: const Text('Pitjor rendiment 1r dia'),
              ),
              CheckedPopupMenuItem(
                value: 'funds_desc',
                checked: _sortBy == 'funds_desc',
                child: const Text('Capital recaptat'),
              ),
              CheckedPopupMenuItem(
                value: 'name_asc',
                checked: _sortBy == 'name_asc',
                child: const Text('Nom empresa'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de cerca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca per ticker, nom...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Llista d'IPOs
          Expanded(
            child: Consumer<IPOProvider>(
              builder: (context, provider, child) {
                final ipos = provider.pastIPOs;
                if (ipos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hi ha IPOs registrades',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar per cerca
                final filtered = _searchQuery.isEmpty
                    ? ipos
                    : ipos.where((ipo) =>
                        ipo.ticker
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        ipo.companyName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase())).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No s\'han trobat resultats'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ipo = filtered[index];
                    return _buildIPOCard(ipo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIPOCard(IPOModel ipo) {
    final firstDayReturn = ipo.firstDayReturn;
    final returnColor = firstDayReturn != null && firstDayReturn >= 0
        ? AppConstants.positiveColor
        : AppConstants.negativeColor;
    final returnBgColor = firstDayReturn != null && firstDayReturn >= 0
        ? Colors.green[50]
        : Colors.red[50];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IPODetailScreen(ipo: ipo),
          ),
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ticker
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: returnBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    ipo.ticker,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: returnColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Informació
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ipo.companyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.formatDate(ipo.listingDate)} · ${ipo.sector ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.monetization_on,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'IPO: ${Formatters.formatCurrency(ipo.ipoPrice)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (ipo.currentPrice != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.trending_up,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Actual: ${Formatters.formatCurrency(ipo.currentPrice!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Rendiment 1r dia
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: returnBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      Formatters.formatReturn(firstDayReturn),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: returnColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '1r dia',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
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

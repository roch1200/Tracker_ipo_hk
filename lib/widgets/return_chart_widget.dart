import 'package:flutter/material.dart';
import '../models/ipo_model.dart';
import '../utils/formatters.dart';

/// Widget de gràfic de barres per visualitzar la rendibilitat per període
class ReturnChartWidget extends StatelessWidget {
  final IPOModel ipo;

  const ReturnChartWidget({super.key, required this.ipo});

  @override
  Widget build(BuildContext context) {
    final returns = [
      {'label': '1r Dia', 'value': ipo.firstDayReturn},
      {'label': '2n Dia', 'value': ipo.secondDayReturn},
      {'label': '1a Set.', 'value': ipo.firstWeekReturn},
      {'label': '2a Set.', 'value': ipo.secondWeekReturn},
    ];

    // Calcular el valor màxim per escalar el gràfic
    double maxAbsValue = 0;
    for (final r in returns) {
      if (r['value'] != null) {
        final abs = (r['value'] as double).abs();
        if (abs > maxAbsValue) maxAbsValue = abs;
      }
    }
    if (maxAbsValue == 0) maxAbsValue = 1;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: returns.map((r) {
              final value = r['value'] as double?;
              final label = r['label'] as String;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (value != null)
                        Text(
                          Formatters.formatReturn(value),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: value >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        height: value != null
                            ? ((value.abs() / maxAbsValue) * 120).clamp(4, 120)
                            : 4,
                        decoration: BoxDecoration(
                          color: value != null
                              ? (value >= 0 ? Colors.green : Colors.red)
                              : Colors.grey,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

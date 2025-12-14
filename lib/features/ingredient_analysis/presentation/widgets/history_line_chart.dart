import 'package:bienestar_integral_app/features/ingredient_analysis/domain/entities/ingredient_history.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoryLineChart extends StatelessWidget {
  final List<HistoryPoint> points;

  const HistoryLineChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Si no hay suficientes datos, mostramos mensaje
    if (points.isEmpty) {
      return const Center(child: Text("No hay datos históricos para graficar"));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colors.surfaceVariant.withOpacity(0.3),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Evolución de Compras",
              style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colors.outline.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: colors.outline.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < points.length) {
                            // Mostrar solo la fecha corta (MM-DD)
                            final dateParts = points[index].fecha.split('-');
                            if (dateParts.length == 3) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "${dateParts[1]}/${dateParts[2]}",
                                  style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
                                ),
                              );
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: colors.outline.withOpacity(0.5)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.cantidadCompras.toDouble());
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.secondary],
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            colors.primary.withOpacity(0.3),
                            colors.primary.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
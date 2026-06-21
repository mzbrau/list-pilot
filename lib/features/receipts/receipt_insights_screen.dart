import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_providers.dart';
import '../../data/services/receipt_ai_insights_service.dart';
import '../../data/services/receipt_insights_service.dart';
import '../../router/navigation_helpers.dart';
import 'receipt_formatters.dart';

class ReceiptInsightsScreen extends ConsumerStatefulWidget {
  const ReceiptInsightsScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<ReceiptInsightsScreen> createState() =>
      _ReceiptInsightsScreenState();
}

class _ReceiptInsightsScreenState extends ConsumerState<ReceiptInsightsScreen> {
  bool _generatingAi = false;

  Future<void> _generateAiInsights() async {
    final aiConfig = ref.read(aiConfigProvider);
    if (!aiConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configure AI import in Settings before generating insights'),
        ),
      );
      return;
    }

    setState(() => _generatingAi = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final receipts =
          await ref.read(receiptsForListProvider(widget.listId).future);
      final lines =
          await ref.read(receiptRepositoryProvider).getLinesForList(widget.listId);
      final content = await ref.read(receiptAiInsightsServiceProvider).generateInsights(
            receipts: receipts,
            lines: lines,
          );
      await ref.read(receiptRepositoryProvider).saveAiInsightRun(
            listId: widget.listId,
            content: content,
          );
    } on ReceiptAiInsightsException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Failed to generate insights: $e')));
    } finally {
      if (mounted) setState(() => _generatingAi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(receiptInsightsSnapshotProvider(widget.listId));
    final aiInsightAsync = ref.watch(receiptAiInsightProvider(widget.listId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: overviewBackButton(context),
          title: const Text('Receipt insights'),
        ),
        body: snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (snapshot) {
            if (snapshot.tripPoints.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No receipt data yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Import receipts to see spending charts and insights.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final categoryNames = <String, String>{
              for (final category in categoriesAsync.valueOrNull ?? [])
                category.id: category.name,
            };
            final chartColors = _chartColors(theme);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionTitle(title: 'Spend over time'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 220,
                      child: _TripLineChart(
                        points: snapshot.tripPoints,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Monthly spend by category'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 240,
                      child: _MonthlyCategoryChart(
                        months: snapshot.monthlyCategorySpend,
                        categoryNames: categoryNames,
                        colors: chartColors,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Total by category'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      for (final entry in snapshot.categoryTotals) ...[
                        ListTile(
                          title: Text(categoryNames[entry.categoryId] ?? entry.categoryId),
                          trailing: Text(formatReceiptAmount(entry.total)),
                        ),
                        if (entry != snapshot.categoryTotals.last)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Top 10 items'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      for (final item in snapshot.topItems) ...[
                        ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.purchaseCount} purchases'),
                          trailing: Text(formatReceiptAmount(item.total)),
                        ),
                        if (item != snapshot.topItems.last) const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'AI insights'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Generate narrative insights from your receipt history.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _generatingAi ? null : _generateAiInsights,
                          icon: _generatingAi
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome_outlined),
                          label: Text(_generatingAi ? 'Generating…' : 'Generate insights'),
                        ),
                        aiInsightAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (run) {
                            if (run == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Generated ${DateFormat.yMMMd().add_jm().format(run.generatedAt)}',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(run.content),
                                ],
                              ),
                            );
                          },
                        ),
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

  List<Color> _chartColors(ThemeData theme) {
    final scheme = theme.colorScheme;
    return [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.pink,
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _TripLineChart extends StatelessWidget {
  const _TripLineChart({required this.points, required this.color});

  final List<ReceiptTripPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      final point = points.first;
      return Center(
        child: Text(
          '${point.shopName}\n${formatReceiptAmount(point.totalAmount)}',
          textAlign: TextAlign.center,
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].totalAmount));
    }

    final maxY = points.map((p) => p.totalAmount).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.1,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat.Md().format(points[index].purchasedAt),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _MonthlyCategoryChart extends StatelessWidget {
  const _MonthlyCategoryChart({
    required this.months,
    required this.categoryNames,
    required this.colors,
  });

  final List<MonthlyCategorySpend> months;
  final Map<String, String> categoryNames;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return const Center(child: Text('No monthly data'));
    }

    final categories = <String>{};
    for (final month in months) {
      categories.addAll(month.categoryTotals.keys);
    }
    final categoryList = categories.toList()..sort();

    final maxTotal = months
        .map((month) => month.total)
        .fold(0.0, (max, value) => value > max ? value : max);

    return BarChart(
      BarChartData(
        maxY: maxTotal == 0 ? 1 : maxTotal * 1.15,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= months.length) {
                  return const SizedBox.shrink();
                }
                final month = months[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat.MMM().format(DateTime(month.year, month.month)),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < months.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: months[i].total,
                  width: 18,
                  rodStackItems: [
                    for (var c = 0; c < categoryList.length; c++)
                      if ((months[i].categoryTotals[categoryList[c]] ?? 0) > 0)
                        BarChartRodStackItem(
                          _stackFrom(months[i], categoryList, c),
                          _stackTo(months[i], categoryList, c),
                          colors[c % colors.length],
                        ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  double _stackFrom(MonthlyCategorySpend month, List<String> categories, int index) {
    var total = 0.0;
    for (var i = 0; i < index; i++) {
      total += month.categoryTotals[categories[i]] ?? 0;
    }
    return total;
  }

  double _stackTo(MonthlyCategorySpend month, List<String> categories, int index) {
    return _stackFrom(month, categories, index) +
        (month.categoryTotals[categories[index]] ?? 0);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/ai/tflite_service.dart';

class PricePredictionScreen extends StatefulWidget {
  const PricePredictionScreen({super.key});

  @override
  State<PricePredictionScreen> createState() => _PricePredictionScreenState();
}

class _PricePredictionScreenState extends State<PricePredictionScreen> {
  Map<String, dynamic>? _predictionData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrediction();
  }

  Future<void> _loadPrediction() async {
    setState(() => _isLoading = true);

    final tfliteService = context.read<TFLiteService>();
    final data = await tfliteService.predictPrices();

    setState(() {
      _predictionData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Price Prediction'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            )
                : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPrediction,
        backgroundColor: AppColors.primaryBrown,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildContent() {
    if (_predictionData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Text('Failed to load prediction'),
        ),
      );
    }

    final currentPrice = _predictionData! ['currentPrice'] as double;
    final predictions = _predictionData!['predictions'] as List;
    final weeklyChange = _predictionData!['weeklyChange'] as double;
    final trend = _predictionData!['trend'] as String;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Price Card
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Market Price',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Rs. ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        currentPrice.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '/kg',
                        style: TextStyle(
                          color: Colors. white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        weeklyChange >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: weeklyChange >= 0 ? AppColors.accentGreen : AppColors.accentRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${weeklyChange >= 0 ? '+' : ''}${weeklyChange.toStringAsFixed(1)}% this week',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Price Trend Chart
          const Text(
            'Price Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      _buildChartData(currentPrice, predictions),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTrendIndicator(trend),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Predictions Table
          const Text(
            'Next 3 Months Predictions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ... predictions.map((prediction) {
            final month = prediction['month'] as DateTime;
            final price = prediction['price'] as double;
            final confidence = prediction['confidence'] as double;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrown. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryBrown,
                  ),
                ),
                title: Text(
                  DateFormat('MMMM yyyy').format(month),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Confidence: ${confidence.toStringAsFixed(0)}%',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                    Text(
                      '±${(price * 0.03).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }). toList(),

          const SizedBox(height: 24),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentYellow. withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentYellow),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.accentYellow,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Predictions are based on historical data and market trends.  Actual prices may vary.',
                    style: TextStyle(
                      color: AppColors.textPrimary. withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  LineChartData _buildChartData(double currentPrice, List predictions) {
    final spots = <FlSpot>[
      FlSpot(0, currentPrice),
    ];

    for (int i = 0; i < predictions.length; i++) {
      final price = predictions[i]['price'] as double;
      spots.add(FlSpot((i + 1). toDouble(), price));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 50,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                'Rs. ${value.toInt()}',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final labels = ['Now', 'M1', 'M2', 'M3'];
              if (value. toInt() >= 0 && value.toInt() < labels.length) {
                return Text(labels[value.toInt()]);
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors. primaryBrown,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryBrown.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(String trend) {
    final isUpward = trend == 'upward';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isUpward
            ? AppColors.accentGreen. withOpacity(0.1)
            : AppColors.accentRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUpward ? Icons. arrow_upward : Icons.arrow_downward,
            color: isUpward ? AppColors.accentGreen : AppColors.accentRed,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '${trend. toUpperCase()} TREND',
            style: TextStyle(
              color: isUpward ?  AppColors.accentGreen : AppColors.accentRed,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
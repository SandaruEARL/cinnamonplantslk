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
  // Available districts and grades
  final List<String> _districts = [
    'All Districts',
    'Galle',
    'Matara',
    'Hambantota',
    'Kalutara',
    'Ratnapura',
    'Gampaha',
  ];

  final List<String> _grades = [
    'All Grades',
    'Alba',
    'C5 Special',
    'C5',
    'C4',
    'M5',
    'M4',
    'H1',
    'H2',
  ];

  String _selectedDistrict = 'All Districts';
  String _selectedGrade = 'All Grades';

  Map<String, dynamic>? _predictionData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    setState(() => _isLoading = true);

    try {
      final tfliteService = context.read<TFLiteService>();

      // Get predictions based on selected filters
      final data = await tfliteService.predictPrices(
        district: _selectedDistrict == 'All Districts' ? null : _selectedDistrict,
        grade: _selectedGrade == 'All Grades' ? null : _selectedGrade,
      );

      setState(() {
        _predictionData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading predictions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Price Predictions'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          // Filters
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // District Filter
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDistrict,
                              isExpanded: true,
                              items: _districts.map((district) {
                                return DropdownMenuItem(
                                  value: district,
                                  child: Text(district),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedDistrict = value;
                                  });
                                  _loadPredictions();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Grade Filter
                  Row(
                    children: [
                      const Icon(Icons.grade, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGrade,
                              isExpanded: true,
                              items: _grades.map((grade) {
                                return DropdownMenuItem(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedGrade = value;
                                  });
                                  _loadPredictions();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content
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
        onPressed: _loadPredictions,
        backgroundColor: AppColors.primaryBrown,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildContent() {
    if (_predictionData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No predictions available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting different filters',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentPrice = _predictionData!['currentPrice'] as double;
    final predictions = _predictionData!['predictions'] as List;
    final weeklyChange = _predictionData!['weeklyChange'] as double;
    final trend = _predictionData!['trend'] as String;
    final isMock = _predictionData!['mock'] ?? false;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock Data Warning (if using mock data)
          if (isMock)
            Card(
              color: AppColors.accentYellow.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.accentYellow),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Showing sample data. Select specific district and grade for real predictions.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (isMock) const SizedBox(height: 16),

          // Selection Summary
          if (!isMock)
            Card(
              color: AppColors.primaryBrown.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryBrown),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Showing $_selectedGrade in $_selectedDistrict',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on 30 days of historical data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

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
                  Row(
                    children: [
                      Text(
                        isMock ? 'Sample Price' : 'Current Market Price',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (!isMock) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ],
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
                          color: Colors.white,
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
                        '${weeklyChange >= 0 ? '+' : ''}${weeklyChange.toStringAsFixed(1)}% next 7 days',
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
            '7-Day Price Forecast',
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

          // Predictions Table (Daily breakdown)
          const Text(
            'Daily Price Predictions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ...predictions.asMap().entries.map((entry) {
            final index = entry.key;
            final prediction = entry.value;

            // Get date and price
            final date = prediction['date'] as DateTime;
            final avgPrice = prediction['average_price'] as double;
            final highPrice = prediction['high_price'] as double;
            final confidence = prediction['confidence'] as double;

            // Calculate change from current price
            final change = ((avgPrice - currentPrice) / currentPrice * 100);

            // Day label
            final dayLabel = index == 0
                ? 'Tomorrow'
                : index == 1
                ? 'Day ${index + 1}'
                : 'Day ${index + 1}';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryBrown,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      dayLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd').format(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'High: Rs. ${highPrice.toStringAsFixed(0)} • Confidence: ${confidence.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: change >= 0 ? AppColors.accentGreen : AppColors.accentRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% vs today',
                          style: TextStyle(
                            fontSize: 12,
                            color: change >= 0 ? AppColors.accentGreen : AppColors.accentRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${avgPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                    Text(
                      'avg',
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

          const SizedBox(height: 24),

          // Quick Compare Button
          if (_selectedDistrict != 'All Districts' || _selectedGrade != 'All Grades')
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDistrict = 'All Districts';
                  _selectedGrade = 'All Grades';
                });
                _loadPredictions();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.1),
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
                    'Predictions are based on historical data and market trends. Actual prices may vary.',
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.7),
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
      final prediction = predictions[i];
      final avgPrice = prediction['average_price'] as double;
      spots.add(FlSpot((i + 1).toDouble(), avgPrice));
    }

    // Calculate min/max for better chart scaling
    final allPrices = [currentPrice, ...predictions.map((p) => p['average_price'] as double)];
    final minPrice = allPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = allPrices.reduce((a, b) => a > b ? a : b);
    final padding = (maxPrice - minPrice) * 0.1;

    return LineChartData(
      minY: minPrice - padding,
      maxY: maxPrice + padding,
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: true,
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
              final labels = ['Now', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7'];
              if (value.toInt() >= 0 && value.toInt() < labels.length) {
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
          color: AppColors.primaryBrown,
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
            ? AppColors.accentGreen.withOpacity(0.1)
            : AppColors.accentRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUpward ? Icons.arrow_upward : Icons.arrow_downward,
            color: isUpward ? AppColors.accentGreen : AppColors.accentRed,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '${trend.toUpperCase()} TREND',
            style: TextStyle(
              color: isUpward ? AppColors.accentGreen : AppColors.accentRed,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/ai/tflite_service.dart';

class PricePredictionScreen extends StatefulWidget {
  const PricePredictionScreen({super.key});

  @override
  State<PricePredictionScreen> createState() => _PricePredictionScreenState();
}

class _PricePredictionScreenState extends State<PricePredictionScreen> {
  final List<String> _districts = [
    'All Districts',
    'Badulla',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Kalutara',
    'Matara',
    'Monaragala',
    'Ratnapura',
    // ✅ REMOVED: 'National' - it's a benchmark, not a prediction target
  ];

  final List<String> _grades = [
    'All Grades',
    'Alba',
    'C-4',
    'C-5',
    'C-5 Sp',
    'M-4',
    'M-5',
    'H-1',
    'H-2',
    'H-Faq',
    'Heen',
    'Gorosu',
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Price Predictions'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _predictionData == null
          ? _buildEmptyState()
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(),
              const SizedBox(height: 16),
              _buildPriceCard(isDarkMode),
              const SizedBox(height: 24),
              _buildChart(isDarkMode),
              const SizedBox(height: 24),
              _buildPredictionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No predictions available',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a district and grade',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildDropdown(
                icon: Icons.location_on,
                value: _selectedDistrict,
                items: _districts,
                onChanged: (value) {
                  setState(() => _selectedDistrict = value!);
                  _loadPredictions();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                icon: Icons.grade,
                value: _selectedGrade,
                items: _grades,
                onChanged: (value) {
                  setState(() => _selectedGrade = value!);
                  _loadPredictions();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(bool isDarkMode) {
    final currentPrice = _predictionData!['currentPrice'] as double;
    final monthlyChange = _predictionData!['monthlyChange'] as double; // ✅ Changed from weeklyChange
    final isMock = _predictionData!['mock'] ?? false;

    // National benchmark if available
    final nationalPrice = _predictionData!['nationalPrice'] as double?;
    final priceVsNational = nationalPrice != null
        ? ((currentPrice - nationalPrice) / nationalPrice * 100)
        : null;

    return Card(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isMock ? 'Sample Price' : 'Current Price',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                if (isMock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'DEMO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Rs. ',
                  style: TextStyle(color: Colors.white, fontSize: 24),
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
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Monthly change indicator (not weekly)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    monthlyChange >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${monthlyChange >= 0 ? '+' : ''}${monthlyChange.toStringAsFixed(1)}% (4 weeks)', // ✅ Changed from 7 days
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // National comparison (only show if specific district selected)
            if (nationalPrice != null && priceVsNational != null && _selectedDistrict != 'All Districts') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      priceVsNational >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${priceVsNational >= 0 ? '+' : ''}${priceVsNational.toStringAsFixed(1)}% vs National (Rs. ${nationalPrice.toStringAsFixed(0)})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart(bool isDarkMode) {
    final currentPrice = _predictionData!['currentPrice'] as double;
    final predictions = _predictionData!['predictions'] as List;
    final trend = _predictionData!['trend'] as String;
    final nationalPrice = _predictionData!['nationalPrice'] as double?;

    // Prepare district chart data
    final List<_ChartData> chartData = [
      _ChartData(DateTime.now(), currentPrice, isNational: false),
    ];

    for (var prediction in predictions) {
      chartData.add(
        _ChartData(
          prediction['date'] as DateTime,
          prediction['average_price'] as double,
          isNational: false,
        ),
      );
    }

    // Prepare national benchmark data (if available and specific district selected)
    List<_ChartData>? nationalData;
    if (nationalPrice != null && _selectedDistrict != 'All Districts') {
      nationalData = [
        _ChartData(DateTime.now(), nationalPrice, isNational: true),
      ];

      for (var prediction in predictions) {
        final nationalPred = prediction['national_average'] as double?;
        if (nationalPred != null) {
          nationalData.add(
            _ChartData(
              prediction['date'] as DateTime,
              nationalPred,
              isNational: true,
            ),
          );
        }
      }
    }

    // Calculate Y-axis range (include national prices)
    final allPrices = [
      ...chartData.map((d) => d.price),
      if (nationalData != null) ...nationalData.map((d) => d.price),
    ];
    final minPrice = allPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = allPrices.reduce((a, b) => a > b ? a : b);
    final padding = (maxPrice - minPrice) * 0.1;

    final chartGradient = isDarkMode
        ? LinearGradient(
      colors: [
        Colors.lightBlueAccent.withOpacity(0.6),
        Colors.lightBlueAccent.withOpacity(0.2),
        Colors.transparent,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
    )
        : LinearGradient(
      colors: [
        AppColors.primaryBrown.withOpacity(0.6),
        AppColors.primaryBrown.withOpacity(0.2),
        Colors.transparent,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
    );

    final borderColor = isDarkMode ? Colors.lightBlueAccent : AppColors.primaryBrown;
    final nationalColor = isDarkMode ? Colors.orange : Colors.deepOrange;
    final gridColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final axisTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '4-Week Forecast', // ✅ Changed from 7-Day Forecast
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Legend
            if (nationalData != null && nationalData.isNotEmpty)
              Row(
                children: [
                  _buildLegendItem('District', borderColor),
                  const SizedBox(width: 12),
                  _buildLegendItem('National', nationalColor, isDashed: true),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 220,
                    child: SfCartesianChart(
                      backgroundColor: Colors.transparent,
                      plotAreaBorderWidth: 0,
                      primaryXAxis: DateTimeAxis(
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        intervalType: DateTimeIntervalType.auto,
                        majorGridLines: MajorGridLines(width: 0.5, color: gridColor),
                        axisLabelFormatter: (details) => ChartAxisLabel(
                          details.text,
                          TextStyle(color: axisTextColor, fontSize: 10),
                        ),
                        dateFormat: DateFormat.MMMd(),
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: minPrice - padding,
                        maximum: maxPrice + padding,
                        majorGridLines: MajorGridLines(width: 0.5, color: gridColor),
                        numberFormat: NumberFormat.compact(),
                        axisLine: const AxisLine(width: 0),
                        axisLabelFormatter: (details) => ChartAxisLabel(
                          'Rs ${details.text}',
                          TextStyle(color: axisTextColor, fontSize: 10),
                        ),
                      ),
                      series: <CartesianSeries<_ChartData, DateTime>>[
                        // District price (area chart)
                        AreaSeries<_ChartData, DateTime>(
                          dataSource: chartData,
                          xValueMapper: (data, _) => data.date,
                          yValueMapper: (data, _) => data.price,
                          gradient: chartGradient,
                          borderColor: borderColor,
                          borderWidth: 2,
                          name: 'District',
                        ),
                        // National benchmark (dashed line)
                        if (nationalData != null && nationalData.isNotEmpty)
                          LineSeries<_ChartData, DateTime>(
                            dataSource: nationalData,
                            xValueMapper: (data, _) => data.date,
                            yValueMapper: (data, _) => data.price,
                            color: nationalColor,
                            width: 2,
                            dashArray: const <double>[5, 5],
                            name: 'National',
                            markerSettings: MarkerSettings(
                              isVisible: true,
                              shape: DataMarkerType.circle,
                              color: nationalColor,
                              borderColor: Colors.white,
                              borderWidth: 2,
                              height: 6,
                              width: 6,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildTrendIndicator(trend),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper for legend items
  Widget _buildLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDashed)
          CustomPaint(
            size: const Size(20, 2),
            painter: DashedLinePainter(color: color),
          )
        else
          Container(
            width: 20,
            height: 2,
            color: color,
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
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
            isUpward ? Icons.trending_up : Icons.trending_down,
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

  Widget _buildPredictionsList() {
    final currentPrice = _predictionData!['currentPrice'] as double;
    final predictions = _predictionData!['predictions'] as List;
    final nationalPrice = _predictionData!['nationalPrice'] as double?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Breakdown', // ✅ Changed from Daily Breakdown
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...predictions.take(4).map((prediction) { // ✅ Changed from 7 to 4
          final date = prediction['date'] as DateTime;
          final avgPrice = prediction['average_price'] as double;
          final highPrice = prediction['high_price'] as double;
          final change = ((avgPrice - currentPrice) / currentPrice * 100);
          final nationalAvg = prediction['national_average'] as double?;

          final weeksDiff = (date.difference(DateTime.now()).inDays / 7).round();
          final weekLabel = weeksDiff == 1 ? 'Next Week' : 'Week $weeksDiff'; // ✅ Changed label

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weekLabel, // ✅ Changed from Day label
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'High: Rs. ${highPrice.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${avgPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 14,
                                color: change >= 0
                                    ? AppColors.accentGreen
                                    : AppColors.accentRed,
                              ),
                              Text(
                                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: change >= 0
                                      ? AppColors.accentGreen
                                      : AppColors.accentRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // National comparison row
                  if (nationalAvg != null && _selectedDistrict != 'All Districts') ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.public,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'National: Rs. ${nationalAvg.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (avgPrice > nationalAvg
                                ? AppColors.accentRed
                                : AppColors.accentGreen)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${avgPrice > nationalAvg ? '+' : ''}${(avgPrice - nationalAvg).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: avgPrice > nationalAvg
                                  ? AppColors.accentRed
                                  : AppColors.accentGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accentYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accentYellow.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.accentYellow.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weekly predictions based on 3 months of historical data and national benchmarks. Actual prices may vary.', // ✅ Updated text
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Chart data class
class _ChartData {
  final DateTime date;
  final double price;
  final bool isNational;

  _ChartData(this.date, this.price, {this.isNational = false});
}

// Dashed line painter for legend
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
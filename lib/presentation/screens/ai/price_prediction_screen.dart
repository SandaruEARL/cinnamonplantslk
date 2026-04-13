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
    'All Districts', 'Badulla', 'Colombo', 'Galle', 'Gampaha',
    'Hambantota', 'Kalutara', 'Matara', 'Monaragala', 'Ratnapura',
  ];

  final List<String> _grades = [
    'All Grades', 'Alba', 'C-4', 'C-5', 'C-5 Sp', 'M-4',
    'M-5', 'H-1', 'H-2', 'H-Faq', 'Heen', 'Gorosu',
  ];

  String _selectedDistrict = 'Galle';
  String _selectedGrade = 'C-4';
  Map<String, dynamic>? _predictionData;
  bool _isLoading = true;
  String? _dataUpdatedAt;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    setState(() => _isLoading = true);
    try {
      final tfliteService = context.read<TFLiteService>();

      if (tfliteService.getModelUpdatedAt() == null) {
        await tfliteService.checkForModelUpdate();
      }

      final data = await tfliteService.predictPrices(
        district: _selectedDistrict == 'All Districts' ? null : _selectedDistrict,
        grade: _selectedGrade == 'All Grades' ? null : _selectedGrade,
      );
      setState(() {
        _predictionData = data;
        _dataUpdatedAt = context.read<TFLiteService>().getModelUpdatedAt();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading predictions: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ── AppBar ────────────────────────────────────────────────────
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Price Predictions',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _predictionData == null
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            _buildPriceCard(),
            const SizedBox(height: 24),
            _buildChart(),
            const SizedBox(height: 24),
            _buildPredictionsList(),
          ],
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
          Text('No predictions available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Select a district and grade',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ── Filters ─────────────────────────────────────────────────────
  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(child: _buildDropdown(
          value: _selectedDistrict,
          items: _districts,
          onChanged: (value) {
            setState(() => _selectedDistrict = value!);
            _loadPredictions();
          },
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildDropdown(
          value: _selectedGrade,
          items: _grades,
          onChanged: (value) {
            setState(() => _selectedGrade = value!);
            _loadPredictions();
          },
        )),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Price Card ───────────────────────────────────────────────────
  Widget _buildPriceCard() {
    final currentPrice = _predictionData!['currentPrice'] as double;
    final monthlyChange = _predictionData!['monthlyChange'] as double;
    final isMock = _predictionData!['mock'] ?? false;
    final nationalPrice = _predictionData!['nationalPrice'] as double?;
    final priceVsNational = nationalPrice != null
        ? ((currentPrice - nationalPrice) / nationalPrice * 100)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),   // ← dark gray, matches screenshot
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMock ? 'Sample Price' : 'Current Price',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (isMock)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('DEMO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Big price
          Text(
            'Rs.${currentPrice.toStringAsFixed(0)} / KG',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Monthly change pill
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
                  monthlyChange >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${monthlyChange >= 0 ? '+' : ''}${monthlyChange.toStringAsFixed(1)} % (4 weeks)',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // National comparison pill
          if (nationalPrice != null &&
              priceVsNational != null &&
              _selectedDistrict != 'All Districts') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    priceVsNational >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${priceVsNational >= 0 ? '+' : ''}${priceVsNational.toStringAsFixed(1)} vs National (Rs. ${nationalPrice.toStringAsFixed(0)})',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_dataUpdatedAt != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 5),
                Text(
                  'Last updated: ${_formatUpdatedAt(_dataUpdatedAt!)}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Chart ────────────────────────────────────────────────────────
  Widget _buildChart() {
    final currentPrice = _predictionData!['currentPrice'] as double;
    final predictions = _predictionData!['predictions'] as List;
    final trend = _predictionData!['trend'] as String;
    final nationalPrice = _predictionData!['nationalPrice'] as double?;

    final List<_ChartData> chartData = [
      _ChartData(DateTime.now(), currentPrice),
      ...predictions.map((p) =>
          _ChartData(p['date'] as DateTime, p['average_price'] as double)),
    ];

    List<_ChartData>? nationalData;
    if (nationalPrice != null && _selectedDistrict != 'All Districts') {
      nationalData = [
        _ChartData(DateTime.now(), nationalPrice),
        ...predictions
            .where((p) => p['national_average'] != null)
            .map((p) =>
            _ChartData(p['date'] as DateTime, p['national_average'] as double)),
      ];
    }

    final allPrices = [
      ...chartData.map((d) => d.price),
      if (nationalData != null) ...nationalData.map((d) => d.price),
    ];
    final minPrice = allPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = allPrices.reduce((a, b) => a > b ? a : b);
    final padding = (maxPrice - minPrice) * 0.15;

    const borderColor = AppColors.primaryGreen;
    final nationalColor = AppColors.primaryGreen.withOpacity(0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('4 - week forecast',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            if (nationalData != null)
              Row(
                children: [
                  _buildLegendItem('District', borderColor),
                  const SizedBox(width: 10),
                  _buildLegendItem('National', nationalColor,
                      isDashed: true),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: SfCartesianChart(
                      backgroundColor: Colors.transparent,
                      plotAreaBorderWidth: 0,
                      primaryXAxis: DateTimeAxis(
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        majorGridLines: const MajorGridLines(
                            width: 0.5, color: Color(0xFFEEEEEE)),
                        axisLabelFormatter: (details) => ChartAxisLabel(
                          details.text,
                          TextStyle(
                              color: Colors.grey[600], fontSize: 10),
                        ),
                        dateFormat: DateFormat.MMMd(),
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: minPrice - padding,
                        maximum: maxPrice + padding,
                        majorGridLines: const MajorGridLines(
                            width: 0.5, color: Color(0xFFEEEEEE)),
                        numberFormat: NumberFormat.compact(),
                        axisLine: const AxisLine(width: 0),
                        axisLabelFormatter: (details) => ChartAxisLabel(
                          'Rs ${details.text}',
                          TextStyle(
                              color: Colors.grey[600], fontSize: 10),
                        ),
                      ),
                      series: <CartesianSeries<_ChartData, DateTime>>[
                        AreaSeries<_ChartData, DateTime>(
                          dataSource: chartData,
                          xValueMapper: (d, _) => d.date,
                          yValueMapper: (d, _) => d.price,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.35),
                              AppColors.primaryGreen.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderColor: borderColor,
                          borderWidth: 2,
                          animationDuration: 0,
                        ),
                        if (nationalData != null &&
                            nationalData.isNotEmpty)
                          LineSeries<_ChartData, DateTime>(
                            dataSource: nationalData,
                            xValueMapper: (d, _) => d.date,
                            yValueMapper: (d, _) => d.price,
                            color: nationalColor,
                            width: 2,
                            dashArray: const <double>[5, 5],
                            animationDuration: 0,
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
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTrendIndicator(trend),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color,
      {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDashed)
          CustomPaint(
              size: const Size(20, 2),
              painter: DashedLinePainter(color: color))
        else
          Container(width: 20, height: 2, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
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
            color:
            isUpward ? AppColors.accentGreen : AppColors.accentRed,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '${trend.toUpperCase()} TREND',
            style: TextStyle(
              color: isUpward
                  ? AppColors.accentGreen
                  : AppColors.accentRed,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Weekly Breakdown ─────────────────────────────────────────────
  Widget _buildPredictionsList() {
    final currentPrice = _predictionData!['currentPrice'] as double;
    final predictions = _predictionData!['predictions'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weekly Breakdown',
            style:
            TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...predictions.take(4).map((prediction) {
          final date = prediction['date'] as DateTime;
          final avgPrice = prediction['average_price'] as double;
          final highPrice = prediction['high_price'] as double;
          final change =
          ((avgPrice - currentPrice) / currentPrice * 100);
          final nationalAvg =
          prediction['national_average'] as double?;
          final weeksDiff =
          (date.difference(DateTime.now()).inDays / 7).round();
          final weekLabel =
          weeksDiff == 1 ? 'Next Week' : 'Week $weeksDiff';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF358841),    // ← green filled
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Left: labels
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weekLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM dd').format(date),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Highest: Rs. ${highPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // Right: price + change
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${avgPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              change >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 13,
                              color: Colors.white,
                            ),
                            Text(
                              '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // National row
                if (nationalAvg != null &&
                    _selectedDistrict != 'All Districts') ...[
                  const SizedBox(height: 10),
                  const Divider(
                      height: 1, color: Colors.white24),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('National: ',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      Text('Rs. ${nationalAvg.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${avgPrice > nationalAvg ? '+' : ''}${(avgPrice - nationalAvg).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 8),

        // Disclaimer
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline,
                size: 14, color: Colors.grey[500]),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Weekly predictions based on 3 months of historical data and national benchmarks. Actual prices may vary.',
                style:
                TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }
  String _formatUpdatedAt(String rawDate) {
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }
}

// ── Chart data ────────────────────────────────────────────────────────────────

class _ChartData {
  final DateTime date;
  final double price;
  _ChartData(this.date, this.price);
}

// ── Dashed line painter ───────────────────────────────────────────────────────

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


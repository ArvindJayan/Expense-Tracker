import 'package:expensetracker/models/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Widget for displaying a bar graph
class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  // Initialize bar data based on monthly summary
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) {
        // Calculate month offset based on start month and index
        int monthOffset = (index + widget.startMonth - 1) % 12;
        return IndividualBar(x: monthOffset, y: widget.monthlySummary[index]);
      },
    );
  }

  // Calculate the maximum value for the Y-axis of the bar chart
  double calculateMax() {
    double max = 10000;
    widget.monthlySummary.sort();
    max = widget.monthlySummary.last * 1.3;

    if (max < 5000) {
      return 5000;
    } else {
      return max;
    }
  }

  final ScrollController _scrollController = ScrollController();

  // Scroll to the end of the bar graph
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return getBottomTitles(value, meta, widget.startMonth);
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              barGroups: barData
                  .map(
                    (data) => BarChartGroupData(
                      x: data.x,
                      barRods: [
                        BarChartRodData(
                          toY: data.y,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                          color: Color.fromARGB(255, 217, 17, 17),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: calculateMax(),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for displaying the month labels on the X-axis of the bar chart
Widget getBottomTitles(double value, TitleMeta meta, int startMonth) {
  const textstyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  int index = value.toInt();
  String text;

  // Adjust for starting month offset
  int monthOffset = (index + startMonth - 1) % 12;
  text = months[monthOffset];

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(
      text,
      style: textstyle,
    ),
  );
}

const List<String> months = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

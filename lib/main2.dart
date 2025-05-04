import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Web',
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isCollapsed = false;
  int selectedIndex = 0;

  final List<String> menuTitles = [
    "Home",
    "Photobioreactors",
    "Control Center",
  ];

  Widget _buildPageContent() {
    switch (selectedIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location & Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Kota Kinabalu",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Saturday, May 3",
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),

                    // Main Weather Info
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wb_sunny,
                            size: 40, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text("30°C",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),

                    // Extra Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Humidity: 70%",
                            style: TextStyle(fontSize: 16)),
                        Text("Wind: 12 km/h",
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    // Left container
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Photobioreactors",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView(
                                children: List.generate(4, (index) {
                                  final isOnline = index % 2 == 0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: isOnline
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Photobioreactor ${index + 1}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Text(
                                          isOnline ? "Online" : "Offline",
                                          style: TextStyle(
                                            color: isOnline
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Average Carbon Captured",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                // Chart legend
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.blue, Colors.blueAccent],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "kg CO₂",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 180,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0, bottom: 20.0),
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: true,
                                      horizontalInterval: 2,
                                      verticalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.shade300,
                                          strokeWidth: 1,
                                        );
                                      },
                                      getDrawingVerticalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.shade300,
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            const style = TextStyle(
                                              color: Color(0xff68737d),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            );
                                            String text;
                                            switch (value.toInt()) {
                                              case 0:
                                                text = 'Mon';
                                                break;
                                              case 1:
                                                text = 'Tue';
                                                break;
                                              case 2:
                                                text = 'Wed';
                                                break;
                                              case 3:
                                                text = 'Thu';
                                                break;
                                              case 4:
                                                text = 'Fri';
                                                break;
                                              default:
                                                text = '';
                                                break;
                                            }
                                            return Text(text, style: style);
                                          },
                                        ),
                                        axisNameWidget: Text(
                                          'Day of Week',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 2,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              '${value.toInt()}',
                                              style: TextStyle(
                                                color: Color(0xff68737d),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.right,
                                            );
                                          },
                                          reservedSize: 28,
                                        ),
                                        axisNameWidget: Text(
                                          'kg CO₂',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                                        left: BorderSide(color: Colors.grey.shade300, width: 1),
                                      ),
                                    ),
                                    minX: 0,
                                    maxX: 4,
                                    minY: 8,
                                    maxY: 16,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: [
                                          FlSpot(0, 10),
                                          FlSpot(1, 12),
                                          FlSpot(2, 11),
                                          FlSpot(3, 13),
                                          FlSpot(4, 12),
                                        ],
                                        isCurved: true,
                                        gradient: LinearGradient(
                                          colors: [Colors.blue, Colors.blueAccent],
                                        ),
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 4,
                                              color: Colors.white,
                                              strokeWidth: 2,
                                              strokeColor: Colors.blueAccent,
                                            );
                                          },
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.withOpacity(0.3),
                                              Colors.blue.withOpacity(0.1),
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
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Current: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "12 kg CO₂",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right container
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Weekly Performance",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Performance metrics will be displayed here",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
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
            ],
          ),
        );
      default:
        return Center(
          child: Text(
            "You selected: ${menuTitles[selectedIndex]}",
            style: TextStyle(fontSize: 24),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: isCollapsed ? 70 : 240,
            color: Colors.blueGrey[900],
            child: Column(
              children: [
                const SizedBox(height: 32),
                IconButton(
                  icon: Icon(isCollapsed ? Icons.menu : Icons.close, color: Colors.white),
                  onPressed: () => setState(() => isCollapsed = !isCollapsed),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: menuTitles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      IconData icon;
                      switch (index) {
                        case 0:
                          icon = FontAwesomeIcons.house;
                          break;
                        case 1:
                          icon = FontAwesomeIcons.seedling;
                          break;
                        case 2:
                          icon = FontAwesomeIcons.gear;
                          break;
                        default:
                          icon = FontAwesomeIcons.circle;
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        leading: FaIcon(icon, color: Colors.white, size: 20),
                        title: isCollapsed
                            ? null
                            : Text(menuTitles[index], style: TextStyle(color: Colors.white)),
                        onTap: () => setState(() => selectedIndex = index),
                        selected: selectedIndex == index,
                        selectedTileColor: Colors.blueGrey[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: Colors.red[200]),
                    title: isCollapsed
                        ? null
                        : Text("Logout", style: TextStyle(color: Colors.red[200])),
                    onTap: () {
                      // Handle logout
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    hoverColor: Colors.red[400]?.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(child: _buildPageContent()),
        ],
      ),
    );
  }
}
import 'package:dashboard_web/pages/control_center_page.dart';
import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/weather_card.dart';
import '../widgets/photobioreactor_panel.dart';
import '../widgets/weekly_performance.dart';
import '../pages/photobioreactor_page.dart'; // Import the new page

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
              WeatherCard(),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: PhotobioreactorPanel(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CarbonCaptureChartSection(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 1:
        // This is the Photobioreactors page
        return const PhotobioreactorPage();
      case 2:
        // This is the Control Center Page
        return const ControlCenterPage();
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
          Sidebar(
            isCollapsed: isCollapsed,
            selectedIndex: selectedIndex,
            menuTitles: menuTitles,
            onCollapsedChanged: (value) => setState(() => isCollapsed = value),
            onSelectedIndexChanged: (index) => setState(() => selectedIndex = index),
          ),
          Expanded(child: _buildPageContent()),
        ],
      ),
    );
  }
}
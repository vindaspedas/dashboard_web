import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HealthScorePage extends StatefulWidget {
  const HealthScorePage({Key? key}) : super(key: key);

  @override 
  _HealthScorePageState createState() => _HealthScorePageState();
}

class _HealthScorePageState extends State<HealthScorePage> with TickerProviderStateMixin {
  // Firebase reference
  final DatabaseReference _healthScoreRef = FirebaseDatabase.instance.ref().child('health_score');
  
  // Animation controllers
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _buttonScaleAnimation;
  
  // Data holders
  Map<String, dynamic> _sensorsData = {};
  List<Map<String, dynamic>> _anomaliesData = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  String _lastUpdated = 'Never';

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _cardScaleAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    );
    
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Fetch initial data
    _fetchData();
    
    // Set up periodic data refresh (every 30 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchData();
    });
    
    // Start animations
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Fetch data from Firebase
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch sensors data
      final sensorsSnapshot = await _healthScoreRef.child('sensors').get();
      if (sensorsSnapshot.exists) {
        setState(() {
          _sensorsData = Map<String, dynamic>.from(sensorsSnapshot.value as Map);
        });
      }

      // Fetch anomalies data
      final anomaliesSnapshot = await _healthScoreRef.child('anomalies').get();
      if (anomaliesSnapshot.exists) {
        final anomaliesMap = Map<String, dynamic>.from(anomaliesSnapshot.value as Map);
        final anomaliesList = <Map<String, dynamic>>[];
        
        anomaliesMap.forEach((key, value) {
          final anomaly = Map<String, dynamic>.from(value as Map);
          anomaly['id'] = key;
          anomaliesList.add(anomaly);
        });
        
        // Sort anomalies by timestamp (newest first)
        anomaliesList.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
        
        setState(() {
          _anomaliesData = anomaliesList;
        });
      }

      // Update last refreshed time
      setState(() {
        _isLoading = false;
        _lastUpdated = DateFormat('MMM dd, yyyy - HH:mm:ss').format(DateTime.now());
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get color based on sensor value compared to thresholds
  Color _getSensorColor(String sensorType, dynamic value) {
    switch (sensorType) {
      case 'temperature':
        return value > 40.0 ? Colors.red : (value > 35.0 ? Colors.orange : Colors.green);
      case 'humidity':
        return value > 85.0 ? Colors.red : (value > 75.0 ? Colors.orange : Colors.green);
      case 'pressure':
        return value < 980.0 ? Colors.red : (value < 1000.0 ? Colors.orange : Colors.green);
      case 'vibration':
        return value > 30.0 ? Colors.red : (value > 25.0 ? Colors.orange : Colors.green);
      default:
        return Colors.green;
    }
  }

  // Get icon based on sensor type
  IconData _getSensorIcon(String sensorType) {
    switch (sensorType) {
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'pressure':
        return Icons.speed;
      case 'vibration':
        return Icons.vibration;
      default:
        return Icons.sensors;
    }
  }

  // Format sensor value with appropriate unit
  String _formatSensorValue(String sensorType, dynamic value) {
    switch (sensorType) {
      case 'temperature':
        return '$value°C';
      case 'humidity':
        return '$value%';
      case 'pressure':
        return '$value hPa';
      case 'vibration':
        return '$value Hz';
      default:
        return value.toString();
    }
  }

  // Format timestamp to readable date
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, yyyy - HH:mm:ss').format(date);
  }

  // Build sensor value card
  Widget _buildSensorCard(String sensorType, dynamic value) {
    final color = _getSensorColor(sensorType, value);
    final icon = _getSensorIcon(sensorType);
    final formattedValue = _formatSensorValue(sensorType, value);
    
    return ScaleTransition(
      scale: _cardScaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              sensorType.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedValue,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build animated button
  Widget _buildAnimatedButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) => _buttonAnimationController.forward(),
      onTapUp: (_) => _buttonAnimationController.reverse(),
      onTapCancel: () => _buttonAnimationController.reverse(),
      onTap: onPressed,
      child: ScaleTransition(
        scale: _buttonScaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build health status indicator
  Widget _buildHealthStatusIndicator() {
    // Calculate health score based on number of anomalies
    final int anomalyCount = _anomaliesData.length;
    final double healthScore = anomalyCount > 0 ? (100 - (anomalyCount * 15)).clamp(0, 100).toDouble() : 100.0;
    
    Color statusColor;
    String statusText;
    
    if (healthScore >= 80) {
      statusColor = Colors.green;
      statusText = 'Excellent';
    } else if (healthScore >= 60) {
      statusColor = Colors.orange;
      statusText = 'Good';
    } else if (healthScore >= 40) {
      statusColor = Colors.amber;
      statusText = 'Warning';
    } else {
      statusColor = Colors.red;
      statusText = 'Critical';
    }
    
    return ScaleTransition(
      scale: _cardScaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'SYSTEM HEALTH',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: healthScore / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${healthScore.toInt()}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Detected Anomalies: $anomalyCount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: anomalyCount > 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build anomaly list item
  Widget _buildAnomalyListItem(Map<String, dynamic> anomaly) {
    final sensorType = anomaly['sensorType'] as String;
    final value = anomaly['value'];
    final threshold = anomaly['threshold'];
    final timestamp = anomaly['timestamp'] as int;
    final color = _getSensorColor(sensorType, value);
    final icon = _getSensorIcon(sensorType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sensorType.toUpperCase()} ANOMALY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Value: ${_formatSensorValue(sensorType, value)} (Threshold: ${_formatSensorValue(sensorType, threshold)})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Health Score Dashboard',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last updated: $_lastUpdated',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        _buildAnimatedButton(
                          text: 'Refresh Data',
                          color: Colors.blue,
                          icon: Icons.refresh,
                          onPressed: _fetchData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Health status card
                    _buildHealthStatusIndicator(),
                    const SizedBox(height: 24),
                    
                    // Sensor readings
                    const Text(
                      'Current Sensor Readings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sensorsData.isNotEmpty
                        ? GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildSensorCard('temperature', _sensorsData['temperature']),
                              _buildSensorCard('humidity', _sensorsData['humidity']),
                              _buildSensorCard('pressure', _sensorsData['pressure']),
                              _buildSensorCard('vibration', _sensorsData['vibration']),
                            ],
                          )
                        : const Center(
                            child: Text('No sensor data available'),
                          ),
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedButton(
                          text: 'Generate Report',
                          color: Colors.green,
                          icon: Icons.description,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Generating health report...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildAnimatedButton(
                          text: 'Reset Anomalies',
                          color: Colors.red,
                          icon: Icons.refresh,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('This would reset anomalies in a real system'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Anomalies section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detected Anomalies',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_anomaliesData.length} found',
                          style: TextStyle(
                            fontSize: 14,
                            color: _anomaliesData.isNotEmpty ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _anomaliesData.isNotEmpty
                        ? Column(
                            children: _anomaliesData
                                .map((anomaly) => _buildAnomalyListItem(anomaly))
                                .toList(),
                          )
                        : Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.5)),
                            ),
                            child: const Center(
                              child: Text(
                                'No anomalies detected - System is running optimally',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
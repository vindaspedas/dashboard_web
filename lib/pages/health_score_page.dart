import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_card.dart';
import '../widgets/responsive.dart';

class HealthScorePage extends StatefulWidget {
  const HealthScorePage({Key? key}) : super(key: key);

  @override
  _HealthScorePageState createState() => _HealthScorePageState();
}

class _HealthScorePageState extends State<HealthScorePage> {
  final DatabaseReference _healthScoreRef = FirebaseDatabase.instance.ref().child('health_score');
  final Map<String, double> _thresholds = {
    'temperature': 40.0, // Celsius
    'humidity': 80.0, // Percentage
    'pressure': 1050.0, // hPa
    'vibration': 50.0, // mm/s²
  };
  
  Map<String, dynamic> _sensorData = {};
  List<Map<String, dynamic>> _anomalyHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
    _listenForAnomalies();
  }

  void _fetchSensorData() async {
    try {
      final snapshot = await _healthScoreRef.child('sensors').get();
      if (snapshot.exists) {
        setState(() {
          _sensorData = Map<String, dynamic>.from(snapshot.value as Map);
          _isLoading = false;
        });
      } else {
        // Create placeholder data if none exists
        _createPlaceholderData();
      }
    } catch (e) {
      debugPrint('Error fetching sensor data: $e');
      _createPlaceholderData();
    }
  }

  void _createPlaceholderData() async {
    final Map<String, dynamic> placeholderData = {
      'temperature': 32.5,
      'humidity': 65.2,
      'pressure': 1013.0,
      'vibration': 20.3,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    try {
      await _healthScoreRef.child('sensors').set(placeholderData);
      setState(() {
        _sensorData = placeholderData;
        _isLoading = false;
      });
      debugPrint('Placeholder data created successfully');
    } catch (e) {
      debugPrint('Error creating placeholder data: $e');
    }
  }

  void _listenForAnomalies() {
    _healthScoreRef.child('anomalies').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _anomalyHistory = [];
          data.forEach((key, value) {
            _anomalyHistory.add(Map<String, dynamic>.from(value as Map));
          });
          // Sort by timestamp (newest first)
          _anomalyHistory.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
        });
      }
    });
  }

  bool _isAnomaly(String sensorType, double value) {
    if (!_thresholds.containsKey(sensorType)) return false;
    return value > _thresholds[sensorType]!;
  }

  Future<void> _logAnomaly(String sensorType, double value) async {
    final anomaly = {
      'sensorType': sensorType,
      'value': value,
      'threshold': _thresholds[sensorType],
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    try {
      await _healthScoreRef.child('anomalies').push().set(anomaly);
      debugPrint('Anomaly logged successfully');
    } catch (e) {
      debugPrint('Error logging anomaly: $e');
    }
  }

  Future<void> _updateSensorValue(String sensorType, double value) async {
    try {
      await _healthScoreRef.child('sensors').update({
        sensorType: value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Check for anomaly
      if (_isAnomaly(sensorType, value)) {
        await _logAnomaly(sensorType, value);
      }
      
      setState(() {
        _sensorData[sensorType] = value;
        _sensorData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      });
    } catch (e) {
      debugPrint('Error updating sensor value: $e');
    }
  }

  String _getFormattedDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, yyyy - HH:mm:ss').format(date);
  }

  Color _getHealthStatusColor(double overallScore) {
    if (overallScore >= 90) return Colors.green;
    if (overallScore >= 70) return Colors.amber;
    return Colors.red;
  }

  IconData _getSensorIcon(String sensorType) {
    switch (sensorType) {
      case 'temperature': return FontAwesomeIcons.temperatureHigh;
      case 'humidity': return FontAwesomeIcons.droplet;
      case 'pressure': return FontAwesomeIcons.gauge;
      case 'vibration': return FontAwesomeIcons.vial;
      default: return FontAwesomeIcons.solidCircle;
    }
  }

  String _getSensorUnit(String sensorType) {
    switch (sensorType) {
      case 'temperature': return '°C';
      case 'humidity': return '%';
      case 'pressure': return 'hPa';
      case 'vibration': return 'mm/s²';
      default: return '';
    }
  }

  double _calculateOverallHealth() {
    if (_sensorData.isEmpty) return 0;
    
    double score = 100;
    _thresholds.forEach((sensor, threshold) {
      if (_sensorData.containsKey(sensor)) {
        final value = _sensorData[sensor] as double;
        if (_isAnomaly(sensor, value)) {
          // Reduce score based on how much it exceeds the threshold
          final percentExceeded = ((value - threshold) / threshold) * 100;
          score -= percentExceeded.clamp(5, 25); // Deduct between 5-25 points
        }
      }
    });
    
    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final overallHealthScore = _calculateOverallHealth();
    final healthColor = _getHealthStatusColor(overallHealthScore);
    
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Score',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getFormattedDate(DateTime.now().millisecondsSinceEpoch),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Overall health score card
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overall System Health',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(
                            overallHealthScore > 70 
                              ? FontAwesomeIcons.checkCircle 
                              : FontAwesomeIcons.exclamationTriangle,
                            color: healthColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: overallHealthScore / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${overallHealthScore.toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: healthColor,
                                  ),
                                ),
                                Text(
                                  overallHealthScore > 90 ? 'Excellent' : 
                                    overallHealthScore > 70 ? 'Good' : 'Critical',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Sensor readings grid
                Responsive(
                  mobile: _sensorGridView(crossAxisCount: 1),
                  tablet: _sensorGridView(crossAxisCount: 2),
                  desktop: _sensorGridView(crossAxisCount: 4),
                ),
                
                const SizedBox(height: 20),
                
                // Anomaly detection history
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Anomaly Detection History',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(
                            FontAwesomeIcons.history,
                            color: Colors.blue[700],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _anomalyHistory.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text('No anomalies detected'),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _anomalyHistory.length > 5 ? 5 : _anomalyHistory.length,
                              itemBuilder: (context, index) {
                                final anomaly = _anomalyHistory[index];
                                return ListTile(
                                  leading: Icon(
                                    _getSensorIcon(anomaly['sensorType']),
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    '${anomaly['sensorType'].toString().toUpperCase()} Anomaly Detected',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Value: ${anomaly['value']} ${_getSensorUnit(anomaly['sensorType'])} '
                                    '(Threshold: ${anomaly['threshold']} ${_getSensorUnit(anomaly['sensorType'])})\n'
                                    '${_getFormattedDate(anomaly['timestamp'])}',
                                  ),
                                  isThreeLine: true,
                                );
                              },
                            ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Test controls for simulation
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Simulation Controls',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(
                            FontAwesomeIcons.sliders,
                            color: Colors.purple[700],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: _thresholds.keys.map((sensorType) {
                          return ElevatedButton.icon(
                            icon: Icon(_getSensorIcon(sensorType)),
                            label: Text('Trigger $sensorType anomaly'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              final threshold = _thresholds[sensorType]!;
                              final anomalyValue = threshold + (threshold * 0.2); // 20% above threshold
                              _updateSensorValue(sensorType, anomalyValue);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(FontAwesomeIcons.rotate),
                        label: const Text('Reset all sensors to normal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _thresholds.keys.forEach((sensorType) {
                            final normalValue = _thresholds[sensorType]! * 0.7; // 70% of threshold
                            _updateSensorValue(sensorType, normalValue);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _sensorGridView({required int crossAxisCount}) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: _thresholds.keys.map((sensorType) {
        final value = _sensorData[sensorType] as double? ?? 0.0;
        final isAnomaly = _isAnomaly(sensorType, value);
        
        return CustomCard(
          color: isAnomaly ? Colors.red.withOpacity(0.1) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sensorType.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Icon(
                    _getSensorIcon(sensorType),
                    color: isAnomaly ? Colors.red : Colors.blue[700],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isAnomaly ? Colors.red : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getSensorUnit(sensorType),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: value / (_thresholds[sensorType]! * 1.5),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isAnomaly ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Threshold: ${_thresholds[sensorType]!} ${_getSensorUnit(sensorType)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
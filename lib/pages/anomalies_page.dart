import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AnomaliesPage extends StatefulWidget {
  const AnomaliesPage({super.key});

  @override
  State<AnomaliesPage> createState() => _AnomaliesPageState();
}

class _AnomaliesPageState extends State<AnomaliesPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> anomalies = [];
  bool isLoading = true;
  String selectedPbr = 'All';
  String selectedSensor = 'All';

  @override
  void initState() {
    super.initState();
    _fetchAnomalies();
  }

  Future<void> _fetchAnomalies() async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<String> pbrs = ['PBR1', 'PBR2', 'PBR3', 'PBR4'];
      List<Map<String, dynamic>> allAnomalies = [];

      for (String pbr in pbrs) {
        final snapshot = await _databaseRef.child('photobioreactors/$pbr/anomalies').get();
        if (snapshot.exists) {
          final anomaliesData = snapshot.value as Map<dynamic, dynamic>;
          
          anomaliesData.forEach((key, value) {
            if (value is Map) {
              final anomalyData = Map<String, dynamic>.from(value as Map);
              allAnomalies.add({
                'id': key,
                'pbr': pbr,
                'sensorType': anomalyData['sensorType'],
                'threshold': anomalyData['threshold'],
                'value': anomalyData['value'],
                'timestamp': anomalyData['timestamp'],
              });
            }
          });
        }
      }
      
      // Sort by timestamp (newest first)
      allAnomalies.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

      setState(() {
        anomalies = allAnomalies;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching anomalies: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredAnomalies() {
    return anomalies.where((anomaly) {
      bool pbrMatch = selectedPbr == 'All' || anomaly['pbr'] == selectedPbr;
      bool sensorMatch = selectedSensor == 'All' || anomaly['sensorType'] == selectedSensor;
      return pbrMatch && sensorMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAnomalies = getFilteredAnomalies();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anomalies & Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnomalies,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filter Anomalies',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Photobioreactor',
                                          border: OutlineInputBorder(),
                                        ),
                                        value: selectedPbr,
                                        items: ['All', 'PBR1', 'PBR2', 'PBR3', 'PBR4']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedPbr = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Sensor Type',
                                          border: OutlineInputBorder(),
                                        ),
                                        value: selectedSensor,
                                        items: [
                                          'All',
                                          'temperature',
                                          'humidity',
                                          'pressure',
                                          'vibration',
                                          'lightIntensity',
                                          'co2Level'
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value == 'All'
                                                ? 'All'
                                                : value == 'lightIntensity'
                                                    ? 'Light Intensity'
                                                    : value == 'co2Level'
                                                        ? 'CO₂ Level'
                                                        : value.substring(0, 1).toUpperCase() +
                                                            value.substring(1)),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedSensor = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${filteredAnomalies.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Anomalies'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredAnomalies.isEmpty
                      ? const Center(
                          child: Text(
                            'No anomalies found.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredAnomalies.length,
                          itemBuilder: (context, index) {
                            final anomaly = filteredAnomalies[index];
                            final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
                                anomaly['timestamp'] as int);
                            final String formattedDate =
                                DateFormat('MMM dd, yyyy - HH:mm:ss').format(timestamp);
                            
                            String sensorName = anomaly['sensorType'] == 'lightIntensity'
                                ? 'Light Intensity'
                                : anomaly['sensorType'] == 'co2Level'
                                    ? 'CO₂ Level'
                                    : anomaly['sensorType'].toString().substring(0, 1).toUpperCase() +
                                        anomaly['sensorType'].toString().substring(1);
                            
                            String unit = '';
                            switch (anomaly['sensorType']) {
                              case 'temperature':
                                unit = '°C';
                                break;
                              case 'humidity':
                                unit = '%';
                                break;
                              case 'pressure':
                                unit = 'hPa';
                                break;
                              case 'vibration':
                                unit = 'units';
                                break;
                              case 'lightIntensity':
                                unit = 'lux';
                                break;
                              case 'co2Level':
                                unit = 'ppm';
                                break;
                            }

                            // Determine severity
                            bool isCritical = false;
                            switch (anomaly['sensorType']) {
                              case 'temperature':
                                isCritical = (anomaly['value'] as num) >= 40;
                                break;
                              case 'humidity':
                                isCritical = (anomaly['value'] as num) >= 85;
                                break;
                              case 'pressure':
                                isCritical = (anomaly['value'] as num) <= 930;
                                break;
                              case 'vibration':
                                isCritical = (anomaly['value'] as num) >= 35;
                                break;
                              case 'lightIntensity':
                                isCritical = (anomaly['value'] as num) <= 500;
                                break;
                              case 'co2Level':
                                isCritical = (anomaly['value'] as num) >= 550;
                                break;
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: isCritical 
                                  ? Colors.red.shade50 
                                  : Colors.orange.shade50,
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCritical ? Colors.red : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getSensorIcon(anomaly['sensorType']),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      '${anomaly['pbr']} - $sensorName Anomaly',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isCritical ? Colors.red : Colors.orange,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        isCritical ? 'Critical' : 'Warning',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Value: ${anomaly['value']} $unit (Threshold: ${anomaly['threshold']} $unit)'),
                                    Text('Time: $formattedDate'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    _deleteAnomaly(anomaly['pbr'], anomaly['id']);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

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
      case 'lightIntensity':
        return Icons.light_mode;
      case 'co2Level':
        return Icons.air;
      default:
        return Icons.sensors;
    }
  }

  Future<void> _deleteAnomaly(String pbr, String anomalyId) async {
    try {
      await _databaseRef.child('photobioreactors/$pbr/anomalies/$anomalyId').remove();
      _fetchAnomalies();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anomaly deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting anomaly: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
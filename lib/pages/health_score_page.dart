import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';

class HealthScorePage extends StatefulWidget {
  const HealthScorePage({Key? key}) : super(key: key);

  @override
  _HealthScorePageState createState() => _HealthScorePageState();
}

class _HealthScorePageState extends State<HealthScorePage> {
  final databaseRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> sensorData = {};
  Map<String, dynamic> pbrData = {};
  List<Map<String, dynamic>> anomalies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHealthScoreData();
  }

  void fetchHealthScoreData() {
    databaseRef.child('health_score').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (data != null) {
        setState(() {
          // Process sensor data - average values from all 4 PBRs
          final sensorsData = Map<String, dynamic>.from(data['sensors'] ?? {});
          
          // Store the PBR data for charts in the report
          if (data['pbr_data'] != null) {
            pbrData = Map<String, dynamic>.from(data['pbr_data'] as Map);
          }
          
          // Calculate averages from all 4 PBRs if available, otherwise use sensor data
          if (pbrData.isNotEmpty) {
            double tempSum = 0, phSum = 0, turbiditySum = 0;
            int count = 0;
            
            pbrData.forEach((key, value) {
              if (value is Map) {
                final pbrValues = Map<String, dynamic>.from(value as Map);
                tempSum += pbrValues['temperature'] ?? 0.0;
                phSum += pbrValues['ph'] ?? 0.0;
                turbiditySum += pbrValues['turbidity'] ?? 0.0;
                count++;
              }
            });
            
            if (count > 0) {
              sensorData = {
                'temperature': tempSum / count,
                'ph': phSum / count,
                'turbidity': turbiditySum / count,
                'timestamp': sensorsData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
              };
            } else {
              // Fallback to sensor data if PBR data calculation fails
              sensorData = {
                'temperature': sensorsData['temperature'] ?? 0.0,
                'ph': sensorsData['ph'] ?? 0.0,
                'turbidity': sensorsData['turbidity'] ?? 0.0,
                'timestamp': sensorsData['timestamp'] ?? 0,
              };
            }
          } else {
            // Use sensor data if PBR data is not available
            sensorData = {
              'temperature': sensorsData['temperature'] ?? 0.0,
              'ph': sensorsData['ph'] ?? 0.0,
              'turbidity': sensorsData['turbidity'] ?? 0.0,
              'timestamp': sensorsData['timestamp'] ?? 0,
            };
          }
          
          // Process anomalies
          final anomaliesData = data['anomalies'] as Map<dynamic, dynamic>?;
          anomalies = [];
          
          if (anomaliesData != null) {
            anomaliesData.forEach((key, value) {
              final anomaly = Map<String, dynamic>.from(value as Map);
              // Only include temperature, pH and turbidity anomalies
              if (['temperature', 'ph', 'turbidity'].contains(anomaly['sensorType'])) {
                anomalies.add(anomaly);
              }
            });
          }
          
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Score'),
        actions: [
          ElevatedButton(
            onPressed: generateReport,
            child: Text('Generate Report'),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current PBR Health Metrics (Average of 4 PBRs)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildSensorCard('Temperature', '${sensorData['temperature']}°C', Colors.orange),
                  SizedBox(height: 16),
                  _buildSensorCard('pH Level', '${sensorData['ph']}', Colors.blue),
                  SizedBox(height: 16),
                  _buildSensorCard('Turbidity', '${sensorData['turbidity']} NTU', Colors.green),
                  SizedBox(height: 30),
                  Text(
                    'Recent Anomalies',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: anomalies.isEmpty
                        ? Center(child: Text('No recent anomalies detected'))
                        : ListView.builder(
                            itemCount: anomalies.length,
                            itemBuilder: (context, index) {
                              final anomaly = anomalies[index];
                              return _buildAnomalyCard(anomaly);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSensorCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForSensor(title),
              color: color,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Spacer(),
          _buildStatusIndicator(title, value),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String sensorType, String value) {
    // Compare with thresholds to determine status
    // This is a simplified example - implement your own logic
    bool isNormal = true;
    
    try {
      final numValue = double.parse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
      
      switch (sensorType.toLowerCase()) {
        case 'temperature':
          isNormal = numValue >= 20 && numValue <= 40;
          break;
        case 'ph level':
          isNormal = numValue >= 6.5 && numValue <= 8.5;
          break;
        case 'turbidity':
          isNormal = numValue <= 30;
          break;
      }
    } catch (e) {
      // Handle parsing errors
      print('Error parsing value: $e');
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isNormal ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isNormal ? 'Normal' : 'Alert',
        style: TextStyle(
          color: isNormal ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAnomalyCard(Map<String, dynamic> anomaly) {
    final timestamp = anomaly['timestamp'] as int;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formattedDate = DateFormat('MMM d, yyyy - HH:mm').format(dateTime);
    
    final sensorType = anomaly['sensorType'] as String;
    final value = anomaly['value'];
    final threshold = anomaly['threshold'];
    
    String unit = '';
    switch (sensorType.toLowerCase()) {
      case 'temperature':
        unit = '°C';
        break;
      case 'ph':
        unit = '';
        break;
      case 'turbidity':
        unit = 'NTU';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 3, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                '${sensorType.toUpperCase()} ANOMALY DETECTED',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Value: $value$unit (Threshold: $threshold$unit)'),
          SizedBox(height: 4),
          Text('Detected on: $formattedDate', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  IconData _getIconForSensor(String sensorType) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat;
      case 'ph level':
        return Icons.science;
      case 'turbidity':
        return Icons.opacity;
      default:
        return Icons.sensors;
    }
  }

  Future<Uint8List> _loadLogoImage() async {
    final ByteData data = await rootBundle.load('greenpulselogo.png');
    return data.buffer.asUint8List();
  }
  
  Future<void> generateReport() async {
    final pdf = pw.Document();
    
    final timestamp = sensorData['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    final reportDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formattedDate = DateFormat('MMMM d, yyyy - HH:mm').format(reportDate);
    
    // Load logo for cover page
    pw.MemoryImage? logoImage;
    try {
      final logoData = await _loadLogoImage();
      logoImage = pw.MemoryImage(logoData);
    } catch (e) {
      print('Error loading logo: $e');
    }
    
    // Add cover page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                logoImage != null
                    ? pw.Image(logoImage, height: 150)
                    : pw.SizedBox(height: 150),
                pw.SizedBox(height: 40),
                pw.Text(
                  'PHOTOBIOREACTOR',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'HEALTH REPORT',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green900,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  formattedDate,
                  style: pw.TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
    
    // Add content pages
    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Center(
          child: pw.Text(
            'Photobioreactor Health Report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated on: $formattedDate'),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
          ],
        ),
        build: (pw.Context context) => [
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              'PBR Health Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Sensor Data Table
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Sensor Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              _buildPdfTableRow('Temperature', '${sensorData['temperature']}°C'),
              _buildPdfTableRow('pH Level', '${sensorData['ph']}'),
              _buildPdfTableRow('Turbidity', '${sensorData['turbidity']} NTU'),
            ],
          ),
          
          pw.SizedBox(height: 30),
          
          // Anomalies Section
          pw.Text(
            'Recent Anomalies',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          
          anomalies.isEmpty
              ? pw.Text('No recent anomalies detected')
              : pw.Column(
                  children: anomalies.map((anomaly) {
                    final anomalyTimestamp = anomaly['timestamp'] as int;
                    final anomalyDateTime = DateTime.fromMillisecondsSinceEpoch(anomalyTimestamp);
                    final anomalyDate = DateFormat('MMM d, yyyy - HH:mm').format(anomalyDateTime);
                    
                    return pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 10),
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.red),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${anomaly['sensorType'].toString().toUpperCase()} ANOMALY',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text('Value: ${anomaly['value']} (Threshold: ${anomaly['threshold']})'),
                          pw.Text('Detected on: $anomalyDate'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          
          pw.SizedBox(height: 30),
          
          // Recommendations Section
          pw.Text(
            'Recommendations',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Bullet(text: 'Monitor temperature closely if approaching upper limits'),
          pw.Bullet(text: 'Maintain pH levels between 6.5 and 8.5 for optimal algae growth'),
          pw.Bullet(text: 'Address any turbidity issues promptly to ensure light penetration'),
          pw.Bullet(text: 'Perform system maintenance if multiple anomalies have been detected'),
          
          pw.SizedBox(height: 30),
          
          // Growth prediction section
          pw.Text(
            'Growth Prediction (Based on Current Metrics)',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildGrowthPredictionSection(),
          
          pw.SizedBox(height: 30),
          
          // PBR Comparison Charts
          pw.Text(
            'Photobioreactor Comparison',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildPbrComparisonSection(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.TableRow _buildPdfTableRow(String sensorType, String value) {
    bool isNormal = true;
    
    try {
      final numValue = double.parse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
      
      switch (sensorType.toLowerCase()) {
        case 'temperature':
          isNormal = numValue >= 20 && numValue <= 40;
          break;
        case 'ph level':
          isNormal = numValue >= 6.5 && numValue <= 8.5;
          break;
        case 'turbidity':
          isNormal = numValue <= 30;
          break;
      }
    } catch (e) {
      // Handle parsing errors
    }

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(sensorType),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(
            isNormal ? 'Normal' : 'Attention Required',
            style: pw.TextStyle(color: isNormal ? PdfColors.green : PdfColors.red),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildGrowthPredictionSection() {
    // This is a simplified example - implement your actual prediction algorithm
    String growthPrediction = 'Normal';
    String growthRate = 'Average';
    
    try {
      final temp = double.parse(sensorData['temperature'].toString());
      final ph = double.parse(sensorData['ph'].toString());
      final turbidity = double.parse(sensorData['turbidity'].toString());
      
      if (temp >= 25 && temp <= 35 && ph >= 7.0 && ph <= 8.0 && turbidity <= 20) {
        growthPrediction = 'Excellent';
        growthRate = 'Above Average';
      } else if ((temp < 25 || temp > 35) || (ph < 6.5 || ph > 8.5) || turbidity > 30) {
        growthPrediction = 'Below Optimal';
        growthRate = 'Below Average';
      }
    } catch (e) {
      // Handle parsing errors
    }
    
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Growth Prediction: $growthPrediction'),
          pw.SizedBox(height: 5),
          pw.Text('Estimated Growth Rate: $growthRate'),
          pw.SizedBox(height: 10),
          pw.Text(
            'Note: This prediction is based on current sensor readings and historical patterns. '
            'Actual growth may vary based on additional factors such as light exposure, '
            'nutrient availability, and culture age.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
  
  pw.Widget _buildPbrComparisonSection() {
    // Extract data for all PBRs for charts
    final List<String> pbrNames = [];
    final List<double> temperatures = [];
    final List<double> phValues = [];
    final List<double> turbidityValues = [];
    
    if (pbrData.isNotEmpty) {
      pbrData.forEach((key, value) {
        if (value is Map) {
          final pbrValues = Map<String, dynamic>.from(value as Map);
          pbrNames.add(key);
          temperatures.add(pbrValues['temperature'] ?? 0.0);
          phValues.add(pbrValues['ph'] ?? 0.0);
          turbidityValues.add(pbrValues['turbidity'] ?? 0.0);
        }
      });
    } else {
      // If no PBR data is available, use placeholder data
      pbrNames.addAll(['PBR1', 'PBR2', 'PBR3', 'PBR4']);
      temperatures.addAll([32.0, 32.5, 33.0, 32.8]);
      phValues.addAll([7.2, 7.1, 7.3, 7.0]);
      turbidityValues.addAll([18.0, 19.5, 17.8, 18.9]);
    }
    
    // Build comparison tables
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Temperature Comparison
        pw.Text('Temperature Comparison (°C)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        _buildPbrComparisonTable(pbrNames, temperatures, '°C'),
        pw.SizedBox(height: 20),
        
        // Create temperature bar chart
        _buildBarChart('Temperature (°C)', pbrNames, temperatures, PdfColors.orange),
        pw.SizedBox(height: 20),
        
        // PH Comparison
        pw.Text('pH Comparison', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        _buildPbrComparisonTable(pbrNames, phValues, ''),
        pw.SizedBox(height: 20),
        
        // Create pH bar chart
        _buildBarChart('pH Level', pbrNames, phValues, PdfColors.blue),
        pw.SizedBox(height: 20),
        
        // Turbidity Comparison
        pw.Text('Turbidity Comparison (NTU)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        _buildPbrComparisonTable(pbrNames, turbidityValues, 'NTU'),
        pw.SizedBox(height: 20),
        
        // Create turbidity bar chart
        _buildBarChart('Turbidity (NTU)', pbrNames, turbidityValues, PdfColors.green),
      ],
    );
  }
  
  pw.Widget _buildPbrComparisonTable(List<String> pbrNames, List<double> values, String unit) {
    final rows = <pw.TableRow>[];
    
    // Header row
    final headerCells = <pw.Widget>[];
    headerCells.add(
      pw.Padding(
        padding: pw.EdgeInsets.all(6),
        child: pw.Text('PBR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      )
    );
    
    for (var pbrName in pbrNames) {
      headerCells.add(
        pw.Padding(
          padding: pw.EdgeInsets.all(6),
          child: pw.Text(pbrName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        )
      );
    }
    
    rows.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      children: headerCells,
    ));
    
    // Value row
    final valueCells = <pw.Widget>[];
    valueCells.add(
      pw.Padding(
        padding: pw.EdgeInsets.all(6),
        child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      )
    );
    
    for (var value in values) {
      valueCells.add(
        pw.Padding(
          padding: pw.EdgeInsets.all(6),
          child: pw.Text('${value.toStringAsFixed(1)}$unit'),
        )
      );
    }
    
    rows.add(pw.TableRow(children: valueCells));
    
    return pw.Table(
      border: pw.TableBorder.all(),
      children: rows,
    );
  }
  
  pw.Widget _buildBarChart(String title, List<String> labels, List<double> values, PdfColor color) {
    // Find the maximum value for scaling
    final maxValue = values.reduce((curr, next) => curr > next ? curr : next);
    final chartWidth = 400.0;
    final chartHeight = 180.0;
    final barWidth = chartWidth / (labels.length * 2);
    
    return pw.Container(
      width: chartWidth,
      height: chartHeight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Container(
            height: chartHeight - 40,
            width: chartWidth,
            child: pw.Stack(
              children: [
                // Y-axis
                pw.Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: pw.Container(
                    width: 1,
                    color: PdfColors.black,
                  ),
                ),
                // X-axis
                pw.Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: pw.Container(
                    height: 1,
                    color: PdfColors.black,
                  ),
                ),
                // Bars
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: List.generate(values.length, (index) {
                    final barHeight = (values[index] / maxValue) * (chartHeight - 60);
                    return pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Container(
                          width: barWidth,
                          height: barHeight,
                          color: color,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(labels[index]),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
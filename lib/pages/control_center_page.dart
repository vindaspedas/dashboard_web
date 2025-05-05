import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ControlCenterPage extends StatefulWidget {
  const ControlCenterPage({Key? key}) : super(key: key);

  @override
  _ControlCenterPageState createState() => _ControlCenterPageState();
}

class _ControlCenterPageState extends State<ControlCenterPage> {
  String selectedReactor = 'Photobioreactor 1';
  final List<String> reactors = [
    'Photobioreactor 1',
    'Photobioreactor 2',
    'Photobioreactor 3',
    'Photobioreactor 4',
  ];

  // Store system logs with timestamp, action and status
  final List<LogEntry> eventLogs = [];

  // Track button states
  bool phPumpActive = false;
  bool coolingFanActive = false;
  bool harvestModeActive = false;

  void _toggleSystem(String system) {
    final now = DateTime.now();
    setState(() {
      switch (system) {
        case 'ph':
          phPumpActive = !phPumpActive;
          eventLogs.insert(
            0,
            LogEntry(
              timestamp: now,
              action: 'PH Control',
              description: '${phPumpActive ? 'Activated' : 'Deactivated'} PH balancing pump on $selectedReactor',
              status: phPumpActive ? LogStatus.active : LogStatus.inactive,
            ),
          );
          break;
        case 'temperature':
          coolingFanActive = !coolingFanActive;
          eventLogs.insert(
            0,
            LogEntry(
              timestamp: now,
              action: 'Temperature Control',
              description: '${coolingFanActive ? 'Activated' : 'Deactivated'} cooling fan on $selectedReactor',
              status: coolingFanActive ? LogStatus.active : LogStatus.inactive,
            ),
          );
          break;
        case 'turbidity':
          harvestModeActive = !harvestModeActive;
          eventLogs.insert(
            0,
            LogEntry(
              timestamp: now,
              action: 'Turbidity Control',
              description: '${harvestModeActive ? 'Activated' : 'Deactivated'} harvest mode on $selectedReactor',
              status: harvestModeActive ? LogStatus.active : LogStatus.inactive,
            ),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Control Center',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // Section 1: Reactor Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C20),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Reactor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262930),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3A3D45)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedReactor,
                        dropdownColor: const Color(0xFF262930),
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                        isExpanded: true,
                        items: reactors.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedReactor = newValue;
                              // Reset states when changing reactors
                              phPumpActive = false;
                              coolingFanActive = false;
                              harvestModeActive = false;
                              
                              // Log the reactor change
                              eventLogs.insert(
                                0,
                                LogEntry(
                                  timestamp: DateTime.now(),
                                  action: 'System Change',
                                  description: 'Switched controls to $newValue',
                                  status: LogStatus.info,
                                ),
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section 2: Control Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C20),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$selectedReactor Controls',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // PH Control Button
                      SizedBox(
                        width: 180,
                        child: _buildControlButton(
                          title: 'PH Control',
                          icon: Icons.opacity,
                          label: 'Activate Pump',
                          isActive: phPumpActive,
                          color: Colors.blue,
                          onPressed: () => _toggleSystem('ph'),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Temperature Control Button
                      SizedBox(
                        width: 180,
                        child: _buildControlButton(
                          title: 'Temperature Control',
                          icon: Icons.ac_unit,
                          label: 'Activate Cooling Fan',
                          isActive: coolingFanActive,
                          color: Colors.red,
                          onPressed: () => _toggleSystem('temperature'),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Turbidity Control Button
                      SizedBox(
                        width: 180,
                        child: _buildControlButton(
                          title: 'Turbidity Control',
                          icon: Icons.blur_on,
                          label: 'Activate Harvest Mode',
                          isActive: harvestModeActive,
                          color: Colors.green,
                          onPressed: () => _toggleSystem('turbidity'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section 3: Event Log
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C20),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Event Log',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white54),
                          onPressed: () {
                            setState(() {
                              eventLogs.insert(
                                0,
                                LogEntry(
                                  timestamp: DateTime.now(),
                                  action: 'System',
                                  description: 'Event log refreshed',
                                  status: LogStatus.info,
                                ),
                              );
                            });
                          },
                          tooltip: 'Refresh log',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: eventLogs.isEmpty
                          ? const Center(
                              child: Text(
                                'No events logged yet. Use the controls above to get started.',
                                style: TextStyle(color: Colors.white38),
                              ),
                            )
                          : ListView.builder(
                              itemCount: eventLogs.length,
                              itemBuilder: (context, index) {
                                final log = eventLogs[index];
                                return _buildLogEntry(log);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String title,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          height: 120, // Fixed height
          width: double.infinity, // Fill available width
          decoration: BoxDecoration(
            color: const Color(0xFF262930),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? color : const Color(0xFF3A3D45),
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? color.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onPressed,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isActive ? color : Colors.white54,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? color : Colors.white,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildLogEntry(LogEntry log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF262930),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: log.status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Timestamp
          Text(
            DateFormat('HH:mm:ss').format(log.timestamp),
            style: const TextStyle(
              color: Colors.white38,
              fontFamily: 'Monospace',
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          // Action type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: log.status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              log.action,
              style: TextStyle(
                color: log.status.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Description
          Expanded(
            child: Text(
              log.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Log entry model
class LogEntry {
  final DateTime timestamp;
  final String action;
  final String description;
  final LogStatus status;

  LogEntry({
    required this.timestamp,
    required this.action,
    required this.description,
    required this.status,
  });
}

// Log status enum with color
enum LogStatus {
  active(Colors.green),
  inactive(Colors.red),
  warning(Colors.orange),
  info(Colors.blue);

  final Color color;
  const LogStatus(this.color);
}
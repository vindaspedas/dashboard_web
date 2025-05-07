import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../constants/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({Key? key}) : super(key: key);

  @override
  _SchedulerPageState createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Store the planned batches of microalgae
  final Map<DateTime, List<MicroalgaeBatch>> _batches = {};
  
  // Sample notification date - in a real app, you would calculate this based on your batches
  final DateTime _nextBatchDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    
    // Add some sample data
    _batches[DateTime.now().subtract(const Duration(days: 5))] = [
      MicroalgaeBatch(id: '1', name: 'Spirulina Batch', description: 'First test batch', createdAt: DateTime.now().subtract(const Duration(days: 5)))
    ];
    _batches[DateTime.now()] = [
      MicroalgaeBatch(id: '2', name: 'Chlorella Batch', description: 'Standard production batch', createdAt: DateTime.now())
    ];
  }

  List<MicroalgaeBatch> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _batches[normalizedDay] ?? [];
  }

  void _addNewBatch() {
    if (_selectedDay == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Microalgae Batch'),
        content: AddBatchForm(
          onSave: (batch) {
            setState(() {
              final normalizedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
              if (_batches[normalizedDay] == null) {
                _batches[normalizedDay] = [];
              }
              _batches[normalizedDay]!.add(batch);
            });
            Navigator.of(context).pop();
          },
          selectedDate: _selectedDay!,
        ),
      ),
    );
  }

  void _editBatch(MicroalgaeBatch batch, DateTime day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Microalgae Batch'),
        content: AddBatchForm(
          onSave: (newBatch) {
            setState(() {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final index = _batches[normalizedDay]!.indexWhere((b) => b.id == batch.id);
              if (index != -1) {
                _batches[normalizedDay]![index] = newBatch;
              }
            });
            Navigator.of(context).pop();
          },
          initialBatch: batch,
          selectedDate: day,
        ),
      ),
    );
  }

  void _deleteBatch(MicroalgaeBatch batch, DateTime day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text('Are you sure you want to delete "${batch.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                _batches[normalizedDay]!.removeWhere((b) => b.id == batch.id);
                if (_batches[normalizedDay]!.isEmpty) {
                  _batches.remove(normalizedDay);
                }
              });
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microalgae Dashboard'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Microalgae Scheduler",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Add New Batch"),
                  onPressed: _addNewBatch,
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    formatButtonDecoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            if (_selectedDay != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Batches for ${DateFormat('MMMM d, yyyy').format(_selectedDay!)}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: defaultPadding),
                      ..._buildBatchList(),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: defaultPadding),
            _buildNextBatchNotification(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBatchList() {
    final batches = _getEventsForDay(_selectedDay!);
    
    if (batches.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text("No batches scheduled for this day"),
          ),
        )
      ];
    }

    return batches.map((batch) {
      return Padding(
        padding: const EdgeInsets.only(bottom: defaultPadding / 2),
        child: Container(
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: primaryColor,
                child: Icon(Icons.science, color: Colors.white),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(batch.description),
                    const SizedBox(height: 4),
                    Text(
                      "Created: ${DateFormat('MMM d, yyyy').format(batch.createdAt)}",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: primaryColor),
                onPressed: () => _editBatch(batch, _selectedDay!),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteBatch(batch, _selectedDay!),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNextBatchNotification() {
    final daysLeft = _nextBatchDate.difference(DateTime.now()).inDays;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Next Batch Reminder",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "New batch of microalgae scheduled in $daysLeft days",
                    style: const TextStyle(
                      fontSize: 14,
                      color:Color.fromARGB(255, 255, 255, 255),
                      ),
                  ),
                  Text(
                    "Scheduled date: ${DateFormat('MMMM d, yyyy').format(_nextBatchDate)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MicroalgaeBatch {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  MicroalgaeBatch({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });
}

class AddBatchForm extends StatefulWidget {
  final Function(MicroalgaeBatch) onSave;
  final MicroalgaeBatch? initialBatch;
  final DateTime selectedDate;

  const AddBatchForm({
    Key? key,
    required this.onSave,
    this.initialBatch,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _AddBatchFormState createState() => _AddBatchFormState();
}

class _AddBatchFormState extends State<AddBatchForm> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialBatch?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initialBatch?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Batch Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: defaultPadding),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () {
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a batch name')),
                    );
                    return;
                  }
                  
                  final batch = MicroalgaeBatch(
                    id: widget.initialBatch?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    description: _descriptionController.text,
                    createdAt: widget.initialBatch?.createdAt ?? widget.selectedDate,
                  );
                  
                  widget.onSave(batch);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
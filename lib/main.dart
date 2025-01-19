import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab4_214005',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EventCalendarScreen(),
    );
  }
}

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  Map<String, List> mySelectedEvents = {};
  final titleController = TextEditingController();
  final descpController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    loadPreviousEvents();
  }

  loadPreviousEvents() {
    mySelectedEvents = {
      "2025-02-10": [
        {
          "eventTitle": "Example Subject",
          "eventDescp": "Example.",
          "eventTime": "10:30 AM"
        }
      ]
    };
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Exam', textAlign: TextAlign.center),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: descpController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Session'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Time: '),
                Expanded(
                  child: Text(
                    _selectedTime != null ? _selectedTime!.format(context) : '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => _pickTime(context),
                  child: const Text('Select Time'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Add Exam'),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descpController.text.isNotEmpty &&
                  _selectedTime != null) {
                setState(() {
                  mySelectedEvents[DateFormat('yyyy-MM-dd')
                      .format(_selectedDate!)] = (mySelectedEvents[
                          DateFormat('yyyy-MM-dd').format(_selectedDate!)] ??
                      [])
                    ..add({
                      "eventTitle": titleController.text,
                      "eventDescp": descpController.text,
                      "eventTime": _selectedTime!.format(context),
                    });
                });
                titleController.clear();
                descpController.clear();
                _selectedTime = null;
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All fields are required'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  void _navigateToDetailsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Lab4_214005'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2025),
            lastDay: DateTime(2026),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDate, selectedDay)) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _listOfDayEvents,
          ),
          ..._listOfDayEvents(_selectedDate!).map(
            (myEvents) => ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.teal),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Text('Subject: ${myEvents['eventTitle']}'),
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                        'Session: ${myEvents['eventDescp']}\nTime: ${myEvents['eventTime']}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map_rounded, color: Colors.blue),
                    onPressed: () => _navigateToDetailsScreen(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        label: const Text('Add Exam'),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(42.00423277215921, 21.409547896676074),
          zoom: 15.0,
        ),
        markers: {
          const Marker(
            markerId:
                const MarkerId("Faculty of Computer Science & Engineering"),
            position: LatLng(42.00423277215921, 21.409547896676074),
            infoWindow: InfoWindow(
              title: "Faculty of Computer Science & Engineering",
              snippet: "This is your place for taking the exam",
            ), // InfoWindow
          ), // Marker
        }, // markers
      ), // GoogleMap
    );
  }
}

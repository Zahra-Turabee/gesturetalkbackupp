import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmModel {
  final TimeOfDay time;
  final String label;
  final int id;

  AlarmModel(this.time, this.label, this.id);

  Map<String, dynamic> toJson() => {
    'hour': time.hour,
    'minute': time.minute,
    'label': label,
    'id': id,
  };

  static AlarmModel fromJson(Map<String, dynamic> json) => AlarmModel(
    TimeOfDay(hour: json['hour'], minute: json['minute']),
    json['label'],
    json['id'],
  );
}

class FlashlightAlarmScreen extends StatefulWidget {
  const FlashlightAlarmScreen({super.key});

  @override
  State<FlashlightAlarmScreen> createState() => _FlashlightAlarmScreenState();
}

class _FlashlightAlarmScreenState extends State<FlashlightAlarmScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<AlarmModel> _alarms = [];
  bool _alarmGoingOff = false;
  Timer? _flashlightTimer;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _requestPermissions();
    _initNotifications();
    _loadAlarms();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.camera.request();
    await Permission.scheduleExactAlarm.request();
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == 'STOP') {
          _stopAlarm();
        } else if (response.actionId == 'SNOOZE') {
          _snoozeAlarm();
        } else {
          _startFlashlightAndVibration();
        }
      },
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final label = "Alarm at ${picked.format(context)}";
      final alarm = AlarmModel(picked, label, id);

      setState(() => _alarms.add(alarm));
      _scheduleAlarm(alarm);
      _saveAlarms();
    }
  }

  Future<void> _scheduleAlarm(AlarmModel alarm) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Flashlight Alarm Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'STOP',
          'Stop Alarm',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'SNOOZE',
          'Snooze 5 min',
          showsUserInterface: false,
        ),
      ],
    );

    await _notificationsPlugin.zonedSchedule(
      alarm.id,
      alarm.label,
      'Tap to stop or snooze',
      tzTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'alarm${alarm.id}',
    );

    _showMessage("Alarm set for ${alarm.time.format(context)}");

    Future.delayed(tzTime.difference(DateTime.now()), () {
      if (mounted) _startFlashlightAndVibration();
    });
  }

  void _startFlashlightAndVibration() {
    if (_alarmGoingOff) return;
    setState(() => _alarmGoingOff = true);

    _flashlightTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      try {
        if (timer.tick % 2 == 0) {
          await TorchLight.enableTorch();
        } else {
          await TorchLight.disableTorch();
        }
      } catch (_) {}
    });

    Vibration.vibrate(pattern: [0, 500, 500], repeat: 0);
  }

  void _stopAlarm() {
    _flashlightTimer?.cancel();
    TorchLight.disableTorch();
    Vibration.cancel();
    setState(() => _alarmGoingOff = false);
    _showMessage("Alarm stopped");
  }

  Future<void> _snoozeAlarm() async {
    _stopAlarm();
    final now = DateTime.now().add(const Duration(minutes: 5));
    final snoozeTime = TimeOfDay(hour: now.hour, minute: now.minute);

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final alarm = AlarmModel(snoozeTime, "Snoozed Alarm", id);

    setState(() => _alarms.add(alarm));
    await _scheduleAlarm(alarm);
    _saveAlarms();
    _showMessage("Snoozed for 5 minutes");
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_alarms.map((e) => e.toJson()).toList());
    await prefs.setString('alarms', encoded);
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('alarms');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      final loadedAlarms = decoded.map((e) => AlarmModel.fromJson(e)).toList();
      setState(() => _alarms.addAll(loadedAlarms));
      for (var alarm in loadedAlarms) {
        _scheduleAlarm(alarm);
      }
    }
  }

  void _deleteAlarm(int index) {
    final id = _alarms[index].id;
    setState(() => _alarms.removeAt(index));
    _notificationsPlugin.cancel(id);
    _saveAlarms();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _flashlightTimer?.cancel();
    TorchLight.disableTorch();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashlight Alarm'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Column(
        children: [
          if (_alarmGoingOff)
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.all(10),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
                onPressed: _stopAlarm,
                icon: const Icon(Icons.stop),
                label: const Text("Stop Alarm"),
              ),
            ),
          Expanded(
            child:
                _alarms.isEmpty
                    ? Center(
                      child: Text(
                        "No alarms set",
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                    : ListView.builder(
                      itemCount: _alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = _alarms[index];
                        return ListTile(
                          leading: Icon(
                            Icons.alarm,
                            color: theme.iconTheme.color,
                          ),
                          title: Text(
                            alarm.label,
                            style: theme.textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            "Time: ${alarm.time.format(context)}",
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: () => _deleteAlarm(index),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickTime(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor:
            isDark ? const Color.fromARGB(255, 142, 38, 160) : Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

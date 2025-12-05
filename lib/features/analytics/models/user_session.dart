import 'dart:convert';

class UserSession {
  final int? id;
  final String startTime;
  final String? endTime;
  final int duration; // in seconds
  final List<String>? screensVisited;

  UserSession({
    this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.screensVisited,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'screens_visited': screensVisited != null ? jsonEncode(screensVisited) : null,
    };
  }

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      id: map['id'] as int?,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String?,
      duration: map['duration'] as int,
      screensVisited: map['screens_visited'] != null
          ? List<String>.from(jsonDecode(map['screens_visited'] as String))
          : null,
    );
  }

  factory UserSession.start() {
    return UserSession(
      startTime: DateTime.now().toIso8601String(),
      duration: 0,
      screensVisited: [],
    );
  }

  UserSession copyWith({
    int? id,
    String? startTime,
    String? endTime,
    int? duration,
    List<String>? screensVisited,
  }) {
    return UserSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      screensVisited: screensVisited ?? this.screensVisited,
    );
  }

  UserSession addScreen(String screenName) {
    final screens = List<String>.from(screensVisited ?? []);
    if (!screens.contains(screenName)) {
      screens.add(screenName);
    }
    return copyWith(screensVisited: screens);
  }

  UserSession end() {
    final now = DateTime.now();
    final start = DateTime.parse(startTime);
    final durationInSeconds = now.difference(start).inSeconds;
    
    return copyWith(
      endTime: now.toIso8601String(),
      duration: durationInSeconds,
    );
  }

  String get formattedDuration {
    if (duration < 60) {
      return '$duration seconds';
    } else if (duration < 3600) {
      final minutes = (duration / 60).floor();
      return '$minutes minutes';
    } else {
      final hours = (duration / 3600).floor();
      final minutes = ((duration % 3600) / 60).floor();
      return '$hours hours $minutes minutes';
    }
  }

  @override
  String toString() {
    return 'UserSession(id: $id, start: $startTime, end: $endTime, duration: $formattedDuration)';
  }
}

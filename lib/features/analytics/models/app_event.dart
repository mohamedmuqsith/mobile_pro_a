import 'dart:convert';

class AppEvent {
  final int? id;
  final String eventType;
  final String screenName;
  final String actionName;
  final String timestamp;
  final Map<String, dynamic>? metadata;

  AppEvent({
    this.id,
    required this.eventType,
    required this.screenName,
    required this.actionName,
    required this.timestamp,
    this.metadata,
  });

  // Event Types Constants
  static const String eventScreenView = 'screen_view';
  static const String eventButtonClick = 'button_click';
  static const String eventRecordAdded = 'record_added';
  static const String eventRecordUpdated = 'record_updated';
  static const String eventRecordDeleted = 'record_deleted';
  static const String eventSearchPerformed = 'search_performed';
  static const String eventFormSubmitted = 'form_submitted';
  static const String eventNavigationTap = 'navigation_tap';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_type': eventType,
      'screen_name': screenName,
      'action_name': actionName,
      'timestamp': timestamp,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    return AppEvent(
      id: map['id'] as int?,
      eventType: map['event_type'] as String,
      screenName: map['screen_name'] as String,
      actionName: map['action_name'] as String,
      timestamp: map['timestamp'] as String,
      metadata: map['metadata'] != null 
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  factory AppEvent.screenView(String screenName, {Map<String, dynamic>? metadata}) {
    return AppEvent(
      eventType: AppEvent.eventScreenView,
      screenName: screenName,
      actionName: 'view',
      timestamp: DateTime.now().toIso8601String(),
      metadata: metadata,
    );
  }

  factory AppEvent.buttonClick(String screenName, String buttonName, {Map<String, dynamic>? metadata}) {
    return AppEvent(
      eventType: AppEvent.eventButtonClick,
      screenName: screenName,
      actionName: buttonName,
      timestamp: DateTime.now().toIso8601String(),
      metadata: metadata,
    );
  }

  factory AppEvent.recordAction(String action, String screenName, {Map<String, dynamic>? metadata}) {
    return AppEvent(
      eventType: action,
      screenName: screenName,
      actionName: action,
      timestamp: DateTime.now().toIso8601String(),
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'AppEvent(id: $id, type: $eventType, screen: $screenName, action: $actionName, time: $timestamp)';
  }
}

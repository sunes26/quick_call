import 'package:flutter/material.dart';

class SpeedDialButton {
  final int? id;
  final String name;
  final String phoneNumber;
  final Color color;
  final String group;
  final int position;
  final DateTime createdAt;
  final DateTime? lastCalled;
  final bool isInWidget;
  final int widgetPosition;

  SpeedDialButton({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.color = const Color(0xFF2196F3),
    this.group = '일반',
    required this.position,
    DateTime? createdAt,
    this.lastCalled,
    this.isInWidget = false,
    this.widgetPosition = -1,
  }) : createdAt = createdAt ?? DateTime.now();

  // DB에서 데이터를 가져올 때 사용
  factory SpeedDialButton.fromMap(Map<String, dynamic> map) {
    // 🆕 color 값 안전하게 파싱
    int colorValue;
    final colorData = map['color'];
    if (colorData is int) {
      colorValue = colorData;
    } else if (colorData is String) {
      colorValue = int.tryParse(colorData) ?? 0xFF2196F3;
    } else {
      colorValue = 0xFF2196F3; // 기본 파란색
    }
    
    return SpeedDialButton(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      color: Color(colorValue),
      group: map['group'] as String? ?? '일반',
      position: map['position'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastCalled: map['lastCalled'] != null
          ? DateTime.parse(map['lastCalled'] as String)
          : null,
      isInWidget: (map['isInWidget'] as int? ?? 0) == 1,
      widgetPosition: map['widgetPosition'] as int? ?? -1,
    );
  }

  // DB에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'color': color.value,
      'group': group,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'lastCalled': lastCalled?.toIso8601String(),
      'isInWidget': isInWidget ? 1 : 0,
      'widgetPosition': widgetPosition,
    };
  }

  // 복사본 생성 (업데이트용)
  SpeedDialButton copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    Color? color,
    String? group,
    int? position,
    DateTime? createdAt,
    DateTime? lastCalled,
    bool? isInWidget,
    int? widgetPosition,
  }) {
    return SpeedDialButton(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      color: color ?? this.color,
      group: group ?? this.group,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      lastCalled: lastCalled ?? this.lastCalled,
      isInWidget: isInWidget ?? this.isInWidget,
      widgetPosition: widgetPosition ?? this.widgetPosition,
    );
  }

  @override
  String toString() {
    return 'SpeedDialButton(id: $id, name: $name, phoneNumber: $phoneNumber, color: $color, group: $group, position: $position, isInWidget: $isInWidget, widgetPosition: $widgetPosition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpeedDialButton &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.color == color &&
        other.group == group &&
        other.position == position &&
        other.isInWidget == isInWidget &&
        other.widgetPosition == widgetPosition;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        color.hashCode ^
        group.hashCode ^
        position.hashCode ^
        isInWidget.hashCode ^
        widgetPosition.hashCode;
  }
}
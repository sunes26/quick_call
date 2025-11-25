import 'package:flutter/material.dart';

class SpeedDialButton {
  final int? id;
  final String name;
  final String phoneNumber;
  final IconData iconData;
  final String group; // 그룹 추가: '전체', '가족', '긴급', '직장', '친구' 등
  final int position;
  final DateTime createdAt;
  final DateTime? lastCalled;
  final bool isInWidget; // 🆕 위젯에 표시 여부
  final int widgetPosition; // 🆕 위젯 내 순서 (0-3)

  SpeedDialButton({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.iconData,
    this.group = '일반', // 기본 그룹
    required this.position,
    DateTime? createdAt,
    this.lastCalled,
    this.isInWidget = false, // 🆕 기본값: 위젯에 표시 안함
    this.widgetPosition = -1, // 🆕 기본값: -1 (위젯에 없음)
  }) : createdAt = createdAt ?? DateTime.now();

  // DB에서 데이터를 가져올 때 사용
  factory SpeedDialButton.fromMap(Map<String, dynamic> map) {
    return SpeedDialButton(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      iconData: IconData(
        map['iconCodePoint'] as int,
        fontFamily: map['iconFontFamily'] as String?,
        fontPackage: map['iconFontPackage'] as String?,
      ),
      group: map['group'] as String? ?? '일반',
      position: map['position'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastCalled: map['lastCalled'] != null
          ? DateTime.parse(map['lastCalled'] as String)
          : null,
      isInWidget: (map['isInWidget'] as int? ?? 0) == 1, // 🆕 SQLite boolean (0/1)
      widgetPosition: map['widgetPosition'] as int? ?? -1, // 🆕
    );
  }

  // DB에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'iconCodePoint': iconData.codePoint,
      'iconFontFamily': iconData.fontFamily,
      'iconFontPackage': iconData.fontPackage,
      'group': group,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'lastCalled': lastCalled?.toIso8601String(),
      'isInWidget': isInWidget ? 1 : 0, // 🆕 SQLite boolean (0/1)
      'widgetPosition': widgetPosition, // 🆕
    };
  }

  // 복사본 생성 (업데이트용)
  SpeedDialButton copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    IconData? iconData,
    String? group,
    int? position,
    DateTime? createdAt,
    DateTime? lastCalled,
    bool? isInWidget, // 🆕
    int? widgetPosition, // 🆕
  }) {
    return SpeedDialButton(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      iconData: iconData ?? this.iconData,
      group: group ?? this.group,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      lastCalled: lastCalled ?? this.lastCalled,
      isInWidget: isInWidget ?? this.isInWidget, // 🆕
      widgetPosition: widgetPosition ?? this.widgetPosition, // 🆕
    );
  }

  @override
  String toString() {
    return 'SpeedDialButton(id: $id, name: $name, phoneNumber: $phoneNumber, group: $group, position: $position, isInWidget: $isInWidget, widgetPosition: $widgetPosition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpeedDialButton &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.iconData == iconData &&
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
        iconData.hashCode ^
        group.hashCode ^
        position.hashCode ^
        isInWidget.hashCode ^
        widgetPosition.hashCode;
  }
}
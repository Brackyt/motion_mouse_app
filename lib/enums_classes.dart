import 'package:flutter/material.dart';

enum MouseAction
{
    NONE,
    KEYBOARD_WRITE,
    KEYBOARD_PRESS,
    KEYBOARD_COMBO,
    MOUSE_CLICK,
    MOUSE_DOUBLE_CLICK,
    MOUSE_MOVE
}

enum KeyActionType {
  NONE,
  KEYBOARD_KEY,
  MOUSE_KEY,
  MEDIA_KEY,
}

enum MacroType {
  NO_REPEAT,
  REPEAT_HOLD,
  TOGGLE,
  SEQUENCE,
}

class Shortcut {
  Shortcut({this.title});

  final String title;
  String keymap;
  List<int> mediaKeys;
  List<int> keys;
}

class InputOptionItem {
  const InputOptionItem(this.key, this.name, this.icon, this.keyActionType);
  final String name;
  final Icon icon;
  final int key;
  final KeyActionType keyActionType;

  @override
  bool operator ==(Object other) => other is InputOptionItem && other.name == name;

  @override
  int get hashCode => name.hashCode;

  InputOptionItem.fromJson(Map<String, dynamic> json)
          : name = json["name"],
            icon = Icon(Icons.mouse, color: Colors.white),
            key = json["key"],
            keyActionType = KeyActionType.values[json["keyActionType"]];

  String toString() {
    return ('InputOptionItem [name: ' + name + ', key: ' + key.toString() + ']');
  }

  Map<String, dynamic> toJson() =>
    {
      'name': name,
      'key': key,
      'keyActionType': keyActionType.index,
    };
}

class OptionItem {
  const OptionItem(this.name, this.icon, this.macroType);
  final String name;
  final Icon icon;
  final MacroType macroType;
}

class JsonIcon {
  JsonIcon(this.iconData);

  final IconData iconData;

  JsonIcon.fromJson(Map<String, dynamic> json)
          : iconData = IconData(json["codePoint"], fontFamily: json["fontFamily"], fontPackage: json["fontPackage"]);

  Map<String, dynamic> toJson() =>
    {
      'codePoint': iconData.codePoint,
      'fontFamily': iconData.fontFamily,
      'fontPackage': iconData.fontPackage,
    };
}
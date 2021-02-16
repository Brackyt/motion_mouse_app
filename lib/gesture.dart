import 'combo_elem.dart';
import 'enums_classes.dart';

class Gesture {
  Gesture({this.id, this.name, this.keys, this.macroType});

  int id;
  String name;
  List<ComboElem> keys;
  MacroType macroType;
  JsonIcon icon;

  Gesture.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    id = json["id"];
    keys = keysToJson(json["keys"]);
    icon = JsonIcon.fromJson(json["icon"]);
    macroType = MacroType.values[json["macroType"]];
  }

  String toString() {
    return ('Gesture [name: ' + name + ', macroType: ' + macroType.toString() + ', keys: ' + keys.toString() + ']');
  }

  List<ComboElem> keysToJson(List<dynamic> keys) {
    List<ComboElem> keysRet = List<ComboElem>();

    for (int i = 0; i < keys.length; i++) {
      keysRet.add(ComboElem.fromJson(keys[i]));
    }

    return keysRet;
  }

  Map<String, dynamic> toJson() =>
    {
      'name': name,
      'id': id,
      'keys': keys.map((k) => k.toJson()).toList(),
      'icon': icon.toJson(),
      'macroType': macroType.index,
    };
}
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

List<Gesture> _gestures = List<Gesture>();

void main() {
  runApp(MotionMouse());
}

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

class Shortcut {
  Shortcut({this.title});

  final String title;
  String keymap;
  List<int> mediaKeys;
  List<int> keys;
}

enum KeyActionType {
  NONE,
  KEYBOARD_KEY,
  MOUSE_KEY,
  MEDIA_KEY,
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

enum MacroType {
  NO_REPEAT,
  REPEAT_HOLD,
  TOGGLE,
  SEQUENCE,
}

List<InputOptionItem> getListForOption(InputOptionItem option) {
  switch(option.keyActionType) {
    case KeyActionType.NONE:
      return keyTypeOptions;
      break;
    case KeyActionType.KEYBOARD_KEY:
      return keyboardKeyOptions;
      break;
    case KeyActionType.MOUSE_KEY:
      return mouseKeyOptions;
      break;
    case KeyActionType.MEDIA_KEY:
      return mediaKeyOptions;
      break;
    default:
  }
  return null;
}

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

class SettingStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localGesturesFile async {
    final path = await _localPath;
    return File('$path/gestures');
  }

  Future<List<Gesture>> readGestures() async {
    try {
      final file = await _localGesturesFile;
      List<Gesture> gestures;

      // Read the file
      String contents = await file.readAsString();
      gestures = (json.decode(contents) as List).map((i) =>
                    Gesture.fromJson(i)).toList();
      return gestures;
    } catch (e) {
      print(e);
      return new List<Gesture>();
    }
  }

  Future<File> writeGestures(List<Gesture> gestures) async {
    final file = await _localGesturesFile;
    var json = jsonEncode(gestures.map((g) => g.toJson()).toList());

    return file.writeAsString('$json');
  }
}

class MotionMouse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MotionMouseState();
}

class _MotionMouseState extends State<MotionMouse> {
  bool doneIntroScreen = false;

  @override initState() {
    super.initState();
    _loadIntroDone();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotionMouse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.black,
        backgroundColor: Colors.black,
        indicatorColor: Color(0xff0E1D36),
        buttonColor: Color(0xff3B3B3B),
        hintColor: Color(0xff280C0B),
        highlightColor: Color(0xff372901),
        hoverColor: Color(0xff3A3A3B),
        focusColor: Color(0xff0B2512),
        disabledColor: Colors.grey,
        textSelectionColor: Colors.white,
        cardColor: Color(0xFF121212),
        accentColor: Colors.blue,
        canvasColor: Colors.black,
        brightness: Brightness.dark,
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: ColorScheme.dark(),
        ),
        /*primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,*/
      ),
      home: doneIntroScreen ? HomePage(title: 'MotionMouse Gestures', storage: SettingStorage()) : IntroScreen(),
    );
  }

  void _loadIntroDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      doneIntroScreen = (prefs.getBool('introDone') ?? false);
    });
  }
}

class IntroScreen extends StatefulWidget {
  final List<PageViewModel> listPagesViewModel = <PageViewModel>[
    PageViewModel(
      title: "MotionMouse Gesture Manager",
      bodyWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Swipe left or click next"),
        ],
      ),
      image: const Center(child: Icon(Icons.gesture, size: 200)),
    ),
    PageViewModel(
      title: "Add Gesture",
      bodyWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Click on "),
          Icon(Icons.add),
          Text(" to add a gesture."),
        ],
      ),
      image: const Center(child: Icon(Icons.gesture, size: 200)),
    ),
    PageViewModel(
      title: "Edit Gesture",
      bodyWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Click on a gesture card to edit it."),
        ],
      ),
      image: const Center(child: Icon(Icons.gesture, size: 200)),
    ),
  ];

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  _setIntroDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('introDone', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: widget.listPagesViewModel,
      onDone: () {
        _setIntroDone();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomePage(title: 'MotionMouse Gestures', storage: SettingStorage())),);
      },
      showSkipButton: true,
      next: const Icon(Icons.navigate_next),
      skip: const Text('Skip'),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).accentColor,
        color: Theme.of(context).buttonColor,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0)
        )
      ),
    );
  }
}

class EditGesture extends StatefulWidget {
  EditGesture(this.gesture);

  final Gesture gesture;

  @override
  _EditGestureState createState() => _EditGestureState();
}

class _EditGestureState extends State<EditGesture> {
  int _count = 0;
  Icon _icon;

  int currentStep = 0;
  List<Step> addActionSteps = List<Step>();
  OptionItem selectedMacroType;

  void reorderData(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      ComboElem item = widget.gesture.keys.removeAt(oldIndex);
      widget.gesture.keys.insert(newIndex, item);
      _count = 0;
    });
  }

  _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context, iconPackMode: IconPack.material);

    _icon = Icon(icon);
    setState(() {});
  }

  List<ComboElem> getKeysFromStepper() {
    List<ComboElem> keys = List<ComboElem>();

    for (Step step in addActionSteps) {
      keys.add(step.content);
    }

    return keys;
  }

  @override
  void initState() { 
    super.initState();
    
    if (_icon == null) {
      _icon = Icon(widget.gesture.icon.iconData);
      setState(() {});
    }

    if (addActionSteps.length <= 0) {
      int countSteps = 1;
      for (ComboElem comboElem in widget.gesture.keys) {
        addActionSteps.add(
          Step(
            title: Text("Step " + countSteps.toString()),
            content: comboElem,
            isActive: true,
          ),
        );
        countSteps = countSteps + 1;
      }
    }

    selectedMacroType = macroTypeOptionItems[widget.gesture.macroType.index];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Gesture"),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: new Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                      child: Divider(
                        color: Theme.of(context).accentColor,
                        height: 36,
                        thickness: 5,
                      ),
                    ),
                  ),
                  Text("Gesture Info", style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: new Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                      child: Divider(
                        color: Theme.of(context).accentColor,
                        height: 36,
                        thickness: 5,
                      )
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              RaisedButton(
                onPressed: _pickIcon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Choose Icon', style: TextStyle(color: Theme.of(context).textSelectionColor)),
                    SizedBox(width: 10),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: _icon != null ? _icon : Container(),
                    ),
                  ],
                ),
                color: Theme.of(context).buttonColor,
              ),
              SizedBox(height: 10),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter a gesture name.";
                  }

                  return value;
                },
                initialValue: widget.gesture.name,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Name of the gesture',
                  labelText: 'Gesture Name',
                  fillColor: Theme.of(context).buttonColor,
                  hintStyle: TextStyle(color: Theme.of(context).disabledColor),
                  labelStyle: TextStyle(color: Theme.of(context).disabledColor),
                ),
                onChanged: (value) {
                  widget.gesture.name = value;
                },
              ),
              SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Theme.of(context).accentColor,
                          height: 36,
                          thickness: 5,
                        )),
                  ),
                  Text("Gesture Action", style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Theme.of(context).accentColor,
                          height: 36,
                          thickness: 5,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButton<OptionItem>(
                hint: Text("Select Macro Type", style: TextStyle(color: Theme.of(context).textSelectionColor)),
                value: selectedMacroType,
                onChanged: (OptionItem value) {
                  setState(() {
                    selectedMacroType = value;
                  });
                },
                dropdownColor: Theme.of(context).buttonColor,
                items: macroTypeOptionItems.map((OptionItem item) {
                  return DropdownMenuItem<OptionItem>(
                    key: ValueKey(item),
                    value: item,
                    child: Row(
                      children: <Widget>[
                        item.icon,
                        SizedBox(width: 10),
                        Text(
                          item.name,
                          style: TextStyle(color: Theme.of(context).textSelectionColor),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Stepper(
                physics: ClampingScrollPhysics(),
                key: ValueKey("Stepper" + addActionSteps.length.toString()),
                currentStep: currentStep,
                steps: addActionSteps,
                type: StepperType.vertical,
                onStepTapped: (step) {
                  setState(() {
                    currentStep = step;
                  });
                },
                onStepCancel: () {
                  setState(() {
                    if (currentStep > 0) {
                      currentStep = currentStep - 1;
                    } else {
                      currentStep = 0;
                    }
                  });
                },
                onStepContinue: () {
                    setState(() {
                      if (currentStep == addActionSteps.length - 1) {
                        String stepName = "Step " + (addActionSteps.length + 1).toString();
                        addActionSteps.add(
                          Step(
                            title: Text(stepName),
                            content: ComboElem(selectedAction: keyTypeOptions[0], items: keyTypeOptions),
                            isActive: true,
                          ),
                        );
                      }
                      if (currentStep < addActionSteps.length - 1) {
                        currentStep = currentStep + 1;
                      }
                    });
                },
              ),
              /*Container(
                height: 50,
                child: ReorderableListView(
                  children: List.generate(
                    widget.action.keys.length,
                    (index) {
                      return Container(
                        key: ValueKey(index),
                        child: widget.action.keys[index]
                      );
                    },
                  ),/*[
                    for (final item in widget.gesture.keys)
                      Container(
                        key: ValueKey(widget.gesture.keys.indexOf(item)),
                        child: item,
                      ),
                  ],*/
                  //children: currentGesture.keys,
                  scrollDirection: Axis.horizontal,
                  onReorder: reorderData,
                ),
              ),*/
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.gesture.macroType = selectedMacroType.macroType;
                  widget.gesture.keys = getKeysFromStepper();
                  widget.gesture.icon = JsonIcon(_icon.icon);
                  _gestures[_gestures.indexOf(widget.gesture)] = widget.gesture;
                  Navigator.pop(context, true);
                },
                child: Text('Save Gesture!'),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                  onPrimary: Theme.of(context).textSelectionColor,
                ),
              ),
            ],
          ),
        ),
      ),
      /*body: Center(
        child: ElevatedButton(
          onPressed: () {
            _gestures.add(new Gesture(name: "Scroll Up"));
            Navigator.pop(context, true);
          },
          child: Text('Add Gesture!'),
        ),
      ),*/
    );
  }

  void _addNewComboElem() {
    setState(() {
      _count = _count + 1;
    });
  }
}

/*List<InputOptionItem> keyOptionItems = <InputOptionItem>[
  const InputOptionItem(0, 'NONE', Icon(Icons.stop, color: Colors.white)),
  // KEYBOARD
  const InputOptionItem(1, 'Left CTRL', Icon(Icons.keyboard)),
  const InputOptionItem(2, 'Right CTRL', Icon(Icons.keyboard)),
  const InputOptionItem(3, 'Left SHIFT', Icon(Icons.keyboard)),
  const InputOptionItem(4, 'Right SHIFT', Icon(Icons.keyboard)),
  const InputOptionItem(5, 'Left ALT', Icon(Icons.keyboard)),
  const InputOptionItem(6, 'Right ALT', Icon(Icons.keyboard)),
  const InputOptionItem(7, 'CAPS', Icon(Icons.keyboard)),
  const InputOptionItem(8, 'ESC', Icon(Icons.keyboard)),
  const InputOptionItem(9, 'ENTER', Icon(Icons.keyboard)),
  // MOUSE
  const InputOptionItem(10, 'Left CLICK', Icon(Icons.mouse)),
  const InputOptionItem(11, 'Right CLICK', Icon(Icons.mouse)),
  const InputOptionItem(12, 'Middle CLICK', Icon(Icons.mouse)),
];*/

List<InputOptionItem> keyboardKeyOptions = <InputOptionItem>[
  const InputOptionItem(0, 'NONE', Icon(Icons.stop), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(1, 'Left CTRL', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(2, 'Right CTRL', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(3, 'Left SHIFT', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(4, 'Right SHIFT', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(5, 'Left ALT', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(6, 'Right ALT', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(7, 'CAPS', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(8, 'ESC', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(9, 'ENTER', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
];

List<InputOptionItem> mouseKeyOptions = <InputOptionItem>[
  const InputOptionItem(10, 'NONE', Icon(Icons.stop), KeyActionType.MOUSE_KEY),
  const InputOptionItem(11, 'Left CLICK', Icon(Icons.mouse), KeyActionType.MOUSE_KEY),
  const InputOptionItem(12, 'Right CLICK', Icon(Icons.mouse), KeyActionType.MOUSE_KEY),
  const InputOptionItem(13, 'Middle CLICK', Icon(Icons.mouse), KeyActionType.MOUSE_KEY),
];

List<InputOptionItem> mediaKeyOptions = <InputOptionItem>[
  const InputOptionItem(14, 'NONE', Icon(Icons.stop), KeyActionType.MEDIA_KEY),
  const InputOptionItem(15, 'Volume Up', Icon(Icons.perm_media), KeyActionType.MEDIA_KEY),
  const InputOptionItem(16, 'Volume Down', Icon(Icons.perm_media), KeyActionType.MEDIA_KEY),
  const InputOptionItem(17, 'Play/Pause', Icon(Icons.perm_media), KeyActionType.MEDIA_KEY),
  const InputOptionItem(18, 'Next Track', Icon(Icons.perm_media), KeyActionType.MEDIA_KEY),
  const InputOptionItem(19, 'Previous Track', Icon(Icons.perm_media), KeyActionType.MEDIA_KEY),
];

List<InputOptionItem> keyTypeOptions = <InputOptionItem>[
  const InputOptionItem(20, 'NONE', Icon(Icons.stop), KeyActionType.NONE),
  const InputOptionItem(21, 'Keyboard Key', Icon(Icons.keyboard), KeyActionType.KEYBOARD_KEY),
  const InputOptionItem(22, 'Mouse Key', Icon(Icons.mouse), KeyActionType.MOUSE_KEY),
  const InputOptionItem(23, 'Media Key', Icon(Icons.perm_media), KeyActionType.MEDIA_KEY),
];


/*
const InputOptionItem(1, 'Left CTRL Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(2, 'Left CTRL Up', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(3, 'Right CTRL Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(4, 'Right CTRL Up', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(5, 'Left SHIFT Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(6, 'Left SHIFT Up', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(7, 'Right SHIFT Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(8, 'Right SHIFT Up', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(9, 'Left ALT Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(10, 'Left ALT Up', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(11, 'Right ALT Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(12, 'Right ALT Up', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(13, 'CAPS Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(14, 'CAPS Up', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(15, 'ESC Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(16, 'ESC Up', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(17, 'ENTER Down', Icon(Icons.keyboard, color: Colors.red)),
  const InputOptionItem(18, 'ENTER Up', Icon(Icons.keyboard, color: Colors.red)),
  // MOUSE
  const InputOptionItem(19, 'Left CLICK Down', Icon(Icons.mouse, color: Colors.green), mouse: true),
  const InputOptionItem(20, 'Left CLICK Up', Icon(Icons.mouse, color: Colors.green), mouse: true),
  const InputOptionItem(21, 'Right CLICK Down', Icon(Icons.mouse, color: Colors.green), mouse: true),
  const InputOptionItem(22, 'Right CLICK Up', Icon(Icons.mouse, color: Colors.green), mouse: true),
  const InputOptionItem(23, 'Middle CLICK Donw', Icon(Icons.mouse, color: Colors.green), mouse: true),
  const InputOptionItem(24, 'Middle CLICK Up', Icon(Icons.mouse, color: Colors.green), mouse: true),
*/

// ignore: must_be_immutable
class ComboElem extends StatefulWidget {
  InputOptionItem selectedAction;
  InputOptionItem selectedActionType;
  List<InputOptionItem> items;
  bool selectionDropdown = false;

  ComboElem({this.selectedAction, this.items});


  @override
  // ignore: invalid_override_of_non_virtual_member
  bool operator ==(Object other) => other is ComboElem && other.selectedAction == selectedAction;

  @override
  // ignore: invalid_override_of_non_virtual_member
  int get hashCode => selectedAction.hashCode;

  ComboElem.fromJson(Map<String, dynamic> json)
          : selectedActionType = InputOptionItem.fromJson(json["selectedActionType"]),
            selectedAction = InputOptionItem.fromJson(json["selectedAction"]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return (selectedAction.name);
    //return ('ComboElem [selectedAction: ' + selectedAction.toString() + ']');
  }

  Map<String, dynamic> toJson() =>
    {
      'selectedActionType': selectedActionType.toJson(),
      'selectedAction': selectedAction.toJson(),
    };
  @override
  _ComboElemState createState() => _ComboElemState();
}

class _ComboElemState extends State<ComboElem> {

  @override
  void initState() { 
    super.initState();
    
    if (widget.selectedActionType != null && widget.selectedAction != null) {
      widget.items = keyTypeOptions;
      widget.selectionDropdown = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<InputOptionItem>(
          hint: Text("Select Action Type"),
          value: widget.selectedActionType,
          onChanged: (InputOptionItem value) {
            setState(() {
              widget.selectedActionType = value;
              widget.selectedAction = null;
              widget.selectionDropdown = true;
            });
          },
          items: widget.items.map((InputOptionItem item) {
            return DropdownMenuItem<InputOptionItem>(
              value: item,
              child: Row(
                children: <Widget>[
                  Icon(item.icon.icon, color: Theme.of(context).accentColor),
                  SizedBox(width: 10),
                  Text(
                    item.name,
                    style: TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (widget.selectionDropdown)
          DropdownButton<InputOptionItem>(
            hint: Text("Select Action"),
            value: widget.selectedAction,
            onChanged: (InputOptionItem value) {
              setState(() {
                widget.selectedAction = value;
              });
            },
            items: getListForOption(widget.selectedActionType).map((InputOptionItem item) {
              return DropdownMenuItem<InputOptionItem>(
                value: item,
                child: Row(
                  children: <Widget>[
                    Icon(item.icon.icon, color: Theme.of(context).accentColor),
                    SizedBox(width: 10),
                    Text(
                      item.name,
                      style: TextStyle(color: Theme.of(context).textSelectionColor),
                    ),
                  ],
                ),
              );
            }).toList(),
        )
      ],
    );
  }
}

List<OptionItem> macroTypeOptionItems = <OptionItem>[
  const OptionItem('No Repeatation', Icon(Icons.arrow_right, color: Colors.red), MacroType.NO_REPEAT),
  const OptionItem('Repeat when holding', Icon(Icons.arrow_circle_down, color: Colors.red), MacroType.REPEAT_HOLD),
  const OptionItem('Toggle', Icon(Icons.toggle_on, color: Colors.red), MacroType.TOGGLE),
  const OptionItem('Sequence', Icon(Icons.folder, color: Colors.red), MacroType.SEQUENCE),
];

class AddGesture extends StatefulWidget {
  List<ComboElem> combos = List<ComboElem>();

  @override
  _AddGestureState createState() => _AddGestureState();
}

class _AddGestureState extends State<AddGesture> {
  String name;
  Gesture gesture = Gesture();
  Icon _icon;

  int _count = 1;

  InputOptionItem selectedItem;
  InputOptionItem selectedAction;

  OptionItem selectedMacroType;

  int currentStep = 0;
  List<Step> addActionSteps = [
    Step(
      title: Text("Step 1"),
      content: ComboElem(selectedAction: keyTypeOptions[0], items: keyTypeOptions),
      isActive: true,
    ),
  ];
  /*List<OptionItem> optionItems = <OptionItem>[
    const OptionItem('Mouse Action', Icon(Icons.mouse_rounded, color: Colors.red)),
    const OptionItem('Keyboard Key', Icon(Icons.keyboard, color: Colors.red)),
  ];*/

  void reorderData(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      ComboElem item = widget.combos.removeAt(oldIndex);
      widget.combos.insert(newIndex, item);
      _count = 0;
    });
  }

  _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context, iconPackMode: IconPack.material);

    _icon = Icon(icon);
    setState(() {});
  }

  List<ComboElem> getKeysFromStepper() {
    List<ComboElem> keys = List<ComboElem>();

    for (Step step in addActionSteps) {
      keys.add(step.content);
    }

    return keys;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Gesture"),
      ),
      body : Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Theme.of(context).accentColor,
                          height: 36,
                          thickness: 5,
                        )),
                  ),
                  Text("Gesture Info", style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Theme.of(context).accentColor,
                          height: 36,
                          thickness: 5,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 20),
              RaisedButton(
                onPressed: _pickIcon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Choose Icon', style: TextStyle(color: Theme.of(context).textSelectionColor)),
                    SizedBox(width: 10),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: _icon != null ? _icon : Container(),
                    ),
                  ],
                ),
                color: Theme.of(context).buttonColor,
              ),
              SizedBox(height: 10),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter a gesture name.";
                  }

                  return value;
                },
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Name of the gesture',
                  labelText: 'Gesture Name',
                  fillColor: Theme.of(context).buttonColor,
                  hintStyle: TextStyle(color: Theme.of(context).disabledColor),
                  labelStyle: TextStyle(color: Theme.of(context).disabledColor),
                ),
                onChanged: (value) {
                  gesture.name = value;
                },
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                  decorationColor: Theme.of(context).textSelectionColor,
                ),
              ),
              SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Theme.of(context).accentColor,
                          height: 36,
                          thickness: 5,
                        )),
                  ),
                  Text("Gesture Action", style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Theme.of(context).accentColor,
                          height: 36,
                          thickness: 5,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButton<OptionItem>(
                hint: Text("Select Macro Type", style: TextStyle(color: Theme.of(context).textSelectionColor)),
                value: selectedMacroType,
                onChanged: (OptionItem value) {
                  setState(() {
                    selectedMacroType = value;
                  });
                },
                dropdownColor: Theme.of(context).buttonColor,
                items: macroTypeOptionItems.map((OptionItem item) {
                  return DropdownMenuItem<OptionItem>(
                    key: ValueKey(item),
                    value: item,
                    child: Row(
                      children: <Widget>[
                        item.icon,
                        SizedBox(width: 10),
                        Text(
                          item.name,
                          style: TextStyle(color: Theme.of(context).textSelectionColor),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Stepper(
                physics: ClampingScrollPhysics(),
                key: ValueKey("Stepper" + addActionSteps.length.toString()),
                currentStep: currentStep,
                steps: addActionSteps,
                type: StepperType.vertical,
                onStepTapped: (step) {
                  setState(() {
                    currentStep = step;
                  });
                },
                onStepCancel: () {
                  setState(() {
                    if (currentStep > 0) {
                      currentStep = currentStep - 1;
                    } else {
                      currentStep = 0;
                    }
                  });
                },
                onStepContinue: () {
                    setState(() {
                      if (currentStep == addActionSteps.length - 1) {
                        String stepName = "Step " + (addActionSteps.length + 1).toString();
                        addActionSteps.add(
                          Step(
                            title: Text(stepName),
                            content: ComboElem(selectedAction: keyTypeOptions[0], items: keyTypeOptions),
                            isActive: true,
                          ),
                        );
                      }
                      if (currentStep < addActionSteps.length - 1) {
                        currentStep = currentStep + 1;
                      }
                    });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  gesture.macroType = selectedMacroType.macroType;
                  gesture.keys = getKeysFromStepper();
                  gesture.icon = JsonIcon(_icon.icon);
                  _gestures.add(gesture);
                  Navigator.pop(context, true);
                },
                child: Text('Add Gesture!'),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                  onPrimary: Theme.of(context).textSelectionColor,
                ),
              ),
            ],
          ),
        ),
      ),
      /*body: Form(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  RaisedButton(
                    onPressed: _pickIcon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Choose Icon', style: TextStyle(color: Theme.of(context).textSelectionColor)),
                        SizedBox(width: 10),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: _icon != null ? _icon : Container(),
                        ),
                      ],
                    ),
                    color: Theme.of(context).buttonColor,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please enter a gesture name.";
                      }

                      return value;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Name of the gesture',
                      labelText: 'Gesture Name',
                      fillColor: Theme.of(context).buttonColor,
                      hintStyle: TextStyle(color: Theme.of(context).disabledColor),
                      labelStyle: TextStyle(color: Theme.of(context).disabledColor),
                    ),
                    onChanged: (value) {
                      gesture.name = value;
                    },
                    style: TextStyle(
                      color: Theme.of(context).textSelectionColor,
                      decorationColor: Theme.of(context).textSelectionColor,
                    ),
                  ),
                  DropdownButton<OptionItem>(
                    hint: Text("Select Macro Type", style: TextStyle(color: Theme.of(context).textSelectionColor)),
                    value: selectedMacroType,
                    onChanged: (OptionItem value) {
                      setState(() {
                        selectedMacroType = value;
                      });
                    },
                    dropdownColor: Theme.of(context).buttonColor,
                    items: macroTypeOptionItems.map((OptionItem item) {
                      return DropdownMenuItem<OptionItem>(
                        key: ValueKey(item),
                        value: item,
                        child: Row(
                          children: <Widget>[
                            item.icon,
                            SizedBox(width: 10),
                            Text(
                              item.name,
                              style: TextStyle(color: Theme.of(context).textSelectionColor),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Container(
                    height: 50,
                    child: ReorderableListView(
                      children: [
                        for (final item in widget.combos)
                          Container(
                            key: ValueKey(widget.combos.indexOf(item)),
                            child: item,
                          ),
                      ],
                      //children: currentGesture.keys,
                      scrollDirection: Axis.horizontal,
                      onReorder: reorderData,
                    ),/*ListView(
                      children: _combos, //something happening here i don't remember (maybe make reorderable) ---- also need to fix bug where you crash when you move a just added comboelem
                      scrollDirection: Axis.horizontal,
                    ),*/
                  ),
                  FlatButton(
                    onPressed: _addNewComboElem,
                    child: Icon(Icons.add),
                  ),
                  /*Column(
                    children: [
                      DropdownButton<OptionItem>(
                        hint: Text("Select Macro Type"),
                        value: selectedMacroType,
                        onChanged: (OptionItem value) {
                          setState(() {
                            selectedMacroType = value;
                          });
                        },
                        items: macroTypeOptionItems.map((OptionItem item) {
                          return DropdownMenuItem<OptionItem>(
                            value: item,
                            child: Row(
                              children: <Widget>[
                                item.icon,
                                SizedBox(width: 10),
                                Text(
                                  item.name,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      DropdownButton<InputOptionItem>(
                        hint: Text("Select Action"),
                        value: selectedAction,
                        onChanged: (InputOptionItem value) {
                          setState(() {
                            selectedAction = value;
                          });
                        },
                        items: keyOptionItems.map((InputOptionItem item) {
                          return DropdownMenuItem<InputOptionItem>(
                            value: item,
                            child: Row(
                              children: <Widget>[
                                item.icon,
                                SizedBox(width: 10),
                                Text(
                                  item.name,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),*/
                  ElevatedButton(
                    onPressed: () {
                      gesture.keys = widget.combos;
                      gesture.icon = JsonIcon(_icon.icon);
                      _gestures.add(gesture);
                      Navigator.pop(context, true);
                    },
                    child: Text('Add Gesture!'),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).accentColor,
                      onPrimary: Theme.of(context).textSelectionColor,
                    ),
                  ),
                ].expand(
                  (widget) => [
                    widget,
                    SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),*/
      /*body: Center(
        child: ElevatedButton(
          onPressed: () {
            _gestures.add(new Gesture(name: "Scroll Up"));
            Navigator.pop(context, true);
          },
          child: Text('Add Gesture!'),
        ),
      ),*/
    );
  }

  void _addNewComboElem() {
    setState(() {
      _count = _count + 1;
    });
  }
}

class HomePage extends StatefulWidget {
  final SettingStorage storage;

  HomePage({Key key, this.title, @required this.storage}) : super(key: key);

  String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex;
  bool showOverlay = true;

  void addGestureToStorage() {
    setState(() {
      for (int i = 0; i < _gestures.length; i++) {
        for (int j = 0; j < _gestures[i].keys.length; j++) {
          ComboElem elem = _gestures[i].keys[j];
          if (elem.selectedAction == null || elem.selectedAction.name == "NONE") {
            _gestures[i].keys.removeAt(j);
          }
        }
      }
      widget.storage.writeGestures(_gestures);
    });
  }

  void removeGestureFromStorage() {
    setState(() {
      widget.storage.writeGestures(new List<Gesture>());
    });
  }

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    widget.storage.readGestures().then((List<Gesture> gestures) {
      setState(() {
        _gestures = gestures;
      });
    });
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void changeTitle(String title) {
    setState(() {
      widget.title = title;
    });
  }

  Widget callPage(int selectedPage) {
    switch (selectedPage) {
      case 0: return ListView.builder(padding: const EdgeInsets.all(5.5), itemCount: _gestures?.length ?? 0, itemBuilder: _gestureItemBuilder,);
      break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: callPage(currentIndex),/*ListView.builder(
        padding: const EdgeInsets.all(5.5),
        itemCount: _gestures?.length ?? 0,
        itemBuilder: _itemBuilder,
      ),*/
      floatingActionButton: /*_buildFab(context),*/FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddGesture()),).then((val) => {addGestureToStorage()}),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: [Icons.gesture, Icons.touch_app, Icons.shopping_bag, Icons.settings],
        activeIndex: currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        leftCornerRadius: 15,
        rightCornerRadius: 15,
        onTap: changePage,
        backgroundColor: Theme.of(context).cardColor,
        activeColor: Theme.of(context).accentColor,
        inactiveColor: Theme.of(context).buttonColor,
      ),/*BubbleBottomBar(
        opacity: 0.2,
        currentIndex: currentIndex,
        onTap: changePage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 8,
        fabLocation: BubbleBottomBarFabLocation.center,
        hasNotch: true,
        notchMargin: 6,
        items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(backgroundColor: Colors.red, icon: Icon(Icons.gesture, color: Colors.black,), activeIcon: Icon(Icons.gesture, color: Colors.red,), title: Text("Gestures")),
            BubbleBottomBarItem(backgroundColor: Colors.indigo, icon: Icon(Icons.shopping_bag, color: Colors.black,), activeIcon: Icon(Icons.shopping_bag, color: Colors.indigo,), title: Text("Marketplace")),
        ],
      ),*/
      /*BubbleBottomBar(
        opacity: 0.2,
        currentIndex: currentIndex,
        onTap: changePage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 8,
        fabLocation: BubbleBottomBarFabLocation.end,
        hasNotch: true,
        items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(backgroundColor: Colors.red, icon: Icon(Icons.gesture, color: Colors.black,), activeIcon: Icon(Icons.gesture, color: Colors.red,), title: Text("Gestures")),
            BubbleBottomBarItem(backgroundColor: Colors.indigo, icon: Icon(Icons.shopping_bag, color: Colors.black,), activeIcon: Icon(Icons.shopping_bag, color: Colors.indigo,), title: Text("Marketplace")),
        ],
      ),*/
      /*floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddGesture()),).then((val) => {addGestureToStorage()}),
            tooltip: 'Add Gesture',
            child: Icon(Icons.add),
            heroTag: null,
          ),
          FloatingActionButton(
            onPressed: removeGestureFromStorage,
            tooltip: 'Remove Gestures',
            child: Icon(Icons.remove),
            heroTag: null,
          ),
        ],
      ),*/
    );
  }

  Widget _buildFab(BuildContext context) {
    final icons = [ Icons.add, Icons.remove ];
    final titles = [ "Add Gesture", "Remove GEsture" ];

    return AnchoredOverlay(
      showOverlay: showOverlay,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy - icons.length * 35.0),
          child: FabWithIcons(
            icons: icons,
            titles: titles,
            onIconTapped: onIconTapped,
          ),
        );
      },
      child: FloatingActionButton(
        onPressed: () { },
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
    );
  }

  void onIconTapped(int index) {
    switch (index) {
      case 0: 
        setState(() {
          showOverlay = false;
        });
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddGesture()),).then((val) {
          addGestureToStorage();
          setState(() {
            showOverlay = true;
          });
        });
        break;
      case 1: removeGestureFromStorage(); break;
      default:
    }
  }

  void _removeGesture(int index) {
    _gestures.removeAt(index);
    addGestureToStorage();
  }

  void _editGesture(int index) {
    setState(() {
      showOverlay = false;
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditGesture(_gestures[index])),).then((val) {
      addGestureToStorage();
      setState(() {
        showOverlay = true;
      });
    });
  }

  Widget _gestureItemBuilder(BuildContext context, int index) {
    return Card(
      margin: EdgeInsets.all(4),
      elevation: 4,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        splashColor: Theme.of(context).splashColor,
        onTap: () => _editGesture(index),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).buttonColor,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: InkWell(
                  splashColor: Theme.of(context).splashColor,
                  child: Icon(
                    (_gestures[index].icon != null) ? _gestures[index].icon.iconData : Icons.gesture,
                    color: Theme.of(context).accentColor,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${_gestures[index].name}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${_gestures[index].keys.toString()}',
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${_gestures[index].macroType.toString()}',
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: InkWell(
                splashColor: Theme.of(context).splashColor,
                onTap: () => _removeGesture(index),
                child: Icon(
                  Icons.remove_circle,
                  color: Theme.of(context).buttonColor,
                  size: 24.0,
                ),
              )
            ),
          ],
        ),
      ),
      
    );
  }
}

class FabWithIcons extends StatefulWidget {
  FabWithIcons({this.icons, this.titles, this.onIconTapped});
  final List<IconData> icons;
  final List<String> titles;
  ValueChanged<int> onIconTapped;
  @override
  State createState() => FabWithIconsState();
}

class FabWithIconsState extends State<FabWithIcons> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.icons.length, (int index) {
        return _buildChild(index);
      }).toList()..add(
        _buildFab(),
      ),
    );
  }

  Widget _buildChild(int index) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 70.0,
      alignment: FractionalOffset.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(
              0.0,
              1.0 - index / widget.icons.length / 4.0,
              curve: Curves.easeOut
          ),
        ),
        child: MaterialButton(
          shape: StadiumBorder(),
          padding: EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 20),
          color: backgroundColor,
          splashColor: Colors.grey.withOpacity(0.1),
          highlightColor: Theme.of(context).highlightColor,
          elevation: 2,
          highlightElevation: 2,
          disabledColor: Theme.of(context).disabledColor,
          onPressed: () => _onTapped(index),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(widget.icons[index], color: foregroundColor),
              SizedBox(
                width: 10.0,
              ),
              Text(widget.titles[index]),
            ],
          ),
        )/*FloatingActionButton(
          backgroundColor: backgroundColor,
          child: Row(
            children: <Widget>[
              Text("Test"),
              Icon(widget.icons[index], color: foregroundColor),
            ],
          ),//Icon(widget.icons[index], color: foregroundColor),
          onPressed: () => _onTapped(index),
        ),*/
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      tooltip: 'Increment',
      child: Icon(Icons.add),
      elevation: 2.0,
    );
  }

  void _onTapped(int index) {
    _controller.reverse();
    widget.onIconTapped(index);
  }
}

class AnchoredOverlay extends StatelessWidget {
  final bool showOverlay;
  final Widget Function(BuildContext, Offset anchor) overlayBuilder;
  final Widget child;

  AnchoredOverlay({
    this.showOverlay,
    this.overlayBuilder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return new OverlayBuilder(
          showOverlay: showOverlay,
          overlayBuilder: (BuildContext overlayContext) {
            RenderBox box = context.findRenderObject() as RenderBox;
            final center = box.size.center(box.localToGlobal(const Offset(0.0, 0.0)));
            return overlayBuilder(overlayContext, center);
          },
          child: child,
        );
      }),
    );
  }
}

class OverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final Function(BuildContext) overlayBuilder;
  final Widget child;

  OverlayBuilder({
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  });

  @override
  _OverlayBuilderState createState() => new _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }

    super.dispose();
  }

  bool isShowingOverlay() => overlayEntry != null;

  void showOverlay() {
    overlayEntry = new OverlayEntry(
      builder: widget.overlayBuilder,
    );
    addToOverlay(overlayEntry);
  }

  void addToOverlay(OverlayEntry entry) async {
    Overlay.of(context).insert(entry);
  }

  void hideOverlay() {
    overlayEntry.remove();
    overlayEntry = null;
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      dispose();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class CenterAbout extends StatelessWidget {
  final Offset position;
  final Widget child;

  CenterAbout({
    this.position,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Positioned(
      top: position.dy,
      left: position.dx,
      child: new FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: child,
      ),
    );
  }
}
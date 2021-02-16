import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import 'combo_elem.dart';
import 'enums_classes.dart';
import 'gesture.dart';
import 'main.dart';

class AddGesture extends StatefulWidget {
  List<ComboElem> combos = List<ComboElem>();

  @override
  _AddGestureState createState() => _AddGestureState();
}

class _AddGestureState extends State<AddGesture> {
  String name;
  Gesture gesture = Gesture();
  Icon _icon;

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

  void reorderData(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      ComboElem item = widget.combos.removeAt(oldIndex);
      widget.combos.insert(newIndex, item);
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
                  gestures.add(gesture);
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
    );
  }
}
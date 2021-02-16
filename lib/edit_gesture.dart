import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import 'combo_elem.dart';
import 'enums_classes.dart';
import 'gesture.dart';
import 'main.dart';

class EditGesture extends StatefulWidget {
  EditGesture(this.gesture);

  final Gesture gesture;

  @override
  _EditGestureState createState() => _EditGestureState();
}

class _EditGestureState extends State<EditGesture> {
  Icon _icon;

  int currentStep = 0;
  List<Step> addActionSteps = List<Step>();
  OptionItem selectedMacroType;

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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.gesture.macroType = selectedMacroType.macroType;
                  widget.gesture.keys = getKeysFromStepper();
                  widget.gesture.icon = JsonIcon(_icon.icon);
                  gestures[gestures.indexOf(widget.gesture)] = widget.gesture;
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
    );
  }
}
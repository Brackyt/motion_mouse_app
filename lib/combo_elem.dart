// ignore: must_be_immutable
import 'package:flutter/material.dart';

import 'enums_classes.dart';
import 'main.dart';

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
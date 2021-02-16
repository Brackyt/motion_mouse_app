import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import 'add_gesture.dart';
import 'combo_elem.dart';
import 'edit_gesture.dart';
import 'enums_classes.dart';
import 'gesture.dart';
import 'settings_storage.dart';

List<Gesture> gestures = List<Gesture>();

List<OptionItem> macroTypeOptionItems = <OptionItem>[
  const OptionItem('No Repeatation', Icon(Icons.arrow_right, color: Colors.red), MacroType.NO_REPEAT),
  const OptionItem('Repeat when holding', Icon(Icons.arrow_circle_down, color: Colors.red), MacroType.REPEAT_HOLD),
  const OptionItem('Toggle', Icon(Icons.toggle_on, color: Colors.red), MacroType.TOGGLE),
  const OptionItem('Sequence', Icon(Icons.folder, color: Colors.red), MacroType.SEQUENCE),
];

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

void main() {
  runApp(MotionMouse());
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
      for (int i = 0; i < gestures.length; i++) {
        for (int j = 0; j < gestures[i].keys.length; j++) {
          ComboElem elem = gestures[i].keys[j];
          if (elem.selectedAction == null || elem.selectedAction.name == "NONE") {
            gestures[i].keys.removeAt(j);
          }
        }
      }
      widget.storage.writeGestures(gestures);
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
    widget.storage.readGestures().then((List<Gesture> _gestures) {
      setState(() {
        gestures = _gestures;
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
      case 0: return ListView.builder(padding: const EdgeInsets.all(5.5), itemCount: gestures?.length ?? 0, itemBuilder: _gestureItemBuilder,);
      break;
      default:
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: callPage(currentIndex),
      floatingActionButton: FloatingActionButton(
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
    gestures.removeAt(index);
    addGestureToStorage();
  }

  void _editGesture(int index) {
    setState(() {
      showOverlay = false;
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditGesture(gestures[index])),).then((val) {
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
                    (gestures[index].icon != null) ? gestures[index].icon.iconData : Icons.gesture,
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
                      '${gestures[index].name}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${gestures[index].keys.toString()}',
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${gestures[index].macroType.toString()}',
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

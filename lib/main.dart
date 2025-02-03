import 'dart:html';
import 'dart:ui_web';
import 'dart:js' as js;
import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Flutter Demo', home: HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  String? url;
  bool? isButtonPressed = false;
  bool isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: isButtonPressed == true
                    ? InkWell(
                        onDoubleTap: () {
                          if (isFullscreen) {
                            exitFullscreen();
                          } else {
                            enterFullscreen();
                          }
                        },
                        child: const SizedBox(
                            height: 360,
                            width: 500,
                            child: HtmlElementView(
                              viewType: 'load-image',
                            )),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      url = value;
                      setState(() {});
                    },
                    decoration: const InputDecoration(hintText: 'Image URL'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (url != null) {
                      platformViewRegistry.registerViewFactory(
                          'load-image',
                          (int viewId) => ImageElement()
                            ..height = 360
                            ..width = 500
                            ..src = url
                            ..style.border = 'none');
                      isButtonPressed = true;
                      setState(() {});
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Icon(
                      Icons.arrow_forward,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          checkFullscreen();
        },
        child: PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 1) {
                enterFullscreen();
              } else {
                exitFullscreen();
              }
            },
            itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text(
                      'Enter FullScreen',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text(
                      "Exit FullScreen",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
            icon: const Icon(Icons.add)),
      ),
    );
  }

  enterFullscreen() {
    js.context.callMethod('eval', [
      """
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
      } else {
        document.exitFullscreen();
      }
    """
    ]);
  }

  exitFullscreen() {
    js.context.callMethod('eval', [
      """
      if (document.fullscreenElement) {
      document.exitFullscreen();
      } 
    """
    ]);
  }

  void checkFullscreen() {
    var result =
        js.context.callMethod('eval', ["document.fullscreenElement != null"]);
    setState(() {
      isFullscreen = result;
    });
  }
}

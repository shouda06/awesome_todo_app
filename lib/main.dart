import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 97, 164, 235)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AwesomeToDo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _counter = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState(){
    super.initState();
    _initList();
  }
  
  Future<void> _initList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('LIST');
    if (jsonString != null) {
      final jsonObject = jsonDecode(jsonString);
       setState(() {
        _counter = jsonObject;
      });
    }else{
       setState(() {
        _counter = [];
      });
    }
   }

  void _incrementCounter() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _counter.add({'text': _controller.text, 'completed': false});
        _controller.text = '';
      });
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_counter).toString();
      await prefs.setString('LIST', jsonString);
    }
   }

  void _toggleCompletion(int index) async {
    setState(() {
      _counter[index]['completed'] = !_counter[index]['completed'];
    });
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_counter).toString();
    await prefs.setString('LIST', jsonString);
  }

  void _removeItem(int index) async {
    setState(() {
      _counter.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_counter).toString();
    await prefs.setString('LIST', jsonString);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.inversePrimary,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                itemCount: _counter.length,
                itemBuilder: (context, index) => Dismissible(
                  key: Key(_counter[index]['text']),
                  onDismissed: (direction) {
                    _removeItem(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: GestureDetector(
                      onTap: () => _toggleCompletion(index),
                      child: Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4, left: 12, right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromRGBO(152, 233, 157, 1),
                        ),
                        child: Text(
                          _counter[index]['text'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: _counter[index]['completed']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color.fromRGBO(236, 237, 238, 1),
                          filled: true,
                        ),
                        controller: _controller,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _incrementCounter,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
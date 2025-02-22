import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: 'Flutter Todo'),
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
  List<Map<String, dynamic>> _counter = [];
  final TextEditingController _controller = TextEditingController();

  void _incrementCounter() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _counter.add({'text': _controller.text, 'completed': false});
        _controller.text = '';
      });
    }
  }

  void _toggleCompletion(int index) {
    setState(() {
      _counter[index]['completed'] = !_counter[index]['completed'];
    });
  }

  void _removeItem(int index) {
    setState(() {
      _counter.removeAt(index);
    });
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
                      child: Text(
                        _counter[index]['text'],
                        style: TextStyle(
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
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _controller,
                  ),
                ),
                IconButton(
                  onPressed: _incrementCounter,
                  icon: const Icon(Icons.send),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
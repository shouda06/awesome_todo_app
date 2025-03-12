import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import "package:intl/intl.dart";

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
  final ScrollController _scrollController = ScrollController();  // スクロールコントローラー追加

  @override
  void initState(){
    super.initState();
    _initList();
  }
  
  Future<void> _initList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('LISTv1');
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
      final addToDos = [];
      final userInput = _controller.text;
      final divideUserInputArray = userInput.split('\n');
      var titleNumber = 0;
      divideUserInputArray.forEach((divideUserInput) {
        if(divideUserInput == '') return;
        if(divideUserInput[0] != '・'){
          addToDos.add({'title': divideUserInput, 'completed': false, 'time': DateTime.now().toString(), 'subtitles': []});
          titleNumber += 1;
        }else{
          addToDos[titleNumber - 1]['subtitles'].add({'subTitle': divideUserInput, 'completed': false});
        }
      });
      setState(() {
        _counter.addAll(addToDos);
        _controller.text = '';
        print(_counter);
      });
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent); // スクロールを最下部に移動
      });
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_counter).toString();
      await prefs.setString('LISTv1', jsonString);
    }
   }

  void _toggleCompletion(int index) async {
    setState(() {
      _counter[index]['completed'] = !_counter[index]['completed'];
    });
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_counter).toString();
    await prefs.setString('LISTv1', jsonString);
  }

  void _removeItem(int index) async {
    setState(() {
      _counter.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_counter).toString();
    await prefs.setString('LISTv1', jsonString);
  }

  String dateFormat(String $datetimeString) {
    final datetime = DateTime.parse($datetimeString);
    final formatter = DateFormat('MM/dd');
    return formatter.format(datetime);
  }

  String timeFormat(String $datetimeString) {
    final datetime = DateTime.parse($datetimeString);
    final formatter = DateFormat('H:m');
    return formatter.format(datetime);
  }

  bool isShowDate(dynamic arr, int i) {
    if(i <= 0) {
      return true;
    }
    final correntDatetime = DateTime.parse(arr[i]['time']);
    final beforeDatetime = DateTime.parse(arr[i - 1]['time']);
    final formatter = DateFormat('MM/dd');
    final correntFormatted = formatter.format(correntDatetime);
    final beforeFormatted = formatter.format(beforeDatetime);

    return correntFormatted != beforeFormatted;
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
                controller: _scrollController,  // スクロールコントローラー設定
                itemCount: _counter.length,
                itemBuilder: (context, index) => Dismissible(
                  key: Key(_counter[index]['title']),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          isShowDate(_counter, index) ? Container(
                            margin: EdgeInsets.only(bottom: 10),
                            alignment: Alignment.center,
                            width: double.infinity,
                            child: Container(
                              padding: EdgeInsets.only(right: 6, left: 6, top: 1, bottom: 1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Color.fromARGB(60, 0, 0, 0),
                              ),
                              child: Text(
                                dateFormat(_counter[index]['time']),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ) : SizedBox(),
                          Container(
                            padding: EdgeInsets.only(top: 4, bottom: 4, left: 12, right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color.fromRGBO(152, 233, 157, 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _counter[index]['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    decoration: _counter[index]['completed']
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                               ...( _counter[index]['subtitles'].map((subTitle){
                                  return Text(
                                  subTitle['subTitle'],
                                    style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    decoration: _counter[index]['completed']
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    ),
                                  );
                                })).toList()
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 4, right: 2),
                            child: Text(
                              timeFormat(_counter[index]['time']),
                              style: TextStyle(
                                fontSize: 12
                              ),
                            ),
                          )
                        ],
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
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
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
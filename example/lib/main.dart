import 'package:flutter/material.dart';
import 'package:flutter_requery/flutter_requery.dart';

void main() {
  runApp(App());
}

final List<String> data = ["Hello"];

class App extends StatelessWidget {
  Future<List<String>> _getData() async {
    await Future.delayed(Duration(seconds: 1));
    return data;
  }

  Future<void> _addString() async {
    await Future.delayed(Duration(seconds: 1));
    data.add("World");
  }

  void _onPress() async {
    // Call API and invalidate your query by using the same cache key
    await _addString();
    queryCache.invalidateQueries('strKey');

    // Or if you don't want to wait and you are sure your API works use optimistic response.
    // _addString();
    // queryCache.setOptimistic('strKey', [...data, 'World']);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter requery"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Text("Add"),
          onPressed: _onPress,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Query<List<String>>(
            'strKey',
            future: _getData,
            builder: (context, response) {
              if (response.error != null) {
                return Text('Error');
              }
              if (response.loading) {
                return CircularProgressIndicator();
              }
              return ListView(
                children: response.data.map((str) => Text(str)).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

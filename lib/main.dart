import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:google_fonts_arabic/fonts.dart';

Future<Names> fetchNames() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/MZDN/asma-u-llahi-l-husna/main/BeautifulNamesOfAllah.json');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Names.fromJson(jsonDecode(response.body)["AsmaHusna"] as List);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Names');
  }
}

class Names {
  final List<Name> names;
  Names({
    this.names,
  });
  factory Names.fromJson(List<dynamic> parsedJson) {
    List<Name> names = new List<Name>();
    names = parsedJson.map((i) => Name.fromJson(i)).toList();

    return new Names(names: names);
  }
}

class Name {
  final String number;
  final String arabic;
  final String transliteration;
  Map<String, dynamic> meaning = {};
  //or var meaning = <String, String>{};

  Name({this.number, this.arabic, this.transliteration, this.meaning});

  factory Name.fromJson(Map<String, dynamic> json) {
    return new Name(
      number: json['number'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      meaning: json['meaning'],
    );
  }
}

void main() => runApp(AsmsHusnaApp());

class AsmsHusnaApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asma-Lahi-l-husna',
      theme: ThemeData(
        primaryColor: Colors.lightBlue[900],
        accentColor: Colors.lightBlue[700],
      ),
      home: NamesPage(title: 'Asma-Lahi-l-Husna'),
    );
  }
}

class NamesPage extends StatefulWidget {
  NamesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NamesPageState createState() => _NamesPageState();
}

class _NamesPageState extends State<NamesPage> {
  Future<Names> futureNames;
  final List<Name> _saved = new List<Name>();
  //final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    futureNames = fetchNames();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asma-اللَّهُ-Husna',
      theme: ThemeData(
        primaryColor: Colors.lightBlue[900],
        accentColor: Colors.lightBlue[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Asma-اللَّهُ-Husna',
            style: new TextStyle(
              fontFamily: ArabicFonts.Amiri,
              fontWeight: FontWeight.bold,
              package: 'google_fonts_arabic',
              fontSize: 30.0,
            ),
          ),
          actions: <Widget>[
            // Add 3 lines from here...
            new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
          ],
        ),
        body: Center(
          child: FutureBuilder<Names>(
            future: futureNames,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //return Text(snapshot.data.names[0].arabic);
                return createListView(context, snapshot);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (Name name) {
              return new ListTile(
                leading: CircleAvatar(
                  //backgroundColor: Colors.lightBlue,
                  child: Text(
                    name.number,
                    style: new TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  name.arabic,
                  //style: TextStyle(fontWeight: FontWeight.bold),
                  style: new TextStyle(
                    fontFamily: ArabicFonts.Amiri,
                    fontWeight: FontWeight.bold,
                    package: 'google_fonts_arabic',
                    fontSize: 25.0,
                  ),
                ),
                subtitle: Text(name.transliteration),
                /*title: new Text(
                  name.arabic,
                  style: _biggerFont,
                ),*/
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Saved for Learning'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    Names values = snapshot.data;
    return new ListView.builder(
      itemCount: values.names.length,
      itemBuilder: (BuildContext context, int index) {
        final bool alreadySaved = _saved.contains(values.names[index]);

        return new Column(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  //backgroundColor: Colors.lightBlue,
                  child: Text(
                    values.names[index].number,
                    style: new TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  values.names[index].arabic,
                  //style: TextStyle(fontWeight: FontWeight.bold),
                  style: new TextStyle(
                    fontFamily: ArabicFonts.Amiri,
                    fontWeight: FontWeight.bold,
                    package: 'google_fonts_arabic',
                    fontSize: 25.0,
                  ),
                ),
                subtitle: Text(values.names[index]
                        .transliteration /* +
                    "\n" +
                    "" +
                    "\n" +
                    values.names[index].meaning["de"]*/
                    ),
                //trailing: Icon(Icons.more_vert),
                trailing: new Icon(
                  alreadySaved ? Icons.check_box : Icons.check,
                  color: alreadySaved ? Colors.lightBlue[700] : null,
                ),
                onTap: () {
                  // Add 9 lines from here...
                  setState(() {
                    if (alreadySaved) {
                      _saved.remove(values.names[index]);
                    } else {
                      _saved.add(values.names[index]);
                    }
                    //Sort list
                    _saved.sort((a, b) => a.number.compareTo(b.number));
                  });
                },
                isThreeLine: true,
              ),
            )
          ],
        );
      },
    );
  }
}

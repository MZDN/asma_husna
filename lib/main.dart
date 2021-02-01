import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:google_fonts_arabic/fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:audioplayers/audio_cache.dart';

Future<Names> fetchNames() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/MZDN/asma-u-llahi-l-husna/main/BeautifulNamesOfAllah.json');

  if (response.statusCode == 200 && json.decode(response.body) != null) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Names.fromJson(jsonDecode(response.body)["AsmaHusna"] as List);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Names');
  }
}
//https://stackoverflow.com/questions/51360481/how-can-i-to-load-and-query-local-json-data-in-flutter-mobile-app

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
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ar', 'DZ'), // English
        const Locale('en', 'US'), // English
        const Locale('de', 'DE'), // German
        const Locale('fr', 'FR'), // German
        // ... other locales the app supports
      ],
      home: NamesPage(title: 'Asma-Lahi-l-Husna'),
    );
  }
}

class NamesPage extends StatefulWidget {
  NamesPage({Key key, this.title}) : super(key: key);

  final String title;
  List<Name> _nameForDisplay = List<Name>();
  @override
  _NamesPageState createState() => _NamesPageState();
}

class _NamesPageState extends State<NamesPage> {
  Future<Names> futureNames;
  final List<Name> _saved = new List<Name>();

  //final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  static AudioCache player = AudioCache();

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
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ar', 'DZ'), // English
        const Locale('en', 'US'), // English
        const Locale('de', 'DE'), // German
        const Locale('fr', 'FR'), // German
        // ... other locales the app supports
      ],
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
            new IconButton(
              onPressed: () {
                //showSearch(context: context, delegate: Search(widget._nameForDisplay));
                //player.play("audio/all.mp3");
              },
              icon: Icon(Icons.play_circle_fill),
            ),
            new IconButton(
              onPressed: () {
                showSearch(context: context, delegate: Search(widget._nameForDisplay));
              },
              icon: Icon(Icons.search),
            ),
            new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),

          ],
          centerTitle: true,
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
          Locale myLocale = Localizations.localeOf(context);
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
                title: Row(
                  children: <Widget>[
                    (name.number == "00" || name.number == "85")
                        ? Text(
                            name.arabic,
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            style: new TextStyle(
                              fontFamily: ArabicFonts.Amiri,
                              fontWeight: FontWeight.bold,
                              package: 'google_fonts_arabic',
                              fontSize: 1.0,
                            ),
                          )
                        : Text(name.transliteration),
                    Spacer(flex: 1),
                    Text(
                      name.arabic,
                      //style: TextStyle(fontWeight: FontWeight.bold),
                      style: new TextStyle(
                        fontFamily: ArabicFonts.Amiri,
                        fontWeight: FontWeight.bold,
                        package: 'google_fonts_arabic',
                        fontSize: 25.0,
                      ),
                    )
                  ],
                ),

                subtitle: Text(name.meaning[myLocale.languageCode]),

                trailing: Icon(
                  Icons.play_arrow,
                ),
                onTap: () {
                  // you can add Play/push code over here
                  print("audio/" + name.number + ".mp3");
                  player.play("audio/" + name.number + ".mp3");
                },
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
    Locale myLocale = Localizations.localeOf(context);
    Names values = snapshot.data;
    widget._nameForDisplay.addAll(values.names);
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
                title: Row(
                  children: <Widget>[
                    (values.names[index].number == "00" ||
                            values.names[index].number == "85")
                        ? (Text(
                            values.names[index].arabic,
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            style: new TextStyle(
                              fontFamily: ArabicFonts.Amiri,
                              fontWeight: FontWeight.bold,
                              package: 'google_fonts_arabic',
                              fontSize: 1.0,
                            ),
                          ))
                        : Text(values.names[index].transliteration),
                    Spacer(flex: 1),
                    Text(
                      values.names[index].arabic,
                      //style: TextStyle(fontWeight: FontWeight.bold),
                      style: new TextStyle(
                        fontFamily: ArabicFonts.Amiri,
                        fontWeight: FontWeight.bold,
                        package: 'google_fonts_arabic',
                        fontSize: 25.0,
                      ),
                    ),
                  ],
                ),
                subtitle:
                    Text(values.names[index].meaning[myLocale.languageCode]),
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

class Search extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Name selectedResult = null;

  @override
  Widget buildResults(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    return Container(
        child:        Card(
          child: ListTile(
            leading: CircleAvatar(
              //backgroundColor: Colors.lightBlue,
              child: Text(
                selectedResult.number,
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            title: Row(
              children: <Widget>[
                (selectedResult.number == "00" ||
                    selectedResult.number == "85")
                    ? (Text(
                  selectedResult.arabic,
                  //style: TextStyle(fontWeight: FontWeight.bold),
                  style: new TextStyle(
                    fontFamily: ArabicFonts.Amiri,
                    fontWeight: FontWeight.bold,
                    package: 'google_fonts_arabic',
                    fontSize: 1.0,
                  ),
                ))
                    : Text(selectedResult.transliteration),
                Spacer(flex: 1),
                Text(
                  selectedResult.arabic,
                  //style: TextStyle(fontWeight: FontWeight.bold),
                  style: new TextStyle(
                    fontFamily: ArabicFonts.Amiri,
                    fontWeight: FontWeight.bold,
                    package: 'google_fonts_arabic',
                    fontSize: 25.0,
                  ),
                ),
              ],
            ),
            subtitle:
            Text(selectedResult.meaning[myLocale.languageCode]),
            //trailing: Icon(Icons.more_vert),

          ),
        ),
    );
  }

  List<Name> listExample;
  Search(this.listExample);

  List<Name> recentList = new List<Name>();

  @override
  Widget buildSuggestions(BuildContext context) {
    //recentList.addAll(listExample);
    List<Name> suggestionList = new List<Name>();
    query.isEmpty
        ? suggestionList = recentList //In the true case
        : suggestionList.addAll(listExample.where(
            // In the false case
            (element) => element.number.contains(query),
          ));
    /*List<Name> suggestionList = query.isEmpty
        ? listExample
        : listExample
        .where((x) => x.number.startsWith(query))
        .toList();*/

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        Locale myLocale = Localizations.localeOf(context);
       /* return ListTile(
          title: Text(
            suggestionList[index].number,
          ),
         // leading: query.isEmpty ? Icon(Icons.access_time) : SizedBox(),*/
        return new ListTile(
          leading: CircleAvatar(
            //backgroundColor: Colors.lightBlue,
            child: Text(
              suggestionList[index].number,
              style: new TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          title: Row(
            children: <Widget>[
              (suggestionList[index].number == "00" || suggestionList[index].number == "85")
                  ? Text(
                suggestionList[index].arabic,
                //style: TextStyle(fontWeight: FontWeight.bold),
                style: new TextStyle(
                  fontFamily: ArabicFonts.Amiri,
                  fontWeight: FontWeight.bold,
                  package: 'google_fonts_arabic',
                  fontSize: 1.0,
                ),
              )
                  : Text(suggestionList[index].transliteration),
              Spacer(flex: 1),
              Text(
                suggestionList[index].arabic,
                //style: TextStyle(fontWeight: FontWeight.bold),
                style: new TextStyle(
                  fontFamily: ArabicFonts.Amiri,
                  fontWeight: FontWeight.bold,
                  package: 'google_fonts_arabic',
                  fontSize: 25.0,
                ),
              )
            ],
          ),

          subtitle: Text(suggestionList[index].meaning[myLocale.languageCode]),
          onTap: () {
            selectedResult = suggestionList[index];
            showResults(context);
          },
        );
      },
    );
  }
}


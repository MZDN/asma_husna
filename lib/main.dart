import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:google_fonts_arabic/fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/services.dart' show rootBundle;

Future<String> _loadAsset() async {
  return await rootBundle.loadString('assets/data/BeautifulNamesOfAllah.json');
}
Future<Names> loadData() async {
  String jsonString = await _loadAsset();
  final jsonResponse = json.decode(jsonString);

  return Names.fromJson(jsonResponse["AsmaHusna"] as List);
}

Future<Names> fetchNames() async {
  final response = await http.get(
      Uri.parse('https://raw.githubusercontent.com/MZDN/asma-u-llahi-l-husna/main/BeautifulNamesOfAllah.json'));

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

  //static AudioCache player = AudioCache();
  List newTaskTitle;
  String path;
  bool playing = false;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer audioPlayer;
  AudioCache audioCache;

  @override
  void initState() {
    super.initState();
    //futureNames = fetchNames();
    futureNames = loadData();
    //init player
    initPlayer();
  }

  void initPlayer() {
    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);


  }

  //Button Widget
  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(
        minWidth: 48.0,
        child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }

  //Slider Widget
  Widget slider() {
    return Slider(
        value: _position.inSeconds.toDouble(),
        min: 0.0,
        max: _duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            seekToSecond(value.toInt());
            value = value;
          });
        });
  }

  //Seek Seconds
  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  // Tab For the player is here
  Widget _tab(List<Widget> children) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: children
              .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
              .toList(),
        ),
      ),
    );
  }

  //Audio Play Function
  playAudio(String track) {
    return audioCache.play(track);
  }

  //Audio pause Function
  pauseAudio() {
    return audioPlayer.pause();
  }

  //Audio Stop Function
  stopAudio() {
    return audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
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
          centerTitle: false,
          title: Text(
            'Asma-اللَّهُ-Husna',
            style: new TextStyle(
              fontFamily: ArabicFonts.Amiri,
              fontWeight: FontWeight.bold,
              package: 'google_fonts_arabic',
              fontSize: 25.0,
            ),
          ),
          actions: <Widget>[
            // Add 3 lines from here...
            new IconButton(
                icon: Icon(Icons.play_circle_fill), onPressed: _showPlayer),
            new IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: Search(widget._nameForDisplay));
              },
              icon: Icon(Icons.search),
            ),
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

  void _showPlayer() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 70,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.center, //Center Row contents vertically
              children: [
                IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                  ),
                  iconSize: 40,
                  color: Colors.blueAccent,
                  onPressed: () {
                    playAudio("audio/all.mp3");
                  },
                ),
                SizedBox(
                  width: 30.0,
                ),
                IconButton(
                  icon: Icon(
                    Icons.pause,
                  ),
                  iconSize: 40,
                  color: Colors.blueAccent,
                  onPressed: () {
                    pauseAudio();
                  },
                ),
                SizedBox(
                  width: 30.0,
                ),
                IconButton(
                  icon: Icon(
                    Icons.stop,
                  ),
                  iconSize: 40,
                  color: Colors.blueAccent,
                  onPressed: () {
                    stopAudio();
                  },
                ),
              ],
            ),
          ),
        );
      },
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    (name.number == "00" || name.number == "85")
                        ?  Expanded(child: (Text(
                            name.arabic,
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            style: new TextStyle(
                              fontFamily: ArabicFonts.Amiri,
                              fontWeight: FontWeight.bold,
                              package: 'google_fonts_arabic',
                              fontSize: 1.0,
                            ),
                          )),)
                        :  Expanded(child: (Text(name.transliteration))),
                    //Spacer(flex: 1),
                     Expanded(child: (Text(
                      name.arabic,
                      //style: TextStyle(fontWeight: FontWeight.bold),
                      style: new TextStyle(
                        fontFamily: ArabicFonts.Amiri,
                        fontWeight: FontWeight.bold,
                        package: 'google_fonts_arabic',
                        fontSize: 25.0,
                      ),
                    )))
                  ],
                ),
                subtitle: Text(name.meaning[myLocale.languageCode]),
                trailing: Icon(
                  Icons.play_arrow,
                ),
                onTap: () {
                  // you can add Play/push code over here
                  //print("audio/" + name.number + ".mp3");
                  //player.play("audio/" + name.number + ".mp3");
                  playAudio("audio/" + name.number + ".mp3");
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
                      actions: [
          new IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: Search(widget._nameForDisplay));
              },
              icon: Icon(Icons.search),
            ),
        ],
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
    widget._nameForDisplay.clear();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    (values.names[index].number == "00" ||
                            values.names[index].number == "85")
                        ?  Expanded(child: (Text(
                            values.names[index].arabic,
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            style: new TextStyle(
                              fontFamily: ArabicFonts.Amiri,
                              fontWeight: FontWeight.bold,
                              package: 'google_fonts_arabic',
                              fontSize: 1.0,
                            ),
                          )))
                        :  Expanded(child: Text(values.names[index].transliteration)),
                    //Spacer(flex: 2),
                    Expanded(child:  Text(
                      values.names[index].arabic,
                      //style: TextStyle(fontWeight: FontWeight.bold),
                      style: new TextStyle(
                        fontFamily: ArabicFonts.Amiri,
                        fontWeight: FontWeight.bold,
                        package: 'google_fonts_arabic',
                        fontSize: 20.0,
                      ),
                    ),)
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

bool isNumericUsing_tryParse(String string) {
  // Null or empty string is not a number
  if (string == null || string.isEmpty) {
    return false;
  }

  // Try to parse input string to number. 
  // Both integer and double work.
  // Use int.tryParse if you want to check integer only.
  // Use double.tryParse if you want to check double only.
  final number = num.tryParse(string);

  if (number == null) {
    return false;
  }

  return true;
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
      child: Card(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              (selectedResult.number == "00" || selectedResult.number == "85")
                  ? (Expanded(child:Text(
                      selectedResult.arabic,
                      //style: TextStyle(fontWeight: FontWeight.bold),
                      style: new TextStyle(
                        fontFamily: ArabicFonts.Amiri,
                        fontWeight: FontWeight.bold,
                        package: 'google_fonts_arabic',
                        fontSize: 1.0,
                      ),
                    )))
                  : Expanded(child:Text(selectedResult.transliteration)),
              //sSpacer(flex: 1),
              Expanded(child:Text(
                selectedResult.arabic,
                //style: TextStyle(fontWeight: FontWeight.bold),
                style: new TextStyle(
                  fontFamily: ArabicFonts.Amiri,
                  fontWeight: FontWeight.bold,
                  package: 'google_fonts_arabic',
                  fontSize: 25.0,
                ),
              ),)
            ],
          ),
          subtitle: Text(selectedResult.meaning[myLocale.languageCode]),
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
            isNumericUsing_tryParse(query)?

            // In the false case
            (element) => element.number.contains(query):
            (element) => element.transliteration.contains(query),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              (suggestionList[index].number == "00" ||
                      suggestionList[index].number == "85")
                  ? Expanded(child: Text(
                      suggestionList[index].arabic,
                      //style: TextStyle(fontWeight: FontWeight.bold),
                      style: new TextStyle(
                        fontFamily: ArabicFonts.Amiri,
                        fontWeight: FontWeight.bold,
                        package: 'google_fonts_arabic',
                        fontSize: 1.0,
                      ),
                    ))
                  : Expanded(child:Text(suggestionList[index].transliteration)),
              //Spacer(flex: 1),
              Expanded(child:Text(
                suggestionList[index].arabic,
                //style: TextStyle(fontWeight: FontWeight.bold),
                style: new TextStyle(
                  fontFamily: ArabicFonts.Amiri,
                  fontWeight: FontWeight.bold,
                  package: 'google_fonts_arabic',
                  fontSize: 25.0,
                ),
              ))
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

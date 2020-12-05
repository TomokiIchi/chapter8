import 'dart:async';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generated App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: const Color(0xFFe91e63),
        accentColor: const Color(0xFFe91e63),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new RssListPage(),
    );
  }
}

class RssListPage extends StatelessWidget {
  final List names = ['主要ニュース', '国際情勢', '国内の出来事', 'IT関係'];
  final List links = [
    'http://new.yahoo.co.jp/pickup/rss.xml',
    'http://new.yahoo.co.jp/pickup/world/rss.xml',
    'http://new.yahoo.co.jp/pickup/domestic/rss.xml',
    'http://new.yahoo.co.jp/pickup/computer/rss.xml',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yahoo! checker'),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: items(context),
        ),
      ),
    );
  }

  List<Widget> items(BuildContext context) {
    List items = [];
    for (var i = 0; i < names.length; i++) {
      items.add(ListTile(
        contentPadding: EdgeInsets.all(10.0),
        title: Text(
          names[i],
          style: TextStyle(fontSize: 24.0),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyRssPage(names[i], links[i]),
            ),
          );
        },
      ));
    }
    return items;
  }
}

class MyRssPage extends StatefulWidget {
  final String title;
  final String url;

  MyRssPage(@required this.title, @required this.url);

  @override
  _MyRssPageState createState() => new _MyRssPageState(title: title, url: url);
}

class _MyRssPageState extends State<MyRssPage> {
  final String title;
  final String url;
  List _items = [];
  _MyRssPageState({@required this.title, @required this.url}) {
    getItems();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: _items,
        ),
      ),
    );
  }

  void getItems() async {
    List list = [];
    Response res = await get(url);
    RssFeed feed = RssFeed.parse(res.body);
    for (RssItem item in feed.items) {
      list.add(ListTile(
        contentPadding: EdgeInsets.all(10.0),
        title: Text(
          item.title,
          style: TextStyle(fontSize: 24.0),
        ),
        subtitle: Text(item.pubDate),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ItemDetailsPage(item: item, title: title, url: url),
            ),
          );
        },
      ));
    }
    setState(() {
      _items = list;
    });
  }
}

class ItemDetailsPage extends StatefulWidget {
  final String title;
  final String url;
  final RssItem item;

  ItemDetailsPage(
      {@required this.item, @required this.title, @required this.url});
  @override
  _ItemDetails createState() => new _ItemDetails(item: item);
}

class _ItemDetails extends State {
  RssItem item;
  Widget _widget = Text('wait...');
  _ItemDetails({@required this.item});
  @override
  void initState() {
    super.initState();
    getItem();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: _widget,
    );
  }

  void getItem() async {
    Response res = await get(item.link);
    dom.Document doc = dom.Document.html(res.body);
    dom.Element hbody = doc.querySelector('.hbody');
    dom.Element htitle = doc.querySelector('.newsTitle a');
    dom.Element newslink = doc.querySelector('.newsLink');
    print(newslink.attributes['href']);

    setState(() {
      _widget = SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  htitle.text,
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  hbody.text,
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: Text(
                    '続きを読む...',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  onPressed: () {
                    launch(newslink.attributes['href']);
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

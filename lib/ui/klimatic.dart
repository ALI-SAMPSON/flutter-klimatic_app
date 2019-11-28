import 'dart:convert';

import 'package:flutter/material.dart';

import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:klimatic_app/util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() {
    return _KlimaticState();
  }
}

class _KlimaticState extends State<Klimatic> {

  String _cityEntered;

  void showData() async {
    Map data = await getWeather(util.apiId, util.defaultCity);
    print(data.toString());
  }

  // navigate to next screen
  Future _gotoNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new ChangeCity();
    }));

    if(results != null && results.containsKey('enter')){
      _cityEntered = results['enter'];
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Klimatic App",
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.menu), onPressed: () => _gotoNextScreen(context))
        ],
      ),
      body: new Stack(
        children: <Widget>[
          Center(
            child: new Image.asset(
              "images/umbrella.png",
              width: 490.0,
              fit: BoxFit.fill,
              height: 1200.0,
            ),
          ),

          // adding text
          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 5.5),
            child: Text(
              "${_cityEntered == null ? util.defaultCity : _cityEntered}",
              style: cityStyle(),
            ),
          ),

          // adding icon
          new Container(
            alignment: Alignment.center,
            child: new Image.asset("images/light_rain.png"),
          ),

          // container which will have our weather data
          updateTempWidget(_cityEntered),

        ],
      ),
    );
  }

  Future<Map> getWeather(String apiId, String city) async {
    String apiUrl = 'https://api.openweathermap.org/data/2.5/find?q=$city&appid=${util.apiId}&units=metric';
    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return new FutureBuilder(
        future: getWeather(util.apiId, city == null ? util.defaultCity : city ),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          // where we get all if the json
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return new Container(
              margin: const EdgeInsets.fromLTRB(30.0, 25.0, 0.0, 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: new Text(
                      content['main']['temp'].toString() + " F",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic),
                    ),
                    subtitle: new ListTile(
                      title: new Text(
                          "Humidity : ${content['main']['humidity'].toString()}\n"
                              "Min : ${content['main']['temp_min'].toString()} F\n"
                              "Max : ${content['main']['temp_max'].toString()} F\n",
                        style: extraData(),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return new Container();
          }
        });
  }
}

TextStyle cityStyle() {
  return new TextStyle(
      color: Colors.white, fontSize: 20.0, fontStyle: FontStyle.italic);
}

TextStyle extraData(){
  return TextStyle(
    color: Colors.white70,
    fontSize: 20.5,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal
  );
}

TextStyle tempStyle() {
  return TextStyle(
      color: Colors.white,
      fontSize: 49.0,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal);
}

// second screen
class ChangeCity extends StatelessWidget {

  // controller
  var _cityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Change City"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: <Widget>[
          Center(
              child: Image.asset(
            "images/white_snow.png",
            width: 490.0,
            height: 1200.0,
            fit: BoxFit.fill,
          )),

          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    hintText: "Enter City"
                  ) ,),
                ),

              new ListTile(
                title: new FlatButton(
                    onPressed: () {
                      Navigator.pop(context,{
                        'enter':_cityFieldController.text
                      });
                    },
                    textColor: Colors.white70,
                    color: Colors.redAccent,
                    child: new Text("Get Weather")),
              )

            ],
          ),

         ],
      )
    );
  }
}

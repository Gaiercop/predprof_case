import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FlightTask extends StatefulWidget {
  const FlightTask({super.key});

  @override
  State<FlightTask> createState() => _FlightTaskState();
}

class Point {
  int SH;
  int distance;

  Point(this.SH, this.distance);

  factory Point.fromJson(dynamic json) {
    return Point(json['SH'] as int, json['distance'] as int);
  }

  @override
  String toString() {
    return '{ ${this.SH}, ${this.distance} }';
  }
}

class _FlightTaskState extends State<FlightTask> {
  Future<List<Widget>>? _points;
  late List<Point> _couples;

  @override
  initState() {
    super.initState();

    _points = _getPoints();
  }

  Future<List<Widget>> _getPoints() async {
    var url = Uri.https('dt.miet.ru', '/ppo_it_final');
    var headers = {"X-Auth-Token": "93qvf6c9"};
    var response = await http.get(url, headers: headers);

    final arrayText = json.decode(response.body);

    var tagsJson = arrayText['message'];
    var tags = tagsJson != null ? List.from(tagsJson) : null;

    List<Point> result_points = List.empty(growable: true);
    List<Widget> pointsListText = List.empty(growable: true);

    for (var element in tags!) {
      var points =
          element["points"] != null ? List.from(element["points"]) : null;

      for (var point_element in points!) {
        result_points
            .add(Point(point_element["SH"], point_element["distance"]));
      }
    }

    pointsListText.add(
      Text(
        "Список точек:",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 32, color: Colors.black),
      ),
    );

    for (int i = 0; i < result_points.length; i++) {
      String title = "Точка №" + (i + 1).toString();

      int SH = result_points[i].SH;
      int distance = result_points[i].distance;

      pointsListText.add(
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ); //Text);

      pointsListText.add(
        Text(
          '$SH · $distance',
          maxLines: 1,
          style: const TextStyle(
              fontFamily: 'Lato',
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontSize: 15),
        ),
      );
    }

    _couples = result_points;
    return pointsListText;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
        future: _points,
        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(color: Colors.blue);
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: snapshot.data as List<Widget>,
            );
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        });
  }
}

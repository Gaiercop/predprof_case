import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

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
  int mk = 192, msh = 1, g0 = 8, vmx = 2;

  @override
  initState() {
    super.initState();

    _points = _getPoints();
  }

  int e(int t) {
    int ans = 0;
    for (int i = 0; i <= t; i++) {
      ans += i;
    }
    return ans;
  }

  z(int dist, double v, int n) {
    int ans = 0, day = (dist / v).round();
    int w = (((v * 80 * mk) / (200 * vmx) +
                (v * 80 * (mk + msh * n)) / (200 * vmx)) /
            2)
        .round();

    if (w > 80 || w > day) return [-1];
    ans += w * 10;

    int kp = (n / (8 * day)).floor();
    int sum = (acos(-kp) * 40 / pi).floor();

    if (w != 0 && 2 * sum > 60 * n) return [-1];
    int oxi = 2 * sum;
    ans += 7 * w * oxi;

    day -= w;
    int t = 5;
    oxi = 2 * (sum - t);

    if (oxi > 60 * n) {
      oxi = 60 * n;
      t = sum - oxi;
    }

    if (oxi < 0 || oxi > 60 * n || t > 30 || t < 0) {
      return [-1];
    }

    sum *= (oxi * 7 * day + (10 * e(t)) / 11).round();
    return [ans, oxi, (dist / v).round(), t, n];
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

    pointsListText.add(
      SizedBox(
        height: 50,
      ),
    );

    double v = 2.0;
    for (; v > 0.0; v -= 0.001) {
      int dist = result_points[0].distance;
      int sh = result_points[0].SH + 8;

      int ans = z(dist, v, sh)[0];
      if (ans != -1) break;
    }

    print(v);

    pointsListText.add(
      Text(
        "Скорость: " + v.toString(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );

    pointsListText.add(
      Text(
        "Количество затрат: " +
            z(result_points[0].distance, v, result_points[0].SH + 8)[0]
                .toString(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );

    pointsListText.add(
      Text(
        "Количество кислорода: " +
            z(result_points[0].distance, v, result_points[0].SH + 8)[1]
                .toString(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );

    pointsListText.add(
      Text(
        "Время на перелёт: " +
            z(result_points[0].distance, v, result_points[0].SH + 8)[2]
                .toString(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );

    pointsListText.add(
      Text(
        "Температура сейчас: " +
            z(result_points[0].distance, v, result_points[0].SH + 8)[3]
                .toString(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );

    pointsListText.add(
      Text(
        "Единиц SH сейчас: " +
            z(result_points[0].distance, v, result_points[0].SH + 8)[4]
                .toString(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );

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

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:earth_online_map/auth_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

const String apiKey = '65bf2e32d1b62736046899szn1f7aa8';
const String appId = '69f869397f5902fdf99a6780001bbd03';

class AddNewCityInput extends ConsumerStatefulWidget {
  final AnimatedMapController animatedMapController;

  const AddNewCityInput({
    Key? key,
    required this.animatedMapController,
  }) : super(key: key);

  @override
  ConsumerState<AddNewCityInput> createState() => _AddNewCityInputState();
}

class _AddNewCityInputState extends ConsumerState<AddNewCityInput> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';

  Future<void> _getCityData() async {
    final String cityName = _controller.text;
    final String url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$appId';
    // 'https://geocode.maps.co/search?q=$cityName&api_key=$apiKey';
    final Uri uri = Uri.parse(url);
    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      setState(() {
        _errorMessage = 'City not found';
      });
      return;
    }
    final List<dynamic> data = json.decode(response.body);
    if (data.isNotEmpty) {
      var city = data[0];
      var db = FirebaseFirestore.instance;
      db.collection('cities').add({
        'name': city['name'],
        'latlng': GeoPoint(city['lat'], city['lon']),
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _controller.text = '';
        _errorMessage = '';
      });
      widget.animatedMapController
          .animateTo(dest: LatLng(city['lat'], city['lon']), zoom: 10.0);
    } else {
      setState(() {
        _errorMessage = 'City not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(authProvider);
    if (user.isLoading) {
      return Container();
    }
    if (user.value == null) {
      return Container();
    }
    return SizedBox(
      width: 200,
      height: 60,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: _errorMessage != '' ? _errorMessage : 'Enter city name',
          suffixIcon: IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () {
              _getCityData();
            },
          ),
        ),
      ),
    );
  }
}

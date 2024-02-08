import 'dart:async';

import 'package:earth_online_map/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const double initialZoom = 8.0;
const LatLng initialCenter = LatLng(23.5, 121.0);

class MyMap extends ConsumerStatefulWidget {
  const MyMap({super.key});

  @override
  ConsumerState<MyMap> createState() => _MyMapState();
}

class _MyMapState extends ConsumerState<MyMap> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  late StreamSubscription _subscription;
  List<Marker> markers = [];
  late MapController mapController;
  double markerClusterSize = 50;

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    final collectionRef = db.collection("cities");
    _subscription = collectionRef.snapshots().listen((snapshot) {
      var newMarkers = <Marker>[];
      for (var doc in snapshot.docs) {
        newMarkers.add(buildMarker(doc.id, doc.data()));
      }
      setState(() {
        markers = newMarkers;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  removeMarker(String id) async {
    var user = ref.read(authProvider);
    if (user.value == null) {
      return;
    }
    db.collection('cities').doc(id).delete();
  }

  Marker buildMarker(String id, Map<String, dynamic> data) {
    String name = data['name'];
    GeoPoint geoPoint = data['latlng'];

    return Marker(
      width: 40,
      height: 40,
      point: LatLng(geoPoint.latitude, geoPoint.longitude),
      child: Center(
        child: Tooltip(
          message: name,
          child: InkWell(
            child: Image.asset(
              "assets/images/flag.gif",
              height: 64.0,
              width: 64.0,
            ),
            // child: const Icon(
            //   Icons.flag,
            //   color: Colors.white,
            // ),
            onLongPress: () {
              removeMarker(id);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'space.awesomejerry.earthonline.map',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                markers: markers,
                size: Size(markerClusterSize, markerClusterSize),
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(markerClusterSize / 2),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge
                              ?.color,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright')),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_circle_up),
                onPressed: () {
                  mapController.rotate(0.0);
                },
              ),
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  mapController.move(initialCenter, initialZoom);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

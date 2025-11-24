import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodel/map_viewmodel.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ponto de coleta"),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: Column(
        children: [
          Expanded(
            child: viewModel.points.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: viewModel.center,
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(
                        markers: viewModel.points
                            .map(
                              (p) => Marker(
                                point: LatLng(p.latitude, p.longitude),
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

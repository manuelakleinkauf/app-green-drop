import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodel/map_viewmodel.dart';

class MapPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Ponto de coleta")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nome do ponto"),
                ),
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(labelText: "Rua"),
                ),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: "Número"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: neighborhoodController,
                  decoration: const InputDecoration(labelText: "Bairro"),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "Cidade"),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    String fullAddress =
                        "${streetController.text}, ${numberController.text}, ${neighborhoodController.text}, ${cityController.text}";

                    await viewModel.addPoint(
                      nameController.text,
                      fullAddress,
                      '', // description
                      ['Eletrônicos'], // accepted items
                      'voluntário', // created by
                    );

                    // Limpa os campos após adicionar
                    nameController.clear();
                    streetController.clear();
                    numberController.clear();
                    neighborhoodController.clear();
                    cityController.clear();
                  },
                  child: const Text("Adicionar ponto"),
                ),
              ],
            ),
          ),
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

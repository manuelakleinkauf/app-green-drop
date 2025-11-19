import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/map_viewmodel.dart';
import '../viewmodel/current_user_provider.dart';
import 'components/collection_point_form.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final cityController = TextEditingController();
  final descriptionController = TextEditingController();
  final List<String> selectedItems = [];

  @override
  void dispose() {
    nameController.dispose();
    streetController.dispose();
    numberController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String getFullAddress() {
    return "${streetController.text}, ${numberController.text}, ${neighborhoodController.text}, ${cityController.text}";
  }

  void clearForm() {
    nameController.clear();
    streetController.clear();
    numberController.clear();
    neighborhoodController.clear();
    cityController.clear();
    descriptionController.clear();
    selectedItems.clear();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);
    final userProvider = Provider.of<CurrentUserProvider>(context);

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
      floatingActionButton: userProvider.canCreateCollectionPoint
          ? FloatingActionButton(
              onPressed: () => _showAddPointDialog(context, viewModel),
              backgroundColor: const Color(0xFF00897B),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _showAddPointDialog(BuildContext context, MapViewModel viewModel) async {
    clearForm();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Ponto de Coleta'),
        content: SingleChildScrollView(
          child: CollectionPointForm(
            formKey: _formKey,
            nameController: nameController,
            streetController: streetController,
            numberController: numberController,
            neighborhoodController: neighborhoodController,
            cityController: cityController,
            descriptionController: descriptionController,
            selectedItems: selectedItems,
            onSelectedItemsChanged: () {
              setState(() {});
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && selectedItems.isNotEmpty) {
                try {
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
                  
                  await viewModel.addPoint(
                    nameController.text,
                    getFullAddress(),
                    descriptionController.text,
                    List<String>.from(selectedItems),
                    currentUserId,
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ponto de coleta adicionado com sucesso!')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao adicionar ponto: $e')),
                  );
                }
              } else if (selectedItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecione pelo menos um item aceito')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

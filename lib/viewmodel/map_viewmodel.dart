import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/collection_point.dart';

class MapViewModel extends ChangeNotifier {
  LatLng _center = LatLng(-23.5505, -46.6333);
  LatLng get center => _center;

  final List<CollectionPoint> _points = [];
  List<CollectionPoint> get points => _points;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MapViewModel() {
    _listenToFirestorePoints();
  }

  void _listenToFirestorePoints() {
    _firestore.collection('collection_points').snapshots().listen((snapshot) {
      print("Atualizando pontos do Firebase... Total: ${snapshot.docs.length}");

      _points.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final lat = double.tryParse(data['latitude'].toString());
        final lon = double.tryParse(data['longitude'].toString());

        if (lat != null && lon != null) {
          _points.add(
            CollectionPoint(
              id: doc.id,
              name: data['name'] ?? 'Sem nome',
              address: data['address'] ?? 'Sem endereço',
              latitude: lat,
              longitude: lon,
            ),
          );
        }
      }

      if (_points.isNotEmpty) {
        _center = LatLng(_points.last.latitude, _points.last.longitude);
      }

      notifyListeners();
    });
  }

  Future<void> addPoint(String name, String fullAddress) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$fullAddress&format=json&limit=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'flutter_app'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);

        final point = CollectionPoint(
          id: '',
          name: name,
          address: fullAddress,
          latitude: lat,
          longitude: lon,
        );

        await _firestore.collection('collection_points').add(point.toMap());

        print("Ponto salvo no Firebase: $name ($lat, $lon)");
      } else {
        print(" Nenhum resultado encontrado para o endereço.");
      }
    } else {
      print("Erro na API do Nominatim: ${response.statusCode}");
    }
  }
}

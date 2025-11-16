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
  bool isLoading = false;

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
        final point = CollectionPoint.fromMap(data, doc.id);
        _points.add(point);
      }

      if (_points.isNotEmpty) {
        _center = LatLng(_points.last.latitude, _points.last.longitude);
      }

      notifyListeners();
    });
  }

  Future<void> addPoint(
    String name,
    String address,
    String description,
    List<String> acceptedItems,
    String createdBy,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1',
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
            address: address,
            latitude: lat,
            longitude: lon,
            description: description,
            acceptedItems: acceptedItems,
            createdBy: createdBy,
            createdAt: DateTime.now(),
          );

          await _firestore.collection('collection_points').add(point.toMap());
          print("Ponto salvo no Firebase: $name ($lat, $lon)");
        } else {
          throw Exception('Endereço não encontrado');
        }
      } else {
        throw Exception('Erro ao geocodificar endereço');
      }
    } catch (e) {
      print("Erro ao adicionar ponto: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePoint(CollectionPoint point) async {
    isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection('collection_points')
          .doc(point.id)
          .update(point.toMap());
    } catch (e) {
      print("Erro ao atualizar ponto: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePointStatus(String pointId, bool isActive) async {
    isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection('collection_points')
          .doc(pointId)
          .update({'isActive': isActive});
    } catch (e) {
      print("Erro ao alterar status do ponto: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

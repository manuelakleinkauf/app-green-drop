import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/collection_point.dart';

class MapViewModel extends ChangeNotifier {
  LatLng _center = LatLng(-23.5505, -46.6333);
  LatLng get center => _center;

  // Lista de pontos ativos (para o mapa)
  final List<CollectionPoint> _activePoints = [];
  List<CollectionPoint> get points => _activePoints;

  // Lista de todos os pontos (para gestão)
  final List<CollectionPoint> _allPoints = [];
  List<CollectionPoint> get allPoints => _allPoints;

  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MapViewModel() {
    _listenToActivePoints();
    _listenToAllPoints();
  }

  // Listener para pontos ativos (usado no mapa)
  void _listenToActivePoints() {
    _firestore.collection('collection_points')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _activePoints.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final point = CollectionPoint.fromMap(data, doc.id);
        _activePoints.add(point);
      }

      if (_activePoints.isNotEmpty) {
        _center = LatLng(_activePoints.last.latitude, _activePoints.last.longitude);
      }

      notifyListeners();
    });
  }

  // Listener para todos os pontos (usado na gestão)
  void _listenToAllPoints() {
    _firestore.collection('collection_points').snapshots().listen((snapshot) {
      _allPoints.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final point = CollectionPoint.fromMap(data, doc.id);
        _allPoints.add(point);
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
      final encodedAddress = Uri.encodeComponent(address);
      
      // Tentar diferentes métodos de geocodificação
      Map<String, dynamic>? geocodeResult;
      
      // Método 1: AllOrigins proxy
      try {
        final allOriginsUrl = Uri.parse(
          'https://api.allorigins.win/get?url=${Uri.encodeComponent('https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1')}'
        );
        
        final response1 = await http.get(
          allOriginsUrl,
          headers: {'User-Agent': 'GreenDropApp/1.0'},
        ).timeout(const Duration(seconds: 10));
        
        if (response1.statusCode == 200) {
          final wrapper = json.decode(response1.body);
          final data = json.decode(wrapper['contents']);
          if (data.isNotEmpty) {
            geocodeResult = data[0];
            print("Geocodificação bem-sucedida via AllOrigins");
          }
        }
      } catch (e) {
        print("AllOrigins falhou: $e");
      }
      
      // Método 2: CORS Anywhere alternativo
      if (geocodeResult == null) {
        try {
          final corsAnywhereUrl = Uri.parse(
            'https://api.codetabs.com/v1/proxy?quest=https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1'
          );
          
          final response2 = await http.get(
            corsAnywhereUrl,
            headers: {'User-Agent': 'GreenDropApp/1.0'},
          ).timeout(const Duration(seconds: 10));
          
          if (response2.statusCode == 200) {
            final data = json.decode(response2.body);
            if (data.isNotEmpty) {
              geocodeResult = data[0];
              print("Geocodificação bem-sucedida via CodeTabs");
            }
          }
        } catch (e) {
          print("CodeTabs falhou: $e");
        }
      }
      
      // Método 3: Coordenadas padrão para endereços brasileiros comuns
      if (geocodeResult == null) {
        print("Usando coordenadas aproximadas baseadas no endereço");
        // Extrair cidade do endereço
        final addressLower = address.toLowerCase();
        
        // Coordenadas de cidades brasileiras comuns
        final cityCoordinates = {
          'taquara': {'lat': -29.6478, 'lon': -50.7806},
          'porto alegre': {'lat': -30.0346, 'lon': -51.2177},
          'são paulo': {'lat': -23.5505, 'lon': -46.6333},
          'rio de janeiro': {'lat': -22.9068, 'lon': -43.1729},
          'belo horizonte': {'lat': -19.9167, 'lon': -43.9345},
          'brasília': {'lat': -15.8267, 'lon': -47.9218},
          'curitiba': {'lat': -25.4284, 'lon': -49.2733},
          'salvador': {'lat': -12.9714, 'lon': -38.5014},
          'fortaleza': {'lat': -3.7172, 'lon': -38.5434},
          'recife': {'lat': -8.0476, 'lon': -34.8770},
        };
        
        for (var city in cityCoordinates.keys) {
          if (addressLower.contains(city)) {
            geocodeResult = cityCoordinates[city];
            print("Usando coordenadas aproximadas para $city");
            break;
          }
        }
        
        // Se não encontrar cidade conhecida, usar coordenadas padrão (São Paulo)
        if (geocodeResult == null) {
          geocodeResult = {'lat': -23.5505, 'lon': -46.6333};
          print("Usando coordenadas padrão (São Paulo)");
        }
      }

      // Processar coordenadas e salvar ponto
      final lat = geocodeResult['lat'] is String 
          ? double.parse(geocodeResult['lat']) 
          : geocodeResult['lat'].toDouble();
      final lon = geocodeResult['lon'] is String 
          ? double.parse(geocodeResult['lon']) 
          : geocodeResult['lon'].toDouble();

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

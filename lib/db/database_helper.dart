import '../model/collection_point.dart';

class DatabaseHelper {
  final List<CollectionPoint> _points = [];

  List<CollectionPoint> getAllPoints() => _points;

  void addPoint(CollectionPoint point) {
    _points.add(point);
  }
}

import 'dart:math';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:club_fitness/core/services/url_services.dart';
import 'package:club_fitness/core/utils/utils.dart';

class LocationServices {
  static final LocationServices _locationService = LocationServices._();

  factory LocationServices() => _locationService;

  LocationServices._();

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  static double distanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static double estimateTravelHours(double distanceKm, String mode) {
    final speeds = {
      'walking': 3.0, // km/h
      'cycling': 8.0,
      'driving': 35.0, // assumes mixed city/highway
      'highway': 60.0,
    };

    double speed = speeds[mode] ?? 35.0;
    return distanceKm / speed;
  }

  Future<Placemark> getPlaceMark([double? latitude, double? longitude]) async {
    double fnLatitude = latitude ?? 0.0;
    double fnLongitude = longitude ?? 0.0;
    Position? position;
    if (fnLatitude == 0.0 || fnLongitude == 0.0) {
      position = await getCurrentPosition();
      fnLatitude = position?.latitude ?? fnLatitude;
      fnLongitude = position?.longitude ?? fnLongitude;
    }
    List<Placemark> placemarks = await placemarkFromCoordinates(
      fnLatitude,
      fnLongitude,
    );
    Placemark place = placemarks[0];
    return place;
  }

  String getReadablePlaceName(Placemark place, {String separator = ', '}) {
    final candidates = [
      place.name,
      place.street,
      place.subLocality,
      place.locality,
      place.subAdministrativeArea,
      place.administrativeArea,
      place.country,
    ];

    final parts = candidates
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .toList();

    if (parts.isEmpty) return 'Unknown Location';

    // Deduplicate adjacent duplicates (e.g. locality == subAdministrativeArea)
    final deduped = <String>[];
    for (final part in parts) {
      if (deduped.isEmpty || deduped.last.toLowerCase() != part.toLowerCase()) {
        deduped.add(part);
      }
    }

    // Return top 2 most specific parts for a clean "name1, name2" format
    return deduped.take(2).join(separator);
  }

  Future<String> getReadableLocation([
    double? latitude,
    double? longitude,
  ]) async {
    final place = await getPlaceMark(latitude, longitude);
    return getReadablePlaceName(place);
  }

  Future<String?> tryGetReadableLocation([
    double? latitude,
    double? longitude,
  ]) async {
    try {
      return await getReadableLocation(latitude, longitude);
    } catch (_) {
      return null;
    }
  }

  static String getMapPreviewImageUrl(
    double latitude,
    double longitude, {
    int zoom = 15,
  }) {
    final x = ((longitude + 180) / 360 * (1 << zoom)).floor();
    final latRad = latitude * pi / 180;
    final y = ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * (1 << zoom))
        .floor();
    return 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
  }

  static bool invalidLocation(double? latitude, double? longitude) {
    return latitude == 0.0 ||
        longitude == 0.0 ||
        latitude == null ||
        longitude == null;
  }

  static const String googleMapsApiKey =
      'AIzaSyBRATvAH0HEfWRgSQYM3i_itPytPlm62Mw';

  static String staticMapUrl(double? latitude, double? longitude) {
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$latitude,$longitude'
        '&zoom=15'
        '&size=600x300'
        '&markers=color:red%7C$latitude,$longitude'
        '&key=$googleMapsApiKey';
  }

  static String showCityView({String? locality, String? city}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$locality,$city&zoom=15&size=600x300&markers=color:red%7C$locality,$city&key=$googleMapsApiKey';
  }

  static void openGoogleMapsCity(String query) {
    final url = "https://www.google.com/maps/search/?api=1&query=$query";
    UrlServices.launchRegularUrl(url);
  }

  static void openGoogleMaps(double? latitude, double? longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    UrlServices.launchRegularUrl(url);
  }

  static String formatLocation(String? locality, String? city) {
    if (locality == null && city == null) return '';
    if (locality?.isEmpty ?? true) return city!.capitalizeFirst;
    if (city?.isEmpty ?? true) return locality!.capitalizeFirst;
    if (locality == city) return locality!;
    return '${locality!.capitalizeFirst}, ${city!.capitalizeFirst}';
  }

  static String formatLatLng(dynamic lat, dynamic lng) {
    if (lat == null || lng == null) return '';
    final latitude = lat.toString().toNum.toDouble();
    final longitude = lng.toString().toNum.toDouble();
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';

    final latAbs = latitude.abs().toStringAsFixed(4);
    final lngAbs = longitude.abs().toStringAsFixed(4);

    return '$latAbs° $latDir, $lngAbs° $lngDir';
  }
}

extension TravelTimeExtension on num {
  num estimateTravelHours({String mode = 'driving'}) {
    return LocationServices.estimateTravelHours(toDouble(), mode);
  }

  num estimateTravelMinutes({String mode = 'driving'}) {
    return LocationServices.estimateTravelHours(toDouble(), mode) * 60;
  }

  String estimateTravelTime({String mode = 'driving'}) {
    final hours = LocationServices.estimateTravelHours(toDouble(), mode);
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '${minutes.roundAsFixedString(2)} mins';
    } else {
      return '${hours.roundAsFixedString(2)} hrs';
    }
  }
}

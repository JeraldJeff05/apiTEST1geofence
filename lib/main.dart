import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart'; // Import the new file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LocationPage(),
    );
  }
}

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String? lat; // Renamed variable for latitude
  String? lng; // Renamed variable for longitude
  String message = "Click the button to get location";
  String apiResponse = ""; // To display the API response

  final ApiService apiService = ApiService();

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        message = "Location services are disabled. Please enable them.";
      });
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          message = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        message =
            "Location permissions are permanently denied. We cannot request permissions.";
      });
      return;
    }

    // Fetch the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude.toString();
      lng = position.longitude.toString();
      message = "Location fetched successfully!";
    });

    // Send coordinates to the API
    if (lat != null && lng != null) {
      String response = await apiService.sendCoordinates(lat!, lng!);
      setState(() {
        apiResponse = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Fetcher'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLocation,
              child: Text('Get Location'),
            ),
            SizedBox(height: 20),
            if (lat != null && lng != null)
              Column(
                children: [
                  Text(
                    "Latitude: $lat",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Longitude: $lng",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (apiResponse.isNotEmpty)
              Text(
                "API Response: $apiResponse",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}

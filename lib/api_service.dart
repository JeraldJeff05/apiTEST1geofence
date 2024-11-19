import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiUrl =
      "http://192.168.120.45:8080/geofence/check"; // Replace with your API URL

  Future<String> sendCoordinates(String lat, String lng) async {
    try {
      // Validate latitude and longitude values
      if (lat.isEmpty || lng.isEmpty) {
        return "Latitude and Longitude cannot be empty";
      }

      // Concatenate latitude and longitude as query parameters in the URL
      final url = Uri.parse("$_apiUrl?lat=$lat&lng=$lng");

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      // Check if status code is 200
      if (response.statusCode == 200) {
        // If response body is "true", return "Location is allowed"
        if (response.body.trim().toLowerCase() == 'true') {
          return "Location is allowed";
        }
        // If response body is "false", return "Location not allowed"
        else if (response.body.trim().toLowerCase() == 'false') {
          return "Location not allowed";
        } else {
          return "Unexpected response: ${response.body}";
        }
      } else {
        // Return error response if status code is not 200
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      // Return error if exception occurs
      return "Error: $e";
    }
  }
}

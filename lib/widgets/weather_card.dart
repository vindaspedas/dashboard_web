import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location & Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Kota Kinabalu",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Saturday, May 3",
                  style: TextStyle(color: Colors.grey[700])),
            ],
          ),

          // Main Weather Info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny,
                  size: 40, color: Colors.orange),
              const SizedBox(height: 8),
              Text("30°C",
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),

          // Extra Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Humidity: 70%",
                  style: TextStyle(fontSize: 16)),
              Text("Wind: 12 km/h",
                  style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
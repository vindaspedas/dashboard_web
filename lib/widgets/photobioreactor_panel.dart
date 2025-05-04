import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'carbon_chart.dart';
import '../models/photobioreactor.dart';

class PhotobioreactorPanel extends StatelessWidget {
  final List<Photobioreactor> reactors = [
    Photobioreactor(id: 1, name: 'Photobioreactor 1', isOnline: true),
    Photobioreactor(id: 2, name: 'Photobioreactor 2', isOnline: false),
    Photobioreactor(id: 3, name: 'Photobioreactor 3', isOnline: true),
    Photobioreactor(id: 4, name: 'Photobioreactor 4', isOnline: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Photobioreactors",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: reactors.length,
              itemBuilder: (context, index) {
                final reactor = reactors[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: reactor.isOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        reactor.name,
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        reactor.isOnline ? "Online" : "Offline",
                        style: TextStyle(
                          color: reactor.isOnline ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  final int selectedIndex;
  final List<String> menuTitles;
  final Function(bool) onCollapsedChanged;
  final Function(int) onSelectedIndexChanged;

  const Sidebar({
    Key? key,
    required this.isCollapsed,
    required this.selectedIndex,
    required this.menuTitles,
    required this.onCollapsedChanged,
    required this.onSelectedIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: isCollapsed ? 70 : 240,
      color: Colors.blueGrey[900],
      child: Column(
        children: [
          const SizedBox(height: 32),
          IconButton(
            icon: Icon(isCollapsed ? Icons.menu : Icons.close, color: Colors.white),
            onPressed: () => onCollapsedChanged(!isCollapsed),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: menuTitles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                IconData icon;
                switch (index) {
                  case 0:
                    icon = FontAwesomeIcons.house;
                    break;
                  case 1:
                    icon = FontAwesomeIcons.seedling;
                    break;
                  case 2:
                    icon = FontAwesomeIcons.gear;
                    break;
                  case 3:
                    icon = FontAwesomeIcons.stethoscope;
                  case 4:
                    icon = FontAwesomeIcons.calendarDays;
                  default:
                    icon = FontAwesomeIcons.circle;
                }

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  leading: FaIcon(icon, color: Colors.white, size: 20),
                  title: isCollapsed
                      ? null
                      : Text(menuTitles[index], style: TextStyle(color: Colors.white)),
                  onTap: () => onSelectedIndexChanged(index),
                  selected: selectedIndex == index,
                  selectedTileColor: Colors.blueGrey[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class SidebarListTile extends StatelessWidget {
  final String title;

  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  const SidebarListTile(
      {super.key,
      required this.title,

      required this.icon,
      this.iconColor,
      this.backgroundColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
      child: Container(
        
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), 
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(2),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

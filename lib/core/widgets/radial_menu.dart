import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Radial Menu Overlay Widget
/// Displays menu items in semicircle arc above navigation bar
class RadialMenuOverlay extends StatefulWidget {
  final List<RadialMenuItem> items;
  final double radius;

  const RadialMenuOverlay({
    super.key,
    required this.items,
    this.radius = 100,
  });

  @override
  State<RadialMenuOverlay> createState() => RadialMenuOverlayState();
}

class RadialMenuOverlayState extends State<RadialMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Toggle menu open/close
  void toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  /// Close menu
  void close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOpen) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Full screen overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: close,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),

        // Menu Items in Semicircle
        ..._buildMenuItems(),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    final items = <Widget>[];
    final itemCount = widget.items.length;
    final screenWidth = MediaQuery.of(context).size.width;

    for (int i = 0; i < itemCount; i++) {
      // Calculate angle for semicircle (180 degrees)
      // Start from left (180°) to right (0°)
      final angle = math.pi - (math.pi * i / (itemCount - 1));

      items.add(_buildMenuItem(widget.items[i], angle, i, screenWidth));
    }

    return items;
  }

  Widget _buildMenuItem(
    RadialMenuItem item,
    double angle,
    int index,
    double screenWidth,
  ) {
    // Animation for each item with delay
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        index * 0.1,
        1.0,
        curve: Curves.easeOutBack,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final distance = widget.radius * progress;

        // Calculate position on semicircle (upward arc)
        final dx = math.cos(angle) * distance;
        final dy = math.sin(angle) * distance;

        return Positioned(
          left: (screenWidth / 2) + dx - 28, // Center horizontally
          bottom: 100 + dy, // Position above navigation bar + FAB
          child: Transform.scale(
            scale: progress,
            child: Opacity(
              opacity: progress,
              child: _MenuButton(
                item: item,
                onTap: () {
                  close();
                  item.onTap();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Menu Button Widget
class _MenuButton extends StatelessWidget {
  final RadialMenuItem item;
  final VoidCallback onTap;

  const _MenuButton({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 6,
          shape: const CircleBorder(),
          color: item.backgroundColor,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

/// Radial Menu Item Model
class RadialMenuItem {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const RadialMenuItem({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });
}

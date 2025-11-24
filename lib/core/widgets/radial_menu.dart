import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Radial Menu Widget
/// Creates a semicircle/arc menu with animated buttons
class RadialMenu extends StatefulWidget {
  final List<RadialMenuItem> items;
  final double radius;
  final Color backgroundColor;
  final IconData icon;
  final IconData activeIcon;

  const RadialMenu({
    super.key,
    required this.items,
    this.radius = 100,
    this.backgroundColor = Colors.blue,
    this.icon = Icons.add,
    this.activeIcon = Icons.close,
  });

  @override
  State<RadialMenu> createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
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

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Full screen overlay (only when open)
        if (_isOpen)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

        // Menu Items in Semicircle (positioned above FAB)
        if (_isOpen)
          Positioned(
            left: 0,
            right: 0,
            bottom: 70, // Position above the navigation bar
            child: Center(
              child: SizedBox(
                width: widget.radius * 2.5,
                height: widget.radius * 1.3,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: _buildMenuItems(),
                ),
              ),
            ),
          ),

        // Center FAB (embedded in navigation bar)
        _buildCenterButton(),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    final items = <Widget>[];
    final itemCount = widget.items.length;

    for (int i = 0; i < itemCount; i++) {
      // Calculate angle for semicircle (180 degrees)
      // Start from left (180°) to right (0°)
      final angle = math.pi - (math.pi * i / (itemCount - 1));

      items.add(_buildMenuItem(widget.items[i], angle, i));
    }

    return items;
  }

  Widget _buildMenuItem(RadialMenuItem item, double angle, int index) {
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
          left: (widget.radius * 2.5) / 2 + dx - 28,
          bottom: dy, // Position from bottom upward
          child: Transform.scale(
            scale: progress,
            child: Opacity(
              opacity: progress,
              child: _MenuButton(
                item: item,
                onTap: () {
                  _toggle();
                  item.onTap();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterButton() {
    return FloatingActionButton(
      onPressed: _toggle,
      backgroundColor: widget.backgroundColor,
      elevation: _isOpen ? 12 : 8,
      child: AnimatedRotation(
        turns: _isOpen ? 0.125 : 0.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        child: Icon(
          _isOpen ? widget.activeIcon : widget.icon,
          color: Colors.white,
          size: 28,
        ),
      ),
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

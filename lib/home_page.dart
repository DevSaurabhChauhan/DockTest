

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Dock(
          items: const [
            Icons.person,
            Icons.message,
            Icons.call,
            Icons.camera,
            Icons.photo,
          ],
          builder: (e, isDragging) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              constraints: const BoxConstraints(minWidth: 48),
              height: 48,
              margin: const EdgeInsets.all(8),
              curve: Curves.easeIn,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDragging ? Colors.grey[400] : Colors.primaries[e.hashCode % Colors.primaries.length],
              ),
              child: Center(child: Icon(e, color: Colors.white)),
            );
          },
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<IconData> items;
  final Widget Function(IconData, bool) builder;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late final List<IconData> _items = widget.items.toList();
  IconData? _draggingItem;
  int _draggingIndex = -1;

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildDraggableItem(item, index);
        }).toList(),
      ),
    );
  }

  Widget _buildDraggableItem(IconData item, int index) {
    return LongPressDraggable<IconData>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: widget.builder(item, true),
      ),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () => setState(() {
        _draggingItem = item;
        _draggingIndex = index;
      }),
      onDragEnd: (_) => setState(() {
        _draggingItem = null;
        _draggingIndex = -1;
      }),
      child: DragTarget(
        onAccept: (receivedItem) {
          if (_draggingIndex >= 0) {
            _onReorder(_draggingIndex, index);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            child: widget.builder(item, false),
          );
        },
      ),
    );
  }
}
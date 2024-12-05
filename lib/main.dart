import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (context, item, isHovered, index, hoveredIndex, proximityScale) {
              final matrix = Functions.calculateMatrix(index, hoveredIndex, isHovered);
              return AnimatedContainer(
                transform: matrix,
                curve: Curves.easeOut,
                margin: const EdgeInsets.all(8),
                duration: const Duration(milliseconds: 200),
                height: isHovered ? (48 + proximityScale * 16) : 48,
                constraints: BoxConstraints(minWidth: isHovered ? (48 + proximityScale * 16) : 48),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[item.hashCode % Colors.primaries.length],
                  boxShadow: [
                    isHovered
                        ? const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                        : const BoxShadow(color: Colors.transparent),
                  ],
                ),
                child: Center(
                  child: Icon(item, color: Colors.white, size: isHovered ? (24 + proximityScale * 16) : 24),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(BuildContext, T, bool isHovered, int index, int hoveredIndex, double proximityScale) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// Hovered [T] item and its index.
  T? _hoveredItem;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final proximityScale = Functions.calculateScale(index, _hoveredIndex);

          return Draggable<T>(
            data: item,
            feedback: widget.builder(context, item, true, index, _hoveredIndex ?? -1, proximityScale),
            childWhenDragging: const SizedBox.shrink(),
            onDragStarted: () => onDragStartedDo(item),
            onDraggableCanceled: (_, __) => onDraggableCancelledDo(),
            onDragEnd: (details) => onDragEndDo(details, index, item),
            child: MouseRegion(
              onEnter: (_) => onEnterDo(index, item),
              onExit: (_) => onExitDo(),
              child: widget.builder(context, item, _hoveredItem == item, index, _hoveredIndex ?? -1, proximityScale),
            ),
          );
        }).toList(),
      ),
    );
  }

  void onDragStartedDo(T item) {
    setState(() => _hoveredItem = item);
  }

  void onDraggableCancelledDo() {
    setState(() => _hoveredItem = null);
  }

  void onDragEndDo(DraggableDetails details, int index, T item) {
    final newIndex = Functions.getDropIndex(context, details.offset, _items);
    if (newIndex != index) {
      setState(() {
        _items.removeAt(index);
        _items.insert(newIndex, item);
      });
    }
    setState(() => _hoveredItem = null);
  }

  void onEnterDo(int index, T item) {
    setState(() {
      _hoveredItem = item;
      _hoveredIndex = index;
    });
  }

  void onExitDo() {
    setState(() {
      _hoveredItem = null;
      _hoveredIndex = null;
    });
  }
}

abstract class Functions {
  /// Calculates the transformation matrix for an item based on its index
  static Matrix4 calculateMatrix(int index, hoveredIndex, isHovered) {
    final hoveredMatrix = Matrix4.identity()..translate(0.0, -10.0, 0.0);
    final nearMatrix = Matrix4.identity()..translate(0.0, -5.0, 0.0);
    final defaultMatrix = Matrix4.identity()..translate(0.0, 0.0, 0.0);

    Matrix4 transformMatrix = defaultMatrix;

    if (index == 0 && !isHovered) {
      transformMatrix = defaultMatrix;
    } else if (isHovered) {
      transformMatrix = hoveredMatrix;
    } else if ((index == hoveredIndex - 1) || (index == hoveredIndex + 1)) {
      transformMatrix = nearMatrix;
    }

    return transformMatrix;
  }

  /// Computes the scale factor for an item based on its distance from the hovered item
  static double calculateScale(int index, int? hoveredIndex) {
    if (hoveredIndex == null) return 0.0;

    final distance = (index - hoveredIndex).abs();
    if (distance > 2) return 0.0; // Limit scaling to 2 items away

    return 1.0 - (distance / 2); // Scale decreases with distance
  }

  /// Determines the index where a dragged item should be dropped based on its horizontal position
  static int getDropIndex(BuildContext context, Offset offset, List items) {
    final renderBox = context.findRenderObject() as RenderBox;
    final dockPosition = renderBox.localToGlobal(Offset.zero);
    final relativeX = offset.dx - dockPosition.dx;

    // Dynamically compute item width and center positions
    final itemWidth = renderBox.size.width / items.length;

    // Calculate the centers of all items
    final centers = List.generate(
      items.length,
      (i) => (i + 0.5) * itemWidth,
    );

    // Find the closest center to the drop position
    int index = centers.indexWhere((center) => relativeX <= center);
    if (index == -1) {
      // If no valid center was found (dropped beyond the last item), snap to the last index
      index = items.length - 1;
    }

    return index;
  }
}

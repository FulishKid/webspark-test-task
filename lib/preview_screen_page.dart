import 'package:flutter/material.dart';

class PreviewScreen extends StatelessWidget {
  final String pathString;
  final List<List<int>>? field;

  const PreviewScreen({
    super.key,
    required this.pathString,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    if (field == null || field!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preview screen'),
        ),
        body: const Center(
          child: Text('Field data is unavailable'),
        ),
      );
    }

    final int rows = field!.length;
    final int cols = field![0].length;

    final List<String> pathPoints = pathString.split('->');
    final start = pathPoints.first;
    final end = pathPoints.last;

    for (var point in pathPoints) {
      final coordinates =
          point.replaceAll('(', '').replaceAll(')', '').split(',');
      final int x = int.parse(coordinates[0]);
      final int y = int.parse(coordinates[1]);
      field![x][y] = 4; // Комірка найкоротшого шляху
    }

    final startCoordinates =
        start.replaceAll('(', '').replaceAll(')', '').split(',');
    final int startX = int.parse(startCoordinates[0]);
    final int startY = int.parse(startCoordinates[1]);

    final endCoordinates =
        end.replaceAll('(', '').replaceAll(')', '').split(',');
    final int endX = int.parse(endCoordinates[0]);
    final int endY = int.parse(endCoordinates[1]);

    field![startX][startY] = 3; // Початкова комірка
    field![endX][endY] = 2; // Кінцева комірка

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final int x = index ~/ cols;
                  final int y = index % cols;

                  Color cellColor;
                  Color textColor = Colors.black;
                  switch (field![x][y]) {
                    case 0:
                      cellColor = Colors.black; // Комірка-пастка
                      textColor = Colors.white; // Білий текст на чорній комірці
                      break;
                    case 2:
                      cellColor = const Color(0xFF009688); // Кінцева комірка
                      break;
                    case 3:
                      cellColor = const Color(0xFF64FFDA); // Початкова комірка
                      break;
                    case 4:
                      cellColor =
                          const Color(0xFF4CAF50); // Комірка найкоротшого шляху
                      break;
                    default:
                      cellColor = Colors.white; // Порожня комірка
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                      color: cellColor,
                    ),
                    child: Center(
                      child: Text(
                        '($x,$y)',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(pathString),
            ),
          ],
        ),
      ),
    );
  }
}

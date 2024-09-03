import 'package:flutter_app/path_slover.dart';

class TaskProcessor {
  final Map<String, Map<String, int>> fieldSizes = {};
  final Map<String, List<List<int>>> fields = {};
  List<Map<String, dynamic>> processTasks(List<dynamic> tasks) {
    final List<Map<String, dynamic>> results = [];

    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final field = convertField(task['field'].cast<String>());
      final start = Point(task['start']['x'], task['start']['y']);
      final end = Point(task['end']['x'], task['end']['y']);

      final solver = ShortestPathSolver(field);
      final path = solver.findShortestPath(start, end);

      final steps = path
          .map((point) => {'x': point.x.toString(), 'y': point.y.toString()})
          .toList();
      final pathString = path.join('->');

      final gridSize = {
        'rows': field.length,
        'cols': field[0].length,
      };

      results.add({
        'id': task['id'],
        'result': {
          'steps': steps,
          'path': pathString,
        },
      });

      fieldSizes[task['id']] = gridSize; // Зберігаємо розмір поля у мапі
      fields[task['id']] = field;
    }

    return results;
  }

  Map<String, Map<String, int>> getFieldSizes() {
    return fieldSizes;
  }

  Map<String, List<List<int>>> getFields() {
    return fields;
  }
}

List<List<int>> convertField(List<String> field) {
  List<List<int>> result = [];

  for (String row in field) {
    List<int> newRow = [];
    for (int i = 0; i < row.length; i++) {
      newRow.add(row[i] == '.' ? 1 : 0);
    }
    result.add(newRow);
  }

  return result;
}

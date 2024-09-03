// ignore_for_file: avoid_print

import 'dart:collection';

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  @override
  String toString() {
    return '($x,$y)';
  }
}

class ShortestPathSolver {
  final List<List<int>> grid;
  final int n;

  ShortestPathSolver(this.grid) : n = grid.length {
    if (n <= 1 || n >= 100) {
      throw ArgumentError("Grid size must be > 1 and < 100.");
    }
  }

  List<Point> findShortestPath(Point start, Point end) {
    if (!isValid(start) || !isValid(end)) {
      throw ArgumentError("Start or end point is out of grid bounds.");
    }

    List<List<bool>> visited = List.generate(
      n,
      (i) => List.filled(n, false),
    );

    Queue<List<Point>> queue = Queue();
    queue.add([start]);
    visited[start.x][start.y] = true;

    List<Point> directions = [
      Point(0, 1),
      Point(1, 0),
      Point(0, -1),
      Point(-1, 0),
      Point(1, 1),
      Point(1, -1),
      Point(-1, 1),
      Point(-1, -1)
    ];

    while (queue.isNotEmpty) {
      List<Point> path = queue.removeFirst();
      Point current = path.last;

      if (current.x == end.x && current.y == end.y) {
        return path;
      }

      for (var direction in directions) {
        int newX = current.x + direction.x;
        int newY = current.y + direction.y;

        if (isValid(Point(newX, newY)) &&
            !visited[newX][newY] &&
            grid[newX][newY] == 1) {
          visited[newX][newY] = true;
          List<Point> newPath = List.from(path)..add(Point(newX, newY));
          queue.add(newPath);
        }
      }
    }

    return [];
  }

  bool isValid(Point point) {
    return point.x >= 0 && point.x < n && point.y >= 0 && point.y < n;
  }
}

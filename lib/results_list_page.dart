import 'package:flutter/material.dart';
import 'package:flutter_app/preview_screen_page.dart';
import 'package:flutter_app/storage/result_storage.dart';

class ResultsListPage extends StatelessWidget {
  final Map<String, Map<String, int>> fieldSizes;
  final Map<String, List<List<int>>> fields;

  const ResultsListPage(this.fieldSizes, this.fields, {super.key});

  Future<List<Map<String, dynamic>>> _getResults() async {
    final storage = ResultStorage();
    final results = await storage.loadResults();

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result list screen'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load results'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results found'));
          }

          final results = snapshot.data ?? [];

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final pathString = result['result']['path'];

              final String id = result['id'];
              final field = fields[id];
              return ListTile(
                title: Text(pathString),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewScreen(
                        pathString: pathString,
                        field: field ?? [],
                      ),
                    ),
                  );
                },
                tileColor: Colors.white,
                selectedTileColor: Colors.lightBlueAccent,
                selectedColor: Colors.white,
              );
            },
          );
        },
      ),
    );
  }
}

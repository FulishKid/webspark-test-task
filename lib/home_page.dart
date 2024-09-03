import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/api_service.dart';
import 'package:flutter_app/results_list_page.dart';
import 'package:flutter_app/storage/result_storage.dart';
import 'package:flutter_app/storage/url_storage.dart';
import 'package:flutter_app/task_processor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  double _progress = 0.0;
  bool _calculationComplete = false;
  List<Map<String, dynamic>> results = [];
  Map<String, Map<String, int>> fieldSize = {};
  Map<String, List<List<int>>> fields = {};

  @override
  void initState() {
    super.initState();
    _loadURL();
  }

  Future<void> _loadURL() async {
    final savedUrl = await URLStorage.loadURL();
    if (savedUrl != null) {
      _urlController.text = savedUrl;
    }
  }

  Future<void> _animateProgress() async {
    const int duration = 3000;
    const int steps = 100;
    const double maxProgress = 0.7;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(const Duration(milliseconds: duration ~/ steps));
      setState(() {
        _progress = maxProgress * (i / steps) * (1 + (1 - i / steps));
      });
    }

    while (_progress < 1.0 && _isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        double remainingProgress = (1.0 - _progress) / 10;
        _progress += remainingProgress;
        if (_progress > 1.0) _progress = 1.0;
      });
    }
  }

  Future<void> _onStartPressed() async {
    final url = _urlController.text;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL')),
      );
      return;
    }

    final apiService = APIService(url);
    if (!apiService.isValidURL()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid URL. Please use the correct API URL.')),
      );
      return;
    }

    await URLStorage.saveURL(url);

    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _calculationComplete = false;
    });

    // Запускаємо анімацію прогрес-бара
    _animateProgress();

    try {
      final tasks = await apiService.fetchTasks();
      final processor = TaskProcessor();

      results = processor.processTasks(tasks);
      fieldSize = processor.getFieldSizes();
      fields = processor.getFields();
      setState(() {
        _calculationComplete = true;
        _progress = 1.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tasks: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendResults(
      APIService apiService, List<Map<String, dynamic>> results) async {
    _progress = 0;

    _animateProgress();
    setState(() {
      _isLoading = true;
    });

    try {
      await apiService.sendResults(results);

      final resultStorage = ResultStorage();
      await resultStorage.saveResults(results);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultsListPage(fieldSize, fields)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send results: $e')),
      );
    } finally {
      setState(() {
        _progress = 1.0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 132, 231, 74),
        title: const Text('Home Page'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.link),
                Container(
                  padding: const EdgeInsets.all(8),
                ),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                        hintText: 'Set up base api URL',
                        border: OutlineInputBorder(gapPadding: 5)),
                  ),
                ),
              ],
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _calculationComplete
                  ? Text(!_isLoading
                      ? 'Now you can send results to the server'
                      : 'Sending...')
                  : Text(_isLoading ? '${(_progress * 100).round()}%' : ''),
            ),
            if (_isLoading)
              LinearProgressIndicator(value: _progress)
            else if (_calculationComplete)
              ElevatedButton(
                onPressed: () => _sendResults(
                  APIService(_urlController.text),
                  results,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Text(
                    'Send Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: _isLoading ? null : _onStartPressed,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Text(
                    'Start',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

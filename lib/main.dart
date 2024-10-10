import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const FlappyBirdApp());
}

class FlappyBirdApp extends StatelessWidget {
  const FlappyBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flappy Bird',
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  List<Map<String, dynamic>> highScores = [];
  AudioCache audioCache = AudioCache(); // Initialize AudioCache to play assets

  @override
  void initState() {
    super.initState();
    loadHighScores();
    audioCache = AudioCache(prefix: 'assets/sounds/'); // Set the prefix for sounds folder
  }

  // Method to play sound using AudioCache
  void _playSound(String soundFile) async {
    await audioCache.play(soundFile);
  }

  // Load high scores from JSON
  Future<void> loadHighScores() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/highscores.json');
    if (file.existsSync()) {
      final jsonString = file.readAsStringSync();
      final jsonData = json.decode(jsonString);
      setState(() {
        highScores = List<Map<String, dynamic>>.from(jsonData);
      });
    }
  }

  // Save high scores to JSON
  Future<void> saveHighScores() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/highscores.json');
    final jsonString = json.encode(highScores);
    file.writeAsStringSync(jsonString);
  }

  // Add a new high score
  void addHighScore(String name, int score) {
    setState(() {
      highScores.add({'name': name, 'score': score});
      highScores.sort((a, b) => b['score'].compareTo(a['score']));
    });
    saveHighScores();
  }

  // Reset game and play die sound
  void resetGame() {
    _playSound('die.wav');
    setState(() {
      score = 0;
    });
  }

  // Increment score and play point sound
  void incrementScore() {
    _playSound('point.wav');
    setState(() {
      score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              incrementScore();
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Score: $score',
                    style: const TextStyle(fontSize: 48, color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: resetGame,
                    child: const Text('Reset Game'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: highScores
                  .map((scoreData) => Text(
                        "${scoreData['name']}: ${scoreData['score']}",
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
    );
  }
}

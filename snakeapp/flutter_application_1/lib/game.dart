import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SnakeGamePage(),
      ),
    );
  }
}

class SnakeGamePage extends StatefulWidget {
  @override
  _SnakeGamePageState createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  static const int numRows = 15;
  static const int numCols = 15;
  static const double cellSize = 30.0;
  List<int> snake = [45, 44];
  int food = 0;
  int score = 0; // Score variable added
  int maxScore = 100; // Maximum score variable added
  var random = Random();
  var direction = 'down';
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    setFood();
    startGame();
  }

  void startGame() {
    const duration = Duration(milliseconds: 250);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (checkCollision() || score >= maxScore) { // Check for maximum score
        timer.cancel();
        gameOver = true;
        showGameOverDialog();
      }
      if (!gameOver) {
        setState(() {});
      }
    });
  }

  void setFood() {
    food = random.nextInt(numRows * numCols);
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'up':
          if (snake.first < numCols) {
            snake.insert(0, snake.first - numCols + (numCols * numRows));
          } else {
            snake.insert(0, snake.first - numCols);
          }
          break;
        case 'down':
          snake.insert(0, (snake.first + numCols) % (numCols * numRows));
          break;
        case 'left':
          snake.insert(0, snake.first % numCols == 0 ? snake.first + numCols - 1 : snake.first - 1);
          break;
        case 'right':
          snake.insert(0, snake.first % numCols == numCols - 1 ? snake.first - numCols + 1 : snake.first + 1);
          break;
      }
      if (snake.first == food) {
        score++; 
        setFood();
      } else {
        snake.removeLast();
      }
    });
  }

  bool checkCollision() {
    if (snake.first < 0 ||
        snake.first >= numRows * numCols ||
        snake.sublist(1).contains(snake.first)) {
      return true;
    }
    return false;
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Do you want to play again?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  snake = [45, 44];
                  direction = 'down';
                  gameOver = false;
                  score = 0; // Reset score when starting a new game
                });
                Navigator.of(context).pop();
                startGame();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameOver = true;
                });
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game - Score: $score'), 
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (direction != 'up' && details.delta.dy > 0) {
            direction = 'down';
          } else if (direction != 'down' && details.delta.dy < 0) {
            direction = 'up';
          }
        },
        onHorizontalDragUpdate: (details) {
          if (direction != 'left' && details.delta.dx > 0) {
            direction = 'right';
          } else if (direction != 'right' && details.delta.dx < 0) {
            direction = 'left';
          }
        },

        child: Container(
          color: Colors.green, 
          child: Center(
            child: Container(
              width: numCols * cellSize,
              height: numRows * cellSize,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: numCols,
                ),
                itemCount: numRows * numCols,
                itemBuilder: (BuildContext context, int index) {
                  bool isSnakehead = snake.first == index;
                  bool isSnakebody = snake.contains(index) && !isSnakehead;
                  bool isFood = food == index;

                  if (isSnakehead) {
                    return Image.asset(
                      '../assets/snake.png',
                      width: cellSize,
                      height: cellSize,
                    );
                  } else if (isSnakebody) {
                    return Image.asset(
                      '../assets/shuluun.png',
                      width: cellSize,
                      height: cellSize,
                    );
                  } else if (isFood) {
                    return Image.asset(
                      '../assets/apple.png',
                      width: cellSize,
                      height: cellSize,
                    );
                  } else {
                    return Image.asset(
                      '../assets/images.png', // Replace with your actual asset path
                      width: cellSize,
                      height: cellSize,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

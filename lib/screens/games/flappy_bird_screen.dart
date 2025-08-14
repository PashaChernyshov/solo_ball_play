import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

class FlappyBirdScreen extends StatefulWidget {
  static const routeName = '/flappy-bird';

  @override
  _FlappyBirdScreenState createState() => _FlappyBirdScreenState();
}

class _FlappyBirdScreenState extends State<FlappyBirdScreen>
    with SingleTickerProviderStateMixin {
  // Размеры экрана
  late double _screenWidth;
  late double _screenHeight;

  // Параметры шарика
  double _birdX = 0; // X-координата центра шарика
  double _birdY = 0; // Y-координата центра шарика
  final double _birdRadius = 20; // Радиус шарика
  double _gravity = 0.5; // Гравитация
  double _velocity = 0; // Скорость падения/подъема

  // Параметры труб
  List<double> _barrierX = [300, 700]; // X-координаты труб
  final double _barrierWidth = 80; // Ширина трубы
  final double _gapSize = 200; // Размер зазора между трубами
  List<double> _barrierHeightTop = [100, 150]; // Высота верхних труб
  final double _barrierSpeed = 3; // Скорость движения труб
  final double _minBarrierDistance =
      400; // Минимальное расстояние между трубами

  // Игровые параметры
  bool _gameOver = true; // Состояние игры
  bool _gameStarted = false; // Флаг начала игры
  int _score = 0; // Текущий счет
  int _highScore = 0; // Рекорд
  Timer? _gameLoop; // Таймер для игрового цикла
  SharedPreferences? _prefs; // Для сохранения рекорда

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _resetGame();
  }

  Future<void> _loadHighScore() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = _prefs!.getInt('highScore') ?? 0;
    });
  }

  void _saveHighScore() {
    if (_score > _highScore) {
      setState(() {
        _highScore = _score;
      });
      _prefs?.setInt('highScore', _highScore);
    }
  }

  void _resetGame() {
    setState(() {
      _gameOver = false;
      _gameStarted = false;
      _birdX = 100; // Начальная позиция шарика
      _birdY = 300; // Начальная позиция шарика
      _velocity = 0;
      _score = 0;
      _barrierX = [
        300,
        700
      ]; // Начальные позиции труб с минимальным расстоянием
      _barrierHeightTop = [
        Random().nextDouble() * 200 + 50,
        Random().nextDouble() * 200 + 50
      ];
    });
  }

  void _startGame() {
    if (_gameStarted) return;
    setState(() {
      _gameStarted = true;
      _gameOver = false;
    });
    _gameLoop = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (_gameOver) return;

      // Обновляем позицию шарика
      _velocity += _gravity;
      setState(() {
        _birdY += _velocity;
        _barrierX[0] -= _barrierSpeed;
        _barrierX[1] -= _barrierSpeed;
      });

      // Перезапуск труб
      if (_barrierX[0] < -_barrierWidth) {
        setState(() {
          _barrierX[0] = _barrierX[1] + _minBarrierDistance + _barrierWidth;
          _barrierHeightTop[0] = Random().nextDouble() * 400;
        });
        if (!_gameOver) _score++;
      }
      if (_barrierX[1] < -_barrierWidth) {
        setState(() {
          _barrierX[1] = _barrierX[0] + _minBarrierDistance + _barrierWidth;
          _barrierHeightTop[1] = Random().nextDouble() * 400;
        });
        if (!_gameOver) _score++;
      }

      _checkCollision();
    });
  }

  void _checkCollision() {
    // Проверка нижней границы
    if (_birdY + _birdRadius > _screenHeight * 0.8) {
      _gameOver = true;
      _gameLoop?.cancel();
      _saveHighScore();
    }

    // Проверка верхней границы
    if (_birdY - _birdRadius < 0) {
      _gameOver = true;
      _gameLoop?.cancel();
      _saveHighScore();
    }

    // Проверка столкновений с трубами
    for (int i = 0; i < _barrierX.length; i++) {
      double barrierX = _barrierX[i]; // X-координата трубы
      double topBarrierHeight = _barrierHeightTop[i]; // Высота верхней трубы
      double bottomBarrierY =
          topBarrierHeight + _gapSize; // Начало нижней трубы

      // Проверяем горизонтальное пересечение
      if (_birdX + _birdRadius > barrierX &&
          _birdX - _birdRadius < barrierX + _barrierWidth) {
        // Проверяем вертикальное пересечение
        if (_birdY - _birdRadius < topBarrierHeight ||
            _birdY + _birdRadius > bottomBarrierY) {
          _gameOver = true;
          _gameLoop?.cancel();
          _saveHighScore();
        }
      }
    }
  }

  void _jump() {
    if (_gameOver) return;
    if (!_gameStarted) _startGame();

    setState(() {
      _velocity = -10; // Сила прыжка
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: _jump, // Нажатие работает на всей области экрана
        child: Stack(
          children: [
            // Основной контейнер игры
            Center(
              child: Container(
                width: _screenWidth * 0.8,
                height:
                    _screenHeight * 0.8, // Увеличена высота контейнера до 80%
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 137, 208, 230),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Верхняя граница
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.white, // Белая линия
                      ),
                    ),
                    // Игровая зона
                    Column(
                      children: [
                        // Основная зона полета
                        Expanded(
                          flex: 8, // Увеличили пространство для полета
                          child: Stack(
                            children: [
                              // Трубы
                              _buildBarrierPair(0),
                              _buildBarrierPair(1),
                              // Птица
                              Positioned(
                                left: _birdX - _birdRadius,
                                top: _birdY - _birdRadius,
                                child: Container(
                                  width: _birdRadius * 2,
                                  height: _birdRadius * 2,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Белая линия смерти
                        Container(
                          height: 2,
                          color: Colors.white, // Белая линия
                        ),
                        // Зона счета (без серой обводки)
                        Container(
                          height: 60, // Высота зоны счета
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Score: $_score',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              Text(
                                'High Score: $_highScore',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Оверлей (теперь на весь экран)
            if (_gameOver || !_gameStarted) _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarrierPair(int index) {
    double topBarrierHeight = _barrierHeightTop[index];
    double bottomBarrierY = topBarrierHeight + _gapSize;

    return Positioned(
      left: _barrierX[index],
      child: Column(
        children: [
          // Верхняя труба
          Container(
            width: _barrierWidth,
            height: topBarrierHeight,
            color: const Color.fromARGB(255, 93, 142, 157),
          ),
          // Зазор между трубами
          Container(
            width: _barrierWidth,
            height: _gapSize,
            color: const Color.fromARGB(255, 137, 208, 230),
          ),
          // Нижняя труба
          Container(
            width: _barrierWidth,
            height: _screenHeight * 0.8 - bottomBarrierY,
            color: const Color.fromARGB(255, 93, 142, 157),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Размытие фона
      child: Container(
        color: Colors.black.withOpacity(0.7), // Затемнение
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_gameStarted)
                Column(
                  children: [
                    Text(
                      'Tap to Start',
                      style: TextStyle(fontSize: 36, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Icon(Icons.touch_app, size: 64, color: Colors.white),
                  ],
                ),
              if (_gameOver)
                Column(
                  children: [
                    Text(
                      '$_score', // Отображаем счет большими цифрами
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Game Over!',
                      style: TextStyle(fontSize: 36, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    _buildStyledButton(
                      text: 'Restart',
                      onPressed: _resetGame,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        backgroundColor: Colors.black.withOpacity(0.6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 3,
        minimumSize: Size(200, 50),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

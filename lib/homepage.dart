import 'dart:async';
import 'dart:math';

import 'package:dount_app_4sa/pixel.dart';
import 'package:flutter/material.dart';

import 'path.dart';
import 'player.dart';
import 'ghost.dart';

class Homepage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  static int numberInRow = 11;
  int numberOfSquares = numberInRow * 17;
  int player = numberInRow * 15 + 1;

  static List<int> barriers = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    22,
    33,
    44,
    55,
    66,
    77,
    99,
    110,
    121,
    132,
    143,
    154,
    165,
    176,
    177,
    178,
    179,
    180,
    181,
    182,
    183,
    184,
    185,
    186,
    175,
    164,
    153,
    142,
    131,
    120,
    109,
    87,
    76,
    65,
    54,
    43,
    32,
    21,
    78,
    79,
    80,
    100,
    101,
    102,
    85,
    86,
    106,
    107,
    108,
    24,
    35,
    46,
    57,
    30,
    41,
    52,
    63,
    81,
    70,
    59,
    61,
    72,
    83,
    26,
    28,
    37,
    38,
    39,
    123,
    134,
    145,
    156,
    129,
    140,
    151,
    162,
    103,
    114,
    125,
    105,
    116,
    127,
    147,
    148,
    149,
    158,
    160
  ];

  List<int> food = [];

  String direction = "right";
  bool preGame = true;
  bool mouthClosed = false;
  int score = 0;

  void startGame() {
    setState(() {
      preGame = false;
      score = 0;
      player = numberInRow * 15 + 1;
      ghost = numberInRow * 2 - 2;
      direction = "right";
    });
    getFood();

    Timer.periodic(Duration(milliseconds: 120), (timer) {
      setState(() {
        mouthClosed = !mouthClosed;
      });

      // Movimiento del jugador
      if (food.contains(player)) {
        setState(() {
          food.remove(player);
          score++;
        });
      }

      // Verificar si el jugador toca al fantasma
      if (player == ghost) {
        // El jugador tocó al fantasma, reiniciar el juego
        timer.cancel(); // Detener el temporizador
        setState(() {
          preGame = true; // Cambiar a la pantalla de inicio
        });
        return; // Salir de la función, no continuar el juego
      }

      // Movimiento del jugador
      switch (direction) {
        case "left":
          moveLeft();
          break;
        case "right":
          moveRight();
          break;
        case "up":
          moveUp();
          break;
        case "down":
          moveDown();
          break;
      }

      // Movimiento aleatorio del fantasma
      moveGhostRandomly();
    });
  }

  int ghost = numberInRow * 2 - 2;
  String ghostDirection = "left"; // inicial

  void getFood() {
    food.clear();
    for (int i = 0; i < numberOfSquares; i++) {
      if (!barriers.contains(i)) {
        food.add(i);
      }
    }
  }

  void moveLeft() {
    if (!barriers.contains(player - 1)) {
      setState(() {
        player--;
      });
    }
  }

  void moveRight() {
    if (!barriers.contains(player + 1)) {
      setState(() {
        player++;
      });
    }
  }

  void moveUp() {
    if (!barriers.contains(player - numberInRow)) {
      setState(() {
        player -= numberInRow;
      });
    }
  }

  void moveDown() {
    if (!barriers.contains(player + numberInRow)) {
      setState(() {
        player += numberInRow;
      });
    }
  }

  void moveGhostRandomly() {
    // Generamos una dirección aleatoria (izquierda, derecha, arriba, abajo)
    Random random = Random();
    List<String> directions = ["left", "right", "up", "down"];
    String randomDirection = directions[random.nextInt(4)];

    switch (randomDirection) {
      case "left":
        if (!barriers.contains(ghost - 1)) {
          setState(() {
            ghost--;
          });
        }
        break;
      case "right":
        if (!barriers.contains(ghost + 1)) {
          setState(() {
            ghost++;
          });
        }
        break;
      case "up":
        if (!barriers.contains(ghost - numberInRow)) {
          setState(() {
            ghost -= numberInRow;
          });
        }
        break;
      case "down":
        if (!barriers.contains(ghost + numberInRow)) {
          setState(() {
            ghost += numberInRow;
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0) {
                  direction = "down";
                } else if (details.delta.dy < 0) {
                  direction = "up";
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  direction = "right";
                } else if (details.delta.dx < 0) {
                  direction = "left";
                }
              },
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: numberOfSquares,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numberInRow),
                itemBuilder: (BuildContext context, int index) {
                  if (player == index) {
                    switch (direction) {
                      case "left":
                        return Transform.rotate(
                          angle: pi,
                          child: MyPlayer(),
                        );
                      case "right":
                        return MyPlayer();
                      case "up":
                        return Transform.rotate(
                          angle: 3 * pi / 2,
                          child: MyPlayer(),
                        );
                      case "down":
                        return Transform.rotate(
                          angle: pi / 2,
                          child: MyPlayer(),
                        );
                      default:
                        return MyPlayer();
                    }
                  } else if (barriers.contains(index)) {
                    return MyPixel(
                      innerColor: Colors.blue[800],
                      outerColor: Colors.blue[900],
                    );
                  } else if (food.contains(index)) {
                    return MyPath(
                      innerColor: Colors.yellow,
                      outerColor: Colors.black,
                    );
                  } else if (ghost == index) {
                    return MyGhost(); 
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Score: " + score.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  GestureDetector(
                    onTap: startGame,
                    child: Text(
                      "P L A Y ",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

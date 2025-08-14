import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../constants.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AspectRatio(
          aspectRatio: kCardAspectRatio,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              game.icon,
              SizedBox(height: 16),
              Text(game.name, style: kTitleStyle),
              SizedBox(height: 8),
              Text(game.description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

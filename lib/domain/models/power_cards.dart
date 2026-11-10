import 'package:flutter/material.dart';

enum PowerCardType {
  doubleVote,
  detective,
  shield,
  spy,
  silence,
  secondChance,
}

class PowerCard {
  const PowerCard({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.limitation,
  });

  final PowerCardType type;
  final String title;
  final String description;
  final IconData icon;
  final String limitation;

  static const List<PowerCard> all = [
    PowerCard(
      type: PowerCardType.doubleVote,
      title: 'Double Vote',
      description: "Your vote counts twice during this round's elimination.",
      icon: Icons.how_to_vote_rounded,
      limitation: 'One-time use per match. Must be declared before final vote.',
    ),
    PowerCard(
      type: PowerCardType.detective,
      title: 'Detective',
      description: 'Receive an additional subtle clue about the secret word.',
      icon: Icons.search_rounded,
      limitation: 'Only available if you are a crew member.',
    ),
    PowerCard(
      type: PowerCardType.shield,
      title: 'Shield',
      description: 'Immunity from elimination for the current voting round.',
      icon: Icons.shield_rounded,
      limitation: 'Cannot be used if you are the last surviving crew.',
    ),
    PowerCard(
      type: PowerCardType.spy,
      title: 'Spy',
      description: 'Observe whether a chosen player is on the same team as you.',
      icon: Icons.visibility_rounded,
      limitation: 'Does not reveal their secret word or exact role title.',
    ),
    PowerCard(
      type: PowerCardType.silence,
      title: 'Silence',
      description: 'Temporarily prevent one player from speaking during discussion.',
      icon: Icons.volume_off_rounded,
      limitation: 'Target player may still vote and give non-verbal cues.',
    ),
    PowerCard(
      type: PowerCardType.secondChance,
      title: 'Second Chance',
      description: 'Triggers an emergency revote if you are eliminated.',
      icon: Icons.replay_rounded,
      limitation: 'Activates immediately upon tie or first elimination.',
    ),
  ];
}

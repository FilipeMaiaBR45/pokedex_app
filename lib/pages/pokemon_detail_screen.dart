import 'package:flutter/material.dart';

class PokemonDetailsScreen extends StatelessWidget {
  final String pokemonName;

  PokemonDetailsScreen({required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Pokémon'),
      ),
      body: Center(
        child: Text('Detalhes para o Pokémon $pokemonName'),
      ),
    );
  }
}

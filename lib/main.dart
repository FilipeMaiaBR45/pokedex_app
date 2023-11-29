import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PokemonList(),
    );
  }
}

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  late Future<List<Pokemon>> futurePokemonList;

  @override
  void initState() {
    super.initState();
    futurePokemonList = fetchPokemonList();
  }

  Future<List<Pokemon>> fetchPokemonList() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];

      List<Pokemon> pokemonData = await Future.wait(
        results.map((result) async => await fetchPokemonData(result['url'])),
      );

      return pokemonData;
    } else {
      print('Falha na requisição: ${response.statusCode}');
      throw Exception('Falha ao carregar a lista de Pokémon');
    }
  }

  Future<Pokemon> fetchPokemonData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return Pokemon(
        id: data['id'],
        name: data['name'],
        imageUrl: data['sprites']['front_default'],
        types: data['types']
            .map<String>((type) => type['type']['name'] as String)
            .toList(),
      );
    } else {
      print('Falha na requisição: ${response.statusCode}');
      throw Exception('Falha ao carregar os detalhes do Pokémon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: futurePokemonList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Se estiver carregando, exibe um indicador de carregamento (spinner)
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Se ocorrer um erro, exibe uma mensagem de erro
            return const Center(
              child: Text('Erro ao carregar os dados'),
            );
          } else {
            // Se as requisições foram bem-sucedidas, exibe a lista de Pokémon
            List<Pokemon> pokemonList = snapshot.data!;
            return ListView.builder(
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      '${pokemonList[index].id}. ${pokemonList[index].name}'),
                  subtitle:
                      Text('Tipos: ${pokemonList[index].types.join(', ')}'),
                  leading: Image.network(pokemonList[index].imageUrl),
                  onTap: () {
                    // Navegar para a página de detalhes do Pokémon ao clicar no item da lista
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PokemonDetailsScreen(
                              pokemon: pokemonList[index])),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  Pokemon(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.types});
}

class PokemonDetailsScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailsScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pokémon'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(pokemon.imageUrl),
            const SizedBox(height: 16),
            Text('ID: ${pokemon.id}'),
            Text('Nome: ${pokemon.name}'),
            Text('Tipos: ${pokemon.types.join(', ')}'),
          ],
        ),
      ),
    );
  }
}

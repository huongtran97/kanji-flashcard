import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';

class FavoritesWordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch the appState to access favorites
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet!'),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return ListTile(
          title: Row(
            children: [
              Icon(Icons.favorite, size: 20),  
              SizedBox(width: 8),
              Text(favorite.word),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Onyomi: ${favorite.onyomiReadings}'),
              Text('Kunyomi: ${favorite.kunyomiReadings}'),
              Text('Nanori: ${favorite.nanoriReadings}'),
              // Text('Meaning: ${favorite.wordMeanings}'),
            ],
          ),
        );
      },
    );
  }
}

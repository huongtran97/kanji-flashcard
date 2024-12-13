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
              Text(favorite.word, 
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold
              ),),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (favorite.onyomiReadings.isNotEmpty)
                Text('Onyomi: ${favorite.onyomiReadings.join(', ')}'),
              if (favorite.kunyomiReadings.isNotEmpty)
                Text('Kunyomi: ${favorite.kunyomiReadings.join(', ')}'),
              if (favorite.nanoriReadings.isNotEmpty)
                Text('Nanori: ${favorite.nanoriReadings.join(', ')}'),
              if (favorite.wordMeanings.isNotEmpty)
                Text('Meaning: ${favorite.wordMeanings.join(', ')}'),
              if (favorite.onyomiReadings.isEmpty &&
                  favorite.kunyomiReadings.isEmpty &&
                  favorite.nanoriReadings.isEmpty &&
                  favorite.wordMeanings.isEmpty)
                Text('No available readings or meanings.')
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
// import 'package:japanese_flashcard_application/kanji_details_page.dart';
// import 'package:japanese_flashcard_application/model/kanji_model.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';

class FavoritesWordPage extends StatefulWidget {
  @override
  FavoritesWordPageState createState() => FavoritesWordPageState();
}

class FavoritesWordPageState extends State<FavoritesWordPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = List.of(appState.favorites);

    if (favorites.isEmpty) {
      return Center(child: Text('No favorites yet!'));
    }

    return AnimatedList(
      key: _listKey,
      initialItemCount: favorites.length,
      itemBuilder: (context, index, animation) {
        return _buildListItem(favorites[index], index, animation, appState);
      },
    );
  }

  Widget _buildListItem(
    favorite, int index, Animation<double> animation, MyAppState appState) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          title: Row(
            children: [
              Icon(Icons.favorite, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  favorite.kanji,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Text(
            favorite.meanings.isNotEmpty
                ? 'Meanings: ${favorite.meanings.join(", ")}'
                : 'No available readings or meanings.',
            style: TextStyle(fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.info_rounded,
                    color: Color.fromARGB(255, 128, 126, 125)),
                onPressed: () {
                  // _navigateToKanjiDetailPage(context, favorite.kanji);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: Color.fromARGB(255, 128, 126, 125)),
                onPressed: () {
                  _removeItem(index, appState);
                },
              ),
            ],
          ),
          onTap: () {
            // _navigateToKanjiDetailPage(context, favorite.kanji);
          },
        ),
      ),
    );
  }

  void _removeItem(int index, MyAppState appState) {
    final removedItem = appState.favorites[index];

    _listKey.currentState!.removeItem(
      index,
      (context, animation) =>
          _buildListItem(removedItem, index, animation, appState),
      duration: Duration(milliseconds: 300),
    );

    appState.removeFavorite(removedItem);
  }

  
}

import 'package:flutter/material.dart';
import 'package:japanese_flashcard_application/kanji_vocabulary_page.dart';
import 'package:japanese_flashcard_application/practice_kanji.dart';
import 'package:provider/provider.dart';
import 'favorites_word_page.dart';
import 'my_app_state.dart';
import 'random_word_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  final myAppState = MyAppState();
  await myAppState.loadFavorites();  
  
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => myAppState,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanji Vocabulary',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 54, 90, 122),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

@override
void initState() {
  super.initState();
  final appState = context.read<MyAppState>();
  // Favorites are loaded before getting a random word
  if (appState.isFavoritesLoaded) {
    appState.getRandomWord(context);
  } else {
    appState.addListener(() {
      if (appState.isFavoritesLoaded) {
        appState.getRandomWord(context);
      }
    });
  }
}

   @override
  Widget build(BuildContext context) {
    Widget page;

    if (selectedIndex == 0) {
      page = RandomWordPage();
    } else if (selectedIndex == 1) {
      page = FavoritesWordPage();
    } else if (selectedIndex == 2) {
      page = PracticeKanjiPage();
    } else if (selectedIndex == 3) {
      page = KanjiVocabularyPage();
    } else {
      throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.flash_auto),
                      label: Text('Random Kanji'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorite'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.keyboard),
                      label: Text('Practice'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.local_library),
                      label: Text('Vocabulary'),
                    )
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

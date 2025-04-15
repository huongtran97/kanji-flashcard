import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:japanese_flashcard_application/hiragana_to_romaji_map.dart';
import 'package:japanese_flashcard_application/my_app_state.dart';
import 'package:japanese_flashcard_application/model/favorite_model.dart'
    as favorite_model;
import 'package:japanese_flashcard_application/model/kanji_model.dart';
import 'package:japanese_flashcard_application/model/meaning_model.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';
import 'package:japanese_flashcard_application/transition_animation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class RandomWordPage extends StatefulWidget {
  @override
  RandomWordPageState createState() => RandomWordPageState();
}

class RandomWordPageState extends State<RandomWordPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  late AudioPlayer _audioPlayer;
  List<Map<String, dynamic>> wordHistory = [];
  int currentIndex = 0;
  bool isFlipped = false;
  bool isPlaying = false;
  bool isLoadingAudio = false;
  late AnimationController _animationController;
  String? pronunciationUrl;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadRandomWord();
  }

  Future<void> _loadRandomWord() async {
    var appState = context.read<MyAppState>();
    await appState.getRandomWord(context);

    if (appState.kanji.readings.isNotEmpty) {
      if (mounted) {
        setState(() {
          Kanji currentKanji = appState.kanji;
          wordHistory.add({
            'characters': currentKanji.characters,
            'readings': currentKanji.readings,
            'meanings': currentKanji.meanings,
          });
          currentIndex = wordHistory.length - 1;
        });
      }
    }
  }

  void playPronunciation(String pronunciationUrl) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(pronunciationUrl);
      await _audioPlayer.play();
      setState(() {
        isPlaying = true;
      });

      // Set the isPlaying to false when the audio finishes
      _audioPlayer.positionStream.listen((position) {
        if (position == Duration.zero) {
          setState(() {
            isPlaying = false;
          });
        }
      });
    } catch (e) {
      print("Error playing pronunciation: $e");
    }
  }

  void _showPreviousWord() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        isFlipped = false;
      });
    }
  }

Future<void> _loadAudio() async {
  if (wordHistory.isEmpty || currentIndex >= wordHistory.length) {
    print("No valid character found for currentIndex");
    return;
  }

  var currentWord = wordHistory[currentIndex];
  var characters = currentWord['characters'];

  if (characters != null && characters.isNotEmpty) {
    setState(() {
      isLoadingAudio = true; // Loading animation
    });

    print("Fetching pronunciation audio for character: $characters");

    try {
      
      var appState = context.read<MyAppState>();
      String? audioUrl = await appState.fetchPronunciationForCurrentWord(characters);

      if (audioUrl != null) {
        print("Playing audio from URL: $audioUrl");

        try {
          await _audioPlayer.stop();
          await _audioPlayer.setUrl(audioUrl);

          // Listen for completion
          _audioPlayer.playerStateStream.listen((state) {
            if (state.processingState == ProcessingState.completed) {
              if (mounted) {
                setState(() {
                  isPlaying = false;
                  isLoadingAudio = false;
                });
              }
            }
          });

          await _audioPlayer.play();

          setState(() {
            isPlaying = true;
          });
        } catch (e) {
          print("Error playing audio: $e");
          setState(() {
            isLoadingAudio = false;
            isPlaying = false;
          });
        }
      } else {
        print("No audio found for character: $characters");
        setState(() {
          isLoadingAudio = false;
        });
      }
    } catch (e) {
      print("Error fetching pronunciation audio: $e");
      setState(() {
        isLoadingAudio = false;
      });
    }
  } else {
    print("No valid character found for currentIndex");
  }
}

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    var appState = context.read<MyAppState>();
    var currentWord = wordHistory[currentIndex];
   
    var character = currentWord['characters'] as String;
    var readings = currentWord['readings'] as List<ReadingModel>;
    var meanings = currentWord['meanings'] as List<MeaningModel>;

    var charactersMeanings = meanings
        .where((MeaningModel meaning) => meaning.acceptedAnswer)
        .map((MeaningModel meaning) => meaning.meaning)
        .toList();
    var favorite = favorite_model.FavoriteModel(
     
      kanji: character,
      readings: readings,
      meanings: charactersMeanings,
    );
    appState.toggleFavorite(favorite);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (wordHistory.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    var currentWord = wordHistory[currentIndex];
    var word = currentWord['characters'] as String;
    List<ReadingModel> readings = currentWord['readings'] as List<ReadingModel>;
    var meanings = currentWord['meanings'] as List<MeaningModel>;

    

    bool isFavorite =
        appState.favorites.any((favorite) => favorite.kanji == word);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              cardKey.currentState?.toggleCard();
            },
            child: SizedBox(
              width: 450,
              height: 550,
              child: FlipCard(
                key: cardKey,
                front: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      word,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 90,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                back: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          readings.map((reading) => reading.reading).join(', '),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                  fontSize: 55,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 25),
                        IconButton(
                          onPressed: () {
                            _loadAudio();
                          },
                          icon: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            child: isLoadingAudio
                                ? JumpingDotsLoadingIndicator(
                                    color: Colors.black,
                                    size: 8,
                                  )
                                : Icon(
                                    Icons.volume_up,
                                    key: ValueKey<String>("volume_icon"),
                                    size: 30,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                        Text(
                          convertHiraganaToRomaji(readings
                              .map((readingModel) => readingModel.reading)
                              .join(', ')),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontSize: 20,
                                  color: const Color.fromARGB(255, 10, 64, 156),
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 35),
                        Text(
                          meanings.map((meaning) => meaning.meaning).join(', '),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: 20,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: currentIndex > 0 ? _showPreviousWord : null,
                icon: Icon(Icons.arrow_back),
                label: Text('Previous'),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  if (cardKey.currentState?.isFront != true) {
                    cardKey.currentState?.toggleCard();
                    await Future.delayed(Duration(milliseconds: 100));
                  }
                  _loadRandomWord();
                },
                icon: Icon(Icons.arrow_forward),
                label: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

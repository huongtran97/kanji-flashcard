import 'package:flutter/material.dart';
import 'package:japanese_flashcard_application/my_app_state.dart';
import 'package:japanese_flashcard_application/transition_animation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:japanese_flashcard_application/hiragana_to_romaji_map.dart';
import 'package:japanese_flashcard_application/model/kanji_model.dart';
import 'package:japanese_flashcard_application/model/reading_model.dart';
import 'package:provider/provider.dart';

class KanjiDetailPage extends StatefulWidget {
  final Kanji kanji;
  final List<ReadingModel> readings;
  

  const KanjiDetailPage(
      {super.key, required this.kanji, required this.readings, });

  @override
  State<KanjiDetailPage> createState() => _KanjiDetailPageState();
}

class _KanjiDetailPageState extends State<KanjiDetailPage> {
  late AudioPlayer _audioPlayer;
  bool isLoadingAudio = false;
  bool isFlipped = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> playPronunciation(String character) async {
    setState(() {
      isLoadingAudio = true;
    });

    var appState = context.read<MyAppState>();
    String? audioUrl =
        await appState.fetchPronunciationForCurrentWord(character);

    if (audioUrl != null) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();

        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              isLoadingAudio = false;
            });
          }
        });
      } catch (e) {
        print('Playback error: $e');
        setState(() {
          isLoadingAudio = false;
        });
      }
    } else {
      print('No audio found for character: $character');
      setState(() {
        isLoadingAudio = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final romaji = convertHiraganaToRomaji(
      widget.readings.map((r) => r.reading).join(', '),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Kanji: ${widget.kanji.characters}'),
        actions: [
          IconButton(
            icon: isLoadingAudio
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Icon(Icons.volume_up),
            onPressed: isLoadingAudio
                ? null
                : () => playPronunciation(widget.kanji.characters),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.kanji.characters,
                    style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      if (isPlaying) {
                        _audioPlayer.stop();
                        setState(() {
                          isPlaying = false;
                          isLoadingAudio = false;
                        });
                      } else {
                        playPronunciation(widget.kanji.characters);
                      }
                    },
                    icon: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: isLoadingAudio
                          ? JumpingDotsLoadingIndicator(
                              color: Colors.black,
                              size: 8,
                            )
                          : Icon(
                              isPlaying ? Icons.stop : Icons.volume_up,
                              key: ValueKey<String>("volume_icon"),
                              size: 30,
                              color: Colors.black,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Meanings: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        widget.kanji.meanings.map((m) => m.meaning).join(', '),
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Reading: ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: widget.kanji.readings
                              .map((m) => m.reading)
                              .join(', '),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Romaji: ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: romaji,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Example:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...widget.kanji.contextSentences.map(
              (sentence) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('- "${sentence.ja}" - ${sentence.en}',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

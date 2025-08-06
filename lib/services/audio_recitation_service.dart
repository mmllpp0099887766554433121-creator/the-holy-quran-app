import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/quran_models.dart';
import 'database_service.dart';

class AudioRecitationService {
  static AudioRecitationService? _instance;
  static AudioRecitationService get instance => _instance ??= AudioRecitationService._();
  AudioRecitationService._();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();
  
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _isInitialized = false;
  
  StreamController<PlayerState>? _playerStateController;
  StreamController<Duration>? _positionController;
  StreamController<String>? _speechController;
  
  Stream<PlayerState> get playerStateStream => 
      _playerStateController?.stream ?? Stream.empty();
  Stream<Duration> get positionStream => 
      _positionController?.stream ?? Stream.empty();
  Stream<String> get speechStream => 
      _speechController?.stream ?? Stream.empty();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _playerStateController = StreamController<PlayerState>.broadcast();
    _positionController = StreamController<Duration>.broadcast();
    _speechController = StreamController<String>.broadcast();
    
    // Initialize audio player
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _playerStateController?.add(state);
    });
    
    _audioPlayer.onPositionChanged.listen((position) {
      _positionController?.add(position);
    });
    
    // Initialize speech recognition
    await _initializeSpeechRecognition();
    
    _isInitialized = true;
  }

  Future<void> _initializeSpeechRecognition() async {
    final permission = await Permission.microphone.request();
    if (permission.isGranted) {
      await _speechToText.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
    }
  }

  // Audio playback methods
  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    try {
      // In a real app, this would load from local assets or cache
      final audioPath = 'assets/audio/quran/${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';
      
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      print('Error playing ayah: $e');
      // Fallback to text-to-speech or show error
    }
  }

  Future<void> playSurah(int surahNumber, {int? startFromAyah}) async {
    final surah = DatabaseService.instance.getSurah(surahNumber);
    if (surah == null) return;
    
    final startIndex = (startFromAyah ?? 1) - 1;
    
    for (int i = startIndex; i < surah.ayahs.length; i++) {
      if (!_isPlaying) break;
      
      await playAyah(surahNumber, i + 1);
      
      // Wait for current ayah to finish before playing next
      await _waitForAyahToFinish();
      
      // Add pause between ayahs
      await Future.delayed(Duration(seconds: 2));
    }
  }

  Future<void> _waitForAyahToFinish() async {
    while (_isPlaying) {
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> pausePlayback() async {
    await _audioPlayer.pause();
  }

  Future<void> resumePlayback() async {
    await _audioPlayer.resume();
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Guided recitation mode
  Future<void> startGuidedRecitation(int surahNumber) async {
    final surah = DatabaseService.instance.getSurah(surahNumber);
    if (surah == null) return;
    
    for (final ayah in surah.ayahs) {
      // Play ayah
      await playAyah(surahNumber, ayah.numberInSurah);
      await _waitForAyahToFinish();
      
      // Pause for reflection/repetition
      await Future.delayed(Duration(seconds: 3));
      
      // Show tafsir or translation (would be implemented in UI)
      _showAyahReflection(ayah);
      
      // Wait for user to continue
      await _waitForUserInput();
    }
  }

  void _showAyahReflection(Ayah ayah) {
    // This would trigger UI to show reflection/tafsir
    // Implementation would be in the UI layer
  }

  Future<void> _waitForUserInput() async {
    // This would wait for user to tap continue
    // Implementation would be in the UI layer
    await Future.delayed(Duration(seconds: 5)); // Placeholder
  }

  // Speech recognition for memorization practice
  Future<void> startRecitationPractice(int surahNumber, int ayahNumber) async {
    if (!_speechToText.isAvailable) {
      await _initializeSpeechRecognition();
    }
    
    if (!_speechToText.isAvailable) {
      throw Exception('Speech recognition not available');
    }
    
    final ayah = DatabaseService.instance.getAyah(surahNumber, ayahNumber);
    if (ayah == null) return;
    
    _isRecording = true;
    
    await _speechToText.listen(
      onResult: (result) {
        final spokenText = result.recognizedWords;
        _speechController?.add(spokenText);
        
        if (result.finalResult) {
          _analyzeRecitation(ayah.text, spokenText, surahNumber, ayahNumber);
        }
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      localeId: 'ar_SA', // Arabic locale
    );
  }

  Future<void> stopRecitationPractice() async {
    if (_isRecording) {
      await _speechToText.stop();
      _isRecording = false;
    }
  }

  void _analyzeRecitation(String originalText, String spokenText, 
      int surahNumber, int ayahNumber) {
    
    final accuracy = _calculateAccuracy(originalText, spokenText);
    final mistakes = _findMistakes(originalText, spokenText);
    
    // Store results for memorization service
    if (accuracy < 0.8) {
      // Record mistakes for spaced repetition
      for (final mistake in mistakes) {
        // This would be handled by memorization service
      }
    }
    
    // Provide feedback (would be handled in UI)
    _provideFeedback(accuracy, mistakes);
  }

  double _calculateAccuracy(String original, String spoken) {
    // Simple word-based accuracy calculation
    final originalWords = _normalizeArabicText(original).split(' ');
    final spokenWords = _normalizeArabicText(spoken).split(' ');
    
    int matches = 0;
    final minLength = originalWords.length < spokenWords.length 
        ? originalWords.length 
        : spokenWords.length;
    
    for (int i = 0; i < minLength; i++) {
      if (originalWords[i] == spokenWords[i]) {
        matches++;
      }
    }
    
    return matches / originalWords.length;
  }

  List<String> _findMistakes(String original, String spoken) {
    final mistakes = <String>[];
    final originalWords = _normalizeArabicText(original).split(' ');
    final spokenWords = _normalizeArabicText(spoken).split(' ');
    
    for (int i = 0; i < originalWords.length && i < spokenWords.length; i++) {
      if (originalWords[i] != spokenWords[i]) {
        mistakes.add('Expected: ${originalWords[i]}, Spoken: ${spokenWords[i]}');
      }
    }
    
    return mistakes;
  }

  String _normalizeArabicText(String text) {
    return text
        .replaceAll(RegExp(r'[َُِّْ]'), '') // Remove diacritics
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }

  void _provideFeedback(double accuracy, List<String> mistakes) {
    // This would trigger UI feedback
    print('Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%');
    if (mistakes.isNotEmpty) {
      print('Mistakes found: ${mistakes.length}');
    }
  }

  // Playlist functionality
  Future<void> playPlaylist(List<AyahReference> playlist) async {
    for (final ref in playlist) {
      if (!_isPlaying) break;
      
      await playAyah(ref.surahNumber, ref.ayahNumber);
      await _waitForAyahToFinish();
      
      // Add pause between ayahs
      await Future.delayed(Duration(seconds: 1));
    }
  }

  // Background audio settings
  Future<void> setPlaybackSpeed(double speed) async {
    await _audioPlayer.setPlaybackRate(speed);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Cleanup
  void dispose() {
    _audioPlayer.dispose();
    _speechToText.cancel();
    _playerStateController?.close();
    _positionController?.close();
    _speechController?.close();
  }

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
}
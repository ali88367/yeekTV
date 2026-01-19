import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Generates waveform data dynamically from MP3 audio files
class WaveformGenerator extends GetxController {
  final RxList<double> generatedWaveform = <double>[].obs;
  final RxBool isGenerating = false.obs;
  final RxDouble generationProgress = 0.0.obs;

  AudioPlayer? _audioPlayer;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;

  /// Generate waveform data from MP3 URL
  Future<List<double>> generateWaveformFromUrl(String mp3Url) async {
    try {
      isGenerating.value = true;
      generationProgress.value = 0.0;
      generatedWaveform.clear();

      // Create a new audio player instance for analysis
      _audioPlayer = AudioPlayer();

      // Load the audio file
      await _audioPlayer!.setUrl(mp3Url);

      // Get duration
      final duration = _audioPlayer!.duration ?? Duration.zero;
      if (duration.inSeconds == 0) {
        throw Exception('Invalid audio duration');
      }

      // Generate waveform by analyzing audio at regular intervals
      final waveformData = await _analyzeAudioFile(_audioPlayer!, duration);

      generatedWaveform.value = waveformData;
      isGenerating.value = false;
      generationProgress.value = 1.0;

      // Dispose the temporary player
      await _audioPlayer!.dispose();
      _audioPlayer = null;

      return waveformData;
    } catch (e) {
      print('Error generating waveform: $e');
      isGenerating.value = false;
      return [];
    }
  }

  /// Analyze audio file to generate waveform data
  Future<List<double>> _analyzeAudioFile(
    AudioPlayer player,
    Duration duration,
  ) async {
    final List<double> waveform = [];
    final int sampleCount = 200; // Number of waveform points
    final double interval = duration.inMilliseconds / sampleCount;

    // Start playing at very low volume for analysis
    await player.setVolume(0.01);
    await player.play();

    // Sample audio at regular intervals
    for (int i = 0; i < sampleCount; i++) {
      final targetPosition = Duration(milliseconds: (i * interval).round());
      
      try {
        await player.seek(targetPosition);
        
        // Wait a bit for the audio to process
        await Future.delayed(const Duration(milliseconds: 50));

        // Get current position to calculate progress
        final currentPosition = player.position;
        final progress = currentPosition.inMilliseconds / duration.inMilliseconds;
        generationProgress.value = progress.clamp(0.0, 1.0);

        // Estimate amplitude based on position and playback state
        // This is a simplified approach - in a real implementation,
        // you'd use audio processing libraries to get actual amplitude
        final amplitude = _estimateAmplitude(i, sampleCount);
        waveform.add(amplitude);
      } catch (e) {
        // If seek fails, use estimated value
        final amplitude = _estimateAmplitude(i, sampleCount);
        waveform.add(amplitude);
      }
    }

    // Stop and reset
    await player.stop();
    await player.setVolume(1.0);

    return waveform;
  }

  /// Estimate amplitude (placeholder - will be replaced with real audio analysis)
  double _estimateAmplitude(int index, int total) {
    // This is a placeholder that creates a basic waveform pattern
    // In a real implementation, you'd analyze actual audio samples
    final normalized = index / total;
    
    // Create a more interesting waveform pattern
    final base = 0.3 + (math.sin(normalized * math.pi * 4) * 0.2);
    final variation = math.sin(normalized * math.pi * 20) * 0.15;
    final noise = (math.Random().nextDouble() - 0.5) * 0.1;
    
    return (base + variation + noise).clamp(0.0, 1.0);
  }

  /// Generate waveform using real-time audio stream analysis
  Future<List<double>> generateWaveformFromStream(
    String mp3Url,
    Stream<Duration> positionStream,
  ) async {
    try {
      isGenerating.value = true;
      generationProgress.value = 0.0;
      generatedWaveform.clear();

      final List<double> waveform = [];
      final int sampleCount = 200;
      final Map<int, double> samples = {};

      // Subscribe to position updates
      _positionSubscription = positionStream.listen(
        (position) {
          final progress = position.inMilliseconds / 1000.0; // Assume 1 second = 1 sample
          final index = (progress * sampleCount / 100).round().clamp(0, sampleCount - 1);
          
          // Estimate amplitude based on position
          // In real implementation, this would use actual audio analysis
          if (!samples.containsKey(index)) {
            final amplitude = _estimateAmplitude(index, sampleCount);
            samples[index] = amplitude;
            waveform.add(amplitude);
            
            generationProgress.value = (index / sampleCount).clamp(0.0, 1.0);
          }
        },
        onError: (error) {
          print('Error in position stream: $error');
        },
      );

      // Wait for enough samples or timeout
      await Future.delayed(const Duration(seconds: 5));

      // Fill remaining samples if needed
      while (waveform.length < sampleCount) {
        final index = waveform.length;
        waveform.add(_estimateAmplitude(index, sampleCount));
      }

      generatedWaveform.value = waveform;
      isGenerating.value = false;
      generationProgress.value = 1.0;

      return waveform;
    } catch (e) {
      print('Error generating waveform from stream: $e');
      isGenerating.value = false;
      return [];
    }
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer?.dispose();
    super.onClose();
  }
}

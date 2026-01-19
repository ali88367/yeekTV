import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:audio_visualizer/audio_visualizer.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/s3_url_fix.dart';

/// Service to generate waveform data dynamically from MP3 audio files
/// Uses audio_visualizer package to extract real waveform data from MP3 URLs
class AudioWaveformService extends GetxController {
  // NOTE:
  // On iOS, audio_visualizer behaves like a singleton under the hood. Creating multiple
  // VisualizerPlayer instances can lead to "PLAYER_ALREADY_INITIALIZED" and players that
  // never become ready. We therefore use ONE shared VisualizerPlayer and switch its source.
  VisualizerPlayer? _player;
  String? _currentUrl;
  Future<void>? _initFuture;
  Future<void>? _loadFuture;

  final RxMap<String, List<double>> _waveformCache =
      <String, List<double>>{}.obs;
  final RxMap<String, bool> _generatingStatus = <String, bool>{}.obs;

  Future<void> _ensureInitialized() async {
    _initFuture ??= () async {
      final p = VisualizerPlayer();
      await p.initialize();
      _player = p;
    }();
    await _initFuture;
  }

  Future<void> _prepare(String mp3Url) async {
    final fixedUrl = fixS3UrlFormat(mp3Url);

    if (_currentUrl == fixedUrl && _player != null) {
      // Ensure it keeps running
      try {
        if (_player!.value.status == PlayerStatus.ready &&
            _player!.value.status != PlayerStatus.playing) {
          await _player!.play(looping: true);
        }
      } catch (_) {}
      return;
    }

    await _ensureInitialized();
    if (_player == null) return;

    // Avoid parallel source changes
    _loadFuture ??= () async {
      try {
        // Stop previous (best-effort)
        try {
          await _player!.stop();
        } catch (_) {}

        await _player!.setDataSource(fixedUrl);

        // Wait for ready (timeout ~20s)
        final start = DateTime.now();
        while (_player!.value.status != PlayerStatus.ready) {
          if (DateTime.now().difference(start) > const Duration(seconds: 20)) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 200));
        }

        _currentUrl = fixedUrl;

        // Start playing to generate FFT/waveform continuously
        if (_player!.value.status == PlayerStatus.ready) {
          try {
            await _player!.play(looping: true);
          } catch (_) {}
        }
      } finally {
        _loadFuture = null;
      }
    }();

    await _loadFuture;
  }

  /// Generate waveform data for a track from its MP3 URL
  /// Uses audio_visualizer to extract real waveform data
  Future<List<double>> generateWaveformForTrack({
    required String mp3Url,
    required AudioPlayer audioPlayer,
    required double duration,
  }) async {
    final fixedUrl = fixS3UrlFormat(mp3Url);

    // Check cache first
    if (_waveformCache.containsKey(fixedUrl)) {
      return _waveformCache[fixedUrl]!;
    }

    // Check if already generating
    if (_generatingStatus[fixedUrl] == true) {
      // Wait for generation to complete
      while (_generatingStatus[fixedUrl] == true) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_waveformCache.containsKey(fixedUrl)) {
        return _waveformCache[fixedUrl]!;
      }
    }

    _generatingStatus[fixedUrl] = true;

    try {
      print(
        'Generating waveform from MP3 URL using audio_visualizer: $fixedUrl',
      );

      await _prepare(fixedUrl);
      final visualizerPlayer = _player;
      if (visualizerPlayer == null ||
          visualizerPlayer.value.status != PlayerStatus.ready) {
        throw Exception('VisualizerPlayer not ready');
      }

      // Extract waveform data from visualizer
      final waveformData = _extractWaveformFromVisualizer(visualizerPlayer);

      _waveformCache[fixedUrl] = waveformData;
      print('Waveform generated successfully: ${waveformData.length} points');
      return waveformData;
    } catch (e) {
      print('Error generating waveform for $fixedUrl: $e');
      // Return fallback waveform
      return _generateFallbackWaveform(duration);
    } finally {
      _generatingStatus[fixedUrl] = false;
    }
  }

  /// Extract waveform data from VisualizerPlayer
  List<double> _extractWaveformFromVisualizer(VisualizerPlayer player) {
    // Get waveform data from visualizer
    final waveform = player.value.waveform;

    if (waveform.isEmpty) {
      // If waveform is empty, use FFT data to generate waveform
      return _generateWaveformFromFFT(player);
    }

    // Normalize waveform data to 0.0-1.0 range
    final normalizedWaveform = waveform.map((value) {
      // Waveform values are typically in range -1.0 to 1.0
      return ((value.abs() * 0.5) + 0.5).clamp(0.0, 1.0);
    }).toList();

    // Resample to 200 points if needed
    if (normalizedWaveform.length > 200) {
      return _resampleWaveform(normalizedWaveform, 200);
    } else if (normalizedWaveform.length < 200) {
      return _interpolateWaveform(normalizedWaveform, 200);
    }

    return normalizedWaveform;
  }

  /// Generate waveform from FFT data
  List<double> _generateWaveformFromFFT(VisualizerPlayer player) {
    final fft = player.value.fft;
    if (fft.isEmpty) {
      return _generateFallbackWaveform(1.0);
    }

    // Convert FFT magnitudes to waveform-like data
    final waveform = <double>[];
    final targetLength = 200;
    final fftLength = fft.length;

    for (int i = 0; i < targetLength; i++) {
      final fftIndex = (i * fftLength / targetLength).floor();
      if (fftIndex < fftLength) {
        // Use magnitude of FFT data
        final magnitude = (fft[fftIndex] as num).toDouble().abs();
        waveform.add(magnitude.clamp(0.0, 1.0));
      } else {
        waveform.add(0.0);
      }
    }

    return waveform;
  }

  /// Resample waveform to target length (downsample)
  List<double> _resampleWaveform(List<double> waveform, int targetLength) {
    final result = <double>[];
    final ratio = waveform.length / targetLength;

    for (int i = 0; i < targetLength; i++) {
      final startIndex = (i * ratio).floor();
      final endIndex = ((i + 1) * ratio).floor();

      if (endIndex > startIndex) {
        double sum = 0.0;
        for (int j = startIndex; j < endIndex && j < waveform.length; j++) {
          sum += waveform[j];
        }
        result.add(sum / (endIndex - startIndex));
      } else {
        result.add(waveform[startIndex.clamp(0, waveform.length - 1)]);
      }
    }

    return result;
  }

  /// Interpolate waveform to target length (upsample)
  List<double> _interpolateWaveform(List<double> waveform, int targetLength) {
    if (waveform.isEmpty) {
      return List.filled(targetLength, 0.0);
    }

    final result = <double>[];
    final ratio = (waveform.length - 1) / (targetLength - 1);

    for (int i = 0; i < targetLength; i++) {
      final position = i * ratio;
      final index = position.floor();
      final fraction = position - index;

      if (index >= waveform.length - 1) {
        result.add(waveform.last);
      } else {
        // Linear interpolation
        final value =
            waveform[index] * (1 - fraction) + waveform[index + 1] * fraction;
        result.add(value);
      }
    }

    return result;
  }

  /// Generate fallback waveform when analysis fails
  List<double> _generateFallbackWaveform(double duration) {
    final int sampleCount = 200;
    final List<double> waveform = [];

    for (int i = 0; i < sampleCount; i++) {
      final normalized = i / sampleCount;
      final base = 0.25 + (0.25 * math.sin(normalized * math.pi * 6));
      waveform.add(base.clamp(0.0, 1.0));
    }

    return waveform;
  }

  /// Get VisualizerPlayer for an MP3 URL (for real-time visualization)
  Future<VisualizerPlayer?> getVisualizerPlayer(String mp3Url) async {
    try {
      await _prepare(mp3Url);
      return _player;
    } catch (e) {
      print('Error getting visualizer player: $e');
      return null;
    }
  }

  /// Clear cache for a specific URL
  void clearCache(String mp3Url) {
    final fixedUrl = fixS3UrlFormat(mp3Url);
    _waveformCache.remove(fixedUrl);
    _generatingStatus.remove(fixedUrl);
    // If clearing current url, reset it (player is shared)
    if (_currentUrl == fixedUrl) {
      _currentUrl = null;
    }
  }

  /// Clear all cache
  void clearAllCache() {
    _waveformCache.clear();
    _generatingStatus.clear();
    _currentUrl = null;
  }

  @override
  void onClose() {
    clearAllCache();
    try {
      _player?.dispose();
    } catch (_) {}
    _player = null;
    super.onClose();
  }
}

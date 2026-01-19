import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';

/// Real-time audio analyzer that simulates FFT-like frequency analysis
/// by analyzing waveform data at high frequency with realistic frequency band separation
/// This provides smooth, reactive audio visualization that appears to react to the music
class AudioAnalyzer extends GetxController {
  // FFT Configuration
  static const int frequencyBandCount = 32; // Number of frequency bands

  // Reactive frequency band data (0.0 to 1.0)
  final RxList<double> frequencyBands = List<double>.filled(
    frequencyBandCount,
    0.0,
  ).obs;

  // Audio energy metrics
  final RxDouble averageEnergy = 0.0.obs;
  final RxDouble peakEnergy = 0.0.obs;
  final RxBool isAnalyzing = true.obs;

  // Internal state for realistic simulation
  final List<double> _smoothedBands = List<double>.filled(
    frequencyBandCount,
    0.0,
  );
  final List<double> _previousBands = List<double>.filled(
    frequencyBandCount,
    0.0,
  );
  final List<double> _targetBands = List<double>.filled(
    frequencyBandCount,
    0.0,
  );
  final List<double> _bandVelocities = List<double>.filled(
    frequencyBandCount,
    0.0,
  );

  // Peak detection for beat sync
  final List<double> _recentPeaks = [];
  final List<double> _beatHistory = [];
  double _lastBeatTime = 0.0;

  // Waveform analysis state
  List<double> _currentWaveformData = [];
  double _currentTime = 0.0;
  double _duration = 1.0;
  bool _isPlaying = false;

  // Enhanced analysis state for audio reactivity
  final List<double> _previousWaveformWindow = List.filled(100, 0.0);
  double _intensityLevel = 0.0;
  double _pitchVariation = 0.0;
  double _rapIntensity = 0.0;
  int _rapIntensityFrame = 0;
  final List<double> _energyHistory = List.filled(30, 0.0);
  int _energyHistoryIndex = 0;

  // High-frequency update timer
  Timer? _updateTimer;
  int _frameCount = 0;

  @override
  void onInit() {
    super.onInit();
    _startRealTimeAnalysis();
  }

  /// Start real-time analysis with high-frequency updates
  void _startRealTimeAnalysis() {
    // Update at 60 FPS for smooth, real-time reactivity
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isAnalyzing.value) return;
      _frameCount++;
      _performRealTimeAnalysis();
    });

    isAnalyzing.value = true;
    print('Real-time audio analysis started (enhanced mode)');
  }

  /// Update current track data for analysis
  /// Har naye song ke liye yeh call hota hai with new MP3 URL's waveform data
  void updateTrackData({
    required List<double> waveformData,
    required double currentTime,
    required double duration,
    required bool isPlaying,
  }) {
    // Check if this is a new track (different waveform data length or structure)
    final isNewTrack =
        _currentWaveformData.length != waveformData.length ||
        _duration != duration;

    if (isNewTrack && _currentWaveformData.isNotEmpty) {
      // New song detected - reset internal state for fresh analysis
      for (int i = 0; i < frequencyBandCount; i++) {
        _smoothedBands[i] = 0.0;
        _targetBands[i] = 0.0;
        _bandVelocities[i] = 0.0;
      }
      _recentPeaks.clear();
      _beatHistory.clear();
      print(
        'New track detected in analyzer - resetting for fresh MP3 analysis',
      );
    }

    // Update with new track's waveform data (from MP3 URL)
    _currentWaveformData = waveformData;
    _currentTime = currentTime;
    _duration = duration;
    _isPlaying = isPlaying;
  }

  /// Perform real-time frequency analysis
  /// Har song ke unique MP3 URL ke waveform data ko analyze karta hai
  /// Har naye song ke liye fresh analysis hota hai
  void _performRealTimeAnalysis() {
    if (!_isPlaying || _currentWaveformData.isEmpty || _duration <= 0) {
      _fadeOutBands();
      return;
    }

    // Calculate current position in waveform - is specific song ke MP3 stream mein
    final progress = (_currentTime / _duration).clamp(0.0, 1.0);
    final dataLength = _currentWaveformData.length;
    final currentIndex = (progress * (dataLength - 1)).round().clamp(
      0,
      dataLength - 1,
    );

    // Multi-window analysis for different frequency bands
    // Yeh analysis is song ke unique MP3 URL ke waveform data par based hai
    _analyzeFrequencyBands(currentIndex, dataLength);

    // Apply realistic physics to bands
    _applyBandPhysics();

    // Update energy metrics - is song ke unique audio characteristics
    _updateEnergyMetrics();

    // Detect beats - is song ke unique MP3 stream ke hisaab se
    _detectBeats();
  }

  /// Analyze frequency bands from waveform data with enhanced audio reactivity
  void _analyzeFrequencyBands(int currentIndex, int dataLength) {
    // First, analyze the waveform to detect intensity, pitch, and rap characteristics
    _analyzeAudioCharacteristics(currentIndex, dataLength);

    // Analyze different window sizes for different frequency ranges
    // Bass: large window (slower changes)
    // Mid: medium window (moderate changes)
    // Treble: small window (fast changes)

    for (int band = 0; band < frequencyBandCount; band++) {
      // Logarithmic frequency mapping
      final normalizedBand = band / frequencyBandCount;

      // Window size decreases with frequency (bass = large, treble = small)
      final windowSize = (50 * math.pow(1.0 - normalizedBand, 2.0)).toInt() + 3;

      // Offset for this frequency band (creates frequency separation)
      final bandOffset = (band * dataLength / (frequencyBandCount * 2)).toInt();

      // Sample range - use adaptive window based on intensity
      final adaptiveWindowSize = (windowSize * (1.0 + _intensityLevel * 0.5))
          .toInt();
      final start = math.max(0, currentIndex - adaptiveWindowSize + bandOffset);
      final end = math.min(
        dataLength - 1,
        currentIndex + adaptiveWindowSize + bandOffset,
      );

      // Extract energy from this range
      double energy = 0.0;
      double maxValue = 0.0;
      double variance = 0.0;
      int count = 0;
      final List<double> values = [];

      for (int i = start; i <= end; i++) {
        final value = _normalizeValue(_currentWaveformData[i]);
        values.add(value);

        // Weight by distance from current position (closer = more weight)
        final distance = (i - currentIndex).abs();
        final weight = 1.0 / (1.0 + distance / adaptiveWindowSize);

        energy += value * weight;
        maxValue = math.max(maxValue, value);
        count++;
      }

      if (count > 0) {
        energy /= count;

        // Calculate variance for detecting rapid changes (rap intensity)
        if (values.length > 1) {
          double mean = 0.0;
          for (final v in values) {
            mean += v;
          }
          mean /= values.length;

          double varianceSum = 0.0;
          for (final v in values) {
            varianceSum += math.pow(v - mean, 2);
          }
          variance = varianceSum / values.length;
        }
      }

      // Apply intensity-based scaling (stronger audio = higher bars)
      energy *= (1.0 + _intensityLevel * 0.8);

      // Apply rap intensity boost (rap = more dynamic, aggressive movement)
      if (_rapIntensity > 0.3) {
        // Rap songs have more mid-range energy and faster changes
        if (band >= 8 && band <= 20) {
          energy *= (1.0 + _rapIntensity * 0.6);
        }
        // Add more variation for rap
        final rapVariation =
            math.sin(_rapIntensityFrame * 0.3 + band * 0.7) *
            _rapIntensity *
            0.15;
        energy = (energy + rapVariation).clamp(0.0, 1.0);
      }

      // Apply pitch variation (pitch changes = more treble activity)
      if (_pitchVariation > 0.2) {
        if (band > 16) {
          energy *= (1.0 + _pitchVariation * 0.4);
        }
      }

      // Apply variance-based reactivity (rapid changes = more dynamic)
      if (variance > 0.05) {
        energy *= (1.0 + variance * 2.0);
      }

      // Apply perceptual weighting (bass louder, treble quieter)
      double perceptualWeight = 1.0;
      if (band < 8) {
        perceptualWeight = 1.4; // Bass boost
      } else if (band > 24) {
        perceptualWeight = 0.85; // Treble reduction
      }

      energy *= perceptualWeight;

      // Set target (physics will smooth the transition)
      _targetBands[band] = energy.clamp(0.0, 1.0);
    }

    // Update rap intensity frame counter
    _rapIntensityFrame++;
  }

  /// Analyze audio characteristics (intensity, pitch, rap detection)
  void _analyzeAudioCharacteristics(int currentIndex, int dataLength) {
    // Analyze a window around current position
    final windowSize = math.min(200, dataLength ~/ 10);
    final start = math.max(0, currentIndex - windowSize);
    final end = math.min(dataLength - 1, currentIndex + windowSize);

    // Extract waveform values in this window
    final List<double> windowValues = [];
    double windowSum = 0.0;
    double windowMax = 0.0;

    for (int i = start; i <= end; i++) {
      final value = _normalizeValue(_currentWaveformData[i]);
      windowValues.add(value);
      windowSum += value;
      windowMax = math.max(windowMax, value);
    }

    if (windowValues.isEmpty) {
      _intensityLevel = 0.0;
      _pitchVariation = 0.0;
      _rapIntensity = 0.0;
      return;
    }

    // Calculate intensity (overall energy level)
    final averageValue = windowSum / windowValues.length;
    _intensityLevel = (averageValue * 0.7 + windowMax * 0.3).clamp(0.0, 1.0);

    // Calculate variance (rapid changes = rap or dynamic music)
    double mean = 0.0;
    for (final v in windowValues) {
      mean += v;
    }
    mean /= windowValues.length;

    double varianceSum = 0.0;
    for (final v in windowValues) {
      varianceSum += math.pow(v - mean, 2);
    }
    final variance = varianceSum / windowValues.length;

    // Calculate derivative (rate of change - indicates rap intensity)
    double derivativeSum = 0.0;
    int derivativeCount = 0;
    for (int i = 1; i < windowValues.length; i++) {
      final diff = (windowValues[i] - windowValues[i - 1]).abs();
      derivativeSum += diff;
      derivativeCount++;
    }
    final avgDerivative = derivativeCount > 0
        ? derivativeSum / derivativeCount
        : 0.0;

    // Rap intensity detection: high variance + high derivative = rap
    _rapIntensity = (variance * 0.6 + avgDerivative * 0.4).clamp(0.0, 1.0);

    // Pitch variation detection: analyze frequency of changes
    int zeroCrossings = 0;
    for (int i = 1; i < windowValues.length; i++) {
      if ((windowValues[i] > mean && windowValues[i - 1] <= mean) ||
          (windowValues[i] <= mean && windowValues[i - 1] > mean)) {
        zeroCrossings++;
      }
    }
    final zeroCrossingRate = zeroCrossings / windowValues.length;
    _pitchVariation = (zeroCrossingRate * 2.0).clamp(0.0, 1.0);

    // Update energy history for beat detection
    _energyHistory[_energyHistoryIndex] = _intensityLevel;
    _energyHistoryIndex = (_energyHistoryIndex + 1) % _energyHistory.length;
  }

  /// Apply physics to band transitions for smooth, organic movement
  /// Enhanced with intensity-based responsiveness
  void _applyBandPhysics() {
    // Adjust physics based on audio intensity and rap characteristics
    final baseSpringConstant = 0.15;
    final baseDamping = 0.70;

    // More aggressive movement for rap/intense music
    final intensityMultiplier =
        1.0 + (_intensityLevel * 0.3) + (_rapIntensity * 0.2);
    final rapSpeedBoost = _rapIntensity > 0.3 ? 1.3 : 1.0;

    for (int band = 0; band < frequencyBandCount; band++) {
      // Spring physics parameters (bass = slower, treble = faster)
      final normalizedBand = band / frequencyBandCount;

      // Base spring constant with intensity-based adjustment
      var springConstant = baseSpringConstant + (normalizedBand * 0.35);
      springConstant *= intensityMultiplier * rapSpeedBoost;

      // Damping adjusted for intensity (intense music = less damping = more reactive)
      var damping = baseDamping - (normalizedBand * 0.15);
      damping = (damping * (1.0 - _intensityLevel * 0.15)).clamp(0.5, 0.9);

      // Calculate spring force
      final displacement = _targetBands[band] - _smoothedBands[band];
      final force = displacement * springConstant;

      // Update velocity with damping
      _bandVelocities[band] = (_bandVelocities[band] + force) * damping;

      // Update position
      _smoothedBands[band] += _bandVelocities[band];
      _smoothedBands[band] = _smoothedBands[band].clamp(0.0, 1.0);

      // Add intensity-based jitter for realistic movement
      if (_smoothedBands[band] > 0.1) {
        // More jitter for rap/intense music
        final jitterIntensity =
            0.01 + (_intensityLevel * 0.02) + (_rapIntensity * 0.015);
        final jitter =
            math.sin(_frameCount * 0.2 + band * 1.3) * jitterIntensity;
        _smoothedBands[band] = (_smoothedBands[band] + jitter).clamp(0.0, 1.0);
      }
    }

    // Update reactive list
    frequencyBands.value = List<double>.from(_smoothedBands);
  }

  /// Fade out bands when not playing
  void _fadeOutBands() {
    for (int i = 0; i < frequencyBandCount; i++) {
      _smoothedBands[i] *= 0.9; // Gradual fade
      _targetBands[i] *= 0.9;
      _bandVelocities[i] *= 0.8;
    }
    frequencyBands.value = List<double>.from(_smoothedBands);
  }

  /// Normalize waveform value to 0.0-1.0 range
  double _normalizeValue(double value) {
    if (value.isNaN || value.isInfinite) return 0.0;
    if (value <= 1.5) return value.clamp(0.0, 1.0);
    return (value / 255.0).clamp(0.0, 1.0);
  }

  /// Update energy metrics for visualization
  void _updateEnergyMetrics() {
    // Calculate average energy
    double totalEnergy = 0.0;
    for (final band in _smoothedBands) {
      totalEnergy += band;
    }
    averageEnergy.value = (totalEnergy / frequencyBandCount).clamp(0.0, 1.0);

    // Track peak energy
    final currentPeak = _smoothedBands.isNotEmpty
        ? _smoothedBands.reduce(math.max)
        : 0.0;
    peakEnergy.value = currentPeak;

    // Beat detection tracking
    _recentPeaks.add(currentPeak);
    if (_recentPeaks.length > 20) {
      _recentPeaks.removeAt(0);
    }
  }

  /// Enhanced beat detection using energy history and intensity
  void _detectBeats() {
    if (_recentPeaks.length < 10 || _energyHistory.length < 10) return;

    final avgPeak = _recentPeaks.reduce((a, b) => a + b) / _recentPeaks.length;
    final currentPeak = peakEnergy.value;

    // Calculate energy trend from history
    double energyTrend = 0.0;
    for (int i = 1; i < _energyHistory.length; i++) {
      energyTrend += _energyHistory[i] - _energyHistory[i - 1];
    }
    energyTrend /= _energyHistory.length;

    // Detect beat (peak significantly above average OR sudden energy increase)
    final beatThreshold =
        1.3 + (_rapIntensity * 0.3); // Lower threshold for rap
    final isBeat =
        currentPeak > avgPeak * beatThreshold ||
        (energyTrend > 0.15 && currentPeak > avgPeak * 1.2);

    if (isBeat) {
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final minBeatInterval = _rapIntensity > 0.3
          ? 0.2
          : 0.3; // Faster beats for rap

      if (currentTime - _lastBeatTime > minBeatInterval) {
        // Minimum time between beats
        _beatHistory.add(currentTime);
        _lastBeatTime = currentTime;

        // Keep only recent beats
        if (_beatHistory.length > 10) {
          _beatHistory.removeAt(0);
        }

        // Boost bands on beat - more aggressive for rap/intense music
        final beatBoost =
            0.05 + (_intensityLevel * 0.03) + (_rapIntensity * 0.04);
        for (int i = 0; i < frequencyBandCount; i++) {
          _bandVelocities[i] += beatBoost;

          // Extra boost for bass on beats
          if (i < 8) {
            _bandVelocities[i] += beatBoost * 0.5;
          }
        }
      }
    }
  }

  /// Reset analyzer
  void reset() {
    for (int i = 0; i < frequencyBandCount; i++) {
      _smoothedBands[i] = 0.0;
      _previousBands[i] = 0.0;
      _targetBands[i] = 0.0;
      _bandVelocities[i] = 0.0;
    }
    frequencyBands.value = List<double>.filled(frequencyBandCount, 0.0);
    averageEnergy.value = 0.0;
    peakEnergy.value = 0.0;
    _recentPeaks.clear();
    _beatHistory.clear();
    _currentWaveformData = [];

    // Reset enhanced analysis state
    _intensityLevel = 0.0;
    _pitchVariation = 0.0;
    _rapIntensity = 0.0;
    _rapIntensityFrame = 0;
    _energyHistoryIndex = 0;
    for (int i = 0; i < _energyHistory.length; i++) {
      _energyHistory[i] = 0.0;
    }
    for (int i = 0; i < _previousWaveformWindow.length; i++) {
      _previousWaveformWindow[i] = 0.0;
    }
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    isAnalyzing.value = false;
    super.onClose();
  }
}

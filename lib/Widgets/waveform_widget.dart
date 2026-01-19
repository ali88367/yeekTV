import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:audio_visualizer/audio_visualizer.dart';
import 'package:audio_visualizer/utils.dart';
import '../Controller/audio_player_controller.dart';
import '../utils/audio_waveform_service.dart';
import '../utils/s3_url_fix.dart';

/// Audio-Reactive Waveform Visualizer using audio_visualizer package
/// Generates real-time waveform bars from MP3 URL
class WaveformWidget extends StatefulWidget {
  final String? mp3Url;
  final bool isPlaying;
  final double currentTime;
  final double duration;
  final bool isFullscreen;

  const WaveformWidget({
    Key? key,
    this.mp3Url,
    required this.isPlaying,
    this.currentTime = 0.0,
    this.duration = 0.0,
    this.isFullscreen = false,
  }) : super(key: key);

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> {
  VisualizerPlayer? _visualizerPlayer;
  AudioWaveformService? _waveformService;
  String? _currentMp3Url;
  bool _isInitialized = false;
  bool _isDisposed = false;
  List<double> _previousBarHeights = []; // For temporal smoothing

  @override
  void initState() {
    super.initState();
    _initializeVisualizer();
  }

  Future<void> _initializeVisualizer() async {
    try {
      _waveformService = Get.find<AudioWaveformService>();
      await _loadVisualizerPlayer();
    } catch (e) {
      print('Error initializing visualizer: $e');
    }
  }

  Future<void> _loadVisualizerPlayer() async {
    if (_isDisposed || !mounted) return;

    final controller = Get.find<AudioPlayerController>();
    final track = controller.currentTrack.value;

    if (track == null) return;

    final mp3Url = widget.mp3Url ?? fixS3UrlFormat(track.mp3Url);

    // Only reload if URL changed
    if (_currentMp3Url == mp3Url && _isInitialized) {
      return;
    }

    final prevUrl = _currentMp3Url;
    _currentMp3Url = mp3Url;

    try {
      // Remove listener from previous player (shared player is owned by service)
      if (_visualizerPlayer != null) {
        _visualizerPlayer!.removeListener(_onVisualizerUpdate);
        _visualizerPlayer = null;
      }

      // Get visualizer player from service
      final service = _waveformService ?? Get.find<AudioWaveformService>();
      _waveformService = service;
      final player = await service.getVisualizerPlayer(mp3Url);
      if (_isDisposed || !mounted) return;
      _visualizerPlayer = player;

      if (_visualizerPlayer != null) {
        // Add listener to update when player becomes ready
        _visualizerPlayer!.addListener(_onVisualizerUpdate);

        // Mark as initialized - we'll show bars when data is available
        _isInitialized = true;
        if (mounted && !_isDisposed) {
          setState(() {});
        }
      } else {
        // If the service couldn't provide a player (e.g., still initializing),
        // don't mark initialized; show fallback bars for now.
        _isInitialized = false;
      }
      if (prevUrl != mp3Url) {
        // Force rebuild when url changed
        if (mounted && !_isDisposed) setState(() {});
      }
    } catch (e) {
      print('Error loading visualizer player: $e');
    }
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDisposed || !mounted) return;

    final controller = Get.find<AudioPlayerController>();
    final track = controller.currentTrack.value;

    if (track != null) {
      final mp3Url = widget.mp3Url ?? fixS3UrlFormat(track.mp3Url);

      // Reload if URL changed
      if (_currentMp3Url != mp3Url) {
        _isInitialized = false;
        _loadVisualizerPlayer();
        return;
      }

      // Sync visualizer playback with main audio playback state
      if (oldWidget.isPlaying != widget.isPlaying &&
          _visualizerPlayer != null) {
        _syncVisualizerWithMainAudio();
      }
    }
  }

  /// Sync visualizer playback with main audio playback state
  void _syncVisualizerWithMainAudio() {
    if (_isDisposed || !mounted || _visualizerPlayer == null) return;

    try {
      final status = _visualizerPlayer!.value.status;

      if (widget.isPlaying) {
        // Main audio is playing - ensure visualizer is playing
        if (status == PlayerStatus.ready ||
            status == PlayerStatus.paused ||
            status == PlayerStatus.stopped) {
          // Resume or start playing
          _visualizerPlayer!.play(looping: true).catchError((e) {
            print('Error syncing visualizer play: $e');
          });
        }
      } else {
        // Main audio is paused - pause visualizer too
        if (status == PlayerStatus.playing) {
          _visualizerPlayer!.pause().catchError((e) {
            print('Error syncing visualizer pause: $e');
          });
        }
      }
    } catch (e) {
      print('Error syncing visualizer: $e');
    }
  }

  void _onVisualizerUpdate() {
    if (!_isDisposed && mounted && _visualizerPlayer != null) {
      // Always update UI when visualizer updates
      // This ensures we catch any data changes
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Don't dispose visualizer player - let service manage it
    // This ensures waveform continues working when returning from fullscreen
    _visualizerPlayer?.removeListener(_onVisualizerUpdate);
    _visualizerPlayer = null;
    // Only remove listener, don't dispose - service will manage lifecycle
    // _visualizerPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loader only if not initialized yet
    if (!_isInitialized) {
      return Container(
        width: double.infinity,
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: Colors.transparent,
        ),
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFEFBF04),
              ),
            ),
          ),
        ),
      );
    }

    // If no player yet, show empty bars
    if (_visualizerPlayer == null) {
      return Container(
        width: double.infinity,
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: Colors.transparent,
        ),
        child: CustomPaint(
          painter: WaveformBarPainter(
            barHeights: List.filled(25, 0.2),
            isPlaying: widget.isPlaying,
          ),
          size: Size.infinite,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: Colors.transparent,
      ),
      clipBehavior: Clip.none,
      child: ListenableBuilder(
        listenable: _visualizerPlayer!,
        builder: (context, child) {
          // Get waveform and FFT data
          final waveform = _visualizerPlayer!.value.waveform;
          final fft = _visualizerPlayer!.value.fft;

          // Prioritize FFT data for real-time visualization (better for music)
          // FFT provides frequency domain data that changes with the music
          if (fft.isNotEmpty) {
            // Use FFT data - this is better for real-time audio visualization
            final fftData = getMagnitudes(fft);
            final fftDouble = fftData
                .map((e) => (e.toDouble() / 255.0).clamp(0.0, 1.0))
                .toList();

            return _buildBarVisualizerFromFFT(fftDouble);
          } else if (waveform.isNotEmpty) {
            // Fallback to waveform data if FFT not available
            final waveformDouble = waveform
                .map((e) => (e.toDouble() / 32768.0).abs().clamp(0.0, 1.0))
                .toList();
            return _buildBarVisualizer(waveformDouble);
          }

          // Fallback: show static bars while loading or if no data
          return CustomPaint(
            painter: WaveformBarPainter(
              barHeights: List.filled(25, 0.2),
              isPlaying: widget.isPlaying,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildBarVisualizer(List<double> waveform) {
    // Normalize waveform to 0.0-1.0 range
    final normalizedWaveform = waveform.map((value) {
      return value.abs().clamp(0.0, 1.0);
    }).toList();

    // Resample to 25 bars (matching original design)
    final barCount = 25;
    final barData = _resampleToBars(normalizedWaveform, barCount);

    return CustomPaint(
      key: ValueKey(
        'waveform_${waveform.hashCode}',
      ), // Force repaint when data changes
      painter: WaveformBarPainter(
        barHeights: barData,
        isPlaying: widget.isPlaying,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildBarVisualizerFromFFT(List<double> fftMagnitudes) {
    // Convert FFT magnitudes to bar heights using logarithmic mapping
    // This provides better visualization of frequency spectrum
    final barCount = 25;
    final barData = <double>[];

    if (fftMagnitudes.isEmpty) {
      final defaultHeights = List.filled(barCount, 0.08);
      _previousBarHeights = defaultHeights;
      return CustomPaint(
        painter: WaveformBarPainter(
          barHeights: defaultHeights,
          isPlaying: widget.isPlaying,
        ),
        size: Size.infinite,
      );
    }

    // Map FFT data from center outward (symmetric flow)
    // Center bars get strongest data, flows outward symmetrically
    final centerBarIndex = (barCount - 1) / 2; // 12 (center of 25 bars)
    final animatedBarStart = 4; // Left static bars end
    final animatedBarEnd = barCount - 4; // Right static bars start (21)

    // First pass: calculate raw magnitudes
    final rawMagnitudes = <double>[];
    double maxCenterMagnitude =
        0.0; // Track center bar max for capping edge bars

    for (int i = 0; i < barCount; i++) {
      // Left 4 bars (0-3) and Right 4 bars (21-24) are static (smaller height)
      if (i < animatedBarStart || i >= animatedBarEnd) {
        rawMagnitudes.add(0.08); // Static height - smaller like unmoving bars
        continue;
      }

      // For animated center bars: map from center outward
      // Calculate distance from center (0 = center, higher = further out)
      final distanceFromCenter = (i - centerBarIndex).abs();
      final maxDistance =
          centerBarIndex -
          animatedBarStart; // 8 (from center to edge of animated area)

      // Map distance to FFT index (center gets lower frequencies/bass, edges get higher)
      // Invert so center gets stronger data
      final normalizedDistance =
          distanceFromCenter / maxDistance; // 0.0 (center) to 1.0 (edge)
      final invertedDistance =
          1.0 - normalizedDistance; // 1.0 (center) to 0.0 (edge)

      // Map to FFT index - center gets lower frequencies (stronger), edges get higher frequencies
      final fftIndex = (invertedDistance * (fftMagnitudes.length - 1))
          .floor()
          .clamp(0, fftMagnitudes.length - 1);

      // Get magnitude and apply smoothing by averaging nearby values
      double magnitude = fftMagnitudes[fftIndex];

      // Average with nearby bins for smoother visualization
      if (fftIndex > 0 && fftIndex < fftMagnitudes.length - 1) {
        magnitude =
            (fftMagnitudes[fftIndex - 1] +
                fftMagnitudes[fftIndex] +
                fftMagnitudes[fftIndex + 1]) /
            3.0;
      }

      // Apply movement intensity based on distance from center
      // Use cubic curve for stronger reduction of edge bar movement
      final centerBoost = math
          .pow(1.0 - normalizedDistance, 2.5)
          .toDouble(); // Stronger curve: 1.0 at center, ~0.0 at edges

      magnitude = magnitude.clamp(0.0, 1.0);
      magnitude = math
          .pow(magnitude, 0.6)
          .toDouble(); // lifts low values, keeps peaks

      // Apply amplification with strong center focus and reduced edge movement
      // Center: 2.6x, Edges: 0.9x (much less movement for edge bars)
      // Increase heights significantly in fullscreen mode for better visibility
      final baseAmplification =
          0.9 + centerBoost * 1.7; // 2.6 at center, 0.9 at edges
      final fullscreenMultiplier = widget.isFullscreen
          ? 2.5
          : 1.0; // 150% increase in fullscreen (much taller bars)
      final amplification = baseAmplification * fullscreenMultiplier;
      magnitude = (magnitude * amplification).clamp(0.0, 1.0);

      // Apply movement reduction factor for side bars (more aggressive for edge bars)
      // Edge bars (4 and 20) get much less movement
      final isEdgeBar = (i == animatedBarStart || i == animatedBarEnd - 1);
      final edgeReduction = isEdgeBar
          ? 0.4
          : 0.6; // Edge bars: 40%, others: 60%+
      final movementIntensity =
          edgeReduction +
          centerBoost *
              (1.0 - edgeReduction); // 1.0 at center, edgeReduction at edges
      magnitude = magnitude * movementIntensity;

      // Ensure minimum height (higher at center, lower at edges)
      // Increase minimum height significantly in fullscreen for better visibility
      final baseMinHeight =
          0.08 + centerBoost * 0.12; // 0.20 center, 0.08 edges
      final fullscreenMinMultiplier = widget.isFullscreen
          ? 2.0
          : 1.0; // 100% increase in fullscreen (much taller minimum bars)
      final minHeight = baseMinHeight * fullscreenMinMultiplier;
      magnitude = magnitude.clamp(minHeight, 1.0);

      rawMagnitudes.add(magnitude);

      // Track center bar magnitudes (bars 10-14, closest to center)
      if (distanceFromCenter <= 2.0) {
        maxCenterMagnitude = math.max(maxCenterMagnitude, magnitude);
      }
    }

    // Second pass: cap edge bars to ensure center bars are always dominant
    // Edge bars should never exceed 70% of max center bar height
    final centerMaxCap = maxCenterMagnitude * 0.7;
    for (int i = 0; i < barCount; i++) {
      if (i < animatedBarStart || i >= animatedBarEnd) {
        barData.add(0.08); // Static bars
      } else {
        double magnitude = rawMagnitudes[i];
        final isEdgeBar = (i == animatedBarStart || i == animatedBarEnd - 1);

        // Cap edge bars to be less than center bars
        if (isEdgeBar && maxCenterMagnitude > 0.1) {
          magnitude = math.min(magnitude, centerMaxCap);
        }

        // Apply temporal smoothing for smoother animation
        if (_previousBarHeights.length == barCount &&
            i < _previousBarHeights.length) {
          // Smooth with 70% new, 30% previous (adjustable for smoothness)
          magnitude = magnitude * 0.7 + _previousBarHeights[i] * 0.3;
        }

        barData.add(magnitude);
      }
    }

    // Update previous heights for next frame
    _previousBarHeights = List.from(barData);

    return CustomPaint(
      key: ValueKey(
        'fft_${fftMagnitudes.hashCode}',
      ), // Force repaint when data changes
      painter: WaveformBarPainter(
        barHeights: barData,
        isPlaying: widget.isPlaying,
      ),
      size: Size.infinite,
    );
  }

  List<double> _resampleToBars(List<double> waveform, int barCount) {
    if (waveform.isEmpty) {
      return List.filled(barCount, 0.2);
    }

    final result = <double>[];
    final ratio = waveform.length / barCount;

    for (int i = 0; i < barCount; i++) {
      final startIndex = (i * ratio).floor();
      final endIndex = ((i + 1) * ratio).floor();

      if (endIndex > startIndex) {
        double sum = 0.0;
        int count = 0;
        for (int j = startIndex; j < endIndex && j < waveform.length; j++) {
          sum += waveform[j];
          count++;
        }
        result.add(count > 0 ? (sum / count).clamp(0.0, 1.0) : 0.2);
      } else {
        result.add(waveform[startIndex.clamp(0, waveform.length - 1)]);
      }
    }

    return result;
  }
}

/// Custom painter for waveform bars matching the original design
class WaveformBarPainter extends CustomPainter {
  final List<double> barHeights;
  final bool isPlaying;

  static const int barCount = 25;
  static const int outerFixedBars = 4;
  static const double barWidthRatio = 0.95;
  static const double minBarHeight = 3.0;

  WaveformBarPainter({required this.barHeights, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    if (barHeights.isEmpty) return;

    // Calculate bar dimensions
    final totalGapWidth = size.width * (1 - barWidthRatio);
    final totalBarWidth = size.width - totalGapWidth;
    final barWidth = totalBarWidth / barCount;
    final gap = totalGapWidth / (barCount - 1);

    // Draw each bar
    for (int i = 0; i < barCount && i < barHeights.length; i++) {
      final x = (barWidth + gap) * i;

      // Calculate bar height
      // Left 4 bars (0-3) and Right 4 bars (21-24) are static
      // Center bars (4-20) are animated
      final isStaticBar = i < outerFixedBars || i >= barCount - outerFixedBars;
      final normalizedHeight = isStaticBar
          ? 0.08 // Fixed height for static bars (8% of max height - smaller like unmoving bars)
          : barHeights[i]; // Animated height for center bars
      final calculatedHeight = normalizedHeight * size.height;
      final barHeight = calculatedHeight.clamp(minBarHeight, size.height);

      // Center-aligned bars (grow from center to both top and bottom)
      final yPosition = (size.height - barHeight) / 2;

      // All bars use the same color scheme (same as right side/treble bars)
      Color bottomColor = const Color(0xFFEFBF04); // Gold
      Color midColor = const Color(0xFFEFBF04);
      // Light gold (same as right side)
      Color topColor = const Color(0xFFFFFFFF); // White

      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [bottomColor, midColor, topColor],
        stops: const [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(x, yPosition, barWidth, barHeight),
        )
        ..style = PaintingStyle.fill;

      // Dynamic glow when playing (only for animated center bars)
      if (isPlaying && !isStaticBar && normalizedHeight > 0.1) {
        final glowPaint = Paint()
          ..color = bottomColor.withOpacity(0.15 + normalizedHeight * 0.35)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            1.5 + normalizedHeight * 4.0,
          );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 1, yPosition - 1, barWidth + 2, barHeight + 2),
            const Radius.circular(2),
          ),
          glowPaint,
        );
      }

      // Draw main bar with rounded corners
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, yPosition, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformBarPainter oldDelegate) {
    // Always repaint if bar heights changed or playing state changed
    if (oldDelegate.barHeights.length != barHeights.length) {
      return true;
    }

    // Check if any bar height changed significantly (more than 0.01)
    for (int i = 0; i < barHeights.length; i++) {
      if ((oldDelegate.barHeights[i] - barHeights[i]).abs() > 0.01) {
        return true;
      }
    }

    return oldDelegate.isPlaying != isPlaying;
  }
}

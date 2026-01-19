import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/track.dart';
import '../utils/s3_url_fix.dart';
import '../utils/audio_analyzer.dart';
import '../utils/audio_waveform_service.dart';

class AudioPlayerController extends GetxController {
  late AudioPlayer _audioPlayer;
  late AudioAnalyzer audioAnalyzer;

  // Observable state
  final RxList<Track> playlist = <Track>[].obs;
  final Rxn<Track> currentTrack = Rxn<Track>();
  final RxDouble currentTime = 0.0.obs;
  final RxDouble duration = 0.0.obs;
  final RxDouble volume = 0.8.obs;
  final RxBool isPlaying = false.obs;
  // Shared fullscreen state (used by manual toggle + device rotation)
  final RxBool isFullscreenOpen = false.obs;
  final RxString currentJsonSource = "last_updated_fresh".obs;
  final RxBool isSyncing = true.obs;
  final RxBool userHasUnmuted = false.obs;
  final RxBool userManuallyPaused = false.obs;
  final RxBool isSwitchingChannel = false.obs;

  // Dynamic waveform generation
  final RxMap<String, List<double>> dynamicWaveforms =
      <String, List<double>>{}.obs;
  final RxBool isGeneratingWaveform = false.obs;
  late AudioWaveformService waveformService;

  // Channel order
  final List<String> channels = [
    "last_updated_fresh", // The South Got Something To Say Radio!
    "tunnel_radio_nyc", // Tunnel Radio NYC
    "west_coast_g_funk_radio", // West Coast G-Funk Radio
    "vintage_pop_rock_radio", // Vintage Pop & Rock Radio
  ];

  // Channel names mapping
  final Map<String, String> channelNames = {
    "last_updated_fresh": "The South Got Something To Say Radio!",
    "tunnel_radio_nyc": "Tunnel Radio NYC",
    "west_coast_g_funk_radio": "West Coast G-Funk Radio",
    "vintage_pop_rock_radio": "Vintage Pop & Rock Radio",
  };

  // Refs for tracking
  String? lastLoadedTrackId;
  bool initialSyncDone = false;
  Timer? syncTimer;
  bool _isPlayingInProgress = false; // Prevent duplicate play calls

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    audioAnalyzer = AudioAnalyzer();
    Get.put(audioAnalyzer); // Make it available globally

    // Initialize waveform service
    waveformService = AudioWaveformService();
    Get.put(waveformService); // Make it available globally
    _setupAudioPlayer();
    loadPlaylist();
    _startSyncTimer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.positionStream.listen((position) {
      currentTime.value = position.inSeconds.toDouble();

      // Update analyzer with current playback state
      _updateAnalyzerData();
    });

    _audioPlayer.durationStream.listen((d) {
      if (d != null) {
        duration.value = d.inSeconds.toDouble();
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      // Only update isPlaying if not manually paused or if actually playing
      // This prevents race conditions where stream updates isPlaying to false
      // right after we call play(), causing unwanted pause behavior
      if (!userManuallyPaused.value || state.playing) {
        isPlaying.value = state.playing;
      }

      if (state.processingState == ProcessingState.completed) {
        _handleTrackEnd();
      }

      // Update analyzer when play state changes
      _updateAnalyzerData();
    });
  }

  /// Generate waveform dynamically from MP3 URL
  Future<void> _generateWaveformForTrack(Track track) async {
    try {
      isGeneratingWaveform.value = true;

      // Use MP3 URL to generate waveform
      final mp3Url = fixS3UrlFormat(track.mp3Url);
      final trackDuration = (duration.value > 0)
          ? duration.value
          : track.duration.toDouble();

      // Generate waveform using the service
      final generatedWaveform = await waveformService.generateWaveformForTrack(
        mp3Url: mp3Url,
        audioPlayer: _audioPlayer,
        duration: trackDuration,
      );

      // Store generated waveform
      dynamicWaveforms[mp3Url] = generatedWaveform;

      // Update analyzer with dynamically generated waveform
      audioAnalyzer.updateTrackData(
        waveformData: generatedWaveform,
        currentTime: currentTime.value,
        duration: trackDuration,
        isPlaying: isPlaying.value,
      );

      isGeneratingWaveform.value = false;
      print('Waveform generated dynamically for: ${track.title}');
    } catch (e) {
      print('Error generating waveform: $e');
      isGeneratingWaveform.value = false;

      // Fallback to original waveform data if generation fails
      audioAnalyzer.updateTrackData(
        waveformData: track.waveformData,
        currentTime: currentTime.value,
        duration: (duration.value > 0)
            ? duration.value
            : track.duration.toDouble(),
        isPlaying: isPlaying.value,
      );
    }
  }

  /// Update audio analyzer with current track data
  void _updateAnalyzerData() {
    final track = currentTrack.value;
    if (track != null) {
      // Use dynamically generated waveform if available, otherwise fallback to original
      final mp3Url = fixS3UrlFormat(track.mp3Url);
      final waveformData = dynamicWaveforms[mp3Url] ?? track.waveformData;

      audioAnalyzer.updateTrackData(
        waveformData: waveformData,
        currentTime: currentTime.value,
        duration: (duration.value > 0)
            ? duration.value
            : track.duration.toDouble(),
        isPlaying: isPlaying.value,
      );
    }
  }

  /// Get waveform data for current track (dynamic or fallback)
  List<double> getCurrentWaveformData() {
    final track = currentTrack.value;
    if (track == null) return [];

    final mp3Url = fixS3UrlFormat(track.mp3Url);
    return dynamicWaveforms[mp3Url] ?? track.waveformData;
  }

  Future<void> loadPlaylist() async {
    try {
      isSyncing.value = true;
      String jsonFile = "last_updated_fresh.json";

      if (currentJsonSource.value == "tunnel_radio_nyc") {
        jsonFile = "tunnel_radio_nyc.json";
      } else if (currentJsonSource.value == "west_coast_g_funk_radio") {
        jsonFile = "west_coast_g_funk_radio.json";
      } else if (currentJsonSource.value == "vintage_pop_rock_radio") {
        jsonFile = "Vintage Pop & Rock Radio.json";
      }

      final String jsonString = await rootBundle.loadString(
        'assets/json/$jsonFile',
      );
      final List<dynamic> data = json.decode(jsonString);

      final tracks = data.map((json) => Track.fromJson(json)).toList();
      tracks.sort((a, b) => a.sequence.compareTo(b.sequence));

      playlist.value = tracks;

      // Sync to live position after loading
      await syncToLivePosition();
    } catch (e) {
      print('Error loading playlist: $e');
      isSyncing.value = false;
    }
  }

  Future<PositionData?> calculateCurrentPosition() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('radio')
          .doc('stream')
          .get();

      if (!doc.exists || !doc.data()!.containsKey('startTimestampUTC')) {
        return null;
      }

      // Handle both String and int types for startTimestampUTC
      final startTimestampUTCValue = doc.data()!['startTimestampUTC'];
      final int startTimestampUTC;
      if (startTimestampUTCValue is String) {
        startTimestampUTC = int.tryParse(startTimestampUTCValue) ?? 0;
      } else if (startTimestampUTCValue is int) {
        startTimestampUTC = startTimestampUTCValue;
      } else {
        return null;
      }

      final currentUTC = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds = (currentUTC - startTimestampUTC) / 1000;

      if (playlist.isEmpty) return null;

      // Sort playlist by elapsedDuration
      final sortedPlaylist = List<Track>.from(playlist)
        ..sort((a, b) => a.elapsedDuration.compareTo(b.elapsedDuration));

      // Calculate total loop duration
      final lastTrack = sortedPlaylist.last;
      final totalLoopDuration = lastTrack.elapsedDuration + lastTrack.duration;

      // Get position in loop
      double syncedPosition = elapsedSeconds % totalLoopDuration;
      if (syncedPosition < 0) syncedPosition += totalLoopDuration;

      // Find track at position
      for (final track in sortedPlaylist) {
        final start = track.elapsedDuration.toDouble();
        final end = start + track.duration;

        if (syncedPosition >= start && syncedPosition < end) {
          return PositionData(
            track: track,
            positionInTrack: syncedPosition - start,
          );
        }
      }

      // Fallback to first track
      return PositionData(track: sortedPlaylist.first, positionInTrack: 0);
    } catch (e) {
      print('Error calculating position: $e');
      return null;
    }
  }

  Future<void> syncToLivePosition() async {
    try {
      final positionData = await calculateCurrentPosition();
      if (positionData != null) {
        await loadTrack(positionData.track, positionData.positionInTrack);
        // Wait a bit more for audio to be fully ready, then auto-play
        await Future.delayed(const Duration(milliseconds: 500));
        // On initial sync, always auto-play (first time load)
        if (!initialSyncDone) {
          print('Initial sync: Auto-playing track with sound');
          // Unmute and set volume for initial auto-play
          userHasUnmuted.value = true;
          await _audioPlayer.setVolume(volume.value);
          await play();
        } else if (!userManuallyPaused.value) {
          // After initial sync, only play if not manually paused
          await play();
        }
        initialSyncDone = true;
        isSyncing.value = false;
      } else {
        // If Firebase sync fails, start with first track
        if (playlist.isNotEmpty) {
          await loadTrack(playlist.first, 0);
          // Wait a bit more for audio to be fully ready, then auto-play
          await Future.delayed(const Duration(milliseconds: 500));
          // On initial sync, always auto-play (first time load)
          if (!initialSyncDone) {
            print('Initial sync (fallback): Auto-playing track with sound');
            // Unmute and set volume for initial auto-play
            userHasUnmuted.value = true;
            await _audioPlayer.setVolume(volume.value);
            await play();
          } else if (!userManuallyPaused.value) {
            await play();
          }
          initialSyncDone = true;
          isSyncing.value = false;
        }
      }
    } catch (e) {
      print('Error syncing to live position: $e');
      // Fallback: start with first track if sync fails
      if (playlist.isNotEmpty) {
        await loadTrack(playlist.first, 0);
        // Wait a bit more for audio to be fully ready, then auto-play
        await Future.delayed(const Duration(milliseconds: 500));
        // On initial sync, always auto-play (first time load)
        if (!initialSyncDone) {
          print('Initial sync (error fallback): Auto-playing track with sound');
          // Unmute and set volume for initial auto-play
          userHasUnmuted.value = true;
          await _audioPlayer.setVolume(volume.value);
          await play();
        } else if (!userManuallyPaused.value) {
          await play();
        }
        initialSyncDone = true;
      }
      isSyncing.value = false;
    }
  }

  Future<void> loadTrack(Track track, double startTime) async {
    try {
      // Prevent duplicate load - if same track is already loaded, skip
      if (lastLoadedTrackId == track.id && currentTrack.value?.id == track.id) {
        print('Track already loaded: ${track.title} - skipping duplicate load');
        return;
      }

      // Reset analyzer for new song - har naye song ke liye fresh start
      if (lastLoadedTrackId != null && lastLoadedTrackId != track.id) {
        audioAnalyzer.reset();
        print('New song detected: Resetting analyzer for ${track.title}');
      }

      // Fix S3 URL format
      String audioUrl = fixS3UrlFormat(track.mp3Url);

      await _audioPlayer.setUrl(audioUrl);

      // Wait for audio to be ready (like web version waits for 'canplay' event)
      // Wait for duration to be available (means audio is loaded)
      int retries = 0;
      while (_audioPlayer.duration == null && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }

      // Try seeking
      try {
        await _audioPlayer.seek(Duration(seconds: startTime.toInt()));
      } catch (_) {
        // If seek fails, wait a bit more and retry
        await Future.delayed(const Duration(milliseconds: 200));
        if (_audioPlayer.duration != null) {
          await _audioPlayer.seek(Duration(seconds: startTime.toInt()));
        }
      }

      // Start muted (autoplay policy)
      if (!userHasUnmuted.value) {
        await _audioPlayer.setVolume(0.0);
      } else {
        await _audioPlayer.setVolume(volume.value);
      }

      currentTrack.value = track;
      lastLoadedTrackId = track.id;

      // Generate waveform dynamically from MP3 URL
      _generateWaveformForTrack(track);

      // Update analyzer with new track data - is naye song ka MP3 URL
      _updateAnalyzerData();

      print('Track loaded: ${track.title} - MP3 URL: ${track.mp3Url}');
    } catch (e) {
      print('Error loading track: $e');
    }
  }

  Future<void> play() async {
    try {
      // Prevent duplicate play calls - if already playing or play in progress, return
      if (_audioPlayer.playing || _isPlayingInProgress) {
        print(
          'play() called but audio is already playing or play in progress - skipping',
        );
        return;
      }

      _isPlayingInProgress = true;
      print('play() called - checking audio state...');
      print('Duration: ${_audioPlayer.duration}');
      print('Playing state: ${_audioPlayer.playing}');

      // Ensure audio is ready before playing
      if (_audioPlayer.duration == null) {
        print('Waiting for audio duration...');
        // Wait for audio to be ready
        int retries = 0;
        while (_audioPlayer.duration == null && retries < 20) {
          await Future.delayed(const Duration(milliseconds: 100));
          retries++;
        }
        print(
          'After waiting - Duration: ${_audioPlayer.duration}, Retries: $retries',
        );
      }

      // Try to play regardless - just_audio will handle if not ready
      try {
        // Clear manual pause flag BEFORE playing
        userManuallyPaused.value = false;
        await _audioPlayer.play();
        // Immediately update isPlaying for responsive UI
        isPlaying.value = true;
        print('Audio play() called successfully');

        // Verify it's actually playing
        await Future.delayed(const Duration(milliseconds: 200));
        print('Playing state after play(): ${_audioPlayer.playing}');
        // Sync with actual player state (stream will also update it)
        isPlaying.value = _audioPlayer.playing;
        if (!_audioPlayer.playing) {
          print('Warning: play() called but audio is not playing');
          // Only retry if user hasn't manually paused
          if (!userManuallyPaused.value) {
            // Try one more time
            await Future.delayed(const Duration(milliseconds: 300));
            await _audioPlayer.play();
            isPlaying.value = _audioPlayer.playing;
            print('Retry play() - Playing state: ${_audioPlayer.playing}');
          } else {
            print('Skipping retry - user manually paused');
          }
        }
        _isPlayingInProgress = false; // Reset flag after successful play
      } catch (playError) {
        print('Error in _audioPlayer.play(): $playError');
        _isPlayingInProgress = false; // Reset flag on error
        // Retry after delay - only if user hasn't manually paused
        if (!userManuallyPaused.value) {
          await Future.delayed(const Duration(milliseconds: 500));
          await _audioPlayer.play();
          userManuallyPaused.value = false;
          isPlaying.value = _audioPlayer.playing;
          print('Audio playing after retry');
        } else {
          print('Skipping retry - user manually paused');
        }
        _isPlayingInProgress = false;
      }
    } catch (e) {
      print('Error in play() function: $e');
      _isPlayingInProgress = false; // Reset flag on error
      // Final retry - only if user hasn't manually paused
      if (!userManuallyPaused.value) {
        try {
          await Future.delayed(const Duration(milliseconds: 1000));
          await _audioPlayer.play();
          userManuallyPaused.value = false;
          isPlaying.value = _audioPlayer.playing;
          print('Audio playing after final retry');
        } catch (e2) {
          print('Error playing after final retry: $e2');
          isPlaying.value = false;
        } finally {
          _isPlayingInProgress = false;
        }
      } else {
        print('Skipping final retry - user manually paused');
        _isPlayingInProgress = false;
      }
    } finally {
      _isPlayingInProgress = false; // Always reset flag
    }
  }

  Future<void> pause() async {
    try {
      _isPlayingInProgress = false; // Reset play in progress flag
      userManuallyPaused.value = true; // Set pause flag FIRST
      await _audioPlayer.pause();
      // Immediately update isPlaying for responsive UI
      isPlaying.value = false;
      print('Audio paused - userManuallyPaused set to true');
    } catch (e) {
      print('Error pausing: $e');
      _isPlayingInProgress = false;
      userManuallyPaused.value = true; // Ensure flag is set even on error
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pause();
    } else {
      // Clear manual pause flag when user explicitly plays
      userManuallyPaused.value = false;
      await play();
    }
  }

  Future<void> setVolume(double vol) async {
    volume.value = vol.clamp(0.0, 1.0);
    if (userHasUnmuted.value) {
      await _audioPlayer.setVolume(volume.value);
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      currentTime.value = position.inSeconds.toDouble();
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  Future<void> unmute() async {
    userHasUnmuted.value = true;
    await _audioPlayer.setVolume(volume.value);
  }

  void _handleTrackEnd() {
    // Calculate next track from Firebase
    calculateCurrentPosition().then((positionData) {
      if (positionData != null &&
          positionData.track.id != currentTrack.value?.id) {
        loadTrack(positionData.track, 0);
        if (!userManuallyPaused.value) {
          play();
        }
      }
    });
  }

  void _startSyncTimer() {
    syncTimer?.cancel();
    syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (playlist.isEmpty || isSwitchingChannel.value) return;

      // Don't sync if user manually paused - respect user's pause state
      if (userManuallyPaused.value) {
        return;
      }

      final positionData = await calculateCurrentPosition();
      if (positionData != null) {
        final currentTrackValue = currentTrack.value;

        if (positionData.track.id != currentTrackValue?.id) {
          // Track changed - load new track
          await loadTrack(positionData.track, positionData.positionInTrack);
          // Only auto-play if not manually paused (double check after loadTrack)
          if (!userManuallyPaused.value && !_isPlayingInProgress) {
            await play();
          }
        } else {
          // Same track - sync position if needed (only if playing)
          if (!userManuallyPaused.value && isPlaying.value) {
            final diff = (positionData.positionInTrack - currentTime.value)
                .abs();
            if (diff > 3) {
              await _audioPlayer.seek(
                Duration(seconds: positionData.positionInTrack.toInt()),
              );
            }
          }
        }
      }
    });
  }

  Future<void> switchChannel(String newChannel) async {
    print('switchChannel called: $newChannel');

    // Don't switch if already on this channel
    if (currentJsonSource.value == newChannel) {
      print('Already on channel: $newChannel');
      return;
    }

    // Stop current playback - await to ensure it stops before loading new track
    try {
      await _audioPlayer.pause();
      await _audioPlayer.stop();
      isPlaying.value = false;
      print('Previous track stopped successfully');
    } catch (e) {
      print('Error stopping previous track: $e');
    }

    // Reset state - preserve userManuallyPaused if user had paused
    // Don't reset userManuallyPaused - if user paused, new channel should also be paused
    // userManuallyPaused.value = false; // Preserve pause state across channel switches
    lastLoadedTrackId = null;
    initialSyncDone = false;
    currentTrack.value = null;

    // Set new channel
    isSwitchingChannel.value = true;
    currentJsonSource.value = newChannel;
    print('Channel set to: ${currentJsonSource.value}');

    // Reload playlist with timeout to ensure isSwitchingChannel is always reset
    loadPlaylist()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Channel switch timeout - resetting flag');
            isSwitchingChannel.value = false;
          },
        )
        .then((_) {
          print('Playlist loaded successfully for: $newChannel');
          isSwitchingChannel.value = false;
        })
        .catchError((error) {
          print('Error switching channel: $error');
          isSwitchingChannel.value = false;
        });
  }

  void nextChannel() {
    // Prevent navigation while switching channels
    if (isSwitchingChannel.value) {
      print('Navigation blocked: Channel switch in progress');
      return;
    }

    // Ensure currentJsonSource is valid
    if (!channels.contains(currentJsonSource.value)) {
      print(
        'Next Channel - Invalid current source, resetting to first channel',
      );
      currentJsonSource.value = channels.first;
      return;
    }

    final currentIndex = channels.indexOf(currentJsonSource.value);
    print(
      'Next Channel - Current: ${currentJsonSource.value}, Index: $currentIndex',
    );

    // If already at the last channel (Vintage), do nothing
    if (currentIndex >= channels.length - 1) {
      print('Next Channel - Already at last channel');
      return;
    }

    // Move to next channel
    final nextIndex = currentIndex + 1;
    final nextChannel = channels[nextIndex];
    print('Next Channel - Switching to: $nextChannel (index: $nextIndex)');
    switchChannel(nextChannel);
  }

  void previousChannel() {
    // Prevent navigation while switching channels
    if (isSwitchingChannel.value) {
      print('Navigation blocked: Channel switch in progress');
      return;
    }

    // Ensure currentJsonSource is valid
    if (!channels.contains(currentJsonSource.value)) {
      print(
        'Previous Channel - Invalid current source, resetting to first channel',
      );
      currentJsonSource.value = channels.first;
      return;
    }

    final currentIndex = channels.indexOf(currentJsonSource.value);
    print(
      'Previous Channel - Current: ${currentJsonSource.value}, Index: $currentIndex',
    );

    // If already at the first channel (Last Updated), do nothing
    if (currentIndex <= 0) {
      print('Previous Channel - Already at first channel');
      return;
    }

    // Move to previous channel
    final prevIndex = currentIndex - 1;
    final prevChannel = channels[prevIndex];
    print('Previous Channel - Switching to: $prevChannel (index: $prevIndex)');
    switchChannel(prevChannel);
  }

  String getCurrentChannelName() {
    return channelNames[currentJsonSource.value] ?? "Unknown Channel";
  }

  @override
  void onClose() {
    syncTimer?.cancel();
    _audioPlayer.dispose();
    audioAnalyzer.onClose();
    super.onClose();
  }
}

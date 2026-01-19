# Audio Page - Complete Flutter Implementation Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [JSON Data Structure](#json-data-structure)
4. [Component Structure](#component-structure)
5. [State Management & Logic](#state-management--logic)
6. [Styling & Design System](#styling--design-system)
7. [Fonts](#fonts)
8. [Audio Player Logic](#audio-player-logic)
9. [Waveform Visualization](#waveform-visualization)
10. [Channel Switching](#channel-switching)
11. [Firebase Sync Logic](#firebase-sync-logic)
12. [Responsive Design](#responsive-design)
13. [iOS Safari Fixes](#ios-safari-fixes)
14. [Flutter Implementation Steps](#flutter-implementation-steps)

---

## Overview

The Audio Page is a live radio streaming interface with:
- **Real-time audio playback** synchronized with Firebase
- **Multiple radio channels** (4 channels: Tunnel Radio NYC, West Coast G-Funk, Vintage Pop & Rock, The South)
- **Waveform visualization** using Web Audio API
- **Live chat/comments** section
- **Channel switching** with seamless transitions
- **Responsive design** for all devices
- **iOS Safari optimizations**

---

## Architecture

### Main Components

```
AudioScreen (Main Container)
├── Header (App Bar)
├── MobileLayout
│   ├── VideoPlayerSection
│   │   └── AudioPlayer Component
│   │       ├── Track Info Section
│   │       ├── Waveform Canvas
│   │       └── Controls (Play/Pause, Volume, Like, Next/Prev)
│   ├── VideoInfoBox
│   │   ├── Channel Title & Info
│   │   ├── Subscribe Button
│   │   └── Description
│   └── CommentsSection (Mobile)
└── AudioPlayerContext (Global State)
    ├── Playlist Management
    ├── Track Loading
    ├── Firebase Sync
    └── Channel Switching
```

---

## JSON Data Structure

### File Locations
- `last_updated_fresh.json` - The South Got Something To Say Radio
- `tunnel_radio_nyc.json` - Tunnel Radio NYC
- `west_coast_g_funk_radio.json` - West Coast G-Funk Radio
- `Vintage Pop & Rock Radio.json` - Vintage Pop & Rock Radio

### Track Object Structure

```json
{
  "sequence": 1567,
  "title": "U.O.E.N.O. - Rocko ft Rick Ross, Future [Gift Of Gab 2]",
  "description": "Track 03 from the mixtape Gift Of Gab 2.",
  "duration": 261,
  "duration_string": "4:21",
  "elapsedDuration": 398146,
  "url": "https://www.youtube.com/watch?v=9c_VGNYAhi0",
  "id": "9c_VGNYAhi0",
  "thumbnail": "https://i.ytimg.com/vi/9c_VGNYAhi0/maxresdefault.jpg",
  "mp3_url": "https://yeek.tv.s3.eu-north-1.amazonaws.com/final merge/1699 - U.O.E.N.O. - Rocko ft Rick Ross, Future [Gift Of Gab 2].mp3",
  "artist": "Rocko feat. Future & Rick Ross",
  "album": "Gift of Gab 2",
  "year": 2013,
  "waveformData": [0.858, 0.552, 0.455, ...] // Array of 0-1 values
}
```

### Key Fields
- **sequence**: Playback order
- **duration**: Track length in seconds
- **elapsedDuration**: Cumulative time from playlist start (for sync)
- **mp3_url**: Direct audio file URL (S3)
- **waveformData**: Pre-calculated waveform visualization data (array of 0-1 floats)

---

## Component Structure

### 1. AudioScreen (Main Container)

**Location**: `src/components/audioPlayer/audioScreen/audioScreen.jsx`

**Key Features**:
- Channel data management
- Chat messages state
- Like/Subscribe interactions
- Viewer count display
- Comments toggle

**State Variables**:
```javascript
const [isPlaying, setIsPlaying] = useState(true)
const [chatMessages, setChatMessages] = useState([])
const [isLiked, setIsLiked] = useState(false)
const [likeCount, setLikeCount] = useState(21)
const [isSubscribed, setIsSubscribed] = useState(false)
const [viewerCount, setViewerCount] = useState(406)
const [showChat, setShowChat] = useState(false)
```

**Channel Data Structure**:
```javascript
const channelData = {
  "featured-1": {
    name: "The South Got Something To Say Radio!",
    dj: "THE SOUTH RADIO",
    viewers: 1247,
    thumbnail: "...",
    category: "Pop",
    subscribers: "12.4K",
    isLive: true,
    description: "...",
    profileImage: "/assets/..."
  }
}
```

### 2. AudioPlayer Component

**Location**: `src/components/audioPlayer/audio.jsx`

**Key Features**:
- Track display (title, artist, album, year)
- Play/Pause button
- Waveform visualization
- Volume control
- Like button
- Next/Previous channel buttons
- Viewer count badge

**Layout Structure**:
```
┌─────────────────────────────────────┐
│  Track Title (h3)                   │
├─────────────────────────────────────┤
│  ┌──────────┐  ┌────────────────┐ │
│  │ Play/Pause│  │ Track Info     │ │
│  │ Button    │  │ - Artist       │ │
│  │           │  │ - Album        │ │
│  │           │  │ - Year         │ │
│  └──────────┘  └────────────────┘ │
│  ┌──────────────────────────────┐  │
│  │   Thumbnail Image (Center)   │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │   Waveform Canvas (Bottom)    │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │ Volume | Like | Prev | Next  │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### 3. AudioPlayerContext (Global State)

**Location**: `src/components/audioPlayer/AudioPlayerContext/AudioPlayerContext.jsx`

**Responsibilities**:
- Playlist loading from JSON files
- Track synchronization with Firebase
- Audio element management
- Channel switching
- Volume control
- Play/Pause state

**Key Functions**:
- `loadPlaylist()` - Loads JSON file based on current channel
- `calculateCurrentPosition()` - Syncs with Firebase `radio/stream` document
- `loadTrack()` - Loads and prepares audio track
- `syncToLivePosition()` - Syncs playback to live position
- `switchToTunnelRadioNYC()` - Channel switching functions

---

## State Management & Logic

### Audio Player State

```javascript
// Global Audio State
const [isPlaying, setIsPlaying] = useState(false)
const [currentTime, setCurrentTime] = useState(0)
const [duration, setDuration] = useState(0)
const [volume, setVolume] = useState(0.8)
const [playlist, setPlaylist] = useState([])
const [currentTrack, setCurrentTrack] = useState(null)
const [currentJsonSource, setCurrentJsonSource] = useState("last_updated_fresh")
const [isSyncing, setIsSyncing] = useState(true)
const [userHasUnmuted, setUserHasUnmuted] = useState(false)
const [userManuallyPaused, setUserManuallyPaused] = useState(false)
```

### Track Loading Logic

1. **Initial Load**:
   - Load playlist JSON based on `currentJsonSource`
   - Sort by `sequence` field
   - Calculate current position from Firebase
   - Load and play track at calculated position

2. **Track Sync**:
   - Every 5 seconds, check Firebase for current position
   - If track changed, load new track
   - If same track, sync `currentTime` if drift > 3 seconds

3. **Track End**:
   - Calculate next track from Firebase
   - If no Firebase data, use next track in playlist
   - Load and play next track

### Channel Switching Logic

```javascript
// Channel order:
1. last_updated_fresh (The South)
2. tunnel_radio_nyc (Tunnel Radio NYC)
3. west_coast_g_funk_radio (West Coast G-Funk)
4. vintage_pop_rock_radio (Vintage Pop & Rock)

// Next: Moves forward in order
// Previous: Moves backward in order
```

**Switching Process**:
1. Pause current audio
2. Reset `currentTime` to 0
3. Clear audio `src`
4. Reset sync flags
5. Set new `currentJsonSource`
6. Load new playlist
7. Sync to live position

---

## Styling & Design System

### Color Palette

```css
/* Background */
background: linear-gradient(135deg, #0f0f0f 0%, #1a1a1a 50%, #0f0f0f 100%);

/* Primary Accent */
#EFBF04 (Gold/Yellow) - Used for buttons, icons, highlights

/* Text Colors */
- White: #ffffff
- Gray: #aaa, #888
- Dark Gray: #3f3f3f

/* Borders */
border: 2px solid #3f3f3f
border-radius: 8px (sections), 12px (buttons), 25px (inputs)

/* Shadows */
box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4)
```

### Typography

**Font Families**:
- **Primary**: `"Roboto", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`
- **Custom**: `"YeekBold"` (for special headings)

**Font Sizes**:
```css
/* Track Title */
font-size: 18px (mobile), 20px (desktop)
font-weight: 600
line-height: 1.3

/* Track Meta (Artist, Album, Year) */
font-size: 14px (mobile), 16px (desktop)
font-weight: 400
color: #aaa

/* Buttons */
font-size: 14px
font-weight: 500
```

### Spacing System

```css
/* Padding */
- Section padding: 12px (mobile), 16px (desktop)
- Button padding: 8px 12px
- Input padding: 12px 20px

/* Margins */
- Section gap: 15px (mobile), 24px (desktop)
- Element gap: 8px, 12px, 16px

/* iOS Safari Specific */
- Horizontal padding: 10px (on inner sections)
- Top margin: 8px (mobileLayoutVicode)
```

### Component Styles

#### Audio Container
```css
.audio-container-pointer-setter {
  height: fit-content;
  min-height: 300px;
  max-height: 400px;
  padding: 0px 8px;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow-x: hidden;
}
```

#### Track Info Section
```css
.new_section_row_set {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px;
}

.track-title {
  font-size: 18px;
  font-weight: 600;
  color: white;
  margin: 0;
}

.track-meta {
  font-size: 14px;
  color: #aaa;
  margin: 2px 0;
}
```

#### Waveform Container
```css
.waveform-container {
  width: 100%;
  height: 120px;
  position: relative;
  background: transparent;
  border-radius: 4px;
  overflow: hidden;
}

canvas {
  width: 100%;
  height: 100%;
  display: block;
}
```

#### Control Buttons
```css
.play-pause-btnn {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  border: 2px solid rgba(255, 255, 255, 0.2);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.play-pause-btnn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.05);
}
```

---

## Fonts

### YeekBold Font

**File**: `assets/fonts/YeekBold.ttf`

**Usage**:
```css
@font-face {
  font-family: 'YeekBold';
  src: url('../../../assets/fonts/YeekBold.ttf') format('truetype');
  font-weight: bold;
  font-style: normal;
  font-display: swap;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

**Flutter Implementation**:
```dart
// Add font to pubspec.yaml
fonts:
  - family: YeekBold
    fonts:
      - asset: assets/fonts/YeekBold.ttf

// Use in Flutter
TextStyle(
  fontFamily: 'YeekBold',
  fontSize: 18,
  fontWeight: FontWeight.bold,
)
```

### Primary Font (Roboto)

**Fallback Stack**:
```
"Roboto", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif
```

**Flutter Implementation**:
```dart
TextStyle(
  fontFamily: 'Roboto',
  fontSize: 14,
  fontWeight: FontWeight.normal,
)
```

---

## Audio Player Logic

### 1. Playlist Loading

```javascript
// Load playlist based on current channel
const loadPlaylist = async () => {
  let jsonFile = "last_updated_fresh.json";
  if (currentJsonSource === "tunnel_radio_nyc") {
    jsonFile = "tunnel_radio_nyc.json";
  } else if (currentJsonSource === "west_coast_g_funk_radio") {
    jsonFile = "west_coast_g_funk_radio.json";
  } else if (currentJsonSource === "vintage_pop_rock_radio") {
    jsonFile = "Vintage Pop & Rock Radio.json";
  }
  
  const response = await fetch(`/assets/${jsonFile}`);
  const data = await response.json();
  const sorted = [...data].sort((a, b) => a.sequence - b.sequence);
  setPlaylist(sorted);
}
```

### 2. Firebase Sync

**Firebase Document**: `radio/stream`

**Structure**:
```javascript
{
  startTimestampUTC: 1234567890123 // Unix timestamp in milliseconds
}
```

**Sync Calculation**:
```javascript
const calculateCurrentPosition = async () => {
  const streamDoc = doc(db, "radio", "stream");
  const snap = await getDoc(streamDoc);
  const startTimestampUTC = snap.data().startTimestampUTC;
  const currentUTC = Date.now();
  const elapsedMs = currentUTC - startTimestampUTC;
  const elapsedSeconds = elapsedMs / 1000;
  
  // Find track at current position
  const sortedPlaylist = [...playlist].sort(
    (a, b) => a.elapsedDuration - b.elapsedDuration
  );
  const lastTrack = sortedPlaylist[sortedPlaylist.length - 1];
  const totalLoopDuration = lastTrack.elapsedDuration + lastTrack.duration;
  
  let syncedPosition = elapsedSeconds % totalLoopDuration;
  
  // Find which track is playing
  for (let i = 0; i < sortedPlaylist.length; i++) {
    const track = sortedPlaylist[i];
    const start = track.elapsedDuration;
    const end = start + track.duration;
    if (syncedPosition >= start && syncedPosition < end) {
      return {
        track: track,
        positionInTrack: syncedPosition - start
      };
    }
  }
}
```

### 3. Track Loading

```javascript
const loadTrack = async (track, startTime = 0) => {
  // Fix S3 URL format
  let audioUrl = fixS3UrlFormat(track.mp3_url);
  
  // Encode URL properly
  const urlMatch = audioUrl.match(/^(https?:\/\/[^\/]+)(\/.*)$/);
  if (urlMatch) {
    const [, base, path] = urlMatch;
    const encodedPath = pathParts.map(part => encodeURIComponent(part)).join("/");
    audioUrl = base + encodedPath;
  }
  
  // Set audio source
  audio.src = audioUrl;
  audio.currentTime = startTime;
  audio.muted = true; // Start muted (autoplay policy)
  
  // Wait for audio to be ready
  await new Promise((resolve, reject) => {
    const handleCanPlay = () => {
      if (userHasUnmuted) {
        audio.muted = false;
      }
      resolve();
    };
    audio.addEventListener("canplay", handleCanPlay);
    audio.addEventListener("error", reject);
  });
  
  setCurrentTrack(track);
}
```

### 4. S3 URL Fix

```javascript
const fixS3UrlFormat = (url) => {
  const problematicDomain = "yeek.tv.s3.eu-north-1.amazonaws.com";
  
  if (url.includes(problematicDomain)) {
    const domainIndex = url.indexOf(problematicDomain + "/");
    if (domainIndex !== -1) {
      const path = url.substring(domainIndex + problematicDomain.length + 1);
      return `https://s3.eu-north-1.amazonaws.com/yeek.tv/${path}`;
    }
  }
  
  // Ensure HTTPS
  if (url.startsWith("http://")) {
    return url.replace("http://", "https://");
  }
  
  return url;
}
```

### 5. Continuous Sync

```javascript
// Every 5 seconds, check if track should change
useEffect(() => {
  const detectCurrentTrack = async () => {
    const positionData = await calculateCurrentPosition();
    const { track: trackAtPosition, positionInTrack } = positionData;
    const currentTrackValue = currentTrackRef.current;
    
    if (trackAtPosition.id !== currentTrackValue?.id) {
      // Track changed - load new track
      await loadAndPlayTrack(trackAtPosition, positionInTrack);
    } else {
      // Same track - sync position if needed
      const audio = audioRef.current;
      const diff = Math.abs(positionInTrack - audio.currentTime);
      if (diff > 3) {
        audio.currentTime = positionInTrack;
      }
    }
  };
  
  const interval = setInterval(detectCurrentTrack, 5000);
  return () => clearInterval(interval);
}, [playlist]);
```

---

## Waveform Visualization

### Web Audio API Setup

```javascript
// Create shared AudioContext (prevents Safari issues)
const getSharedAudioContext = () => {
  const AudioContextClass = window.AudioContext || window.webkitAudioContext;
  const audioContext = new AudioContextClass({
    latencyHint: "interactive",
    sampleRate: 44100,
  });
  return audioContext;
};

// Create analyser node
const analyser = audioContext.createAnalyser();
analyser.fftSize = 512;
analyser.smoothingTimeConstant = 0.3;
analyser.minDecibels = -85;
analyser.maxDecibels = -10;

// Connect audio element to analyser
const source = audioContext.createMediaElementSource(audioElement);
source.connect(analyser);
analyser.connect(audioContext.destination);
```

### Canvas Rendering

```javascript
const drawWaveform = () => {
  const canvas = canvasRef.current;
  const ctx = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;
  
  // Get frequency data
  const dataArray = new Uint8Array(analyser.frequencyBinCount);
  analyser.getByteFrequencyData(dataArray);
  
  // Clear canvas
  ctx.fillStyle = 'transparent';
  ctx.fillRect(0, 0, width, height);
  
  // Draw waveform bars
  const barWidth = width / dataArray.length;
  const barCount = Math.min(dataArray.length, 200); // Limit bars
  
  for (let i = 0; i < barCount; i++) {
    const barHeight = (dataArray[i] / 255) * height;
    const x = (width / barCount) * i;
    
    // Create gradient
    const gradient = ctx.createLinearGradient(0, height, 0, height - barHeight);
    gradient.addColorStop(0, '#EFBF04'); // Gold
    gradient.addColorStop(0.5, '#FFD700');
    gradient.addColorStop(1, '#FFFFFF');
    
    ctx.fillStyle = gradient;
    ctx.fillRect(x, height - barHeight, barWidth - 1, barHeight);
  }
  
  requestAnimationFrame(drawWaveform);
};
```

### Fallback: Pre-calculated Waveform

If Web Audio API fails (Safari), use `waveformData` from JSON:

```javascript
const drawPrecalculatedWaveform = (waveformData) => {
  const canvas = canvasRef.current;
  const ctx = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;
  
  ctx.clearRect(0, 0, width, height);
  
  const barWidth = width / waveformData.length;
  
  waveformData.forEach((value, i) => {
    const barHeight = value * height;
    const x = barWidth * i;
    
    const gradient = ctx.createLinearGradient(0, height, 0, height - barHeight);
    gradient.addColorStop(0, '#EFBF04');
    gradient.addColorStop(1, '#FFFFFF');
    
    ctx.fillStyle = gradient;
    ctx.fillRect(x, height - barHeight, barWidth - 1, barHeight);
  });
};
```

---

## Channel Switching

### Channel Order

```javascript
const channels = [
  "last_updated_fresh",        // The South Got Something To Say Radio!
  "tunnel_radio_nyc",          // Tunnel Radio NYC
  "west_coast_g_funk_radio",   // West Coast G-Funk Radio
  "vintage_pop_rock_radio"     // Vintage Pop & Rock Radio
];
```

### Switch Function

```javascript
const switchChannel = (newChannel) => {
  // Stop current playback
  audio.pause();
  audio.currentTime = 0;
  audio.src = "";
  
  // Reset state
  setUserManuallyPaused(false);
  lastLoadedTrackIdRef.current = null;
  initialSyncDoneRef.current = false;
  
  // Set new channel
  setIsSwitchingChannel(true);
  setCurrentJsonSource(newChannel);
  
  // Playlist will reload automatically via useEffect
};
```

### Next/Previous

```javascript
const nextChannel = () => {
  const currentIndex = channels.indexOf(currentJsonSource);
  const nextIndex = (currentIndex + 1) % channels.length;
  switchChannel(channels[nextIndex]);
};

const previousChannel = () => {
  const currentIndex = channels.indexOf(currentJsonSource);
  const prevIndex = (currentIndex - 1 + channels.length) % channels.length;
  switchChannel(channels[prevIndex]);
};
```

---

## Firebase Sync Logic

### Document Structure

**Collection**: `radio`  
**Document**: `stream`

```javascript
{
  startTimestampUTC: 1704067200000 // Unix timestamp (milliseconds)
}
```

### Sync Algorithm

1. **Get Start Time**: Read `startTimestampUTC` from Firebase
2. **Calculate Elapsed**: `elapsedSeconds = (currentUTC - startTimestampUTC) / 1000`
3. **Find Loop Position**: `position = elapsedSeconds % totalLoopDuration`
4. **Find Track**: Iterate through sorted playlist to find track at position
5. **Calculate Track Position**: `positionInTrack = position - track.elapsedDuration`

### Implementation

```javascript
const calculateCurrentPosition = async () => {
  // Get Firebase document
  const streamDoc = doc(db, "radio", "stream");
  const snap = await getDoc(streamDoc);
  
  if (!snap.exists()) return null;
  
  const startTimestampUTC = snap.data().startTimestampUTC;
  const currentUTC = Date.now();
  const elapsedSeconds = (currentUTC - startTimestampUTC) / 1000;
  
  // Sort playlist by elapsedDuration
  const sortedPlaylist = [...playlist].sort(
    (a, b) => a.elapsedDuration - b.elapsedDuration
  );
  
  // Calculate total loop duration
  const lastTrack = sortedPlaylist[sortedPlaylist.length - 1];
  const totalLoopDuration = lastTrack.elapsedDuration + lastTrack.duration;
  
  // Get position in loop
  let syncedPosition = elapsedSeconds % totalLoopDuration;
  if (syncedPosition < 0) syncedPosition += totalLoopDuration;
  
  // Find track at position
  for (let i = 0; i < sortedPlaylist.length; i++) {
    const track = sortedPlaylist[i];
    const start = track.elapsedDuration;
    const end = start + track.duration;
    
    if (syncedPosition >= start && syncedPosition < end) {
      return {
        track: track,
        positionInTrack: syncedPosition - start
      };
    }
  }
  
  // Fallback to first track
  return {
    track: sortedPlaylist[0],
    positionInTrack: 0
  };
};
```

---

## Responsive Design

### Breakpoints

```css
/* Mobile */
@media (max-width: 767px) {
  /* Mobile-specific styles */
}

/* Tablet */
@media (min-width: 768px) and (max-width: 1023px) {
  /* Tablet-specific styles */
}

/* Desktop */
@media (min-width: 1024px) {
  /* Desktop-specific styles */
}
```

### Mobile Layout

```css
.mobile-layout {
  display: flex;
  flex-direction: column;
  gap: 15px;
  width: 100%;
  padding: 0 10px; /* iOS Safari fix */
}

.audio-container-pointer-setter {
  min-height: 275px;
  max-height: 400px;
  padding: 0 8px;
}
```

### Desktop Layout

```css
.desktop-layout {
  display: flex;
  flex-direction: row;
  gap: 24px;
}

.audio-container-pointer-setter {
  max-height: 400px;
}
```

### iOS Safari Specific

```css
@supports (-webkit-touch-callout: none) {
  .mobileLayoutVicode {
    padding: 0px !important;
    margin-top: 8px !important;
  }
  
  .video-player-section {
    padding: 0px 10px !important;
  }
  
  .video-info-box {
    padding-left: 10px !important;
    padding-right: 10px !important;
  }
}
```

---

## iOS Safari Fixes

### 1. Padding Issues

**Problem**: iOS Safari adds extra padding/margin  
**Solution**: Use `!important` and `@supports (-webkit-touch-callout: none)`

```css
@supports (-webkit-touch-callout: none) {
  .mobileLayoutVicode {
    padding: 0px !important;
    margin-top: 8px !important;
  }
  
  .video-player.audio-container-pointer-setter {
    padding: 0px !important;
    width: 100% !important;
  }
}
```

### 2. Audio Context Suspension

**Problem**: AudioContext starts suspended on iOS  
**Solution**: Resume on user interaction

```javascript
if (audioContext.state === "suspended") {
  await audioContext.resume();
  // Wait longer for iOS
  await new Promise(resolve => setTimeout(resolve, 150));
}
```

### 3. MediaElementSource Limitation

**Problem**: Safari only allows ONE MediaElementSource per audio element  
**Solution**: Use shared singleton pattern

```javascript
const sharedMediaElementSourceByEl = new WeakMap();

const getOrCreateSharedMediaElementSource = (audioContext, audioEl) => {
  const existing = sharedMediaElementSourceByEl.get(audioEl);
  if (existing) return existing;
  const node = audioContext.createMediaElementSource(audioEl);
  sharedMediaElementSourceByEl.set(audioEl, node);
  return node;
};
```

### 4. Full Page Scroll

**Problem**: Comments section blocks page scroll  
**Solution**: Remove height constraints

```css
@media (max-width: 767px) {
  .mobile-comments-inline {
    max-height: none !important;
    overflow: visible !important;
  }
  
  .mobile-layout {
    overflow-y: auto !important;
    -webkit-overflow-scrolling: touch;
  }
}
```

---

## Flutter Implementation Steps

### 1. Project Setup

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  just_audio: ^0.9.36  # Audio playback
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.6
  http: ^1.1.0  # JSON loading
  audioplayers: ^5.2.1  # Alternative audio player
  flutter_sound: ^9.2.13  # Advanced audio features
  provider: ^6.1.1  # State management
  cached_network_image: ^3.3.0  # Image loading
```

### 2. State Management (Provider)

```dart
// audio_player_provider.dart
class AudioPlayerProvider extends ChangeNotifier {
  AudioPlayer? _audioPlayer;
  List<Track> _playlist = [];
  Track? _currentTrack;
  double _currentTime = 0;
  double _duration = 0;
  double _volume = 0.8;
  bool _isPlaying = false;
  String _currentJsonSource = "last_updated_fresh";
  
  // Load playlist from JSON
  Future<void> loadPlaylist(String jsonSource) async {
    final response = await http.get(Uri.parse('assets/$jsonSource.json'));
    final List<dynamic> data = json.decode(response.body);
    _playlist = data.map((json) => Track.fromJson(json)).toList();
    _playlist.sort((a, b) => a.sequence.compareTo(b.sequence));
    notifyListeners();
  }
  
  // Calculate current position from Firebase
  Future<PositionData?> calculateCurrentPosition() async {
    final doc = await FirebaseFirestore.instance
        .collection('radio')
        .doc('stream')
        .get();
    
    if (!doc.exists) return null;
    
    final startTimestampUTC = doc.data()!['startTimestampUTC'] as int;
    final currentUTC = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (currentUTC - startTimestampUTC) / 1000;
    
    // Find track at position
    // ... (same logic as JavaScript)
  }
  
  // Load and play track
  Future<void> loadTrack(Track track, double startTime) async {
    // Fix S3 URL
    String audioUrl = fixS3UrlFormat(track.mp3Url);
    
    await _audioPlayer?.setUrl(audioUrl);
    await _audioPlayer?.seek(Duration(seconds: startTime.toInt()));
    
    _currentTrack = track;
    notifyListeners();
  }
}
```

### 3. Track Model

```dart
// track.dart
class Track {
  final int sequence;
  final String title;
  final String description;
  final int duration;
  final String durationString;
  final int elapsedDuration;
  final String url;
  final String id;
  final String thumbnail;
  final String mp3Url;
  final String artist;
  final String album;
  final int year;
  final List<double> waveformData;
  
  Track({
    required this.sequence,
    required this.title,
    required this.description,
    required this.duration,
    required this.durationString,
    required this.elapsedDuration,
    required this.url,
    required this.id,
    required this.thumbnail,
    required this.mp3Url,
    required this.artist,
    required this.album,
    required this.year,
    required this.waveformData,
  });
  
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      sequence: json['sequence'],
      title: json['title'],
      description: json['description'] ?? '',
      duration: json['duration'],
      durationString: json['duration_string'] ?? '',
      elapsedDuration: json['elapsedDuration'],
      url: json['url'],
      id: json['id'],
      thumbnail: json['thumbnail'],
      mp3Url: json['mp3_url'],
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      year: json['year'] ?? 0,
      waveformData: (json['waveformData'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ?? [],
    );
  }
}
```

### 4. UI Components

#### Audio Player Widget

```dart
// audio_player_widget.dart
class AudioPlayerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, provider, child) {
        final track = provider.currentTrack;
        if (track == null) return CircularProgressIndicator();
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // Track Title
              Text(
                track.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              
              // Track Info Row
              Row(
                children: [
                  // Play/Pause Button
                  IconButton(
                    icon: Icon(
                      provider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Color(0xFFEFBF04),
                      size: 36,
                    ),
                    onPressed: () => provider.togglePlayPause(),
                  ),
                  
                  // Track Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.artist,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          track.album,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          track.year.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Thumbnail
              Container(
                width: double.infinity,
                height: 200,
                child: CachedNetworkImage(
                  imageUrl: track.thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Waveform
              Container(
                width: double.infinity,
                height: 120,
                child: WaveformWidget(
                  waveformData: track.waveformData,
                  isPlaying: provider.isPlaying,
                ),
              ),
              
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Volume
                  IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.white),
                    onPressed: () {},
                  ),
                  
                  // Like
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                  
                  // Previous
                  IconButton(
                    icon: Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: () => provider.previousChannel(),
                  ),
                  
                  // Next
                  IconButton(
                    icon: Icon(Icons.skip_next, color: Colors.white),
                    onPressed: () => provider.nextChannel(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
```

#### Waveform Widget

```dart
// waveform_widget.dart
class WaveformWidget extends StatelessWidget {
  final List<double> waveformData;
  final bool isPlaying;
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(waveformData, isPlaying),
      size: Size.infinite,
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final bool isPlaying;
  
  WaveformPainter(this.waveformData, this.isPlaying);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;
    
    final barWidth = size.width / waveformData.length;
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < waveformData.length; i++) {
      final value = waveformData[i];
      final barHeight = value * size.height;
      final x = barWidth * i;
      
      // Create gradient
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFFEFBF04), // Gold
          Color(0xFFFFD700),
          Colors.white,
        ],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
      );
      
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - barHeight, barWidth - 1, barHeight),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
           oldDelegate.isPlaying != isPlaying;
  }
}
```

### 5. Firebase Sync

```dart
// Sync every 5 seconds
Timer.periodic(Duration(seconds: 5), (timer) async {
  final positionData = await provider.calculateCurrentPosition();
  if (positionData != null) {
    if (positionData.track.id != provider.currentTrack?.id) {
      // Track changed
      await provider.loadTrack(positionData.track, positionData.positionInTrack);
      if (!provider.userManuallyPaused) {
        await provider.play();
      }
    } else {
      // Same track - sync position
      final currentTime = await provider.audioPlayer?.position;
      final diff = (positionData.positionInTrack - currentTime!.inSeconds).abs();
      if (diff > 3) {
        await provider.audioPlayer?.seek(
          Duration(seconds: positionData.positionInTrack.toInt()),
        );
      }
    }
  }
});
```

### 6. S3 URL Fix

```dart
String fixS3UrlFormat(String url) {
  const problematicDomain = "yeek.tv.s3.eu-north-1.amazonaws.com";
  
  if (url.contains(problematicDomain)) {
    final domainIndex = url.indexOf(problematicDomain + "/");
    if (domainIndex != -1) {
      final path = url.substring(domainIndex + problematicDomain.length + 1);
      return "https://s3.eu-north-1.amazonaws.com/yeek.tv/$path";
    }
  }
  
  // Ensure HTTPS
  if (url.startsWith("http://")) {
    return url.replaceFirst("http://", "https://");
  }
  
  return url;
}
```

### 7. Styling

```dart
// theme.dart
final appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFFEFBF04), // Gold
  scaffoldBackgroundColor: Color(0xFF0f0f0f),
  backgroundColor: Color(0xFF1a1a1a),
  textTheme: TextTheme(
    headline6: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyText1: TextStyle(
      fontSize: 14,
      color: Colors.grey[400],
    ),
  ),
);
```

### 8. Responsive Design

```dart
// Use LayoutBuilder for responsive design
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 768) {
      // Mobile layout
      return MobileAudioLayout();
    } else {
      // Desktop layout
      return DesktopAudioLayout();
    }
  },
)
```

---

## Key Implementation Notes

### 1. Audio Playback
- Use `just_audio` package for reliable cross-platform audio
- Handle autoplay policies (start muted, unmute on user interaction)
- Implement proper error handling for network issues

### 2. State Management
- Use Provider or Riverpod for global state
- Keep audio player state separate from UI state
- Implement proper cleanup on dispose

### 3. Firebase Sync
- Sync every 5 seconds (not too frequent to avoid rate limits)
- Handle offline scenarios gracefully
- Cache last known position if Firebase is unavailable

### 4. Waveform Visualization
- Use pre-calculated `waveformData` from JSON (more reliable than real-time)
- Animate bars smoothly using `AnimationController`
- Handle empty/null waveform data

### 5. Channel Switching
- Pause current audio before switching
- Clear audio source
- Reset sync flags
- Load new playlist
- Sync to live position

### 6. Error Handling
- Network errors (retry with exponential backoff)
- Audio loading failures (skip to next track)
- Firebase connection issues (use cached position)
- Invalid JSON data (fallback to default playlist)

---

## Testing Checklist

- [ ] Playlist loads correctly from JSON
- [ ] Firebase sync calculates correct position
- [ ] Track switches automatically when sync detects change
- [ ] Channel switching works smoothly
- [ ] Waveform displays correctly
- [ ] Play/Pause works
- [ ] Volume control works
- [ ] Like button toggles
- [ ] Comments section scrolls properly
- [ ] Responsive design works on all screen sizes
- [ ] iOS Safari specific fixes work
- [ ] Offline mode handles gracefully
- [ ] Error handling works for network failures

---

## Additional Resources

- **Just Audio Package**: https://pub.dev/packages/just_audio
- **Firebase Flutter**: https://firebase.flutter.dev/
- **Provider State Management**: https://pub.dev/packages/provider
- **Custom Paint (Waveform)**: https://api.flutter.dev/flutter/rendering/CustomPainter-class.html

---

## Conclusion

This documentation provides a complete guide to implementing the Audio Page in Flutter. Follow the steps sequentially, and ensure all key features are implemented:

1. ✅ JSON playlist loading
2. ✅ Firebase sync logic
3. ✅ Audio playback with just_audio
4. ✅ Waveform visualization
5. ✅ Channel switching
6. ✅ Responsive design
7. ✅ Error handling

Good luck with your Flutter implementation! 🚀

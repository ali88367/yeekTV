# Subscribe Button - React/React Native Implementation Guide

## Overview
This document provides a complete implementation guide for recreating the Flutter Subscribe Button in React (Web) and React Native with all animations, particles, bell ring, and state management exactly as in the Flutter version.

---

## Table of Contents
1. [React Web Implementation](#react-web-implementation)
2. [React Native Implementation](#react-native-implementation)
3. [Particle Animation System](#particle-animation-system)
4. [Animation Timings & Synchronization](#animation-timings--synchronization)
5. [State Management](#state-management)
6. [Complete Code Examples](#complete-code-examples)

---

## React Web Implementation

### Required Dependencies

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "framer-motion": "^10.16.0",
    "zustand": "^4.4.0"
  }
}
```

### Install Command
```bash
npm install framer-motion zustand
# or
yarn add framer-motion zustand
```

---

## Component Structure

### 1. SubscribeButton Component (React Web)

```tsx
import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence, useAnimation } from 'framer-motion';
import { useParticleAnimation } from './hooks/useParticleAnimation';
import { useBellAnimation } from './hooks/useBellAnimation';
import './SubscribeButton.css';

// Button states enum
enum ButtonState {
  INITIAL = 'initial',      // "Subscribe" text, white background
  ANIMATING = 'animating',  // Gold, shrinking, showing bell
  FINAL_STATE = 'finalState' // Gold, bell + arrow
}

interface SubscribeButtonProps {
  isSubscribed: boolean;
  onSubscribe: () => void;
  onUnsubscribe: () => void;
}

const SubscribeButton: React.FC<SubscribeButtonProps> = ({
  isSubscribed,
  onSubscribe,
  onUnsubscribe,
}) => {
  const [buttonState, setButtonState] = useState<ButtonState>(ButtonState.INITIAL);
  const [showArrow, setShowArrow] = useState(false);
  const [showParticles, setShowParticles] = useState(false);

  // Animation controls
  const particleControls = useParticleAnimation(showParticles);
  const bellControls = useBellAnimation();

  // Constants
  const FULL_WIDTH = 150; // px
  const COLLAPSED_WIDTH = 53.6; // px
  const GOLD_COLOR = '#EFBF04';
  const WHITE_COLOR = '#FFFFFF';

  // Listen to subscription changes
  useEffect(() => {
    if (!isSubscribed) {
      setButtonState(ButtonState.INITIAL);
      setShowArrow(false);
    }
  }, [isSubscribed]);

  const handleButtonClick = () => {
    if (buttonState !== ButtonState.INITIAL) {
      // Already subscribed - show menu or unsubscribe
      onUnsubscribe();
      return;
    }

    // Start subscribe animation
    setButtonState(ButtonState.ANIMATING);
    setShowArrow(false);

    // Trigger particle animation
    setShowParticles(true);
    onSubscribe();

    // Show arrow immediately
    setShowArrow(true);

    // Start bell animation sequence
    bellControls.start('ring').then(() => {
      setButtonState(ButtonState.FINAL_STATE);
    });
  };

  // Calculate button width
  const buttonWidth = buttonState === ButtonState.INITIAL 
    ? FULL_WIDTH 
    : COLLAPSED_WIDTH;

  // Calculate background color
  const bgColor = buttonState === ButtonState.INITIAL 
    ? WHITE_COLOR 
    : GOLD_COLOR;

  // Border color
  const borderColor = buttonState === ButtonState.INITIAL
    ? 'rgba(255, 255, 255, 0.2)'
    : GOLD_COLOR;

  return (
    <div className="subscribe-button-container">
      <motion.button
        className="subscribe-button"
        onClick={handleButtonClick}
        animate={{
          width: `${buttonWidth}px`,
          backgroundColor: bgColor,
          borderColor: borderColor,
        }}
        transition={{
          duration: 0.32, // 320ms
          ease: [0.65, 0, 0.35, 1], // easeInOutCubic
        }}
        style={{
          height: '30px',
          borderRadius: '18px',
          border: `1px solid ${borderColor}`,
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.2)',
          position: 'relative',
          overflow: 'hidden',
          cursor: 'pointer',
          padding: 0,
        }}
      >
        {/* Inner border (always gold) */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            border: '3px solid #EFBF04',
            borderRadius: '18px',
            pointerEvents: 'none',
          }}
        />

        {/* Content */}
        <AnimatePresence mode="wait">
          {buttonState === ButtonState.INITIAL ? (
            <motion.div
              key="subscribe-text"
              initial={{ opacity: 0, scaleX: 0 }}
              animate={{ opacity: 1, scaleX: 1 }}
              exit={{ opacity: 0, scaleX: 0 }}
              transition={{
                duration: 0.22, // 220ms
                ease: [0, 0, 0.2, 1], // easeOut for in
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                height: '100%',
                width: '100%',
              }}
            >
              <span
                style={{
                  color: '#000000',
                  fontSize: '14px',
                  fontWeight: 800,
                }}
              >
                Subscribe
              </span>
            </motion.div>
          ) : (
            <motion.div
              key={`bell-${showArrow}`}
              initial={{ opacity: 0, scaleX: 0 }}
              animate={{ opacity: 1, scaleX: 1 }}
              exit={{ opacity: 0, scaleX: 0 }}
              transition={{
                duration: 0.22, // 220ms
                ease: [0, 0, 0.2, 1], // easeOut for in
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                height: '100%',
                width: '100%',
              }}
            >
              <BellIcon showArrow={showArrow} controls={bellControls} />
            </motion.div>
          )}
        </AnimatePresence>

        {/* Particle overlay */}
        {showParticles && (
          <ParticleOverlay
            progress={particleControls.progress}
            buttonWidth={FULL_WIDTH}
            buttonHeight={30}
          />
        )}
      </motion.button>
    </div>
  );
};

export default SubscribeButton;
```

### 2. Bell Icon Component

```tsx
import React from 'react';
import { motion, useAnimation } from 'framer-motion';

interface BellIconProps {
  showArrow: boolean;
  controls: any; // Animation controls from useBellAnimation
}

const BellIcon: React.FC<BellIconProps> = ({ showArrow, controls }) => {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
      <motion.div
        animate={controls}
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M12 2C8.13 2 5 5.13 5 9c0 5.25 2.49 9.45 6 12.88C11.51 21.45 14 17.25 14 12c0-3.87-3.13-7-7-7zm0 2c2.76 0 5 2.24 5 5 0 4.67-2.33 8.4-5 11.12C9.33 17.4 7 13.67 7 9c0-2.76 2.24-5 5-5zm-1 15h2v2h-2v-2zm0-8h2v6h-2V9z"
            fill="#000000"
          />
        </svg>
      </motion.div>
      {showArrow && (
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"
            fill="#000000"
          />
        </svg>
      )}
    </div>
  );
};
```

### 3. Bell Animation Hook

```tsx
import { useEffect, useRef } from 'react';
import { useAnimation } from 'framer-motion';

export const useBellAnimation = () => {
  const controls = useAnimation();

  const ring = async () => {
    // Reset
    await controls.set({ rotate: 0 });

    // Forward animation: 0 to 1 (500ms)
    await controls.start({
      rotate: [0, 0.5, 0], // Sine wave: sin(progress * π) * 0.5
      transition: {
        duration: 0.5, // 500ms
        times: [0, 0.5, 1],
        ease: (t) => {
          // Sine wave calculation: sin(t * π) * 0.5
          return Math.sin(t * Math.PI) * 0.5;
        },
      },
    });

    // Pause 150ms
    await new Promise((resolve) => setTimeout(resolve, 150));

    // Reverse animation: 1 to 0 (500ms)
    await controls.start({
      rotate: [0, -0.5, 0], // Reverse sine wave
      transition: {
        duration: 0.5, // 500ms
        times: [0, 0.5, 1],
        ease: (t) => {
          // Reverse sine wave: sin((1-t) * π) * 0.5
          return Math.sin((1 - t) * Math.PI) * 0.5;
        },
      },
    });
  };

  return {
    start: ring,
    controls,
  };
};
```

### 4. Particle Animation Hook

```tsx
import { useEffect, useState } from 'react';

export const useParticleAnimation = (showParticles: boolean) => {
  const [progress, setProgress] = useState(0);
  const animationRef = useRef<number>();

  useEffect(() => {
    if (showParticles) {
      const startTime = Date.now();
      const duration = 800; // 800ms

      const animate = () => {
        const elapsed = Date.now() - startTime;
        const newProgress = Math.min(elapsed / duration, 1);

        setProgress(newProgress);

        if (newProgress < 1) {
          animationRef.current = requestAnimationFrame(animate);
        } else {
          setProgress(0);
        }
      };

      animationRef.current = requestAnimationFrame(animate);
    } else {
      setProgress(0);
    }

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, [showParticles]);

  return { progress };
};
```

### 5. Particle Overlay Component

```tsx
import React, { useMemo } from 'react';

interface ParticleOverlayProps {
  progress: number;
  buttonWidth: number;
  buttonHeight: number;
}

const ParticleOverlay: React.FC<ParticleOverlayProps> = ({
  progress,
  buttonWidth,
  buttonHeight,
}) => {
  const particles = useMemo(() => {
    if (progress <= 0 || progress >= 1) return [];

    const maxDistance = Math.sqrt(
      buttonWidth * buttonWidth + buttonHeight * buttonHeight
    ) / 2;

    const pinkShades = [
      '#FF69B4', // Hot pink
      '#FF1493', // Deep pink
      '#FFB6C1', // Light pink
      '#FFC0CB', // Pink
      '#FF91A4', // Salmon pink
      '#FF6B9D', // Rose pink
    ];

    const particleList: Array<{
      x: number;
      y: number;
      size: number;
      color: string;
      opacity: number;
    }> = [];

    // Main particles (100 particles)
    for (let i = 0; i < 100; i++) {
      const normalizedIndex = i / 100.0;
      const startX = (normalizedIndex * 3) % 1.0;
      const startY = (normalizedIndex * 2.5) % 1.0;
      const angle = (i * 0.618) * 2 * Math.PI + (progress * 0.8);
      const distance = progress * maxDistance * (0.5 + normalizedIndex * 0.8);

      const baseX = startX * buttonWidth;
      const baseY = startY * buttonHeight;
      const x = baseX + Math.cos(angle) * distance;
      const y = baseY + Math.sin(angle) * distance;

      if (x >= 0 && x <= buttonWidth && y >= 0 && y <= buttonHeight) {
        const particleSize = (1.5 + (i % 6) * 0.4) * (1 - progress * 0.3);
        const opacity = Math.max(0, Math.min(1, 1 - progress * 1.1));

        particleList.push({
          x,
          y,
          size: particleSize,
          color: pinkShades[i % pinkShades.length],
          opacity,
        });
      }
    }

    // Edge particles (80 particles)
    for (let i = 0; i < 80; i++) {
      const edgeIndex = i % 4;
      let startX: number, startY: number;

      if (edgeIndex === 0) {
        startX = (i / 80.0) * buttonWidth;
        startY = 0;
      } else if (edgeIndex === 1) {
        startX = buttonWidth;
        startY = (i / 80.0) * buttonHeight;
      } else if (edgeIndex === 2) {
        startX = (1 - i / 80.0) * buttonWidth;
        startY = buttonHeight;
      } else {
        startX = 0;
        startY = (1 - i / 80.0) * buttonHeight;
      }

      const angle = (i * 0.5) * 2 * Math.PI + (progress * 0.6);
      const distance = progress * maxDistance * 0.7;
      const x = startX + Math.cos(angle) * distance;
      const y = startY + Math.sin(angle) * distance;

      if (
        x >= 0 &&
        x <= buttonWidth &&
        y >= 0 &&
        y <= buttonHeight &&
        progress < 0.9
      ) {
        const sparkleSize = (1.2 + (i % 4) * 0.3) * (1 - progress);
        const opacity = Math.max(0, Math.min(1, 1 - progress * 1.4));

        particleList.push({
          x,
          y,
          size: sparkleSize,
          color: pinkShades[(i + 2) % pinkShades.length],
          opacity: opacity * 0.85,
        });
      }
    }

    // Corner particles (50 particles)
    for (let i = 0; i < 50; i++) {
      const corner = i % 4;
      let cornerX: number, cornerY: number;

      if (corner === 0) {
        cornerX = 0;
        cornerY = 0;
      } else if (corner === 1) {
        cornerX = buttonWidth;
        cornerY = 0;
      } else if (corner === 2) {
        cornerX = buttonWidth;
        cornerY = buttonHeight;
      } else {
        cornerX = 0;
        cornerY = buttonHeight;
      }

      const angle = (i * 0.4) * 2 * Math.PI + (progress * 0.5);
      const distance = progress * maxDistance * 0.6;
      const x = cornerX + Math.cos(angle) * distance;
      const y = cornerY + Math.sin(angle) * distance;

      if (
        x >= 0 &&
        x <= buttonWidth &&
        y >= 0 &&
        y <= buttonHeight &&
        progress < 0.75
      ) {
        const tinySize = (1.0 + (i % 3) * 0.3) * (1 - progress);
        const opacity = Math.max(0, Math.min(1, 1 - progress * 1.8));

        particleList.push({
          x,
          y,
          size: tinySize,
          color: pinkShades[(i + 4) % pinkShades.length],
          opacity: opacity * 0.7,
        });
      }
    }

    return particleList;
  }, [progress, buttonWidth, buttonHeight]);

  return (
    <div
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        pointerEvents: 'none',
        overflow: 'hidden',
      }}
    >
      <svg
        width={buttonWidth}
        height={buttonHeight}
        style={{ position: 'absolute', top: 0, left: 0 }}
      >
        {particles.map((particle, index) => (
          <circle
            key={index}
            cx={particle.x}
            cy={particle.y}
            r={particle.size}
            fill={particle.color}
            opacity={particle.opacity}
          />
        ))}
      </svg>
    </div>
  );
};
```

---

## React Native Implementation

### Required Dependencies

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-native": "^0.72.0",
    "react-native-reanimated": "^3.5.0",
    "react-native-gesture-handler": "^2.13.0",
    "zustand": "^4.4.0"
  }
}
```

### Install Command
```bash
npm install react-native-reanimated react-native-gesture-handler zustand
# or
yarn add react-native-reanimated react-native-gesture-handler zustand
```

### Setup (babel.config.js)
```js
module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
  plugins: [
    'react-native-reanimated/plugin', // Must be last
  ],
};
```

### SubscribeButton Component (React Native)

```tsx
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Dimensions } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSequence,
  Easing,
  runOnJS,
} from 'react-native-reanimated';
import { useParticleAnimation } from './hooks/useParticleAnimation';
import { useBellAnimation } from './hooks/useBellAnimation';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

enum ButtonState {
  INITIAL = 'initial',
  ANIMATING = 'animating',
  FINAL_STATE = 'finalState',
}

interface SubscribeButtonProps {
  isSubscribed: boolean;
  onSubscribe: () => void;
  onUnsubscribe: () => void;
}

const SubscribeButton: React.FC<SubscribeButtonProps> = ({
  isSubscribed,
  onSubscribe,
  onUnsubscribe,
}) => {
  const [buttonState, setButtonState] = useState<ButtonState>(ButtonState.INITIAL);
  const [showArrow, setShowArrow] = useState(false);
  const [showParticles, setShowParticles] = useState(false);

  // Animated values
  const buttonWidth = useSharedValue(150);
  const backgroundColor = useSharedValue('#FFFFFF');
  const borderColor = useSharedValue('rgba(255, 255, 255, 0.2)');
  const bellRotation = useSharedValue(0);
  const contentOpacity = useSharedValue(1);
  const contentScaleX = useSharedValue(1);

  const FULL_WIDTH = 150;
  const COLLAPSED_WIDTH = 53.6;
  const GOLD_COLOR = '#EFBF04';
  const WHITE_COLOR = '#FFFFFF';

  // Particle animation
  const particleProgress = useParticleAnimation(showParticles);

  // Listen to subscription changes
  useEffect(() => {
    if (!isSubscribed) {
      setButtonState(ButtonState.INITIAL);
      setShowArrow(false);
      buttonWidth.value = withTiming(FULL_WIDTH, {
        duration: 320,
        easing: Easing.bezier(0.65, 0, 0.35, 1), // easeInOutCubic
      });
      backgroundColor.value = withTiming(WHITE_COLOR, { duration: 320 });
      borderColor.value = withTiming('rgba(255, 255, 255, 0.2)', { duration: 320 });
    }
  }, [isSubscribed]);

  const handleButtonPress = () => {
    if (buttonState !== ButtonState.INITIAL) {
      onUnsubscribe();
      return;
    }

    // Start animation
    setButtonState(ButtonState.ANIMATING);
    setShowArrow(false);

    // Animate button
    buttonWidth.value = withTiming(COLLAPSED_WIDTH, {
      duration: 320,
      easing: Easing.bezier(0.65, 0, 0.35, 1),
    });
    backgroundColor.value = withTiming(GOLD_COLOR, { duration: 320 });
    borderColor.value = withTiming(GOLD_COLOR, { duration: 320 });

    // Trigger particles
    setShowParticles(true);
    onSubscribe();

    // Show arrow immediately
    setShowArrow(true);

    // Animate content transition
    contentOpacity.value = withTiming(0, { duration: 220 }, () => {
      contentOpacity.value = withTiming(1, { duration: 220 });
    });
    contentScaleX.value = withTiming(0, { duration: 220 }, () => {
      contentScaleX.value = withTiming(1, { duration: 220 });
    });

    // Bell animation
    ringBell();
  };

  const ringBell = () => {
    // Forward: 0 to 0.5 (sine wave peak)
    bellRotation.value = withSequence(
      withTiming(0.5, {
        duration: 250,
        easing: (t) => Math.sin(t * Math.PI) * 0.5,
      }),
      // Pause
      withTiming(0.5, { duration: 150 }),
      // Reverse: 0.5 to -0.5 to 0
      withTiming(-0.5, {
        duration: 250,
        easing: (t) => Math.sin((1 - t) * Math.PI) * 0.5,
      }),
      withTiming(0, {
        duration: 250,
        easing: (t) => Math.sin(t * Math.PI) * 0.5,
      }),
      // Complete
      withTiming(0, { duration: 0 }, () => {
        runOnJS(setButtonState)(ButtonState.FINAL_STATE);
      })
    );
  };

  // Animated styles
  const buttonAnimatedStyle = useAnimatedStyle(() => ({
    width: buttonWidth.value,
    backgroundColor: backgroundColor.value,
    borderColor: borderColor.value,
  }));

  const bellAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ rotate: `${bellRotation.value}rad` }],
  }));

  const contentAnimatedStyle = useAnimatedStyle(() => ({
    opacity: contentOpacity.value,
    transform: [{ scaleX: contentScaleX.value }],
  }));

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.button, buttonAnimatedStyle]}>
        {/* Inner border */}
        <View style={styles.innerBorder} />

        {/* Content */}
        <Animated.View style={[styles.content, contentAnimatedStyle]}>
          {buttonState === ButtonState.INITIAL ? (
            <Text style={styles.subscribeText}>Subscribe</Text>
          ) : (
            <View style={styles.iconContainer}>
              <Animated.View style={bellAnimatedStyle}>
                <Text style={styles.bellIcon}>🔔</Text>
              </Animated.View>
              {showArrow && <Text style={styles.arrowIcon}>⌄</Text>}
            </View>
          )}
        </Animated.View>

        {/* Particle overlay */}
        {showParticles && (
          <ParticleOverlay
            progress={particleProgress}
            buttonWidth={FULL_WIDTH}
            buttonHeight={30}
          />
        )}
      </Animated.View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
  },
  button: {
    height: 30,
    borderRadius: 18,
    borderWidth: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    overflow: 'hidden',
    position: 'relative',
  },
  innerBorder: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderWidth: 3,
    borderColor: '#EFBF04',
    borderRadius: 18,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  subscribeText: {
    color: '#000000',
    fontSize: 14,
    fontWeight: '800',
  },
  iconContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  bellIcon: {
    fontSize: 18,
  },
  arrowIcon: {
    fontSize: 18,
    color: '#000000',
  },
});

export default SubscribeButton;
```

### Particle Animation Hook (React Native)

```tsx
import { useEffect } from 'react';
import { useSharedValue, withTiming, cancelAnimation } from 'react-native-reanimated';

export const useParticleAnimation = (showParticles: boolean) => {
  const progress = useSharedValue(0);

  useEffect(() => {
    if (showParticles) {
      progress.value = withTiming(1, {
        duration: 800,
        easing: (t) => t, // Linear
      });
    } else {
      cancelAnimation(progress);
      progress.value = 0;
    }
  }, [showParticles]);

  return progress;
};
```

### Particle Overlay (React Native with react-native-svg)

**Install react-native-svg:**
```bash
npm install react-native-svg
```

```tsx
import React, { useMemo } from 'react';
import { View, StyleSheet } from 'react-native';
import Svg, { Circle } from 'react-native-svg';

interface ParticleOverlayProps {
  progress: number;
  buttonWidth: number;
  buttonHeight: number;
}

const ParticleOverlay: React.FC<ParticleOverlayProps> = ({
  progress,
  buttonWidth,
  buttonHeight,
}) => {
  const particles = useMemo(() => {
    if (progress <= 0 || progress >= 1) return [];

    const maxDistance = Math.sqrt(
      buttonWidth * buttonWidth + buttonHeight * buttonHeight
    ) / 2;

    const pinkShades = [
      '#FF69B4', // Hot pink
      '#FF1493', // Deep pink
      '#FFB6C1', // Light pink
      '#FFC0CB', // Pink
      '#FF91A4', // Salmon pink
      '#FF6B9D', // Rose pink
    ];

    const particleList: Array<{
      x: number;
      y: number;
      size: number;
      color: string;
      opacity: number;
    }> = [];

    // Main particles (100 particles)
    for (let i = 0; i < 100; i++) {
      const normalizedIndex = i / 100.0;
      const startX = (normalizedIndex * 3) % 1.0;
      const startY = (normalizedIndex * 2.5) % 1.0;
      const angle = (i * 0.618) * 2 * Math.PI + (progress * 0.8);
      const distance = progress * maxDistance * (0.5 + normalizedIndex * 0.8);

      const baseX = startX * buttonWidth;
      const baseY = startY * buttonHeight;
      const x = baseX + Math.cos(angle) * distance;
      const y = baseY + Math.sin(angle) * distance;

      if (x >= 0 && x <= buttonWidth && y >= 0 && y <= buttonHeight) {
        const particleSize = (1.5 + (i % 6) * 0.4) * (1 - progress * 0.3);
        const opacity = Math.max(0, Math.min(1, 1 - progress * 1.1));

        particleList.push({
          x,
          y,
          size: particleSize,
          color: pinkShades[i % pinkShades.length],
          opacity,
        });
      }
    }

    // Edge particles (80 particles)
    for (let i = 0; i < 80; i++) {
      const edgeIndex = i % 4;
      let startX: number, startY: number;

      if (edgeIndex === 0) {
        startX = (i / 80.0) * buttonWidth;
        startY = 0;
      } else if (edgeIndex === 1) {
        startX = buttonWidth;
        startY = (i / 80.0) * buttonHeight;
      } else if (edgeIndex === 2) {
        startX = (1 - i / 80.0) * buttonWidth;
        startY = buttonHeight;
      } else {
        startX = 0;
        startY = (1 - i / 80.0) * buttonHeight;
      }

      const angle = (i * 0.5) * 2 * Math.PI + (progress * 0.6);
      const distance = progress * maxDistance * 0.7;
      const x = startX + Math.cos(angle) * distance;
      const y = startY + Math.sin(angle) * distance;

      if (
        x >= 0 &&
        x <= buttonWidth &&
        y >= 0 &&
        y <= buttonHeight &&
        progress < 0.9
      ) {
        const sparkleSize = (1.2 + (i % 4) * 0.3) * (1 - progress);
        const opacity = Math.max(0, Math.min(1, 1 - progress * 1.4));

        particleList.push({
          x,
          y,
          size: sparkleSize,
          color: pinkShades[(i + 2) % pinkShades.length],
          opacity: opacity * 0.85,
        });
      }
    }

    // Corner particles (50 particles)
    for (let i = 0; i < 50; i++) {
      const corner = i % 4;
      let cornerX: number, cornerY: number;

      if (corner === 0) {
        cornerX = 0;
        cornerY = 0;
      } else if (corner === 1) {
        cornerX = buttonWidth;
        cornerY = 0;
      } else if (corner === 2) {
        cornerX = buttonWidth;
        cornerY = buttonHeight;
      } else {
        cornerX = 0;
        cornerY = buttonHeight;
      }

      const angle = (i * 0.4) * 2 * Math.PI + (progress * 0.5);
      const distance = progress * maxDistance * 0.6;
      const x = cornerX + Math.cos(angle) * distance;
      const y = cornerY + Math.sin(angle) * distance;

      if (
        x >= 0 &&
        x <= buttonWidth &&
        y >= 0 &&
        y <= buttonHeight &&
        progress < 0.75
      ) {
        const tinySize = (1.0 + (i % 3) * 0.3) * (1 - progress);
        const opacity = Math.max(0, Math.min(1, 1 - progress * 1.8));

        particleList.push({
          x,
          y,
          size: tinySize,
          color: pinkShades[(i + 4) % pinkShades.length],
          opacity: opacity * 0.7,
        });
      }
    }

    return particleList;
  }, [progress, buttonWidth, buttonHeight]);

  return (
    <View style={StyleSheet.absoluteFill} pointerEvents="none">
      <Svg width={buttonWidth} height={buttonHeight}>
        {particles.map((particle, index) => (
          <Circle
            key={index}
            cx={particle.x}
            cy={particle.y}
            r={particle.size}
            fill={particle.color}
            opacity={particle.opacity}
          />
        ))}
      </Svg>
    </View>
  );
};
```

---

## Animation Timings & Synchronization

### Complete Animation Timeline

```
Time 0ms:     User taps button
              ↓
Time 0ms:     State → ANIMATING
              Width: 150px → 53.6px (starts, 320ms)
              Color: white → gold (starts, 320ms)
              ↓
Time 0ms:     Particle animation starts (800ms)
              ↓
Time 0ms:     Arrow appears (_showArrow = true)
              ↓
Time 0ms:     Content transition starts (220ms)
              Text fades out, Bell fades in
              ↓
Time 0ms:     Bell animation forward starts (500ms)
              ↓
Time 220ms:   Content transition completes
              ↓
Time 320ms:   Button width/color animation completes
              ↓
Time 500ms:   Bell forward completes
              ↓
Time 650ms:   Bell pause ends (150ms pause)
              ↓
Time 800ms:   Particle animation completes
              Particles hidden
              ↓
Time 900ms:   Bell reverse completes (500ms reverse)
              ↓
Time 1150ms:  Bell animation fully complete
              State → FINAL_STATE
```

### Key Timings

| Animation | Duration | Easing |
|-----------|----------|--------|
| Button Width/Color | 320ms | easeInOutCubic |
| Content Transition | 220ms | easeOut (in), easeIn (out) |
| Particle Animation | 800ms | Linear |
| Bell Forward | 500ms | Sine wave |
| Bell Pause | 150ms | - |
| Bell Reverse | 500ms | Sine wave (reverse) |
| **Total Subscribe** | **~1150ms** | - |

---

## State Management

### Using Zustand (Recommended)

```tsx
import create from 'zustand';

interface SubscribeStore {
  isSubscribed: boolean;
  subscriptionPreference: 'All' | 'Personalized' | 'None';
  subscribe: () => void;
  unsubscribe: () => void;
  setPreference: (pref: 'All' | 'Personalized' | 'None') => void;
}

export const useSubscribeStore = create<SubscribeStore>((set) => ({
  isSubscribed: false,
  subscriptionPreference: 'All',
  subscribe: () => set({ isSubscribed: true }),
  unsubscribe: () => set({ isSubscribed: false, subscriptionPreference: 'All' }),
  setPreference: (pref) => set({ subscriptionPreference: pref }),
}));
```

### Usage in Component

```tsx
import { useSubscribeStore } from './store/subscribeStore';

const SubscribeButton = () => {
  const { isSubscribed, subscribe, unsubscribe } = useSubscribeStore();

  return (
    <SubscribeButton
      isSubscribed={isSubscribed}
      onSubscribe={subscribe}
      onUnsubscribe={unsubscribe}
    />
  );
};
```

---

## Complete Integration Example

### Parent Component (React Web)

```tsx
import React, { useState } from 'react';
import SubscribeButton from './components/SubscribeButton';
import SubscriptionMenu from './components/SubscriptionMenu';

const ChannelInfoBox = () => {
  const [isSubscribed, setIsSubscribed] = useState(false);
  const [subscriptionPreference, setSubscriptionPreference] = useState<'All' | 'Personalized' | 'None'>('All');
  const [showMenu, setShowMenu] = useState(false);

  const handleSubscribe = () => {
    // This will be called when button is clicked
    // The button handles its own animation
    setTimeout(() => {
      setIsSubscribed(true);
    }, 1000); // After animation completes
  };

  const handleUnsubscribe = () => {
    if (isSubscribed) {
      setShowMenu(true);
    }
  };

  const handleMenuUnsubscribe = () => {
    setIsSubscribed(false);
    setSubscriptionPreference('All');
    setShowMenu(false);
  };

  return (
    <div>
      <SubscribeButton
        isSubscribed={isSubscribed}
        onSubscribe={handleSubscribe}
        onUnsubscribe={handleUnsubscribe}
      />
      
      {showMenu && (
        <SubscriptionMenu
          isOpen={showMenu}
          onClose={() => setShowMenu(false)}
          onUnsubscribe={handleMenuUnsubscribe}
          preference={subscriptionPreference}
          onPreferenceChange={setSubscriptionPreference}
        />
      )}
    </div>
  );
};

export default ChannelInfoBox;
```

---

## Important Notes

### 1. Bell Rotation Calculation
The bell uses a sine wave for natural oscillation:
```javascript
// Forward animation
rotate = Math.sin(progress * Math.PI) * 0.5
// This creates: 0 → 0.5 → 0 radians (-29° to +29°)

// Reverse animation
rotate = Math.sin((1 - progress) * Math.PI) * 0.5
// This creates: 0 → -0.5 → 0 radians
```

### 2. Particle Colors
Use these exact pink shades for particles:
- `#FF69B4` (Hot pink)
- `#FF1493` (Deep pink)
- `#FFB6C1` (Light pink)
- `#FFC0CB` (Pink)
- `#FF91A4` (Salmon pink)
- `#FF6B9D` (Rose pink)

### 3. Button Colors
- Initial: `#FFFFFF` (white)
- Subscribed: `#EFBF04` (gold)
- Border (initial): `rgba(255, 255, 255, 0.2)`
- Border (subscribed): `#EFBF04` (gold)
- Inner border: Always `#EFBF04` with 3px width

### 4. Responsive Sizing
- Full width: `150px`
- Collapsed width: `53.6px`
- Height: `30px`
- Border radius: `18px`

### 5. Animation Easing
- Button animations: `cubic-bezier(0.65, 0, 0.35, 1)` (easeInOutCubic)
- Content transitions: `cubic-bezier(0, 0, 0.2, 1)` (easeOut) for in, `cubic-bezier(0.4, 0, 1, 1)` (easeIn) for out

---

## Testing Checklist

- [ ] Button shrinks smoothly from 150px to 53.6px
- [ ] Background color changes from white to gold
- [ ] Particles appear and animate correctly
- [ ] Bell icon rotates left-right smoothly
- [ ] Arrow appears immediately with bell
- [ ] Content transitions smoothly (text ↔ icons)
- [ ] Unsubscribe resets button to initial state
- [ ] All animations complete in correct sequence
- [ ] No visual glitches or jumps
- [ ] Performance is smooth (60fps)

---

## Troubleshooting

### Particles not showing
- Check if `showParticles` state is being set correctly
- Verify particle calculation logic
- Ensure SVG/Canvas is properly positioned

### Bell not rotating
- Verify animation controls are connected
- Check sine wave calculation
- Ensure animation duration matches (500ms forward, 500ms reverse)

### Button not shrinking
- Check animated width value
- Verify easing function
- Ensure duration is 320ms

### Content not transitioning
- Verify AnimatePresence/AnimatedSwitcher setup
- Check key props are different
- Ensure duration is 220ms

---

## Quick Start Guide

### For React Web Developers

1. **Install dependencies:**
   ```bash
   npm install framer-motion zustand
   ```

2. **Copy these files:**
   - `SubscribeButton.tsx` (main component)
   - `BellIcon.tsx` (bell icon component)
   - `ParticleOverlay.tsx` (particle animation)
   - `useBellAnimation.ts` (bell animation hook)
   - `useParticleAnimation.ts` (particle animation hook)

3. **Use in your component:**
   ```tsx
   import SubscribeButton from './components/SubscribeButton';
   
   <SubscribeButton
     isSubscribed={isSubscribed}
     onSubscribe={() => setIsSubscribed(true)}
     onUnsubscribe={() => setIsSubscribed(false)}
   />
   ```

### For React Native Developers

1. **Install dependencies:**
   ```bash
   npm install react-native-reanimated react-native-gesture-handler react-native-svg zustand
   ```

2. **Setup babel.config.js:**
   ```js
   module.exports = {
     presets: ['module:metro-react-native-babel-preset'],
     plugins: ['react-native-reanimated/plugin'], // Must be last
   };
   ```

3. **Copy the React Native SubscribeButton component**

4. **Use in your component:**
   ```tsx
   import SubscribeButton from './components/SubscribeButton';
   
   <SubscribeButton
     isSubscribed={isSubscribed}
     onSubscribe={() => setIsSubscribed(true)}
     onUnsubscribe={() => setIsSubscribed(false)}
   />
   ```

## Key Implementation Points

### 1. Exact Timings (Critical!)
- Button shrink: **320ms** with `easeInOutCubic`
- Content transition: **220ms** with `easeOut`/`easeIn`
- Particle animation: **800ms** linear
- Bell forward: **500ms** with sine wave
- Bell pause: **150ms**
- Bell reverse: **500ms** with reverse sine wave

### 2. Exact Colors
- Initial background: `#FFFFFF` (white)
- Subscribed background: `#EFBF04` (gold)
- Border (initial): `rgba(255, 255, 255, 0.2)`
- Border (subscribed): `#EFBF04` (gold)
- Inner border: Always `#EFBF04` with `3px` width

### 3. Exact Sizes
- Full width: `150px`
- Collapsed width: `53.6px`
- Height: `30px`
- Border radius: `18px`

### 4. Bell Rotation Formula
```javascript
// Forward animation
angle = Math.sin(progress * Math.PI) * 0.5
// Creates: 0 → 0.5 → 0 radians (-29° to +29°)

// Reverse animation  
angle = Math.sin((1 - progress) * Math.PI) * 0.5
// Creates: 0 → -0.5 → 0 radians
```

### 5. Animation Sequence
1. User clicks → Button starts shrinking + color changing
2. Particles appear immediately
3. Arrow appears immediately (with bell)
4. Content transitions (text → bell icon)
5. Bell rings forward (500ms)
6. Bell pauses (150ms)
7. Bell rings reverse (500ms)
8. State changes to FINAL_STATE

## Common Issues & Solutions

### Issue: Particles not showing
**Solution:** Check that `showParticles` state is being set to `true` and particle calculation is running correctly.

### Issue: Bell not rotating smoothly
**Solution:** Ensure you're using the exact sine wave formula: `Math.sin(progress * Math.PI) * 0.5`

### Issue: Button not shrinking
**Solution:** Verify animated width value changes from `150` to `53.6` with `320ms` duration and `easeInOutCubic` easing.

### Issue: Content not transitioning
**Solution:** Make sure `AnimatePresence` (React) or `AnimatedSwitcher` (React Native) keys are different for text vs icons.

## Testing Checklist

Before considering implementation complete, verify:

- [ ] Button shrinks from 150px to 53.6px smoothly
- [ ] Background changes from white to gold
- [ ] Particles appear and animate (230 total particles)
- [ ] Bell icon rotates left-right smoothly using sine wave
- [ ] Arrow appears immediately with bell (not after)
- [ ] Content transitions smoothly (text ↔ icons)
- [ ] Unsubscribe resets button to initial state
- [ ] All animations complete in correct sequence
- [ ] No visual glitches or jumps
- [ ] Performance is smooth (60fps)
- [ ] Colors match exactly (`#EFBF04` gold, white, pink particles)
- [ ] Timings match exactly (320ms, 220ms, 800ms, 500ms, 150ms)

## Conclusion

This implementation guide provides everything needed to recreate the Flutter Subscribe Button in React/React Native with identical animations, timing, and behavior. Follow the code examples and timing specifications exactly to achieve the same visual result.

**Remember:** The key to matching the Flutter version is:
1. Exact timings (320ms, 220ms, 800ms, 500ms, 150ms)
2. Exact colors (`#EFBF04` gold, white, pink shades)
3. Exact sizes (150px → 53.6px, 30px height)
4. Exact bell rotation formula (sine wave)
5. Exact particle calculation (230 particles total)

Good luck with your implementation! 🚀

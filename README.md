# Homebrew Tap for ctrlSPEAK

This repository contains the Homebrew formula for [ctrlSPEAK](https://github.com/patelnav/ctrlspeak), a minimal speech-to-text utility for macOS.

## Installation

```bash
# Add the tap
brew tap patelnav/ctrlspeak

# Install ctrlSPEAK
brew install ctrlspeak

# Or install with UV for faster dependency installation
brew install ctrlspeak --with-uv
```

## Features

- 🖥️ **Minimal Interface**: Runs quietly in the background via the command line
- ⚡ **Triple-Tap Magic**: Start/stop recording with a quick `Ctrl` triple-tap
- 📋 **Auto-Paste**: Text lands right where you need it, no extra clicks
- 🔊 **Audio Cues**: Hear when recording begins and ends
- 🍎 **Mac Optimized**: Harnesses Apple Silicon's MPS for blazing performance
- 🌟 **Top-Tier Models**: Powered by NVIDIA NeMo and OpenAI Whisper

## Usage

After installation, run `ctrlspeak` in your terminal to start the application. Triple-tap the Ctrl key to start/stop recording.

## Requirements

- macOS 12.3+
- Python 3.11+ (installed automatically)
- Microphone and Accessibility permissions (you'll be prompted to grant these) 
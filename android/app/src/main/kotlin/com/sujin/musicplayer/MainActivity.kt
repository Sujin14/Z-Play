package com.sujin.musicplayer

import com.ryanheise.audioservice.AudioServiceActivity

// Shares audio_service's Flutter engine, so playback can outlive the screen.
class MainActivity: AudioServiceActivity() {
}

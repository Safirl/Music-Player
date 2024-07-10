//
//  MusicController.swift
//  PipouPlayer
//
//  Created by loic leforestier on 09/07/2024.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var currentPlaybackTime: CMTime?
    
    @Published var isPlaying: Bool = false
    
    private init() {
        setupAudioSession()
        setupRemoteTransportControls()
            // Initialisation de l'AudioManager
        }

    private func setupAudioSession() {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, mode: .default, options: [])
                try audioSession.setActive(true)
            } catch {
                print("Error setting up audio session: \(error.localizedDescription)")
            }
        }
    
    private func setupRemoteTransportControls() {
           let commandCenter = MPRemoteCommandCenter.shared()
           
           commandCenter.playCommand.addTarget { [weak self] _ in
               self?.player?.play()
               return .success
           }
           
           commandCenter.pauseCommand.addTarget { [weak self] _ in
               self?.player?.pause()
               return .success
           }
           
           // Ajoutez d'autres commandes audio ici (par exemple, next, previous, etc.)
    }
    
    func playAudio(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Restaurer la position de lecture actuelle s'il y en a une
        if let currentPlaybackTime = currentPlaybackTime {
            player?.seek(to: currentPlaybackTime)
            self.currentPlaybackTime = nil // Réinitialiser la position après utilisation
        }
        
        player?.play()
        isPlaying = true
    }
    
    func stopAudio() {
        player?.pause()
        isPlaying = false
        currentPlaybackTime = player?.currentTime()
        print("Audio stopped")
    }
}


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
    private var currentSongId : UUID?
    
    var modelData: ModelData?
    
    @Published var currentSongIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var isInitialized: Bool = false
    //@Published var waitingList: [Song] = []

    
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
    
    
    func initializeModelData(modelData: ModelData) {
        if !isInitialized {
            self.modelData = modelData
            //waitingList = modelData.songs
            isInitialized = true
            return
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
        
        commandCenter.nextTrackCommand.addTarget{ [weak self] event in
            self?.playNextSong()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget{ [weak self] event in
            self?.playPreviousSong()
            return .success
        }
           // Ajoutez d'autres commandes audio ici (par exemple, next, previous, etc.)
    }
    
    func playAudio(fileName: String) -> Bool {
        let url = getDocumentsDirectory().appending(component: fileName).appendingPathExtension("m4a")
        guard doesFileExist(for: url) else {
            print("Audio file not found")
            return false
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
        return true
    }
    
    func playNewAudio(fileName: String) {
        guard let newSongId = modelData?.songs.first(where: { $0.fileName == fileName })?.id else {
            print("Audio file Id not found")
            return
        }
        
        if newSongId == currentSongId {
            print("The song \(fileName) is already playing.")
            return
        }
        
        //Play the audio
        guard playAudio(fileName: fileName) else {
            return
        }
        
        // Mettre à jour la chanson actuelle
        currentSongId = newSongId
        print("Playing new song: \(fileName)")
    }
    
    func stopAudio() {
        player?.pause()
        isPlaying = false
        currentPlaybackTime = player?.currentTime()
        print("Audio stopped")
    }
    
    func playNextSong(){
        guard modelData != nil else { return }
        guard !(modelData?.songs.isEmpty)! else { return }
        currentSongIndex = (currentSongIndex+1) % (modelData?.songs.count)!
        playNewAudio(fileName: (modelData?.songs[currentSongIndex].fileName)!)
    }
    
    func playPreviousSong(){
        guard modelData != nil else { return }
        guard !(modelData?.songs.isEmpty)! else { return }
        currentSongIndex = (currentSongIndex-1 + (modelData?.songs.count)!) % (modelData?.songs.count)!
        playNewAudio(fileName: (modelData?.songs[currentSongIndex].fileName)!)
    }
}


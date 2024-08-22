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
    private var playbackTimer: Timer?
    @Published var currentPlaybackPosition: Double = 0.0
    
    private var currentPlaybackTime: CMTime?
    private var currentSongId : UUID?
    
    var modelData: ModelData?
    
    @Published var currentSongIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var isInitialized: Bool = false
    @Published var playbackProgress: Double = 0.0
    //@Published var waitingList: [Song] = []
    
    private var timeObserverToken: Any?

    
    private init() {
        setupAudioSession()
        setupRemoteTransportControls()
        setupPlayerEndObserver()
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
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let player = self.player,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            
            let newTime = CMTime(seconds: event.positionTime, preferredTimescale: 1)
            player.seek(to: newTime)
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
        
        removeTimeObserver()
        removePlayerEndObserver()
        
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        addTimeObserver()
        setupPlayerEndObserver()
        
        // Restaurer la position de lecture actuelle s'il y en a une
        if let currentPlaybackTime = currentPlaybackTime {
            player?.seek(to: currentPlaybackTime)
            self.currentPlaybackTime = nil // Réinitialiser la position après utilisation
        }
        
        player?.play()
        isPlaying = true
        Task {
            await updateNowPlayingInfo()
        }
        
        return true
    }
    
    private func updateNowPlayingInfo() async {
        guard let modelData = modelData, let player = player, !modelData.songs.isEmpty else { return }
        let song = modelData.songs[currentSongIndex]
        
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artistName
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        
        // Ajouter l'image de couverture si disponible
        if let artworkImage = song.uiImage, let artworkData = artworkImage.pngData() {
            let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in
                return UIImage(data: artworkData) ?? artworkImage
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        do {
        // Ajouter la durée totale et la position actuelle du morceau
            if let duration = try await playerItem?.asset.load(.duration) {
                let durationInSeconds = CMTimeGetSeconds(duration)
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
            }
        }
        catch {
            print("Error while getting the duration : \(error.localizedDescription)")
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupPlayerEndObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        playNextSong() // Automatically play the next song
    }
    
    private func removePlayerEndObserver() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func addTimeObserver() {
        guard let player = player else { return }
        
        // Effacez l'ancien observateur s'il existe
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        // Ajouter un observateur de temps pour suivre la progression de la lecture
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = player.currentItem?.duration.seconds else { return }
            if duration > 0 {
                self.playbackProgress = (player.currentTime().seconds / duration) * 100
            }
        }
    }
    
    private func removeTimeObserver() {
        guard let player = player else { return }
        
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func playNewAudio(fileName: String) {
        guard let newSongId = modelData?.songs.first(where: { $0.fileName == fileName })?.id else {
            print("Audio file Id not found")
            return
        }
        
        guard let newIndex = modelData?.songs.firstIndex(where: { song in
            song.id == newSongId
        }) else {
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
//        currentSongId = newSongId
        currentSongIndex = newIndex
        print("Playing new song: \(fileName)")
    }
    
    func stopAudio() {
        player?.pause()
        isPlaying = false
        currentPlaybackTime = player?.currentTime()
        
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
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
    
    func seek(to percentage: Double) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let newTime = CMTime(seconds: duration.seconds * (percentage / 100), preferredTimescale: 600)
        player.seek(to: newTime)
        Task {
            await updateNowPlayingInfo()
        }
    }
}


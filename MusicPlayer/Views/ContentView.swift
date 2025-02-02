import SwiftUI

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ContentView: View {
    @Environment(ModelData.self) var modelData
    @StateObject var audioManager = AudioManager.shared
    
    var defaultSong: Song {
        return Song(
            title: "Default Title",
            artistName: "Default Artist",
            fileName: "saveMe",
            image: UIImage(named: "saveMe") ?? UIImage()
        )
    }
    
    var body: some View {
        ZStack{
            Color(Color(red: 0.97, green: 0.97, blue: 0.97))
                .ignoresSafeArea()
            if let currentSong = modelData.songs[safe: audioManager.currentSongIndex] {
                SongList(currentSong: currentSong)
            } else {
                SongList(currentSong: defaultSong)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            AudioManager.shared.initializeModelData(modelData: modelData)
        }
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}

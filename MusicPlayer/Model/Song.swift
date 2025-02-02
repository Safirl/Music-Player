//
//  Song.swift
//  PipouPlayer
//
//  Created by loic leforestier on 07/07/2024.
//

import Foundation
import SwiftUI

struct Song : Hashable, Identifiable {
    var id : UUID
    var title : String = "Unknown song"
    var artistName : String = "Unknown artist"
    var isFavorite : Bool
    var fileName: String
    
    var uiImage: UIImage?
    var image: Image {
        if let uiImage = self.uiImage {
            return Image(uiImage: uiImage)
        } else {
            return Image("blurryface")
        }
    }
    
    enum CodingKeys: String, CodingKey {
            case id, title, artistName, isFavorite, fileName, imageData
    }
    
    init(title: String, artistName: String, fileName: String, image: UIImage) {
        self.id = UUID()
        self.title = title
        self.artistName = artistName
        self.isFavorite = false
        self.fileName = fileName
        self.uiImage = image
    }
    
    mutating func toggleFavorite() {
        isFavorite.toggle()
    }
    
    func isFavoriteBinding(_ binding: Binding<Bool>) -> Self {
            var newSong = self
            newSong.isFavorite = binding.wrappedValue
            return newSong
    }
}

extension Song: Codable {
    // Encodage personnalisé
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(fileName, forKey: .fileName)
    }
    
    // Décodage personnalisé
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        fileName = try container.decode(String.self, forKey: .fileName)
    }
}

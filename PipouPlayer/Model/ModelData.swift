//
//  ModelData.swift
//  PipouPlayer
//
//  Created by loic leforestier on 07/07/2024.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI

@Observable
class ModelData {
    var songs: [Song] = []
    
    init() {
        Task {
            do {
                songs = try await loadInitialSongs()  // Chargement initial des chansons
            } catch {
                print("Failed to load songs: \(error.localizedDescription)")
            }
        }
    }
    
    // Méthode pour mettre à jour l'état isFavorite
    func updateFavoriteStatus(for song: Song, isFavorite: Bool) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].isFavorite = isFavorite

            // Sauvegarder les données après mise à jour
            save(songs, to: "songData.json")
        }
    }
    
    func saveSongs(){
        save(songs, to: "songData.json")
    }
}


func loadInitialSongs() async throws -> [Song] {
    let filename = "songData.json"
    
    //To delete documents json if the data model has been changed !! Only for Test, do not use on shipping.
//    deleteFile(named: "songData.json")
//    deleteFile(named: "Updated_driftingSmoke.m4a")
    let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
    
    return try await load(filename, fromBundle: !doesFileExist(for: fileURL))
}

func load(_ filename: String, fromBundle: Bool) async throws -> [Song] {
    let fileURL: URL
    if fromBundle {
        // Charger depuis le bundle
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Couldn't find \(filename) in bundle.")
        }
        fileURL = url
    } else {
        // Charger depuis le répertoire des documents
        fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        guard doesFileExist(for: fileURL) else {
            fatalError("Error \(fileURL) does not exist")
        }
    }
    
    let data: Data

    do {
        data = try Data(contentsOf: fileURL)
    } catch {
        fatalError("Couldn't load \(filename) from documents directory:\n\(error)")
    }
    
    var songsToRemove: [Song] = []
    
    do {
        let decoder = JSONDecoder()
        var songs = try decoder.decode([Song].self, from: data)
        
        for i in 0..<songs.count {
            let songFileUrl = getDocumentsDirectory().appendingPathComponent(songs[i].fileName).appendingPathExtension("m4a")
            guard doesFileExist(for: songFileUrl) else {
                print("Error file with name \(songs[i].fileName) does not exist at \(getDocumentsDirectory().appendingPathComponent(songs[i].fileName, conformingTo: UTType.audio))")
                songsToRemove.append(songs[i])
                continue
            }
            try await extractMetadata(from: songFileUrl) { title, artist, artwork, artworkName, error in
                if let error = error {
                    print("Error extracting metadata: \(error.localizedDescription)")
                } else {
                    songs[i].title = title ?? "Unknown song"
                    songs[i].artistName = artist ?? "Unknown artist"
                    songs[i].uiImage = artwork
                }
            }
        }
        return removeSongs(for: songsToRemove, in: songs)
    } catch {
        fatalError("Couldn't parse \(filename) as \([Song].self):\n\(error)")
    }
}

func findFile(named baseName: String, withPossibleExtensions extensions: [String], in directory: URL) -> URL? {
    do {
        _ = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        for ext in extensions {
            let fileURL = directory.appendingPathComponent("\(baseName).\(ext)")
            if doesFileExist(for: fileURL) {
                return fileURL
            }
        }
    } catch {
        print("Error accessing directory contents: \(error.localizedDescription)")
    }
    return nil
}

func removeSong(for songToRemove: Song, in songs: [Song]) -> [Song] {
    var songsToRemove: [Song] = []
    songsToRemove.append(songToRemove)
    return removeSongs(for: songsToRemove, in: songs)
}

func removeSongs(for songsToRemove: [Song], in songs: [Song]) -> [Song] {
    let songsFiltered = songs.filter { !songsToRemove.contains($0) }
    save(songsFiltered, to: "songData.json")
    return songsFiltered
}

func save<T: Encodable>(_ data: T, to filename: String) {
    let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
    printFilePath(for: "songData.json")

    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(data)
        try data.write(to: fileURL, options: [.atomicWrite, .completeFileProtection])
    } catch {
        fatalError("Couldn't save \(filename) to documents directory:\n\(error)")
    }
    print("\(fileURL) saved")
}


func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func printFilePath(for filename: String) {
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        print("File path: \(fileURL.path)")
    } else {
        print("Failed to find the documents directory.")
    }
}

func doesFileExist(for fileURL: URL) -> Bool {
    if FileManager.default.fileExists(atPath: fileURL.path){
        return true
    }
    return false
}

func deleteFile(named fileName: String) {
    // Accéder au répertoire Documents de l'application
    let fileManager = FileManager.default
    if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        // Construire le chemin complet du fichier
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Vérifier si le fichier existe
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                // Tenter de supprimer le fichier
                try fileManager.removeItem(at: fileURL)
                print("File \(fileName) successfully deleted.")
            } catch {
                print("Error deleting file \(fileName): \(error)")
            }
        } else {
            print("File \(fileName) not found.")
        }
    }
}

func extractMetadata(from url: URL, completion: @escaping (String?, String?, UIImage?, String?, Error?) -> Void) async throws {
    do {
        let isInDocumentsDirectory = doesFileExist(for: getDocumentsDirectory().appendingPathComponent(url.lastPathComponent))
        
        if isInDocumentsDirectory || url.startAccessingSecurityScopedResource() {
            defer {
                if !isInDocumentsDirectory {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let asset = AVAsset(url: url)
            
            // Chargement des métadonnées avec gestion des erreurs
            let metadataList = try await asset.load(.commonMetadata)
            
            // Load file's name and artwork if there is one
            var title: String?
            var artist: String?
            var artwork: UIImage?
            var artworkName: String?
            
            // Parcourir la liste des métadonnées
            for metadata in metadataList {
                do {
                    let value = try await metadata.load(.value)
                    switch metadata.commonKey {
                    case .commonKeyTitle:
                        title = value as? String
                    case .commonKeyArtist:
                        artist = value as? String
                    case .commonKeyArtwork:
                        if let imageData = value as? Data {
                            artwork = UIImage(data: imageData)
                            artworkName = title ?? "Song image"
                        }
                    default:
                        break
                    }
                } catch {
                    // Si une erreur survient en chargeant une valeur de métadonnée
                    print("Error loading metadata value: \(error.localizedDescription)")
                }
            }
            
            // Appel du completion handler avec les résultats et sans erreur
            completion(title, artist, artwork, artworkName, nil)
        } else {
            // Si le fichier n'est pas accessible et startAccessingSecurityScopedResource a échoué
            completion(nil, nil, nil, nil, NSError(domain: "com.yourdomain.app", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the security-scoped resource."]))
        }
    } catch {
        // Gestion des erreurs lors du chargement des métadonnées
        print("Error loading metadata: \(error.localizedDescription)")
        
        // Appel du completion handler avec l'erreur
        completion(nil, nil, nil, nil, error)
    }
}


func writeMetadata(in fileUrl: URL, title: String, artist: String, artwork: UIImage) async -> Bool  {
    guard doesFileExist(for: fileUrl),
          !title.isEmpty,
          !artist.isEmpty
    else {
        print("Error writing metadata: \(fileUrl)")
        return false
    }
    
    let asset = AVAsset(url: fileUrl)
    
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
        print("Failed to create AVAssetExportSession")
        return false
    }
    
    // Crée un nouveau fichier dans le même dossier avec un préfixe "Updated_"
    let outputFileUrl = fileUrl.deletingPathExtension().appendingPathExtension("m4a")
    
    print("Output file URL: \(outputFileUrl)")
    
    exportSession.outputFileType = .m4a
    exportSession.outputURL = outputFileUrl
    
    // Vérification de l'existence du dossier de sortie
    let outputDirectory = outputFileUrl.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: outputDirectory.path) {
        do {
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error.localizedDescription)")
            return false
        }
    }
    
    let titleMetadataItem = AVMutableMetadataItem()
    titleMetadataItem.key = AVMetadataKey.commonKeyTitle as NSString
    titleMetadataItem.keySpace = AVMetadataKeySpace.common
    titleMetadataItem.value = title as NSString
    
    let artistMetadataItem = AVMutableMetadataItem()
    artistMetadataItem.key = AVMetadataKey.commonKeyArtist as NSString
    artistMetadataItem.keySpace = AVMetadataKeySpace.common
    artistMetadataItem.value = artist as NSString
    
    let artworkMetadataItem = AVMutableMetadataItem()
    artworkMetadataItem.key = AVMetadataKey.commonKeyArtwork as NSString
    artworkMetadataItem.keySpace = AVMetadataKeySpace.common
    if let artworkData = artwork.pngData() {
        artworkMetadataItem.value = artworkData as NSData
    }
    
    exportSession.metadata = [titleMetadataItem, artistMetadataItem, artworkMetadataItem]
    
    let success = await withCheckedContinuation { continuation in
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("Successfully wrote metadata to \(outputFileUrl)")
                deleteFile(named: fileUrl.lastPathComponent)
                continuation.resume(returning: true)
            case .failed:
                print("Failed to write metadata: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                continuation.resume(returning: false)
            case .cancelled:
                print("Export cancelled: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                continuation.resume(returning: false)
            default:
                print("Unknown export status")
                continuation.resume(returning: false)
            }
        }
    }
    
    return success
}

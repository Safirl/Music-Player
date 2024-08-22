//
//  AddMusicView.swift
//  PipouPlayer
//
//  Created by loic leforestier on 01/08/2024.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import AVFoundation

struct AddMusicView: View {
    
    @State private var importedFileURL: URL? = nil
    @State private var importedCover: UIImage? = nil
    @State private var importedFileName: String? = nil
    @State private var showFileImporterMusic = false
    @State private var showFileImporterCover = false
    @State private var artistName: String = ""
    @State private var songTitle: String = ""
    @State private var importedCoverName: String? = nil
//    @State private var coverImage: UIImage?
    @Binding var showAddMusicView: Bool
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        ZStack {
            Color.clear
                .background(BlurView(style: .systemThinMaterial)) // Apply a blur effect
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 26){
                HStack{
                    Text("Music file:")
                    Button(action: {
                        showFileImporterMusic = true
                    }){
                        HStack {
                            Text(importedFileName ?? "Import file")
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Image("addFileIcon")
                                .resizable()
                                .frame(width: 32, height: 32)
                                
                        }
                    }
                    .fileImporter(
                        isPresented: $showFileImporterMusic,
                        allowedContentTypes: [UTType.audio],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            let selectedFile: URL = try result.get().first!
                            importedFileURL = selectedFile
                            importedFileName = selectedFile.lastPathComponent
                            print("Selected file: \(selectedFile)")
                            
                            Task {
                                do {
                                    try await extractMetadata(from: selectedFile) { title, artist, artwork, artworkName, error in
                                        if let error = error {
                                            print("Error extracting metadata: \(error.localizedDescription)")
                                        } else {
                                            // Update the UI with the extracted metadata
                                            songTitle = title ?? "Unknown Title"
                                            artistName = artist ?? "Unknown Artist"
                                            importedCoverName = artworkName ?? ""
                                            importedCover = artwork
                                        }
                                    }
                                } catch {
                                    print("Unexpected error: \(error.localizedDescription)")
                                }
                            }
                        } catch {
                            print("File selection failed: \(error.localizedDescription)")
                        }
                    }
                }
                HStack{
                    Text("Artist name:")
                    TextField("Enter artist name", text: $artistName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack{
                    Text("Song title:")
                    TextField("Enter song title", text: $songTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack{
                    Text("Cover image:")
                    Button(action: {
                        showFileImporterCover = true
                    }){
                        HStack {
                            Text(importedCoverName ?? "Import cover image")
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Image("addCoverIcon")
                                .resizable()
                                .frame(width: 21, height: 21)
                                
                        }
                    }
                    .fileImporter(
                        isPresented: $showFileImporterCover,
                        allowedContentTypes: [UTType.image],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            let selectedFile: URL = try result.get().first!
                            if selectedFile.startAccessingSecurityScopedResource() {
                                defer {
                                    selectedFile.stopAccessingSecurityScopedResource()
                                }
                                
                                let imageData = try Data(contentsOf: selectedFile)
                                importedCover = UIImage(data: imageData)
                                importedCoverName = selectedFile.lastPathComponent
                                print("Selected file: \(selectedFile)")
                            }
                        } catch {
                            print("File selection failed: \(error.localizedDescription)")
                        }
                    }
                }
                HStack{
                    Button(action: {
                        resetFields()
                    }){
                        Text("Cancel")
                    }
                    Spacer()
                    Button(action: {
                        Task {
                            await importSong()
                        }
                    }){
                        Text("Import song")
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 25.0)
                    .shadow(color: Color.gray.opacity(0.3), radius: 5)
                    .foregroundColor(Color(red: 0.97, green: 0.97, blue: 0.97))
            )
            .padding()
        }
    }
    
    struct BlurView: UIViewRepresentable {
        var style: UIBlurEffect.Style

        func makeUIView(context: Context) -> UIVisualEffectView {
            let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
            return view
        }

        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
            uiView.effect = UIBlurEffect(style: style)
        }
    }
    
    private func resetFields() {
        importedFileURL = nil
        importedCover = nil
        artistName = ""
        songTitle = ""
        importedFileName = nil
        importedCoverName = nil
        importedCover = nil
        showAddMusicView = false
    }
    
    private func importSong() async {
        guard let fileURL = importedFileURL,
              importedCoverName != nil,
              !artistName.isEmpty,
              !songTitle.isEmpty,
              importedCover != nil
        else {
            print("Please fill all fields and import files.")
            return
        }
        
        let fileName = fileURL.deletingPathExtension().lastPathComponent
        
        let newSong = Song(
            title: songTitle,
            artistName: artistName,
            fileName: fileName,
            image: importedCover!
        )
        
        var copiedFileURL: URL?

        do {
            copiedFileURL = try copyFileToDocumentsDirectory(from: fileURL)
        } catch {
            print("Error when copying the file to documents directory: \(error.localizedDescription)")
            return
        }

        guard await writeMetadata(in: copiedFileURL!, title: newSong.title, artist: newSong.artistName, artwork: importedCover!) else {
            print("Failed to write metadata in file at \(copiedFileURL!)")
            deleteFile(named: copiedFileURL!.lastPathComponent)
            resetFields()
            return
        }
        
        modelData.songs.append(newSong)
        modelData.saveSongs()
        
        resetFields()
    }
    
    enum FileCopyError: Error {
        case fileAlreadyExists(String)
        case failedToCopy(String)
    }
    
    func copyFileToDocumentsDirectory(from urlAudioFile: URL) throws -> URL? {
        if urlAudioFile.startAccessingSecurityScopedResource() {
            defer {
                urlAudioFile.stopAccessingSecurityScopedResource()
            }
            let fileManager = FileManager.default
            let documentsURL = getDocumentsDirectory()
            
            // Log the source and destination URLs
            print("Source file URL: \(urlAudioFile)")
            print("Destination directory: \(documentsURL)")
            
            //audio file
            let audioFileName = urlAudioFile.lastPathComponent
            let audioDestinationURL = documentsURL.appendingPathComponent(audioFileName)
            importedFileURL = audioDestinationURL
            // Log the final destination URL
            print("Destination file URL: \(audioDestinationURL)")
            
            // Copier le fichier audio
            do {
                if !fileManager.fileExists(atPath: audioDestinationURL.path) {
                    print("File does not exist at destination, proceeding to copy.")
                    try fileManager.copyItem(at: urlAudioFile, to: audioDestinationURL)
                    print("File successfully copied to \(audioDestinationURL.path)")
                    
                    return audioDestinationURL
                    
                } else {
                    throw FileCopyError.fileAlreadyExists("File already exists at destination: \(audioDestinationURL.path)")
                }
                
            } catch let error as NSError {
                print("Failed to copy file: \(error.localizedDescription)")
                print("Error details: \(error)")
                throw error // Re-throw the error after logging
            }
        }
        return nil
    }
}

#Preview {
    AddMusicView(showAddMusicView: .constant(true))
        .environment(ModelData())
}

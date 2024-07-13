//
//  ContentView.swift
//  PipouPlayer
//
//  Created by loic leforestier on 17/12/2023.
//

import SwiftUI

struct ContentView: View {
    @Environment (ModelData.self) var modelData
    
    var body: some View {
        ZStack{
            Color(Color(red: 0.97, green: 0.97, blue: 0.97))
                .ignoresSafeArea()
            SongList()
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

//
//  PipouPlayerApp.swift
//  PipouPlayer
//
//  Created by loic leforestier on 17/12/2023.
//

import SwiftUI

@main
struct PipouPlayerApp: App {
    @State private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
        }
    }
}

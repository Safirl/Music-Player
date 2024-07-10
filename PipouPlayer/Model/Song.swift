//
//  Song.swift
//  PipouPlayer
//
//  Created by loic leforestier on 07/07/2024.
//

import Foundation
import SwiftUI

struct Song : Hashable, Codable, Identifiable {
    var id : Int
    var title : String
    var artistName : String
    var isFavorite : Bool
    var fileName: String
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
}

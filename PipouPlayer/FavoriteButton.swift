//
//  FavoriteButton.swift
//  PipouPlayer
//
//  Created by loic leforestier on 04/07/2024.
//

import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet: Bool
    
    var body: some View {
        Button{
            isSet.toggle()
        } label: {
            Label("Toggle favorite", systemImage: isSet ? "heart.fill" : "heart")
                .labelStyle(.iconOnly)
                .padding(7)
                .background(Circle()
                    .fill(Color(.white))
                    .shadow(color: Color.gray.opacity(0.3), radius: 5)
                )
                .foregroundStyle(isSet ? .pink : .gray)
        }
    }
}

#Preview {
    FavoriteButton(isSet: .constant(true))
}

//
//  CharacterView.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import SwiftUI

struct CharacterView: View {
    
    let character: CharacterResponse
    
    var body: some View {
        HStack(alignment: .top) {
            CachedAsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 100, height: 100)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(8)
                case .failure:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
            }

            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.title)
                    .foregroundStyle(.primary)

                Text(character.species ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background {
            Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ?
                UIColor.white : UIColor.red
            }).opacity(0.5)
        }
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

#Preview {
    CharacterView(
        character: CharacterResponse(
            id: 1,
            name: "Obada",
            species: "Human",
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
        )
    )
}

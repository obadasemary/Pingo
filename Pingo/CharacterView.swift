//
//  CharacterView.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import SwiftUI

struct CharacterView: View {
    let character: CharacterResponse
    private let imageSize: CGFloat = 100

    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: imageSize, height: imageSize)
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(8)
                case .failure:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
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
            Color(UIColor.secondarySystemBackground).opacity(0.5)
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

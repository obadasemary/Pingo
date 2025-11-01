//
//  CarouselView.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 01.11.2025.
//

import Combine
import SwiftUI

struct CarouselView: View {
    
    let characters: [CharacterResponse]
    let autoScrollInterval: TimeInterval

    @State private var currentIndex = 0

    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    init(characters: [CharacterResponse], autoScrollInterval: TimeInterval = 4) {
        self.characters = characters
        self.autoScrollInterval = autoScrollInterval
        self.timer = Timer
            .publish(
                every: autoScrollInterval,
                on: .main,
                in: .common
            ).autoconnect()
    }

    var body: some View {
        Group {
            if characters.isEmpty {
                EmptyView()
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                        CarouselCard(character: character)
                            .tag(index)
                            .padding(.horizontal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top)
                .onReceive(timer) { _ in
                    guard characters.count > 1 else { return }
                    withAnimation(.easeInOut(duration: 0.45)) {
                        currentIndex = (currentIndex + 1) % characters.count
                    }
                }
                .onChange(of: characters) { oldValue, newValue in
                    guard !newValue.isEmpty else {
                        currentIndex = 0
                        return
                    }
                    currentIndex = min(currentIndex, newValue.count - 1)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("carousel_view")
            }
        }
    }
}

private struct CarouselCard: View {
    
    let character: CharacterResponse

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.quinary)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.quinary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 220)
            .clipped()

            LinearGradient(
                colors: [.black.opacity(0.7), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 90)
            .frame(maxWidth: .infinity, alignment: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                if let species = character.species, !species.isEmpty {
                    Text(species)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(16)
        }
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//        .shadow(radius: 4, y: 2)
    }
}

extension CarouselView {
    struct PreviewData {
        static let characters: [CharacterResponse] = [
            CharacterResponse(id: 1, name: "Rick Sanchez", species: "Human", image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")),
            CharacterResponse(id: 2, name: "Morty Smith", species: "Human", image: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")),
            CharacterResponse(id: 3, name: "Summer Smith", species: "Human", image: URL(string: "https://rickandmortyapi.com/api/character/avatar/3.jpeg"))
        ]
    }
}

#Preview {
    CarouselView(characters: CarouselView.PreviewData.characters)
        .padding()
        .background(Color(uiColor: .systemBackground))
}

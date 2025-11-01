//
//  FeedBuilder.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import SwiftUI

@Observable
final class FeedBuilder {
    func buildFeedView(usingMock: Bool = false) -> some View {
        let feedRepository: FeedRepositoryProtocol
        if usingMock {
            feedRepository = MockFeedRepository()
        } else {
            let networkService = NetworkService(session: .shared)
            feedRepository = FeedRepository(
                networkServiceProtocol: networkService
            )
        }
        let feedUseCase = FeedUseCase(feedRepository: feedRepository)
        let viewModel = FeedViewModel(feedUseCase: feedUseCase)
        return FeedView(viewModel: viewModel)
    }
}

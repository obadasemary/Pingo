//
//  PingoApp.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import SwiftUI

@main
struct PingoApp: App {
    @State private var feedBuilder = FeedBuilder()

    var body: some Scene {
        WindowGroup {
            feedBuilder.buildFeedView()
        }
    }
}

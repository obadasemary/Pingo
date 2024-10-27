//
//  PingoApp.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import SwiftUI

@main
struct PingoApp: App {
    var body: some Scene {
        WindowGroup {
            let feedBuilder = FeedBuilder()
            feedBuilder.buildFeedView()
        }
    }
}

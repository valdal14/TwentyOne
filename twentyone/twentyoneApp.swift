//
//  twentyoneApp.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import SwiftUI

@main
struct twentyoneApp: App {
	@StateObject var deckVM: DeckViewModel = DeckViewModel(networkService: NetworkService())
	
    var body: some Scene {
        WindowGroup {
            TwentyOne()
				.environmentObject(deckVM)
        }
    }
}

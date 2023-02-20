//
//  Players.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 20/2/23.
//

import Foundation

protocol Players: Sendable {
	func getHandCount() async -> Int
	func setHandCount(_ handCount: Int) async
	func getBusted() async -> Bool
	func setGetBusted(_ value: Bool) async
}

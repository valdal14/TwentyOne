//
//  PlayerViewModel.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import Foundation

actor PlayerViewModel: ObservableObject, Players {
	
	@Published private(set) var _handCount: Int = 0
	@Published private(set) var _gotBusted: Bool = false
	@Published private(set) var current: Player = Player(money: 1400, currentHand: 0)
	
	func getHandCount() async -> Int {
		return _handCount
	}
	
	func setHandCount(_ handCount: Int) async {
		_handCount += handCount
	}
	
	func getBusted() async -> Bool {
		return _gotBusted
	}
	
	func setGetBusted(_ value: Bool) async {
		_gotBusted = value
	}
	
	func getCurrentPlayer() -> Player {
		return current
	}
	
	func bet(amount: Double) -> Bool {
		if amount > current.money {
			return false
		} else {
			current.money -= amount
			return true
		}
	}
	
	func getMoney() async -> Double {
		return current.money
	}
	
	func addMoney(_ value: Double) async {
		current.money += value
	}
	
	func withdrawMoney(_ value: Double) async {
		current.money -= value
	}
}

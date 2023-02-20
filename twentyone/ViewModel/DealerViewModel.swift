//
//  DealerViewModel.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import Foundation

actor DealerViewModel: ObservableObject, Players {
	@Published private(set) var _handCount: Int = 0
	@Published private(set) var _gotBusted: Bool = false
	@Published private(set) var current: Dealer = Dealer(money: 5000, currentHand: 0)
	
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
	
	func getCurrentDealer() -> Dealer {
		return current
	}
}

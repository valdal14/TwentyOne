//
//  DeckViewModel.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import Foundation

enum AceValue: Int {
	case one = 1
	case eleven = 11
}

enum GameError: String, Error {
	case insufficientFound = "You cannot bet more than you own"
}

actor DeckViewModel: ObservableObject {
	private let networkService: NetworkService
	
	@Published private(set) var dealer = DealerViewModel()
	@Published private(set) var player = PlayerViewModel()
	@Published private(set) var gameDeck: [GameCard] = []
	@Published private(set) var dealerPlayedCards: [GameCard] = []
	@Published private(set) var playerPlayedCards: [GameCard] = []
	@Published private(set) var ace: Int = 0
	@Published private(set) var busted: Bool = false
	@Published private(set) var wasBlackJackDone: Bool = false
	@Published private(set) var showError: Bool = false
	private let maxHandCount: Int = 21
	private(set) var deck: [Card] = []
	
	init(networkService: NetworkService){
		self.networkService = networkService
	}
	
	/// Get cards from NetworkService and populate the cards mutable variable
	func buildDeck(isTest: Bool) async throws {
		if isTest {
			deck = try await networkService.getCards(isTest: isTest)
		} else {
			deck = try await networkService.getCards(isTest: isTest)
		}
	}
	
	/// Compute the mutable property ace based on the mutable property handCount
	///
	/// parameters - cardValue: String
	func computeAce<T: Players>(cardValue: String, player: T) async {
		let playerHandCount = await player.getHandCount()
		if cardValue == "ACE" && playerHandCount <= 10 {
			ace = 11
		} else {
			ace = 1
		}
	}
	
	/// Given a cardValue in String returns its game value in Int
	///
	/// returns: - Int
	func computeCardValue(cardValue: String) -> Int {
		if cardValue == "QUEEN" || cardValue == "JACK" || cardValue == "KING" {
			return 10
		} else if cardValue == "ACE" {
			return 1
		} else {
			return Int(cardValue) ?? 0
		}
	}
	
	/// Generate the in-game deck
	func generateDeck() {
		for card in deck {
			gameDeck.append(GameCard(url: card.url, value: computeCardValue(cardValue: card.value)))
		}
	}
	
	/// Return the gameDeck
	///
	/// returns: - [GameCard]
	func getGeneratedInGameDeck() -> [GameCard] {
		return gameDeck
	}
	
	/// Returns the value of the current ace
	///
	/// returns: - Int
	func getCurrentAceValue() -> Int {
		return self.ace
	}
	
	/// change the internal state of the mutable variable handCount for the given player or dealer
	func setHandCount<T: Players>(cardValue: Int, player: T) async {
		if await player.getHandCount() + cardValue <= self.maxHandCount {
			await player.setHandCount(cardValue)
		} else {
			await player.setGetBusted(true)
		}
	}
	
	/// Shuffle the current deck
	func shuffleDeck() {
		deck.shuffle()
	}
	
	/// Return a tuple made of Dealer and Player cards hande
	///
	/// parameters: - player: T, dealder: K
	func playFirstHand<T: Players, K: Players>(player: T, dealder: K) async {
		/// dealer first card
		let dealerIndex = Int.random(in: 0..<gameDeck.count)
		let delearCard = gameDeck.remove(at: dealerIndex)
		/// player first card
		let playerIndex = Int.random(in: 0..<gameDeck.count)
		let playerCard = gameDeck.remove(at: playerIndex)
		/// dealer second card
		let dealerIndexTwo = Int.random(in: 0..<gameDeck.count)
		let delearCardTwo = gameDeck.remove(at: dealerIndexTwo)
		/// player first card
		let playerIndexTwo = Int.random(in: 0..<gameDeck.count)
		let playerCardTwo = gameDeck.remove(at: playerIndexTwo)
		
		dealerPlayedCards.append(delearCard)
		dealerPlayedCards.append(delearCardTwo)
		
		playerPlayedCards.append(playerCard)
		playerPlayedCards.append(playerCardTwo)
		
		for (index, aces) in dealerPlayedCards.enumerated() {
			if aces.value == 1 {
				await computeAce(cardValue: "ACE", player: dealder)
				dealerPlayedCards[index].value = ace
			}
		}
		
		for (index, aces) in playerPlayedCards.enumerated() {
			if aces.value == 1 {
				await computeAce(cardValue: "ACE", player: player)
				playerPlayedCards[index].value = ace
			}
		}
		
		for card in dealerPlayedCards {
			await dealder.setHandCount(card.value)
		}
		
		
		for card in playerPlayedCards {
			await player.setHandCount(card.value)
		}
	}
	
	/// Return the player objejct
	///
	/// returns: - Player
	func getPlayer() async -> PlayerViewModel {
		return player
	}
	
	/// Return the dealer objejct
	///
	/// returns: - Dealer
	func getDealer() async -> DealerViewModel {
		return dealer
	}
	
	/// Iterate over the cards to check whether a blackjack was done
	/// and return either true or false
	///
	/// parameters: - cards: [GameCard]
	///
	/// returns: - Bool
	func checkForBlackJack(cards: [GameCard]) -> Bool {
		var blackjackCounter: Int = 0
		for card in cards {
			for deckCard in deck {
				if card.url == deckCard.url && deckCard.value == "ACE" {
					blackjackCounter += ace
				}
				
				if card.url == deckCard.url && deckCard.value == "JACK" {
					blackjackCounter += card.value
				}
			}
		}
		
		if blackjackCounter == 21 {
			wasBlackJackDone = true
		}
		
		return blackjackCounter == 21 ? true : false
	}
	
	/// Returns whether the blackjack was done
	///
	/// returns: - Bool
	func returnIfWeHitBlackJack() -> Bool {
		return wasBlackJackDone
	}
	
	/// Draw a new card from the gameDeck and add its value to the
	/// player or dealer current count
	///
	/// parameters: - currentPlayer: T
	func drawNewCard<T: Players>(currentPlayer: T) async {
		let index = Int.random(in: 0..<gameDeck.count)
		let playerCard = gameDeck.remove(at: index)
		
		if type(of: currentPlayer) == type(of: player) {
			if playerCard.value == 1 {
				await computeAce(cardValue: "ACE", player: currentPlayer)
				let newAce = GameCard(url: playerCard.url, value: ace)
				playerPlayedCards.append(newAce)
				await player.setHandCount(playerCard.value)
			} else {
				playerPlayedCards.append(playerCard)
				await player.setHandCount(playerCard.value)
			}
		} else {
			if playerCard.value == 1 {
				await computeAce(cardValue: "ACE", player: currentPlayer)
				let newAce = GameCard(url: playerCard.url, value: ace)
				dealerPlayedCards.append(newAce)
				await dealer.setHandCount(playerCard.value)
			} else {
				dealerPlayedCards.append(playerCard)
				await dealer.setHandCount(playerCard.value)
			}
		}
	}
	
	/// Returns the dealer current hand
	///
	/// returns: - [GameCard]
	func getDealerPlayedCards() -> [GameCard] {
		return dealerPlayedCards
	}
	
	/// Returns the player current hand
	///
	/// returns: - [GameCard]
	func getPlayerPlayedCards() -> [GameCard] {
		return playerPlayedCards
	}
}

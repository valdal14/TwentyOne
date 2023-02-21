//
//  TwentyOne.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import SwiftUI

struct TwentyOne: View {
	@EnvironmentObject var deckVM: DeckViewModel
	
	@State private var colums : [GridItem] = [GridItem(.fixed(90), spacing: 3, alignment: .center),
											  GridItem(.fixed(90), spacing: 3, alignment: .center),
											  GridItem(.fixed(90), spacing: 3, alignment: .center),
											  GridItem(.fixed(90), spacing: 3, alignment: .center)]
	
	@State private var showNetworkError: Bool = false
	@State private var playerHand: [GameCard] = []
	@State private var dealerHand: [GameCard] = []
	@State private var dealerBalance: Double = 0
	@State private var playerBalance: Double = 0
	@State private var playerCurrentScore: Int = 0
	@State private var counter: Int = 0
	@State private var round: Int = 1
	
	var body: some View {
		ZStack {
			GeometryReader { proxy in
				Image("table")
					.resizable()
					.scaledToFit()
					.frame(width: proxy.size.width, height: proxy.size.height)
			}
			VStack(alignment: .center) {
				DealerHeadeView(total: $dealerBalance, round: $round)
				LazyVGrid(columns: colums, alignment: .center, spacing: 10) {
					ForEach(deckVM.dealerPlayedCards, id: \.url) { card in
						GameCardView(cardURL: Binding<URL>(
							get: { card.url }, set: {_ in }), cardValue: Binding<Int>(
								get: { card.value }, set: { _ in }), isFaceUp: card.isFaceUP)
					}
				}
				Spacer()
				LazyVGrid(columns: colums, alignment: .center, spacing: 10) {
					ForEach(deckVM.playerPlayedCards, id: \.url) { card in
						GameCardView(cardURL: Binding<URL>(
							get: { card.url }, set: {_ in }), cardValue: Binding<Int>(
								get: { card.value }, set: { _ in }), isFaceUp: card.isFaceUP)
					}
				}
				Spacer()
				PlayerHeaderView(totalMoney: $playerBalance, currentScore: $playerCurrentScore)
			}
			.padding()
		}
		.alert("Player Won Hand", isPresented: $deckVM.playerWon) {
			Button("OK", role: .cancel) { }
		}
		.alert("Dealer Won Hand", isPresented: $deckVM.dealerWon) {
			Button("OK", role: .cancel) { }
		}
		.onAppear {
			Task {
				do {
					/// get cards from api
					try await deckVM.buildDeck(isTest: false)
					/// generate in-game deck
					deckVM.generateDeck()
					/// setup the first hand
					await deckVM.playFirstHand(player: deckVM.getPlayer(), dealder: deckVM.getDealer())
					/// get dealer first hand
					dealerHand = deckVM.getDealerPlayedCards()
					/// get player first hand
					playerHand = deckVM.getPlayerPlayedCards()
					/// get player and dealer balance
					playerBalance = await deckVM.getPlayer().getMoney()
					dealerBalance = await deckVM.getDealer().getMoney()
					/// get player current score
					playerCurrentScore = await deckVM.getPlayer().getHandCount()
					print(await deckVM.getDealer().getHandCount())
				} catch let error as NetworkService.NetworkManagerError {
					print(error)
					showNetworkError = true
				}
			}
		}
		.onChange(of: playerBalance, perform: { _ in
			Task {
				dealerBalance = await deckVM.dealer.getMoney()
			}
		})
		.edgesIgnoringSafeArea(.all)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		TwentyOne()
	}
}

//
//  GameCardView.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 20/2/23.
//

import SwiftUI

struct GameCardView: View {
	@EnvironmentObject var deckVM: DeckViewModel
	@Binding var cardURL: URL
	@Binding var cardValue: Int
	@State var isFaceUp : Bool
	@State var degree : Double = 0
	var cardW : CGFloat = 90.0
	var cardH : CGFloat = 110
	
	var body: some View {
		ZStack {
			AsyncImage(url: cardURL) { image in
				if isFaceUp {
					withAnimation(.linear(duration: 2)) {
						image
							.resizable()
							.scaledToFill()
							.frame(width: cardW, height: cardH)
					}
				} else {
					withAnimation(.linear(duration: 0.5)) {
						Image("cardBack")
							.resizable()
							.scaledToFill()
							.frame(width: cardW, height: cardH)
					}
				}
			} placeholder: {
				withAnimation(.linear(duration: 0.5)) {
					Image("cardBack")
						.resizable()
						.scaledToFill()
						.frame(width: cardW, height: cardH)
				}
			}
		}
		.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
	}
}

struct GameCardView_Previews: PreviewProvider {
	@State static var cardURL: URL = URL(string: "https://deckofcardsapi.com/static/img/2C.png")!
	@State static var cardValue: Int = 10
	@State static var isFaceUP: Bool = true
	static var previews: some View {
		GameCardView(cardURL: $cardURL, cardValue: $cardValue, isFaceUp: true)
	}
}

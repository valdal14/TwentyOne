//
//  DealerHeadeView.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 20/2/23.
//

import SwiftUI

struct DealerHeadeView: View {
	@EnvironmentObject var deckVM: DeckViewModel
	
	@Binding var total: Double
	@Binding var round: Int
	
    var body: some View {
		HStack {
			Image("dealerFishes")
				.resizable()
				.scaledToFit()
				.frame(width: 50, height: 50)
			Text(String(format: "%.1f", total))
				.font(.title)
				.fontWeight(.bold)
				.foregroundColor(.white)
			Spacer()
			Text("dealer")
				.font(.title)
				.fontWeight(.bold)
				.foregroundColor(.white)
		}
		.padding()
		Spacer()
		HStack {
			Spacer()
			Image(round <= 3 ? "Deck-2" : "Deck-0")
				.resizable()
				.scaledToFit()
				.frame(width: 150, height: 150)
			Spacer()
		}
		Spacer()
    }
}

struct DealerHeadeView_Previews: PreviewProvider {
	@State static var total: Double = 5000
	@State static var round: Int = 1
    static var previews: some View {
		DealerHeadeView(total: $total, round: $round)
    }
}

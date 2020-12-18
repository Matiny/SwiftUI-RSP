//
//  ContentView.swift
//  SwiftUI RSPGame
//
//  Created by Matiny L on 12/8/20.
//

import SwiftUI

/* Model */
struct RSPGame {
    enum Choice: String, CaseIterable {
        case rock = "✊🏽", scissors = "✌🏽", paper = "👋🏽"
        
        static var winningMoves: [Choice:Choice] {
            [
                .rock : .scissors,
                .paper : .rock,
                .scissors : .paper
            ]
        }
    }
    
    enum Player {
        case one, two
    }
    
    enum Result {
        case win, loss, draw
    }
    
    let choices = Choice.allCases
    
    var activePlayer = Player.one
    
    /* Ternary to keep the current player set */
    
    var playerChoices: (first: Choice?, second: Choice?) = (nil, nil) {
        didSet {
            activePlayer = (playerChoices.first != nil && activePlayer == .one) ? .two : .one
        }
    }
    
    var isGameOver: Bool {
        playerChoices.first != nil && playerChoices.second != nil
    }
    
    var winner: Player? = nil
    
    func evaluateResult() -> Result? {
        guard let choiceOne = playerChoices.first, let choiceTwo = playerChoices.second else {return nil}
        
        /* Draw */
        
        if choiceOne == choiceTwo {
            return .draw
        }
        
        if let choiceToWin = Choice.winningMoves[choiceOne], choiceTwo == choiceToWin {
            return .win
        }
        
        return .loss
    }
        
}

/* ViewModel, where we transform the data and allow user choices  */

// ObservableObject keeps the view synced with the ViewModel

final class RSPGameViewModel: ObservableObject {
    // When the model gets updated, the view will change
    @Published private var model = RSPGame()
    
    func getAllowedChoices(forPlayer player: RSPGame.Player) -> [RSPGame.Choice] {
        if model.activePlayer == player && !model.isGameOver {
            return model.choices
        }
        return []
    }
    
    func getStatusText(forPlayer player: RSPGame.Player) -> String {
        if !model.isGameOver {
            return model.activePlayer == player ? "" : "..."
        }
        if let result = model.evaluateResult() {
            switch result {
            case .win:
                return player == .one ? "You Win!" : "You Lose!"
                
            case .loss:
                return player == .one ? "You Lose!" : "You Win!"
            
            case .draw:
                return "Draw!"
            }
        }
        return "Undefined State"
    }
    
    func getFinalMove(forPlayer player: RSPGame.Player) -> String {
        if model.isGameOver {
            switch player {
            case .one:
                return model.playerChoices.first?.rawValue ?? ""
            case .two:
                return model.playerChoices.second?.rawValue ?? ""
            }
        }
         return ""
    }
    
    func isGameOver() -> Bool {
        model.isGameOver
    }
    
    func choose(_ theChoice: RSPGame.Choice, forPlayer player: RSPGame.Player) {
        print("Player \(player) chose \(theChoice.rawValue)")
        if player == .one {
            model.playerChoices.first = theChoice
        } else {
            model.playerChoices.second = theChoice
        }
    }
    
    func resetGame() {
        model.activePlayer = .one
        model.playerChoices = (nil, nil)
        model.winner = nil
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = RSPGameViewModel()
    var body: some View {
        VStack {
            ZStack {
                Color.purple
                VStack {
                    Text("Player 2")
                    Spacer()
                    Text(viewModel.getFinalMove(forPlayer: .two))
                    Spacer()
                    Text(viewModel.getStatusText(forPlayer: .two))
                    HStack {
                        ForEach(viewModel.getAllowedChoices(forPlayer: .two),id: \.self) { choice in
                            Button(action: {
                                self.viewModel.choose(choice, forPlayer: .two)
                            }, label: {
                                Spacer()
                                Text(choice.rawValue)
                                Spacer()
                            })
                        }
                    }
                }.padding(.bottom, 40)
            }.rotationEffect(.init(degrees: 180))
            // TODO: Retry Button
            
            if viewModel.isGameOver() {
                Button(action: {
                    self.viewModel.resetGame()
                }, label: {
                    Text("Retry 🔄")
                        .foregroundColor(.blue)
                        .font(.custom("AvenirNext-UltraLight-Bold", size: 30))
                })
            }
            ZStack {
                Color.blue
                VStack {
                    Text("Player 1")
                    Spacer()
                    Text(viewModel.getFinalMove(forPlayer: .one))
                    Spacer()
                    Text(viewModel.getStatusText(forPlayer: .one))
                    HStack {
                        ForEach(viewModel.getAllowedChoices(forPlayer: .one),id: \.self) { choice in
                            Button(action: {
                                self.viewModel.choose(choice, forPlayer: .one)
                            }, label: {
                                Spacer()
                                Text(choice.rawValue)
                                Spacer()
                            })
                        }
                    }
                }.padding(.bottom, 40)
            }
        }
        .foregroundColor(.white)
        .font(
            .custom("AvenirNext-UltraLight", size: 80)
        )
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

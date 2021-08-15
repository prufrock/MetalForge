//
//  ContentView.swift
//  Shared
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI
import ViewModel

struct ContentView: View {
    @ObservedObject var window: VMDLMatrixWindow

    @State private var vector: [[String]] = [["0.0", "0.0", "0.0", "0.0"]]

    @State private var vectorFunction: [[String]] = [
        ["1.0", "0.0", "0.0", "0.0"],
        ["0.0", "1.0", "0.0", "0.0"],
        ["0.0", "0.0", "1.0", "1.0"],
        ["0.0", "0.0", "0.0", "1.0"]
    ]

    @State private var showingMatrixInput = false

    @State private var inputMatrix = ""

    @State private var showingVectorInput = false

    @State private var inputVector = ""

    init(window: VMDLMatrixWindow) {
        self.window = window
    }

    var body: some View {
        HStack{
            VStack {
                Group{
                    Matrix(matrix: $vectorFunction)
                    BtnInputMatrix(inputMatrix: $inputMatrix)
                }
            }.padding(10)
            VStack {
                Button(action: { window.computeDotProduct() }) {
                    Image(systemName: "circle")
                        .renderingMode(.original)
                }.buttonStyle(DefaultButtonStyle())
                Button(action: {
                    window.undoLastDotProduct()
                }) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .renderingMode(.original)
                }.buttonStyle(DefaultButtonStyle())
                .disabled(window.getUndoButton().isDisabled())
                Button(action: {  }) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .renderingMode(.original)
                }.buttonStyle(DefaultButtonStyle())
            }
            VStack{
                MatrixElements(matrix: $vector, column: 0)
                BtnInputMatrix(inputMatrix: $inputVector)
            }.padding(10)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(window: VMDLMatrixWindow(
                id: UUID(),
                undoButton: VMDLButton(id: UUID(), disabled: true),
                dotProductButton: VMDLButton(id: UUID(), disabled: true),
                commands: []
        ))
    }
}

//
//  ContentView.swift
//  Shared
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI
import ViewModel

struct ContentView: View {
    @ObservedObject var app: VMDLMatrixWindow

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

    init(app: VMDLMatrixWindow) {
        self.app = app
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
                Button(action: { app.computeDotProduct() }) {
                    Image(systemName: "circle")
                        .renderingMode(.original)
                }.buttonStyle(DefaultButtonStyle())
                Button(action: {
                    app.undoLastDotProduct()
                }) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .renderingMode(.original)
                }.buttonStyle(DefaultButtonStyle())
                .disabled(app.getUndoButton().isDisabled())
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
        ContentView(app: ViewModel.application(id: UUID(uuidString: "4e6ecfae-9e8d-4464-ba48-976e7f8ed413")!) {
            $0.undoButton(
                VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true)
            )
        }.create())
    }
}

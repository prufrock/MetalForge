//
//  ContentView.swift
//  Shared
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI
import ViewModel

struct ContentView: View {
    @State var app: Application

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

    var body: some View {
        HStack{
            VStack {
                Group{
                    Matrix(matrix: $vectorFunction)
                    BtnInputMatrix(inputMatrix: $inputMatrix)
                }
            }.padding(10)
            VStack {
                Button(action: { app = app.setElement(i: 0, element: app.getElement(i: 0).toggle()) }) {
                    Image(systemName: "circle")
                        .renderingMode(.original)
                }.buttonStyle(DefaultButtonStyle())
                Button(action: {
                    1 + 1
                }) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .renderingMode(.original)
                }.buttonStyle(DefaultButtonStyle())
                .disabled(app.getElement(i: 0).isDisabled())
                Button(action: { 1 + 1 }) {
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
        ContentView(app: Application(id: UUID(uuidString: "4e6ecfae-9e8d-4464-ba48-976e7f8ed413")!) {
            Button(id: UUID(uuidString: "6101a91c-1ebe-47ca-9744-d342e51e96d1")!, disabled: true)
        })
    }
}

//
//  ContentView.swift
//  Shared
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI

struct ContentView: View {
    @State private var vector: [[String]] = [["0.0", "0.0", "0.0", "0.0"]]

    @State private var vectorFunction: [[String]] = [
        ["1.0", "0.0", "0.0", "0.0"],
        ["0.0", "1.0", "0.0", "0.0"],
        ["0.0", "0.0", "1.0", "1.0"],
        ["0.0", "0.0", "0.0", "1.0"]
    ]

    var body: some View {
        HStack{
            VStack{
                HStack{
                    MatrixElement(matrix: $vectorFunction, index: [0,0])
                    MatrixElement(matrix: $vectorFunction, index: [0,1])
                    MatrixElement(matrix: $vectorFunction, index: [0,2])
                    MatrixElement(matrix: $vectorFunction, index: [0,3])
                }
                HStack {
                    MatrixElement(matrix: $vectorFunction, index: [1,0])
                    MatrixElement(matrix: $vectorFunction, index: [1,1])
                    MatrixElement(matrix: $vectorFunction, index: [1,2])
                    MatrixElement(matrix: $vectorFunction, index: [1,3])
                }
                HStack {
                    MatrixElement(matrix: $vectorFunction, index: [2,0])
                    MatrixElement(matrix: $vectorFunction, index: [2,1])
                    MatrixElement(matrix: $vectorFunction, index: [2,2])
                    MatrixElement(matrix: $vectorFunction, index: [2,3])
                }
                HStack {
                    MatrixElement(matrix: $vectorFunction, index: [3,0])
                    MatrixElement(matrix: $vectorFunction, index: [3,1])
                    MatrixElement(matrix: $vectorFunction, index: [3,2])
                    MatrixElement(matrix: $vectorFunction, index: [3,3])
                }
            }.padding(10)
            VStack{
                MatrixElement(matrix: $vector, index: [0])
                MatrixElement(matrix: $vector, index: [1])
                MatrixElement(matrix: $vector, index: [2])
                MatrixElement(matrix: $vector, index: [3])
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

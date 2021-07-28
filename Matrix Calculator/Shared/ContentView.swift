//
//  ContentView.swift
//  Shared
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI

struct ContentView: View {
    @State private var vector: [String] = ["0.0", "0.0", "0.0", "0.0"]

    var body: some View {
        VStack{
            MatrixElement(matrix: $vector, index: 0)
            MatrixElement(matrix: $vector, index: 1)
            MatrixElement(matrix: $vector, index: 2)
            MatrixElement(matrix: $vector, index: 3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

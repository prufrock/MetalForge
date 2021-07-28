//
//  ContentView.swift
//  Shared
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI

struct ContentView: View {
    @State private var vOneOne: String = "0.0"

    var body: some View {
        VStack{
            MatrixElement(value: $vOneOne)
            MatrixElement(value: $vOneOne)
            MatrixElement(value: $vOneOne)
            MatrixElement(value: $vOneOne)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

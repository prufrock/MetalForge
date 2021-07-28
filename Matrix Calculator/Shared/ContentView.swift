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
            TextField("", text: $vOneOne)
                .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            TextField("", text: $vOneOne)
                .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            TextField("", text: $vOneOne)
               .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            TextField("", text: $vOneOne)
                .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

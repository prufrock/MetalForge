//
//  MatrixElement.swift
//  Matrix Calculator
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI

struct MatrixElement: View {
    @Binding var value: String

    var body: some View {
        TextField("", text: $value)
            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct MatrixElement_Previews: PreviewProvider {
    static var previews: some View {
        MatrixElement(value: .constant("0.0"))
    }
}

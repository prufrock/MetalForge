//
//  MatrixElement.swift
//  Matrix Calculator
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI

struct MatrixElement: View {
    @Binding var matrix: [String]
    var index: Int

    var body: some View {
        TextField("", text: $matrix[index])
            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct MatrixElement_Previews: PreviewProvider {
    static var previews: some View {
        MatrixElement(matrix: .constant(["0.0"]), index: 0)
    }
}

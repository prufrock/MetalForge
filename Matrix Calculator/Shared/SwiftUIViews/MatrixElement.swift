//
//  MatrixElement.swift
//  Matrix Calculator
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI

struct MatrixElement: View {
    @Binding var matrix: [[String]]
    var index: [Int]

    var body: some View {
        TextField("", text: element())
            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }

    func element() -> Binding<String> {
        if index.count == 1 {
            return $matrix[0][index[0]]
        } else if index.count == 2 {
            return $matrix[index[0]][index[1]]
        } else {
            fatalError("What!? This wasn't supposed to be an index size: " + String(index.count))
        }
    }
}

struct MatrixElement_Previews: PreviewProvider {
    static var previews: some View {
        MatrixElement(matrix: .constant([["0.0"]]), index: [0])
    }
}

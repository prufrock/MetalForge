//
//  Vector.swift
//  Matrix Calculator
//
//  Created by David Kanenwisher on 7/28/21.
//

import SwiftUI

struct MatrixElements: View {
    @Binding var matrix: [[String]]
    let column: Int

    var body: some View {
        Group {
            MatrixElement(matrix: $matrix, index: [column,0])
            MatrixElement(matrix: $matrix, index: [column,1])
            MatrixElement(matrix: $matrix, index: [column,2])
            MatrixElement(matrix: $matrix, index: [column,3])
        }
    }
}

struct Vector_Previews: PreviewProvider {
    static var previews: some View {
        MatrixElements(matrix: .constant([["0.0", "0.0", "0.0", "0.0"]]), column: 0)
    }
}

//
//  Matrix.swift
//  Matrix Calculator
//
//  Created by David Kanenwisher on 7/28/21.
//

import SwiftUI

struct Matrix: View {
    @Binding var matrix: [[String]]

    var body: some View {
        Group{
            HStack{
                MatrixElements(matrix: $matrix, column: 0)
            }
            HStack{
                MatrixElements(matrix: $matrix, column: 1)
            }
            HStack{
                MatrixElements(matrix: $matrix, column: 2)
            }
            HStack{
                MatrixElements(matrix: $matrix, column: 3)
            }
        }
    }
}

struct Matrix_Previews: PreviewProvider {
    static var previews: some View {
        Matrix(matrix: .constant([
            ["1.0", "0.0", "0.0", "0.0"],
            ["0.0", "1.0", "0.0", "0.0"],
            ["0.0", "0.0", "1.0", "1.0"],
            ["0.0", "0.0", "0.0", "1.0"]
        ]))
    }
}

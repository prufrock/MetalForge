//
//  EnterLineMatrix.swift
//  Matrix Calculator
//
//  Created by David Kanenwisher on 7/29/21.
//

import SwiftUI

struct EnterLineMatrix: View {
    @Binding var isShowing: Bool
    @Binding var value: String

    var body: some View {
        VStack {
        Button("[]") {
            isShowing = false
        }
        .padding()
        TextField("", text: $value)
        }
    }
}

struct EnterLineMatrix_Previews: PreviewProvider {
    static var previews: some View {
        EnterLineMatrix(isShowing: .constant(true), value: .constant(""))
    }
}

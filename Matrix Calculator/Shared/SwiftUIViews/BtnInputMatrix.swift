//
//  BtnInputMatrix.swift
//  Matrix Calculator
//
//  Created by David Kanenwisher on 7/31/21.
//

import SwiftUI

struct BtnInputMatrix: View {
    @State private var showingMatrixInput = false

    @Binding var inputMatrix: String

    var body: some View {
        Button(action: { showingMatrixInput.toggle() }) {
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                .renderingMode(.original)
        }.buttonStyle(DefaultButtonStyle())
        .sheet(isPresented: $showingMatrixInput) {
            EnterLineMatrix(isShowing: $showingMatrixInput, value: $inputMatrix)
        }
    }
}

struct BtnInputMatrix_Previews: PreviewProvider {
    static var previews: some View {
        BtnInputMatrix(inputMatrix: .constant(""))
    }
}

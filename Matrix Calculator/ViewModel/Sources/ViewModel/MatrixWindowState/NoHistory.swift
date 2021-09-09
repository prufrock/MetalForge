//
//  File.swift
//  
//
//  Created by David Kanenwisher on 8/19/21.
//

import Foundation

@available(macOS 10.15, *)
extension VMDLMatrixWindow {
    struct NoHistory: MatrixWindowState {
        public let id: UUID
        public let undoButton: VMDLButton
        public let redoButton: VMDLButton
        public let dotProductButton: VMDLButton
        public let commands: [String]
        public let vectorState: VMDLMatrixWindow.VectorStates

        func computeDotProduct() -> MatrixWindowState {
            HasHistory(
                    id: id,
                    undoButton: undoButton.enable(),
                    redoButton: redoButton.disable(),
                    dotProductButton: dotProductButton,
                    commands: commands + [UUID().uuidString],
                    vectorState: vectorState
            )
        }

        func undoLastDotProduct() -> MatrixWindowState {
            print("NoHistory: do nothing")
            return self
        }

        private func updateDotProductButton() -> VMDLButton {
            let newDotProductButton: VMDLButton
            switch vectorState {
            case .InvalidVector:
                newDotProductButton = dotProductButton.disable()
            case .ValidVector:
                newDotProductButton = dotProductButton.enable()
            }

            return newDotProductButton
        }
    }
}

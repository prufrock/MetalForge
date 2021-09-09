//
//  File.swift
//  
//
//  Created by David Kanenwisher on 8/19/21.
//

import Foundation

@available(macOS 10.15, *)
extension VMDLMatrixWindow {
    struct HasHistory: MatrixWindowState {
        public let id: UUID
        public let undoButton: VMDLButton
        public let redoButton: VMDLButton
        public let dotProductButton: VMDLButton
        public let commands: [String]
        public let vectorState: VMDLMatrixWindow.VectorStates

        func computeDotProduct() -> MatrixWindowState {

            HasHistory(id: id,
                    undoButton: undoButton.enable(),
                    redoButton: redoButton.disable(),
                    dotProductButton: updateDotProductButton(),
                    commands: commands + [UUID().uuidString],
                    vectorState: vectorState
            )
        }

        func undoLastDotProduct() -> MatrixWindowState {

            if (commands.count == 1) {
                print("HasHistory: remove last")
                return clone(
                        undoButton: self.undoButton.disable(),
                        commands: [],
                        vectorState: vectorState
                )
            } else {
                print("HasHistory: an item")
                return HasHistory(
                        id: id,
                        undoButton: self.undoButton,
                        redoButton: self.redoButton,
                        dotProductButton: updateDotProductButton(),
                        commands: commands.dropLast(),
                        vectorState: vectorState
                )
            }
        }

        private func updateDotProductButton() -> VMDLButton {
            // TODO it doesn't seem right that this is going to have to be duplicated.
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

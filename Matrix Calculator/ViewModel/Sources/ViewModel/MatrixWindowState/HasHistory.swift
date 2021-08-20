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

        func computeDotProduct() -> MatrixWindowState {
            HasHistory(id: id,
                    undoButton: undoButton.enable(),
                    redoButton: redoButton.disable(),
                    dotProductButton: dotProductButton,
                    commands: commands + [UUID().uuidString]
            )
        }

        func undoLastDotProduct() -> MatrixWindowState {

            if (commands.count == 1) {
                print("HasHistory: remove last")
                return clone(
                        undoButton: self.undoButton.disable(),
                        commands: []
                )
            } else {
                print("HasHistory: an item")
                return HasHistory(
                        id: id,
                        undoButton: self.undoButton,
                        redoButton: self.redoButton,
                        dotProductButton: dotProductButton,
                        commands: commands.dropLast()
                )
            }
        }

        func clone(
                id: UUID? = nil,
                undoButton: VMDLButton? = nil,
                redoButton: VMDLButton? = nil,
                dotProductButton: VMDLButton? = nil,
                commands: [String]? = nil
        ) -> MatrixWindowState {
            Self(
                id: id ?? self.id,
                undoButton: undoButton ?? self.undoButton,
                redoButton: redoButton ?? self.redoButton,
                dotProductButton: dotProductButton ?? self.dotProductButton,
                commands: commands ?? self.commands
            )
        }
    }
}

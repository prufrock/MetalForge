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
        public let dotProductButton: VMDLButton
        public let commands: [String]

        func computeDotProduct() -> MatrixWindowState {
            HasHistory(
                    id: id,
                    undoButton: undoButton.enable(),
                    dotProductButton: dotProductButton,
                    commands: commands + [UUID().uuidString]
            )
        }

        func undoLastDotProduct() -> MatrixWindowState {
            print("NoHistory: do nothing")
            return self
        }

        func clone(
                id: UUID? = nil,
                undoButton: VMDLButton? = nil,
                dotProductButton: VMDLButton? = nil,
                commands: [String]? = nil
        ) -> MatrixWindowState {
            Self(
                    id: id ?? self.id,
                    undoButton: undoButton ?? self.undoButton,
                    dotProductButton: dotProductButton ?? self.dotProductButton,
                    commands: commands ?? self.commands
            )
        }
    }
}

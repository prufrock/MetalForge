//
//  File.swift
//  
//
//  Created by David Kanenwisher on 8/19/21.
//

import Foundation

@available(macOS 10.15, *)
protocol MatrixWindowState {
    var id: UUID { get }
    var undoButton: VMDLButton { get }
    var redoButton: VMDLButton { get }
    var dotProductButton: VMDLButton { get }
    var commands: [String] { get }

    init(
        id: UUID,
        undoButton: VMDLButton,
        redoButton: VMDLButton,
        dotProductButton: VMDLButton,
        commands: [String]
    )

    func computeDotProduct() -> MatrixWindowState

    func undoLastDotProduct() -> MatrixWindowState

    func clone(
            id: UUID?,
            undoButton: VMDLButton?,
            redoButton: VMDLButton?,
            dotProductButton: VMDLButton?,
            commands: [String]?
    ) -> MatrixWindowState
}

extension MatrixWindowState {
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

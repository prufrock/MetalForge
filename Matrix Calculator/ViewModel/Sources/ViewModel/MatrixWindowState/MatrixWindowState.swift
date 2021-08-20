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

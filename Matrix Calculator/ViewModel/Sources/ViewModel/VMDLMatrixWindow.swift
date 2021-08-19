//
// Created by David Kanenwisher on 8/1/21.
//

import Foundation

/**
 Represents the entire application being presented.
 */
@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class VMDLMatrixWindow: ObservableObject {
    public let id: UUID
    public var undoButton: VMDLButton {
        get {
            state.undoButton
        }
    }
    private var dotProductButton: VMDLButton

    @Published private var state: MatrixWindowState

    public init(
            id: UUID,
            undoButton: VMDLButton,
            dotProductButton: VMDLButton,
            commands: [String] = []
    ) {
        self.id = id

        self.dotProductButton = dotProductButton

        if commands.count == 1 {
            self.state = VMDLMatrixWindow.HasHistory(
                id: id,
                undoButton: undoButton.enable(),
                dotProductButton: dotProductButton,
                commands: commands
            )
        } else {
            self.state = VMDLMatrixWindow.NoHistory(
                    id: id,
                    undoButton: undoButton.disable(),
                    dotProductButton: dotProductButton,
                    commands: commands.dropLast()
            )
        }
    }

    public func computeDotProduct() -> VMDLMatrixWindow {
        updateState(state: state.computeDotProduct())

        return self
    }

    public func undoLastDotProduct() -> VMDLMatrixWindow {
        updateState(state: state.undoLastDotProduct())

        return self
    }

    private func updateState(state: MatrixWindowState) {
        self.state = state
        self.dotProductButton = self.state.dotProductButton
    }

    public struct Builder {
        private var id: UUID
        private var elements: [VMDLButton] = []
        private var undoButton: VMDLButton?
        private var dotProductButton: VMDLButton?

        public init(id: UUID) {
            self.id = id
        }

        private init(
            id: UUID,
            undoButton: VMDLButton? = nil,
            dotProductButton: VMDLButton? = nil
        ) {
            self.id = id
            self.undoButton = undoButton
            self.dotProductButton = dotProductButton
        }

        public func undoButton(_ button:VMDLButton) -> Self {
            Self(id: id, undoButton: button)
        }

        public func dotProductButton(_ button:VMDLButton) -> Self {
            Self(
                id: id,
                undoButton: undoButton,
                dotProductButton: button
            )
        }

        public func create() -> VMDLMatrixWindow {
            VMDLMatrixWindow(
                id: id,
                undoButton: undoButton!,
                dotProductButton: dotProductButton!
            )
        }
    }

    @available(macOS 10.15, *)
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

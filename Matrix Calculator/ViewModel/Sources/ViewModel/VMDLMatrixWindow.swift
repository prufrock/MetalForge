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
    @Published private var undoButton: VMDLButton
    @Published private var dotProductButton: VMDLButton

    private var state: MatrixWindowState

    public init(
            id: UUID,
            undoButton: VMDLButton,
            dotProductButton: VMDLButton,
            commands: [String] = []
    ) {
        self.id = id
        self.undoButton = undoButton
        self.dotProductButton = dotProductButton
        self.state = VMDLMatrixWindow.NoHistory(
            id: id,
            undoButton: undoButton,
            dotProductButton: dotProductButton,
            commands: commands
        )
    }

    public func computeDotProduct() -> VMDLMatrixWindow {
        updateState(state: state.computeDotProduct())

        return self
    }

    public func undoLastDotProduct() -> VMDLMatrixWindow {
        updateState(state: state.undoLastDotProduct())

        return self
    }

    public func disableUndoButton() {
        undoButton = undoButton.disable()
    }

    public func enableUndoButton() {
        undoButton = undoButton.enable()
    }

    public func getUndoButton() -> VMDLButton { undoButton }

    private func updateState(state: MatrixWindowState) {
        self.state = state
        self.undoButton = self.state.undoButton
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
    }

    @available(macOS 10.15, *)
    struct HasHistory: MatrixWindowState {
        public let id: UUID
        public let undoButton: VMDLButton
        public let dotProductButton: VMDLButton
        public let commands: [String]

        func computeDotProduct() -> MatrixWindowState {
            HasHistory(id: id,
                    undoButton: undoButton.enable(),
                    dotProductButton: dotProductButton,
                    commands: commands + [UUID().uuidString]
            )
        }

        func undoLastDotProduct() -> MatrixWindowState {

            let undoButton: VMDLButton

            if (commands.count == 1) {
                print("HasHistory: remove last")

                undoButton = self.undoButton.disable()
                return VMDLMatrixWindow.NoHistory(
                        id: id,
                        undoButton: undoButton,
                        dotProductButton: dotProductButton,
                        commands: []
                )
            } else {
                print("HasHistory: an item")
                return HasHistory(
                        id: id,
                        undoButton: self.undoButton,
                        dotProductButton: dotProductButton,
                        commands: commands.dropLast()
                )
            }
        }
    }
}

@available(macOS 10.15, *)
protocol MatrixWindowState {
    var undoButton: VMDLButton { get }
    var dotProductButton: VMDLButton { get }

    func computeDotProduct() -> MatrixWindowState

    func undoLastDotProduct() -> MatrixWindowState

}

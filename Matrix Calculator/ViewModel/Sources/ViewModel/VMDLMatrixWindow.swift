//
// Created by David Kanenwisher on 8/1/21.
//

import Foundation
import MCLCModel
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
    public var redoButton: VMDLButton {
        get {
            state.redoButton
        }
    }
    private var dotProductButton: VMDLButton
    @Published public var vector: [[String]]

    public var model: MCLCModel

    @Published private var state: MatrixWindowState

    public init(
            id: UUID,
            undoButton: VMDLButton,
            redoButton: VMDLButton,
            dotProductButton: VMDLButton,
            commands: [String] = [],
            model: MCLCModel
    ) {
        self.id = id

        self.dotProductButton = dotProductButton

        self.model = model

        self.vector = self.model.vectorAsString()

        if commands.count == 1 {
            self.state = VMDLMatrixWindow.HasHistory(
                id: id,
                undoButton: undoButton.enable(),
                redoButton: redoButton.disable(),
                dotProductButton: dotProductButton,
                commands: commands
            )
        } else {
            self.state = VMDLMatrixWindow.NoHistory(
                    id: id,
                    undoButton: undoButton.disable(),
                    redoButton: redoButton.disable(),
                    dotProductButton: dotProductButton,
                    commands: []
            )
        }
    }

    public func updateVector(vector: [[String]]) -> VMDLMatrixWindow {
        self.model = model.update(vector: vector.map{$0.map{Float($0)!}})
        self.vector = self.model.vectorAsString()

        return self
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
        private var redoButton: VMDLButton?
        private var dotProductButton: VMDLButton?
        private var model: MCLCModel?

        public init(id: UUID) {
            self.id = id
        }

        private init(
            id: UUID,
            undoButton: VMDLButton? = nil,
            redoButton: VMDLButton? = nil,
            dotProductButton: VMDLButton? = nil,
            model: MCLCModel? = nil
        ) {
            self.id = id
            self.undoButton = undoButton
            self.redoButton = redoButton
            self.dotProductButton = dotProductButton
            self.model = model
        }

        public func undoButton(_ button:VMDLButton) -> Self {
            clone(undoButton: button)
        }

        public func redoButton(_ button:VMDLButton) -> Self {
            clone(redoButton: button)
        }

        public func dotProductButton(_ button:VMDLButton) -> Self {
            clone(dotProductButton: button)
        }

        public func model(_ model:MCLCModel) -> Self {
            clone(model: model)
        }

        public func create() -> VMDLMatrixWindow {
            VMDLMatrixWindow(
                id: id,
                undoButton: undoButton!,
                redoButton: redoButton!,
                dotProductButton: dotProductButton!,
                model: model!
            )
        }

        private func clone(
            id: UUID? = nil,
            undoButton: VMDLButton? = nil,
            redoButton: VMDLButton? = nil,
            dotProductButton: VMDLButton? = nil,
            model: MCLCModel? = nil
        ) -> Self {
            Self(
                id: id ?? self.id,
                undoButton: undoButton ?? self.undoButton,
                redoButton: redoButton ?? self.redoButton,
                dotProductButton: dotProductButton ?? self.dotProductButton,
                model: model ?? self.model
            )
        }
    }
}

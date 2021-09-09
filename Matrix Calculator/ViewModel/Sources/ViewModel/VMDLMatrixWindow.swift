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
    public var dotProductButton: VMDLButton {
        get {
            state.dotProductButton
        }
    }
    @Published public var vector: [[String]]

    private var model: MCLCModel

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

        self.model = model

        self.vector = self.model.vectorAsString()

        if commands.count == 1 {
            self.state = VMDLMatrixWindow.HasHistory(
                id: id,
                undoButton: undoButton.enable(),
                redoButton: redoButton.disable(),
                dotProductButton: dotProductButton,
                commands: commands,
                vectorState: VectorStates.ValidVector
            )
        } else {
            self.state = VMDLMatrixWindow.NoHistory(
                    id: id,
                    undoButton: undoButton.disable(),
                    redoButton: redoButton.disable(),
                    dotProductButton: dotProductButton,
                    commands: [],
                    vectorState: VectorStates.ValidVector
            )
        }
    }

    public func updateVector(vector: [[String]]) -> VMDLMatrixWindow {
        // simple double validation for now
        let valid: [[Bool]] = vector.map {
            $0.filter{ Float($0) != nil }
            .map{ $0.count >= 3}
            .filter{ $0 }
        }
        if valid[0].count != 4 {
            print("vector invalid")
            self.state = updateInResponseToChange(vectorState: .InvalidVector)
            return self
        }
        print("vector valid model")
        self.state = updateInResponseToChange(vectorState: .ValidVector)
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

    /**
     Evaluate the current state to determine how the new MatrixWindowState
     should be configured.

     Long name for now while I work this out.
     */
    private func updateInResponseToChange(vectorState: VectorStates) -> MatrixWindowState {
        let newDotProductButton: VMDLButton
        switch vectorState {
        case .InvalidVector:
            newDotProductButton = state.dotProductButton.disable()
        case .ValidVector:
            newDotProductButton = state.dotProductButton.enable()
        }


        return state.clone(dotProductButton: newDotProductButton, vectorState: vectorState)
    }

    private func updateState(state: MatrixWindowState) {

        self.state = state
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

    internal enum VectorStates {
        case ValidVector
        case InvalidVector
    }
}

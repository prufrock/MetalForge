//
// Created by David Kanenwisher on 8/1/21.
//

import Foundation

/**
 Represents the entire application being presented.
 */
@available(macOS 10.15, *)
public class VMDLWindow: ObservableObject {
    public let id: UUID
    @Published private var undoButton: Button
    @Published private var dotProductButton: Button

    private var state: MatrixWindowState

    public init(
            id: UUID,
            undoButton: Button,
            dotProductButton: Button,
            commands: [String] = []
    ) {
        self.id = id
        self.undoButton = undoButton
        self.dotProductButton = dotProductButton
        self.state = NoHistory(
            id: id,
            undoButton: undoButton,
            dotProductButton: dotProductButton,
            commands: commands
        )
    }

    public func computeDotProduct() -> VMDLWindow {
        self.updateState(state: self.state.computeDotProduct())


        return self
    }

    public func undoLastDotProduct() -> VMDLWindow {
        self.updateState(state: self.state.undoLastDotProduct())

        return self
    }

    public func disableUndoButton() {
        self.undoButton = self.undoButton.disable()
    }

    public func enableUndoButton() {
        self.undoButton = self.undoButton.enable()
    }

    public func getUndoButton() -> Button { undoButton }

    private func updateState(state: MatrixWindowState) {
        self.state = state
        self.undoButton = self.state.undoButton
        self.dotProductButton = self.state.dotProductButton
    }

    public struct Builder {

        private var id: UUID
        private var elements: [Button] = []
        private var undoButton: Button?
        private var dotProductButton: Button?

        public init(id: UUID) {
            self.id = id
        }

        private init(
            id: UUID,
            undoButton: Button? = nil,
            dotProductButton: Button? = nil
        ) {
            self.id = id
            self.undoButton = undoButton
            self.dotProductButton = dotProductButton
        }

        public func undoButton(_ button:Button) -> Self {
            return Self(id: id, undoButton: button)
        }

        public func dotProductButton(_ button:Button) -> Self {
            return Self(
                id: id,
                undoButton: undoButton,
                dotProductButton: button
            )
        }

        public func create() -> VMDLWindow {
            VMDLWindow(
                id: id,
                undoButton: undoButton!,
                dotProductButton: dotProductButton!
            )
        }
    }
}

@available(macOS 10.15, *)
public func application(id: UUID, using lambda: (VMDLWindow.Builder) -> VMDLWindow.Builder) -> VMDLWindow.Builder {
    let builder = VMDLWindow.Builder(id: id);
    return lambda(builder)
}

@available(macOS 10.15, *)
protocol MatrixWindowState {
    var undoButton: Button { get }
    var dotProductButton: Button { get }

    func computeDotProduct() -> MatrixWindowState

    func undoLastDotProduct() -> MatrixWindowState

}

@available(macOS 10.15, *)
struct NoHistory: MatrixWindowState {
    public let id: UUID
    public let undoButton: Button
    public let dotProductButton: Button
    public let commands: [String]

    func computeDotProduct() -> MatrixWindowState {

        return HasHistory(id: id,
                          undoButton: undoButton.enable(),
                          dotProductButton: dotProductButton,
                          commands: commands + [UUID().uuidString])
    }

    func undoLastDotProduct() -> MatrixWindowState {
        print("NoHistory: do nothing")
        return self
    }
}

@available(macOS 10.15, *)
struct HasHistory: MatrixWindowState {
    public let id: UUID
    public let undoButton: Button
    public let dotProductButton: Button
    public let commands: [String]

    func computeDotProduct() -> MatrixWindowState {

        return HasHistory(id: id,
                          undoButton: undoButton.enable(),
                          dotProductButton: dotProductButton,
                          commands: commands + [UUID().uuidString])
    }

    func undoLastDotProduct() -> MatrixWindowState {

        let undoButton: Button

        if (self.commands.count == 1) {
            print("HasHistory: remove last")

            undoButton = self.undoButton.disable()
            return NoHistory(id: id,
                             undoButton: undoButton,
                             dotProductButton: dotProductButton,
                             commands: []
            )
        } else {
            print("HasHistory: an item")
            return HasHistory(id: id,
                              undoButton: self.undoButton,
                              dotProductButton: dotProductButton,
                              commands: commands.dropLast())
        }
    }
}

//
// Created by David Kanenwisher on 8/1/21.
//

import Foundation

/**
 Represents the entire application being presented.
 */
@available(macOS 10.15, *)
public class Application: ObservableObject {
    public let id: UUID
    @Published private var undoButton: Button
    @Published private var dotProductButton: Button

    private var commands: [String]

    public init(
            id: UUID,
            undoButton: Button,
            dotProductButton: Button,
            commands: [String] = []
    ) {
        self.id = id
        self.undoButton = undoButton
        self.dotProductButton = dotProductButton
        self.commands = commands
    }

    public func computeDotProduct() -> Application {
        self.commands.append(UUID().uuidString)

        if (self.commands.count > 0) {
            enableUndoButton()
        }

        return self
    }

    public func undoLastDotProduct() -> Application {
        print(self.commands.popLast())

        if (self.commands.count > 0) {
            enableUndoButton()
        } else {
            disableUndoButton()
        }

        return self
    }

    private func disableUndoButton() {
        self.undoButton = self.undoButton.disable()
    }

    private func enableUndoButton() {
        self.undoButton = self.undoButton.enable()
    }

    public func getUndoButton() -> Button { undoButton }

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

        public func create() -> Application {
            Application(
                id: id,
                undoButton: undoButton!,
                dotProductButton: dotProductButton!
            )
        }
    }
}

@available(macOS 10.15, *)
public func application(id: UUID, using lambda: (Application.Builder) -> Application.Builder) -> Application.Builder {
    let builder = Application.Builder(id: id);
    return lambda(builder)
}

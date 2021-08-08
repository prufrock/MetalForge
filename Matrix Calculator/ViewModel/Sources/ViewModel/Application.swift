//
// Created by David Kanenwisher on 8/1/21.
//

import Foundation

/**
 Represents the entire application being presented.
 */
public struct Application {
    public let id: UUID
    private let undoButton: Button

    public init(
            id: UUID,
            undoButton: Button
    ) {
        self.id = id
        self.undoButton = undoButton
    }

    public func getUndoButton(button: Button) -> Button { undoButton }
    public func setUndoButton(button: Button) -> Application {
        Application(id: id, undoButton: button)
    }

    public struct Builder {

        private var id: UUID
        private var elements: [Button] = []
        private var undoButton: Button?

        public init(id: UUID) {
            self.id = id
        }

        private init(id: UUID, undoButton: Button? = nil) {
            self.id = id
            self.undoButton = undoButton
        }

        public func undoButton(_ button:Button) -> Self {
            return Self(id: id, undoButton: button)
        }

        public func create() -> Application {
            Application(
                id: id,
                undoButton: undoButton!
            )
        }
    }
}

func application(id: UUID, using lambda: (Application.Builder) -> Application.Builder) -> Application.Builder {
    let builder = Application.Builder(id: id);
    return lambda(builder)
}

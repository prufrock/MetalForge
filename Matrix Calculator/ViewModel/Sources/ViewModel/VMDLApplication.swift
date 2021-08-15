//
// Created by David Kanenwisher on 8/14/21.
//

import Foundation

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public struct VMDLApplication {
    public let id: UUID
    public let firstWindow: VMDLMatrixWindow

    public init(id: UUID, firstWindow: VMDLMatrixWindow) {
        self.id = id
        self.firstWindow = firstWindow
    }

    public struct Builder {

        private var id: UUID
        private var firstWindow: VMDLMatrixWindow?

        public init(id: UUID) {
            self.id = id
        }

        private init(
                id: UUID,
                firstWindow: VMDLMatrixWindow
        ) {
            self.id = id
            self.firstWindow = firstWindow
        }

        public func firstWindow(id: UUID, _ lambda: (VMDLMatrixWindow.Builder) -> VMDLMatrixWindow.Builder) -> Self {
            let builder = VMDLMatrixWindow.Builder(id: id)
            return Self(
                    id: id,
                    firstWindow: lambda(builder).create()
            )
        }

        public func create() -> VMDLApplication {
            VMDLApplication(
                    id: id,
                    firstWindow: firstWindow!
            )
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public func vmdlApplication(id: UUID, using lambda: (VMDLApplication.Builder) -> VMDLApplication.Builder) -> VMDLApplication.Builder {
    let builder = VMDLApplication.Builder(id: id);
    return lambda(builder)
}

//
//  GMButton.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 10/1/22.
//

/**
 * Represents a button on the screen a player can press.
 */
struct GMButton: GMActor {
    var radius: Float

    var position: Float2

    // You can't kill a button
    var isDead: Bool { false }

    var texture: GMTexture = .squareGreen

    var debounce = GMDebounce(duration: 0.01)

    var state: GMButtonState = .notClicked

    var canClick: Bool {
        switch state {
        case .clicked:
            return false
        case .notClicked:
            return true
        }
    }

    mutating func update(with input: GMInput, in world: inout GMWorld) {
        if canClick {
            state = .clicked
            if let touchCoords = input.touchLocation {
                print("touchLocation:", String(format: "%.1f, %.1f", touchCoords.position.x, touchCoords.position.y))
                world.addTouchLocation(position: touchCoords.toWorldSpace())
            }
            debounce.time = 0
        }

        if !debounce.isActive {
            state = .notClicked
        }
    }

    func toNdcSpace() -> Float2 {
        //TODO these should go somewhere more global
        let worldMaxX: Float = 1.0
        let worldMaxY: Float = 1.0
        // -1 on the left because +x to the right
        let x = ((position.x / worldMaxX) * 2) - 1
        // 1 - on the right because +y is down
        let y = 1 - ((position.y / worldMaxY) * 2)
        return Float2(x, y)
    }
}

struct GMDebounce {
    let duration: Float
    var time: Float = 0

    var isActive: Bool {
        time < duration
    }
}

enum GMButtonState {
    case clicked
    case notClicked
}

enum GMButtonType {
    case green
    case purple
}

struct GMTouchCoords {
    let position: Float2

    func toWorldSpace() -> Float2 {
        let screenWidth:Float = 965.0
        let screenHeight:Float = 680.0
        let x = 1/screenWidth * position.x
        // substract screenHeight - position.y because screen space has a lower left origin
        // while world space has an upper left origin
        let y = 1/screenHeight * (screenHeight - position.y)
        print("worldPosition:", String(format: "%.8f, %.8f", x, y))
        return Float2(x, y)
    }
}

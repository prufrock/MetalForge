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

            if input.isTouching, let touchLocation: GMButton = world.touchLocation, let intersection = intersection(with: touchLocation) {
                texture = .squarePurple
                world.toggleLight()
            }
            debounce.time = 0
        }

        if !debounce.isActive {
            state = .notClicked
            texture = .squareGreen
        }
    }

    func toNdcSpace(aspect: Float) -> Float2 {
        //TODO these should go somewhere more global
        let worldMaxX: Float = 1.0
        let worldMaxY: Float = 1.0
        // -1 on the left because +x to the right
        let x = (((position.x / worldMaxX) * 2) - 1)
            * (aspect) // adjust for the aspect ratio
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

    /**

     - Parameters:
       - screenWidth: The width of the screen that corresponds with the coordinates.
       - screenHeight: The height of the screen that corresponds with the coordinates.
       - flipY: macOS has an origin in the lower left while iOS has the origin in the upper right so you need to flip y.
     - Returns:
     */
    func toWorldSpace(screenWidth: Float, screenHeight: Float, flipY: Bool = true) -> Float2 {
        print("screen position:", String(format: "%.8f, %.8f", position.x, position.y))
        let x = 1/screenWidth * position.x
        let y = 1/screenHeight * ((position.y * (flipY ? -1 : 1)) + (screenHeight * (flipY ? 1 : 0)))
        print("h w:", String(format: "%.8f, %.8f", screenHeight, screenWidth))
        print("worldPosition:", String(format: "%.8f, %.8f", x, y))
        return Float2(x, y)
    }
}

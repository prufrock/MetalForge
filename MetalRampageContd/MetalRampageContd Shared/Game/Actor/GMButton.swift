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

    /**
     * Updates the button and lets you know if a button was clicked on this update.
     - Parameters:
       - input:
       - world:
     */
    mutating func update(with input: GMInput, in world: inout GMWorld) -> Bool {
        var clicked = false
        if canClick {
            if input.isTouching, let touchLocation: GMButton = world.touchLocation, let _ = intersection(with: touchLocation) {
                state = .clicked
                texture = .squarePurple
                world.toggleLight()
                debounce.time = 0
                clicked = true
            }
        }

        if !debounce.isActive {
            state = .notClicked
            texture = .squareGreen
        }

        return clicked
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
        let ndcPosition = toNdcSpace(screenWidth: screenWidth, screenHeight: screenHeight)
        let aspect = screenWidth / screenHeight
        //TODO find a way to share `hudCamera` between here and the renderer.
        let hudCamera = Float4x4.identity()
                .scaledX(by: 1/aspect)
        // Invert the Camera so that the position can go from NDC space to world space.
        // The camera normally takes a coordinate from world space to NDC space.
        let position4 = Float4(position: ndcPosition) * hudCamera.inverse
        print("touch world:", String(format: "%.8f, %.8f", position4.x, position4.y))
        return Float2(position4.x, position4.y)
    }

    /**
     - Parameters:
       - screenWidth: The width of the screen that corresponds with the coordinates.
       - screenHeight: The height of the screen that corresponds with the coordinates.
       - flipY: macOS has an origin in the lower left while iOS has the origin in the upper right so you need to flip y.
     - Returns:
     */
    func toNdcSpace(screenWidth: Float, screenHeight: Float, flipY: Bool = true) -> Float2 {
        // divide position.x by the screenWidth so number varies between 0 and 1
        // multiply that by 2 so that it varies between 0 and 2
        // subtract 1 because NDC x increases as you go to the right and this moves the value between -1 and 1.
        // remember the abs(-1 - 1) = 2 so multiplying by 2 is important
        let x = ((position.x / screenWidth) * 2) - 1
        // converting position.y is like converting position.x
        // I think I may need to flip the y for iOS when I get there
        let y = ((position.y / screenHeight) * 2) - 1
        print("touch screen:", String(format: "%.8f, %.8f", position.x, position.y))
        print("touch NDC:", String(format: "%.8f, %.8f", x, y))
        return Float2(x, y)
    }
}

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
                print("touchLocation:", String(format: "%.1f, %.1f", touchCoords.x, touchCoords.y))
                world.addTouchLocation(position: touchCoords)
            }
            debounce.time = 0
        }

        if !debounce.isActive {
            state = .notClicked
        }
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

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
}

enum GMButtonType {
    case green
    case purple
}

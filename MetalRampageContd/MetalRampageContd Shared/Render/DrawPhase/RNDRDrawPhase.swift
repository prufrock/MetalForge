//
//  RNDRDrawPhase.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 5/24/22.
//

import MetalKit

protocol RNDRDrawWorldPhase {
    /**
     Draws a part of the world.
     - Parameters:
       - world: the world object whose current state is drawn.
       - encoder: a command encoder from the current command buffer.
       - camera: the camera whose POV should be drawn.
     */
    func draw(world: GMWorld, encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

protocol RNDRDrawHudPhase {
    func draw(hud: GMHud, encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

protocol RNDRDrawEffectsPhase {
    func draw(effects: [GMEffect], encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

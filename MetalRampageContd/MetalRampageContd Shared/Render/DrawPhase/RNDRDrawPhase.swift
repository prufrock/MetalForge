//
//  RNDRDrawPhase.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 5/24/22.
//

import MetalKit

protocol RNDRDrawWorldPhase {
    func draw(world: GMWorld, encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

protocol RNDRDrawHudPhase {
    func draw(hud: GMHud, encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

protocol RNDRDrawEffectsPhase {
    func draw(effects: [GMEffect], encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

//
//  RNDRDrawPhase.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 5/24/22.
//

import MetalKit

protocol RNDRDrawWorldPhase {
    func draw(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

protocol RNDRDrawHudPhase {
    func draw(hud: Hud, encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

protocol RNDRDrawEffectsPhase {
    func draw(effects: [Effect], encoder: MTLRenderCommandEncoder, camera: Float4x4)
}

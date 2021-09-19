//
//  AppDelegateExt.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import Foundation
import MetalKit

extension AppDelegate {
    private struct MetalBits {
        let device: MTLDevice
        let pipelines: [String: MTLRenderPipelineState]
        let vertices: [VerticeObjects: Vertices]
    }

    private enum VerticeObjects {
        case square
    }
}

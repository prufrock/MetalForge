//
//  GMSceneLighting.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 9/20/22.
//

/**
 Holds all of the lights.
 */
struct GMLighting {
    var lights: [Light] = []

    let sunlight: Light  = {
        var light = Self.buildDefaultLighting()
        // world space
        light.position = [3, 7, 2]
        return light
    }()

    init() {
        lights.append(sunlight)
    }

    static func buildDefaultLighting() -> Light {
        var light = Light()
        // world space
        light.position = [0, 0, 0]
        light.color = [0.6, 1, 0.6]
        light.specularColor = [0.4, 0.4, 0.4]
        light.attenuation = [1, 0, 0]
        light.type = Sun
        return light
    }
}

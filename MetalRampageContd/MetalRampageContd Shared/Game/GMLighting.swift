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

    let ambientLight: Light = {
        var light = Self.buildDefaultLighting()
        light.color = [0.1, 0, 0]
        light.type = Ambient
        return light
    }()

    let redLight: Light = {
        var light = Self.buildDefaultLighting()
        light.type = PointLight
        light.position = [5.5, 1.5, 0.5] // player on first level?
        light.color = [1, 0, 0]
        light.attenuation = [0.5, 2.0, 1.0]
        return light
    }()

    init() {
        lights.append(sunlight)
        lights.append(ambientLight)
        lights.append(redLight)
        lights.append(redLight)
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

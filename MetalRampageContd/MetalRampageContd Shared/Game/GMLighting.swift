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
        light.color = [1, 0.8, 0.8]
        light.attenuation = [1.0, 0.01, 1.0]
        return light
    }()

    let spotlight: Light = {
        var light = Self.buildDefaultLighting()
        light.type = Spot
        light.position = [4.5, 1.5, 0.5]
        light.color = [1, 0, 1]
        light.attenuation = [1, 0.1, 0]
        light.coneAngle = Float(40).degreesToRadians
        light.coneDirection = [1.0, 0.0, 0.0]
        light.coneAttenuation = 8
        return light
    }()

    init() {
        lights.append(redLight)
//        lights.append(sunlight)
//        lights.append(ambientLight)
//        lights.append(redLight)
//        lights.append(redLight)
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

extension Float {
  var radiansToDegrees: Float {
      (self / .pi) * 180
  }
  var degreesToRadians: Float {
      (self / 180) * .pi
  }
}

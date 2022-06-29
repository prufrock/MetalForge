//
// Created by David Kanenwisher on 12/14/21.
//

import MetalKit

enum GMColor: Int {
    case black = 0x000000
    case red = 0xFF0000
    case green = 0x00FF00
    case blue = 0x0000FF
    case white = 0xFFFFFF
    case grey = 0x808080
    case orange = 0xff8c00
    case yellow = 0xffff00

    // shift to the right x places
    // then only take FF(the two right most hex digits or 8 most bits)
    func r() -> Int {
        rawValue >> 16 & 0xFF
    }

    func g() -> Int {
        rawValue >> 8 & 0xFF
    }

    func b() -> Int {
        rawValue >> 0 & 0xFF
    }

    func rFloat() -> Float {
        Float(r()) / 255.0
    }

    func gFloat() -> Float {
        Float(g()) / 255.0
    }

    func bFloat() -> Float {
        Float(b()) / 255.0
    }
}

extension Float3 {
    init(_ color: GMColor) {
        self.init(color.rFloat(), color.gFloat(), color.bFloat())
    }
}

extension Float4 {
    init(_ color: GMColor) {
        self.init(color.rFloat(), color.gFloat(), color.bFloat(), 1.0)
    }

    init(_ color: GMColor, alpha: Float) {
        self.init(color.rFloat(), color.gFloat(), color.bFloat(), alpha)
    }

    init(_ color: ColorA) {
        self.init(color.r, color.g, color.b, color.a)
    }
}

extension MTLClearColor {
    init(_ color: GMColor) {
        self.init(red: Double(color.rFloat()), green: Double(color.gFloat()), blue: Double(color.bFloat()), alpha: 1.0)
    }
}

/**
 Color with alpha.
 */
class ColorA {
    let r: Float
    let g: Float
    let b: Float
    let a: Float

    init(r: Float, g: Float, b: Float, a: Float) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init(_ color: GMColor, a: Float = 1.0) {
        r = color.rFloat()
        g = color.gFloat()
        b = color.bFloat()
        self.a = a
    }
}

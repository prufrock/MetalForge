//
// Created by David Kanenwisher on 12/14/21.
//

import MetalKit

public enum Color: Int {
    case black = 0x000000
    case red = 0xFF0000
    case green = 0x00FF00
    case blue = 0x0000FF
    case white = 0xFFFFFF

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
    init(_ color: Color) {
        self.init(color.rFloat(), color.gFloat(), color.bFloat())
    }
}

extension MTLClearColor {
    init(_ color: Color) {
        self.init(red: Double(color.rFloat()), green: Double(color.gFloat()), blue: Double(color.bFloat()), alpha: 1.0)
    }
}

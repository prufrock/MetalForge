//
//  Model.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/19/22.
//
import Metal

protocol Model {
    var v: [F3] {get}
    var s: MSpaces {get}
    var primitiveType: MTLPrimitiveType {get}
}

struct Dot: Model {
    let v: [F3] = [F3(0.0, 0.0, 0.0)]
    let s: MSpaces = .model
    let primitiveType: MTLPrimitiveType = .point
}

struct Square: Model {
    let v: [F3] = [
        // first triangle
        F3(-1, 1, 0), F3(1,1,0), F3(1, -1, 0), F3(-1, 1, 0),
        // second triangle
        F3(1, -1, 0),  F3(-1,-1,0), F3(1, -1, 0),
    ]
    let s: MSpaces = .model
    let primitiveType: MTLPrimitiveType = .triangle
}

struct WireframeSquare: Model {
    let v: [F3] = [
        // first triangle
        F3(-1, 1, 0), F3(1, 1, 0), F3(1, 1, 0), F3(1, -1, 0), F3(1, -1, 0), F3(-1, 1, 0),
        // second triangle
        F3(1, -1, 0), F3(-1, -1, 0), F3(-1, -1, 0), F3(-1, 1, 0), F3(-1, 1, 0), F3(1, -1, 0),
    ]
    let s: MSpaces = .model
    let primitiveType: MTLPrimitiveType = .line
}

enum BasicModels {
    case dot, square, wfSquare
}

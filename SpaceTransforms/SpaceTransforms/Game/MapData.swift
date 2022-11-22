//
//  MapData.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/22/22.
//

struct MapData: Decodable {
    let tiles: [Tile]
    let things: [Thing]?
    let width: Int
}

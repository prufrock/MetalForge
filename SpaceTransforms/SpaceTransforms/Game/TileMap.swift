//
//  TileMap.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/22/22.
//

struct TileMap {
    private(set) var tiles: [Tile]
    private var things: [Thing]
    private var hud: [Tile]
    let width: Int
    var height: Int {
        tiles.count / width
    }
    var size: Float2 {
        return Float2(x: Float(width), y: Float(height))
    }

    // for switching between levels
    let index: Int

    init(_ map: MapData, index: Int) {
        tiles = map.tiles
        things = map.things ?? Array(repeating: .nothing, count: map.tiles.count)
        hud = map.hud
        width = map.width
        self.index = index
    }

    /**
     Access things via subscript so it's a little more natural to get at them.
     Also, it's 1D array posing as a 2D array so hide that.
     */
    subscript(thing x: Int, y: Int) -> Thing {
        get { things[y * width + x] }
    }

    subscript(hud x: Int, y: Int) -> Tile {
        get { hud[y * width + x] }
    }

    subscript(x: Int, y: Int) -> Tile {
        get { tiles[y * width + x ] }
    }
}

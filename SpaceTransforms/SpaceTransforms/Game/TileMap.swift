//
//  TileMap.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/22/22.
//

struct TileMap {
    private(set) var tiles: [Tile]
    private var things: [Thing]
    let width: Int
    var height: Int {
        tiles.count / width
    }

    // for switching between levels
    let index: Int

    init(_ map: MapData, index: Int) {
        tiles = map.tiles
        things = map.things ?? Array(repeating: .nothing, count: map.tiles.count)
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

    subscript(x: Int, y: Int) -> Tile {
        get { tiles[y * width + x ] }
    }
}

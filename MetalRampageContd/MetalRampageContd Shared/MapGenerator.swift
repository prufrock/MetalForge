//
// Created by David Kanenwisher on 5/9/22.
//

/**
 Knows how to create random levels.
 */
struct MapGenerator {
    private(set) var map: Tilemap

    public init(mapData: MapData, index: Int) {
        map = Tilemap(mapData, index: index)
    }
}

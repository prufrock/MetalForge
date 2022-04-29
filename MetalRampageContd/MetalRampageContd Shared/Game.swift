//
// Created by David Kanenwisher on 4/28/22.
//

/**
 Manages all of the things that happen outside of the World but are still a part of the game.
 You know, things like menus and the title screen.
 */
struct Game {
    let levels: [Tilemap]
    private(set) var world: World
    private(set) var state: GameState = .title

    init(levels: [Tilemap]) {
        self.levels = levels
        // Game manages the world
        // Seems like we should start at level 0
        self.world = World(map: levels[0])
    }
}

/**
 Like so many things in MetalRampage even the Game has a state.
 It's especially useful to know if the game is being played or something else is happening.
 */
enum GameState {
    case title
    case playing
}

/**
 A delegate so Game can make the controllers do things.
 */
protocol GameDelegate: AnyObject {
    func playSound(_ sound: Sound)
    func clearSounds()
}

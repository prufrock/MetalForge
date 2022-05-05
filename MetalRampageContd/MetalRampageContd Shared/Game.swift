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

    // Transition effects between game states.
    private(set) var transition: Effect?

    // weak because Game shouldn't prevent the delegate from getting deallocated.
    weak var delegate: GameDelegate?

    init(levels: [Tilemap]) {
        self.levels = levels
        // Game manages the world
        // Seems like we should start at level 0
        self.world = World(map: levels[0])
    }
}

extension Game {
    /**
     Update the game.
     - Parameters:
       - timeStep: The amount of time to move it forward.
       - input: The input to apply to the world.
     */
    mutating func update(timeStep: Float, input: Input) {
        // if there isn't a delegate there's no reason to work
        guard let delegate = delegate else {
            return
        }

        // Update transition
        if var effect = transition {
            effect.time += timeStep
            transition = effect
        }

        // Update state
        switch state {
        case .title:
            // if the player presses the fire button switch to playing
            if input.isFiring {
                print("switch to playing")
                transition = Effect(type: .fadeOut, color: ColorA(Color.black), duration: 0.5)
                state = .starting
            }
        case .starting:
            if transition?.isCompleted == true {
                transition = Effect(type: .fadeIn, color: ColorA(Color.black), duration: 0.5)
                state = .playing
            }
        case .playing:
            if let action = world.update(timeStep: timeStep, input: input) {
                switch action {
                case .loadLevel(let index):
                    // keep rotating through the available levels.
                    let index = index % levels.count
                    world.setLevel(levels[index])
                    //TODO look for a way to create a new renderer when a new World is created
                    // quick work around to make sure aspect is passed when a new renderer is created
                    delegate.updateRenderer(world)
                    delegate.clearSounds()
                case .playSounds(let sounds):
                    // implicitly passes the sound to playSound
                    sounds.forEach(delegate.playSound)
                }
            }
        }
    }
}

/**
 Like so many things in MetalRampage even the Game has a state.
 It's especially useful to know if the game is being played or something else is happening.
 */
enum GameState {
    case title
    case starting
    case playing
}

/**
 A delegate so Game can make the controllers do things.
 */
protocol GameDelegate: AnyObject {
    func playSound(_ sound: Sound)
    func clearSounds()
    func updateRenderer(_ world: World)
}

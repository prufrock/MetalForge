//
// Created by David Kanenwisher on 4/9/22.
//

import Foundation

struct Switch {
    let position: Float2
    var state: SwitchState = .off
    var animation: Animation = .switchOff
}

extension Switch {
    // For collision, only as big as the tile it's in.
    var rect: Rect {
        Rect(
            min: position - Float2(x: 0.5, y: 0.5),
            max: position + Float2(x: 0.5, y: 0.5)
        )
    }

    mutating func update(in world: inout World) {
        switch state {
        // Is that the player?! Change to the "on" state
        case .off:
            if world.player.rect.intersection(with: self.rect) != nil {
                print("flipped the switch")
                state = .on
                animation = .switchFlip
                world.playSound(.switchFlip, at: position)
            }
        case .on:
            // once the animation is over end the level
            // don't end in .off  then animations stop updating before they're done
            if animation.time >= animation.duration {
                animation = .switchOn
                world.endLevel()
            }
            // Make sure the switch doesn't animate forever
            if animation.isCompleted {
                animation = .switchOn
            }
        }
    }
}

enum SwitchState {
    case off
    case on
}

extension Animation {
    // it sits in the off state so 1 frame
    static let switchOff = Animation(frames: [
        .switch1
    ], duration: 0)
    // it moves through all 4 frames when it is flipped
    static let switchFlip = Animation(frames: [
        .switch1,
        .switch2,
        .switch3,
        .switch4
    ], duration: 0.4)
    // it sits in the on state so 1 frame
    static let switchOn = Animation(frames: [
        .switch4
    ], duration: 0)
}

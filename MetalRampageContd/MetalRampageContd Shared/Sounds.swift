//
// Created by David Kanenwisher on 4/12/22.
//

// These will be mapped to actual sound files
public enum SoundName: String, CaseIterable {
    case castSpell //pistolFire
    case spellMiss //ricochet
    case castFireSpell
    case fireSpellMiss
    case fireSpellHit
    case monsterHit
    case monsterGroan
    case monsterDeath
    case monsterSwipe
    case doorSlide
    case wallSlide
    case wallThud
    case switchFlip
    case playerDeath
    case playerWalk
    case squelch
}

public struct Sound {
    // when this is nil SoundManager knows to stop playing the sound on the channel
    let name: SoundName?
    let volume: Float
    // controls the balance of sound
    let pan: Float
    let delay: Float
    // allows a sound to be referenced and controlled
    // not every sound needs a channel so it can be optional
    // it is only used for sounds that loop
    let channel: Int?
}
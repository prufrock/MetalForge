//
// Created by David Kanenwisher on 4/12/22.
//

// These will be mapped to actual sound files
public enum SoundName: String, CaseIterable {
    case castFireSpell //pistolFire
    case fireSpellMiss //ricochet
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
    let name: SoundName
}
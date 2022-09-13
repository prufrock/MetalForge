//
// Created by David Kanenwisher on 3/18/22.
//
enum GMTexture: String, CaseIterable, Decodable {
    case floor, crackFloor
    case ceiling
    case wall, crackWall, crackWall2, slimeWall, slimeWall2
    case wandSpriteSheet
    case wand
    case wandIcon
    case wandFiring1, wandFiring2, wandFiring3, wandFiring4
    case monsterSpriteSheet
    case monsterBlobSpriteSheet
    case monster
    case monsterWalk1, monsterWalk2
    case monsterScratch1, monsterScratch2, monsterScratch3, monsterScratch4
    case monsterScratch5, monsterScratch6, monsterScratch7, monsterScratch8
    case monsterHurt, monsterDeath1, monsterDeath2, monsterDead
    case door1, door2
    case doorSpriteSheet
    case doorJamb1, doorJamb2
    case switch1, switch2, switch3, switch4
    case healingPotion
    case fireBlastIdle
    case fireBlastFire1, fireBlastFire2,  fireBlastFire3, fireBlastFire4
    case fireBlastSpriteSheet
    case fireBlastPickup
    case fireBlastIcon
    case crosshair
    case healthIcon
    case font
    case titleLogo
    case wallSpriteSheet
    case pickUpSpriteSheet
    case none
}

/**
 Eventually determines the dimensions of the sprite sheet to use.
 */
enum GMTextureType {
    case none
    case monster
    case pickup
    case door
    case wall
}

/**
 Determines the specific file to load.
 */
enum GMTextureVariant {
    // use none when there either are no variants or it's the base case
    // like for monster "none" means to use the "monsterSpriteSheet"
    case none
    case monsterBlob
}
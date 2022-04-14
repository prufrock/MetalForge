//
// Created by David Kanenwisher on 4/12/22.
//

import AVFoundation

/**
 Only allow one instance of the SoundManager(singleton).
 */
class SoundManager: NSObject, AVAudioPlayerDelegate {
    // Holds AVAudioPlayer instances that are currently playing a sound.
    private var playing = Set<AVAudioPlayer>()

    static let shared = SoundManager()

    private override init() {}

    /**
     AVAudioPlayerDelegate method that is called when a player finishes. Use this to remove that player from the set of
     playing players.
     - Parameters:
       - player: The player to remove.
       - flag: Whether or not it finished successfully.
     */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing.remove(player)
    }
}

extension SoundManager {
    // hey OS, we're going to use sound!
    func activate() throws {
        // AVAudioSession is only available on iOS
        #if os(iOS)
        try AVAudioSession.sharedInstance().setActive(true)
        #endif
    }

    // Boot up AVAudioPlayer by loading a file since AVAudioPlayer briefly blocks when it's loaded.
    func preload(_ url: URL) throws -> AVAudioPlayer {
        try AVAudioPlayer(contentsOf: url)
    }

    /**
     Play the sound at volume. The volume helps create a sense of how near the sound is to the player.
     - Parameters:
       - url: path to the sound to play
       - volume: the volume to play it at
       - pan: the pan to play it at
     - Throws:
     */
    func play(_ url: URL, volume: Float, pan: Float) throws {
        let player = try AVAudioPlayer(contentsOf: url)
        // Add the playing players to a Set so they don't get destroyed before they finish playing.
        playing.insert(player)
        // Set the sounds manager as the delegate so it's called when the player finishes.
        player.delegate = self
        player.volume = volume
        player.pan = pan
        player.play()
    }
}

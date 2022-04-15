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

    private var channels = [Int: (url: URL, player: AVAudioPlayer)]()

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

    // Can preload a sound to stop AVAudioPLayer from blocking during the game
    // Also, prepares audio players to playback a sound,
    // checking to see if the sound is already playing on a channel.
    func preload(_ url: URL, channel: Int? = nil) throws -> AVAudioPlayer {
        if let channel = channel, let (oldUrl, oldSound) = channels[channel] {
            if oldUrl == url {
                return oldSound
            }
            oldSound.stop()
        }
        return try AVAudioPlayer(contentsOf: url)
    }

    /**
     Play the sound at volume. The volume helps create a sense of how near the sound is to the player.
     - Parameters:
       - url: path to the sound to play
       - channel: allows control of looping sounds
       - volume: the volume to play it at
       - pan: the pan to play it at
     - Throws:
     */
    func play(_ url: URL, channel: Int?, volume: Float, pan: Float) throws {
        let player = try preload(url, channel: channel)

        // if it has a channel
        // store the sound in channels
        // and loop it indefinitely
        if let channel = channel {
            channels[channel] = (url, player)
            player.numberOfLoops = -1
        }

        // Add the playing players to a Set so they don't get destroyed before they finish playing.
        playing.insert(player)
        // Set the sounds manager as the delegate so it's called when the player finishes.
        player.delegate = self
        player.volume = volume
        player.pan = pan
        player.play()
    }

    func clearChannel(_ channel: Int) {
        channels[channel]?.player.stop()
        channels[channel] = nil
    }

    func clearAll() {
        channels.keys.forEach(clearChannel)
    }
}

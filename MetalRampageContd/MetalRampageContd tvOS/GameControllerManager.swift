//
//  GameControllerManager.swift
//  MetalRampageContd tvOS
//
//  Created by David Kanenwisher on 1/3/23.
//

import GameController

/**
 Sourced from: https://github.com/nicklockwood/RetroRampage/pull/14/commits/dd2b1420eec338ba2222ed4ce196b541ec5b0747#diff-e853547ae093b1432e7936cd4f64a808346ae89a2e27152af9b4ccb77fe1445b
 */
class GameControllerManager {
    var gameController: GCController?

    init() {
        // Watch for controller connected and disconnected events
        NotificationCenter.default.addObserver(self, selector: #selector(controllerConnected), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDisconnected), name: .GCControllerDidDisconnect, object: nil)
        // start looking for controllers
        GCController.startWirelessControllerDiscovery()
    }
}

extension GameControllerManager {
    @objc private func controllerConnected(_ note: Notification) {
        // Once you find a controller stop looking for controllers.
        // In the future this should probably be controller by uesr interaction.
        GCController.stopWirelessControllerDiscovery()
        gameController = note.object as? GCController
    }

    @objc private func controllerDisconnected(_ note: Notification) {
        // when the controller disconnects start looking for controllers again
        // In the future this should probably be controller by user interaction.
        GCController.startWirelessControllerDiscovery()
        // clean up when a controller is disconnected
        gameController = nil
    }
}

extension GameControllerManager {
    func input(turningSpeed: Float, worldTimeStep: Float) -> GMInput? {
        guard let controller = gameController?.extendedGamepad else { return nil }

        let leftInput = controller.leftThumbstick
        let rightInput = controller.rightThumbstick
        let rotation = Float(rightInput.xAxis.value) * turningSpeed * worldTimeStep
        let isFiring = controller.rightTrigger.isPressed

        return GMInput(speed: Float(leftInput.yAxis.value),
                       rotation: Float2x2.rotate(rotation),
                       rotation3d: Float4x4.rotateY(rotation),
                       isFiring: isFiring,
                       showMap: false,
                       drawWorld: false,
                       isTouching: false)
    }
}

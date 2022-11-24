//
// Created by David Kanenwisher on 11/22/22.
//

import Foundation

struct Input {
    var movement: Float2
    var cameraMovement: Float3
    var camera: AvailableCameras
    var isClicked: Bool
    var clickCoordinates: MFloat2
    var aspect: Float
    var viewWidth: Float
    var viewHeight: Float
}

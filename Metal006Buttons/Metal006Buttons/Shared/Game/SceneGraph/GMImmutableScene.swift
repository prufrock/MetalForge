//
// Created by David Kanenwisher on 11/29/21.
//

import simd

struct GMImmutableScene: RenderableCollection {
    private let screenHeight: Float
    private let screenWidth: Float

    let camera: GMImmutableCamera
    let node: GMNode
    let state: SceneState

    init(
        node: GMNode = GMImmutableNode(),
        camera: GMImmutableCamera,
        state: SceneState = .paused,
        screenWidth: Float = 0,
        screenHeight: Float = 0
    ) {
        self.node = node
        self.camera = camera
        self.state = state
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
    }

    func cameraSpace() -> Float4x4 {
        camera.cameraSpace()
    }

    func click(x: Float, y: Float) -> RenderableCollection {
        //TODO move process of changing displayCoords to worldCoords into a function
        let displayCoords = SIMD2<Float>(Float(x), Float(y))
        let ndcCoords: Float4x4 = displayCoords.displayToNdc(
            display: SIMD2<Float>(Float(screenWidth), Float(screenHeight))
        )

        print("ndc x:\(ndcCoords[0][0]) y:\(ndcCoords[1][1])")

        let worldCoords = ndcCoords * camera.reverseProjectionMatrix()

        print("world x:\(worldCoords[0][0]) y:\(worldCoords[1][1])")

        let ray = GMRay(origin: Float3(worldCoords[0][0], worldCoords[1][1], 0.0), target: Float3(worldCoords[0][0], worldCoords[1][1], camera.nearPlane))

        var newChildren: [GMNode] = []
        var translation: Float4x4 = matrix_identity_float4x4
        var newState = state

        for i in 0..<camera.children.count {
            let children = camera.children
            let node = children[i]
            //TODO make it easier to create a sphere from a node
            let sphere = GMSphere(center: node.element.location.rawValue, radius: 0.2)
            if(ray.intersects(with: sphere)) {
                if (node.element.color == Float4(.white)) {
                    newChildren.append(node.setColor(Float4(.red)))
                } else {
                    newChildren.append(node.setColor(Float4(.white)))
                }

                if i == 0 {
                    translation = Float4x4.translate(x: -0.1, y: 0, z: 0)
                } else if i == 1 {
                    translation = matrix_identity_float4x4
                    switch state {
                    case .playing:
                        newState = .paused
                    case .paused:
                        newState = .playing
                    }
                } else if i == 2 {
                    translation = Float4x4.translate(x: 0.1, y: 0, z: 0)
                }
            } else {
                newChildren.append(node)
            }
        }

        //TODO Figure out a way to not force downcast this.
        return clone(camera: (camera.clone(children: newChildren).translate(translation) as! GMImmutableCamera), state: newState)
    }

    func render(to: (RenderableNode) -> Void) {
        camera.render(to: to)
        node.render(to: to)
    }

    func update(elapsed: Double) -> RenderableCollection {
        var newNode: GMNode
        switch state {
        case .playing:
            newNode = node.setChildren(updateAllButNewestChild(elapsed: elapsed, children: node.children))
        case .paused:
            newNode = node
        }

        if(newNode.children.count >= 1) {
            newNode = newNode.setChildren(newNode.children[0..<(node.children.endIndex-1)] + [newNode.children.last!.setColor(Float4(.red))])
        }

        return clone(node: newNode)
    }

    private func updateAllButNewestChild(
        elapsed: Double,
        children oldChildren: [GMNode],
        newChildren: [GMNode] = []
    ) -> [GMNode] {
        // if there's no children then do nothing
        if oldChildren.lastIndex == -1 {
            return oldChildren
            // stop just short of the end so that the last element doesn't change
        } else if (newChildren.lastIndex + 1) == oldChildren.lastIndex {
            return newChildren + [oldChildren[oldChildren.lastIndex]]
        } else {
            return updateAllButNewestChild(elapsed: elapsed, children: oldChildren, newChildren: newChildren + [oldChildren[newChildren.count].move(elapsed: elapsed).setColor(Float4(.green))])
        }
    }

    private func clone(
        node: GMNode? = nil,
        camera: GMImmutableCamera? = nil,
        state: SceneState? = nil,
        screenWidth: Float? = nil,
        screenHeight: Float? = nil
    ) -> RenderableCollection {
        GMImmutableScene(
            node: node ?? self.node,
            camera: camera ?? self.camera,
            state: state ?? self.state,
            screenWidth: screenWidth ?? self.screenWidth,
            screenHeight: screenHeight ?? self.screenHeight
        )
    }

    func setScreenDimensions(width: Float, height: Float) -> RenderableCollection {
        clone(camera: camera.setAspectRatio(Float(width / height)), screenWidth: width, screenHeight: height)
    }

    private func randomNode(children: [GMImmutableNode], color: Float4) -> GMImmutableNode {
        let location = Point(
            Float.random(in: -1...1),
            Float.random(in: self.camera.cameraBottom...self.camera.cameraTop),
            Float.random(in: 0...1)
        )

        let transformation = matrix_identity_float4x4

        return GMImmutableNode(
            children: children,
            location: location,
            transformation: transformation,
            vertices: VerticeCollection().c[.cube]!,
            color: color,
            state: .forward,
            hidden: false
        )
    }

    enum SceneState {
        case playing
        case paused
    }
}

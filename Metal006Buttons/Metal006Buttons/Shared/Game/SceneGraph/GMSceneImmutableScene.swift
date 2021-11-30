//
// Created by David Kanenwisher on 11/29/21.
//

import simd

struct GMSceneImmutableScene: RenderableCollection {
    private let screenHeight: Float
    private let screenWidth: Float

    let camera: GMImmutableCamera
    let node: GMSceneNode
    let state: SceneState

    init(
        node: GMSceneNode = GMSceneImmutableNode(),
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

    func cameraSpace(withAspect aspect: Float) -> float4x4 {
        camera.cameraSpace(withAspect: aspect)
    }

    func click(x: Float, y: Float) -> RenderableCollection {
        let aspect = Float(screenWidth / screenHeight)
        let displayCoords = SIMD2<Float>(Float(x), Float(y))
        let ndcCoords: float4x4 = displayCoords.displayToNdc(
            display: SIMD2<Float>(Float(screenWidth), Float(screenHeight))
        )

        let worldCoords = ndcCoords * camera.reverseProjectionMatrix(aspect)

        let ray = Ray(origin: float3(worldCoords[0][0], worldCoords[1][1], 0.0), target: float3(worldCoords[0][0], worldCoords[1][1], camera.nearPlane))

        var newChildren: [GMSceneNode] = []

        for i in 0..<camera.children.count {
            let children = camera.children
            let node = children[i]
            let sphere = Sphere(center: node.location.rawValue, radius: 0.2)
            if(ray.intersects(with: sphere)) {
                if (node.color == float4(.white)) {
                    newChildren.append(node.setColor(float4(.red)))
                } else {
                    newChildren.append(node.setColor(float4(.white)))
                }
            } else {
                newChildren.append(node)
            }
        }

        return clone(camera: camera.clone(children: newChildren))
    }

    func setCameraDimension(top: Float, bottom: Float) -> RenderableCollection {
        clone(
            camera: camera.setDimensions(cameraTop: top, cameraBottom: bottom)
        )
    }

    func render(to: (RenderableNode) -> Void) {
        camera.render(to: to)
        node.render(to: to)
    }

    func update(elapsed: Double) -> RenderableCollection {
        var newNode: GMSceneNode
        switch state {
        case .playing:
            newNode = node.setChildren(node.children.map {
                node in node.update { node in
                    node.move(elapsed: elapsed).setColor(float4(.green))
                }
            })
        case .paused:
            newNode = node.setChildren(updateAllButNewestChild(elapsed: elapsed, children: node.children))
        }

        if(newNode.children.count >= 1) {
            newNode = newNode.setChildren(newNode.children[0..<(node.children.endIndex-1)] + [newNode.children.last!.setColor(float4(.red))])
        }

        return clone(node: newNode)
    }

    private func updateAllButNewestChild(
        elapsed: Double,
        children oldChildren: [GMSceneNode],
        newChildren: [GMSceneNode] = []
    ) -> [GMSceneNode] {
        // if there's no children then do nothing
        if oldChildren.lastIndex == -1 {
            return oldChildren
            // stop just short of the end so that the last element doesn't change
        } else if (newChildren.lastIndex + 1) == oldChildren.lastIndex {
            return newChildren + [oldChildren[oldChildren.lastIndex]]
        } else {
            return updateAllButNewestChild(elapsed: elapsed, children: oldChildren, newChildren: newChildren + [oldChildren[newChildren.count].move(elapsed: elapsed).setColor(float4(.green))])
        }
    }

    private func clone(
        node: GMSceneNode? = nil,
        camera: GMImmutableCamera? = nil,
        state: SceneState? = nil,
        screenWidth: Float? = nil,
        screenHeight: Float? = nil
    ) -> RenderableCollection {
        GMSceneImmutableScene(
            node: node ?? self.node,
            camera: camera ?? self.camera,
            state: state ?? self.state,
            screenWidth: screenWidth ?? self.screenWidth,
            screenHeight: screenHeight ?? self.screenHeight
        )
    }

    func setScreenDimensions(height: Float, width: Float) -> RenderableCollection {
        return clone(screenWidth: width, screenHeight: height)
    }

    private func randomNode(children: [GMSceneImmutableNode], color: float4) -> GMSceneImmutableNode {
        let location = Point(
            Float.random(in: -1...1),
            Float.random(in: self.camera.cameraBottom...self.camera.cameraTop),
            Float.random(in: 0...1)
        )

        let transformation = matrix_identity_float4x4

        return GMSceneImmutableNode(
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

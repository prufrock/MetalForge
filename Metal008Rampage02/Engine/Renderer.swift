//
// Created by David Kanenwisher on 12/13/21.
//

import Foundation
import MetalKit

public class Renderer: NSObject {
    let view: MTKView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipeline: MTLRenderPipelineState
    var aspect: Float = 1.0
    private var world = World(map: loadMap())
    private let maximumTimeStep: Float = 1 / 20 // cap at a minimum of 20 FPS
    private let worldTimeStep: Float = 1 / 120 // number of steps to take each frame
    private var lastFrameTime = CACurrentMediaTime()
    //TODO is there some way to do this in the view controller?
    private let panGesture = UIPanGestureRecognizer()
    private var inputVector: Float2 {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: view)
            var vector = Float2(x: Float(translation.x), y: Float(translation.y))
            vector /= max(joystickRadius, vector.length)

            //update the position of where the gesture started
            //to make movement a little smoother
            panGesture.setTranslation(CGPoint(
                x: Double(vector.x * joystickRadius),
                y: Double(vector.y * joystickRadius)
            ), in: view)

            return vector
        default:
            return Float2(x: 0, y: 0)
        }
    }
    // travel distance of 80 screen points ~0.5" so 40 radius
    private let joystickRadius: Float = 40

    public init(_ view: MTKView, width: Int, height: Int) {
        self.view = view

        guard let newDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("""
                       I looked in the computer and didn't find a device...sorry =/
                       """)
        }

        view.device = newDevice
        view.addGestureRecognizer(panGesture)

        device = newDevice

        guard let newCommandQueue = device.makeCommandQueue() else {
            fatalError("""
                       What?! No comand queue. Come on!
                       """)
        }

        commandQueue = newCommandQueue

        guard let library = device.makeDefaultLibrary() else {
            fatalError("""
                       What in the what?! The library couldn't be loaded.
                       """)
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let defaultPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        pipeline = defaultPipelineState

        super.init()

        view.delegate = self
        view.clearColor = MTLClearColor(.black)
    }

    private func render(_ world: World) {

        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
            fatalError("""
                       Ugh, no command buffer. What the heck!
                       """)
        }

        guard let descriptor = view.currentRenderPassDescriptor, let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("""
                       Dang it, couldn't create a command encoder.
                       """)


        }

        let worldTransform = Float4x4.identity()
            * Float4x4(scaleY: -1)

        let cameraTransform = Float4x4.identity()
            * Float4x4(translateX: -0.32, y: 0.65, z: 0)
            * Float4x4(scaleX: 0.09, y: 0.09, z: 1.0)
            * Float4x4(scaleY: aspect)

        //Draw map
        var renderables: [([Float3], Float4x4, Color)] = TileImage(map: world.map).tiles
        //Draw player
        renderables.append(world.player.rect.renderable())

        renderables.forEach { (vertices, objTransform, color) in
            let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = cameraTransform * worldTransform * objTransform

            encoder.setRenderPipelineState(pipeline)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<simd_float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float3(color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }

        encoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

//TODO can this be an extension of the view controller?
extension Renderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        print("height: \(size.height) width: \(size.width)")
        print("height: \(view.frame.height) width: \(view.frame.width)")

        aspect = Float(size.width / size.height)
    }

    public func draw(in view: MTKView) {
        // increase accuracy of collisions by reducing time between updates
        // also avoid spiralling when world updates take longer than frame step
        let time = CACurrentMediaTime()
        let timeStep = min(maximumTimeStep, Float(CACurrentMediaTime() - lastFrameTime))
        let input = Input(velocity: inputVector)
        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            world.update(timeStep: Float(timeStep /  worldSteps), input: input)
        }
        lastFrameTime = time


        render(world)
    }
}


private func loadMap() -> Tilemap {
    let jsonUrl = Bundle.main.url(forResource: "Map", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonUrl)
    return try! JSONDecoder().decode(Tilemap.self, from: jsonData)
}

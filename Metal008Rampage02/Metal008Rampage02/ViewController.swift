//
//  ViewController.swift
//  Metal008Rampage02
//
//  Created by David Kanenwisher on 12/26/21.
//

import UIKit
import MetalKit
import Engine

class ViewController: UIViewController {
    private let metalView = MTKView()
    private var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetalView()

        renderer = Renderer(metalView, width: 8, height: 8)
    }

    func setupMetalView() {
        view.addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        metalView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        metalView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        metalView.contentMode = .scaleAspectFit
        metalView.backgroundColor = .black
    }
}

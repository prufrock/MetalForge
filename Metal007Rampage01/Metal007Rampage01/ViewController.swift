//
//  ViewController.swift
//  Metal007Rampage01
//
//  Created by David Kanenwisher on 12/13/21.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    private let metalView = MTKView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetalView()
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


//
//  GameViewController.swift
//  IOSGame
//
//  Created by teknologi game on 29/03/18.
//  Copyright © 2018 PENS. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

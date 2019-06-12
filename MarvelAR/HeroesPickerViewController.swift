//
//  HeroesPickerViewController.swift
//  MarvelAR
//
//  Created by Hadi Dbouk on 6/11/19.
//  Copyright © 2019 hadiidbouk. All rights reserved.
//

import UIKit
import SceneKit

class HeroesPickerViewController: UIViewController {
    
    var cameraNode: SCNNode!
    var scene: SCNScene!
    var sceneView: SCNView!
    var size: CGSize!
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.size = size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = size
        setupScene()
        addHerosNodes()
    }
    
    private func setupScene() {
        
        view.frame = CGRect(origin: .zero, size: size)
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.insertSubview(sceneView, at: 0)
        sceneView.debugOptions = SCNDebugOptions(arrayLiteral: [SCNDebugOptions.renderAsWireframe])
        scene = SCNScene(named: "heroes.scnassets/picker.scn")
        sceneView.scene = scene
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene?.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(0, 0, 8)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .spot
        lightNode.position = SCNVector3(0, 5, 5)
        scene?.rootNode.addChildNode(lightNode)
    }
    
    private func addHerosNodes() {
    
        let ironManPosition = SCNVector3(0, -2, 0)
        let ironManNode = getHeroNode(name: "ironMan", position: ironManPosition, eulerAngles: SCNVector3(5, 0, 0))
        ironManNode.rotateAroundSelf(initialPosition: ironManPosition, duration: 8)
        scene.rootNode.addChildNode(ironManNode)
        
        let hulkPosition = SCNVector3(-1.19, -0.8, -1)
        let hulkNode = getHeroNode(name: "hulk", position: hulkPosition, eulerAngles: SCNVector3(90.0.degreesToRadians, 0.3, 0))
        hulkNode.scale = SCNVector3(4, 4, 4)
        hulkNode.rotateAroundSelf(initialPosition: hulkPosition, duration: 8)
        scene.rootNode.addChildNode(hulkNode)
        
        let captainAmericaPosition = SCNVector3(3.2, -2.1, 0)
        let captainAmericaNode = getHeroNode(name: "captainAmerica", position: captainAmericaPosition, eulerAngles: SCNVector3(5, -0.3, 0))
        captainAmericaNode.centerPivot()
        captainAmericaNode.rotateAroundSelf(initialPosition: captainAmericaPosition, duration: 8)
        scene.rootNode.addChildNode(captainAmericaNode)
    }
    
    private func getHeroNode(name: String, position: SCNVector3, eulerAngles: SCNVector3) -> SCNNode {
        let scene = SCNScene(named: "heroes.scnassets/\(name)/\(name).dae")
        let containerNode = SCNNode()

        if let rootNode = scene?.rootNode {
            rootNode.position = position
            rootNode.eulerAngles = eulerAngles
            
            containerNode.addChildNode(rootNode)
        }
        return containerNode
    }
}

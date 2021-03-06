//
//  HeroesPlacer.swift
//  MarvelAR
//
//  Created by Hadi Dbouk on 6/11/19.
//  Copyright © 2019 hadiidbouk. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class HeroesPlacerViewController: UIViewController {

    var heroesPickerViewController: HeroesPickerViewController?
    var selectedHeroName: HeroName?
    var nodes = [HeroNode]()
    var inEditMode = false
    var boundingView: UIView?
    var cameraNode: SCNNode!
    var lastSelectedNode: HeroNode?
    
    //UI
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var rotateBtn: UIButton!
    @IBOutlet weak var downBtn: UIButton!
    @IBOutlet weak var upBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var editModeLbl: UILabel!
    @IBOutlet weak var heroPickerBtn: UIButton!
    @IBOutlet weak var closeEditModeBtn: UIButton!
    
    var focusPoint: CGPoint {
        return CGPoint(
            x: sceneView.bounds.size.width / 2,
            y: sceneView.bounds.size.height - (sceneView.bounds.size.height / 1.618))
    }
    
    var focusView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0.8
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 20, height: 20)
        imageView.image = #imageLiteral(resourceName: "focus")
        imageView.center = view.center
        
        view.addSubview(imageView)
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            
            imageView.transform = imageView.transform.scaledBy(x: 1.5, y: 1.5)
            
        }, completion: nil)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func addGestures() {
        let rotateGesture = LongPressActionGestureRecognizer(actionType: .rotate, target: self, action: #selector(onLongPressActionBtn(gesture:)))
        let upGesture = LongPressActionGestureRecognizer(actionType: .moveUp, target: self, action: #selector(onLongPressActionBtn(gesture:)))
        let downGesture = LongPressActionGestureRecognizer(actionType: .moveDown, target: self, action: #selector(onLongPressActionBtn(gesture:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        
        rotateGesture.minimumPressDuration = 0.1
        upGesture.minimumPressDuration = 0.1
        downGesture.minimumPressDuration = 0.1
        
        rotateBtn.addGestureRecognizer(rotateGesture)
        upBtn.addGestureRecognizer(upGesture)
        downBtn.addGestureRecognizer(downGesture)
        sceneView.addGestureRecognizer(pinchGesture)
    }
    
    func onHeroSelected(selectedHeroName: HeroName) {
        self.selectedHeroName = selectedHeroName
        heroesPickerViewController?.dismiss(animated: true, completion: nil)
    }
    
    func placeHero(position: SCNVector3) {
        guard let nodeName = selectedHeroName else { return }
        let node = HeroNode(name: nodeName)
        node.position = position
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        sceneView.scene.rootNode.addChildNode(node)
        selectedHeroName = nil
        nodes.append(node)
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if heroesPickerViewController?.isViewLoaded ?? false && (heroesPickerViewController?.view.window != nil) {
            return
        }
        
        guard let touch = touches.first else { return }
        
        let results = sceneView.hitTest(touch.location(in: sceneView), types: [.featurePoint])
        guard let hitFeature = results.last else { return }
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        placeHero(position: hitPosition)
    }
}

//MARK: UI
extension HeroesPlacerViewController {
    
    private func setupUI() {
        setupSceneView()
        setupActionView()
    }
    
    private func setupSceneView() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        sceneView.scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(0, 0, 8)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .spot
        lightNode.position = SCNVector3(0, 5, 5)
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        focusView.isHidden = true
        focusView.center = focusPoint
        sceneView.addSubview(focusView)
        
        sceneView.delegate = self
    }
    
    private func setupActionView() {
        actionView.layer.cornerRadius = 15
        actionView.isHidden = true
    }
    
    func onSelectNode(heroNode: HeroNode) {
        
        heroNode.onSelectNode()
        
        showActionView()
        hideFocusView()
        
        if lastSelectedNode !== heroNode {
            lastSelectedNode?.onDeselectNode()
            lastSelectedNode = heroNode
        }
    }
    
    func onSelectionEnded() {
        
        hideActionView()
        
        lastSelectedNode?.onDeselectNode()
    }
    
    func showRings() {
        for heroNode in nodes {
            heroNode.isRingHidden = false
        }
    }
    
    func hideRings() {
        for heroNode in nodes {
            heroNode.isRingHidden = true
        }
    }
}

//MARK: @IBAction & Btns Handling
extension HeroesPlacerViewController {
    
    @IBAction func onPickAHeroBtnPressed(_ sender: Any) {
        heroesPickerViewController = HeroesPickerViewController(size: CGSize(width: view.bounds.width, height: 300))
        heroesPickerViewController!.modalPresentationStyle = .popover
        heroesPickerViewController!.popoverPresentationController?.delegate = self
        heroesPickerViewController!.heroesPlacerViewController = self
        present(heroesPickerViewController!, animated: true, completion: nil)
        heroesPickerViewController!.popoverPresentationController?.sourceView = sender as? UIView
    }
    
    @objc func onLongPressActionBtn(gesture: LongPressActionGestureRecognizer) {
        
        guard let heroNode = lastSelectedNode else { return }
        
        if gesture.state == .ended {
            heroNode.removeAllActions()
        } else if gesture.state == .began {
            addAction(heroNode: heroNode, actionType: gesture.actionType)
        }
    }
    
    private func addAction(heroNode: HeroNode, actionType: ActionType) {
        
        switch actionType {
            case .rotate:
                let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.1 * Double.pi), z: 0, duration: 0.1))
                heroNode.runAction(rotate)
            case .moveUp:
                let moveUp = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 0.1))
                heroNode.runAction(moveUp)
            case .moveDown:
                let moveDown = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 0.1))
                heroNode.runAction(moveDown)
            case .remove:
                nodes.removeAll { $0 === lastSelectedNode }
                lastSelectedNode?.removeFromParentNode()
                lastSelectedNode = nil
            case .scale:
                return
        }
    }
    
    @objc func handlePinchGesture(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        
        guard let heroNode = lastSelectedNode else { return }

        if recognizer.state == .changed && inEditMode {
            let pinchScaleX = Float(recognizer.scale) * heroNode.scale.x
            let pinchScaleY =  Float(recognizer.scale) * heroNode.scale.y
            let pinchScaleZ =  Float(recognizer.scale) * heroNode.scale.z
            
            heroNode.scale = SCNVector3(x: Float(pinchScaleX), y: Float(pinchScaleY), z: Float(pinchScaleZ))
            recognizer.scale = 1
        }
        
    }
    
    @IBAction func onRemoveActionBtnPressed(_ sender: Any) {
        
        guard let heroNode = lastSelectedNode else { return }
        addAction(heroNode: heroNode, actionType: .remove)
    }
    
    @IBAction func onEditBtnPressed(_ sender: Any) {
        hideEditBtn()
        hideHeroPickerBtn()
        showEditModeLbl()
        showFocusView()
        showCloseEditModeBtn()
        showRings()
        inEditMode = true
    }
    
    @IBAction func onCloseEditModeBtnPressed(_ sender: Any) {
        onSelectionEnded()
        showEditBtn()
        showHeroPickerBtn()
        hideEditModeLbl()
        hideFocusView()
        hideCloseEditModeBtn()
        hideRings()
        inEditMode = false
    }
}

//MARK: UIPopoverPresentationControllerDelegate
extension HeroesPlacerViewController : UIPopoverPresentationControllerDelegate {
    
}

//MARK: ARSCNViewDelegate
extension HeroesPlacerViewController : ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if !strongSelf.inEditMode { return }
            
            for node in strongSelf.nodes {
                
                let position = node.ringNode.convertPosition(SCNVector3Zero, to: nil)
                let projectedPoint = renderer.projectPoint(position)
                let projectedCGPoint = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
                let distance = projectedCGPoint.distance(to: strongSelf.focusPoint)
                if distance < 50 {
                    strongSelf.onSelectNode(heroNode: node)
                }
            }
        }
    }
}


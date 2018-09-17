//
//  ViewController.swift
//  instructor
//
//  Created by Morten Just Petersen on 7/31/18.
//  Copyright © 2018 Morten Just Petersen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var tvPlaneNode : SCNNode!
    var videoNode : SKVideoNode!
    
    var nodeToAdjust : SCNNode!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
//        sceneView.showsStatistics = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(rec:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(rec:)))

//        sceneView.addGestureRecognizer(pinch)
//        sceneView.addGestureRecognizer(pan)
        
        
        
        
        print("Setting videonode")
        
        self.videoNode = SKVideoNode(fileNamed: "xfinity02.mov")
        
//        nodeToAdjust = self.videoNode
        
        
        sceneView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap(rec:)))
        )
        
        
//        let testNode = SCNNode()
//        testNode.position.y = -0.2
//        addVideoNode(to: testNode)
//        sceneView.scene.rootNode.addChildNode(testNode)
    }
    
    
    @objc func didTap(rec recognizer: UITapGestureRecognizer){
        print("tapped")
        
        if let v = videoNode {
            v.play()
        }
    }
    
    @objc func didPinch(rec recognizer: UIPinchGestureRecognizer){
        
        if recognizer.state == .began || recognizer.state == .changed {
            let s = recognizer.scale
            let a = SCNAction.scale(by: s, duration: 0.0)
            recognizer.scale = 1
            nodeToAdjust.runAction(a)
            print("scale now: ")
            print(nodeToAdjust.scale)
        }
    }
    
    @objc func didPan(rec recognizer: UIPanGestureRecognizer){
        let t = recognizer.translation(in: sceneView)
        
        let scale = Float(0.00001)
        let a = SCNAction.move(by: SCNVector3Make(Float(-t.x)*scale , 0.0, Float(-t.y)*scale), duration: 0.0)
        nodeToAdjust.runAction(a)
        print("position now: ")
        print(nodeToAdjust.position)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        guard let refImg = ARReferenceImage.referenceImages(inGroupNamed: "AR", bundle: nil) else {
            fatalError("No group called that, sorry")
        }
        
        configuration.detectionImages = refImg
        configuration.maximumNumberOfTrackedImages = 15
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Did add a node")
        
        addVideoNode(to: node)
        
    }
    
    func addVideoNode(to node:SCNNode){
        let videoNode = SKVideoNode(fileNamed: "xfinity02.mov")
        self.videoNode = videoNode
        
        DispatchQueue.main.async {
            let skScene = SKScene(size: CGSize(width: 1080, height: 1920)) // 1.7
            
            //
            let effectNode = SKEffectNode()
            //        let filter = CIFilter(name: "CIEdgeWork") // pretty good
            //        filter?.setDefaults()
            //        filter?.setValue(1.5, forKey: "inputRadius")
            
            //            let filter = CIFilter(name: "CISpotColor") // pretty good
            //            filter?.setDefaults()
            //            let c = CIColor(color: UIColor(red:0.861, green:0.602, blue:0.505, alpha:1.000))
            //            filter?.setValue(c, forKey: "inputCenterColor1")
            //            let c2 = CIColor.blue
            //            filter?.setValue(c2, forKey: "inputReplacementColor1")
            //
            
            let filter = CIFilter(name: "CIColorMonochrome")
            filter?.setDefaults()
            filter?.setValue(CIColor.blue, forKey: "inputColor")
            
            
            effectNode.filter = filter
            
            effectNode.addChild(videoNode)
            
            // add to scene
            skScene.addChild(effectNode)
            
            self.videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
            self.videoNode.size = skScene.size
            
            
            // scene kit
            let tvPlane = SCNPlane(width: 0.221, height: 0.13)
            tvPlane.firstMaterial?.diffuse.contents = skScene
            //        tvPlane.firstMaterial?.blendMode = .screen
            tvPlane.firstMaterial?.isDoubleSided = true
            //        tvPlane.firstMaterial?.colorBufferWriteMask = [.blue ]
            
            tvPlane.cornerRadius = 0.015
            
            self.tvPlaneNode = SCNNode(geometry: tvPlane)
            self.tvPlaneNode.eulerAngles.x = .pi / 2
            self.tvPlaneNode.eulerAngles.y = -.pi / 2
            self.tvPlaneNode.opacity = 0.9
            
            self.tvPlaneNode.localTranslate(by: SCNVector3Make(0.053, 0, 0) )
            
            self.tvPlaneNode.position = SCNVector3Make(0.001483334, 1.8626451e-09, 0.025205001)
            self.tvPlaneNode.scale = SCNVector3Make(0.52119976, 0.52119976, 0.52119976)
            
            print("Tv plane node position")
            print(self.tvPlaneNode.position)
            
//            let textNode = SCNScene(named: "art.scnassets/instruction.scn")!.rootNode
//            node.addChildNode(textNode)

            
            //        let anchorNode = SCNScene(named: "art.scnassets/currency.scn")!.rootNode.childNodes[0]
//            node.addChildNode(self.tvPlaneNode)
            
            let drawingPlane = SCNPlane(width: 0.325, height: 0.22)
            let drawingNode = SCNNode()
//            drawingPlane.firstMaterial?.diffuse.contents
            drawingPlane.firstMaterial?.diffuse.contents = UIColor.clear
            drawingPlane.firstMaterial?.colorBufferWriteMask = [.blue, .green]
//            drawingPlane.firstMaterial?.blendMode = .multiply
            drawingNode.geometry = drawingPlane
            
            
            drawingNode.eulerAngles.x = -.pi / 2
            drawingNode.scale = SCNVector3(x: 0.7267225, y: 0.7267225, z: 0.7267225)
            drawingNode.position = SCNVector3(x: 0.006976659, y: 0.0, z: -0.012759991)

            node.opacity = 0.0
            node.addChildNode(drawingNode)
            node.runAction(SCNAction.fadeIn(duration: 1))
            self.startAddingDrawings(to: drawingNode)
            
            self.videoNode.play()
            self.nodeToAdjust = drawingNode // so we can scale and place it accordingly
        }
    }
    
    func startAddingDrawings(to node:SCNNode){
        print("startAdding")
        for i in 0...6 { // start 7 timers
            print("Scheduling timer for \(i)")
            Timer.scheduledTimer(withTimeInterval: TimeInterval(i * 3), repeats: false) { (timer) in
                
                // clone the original node's geo
                let newNode = SCNNode()
                newNode.geometry = node.geometry?.copy() as? SCNGeometry // don't share geo
                if let newMaterial = newNode.geometry?.materials.first?.copy() as? SCNMaterial {
                    //make changes to material
                    newNode.geometry?.materials = [newMaterial]
                }
                // set image and fade in
                let imageName = "written-instructions 0\(i)"
                print("Grabbing \(imageName)")
                let image = UIImage(named: imageName)!
                newNode.opacity = 0
                newNode.geometry?.firstMaterial?.diffuse.contents = image
                node.addChildNode(newNode)
                newNode.runAction(SCNAction.fadeIn(duration: 1))
            }
        }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: Add the video
    
    func addVideo(to position:SCNVector3){

    }
    
    
}

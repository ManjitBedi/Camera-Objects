//
//  GameViewController.swift
//  Camera&Objects
//
//  Created by Manjit Bedi on 2016-07-27.
//  Copyright © 2016 noorg. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var object1: SCNNode!
    var object2: SCNNode!
    var orbitNode: SCNNode!
    var centreNode: SCNNode!
    var waypointNode: SCNNode!
    var cameraNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = SCNScene(named: "art.scnassets/objects.scn") {
            let rootNode = scene.rootNode
            self.cameraNode = rootNode.childNode(withName: "camera", recursively: true)
            self.orbitNode = rootNode.childNode(withName: "orbitNode", recursively: true)!
            self.centreNode = rootNode.childNode(withName: "centreNode", recursively: true)!
            self.waypointNode = rootNode.childNode(withName: "waypointNode", recursively: true)!
            self.object1 = rootNode.childNode(withName: "shape1", recursively: true)!
            self.object2 = rootNode.childNode(withName: "shape2", recursively: true)!
            
            let lookAtConstraint = SCNLookAtConstraint(target: self.centreNode)
            lookAtConstraint.isGimbalLockEnabled = false
            self.cameraNode.constraints = [lookAtConstraint]
            
            // now apply some logic
            self.object2.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(M_PI), z: 0, duration: 2))
    
            self.object1.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(M_PI), z: 0, duration: 2)) {

                let lookAtConstraint = SCNLookAtConstraint(target: self.object1)
                lookAtConstraint.isGimbalLockEnabled = false
                self.cameraNode.constraints = [lookAtConstraint]
                
                let moveAction = SCNAction.move(to: self.waypointNode.position, duration: 5.0);
                self.orbitNode.runAction(moveAction){
                    let lookAtConstraint = SCNLookAtConstraint(target: self.object1)
                    lookAtConstraint.isGimbalLockEnabled = true
                    self.cameraNode.constraints = [lookAtConstraint]
                    let moveAction = SCNAction.move(to: self.centreNode.position, duration: 5.0);
                    self.orbitNode.runAction(moveAction){
                        self.cameraNode.constraints = nil
                    }
                }
            }
    
            // retrieve the SCNView
            let scnView = self.view as! SCNView
            
            // set the scene to the view
            scnView.scene = scene
            
            // allows the user to manipulate the camera
            scnView.allowsCameraControl = false
            
            // show statistics such as fps and timing information
            scnView.showsStatistics = true
            
            // configure the view
            scnView.backgroundColor = UIColor.white
            
            // add a tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            scnView.addGestureRecognizer(tapGesture)

        }
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.black
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .left {
            print("swipe left")
            self.cameraNode.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(M_PI), z: 0, duration: 0.5))
        } else {
             print("swipe right")
            self.cameraNode.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(-M_PI), z: 0, duration: 0.5))
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}

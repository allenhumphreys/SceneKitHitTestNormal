//
//  ViewController.swift
//  HitTestNormalApp
//
//  Created by Allen Humphreys on 8/30/17.
//  Copyright © 2017 blank. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!

    var scene: SCNScene {
        return sceneView.scene!
    }

    var redsphere: SCNNode!
    var bluesphere: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true

        redsphere = scene.rootNode.childNode(withName: "redsphere", recursively: true)
        bluesphere = scene.rootNode.childNode(withName: "bluesphere", recursively: true)
    }

    @IBAction func sceneTapped(_ sender: UITapGestureRecognizer) {

        let touchInScene = sender.location(in: sceneView)

        let results: [SCNHitTestResult] = sceneView.hitTest(touchInScene, options: nil)

        if let sphereHit = results.first(where: { $0.node.name == "bluesphere" }) {

            let redsphereCoordinates = bluesphere.convertPosition(sphereHit.localCoordinates, to: redsphere)

            addBlueStick(at: redsphereCoordinates, normal: sphereHit.worldNormal, targetNode: redsphere)
        }
    }

    @discardableResult
    func addBlueStick(at position: SCNVector3, normal: SCNVector3, targetNode: SCNNode) -> SCNNode {

        let height: CGFloat = 2.5
        let cylinder = SCNCylinder(radius: height/20, height: height)
        cylinder.firstMaterial!.diffuse.contents = UIColor.blue
        cylinder.firstMaterial!.specular.contents = UIColor.white

        let newNode = SCNNode(geometry: cylinder)
        newNode.pivot = SCNMatrix4MakeTranslation(0, -Float(height/2), 0)

        newNode.position = position

        let targetGLKQuaternion = GLKQuaternion(from: targetNode.worldTransform)
        let inWorldSpace = SCNVector3(0, 1, 0).rotation(to: normal)

        let finalOrientation = targetGLKQuaternion.inverted() * inWorldSpace

        newNode.orientation = SCNQuaternion(finalOrientation)

        targetNode.addChildNode(newNode)

        return newNode
    }
}

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

extension GLKVector3 {

    init(_ vector: SCNVector3) {
        self = SCNVector3ToGLKVector3(vector)
    }
}

extension GLKQuaternion {

    init(from matrix: SCNMatrix4) {
        self = GLKQuaternionMakeWithMatrix4(SCNMatrix4ToGLKMatrix4(matrix))
    }

    init(vector: VectorThree, scalar: Float) {
        let glkVector = GLKVector3Make(vector.x, vector.y, vector.z)

        self = GLKQuaternionMakeWithVector3(glkVector, scalar)
    }

    func inverted() -> GLKQuaternion {
        return GLKQuaternionInvert(self)
    }

    func normalized() -> GLKQuaternion {
        return GLKQuaternionNormalize(self)
    }
}

func * (left: GLKQuaternion, right: GLKQuaternion) -> GLKQuaternion {

    return GLKQuaternionMultiply(left, right)
}

extension SCNQuaternion {

    init(_ quaternion: GLKQuaternion) {

        self = SCNVector4(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
    }

    init(vector: SCNVector3, scalar: Float) {

        self = SCNVector4(vector.x, vector.y, vector.z, scalar)
    }
}

extension GLKVector3: VectorThree {
    init(x: Float, y: Float, z: Float) {
        self = GLKVector3Make(x, y, z)
    }
}

extension SCNVector3: VectorThree {
    init(x: Float, y: Float, z: Float) {
        self = SCNVector3(x, y, z)
    }
}

protocol VectorThree {
    var x: Float { get set }
    var y: Float { get set }
    var z: Float { get set }

    init(x: Float, y: Float, z: Float)
}

extension VectorThree {

    /**
     * Negates the vector described by SCNVector3 and returns
     * the result as a new SCNVector3.
     */
    func negated() -> VectorThree {
        return self * -1
    }

    /**
     * Returns the length (magnitude) of the vector described by the VectorThree
     */
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }

    func normalized() -> VectorThree {
        return self / length()
    }

    /**
     * Calculates the cross product between two VectorThree.
     */
    func cross(vector: VectorThree) -> VectorThree {
        return type(of: vector).init(x: y * vector.z - z * vector.y,
                                     y: z * vector.x - x * vector.z,
                                     z: x * vector.y - y * vector.x)
    }

    /**
     * Calculates the dot product between two VectorThree.
     */
    func dot(vector: VectorThree) -> Float {
        return x * vector.x + y * vector.y + z * vector.z
    }

    /**
     * Calculates the distance between two VectorThree. Pythagoras!
     */
    func distance(vector: VectorThree) -> Float {
        return (self - vector).length()
    }

    // based on: https://stackoverflow.com/a/1171995/5099014
    func rotation(to target: VectorThree) -> GLKQuaternion {

        let start = self
        let end = target
        let thing = pow(start.length(), 2) * pow(end.length(), 2)
        let scalar = sqrt(thing) + start.dot(vector: end)

        return GLKQuaternion(vector: start.cross(vector: end), scalar: scalar).normalized()
    }
}

func + (left: VectorThree, right: VectorThree) -> VectorThree {
    return type(of: left).init(x: left.x + right.x,
                               y: left.y + right.y,
                               z: left.z + right.z)
}

func * (vector: VectorThree, scalar: Float) -> VectorThree {
    return type(of: vector).init(x: vector.x * scalar,
                                 y: vector.y * scalar,
                                 z: vector.z * scalar)
}

func / (vector: VectorThree, scalar: Float) -> VectorThree {
    return type(of: vector).init(x: vector.x / scalar, y: vector.y / scalar, z: vector.z / scalar)
}

/**
 * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func - (left: VectorThree, right: VectorThree) -> VectorThree {
    return type(of: left).init(x: left.x - right.x,
                               y: left.y - right.y,
                               z: left.z - right.z)
}


func / (vector: SCNVector4, scalar: Float) -> SCNVector4 {
    return SCNVector4(vector.x / scalar, vector.y / scalar, vector.z / scalar, vector.w / scalar)
}



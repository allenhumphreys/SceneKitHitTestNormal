//
//  GLKQuaternion+Swift.swift
//  HitTestNormalApp
//
//  Created by Allen Humphreys on 8/31/17.
//  Copyright © 2017 blank. All rights reserved.
//

import SceneKit

extension GLKQuaternion {

    init(from matrix: SCNMatrix4) {
        self = GLKQuaternionMakeWithMatrix4(SCNMatrix4ToGLKMatrix4(matrix))
    }

    init(vector: GLKVector3, scalar: Float) {
        let glkVector = GLKVector3Make(vector.x, vector.y, vector.z)

        self = GLKQuaternionMakeWithVector3(glkVector, scalar)
    }

    init(angle: Float, axis: GLKVector3) {

        self = GLKQuaternionMakeWithAngleAndAxis(angle, axis.x, axis.y, axis.z)
    }

    func inverted() -> GLKQuaternion {
        return GLKQuaternionInvert(self)
    }

    func normalized() -> GLKQuaternion {
        return GLKQuaternionNormalize(self)
    }

    func conjugated() -> GLKQuaternion {
        return GLKQuaternionConjugate(self)
    }

    var axis: GLKVector3 {
        return GLKQuaternionAxis(self)
    }

    var angle: Float {
        return GLKQuaternionAngle(self)
    }

    func rotate(_ vector: GLKVector3) -> GLKVector3 {
        return GLKQuaternionRotateVector3(self, vector)
    }

    func rotate(_ vector: GLKVector4) -> GLKVector4 {
        return GLKQuaternionRotateVector4(self, vector)
    }

    static var identity: GLKQuaternion {
        return GLKQuaternionIdentity
    }
}

func * (left: GLKQuaternion, right: GLKQuaternion) -> GLKQuaternion {

    return GLKQuaternionMultiply(left, right)
}

func + (left: GLKQuaternion, right: GLKQuaternion) -> GLKQuaternion {

    return GLKQuaternionAdd(left, right)
}

func - (left: GLKQuaternion, right: GLKQuaternion) -> GLKQuaternion {

    return GLKQuaternionSubtract(left, right)
}

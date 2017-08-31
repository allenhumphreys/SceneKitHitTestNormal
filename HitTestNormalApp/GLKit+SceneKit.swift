//
//  GLKVector3+Swift.swift
//  HitTestNormalApp
//
//  Created by Allen Humphreys on 8/31/17.
//  Copyright © 2017 blank. All rights reserved.
//

import SceneKit

extension GLKVector3 {

    init(_ vector: SCNVector3) {
        self = SCNVector3ToGLKVector3(vector)
    }
}

extension SCNQuaternion {

    init(_ quaternion: GLKQuaternion) {

        self = SCNVector4(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
    }
}

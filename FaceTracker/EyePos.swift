//
//  EyePos.swift
//  FaceTracker
//
//  Created by Nivedh Mudiam on 6/9/21.
//

import Foundation


class EyePos: Decodable {
    
    var VideoName:String
    var FrameId:Int
    var FaceGridSize: Int
    var EstPosX:Double
    var EstPosY:Double
}

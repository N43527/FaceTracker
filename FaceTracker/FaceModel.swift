//
//  FaceModel.swift
//  FaceTracker
//
//  Created by Nivedh Mudiam on 7/14/21.
//

import Foundation

class FaceModel: ObservableObject{
    
    @Published var pitch: Int
    @Published var roll: Int
    @Published var yaw: Int
    
    init(pitch: Int, roll:Int, yaw: Int){
        self.pitch = pitch
        self.roll = roll
        self.yaw = yaw
    }
}

//
//  EyeModel.swift
//  FaceTracker
//
//  Created by Nivedh Mudiam on 6/12/21.
//

import Foundation

class EyeModel: ObservableObject{
    
    @Published var x_Value: Double
    @Published var y_Value: Double
    @Published var FaceGridSize: Double
    
    init(x: Double, y:Double, faceSize: Double){
        self.x_Value = x
        self.y_Value = y
        self.FaceGridSize = faceSize
    }
}

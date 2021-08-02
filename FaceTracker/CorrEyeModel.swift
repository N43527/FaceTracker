//
//  CorrEyeModel.swift
//  FaceTracker
//
//  Created by Nivedh Mudiam on 7/19/21.
//  Copyright © 2021 Anurag Ajwani. All rights reserved.
//

import Foundation

class CorrEyeModel: ObservableObject {
    
    @Published var corrXValue: Double
    @Published var corrYValue: Double
    
    init(corrX: Double, corrY:Double){
        self.corrXValue = corrX
        self.corrYValue = corrY
    }
}

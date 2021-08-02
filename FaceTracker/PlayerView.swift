//
//  PlayerView.swift
//  FaceTracker
//
//  Created by Nivedh Mudiam on 6/8/21.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    var fname:URL?
    var body: some View {
        if #available(iOS 14.0, *) {
            VideoPlayer(player: AVPlayer(url: fname!))
                                            
        } else {
            // Fallback on earlier versions
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}

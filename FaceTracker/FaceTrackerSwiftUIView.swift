//
//  FaceTrackerSwiftUIView.swift
//  FaceTracker
//
//  Created by Nivedh Mudiam on 6/8/21.
//
//

import SwiftUI


@available(iOS 14.0, *)
@main
struct FaceTracker_App:App{
    var body: some Scene{
        WindowGroup{
            FaceTrackerSwiftUIView()
        }
    }
}

struct FaceTrackerSwiftUIView: View {
   
    
    
    let isWorking = true
    @State var filename:URL?
//    @State var xval:Double = 0
//    @State var yval:Double = 0
    
    @ObservedObject var eyeModel = EyeModel(x: 0, y: 0, faceSize: 0.0)
    @ObservedObject var faceModel = FaceModel(pitch: 0, roll: 0, yaw: 0)
    @ObservedObject var oldFaceModel = FaceModel(pitch: 0, roll: 0, yaw: 0)
    @ObservedObject var corrEyeModel = CorrEyeModel(corrX: 0.0, corrY: 0.0)
    
    var test = 0.0
    
    
    var swiftuiController = SwiftUIViewController()

    
//    fileprivate func readJsonfromAssets() {
//        let asset = NSDataAsset(name: "test", bundle: Bundle.main)
//        do {
//            let decoder = JSONDecoder()
//            do {
//                let eyeData = try decoder.decode([EyePos].self, from: asset!.data)
//                for i in eyeData{
//                    xval = i.EstPosX
//                    yval = i.EstPosY
//                    print("x: \(xval)  y:\(yval) ")
//                }
//            }
//            catch {
//                print(error)
//            }
//
//
//        } catch {
//            print(error)
//        }
//    }
    
    
    // test function for reading mock json
//    private func readJsonfromApi(completion:@escaping ([EyePos])->() ){
//
//        guard let url = URL(string: "https://my-json-server.typicode.com/N43527/testjson/frames/") else { return }
//                URLSession.shared.dataTask(with: url) { (data, _, _) in
//                    let eyeData = try! JSONDecoder().decode([EyePos].self, from: data!)
//                    print(eyeData)
//
//                    for i in eyeData{
//                        xval = i.EstPosX
//                        yval = i.EstPosY
//                        print("x: \(xval)  y:\(yval) ")
//                    }
//                    self.xval = 0
//                    self.yval = 0
//
//                    DispatchQueue.main.async {
//                        completion(eyeData)
//                    }
//                }
//                .resume()
//    }
    
    
    var body: some View {
//        NavigationView {
            ZStack {
                ZStack {
                    VStack {
//                        Button("send") {
//                            print(self.swiftuiController.myViewController.frames)
//                            let av = UIActivityViewController(activityItems: self.swiftuiController.myViewController.frames, applicationActivities: nil)
//                            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
//                        }
                        HStack {
                            Spacer()
                            Text("Distance: \(63.6936 * (pow(0.995616, Double(eyeModel.FaceGridSize))))cm")
                                .foregroundColor((eyeModel.FaceGridSize > 45) ? ((eyeModel.FaceGridSize < 70) ? .green : (eyeModel.FaceGridSize < 80) ? .orange : .red) : .blue)
                                .padding(.top, 50)
//
                            Spacer()

                            Text("x:\(self.eyeModel.x_Value) y:\(self.eyeModel.y_Value) FaceGrid: \(self.eyeModel.FaceGridSize)")
                                .padding(.top, 50)
                            
                            
                            Spacer()
                            
                            Text("pitch:\(self.faceModel.pitch) roll:\(self.faceModel.roll) yaw: \(self.faceModel.yaw)" )
                                .padding(.top, 50)
                            
                            
                            Spacer()
                            
                            Text("corrX: \(self.corrEyeModel.corrXValue) corrY: \(self.corrEyeModel.corrYValue)")
                            
                            Spacer()
                            
                            Text("hori vel : \(self.faceModel.yaw - self.oldFaceModel.yaw) vert vel: \(self.faceModel.pitch - self.oldFaceModel.pitch)")
                            
                        }
                        Spacer()
                        
                        swiftuiController.hidden()
    //
    //                    Spacer()
                        
                        
                        Spacer()
                        
    //                    NavigationLink(destination: PlayerView(fname: filename)) {
    //                        Text("Play")
    //                    }
    //                    Spacer()
                    }
                    Text("•")
                        .foregroundColor((eyeModel.FaceGridSize > 45) ? ((eyeModel.FaceGridSize < 70) ? .green : (eyeModel.FaceGridSize < 80) ? .orange : .red) : .blue)
    //                    .position(x: CGFloat(swiftuiController.myViewController.xValue + 200), y: CGFloat(swiftuiController.myViewController.yValue * -1))
    //                    .position(x: CGFloat(320), y: CGFloat(547))
//                        .position(x: CGFloat(117.608132799 * (eyeModel.x_Value + 1.54207583937)), y: CGFloat(-91.1688466732 * (eyeModel.y_Value + 3.53224180883)))
                        
                        // this is iphone 12 (big)
//                        .position(x: CGFloat(107.608132799 * (eyeModel.x_Value + 1.84207583937)), y: CGFloat(-61.1688466732 * (eyeModel.y_Value + 0.25)))
//                        .position(x: CGFloat(60 * (eyeModel.x_Value + 2.74207583937)), y: CGFloat(-80 * (eyeModel.y_Value + 2.53224180883)))
                        // this is iphone SE (small)
//                        .position(x: CGFloat(60 * (eyeModel.x_Value + 1.24207583937)), y: CGFloat(-70 * (eyeModel.y_Value + 3.03224180883)))
                        
                        // x: CGFloat(80 * (eyeModel.x_Value - 0.7 + (0.09 * faceModel.yaw)) + 160)
                        // x: CGFloat((80 * eyeModel.x_Value) + (7.2 * faceModel.yaw) + 104)
                        
                        //.position(x: CGFloat(70 * (eyeModel.x_Value - 0.7) + 175), y: CGFloat(-50 * (eyeModel.y_Value + 6.5) + 250))    <- demo version
                        
                        
                        
                        
                        
//                        .position(x: CGFloat(80 * (eyeModel.x_Value - 0.7 + (0.09 * eyeModel.FaceGridSize)) + 160), y: CGFloat(-50 * (eyeModel.y_Value + 6.5) + 250))
                        .position(x: CGFloat(self.corrEyeModel.corrXValue), y: CGFloat(self.corrEyeModel.corrYValue))
                        
                        
                        
                        
                        
//                        .position(x: CGFloat(55 * (eyeModel.x_Value + 2.24207583937)), y: CGFloat(-80 * (eyeModel.y_Value + 3.03224180883)))
                        .font(.system(size: 100.0))
                }

                VStack {
                    Spacer()
                    Text("UP")
                        .font(.system(size: 20.0))
                        .background(faceModel.pitch > 10 ? Color.green: Color.black)
                        .padding(.top, 80)
                    Spacer()
                    HStack {
                        Spacer()
                        Text("LEFT")
                            .font(.system(size: 20.0))
                            .background(faceModel.yaw < -20 ? Color.green: Color.black)
//                            .foregroundColor(faceModel.yaw < -20 ? .green: .black)
                        Spacer()
                        Text("•")
                            .font(.system(size: 100.0))
                        Spacer()
                        Text("RIGHT")
                            .font(.system(size: 20.0))
                            .background(faceModel.yaw > 15 ? Color.green: Color.black)
//                            .foregroundColor(faceModel.yaw > 20 ? .green: .black)
                        Spacer()
                    }
                    Spacer()
                    Text("DOWN")
                        .font(.system(size: 20.0))
                        .background(faceModel.pitch < -25 ? Color.green: Color.black)
//                        .foregroundColor(faceModel.pitch < -20 ? .green: .black)
                        .padding(.bottom, 40)
                    Spacer()

                }
            
            }.onAppear() {
                print("hi")
                swiftuiController.myViewController.eye_Model = self.eyeModel
                swiftuiController.myViewController.face_Model = self.faceModel
                swiftuiController.myViewController.oldFace_Model = self.oldFaceModel
                swiftuiController.myViewController.corrEye_Model = self.corrEyeModel
                //readJsonfromAssets()66
//                readJsonfromApi { (t) in
//                    //self.dumbPos = t
//                }

            }
        }
//    }
}

struct FaceTrackerSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FaceTrackerSwiftUIView()
    }
}


struct SwiftUIViewController: UIViewControllerRepresentable {
    public var myViewController = ViewController()
    
    
    func makeUIViewController(context: Context) -> ViewController {
            return myViewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
    }
    
}




//
//  ViewController.swift
//  FaceTracker
//
//

import UIKit
import AVFoundation
import Vision
import Alamofire

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
                    print ( "video Url = \(outputURL.absoluteString)" )
                    print("Error recording movie: \(error!.localizedDescription)")
                
                } else {
                
                    let videoRecorded = outputURL! as URL
                    print ( "video Url = \(outputURL.absoluteString)" )
                    //performSegue(withIdentifier: "showVideo", sender: videoRecorded)
                
                }
    }
    
    var xValue = 0.0
    var yValue = 0.0
    var FaceGridSize:Int = 0
    
    var eye_Model = EyeModel(x: 0, y: 0, faceSize: 0)
    
    var pitchValue:Int = 0
    var rollValue:Int = 0
    var yawValue:Int = 0
    
    var face_Model = FaceModel(pitch: 0, roll: 0, yaw: 0)
    
    
    var oldPitchValue:Int = 0
    var oldRollValue:Int = 0
    var oldYawValue:Int = 0
    
    var oldFace_Model = FaceModel(pitch: 0, roll: 0, yaw: 0)
    
    var corrXValue = 0.0
    var corrYValue = 0.0
    
    var corrEye_Model = CorrEyeModel(corrX: 0.0, corrY: 0.0)
    
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var filename: URL!
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var drawings: [CAShapeLayer] = []
    
    var frames: [URL] = []
    
    var count:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCameraInput()
        self.showCameraFeed()
        self.getCameraFrames()
        self.captureSession.startRunning()
//        self.startRecording()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopRecording()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.frame
//        print(self.previewLayer.frame)
        
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.detectFace(in: frame)
        count += 1
//        print(count)
        if count % 10 == 0 {
            let image = UIImage(ciImage: CIImage(cvPixelBuffer: frame)) //  Here you have UIImage
            if let data = image.jpegData(compressionQuality: 0.8) {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "yyyyMMdd_HHmmss"
                let datetime = formatter.string(from: Date())

//                print("FILENAME => swift_file_\(datetime).jpg")
                
                self.filename = getDocumentsDirectory().appendingPathComponent("swift_file_\(datetime)_\(count).jpg")
                try? data.write(to: filename)
                self.sendFrameAndGetPoint(data)
                self.frames.append(self.filename!)
//                print(filename)
//                print("*********** took picture")
            }
        }

        //print(frame)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    

    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .front).devices.first else {
                fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
        self.activeInput = cameraInput
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.frame
//        print("here: \(self.previewLayer.frame)")
    }
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
//        self.captureSession.addOutput(self.movieOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
//        print("in camera frames")
    }
    
    
    private func tempURL() -> URL? {
            let directory = NSTemporaryDirectory() as NSString
        
            if directory != "" {
                let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
                return URL(fileURLWithPath: path)
            }
        
            return nil
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
//            orientation = AVCaptureVideoOrientation.landscapeLeft
            orientation = AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown:
//            orientation = AVCaptureVideoOrientation.portraitUpsideDown
            orientation = AVCaptureVideoOrientation.portrait
        default:
//            orientation = AVCaptureVideoOrientation.landscapeRight
            orientation = AVCaptureVideoOrientation.portrait
        }
        
        return orientation
    }
    
    func startRecording() {
        
            if movieOutput.isRecording == false {
            
                let connection = movieOutput.connection(with: AVMediaType.video)
            
                if (connection?.isVideoOrientationSupported)! {
                    connection?.videoOrientation = currentVideoOrientation()
                }
            
                if (connection?.isVideoStabilizationSupported)! {
                    connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                }
            
                let device = activeInput.device
            
                if (device.isSmoothAutoFocusSupported) {
                
                    do {
                        try device.lockForConfiguration()
                        device.isSmoothAutoFocusEnabled = false
                        device.unlockForConfiguration()
                    } catch {
                       print("Error setting configuration: \(error)")
                    }
                
                }
            
                //EDIT2: And I forgot this
                outputURL = tempURL()
                movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
                }
                else {
                    stopRecording()
                }
        
           }

    func stopRecording() -> URL? {

       if movieOutput.isRecording == true {
           movieOutput.stopRecording()
           return outputURL!
        }
        return nil
    }
    
    private func processModels() {
        self.corrEye_Model.corrXValue = 80.0 * (self.xValue - 0.7 + (0.09 * Double(self.yawValue))) + 160.0
//        self.corrEye_Model.corrYValue = self.yValue + Double(self.pitchValue)
        self.corrEye_Model.corrYValue = -50.0 * (self.yValue + 7) + 280
        
        self.corrXValue = self.corrEye_Model.corrXValue
        self.corrYValue = self.corrEye_Model.corrYValue
        
        print(self.corrXValue)
        print(self.corrYValue)
    }
    
    private func sendFrameAndGetPoint(_ imageData: Data) {
//        print("in sendFrame")

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let datetime = formatter.string(from: Date())

//        print("FILENAME => swift_file_\(datetime).jpg")
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "file", fileName: "swift_file_\(datetime).png", mimeType: "image/png")
        }, to: "http://18.219.195.64/itracker")
//        .cURLDescription{ description in
//            print(description)
//        }
        .responseJSON { response in
            debugPrint(response)
            switch response.result {
                    case .success:
//                        print("Post Successful")
                        do  {
//                            print(response.data!)
                            let eyeData = try JSONDecoder().decode([EyePos].self, from: response.data!)
                            print(eyeData)
                            for e in eyeData{
                                self.xValue = e.EstPosX
                                self.yValue = e.EstPosY
                                self.FaceGridSize = e.FaceGridSize

                                self.eye_Model.x_Value = e.EstPosX
                                self.eye_Model.y_Value = e.EstPosY
                                self.eye_Model.FaceGridSize = Double(e.FaceGridSize)
                                
                                self.processModels()
                            }
                        } catch {
                            print("bad")
                        }
                    case let .failure(error):
                        print("Eye Pos error-----\(error)")
                        self.xValue = Double.random(in: 1...5)
                        self.yValue = Double.random(in: 1...5)
                        print(self.xValue)
                        print(self.yValue)
            }
        }
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "file", fileName: "swift_file_\(datetime).png", mimeType: "image/png")
        }, to: "http://18.219.195.64:1080/whenet")
//        .cURLDescription{ description in
//            print(description)
//        }
        .responseJSON { response in
            debugPrint(response)
            switch response.result {
                    case .success:
//                        print("Post Successful")
                        do  {
//                            print(response.data!)
                            let facePosData = try JSONDecoder().decode([FacePos].self, from: response.data!)
                            print(facePosData)
                            for face in facePosData{
                                self.oldPitchValue = self.pitchValue
                                self.oldRollValue = self.rollValue
                                self.oldYawValue = self.yawValue
                                
                                self.oldFace_Model.pitch = self.face_Model.pitch
                                self.oldFace_Model.roll = self.face_Model.roll
                                self.oldFace_Model.yaw = self.face_Model.yaw
                                
                                self.pitchValue = face.pitch
                                self.rollValue = face.roll
                                self.yawValue = face.yaw
                                
                                self.face_Model.pitch = face.pitch
                                self.face_Model.roll = face.roll
                                self.face_Model.yaw = face.yaw
                            }
                        } catch {
                            print("bad")
                        }
                    case let .failure(error):
                        print("Face Pos error-----\(error)")
            }
        }
        
        
        
    }
    
    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionResults(results)
                } else {
                    self.clearDrawings()
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        
        self.clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            var newDrawings = [CAShapeLayer]()
            newDrawings.append(faceBoundingBoxShape)
            if let landmarks = observedFace.landmarks {
                newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
            }
            return newDrawings
        })
        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
        self.drawings = facesBoundingBoxes
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
    private func drawFaceFeatures(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) -> [CAShapeLayer] {
        var faceFeaturesDrawings: [CAShapeLayer] = []
        if let leftEye = landmarks.leftEye {
            let eyeDrawing = self.drawEye(leftEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        if let rightEye = landmarks.rightEye {
            let eyeDrawing = self.drawEye(rightEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        // draw other face features here
        return faceFeaturesDrawings
    }
    private func drawEye(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> CAShapeLayer {
        let eyePath = CGMutablePath()
        let eyePathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x,
                    y: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y)
            })
        eyePath.addLines(between: eyePathPoints)
        eyePath.closeSubpath()
        let eyeDrawing = CAShapeLayer()
        eyeDrawing.path = eyePath
        eyeDrawing.fillColor = UIColor.clear.cgColor
        eyeDrawing.strokeColor = UIColor.green.cgColor
//        print(eyeDrawing)
        return eyeDrawing
    }
}

//
//  RTCPeer.swift
//  VTV_Stream
//
//  Created by Admin on 6/22/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import WebRTC
import SocketRocket

class RTCPeer: NSObject{

    var webRTCPeer: NBMWebRTCPeer!
    private let settingsModel: RTCCapturerSettingsModel
    var streamViewController: StreamViewController!
    var localVideoStreaming: RTCVideoRenderer!
    var capturer: RTCCameraVideoCapturer!
    private let client: WebRTCClient
    private var nICECandidateSocketSendCount: Int = 0
    private var backCamera: Bool = false
    private var sessionId: String = ""
    let isCreator: Bool
    init(client: WebRTCClient, sessionId: String, isCreator: Bool) {
        self.client = client
        self.sessionId = sessionId
        self.isCreator = isCreator
        settingsModel = RTCCapturerSettingsModel()
        super.init()
        let mediaConfig = NBMMediaConfiguration.default()
        self.webRTCPeer = NBMWebRTCPeer(delegate: self, configuration: mediaConfig)
        
    }
    func selectCamera(backCamera: Bool){
        let abc = NSString()
        self.backCamera = backCamera
        let cameraPosition = backCamera ? NBMCameraPosition.back : NBMCameraPosition.front
        if webRTCPeer.hasCameraPositionAvailable(cameraPosition){
            webRTCPeer.selectCameraPosition(cameraPosition)
        }
    }
    func geterateOffer(id: String){
        self.sessionId = id
        self.webRTCPeer.generateOffer(id)
    }
    func processAnswer(sdpAnswer: String){
        self.webRTCPeer.processAnswer(sdpAnswer, connectionId: sessionId)
    }
    func addICECandidate(candidate: RTCIceCandidate){
        self.webRTCPeer.add(candidate, connectionId: sessionId)
    }
    func getStringForSocletReadyState(readyState: SRReadyState)->String{
        switch readyState {
        case .CONNECTING:
            return "Socket Connecting"
        case .OPEN:
            return "Socket Open"
        case .CLOSING:
            return "Socket Closing"
        case .CLOSED:
            return "Socket Closed"
        default:
            return "Socket State Unknown"
        }
        
    }
    func converDataToString(data:[String:Any])->String{
        if let theJSONData = try? JSONSerialization.data(withJSONObject: data,options: []),
            let theJSONText = String(data: theJSONData,encoding: .utf8) {
                return theJSONText
            }
        return ""
    }
}
extension RTCPeer: NBMWebRTCPeerDelegate{
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didCreateLocalFileCapturer fileCapturer: RTCFileVideoCapturer!) {
        print("setup file video capturer")
        if let _ = Bundle.main.path( forResource: "sample.mp4", ofType: nil ) {
            fileCapturer.startCapturing(fromFileNamed: "sample.mp4") { (err) in
                print(err)
            }
        }else{
            print("file did not faund")
        }
    }
    
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didCreateLocalCapturer capturer: RTCCameraVideoCapturer!) {
        print("didCreateLocalCapturer")
        let localRenderer = self.renderLocalVideoView()
        self.localVideoStreaming = localRenderer
        
        
        self.capturer = capturer
        let position: AVCaptureDevice.Position = AVCaptureDevice.Position.front
        guard let device = self.findDeviceForPosition(position: position) else { return }

        let format = self.selectFormatForDevice(device: device)
        let fps = 60
        print("fps: \(fps)")
        capturer.startCapture(with: device,
                                          format: format,
                                          fps: fps)
        
    }
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
            let position: AVCaptureDevice.Position = AVCaptureDevice.Position.front
            guard let device = self.findDeviceForPosition(position: position) else { return }

                        let format = self.selectFormatForDevice(device: device)
            //            let fps = self.selectFpsForFormat(format: format)
                        let fps = 10
                        print("fps: \(fps)")
                        capturer.startCapture(with: device,
                                              format: format,
                                              fps: fps)

        }
    func webrtcPeer(_ peer: NBMWebRTCPeer!, iceStatusChanged state: RTCIceConnectionState, of connection: NBMPeerConnection!) {
        //
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateOffer sdpOffer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        print("didGenerateOffer")
        var payload = [String: Any]()
        payload["id"] = self.isCreator ? "presenter":"viewer"
        payload["session"] = self.sessionId
        payload["sdpOffer"] = sdpOffer.description
        self.client.sendMessage(message: self.converDataToString(data: payload))
               
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateAnswer sdpAnswer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        print("didGenerateAnswer")
       
        
        
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, hasICECandidate candidate: RTCIceCandidate!, for connection: NBMPeerConnection!) {
        print("hasICECandidate")
        var payload = [String: Any]()
        payload["sdpMLineIndex"] = candidate.sdpMLineIndex
        payload["sdpMid"] = candidate.sdpMid
        payload["candidate"] = candidate.sdp
        let message: [String: Any] = ["id": "onIceCandidate", "candidate": payload]
        self.client.sendMessage(message: self.converDataToString(data: message))
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        print("didAdd remoteStream")
        if !self.isCreator{
            self.client.didAddRemoteStream(mediaStream: remoteStream)
        }
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didRemove remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        print("didRemove remoteStream")
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd dataChannel: RTCDataChannel!) {
       print("didAdd dataChannel")
    }
    
    
}

private extension RTCPeer {
    func findDeviceForPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let captureDevices = RTCCameraVideoCapturer.captureDevices()
        for device in captureDevices {
            if device.position == position {
                return device
            }
        }
        return captureDevices.first
    }

    func selectFpsForFormat(format: AVCaptureDevice.Format) -> Int {
        var maxFramerate: Float64 = 0

        for fpsRange in format.videoSupportedFrameRateRanges {
            maxFramerate = fmax(maxFramerate, fpsRange.maxFrameRate)
        }

        return Int(maxFramerate)
    }

    func selectFormatForDevice(device: AVCaptureDevice) -> AVCaptureDevice.Format {
        let supportedFormats = RTCCameraVideoCapturer.supportedFormats(for: device)
        let targetWidth = self.settingsModel.currentVideoResolutionWidthFromStore
        let targetHeight = self.settingsModel.currentVideoResolutionHeightFromStore

        var selectedFormat: AVCaptureDevice.Format? = nil
        var currentDiff = INT_MAX

        for format in supportedFormats {
            let dimension: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let diff = abs(targetWidth - Int(dimension.width)) + abs(targetHeight - Int(dimension.height));
            if diff < currentDiff {
                selectedFormat = format
                currentDiff = Int32(diff)
            }
        }
        return selectedFormat!
    }
    
    private func renderLocalVideoView()->RTCVideoRenderer{
        #if arch(arm64)
            // Using metal (arm64 only)
        let localRenderer = RTCMTLVideoView(frame: self.streamViewController.streamingVideoView.frame)
            localRenderer.videoContentMode = .scaleAspectFill
        #else
            // Using OpenGLES for the rest
        let localRenderer = RTCEAGLVideoView(frame: self.streamViewController.streamingVideoView.frame)
        #endif
        return localRenderer
    }
}

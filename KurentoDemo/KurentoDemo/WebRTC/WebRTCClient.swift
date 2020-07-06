//
//  WebRTCClient.swift
//  VTV_Stream
//
//  Created by Admin on 6/22/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import SocketRocket
import WebRTC

enum TransportChannelState{
    case opening
    case open
    case closing
    case closed
}
enum CallState: Int{
    case stream = 1
    case none = 0
}

class WebRTCClient: NSObject{
    static let shared = WebRTCClient()
    
    private let kChannelTimeoutInterval: TimeInterval = 5.0;
    private let kChannelKeepaliveInterval: TimeInterval = 20.0;
    private var keepAliveTimer: Timer?
    weak var delegate: WebRTCDelegate?
    private var rtcPeer: RTCPeer?
    var streamViewController: StreamViewController!
    private var channelState: TransportChannelState = .closed
    private var callState: CallState = .none
    private var sessionId: String = ""
    private var localStream: RTCMediaStream!
    private var localRenderer: NBMRenderer!
    private var remoteStream: RTCMediaStream!
    private var remoteRenderer: NBMRenderer!
    private let webSocket: SRWebSocket
    private var backCamera: Bool = false
    var type: TypeWebRTC = TypeWebRTC.oneToOne
    override init() {
        let url = URL(string: KurentoConfig.urlString + type.path)
        self.channelState = .closed
        let request: URLRequest = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: kChannelTimeoutInterval)
        let wSocket = SRWebSocket(urlRequest: request, protocols: ["chat"], allowsUntrustedSSLCertificates: true)
        let queue = DispatchQueue.init(label: "eu.nubomedia.websocket.processing", qos: .background, attributes: .concurrent, autoreleaseFrequency: .never, target: nil)
        wSocket?.setDelegateDispatchQueue(queue)
        wSocket?.open()
        self.webSocket = wSocket!
        super.init()
        self.webSocket.delegate = self
        
    }
    func createStream(sessionId: String){
        if channelState != .open{
            self.delegate?.onSocketNotReady()
        }
        if self.callState != .none{
            return
        }
        self.callState = .stream
        self.rtcPeer = RTCPeer(client: self, sessionId: sessionId, isCreator: true)
        self.rtcPeer?.streamViewController = streamViewController
        self.sessionId = sessionId
        if rtcPeer?.webRTCPeer.startLocalMedia() ?? false{
            rtcPeer?.selectCamera(backCamera: false)
            self.localStream = rtcPeer?.webRTCPeer.localStream
            if let render = self.renderForStream(stream: self.localStream){
                self.localRenderer = render
                self.delegate?.onAddLocalStream(videoView: self.localRenderer.rendererView)
            }
        }
        rtcPeer?.geterateOffer(id: sessionId)
    }
    func viewStream(sessionId: String){
        if channelState != .open{
            self.delegate?.onSocketNotReady()
            return
        }
        if self.callState != .none{
            return
        }
        callState = .stream
        self.rtcPeer = RTCPeer(client: self, sessionId: sessionId, isCreator: false)
        self.sessionId = sessionId
        rtcPeer?.geterateOffer(id: sessionId)

        
    }
    func renderForStream(stream: RTCMediaStream)->NBMEAGLRenderer?{
        let videoTrack = stream.videoTracks.first
        let render = NBMEAGLRenderer(delegate: self)
        render?.videoTrack = videoTrack
        return render
    }
    func stopStream(){
        let param = ["id": "stop"]
        self.sendMessage(message: Convert.dataToString(data: param))
        self.stopCommunication()
    }
    
    func sendMessage(message: String){
        guard channelState == .open else {
            print("WebSocket not ready")
            return
        }
        self.webSocket.send(message)
    }
    func didAddRemoteStream(mediaStream: RTCMediaStream){
        self.remoteStream = mediaStream
        guard let render = self.renderForStream(stream: mediaStream) else {return}
        self.remoteRenderer = render
        self.delegate?.onAddRemoteStream(videoView: self.remoteRenderer.rendererView)
    }
    func switchCamera(){
        self.backCamera.toggle()
        self.rtcPeer?.selectCamera(backCamera: self.backCamera)
        if callState != .none{
            self.localStream = rtcPeer?.webRTCPeer.localStream
            guard let render = self.renderForStream(stream: self.localStream) else {return}
            self.localRenderer = render
            self.delegate?.onAddLocalStream(videoView: self.localRenderer.rendererView)
            
        }
    }
}

extension WebRTCClient: SRWebSocketDelegate{
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        print("didReceiveMessage")
        guard let message = message as? String else {return}
        DispatchQueue.main.async {
            guard let objectData = message.data(using: String.Encoding.utf8) else{
                return
            }
            do {
                guard let messageDict = try JSONSerialization.jsonObject(with: objectData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                guard let id = messageDict["id"] as? String else {return}
                switch id{
                case "presenterResponse":
                    self.presenterResponse(message: messageDict)
                case "viewerResponse":
                    self.viewerResponse(message: messageDict)
                case "stopCommunication":
                    self.stopCommunication()
                case "iceCandidate":
                    self.iceCandidate(message: messageDict)
                default:
                    break
                }

            } catch {
                // Handle error
                print(error)
            }
        }
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        DispatchQueue.main.async {
            self.channelState = .open
            self.scheduleTimer()
        }
    }
}
extension WebRTCClient{
    private func scheduleTimer(){
        self.invalidateTimer()
        let timer = Timer(timeInterval: self.kChannelKeepaliveInterval, target: self, selector: #selector(handlePingTimer), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        self.keepAliveTimer = timer
    }
    private func invalidateTimer(){
        self.keepAliveTimer?.invalidate()
        self.keepAliveTimer = nil
    }
    @objc private func handlePingTimer(){
        self.sendPing()
        self.scheduleTimer()
    }
    private func sendPing(){
        if webSocket.readyState == .OPEN{
            self.webSocket.sendPing(nil)
        }
    }
}
extension WebRTCClient: NBMRendererDelegate{
    func renderer(_ renderer: NBMRenderer!, streamDimensionsDidChange dimensions: CGSize) {
        print("rennder ra day")
    }
    
    func rendererDidReceiveVideoData(_ renderer: NBMRenderer!) {
        //
    }
    
    
}
extension WebRTCClient{
    private func presenterResponse(message: [String: Any]){
        guard let response = message["response"] as? String else {return}
        if response == "accepted"{
            if let sdpAnswer = message["sdpAnswer"] as? String{
                self.rtcPeer?.processAnswer(sdpAnswer: sdpAnswer)
                self.delegate?.onStreamCreated()
            }
        }else{
            self.callState = .none
            let messageString = message["message"] as? String ?? "Loi khong xac dinh"
            self.delegate?.onCreateFailed(message: messageString)
        }
    }
    private func viewerResponse(message: [String: Any]){
        guard let response = message["response"] as? String else {return}
        if response == "accepted"{
            if let sdpAnswer = message["sdpAnswer"] as? String{
                self.rtcPeer?.processAnswer(sdpAnswer: sdpAnswer)
                self.delegate?.onStreamCreated()
            }
        }else{
            self.callState = .none
            let messageString = message["message"] as? String ?? "Loi khong xac dinh"
            self.delegate?.onCreateFailed(message: messageString)
        }
    }
    private func iceCandidate(message: [String: Any]){
        guard let cadidateObject = message["candidate"] as? [String: Any] else {return}
        guard let sdpMid = cadidateObject["sdpMid"] as? String else {return}
        guard let sdpMLineIndex = cadidateObject["sdpMLineIndex"] as? Int32 else {return}
        let candidate = RTCIceCandidate(sdp: sdpMid, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
        rtcPeer?.addICECandidate(candidate: candidate)
    }
    private func stopCommunication(){
        self.callState = .none
        self.delegate?.onStopCommunication()
        if rtcPeer?.isCreator ?? false{
            self.localStream = nil
            self.localRenderer = nil
            self.delegate?.onRemoveLocalStream()
        }else{
            self.remoteStream = nil
            self.remoteRenderer = nil
            self.delegate?.onRemoveRemoteStream()
        }
    }
    
}
extension WebRTCClient{
    func register(name: String){
        let params = ["id": "register", "name": name]
        let messageString = Convert.dataToString(data: params)
        self.rtcPeer = RTCPeer(client: self, sessionId: "", isCreator: false)
        rtcPeer.con
    }
}

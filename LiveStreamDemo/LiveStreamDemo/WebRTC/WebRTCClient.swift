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
    var delegate: WebRTCDelegate?
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
    override init() {
        
        let url = URL(string: "https://192.168.1.157:8443/one2many")
        let webSocket = SRWebSocket(url: url!, protocols: ["chat"])
        let queue = DispatchQueue.init(label: "eu.nubomedia.websocket.processing", qos: .background, attributes: .concurrent, autoreleaseFrequency: .never, target: nil)
        webSocket?.setDelegateDispatchQueue(queue)
        
        webSocket?.open()
        self.webSocket = webSocket!
        super.init()
        webSocket?.delegate = self
        
    }
    func createStream(sessionId: String){
//
        
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
//        if channelState != .open{
//            self.delegate?.onSocketNotReady()
//            return
//        }
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
        self.sendMessage(message: self.converDataToString(data: param))
        self.stopCommunication()
    }
    func converDataToString(data:[String:Any])->String{
        if let theJSONData = try? JSONSerialization.data(withJSONObject: data,options: []),
            let theJSONText = String(data: theJSONData,encoding: .utf8) {
                return theJSONText
            }
        return ""
    }
    func sendMessage(message: String){
        if channelState == .open{
            print("send message: \(message)")
            self.webSocket.send(message)
        }
    }
    func didAddRemoteStream(mediaStream: RTCMediaStream){
        self.remoteStream = mediaStream
        guard let render = self.renderForStream(stream: mediaStream) else {return}
        self.remoteRenderer = render
        self.delegate?.onAddRemoteStream(videoView: self.remoteRenderer.rendererView)
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
        guard let sdp = cadidateObject["candidate"] as? String else {return}
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

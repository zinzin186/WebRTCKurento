//
//  ViewController.swift
//  LiveStreamDemo
//
//  Created by NamViet on 6/23/20.
//  Copyright © 2020 Dinh Le. All rights reserved.
//

import UIKit
import Starscream


class ViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    
    
    // localVideoStreaming: RTCVideoRenderer!
   // private let webRTCClient: WebRTCClient
    
    var socket:WebSocket!
    var isConnected:Bool = false
    private var localVideoTrack: RTCVideoTrack?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //createWebSocket()

    }

    func createWebSocket() {
        var request = URLRequest(url: URL(string: "https://192.168.51.18:8443/one2many")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
    }
    
    func createKurentoWebRTCPeer() {
        let mediaConfig = NBMMediaConfiguration.default()
        
        let webRtcPeer = NBMWebRTCPeer.init(delegate: self, configuration: mediaConfig)
        let isMediaStarted = webRtcPeer?.startLocalMedia()
        if isMediaStarted ?? false{
            webRtcPeer?.selectCameraPosition(.back)
        }
   
    }
    
    
    
    
    @IBAction func clickPresent(_ sender: Any) {
        let vc = StreamViewController(nibName: "StreamViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func clickViewer(_ sender: Any) {
        let vc = ViewerViewController.init(nibName: "ViewerViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickStop(_ sender: Any) {
    }
}


extension ViewController : NBMWebRTCPeerDelegate {
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didCreateLocalFileCapturer fileCapturer: RTCFileVideoCapturer!) {
        //
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didCreateLocalCapturer capturer: RTCCameraVideoCapturer!) {
        print("didCreateLocalCapturer")
    }
    
   
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateOffer sdpOffer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didGenerateAnswer sdpAnswer: RTCSessionDescription!, for connection: NBMPeerConnection!) {
        
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, hasICECandidate candidate: RTCIceCandidate!, for connection: NBMPeerConnection!) {
        
    }
    
    func webrtcPeer(_ peer: NBMWebRTCPeer!, iceStatusChanged state: RTCIceConnectionState, of connection: NBMPeerConnection!) {
        
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didRemove remoteStream: RTCMediaStream!, of connection: NBMPeerConnection!) {
        
    }
    
    func webRTCPeer(_ peer: NBMWebRTCPeer!, didAdd dataChannel: RTCDataChannel!) {
        
    }
    
    
}

extension ViewController : WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print("erorr: \(String(describing: error))")
        }
    }
}

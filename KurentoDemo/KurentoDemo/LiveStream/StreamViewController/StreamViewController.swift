//
//  StreamViewController.swift
//  VTV_Stream
//
//  Created by Admin on 6/22/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class StreamViewController: UIViewController {

    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var streamingVideoView: UIView!
    private var localVideo: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        WebRTCClient.shared.delegate = self
        WebRTCClient.shared.streamViewController = self
        self.createStreaming()
    }

    @IBAction func startStreaming(_ sender: Any) {
        self.createStreaming()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebRTCClient.shared.stopStream()
    }
    private func createStreaming(){
        let interval = Date().timeIntervalSince1970
        let sessionId = "\(interval)"
        self.sessionLabel.text = sessionId
        WebRTCClient.shared.createStream(sessionId: sessionId)
    }
    @IBAction func finishStreaming(_ sender: Any) {
        WebRTCClient.shared.stopStream()
    }
    
}
extension StreamViewController: WebRTCDelegate{
    func onStreamCreated() {
        //
    }
    
    func onStopCommunication() {
        //
    }
    
    func onAddLocalStream(videoView: UIView) {
        if localVideo != nil{
            localVideo?.removeFromSuperview()
        }
        self.localVideo = videoView
        self.streamingVideoView.addSubview(self.localVideo!)
        self.localVideo?.frame = self.streamingVideoView.bounds
    }
    
    func onRemoveLocalStream() {
        if localVideo != nil{
            localVideo?.removeFromSuperview()
        }
        localVideo = nil
    }
    
    func onAddRemoteStream(videoView: UIView) {
        //
    }
    
    func onRemoveRemoteStream() {
        //
    }
    
    func onCreateFailed(message: String) {
        //
    }
    
    func onViewFailed(message: String) {
        //
    }
    
    func onSocketOpenFailed() {
        //
    }
    
    func onSocketNotReady() {
        //
    }
    
    
}

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
        self.setupNavigation()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebRTCClient.shared.stopStream()
    }
    private func setupNavigation(){
        let witchButton = UIBarButtonItem(title: "Switch", style: .plain, target: self, action: #selector(witchCamera))
        self.navigationItem.rightBarButtonItem = witchButton
    }
    @objc private func witchCamera(){
        WebRTCClient.shared.switchCamera()
    }
    
    @IBAction func startStreaming(_ sender: Any) {
        self.createStreaming()
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
    func onCallReceived(from: String) {
        //
    }
    
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
        self.localVideo?.addViewToSuperView(superV: self.streamingVideoView)
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
extension UIView{
    func addViewToSuperView(superV: UIView){
        superV.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: superV.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: superV.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: superV.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superV.bottomAnchor).isActive = true
    }
}

//
//  OneToOneViewController.swift
//  KurentoDemo
//
//  Created by Admin on 7/6/20.
//  Copyright © 2020 Din Vu Dinh. All rights reserved.
//

import UIKit

class OneToOneViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var calleeTextField: UITextField!
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var localVideoView: UIView!
    private var localVideo: UIView?
    private var removeVideo: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        WebRTCClient.shared.delegate = self
    }

    @IBAction func register(_ sender: Any) {
        self.view.endEditing(true)
        WebRTCClient.shared.register(name: self.nameTextField.text!)
    }
    @IBAction func makeCall(_ sender: Any) {
        let callee = self.calleeTextField.text!
//        self.onAddLocalStream(videoView: self.localVideoView)
        self.view.endEditing(true)
        WebRTCClient.shared.makeCall(callee: callee)
    }
    
    @IBAction func hangup(_ sender: Any) {
        WebRTCClient.shared.rejectCall(reason: "Close")
    }
    
}
extension OneToOneViewController: WebRTCDelegate{
    func onCallReceived(from: String) {
        let alert = UIAlertController(title: "Cuoc goi", message: "Co nguoi goi den", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oke", style: .default, handler: { (_) in
            WebRTCClient.shared.acceptCall()
        }))
        self.present(alert, animated: true, completion: nil)
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
        self.localVideo?.addViewToSuperView(superV: self.localVideoView)
    }
    
    func onRemoveLocalStream() {
        if localVideo != nil{
            localVideo?.removeFromSuperview()
        }
        localVideo = nil
    }
    
    func onAddRemoteStream(videoView: UIView) {
        if removeVideo != nil{
            removeVideo?.removeFromSuperview()
        }
        self.removeVideo = videoView
        self.remoteVideoView.addSubview(self.removeVideo!)
        self.removeVideo?.frame = self.remoteVideoView.bounds
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

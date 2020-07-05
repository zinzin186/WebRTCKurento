//
//  ViewerViewController.swift
//  LiveStreamDemo
//
//  Created by Admin on 6/26/20.
//  Copyright © 2020 Dinh Le. All rights reserved.
//

import UIKit

class ViewerViewController: UIViewController {

    @IBOutlet weak var remoteVideoView: UIView!
    private var removeVideo: UIView?
    let session: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WebRTCClient.shared.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebRTCClient.shared.stopStream()
    }
    @IBAction func actionJoinToView(_ sender: Any) {
        self.createViewer()
    }
    
    @IBAction func finishView(_ sender: Any) {
        WebRTCClient.shared.stopStream()
    }
    
    

}
extension ViewerViewController{
    func createViewer(){
        WebRTCClient.shared.viewStream(sessionId: session)
    }
}
extension ViewerViewController: WebRTCDelegate{
    func onStreamCreated() {
        //
    }
    
    func onStopCommunication() {
        //
    }
    
    func onAddLocalStream(videoView: UIView) {
        
    }
    
    func onRemoveLocalStream() {
        
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
        if removeVideo != nil{
            removeVideo?.removeFromSuperview()
        }
        removeVideo = nil
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

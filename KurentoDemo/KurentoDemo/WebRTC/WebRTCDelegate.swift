//
//  WebRTCDelegate.swift
//  VTV_Stream
//
//  Created by Admin on 6/22/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

protocol WebRTCDelegate: class {
    func onStreamCreated()
    func onStopCommunication()
    func onAddLocalStream(videoView: UIView)
    func onRemoveLocalStream()
    func onAddRemoteStream(videoView: UIView)
    func onRemoveRemoteStream()
    func onCreateFailed(message: String)
    func onViewFailed(message: String)
    func onSocketOpenFailed()
    func onSocketNotReady()
    func onCallReceived(from: String)
}

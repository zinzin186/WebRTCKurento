//
//  SocketManager.swift
//  VTV_Stream
//
//  Created by Admin on 6/22/20.
//  Copyright © 2020 Admin. All rights reserved.
//


struct SOCKET {

    static let HOST = "wss://192.168.1.157:8443/one2many"
    static let CONNECTED_SUCCESS        = "socket connected success "
    static let CONNECTED_ERROR          = "socket connected error "
    static let DISCONNECTED             = "socket disconnected "
    static let RECONNECTED              = "reconnect socket"
    static let STATUS_SOCKET            = "status socket "
}



//class SocketIOManager: NSObject{
//    static let shared = SocketIOManager()
//    private var manager: SocketManager?
//    private var socket : SocketIOClient?
//    private var isConnected: Bool = false
//    
//    func establishConnection() {
//        self.manager = SocketManager(socketURL: URL(string: SOCKET.HOST)!, config: [.reconnects(false), .log(false), .compress])
//        socket = manager?.defaultSocket
//        socket?.on(clientEvent: .statusChange) {data, ack in
//            print("Data ******: \(data)")
//        }
//        socket?.on(clientEvent: .error) {[weak self](data, ack) in
//            self?.isConnected = false
//            print(SOCKET.CONNECTED_ERROR)
//        }
//        socket?.on(clientEvent: .disconnect) {[weak self](data, ack) in
//            self?.isConnected = false
//            print(SOCKET.DISCONNECTED)
//        }
//        socket?.on(clientEvent: .reconnect) {data, ack in
//            print(SOCKET.RECONNECTED)
//        }
//        socket?.on(clientEvent: .reconnectAttempt) {data, ack in
//            print(SOCKET.RECONNECTED)
//        }
//        socket?.on(clientEvent: .connect) {[weak self](data, ack) in
//            guard let `self` = self else {return}
//            print("socket connected")
//        }
//        
//        socket?.on("error") { (dataArray, socketAck) -> Void in
//            let dicMess = dataArray[0]
//            print(dicMess)
//        }
//        socket?.connect()
//        
//    }
//}

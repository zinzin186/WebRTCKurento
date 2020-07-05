//
//  ViewController.swift
//  KurentoDemo
//
//  Created by Din Vu Dinh on 7/5/20.
//  Copyright © 2020 Din Vu Dinh. All rights reserved.
//

import UIKit

enum TypeWebRTC{
    case oneToOne
    case room
    case liveStream
    
    var name: String{
        switch self {
        case .oneToOne:
            return "Call one to one"
        case .room:
            return "Call group"
        default:
            return "Live Stream"
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let typeRTC = [TypeWebRTC.oneToOne, TypeWebRTC.room, TypeWebRTC.liveStream]
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
    }

    private func configTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeRTC.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = typeRTC[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = RoomViewController.init(nibName: "RoomViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

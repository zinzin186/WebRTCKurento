//
//  HomeViewController.swift
//  LiveStreamDemo
//
//  Created by Admin on 6/27/20.
//  Copyright © 2020 Dinh Le. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func gotoPresenter(_ sender: Any) {
        let vc = StreamViewController(nibName: "StreamViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func gotoViewer(_ sender: Any) {
        let vc = ViewerViewController.init(nibName: "ViewerViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }


}

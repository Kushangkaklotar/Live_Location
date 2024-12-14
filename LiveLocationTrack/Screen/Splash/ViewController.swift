//
//  ViewController.swift
//  LiveLocationTrack
//
//  Created by Kushang  on 08/12/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let storyboard = UIStoryboard(name: "Location", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "LocationScreenViewController") as? LocationScreenViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }


}


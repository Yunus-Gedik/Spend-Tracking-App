//
//  Indicator.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 15.01.2022.
//

import UIKit

class Indicator{
    static var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    init(_ view: UIView){
        Indicator.indicator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        Indicator.indicator.center = view.center
        view.addSubview(Indicator.indicator)
        view.bringSubviewToFront(Indicator.indicator)
    }
    func start(){
        Indicator.indicator.startAnimating()
    }
    func stop(){
        Indicator.indicator.stopAnimating()
    }
}

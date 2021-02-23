//
//  UIViewController+showAler.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import UIKit

extension UIViewController {

    func showAlert(message: String,
                   okAction: (() -> Void)? = nil,
                   cancelAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default) { _ in okAction?() }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("alert_cancel", comment: ""), style: .cancel) { _ in cancelAction?() }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}




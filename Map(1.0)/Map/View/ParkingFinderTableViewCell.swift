//
//  ParkingFinderTableViewCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 10/11/2024.
//

import UIKit

protocol ParkingFinderTableViewCellDelegate: AnyObject {
    func nearestParkingButtonDidPress()
    func evParkingButtonDidPress()
    func disableParkingButtonDidPress()
}
class ParkingFinderTableViewCell: UITableViewCell {

    @IBOutlet weak var nearestParkingButton: UIButton!
    @IBOutlet weak var evParkingButton: UIButton!
    @IBOutlet weak var disableParkingButton: UIButton!
    var delegate: ParkingFinderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nearestParkingButton.addTarget(self, action: #selector(nearestParkingButtonPressed), for: .touchUpInside)
        evParkingButton.addTarget(self, action: #selector(evParkingButtonPressed), for: .touchUpInside)
        disableParkingButton.addTarget(self, action: #selector(disableParkingButtonPressed), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    @objc func nearestParkingButtonPressed() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.nearestParkingButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // Scale up to 120%
        }) { _ in
            // Animation block to scale down the button back to its original size
            UIView.animate(withDuration: 0.1) {
                self.nearestParkingButton.transform = CGAffineTransform.identity // Reset to original size
            }
        }
        
        if let delegate = delegate {
            delegate.nearestParkingButtonDidPress()
        }
        print("nearestParkingButtonPressed")
    }
    
    @objc func evParkingButtonPressed() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.evParkingButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // Scale up to 120%
        }) { _ in
            // Animation block to scale down the button back to its original size
            UIView.animate(withDuration: 0.1) {
                self.evParkingButton.transform = CGAffineTransform.identity // Reset to original size
            }
        }
        
        if let delegate = delegate {
            delegate.evParkingButtonDidPress()
        }
        
        print("evParkingButtonPressed")
    }
    
    @objc func disableParkingButtonPressed() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.disableParkingButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // Scale up to 120%
        }) { _ in
            // Animation block to scale down the button back to its original size
            UIView.animate(withDuration: 0.1) {
                self.disableParkingButton.transform = CGAffineTransform.identity // Reset to original size
            }
        }
        
        if let delegate = delegate {
            delegate.disableParkingButtonDidPress()
        }
        
        print("disableParkingButtonPressed")
    }
}

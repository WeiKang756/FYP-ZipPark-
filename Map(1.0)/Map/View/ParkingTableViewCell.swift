//
//  ParkingTableViewCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 22/09/2024.
//

import UIKit

class ParkingTableViewCell: UITableViewCell {


    @IBOutlet weak var parkingTypeIcon: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var parkingLotLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

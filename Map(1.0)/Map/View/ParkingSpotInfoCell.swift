//
//  Cell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 21/10/2024.
//

import UIKit

class ParkingSpotInfoCell: UITableViewCell {

    @IBOutlet weak var parkingSpotLabel: UILabel!
    @IBOutlet weak var isAvailableLabel: UILabel!
    @IBOutlet weak var parkingTypeLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var parkingTypeImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

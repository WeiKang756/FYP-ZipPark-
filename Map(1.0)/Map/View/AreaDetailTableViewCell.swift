//
//  AreaDetailTableViewCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 22/10/2024.
//

import UIKit

class AreaDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var numDisableParkingLabel: UILabel!
    @IBOutlet weak var numRedParkingLabel: UILabel!
    @IBOutlet weak var numGreenParkingLabel: UILabel!
    @IBOutlet weak var numYellowParkingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  AreaListTableViewCell.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 10/11/2024.
//

import UIKit

class AreaListTableViewCell: UITableViewCell {
    @IBOutlet weak var areaName: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

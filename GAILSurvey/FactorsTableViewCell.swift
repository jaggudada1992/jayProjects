//
//  FactorsTableViewCell.swift
//  GAILSurvey
//
//  Created by BIS MAC 1 on 06/02/18.
//  Copyright © 2018 BIS MAC 1. All rights reserved.
//

import UIKit

class FactorsTableViewCell: UITableViewCell {

    @IBOutlet weak var sNoLbl: UILabel!
    @IBOutlet weak var factorLbl: UILabel!
    @IBOutlet weak var ratingTF: UITextField!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var noSelectBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
}

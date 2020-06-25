//
//  InviteUserTableViewCell.swift
//  Party Finder
//
//  Created by Jptc on 12/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

protocol InviteUserDelegate {
    func invite(index: Int)
    func detail(index: Int)
}

class InviteUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var player: UILabel!
    @IBOutlet weak var rank: UILabel!
    
    var index: Int?
    var delegate: InviteUserDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func invite(_ sender: Any) {
        delegate?.invite(index: index!)
    }
    
    @IBAction func detail(_ sender: Any) {
        delegate?.detail(index: index!)
    }
    
}

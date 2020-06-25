//
//  FindTableViewCell.swift
//  Party Finder
//
//  Created by Jptc on 8/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

protocol JoinPartyDelegate {
    func join(index: Int)
}

class FindTableViewCell: UITableViewCell {
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var leader: UILabel!
    @IBOutlet weak var rank: UILabel!
    
    var index: Int?
    var delegate: JoinPartyDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func joinParty(_ sender: Any) {
        delegate?.join(index: index!)
    }
}

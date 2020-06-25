//
//  InvitesTableViewCell.swift
//  Party Finder
//
//  Created by Jptc on 12/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

protocol CellButtonDelegate {
    func accept(index: Int)
    func decline(index: Int)
}

class InvitesTableViewCell: UITableViewCell {

    @IBOutlet weak var leader: UILabel!
    @IBOutlet weak var rank: UILabel!
    
    var index: Int?
    var delegate: CellButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func accept(_ sender: Any) {
        delegate?.accept(index: index!)
    }
    
    @IBAction func decline(_ sender: Any) {
        delegate?.decline(index: index!)
    }
    
}

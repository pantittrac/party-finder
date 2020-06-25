//
//  InviteUserVC.swift
//  Party Finder
//
//  Created by Jptc on 12/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

class InviteUserVC: UIViewController {
    
    @IBOutlet weak var user_id: UILabel!
    @IBOutlet weak var firstname: UILabel!
    @IBOutlet weak var lastname: UILabel!
    @IBOutlet weak var steam_id: UILabel!
    @IBOutlet weak var medal: UILabel!
    @IBOutlet weak var number: UILabel!
    
    var user: [String:Any] = [:]
    var delegate: InviteUserDelegate?
    var index: Int?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        user_id.text = user["user_id"] as? String
        firstname.text = user["firstname"] as? String
        lastname.text = user["lastname"] as? String
        steam_id.text = (user["steam_id"] ?? "") as? String
        medal.text = (user["dota_rank_medal"] ?? "") as? String
        number.text = (user["dota_rank_number"] ?? "") as? String
    }
    
    @IBAction func clickInvite(_ sender: Any) {
        delegate?.invite(index: index!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

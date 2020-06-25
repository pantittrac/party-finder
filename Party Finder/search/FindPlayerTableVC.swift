//
//  FindPlayerTableVC.swift
//  Party Finder
//
//  Created by Jptc on 10/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

class FindPlayerTableVC: UITableViewController, InviteUserDelegate {
    
    var result: [Any] = []
    
    var user: Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        print(result)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return result.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "player", for: indexPath) as! InviteUserTableViewCell
        let data = result[indexPath.row] as! [String: Any]
        cell.delegate = self
        cell.index = indexPath.row
        cell.player.text = "Name: \(data["firstname"]!)"
        cell.rank.text = "Rank: \(data["dota_rank_medal"] ?? "")"
        
        return cell
    }

    func invite(index: Int) {
        let ud = UserDefaults.standard
        if let party_id = ud.value(forKey: "party_id") {
            let data = result[index] as! [String:Any]
            let param = ["inviter_id": ud.value(forKey: "username") as! String, "party_id": party_id as! Int, "invited_id": data["user_id"] as! String] as [String : Any]
            guard let uploadData = try? JSONSerialization.data(withJSONObject: param, options: []) else { return }
            let urlStr = "http://localhost:8081/api/invite/create"
            let url = URL(string: urlStr)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
                if let error = error {
                    print("error: \(error)")
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                        print("server error")
                        return
                }
                //print("-----")
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data {
                    var dict: [String:Any]?
                    do {
                        dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    } catch let error {
                        print("Error \(error)")
                    }
                    print(dict!)
                    DispatchQueue.main.async {
                        if dict!["success"] as! Int == 1 {
                            let alert = UIAlertController(title: "Send Invite", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                        }
                    }
                }
            }
            task.resume()
            
            
        } else {
            let alert = UIAlertController(title: "Don't have party", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
        }
    }
    
    func detail(index: Int) {
        user = index
        performSegue(withIdentifier: "inviteUser", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inviteUser" {
            if let vc = segue.destination as? InviteUserVC {
                vc.delegate = self
                vc.user = result[user!] as! [String: Any]
                vc.index = user
            }
        }
    }
    
    
}

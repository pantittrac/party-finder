//
//  InvitesTableVC.swift
//  Party Finder
//
//  Created by Jptc on 10/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

class InvitesTableVC: UITableViewController {
    
    var inviteData: [Any] = []
    let param = ["invited_id": UserDefaults.standard.value(forKey: "username") as? String]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    func getData() {
        guard let uploadData = try? JSONEncoder().encode(param) else { return }
        let urlStr = "http://localhost:8081/api/invite/getByInvitedId"
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
                    let message = dict?["message"] as? [Any]
                    print(message!)
                    if message?.isEmpty == false {
                        self.inviteData = message!
                        print("have invite")
                        // if data doesn't load
                        //self.tableView.reloadData()
                    } else {
                        print("don't have invite")
                    }
                }
                
                
                //["success": 1, "message": User successfully updated]
                //let mes = dict!["message"]
                //print(dict)
            }
        }
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inviteData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invite", for: indexPath) as! InvitesTableViewCell
        
        let cellData = inviteData[indexPath.row] as! [String: Any]
        
        cell.delegate = self
        cell.index = indexPath.row
        
        //check
        cell.leader.text = "Leader: \(cellData["leader_user_id"]!)"
        cell.rank.text = "Rank: \(cellData["dota_rank_medal"]!)"
        
        return cell
    }

}

extension InvitesTableVC: CellButtonDelegate {
    func accept(index: Int) {
        let invitation = inviteData[index] as! [String: Any]
        var params: [String:Any] = param as [String : Any]
        params["invitation_id"] = invitation["invitation_id"]
        guard let uploadData = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        let urlStr = "http://localhost:8081/api/invite/accept"
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
            }
        }
        task.resume()
    }
    
    func decline(index: Int) {
        let invitation = inviteData[index] as! [String: Any]
        var params: [String:Any] = param as [String : Any]
        params["invitation_id"] = invitation["invitation_id"]
        guard let uploadData = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        let urlStr = "http://localhost:8081/api/invite/decline"
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
            }
        }
        task.resume()
    }
    
}

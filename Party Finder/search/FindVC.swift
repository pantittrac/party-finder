//
//  FindVC.swift
//  Party Finder
//
//  Created by Jptc on 8/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

class FindVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var result: [Any]?
    
    @IBOutlet weak var tableR: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("--------------------------------Page II -----------------------------------")
        
        tableR.delegate = self
        tableR.dataSource = self
        //searchB.delegate = self
        //pickerView.delegate = self
        //searchT = searchB.value(forKey: "searchField") as! UITextField

        // Do any additional setup after loading the view.
        //searchB.inputAccessoryView = pickerView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! FindTableViewCell
        let data = result?[indexPath.row] as! [String:Any]
        //let id = data["party_id"]
        //cell.textLabel?.text = "\(id ?? " ")"
        cell.status.text = "Status: \(data["status"] ?? " ")"
        cell.leader.text = "Leader: \(data["party_leader_id"] ?? " ")"
        cell.rank.text = "Rank: \(data["dota_rank_medal"] ?? " ")"
        cell.delegate = self
        cell.index = indexPath.row
        
        return cell
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

extension FindVC: JoinPartyDelegate {
    func join(index: Int) {
        let data = result![index] as! [String: Any]
        let params = ["party_id": data["party_id"], "user_id": UserDefaults.standard.value(forKey: "username") as! String]
        guard let uploadData = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        let urlStr = "http://localhost:8081/api/joinRequest/create"
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

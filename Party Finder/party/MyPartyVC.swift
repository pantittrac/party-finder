//
//  MyPartyVC.swift
//  Party Finder
//
//  Created by Jptc on 8/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

class MyPartyVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let param = ["user_id": UserDefaults.standard.value(forKey: "username") as? String]
    var party_id: Int?
    var member: [Any] = []
    var request: [Any] = []
    
    
    @IBOutlet weak var createParty: UIBarButtonItem!
    @IBOutlet weak var leaveB: UIBarButtonItem!
    @IBOutlet weak var editB: UIBarButtonItem!
    
    @IBOutlet weak var tableMem: UITableView!
    @IBOutlet weak var tableReq: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableMem.delegate = self
        tableMem.dataSource = self
        tableMem.tag = 0
        
        tableReq.delegate = self
        tableReq.dataSource = self
        tableReq.tag = 1
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
    }
    
    func getData() {
        guard let uploadData = try? JSONEncoder().encode(param) else { return }
        let urlStr = "http://localhost:8081/api/party/getCurrentParty"
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
                    print("from getData")
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
                    print("-----")
                    if message?.isEmpty == false {
                        let data = message![0] as! [String: Any]
                        self.createParty.isEnabled = false
                        self.leaveB.isEnabled = true
                        self.editB.isEnabled = true
                        self.party_id = data["party_id"] as? Int
                        UserDefaults.standard.set(self.party_id, forKey: "party_id")
                        UserDefaults.standard.synchronize()
                        self.getMember()
                        self.getRequest()
                        //print(party_id!)
                        //print(type(of: self.party_id!))
                        //get member
                    } else {
                        print("don't have party")
                        self.createParty.isEnabled = true
                        self.leaveB.isEnabled = false
                        self.editB.isEnabled = false
                    }
                }
                
                
                //["success": 1, "message": User successfully updated]
                //let mes = dict!["message"]
                //print(dict)
            }
        }
        task.resume()
    }
    
    @IBAction func createParty(_ sender: Any) {
        let create = UIAlertController(title: "Create Party", message: nil, preferredStyle: .alert)
        create.addTextField { (text) in
            text.placeholder = "Description"
        }
        create.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        create.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
            let des = create.textFields![0].text
            self.createP(des: des ?? "")
        }))
        self.present(create, animated: true, completion: nil)
    }
    
    @IBAction func leaveParty(_ sender: Any) {
        var params: [String:Any] = param as [String : Any]
        params["party_id"] = party_id
        guard let uploadData = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        let urlStr = "http://localhost:8081/api/party/leave"
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
                    self.member = []
                    self.request = []
                    self.tableMem.reloadData()
                    self.tableReq.reloadData()
                    UserDefaults.standard.removeObject(forKey: "party_id")
                    UserDefaults.standard.synchronize()
                    let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        task.resume()
        
    }
    
    @IBAction func editParty(_ sender: Any) {
        let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        alert.addTextField { (text) in
            text.placeholder = "Description"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) in
            let des = alert.textFields![0].text
            self.editP(des: des ?? "")
        }))
        
    }
    
    
    
    //connect API
    func createP(des: String) {
        var params = param
        params["description"] = des
        guard let uploadData = try? JSONEncoder().encode(params) else { return }
        let urlStr = "http://localhost:8081/api/party/create"
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
                
                //["success": 1, "message": User successfully updated]
                //let mes = dict!["message"]
                //print(dict)
            }
        }
        task.resume()
    }
    
    func editP(des: String) {
        var params: [String:Any] = param as [String : Any]
        params["new_description"] = des
        //check status
        //params["new_status"] =
        params["party_id"] = party_id
        guard let uploadData = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        let urlStr = "http://localhost:8081/api/party/update"
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
                
                //["success": 1, "message": User successfully updated]
                //let mes = dict!["message"]
                //print(dict)
            }
        }
        task.resume()
    }
    
    func getMember() {
        guard let uploadData = try? JSONEncoder().encode(["party_id" : party_id]) else { return }
        let urlStr = "http://localhost:8081/api/party/getMembers"
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
                    print("from getMem")
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
                    self.member = message!
                    self.tableMem.reloadData()
                }
                
                
                //["success": 1, "message": User successfully updated]
                //let mes = dict!["message"]
                //print(dict)
            }
        }
        task.resume()
    }
    
    func getRequest() {
        guard let uploadData = try? JSONEncoder().encode(["party_id" : party_id]) else { return }
        let urlStr = "http://localhost:8081/api/joinRequest/getByPartyID"
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
                    print("from getReq")
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
                    self.request = message!
                    self.tableReq.reloadData()
                }
                
                
                //["success": 1, "message": User successfully updated]
                //let mes = dict!["message"]
                //print(dict)
            }
        }
        task.resume()
    }
    
    //table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return member.count
        } else {
            return request.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "member", for: indexPath)
            let data = member[indexPath.row] as! [String: Any]
            
            cell.textLabel?.text = "Name: \(data["firstname"]!)"
            cell.detailTextLabel?.text = "Rank: \(data["dota_rank_medal"] ?? "")"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "request", for: indexPath) as! RequestTableViewCell
            if !request.isEmpty {
                let data = request[indexPath.row] as! [String:Any]
                
                cell.delegate = self
                cell.index = indexPath.row
                cell.player.text = "Name: \(data["firstname"]!)"
                cell.rank.text = "Rank: \(data["dota_rank_medal"] ?? "")"
            }
            return cell
        }
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
//check
extension MyPartyVC: CellButtonDelegate {
    func accept(index: Int) {
        let req = request[index] as! [String: Any]
        //check
        let params = ["request_id": req["request_id"], "user_id": req["user_id"]]
        guard let uploadData = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        let urlStr = "http://localhost:8081/api/joinRequest/accept"
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
                    self.tableMem.reloadData()
                    self.tableReq.reloadData()
                }
            }
        }
        task.resume()
    }
    
    func decline(index: Int) {
        let req = request[index] as! [String: Any]
        //check
        let params = ["request_id": req["request_id"], "user_id": req["user_id"]]
        guard let uploadData = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        let urlStr = "http://localhost:8081/api/joinRequest/decline"
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
                    self.tableReq.reloadData()
                }
            }
        }
        task.resume()
    }
    
}

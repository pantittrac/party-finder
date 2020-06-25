//
//  ProfileVC.swift
//  Party Finder
//
//  Created by Jptc on 10/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//
//idle:1, looking to play:2

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var firstname: UILabel!
    @IBOutlet weak var lastname: UILabel!
    @IBOutlet weak var steamID: UILabel!
    @IBOutlet weak var medal: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var statusS: UISwitch!
    
    var lookingToPlay = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ud = UserDefaults.standard
        username.text = ud.value(forKey: "username") as? String
        firstname.text = ud.value(forKey: "firstname") as? String
        lastname.text = ud.value(forKey: "lastname") as? String
        //steamID.text = ud.value(forKey: "steam_id") as? String
        //medal.text = ud.value(forKey: "rank_medal") as? String
        
       
        
        let status = ud.value(forKey: "status") as? String
        //print(status)
        if status == "idle" {
            statusS.isOn = false
        } else {
            statusS.isOn = true
        }


        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let ud = UserDefaults.standard
        
        let steam_id = ud.value(forKey: "steam_id") as? String
        if steam_id != "<null>" {
            steamID.text = steam_id
        } else {
            steamID.text = "-"
        }
        let rank_medal = ud.value(forKey: "rank_medal") as? String
        if rank_medal != "<null>" {
            medal.text = rank_medal
        } else {
            medal.text = "-"
        }
        let rank_num = ud.value(forKey: "rank_num") as? String
        if rank_num != "<null>" {
            number.text = rank_num
        } else {
            number.text = "-"
        }
    }
    
    @IBAction func playSwitch(_ sender: UISwitch) {
        let ud = UserDefaults.standard
        if sender.isOn {
            lookingToPlay = 2
            ud.set("looking to play", forKey: "status")
            print("looking to play")
        } else {
            lookingToPlay = 1
            ud.set("idle", forKey: "status")
            print("idle")
        }
        ud.synchronize()
        //let parem = ["user_id": (ud.value(forKey: "username") as? String)!, "looking_to_play": lookingToPlay] as [String : Any]
        //guard let uploadData = try? JSONEncoder().encode(parem) else {            return }
        var parem : [String:Any] = [:]
        
        if lookingToPlay == 2 {
            parem = ["user_id": (ud.value(forKey: "username") as? String)!, "looking_to_play": lookingToPlay]
        } else {
            parem = ["user_id": (ud.value(forKey: "username") as? String)!]
        }
        guard let uploadData = try? JSONSerialization.data(withJSONObject: parem, options: .prettyPrinted) else {
            return
        }
        //print(String(data: uploadData, encoding: .utf8))
        getData(uploadData: uploadData)
        
    }
    
    func getData(uploadData: Data) {
        let urlStr = "http://localhost:8081/api/user/setLookingToPlay"
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

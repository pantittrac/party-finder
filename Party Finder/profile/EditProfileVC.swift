//
//  EditProfileVC.swift
//  Party Finder
//
//  Created by Jptc on 10/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let rankmedal = ["","Herald","Guardian","Crusader","Archon","Legend","Ancient","Divine","Immortal"]
    let ranknumber = ["","1","2","3","4","5","6","7"]
    
    @IBOutlet weak var steamID: UITextField!
    @IBOutlet weak var uMedal: UITextField!
    @IBOutlet weak var uNumber: UITextField!
    
    var modalPicker = UIPickerView()
    var numberPicker = UIPickerView()
    
    var editMedal = 0
    var editNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ud = UserDefaults.standard
        
        let steam_id = ud.value(forKey: "steam_id") as? String
        if steam_id != "<null>" {
            steamID.text = steam_id
        } else {
            steamID.text = ""
        }
        let rank_medal = ud.value(forKey: "rank_medal") as? String
        if rank_medal != "<null>" {
            uMedal.text = rank_medal
            editMedal = rankmedal.firstIndex(of: rank_medal!)!
        } else {
            uMedal.text = ""
        }
        let rank_num = ud.value(forKey: "rank_num") as? String
        if rank_num != "<null>" {
            uNumber.text = rank_num
            editNumber = ranknumber.firstIndex(of: rank_num!)!
        } else {
            uNumber.text = ""
        }
        
        
        modalPicker.delegate = self
        modalPicker.tag = 0
        uMedal.inputView = modalPicker
        let medalToolbar = UIToolbar()
        medalToolbar.barStyle = .default
        medalToolbar.sizeToFit()
        let medalDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.buttonDoneDidTap))
        medalDone.tag = 0
        medalToolbar.setItems([medalDone], animated: true)
        medalToolbar.isUserInteractionEnabled = true
        uMedal.inputAccessoryView = medalToolbar
        
        numberPicker.delegate = self
        numberPicker.tag = 1
        uNumber.inputView = numberPicker
        let numberToolbar = UIToolbar()
        numberToolbar.barStyle = .default
        numberToolbar.sizeToFit()
        let numberDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.buttonDoneDidTap))
        numberDone.tag = 1
        numberToolbar.setItems([numberDone], animated: true)
        uNumber.inputAccessoryView = numberToolbar
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        if (editMedal == 0 || editNumber == 0 || steamID.text == "") {
            let alert = UIAlertController(title: "Error", message: "Please make sure all fields have been entered", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let parameter = ["user_id": UserDefaults.standard.value(forKey: "username") as! String, "dota_rank_medal": editMedal, "dota_rank_number": editNumber, "steam_id": steamID.text!] as [String : Any]
            guard let uploadData = try? JSONSerialization.data(withJSONObject: parameter, options: []) else { return }
            //print(String(data: uploadData, encoding: .utf8))
            getData(uploadData: uploadData)
        }
    }
    
    func getData(uploadData: Data) {
        let urlStr = "http://localhost:8081/api/user/update"
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
                //let mes = dict!["message"]
                //print(dict)
                DispatchQueue.main.async {
                    if dict!["success"] as? Int == 1 {
                        let ud = UserDefaults.standard
                        ud.set(self.rankmedal[self.editMedal], forKey: "rank_medal")
                        ud.set(self.ranknumber[self.editNumber], forKey: "rank_num")
                        ud.set(self.steamID.text!, forKey: "steam_id")
                        ud.synchronize()
                        let success = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        success.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(success, animated: true, completion: nil)
                    }
                    //alert and dismiss
                }
            }
        }
        task.resume()
    }
    
    @objc func buttonDoneDidTap(_ sender: UIBarButtonItem) {
        if sender.tag == 0 {
            uMedal.resignFirstResponder()
        } else {
            uNumber.resignFirstResponder()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return rankmedal.count
        } else {
            return ranknumber.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return rankmedal[row]
        } else {
            return ranknumber[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            uMedal.text = rankmedal[row]
            editMedal = row
            print(rankmedal[editMedal])
        } else {
            uNumber.text = ranknumber[row]
            editNumber = row
            print(ranknumber[editNumber])
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

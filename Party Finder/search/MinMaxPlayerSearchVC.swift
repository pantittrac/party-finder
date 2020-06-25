//
//  MinMaxPlayerSearchVC.swift
//  Party Finder
//
//  Created by Jptc on 10/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit

class MinMaxPlayerSearchVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var maxRank: UITextField!
    @IBOutlet weak var minRank: UITextField!
    
    var minPickerView = UIPickerView()
    var maxPickerView = UIPickerView()
    
    var min = 0
    var max = 0
    var result = [Any]()
    
    
    let rank = ["","Herald","Guardian","Crusader","Archon","Legend","Ancient","Divine","Immortal"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        minPickerView.delegate = self
        maxPickerView.delegate = self
        minPickerView.tag = 0
        maxPickerView.tag = 1
        maxRank.inputView = maxPickerView
        minRank.inputView = minPickerView
        //min
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let minDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.buttonDoneDidTap))
        minDone.tag = 0
        toolbar.setItems([minDone], animated: true)
        toolbar.isUserInteractionEnabled = true
        minRank.inputAccessoryView = toolbar
        //max
        let toolbar2 = UIToolbar()
        toolbar2.barStyle = .default
        toolbar2.sizeToFit()
        let maxDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.buttonDoneDidTap))
        
        maxDone.tag = 1
        toolbar2.setItems([maxDone], animated: true)
        toolbar2.isUserInteractionEnabled = true
        maxRank.inputAccessoryView = toolbar2

        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rank.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rank[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            min = row
            minRank.text = rank[row]
        } else {
            max = row
            maxRank.text = rank[row]
        }
    }
    
    @objc func buttonDoneDidTap(_ sender: UIBarButtonItem) {
        if sender.tag == 0 {
            minRank.resignFirstResponder()
        } else {
            maxRank.resignFirstResponder()
        }
    }
    
    
    @IBAction func searchDidTap(_ sender: Any) {
        if (min == 0 || max == 0) {
            let alert = UIAlertController(title: "Can't Search", message: "Please select rank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        } else {
            guard let uploadData = try? JSONEncoder().encode(["medal_min": min, "medal_max": max]) else { return }
            getData(uploadData: uploadData)
        }
    }
    
    func getData(uploadData: Data) {
        let urlStr = "http://localhost:8081/api/user/getLookingToPlay"
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
                    self.result = dict!["message"] as! [Any]
                    self.performSegue(withIdentifier: "getPlayer", sender: nil)
                }
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getPlayer" {
            if let vc = segue.destination as? FindPlayerTableVC {
                vc.result = self.result
            }
        }
    }
    
    @IBAction func clickBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

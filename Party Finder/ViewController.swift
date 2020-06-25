//
//  ViewController.swift
//  Party Finder
//
//  Created by Jptc on 3/5/2562 BE.
//  Copyright © 2562 Jptc. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKURLSchemeHandler {
    
    let DeeAppId:String = "#"
    let DeeAppSecret:String = "#"
    
    var ticket:String? = nil
    var username:String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(self, forURLScheme: "#")
        let wkWebView = WKWebView(frame: .zero,configuration:configuration)
        self.view = wkWebView
        
        let mURL:URL = URL(string: "#")!
        let request:URLRequest = URLRequest(url: mURL)
        wkWebView.load(request)
        
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let components:URLComponents=URLComponents(string: urlSchemeTask.request.url!.absoluteString)!
        
        let ticket:String = (components.queryItems?.filter({$0.name=="ticket"}).first!.value)!
        print("ticket: ", ticket)
        //urlSchemeTask.didFinish()
        let stURL="#"
        let url:URL = URL(string: stURL)!
        var request:URLRequest = URLRequest(url: url)
        
        request.httpMethod="POST"
        request.addValue(DeeAppId, forHTTPHeaderField: "DeeAppId")
        request.addValue(DeeAppSecret, forHTTPHeaderField: "DeeAppSecret")
        request.addValue(ticket, forHTTPHeaderField: "DeeTicket")
        
        let task=URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard let data = data else { return }
            //let jsonString:String = String(data:data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            //print(String(data:data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Any)
            var obj = try? (JSONSerialization.jsonObject(with: data, options: []) as! [String: Any])
            let info = ["firstname" : obj!["firstname"], "lastname": obj!["lastname"], "username": obj!["username"]]
            DispatchQueue.main.async {
                self.getUserCreate(info: info as! [String : String])
            }
            
        }
        task.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("webView: stop");
    }
    
    func getUserCreate(info: [String: String]) {
        guard let uploadData = try? JSONEncoder().encode(info) else { return }
        
        let urlStr = "http://localhost:8081/api/user/getUserCreate"
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
                //print(dict!)
                //print(type(of: dict!))
                let result = dict!["message"] as! [String:Any]
                DispatchQueue.main.async {
                    let ud = UserDefaults.standard
                    ud.set(result["firstname"], forKey: "firstname")
                    ud.set(result["lastname"], forKey: "lastname")
                    ud.set(result["user_id"], forKey: "username")
                    ud.set(result["status"], forKey: "status")
                    ud.set("\(result["dota_rank_number"] ?? " ")" , forKey: "rank_num")
                    ud.set("\(result["dota_rank_medal"] ?? " ")", forKey: "rank_medal")
                    ud.set("\(result["steam_id"] ?? " ")", forKey: "steam_id")
                    ud.synchronize()
                    print(result)
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home") {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
}


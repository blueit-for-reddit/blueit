//
//  LoginViewController.swift
//  blueit
//
//  Created by Eli Young on 11/15/22.
//

import UIKit


let DURATION = "temporary"
let SCOPE = "read,vote,submit,identity,history,submit"
let STATE = "pyscript"

let OAUTH_URL = URL(string: "https://www.reddit.com/api/v1/authorize?client_id=\(CLIENT_ID)&response_type=code&state=\(STATE)&redirect_uri=\(REDIRECT_URI)&duration=\(DURATION)&scope=\(SCOPE)")!

class LoginViewController: UIViewController {
    static var client: LoginViewController? = nil
    
    
    @IBAction func onLogin(_ sender: Any) {
        UIApplication.shared.open(OAUTH_URL)
    }
    
    
    override func viewDidLoad() {
        LoginViewController.client = self
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if UserDefaults.standard.string(forKey: "sessionToken") != nil
        {
            RedditAPICaller.sessionToken = UserDefaults.standard.string(forKey: "sessionToken")
            self.performSegue(withIdentifier: "loginToHome", sender: self)
            
        }
    }
    
    
    func goToFeed() {
        self.performSegue(withIdentifier: "loginToHome", sender: self)
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

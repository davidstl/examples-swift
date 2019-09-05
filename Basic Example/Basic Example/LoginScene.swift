//
//  ViewController.swift
//  Basic Example
//
//  Created by brainCloud Support on 2018-08-14.
//  Copyright © 2018 brainCloud Support. All rights reserved.
//

import UIKit

class LoginScene: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        // If user has already authenticated, so let's reconnect
        if(UserDefaults.standard.bool(forKey: "HasAuthenticated")) {
            reconnectBtn.isEnabled = true
            
            profileId.text = AppDelegate._bc.storedProfileId;
            anonId.text = AppDelegate._bc.storedAnonymousId;
        } else {
            reconnectBtn.isEnabled = false
        }
        
    }
    
    @IBOutlet weak var loginView: UIStackView!
    @IBOutlet weak var registerView: UIStackView!
    
    @IBAction func onMenuChanged(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0) {
            loginView.isHidden = false;
            registerView.isHidden = true;
        } else if(sender.selectedSegmentIndex == 1) {
            loginView.isHidden = true;
            registerView.isHidden = false;
        } 
    }
    
    /**
     Login
     */
    
    @IBOutlet weak var lEmail: UITextField!
    @IBOutlet weak var lPassword: UITextField!
    
    @IBOutlet weak var lLoginError: UILabel!
    
    @IBAction func OnLoginClicked(_ sender: Any) {
        
        /*
         BRAINCLOUD_INFO
         
         On our apps login page, we request the user to give a email and password for the EMAIL and PASSWORD required for authentication.
         
         After a successful login, the onAuthenticate function will be called
         
         AppDelegate.authenticateEmailPassword(EMAIl,
         password: PASSWORD,
         forceCreate: true,
         completionBlock: onAuthenticate,
         errorCompletionBlock: onAuthenticateFailed,
         cbObject: nil)
         */
        
        AppDelegate._bc.authenticateEmailPassword(lEmail.text,
                                              password: lPassword.text,
                                              forceCreate: true,
                                              completionBlock: onAuthenticate,
                                              errorCompletionBlock: onAuthenticateFailed,
                                              cbObject: nil)
    }
    
    func onAuthenticate(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        
        AppDelegate._bc.identityService.switch(toChildProfile: nil, childAppId: "12049", forceCreate: true, completionBlock: onProfileSwitch, errorCompletionBlock:nil, cbObject: nil);
        
       
        
    }
    
    func onProfileSwitch(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        
        
        let data = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
            
            let data = json["data"] as AnyObject;
            let id = data["id"] as! String;

            // Let's ensure we grab the child profile id
            AppDelegate._bc.storedProfileId = id;
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
        
        UserDefaults.standard.set(true, forKey: "HasAuthenticated")
        
        self.performSegue(withIdentifier: "onLogin", sender: nil)
        
        
    }
    
    
    func onAuthenticateFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        print("\(serviceOperation!) Failure \(jsonError!)")
        
        /*
         BRAINCLOUD_INFO
         
         The user has failed to login. Perhaps they entered the wrong password, or do not have an internet connection.
         
         Display an error to the user, based on the problem that occured
         */
        
        if(reasonCode == 40208) {
            self.lLoginError.text = "Account does not exist. Please register instead."
        } else {
            
            self.lLoginError.text = "\n\(serviceOperation!) Error \(reasonCode!)"
        }
        
        UserDefaults.standard.set(false, forKey: "HasAuthenticated")
    }
    
    
    @IBOutlet weak var reconnectBtn: UIButton!
    @IBOutlet weak var profileId: UITextField!
    @IBOutlet weak var anonId: UITextField!
    
    @IBAction func onReconnectClicked(_ sender: Any) {
        AppDelegate._bc.reconnect(onAuthenticate,
                                  errorCompletionBlock: onAuthenticateFailed,
                                  cbObject: nil)
    }
    
    
    
    /**
     Register
     */
    
    @IBOutlet weak var rEmail: UITextField!
    @IBOutlet weak var rPassword: UITextField!
    @IBOutlet weak var rName: UITextField!
    @IBOutlet weak var rRegisterError: UILabel!
    
    @IBAction func onRegisterClicked(_ sender: Any) {
        AppDelegate._bc.authenticateEmailPassword(rEmail.text,
                                              password: rPassword.text,
                                              forceCreate: true,
                                              completionBlock: onRegister,
                                              errorCompletionBlock: onRegisterFailed,
                                              cbObject: nil)
    }
    
    func onRegister(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        print("Success \(String(describing: jsonData))")
        
        
        let data = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        /*
         BRAINCLOUD_INFO
         
         After our user logs in, we are going to see if they are a newUser, and if they are, we are going to update their "name" to match the name they entered on the register screen
         
         */
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
            
            let data = json["data"] as AnyObject;
            let isNewUser = data["newUser"] as! String;
            
            if(isNewUser.elementsEqual("true")) {
                AppDelegate._bc.playerStateService.updateName(self.rName?.text,
                                                              completionBlock: nil,
                                                              errorCompletionBlock: nil,
                                                              cbObject: nil)
                
                
                
                UserDefaults.standard.set(true, forKey: "HasAuthenticated")
                
                self.performSegue(withIdentifier: "onLogin", sender: nil)
                
            } else {
                /*
                 If they aren't a new user, we are going to logout, and throw an error that they need to login instead
                 */
                AppDelegate._bc.playerStateService.logout(nil, errorCompletionBlock: nil, cbObject: nil);
                
                rRegisterError.text = "User already exists, please login instead.";
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
        
    }
    
    func onRegisterFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        print("Failure \(String(describing: serviceName))")
        
        UserDefaults.standard.set(false, forKey: "HasAuthenticated")
        
        self.rRegisterError.text = "Could not register. If user already exists, please login instead.";
    }
    
    
    @IBAction func onAnonymousLoginClicked(_ sender: Any) {
        AppDelegate._bc.storedAnonymousId = "";
        AppDelegate._bc.storedProfileId = "";
        
        AppDelegate._bc.authenticateAnonymous(onAuthenticate,
                                              errorCompletionBlock: onAuthenticateFailed,
                                              cbObject: nil)
        
    }
    
    
}


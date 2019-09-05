//
//  ViewController.swift
//  Basic Example
//
//  Created by brainCloud Support on 2018-08-14.
//  Copyright © 2018 brainCloud Support. All rights reserved.

import UIKit
import BrainCloud

class MainScene: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource   {
   
    let ENTITY_TYPE = "Person"
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    var pickerData = [] as Array<String>
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    var lastRow = 0
    var entities = Array<AnyObject>()
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(lastRow != row) {
           
            
            var entity = entities[row] as! Dictionary<String, AnyObject>
            
            entityType.text = entity["entityType"] as? String
            name.text = entity["data"]?["name"] as? String
            age.text = entity["data"]?["age"] as? String
            
            lastRow = row;
        }
        
        return pickerData[row]
    }
    
    
    @IBOutlet weak var deviceTokenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        deviceTokenLabel.text = AppDelegate.pushToken
        
        AppDelegate._bc.entityService.getEntitiesByType(
            ENTITY_TYPE,
            completionBlock: onGetEntitiesByType,
            errorCompletionBlock: onGetEntitiesByTypeFailed,
            cbObject: nil)
    }
    
    func onGetEntitiesByType(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        print("\n\(serviceOperation!) Success \(jsonData!)")
        
        self.entityLog.text = "\n\(serviceOperation!) Success \(jsonData!)"
        
        let data = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
            
            entities = json["data"]!["entities"] as! Array<AnyObject>;
            
            pickerData = []
            
            for entity in entities {
                let entityData = entity as! Dictionary<String, AnyObject>
                pickerData.append(entityData["entityId"] as! String);
            }
            
            entityIdPicker.reloadAllComponents()
            
            print(entities);
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
    }
    
    func onGetEntitiesByTypeFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        self.entityLog.text = "\(serviceOperation!) Failed \(jsonError!)"
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBOutlet weak var entityIdPicker: UIPickerView!
    @IBOutlet weak var entityType: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    
    @IBOutlet weak var entityLog: UITextView!
    
    @IBAction func onCreateEntity(_ sender: Any) {
        let jsonData = "{ \"name\": \"\(name.text!)\", \"age\": \"\(age.text!)\" }"
        let jsonAcl = "{ \"other\": 0 }"
        
        AppDelegate._bc.entityService.createEntity(ENTITY_TYPE,
                                                   jsonEntityData: jsonData,
                                                   jsonEntityAcl: jsonAcl,
                                                   completionBlock: onCreateEntity,
                                                   errorCompletionBlock: onCreateEntityFailed,
                                                   cbObject: nil)
        
        
    }
    
    func onCreateEntity(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        print("\n\(serviceOperation!) Success \(jsonData!)")
        
        self.entityLog.text = "\n\(serviceOperation!) Success \(jsonData!)"
        
        AppDelegate._bc.entityService.getEntitiesByType(
            ENTITY_TYPE,
            completionBlock: onGetEntitiesByType,
            errorCompletionBlock: onGetEntitiesByTypeFailed,
            cbObject: nil)
        
        
    }
    
    func onCreateEntityFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        self.entityLog.text = "\(serviceOperation!) Failed \(jsonError!)"
        
    }
    
    @IBAction func onDeleteEntity(_ sender: Any) {
        AppDelegate._bc.entityService.delete(pickerData[entityIdPicker.selectedRow(inComponent: 0)],
                                             version: -1,
                                             completionBlock: onDeleteEntity,
                                             errorCompletionBlock: onDeleteEntityFailed,
                                             cbObject: nil)
    }
    
    func onDeleteEntity(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        
        self.entityLog.text = "\(serviceOperation!) Success \(jsonData!)"
        
        AppDelegate._bc.entityService.getEntitiesByType(
            ENTITY_TYPE,
            completionBlock: onGetEntitiesByType,
            errorCompletionBlock: onGetEntitiesByTypeFailed,
            cbObject: nil)
    }
    
    func onDeleteEntityFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        self.entityLog.text = "\(serviceOperation!) Failed \(jsonError!)"
        
    }
    
    @IBOutlet weak var entityMenu: UIStackView!
    @IBOutlet weak var pushNotificationMenu: UIStackView!
    
    @IBAction func onChangeMenu(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0) {
            entityMenu.isHidden = false;
            pushNotificationMenu.isHidden = true;
        } else if(sender.selectedSegmentIndex == 1) {
            entityMenu.isHidden = true;
            pushNotificationMenu.isHidden = false;
        } else if(sender.selectedSegmentIndex == 2) {
            AppDelegate._bc.playerStateService.logout(
                nil,
                errorCompletionBlock: nil,
                cbObject: nil)
            
            AppDelegate._bc.getBCClient()
                .authenticationService.clearSavedProfile()
            AppDelegate._bc.storedAnonymousId = ""
            AppDelegate._bc.storedProfileId = ""
            
            UserDefaults.standard.set(false, forKey: "HasAuthenticated")
            
            self.performSegue(withIdentifier: "onLogout", sender: nil)
        }
    }
    
    
    /**
        Push Notifications
     */
    
    @IBOutlet weak var deviceToken: UILabel!
    
    @IBAction func onRegisterPushNotificationsClicked(_ sender: Any) {
       
        deviceTokenLabel.text = AppDelegate.pushToken
        AppDelegate._bc.pushNotificationService.registerDeviceToken(
            PlatformObjc.iOS(),
            deviceToken: AppDelegate.pushToken,
            completionBlock: onPushNotificationSuccess,
            errorCompletionBlock: nil,
            cbObject: nil)
    }
    
    @IBAction func onDeregisterPushNotificationsClicked(_ sender: Any) {
        AppDelegate._bc.pushNotificationService.deregisterAllPushNotificationDeviceTokens(
            onPushNotificationSuccess,
            errorCompletionBlock: nil,
            cbObject: nil)
    }
    
    @IBAction func onSendPushNotificationsClicked(_ sender: Any) {

        /** cloud code example
 var response = {};
 
 var toProfileId = bridge.profileId;
 
 var fcmContent = {
 "notification": {
 "body": "content of message",
 "title": "message title"
 },
 "data": {
 "customfield1": "customValue1",
 "customfield2": "customValue2"
 },
 "priority": "normal"
 };
 var iosContent = {
 "aps": {
 "alert": {
 "body": "content of message",
 "title": "message title"
 },
 "badge": 0,
 "sound": "gggg"
 }
 };
 var facebookContent = {
 "template": "content of message"
 };
 
 var pushNotificationProxy = bridge.getPushNotificationServiceProxy();
 
 var postResult = pushNotificationProxy.sendRawPushNotification(
 toProfileId,
 fcmContent,
 iosContent,
 facebookContent
 );
 
 response;
 */
        AppDelegate._bc.scriptService.run("Test", jsonScriptData: "", completionBlock: nil, errorCompletionBlock: nil, cbObject: nil);
        
        // Or regular push example
        AppDelegate._bc.pushNotificationService.sendSimplePushNotification(
            AppDelegate._bc.storedProfileId,
            message: "Message_" + String(describing: arc4random_uniform(2000)),
            completionBlock: onPushNotificationSuccess,
            errorCompletionBlock: nil,
            cbObject: nil)
    }
    
    @IBOutlet weak var pushLog: UILabel!
    
    func onPushNotificationSuccess(serviceName:String?, serviceOperation:String?, jsonData:String?, cbObject: NSObject?) {
        
        self.pushLog.text = "\(serviceOperation!) Success \(jsonData!)"
        
    }
    
    func onPushNotificationFailure(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?) {
        
        self.pushLog.text = "\(serviceOperation!) Failed \(jsonError!)"
    }
}


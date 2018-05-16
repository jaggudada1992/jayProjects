//
//  ViewController.swift
//  GAILSurvey
//
//  Created by BIS MAC 1 on 06/02/18.
//  Copyright © 2018 BIS MAC 1. All rights reserved.
//

import UIKit

class ViewController: UIViewController,PortalStatusServiceDelegate {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneNoTF: UITextField!
    var responseMessage : String = ""
    var progressView:ProgressView?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton=true
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.title="Login Page"
        self.hideKeyboardWhenTappedAround()
        self.progressView = ProgressView(Message: "",
                                         Theme:.Dark,
                                         IsModal:true);
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
    @IBAction func registerUser(_ sender: Any) {
        if phoneNoTF.text?.count==0 || nameTF.text?.count==0
        {
            self.alert(message: "None of the fields can be left empty", title: " ")
        }
        
        else
        {
            //   "Password":"Wmhagiatq!@34"
            let urlType="https://gailebank.gail.co.in/IIIGSurveyAPI/api/User/UserAuthentication"
            let url = URL(string: urlType)
            var request = URLRequest(url: url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let userName = nameTF.text!
            let userMobile = phoneNoTF.text!
            let parameters = ["UserName": "\(userName)", "Password":"\(userMobile)"] as Dictionary<String, String>
                    
            if let postData = (try? JSONSerialization.data(withJSONObject: parameters, options: []))
            {
                request.httpBody = postData
                self.progressView?.show()
                let serviceClassObject = ServiceClass()
                serviceClassObject.delegate = self
                serviceClassObject.getDataPortalStatusWebServiceMethod(urlRequest:request as! NSMutableURLRequest)
            }
            else
                {
                        print("some error occured")
                }
            }}
    
      func successServerResponseMethod(responseDict:NSDictionary)
      {
        self.progressView?.hide()
        
        var dataDict = NSDictionary()
        
        if (responseDict["Message"] as! String?) != nil
        {
            responseMessage = responseDict["Message"] as! String
            
            let dataArr = responseDict["lstInfo"]as! NSArray
            
            if dataArr.count>0
            {
                dataDict = dataArr[0] as! NSDictionary
            }
            print(dataDict)
            
            if responseMessage == "User Authorized to survey"
            {
                UserDefaults.standard.set("LoginSuccess", forKey: "CheckLoginLogout")
                UserDefaults.standard.set(responseDict["EmpName"] as? String, forKey: "EmpName")
                if let userID = (responseDict["CPF"] as? NSString)?.intValue
                {
                    UserDefaults.standard.set(userID, forKey:"UserID")
                    
                }

                UserDefaults.standard.synchronize()
                if responseDict["Type"] as? String == "Number"
                {
                    UserDefaults.standard.set("Number", forKey: "ScreenType")
                    DispatchQueue.main.async
                        {
                            let mainBoard=UIStoryboard(name:"Main", bundle:nil)
                            let homeViewController=mainBoard.instantiateViewController(withIdentifier: "HomeVC")as! HomeViewController
                            self.navigationController?.navigationItem.hidesBackButton = true
                            self.navigationController?.pushViewController(homeViewController, animated: true)
                    }
                }
                
               else if responseDict["Type"] as? String == "Option"
                {
                    UserDefaults.standard.set("Option", forKey: "ScreenType")
                    DispatchQueue.main.async
                        {
                            let mainBoard=UIStoryboard(name:"Main", bundle:nil)
                            let homeViewController=mainBoard.instantiateViewController(withIdentifier: "MediaVC")as! MediaSurveyViewController
                            self.navigationController?.navigationItem.hidesBackButton = true
                            self.navigationController?.pushViewController(homeViewController, animated: true)
                    }
                }
                
                else if responseDict["Type"] as? String == "No Survey Available"
                {
                    UserDefaults.standard.set("Welcome", forKey: "ScreenType")
                    DispatchQueue.main.async
                        {
                            let mainBoard=UIStoryboard(name:"Main", bundle:nil)
                            let homeViewController=mainBoard.instantiateViewController(withIdentifier: "WelcomeVC")as! WelcomeViewController
                            homeViewController.statusMessage = "No Survey Available"
                            self.navigationController?.navigationItem.hidesBackButton = true
                            self.navigationController?.pushViewController(homeViewController, animated: true)
                    }
                }}
                
            else if responseMessage == "User Not Authorized to survey"
            {
                self.alert(message: "You are not authorized to survey", title: "Login Failed")
            }
                
            else
            {
                self.alert(message: "Something went wrong, Please try again", title: "")
            }
        }}
    
    func failureServerResponseMethod(failureResponseMsg:String)
    {
        self.progressView?.hide()
        self.alert(message: "Something went wrong, Please try again", title: "Oops")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


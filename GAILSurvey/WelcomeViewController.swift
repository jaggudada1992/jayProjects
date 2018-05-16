//
//  WelcomeViewController.swift
//  GAILSurvey
//
//  Created by BIS MAC 1 on 17/02/18.
//  Copyright © 2018 BIS MAC 1. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController,PortalStatusServiceDelegate {
    var progressView : ProgressView?
    var responseMessage : String = ""
    var statusMessage :  String = ""
    @IBOutlet weak var statusLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Welcome Screen"
       // Do any additional setup after loading the view.
    }
    
    @IBAction func checkForNewSurvey(_ sender: UIButton) {
        
        self.progressView = ProgressView(Message: "",
                                         Theme:.Dark,
                                         IsModal:true);
        self.progressView?.show()
        
        getNewSurveyList()
    }
    
    func getNewSurveyList()
    {
        let urlType=ConstantClass.kServiceUrl+ConstantClass.kSurveyMotivateType
        let url = URL(string: urlType)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let caseType=UserDefaults.standard.integer(forKey: "UserID")
        print("case type: \(caseType)")
        let parameters = ["CPF_NO": caseType] as Dictionary<String, Any>
        
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
    }

    func successServerResponseMethod(responseDict: NSDictionary) {
        print("response is \(responseDict)")
        self.progressView?.hide()
        if (responseDict["Message"] as! String?) != nil
    {
        responseMessage = responseDict["Message"] as! String
        
        if responseMessage == "You have already submitted your survey"
        {
            self.alert(message: (responseDict["Message"] as? String)!, title:"" )
        }
        else if responseMessage == "There is no survey activated currently"
        {
            self.alert(message: responseMessage, title:"" )
        }
       else if responseMessage == "succuss"
        {
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
        }
        else if responseMessage == "User Not Authorized to survey"
        {
            self.alert(message: "You are not authorized to survey", title: "Failed")
        }
            
        else
        {
            self.alert(message: "Something went wrong, Please try again", title: "Failed")
        }
            
        }}
    
    func failureServerResponseMethod(failureResponseMsg: String)
    {
        print("failed")
        self.progressView?.hide()
        DispatchQueue.main.async
            {
                self.alert(message: failureResponseMsg, title: "")
            }
    }
    
    func tapToDissmissAlert()
    {
        print("dissmiss")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

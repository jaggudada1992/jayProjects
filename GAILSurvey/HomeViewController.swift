//
//  HomeViewController.swift
//  GAILSurvey
//
//  Created by BIS MAC 1 on 06/02/18.
//  Copyright © 2018 BIS MAC 1. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,PortalStatusServiceDelegate,UITextFieldDelegate {

    @IBOutlet weak var factorsList: UITableView!
    var factorArr = NSMutableArray()
    var progressView : ProgressView?
    var factorWeightageArr = NSMutableArray()
    var chooseArr = NSMutableArray()
    var chooseDict = NSMutableDictionary.init()
    @IBOutlet weak var empNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title="Survey On What Motivates You"
        self.hideKeyboardWhenTappedAround()
        factorsList.rowHeight = UITableViewAutomaticDimension
        factorsList.estimatedRowHeight = 140
        self.factorsList.dataSource=self
        self.factorsList.delegate=self
        self.progressView = ProgressView(Message: "",
                                         Theme:.Dark,
                                         IsModal:true);
        self.progressView?.show()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
       if let empName = UserDefaults.standard.string(forKey: "EmpName")
       {
           self.empNameLbl.text = "Welcome " + empName
       }
        
        getMotivateFactorsList()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return factorArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FactorsTableViewCell = factorsList!.dequeueReusableCell(withIdentifier: "FactorId") as! FactorsTableViewCell
        let allData = factorArr[indexPath.row] as? NSDictionary
        cell.factorLbl.text = allData!["FACTOR"] as? String
        cell.ratingTF.delegate = self
        cell.ratingTF.tag = allData!["FACTOR_ID"] as! Int
        let myStr = String(cell.ratingTF.tag)
        if chooseArr.contains(cell.ratingTF.tag)
        {
            cell.ratingTF.text = chooseDict.value(forKey: myStr) as? String
        }
        else
        {
            cell.ratingTF.text = ""
        }
     
        cell.sNoLbl.text = String(indexPath.row+1)
        cell.selectionStyle = .none
        return cell;
    }
    
    func  getMotivateFactorsList() {
        
        let urlType=ConstantClass.kServiceUrl+ConstantClass.kSurveyMotivateType
        let url = URL(string: urlType)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        print("factor weigtage arr:\(factorWeightageArr)")
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
        if responseDict["Message"] as? String == "Successfully Submitted"
        {
            UserDefaults.standard.set("Welcome", forKey: "ScreenType")
            DispatchQueue.main.async
                {
                    let mainBoard=UIStoryboard(name:"Main", bundle:nil)
                    let homeViewController=mainBoard.instantiateViewController(withIdentifier: "WelcomeVC")as! WelcomeViewController
                    self.navigationController?.navigationItem.hidesBackButton = true
                    self.navigationController?.pushViewController(homeViewController, animated: true)
            }
        }
        else if responseDict["Message"] as? String == "You have already submitted your survey"
        {
            UserDefaults.standard.set("Welcome", forKey: "ScreenType")
            DispatchQueue.main.async
                {
                    let mainBoard=UIStoryboard(name:"Main", bundle:nil)
                    let homeViewController=mainBoard.instantiateViewController(withIdentifier: "WelcomeVC")as! WelcomeViewController
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

        else
        {
        if let aboutGAILArr=responseDict["lstInfo"] as? [[String:Any]] {
            for bookDict in aboutGAILArr {
                factorArr.add(bookDict)
            }}
        DispatchQueue.main.async
            {
                self.factorsList?.reloadData()
            }}
        }
   
    
    func failureServerResponseMethod(failureResponseMsg: String)
    {
        print("failed")
        self.progressView?.hide()
        DispatchQueue.main.async
            {
            
            }
    }
    
    func tapToDissmissAlert()
    {
        print("dissmiss")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called & tag is \(textField.tag)")

        let submitDict = NSMutableDictionary.init()
        let myTag = textField.tag
        let myTagStr = String(myTag)
        let myTagVal = Int(textField.text!)
        chooseDict.setValue(textField.text!, forKey:myTagStr)
        chooseArr.add(myTag)
        print("choose dict:\(chooseDict)")
        
        if factorWeightageArr.count>0
        {
           
            for var i in 0..<factorWeightageArr.count {
                
                for (key,value) in factorWeightageArr[i] as! NSMutableDictionary
                {
                    if key as! String == "FACTORS"
                    {
                        print("value : \(value)")

                        if value as? Int == myTag
                        {
                            if (textField.text?.isEmpty)!
                            {
                                print("value1: \(factorWeightageArr[i])")
                                factorWeightageArr.remove(factorWeightageArr[i])
                                return
                            }
                            submitDict.setValue(myTag, forKey: "FACTORS")
                            submitDict.setValue(myTagVal, forKey: "ANSWER")
                            factorWeightageArr.replaceObject(at:i, with: submitDict)
                            return
                        }
                        else if (textField.text?.isEmpty)!
                        {
                             print("still not added")
                        }
                    }
                }
            }
            
            print("returned")
            if !(textField.text?.isEmpty)!
            {
            submitDict.setValue(myTag, forKey: "FACTORS")
            submitDict.setValue(myTagVal, forKey: "ANSWER")
            factorWeightageArr.add(submitDict)
            }
            print("factor array:\(factorWeightageArr)")
          }
        
        else
        {
        if !(textField.text?.isEmpty)! // check textfield contains value or not
        {
            submitDict.setValue(myTag, forKey: "FACTORS")
            submitDict.setValue(myTagVal, forKey: "ANSWER")
            factorWeightageArr.add(submitDict)
            print("factor weigtage arr:\(factorWeightageArr)")
      }
    }
}
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder();
            return true;
        }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
           print("TextField did BEGIN editing method called & tag is \(textField.tag)")
        
           if textField.tag == 0
            {
                
            }
            else
            {
                
            }
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inputStr = textField.text?.appending(string)
        let inputInt = Int(inputStr!)
        if inputInt! >= 0 && inputInt! < 11 {
            return true
        } else {
            return false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitFactors(_ sender: UIButton) {
        print("factor weigtage arr:\(factorWeightageArr)")
        
        if factorWeightageArr.count != factorArr.count {
            print("yes")
            self.alert(message: "Please submit weightage for all factors", title: "Failed")
        }
      else
       {
        let urlType=ConstantClass.kServiceUrl+ConstantClass.kProjectFactorsSubmit
        let url = URL(string: urlType)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        print("factor weigtage arr:\(factorWeightageArr)")
        
        let caseType=UserDefaults.standard.integer(forKey: "UserID")
        print("case type: \(caseType)")

        let parameters = ["CPF_NO": caseType , "SurveyDetails":factorWeightageArr] as Dictionary<String, Any>
        
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

//
//  MediaSurveyViewController.swift
//  GAILSurvey
//
//  Created by BIS MAC 1 on 06/02/18.
//  Copyright © 2018 BIS MAC 1. All rights reserved.
//

import UIKit

class MediaSurveyViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,PortalStatusServiceDelegate {

    @IBOutlet weak var mediaFctTbl: UITableView!
    var mediaFactorArr = NSMutableArray()
     var isSelected = true
    var progressView : ProgressView?
    var factorWeightageArr = NSMutableArray()
    var selectedPaths=Set<IndexPath>()
    var selectedNoPaths = Set<IndexPath>()
    @IBOutlet weak var empNameLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title="Survey On Digital Maturity"
        mediaFctTbl.rowHeight = UITableViewAutomaticDimension
        mediaFctTbl.estimatedRowHeight = 140
        self.mediaFctTbl.dataSource=self
        self.mediaFctTbl.delegate=self
        self.mediaFctTbl.tableFooterView = UIView()

        self.progressView = ProgressView(Message: "",
                                         Theme:.Dark,
                                         IsModal:true);
        self.progressView?.show()
        
        if let empName = UserDefaults.standard.string(forKey: "EmpName")
        {
            self.empNameLbl.text = "Welcome " + empName
        }
        
        getDigitalMaturityList()
        
        // Do any additional setup after loading the view.
    }

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return mediaFactorArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : FactorsTableViewCell = mediaFctTbl!.dequeueReusableCell(withIdentifier: "MediaFactorId") as! FactorsTableViewCell
        let allData = mediaFactorArr[indexPath.row] as? NSDictionary
        cell.factorLbl.text = allData!["FACTOR"] as? String
        cell.sNoLbl.text = String(indexPath.row+1)
        cell.selectBtn.addTarget(self, action:#selector(MediaSurveyViewController.tapToCheck), for: .touchUpInside)
        cell.selectBtn.tag = allData!["FACTOR_ID"] as! Int
        cell.noSelectBtn.tag = allData!["FACTOR_ID"] as! Int
        cell.selectionStyle = .none
        return cell;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func  getDigitalMaturityList() {
        
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
        
        if responseDict["Message"] as? String == "Successfully Submitted"
        {
           // self.alert(message: (responseDict["Message"] as? String)!, title: "Success")
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
            
       else if responseDict["Type"] as? String == "Number"
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
            
        else
        {
            if let aboutGAILArr=responseDict["lstInfo"] as? [[String:Any]] {
                for bookDict in aboutGAILArr {
                    mediaFactorArr.add(bookDict)
                }}
            DispatchQueue.main.async
                {
                    self.mediaFctTbl?.reloadData()
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
    

    @objc func tapToCheck(sender:UIButton!)
    {
        print("clicked")
        let submitDict = NSMutableDictionary.init()
        let myTagVal = sender.tag
        var chooseString = ""
        
        if let cell = sender.superview?.superview as? FactorsTableViewCell {
            let indexPath = mediaFctTbl.indexPath(for: cell)
            
            var image = UIImage(named: "checkRound.png")
            if self.selectedPaths.contains(indexPath!)
            {
                image = UIImage(named: "uncheck.png")
                self.selectedPaths.remove(indexPath!)
                chooseString = "Nothing to say"
                sender.setImage(UIImage(named: "uncheck.png"), for: .normal)
               
                if factorWeightageArr.count>0
                {
                    
                    for var i in 0..<factorWeightageArr.count {
                        
                        for (key,value) in factorWeightageArr[i] as! NSMutableDictionary
                        {
                            if key as! String == "FACTORS"
                            {
                                
                                if value as? Int == myTagVal
                                {
                                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                                    submitDict.setValue(chooseString, forKey: "ANSWER")
                                    factorWeightageArr.replaceObject(at:i, with: submitDict)
                                    print("weitage arr:\(factorWeightageArr)")
                                    return
                                }
                            }
                        }
                    }
                    
                    print("returned")
                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                    submitDict.setValue(chooseString, forKey: "ANSWER")
                    factorWeightageArr.add(submitDict)
                }
                else
                {
                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                    submitDict.setValue(chooseString, forKey: "ANSWER")
                    factorWeightageArr.add(submitDict)
                }
            }
                    
                else {
                chooseString = "YES"
                sender.setImage(UIImage(named: "checkRound.png"), for: .normal)
                submitDict.setValue(myTagVal, forKey: "FACTORS")
                submitDict.setValue(chooseString, forKey: "ANSWER")
                self.selectedPaths.insert(indexPath!)
                self.selectedNoPaths.remove(indexPath!)

                if (cell.noSelectBtn.currentImage?.isEqual(UIImage(named: "checkRound.png")))! {
                    cell.noSelectBtn.setImage(UIImage(named:"uncheck.png"), for: .normal)
                }
                if factorWeightageArr.count>0
                {
                    
                    for var i in 0..<factorWeightageArr.count {
                        
                        for (key,value) in factorWeightageArr[i] as! NSMutableDictionary
                        {
                            if key as! String == "FACTORS"
                            {
                                
                                if value as? Int == myTagVal
                                {
                                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                                    submitDict.setValue(chooseString, forKey: "ANSWER")
                                    factorWeightageArr.replaceObject(at:i, with: submitDict)
                                    print("weitage arr:\(factorWeightageArr)")
                                    return
                                }
                            }
                        }
                    }
                    
                    print("returned")
                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                    submitDict.setValue(chooseString, forKey: "ANSWER")
                    factorWeightageArr.add(submitDict)
                }
                else
                {
                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                    submitDict.setValue(chooseString, forKey: "ANSWER")
                    factorWeightageArr.add(submitDict)
                }
            }
            
        }
        
            print("factor weigtage arr in yes:\(factorWeightageArr)")
    }
    
    
    @IBAction func noChoiceAction(_ sender: UIButton) {
        
        let submitDict = NSMutableDictionary.init()
        let myTagVal = sender.tag
        var chooseString = ""
        
        if let cell = sender.superview?.superview as? FactorsTableViewCell {
            let indexPath = mediaFctTbl.indexPath(for: cell)
            
            print("selected no paths arr count:\(selectedNoPaths.count)")
            
            var image = UIImage(named: "checkRound.png")
            if self.selectedNoPaths.contains(indexPath!)
            {
                image = UIImage(named: "uncheck.png")
                self.selectedNoPaths.remove(indexPath!)
                chooseString = "Nothing to say"
               
                sender.setImage(UIImage(named: "uncheck.png"), for: .normal)
                
                if factorWeightageArr.count>0
                {
                    
                    for var i in 0..<factorWeightageArr.count {
                        
                        for (key,value) in factorWeightageArr[i] as! NSMutableDictionary
                        {
                            if key as! String == "FACTORS"
                            {
                                
                                if value as? Int == myTagVal
                                {
                                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                                    submitDict.setValue(chooseString, forKey: "ANSWER")
                                    factorWeightageArr.replaceObject(at:i, with: submitDict)
                                    return
                                }
                            }
                        }
                    }
                    
                    print("returned")
                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                    submitDict.setValue(chooseString, forKey: "ANSWER")
                    factorWeightageArr.add(submitDict)
                }
                else
                {
                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                    submitDict.setValue(chooseString, forKey: "ANSWER")
                    factorWeightageArr.add(submitDict)
                }
            }
                
            else {
                chooseString = "NO"
                sender.setImage(UIImage(named: "checkRound.png"), for: .normal)
                submitDict.setValue(myTagVal, forKey: "FACTORS")
                submitDict.setValue(chooseString, forKey: "ANSWER")
                self.selectedPaths.remove(indexPath!)
                self.selectedNoPaths.insert(indexPath!)
                if (cell.selectBtn.currentImage?.isEqual(UIImage(named: "checkRound.png")))! {
                    cell.selectBtn.setImage(UIImage(named:"uncheck.png"), for: .normal)
                }
                if factorWeightageArr.count>0
                {
                    
                    for var i in 0..<factorWeightageArr.count {
                        
                        for (key,value) in factorWeightageArr[i] as! NSMutableDictionary
                        {
                            if key as! String == "FACTORS"
                            {
                                
                                if value as? Int == myTagVal
                                {
                                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                                    submitDict.setValue(chooseString, forKey: "ANSWER")
                                    factorWeightageArr.replaceObject(at:i, with: submitDict)
                                    print("weitage arr in no:\(factorWeightageArr)")
                                    return
                                }
                            }
                        }
                    }
                    
                    print("returned")
                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                    submitDict.setValue(chooseString, forKey: "ANSWER")
                    factorWeightageArr.add(submitDict)

                }
                else
                {
                    submitDict.setValue(myTagVal, forKey: "FACTORS")
                    submitDict.setValue(chooseString, forKey: "ANSWER")
                    factorWeightageArr.add(submitDict)
                
               }
            }
        }
        
        print("factor weigtage arr in NO:\(factorWeightageArr)")
    }
    
    @IBAction func submitMediaFactors(_ sender: UIButton)
    
    {
        if factorWeightageArr.count==0 {
            
            self.alert(message: "Please choose aginst atleast one of the above digital media platforms", title: "")
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

        let parameters = ["CPF_NO": caseType, "SurveyDetails":factorWeightageArr] as Dictionary<String, Any>
        
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50.0
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

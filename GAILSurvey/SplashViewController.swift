//
//  SplashViewController.swift
//  GAILSurvey
//
//  Created by BIS MAC 1 on 06/02/18.
//  Copyright © 2018 BIS MAC 1. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=true;
        
        if let caseType=UserDefaults.standard.string(forKey:"ScreenType")
        {
            if caseType=="Number"
            {
                self.perform(#selector(SplashViewController.tapToHomeView), with: nil, afterDelay: 2)
            }
            else if caseType=="Option"
            {
                self.perform(#selector(SplashViewController.tapToMediaSurveyView), with: nil, afterDelay: 2)
            }
            else if caseType=="Welcome"
            {
                self.perform(#selector(SplashViewController.tapToWelcomeView), with: nil, afterDelay: 2)
            }
        }
        else
            
        {
            self.perform(#selector(SplashViewController.tapToLoginView), with: nil, afterDelay: 2)
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tapToLoginView(sender:AnyObject)
    {
        self.navigationController?.navigationBar.isHidden=false;
        let mainBoard=UIStoryboard(name: "Main", bundle: nil)
        let loginVC=mainBoard.instantiateViewController(withIdentifier: "LoginVC")as! ViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
  
    @objc func tapToHomeView(sender:AnyObject)
    {
        self.navigationController?.navigationBar.isHidden=false;
        let mainBoard=UIStoryboard(name:"Main", bundle:nil)
        let homeViewController=mainBoard.instantiateViewController(withIdentifier:"HomeVC")as! HomeViewController
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    @objc func tapToWelcomeView(sender:AnyObject)
    {
        self.navigationController?.navigationBar.isHidden=false;
        let mainBoard=UIStoryboard(name:"Main", bundle:nil)
        let homeViewController=mainBoard.instantiateViewController(withIdentifier:"WelcomeVC")as! WelcomeViewController
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    @objc func tapToMediaSurveyView(sender:AnyObject)
    {
       self.navigationController?.navigationBar.isHidden=false;
       let mainBoard=UIStoryboard(name:"Main", bundle:nil)
       let mediaViewController=mainBoard.instantiateViewController(withIdentifier: "MediaVC")as! MediaSurveyViewController
       self.navigationController?.pushViewController(mediaViewController, animated: true)
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

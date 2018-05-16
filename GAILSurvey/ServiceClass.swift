//
//  ServiceClass.swift
//  PortalStatusApp
//
//  Created by Akal InfoSys-2 on 8/19/17.
//  Copyright © 2017 Akal InfoSys.com created by navin yadav. All rights reserved.
//

import UIKit

protocol PortalStatusServiceDelegate
{
    func successServerResponseMethod(responseDict:NSDictionary)
    func failureServerResponseMethod(failureResponseMsg:String)
}

class ServiceClass: NSObject
{
    var delegate:PortalStatusServiceDelegate?
    
    func getDataPortalStatusWebServiceMethod(urlRequest:NSMutableURLRequest)
    {
        print("request:\(urlRequest)")
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest)
        { data,response,error in
            
            
            if error != nil
            {
                //check the network status here
                print("show error message",error)
                self.delegate?.failureServerResponseMethod(failureResponseMsg:"internet connection issue...")
                
                return
            }
            do
            {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
    
                print("response is \(json)")
                
                        //let responseArr = json?["eventData"]as! NSArray
                self.delegate?.successServerResponseMethod(responseDict:json!)
                }
            catch let error as NSError
            {
                print(error)
                
            }
        }
        task.resume()
        
    }
    


}

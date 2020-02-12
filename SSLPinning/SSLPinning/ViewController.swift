//
//  ViewController.swift
//  SSLPinning
//
//  Created by Bhavin Trivedi on 2/11/20.
//  Copyright © 2020 Bhavin Trivedi. All rights reserved.
//

import UIKit


//MARK: Initialize certificate or directly add certificate.
//MARK: Use below commands to initialize certificates 
//MARK: openssl s_client -connect api.stackexchange.com:443 </dev/null
/*openssl s_client -connect api.stackexchange.com:443 </dev/null \
| openssl x509 -outform DER -out stackexchange.com.der*/


class ViewController: UIViewController, URLSessionDelegate {
    let certi = "stackexchange.com"
    let corrupted = "corrupted"
    var urlSession: URLSession!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        callAPI()
    }
    
    func callAPI() {
        let url = URL.init(string: "https://api.stackexchange.com/2.2/users?order=desc&sort=reputation&site=stackoverflow")!
        let request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        urlSession.dataTask(with: request) { (data, response, error) in
            print("Error : \(String(describing: error)) data: \(String(describing: data)) response: \(String(describing: response))")
        }.resume()
        /*
        urlSession.dataTask(with:url) { (data, response, error) in
            print("Error : \(String(describing: error)) data: \(String(describing: data)) response: \(String(describing: response))")
        }.resume()*/
    }
    

    // MARK: URL session delegate
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let serverTrust = challenge.protectionSpace.serverTrust
        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)
        
        // Set SSL policies for domain name check
        //Set policy to validate domain
        let policy: SecPolicy = SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString))
        let policies = NSArray.init(object: policy)
        SecTrustSetPolicies(serverTrust!, policies)
        // Evaluate server certificate
        var result: SecTrustResultType = SecTrustResultType(rawValue: 0)!
        SecTrustEvaluate(serverTrust!, &result)
        let isServerTrusted = (result == .unspecified || result == .proceed)

        // Get local and remote cert data
        let remoteCertificateData:NSData = SecCertificateCopyData(certificate!)
        //MARK: use corrupted for negative scenario
        guard let pathToCert = Bundle.main.path(forResource: certi, ofType: "cer") else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return }
        let data = try! Data(contentsOf: URL(fileURLWithPath: pathToCert))
        
        if (isServerTrusted && remoteCertificateData.isEqual(to: data)) {
            let credential:URLCredential = URLCredential.init(trust: serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}


//
//  ViewController.swift
//  DarwinCoreTest
//
//  Created by 孔祥波 on 16/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

import UIKit
import DarwinCore
import AVFoundation
class ViewController: UIViewController {
    //let r = DNSResolver()
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        print_free_memory()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func test()  {
        DNS.loadSystemDNSServer()
        let string = Route.currntRouter() as String
        print(string)
        myUtterance = AVSpeechUtterance(string: "你好,www.freebsdchina.org")
        myUtterance.rate = AVSpeechUtteranceMaximumSpeechRate * 0.5
        synth.speak(myUtterance)
        for _ in 0..<2{
            testReolover(host: "www.freebsdchina.org",r:DNSResolver())
        }
        
        
    }
    func testReolover(host:String,r:DNSResolver) {
        r.hostname = host
        r.querey(host) { (record) in
            
            if let record = record {
                print("#####++++" + record.ipaddress)
            }else {
                print("error")
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


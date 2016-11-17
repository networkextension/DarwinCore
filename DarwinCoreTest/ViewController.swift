//
//  ViewController.swift
//  DarwinCoreTest
//
//  Created by 孔祥波 on 16/11/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

import UIKit
import DarwinCore
class ViewController: UIViewController {
    let r = DNSResolver()
    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func test()  {
        DNS.loadSystemDNSServer()
        let string = Route.currntRouter() as String
        print(string)
        testReolover(host: "www.freebsdchina.org")
        
    }
    func testReolover(host:String) {
        r.hostname = "www.freebsdchina.org"
        r.querey(host) { (record) in
            
            if let record = record {
                print(record.ipaddress)
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


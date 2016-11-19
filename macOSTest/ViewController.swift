//
//  ViewController.swift
//  macOSTest
//
//  Created by yarshure on 2016/11/19.
//  Copyright © 2016年 Kong XiangBo. All rights reserved.
//
import Foundation
import Cocoa
import DarwinCore

class ViewController: NSViewController {
    let r = DNSResolver()
    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        // Do any additional setup after loading the view.
    }

    func test()  {
        DNS.loadSystemDNSServer()
       
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


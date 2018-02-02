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

class ViewController: NSViewController,ClientDelegate {
    let r = DNSResolver()
    //var clients:[Client] = []
    let que = DispatchQueue.init(label: "server")
    let socketQueue = DispatchQueue.init(label: "server.socket")
    var clientTree:AVLTree = AVLTree<Int32,Client>()
    let s = GCDSocket.init(remoteaddr: "www.baidu.com", port: "80")
    var manager:TManager!
    let server = GCDSocketServer.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        que.async {
           
        }
        que.async {
            //dtls_client()
        }
        let s = GCDSocket.init(remoteaddr: "www.apple.com", port: "443")
        print(s)
        self.manager  = TManager.init(dq: self.que, sq: self.socketQueue,share: true)
        test()
        testServer()
        
        
        if let path = proPath(52453){
            print(path)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func clientDead(c:Client){
        let fd = c.fd
        close(fd)
        
        
    }

    func testServer(){
        
            server.accept = { fd,addr,port in
                let c = Client.init(sfd: fd, delegate: self, q: DispatchQueue.main)
                //self.clients.append(c);
                self.clientTree.insert(key: fd, payload: c)
                c.connect()
                print("\(fd) \(String(describing: addr)) \(port)")
            }
            server.colse = { fd in
                print("\(fd) close")
                //self.clientTree.delete(key: fd)
                if let c = self.clientTree.search(input: fd){
                    c.forceClose()
                    self.clientTree.delete(key: fd)
                }
            }
            server.incoming  = { fd ,data in
                print("\(fd) \(String(describing: data))")
//                for c in self.clients {
//                    if c.fd == fd {
//                        c.incoming(data: data!)
//                    }
//                }
                if let c = self.clientTree.search(input: fd){
                    c.incoming(data: data)
                }
                //server.server_write_request(fd, buffer: "wello come\n", total: 11);
            }
            //let q = DispatchQueue.init(label: "dispatch queue")
        
        
    }
    @IBAction func startServer(_ sender:Any){
       server.start(10082, dispatchQueue: DispatchQueue.main, socketQueue: socketQueue, share: false)
    }
    @IBAction func stop(_ sender:Any){
        server.stop()
    }
    func test()  {
        
        guard let dns = DNS.loadSystemDNSServer() else {
            fatalError("dns get error")
        }
        print(dns)
       
       
        
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

    @IBAction func testRouter(_ sender: Any) {
        for _ in 0..<10000 {
            let string = Route.currntRouterInet4(true, defaultRouter: false) as String
            print(string.count)
        }
    }
    @IBAction func testSocketRW(_ sender: Any) {
        manager.start()
        s.dispatchQueue = self.que
        s.socketQueue = self.socketQueue
        let getStr = """
        HEAD / HTTP/1.1\r\n
        Host: www.baidu.com\r\n
        User-Agent: curl/7.54.0\r\n
        Accept: */*\r\n\r\n
        """
        s.write(getStr.data(using: .utf8)!) { (e) in
            if let e = e {
                print(e.localizedDescription)
                self.s.closeReadWithError(e)
            }else {
                self.getData()
            }
        }
    }
    func getData(){
        
        s.read { (d, e) in
            if let e = e {
                print(e.localizedDescription)
            }else {
                guard let d = d else {
                    
                    self.s.closeReadWithError(nil)
                    return
                }
                print("\(d as NSData)")
                self.getData()
            }
        }
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


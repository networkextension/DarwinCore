//
//  Client.swift
//  DarwinCore
//
//  Created by yarshure on 2017/8/17.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

import Foundation
import Darwin
protocol ClientDelegate {
    func clientDead(c:Client);
}
import DarwinCore
import CocoaAsyncSocket
import os.log
class Client: NSObject,GCDAsyncSocketDelegate {

    var fd:Int32 = 0
    var socket:GCDAsyncSocket?
    
    var queue:DispatchQueue
    var delegate:ClientDelegate
    init(sfd:Int32,delegate:ClientDelegate, q:DispatchQueue) {
        fd = sfd
        self.delegate = delegate
        queue = q
    }
    func connect(){
        self.socket = GCDAsyncSocket.init(delegate: self, delegateQueue: self.queue)
        
        do {
            try self.socket?.connect(toHost: "192.168.2.79", onPort: 8000)
        }catch let e {
            print(e.localizedDescription)
        }
        
        
    }
    func incoming(data:Data){
        guard let ss = self.socket else {return}
        ss.write(data, withTimeout: 1, tag: 0)
    }
    func forceClose(){
        if let s = self.socket, s.isConnected {
            s.delegate = nil
            s.disconnectAfterWriting()
        }
        //self.delegate.clientDead(c: self)
    }
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16){
        guard let s = self.socket else {return}
        s.readData(withTimeout: 10, tag: -1);
    }
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int){
        let s = GCDSocketServer.shared()
        
        
        s.server_write_request(self.fd, data: data) { (t, x, i) in
            self.socket!.readData(withTimeout: 10, tag: 1);
        }
       
        
    }
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?){
        if let e = err {
            os_log("socketDidDisconnect %@" ,e.localizedDescription)
        }
        
        self.delegate.clientDead(c: self)
    }
}
extension Client:Comparable{
    public static func <(lhs: Client, rhs: Client) -> Bool {
        return lhs.fd < rhs.fd
    }
}

//
//  TServer.swift
//  macOSTest
//
//  Created by yarshure on 2018/1/1.
//  Copyright © 2018年 Kong XiangBo. All rights reserved.
//

import Foundation
import DarwinCore
class TManager {
    var sq:DispatchQueue!
    var dq:DispatchQueue!
    var s:SocketServer!
    var ss:[GCDSocket] = []
    init(dq:DispatchQueue, sq:DispatchQueue) {
        self.sq = sq
        self.dq = dq
        s = SocketServer.init(5000, dispatchQueue: self.dq, socketQueue: self.sq)
    }
    func start() {
        s?.start({ (socket) in
            if let so = socket {
                self.ss.append(so)
                so.dispatchQueue = self.dq
                so.socketQueue = self.sq
                self.read(socket: so)
            }
        })
    }
    func read(socket:GCDSocket){
        socket.read(completionHandler: { (d, e) in
            if let e = e {
                print(e.localizedDescription)
            }else {
                guard let d = d else {
                    socket.closeReadWithError(nil)
                    return
                }
                self.writ(socket: socket, data: d)
            }
        })
    }
    func writ(socket:GCDSocket,data:Data){
        socket.write(data) { (e) in
            if let e = e {
                print(e)
            }else {
                self.read(socket: socket)
            }
        }
    }
}

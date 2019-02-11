//
//  iPv6Socket.swift
//  Pencil
//
//  Created by Lakr Sakura on 2018/8/7.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

import Foundation
import Socket


func sendStringWithiPv6Address(saying: String, port: Int){
    print("[iPv6] Sending " + saying + "to server at:" + iPv6Addr + ":" + String(port))
    do {
        let rocket6 = try Socket.create(family: .inet6, type: .stream, proto: .tcp)
        do {
            _ = try rocket6.connect(to: iPv6Addr, port: Int32(port))
                    do {
                        _ = try rocket6.write(from: saying)
                    } catch {
                        print("[iPv6] [Error] Failed to send to server.")
                    }
        } catch {
            print("[iPv6] [Error] Failed to connect to server.")
        }
        rocket6.close()
    } catch {
        print("[iPv6] [Error] Failed to create a socket.")
    }
    return
}

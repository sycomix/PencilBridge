//
//  Extensions.swift
//  Pencil
//
//  Created by Lakr Sakura on 2018/7/31.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

import Foundation
import UIKit
import SwiftSocket

var pForce: CGFloat = -1         //1
var pRotation: CGFloat = -1      //2
var pAlt: CGFloat = -1           //3
var pStatus: Int = -1            //4
var pLocationX: CGFloat = -1     //5
var pLocationY: CGFloat = -1     //6

var FingerX: CGFloat = -1
var FingerY: CGFloat = -1

var required_MSGNO_Reset: Bool = false
var client_Exist: Bool = false
let rocket = TCPClient(address: "!!Unset", port: -1)

func fDetail_init(FX: CGFloat, FY: CGFloat) {
    FingerX = FX
    FingerY = FY
}

func pDetail_init(ipForce: CGFloat, ipRotation: CGFloat, ipAlt: CGFloat, ipStatus: Int, ipLocationX: CGFloat, ipLocationY: CGFloat) {
    pForce = ipForce
    pRotation = ipRotation
    pAlt = ipAlt
    pStatus = ipStatus
    pLocationX = ipLocationX
    pLocationY = ipLocationY
}

func update_Pecile_Datebase() {
    //Send Http Request.
    _ = sendToLaptop(StartID: pStatus)
}

func update_touch_Datebase() {
    _ = sendToLaptop(StartID: 4)
}

func ResetMessageNumber() {
    MessgaeNO = 0
    _ = sendWithString(str: "|COMMAND|RESETMSGNO|END|")
    usleep(5)
    _ = sendWithString(str: "|COMMAND|RESETMSGNO|END|")
    usleep(5)
    _ = sendWithString(str: "|COMMAND|RESETMSGNO|END|")
    required_MSGNO_Reset = false
}

func sendToLaptop(StartID: Int) -> Int {
    if 0 == 1 {                                     //for beauty
    }else if StartID == 1 || StartID == 0{          //Post Touch Begin
        _ = sendWithString(str: ("MNO" + String(MessgaeNO) + "|UpdateStatus|Pen|TouchesBegin|END|"))
    }else if StartID == 2{                          //Post Drawing Details
        let intPForce = Int(1000 * pForce)
        let intPRotat = Int(pRotation + 180)
        let intPAlt   = Int(pAlt)
        let intPXLoca = Int(pLocationX)
        let intPYLoca = Int(pLocationY)
        _ = sendWithString(str:
            ("MNO" + String(MessgaeNO) + "|UpdateStatus|Pen|TouchesMoved|pF" + String(intPForce) + "|pR" + String(intPRotat) + "|pA" + String(intPAlt) + "|pX" + String(intPXLoca) + "|pY" + String(intPYLoca) + "|END|"))
    }else if StartID == 3{                          //Post Drawing Stop
        _ = sendWithString(str: ("MNO" + String(MessgaeNO) + "|UpdateStatus|Pen|TouchesStoped|END|"))
    }else if StartID == 4{                          //Post Poniter move
        let intFXLoca = Int(FingerX)
        let intFYLoca = Int(FingerY)
        _ = sendWithString(str: ("MNO" + String(MessgaeNO) + "|UpdateStatus|Finger|FX" + String(intFXLoca) + "|FY" + String(intFYLoca) + "|END|"))
    }else if StartID == 5{                          //Test
        _ = sendWithString(str: "HANDSHAKE!")
    }else if StartID == 6{                          //Addition Info Finger Touch Begin
        _ = sendWithString(str: ("MNO" + String(MessgaeNO) + "|UpdateStatus|Finger|TouchesBegin|END|"))
    }else if StartID == 7{                          //Addition Info Finger Touch Ended
        _ = sendWithString(str: ("MNO" + String(MessgaeNO) + "|UpdateStatus|Finger|TouchesStoped|END|"))
    }else{
        return -1                                   //Handle Errors
    }
    return 0
}

func sendWithString(str: String) -> Int {
    if URLStr == "127.0.0.1" { return -9 }
    MessgaeNO += 1
    if MessgaeNO >= 65500 {
        required_MSGNO_Reset = true
    }
    if isiPv6 {
        sendStringWithiPv6Address(saying: str, port: TargetPort)
        return 6
    }
    print("[Network] Sending message {", str, "} to server{", URLStr,":", TargetPort)
    let rocket = TCPClient(address: URLStr, port: Int32(TargetPort))
    rocket.close()
    switch rocket.connect(timeout: 1) {
    case .success: //Socket built
        switch rocket.send(string: str) {
        case .success: //Do nothing.
            rocket.close()
            return 0
        case .failure(_): break
        }
    default: break
    }
    rocket.close()
    print("[Error] Failed to send message to host.")
    return -1
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: convertFromCATransitionType(CATransitionType.fade))
    }
}


func changeTargetPort(withTip: String, selfIN: UIViewController) {
    //1. Create the alert controller.
    let alert = UIAlertController(title: "Change Port", message: withTip, preferredStyle: .alert)
    //2. Add the text field. You can configure it however you need.
    alert.addTextField { (textField) in
        textField.text = String(TargetPort)
    }
    // 3. Grab the value from the text field, and print it when the user clicks OK.
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
        let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
        let str: String! = String(describing: textField?.text)
        //Fixing string for convert Int()
        var NONStr: String! = str!
        var i = 0
        while i < 10 {
            i += 1
            NONStr.removeFirst()
        }
        i = 0
        while i < 2 {
            i += 1
            NONStr.removeLast()
        }
        print("[System] Changing Target Port to :" + NONStr)
        let PortCa = Int(NONStr)
        if PortCa == nil {
            print("[System] Port number nil.")
            //Rerun this function
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                changeTargetPort(withTip: "Try another port > 2222 or leave it.", selfIN: selfIN)
                return
            })
            return
        }
        let PortC: Int! = PortCa!
        if PortC <= 2222 || 65533 <= PortC {
            print("[System] Port number not allowed.")
            //Rerun this function
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                changeTargetPort(withTip: "Try another port > 2222 or leave it.", selfIN: selfIN)
                return
            })
            return
        }
        TargetPort = PortC
    }))
    
    // 4. Present the alert.
    selfIN.present(alert, animated: true, completion: nil)
}


func validateIpAddress(ipToValidate: String, checkiPv6: Bool) -> Bool {
    
    var sin = sockaddr_in()
    var sin6 = sockaddr_in6()
    
    if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
        // IPv6 peer.
        if checkiPv6{
            return true
        }else{
            return false
        }
    }
    else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
        // IPv4 peer.
        if checkiPv6{
            return false
        }
        return true
    }
    
    return false;
}

/*
 说了你又不听
 听了你又不懂
 懂了你又不做
 做了你又做错
 错了你又不认
 认了你又不改
 改了你又不服
 不服你又不说
 你要我怎么说你呐
 */

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATransitionType(_ input: CATransitionType) -> String {
	return input.rawValue
}

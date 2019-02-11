//
//  iPViewController.swift
//  Pencil
//
//  Created by Lakr Sakura on 2018/8/2.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

import Foundation
import UIKit
import SwiftSocket

var debug_enable: Int = -1
var isUpdatedFromQRCode: Bool = false

class iPViewController: UIViewController {
    
    @IBOutlet weak var iP1: UITextField!
    @IBOutlet weak var iP2: UITextField!
    @IBOutlet weak var iP3: UITextField!
    @IBOutlet weak var iP4: UITextField!
    
    @IBOutlet weak var ContiuneButton: UIButton!
    
    @IBAction func PushWork(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.ContiuneButton.fadeTransition(0.2)
            self.ContiuneButton.setTitle("Trying TCP", for: .normal)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.makeitWork(needAlert: true)
        }
    }
    
    @IBAction func DebugWay(_ sender: Any) {
        debug_enable += 1
        if debug_enable >= 2 {
            print("[Lakr] Debug push VC started")
            makeitWork(needAlert: false)
            pushToVC()
        }
    }
    
    @IBAction func ForcePush(_ sender: Any) {
        let FAlert = UIAlertController(title: "Force To Do?", message: "\nWe will force to set server iP to 127.0.0.1 to make sure you can see details smoothly.", preferredStyle: .alert)
        let FAlert_OK = UIAlertAction(title: "OK", style: .default, handler: {ACTION in
            self.iP1.text = "127"
            self.iP2.text = "0"
            self.iP3.text = "0"
            self.iP4.text = "1"
            self.makeitWork(needAlert: false)
            self.pushToVC()})
        let FAlert_Retry = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        FAlert.addAction(FAlert_OK)
        FAlert.addAction(FAlert_Retry)
        self.present(FAlert, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iP1.text = String(TargetIPAddr_1)
        iP2.text = String(TargetIPAddr_2)
        iP3.text = String(TargetIPAddr_3)
        iP4.text = String(TargetIPAddr_4)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setTiltBack()
    }
    
    
    func handleInputError() -> () {
        ContiuneButton.setTitle("Error in input.>Retry", for: .normal)
    }
    
    @IBAction func iP1PrimaryAction(_ sender: Any) {
        iP2.becomeFirstResponder()
    }
    @IBAction func iP2PrimaryAction(_ sender: Any) {
        iP3.becomeFirstResponder()
    }
    @IBAction func iP3PrimaryAction(_ sender: Any) {
        iP4.becomeFirstResponder()
    }
    @IBAction func iP4PrimaryAction(_ sender: Any) {
        iP4.endEditing(true)
        makeitWork(needAlert: true)
    }
    
    
    @IBAction func ChangePortPushed(_ sender: Any) {
        changeTargetPort(withTip: "If you don't know what it is, leave it and push OK.", selfIN: self)
    }    
    
    func makeitWork(needAlert: Bool) -> () {
        
        guard let iPN1 = iP1.text else { handleInputError(); return }
        guard let iPN2 = iP2.text else { handleInputError(); return }
        guard let iPN3 = iP3.text else { handleInputError(); return }
        guard let iPN4 = iP4.text else { handleInputError(); return }
        
        if Int(iPN1) == nil || Int(iPN2) == nil || Int(iPN3) == nil || Int(iPN4) == nil {
            handleInputError()
            return
        }
        
        TargetIPAddr_1 = Int(iPN1)!
        TargetIPAddr_2 = Int(iPN2)!
        TargetIPAddr_3 = Int(iPN3)!
        TargetIPAddr_4 = Int(iPN4)!

        //Make a URL
        URLStr = String(TargetIPAddr_1) + "." + String(TargetIPAddr_2) + "." + String(TargetIPAddr_3) + "." + String(TargetIPAddr_4)
        if validateIpAddress(ipToValidate: URLStr, checkiPv6: false) != true {
            handleInputError()
            return
        }
        
        print("[Setup] Setting gobal url as:", URLStr)
        
        //Ready for socket sending.
        let client_as_TCP = TCPClient(address: URLStr, port: Int32(TargetPort))
        switch client_as_TCP.connect(timeout: 6) {
            case .success: //Socket built
                print("[Network] |Status| Socket built successfully.")
                            switch client_as_TCP.send(string: "[Handshake] Client_toPencil_Trying_Connect.Close_socket_if_you_don't_build_it_as_you_want." ) {
                                case .success://Socket send successfully
                                    print("[Network] |Status| Socket sent successfully.")
                                    pushToVC()
                                    /*
                                    //Waitting for message to be send back.
                                    sleep(1);
                                    guard let data = client_as_TCP.read(1024*10) else { print("[Error] Guard let error."); client_as_TCP.close(); sleep(1); setTiltBack(); return }
                                                if let response = String(bytes: data, encoding: .utf8) {
                                                    print("[Network] Recived data:", response)
                                                    
                                                            if (response == "HANDSHAKE!") {  //Recived setup handshake
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                                    client_as_TCP.close()
                                                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                                                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "drawViewController") as! drawViewController
                                                                    self.present(nextViewController, animated:true, completion:nil)
                                                                    client_as_TCP.close()
                                                                    return
                                                                }
                                                                //Recived wrong data. Alert handle
                                                                if needAlert != true { return }
                                                                let FAlert = UIAlertController(title: "Failed", message: ("\nWe have recived a wrong handshake message from server. \n It could be a fake server while it might be a bug, too. \n\nProccess anywhay? \n\nMessage from server:\n" + response), preferredStyle: .alert)
                                                                let FAlert_OK = UIAlertAction(title: "Proccess", style: .default, handler: { ACTION in self.pushToVC() })
                                                                let FAlert_Retry = UIAlertAction(title: "No", style: .cancel, handler: nil)
                                                                FAlert.addAction(FAlert_OK)
                                                                FAlert.addAction(FAlert_Retry)
                                                                self.present(FAlert, animated: true) { print("[Info] Failed Alert Presented.") }
                                                                client_as_TCP.close()
                                                                setTiltBack();
                                                                return
                                                    }
                                        break
                                    }
                                 */
                                case .failure( _): break
                }
        case .failure( _): break
        }
        print("[Error] Connect to server(", URLStr, ") Failed.")
        if needAlert != true { return }
        let FAlert = UIAlertController(title: "Failed", message: "\nWe are not able to build connection to your laptop server app. \n\nCheck the iP address? Does our app currently running on laptop?", preferredStyle: .alert)
        let FAlert_OK = UIAlertAction(title: "OK", style: .default, handler: nil)
        let FAlert_Retry = UIAlertAction(title: "Retry", style: .cancel) { ACTION in self.makeitWork(needAlert: true) }
        FAlert.addAction(FAlert_OK)
        FAlert.addAction(FAlert_Retry)
        self.present(FAlert, animated: true) { print("[Info] Failed Alert Presented.") }
        client_as_TCP.close()
        setTiltBack();
    }
    
    func setTiltBack() {
        self.ContiuneButton.fadeTransition(0.2)
        self.ContiuneButton.setTitle("Continue", for: .normal)
    }
    
    func pushToVC() {
        //Push if successed.
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "drawViewController") as! drawViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if isUpdatedFromQRCode {
            PushWork(iPViewController())
            isUpdatedFromQRCode = false
        }
    }
    

    
    
}

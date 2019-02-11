//
//  drawViewController.swift
//  Pencil
//
//  Created by Lakr Sakura on 2018/7/31.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

import Foundation
import UIKit


var PencilStatus = -1 // -1 unset 0 not touch down 1 first touch down 2 drawing 3 last touch down.
var lastTouchForce: CGFloat = 0.0

class drawViewController: UIViewController{
    
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var centerInspector: UIImageView!
    @IBOutlet weak var AdditionInspector: UIImageView!
    @IBOutlet weak var ForDetailInspector: UILabel!
    @IBOutlet weak var RogDetailInspector: UILabel!
    @IBOutlet weak var AltDetailInspector: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PencilStatus = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.ErrorLabel.fadeTransition(0.5)
            self.ErrorLabel.text = ""
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Make touch reachable.
        guard let touch = touches.first else { return }
        var touches = [UITouch]()
        
        if let coalescedTouches = event?.coalescedTouches(for: touch){
            touches = coalescedTouches
        }else{
            touches.append(touch)
        }
        //------------------------------------------------------Start Handle
        if touch.type == .stylus {
            //Handle Apple Pencil Events.
            
            if 0 == 1 { // for beauty
            }else if PencilStatus == 0 || PencilStatus == 3 || PencilStatus == 4{ // if not touch down
                PencilStatus = 1 //first touch down
            }else if PencilStatus == 1{ // if touched down first
                PencilStatus = 2 //make it drawing
            }else if PencilStatus == 2{ //Do Nothing
            }else{
                print("[Error] You shouldn't been here so far?! OwO")//Error handle. Force to 0.
            }

            self.AdditionInspector.isHidden = false
            self.centerInspector.isHidden = false
            
                                //Fix Force 0.0 Issue
                                if touch.force != 0.0 {
                                        lastTouchForce = touch.force
                                    }else{
                                        ErrorLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                                        ErrorLabel.text = "Occurred draw force 0. Assigned last value."
                                        print("[ERROR] (Fixed) Using last force value.", lastTouchForce)
                                }
            
            //Get Altitude and have it right.
            let AltitudeAngle = fixAnyAngle(input: touch.altitudeAngle)
            let RotationAngle = fixAnyAngle(input: touch.azimuthAngle(in: drawView()))
            //Get location as CGPoint for now.
            let LocationPoint: CGPoint = touch.location(in: drawView())
            //Update Status Bar And Inspectors And database.
            UpdateStauts(force: lastTouchForce, Rot: RotationAngle, Alt: AltitudeAngle)
            centerInspector.frame = CGRect(
                origin: FixCenterPoint(
                                      force: lastTouchForce, whereP: LocationPoint)
                , size: force_to_Siza(force: lastTouchForce))
            AdditionInspector.frame = AddInspectorCalc(
                Alt: AltitudeAngle, Rog: RotationAngle, Cen: LocationPoint)
            //Update to class and record --------------------------------------------
            
            pDetail_init(
                ipForce: lastTouchForce, ipRotation: RotationAngle,
                ipAlt: AltitudeAngle, ipStatus: PencilStatus,
                ipLocationX: LocationPoint.x, ipLocationY: LocationPoint.y
            )
            
            update_Pecile_Datebase()
            
        }else{
            //Handle Finger Touch Events.
            //Do Nothing While Pencil is drawing.
            if PencilStatus == 2{
                return
            }
            self.ErrorLabel.textColor = #colorLiteral(red: 0.7732421756, green: 0.7732421756, blue: 0.7732421756, alpha: 1)
            ErrorLabel.text = "Finger is for moving pointer."
            UpdateStauts(force: 0, Rot: -180, Alt: 0)
            //Set Special Values to -1
            PencilStatus = 4
            //Get location as CGPoint for now.
            let LocationPoint: CGPoint = touch.location(in: drawView())
            fDetail_init(FX: LocationPoint.x, FY: LocationPoint.y)
            update_touch_Datebase()
        }
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.centerInspector.isHidden = true
        self.AdditionInspector.isHidden = true
        lastTouchForce = 0.0
        if PencilStatus == 2 {
            _ = sendToLaptop(StartID: 3)
        }else if PencilStatus == 4 {
            //Do Nothing While Pencil is drawing.
            if PencilStatus == 2{
                return
            }
            _ = sendToLaptop(StartID: 7)
        }else{
            print("[Unexcept Result] TouchesEnded Event Recived an Error Pencil Status.")
            _ = sendToLaptop(StartID: 7)
        }
        if PencilStatus != 4 {
            PencilStatus = 3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.ErrorLabel.textColor = #colorLiteral(red: 0.7732421756, green: 0.7732421756, blue: 0.7732421756, alpha: 1)
            self.ErrorLabel.text = ""
        }
        if required_MSGNO_Reset == true {
            ResetMessageNumber()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Make touch reachable.
        guard let touch = touches.first else { return }
        var touches = [UITouch]()
        if let coalescedTouches = event?.coalescedTouches(for: touch){
            touches = coalescedTouches
        }else{
            touches.append(touch)
        }
        //------------------------------------------------------Start Handle
        if touch.type == .stylus { return } //Not a finger
        //Handle Finger Touch Events.
        //Do Nothing While Pencil is drawing.
        if PencilStatus == 2{
            return
        }
        self.ErrorLabel.textColor = #colorLiteral(red: 0.7732421756, green: 0.7732421756, blue: 0.7732421756, alpha: 1)
        ErrorLabel.text = "Finger is for moving pointer."
        UpdateStauts(force: 0, Rot: -180, Alt: 0)
        _ = sendToLaptop(StartID: 6)
    }
    
    func UpdateStauts(force: CGFloat, Rot: CGFloat, Alt: CGFloat) -> () {
        //PencilDetail ( Force:0, Azimuth:0, Altitude:0 ).
        //Force Range 0.0 <-> 4.16666666666667
        //Convert to diaplay value. But number force need to be 8192 level.
        let force_level_temp = force * (100.000 / 4.16666666666667) * 100
        let int_fo_level = Int(force_level_temp)
        let double_fo_level = Double(int_fo_level) / 100
        //Assign value to pre data base.
        let fo: Double = Double(double_fo_level)
        let ro: Double = Double(Int(Rot + 180))
        let al: Double = Double(Int(Alt))
        //Update UI Detail Inspector
        ForDetailInspector.text = (String(fo) + "%")
        RogDetailInspector.text = (String(ro) + "°")
        AltDetailInspector.text = (String(al) + "°")
    }
    
    func AddInspectorCalc(Alt: CGFloat, Rog: CGFloat, Cen: CGPoint) -> CGRect {
        let PP: CGFloat = 50
        let AltPP: CGFloat = 100 / Alt / 4
        var center: CGPoint = CGPoint(x: 0, y: 0)
        let Angel_To_Pi: CGFloat = Rog * Math_Pi / 180
        center.y = CGFloat(Cen.y + sin(Angel_To_Pi) * PP * AltPP - 25)
        center.x = CGFloat(Cen.x + cos(Angel_To_Pi) * PP * AltPP - 25)
        return CGRect(origin: center, size: CGSize(width: 50, height: 50))
    }
    
    //Make rad -> jiaodu..... lmao
    func fixAnyAngle(input: CGFloat) -> CGFloat{
        let output: CGFloat = 180 / Math_Pi * input
        return output
    }
    
    func force_to_Siza(force: CGFloat) -> CGSize {
        var size: CGFloat = 50
        size = size + force * 10
        return CGSize(width: size, height: size)
    }
    
    func FixCenterPoint(force :CGFloat, whereP: CGPoint) -> CGPoint {
        let size = force_to_Siza(force: force)
        let x: CGFloat = whereP.x - (size.width / 2)
        let y: CGFloat = whereP.y - (size.height / 2)
        return CGPoint(x: x, y: y)
    }
    
    
}


class drawView: UIView {
    
}

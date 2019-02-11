//
//  ViewController.swift
//  Pencil
//
//  Created by Lakr Sakura on 2018/7/31.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

import UIKit
import SwiftSocket

class initViewController: UIViewController{
    
    @IBOutlet weak var animateRound: UIImageView!
    @IBOutlet weak var staticRound: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var animateControlloer = 1
    var roundCenter = CGPoint(x: 0, y: 0)
    
    @IBAction func ShareButton(_ sender: Any) {
        let tweetText = "I am using toPencil to save my money for buying a digital draw board. (Apple Pencil and iPad Pro is needed.)"
        let tweetUrl = "https://itunes.apple.com/us/app/topencil/id1423091942"
        
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)"
        
        // encode a space to %20 for example
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        // cast to an url
        let url = URL(string: escapedShareString)
        
        // open in safari
        UIApplication.shared.open(url!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
  
        //Reset pencil detect 'cause FAQ repush
        PencilDetected = false
        //Get Center Value.
        roundCenter.x = animateRound.center.x - 11
        roundCenter.y = animateRound.center.y - 11
        //Animate touch round
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {self.makeRoundAnimate()})
    }

    
    func makeRoundAnimate() {
        UIView.animate(withDuration: 1) {
            if self.animateControlloer == 0 {
                self.animateControlloer = 1
                //It is small. making it bigger.
                self.roundCenter.x = self.animateRound.center.x - 44
                self.roundCenter.y = self.animateRound.center.y - 44
                self.animateRound.frame = CGRect(
                    origin: self.roundCenter, size: CGSize(width: 88, height: 88))
            }else{
                self.animateControlloer = 0
                //It is a big round. making it small
                self.roundCenter.x = self.animateRound.center.x - 11
                self.roundCenter.y = self.animateRound.center.y - 11
                self.animateRound.frame = CGRect(
                    origin: self.roundCenter, size: CGSize(width: 22, height: 22))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {self.makeRoundAnimate()})
    }
    
    
    //detect if is a apple pencil
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if PencilDetected == true { return }
        
        guard let touch = touches.first else { return }
        var touches = [UITouch]()
        
        if let coalescedTouches = event?.coalescedTouches(for: touch) {
                touches = coalescedTouches
            } else {
                touches.append(touch)
        }
        if touch.type == .stylus {
                infoLabel.fadeTransition(0.5)
                infoLabel.text = "Initializing Core Function..."
                PencilDetected = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "iPViewController") as! iPViewController
                self.present(nextViewController, animated:true, completion:nil)
            }
            }else{
                infoLabel.fadeTransition(0.5)
                infoLabel.text = "This is not an Apple Pencil?"
        }
    }
    
//End class
}


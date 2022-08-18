//
//  ViewController.swift
//  app2
//
//  Created by shino on 2022/08/02.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {
    @IBOutlet weak var Lright: UILabel!
    @IBOutlet weak var Lleft: UILabel!
    @IBOutlet weak var Ltop: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var bw_sw: UISwitch!
    
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    @IBOutlet weak var fb: UILabel!
    @IBOutlet weak var lr: UILabel!

    @IBOutlet var bg: UIView!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var lpf_val: UISegmentedControl!
    
    let motionManager = CMMotionManager()
    var timer: Timer!
    var timer_disp: Timer!
    
    var post_x:Double=0
    var post_y:Double=0
    var post_z:Double=0

    var offsetx:Double=0
    var offsety:Double=0
    var offsetz:Double=0
    
    var app_x: Double=0
    var app_y: Double=0
    var app_z: Double=0
    
    var br_x: Bool=true
    var br_y: Bool=true
    var br_z: Bool=true
    
    
    var K_now:Double  = 0.0295
    var K_post:Double = 0.9705
    
    
    // LPF setting
    @IBAction func lpf_change(_ sender: Any) {
        if(lpf_val.selectedSegmentIndex==0){
            K_now =  0.1389
            K_post = 0.8611
        }
        if(lpf_val.selectedSegmentIndex==1){
            K_now =  0.0295
            K_post = 0.9705
        }
        if(lpf_val.selectedSegmentIndex==2){
            K_now =  0.0030
            K_post = 0.9970
        }
    }
    
    
    @IBAction func bw(_ sender: Any) {
    
        if(bw_sw.isOn == true){
            bg_black()
        }else{
            bg_white()
        }

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bg_black()
      }

    // apper
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if motionManager.isAccelerometerAvailable {
           motionManager.accelerometerUpdateInterval = 0.01
           motionManager.startAccelerometerUpdates()
        }
        if motionManager.isDeviceMotionAvailable{
            // motionManager.deviceMotionUpdateInterval = 0.01
            // motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        }
        startTimer()

    }

    // disapper
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if motionManager.isDeviceMotionAvailable{
           motionManager.stopDeviceMotionUpdates()
           }
        timer.invalidate()
    }
    

    @IBAction func zeroset(_ sender: Any) {
//        Thread.sleep(forTimeInterval: 0.5)
        reset_axis()
    }
    
    func reset_axis(){

        offsetx=post_x
        offsety=post_y
        offsetz=post_z
        
    }
    
    func bg_black(){

        v1.backgroundColor = UIColor.black
        v2.backgroundColor = UIColor.black
        fb.backgroundColor = UIColor.black
        lr.backgroundColor = UIColor.black
        time.backgroundColor = UIColor.black
        Ltop.backgroundColor = UIColor.black
        Lright.backgroundColor = UIColor.black
        Lleft.backgroundColor = UIColor.black
        bg.backgroundColor = UIColor.black
        fb.textColor = UIColor.white
        lr.textColor = UIColor.white
        time.textColor = UIColor.white
        Ltop.textColor = UIColor.white
        Lright.textColor = UIColor.white
        Lleft.textColor = UIColor.white
        
    }
    func bg_white(){

        v1.backgroundColor = UIColor.white
        v2.backgroundColor = UIColor.white
        fb.backgroundColor = UIColor.white
        lr.backgroundColor = UIColor.white
        time.backgroundColor = UIColor.white
        Ltop.backgroundColor = UIColor.white
        Lright.backgroundColor = UIColor.white
        Lleft.backgroundColor = UIColor.white
        bg.backgroundColor = UIColor.white
        fb.textColor = UIColor.black
        lr.textColor = UIColor.black
        time.textColor = UIColor.black
        Ltop.textColor = UIColor.black
        Lright.textColor = UIColor.black
        Lleft.textColor = UIColor.black
        
    }

    func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(self.filttimer),
            userInfo: nil,
            repeats: true)
        
        timer_disp = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(self.disptimer),
            userInfo: nil,
            repeats: true)
    }
 
    
    @objc func filttimer() {
        
        
        var raw_x: Double=0
        var raw_y: Double=0
        var raw_z: Double=0


        
        if  self.motionManager.isAccelerometerAvailable {
            if let data = self.motionManager.accelerometerData {
               raw_x = data.acceleration.x * 9.8
               raw_y = data.acceleration.y * 9.8
               raw_z = data.acceleration.z * 9.8
            
               }
        }
        /*
        if  self.motionManager.isDeviceMotionAvailable {
            if let data = self.motionManager.deviceMotion {
                raw_x = data.userAcceleration.x * 9.8
                raw_y = data.userAcceleration.y * 9.8
                raw_z = data.userAcceleration.z * 9.8
            
               }
        }
         */
        
        app_x = K_now * raw_x + K_post * post_x
        app_y = K_now * raw_y + K_post * post_y
        app_z = K_now * raw_z + K_post * post_z
        
        

        post_x = app_x
        post_y = app_y
        post_z = app_z
        
    }
    
    @objc func disptimer() {
        let dt = Date()
        let dateFormatter = DateFormatter()
        let locale = Locale.current
        let localeid = locale.identifier
        var disp_x: Double=0
        var disp_y: Double=0
        var disp_z: Double=0

        // DateFormatter for local
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "Hms", options: 0, locale: Locale(identifier: localeid))
        time.text = dateFormatter.string(from: dt)
    
        disp_x = app_x - offsetx
        Lleft.text=String(format:"%03.2f",disp_x)
        if((br_x == true)&&(disp_x <= -2.00))
        {
            br_x = false
        }else if((br_x == false)&&(disp_x > -1.9)&&(disp_x < 1.9))
        {
            br_x = true
        }else if((br_x == true)&&(disp_x >= 2.00))
        {
            br_x = false
        }else{
            // br_x stay itself
        }
        
        if(br_x == true){
            if(bw_sw.isOn == false){
                Lleft.textColor=UIColor.black
            }else{
                Lleft.textColor=UIColor.white
            }
        }else{
            Lleft.textColor=UIColor.red
        }
        
        
        disp_y = app_y - offsety
        Lright.text=String(format:"%03.2f",disp_y)

        if((br_y == true)&&(disp_y <= -2.0))
        {
            br_y = false
        }else if((br_y == false)&&(disp_y > -1.9)&&(disp_y < 1.9))
        {
            br_y = true
        }else if((br_y == true)&&(disp_y >= 2.00))
        {
            br_y = false
        }else{
            // br_y stay itself
        }
        
        
        
        if(br_y == true){
            if(bw_sw.isOn == false){
                Lright.textColor=UIColor.black
            }else{
                Lright.textColor=UIColor.white
            }
        }else{
            Lright.textColor=UIColor.red
        }
 
        disp_z = app_z - offsetz
        Ltop.text=String(format:"%03.2f",disp_z)
        
        if((br_z == true)&&(disp_z <= -2.00))
        {
            br_z = false
        }else if((br_z == false)&&(disp_z > -1.9)&&(disp_z < 1.9))
        {
            br_z = true
        }else if((br_z == true)&&(disp_z >= 2.00))
        {
            br_z = false
        }else{
            // br_z stay itself
        }
        
        if(br_z == true){
            if(bw_sw.isOn == false){
                Ltop.textColor=UIColor.black
            }else{
                Ltop.textColor=UIColor.white
                }
        }else{
            Ltop.textColor=UIColor.red
        }
        
    }
 
 
    
}


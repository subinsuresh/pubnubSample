//
//  ViewController.swift
//  PubNubSample
//
//  Created by QBurst on 11/07/17.
//  Copyright © 2017 QBurst. All rights reserved.
//

import UIKit
import PubNub

fileprivate let publishKey = "pub-c-6855b23d-e5d1-49f5-b5ce-dd394a8f77d1"
fileprivate let subscribeKey = "sub-c-5dcca50c-653f-11e7-8fcc-0619f8945a4f"

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    var client : PubNub?
    
    // this queue below is only for scheduling publishes
    // it won't share resources with anything else and is concurrent
    // so that there will be no delay in scheduling publishes
    let publishQueue = DispatchQueue(label: "PublishQueue", qos: .userInitiated, attributes: [.concurrent])
    // this queue below is only for callbacks
    // it is concurrent so callbacks won't be delayed
    // and is separate from the publish queue so as not to delay either
    let callbackQueue = DispatchQueue(label: "PubNubCallbackQueue", qos: .userInitiated, attributes: [.concurrent])
    
    @IBAction func publish(_ sender: Any) {

      let publishStep0 = Date()
       DispatchQueue.main.async {
            let publishStep1 = Date()
            let publishText = self.textField.text ?? "default"
            self.publishQueue.async {
                let publishStep2 = Date()
                self.client?.publish(publishText, toChannel: "my_channel1",
                                     compressed: false, withCompletion: { (status) in
                                        let publishStep3 = Date()
                                        print("****** \(#function) publish steps ******")
                                        print("Step 0: \(publishStep0)")
                                        print("Step 1: \(publishStep1)")
                                        print("Step 2: \(publishStep2)")
                                        print("Step 3: \(publishStep3)")
                                        print("****************************************")
                                        if !status.isError {
                                        }
                                        else{
                                            
                                        }
                })
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        config.stripMobilePayload = false
        self.client = PubNub.clientWithConfiguration(config, callbackQueue: callbackQueue)
        self.client?.logger.enabled = true
        self.client?.logger.setLogLevel(PNLogLevel.PNVerboseLogLevel.rawValue)
        // optionally add the app delegate as a listener, or anything else
        // View Controllers should get the client from the App Delegate
        // and add themselves as listeners if they are interested in
        // stream events (subscribe, presence, status)
        self.client?.addListener(self)
        self.client?.subscribeToChannels(["my_channel1"], withPresence: false)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - PNObjectEventListener
extension ViewController: PNObjectEventListener {
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        
        print("Status \(status.category.rawValue)")
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        DispatchQueue.main.async {
//            print("$$$$$$$$$$$$$$$$ Message received $$$$$$$$$$$$$$$$")
//            print("message: \(message.debugDescription)")
            print("time: \(Date())")
    //        print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
            self.label.text = self.label.text?.appending(",\(message.data.message!) ")
        }
        
    }
    
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        // This most likely won't be used here, but in any relevant view controllers
    }
}




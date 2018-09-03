//
//  PreferencesWindowController.swift
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import Cocoa

@objc protocol PreferencesChangeProtocol {
    @objc optional func successTestCompleterConnection(_ completer: Completer)
}

@objc class PreferencesWindowController: NSWindowController {
    
    @IBOutlet weak var portLabel: NSTextField!
    @IBOutlet weak var errorLabel: NSTextField!
    
    @objc var delegate: PreferencesChangeProtocol?
    
    @IBAction func closeWindow(_ sender: AnyObject) {
        guard let w = self.window else { return }
        NSApp.mainWindow?.endSheet(w)
    }
    
    @IBAction func testConnection(_ sender: AnyObject) {
        let value = self.portLabel.stringValue
        
        if value.count <= 1 {
            NSSound.beep()
            return
        }
        
        print("value", value)
        
        let completer = Completer(port: value)
        completer.ping { (result) -> () in
            switch result {
            case .running(let r) where r == true:
                UserDefaults.standard.set(value, forKey: "TextMateSwiftCompletionPort")
                self.errorLabel.isHidden = false
                self.errorLabel.stringValue = "Connected!"
                if let delegate = self.delegate {
                    print("delegate", delegate)
                    delegate.successTestCompleterConnection?(completer)
                }
            default:
                self.errorLabel.isHidden = false
                self.errorLabel.stringValue = "Could Not Connect!"
            }
        }
    }
}

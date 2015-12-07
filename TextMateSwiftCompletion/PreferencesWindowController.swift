//
//  PreferencesWindowController.swift
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import Cocoa

@objc protocol PreferencesChangeProtocol {
    optional func successTestCompleterConnection(completer: Completer)
}

@objc class PreferencesWindowController: NSWindowController {
    
    @IBOutlet weak var portLabel: NSTextField!
    @IBOutlet weak var errorLabel: NSTextField!
    
    var delegate: PreferencesChangeProtocol?
    
    @IBAction func closeWindow(sender: AnyObject) {
        guard let w = self.window else { return }
        NSApp.mainWindow?.endSheet(w)
    }
    
    @IBAction func testConnection(sender: AnyObject) {
        let value = self.portLabel.stringValue
        
        if value.characters.count <= 1 {
            NSBeep()
            return
        }
        
        print("value", value)
        
        let completer = Completer(port: value)
        completer.ping { (result) -> () in
            switch result {
            case .Running(let r) where r == true:
                NSUserDefaults.standardUserDefaults().setObject(value, forKey: "TextMateSwiftCompletionPort")
                self.errorLabel.hidden = false
                self.errorLabel.stringValue = "Connected!"
                if let delegate = self.delegate {
                    print("delegate", delegate)
                    delegate.successTestCompleterConnection?(completer)
                }
            default:
                self.errorLabel.hidden = false
                self.errorLabel.stringValue = "Could Not Connect!"
            }
        }
    }
}
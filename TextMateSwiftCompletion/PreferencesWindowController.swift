//
//  PreferencesWindowController.swift
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import Cocoa

@objc class PreferencesWindowController: NSWindowController {
    
    @IBOutlet weak var portLabel: NSTextField!
    @IBOutlet weak var errorLabel: NSTextField!
    
    @IBAction func closeWindow(sender: AnyObject) {
        
    }
    @IBAction func testConnection(sender: AnyObject) {
    }
}
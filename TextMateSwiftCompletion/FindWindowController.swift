//
//  FindWindowController.swift
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import Cocoa

@objc class FindWindowTextField: NSTextField {
    override func keyDown(theEvent: NSEvent) {
        NSLog("key down", theEvent.keyCode)
        super.keyDown(theEvent)
    }
}

@objc class FindWindowController: NSWindowController {
    @IBOutlet var filesTableView: NSTableView!
    @IBOutlet var filterTextField: NSTextField!
    var completer: Completer? = nil 
    
    private var internalFilter: String = ""
    
    override func awakeFromNib() {
        self.filterTextField.delegate = self
        
        // get the project files
        
    }
    
    @IBAction func filterTextChanged(sender: AnyObject) {
        self.internalFilter = self.filterTextField.stringValue
        
        // re-filter the table
    }
    
    override func cancelOperation(sender: AnyObject?) {
        self.closeOperation()
    }
    
    private func closeOperation() {
        guard let mainWindow = NSApp.mainWindow,
            ourWindow = self.window
        else { return }
        mainWindow.endSheet(ourWindow)
    }
}

extension FindWindowController: NSTextFieldDelegate {
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        self.closeOperation()
        return true
    }
    
    func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
        if commandSelector == "moveUp:" {
            self.filterTextField.stringValue = "arrow up"
            return true
        }
        if commandSelector == "moveDown:" {
            self.filterTextField.stringValue = "arrow down"
            return true
        }
        return false
    }
}
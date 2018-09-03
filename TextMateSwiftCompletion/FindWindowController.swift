//
//  FindWindowController.swift
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import Cocoa

@objc class FindWindowTextField: NSTextField {
    override func keyDown(with theEvent: NSEvent) {
        NSLog("key down", theEvent.keyCode)
        super.keyDown(with: theEvent)
    }
}

@objc class FindWindowController: NSWindowController {
    @IBOutlet var filesTableView: NSTableView!
    @IBOutlet var filterTextField: NSTextField!
    var completer: Completer? = nil 
    
    fileprivate var internalFilter: String = ""
    
    override func awakeFromNib() {
        self.filterTextField.delegate = self
        
        // get the project files
        
    }
    
    @IBAction func filterTextChanged(_ sender: AnyObject) {
        self.internalFilter = self.filterTextField.stringValue
        
        // re-filter the table
    }
    
    override func cancelOperation(_ sender: Any?) {
        self.closeOperation()
    }
    
    fileprivate func closeOperation() {
        guard let mainWindow = NSApp.mainWindow,
            let ourWindow = self.window
        else { return }
        mainWindow.endSheet(ourWindow)
    }
}

extension FindWindowController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        self.closeOperation()
        return true
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.moveUp(_:)) {
            self.filterTextField.stringValue = "arrow up"
            return true
        }
        if commandSelector == #selector(NSResponder.moveDown(_:)) {
            self.filterTextField.stringValue = "arrow down"
            return true
        }
        return false
    }
}

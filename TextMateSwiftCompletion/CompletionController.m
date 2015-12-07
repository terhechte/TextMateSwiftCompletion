//
//  CompletionController.m
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import "CompletionController.h"
#import "DocumentController.h"
#import "TextMateSwiftCompletion-Swift.h"

@interface CompletionController() <PreferencesChangeProtocol> {
    IBOutlet FindWindowController* _findWindowController;
    IBOutlet PreferencesWindowController* _prefsWindowController;
    NSMenu* _windowMenu;
    NSMenuItem* _showPluginMenuItem;
    NSMenuItem *_findFileItem;
    NSMenuItem *_completionItem;
    id _currentDocumentController;
    
    // The Completer
    Completer *_completer;
}
- (id)initWithPlugInController:(id <TMPlugInController>)aController;
- (void)installMenuItem;
- (void)uninstallMenuItem;
@end

@implementation CompletionController

#pragma mark Initialization

- (id)initWithPlugInController:(id <TMPlugInController>)aController {
    NSApp = [NSApplication sharedApplication];
    if(self = [super init])
        [self installMenuItem];
    return self;
}

- (void)dealloc {
    [self uninstallMenuItem];
}

#pragma mark Menu Handling

- (void)installMenuItem {
    /// Create a submenu which contains the two actions we have
    NSMenu *submenu = [[NSMenu alloc] initWithTitle:@"Swift Xcode Completion"];
    //NSMenuItem *findItem = [[NSMenuItem alloc] initWithTitle:@"Open Project File" action:@selector(openXcodeFile:) keyEquivalent:@"o"];
    NSMenuItem *prefsItem = [[NSMenuItem alloc] initWithTitle:@"Swift Project Settings" action:@selector(openXcodeSettings:) keyEquivalent:@"x"];
    NSMenuItem *triggerItem = [[NSMenuItem alloc] initWithTitle:@"Get Completions" action:@selector(completions:) keyEquivalent:@">"];
    
    prefsItem.target = self;
    
    [submenu addItem:prefsItem];
    [submenu addItem:triggerItem];
    
    _showPluginMenuItem = [[NSMenuItem alloc] init];
    _showPluginMenuItem.title = @"Swift Completion";
    _showPluginMenuItem.submenu = submenu;
    
    if((_windowMenu = [[[NSApp mainMenu] itemWithTitle:@"Window"] submenu])) {
        unsigned index = 0;
        NSArray* items = [_windowMenu itemArray];
        for(int separators = 0; index != [items count] && separators != 2; index++)
            separators += [[items objectAtIndex:index] isSeparatorItem] ? 1 : 0;
        
        [_windowMenu insertItem:_showPluginMenuItem atIndex:index ? index-1 : 0];
    }
    
    _completionItem = triggerItem;
//    _findFileItem = findItem;
}

- (void)uninstallMenuItem {
    [_windowMenu removeItem:_showPluginMenuItem];
    _showPluginMenuItem = nil;
    _windowMenu = nil;
}

#pragma mark Plugin Actions

- (void) openXcodeFile:(id)sender {
    /**
     Not working yet, this should open a list of all the files in the current project
     */
    if (!_findWindowController) {
        _findWindowController = [[FindWindowController alloc] initWithWindowNibName:@"FileFinder"];
        [self performSelector:@selector(openXcodeFile:) withObject:sender afterDelay:0.01];
        return;
    }
    
    NSWindow *mainWindow = [NSApp mainWindow];
    [mainWindow beginSheet:_findWindowController.window
         completionHandler:nil];
}

- (void) openXcodeSettings:(id)sender {
    if(!_prefsWindowController) {
        _prefsWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
        [self performSelector:@selector(openXcodeSettings:) withObject:sender afterDelay:0.01];
        return;
    }
    _prefsWindowController.delegate = self;
    NSWindow *mainWindow = [NSApp mainWindow];
    [mainWindow beginSheet:_prefsWindowController.window
         completionHandler:nil];
}

#pragma mark Completion Actions

- (void) completions:(id)sender {
    // call into the completion engine to retrieve completions,
    // and start a textmate completion action
    DocumentController *controller = nil;
    for (NSWindow *window in [NSApp windows]) {
        //NSLog([NSString stringWithFormat:@"%@", window.delegate]);
        NSString *className = [NSString stringWithFormat:@"%@", window.delegate];
        if ([className containsString:@"DocumentController"] && window.isKeyWindow) {
            if (![[[(DocumentController*)window.delegate documentPath] lowercaseString] containsString:@".swift"])continue;
            controller = window.delegate;
            break;
        }
    }
    
    if (!controller) {
        NSBeep();
        return;
    }
    
    if (!_completer) {
        NSBeep();
        return;
    }
    
    _currentDocumentController = controller;
    
    // we have a controller, we can start completions.
    NSString * contents = [controller.textView string];
    NSRange offset = [controller.textView selectedRange];
    NSString *temporaryFile = [_completer temporaryFile:contents];
    [CompleterWrapper
     completionsWrapper:_completer
     offset:offset.location
     file:temporaryFile
     completion:^(NSArray<NSString *> * completions) {
         NSMenu *menu = [[NSMenu alloc] init];
         for (NSString *s in completions) {
             NSMenuItem *completionItem = [[NSMenuItem alloc] init];
             completionItem.title = s;
             completionItem.representedObject = s;
             completionItem.target = self;
             completionItem.action = @selector(doCompletion:);
             [menu addItem:completionItem];
         }
         [controller.textView showMenu:menu];
     }];
}

- (void) doCompletion:(NSMenuItem*)item {
    if (!_currentDocumentController) {
        NSBeep();
        return;
    }
    
    OakTextView *textView = [(DocumentController*)_currentDocumentController textView];
    [textView insertText:item.representedObject replacementRange: textView.selectedRange];
}

#pragma mark PreferencesChangeProtocol

- (void) successTestCompleterConnection:(Completer*)completer {
    _completer = completer;
    // Connect the find file & completion menu entries
    _findFileItem.target = self;
    _completionItem.target = self;
}

@end

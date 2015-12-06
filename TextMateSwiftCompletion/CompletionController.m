//
//  CompletionController.m
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import "CompletionController.h"
#import "DocumentController.h"

@interface CompletionController() {
    IBOutlet FindWindowController* _findWindowController;
    IBOutlet PreferencesWindowController* _prefsWindowController;
    NSMenu* _windowMenu;
    NSMenuItem* _showPluginMenuItem;
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
    NSMenuItem *findItem = [[NSMenuItem alloc] initWithTitle:@"Open Project File" action:@selector(openXcodeFile:) keyEquivalent:@"o"];
    NSMenuItem *prefsItem = [[NSMenuItem alloc] initWithTitle:@"Swift Project Settings" action:@selector(openXcodeSettings:) keyEquivalent:@"x"];
    NSMenuItem *triggerItem = [[NSMenuItem alloc] initWithTitle:@"Get Completions" action:@selector(completions:) keyEquivalent:@"y"];
    
    prefsItem.target = self;
    findItem.target = self;
    triggerItem.target = self;
    
    [submenu addItem:findItem];
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
}

- (void)uninstallMenuItem {
    [_windowMenu removeItem:_showPluginMenuItem];
    _showPluginMenuItem = nil;
    _windowMenu = nil;
}

#pragma mark Plugin Actions

- (void) openXcodeFile:(id)sender {
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
    NSWindow *mainWindow = [NSApp mainWindow];
    [mainWindow beginSheet:_prefsWindowController.window
         completionHandler:nil];
}

#pragma mark Completion Actions

- (void) completions:(id)sender {
    // call into the completion engine to retrieve completions,
    // and start a textmate completion action
    
    // Right now this doesn't work out because TextMate's documents are of c++ type
    // document_t, and 
    NSMutableArray *documents = @[].mutableCopy;
    for (NSWindow *window in [NSApp windows]) {
        //NSLog([NSString stringWithFormat:@"%@", window.delegate]);
        NSString *className = [NSString stringWithFormat:@"%@", window.delegate];
        if ([className containsString:@"DocumentController"]) {
            [documents addObject:window.delegate];
//            DocumentController *controller = (DocumentController*)window.delegate;
//            NSLog(@"%@", controller.)
            NSLog(@"%@", [(DocumentController*)window.delegate documentPath]);
            NSLog(@"%@", [(DocumentController*)window.delegate documentView]);
            NSLog(@"%@", currentDocumentPath((DocumentController*)window.delegate));
        }
    }
}

@end

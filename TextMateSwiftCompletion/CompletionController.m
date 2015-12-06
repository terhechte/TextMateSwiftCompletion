//
//  CompletionController.m
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import "CompletionController.h"

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
    prefsItem.target = self;
    findItem.target = self;
    [submenu addItem:findItem];
    [submenu addItem:prefsItem];
    
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
    
}

@end

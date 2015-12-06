//
//  CompletionController.h
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TMPlugInController
- (float)version;
@end

@interface CompletionController : NSObject
{
    NSWindowController* clockWindowController;
    NSMenu* windowMenu;
    NSMenuItem* showClockMenuItem;
}
- (id)initWithPlugInController:(id <TMPlugInController>)aController;
- (void)dealloc;

- (void)installMenuItem;
- (void)uninstallMenuItem;

- (void)showClock:(id)sender;
- (void)disposeClock;
@end

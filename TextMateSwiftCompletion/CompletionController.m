//
//  CompletionController.m
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import "CompletionController.h"
#import "TextMateSwiftCompletion-Swift.h"

@implementation CompletionController

- (id)initWithPlugInController:(id <TMPlugInController>)aController {
    NSApp = [NSApplication sharedApplication];
    if(self = [super init])
        [self installMenuItem];
    return self;
}

- (void)dealloc {
    [self uninstallMenuItem];
    [self disposeAttempt];
}

- (void)installMenuItem {
    NSLog([Completer test]);
    if((windowMenu = [[[NSApp mainMenu] itemWithTitle:@"Window"] submenu]))
    {
        unsigned index = 0;
        NSArray* items = [windowMenu itemArray];
        for(int separators = 0; index != [items count] && separators != 2; index++)
            separators += [[items objectAtIndex:index] isSeparatorItem] ? 1 : 0;
        
        showClockMenuItem = [[NSMenuItem alloc] initWithTitle:@"Attempt" action:@selector(showAttempt:) keyEquivalent:@""];
        [showClockMenuItem setTarget:self];
        [windowMenu insertItem:showClockMenuItem atIndex:index ? index-1 : 0];
    }
}

- (void)uninstallMenuItem {
    [windowMenu removeItem:showClockMenuItem];
    showClockMenuItem = nil;
    windowMenu = nil;
}

- (void)showAttempt:(id)sender {
    NSLog(@"attempt");
}

- (void)disposeAttempt {
    NSLog(@"dispose attempt");
}
@end

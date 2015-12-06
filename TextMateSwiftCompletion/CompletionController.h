//
//  CompletionController.h
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextMateSwiftCompletion-Swift.h"

@protocol TMPlugInController
- (float)version;
@end

@interface CompletionController : NSObject
@end

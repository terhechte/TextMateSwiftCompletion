//
//  DocumentController.h
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakDocumentView
@end

@interface DocumentController: NSObject
@property (nonatomic) OakDocumentView*            documentView;
@property (nonatomic) NSString*                   documentPath;
@end


#if defined __cplusplus
extern "C" {
#endif
NSString *currentDocumentPath(DocumentController* controller);
#if defined __cplusplus
};
#endif

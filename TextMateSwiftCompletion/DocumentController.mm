//
//  DocumentController.m
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import "DocumentController.h"
#import "document.h"

@interface DocumentController (Docs)
@property (nonatomic) std::vector<document::document_ptr> const& documents;
@property (nonatomic) document::document_ptr              const& selectedDocument;
@end

NSString *currentDocumentPath(DocumentController* controller) {
    std::string path = controller.selectedDocument->path();
    return [NSString stringWithCString:path.c_str() encoding:[NSString defaultCStringEncoding]];
}



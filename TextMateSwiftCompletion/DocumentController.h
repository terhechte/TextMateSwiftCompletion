//
//  DocumentController.h
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface OakTextView : NSView <NSTextInput>
- (NSString *)stringValue;
- (void)insertSnippetWithOptions:(NSDictionary*)someOptions;
- (void)setSelectionString:(NSString*)aSelectionString;
- (NSRange)selectedRange;
- (id)xmlRepresentationForSelection;
- (NSDictionary *)environmentVariables;

- (void)goToLineNumber:(id)fp8;
- (void)goToColumnNumber:(id)fp8;
- (void)selectToLine:(id)fp8 andColumn:(id)fp12;

// Actions
- (void)deleteSelection:(id)sender;

// TextMate 2 API
- (id)scopeContext;
- (NSString *)scopeAsString;
@property (nonatomic, assign) id          delegate;
@property (nonatomic, retain) NSCursor*   ibeamCursor;
@property (nonatomic, retain) NSFont*     font;
@property (nonatomic, assign) BOOL        antiAlias;
@property (nonatomic, assign) size_t      tabSize;
@property (nonatomic, assign) BOOL        showInvisibles;
@property (nonatomic, assign) BOOL        softWrap;
@property (nonatomic, assign) BOOL        softTabs;
@property (nonatomic, readonly) BOOL      continuousIndentCorrections;

@property (nonatomic, readonly) BOOL      hasMultiLineSelection;
@property (nonatomic, readonly) BOOL      hasSelection;
@property (nonatomic, retain) NSString*   selectionString;
@property (nonatomic, retain) NSString*   string;

- (NSPoint) positionForWindowUnderCaret;
- (void)showMenu:(NSMenu*)aMenu;
- (void)insertText:(id)aString replacementRange:(NSRange)aRange;

@end

@interface OakDocumentView
@end

@interface DocumentController: NSObject
@property (nonatomic) OakDocumentView*            documentView;
@property (nonatomic) OakTextView*            textView;
@property (nonatomic) NSString*                   documentPath;
@end


@interface OakChoiceMenu : NSResponder <NSTableViewDataSource>
{
    NSWindow* window;
    NSTableView* tableView;
    NSArray* choices;
    NSUInteger choiceIndex;
    NSUInteger keyAction;
    NSPoint topLeftPosition;
}
@property (nonatomic) NSArray* choices;
@property (nonatomic) NSUInteger choiceIndex;
@property (nonatomic, readonly) NSString* selectedChoice;
- (void)showAtTopLeftPoint:(NSPoint)aPoint forView:(NSView*)aView;
- (BOOL)isVisible;
- (NSUInteger)didHandleKeyEvent:(NSEvent*)anEvent;
@end

@interface OakChooser : NSResponder
@property (nonatomic) NSWindow* window;

@property (nonatomic) SEL action;
@property (nonatomic, weak) id target;

@property (nonatomic) NSString* filterString;
@property (nonatomic, readonly) NSArray* selectedItems;
@property (nonatomic) NSArray*       items;

- (void)showWindow:(id)sender;
- (void)showWindowRelativeToFrame:(NSRect)parentFrame;
- (void)close;
@end
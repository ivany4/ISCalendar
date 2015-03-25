//
//  ISPopupCalendarTextField.m
//  Pods
//
//  Created by Ivan on 25/03/15.
//
//

#import "ISPopupCalendarTextField.h"

@implementation ISPopupCalendarTextField

- (void)setSelectedRange:(NSRange)range
{
    UITextPosition *from = [self positionFromPosition:[self beginningOfDocument] offset:range.location];
    UITextPosition *to = [self positionFromPosition:from offset:range.length];
    [self setSelectedTextRange:[self textRangeFromPosition:from toPosition:to]];
}
@end
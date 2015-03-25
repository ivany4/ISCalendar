#import "ISPopupCalendar.h"
#import "ISCalendarViewController.h"
#import "ISPopupCalendarTextField.h"


@interface ISPopupCalendar () <UITextFieldDelegate, ISCalendarViewControllerDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) ISPopupCalendarTextField *textField;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *zeroDateString;
@end

@implementation ISPopupCalendar

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _placeholder = NSLocalizedString(@"ENTER DATE", @"Calendar title");
    _textColor = [UIColor blackColor];
    
    ISPopupCalendarTextField *textField = [[ISPopupCalendarTextField alloc] init];
    textField.delegate = self;
    textField.textColor = _textColor;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_placeholder attributes:@{NSForegroundColorAttributeName:_textColor}];
    textField.keyboardType = UIKeyboardTypePhonePad;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"calendar-blue-icon"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:textField];
    [self addSubview:button];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[textField]-10-[button]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(textField, button)]];
    
    self.textField = textField;
    self.button = button;
    
    [self invalidateIntrinsicContentSize];
    
    [self layoutIfNeeded];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.textField.intrinsicContentSize.width+10+self.button.intrinsicContentSize.width, MAX(self.textField.intrinsicContentSize.height, self.button.intrinsicContentSize.height));
}

- (NSDateFormatter *)dateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
    });
    return _dateFormatter;
}

- (NSString *)zeroDateString
{
    if ([self.delegate respondsToSelector:@selector(noDateStringForCalendar:)]) {
        return [self.delegate noDateStringForCalendar:self];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zeroDateString = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]];
    });
    return _zeroDateString;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    self.userInteractionEnabled = enabled;
    self.button.enabled = enabled;
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    [self setTextFieldText:[self.dateFormatter stringFromDate:selectedDate]];
}

- (BOOL)setDate:(NSDate *)date
{
    if ((!self.selectedDate && date) || (self.selectedDate && !date) || (![date isEqualToDate:self.selectedDate])) {
        self.selectedDate = date;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        return YES;
    }
    return NO;
}

- (void)setTextFieldText:(NSString *)text
{
    //Otherwise, placeholder holds textfield intrinsic width
    if (text.length > 0) {
        self.textField.attributedPlaceholder = nil;

    }
    else {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:self.textColor}];
    }
    
    self.textField.attributedText = text ? [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:self.textColor}] : nil;
    
    if ([self.delegate respondsToSelector:@selector(popupCalendar:didChangeText:)]) {
        [self.delegate popupCalendar:self didChangeText:text];
    }
    
    [self layoutIfNeeded];
}

- (void)setTextFieldText:(NSString *)text withRange:(NSRange)range
{
    [self setTextFieldText:text];
    
    [self.textField setSelectedRange:range];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    //To assign or remove placeholder
    [self setTextFieldText:self.textField.attributedText.string];

}

- (void)buttonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(popoverWillOpen:)]) {
        [self.delegate popoverWillOpen:self];
    }
    [self openPopover];
    if ([self.delegate respondsToSelector:@selector(popoverDidOpen:)]) {
        [self.delegate popoverDidOpen:self];
    }
}

- (void)openPopover
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    else {
        if (self.textField.isFirstResponder) {
            [self.textField resignFirstResponder];
            return;
        }
        
        NSDate *selectedDate = nil;
        if (self.textField.attributedText.length > 0 && ![self.textField.attributedText.string isEqualToString:self.zeroDateString]) {
            selectedDate = [self.dateFormatter dateFromString:self.textField.attributedText.string];
        }
        
        if (!selectedDate) {
            selectedDate = self.selectedDate;
        }
        
        ISCalendarViewController *ctrl = [[ISCalendarViewController alloc] initWithSelectedDate:selectedDate delegate:self];
        self.popover = [[UIPopoverController alloc] initWithContentViewController:ctrl];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:self.button.bounds inView:self.button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - ISCalendarViewControllerDelegate

- (void)selectedDateChanged:(NSDate *)date
{
    BOOL proceed = YES;
    if ([self.delegate respondsToSelector:@selector(popupCalendar:shouldChangeDate:)]) {
        proceed = [self.delegate popupCalendar:self shouldChangeDate:date];
    }
    
    if (proceed && [self setDate:date]) {
        [self setTextFieldText:[self.dateFormatter stringFromDate:date]];
    }
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.attributedText.string.length == 0) {
        [self setTextFieldText:self.zeroDateString];
        [(ISPopupCalendarTextField *)textField setSelectedRange:NSMakeRange(0, 0)];
    }
    
    if ([self.delegate respondsToSelector:@selector(popupCalendarDidBeginEditingText:)]) {
        [self.delegate popupCalendarDidBeginEditingText:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.attributedText.string isEqualToString:self.zeroDateString]) {
        self.selectedDate = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(popupCalendarDidEndEditingText:)]) {
        [self.delegate popupCalendarDidEndEditingText:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(popupCalendarShouldReturnText:)]) {
        result = [self.delegate popupCalendarShouldReturnText:self];
    }
    
    [textField resignFirstResponder];
    return result;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= 10) {
        return NO;
    }
    
    //Check that char is number
    NSString *replacement = string;
    
    NSInteger location = range.location;
    NSInteger cursor;
    
    if (replacement.length > 0) {
        
        if (replacement.length > 1) {
            replacement = [replacement substringToIndex:1];
            
        }
        NSCharacterSet *nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSRange r = [replacement rangeOfCharacterFromSet:nonNumbers];
        if (r.location != NSNotFound) {
            return NO;
        }
        
        if (location == 2 || location == 5) {
            location++;
        }
        cursor = location+1;
    }
    else {
        replacement = @"0";
        if (location == 2 || location == 5) {
            location--;
        }
        cursor = location;
    }
    
    if (cursor == 2 || cursor == 5) {
        cursor++;
    }
    NSRange cursorRange = NSMakeRange(cursor, 0);
    
    
    NSString *newValue = [textField.attributedText.string stringByReplacingCharactersInRange:NSMakeRange(location, 1) withString:replacement];
    
    BOOL proceed = YES;
    if ([self.delegate respondsToSelector:@selector(popupCalendar:shouldChangeText:cursorRange:)]) {
        proceed = [self.delegate popupCalendar:self shouldChangeText:newValue cursorRange:cursorRange];
    }
    
    if (proceed) {
        [self setTextFieldText:newValue];
        
        [(ISPopupCalendarTextField *)textField setSelectedRange:cursorRange];
    }
    
    return NO;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

#pragma mark - Text color

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.textField.textColor = textColor;
    if (self.textField.attributedPlaceholder.string.length > 0) {
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.attributedPlaceholder.string attributes:@{NSForegroundColorAttributeName:textColor}];
    }
}

@end

#import "ISPopupCalendarTextField.h"

@class ISPopupCalendar, ISPopupCalendarTextField;
@protocol ISPopupCalendarDelegate <NSObject>
@optional
- (void)popupCalendar:(ISPopupCalendar *)calendar didChangeText:(NSString *)text;
- (void)popoverWillOpen:(ISPopupCalendar *)calendar;
- (void)popoverDidOpen:(ISPopupCalendar *)calendar;
- (BOOL)popupCalendar:(ISPopupCalendar *)calendar shouldChangeText:(NSString *)text cursorRange:(NSRange)cursor;
- (BOOL)popupCalendar:(ISPopupCalendar *)calendar shouldChangeDate:(NSDate *)date;
- (void)popupCalendarDidEndEditingText:(ISPopupCalendar *)calendar;
- (void)popupCalendarDidBeginEditingText:(ISPopupCalendar *)calendar;
- (BOOL)popupCalendarShouldReturnText:(ISPopupCalendar *)calendar;
- (NSString *)noDateStringForCalendar:(ISPopupCalendar *)calendar;

@end

@interface ISPopupCalendar : UIControl
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, readonly) ISPopupCalendarTextField *textField;
@property (nonatomic, readonly) UIButton *button;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, weak) IBOutlet id<ISPopupCalendarDelegate> delegate;
- (void)setTextFieldText:(NSString *)text;
- (void)setTextFieldText:(NSString *)text withRange:(NSRange)range;
- (void)openPopover;
@end

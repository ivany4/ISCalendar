#import <UIKit/UIKit.h>
#import "ISPopupCalendar.h"
#import "ISCalendarViewController.h"

@class ISCalendar;
@protocol ISCalendarDelegate <NSObject>
@optional
- (void)calendarBoundsDidChange:(ISCalendar *)calendar;
- (void)calendarVisibleMonthDidChange:(ISCalendar *)calendar;
@end

@interface ISCalendar : UIControl
@property (nonatomic) NSUInteger minimumAvailableDay;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, readonly) NSDate *visibleMonth;
@property (nonatomic, weak) IBOutlet id<ISCalendarDelegate> delegate;
@property (nonatomic, readonly) NSDateComponents *selectedDateComponents;
+ (NSInteger)heightForDate:(NSDate *)date;
- (void)layoutForMonth:(NSDate *)monthDate;
@end

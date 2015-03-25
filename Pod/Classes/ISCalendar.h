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

//Appearance
@property (nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *weekdayFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *arrowColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *normalBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *normalTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *normalTextFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *highlightedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *highLightedTextFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *todayBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *todayTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *todayTextFont UI_APPEARANCE_SELECTOR;
@end
#import <UIKit/UIKit.h>

@protocol ISCalendarViewControllerDelegate <NSObject>
- (void)selectedDateChanged:(NSDate *)date;
@end

@interface ISCalendarViewController : UIViewController
@property (nonatomic, weak) id<ISCalendarViewControllerDelegate> delegate;
- (id)initWithSelectedDate:(NSDate *)date delegate:(id<ISCalendarViewControllerDelegate>)delegate;

@end

#import "ISCalendarViewController.h"
#import "ISCalendar.h"

@interface ISCalendarViewController () <ISCalendarDelegate>
@property (nonatomic, strong) ISCalendar *calendar;
@property (nonatomic, strong) NSDate *selectedDate;
@end

@implementation ISCalendarViewController

- (id)initWithSelectedDate:(NSDate *)date delegate:(id<ISCalendarViewControllerDelegate>)delegate
{
    if (self = [super init]) {
        self.selectedDate = date;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ISCalendar *calendar = [[ISCalendar alloc] init];
    self.calendar = calendar;
    calendar.delegate = self;
    [calendar layoutForMonth:self.selectedDate];
    calendar.selectedDate = self.selectedDate;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.translatesAutoresizingMaskIntoConstraints = NO;
    [calendar addTarget:self action:@selector(selectedDateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:calendar];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(calendar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(-1)-[calendar]-(-1)-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[calendar]|" options:0 metrics:nil views:views]];
 
    [self updatePreferredSize];
}

- (void)updatePreferredSize
{
    CGRect newFrame = CGRectZero;
    newFrame.size = self.calendar.intrinsicContentSize;
    newFrame.size.width -= 2;
    self.view.frame = newFrame;
    self.preferredContentSize = newFrame.size;
    [self.view layoutIfNeeded];
}

- (void)selectedDateChanged:(ISCalendar *)calendar
{
    self.selectedDate = calendar.selectedDate;
    [self.delegate selectedDateChanged:calendar.selectedDate];
}

#pragma mark - ISCalendarDelegate

- (void)calendarBoundsDidChange:(ISCalendar *)calendar
{
    [self updatePreferredSize];
}

@end

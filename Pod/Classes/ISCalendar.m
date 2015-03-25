#import "ISCalendar.h"


#define TAG_TO_DAY(x) (x-1000)
#define TAG_TO_VIEW(x) (TAG_TO_DAY(x)-1)
#define DAY_TO_TAG(x) (x+1000)

#define THIS_MONTH(x) (x > 0 && x <= (NSInteger)_daysCount)
#define NO_MONTH(x) (x == -1)

#define CELL_EDGE 40
#define WEEKDAY_MARGIN  3
#define WEEKDAY_HEIGHT  10
#define HEADER_HEIGHT   36

#define BUNDLE_ID @"ISCalendar"

#define CAL_WIDTH   CELL_EDGE*7+8
#define DAYS_TOP_MARGIN HEADER_HEIGHT+1+WEEKDAY_HEIGHT+WEEKDAY_MARGIN*2+1

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)

typedef NS_ENUM(NSUInteger, PNTCalendarDayType) {
    kCalendarDaySelected,
    kCalendarDayRegular,
    kCalendarDayToday
};

@interface ISCalendar () {
    NSUInteger _weekCount;
    NSUInteger _daysCount;
    CGFloat _requiredHeight;
}

@property (nonatomic, strong) NSArray *dateLabels;
@property (nonatomic, strong) NSMutableArray *cellTypes;
@property (nonatomic, strong) NSArray *weekdayLabels;
@property (nonatomic, strong) NSArray *verticalSeparatorViews;
@property (nonatomic, strong) NSArray *horizontalSeparatorViews;
@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UIButton *nextMonthButton;
@property (nonatomic, strong) UIButton *previousMonthButton;
@property (nonatomic, strong) CAShapeLayer *previousButtonShape;
@property (nonatomic, strong) CAShapeLayer *nextButtonShape;
@property (nonatomic, strong) UIView *topSeparator;
@property (nonatomic, strong) NSDateComponents *todayComponents;
@property (nonatomic, strong) NSDateComponents *visibleMonthComponents;

@end

@implementation ISCalendar
@dynamic selectedDate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.todayComponents = [[NSCalendar autoupdatingCurrentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    _selectedDateComponents = nil;
    
    //Default appearance
    _normalBackgroundColor = [UIColor whiteColor];
    _normalTextColor = _todayTextColor = [UIColor colorWithRed:56/255. green:68/255. blue:77/255. alpha:1];
    _normalTextFont = _highLightedTextFont = _todayTextFont = [UIFont boldSystemFontOfSize:17];
    _highlightedTextColor = [UIColor whiteColor];
    _highlightedBackgroundColor = _arrowColor = [UIColor colorWithRed:67/255. green:141/255. blue:196/255. alpha:1];
    _todayBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    _weekdayFont = [UIFont systemFontOfSize:9];
    _separatorColor = [UIColor colorWithWhite:235/255.0 alpha:1];
    
    self.backgroundColor = _normalBackgroundColor;
    
    [self setupSubviewsForDate:nil];
}

- (void)setupSubviewsForDate:(NSDate *)newDate
{
    if (newDate) {
        self.visibleMonthComponents = [[NSCalendar autoupdatingCurrentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:newDate];
    }
    else {
        self.visibleMonthComponents = [self.todayComponents copy];
    }
    self.visibleMonthComponents.calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDate *visibleMonthDate = self.visibleMonthComponents.date;
    
    if ([self.delegate respondsToSelector:@selector(calendarVisibleMonthDidChange:)]) {
        [self.delegate calendarVisibleMonthDidChange:self];
    }
    
    NSInteger weeksCnt = [ISCalendar numberOfWeeksForDate:visibleMonthDate];
    NSInteger daysCnt = [[NSCalendar autoupdatingCurrentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:visibleMonthDate].length;
    
    

    CGFloat trueHeight = [ISCalendar heightForWeekNumbers:weeksCnt];
    
    BOOL notifyAboutHeightChange = trueHeight != _requiredHeight;
    
    _requiredHeight = trueHeight;
    [self invalidateIntrinsicContentSize];
    
    _daysCount = daysCnt;
    _weekCount = weeksCnt;
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.calendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    //Month navigation
    if (!self.monthLabel) {
        self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEADER_HEIGHT)];
        self.monthLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        self.monthLabel.backgroundColor = [UIColor whiteColor];
        self.monthLabel.textAlignment = NSTextAlignmentCenter;
        self.monthLabel.font = [UIFont boldSystemFontOfSize:16];
        self.monthLabel.textColor = [UIColor colorWithRed:56/255. green:68/255. blue:77/255. alpha:1];
        [self addSubview:self.monthLabel];
    }
    
    if (!self.previousMonthButton) {
        self.previousMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.previousMonthButton.frame = CGRectMake(0, 0, HEADER_HEIGHT, HEADER_HEIGHT);
        self.previousMonthButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(HEADER_HEIGHT*5/8, HEADER_HEIGHT*9/32)];
        [bezierPath addLineToPoint: CGPointMake(HEADER_HEIGHT*13/32, HEADER_HEIGHT*0.5)];
        [bezierPath addLineToPoint: CGPointMake(HEADER_HEIGHT*5/8, HEADER_HEIGHT*23/32)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.previousMonthButton.bounds;
        shapeLayer.path = bezierPath.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = self.arrowColor.CGColor;
        shapeLayer.lineWidth = .75;
        self.previousButtonShape = shapeLayer;
        [self.previousMonthButton.layer addSublayer:shapeLayer];
        [self.previousMonthButton addTarget:self action:@selector(previousMonthButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.previousMonthButton];
    }
    
    if (!self.nextMonthButton) {
        self.nextMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nextMonthButton.frame = CGRectMake(self.frame.size.width-HEADER_HEIGHT, 0, HEADER_HEIGHT, HEADER_HEIGHT);
        self.nextMonthButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(HEADER_HEIGHT*13/32, HEADER_HEIGHT*9/32)];
        [bezierPath addLineToPoint: CGPointMake(HEADER_HEIGHT*5/8, HEADER_HEIGHT*0.5)];
        [bezierPath addLineToPoint: CGPointMake(HEADER_HEIGHT*13/32, HEADER_HEIGHT*23/32)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.previousMonthButton.bounds;
        shapeLayer.path = bezierPath.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = self.arrowColor.CGColor;
        shapeLayer.lineWidth = .75;
        self.nextButtonShape = shapeLayer;
        [self.nextMonthButton.layer addSublayer:shapeLayer];
        [self.nextMonthButton addTarget:self action:@selector(nextMonthButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.nextMonthButton];
    }
    
    if (!self.topSeparator) {
        self.topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.frame.size.width, 1)];
        self.topSeparator.backgroundColor = self.separatorColor;
        self.topSeparator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.topSeparator];
    }
    
    
    self.monthLabel.text = [NSString stringWithFormat:@"%@ %ld", [dateFormatter.monthSymbols[self.visibleMonthComponents.month-1] uppercaseString], (long)self.visibleMonthComponents.year];
    
    self.visibleMonthComponents.day = 1;
    NSInteger firstWeekday = [[NSCalendar autoupdatingCurrentCalendar] components:DATE_COMPONENTS fromDate:self.visibleMonthComponents.date].weekday;
    
    NSMutableArray *weekdaySymbols = dateFormatter.shortWeekdaySymbols.mutableCopy;
    NSUInteger localeFirstWeekday = [[NSCalendar autoupdatingCurrentCalendar] firstWeekday];
    if (localeFirstWeekday == 1) {
//        NSLog(@"First day of the week is Sunday. Moving SUN to the front");
        NSString *sunday = [weekdaySymbols lastObject];
        [weekdaySymbols removeLastObject];
        [weekdaySymbols insertObject:sunday atIndex:0];
    }
    else if (localeFirstWeekday == 2)  {
//        NSLog(@"First day of the week is Monday");
        firstWeekday = ((firstWeekday + 5) % 7) + 1; // Transforming so that monday = 1 and sunday = 7
    }
    else {
        NSLog(@"WARNING: First day of the week is neither Sunday nor Monday. Currently not supported. Calendar will have unexpected behavior.");
    }
    
    [weekdaySymbols addObject:weekdaySymbols[0]];
    [weekdaySymbols removeObjectAtIndex:0];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:weekdaySymbols.count];
    for (NSUInteger i = 0; i < weekdaySymbols.count; i++) {
        NSString *caption = [weekdaySymbols objectAtIndex:i];
        UILabel *label = [[UILabel alloc] init];
        label.text = caption.uppercaseString;
        label.backgroundColor = [UIColor whiteColor];
        label.userInteractionEnabled = NO;
        label.textColor = self.normalTextColor;
        label.font = self.weekdayFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake((CELL_EDGE+1)*i, HEADER_HEIGHT+WEEKDAY_MARGIN, CELL_EDGE, WEEKDAY_HEIGHT);
        label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [mutableArray addObject:label];
        [self addSubview:label];
    }
    //Put sunday as last weekday
    _weekdayLabels = mutableArray;
    
    
    mutableArray = [NSMutableArray arrayWithCapacity:_daysCount];
    _cellTypes = [NSMutableArray arrayWithCapacity:_daysCount];
    for (int i = 1; i <= _daysCount; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = DAY_TO_TAG(i);
        NSUInteger position = i+firstWeekday-2;
        NSUInteger col = position % 7;
        NSUInteger row = position / 7;
        button.frame = CGRectMake(1+(CELL_EDGE+1)*col, DAYS_TOP_MARGIN+(CELL_EDGE+1)*row, CELL_EDGE, CELL_EDGE);
        button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [button setTitle:[NSString stringWithFormat:@"%i", i] forState:UIControlStateNormal];
        
        PNTCalendarDayType type = [self isDaySelected:i] ? kCalendarDaySelected : kCalendarDayRegular;
        [_cellTypes addObject:@(type)];
        if (type == kCalendarDayRegular) {
            [self setCellTypeRegularOrToday:i-1];
        }
        [button addTarget:self action:@selector(dayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [mutableArray addObject:button];
        [self insertSubview:button atIndex:0];
    }
    _dateLabels = mutableArray;
    
    mutableArray = [NSMutableArray arrayWithCapacity:6];
    for (NSUInteger i = 0; i < 8; i++) {
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = self.separatorColor;
        if (i == 0 || i == 7) {
            //Edges should be of full height
            separator.frame = CGRectMake((CELL_EDGE+1)*i, 0, 1, trueHeight);
        }
        else {
            separator.frame = CGRectMake((CELL_EDGE+1)*i, HEADER_HEIGHT, 1, trueHeight-HEADER_HEIGHT);
        }
        separator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [mutableArray addObject:separator];
        [self addSubview:separator];
    }
    _verticalSeparatorViews = mutableArray;
    
    NSUInteger horizontalSeparatorCount = _weekCount;
    mutableArray = [NSMutableArray arrayWithCapacity:horizontalSeparatorCount];
    for (NSUInteger i = 0; i < horizontalSeparatorCount; i++) {
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = self.separatorColor;
        separator.frame = CGRectMake(0, DAYS_TOP_MARGIN-1+(CELL_EDGE+1)*i, CAL_WIDTH, 1);
        separator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [mutableArray addObject:separator];
        [self addSubview:separator];
    }
    _horizontalSeparatorViews = mutableArray;
    
    [self updateCalendarSubviews];
    
    if (notifyAboutHeightChange) {
        if ([self.delegate respondsToSelector:@selector(calendarBoundsDidChange:)]) {
            [self.delegate calendarBoundsDidChange:self];
        }
    }
}

- (void)setArrowColor:(UIColor *)arrowColor
{
    _arrowColor = arrowColor;
    self.previousButtonShape.strokeColor = self.nextButtonShape.strokeColor = arrowColor.CGColor;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [self updateCalendarSubviews];
}

- (void)setCellType:(PNTCalendarDayType)type forDayButton:(UIButton *)button
{
    UIImage *backgroundImage = nil;
    UIColor *backgroundColor = nil;
    UIFont *titleLabeLFont = nil;
    UIColor *titleColor = nil;
    
    
    switch (type) {
        case kCalendarDayToday:
            backgroundColor = self.todayBackgroundColor;
            titleLabeLFont = self.todayTextFont;
            titleColor = self.todayTextColor;
            break;
        case kCalendarDayRegular:
            backgroundColor = self.normalBackgroundColor;
            titleLabeLFont = self.normalTextFont;
            titleColor = self.normalTextColor;
            break;
        case kCalendarDaySelected:
            backgroundColor = self.highlightedBackgroundColor;
            titleLabeLFont = self.highLightedTextFont;
            titleColor = self.highlightedTextColor;
            break;
        default:
            break;
    }
    
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    button.backgroundColor = backgroundColor;
    button.titleLabel.backgroundColor = backgroundColor;
    
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = titleLabeLFont;
}

- (void)setCellTypeRegularOrToday:(NSUInteger)index
{
    if (self.visibleMonthComponents.year == self.todayComponents.year && self.visibleMonthComponents.month == self.todayComponents.month && index+1 == self.todayComponents.day) {
        _cellTypes[index] = @(kCalendarDayToday);
    }
    else {
        _cellTypes[index] = @(kCalendarDayRegular);
    }
}

#pragma mark - Action methods

- (void)dayButtonPressed:(UIButton *)sender
{
    NSUInteger day = TAG_TO_DAY(sender.tag);
    
    if (_selectedDateComponents == nil || ![self isDaySelected:day]) {
        if (_selectedDateComponents != nil) {
            [self setCellTypeRegularOrToday:_selectedDateComponents.day-1];
        }
        _selectedDateComponents = [self.visibleMonthComponents copy];
        _selectedDateComponents.calendar = [NSCalendar autoupdatingCurrentCalendar];
        _selectedDateComponents.day = day;
        _cellTypes[day-1] = @(kCalendarDaySelected);
        
        [self updateCalendarSubviews];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)cleanUp
{
    NSMutableArray *subviews = [self.subviews mutableCopy];
    
    //Don't instantiate again
    [subviews removeObject:self.nextMonthButton];
    [subviews removeObject:self.previousMonthButton];
    [subviews removeObject:self.monthLabel];
    [subviews removeObject:self.topSeparator];
    
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)previousMonthButtonPressed:(UIButton *)sender
{
    self.visibleMonthComponents.month--;
    if (self.visibleMonthComponents.month < 1) {
        self.visibleMonthComponents.month += 12;
        self.visibleMonthComponents.year--;
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarVisibleMonthDidChange:)]) {
        [self.delegate calendarVisibleMonthDidChange:self];
    }
    
    [self cleanUp];
    
    [self setupSubviewsForDate:self.visibleMonthComponents.date];
    
}

- (void)nextMonthButtonPressed:(UIButton *)sender
{
    self.visibleMonthComponents.month++;
    if (self.visibleMonthComponents.month > 12) {
        self.visibleMonthComponents.month -= 12;
        self.visibleMonthComponents.year++;
    }
    if ([self.delegate respondsToSelector:@selector(calendarVisibleMonthDidChange:)]) {
        [self.delegate calendarVisibleMonthDidChange:self];
    }
    
    [self cleanUp];
    
    [self setupSubviewsForDate:self.visibleMonthComponents.date];
    
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    if (selectedDate) {
        
        if (_selectedDateComponents) {
            if ([selectedDate isEqualToDate:_selectedDateComponents.date]) return;
            
            if ([self isDaySelected:_selectedDateComponents.day]) {
                [self setCellTypeRegularOrToday:_selectedDateComponents.day-1];
            }
        }
        
        NSDateComponents *newDateComponents = [[NSCalendar autoupdatingCurrentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:selectedDate];
        newDateComponents.calendar = [NSCalendar autoupdatingCurrentCalendar];
        
        if (newDateComponents.month == self.visibleMonthComponents.month && newDateComponents.year == self.visibleMonthComponents.year) {
            _cellTypes[newDateComponents.day-1] = @(kCalendarDaySelected);
        }
        _selectedDateComponents = [newDateComponents copy];
        _selectedDateComponents.calendar = [NSCalendar autoupdatingCurrentCalendar];
        
        [self updateCalendarSubviews];
    }
    else if (_selectedDateComponents) {
        if ([self isDaySelected:_selectedDateComponents.day]) {
            [self setCellTypeRegularOrToday:_selectedDateComponents.day-1];
            [self updateCalendarSubviews];
        }
        _selectedDateComponents = nil;
    }
}

- (NSDate *)selectedDate
{
    return _selectedDateComponents.date;
}

- (NSDate *)visibleMonth
{
    return self.visibleMonthComponents.date;
}

- (void)layoutForMonth:(NSDate *)monthDate
{
    [self cleanUp];
    [self setupSubviewsForDate:monthDate];
}

- (void)updateCalendarSubviews
{
    for (NSInteger day = 1; day <= _daysCount; day++) {
        NSUInteger idx = day-1;
        PNTCalendarDayType type = (PNTCalendarDayType)[_cellTypes[idx] unsignedIntegerValue];
        UIButton *button = (UIButton *)_dateLabels[idx];
        [self setCellType:type forDayButton:button];
    }
}

- (BOOL)isDaySelected:(NSUInteger)day
{
    return _selectedDateComponents != nil && _selectedDateComponents.month == self.visibleMonthComponents.month && _selectedDateComponents.year == self.visibleMonthComponents.year && day == _selectedDateComponents.day;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(CAL_WIDTH, _requiredHeight);
}

+ (NSUInteger)numberOfWeeksForDate:(NSDate *)date
{
    NSRange weekRange = [[NSCalendar autoupdatingCurrentCalendar] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return weekRange.length;
}


+ (NSInteger)heightForWeekNumbers:(NSUInteger)weeksCount
{
    CGFloat trueHeight = DAYS_TOP_MARGIN+weeksCount*(CELL_EDGE+1)-1;
    return trueHeight;
}

+ (NSInteger)heightForDate:(NSDate *)date
{
    return [self heightForWeekNumbers:[self numberOfWeeksForDate:date]];
}

@end

//
//  ISViewController.m
//  ISCalendar
//
//  Created by Ivan Sinkarenko on 03/25/2015.
//  Copyright (c) 2014 Ivan Sinkarenko. All rights reserved.
//

#import "ISViewController.h"
#import "ISCalendar.h"

@interface ISViewController () <ISPopupCalendarDelegate, ISCalendarDelegate>
@property (nonatomic, strong) UILabel *popupDate;
@property (nonatomic, strong) UILabel *calDate;
@property (nonatomic, strong) ISCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation ISViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDate *date = [NSDate date];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterFullStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    ISCalendar *calendar = [[ISCalendar alloc] init];
    calendar.delegate = self;
    [calendar layoutForMonth:date];
    calendar.selectedDate = date;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.translatesAutoresizingMaskIntoConstraints = NO;
    [calendar addTarget:self action:@selector(selectedDateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:calendar];
    
    UILabel *calDate = [[UILabel alloc] init];
    self.calDate = calDate;
    calDate.backgroundColor = [UIColor whiteColor];
    calDate.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:calDate];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(calendar, calDate);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        ISPopupCalendar *popup = [[ISPopupCalendar alloc] init];
        popup.translatesAutoresizingMaskIntoConstraints = NO;
        popup.delegate = self;
        [popup addTarget:self action:@selector(popupDateChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:popup];
        
        UILabel *popupDate = [[UILabel alloc] init];
        self.popupDate = popupDate;
        popupDate.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:popupDate];
        
        views = NSDictionaryOfVariableBindings(popup, calendar, popupDate, calDate);
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[popup]-20-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[popupDate]-20-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[popup]-10-[popupDate]-40-[calendar]-[calDate]" options:0 metrics:nil views:views]];
    }
    else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[calendar]-[calDate]" options:0 metrics:nil views:views]];
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:calendar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[calDate]-20-|" options:0 metrics:nil views:views]];
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popupDateChanged:(ISPopupCalendar *)sender
{
    self.popupDate.text = [self.dateFormatter stringFromDate:sender.selectedDate];
}

- (void)selectedDateChanged:(ISCalendar *)sender
{
    self.calDate.text = [NSString stringWithFormat:@"Selected: %@", [self.dateFormatter stringFromDate:sender.selectedDate]];
}

@end

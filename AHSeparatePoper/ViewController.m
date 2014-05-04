//
//  ViewController.m
//  AHSeparatePoper
//
//  Created by jun on 4/30/14.
//  Copyright (c) 2014 Junkor. All rights reserved.
//

#import "ViewController.h"
#import "AHSeparatePoper.h"

#import "UIView+ViewFrameGeometry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"ContentView" owner:self options:nil].lastObject;
    
    // call by instance
//    AHSeparatePoper *poper = [[AHSeparatePoper alloc] initWithView:self.view];
//    [poper separateTo:self.view withContent:contentView by:sender];
    
    // call by class method
    [AHSeparatePoper separatePoperTo:self.view withContent:contentView by:sender];
}

@end

//
//  MainView.m
//  Matar
//
//  Created by Dorian Peake on 01/08/2014.
//  Copyright (c) 2014 Vereia. All rights reserved.
//

#import "MainView.h"
#import <QuartzCore/QuartzCore.h>

@interface MainView ()

- (void)setup;
- (NSImageView*)imageViewWithName:(NSString*)imageName;
@end

@implementation MainView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setWantsLayer:YES];
        [self setup];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor colorWithCalibratedRed:((float)0x0d/(float)0xff) green:((float)0x5a/(float)0xff) blue:((float)0xf7/(float)0xff) alpha:1.0f] setFill];
    // Drawing code here.
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

- (void)setup
{
    // set up stack view properties
    self.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.alignment = NSLayoutAttributeCenterX;
    self.spacing = 0;
    [self setHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self setHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
    
    // I'll be doing all the constraints manually, thanks
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // set up the main search and download view section
    NSView *topView = [[NSView alloc] initWithFrame:self.frame];
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertView:topView atIndex:0 inGravity:NSStackViewGravityTop];
    self.topView = topView;
    
    NSTextField *downloadField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    downloadField.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *downloadFieldWidth = [NSLayoutConstraint constraintWithItem:downloadField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:400];
    //NSLayoutConstraint *downloadFieldHeight = [NSLayoutConstraint constraintWithItem:downloadField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:20];
    
    [downloadField addConstraint:downloadFieldWidth];
    self.downloadField = downloadField;
    
    // begin startup animation ////////////////////////////////////////////////////////////////////////
    
    // load image and set up constraints
    NSImageView *logoView = [self imageViewWithName:@"logo_170x170.png"];
    self.logoView = logoView;
    NSLayoutConstraint *alignLogoX = [NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.topView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *alignLogoY = [NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *alignDownloadFieldY = [NSLayoutConstraint constraintWithItem:self.downloadField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topView attribute:NSLayoutAttributeCenterY multiplier:1 constant:60];
    NSLayoutConstraint *alignDownloadFieldX = [NSLayoutConstraint constraintWithItem:self.downloadField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.topView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        // fade in the logo
        context.duration = 1.5f;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        self.topView.animations = [NSDictionary dictionaryWithObjectsAndKeys:context,@"subviews", nil];
        [self.topView.animator addSubview:logoView];
    
        [self.topView addConstraint:alignLogoX];
        [self.topView addConstraint:alignLogoY];

    } completionHandler:^{
        
        // move the logo up a little to make room for the search bar
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [self.topView removeConstraint:alignLogoY];
            
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            context.duration = 1.0f;
            
            // nudge the frame to trigger a movement animation
            self.logoView.animator.frame = NSZeroRect;
            alignLogoY.constant = -self.logoView.frame.size.height/2 + 30;
            
            // add a constraint to move the image in to the correct location (sooo hacky, whats a better way to do it?!)
            [self.topView addConstraint:alignLogoY];

        } completionHandler:^{
            return;
        }];
    
        // fade in the search bar
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            context.duration = 1.0f;
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

            [self.topView.animator addSubview:self.downloadField];
            [self.topView addConstraint:alignDownloadFieldX];
            [self.topView addConstraint:alignDownloadFieldY];
            
        } completionHandler:^{
            NSLog(@"Done!");
        }];
    }];
    
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

- (NSImageView*)imageViewWithName:(NSString*)imageName
{
    NSImage *image = [NSImage imageNamed:imageName];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView setImage:image];
    
    [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:image.size.width]];
    
    [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:image.size.height]];
    
    return imageView;
}

@end

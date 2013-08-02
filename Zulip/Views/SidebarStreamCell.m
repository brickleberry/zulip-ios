//
//  SidebarStreamCell.m
//  Zulip
//
//  Created by Leonardo Franchi on 7/30/13.
//
//

#import "SidebarStreamCell.h"
#import "ZulipAppDelegate.h"
#import "ZulipAPIController.h"
#import "UIColor+HexColor.h"

@interface SidebarStreamCell ()
@end

@implementation SidebarStreamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.stream = nil;
    }
    return self;
}

- (void)setShortcut:(SIDEBAR_SHORTCUTS)shortcut
{
    _shortcut = shortcut;
    NarrowOperators *op = [[NarrowOperators alloc] init];

    switch (shortcut) {
        case HOME:
        {
            self.name.text = @"Home";
            // Magic to go  back to the main view
            [op setInHomeView];
            UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home" ofType:@"png"]];
            self.gravatar.image = image;
            break;

        }
        case PRIVATE_MESSAGES:
        {
            self.name.text = @"Private Messages";
            [op setPrivateMessages];

            UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"user" ofType:@"png"]];
            self.gravatar.image = image;
            break;
        }
        default:
            break;
    }
    _narrow = op;
}

- (void)setStream:(ZSubscription *)subscription
{
    _shortcut = STREAM;
    _stream = subscription;
    self.name.text = subscription.name;

    NarrowOperators *op = [[NarrowOperators alloc] init];
    [op addStreamNarrow:subscription.name];
    _narrow = op;

    CGFloat size = CGRectGetHeight(self.gravatar.bounds);
    self.gravatar.image = [self streamColorSwatchWithSize:size andColor:subscription.color];

    [self setBackgroundIfCurrent];
}

- (void)setBackgroundIfCurrent
{
    ZulipAppDelegate *delegate = (ZulipAppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([[delegate currentNarrow] isEqual:self.narrow]) {
        // This is the current narrow, highlight it
        self.backgroundColor = [UIColor colorWithHexString:@"#CCD6CC" defaultColor:[UIColor grayColor]];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Drawing Methods

- (UIImage *)streamColorSwatchWithSize:(int)height andColor:(NSString *)colorRGB
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(height, height), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);

    CGRect bounds = CGRectMake(0, 0, height, height);
    CGContextAddEllipseInRect(context, bounds);
    CGContextClip(context);

    UIColor *color = [UIColor colorWithHexString:colorRGB defaultColor:[UIColor grayColor]];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, bounds);

    UIGraphicsPopContext();
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

    return result;
}

@end
#import "CustomStatusBar.h"
#import <QuartzCore/QuartzCore.h>
@implementation CustomStatusBar
@synthesize statusLabel, shown;
-(id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		// Place the window on the correct level & position
		self.windowLevel = UIWindowLevelStatusBar + 1.0f;
    CGRect tempFrame = [UIApplication sharedApplication].statusBarFrame;
    statusbarHeight = tempFrame.size.height;
    self.frame = CGRectMake(tempFrame.origin.x, -statusbarHeight, tempFrame.size.width, statusbarHeight);
    backgroundView = [[UIView alloc] initWithFrame:tempFrame];
    [backgroundView setBackgroundColor:[UIColor blackColor]];
		
		statusLabel = [[UILabel alloc] initWithFrame:(CGRect){.origin.x =  0.0f, .origin.y = 0.0f, .size.width = 320.0f, .size.height = self.frame.size.height}];
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textColor = [UIColor whiteColor];
    [statusLabel setTextAlignment:UITextAlignmentCenter];
		statusLabel.font = [UIFont boldSystemFontOfSize:11.0f];
		[backgroundView addSubview:statusLabel];

    loadingIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_indicator.png"]];
    [loadingIndicator setFrame:CGRectMake(0, 5, 16, 10)];
    [loadingIndicator setHidden:YES];
    [backgroundView addSubview:loadingIndicator];

    self.hidden = YES;
    [self addSubview:backgroundView];
    //This is needed to detect if the application changes to a phone.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resizeViews:)
                                                 name:@"UIApplicationDidChangeStatusBarFrameNotification"
                                               object:nil];
	}
	return self;
}
- (void) resizeViews:(id)sender {
  CGRect tempFrame = [UIApplication sharedApplication].statusBarFrame;
  statusbarHeight = tempFrame.size.height;
  self.frame = CGRectMake(tempFrame.origin.x, -statusbarHeight, tempFrame.size.width, statusbarHeight);
  [backgroundView setFrame:tempFrame];
  [statusLabel setFrame:tempFrame];
}
- (void) animate {
  [loadingIndicator setFrame:CGRectMake(0, 5, 16, 10)];
  [loadingIndicator setHidden:NO];
  stopAnimating = NO;
  if (!indicatorShown) {
    [self animateIndicatorRight];
  }
  indicatorShown = YES;

}
- (void) stopAnimating {
  stopAnimating = YES;
  indicatorShown = NO;
  //[self.layer removeAllAnimations];
}
- (void) animateIndicatorRight {
  if(stopAnimating) {
    return;
  }
  [UIView animateWithDuration:0.3f
                        delay:0.0
                      options: UIViewAnimationOptionTransitionFlipFromLeft
                   animations:^{
                      loadingIndicator.transform = CGAffineTransformMake(loadingIndicator.transform.a * -1, 0, 0, 1, loadingIndicator.transform.tx, 0);
                   }
                   completion:^(BOOL finished){
                     [UIView animateWithDuration:1
                                           delay:0.0
                                         options: UIViewAnimationCurveEaseOut
                                      animations:^{
                                        //loadingIndicator.center = CGPointMake(100.0, 100.0);
                                        loadingIndicator.frame = CGRectMake(30, 5, 16, 10);
                                      }
                                      completion:^(BOOL finished){
                                        [self animateIndicatorLeft];
                                        rightAnimationAdded = YES;
                                      }];
                   }];

}
- (void) animateIndicatorLeft {
  if(stopAnimating) {
    return;
  }

  [UIView animateWithDuration:0.3f
                        delay:0.0
                      options: UIViewAnimationCurveEaseOut
                   animations:^{
                     //loadingIndicator.center = CGPointMake(100.0, 100.0);
                     loadingIndicator.transform = CGAffineTransformMakeRotation(0);
                   }
   completion:^(BOOL finished) {
     [UIView animateWithDuration:1
                           delay:0.0
                         options: UIViewAnimationCurveEaseOut
                      animations:^{
                        //loadingIndicator.center = CGPointMake(100.0, 100.0);
                        loadingIndicator.frame = CGRectMake(0, 5, 16, 10);
                      }
                      completion:^(BOOL finished){
                        [self animateIndicatorRight];
                        leftAnimationAdded = YES;
                      }];
   }
   ];

}
- (void)dealloc
{
	[statusLabel release];
	[super dealloc];
}
- (void)showWithStatusMessage:(NSString*)msg
{
  [self showWithStatusMessage:msg hide:NO];
}
- (void)showWithStatusMessage:(NSString*)msg hide:(BOOL)shouldHide {
  [self showWithStatusMessage:msg hide:shouldHide showLoadingIndicator:NO];
}
- (void)showWithStatusMessage:(NSString*)msg showLoadingIndicator:(BOOL)showLoadingIndicator {
  [self showWithStatusMessage:msg hide:NO showLoadingIndicator:showLoadingIndicator];
}
- (void)showWithStatusMessage:(NSString*)msg hide:(BOOL)shouldHide showLoadingIndicator:(BOOL)showLoadingIndicator {
  [loadingIndicator setHidden:YES];
  if(showLoadingIndicator) {
    [self animate];
  }
  if(self.shown) {
    statusLabel.text = msg;
    if(shouldHide) {
      [self hide:2.0f];
    }
    return;
  }
	if (!msg)
		return;
  self.hidden = NO;
	statusLabel.text = msg;
  CGRect tempFrame = [UIApplication sharedApplication].statusBarFrame;
  self.frame = CGRectMake(tempFrame.origin.x, -statusbarHeight, tempFrame.size.width, statusbarHeight);
  [UIView animateWithDuration:0.5f
                        delay:0.0f
                      options: UIViewAnimationCurveLinear
                   animations:^{
                     self.shown = YES;
                     self.frame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.width, statusbarHeight);
                   }
                   completion:^(BOOL finished) {
                     if(shouldHide) {
                       [self hide];
                     }
                   }];
}

- (void)hide:(CGFloat)delay withCompletition:(void (^)(BOOL finished))completition
{
  if(self.shown) {
    self.shown = NO;
    CGRect tempFrame = [UIApplication sharedApplication].statusBarFrame;
    [UIView animateWithDuration:0.5f
                          delay:delay
                        options: UIViewAnimationCurveLinear
                     animations:^{
                       self.frame = CGRectMake(tempFrame.origin.x, -statusbarHeight, tempFrame.size.width, statusbarHeight);
                       self.shown = NO;
                     }
                     completion:completition];
  }
}

- (void)hide {
  [self hide:2.0f withCompletition:^(BOOL finished) {
    if (finished) {
      self.shown = NO;
      self.hidden = YES;
    }
  }];
}
- (void)hide:(CGFloat)delay {
  [self hide:delay withCompletition:^(BOOL finished) {
    if (finished) {
      self.shown = NO;
      self.hidden = YES;
    }
  }];
}
@end;
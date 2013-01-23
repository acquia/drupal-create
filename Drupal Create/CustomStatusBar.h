@interface CustomStatusBar : UIWindow
{
@private
	/// Text information
	UILabel* statusLabel;
	/// Black View
  UIView *backgroundView;
  UIImageView *loadingIndicator;
  BOOL shown;
  int statusbarHeight;
  BOOL indicatorShown;
  BOOL stopAnimating;
  BOOL leftAnimationAdded;
  BOOL rightAnimationAdded;
}
@property (nonatomic, retain) UILabel* statusLabel;
@property (nonatomic, assign) BOOL shown;
-(void)showWithStatusMessage:(NSString*)msg;
-(void)showWithStatusMessage:(NSString*)msg showLoadingIndicator:(BOOL)showLoadingIndicator;
-(void)showWithStatusMessage:(NSString*)msg hide:(BOOL)shouldHide;
-(void)showWithStatusMessage:(NSString*)msg hide:(BOOL)shouldHide showLoadingIndicator:(BOOL)showLoadingIndicator;
-(void)hide;
-(void)hide:(CGFloat)delay;
-(void)hide:(CGFloat)delay withCompletition:(void (^)(BOOL finished))completition;

@end
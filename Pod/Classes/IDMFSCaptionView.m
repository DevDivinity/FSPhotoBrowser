//
//  FSCaptionView.m
//  PhotoBrowser
//
//  Created by DevDivinity on 8/20/15.
//
//

#import "IDMFSCaptionView.h"
#import "FSPhotoBrowser_TTTAttributedLabel.h"

static const CGFloat CAPTION_PADDING = 16;
static const CGFloat INTER_CAPTION_PADDING = 1;

static const NSString* ELLIPSES = @"... ";
static const NSString* TRUNCATING_TOKEN = @"More";
static const CGFloat FADE_ANIMATION_DURATION = 0.3;
static const NSUInteger NO_LINES_FOR_UNEXPANDED_TITLE = 1;
static const NSUInteger NO_LINES_FOR_UNEXPANDED_CAPTION = 4;

@interface IDMFSCaptionView()<UITextViewDelegate> {
    FSPhotoBrowser_TTTAttributedLabel *_captionLabel;
    FSPhotoBrowser_TTTAttributedLabel *_titleLabel;
    BOOL _isCaptionExpanded;
    UIView* _fadingView;
    UIScrollView* _captionLabelScrollView;
    UIGestureRecognizer* _fadingViewTapGestureRecognizer;
}
@end


@implementation IDMFSCaptionView

- (void)setupCaption {

    _captionLabelScrollView = [[UIScrollView alloc] init];
    _captionLabelScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _captionLabelScrollView.showsHorizontalScrollIndicator = NO;
    _captionLabelScrollView.showsVerticalScrollIndicator = NO;
    _captionLabelScrollView.backgroundColor = [UIColor blackColor];
    [self addSubview:_captionLabelScrollView];
    
    _captionLabel = [[FSPhotoBrowser_TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                         self.bounds.size.width,
                                                                         self.bounds.size.height)];
    _captionLabel.numberOfLines = [self getNumberofCaptionLines];
    _captionLabel.userInteractionEnabled = YES;
    _captionLabel.textAlignment = NSTextAlignmentJustified;
    _captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _captionLabel.attributedText = [self getCaptionAttributedStringWithText:nil];
    
    _titleLabel = [[FSPhotoBrowser_TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                         self.bounds.size.width,
                                                                         self.bounds.size.height)];
    _titleLabel.numberOfLines = 1;
    _titleLabel.userInteractionEnabled = YES;
    _titleLabel.textAlignment = NSTextAlignmentJustified;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _titleLabel.attributedText = [self getTitleAttributedStringWithText:nil];
    
    [self setTruncatingTokenForCaption:TRUNCATING_TOKEN];

    [_captionLabelScrollView addSubview:_titleLabel];
    [_captionLabelScrollView addSubview:_captionLabel];

    [self setupConstaints];
    
    UITapGestureRecognizer *titleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [_titleLabel addGestureRecognizer:titleTapGesture];
    
    UITapGestureRecognizer *captionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [_captionLabel addGestureRecognizer:captionTapGesture];
}

-(NSUInteger) getNumberofTitleLines {
    
    if(!_isCaptionExpanded) {
        
        if ([[self getPhoto] respondsToSelector:@selector(title)]) {
            
            if([self getPhoto].title.length > 0)
                return NO_LINES_FOR_UNEXPANDED_TITLE;
        }
    }
    return 0;
}

-(NSUInteger) getNumberofCaptionLines {
    
    if(!_isCaptionExpanded) {
        
        if ([[self getPhoto] respondsToSelector:@selector(caption)]) {
            if([self getPhoto].caption.length > 0)
                return NO_LINES_FOR_UNEXPANDED_CAPTION;
        }
    }
    
    return 0;
    
}

-(NSUInteger) getNumberOfLines {
    
    NSUInteger titlesLines = [self getNumberofTitleLines];
    NSUInteger captionLines = [self getNumberofCaptionLines];
    
    if(titlesLines > 0)
        return titlesLines + captionLines + 1;
    else
        return titlesLines + captionLines;
}

-(void) setCaptionStateExpanded:(BOOL)expanded {
    
    _isCaptionExpanded = expanded;
    
    if(expanded) {
        
        _captionLabel.numberOfLines = 0;
        _captionLabel.attributedTruncationToken = nil;
        
        [self setupFadingView];
        
        [UIView animateWithDuration:FADE_ANIMATION_DURATION animations:^{
            _fadingView.alpha = 0.5;
        }];
        
    }
    else {
        [UIView animateWithDuration:FADE_ANIMATION_DURATION animations:^{
            _fadingView.alpha = 0;
        } completion:^(BOOL finished) {
            [self clearFadingView];
        }];
        
        _captionLabel.numberOfLines = [self getNumberofCaptionLines];
        
        [self setTruncatingTokenForCaption:TRUNCATING_TOKEN];
    }
}

-(void) setupFadingView {
    
    if(!_fadingView) {
        _fadingView = [[UIView alloc] initWithFrame:self.superview.frame];
        _fadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _fadingView.userInteractionEnabled = NO;
        _fadingView.backgroundColor = [UIColor blackColor];
        _fadingView.alpha = 0;
        
        [self.superview insertSubview:_fadingView belowSubview:self];
        
        _fadingViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
        [self.superview addGestureRecognizer:_fadingViewTapGestureRecognizer];
    }
}
-(void) clearFadingView {
    [self.superview removeGestureRecognizer:_fadingViewTapGestureRecognizer];
    [_fadingView removeFromSuperview];
    _fadingView = nil;
}


-(void) setupConstaints {
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_captionLabelScrollView, _captionLabel, _titleLabel);
    
    NSArray *scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-captionPadding-[_titleLabel]|" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
    [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];
    
    scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-captionPadding-[_titleLabel]|" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
    [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];
    
    NSLayoutConstraint* captionWidthConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_captionLabelScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-CAPTION_PADDING*2];
    [_captionLabelScrollView addConstraint:captionWidthConstraint];
    
    scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-captionPadding-[_captionLabel]|" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
    [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];
    
    if([_titleLabel.text length] > 0) {
        scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLabel]-captionPadding-[_captionLabel]" options:0 metrics:@{@"captionPadding":@(INTER_CAPTION_PADDING)} views:views];
        [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];
    }
    else {
        scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-captionPadding-[_captionLabel]" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
        [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];
    }
    
    captionWidthConstraint = [NSLayoutConstraint constraintWithItem:_captionLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_captionLabelScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-CAPTION_PADDING*2];
    [_captionLabelScrollView addConstraint:captionWidthConstraint];
    
    
    NSArray *scrollViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_captionLabelScrollView]|" options:0 metrics:nil views:views];
    [self addConstraints:scrollViewConstraints];
    
    scrollViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_captionLabelScrollView]|" options:0 metrics:nil views:views];
    [self addConstraints:scrollViewConstraints];
}

-(void) setTruncatingTokenForCaption:(const NSString*)token {
    
    if(token == nil) {
        _captionLabel.attributedTruncationToken = nil;
    }
    else {
        NSMutableAttributedString* moreString = [[NSMutableAttributedString alloc] initWithString:(NSString*)ELLIPSES];
        
        [moreString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:NSLocalizedStringWithDefaultValue(@"ContentInfusionMore", nil, [NSBundle mainBundle], (NSString*)token, nil)]];
        
        [moreString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, moreString.length)];
        [moreString addAttribute:NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(ELLIPSES.length, moreString.length - ELLIPSES.length)];

        [moreString addAttribute:NSFontAttributeName value:[self getCaptionFont] range:NSMakeRange(0, moreString.length)];
        _captionLabel.attributedTruncationToken = moreString;
        
    }
}

-(UIFont*) getCaptionFont {
    
    UIFont* captionFont = nil;

    if ([[self getPhoto] respondsToSelector:@selector(captionFont)])
        captionFont =  [self getPhoto].captionFont;
    
    if(captionFont == nil)
    captionFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    return captionFont;
}

-(UIFont*) getTitleFont {
    
    UIFont* titleFont = nil;
    
    if ([[self getPhoto] respondsToSelector:@selector(titleFont)])
        titleFont =  [self getPhoto].titleFont;
    
    if(titleFont == nil)
        titleFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    return titleFont;
}

-(NSAttributedString*) getTitleAttributedStringWithText:(NSString*)text {
    
    NSString* titleString = text ? text : @"";
    
    if (!text && [[self getPhoto] respondsToSelector:@selector(title)])
        titleString = [[self getPhoto].title stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return [[NSMutableAttributedString alloc] initWithString:titleString?titleString:@"" attributes:@{NSFontAttributeName: [self getTitleFont],NSForegroundColorAttributeName :[UIColor whiteColor]}];
}

-(NSAttributedString*) getCaptionAttributedStringWithText:(NSString*)text {
    
    NSString* captionString = text ? text : @"";
    
    if (!text && [[self getPhoto] respondsToSelector:@selector(caption)])
        captionString = [[self getPhoto].caption stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return [[NSMutableAttributedString alloc] initWithString:captionString?captionString:@""  attributes:@{NSFontAttributeName: [self getCaptionFont],NSForegroundColorAttributeName :[UIColor whiteColor]}];
}

-(NSString*) getStringWithRepeatingString:(NSString*)str repeatCount:(NSUInteger)repeatCount{

    return [@"" stringByPaddingToLength:repeatCount withString:str startingAtIndex:0];
}

- (void)didRecognizeTapGesture:(UITapGestureRecognizer*)gesture {
    
    [self setCaptionStateExpanded:!_isCaptionExpanded];
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    if ([_captionLabel.text length] == 0)
        return CGSizeZero;
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBound.size.width;
    CGFloat screenHeight = screenBound.size.height;
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        screenWidth = screenBound.size.height;
        screenHeight = screenBound.size.width;
    }
    
    CGFloat maxHeight = screenHeight;
    CGFloat width = size.width - CAPTION_PADDING*2;
    
    CGRect titleRect = CGRectZero;
    if([_titleLabel.text length] > 0)
        titleRect = [[self getTitleAttributedStringWithText:[self getStringWithRepeatingString:@" " repeatCount:1]] boundingRectWithSize:(CGSize){width, maxHeight}
                                                                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                    context:nil];

    CGRect captionRect = [_captionLabel.attributedText boundingRectWithSize:(CGSize){width, maxHeight}
                                                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                        context:nil];
    if(!_isCaptionExpanded) {
        
        CGRect titleRectUnexpanded = CGRectZero;
        if([_titleLabel.text length] > 0)
            titleRectUnexpanded = [[self getTitleAttributedStringWithText:[self getStringWithRepeatingString:@" " repeatCount:1]] boundingRectWithSize:(CGSize){width, maxHeight} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        
        CGRect captionRectUnexpanded = [[self getCaptionAttributedStringWithText:[self getStringWithRepeatingString:@"\n" repeatCount:[self getNumberofCaptionLines]-1]] boundingRectWithSize:(CGSize){width, maxHeight} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        
        if(titleRectUnexpanded.size.height + captionRectUnexpanded.size.height < titleRect.size.height + captionRect.size.height) {
            
        return CGSizeMake(size.width, titleRectUnexpanded.size.height + captionRectUnexpanded.size.height + CAPTION_PADDING + CAPTION_PADDING + ([_titleLabel.text length]>0?INTER_CAPTION_PADDING:0));
        }

    }
    
    return CGSizeMake(size.width, MIN(titleRect.size.height + captionRect.size.height + CAPTION_PADDING + CAPTION_PADDING + ([_titleLabel.text length]>0?INTER_CAPTION_PADDING:0), maxHeight));
}


@end

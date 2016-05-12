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
static const NSUInteger NO_LINES_FOR_UNEXPANDED_TITLE_WITH_ADDITIONAL_TEXT = 3;
static const NSUInteger NO_LINES_FOR_UNEXPANDED_CAPTION = 4;
static const NSUInteger NO_LINES_FOR_UNEXPANDED_CAPTION_WITH_ADDITIONAL_TEXT = 1;

@interface IDMFSCaptionView()<UITextViewDelegate> {
    FSPhotoBrowser_TTTAttributedLabel *_captionLabel;
    FSPhotoBrowser_TTTAttributedLabel *_titleLabel;
    FSPhotoBrowser_TTTAttributedLabel *_additionalTextLabel;
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
    _titleLabel.userInteractionEnabled = YES;
    _titleLabel.textAlignment = NSTextAlignmentJustified;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.numberOfLines = [self getNumberofTitleLines];
    _titleLabel.attributedText = [self getTitleAttributedStringWithText:nil];

    [self setTruncatingTokenForCaption];

    [_captionLabelScrollView addSubview:_titleLabel];
    [_captionLabelScrollView addSubview:_captionLabel];


    _additionalTextLabel = [[FSPhotoBrowser_TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
    _additionalTextLabel.numberOfLines = 1;
    _additionalTextLabel.userInteractionEnabled = YES;
    _additionalTextLabel.textAlignment = NSTextAlignmentJustified;
    _additionalTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _additionalTextLabel.attributedText = [self getAdditionalTextAttributedStringWithText:nil];
    [_captionLabelScrollView addSubview:_additionalTextLabel];

    [self setupConstraints];

    UITapGestureRecognizer *additionalTextTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [_additionalTextLabel addGestureRecognizer:additionalTextTapGesture];

    UITapGestureRecognizer *titleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [_titleLabel addGestureRecognizer:titleTapGesture];

    UITapGestureRecognizer *captionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [_captionLabel addGestureRecognizer:captionTapGesture];
}

-(NSUInteger) getNumberofTitleLines {

    if(!_isCaptionExpanded) {

        if ([[self getPhoto] respondsToSelector:@selector(title)]) {

            if([self getPhoto].title.length > 0)
                return ([self getAdditionalTextAttributedStringWithText:nil].length > 0) ? NO_LINES_FOR_UNEXPANDED_TITLE_WITH_ADDITIONAL_TEXT : NO_LINES_FOR_UNEXPANDED_TITLE;
        }
    }
    return 0;
}

-(NSUInteger) getNumberofCaptionLines {

    if(!_isCaptionExpanded) {

        if ([[self getPhoto] respondsToSelector:@selector(caption)]) {
            if([self getPhoto].caption.length > 0)
                return ([self getAdditionalTextAttributedStringWithText:nil].length > 0) ? NO_LINES_FOR_UNEXPANDED_CAPTION_WITH_ADDITIONAL_TEXT : NO_LINES_FOR_UNEXPANDED_CAPTION;
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
        _titleLabel.numberOfLines = 0;
        _titleLabel.attributedTruncationToken = nil;

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
        _titleLabel.numberOfLines = [self getNumberofTitleLines];

        [self setTruncatingTokenForCaption];
    }

    if(SYSTEM_VERSION_LESS_THAN(@"8.0"))
        [[self parentController].view setNeedsLayout];
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


-(void) setupConstraints {

    NSDictionary *views = NSDictionaryOfVariableBindings(_captionLabelScrollView, _captionLabel, _titleLabel, _additionalTextLabel);

    NSArray *scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-captionPadding-[_titleLabel]|" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
    [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];

    scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-captionPadding-[_titleLabel]|" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
    [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];

    NSLayoutConstraint* captionWidthConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_captionLabelScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-CAPTION_PADDING*2];
    [_captionLabelScrollView addConstraint:captionWidthConstraint];

    scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-captionPadding-[_captionLabel]|" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
    [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];

    if ([_titleLabel.text length] > 0) {
        scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLabel]-captionPadding-[_captionLabel]" options:0 metrics:@{@"captionPadding":@(INTER_CAPTION_PADDING)} views:views];
        [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];
    }
    else {
        scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-captionPadding-[_captionLabel]" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
        [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];
    }

    if ([_additionalTextLabel.text length] > 0) {
        scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-captionPadding-[_additionalTextLabel]|" options:0 metrics:@{@"captionPadding":@(CAPTION_PADDING)} views:views];
        [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];

        scrollViewLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_captionLabel]-captionPadding-[_additionalTextLabel]" options:0 metrics:@{@"captionPadding":@(INTER_CAPTION_PADDING)} views:views];
        [_captionLabelScrollView addConstraints:scrollViewLabelConstraints];
    }

    captionWidthConstraint = [NSLayoutConstraint constraintWithItem:_captionLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_captionLabelScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-CAPTION_PADDING*2];
    [_captionLabelScrollView addConstraint:captionWidthConstraint];


    NSArray *scrollViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_captionLabelScrollView]|" options:0 metrics:nil views:views];
    [self addConstraints:scrollViewConstraints];

    scrollViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_captionLabelScrollView]|" options:0 metrics:nil views:views];
    [self addConstraints:scrollViewConstraints];
}

-(void) setTruncatingTokenForCaption {
    NSString *truncatingToken = [self getPhoto].truncatingToken;
    NSMutableAttributedString* moreString = [[NSMutableAttributedString alloc] initWithString:(NSString*)ELLIPSES];
    [moreString appendAttributedString:[[NSMutableAttributedString alloc] initWithString: (truncatingToken) ? truncatingToken : TRUNCATING_TOKEN]];
    [moreString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, moreString.length)];
    [moreString addAttribute:NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(ELLIPSES.length, moreString.length - ELLIPSES.length)];
    [moreString addAttribute:NSFontAttributeName value:[self getCaptionFont] range:NSMakeRange(0, moreString.length)];
    if([self getNumberofCaptionLines] > 1)
        _captionLabel.attributedTruncationToken = moreString;
    if([self getNumberofTitleLines] > 1)
        _titleLabel.attributedTruncationToken = moreString;
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

-(UIFont*) getAdditionalTextFont
{
    UIFont* additionalTextfont = nil;
    if ([[self getPhoto] respondsToSelector:@selector(additionalTextFont)]) {
        additionalTextfont =  [self getPhoto].additionalTextFont;
    }
    if(additionalTextfont == nil) {
        additionalTextfont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    return additionalTextfont;
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

-(NSAttributedString*) getAdditionalTextAttributedStringWithText:(NSString*)text
{
    NSString* additionalTextString = text ? text : @"";
    if (!text && [[self getPhoto] respondsToSelector:@selector(additionalText)]) {
        additionalTextString = [[self getPhoto].additionalText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    return [[NSMutableAttributedString alloc] initWithString:additionalTextString?additionalTextString:@"" attributes:@{NSFontAttributeName: [self getAdditionalTextFont],NSForegroundColorAttributeName :[UIColor colorWithRed:102.0f/255.0f green:100.0f/255.0f blue:89.0f/255.0f alpha:1.0f]}];
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

    CGFloat maxHeight = FLT_MAX;
    CGFloat width = size.width - CAPTION_PADDING*2;

    CGRect titleRect = CGRectZero;
    CGSize titleSize = CGSizeZero;
    if([_titleLabel.text length] > 0)
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
            titleRect = [_titleLabel.attributedText boundingRectWithSize:(CGSize){width, maxHeight}
                                                                 options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                 context:nil];
        else {
            titleSize = [_titleLabel sizeThatFits:CGSizeMake(width, maxHeight)];
            titleRect.size = titleSize;
        }
    }

    CGRect captionRect = CGRectZero;
    CGSize captionSize = CGSizeZero;

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        captionRect = [_captionLabel.attributedText boundingRectWithSize:(CGSize){width, maxHeight}
                                                                 options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                 context:nil];
    else {
        captionSize = [_captionLabel sizeThatFits:CGSizeMake(width, maxHeight)];
        captionRect.size = captionSize;
    }

    CGRect additionalTextRect = CGRectZero;
    CGSize additionalTextSize = CGSizeZero;

    if ([_additionalTextLabel.text length] > 0) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            additionalTextRect = [[self getAdditionalTextAttributedStringWithText:[self getStringWithRepeatingString:@" " repeatCount:1]] boundingRectWithSize:(CGSize){width, maxHeight}
                                                                                                                                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                                                                                                       context:nil];
        } else {
            additionalTextSize = [_additionalTextLabel sizeThatFits:CGSizeMake(width, maxHeight)];
            additionalTextRect.size = additionalTextSize;
        }
    }

    CGSize newsize = CGSizeZero;
    if(!_isCaptionExpanded) {

        CGRect titleRectUnexpanded = CGRectZero;
        CGSize titleSizeUnexpanded = CGSizeZero;

        if([_titleLabel.text length] > 0) {

            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                NSUInteger reapeatingTitleLineCount = [self getNumberofTitleLines];
                reapeatingTitleLineCount = (reapeatingTitleLineCount > 1) ? reapeatingTitleLineCount - 1 : 1;
                NSString* repeatingString = (reapeatingTitleLineCount > 1) ? @"\n" : @" ";
                titleRectUnexpanded = [[self getTitleAttributedStringWithText:[self getStringWithRepeatingString:repeatingString repeatCount: reapeatingTitleLineCount]] boundingRectWithSize:(CGSize){width, maxHeight} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
            }
            else {
                titleSizeUnexpanded = [_titleLabel sizeThatFits:CGSizeMake(width, maxHeight)];
                titleRectUnexpanded.size = titleSizeUnexpanded;
            }
        }

        CGRect captionRectUnexpanded = CGRectZero;
        CGSize captionSizeUnexpanded = CGSizeZero;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            NSUInteger reapeatingCaptionLineCount = [self getNumberofCaptionLines];
            reapeatingCaptionLineCount = (reapeatingCaptionLineCount > 1) ? reapeatingCaptionLineCount - 1 : 1;
            NSString* repeatingCaptionString = (reapeatingCaptionLineCount > 1) ? @"\n" : @" ";
            captionRectUnexpanded = [[self getCaptionAttributedStringWithText:[self getStringWithRepeatingString:repeatingCaptionString repeatCount: reapeatingCaptionLineCount]] boundingRectWithSize:(CGSize){width, maxHeight} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        }
        else {
            captionSizeUnexpanded = [_captionLabel sizeThatFits:CGSizeMake(width, maxHeight)];
            captionRectUnexpanded.size = captionSizeUnexpanded;
        }

        CGRect additionalTextRectUnexpanded = CGRectZero;
        CGSize additionalTextSizeUnexpanded = CGSizeZero;

        if([_additionalTextLabel.text length] > 0) {

            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
                additionalTextRectUnexpanded = [[self getAdditionalTextAttributedStringWithText:[self getStringWithRepeatingString:@" " repeatCount:1]] boundingRectWithSize:(CGSize){width, maxHeight} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
            else {
                additionalTextSizeUnexpanded = [_additionalTextLabel sizeThatFits:CGSizeMake(width, maxHeight)];
                additionalTextRectUnexpanded.size = additionalTextSizeUnexpanded;
            }
        }

        if(titleRectUnexpanded.size.height + captionRectUnexpanded.size.height + additionalTextRectUnexpanded.size.height < titleRect.size.height + captionRect.size.height + additionalTextRect.size.height) {

            newsize =  CGSizeMake(size.width, ceil(titleRectUnexpanded.size.height) + ceil(captionRectUnexpanded.size.height) + ceil(additionalTextRectUnexpanded.size.height) + CAPTION_PADDING + CAPTION_PADDING + ([_titleLabel.text length]>0?INTER_CAPTION_PADDING:0) + ([_additionalTextLabel.text length]>0?INTER_CAPTION_PADDING:0));
            _captionLabelScrollView.contentSize = newsize;

            return newsize;
        }

    }

    newsize = CGSizeMake(size.width, MIN(ceil(titleRect.size.height) + ceil(captionRect.size.height) + ceil(additionalTextRect.size.height) + CAPTION_PADDING + CAPTION_PADDING + ([_titleLabel.text length]>0?INTER_CAPTION_PADDING:0) + ([_additionalTextLabel.text length]>0?INTER_CAPTION_PADDING:0), screenHeight));
    
    _captionLabelScrollView.contentSize = CGSizeMake(newsize.width, _captionLabel.frame.origin.y+_captionLabel.frame.size.height + (newsize.height >= screenHeight ? CAPTION_PADDING: 0));
    
    return newsize;
}


@end

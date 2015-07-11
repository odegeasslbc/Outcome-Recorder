//
//  CFShareCircleView.m
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import "CFShareCircleView.h"

@interface CFShareCircleView()
- (void)setUpCircleLayers; /* Build all the layers to be displayed onto the view of the share circle. */
- (void)setUpSharingOptionsView; /* Build the view to show all the sharers when there is too many for the circle. */
- (void)updateLayers; /* Updates all the layers based on the new current position of the touch input. */
- (void)animateImagesIn; /* Animation used when the view is first presented to the user. */
- (void)animateImagesOut; /* Animation used to reset the images so the animation in works correctly. */
- (void)animateMoreOptionsIn; /* Animates the table view in to show all the sharer options. */
- (void)animateMoreOptionsOut; /* Hides the table view with all the sharers. */
- (NSString *)sharerNameHoveringOver; /* Return the name of the sharer that the user is hovering over at this exact moment in time. */
- (CGPoint)touchLocationAtPoint:(CGPoint)point; /* Determines where the touch images is going to be placed inside of the view. */
- (BOOL)circleEnclosesPoint:(CGPoint)point; /* Returns if the point is inside the cirlce. */
- (UIImage *)whiteOverlayedImage:(UIImage*)image;
@end

@implementation CFShareCircleView{
    CGFloat X;
    CGFloat Y;
    CGPoint _location;
    CGPoint _currentPosition, _origin;
    BOOL _dragging, _circleIsVisible, _sharingOptionsIsVisible;
    CALayer *_closeButtonLayer, *_overlayLayer;
    CAShapeLayer *_backgroundLayer, *_touchLayer;
    CATextLayer *_introTextLayer, *_shareTitleLayer;
    NSMutableArray *_imageLayers, *_sharers;
    NSUInteger _numberSharersInCircle;
    UIView *_sharingOptionsView;
    NSMutableArray *_sharerLocations;
}

#define BACKGROUND_SIZE 190
#define PATH_SIZE 130
#define IMAGE_SIZE 30
#define TOUCH_SIZE 50
#define MAX_VISIBLE_SHARERS 6
//#define X 0
//#define Y 0

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        _sharers = [[NSMutableArray alloc] initWithObjects: [CFSharer pinterest], [CFSharer googleDrive], [CFSharer twitter], [CFSharer facebook], [CFSharer evernote], [CFSharer logout], [CFSharer mail], [CFSharer photoLibrary], nil];
        [self setUpCircleLayers];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame location:(CGPoint )location {
    X = location.x;
    Y = location.y;
    self = [super initWithFrame:frame];
    if (self) {
        _sharers = [[NSMutableArray alloc] initWithObjects: [CFSharer pinterest], [CFSharer googleDrive], [CFSharer twitter], [CFSharer facebook], [CFSharer evernote], [CFSharer logout], [CFSharer mail], [CFSharer photoLibrary], nil];
        [self setUpCircleLayers];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame sharers:(NSArray *)sharers {
    self = [super initWithFrame:frame];
    if (self) {
        _sharers = [[NSMutableArray alloc] initWithArray:sharers];
        [self setUpCircleLayers];
    }
    return self;
}

- (void)layoutSubviews {
    // Adjust geometry when updating the subviews.
    _overlayLayer.frame = self.bounds;
    _origin = CGPointMake(CGRectGetMidX(self.bounds)+X, CGRectGetMidY(self.bounds)+Y);
    _currentPosition = _origin;
    if(_circleIsVisible) {
        _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    } else {
        _backgroundLayer.position = CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds));
    }
    if(_sharingOptionsIsVisible)
        _sharingOptionsView.frame = self.bounds;
    [self updateLayers];
}

#pragma mark -
#pragma mark - Private methods

- (void)setUpCircleLayers {  
    // Set all the defaults for the share circle.
    _imageLayers = [[NSMutableArray alloc] init];
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _circleIsVisible = NO;
    _sharingOptionsIsVisible = NO;
    _origin = CGPointMake(CGRectGetMidX(self.bounds)+X, CGRectGetMidY(self.bounds)+Y);
    _currentPosition = _origin;
    
    // Create the CGFont that is to be used on the layers.
    NSString *fontName = @"HelveticaNeue-Light";
    CFStringRef cfFontName = (CFStringRef)CFBridgingRetain(fontName);
    CGFontRef font = CGFontCreateWithFontName(cfFontName);
    CFRelease(cfFontName);
    
    // Determine the number of sharers in the circle. If it is more then the max then let's insert the more sharer into the array.
    // Also construct the all options view if the max has been exceeded.
    if(_sharers.count > MAX_VISIBLE_SHARERS) {
        _numberSharersInCircle = MAX_VISIBLE_SHARERS;
        [self setUpSharingOptionsView];
    } else {
        _numberSharersInCircle = _sharers.count;
    }
    
    // Create the overlay layer for the entire screen.
    _overlayLayer = [CAShapeLayer layer];
    _overlayLayer.frame = self.bounds;
    _overlayLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8].CGColor;
    [self.layer addSublayer:_overlayLayer];
    
    // Create a larger circle layer for the background of the Share Circle.
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.frame = CGRectMake(CGRectGetMidX(self.bounds) - BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds) - BACKGROUND_SIZE/2.0, BACKGROUND_SIZE, BACKGROUND_SIZE);
    _backgroundLayer.position = CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds));
    //小圆圈的颜色
    _backgroundLayer.fillColor = [UIColor colorWithWhite:1 alpha: 0.8].CGColor;
    
    CGMutablePathRef backgroundPath = CGPathCreateMutable();
    CGRect backgroundRect = CGRectMake(X,Y,BACKGROUND_SIZE,BACKGROUND_SIZE);
    CGPathAddEllipseInRect(backgroundPath, nil, backgroundRect);
    _backgroundLayer.path = backgroundPath;
    CGPathRelease(backgroundPath);
    [self.layer addSublayer:_backgroundLayer];
    
    
    // Create the layers for all the sharing service images.
    for(int i = 0; i < _numberSharersInCircle; i++) {
        CFSharer *sharer;
        if(i == 4 && _sharers.count > 5)
            sharer = [[CFSharer alloc] initWithName:@"More" imageName:@"more.png"];
        else
            sharer = [_sharers objectAtIndex:i];
        UIImage *image = sharer.image;
        
        // Construct the image layer which will contain our image.
        CALayer *imageLayer = [CALayer layer];
        imageLayer.bounds = CGRectMake(0, 0, IMAGE_SIZE+30, IMAGE_SIZE+30);
        imageLayer.frame = CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);
        imageLayer.position = CGPointMake(BACKGROUND_SIZE/2.0+X, BACKGROUND_SIZE/2.0+Y);
        imageLayer.contents = (id)image.CGImage;
        imageLayer.shadowColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor;
        imageLayer.shadowOffset = CGSizeMake(1, 1);
        imageLayer.shadowRadius = 0;
        imageLayer.shadowOpacity = 1.0;
        imageLayer.name = sharer.name;
        
        [_imageLayers addObject:imageLayer];
        [_backgroundLayer addSublayer:[_imageLayers objectAtIndex:i]];
    }
    
    // Create the touch layer for the Share Circle.
    _touchLayer = [CAShapeLayer layer];
    _touchLayer.frame = CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE);
    CGMutablePathRef circularPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circularPath, NULL, CGRectMake(0, 0, TOUCH_SIZE, TOUCH_SIZE));
    _touchLayer.path = circularPath;
    CGPathRelease(circularPath);
    _touchLayer.position = CGPointMake(CGRectGetMidX(self.layer.bounds), CGRectGetMidY(self.layer.bounds));
    _touchLayer.opacity = 0.0;
    _touchLayer.fillColor = [UIColor clearColor].CGColor;
    _touchLayer.strokeColor = [UIColor blackColor].CGColor;
    _touchLayer.lineWidth = 2.0f;
    [self.layer addSublayer:_touchLayer];
    
    // Create the intro text layer to help the user.
    _introTextLayer = [CATextLayer layer];
    _introTextLayer.string = @"Drag\nto";
    _introTextLayer.wrapped = YES;
    _introTextLayer.alignmentMode = kCAAlignmentCenter;
    _introTextLayer.fontSize = 14.0;
    _introTextLayer.font = font;
    _introTextLayer.foregroundColor = [UIColor blackColor].CGColor;
    _introTextLayer.frame = CGRectMake(0, 0, 60, 31);
    _introTextLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds)+X, CGRectGetMidY(_backgroundLayer.bounds)+Y);
    _introTextLayer.contentsScale = [[UIScreen mainScreen] scale];
    _introTextLayer.opacity = 0.0;
    [_backgroundLayer addSublayer:_introTextLayer];
    
    // Create the share title text layer.
    _shareTitleLayer = [CATextLayer layer];
    _shareTitleLayer.string = @"";
    _shareTitleLayer.wrapped = YES;
    _shareTitleLayer.alignmentMode = kCAAlignmentCenter;
    _shareTitleLayer.fontSize = 20.0;
    _shareTitleLayer.font = font;
    _shareTitleLayer.foregroundColor = [[UIColor blackColor] CGColor];
    _shareTitleLayer.frame = CGRectMake(0, 0, 120, 28);
    _shareTitleLayer.position = CGPointMake(CGRectGetMidX(_backgroundLayer.bounds)+X, CGRectGetMidY(_backgroundLayer.bounds)+Y);
    _shareTitleLayer.contentsScale = [[UIScreen mainScreen] scale];
    _shareTitleLayer.opacity = 0.0;
    [_backgroundLayer addSublayer:_shareTitleLayer];
    
    // Release the font.
    CGFontRelease(font);
}

- (void)setUpSharingOptionsView {
    CGRect frame = self.bounds;
    frame.origin.y += frame.size.height;
    _sharingOptionsView = [[UIView alloc] initWithFrame:frame];
    _sharingOptionsView.backgroundColor = [UIColor whiteColor];
    _sharingOptionsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add the label.
    UILabel *sharingOptionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _sharingOptionsView.frame.size.width, 300.0f)];
    sharingOptionsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sharingOptionsLabel.text = @"Sharing Options";
    sharingOptionsLabel.textAlignment = NSTextAlignmentCenter ;
    sharingOptionsLabel.textColor = [UIColor whiteColor];
    sharingOptionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0f];
    sharingOptionsLabel.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:1.0];

    sharingOptionsLabel.opaque = NO;
    [_sharingOptionsView addSubview:sharingOptionsLabel];
    
    // Add table view.
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 175.0f, _sharingOptionsView.frame.size.width, _sharingOptionsView.frame.size.height)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 60.0f;
    [_sharingOptionsView addSubview:tableView];
    
    // Add the close button.
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(_sharingOptionsView.frame.size.width - 45.f,130.0f,45.0f,45.0f);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    // Create an image for the button when highlighted.
    CGRect rect = CGRectMake(0.0f, 0.0f, 45.0f, 45.0f);
    UIImage *closeButtonImage = [UIImage imageNamed:@"close.png"];
    
    //closeButtonImage.scale = 1.5;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:0.5] CGColor]);
    CGContextFillRect(context, rect);
    [closeButtonImage drawInRect:CGRectMake(15.0f,15.0f,closeButtonImage.size.width,closeButtonImage.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *highlightedButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [closeButton setBackgroundImage:highlightedButtonImage forState:UIControlStateHighlighted];
    
    // Create the normal image for the button.
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    UIGraphicsGetCurrentContext();
    [closeButtonImage drawInRect:CGRectMake(15.0f,15.0f,closeButtonImage.size.width,closeButtonImage.size.height) blendMode:kCGBlendModeNormal alpha:0.5];
    UIImage *normalButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [closeButton setBackgroundImage:normalButtonImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(animateMoreOptionsOut) forControlEvents:UIControlEventTouchUpInside];
    [_sharingOptionsView addSubview:closeButton];
}

#define SUBSTANTIAL_MARGIN 20.0

- (void)updateLayers {
    // Only update if the circle is presented to the user.
    if(_circleIsVisible) {
        // Update the touch layer without waiting for an animation if the difference is not substantial.
        CGPoint newTouchLocation = [self touchLocationAtPoint:_currentPosition];
        if(MAX(ABS(newTouchLocation.x - _touchLayer.position.x),ABS(newTouchLocation.y - _touchLayer.position.y)) > SUBSTANTIAL_MARGIN) {
            _touchLayer.position = newTouchLocation;
        } else {
            [CATransaction begin];
            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
            _touchLayer.position = newTouchLocation;
            [CATransaction commit];
        }
        
        NSString *sharerName = [self sharerNameHoveringOver];
        // Update the images.
        for(int i = 0; i < [_imageLayers count]; i++) {
            CALayer *layer = [_imageLayers objectAtIndex:i];
            if(!_dragging || [sharerName isEqualToString:layer.name])
                layer.opacity = 1.0;
            else
                layer.opacity = 0.6;
        }
        
        // Update the touch layer.
        if(sharerName)
            _touchLayer.opacity = 1.0;
        else if(_dragging)
            _touchLayer.opacity = 0.5;
        else
            _touchLayer.opacity = 0.1;
        
        // Update the intro text layer.
        if(_dragging)
            _introTextLayer.opacity = 0.0;
        else
            _introTextLayer.opacity = 0.6;
        
        // Update the share title text layer
        if(sharerName) {
            _shareTitleLayer.string = sharerName;
            _shareTitleLayer.opacity = 0.6;
        } else {
            _shareTitleLayer.opacity = 0.0;
            _shareTitleLayer.string = @"";
        }
    }
    
    // Hide all the layers if the they are not presented to the user.
    else {
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        _touchLayer.opacity = 0.0;
        _introTextLayer.opacity = 0.0;
        _shareTitleLayer.opacity = 0.0;
        [CATransaction commit];
    }
}

- (void)animateImagesIn {
    if(_sharerLocations == nil) {
        _sharerLocations = [[NSMutableArray alloc] init];
        for(int i = 0; i < _numberSharersInCircle; i++) {
            // Animate the base layer for the main rotation.
            CALayer* layer = [_imageLayers objectAtIndex:i];
            
            // Calculate the x and y coordinate. Points go around the unit circle starting at pi = 0.
            float trig = i/(_numberSharersInCircle/2.0)*M_PI;
            float x = layer.position.x + cosf(trig)*PATH_SIZE/2.0;
            float y = layer.position.y - sinf(trig)*PATH_SIZE/2.0;
            [_sharerLocations addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            layer.position = [[_sharerLocations objectAtIndex:i] CGPointValue];
        }  
    } else {
        for(int i = 0; i < _numberSharersInCircle; i++) {
            // Animate the base layer for the main rotation.
            CALayer* layer = [_imageLayers objectAtIndex:i];
            layer.position = [[_sharerLocations objectAtIndex:i] CGPointValue];
        }
    }
}

- (void)animateImagesOut {
    for(int i = 0; i < _numberSharersInCircle; i++) {
        // Animate the base layer for the main rotation.
        CALayer* layer = [_imageLayers objectAtIndex:i];
        layer.position = CGPointMake(BACKGROUND_SIZE/2.0+X*1.5, BACKGROUND_SIZE/2.0+Y*1.5);
    }
}

- (NSString*)sharerNameHoveringOver {
    NSString *name = nil;
    CALayer *hitLayer = [_backgroundLayer hitTest:_touchLayer.position];
    if(_dragging && hitLayer.name) {
        return hitLayer.name;
    }
    return name;
}

#define GRAVITATIONAL_PULL 30.0

- (CGPoint)touchLocationAtPoint:(CGPoint)point {
    
    // If not dragging make sure we redraw the touch image at the origin.
    if(!_dragging)
        point = _origin;
    
    // See if the new point is outside of the circle's radius.
    else if(pow(BACKGROUND_SIZE/2.0 - TOUCH_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2))) {
        
        // Determine x and y from the center of the circle.
        point.x = _origin.x - point.x;
        point.y -= _origin.y;
        
        // Calculate the angle on the around the circle.
        double angle = atan2(point.y, point.x);
        
        // Get the new x and y from the point on the edge of the circle subtracting the size of the touch image.
        point.x = _origin.x - (BACKGROUND_SIZE/2.0 - TOUCH_SIZE/2.0) * cos(angle);
        point.y = _origin.y + (BACKGROUND_SIZE/2.0 - TOUCH_SIZE/2.0) * sin(angle);
    }
    
    // Add the gravitation physics effect.
    for(NSValue *value in _sharerLocations) {
        CGPoint sharerLocation = [value CGPointValue];
        
        // Convert the sharer location to the full screen bounds location.
        sharerLocation.x += _backgroundLayer.frame.origin.x;
        sharerLocation.y += _backgroundLayer.frame.origin.y;
        
        if(MAX(ABS(sharerLocation.x - point.x),ABS(sharerLocation.y - point.y)) < GRAVITATIONAL_PULL)
            point = sharerLocation;
    }
    
    return point;
}

- (BOOL)circleEnclosesPoint:(CGPoint)point {
    if(pow(BACKGROUND_SIZE/2.0,2) < (pow(point.x - _origin.x,2) + pow(point.y - _origin.y,2)))
        return NO;
    else
        return YES;
}

- (void)animateMoreOptionsIn {
    _sharingOptionsIsVisible = YES;
    [self addSubview:_sharingOptionsView];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _sharingOptionsView.frame = self.bounds;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)animateMoreOptionsOut {
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect frame = _sharingOptionsView.frame;
                         frame.origin.y += self.bounds.size.height;
                         _sharingOptionsView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         _sharingOptionsIsVisible = NO;
                         self.hidden = YES;
                         [_sharingOptionsView removeFromSuperview];
                     }];
}

-  (UIImage *)whiteOverlayedImage:(UIImage *)image {
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    return tempImage;
}

#pragma mark -
#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqual:@"animateOut"]) {
        if(!_circleIsVisible && !_sharingOptionsIsVisible) self.hidden = YES;
    } else if([[anim valueForKey:@"id"] isEqual:@"animateIn"]) {
        _circleIsVisible = YES;
        [self updateLayers];
    }
}

#pragma mark -
#pragma mark - Touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    // Make sure the user starts with touch inside the circle.
    if([self circleEnclosesPoint: _currentPosition]) {
        _dragging = YES;
        [self updateLayers];
    } else {
        [self hide];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    
    if(_dragging) [self updateLayers];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    _currentPosition = [touch locationInView:self];
    CALayer *hitLayer = [_backgroundLayer hitTest:_touchLayer.position];
    
    if(_dragging && hitLayer.name) {
        // Return the sharer that was selected and then animate out.
        if([hitLayer.name isEqualToString:@"More"]) {
            [self animateMoreOptionsIn];
        } else {
            for(CFSharer *sharer in _sharers) {
                if([sharer.name isEqualToString:hitLayer.name]) {
                    [_delegate shareCircleView:self didSelectSharer:sharer];
                    break;
                }
            }
        }
        [self hide];
    }
    _currentPosition = _origin;
    _dragging = NO;
    [self updateLayers];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Reset location.
    _currentPosition = _origin;
    _dragging = NO;
}

#pragma mark -
#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self animateMoreOptionsOut];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate shareCircleView:self didSelectSharer:[_sharers objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#define LABEL_TAG 13
#define IMAGE_VIEW_TAG 14
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SharerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SharerCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    
    CFSharer *sharer = [_sharers objectAtIndex:indexPath.row];
    // Determine if the label or imageview have already been created.
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:LABEL_TAG];;
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
    if(nameLabel == nil) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 10.0, 150.0, 40.0)];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
        nameLabel.highlightedTextColor = [UIColor whiteColor];
        nameLabel.tag = LABEL_TAG;
        [cell.contentView addSubview:nameLabel];
    }
    if(imageView == nil)  {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, 15.0, 30.0, 30.0)];
        imageView.tag = IMAGE_VIEW_TAG;
        [cell.contentView addSubview:imageView];
    }   
    
    // Set the label and image properties.
    nameLabel.text = sharer.name;
    imageView.image = sharer.image;
    imageView.highlightedImage = [self whiteOverlayedImage:sharer.image];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sharers.count;
}

#pragma mark -
#pragma mark - Public methods

- (void)show {
    self.hidden = NO;

    // Set up the animation for the background layer to come in.
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // Set delegate and key/value to know when animation ends.
    animation.delegate = self;
    [animation setValue:@"animateIn" forKey:@"id"];
    
    // Construct the animation.
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMaxY(self.bounds))];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    // Intiate the animation and ensure the layer stays there.
    _backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [_backgroundLayer addAnimation:animation forKey:@"position"];
    
    // Move the sharer images.
    [self animateImagesIn];
}

- (void)hide {
    _circleIsVisible = NO;
    [self updateLayers];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // Set delegate and key/value to know when animation ends.
    animation.delegate = self;
    [animation setValue:@"animateOut" forKey:@"id"];
    
    // Construct the animation.
    animation.fromValue = [_backgroundLayer valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMaxY(self.bounds))];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Intiate the animation.
    _backgroundLayer.position = CGPointMake(self.bounds.size.width + BACKGROUND_SIZE/2.0, CGRectGetMidY(self.bounds));
    [_backgroundLayer addAnimation:animation forKey:@"position"];
    
    [self animateImagesOut];
}

@end
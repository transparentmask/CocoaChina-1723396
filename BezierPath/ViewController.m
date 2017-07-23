//
//  ViewController.m
//  BezierPath
//
//  Created by Martin Yin on 23/07/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CAShapeLayer *bezierPathLayer;

@property (nonatomic, weak) IBOutlet UIButton *prevButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@property (nonatomic, assign) NSUInteger imagesCount;
@property (nonatomic, strong) NSArray<UIImage *> *images;
@property (nonatomic, strong) NSArray<UIBezierPath *> *bezierPaths;
@property (nonatomic, assign) NSUInteger currentIndex;

@end

@implementation ViewController

- (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *chars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    self.imagesCount = [chars length];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.imagesCount];
    NSMutableArray *bezierPaths = [NSMutableArray arrayWithCapacity:self.imagesCount];
    
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)@"Helvetica", 128, NULL);
    CGFloat capHeight = ceilf(CTFontGetCapHeight(font))+5;
    CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, -capHeight);

    for(NSInteger i = 0; i < self.imagesCount; i++) {
        UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, self.imageView.opaque, self.imageView.contentScaleFactor);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[self randomColor] CGColor]);
        CGContextFillRect(context, self.imageView.bounds);
        [images addObject:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
        
        unichar character;
        [chars getCharacters:&character range:NSMakeRange(i, 1)];
        CGGlyph glyph;
        CTFontGetGlyphsForCharacters(font, &character, &glyph, 1);
        CGPathRef path = CTFontCreatePathForGlyph(font, glyph, &transform);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path];
        [bezierPaths addObject:bezierPath];
        CGPathRelease(path);
    }
    
    CFRelease(font);
    
    self.images = images;
    self.bezierPaths = bezierPaths;
    
    self.prevButton.layer.borderWidth = 1;
    self.prevButton.layer.borderColor = self.prevButton.currentTitleColor.CGColor;
    self.prevButton.layer.cornerRadius = 5;

    self.nextButton.layer.borderWidth = 1;
    self.nextButton.layer.borderColor = self.prevButton.currentTitleColor.CGColor;
    self.nextButton.layer.cornerRadius = 5;
    
    self.bezierPathLayer = [CAShapeLayer layer];
    self.bezierPathLayer.frame = CGRectMake(0, 0, capHeight, capHeight);
    self.bezierPathLayer.position = CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height/2);
    self.bezierPathLayer.strokeColor = [[UIColor blackColor] CGColor];
    [self.imageView.layer addSublayer:self.bezierPathLayer];
    
    [self showImageWithIndex:0];
}

- (void)showImageWithIndex:(NSUInteger)index {
    self.currentIndex = MIN(index, self.imagesCount-1);

    self.imageView.image = self.images[self.currentIndex];
    self.bezierPathLayer.path = [self.bezierPaths[self.currentIndex] CGPath];
}

- (IBAction)showPrevImage:(id)sender {
    [self showImageWithIndex:(self.currentIndex == 0)?(self.imagesCount-1):(self.currentIndex-1)];
}

- (IBAction)showNextImage:(id)sender {
    [self showImageWithIndex:(self.currentIndex == self.imagesCount-1)?0:(self.currentIndex+1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  PhotoCell.m
//  Prototyper
//
//  Created by Andy Qua on 09/01/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "PhotoCell.h"

@interface PhotoCell ()
@end

@implementation PhotoCell


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 5;
    }
    return self;
}
- (void) setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

- (void) setHighlight:(BOOL)highlight
{
    _highlight = highlight;
    
    if ( _highlight )
        self.backgroundColor = [UIColor greenColor];
    else
        self.backgroundColor = [UIColor clearColor];
}
@end

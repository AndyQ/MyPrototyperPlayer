//
//  ImageLink.m
//  Prototyper
//
//  Created by Andy Qua on 10/01/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import "ImageLink.h"

@implementation ImageLink

+ (ImageLink *) fromDictionary:(NSDictionary *)dict;
{
    ImageLink *link = [ImageLink new];
    
    link.rect = CGRectFromString(dict[@"rect"] );
    link.linkedToId = dict[@"linkedToId"];
    link.transition = [dict[@"transition"] intValue];
    link.linkType = [dict[@"linkType"] intValue];
    link.infoText = dict[@"infoText"];
    
    return link;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.transition = IT_None;
        self.linkType = ILT_Normal;
        self.infoText = @"";
    }
    return self;
}

- (NSDictionary *) toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    dict[@"rect"] = NSStringFromCGRect(self.rect);
    dict[@"linkedToId"] = self.linkedToId != nil ? self.linkedToId : @"";
    dict[@"transition"] = @(self.transition);
    dict[@"linkType"] = @(self.linkType);
    dict[@"infoText"] = self.infoText != nil ? self.infoText : @"";

    return dict;
}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.rect = [aDecoder decodeCGRectForKey:@"rect"];
        self.linkedToId = [aDecoder decodeObjectForKey:@"linkedToId"];
        
        if ( [aDecoder containsValueForKey:@"transition"] )
            self.transition = [aDecoder decodeInt32ForKey:@"transition"];
        else
            self.transition = IT_None;

        if ( [aDecoder containsValueForKey:@"linkType"] )
            self.transition = [aDecoder decodeInt32ForKey:@"linkType"];
        else
            self.transition = ILT_Normal;
        
        if ( [aDecoder containsValueForKey:@"infoText"] )
            self.infoText = [aDecoder decodeObjectForKey:@"infoText"];
        else
            self.infoText = @"";
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeCGRect:self.rect forKey:@"rect"];
    [coder encodeObject:self.linkedToId forKey:@"linkedToId"];
    [coder encodeInt32:self.transition forKey:@"transition"];
    [coder encodeInt32:self.linkType forKey:@"linkType"];
    [coder encodeObject:self.infoText forKey:@"infoText"];
}
@end

//
//  ImageView.m
//  QQ
//
//  Created by zhangke on 15/4/8.
//  Copyright (c) 2015年 zhangke. All rights reserved.
//

#import "ImageView.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"


// Constants for view sizing and alignment
#define MESSAGE_FONT_SIZE       (13.0)
#define BUFFER_WHITE_SPACE      (14.0)
#define DETAIL_TEXT_LABEL_WIDTH (200.0)

#define BALLOON_INSET_Y   22
#define BALLOON_INSET_X   24

#define BALLOON_Y_PANDING 50

#define BALLOON_EDGE_CENTERY   4

#define LOGOWIDTH   35



@interface ImageView ()

// Background image
@property (nonatomic, retain) UIImageView *balloonView;

// Name text (for received messages)
@property (nonatomic, retain) UIImageView *ImageView;

@property (nonatomic, retain) UIImageView *logoView;

// Cache the background images and stretchable insets
@property (retain, nonatomic) UIImage *balloonImageLeft;
@property (retain, nonatomic) UIImage *balloonImageRight;
@property (assign, nonatomic) UIEdgeInsets balloonInsets;


@property (weak, nonatomic) XMPPMessageArchiving_Message_CoreDataObject *message;


@end



@implementation ImageView


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor=[UIColor clearColor];
        self.backgroundColor=[UIColor clearColor];
        
        // Initialization the views
        _balloonView = [UIImageView new];
        
        
        self.logoView=[[UIImageView alloc] init];
        self.logoView.frame=CGRectMake(0, 0, LOGOWIDTH, LOGOWIDTH);
        
        self.ImageView=[[UIImageView alloc] init];
        
        self.balloonImageLeft = [UIImage imageNamed:@"chat_recive_nor.png"];
        self.balloonImageRight = [UIImage imageNamed:@"chat_send_nor.png"];
        
        _balloonInsets = UIEdgeInsetsMake(BALLOON_INSET_Y, BALLOON_INSET_X, BALLOON_INSET_Y, BALLOON_INSET_X);
        
        // Add to parent view
        [self addSubview:_balloonView];
        [_balloonView addSubview:self.ImageView];
        [self addSubview:self.logoView];
        
//        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(paly)];
//        [_balloonView addGestureRecognizer:tap];
//        _balloonView.userInteractionEnabled=YES;
    }
    return self;
}


// Method for setting the transcript object which is used to build this view instance.
- (void)setData:(XMPPMessageArchiving_Message_CoreDataObject *)message photo:(UIImage *)photo
{
    self.message=message;
    
    // Compute message size and frames
    CGSize balloonSize = [ImageView balloonSizeForLabelSize:CGSizeZero];
    
    NSData *data = [[NSData alloc] initWithBase64Encoding:[message.body substringFromIndex:5]];
    UIImage* image=[UIImage imageWithData:data];
    
    if (message.isOutgoing) {
        // Sent messages appear or right of view
        CGFloat xOffsetBalloon = self.frame.size.width - balloonSize.width-self.logoView.frame.size.width-10;
        
        self.logoView.image=photo;
        self.logoView.frame=CGRectMake(self.frame.size.width -self.logoView.frame.size.width-10, 10, LOGOWIDTH, LOGOWIDTH);
        

        // Set resizeable image
        _balloonView.image = [self.balloonImageRight resizableImageWithCapInsets:_balloonInsets];
        _balloonView.frame = CGRectMake(xOffsetBalloon, 0, balloonSize.width, balloonSize.height);
        
        _ImageView.frame=CGRectMake(BALLOON_INSET_X/2, BALLOON_INSET_Y/2, _balloonView.frame.size.width-BALLOON_INSET_X, _balloonView.frame.size.height-BALLOON_INSET_Y);
        _ImageView.image=image;
        _ImageView.layer.cornerRadius=BALLOON_INSET_Y/2;
        _ImageView.layer.masksToBounds=YES;
    }
    else {
        // Received messages appear on left of view with additional display name label
        
        self.logoView.image=photo;
        self.logoView.frame=CGRectMake(10, 10, LOGOWIDTH, LOGOWIDTH);
    
        
        // Set resizeable image
        _balloonView.image = [self.balloonImageLeft resizableImageWithCapInsets:_balloonInsets];
        _balloonView.frame = CGRectMake(LOGOWIDTH+10, 0, balloonSize.width, balloonSize.height);
        
        _ImageView.frame=CGRectMake(BALLOON_INSET_X/2, BALLOON_INSET_Y/2, _balloonView.frame.size.width-BALLOON_INSET_X, _balloonView.frame.size.height-BALLOON_INSET_Y);
        _ImageView.image=image;
        _ImageView.layer.cornerRadius=BALLOON_INSET_Y/2;
        _ImageView.layer.masksToBounds=YES;

    }
}



#pragma - class methods for computing sizes based on strings

+ (CGFloat)viewHeightForTranscript:(XMPPMessageArchiving_Message_CoreDataObject *)transcript
{
    CGFloat height = BALLOON_INSET_Y+ BALLOON_Y_PANDING*2 +5;
    return height;
}


+ (CGSize)balloonSizeForLabelSize:(CGSize)labelSize
{
    return CGSizeMake(150, BALLOON_INSET_Y+BALLOON_Y_PANDING*2);
}






@end

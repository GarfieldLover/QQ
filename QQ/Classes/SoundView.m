//
//  SoundView.m
//  QQ
//
//  Created by zhangke on 15/4/3.
//  Copyright (c) 2015年 zhangke. All rights reserved.
//

#import "SoundView.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import <AVFoundation/AVFoundation.h>

// Constants for view sizing and alignment
#define MESSAGE_FONT_SIZE       (13.0)
#define BUFFER_WHITE_SPACE      (14.0)
#define DETAIL_TEXT_LABEL_WIDTH (200.0)

#define BALLOON_INSET_Y   22
#define BALLOON_INSET_X   24

#define BALLOON_Y_PANDING (22-4)

#define BALLOON_EDGE_CENTERY   4

#define LOGOWIDTH   35



@interface SoundView ()

// Background image
@property (nonatomic, retain) UIImageView *balloonView;
// Message text string
@property (nonatomic, retain) UILabel *soundLengthLabel;
// Name text (for received messages)
@property (nonatomic, retain) UIImageView *soundView;

@property (nonatomic, retain) UIImageView *logoView;

// Cache the background images and stretchable insets
@property (retain, nonatomic) UIImage *balloonImageLeft;
@property (retain, nonatomic) UIImage *balloonImageRight;
@property (assign, nonatomic) UIEdgeInsets balloonInsets;

@property (strong, nonatomic) AVAudioPlayer *avPlay;

@property (weak, nonatomic) XMPPMessageArchiving_Message_CoreDataObject *message;

@end



@implementation SoundView


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor=[UIColor clearColor];
        self.backgroundColor=[UIColor clearColor];
        
        // Initialization the views
        _balloonView = [UIImageView new];
        
        _soundLengthLabel = [UILabel new];
        _soundLengthLabel.font=[UIFont systemFontOfSize:MESSAGE_FONT_SIZE];
        _soundLengthLabel.textAlignment=NSTextAlignmentCenter;
        
        self.logoView=[[UIImageView alloc] init];
        self.logoView.frame=CGRectMake(0, 0, LOGOWIDTH, LOGOWIDTH);
        
        self.soundView=[[UIImageView alloc] init];
        
        
        self.balloonImageLeft = [UIImage imageNamed:@"chat_recive_nor.png"];
        self.balloonImageRight = [UIImage imageNamed:@"chat_send_nor.png"];
        
        _balloonInsets = UIEdgeInsetsMake(BALLOON_INSET_Y, BALLOON_INSET_X, BALLOON_INSET_Y, BALLOON_INSET_X);
        
        // Add to parent view
        [self addSubview:_balloonView];
        [_balloonView addSubview:_soundLengthLabel];
        [_balloonView addSubview:self.soundView];
        [self addSubview:self.logoView];
        
        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(paly)];
        [_balloonView addGestureRecognizer:tap];
        _balloonView.userInteractionEnabled=YES;
    }
    return self;
}

-(void)paly
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&err];
    
    if (self.avPlay.playing) {
        [self.avPlay stop];
        return;
    }
    
    NSData *sound = [[NSData alloc] initWithBase64Encoding:self.message.body];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:sound error:nil];
    self.avPlay = player;
    [self.avPlay play];
    
    self.avPlay.volume=1.0;
}


// Method for setting the transcript object which is used to build this view instance.
- (void)setData:(XMPPMessageArchiving_Message_CoreDataObject *)message photo:(UIImage *)photo
{
    self.message=message;
    
    // Compute message size and frames
    CGSize balloonSize = [SoundView balloonSizeForLabelSize:CGSizeZero];
    
    NSData *sound = [[NSData alloc] initWithBase64Encoding:message.body];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:sound error:nil];
    _soundLengthLabel.text = [NSString stringWithFormat:@"%d''",(NSInteger)player.duration];

    
    if (message.isOutgoing) {
        // Sent messages appear or right of view
        CGFloat xOffsetBalloon = self.frame.size.width - balloonSize.width-self.logoView.frame.size.width-10;
        
        self.logoView.image=photo;
        self.logoView.frame=CGRectMake(self.frame.size.width -self.logoView.frame.size.width-10, 10, LOGOWIDTH, LOGOWIDTH);
        
        // Set text color
        _soundLengthLabel.textColor = [UIColor whiteColor];
        _soundLengthLabel.frame=CGRectMake((balloonSize.width-30)/2, BALLOON_Y_PANDING, 30, BALLOON_INSET_Y);

        UIImage* image=[UIImage imageNamed:@"voice_send_icon_nor.png"];
        _soundView.frame=CGRectMake(CGRectGetMaxX(_soundLengthLabel.frame), BALLOON_Y_PANDING, image.size.width, image.size.height);
        _soundView.image=image;
        
        // Set resizeable image
        _balloonView.image = [self.balloonImageRight resizableImageWithCapInsets:_balloonInsets];
        _balloonView.frame = CGRectMake(xOffsetBalloon, 0, balloonSize.width, balloonSize.height);
    }
    else {
        // Received messages appear on left of view with additional display name label
        
        self.logoView.image=photo;
        self.logoView.frame=CGRectMake(10, 10, LOGOWIDTH, LOGOWIDTH);
        
        // Set text color
        _soundLengthLabel.textColor = [UIColor darkTextColor];
        _soundLengthLabel.frame=CGRectMake(BALLOON_INSET_X, BALLOON_Y_PANDING, 40, BALLOON_INSET_Y);
        
        UIImage* image=[UIImage imageNamed:@"voice_receive_icon_nor.png"];
        _soundView.frame=CGRectMake(BALLOON_INSET_X, BALLOON_Y_PANDING, image.size.width, image.size.height);
        _soundView.image=image;
        
        // Set resizeable image
        _balloonView.image = [self.balloonImageLeft resizableImageWithCapInsets:_balloonInsets];
        _balloonView.frame = CGRectMake(LOGOWIDTH+10, 0, balloonSize.width, balloonSize.height);
        
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
    return CGSizeMake(120, BALLOON_INSET_Y+BALLOON_Y_PANDING*2);
}



@end







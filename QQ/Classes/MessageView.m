/*
     File: MessageView.m
 Abstract: 
    This is a content view class for managing the 'text message' type table view cells
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */


#import "MessageView.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"

// Constants for view sizing and alignment
#define MESSAGE_FONT_SIZE       (16.0)
#define BUFFER_WHITE_SPACE      (14.0)
#define DETAIL_TEXT_LABEL_WIDTH (200.0)

#define BALLOON_INSET_Y   22
#define BALLOON_INSET_X   24

#define BALLOON_Y_PANDING (22-4)

#define BALLOON_EDGE_CENTERY   4

#define LOGOWIDTH   35

@interface MessageView ()

// Background image
@property (nonatomic, retain) UIImageView *balloonView;
// Message text string
@property (nonatomic, retain) UILabel *messageLabel;
// Name text (for received messages)

@property (nonatomic, retain) UIImageView *logoView;

// Cache the background images and stretchable insets
@property (retain, nonatomic) UIImage *balloonImageLeft;
@property (retain, nonatomic) UIImage *balloonImageRight;
@property (assign, nonatomic) UIEdgeInsets balloonInsets;

@end



@implementation MessageView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor=[UIColor clearColor];
        self.backgroundColor=[UIColor clearColor];
        
        // Initialization the views
        _balloonView = [UIImageView new];
        _messageLabel = [UILabel new];
        _messageLabel.numberOfLines = 0;
        _messageLabel.font=[UIFont systemFontOfSize:MESSAGE_FONT_SIZE];
        
        self.logoView=[[UIImageView alloc] init];
        self.logoView.frame=CGRectMake(0, 0, LOGOWIDTH, LOGOWIDTH);
        
        self.balloonImageLeft = [UIImage imageNamed:@"chat_recive_nor.png"];
        self.balloonImageRight = [UIImage imageNamed:@"chat_send_nor.png"];

        _balloonInsets = UIEdgeInsetsMake(BALLOON_INSET_Y, BALLOON_INSET_X, BALLOON_INSET_Y, BALLOON_INSET_X);

        // Add to parent view
        [self addSubview:_balloonView];
        [_balloonView addSubview:_messageLabel];
        [self addSubview:self.logoView];
    }
    return self;
}

// Method for setting the transcript object which is used to build this view instance.
- (void)setData:(XMPPMessageArchiving_Message_CoreDataObject *)message photo:(UIImage *)photo
{
    // Set the message text
    NSString *messageText = message.body;
    _messageLabel.text = messageText;

    // Compute message size and frames
    CGSize labelSize = [MessageView labelSizeForString:messageText fontSize:MESSAGE_FONT_SIZE];
    CGSize balloonSize = [MessageView balloonSizeForLabelSize:labelSize];

    
    if (message.isOutgoing) {
        // Sent messages appear or right of view
        CGFloat xOffsetBalloon = self.frame.size.width - balloonSize.width-self.logoView.frame.size.width-10;
        
        self.logoView.image=photo;
        self.logoView.frame=CGRectMake(self.frame.size.width -self.logoView.frame.size.width-10, 10, LOGOWIDTH, LOGOWIDTH);
        
        // Set text color
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.frame=CGRectMake(BALLOON_INSET_X, BALLOON_Y_PANDING, labelSize.width, labelSize.height);

        // Set resizeable image
        _balloonView.image = [self.balloonImageRight resizableImageWithCapInsets:_balloonInsets];
        _balloonView.frame = CGRectMake(xOffsetBalloon, 0, balloonSize.width, balloonSize.height);
    }
    else {
        // Received messages appear on left of view with additional display name label
        
        self.logoView.image=photo;
        self.logoView.frame=CGRectMake(10, 10, LOGOWIDTH, LOGOWIDTH);
        
        // Set text color
        _messageLabel.textColor = [UIColor darkTextColor];
        _messageLabel.frame=CGRectMake(BALLOON_INSET_X, BALLOON_Y_PANDING, labelSize.width, labelSize.height);

        // Set resizeable image
        _balloonView.image = [self.balloonImageLeft resizableImageWithCapInsets:_balloonInsets];
        _balloonView.frame = CGRectMake(LOGOWIDTH+10, 0, balloonSize.width, balloonSize.height);

    }
}

#pragma - class methods for computing sizes based on strings

+ (CGFloat)viewHeightForTranscript:(XMPPMessageArchiving_Message_CoreDataObject *)transcript
{
    CGFloat height = [MessageView balloonSizeForLabelSize:[MessageView labelSizeForString:transcript.body fontSize:MESSAGE_FONT_SIZE]].height+5;
    return height;
}

+ (CGSize)labelSizeForString:(NSString *)string fontSize:(CGFloat)fontSize
{
    return [string boundingRectWithSize:CGSizeMake(DETAIL_TEXT_LABEL_WIDTH, 2000.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil].size;
}

+ (CGSize)balloonSizeForLabelSize:(CGSize)labelSize
{
 	CGSize balloonSize;

    if (labelSize.height < BALLOON_EDGE_CENTERY) {
        balloonSize.height = BALLOON_EDGE_CENTERY+BALLOON_Y_PANDING*2;
    }
    else {
        balloonSize.height = labelSize.height + BALLOON_Y_PANDING*2;
    }

    balloonSize.width = labelSize.width + BALLOON_INSET_X*2;

    return balloonSize;
}

@end

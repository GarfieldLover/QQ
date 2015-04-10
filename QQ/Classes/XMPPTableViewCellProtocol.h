//
//  XMPPTableViewCellProtocol.h
//  QQ
//
//  Created by zhangke on 15/4/8.
//  Copyright (c) 2015年 zhangke. All rights reserved.
//

#ifndef QQ_XMPPTableViewCellProtocol_h
#define QQ_XMPPTableViewCellProtocol_h


@class XMPPMessageArchiving_Message_CoreDataObject;
@class XMPPUserCoreDataStorageObject;


 @protocol XMPPTableViewCellProtocol <NSObject>

@optional

// Class method for computing a view height based on a given message transcript

- (void)setData:(XMPPMessageArchiving_Message_CoreDataObject *)message photo:(UIImage*)photo;



@end



#endif

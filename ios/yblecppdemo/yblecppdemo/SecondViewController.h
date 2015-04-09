//
//  SecondViewController.h
//  yble_cpp
//
//  Created by YANG HONGBO on 2015-4-10.
//  Copyright (c) 2015年 Yang.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "yble_cpp.h"

using namespace Yble;
@interface SecondViewController : UITableViewController
@property (nonatomic, assign, readwrite)  CPeripheral *peripheral;
@end

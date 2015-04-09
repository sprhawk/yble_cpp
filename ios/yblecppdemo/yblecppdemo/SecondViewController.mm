//
//  SecondViewController.m
//  yble_cpp
//
//  Created by YANG HONGBO on 2015-4-10.
//  Copyright (c) 2015年 Yang.me. All rights reserved.
//

#import "SecondViewController.h"

class CDelegate2 :public CPeripheralDelegate
{
public:
    CDelegate2(SecondViewController *r);
    
public:
    virtual void peripheralDidUpdateState(const CPeripheral *peripheral, PeripheralState state);
    virtual void peripheralDidUpdateRSSI(const CPeripheral *peripheral ,int16_t rssi);
    virtual void peripheralDidDiscoverService(const CPeripheral *peripheral, const CService *service);
    virtual void peripheralDidUpdateValue(const CPeripheral *peripheral, const CCharacteristic *characteristic, const void *value, const size_t size);
    virtual void peripheralDidWriteValue(const CPeripheral *peripheral, const CCharacteristic *characteristic, const void *value, const size_t size);
    virtual void peripheralDidUpdateNotificationState(const CPeripheral *peripheral, const CCharacteristic *characteristic, const bool isNotifying);
    
private:
    SecondViewController *m_root;
};


@interface SecondViewController ()
{
    CDelegate2 *_delegate;
}
@end

CDelegate2::CDelegate2(SecondViewController *r)
{
    m_root = r;
}

void CDelegate2::peripheralDidUpdateState(const CPeripheral *peripheral, PeripheralState state)
{
    NSLog(@"peripheral state:%d", (int)state);
}
void CDelegate2::peripheralDidUpdateRSSI(const CPeripheral *peripheral ,int16_t rssi)
{
    
}
void CDelegate2::peripheralDidDiscoverService(const CPeripheral *peripheral, const CService *service)
{
    
}
void CDelegate2::peripheralDidUpdateValue(const CPeripheral *peripheral, const CCharacteristic *characteristic, const void *value, const size_t size)
{
    
}
void CDelegate2::peripheralDidWriteValue(const CPeripheral *peripheral, const CCharacteristic *characteristic, const void *value, const size_t size)
{
    
}
void CDelegate2::peripheralDidUpdateNotificationState(const CPeripheral *peripheral, const CCharacteristic *characteristic, const bool isNotifying)
{
    
}



@implementation SecondViewController

- (void)awakeFromNib
{
    
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _delegate = new CDelegate2(self);
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"connecting ...");
    self.peripheral->setDelegate(_delegate);
    self.peripheral->connect();
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.peripheral->disconnect();
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    return cell;
}

@end

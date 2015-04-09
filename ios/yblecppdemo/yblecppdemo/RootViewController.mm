//
//  RootViewController.m
//  test_yble_cpp
//
//  Created by YANG HONGBO on 2015-4-9.
//  Copyright (c) 2015年 Yang.me. All rights reserved.
//

#import "RootViewController.h"
#import "SecondViewController.h"

#include <vector>
#include <string>

#include "yble_cpp.h"

using namespace Yble;

using namespace std;

class CDelegate :public CCentralDelegate
{
public:
    CDelegate(RootViewController *r);
    
public:
    virtual void centralDidUpdateState(CCentral *central, CentralState state);
    virtual void centralDidDiscoverPeripheral(CCentral *central, CPeripheral *peripheral);
    
private:
    RootViewController *m_root;
};

@interface RootViewController ()
{
    CDelegate *_delegate;
    vector<CPeripheral *> _peripherals;
}
@property (nonatomic, assign, readwrite) Yble::CCentral *yble;
- (void)addPeripheral:(CPeripheral *)peripheral;
@end

CDelegate::CDelegate(RootViewController *r)
{
    m_root = r;
}

void CDelegate::centralDidUpdateState(CCentral *central, CentralState state)
{
    if (CentralStatePoweredOn == state) {
        NSLog(@"start scanning");
        m_root.yble->startScan(NULL, 0);
    }
    else {
        NSLog(@"central state:%d", (int)state);
    }
}

void CDelegate::centralDidDiscoverPeripheral(CCentral *central, CPeripheral *peripheral)
{
    [m_root addPeripheral:peripheral];
}

@implementation RootViewController

- (void)awakeFromNib
{
    _delegate = new CDelegate(self);
    self.yble = CreateYbleCentral(_delegate);
}

- (void)addPeripheral:(Yble::CPeripheral *)peripheral
{
    _peripherals.push_back(peripheral);
    NSLog(@"0x%lx(%s)", (unsigned long)peripheral, peripheral->getName().c_str());
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_peripherals.size()-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _peripherals.size();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    CPeripheral *p = _peripherals.at(indexPath.row);
    cell.textLabel.text = [NSString stringWithUTF8String:p->getName().c_str()];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPeripheral *p = _peripherals.at(indexPath.row);
    SecondViewController *s = [[SecondViewController alloc] initWithStyle:UITableViewStylePlain];
    s.peripheral = p;
    [self.navigationController pushViewController:s animated:YES];
}
@end

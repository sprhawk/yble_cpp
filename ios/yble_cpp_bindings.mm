//
//    Copyright (c) 2015 YANG HONGBO
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

#import <Foundation/Foundation.h>

#include "yble_cpp.h"
#import "yble.h"

#include <map>
#include <string>
#include <vector>
using namespace Yble;

class CCentralObjc;
class CPeripheralObjc;

class CCentralObjc :public CCentral {
public:
    CCentralObjc();
    CCentralObjc(const CCentralDelegate *delegate);
    virtual ~CCentralObjc();

public:
    virtual bool isAvailable() const;
    virtual void startScan(const vector<string> *services, unsigned int options);
    virtual void stopScan();
    
    virtual CentralState getState(void) const;
    
protected:
    virtual void stateUpdate(YBleState state);
    static CentralState cStateFromObjcState(YBleState state);

protected:
    
private:
    YBleCentral *m_central;
    
    map<string, CPeripheralObjc*> m_peripherals;
};

class CAdvertisementObjc :public CAdvertisement {
public:
    CAdvertisementObjc(AdvertisementType type, void *data, size_t size);
    virtual ~CAdvertisementObjc();
    
    const AdvertisementType getType();
    const size_t getSize();
    void update(AdvertisementType type, const void *data, const size_t size);

protected:
    AdvertisementType m_type;
    size_t m_size;
    void *m_data;
};

class CPeripheralObjc :public CPeripheral {
public:
    CPeripheralObjc(YBlePeripheral *peripheral);
    ~CPeripheralObjc();
    
public:
    virtual map<string, CAdvertisement* > getAdvertisements() const;
    virtual int16_t getAdvRSSI() const;
    virtual void readRSSI();
    virtual PeripheralState getState(void) const;
    
    virtual string getIdentifier(void) const;
    virtual string getName() const;
    
    virtual void connect();
    virtual void disconnect();
    
    virtual void discoverServices(const vector<CService *> *services);
    
    virtual void readCharacteristic(const CCharacteristic *characteristic);
    virtual void setCharacteristicNotifying(const CCharacteristic *characteristic, bool notifying);
    virtual void writeCharacteristic(const CCharacteristic *characteristic, const void *data, uint32_t length);
    
    virtual vector<string> getAdvertisementKeys() const;
    virtual CAdvertisement* getAdvertisementByKey(const string& key) const;
    
protected:
    virtual void setName(const string &name);
    
    static PeripheralState cStateFromObjcState(YBlePeripheralState state);
    
private:
    YBlePeripheral *m_peripheral;
    string m_identifier;
    map<string, CService *> m_services;
    map<string, CAdvertisement *> m_advertisements;
    string m_name;
};

class CServiceObjc :public CService
{
public:
    CServiceObjc(YBleService *service);
    virtual ~CServiceObjc();
private:

};

class CCharacteristicObjc :public CCharacteristic
{
public:
    CCharacteristicObjc(YBleCharacteristic *characteristic);
    virtual ~CCharacteristicObjc();
    virtual unsigned long getProperties(void) const;
    
public:
    const YBleCharacteristic *getYbleCharacteristic(void) const;

protected:
private:
    YBleCharacteristic *m_characteristic;
};

//---------------------------------------------
// CYbleObjc

// public
CCentralObjc::CCentralObjc()
:m_central(NULL)
{
    m_central = [[YBleCentral alloc] initInMainQueueWithStateCallback:^(YBleState state) {
        this->stateUpdate(state);
    } restoreIdentifier:nil];
}

CCentralObjc::CCentralObjc(const CCentralDelegate *delegate)
:CCentralObjc()
{
    this->setDelegate(delegate);
}

CCentralObjc::~CCentralObjc()
{
    m_central = nil;
}

bool CCentralObjc::isAvailable() const
{
    return m_central.isAvailable;
}

CentralState CCentralObjc::cStateFromObjcState(YBleState state)
{
    CentralState cstate;
    switch (state) {
        case YBleStatePoweredOn:
            cstate = CentralStatePoweredOn;
            break;
        case YBleStatePoweredOff:
            cstate = CentralStatePoweredOff;
            break;
        case YBleStateResetting:
            cstate = CentralStateResetting;
            break;
        case YBleStateUnauthorized:
            cstate = CentralStateUnauthorized;
            break;
        case YBleStateUnsupported:
            cstate = CentralStateUnsupported;
            break;
        case YBleStateUnknown:
        default:
            cstate = CentralStateUnknown;
            break;
    }
    return cstate;
}

void CCentralObjc::stateUpdate(YBleState state)
{
    if (m_delegate) {
        CentralState s = CCentralObjc::cStateFromObjcState(state);
        m_delegate->centralDidUpdateState(this, s);
    }
}

CentralState CCentralObjc::getState() const
{
    CentralState cstate = this->cStateFromObjcState(m_central.state);
    return cstate;
}

void CCentralObjc::startScan(const vector<string> *services, unsigned int options)
{
    NSMutableArray *array = nil;
    if (services && services->size()) {
        array = [NSMutableArray arrayWithCapacity:services->size()];
        
        for (vector<string>::const_iterator i = services->begin(); i != services->end(); i ++) {
            const string &s = *i;
            const char *c = s.c_str();
            NSString *srv = [NSString stringWithCString:c encoding:NSUTF8StringEncoding];
            [array addObject:srv];
        }
    }
    
    NSMutableDictionary *scanOptions = nil;
    if (!options) {
        scanOptions = [NSMutableDictionary dictionary];
    }
    
    [m_central scanForServices:array
                       options:scanOptions
                      callback:^(YBlePeripheral *peripheral) {
                          CPeripheralObjc *p = new CPeripheralObjc(peripheral);
                          string key = p->getIdentifier();
                          m_peripherals[key] = p;
                          if (m_delegate) {
                              m_delegate->centralDidDiscoverPeripheral(this, p);
                          }
                      }];
}

void CCentralObjc::stopScan()
{
    [m_central stopScan];
}

//---------------------------------------------
// CYblePeripheralObjc
CPeripheralObjc::CPeripheralObjc(YBlePeripheral *peripheral)
:m_peripheral(peripheral)
,m_identifier(peripheral.uuid.UUIDString.UTF8String)
{
    this->setName(peripheral.name.UTF8String);
    [m_peripheral setNameUpdateBlock:^(NSString *name){
        this->setName(name.UTF8String);
    }];
    [m_peripheral setStateUpdateBlock:^(YBlePeripheralState state, NSError *error) {
        if (this->getDelegate()) {
            PeripheralState s = cStateFromObjcState(state);
            this->getDelegate()->peripheralDidUpdateState(this, s);
        }
    }];
}

CPeripheralObjc::~CPeripheralObjc()
{
    map<string, CService *>::iterator i;
    for (i = m_services.begin(); i != m_services.end(); i ++) {
        delete i->second;
        m_services.erase(i);
    }
}

string CPeripheralObjc::getIdentifier() const
{
    return m_identifier;
}

string CPeripheralObjc::getName() const
{
    return m_name;
}

void CPeripheralObjc::setName(const string &name)
{
    m_name = name;
}

map<string, CAdvertisement *> CPeripheralObjc::getAdvertisements() const
{
    assert(m_peripheral);
    map<string, CAdvertisement *> adv;
    for (NSString *key in m_peripheral.advertisementData) {
        id value = m_peripheral.advertisementData[key];
        string k = key.UTF8String;
        if ([value isKindOfClass:[NSString class]]) {
            string *s = NULL;
//            string *s = new string([(NSString *)value UTF8String]);
            adv[k] = reinterpret_cast<CAdvertisement *>(s); // NULL is only a placeholder
        }
        else {
            adv[k] = NULL; // NULL is only a placeholder
        }
        
    }
    return adv;
}

vector<string> CPeripheralObjc::getAdvertisementKeys() const
{
    vector<string> m;
    return m;
}
CAdvertisement* CPeripheralObjc::getAdvertisementByKey(const string& key) const
{
    return NULL;
}

int16_t CPeripheralObjc::getAdvRSSI() const
{
    assert(m_peripheral);
    return m_peripheral.rssi.integerValue;
}

void CPeripheralObjc::readRSSI()
{
    assert(m_peripheral);
    [m_peripheral readRssiCallback:^(NSNumber *rssi, NSError *error) {
        if (!error) {
            if (m_delegate) {
                m_delegate->peripheralDidUpdateRSSI(this, rssi.integerValue);
            }
        }
    }];
}

PeripheralState CPeripheralObjc::cStateFromObjcState(YBlePeripheralState state)
{
    PeripheralState cstate;
    switch (state) {
        case YBlePeripheralStateConnected:
            cstate = PeripheralStateConnected;
            break;
        case YBlePeripheralStateConnecting:
            cstate = PeripheralStateConnecting;
            break;
        case YBlePeripheralStateDisconnecting:
            cstate = PeripheralStateDisconnecting;
            break;
        case YBlePeripheralStateIdle:
        default:
            cstate = PeripheralStateIdle;
            break;
    }
    return cstate;
}

PeripheralState CPeripheralObjc::getState(void) const
{
    assert(m_peripheral);
    PeripheralState cstate = this->cStateFromObjcState(m_peripheral.state);
    return cstate;
}

void CPeripheralObjc::connect()
{
    assert(m_peripheral);
    [m_peripheral connect];
}

void CPeripheralObjc::disconnect()
{
    assert(m_peripheral);
    [m_peripheral disconnect];
}

void CPeripheralObjc::discoverServices(const vector<CService *> *services)
{
    assert(m_peripheral);
    assert(services);
    NSMutableArray *servicesObjc = nil;
    if (services->size()) {
        servicesObjc = [NSMutableArray arrayWithCapacity:services->size()];
        vector<CService *>::const_iterator i;
        for (i = services->begin(); i != services->end(); i ++) {
            CService *srv = *i;
            string uuid = srv->getUUID();
            CBUUID *UUID = [CBUUID UUIDWithString:[NSString stringWithUTF8String:uuid.c_str()]];
            YBleService *s = [[YBleService alloc] initWithUUID:UUID];
            
            [servicesObjc addObject:s];
        }
    }
    [m_peripheral discoverServices:servicesObjc
                        discovered:^(YBleService *service, NSError *error) {
                            if (m_delegate) {
                                CServiceObjc *srv = new CServiceObjc(service);
                                string uuid = srv->getUUID();
                                m_services[uuid] = srv;
                                m_delegate->peripheralDidDiscoverService(this, srv);
                            }
                        }];
}

void CPeripheralObjc::readCharacteristic(const CCharacteristic *characteristic)
{
    const CCharacteristicObjc *c = dynamic_cast<const CCharacteristicObjc *>(characteristic);
    assert(c);
    const YBleCharacteristic * yc = c->getYbleCharacteristic();
    [m_peripheral readCharacteristic:const_cast<YBleCharacteristic *>(yc)];
}

void CPeripheralObjc::setCharacteristicNotifying(const CCharacteristic *characteristic, bool notifying)
{
    const CCharacteristicObjc *c = dynamic_cast<const CCharacteristicObjc *>(characteristic);
    assert(c);
    assert(m_peripheral);
    const YBleCharacteristic * yc = c->getYbleCharacteristic();
    [m_peripheral setCharacteristic:const_cast<YBleCharacteristic *>(yc)
                          notifying:notifying
                      stateCallback:^(BOOL notifying, NSError *error) {
                          if (m_delegate) {
                              m_delegate->peripheralDidUpdateNotificationState(this, characteristic, notifying);
                          }
                      }];
}

void CPeripheralObjc::writeCharacteristic(const CCharacteristic *characteristic, const void *data, uint32_t length)
{
    const CCharacteristicObjc *c = dynamic_cast<const CCharacteristicObjc *>(characteristic);
    assert(c);
    assert(m_peripheral);
    assert(data);
    assert(length > 0);
    void (^block)(NSData *data, NSError *error) = NULL;
    
    NSData *value = [NSData dataWithBytes:data length:length];
    const YBleCharacteristic * yc = c->getYbleCharacteristic();
    [m_peripheral writeCharacteristic:const_cast<YBleCharacteristic *>(yc)
                                value:value
                             callback:block];
}

CServiceObjc::CServiceObjc(YBleService *service)
:CService(service.uuid.UUIDString.UTF8String)
{
    assert(service);
    for (YBleCharacteristic *c in service.characteristics) {
        CCharacteristicObjc *ch = new CCharacteristicObjc(c);
        this->addCharacteristic(ch);
    }
}

CServiceObjc::~CServiceObjc()
{
}

CCharacteristicObjc::CCharacteristicObjc(YBleCharacteristic *characteristic)
:CCharacteristic(characteristic.uuid.UUIDString.UTF8String)
{
    assert(characteristic);
    m_characteristic = characteristic;
}

CCharacteristicObjc::~CCharacteristicObjc()
{
    
}

unsigned long CCharacteristicObjc::getProperties(void) const
{
    assert(m_characteristic);
    return m_characteristic.properties;
}

const YBleCharacteristic *CCharacteristicObjc::getYbleCharacteristic() const
{
    assert(m_characteristic);
    return m_characteristic;
}

extern "C"
CCentral *CreateYbleCentral(const CCentralDelegate *delegate)
{
    CCentralObjc *yble = new CCentralObjc(delegate);
    return yble;
}


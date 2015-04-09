//
//  yble_cpp.h
//  yble_cpp
//
//  Created by YANG HONGBO on 2015-4-3.
//  Copyright (c) 2015年 Yang.me. All rights reserved.
//

#ifndef __yble_cpp__yble_cpp__
#define __yble_cpp__yble_cpp__

#include <string>
#include <vector>
#include <map>

using namespace std;

namespace Yble {

    class CCentral;
    class CCentralDelegate;
    class CPeripheral;
    class CPeripheralDelegate;
    
    typedef enum CentralState {
        CentralStateUnknown,
        CentralStatePoweredOff,
        CentralStatePoweredOn,
        CentralStateUnauthorized,
        CentralStateUnsupported,
        CentralStateResetting,
    }CentralState;
    
    class CCentral {
    public:
        
        CCentral();
        CCentral(const CCentralDelegate *delegate);
        virtual ~CCentral();
        
        virtual bool isAvailable() const = 0;
        virtual void startScan(const vector<string> *services, unsigned int options) = 0;
        virtual void stopScan() = 0;
        
        virtual CentralState getState(void) const = 0;
        void setDelegate(const CCentralDelegate *delegate) { m_delegate = const_cast<CCentralDelegate *>(delegate); };
    protected:
        CCentralDelegate *m_delegate;
    };
    
    class CCentralDelegate {
    public:
        virtual void centralDidUpdateState(CCentral *central, CentralState state) = 0;
        virtual void centralDidDiscoverPeripheral(CCentral *central, CPeripheral *peripheral) = 0;
    };
    
    class CService;
    class CCharacteristic;

    typedef enum AdvertisementType {
        AdvertisementTypeRaw,
        AdvertisementTypeString,
    }AdvertisementType;
    
    class CAdvertisement {
    public:
        virtual const AdvertisementType getType() = 0;
        virtual const size_t getSize() = 0;
        
    };
    
    typedef enum PeripheralState {
        PeripheralStateIdle = 0,
        PeripheralStateConnecting,
        PeripheralStateConnected,
        PeripheralStateDisconnecting,
    }PeripheralState;
    
    class CPeripheral {
    public:

        CPeripheral();
        virtual ~CPeripheral();
        
        virtual int16_t getAdvRSSI() const = 0;
        virtual void readRSSI() = 0;
        virtual PeripheralState getState(void) const = 0;
        virtual string getIdentifier(void) const = 0;
        virtual string getName() const = 0;
        
        void setDelegate(CPeripheralDelegate *delegate) { m_delegate = delegate; };
        CPeripheralDelegate *getDelegate(void) const { return m_delegate; };
        
        virtual void connect() = 0;
        virtual void disconnect() = 0;
        
        virtual void discoverServices(const vector<CService *> *services) = 0;
        
        virtual void readCharacteristic(const CCharacteristic *characteristic) = 0;
        virtual void setCharacteristicNotifying(const CCharacteristic *characteristic, bool notifying) = 0;
        virtual void writeCharacteristic(const CCharacteristic *characteristic, const void *data, uint32_t length)= 0;
        
        virtual map<string, CAdvertisement *> getAdvertisements() const = 0;
        virtual vector<string> getAdvertisementKeys() const = 0;
        virtual CAdvertisement* getAdvertisementByKey(const string& key) const = 0;
        
    protected:
        virtual void setName(const string &name) = 0;
        
    protected:
        CPeripheralDelegate *m_delegate;
    };
    
    class CPeripheralDelegate {
    public:
        virtual void peripheralDidUpdateState(const CPeripheral *peripheral, PeripheralState state) = 0;
        virtual void peripheralDidUpdateRSSI(const CPeripheral *peripheral ,int16_t rssi) = 0;
        virtual void peripheralDidDiscoverService(const CPeripheral *peripheral, const CService *service) = 0;
        virtual void peripheralDidUpdateValue(const CPeripheral *peripheral, const CCharacteristic *characteristic, const void *value, const size_t size) = 0;
        virtual void peripheralDidWriteValue(const CPeripheral *peripheral, const CCharacteristic *characteristic, const void *value, const size_t size) = 0;
        virtual void peripheralDidUpdateNotificationState(const CPeripheral *peripheral, const CCharacteristic *characteristic, const bool isNotifying) = 0;
    };
    
    class CService
    {
    public:
        CService(string uuid);
        virtual ~CService();
        
        string getUUID(void);
        void addCharacteristic(CCharacteristic *characteristic);
    private:
        string m_uuid;
        vector<CCharacteristic *> m_characteristics;
    };
    
    enum  {
        CharacteristicPropertyBroadcast											= 0x01,
        CharacteristicPropertyRead													= 0x02,
        CharacteristicPropertyWriteWithoutResponse									= 0x04,
        CharacteristicPropertyWrite												= 0x08,
        CharacteristicPropertyNotify												= 0x10,
        CharacteristicPropertyIndicate												= 0x20,
        CharacteristicPropertyAuthenticatedSignedWrites							= 0x40,
        CharacteristicPropertyExtendedProperties									= 0x80,
        CharacteristicPropertyNotifyEncryptionRequired                             = 0x100,
        CharacteristicPropertyIndicateEncryptionRequired                           = 0x200
    };
    
    typedef unsigned long CharacteristicProperties;
    
    class CCharacteristic
    {
    public:
        CCharacteristic(string uuid);
        virtual ~CCharacteristic();
        string getUUID(void);
        virtual unsigned long getProperties(void) const = 0;
        
    protected:
        
    private:
        string m_uuid;
    };
};

#ifdef __cplusplus
extern "C" {
#endif
    Yble::CCentral *CreateYbleCentral(const Yble::CCentralDelegate *delegate);
#ifdef __cplusplus
};
#endif


#endif /* defined(__yble_cpp__yble_cpp__) */

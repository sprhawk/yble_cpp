//
//  yble_cpp.cpp
//  yble_cpp
//
//  Created by YANG HONGBO on 2015-4-3.
//  Copyright (c) 2015年 Yang.me. All rights reserved.
//

#include "yble_cpp.h"

//--------------------------
// CYble
using namespace Yble;
CCentral::CCentral()
:m_delegate(NULL)
{
    
}

CCentral::CCentral(const CCentralDelegate *delegate)
:m_delegate(const_cast<CCentralDelegate *>(delegate))
{
    
}

CCentral::~CCentral()
{
    
}

//--------------------------
// CYblePeripheral
CPeripheral::CPeripheral()
:m_delegate(NULL)
{
    
}

CPeripheral::~CPeripheral()
{
    
}

//--------------------------
// CYbleService

CService::CService(string uuid)
:m_uuid(uuid)
{
    
}

CService::~CService()
{
    vector<CCharacteristic *>::iterator i;
    for (i = m_characteristics.begin(); i != m_characteristics.end(); i ++) {
        delete *i;
        m_characteristics.erase(i);
    }
}

string CService::getUUID()
{
    return m_uuid;
}

void CService::addCharacteristic(CCharacteristic *characteristic)
{
    m_characteristics.push_back(characteristic);
}

//--------------------------
// CYbleCharactersitc
CCharacteristic::CCharacteristic(string uuid)
:m_uuid(uuid)
{
    
}

CCharacteristic::~CCharacteristic()
{
    
}

string CCharacteristic::getUUID()
{
    return m_uuid;
}

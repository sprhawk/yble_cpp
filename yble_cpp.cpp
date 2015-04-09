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

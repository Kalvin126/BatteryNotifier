//
//  CFTypeAddition.h
//  Core
//
//  Created by Samantha Marshall on 1/12/14.
//  Copyright (c) 2014 Samantha Marshall. All rights reserved.
//

#ifndef Core_CFTypeAddition_h
#define Core_CFTypeAddition_h

#include <CoreFoundation/CoreFoundation.h>

void PrintCFType(CFTypeRef value);
CFStringRef CFTypeStringRep(CFTypeRef value);
void CFSafeRelease(CFTypeRef CF_RELEASES_ARGUMENT var);

#endif

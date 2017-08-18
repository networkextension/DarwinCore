//
//  proinfo.c
//  DarwinCore
//
//  Created by yarshure on 2017/8/18.
//  Copyright © 2017年 Kong XiangBo. All rights reserved.
//

#include "proinfo.h"
//#include <sys/param.h>
//#include <sys/proc_info.h>
#include <libproc.h>
#include <string.h>
int proPath(int ppid,char *pathBuffer) {
    // insert code here...
    
    pid_t pid = ppid;
    //char pathBuffer [PROC_PIDPATHINFO_MAXSIZE];
    proc_pidpath(pid, pathBuffer, sizeof(pathBuffer));
//    
//    char nameBuffer[256];
//    
//    size_t position = strlen((const char*)pathBuffer);
//    while(position >= 1 && pathBuffer[position] != '/')
//    {
//        position--;
//    }
//    
//    strcpy(nameBuffer, pathBuffer + position + 1);
    
//    printf("path: %s\n\nname:%s\n\n", pathBuffer, nameBuffer);
//    printf("Hello, World!\n");
    return 0;
}

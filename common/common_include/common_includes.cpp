//
// Created by khalidzhang on 2019/10/14.
//
#include "common_includes.h"

int beforeRun() {
  srand(time(NULL));
  int iRet = log_init();
  return iRet;
}
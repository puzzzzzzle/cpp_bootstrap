/************************************************
 * @author puzzzzzzle
 * @email 2359173906@qq.com
 * @desc
 * @time 2021/5/24
 * @file time_gap.hpp
 * @version
 * version        author            desc
 * 1.0            puzzzzzzle       create
 ************************************************/
#pragma once
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <iostream>
#define MICRO_NANO (1000)
#define SEC_MICRO (MICRO_NANO * 1000)
#define SEC_NANO (SEC_MICRO * 1000)
#define MICRO_MILLI (1000 * 1000)

#ifdef _WIN32
#include <Windows.h>
#include <stdint.h>  // portable: uint64_t   MSVC: __int64

int gettimeofday(struct timeval *tp, struct timezone *tzp) {
  // Note: some broken versions only have 8 trailing zero's, the correct epoch
  // has 9 trailing zero's This magic number is the number of 100 nanosecond
  // intervals since January 1, 1601 (UTC) until 00:00:00 January 1, 1970
  static const uint64_t EPOCH = ((uint64_t)116444736000000000ULL);

  SYSTEMTIME system_time;
  FILETIME file_time;
  uint64_t time;

  GetSystemTime(&system_time);
  SystemTimeToFileTime(&system_time, &file_time);
  time = ((uint64_t)file_time.dwLowDateTime);
  time += ((uint64_t)file_time.dwHighDateTime) << 32;

  tp->tv_sec = (long)((time - EPOCH) / 10000000L);
  tp->tv_usec = (long)(system_time.wMilliseconds * 1000);
  return 0;
}
#else
#include <sys/time.h>
#endif

class TimeGap {
  public:
  TimeGap() {
    if (gettimeofday(&start, nullptr)) {
      exit(-100);
    }
  }

  /**
   * 获取和开始时间相差的微秒数
   * @return 微秒数
   */
  inline long gap() {
    timeval end{};
    if (gettimeofday(&end, nullptr)) {
      return -1;
    }
    return (end.tv_sec - start.tv_sec) * 1000000 +
           (end.tv_usec - start.tv_usec);
  }

  /**
   * 获取和开始时间相差的秒数
   * @return 秒数
   */
  inline long gapSec() {
    timeval end{};
    if (gettimeofday(&end, nullptr)) {
      return -1;
    }
    return (end.tv_sec - start.tv_sec);
  }

  inline int resetStart(const timeval &_start) {
    start = _start;
    return 0;
  }

  inline int resetStartNow() { return gettimeofday(&start, nullptr); }

  private:
  timeval start{};
};
class TimeTools {
  public:
  static void SleepMicro(long microSeconds) {
    timespec req{}, rem{};
    req.tv_sec = microSeconds / SEC_MICRO;
    req.tv_nsec = (microSeconds % SEC_MICRO) * MICRO_NANO;
    int iRet{};
    do {
      iRet = nanosleep(&req, &rem);
      if (iRet) {
        std::cerr << strerror(errno) << std::endl;

        req = rem;
      }
    } while (iRet);
  }
  static void SleepNano(timespec req) {
    timespec rem{};
    int iRet{};
    do {
      iRet = nanosleep(&req, &rem);
      if (iRet) {
        std::cerr << strerror(errno) << std::endl;

        req = rem;
      }
    } while (iRet);
  }
  static void SleepNano(long nanoSeconds) {
    timespec req{}, rem{};
    req.tv_sec = nanoSeconds / SEC_NANO;
    req.tv_nsec = (nanoSeconds % SEC_NANO);
    int iRet{};
    do {
      iRet = nanosleep(&req, &rem);
      if (iRet) {
        std::cerr << strerror(errno) << std::endl;

        req = rem;
      }
    } while (iRet);
  }
  static void SleepSec(long sec) { SleepNano(sec * SEC_NANO); }
  static inline long SubTimeMicro(timespec &end, timespec &start) {
    return (end.tv_sec - start.tv_sec) * SEC_MICRO +
           (end.tv_nsec - start.tv_nsec) / MICRO_NANO;
  }
  static inline long SubTimeNano(timespec &end, timespec &start) {
    return (end.tv_sec - start.tv_sec) * SEC_NANO +
           (end.tv_nsec - start.tv_nsec);
  }
  static inline timespec SubTime(timespec &end, timespec &start) {
    return timespec{end.tv_sec - start.tv_sec, end.tv_nsec - start.tv_nsec};
  };
};
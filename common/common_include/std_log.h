/************************************************
 * @author puzzzzzzle
 * @email 2359173906@qq.com
 * @desc
 * @time 2023/1/21
 * @file std_log.h
 * @version
 * version        author            desc
 * 1.0            puzzzzzzle       create
 ************************************************/

#pragma once

#include <cerrno>
#include <cstdio>
#include <iostream>

#ifdef STD_LOG_SYNC
#include <atomic>
#include <mutex>
namespace LogInit {
inline std::mutex& get_std_log_lock() {
  static std::mutex lock{};
  return lock;
}
inline std::atomic_int& get_std_log_count() {
  static std::atomic_int count{};
  return count;
}
}  // namespace LogInit
#endif
namespace LogInit {
inline int log_init() { return 0; }
inline std::string log_now_time() {
  time_t t = time(0);
  char ch[64];
  strftime(ch, sizeof(ch), "%Y-%m-%d %H:%M:%S", localtime(&t));

  return ch;
}
}  // namespace LogInit

// log 格式定义
#define LOG_FORMAT(level, msg)                                                 \
  "[" << LogInit::get_std_log_count().fetch_add(1) << "] " << level << "    [" \
      << LogInit::log_now_time() << "]    "                                    \
      << "[" << msg << "]   [" << __FILE__ << ":" << __LINE__ << "    "        \
      << __PRETTY_FUNCTION__ << "]" << std::endl;
#ifdef STD_LOG_SYNC
#define STD_LOG_DEF(stream, level, msg)                             \
  {                                                                 \
    std::unique_lock<std::mutex> inner_log_lock(LogInit::get_std_log_lock()); \
    stream << LOG_FORMAT(level, msg)                                \
  }
#else
#define STD_LOG_DEF(stream, level, msg) stream << LOG_FORMAT(level, msg)
#endif

// 输出到不同stream的log
#define STD_LOG(level, msg) STD_LOG_DEF(std::cout, level, msg)
#define ERR_LOG(level, msg) STD_LOG_DEF(std::cerr, level, msg)

// log定义
#define LOG_TRACE(msg) STD_LOG("[TRACE]", msg)
#define LOG_DEBUG(msg) STD_LOG("[DEBUG]", msg)
#define LOG_INFO(msg) STD_LOG("[INFO]", msg)
#define LOG_WARNING(msg) ERR_LOG("[WARNING]", msg)
#define LOG_ERROR(msg) ERR_LOG("[ERROR]", msg)
   // 只是一个参考，调用errno检查错误
#define LOG_PERROR(msg) \
  ERR_LOG("[ERROR]", msg << "[ reason maybe  :  " << strerror(errno) << " ]")
#define LOG_FATAL(msg) ERR_LOG("[FATAL]", msg)

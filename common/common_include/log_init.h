/************************************************
 * @author puzzzzzzle
 * @email 2359173906@qq.com
 * @desc
 * @time 2021/5/24
 * @file log_init.h
 * @version
 * version        author            desc
 * 1.0            puzzzzzzle       create
 ************************************************/
#include <cerrno>
#include <iostream>
#include <cstdio>
#ifdef WIN32
#define __PRETTY_FUNCTION__ __FUNCSIG__
#endif
#ifdef LOG_BOOST
#include <boost/date_time/posix_time/posix_time_types.hpp>
#include <boost/log/attributes.hpp>
#include <boost/log/common.hpp>
#include <boost/log/expressions.hpp>
#include <boost/log/sinks.hpp>
#include <boost/log/sinks/text_file_backend.hpp>
#include <boost/log/sources/channel_feature.hpp>
#include <boost/log/sources/channel_logger.hpp>
#include <boost/log/sources/logger.hpp>
#include <boost/log/sources/record_ostream.hpp>
#include <boost/log/sources/severity_channel_logger.hpp>
#include <boost/log/sources/severity_logger.hpp>
#include <boost/log/support/date_time.hpp>
#include <boost/log/trivial.hpp>
#include <boost/log/utility/setup/common_attributes.hpp>
#include <boost/log/utility/setup/console.hpp>
#include <boost/log/utility/setup/file.hpp>
#include <boost/log/utility/setup/from_stream.hpp>
#include <boost/log/utility/setup/settings.hpp>
#include <boost/smart_ptr/shared_ptr.hpp>
#include <fstream>
#include <string>

namespace logging = boost::log;
namespace src = boost::log::sources;
namespace expr = boost::log::expressions;
namespace keywords = boost::log::keywords;
namespace attrs = boost::log::attributes;
namespace sinks = boost::log::sinks;
namespace trivial = logging::trivial;
using LogChannal =
    src::severity_channel_logger<trivial::severity_level, std::string>;

namespace LogInit {
LogChannal& GetLogger() {
  static LogChannal logger{};
  return logger;
}
/**
 * 初始化boost_log 只能由main函数调用一次
 * @return
 */
inline int log_init() {
  logging::add_common_attributes();
  logging::core::get()->add_thread_attribute("Scope", attrs::named_scope());

  logging::register_simple_formatter_factory<trivial::severity_level, char>(
      "Severity");
  logging::register_simple_filter_factory<trivial::severity_level, char>(
      "Severity");

  std::ifstream file("./data/properties/boost_log_settings.ini");
  if (!file.is_open()) {
    std::cerr << "open settings fail" << std::endl;
    return -1;
  }
  logging::init_from_stream(file);
  file.close();
  return 0;
}
}  // namespace LogInit
#define LOG_TRACE(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::trace) \
      << msg << "]   [" << __FILE__ << ":" << __LINE__ << "    "      \
      << __PRETTY_FUNCTION__;
#define LOG_DEBUG(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::debug) \
      << msg << "]   [" << __FILE__ << ":" << __LINE__ << "    "      \
      << __PRETTY_FUNCTION__;
#define LOG_INFO(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::info) \
      << msg << "]   [" << __FILE__ << ":" << __LINE__ << "    "     \
      << __PRETTY_FUNCTION__;
#define LOG_WARNING(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::warning) \
      << msg << "]   [" << __FILE__ << ":" << __LINE__ << "    "        \
      << __PRETTY_FUNCTION__;
#define LOG_ERROR(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::error) \
      << msg << "]   [" << __FILE__ << ":" << __LINE__ << "    "      \
      << __PRETTY_FUNCTION__;
//只是一个参考，调用errno检查错误
#define LOG_PERROR(msg)                                                      \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::error)        \
      << msg << "]   ["                                                      \
      << " reason maybe  :  " << strerror(errno) << "   " << __FILE__ << ":" \
      << __LINE__ << "    " << __PRETTY_FUNCTION__;
#define LOG_FATAL(msg)                                           \
  BOOST_LOG_SEV(LogInit::GetLogger(), fatal)                     \
      << msg << "]   [" << __FILE__ << ":" << __LINE__ << "    " \
      << __PRETTY_FUNCTION__;
#else
#include <errno.h>
#include <stdio.h>

class LogTime {
  public:
  static std::string GetTimeNow() {
    time_t t = time(0);
    char ch[64];
    strftime(ch, sizeof(ch), "%Y-%m-%d %H:%M:%S", localtime(&t));
    return ch;
  }
};
#define LOG_BASE(msg)                                                         \
  "    [" << LogTime::GetTimeNow() << "]    "                                 \
          << "[" << msg << "]   [" << __FILE__ << ":" << __LINE__ << "    " \
          << __PRETTY_FUNCTION__ << "]" << std::endl;
#define LOG_TRACE(msg) std::cout << "[TRACE]" << LOG_BASE(msg)
#define LOG_DEBUG(msg) std::cout << "[DEBUG]" << LOG_BASE(msg)
#define LOG_INFO(msg) std::cout << "[INFO]" << LOG_BASE(msg)
#define LOG_WARNING(msg) std::cerr << "[WARNING]" << LOG_BASE(msg)
#define LOG_ERROR(msg) std::cerr << "[ERROR]" << LOG_BASE(msg)
//只是一个参考，调用errno检查错误
#define LOG_PERROR(msg)                                                        \
  std::cerr < "[ERROR]    [" << LogTime::GetTimeNow() << "]    "               \
                             << "[" msg << "]   ["                             \
                             << " reason maybe  :  " << strerror(errno)        \
                             << "   " << __FILE__ << ":" << __LINE__ << "    " \
                             << __PRETTY_FUNCTION__ << "]" << std::endl;
#define LOG_FATAL(msg) std::cerr << "[FATAL]" << LOG_BASE
namespace LogInit {
inline int log_init() { return 0; }
}  // namespace LogInit
#endif

///// 原始输出
#define LOG_RAW_COUT(msg) std::cout << msg;
#define LOG_RAW_CLINE(msg) std::cout << msg << std::endl;
#define LOG_RAW_PRINTF (fmt, args...) printf(fmt, ##args);
#define LOG_RAW_PLINE                 \
  (fmt, args...) printf(fmt, ##args); \
  printf("\n");

#define RAW_COUT(msg) LOG_RAW_COUT(msg);
#define RAW_CLINE(msg) LOG_RAW_CLINE(msg);
#define RAW_PRINTF(fmt, args...) printf(fmt, ##args);
#define RAW_PLINE(fmt, args...) \
  printf(fmt, ##args);          \
  printf("\n");

/************************************************
 * @author puzzzzzzle
 * @email 2359173906@qq.com
 * @desc
 * @time 2023/1/21
 * @file boost_log.h
 * @version
 * version        author            desc
 * 1.0            puzzzzzzle       create
 ************************************************/

#pragma once
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
inline LogChannal& GetLogger() {
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

  std::ifstream file("./data/boost_log_settings.ini");
  if (!file.is_open()) {
    std::cerr << "open settings fail" << std::endl;
    return -1;
  }
  logging::init_from_stream(file);
  file.close();
  return 0;
}
}  // namespace LogInit
template <typename T>
inline boost::log::formatting_ostream& operator<<(
    boost::log::formatting_ostream& p, const T& v) {
  std::ostringstream oss{};
  oss << v;
  p << oss.str();
  return p;
}
#define LOG_BASE(msg)                                            \
  << "[" << msg << "]| " << __FILE__ << ":" << __LINE__ << " | " \
  << __PRETTY_FUNCTION__ << " |" << std::this_thread::get_id();
#define LOG_TRACE(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::trace) \
  LOG_BASE(msg)
#define LOG_DEBUG(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::debug) \
  LOG_BASE(msg)

#define LOG_INFO(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::info) \
  LOG_BASE(msg)

#define LOG_WARNING(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::warning) \
  LOG_BASE(msg)

#define LOG_ERROR(msg)                                                \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::error) \
  LOG_BASE(msg)

// 只是一个参考，调用errno检查错误
#define LOG_PERROR(msg)                                               \
  BOOST_LOG_SEV(LogInit::GetLogger(), trivial::severity_level::error) \
  LOG_BASE(msg) << "|reason maybe:" << strerror(errno)
#define LOG_FATAL(msg)                       \
  BOOST_LOG_SEV(LogInit::GetLogger(), fatal) \
  LOG_BASE(msg)
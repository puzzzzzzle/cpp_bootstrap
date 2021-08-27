/************************************************
 * @author puzzzzzzle
 * @email 2359173906@qq.com
 * @desc
 * @time 2021/5/24
 * @file common_funcs.h
 * @version
 * version        author            desc
 * 1.0            puzzzzzzle       create
 ************************************************/

#pragma once
#include <cassert>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <functional>
#include <ios>
#include <iostream>
#include <iterator>
#include <memory>
#include <set>
#include <sstream>
#include <vector>

/**
 * memncpy 类似strncpy
 * @param dest 目标
 * @param dest_len 目标最大长度
 * @param src 源
 * @param src_len 源最大长度
 * @return 实际拷贝的长度
 */
inline size_t memncpy(void* __restrict dest, size_t dest_len,
                      const void* __restrict src, size_t src_len) {
  size_t len = (src_len < dest_len) ? src_len : dest_len;
  memcpy(dest, src, len);
  return len;
}
/**
 * memncpy,不返回任何信息
 */
#define MEMNCPY(dest, dest_len, src, src_len) \
  memcpy(dest, src, (src_len < dest_len) ? src_len : dest_len)

#ifdef _WIN32
#include "Windows.h"
#include "winsock.h"
unsigned sleep(unsigned seconds) {
  Sleep(seconds);
  return 0;
}
#else
#include <sys/select.h>
#endif
/**
 * 检测读超时的函数（并不进行读操作）
 * 也可以用于accept函数
 * eg：
 * if(read_timeout(fd,waitSec){
 * ERROR() //错误操作
 * }else{
 * read(...) //正确操作
 * }
 * @param fd 目标fd
 * @param wait_sec 等待时间
 * @return 正确返回0，出错返回-1
 */
inline int test_read_timeout(int fd, long wait_sec) {
  int ready_number;
  fd_set r_set{};
  timeval wait_time{};

  FD_ZERO(&r_set);
  FD_SET(fd, &r_set);

  wait_time.tv_sec = wait_sec;
  wait_time.tv_usec = 0;

  do {
    ready_number = select(fd + 1, &r_set, nullptr, nullptr, &wait_time);
  } while (ready_number < 0 && errno == EINTR);  //等待被(信号)打断的情况

  return (ready_number == 1) ? 0 : 1;
}

/**
 * 检测写超时的函数（并不进行读操作）
 * if(write_timeout(fd,waitSec){
 * ERROR() //错误操作
 * }else{
 * read(...) //正确操作
 * }
 * @param fd 目标fd
 * @param wait_sec 等待时间
 * @return 正确返回0，出错返回-1
 */
inline int test_write_timeout(int fd, long wait_sec) {
  int ready_number;
  fd_set w_set{};
  struct timeval wait_time {};

  FD_ZERO(&w_set);
  FD_SET(fd, &w_set);

  wait_time.tv_sec = wait_sec;
  wait_time.tv_usec = 0;

  do {
    ready_number = select(fd + 1, nullptr, &w_set, nullptr, &wait_time);
  } while (ready_number < 0 && errno == EINTR);  //等待被(信号)打断的情况

  return (ready_number == 1) ? 0 : -1;
}
static char readadbleChar[256] =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

inline char randChar() {
  return readadbleChar[rand() % (strlen(readadbleChar))];
}

template <class T>
std::ostream& operator<<(std::ostream& os, const std::vector<T>& v) {
  std::copy(v.begin(), v.end(), std::ostream_iterator<T>(os, ","));
  return os;
}

template <class T>
std::ostream& printArr(std::ostream& os, size_t len, const T value[]) {
  os << "values :\t[";
  for (int i = 0; i < len; ++i) {
    os << value[i] << ", ";
  }
  os << "]";
  return os;
}
template <class T>
std::ostream& sumArr(std::ostream& os, size_t len, const T value[]) {
  os << "sum :\t[";
  T sum{};
  for (int i = 0; i < len; ++i) {
    sum += value[i];
  }
  os << sum;
  return os;
}
template <class T>
bool checkDuplicated(int len, T value[]) {
  std::set<T> checkSet;
  for (int i = 0; i < len; ++i) {
    if (!checkSet.insert(value[i]).second) {
      return false;
    }
  }
  return true;
}
template <typename T>
std::string VecLikeToString(const T& vec) {
  if (vec.empty()) {
    return "[]";
  }
  std::ostringstream oss{};
  oss << "[";
  for (const auto& item : vec) {
    oss << item << ",";
  }
  oss.seekp(-1, std::ios_base::end);
  oss << "]";
  return oss.str();
}
template <typename T>
std::string MapLikeToString(const T& vec, const std::string& lineGap = "") {
  std::ostringstream oss{};
  oss << "[";
  for (const auto& item : vec) {
    oss << "{" << item.first << "," << item.second << "}" << lineGap << ",";
  }
  oss.seekp(-1, std::ios_base::end);
  oss << "]";
  return oss.str();
}
template <class ItemType>
bool InContainer(const ItemType& item, const std::vector<ItemType>& container) {
  return std::find(container.cbegin(), container.cend(), item) !=
         container.cend();
}
template <class ItemType, class FindableContainerType>
bool InContainer(const ItemType& item, const FindableContainerType& container) {
  return container.find(item) != container.cend();
}

inline int Split(std::string s, const std::string& delimiter,
                 std::vector<std::string>& rst) {
  rst.clear();
  int count = 0;
  size_t pos = 0;
  while ((pos = s.find(delimiter)) != std::string::npos) {
    std::string token = s.substr(0, pos);
    rst.push_back(token);
    ++count;
    s.erase(0, pos + delimiter.length());
  }
  rst.push_back(s);
  ++count;
  return count;
}
inline std::string LoadFileStr(const std::string& path) {
  std::ifstream inFile(path.c_str());
  if (!inFile.is_open()) {
    return "";
  }
  std::istreambuf_iterator<char> begin(inFile);
  std::istreambuf_iterator<char> end;
  std::string allStr(begin, end);
  return allStr;
}
inline bool startsWith(const std::string& s, const std::string& sub) {
  return s.find(sub) == 0;
}

inline bool endsWith(const std::string& s, const std::string& sub) {
  return s.rfind(sub) == (s.length() - sub.length());
}
template <typename T>
T InstenceSharedPtr() {
  return std::make_shared<typename T::element_type>();
}
template <typename T>
T InstenceSharedPtr(T) {
  return std::make_shared<typename T::element_type>();
}

#define DOUBLE_DIFF_GAP 0.000001
/**
 * lhs小 -1
 * 相等 0
 * lhs大 1
 * @param lhs
 * @param rhs
 * @return
 */
template <typename L, typename R>
int CompareDouble(L lhs, R rhs) {
  double diff = lhs - rhs;
  if (std::abs(diff) <= DOUBLE_DIFF_GAP) {
    return 0;
  }
  if (diff < 0) {
    return -1;
  }
  return 1;
}
//
// Created by tao on 19-1-21.
//

#ifndef UNIXSTUDY_COMMON_FUNCS_H
#define UNIXSTUDY_COMMON_FUNCS_H

#include <cassert>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <functional>
#include <ios>
#include <iostream>
#include <iterator>
#include <set>
#include <sstream>
#include <vector>
//>其他文件中的方法
//#include "log_init.h"
//<

/**
 * memncpy 类似strncpy
 * @param dest 目标
 * @param dest_len 目标最大长度
 * @param src 源
 * @param src_len 源最大长度
 * @return 实际拷贝的长度
 */
size_t memncpy(void* __restrict dest, size_t dest_len,
               const void* __restrict src, size_t src_len);

/**
 * memncpy,不返回任何信息
 */
#define MEMNCPY(dest, dest_len, src, src_len) \
  memcpy(dest, src, (src_len < dest_len) ? src_len : dest_len)

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
int test_read_timeout(int fd, long wait_sec);

/**
 * 检测写超时的函数（并不进行读操作）
 * if(write_timeout(fd,waitSec){
 * ERROR() //错误操作
 * }else{
 * write(...) //正确操作
 * }
 * @param fd 目标fd
 * @param wait_sec 等待时间
 * @return 正确返回0，出错返回-1
 */
int test_write_timeout(int fd, long wait_sec);

char randChar();

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
template <typename SET_TYPE, typename VALUE_TYPE>
bool IsInStlCon(const SET_TYPE& checkSet, const VALUE_TYPE& key) {
  auto it = checkSet.find(key);
  if (checkSet.end() == it) {
    return false;
  } else {
    return true;
  }
}
template <typename T>
std::string MapLikeToString(const T& vec) {
  std::ostringstream oss{};
  oss << "[";
  for (const auto& item : vec) {
    oss << "{" << item.first << "," << item.second << "},";
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

struct CommonFuncs {
  static int Split(std::string s, const std::string& delimiter,
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
  static std::string LoadFileStr(const std::string& path) {
    std::ifstream inFile(path.c_str());
    if (!inFile.is_open()) {
      return "";
    }
    std::istreambuf_iterator<char> begin(inFile);
    std::istreambuf_iterator<char> end;
    std::string allStr(begin, end);
    return allStr;
  }
  static bool startsWith(const std::string& s, const std::string& sub) {
    return s.find(sub) == 0;
  }

  static bool endsWith(const std::string& s, const std::string& sub) {
    return s.rfind(sub) == (s.length() - sub.length());
  }
};
#endif  // UNIXSTUDY_COMMON_FUNCS_H

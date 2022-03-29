/************************************************
 * @author puzzzzle
 * @mail 2359173906@qq.com
 * @desc stl 容器to_string 或者 输出到 ostream, 并自带operator<< 操作符
 * 以支持
 * array vector forward_list list
 * set unordered_set multiset unordered_multiset
 * map unordered_map multimap unordered_multimap
 * pair
 * @time 2022/3/28
 * @file stl_to_str.h
 * @version
 * version        author            desc
 * 1.0            puzzzzle       create
 ************************************************/

#pragma once
#include <array>
#include <deque>
#include <forward_list>
#include <ios>
#include <list>
#include <map>
#include <set>
#include <stack>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

// 类似 vec 的输出分割符
#ifndef STL_TO_STR_START
#define STL_TO_STR_START "["
#endif

#ifndef STL_TO_STR_END
#define STL_TO_STR_END "]"
#endif

#ifndef STL_TO_STR_SPLIT
#define STL_TO_STR_SPLIT ","
#endif

// pair 的输出分割符
#ifndef STL_TO_STR_PAIR_START
#define STL_TO_STR_PAIR_START "("
#endif

#ifndef STL_TO_STR_PAIR_END
#define STL_TO_STR_PAIR_END ")"
#endif

#ifndef STL_TO_STR_PAIR_SPLIT
#define STL_TO_STR_PAIR_SPLIT ","
#endif

// map的输出分隔符
#ifndef STL_TO_STR_MAP_START
#define STL_TO_STR_MAP_START "{"
#endif

#ifndef STL_TO_STR_MAP_END
#define STL_TO_STR_MAP_END "}"
#endif

#ifndef STL_TO_STR_MAP_SPLIT
#define STL_TO_STR_MAP_SPLIT ","
#endif

#ifndef STL_TO_STR_MAP_KEY_START
#define STL_TO_STR_MAP_KEY_START "\""
#endif

#ifndef STL_TO_STR_MAP_KEY_END
#define STL_TO_STR_MAP_KEY_END "\""
#endif

#ifndef STL_TO_STR_MAP_KEY_SPLIT
#define STL_TO_STR_MAP_KEY_SPLIT ":"
#endif

#ifndef STL_TO_STR_MAP_ITEM_START
#define STL_TO_STR_MAP_ITEM_START "{"
#endif

#ifndef STL_TO_STR_MAP_ITEM_END
#define STL_TO_STR_MAP_ITEM_END "}"
#endif

template <typename T>
class default_value_to_stream {
  public:
  void operator()(std::ostream &os, const T &v) { os << v; }
};

template <typename T, typename TW = default_value_to_stream<
                          typename std::remove_reference<T>::type::value_type>>
std::ostream &vec_like_to_string_t(
    std::ostream &os, const T &vec, const std::string &start = STL_TO_STR_START,
    const std::string &end = STL_TO_STR_END,
    const std::string &split = STL_TO_STR_SPLIT) {
  TW to_str{};
  os << start;
  auto it = vec.cbegin();
  // 忽略最后一个数据, 按照json格式, 不能输出分割符
  auto it_next = it;
  ++it_next;
  while (it != vec.cend()) {
    to_str(os, *it);
    os << split;
    ++it;
    ++it_next;
    if (it_next == vec.cend()) {
      break;
    }
  }
  if (it != vec.cend()) {
    to_str(os, *it);
  }
  os << end;
#ifdef STL_TO_STR_WITH_COUNT
  os << "(" << count << ")";
#endif
  return os;
}
template <typename T,
          typename TW = default_value_to_stream<typename T::value_type>>
std::string vec_like_to_string(const T &vec) {
  std::ostringstream oss{};
  vec_like_to_string_t<T, TW>(oss, vec);
  return oss.str();
}
// 不能直接重载一个通配符T, 要重载std::xxx<T>, 因为这会和全局的符号冲突,
// 例如 std::vector<char>  和std::string 会有歧义, 两者都能匹配成功

// 匹配 单值 顺序容器
template <typename T, typename _Alloc, typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os, const std::vector<T, _Alloc> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}
template <typename T, std::size_t _Nm, typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os, const std::array<T, _Nm> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}
template <typename T, typename _Alloc, typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os,
                         const std::forward_list<T, _Alloc> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}

template <typename T, typename _Alloc, typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os, const std::list<T, _Alloc> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}
template <typename T, typename _Alloc, typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os, const std::deque<T, _Alloc> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}
// 匹配单值关联容器
template <typename T, typename _Compare, typename _Alloc,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os,
                         const std::set<T, _Compare, _Alloc> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}
template <typename T, typename _Compare, typename _Alloc,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os,
                         const std::multiset<T, _Compare, _Alloc> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}
template <typename T, typename _Compare, typename _Alloc,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(
    std::ostream &os, const std::unordered_multiset<T, _Compare, _Alloc> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}
template <typename T, typename _Hash, typename _Pred, typename _Alloc,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(
    std::ostream &os, const std::unordered_set<T, _Hash, _Pred, _Alloc> &vec) {
  return vec_like_to_string_t<decltype(vec), TW>(os, vec);
}

// 匹配关联容器
template <typename K, typename T, typename KW = default_value_to_stream<K>,
          typename TW = default_value_to_stream<T>>
class map_pair_to_stream {
  KW _M_k_to_steam{};
  TW _M_t_to_steam{};

  public:
  std::ostream &operator()(std::ostream &os, const std::pair<K, T> &obj) {
    os << STL_TO_STR_MAP_ITEM_START << STL_TO_STR_MAP_KEY_START;
    _M_k_to_steam(os, obj.first);
    os << STL_TO_STR_MAP_KEY_END << STL_TO_STR_MAP_KEY_SPLIT;
    _M_t_to_steam(os, obj.second);
    os << STL_TO_STR_MAP_ITEM_END;
    return os;
  }
};
template <typename _Tp,
          typename KW = default_value_to_stream<typename _Tp::key_type>,
          typename TW = default_value_to_stream<typename _Tp::mapped_type>>
std::ostream &map_like_to_string_t(std::ostream &os, const _Tp &map) {
  using MapT = typename std::remove_reference<_Tp>::type;
  return vec_like_to_string_t<
      _Tp, map_pair_to_stream<typename MapT::key_type,
                              typename MapT::mapped_type, KW, TW>>(
      os, map, STL_TO_STR_MAP_START, STL_TO_STR_MAP_END, STL_TO_STR_MAP_SPLIT);
}

template <typename _Tp,
          typename KW = default_value_to_stream<typename _Tp::key_type>,
          typename TW = default_value_to_stream<typename _Tp::mapped_type>>
std::string map_like_to_string(const _Tp &map) {
  std::ostringstream oss{};
  map_like_to_string_t<_Tp, KW, TW>(oss, map);
  return oss.str();
}
template <typename K, typename T, typename _Compare, typename _Alloc,
          typename KW = default_value_to_stream<K>,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os,
                         const std::map<K, T, _Compare, _Alloc> &map) {
  return map_like_to_string_t<decltype(map), KW, TW>(os, map);
}
template <typename K, typename T, typename _Compare, typename _Alloc,
          typename KW = default_value_to_stream<K>,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os,
                         const std::multimap<K, T, _Compare, _Alloc> &map) {
  return map_like_to_string_t<decltype(map), KW, TW>(os, map);
}
template <typename K, typename T, typename _Compare, typename _Alloc,
          typename KW = default_value_to_stream<K>,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(
    std::ostream &os,
    const std::unordered_multimap<K, T, _Compare, _Alloc> &map) {
  return map_like_to_string_t<decltype(map), KW, TW>(os, map);
}
template <typename K, typename T, class _Hash, class _Pred, class _Alloc,
          typename KW = default_value_to_stream<K>,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(
    std::ostream &os,
    const std::unordered_map<K, T, _Hash, _Pred, _Alloc> &map) {
  return map_like_to_string_t<decltype(map), KW, TW>(os, map);
}

// 匹配 k,v 容器
template <typename K, typename T, typename KW = default_value_to_stream<K>,
          typename TW = default_value_to_stream<T>>
std::ostream &pair_to_string_t(std::ostream &os, const std::pair<K, T> &obj) {
  KW _M_k_to_steam{};
  TW _M_v_to_steam{};
  os << STL_TO_STR_PAIR_START;
  _M_k_to_steam(os, obj.first);
  os << STL_TO_STR_PAIR_SPLIT;
  _M_v_to_steam(os, obj.second);
  os << STL_TO_STR_PAIR_END;
  return os;
}
template <typename K, typename T, typename KW = default_value_to_stream<K>,
          typename TW = default_value_to_stream<T>>
std::string pair_to_string(const std::pair<K, T> &obj) {
  std::ostringstream oss{};
  pair_to_string_t<K, T, KW, TW>(oss, obj);
  return oss.str();
}
template <typename K, typename T, typename KW = default_value_to_stream<K>,
          typename TW = default_value_to_stream<T>>
std::ostream &operator<<(std::ostream &os, const std::pair<K, T> &obj) {
  return pair_to_string_t<K, T, KW, TW>(os, obj);
}

// 容器适配器 stack queue priority_queue

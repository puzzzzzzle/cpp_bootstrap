cmake_minimum_required(VERSION 3.7)
set(project_name template_project)
set(CMAKE_CXX_STANDARD 17)


project(${project_name})

#设置版本号
set(VERSION_MAJOR 1.2)
set(VERSION_MINOR 0)

# boost 选项
option(boost_static "use static boost lib" ON)

#log 选项
# 默认不使用boost, 减少依赖
#add_definitions(-DLOG_BOOST)

# # 设置conan 参数
#set(CONAN_ARGS "${CONAN_ARGS} ")
message("CONAN_ARGS: ${CONAN_ARGS}")

# 环境
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 设置源码根目录(包含cmake的文件夹将被解析为一个编译target)
set(SRC_DIR_ROOT ${CMAKE_SOURCE_DIR}/src)
# 设置配目录(运行时拷贝)
set(CONFIG_DIR ${CMAKE_SOURCE_DIR}/data)
# 设置 boostStrap 文件夹名
set(BOOTSTRAP_DIR ${CMAKE_SOURCE_DIR}/cpp_bootstrap)

# 开始加载
include(cpp_bootstrap/BasicCmake.cmake)

AddAllSubDir()

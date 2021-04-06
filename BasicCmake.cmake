add_definitions(-DBOOTSTRAP_DIR ${BOOTSTRAP_DIR})

include(${BOOTSTRAP_DIR}/common/CMake/FuncDefs.cmake)

# 按需加载conan管理的依赖
ConanBootstrap()

# 公用定义,需要在设定完成后include
include(${BOOTSTRAP_DIR}/common/CMake/CommonInclude.cmake)


# 编译ptoro, 所有proto 打包为一个定义 PTOTO_CPPS
# TODO 实现中
#set(PROTO_CPP_DIR ${CMAKE_BINARY_DIR}/proto)
#BuildProto(${CMAKE_SOURCE_DIR}/src ${PROTO_CPP_DIR})
#include_directories(${PROTO_CPP_DIR})
#aux_source_directory(${PROTO_CPP_DIR} PROTO_CPPS)




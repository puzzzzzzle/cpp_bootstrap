add_definitions(-DBOOTSTRAP_DIR ${BOOTSTRAP_DIR})

include(${BOOTSTRAP_DIR}/common/CMake/FuncDefs.cmake)

# 按需加载conan管理的依赖
if (NOT IGNORE_CONAN)
    # 加载conan
    set(CONAN_LIBS "")
    set(CONAN_EXEC "conan install ..  --build missing  ${CONAN_ARGS} ")
    message("CONAN_EXEC at  ${CMAKE_CURRENT_SOURCE_DIR} : ${CONAN_EXEC}")
    # 注意 execute_process  COMMAND 并不会做任何解析, 会逐字逐句的传递给命令行
    # 有需要参数的, 使用环境变量吧
    execute_process(
            COMMAND conan install .. --build missing
            OUTPUT_VARIABLE _RES
            ERROR_VARIABLE _RES
    )
    message("conan install end ${_RES}")
    include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    conan_basic_setup()
    message("conan get libs\t${CONAN_LIBS}\n")
    add_definitions(-DUSE_CONAN)
else ()
    add_definitions(-DIGNORE_CONAN)
endif ()

# 公用定义,需要在设定完成后include
include(${BOOTSTRAP_DIR}/common/CMake/CommonInclude.cmake)


# 编译ptoro, 所有proto 打包为一个定义 PTOTO_CPPS
# TODO 实现中
#set(PROTO_CPP_DIR ${CMAKE_BINARY_DIR}/proto)
#BuildProto(${CMAKE_SOURCE_DIR}/src ${PROTO_CPP_DIR})
#include_directories(${PROTO_CPP_DIR})
#aux_source_directory(${PROTO_CPP_DIR} PROTO_CPPS)




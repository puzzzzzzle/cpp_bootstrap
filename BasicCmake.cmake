
add_definitions(-DBOOTSTRAP_DIR ${BOOTSTRAP_DIR})

# 选项
option(boost_static "use static boost lib" ON)

include(${BOOTSTRAP_DIR}/common/CMake/FuncDefs.cmake)

# 公用定义,需要在设定完成后include
include(${BOOTSTRAP_DIR}/common/CMake/CommonInclude.cmake)

# 加载conan
set(CONAN_LIBS "")
execute_process(
        COMMAND conan install ..
)
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()
message("conan get libs\t${CONAN_LIBS}\n")


# 编译ptoro, 所有proto 打包为一个定义 PTOTO_CPPS
# TODO 实现中
set(PROTO_CPP_DIR ${CMAKE_BINARY_DIR}/proto)
BuildProto(${CMAKE_SOURCE_DIR}/src ${PROTO_CPP_DIR})
include_directories(${PROTO_CPP_DIR})
aux_source_directory(${PROTO_CPP_DIR} PROTO_CPPS)

# 遍历文件
AddAllSubDir()


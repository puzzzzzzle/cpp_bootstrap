aux_source_directory(. ${build_temp}cpps)
include_directories(.)
include_directories(../adapter)

# 输出库
add_library(${build_temp}-impl SHARED ${${build_temp}cpps} )
add_library(${build_temp}-static-impl STATIC ${${build_temp}cpps} )

#动态链接库依赖
target_link_libraries(${build_temp}-impl  pthread ${COMMON_LIBS})

# 可执行文件
aux_source_directory(main ${build_temp}maincpps)
add_executable(${build_temp} ${${build_temp}maincpps})
#可执行文件的依赖动态库
target_link_libraries(${build_temp}-share ${build_temp}-impl)
target_link_libraries(${build_temp}-static ${build_temp}-static-impl)

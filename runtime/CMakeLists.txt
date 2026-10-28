cmake_minimum_required(VERSION 3.20)
project(CoroShadowRuntime C)

add_library(coroshadow STATIC CoroShadowRuntime.c)
target_link_libraries(coroshadow pthread)
target_compile_options(coroshadow PRIVATE -O2 -Wall)
install(TARGETS coroshadow ARCHIVE DESTINATION lib)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../passes/CoroShadowPass.h
        DESTINATION include)


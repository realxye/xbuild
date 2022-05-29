cmake_minimum_required(VERSION 3.15.0)

project(LibCppVersionCheck CXX)

add_library(PrintLibCppVersion STATIC main.cpp)
target_compile_options(PrintLibCppVersion PRIVATE -stdlib=libc++)
target_link_options(PrintLibCppVersion PRIVATE -stdlib=libc++)

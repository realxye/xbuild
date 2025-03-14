cmake_minimum_required(VERSION 3.15.0)

project(libcppversioncheck CXX)

add_library(printlibcppversion STATIC main.cpp)
target_compile_options(printlibcppversion PRIVATE -stdlib=libc++)
target_link_options(printlibcppversion PRIVATE -stdlib=libc++)

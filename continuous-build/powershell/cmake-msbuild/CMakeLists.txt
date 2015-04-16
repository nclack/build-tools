cmake_minimum_required(VERSION 3.0)
project(scratch)
include_directories(
  "$ENV{VCINSTALLDIR}/include"
  "$ENV{UniversalCRTSdkDir}/include/ucrt"
  "$ENV{WindowsSdkDir}/Include/shared"
  "$ENV{WindowsSdkDir}/Include/um"
  "$ENV{WindowsSdkDir}/Include/winrt"
)

add_subdirectory(src)

# Protobuf

# first try the package provided config
find_package(Protobuf CONFIG)
if(NOT Protobuf_FOUND)
  # Fall back to the CMake provide module
  find_package(Protobuf MODULE REQUIRED)
endif()

add_library(mixxx-proto OBJECT)
add_library(mixxx-grpc OBJECT "${CMAKE_CURRENT_LIST_DIR}/plugin.proto")

if(TARGET protobuf::libprotobuf)
    target_link_libraries(mixxx-proto PUBLIC protobuf::libprotobuf)
    if(TARGET grpc++)
      target_link_libraries(mixxx-grpc PUBLIC protobuf::libprotobuf grpc++)
    else()
        message(FATAL_ERROR "grpc++ libraries are required to compile Mixxx.")
    endif()
else()
    message(FATAL_ERROR "Protobuf libraries are required to compile Mixxx.")
endif()

if(EMSCRIPTEN)
  # If we try linking in a proto lib built without -pthread we get
  #   wasm-ld: error: --shared-memory is disallowed by keys.pb.cc.o
  #   because it was not compiled with 'atomics' or 'bulk-memory' features.
  # See https://groups.google.com/g/emscripten-discuss/c/G4nwFprZFYo
  target_compile_options(mixxx-proto PRIVATE -pthread)
endif()
set(PROTO_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(PROTO_IMPORT_DIRS "${CMAKE_CURRENT_LIST_DIR}")

file(MAKE_DIRECTORY ${PROTO_BINARY_DIR})

protobuf_generate(
  LANGUAGE cpp
  TARGET mixxx-proto
  PROTOS
    beats.proto
    headers.proto
    keys.proto
    skin.proto
    waveform.proto
)

target_include_directories(mixxx-grpc PUBLIC "$<BUILD_INTERFACE:${PROTO_BINARY_DIR}>")

protobuf_generate(
    TARGET mixxx-grpc
    PROTOS
      plugin.proto
    PROTOC_OUT_DIR "${PROTO_BINARY_DIR}")

protobuf_generate(
  LANGUAGE grpc
  TARGET mixxx-grpc
  GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc
  PROTOS
    plugin.proto
  PLUGIN "protoc-gen-grpc=\$<TARGET_FILE:grpc_cpp_plugin>"
  PROTOC_OUT_DIR "${PROTO_BINARY_DIR}")

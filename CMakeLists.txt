cmake_minimum_required(VERSION 3.4.1)

project(monero-java-jni)

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -std=c++11 -F/Library/Frameworks -pthread")

#find_package(Threads)
#find_package(Backtrace)

add_definitions(-DAUTO_INITIALIZE_EASYLOGGINGPP)

#############
# System
#############

include_directories("$ENV{JAVA_HOME}")
include_directories("$ENV{JAVA_HOME}/include")
include_directories("$ENV{JAVA_HOME}/include/darwin")

# TODO: remove TRUEs, how are APPLE, DEPENDS, etc initialized?
if (TRUE OR HIDAPI_FOUND OR LibUSB_COMPILE_TEST_PASSED)
  if (TRUE OR APPLE)
    if(TRUE OR DEPENDS)
      list(APPEND EXTRA_LIBRARIES "-framework Foundation -framework IOKit")
    else()
      find_library(COREFOUNDATION CoreFoundation)
      find_library(IOKIT IOKit)
      list(APPEND EXTRA_LIBRARIES ${IOKIT})
      list(APPEND EXTRA_LIBRARIES ${COREFOUNDATION})
    endif()
  endif()
  if (WIN32)
    list(APPEND EXTRA_LIBRARIES setupapi)
  endif()
endif()

#list(APPEND EXTRA_LIBRARIES "-framework Foundation -framework IOKit")
message(STATUS EXTRA_LIBRARIES: ${EXTRA_LIBRARIES})

##############
# C++ bridge
##############

include_directories("src/main/cpp")

#####################
# monero-cpp-library
#####################

set(MONERO_CPP "external/monero-cpp-library")
set(MONERO_CPP_SRC "${MONERO_CPP}/src")

# headers
include_directories("${MONERO_CPP_SRC}")
include_directories("${MONERO_CPP}/external/libsodium/include")
include_directories("${MONERO_CPP}/external/libsodium/include/sodium")

##################
# monero-project
##################

set(MONERO_CORE "${MONERO_CPP}/external/monero-core")
set(MONERO_CORE_SRC "${MONERO_CORE}/src")

# headers
include_directories("${MONERO_CORE_SRC}/")
include_directories("${MONERO_CORE_SRC}/checkpoints")
include_directories("${MONERO_CORE_SRC}/common")
#include_directories("${MONERO_CORE_SRC}/crypto")
#include_directories("${MONERO_CORE_SRC}/crypto/crypto_ops_builder/include/")	# DISABLED?
#include_directories("${MONERO_CORE_SRC}/crypto/crypto_ops_builder/include/sodium")	# DISABLED?
include_directories("${MONERO_CORE_SRC}/cryptonote_basic")
#include_directories("${MONERO_CORE_SRC}/multisig")
#include_directories("${MONERO_CORE_SRC}/cryptonote_core")
#include_directories("${MONERO_CORE_SRC}/cryptonote_protocol")
#include_directories("${MONERO_CORE_SRC}/wallet")
#include_directories("${MONERO_CORE_SRC}/rpc")
#include_directories("${MONERO_CORE_SRC}/mnemonics")
include_directories("${MONERO_CORE}/external/")
include_directories("${MONERO_CORE}/external/easylogging++")
include_directories("${MONERO_CORE}/external/rapidjson/include")
include_directories("${MONERO_CORE}/external/unbound/libunbound")
include_directories("${MONERO_CORE}/external/db_drivers/liblmdb")
include_directories("${MONERO_CORE}/contrib/epee/include")
include_directories("${MONERO_CORE}/contrib/epee/include/net")

#include_directories("${CMAKE_CURRENT_BINARY_DIR}")
#include_directories("${MONERO_CORE_SRC}/wallet/api")

include_directories("${MONERO_CORE}/build/release/translations")

#############
# OpenSSL
#############

#find_package(OpenSSL REQUIRED)
#message(STATUS "Using OpenSSL include dir at ${OPENSSL}")

set(OPENSSL "${MONERO_CPP}/external/openssl-sdk")
include_directories("${OPENSSL}")
include_directories("${OPENSSL}/include") # must exist already - run bin/build-openssl-emscripten.sh

add_library(openssl_crypto STATIC IMPORTED)
set_target_properties(
    openssl_crypto PROPERTIES IMPORTED_LOCATION
    ${OPENSSL}/lib/libcrypto.a
)

add_library(openssl_ssl STATIC IMPORTED)
set_target_properties(
    openssl_ssl PROPERTIES IMPORTED_LOCATION
    ${OPENSSL}/lib/libssl.a
)

#############
# Boost
#############

set(BOOST "${MONERO_CPP}/external/boost-sdk") # must already exist and be built
include_directories("${BOOST}")
include_directories("${BOOST}/include")

add_library(boost_chrono STATIC IMPORTED)
set_target_properties(
    boost_chrono PROPERTIES IMPORTED_LOCATION
    ${BOOST}/lib/libboost_chrono.a
)

add_library(boost_system STATIC IMPORTED)
set_target_properties(
    boost_system PROPERTIES IMPORTED_LOCATION
    ${BOOST}/lib/libboost_system.a
)

add_library(boost_thread STATIC IMPORTED)
set_target_properties(
    boost_thread PROPERTIES IMPORTED_LOCATION
    ${BOOST}/lib/libboost_thread.a
)

add_library(boost_serialization STATIC IMPORTED)
set_target_properties(
    boost_serialization PROPERTIES IMPORTED_LOCATION
    ${BOOST}/lib/libboost_serialization.a
)

add_library(boost_filesystem STATIC IMPORTED)
set_target_properties(
    boost_filesystem PROPERTIES IMPORTED_LOCATION
    ${BOOST}/lib/libboost_filesystem.a
)

add_library(boost_regex STATIC IMPORTED)
set_target_properties(
    boost_regex PROPERTIES IMPORTED_LOCATION
    ${BOOST}/lib/libboost_regex.a
)

#add_library(boost_atomic STATIC IMPORTED)
#set_target_properties(
    #boost_atomic PROPERTIES IMPORTED_LOCATION
    #${BOOST}/lib/libboost_atomic.a
#)

####################
# Source files
####################

set(
    SRC_FILES
    
    # monero-java JNI bridge
    src/main/cpp/monero_utils_jni_bridge.cpp
    src/main/cpp/monero_wallet_jni_bridge.cpp
    
    # monero-cpp-library
    ${MONERO_CPP_SRC}/utils/monero_utils.cpp
    ${MONERO_CPP_SRC}/daemon/monero_daemon_model.cpp
    ${MONERO_CPP_SRC}/wallet/monero_wallet_model.cpp
    ${MONERO_CPP_SRC}/wallet/monero_wallet_keys.cpp
    ${MONERO_CPP_SRC}/wallet/monero_wallet_core.cpp
    ${MONERO_CPP}/external/libsodium/src/crypto_verify/verify.c
    
    # monero-project (modified for WASM)
    ${MONERO_CORE_SRC}/wallet/wallet2.cpp
    ${MONERO_CORE_SRC}/wallet/message_store.cpp
    ${MONERO_CORE_SRC}/wallet/message_transporter.cpp
    ${MONERO_CORE_SRC}/wallet/node_rpc_proxy.cpp
    ${MONERO_CORE_SRC}/wallet/wallet_rpc_payments.cpp
    ${MONERO_CORE}/external/db_drivers/liblmdb/mdb.c
    ${MONERO_CORE}/external/db_drivers/liblmdb/midl.c
    #${MONERO_CORE_SRC}/blockchain_db/lmdb/db_lmdb.cpp
    ${MONERO_CORE_SRC}/cryptonote_basic/cryptonote_basic_impl.cpp
    ${MONERO_CORE_SRC}/cryptonote_basic/account.cpp
    ${MONERO_CORE_SRC}/cryptonote_basic/cryptonote_format_utils.cpp
    ${MONERO_CORE_SRC}/checkpoints/checkpoints.cpp
    ${MONERO_CORE_SRC}/crypto/crypto.cpp
    ${MONERO_CORE_SRC}/crypto/hash.c
    ${MONERO_CORE_SRC}/crypto/slow-hash.c
    #${MONERO_CORE_SRC}/crypto/slow-hash-dummied.cpp
    ${MONERO_CORE_SRC}/crypto/oaes_lib.c
    ${MONERO_CORE_SRC}/crypto/crypto-ops.c
    ${MONERO_CORE_SRC}/crypto/crypto-ops-data.c
    ${MONERO_CORE_SRC}/crypto/keccak.c
    ${MONERO_CORE_SRC}/crypto/chacha.c
    ${MONERO_CORE_SRC}/crypto/random.c
    ${MONERO_CORE_SRC}/crypto/aesb.c
    ${MONERO_CORE_SRC}/crypto/tree-hash.c
    ${MONERO_CORE_SRC}/crypto/hash-extra-blake.c
    ${MONERO_CORE_SRC}/crypto/blake256.c
    ${MONERO_CORE_SRC}/crypto/hash-extra-groestl.c
    ${MONERO_CORE_SRC}/crypto/hash-extra-jh.c
    ${MONERO_CORE_SRC}/crypto/hash-extra-skein.c
    ${MONERO_CORE_SRC}/crypto/groestl.c
    ${MONERO_CORE_SRC}/crypto/jh.c
    ${MONERO_CORE_SRC}/crypto/skein.c
    ${MONERO_CORE_SRC}/cryptonote_core/cryptonote_tx_utils.cpp
    ${MONERO_CORE_SRC}/common/perf_timer.cpp
    ${MONERO_CORE_SRC}/common/base58.cpp
    ${MONERO_CORE_SRC}/common/threadpool.cpp
    ${MONERO_CORE_SRC}/common/aligned.c
    ${MONERO_CORE_SRC}/common/util.cpp
    ${MONERO_CORE_SRC}/common/i18n.cpp
    ${MONERO_CORE}/contrib/epee/src/hex.cpp
    #${MONERO_CORE}/contrib/epee/src/http_auth.cpp
    ${MONERO_CORE}/contrib/epee/src/string_tools.cpp
    ${MONERO_CORE}/contrib/epee/src/memwipe.c
    ${MONERO_CORE}/contrib/epee/src/mlocker.cpp
    ${MONERO_CORE}/contrib/epee/src/wipeable_string.cpp
    ${MONERO_CORE_SRC}/device/device.cpp
    ${MONERO_CORE_SRC}/device/device_default.cpp
    ${MONERO_CORE_SRC}/multisig/multisig.cpp
    ${MONERO_CORE_SRC}/rpc/rpc_payment_signature.cpp
    ${MONERO_CORE_SRC}/ringct/rctOps.cpp
    ${MONERO_CORE_SRC}/ringct/rctTypes.cpp
    ${MONERO_CORE_SRC}/ringct/rctCryptoOps.c
    ${MONERO_CORE_SRC}/ringct/rctSigs.cpp
    ${MONERO_CORE_SRC}/ringct/bulletproofs.cc
    ${MONERO_CORE_SRC}/ringct/multiexp.cc
    ${MONERO_CORE_SRC}/mnemonics/electrum-words.cpp
    ${MONERO_CORE}/external/easylogging++/easylogging++.cc
    ${MONERO_CORE_SRC}/wallet/ringdb.cpp
)

###############################################
# Build Java dynamic library (.dylib) for JNI
###############################################

add_library(monero-java SHARED ${SRC_FILES})

target_link_libraries(monero-java
	${EXTRA_LIBRARIES}
)
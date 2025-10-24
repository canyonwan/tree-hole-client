#!/bin/bash

# 设置 SDK 环境变量
export DEVECO_SDK_HOME="$HOME/Library/OpenHarmony/Sdk"

# 清理缓存
echo "清理构建缓存..."
rm -rf .hvigor/cache
rm -rf build
rm -rf products/default/.hvigor
rm -rf products/default/build

# 运行 hvigor 编译
echo "开始编译..."
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node \
  /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js \
  --mode module \
  -p module=default@default \
  -p product=default \
  assembleHap \
  --stacktrace \
  --no-daemon

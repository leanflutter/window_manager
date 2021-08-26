#!/usr/bin/env bash

# 编译 window_manager_example
cd ../
cd example/
flutter build web --profile
rm -rf ../embed_example/window_manager_example
mv build/web ../embed_example/window_manager_example
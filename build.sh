#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Cloudflare Pages 构建脚本
# 安装与本地一致的 Dart Sass 和 Hugo，然后构建站点
#------------------------------------------------------------------------------
set -euo pipefail

# 工具版本（与本地保持一致）
DART_SASS_VERSION=1.108.2
HUGO_VERSION=0.170.1

# 时区
export TZ=Asia/Shanghai
# 构建缓存目录
export HUGO_CACHEDIR="${PWD}/.cache/hugo"

build_temp_dir=$(mktemp -d)
trap 'rm -rf "$build_temp_dir"' EXIT
mkdir -p "${HOME}/.local"

# 1. 安装 Dart Sass（FixIt 主题编译 SCSS 必需）
echo "Installing Dart Sass ${DART_SASS_VERSION}..."
curl -sfL --output-dir "${build_temp_dir}" -O \
  "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz"
tar -C "${HOME}/.local" -xf "${build_temp_dir}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz"
export PATH="${HOME}/.local/dart-sass:${PATH}"

# 2. 安装 Hugo（标准版 + 外部 Dart Sass 即可）
echo "Installing Hugo ${HUGO_VERSION}..."
curl -sfL --output-dir "${build_temp_dir}" -O \
  "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
mkdir -p "${HOME}/.local/hugo"
tar -C "${HOME}/.local/hugo" -xf "${build_temp_dir}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
export PATH="${HOME}/.local/hugo:${PATH}"

echo "sass: $(sass --version)"
echo "hugo: $(hugo version)"

# 3. 构建站点；baseURL 优先用 Cloudflare 提供的部署地址
hugo --gc --minify --baseURL "${CF_PAGES_URL:-https://example.org/}"

#!/bin/bash
# 部署脚本 — 在本机执行，推送代码到华为云服务器
# 用法: ./deploy.sh
set -e

SERVER="root@115.175.15.145"
REMOTE_DIR="/data/postcards"
APP_NAME="postcards-api"

echo "==> 构建 TypeScript..."
npm run build

echo "==> 同步代码到服务器..."
rsync -avz --delete \
  --exclude='.env' \
  --exclude='node_modules' \
  --exclude='uploads' \
  --exclude='logs' \
  dist/ "$SERVER:$REMOTE_DIR/dist/"

rsync -avz \
  package.json \
  ecosystem.config.js \
  "$SERVER:$REMOTE_DIR/"

echo "==> 服务器：安装依赖（仅 production）..."
ssh "$SERVER" "cd $REMOTE_DIR && npm install --omit=dev"

echo "==> 服务器：重启应用..."
ssh "$SERVER" "cd $REMOTE_DIR && pm2 reload $APP_NAME || pm2 start ecosystem.config.js"

echo "==> 服务器：保存 PM2 进程列表..."
ssh "$SERVER" "pm2 save"

echo "✅  部署完成"

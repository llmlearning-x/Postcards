# assets-archive

存放当前不参与 APK 打包但需保留的设计/历史素材。

UniApp 只会把 `src/static/` 下的内容打进 APK，本目录在 `src/` 外，因此不影响包体积。

## 目录说明

- `stamps/` — 早期本地邮票图（5 个系列共 42MB）。现已改为后端统一提供（项目记忆：邮票图片由后端统一提供，部署到华为云服务器），代码无引用。
- `icons/` — App 图标设计源文件（`app-icon-primary.png` 等）。实际打包用的图标在 `unpackage/res/icons/` 下。
- `previews/` — 项目预览截图，非运行时资源。
- `branding/` — 品牌设计资源，目前代码无引用。

如需重新启用某项，把对应子目录移回 `src/static/` 即可。

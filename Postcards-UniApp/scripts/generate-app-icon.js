/**
 * 从 Phosphor Icons 生成应用图标 (1024x1024)
 * 使用 @phosphor-icons/core 中的 mailbox.svg
 */
const fs = require('fs')
const path = require('path')
const sharp = require('sharp')

const ASSETS_DIR = path.join(__dirname, '../node_modules/@phosphor-icons/core/assets/regular')
const OUTPUT_PATH = path.join(__dirname, '../src/static/logo.png')

const SIZE = 1024
const ICON_SIZE = 600
const BG_COLOR = '#2E7D58'
const ICON_COLOR = '#FFFFFF'

async function generate() {
  const svgPath = path.join(ASSETS_DIR, 'mailbox.svg')
  let svgContent = fs.readFileSync(svgPath, 'utf-8')
  svgContent = svgContent.replace(/currentColor/g, ICON_COLOR)

  // 渲染 SVG 图标
  const iconBuffer = await sharp(Buffer.from(svgContent), { density: 300 })
    .resize(ICON_SIZE, ICON_SIZE, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png()
    .toBuffer()

  // 创建圆角背景
  const bgBuffer = await sharp({
    create: {
      width: SIZE,
      height: SIZE,
      channels: 4,
      background: BG_COLOR,
    },
  })
    .png()
    .toBuffer()

  // 合成图标到背景中心
  await sharp(bgBuffer)
    .composite([{
      input: iconBuffer,
      gravity: 'center',
    }])
    .png()
    .toFile(OUTPUT_PATH)

  console.log(`✅ App icon generated: ${OUTPUT_PATH}`)
}

generate().catch(err => {
  console.error('❌ Failed:', err)
  process.exit(1)
})

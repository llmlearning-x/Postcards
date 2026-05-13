/**
 * 从 Phosphor Icons 导出 TabBar PNG 图标
 * 不手写 SVG，使用 @phosphor-icons/core 现成资产
 */
const fs = require('fs')
const path = require('path')
const sharp = require('sharp')

const ASSETS_DIR = path.join(__dirname, '../node_modules/@phosphor-icons/core/assets/regular')
const OUTPUT_DIR = path.join(__dirname, '../src/static/tabbar')

const ICONS = [
  { name: 'home', source: 'house.svg' },
  { name: 'timeline', source: 'calendar.svg' },
  { name: 'record', source: 'pencil-simple.svg' },
  { name: 'map', source: 'map-trifold.svg' },
  { name: 'profile', source: 'user.svg' },
]

const COLORS = {
  normal: '#999999',
  selected: '#2E7D58',
}

const SIZE = 81

async function generate() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true })
  }

  for (const icon of ICONS) {
    const svgPath = path.join(ASSETS_DIR, icon.source)
    let svgContent = fs.readFileSync(svgPath, 'utf-8')

    for (const [state, color] of Object.entries(COLORS)) {
      // 替换 currentColor 为具体颜色值
      const coloredSvg = svgContent.replace(/currentColor/g, color)
      const outputPath = path.join(OUTPUT_DIR, `${icon.name}-${state}.png`)

      await sharp(Buffer.from(coloredSvg), { density: 300 })
        .resize(SIZE, SIZE, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
        .png()
        .toFile(outputPath)

      console.log(`✅ ${icon.name}-${state}.png`)
    }
  }

  console.log('\n🎉 TabBar 图标全部生成完毕')
}

generate().catch(err => {
  console.error('❌ 生成失败:', err)
  process.exit(1)
})

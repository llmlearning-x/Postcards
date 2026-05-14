// 旅笺 — design canvas composition

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "primary": "#3C604D",
  "accent": "#A43B2D",
  "showAnnotations": true
}/*EDITMODE-END*/;

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);

  // Live-apply primary / accent overrides to tokens
  React.useEffect(() => {
    window.T.green = t.primary;
    window.T.red = t.accent;
    // re-derive deep + soft from primary
    window.T.greenDeep = shade(t.primary, -10);
    window.T.greenSoft = tint(t.primary, 92);
    // force redraw by triggering a state bump
    setNonce(n => n + 1);
  }, [t.primary, t.accent]);

  const [, setNonce] = React.useState(0);

  return (
    <>
      <DesignCanvas>
        <DCSection id="overview" title="旅笺 · POSTCARDS" subtitle="复古邮政 × 现代旅行 · 高保真原型设计稿  ·  5 主 Tab + 3 子页面">
          <DCArtboard id="launch" label="00 · 启动页 Launch" width={390} height={844}>
            <ScreenLaunch/>
          </DCArtboard>
        </DCSection>

        <DCSection id="tabs" title="主 Tab · Main Tabs" subtitle="底部导航的 5 个主页面，遵循统一头部 / 卡片 / Tab Bar 设计语言">
          <DCArtboard id="home" label="01 · 首页 Home" width={390} height={844}>
            <ScreenHome active="home" setActive={()=>{}} onOpenDetail={()=>{}}/>
          </DCArtboard>
          <DCArtboard id="timeline" label="02 · 时间轴 Timeline" width={390} height={844}>
            <ScreenTimeline setActive={()=>{}} onOpenDetail={()=>{}}/>
          </DCArtboard>
          <DCArtboard id="record" label="03 · 记录 Record" width={390} height={844}>
            <ScreenRecord setActive={()=>{}}/>
          </DCArtboard>
          <DCArtboard id="map" label="04 · 地图 Map" width={390} height={844}>
            <ScreenMap setActive={()=>{}}/>
          </DCArtboard>
          <DCArtboard id="profile" label="05 · 我的 Profile" width={390} height={844}>
            <ScreenProfile setActive={()=>{}}/>
          </DCArtboard>
        </DCSection>

        <DCSection id="sub" title="子页面 · Sub Pages" subtitle="详情、编辑、表单 — 从主 Tab 进入的二级页面">
          <DCArtboard id="detail" label="06 · 明信片详情 Detail" width={390} height={844}>
            <ScreenDetail/>
          </DCArtboard>
          <DCArtboard id="edit" label="07 · 编辑明信片 Edit" width={390} height={844}>
            <ScreenEdit/>
          </DCArtboard>
          <DCArtboard id="album" label="08 · 集邮册 Album" width={390} height={844}>
            <ScreenAlbum/>
          </DCArtboard>
        </DCSection>

        <DCSection id="stamps" title="邮票与明信片 · Stamps & Postcards" subtitle="6 款主题邮票（穿孔纸 + 独特图案 + 面值） · 明信片正反面变体">
          <DCArtboard id="stamp-collection" label="邮票总集 · 5 Series" width={560} height={1700}>
            <StampSheet/>
          </DCArtboard>
          <DCArtboard id="postcard-fronts" label="明信片正面 · Fronts" width={420} height={680}>
            <PostcardFronts/>
          </DCArtboard>
          <DCArtboard id="postcard-back" label="明信片背面 · Back" width={520} height={360}>
            <PostcardBack/>
          </DCArtboard>
        </DCSection>

        <DCSection id="system" title="设计系统 · Design System" subtitle="色彩、字体、邮票、组件标注">
          <DCArtboard id="ds" label="设计 Tokens" width={840} height={1100}>
            <DesignSystem/>
          </DCArtboard>
        </DCSection>
      </DesignCanvas>

      <TweaksPanel title="Tweaks">
        <TweakSection label="品牌色 Brand Colors">
          <TweakColor label="主色 · 邮政绿" value={t.primary}
            options={['#3C604D', '#2C4A3A', '#1F4F3A', '#4A6F2F', '#0E5E5C', '#5B4F76']}
            onChange={v=>setTweak('primary', v)}/>
          <TweakColor label="辅色 · 邮戳红" value={t.accent}
            options={['#A43B2D', '#7B2D24', '#C4753A', '#5B4F76', '#1F4B66']}
            onChange={v=>setTweak('accent', v)}/>
        </TweakSection>
        <TweakSection label="展示 Display">
          <TweakToggle label="显示组件标注" value={t.showAnnotations}
            onChange={v=>setTweak('showAnnotations', v)}/>
        </TweakSection>
      </TweaksPanel>
    </>
  );
}

// hex utilities
function shade(hex, amt) {
  // amt negative = darker
  const n = parseInt(hex.slice(1), 16);
  let r = (n >> 16) & 255, g = (n >> 8) & 255, b = n & 255;
  r = Math.max(0, Math.min(255, r + amt));
  g = Math.max(0, Math.min(255, g + amt));
  b = Math.max(0, Math.min(255, b + amt));
  return '#' + ((r<<16)|(g<<8)|b).toString(16).padStart(6,'0');
}
function tint(hex, pct) {
  const n = parseInt(hex.slice(1), 16);
  let r = (n >> 16) & 255, g = (n >> 8) & 255, b = n & 255;
  const k = pct/100;
  r = Math.round(r + (255-r)*k);
  g = Math.round(g + (255-g)*k);
  b = Math.round(b + (255-b)*k);
  return '#' + ((r<<16)|(g<<8)|b).toString(16).padStart(6,'0');
}

// ───────────────────────── DESIGN SYSTEM PANEL ─────────────────────────
function DesignSystem() {
  const palette = [
    { label: '邮政绿 · Postal Green', code: T.green, role: '主按钮 · Tab · 头部' },
    { label: '邮政绿深 · Deep', code: T.greenDeep, role: '渐变终点 · 强调' },
    { label: '邮戳红 · Postmark', code: T.red, role: '收藏 · 起点 · 警告' },
    { label: '纸张 · Paper', code: T.bg, role: '全局页面背景' },
    { label: '卡片 · Card', code: T.card, role: '内容卡片' },
    { label: '邮票纸 · Stamp Paper', code: T.paper, role: '邮票底纹' },
    { label: '分割线 · Divider', code: T.divider, role: '细线 · 边界' },
    { label: '主文字 · Ink', code: T.ink, role: '标题 · 重要文字' },
  ];
  return (
    <div style={{
      width:'100%', height:'100%', background: T.bg, padding: 32,
      fontFamily: F.sans, color: T.ink, overflow:'auto', boxSizing:'border-box',
    }}>
      <style>{`div::-webkit-scrollbar{display:none}`}</style>
      {/* header */}
      <div style={{ display:'flex', alignItems:'flex-end', justifyContent:'space-between',
        borderBottom:`1px solid ${T.divider}`, paddingBottom: 16 }}>
        <div>
          <div style={{ ...labelStyle, color: T.green, marginBottom: 6 }}>DESIGN SYSTEM · v1.0</div>
          <div style={{ fontFamily: F.display, fontWeight: 400, fontSize: 32, letterSpacing: -0.5, lineHeight: 1 }}>旅笺</div>
          <div style={{ fontFamily: F.serif, fontStyle:'italic', fontSize: 14, color: T.body, marginTop: 8 }}>
            复古邮政 × 现代旅行 · A refined postal language for travel journaling
          </div>
        </div>
        <div style={{ ...labelStyle, textAlign:'right' }}>
          <div>CN — 839204</div>
          <div style={{ marginTop: 4 }}>ISSUE · 2024</div>
        </div>
      </div>

      {/* colors */}
      <DSBlock title="01 · 色彩 · Palette" sub="低饱和 · 温暖纸感 · 印刷油墨配色">
        <div style={{ display:'grid', gridTemplateColumns:'repeat(4, 1fr)', gap: 12 }}>
          {palette.map(c => (
            <div key={c.label} style={{ background: T.card, borderRadius: 4, overflow:'hidden', border:`1px solid ${T.divider}` }}>
              <div style={{ height: 64, background: c.code, position:'relative' }}>
                {c.code === T.bg && <div style={{ position:'absolute', inset: 0, border: `1px dashed ${T.divider}` }}/>}
              </div>
              <div style={{ padding: '10px 12px' }}>
                <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 13 }}>{c.label}</div>
                <div style={{ ...labelStyle, fontSize: 9, marginTop: 4 }}>{c.code}</div>
                <div style={{ fontSize: 11, color: T.body, marginTop: 4, fontFamily: F.serif }}>{c.role}</div>
              </div>
            </div>
          ))}
        </div>
      </DSBlock>

      {/* type */}
      <DSBlock title="02 · 字体 · Typography" sub="Fraunces 显示 · Noto Serif SC 正文 · IBM Plex Mono 标签">
        <div style={{ background: T.card, padding: 24, borderRadius: 4, border:`1px solid ${T.divider}` }}>
          <TypeRow tag="DISPLAY · 显示" font={F.display} size={36} weight={400} text="旅笺"/>
          <TypeRow tag="H1 · 一级标题" font={F.display} size={26} weight={500} text="江南水乡之旅"/>
          <TypeRow tag="H2 · 二级标题" font={F.display} size={19} weight={500} text="最近明信片"/>
          <TypeRow tag="BODY ITALIC · 手记" font={F.serif} italic size={14} weight={400} text="断桥不断，情意绵绵。和心爱的人一起，看落日。"/>
          <TypeRow tag="BODY · 正文" font={F.serif} size={14} weight={400} text="按日期倒序展示所有明信片"/>
          <TypeRow tag="NUMERAL · 数字" font={F.display} size={28} weight={400} text="09  ·  04  ·  06"/>
          <TypeRow tag="LABEL · 小标签" font={F.mono} size={11} weight={400} text="POSTCARD · CN — 839204"/>
        </div>
      </DSBlock>

      {/* stamps */}
      <DSBlock title="03 · 邮票 · Stamps" sub="五个系列 · 20 款主题 · 穿孔纸 · 单色油墨">
        <div style={{ background: T.card, padding: 20, borderRadius: 4, border:`1px solid ${T.divider}`,
          display:'flex', flexDirection:'column', gap: 18 }}>
          {['I','III','IV','V'].map(sid => {
            const kinds = Object.keys(T.stamps).filter(k => T.stamps[k].series === sid);
            const meta = { I:'旅行 TRAVEL', III:'四季 SEASONS', IV:'节气 SOLAR TERMS', V:'远方 FAR LANDS' }[sid];
            return (
              <div key={sid}>
                <div style={{ ...labelStyle, fontSize: 9, color: T.green, marginBottom: 8 }}>SERIES · {sid}  ·  {meta}</div>
                <div style={{ display:'flex', gap: 14, flexWrap:'wrap' }}>
                  {kinds.map(k => (
                    <div key={k} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap: 4, width: 64 }}>
                      <Stamp kind={k} size={48}/>
                      <div style={{ fontFamily: F.display, fontSize: 11, fontWeight: 500, marginTop: 2 }}>{T.stamps[k].name}</div>
                      <div style={{ ...labelStyle, fontSize: 7 }}>{T.stamps[k].name_en}</div>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </DSBlock>

      {/* components */}
      <DSBlock title="04 · 组件 · Components" sub="按钮 · 卡片 · 标签 · 表单">
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 14 }}>
          <CompCard label="主按钮 · PRIMARY">
            <button style={{
              all:'unset', cursor:'pointer', textAlign:'center', display:'block',
              background: T.green, color:'#F4EFE5', borderRadius: 6,
              padding: '14px 0', fontWeight: 500, fontSize: 14,
              letterSpacing: 6, fontFamily: F.display, width:'100%',
            }}>寄出明信片 ›</button>
          </CompCard>
          <CompCard label="边框按钮 · GHOST">
            <button style={btnGhost}>{Ico.pin(12)}<span style={{marginLeft:6}}>定位</span></button>
          </CompCard>
          <CompCard label="圆角 · RADII">
            <div style={{ display:'flex', gap: 10 }}>
              <div style={{ flex:1, height: 42, background: T.bg, borderRadius: 4, border:`1px solid ${T.divider}`, display:'flex', alignItems:'center', justifyContent:'center', fontFamily: F.mono, fontSize: 10, color: T.body, letterSpacing: 1 }}>r4</div>
              <div style={{ flex:1, height: 42, background: T.bg, borderRadius: 6, border:`1px solid ${T.divider}`, display:'flex', alignItems:'center', justifyContent:'center', fontFamily: F.mono, fontSize: 10, color: T.body, letterSpacing: 1 }}>r6</div>
              <div style={{ flex:1, height: 42, background: T.bg, borderRadius: 99, border:`1px solid ${T.divider}`, display:'flex', alignItems:'center', justifyContent:'center', fontFamily: F.mono, fontSize: 10, color: T.body, letterSpacing: 1 }}>r99</div>
            </div>
          </CompCard>
          <CompCard label="状态 · TAGS">
            <div style={{ display:'flex', gap: 8, flexWrap:'wrap' }}>
              <Tag bg={T.greenSoft} fg={T.green}>ONGOING · 进行中</Tag>
              <Tag bg="#F0EEEA" fg={T.body}>POSTED · 已寄出</Tag>
              <Tag bg="#E7EEF3" fg="#1F4B66">DRAFT · 草稿</Tag>
              <Tag bg={T.redSoft} fg={T.red}>LOVED · 收藏</Tag>
            </div>
          </CompCard>
        </div>
      </DSBlock>

      {/* spacing */}
      <DSBlock title="05 · 间距与圆角 · Spacing & Rhythm" sub="基础单位 4px · 卡片半径 6px · 大圆角 12px">
        <div style={{
          background: T.card, padding: 20, borderRadius: 4, border:`1px solid ${T.divider}`,
          display:'flex', gap: 20, alignItems:'center', flexWrap:'wrap',
        }}>
          {[4, 8, 12, 16, 20, 24, 32].map(n => (
            <div key={n} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap: 6 }}>
              <div style={{ width: n, height: n, background: T.green, borderRadius: 2 }}/>
              <div style={{ ...labelStyle, fontSize: 9 }}>{n}px</div>
            </div>
          ))}
        </div>
      </DSBlock>
    </div>
  );
}

function DSBlock({ title, sub, children }) {
  return (
    <div style={{ marginTop: 28 }}>
      <div style={{ display:'flex', alignItems:'flex-end', justifyContent:'space-between', marginBottom: 14 }}>
        <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 16, color: T.ink }}>{title}</div>
        <div style={{ ...labelStyle, fontSize: 9 }}>{sub}</div>
      </div>
      {children}
    </div>
  );
}
function TypeRow({ tag, font, size, weight, text, italic }) {
  return (
    <div style={{ padding: '14px 0', borderBottom: `1px solid ${T.divider}`, display:'flex', alignItems:'baseline', gap: 24 }}>
      <div style={{ width: 160, ...labelStyle, fontSize: 9 }}>{tag}</div>
      <div style={{ fontFamily: font, fontSize: size, fontWeight: weight, color: T.ink, fontStyle: italic?'italic':'normal', letterSpacing: size > 24 ? -0.5 : 0.1 }}>{text}</div>
    </div>
  );
}
function CompCard({ label, children }) {
  return (
    <div style={{ background: T.card, padding: 16, borderRadius: 4, border:`1px solid ${T.divider}` }}>
      <div style={{ ...labelStyle, fontSize: 9, marginBottom: 12 }}>{label}</div>
      {children}
    </div>
  );
}
function Tag({ bg, fg, children }) {
  return <span style={{ padding:'4px 10px', borderRadius: 99, background: bg, color: fg, fontFamily: F.mono, fontSize: 9, fontWeight: 500, letterSpacing: 1 }}>{children}</span>;
}

// mount
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App/>);

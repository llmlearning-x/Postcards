// 旅笺 · Design Tokens v2 — refined editorial / postal aesthetic
// Inspired by: Japan Post stamp art · Kinfolk · Aesop signage · Muji ·
// the kind of typography you'd see in a quiet travel journal.

const T = {
  // brand — deeper, lower-chroma postal greens
  green:     '#3C604D',   // primary postal — refined, less neon
  greenDeep: '#2C4A3A',   // gradient terminus / pressed
  greenSoft: '#E8EEE9',   // 8% tint surface
  greenInk:  '#1F3329',   // text-on-light when accenting

  // accent — vermillion postmark / hand-stamp red
  red:       '#A43B2D',
  redSoft:   '#F4E2DE',

  alive:     '#5E8C4F',   // a quiet "in progress" green (not neon)

  // surface — warm, tactile
  bg:        '#F4EFE5',   // base paper, slightly cooler & cleaner than before
  card:      '#FBF8F1',   // off-white card, never pure white
  cardWarm:  '#F8F3E7',   // alt card for variety
  paper:     '#EDE5D1',   // stamp paper / inset surface
  divider:   '#E0D8C4',   // hairlines
  rule:      '#D5CCB2',   // stronger rule color when needed

  // text
  ink:       '#222019',   // warm near-black
  body:      '#5C5648',   // body / secondary
  mute:      '#8E8775',   // captions
  whisper:   '#B5AE9B',   // tertiary, almost decorative

  // stamp palette — desaturated, color-of-vintage-printing-ink
  stamps: {
    // Series I · 旅行 TRAVEL
    classic: { name: '经典', name_en: 'CLASSIC', color: '#A43B2D', series: 'I' },
    nature:  { name: '自然', name_en: 'NATURE',  color: '#3C604D', series: 'I' },
    culture: { name: '文化', name_en: 'CULTURE', color: '#5B4F76', series: 'I' },
    city:    { name: '城市', name_en: 'CITY',    color: '#1F4B66', series: 'I' },
    ocean:   { name: '海洋', name_en: 'OCEAN',   color: '#3A7791', series: 'I' },
    sunset:  { name: '日落', name_en: 'SUNSET',  color: '#C4753A', series: 'I' },
    // Series III · 四季 SEASONS
    spring:  { name: '春樱', name_en: 'SPRING',  color: '#B26573', series: 'III' },
    summer:  { name: '夏荷', name_en: 'SUMMER',  color: '#2F6E5E', series: 'III' },
    autumn:  { name: '秋枫', name_en: 'AUTUMN',  color: '#B25A30', series: 'III' },
    winter:  { name: '冬雪', name_en: 'WINTER',  color: '#6A85A0', series: 'III' },
    // Series IV · 节气 SOLAR TERMS
    lichun:      { name: '立春', name_en: 'LICHUN',  color: '#6B8E4E', series: 'IV' },
    qingming:    { name: '清明', name_en: 'QINGMING',color: '#7B946F', series: 'IV' },
    xiazhi:      { name: '夏至', name_en: 'XIAZHI',  color: '#C49432', series: 'IV' },
    liqiu:       { name: '立秋', name_en: 'LIQIU',   color: '#9C6F2B', series: 'IV' },
    shuangjiang: { name: '霜降', name_en: 'SHUANG',  color: '#7E97A8', series: 'IV' },
    dahan:       { name: '大寒', name_en: 'DAHAN',   color: '#3D5266', series: 'IV' },
    // Series V · 远方 FAR LANDS
    prairie:  { name: '草原', name_en: 'PRAIRIE',  color: '#7A8540', series: 'V' },
    snowpeak: { name: '雪山', name_en: 'SNOWPEAK', color: '#5A7585', series: 'V' },
    desert:   { name: '沙漠', name_en: 'DESERT',   color: '#B07A3E', series: 'V' },
    island:   { name: '海岛', name_en: 'ISLAND',   color: '#2E7689', series: 'V' },
  },
};

const F = {
  display: '"Fraunces", "Noto Serif SC", "Songti SC", "宋体", Georgia, serif',
  serif:   '"Noto Serif SC", "Fraunces", "Songti SC", "宋体", Georgia, serif',
  sans:    '-apple-system, "PingFang SC", "Hiragino Sans GB", system-ui, sans-serif',
  mono:    '"IBM Plex Mono", "SF Mono", Menlo, monospace',
};

// shared style fragments — used by labels everywhere
const labelStyle = {
  fontFamily: F.mono, fontSize: 10, letterSpacing: 2.4,
  color: T.mute, textTransform: 'uppercase', fontWeight: 400,
};

// ─────────── ICONS ───────────
// Postal-themed wherever possible — envelopes, mailboxes, postmarks, etc.
const Ico = {
  // tabs — all postal
  home: (s=22)=> ( // 收件箱 envelope w/ down arrow
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <rect x="3.5" y="7.5" width="17" height="12.5" rx="1.4" stroke="currentColor" strokeWidth="1.4"/>
      <path d="M3.5 9.2L12 14.5l8.5-5.3" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
      <path d="M12 3.5v3.5M10 5.2L12 7l2-1.8" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  timeline: (s=22)=> ( // 投递日志 stacked letters + clock
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <rect x="3.5" y="11" width="13" height="9" rx="1" stroke="currentColor" strokeWidth="1.4"/>
      <path d="M3.5 12.5L10 16l6.5-3.5" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
      <rect x="5" y="7.5" width="13" height="2" rx="0.6" stroke="currentColor" strokeWidth="1.2"/>
      <rect x="6.5" y="4.5" width="11" height="1.6" rx="0.6" stroke="currentColor" strokeWidth="1.1" opacity="0.7"/>
    </svg>
  ),
  plus: (s=22)=> ( // 寄件 envelope w/ up arrow
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <rect x="3.5" y="9" width="17" height="11" rx="1.4" stroke="currentColor" strokeWidth="1.4"/>
      <path d="M3.5 10.5L12 16l8.5-5.5" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/>
      <path d="M12 7V3M10 5l2-2 2 2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  map: (s=22)=> ( // 邮路 globe with airmail crossing line
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="8.5" stroke="currentColor" strokeWidth="1.4"/>
      <path d="M3.5 12h17" stroke="currentColor" strokeWidth="1.4"/>
      <path d="M12 3.5c2.4 3 2.4 14 0 17M12 3.5c-2.4 3-2.4 14 0 17" stroke="currentColor" strokeWidth="1"/>
      <path d="M5 6L20 18" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeDasharray="2 2.4"/>
    </svg>
  ),
  user: (s=22)=> ( // 我的 mailbox post
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M5.5 9c0-2.2 1.8-4 4-4h5.5c2.2 0 4 1.8 4 4v6h-13.5V9Z" stroke="currentColor" strokeWidth="1.4"/>
      <path d="M12 15v6" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
      <circle cx="9.5" cy="11" r="0.9" fill="currentColor"/>
      <path d="M14 9h3" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round"/>
    </svg>
  ),
  // others
  heart: (s=18, fill='none')=> <svg width={s} height={s} viewBox="0 0 24 24" fill={fill}><path d="M12 21s-7-4.5-9.5-9.2C.7 7.8 3.2 4 7 4c2 0 3.6 1.1 5 3 1.4-1.9 3-3 5-3 3.8 0 6.3 3.8 4.5 7.8C19 16.5 12 21 12 21Z" stroke="currentColor" strokeWidth="1.3" strokeLinejoin="round"/></svg>,
  pin: (s=16)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M12 22s6-7 6-12a6 6 0 1 0-12 0c0 5 6 12 6 12Z" stroke="currentColor" strokeWidth="1.4"/><circle cx="12" cy="10" r="2.2" stroke="currentColor" strokeWidth="1.4"/></svg>,
  globe: (s=16)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="8.5" stroke="currentColor" strokeWidth="1.4"/><path d="M3.5 12h17M12 3.5c2.5 3 2.5 14 0 17M12 3.5c-2.5 3-2.5 14 0 17" stroke="currentColor" strokeWidth="1.4"/></svg>,
  camera: (s=22)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M3.5 8h3l2-2h7l2 2h3v10.5H3.5V8Z" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/><circle cx="12" cy="13" r="3.4" stroke="currentColor" strokeWidth="1.4"/></svg>,
  stamp: (s=18)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M5.5 5.5h13v13h-13z" stroke="currentColor" strokeWidth="1.4" strokeDasharray="1.5 2"/><circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="1.4"/></svg>,
  edit: (s=16)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M4 20h4l11-11-4-4L4 16v4Zm10-14 4 4" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/></svg>,
  share: (s=18)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><circle cx="18" cy="5.5" r="2.2" stroke="currentColor" strokeWidth="1.4"/><circle cx="6" cy="12" r="2.2" stroke="currentColor" strokeWidth="1.4"/><circle cx="18" cy="18.5" r="2.2" stroke="currentColor" strokeWidth="1.4"/><path d="M8 11l8-4.5M8 13l8 4.5" stroke="currentColor" strokeWidth="1.4"/></svg>,
  clock: (s=16)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="8.5" stroke="currentColor" strokeWidth="1.4"/><path d="M12 7v5l3.5 2" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/></svg>,
  chev: (s=14, dir='r')=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none" style={{ transform: dir==='l'?'rotate(180deg)':dir==='d'?'rotate(90deg)':dir==='u'?'rotate(-90deg)':'none' }}><path d="M9 6l6 6-6 6" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  back: (s=22)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  more: (s=22)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="5.5" r="1.3"/><circle cx="12" cy="12" r="1.3"/><circle cx="12" cy="18.5" r="1.3"/></svg>,
  flag: (s=16)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M5 21V4m0 0h12l-2 4 2 4H5" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/></svg>,
  rocket: (s=18)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M14 4c4 0 6 2 6 6-2 0-3 .5-4 1.5l-7 7-3-3 7-7C14 7.5 14.5 6.5 14.5 4H14ZM4 20l3-3" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/></svg>,
  check: (s=18)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M5 12l5 5 9-11" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  cal:   (s=18)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><rect x="3.5" y="5.5" width="17" height="15" rx="1.5" stroke="currentColor" strokeWidth="1.4"/><path d="M3.5 9.5h17M8 3.5v4M16 3.5v4" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/></svg>,
  envelope: (s=22)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><rect x="3.5" y="6" width="17" height="13" rx="1.5" stroke="currentColor" strokeWidth="1.4"/><path d="M3.5 8l8.5 6 8.5-6" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round"/></svg>,
  plane: (s=18)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M2.5 13.5L21 5.5l-4.5 15-4-7-7-2Z" stroke="currentColor" strokeWidth="1.3" strokeLinejoin="round"/></svg>,
  truck: (s=18)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><rect x="2" y="8" width="11" height="8" stroke="currentColor" strokeWidth="1.3"/><path d="M13 11h5l3 3v2h-8V11Z" stroke="currentColor" strokeWidth="1.3" strokeLinejoin="round"/><circle cx="6" cy="17.5" r="1.5" stroke="currentColor" strokeWidth="1.3"/><circle cx="17" cy="17.5" r="1.5" stroke="currentColor" strokeWidth="1.3"/></svg>,
  scissors: (s=14)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><circle cx="6" cy="7" r="2.5" stroke="currentColor" strokeWidth="1.3"/><circle cx="6" cy="17" r="2.5" stroke="currentColor" strokeWidth="1.3"/><path d="M8 9l13 9M8 15l13-9" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/></svg>,
  search: (s=18)=> <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><circle cx="11" cy="11" r="6" stroke="currentColor" strokeWidth="1.4"/><path d="M16 16l4 4" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/></svg>,
};

// ─────────── PHOTO PLACEHOLDER (refined) ───────────
// No more raw stripes. Real-feeling landscape gradients with optional
// horizon line + sun, painted with multi-stop linear-gradient + radial,
// finished with a subtle grain overlay and warm vignette. Each "tone"
// looks like a different time-of-day or biome.
function Photo({ label='PHOTO', tone='forest', w='100%', h=160, radius=12, children, code }) {
  const scenes = {
    // forest: dawn over green hills
    forest: {
      bg: 'linear-gradient(180deg, #C9D2B6 0%, #B6C39E 40%, #6E8862 75%, #4F6A4E 100%)',
      sun: { cx: '72%', cy: '34%', glow: '#F4E9C8' },
      horizon: '64%',
    },
    // sand: desert / dunhuang
    sand: {
      bg: 'linear-gradient(180deg, #EAD5A8 0%, #DABC85 50%, #A8855A 100%)',
      sun: { cx: '30%', cy: '40%', glow: '#F8E4B0' },
      horizon: '70%',
    },
    // dusk: temple / chongqing night
    dusk: {
      bg: 'linear-gradient(180deg, #594962 0%, #8E6A78 45%, #C28A78 80%, #6B4258 100%)',
      sun: { cx: '60%', cy: '50%', glow: '#F4C29C' },
      horizon: '72%',
    },
    // river: water / sea
    river: {
      bg: 'linear-gradient(180deg, #BDD0CF 0%, #8DAFB3 50%, #466B72 100%)',
      sun: null, horizon: null,
    },
    // sky
    sky: {
      bg: 'linear-gradient(180deg, #C5D6DE 0%, #97B5C2 60%, #6E92A4 100%)',
      sun: null, horizon: null,
    },
    // dusk2 (rose)
    rose: {
      bg: 'linear-gradient(180deg, #E8C8B8 0%, #C99080 60%, #7A4A4A 100%)',
      sun: { cx: '50%', cy: '38%', glow: '#FBE5C0' },
      horizon: '72%',
    },
    paper: {
      bg: 'linear-gradient(180deg, #ECE3CE 0%, #DBCFB1 100%)',
      sun: null, horizon: null,
    },
  };
  const s = scenes[tone] || scenes.forest;
  // SVG noise for grain
  const grain = "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/><feColorMatrix values='0 0 0 0 0.16 0 0 0 0 0.14 0 0 0 0 0.10 0 0 0 0.12 0'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>\")";
  return (
    <div style={{
      width: w, height: h, borderRadius: radius, overflow: 'hidden',
      background: s.bg, position: 'relative',
    }}>
      {/* sun */}
      {s.sun && (
        <div style={{
          position:'absolute', top: s.sun.cy, left: s.sun.cx,
          width: h*0.45, height: h*0.45, borderRadius: 99,
          transform: 'translate(-50%, -50%)',
          background: `radial-gradient(circle, ${s.sun.glow} 0%, transparent 65%)`,
          mixBlendMode: 'screen', opacity: .85,
        }}/>
      )}
      {/* horizon strip */}
      {s.horizon && (
        <div style={{ position:'absolute', left:0, right:0, top: s.horizon,
          height: 1, background: 'rgba(0,0,0,0.18)' }}/>
      )}
      {/* grain */}
      <div style={{ position:'absolute', inset:0,
        backgroundImage: grain, backgroundSize: '160px 160px',
        mixBlendMode: 'multiply', opacity: .55, pointerEvents:'none' }}/>
      {/* vignette */}
      <div style={{ position:'absolute', inset:0,
        boxShadow: 'inset 0 0 60px rgba(20,18,12,0.22)', pointerEvents:'none' }}/>
      {/* monospaced corner label — small, refined */}
      <div style={{
        position:'absolute', left: 10, bottom: 10,
        fontFamily: F.mono, fontSize: 9, letterSpacing: 2,
        color: 'rgba(255,250,238,0.85)',
        textShadow: '0 1px 2px rgba(0,0,0,0.35)',
        textTransform: 'uppercase',
      }}>{label}</div>
      {code && (
        <div style={{
          position:'absolute', right: 10, top: 10,
          fontFamily: F.mono, fontSize: 9, letterSpacing: 2,
          color: 'rgba(255,250,238,0.7)',
          textShadow: '0 1px 2px rgba(0,0,0,0.35)',
        }}>{code}</div>
      )}
      {children}
    </div>
  );
}

// ─────────── EDITORIAL HEADER (paper, not slab) ───────────
// Replaces the heavy green gradient with a refined paper masthead:
// hairline above, small caps kicker, large serif title, soft tonal rule below.
// Pages that need brand-color emphasis can pass tone='green'.
function PostalHeader({ title, subtitle, kicker, tone='paper', children, right }) {
  const onGreen = tone === 'green';
  return (
    <div style={{
      position: 'relative',
      background: onGreen ? `linear-gradient(180deg, ${T.green}, ${T.greenDeep})` : T.bg,
      color: onGreen ? '#F4EFE5' : T.ink,
      paddingTop: 64, paddingLeft: 24, paddingRight: 24, paddingBottom: 22,
      borderBottom: onGreen ? 'none' : `1px solid ${T.divider}`,
    }}>
      {/* tiny perforation accent at top — postal cue */}
      {!onGreen && (
        <div aria-hidden style={{
          position:'absolute', top: 54, left: 24, right: 24, height: 1,
          backgroundImage: `repeating-linear-gradient(90deg, ${T.rule} 0 4px, transparent 4px 8px)`,
        }}/>
      )}
      <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start', gap: 12 }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          {kicker && (
            <div style={{
              ...labelStyle,
              color: onGreen ? 'rgba(244,239,229,0.65)' : T.green,
              marginBottom: 10,
            }}>{kicker}</div>
          )}
          <div style={{
            fontFamily: F.display, fontWeight: 400,
            fontSize: 30, lineHeight: 1.1,
            letterSpacing: -0.5,
            color: onGreen ? '#F4EFE5' : T.ink,
          }}>{title}</div>
          {subtitle && (
            <div style={{
              marginTop: 8, fontFamily: F.serif, fontSize: 13, lineHeight: 1.5,
              color: onGreen ? 'rgba(244,239,229,0.75)' : T.body,
            }}>{subtitle}</div>
          )}
        </div>
        {right}
      </div>
      {children}
    </div>
  );
}

// ─────────── TAB BAR (refined — no center FAB, all equal) ───────────
function TabBar({ active='home', onChange }) {
  const items = [
    { k: 'home', icon: Ico.home, label: '首页' },
    { k: 'timeline', icon: Ico.timeline, label: '时间轴' },
    { k: 'record', icon: Ico.plus, label: '记录' },
    { k: 'map', icon: Ico.map, label: '地图' },
    { k: 'profile', icon: Ico.user, label: '我的' },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0,
      height: 78, background: 'rgba(251,248,241,0.92)',
      backdropFilter: 'blur(20px) saturate(120%)',
      WebkitBackdropFilter: 'blur(20px) saturate(120%)',
      borderTop: `1px solid ${T.divider}`,
      display: 'flex', alignItems: 'flex-start', justifyContent: 'space-around',
      padding: '12px 8px 0', zIndex: 30,
    }}>
      {items.map(it => {
        const on = it.k === active;
        return (
          <button key={it.k} onClick={()=>onChange?.(it.k)} style={{
            all:'unset', cursor:'pointer', flex:1, display:'flex', flexDirection:'column',
            alignItems:'center', gap: 5,
            color: on ? T.green : T.mute,
            fontSize: 10, fontWeight: 500, letterSpacing: 1,
          }}>
            <span style={{ position:'relative' }}>
              {it.icon(20)}
              {on && <span style={{
                position:'absolute', bottom: -6, left: '50%', transform: 'translateX(-50%)',
                width: 4, height: 4, borderRadius: 99, background: T.green,
              }}/>}
            </span>
            <span>{it.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ─────────── STAT CARD ───────────
// Refined: no shadow, hairline border, more whitespace, mono labels.
function StatCard({ icon, n, label, color = T.green, compact=false }) {
  return (
    <div style={{
      flex: 1, background: T.card, borderRadius: 10,
      padding: compact ? '12px 8px' : '16px 12px',
      display:'flex', flexDirection:'column', alignItems:'center', gap: 6,
      border: `1px solid ${T.divider}`,
    }}>
      <div style={{ color, opacity: .8 }}>{icon}</div>
      <div style={{
        fontFamily: F.display, fontSize: compact ? 22 : 28, fontWeight: 400,
        color: T.ink, lineHeight: 1, letterSpacing: -0.5,
      }}>{n}</div>
      <div style={{
        fontFamily: F.mono, fontSize: 9, color: T.mute,
        letterSpacing: 2, textTransform: 'uppercase',
      }}>{label}</div>
    </div>
  );
}

// ─────────── POSTCARD ROW (list item) ───────────
// Now styled as a delivered letter: photo + serif title + city + tiny postmark
// + a small stamp on the right edge so every row reads as "postal".
function PostcardRow({ p, onFav, compact }) {
  const stamp = p.stamp || 'classic';
  return (
    <div style={{
      display:'flex', gap: 12, padding: compact ? 10 : 12,
      background: T.card, borderRadius: 4,
      border: `1px solid ${T.divider}`,
      position:'relative', alignItems:'stretch',
    }}>
      <Photo label={(p.locLabel || p.location)} tone={p.tone || 'forest'}
        w={compact ? 64 : 72} h={compact ? 64 : 72} radius={3}/>
      <div style={{ flex:1, minWidth:0, display:'flex', flexDirection:'column', justifyContent:'center' }}>
        <div style={{ display:'flex', alignItems:'center', gap: 6 }}>
          <span style={{ ...labelStyle, fontSize: 8, color: T.mute }}>{(p.city || 'CN').toUpperCase()} · {p.date || '05·10'}</span>
        </div>
        <div style={{
          fontFamily: F.display, fontSize: 16, fontWeight: 500,
          color: T.ink, lineHeight: 1.1, letterSpacing: 0.2,
          marginTop: 4,
        }}>{p.location}</div>
        <div style={{ fontSize: 12, color: T.body, marginTop: 4,
          overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap',
          fontFamily: F.serif, fontStyle: 'italic',
        }}>"{p.note}"</div>
      </div>
      {/* right edge — stamp + heart */}
      <div style={{
        display:'flex', flexDirection:'column', alignItems:'flex-end', justifyContent:'space-between',
        gap: 6, paddingLeft: 6,
      }}>
        <button onClick={onFav} style={{
          all:'unset', cursor:'pointer',
          color: p.fav ? T.red : T.whisper,
        }}>{Ico.heart(15, p.fav ? T.red : 'none')}</button>
        <Stamp kind={stamp} size={26} rotate={2}/>
      </div>
    </div>
  );
}

// ─────────── STAMP — refined, Japan-post style ───────────
// Perforated paper + colored interior + scene. No "¥1.20" / "CHINA·POST"
// noise — just a tiny year strip at the bottom. Smaller proportions.
function Stamp({ kind='classic', size=44, rotate=0 }) {
  const s = T.stamps[kind];
  const w = size, h = size * 1.22;
  const perfR = Math.max(1.4, size * 0.042);
  const perfsX = 7, perfsY = 9;
  const dxs = Array.from({length: perfsX}, (_,i) => (i+0.5) * (w / perfsX));
  const dys = Array.from({length: perfsY}, (_,i) => (i+0.5) * (h / perfsY));
  const pad = perfR + 1.5;
  return (
    <svg viewBox={`0 0 ${w} ${h}`} width={w} height={h}
      style={{ display:'block', transform: `rotate(${rotate}deg)`,
        filter: 'drop-shadow(0 1.5px 2px rgba(30,25,15,0.18))' }}>
      <defs>
        <mask id={`m-${kind}-${size}`}>
          <rect x="0" y="0" width={w} height={h} fill="#fff"/>
          {dxs.map((x,i)=>(<circle key={'t'+i} cx={x} cy="0" r={perfR} fill="#000"/>))}
          {dxs.map((x,i)=>(<circle key={'b'+i} cx={x} cy={h} r={perfR} fill="#000"/>))}
          {dys.map((y,i)=>(<circle key={'l'+i} cx="0" cy={y} r={perfR} fill="#000"/>))}
          {dys.map((y,i)=>(<circle key={'r'+i} cx={w} cy={y} r={perfR} fill="#000"/>))}
        </mask>
      </defs>
      <g mask={`url(#m-${kind}-${size})`}>
        {/* paper */}
        <rect x="0" y="0" width={w} height={h} fill={T.paper}/>
        {/* tiny paper grain */}
        <rect x="0" y="0" width={w} height={h} fill="url(#paperGrain)" opacity="0.0"/>
        {/* colored interior */}
        <rect x={pad} y={pad} width={w - pad*2} height={h - pad*2} fill={s.color}/>
        {/* inner hairline frame */}
        <rect x={pad + 2} y={pad + 2} width={w - (pad+2)*2} height={h - (pad+2)*2}
          fill="none" stroke="rgba(248,243,231,0.6)" strokeWidth="0.4"/>
        {/* scene (translated into inner rect) */}
        <g transform={`translate(${pad},${pad}) scale(${(w-pad*2)/w} ${(h-pad*2)/h})`}>
          {stampScene(kind, w, h)}
        </g>
      </g>
    </svg>
  );
}

function stampScene(kind, w, h) {
  const fg = '#F4EFE5';  // paper-warm white instead of pure white
  if (kind === 'classic') return (
    <g>
      <circle cx={w/2} cy={h*0.42} r={w*0.22} fill="none" stroke={fg} strokeWidth="1"/>
      <circle cx={w/2} cy={h*0.42} r={w*0.14} fill="none" stroke={fg} strokeWidth="0.6"/>
      <text x={w/2} y={h*0.47} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontWeight: 500, fontSize: w*0.18 }}>邮</text>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>CLASSIC</text>
    </g>
  );
  if (kind === 'nature') return (
    <g>
      <circle cx={w*0.72} cy={h*0.26} r={w*0.07} fill={fg} opacity="0.85"/>
      <path d={`M${w*0.1},${h*0.56} L${w*0.3},${h*0.3} L${w*0.46},${h*0.45} L${w*0.66},${h*0.24} L${w*0.9},${h*0.56} Z`} fill={fg}/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>NATURE</text>
    </g>
  );
  if (kind === 'culture') return (
    <g stroke="none" fill={fg}>
      <path d={`M${w/2},${h*0.14} L${w*0.34},${h*0.24} L${w*0.66},${h*0.24} Z`}/>
      <rect x={w*0.4} y={h*0.25} width={w*0.2} height={h*0.03}/>
      <path d={`M${w*0.3},${h*0.34} L${w*0.36},${h*0.3} L${w*0.64},${h*0.3} L${w*0.7},${h*0.34} Z`}/>
      <rect x={w*0.4} y={h*0.35} width={w*0.2} height={h*0.04}/>
      <path d={`M${w*0.26},${h*0.46} L${w*0.34},${h*0.42} L${w*0.66},${h*0.42} L${w*0.74},${h*0.46} Z`}/>
      <rect x={w*0.42} y={h*0.47} width={w*0.16} height={h*0.05}/>
      <text x={w/2} y={h*0.82} textAnchor="middle"
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>CULTURE</text>
    </g>
  );
  if (kind === 'city') return (
    <g fill={fg}>
      <rect x={w*0.14} y={h*0.36} width={w*0.12} height={h*0.22}/>
      <rect x={w*0.28} y={h*0.24} width={w*0.1} height={h*0.34}/>
      <rect x={w*0.4} y={h*0.16} width={w*0.06} height={h*0.42}/>
      <rect x={w*0.38} y={h*0.12} width={w*0.1} height={h*0.04}/>
      <rect x={w*0.48} y={h*0.3} width={w*0.1} height={h*0.28}/>
      <rect x={w*0.6} y={h*0.22} width={w*0.12} height={h*0.36}/>
      <rect x={w*0.74} y={h*0.4} width={w*0.1} height={h*0.18}/>
      <text x={w/2} y={h*0.82} textAnchor="middle"
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>CITY</text>
    </g>
  );
  if (kind === 'ocean') return (
    <g>
      <path d={`M${w*0.42},${h*0.22} L${w*0.58},${h*0.22} L${w*0.55},${h*0.32} L${w*0.45},${h*0.32} Z`} fill={fg}/>
      <path d={`M${w*0.5},${h*0.14} L${w*0.5},${h*0.22} L${w*0.6},${h*0.22} Z`} fill={fg}/>
      {[0.4, 0.48, 0.56].map((y,i)=>(
        <path key={i} d={`M${w*0.08},${h*y} Q${w*0.3},${h*(y-0.05)} ${w*0.5},${h*y} T${w*0.92},${h*y}`} fill="none" stroke={fg} strokeWidth="1"/>
      ))}
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>OCEAN</text>
    </g>
  );
  if (kind === 'sunset') return (
    <g>
      <circle cx={w/2} cy={h*0.32} r={w*0.16} fill={fg}/>
      <path d={`M${w*0.08},${h*0.46} L${w*0.92},${h*0.46}`} stroke={fg} strokeWidth="1"/>
      <path d={`M${w*0.08},${h*0.52} L${w*0.92},${h*0.52}`} stroke={fg} strokeWidth="0.6" opacity="0.7"/>
      <path d={`M${w*0.08},${h*0.58} L${w*0.92},${h*0.58}`} stroke={fg} strokeWidth="0.4" opacity="0.45"/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>SUNSET</text>
    </g>
  );

  // ─── Series III · SEASONS ───
  if (kind === 'spring') return (
    <g fill={fg}>
      {/* branch */}
      <path d={`M${w*0.18},${h*0.55} Q${w*0.4},${h*0.4} ${w*0.8},${h*0.3}`} fill="none" stroke={fg} strokeWidth="1.2"/>
      <path d={`M${w*0.4},${h*0.46} Q${w*0.5},${h*0.3} ${w*0.55},${h*0.2}`} fill="none" stroke={fg} strokeWidth="0.7" opacity="0.85"/>
      {/* blossoms */}
      {[[0.32,0.5],[0.5,0.36],[0.7,0.32],[0.58,0.18]].map((p,i)=>(
        <g key={i} transform={`translate(${w*p[0]},${h*p[1]})`}>
          {[0,72,144,216,288].map(a=>(
            <ellipse key={a} cx="0" cy={-w*0.04} rx={w*0.026} ry={w*0.04} fill={fg} transform={`rotate(${a})`}/>
          ))}
          <circle r={w*0.015} fill={s_color('spring')} stroke={fg} strokeWidth="0.5"/>
        </g>
      ))}
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>SPRING</text>
    </g>
  );
  if (kind === 'summer') return (
    <g fill={fg}>
      {/* lily pad */}
      <path d={`M${w*0.15},${h*0.55} A${w*0.36},${w*0.18} 0 1 0 ${w*0.85},${h*0.55} L${w*0.5},${h*0.51} Z`} fill={fg} opacity="0.6"/>
      {/* lotus petals */}
      <g transform={`translate(${w/2},${h*0.4})`}>
        {[0,40,-40,75,-75].map((a,i)=>(
          <ellipse key={a} cx="0" cy={-w*0.12} rx={w*0.06} ry={w*0.13} fill={fg} transform={`rotate(${a})`} opacity={i===0?1:0.85}/>
        ))}
        <ellipse cx="0" cy={-w*0.05} rx={w*0.07} ry={w*0.1} fill={fg}/>
      </g>
      {/* water ripples */}
      <path d={`M${w*0.2},${h*0.62} Q${w*0.4},${h*0.6} ${w*0.5},${h*0.62}`} fill="none" stroke={fg} strokeWidth="0.6" opacity="0.6"/>
      <path d={`M${w*0.5},${h*0.62} Q${w*0.6},${h*0.6} ${w*0.8},${h*0.62}`} fill="none" stroke={fg} strokeWidth="0.6" opacity="0.6"/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>SUMMER</text>
    </g>
  );
  if (kind === 'autumn') return (
    <g fill={fg}>
      {/* maple leaf — 5-point simplified */}
      <g transform={`translate(${w/2},${h*0.36})`}>
        <path d={`M0,${-w*0.22}
          L${w*0.06},${-w*0.1} L${w*0.18},${-w*0.06}
          L${w*0.1},${w*0.02}  L${w*0.2},${w*0.12}
          L${w*0.06},${w*0.1}  L${w*0.03},${w*0.22}
          L${-w*0.03},${w*0.22} L${-w*0.06},${w*0.1}
          L${-w*0.2},${w*0.12} L${-w*0.1},${w*0.02}
          L${-w*0.18},${-w*0.06} L${-w*0.06},${-w*0.1} Z`} fill={fg}/>
        <path d={`M0,${w*0.22} L0,${-w*0.2}`} stroke={s_color('autumn')} strokeWidth="0.5" opacity="0.5"/>
      </g>
      {/* stem */}
      <path d={`M${w/2},${h*0.58} L${w/2},${h*0.64}`} stroke={fg} strokeWidth="1.2"/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>AUTUMN</text>
    </g>
  );
  if (kind === 'winter') return (
    <g stroke={fg} fill="none" strokeWidth="1" strokeLinecap="round">
      <g transform={`translate(${w/2},${h*0.36})`}>
        {[0,60,120,180,240,300].map(a=>(
          <g key={a} transform={`rotate(${a})`}>
            <line x1="0" y1="0" x2="0" y2={-w*0.22}/>
            <line x1="0" y1={-w*0.1} x2={-w*0.04} y2={-w*0.14}/>
            <line x1="0" y1={-w*0.1} x2={w*0.04} y2={-w*0.14}/>
            <line x1="0" y1={-w*0.18} x2={-w*0.04} y2={-w*0.22}/>
            <line x1="0" y1={-w*0.18} x2={w*0.04} y2={-w*0.22}/>
          </g>
        ))}
        <circle r={w*0.02} fill={fg}/>
      </g>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg} stroke="none"
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>WINTER</text>
    </g>
  );

  // ─── Series IV · SOLAR TERMS ───
  if (kind === 'lichun') return (
    <g fill={fg}>
      {/* soil line */}
      <path d={`M${w*0.18},${h*0.58} L${w*0.82},${h*0.58}`} stroke={fg} strokeWidth="1" fill="none"/>
      {/* stem */}
      <path d={`M${w/2},${h*0.58} L${w/2},${h*0.3}`} stroke={fg} strokeWidth="1.4" fill="none"/>
      {/* two leaves */}
      <path d={`M${w/2},${h*0.4} Q${w*0.32},${h*0.34} ${w*0.28},${h*0.22} Q${w*0.42},${h*0.28} ${w/2},${h*0.4}`} fill={fg}/>
      <path d={`M${w/2},${h*0.36} Q${w*0.68},${h*0.3} ${w*0.72},${h*0.18} Q${w*0.58},${h*0.24} ${w/2},${h*0.36}`} fill={fg}/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>LICHUN</text>
    </g>
  );
  if (kind === 'qingming') return (
    <g fill={fg} stroke={fg}>
      {/* rain drops */}
      {[[0.3,0.18],[0.5,0.22],[0.7,0.16],[0.4,0.34],[0.6,0.32]].map((p,i)=>(
        <path key={i} d={`M${w*p[0]},${h*p[1]} q${w*0.02},${h*0.04} 0,${h*0.06} q${-w*0.02},${-h*0.02} 0,${-h*0.06}z`} fill={fg} stroke="none"/>
      ))}
      {/* grass blades */}
      <path d={`M${w*0.22},${h*0.6} Q${w*0.24},${h*0.5} ${w*0.27},${h*0.46}`} fill="none" stroke={fg} strokeWidth="1.1" strokeLinecap="round"/>
      <path d={`M${w*0.4},${h*0.62} Q${w*0.42},${h*0.5} ${w*0.46},${h*0.48}`} fill="none" stroke={fg} strokeWidth="1.1" strokeLinecap="round"/>
      <path d={`M${w*0.56},${h*0.6} Q${w*0.58},${h*0.5} ${w*0.62},${h*0.46}`} fill="none" stroke={fg} strokeWidth="1.1" strokeLinecap="round"/>
      <path d={`M${w*0.7},${h*0.62} Q${w*0.72},${h*0.5} ${w*0.76},${h*0.48}`} fill="none" stroke={fg} strokeWidth="1.1" strokeLinecap="round"/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg} stroke="none"
        style={{ fontFamily: F.display, fontSize: w*0.12, letterSpacing: 1 }}>QINGMING</text>
    </g>
  );
  if (kind === 'xiazhi') return (
    <g stroke={fg} fill={fg}>
      {/* big sun w/ rays */}
      <circle cx={w/2} cy={h*0.35} r={w*0.16} fill={fg}/>
      {[0,30,60,90,120,150,180,210,240,270,300,330].map(a=>(
        <line key={a} x1={w/2} y1={h*0.35} x2={w/2} y2={h*0.35 - w*0.28}
          stroke={fg} strokeWidth="0.9" strokeLinecap="round"
          transform={`rotate(${a} ${w/2} ${h*0.35})`}/>
      ))}
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg} stroke="none"
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>XIAZHI</text>
    </g>
  );
  if (kind === 'liqiu') return (
    <g fill={fg} stroke={fg}>
      {/* wheat ear */}
      <path d={`M${w/2},${h*0.62} L${w/2},${h*0.16}`} stroke={fg} strokeWidth="1.2" fill="none"/>
      {[0.22,0.3,0.38,0.46].map((y,i)=>(
        <g key={i}>
          <ellipse cx={w/2 - w*0.06} cy={h*y} rx={w*0.05} ry={w*0.025} fill={fg} transform={`rotate(-20 ${w/2 - w*0.06} ${h*y})`}/>
          <ellipse cx={w/2 + w*0.06} cy={h*y} rx={w*0.05} ry={w*0.025} fill={fg} transform={`rotate(20 ${w/2 + w*0.06} ${h*y})`}/>
        </g>
      ))}
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg} stroke="none"
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>LIQIU</text>
    </g>
  );
  if (kind === 'shuangjiang') return (
    <g stroke={fg} fill="none" strokeWidth="0.9" strokeLinecap="round">
      {/* small frost crystals */}
      {[[0.3,0.28],[0.5,0.22],[0.7,0.3],[0.36,0.46],[0.62,0.5]].map((p,i)=>(
        <g key={i} transform={`translate(${w*p[0]},${h*p[1]})`}>
          {[0,60,120].map(a=>(
            <line key={a} x1="0" y1="0" x2={w*0.06} y2="0" stroke={fg} strokeWidth="0.9"
              transform={`rotate(${a})`}/>
          ))}
          {[180,240,300].map(a=>(
            <line key={a} x1="0" y1="0" x2={w*0.06} y2="0" stroke={fg} strokeWidth="0.9"
              transform={`rotate(${a})`}/>
          ))}
        </g>
      ))}
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg} stroke="none"
        style={{ fontFamily: F.display, fontSize: w*0.12, letterSpacing: 1 }}>SHUANG</text>
    </g>
  );
  if (kind === 'dahan') return (
    <g fill={fg}>
      {/* big snowy mountain */}
      <path d={`M${w*0.1},${h*0.6} L${w*0.4},${h*0.2} L${w*0.55},${h*0.36} L${w*0.7},${h*0.16} L${w*0.9},${h*0.6} Z`} fill={fg}/>
      {/* snow line */}
      <path d={`M${w*0.22},${h*0.42} L${w*0.4},${h*0.2} L${w*0.5},${h*0.3} L${w*0.6},${h*0.22} L${w*0.7},${h*0.16} L${w*0.78},${h*0.32}`}
        fill="none" stroke={s_color('dahan')} strokeWidth="0.6" opacity="0.4"/>
      {/* snow flakes */}
      <circle cx={w*0.2} cy={h*0.16} r="1" fill={fg}/>
      <circle cx={w*0.78} cy={h*0.18} r="1" fill={fg}/>
      <circle cx={w*0.5} cy={h*0.1}  r="1" fill={fg}/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>DAHAN</text>
    </g>
  );

  // ─── Series V · FAR LANDS ───
  if (kind === 'prairie') return (
    <g>
      {/* rolling hills */}
      <path d={`M${w*0.04},${h*0.55} Q${w*0.25},${h*0.4} ${w*0.5},${h*0.5} T${w*0.96},${h*0.5} L${w*0.96},${h*0.6} L${w*0.04},${h*0.6} Z`} fill={fg}/>
      {/* horse silhouette */}
      <g transform={`translate(${w*0.4},${h*0.38})`} fill={fg}>
        <rect x="0" y="0" width={w*0.18} height={w*0.06} rx={w*0.01}/>
        <rect x="0" y={w*0.06} width={w*0.02} height={w*0.06}/>
        <rect x={w*0.04} y={w*0.06} width={w*0.02} height={w*0.06}/>
        <rect x={w*0.12} y={w*0.06} width={w*0.02} height={w*0.06}/>
        <rect x={w*0.16} y={w*0.06} width={w*0.02} height={w*0.06}/>
        <rect x={w*0.15} y={-w*0.04} width={w*0.05} height={w*0.06}/>
      </g>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.12, letterSpacing: 1 }}>PRAIRIE</text>
    </g>
  );
  if (kind === 'snowpeak') return (
    <g fill={fg}>
      {/* triangle peak */}
      <path d={`M${w*0.5},${h*0.16} L${w*0.86},${h*0.6} L${w*0.14},${h*0.6} Z`} fill={fg}/>
      {/* snow cap */}
      <path d={`M${w*0.42},${h*0.28} L${w*0.5},${h*0.16} L${w*0.58},${h*0.28} L${w*0.54},${h*0.34} L${w*0.5},${h*0.3} L${w*0.46},${h*0.34} Z`} fill={s_color('snowpeak', '#F4EFE5')}/>
      {/* small accent peak behind */}
      <path d={`M${w*0.05},${h*0.6} L${w*0.22},${h*0.36} L${w*0.36},${h*0.6} Z`} fill={fg} opacity="0.55"/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.12, letterSpacing: 1 }}>SNOWPEAK</text>
    </g>
  );
  if (kind === 'desert') return (
    <g fill={fg}>
      {/* dune */}
      <path d={`M${w*0.04},${h*0.6} Q${w*0.28},${h*0.34} ${w*0.5},${h*0.46} T${w*0.96},${h*0.5} L${w*0.96},${h*0.62} L${w*0.04},${h*0.62} Z`} fill={fg}/>
      {/* camel — simplified */}
      <g transform={`translate(${w*0.3},${h*0.38})`} fill={fg}>
        <ellipse cx={w*0.08} cy={w*0.04} rx={w*0.09} ry={w*0.035}/>
        <path d={`M${w*0.02},${w*0.04} q${w*0.025},${-w*0.05} ${w*0.05},${0}`} fill={fg}/>
        <path d={`M${w*0.1},${w*0.04} q${w*0.025},${-w*0.05} ${w*0.05},${0}`} fill={fg}/>
        <circle cx={w*0.17} cy={w*0.01} r={w*0.018}/>
        <rect x="0" y={w*0.06} width={w*0.01} height={w*0.05}/>
        <rect x={w*0.04} y={w*0.06} width={w*0.01} height={w*0.05}/>
        <rect x={w*0.12} y={w*0.06} width={w*0.01} height={w*0.05}/>
        <rect x={w*0.16} y={w*0.06} width={w*0.01} height={w*0.05}/>
      </g>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>DESERT</text>
    </g>
  );
  if (kind === 'island') return (
    <g fill={fg}>
      {/* small island */}
      <ellipse cx={w*0.5} cy={h*0.56} rx={w*0.22} ry={w*0.04}/>
      {/* palm tree trunk */}
      <path d={`M${w*0.5},${h*0.56} Q${w*0.46},${h*0.4} ${w*0.42},${h*0.28}`} fill="none" stroke={fg} strokeWidth="1.4" strokeLinecap="round"/>
      {/* palm leaves */}
      <path d={`M${w*0.42},${h*0.28} Q${w*0.32},${h*0.22} ${w*0.22},${h*0.26}`} fill="none" stroke={fg} strokeWidth="1.1" strokeLinecap="round"/>
      <path d={`M${w*0.42},${h*0.28} Q${w*0.36},${h*0.16} ${w*0.32},${h*0.1}`}  fill="none" stroke={fg} strokeWidth="1.1" strokeLinecap="round"/>
      <path d={`M${w*0.42},${h*0.28} Q${w*0.5},${h*0.18} ${w*0.6},${h*0.16}`}   fill="none" stroke={fg} strokeWidth="1.1" strokeLinecap="round"/>
      <path d={`M${w*0.42},${h*0.28} Q${w*0.52},${h*0.24} ${w*0.66},${h*0.26}`}fill="none" stroke={fg} strokeWidth="1.1" strokeLinecap="round"/>
      {/* waves */}
      <path d={`M${w*0.08},${h*0.66} Q${w*0.2},${h*0.62} ${w*0.32},${h*0.66}`} fill="none" stroke={fg} strokeWidth="0.7"/>
      <path d={`M${w*0.68},${h*0.66} Q${w*0.8},${h*0.62} ${w*0.92},${h*0.66}`} fill="none" stroke={fg} strokeWidth="0.7"/>
      <text x={w/2} y={h*0.82} textAnchor="middle" fill={fg}
        style={{ fontFamily: F.display, fontSize: w*0.13, letterSpacing: 1 }}>ISLAND</text>
    </g>
  );
  return null;
}

// helper for scenes — get a stamp's accent color, with optional override
function s_color(kind, fallback) {
  return (T.stamps[kind] && T.stamps[kind].color) || fallback || '#000';
}

// ─────────── EMBEDDED POSTCARD PREVIEW ───────────
function PostcardPreview({ photo='LANDSCAPE', tone='forest', location='西湖断桥', city='杭州', country='中国', note='断桥不断', stamp='classic' }) {
  return (
    <div style={{
      background: T.card, borderRadius: 6, overflow:'hidden',
      border: `1px solid ${T.divider}`,
      boxShadow: '0 12px 28px rgba(40,30,15,0.10)',
      transform: 'rotate(-0.7deg)',
    }}>
      <Photo label={photo} tone={tone} code={city.toUpperCase()} w='100%' h={130} radius={0} />
      <div style={{ padding: '14px 16px 10px', display:'flex', gap: 12 }}>
        <div style={{ flex:1, minWidth:0 }}>
          <div style={{ ...labelStyle, fontSize: 9, color: T.mute }}>{city} · {country}</div>
          <div style={{
            fontFamily: F.display, fontWeight: 500, color: T.ink, fontSize: 18,
            letterSpacing: 0.3, marginTop: 4,
          }}>{location}</div>
          <div style={{ marginTop: 8,
            fontFamily: F.serif, fontStyle: 'italic',
            color: T.body, fontSize: 12, lineHeight: 1.55,
          }}>"{note}"</div>
        </div>
        <Stamp kind={stamp} size={42} rotate={2}/>
      </div>
      <div style={{
        borderTop: `1px solid ${T.divider}`, padding: '8px 16px',
        display:'flex', justifyContent:'space-between',
        fontFamily: F.mono, fontSize: 9, color: T.mute, letterSpacing: 2,
      }}>
        <span>旅笺 · 寄往远方</span>
        <span>CN — 0001</span>
      </div>
    </div>
  );
}

// ─────────── PHONE FRAME ───────────
function PhoneFrame({ children, w=390, h=844 }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: 48, overflow: 'hidden',
      position: 'relative', background: T.bg,
      boxShadow: '0 40px 80px rgba(30,25,15,0.16), 0 0 0 1px rgba(0,0,0,0.10), inset 0 0 0 3px #14110A',
      fontFamily: F.sans,
      WebkitFontSmoothing: 'antialiased',
      color: T.ink,
    }}>
      <div style={{
        position: 'absolute', top: 12, left: '50%', transform: 'translateX(-50%)',
        width: 110, height: 32, borderRadius: 24, background: '#000', zIndex: 50,
      }} />
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, height: 54,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 28px', zIndex: 40, color: T.ink,
        fontWeight: 600, fontSize: 14, letterSpacing: .3,
      }}>
        <span style={{ marginTop: 12 }}>9:41</span>
        <span style={{ marginTop: 12, display:'flex', gap: 6, alignItems:'center' }}>
          <span style={{ display:'flex', gap: 2 }}>
            {[3,5,7,9].map((H,i) => <span key={i} style={{ width: 3, height: H, background: 'currentColor', borderRadius: 1 }}/>)}
          </span>
          <span style={{ width: 22, height: 11, border: '1px solid currentColor', borderRadius: 2.5, position:'relative' }}>
            <span style={{ position:'absolute', left:1, top:1, right:5, bottom:1, background: 'currentColor', borderRadius: 1 }}/>
          </span>
        </span>
      </div>
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}>{children}</div>
      <div style={{
        position: 'absolute', bottom: 8, left: 0, right: 0, zIndex: 70,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{ width: 134, height: 5, borderRadius: 100, background: 'rgba(0,0,0,0.32)' }}/>
      </div>
    </div>
  );
}

// scroll body container
function Body({ children, padBottom=96, padTop=0, bg=T.bg }) {
  return (
    <div style={{
      position:'absolute', inset:0, overflow:'auto', background: bg,
      paddingBottom: padBottom, paddingTop: padTop,
      scrollbarWidth: 'none',
    }}>
      <style>{`div::-webkit-scrollbar{display:none}`}</style>
      {children}
    </div>
  );
}

// ─────────── AIRMAIL STRIPE ───────────
// The red/white/blue diagonal stripe border used on real airmail envelopes.
// Defaults: 1-direction (top), but `sides` accepts any combo of t/r/b/l.
function AirMail({ sides='trbl', height=10, stripeWidth=6 }) {
  // diagonal red/blue alternating stripes
  const pattern = `repeating-linear-gradient(45deg,
      ${T.red} 0 ${stripeWidth}px,
      transparent ${stripeWidth}px ${stripeWidth*2}px,
      #1F4B66 ${stripeWidth*2}px ${stripeWidth*3}px,
      transparent ${stripeWidth*3}px ${stripeWidth*4}px)`;
  const styles = (where) => ({
    position: 'absolute',
    background: pattern,
    backgroundColor: T.bg,
    [where === 't' || where === 'b' ? 'left' : 'top']: 0,
    [where === 't' || where === 'b' ? 'right' : 'bottom']: 0,
    [where]: 0,
    ...(where === 't' || where === 'b' ? { height } : { width: height }),
  });
  return (
    <>
      {sides.includes('t') && <div aria-hidden style={styles('t')}/>}
      {sides.includes('r') && <div aria-hidden style={styles('r')}/>}
      {sides.includes('b') && <div aria-hidden style={styles('b')}/>}
      {sides.includes('l') && <div aria-hidden style={styles('l')}/>}
    </>
  );
}

// ─────────── POSTMARK ───────────
// Circular date stamp — like a real cancellation mark. City on top, date
// in middle, year on bottom. Color and rotation customizable.
function Postmark({ city='HANGZHOU', date='05·10', year='2024', size=60, color=T.red, rotate=-8 }) {
  return (
    <svg viewBox={`0 0 ${size} ${size}`} width={size} height={size}
      style={{ transform: `rotate(${rotate}deg)`, display:'block' }}>
      <circle cx={size/2} cy={size/2} r={size*0.46} fill="none" stroke={color} strokeWidth="1.1"/>
      <circle cx={size/2} cy={size/2} r={size*0.38} fill="none" stroke={color} strokeWidth="0.5" opacity="0.55"/>
      <text x={size/2} y={size*0.4} textAnchor="middle" fill={color}
        style={{ fontFamily: F.mono, fontSize: size*0.13, letterSpacing: 1.5, opacity: .9 }}>{city}</text>
      <line x1={size*0.22} y1={size*0.46} x2={size*0.78} y2={size*0.46} stroke={color} strokeWidth="0.5" opacity=".55"/>
      <text x={size/2} y={size*0.6} textAnchor="middle" fill={color}
        style={{ fontFamily: F.display, fontSize: size*0.22, fontWeight: 500 }}>{date}</text>
      <text x={size/2} y={size*0.74} textAnchor="middle" fill={color}
        style={{ fontFamily: F.mono, fontSize: size*0.1, letterSpacing: 1.5, opacity: .8 }}>{year}</text>
    </svg>
  );
}

// ─────────── PAR AVION / VIA AIR MAIL LABEL ───────────
function ParAvion({ size='small', color=T.red, bg='transparent' }) {
  const big = size === 'big';
  return (
    <div style={{
      display:'inline-flex', alignItems:'center', gap: big ? 8 : 5,
      padding: big ? '4px 10px' : '2px 7px',
      border: `1px solid ${color}`,
      color, background: bg,
      fontFamily: F.mono, fontSize: big ? 11 : 9, fontWeight: 500,
      letterSpacing: big ? 3 : 2,
    }}>
      <span style={{
        fontFamily: F.serif, fontStyle:'italic', textTransform:'none',
        letterSpacing: 0.5, fontSize: big ? 12 : 10,
      }}>par avion</span>
      <span style={{ width: 1, height: big ? 12 : 9, background: color, opacity: .5 }}/>
      <span>VIA AIR MAIL</span>
    </div>
  );
}

// ─────────── ENVELOPE FRAME ───────────
// Layered envelope shape — body + diagonal flap + airmail border.
// Children render inside the envelope body.
function Envelope({ children, color=T.cardWarm, border=true, flap=false, height='auto', padding=18 }) {
  return (
    <div style={{
      background: color, position:'relative',
      border: border ? `1px solid ${T.divider}` : 'none',
      borderRadius: 2, padding,
      boxShadow: '0 6px 18px rgba(40,30,15,0.08)',
      overflow:'hidden', height,
    }}>
      {/* diagonal flap shadow line (open envelope) */}
      {flap && (
        <svg viewBox="0 0 100 30" preserveAspectRatio="none"
          style={{ position:'absolute', top: 0, left: 0, width: '100%', height: 28, pointerEvents:'none' }}>
          <path d="M0 0 L50 22 L100 0" fill="none" stroke={T.divider} strokeWidth="0.5"/>
        </svg>
      )}
      <AirMail sides="t" height={6} stripeWidth={5}/>
      <AirMail sides="b" height={6} stripeWidth={5}/>
      <div style={{ paddingTop: 8, paddingBottom: 8, position:'relative', zIndex:1 }}>
        {children}
      </div>
    </div>
  );
}

// ─────────── ADDRESS BLOCK ───────────
// FROM / TO style address layout in two columns w/ small caps labels.
function AddressBlock({ from, to, accent=T.green, dense=false }) {
  return (
    <div style={{
      display:'grid', gridTemplateColumns:'auto 1fr', columnGap: 14, rowGap: dense ? 6 : 8,
    }}>
      <div style={{ ...labelStyle, color: accent, paddingTop: 2 }}>FROM</div>
      <div style={{ fontFamily: F.serif, fontSize: dense ? 12 : 13, color: T.ink, lineHeight: 1.4 }}>{from}</div>
      <div style={{ ...labelStyle, color: accent, paddingTop: 2 }}>TO</div>
      <div style={{ fontFamily: F.serif, fontSize: dense ? 12 : 13, color: T.ink, lineHeight: 1.4 }}>{to}</div>
    </div>
  );
}

Object.assign(window, {
  T, F, Ico, Photo, PostalHeader, TabBar, StatCard, PostcardRow, Stamp, PostcardPreview,
  PhoneFrame, Body, labelStyle,
  AirMail, Postmark, ParAvion, Envelope, AddressBlock,
});

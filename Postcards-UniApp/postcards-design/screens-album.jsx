// 旅笺 · 集邮册 (Stamp Album) — full multi-series version

function ScreenAlbum() {
  // ── Series I · 旅行 — base set ──
  const series1 = [
    { kind: 'classic', count: 3, lastCity: '杭州 · 西湖',   lastDate: '2024 · 05 · 10' },
    { kind: 'nature',  count: 2, lastCity: '敦煌 · 鸣沙山', lastDate: '2024 · 04 · 13' },
    { kind: 'culture', count: 2, lastCity: '敦煌 · 莫高窟', lastDate: '2024 · 04 · 12' },
    { kind: 'city',    count: 2, lastCity: '重庆 · 洪崖洞', lastDate: '2024 · 03 · 14' },
    { kind: 'ocean',   locked: true, hint: '前往一座海滨城市' },
    { kind: 'sunset',  locked: true, hint: '记录一次日落时刻' },
  ];

  // ── Series III · 四季 ──
  const series3 = [
    { kind: 'spring',  count: 1, lastCity: '杭州 · 苏堤春晓', lastDate: '2024 · 04 · 03' },
    { kind: 'summer',  locked: true, hint: '于 6-8 月寄出一张' },
    { kind: 'autumn',  locked: true, hint: '记录一片落叶' },
    { kind: 'winter',  locked: true, hint: '冬日寄出一张明信片' },
  ];

  // ── Series IV · 节气 ──
  const series4 = [
    { kind: 'lichun',      count: 1, lastCity: '杭州 · 春日',  lastDate: '2024 · 02 · 04' },
    { kind: 'qingming',    locked: true, hint: '清明节当天寄出' },
    { kind: 'xiazhi',      locked: true, hint: '夏至当天寄出' },
    { kind: 'liqiu',       locked: true, hint: '立秋当天寄出' },
    { kind: 'shuangjiang', locked: true, hint: '霜降节气寄出' },
    { kind: 'dahan',       locked: true, hint: '大寒节气寄出' },
  ];

  // ── Series V · 远方 ──
  const series5 = [
    { kind: 'prairie',  locked: true, hint: '抵达一片草原' },
    { kind: 'snowpeak', locked: true, hint: '记录一座雪山' },
    { kind: 'desert',   locked: true, hint: '穿越一片沙漠' },
    { kind: 'island',   locked: true, hint: '抵达一座海岛' },
  ];

  // ── Series II · 限定 ──
  const series2 = [
    { name: '雪 · SNOW',     color: '#7A95AE', hint: '在冬日寄出一张明信片' },
    { name: '雨 · RAIN',     color: '#4F6D7A', hint: '雨天记录一段路途' },
    { name: '夜 · NIGHT',    color: '#3D3852', hint: '晚于 21:00 寄出一张' },
    { name: '远 · DISTANCE', color: '#8A5A3B', hint: '抵达 1000 公里以外' },
  ];

  const seriesData = [
    { id:'I',   cn:'旅行', en:'TRAVEL',   sub:'基础系列 · 6 款',   items: series1 },
    { id:'III', cn:'四季', en:'SEASONS',  sub:'限季发行 · 4 款',   items: series3 },
    { id:'IV',  cn:'节气', en:'SOLAR TERMS', sub:'24 节气 · 6 款代表', items: series4 },
    { id:'V',   cn:'远方', en:'FAR LANDS', sub:'地貌系列 · 4 款',   items: series5 },
    { id:'II',  cn:'限定', en:'LIMITED',  sub:'限时收藏 · 4 款',   items: series2, foreign: true },
  ];

  const totalSlots = seriesData.reduce((n, s) => n + s.items.length, 0);
  const collected = seriesData.reduce((n, s) =>
    n + s.items.filter(it => !it.locked).length, 0);

  return (
    <PhoneFrame>
      <Body padBottom={36}>
        {/* nav */}
        <div style={{
          position:'sticky', top: 0, zIndex: 20,
          background: T.bg, paddingTop: 54, paddingBottom: 14,
          paddingLeft: 18, paddingRight: 18,
          borderBottom: `1px solid ${T.divider}`,
          display:'flex', alignItems:'center', justifyContent:'space-between',
        }}>
          <button style={{
            all:'unset', cursor:'pointer', width: 36, height: 36, borderRadius: 99,
            color: T.ink, display:'flex', alignItems:'center', justifyContent:'center',
            border: `1px solid ${T.divider}`,
          }}>{Ico.back(18)}</button>
          <div style={{ textAlign:'center' }}>
            <div style={{ ...labelStyle, fontSize: 9 }}>STAMP ALBUM · 集邮册</div>
            <div style={{ fontFamily: F.display, fontSize: 16, fontWeight: 500, color: T.ink, marginTop: 2 }}>旅笺 · 我的邮票</div>
          </div>
          <button style={{
            all:'unset', cursor:'pointer', width: 36, height: 36, borderRadius: 99,
            color: T.body, display:'flex', alignItems:'center', justifyContent:'center',
            border: `1px solid ${T.divider}`,
          }}>{Ico.share(16)}</button>
        </div>

        {/* hero — progress + rank */}
        <div style={{
          padding: '24px 20px 24px',
          borderBottom: `1px solid ${T.divider}`,
          position:'relative', overflow:'hidden',
        }}>
          <div aria-hidden style={{
            position:'absolute', top: 14, left: 20, right: 20, height: 1,
            backgroundImage: `repeating-linear-gradient(90deg, ${T.rule} 0 4px, transparent 4px 8px)`,
          }}/>
          <div style={{ display:'flex', alignItems:'flex-start', gap: 18, marginTop: 14 }}>
            <ProgressRing collected={collected} total={totalSlots}/>
            <div style={{ flex:1, minWidth:0, paddingTop: 4 }}>
              <div style={{ ...labelStyle, color: T.green, marginBottom: 6 }}>PROGRESS · 收藏进度</div>
              <div style={{
                fontFamily: F.display, fontWeight: 500, fontSize: 22, color: T.ink,
                lineHeight: 1.15, letterSpacing: -0.3,
              }}>初出茅庐</div>
              <div style={{
                fontFamily: F.serif, fontStyle: 'italic', fontSize: 12, color: T.body, marginTop: 6, lineHeight: 1.5,
              }}>"再集 04 款邮票，<br/>即可升级为「旅行者」"</div>
              <div style={{ marginTop: 10, display:'flex', gap: 16, flexWrap:'wrap' }}>
                <Meta2 k="TOTAL"  v="09" sub="张明信片"/>
                <Meta2 k="SERIES" v="05" sub="个系列"/>
                <Meta2 k="SINCE"  v="04·03" sub="加入"/>
              </div>
            </div>
          </div>
        </div>

        {/* series sections */}
        {seriesData.map((sec) => (
          <div key={sec.id}>
            <SeriesHeader id={sec.id} cn={sec.cn} en={sec.en} sub={sec.sub}
              count={`${String(sec.items.filter(it=>!it.locked).length).padStart(2,'0')} / ${String(sec.items.length).padStart(2,'0')}`}/>
            <AlbumGrid items={sec.items.map(it => (
              it.kind ? {
                kind: it.kind,
                name: T.stamps[it.kind].name,
                en: T.stamps[it.kind].name_en,
                color: T.stamps[it.kind].color,
                count: it.count, lastCity: it.lastCity, lastDate: it.lastDate,
                locked: it.locked, hint: it.hint,
              } : {
                name: it.name.split(' ·')[0].trim(),
                en: it.name.split(' · ')[1],
                color: it.color,
                locked: true, hint: it.hint,
              }
            ))}/>
          </div>
        ))}

        {/* achievements */}
        <SeriesHeader cn="成就" en="ACHIEVEMENTS · 旅人徽章" sub="02 / 06 已解锁"/>
        <div style={{ padding: '0 20px 32px' }}>
          <div style={{
            background: T.card, borderRadius: 6, border: `1px solid ${T.divider}`,
            padding: '16px 4px',
          }}>
            <div style={{ display:'grid', gridTemplateColumns:'repeat(3, 1fr)', rowGap: 18 }}>
              <Achievement i={Ico.envelope(18)} title="首封" desc="寄出第一张" done date="04·03"/>
              <Achievement i={Ico.flag(18)}     title="启程" desc="完成首次旅程" done date="04·21"/>
              <Achievement i={Ico.pin(18)}      title="远行者" desc="到访 5 座城市"   lock="03 / 05"/>
              <Achievement i={Ico.heart(18)}    title="知己"   desc="收藏 10 张"     lock="06 / 10"/>
              <Achievement i={Ico.stamp(18)}    title="集邮人" desc="集齐 SERIES I"  lock="04 / 06"/>
              <Achievement i={Ico.globe(18)}    title="跨国"   desc="到访 2 个国家"   lock="01 / 02"/>
            </div>
          </div>
        </div>

        {/* footer info */}
        <div style={{ padding: '0 20px 28px' }}>
          <div style={{
            display:'flex', justifyContent:'space-between', alignItems:'center',
            paddingTop: 16, borderTop: `1px solid ${T.divider}`,
            ...labelStyle, fontSize: 9,
          }}>
            <span>旅笺 · CN — 839204</span>
            <span>ALBUM N° 01 / 06</span>
          </div>
          <div style={{
            textAlign:'center', marginTop: 14,
            fontFamily: F.display, fontStyle:'italic', fontSize: 13, color: T.body,
          }}>每一张邮票，都是一段路途的注脚</div>
        </div>
      </Body>
    </PhoneFrame>
  );
}

function ProgressRing({ collected, total }) {
  const r = 44, c = 2 * Math.PI * r;
  const pct = collected / total;
  return (
    <div style={{ position:'relative', flexShrink: 0 }}>
      <svg width="100" height="100" viewBox="0 0 100 100">
        <circle cx="50" cy="50" r={r} fill="none" stroke={T.divider} strokeWidth="2"/>
        <circle cx="50" cy="50" r={r} fill="none" stroke={T.green} strokeWidth="2"
          strokeDasharray={`${pct * c} 999`}
          strokeLinecap="round"
          transform="rotate(-90 50 50)"/>
        {Array.from({length: 24}).map((_,i)=>{
          const filled = i < Math.round(pct * 24);
          return (
            <line key={i} x1="50" y1="2" x2="50" y2="6"
              transform={`rotate(${i*15} 50 50)`}
              stroke={filled ? T.green : T.mute} strokeWidth="0.8" opacity={filled?0.9:0.3}/>
          );
        })}
      </svg>
      <div style={{
        position:'absolute', inset:0, display:'flex', flexDirection:'column',
        alignItems:'center', justifyContent:'center',
      }}>
        <div style={{ fontFamily: F.display, fontSize: 24, fontWeight: 400, letterSpacing: -0.5, color: T.ink, lineHeight: 1 }}>
          {String(collected).padStart(2,'0')}
        </div>
        <div style={{ ...labelStyle, fontSize: 7, marginTop: 2 }}>OF {String(total).padStart(2,'0')}</div>
      </div>
    </div>
  );
}

function Meta2({ k, v, sub }) {
  return (
    <div>
      <div style={{ ...labelStyle, fontSize: 8 }}>{k}</div>
      <div style={{
        fontFamily: F.display, fontSize: 17, fontWeight: 500, color: T.ink,
        marginTop: 2, lineHeight: 1, letterSpacing: -0.3,
      }}>{v}</div>
      <div style={{ fontFamily: F.serif, fontSize: 11, color: T.body, marginTop: 2 }}>{sub}</div>
    </div>
  );
}

function SeriesHeader({ id, cn, en, sub, count }) {
  return (
    <div style={{ padding: '24px 20px 12px' }}>
      <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', marginBottom: 8 }}>
        <div style={{ display:'flex', alignItems:'baseline', gap: 8 }}>
          {id && <span style={{ ...labelStyle, color: T.green }}>SERIES · {id}</span>}
          {!id && <span style={{ ...labelStyle, color: T.green }}>{en}</span>}
        </div>
        {count && <span style={{ ...labelStyle, fontSize: 9, fontFamily: F.mono, color: T.body }}>{count}</span>}
      </div>
      <div style={{ display:'flex', alignItems:'baseline', gap: 10 }}>
        <span style={{ fontFamily: F.display, fontWeight: 500, fontSize: 20, color: T.ink, letterSpacing: -0.3 }}>{cn}</span>
        {id && <span style={{ ...labelStyle, fontSize: 9, color: T.mute }}>{en}</span>}
      </div>
      {sub && <div style={{ fontFamily: F.serif, fontSize: 11.5, fontStyle:'italic', color: T.body, marginTop: 4 }}>{sub}</div>}
    </div>
  );
}

function AlbumGrid({ items }) {
  return (
    <div style={{ padding: '0 20px' }}>
      <div style={{
        background: T.cardWarm, borderRadius: 4,
        border: `1px solid ${T.divider}`,
        padding: '14px 14px',
        position:'relative',
      }}>
        <div style={{
          position:'absolute', top: -1, right: 12,
          background: T.cardWarm, padding: '0 6px',
          ...labelStyle, fontSize: 8, color: T.mute,
        }}>PAGE</div>

        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 12 }}>
          {items.map((it, i) => <AlbumSlot key={i} {...it}/>)}
        </div>
      </div>
    </div>
  );
}

function AlbumSlot({ kind, name, en, color, count, lastCity, lastDate, locked, hint }) {
  return (
    <div style={{
      background: locked ? 'transparent' : T.card,
      border: `1px ${locked?'dashed':'solid'} ${locked ? T.rule : T.divider}`,
      borderRadius: 4, padding: '12px 12px',
      display:'flex', alignItems:'center', gap: 12,
      minHeight: 86,
    }}>
      <div style={{ flexShrink: 0, position:'relative' }}>
        {locked ? (
          <SilhouetteStamp color={color}/>
        ) : (
          <Stamp kind={kind} size={52}/>
        )}
        {!locked && count > 1 && (
          <div style={{
            position:'absolute', bottom: -4, right: -6,
            minWidth: 18, height: 18, padding: '0 5px',
            borderRadius: 99, background: T.ink, color: T.bg,
            display:'flex', alignItems:'center', justifyContent:'center',
            fontFamily: F.mono, fontSize: 9, fontWeight: 600, letterSpacing: 0.5,
            border: `1.5px solid ${T.cardWarm}`,
          }}>×{count}</div>
        )}
      </div>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{
          fontFamily: F.display, fontWeight: 500, fontSize: 14, color: locked ? T.mute : T.ink,
          letterSpacing: 0.3,
        }}>{name}</div>
        <div style={{ ...labelStyle, fontSize: 8, marginTop: 2, color: locked ? T.whisper : T.mute }}>{en}</div>

        {locked ? (
          <div style={{
            marginTop: 6, paddingTop: 6, borderTop: `1px dashed ${T.divider}`,
            fontSize: 11, color: T.mute, lineHeight: 1.4,
            fontFamily: F.serif, fontStyle:'italic',
          }}>{hint}</div>
        ) : (
          <div style={{ marginTop: 5 }}>
            <div style={{ fontFamily: F.serif, fontSize: 11, color: T.body, lineHeight: 1.4 }}>
              {lastCity}
            </div>
            <div style={{ ...labelStyle, fontSize: 8, marginTop: 2 }}>{lastDate}</div>
          </div>
        )}
      </div>
    </div>
  );
}

function SilhouetteStamp({ color }) {
  const w = 52, h = w * 1.22;
  const perfR = 2.2;
  const perfsX = 7, perfsY = 9;
  const dxs = Array.from({length: perfsX}, (_,i) => (i+0.5) * (w / perfsX));
  const dys = Array.from({length: perfsY}, (_,i) => (i+0.5) * (h / perfsY));
  const pad = perfR + 1.5;
  const uid = `silm-${color.replace('#','')}`;
  return (
    <svg viewBox={`0 0 ${w} ${h}`} width={w} height={h} style={{ display:'block', opacity: 0.65 }}>
      <defs>
        <mask id={uid}>
          <rect x="0" y="0" width={w} height={h} fill="#fff"/>
          {dxs.map((x,i)=>(<circle key={'t'+i} cx={x} cy="0" r={perfR} fill="#000"/>))}
          {dxs.map((x,i)=>(<circle key={'b'+i} cx={x} cy={h} r={perfR} fill="#000"/>))}
          {dys.map((y,i)=>(<circle key={'l'+i} cx="0" cy={y} r={perfR} fill="#000"/>))}
          {dys.map((y,i)=>(<circle key={'r'+i} cx={w} cy={y} r={perfR} fill="#000"/>))}
        </mask>
      </defs>
      <g mask={`url(#${uid})`}>
        <rect x="0" y="0" width={w} height={h} fill={T.paper}/>
        <rect x={pad} y={pad} width={w - pad*2} height={h - pad*2} fill={T.divider}/>
        <text x={w/2} y={h*0.55} textAnchor="middle" fill={T.whisper}
          style={{ fontFamily: F.display, fontSize: w*0.42, fontWeight: 300 }}>?</text>
      </g>
    </svg>
  );
}

function Achievement({ i, title, desc, done, lock, date }) {
  return (
    <div style={{
      display:'flex', flexDirection:'column', alignItems:'center', gap: 4,
      padding: '4px 6px', textAlign:'center',
      opacity: done ? 1 : 0.55,
    }}>
      <div style={{
        width: 42, height: 42, borderRadius: 99,
        background: done ? T.greenSoft : T.bg,
        border: `1px ${done ? 'solid' : 'dashed'} ${done ? T.green : T.rule}`,
        color: done ? T.green : T.mute,
        display:'flex', alignItems:'center', justifyContent:'center',
      }}>{i}</div>
      <div style={{
        fontFamily: F.display, fontSize: 12, fontWeight: 500,
        color: done ? T.ink : T.body, marginTop: 4,
      }}>{title}</div>
      <div style={{ ...labelStyle, fontSize: 8 }}>{done ? date : lock}</div>
    </div>
  );
}

Object.assign(window, { ScreenAlbum });

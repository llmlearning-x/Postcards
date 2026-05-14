// 旅笺 · Main Tabs (refined v2 — editorial postal aesthetic)

// ───────── tiny shared atoms ─────────
function SectionLabel({ kicker, title, right }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <div style={{ display:'flex', alignItems:'flex-end', justifyContent:'space-between', gap: 12 }}>
        <div>
          {kicker && <div style={{ ...labelStyle, marginBottom: 4, color: T.green }}>{kicker}</div>}
          <div style={{
            fontFamily: F.display, fontWeight: 500, fontSize: 19,
            color: T.ink, letterSpacing: 0.2, lineHeight: 1,
          }}>{title}</div>
        </div>
        {right}
      </div>
      <div style={{ marginTop: 10, height: 1, background: T.divider }}/>
    </div>
  );
}

function MetaRow({ items }) {
  // small caps key + value, pipe separated
  return (
    <div style={{ display:'flex', gap: 14, flexWrap:'wrap' }}>
      {items.map((it, i) => (
        <div key={i}>
          <div style={{ ...labelStyle, color: T.mute, fontSize: 9 }}>{it.k}</div>
          <div style={{
            fontFamily: it.mono ? F.mono : F.serif,
            fontSize: it.mono ? 13 : 14,
            fontWeight: 500, color: T.ink, marginTop: 2,
            letterSpacing: it.mono ? 1 : 0.2,
          }}>{it.v}</div>
        </div>
      ))}
    </div>
  );
}

function Pulse() {
  return (
    <span style={{ position:'relative', width: 6, height: 6, display:'inline-block' }}>
      <span style={{ position:'absolute', inset:0, borderRadius: 99, background: T.alive }}/>
      <span style={{ position:'absolute', inset:-3, borderRadius: 99, background: T.alive, opacity:.3, animation:'fyPulse 1.8s infinite ease-out' }}/>
      <style>{`@keyframes fyPulse{0%{transform:scale(0.6);opacity:.45}100%{transform:scale(2);opacity:0}}`}</style>
    </span>
  );
}

// ───────────────────────── Tab 1: HOME · 收件箱 ─────────────────────────
function ScreenHome({ active, setActive, onOpenDetail }) {
  const [favs, setFavs] = React.useState({ c1: true, c2: true, c3: false });
  const toggle = k => setFavs(s => ({ ...s, [k]: !s[k] }));
  return (
    <PhoneFrame>
      <Body padBottom={96}>
        <PostalHeader
          kicker="INBOX · 旅笺 · 收件箱"
          title={<span>今日 09 封<br/>来自远方的笺</span>}
          subtitle="9 张明信片 · 4 段旅程 · 一个仍在路上的你"
        />

        {/* TODAY's letter — hero envelope */}
        <div style={{ padding: '22px 20px 0' }}>
          <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', marginBottom: 10 }}>
            <span style={{ ...labelStyle, color: T.green }}>TODAY · 今日邮件</span>
            <ParAvion/>
          </div>
          <Envelope flap padding={0}>
            <div style={{ display:'flex', gap: 0 }}>
              <Photo label="WEST LAKE · 西湖" tone="forest" w={140} h={140} radius={0} code="05·10"/>
              <div style={{
                flex:1, padding: '18px 16px 14px', position:'relative',
                display:'flex', flexDirection:'column', justifyContent:'space-between', minWidth:0,
              }}>
                <div>
                  <AddressBlock dense
                    from={<><span>杭州 · 西湖断桥</span><br/><span style={{ color: T.body, fontSize: 11 }}>30.25°N, 120.15°E</span></>}
                    to={<><span>未来的我</span><br/><span style={{ color: T.body, fontSize: 11 }}>北京 · 2025</span></>}
                  />
                </div>
                <div style={{
                  position:'absolute', bottom: 10, right: 10,
                }}>
                  <Postmark size={48} color={T.red} city="HZ" date="05·10" year="24"/>
                </div>
                <div style={{ position:'absolute', top: 12, right: 12 }}>
                  <Stamp kind="classic" size={32} rotate={-3}/>
                </div>
              </div>
            </div>
          </Envelope>
          <div style={{ ...labelStyle, fontSize: 9, color: T.mute, textAlign:'center', marginTop: 8 }}>
            点击 · 拆开这封信
          </div>
        </div>

        {/* stats */}
        <div style={{ padding: '24px 20px 0' }}>
          <div style={{ display:'flex', gap: 8 }}>
            <StatCard icon={Ico.flag(18)} n="04" label="JOURNEYS" compact/>
            <StatCard icon={Ico.envelope(18)} n="09" label="CARDS" compact/>
            <StatCard icon={Ico.heart(18)} n="06" label="LOVED" color={T.red} compact/>
            <StatCard icon={Ico.pin(18)} n="03" label="CITIES" compact/>
          </div>
        </div>

        {/* current journey */}
        <div style={{ padding: '28px 20px 0' }}>
          <SectionLabel kicker="ONGOING · 进行中" title="江南水乡之旅"
            right={<span style={{ ...labelStyle, color: T.green }}>71%</span>}/>
          <div style={{
            background: T.card, border: `1px solid ${T.divider}`, borderRadius: 4,
            padding: '16px 18px 18px',
            position: 'relative', overflow:'hidden',
          }}>
            <div style={{ position:'absolute', top: -10, right: -10, opacity: .06 }}>
              <Stamp kind="nature" size={84}/>
            </div>
            <div style={{ display:'flex', alignItems:'center', gap:8 }}>
              <Pulse/>
              <span style={{ ...labelStyle, fontSize: 10, color: T.alive }}>第 5 天 / 共 7 天</span>
              <span style={{ marginLeft: 'auto', ...labelStyle, fontSize: 9 }}>TRAVEL · 01</span>
            </div>
            <div style={{ marginTop: 8, fontSize: 13, color: T.body, display:'flex', alignItems:'center', gap: 6 }}>
              <span style={{ color: T.green }}>{Ico.pin(13)}</span>
              <span style={{ fontFamily: F.serif }}>杭州 · 苏州 · 乌镇</span>
            </div>
            <div style={{ marginTop: 16, height: 4, background: T.divider, borderRadius: 99, overflow:'hidden' }}>
              <div style={{ width: '71%', height: '100%', background: T.green, borderRadius: 99 }}/>
            </div>
            <div style={{ marginTop: 10, display:'flex', justifyContent:'space-between',
              fontFamily: F.mono, fontSize: 10, color: T.mute, letterSpacing: 1.5 }}>
              <span>05·08 · 启程</span><span>05·15 · 归程</span>
            </div>
          </div>
        </div>

        {/* recent postcards */}
        <div style={{ padding: '28px 20px 0' }}>
          <SectionLabel kicker="ARCHIVE · 信件回执" title="最近寄出"
            right={<span onClick={()=>setActive('timeline')} style={{ ...labelStyle, color: T.green, cursor:'pointer' }}>全部 →</span>}/>
          <div style={{ display:'flex', flexDirection:'column', gap: 10 }}>
            {[
              { id:'c1', location:'西湖断桥', city:'杭州', note:'断桥不断，情意绵绵', tone:'forest', fav: favs.c1, date:'05·10', stamp:'classic' },
              { id:'c2', location:'雷峰塔', city:'杭州', note:'白娘子的传说', tone:'sand', fav: favs.c2, date:'05·09', stamp:'nature' },
              { id:'c3', location:'灵隐寺', city:'杭州', note:'深山藏古寺', tone:'dusk', fav: favs.c3, date:'05·09', stamp:'culture' },
            ].map(p => (
              <div key={p.id} onClick={()=>onOpenDetail?.(p)} style={{ cursor:'pointer' }}>
                <PostcardRow p={p} onFav={(e)=>{ e.stopPropagation(); toggle(p.id); }}/>
              </div>
            ))}
          </div>
        </div>
        <div style={{ height: 28 }}/>
      </Body>
      <TabBar active="home" onChange={setActive}/>
    </PhoneFrame>
  );
}

// ───────────────────────── Tab 2: TIMELINE ─────────────────────────
function ScreenTimeline({ setActive, onOpenDetail }) {
  const [favs, setFavs] = React.useState({ a: true, b: true, c: false, d: true, e: false });
  const toggle = k => setFavs(s => ({ ...s, [k]: !s[k] }));
  const groups = [
    {
      date: '5 · 10', month: 'MAY', y: '2024', wk: '星期五',
      cards: [
        { id:'a', location:'西湖断桥', city:'杭州', note:'断桥不断，情意绵绵', tone:'forest' },
        { id:'b', location:'雷峰塔',   city:'杭州', note:'白娘子的传说', tone:'sand' },
      ],
    },
    {
      date: '5 · 09', month: 'MAY', y: '2024', wk: '星期四',
      cards: [
        { id:'c', location:'灵隐寺', city:'杭州', note:'深山藏古寺', tone:'dusk' },
      ],
    },
    {
      date: '4 · 12', month: 'APR', y: '2024', wk: '星期五',
      cards: [
        { id:'d', location:'莫高窟', city:'敦煌', note:'千年壁画，艺术瑰宝', tone:'sand' },
        { id:'e', location:'鸣沙山', city:'敦煌', note:'沙漠中的歌声', tone:'sand' },
      ],
    },
  ];

  return (
    <PhoneFrame>
      <Body padBottom={96}>
        <PostalHeader
          kicker="TIMELINE · 时间轴"
          title="回顾旅途"
          subtitle="按日期倒序 · 共 9 张明信片"
        />
        <div style={{ padding: '24px 20px 0' }}>
          {groups.map((g, gi) => (
            <div key={g.date+gi} style={{ marginBottom: 22 }}>
              {/* group header — left date column, hairline */}
              <div style={{ display:'flex', alignItems:'baseline', gap: 14, marginBottom: 12 }}>
                <div style={{ width: 56, flexShrink: 0 }}>
                  <div style={{ fontFamily: F.display, fontWeight: 400, fontSize: 22, lineHeight: 1, letterSpacing: -0.5 }}>
                    {g.date}
                  </div>
                  <div style={{ ...labelStyle, fontSize: 9, marginTop: 4 }}>{g.month} · {g.wk}</div>
                </div>
                <div style={{ flex:1, height: 1, background: T.divider }}/>
                <span style={{ ...labelStyle, fontSize: 9 }}>{String(g.cards.length).padStart(2,'0')} 张</span>
              </div>

              <div style={{ position:'relative', paddingLeft: 14 }}>
                {/* vertical rail */}
                <div style={{
                  position:'absolute', left: 2, top: 8, bottom: 8,
                  width: 1, background: T.divider,
                }}/>
                <div style={{ display:'flex', flexDirection:'column', gap: 10 }}>
                  {g.cards.map((p, i) => {
                    const first = gi===0 && i===0;
                    return (
                      <div key={p.id} style={{ position:'relative' }}>
                        <div style={{
                          position:'absolute', left: -16, top: 24, width: 9, height: 9,
                          borderRadius: 99, background: first ? T.green : T.bg,
                          border: `1.5px solid ${T.green}`,
                          boxShadow: first ? `0 0 0 4px ${T.greenSoft}` : 'none',
                        }}/>
                        <div onClick={()=>onOpenDetail?.(p)} style={{ cursor:'pointer' }}>
                          <PostcardRow p={{...p, fav: favs[p.id]}} onFav={(e)=>{e.stopPropagation(); toggle(p.id);}}/>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          ))}
          <div style={{
            textAlign:'center', color: T.whisper, fontSize: 10, padding: '8px 0 24px',
            fontFamily: F.mono, letterSpacing: 4,
          }}>— · 旅程开始 · —</div>
        </div>
      </Body>
      <TabBar active="timeline" onChange={setActive}/>
    </PhoneFrame>
  );
}

// ───────────────────────── Tab 3: RECORD ─────────────────────────
function ScreenRecord({ setActive }) {
  const [stamp, setStamp] = React.useState('classic');
  const [photoSet, setPhotoSet] = React.useState(true);
  const [loc, setLoc] = React.useState('西湖断桥');
  const [city, setCity] = React.useState('杭州');
  const [country, setCountry] = React.useState('中国');
  const [note, setNote] = React.useState('断桥不断，情意绵绵。和心爱的人一起，在湖边看落日。');
  const stamps = Object.keys(T.stamps);

  return (
    <PhoneFrame>
      <Body padBottom={96}>
        <PostalHeader
          kicker="NEW POSTCARD · 寄往未来"
          title="记录明信片"
          subtitle="从这里寄出一张明信片 · No. 0010"
        />
        <div style={{ padding: '20px 20px 0', display:'flex', flexDirection:'column', gap: 14 }}>
          {/* photo upload */}
          {photoSet ? (
            <div style={{ position:'relative' }}>
              <Photo label="WEST LAKE · HANGZHOU" tone="forest" h={210} radius={10} code="05·10"/>
              <button onClick={()=>setPhotoSet(false)} style={{
                all:'unset', cursor:'pointer', position:'absolute', top: 10, right: 10,
                background: 'rgba(20,15,10,0.55)', color:'#F4EFE5', borderRadius: 6,
                width: 32, height: 32, display:'flex', alignItems:'center', justifyContent:'center',
                backdropFilter:'blur(8px)',
              }}>{Ico.camera(14)}</button>
            </div>
          ) : (
            <div style={{
              border: `1px dashed ${T.rule}`, borderRadius: 10, padding: 36,
              background: T.card, display:'flex', flexDirection:'column', alignItems:'center', gap: 10,
            }}>
              <div style={{ color: T.green }}>{Ico.camera(28)}</div>
              <div style={{ fontFamily: F.display, fontSize: 16, color: T.ink, fontWeight: 500 }}>点击拍照或选择照片</div>
              <div style={{ ...labelStyle, fontSize: 9 }}>4:3 · MAX 10MB</div>
            </div>
          )}

          <FormCard label="LOCATION" cn="位置" icon={Ico.pin(14)} required>
            <input value={loc} onChange={e=>setLoc(e.target.value)} style={inputStyle}/>
            <button style={btnGhost}>{Ico.pin(12)}<span style={{marginLeft:4}}>定位</span></button>
          </FormCard>

          <FormCard label="CITY" cn="城市" icon={Ico.map(14)} required>
            <input value={city} onChange={e=>setCity(e.target.value)} style={inputStyle}/>
          </FormCard>

          <FormCard label="COUNTRY" cn="国家" icon={Ico.globe(14)}>
            <input value={country} onChange={e=>setCountry(e.target.value)} style={inputStyle}/>
          </FormCard>

          <FormCard label="MESSAGE" cn="备注" icon={Ico.edit(14)} stack>
            <textarea value={note} onChange={e=>setNote(e.target.value)} rows={3}
              style={{...inputStyle, resize:'none', width:'100%', padding: '6px 0',
                fontFamily: F.serif, fontStyle: 'italic', fontSize: 14, lineHeight: 1.6 }}/>
            <div style={{ textAlign:'right', ...labelStyle, fontSize: 9 }}>{note.length} / 200</div>
          </FormCard>

          <FormCard label="STAMP" cn="邮票样式" icon={Ico.stamp(14)} stack>
            <div style={{ display:'flex', gap: 10, overflowX:'auto', paddingBottom: 4, paddingTop: 6 }}>
              {stamps.map(k => {
                const on = k === stamp;
                return (
                  <button key={k} onClick={()=>setStamp(k)} style={{
                    all:'unset', cursor:'pointer', display:'flex', flexDirection:'column',
                    alignItems:'center', gap: 7, padding: '8px 10px', borderRadius: 6,
                    border: `1px solid ${on ? T.green : T.divider}`,
                    background: on ? T.greenSoft : 'transparent',
                    minWidth: 64, flexShrink: 0,
                  }}>
                    <Stamp kind={k} size={36}/>
                    <span style={{ fontSize: 11, color: on ? T.green : T.body, fontWeight: on ? 600 : 500,
                      fontFamily: F.serif }}>{T.stamps[k].name}</span>
                  </button>
                );
              })}
            </div>
          </FormCard>

          {/* live preview */}
          <div style={{ marginTop: 14 }}>
            <SectionLabel kicker="LIVE PREVIEW · 预览" title="明信片"/>
            <PostcardPreview photo={loc.toUpperCase()} tone="forest" location={loc} city={city} country={country} note={note.slice(0,28)} stamp={stamp}/>
          </div>

          {/* submit */}
          <button style={{
            all:'unset', cursor:'pointer', textAlign:'center',
            background: T.green, color:'#F4EFE5', borderRadius: 6,
            padding: '16px 0', fontWeight: 500, fontSize: 14,
            letterSpacing: 6, fontFamily: F.display,
            marginTop: 14,
          }}>寄出明信片 ›</button>
          <div style={{ textAlign:'center', ...labelStyle, fontSize: 9, marginTop: 8 }}>POSTAGE PAID · 旅笺</div>
          <div style={{ height: 14 }}/>
        </div>
      </Body>
      <TabBar active="record" onChange={setActive}/>
    </PhoneFrame>
  );
}

const inputStyle = {
  border: 'none', outline: 'none', background: 'transparent',
  fontFamily: F.serif, fontSize: 15, color: T.ink, flex: 1, padding: 0, minWidth: 0,
  letterSpacing: 0.3, fontWeight: 500,
};
const btnGhost = {
  all:'unset', cursor:'pointer', display:'inline-flex', alignItems:'center',
  padding:'5px 10px', borderRadius: 4,
  color: T.green, fontSize: 11, fontWeight: 500,
  border: `1px solid ${T.green}55`, letterSpacing: 1,
  fontFamily: F.mono,
};

function FormCard({ label, cn, icon, required, stack, children }) {
  return (
    <div style={{
      background: T.card, borderRadius: 6, padding: '12px 16px',
      border: `1px solid ${T.divider}`,
    }}>
      <div style={{ display:'flex', alignItems:'center', gap: 8, marginBottom: stack ? 4 : 0 }}>
        <span style={{ color: T.green }}>{icon}</span>
        <span style={{ ...labelStyle, fontSize: 9 }}>{label}</span>
        <span style={{ fontFamily: F.serif, fontSize: 11, color: T.mute }}>· {cn}</span>
        {required && <span style={{ color: T.red, fontSize: 11, marginLeft: -2, fontFamily: F.serif }}>*</span>}
      </div>
      {stack ? children : (
        <div style={{ display:'flex', alignItems:'center', gap: 8, marginTop: 6 }}>{children}</div>
      )}
    </div>
  );
}

// ───────────────────────── Tab 4: MAP ─────────────────────────
function ScreenMap({ setActive }) {
  const cities = [
    { n: '北京', en: 'BJ', tag:'起点' },
    { n: '杭州', en: 'HZ' },
    { n: '敦煌', en: 'DH' },
    { n: '重庆', en: 'CQ', tag:'当前' },
  ];
  const trips = [
    { title:'江南水乡之旅', dest:'杭州 · 苏州', date:'5·8 — 5·15', icon: Ico.rocket, status:'进行中', en:'ONGOING', accent: T.green },
    { title:'西北风光行',   dest:'敦煌 · 嘉峪关', date:'4·14 — 4·21', icon: Ico.check, status:'已完成', en:'POSTED', accent: T.mute },
    { title:'山城重庆',     dest:'重庆 · 武隆',   date:'3·14 — 3·20', icon: Ico.check, status:'已完成', en:'POSTED', accent: T.mute },
    { title:'彩云之南',     dest:'丽江 · 大理',   date:'5·29 — 6·5',  icon: Ico.cal,   status:'待出发', en:'DRAFT',  accent: '#1F4B66' },
  ];

  return (
    <PhoneFrame>
      <Body padBottom={96}>
        <PostalHeader
          kicker="ATLAS · 旅行足迹"
          title="走过的远方"
          subtitle="03 城市 · 09 张明信片 · 一段尚未结束的旅程"
        />

        {/* footprint card */}
        <div style={{ padding: '24px 20px 0' }}>
          <div style={{
            background: T.card, borderRadius: 6, padding: 20,
            border: `1px solid ${T.divider}`,
          }}>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
              <div>
                <div style={{ ...labelStyle, color: T.green, marginBottom: 4 }}>ROUTE · 路线图</div>
                <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 18, color: T.ink }}>我的足迹</div>
              </div>
              <div style={{ ...labelStyle, fontFamily: F.mono }}>{cities.length} CITIES</div>
            </div>
            {/* route */}
            <div style={{ marginTop: 20, position:'relative', height: 92, padding: '0 4px' }}>
              <svg width="100%" height="92" viewBox="0 0 320 92" preserveAspectRatio="none" style={{ position:'absolute', inset:0 }}>
                <path d="M 20 50 C 80 18, 130 78, 180 40 S 280 60, 300 48"
                  fill="none" stroke={T.green} strokeWidth="1" strokeDasharray="3 4" opacity=".7"/>
              </svg>
              {cities.map((c, i) => {
                const positions = [{l:'6%',t:50},{l:'34%',t:65},{l:'56%',t:18},{l:'90%',t:48}];
                const first = i===0, last = i===cities.length-1;
                return (
                  <div key={c.n} style={{
                    position:'absolute', left: positions[i].l, top: positions[i].t,
                    transform:'translate(-50%, -50%)',
                    display:'flex', flexDirection:'column', alignItems:'center', gap: 6,
                  }}>
                    <div style={{
                      width: 22, height: 22, borderRadius: 99,
                      background: first ? T.red : (last ? T.green : T.bg),
                      border: `1.5px solid ${first ? T.red : T.green}`,
                      color: (first || last) ? '#F4EFE5' : T.green,
                      display:'flex', alignItems:'center', justifyContent:'center',
                      fontFamily: F.mono, fontSize: 10, fontWeight: 600,
                    }}>{i+1}</div>
                    <div style={{ fontFamily: F.serif, fontWeight: 500, fontSize: 11, color: T.ink }}>{c.n}</div>
                    {c.tag && <div style={{ ...labelStyle, fontSize: 8, color: first?T.red:T.green }}>{c.tag}</div>}
                  </div>
                );
              })}
            </div>
            <div style={{ marginTop: 12, paddingTop: 12, borderTop: `1px solid ${T.divider}`,
              display:'flex', justifyContent:'space-between',
              fontFamily: F.mono, fontSize: 10, color: T.mute, letterSpacing: 1.5 }}>
              <span>北京 → 重庆</span>
              <span>04 · 经停</span>
              <span>05 · 仍在路上</span>
            </div>
          </div>
        </div>

        {/* 2x2 stats */}
        <div style={{ padding: '20px 20px 0' }}>
          <div style={{ display:'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <BigStat icon={Ico.globe(18)} n="01" label="COUNTRIES · 国家"/>
            <BigStat icon={Ico.pin(18)} n="03" label="CITIES · 城市" color={T.red}/>
            <BigStat icon={Ico.envelope(18)} n="09" label="POSTCARDS · 明信片"/>
            <BigStat icon={Ico.flag(18)} n="04" label="JOURNEYS · 旅程"/>
          </div>
        </div>

        {/* trips */}
        <div style={{ padding: '28px 20px 0' }}>
          <SectionLabel kicker="JOURNEYS · 旅程档案" title="路线"/>
          <div style={{ display:'flex', flexDirection:'column', gap: 0,
            background: T.card, border:`1px solid ${T.divider}`, borderRadius: 6, overflow:'hidden' }}>
            {trips.map((t,i) => (
              <div key={i} style={{
                padding: '14px 16px',
                display:'flex', alignItems:'center', gap: 12,
                borderBottom: i<trips.length-1 ? `1px solid ${T.divider}` : 'none',
              }}>
                <div style={{
                  width: 36, height: 36, borderRadius: 4, color: t.accent,
                  display:'flex', alignItems:'center', justifyContent:'center',
                  border: `1px solid ${t.accent}33`,
                }}>{t.icon(18)}</div>
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontFamily: F.display, fontWeight: 500, color: T.ink, fontSize: 15 }}>{t.title}</div>
                  <div style={{ fontSize: 11, color: T.body, marginTop: 3, fontFamily: F.mono, letterSpacing: 1 }}>
                    {t.dest} <span style={{ color: T.mute }}>·  {t.date}</span>
                  </div>
                </div>
                <div style={{ textAlign:'right' }}>
                  <div style={{ ...labelStyle, fontSize: 9, color: t.accent }}>{t.en}</div>
                  <div style={{ fontSize: 11, color: t.accent, marginTop: 2, fontFamily: F.serif, fontWeight: 500 }}>{t.status}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div style={{ height: 28 }}/>
      </Body>
      <TabBar active="map" onChange={setActive}/>
    </PhoneFrame>
  );
}

function BigStat({ icon, n, label, color = T.green }) {
  return (
    <div style={{
      background: T.card, borderRadius: 6, padding: 16,
      border: `1px solid ${T.divider}`,
      display:'flex', alignItems:'center', gap: 14,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 99, color,
        display:'flex', alignItems:'center', justifyContent:'center',
        border: `1px solid ${color}33`,
      }}>{icon}</div>
      <div>
        <div style={{ fontFamily: F.display, fontSize: 26, fontWeight: 400, color: T.ink, lineHeight: 1, letterSpacing: -0.5 }}>{n}</div>
        <div style={{ ...labelStyle, fontSize: 8, marginTop: 4 }}>{label}</div>
      </div>
    </div>
  );
}

// ───────────────────────── Tab 5: PROFILE ─────────────────────────
function ScreenProfile({ setActive }) {
  return (
    <PhoneFrame>
      <Body padBottom={96}>
        {/* hero — the one screen with green emphasis */}
        <div style={{
          position:'relative',
          background: `linear-gradient(180deg, ${T.green} 0%, ${T.greenDeep} 100%)`,
          color: '#F4EFE5', textAlign:'center', overflow:'hidden',
          paddingTop: 60, paddingBottom: 70,
        }}>
          {/* faint cross-hatch grain */}
          <div aria-hidden style={{
            position:'absolute', inset:0, opacity: .07, pointerEvents:'none',
            background:'repeating-linear-gradient(45deg, transparent 0 14px, rgba(244,239,229,0.5) 14px 15px)',
          }}/>
          {/* corner perforation accent */}
          <div aria-hidden style={{
            position:'absolute', top: 80, left:0, right:0, height: 1,
            backgroundImage: `repeating-linear-gradient(90deg, rgba(244,239,229,0.5) 0 4px, transparent 4px 8px)`,
          }}/>
          <div style={{ position:'relative', zIndex:1 }}>
            <div style={{ ...labelStyle, color:'rgba(244,239,229,0.7)', letterSpacing: 6 }}>
              旅笺 · CHINA POSTCARDS
            </div>
            {/* monogram avatar */}
            <div style={{
              width: 86, height: 86, borderRadius: 99, margin: '28px auto 0',
              background: T.bg, color: T.green,
              display:'flex', alignItems:'center', justifyContent:'center',
              fontFamily: F.display, fontWeight: 500, fontSize: 36,
              boxShadow: '0 8px 22px rgba(0,0,0,0.25)',
              border: '1px solid rgba(244,239,229,0.4)',
            }}>旅</div>
            <div style={{ marginTop: 16, fontFamily: F.display, fontWeight: 400, fontSize: 26, letterSpacing: 1 }}>远方旅人</div>
            <div style={{ marginTop: 6, fontFamily: F.serif, fontStyle:'italic', fontSize: 13, opacity:.75 }}>初出茅庐 · Wanderer</div>

            {/* mail box id */}
            <div style={{
              marginTop: 24, display:'inline-flex', alignItems:'center', gap: 10,
              padding: '8px 18px', borderRadius: 99,
              border: '1px solid rgba(244,239,229,0.32)',
              fontFamily: F.mono, fontSize: 11, letterSpacing: 3,
            }}>
              个人邮箱 <span style={{ opacity:.5 }}>·</span> CN — 839204
            </div>
            <div style={{ marginTop: 12, ...labelStyle, color:'rgba(244,239,229,0.55)', fontSize: 9 }}>
              JOINED 32 DAYS · 已加入 32 天
            </div>
          </div>
        </div>

        {/* floating stats card */}
        <div style={{ padding: '0 20px', marginTop: -36, position:'relative' }}>
          <div style={{
            background: T.card, borderRadius: 6,
            padding: '18px 8px', display:'flex',
            border: `1px solid ${T.divider}`,
            boxShadow: '0 10px 28px rgba(40,30,15,0.10)',
          }}>
            {[
              { n:'04', l:'JOURNEYS', cn:'旅程' },
              { n:'09', l:'CARDS',    cn:'明信片' },
              { n:'06', l:'LOVED',    cn:'收藏' },
            ].map((it, i) => (
              <React.Fragment key={i}>
                <div style={{ flex:1, textAlign:'center' }}>
                  <div style={{ fontFamily: F.display, fontSize: 26, fontWeight: 400, color: T.ink, letterSpacing: -0.5 }}>{it.n}</div>
                  <div style={{ ...labelStyle, fontSize: 8, marginTop: 4 }}>{it.l}</div>
                  <div style={{ fontFamily: F.serif, fontSize: 11, color: T.body, marginTop: 1 }}>{it.cn}</div>
                </div>
                {i < 2 && <div style={{ width: 1, background: T.divider }}/>}
              </React.Fragment>
            ))}
          </div>
        </div>

        {/* menus */}
        <div style={{ padding: '24px 20px 0' }}>
          {/* highlighted album entry */}
          <div style={{
            background: T.cardWarm, borderRadius: 6,
            border: `1px solid ${T.divider}`,
            padding: '14px 16px', marginBottom: 22,
            display:'flex', alignItems:'center', gap: 14, cursor:'pointer',
            position:'relative', overflow:'hidden',
          }}>
            <div style={{ position:'absolute', right: -6, top: -6, opacity: .14 }}>
              <Stamp kind="classic" size={62}/>
            </div>
            <div style={{
              width: 44, height: 44, borderRadius: 4,
              background: T.greenSoft, color: T.green,
              display:'flex', alignItems:'center', justifyContent:'center',
              border: `1px solid ${T.green}33`,
            }}>{Ico.stamp(20)}</div>
            <div style={{ flex:1, minWidth:0 }}>
              <div style={{ ...labelStyle, fontSize: 9, color: T.green }}>STAMP ALBUM · 集邮册</div>
              <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 16, color: T.ink, marginTop: 2 }}>我的集邮册</div>
              <div style={{ fontFamily: F.serif, fontStyle:'italic', fontSize: 12, color: T.body, marginTop: 2 }}>已收集 06 / 24 款 · 5 个系列</div>
            </div>
            <div style={{ color: T.mute }}>{Ico.chev(13)}</div>
          </div>

          <MenuGroup title="设置 · SETTINGS" rows={[
            { i: Ico.edit(14), t: '编辑昵称', sub: '远方旅人' },
            { i: Ico.stamp(14), t: '默认邮票样式', sub: '经典 Classic' },
            { i: Ico.envelope(14), t: '邮箱号码', sub: 'CN-839204', mono: true },
          ]}/>
          <MenuGroup title="关于 · ABOUT" rows={[
            { i: Ico.envelope(14), t: '隐私协议', sub: '' },
            { i: Ico.envelope(14), t: '用户协议', sub: '' },
            { i: Ico.envelope(14), t: '关于我们', sub: 'v1.2.0', mono: true },
          ]}/>
          <MenuGroup title="数据 · DATA" rows={[
            { i: Ico.flag(14), t: '重置数据', sub: '清空所有明信片', danger: true },
          ]}/>
          <div style={{ textAlign:'center', marginTop: 26, paddingBottom: 4 }}>
            <div style={{ fontFamily: F.display, fontStyle:'italic', color: T.body, fontSize: 14 }}>记录旅途，寄往远方</div>
            <div style={{ ...labelStyle, fontSize: 9, marginTop: 6 }}>VERSION 1.2.0 · 旅笺</div>
          </div>
        </div>
        <div style={{ height: 20 }}/>
      </Body>
      <TabBar active="profile" onChange={setActive}/>
    </PhoneFrame>
  );
}

function MenuGroup({ title, rows }) {
  return (
    <div style={{ marginBottom: 22 }}>
      <div style={{ ...labelStyle, marginBottom: 8, paddingLeft: 2 }}>{title}</div>
      <div style={{
        background: T.card, borderRadius: 6,
        border: `1px solid ${T.divider}`,
        overflow: 'hidden',
      }}>
        {rows.map((r, i) => (
          <div key={i} style={{
            display:'flex', alignItems:'center', gap: 14, padding: '14px 16px',
            borderBottom: i < rows.length-1 ? `1px solid ${T.divider}` : 'none',
            cursor:'pointer',
          }}>
            <div style={{ color: r.danger ? T.red : (r.accent ? T.green : T.mute) }}>{r.i}</div>
            <div style={{ flex:1 }}>
              <div style={{ fontFamily: F.serif, fontSize: 14, color: r.danger ? T.red : T.ink, fontWeight: 500 }}>{r.t}</div>
            </div>
            {r.sub && <div style={{ fontSize: 12, color: T.mute, fontFamily: r.mono ? F.mono : F.serif, letterSpacing: r.mono ? 1 : 0 }}>{r.sub}</div>}
            <div style={{ color: T.whisper }}>{Ico.chev(11)}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {
  ScreenHome, ScreenTimeline, ScreenRecord, ScreenMap, ScreenProfile,
  SectionLabel, FormCard, inputStyle, btnGhost, BigStat, Pulse, MetaRow,
});

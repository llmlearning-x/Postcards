// 旅笺 · Sub pages + Launch (refined v2)

// ───────────────────────── DETAIL ─────────────────────────
function ScreenDetail() {
  const [fav, setFav] = React.useState(true);
  return (
    <PhoneFrame>
      <Body padBottom={0}>
        {/* big photo hero */}
        <div style={{ position:'relative' }}>
          <Photo label="WEST LAKE · DUAN BRIDGE" tone="forest" h={420} radius={0} code="N° 0007">
            {/* refined postmark — concentric circles */}
            <div style={{
              position:'absolute', top: 78, right: 18, transform: 'rotate(-9deg)',
              opacity: .9,
            }}>
              <svg width="86" height="86" viewBox="0 0 86 86">
                <circle cx="43" cy="43" r="38" fill="none" stroke="#F4EFE5" strokeWidth="1" opacity="0.5"/>
                <circle cx="43" cy="43" r="33" fill="none" stroke="#F4EFE5" strokeWidth="1.2"/>
                <circle cx="43" cy="43" r="26" fill="none" stroke="#F4EFE5" strokeWidth="0.6" opacity="0.6"/>
                <text x="43" y="35" textAnchor="middle" fill="#F4EFE5" style={{ fontFamily: F.mono, fontSize: 8, letterSpacing: 2 }}>HANGZHOU</text>
                <text x="43" y="48" textAnchor="middle" fill="#F4EFE5" style={{ fontFamily: F.display, fontSize: 13, fontWeight: 500 }}>05·10</text>
                <text x="43" y="58" textAnchor="middle" fill="#F4EFE5" style={{ fontFamily: F.mono, fontSize: 7, letterSpacing: 2, opacity: .8 }}>2024</text>
              </svg>
            </div>
          </Photo>
          <div style={{
            position:'absolute', bottom: 0, left:0, right:0, height: 80,
            background: `linear-gradient(180deg, transparent, ${T.bg})`,
          }}/>
        </div>

        {/* fixed top nav */}
        <div style={{
          position:'absolute', top: 0, left: 0, right: 0, paddingTop: 50,
          height: 100, display:'flex', alignItems:'center', justifyContent:'space-between',
          padding: '50px 16px 0', zIndex: 20,
        }}>
          <button style={navBtn}>{Ico.back(20)}</button>
          <div style={{
            ...labelStyle, color: 'rgba(244,239,229,0.95)',
            textShadow:'0 2px 6px rgba(0,0,0,0.3)',
          }}>POSTCARD · 明信片</div>
          <button style={navBtn}>{Ico.more(20)}</button>
        </div>

        {/* content card overlapping photo */}
        <div style={{ padding: '0 18px', marginTop: -38, position:'relative', zIndex: 5 }}>
          <div style={{
            background: T.card, borderRadius: 6, padding: '22px 22px 18px',
            border: `1px solid ${T.divider}`,
            boxShadow: '0 12px 32px rgba(40,30,15,0.10)',
            position: 'relative',
          }}>
            {/* header */}
            <div style={{ display:'flex', alignItems:'flex-start', gap: 14 }}>
              <div style={{ flex:1, minWidth: 0 }}>
                <div style={{ ...labelStyle, color: T.green, marginBottom: 6 }}>N° 0007 · 江南水乡之旅</div>
                <div style={{
                  fontFamily: F.display, fontWeight: 400, fontSize: 28,
                  color: T.ink, letterSpacing: -0.3, lineHeight: 1.1,
                }}>西湖断桥</div>
                <div style={{ ...labelStyle, fontFamily: F.mono, fontSize: 10, marginTop: 6, color: T.body }}>
                  HANGZHOU · 30.25° N, 120.15° E
                </div>
              </div>
              <Stamp kind="classic" size={56} rotate={-3}/>
            </div>

            {/* meta row */}
            <div style={{ marginTop: 16, paddingTop: 14, borderTop: `1px solid ${T.divider}`,
              display:'grid', gridTemplateColumns:'repeat(3, 1fr)', gap: 16 }}>
              <Meta k="DATE" v="2024 · 05 · 10"/>
              <Meta k="TIME" v="18 : 24"/>
              <Meta k="WEATHER" v="雨后初晴"/>
            </div>

            {/* note — handwriting */}
            <div style={{
              marginTop: 20, padding: '16px 14px',
              background: T.bg, borderRadius: 4,
              border: `1px solid ${T.divider}`,
              position: 'relative',
            }}>
              <div style={{ ...labelStyle, fontSize: 9, color: T.green, marginBottom: 10 }}>MESSAGE · 旅人手记</div>
              <div style={{
                fontFamily: F.display, fontStyle: 'italic',
                color: T.ink, fontSize: 15, lineHeight: 1.75,
                letterSpacing: 0.2,
              }}>
                断桥不断，情意绵绵。和心爱的人一起，在湖边看落日，水波温柔，远山如黛。<br/>
                <span style={{ marginLeft: 24 }}>那一刻，时间仿佛停止了。</span>
              </div>
              <div style={{ marginTop: 14, paddingTop: 10, borderTop: `1px dashed ${T.divider}`,
                display:'flex', justifyContent:'space-between',
                ...labelStyle, fontSize: 9 }}>
                <span>— 远方旅人 ·  写于湖边</span>
                <span>05·10</span>
              </div>
            </div>
          </div>

          {/* actions */}
          <div style={{ display:'flex', gap: 8, marginTop: 14 }}>
            <ActionBtn onClick={()=>setFav(f=>!f)} icon={Ico.heart(16, fav?T.red:'none')} label="收藏" en="LOVE" active={fav} accent={T.red}/>
            <ActionBtn icon={Ico.edit(16)} label="编辑" en="EDIT"/>
            <ActionBtn icon={Ico.share(16)} label="分享" en="SHARE"/>
          </div>

          {/* journey context */}
          <div style={{ marginTop: 26 }}>
            <SectionLabel kicker="JOURNEY · 同一旅程" title="江南水乡之旅"
              right={<span style={{ ...labelStyle, color: T.green }}>04 张 →</span>}/>
            <div style={{ display:'flex', gap: 10, overflowX:'auto', paddingBottom: 8 }}>
              {[
                { l: '雷峰塔', t:'sand', date:'05·09' },
                { l: '灵隐寺', t:'dusk', date:'05·09' },
                { l: '苏堤春晓', t:'river', date:'05·11' },
                { l: '南屏晚钟', t:'rose', date:'05·11' },
              ].map((p,i) => (
                <div key={i} style={{ minWidth: 120, background: T.card, borderRadius: 6, padding: 8,
                  border: `1px solid ${T.divider}` }}>
                  <Photo label={p.l} tone={p.t} h={88} radius={3} code={p.date}/>
                  <div style={{ fontFamily: F.serif, fontWeight: 500, fontSize: 13, color: T.ink, marginTop: 8, padding: '0 4px 2px' }}>{p.l}</div>
                  <div style={{ ...labelStyle, fontSize: 8, padding: '0 4px 2px' }}>{p.date}</div>
                </div>
              ))}
            </div>
          </div>
          <div style={{ height: 36 }}/>
        </div>
      </Body>
    </PhoneFrame>
  );
}

function Meta({ k, v }) {
  return (
    <div>
      <div style={{ ...labelStyle, fontSize: 9 }}>{k}</div>
      <div style={{ marginTop: 4, fontFamily: F.serif, fontSize: 13, color: T.ink, fontWeight: 500 }}>{v}</div>
    </div>
  );
}

const navBtn = {
  all:'unset', cursor:'pointer', width: 38, height: 38, borderRadius: 99,
  background: 'rgba(20,15,10,0.35)', backdropFilter: 'blur(10px)',
  color: '#F4EFE5', display:'flex', alignItems:'center', justifyContent:'center',
  border: '1px solid rgba(244,239,229,0.18)',
};

function ActionBtn({ icon, label, en, active, accent, onClick }) {
  return (
    <button onClick={onClick} style={{
      all:'unset', cursor:'pointer', flex: 1, textAlign:'center',
      padding: '14px 0', borderRadius: 6, background: T.card,
      border: `1px solid ${T.divider}`,
      display:'flex', flexDirection:'column', alignItems:'center', gap: 5,
      color: active ? (accent || T.green) : T.body,
    }}>
      {icon}
      <span style={{ fontSize: 11, fontWeight: 500, fontFamily: F.serif }}>{label}</span>
      <span style={{ ...labelStyle, fontSize: 8 }}>{en}</span>
    </button>
  );
}

// ───────────────────────── EDIT ─────────────────────────
function ScreenEdit() {
  return (
    <PhoneFrame>
      <Body padBottom={96}>
        {/* sticky editorial nav */}
        <div style={{
          position:'sticky', top: 0, zIndex: 20,
          background: T.bg,
          paddingTop: 54, paddingBottom: 16,
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
            <div style={{ ...labelStyle, fontSize: 9 }}>EDITING · N° 0007</div>
            <div style={{ fontFamily: F.display, fontSize: 16, fontWeight: 500, color: T.ink, marginTop: 2 }}>编辑明信片</div>
          </div>
          <button style={{
            all:'unset', cursor:'pointer', fontSize: 12, fontWeight: 600,
            color: T.green, padding: '8px 14px', borderRadius: 99,
            border: `1px solid ${T.green}`, letterSpacing: 1,
            fontFamily: F.mono,
          }}>SAVE</button>
        </div>

        <div style={{ padding: '20px 20px', display:'flex', flexDirection:'column', gap: 14 }}>
          {/* note */}
          <div style={{
            display:'flex', gap: 12, padding: '12px 14px', borderRadius: 6,
            background: '#F9EFD9', color: '#6A5325', fontSize: 12,
            border: '1px solid #E6D8B0', alignItems:'flex-start',
          }}>
            <span style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 2, color: '#A37E2D', flexShrink: 0 }}>NOTE</span>
            <span style={{ fontFamily: F.serif, lineHeight: 1.5 }}>你正在编辑已寄出的明信片。修改不会改变原始记录时间。</span>
          </div>

          <Photo label="LINGYIN · 灵隐" tone="dusk" h={200} radius={10} code="05·09"/>

          <FormCard label="LOCATION" cn="位置" icon={Ico.pin(14)} required>
            <input defaultValue="灵隐寺" style={inputStyle}/>
            <button style={btnGhost}>{Ico.pin(12)}<span style={{marginLeft:4}}>定位</span></button>
          </FormCard>
          <FormCard label="CITY" cn="城市" icon={Ico.map(14)} required>
            <input defaultValue="杭州" style={inputStyle}/>
          </FormCard>
          <FormCard label="COUNTRY" cn="国家" icon={Ico.globe(14)}>
            <input defaultValue="中国" style={inputStyle}/>
          </FormCard>
          <FormCard label="MESSAGE" cn="备注" icon={Ico.edit(14)} stack>
            <textarea defaultValue="深山藏古寺，钟声穿云来。香烟袅袅，禅意悠悠。" rows={3}
              style={{...inputStyle, resize:'none', width:'100%', padding: '6px 0',
                fontFamily: F.serif, fontStyle: 'italic', lineHeight: 1.6 }}/>
            <div style={{ textAlign:'right', ...labelStyle, fontSize: 9 }}>22 / 200</div>
          </FormCard>
          <FormCard label="STAMP" cn="邮票样式" icon={Ico.stamp(14)} stack>
            <div style={{ display:'flex', gap: 10, overflowX:'auto', paddingBottom: 4, paddingTop: 6 }}>
              {Object.keys(T.stamps).map(k => {
                const on = k === 'culture';
                return (
                  <div key={k} style={{
                    display:'flex', flexDirection:'column', alignItems:'center', gap: 7,
                    padding: '8px 10px', borderRadius: 6,
                    border: `1px solid ${on ? T.green : T.divider}`,
                    background: on ? T.greenSoft : 'transparent',
                    minWidth: 64, flexShrink: 0,
                  }}>
                    <Stamp kind={k} size={36}/>
                    <span style={{ fontSize: 11, color: on ? T.green : T.body, fontWeight: on ? 600 : 500, fontFamily: F.serif }}>{T.stamps[k].name}</span>
                  </div>
                );
              })}
            </div>
          </FormCard>

          <button style={{
            all:'unset', cursor:'pointer', textAlign:'center',
            background: T.green, color:'#F4EFE5', borderRadius: 6,
            padding: '15px 0', fontWeight: 500, fontSize: 14,
            letterSpacing: 6, fontFamily: F.display,
            marginTop: 6,
          }}>保存修改 ›</button>

          <button style={{
            all:'unset', cursor:'pointer', textAlign:'center',
            padding: '13px 0', borderRadius: 6,
            color: T.red, fontSize: 13, fontWeight: 500,
            border: `1px solid ${T.red}33`,
            fontFamily: F.serif,
          }}>删除这张明信片</button>
          <div style={{ height: 4 }}/>
        </div>
      </Body>
    </PhoneFrame>
  );
}

// ───────────────────────── LAUNCH ─────────────────────────
function ScreenLaunch() {
  return (
    <PhoneFrame>
      <div style={{
        position:'absolute', inset:0, background: T.bg,
        display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
        overflow: 'hidden',
      }}>
        {/* airmail stripe top and bottom — single bold postal cue */}
        <AirMail sides="t" height={8} stripeWidth={6}/>
        <AirMail sides="b" height={8} stripeWidth={6}/>

        {/* central single stamp — calm and focused */}
        <Stamp kind="classic" size={132} rotate={-2}/>

        {/* title */}
        <div style={{
          marginTop: 44, fontFamily: F.display, fontWeight: 400, fontSize: 52,
          letterSpacing: 16, color: T.ink, paddingLeft: 16,
        }}>旅笺</div>
        <div style={{ marginTop: 14, ...labelStyle, fontSize: 10, letterSpacing: 8, color: T.green }}>
          · POSTCARDS ·
        </div>

        {/* slogan + thin loader */}
        <div style={{
          position:'absolute', bottom: 90,
          display:'flex', flexDirection:'column', alignItems:'center', gap: 18,
        }}>
          <div style={{ fontFamily: F.display, fontStyle:'italic', color: T.body, fontSize: 14 }}>
            写一张笺 · 寄向远方
          </div>
          <div style={{
            width: 80, height: 1.5, background: T.divider,
            position:'relative', overflow:'hidden',
          }}>
            <div style={{
              position:'absolute', left:0, top:0, bottom:0, width: '40%',
              background: T.green, animation: 'fySlide 1.6s ease-in-out infinite',
            }}/>
            <style>{`@keyframes fySlide{0%{transform:translateX(-100%)}100%{transform:translateX(250%)}}`}</style>
          </div>
        </div>
      </div>
    </PhoneFrame>
  );
}

Object.assign(window, { ScreenDetail, ScreenEdit, ScreenLaunch });

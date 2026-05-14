// 邮票收藏夹 + 明信片正反面 (refined v2)

// ─────────── STAMP SHEET — all 5 series stacked ───────────
function StampSheet() {
  const all = Object.keys(T.stamps);
  const groups = ['I','III','IV','V'].map(sid => ({
    id: sid,
    items: all.filter(k => T.stamps[k].series === sid),
    meta: {
      I:   { cn: '旅行', en: 'TRAVEL',     sub: '基础系列 · 6 款' },
      III: { cn: '四季', en: 'SEASONS',    sub: '限季发行 · 4 款' },
      IV:  { cn: '节气', en: 'SOLAR TERMS', sub: '24 节气 · 6 款代表' },
      V:   { cn: '远方', en: 'FAR LANDS',  sub: '地貌系列 · 4 款' },
    }[sid],
  }));
  return (
    <div style={{
      width:'100%', height:'100%', background: T.bg, padding: 36,
      fontFamily: F.sans, color: T.ink, overflow:'auto', boxSizing:'border-box',
    }}>
      <style>{`div::-webkit-scrollbar{display:none}`}</style>

      <div style={{
        display:'flex', justifyContent:'space-between', alignItems:'flex-end',
        marginBottom: 24, paddingBottom: 14, borderBottom: `1px solid ${T.divider}`,
      }}>
        <div>
          <div style={{ ...labelStyle, color: T.green, marginBottom: 8 }}>STAMP COLLECTION · 2024</div>
          <div style={{ fontFamily: F.display, fontWeight: 400, fontSize: 32, letterSpacing: -0.5, lineHeight: 1.05 }}>
            旅笺邮票总集
          </div>
          <div style={{ fontFamily: F.serif, fontStyle:'italic', fontSize: 13, color: T.body, marginTop: 8 }}>
            五个系列 · 二十款主题邮票 · 限量发行
          </div>
        </div>
        <div style={{ textAlign:'right', ...labelStyle, fontSize: 9 }}>
          <div>20 STAMPS · 5 SERIES</div>
          <div style={{ marginTop: 4 }}>SHEET 01 / 04</div>
        </div>
      </div>

      <div style={{ display:'flex', flexDirection:'column', gap: 28 }}>
        {groups.map(g => (
          <div key={g.id} style={{
            background: T.cardWarm,
            border: `1px solid ${T.divider}`,
            padding: '28px 28px 22px',
            position: 'relative',
            boxShadow: '0 8px 22px rgba(40,30,15,0.06)',
          }}>
            {/* corner marks */}
            {['tl','tr','bl','br'].map(p => (
              <svg key={p} width="14" height="14" viewBox="0 0 14 14" style={{
                position:'absolute',
                top: p[0]==='t' ? 8 : 'auto', bottom: p[0]==='b' ? 8 : 'auto',
                left: p[1]==='l' ? 8 : 'auto', right: p[1]==='r' ? 8 : 'auto',
                transform: p === 'tr' ? 'scaleX(-1)' : p === 'bl' ? 'scaleY(-1)' : p==='br' ? 'scale(-1,-1)' : 'none',
              }}>
                <path d="M 1 7 L 1 1 L 7 1" fill="none" stroke={T.body} strokeWidth="0.7"/>
                <circle cx="1" cy="1" r="0.9" fill={T.body}/>
              </svg>
            ))}
            {/* sheet header */}
            <div style={{ display:'flex', alignItems:'flex-end', justifyContent:'space-between',
              marginBottom: 18, paddingBottom: 10, borderBottom: `1px dashed ${T.divider}` }}>
              <div>
                <div style={{ ...labelStyle, color: T.green, marginBottom: 4 }}>SERIES · {g.id}</div>
                <div style={{ display:'flex', alignItems:'baseline', gap: 12 }}>
                  <span style={{ fontFamily: F.display, fontWeight: 500, fontSize: 20, letterSpacing: -0.3 }}>{g.meta.cn}</span>
                  <span style={{ ...labelStyle, fontSize: 9 }}>{g.meta.en}</span>
                </div>
                <div style={{ fontFamily: F.serif, fontStyle:'italic', fontSize: 11.5, color: T.body, marginTop: 4 }}>{g.meta.sub}</div>
              </div>
              <div style={{ ...labelStyle, fontSize: 9 }}>{String(g.items.length).padStart(2,'0')} STAMPS</div>
            </div>
            <div style={{
              display:'grid',
              gridTemplateColumns: g.items.length === 6 ? 'repeat(3, 1fr)' : 'repeat(4, 1fr)',
              gap: '24px 16px', justifyItems:'center',
            }}>
              {g.items.map((k, i) => (
                <div key={k} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap: 8 }}>
                  <Stamp kind={k} size={88}/>
                  <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 12, color: T.ink, marginTop: 2, letterSpacing: 0.4 }}>{T.stamps[k].name}</div>
                  <div style={{ ...labelStyle, fontSize: 8 }}>{T.stamps[k].name_en}</div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      <div style={{
        marginTop: 22, padding: 16, background: T.card, borderRadius: 6,
        border: `1px solid ${T.divider}`,
      }}>
        <div style={{ ...labelStyle, color: T.green, marginBottom: 8 }}>DESIGN NOTES · 设计说明</div>
        <div style={{ fontFamily: F.serif, fontSize: 12, color: T.body, lineHeight: 1.7 }}>
          每张邮票由穿孔纸边、油墨色内层、白色描线图案与英文名构成。
          四个系列分别围绕"旅行 · 四季 · 节气 · 远方"展开。每张邮票通过特定条件解锁
          —— 例如「霜降」只能在节气当天寄出，「海岛」需要抵达海边记录一张。
          Limited Series II（雪/雨/夜/远）则按动作触发：在雨天、夜晚或长距离旅行后获得。
        </div>
      </div>
    </div>
  );
}

// ─────────── POSTCARD FRONTS — 4 layouts ───────────
function PostcardFronts() {
  return (
    <div style={{
      width:'100%', height:'100%', background: T.bg, padding: 28,
      fontFamily: F.sans, color: T.ink, overflow:'auto', boxSizing:'border-box',
    }}>
      <style>{`div::-webkit-scrollbar{display:none}`}</style>

      <div style={{ marginBottom: 18, paddingBottom: 12, borderBottom: `1px solid ${T.divider}` }}>
        <div style={{ ...labelStyle, color: T.green, marginBottom: 6 }}>FRONT LAYOUTS · 正面排版</div>
        <div style={{ fontFamily: F.display, fontWeight: 400, fontSize: 24, letterSpacing: -0.3 }}>明信片 · 四种版式</div>
      </div>

      <div style={{ display:'flex', flexDirection:'column', gap: 22 }}>

        {/* A — editorial split */}
        <PostcardCard label="A" cn="编辑版式" sub="左照右文 · 衬线大标题">
          <div style={{ display:'flex', background: T.card, border: `1px solid ${T.divider}`, borderRadius: 4, overflow:'hidden', boxShadow:'0 8px 22px rgba(40,30,15,0.08)' }}>
            <Photo label="WEST LAKE" tone="forest" w={150} h={170} radius={0} code="05·10"/>
            <div style={{ flex:1, padding: '18px 16px', display:'flex', flexDirection:'column', justifyContent:'space-between' }}>
              <div>
                <div style={{ ...labelStyle, color: T.green, fontSize: 9 }}>HANGZHOU · 中国</div>
                <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 22, lineHeight: 1.1, marginTop: 6, letterSpacing: -0.3 }}>西湖断桥</div>
                <div style={{ fontFamily: F.serif, fontStyle:'italic', fontSize: 12, color: T.body, marginTop: 12, lineHeight: 1.55 }}>
                  "断桥不断，<br/>情意绵绵。"
                </div>
              </div>
              <div style={{ display:'flex', alignItems:'flex-end', justifyContent:'space-between', marginTop: 10 }}>
                <span style={{ ...labelStyle, fontSize: 9 }}>2024 · 05 · 10</span>
                <Stamp kind="classic" size={40} rotate={-3}/>
              </div>
            </div>
          </div>
        </PostcardCard>

        {/* B — full bleed with overlay */}
        <PostcardCard label="B" cn="全图叠层" sub="照片满铺 · 渐变文字层">
          <div style={{ position:'relative', borderRadius: 4, overflow:'hidden', boxShadow:'0 8px 22px rgba(40,30,15,0.1)' }}>
            <Photo label="CHONGQING NIGHT" tone="dusk" h={220} radius={0} code="03·14"/>
            <div style={{ position:'absolute', inset:0,
              background:'linear-gradient(180deg, rgba(0,0,0,0) 35%, rgba(0,0,0,0.72) 100%)' }}/>
            <div style={{ position:'absolute', left:18, right:18, bottom: 16, display:'flex', alignItems:'flex-end', gap:14 }}>
              <div style={{ flex:1, color:'#F4EFE5' }}>
                <div style={{ ...labelStyle, color:'rgba(244,239,229,0.7)', fontSize: 9 }}>CHONGQING · 中国</div>
                <div style={{ fontFamily: F.display, fontWeight: 400, fontSize: 26, letterSpacing: -0.3, marginTop: 6 }}>洪崖洞</div>
                <div style={{ fontFamily: F.serif, fontStyle:'italic', fontSize: 12, opacity:.9, marginTop: 6 }}>"千与千寻的世界。"</div>
              </div>
              <Stamp kind="city" size={48} rotate={3}/>
            </div>
            <div style={{
              position:'absolute', top: 16, right: 16, opacity: .92,
            }}>
              <svg width="62" height="62" viewBox="0 0 62 62" style={{ transform:'rotate(-10deg)' }}>
                <circle cx="31" cy="31" r="27" fill="none" stroke="#F4EFE5" strokeWidth="1"/>
                <text x="31" y="28" textAnchor="middle" fill="#F4EFE5" style={{ fontFamily: F.mono, fontSize: 7, letterSpacing: 2 }}>CHONGQING</text>
                <text x="31" y="38" textAnchor="middle" fill="#F4EFE5" style={{ fontFamily: F.display, fontSize: 11, fontWeight: 500 }}>03·14</text>
              </svg>
            </div>
          </div>
        </PostcardCard>

        {/* C — letterhead style with rules */}
        <PostcardCard label="C" cn="信笺式" sub="纸张色底 · 横线 + 邮戳水印">
          <div style={{
            background: T.cardWarm, border: `1px solid ${T.divider}`,
            padding: '16px 18px', borderRadius: 2,
            position: 'relative', overflow: 'hidden',
            boxShadow: '0 8px 22px rgba(40,30,15,0.08)',
          }}>
            <div style={{
              position:'absolute', top: 60, left: '50%', transform:'translateX(-50%) rotate(-12deg)',
              ...labelStyle, fontSize: 36, color: T.green, opacity: .06, letterSpacing: 14,
            }}>POSTCARD</div>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline', marginBottom: 14, paddingBottom: 10, borderBottom: `1px solid ${T.divider}` }}>
              <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 14, letterSpacing: 1 }}>旅笺</div>
              <div style={{ ...labelStyle, fontSize: 9 }}>N° 0008 · DUNHUANG</div>
            </div>
            <div style={{ display:'flex', gap: 14, position: 'relative' }}>
              <Photo label="MOGAO CAVES" tone="sand" w={120} h={110} radius={3} code="04·12"/>
              <div style={{ flex:1, minWidth:0 }}>
                <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 20, color: T.ink, lineHeight: 1.1, letterSpacing: -0.3 }}>莫高窟</div>
                <div style={{ ...labelStyle, fontSize: 9, marginTop: 6, color: T.body }}>敦煌 · GANSU</div>
                <div style={{ fontFamily: F.display, fontStyle:'italic', fontSize: 13, color: T.body, marginTop: 10, lineHeight: 1.55 }}>
                  "千年壁画，<br/>艺术瑰宝。"
                </div>
              </div>
            </div>
            <div style={{ marginTop: 14, paddingTop: 10, borderTop: `1px dashed ${T.divider}`,
              display:'flex', justifyContent:'space-between', alignItems:'center' }}>
              <span style={{ ...labelStyle, fontSize: 9 }}>STAMP · CULTURE · 文化</span>
              <Stamp kind="culture" size={40}/>
            </div>
          </div>
        </PostcardCard>

        {/* D — film strip */}
        <PostcardCard label="D" cn="胶片条" sub="黑色齿条 + 海洋邮票">
          <div style={{ borderRadius: 4, overflow:'hidden', background: '#14110A', boxShadow:'0 8px 22px rgba(40,30,15,0.12)' }}>
            <FilmStrip/>
            <Photo label="SANYA · 三亚" tone="river" h={130} radius={0} code="06·02"/>
            <FilmStrip/>
            <div style={{ background: T.card, padding: '14px 16px', display:'flex', alignItems:'center', gap: 14 }}>
              <div style={{ flex:1 }}>
                <div style={{ ...labelStyle, color: T.green, fontSize: 9 }}>SANYA · HAINAN</div>
                <div style={{ fontFamily: F.display, fontWeight: 500, fontSize: 18, color: T.ink, marginTop: 4 }}>三亚 · 海角</div>
                <div style={{ fontFamily: F.serif, fontStyle:'italic', fontSize: 12, color: T.body, marginTop: 6 }}>"海风裹着咸味，把日子吹得很慢。"</div>
              </div>
              <Stamp kind="ocean" size={42}/>
            </div>
          </div>
        </PostcardCard>

      </div>
      <div style={{ height: 18 }}/>
    </div>
  );
}

function PostcardCard({ label, cn, sub, children }) {
  return (
    <div>
      <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', marginBottom: 10 }}>
        <div style={{ display:'flex', alignItems:'baseline', gap: 10 }}>
          <span style={{ fontFamily: F.display, fontSize: 16, fontWeight: 500, color: T.green, letterSpacing: 1 }}>{label}</span>
          <span style={{ fontFamily: F.serif, fontSize: 13, color: T.ink }}>{cn}</span>
        </div>
        <span style={{ ...labelStyle, fontSize: 9 }}>{sub}</span>
      </div>
      {children}
    </div>
  );
}

function FilmStrip() {
  return (
    <div style={{
      height: 14, background: '#14110A',
      display:'flex', alignItems:'center', justifyContent:'space-around',
      paddingLeft: 6, paddingRight: 6,
    }}>
      {Array.from({length: 14}).map((_,i)=>(
        <div key={i} style={{ width: 10, height: 6, background: T.cardWarm, borderRadius: 1 }}/>
      ))}
    </div>
  );
}

// ─────────── POSTCARD BACK ───────────
function PostcardBack() {
  return (
    <div style={{
      width:'100%', height:'100%', background: T.bg, padding: 28,
      fontFamily: F.sans, color: T.ink, boxSizing:'border-box',
    }}>
      <div style={{ display:'flex', alignItems:'flex-end', justifyContent:'space-between', marginBottom: 16, paddingBottom: 12, borderBottom: `1px solid ${T.divider}` }}>
        <div>
          <div style={{ ...labelStyle, color: T.green, marginBottom: 4 }}>BACK · 明信片背面</div>
          <div style={{ fontFamily: F.display, fontWeight: 400, fontSize: 22, letterSpacing: -0.3 }}>写给未来的信</div>
        </div>
        <div style={{ ...labelStyle, fontSize: 9 }}>149 × 105 MM · 标准明信片尺寸</div>
      </div>

      <div style={{
        background: T.cardWarm, borderRadius: 2,
        padding: 22, boxShadow: '0 12px 32px rgba(40,30,15,0.10)',
        border: `1px solid ${T.divider}`,
        position: 'relative', overflow: 'hidden',
        backgroundImage: `linear-gradient(${T.divider}88 0.5px, transparent 0.5px)`,
        backgroundSize: '100% 24px',
        backgroundPosition: '0 36px',
        display:'grid', gridTemplateColumns: '1.1fr auto 1fr', gap: 20,
      }}>
        {/* watermark */}
        <div style={{
          position:'absolute', left: '50%', top:'50%', transform:'translate(-50%,-50%) rotate(-16deg)',
          ...labelStyle, fontSize: 60, color: T.green, opacity: .05, letterSpacing: 16, pointerEvents:'none',
        }}>POSTCARD</div>

        {/* left: message */}
        <div style={{ position:'relative', zIndex:1 }}>
          <div style={{ ...labelStyle, color: T.green, fontSize: 9, marginBottom: 14 }}>MESSAGE · 旅人手记</div>
          <div style={{
            fontFamily: F.display, fontStyle: 'italic', fontWeight: 400,
            color: T.ink, fontSize: 13.5, lineHeight: '24px',
            letterSpacing: 0.2,
          }}>
            亲爱的未来：<br/>
            今天到了西湖。雨刚停，断桥还湿着。<br/>
            我在桥头坐了很久——<br/>
            看苏堤的柳，看远山的雾。<br/>
            <br/>
            想起你说过——<br/>
            旅行不是去看新的风景，<br/>
            是把旧的自己留在路上。<br/>
            <br/>
            <span style={{ color: T.body }}>—— 远方旅人</span>
          </div>
        </div>

        <div style={{
          width: 1, background: `repeating-linear-gradient(180deg, ${T.divider} 0 6px, transparent 6px 10px)`,
          position:'relative', zIndex:1,
        }}/>

        {/* right: stamp + cancel + address */}
        <div style={{ position:'relative', zIndex:1, display:'flex', flexDirection:'column' }}>
          <div style={{ alignSelf:'flex-end', position:'relative', marginTop: -4 }}>
            <Stamp kind="classic" size={66} rotate={-4}/>
            {/* cancellation lines */}
            <svg viewBox="0 0 130 70" width="130" height="70" style={{
              position:'absolute', top: -2, right: -30, pointerEvents:'none', transform:'rotate(-6deg)',
            }}>
              <circle cx="32" cy="32" r="22" fill="none" stroke={T.red} strokeWidth="0.9" opacity="0.65"/>
              <text x="32" y="29" textAnchor="middle" fill={T.red} fontFamily="IBM Plex Mono" fontSize="6" letterSpacing="2" opacity=".7">HANGZHOU</text>
              <text x="32" y="38" textAnchor="middle" fill={T.red} fontFamily="IBM Plex Mono" fontSize="5" opacity=".7" letterSpacing="1">2024·05·10</text>
              {[0,1,2,3,4].map(i=>(
                <line key={i} x1="58" x2="128" y1={22+i*4.5} y2={22+i*4.5} stroke={T.red} strokeWidth="0.7" opacity=".4"/>
              ))}
            </svg>
          </div>

          <div style={{ marginTop: 32, ...labelStyle, color: T.green, fontSize: 9, marginBottom: 14 }}>TO · 收件</div>
          <div style={{ fontFamily: F.display, fontStyle:'italic', color: T.ink, fontSize: 13.5, lineHeight: '24px' }}>
            <div>致 · 未来的我</div>
            <div style={{ color: T.body, marginTop: 4 }}>北京市 · 朝阳区</div>
            <div style={{ color: T.body }}>建国路 88 号</div>
            <div style={{ color: T.body }}>2025 · 春 · 收</div>
          </div>

          <div style={{ flex:1 }}/>
          <div style={{
            paddingTop: 12, borderTop: `1px solid ${T.divider}`,
            display:'flex', justifyContent:'space-between',
            ...labelStyle, fontSize: 9,
          }}>
            <span>CN — 839204</span><span>N° 0001</span>
          </div>
        </div>
      </div>

      <div style={{
        marginTop: 16, display:'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 12,
      }}>
        <Note color={T.green} title="MESSAGE · 旅人手记">手写感衬线 italic，行高 24px 与底纹横线对齐，写给未来</Note>
        <Note color={T.red} title="STAMP + CANCEL · 邮票与销戳">邮票贴在右上角，红色圆形销戳叠加，盖印城市与日期</Note>
        <Note color={T.body} title="ADDRESS · 收件信息">日期可填未来某日，呼应"寄往远方"主题</Note>
      </div>
    </div>
  );
}

function Note({ color, title, children }) {
  return (
    <div style={{
      background: T.card, borderRadius: 4, padding: '10px 12px',
      border:`1px solid ${T.divider}`, borderLeft: `2px solid ${color}`,
    }}>
      <div style={{ ...labelStyle, color, fontSize: 9, marginBottom: 5 }}>{title}</div>
      <div style={{ fontFamily: F.serif, fontSize: 11, color: T.body, lineHeight: 1.5 }}>{children}</div>
    </div>
  );
}

Object.assign(window, { StampSheet, PostcardFronts, PostcardBack });

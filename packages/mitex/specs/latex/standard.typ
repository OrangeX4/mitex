#import "@preview/xarrow:0.2.0": xarrow

#import "../prelude.typ": *

// 0. Some useful internal variables or functions
#let mitex-color-map = (
  "red": rgb(255, 0, 0),
  "green": rgb(0, 255, 0),
  "blue": rgb(0, 0, 255),
  "cyan": rgb(0, 255, 255),
  "magenta": rgb(255, 0, 255),
  "yellow": rgb(255, 255, 0),
  "black": rgb(0, 0, 0),
  "white": rgb(255, 255, 255),
  "gray": rgb(128, 128, 128),
  "lightgray": rgb(192, 192, 192),
  "darkgray": rgb(64, 64, 64),
  "brown": rgb(165, 42, 42),
  "orange": rgb(255, 165, 0),
  "pink": rgb(255, 182, 193),
  "purple": rgb(128, 0, 128),
  "teal": rgb(0, 128, 128),
  "olive": rgb(128, 128, 0),
)
#let get-tex-str-from-arr(arr) = arr.filter(it => it != [ ] and it != [#math.zws]).map(it => it.text).sum()
#let get-tex-str(tex) = get-tex-str-from-arr(tex.children)
#let get-tex-color-from-arr(arr) = {
    mitex-color-map.at(lower(get-tex-str-from-arr(arr)), default: none)
}
#let get-tex-color(texcolor) = get-tex-color-from-arr(texcolor.children)
#let text-end-space(it) = if it.len() > 1 and it.ends-with(" ") { " " }

// 1. functions created to make it easier to define a spec
#let operatornamewithlimits(it) = math.op(limits: true, math.upright(it))
#let arrow-handle(arrow-sym) = define-cmd(1, handle: it => $limits(xarrow(sym: #arrow-sym, it))$)
#let greedy-handle(alias, fn) = define-greedy-cmd(alias, handle: fn)
#let limits-handle(alias, wrap) = define-cmd(1, alias: alias, handle: (it) => math.limits(wrap(it)))
#let matrix-handle(delim: none, handle: none) = define-matrix-env(none, alias: none, handle: math.mat.with(delim: delim))
#let text-handle(wrap) = define-cmd(1, handle: it => $wrap(it)$ + text-end-space(it),)
#let call-or-ignore(fn) = (..args) => if args.pos().len() > 0 { fn(..args) } else { math.zws }
#let ignore-me = it => {}
#let ignore-sym = define-sym("")

// 2. Standard package definitions, generate specs and scopes,
//    for parser/convert and typst respectively
#let (spec, scope) = process-spec((
  // Spaces: \! \, \> \: \; \ \quad \qquad
  "!": define-sym("negthinspace", sym: h(-(3/18) * 1em)),
  negthinspace: of-sym(h(-(3/18) * 1em)),
  negthinmedspace: of-sym(h(-(3/18) * 1em)),
  negmedspace: of-sym(h(-(4/18) * 1em)),
  negthickspace: of-sym(h(-(5/18) * 1em)),
  ",": define-sym("thin"),
  thinspace: define-sym("thin"),
  ">": define-sym("med"),
  ":": define-sym("med"),
  medspace: define-sym("med"),
  ";": define-sym("thick"),
  "": define-sym("thick"),
  thickspace: define-sym("thick"),
  enspace: of-sym(h((1/2) * 1em)),
  nobreakspace: define-sym("space.nobreak"),
  space: sym,
  quad: sym,
  qquad: define-sym("wide"),
  phantom: define-cmd(1, handle: hide),
  hphantom: define-cmd(1, handle: it => box(height: 0pt, hide(it))),
  vphantom: define-cmd(1, handle: it => box(width: 0pt, hide(it))),
  // Escape symbols
  "_": define-sym("\\_"),
  "^": define-sym("hat"),
  "*": define-sym(""),
  "|": define-sym("||"),
  "&": define-sym("amp"),
  "#": define-sym("hash"),
  "%": define-sym("percent"),
  "$": define-sym("dollar"),
  "{": define-sym("\\{"),
  "}": define-sym("\\}"),
  vert: define-sym("|"),
  lvert: define-sym("|"),
  rvert: define-sym("|"),
  Vert: define-sym("||"),
  lVert: define-sym("||"),
  rVert: define-sym("||"),
  lparen: define-sym("paren.l"),
  rparen: define-sym("paren.r"),
  lceil: define-sym(" ⌈ "),
  rceil: define-sym("⌉ "),
  lfloor: define-sym("⌊ "),
  rfloor: define-sym("⌋"),
  // Sizes and styles
  displaystyle: greedy-handle("mitexdisplay", math.display),
  textstyle: greedy-handle("mitexinline", math.inline),
  scriptstyle: greedy-handle("mitexscript", math.script),
  scriptscriptstyle: greedy-handle("mitexsscript", math.sscript),
  bf: greedy-handle("mitexbold", math.bold),
  rm: greedy-handle("mitexupright", math.upright),
  it: greedy-handle("mitexitalic", math.italic),
  sf: greedy-handle("mitexsans", math.sans),
  frak: greedy-handle("mitexfrak", math.frak),
  tt: greedy-handle("mitexmono", math.mono),
  cal: greedy-handle("mitexcal", math.cal),
  bold: define-cmd(1, alias: "bold"),
  mathbf: define-cmd(1, alias: "bold"),
  bm: define-cmd(1, alias: "bold"),
  boldsymbol: define-cmd(1, alias: "bold"),
  pmb: define-cmd(1, alias: "bold"),
  mathrm: define-cmd(1, alias: "upright"),
  mathit: define-cmd(1, alias: "italic"),
  mathnormal: define-cmd(1, alias: "italic"),
  mathsf: define-cmd(1, alias: "sans"),
  mathfrak: define-cmd(1, alias: "frak"),
  mathtt: define-cmd(1, alias: "mono"),
  Bbb: define-cmd(1, alias: "bb"),
  mathbb: define-cmd(1, alias: "bb"),
  mathcal: define-cmd(1, alias: "cal"),
  mathbin: define-cmd(1, handle: it => math.class("binary", it)),
  mathclose: define-cmd(1, handle: it => math.class("closing", it)),
  mathinner: define-cmd(1, handle: it => math.class("fence", it)),
  mathop: define-cmd(1, handle: it => math.class("unary", it)),
  mathopen: define-cmd(1, handle: it => math.class("opening", it)),
  mathord: define-cmd(1, handle: it => math.class("normal", it)),
  mathpunct: define-cmd(1, handle: it => math.class("punctuation", it)),
  mathrel: define-cmd(1, handle: it => math.class("relation", it)),
  big: define-cmd(1, handle: it => math.lr(size: 120%, it)),
  Big: define-cmd(1, handle: it => math.lr(size: 180%, it)),
  bigg: define-cmd(1, handle: it => math.lr(size: 240%, it)),
  Bigg: define-cmd(1, handle: it => math.lr(size: 300%, it)),
  bigl: define-cmd(1, alias: "big"),
  Bigl: define-cmd(1, alias: "Big"),
  biggl: define-cmd(1, alias: "bigg"),
  Biggl: define-cmd(1, alias: "Bigg"),
  bigm: define-cmd(1, alias: "big"),
  Bigm: define-cmd(1, alias: "Big"),
  biggm: define-cmd(1, alias: "bigg"),
  Biggm: define-cmd(1, alias: "Bigg"),
  bigr: define-cmd(1, alias: "big"),
  Bigr: define-cmd(1, alias: "Big"),
  biggr: define-cmd(1, alias: "bigg"),
  Biggr: define-cmd(1, alias: "Bigg"),
  // todo: size, especially multi-line, ignore it for now.
  Huge: ignore-sym,
  normalsize: ignore-sym,
  huge: ignore-sym,
  small: ignore-sym,
  footnotesize: ignore-sym,
  Large: ignore-sym,
  LARGE: ignore-sym,
  scriptsize: ignore-sym,
  large: ignore-sym,
  tiny: ignore-sym,
  // Colors
  color: define-greedy-cmd("mitexcolor", handle: body => {
    let texcolor = ()
    let args = ()
    for i in range(body.children.len()) {
      if body.children.at(i) != [#math.zws] {
        texcolor.push(body.children.at(i))
      } else {
        args = body.children.slice(i)
        break
      }
    }
    let color = get-tex-color-from-arr(texcolor)
    if color != none {
      text(fill: color, args.sum())
    } else {
      args.sum()
    }
  }),
  textcolor: define-cmd(2, alias: "colortext", handle: (texcolor, body) => {
    let color = get-tex-color(texcolor)
    if color != none {
      text(fill: get-tex-color(texcolor), body)
    } else {
      body
    }
  }),
  colorbox: define-cmd(2, handle: (texcolor, body) => {
    let color = get-tex-color(texcolor)
    if color != none {
      box(fill: get-tex-color(texcolor), $body$)
    } else {
      body
    }
  }),
  // Limits
  limits: left1-op("limits"),
  nolimits: left1-op("scripts"),
  // Commands
  frac: define-cmd(2, handle: (num, den) => $(num)/(den)$),
  // todo: cfrac, dfrac are same?
  cfrac: define-cmd(2, handle: (num, den) => $display((num)/(den))$),
  dfrac: define-cmd(2, handle: (num, den) => $display((num)/(den))$),
  tfrac: define-cmd(2, handle: (num, den) => $inline((num)/(den))$),
  binom: define-cmd(2),
  dbinom: define-cmd(2, handle: (n, k) => $display(binom(#n, #k))$),
  tbinom: define-cmd(2, handle: (n, k) => $inline(binom(#n, #k))$),
  stackrel: define-cmd(2, handle: (sup, base) => $limits(base)^(sup)$),
  substack: define-cmd(1, handle: it => it),
  overset: define-cmd(2, handle: (sup, base) => $limits(base)^(sup)$),
  underset: define-cmd(2, handle: (sub, base) => $limits(base)_(sub)$),
  // Accents
  "not": define-cmd(1, alias: "cancel"),
  cancel: define-cmd(1),
  xcancel: define-cmd(1, handle: math.cancel),
  bcancel: define-cmd(1, handle: math.cancel.with(inverted: true)),
  sout: define-cmd(1, handle: math.cancel.with(angle: 90deg)),
  grave: define-cmd(1, alias: "grave"),
  acute: define-cmd(1, alias: "acute"),
  hat: define-cmd(1, alias: "hat"),
  widehat: define-cmd(1, alias: "hat"),
  tilde: define-cmd(1, alias: "tilde"),
  widetilde: define-cmd(1, alias: "tilde"),
  bar: define-cmd(1, alias: "macron"),
  breve: define-cmd(1, alias: "breve"),
  dot: define-cmd(1, alias: "dot"),
  ddot: define-cmd(1, alias: "dot.double"),
  dddot: define-cmd(1, alias: "dot.triple"),
  ddddot: define-cmd(1, alias: "dot.quad"),
  H: define-cmd(1, alias: "acute.double"),
  check: define-cmd(1, alias: "caron"),
  widecheck: define-cmd(1, alias: "caron"),
  u: define-cmd(1, alias: "breve"),
  v: define-cmd(1, alias: "caron"),
  r: define-cmd(1, alias: "circle"),
  vec: define-cmd(1, alias: "arrow"),
  overrightarrow: define-cmd(1, alias: "arrow"),
  overleftarrow: define-cmd(1, alias: "arrow.l"),
  overline: cmd1,
  underline: cmd1,
  overbrace: limits-handle("mitexoverbrace", math.overbrace),
  underbrace: limits-handle("mitexunderbrace", math.underbrace),
  overbracket: limits-handle("mitexoverbracket", math.overbracket),
  underbracket: limits-handle("mitexunderbracket", math.underbracket),
  boxed: define-cmd(1, handle: it => box(stroke: 0.5pt, $it$)),
  // Greeks
  alpha: sym,
  beta: sym,
  gamma: sym,
  delta: sym,
  epsilon: sym,
  zeta: sym,
  eta: sym,
  theta: sym,
  iota: sym,
  kappa: sym,
  lambda: sym,
  mu: sym,
  nu: sym,
  xi: sym,
  omicron: sym,
  pi: sym,
  rho: sym,
  sigma: sym,
  tau: sym,
  upsilon: sym,
  phi: sym,
  chi: sym,
  psi: sym,
  omega: sym,
  Alpha: sym,
  Beta: sym,
  Gamma: sym,
  Delta: sym,
  Epsilon: sym,
  Zeta: sym,
  Eta: sym,
  Theta: sym,
  Iota: sym,
  Kappa: sym,
  Lambda: sym,
  Mu: sym,
  Nu: sym,
  Xi: sym,
  Omicron: sym,
  Pi: sym,
  Rho: sym,
  Sigma: sym,
  Tau: sym,
  Upsilon: sym,
  Phi: sym,
  Chi: sym,
  Psi: sym,
  Omega: sym,
  varbeta: define-sym("beta.alt"),
  varepsilon: define-sym("epsilon.alt"),
  varkappa: define-sym("kappa.alt"),
  varphi: define-sym("phi.alt"),
  varpi: define-sym("pi.alt"),
  varrho: define-sym("rho.alt"),
  varsigma: define-sym("sigma.alt"),
  vartheta: define-sym("theta.alt"),
  ell: sym,
  // Function symbols
  sin: sym,
  cos: sym,
  tan: sym,
  cot: sym,
  sec: sym,
  csc: sym,
  arcsin: sym,
  arccos: sym,
  arctan: sym,
  sinh: sym,
  cosh: sym,
  tanh: sym,
  coth: sym,
  ln: sym,
  log: sym,
  lg: sym,
  lim: sym,
  limsup: sym,
  liminf: sym,
  hom: sym,
  det: sym,
  exp: sym,
  deg: sym,
  gcd: sym,
  lcm: sym,
  dim: sym,
  ker: sym,
  arg: sym,
  Pr: sym,
  // Limits
  max: sym,
  min: sym,
  argmax: sym,
  argmin: sym,
  sup: sym,
  inf: sym,
  sum: sym,
  prod: define-sym("product"),
  int: define-sym("∫"),
  int: define-sym("integral"),
  iint: define-sym("integral.double"),
  iiint: define-sym("integral.triple"),
  oint: define-sym("integral.cont"),
  oiint: define-sym("integral.surf"),
  oiiint: define-sym("integral.vol"),
  // Symbols
  mod: define-sym("mod"),
  bmod: define-sym("mod"),
  cdot: define-sym("dot.c"),
  cdotp: define-sym("dot.c"),
  sdot: define-sym("dot.c"),
  times: define-sym("times"),
  oplus: define-sym("plus.circle"),
  ominus: define-sym("minus.circle"),
  osplash: define-sym("⊘"),
  pm: define-sym("plus.minus"),
  plusmn: define-sym("plus.minus"),
  mp: define-sym("minus.plus"),
  div: define-sym("div"),
  star: define-sym("star"),
  cap: define-sym("sect"),
  cup: define-sym("union"),
  "in": define-sym("in"),
  isin: define-sym("in"),
  notin: define-sym("in.not"),
  subset: define-sym("subset"),
  subseteq: define-sym("subset.eq"),
  subsetneqq: define-sym("⫋"),
  ne: define-sym("!="),
  neq: define-sym("!="),
  lt: define-sym("<"),
  gt: define-sym(">"),
  le: define-sym("<="),
  ge: define-sym(">="),
  leq: define-sym("<="),
  geq: define-sym(">="),
  leqslant: define-sym("lt.eq.slant"),
  geqslant: define-sym("gt.eq.slant"),
  eqslantgtr: define-sym("⪖"),
  eqslantless: define-sym("⪕"),
  approx: define-sym("approx"),
  leftarrow: define-sym("<-"),
  rightarrow: define-sym("->"),
  leftrightarrow: define-sym("<->"),
  Leftarrow: define-sym("arrow.l.double"),
  Rightarrow: define-sym("=>"),
  Leftrightarrow: define-sym("<=>"),
  larr: define-sym("<-"),
  rarr: define-sym("->"),
  lrarr: define-sym("<->"),
  lArr: define-sym("arrow.l.double"),
  rArr: define-sym("=>"),
  lrArr: define-sym("<=>"),
  Larr: define-sym("arrow.l.double"),
  Rarr: define-sym("=>"),
  Lrarr: define-sym("<=>"),
  longleftarrow: define-sym("<--"),
  longrightarrow: define-sym("-->"),
  longleftrightarrow: define-sym("<-->"),
  Longleftarrow: define-sym("<=="),
  Longrightarrow: define-sym("==>"),
  Longleftrightarrow: define-sym("<==>"),
  to: define-sym("->"),
  gets: define-sym("<-"),
  implies: define-sym("==>"),
  impliedby: define-sym("<=="),
  gets: define-sym("<-"),
  mapsto: define-sym("|->"),
  infty: define-sym("oo"),
  lbrack: define-sym("bracket.l"),
  rbrack: define-sym("bracket.r"),
  lgroup: define-sym("⟮"),
  rgroup: define-sym("⟯"),
  llbracket: define-sym("bracket.l.double"),
  rrbracket: define-sym("bracket.r.double"),
  angle: define-sym("angle"),
  lang: define-sym("angle.l"),
  rang: define-sym("angle.r"),
  langle: define-sym("angle.l"),
  rangle: define-sym("angle.r"),
  measuredangle: define-sym("angle.arc"),
  sphericalangle: define-sym("angle.spheric"),
  ast: define-sym("ast"),
  checkmark: define-sym("checkmark"),
  circledast: define-sym("ast.circle"),
  backslash: define-sym("backslash"),
  dagger: define-sym("dagger"),
  ddagger: define-sym("dagger.double"),
  circleddash: define-sym("dash.circle"),
  odot: define-sym("dot.circle"),
  bigodot: define-sym("dot.circle.big"),
  boxdot: define-sym("dot.square"),
  dots: define-sym("dots.h"),
  cdots: define-sym("dots.h.c"),
  ldots: define-sym("dots.h"),
  vdots: define-sym("dots.v"),
  ddots: define-sym("dots.down"),
  dotsb: define-sym("dots.h.c"),
  dotsc: define-sym("dots.h"),
  dotsi: define-sym("dots.h.c"),
  dotsm: define-sym("dots.h.c"),
  dotso: define-sym("dots.h"),
  sim: define-sym("tilde"),
  simeq: define-sym("tilde.eq"),
  backsimeq: define-sym("tilde.eq.rev"),
  cong: define-sym("tilde.equiv"),
  ncong: define-sym("tilde.equiv.not"),
  nsim: define-sym("tilde.not"),
  backsim: define-sym("tilde.rev"),
  prime: define-sym("prime"),
  backprime: define-sym("prime.rev"),
  bigoplus: define-sym("plus.circle.big"),
  dotplus: define-sym("plus.dot"),
  boxplus: define-sym("plus.square"),
  boxminus: define-sym("minus.square"),
  eqsim: define-sym("minus.tilde"),
  otimes: define-sym("times.circle"),
  bigotimes: define-sym("times.circle.big"),
  divideontimes: define-sym("times.div"),
  leftthreetimes: define-sym("times.three.l"),
  rightthreetimes: define-sym("times.three.r"),
  ltimes: define-sym("times.l"),
  rtimes: define-sym("times.r"),
  boxtimes: define-sym("times.square"),
  triangleq: define-sym("eq.delta"),
  curlyeqprec: define-sym("eq.prec"),
  curlyeqsucc: define-sym("eq.succ"),
  gtrdot: define-sym("gt.dot"),
  gg: define-sym("gt.double"),
  gtreqless: define-sym("gt.eq.lt"),
  ngeq: define-sym("gt.eq.not"),
  geqq: define-sym("gt.equiv"),
  gtrless: define-sym("gt.lt"),
  gneqq: define-sym("gt.nequiv"),
  ngtr: define-sym("gt.not"),
  gnsim: define-sym("gt.ntilde"),
  gtrsim: define-sym("gt.tilde"),
  vartriangleright: define-sym("gt.tri"),
  trianglerighteq: define-sym("gt.tri.eq"),
  ntrianglerighteq: define-sym("gt.tri.eq.not"),
  ntriangleright: define-sym("gt.tri.not"),
  ggg: define-sym("gt.triple"),
  lessdot: define-sym("lt.dot"),
  ll: define-sym("lt.double"),
  lesseqgtr: define-sym("lt.eq.gt"),
  nleq: define-sym("lt.eq.not"),
  leqq: define-sym("lt.equiv"),
  lessgtr: define-sym("lt.gt"),
  lneqq: define-sym("lt.nequiv"),
  nless: define-sym("lt.not"),
  lnsim: define-sym("lt.ntilde"),
  lesssim: define-sym("lt.tilde"),
  vartriangleleft: define-sym("lt.tri"),
  trianglelefteq: define-sym("lt.tri.eq"),
  ntrianglelefteq: define-sym("lt.tri.eq.not"),
  ntriangleleft: define-sym("lt.tri.not"),
  lll: define-sym("lt.triple"),
  approxeq: define-sym("approx.eq"),
  prec: define-sym("prec"),
  precapprox: define-sym("prec.approx"),
  preceq: define-sym("prec.eq"),
  preccurlyeq: define-sym("prec.eq"),
  npreceq: define-sym("prec.eq.not"),
  precnapprox: define-sym("prec.napprox"),
  nprec: define-sym("prec.not"),
  precnsim: define-sym("prec.ntilde"),
  precsim: define-sym("prec.tilde"),
  succ: define-sym("succ"),
  succapprox: define-sym("succ.approx"),
  succeq: define-sym("succ.eq"),
  succcurlyeq: define-sym("succ.eq"),
  nsucceq: define-sym("succ.eq.not"),
  succnapprox: define-sym("succ.napprox"),
  nsucc: define-sym("succ.not"),
  succnsim: define-sym("succ.ntilde"),
  succsim: define-sym("succ.tilde"),
  equiv: define-sym("equiv"),
  propto: define-sym("prop"),
  empty: define-sym("nothing"),
  emptyset: define-sym("nothing"),
  varnothing: define-sym("nothing"),
  o: define-sym("nothing"),
  O: define-sym("nothing"),
  osplash: define-sym("⊘"),
  setminus: define-sym("without"),
  smallsetminus: define-sym("without"),
  And: define-sym("amp"),
  bigcirc: define-sym("circle.stroked.big"),
  smallsetminus: define-sym("without"),
  complement: define-sym("complement"),
  ni: define-sym("in.rev"),
  notni: define-sym("in.rev.not"),
  Subset: define-sym("subset.double"),
  nsubseteq: define-sym("subset.eq.not"),
  sqsubseteq: define-sym("subset.eq.sq"),
  subsetneq: define-sym("subset.neq"),
  supset: define-sym("supset"),
  Supset: define-sym("supset.double"),
  supseteq: define-sym("supset.eq"),
  nsupseteq: define-sym("supset.eq.not"),
  sqsupseteq: define-sym("supset.eq.sq"),
  supsetneq: define-sym("supset.neq"),
  bigcup: define-sym("union.big"),
  Cup: define-sym("union.double"),
  uplus: define-sym("union.plus"),
  biguplus: define-sym("union.plus.big"),
  sqcup: define-sym("union.sq"),
  bigsqcup: define-sym("union.sq.big"),
  bigcap: define-sym("sect.big"),
  Cap: define-sym("sect.double"),
  sqcap: define-sym("sect.sq"),
  partial: define-sym("diff"),
  nabla: define-sym("nabla"),
  coprod: define-sym("product.co"),
  forall: define-sym("forall"),
  exist: define-sym("exists"),
  exists: define-sym("exists"),
  nexists: define-sym("exists.not"),
  top: define-sym("top"),
  bot: define-sym("bot"),
  neg: define-sym("not"),
  lnot: define-sym("not"),
  land: define-sym("and"),
  wedge: define-sym("and"),
  lor: define-sym("or"),
  bigwedge: define-sym("and.big"),
  curlywedge: define-sym("and.curly"),
  vee: define-sym("or"),
  bigvee: define-sym("or.big"),
  curlyvee: define-sym("or.curly"),
  models: define-sym("models"),
  therefore: define-sym("therefore"),
  because: define-sym("because"),
  blacksquare: define-sym("qed"),
  circ: define-sym("compose"),
  multimap: define-sym("multimap"),
  mid: define-sym("divides"),
  nmid: define-sym("divides.not"),
  wr: define-sym("wreath"),
  parallel: define-sym("parallel"),
  shortparallel: define-sym("parallel"),
  nparallel: define-sym("parallel.not"),
  perp: define-sym("perp"),
  Join: define-sym("join"),
  pounds: define-sym("pound"),
  clubsuit: define-sym("suit.club"),
  spadesuit: define-sym("suit.spade"),
  bull: define-sym("bullet"),
  bullet: define-sym("bullet"),
  circledcirc: define-sym("circle.nested"),
  rhd: define-sym("triangle.stroked.r"),
  lhd: define-sym("triangle.stroked.l"),
  triangle: define-sym("triangle.stroked.t"),
  bigtriangleup: define-sym("triangle.stroked.t"),
  bigtriangledown: define-sym("triangle.stroked.b"),
  triangleright: define-sym("triangle.stroked.small.r"),
  triangledown: define-sym("triangle.stroked.small.b"),
  triangleleft: define-sym("triangle.stroked.small.l"),
  vartriangle: define-sym("triangle.stroked.small.t"),
  square: define-sym("square.stroked"),
  Diamond: define-sym("diamond.stroked"),
  diamond: define-sym("diamond.stroked.small"),
  diamonds: define-sym("diamond.stroked"),
  diamondsuit: define-sym("diamond.stroked"),
  lozenge: define-sym("lozenge.stroked"),
  blacklozenge: define-sym("lozenge.filled"),
  bigstar: define-sym("star.stroked"),
  longmapsto: define-sym("arrow.r.long.bar"),
  nRightarrow: define-sym("arrow.r.double.not"),
  hookrightarrow: define-sym("arrow.r.hook"),
  looparrowright: define-sym("arrow.r.loop"),
  nrightarrow: define-sym("arrow.r.not"),
  rightsquigarrow: define-sym("arrow.r.squiggly"),
  rightarrowtail: define-sym("arrow.r.tail"),
  Rrightarrow: define-sym("arrow.r.triple"),
  twoheadrightarrow: define-sym("arrow.r.twohead"),
  nLeftarrow: define-sym("arrow.l.double.not"),
  hookleftarrow: define-sym("arrow.l.hook"),
  looparrowleft: define-sym("arrow.l.loop"),
  nleftarrow: define-sym("arrow.l.not"),
  leftarrowtail: define-sym("arrow.l.tail"),
  Lleftarrow: define-sym("arrow.l.triple"),
  twoheadleftarrow: define-sym("arrow.l.twohead"),
  uparrow: define-sym("arrow.t"),
  Uparrow: define-sym("arrow.t.double"),
  downarrow: define-sym("arrow.b"),
  Downarrow: define-sym("arrow.b.double"),
  iff: define-sym("arrow.l.r.double.long"),
  nLeftrightarrow: define-sym("arrow.l.r.double.not"),
  nleftrightarrow: define-sym("arrow.l.r.not"),
  leftrightsquigarrow: define-sym("arrow.l.r.wave"),
  updownarrow: define-sym("arrow.t.b"),
  Updownarrow: define-sym("arrow.t.b.double"),
  nearrow: define-sym("arrow.tr"),
  searrow: define-sym("arrow.br"),
  nwarrow: define-sym("arrow.tl"),
  swarrow: define-sym("arrow.bl"),
  circlearrowleft: define-sym("arrow.ccw"),
  curvearrowleft: define-sym("arrow.ccw.half"),
  circlearrowright: define-sym("arrow.cw"),
  curvearrowright: define-sym("arrow.cw.half"),
  rightrightarrows: define-sym("arrows.rr"),
  leftleftarrows: define-sym("arrows.ll"),
  upuparrows: define-sym("arrows.tt"),
  downdownarrows: define-sym("arrows.bb"),
  leftrightarrows: define-sym("arrows.lr"),
  rightleftarrows: define-sym("arrows.rl"),
  rightharpoonup: define-sym("harpoon.rt"),
  rightharpoondown: define-sym("harpoon.rb"),
  leftharpoonup: define-sym("harpoon.lt"),
  leftharpoondown: define-sym("harpoon.lb"),
  upharpoonleft: define-sym("harpoon.tl"),
  upharpoonright: define-sym("harpoon.tr"),
  downharpoonleft: define-sym("harpoon.bl"),
  downharpoonright: define-sym("harpoon.br"),
  leftrightharpoons: define-sym("harpoons.ltrb"),
  rightleftharpoons: define-sym("harpoons.rtlb"),
  vdash: define-sym("tack.r"),
  nvdash: define-sym("tack.r.not"),
  vDash: define-sym("tack.r.double"),
  nvDash: define-sym("tack.r.double.not"),
  dashv: define-sym("tack.l"),
  hbar: define-sym("planck.reduce"),
  hslash: define-sym("planck.reduce"),
  Re: define-sym("Re"),
  Im: define-sym("Im"),
  AA: define-sym("circle(A)"),
  aa: define-sym("circle(A)"),
  Box: define-sym("ballot"),
  N: define-sym("NN"),
  natnums: define-sym("NN"),
  natural: define-sym("♮"),
  P: define-sym("pilcrow"),
  Q: define-sym("QQ"),
  R: define-sym("RR"),
  Z: define-sym("ZZ"),
  S: define-sym("section"),
  sect: define-sym("section"),
  AE: define-sym("Æ"),
  ae: define-sym("æ"),
  alef: define-sym("aleph"),
  alefsym: define-sym("aleph"),
  aleph: define-sym("aleph"),
  amalg: define-sym("product.co"),
  arctg: of-sym(math.op("arctg")),
  asymp: define-sym("≍"),
  ch: of-sym(math.op("ch")),
  circeq: define-sym("≗"),
  colon: define-sym("colon"),
  cth: of-sym(math.op("cth")),
  dag: define-sym("dagger"),
  dagger: define-sym("dagger"),
  Dagger: define-sym("dagger.double"),
  ddag: define-sym("dagger.double"),
  ddagger: define-sym("dagger.double"),
  daleth: define-sym("ℸ"),
  sharp: define-sym("♯"),
  flat: define-sym("♭"),
  i: define-sym("dotless.i"),
  j: define-sym("dotless.j"),
  imath: define-sym("dotless.i"),
  jmath: define-sym("dotless.j"),
  smallsmile: define-sym("⌣"),
  smile: define-sym("⌣"),
  ss: define-sym("ß"),
  surd: define-sym("\√"),
  tg: define-sym("tg"),
  th: of-sym(math.op("th")),
  weierp: define-sym("℘"),
  wp: define-sym("℘"),
  wr: define-sym("≀"),
  lbrace: define-sym("\\{"),
  rbrace: define-sym("\\}"),
  doteq: define-sym("≐"),
  Vdash: define-sym("⊩"),
  Doteq: define-sym("≑"),
  smallsmile: define-sym("⌣"),
  Vvdash: define-sym("⊪"),
  gnapprox: define-sym("⪊"),
  ngeqslant: define-sym("gt.eq.not"),
  precneqq: define-sym("prec.nequiv"),
  gneq: define-sym("⪈"),
  approxcolon: define-sym("approx:"),
  approxcoloncolon: define-sym("approx::"),
  backepsilon: define-sym("in.rev.small"),
  barwedge: define-sym("⊼"),
  beth: define-sym("beth"),
  between: define-sym("≬"),
  between: define-sym("≬"),
  bigdot: define-sym("dot.circle.big"),
  bigplus: define-sym("plus.circle.big"),
  bigtimes: define-sym("times.circle.big"),
  blacktriangle: define-sym("triangle.filled.t"),
  blacktriangledown: define-sym("triangle.filled.b"),
  blacktriangleleft: define-sym("triangle.filled.l"),
  blacktriangleright: define-sym("triangle.filled.r"),
  bowtie: define-sym("⋈"),
  Bumpeq: define-sym("≎"),
  bumpeq: define-sym("≏"),
  centerdot: define-sym("dot.op"),
  circledR: define-sym("®"),
  circledS: define-sym("Ⓢ"),
  clubs: define-sym("suit.club"),
  cnums: define-sym("CC"),
  Colonapprox: define-sym("::approx"),
  colonapprox: define-sym(":approx"),
  coloncolon: define-sym("::"),
  coloncolonapprox: define-sym("::approx"),
  coloncolonequals: define-sym("::="),
  coloncolonminus: define-sym("::−"),
  coloncolonsim: define-sym("::tilde.op"),
  Coloneq: define-sym("::−"),
  coloneq: define-sym(":−"),
  colonequals: define-sym(":="),
  Coloneqq: define-sym("::="),
  coloneqq: define-sym(":="),
  colonminus: define-sym(":−"),
  Colonsim: define-sym("::tilde.op"),
  colonsim: define-sym(":tilde.op"),
  Complex: define-sym("CC"),
  copyright: define-sym("copyright"),
  ctg: define-sym("ctg"),
  Darr: define-sym("arrow.b.double"),
  dArr: define-sym("arrow.b.double"),
  darr: define-sym("arrow.b"),
  dashleftarrow: define-sym("arrow.l.dash"),
  dashrightarrow: define-sym("arrow.r.dash"),
  dbcolon: define-sym("::"),
  degree: define-sym("degree"),
  digamma: define-sym("ϝ"),
  diagdown: define-sym("╲"),
  diagup: define-sym("╱"),
  doteqdot: define-sym("≑"),
  doublebarwedge: define-sym("⩞"),
  doublecap: define-sym("sect.double"),
  doublecup: define-sym("union.double"),
  eqcirc: define-sym("≖"),
  Eqcolon: define-sym("−::"),
  eqcolon: define-sym("dash.colon"),
  Eqqcolon: define-sym("=::"),
  eqqcolon: define-sym("=:"),
  equalscolon: define-sym("=:"),
  equalscoloncolon: define-sym("=::"),
  eth: define-sym("ð"),
  fallingdotseq: define-sym("≒"),
  Finv: define-sym("Ⅎ"),
  frown: define-sym("⌢"),
  Game: define-sym("⅁"),
  gggtr: define-sym(">>>"),
  gimel: define-sym("gimel"),
  Harr: define-sym("<=>"),
  hArr: define-sym("<=>"),
  harr: define-sym("<->"),
  hearts: define-sym("♡"),
  heartsuit: define-sym("♡"),
  image: define-sym("Im"),
  imageof: define-sym("⊷"),
  infin: define-sym("infinity"),
  intercal: define-sym("⊺"),
  intop: define-sym("integral"),
  lBrace: define-sym("⦃"),
  ldotp: define-sym("."),
  leadsto: define-sym("arrow.r.squiggly"),
  lessapprox: define-sym("⪅"),
  lesseqqgtr: define-sym("⪋"),
  llcorner: define-sym("⌞"),
  llless: define-sym("<<<"),
  lnapprox: define-sym("⪉"),
  lneq: define-sym("⪇"),
  lrcorner: define-sym("⌟"),
  lq: define-sym("quote.l.single"),
  Lsh: define-sym("↰"),
  maltese: define-sym("maltese"),
  mathellipsis: define-sym("..."),
  mathsterling: define-sym("pound"),
  mho: define-sym("ohm.inv"),
  minuscolon: define-sym("dash.colon"),
  minuscoloncolon: define-sym("−::"),
  minuso: define-sym("⦵"),
  newline: define-sym("\\"),
  nVDash: define-sym("⊯"),
  nVdash: define-sym("⊮"),
  OE: define-sym("Œ"),
  oe: define-sym("œ"),
  origof: define-sym("⊶"),
  oslash: define-sym("⊘"),
  owns: define-sym("in.rev"),
  pitchfork: define-sym("⋔"),
  ratio: define-sym(":"),
  rBrace: define-sym("⦄"),
  real: define-sym("Re"),
  Reals: define-sym("RR"),
  reals: define-sym("RR"),
  restriction: define-sym("harpoon.tr"),
  risingdotseq: define-sym("≓"),
  rmoustache: define-sym("⎱"),
  rq: define-sym("'"),
  Rsh: define-sym("↱"),
  simcolon: define-sym("tilde.op:"),
  simcoloncolon: define-sym("tilde.op::"),
  spades: define-sym("suit.spade"),
  sqsubset: define-sym("subset.sq"),
  sqsupset: define-sym("supset.sq"),
  sub: define-sym("subset"),
  sube: define-sym("subset.eq"),
  subseteqq: define-sym("⫅"),
  succneqq: define-sym("succ.nequiv"),
  supe: define-sym("supset.eq"),
  supseteqq: define-sym("⫆"),
  supsetneqq: define-sym("⫌"),
  textasciitilde: define-sym("~"),
  textasciicircum: define-sym("\\^"),
  textbackslash: define-sym("\\\\"),
  textbar: define-sym("\\|"),
  textbardbl: define-sym("‖"),
  textbraceleft: define-sym("{"),
  textbraceright: define-sym("}"),
  textdagger: define-sym("dagger"),
  textdaggerdbl: define-sym("dagger.double"),
  textdegree: define-sym("degree"),
  textdollarsign: define-sym("\\$"),
  textellipsis: define-sym("..."),
  textemdash: define-sym("---"),
  textendash: define-sym("--"),
  textgreater: define-sym("gt"),
  textless: define-sym("lt"),
  textquotedblleft: define-sym("quote.l.double"),
  textquotedblright: define-sym("quote.r.double"),
  textquoteleft: define-sym("quote.l.single"),
  textquoteright: define-sym("quote.r.single"),
  textregistered: define-sym("®"),
  textsterling: define-sym("pound"),
  textunderscore: define-sym("\\_"),
  thetasym: define-sym("theta.alt"),
  Uarr: define-sym("arrow.t.double"),
  uArr: define-sym("arrow.t.double"),
  uarr: define-sym("arrow.t"),
  ulcorner: define-sym("⌜"),
  unlhd: define-sym("lt.tri.eq"),
  unrhd: define-sym("gt.tri.eq"),
  urcorner: define-sym("⌝"),
  varpropto: define-sym("prop"),
  varsubsetneq: define-sym("subset.neq"),
  varsubsetneqq: define-sym("⫋"),
  varsupsetneq: define-sym("supset.neq"),
  varsupsetneqq: define-sym("⫌"),
  vcentcolon: define-sym(":"),
  veebar: define-sym("⊻"),
  yen: define-sym("yen"),
  arcctg: of-sym(math.op("arcctg")),
  begingroup: ignore-sym,
  cosec: of-sym(math.op("cosec")),
  cotg: `#math.op("cotg")`,
  cotg: of-sym(math.op("cotg")),
  injlim: of-sym(math.op("inj\u{2009}lim", limits: true)),
  mathclap: define-cmd(1, handle: it => box(width: 0pt, $it$)),
  mathring: define-cmd(1, handle: it => math.circle(it)),
  nobreak: ignore-sym,
  noexpand: ignore-sym,
  overgroup: define-cmd(1, handle: it => $accent(it, \u{0311})$),
  undergroup: define-cmd(1, handle: it => $accent(it, \u{032e})$),
  overleftharpoon: define-cmd(1, handle: it => $accent(it, \u{20d0})$),
  overleftrightarrow: define-cmd(1, handle: it => $accent(it, \u{20e1})$),
  overlinesegment: define-cmd(1, handle: it => $accent(it, \u{20e9})$),
  overrightharpoon: define-cmd(1, handle: it => $accent(it, \u{20d1})$),
  underbar: define-cmd(1, handle: it => $underline(it)$),
  plim: of-sym(math.op("plim", limits: true)),
  projlim: of-sym(math.op("proj\u{2009}lim", limits: true)),
  raisebox: define-cmd(2, handle: (sp, it) => text(baseline: -eval(get-tex-str(sp)), it)),
  sh: of-sym(math.op("sh")),
  smallint: of-sym($inline(integral)$),
  thickapprox: of-sym($bold(approx)$),
  thicksim: of-sym($bold(tilde)$),
  varDelta: of-sym($italic(Delta)$),
  varGamma: of-sym($italic(Gamma)$),
  varLambda: of-sym($italic(Lambda)$),
  varOmega: of-sym($italic(Omega)$),
  varPhi: of-sym($italic(Phi)$),
  varPi: of-sym($italic(Pi)$),
  varPsi: of-sym($italic(Psi)$),
  varSigma: of-sym($italic(Sigma)$),
  varTheta: of-sym($italic(Theta)$),
  varUpsilon: of-sym($italic(Upsilon)$),
  varXi: of-sym($italic(Xi)$),
  // xarrows
  xleftarrow: arrow-handle(math.arrow.l.long),
  xrightarrow: arrow-handle(math.arrow.r.long),
  xLeftarrow: arrow-handle(math.arrow.l.double.long),
  xRightarrow: arrow-handle(math.arrow.r.double.long),
  xleftrightarrow: arrow-handle(math.arrow.l.r),
  xLeftrightarrow: arrow-handle(math.arrow.l.r.double),
  xhookleftarrow: arrow-handle(math.arrow.l.hook),
  xhookrightarrow: arrow-handle(math.arrow.r.hook),
  xtwoheadleftarrow: arrow-handle(math.arrow.l.twohead),
  xtwoheadrightarrow: arrow-handle(math.arrow.r.twohead),
  xleftharpoonup: arrow-handle(math.harpoon.lt),
  xrightharpoonup: arrow-handle(math.harpoon.rt),
  xleftharpoondown: arrow-handle(math.harpoon.lb),
  xrightharpoondown: arrow-handle(math.harpoon.rb),
  xleftrightharpoons: arrow-handle(math.harpoons.ltrb),
  xrightleftharpoons: arrow-handle(math.harpoons.rtlb),
  xtofrom: arrow-handle(math.arrows.rl),
  xmapsto: arrow-handle(math.arrow.r.bar),
  xlongequal: arrow-handle(math.eq),
  pmod: define-cmd(1, handle: it => $quad (mod thick it)$),
  pod: define-cmd(1, handle: it => $quad (it)$),
  "set": define-cmd(1, handle: it => $\{it\}$),
  Set: define-cmd(1, handle: it => $lr(\{it\})$),
  bra: define-cmd(1, handle: it => $angle.l it|$),
  Bra: define-cmd(1, handle: it => $lr(angle.l it|)$),
  ket: define-cmd(1, handle: it => $|it angle.r$),
  Ket: define-cmd(1, handle: it => $lr(|it angle.r)$),
  braket: define-cmd(1, handle: it => $angle.l it angle.r$),
  Braket: define-cmd(1, handle: it => $lr(angle.l it angle.r)$),
  fbox: define-cmd(1, handle: it => box(stroke: 0.5pt, $it$)),
  hbox: define-cmd(1, handle: it => it),
  // Matrices
  matrix: matrix-handle(delim: none),
  pmatrix: matrix-handle(delim: "("),
  bmatrix: matrix-handle(delim: "["),
  Bmatrix: matrix-handle(delim: "{"),
  vmatrix: matrix-handle(delim: "|"),
  Vmatrix: matrix-handle(delim: "||"),
  smallmatrix: matrix-handle(handle: (..args) => math.inline(math.mat.with(delim: none, ..args))),
  array: define-matrix-env(1, alias: "mitexarray", handle: (arg0: ("l",), ..args) => {
    if args.pos().len() == 0 {
      return
    }
    if type(arg0) != str {
      if arg0.has("children") {
        arg0 = arg0.children.filter(it => it != [ ] and it != [#math.zws])
          .map(it => it.text)
          .filter(it => it == "l" or it == "c" or it == "r")
      } else {
        arg0 = (arg0.text,)
      }
    }
    let matrix = args.pos().map(row => if type(row) == array { row } else { (row,) } )
    let n = matrix.len()
    let m = calc.max(..matrix.map(row => row.len()))
    matrix = matrix.map(row => row + (m - row.len()) * (none,))
    let array-at(arr, pos) = {
      arr.at(calc.min(pos, arr.len() - 1))
    }
    let align-map = ("l": left, "c": center, "r": right)
    set align(align-map.at(array-at(arg0, 0)))
    pad(y: 0.2em, grid(
      columns: m,
      column-gutter: 0.5em,
      row-gutter: 0.5em,
      ..matrix.flatten().map(it => $it$)
    ))
  }),
  subarray: define-matrix-env(1, alias: "mitexarray"),
  // Environments
  aligned: normal-env(call-or-ignore(it => pad(y: 0.2em, block(math.op(math.display(it)))))),
  alignedat: define-env(1, alias: "alignedat", handle: (arg0: none, it) => pad(y: 0.2em, block(math.op(it)))),
  align: define-env(none, alias: "aligned"),
  "align*": define-env(none, alias: "aligned"),
  equation: define-env(none, alias: "aligned"),
  "equation*": define-env(none, alias: "aligned"),
  split: define-env(none, alias: "aligned"),
  gather: define-env(none, alias: "aligned"),
  gathered: define-env(none, alias: "aligned"),
  cases: define-cases-env(alias: "cases"),
  rcases: define-cases-env(alias: "rcases", handle: math.cases.with(reverse: true)),
  // Specials
  label: define-cmd(1, alias: "mitexlabel", handle: ignore-me),
  tag: define-cmd(1, alias: "mitexlabel", handle: ignore-me),
  ref: define-cmd(1, alias: "mitexlabel", handle: ignore-me),
  notag: ignore-sym,
  relax: ignore-sym,
  cr: ignore-sym,
  expandafter: ignore-sym,
  hline: ignore-sym,
  vline: ignore-sym,
  hskip: ignore-sym,
  mskip: ignore-sym,
  kern: ignore-sym,
  mkern: ignore-sym,
  mathstrut: ignore-sym,
  nonumber: ignore-sym,
  KaTeX: of-sym(math.upright($kai A T E X$)),
  LaTeX: of-sym(math.upright($L A T E X$)),
  TeX: of-sym(math.upright($T E X$)),
  middle: define-cmd(1, handle: it => math.mid(it)),
  operatorname: define-cmd(1, handle: it => math.op(math.upright(it))),
  operatornamewithlimits: define-cmd(1, alias: "operatornamewithlimits", handle: operatornamewithlimits),
  "operatorname*": define-cmd(1, alias: "operatornamewithlimits", handle: operatornamewithlimits),
  vspace: define-cmd(1, handle: it => v(eval(get-tex-str(it)))),
  hspace: define-cmd(1, handle: it => h(eval(get-tex-str(it)))),
  text: define-cmd(1, handle: it => it),
  textmd: define-cmd(1, handle: it => it),
  textnormal: define-cmd(1, handle: it => it),
  textbf: text-handle(math.bold),
  textrm: text-handle(math.upright),
  textup: text-handle(math.upright),
  textit: text-handle(math.italic),
  textsf: text-handle(math.sans),
  texttt: text-handle(math.mono),
  over: define-infix-cmd("frac"),
  atop: define-infix-cmd("atop", handle: (a, b) => $mat(delim: #none, #a; #b)$),
  choose: define-infix-cmd("binom", handle: math.binom),
  brace: define-infix-cmd("brace", handle: (n, k) => $mat(delim: "{", #n;; #k)$),
  brack: define-infix-cmd("brack", handle: (n, k) => $mat(delim: "[", #n;; #k)$),
  sqrt: define-glob-cmd("{,b}t", "mitexsqrt", handle: (..args) => {
    if args.pos().len() == 1 {
      $sqrt(#args.pos().at(0))$
    } else if args.pos().len() == 2 {
      $root(
        #args.pos().at(0).children.filter(it => it != [\[] and it != [\]]).sum(),
        #args.pos().at(1)
      )$
    } else {
      panic("unexpected args in sqrt")
    }
  }),
  // todo: macros
  def: ignore-sym,
  newcommand: ignore-sym,
  "newcommand*": ignore-sym,
  renewcommand: ignore-sym,
  "renewcommand*": ignore-sym,
  DeclareRobustCommand: ignore-sym,
  "DeclareRobustCommand*": ignore-sym,
  DeclareTextCommand: ignore-sym,
  DeclareTextCommandDefault: ignore-sym,
  ProvideTextCommand: ignore-sym,
  ProvideTextCommandDefault: ignore-sym,
  providecommand: ignore-sym,
  "providecommand*": ignore-sym,
  newenvironment: ignore-sym,
  "newenvironment*": ignore-sym,
  renewenvironment: ignore-sym,
  "renewenvironment*": ignore-sym,
  AtEndOfClass: ignore-sym,
  AtEndOfPackage: ignore-sym,
  AtBeginDocument: ignore-sym,
  AtEndDocument: ignore-sym,
  "@ifstar": ignore-sym,
  "if": ignore-sym,
  ifdim: ignore-sym,
  iffalse: ignore-sym,
  ifnum: ignore-sym,
  ifodd: ignore-sym,
  iftrue: ignore-sym,
  ifx: ignore-sym,
  DeclareOption: ignore-sym,
  "DeclareOption*": ignore-sym,
  CurrentOption: ignore-sym,
  ProcessOptions: ignore-sym,
  ExecuteOptions: ignore-sym,
  RequirePackage: ignore-sym,
  RequirePackageWithOptions: ignore-sym,
  documentclass: ignore-sym,
  PassOptionsToClass: ignore-sym,
  PassOptionsToPackage: ignore-sym,
  IfFileExists: ignore-sym,
  InputIfFileExists: ignore-sym,
  ProvidesFile: ignore-sym,
  ignorespaces: ignore-sym,
  ignorespacesafterend: ignore-sym,
  ifvoid: ignore-sym,
  ifinner: ignore-sym,
  ifhbox: ignore-sym,
  ifvbox: ignore-sym,
  ifhmode: ignore-sym,
  ifmmode: ignore-sym,
  ifvmode: ignore-sym,
  CheckCommand: ignore-sym,
  "CheckCommand*": ignore-sym,
  newcounter: ignore-sym,
  newlength: ignore-sym,
  newsavebox: ignore-sym,
  newtheorem: ignore-sym,
  newfont: ignore-sym,
  ProvidesClass: ignore-sym,
  LoadClass: ignore-sym,
  LoadClassWithOptions: ignore-sym,
))

// export: include package name, spec and scope 
#let package = (name: "latex-std", spec: (commands: spec), scope: scope)

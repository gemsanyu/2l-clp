### Sets

#set P; #Products (small items)
set B; #Cartons
set F; #Family of Products
set T; #Containers (vehicle)
set L; # Family of cartons 



### Parameter of Products

#param lp {P}; #Length of product p
#param wp {P}; #Width of product p
#param hp {P}; # Height of product p
#param WG {P}; # Weight of product p
#param bottom_area {pp in P} := lp[pp]*wp[pp]; #Bottom area of item pp (item stacked)

### Parameter for cartons

param LB {B}; # Length of carton b
param WB {B}; # Width of carton b
param HB {B}; # Height of carton b
param CB {B}; # Load bearing capacity of carton b
param Hmax := max {b in B} HB[b]; # maximum Height of Carton
param Lmax := max {b in B} LB[b]; # maximum Length of Carton
param Wmax := max {b in B} WB[b]; # maximum Wide of Carton
param BOTTOM_AREA{bb in B} := LB[bb]*WB[bb]; #Bottom area of carton bb (carton stacked)

### Parameters for containers

param LT {T}; # Length of container t
param WT {T}; # Width of container t
param HT {T};  #Height of container t
param CT {T}; # Load bearing capacity of container t
param Xmax := max {t in T} LT[t]; # maximum Height of Carton
param Ymax := max {t in T} WT[t]; # maximum Length of Carton
param Zmax := max {t in T} HT[t]; # maximum Wide of Carton

### Binary family mapping
#param e {P, F}, binary;   # 1 if product p belongs to family f
param g {F, L}, binary;   # 1 if carton b belongs to family l

### Cost factors
param alpha{B};              # Cost factor for using carton
#param alpha_supp;		# minimum percentage of its bottom face supported by other items' top faces
param beta{T};               # Cost factor for using container
param beta_supp;            # minimum percentage of its bottom face supported by other cartons' top faces
### Large constant
param M;                  # Sufficiently large constant


### Packing decision, usage, and assignment variables
#var x {P, B} binary;      # 1 if product p is packed in carton b
#var u {B} binary;         # 1 if carton b is used
param q {B, F} binary;      # 1 if at least one product in family f is in b
var y {B, T} binary;      # 1 if carton b is loaded in container t
var v {T} binary;         # 1 if container t is used
var w{T, L} binary;      # 1 if at least one carton in family l is in t
var Q {B,L} binary;  # 1 if carton b belongs to carton family l

### Positioning variables
#var xp {P} >= 0 integer;
#var yp {P} >= 0 integer;
#var zp {P} >= 0 integer;

var Xb {B} >= 0	integer;
var Yb {B} >= 0	integer;
var Zb {B} >= 0	integer;

#var ybar {P,P} binary;
#var yx {p in P, pp in P, b in B} binary;
#var xplus {P, P} binary;
#var xminus {P, P} binary;
#var yplus {P, P} binary;
#var yminus {P, P} binary;
#var zplus {P, P} binary;
#var zminus {P, P} binary;

var Ybar {B,B} binary;
var Yx {b in B,bb in B, t in T} binary;
var Xplus {B, B} binary;
var Xminus {B, B} binary;
var Yplus {B, B} binary;
var Yminus {B, B} binary;
var Zplus {B, B} binary;
var Zminus {B, B} binary;

# Orientation variables for products
#var l_px {P}binary;    # 1 if length of product p is along x axis
#var l_py {P} binary;    # 1 if length of product p is along y axis

#var w_px {P}binary;    # 1 if width of product p is along x axis
#var w_py {P}binary;    # 1 if width of product p is along y axis

# Orientation variables for cartons
var L_bx {B} binary;    # 1 if length of carton b is along x axis
var L_by {B} binary;    # 1 if length of carton b is along y axis

var W_bx {B} binary;    # 1 if width of carton b is along x axis
var W_by {B} binary;    # 1 if width of carton b is along y axis

#Vertical Stability
#var lx {P, P} >= 0 ; # overlap along x (carton)
#var wy {P, P} >= 0;  # overlap along y (carton)
#var supp {P, P} binary; #1 if p support pp
#var Zarea {P, P} >=0;# product Lx*Ly (linearized via McCormick)
#var on_floor {P} binary;# 1 if item p sits on floor (zp = 0 in assigned carton)
#var lenX {p in P} >= 0; 
#var widY {p in P} >= 0;
#var lub {p in P, pp in P} >= 0; # overlap bounds of length item
#var wub {p in P, pp in P} >= 0; # overlap bounds of Wide item

var SUPP {B,B} binary;	#1 if b support bb
var ON_FLOOR {B} binary; # 1 if carton b sits on floor (Zb = 0 in assigned container)
var lengthX {b in B} >= 0; 
var widthY {b in B} >= 0;
var Lx {B,B} >= 0; # overlap along x (container)
var Wy {B, B} >= 0;  # overlap along y (container)
var LUB {b in B, bb in B} >= 0; # overlap bounds of length carton
var WUB {b in B, bb in B} >= 0; # overlap bounds of Wide carton
var ZAREA {B,B} >= 0; #product Lx*Ly (linearized via McCormick)


#Objective Function

minimize Z :  sum {t in T}beta[t]*v[t];





##Carton packing Constraints

#s.t. c12 {p in P, b in B}:
#	x[p,b] <= u[b];

#s.t. c13 {p in P}:
#	sum {b in B} x[p,b] = 1;

#s.t. c14 {b in B} :
#	sum {p in P} WG[p]*x[p,b] <= CB[b]*u[b];
	
#s.t. c15 {b in B}:
#	sum {p in P} (lp[p]*wp[p]*hp[p])*x[p,b] <= LB[b]*WB[b]*HB[b];
	
#s.t. c16 {b in B, p in P}:
#	xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p] <=LB[b]*u[b] + M*(1-x[p,b]);
	
#s.t. c17 {b in B, p in P} :
#	yp[p] + lp[p]*l_py[p] + wp[p]*w_py[p] <= WB[b]*u[b] + M*(1-x[p,b]);

#s.t. c18 { b in B, p in P}:
#	zp[p] + hp[p] <= HB[b]*u[b] + M*(1-x[p,b]);


## relative positioning inside carton
#s.t. c19 {p in P, pp in P :  p != pp} :
#	xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p] <= xp[pp] + M*(1-xplus[p,pp]);
	
#s.t. c110 {p in P, pp in P: p != pp} :
#	xp[pp] + lp[pp]*l_px[pp] + wp[pp]*w_px[pp] <= xp[p] + M*(1-xminus[p,pp]);

#s.t. c111 {p in P, pp in P :  p != pp} :
#	yp[p] + lp[p]*l_py[p] +wp[p]*w_py[p] <= yp[pp] + M*(1-yplus[p,pp]);

#s.t. c112 {p in P, pp in P :  p != pp}:
#	yp[pp] + lp[pp]*l_py[pp] +wp[pp]*w_py[pp] <= yp[p] +M*(1-yminus[p,pp]);

#s.t. c113 {p in P,pp in P :  p != pp}:
#	zp[p] + hp[p] <= zp[pp] + M*(1-zplus[p,pp]);

#s.t. c114 {p in P, pp in P :  p != pp}:
#	zp[pp] + hp[pp] <= zp[p] + M*(1-zminus[p,pp]); 
	
	
#s.t. c115 { p in P, b in B ,pp in P : p != pp}:
#	xplus[p,pp] + xminus[p,pp] + yplus[p,pp] + yminus[p,pp] + zplus[p,pp] + zminus[p,pp] >=x[p,b] + x[pp,b] - 1;
	
#s.t.  c116 {p in P} :
#	l_px[p] + l_py[p] = 1;
#s.t. c117  {p in P} :
#	l_px[p] + w_px[p]  =1;
	
#s.t. c118 {p in P}:
#	w_px[p] + w_py[p] = 1;
	
#s.t. c119 {p in P} :
#	l_py[p] + w_py[p] = 1;

#s.t. c120 {b in B} :
 #    sum {f in F} q[b,f] <= u[b];
#s.t. c121 { b in B, f in F} :
#	sum {p in P} e[p,f]*x[p,b] <= M*q[b,f];
#s.t. c122 { b in B, f in F} :
#	q[b,f] <= sum {p in P} e[p,f]*x[p,b];


#s.t. c123 {p in P, b in B ,pp in P : p != pp}:
#	yx[p,pp,b] <= x[p,b];

#s.t. c124 {p in P, b in B ,pp in P : p != pp}:
#	yx[p,pp,b] <= x[pp,b];
	
#s.t. c125 {p in P, b in B ,pp in P : p != pp}:
#	yx[p,pp,b] >= x[p,b] + x[pp,b] - 1;
	
#s.t. c126 {p in P, pp in P : p != pp}:
#	ybar[p,pp] = sum {b in B} yx[p,pp,b];
	
#s.t. c127 {p in P, pp in P: p != pp}:
 #   xplus[p,pp] <= ybar[p,pp];

#s.t. c128 {p in P, pp in P: p != pp}:
 #   xminus[p,pp] <= ybar[p,pp];

#s.t. c129 {p in P, pp in P:  p != pp}:
 #   yplus[p,pp] <= ybar[p,pp];

#s.t. c130 {p in P, pp in P:  p != pp}:
 #  yminus[p,pp] <= ybar[p,pp];

#s.t. c131 {p in P, pp in P:  p != pp}:
 #   zplus[p,pp] <= ybar[p,pp];

#s.t. c132 {p in P, pp in P:  p != pp}:
 #   zminus[p,pp] <= ybar[p,pp];

#s.t. c133 {p in P, pp in P:  p != pp}:
#	 supp[p,pp] <= ybar[p,pp];

#s.t. c134 {p in P, pp in P:  p != pp}:
#	 supp[p,pp] <= zplus[p,pp];


#s.t. c135 {p in P, pp in P:  p != pp}:
 #   zp[pp] >= zp[p] + hp[p] - M*(1-supp[p,pp]);

#s.t. c136 {p in P, pp in P:  p != pp}:
 # zp[pp] <= zp[p] + hp[p] + M*(1-supp[p,pp]);
    
#s.t. c137 {p in P}:
#	zp[p] <= M*(1-on_floor[p]);
	
# Vertical Stability
#s.t. c138 {pp in P} :
#	 on_floor[pp] + sum{p in P : p != pp} supp[p,pp] = 1;
	 
#s.t. c139 {p in P, pp in P :  p != pp} :
 #   lx[p,pp] <= xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p]- xp[pp] + lub[p,pp]*(1-supp[p,pp]);


#s.t. c140{p in P, pp in P :  p != pp} :
 #  lx[p,pp] <= xp[pp] + lp[pp]*l_px[pp] + wp[pp]*w_px[pp]- xp[p] + lub[p,pp]*(1-supp[p,pp]);
  

#s.t. c141 {p in P, pp in P : p != pp }:
 #  wy[p,pp] <= yp[p] + lp[p]*l_py[p] +wp[p]*w_py[p]- yp[pp] +  wub[p,pp]*(1-supp[p,pp]);

#s.t. c142 {p in P, pp in P :  p != pp} :
 #  wy[p,pp] <= yp[pp] + lp[pp]*l_py[pp] +wp[pp]*w_py[pp]- yp[p] +  wub[p,pp]*(1-supp[p,pp]);


#s.t. lenX_def {p in P}:
 #   lenX[p] = lp[p]*l_px[p] + wp[p]*w_px[p];

#s.t. widY_def {p in P}:
 #   widY[p] = lp[p]*l_py[p] + wp[p]*w_py[p];

#s.t. LUB_def {p in P, pp in P:  p != pp} :
 #   lub[p,pp] <= lenX[p];
    
#s.t. LUB_def2 {p in P, pp in P:  p != pp}:
 #   lub[p,pp] <= lenX[pp];

# same for Y
#s.t. WUB_def {p in P, pp in P:  p != pp}:
 #   wub[p,pp] <= widY[p];
    
#s.t. WUB_def2 {p in P, pp in P: p != pp}:
 #   wub[p,pp] <= widY[pp];
    
#s.t. c182 {p in P, pp in P :  p != pp} :
 #  lx[p,pp] <= lub[p,pp]*supp[p,pp];

#s.t. c154 {p in P, pp in P :  p != pp} :
 #   wy[p,pp] <=  wub[p,pp]*supp[p,pp];
    
# McCormick relax (use global Lmax/Wmax)   
#s.t. c156 {p in P, pp in P :  p != pp} :
 #Zarea[p,pp] <= lub[p,pp]*wy[p,pp];

#s.t. c157 {p in P, pp in P :  p != pp} :
 #Zarea[p,pp] <= wub[p,pp]* lx[p,pp];

#s.t. c158 {p in P, pp in P :  p != pp} :
 #Zarea[p,pp]>=lub[p,pp]*wy[p,pp] + wub[p,pp]* lx[p,pp] -lub[p,pp]*wub[p,pp];

#s.t. c159 {p in P, pp in P :  p != pp} :
#Zarea[p,pp] <= lub[p,pp]* wub[p,pp]*supp[p,pp];

#s.t. c160 {pp in P} :
#sum {p in P:p != pp} Zarea[p,pp] >= alpha_supp*(lp[pp]*l_px[pp] + wp[pp]*w_px[pp])*(lp[pp]*l_py[pp] +wp[pp]*w_py[pp])*(1-on_floor[pp]) ;


## Container constraints

#s.t. try {b in B, t in T}:
#	y[b,t]<= u[b];
s.t. c161 {b in B, t in T}:
	y[b,t]<= v[t];

#s.t. c162 { b in B} :
#	sum { t in T} y[b,t] = u[b];
	

s.t. c162 { b in B} :
	sum { t in T} y[b,t] = 1;
	
#s.t. c163 { t in T}:
#	sum {b in B, p in P} WG[p]*x[p,b]*y[b,t] <= CT[t]*v[t];
	
#s.t. c163 { t in T}:
#	sum {b in B, p in P} WG[p]*y[b,t] <= CT[t]*v[t];
		
s.t. c164 {t in T} :
	sum { b in B}(LB[b]*WB[b]*HB[b])*y[b,t] <= LT[t]*WT[t]*HT[t];


s.t. c165 {b in B, t in T}:
Xb[b] + LB[b]*L_bx[b] +WB[b]*W_bx[b] <= LT[t]*v[t] + M*(1-y[b,t]);
	
s.t. c166 {b in B, t in T} :
Yb[b] + LB[b]*L_by[b] + WB[b]*W_by[b] <= WT[t]*v[t] + M*(1-y[b,t]);
	
s.t. c167 {b in B, t in T}:
	Zb[b] + HB[b] <= HT[t]*v[t] + M*(1-y[b,t]);
	
	
s.t. c168 {b in B, bb in B :b != bb} :
	Xb[b] +LB[b]*L_bx[b]+WB[b]*W_bx[b]<= Xb[bb]+M*(1-Xplus[b,bb]);
	
s.t. c169 {b in B, bb in B : b != bb} :
	Xb[bb]	+	LB[bb]*L_bx[bb] + WB[bb]*W_bx[bb]<= Xb[b]+ M*(1-Xminus[b,bb]);

s.t. c170 {b in B, bb in B : b != bb} :
	Yb[b]		+ LB[b]*L_by[b]+ WB[b]*W_by[b]<= Yb[bb] +	M*(1-Yplus[b,bb]);
	
s.t. c171 {b in B, bb in B : b != bb} :
	Yb[bb]	+ LB[bb]*L_by[bb]+	 WB[bb]*W_by[bb]<= Yb[b]	+ M*(1-Yminus[b,bb]);

s.t. c172 { b in B, bb in B : b != bb} :
	Zb[b] + HB[b] <= Zb[bb] + M*(1-Zplus[b,bb]);
	
s.t. c173 { b in B, bb in B : b != bb} :
	Zb[bb] + HB[bb] <= Zb[b] + M*(1-Zminus[b,bb]);

s.t. c174 {t in	T,b in B, bb in B : b != bb} :
	Xplus[b,bb] + Xminus[b,bb] + Yplus[b,bb]+ Yminus[b,bb]+ Zplus[b,bb] + Zminus[b,bb] >= y[b,t] + y[bb,t] - 1;

#s.t. c175 {b in B} :
#	L_bx[b] + L_by[b] = u[b];
	
#s.t. c176 {b in B} :
#	L_bx[b] + W_bx[b] = u[b];
	
#s.t. c177 {b in B} :
#	W_bx[b] + W_by[b] =u[b];

#s.t. c178 {b in B} :
#	L_by[b] + W_by[b] =u[b];
	
s.t. c175 {b in B} :
	L_bx[b] + L_by[b] = 1;
	
s.t. c176 {b in B} :
	L_bx[b] + W_bx[b] = 1;
	
s.t. c177 {b in B} :
	W_bx[b] + W_by[b] =1;

s.t. c178 {b in B} :
	L_by[b] + W_by[b] =1;
		
		
s.t. c179 {t in T}:
	sum {l in L} w[t,l] <= v[t];
	
s.t. c180 {l in L, t in T}:
    sum {b in B} Q[b,l] * y[b,t] <= M * w[t,l];
    
s.t. c181{b in B, l in L}:
    Q[b,l] <= sum {f in F} g[f,l] * q[b,f];
 
s.t. c184{b in B, l in L, f in F} :
    Q[b,l] >= q[b,f] + g[f,l] - 1 ; 

#s.t. c185 {t in T, b in B ,bb in B : b != bb}:
#	Yx[b,bb,t] <= y[b,t];

#s.t. c186 {t in T, b in B ,bb in B : b != bb}:
#	Yx[b,bb,t] <= y[bb,t];
	
#s.t. c187 {t in T, b in B ,bb in B : b != bb}:
#	Yx[b,bb,t] >= y[b,t] + y[bb,t] - 1;
	
#s.t. c188 {b in B ,bb in B : b != bb}:
#	Ybar[b,bb] = sum {t in T} Yx[b,bb,t];
	
#s.t. c189 {b in B ,bb in B : b != bb} :
#	Xplus[b,bb] <= Ybar[b,bb];
	
#s.t. c190 {b in B ,bb in B : b != bb} :
#	Xminus[b,bb] <= Ybar[b,bb];
	
#s.t. c191 {b in B ,bb in B : b != bb} :
#	Yplus[b,bb] <= Ybar[b,bb];
	
#s.t. c192 {b in B ,bb in B : b != bb} :
#	Yminus[b,bb] <= Ybar[b,bb];
	
#s.t. c193 {b in B ,bb in B : b != bb} :
#	Zplus[b,bb] <= Ybar[b,bb];
	
#s.t. c194 {b in B ,bb in B : b != bb} :
#	Zminus[b,bb] <= Ybar[b,bb];
	
#s.t. c195 {b in B ,bb in B : b != bb}:
#	 SUPP[b,bb] <= Ybar[b,bb];	

#s.t. c196 {b in B ,bb in B : b != bb}:
#	 SUPP[b,bb] <= Zplus[b,bb];	

#s.t. c197{b in B ,bb in B : b != bb}:
#	 Zb[bb] >= Zb[b] + HB[b] - M*(1-SUPP[b,bb]);	

#s.t. c198 {b in B ,bb in B : b != bb}:
#	 Zb[bb] <= Zb[b] + HB[b] + M*(1-SUPP[b,bb]);	
	

s.t. c199 {b in B}:
	 Zb[b] <= M*(1-ON_FLOOR[b]);	 

s.t. c200 {bb in B}:
	 ON_FLOOR[bb] + sum {b in B : b != bb} SUPP[b,bb] = 1;	
	 
s.t. c201 {b in B ,bb in B : b != bb} :
	Lx[b,bb] <= Xb[b] + LB[b]*L_bx[b] + WB[b]*W_bx[b] - Xb[bb] + LUB[b,bb]*(1-SUPP[b,bb]);
	
s.t. c202 {b in B ,bb in B : b != bb} :
	Lx[b,bb] <= Xb[bb] + LB[bb]*L_bx[bb] + WB[bb]*W_bx[bb] - Xb[b] + LUB[b,bb]*(1-SUPP[b,bb]);
	
s.t. c203 {b in B ,bb in B : b != bb} :
	Wy[b,bb] <= Yb[b] + LB[b]*L_by[b] + WB[b]*W_by[b] - Yb[bb] + WUB[b,bb]*(1-SUPP[b,bb]);
	
s.t. c204 {b in B ,bb in B : b != bb} :
	Wy[b,bb] <= Yb[bb] + LB[bb]*L_by[bb] + WB[bb]*W_by[bb] - Yb[b] + WUB[b,bb]*(1-SUPP[b,bb]);	

	 
	 
s.t. c205 {b in B}:
    lengthX[b] = LB[b]*L_bx[b] + WB[b]*W_bx[b];

s.t. c206 {b in B}:
    widthY[b] = LB[b]*L_by[b] + WB[b]*W_by[b];

s.t. c207 {b in B ,bb in B : b != bb} :
    LUB[b,bb] <= lengthX[b];
    
s.t. c208 {b in B ,bb in B : b != bb}:
    LUB[b,bb] <= lengthX[bb];

# same for Y
s.t. c209 {b in B ,bb in B : b != bb}:
    WUB[b,bb] <= widthY[b];
    
s.t. c210 {b in B ,bb in B : b != bb}:
  	 WUB[b,bb] <= widthY[bb];
    
s.t. c211 {b in B ,bb in B : b != bb} :
   Lx[b,bb] <= LUB[b,bb]*SUPP[b,bb];

s.t. c212 {b in B ,bb in B : b != bb} :
    Wy[b,bb] <=  WUB[b,bb]*SUPP[b,bb];

# McCormick relax (use global Lmax/Wmax)   
s.t. c213 {b in B ,bb in B : b != bb} :
 ZAREA[b,bb] <= LUB[b,bb]*Wy[b,bb];

s.t. c214 {b in B ,bb in B : b != bb} :
 	ZAREA[b,bb] <= WUB[b,bb]*Lx[b,bb];

s.t. c215 {b in B ,bb in B : b != bb} :
 ZAREA[b,bb] >=LUB[b,bb]*Wy[b,bb] + WUB[b,bb]*Lx[b,bb] -LUB[b,bb]*WUB[b,bb];

s.t. c216 {b in B ,bb in B : b != bb} :
 ZAREA[b,bb] <= LUB[b,bb]*WUB[b,bb]*SUPP[b,bb];

s.t. c217 {bb in B} :
sum {b in B : b != bb} ZAREA[b,bb] >= beta_supp*(LB[bb]*L_bx[bb] + WB[bb]*W_bx[bb])*(LB[bb]*L_by[bb] +WB[bb]*W_by[bb])*(1-ON_FLOOR[bb]) ;


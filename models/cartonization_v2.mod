### Sets

set P; #index Product
set N; #type product 
#set F; #Family of Products
set B; # index cartons
set S; #type cartons



### Parameter of Products

param lp_n {P} >=0; #Length of product p
param wp_n {P} >= 0; #Width of product p
param hp_n {P} >= 0; # Height of product p
param WG_n {P} >= 0; # Weight of product p
param Demand_p{N} ; #inventory S

var lp {P} >=0; #Length of product p
var wp {P} >= 0; #Width of product p
var hp {P} >= 0; # Height of product p
var  WG{P} >= 0; # Weight of product p

### Parameter for cartons

param LB_s {S}; # Length of carton b
param WB_s {S}; # Width of carton b
param HB_s {S}; # Height of carton b
param CB_s {S}; # Load bearing capacity of carton b
#param Hmax := max {s in S} HB_s[s]; # maximum Height of Carton type b
#param Lmax := max {s in S} LB_s[s]; # maximum Length of Carton type b
#param Wmax := max {b in B} WB_s[s]; # maximum Wide of Carton type b
#param BOTTOM_AREA{s in S} := LB_s[s]*WB_s[s]; #Bottom area of carton type bb (carton stacked)
param Invr_b{S} ; #inventory S
var LB{B} >= 0; # Length of carton b
var WB {B} >= 0; # Width of carton b
var HB {B} >= 0; # Height of carton b
var CB {B} >= 0; # Load bearing capacity of carton b

#param type_of {B} integer ;# mapping box 
#param E{D,P}; #demand of each type of product
### Binary family mapping
#param e {P, F}, binary;   # 1 if product p belongs to family f

### Cost factors
param alpha_s{S};              # Cost factor for using carton type s
param alpha_supp;		# minimum percentage of its bottom face supported by other items' top faces
### Large constant
param M;                  # Sufficiently large constant


### Packing decision, usage, and assignment variables
var x {P, B} binary;      # 1 if product p is packed in carton b
var u {B} binary;         # 1 if carton b is used
#var q {B, F} binary;      # 1 if at least one product in family f is in b


### Positioning variables
var xp {P} >= 0 integer;
var yp {P} >= 0 integer;
var zp {P} >= 0 integer;


#var ybar {P,P} binary;
#var yx {p in P, pp in P, b in B} binary;
var xplus {P, P} binary;
var xminus {P, P} binary;
var yplus {P, P} binary;
var yminus {P, P} binary;
var zplus {P, P} binary;
var zminus {P, P} binary;

# Orientation variables for products
var l_px {P}binary;    # 1 if length of product p is along x axis
var l_py {P} binary;    # 1 if length of product p is along y axis

var w_px {P}binary;    # 1 if width of product p is along x axis
var w_py {P}binary;    # 1 if width of product p is along y axis

#Vertical Stability
var lx {P,P} >= 0 ; # overlap along x (carton)
var wy {P,P} >= 0;  # overlap along y (carton)
var supp {P,P} binary; #1 if p support pp
var Zarea {P,P} >=0;# product Lx*Ly (linearized via McCormick)
var on_floor {P} binary;# 1 if item j sits on floor (zp = 0 in assigned carton)
var lenX {p in P} >= 0; # Effective length of item p along X
var widY {p in P} >= 0; # Effective width of item p along Y
var LUB {P,P} >= 0; # overlap bounds of length
var WUB {P,P} >= 0; # overlap bounds of Wide

# auxiliary variable
var dp {P,P} >= 0 ; #auxiliary variable for linearization dp = lenX[p]*supp
var ep {P,P} >= 0 ; #auxiliary variable for linearization dp = Widy[p]*supp
var o {b in B, s in S} binary;
param r {p in P, n in N} binary;



#Objective Function

minimize Z :  sum {b in B, s in S}alpha_s[s]*o[b,s] ;




##Carton packing Constraints

s.t. c12 {p in P, b in B}:
	x[p,b] <= u[b];
	
s.t. c13 {p in P}:
	sum {b in B} x[p,b] = 1;

s.t. c14 {b in B} :
	sum {p in P} WG[p]*x[p,b] <= sum {s in S} CB_s[s]*o[b,s];
	
s.t. c15 {b in B}:
	sum {p in P} (lp[p]*wp[p]*hp[p])*x[p,b] <= sum {s in S}  LB_s[s]*WB_s[s]*HB_s[s]*o[b,s];
	
s.t. c16 {b in B, p in P}:
	xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p] <= sum {s in S} LB_s[s]*o[b,s] + M*(1-x[p,b]);
s.t. c17 {b in B, p in P} :
	yp[p] + lp[p]*l_py[p] + wp[p]*w_py[p] <= sum {s in S} WB_s[s]*o[b,s] + M*(1-x[p,b]);

s.t. c18 { b in B, p in P}:
	zp[p] + hp[p] <= sum {s in S}HB_s[s]*o[b,s] + M*(1-x[p,b]);
	
## relative positioning inside carton
s.t. c19 {p in P, pp in P :  p != pp} :
	xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p] <= xp[pp] + M*(1-xplus[p,pp]);
	
s.t. c110 {p in P, pp in P: p != pp} :
	xp[pp] + lp[pp]*l_px[pp] + wp[pp]*w_px[pp] <= xp[p] + M*(1-xminus[p,pp]);

s.t. c111 {p in P, pp in P :  p != pp} :
	yp[p] + lp[p]*l_py[p] +wp[p]*w_py[p] <= yp[pp] + M*(1-yplus[p,pp]);

s.t. c112 {p in P, pp in P :  p != pp}:
	yp[pp] + lp[pp]*l_py[pp] +wp[pp]*w_py[pp] <= yp[p] +M*(1-yminus[p,pp]);

s.t. c113 {p in P,pp in P :  p != pp}:
	zp[p] + hp[p] <= zp[pp] + M*(1-zplus[p,pp]);

s.t. c114 {p in P, pp in P :  p != pp}:
	zp[pp] + hp[pp] <= zp[p] + M*(1-zminus[p,pp]); 
	
	
s.t. c115 { p in P, b in B ,pp in P : p != pp}:
	xplus[p,pp] + xminus[p,pp] + yplus[p,pp] + yminus[p,pp] + zplus[p,pp] + zminus[p,pp] >=x[p,b] + x[pp,b] - 1;
	
s.t.  c116 {p in P} :
	l_px[p] + l_py[p] = 1;
s.t. c117  {p in P} :
	l_px[p] + w_px[p]  =1;
	
s.t. c118 {p in P}:
	w_px[p] + w_py[p] = 1;
	
s.t. c119 {p in P} :
	l_py[p] + w_py[p] = 1;

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


s.t. c135 {p in P, pp in P:  p != pp}:
    zp[pp] >= zp[p] + hp[p] - M*(1-supp[p,pp]);

s.t. c136 {p in P, pp in P:  p != pp}:
  zp[pp] <= zp[p] + hp[p] + M*(1-supp[p,pp]);
    
s.t. c137 {p in P}:
	zp[p] <= M*(1-on_floor[p]);
	
# Vertical Stability
s.t. c138 {pp in P} :
on_floor[pp] + sum{p in P : p != pp} supp[p,pp] = 1;
	
	 
s.t. c139 {p in P, pp in P:  p != pp} :
  lx[p,pp] <= xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p]- xp[pp] + lenX[pp]-dp[p,pp];


s.t. c140{p in P, pp in P:  p != pp} :
  lx[p,pp] <= xp[pp] + lp[pp]*l_px[pp] + wp[pp]*w_px[pp]- xp[p] + lenX[pp]-dp[p,pp];
  

s.t. c141 {p in P, pp in P:  p != pp }:
 wy[p,pp] <= yp[p] + lp[p]*l_py[p] +wp[p]*w_py[p]- yp[pp] +  widY[pp] - ep[p,pp];

s.t. c142 {p in P, pp in P:  p != pp} :
 wy[p,pp] <= yp[pp] + lp[pp]*l_py[pp] +wp[pp]*w_py[pp]- yp[p] + widY[pp] - ep[p,pp];

s.t. lenX_def {p in P}:
  lenX[p] = lp[p]*l_px[p] + wp[p]*w_px[p];

s.t. widY_def {p in P}:
  widY[p] = lp[p]*l_py[p] + wp[p]*w_py[p];


## Auxiliary variable
s.t. c160 {p in P, pp in P:  p != pp} :
dp[p,pp] >= lenX[pp]-M*(1-supp[p,pp]) ;

s.t. c161 {p in P, pp in P:  p != pp} :
dp[p,pp] <= M*supp[p,pp]; 

s.t. c162 {p in P, pp in P:  p != pp} :
dp[p,pp] <= lenX[pp];
 
s.t. c163 {p in P, pp in P:  p != pp} :
ep[p,pp] >= widY[pp]-M*(1-supp[p,pp]) ;

s.t. c164 {p in P, pp in P:  p != pp} :
 ep[p,pp] <= M*supp[p,pp];
 
s.t. c165  {p in P, pp in P :  p != pp} :
	ep[p,pp] <= widY[pp];
 
# McCormick relax (use global Lmax/Wmax)   
 s.t. c156 {p in P, pp in P:  p != pp} :
 Zarea[p,pp] <= lp[pp]*wy[p,pp];

 s.t. c157 {p in P, pp in P:  p != pp} :
 Zarea[p,pp] <= wp[pp]* lx[p,pp];

 s.t. c158 {p in P, pp in P:  p != pp} :
 Zarea[p,pp]>=lp[pp]*wy[p,pp] + wp[pp]* lx[p,pp] -lp[pp]*wp[pp];

 s.t. c170 {p in P, pp in P:  p != pp} :
	Zarea[p,pp] <= lp[pp]*wp[pp]*supp[p,pp];

 s.t. c159 {pp in P} :
 sum {p in P:p != pp} Zarea[p,pp] >= alpha_supp*lp[pp]*wp[pp]*(1-on_floor[pp]) ;
 
s.t. pick_box_type {b in B}:
    sum {s in S} o[b,s] = u[b];


s.t. box_inventory {s in S}:
   sum {b in B} o[b,s]  <= Invr_b[s];



s.t. set_LB {b in B}: 
	LB[b] = sum {s in S} LB_s[s] * o[b,s];

s.t. set_WB {b in B}: 
	WB[b] = sum {s in S} WB_s[s] * o[b,s];
	
s.t. set_HB {b in B}:
	HB[b] = sum {s in S} HB_s[s] * o[b,s];
	
s.t. set_CB {b in B}:
	CB[b] = sum {s in S} CB_s[s] * o[b,s];

    
 s.t. set_lp {p in P}: 
	lp[p] = sum {n in N} lp_n[n] * r[p,n];

 s.t. set_wp {p in P}: 
	wp[p] = sum {n in N} wp_n[n] * r[p,n];
	
 s.t. set_hp {p in P}:
	hp[p] = sum {n in N} hp_n[n] * r[p,n];
	
s.t. set_cp {p in P}:
	WG[p] = sum {n in N} WG_n[n] * r[p,n];

#s.t. product_demand {n in N}:
 # sum {p in P} r[p,n]  <= Demand_p[n];

## symetric breaking

#s.t. sym_carton_type {s in S, b in B, bb in B: ord(b) < ord(bb)}:
 #   o[b,s] >= o[bb,s];

#s.t. sym_carton_use {b in B: ord(b) < card(B)}:
 #   u[b] >= u[next(b)];    
# For pairs p < pp that share the same type n
#s.t. sym_item_assign {p in P, pp in P: ord(p) < ord(pp),
  #                    sum {n in N} r[p,n]*r[pp,n] = 1}:
 #   sum {b in B} ord(b) * x[p,b] <= sum {b in B} ord(b) * x[pp,b];   
    
    

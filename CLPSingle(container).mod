### Sets

set P; #Products (small items)
set B; #Cartons
set F; #Family of Products




### Parameter of Products

param lp {P}; #Length of product p
param wp {P}; #Width of product p
param hp {P}; # Height of product p
param WG {P}; # Weight of product p

### Parameter for cartons

param LB {B}; # Length of carton b
param WB {B}; # Width of carton b
param HB {B}; # Height of carton b
param CB {B}; # Load bearing capacity of carton b
param Hmax := max {b in B} HB[b];
param Lmax := max {b in B} LB[b];
param Wmax := max {b in B} WB[b];


### Binary family mapping
param e {P, F}, binary;   # 1 if product p belongs to family f

### Cost factors
param alpha;              # Cost factor for using carton
param alpha_supp;		# minimum percentage of its bottom face supported by other items' top faces

### Large constant
param M;                  # Sufficiently large constant


### Packing decision, usage, and assignment variables
var x {P, B} binary;      # 1 if product p is packed in carton b
var u {B} binary;         # 1 if carton b is used
var q {B, F} binary;      # 1 if at least one product in family f is in b


### Positioning variables
var xp {P} >= 0;
var yp {P} >= 0;
var zp {P} >= 0;


var ybar {P,P} binary;
var yx {p in P, pp in P, b in B} binary;
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
var lx {P, P} >= 0 ; # overlap along x (carton)
var wy {P, P} >= 0;  # overlap along y (carton)
var supp {P, P} binary; #1 if p support pp
var Zarea {P, P} >=0;# product Lx*Ly (linearized via McCormick)
var on_floor {P} binary;# 1 if item j sits on floor (zp = 0 in assigned carton)

#Objective Function

minimize Z :  alpha * sum {b in B} u[b];




#Carton packing Constraints

s.t. c12 {p in P, b in B}:
	x[p,b] <= u[b];
	
s.t. c13 {p in P}:
	sum {b in B} x[p,b] = 1;

s.t. c14 {b in B} :
	sum {p in P} WG[p]*x[p,b] <= CB[b]*u[b];
	
s.t. c15 {b in B}:
	sum {p in P} (lp[p]*wp[p]*hp[p])*x[p,b] <= LB[b]*WB[b]*HB[b];
	
s.t. c16 {b in B, p in P}:
	xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p] <=LB[b]*u[b] + M*(1-x[p,b]);
s.t. c17 {b in B, p in P} :
	yp[p] + lp[p]*l_py[p] + wp[p]*w_py[p] <= WB[b]*u[b] + M*(1-x[p,b]);

s.t. c18 { b in B, p in P}:
	zp[p] + hp[p] <= HB[b]*u[b] + M*(1-x[p,b]);
	
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

s.t. c120 {b in B} :
     sum {f in F} q[b,f] <= u[b];
s.t. c121 { b in B, f in F} :
	sum {p in P} e[p,f]*x[p,b] <= M*q[b,f];
s.t. c122 { b in B, f in F} :
	q[b,f] <= sum {p in P} e[p,f]*x[p,b];


s.t. c145 {p in P, b in B ,pp in P : p != pp}:
	yx[p,pp,b] <= x[p,b];

s.t. c146 {p in P, b in B ,pp in P : p != pp}:
	yx[p,pp,b] <= x[pp,b];
	
s.t. c147 {p in P, b in B ,pp in P : p != pp}:
	yx[p,pp,b] >= x[p,b] + x[pp,b] - 1;
	
s.t. c148 {p in P, pp in P : p != pp}:
	ybar[p,pp] = sum {b in B} yx[p,pp,b];
	
s.t. c149 {p in P, pp in P: p != pp}:
    xplus[p,pp] <= ybar[p,pp];

s.t. c150 {p in P, pp in P: p != pp}:
    xminus[p,pp] <= ybar[p,pp];

s.t. c151 {p in P, pp in P:  p != pp}:
    yplus[p,pp] <= ybar[p,pp];

s.t. c152 {p in P, pp in P:  p != pp}:
   yminus[p,pp] <= ybar[p,pp];

s.t. c153 {p in P, pp in P:  p != pp}:
    zplus[p,pp] <= ybar[p,pp];

s.t. c154 {p in P, pp in P:  p != pp}:
    zminus[p,pp] <= ybar[p,pp];

s.t. c157 {p in P, pp in P:  p != pp}:
	 supp[p,pp] <= ybar[p,pp];

s.t. c158 {p in P, pp in P:  p != pp}:
	 supp[p,pp] <= zplus[p,pp];


s.t. c162 {p in P, pp in P:  p != pp}:
    zp[pp] >= zp[p] + hp[p] - Hmax*(1-supp[p,pp]);

s.t. c161 {p in P, pp in P:  p != pp}:
  zp[pp] <= zp[p] + hp[p] + Hmax*(1-supp[p,pp]);
    
s.t. c163 {p in P}:
	zp[p] <= Hmax*(1-on_floor[p]);
	

s.t. c165 {pp in P} :
	 on_floor[pp] + sum{p in P : p != pp} supp[p,pp] = 1;
	 
  
s.t. c132 {p in P, pp in P :  p != pp} :
    lx[p,pp] <= xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p]- xp[pp] + Lmax*(1-supp[p,pp]);


s.t. c133 {p in P, pp in P :  p != pp} :
   lx[p,pp] <= xp[pp] + lp[pp]*l_px[pp] + wp[pp]*w_px[pp]- xp[p] + Lmax*(1-supp[p,pp]);
  

s.t. c134 {p in P, pp in P : p != pp }:
   wy[p,pp] <= yp[p] + lp[p]*l_py[p] +wp[p]*w_py[p]- yp[pp] +  Wmax*(1-supp[p,pp]);

s.t. c135 {p in P, pp in P :  p != pp} :
   wy[p,pp] <= yp[pp] + lp[pp]*l_py[pp] +wp[pp]*w_py[pp]- yp[p] + Wmax*(1-supp[p,pp]);


s.t. c182 {p in P, pp in P :  p != pp} :
   lx[p,pp] <= Lmax*supp[p,pp];

s.t. c183 {p in P, pp in P :  p != pp} :
    wy[p,pp] <= Wmax*supp[p,pp];
   
s.t. c136 {p in P, pp in P :  p != pp} :
 Zarea[pp,p] >= lx[p,pp]* wy[p,pp];

s.t. c140 {pp in P } :
sum {p in P:p != pp} Zarea[pp,p] >= alpha_supp*(lp[pp]*l_px[pp] + wp[pp]*w_px[pp])*(lp[pp]*l_py[pp] +wp[pp]*w_py[pp])*(1-on_floor[pp]);



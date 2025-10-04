### Sets

set P ordered; #Products (small items)
set B ordered; #Cartons
set F; #Family of Products
set T; #containers (vehicle)
set L; #Family of cartons


### Parameter of Products
#nambah sesuatu

param lp {P}; #Length of product p
param wp {P}; #Width of product p
param hp {P}; # Height of product p
param WG {P}; # Weight of product p

### Parameter for cartons

param LB {B}; # Length of carton b
param WB {B}; # Width of carton b
param HB {B}; # Height of carton b
param CB {B}; # Load bearing capacity of carton b

### Parameter of Containers
param LT {T}; # Length of container t
param WT {T}; # Width of container t
param HT {T}; # Height of container t
param CT {T}; # Load bearing capacity of container t



### Binary family mapping
param e {P, F}, binary;   # 1 if product p belongs to family f
param g {B, L}, binary;   # 1 if carton b belongs to family l

### Cost factors
param alpha;              # Cost factor for using carton
param beta; 			  # Cost factor for using each container
param alpha_supp;		# minimum percentage of its bottom face supported by other items' top faces
param epsilon;
### Large constant
param M;                  # Sufficiently large constant


### Packing decision, usage, and assignment variables
var x {P, B} binary;      # 1 if product p is packed in carton b
var u {B} binary;         # 1 if carton b is used
var q {B, F} binary;      # 1 if at least one product in family f is in b
var v {T} binary; 		  #1 if container t is used
var y {B,T} binary; 	  #1 if b is loaded in container t
var w  {T,L} binary; 	  #1 if at least one carton in family l are loaded into container t

### Positioning variables
var xp {P} >= 0;
var yp {P} >= 0;
var zp {P} >= 0;

var xb {B} >= 0;
var yb {B} >= 0;
var zb {B} >= 0;


var ybar {P,P} binary;
var yx {p in P, pp in P, b in B} binary;
var xplus {P, P} binary;
var xminus {P, P} binary;
var yplus {P, P} binary;
var yminus {P, P} binary;
var zplus {P, P} binary;
var zminus {P, P} binary;

var Xplus {B,B} binary;
var Xminus {B,B} binary;
var Yplus {B,B} binary;
var Yminus {B,B} binary;
var Zplus {B,B} binary;
var Zminus {B,B} binary;


# Orientation variables for products
var l_px {P}binary;    # 1 if length of product p is along x axis
var l_py {P} binary;    # 1 if length of product p is along y axis

var w_px {P}binary;    # 1 if width of product p is along x axis
var w_py {P}binary;    # 1 if width of product p is along y axis

var L_bx {B} binary; 	#1 if length of carton b is parallel to x axis
var L_by {B} binary; 	#1 if length of carton b is parallel to y axis

var W_bx {B} binary;    #1 if width of carton b is parallel to x axis
var W_by {B} binary; 	#1 if width of carton b is parallel to y axis

#Vertical Stability
var lx {p in P, pp in P} >= 0 ; # overlap along x (carton)
var wy {p in P, pp in P} >= 0;  # overlap along y (carton)
var supp {p in P, pp in P} binary; #1 if p support pp
var Zarea {p in P, pp in P} >=0;# product Lx*Ly (linearized via McCormick)
var on_floor {P} binary;# 1 if item j sits on floor (zp = 0 in assigned carton)

#Good practice to make big M as tight as possible (if possible)
var n_fp {f in F} >=0; # num of products in family f


#Objective Function

minimize Z : alpha * sum {b in B} u[b] + beta * sum{t in T} v[t];

#Prepare aux variables
s.t. c01 {f in F}:
    sum {p in P} e[p,f] = n_fp[f];

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

## record which items share the same carton
s.t. c145 {p in P, b in B ,pp in P : p != pp}:
	yx[p,pp,b] <= x[p,b];

s.t. c146 {p in P, b in B ,pp in P : p != pp}:
	yx[p,pp,b] <= x[pp,b];

s.t. c147 {p in P, b in B ,pp in P :p != pp}:
	yx[p,pp,b] >= x[p,b] + x[pp,b] - 1;
	
s.t. c148 {p in P, pp in P : p != pp}:
	ybar[p,pp] = sum {b in B} yx[p,pp,b];

## ensure only products of same family share carton
s.t. c120 {b in B} :
     sum {f in F} q[b,f] <= u[b];
s.t. c121 { b in B, f in F} :
	sum {p in P} e[p,f]*x[p,b] <= n_fp[f]*q[b,f];
s.t. c122 { b in B, f in F} :
	q[b,f] <= sum {p in P} e[p,f]*x[p,b];
s.t. c123 {p in P, pp in P :ord(p) < ord(pp)}:
	sum{f in F} e[p,f]*e[pp, f] >= 1 - M*(1-ybar[p,pp]);

## product rotation in carton
s.t.  c116 {p in P} :
	l_px[p] + l_py[p] = 1;

s.t. c117  {p in P} :
	l_px[p] + w_px[p]  =1;
	
s.t. c118 {p in P}:
	w_px[p] + w_py[p] = 1;
	
s.t. c119 {p in P} :
	l_py[p] + w_py[p] = 1;


## relative positioning inside carton
s.t. c19 {p in P, pp in P : p != pp} :
	xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p] <= xp[pp] + M*(1-xplus[p,pp]) + M*(1-ybar[p,pp]);

s.t. c19a {p in P, pp in P : p != pp} :
	xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p] <= xp[pp] + M*(1-xminus[pp,p]) + M*(1-ybar[p,pp]);
	
s.t. c111 {p in P, pp in P : p != pp} :
	yp[p] + lp[p]*l_py[p] +wp[p]*w_py[p] <= yp[pp] + M*(1-yplus[p,pp]) + M*(1-ybar[p,pp]);

s.t. c111a {p in P, pp in P : p != pp} :
	yp[p] + lp[p]*l_py[p] +wp[p]*w_py[p] <= yp[pp] + M*(1-yminus[pp,p]) + M*(1-ybar[p,pp]);

s.t. c113 {p in P,pp in P : p != pp}:
	zp[p] + hp[p] <= zp[pp] + M*(1-zplus[p,pp]) + M*(1-ybar[p,pp]);
	
s.t. c113a {p in P,pp in P : p != pp}:
	zp[p] + hp[p] <= zp[pp] + M*(1-zminus[pp,p]) + M*(1-ybar[p,pp]);
	
s.t. c115 { p in P, b in B ,pp in P : p != pp}:
	xplus[p,pp] + xminus[p,pp] + yplus[p,pp] + yminus[p,pp] + zplus[p,pp] + zminus[p,pp] >= ybar[p, pp];
	
s.t. c149 { p in P, pp in P : p != pp}:
	xplus[p,pp] + xminus[p,pp] <=2*ybar[p,pp];
	
s.t. c150 { p in P, pp in P : p != pp}:
	zplus[p,pp] + zminus[p,pp] <=2*ybar[p,pp];
	
s.t. c151 { p in P, pp in P : p != pp}:
	yplus[p,pp] + yminus[p,pp] <=2*ybar[p,pp];
	
# To make the zp start the coordinate from 0
# s.t. c129  {b in B, p in P}:
# 	zp[p] <= HB[b]*(1-on_floor[p]);

# s.t. c141  {p in P}:
# 	zp[p] > epsilon*(1-on_floor[p]) - on_floor[p]*M;

# s.t. c130 {p in P, b in B ,pp in P :ord(p) < ord(pp)}:
# 	on_floor[pp] >= 1- supp[p,pp];

	 
#s.t. c142 {p in P, b in B ,pp in P :ord(p) < ord(pp)}:
	#supp[p,pp] >= x[p,b] +x[pp,b]-1;
 
# s.t. c143 {p in P, pp in P :ord(p) < ord(pp)}:
# 	supp[p,pp] <= zplus[p,pp];
	



# s.t. c132 {b in B,p in P, pp in P : ord (p) < ord (pp)} :
#    lx[p,pp] <= xp[p] + lp[p]*l_px[p] + wp[p]*w_px[p]- xp[pp]+LB[b]*u[b]*(1-supp[p,pp]);
   
# s.t. c133 {b in B , p in P, pp in P : ord (p) < ord (pp)} :
#    lx[p,pp] <= xp[pp] + lp[pp]*l_px[pp] + wp[pp]*w_px[pp]- xp[p] + LB[b]*u[b]*(1-supp[p,pp]);
   
# s.t. c134 {b in B , p in P, pp in P : ord (p) < ord (pp)} :
#    wy[p,pp] <= yp[p] + lp[p]*l_py[p] +wp[p]*w_py[p]- yp[pp] +  WB[b]*u[b]*(1-supp[p,pp]);

# s.t. c135 {b in B , p in P, pp in P : ord (p) < ord (pp)} :
#    wy[p,pp] <= yp[pp] + lp[pp]*l_py[pp] +wp[pp]*w_py[pp]- yp[p] +  WB[b]*u[b]*(1-supp[p,pp]);

# s.t. c136 {b in B , p in P, pp in P : ord (p) < ord (pp)} :
#  Zarea[p,pp] <= LB[b]*u[b]*wy[p,pp] ;

# s.t. c137 {b in B , p in P, pp in P : ord (p) < ord (pp)} :
#  Zarea[p,pp] <= WB[b]*u[b]*lx[p,pp] ;
 
# s.t. c138 {b in B , p in P, pp in P : ord (p) < ord (pp)} :
#  Zarea[p,pp] >= LB[b]*u[b]*wy[p,pp]+ WB[b]*u[b]*lx[p,pp]-LB[b]*u[b]*WB[b]*u[b];



# s.t. c140 {b in B ,p in P, pp in P: ord(p) < ord(pp)}:
# sum {r in P} Zarea[r,pp]>= alpha_supp*(lp[pp]*l_px[pp] + wp[pp]*w_px[pp])*(lp[pp]*l_py[pp] +wp[pp]*w_py[pp]) * x[pp,b]*supp[p,pp];

 
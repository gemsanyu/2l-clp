### Sets

set P; #Products (small items)
set B; #Cartons
#set F; #Family of Products

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
param Hmax := max {b in B} HB[b]; # maximum Height of Carton
param Lmax := max {b in B} LB[b]; # maximum Length of Carton
param Wmax := max {b in B} WB[b]; # maximum Wide of Carton

### Cost factors
param alpha{B};              # Cost factor for using carton
param alpha_supp;		# minimum percentage of its bottom face supported by other items' top faces

### Large constant
param M;                  # Sufficiently large constant


### Packing decision, usage, and assignment variables
var x {P, B} binary;      # 1 if product p is packed in carton b
var u {B} binary;         # 1 if carton b is used
#var q {B, F} binary;      # 1 if at least one product in family f is in b


### Positioning variables
var xp {P} >= 0;
var yp {P} >= 0;
var zp {P} >= 0;


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
var lx {P, P} >= 0 ; # overlap along x (carton)
var wy {P, P} >= 0;  # overlap along y (carton)
var supp {P, P} binary; #1 if p support pp
var in_same_carton {P, P} binary;
var isc_aux {P, P, B} binary; #aux variable to linearize x[p,b]*x[pp,b]
var Zarea {P, P} >=0;# product Lx*Ly (linearized via McCormick)
var on_floor {P} binary;# 1 if item j sits on floor (zp = 0 in assigned carton)
var lenX {p in P} >= 0; # Effective length of item p along X
var widY {p in P} >= 0; # Effective width of item p along Y
var LUB {p in P, pp in P} >= 0; # overlap bounds of length
var WUB {p in P, pp in P} >= 0; # overlap bounds of Wide


#Objective Function

minimize Z :   sum {b in B}alpha[b]*u[b];




##Carton packing Constraints

s.t. lenX_def {p in P}:
    lenX[p] = lp[p]*l_px[p] + wp[p]*w_px[p];

s.t. widY_def {p in P}:
    widY[p] = lp[p]*l_py[p] + wp[p]*w_py[p];

s.t. c12 {p in P, b in B}:
	x[p,b] <= u[b];
	
s.t. c13 {p in P}:
	sum {b in B} x[p,b] = 1;

s.t. c14 {b in B} :
	sum {p in P} WG[p]*x[p,b] <= CB[b]*u[b];
	
s.t. c15 {b in B}:
	sum {p in P} (lp[p]*wp[p]*hp[p])*x[p,b] <= LB[b]*WB[b]*HB[b];
	
s.t. c16 {b in B, p in P}:
	xp[p] + lenX[p] <=LB[b]*u[b] + M*(1-x[p,b]);
s.t. c17 {b in B, p in P} :
	yp[p] + widY[p] <= WB[b]*u[b] + M*(1-x[p,b]);

s.t. c18 { b in B, p in P}:
	zp[p] + hp[p] <= HB[b]*u[b] + M*(1-x[p,b]);
	
## relative positioning inside carton
s.t. c19 {p in P, pp in P :  p != pp} :
	xp[p] + lenX[p] <= xp[pp] + M*(1-xplus[p,pp]);
	
s.t. c110 {p in P, pp in P: p != pp} :
	xp[pp] + lenX[pp] <= xp[p] + M*(1-xminus[p,pp]);

s.t. c111 {p in P, pp in P :  p != pp} :
	yp[p] + widY[p] <= yp[pp] + M*(1-yplus[p,pp]);

s.t. c112 {p in P, pp in P :  p != pp}:
	yp[pp] + widY[pp] <= yp[p] +M*(1-yminus[p,pp]);

s.t. c113 {p in P,pp in P :  p != pp}:
	zp[p] + hp[p] <= zp[pp] + M*(1-zplus[p,pp]);

s.t. c114 {p in P, pp in P :  p != pp}:
	zp[pp] + hp[pp] <= zp[p] + M*(1-zminus[p,pp]); 

# s.t. c115aux1 {b in B, p in P, pp in P: p!=pp}:
# 	isc_aux[p,pp,b] <= x[p,b];

# s.t. c115aux2 {b in B, p in P, pp in P: p!=pp}:
# 	isc_aux[p,pp,b] <= x[pp,b];

# s.t. c115aux3 {b in B, p in P, pp in P: p!=pp}:
# 	isc_aux[p,pp,b] >= x[p,b] + x[pp,b] - 1;

s.t. c115a {p in P, pp in P}:
	in_same_carton[p,pp] = sum{b in B} x[p,b] * x[pp,b];

s.t. c115b { p in P, pp in P: p != pp}:
	xplus[p,pp] + xminus[p,pp] + yplus[p,pp] + yminus[p,pp] + zplus[p,pp] + zminus[p,pp] >= in_same_carton[p,pp] - 1;
	
s.t.  c116 {p in P} :
	l_px[p] + l_py[p] = 1;
s.t. c117  {p in P} :
	l_px[p] + w_px[p]  =1;
	
s.t. c118 {p in P}:
	w_px[p] + w_py[p] = 1;
	
s.t. c119 {p in P} :
	l_py[p] + w_py[p] = 1;

s.t. c135 {p in P, pp in P:  p != pp}:
    zp[pp] >= zp[p] + hp[p] - M*(1-supp[p,pp]);

s.t. c136 {p in P, pp in P:  p != pp}:
  zp[pp] <= zp[p] + hp[p] + M*(1-supp[p,pp]);
    
s.t. c137 {p in P}:
	zp[p] <= M*(1-on_floor[p]);
	
# Vertical Stability
s.t. c138 {pp in P} :
	 on_floor[pp] + sum{p in P : p != pp} supp[p,pp] = 1;

# s.t. c139 {p in P, pp in P :  p != pp} :
#     lx[p,pp] <= xp[p] + lenX[p]- xp[pp] + LUB[p,pp]*(1-supp[p,pp]);


# s.t. c140{p in P, pp in P :  p != pp} :
#    lx[p,pp] <= xp[pp] + lenX[pp]- xp[p] + LUB[p,pp]*(1-supp[p,pp]);
  

# s.t. c141 {p in P, pp in P : p != pp }:
#    wy[p,pp] <= yp[p] + widY[p]- yp[pp] +  WUB[p,pp]*(1-supp[p,pp]);

# s.t. c142 {p in P, pp in P :  p != pp} :
#    wy[p,pp] <= yp[pp] + widY[pp]- yp[p] +  WUB[p,pp]*(1-supp[p,pp]);

# s.t. LUB_def {p in P, pp in P:  p != pp} :
#     LUB[p,pp] <= lenX[p];
    
# s.t. LUB_def2 {p in P, pp in P:  p != pp}:
#     LUB[p,pp] <= lenX[pp];

# # same for Y
# s.t. WUB_def {p in P, pp in P:  p != pp}:
#     WUB[p,pp] <= widY[p];
    
# s.t. WUB_def2 {p in P, pp in P: p != pp}:
#     WUB[p,pp] <= widY[pp];
    
# s.t. c182 {p in P, pp in P :  p != pp} :
#   lx[p,pp] <= LUB[p,pp]*supp[p,pp];

# s.t. c154 {p in P, pp in P :  p != pp} :
#    wy[p,pp] <=  WUB[p,pp]*supp[p,pp];
    
# # McCormick relax (use global Lmax/Wmax)   
# s.t. c156 {p in P, pp in P :  p != pp} :
#  Zarea[p,pp] <= LUB[p,pp]*wy[p,pp];

# s.t. c157 {p in P, pp in P :  p != pp} :
#  Zarea[p,pp] <= WUB[p,pp]* lx[p,pp];

# s.t. c158 {p in P, pp in P :  p != pp} :
#  Zarea[p,pp]>=LUB[p,pp]*wy[p,pp] + WUB[p,pp]* lx[p,pp] -LUB[p,pp]* WUB[p,pp];

# s.t. c170 {p in P, pp in P :  p != pp} :
# Zarea[p,pp] <= LUB[p,pp]* WUB[p,pp]*supp[p,pp];

# s.t. c159 {pp in P} :
# sum {p in P:p != pp} Zarea[p,pp] >= alpha_supp*(lenX[pp])*(widY[p])*(1-on_floor[pp]) ;


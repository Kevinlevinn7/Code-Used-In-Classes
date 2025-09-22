set W; # widths
set P; # patterns

param order {W} > 0;  # order for each width
param a {W,P} >= 0;  # number of rolls of width w in pattern p  
param width_roll >= 0;

var Make {P} >= 0; 

minimize Total_Number: sum {p in P} Make[p];

subject to Order {w in W}:
   sum {p in P} a[w,p] * Make[p] >= order[w];

subject to Width {p in P}:
   sum {w in W} a[w,p] * w <= width_roll;
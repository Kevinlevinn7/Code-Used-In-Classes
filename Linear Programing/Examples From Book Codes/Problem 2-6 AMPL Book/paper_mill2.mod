set W; # widths
set P; # patterns

param order {W} > 0;  # order for each width
param a {W,P} >= 0;  # number of rolls of width w in pattern p  

var Make {P} >= 0; 

minimize Total_Number: sum {p in P} Make[p];

subject to Order_Lower {w in W}:
   sum {p in P} a[w,p] * Make[p] >= 0.9 * order[w];

subject to Order_Upper {w in W}:
   sum {p in P} a[w,p] * Make[p] <= 1.4 * order[w];

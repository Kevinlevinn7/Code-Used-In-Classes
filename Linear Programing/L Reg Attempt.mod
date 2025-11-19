#With these being so general I don't know how we could truly tranlsate the data without creating lots of sets

set I;                     # observations i = 1..n
set J;                     # coefficients j


#these I am still unsure how they would work with real data but its a start


param y{i in I};           # response
param x{i in I, j in J};   # regressors x_ij
param t;                   # L1 budget

#since orignally not in standard format for ampl we have to translate into the poistive and engative side
var bplus{j in J}  >= 0;   # b_j^+ 
var bminus{j in J} >= 0;   # b_j^-

# same as: max -sum_i ( ... )^2
# minimizing the sum squared error 
minimize SSE:
    sum {i in I}
        sqr( y[i] - sum {j in J} (bplus[j] - bminus[j]) * x[i,j] );

subject to L1_budget:
    sum {j in J} (bplus[j] + bminus[j]) <= t;

param T > 0 integer;
set TIME := 1..T ordered;

param demand     {TIME} >= 0;
param buy_cost   {TIME} >= 0;
param fast_cost           >= 0;
param slow_cost           >= 0;
param init_clean         >= 0;

minimize Total_Cost;

node Clean {t in TIME};
node Used  {t in TIME}; 
node Dump: net_in >= 0 ;
node Store: net_out >=0;

arc Init >= init_clean, <= init_clean, from Store, to Clean[1];

arc Buy {t in TIME} >= 0,
    from Store, to Clean[t], obj Total_Cost buy_cost[t];

arc Carry {t in TIME: t < T} >= 0,
    from Clean[t], to Clean[t+1];

arc Use {t in TIME} >= demand[t],
    from Clean[t], to Used[t];

arc Wash2 {t in TIME: t <= T-2} >= 0,
    from Used[t], to Clean[t+2], obj Total_Cost fast_cost;
    
arc Wash4 {t in TIME: t <= T-4} >= 0,
    from Used[t], to Clean[t+4], obj Total_Cost slow_cost;

arc Trash {t in TIME} >= 0,
    from Used[t], to Dump;

from amplpy import AMPL
import pandas as pd

def solve_ampl_model(model_file, data_file, solver='gurobi', maximize='Profit', reheat_hours=None):
    ampl = AMPL()
    
    # Load model and data
    ampl.eval(f"model '{model_file}';")
    ampl.eval(f"data '{data_file}';")
    
    # Update reheat hours if specified
    if reheat_hours is not None:
        ampl.eval(f'let avail["reheat"] := {reheat_hours};')
    
    # Set solver
    ampl.eval(f"option solver {solver};")
    
    # Solve model
    ampl.solve()
    
    # Print objective value
    total_obj = ampl.get_objective(f"Total_{maximize}")
    print(f"Total {maximize}: {total_obj.value()}")
    
    # Print variable values
    make = ampl.get_variable('Make')
    make_df = make.get_values().to_pandas()
    
    print("\nProduction plan (tons per product):")
    for product, value in make_df['Make.val'].items():
        print(f"{product}: {value} tons")
    
    print("\nProduction plan as table:")
    print(make_df)
    return ampl

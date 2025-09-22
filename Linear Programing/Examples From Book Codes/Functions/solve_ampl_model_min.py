from amplpy import AMPL
import pandas as pd
import os

def solve_ampl_model_min(model_file, data_file, solver='gurobi', minimize='Profit', base_path=None):
    ampl = AMPL()  
    if base_path is not None:
        model_file = os.path.join(base_path, model_file)
        data_file = os.path.join(base_path, data_file)
    
    # Load model and data
    ampl.eval(f"model '{model_file}';")
    ampl.eval(f"data '{data_file}';")
    
    # Set solver
    ampl.eval(f"option solver {solver};")
    
    # Solve model
    ampl.solve()
    
    # Print objective value
    total_obj = ampl.get_objective(f"Total_{minimize}")
    print(f"Total {minimize}: {total_obj.value()}")
    
    # Print variable values
    make = ampl.get_variable('Make')
    make_df = make.get_values().to_pandas()

    print("\nProduction plan:")
    print(make_df)
    return ampl
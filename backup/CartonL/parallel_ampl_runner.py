import multiprocessing as mp
import os
import secrets
import subprocess
from typing import List, Tuple
import re
import glob

# --- Required Imports (Assuming these are defined in box.py and text_utils.py) ---
# NOTE: You must ensure box.py and text_utils.py are accessible and imported correctly.
from box import Box, Carton, get_cartons, get_products 
import plotly.graph_objects as go 

# --- Visualization Function (No changes) ---

def visualize(carton: Carton, products: List[Box], output_dir: str):
    """Save a 3D visualization of a carton and its products into an output folder."""
    if len(carton.products) == 0:
        return
    os.makedirs(output_dir, exist_ok=True)
    fig = go.Figure()

    # --- Draw carton (transparent wireframe) ---
    lx, wy, hz = carton.dim
    carton_edges = [
        ([0, lx, lx, 0, 0], [0, 0, wy, wy, 0], [0, 0, 0, 0, 0]),
        ([0, lx, lx, 0, 0], [0, 0, wy, wy, 0], [hz, hz, hz, hz, hz]),
        ([0, 0], [0, 0], [0, hz]),
        ([lx, lx], [0, 0], [0, hz]),
        ([lx, lx], [wy, wy], [0, hz]),
        ([0, 0], [wy, wy], [0, hz])
    ]
    for x, y, z in carton_edges:
        fig.add_trace(go.Scatter3d(
            x=x, y=y, z=z, mode='lines',
            line=dict(color='black', width=4),
            name=f'Carton {carton.idx}', showlegend=False
        ))

    # --- Draw each product box ---
    for pi in carton.products:
        if pi < len(products):
            prod = products[pi]
            x0, y0, z0 = prod.pos
            lx, wy, hz = prod.dim
            if prod.is_rotated:
                lx, wy = wy, lx

            fig.add_trace(go.Mesh3d(
                x=[x0, x0+lx, x0+lx, x0, x0, x0+lx, x0+lx, x0],
                y=[y0, y0, y0+wy, y0+wy, y0, y0, y0+wy, y0+wy],
                z=[z0, z0, z0, z0, z0+hz, z0+hz, z0+hz, z0+hz],
                i=[0, 0, 0, 1, 1, 2, 2, 3, 4, 4, 5, 6],
                j=[1, 2, 3, 2, 5, 3, 6, 0, 5, 6, 6, 7],
                k=[2, 3, 0, 5, 2, 6, 7, 4, 6, 7, 7, 4],
                color='rgba(0, 100, 250, 0.3)',
                opacity=0.6,
                name=f'Product {prod.idx}', showlegend=False
            ))

    # --- Layout ---
    fig.update_layout(
        scene=dict(
            xaxis_title='Length', yaxis_title='Width', zaxis_title='Height',
            aspectmode='data'
        ),
        title=f"Carton {carton.idx} Visualization",
        showlegend=False
    )

    # Save figure
    output_path = os.path.join(output_dir, f"carton_{carton.idx}.png")
    fig.write_image(output_path, scale=2, width=800, height=600)
    print(f"✅ Saved: {output_path}")


def visualize_packing(log_path: str, output_dir: str):
    """Read a log file and trigger multiprocessing visualization."""
    try:
        with open(log_path, "r") as f:
            text = f.read()
    except FileNotFoundError:
        print(f"⚠️ Log file not found: {log_path}. Skipping visualization.")
        return

    # --- ADD TRY-EXCEPT BLOCK HERE ---
    try:
        # NOTE: Assuming get_products and get_cartons from box.py are imported
        products = get_products(text)
        cartons = get_cartons(text)
    except Exception as e:
        print(f"❌ Error parsing AMPL log ({log_path}) in get_products/get_cartons: {e}. Skipping visualization.")
        # This will prevent the "list index out of range" from bubbling up and failing the entire instance
        return 
    # --- END OF TRY-EXCEPT BLOCK ---

    packed_cartons = [carton for carton in cartons if len(carton.products) > 0]
    if not packed_cartons:
        print(f"No products packed according to {log_path}. Skipping visualization.")
        return

    args = [(carton, products, output_dir) for carton in packed_cartons]
    print(f"🖼️ Starting parallel visualization for {len(packed_cartons)} cartons from {log_path}...")
    with mp.Pool(4) as p:
        p.starmap(visualize, args)


# --- Core Function for Parallel Execution (FIXED) ---

def process_instance(data_file: str, base_dir: str = "results") -> Tuple[str, str]:
    """
    Runs a single instance of the AMPL solver using the specified data file.
    
    FIX: Uses Python's stdout= argument to handle output redirection, avoiding the 
    'can't open' error caused by the shell=True redirection syntax.
    """
    instance_name = os.path.splitext(data_file)[0]
    print(f"🚀 Starting instance: {instance_name} with data file {data_file}...")
    
    # 1. Create unique file names for this instance
    suffix = secrets.token_bytes(4).hex()
    # Note: Using .run.tmp to make it clear this is a temporary file
    run_filename = f"run_{instance_name}_{suffix}.run.tmp" 
    log_filename = f"log_{instance_name}_{suffix}.log"
    output_dir = os.path.join(base_dir, f"figures_{instance_name}_{suffix}")
    
    # 2. Generate the specific .run file from the template
    template_file = "CartonL.template.run"
    try:
        with open(template_file, "r") as f:
            template = f.read()
        
        # Replace the placeholder (must be '$DATA_FILE$' in the template)
        # NOTE: If your template file is 'CartonL.run.template', change 'CartonL.template.run' above.
        run_content = template.replace("$DATA_FILE$", data_file)
        
        with open(run_filename, "w") as f:
            f.write(run_content)
        
    except FileNotFoundError:
        return (instance_name, f"Failure: Missing template file '{template_file}'")
    
    # 3. Prepare AMPL command (NO shell redirection here)
    cmd_args = [
        "ampl",
        run_filename 
    ]
    
    # 4. Execute AMPL (Using Python for output redirection)
    try:
        # Open the log file for writing the output
        with open(log_filename, "w") as log_file:
            # Run subprocess without shell=True, and direct stdout to the log file
            subprocess.run(
                cmd_args, 
                check=True,  # This ensures CalledProcessError is raised on failure
                cwd=os.getcwd(), 
                stdout=log_file,       # Redirect standard output (AMPL results/log)
                stderr=subprocess.STDOUT # Also capture errors in the same log file
            ) 
        
        print(f"✅ Instance {instance_name}: AMPL run complete. Log saved to {log_filename}")
        
        # 5. Visualize the results for this instance
        visualize_packing(log_filename, output_dir)
        
        return (instance_name, f"Success. Figures saved to: {output_dir}")
        
    except subprocess.CalledProcessError as e:
        error_msg = f"❌ Instance {instance_name}: AMPL failed with exit code {e.returncode}"
        print(error_msg)
        return (instance_name, f"Failure: AMPL exit code {e.returncode}. Log retained: {log_filename}")
        
    except Exception as e:
        error_msg = f"❌ Instance {instance_name}: An unexpected error occurred: {e}"
        print(error_msg)
        return (instance_name, f"Failure: Unexpected error {e}. Log retained: {log_filename}")
    
    finally:
        # Clean up the temporary .run file unconditionally
        if os.path.exists(run_filename):
            os.remove(run_filename)
        # NOTE: We keep the log file on failure to allow debugging.
        # If the run was successful, the log file is cleaned up by visualize_packing's success path (though 
        # the current script structure does NOT automatically clean up successful logs.
        # For simplicity, we will manually clean up successful logs later if needed, but keep failures.)

 #--- Result Aggregation Function ---
def aggregate_results(base_dir: str = "."):
    """
    Reads all log files in the results directory, extracts the product-to-carton 
    assignment data, and saves it to a single summary CSV file. Also extracts
    and prints the static carton parameters (LB, WB, HB).
    """
    all_assignments = []
    carton_params = {}
    
    # 1. Glob all log files created by the runner
    log_files = glob.glob(os.path.join(base_dir, "log_*.log"))
    
    if not log_files:
        print("\n⚠️ No log files found in the results directory. Skipping aggregation.")
        return

    print(f"\n📂 Aggregating data from {len(log_files)} log files...")

    for log_path in log_files:
        try:
            with open(log_path, 'r') as f:
                content = f.read()
            
            # 1. Extract Instance Name (e.g., shipment_164316)
            instance_name_match = re.search(r'log_(shipment_\d+)_', os.path.basename(log_path))
            instance_name = instance_name_match.group(1) if instance_name_match else "UNKNOWN_INSTANCE"

            # 2. Extract Product Assignments (x[p,b])
            assignment_match = re.search(r'product ->carton: begin\n(.*?)product ->carton: end', content, re.DOTALL)
            if assignment_match:
                assignments_block = assignment_match.group(1).strip().split('\n')
                for line in assignments_block:
                    # Expected format: "p (1) -> b"
                    m = re.match(r'(\d+)\s+\(1\)\s+->\s+(\d+)', line.strip())
                    if m:
                        product_id = int(m.group(1))
                        carton_id = int(m.group(2))
                        all_assignments.append((instance_name, product_id, carton_id))
            
            # 3. Extract Carton Dimensions (LB, WB, HB) from the first log found
            if not carton_params:
                carton_dim_match = re.search(r'LB, WB, HB: begin\n(.*?)LB, WB, HB: end', content, re.DOTALL)
                if carton_dim_match:
                    dim_block = carton_dim_match.group(1).strip().split('\n')
                    for line in dim_block:
                        m = re.match(r'(\d+): (\S+) (\S+) (\S+)', line.strip())
                        if m:
                            b_id = int(m.group(1))
                            LB = float(m.group(2))
                            WB = float(m.group(3))
                            HB = float(m.group(4))
                            # Alpha is an input parameter, marked as N/A unless printed in .run file
                            carton_params[b_id] = {'LB': LB, 'WB': WB, 'HB': HB, 'alpha': 'N/A (Input)'}

        except Exception as e:
            print(f"Error processing log file {log_path}: {e}")
            continue

    # --- Save Aggregated Assignments to CSV ---
    assignment_output_file = "aggregated_assignments.csv"
    full_output_path = os.path.join(base_dir, assignment_output_file)

    try:
        with open(full_output_path, 'w') as csvfile:
            csvfile.write("Instance,Product_ID,Assigned_Carton_ID\n")
            for inst, p_id, c_id in all_assignments:
                csvfile.write(f"{inst},{p_id},{c_id}\n")
        print(f"\n✅ Aggregated product assignments saved to: {full_output_path}")
    except Exception as e:
        print(f"Error writing assignment CSV: {e}")

    # --- Print Carton Parameters (LB, WB, HB, alpha) ---
    print("\n--- 3. Carton Parameters (Extracted from Solution Output) ---")
    if carton_params:
        sorted_cartons = sorted(carton_params.items())
        
        print("{:<10} | {:<10} | {:<10} | {:<10} | {:<15}".format("Carton_ID", "LB", "WB", "HB", "Alpha"))
        print("-" * 68)
        
        for b_id, dims in sorted_cartons:
            print("{:<10} | {:<10.2f} | {:<10.2f} | {:<10.2f} | {:<15}".format(
                b_id, dims['LB'], dims['WB'], dims['HB'], dims['alpha']
            ))
    else:
        print("Carton parameters (LB, WB, HB) could not be extracted from any log.")

# If you need to extract 'alpha' specifically, you must modify CartonL.template.run
# to print 'alpha[b]' for all 'b in B'.

# --- Main Parallel Runner ---

def run_all_shipments():
    """
    Runs all predefined shipment files in parallel.
    """
    # List of all your data files
    data_files = [
        "shipment_112852.dat",
        "shipment_112890.dat", # Include all files you want to run
        "shipment_112947.dat",
        "shipment_144195.dat",
        "shipment_145555.dat",
        "shipment_157376.dat",
        "shipment_160515.dat",
        "shipment_160558.dat",
        "shipment_160630.dat",
        "shipment_163822.dat",
        "shipment_164145.dat",
        "shipment_164316.dat",
        "shipment_169688.dat",
        "shipment_179278.dat",
    ]
    
    num_instances = len(data_files)
    print(f"Starting {num_instances} parallel AMPL solver instances...")
    
    base_dir = "results"
    os.makedirs(base_dir, exist_ok=True)
    
    args = [(f, base_dir) for f in data_files]
    
    # Run all instances in parallel
    with mp.Pool(min(num_instances, os.cpu_count())) as p:
        results = p.starmap(process_instance, args)
        
    print("\n--- ✅ Final Parallel Run Summary ---")
    for instance, status in results:
        print(f"[{instance}]: {status}")

if __name__ == "__main__":
    run_all_shipments()


# ----------------------------------------------------
# --- Main Execution Block (Modified) ---
# ----------------------------------------------------
if __name__ == "__main__":
    run_all_shipments()
    
    # --- 2. ADD THE CALL HERE ---
    aggregate_results()
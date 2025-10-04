import re
import subprocess
from typing import List

import plotly.graph_objects as go

from box import Box, Carton, get_cartons, get_products


def visualize(carton: Carton, products: List[Box]):
    """Visualize a carton and the products inside it in 3D."""
    # Skip empty cartons
    if len(carton.products)==0:
        return

    fig = go.Figure()

    # --- Draw carton (transparent wireframe) ---
    lx, wy, hz = carton.dim
    carton_edges = [
        # Bottom square
        ([0, lx, lx, 0, 0], [0, 0, wy, wy, 0], [0, 0, 0, 0, 0]),
        # Top square
        ([0, lx, lx, 0, 0], [0, 0, wy, wy, 0], [hz, hz, hz, hz, hz]),
        # Vertical edges
        ([0, 0], [0, 0], [0, hz]),
        ([lx, lx], [0, 0], [0, hz]),
        ([lx, lx], [wy, wy], [0, hz]),
        ([0, 0], [wy, wy], [0, hz])
    ]
    for x, y, z in carton_edges:
        fig.add_trace(go.Scatter3d(
            x=x, y=y, z=z, mode='lines',
            line=dict(color='black', width=4),
            name=f'Carton {carton.idx}'
        ))

    # --- Draw each product box ---
    for pi in carton.products:
        prod = products[pi]
        # You can set prod.x, prod.y, prod.z externally if you want placement control
        x0, y0, z0 = prod.pos
        lx, wy, hz = prod.dim
        if prod.is_rotated:
            lx, wy = prod.dim[1], prod.dim[0]

        fig.add_trace(go.Mesh3d(
            x=[x0, x0+lx, x0+lx, x0, x0, x0+lx, x0+lx, x0],
            y=[y0, y0, y0+wy, y0+wy, y0, y0, y0+wy, y0+wy],
            z=[z0, z0, z0, z0, z0+hz, z0+hz, z0+hz, z0+hz],
            i=[0, 0, 0, 1, 1, 2, 2, 3, 4, 4, 5, 6],
            j=[1, 2, 3, 2, 5, 3, 6, 0, 5, 6, 6, 7],
            k=[2, 3, 0, 5, 2, 6, 7, 4, 6, 7, 7, 4],
            color='rgba(0, 100, 250, 0.3)',
            opacity=0.6,
            name=f'Product {prod.idx}'
        ))

    # --- Layout ---
    fig.update_layout(
        scene=dict(
            xaxis_title='Length',
            yaxis_title='Width',
            zaxis_title='Height',
            aspectmode='data'
        ),
        title=f"Carton {carton.idx} Visualization",
        showlegend=False
    )

    fig.show()

def visualize_packing():
    text: str
    with open("log.txt", "r") as f:
        text = f.read()
    products = get_products(text)
    cartons = get_cartons(text)

    for carton in cartons:
        visualize(carton, products)




def run():
    cmd_args = [
        "ampl",
        "CLPSingle(container).run"
    ]
    try:
        subprocess.run(cmd_args)
    except subprocess.CalledProcessError as e:
        print(f"⚠️ failed with exit code {e.returncode}")    
    visualize_packing()

if __name__ == "__main__":
    run()

    
import re
from typing import List


def extract_product_dims_block(text:str)->List:
    block_pattern = r'lp, wp, hp: begin(.*?)lp, wp, hp: end'
    content = re.findall(block_pattern, text, flags=re.S)[0]
    
    # Extract all "id: a b c"
    entries = re.findall(r'(\d+):\s+(\d+[\.\d+]?)\s+(\d+[\.\d+]?)\s+(\d+[\.\d+]?)', content)
    data = [[int(a), float(b), float(c), float(d)] for a, b, c, d in entries]
    return data

def extract_rotation_block(text:str)->dict[int, bool]:
    block_pattern = r'l_px, l_py, w_px, w_py: begin(.*?)l_px, l_py, w_px, w_py: end'
    content = re.findall(block_pattern, text, flags=re.S)[0]
    
    # Extract all "id: a b c"
    entries = re.findall(r'(\d+):\s+(\d)\s+(\d)\s+(\d)\s+(\d)', content)
    data = {int(a): bool(int(c)) for a, b, c, d, e in entries}
    # data = [[int(a), int(b), int(c), int(d), int (e)] for a, b, c, d, e in entries]
    return data

def extract_position_block(text:str)->dict[int, List[float]]:
    block_pattern = r'(xp, yp, zp, on_floor): begin(.*?)\1: end'
    content = re.findall(block_pattern, text, flags=re.S)[0][1]
    entries = re.findall(r'(\d+):\s+([\d\.Ee+-]+)\s+([\d\.Ee+-]+)\s+([\d\.Ee+-]+)\s+([\d\.Ee+-]+)', content)
    data = {int(a): [float(b), float(c), float(d)] for a, b, c, d, e in entries}
    return data

def extract_carton_dims(text:str)->List:
    block_pattern = r'LB, WB, HB: begin(.*?)LB, WB, HB: end'
    content = re.findall(block_pattern, text, flags=re.S)[0]
    
    # Extract all "id: a b c"
    entries = re.findall(r'(\d+):\s+(\d+[\.\d+]?)\s+(\d+[\.\d+]?)\s+(\d+[\.\d+]?)', content)
    data = [[int(a), float(b), float(c), float(d)] for a, b, c, d in entries]
    return data

def extract_product_carton_map(text:str)->dict[int, int]:
    block_pattern = r'product \(family\)->carton: begin(.*?)product \(family\)->carton: end'
    content = re.findall(block_pattern, text, flags=re.S)[0]
    
    # Extract all "id: a b c"
    entries = re.findall(r'(\d+) \(\d+\) -> (\d+)', content)
    data = {int(a):int(b) for a, b in entries}
    return data


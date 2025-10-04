from typing import List

from text_utils import *


class Box:
    def __init__(self, 
                 idx:int=0, 
                 length:float=0, 
                 width:float=0, 
                 height:float=0, 
                 is_rotated:bool=False):
        self.idx: int = idx
        self.dim: List[float] = [length, width, height]
        self.pos: List[float] = [-1., -1., -1.]
        self.is_rotated: bool = is_rotated

    def set_pos(self, x: float, y:float, z:float):
        self.pos = [x,y,z]

class Carton(Box):
    def __init__(self, idx = 0, length = 0, width = 0, height = 0, is_rotated = False):
        super().__init__(idx, length, width, height, is_rotated)
        self.products: List[int] = []       

        
def set_products_rotation(text:str, products:List[Box]):
    rotation_info = extract_rotation_block(text)
    for pi, product in enumerate(products):
        if pi == 0:
            continue
        products[pi].is_rotated = rotation_info[product.idx]

def set_products_position(text:str, products:List[Box]):
    position_info = extract_position_block(text)
    for pi, product in enumerate(products):
        if pi == 0:
            continue
        products[pi].set_pos(*position_info[pi])

def get_products(text: str)->List[Box]:
    products: List[Box] = [Box()]
    products_dim_block = extract_product_dims_block(text)
    for arr in products_dim_block:
        products.append(Box(arr[0],arr[1],arr[2],arr[3], False))
    set_products_rotation(text, products)
    set_products_position(text, products)

    return products


def get_cartons(text:str)->List[Carton]:
    carton_dims = extract_carton_dims(text)
    cartons: List[Carton] = [Carton()]
    for c in carton_dims:
        cartons.append(Carton(c[0], c[1], c[2], c[3]))
    product_carton_map = extract_product_carton_map(text)
    for pi, ci in product_carton_map.items():
        cartons[ci].products.append(pi)
    return cartons
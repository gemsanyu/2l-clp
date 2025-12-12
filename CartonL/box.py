from typing import List

from text_utils import *


class Box:
    def __init__(self, 
                 idx: int = 0, 
                 length: float = 0, 
                 width: float = 0, 
                 height: float = 0, 
                 is_rotated: bool = False):
        self.idx: int = idx
        self.dim: List[float] = [length, width, height]
        self.pos: List[float] = [-1., -1., -1.]
        self.is_rotated: bool = is_rotated

    def set_pos(self, x: float, y: float, z: float):
        self.pos = [x, y, z]

    def __repr__(self):
        return f"Box(idx={self.idx}, dim={self.dim}, pos={self.pos}, rotated={self.is_rotated})"

    def __getstate__(self):
        return self.__dict__

    def __setstate__(self, state):
        self.__dict__.update(state)


class Carton(Box):
    def __init__(self, idx=0, length=0, width=0, height=0, is_rotated=False):
        super().__init__(idx, length, width, height, is_rotated)
        self.products: List[int] = []

    def __repr__(self):
        return f"Carton(idx={self.idx}, dim={self.dim}, n_products={len(self.products)})"

        
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


if __name__ == "__main__":
    import pickle

    b = Box(1, 2, 3, 4)
    c = Carton(10, 5, 5, 5)
    c.products = [1, 2, 3]

    pickle.dumps(b)
    pickle.dumps(c)
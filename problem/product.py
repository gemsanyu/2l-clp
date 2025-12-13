from dataclasses import dataclass
from typing import Dict, List


@dataclass
class Product:
    code:str
    weight:float
    length:float
    width:float
    height:float


def create_product_map(products: List[Product])->Dict[str, Product]:
    product_map:Dict[str, Product] = {product.code: product for product in products}
    return product_map

def create_product_code_map(products: List[Product])->Dict[str, int]:
    product_code_map:Dict[str, int] = {product.code: i for i, product in enumerate(products)}
    return product_code_map
from dataclasses import dataclass
from typing import List


@dataclass
class Order:
    product_code: str
    qty: int

@dataclass
class Customer:
    cust_id:str
    orders:List[Order]
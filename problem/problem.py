from typing import List, Set
from pathlib import Path

from problem.customer import Customer, Order
from problem.product import (Product, create_product_code_map,
                             create_product_map)


class Problem:
    def __init__(self,
                 customers: List[Customer],
                 products: List[Product]):
        self.customers = customers
        self.products = products
        self.product_code_map = create_product_code_map(products)
        self.product_map = create_product_map(products)

    # def generate_full_dat(self):


    def generate_per_customer_dats(self, write_dir: Path):
        
        for customer in self.customers:





def from_json(json_data: dict)->Problem:
    product_code_set: Set[str] = set()
    products: List[Product] = []
    customers: List[Customer] = []
    for cust_id, order_details_list in json_data.items():
        orders: List[Order] = []
        for order_details in order_details_list:
            orders.append(Order(order_details["product_code"], order_details["shipped_qty"]))
            if order_details["product_code"] not in product_code_set:
                new_product = Product(
                    order_details["product_code"],
                    order_details["product_weight"],
                    order_details["product_length"],
                    order_details["product_width"],
                    order_details["product_height"])
                product_code_set.add(new_product.code)
                products.append(new_product)
        customers.append(Customer(cust_id, orders))
    return Problem(customers, products)
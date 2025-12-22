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
        self.base_box_data = [
            (1, 28,   15,   15,   6300,   32),
            (2, 42,   32,   26,   34944,  94),
            (3, 45.7, 45.7, 40.6, 84793,  156),
            (4, 61,   46,   61,   171166, 469)
        ]


    # def generate_full_dat(self):


    def generate_per_customer_dats(self, write_dir: Path):
        for customer in self.customers:
            self.generate_customer_dat(customer, write_dir)
    
    def generate_customer_dat(self, customer:Customer, write_dir: Path):
        cust_products: List[Product] = []
        for order in customer.orders:
            cust_products += [self.product_map[order.product_code] for _ in range(order.qty)]
        
        texts = []
        texts += ["set P :=\n"]
        prod_idxs = list(range(1, len(cust_products)+1))
        prod_idxs_str = [str(i) for i in prod_idxs]
        texts += [" ".join(prod_idxs_str) + "\n"]
        texts += [";\n"]
        
        texts += ["param:\tWG\tlp\twp\thp\t:=\n"]
        for i, product in enumerate(cust_products):
            wg = product.weight
            lp = product.length
            wp = product.width
            hp = product.height
            texts += [f"{i+1}\t{wg}\t{lp}\t{wp}\t{hp}\n"]
        texts += [";\n"]
        
    
        num_box_duplicate = 20
        boxes = [bbox for i in range(num_box_duplicate) for bbox in self.base_box_data]     
        texts += ["set\tB\t:=\n"]
        box_idxs = list(range(1, len(boxes)+1))
        box_idxs_str = [str(i) for i in box_idxs]
        texts += [" ".join(box_idxs_str) + "\n"]
        texts += [";\n"]
        
        texts += ["param:\tLB\tWB\tHB\tCB\talpha\t:=\n"]
        for i, box in enumerate(boxes):
            lb = box[1]
            wb = box[2]
            hb = box[3]
            cb = box[4]
            alpha = box[5]
            texts += [f"{i+1}\t{lb}\t{wb}\t{hb}\t{cb}\t{alpha}\t\n"]
        texts += [";\n"] 
        # texts += ["param\tM\t:= 1000000;\n"]
        texts += ["param\talpha_supp\t:= 1;\n"]
        
        filename = f"{customer.cust_id}.dat"
        filepath = write_dir/filename
        with open(filepath, "w") as f:
            f.writelines(texts)

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
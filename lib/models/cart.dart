class Cart {
  String? cartid;
  String? subname;
  String? price;
  String? cartqty;
  String? subid;
  String? pricetotal;

  Cart(
      {this.cartid,
      this.subname,
      this.price,
      this.cartqty,
      this.subid,
      this.pricetotal});

  Cart.fromJson(Map<String, dynamic> json) {
    cartid = json['cart_id'];
    subname = json['subject_name'];
    price = json['price'];
    cartqty = json['cart_qty'];
    subid = json['subject_id'];
    pricetotal = json['pricetotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartid;
    data['subject_name'] = subname;
    data['price'] = price;
    data['cart_qty'] = cartqty;
    data['subject_id'] = subid;
    data['pricetotal'] = pricetotal;
    return data;
  }
}
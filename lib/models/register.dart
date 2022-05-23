class Register {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? ads;
  String? password;

  Register(
      {this.id, this.name, this.phone, this.email, this.ads, this.password});

  Register.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    ads = json['ads'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['ads'] = ads;
    data['password'] = password;
    return data;
  }
}
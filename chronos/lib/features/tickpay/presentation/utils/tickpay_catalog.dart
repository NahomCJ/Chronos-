/// Comprehensive product catalog for TickPay Discover.
/// Categories: electronics, fashion, home, sports, beauty, gaming, travel, food, health, toys, music, auto, books, pets
library;

class TProduct {
  final String name, price, imageUrl, category, brand, bnpl;
  final double priceNum, discount;
  const TProduct({
    required this.name,
    required this.price,
    required this.priceNum,
    required this.imageUrl,
    required this.category,
    required this.brand,
    this.bnpl = '',
    this.discount = 0,
  });
}

// Pexels image URLs — all pre-validated
const String _e1  = 'https://images.pexels.com/photos/19060954/pexels-photo-19060954.jpeg?auto=compress&cs=tinysrgb&w=600'; // iPhone 15 Pro
const String _e2  = 'https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg?auto=compress&cs=tinysrgb&w=600'; // headphones black
const String _e3  = 'https://images.pexels.com/photos/437038/pexels-photo-437038.jpeg?auto=compress&cs=tinysrgb&w=600'; // apple watch
const String _e4  = 'https://images.pexels.com/photos/205421/pexels-photo-205421.jpeg?auto=compress&cs=tinysrgb&w=600'; // macbook
const String _e5  = 'https://images.pexels.com/photos/1334597/pexels-photo-1334597.jpeg?auto=compress&cs=tinysrgb&w=600'; // ipad
const String _e6  = 'https://images.pexels.com/photos/5081398/pexels-photo-5081398.jpeg?auto=compress&cs=tinysrgb&w=600'; // earbuds
const String _e7  = 'https://images.pexels.com/photos/475773/pexels-photo-475773.jpeg?auto=compress&cs=tinysrgb&w=600'; // smartwatch
const String _e8  = 'https://images.pexels.com/photos/1706694/pexels-photo-1706694.jpeg?auto=compress&cs=tinysrgb&w=600'; // speaker
const String _e9  = 'https://images.pexels.com/photos/5054541/pexels-photo-5054541.jpeg?auto=compress&cs=tinysrgb&w=600'; // apple watch black
const String _e10 = 'https://images.pexels.com/photos/3394665/pexels-photo-3394665.jpeg?auto=compress&cs=tinysrgb&w=600'; // headphones white
const String _e11 = 'https://images.pexels.com/photos/5437583/pexels-photo-5437583.jpeg?auto=compress&cs=tinysrgb&w=600'; // smartphone

const String _f1  = 'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&cs=tinysrgb&w=600'; // dress
const String _f2  = 'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg?auto=compress&cs=tinysrgb&w=600'; // handbag
const String _f3  = 'https://images.pexels.com/photos/1225136/pexels-photo-1225136.jpeg?auto=compress&cs=tinysrgb&w=600'; // white sneakers
const String _f4  = 'https://images.pexels.com/photos/2529157/pexels-photo-2529157.jpeg?auto=compress&cs=tinysrgb&w=600'; // nike shoes
const String _f5  = 'https://images.pexels.com/photos/787593/pexels-photo-787593.jpeg?auto=compress&cs=tinysrgb&w=600'; // adidas shoes
const String _f6  = 'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&cs=tinysrgb&w=600'; // summer dress alt
const String _f7  = 'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg?auto=compress&cs=tinysrgb&w=600'; // bag alt

const String _h1  = 'https://images.pexels.com/photos/2080590/pexels-photo-2080590.jpeg?auto=compress&cs=tinysrgb&w=600'; // coffee maker
const String _h2  = 'https://images.pexels.com/photos/1112598/pexels-photo-1112598.jpeg?auto=compress&cs=tinysrgb&w=600'; // lamp
const String _h3  = 'https://images.pexels.com/photos/3822906/pexels-photo-3822906.jpeg?auto=compress&cs=tinysrgb&w=600'; // yoga mat

const String _s1  = 'https://images.pexels.com/photos/1280064/pexels-photo-1280064.jpeg?auto=compress&cs=tinysrgb&w=600'; // gym bag

const String _b1  = 'https://images.pexels.com/photos/965989/pexels-photo-965989.jpeg?auto=compress&cs=tinysrgb&w=600'; // perfume
const String _b2  = 'https://images.pexels.com/photos/3373736/pexels-photo-3373736.jpeg?auto=compress&cs=tinysrgb&w=600'; // skincare

const String _g1  = 'https://images.pexels.com/photos/3945683/pexels-photo-3945683.jpeg?auto=compress&cs=tinysrgb&w=600'; // controller

const List<TProduct> kAllProducts = [
  // ── Electronics ──────────────────────────────────────────────────────────
  TProduct(name: 'iPhone 15 Pro', price: '\$1,199', priceNum: 1199, imageUrl: _e1, category: 'electronics', brand: 'Apple', bnpl: '4 × \$299.75', discount: 0.05),
  TProduct(name: 'MacBook Air M3', price: '\$1,099', priceNum: 1099, imageUrl: _e4, category: 'electronics', brand: 'Apple', bnpl: '4 × \$274.75', discount: 0.08),
  TProduct(name: 'iPad Pro 12.9"', price: '\$799', priceNum: 799, imageUrl: _e5, category: 'electronics', brand: 'Apple', bnpl: '3 × \$266.33', discount: 0.10),
  TProduct(name: 'Apple Watch Ultra', price: '\$799', priceNum: 799, imageUrl: _e9, category: 'electronics', brand: 'Apple', bnpl: '3 × \$266.33', discount: 0.05),
  TProduct(name: 'AirPods Pro 2', price: '\$249', priceNum: 249, imageUrl: _e6, category: 'electronics', brand: 'Apple', bnpl: '2 × \$124.50', discount: 0.15),
  TProduct(name: 'Apple Watch Series 9', price: '\$399', priceNum: 399, imageUrl: _e3, category: 'electronics', brand: 'Apple', bnpl: '2 × \$199.50', discount: 0.10),
  TProduct(name: 'Sony WH-1000XM5', price: '\$349', priceNum: 349, imageUrl: _e2, category: 'electronics', brand: 'Sony', bnpl: '2 × \$174.50', discount: 0.20),
  TProduct(name: 'Samsung Galaxy Buds2 Pro', price: '\$179', priceNum: 179, imageUrl: _e6, category: 'electronics', brand: 'Samsung', bnpl: '2 × \$89.50', discount: 0.15),
  TProduct(name: 'JBL Charge 5', price: '\$149', priceNum: 149, imageUrl: _e8, category: 'electronics', brand: 'JBL', bnpl: '2 × \$74.50', discount: 0.10),
  TProduct(name: 'Bose QuietComfort 45', price: '\$279', priceNum: 279, imageUrl: _e10, category: 'electronics', brand: 'Bose', bnpl: '2 × \$139.50', discount: 0.18),
  TProduct(name: 'Samsung Galaxy S24', price: '\$999', priceNum: 999, imageUrl: _e11, category: 'electronics', brand: 'Samsung', bnpl: '4 × \$249.75', discount: 0.08),
  TProduct(name: 'Google Pixel 8', price: '\$699', priceNum: 699, imageUrl: _e11, category: 'electronics', brand: 'Google', bnpl: '3 × \$233', discount: 0.10),
  TProduct(name: 'Garmin Forerunner 265', price: '\$449', priceNum: 449, imageUrl: _e7, category: 'electronics', brand: 'Garmin', bnpl: '3 × \$149.67', discount: 0.10),
  TProduct(name: 'Fitbit Charge 6', price: '\$159', priceNum: 159, imageUrl: _e7, category: 'electronics', brand: 'Fitbit', bnpl: '2 × \$79.50', discount: 0.12),

  // ── Fashion ───────────────────────────────────────────────────────────────
  TProduct(name: 'Summer Floral Dress', price: '\$89', priceNum: 89, imageUrl: _f1, category: 'fashion', brand: 'Zara', bnpl: '2 × \$44.50', discount: 0.20),
  TProduct(name: 'Leather Tote Bag', price: '\$145', priceNum: 145, imageUrl: _f2, category: 'fashion', brand: 'Coach', bnpl: '2 × \$72.50', discount: 0.15),
  TProduct(name: 'Nike Air Max 270', price: '\$130', priceNum: 130, imageUrl: _f4, category: 'fashion', brand: 'Nike', bnpl: '2 × \$65', discount: 0.10),
  TProduct(name: 'Adidas Ultraboost 23', price: '\$180', priceNum: 180, imageUrl: _f5, category: 'fashion', brand: 'Adidas', bnpl: '2 × \$90', discount: 0.20),
  TProduct(name: 'White Platform Sneakers', price: '\$95', priceNum: 95, imageUrl: _f3, category: 'fashion', brand: 'Vans', bnpl: '2 × \$47.50', discount: 0.10),
  TProduct(name: 'Silk Blouse', price: '\$65', priceNum: 65, imageUrl: _f6, category: 'fashion', brand: 'H&M', bnpl: '2 × \$32.50', discount: 0.15),
  TProduct(name: 'Crossbody Handbag', price: '\$79', priceNum: 79, imageUrl: _f7, category: 'fashion', brand: 'Michael Kors', bnpl: '2 × \$39.50', discount: 0.12),
  TProduct(name: 'Nike Running Jacket', price: '\$115', priceNum: 115, imageUrl: _f4, category: 'fashion', brand: 'Nike', bnpl: '2 × \$57.50', discount: 0.08),
  TProduct(name: 'Adidas Track Pants', price: '\$65', priceNum: 65, imageUrl: _f5, category: 'fashion', brand: 'Adidas', bnpl: '2 × \$32.50', discount: 0.10),
  TProduct(name: 'Oversized Hoodie', price: '\$55', priceNum: 55, imageUrl: _f6, category: 'fashion', brand: 'Champion', bnpl: '2 × \$27.50', discount: 0.15),

  // ── Home ─────────────────────────────────────────────────────────────────
  TProduct(name: 'Nespresso Vertuo Pop', price: '\$89', priceNum: 89, imageUrl: _h1, category: 'home', brand: 'Nespresso', bnpl: '2 × \$44.50', discount: 0.20),
  TProduct(name: 'Philips Hue Starter Kit', price: '\$129', priceNum: 129, imageUrl: _h2, category: 'home', brand: 'Philips', bnpl: '2 × \$64.50', discount: 0.10),
  TProduct(name: 'Dyson V15 Vacuum', price: '\$749', priceNum: 749, imageUrl: _h1, category: 'home', brand: 'Dyson', bnpl: '3 × \$249.67', discount: 0.05),
  TProduct(name: 'Ninja Air Fryer XL', price: '\$119', priceNum: 119, imageUrl: _h1, category: 'home', brand: 'Ninja', bnpl: '2 × \$59.50', discount: 0.12),
  TProduct(name: 'Instant Pot Duo 7-in-1', price: '\$99', priceNum: 99, imageUrl: _h1, category: 'home', brand: 'Instant Pot', bnpl: '2 × \$49.50', discount: 0.15),
  TProduct(name: 'Floor Lamp Arc', price: '\$79', priceNum: 79, imageUrl: _h2, category: 'home', brand: 'IKEA', bnpl: '2 × \$39.50', discount: 0.10),
  TProduct(name: 'Yoga Mat Premium', price: '\$59', priceNum: 59, imageUrl: _h3, category: 'home', brand: 'Lululemon', bnpl: '2 × \$29.50', discount: 0.08),
  TProduct(name: 'Robot Vacuum iRobot', price: '\$299', priceNum: 299, imageUrl: _h1, category: 'home', brand: 'iRobot', bnpl: '3 × \$99.67', discount: 0.15),

  // ── Sports ───────────────────────────────────────────────────────────────
  TProduct(name: 'Nike Dri-FIT Shorts', price: '\$45', priceNum: 45, imageUrl: _f4, category: 'sports', brand: 'Nike', bnpl: '', discount: 0.10),
  TProduct(name: 'Adidas Sports Bag', price: '\$55', priceNum: 55, imageUrl: _s1, category: 'sports', brand: 'Adidas', bnpl: '2 × \$27.50', discount: 0.10),
  TProduct(name: 'Premium Yoga Mat', price: '\$35', priceNum: 35, imageUrl: _h3, category: 'sports', brand: 'Manduka', bnpl: '', discount: 0.15),
  TProduct(name: 'Fitbit Charge 6', price: '\$129', priceNum: 129, imageUrl: _e7, category: 'sports', brand: 'Fitbit', bnpl: '2 × \$64.50', discount: 0.10),
  TProduct(name: 'Under Armour Hoodie', price: '\$75', priceNum: 75, imageUrl: _f4, category: 'sports', brand: 'Under Armour', bnpl: '2 × \$37.50', discount: 0.12),
  TProduct(name: 'Resistance Bands Set', price: '\$29', priceNum: 29, imageUrl: _s1, category: 'sports', brand: 'ProForm', bnpl: '', discount: 0.20),
  TProduct(name: 'Running Shoes Gel', price: '\$120', priceNum: 120, imageUrl: _f5, category: 'sports', brand: 'ASICS', bnpl: '2 × \$60', discount: 0.15),
  TProduct(name: 'Hydro Flask 32oz', price: '\$44', priceNum: 44, imageUrl: _s1, category: 'sports', brand: 'Hydro Flask', bnpl: '', discount: 0.08),

  // ── Beauty ───────────────────────────────────────────────────────────────
  TProduct(name: 'Chanel No.5 EDP 100ml', price: '\$145', priceNum: 145, imageUrl: _b1, category: 'beauty', brand: 'Chanel', bnpl: '2 × \$72.50', discount: 0.10),
  TProduct(name: 'Dior Skincare Set', price: '\$189', priceNum: 189, imageUrl: _b2, category: 'beauty', brand: 'Dior', bnpl: '2 × \$94.50', discount: 0.12),
  TProduct(name: 'La Mer Moisturizer', price: '\$210', priceNum: 210, imageUrl: _b2, category: 'beauty', brand: 'La Mer', bnpl: '2 × \$105', discount: 0.08),
  TProduct(name: 'MAC Eyeshadow Palette', price: '\$65', priceNum: 65, imageUrl: _b2, category: 'beauty', brand: 'MAC', bnpl: '', discount: 0.15),
  TProduct(name: 'Dyson Airwrap', price: '\$599', priceNum: 599, imageUrl: _e2, category: 'beauty', brand: 'Dyson', bnpl: '3 × \$199.67', discount: 0.05),
  TProduct(name: 'Fenty Beauty Set', price: '\$89', priceNum: 89, imageUrl: _b1, category: 'beauty', brand: 'Fenty', bnpl: '2 × \$44.50', discount: 0.10),
  TProduct(name: 'Kiehl\'s Face Cream', price: '\$55', priceNum: 55, imageUrl: _b2, category: 'beauty', brand: "Kiehl's", bnpl: '', discount: 0.12),
  TProduct(name: 'Jo Malone Cologne 50ml', price: '\$135', priceNum: 135, imageUrl: _b1, category: 'beauty', brand: 'Jo Malone', bnpl: '2 × \$67.50', discount: 0.08),

  // ── Gaming ───────────────────────────────────────────────────────────────
  TProduct(name: 'PS5 DualSense Controller', price: '\$69', priceNum: 69, imageUrl: _g1, category: 'gaming', brand: 'Sony', bnpl: '2 × \$34.50', discount: 0.08),
  TProduct(name: 'Xbox Series X Controller', price: '\$59', priceNum: 59, imageUrl: _g1, category: 'gaming', brand: 'Microsoft', bnpl: '', discount: 0.10),
  TProduct(name: 'Razer BlackShark V2', price: '\$99', priceNum: 99, imageUrl: _e2, category: 'gaming', brand: 'Razer', bnpl: '2 × \$49.50', discount: 0.15),
  TProduct(name: 'Logitech G Pro Mouse', price: '\$79', priceNum: 79, imageUrl: _g1, category: 'gaming', brand: 'Logitech', bnpl: '2 × \$39.50', discount: 0.10),
  TProduct(name: 'SteelSeries Arctis 7', price: '\$149', priceNum: 149, imageUrl: _e2, category: 'gaming', brand: 'SteelSeries', bnpl: '2 × \$74.50', discount: 0.12),
  TProduct(name: 'Nintendo Switch OLED', price: '\$349', priceNum: 349, imageUrl: _g1, category: 'gaming', brand: 'Nintendo', bnpl: '3 × \$116.33', discount: 0.05),
  TProduct(name: 'Gaming Chair Pro', price: '\$299', priceNum: 299, imageUrl: _g1, category: 'gaming', brand: 'Secretlab', bnpl: '3 × \$99.67', discount: 0.08),

  // ── Health ───────────────────────────────────────────────────────────────
  TProduct(name: 'Theragun Mini', price: '\$199', priceNum: 199, imageUrl: _s1, category: 'health', brand: 'Therabody', bnpl: '2 × \$99.50', discount: 0.10),
  TProduct(name: 'Oral-B iO Series 7', price: '\$149', priceNum: 149, imageUrl: _b2, category: 'health', brand: 'Oral-B', bnpl: '2 × \$74.50', discount: 0.12),
  TProduct(name: 'Withings Body+ Scale', price: '\$99', priceNum: 99, imageUrl: _e7, category: 'health', brand: 'Withings', bnpl: '2 × \$49.50', discount: 0.08),
  TProduct(name: 'Vitamix Blender A2300', price: '\$449', priceNum: 449, imageUrl: _h1, category: 'health', brand: 'Vitamix', bnpl: '3 × \$149.67', discount: 0.05),
  TProduct(name: 'Oura Ring Gen 3', price: '\$299', priceNum: 299, imageUrl: _e7, category: 'health', brand: 'Oura', bnpl: '3 × \$99.67', discount: 0.08),

  // ── Music ────────────────────────────────────────────────────────────────
  TProduct(name: 'Fender Stratocaster', price: '\$799', priceNum: 799, imageUrl: _g1, category: 'music', brand: 'Fender', bnpl: '4 × \$199.75', discount: 0.05),
  TProduct(name: 'Audio-Technica AT2020', price: '\$99', priceNum: 99, imageUrl: _e2, category: 'music', brand: 'Audio-Technica', bnpl: '2 × \$49.50', discount: 0.10),
  TProduct(name: 'Yamaha P-45 Piano', price: '\$549', priceNum: 549, imageUrl: _g1, category: 'music', brand: 'Yamaha', bnpl: '3 × \$183', discount: 0.08),
  TProduct(name: 'Rode NT1-A Condenser', price: '\$249', priceNum: 249, imageUrl: _e8, category: 'music', brand: 'Rode', bnpl: '2 × \$124.50', discount: 0.12),

  // ── Books ────────────────────────────────────────────────────────────────
  TProduct(name: 'Kindle Paperwhite', price: '\$139', priceNum: 139, imageUrl: _e11, category: 'books', brand: 'Amazon', bnpl: '2 × \$69.50', discount: 0.10),
  TProduct(name: 'Kindle Scribe 16GB', price: '\$339', priceNum: 339, imageUrl: _e5, category: 'books', brand: 'Amazon', bnpl: '3 × \$113', discount: 0.08),

  // ── Auto ─────────────────────────────────────────────────────────────────
  TProduct(name: 'Garmin Dashcam Mini', price: '\$89', priceNum: 89, imageUrl: _e7, category: 'auto', brand: 'Garmin', bnpl: '2 × \$44.50', discount: 0.12),
  TProduct(name: 'Anker Car Charger 67W', price: '\$35', priceNum: 35, imageUrl: _e11, category: 'auto', brand: 'Anker', bnpl: '', discount: 0.10),

  // ── Toys ─────────────────────────────────────────────────────────────────
  TProduct(name: 'LEGO Technic 42196', price: '\$129', priceNum: 129, imageUrl: _g1, category: 'toys', brand: 'LEGO', bnpl: '2 × \$64.50', discount: 0.08),
  TProduct(name: 'Hot Wheels Track Set', price: '\$59', priceNum: 59, imageUrl: _g1, category: 'toys', brand: 'Mattel', bnpl: '', discount: 0.10),

  // ── Pets ─────────────────────────────────────────────────────────────────
  TProduct(name: 'Furbo Dog Camera', price: '\$169', priceNum: 169, imageUrl: _e11, category: 'pets', brand: 'Furbo', bnpl: '2 × \$84.50', discount: 0.12),
  TProduct(name: 'PetSafe Smart Feeder', price: '\$119', priceNum: 119, imageUrl: _h1, category: 'pets', brand: 'PetSafe', bnpl: '2 × \$59.50', discount: 0.10),

  // ── Travel ───────────────────────────────────────────────────────────────
  TProduct(name: 'Rimowa Essential Cabin', price: '\$695', priceNum: 695, imageUrl: _s1, category: 'travel', brand: 'Rimowa', bnpl: '3 × \$231.67', discount: 0.05),
  TProduct(name: 'Samsonite Spinner 68', price: '\$199', priceNum: 199, imageUrl: _s1, category: 'travel', brand: 'Samsonite', bnpl: '2 × \$99.50', discount: 0.10),
  TProduct(name: 'Travel Neck Pillow', price: '\$39', priceNum: 39, imageUrl: _h3, category: 'travel', brand: 'Trtl', bnpl: '', discount: 0.15),

  // ── Food ─────────────────────────────────────────────────────────────────
  TProduct(name: 'Nespresso Vertuo Next', price: '\$169', priceNum: 169, imageUrl: _h1, category: 'food', brand: 'Nespresso', bnpl: '2 × \$84.50', discount: 0.12),
  TProduct(name: 'KitchenAid Mixer 5Qt', price: '\$449', priceNum: 449, imageUrl: _h1, category: 'food', brand: 'KitchenAid', bnpl: '3 × \$149.67', discount: 0.08),
];

/// Get products for a specific category
List<TProduct> productsFor(String category) {
  final cat = category.toLowerCase();
  return kAllProducts.where((p) => p.category == cat).toList();
}

/// Get featured / top discount products
List<TProduct> get featuredProducts =>
    [...kAllProducts]..sort((a, b) => b.discount.compareTo(a.discount));

/// Search products by query
List<TProduct> searchProducts(String query) {
  final q = query.toLowerCase();
  return kAllProducts
      .where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q))
      .toList();
}

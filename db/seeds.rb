# Idempotent seeds migrated from seed.sql into ActiveRecord operations

puts "Seeding admins..."
admin1 = Admin.find_or_initialize_by(email: 'tilia@example.com')
admin1.name = 'Tilia Vega'
admin1.password = 'securepass123'
admin1.save!

admin2 = Admin.find_or_initialize_by(email: 'lucia@example.com')
admin2.name = 'Lucía Fernández'
admin2.password = 'strongpass456'
admin2.save!

puts "Seeding products..."
products_data = [
  { name: 'Escritorio Minimalista', description: 'Escritorio de madera clara con diseño escandinavo, ideal para espacios pequeños.', price: 129.99, created_by_admin: admin1 },
  { name: 'Silla Ergonómica Pro', description: 'Silla con soporte lumbar ajustable, reposacabezas y ruedas silenciosas.', price: 89.50, created_by_admin: admin1 },
  { name: 'Lámpara LED Inteligente', description: 'Lámpara con control por voz, cambio de color y temporizador integrado.', price: 45.75, created_by_admin: admin2 },
  { name: 'Estantería Modular', description: 'Sistema de estanterías personalizable con acabados en roble y blanco mate.', price: 159.00, created_by_admin: admin2 },
  { name: 'Alfombra Antideslizante', description: 'Alfombra decorativa con base antideslizante, ideal para salas y dormitorios.', price: 39.90, created_by_admin: admin1 },
  { name: 'Mesa Plegable Compacta', description: 'Mesa plegable de aluminio, perfecta para espacios reducidos o exteriores.', price: 74.25, created_by_admin: admin2 }
]

products_by_name = {}
products_data.each do |attrs|
  prod = Product.find_or_initialize_by(name: attrs[:name])
  prod.description = attrs[:description]
  prod.price = attrs[:price]
  prod.created_by_admin = attrs[:created_by_admin]
  prod.save!
  products_by_name[prod.name] = prod
end

puts "Seeding categories..."
categories_data = [
  { name: 'Muebles Funcionales', description: 'Muebles prácticos y versátiles para el hogar y la oficina.', created_by_admin: admin1 },
  { name: 'Iluminación Inteligente', description: 'Lámparas y sistemas de iluminación con tecnología avanzada.', created_by_admin: admin1 },
  { name: 'Decoración & Textiles', description: 'Artículos decorativos y textiles para embellecer espacios.', created_by_admin: admin2 }
]

categories_by_name = {}
categories_data.each do |attrs|
  cat = Category.find_or_initialize_by(name: attrs[:name])
  cat.description = attrs[:description]
  cat.created_by_admin = attrs[:created_by_admin]
  cat.save!
  categories_by_name[cat.name] = cat
end

puts "Linking products to categories..."
links = [
  [ 'Escritorio Minimalista', 'Muebles Funcionales' ],
  [ 'Silla Ergonómica Pro', 'Muebles Funcionales' ],
  [ 'Lámpara LED Inteligente', 'Iluminación Inteligente' ],
  [ 'Estantería Modular', 'Muebles Funcionales' ],
  [ 'Alfombra Antideslizante', 'Decoración & Textiles' ],
  [ 'Mesa Plegable Compacta', 'Muebles Funcionales' ]
]

links.each do |pname, cname|
  product = products_by_name.fetch(pname)
  category = categories_by_name.fetch(cname)
  ProductsCategory.find_or_create_by!(products_id: product.id, categories_id: category.id)
end

puts "Seeding images..."
images = [
  [ 'Escritorio Minimalista', '/images/escritorio_minimalista.png' ],
  [ 'Silla Ergonómica Pro', '/images/silla_ergonomica_pro.png' ],
  [ 'Lámpara LED Inteligente', '/images/lampara_led_inteligente.png' ],
  [ 'Estantería Modular', '/images/estanteria_modular.png' ],
  [ 'Alfombra Antideslizante', '/images/alfombra_antideslizante.png' ],
  [ 'Mesa Plegable Compacta', '/images/mesa_plegable_compacta.png' ]
]

images.each do |pname, path|
  product = products_by_name.fetch(pname)
  Image.find_or_create_by!(product: product, path: path)
end

puts "Seeding clients..."
clients = [
  { name: 'Juan Pérez', email: 'juan@example.com' },
  { name: 'María López', email: 'maria@example.com' },
  { name: 'Ana Martínez', email: 'ana@example.com' }
]

clients_by_email = {}
clients.each do |attrs|
  c = Client.find_or_initialize_by(email: attrs[:email])
  c.name = attrs[:name]
  c.save!
  clients_by_email[c.email] = c
end

puts "Seeding purchases and products_solds..."
juan  = clients_by_email['juan@example.com']
maria = clients_by_email['maria@example.com']
ana   = clients_by_email['ana@example.com']

# Evitar duplicados si ya se crearon compras previamente
created_purchases = []
if Purchase.exists?
  puts "Purchases already exist; skipping purchases and products_solds seeding."
else
  # Compras (cliente 1: 3 compras, cliente 2: 1, cliente 3: 1)
  pur_attrs = [
    { client: juan,  total_price: 395.23 },
    { client: juan,  total_price: 395.23 },
    { client: juan,  total_price: 347.40 },
    { client: maria, total_price: 89.50 },
    { client: ana,   total_price: 248.50 }
  ]

  pur_attrs.each_with_index do |attrs, idx|
    client = attrs[:client]
    raise "Client missing for purchase #{idx + 1}" unless client
    purchase = Purchase.create!(client: client, total_price: attrs[:total_price])
    created_purchases << purchase
  end

  # Detalle de compras (ProductsSold)
  ps_items = [
    # Compra 1
    [ 'Escritorio Minimalista', 0, 129.99 ],
    [ 'Escritorio Minimalista', 0, 129.99 ],
    [ 'Silla Ergonómica Pro', 0, 89.50 ],
    [ 'Lámpara LED Inteligente', 0, 45.75 ],

    # Compra 2
    [ 'Escritorio Minimalista', 1, 129.99 ],
    [ 'Escritorio Minimalista', 1, 129.99 ],
    [ 'Silla Ergonómica Pro', 1, 89.50 ],
    [ 'Lámpara LED Inteligente', 1, 45.75 ],

    # Compra 3
    [ 'Estantería Modular', 2, 159.00 ],
    [ 'Alfombra Antideslizante', 2, 39.90 ],
    [ 'Mesa Plegable Compacta', 2, 74.25 ],
    [ 'Mesa Plegable Compacta', 2, 74.25 ],

    # Compra 4
    [ 'Silla Ergonómica Pro', 3, 89.50 ],

    # Compra 5
    [ 'Estantería Modular', 4, 159.00 ],
    [ 'Silla Ergonómica Pro', 4, 89.50 ]
  ]

  ps_items.each do |product_name, purchase_index, price|
    purchase = created_purchases.fetch(purchase_index)
    product = products_by_name.fetch(product_name)
    ProductsSold.create!(product: product, purchase: purchase, price: price)
  end
end

puts "Seed completed."

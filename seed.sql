INSERT INTO admins (name, email, password, created_at, updated_at)
VALUES 
  ('Tilia Vega', 'tilia@example.com', 'securepass123', NOW(), NOW()),
  ('Lucía Fernández', 'lucia@example.com', 'strongpass456', NOW(), NOW());


INSERT INTO products (name, description, price, created_by_admin_id, created_at, updated_at)
VALUES 
  ('Escritorio Minimalista', 'Escritorio de madera clara con diseño escandinavo, ideal para espacios pequeños.', 129.99, 1, NOW(), NOW()),
  ('Silla Ergonómica Pro', 'Silla con soporte lumbar ajustable, reposacabezas y ruedas silenciosas.', 89.50, 1, NOW(), NOW()),
  ('Lámpara LED Inteligente', 'Lámpara con control por voz, cambio de color y temporizador integrado.', 45.75, 2, NOW(), NOW()),
  ('Estantería Modular', 'Sistema de estanterías personalizable con acabados en roble y blanco mate.', 159.00, 2, NOW(), NOW()),
  ('Alfombra Antideslizante', 'Alfombra decorativa con base antideslizante, ideal para salas y dormitorios.', 39.90, 1, NOW(), NOW()),
  ('Mesa Plegable Compacta', 'Mesa plegable de aluminio, perfecta para espacios reducidos o exteriores.', 74.25, 2, NOW(), NOW());


INSERT INTO images (product_id, path, created_at, updated_at)
VALUES
  (1, '/images/escritorio_minimalista.png', NOW(), NOW()),
  (2, '/images/silla_ergonomica_pro.png', NOW(), NOW()),
  (3, '/images/lampara_led_inteligente.png', NOW(), NOW()),
  (4, '/images/estanteria_modular.png', NOW(), NOW()),
  (5, '/images/alfombra_antideslizante.png', NOW(), NOW()),
  (6, '/images/mesa_plegable_compacta.png', NOW(), NOW());


INSERT INTO clients (name, email, created_at, updated_at)
VALUES
  ('Juan Pérez', 'juan@example.com', NOW(), NOW()),
  ('María López', 'maria@example.com', NOW(), NOW()),
  ('Ana Martínez', 'ana@example.com', NOW(), NOW());


INSERT INTO purchases (clients_id, total_price, created_at, updated_at)
VALUES
  (1, 395.23, NOW(), NOW()), -- 129.99 * 2 + 89.50 + 45.75
  (1, 395.23, NOW(), NOW()),
  (1, 347.4, NOW(), NOW()),  -- 159.00 + 39.90 + 74.25 * 2
  (2, 89.50, NOW(), NOW()),
  (3, 248.5, NOW(), NOW());  -- 159.00 + 89.50

INSERT INTO products_solds (products_id, purchases_id, price, created_at, updated_at)
VALUES
  -- Compra 1 (purchases_id = 1): 4 productos
  (1, 1, 129.99, NOW(), NOW()), -- Escritorio Minimalista
  (1, 1, 129.99, NOW(), NOW()), -- Escritorio Minimalista (2 unidades)
  (2, 1, 89.50, NOW(), NOW()),  -- Silla Ergonómica Pro
  (3, 1, 45.75, NOW(), NOW()),  -- Lámpara LED Inteligente

  -- Compra 2 (purchases_id = 2): 4 productos (igual que la primera)
  (1, 2, 129.99, NOW(), NOW()),
  (1, 2, 129.99, NOW(), NOW()),
  (2, 2, 89.50, NOW(), NOW()),
  (3, 2, 45.75, NOW(), NOW()),

  -- Compra 3 (purchases_id = 3): 4 productos
  (4, 3, 159.00, NOW(), NOW()), -- Estantería Modular
  (5, 3, 39.90, NOW(), NOW()),  -- Alfombra Antideslizante
  (6, 3, 74.25, NOW(), NOW()),  -- Mesa Plegable Compacta
  (6, 3, 74.25, NOW(), NOW()),  -- Mesa Plegable Compacta (2 unidades)

  -- Compra 4 (purchases_id = 4): 1 producto
  (2, 4, 89.50, NOW(), NOW()),  -- Silla Ergonómica Pro

  -- Compra 5 (purchases_id = 5): 2 productos
  (4, 5, 159.00, NOW(), NOW()), -- Estantería Modular
  (2, 5, 89.50, NOW(), NOW());  -- Silla Ergonómica Pro
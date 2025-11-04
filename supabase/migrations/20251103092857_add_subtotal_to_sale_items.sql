-- Agregar columna subtotal a sale_items
ALTER TABLE sale_items
ADD COLUMN subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantity * price) STORED;

-- Crear índice para mejorar el rendimiento de las consultas por subtotal
CREATE INDEX idx_sale_items_subtotal ON sale_items(subtotal);
-- Agregar columna unit_price a sale_items
ALTER TABLE sale_items
ADD COLUMN unit_price DECIMAL(10,2);

-- Actualizar el trigger para incluir el unit_price
CREATE OR REPLACE FUNCTION update_sale_item_product_details()
RETURNS TRIGGER AS $$
BEGIN
    -- Obtener los detalles del producto
    SELECT 
        name,
        price,
        price -- El precio del producto será el precio unitario por defecto
    INTO 
        NEW.product_name,
        NEW.product_price,
        NEW.unit_price
    FROM products
    WHERE id = NEW.product_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Actualizar los registros existentes si hay alguno
UPDATE sale_items si
SET unit_price = p.price
FROM products p
WHERE si.product_id = p.id;
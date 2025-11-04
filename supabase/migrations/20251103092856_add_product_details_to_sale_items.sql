-- Agregar columnas adicionales a sale_items
ALTER TABLE sale_items
ADD COLUMN product_name TEXT,
ADD COLUMN product_price DECIMAL(10,2);

-- Crear un trigger para mantener actualizados los datos del producto
CREATE OR REPLACE FUNCTION update_sale_item_product_details()
RETURNS TRIGGER AS $$
BEGIN
    -- Obtener los detalles del producto
    SELECT name, price
    INTO NEW.product_name, NEW.product_price
    FROM products
    WHERE id = NEW.product_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
CREATE TRIGGER update_sale_item_details
    BEFORE INSERT OR UPDATE ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION update_sale_item_product_details();

-- Actualizar los registros existentes si hay alguno
UPDATE sale_items si
SET 
    product_name = p.name,
    product_price = p.price
FROM products p
WHERE si.product_id = p.id;
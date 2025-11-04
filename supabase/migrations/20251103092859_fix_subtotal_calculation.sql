-- Primero eliminamos las restricciones y triggers existentes
DROP TRIGGER IF EXISTS update_sale_items_updated_at ON sale_items;
DROP TRIGGER IF EXISTS update_sale_item_details ON sale_items;

-- Eliminamos la columna subtotal existente
ALTER TABLE sale_items
DROP COLUMN IF EXISTS subtotal;

-- Recreamos la columna subtotal como una columna normal
ALTER TABLE sale_items
ADD COLUMN subtotal DECIMAL(10,2);

-- Actualizamos el trigger para calcular el subtotal
CREATE OR REPLACE FUNCTION update_sale_item_details()
RETURNS TRIGGER AS $$
BEGIN
    -- Obtener los detalles del producto
    SELECT 
        name,
        price,
        price
    INTO 
        NEW.product_name,
        NEW.product_price,
        NEW.unit_price
    FROM products
    WHERE id = NEW.product_id;
    
    -- Calcular el subtotal
    NEW.subtotal := NEW.quantity * NEW.price;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear el trigger
CREATE TRIGGER update_sale_item_details
    BEFORE INSERT OR UPDATE ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION update_sale_item_details();

-- Actualizar los registros existentes
UPDATE sale_items
SET subtotal = quantity * price
WHERE subtotal IS NULL;
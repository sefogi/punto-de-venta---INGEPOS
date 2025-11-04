-- Actualizamos el trigger para manejar el precio correctamente
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
    
    -- Si no se proporciona un precio, usar el precio del producto
    IF NEW.price IS NULL THEN
        NEW.price := NEW.product_price;
    END IF;
    
    -- Calcular el subtotal
    NEW.subtotal := NEW.quantity * NEW.price;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear el trigger
DROP TRIGGER IF EXISTS update_sale_item_details ON sale_items;
CREATE TRIGGER update_sale_item_details
    BEFORE INSERT OR UPDATE ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION update_sale_item_details();

-- Actualizar los registros existentes si hay alguno
UPDATE sale_items si
SET 
    price = COALESCE(si.price, p.price),
    subtotal = si.quantity * COALESCE(si.price, p.price)
FROM products p
WHERE si.product_id = p.id;
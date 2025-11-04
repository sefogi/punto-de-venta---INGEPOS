-- Crear una vista que incluya los detalles del producto en los items de venta
CREATE OR REPLACE VIEW public.sale_items_with_details AS
SELECT 
    si.id,
    si.sale_id,
    si.product_id,
    p.name as product_name,
    p.price as product_price,
    si.quantity,
    si.price as sale_price,
    si.created_at
FROM 
    sale_items si
    LEFT JOIN products p ON si.product_id = p.id;

-- Dar permisos de lectura a la vista para usuarios autenticados
GRANT SELECT ON public.sale_items_with_details TO authenticated;
GRANT SELECT ON public.sale_items_with_details TO anon;

-- Actualizar la política de la vista
CREATE POLICY "Permitir lectura de detalles de venta a usuarios autenticados" 
    ON sale_items_with_details
    FOR SELECT 
    USING (true);
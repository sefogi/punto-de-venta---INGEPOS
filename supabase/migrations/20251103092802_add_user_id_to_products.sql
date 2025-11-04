-- Agregar columna user_id a la tabla products
ALTER TABLE products
ADD COLUMN user_id UUID REFERENCES auth.users(id);

-- Actualizar las políticas de seguridad para incluir el user_id
DROP POLICY IF EXISTS "Permitir modificación a usuarios autenticados" ON products;

-- Nueva política que permite a los usuarios autenticados modificar sus propios productos
CREATE POLICY "Permitir modificación a usuarios autenticados" ON products
    FOR ALL USING (
        auth.role() = 'authenticated' AND (
            user_id = auth.uid() OR 
            user_id IS NULL -- Permitir acceso a productos sin usuario asignado
        )
    );

-- Crear índice para mejorar el rendimiento de búsquedas por user_id
CREATE INDEX idx_products_user_id ON products(user_id);
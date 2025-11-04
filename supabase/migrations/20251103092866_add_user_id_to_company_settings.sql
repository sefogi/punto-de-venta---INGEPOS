-- Agregar columna para el user_id
ALTER TABLE company_settings
ADD COLUMN user_id UUID REFERENCES auth.users(id);

-- Actualizar las políticas de seguridad para incluir el user_id
DROP POLICY IF EXISTS "Permitir lectura pública de configuración" ON company_settings;
DROP POLICY IF EXISTS "Permitir modificación a usuarios autenticados" ON company_settings;

-- Crear nuevas políticas basadas en user_id
CREATE POLICY "Permitir lectura de configuración a usuarios autenticados" ON company_settings
    FOR SELECT 
    USING (auth.role() = 'authenticated');

CREATE POLICY "Permitir modificación a propietarios" ON company_settings
    FOR ALL 
    USING (
        auth.role() = 'authenticated' 
        AND (
            user_id = auth.uid()
            OR 
            user_id IS NULL
        )
    );

-- Crear un índice para mejorar el rendimiento
CREATE INDEX idx_company_settings_user_id ON company_settings(user_id);
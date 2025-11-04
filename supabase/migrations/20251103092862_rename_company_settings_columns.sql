-- Renombrar las columnas existentes
ALTER TABLE company_settings
RENAME COLUMN address TO company_address;

ALTER TABLE company_settings
RENAME COLUMN phone TO company_phone;

ALTER TABLE company_settings
RENAME COLUMN email TO company_email;

ALTER TABLE company_settings
RENAME COLUMN tax_rate TO company_tax_rate;

-- Refrescar las políticas de seguridad
DROP POLICY IF EXISTS "Permitir lectura pública de configuración" ON company_settings;
DROP POLICY IF EXISTS "Permitir modificación a usuarios autenticados" ON company_settings;

-- Recrear las políticas
CREATE POLICY "Permitir lectura pública de configuración" ON company_settings
    FOR SELECT USING (true);

CREATE POLICY "Permitir modificación a usuarios autenticados" ON company_settings
    FOR ALL USING (auth.role() = 'authenticated');
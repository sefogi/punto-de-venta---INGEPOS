-- Agregar columna para el logo
ALTER TABLE company_settings
ADD COLUMN logo_url TEXT;

-- Crear un índice para mejorar las búsquedas por logo_url si es necesario
CREATE INDEX idx_company_settings_logo ON company_settings(logo_url);
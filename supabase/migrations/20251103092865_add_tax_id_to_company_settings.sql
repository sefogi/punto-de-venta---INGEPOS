-- Agregar columna para el RUC/tax_id
ALTER TABLE company_settings
ADD COLUMN tax_id TEXT;

-- Crear un índice para mejorar las búsquedas por tax_id
CREATE INDEX idx_company_settings_tax_id ON company_settings(tax_id);
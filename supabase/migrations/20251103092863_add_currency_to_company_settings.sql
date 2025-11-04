-- Agregar columna de moneda
ALTER TABLE company_settings
ADD COLUMN currency TEXT DEFAULT 'PEN';

-- Actualizar registros existentes si hay alguno
UPDATE company_settings
SET currency = 'PEN'
WHERE currency IS NULL;
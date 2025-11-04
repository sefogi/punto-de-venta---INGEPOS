-- Crear una vista que mapee los nombres de columnas para compatibilidad
CREATE OR REPLACE VIEW public.company_settings_view AS
SELECT 
    id,
    company_name,
    address as company_address,
    phone as company_phone,
    email as company_email,
    tax_rate as company_tax_rate,
    created_at,
    updated_at
FROM company_settings;

-- Dar permisos de lectura/escritura a la vista
GRANT SELECT, INSERT, UPDATE, DELETE ON public.company_settings_view TO authenticated;
GRANT SELECT ON public.company_settings_view TO anon;

-- Crear una función para manejar las inserciones en la vista
CREATE OR REPLACE FUNCTION insert_company_settings()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO company_settings (
        company_name,
        address,
        phone,
        email,
        tax_rate
    ) VALUES (
        NEW.company_name,
        NEW.company_address,
        NEW.company_phone,
        NEW.company_email,
        NEW.company_tax_rate
    )
    RETURNING * INTO NEW;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear una función para manejar las actualizaciones en la vista
CREATE OR REPLACE FUNCTION update_company_settings()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE company_settings SET
        company_name = NEW.company_name,
        address = NEW.company_address,
        phone = NEW.company_phone,
        email = NEW.company_email,
        tax_rate = NEW.company_tax_rate,
        updated_at = TIMEZONE('utc'::text, NOW())
    WHERE id = OLD.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear los triggers para la vista
CREATE TRIGGER company_settings_view_insert
    INSTEAD OF INSERT ON company_settings_view
    FOR EACH ROW
    EXECUTE FUNCTION insert_company_settings();

CREATE TRIGGER company_settings_view_update
    INSTEAD OF UPDATE ON company_settings_view
    FOR EACH ROW
    EXECUTE FUNCTION update_company_settings();
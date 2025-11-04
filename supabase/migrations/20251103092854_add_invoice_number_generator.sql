-- Crear una secuencia para los números de factura
CREATE SEQUENCE IF NOT EXISTS invoice_number_seq;

-- Crear función para generar números de factura
CREATE OR REPLACE FUNCTION public.generate_invoice_number()
RETURNS TEXT AS $$
DECLARE
    year_prefix TEXT;
    sequence_number TEXT;
BEGIN
    -- Obtener el año actual
    year_prefix := TO_CHAR(CURRENT_DATE, 'YYYY');
    
    -- Obtener el siguiente número de la secuencia y formatearlo con ceros a la izquierda
    sequence_number := LPAD(NEXTVAL('invoice_number_seq')::TEXT, 8, '0');
    
    -- Combinar el año con el número de secuencia (formato: YYYY-00000001)
    RETURN year_prefix || '-' || sequence_number;
END;
$$ LANGUAGE plpgsql;
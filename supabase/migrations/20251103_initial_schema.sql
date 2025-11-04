-- Crear extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de configuración de la empresa
CREATE TABLE company_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    email TEXT,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabla de productos
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    sku TEXT UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2),
    stock INTEGER NOT NULL DEFAULT 0,
    min_stock INTEGER DEFAULT 0,
    image_url TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabla de ventas
CREATE TABLE sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number TEXT NOT NULL UNIQUE DEFAULT public.generate_invoice_number(),
    customer_name TEXT,
    customer_email TEXT,
    customer_phone TEXT,
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) DEFAULT 0,
    discount DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    payment_method TEXT NOT NULL,
    notes TEXT,
    user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabla de detalles de venta
CREATE TABLE sale_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_id UUID REFERENCES sales(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name TEXT,
    product_price DECIMAL(10,2),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2),
    price DECIMAL(10,2), -- Removemos NOT NULL para permitir que el trigger lo establezca
    subtotal DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Función para actualizar el timestamp de actualización
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar el timestamp
CREATE TRIGGER update_company_settings_updated_at
    BEFORE UPDATE ON company_settings
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Políticas de seguridad RLS (Row Level Security)

-- Habilitar RLS
ALTER TABLE company_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;

-- Políticas para company_settings
CREATE POLICY "Permitir lectura pública de configuración" ON company_settings
    FOR SELECT USING (true);

CREATE POLICY "Permitir modificación a usuarios autenticados" ON company_settings
    FOR ALL USING (auth.role() = 'authenticated');

-- Políticas para products
CREATE POLICY "Permitir lectura pública de productos" ON products
    FOR SELECT USING (true);

CREATE POLICY "Permitir modificación a usuarios autenticados" ON products
    FOR ALL USING (auth.role() = 'authenticated');

-- Políticas para sales
CREATE POLICY "Permitir lectura de ventas a usuarios autenticados" ON sales
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Permitir crear ventas a usuarios autenticados" ON sales
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Políticas para sale_items
CREATE POLICY "Permitir lectura de items de venta a usuarios autenticados" ON sale_items
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Permitir crear items de venta a usuarios autenticados" ON sale_items
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Índices para mejorar el rendimiento
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_sales_date ON sales(created_at);
CREATE INDEX idx_sales_invoice ON sales(invoice_number);
CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);
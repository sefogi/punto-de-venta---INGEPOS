# Sistema de Punto de Venta e Inventario

![Versión](https://img.shields.io/badge/versión-1.01-blue)
![Estado](https://img.shields.io/badge/estado-stable-green)

Sistema de punto de venta e inventario desarrollado con React y Supabase, diseñado para pequeños y medianos negocios.

## 🚀 Características

### Punto de Venta (POS)

- Interfaz intuitiva para registro de ventas
- Procesamiento de múltiples métodos de pago
- Generación automática de números de factura
- Descuentos y ajustes de impuestos
- Registro de información del cliente

### Gestión de Productos

- Catálogo completo de productos
- Control de inventario en tiempo real
- Alertas de stock bajo
- Gestión de precios y costos
- Códigos SKU y gestión de imágenes

### Gestión de Ventas

- Historial detallado de transacciones
- Exportación de datos a CSV y Excel
- Filtrado y búsqueda de ventas
- Visualización de detalles de venta
- Reportes de ventas

### Configuración

- Personalización de la información de la empresa
- Gestión de usuarios y permisos
- Configuración de impuestos y descuentos
- Respaldo en la nube con Supabase

## 💻 Tecnologías

- **Frontend**: React + TypeScript
- **UI Components**: Radix UI + Tailwind CSS
- **Base de datos**: Supabase
- **Autenticación**: Supabase Auth
- **Estado**: React Query
- **Gráficos**: Recharts
- **Exportación**: XLSX

## 📦 Instalación

```bash
# Clonar el repositorio
git clone [url-del-repositorio]

# Instalar dependencias
pnpm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de Supabase

# Iniciar el servidor de desarrollo
pnpm run dev
```

## 🔧 Configuración

### Variables de Entorno Requeridas

```env
VITE_SUPABASE_URL=tu_url_de_supabase
VITE_SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase
```

### Base de Datos

El sistema requiere las siguientes tablas en Supabase:

- `products`: Gestión de productos
- `sales`: Registro de ventas
- `company_settings`: Configuración de la empresa

## 📱 Uso

1. **Iniciar Sesión**: Accede con tus credenciales
2. **Punto de Venta**:
   - Selecciona productos
   - Agrega cantidades
   - Procesa el pago
3. **Gestión de Productos**:
   - Agrega/edita productos
   - Gestiona inventario
4. **Ventas**:
   - Revisa el historial
   - Exporta reportes
   - Visualiza detalles

## 🤝 Soporte

### Desarrollador

- **Nombre**: Sebastian Forero
- **Contacto**: 617-786-268
- **Horario**: Lunes a Viernes, 8:00 AM - 6:00 PM
- **Email**: ingenios.inc@gmail.com

## 📄 Licencia

Este proyecto es software propietario. Todos los derechos reservados.

## 🔄 Actualizaciones

### Versión 1.01

- Sistema base estable
- Funcionalidades principales implementadas
- Exportación a CSV y Excel
- Sistema de ayuda integrado

---

Desarrollado por Sebastian Forero © 2025

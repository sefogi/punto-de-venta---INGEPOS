import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Separator } from "@/components/ui/separator";
import { Badge } from "@/components/ui/badge";

interface SaleDetail {
  id: string;
  invoice_number: string;
  customer_name?: string;
  customer_email?: string;
  customer_phone?: string;
  subtotal: number;
  tax: number;
  discount: number;
  total: number;
  payment_method: string;
  notes?: string;
  created_at: string;
}

interface SaleItem {
  id: string;
  product_name: string;
  quantity: number;
  unit_price: number;
  subtotal: number;
}

interface SaleDetailDialogProps {
  saleId: string | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export const SaleDetailDialog = ({
  saleId,
  open,
  onOpenChange,
}: SaleDetailDialogProps) => {
  const [sale, setSale] = useState<SaleDetail | null>(null);
  const [items, setItems] = useState<SaleItem[]>([]);

  useEffect(() => {
    if (saleId && open) {
      fetchSaleDetails();
    }
  }, [saleId, open]);

  const fetchSaleDetails = async () => {
    if (!saleId) return;

    const { data: saleData } = await supabase
      .from("sales")
      .select("*")
      .eq("id", saleId)
      .single();

    const { data: itemsData } = await supabase
      .from("sale_items")
      .select("*")
      .eq("sale_id", saleId);

    if (saleData) setSale(saleData);
    if (itemsData) setItems(itemsData);
  };

  if (!sale) return null;

  const getPaymentMethodLabel = (method: string) => {
    const labels: Record<string, string> = {
      cash: "Efectivo",
      card: "Tarjeta",
      transfer: "Transferencia",
      other: "Otro",
    };
    return labels[method] || method;
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Detalles de Venta</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {/* Header */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <div className="text-sm text-muted-foreground">Factura</div>
              <div className="font-semibold text-lg">{sale.invoice_number}</div>
            </div>
            <div>
              <div className="text-sm text-muted-foreground">Fecha</div>
              <div className="font-semibold">
                {new Date(sale.created_at).toLocaleDateString("es-ES", {
                  year: "numeric",
                  month: "long",
                  day: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </div>
            </div>
          </div>

          {/* Customer Info */}
          {(sale.customer_name || sale.customer_email || sale.customer_phone) && (
            <>
              <Separator />
              <div>
                <h3 className="font-semibold mb-2">Información del Cliente</h3>
                <div className="space-y-1 text-sm">
                  {sale.customer_name && (
                    <div>
                      <span className="text-muted-foreground">Nombre: </span>
                      {sale.customer_name}
                    </div>
                  )}
                  {sale.customer_email && (
                    <div>
                      <span className="text-muted-foreground">Email: </span>
                      {sale.customer_email}
                    </div>
                  )}
                  {sale.customer_phone && (
                    <div>
                      <span className="text-muted-foreground">Teléfono: </span>
                      {sale.customer_phone}
                    </div>
                  )}
                </div>
              </div>
            </>
          )}

          {/* Items */}
          <Separator />
          <div>
            <h3 className="font-semibold mb-3">Productos</h3>
            <div className="space-y-2">
              {items.map((item) => (
                <div
                  key={item.id}
                  className="flex items-center justify-between bg-muted p-3 rounded-lg"
                >
                  <div className="flex-1">
                    <div className="font-medium">{item.product_name}</div>
                    <div className="text-sm text-muted-foreground">
                      {item.quantity} x ${item.unit_price.toFixed(2)}
                    </div>
                  </div>
                  <div className="font-semibold">
                    ${item.subtotal.toFixed(2)}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Totals */}
          <Separator />
          <div className="space-y-2">
            <div className="flex justify-between">
              <span>Subtotal:</span>
              <span className="font-semibold">${sale.subtotal.toFixed(2)}</span>
            </div>
            {sale.tax > 0 && (
              <div className="flex justify-between">
                <span>Impuesto:</span>
                <span className="font-semibold">${sale.tax.toFixed(2)}</span>
              </div>
            )}
            {sale.discount > 0 && (
              <div className="flex justify-between">
                <span>Descuento:</span>
                <span className="font-semibold">-${sale.discount.toFixed(2)}</span>
              </div>
            )}
            <Separator />
            <div className="flex justify-between text-lg">
              <span className="font-bold">Total:</span>
              <span className="font-bold text-primary">
                ${sale.total.toFixed(2)}
              </span>
            </div>
          </div>

          {/* Payment Method */}
          <div className="flex items-center justify-between">
            <span className="text-muted-foreground">Método de Pago:</span>
            <Badge>{getPaymentMethodLabel(sale.payment_method)}</Badge>
          </div>

          {/* Notes */}
          {sale.notes && (
            <>
              <Separator />
              <div>
                <h3 className="font-semibold mb-2">Notas</h3>
                <p className="text-sm text-muted-foreground">{sale.notes}</p>
              </div>
            </>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
};

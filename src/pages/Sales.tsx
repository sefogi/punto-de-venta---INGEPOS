import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Search, Eye, Download, FileSpreadsheet, HelpCircle } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropdownMenuItem } from "@/components/ui/dropdown-menu";
import * as XLSX from 'xlsx';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { SaleDetailDialog } from "@/components/sales/SaleDetailDialog";

interface Sale {
  id: string;
  invoice_number: string;
  customer_name?: string;
  total: number;
  payment_method: string;
  created_at: string;
}

const Sales = () => {
  const [sales, setSales] = useState<Sale[]>([]);
  const [search, setSearch] = useState("");
  const [selectedSale, setSelectedSale] = useState<string | null>(null);
  const [helpDialogOpen, setHelpDialogOpen] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    fetchSales();
  }, []);

  const fetchSales = async () => {
    const { data, error } = await supabase
      .from("sales")
      .select("*")
      .order("created_at", { ascending: false });

    if (error) {
      toast({
        variant: "destructive",
        title: "Error",
        description: "No se pudieron cargar las ventas",
      });
      return;
    }

    setSales(data || []);
  };

  const filteredSales = sales.filter(
    (sale) =>
      sale.invoice_number.toLowerCase().includes(search.toLowerCase()) ||
      sale.customer_name?.toLowerCase().includes(search.toLowerCase())
  );

  const getPaymentMethodLabel = (method: string) => {
    const labels: Record<string, string> = {
      cash: "Efectivo",
      card: "Tarjeta",
      transfer: "Transferencia",
      other: "Otro",
    };
    return labels[method] || method;
  };

  const getExportData = () => {
    return sales.map((sale) => ({
      "Número de Factura": sale.invoice_number,
      "Cliente": sale.customer_name || "Cliente general",
      "Fecha": new Date(sale.created_at).toLocaleDateString("es-ES", {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      }),
      "Método de Pago": getPaymentMethodLabel(sale.payment_method),
      "Total": sale.total.toFixed(2),
    }));
  };

  const exportToCSV = () => {
    const data = getExportData();
    const headers = Object.keys(data[0]).join(",");
    const rows = data.map(row => 
      Object.values(row)
        .map(cell => `"${cell}"`)
        .join(",")
    );
    const csv = [headers, ...rows].join("\n");

    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `ventas_${new Date().toISOString().split("T")[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    toast({
      title: "Exportación completada",
      description: "El archivo CSV se ha descargado correctamente",
    });
  };

  const exportToExcel = () => {
    const data = getExportData();
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Ventas");
    
    // Ajustar el ancho de las columnas
    const colWidths = Object.keys(data[0]).map(key => ({
      wch: Math.max(key.length, ...data.map(row => String(row[key as keyof typeof row]).length))
    }));
    ws["!cols"] = colWidths;

    XLSX.writeFile(wb, `ventas_${new Date().toISOString().split("T")[0]}.xlsx`);
    
    toast({
      title: "Exportación completada",
      description: "El archivo Excel se ha descargado correctamente",
    });
  };

  return (
    <div className="h-full flex flex-col">
      <div className="p-6 border-b bg-card">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-3xl font-bold">Historial de Ventas</h1>
          <div className="flex items-center gap-2">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setHelpDialogOpen(true)}
              className="text-muted-foreground hover:text-foreground"
            >
              <HelpCircle className="w-5 h-5" />
            </Button>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" className="flex items-center gap-2">
                  <Download className="w-4 h-4" />
                  Exportar
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={exportToCSV} className="flex items-center gap-2">
                  <FileSpreadsheet className="w-4 h-4" />
                  Exportar a CSV
                </DropdownMenuItem>
                <DropdownMenuItem onClick={exportToExcel} className="flex items-center gap-2">
                  <FileSpreadsheet className="w-4 h-4" />
                  Exportar a Excel
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-5 h-5" />
          <Input
            placeholder="Buscar por factura o cliente..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>

      <div className="flex-1 overflow-auto p-6">
        <div className="bg-card rounded-lg border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Factura</TableHead>
                <TableHead>Cliente</TableHead>
                <TableHead>Fecha</TableHead>
                <TableHead>Método de Pago</TableHead>
                <TableHead className="text-right">Total</TableHead>
                <TableHead className="text-right">Acciones</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredSales.map((sale) => (
                <TableRow key={sale.id}>
                  <TableCell>
                    <code className="font-semibold">{sale.invoice_number}</code>
                  </TableCell>
                  <TableCell>{sale.customer_name || "Cliente general"}</TableCell>
                  <TableCell>
                    {new Date(sale.created_at).toLocaleDateString("es-ES", {
                      year: "numeric",
                      month: "short",
                      day: "numeric",
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline">
                      {getPaymentMethodLabel(sale.payment_method)}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-right font-bold text-primary">
                    ${sale.total.toFixed(2)}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => setSelectedSale(sale.id)}
                    >
                      <Eye className="w-4 h-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
              {filteredSales.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-12">
                    <div className="text-muted-foreground">
                      No se encontraron ventas
                    </div>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </div>
      </div>

      <SaleDetailDialog
        saleId={selectedSale}
        open={!!selectedSale}
        onOpenChange={(open) => !open && setSelectedSale(null)}
      />

      <Dialog open={helpDialogOpen} onOpenChange={setHelpDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Acerca del Sistema</DialogTitle>
            <DialogDescription className="space-y-4">
              <div className="space-y-2">
                <h3 className="font-semibold">Información del Sistema</h3>
                <p>Versión: 1.01</p>
                <p>Sistema de Punto de Venta e Inventario</p>
              </div>
              
              <div className="space-y-2">
                <h3 className="font-semibold">Desarrollador</h3>
                <p>Sebastian Forero</p>
                <p>Contacto de Soporte: <a href="tel:+51617786268" className="text-primary hover:underline">617-786-268</a></p>
              </div>

              <div className="space-y-2">
                <h3 className="font-semibold">Soporte Técnico</h3>
                <ul className="list-disc list-inside space-y-1 text-muted-foreground">
                  <li>Horario de atención: Lunes a Viernes</li>
                  <li>8:00 AM - 6:00 PM</li>
                  <li>Email: ingenios.inc@gmail.com</li>
                </ul>
              </div>
            </DialogDescription>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default Sales;

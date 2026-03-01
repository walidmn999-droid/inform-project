"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Plus, Pencil, Trash2, CheckCircle, Paperclip } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useLang } from "@/lib/language-context"

/* ---------- Types ---------- */
export interface TransactionItem {
  service: string
  serviceEn?: string
  qty: number
  unitPrice: number
  total: number
  company: string
  companyEn?: string
  employee: string
  employeeEn?: string
  hasAttachment: boolean
}

export interface Transaction {
  invoiceNumber: string
  date: string
  status: "مكتمل" | "قيد التنفيذ" | "ملغي"
  grandTotal: number
  items: TransactionItem[]
}

/* ---------- Action Bar ---------- */
function ActionBar() {
  const { t } = useLang()
  const router = useRouter()
  return (
    <div className="flex flex-wrap items-center gap-2">
      <Button onClick={() => router.push("/customer/transactions/add")} className="h-9 gap-2 rounded-lg bg-[#16A34A] px-4 text-sm font-medium text-[#ffffff] shadow-sm transition-all hover:bg-[#15803D]">
        <Plus className="size-4" />
        {t("tx.addTx")}
      </Button>
      <Button className="h-9 gap-2 rounded-lg bg-[#2563EB] px-4 text-sm font-medium text-[#ffffff] shadow-sm transition-all hover:bg-[#1D4ED8]">
        <Pencil className="size-4" />
        {t("tx.editTx")}
      </Button>
      <Button variant="outline" className="h-9 gap-2 rounded-lg border-[#EF4444]/30 px-4 text-sm font-medium text-[#EF4444] transition-all hover:bg-[#EF4444] hover:text-[#ffffff]">
        <Trash2 className="size-4" />
        {t("tx.deleteTx")}
      </Button>
      <Button className="h-9 gap-2 rounded-lg bg-[#F59E0B] px-4 text-sm font-medium text-[#ffffff] shadow-sm transition-all hover:bg-[#D97706]">
        <CheckCircle className="size-4" />
        {t("tx.status")}
      </Button>
    </div>
  )
}

/* ---------- Status helpers ---------- */
function statusColor(status: Transaction["status"]) {
  switch (status) {
    case "مكتمل":
      return "bg-[#16A34A] text-[#ffffff]"
    case "قيد التنفيذ":
      return "bg-[#F59E0B] text-[#ffffff]"
    case "ملغي":
      return "bg-[#EF4444] text-[#ffffff]"
  }
}

function useStatusText() {
  const { t } = useLang()
  return (status: Transaction["status"]) => {
    switch (status) {
      case "مكتمل": return t("tx.completed")
      case "قيد التنفيذ": return t("tx.pending")
      case "ملغي": return t("tx.cancelled")
    }
  }
}

/* ---------- Transaction Block ---------- */
function TransactionBlock({ tx, isSelected, onClick }: { tx: Transaction; isSelected: boolean; onClick: () => void }) {
  const { t, lang, formatCurrency } = useLang()
  const getStatusText = useStatusText()

  return (
    <div
      onClick={onClick}
      className={`cursor-pointer transition-all duration-150 ${
        isSelected ? "ring-2 ring-inset ring-[#2563EB]" : ""
      }`}
    >
      {/* Items rows with zebra striping */}
      {tx.items.map((item, idx) => {
        const serviceName = lang === "en" && item.serviceEn ? item.serviceEn : item.service
        const companyName = lang === "en" && item.companyEn ? item.companyEn : item.company
        const employeeName = lang === "en" && item.employeeEn ? item.employeeEn : item.employee

        return (
          <div
            key={idx}
            className={`grid grid-cols-[minmax(140px,2.5fr)_55px_85px_100px_minmax(120px,1.8fr)_minmax(100px,1.3fr)_55px] items-center gap-x-3 border-b border-[#F1F5F9] px-5 py-3 text-[15px] leading-relaxed transition-colors hover:bg-[#EFF6FF] ${
              idx % 2 === 0 ? "bg-[#ffffff]" : "bg-[#F8FAFC]"
            }`}
          >
            <span className="font-medium text-[#000000]">{serviceName}</span>
            <span className="text-center tabular-nums font-medium text-[#000000]">{item.qty}</span>
            <span className="text-center tabular-nums font-medium text-[#000000]">
              {item.unitPrice.toLocaleString("en-US", { minimumFractionDigits: 2 })}
            </span>
            <span className="text-center tabular-nums font-semibold text-[#000000]">
              {item.total.toLocaleString("en-US", { minimumFractionDigits: 2 })}
            </span>
            <span className="font-medium text-[#1E5A8A]">{companyName}</span>
            <span className="font-medium text-[#7C3AED]">{employeeName}</span>
            <span className="flex justify-center">
              {item.hasAttachment ? (
                <span className="flex size-7 items-center justify-center rounded-md bg-[#2563EB] text-[#ffffff] transition-transform hover:scale-110">
                  <Paperclip className="size-3.5" />
                </span>
              ) : (
                <span className="text-xs text-[#CBD5E1]">-</span>
              )}
            </span>
          </div>
        )
      })}

      {/* Summary cell */}
      <div className="flex justify-center border-b border-[#E2E8F0] bg-[#DBEAFE] py-2.5">
        <div className="inline-flex flex-wrap items-center gap-x-3 gap-y-1 rounded-lg border border-[#2563EB]/20 bg-[#EFF6FF] px-5 py-1.5 shadow-sm">
          <span className="text-sm font-medium text-[#000000]">
            {t("tx.invoice")}{" "}
            <span className="tabular-nums text-[#2563EB]">{tx.invoiceNumber}</span>
          </span>
          <span className="h-3.5 w-px bg-[#CBD5E1]" />
          <span className="text-sm font-medium text-[#000000]">
            {t("tx.date")}{" "}
            <span className="tabular-nums text-[#000000]">{tx.date}</span>
          </span>
          <span className="h-3.5 w-px bg-[#CBD5E1]" />
          <span className="text-sm font-medium text-[#000000]">
            {t("tx.statusLabel")}{" "}
            <span className={`inline-block rounded-md px-2.5 py-0.5 text-xs font-medium ${statusColor(tx.status)}`}>
              {getStatusText(tx.status)}
            </span>
          </span>
          <span className="h-3.5 w-px bg-[#CBD5E1]" />
          <span className="text-sm font-medium text-[#000000]">
            {t("tx.grandTotal")}{" "}
            <span className="text-base font-semibold tabular-nums text-[#2563EB]">
              {formatCurrency(tx.grandTotal)}
            </span>
          </span>
        </div>
      </div>
    </div>
  )
}

/* ---------- Main Table ---------- */
interface TransactionsTableProps {
  transactions: Transaction[]
  customerName: string
}

export function TransactionsTable({ transactions, customerName }: TransactionsTableProps) {
  const [selectedTx, setSelectedTx] = useState<string | null>(null)
  const { t, lang } = useLang()

  return (
    <section className="flex flex-1 flex-col overflow-hidden">
      {/* Sticky header zone: title + actions + table header */}
      <div className="sticky top-0 z-20 bg-[#F8FAFC]">
        {/* Page title row */}
        <div className="flex flex-wrap items-center justify-between gap-4 px-6 pb-4 pt-6">
          <div className="flex items-center gap-3">
            <div className="h-8 w-1 rounded-full bg-[#2563EB]" />
            <div>
              <h1 className="text-2xl font-semibold text-[#000000]">
                {t("tx.title")}
              </h1>
              <p className="text-base font-medium text-[#2563EB]">{customerName}</p>
            </div>
          </div>
          <ActionBar />
        </div>

        {/* Table header */}
        <div className="mx-6 grid grid-cols-[minmax(140px,2.5fr)_55px_85px_100px_minmax(120px,1.8fr)_minmax(100px,1.3fr)_55px] items-center gap-x-3 rounded-t-xl bg-[#2B6CB0] px-5 py-3 text-sm font-medium tracking-wide text-[#ffffff] shadow-md">
          <span>{t("tx.service")}</span>
          <span className="text-center">{t("tx.qty")}</span>
          <span className="text-center">{t("tx.unitPrice")}</span>
          <span className="text-center">{t("tx.total")}</span>
          <span>{t("tx.company")}</span>
          <span>{t("tx.employee")}</span>
          <span className="text-center">{t("tx.attachments")}</span>
        </div>
      </div>

      {/* Scrollable body */}
      <div className="flex-1 scroll-smooth overflow-y-auto px-6 pb-6">
        <div className="overflow-hidden rounded-b-xl border border-t-0 border-[#E2E8F0] bg-[#ffffff] shadow-lg">
          {/* Transaction blocks */}
          <div>
            {transactions.map((tx, index) => (
              <div key={tx.invoiceNumber}>
                <TransactionBlock
                  tx={tx}
                  isSelected={selectedTx === tx.invoiceNumber}
                  onClick={() =>
                    setSelectedTx(selectedTx === tx.invoiceNumber ? null : tx.invoiceNumber)
                  }
                />
                {/* Separator between blocks */}
                {index < transactions.length - 1 && (
                  <div className="h-[3px] bg-[#2563EB]/20" />
                )}
              </div>
            ))}
          </div>

          {/* Table footer with grand total */}
          <div className="flex items-center justify-between border-t-2 border-[#2B6CB0] bg-[#F8FAFC] px-5 py-3">
            <span className="text-base font-medium text-[#000000]">
              {t("tx.grandTotal")} {transactions.length} {lang === "ar" ? "معاملة" : "transactions"}
            </span>
          </div>
        </div>
      </div>
    </section>
  )
}

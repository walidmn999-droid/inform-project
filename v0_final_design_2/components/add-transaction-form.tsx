"use client"

import { useState, useCallback } from "react"
import { useRouter } from "next/navigation"
import { Plus, Trash2, PlusCircle, Paperclip } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { useLang } from "@/lib/language-context"

interface ItemRow {
  id: string
  service: string
  qty: number
  unitPrice: number
  discount: number
  benefit: number
  total: number
  attachment: File | null
}

function createEmptyItem(): ItemRow {
  return {
    id: crypto.randomUUID(),
    service: "",
    qty: 1,
    unitPrice: 0,
    discount: 0,
    benefit: 0,
    total: 0,
    attachment: null,
  }
}

function calculateTotal(item: ItemRow): number {
  const subtotal = item.qty * item.unitPrice
  return Math.max(subtotal - item.discount + item.benefit, 0)
}

export function AddTransactionForm() {
  const router = useRouter()
  const { t, formatCurrency } = useLang()
  const [invoiceNumber] = useState(
    () => Math.floor(Math.random() * 900 + 100).toString()
  )

  // Shared fields for the whole transaction
  const [company, setCompany] = useState("")
  const [employee, setEmployee] = useState("")
  const [date, setDate] = useState(new Date().toISOString().split("T")[0])

  // Item rows
  const [items, setItems] = useState<ItemRow[]>([createEmptyItem()])

  const updateItem = useCallback(
    (id: string, field: keyof ItemRow, value: string | number | File | null) => {
      setItems((prev) =>
        prev.map((item) => {
          if (item.id !== id) return item
          const updated = { ...item, [field]: value }
          updated.total = calculateTotal(updated)
          return updated
        })
      )
    },
    []
  )

  const addItem = useCallback(() => {
    setItems((prev) => [...prev, createEmptyItem()])
  }, [])

  const removeItem = useCallback((id: string) => {
    setItems((prev) => (prev.length === 1 ? prev : prev.filter((i) => i.id !== id)))
  }, [])

  const grandTotal = items.reduce((sum, item) => sum + item.total, 0)

  return (
    <section className="flex flex-1 flex-col overflow-hidden">
      {/* Sticky header: title + shared fields */}
      <div className="sticky top-0 z-20 bg-[#ffffff] shadow-sm">
        {/* Title */}
        <div className="border-b border-[#E2E8F0] px-8 py-5">
          <h1 className="text-2xl font-semibold text-[#2563EB]">
            {t("addTx.title")}
          </h1>
        </div>

        {/* Shared fields card */}
        <div className="border-b-2 border-[#2563EB]/15 bg-[#F8FAFC] px-8 py-5">
          <div className="grid grid-cols-4 gap-5 rounded-xl border-2 border-[#2563EB]/25 bg-[#ffffff] p-5">
            {/* Invoice number */}
            <div className="flex flex-col gap-1.5">
              <label className="text-sm font-medium text-[#2B6CB0]">
                {t("addTx.invoiceNumber")}
              </label>
              <Input
                readOnly
                value={invoiceNumber}
                className="h-10 cursor-default bg-[#ffffff] text-center text-[15px] font-semibold tabular-nums"
              />
            </div>
            {/* Company */}
            <div className="flex flex-col gap-1.5">
              <label className="text-sm font-medium text-[#2B6CB0]">
                {t("addTx.company")}
              </label>
              <Input
                value={company}
                onChange={(e) => setCompany(e.target.value)}
                className="h-10 text-[15px]"
              />
            </div>
            {/* Employee */}
            <div className="flex flex-col gap-1.5">
              <label className="text-sm font-medium text-[#2B6CB0]">
                {t("addTx.employee")}
              </label>
              <Input
                placeholder={t("addTx.employeePlaceholder")}
                value={employee}
                onChange={(e) => setEmployee(e.target.value)}
                className="h-10 text-[15px]"
              />
            </div>
            {/* Date */}
            <div className="flex flex-col gap-1.5">
              <label className="text-sm font-medium text-[#2B6CB0]">
                {t("addTx.date")}
              </label>
              <Input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="h-10 text-[15px]"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Scrollable body -- items only */}
      <div className="flex-1 scroll-smooth overflow-y-auto px-8 py-6">
        {/* Section title + add button */}
        <div className="mb-5 flex items-center justify-between">
          <h2 className="text-base font-semibold text-[#2B6CB0]">
            {t("addTx.items")}
          </h2>
          <Button
            type="button"
            onClick={addItem}
            variant="outline"
            className="gap-2 rounded-lg border-[#2563EB] text-sm font-medium text-[#2563EB] hover:bg-[#EFF6FF]"
          >
            <Plus className="size-4" />
            {t("addTx.addItem")}
          </Button>
        </div>

        {/* Item blocks */}
        <div className="flex flex-col gap-5">
          {items.map((item, index) => (
            <div
              key={item.id}
              className="rounded-xl border-2 border-[#2563EB]/20 bg-[#ffffff] shadow-md"
            >
              {/* Block header */}
              <div className="flex items-center justify-between border-b border-[#E2E8F0] px-5 py-3">
                <span className="rounded-md bg-[#2563EB] px-3 py-1 text-sm font-medium text-[#ffffff]">
                  {t("addTx.itemNumber")} #{index + 1}
                </span>
                <Button
                  type="button"
                  onClick={() => removeItem(item.id)}
                  variant="outline"
                  className="h-8 gap-1.5 rounded-lg border-[#EF4444]/30 px-3 text-xs font-medium text-[#EF4444] hover:bg-[#EF4444] hover:text-[#ffffff]"
                  disabled={items.length === 1}
                >
                  <Trash2 className="size-3.5" />
                  {t("addTx.deleteItem")}
                </Button>
              </div>

              {/* Fields */}
              <div className="flex flex-col gap-5 p-5">
                {/* Row 1: service type (full width) */}
                <div className="flex flex-col gap-1.5">
                  <label className="text-sm font-medium text-[#2B6CB0]">
                    {t("addTx.serviceType")}
                  </label>
                  <Input
                    placeholder={t("addTx.servicePlaceholder")}
                    value={item.service}
                    onChange={(e) => updateItem(item.id, "service", e.target.value)}
                    className="h-10 text-[15px]"
                  />
                </div>

                {/* Row 2: qty, unit price, discount, benefit, total */}
                <div className="grid grid-cols-5 gap-4">
                  <div className="flex flex-col gap-1.5">
                    <label className="text-sm font-medium text-[#2B6CB0]">
                      {t("addTx.qty")}
                    </label>
                    <Input
                      type="number"
                      min={1}
                      value={item.qty}
                      onChange={(e) => updateItem(item.id, "qty", Number(e.target.value))}
                      className="h-10 text-center text-[15px] tabular-nums"
                    />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label className="text-sm font-medium text-[#2B6CB0]">
                      {t("addTx.unitPrice")}
                    </label>
                    <Input
                      type="number"
                      min={0}
                      step={0.01}
                      value={item.unitPrice}
                      onChange={(e) => updateItem(item.id, "unitPrice", Number(e.target.value))}
                      className="h-10 text-center text-[15px] tabular-nums"
                    />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label className="text-sm font-medium text-[#2B6CB0]">
                      {t("addTx.discount")}
                    </label>
                    <Input
                      type="number"
                      min={0}
                      step={0.01}
                      value={item.discount}
                      onChange={(e) => updateItem(item.id, "discount", Number(e.target.value))}
                      className="h-10 text-center text-[15px] tabular-nums"
                    />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label className="text-sm font-medium text-[#2B6CB0]">
                      {t("addTx.benefit")}
                    </label>
                    <Input
                      type="number"
                      min={0}
                      step={0.01}
                      value={item.benefit}
                      onChange={(e) => updateItem(item.id, "benefit", Number(e.target.value))}
                      className="h-10 text-center text-[15px] tabular-nums"
                    />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label className="text-sm font-medium text-[#2B6CB0]">
                      {t("addTx.total")}
                    </label>
                    <Input
                      readOnly
                      value={item.total.toFixed(2)}
                      className="h-10 cursor-default bg-[#F8FAFC] text-center text-[15px] font-semibold tabular-nums"
                    />
                  </div>
                </div>

                {/* Row 3: attachments */}
                <div className="flex flex-col gap-1.5">
                  <label className="text-sm font-medium text-[#2B6CB0]">
                    {t("addTx.attachments")}
                  </label>
                  <div className="flex items-center gap-3">
                    <label className="flex h-10 cursor-pointer items-center gap-2 rounded-lg border border-[#E2E8F0] bg-[#F8FAFC] px-4 text-sm font-medium text-[#2B6CB0] transition-colors hover:bg-[#EFF6FF]">
                      <Paperclip className="size-4 text-[#2563EB]" />
                      <span>
                        {item.attachment ? item.attachment.name : "Choose Files"}
                      </span>
                      <input
                        type="file"
                        className="hidden"
                        onChange={(e) =>
                          updateItem(item.id, "attachment", e.target.files?.[0] ?? null)
                        }
                      />
                    </label>
                    {item.attachment && (
                      <span className="text-xs text-[#64748B]">
                        {item.attachment.name}
                      </span>
                    )}
                  </div>
                </div>
              </div>

              {/* Add new item inside block */}
              <div className="border-t border-[#E2E8F0] px-5 py-3">
                <button
                  type="button"
                  onClick={addItem}
                  className="flex items-center gap-2 rounded-lg border border-[#16A34A]/30 bg-[#ffffff] px-4 py-1.5 text-sm font-medium text-[#16A34A] transition-colors hover:bg-[#F0FDF4]"
                >
                  <PlusCircle className="size-4" />
                  {t("addTx.addNewItem")}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Sticky footer */}
      <div className="sticky bottom-0 z-20 flex items-center gap-4 border-t-2 border-[#2B6CB0] bg-[#ffffff] px-8 py-4 shadow-[0_-2px_10px_rgba(0,0,0,0.05)]">
        <Button
          type="button"
          onClick={() => router.back()}
          className="h-10 gap-2 rounded-lg bg-[#EF4444] px-6 text-sm font-medium text-[#ffffff] hover:bg-[#DC2626]"
        >
          {t("addTx.cancel")}
        </Button>
        <Button
          type="button"
          className="h-10 gap-2 rounded-lg bg-[#2563EB] px-6 text-sm font-medium text-[#ffffff] hover:bg-[#1D4ED8]"
        >
          {t("addTx.save")}
        </Button>
        <div className="flex items-center gap-2">
          <span className="text-base font-medium text-[#2B6CB0]">
            {t("addTx.grandTotal")}
          </span>
          <span className="rounded-lg border-2 border-[#2563EB]/20 bg-[#EFF6FF] px-4 py-1.5 text-lg font-semibold tabular-nums text-[#2563EB]">
            {formatCurrency(grandTotal)}
          </span>
        </div>
      </div>
    </section>
  )
}

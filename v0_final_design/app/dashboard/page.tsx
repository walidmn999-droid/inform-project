"use client"

import { useState } from "react"
import { DashboardHeader } from "@/components/dashboard-header"
import { CentralBanner } from "@/components/central-banner"
import { CustomerGrid, type Customer } from "@/components/customer-grid"

const SAMPLE_CUSTOMERS: Customer[] = [
  { id: 1, name: "أحمد محمد", nameEn: "Ahmed Mohammed" },
  { id: 2, name: "فاطمة علي", nameEn: "Fatima Ali" },
  { id: 3, name: "خالد إبراهيم", nameEn: "Khaled Ibrahim" },
  { id: 4, name: "نورة سالم", nameEn: "Noura Salem" },
  { id: 5, name: "عبدالله حسن", nameEn: "Abdullah Hassan" },
  { id: 6, name: "مريم يوسف", nameEn: "Mariam Youssef" },
  { id: 7, name: "سعود عبدالعزيز", nameEn: "Saud Abdulaziz" },
  { id: 8, name: "هند خالد", nameEn: "Hind Khaled" },
  { id: 9, name: "ياسر عمر", nameEn: "Yasser Omar" },
  { id: 10, name: "ليلى أحمد", nameEn: "Layla Ahmed" },
  { id: 11, name: "محمد سعيد", nameEn: "Mohammed Saeed" },
]

export default function DashboardPage() {
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set())

  const handleToggle = (id: number) => {
    setSelectedIds((prev) => {
      const next = new Set(prev)
      if (next.has(id)) {
        next.delete(id)
      } else {
        next.add(id)
      }
      return next
    })
  }

  return (
    <main className="flex min-h-svh flex-col bg-[#F8FAFC]">
      <DashboardHeader customerCount={SAMPLE_CUSTOMERS.length} />
      <CentralBanner />
      <CustomerGrid
        customers={SAMPLE_CUSTOMERS}
        selectedIds={selectedIds}
        onToggle={handleToggle}
      />
    </main>
  )
}

"use client"

import { useRouter } from "next/navigation"
import { Checkbox } from "@/components/ui/checkbox"
import { useLang } from "@/lib/language-context"

export interface Customer {
  id: number
  name: string
  nameEn?: string
}

interface CustomerCardProps {
  customer: Customer
  isSelected: boolean
  onToggle: (id: number) => void
}

function getInitial(name: string): string {
  return name.charAt(0)
}

export function CustomerCard({ customer, isSelected, onToggle }: CustomerCardProps) {
  const router = useRouter()
  const { lang } = useLang()

  const handleCardClick = () => {
    router.push("/customer/transactions")
  }

  const displayName = lang === "en" && customer.nameEn ? customer.nameEn : customer.name

  return (
    <div
      onClick={handleCardClick}
      className={`group relative flex cursor-pointer flex-col overflow-hidden rounded-xl border bg-[#ffffff] transition-all duration-200 ${
        isSelected
          ? "border-[#2563EB] shadow-lg shadow-[#2563EB]/15"
          : "border-[#E2E8F0] shadow-sm hover:border-[#2563EB]/40 hover:shadow-md"
      }`}
    >
      {/* Card header */}
      <div className="relative flex items-center justify-center bg-[#F8FAFC] px-4 pb-3 pt-5">
        <div className="absolute top-2.5 right-2.5" onClick={(e) => e.stopPropagation()}>
          <Checkbox
            checked={isSelected}
            onCheckedChange={() => onToggle(customer.id)}
            aria-label={`Select ${displayName}`}
            className="size-4 border-2 border-[#CBD5E1] data-[state=checked]:bg-[#2563EB] data-[state=checked]:border-[#2563EB]"
          />
        </div>
        <div className="flex size-14 items-center justify-center rounded-full bg-[#2563EB] shadow-md shadow-[#2563EB]/25 ring-3 ring-[#ffffff]">
          <span className="text-lg font-bold text-[#ffffff]">
            {getInitial(displayName)}
          </span>
        </div>
      </div>

      {/* Card body */}
      <div className="flex flex-col items-center gap-2 px-3 pb-4 pt-3">
        <p className="text-center text-base font-medium text-[#000000]">
          {displayName}
        </p>
        <span className="rounded-md bg-[#EFF6FF] px-3 py-1 text-xs font-medium tabular-nums text-[#2563EB]">
          ID: {customer.id}
        </span>
      </div>
    </div>
  )
}

interface CustomerGridProps {
  customers: Customer[]
  selectedIds: Set<number>
  onToggle: (id: number) => void
}

export function CustomerGrid({ customers, selectedIds, onToggle }: CustomerGridProps) {
  const { t } = useLang()

  return (
    <section className="px-6 py-8">
      <div className="mb-6 flex items-center gap-3">
        <div className="h-7 w-1 rounded-full bg-[#2563EB]" />
        <h3 className="text-xl font-semibold text-[#000000]">
          {t("dashboard.customerList")}
        </h3>
      </div>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6">
        {customers.map((customer) => (
          <CustomerCard
            key={customer.id}
            customer={customer}
            isSelected={selectedIds.has(customer.id)}
            onToggle={onToggle}
          />
        ))}
      </div>
    </section>
  )
}

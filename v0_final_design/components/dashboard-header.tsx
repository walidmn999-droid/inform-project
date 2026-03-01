"use client"

import { useRouter } from "next/navigation"
import { Users, LogOut, Trash2, Pencil, UserPlus, Globe } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useLang } from "@/lib/language-context"

interface DashboardHeaderProps {
  customerCount: number
  onAddCustomer?: () => void
  onEditCustomer?: () => void
  onDeleteCustomer?: () => void
}

export function DashboardHeader({
  customerCount,
  onAddCustomer,
  onEditCustomer,
  onDeleteCustomer,
}: DashboardHeaderProps) {
  const { t, lang, toggleLang } = useLang()
  const router = useRouter()

  return (
    <header className="flex flex-wrap items-center justify-between gap-4 bg-[#ffffff] px-6 py-3 shadow-sm">
      {/* Right side - Title and counter */}
      <div className="flex items-center gap-3">
        <div className="flex size-10 items-center justify-center rounded-lg bg-[#2563EB] shadow-sm shadow-[#2563EB]/20">
          <Users className="size-5 text-[#ffffff]" />
        </div>
        <div className="flex items-center gap-2">
          <h1 className="text-xl font-semibold text-[#000000]">
            {t("dashboard.title")}
          </h1>
          <span className="rounded-md bg-[#EFF6FF] px-2.5 py-0.5 text-sm font-medium tabular-nums text-[#2563EB]">
            {customerCount} {t("dashboard.customer")}
          </span>
        </div>
      </div>

      {/* Left side - Action buttons + lang toggle */}
      <div className="flex flex-wrap items-center gap-2">
        <Button
          onClick={onAddCustomer}
          className="h-9 gap-2 rounded-lg bg-[#16A34A] px-4 text-[#ffffff] text-sm font-medium shadow-sm transition-all duration-200 hover:bg-[#15803D]"
        >
          <UserPlus className="size-4" />
          {t("dashboard.addCustomer")}
        </Button>
        <Button
          onClick={onEditCustomer}
          className="h-9 gap-2 rounded-lg bg-[#2563EB] px-4 text-[#ffffff] text-sm font-medium shadow-sm transition-all duration-200 hover:bg-[#1D4ED8]"
        >
          <Pencil className="size-4" />
          {t("dashboard.editCustomer")}
        </Button>
        <Button
          onClick={onDeleteCustomer}
          variant="outline"
          className="h-9 gap-2 rounded-lg border-[#EF4444]/30 px-4 text-sm font-medium text-[#EF4444] transition-all duration-200 hover:bg-[#EF4444] hover:text-[#ffffff]"
        >
          <Trash2 className="size-4" />
          {t("dashboard.deleteCustomer")}
        </Button>

        {/* Separator */}
        <div className="mx-1 h-6 w-px bg-[#E2E8F0]" />

        {/* Language toggle */}
        <button
          onClick={toggleLang}
          className="flex h-9 items-center gap-1.5 rounded-lg border border-[#E2E8F0] bg-[#F8FAFC] px-3 text-sm font-medium text-[#000000] transition-all hover:bg-[#EFF6FF] hover:border-[#2563EB]/30"
        >
          <Globe className="size-3.5" />
          {lang === "ar" ? "EN" : "عربي"}
        </button>

        {/* Logout */}
        <Button
          onClick={() => router.push("/")}
          className="h-9 gap-2 rounded-lg bg-[#2B6CB0] px-4 text-[#ffffff] text-sm font-medium shadow-sm transition-all duration-200 hover:bg-[#1E5A8A]"
        >
          <LogOut className="size-4" />
          {t("dashboard.logout")}
        </Button>
      </div>
    </header>
  )
}

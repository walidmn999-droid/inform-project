"use client"

import { useRouter, usePathname } from "next/navigation"
import {
  Home,
  Upload,
  Trash2,
  FileText,
  BarChart3,
  Settings,
  LogOut,
} from "lucide-react"
import { cn } from "@/lib/utils"
import { useLang } from "@/lib/language-context"

interface SidebarItem {
  labelKey: string
  icon: React.ElementType
  href?: string
  action?: string
}

const sidebarItems: SidebarItem[] = [
  { labelKey: "sidebar.home", icon: Home, href: "/dashboard" },
  { labelKey: "sidebar.uploadAttachments", icon: Upload, href: "#" },
  { labelKey: "sidebar.deleteAttachments", icon: Trash2, href: "#" },
  { labelKey: "sidebar.invoices", icon: FileText, href: "#" },
  { labelKey: "sidebar.reports", icon: BarChart3, href: "#" },
  { labelKey: "sidebar.settings", icon: Settings, href: "#" },
  { labelKey: "sidebar.logout", icon: LogOut, action: "logout" },
]

export function AppSidebar() {
  const router = useRouter()
  const pathname = usePathname()
  const { t, lang, toggleLang } = useLang()

  const handleClick = (item: SidebarItem) => {
    if (item.action === "logout") {
      router.push("/")
      return
    }
    if (item.href && item.href !== "#") {
      router.push(item.href)
    }
  }

  return (
    <aside className="flex h-svh w-60 shrink-0 flex-col bg-[#2B6CB0] shadow-xl">
      {/* Logo section */}
      <div className="flex flex-col items-center gap-1 border-b border-[#ffffff]/15 px-4 py-5">
        <div className="flex size-12 items-center justify-center rounded-xl bg-[#2563EB] shadow-lg shadow-[#2563EB]/30">
          <span className="text-xl font-black text-[#ffffff]">EN</span>
        </div>
        <span className="mt-2 text-xs font-bold tracking-widest text-[#ffffff]/90" dir="ltr">
          INFORM TYPING
        </span>
        <span className="text-[10px] font-medium text-[#93B5D3]">
          {t("sidebar.brand")}
        </span>
      </div>

      {/* Language toggle */}
      <div className="border-b border-[#ffffff]/15 px-3 py-3">
        <button
          onClick={toggleLang}
          className="flex w-full items-center justify-center gap-2 rounded-lg bg-[#1E5A8A] px-3 py-2 text-xs font-bold text-[#ffffff] transition-all hover:bg-[#2563EB]"
        >
          <span className={cn("rounded px-2 py-0.5 transition-all", lang === "ar" ? "bg-[#2563EB] text-[#ffffff]" : "text-[#93B5D3]")}>
            عربي
          </span>
          <span className="text-[#4B7399]">/</span>
          <span className={cn("rounded px-2 py-0.5 transition-all", lang === "en" ? "bg-[#2563EB] text-[#ffffff]" : "text-[#93B5D3]")}>
            EN
          </span>
        </button>
      </div>

      {/* Navigation items */}
      <nav className="flex flex-1 flex-col gap-1 px-3 py-4">
        {sidebarItems.map((item) => {
          const isActive =
            item.href && item.href !== "#" && pathname === item.href
          const isLogout = item.action === "logout"
          const Icon = item.icon

          return (
            <button
              key={item.labelKey}
              onClick={() => handleClick(item)}
              className={cn(
                "flex items-center gap-3 rounded-lg px-4 py-2.5 text-[15px] font-medium transition-all duration-200",
                isActive
                  ? "bg-[#2563EB] text-[#ffffff] shadow-md shadow-[#2563EB]/30"
                  : "text-[#B0CDE4] hover:bg-[#1E5A8A] hover:text-[#ffffff]",
                isLogout && "mt-auto text-[#B0CDE4] hover:bg-[#DC2626]/15 hover:text-[#EF4444]"
              )}
            >
              <Icon className="size-[18px] shrink-0" />
              <span>{t(item.labelKey)}</span>
            </button>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="border-t border-[#ffffff]/15 px-4 py-3">
        <p className="text-center text-[10px] font-medium text-[#7BA3C4]">
          {"v1.0.0 - inform typing"}
        </p>
      </div>
    </aside>
  )
}

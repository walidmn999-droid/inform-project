"use client"

import { Globe } from "lucide-react"
import { BrandingPanel } from "@/components/branding-panel"
import { LoginForm } from "@/components/login-form"
import { useLang } from "@/lib/language-context"

export default function LoginPage() {
  const { t, lang, toggleLang } = useLang()

  return (
    <main className="flex min-h-svh flex-row-reverse">
      {/* Right panel - Royal Blue branding with contact info */}
      <div className="hidden w-1/2 lg:block">
        <BrandingPanel />
      </div>

      {/* Left panel - White login form */}
      <div className="relative flex w-full flex-col items-center justify-center bg-card px-6 py-12 lg:w-1/2">
        {/* Language toggle - top corner */}
        <button
          onClick={toggleLang}
          className="absolute top-4 left-4 flex items-center gap-1.5 rounded-lg border border-[#E2E8F0] bg-[#F8FAFC] px-3 py-2 text-xs font-bold text-[#334155] transition-all hover:bg-[#EFF6FF] hover:border-[#2563EB]/30"
        >
          <Globe className="size-3.5" />
          {lang === "ar" ? "EN" : "عربي"}
        </button>

        <div className="w-full max-w-md">
          {/* Mobile header */}
          <div className="mb-8 flex flex-col items-center gap-3 lg:hidden">
            <div className="flex size-14 items-center justify-center rounded-xl bg-[#2563EB]">
              <span className="text-xl font-bold text-[#ffffff]">i</span>
            </div>
            <p className="text-sm font-medium text-muted-foreground">
              inform typing photo copy
            </p>
          </div>

          {/* Title */}
          <div className="mb-10 flex flex-col gap-3 text-center lg:text-right">
            <h2 className="text-balance text-2xl font-bold leading-snug tracking-tight text-foreground">
              {t("login.title.en")}
            </h2>
            <h3 className="text-balance text-xl font-semibold leading-snug text-foreground/80">
              {t("login.title.ar")}
            </h3>
            <div className="mx-auto h-px w-16 bg-border lg:mx-0 lg:mr-0" />
            <p className="text-lg font-medium text-primary">
              {t("login.subtitle")}
            </p>
          </div>

          {/* Login form */}
          <LoginForm />

          {/* Mobile contact info */}
          <div className="mt-10 flex flex-col items-center gap-3 text-center lg:hidden" dir="ltr">
            <div className="h-px w-full bg-border" />
            <div className="flex flex-col gap-1.5 pt-2">
              <p className="text-xs text-muted-foreground">971 528047909 / 97155642850</p>
              <p className="text-xs text-muted-foreground">info@informtyping.com</p>
              <p className="text-xs text-muted-foreground">informtyping.com</p>
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}

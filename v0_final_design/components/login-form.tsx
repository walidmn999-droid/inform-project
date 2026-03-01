"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Eye, EyeOff, Loader2, Mail, Lock } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { useLang } from "@/lib/language-context"

export function LoginForm() {
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const router = useRouter()
  const { t } = useLang()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    await new Promise((resolve) => setTimeout(resolve, 1500))
    setIsLoading(false)
    router.push("/dashboard")
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-6">
      {/* Email field */}
      <div className="flex flex-col gap-2.5">
        <Label htmlFor="email" className="text-sm font-medium text-foreground">
          {t("login.email")}
        </Label>
        <div className="relative">
          <Mail className="pointer-events-none absolute right-4 top-1/2 size-[18px] -translate-y-1/2 text-muted-foreground/50" />
          <Input
            id="email"
            type="email"
            placeholder={t("login.email.placeholder")}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="h-12 rounded-lg border-border/60 bg-secondary/50 pr-11 pl-4 text-foreground placeholder:text-muted-foreground/50 focus-visible:border-primary focus-visible:ring-primary/20 focus-visible:bg-card"
          />
        </div>
      </div>

      {/* Password field */}
      <div className="flex flex-col gap-2.5">
        <Label htmlFor="password" className="text-sm font-medium text-foreground">
          {t("login.password")}
        </Label>
        <div className="relative">
          <Lock className="pointer-events-none absolute right-4 top-1/2 size-[18px] -translate-y-1/2 text-muted-foreground/50" />
          <Input
            id="password"
            type={showPassword ? "text" : "password"}
            placeholder={t("login.password.placeholder")}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="h-12 rounded-lg border-border/60 bg-secondary/50 pr-11 pl-12 text-foreground placeholder:text-muted-foreground/50 focus-visible:border-primary focus-visible:ring-primary/20 focus-visible:bg-card"
          />
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground/50 transition-colors hover:text-foreground"
            aria-label={showPassword ? "Hide password" : "Show password"}
          >
            {showPassword ? (
              <EyeOff className="size-[18px]" />
            ) : (
              <Eye className="size-[18px]" />
            )}
          </button>
        </div>
      </div>

      {/* Login button */}
      <Button
        type="submit"
        disabled={isLoading}
        className="h-12 w-full rounded-lg bg-[#2563EB] text-[#ffffff] text-base font-semibold shadow-md transition-all hover:bg-[#1d4ed8] hover:shadow-lg disabled:opacity-70"
        size="lg"
      >
        {isLoading ? (
          <>
            <Loader2 className="size-5 animate-spin" />
            <span>{t("login.loading")}</span>
          </>
        ) : (
          t("login.submit")
        )}
      </Button>

      {/* Links */}
      <div className="flex items-center justify-between">
        <a
          href="#"
          className="text-sm font-medium text-primary transition-colors hover:text-primary/80"
        >
          {t("login.forgot")}
        </a>
        <a
          href="#"
          className="text-sm font-medium text-primary transition-colors hover:text-primary/80"
        >
          {t("login.create")}
        </a>
      </div>
    </form>
  )
}

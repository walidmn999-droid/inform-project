"use client"

import { useEffect } from "react"
import { useLang } from "@/lib/language-context"

export function LanguageHtmlUpdater() {
  const { lang, dir } = useLang()

  useEffect(() => {
    document.documentElement.lang = lang
    document.documentElement.dir = dir
  }, [lang, dir])

  return null
}

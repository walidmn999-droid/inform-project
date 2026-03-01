"use client"

import { createContext, useContext, useState, useCallback, type ReactNode } from "react"

export type Lang = "ar" | "en"

interface LanguageContextValue {
  lang: Lang
  toggleLang: () => void
  t: (key: string) => string
  dir: "rtl" | "ltr"
  formatCurrency: (amount: number) => string
}

/* ---------- Translations ---------- */
const translations: Record<string, Record<Lang, string>> = {
  // Login
  "login.title.en": { ar: "inform typing photo copy", en: "inform typing photo copy" },
  "login.title.ar": { ar: "إنفورم للطباعة والتصوير", en: "Inform Typing & Photo Copy" },
  "login.subtitle": { ar: "تسجيل الدخول", en: "Sign In" },
  "login.email": { ar: "البريد الإلكتروني", en: "Email" },
  "login.email.placeholder": { ar: "أدخل البريد الإلكتروني", en: "Enter your email" },
  "login.password": { ar: "كلمة المرور", en: "Password" },
  "login.password.placeholder": { ar: "أدخل كلمة المرور", en: "Enter your password" },
  "login.submit": { ar: "تسجيل الدخول", en: "Sign In" },
  "login.loading": { ar: "جاري تسجيل الدخول...", en: "Signing in..." },
  "login.forgot": { ar: "نسيت الباسوورد", en: "Forgot Password" },
  "login.create": { ar: "انشاء حساب", en: "Create Account" },

  // Dashboard
  "dashboard.title": { ar: "إدارة العملاء", en: "Customer Management" },
  "dashboard.customer": { ar: "عميل", en: "Customers" },
  "dashboard.addCustomer": { ar: "إضافة عميل", en: "Add Customer" },
  "dashboard.editCustomer": { ar: "تعديل عميل", en: "Edit Customer" },
  "dashboard.deleteCustomer": { ar: "حذف عميل", en: "Delete Customer" },
  "dashboard.logout": { ar: "تسجيل الخروج", en: "Sign Out" },
  "dashboard.customerList": { ar: "قائمة العملاء", en: "Customer List" },

  // Sidebar
  "sidebar.home": { ar: "الرئيسية", en: "Home" },
  "sidebar.uploadAttachments": { ar: "تحميل المرفقات", en: "Upload Files" },
  "sidebar.deleteAttachments": { ar: "حذف المرفقات", en: "Delete Files" },
  "sidebar.invoices": { ar: "الفواتير", en: "Invoices" },
  "sidebar.reports": { ar: "التقارير", en: "Reports" },
  "sidebar.settings": { ar: "الاعدادات", en: "Settings" },
  "sidebar.logout": { ar: "تسجيل الخروج", en: "Sign Out" },
  "sidebar.brand": { ar: "إنفورم للطباعة والتصوير", en: "Inform Typing & Photo Copy" },

  // Transactions
  "tx.title": { ar: "معاملات العميل", en: "Customer Transactions" },
  "tx.addTx": { ar: "إضافة معاملة", en: "Add Transaction" },
  "tx.editTx": { ar: "تعديل معاملة", en: "Edit Transaction" },
  "tx.deleteTx": { ar: "حذف معاملة", en: "Delete Transaction" },
  "tx.status": { ar: "الحالة", en: "Status" },
  "tx.service": { ar: "بند الخدمة", en: "Service" },
  "tx.qty": { ar: "العدد", en: "Qty" },
  "tx.unitPrice": { ar: "سعر الوحدة", en: "Unit Price" },
  "tx.total": { ar: "الإجمالي", en: "Total" },
  "tx.company": { ar: "اسم الشركة", en: "Company" },
  "tx.employee": { ar: "اسم الموظف", en: "Employee" },
  "tx.attachments": { ar: "المرفقات", en: "Files" },
  "tx.invoice": { ar: "فاتورة:", en: "Invoice:" },
  "tx.date": { ar: "التاريخ:", en: "Date:" },
  "tx.statusLabel": { ar: "الحالة:", en: "Status:" },
  "tx.grandTotal": { ar: "الإجمالي:", en: "Total:" },
  "tx.completed": { ar: "مكتمل", en: "Completed" },
  "tx.pending": { ar: "قيد التنفيذ", en: "Pending" },
  "tx.cancelled": { ar: "ملغي", en: "Cancelled" },

  // Add Transaction
  "addTx.title": { ar: "إضافة معاملة", en: "Add Transaction" },
  "addTx.invoiceNumber": { ar: "رقم الفاتورة", en: "Invoice Number" },
  "addTx.items": { ar: "بنود المعاملة", en: "Transaction Items" },
  "addTx.addItem": { ar: "إضافة بند", en: "Add Item" },
  "addTx.addNewItem": { ar: "إضافة بند جديد", en: "Add New Item" },
  "addTx.deleteItem": { ar: "حذف", en: "Delete" },
  "addTx.itemNumber": { ar: "بند", en: "Item" },
  "addTx.serviceType": { ar: "نوع الخدمة", en: "Service Type" },
  "addTx.servicePlaceholder": { ar: "مثال: طباعة", en: "e.g. Printing" },
  "addTx.date": { ar: "التاريخ", en: "Date" },
  "addTx.company": { ar: "الشركة", en: "Company" },
  "addTx.employee": { ar: "الموظف", en: "Employee" },
  "addTx.employeePlaceholder": { ar: "اختياري", en: "Optional" },
  "addTx.qty": { ar: "العدد", en: "Qty" },
  "addTx.unitPrice": { ar: "سعر الوحدة", en: "Unit Price" },
  "addTx.discount": { ar: "الخصم", en: "Discount" },
  "addTx.benefit": { ar: "الفائدة", en: "Benefit" },
  "addTx.total": { ar: "الإجمالي", en: "Total" },
  "addTx.attachments": { ar: "المرفقات", en: "Attachments" },
  "addTx.save": { ar: "حفظ", en: "Save" },
  "addTx.cancel": { ar: "إلغاء", en: "Cancel" },
  "addTx.grandTotal": { ar: "الإجمالي:", en: "Total:" },

  // Currency
  "currency": { ar: "د.إ", en: "AED" },
}

const LanguageContext = createContext<LanguageContextValue | null>(null)

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [lang, setLang] = useState<Lang>("ar")

  const toggleLang = useCallback(() => {
    setLang((prev) => (prev === "ar" ? "en" : "ar"))
  }, [])

  const t = useCallback(
    (key: string): string => {
      return translations[key]?.[lang] ?? key
    },
    [lang]
  )

  const dir = lang === "ar" ? "rtl" : "ltr"

  const formatCurrency = useCallback(
    (amount: number): string => {
      const formatted = amount.toLocaleString("en-US", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      })
      return lang === "ar" ? `${formatted} د.إ` : `AED ${formatted}`
    },
    [lang]
  )

  return (
    <LanguageContext.Provider value={{ lang, toggleLang, t, dir, formatCurrency }}>
      {children}
    </LanguageContext.Provider>
  )
}

export function useLang() {
  const ctx = useContext(LanguageContext)
  if (!ctx) throw new Error("useLang must be used within LanguageProvider")
  return ctx
}

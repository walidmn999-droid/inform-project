"use client"

import { AppSidebar } from "@/components/app-sidebar"
import { AddTransactionForm } from "@/components/add-transaction-form"

export default function AddTransactionPage() {
  return (
    <div className="flex h-svh bg-[#F8FAFC]">
      <AppSidebar />
      <div className="flex flex-1 flex-col overflow-hidden">
        <AddTransactionForm />
      </div>
    </div>
  )
}

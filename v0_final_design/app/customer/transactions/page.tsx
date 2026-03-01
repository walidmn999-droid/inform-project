"use client"

import { AppSidebar } from "@/components/app-sidebar"
import {
  TransactionsTable,
  type Transaction,
} from "@/components/transactions-table"

/* ---------- Sample data ---------- */
const SAMPLE_TRANSACTIONS: Transaction[] = [
  {
    invoiceNumber: "INV-2024-001",
    date: "2024-12-15",
    status: "مكتمل",
    grandTotal: 1850,
    items: [
      {
        service: "طباعة مستندات A4",
        serviceEn: "A4 Document Printing",
        qty: 500,
        unitPrice: 1,
        total: 500,
        company: "شركة النور للتجارة",
        companyEn: "Al Noor Trading Co.",
        employee: "أحمد محمد",
        employeeEn: "Ahmed Mohammed",
        hasAttachment: true,
      },
      {
        service: "تصوير ملون A3",
        serviceEn: "A3 Color Copy",
        qty: 200,
        unitPrice: 3,
        total: 600,
        company: "شركة النور للتجارة",
        companyEn: "Al Noor Trading Co.",
        employee: "أحمد محمد",
        employeeEn: "Ahmed Mohammed",
        hasAttachment: false,
      },
      {
        service: "تجليد مستندات",
        serviceEn: "Document Binding",
        qty: 50,
        unitPrice: 15,
        total: 750,
        company: "شركة النور للتجارة",
        companyEn: "Al Noor Trading Co.",
        employee: "فاطمة علي",
        employeeEn: "Fatima Ali",
        hasAttachment: true,
      },
    ],
  },
  {
    invoiceNumber: "INV-2024-002",
    date: "2024-12-18",
    status: "قيد التنفيذ",
    grandTotal: 3200,
    items: [
      {
        service: "طباعة بروشورات",
        serviceEn: "Brochure Printing",
        qty: 1000,
        unitPrice: 2,
        total: 2000,
        company: "مؤسسة الخليج",
        companyEn: "Gulf Foundation",
        employee: "خالد إبراهيم",
        employeeEn: "Khaled Ibrahim",
        hasAttachment: true,
      },
      {
        service: "تصميم شعار",
        serviceEn: "Logo Design",
        qty: 1,
        unitPrice: 500,
        total: 500,
        company: "مؤسسة الخليج",
        companyEn: "Gulf Foundation",
        employee: "نورة سالم",
        employeeEn: "Noura Salem",
        hasAttachment: false,
      },
      {
        service: "طباعة كروت شخصية",
        serviceEn: "Business Card Printing",
        qty: 200,
        unitPrice: 3.5,
        total: 700,
        company: "مؤسسة الخليج",
        companyEn: "Gulf Foundation",
        employee: "خالد إبراهيم",
        employeeEn: "Khaled Ibrahim",
        hasAttachment: true,
      },
    ],
  },
  {
    invoiceNumber: "INV-2024-003",
    date: "2024-12-20",
    status: "ملغي",
    grandTotal: 450,
    items: [
      {
        service: "تصوير مستندات",
        serviceEn: "Document Copying",
        qty: 150,
        unitPrice: 1.5,
        total: 225,
        company: "شركة الأمل العقارية",
        companyEn: "Al Amal Real Estate",
        employee: "ياسر عمر",
        employeeEn: "Yasser Omar",
        hasAttachment: false,
      },
      {
        service: "لمينيشن A4",
        serviceEn: "A4 Lamination",
        qty: 50,
        unitPrice: 4.5,
        total: 225,
        company: "شركة الأمل العقارية",
        companyEn: "Al Amal Real Estate",
        employee: "ياسر عمر",
        employeeEn: "Yasser Omar",
        hasAttachment: false,
      },
    ],
  },
  {
    invoiceNumber: "INV-2024-004",
    date: "2024-12-22",
    status: "مكتمل",
    grandTotal: 5750,
    items: [
      {
        service: "طباعة لوحات إعلانية",
        serviceEn: "Billboard Printing",
        qty: 10,
        unitPrice: 350,
        total: 3500,
        company: "شركة الصقر للمقاولات",
        companyEn: "Al Saqr Contracting",
        employee: "عبدالله حسن",
        employeeEn: "Abdullah Hassan",
        hasAttachment: true,
      },
      {
        service: "طباعة ستيكرات",
        serviceEn: "Sticker Printing",
        qty: 500,
        unitPrice: 2.5,
        total: 1250,
        company: "شركة الصقر للمقاولات",
        companyEn: "Al Saqr Contracting",
        employee: "مريم يوسف",
        employeeEn: "Mariam Youssef",
        hasAttachment: true,
      },
      {
        service: "تصوير مخططات هندسية",
        serviceEn: "Engineering Plan Copying",
        qty: 20,
        unitPrice: 25,
        total: 500,
        company: "شركة الصقر للمقاولات",
        companyEn: "Al Saqr Contracting",
        employee: "عبدالله حسن",
        employeeEn: "Abdullah Hassan",
        hasAttachment: false,
      },
      {
        service: "طباعة أظرف رسمية",
        serviceEn: "Official Envelope Printing",
        qty: 200,
        unitPrice: 2.5,
        total: 500,
        company: "شركة الصقر للمقاولات",
        companyEn: "Al Saqr Contracting",
        employee: "مريم يوسف",
        employeeEn: "Mariam Youssef",
        hasAttachment: true,
      },
    ],
  },
  {
    invoiceNumber: "INV-2024-005",
    date: "2024-12-25",
    status: "قيد التنفيذ",
    grandTotal: 1200,
    items: [
      {
        service: "طباعة تقارير مالية",
        serviceEn: "Financial Report Printing",
        qty: 100,
        unitPrice: 5,
        total: 500,
        company: "بنك الاتحاد الوطني",
        companyEn: "National Union Bank",
        employee: "سعود عبدالعزيز",
        employeeEn: "Saud Abdulaziz",
        hasAttachment: true,
      },
      {
        service: "تجليد فاخر",
        serviceEn: "Premium Binding",
        qty: 20,
        unitPrice: 35,
        total: 700,
        company: "بنك الاتحاد الوطني",
        companyEn: "National Union Bank",
        employee: "هند خالد",
        employeeEn: "Hind Khaled",
        hasAttachment: false,
      },
    ],
  },
]

export default function CustomerTransactionsPage() {
  return (
    <div className="flex h-svh bg-[#F8FAFC]">
      <AppSidebar />
      <div className="flex flex-1 flex-col overflow-hidden">
        <TransactionsTable
          transactions={SAMPLE_TRANSACTIONS}
          customerName="أحمد محمد"
        />
      </div>
    </div>
  )
}

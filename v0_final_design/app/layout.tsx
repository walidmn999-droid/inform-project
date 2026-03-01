import type { Metadata } from 'next'
import { Inter, Cairo } from 'next/font/google'
import { Analytics } from '@vercel/analytics/next'
import { LanguageProvider } from '@/lib/language-context'
import { LanguageHtmlUpdater } from '@/components/language-html-updater'
import './globals.css'

const _inter = Inter({ subsets: ["latin"] });
const _cairo = Cairo({ subsets: ["arabic", "latin"] });

export const metadata: Metadata = {
  title: 'inform typing photo copy - إنفورم للطباعة والتصوير',
  description: 'إنفورم للطباعة والتصوير - نظام إدارة العملاء',
  generator: 'v0.app',
  icons: {
    icon: [
      {
        url: '/icon-light-32x32.png',
        media: '(prefers-color-scheme: light)',
      },
      {
        url: '/icon-dark-32x32.png',
        media: '(prefers-color-scheme: dark)',
      },
      {
        url: '/icon.svg',
        type: 'image/svg+xml',
      },
    ],
    apple: '/apple-icon.png',
  },
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="ar" dir="rtl" suppressHydrationWarning>
      <body className="font-sans antialiased">
        <LanguageProvider>
          <LanguageHtmlUpdater />
          {children}
        </LanguageProvider>
        <Analytics />
      </body>
    </html>
  )
}

import { Phone, Mail, Globe } from "lucide-react"

export function BrandingPanel() {
  return (
    <div className="relative flex h-full flex-col items-center justify-center overflow-hidden bg-[#2563EB] p-12 text-[#ffffff]">
      {/* Subtle background pattern */}
      <div className="pointer-events-none absolute inset-0 opacity-[0.05]">
        <svg className="h-full w-full" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern
              id="grid"
              width="48"
              height="48"
              patternUnits="userSpaceOnUse"
            >
              <path
                d="M 48 0 L 0 0 0 48"
                fill="none"
                stroke="currentColor"
                strokeWidth="1"
              />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#grid)" />
        </svg>
      </div>

      {/* Decorative circles */}
      <div className="pointer-events-none absolute -top-24 -left-24 size-64 rounded-full bg-[#ffffff]/[0.04]" />
      <div className="pointer-events-none absolute -bottom-32 -right-32 size-80 rounded-full bg-[#ffffff]/[0.03]" />

      {/* Content */}
      <div className="relative z-10 flex flex-col items-center gap-10 text-center" dir="ltr">
        {/* Logo / Title */}
        <div className="flex flex-col items-center gap-4">
          <div className="flex size-16 items-center justify-center rounded-2xl bg-[#ffffff]/15 backdrop-blur-sm">
            <span className="text-2xl font-bold text-[#ffffff]">i</span>
          </div>
          <div className="flex flex-col items-center gap-1">
            <h1 className="text-2xl font-bold tracking-tight text-[#ffffff]">inform typing</h1>
            <p className="text-sm font-medium text-[#ffffff]/70">photo copy</p>
          </div>
        </div>

        {/* Divider */}
        <div className="h-px w-24 bg-[#ffffff]/20" />

        {/* Contact Details */}
        <div className="flex flex-col gap-6">
          {/* Phone numbers */}
          <div className="flex flex-col items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-[#ffffff]/10">
              <Phone className="size-5 text-[#ffffff]/80" />
            </div>
            <div className="flex flex-col items-center gap-1.5">
              <a
                href="tel:971528047909"
                className="text-sm font-medium text-[#ffffff]/90 transition-colors hover:text-[#ffffff]"
              >
                971 528047909
              </a>
              <a
                href="tel:97155642850"
                className="text-sm font-medium text-[#ffffff]/90 transition-colors hover:text-[#ffffff]"
              >
                97155642850
              </a>
            </div>
          </div>

          {/* Email */}
          <div className="flex flex-col items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-[#ffffff]/10">
              <Mail className="size-5 text-[#ffffff]/80" />
            </div>
            <a
              href="mailto:info@informtyping.com"
              className="text-sm font-medium text-[#ffffff]/90 transition-colors hover:text-[#ffffff]"
            >
              info@informtyping.com
            </a>
          </div>

          {/* Website */}
          <div className="flex flex-col items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-[#ffffff]/10">
              <Globe className="size-5 text-[#ffffff]/80" />
            </div>
            <a
              href="https://informtyping.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm font-medium text-[#ffffff]/90 transition-colors hover:text-[#ffffff]"
            >
              informtyping.com
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

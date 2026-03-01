import { Printer } from "lucide-react"

export function CentralBanner() {
  return (
    <div className="relative overflow-hidden bg-gradient-to-l from-[#1E5A8A] via-[#2B6CB0] to-[#2563EB] px-6 py-10" dir="ltr">
      {/* Decorative glow */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_center,_rgba(37,99,235,0.15)_0%,_transparent_70%)]" />

      {/* Content */}
      <div className="relative z-10 flex items-center justify-center gap-8">
        {/* Left printer icon */}
        <div className="flex size-16 shrink-0 items-center justify-center rounded-2xl bg-[#ffffff]/10 shadow-lg shadow-[#000000]/10 backdrop-blur-sm">
          <Printer className="size-8 text-[#ffffff]/90" />
        </div>

        {/* Title */}
        <h2 className="text-center text-3xl font-black tracking-widest text-[#ffffff] drop-shadow-md sm:text-4xl lg:text-5xl">
          INFORM TYPING PHOTO COPY
        </h2>

        {/* Right printer icon */}
        <div className="flex size-16 shrink-0 items-center justify-center rounded-2xl bg-[#ffffff]/10 shadow-lg shadow-[#000000]/10 backdrop-blur-sm">
          <Printer className="size-8 text-[#ffffff]/90" />
        </div>
      </div>
    </div>
  )
}

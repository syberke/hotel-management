import { cn, getStatusColor } from "@/lib/utils";

interface BadgeProps {
  status: string;
  className?: string;
}

export function Badge({ status, className }: BadgeProps) {
  const label = status.replace(/_/g, " ");
  return (
    <span
      className={cn(
        "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold",
        getStatusColor(status),
        className,
      )}
    >
      {label}
    </span>
  );
}

import { cn } from "@/lib/utils";

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  trend?: { value: number; label: string };
  color?: "blue" | "green" | "orange" | "purple" | "gold" | "red";
}

const colorMap = {
  blue: "from-blue-500 to-blue-600 shadow-blue-500/25",
  green: "from-green-500 to-green-600 shadow-green-500/25",
  orange: "from-orange-500 to-orange-600 shadow-orange-500/25",
  purple: "from-purple-500 to-purple-600 shadow-purple-500/25",
  gold: "from-gold-500 to-gold-600 shadow-gold-500/25",
  red: "from-red-500 to-red-600 shadow-red-500/25",
};

export function StatCard({
  title,
  value,
  icon,
  trend,
  color = "blue",
}: StatCardProps) {
  return (
    <div className="card hover:shadow-md transition-shadow duration-200">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-500">{title}</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">{value}</p>
          {trend && (
            <div className="mt-2 flex items-center gap-1">
              <span
                className={cn(
                  "text-xs font-semibold",
                  trend.value >= 0 ? "text-green-600" : "text-red-600",
                )}
              >
                {trend.value >= 0 ? "↑" : "↓"} {Math.abs(trend.value)}%
              </span>
              <span className="text-xs text-gray-500">{trend.label}</span>
            </div>
          )}
        </div>
        <div
          className={cn(
            "w-12 h-12 rounded-xl bg-gradient-to-br flex items-center justify-center text-white shadow-lg",
            colorMap[color],
          )}
        >
          {icon}
        </div>
      </div>
    </div>
  );
}

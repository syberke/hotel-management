"use client";

import { useEffect, useState } from "react";
import { formatCurrency } from "@/lib/utils";
import { DataTable } from "@/components/DataTable";
import { Badge } from "@/components/Badge";
import { Modal } from "@/components/Modal";
import { HiOutlinePlus, HiOutlineShoppingCart } from "react-icons/hi2";
import { toast } from "sonner";

interface MenuItem {
  id: string;
  name: string;
  category: string;
  price: number;
  description: string | null;
  isAvailable: boolean;
  image: string | null;
}

interface CartItem extends MenuItem {
  quantity: number;
}

export default function RestaurantPage() {
  const [menuItems, setMenuItems] = useState<MenuItem[]>([]);
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"menu" | "orders">("menu");
  const [category, setCategory] = useState("ALL");
  const [cart, setCart] = useState<CartItem[]>([]);
  const [showCart, setShowCart] = useState(false);
  const [orderType, setOrderType] = useState<"RESTAURANT" | "ROOM_SERVICE">(
    "RESTAURANT",
  );
  const [roomNumber, setRoomNumber] = useState("");

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    try {
      const [menuRes, orderRes] = await Promise.all([
        fetch("/api/restaurant?type=menu"),
        fetch("/api/restaurant?type=orders"),
      ]);
      setMenuItems(await menuRes.json());
      setOrders(await orderRes.json());
    } catch {
      toast.error("Gagal memuat data");
    } finally {
      setLoading(false);
    }
  }

  function addToCart(item: MenuItem) {
    setCart((prev) => {
      const existing = prev.find((c) => c.id === item.id);
      if (existing)
        return prev.map((c) =>
          c.id === item.id ? { ...c, quantity: c.quantity + 1 } : c,
        );
      return [...prev, { ...item, quantity: 1 }];
    });
    toast.success(`${item.name} ditambahkan ke keranjang`);
  }

  function removeFromCart(id: string) {
    setCart((prev) => prev.filter((c) => c.id !== id));
  }

  function updateQuantity(id: string, qty: number) {
    if (qty <= 0) return removeFromCart(id);
    setCart((prev) =>
      prev.map((c) => (c.id === id ? { ...c, quantity: qty } : c)),
    );
  }

  async function submitOrder() {
    if (cart.length === 0) return;
    if (orderType === "ROOM_SERVICE" && !roomNumber) {
      toast.error("Masukkan nomor kamar");
      return;
    }
    try {
      const res = await fetch("/api/restaurant", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          orderType,
          roomNumber: orderType === "ROOM_SERVICE" ? roomNumber : null,
          items: cart.map((c) => ({
            menuItemId: c.id,
            quantity: c.quantity,
            price: c.price,
          })),
        }),
      });
      if (!res.ok) throw new Error();
      toast.success("Pesanan berhasil dibuat!");
      setCart([]);
      setShowCart(false);
      setRoomNumber("");
      fetchData();
    } catch {
      toast.error("Gagal membuat pesanan");
    }
  }

  const categories = ["ALL", "MAKANAN", "MINUMAN", "SNACK", "DESSERT"];
  const filteredMenu =
    category === "ALL"
      ? menuItems
      : menuItems.filter((m) => m.category === category);
  const cartTotal = cart.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0,
  );
  const cartCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  if (loading)
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-hotel-600" />
      </div>
    );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">
            Restaurant & Room Service
          </h1>
          <p className="text-gray-500 mt-1">
            Kelola pesanan restaurant dan room service
          </p>
        </div>
        <button
          onClick={() => setShowCart(true)}
          className="btn-primary flex items-center gap-2 w-fit relative"
        >
          <HiOutlineShoppingCart className="w-5 h-5" />
          Keranjang
          {cartCount > 0 && (
            <span className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-bold">
              {cartCount}
            </span>
          )}
        </button>
      </div>

      <div className="flex gap-2 border-b border-gray-200">
        <button
          onClick={() => setActiveTab("menu")}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "menu"
              ? "border-hotel-600 text-hotel-600"
              : "border-transparent text-gray-500 hover:text-gray-700"
          }`}
        >
          Menu
        </button>
        <button
          onClick={() => setActiveTab("orders")}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === "orders"
              ? "border-hotel-600 text-hotel-600"
              : "border-transparent text-gray-500 hover:text-gray-700"
          }`}
        >
          Pesanan ({orders.length})
        </button>
      </div>

      {activeTab === "menu" ? (
        <>
          <div className="flex flex-wrap gap-2">
            {categories.map((c) => (
              <button
                key={c}
                onClick={() => setCategory(c)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                  category === c
                    ? "bg-hotel-600 text-white"
                    : "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"
                }`}
              >
                {c === "ALL" ? "Semua" : c}
              </button>
            ))}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {filteredMenu
              .filter((m) => m.isAvailable)
              .map((item) => (
                <div
                  key={item.id}
                  className="card hover:shadow-md transition-all overflow-hidden p-0"
                >
                  {/* Gambar Menu */}
                  <div className="w-full h-40 bg-gradient-to-br from-hotel-100 to-hotel-200 overflow-hidden">
                    {item.image ? (
                      <img
                        src={item.image}
                        alt={item.name}
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          e.currentTarget.style.display = "none";
                          const parent = e.currentTarget.parentElement;
                          if (parent) {
                            parent.innerHTML =
                              '<div class="flex items-center justify-center h-full text-4xl">️</div>';
                          }
                        }}
                      />
                    ) : (
                      <div className="flex items-center justify-center h-full text-4xl">
                        {item.category === "MAKANAN"
                          ? "🍽️"
                          : item.category === "MINUMAN"
                            ? "🥤"
                            : item.category === "DESSERT"
                              ? "🍰"
                              : "🍿"}
                      </div>
                    )}
                  </div>

                  <div className="p-4">
                    <span className="text-xs font-medium text-hotel-600 uppercase">
                      {item.category}
                    </span>
                    <h3 className="font-bold text-gray-900 mt-1">
                      {item.name}
                    </h3>
                    {item.description && (
                      <p className="text-xs text-gray-500 mt-1 line-clamp-2">
                        {item.description}
                      </p>
                    )}
                    <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100">
                      <span className="font-bold text-hotel-700">
                        {formatCurrency(item.price)}
                      </span>
                      <button
                        onClick={() => addToCart(item)}
                        className="w-8 h-8 bg-hotel-600 hover:bg-hotel-700 text-white rounded-lg flex items-center justify-center transition-colors"
                      >
                        <HiOutlinePlus className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
          </div>
        </>
      ) : (
        <DataTable
          columns={[
            {
              key: "orderNumber",
              header: "No. Pesanan",
              render: (o: any) => (
                <span className="font-mono font-semibold text-hotel-700">
                  {o.orderNumber}
                </span>
              ),
            },
            {
              key: "orderType",
              header: "Tipe",
              render: (o: any) => (
                <span
                  className={`text-xs font-semibold px-2 py-1 rounded ${
                    o.orderType === "ROOM_SERVICE"
                      ? "bg-purple-100 text-purple-800"
                      : "bg-blue-100 text-blue-800"
                  }`}
                >
                  {o.orderType === "ROOM_SERVICE"
                    ? "Room Service"
                    : "Restaurant"}
                </span>
              ),
            },
            {
              key: "roomNumber",
              header: "Kamar",
              render: (o: any) => o.roomNumber || "-",
            },
            {
              key: "items",
              header: "Item",
              render: (o: any) => (
                <div>
                  {o.items?.slice(0, 2).map((i: any) => (
                    <p key={i.id} className="text-sm">
                      {i.quantity}x {i.menuItem.name}
                    </p>
                  ))}
                  {o.items?.length > 2 && (
                    <p className="text-xs text-gray-500">
                      +{o.items.length - 2} lainnya
                    </p>
                  )}
                </div>
              ),
            },
            {
              key: "totalAmount",
              header: "Total",
              render: (o: any) => (
                <span className="font-bold">
                  {formatCurrency(o.totalAmount)}
                </span>
              ),
            },
            {
              key: "status",
              header: "Status",
              render: (o: any) => <Badge status={o.status} />,
            },
          ]}
          data={orders}
          keyExtractor={(o: any) => o.id}
          emptyMessage="Belum ada pesanan"
        />
      )}

      <Modal
        isOpen={showCart}
        onClose={() => setShowCart(false)}
        title="Keranjang Pesanan"
        size="lg"
      >
        {cart.length === 0 ? (
          <p className="text-center text-gray-500 py-8">
            Keranjang masih kosong
          </p>
        ) : (
          <div className="space-y-4">
            <div className="flex gap-2">
              <button
                onClick={() => setOrderType("RESTAURANT")}
                className={`flex-1 py-2.5 rounded-lg text-sm font-medium transition-all ${
                  orderType === "RESTAURANT"
                    ? "bg-hotel-600 text-white"
                    : "bg-gray-100 text-gray-700"
                }`}
              >
                🍽️ Dine In
              </button>
              <button
                onClick={() => setOrderType("ROOM_SERVICE")}
                className={`flex-1 py-2.5 rounded-lg text-sm font-medium transition-all ${
                  orderType === "ROOM_SERVICE"
                    ? "bg-hotel-600 text-white"
                    : "bg-gray-100 text-gray-700"
                }`}
              >
                🛎️ Room Service
              </button>
            </div>

            {orderType === "ROOM_SERVICE" && (
              <div>
                <label className="label-field">Nomor Kamar</label>
                <input
                  type="text"
                  value={roomNumber}
                  onChange={(e) => setRoomNumber(e.target.value)}
                  className="input-field"
                  placeholder="Contoh: 101"
                  required
                />
              </div>
            )}

            <div className="space-y-3 max-h-64 overflow-y-auto">
              {cart.map((item) => (
                <div
                  key={item.id}
                  className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
                >
                  <div className="flex-1">
                    <p className="font-medium text-sm">{item.name}</p>
                    <p className="text-xs text-gray-500">
                      {formatCurrency(item.price)}
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => updateQuantity(item.id, item.quantity - 1)}
                      className="w-7 h-7 bg-white border rounded flex items-center justify-center text-sm"
                    >
                      -
                    </button>
                    <span className="w-8 text-center text-sm font-medium">
                      {item.quantity}
                    </span>
                    <button
                      onClick={() => updateQuantity(item.id, item.quantity + 1)}
                      className="w-7 h-7 bg-white border rounded flex items-center justify-center text-sm"
                    >
                      +
                    </button>
                  </div>
                  <p className="font-bold text-sm w-24 text-right">
                    {formatCurrency(item.price * item.quantity)}
                  </p>
                </div>
              ))}
            </div>

            <div className="flex items-center justify-between pt-4 border-t">
              <span className="text-lg font-bold">Total</span>
              <span className="text-xl font-bold text-hotel-700">
                {formatCurrency(cartTotal)}
              </span>
            </div>

            <button onClick={submitOrder} className="btn-primary w-full">
              Buat Pesanan
            </button>
          </div>
        )}
      </Modal>
    </div>
  );
}

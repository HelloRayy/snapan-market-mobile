import { create } from 'zustand';
import { CartItem } from '@/types/order';
import { Product } from '@/types/product';

interface CartState {
  items: CartItem[];
  addItem: (product: Product, quantity?: number) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
  getTotalItems: () => number;
  getTotalPrice: () => number;
}

// Key LocalStorage untuk persistence keranjang
const CART_STORAGE_KEY = 'snapan_cart_items';

const loadCartFromStorage = (): CartItem[] => {
  try {
    const saved = localStorage.getItem(CART_STORAGE_KEY);
    return saved ? JSON.parse(saved) : [];
  } catch {
    return [];
  }
};

const saveCartToStorage = (items: CartItem[]) => {
  try {
    localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(items));
  } catch (e) {
    console.error('Failed to save cart to localStorage', e);
  }
};

export const useCartStore = create<CartState>((set, get) => ({
  items: loadCartFromStorage(),

  addItem: (product, quantity = 1) => {
    set((state) => {
      const existingIndex = state.items.findIndex(
        (item) => item.product.id === product.id
      );

      let newItems: CartItem[];
      if (existingIndex > -1) {
        newItems = [...state.items];
        newItems[existingIndex].quantity += quantity;
      } else {
        newItems = [...state.items, { product, quantity }];
      }

      saveCartToStorage(newItems);
      return { items: newItems };
    });
  },

  removeItem: (productId) => {
    set((state) => {
      const newItems = state.items.filter(
        (item) => item.product.id !== productId
      );
      saveCartToStorage(newItems);
      return { items: newItems };
    });
  },

  updateQuantity: (productId, quantity) => {
    set((state) => {
      if (quantity <= 0) {
        const newItems = state.items.filter(
          (item) => item.product.id !== productId
        );
        saveCartToStorage(newItems);
        return { items: newItems };
      }

      const newItems = state.items.map((item) =>
        item.product.id === productId ? { ...item, quantity } : item
      );
      saveCartToStorage(newItems);
      return { items: newItems };
    });
  },

  clearCart: () => {
    saveCartToStorage([]);
    set({ items: [] });
  },

  getTotalItems: () => {
    return get().items.reduce((total, item) => total + item.quantity, 0);
  },

  getTotalPrice: () => {
    return get().items.reduce(
      (total, item) => total + item.product.price * item.quantity,
      0
    );
  }
}));

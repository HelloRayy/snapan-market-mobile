import React from 'react';
import { ShoppingBag, CheckCircle2 } from 'lucide-react';
import { Product } from '@/types/product';
import { Card } from '@/ui/components/ui/Card';
import { Badge } from '@/ui/components/ui/Badge';
import { ButtonPrimary } from '@/ui/components/ui/ButtonPrimary';
import { RatingStars } from './RatingStars';
import { formatRupiah, formatCompactNumber } from '@/utils/formatters';
import { useCartStore } from '@/ui/store/cartStore';

interface ProductCardProps {
  product: Product;
}

export const ProductCard: React.FC<ProductCardProps> = ({ product }) => {
  const addItem = useCartStore((state) => state.addItem);

  return (
    <Card className="group flex flex-col justify-between hover:border-neutral-300 transition-colors duration-150">
      <div className="relative aspect-square w-full bg-neutral-100 overflow-hidden">
        <img
          src={product.images[0] || 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80'}
          alt={product.name}
          className="h-full w-full object-cover object-center group-hover:scale-105 transition-transform duration-500"
          loading="lazy"
        />
        {product.originalPrice && product.originalPrice > product.price && (
          <Badge variant="rose" className="absolute top-2 left-2">
            Diskon {Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100)}%
          </Badge>
        )}
      </div>

      <div className="p-3.5 flex flex-col flex-1 justify-between gap-3 bg-white">
        <div className="space-y-1.5">
          <div className="flex items-center gap-1 text-xs text-neutral-500">
            <span className="truncate max-w-[120px] font-medium">{product.sellerName}</span>
            {product.isVerifiedSeller && (
              <CheckCircle2 className="w-3.5 h-3.5 text-black shrink-0" />
            )}
          </div>
          <h3 className="text-sm font-semibold text-neutral-900 line-clamp-2 leading-snug group-hover:text-neutral-700 transition-colors">
            {product.name}
          </h3>
        </div>

        <div className="space-y-2">
          <div className="flex items-center gap-1.5 text-xs text-neutral-500">
            <RatingStars rating={product.rating} size={14} />
            <span>•</span>
            <span>{formatCompactNumber(product.soldCount)} Terjual</span>
          </div>

          <div className="flex items-center justify-between gap-2 pt-1 border-t border-neutral-100">
            <div>
              <p className="text-base font-bold text-black">
                {formatRupiah(product.price)}
              </p>
              {product.originalPrice && (
                <p className="text-xs text-neutral-400 line-through">
                  {formatRupiah(product.originalPrice)}
                </p>
              )}
            </div>

            <ButtonPrimary
              size="sm"
              onClick={() => addItem(product)}
              className="px-2.5 py-1.5 h-8 w-8 rounded-lg p-0 flex items-center justify-center"
              title="Tambah ke keranjang"
            >
              <ShoppingBag className="w-4 h-4" />
            </ButtonPrimary>
          </div>
        </div>
      </div>
    </Card>
  );
};

import React, { useEffect, useRef, useState } from 'react';
import { getMapData, show3dMap, MapView } from '@mappedin/mappedin-js';
import '@mappedin/mappedin-js/lib/index.css';
import { Loader2, RefreshCw, Layers } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

interface MappedinViewProps {
  className?: string;
  onSpaceClick?: (spaceName: string) => void;
}

export const MappedinView: React.FC<MappedinViewProps> = ({
  className = '',
  onSpaceClick,
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapViewRef = useRef<MapView | null>(null);

  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [selectedSpaceName, setSelectedSpaceName] = useState<string | null>(null);
  const [floors, setFloors] = useState<any[]>([]);
  const [currentFloorId, setCurrentFloorId] = useState<string | null>(null);

  const initMap = async () => {
    if (!containerRef.current) return;
    setIsLoading(true);
    setErrorMsg(null);

    try {
      // 1. Fetch Official Demo Venue Data from Mappedin Cloud
      const mapData = await getMapData({
        key: '5eab30aa91b055001a68e996',
        secret: 'RJyRXKcryCMy4erZqqCbuB1NbR66QTGNXVE0x3Pg6oCIlUR1',
        mapId: 'mappedin-demo-mall',
      });

      if (!containerRef.current) return;

      // 2. Render 3D/2.5D WebGL Interactive Map Canvas
      const mapView = await show3dMap(containerRef.current, mapData);
      mapViewRef.current = mapView;

      // 3. Extract Floor Stack data
      if (mapData.getByType('floor')) {
        const floorList = mapData.getByType('floor');
        setFloors(floorList);
        if (floorList.length > 0) {
          setCurrentFloorId(floorList[0].id);
        }
      }

      // 4. Interactivity: Listen to Click / Tap Events on Spaces
      mapView.on('click', (event: any) => {
        if (event && event.spaces && event.spaces.length > 0) {
          triggerHaptic('light');
          const clickedSpace = event.spaces[0];
          const name = clickedSpace.name || 'Ruangan / Toko';
          setSelectedSpaceName(name);
          onSpaceClick?.(name);

          // Dynamic 2.5D Camera Tween Focus & Poligon Highlight
          try {
            (mapView as any).updateState?.(clickedSpace, {
              color: '#3d38f5',
            });
            (mapView as any).Camera?.focusOn?.(clickedSpace);
          } catch {
            // Safe fallback
          }
        }
      });

      setIsLoading(false);
    } catch (err: any) {
      console.error('Mappedin WebGL initialization error:', err);
      setErrorMsg(err.message || 'Gagal memuat engine WebGL Mappedin.');
      setIsLoading(false);
    }
  };

  useEffect(() => {
    initMap();

    return () => {
      if (mapViewRef.current) {
        try {
          mapViewRef.current.destroy();
        } catch {
          // Safe WebGL memory cleanup
        }
      }
    };
  }, []);

  const handleFloorSelect = (floor: any) => {
    triggerHaptic('medium');
    if (mapViewRef.current && floor) {
      try {
        mapViewRef.current.setFloor(floor);
        setCurrentFloorId(floor.id);
      } catch (err) {
        console.error('Error changing floor:', err);
      }
    }
  };

  return (
    <div className={`relative w-full h-full bg-slate-900 overflow-hidden font-gt-standard select-none touch-none ${className}`}>
      {/* Loading Overlay */}
      {isLoading && (
        <div className="absolute inset-0 z-30 bg-slate-900/95 backdrop-blur-md flex flex-col items-center justify-center gap-3 select-none text-white">
          <Loader2 className="w-9 h-9 text-[#3d38f5] animate-spin" />
          <p className="text-[14px] font-bold text-white tracking-wide">
            Memuat WebGL 2.5D Map Engine...
          </p>
          <p className="text-[12px] text-slate-400 font-normal">
            Menghubungkan ke Mappedin Interactive Cloud
          </p>
        </div>
      )}

      {/* Error Fallback */}
      {errorMsg && !isLoading && (
        <div className="absolute inset-0 z-30 bg-slate-900/95 backdrop-blur-md flex flex-col items-center justify-center p-6 text-center space-y-3 text-white">
          <p className="text-[14px] font-bold text-rose-400">{errorMsg}</p>
          <button
            type="button"
            onClick={initMap}
            className="px-5 py-2.5 rounded-xl bg-[#3d38f5] text-white text-[13px] font-bold flex items-center gap-2 hover:bg-indigo-600 active:scale-95 transition-all cursor-pointer shadow-lg"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Coba Muat Ulang</span>
          </button>
        </div>
      )}

      {/* Pure WebGL Map Canvas Container */}
      <div
        ref={containerRef}
        id="mappedin-canvas-container"
        className="w-full h-full"
        style={{ width: '100%', height: '100%' }}
      />

      {/* Floating Floor Selector in Top-Right (Minimalist Pill) */}
      {floors.length > 1 && (
        <div className="absolute top-4 right-4 z-20 bg-slate-900/80 backdrop-blur-xl border border-white/10 p-1 rounded-2xl shadow-xl flex flex-col gap-1 select-none">
          <div className="flex items-center gap-1 px-2 py-0.5 text-[9.5px] font-bold text-slate-400 tracking-wider">
            <Layers className="w-3 h-3 text-[#3d38f5]" />
            <span>LANTAI</span>
          </div>
          {floors.map((fl) => (
            <button
              key={fl.id}
              type="button"
              onClick={() => handleFloorSelect(fl)}
              className={`px-3 py-1.5 rounded-xl text-[11.5px] font-bold transition-all cursor-pointer text-left ${
                currentFloorId === fl.id
                  ? 'bg-[#3d38f5] text-white shadow-md'
                  : 'text-slate-300 hover:bg-white/10'
              }`}
            >
              {fl.name || `Lantai ${fl.elevation || 1}`}
            </button>
          ))}
        </div>
      )}

      {/* Minimalist Floating Selected Room Badge at Bottom Center */}
      {selectedSpaceName && (
        <div className="absolute bottom-5 inset-x-4 z-20 pointer-events-none flex justify-center animate-in slide-in-from-bottom-2 duration-150">
          <div className="bg-slate-900/90 backdrop-blur-xl border border-white/15 text-white px-4 py-2 rounded-full shadow-2xl text-[13px] font-bold flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-[#3d38f5] animate-pulse" />
            <span>Ruangan:</span>
            <span className="text-[#818cf8]">{selectedSpaceName}</span>
          </div>
        </div>
      )}
    </div>
  );
};

import React, { useEffect, useRef, useState } from 'react';
import { getMapData, show3dMap, MapView } from '@mappedin/mappedin-js';
import '@mappedin/mappedin-js/lib/index.css';
import { Loader2, RefreshCw, Layers } from 'lucide-react';

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
      // 1. Fetch Demo Map Data from Mappedin Cloud
      const mapData = await getMapData({
        key: '5eab30aa91b055001a68e996',
        secret: 'RJyRXKcryCMy4erZqqCbuB1NbR66QTGNXVE0x3Pg6oCIlUR1',
        mapId: 'mappedin-demo-mall',
      });

      if (!containerRef.current) return;

      // 2. Render 3D WebGL Map onto Container
      const mapView = await show3dMap(containerRef.current, mapData);
      mapViewRef.current = mapView;

      // 3. Extract Floor data
      if (mapData.getByType('floor')) {
        const floorList = mapData.getByType('floor');
        setFloors(floorList);
        if (floorList.length > 0) {
          setCurrentFloorId(floorList[0].id);
        }
      }

      // 4. Interactivity: Listen to Click Events on Spaces / Polygons
      mapView.on('click', (event) => {
        if (event && event.spaces && event.spaces.length > 0) {
          const clickedSpace = event.spaces[0];
          const name = clickedSpace.name || 'Ruangan Terpilih';
          setSelectedSpaceName(name);
          onSpaceClick?.(name);

          // Dynamic Camera Focus & Highlight on Clicked Space
          try {
            (mapView as any).updateState?.(clickedSpace, {
              color: '#3d38f5',
            });
            (mapView as any).Camera?.focusOn?.(clickedSpace);
          } catch {
            // Ignore if optional camera animation
          }
        }
      });

      setIsLoading(false);
    } catch (err: any) {
      console.error('Mappedin initialization error:', err);
      setErrorMsg(err.message || 'Gagal memuat engine peta Mappedin.');
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
          // Cleanup safe
        }
      }
    };
  }, []);

  const handleFloorSelect = (floor: any) => {
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
    <div className={`relative w-full h-[650px] bg-neutral-100 rounded-[28px] overflow-hidden border border-neutral-200 shadow-2xs font-gt-standard ${className}`}>
      {/* Loading Overlay */}
      {isLoading && (
        <div className="absolute inset-0 z-30 bg-neutral-100/90 backdrop-blur-sm flex flex-col items-center justify-center gap-3 select-none">
          <Loader2 className="w-8 h-8 text-[#3d38f5] animate-spin" />
          <p className="text-[13.5px] font-bold text-slate-800">
            Memuat WebGL Map Engine...
          </p>
          <p className="text-[11.5px] text-slate-500 font-normal">
            Menghubungkan ke Mappedin Playground
          </p>
        </div>
      )}

      {/* Error Fallback */}
      {errorMsg && !isLoading && (
        <div className="absolute inset-0 z-30 bg-white/95 backdrop-blur-sm flex flex-col items-center justify-center p-6 text-center space-y-3">
          <p className="text-[14px] font-bold text-rose-600">{errorMsg}</p>
          <button
            type="button"
            onClick={initMap}
            className="px-4 py-2 rounded-xl bg-slate-900 text-white text-[13px] font-bold flex items-center gap-2 hover:bg-black active:scale-95 transition-all cursor-pointer"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Coba Muat Ulang</span>
          </button>
        </div>
      )}

      {/* Mappedin Interactive Map Container */}
      <div
        ref={containerRef}
        id="mappedin-canvas-container"
        className="w-full h-full"
        style={{ width: '100%', height: '100%' }}
      />

      {/* Floating Floor Selector (If multiple floors exist) */}
      {floors.length > 1 && (
        <div className="absolute top-4 right-4 z-20 bg-white/95 backdrop-blur-md border border-neutral-200/90 p-1.5 rounded-2xl shadow-md flex flex-col gap-1 select-none">
          <div className="flex items-center gap-1 px-1.5 py-0.5 text-[10.5px] font-bold text-neutral-400">
            <Layers className="w-3 h-3" />
            <span>LANTAI</span>
          </div>
          {floors.map((fl) => (
            <button
              key={fl.id}
              type="button"
              onClick={() => handleFloorSelect(fl)}
              className={`px-3 py-1.5 rounded-xl text-[12px] font-bold transition-all cursor-pointer text-left ${
                currentFloorId === fl.id
                  ? 'bg-[#3d38f5] text-white shadow-2xs'
                  : 'text-slate-700 hover:bg-neutral-100'
              }`}
            >
              {fl.name || `Lantai ${fl.elevation || 1}`}
            </button>
          ))}
        </div>
      )}

      {/* Floating Info Pill on Bottom */}
      {selectedSpaceName && (
        <div className="absolute bottom-4 inset-x-4 z-20 pointer-events-none flex justify-center">
          <div className="bg-slate-900/90 backdrop-blur-md text-white px-4 py-2 rounded-full shadow-lg text-[13px] font-bold animate-in slide-in-from-bottom-2 duration-150">
            Ruangan Terpilih: <span className="text-[#818cf8]">{selectedSpaceName}</span>
          </div>
        </div>
      )}
    </div>
  );
};

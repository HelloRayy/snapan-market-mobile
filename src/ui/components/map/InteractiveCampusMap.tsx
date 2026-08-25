import React, { useState, useRef } from 'react';
import {
  ZoomIn,
  ZoomOut,
  MapPin,
  Check,
  Compass,
  Utensils,
  Laptop,
  Building,
  BookOpen,
  TreePine,
} from 'lucide-react';
import { SCHOOL_FLOORS, RoomZone, FloorData } from '@/data/mockSchoolMapData';
import { triggerHaptic } from '@/utils/haptics';

interface InteractiveCampusMapProps {
  onSelectLocation?: (room: RoomZone) => void;
  selectedLocationId?: string;
  className?: string;
}

export const InteractiveCampusMap: React.FC<InteractiveCampusMapProps> = ({
  onSelectLocation,
  selectedLocationId = 'kantin-utama',
  className = '',
}) => {
  // Current Floor: 1, 2, or 3
  const [currentFloorNumber, setCurrentFloorNumber] = useState<number>(1);
  const currentFloor: FloorData =
    SCHOOL_FLOORS.find((f) => f.floor === currentFloorNumber) || SCHOOL_FLOORS[0];

  // Selected Room
  const [selectedRoom, setSelectedRoom] = useState<RoomZone | null>(() => {
    return (
      currentFloor.rooms.find((r) => r.id === selectedLocationId) ||
      currentFloor.rooms[0] ||
      null
    );
  });

  // Active Category Filter: 'all' | 'canteen' | 'lab' | 'lobby' | 'facility' | 'outdoor'
  const [activeCategory, setActiveCategory] = useState<string>('all');

  // Canvas Pan & Zoom State
  const [zoom, setZoom] = useState<number>(1);
  const [pan, setPan] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const isDraggingRef = useRef<boolean>(false);
  const startPanRef = useRef<{ x: number; y: number }>({ x: 0, y: 0 });
  const containerRef = useRef<HTMLDivElement>(null);

  // Smoothly center on selected room
  const centerOnRoom = (room: RoomZone) => {
    // Standard SVG viewBox center is (350, 400)
    const targetX = (350 - room.pinPosition.x) * 0.7;
    const targetY = (380 - room.pinPosition.y) * 0.7;
    setPan({ x: targetX, y: targetY });
    setZoom(1.15);
  };

  const handleSelectRoom = (room: RoomZone) => {
    triggerHaptic('light');
    setSelectedRoom(room);
    if (room.floor !== currentFloorNumber) {
      setCurrentFloorNumber(room.floor);
    }
    centerOnRoom(room);
  };

  const handleFloorChange = (floorNum: number) => {
    triggerHaptic('medium');
    setCurrentFloorNumber(floorNum);
    const targetFloor = SCHOOL_FLOORS.find((f) => f.floor === floorNum);
    if (targetFloor && targetFloor.rooms.length > 0) {
      // Pick first popular or first room on this floor
      const firstRoom =
        targetFloor.rooms.find((r) => r.isPopularCodSpot) || targetFloor.rooms[0];
      setSelectedRoom(firstRoom);
      centerOnRoom(firstRoom);
    }
  };

  // Zoom handlers
  const handleZoomIn = () => {
    triggerHaptic('light');
    setZoom((z) => Math.min(2.2, +(z + 0.25).toFixed(2)));
  };

  const handleZoomOut = () => {
    triggerHaptic('light');
    setZoom((z) => Math.max(0.65, +(z - 0.25).toFixed(2)));
  };

  const handleResetView = () => {
    triggerHaptic('light');
    setZoom(1);
    setPan({ x: 0, y: 0 });
  };

  // Touch & Mouse Drag (Pan) Handlers
  const handlePointerDown = (clientX: number, clientY: number) => {
    isDraggingRef.current = true;
    startPanRef.current = { x: clientX - pan.x, y: clientY - pan.y };
  };

  const handlePointerMove = (clientX: number, clientY: number) => {
    if (!isDraggingRef.current) return;
    const newX = clientX - startPanRef.current.x;
    const newY = clientY - startPanRef.current.y;
    // Bound pan
    setPan({
      x: Math.max(-280, Math.min(280, newX)),
      y: Math.max(-280, Math.min(280, newY)),
    });
  };

  const handlePointerUp = () => {
    isDraggingRef.current = false;
  };

  // Category Icon Resolver
  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'canteen':
        return <Utensils className="w-3.5 h-3.5" />;
      case 'lab':
        return <Laptop className="w-3.5 h-3.5" />;
      case 'lobby':
        return <Building className="w-3.5 h-3.5" />;
      case 'facility':
        return <BookOpen className="w-3.5 h-3.5" />;
      case 'outdoor':
        return <TreePine className="w-3.5 h-3.5" />;
      default:
        return <MapPin className="w-3.5 h-3.5" />;
    }
  };

  return (
    <div
      ref={containerRef}
      className={`relative w-full h-[620px] sm:h-[680px] bg-[#f8fafc] rounded-[28px] overflow-hidden border border-neutral-200/90 shadow-2xs font-gt-standard select-none touch-none ${className}`}
    >
      {/* 1. TOP FLOATING BAR: Category Filter Chips & Floor Switcher */}
      <div className="absolute top-3 inset-x-3 z-30 flex items-center justify-between gap-2 pointer-events-auto">
        {/* Left: Category Scroll Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto scrollbar-none py-1 max-w-[68%]">
          {[
            { id: 'all', label: 'Semua Zona' },
            { id: 'canteen', label: 'Kantin' },
            { id: 'lab', label: 'Lab' },
            { id: 'lobby', label: 'Lobi' },
            { id: 'facility', label: 'Fasilitas' },
          ].map((cat) => (
            <button
              key={cat.id}
              type="button"
              onClick={() => {
                triggerHaptic('light');
                setActiveCategory(cat.id);
              }}
              className={`px-3 py-1.5 rounded-full text-[12px] font-bold shrink-0 transition-all cursor-pointer shadow-2xs ${
                activeCategory === cat.id
                  ? 'bg-slate-900 text-white'
                  : 'bg-white/95 backdrop-blur-md text-slate-700 border border-neutral-200/80 hover:bg-neutral-50'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Right: Floor Selector Pill (1F / 2F / 3F) */}
        <div className="bg-white/95 backdrop-blur-md border border-neutral-200/80 p-1 rounded-full shadow-md flex items-center gap-0.5 shrink-0">
          {[1, 2, 3].map((fNum) => (
            <button
              key={fNum}
              type="button"
              onClick={() => handleFloorChange(fNum)}
              className={`px-2.5 py-1 rounded-full text-[11.5px] font-bold transition-all cursor-pointer ${
                currentFloorNumber === fNum
                  ? 'bg-[#3d38f5] text-white shadow-2xs'
                  : 'text-slate-600 hover:text-slate-900 hover:bg-neutral-100/60'
              }`}
            >
              Lt {fNum}
            </button>
          ))}
        </div>
      </div>

      {/* 2. FLOATING MAP CONTROLS (Zoom In, Zoom Out, Compass Reset) */}
      <div className="absolute right-3.5 top-16 z-30 flex flex-col gap-1.5 pointer-events-auto">
        <button
          type="button"
          onClick={handleZoomIn}
          className="w-9 h-9 rounded-xl bg-white/95 backdrop-blur-md border border-neutral-200/90 shadow-md text-slate-700 hover:text-slate-900 hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Zoom In"
        >
          <ZoomIn className="w-4.5 h-4.5 stroke-[2.2]" />
        </button>
        <button
          type="button"
          onClick={handleZoomOut}
          className="w-9 h-9 rounded-xl bg-white/95 backdrop-blur-md border border-neutral-200/90 shadow-md text-slate-700 hover:text-slate-900 hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Zoom Out"
        >
          <ZoomOut className="w-4.5 h-4.5 stroke-[2.2]" />
        </button>
        <button
          type="button"
          onClick={handleResetView}
          className="w-9 h-9 rounded-xl bg-white/95 backdrop-blur-md border border-neutral-200/90 shadow-md text-slate-700 hover:text-slate-900 hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Reset Tampilan"
          title="Pusatkan Peta"
        >
          <Compass className="w-4.5 h-4.5 stroke-[2.2] text-[#3d38f5]" />
        </button>
      </div>

      {/* 3. INTERACTIVE SVG MAP VIEWPORT (Draggable & Zoomable) */}
      <div
        className="w-full h-full flex items-center justify-center cursor-grab active:cursor-grabbing"
        onMouseDown={(e) => handlePointerDown(e.clientX, e.clientY)}
        onMouseMove={(e) => handlePointerMove(e.clientX, e.clientY)}
        onMouseUp={handlePointerUp}
        onMouseLeave={handlePointerUp}
        onTouchStart={(e) => {
          if (e.touches.length === 1) {
            handlePointerDown(e.touches[0].clientX, e.touches[0].clientY);
          }
        }}
        onTouchMove={(e) => {
          if (e.touches.length === 1) {
            handlePointerMove(e.touches[0].clientX, e.touches[0].clientY);
          }
        }}
        onTouchEnd={handlePointerUp}
      >
        <div
          style={{
            transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})`,
            transformOrigin: 'center center',
            transition: isDraggingRef.current ? 'none' : 'transform 0.25s cubic-bezier(0.16, 1, 0.3, 1)',
          }}
          className="w-full h-full flex items-center justify-center"
        >
          <svg
            viewBox="0 0 700 800"
            className="w-[90%] max-w-[620px] h-auto drop-shadow-sm select-none"
          >
            {/* A. Outer Building Architectural Boundary */}
            <path
              d="M 60 40 L 520 40 L 520 200 L 640 200 L 640 340 L 520 340 L 520 760 L 60 760 Z"
              fill="#f1f5f9"
              stroke="#cbd5e1"
              strokeWidth="2.5"
              strokeLinejoin="round"
            />

            {/* B. Hallway & Walkway Inner Canvas */}
            <path
              d="M 120 70 L 460 70 L 460 720 L 120 720 Z"
              fill="#ffffff"
              stroke="#e2e8f0"
              strokeWidth="1.5"
            />

            {/* C. Render Decorative Architectural Features */}
            {currentFloor.features.map((feat) => {
              if (feat.type === 'atrium') {
                return (
                  <g key={feat.id}>
                    {/* Outer dashed ring */}
                    <circle
                      cx={feat.x}
                      cy={feat.y}
                      r={feat.radius || 24}
                      fill="#f8fafc"
                      stroke="#f59e0b"
                      strokeWidth="2"
                      strokeDasharray="4 3"
                    />
                    {/* Inner core */}
                    <circle
                      cx={feat.x}
                      cy={feat.y}
                      r={(feat.radius || 24) * 0.45}
                      fill="#fef3c7"
                      stroke="#d97706"
                      strokeWidth="1.5"
                    />
                    <text
                      x={feat.x}
                      y={feat.y + 36}
                      textAnchor="middle"
                      className="text-[10px] font-bold fill-amber-700 select-none pointer-events-none"
                    >
                      ATRIUM
                    </text>
                  </g>
                );
              }

              if (feat.type === 'table') {
                return (
                  <rect
                    key={feat.id}
                    x={feat.x}
                    y={feat.y}
                    width={feat.width || 18}
                    height={feat.height || 18}
                    rx="3.5"
                    fill="#fef08a"
                    stroke="#ca8a04"
                    strokeWidth="1.5"
                    className="transition-colors hover:fill-amber-300"
                  />
                );
              }

              if (feat.type === 'entrance') {
                return (
                  <g key={feat.id}>
                    <rect
                      x={feat.x}
                      y={feat.y}
                      width={feat.width || 60}
                      height={feat.height || 12}
                      rx="4"
                      fill="#3b82f6"
                      stroke="#1d4ed8"
                      strokeWidth="1.5"
                    />
                    <text
                      x={feat.x + (feat.width || 60) / 2}
                      y={feat.y + 24}
                      textAnchor="middle"
                      className="text-[9.5px] font-bold fill-blue-700 select-none pointer-events-none"
                    >
                      GERBANG UTAMA
                    </text>
                  </g>
                );
              }

              return null;
            })}

            {/* D. Render Interactive Rooms / Zones */}
            {currentFloor.rooms.map((room) => {
              const isSelected = selectedRoom?.id === room.id;
              const isDimmed = activeCategory !== 'all' && room.category !== activeCategory;

              return (
                <g
                  key={room.id}
                  onClick={(e) => {
                    e.stopPropagation();
                    handleSelectRoom(room);
                  }}
                  className={`cursor-pointer transition-all duration-200 ${
                    isDimmed ? 'opacity-35' : 'opacity-100'
                  }`}
                >
                  {/* Room Area Polygon */}
                  <path
                    d={room.path}
                    fill={isSelected ? '#eef0ff' : '#ffffff'}
                    stroke={isSelected ? '#3d38f5' : '#cbd5e1'}
                    strokeWidth={isSelected ? '3' : '1.5'}
                    strokeLinejoin="round"
                    className="hover:fill-[#f0f2fe] transition-colors"
                  />

                  {/* Room Label */}
                  <text
                    x={room.pinPosition.x}
                    y={room.pinPosition.y - 12}
                    textAnchor="middle"
                    className={`text-[11px] font-bold select-none pointer-events-none tracking-tight ${
                      isSelected ? 'fill-[#3d38f5]' : 'fill-slate-700'
                    }`}
                  >
                    {room.code}
                  </text>
                </g>
              );
            })}

            {/* E. Pulsing Radar Pin on Selected Room */}
            {selectedRoom && selectedRoom.floor === currentFloorNumber && (
              <g
                transform={`translate(${selectedRoom.pinPosition.x}, ${selectedRoom.pinPosition.y})`}
                className="pointer-events-none"
              >
                {/* Outer expanding ripple */}
                <circle
                  r="18"
                  fill="none"
                  stroke="#3d38f5"
                  strokeWidth="2"
                  className="animate-ping opacity-75"
                />
                {/* Secondary soft aura */}
                <circle r="12" fill="#3d38f5" fillOpacity="0.2" />
                {/* Solid Core Dot */}
                <circle
                  r="6"
                  fill="#3d38f5"
                  stroke="#ffffff"
                  strokeWidth="2"
                  className="drop-shadow-md"
                />
              </g>
            )}
          </svg>
        </div>
      </div>

      {/* 4. FLOATING BOTTOM DETAIL CARD (Mappedin Style) */}
      {selectedRoom && (
        <div className="absolute bottom-3 inset-x-3 z-30 pointer-events-auto animate-in slide-in-from-bottom-3 duration-200">
          <div className="bg-white/95 backdrop-blur-xl border border-neutral-200/90 rounded-2xl p-4 shadow-[0_12px_36px_rgba(0,0,0,0.12)] space-y-3 font-gt-standard">
            {/* Top Row: Category Pill & Floor Badge */}
            <div className="flex items-center justify-between gap-2">
              <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#eef0ff] text-[#3d38f5] text-[11.5px] font-bold">
                {getCategoryIcon(selectedRoom.category)}
                <span>{selectedRoom.categoryLabel}</span>
              </div>

              <span className="text-[12px] font-bold text-neutral-500 bg-neutral-100 px-2.5 py-1 rounded-full">
                Lantai {selectedRoom.floor}
              </span>
            </div>

            {/* Room Title & Hint */}
            <div>
              <h3 className="font-bold text-[16px] text-slate-900 leading-snug">
                {selectedRoom.name}
              </h3>
              <p className="text-[12.5px] text-slate-500 font-normal leading-relaxed mt-0.5">
                {selectedRoom.hint}
              </p>
            </div>

            {/* Kumo UI Action Button: Gunakan Titik Temu Ini */}
            <button
              type="button"
              onClick={() => {
                triggerHaptic('medium');
                if (onSelectLocation) {
                  onSelectLocation(selectedRoom);
                } else {
                  alert(`Titik Temu Terpilih: ${selectedRoom.name} (Lantai ${selectedRoom.floor})`);
                }
              }}
              className="relative w-full h-11 px-4 rounded-xl text-white font-bold text-[13.5px] bg-[#3d38f5] border border-[#312bd9] shadow-md shadow-indigo-500/25 active:scale-[0.97] transition-transform flex items-center justify-center gap-2 cursor-pointer overflow-hidden group select-none"
            >
              {/* Inset Top Rim Highlight */}
              <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#5550f7] to-[#3d38f5] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#4944f6] pointer-events-none" />
              <Check className="relative z-10 w-4.5 h-4.5 stroke-[2.4]" />
              <span className="relative z-10">Gunakan Titik Temu Ini</span>
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

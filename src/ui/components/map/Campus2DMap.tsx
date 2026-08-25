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
  Layers,
  ArrowLeft,
} from 'lucide-react';
import {
  SCHOOL_BUILDING_OUTLINES,
  SCHOOL_FLOORS,
  RoomZone,
  FloorData,
} from '@/data/mockSchoolMapData';
import { triggerHaptic } from '@/utils/haptics';

interface Campus2DMapProps {
  onBack?: () => void;
  onSelectSpot?: (room: RoomZone) => void;
}

export const Campus2DMap: React.FC<Campus2DMapProps> = ({
  onBack,
  onSelectSpot,
}) => {
  // Current Floor State: 1 or 2
  const [currentFloorNumber, setCurrentFloorNumber] = useState<number>(1);
  const currentFloor: FloorData =
    SCHOOL_FLOORS.find((f) => f.floor === currentFloorNumber) || SCHOOL_FLOORS[0];

  // Selected Room State
  const [selectedRoom, setSelectedRoom] = useState<RoomZone | null>(() => {
    return (
      currentFloor.rooms.find((r) => r.isPopularCodSpot) ||
      currentFloor.rooms[0] ||
      null
    );
  });

  // Active Category Filter
  const [activeCategory, setActiveCategory] = useState<string>('all');

  // Canvas Pan & Zoom State
  const [zoom, setZoom] = useState<number>(1);
  const [pan, setPan] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const isDraggingRef = useRef<boolean>(false);
  const startPanRef = useRef<{ x: number; y: number }>({ x: 0, y: 0 });
  const containerRef = useRef<HTMLDivElement>(null);

  // Smoothly center on selected room
  const centerOnRoom = (room: RoomZone) => {
    // SVG viewBox: 1100 x 850 -> Center is (550, 425)
    const targetX = (550 - room.pinPosition.x) * 0.7;
    const targetY = (425 - room.pinPosition.y) * 0.7;
    setPan({ x: targetX, y: targetY });
    setZoom(1.2);
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
      const firstRoom =
        targetFloor.rooms.find((r) => r.isPopularCodSpot) || targetFloor.rooms[0];
      setSelectedRoom(firstRoom);
      centerOnRoom(firstRoom);
    }
  };

  // Zoom handlers
  const handleZoomIn = () => {
    triggerHaptic('light');
    setZoom((z) => Math.min(2.5, +(z + 0.25).toFixed(2)));
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

  // Touch & Mouse Drag Handlers
  const handlePointerDown = (clientX: number, clientY: number) => {
    isDraggingRef.current = true;
    startPanRef.current = { x: clientX - pan.x, y: clientY - pan.y };
  };

  const handlePointerMove = (clientX: number, clientY: number) => {
    if (!isDraggingRef.current) return;
    const newX = clientX - startPanRef.current.x;
    const newY = clientY - startPanRef.current.y;
    setPan({
      x: Math.max(-380, Math.min(380, newX)),
      y: Math.max(-320, Math.min(320, newY)),
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
      className="fixed inset-0 z-50 w-screen h-screen bg-[#f1f5f9] overflow-hidden select-none font-gt-standard touch-none"
    >
      {/* 1. TOP FLOATING BAR: Back Button, School Name, Category Filters & Floor Switcher */}
      <div className="absolute top-3.5 inset-x-3.5 z-40 flex items-center justify-between gap-2 pointer-events-auto">
        {/* Left: Back Button & School Info */}
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => {
              triggerHaptic('light');
              if (onBack) onBack();
              else window.history.back();
            }}
            className="w-10 h-10 rounded-2xl bg-white/95 backdrop-blur-xl border border-neutral-200/90 text-slate-800 hover:bg-white active:scale-90 flex items-center justify-center transition-all shadow-md cursor-pointer shrink-0"
            aria-label="Kembali"
          >
            <ArrowLeft className="w-5 h-5 stroke-[2.4]" />
          </button>

          <div className="bg-white/95 backdrop-blur-xl border border-neutral-200/90 px-3 py-2 rounded-2xl shadow-md hidden sm:flex items-center gap-1.5 text-[12px] font-bold text-slate-800">
            <MapPin className="w-3.5 h-3.5 text-[#3d38f5]" />
            <span>SMKN 8 Semarang (2D Blueprint)</span>
          </div>
        </div>

        {/* Center: Category Chips (Scrollable) */}
        <div className="flex items-center gap-1.5 overflow-x-auto scrollbar-none py-1 max-w-[50%] sm:max-w-[42%]">
          {[
            { id: 'all', label: 'Semua Spot' },
            { id: 'canteen', label: 'Kantin' },
            { id: 'lab', label: 'Lab RPL/DKV' },
            { id: 'lobby', label: 'Lobi' },
            { id: 'outdoor', label: 'Gazebo' },
          ].map((cat) => (
            <button
              key={cat.id}
              type="button"
              onClick={() => {
                triggerHaptic('light');
                setActiveCategory(cat.id);
              }}
              className={`px-3 py-1.5 rounded-full text-[11.5px] font-bold shrink-0 transition-all cursor-pointer shadow-2xs ${
                activeCategory === cat.id
                  ? 'bg-slate-900 text-white'
                  : 'bg-white/95 backdrop-blur-md text-slate-700 border border-neutral-200/80 hover:bg-neutral-50'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Right: Floor Selector Pill (Lt 1 / Lt 2) */}
        <div className="bg-white/95 backdrop-blur-xl border border-neutral-200/90 p-1 rounded-2xl shadow-md flex items-center gap-0.5 shrink-0">
          <div className="hidden sm:flex items-center gap-1 px-1.5 text-[10px] font-bold text-neutral-400">
            <Layers className="w-3 h-3 text-[#3d38f5]" />
          </div>
          {[1, 2].map((fNum) => (
            <button
              key={fNum}
              type="button"
              onClick={() => handleFloorChange(fNum)}
              className={`px-3 py-1 rounded-xl text-[11.5px] font-bold transition-all cursor-pointer ${
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
      <div className="absolute right-3.5 top-18 z-40 flex flex-col gap-1.5 pointer-events-auto">
        <button
          type="button"
          onClick={handleZoomIn}
          className="w-10 h-10 rounded-xl bg-white/95 backdrop-blur-xl border border-neutral-200/90 shadow-md text-slate-700 hover:text-slate-900 hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Zoom In"
        >
          <ZoomIn className="w-5 h-5 stroke-[2.2]" />
        </button>
        <button
          type="button"
          onClick={handleZoomOut}
          className="w-10 h-10 rounded-xl bg-white/95 backdrop-blur-xl border border-neutral-200/90 shadow-md text-slate-700 hover:text-slate-900 hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Zoom Out"
        >
          <ZoomOut className="w-5 h-5 stroke-[2.2]" />
        </button>
        <button
          type="button"
          onClick={handleResetView}
          className="w-10 h-10 rounded-xl bg-white/95 backdrop-blur-xl border border-neutral-200/90 shadow-md text-slate-700 hover:text-slate-900 hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Reset Tampilan"
          title="Pusatkan Peta"
        >
          <Compass className="w-5 h-5 stroke-[2.2] text-[#3d38f5]" />
        </button>
      </div>

      {/* 3. PURE TOP-DOWN 2D ARCHITECTURAL SVG MAP VIEWPORT */}
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
            viewBox="0 0 1150 880"
            className="w-[98%] max-w-[860px] h-auto drop-shadow-sm select-none"
          >
            {/* A. Background Ground Canvas */}
            <rect width="1150" height="880" fill="#f1f5f9" />

            {/* B. Roadways: Jl. Pandanaran 2 on West and Connector on North */}
            {/* West Road (Jl. Pandanaran 2) */}
            <rect x="0" y="0" width="85" height="880" fill="#e2e8f0" />
            <line x1="42" y1="0" x2="42" y2="880" stroke="#ffffff" strokeWidth="2.5" strokeDasharray="14 10" />
            <text
              x="-440"
              y="52"
              transform="rotate(-90)"
              textAnchor="middle"
              className="text-[11px] font-bold fill-slate-400 tracking-[0.25em] select-none pointer-events-none"
            >
              JL. PANDANARAN 2
            </text>

            {/* North Road (Connector) */}
            <rect x="0" y="0" width="1150" height="65" fill="#e2e8f0" />
            <line x1="0" y1="32" x2="1150" y2="32" stroke="#ffffff" strokeWidth="2.5" strokeDasharray="14 10" />

            {/* Sidewalk border lines */}
            <line x1="85" y1="65" x2="85" y2="880" stroke="#cbd5e1" strokeWidth="2" />
            <line x1="85" y1="65" x2="1150" y2="65" stroke="#cbd5e1" strokeWidth="2" />

            {/* C. School Courtyard / Green Lawn & Basketball/Futsal Court */}
            {/* Green Lawn */}
            <rect x="290" y="240" width="370" height="340" rx="16" fill="#dcfce7" stroke="#bbf7d0" strokeWidth="2" />

            {/* Sports Court in Center */}
            <rect x="330" y="270" width="290" height="180" rx="8" fill="#d1fae5" stroke="#86efac" strokeWidth="2" />
            <line x1="475" y1="270" x2="475" y2="450" stroke="#ffffff" strokeWidth="2" />
            <circle cx="475" cy="360" r="32" fill="none" stroke="#ffffff" strokeWidth="2" />
            <rect x="330" y="320" width="40" height="80" fill="none" stroke="#ffffff" strokeWidth="2" />
            <rect x="580" y="320" width="40" height="80" fill="none" stroke="#ffffff" strokeWidth="2" />

            <text
              x="475"
              y="225"
              textAnchor="middle"
              className="text-[12px] font-bold fill-emerald-800/60 tracking-[0.2em] select-none pointer-events-none uppercase"
            >
              LAPANGAN UPACARA & OLAHRAGA
            </text>

            {/* D. Base Architectural Building Outlines (Warm Stone Neutral) */}
            {SCHOOL_BUILDING_OUTLINES.map((bldg) => (
              <path
                key={bldg.id}
                d={bldg.path}
                fill="#f8fafc"
                stroke="#cbd5e1"
                strokeWidth="3"
                strokeLinejoin="round"
              />
            ))}

            {/* Special Roof Lines for Central Joglo/Limasan Hall */}
            <g className="pointer-events-none opacity-40">
              <line x1="324" y1="435" x2="490" y2="480" stroke="#94a3b8" strokeWidth="1.5" strokeDasharray="4 3" />
              <line x1="658" y1="418" x2="490" y2="480" stroke="#94a3b8" strokeWidth="1.5" strokeDasharray="4 3" />
              <line x1="660" y1="522" x2="490" y2="480" stroke="#94a3b8" strokeWidth="1.5" strokeDasharray="4 3" />
              <line x1="328" y1="540" x2="490" y2="480" stroke="#94a3b8" strokeWidth="1.5" strokeDasharray="4 3" />
            </g>

            {/* Canteen Tables Markings (Yellow/Warm Squares) */}
            <g className="pointer-events-none opacity-70">
              {[
                { x: 620, y: 680 },
                { x: 650, y: 700 },
                { x: 680, y: 720 },
                { x: 600, y: 710 },
                { x: 630, y: 730 },
              ].map((tb, i) => (
                <rect
                  key={i}
                  x={tb.x}
                  y={tb.y}
                  width="12"
                  height="12"
                  rx="2"
                  fill="#fef08a"
                  stroke="#eab308"
                  strokeWidth="1"
                />
              ))}
            </g>

            {/* E. Interactive Hotspot Rooms */}
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
                    isDimmed ? 'opacity-30' : 'opacity-100'
                  }`}
                >
                  {/* Room Polygon */}
                  <path
                    d={room.path}
                    fill={isSelected ? '#eef0ff' : '#ffffff'}
                    stroke={isSelected ? '#3d38f5' : '#94a3b8'}
                    strokeWidth={isSelected ? '3.5' : '1.5'}
                    strokeLinejoin="round"
                    className="hover:fill-[#f1f5f9] transition-colors"
                  />

                  {/* Room Label */}
                  <text
                    x={room.pinPosition.x}
                    y={room.pinPosition.y - 8}
                    textAnchor="middle"
                    className={`text-[11.5px] font-bold select-none pointer-events-none tracking-tight ${
                      isSelected ? 'fill-[#3d38f5]' : 'fill-slate-800'
                    }`}
                  >
                    {room.code}
                  </text>
                </g>
              );
            })}

            {/* F. Pulsing Radar Pin on Selected Room */}
            {selectedRoom && selectedRoom.floor === currentFloorNumber && (
              <g
                transform={`translate(${selectedRoom.pinPosition.x}, ${selectedRoom.pinPosition.y + 6})`}
                className="pointer-events-none"
              >
                {/* Outer Ripple */}
                <circle
                  r="22"
                  fill="none"
                  stroke="#3d38f5"
                  strokeWidth="2.5"
                  className="animate-ping opacity-75"
                />
                {/* Soft Glow */}
                <circle r="14" fill="#3d38f5" fillOpacity="0.2" />
                {/* Core Dot */}
                <circle
                  r="7.5"
                  fill="#3d38f5"
                  stroke="#ffffff"
                  strokeWidth="2.5"
                  className="drop-shadow-md"
                />
              </g>
            )}
          </svg>
        </div>
      </div>

      {/* 4. FLOATING BOTTOM DETAIL CARD */}
      {selectedRoom && (
        <div className="absolute bottom-3.5 inset-x-3.5 max-w-[520px] mx-auto z-40 pointer-events-auto animate-in slide-in-from-bottom-3 duration-200">
          <div className="bg-white/95 backdrop-blur-2xl border border-neutral-200/90 rounded-2xl p-4 shadow-[0_12px_40px_rgba(0,0,0,0.12)] space-y-3 font-gt-standard">
            {/* Top Row: Category & Building Badges */}
            <div className="flex items-center justify-between gap-2">
              <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#eef0ff] text-[#3d38f5] text-[11.5px] font-bold">
                {getCategoryIcon(selectedRoom.category)}
                <span>{selectedRoom.categoryLabel}</span>
              </div>

              <span className="text-[11.5px] font-bold text-neutral-500 bg-neutral-100 px-2.5 py-1 rounded-full">
                {selectedRoom.buildingName} · Lt {selectedRoom.floor}
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

            {/* Kumo UI Action Button */}
            <button
              type="button"
              onClick={() => {
                triggerHaptic('medium');
                if (onSelectSpot) {
                  onSelectSpot(selectedRoom);
                } else {
                  alert(`Titik COD Terkunci: ${selectedRoom.name} (${selectedRoom.buildingName} - Lantai ${selectedRoom.floor})`);
                }
              }}
              className="relative w-full h-11 px-4 rounded-xl text-white font-bold text-[13.5px] bg-[#3d38f5] border border-[#312bd9] shadow-md active:scale-[0.98] transition-transform flex items-center justify-center gap-2 cursor-pointer overflow-hidden group select-none"
            >
              <Check className="w-4.5 h-4.5 stroke-[2.4]" />
              <span>Gunakan Titik Temu Ini</span>
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

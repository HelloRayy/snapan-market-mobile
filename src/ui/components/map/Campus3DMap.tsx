import React, { useEffect, useRef, useState } from 'react';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { Compass, ZoomIn, ZoomOut, Layers, Check, ArrowLeft } from 'lucide-react';
import { SCHOOL_FLOORS, RoomZone } from '@/data/mockSchoolMapData';
import { triggerHaptic } from '@/utils/haptics';

interface Campus3DMapProps {
  onBack?: () => void;
  onSelectSpot?: (room: RoomZone) => void;
}

export const Campus3DMap: React.FC<Campus3DMapProps> = ({
  onBack,
  onSelectSpot,
}) => {
  const mountRef = useRef<HTMLDivElement>(null);
  const [selectedRoom, setSelectedRoom] = useState<RoomZone | null>(null);
  const [currentFloor, setCurrentFloor] = useState<number>(1);

  // References for Three.js instances
  const sceneRef = useRef<THREE.Scene | null>(null);
  const cameraRef = useRef<THREE.PerspectiveCamera | null>(null);
  const rendererRef = useRef<THREE.WebGLRenderer | null>(null);
  const controlsRef = useRef<OrbitControls | null>(null);
  const meshMapRef = useRef<Map<string, THREE.Mesh>>(new Map());
  const raycasterRef = useRef<THREE.Raycaster>(new THREE.Raycaster());
  const mouseRef = useRef<THREE.Vector2>(new THREE.Vector2());
  const markerGroupRef = useRef<THREE.Group | null>(null);

  // Floor data
  const floorData = SCHOOL_FLOORS.find((f) => f.floor === currentFloor) || SCHOOL_FLOORS[0];

  useEffect(() => {
    if (!mountRef.current) return;
    const container = mountRef.current;
    const width = container.clientWidth || window.innerWidth;
    const height = container.clientHeight || window.innerHeight;

    // 1. Scene Setup
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0xf4f8fa);
    sceneRef.current = scene;

    // 2. Camera Setup (2.5D Isometric Perspective)
    const camera = new THREE.PerspectiveCamera(40, width / height, 1, 3000);
    camera.position.set(0, 480, 520);
    camera.lookAt(0, 0, 0);
    cameraRef.current = camera;

    // 3. WebGL Renderer with High-DPI & Antialiasing
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'high-performance' });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    container.appendChild(renderer.domElement);
    rendererRef.current = renderer;

    // 4. OrbitControls with Momentum Physics (Mappedin Style)
    const controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.06; // Kinetic smooth deceleration
    controls.screenSpacePanning = true;
    controls.maxPolarAngle = Math.PI / 2.3; // Prevent going below ground
    controls.minDistance = 150;
    controls.maxDistance = 900;
    controls.target.set(0, 0, 0);
    controlsRef.current = controls;

    // 5. Lighting: Ambient + Directional Key Light with Soft Shadows
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.85);
    scene.add(ambientLight);

    const dirLight = new THREE.DirectionalLight(0xffffff, 0.95);
    dirLight.position.set(200, 450, 250);
    dirLight.castShadow = true;
    dirLight.shadow.mapSize.width = 1024;
    dirLight.shadow.mapSize.height = 1024;
    dirLight.shadow.camera.near = 10;
    dirLight.shadow.camera.far = 1000;
    dirLight.shadow.camera.left = -400;
    dirLight.shadow.camera.right = 400;
    dirLight.shadow.camera.top = 400;
    dirLight.shadow.camera.bottom = -400;
    dirLight.shadow.bias = -0.001;
    scene.add(dirLight);

    // 6. Ground Base Plane (Pale School Campus Yard)
    const groundGeo = new THREE.PlaneGeometry(1200, 1000);
    const groundMat = new THREE.MeshStandardMaterial({
      color: 0xeef3f6,
      roughness: 0.9,
    });
    const ground = new THREE.Mesh(groundGeo, groundMat);
    ground.rotation.x = -Math.PI / 2;
    ground.position.y = -0.5;
    ground.receiveShadow = true;
    scene.add(ground);

    // Subtle Ground Grid
    const grid = new THREE.GridHelper(1000, 25, 0xd8e2e8, 0xe2ebf0);
    grid.position.y = 0.1;
    scene.add(grid);

    // 7. Pulsing 3D Pin Marker Group
    const markerGroup = new THREE.Group();
    scene.add(markerGroup);
    markerGroupRef.current = markerGroup;

    // Marker Pin Core Mesh
    const pinGeo = new THREE.ConeGeometry(8, 20, 16);
    pinGeo.rotateX(Math.PI);
    const pinMat = new THREE.MeshStandardMaterial({
      color: 0x3d38f5,
      emissive: 0x3d38f5,
      emissiveIntensity: 0.4,
      roughness: 0.2,
    });
    const pinMesh = new THREE.Mesh(pinGeo, pinMat);
    pinMesh.position.y = 28;
    markerGroup.add(pinMesh);

    // Marker Floating Ring
    const ringGeo = new THREE.RingGeometry(8, 12, 24);
    ringGeo.rotateX(-Math.PI / 2);
    const ringMat = new THREE.MeshBasicMaterial({
      color: 0x3d38f5,
      side: THREE.DoubleSide,
      transparent: true,
      opacity: 0.6,
    });
    const ringMesh = new THREE.Mesh(ringGeo, ringMat);
    ringMesh.position.y = 2;
    markerGroup.add(ringMesh);
    markerGroup.visible = false;

    // 8. Build 2.5D Extruded Building Geometry
    const buildFloorMeshes = () => {
      // Clear previous meshes
      meshMapRef.current.forEach((mesh) => scene.remove(mesh));
      meshMapRef.current.clear();

      // SVG scale & offset to center around (0,0) in 3D world
      const scale = 0.85;
      const offsetX = 510;
      const offsetY = 400;

      // Coordinate converter helper from SVG to 3D world (X, Z)
      const to3D = (svgX: number, svgY: number) => {
        return {
          x: (svgX - offsetX) * scale,
          z: (svgY - offsetY) * scale,
        };
      };

      // Create Extruded 3D Building Meshes
      floorData.rooms.forEach((room) => {
        // Parse simple SVG Path coordinates
        const points = room.path
          .replace(/[MLZ]/g, ' ')
          .trim()
          .split(/\s+/)
          .map(Number);

        if (points.length >= 6) {
          const shape = new THREE.Shape();
          const start = to3D(points[0], points[1]);
          shape.moveTo(start.x, -start.z);

          for (let i = 2; i < points.length; i += 2) {
            if (!isNaN(points[i]) && !isNaN(points[i + 1])) {
              const pt = to3D(points[i], points[i + 1]);
              shape.lineTo(pt.x, -pt.z);
            }
          }
          shape.closePath();

          const extrudeSettings = {
            depth: 28, // Extrusion height for 2.5D walls
            bevelEnabled: true,
            bevelSegments: 2,
            steps: 1,
            bevelSize: 1,
            bevelThickness: 1.2,
          };

          const geo = new THREE.ExtrudeGeometry(shape, extrudeSettings);
          geo.rotateX(-Math.PI / 2); // Lay flat on ground

          const isSelected = selectedRoom?.id === room.id;
          const mat = new THREE.MeshStandardMaterial({
            color: isSelected ? 0x3d38f5 : 0xe4e2dc,
            roughness: 0.55,
            metalness: 0.1,
          });

          const mesh = new THREE.Mesh(geo, mat);
          mesh.castShadow = true;
          mesh.receiveShadow = true;
          (mesh as any).userData = { room };

          scene.add(mesh);
          meshMapRef.current.set(room.id, mesh);
        }
      });
    };

    buildFloorMeshes();

    // 9. Animation & Render Loop
    let animationFrameId: number;
    let clock = new THREE.Clock();

    const animate = () => {
      animationFrameId = requestAnimationFrame(animate);
      const elapsedTime = clock.getElapsedTime();

      // Pulse the 3D pin marker
      if (markerGroup.visible) {
        ringMesh.scale.setScalar(1 + Math.sin(elapsedTime * 4) * 0.25);
        pinMesh.position.y = 28 + Math.sin(elapsedTime * 3) * 3;
      }

      controls.update();
      renderer.render(scene, camera);
    };
    animate();

    // 10. Pointer Click Detection (Raycasting)
    const handlePointerClick = (e: MouseEvent | TouchEvent) => {
      const rect = renderer.domElement.getBoundingClientRect();
      const clientX = 'touches' in e ? e.changedTouches[0].clientX : e.clientX;
      const clientY = 'touches' in e ? e.changedTouches[0].clientY : e.clientY;

      mouseRef.current.x = ((clientX - rect.left) / rect.width) * 2 - 1;
      mouseRef.current.y = -((clientY - rect.top) / rect.height) * 2 + 1;

      raycasterRef.current.setFromCamera(mouseRef.current, camera);
      const meshes = Array.from(meshMapRef.current.values());
      const intersects = raycasterRef.current.intersectObjects(meshes);

      if (intersects.length > 0) {
        const hitMesh = intersects[0].object as THREE.Mesh;
        const room: RoomZone = (hitMesh as any).userData?.room;
        if (room) {
          triggerHaptic('light');
          setSelectedRoom(room);

          // Update colors: Reset all, highlight clicked
          meshMapRef.current.forEach((m, id) => {
            const mMat = m.material as THREE.MeshStandardMaterial;
            if (id === room.id) {
              mMat.color.setHex(0x3d38f5);
              mMat.emissive.setHex(0x1a1680);
              mMat.emissiveIntensity = 0.25;
            } else {
              mMat.color.setHex(0xe4e2dc);
              mMat.emissive.setHex(0x000000);
            }
          });

          // Position 3D Pin Marker above clicked room
          const scale = 0.85;
          const target3D = {
            x: (room.pinPosition.x - 510) * scale,
            z: (room.pinPosition.y - 400) * scale,
          };
          markerGroup.position.set(target3D.x, 30, target3D.z);
          markerGroup.visible = true;

          // Smooth Camera Focus on Clicked Room
          const currentTarget = controls.target;
          const startTime = performance.now();
          const duration = 400;

          const animateCamera = (now: number) => {
            const t = Math.min(1, (now - startTime) / duration);
            const ease = 1 - Math.pow(1 - t, 3); // Ease Out Cubic
            controls.target.x = THREE.MathUtils.lerp(currentTarget.x, target3D.x, ease);
            controls.target.z = THREE.MathUtils.lerp(currentTarget.z, target3D.z, ease);
            if (t < 1) {
              requestAnimationFrame(animateCamera);
            }
          };
          requestAnimationFrame(animateCamera);
        }
      }
    };

    const dom = renderer.domElement;
    dom.addEventListener('click', handlePointerClick);

    // 11. Handle Screen Resize
    const handleResize = () => {
      if (!mountRef.current || !renderer || !camera) return;
      const w = mountRef.current.clientWidth || window.innerWidth;
      const h = mountRef.current.clientHeight || window.innerHeight;
      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
    };
    window.addEventListener('resize', handleResize);

    // Cleanup on unmount
    return () => {
      cancelAnimationFrame(animationFrameId);
      window.removeEventListener('resize', handleResize);
      dom.removeEventListener('click', handlePointerClick);
      controls.dispose();
      renderer.dispose();
      if (container.contains(dom)) {
        container.removeChild(dom);
      }
    };
  }, [currentFloor]);

  // Reset Camera View
  const handleResetCamera = () => {
    triggerHaptic('light');
    if (!controlsRef.current || !cameraRef.current) return;
    cameraRef.current.position.set(0, 480, 520);
    controlsRef.current.target.set(0, 0, 0);
  };

  const handleZoomIn = () => {
    triggerHaptic('light');
    if (!cameraRef.current) return;
    cameraRef.current.position.multiplyScalar(0.85);
  };

  const handleZoomOut = () => {
    triggerHaptic('light');
    if (!cameraRef.current) return;
    cameraRef.current.position.multiplyScalar(1.18);
  };

  return (
    <div className="fixed inset-0 z-50 w-screen h-screen bg-[#f4f8fa] overflow-hidden select-none font-gt-standard">
      {/* 1. Top Left Floating Back Button */}
      <div className="absolute top-4 left-4 z-40">
        <button
          type="button"
          onClick={() => {
            triggerHaptic('light');
            if (onBack) onBack();
            else window.history.back();
          }}
          className="w-10 h-10 rounded-2xl bg-white/90 backdrop-blur-xl border border-neutral-200/90 text-slate-800 hover:bg-white active:scale-90 flex items-center justify-center transition-all shadow-md cursor-pointer"
          aria-label="Kembali"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.4]" />
        </button>
      </div>

      {/* 2. Top Right Floating Floor Switcher */}
      <div className="absolute top-4 right-4 z-40 bg-white/90 backdrop-blur-xl border border-neutral-200/90 p-1 rounded-2xl shadow-md flex items-center gap-1 select-none">
        <div className="flex items-center gap-1 px-2 py-1 text-[10.5px] font-bold text-neutral-400">
          <Layers className="w-3.5 h-3.5 text-[#3d38f5]" />
          <span>LANTAI</span>
        </div>
        {[1, 2].map((fNum) => (
          <button
            key={fNum}
            type="button"
            onClick={() => {
              triggerHaptic('medium');
              setCurrentFloor(fNum);
            }}
            className={`px-3 py-1.5 rounded-xl text-[12px] font-bold transition-all cursor-pointer ${
              currentFloor === fNum
                ? 'bg-[#3d38f5] text-white shadow-2xs'
                : 'text-slate-700 hover:bg-neutral-100'
            }`}
          >
            Lt {fNum}
          </button>
        ))}
      </div>

      {/* 3. Floating Camera Controls (Compass Reset, Zoom In, Zoom Out) */}
      <div className="absolute right-4 bottom-24 z-40 flex flex-col gap-1.5 pointer-events-auto">
        <button
          type="button"
          onClick={handleZoomIn}
          className="w-10 h-10 rounded-xl bg-white/90 backdrop-blur-xl border border-neutral-200/90 shadow-md text-slate-700 hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Zoom In"
        >
          <ZoomIn className="w-5 h-5 stroke-[2.2]" />
        </button>
        <button
          type="button"
          onClick={handleZoomOut}
          className="w-10 h-10 rounded-xl bg-white/90 backdrop-blur-xl border border-neutral-200/90 shadow-md text-slate-700 hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Zoom Out"
        >
          <ZoomOut className="w-5 h-5 stroke-[2.2]" />
        </button>
        <button
          type="button"
          onClick={handleResetCamera}
          className="w-10 h-10 rounded-xl bg-white/90 backdrop-blur-xl border border-neutral-200/90 shadow-md text-[#3d38f5] hover:bg-white active:scale-90 flex items-center justify-center transition-all cursor-pointer"
          aria-label="Reset Tampilan Kamera"
          title="Pusatkan Kamera"
        >
          <Compass className="w-5 h-5 stroke-[2.4]" />
        </button>
      </div>

      {/* 4. Three.js WebGL 2.5D Canvas Container */}
      <div ref={mountRef} className="w-full h-full cursor-grab active:cursor-grabbing" />

      {/* 5. Floating Bottom Detail Card (When a Room is Clicked) */}
      {selectedRoom && (
        <div className="absolute bottom-4 inset-x-4 max-w-[500px] mx-auto z-40 animate-in slide-in-from-bottom-3 duration-200">
          <div className="bg-white/95 backdrop-blur-2xl border border-neutral-200/90 rounded-2xl p-4 shadow-[0_12px_40px_rgba(0,0,0,0.12)] space-y-2.5">
            <div className="flex items-center justify-between gap-2">
              <span className="text-[11.5px] font-bold text-[#3d38f5] bg-[#eef0ff] px-2.5 py-1 rounded-full">
                {selectedRoom.categoryLabel}
              </span>
              <span className="text-[11.5px] font-bold text-neutral-500 bg-neutral-100 px-2.5 py-1 rounded-full">
                {selectedRoom.buildingName} · Lt {selectedRoom.floor}
              </span>
            </div>

            <div>
              <h3 className="font-bold text-[16px] text-slate-900 leading-snug">
                {selectedRoom.name}
              </h3>
              <p className="text-[12px] text-slate-500 font-normal leading-relaxed mt-0.5">
                {selectedRoom.hint}
              </p>
            </div>

            <button
              type="button"
              onClick={() => {
                triggerHaptic('medium');
                if (onSelectSpot) {
                  onSelectSpot(selectedRoom);
                } else {
                  alert(`Titik COD Terpilih: ${selectedRoom.name}`);
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

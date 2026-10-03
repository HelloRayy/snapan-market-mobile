import { useState, useRef, useEffect } from 'react';

export type UserRole = 'user' | 'admin' | 'buyer' | 'seller';

interface RoleSelectDropdownProps {
  currentRole: UserRole;
  onChangeRole: (newRole: UserRole) => void;
  disabled?: boolean;
}

const ROLE_OPTIONS = [
  {
    id: 'user' as const,
    title: 'Siswa / Warga Sekolah',
    desc: 'Akses penuh C2C: bebas beli & jual produk, posting utas sosial, dan transaksi COD.',
    icon: 'fa-user-graduate',
    badgeBg: '#f0fdf4',
    badgeColor: '#16a34a',
  },
  {
    id: 'admin' as const,
    title: 'Staff Admin',
    desc: 'Akses penuh ke portal manajemen, moderasi konten, dan sistem sekolah.',
    icon: 'fa-shield-halved',
    badgeBg: '#eff6ff',
    badgeColor: '#2563eb',
  },
];

export function RoleSelectDropdown({
  currentRole,
  onChangeRole,
  disabled = false,
}: RoleSelectDropdownProps) {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  const normalizedRole = currentRole === 'buyer' || currentRole === 'seller' ? 'user' : currentRole;
  const selectedOption =
    ROLE_OPTIONS.find((opt) => opt.id === normalizedRole) || ROLE_OPTIONS[0];

  useEffect(() => {
    const handleOutsideClick = (e: MouseEvent) => {
      if (
        containerRef.current &&
        !containerRef.current.contains(e.target as Node)
      ) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleOutsideClick);
    }
    return () => {
      document.removeEventListener('mousedown', handleOutsideClick);
    };
  }, [isOpen]);

  const handleSelect = (role: UserRole) => {
    if (disabled || role === currentRole) {
      setIsOpen(false);
      return;
    }
    onChangeRole(role);
    setIsOpen(false);
  };

  return (
    <div ref={containerRef} style={{ position: 'relative', width: '100%' }}>
      {/* Dropdown Input Trigger */}
      <button
        type="button"
        disabled={disabled}
        onClick={() => setIsOpen((prev) => !prev)}
        style={{
          width: '100%',
          height: '44px',
          padding: '0 14px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          background: '#ffffff',
          border: isOpen ? '1.5px solid #4272d7' : '1px solid #e4e7ec',
          borderRadius: '8px',
          boxShadow: isOpen
            ? '0 0 0 3px rgba(66, 114, 215, 0.15)'
            : '0 1px 2px rgba(0, 0, 0, 0.04)',
          cursor: disabled ? 'not-allowed' : 'pointer',
          opacity: disabled ? 0.6 : 1,
          transition: 'all 150ms ease',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div
            style={{
              width: '26px',
              height: '26px',
              borderRadius: '6px',
              background: selectedOption.badgeBg,
              color: selectedOption.badgeColor,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '12px',
            }}
          >
            <i className={`fa-solid ${selectedOption.icon}`}></i>
          </div>
          <span style={{ fontSize: '13.5px', fontWeight: 600, color: '#1f2937' }}>
            {selectedOption.title}
          </span>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span
            style={{
              fontSize: '11px',
              fontWeight: 700,
              textTransform: 'uppercase',
              padding: '2px 8px',
              borderRadius: '4px',
              background: selectedOption.badgeBg,
              color: selectedOption.badgeColor,
            }}
          >
            {selectedOption.id}
          </span>
          <i
            className="fa-solid fa-chevron-down"
            style={{
              fontSize: '12px',
              color: '#64748b',
              transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)',
              transition: 'transform 200ms ease',
            }}
          ></i>
        </div>
      </button>

      {/* Dropdown Menu (When Open) */}
      {isOpen && (
        <div
          style={{
            position: 'absolute',
            top: 'calc(100% + 6px)',
            left: 0,
            right: 0,
            zIndex: 100,
            background: '#ffffff',
            border: '1px solid #e2e8f0',
            borderRadius: '8px',
            boxShadow: '0 12px 28px rgba(0, 0, 0, 0.12)',
            padding: '6px',
            display: 'flex',
            flexDirection: 'column',
            gap: '4px',
          }}
        >
          {ROLE_OPTIONS.map((opt) => {
            const isSelected = opt.id === currentRole;
            return (
              <div
                key={opt.id}
                onClick={() => handleSelect(opt.id)}
                style={{
                  display: 'flex',
                  alignItems: 'flex-start',
                  justifyContent: 'space-between',
                  padding: '10px 12px',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  background: isSelected ? '#f0f5ff' : 'transparent',
                  border: isSelected ? '1px solid #c7d9fc' : '1px solid transparent',
                  transition: 'background 120ms ease',
                }}
                onMouseEnter={(e) => {
                  if (!isSelected) e.currentTarget.style.background = '#f8fafc';
                }}
                onMouseLeave={(e) => {
                  if (!isSelected) e.currentTarget.style.background = 'transparent';
                }}
              >
                <div style={{ display: 'flex', gap: '10px' }}>
                  <div
                    style={{
                      width: '28px',
                      height: '28px',
                      borderRadius: '6px',
                      background: opt.badgeBg,
                      color: opt.badgeColor,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '12px',
                      flexShrink: 0,
                      marginTop: '2px',
                    }}
                  >
                    <i className={`fa-solid ${opt.icon}`}></i>
                  </div>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <span
                        style={{
                          fontSize: '13px',
                          fontWeight: 600,
                          color: isSelected ? '#1e40af' : '#1f2937',
                        }}
                      >
                        {opt.title}
                      </span>
                    </div>
                    <p
                      style={{
                        margin: '2px 0 0',
                        fontSize: '11.5px',
                        color: isSelected ? '#3b82f6' : '#64748b',
                        lineHeight: 1.4,
                      }}
                    >
                      {opt.desc}
                    </p>
                  </div>
                </div>

                {isSelected && (
                  <div
                    style={{
                      color: '#2563eb',
                      fontSize: '13px',
                      paddingTop: '4px',
                      paddingRight: '4px',
                    }}
                  >
                    <i className="fa-solid fa-check"></i>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

import React from 'react';
import { Campus2DMap } from '@/ui/components/map/Campus2DMap';

interface CampusMapPageProps {
  onBack?: () => void;
}

export const CampusMapPage: React.FC<CampusMapPageProps> = ({ onBack }) => {
  return <Campus2DMap onBack={onBack} />;
};

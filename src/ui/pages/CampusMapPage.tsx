import React from 'react';
import { Campus3DMap } from '../components/map/Campus3DMap';

interface CampusMapPageProps {
  onBack?: () => void;
}

export const CampusMapPage: React.FC<CampusMapPageProps> = ({ onBack }) => {
  return <Campus3DMap onBack={onBack} />;
};

import React, { useEffect, useRef, useState } from 'react';

const GRADIENTS = [
  ['#6366F1', '#8B5CF6', '#06B6D4'], // Indigo, Purple, Cyan
  ['#F59E0B', '#EF4444', '#6366F1'], // Amber, Red, Indigo
  ['#10B981', '#06B6D4', '#8B5CF6'], // Green, Cyan, Purple
  ['#F472B6', '#6366F1', '#06B6D4'], // Pink, Indigo, Cyan
];

function lerp(a, b, t) {
  return a + (b - a) * t;
}

const BackgroundGradient = () => {
  const [gradient, setGradient] = useState(GRADIENTS[0]);
  const [angle, setAngle] = useState(120);
  const [mouse, setMouse] = useState({ x: 0.5, y: 0.5 });
  const timeoutRef = useRef();

  useEffect(() => {
    const handleMouseMove = (e) => {
      const x = e.clientX / window.innerWidth;
      const y = e.clientY / window.innerHeight;
      setMouse({ x, y });
      setAngle(lerp(90, 270, x));
      // Change gradient palette on fast movement
      clearTimeout(timeoutRef.current);
      timeoutRef.current = setTimeout(() => {
        const idx = Math.floor(y * GRADIENTS.length) % GRADIENTS.length;
        setGradient(GRADIENTS[idx]);
      }, 100);
    };
    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  // 3D effect: use radial gradient overlay
  const radialX = lerp(30, 70, mouse.x);
  const radialY = lerp(30, 70, mouse.y);

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 0,
        pointerEvents: 'none',
        transition: 'background 0.5s',
        background: `linear-gradient(${angle}deg, ${gradient[0]}, ${gradient[1]}, ${gradient[2]})`,
        overflow: 'hidden',
      }}
    >
      <div
        style={{
          position: 'absolute',
          left: 0,
          top: 0,
          width: '100%',
          height: '100%',
          background: `radial-gradient(circle at ${radialX}% ${radialY}%, rgba(255,255,255,0.18) 0%, rgba(0,0,0,0.08) 100%)`,
          filter: 'blur(32px)',
          opacity: 0.8,
          zIndex: 1,
        }}
      />
    </div>
  );
};

export default BackgroundGradient; 
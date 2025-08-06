import React, { useState, useEffect, useCallback } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';
import Home from './pages/Home';
import Devices from './pages/Devices';
import Transfers from './pages/Transfers';
import Settings from './pages/Settings';
import Sidebar from './components/Sidebar';
import { useStore } from './store/store';
import BackgroundGradient from './BackgroundGradient';
import Toast from './components/Toast';

function App() {
  const { initializeApp } = useStore();
  const [isLoading, setIsLoading] = useState(true);
  const [toast, setToast] = useState({ message: '', type: 'info' });

  useEffect(() => {
    const init = async () => {
      try {
        await initializeApp();
      } catch (error) {
        setToast({ message: 'Failed to initialize app', type: 'error' });
        console.error('Failed to initialize app:', error);
      } finally {
        setIsLoading(false);
      }
    };
    init();
  }, [initializeApp]);

  const showToast = useCallback((message, type = 'info') => {
    setToast({ message, type });
  }, []);

  if (isLoading) {
    return (
      <div className="app-loading">
        <div className="loading-spinner"></div>
        <p>Initializing SwiftShare...</p>
      </div>
    );
  }

  return (
    <Router>
      <BackgroundGradient />
      <Toast message={toast.message} type={toast.type} onClose={() => setToast({ message: '', type: 'info' })} />
      <div className="app" style={{ position: 'relative', zIndex: 1 }}>
        <Sidebar />
        <main className="main-content">
          <Routes>
            <Route path="/" element={<Home showToast={showToast} />} />
            <Route path="/devices" element={<Devices showToast={showToast} />} />
            <Route path="/transfers" element={<Transfers showToast={showToast} />} />
            <Route path="/settings" element={<Settings showToast={showToast} />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App; 
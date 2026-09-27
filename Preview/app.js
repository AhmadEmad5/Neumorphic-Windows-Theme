/**
 * NEUMORPHIC DARK SOFT UI — INTERACTIVE CONTROLLER SCRIPT
 * Physics-based rotary dial, dynamic LED visualizer, and tactile sound synthesis
 */

(function () {
  'use strict';

  // State
  let currentVolume = 72; // 0 to 100
  let isDragging = false;
  let isMuted = false;
  let previousVolume = 72;
  const TOTAL_SEGMENTS = 16;

  // DOM Elements
  const knob = document.getElementById('rotaryKnob');
  const pointer = document.getElementById('dialPointer');
  const volumeDisplay = document.getElementById('volumeDisplay');
  const dbDisplay = document.getElementById('dbDisplay');
  const visualizerDock = document.getElementById('segmentedVisualizer');
  const stepDownBtn = document.getElementById('stepDownBtn');
  const stepUpBtn = document.getElementById('stepUpBtn');
  const overlayToggleBtn = document.getElementById('overlayToggleBtn');
  const muteToggleBtn = document.getElementById('muteToggleBtn');
  const card = document.getElementById('neumorphicCard');
  const navBtns = document.querySelectorAll('.nav-pill-btn');

  // Web Audio Context for Tactile Feedback Clicks
  let audioCtx = null;

  function initAudio() {
    if (!audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (AudioContext) {
        audioCtx = new AudioContext();
      }
    }
  }

  function playTactileClick(frequency = 1200) {
    if (!audioCtx) return;
    try {
      if (audioCtx.state === 'suspended') {
        audioCtx.resume();
      }
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(frequency, audioCtx.currentTime);
      gain.gain.setValueAtTime(0.015, audioCtx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + 0.04);
      osc.connect(gain);
      gain.connect(audioCtx.destination);
      osc.start();
      osc.stop(audioCtx.currentTime + 0.04);
    } catch (e) {
      // Audio autoplay policy fallback
    }
  }

  // 1. Build Segmented Visualizer Bars
  const segmentElements = [];
  function buildVisualizer() {
    visualizerDock.innerHTML = '';
    const baseHeight = 12;
    const maxHeight = 28;

    for (let i = 0; i < TOTAL_SEGMENTS; i++) {
      const bar = document.createElement('div');
      bar.classList.add('visualizer-segment');
      
      // Arc curve height distribution
      const progress = i / (TOTAL_SEGMENTS - 1);
      const height = baseHeight + Math.sin(progress * Math.PI) * (maxHeight - baseHeight);
      bar.style.height = `${Math.round(height)}px`;
      
      visualizerDock.appendChild(bar);
      segmentElements.push(bar);
    }
  }

  // 2. Update Interface State
  function renderState() {
    // 0% -> 220° arc sweep (from -110deg to +110deg or 0 to 270)
    // Map volume [0, 100] to angle [-135deg, +135deg]
    const angle = ((currentVolume / 100) * 270) - 135;
    pointer.style.transform = `rotate(${angle}deg)`;

    // Update digital readout
    volumeDisplay.textContent = Math.round(currentVolume);

    // Calculate approximate dB
    let dbText = '-∞ dB';
    if (currentVolume > 0) {
      const db = 20 * Math.log10(currentVolume / 100);
      dbText = `${db.toFixed(1)} dB`;
    }
    dbDisplay.textContent = dbText;

    // Update ARIA
    knob.setAttribute('aria-valuenow', Math.round(currentVolume));

    // Update Visualizer Segment illumination
    const activeCount = Math.round((currentVolume / 100) * TOTAL_SEGMENTS);
    segmentElements.forEach((bar, index) => {
      if (index < activeCount) {
        bar.classList.add('active');
        if (index >= TOTAL_SEGMENTS - 3) {
          bar.classList.add('peak-accent');
        } else {
          bar.classList.remove('peak-accent');
        }
      } else {
        bar.classList.remove('active', 'peak-accent');
      }
    });
  }

  function setVolume(value, playSound = true) {
    const clamped = Math.max(0, Math.min(100, value));
    if (Math.round(clamped) !== Math.round(currentVolume)) {
      if (playSound) playTactileClick(600 + (clamped * 10));
    }
    currentVolume = clamped;
    if (currentVolume > 0 && isMuted) {
      isMuted = false;
      muteToggleBtn.classList.remove('active');
    }
    renderState();
  }

  // 3. Rotary Knob Physics & Drag Calculation
  function calculateAngleFromEvent(e) {
    const rect = knob.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;

    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;

    const deltaX = clientX - centerX;
    const deltaY = clientY - centerY;

    // Invert Y for Cartesian plane
    let rad = Math.atan2(deltaY, deltaX);
    let deg = rad * (180 / Math.PI) + 90; // Top is 0
    if (deg < 0) deg += 360;

    // Active sweep angle: 45deg to 315deg (270 deg span)
    // 225 deg at bottom is dead zone
    let normalized = deg - 45;
    if (normalized < 0) normalized += 360;

    if (normalized <= 270) {
      const vol = (normalized / 270) * 100;
      setVolume(vol);
    }
  }

  function onPointerDown(e) {
    initAudio();
    isDragging = true;
    knob.classList.add('grabbing');
    calculateAngleFromEvent(e);
    window.addEventListener('pointermove', onPointerMove);
    window.addEventListener('pointerup', onPointerUp);
  }

  function onPointerMove(e) {
    if (!isDragging) return;
    calculateAngleFromEvent(e);
  }

  function onPointerUp() {
    if (isDragging) {
      isDragging = false;
      knob.classList.remove('grabbing');
      window.removeEventListener('pointermove', onPointerMove);
      window.removeEventListener('pointerup', onPointerUp);
    }
  }

  // Keyboard accessibility
  knob.addEventListener('keydown', (e) => {
    initAudio();
    if (e.key === 'ArrowUp' || e.key === 'ArrowRight') {
      e.preventDefault();
      setVolume(currentVolume + 2);
    } else if (e.key === 'ArrowDown' || e.key === 'ArrowLeft') {
      e.preventDefault();
      setVolume(currentVolume - 2);
    } else if (e.key === 'Home') {
      e.preventDefault();
      setVolume(0);
    } else if (e.key === 'End') {
      e.preventDefault();
      setVolume(100);
    }
  });

  // Mouse Wheel on Knob
  knob.addEventListener('wheel', (e) => {
    initAudio();
    e.preventDefault();
    const delta = e.deltaY > 0 ? -3 : 3;
    setVolume(currentVolume + delta);
  }, { passive: false });

  knob.addEventListener('pointerdown', onPointerDown);

  // 4. Stepper Buttons
  stepDownBtn.addEventListener('click', () => {
    initAudio();
    setVolume(currentVolume - 5);
  });

  stepUpBtn.addEventListener('click', () => {
    initAudio();
    setVolume(currentVolume + 5);
  });

  // 5. Header Actions
  overlayToggleBtn.addEventListener('click', () => {
    initAudio();
    playTactileClick(1400);
    overlayToggleBtn.classList.toggle('active');
    card.classList.toggle('compact-mode');
  });

  muteToggleBtn.addEventListener('click', () => {
    initAudio();
    playTactileClick(900);
    if (isMuted) {
      isMuted = false;
      muteToggleBtn.classList.remove('active');
      setVolume(previousVolume);
    } else {
      isMuted = true;
      muteToggleBtn.classList.add('active');
      previousVolume = currentVolume;
      setVolume(0);
    }
  });

  // 6. Nav Pill Button Tabs
  navBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      initAudio();
      playTactileClick(1100);
      navBtns.forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');
    });
  });

  // Initialize
  buildVisualizer();
  renderState();

})();

import { formatDateTime } from '../utils/date.js';

export const MapManager = {
  // State
  pickerMap: null,
  pickerMarker: null,
  currentLocation: null,
  mapViewMap: null,
  lastRenderedMemos: [],
  lastBounds: null,
  markerStyle: 'pin',
  callbacks: {}, // { focusMemo: (id) => void, onLocationSelected: (loc) => void }

  // DOM Elements
  elements: {
    mapViewEl: null,
    locationModal: null,
    locationMapEl: null,
    locationBtn: null,
    locationSummaryEl: null,
    locationLabelInput: null,
    useCurrentLocationBtn: null,
    locationSaveBtn: null,
    locationClearBtn: null,
    locationModalClose: null,
  },

  init(callbacks = {}) {
    this.callbacks = callbacks;
    this.elements.mapViewEl = document.getElementById('mapView');
    this.elements.locationModal = document.getElementById('locationModal');
    this.elements.locationMapEl = document.getElementById('locationMap');
    this.elements.locationBtn = document.getElementById('locationBtn');
    this.elements.locationSummaryEl = document.getElementById('locationSummary');
    this.elements.locationLabelInput = document.getElementById('locationLabelInput');
    this.elements.useCurrentLocationBtn = document.getElementById('useCurrentLocationBtn');
    this.elements.locationSaveBtn = document.getElementById('locationSaveBtn');
    this.elements.locationClearBtn = document.getElementById('locationClearBtn');
    this.elements.locationModalClose = document.getElementById('locationModalClose');

    this.initLocationPicker();
  },

  ensureLeaflet() {
    if (typeof L === 'undefined') {
      console.warn('Leaflet is not available');
      return false;
    }
    return true;
  },

  showModal() {
    if (!this.elements.locationModal) return;
    this.elements.locationModal.hidden = false;
    // Give layout a frame, then invalidate map size
    setTimeout(() => {
      if (!this.ensureLeaflet()) return;
      if (!this.pickerMap) {
        this.pickerMap = L.map(this.elements.locationMapEl).setView([37.7749, -122.4194], 12);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; OpenStreetMap contributors',
        }).addTo(this.pickerMap);

        this.pickerMap.on('click', (e) => {
          this.setPickerLocation({
            lat: e.latlng.lat,
            lng: e.latlng.lng,
            source: 'manual',
          });
        });
      }

      this.pickerMap.invalidateSize();

      if (this.currentLocation && typeof this.currentLocation.lat === 'number') {
        this.pickerMap.setView([this.currentLocation.lat, this.currentLocation.lng], 13);
        this.setPickerLocation(this.currentLocation);
      } else if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (pos) => {
            this.pickerMap.setView([pos.coords.latitude, pos.coords.longitude], 13);
          },
          () => {},
          { enableHighAccuracy: true, timeout: 8000 }
        );
      }
    }, 0);
  },

  hideModal() {
    if (!this.elements.locationModal) return;
    this.elements.locationModal.hidden = true;
  },

  setPickerLocation(loc) {
    this.currentLocation = {
      lat: loc.lat,
      lng: loc.lng,
      label: loc.label || this.currentLocation?.label || '',
      source: loc.source || 'manual',
    };

    if (!this.ensureLeaflet() || !this.pickerMap) return;

    if (!this.pickerMarker) {
      this.pickerMarker = L.marker([this.currentLocation.lat, this.currentLocation.lng], {
        draggable: true,
      }).addTo(this.pickerMap);
      this.pickerMarker.on('moveend', (e) => {
        const { lat, lng } = e.target.getLatLng();
        this.currentLocation.lat = lat;
        this.currentLocation.lng = lng;
      });
    } else {
      this.pickerMarker.setLatLng([this.currentLocation.lat, this.currentLocation.lng]);
    }
  },

  updateLocationSummary() {
    if (!this.elements.locationSummaryEl) return;
    if (!this.currentLocation) {
      this.elements.locationSummaryEl.hidden = true;
      this.elements.locationSummaryEl.textContent = '';
      return;
    }

    const { lat, lng, label } = this.currentLocation;
    const coords = `${lat.toFixed(4)}, ${lng.toFixed(4)}`;
    this.elements.locationSummaryEl.textContent = label ? `${label} (${coords})` : coords;
    this.elements.locationSummaryEl.hidden = false;
  },

  handleUseCurrentLocation() {
    if (!navigator.geolocation) {
      alert('Geolocation is not available in this browser.');
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const loc = {
          lat: pos.coords.latitude,
          lng: pos.coords.longitude,
          source: 'geolocation',
        };
        this.setPickerLocation(loc);
        if (this.pickerMap) {
          this.pickerMap.setView([loc.lat, loc.lng], 15);
        }
      },
      () => {
        alert('Could not fetch your location.');
      },
      { enableHighAccuracy: true, timeout: 10000 }
    );
  },

  initLocationPicker() {
    if (!this.elements.locationBtn || !this.elements.locationModal) return;

    // Use a flag or removeEventListener to avoid duplicate listeners if init called multiple times
    // For simplicity, we assume init is called once. 

    this.elements.locationBtn.addEventListener('click', () => {
      // Seed from currently edited memo if available - handled by setCurrentEditingLocation before click
      // But we can also check internal state
      if (this.elements.locationLabelInput) {
           this.elements.locationLabelInput.value = this.currentLocation?.label || '';
      }
      this.updateLocationSummary();
      this.showModal();
    });

    this.elements.locationModal.addEventListener('click', (e) => {
      if (e.target === this.elements.locationModal) {
        this.hideModal();
      }
    });

    if (this.elements.locationModalClose) {
      this.elements.locationModalClose.addEventListener('click', () => this.hideModal());
    }

    if (this.elements.useCurrentLocationBtn) {
      this.elements.useCurrentLocationBtn.addEventListener('click', () => this.handleUseCurrentLocation());
    }

    if (this.elements.locationSaveBtn) {
      this.elements.locationSaveBtn.addEventListener('click', () => {
        const label = this.elements.locationLabelInput.value.trim();
        if (this.currentLocation) {
          this.currentLocation = { ...this.currentLocation, label: label || this.currentLocation.label };
        } else if (label) {
          // Label-only location (no coords)
          this.currentLocation = { label, source: 'manual' };
        }

        if (this.callbacks.onLocationSelected) {
          this.callbacks.onLocationSelected(this.currentLocation || null);
        }
        this.updateLocationSummary();
        this.hideModal();
      });
    }

    if (this.elements.locationClearBtn) {
      this.elements.locationClearBtn.addEventListener('click', () => {
        this.currentLocation = null;
        if (this.elements.locationLabelInput) this.elements.locationLabelInput.value = '';
        this.updateLocationSummary();
        if (this.callbacks.onLocationSelected) {
          this.callbacks.onLocationSelected(null);
        }
        this.hideModal();
      });
    }
  },

  ensureMapView() {
    if (!this.elements.mapViewEl) return null;
    if (!this.ensureLeaflet()) return null;
    if (!this.mapViewMap) {
      this.mapViewMap = L.map(this.elements.mapViewEl, {
        zoomControl: true,
        attributionControl: true
      }).setView([20, 0], 2);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap contributors',
      }).addTo(this.mapViewMap);
    }
    // Invalidate size after a short delay to ensure container is fully visible
    setTimeout(() => {
      if (this.mapViewMap) {
        this.mapViewMap.invalidateSize();
      }
    }, 100);
    setTimeout(() => {
        if (this.mapViewMap) {
          this.mapViewMap.invalidateSize();
        }
      }, 300);
    return this.mapViewMap;
  },

  getMoodTone(memoList) {
    const moods = new Set(
      memoList.map((memo) => memo.mood).filter((mood) => !!mood)
    );
    if (moods.size === 0) return 'neutral';
    if (moods.size > 1) return 'mixed';
    if (moods.has('great')) return 'great';
    if (moods.has('ok')) return 'ok';
    if (moods.has('bad')) return 'bad';
    return 'neutral';
  },

  getMoodEmoji(tone) {
    if (tone === 'great') return '😊';
    if (tone === 'ok') return '😐';
    if (tone === 'bad') return '😞';
    return '•';
  },

  createMarkerIcon(memoList) {
    const count = memoList.length;
    const tone = this.getMoodTone(memoList);
    const style = this.markerStyle || 'pin';
    let label = '';

    if (count > 1) {
      label = String(count);
    } else if (style === 'emoji') {
      label = this.getMoodEmoji(tone);
    } else if (memoList.length === 1 && memoList[0].location?.symbol) {
      label = memoList[0].location.symbol;
    }

    const size = style === 'dot' ? 22 : 34;
    const anchor = [size / 2, size / 2];

    return L.divIcon({
      className: `memo-map-marker memo-map-marker--${style} memo-map-marker--${tone}`,
      html: `<div class=\"memo-map-marker__inner\">${label}</div>`,
      iconSize: [size, size],
      iconAnchor: anchor,
      popupAnchor: [0, -size / 2],
    });
  },

  renderMapView(memos, options = {}) {
    if (options.markerStyle) {
      this.markerStyle = options.markerStyle;
    }
    const useHeat = !!options.heat;

    this.lastRenderedMemos = Array.isArray(memos) ? memos : [];
    const map = this.ensureMapView();
    if (!map) return;

    // Clear existing layers except base
    map.eachLayer((layer) => {
      if (!layer._url) {
        map.removeLayer(layer);
      }
    });

    const bounds = [];

    if (useHeat) {
      // Simple heat density 
      const counts = new Map();
      for (const memo of this.lastRenderedMemos) {
        const loc = memo.location;
        if (!loc || typeof loc.lat !== 'number' || typeof loc.lng !== 'number') continue;
        const key = `${loc.lat.toFixed(4)},${loc.lng.toFixed(4)}`;
        counts.set(key, (counts.get(key) || 0) + 1);
      }

      const max = Math.max(1, ...counts.values());
      counts.forEach((count, key) => {
        const [latStr, lngStr] = key.split(',');
        const lat = parseFloat(latStr);
        const lng = parseFloat(lngStr);
        const intensity = count / max; 
        const radius = 20 + intensity * 40;
        const color = intensity > 0.66 ? '#ff3b30' : intensity > 0.33 ? '#ff9f0a' : '#ffd60a';

        L.circle([lat, lng], {
          radius: radius,
          color: color,
          fillColor: color,
          fillOpacity: 0.35,
          weight: 0,
        }).addTo(map);
        bounds.push([lat, lng]);
      });
    } else {
      const clusters = new Map();

      for (const memo of this.lastRenderedMemos) {
        const loc = memo.location;
        if (!loc || typeof loc.lat !== 'number' || typeof loc.lng !== 'number') continue;
        const key = `${loc.lat.toFixed(4)},${loc.lng.toFixed(4)}`;
        if (!clusters.has(key)) clusters.set(key, []);
        clusters.get(key).push(memo);
      }

      clusters.forEach((memoList, key) => {
        const [latStr, lngStr] = key.split(',');
        const lat = parseFloat(latStr);
        const lng = parseFloat(lngStr);
        const marker = L.marker([lat, lng], {
          icon: this.createMarkerIcon(memoList),
        }).addTo(map);
        bounds.push([lat, lng]);

        marker.on('click', () => {
          const container = document.createElement('div');
          container.className = 'map-popup-content';

          if (memoList.length === 1) {
            const memo = memoList[0];
            const title = document.createElement('strong');
            const symbol = memo.location?.symbol ? `${memo.location.symbol} ` : '';
            title.textContent = `${symbol}${memo.title || '(untitled)'}`;
            const date = document.createElement('div');
            date.textContent = formatDateTime(memo.datetime || memo.createdAt) || '';
            const snippet = document.createElement('div');
            snippet.textContent = (memo.text || '').slice(0, 120);
            container.appendChild(title);
            container.appendChild(date);
            container.appendChild(snippet);
          } else {
            const header = document.createElement('div');
            header.textContent = `${memoList.length} memos here`;
            header.style.fontWeight = 'bold';
            header.style.marginBottom = '0.25rem';
            container.appendChild(header);

            const sortBtn = document.createElement('button');
            sortBtn.textContent = 'Sort: newest first';
            sortBtn.style.display = 'block';
            sortBtn.style.marginBottom = '0.25rem';
            sortBtn.style.fontSize = '0.7rem';
            let sortMode = 'newest';
            container.appendChild(sortBtn);

            const list = document.createElement('ul');
            list.style.paddingLeft = '1rem';
            list.style.margin = 0;

            const renderList = () => {
              list.innerHTML = '';
              const sorted = [...memoList].sort((a, b) =>
                sortMode === 'newest'
                  ? (new Date(b.datetime || b.createdAt) - new Date(a.datetime || a.createdAt))
                  : (new Date(a.datetime || a.createdAt) - new Date(b.datetime || b.createdAt))
              );
              for (const memo of sorted) {
                const li = document.createElement('li');
                li.style.cursor = 'pointer';
                li.style.fontSize = '0.75rem';
                li.textContent = `${formatDateTime(memo.datetime || memo.createdAt) || ''} — ${
                  (memo.title || '').slice(0, 40) || '(untitled)'
                }`;
                li.addEventListener('click', () => {
                  if (this.callbacks.focusMemo) {
                    this.callbacks.focusMemo(memo.id);
                  }
                });
                list.appendChild(li);
              }
            };

            sortBtn.addEventListener('click', () => {
              sortMode = sortMode === 'newest' ? 'oldest' : 'newest';
              sortBtn.textContent = sortMode === 'newest' ? 'Sort: newest first' : 'Sort: oldest first';
              renderList();
            });

            renderList();
            container.appendChild(list);
          }

          marker.bindPopup(container).openPopup();
        });
      });
    }

    if (bounds.length) {
      this.lastBounds = L.latLngBounds(bounds);
      map.fitBounds(this.lastBounds, { padding: [20, 20] });
    } else {
      this.lastBounds = null;
    }
  },

  setMapMarkerStyle(style) {
    this.markerStyle = style || 'pin';
    if (this.mapViewMap && this.lastRenderedMemos.length) {
      this.renderMapView(this.lastRenderedMemos, { markerStyle: this.markerStyle }); // heat? 
      // check if header has heat enabled?
      // For now just re-render. Caller should call renderMapView with correct options.
    }
  },

  fitToMarkers() {
    if (!this.mapViewMap) return;
    if (this.lastBounds) {
      this.mapViewMap.fitBounds(this.lastBounds, { padding: [20, 20] });
    } else {
      this.mapViewMap.setView([20, 0], 2);
    }
  },

  focusMemo(id) {
    if (!id) return;
    const memo = this.lastRenderedMemos.find((item) => item.id === id);
    if (!memo || !memo.location || typeof memo.location.lat !== 'number' || typeof memo.location.lng !== 'number') {
      return;
    }
    const map = this.ensureMapView();
    if (!map) return;
    map.setView([memo.location.lat, memo.location.lng], 15, { animate: true });
  },

  setCurrentEditingLocation(loc) {
    this.currentLocation = loc ? { ...loc } : null;
    if (this.elements.locationLabelInput) {
      this.elements.locationLabelInput.value = loc?.label || '';
    }
    this.updateLocationSummary();
  },
  
  getCurrentEditingLocation() {
      return this.currentLocation;
  }
};

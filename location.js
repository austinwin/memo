(function () {
  const mapViewEl = document.getElementById('mapView');
  const locationModal = document.getElementById('locationModal');
  const locationMapEl = document.getElementById('locationMap');
  const locationBtn = document.getElementById('locationBtn');
  const locationSummaryEl = document.getElementById('locationSummary');
  const locationLabelInput = document.getElementById('locationLabelInput');
  const useCurrentLocationBtn = document.getElementById('useCurrentLocationBtn');
  const locationSaveBtn = document.getElementById('locationSaveBtn');
  const locationClearBtn = document.getElementById('locationClearBtn');
  const locationModalClose = document.getElementById('locationModalClose');

  let pickerMap = null;
  let pickerMarker = null;
  let currentLocation = null;
  let mapViewMap = null;

  function ensureLeaflet() {
    if (typeof L === 'undefined') {
      console.warn('Leaflet is not available');
      return false;
    }
    return true;
  }

  function showModal() {
    if (!locationModal) return;
    locationModal.hidden = false;
    // Give layout a frame, then invalidate map size
    setTimeout(() => {
      if (!ensureLeaflet()) return;
      if (!pickerMap) {
        pickerMap = L.map(locationMapEl).setView([37.7749, -122.4194], 12);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; OpenStreetMap contributors',
        }).addTo(pickerMap);

        pickerMap.on('click', (e) => {
          setPickerLocation({
            lat: e.latlng.lat,
            lng: e.latlng.lng,
            source: 'manual',
          });
        });
      }

      pickerMap.invalidateSize();

      if (currentLocation && typeof currentLocation.lat === 'number') {
        pickerMap.setView([currentLocation.lat, currentLocation.lng], 13);
        setPickerLocation(currentLocation);
      } else if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (pos) => {
            pickerMap.setView([pos.coords.latitude, pos.coords.longitude], 13);
          },
          () => {},
          { enableHighAccuracy: true, timeout: 8000 }
        );
      }
    }, 0);
  }

  function hideModal() {
    if (!locationModal) return;
    locationModal.hidden = true;
  }

  function setPickerLocation(loc) {
    currentLocation = {
      lat: loc.lat,
      lng: loc.lng,
      label: loc.label || currentLocation?.label || '',
      source: loc.source || 'manual',
    };

    if (!ensureLeaflet() || !pickerMap) return;

    if (!pickerMarker) {
      pickerMarker = L.marker([currentLocation.lat, currentLocation.lng], {
        draggable: true,
      }).addTo(pickerMap);
      pickerMarker.on('moveend', (e) => {
        const { lat, lng } = e.target.getLatLng();
        currentLocation.lat = lat;
        currentLocation.lng = lng;
      });
    } else {
      pickerMarker.setLatLng([currentLocation.lat, currentLocation.lng]);
    }
  }

  function updateLocationSummary() {
    if (!locationSummaryEl) return;
    if (!currentLocation) {
      locationSummaryEl.hidden = true;
      locationSummaryEl.textContent = '';
      return;
    }

    const { lat, lng, label } = currentLocation;
    const coords = `${lat.toFixed(4)}, ${lng.toFixed(4)}`;
    locationSummaryEl.textContent = label ? `${label} (${coords})` : coords;
    locationSummaryEl.hidden = false;
  }

  function handleUseCurrentLocation() {
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
        setPickerLocation(loc);
        if (pickerMap) {
          pickerMap.setView([loc.lat, loc.lng], 15);
        }
      },
      () => {
        alert('Could not fetch your location.');
      },
      { enableHighAccuracy: true, timeout: 10000 }
    );
  }

  function initLocationPicker() {
    if (!locationBtn || !locationModal) return;

    locationBtn.addEventListener('click', () => {
      // Seed from currently edited memo if available
      const editingMemoLocation = window.memoLocation?.getCurrentEditingLocation?.();
      if (editingMemoLocation) {
        currentLocation = { ...editingMemoLocation };
        locationLabelInput.value = editingMemoLocation.label || '';
      } else {
        currentLocation = null;
        locationLabelInput.value = '';
      }
      updateLocationSummary();
      showModal();
    });

    locationModal.addEventListener('click', (e) => {
      if (e.target === locationModal) {
        hideModal();
      }
    });

    if (locationModalClose) {
      locationModalClose.addEventListener('click', hideModal);
    }

    if (useCurrentLocationBtn) {
      useCurrentLocationBtn.addEventListener('click', handleUseCurrentLocation);
    }

    if (locationSaveBtn) {
      locationSaveBtn.addEventListener('click', () => {
        const label = locationLabelInput.value.trim();
        if (currentLocation) {
          currentLocation = { ...currentLocation, label: label || currentLocation.label };
        } else if (label) {
          // Label-only location (no coords)
          currentLocation = { label, source: 'manual' };
        }

        if (window.memoLocation && typeof window.memoLocation.onLocationSelected === 'function') {
          window.memoLocation.onLocationSelected(currentLocation || null);
        }
        updateLocationSummary();
        hideModal();
      });
    }

    if (locationClearBtn) {
      locationClearBtn.addEventListener('click', () => {
        currentLocation = null;
        locationLabelInput.value = '';
        updateLocationSummary();
        if (window.memoLocation && typeof window.memoLocation.onLocationSelected === 'function') {
          window.memoLocation.onLocationSelected(null);
        }
        hideModal();
      });
    }
  }

  function ensureMapView() {
    if (!mapViewEl) return null;
    if (!ensureLeaflet()) return null;
    if (!mapViewMap) {
      mapViewMap = L.map(mapViewEl).setView([20, 0], 2);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap contributors',
      }).addTo(mapViewMap);
    } else {
      setTimeout(() => mapViewMap.invalidateSize(), 0);
    }
    return mapViewMap;
  }

  function renderMapView(memos) {
    const map = ensureMapView();
    if (!map) return;

    // Clear existing layers except base
    map.eachLayer((layer) => {
      if (!layer._url) {
        map.removeLayer(layer);
      }
    });

    const clusters = new Map();

    for (const memo of memos) {
      const loc = memo.location;
      if (!loc || typeof loc.lat !== 'number' || typeof loc.lng !== 'number') continue;
      const key = `${loc.lat.toFixed(4)},${loc.lng.toFixed(4)}`;
      if (!clusters.has(key)) clusters.set(key, []);
      clusters.get(key).push(memo);
    }

    const bounds = [];

    clusters.forEach((memoList, key) => {
      const [latStr, lngStr] = key.split(',');
      const lat = parseFloat(latStr);
      const lng = parseFloat(lngStr);
      const marker = L.marker([lat, lng]).addTo(map);
      bounds.push([lat, lng]);

      marker.on('click', () => {
        const container = document.createElement('div');
        container.className = 'map-popup-content';

        if (memoList.length === 1) {
          const memo = memoList[0];
          const title = document.createElement('strong');
          title.textContent = memo.title || '(untitled)';
          const date = document.createElement('div');
          date.textContent = window.memoLocation?.formatDateTime?.(memo.datetime || memo.createdAt) || '';
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

          function renderList() {
            list.innerHTML = '';
            const sorted = [...memoList].sort((a, b) =>
              sortMode === 'newest'
                ? (b.datetime || b.createdAt) - (a.datetime || a.createdAt)
                : (a.datetime || a.createdAt) - (b.datetime || b.createdAt)
            );
            for (const memo of sorted) {
              const li = document.createElement('li');
              li.style.cursor = 'pointer';
              li.style.fontSize = '0.75rem';
              li.textContent = `${window.memoLocation?.formatDateTime?.(memo.datetime || memo.createdAt) || ''} — ${
                (memo.title || '').slice(0, 40) || '(untitled)'
              }`;
              li.addEventListener('click', () => {
                if (window.memoLocation && typeof window.memoLocation.focusMemo === 'function') {
                  window.memoLocation.focusMemo(memo.id);
                }
              });
              list.appendChild(li);
            }
          }

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

    if (bounds.length) {
      map.fitBounds(bounds, { padding: [20, 20] });
    }
  }

  window.memoLocation = window.memoLocation || {};
  window.memoLocation.updateLocationSummary = updateLocationSummary;
  window.memoLocation.initLocationPicker = initLocationPicker;
  window.memoLocation.renderMapView = renderMapView;
  window.memoLocation.setCurrentEditingLocation = function (loc) {
    currentLocation = loc ? { ...loc } : null;
    if (locationLabelInput) {
      locationLabelInput.value = loc?.label || '';
    }
    updateLocationSummary();
  };
})();

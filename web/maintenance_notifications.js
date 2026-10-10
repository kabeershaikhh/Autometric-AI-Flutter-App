/* Foreground-only reminders. No push server and no background timer promises. */
window.maintenanceNotifications = (() => {
  let opened = null;
  const supported = 'Notification' in window && window.isSecureContext;
  const storage = (action) => { try { return action(window.localStorage); } catch (_) { return null; } };
  return {
    supported,
    async enable() {
      if (!supported) return false;
      return (await Notification.requestPermission()) === 'granted';
    },
    reconcile(uid, json) {
      if (!supported || Notification.permission !== 'granted' || document.visibilityState !== 'visible') return;
      const hour = new Date(Date.now() + 5 * 3600000).getUTCHours();
      if (hour < 8 || hour > 20) return;
      let sent = 0;
      for (const reminder of JSON.parse(json)) {
        if (reminder.at > Date.now() || sent >= 3) continue;
        const key = `maintenance:${uid}:${reminder.id}:${reminder.at}`;
        // Synchronous claims suppress duplicate alerts across ordinary tab refreshes.
        if (storage(s => s.getItem(key))) continue;
        storage(s => s.setItem(key, String(Date.now())));
        try {
          const notification = new Notification('AutoMetric • Maintenance', {
            body: reminder.body, tag: key, icon: 'icons/Icon-192.png'
          });
          notification.onclick = () => { opened = reminder.vehicleId; window.focus(); notification.close(); };
          sent++;
        } catch (_) { /* Mobile browsers may require push; the in-app inbox remains. */ }
      }
      storage(s => {
        const cutoff = Date.now() - 90 * 86400000;
        for (const key of Object.keys(s)) {
          if (key.startsWith('maintenance:') && Number(s.getItem(key)) < cutoff) s.removeItem(key);
        }
      });
    },
    clear() { opened = null; },
    openedVehicle() { const value = opened; opened = null; return value; }
  };
})();

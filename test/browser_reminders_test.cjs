const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
test('web reminders are foreground-only, permission-gated and deduplicated', async () => {
  const notifications = [];
  class Notification {
    static permission = 'default';
    static async requestPermission() { return Notification.permission = 'granted'; }
    constructor(title, options) { notifications.push({title, ...options}); }
  }
  const items = {};
  const localStorage = { getItem: key => items[key] || null, setItem: (key, value) => items[key] = value, removeItem: key => delete items[key] };
  const window = {Notification, localStorage, isSecureContext: true, focus() {}};
  const document = {visibilityState: 'visible'};
  const now = Date.UTC(2026, 9, 9, 5); // 10:00 Pakistan time
  class Clock extends Date { static now() { return now; } }
  vm.runInNewContext(fs.readFileSync('web/maintenance_notifications.js', 'utf8'), {window, document, Notification, Date: Clock, JSON, Number, Object});
  const api = window.maintenanceNotifications;
  const jobs = JSON.stringify([{id: 'oil', vehicleId: 'car', at: now - 1000, body: 'Check service status'}]);
  api.reconcile('alice', jobs); assert.equal(notifications.length, 0);
  assert.equal(await api.enable(), true);
  document.visibilityState = 'hidden'; api.reconcile('alice', jobs); assert.equal(notifications.length, 0);
  document.visibilityState = 'visible'; api.reconcile('alice', jobs); assert.equal(notifications.length, 1);
  api.reconcile('alice', jobs); assert.equal(notifications.length, 1);
  api.reconcile('bob', jobs); assert.equal(notifications.length, 2);
});

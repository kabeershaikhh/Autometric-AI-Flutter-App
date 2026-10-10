// Run only against demo-project Firestore Emulator. Never accesses live Firebase.
const assert = require('node:assert/strict');
const project = 'demo-autometric-maintenance';
const host = process.env.FIRESTORE_EMULATOR_HOST;
if (!host || !host.startsWith('127.0.0.1:') && !host.startsWith('localhost:')) throw Error('Local Firestore Emulator required');
const root = `projects/${project}/databases/(default)/documents`;
const base = `http://${host}/v1/${root}`;
function token(uid) {
  const now = Math.floor(Date.now() / 1000);
  const encode = data => Buffer.from(JSON.stringify(data)).toString('base64url');
  return `${encode({alg:'none',typ:'JWT'})}.${encode({sub:uid,user_id:uid,aud:project,iss:`https://securetoken.google.com/${project}`,iat:now,exp:now+3600,firebase:{sign_in_provider:'custom'}})}.`;
}
function value(data) {
  if (data === null) return {nullValue: null};
  if (data instanceof Date) return {timestampValue: data.toISOString()};
  if (typeof data === 'boolean') return {booleanValue: data};
  if (typeof data === 'number') return Number.isInteger(data) ? {integerValue: String(data)} : {doubleValue: data};
  if (typeof data === 'string') return {stringValue: data};
  if (Array.isArray(data)) return {arrayValue:{values:data.map(value)}};
  return {mapValue:{fields:fields(data)}};
}
const fields = data => Object.fromEntries(Object.entries(data).map(([k,v]) => [k,value(v)]));
async function request(uid, path, method = 'GET', body) {
  return fetch(`${base}${path}`, {method,headers:{'Content-Type':'application/json',...(uid ? {Authorization:`Bearer ${token(uid)}`} : {})},body:body ? JSON.stringify(body) : undefined});
}
async function expected(response, status) {
  const text = await response.text(); assert.equal(response.status, status, text);
}
(async () => {
  for (const uid of ['alice','bob']) await expected(await request(uid, `/users/${uid}`, 'PATCH', {fields:fields({name:uid,email:`${uid}@example.com`,photoBase64:''})}), 200);
  const car = {manufacturer:'Toyota',model:'Corolla',year:2018,plate:'LEA-123',fuel:'Petrol',odometer:50000,readingDate:new Date(),weeklyKm:250,archived:false,schedules:{}};
  await expected(await request('alice', ':commit', 'POST', {writes:[
    {update:{name:`${root}/users/alice`,fields:fields({maintenanceVehicleCount:1})},updateMask:{fieldPaths:['maintenanceVehicleCount']}},
    {update:{name:`${root}/users/alice/maintenanceVehicles/car`,fields:fields(car)},updateTransforms:[{fieldPath:'createdAt',setToServerValue:'REQUEST_TIME'},{fieldPath:'updatedAt',setToServerValue:'REQUEST_TIME'}]},
    {update:{name:`${root}/users/alice/maintenanceVehicles/car/odometerReadings/first`,fields:fields({km:50000,date:new Date(),correction:false})}},
  ]}), 200);
  await expected(await request('alice','/users/alice/maintenanceVehicles/car'),200);
  await expected(await request('bob','/users/alice/maintenanceVehicles/car'),403);
  await expected(await request(null,'/users/alice/maintenanceVehicles/car'),403);
  await expected(await request('bob','/users/alice/maintenanceVehicles/car','DELETE'),403);
  await expected(await request('alice','/users/alice/maintenanceVehicles/car/attachments/photo','PATCH',{fields:fields({base64:'YWJj',bytes:3})}),403);
  await expected(await request('alice','/users/alice/maintenanceVehicles/car/attachments/receipt_test','PATCH',{fields:fields({base64:'YWJj',bytes:3})}),200);
  await expected(await request('alice','/users/alice/maintenanceVehicles/car/attachments/receipt_test','PATCH',{fields:fields({base64:'YWJj',bytes:204801})}),403);
  await expected(await request('alice','/users/alice/maintenanceSettings/reminders','PATCH',{fields:fields({enabled:true,hour:9,leadDays:7})}),200);
  await expected(await request('alice','/users/alice/maintenanceSettings/reminders','PATCH',{fields:fields({enabled:true,hour:25,leadDays:7})}),403);
  const record = {types:['Oil'],date:new Date(),odometer:50000,costPaisa:850000,notes:'',workshop:'',plannedOnly:false,intervals:{Oil:{km:5000,months:6}},hasReceipt:false};
  await expected(await request('alice','/users/alice/maintenanceVehicles/car/serviceRecords/oil','PATCH',{fields:fields(record)}),200);
  await expected(await request('bob','/users/alice/maintenanceVehicles/car/serviceRecords/oil'),403);
  await expected(await request('alice','/users/alice/maintenanceVehicles/car/serviceRecords/invalid','PATCH',{fields:fields({...record,odometer:-1})}),403);
  console.log('Firestore rules: atomic vehicle creation, owner access, guest/cross-account denial, attachment bounds, reminder validation and service validation passed.');
})().catch(error => {console.error(error);process.exitCode = 1;});

import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, updateDoc, deleteDoc, collection, getDocs } from 'firebase/firestore';

const env = await initializeTestEnvironment({
  projectId: 'demo-tc',
  firestore: { rules: readFileSync('../../firestore.rules', 'utf8'), host: '127.0.0.1', port: 8085 },
});

const owner = env.authenticatedContext('owner').firestore();
const jana = env.authenticatedContext('jana').firestore();
const cizi = env.authenticatedContext('cizi').firestore();
const anon = env.unauthenticatedContext().firestore();
const now = Date.now();
let ok = 0, bad = 0;
async function t(name, p) {
  try { await p; ok++; console.log('OK  ', name); } catch (e) { bad++; console.log('FAIL', name, e.message); }
}

// osobní data
await t('vlastník čte svá data', assertSucceeds(setDoc(doc(owner, 'users/owner/trips/a'), { x: 1 })));
await t('cizí nečte cizí data', assertFails(getDoc(doc(cizi, 'users/owner/trips/a'))));

// sdílení
await t('majitel založí cestu', assertSucceeds(setDoc(doc(owner, 'shared/T'), { ownerUid: 'owner', rev: 1 })));
await t('cizí nesmí založit cestu za jiného', assertFails(setDoc(doc(cizi, 'shared/X'), { ownerUid: 'owner' })));
await t('majitel se přidá jako člen', assertSucceeds(setDoc(doc(owner, 'shared/T/members/owner'), { name: 'Roman', role: 'owner' })));
await t('majitel zapíše řádek', assertSucceeds(setDoc(doc(owner, 'shared/T/expenses/e1'), { id: 'e1', updatedAt: 1, enc: 'x' })));
await t('cizí nečte cestu', assertFails(getDoc(doc(cizi, 'shared/T'))));
await t('cizí nečte řádky', assertFails(getDocs(collection(cizi, 'shared/T/expenses'))));
await t('cizí se nepřidá bez pozvánky', assertFails(setDoc(doc(cizi, 'shared/T/members/cizi'), { name: 'X', role: 'member' })));

// pozvánka
await t('majitel vytvoří pozvánku', assertSucceeds(setDoc(doc(owner, 'invites/INV'), { tripId: 'T', inviterUid: 'owner', wrappedKey: 'k', expiresAt: now + 86400000 })));
await t('cizí nevytvoří pozvánku do cizí cesty', assertFails(setDoc(doc(cizi, 'invites/INV2'), { tripId: 'T', inviterUid: 'cizi', expiresAt: now + 1e8 })));
await t('nepřihlášený pozvánku nepřečte', assertFails(getDoc(doc(anon, 'invites/INV'))));
await t('přihlášený přečte pozvánku podle kódu', assertSucceeds(getDoc(doc(jana, 'invites/INV'))));
await t('pozvánky nejdou vypsat', assertFails(getDocs(collection(jana, 'invites'))));
await t('Jana se připojí s pozvánkou', assertSucceeds(setDoc(doc(jana, 'shared/T/members/jana'), { name: 'Jana', role: 'member', invite: 'INV' })));
await t('Jana nemůže přidat někoho jiného', assertFails(setDoc(doc(jana, 'shared/T/members/cizi'), { name: 'X', role: 'member', invite: 'INV' })));
await t('Jana čte řádky', assertSucceeds(getDocs(collection(jana, 'shared/T/expenses'))));
await t('Jana přidá výdaj', assertSucceeds(setDoc(doc(jana, 'shared/T/expenses/e2'), { id: 'e2', updatedAt: 2, enc: 'y' })));
await t('Jana zvýší rev', assertSucceeds(updateDoc(doc(jana, 'shared/T'), { rev: 2 })));
await t('Jana nezmění vlastníka', assertFails(updateDoc(doc(jana, 'shared/T'), { ownerUid: 'jana' })));
await t('Jana nesmaže cestu', assertFails(deleteDoc(doc(jana, 'shared/T'))));

// prošlá pozvánka
await env.withSecurityRulesDisabled(async (c) => {
  await setDoc(doc(c.firestore(), 'invites/OLD'), { tripId: 'T', inviterUid: 'owner', wrappedKey: 'k', expiresAt: now - 1000 });
});
await t('prošlá pozvánka nepustí', assertFails(setDoc(doc(cizi, 'shared/T/members/cizi'), { name: 'X', role: 'member', invite: 'OLD' })));
await t('pozvánka do jiné cesty nepustí', assertFails(setDoc(doc(cizi, 'shared/Y/members/cizi'), { name: 'X', role: 'member', invite: 'INV' })));

// odebrání a odchod
await t('Jana neodebere majitele', assertFails(deleteDoc(doc(jana, 'shared/T/members/owner'))));
await t('majitel odebere Janu', assertSucceeds(deleteDoc(doc(owner, 'shared/T/members/jana'))));
await t('odebraná Jana už nečte', assertFails(getDocs(collection(jana, 'shared/T/expenses'))));
await t('majitel smaže cestu', assertSucceeds(deleteDoc(doc(owner, 'shared/T'))));
await t('majitel pak smaže sebe', assertSucceeds(deleteDoc(doc(owner, 'shared/T/members/owner'))));

console.log(`\n${ok} OK, ${bad} FAIL`);
await env.cleanup();
process.exit(bad ? 1 : 0);

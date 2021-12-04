import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
import { ask, yesno, done } from '@reach-sh/stdlib/ask.mjs';

if (process.argv.length < 3 || ['projectOwner', 'sponsor'].includes(process.argv[2]) == false) {
  console.log('Usage: reach run index [projectOwner|sponsor]');
  process.exit(0);
}
const role = process.argv[2];
console.log(`Your role is ${role}.`);

const stdlib = loadStdlib(process.env);
console.log(`The consensus network is ${stdlib.connector}.`);

const suStr = stdlib.standardUnit;
const toAU = (su) => stdlib.parseCurrency(su);
const toSU = (au) => stdlib.formatCurrency(au, 4);
const iBalance = toAU(1000);
const showBalance = async (acc) => console.log(`Your balance is ${toSU(await stdlib.balanceOf(acc))} ${suStr}.`);

(async () => {

  const commonInteract = (role) => ({
    reportExit: () => console.log(`Exiting contract.`)
  });

  // Project Owner
  if (role === 'projectOwner') {
    const projectOwnerInteract = {
      ...commonInteract(role),
      reportReady: async () => { console.log(`Contract info: ${JSON.stringify(await ctc.getInfo())}`); },
      projectDetails: {
        projectName: 'Project Sponsorship Project',
        fundraisingGoal: stdlib.parseCurrency(20),
      }
    };

    const acc = await stdlib.newTestAccount(iBalance);
    await showBalance(acc);
    const ctc = acc.contract(backend);
    await backend.ProjectOwner(ctc, projectOwnerInteract);
    await showBalance(acc);
  }

  // Sponsor
  else {
    const sponsorInteract = {
      ...commonInteract(role) 
    };

    const acc = await stdlib.newTestAccount(iBalance);
    const info = await ask('Paste contract info:', (s) => JSON.parse(s));
    const ctc = acc.contract(backend, info);
    await showBalance(acc);
    await ctc.p.Sponsor(sponsorInteract);
    await showBalance(acc);
  }

  done();
})();


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

// acc = await stdlib.newTestAccount(iBalance);
// const abbrAddr = (addr) => addr.substr(0, 5);
// const me = abbrAddr(acc.getAddress());
let tok = null;
    const showBalance2 = async () => {
      // console.log(`${me}: Checking ${tok} balance:`);
      // console.log(`${me}: ${tok} balance: ${fmt(await stdlib.balanceOf(acc, tok))}`);
    };

let amt = null;
(async () => {

  const commonInteract = (role) => ({
    
    reportExit: () => console.log(`Exiting contract.`),
    reportCancellation: () => { console.log(`${role == 'sponsor' ? 'You' : 'The sponsor'} refused to sponsor.`); },
    // showToken: (gag) => { console.log(`Token for ${role == 'sponsor' ? 'You' : 'The sponsor'}`)},
    // didTransfer: (did, _amt) => {console.log(`Transfer was made`)},
    // showToken: () => async (_tok, cmd) => {
    //   tok = _tok;
    //   // console.log(`${me}: The token is: ${tok}`);
    //   await showBalance2();
    //   // console.log(`${me}: The token computed metadata is:`, cmd);
    //   // const omd = await acc.tokenMetadata(tok);
    //   // // console.log(`${me}: The token on-chain metadata is:`, omd);
    //   // for ( const f in cmd ) {
    //   //   assertEq(cmd[f], omd[f]);
    //   // }
    //   // console.log(`${me}: Opt-in to ${tok}:`);
    //   await acc.tokenAccept(tok);
    //   await showBalance2();
    // },
    
    didTransfer: () => async (did, _amt) => {
      if ( did ) {
        amt = _amt;
        // console.log(`${me}: Received transfer of ${fmt(amt)} for ${tok}`);
      }
      await showBalance2();
      // This next line is weird.
      // console.log(`${me}: Doing transfer for ${tok}`);
      await stdlib.transfer(acc, other, amt, tok);
      await showBalance2();
    },
  });

  // Project Owner
  if (role === 'projectOwner') {
    let projectOwnerInteract = {
      ...commonInteract(role),
      reportReady: async () => { console.log(`Contract info: ${JSON.stringify(await ctc.getInfo())}`); },
      projectInfo: {
        projectName: 'Project Sponsorship Project',
        projectDetails: 'Solving Niger wahala',
        fundraisingGoal: toAU(20),
        contractDuration: 200,
      },
      getParams: () => ({
        name: `Gil`, symbol: `GIL`,
        url: `https://tinyurl.com/4nd2faer`,
        metadata: `It's shiny!`,
        supply: stdlib.parseCurrency(1000),
        amt: stdlib.parseCurrency(10),
      }),
      
      
      
      // reportDone: () => { console.log(`You are done.`); process.exit(0); }
    };

    // let tok = null;
    // const showBalance = async () => {
    //   // console.log(`${me}: Checking ${tok} balance:`);
    //   // console.log(`${me}: ${tok} balance: ${fmt(await stdlib.balanceOf(acc, tok))}`);
    // };
    // const showToken = async (_tok, cmd) => {
    //   tok = _tok;
    //   // console.log(`${me}: The token is: ${tok}`);
    //   await showBalance();
    //   // console.log(`${me}: The token computed metadata is:`, cmd);
    //   const omd = await acc.tokenMetadata(tok);
    //   // console.log(`${me}: The token on-chain metadata is:`, omd);
    //   for ( const f in cmd ) {
    //     assertEq(cmd[f], omd[f]);
    //   }
    //   // console.log(`${me}: Opt-in to ${tok}:`);
    //   await acc.tokenAccept(tok);
    //   await showBalance();
    // };
    // let amt = null;
    // const didTransfer = async (did, _amt) => {
    //   if ( did ) {
    //     amt = _amt;
    //     // console.log(`${me}: Received transfer of ${fmt(amt)} for ${tok}`);
    //   }
    //   await showBalance();
    //   // This next line is weird.
    //   // console.log(`${me}: Doing transfer for ${tok}`);
    //   // await stdlib.transfer(acc, other, amt, tok);
    //   // await showBalance();
    // };


    const acc = await stdlib.newTestAccount(iBalance);
    await showBalance(acc);
    // console.log(`Hey: Your project goal is ${projectOwnerInteract.fundraisingGoal} ${suStr}.`);
    const ctc = acc.contract(backend);
    // const info = await ctc.getInfo();
    // console.log(`Hey: Your contract info is ${JSON.stringify(info)}`);
    await backend.ProjectOwner(ctc, projectOwnerInteract);
    await showBalance(acc);
  }

  // Sponsor
  else {
    const sponsorInteract = {
      ...commonInteract(role),
      sponsor: async (projectInfo) => {
        console.log(projectInfo.projectName);
        console.log(`Fundraising goal: ${toSU(projectInfo.fundraisingGoal)}`);
        const fund = {contribute: false, amt: 0};
        const willContribute = await ask(`Do yo wish to contribute?`, yesno);
        if (willContribute) {
          fund.contribute = true
        }
        confirmSponsor: async (total) => await ask(`Do you want to complete the sponsoring for ${toSU(project.formatCurrency)} ${suStr}?`, yesno)
        // reportContribution
        // const sendFund = await ask(`Enter 1-${sellerInfo.products.length}, or 0 to exit:`, (x => x)); 
        return fund;
      },

    };

    

    //
    // amount = await ask(`What is your contribution in ${suStr}?`, (x => x));
    // let sponsorInteract = {
    //   ...commonInteract(role),
    //   contribution: stdlib.parseCurrency(amount),
    //   willContribute: true,
    //   getWillContribute: () => sponsorInteract.willContribute,
    //   reportAddress: (addr) => { console.log(`${me}: Your address starts with ${abbrAddr(addr)}.`); },
    //   reportBalance: (balance) => { console.log(`${me}: Contract balance is ${fmt(balance)} ${suStr}.`); },
    //   reportContribution: (addr, contribution, balance, time) => {
    //     console.log(`${me}: ${yourAddr(addr, acc)} contributed ${fmt(contribution)} ${su} at ${time}. Contract balance is ${fmt(balance)} ${su}.`);
    //     if (stdlib.addressEq(addr, acc.networkAccount)) { contributorApi.willContribute = false; }
    //   },
    //   // reportExit: () => { console.log(`${me}: The contract is exiting.`); },
    //   reportProjectName: (name) => { console.log(`${me}: ${Who} project name is ${name}.`); },
    //   // reportTimeout: () => { console.log(`${me}: Contract timed out.`) },
    //   // reportTransfer: (amt, addr) => { console.log(`${me}: Transferred ${fmt(amt)} ${su} to ${abbrAddr(addr)}.`); },
    // };


    const acc = await stdlib.newTestAccount(iBalance);
    const info = await ask('Paste contract info:', (s) => JSON.parse(s));
    const ctc = acc.contract(backend, info);
    await showBalance(acc);
    await ctc.p.Sponsor(sponsorInteract);
    await showBalance(acc);
  }

  done();
})();


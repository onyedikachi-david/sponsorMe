'reach 0.1';
const projectName = Bytes(28);
const projectDetails = Bytes(28);
const fundraisingGoal = UInt;

const commonInteract = {
  reportPayment: Fun([UInt], Null),
  reportTransfer: Fun([UInt], Null),
  reportExit: Fun([], Null),
  reportCancellation: Fun([], Null),
  reportTokenMinted: Fun(true, Null),
  didTransfer: Fun([Bool, UInt], Null),
};

const projectOwnerInteract = {
  ...commonInteract,
  projectInfo: Object({projectName: projectName, projectDetails: projectDetails, fundraisingGoal: fundraisingGoal}),
  reportReady: Fun([], Null),
  getParams: Fun([], Object({
    name: Bytes(32), symbol: Bytes(8),
    url: Bytes(96), metadata: Bytes(32),
    supply: UInt,
    amt: UInt,
  })),
};

const sponsorInteract = {
  ...commonInteract,
  sponsor: Fun(
    [Object({projectName: projectName, projectDetails: projectDetails, fundraisingGoal: fundraisingGoal})],
    Object({ contribute: Bool, amt: UInt })
  ),
  confirmAgreeToSponsor: Fun([UInt], Bool),
};

export const main = Reach.App(() => {
  const PO = Participant('ProjectOwner', projectOwnerInteract);
  const S = Participant('Sponsor', sponsorInteract);
  deploy(); // deploy function takes you to the Step mode


  PO.only(() => { const projectInfo = declassify(interact.projectInfo); });
  PO.publish(projectInfo);
  
  PO.interact.reportReady();

  commit();


  S.only(() => { const sponsor = declassify(interact.sponsor(projectInfo)); }); 
  S.publish(sponsor);
  if (sponsor.contribute == false) {
    commit();
    each([S, PO], () => interact.reportCancellation());
    each([S, PO], () => interact.reportExit());
    exit();
  } else {
    commit();
  }


  PO.only(() => { const fund = projectInfo.fundraisingGoal; });

  PO.publish(fund);

  commit();

  S.only(() => { const willFund = declassify(interact.confirmAgreeToSponsor(fund)); });
  S.publish(willFund);
  if (!willFund) {
    commit();
    each([S, PO], () => interact.reportCancellation());
    each([S, PO], () => interact.reportExit());
    exit();
  } else {
  commit();
  }


  S.pay(fund);
  // transfer(fund).to(PO);
  each([PO, S], () => interact.reportPayment(fund));
  transfer(fund).to(PO);
  each([PO, S], () => interact.reportTransfer(fund));
  commit();
// Get token details and mint
  PO.only(() => {const { name, symbol, url, metadata, supply, amt } = declassify(interact.getParams());
  assume(4 * amt <= supply);
  assume(4 * amt <= UInt.max);
});
  
  PO.publish(name, symbol, url, metadata, supply, amt);
  require(4 * amt <= supply);
  require(4 * amt <= UInt.max);

  const md1 = {name, symbol, url, metadata, supply};
  // Minting token here
  const tok1 = new Token(md1);
  PO.interact.reportTokenMinted(tok1, md1);
  commit();

  S.publish();
  S.interact.reportTokenMinted(tok1, md1);
  commit();
// Todo: Add if statement for gradual release of funds...
  const doTransfer1 = (who, tokX) => {
    if (who == PO){
      transfer(2 * amt, tokX).to(who);
      who.interact.didTransfer(true, amt);
    } else {
    transfer(2 * amt, tokX).to(who);
    who.interact.didTransfer(true, amt);
    }
  };
  
  S.publish();
  doTransfer1(S, tok1);
  commit();
  PO.publish();
  doTransfer1(PO, tok1);
  commit();
  PO.pay([[2*amt, tok1]]);
  commit();
  S.pay([[2*amt, tok1]]);
  tok1.burn(supply);
  tok1.destroy();

  commit();

  each([PO, S], () => interact.reportExit());
  exit();
});
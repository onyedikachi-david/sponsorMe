'reach 0.1';
const projectName = Bytes(28);
const projectDetails = Bytes(28);
const fundraisingGoal = UInt;

const commonInteract = {
  reportExit: Fun([], Null),
  reportCancellation: Fun([], Null),
  showToken: Fun(true, Null),
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
};

export const main = Reach.App(() => {
  const PO = Participant('ProjectOwner', projectOwnerInteract);
  const S = Participant('Sponsor', sponsorInteract);
  deploy(); // deploy function takes you to the Step mode


  PO.only(() => { const projectInfo = declassify(interact.projectInfo); });
  PO.publish(projectInfo);
  
  PO.interact.reportReady();

  commit();

  // S.only(() => { const willContribute = declassify(interact.confirmContribution(sponsor.fundraisingGoal))})
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
    // const token4Sponsor = fund/(100 * 15);
    // const token4Owner = (100-15)*(fund/100)});
  PO.publish(fund);
  // PO.publish(token4Owner);
  // PO.publish(token4Sponsor);

  commit();

  // const getParams = 
  PO.only(() => {const { name, symbol, url, metadata, supply, amt } = declassify(interact.getParams());
  assume(4 * amt <= supply);
  assume(4 * amt <= UInt.max);
});
  
  PO.publish(name, symbol, url, metadata, supply, amt);
  require(4 * amt <= supply);
  require(4 * amt <= UInt.max);

  const md1 = {name, symbol, url, metadata, supply};
  const tok1 = new Token(md1);
  PO.interact.showToken(tok1, md1);
  commit();
  S.publish();
  S.interact.showToken(tok1, md1);
  commit();
// Todo: Add if statement for gradual release of funds...
  // const doTransfer1 = (who, tokX) => {
  //   if (who == PO){
  //     transfer(2 * amt, tokX).to(who);
  //     who.interact.didTransfer(true, amt);
  //     commit();
  //   } else {
  //     transfer(2 * amt, tokX).to(who);
  //     who.interact.didTransfer(true, amt);
  //     commit();
  //   }
    
  // };

  const doTransfer1 = (who, tokX) => {
    transfer(2 * amt, tokX).to(who);
    who.interact.didTransfer(true, amt);
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

  // const md2 = {name, symbol};
  // const tok2 = new Token(md2);
  // A.interact.showToken(tok2, md2);
  // B.interact.showToken(tok2, md2);
  // commit();

  // B.publish();
  // doTransfer1(B, tok2);
  // commit();
  // A.publish();
  // doTransfer1(A, tok2);
  // tok2.burn(/* defaults to all */);
  // commit();
  // A.pay([[2*amt, tok2]]);
  // commit();
  // B.pay([[2*amt, tok2]]);
  // tok2.burn();
  // tok2.destroy();
  // commit();
  // S.only(() => { const willFund = declassify(interact.confirmSponsor(fund)); });
  // S.publish(willFund);
  // if (!willFund) {
  //   commit();
  //   each([S, PO], () => interact.reportCancellation());
  //   each([S, PO], () => interact.reportExit());
  //   exit();
  // } else {
  // commit();
  // }

  //generates new token
  // const supply;
  // require(supply >= fund);

  // const tok = new Token({ name =  "Project Token", symbol =  "PTK", url, metadata, supply = fund, decimals });
  //calculate percentage tokens for proposal owner and sponsors
  // const sponsorToken = supply*0.4;
  // const proposalToken = tok - sponsorToken;
  //transfer tokens
  // transfer(sponsorToken, tok).to(PO);
  // transfer(proposalToken, tok).to(S)
  
  // S.pay(fund);
  // transfer(fund).to(PO);
  // const token4Sponsor = fund/(100 * 15)
  // const token4Owner = (100-15)*(fund/100)
  // transfer(token4Sponsor).to(S);
  // transfer(token4Owner).to(PO);
  // transfer(token4Sponsor).to(S)
  commit();

  each([PO, S], () => interact.reportExit());
  exit();
});
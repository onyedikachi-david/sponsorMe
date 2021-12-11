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
  // commit();

  each([PO, S], () => interact.reportExit());
  exit();
});
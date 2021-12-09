'reach 0.1';
const projectName = Bytes(28);
const projectDetails = Bytes(28);
const fundraisingGoal = UInt;

const commonInteract = {
  reportExit: Fun([], Null),
  reportCancellation: Fun([], Null)
};

const projectOwnerInteract = {
  ...commonInteract,
  projectInfo: Object({projectName: projectName, projectDetails: projectDetails, fundraisingGoal: fundraisingGoal}),
  reportReady: Fun([], Null)
};

const sponsorInteract = {
  ...commonInteract,
  sponsor: Fun(
    [Object({projectName: projectName, projectDetails: projectDetails, fundraisingGoal: fundraisingGoal})],
    Object({ contribute: Bool, amt: UInt })
  ),
  // confirmSponsor: Fun([UInt], Bool),
  // confirmContribution: Fun([UInt], Bool),
  // sendFund: 
};

export const main = Reach.App(() => {
  const PO = Participant('ProjectOwner', projectOwnerInteract);
  const S = Participant('Sponsor', sponsorInteract);
  deploy();


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
  
  S.pay(fund);
  transfer(fund).to(PO);
  // const token4Sponsor = fund/(100 * 15)
  // const token4Owner = (100-15)*(fund/100)
  // transfer(token4Sponsor).to(S);
  // transfer(token4Owner).to(PO);
  // transfer(token4Sponsor).to(S)
  commit();

  each([PO, S], () => interact.reportExit());
  exit();
});
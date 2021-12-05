'reach 0.1';
const projectName = Bytes(28);
const projectDetails = Bytes(28);
const fundraisingGoal = UInt;

const commonInteract = {
  reportExit: Fun([], Null)
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
    Object({ amt: UInt })
  )
};

export const main = Reach.App(() => {
  const PO = Participant('ProjectOwner', projectOwnerInteract);
  const S = Participant('Sponsor', sponsorInteract);
  deploy();


  PO.only(() => { const projectInfo = declassify(interact.projectInfo); });
  PO.publish(projectInfo);
  PO.interact.reportReady();
  commit();


  S.only(() => { const sponsor = declassify(interact.sponsor(projectInfo)); }); 
  S.publish(sponsor);
  commit();

  each([PO, S], () => interact.reportExit());
  exit();
});
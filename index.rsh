'reach 0.1';

const commonInteract = {
  reportExit: Fun([], Null)
};

const projectOwnerInteract = {
  ...commonInteract,
  reportReady: Fun([], Null)
};

const sponsorInteract = {
  ...commonInteract
};

export const main = Reach.App(() => {
  const PO = Participant('ProjectOwner', projectOwnerInteract);
  const S = Participant('Sponsor', sponsorInteract);
  deploy();

  PO.publish();
  PO.interact.reportReady();
  commit();

  S.publish();
  commit();

  each([PO, S], () => interact.reportExit());
  exit();
});
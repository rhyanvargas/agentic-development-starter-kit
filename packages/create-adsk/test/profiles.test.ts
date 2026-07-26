import { describe, expect, it } from "vitest";
import { getProfile, loadProfiles } from "../src/profiles.js";
import { snapshotRoot } from "./helpers/temp-app.js";

describe("profiles", () => {
  it("loads delivery skills from snapshotted profiles.json", () => {
    const profiles = loadProfiles(snapshotRoot());
    const delivery = getProfile(profiles, "delivery");
    expect(delivery.skills).toEqual([
      "spec-driven-workflow",
      "solution-architecture",
      "devops-strategy-facilitator",
      "release-automation",
    ]);
  });

  it("skills-only has cursor none", () => {
    const profiles = loadProfiles(snapshotRoot());
    expect(getProfile(profiles, "skills-only").cursor).toBe("none");
  });

  it("maintainer includes supply-chain-gate and pull-request-authoring", () => {
    const profiles = loadProfiles(snapshotRoot());
    const skills = getProfile(profiles, "maintainer").skills;
    expect(skills).toContain("supply-chain-gate");
    expect(skills).toContain("pull-request-authoring");
  });
});

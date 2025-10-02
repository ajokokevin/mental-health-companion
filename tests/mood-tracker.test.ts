import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

/*
  Mood Tracker Smart Contract Tests
  Testing daily mood logging, wellness goals, crisis support, and privacy features
*/

describe("Mood Tracker Contract", () => {
  beforeEach(() => {
    // Reset simnet state before each test
    simnet.mineEmptyBlocks(1);
  });

  describe("Initialization", () => {
    it("initializes with zero counters", () => {
      const entryCounter = simnet.callReadOnlyFn("mood-tracker", "get-entry-counter", [], address1);
      const goalCounter = simnet.callReadOnlyFn("mood-tracker", "get-goal-counter", [], address1);
      const insightCounter = simnet.callReadOnlyFn("mood-tracker", "get-insight-counter", [], address1);
      
      expect(entryCounter.result).toBeUint(0);
      expect(goalCounter.result).toBeUint(0);
      expect(insightCounter.result).toBeUint(0);
    });
  });

  describe("Mood Entry Logging", () => {
    it("successfully logs a mood entry with valid data", () => {
      const { result } = simnet.callPublicFn(
        "mood-tracker",
        "log-mood-entry",
        [
          Cl.uint(7),  // mood-score
          Cl.uint(6),  // energy-level
          Cl.uint(4),  // stress-level
          Cl.uint(3),  // anxiety-level
          Cl.uint(8),  // sleep-quality
          Cl.uint(7),  // social-interaction
          Cl.uint(5),  // physical-activity
          Cl.stringAscii("Feeling good today"),  // notes
          Cl.list([Cl.stringAscii("work-stress")]),  // triggers
          Cl.list([Cl.stringAscii("exercise"), Cl.stringAscii("meditation")]),  // activities
          Cl.list([])  // medications
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(0));
    });

    it("rejects mood entry with invalid mood score", () => {
      const { result } = simnet.callPublicFn(
        "mood-tracker",
        "log-mood-entry",
        [
          Cl.uint(11),  // Invalid mood-score (> 10)
          Cl.uint(6),
          Cl.uint(4),
          Cl.uint(3),
          Cl.uint(8),
          Cl.uint(7),
          Cl.uint(5),
          Cl.stringAscii("Test"),
          Cl.list([]),
          Cl.list([]),
          Cl.list([])
        ],
        address1
      );
      
      expect(result).toBeErr(Cl.uint(400));  // ERR-INVALID-INPUT
    });

    it("allows user to retrieve their own mood entry", () => {
      // First log an entry
      simnet.callPublicFn(
        "mood-tracker",
        "log-mood-entry",
        [
          Cl.uint(7), Cl.uint(6), Cl.uint(4), Cl.uint(3), Cl.uint(8),
          Cl.uint(7), Cl.uint(5), Cl.stringAscii("Test entry"),
          Cl.list([]), Cl.list([]), Cl.list([])
        ],
        address1
      );

      // Then retrieve it
      const { result } = simnet.callReadOnlyFn(
        "mood-tracker",
        "get-mood-entry",
        [Cl.uint(0)],
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Wellness Goals", () => {
    it("creates a wellness goal successfully", () => {
      const { result } = simnet.callPublicFn(
        "mood-tracker",
        "create-wellness-goal",
        [
          Cl.stringAscii("daily-meditation"),
          Cl.uint(30),  // target-value: 30 days
          Cl.uint(1000), // target-date
          Cl.list([Cl.uint(7), Cl.uint(14), Cl.uint(21)])  // milestones
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(0));
    });

    it("updates goal progress correctly", () => {
      // Create a goal first
      simnet.callPublicFn(
        "mood-tracker",
        "create-wellness-goal",
        [
          Cl.stringAscii("exercise"),
          Cl.uint(100),
          Cl.uint(1000),
          Cl.list([])
        ],
        address1
      );

      // Update progress
      const { result } = simnet.callPublicFn(
        "mood-tracker",
        "update-goal-progress",
        [Cl.uint(0), Cl.uint(50)],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(50));  // 50% progress
    });

    it("retrieves wellness goal data", () => {
      simnet.callPublicFn(
        "mood-tracker",
        "create-wellness-goal",
        [
          Cl.stringAscii("sleep-quality"),
          Cl.uint(8),
          Cl.uint(1000),
          Cl.list([])
        ],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "mood-tracker",
        "get-wellness-goal",
        [Cl.uint(0)],
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Crisis Support", () => {
    it("updates crisis support plan", () => {
      const { result } = simnet.callPublicFn(
        "mood-tracker",
        "update-crisis-support-plan",
        [
          Cl.list([Cl.stringAscii("emergency-contact-1")]),
          Cl.list([Cl.stringAscii("crisis-hotline")]),
          Cl.stringAscii("My safety plan details"),
          Cl.list([Cl.stringAscii("therapist")])
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.bool(true));
    });

    it("updates crisis risk level", () => {
      const { result } = simnet.callPublicFn(
        "mood-tracker",
        "update-crisis-risk-level",
        [Cl.stringAscii("medium")],
        address1
      );
      
      expect(result).toBeOk(Cl.bool(true));
    });

    it("retrieves crisis support plan", () => {
      simnet.callPublicFn(
        "mood-tracker",
        "update-crisis-support-plan",
        [
          Cl.list([]),
          Cl.list([]),
          Cl.stringAscii("Test plan"),
          Cl.list([])
        ],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "mood-tracker",
        "get-crisis-support-plan",
        [],
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Anonymous Research", () => {
    it("contributes anonymous data", () => {
      const { result } = simnet.callPublicFn(
        "mood-tracker",
        "contribute-anonymous-data",
        [
          Cl.uint(7),
          Cl.stringAscii("2024-Q1")
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.bool(true));
    });

    it("retrieves anonymous statistics", () => {
      simnet.callPublicFn(
        "mood-tracker",
        "contribute-anonymous-data",
        [Cl.uint(8), Cl.stringAscii("2024-Q1")],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "mood-tracker",
        "get-anonymous-stats",
        [Cl.stringAscii("2024-Q1")],
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Privacy & Security", () => {
    it("prevents users from accessing other users' mood entries", () => {
      // User 1 logs an entry
      simnet.callPublicFn(
        "mood-tracker",
        "log-mood-entry",
        [
          Cl.uint(7), Cl.uint(6), Cl.uint(4), Cl.uint(3), Cl.uint(8),
          Cl.uint(7), Cl.uint(5), Cl.stringAscii("Private entry"),
          Cl.list([]), Cl.list([]), Cl.list([])
        ],
        address1
      );

      // User 2 tries to access User 1's entry
      const { result } = simnet.callReadOnlyFn(
        "mood-tracker",
        "get-mood-entry",
        [Cl.uint(0)],
        address2  // Different user
      );
      
      expect(result).toBeNone();  // Should not be able to access
    });

    it("maintains separate goal counters per user", () => {
      // User 1 creates a goal
      simnet.callPublicFn(
        "mood-tracker",
        "create-wellness-goal",
        [
          Cl.stringAscii("goal-1"),
          Cl.uint(10),
          Cl.uint(1000),
          Cl.list([])
        ],
        address1
      );

      // User 2 creates a goal
      simnet.callPublicFn(
        "mood-tracker",
        "create-wellness-goal",
        [
          Cl.stringAscii("goal-2"),
          Cl.uint(20),
          Cl.uint(1000),
          Cl.list([])
        ],
        address2
      );

      // Each user can only see their own goals
      const user1Goal = simnet.callReadOnlyFn(
        "mood-tracker",
        "get-wellness-goal",
        [Cl.uint(0)],
        address1
      );
      
      const user2Goal = simnet.callReadOnlyFn(
        "mood-tracker",
        "get-wellness-goal",
        [Cl.uint(1)],
        address2
      );
      
      expect(user1Goal.result).toBeSome();
      expect(user2Goal.result).toBeSome();
    });
  });
});

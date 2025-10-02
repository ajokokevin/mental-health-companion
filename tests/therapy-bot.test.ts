import { describe, expect, it, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const deployer = accounts.get("deployer")!;

/*
  Therapy Bot Smart Contract Tests
  Testing AI therapeutic sessions, assessments, progress tracking, and crisis intervention
*/

describe("Therapy Bot Contract", () => {
  beforeEach(() => {
    // Reset simnet state before each test
    simnet.mineEmptyBlocks(1);
  });

  describe("Initialization", () => {
    it("initializes with zero counters", () => {
      const sessionCounter = simnet.callReadOnlyFn("therapy-bot", "get-session-counter", [], address1);
      const conversationCounter = simnet.callReadOnlyFn("therapy-bot", "get-conversation-counter", [], address1);
      const assessmentCounter = simnet.callReadOnlyFn("therapy-bot", "get-assessment-counter", [], address1);
      
      expect(sessionCounter.result).toBeUint(0);
      expect(conversationCounter.result).toBeUint(0);
      expect(assessmentCounter.result).toBeUint(0);
    });
  });

  describe("Therapy Session Management", () => {
    it("starts a therapy session successfully", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [
          Cl.stringAscii("anxiety-management"),
          Cl.uint(6),  // mood-before (1-10)
          Cl.stringAscii("CBT")
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(0));
    });

    it("rejects session start with invalid mood score", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [
          Cl.stringAscii("depression-support"),
          Cl.uint(15),  // Invalid mood score (> 10)
          Cl.stringAscii("DBT")
        ],
        address1
      );
      
      expect(result).toBeErr(Cl.uint(400));  // ERR-INVALID-INPUT
    });

    it("ends a therapy session with valid data", () => {
      // Start session first
      simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [
          Cl.stringAscii("mindfulness"),
          Cl.uint(5),
          Cl.stringAscii("Mindfulness-Based")
        ],
        address1
      );

      // End the session
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "end-therapy-session",
        [
          Cl.uint(0),  // session-id
          Cl.uint(7),  // mood-after
          Cl.list([Cl.stringAscii("anxiety"), Cl.stringAscii("breathing")]),  // topics-discussed
          Cl.stringAscii("Patient showed improvement in anxiety management"),  // progress-notes
          Cl.stringAscii("Practice breathing exercises daily"),  // homework-assigned
          Cl.uint(4)   // session-rating (1-5)
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.bool(true));
    });

    it("retrieves therapy session data", () => {
      simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [
          Cl.stringAscii("trauma-therapy"),
          Cl.uint(4),
          Cl.stringAscii("EMDR")
        ],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-therapy-session",
        [Cl.uint(0)],
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Conversation Logging", () => {
    it("logs conversation successfully in active session", () => {
      // Start session first
      simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [
          Cl.stringAscii("general-therapy"),
          Cl.uint(5),
          Cl.stringAscii("Person-Centered")
        ],
        address1
      );

      // Log conversation
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "log-conversation",
        [
          Cl.uint(0),  // session-id
          Cl.stringAscii("I'm feeling anxious about work"),  // user-input
          Cl.stringAscii("I understand. Can you tell me more about what specifically at work is causing this anxiety?"),  // bot-response
          Cl.stringAscii("work-anxiety"),  // conversation-context
          Cl.stringAscii("active-listening"),  // therapeutic-technique
          Cl.stringAscii("negative")  // sentiment-analysis
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(0));
    });

    it("detects crisis keywords and triggers intervention", () => {
      // Start session
      simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [Cl.stringAscii("crisis-session"), Cl.uint(2), Cl.stringAscii("Crisis-Intervention")],
        address1
      );

      // Log conversation with crisis keyword
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "log-conversation",
        [
          Cl.uint(0),
          Cl.stringAscii("suicide"),  // Crisis keyword
          Cl.stringAscii("I'm very concerned about what you just shared..."),
          Cl.stringAscii("crisis-intervention"),
          Cl.stringAscii("crisis-response"),
          Cl.stringAscii("critical")
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(3));  // Should return intervention level
    });

    it("retrieves conversation data", () => {
      simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [Cl.stringAscii("test-session"), Cl.uint(6), Cl.stringAscii("CBT")],
        address1
      );

      simnet.callPublicFn(
        "therapy-bot",
        "log-conversation",
        [
          Cl.uint(0),
          Cl.stringAscii("Test input"),
          Cl.stringAscii("Test response"),
          Cl.stringAscii("test"),
          Cl.stringAscii("reflection"),
          Cl.stringAscii("neutral")
        ],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-conversation",
        [Cl.uint(0), Cl.uint(0)],  // session-id, conversation-id
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Mental Health Assessments", () => {
    it("conducts assessment with high risk result", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "conduct-assessment",
        [
          Cl.stringAscii("PHQ-9"),
          Cl.uint(9),   // questions-answered
          Cl.uint(9),   // total-questions
          Cl.uint(25)   // raw-score (high score = high risk)
        ],
        address1
      );
      
      // Should trigger crisis intervention due to high risk
      expect(result).toBeOk(Cl.uint(3));
    });

    it("conducts assessment with low risk result", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "conduct-assessment",
        [
          Cl.stringAscii("GAD-7"),
          Cl.uint(7),
          Cl.uint(7),
          Cl.uint(20)   // Lower raw-score = lower risk
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(0));  // assessment-id
    });

    it("retrieves assessment results", () => {
      simnet.callPublicFn(
        "therapy-bot",
        "conduct-assessment",
        [
          Cl.stringAscii("Beck-Depression"),
          Cl.uint(21),
          Cl.uint(21),
          Cl.uint(30)
        ],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-assessment",
        [Cl.uint(0)],
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Progress Tracking", () => {
    it("creates and updates progress tracking", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "update-progress-tracking",
        [],
        address1
      );
      
      expect(result).toBeOk(Cl.bool(true));
    });

    it("learns coping strategies", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "learn-coping-strategy",
        [Cl.stringAscii("deep-breathing")],
        address1
      );
      
      expect(result).toBeOk(Cl.bool(true));
    });

    it("retrieves progress tracking data", () => {
      simnet.callPublicFn(
        "therapy-bot",
        "update-progress-tracking",
        [],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-progress-tracking",
        [],
        address1
      );
      
      expect(result).toBeSome();
    });

    it("retrieves session statistics", () => {
      simnet.callPublicFn(
        "therapy-bot",
        "update-progress-tracking",
        [],
        address1
      );
      
      simnet.callPublicFn(
        "therapy-bot",
        "learn-coping-strategy",
        [Cl.stringAscii("mindfulness")],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-session-statistics",
        [],
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Crisis Intervention", () => {
    it("triggers crisis intervention manually", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "trigger-crisis-intervention",
        [
          Cl.stringAscii("suicidal-ideation-detected"),
          Cl.stringAscii("high")
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(3));  // High intervention level
    });

    it("handles medium risk intervention", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "trigger-crisis-intervention",
        [
          Cl.stringAscii("moderate-distress"),
          Cl.stringAscii("medium")
        ],
        address1
      );
      
      expect(result).toBeOk(Cl.uint(2));  // Medium intervention level
    });

    it("retrieves crisis intervention data", () => {
      simnet.callPublicFn(
        "therapy-bot",
        "trigger-crisis-intervention",
        [
          Cl.stringAscii("test-trigger"),
          Cl.stringAscii("low")
        ],
        address1
      );

      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-crisis-intervention",
        [Cl.uint(1)],  // Low risk = level 1
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Therapeutic Resources", () => {
    it("allows contract owner to add therapeutic resources", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "add-therapeutic-resource",
        [
          Cl.stringAscii("coping-strategy"),
          Cl.stringAscii("Progressive Muscle Relaxation"),
          Cl.stringAscii("A technique to reduce physical tension and mental stress by systematically tensing and relaxing muscle groups"),
          Cl.stringAscii("relaxation"),
          Cl.uint(9),  // effectiveness-rating
          Cl.stringAscii("beginner"),
          Cl.list([Cl.stringAscii("anxiety"), Cl.stringAscii("stress")])
        ],
        deployer  // Contract owner
      );
      
      expect(result).toBeOk(Cl.uint(0));
    });

    it("prevents non-owner from adding therapeutic resources", () => {
      const { result } = simnet.callPublicFn(
        "therapy-bot",
        "add-therapeutic-resource",
        [
          Cl.stringAscii("breathing"),
          Cl.stringAscii("Test Resource"),
          Cl.stringAscii("Test Description"),
          Cl.stringAscii("test"),
          Cl.uint(5),
          Cl.stringAscii("intermediate"),
          Cl.list([])
        ],
        address1  // Not contract owner
      );
      
      expect(result).toBeErr(Cl.uint(401));  // ERR-NOT-AUTHORIZED
    });

    it("retrieves therapeutic resource data", () => {
      simnet.callPublicFn(
        "therapy-bot",
        "add-therapeutic-resource",
        [
          Cl.stringAscii("meditation"),
          Cl.stringAscii("Guided Meditation"),
          Cl.stringAscii("Audio-guided meditation sessions"),
          Cl.stringAscii("mindfulness"),
          Cl.uint(8),
          Cl.stringAscii("all-levels"),
          Cl.list([Cl.stringAscii("anxiety")])
        ],
        deployer
      );

      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-therapeutic-resource",
        [Cl.stringAscii("meditation"), Cl.uint(1)],
        address1
      );
      
      expect(result).toBeSome();
    });
  });

  describe("Privacy & Security", () => {
    it("prevents users from accessing other users' sessions", () => {
      // User 1 starts a session
      simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [Cl.stringAscii("private-session"), Cl.uint(5), Cl.stringAscii("CBT")],
        address1
      );

      // User 2 tries to access User 1's session
      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-therapy-session",
        [Cl.uint(0)],
        address2  // Different user
      );
      
      expect(result).toBeNone();  // Should not be able to access
    });

    it("prevents users from accessing other users' conversations", () => {
      // User 1 session and conversation
      simnet.callPublicFn(
        "therapy-bot",
        "start-therapy-session",
        [Cl.stringAscii("private-convo"), Cl.uint(6), Cl.stringAscii("DBT")],
        address1
      );
      
      simnet.callPublicFn(
        "therapy-bot",
        "log-conversation",
        [
          Cl.uint(0),
          Cl.stringAscii("Private message"),
          Cl.stringAscii("Private response"),
          Cl.stringAscii("private"),
          Cl.stringAscii("confidential"),
          Cl.stringAscii("neutral")
        ],
        address1
      );

      // User 2 tries to access User 1's conversation
      const { result } = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-conversation",
        [Cl.uint(0), Cl.uint(0)],
        address2  // Different user
      );
      
      expect(result).toBeNone();
    });

    it("maintains separate progress tracking per user", () => {
      // Both users update their progress
      simnet.callPublicFn("therapy-bot", "update-progress-tracking", [], address1);
      simnet.callPublicFn("therapy-bot", "update-progress-tracking", [], address2);

      // Each user can only see their own progress
      const user1Progress = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-progress-tracking",
        [],
        address1
      );
      
      const user2Progress = simnet.callReadOnlyFn(
        "therapy-bot",
        "get-progress-tracking",
        [],
        address2
      );
      
      expect(user1Progress.result).toBeSome();
      expect(user2Progress.result).toBeSome();
      // They should be different objects (separate tracking)
    });
  });
});

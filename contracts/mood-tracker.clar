;; Mood Tracker Smart Contract
;; Module to log emotions and provide insights over time

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-ENTRY-NOT-FOUND (err u404))
(define-constant ERR-INVALID-INPUT (err u400))
(define-constant ERR-PRIVACY-VIOLATION (err u403))

;; Data Variables
(define-data-var entry-counter uint u0)
(define-data-var goal-counter uint u0)
(define-data-var insight-counter uint u0)

;; Daily mood entries with privacy protection
(define-map mood-entries
    { user: principal, entry-id: uint }
    {
        date: uint,
        mood-score: uint,
        energy-level: uint,
        stress-level: uint,
        anxiety-level: uint,
        sleep-quality: uint,
        social-interaction: uint,
        physical-activity: uint,
        notes: (string-ascii 500),
        triggers: (list 5 (string-ascii 64)),
        activities: (list 10 (string-ascii 64)),
        medications: (list 5 (string-ascii 64)),
        encrypted: bool
    }
)

;; Mental health goals and tracking
(define-map wellness-goals
    { user: principal, goal-id: uint }
    {
        goal-type: (string-ascii 32),
        target-value: uint,
        current-value: uint,
        start-date: uint,
        target-date: uint,
        progress-percentage: uint,
        status: (string-ascii 16),
        milestones: (list 10 uint),
        rewards: (list 5 (string-ascii 128))
    }
)

;; Mood patterns and insights
(define-map mood-insights
    { user: principal, insight-id: uint }
    {
        insight-type: (string-ascii 32),
        pattern-detected: (string-ascii 256),
        confidence-level: uint,
        recommendation: (string-ascii 512),
        evidence-points: (list 10 uint),
        generated-at: uint,
        acknowledged: bool
    }
)

;; Crisis support and emergency contacts
(define-map crisis-support
    { user: principal }
    {
        risk-level: (string-ascii 16),
        emergency-contacts: (list 3 (string-ascii 128)),
        preferred-resources: (list 5 (string-ascii 128)),
        crisis-plan: (string-ascii 1024),
        last-assessment: uint,
        support-team: (list 5 (string-ascii 128))
    }
)

;; Anonymous mood statistics for research
(define-map anonymous-stats
    { date-range: (string-ascii 16) }
    {
        avg-mood-score: uint,
        total-entries: uint,
        common-triggers: (list 5 (string-ascii 64)),
        improvement-rate: int,
        usage-patterns: (string-ascii 256)
    }
)

;; Private helper functions
(define-private (increment-entry-counter)
    (let ((current-id (var-get entry-counter)))
        (var-set entry-counter (+ current-id u1))
        current-id
    )
)

(define-private (increment-goal-counter)
    (let ((current-id (var-get goal-counter)))
        (var-set goal-counter (+ current-id u1))
        current-id
    )
)

(define-private (increment-insight-counter)
    (let ((current-id (var-get insight-counter)))
        (var-set insight-counter (+ current-id u1))
        current-id
    )
)

(define-private (is-valid-mood-score (score uint))
    (and (>= score u1) (<= score u10))
)

(define-private (calculate-wellness-score (mood uint) (energy uint) (stress uint) (anxiety uint) (sleep uint))
    (/ (+ mood energy (- u10 stress) (- u10 anxiety) sleep) u5)
)

(define-private (detect-crisis-risk (mood uint) (anxiety uint) (stress uint))
    (or (and (<= mood u3) (>= anxiety u8)) 
        (and (<= mood u2) (>= stress u9)))
)

;; Public Functions

;; Log daily mood entry
(define-public (log-mood-entry
    (mood-score uint)
    (energy-level uint)
    (stress-level uint)
    (anxiety-level uint)
    (sleep-quality uint)
    (social-interaction uint)
    (physical-activity uint)
    (notes (string-ascii 500))
    (triggers (list 5 (string-ascii 64)))
    (activities (list 10 (string-ascii 64)))
    (medications (list 5 (string-ascii 64)))
)
    (let ((entry-id (increment-entry-counter)))
        (if (and (is-valid-mood-score mood-score)
                 (is-valid-mood-score energy-level)
                 (is-valid-mood-score stress-level)
                 (is-valid-mood-score anxiety-level)
                 (is-valid-mood-score sleep-quality))
            (begin
                (map-set mood-entries
                    { user: tx-sender, entry-id: entry-id }
                    {
                        date: stacks-block-height,
                        mood-score: mood-score,
                        energy-level: energy-level,
                        stress-level: stress-level,
                        anxiety-level: anxiety-level,
                        sleep-quality: sleep-quality,
                        social-interaction: social-interaction,
                        physical-activity: physical-activity,
                        notes: notes,
                        triggers: triggers,
                        activities: activities,
                        medications: medications,
                        encrypted: true
                    }
                )
                ;; Check for crisis risk
                (if (detect-crisis-risk mood-score anxiety-level stress-level)
                    (update-crisis-risk-level "high")
                    (ok entry-id))
            )
            ERR-INVALID-INPUT
        )
    )
)

;; Create wellness goal
(define-public (create-wellness-goal
    (goal-type (string-ascii 32))
    (target-value uint)
    (target-date uint)
    (milestones (list 10 uint))
)
    (let ((goal-id (increment-goal-counter)))
        (begin
            (map-set wellness-goals
                { user: tx-sender, goal-id: goal-id }
                {
                    goal-type: goal-type,
                    target-value: target-value,
                    current-value: u0,
                    start-date: stacks-block-height,
                    target-date: target-date,
                    progress-percentage: u0,
                    status: "active",
                    milestones: milestones,
                    rewards: (list)
                }
            )
            (ok goal-id)
        )
    )
)

;; Update goal progress
(define-public (update-goal-progress (goal-id uint) (current-value uint))
    (match (map-get? wellness-goals { user: tx-sender, goal-id: goal-id })
        goal (let ((progress (/ (* current-value u100) (get target-value goal))))
                (begin
                    (map-set wellness-goals
                        { user: tx-sender, goal-id: goal-id }
                        (merge goal {
                            current-value: current-value,
                            progress-percentage: progress,
                            status: (if (>= current-value (get target-value goal)) "completed" "active")
                        })
                    )
                    (ok progress)
                )
            )
        ERR-ENTRY-NOT-FOUND
    )
)

;; Generate mood insight
(define-public (generate-mood-insight
    (insight-type (string-ascii 32))
    (pattern-detected (string-ascii 256))
    (confidence-level uint)
    (recommendation (string-ascii 512))
    (evidence-points (list 10 uint))
)
    (let ((insight-id (increment-insight-counter)))
        (begin
            (map-set mood-insights
                { user: tx-sender, insight-id: insight-id }
                {
                    insight-type: insight-type,
                    pattern-detected: pattern-detected,
                    confidence-level: confidence-level,
                    recommendation: recommendation,
                    evidence-points: evidence-points,
                    generated-at: stacks-block-height,
                    acknowledged: false
                }
            )
            (ok insight-id)
        )
    )
)

;; Update crisis support plan
(define-public (update-crisis-support-plan
    (emergency-contacts (list 3 (string-ascii 128)))
    (preferred-resources (list 5 (string-ascii 128)))
    (crisis-plan (string-ascii 1024))
    (support-team (list 5 (string-ascii 128)))
)
    (begin
        (map-set crisis-support
            { user: tx-sender }
            {
                risk-level: "normal",
                emergency-contacts: emergency-contacts,
                preferred-resources: preferred-resources,
                crisis-plan: crisis-plan,
                last-assessment: stacks-block-height,
                support-team: support-team
            }
        )
        (ok true)
    )
)

;; Update crisis risk level
(define-public (update-crisis-risk-level (risk-level (string-ascii 16)))
    (match (map-get? crisis-support { user: tx-sender })
        support (begin
                    (map-set crisis-support
                        { user: tx-sender }
                        (merge support {
                            risk-level: risk-level,
                            last-assessment: stacks-block-height
                        })
                    )
                    (ok true)
                )
        ;; Create default crisis support if none exists
        (begin
            (map-set crisis-support
                { user: tx-sender }
                {
                    risk-level: risk-level,
                    emergency-contacts: (list),
                    preferred-resources: (list),
                    crisis-plan: "",
                    last-assessment: stacks-block-height,
                    support-team: (list)
                }
            )
            (ok true)
        )
    )
)

;; Acknowledge insight
(define-public (acknowledge-insight (insight-id uint))
    (match (map-get? mood-insights { user: tx-sender, insight-id: insight-id })
        insight (begin
                    (map-set mood-insights
                        { user: tx-sender, insight-id: insight-id }
                        (merge insight { acknowledged: true })
                    )
                    (ok true)
                )
        ERR-ENTRY-NOT-FOUND
    )
)

;; Contribute to anonymous research (privacy-preserving)
(define-public (contribute-anonymous-data (mood-score uint) (date-range (string-ascii 16)))
    (match (map-get? anonymous-stats { date-range: date-range })
        stats (let ((new-total (+ (get total-entries stats) u1))
                    (new-avg (/ (+ (* (get avg-mood-score stats) (get total-entries stats)) mood-score) new-total)))
                (begin
                    (map-set anonymous-stats
                        { date-range: date-range }
                        (merge stats {
                            avg-mood-score: new-avg,
                            total-entries: new-total
                        })
                    )
                    (ok true)
                )
            )
        ;; Create new anonymous stat entry
        (begin
            (map-set anonymous-stats
                { date-range: date-range }
                {
                    avg-mood-score: mood-score,
                    total-entries: u1,
                    common-triggers: (list),
                    improvement-rate: 0,
                    usage-patterns: ""
                }
            )
            (ok true)
        )
    )
)

;; Read-only functions

;; Get mood entry (only accessible by owner)
(define-read-only (get-mood-entry (entry-id uint))
    (map-get? mood-entries { user: tx-sender, entry-id: entry-id })
)

;; Get wellness goal
(define-read-only (get-wellness-goal (goal-id uint))
    (map-get? wellness-goals { user: tx-sender, goal-id: goal-id })
)

;; Get mood insight
(define-read-only (get-mood-insight (insight-id uint))
    (map-get? mood-insights { user: tx-sender, insight-id: insight-id })
)

;; Get crisis support plan
(define-read-only (get-crisis-support-plan)
    (map-get? crisis-support { user: tx-sender })
)

;; Get anonymous statistics (research data)
(define-read-only (get-anonymous-stats (date-range (string-ascii 16)))
    (map-get? anonymous-stats { date-range: date-range })
)

;; Get current counters
(define-read-only (get-entry-counter)
    (var-get entry-counter)
)

(define-read-only (get-goal-counter)
    (var-get goal-counter)
)

(define-read-only (get-insight-counter)
    (var-get insight-counter)
)


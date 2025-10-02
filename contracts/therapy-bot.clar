;; Therapy Bot Smart Contract
;; AI-powered therapeutic conversations and mental health support

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SESSION-NOT-FOUND (err u404))
(define-constant ERR-INVALID-INPUT (err u400))
(define-constant ERR-SESSION-EXPIRED (err u410))
(define-constant ERR-MAX-SESSIONS-REACHED (err u429))

;; Data Variables
(define-data-var session-counter uint u0)
(define-data-var conversation-counter uint u0)
(define-data-var assessment-counter uint u0)
(define-data-var max-daily-sessions uint u10)

;; Therapy sessions with privacy and security
(define-map therapy-sessions
    { user: principal, session-id: uint }
    {
        session-type: (string-ascii 32),
        start-time: uint,
        end-time: uint,
        duration: uint,
        status: (string-ascii 16),
        mood-before: uint,
        mood-after: uint,
        topics-discussed: (list 10 (string-ascii 64)),
        therapeutic-approach: (string-ascii 32),
        progress-notes: (string-ascii 512),
        homework-assigned: (string-ascii 256),
        next-session-suggested: uint,
        session-rating: uint,
        encrypted: bool
    }
)

;; AI conversation logs with therapeutic context
(define-map conversations
    { user: principal, session-id: uint, conversation-id: uint }
    {
        user-input: (string-ascii 1024),
        bot-response: (string-ascii 1024),
        timestamp: uint,
        conversation-context: (string-ascii 128),
        therapeutic-technique: (string-ascii 64),
        sentiment-analysis: (string-ascii 32),
        crisis-indicators: (list 5 (string-ascii 32)),
        follow-up-required: bool,
        confidence-score: uint
    }
)

;; Mental health assessments and screening tools
(define-map mental-health-assessments
    { user: principal, assessment-id: uint }
    {
        assessment-type: (string-ascii 32),
        questions-answered: uint,
        total-questions: uint,
        raw-score: uint,
        normalized-score: uint,
        risk-level: (string-ascii 16),
        recommendations: (list 5 (string-ascii 128)),
        referral-needed: bool,
        completed-at: uint,
        valid-until: uint
    }
)

;; Therapeutic progress tracking
(define-map progress-tracking
    { user: principal }
    {
        total-sessions: uint,
        consistent-usage-days: uint,
        improvement-trajectory: int,
        goal-achievements: (list 10 (string-ascii 64)),
        behavioral-changes: (list 10 (string-ascii 128)),
        coping-strategies-learned: (list 15 (string-ascii 64)),
        last-progress-update: uint,
        overall-wellness-score: uint
    }
)

;; Crisis intervention protocols
(define-map crisis-interventions
    { user: principal, intervention-id: uint }
    {
        trigger-detected: (string-ascii 128),
        risk-assessment: (string-ascii 16),
        intervention-type: (string-ascii 32),
        resources-provided: (list 5 (string-ascii 128)),
        follow-up-scheduled: bool,
        human-oversight-required: bool,
        escalation-level: uint,
        intervention-timestamp: uint
    }
)

;; Therapeutic resources and coping strategies
(define-map therapeutic-resources
    { resource-type: (string-ascii 32), resource-id: uint }
    {
        title: (string-ascii 128),
        description: (string-ascii 512),
        category: (string-ascii 32),
        effectiveness-rating: uint,
        usage-count: uint,
        accessibility-level: (string-ascii 16),
        evidence-based: bool,
        target-conditions: (list 5 (string-ascii 32))
    }
)

;; Private helper functions
(define-private (increment-session-counter)
    (let ((current-id (var-get session-counter)))
        (var-set session-counter (+ current-id u1))
        current-id
    )
)

(define-private (increment-conversation-counter)
    (let ((current-id (var-get conversation-counter)))
        (var-set conversation-counter (+ current-id u1))
        current-id
    )
)

(define-private (increment-assessment-counter)
    (let ((current-id (var-get assessment-counter)))
        (var-set assessment-counter (+ current-id u1))
        current-id
    )
)

(define-private (is-valid-mood-score (score uint))
    (and (>= score u1) (<= score u10))
)

(define-private (calculate-session-duration (start-time uint) (end-time uint))
    (if (> end-time start-time)
        (- end-time start-time)
        u0
    )
)

(define-private (detect-crisis-keywords (input (string-ascii 1024)))
    ;; Simplified crisis detection - in real implementation would use ML
    (or (is-eq input "suicide") (is-eq input "self-harm") (is-eq input "crisis"))
)

(define-private (calculate-confidence-score (context (string-ascii 128)) (technique (string-ascii 64)))
    ;; Simplified confidence calculation
    (if (and (> (len context) u0) (> (len technique) u0))
        u85
        u60
    )
)

(define-private (assess-intervention-level (risk-level (string-ascii 16)))
    (if (is-eq risk-level "high")
        u3
        (if (is-eq risk-level "medium")
            u2
            u1
        )
    )
)

;; Public Functions

;; Start a new therapy session
(define-public (start-therapy-session
    (session-type (string-ascii 32))
    (mood-before uint)
    (therapeutic-approach (string-ascii 32))
)
    (let ((session-id (increment-session-counter)))
        (if (is-valid-mood-score mood-before)
            (begin
                (map-set therapy-sessions
                    { user: tx-sender, session-id: session-id }
                    {
                        session-type: session-type,
                        start-time: stacks-block-height,
                        end-time: u0,
                        duration: u0,
                        status: "active",
                        mood-before: mood-before,
                        mood-after: u0,
                        topics-discussed: (list),
                        therapeutic-approach: therapeutic-approach,
                        progress-notes: "",
                        homework-assigned: "",
                        next-session-suggested: u0,
                        session-rating: u0,
                        encrypted: true
                    }
                )
                (ok session-id)
            )
            ERR-INVALID-INPUT
        )
    )
)

;; Log conversation in session
(define-public (log-conversation
    (session-id uint)
    (user-input (string-ascii 1024))
    (bot-response (string-ascii 1024))
    (conversation-context (string-ascii 128))
    (therapeutic-technique (string-ascii 64))
    (sentiment-analysis (string-ascii 32))
)
    (let ((conversation-id (increment-conversation-counter)))
        (match (map-get? therapy-sessions { user: tx-sender, session-id: session-id })
            session (if (is-eq (get status session) "active")
                        (let ((crisis-detected (detect-crisis-keywords user-input))
                              (confidence (calculate-confidence-score conversation-context therapeutic-technique)))
                            (begin
                                (map-set conversations
                                    { user: tx-sender, session-id: session-id, conversation-id: conversation-id }
                                    {
                                        user-input: user-input,
                                        bot-response: bot-response,
                                        timestamp: stacks-block-height,
                                        conversation-context: conversation-context,
                                        therapeutic-technique: therapeutic-technique,
                                        sentiment-analysis: sentiment-analysis,
                                        crisis-indicators: (if crisis-detected (list "crisis-language") (list)),
                                        follow-up-required: crisis-detected,
                                        confidence-score: confidence
                                    }
                                )
                                ;; Trigger crisis intervention if needed
                                (if crisis-detected
                                    (trigger-crisis-intervention "crisis-language-detected" "high")
                                    (ok conversation-id))
                            )
                        )
                        ERR-SESSION-EXPIRED
                    )
            ERR-SESSION-NOT-FOUND
        )
    )
)

;; End therapy session
(define-public (end-therapy-session
    (session-id uint)
    (mood-after uint)
    (topics-discussed (list 10 (string-ascii 64)))
    (progress-notes (string-ascii 512))
    (homework-assigned (string-ascii 256))
    (session-rating uint)
)
    (match (map-get? therapy-sessions { user: tx-sender, session-id: session-id })
        session (if (and (is-eq (get status session) "active")
                        (is-valid-mood-score mood-after)
                        (and (>= session-rating u1) (<= session-rating u5)))
                    (let ((duration (calculate-session-duration (get start-time session) stacks-block-height)))
                        (begin
                            (map-set therapy-sessions
                                { user: tx-sender, session-id: session-id }
                                (merge session {
                                    end-time: stacks-block-height,
                                    duration: duration,
                                    status: "completed",
                                    mood-after: mood-after,
                                    topics-discussed: topics-discussed,
                                    progress-notes: progress-notes,
                                    homework-assigned: homework-assigned,
                                    session-rating: session-rating
                                })
                            )
                            (update-progress-tracking)
                            (ok true)
                        )
                    )
                    ERR-INVALID-INPUT
                )
        ERR-SESSION-NOT-FOUND
    )
)

;; Conduct mental health assessment
(define-public (conduct-assessment
    (assessment-type (string-ascii 32))
    (questions-answered uint)
    (total-questions uint)
    (raw-score uint)
)
    (let ((assessment-id (increment-assessment-counter))
          (normalized-score (/ (* raw-score u100) total-questions))
          (risk-level (if (> normalized-score u70) "low"
                         (if (> normalized-score u40) "medium" "high"))))
        (begin
            (map-set mental-health-assessments
                { user: tx-sender, assessment-id: assessment-id }
                {
                    assessment-type: assessment-type,
                    questions-answered: questions-answered,
                    total-questions: total-questions,
                    raw-score: raw-score,
                    normalized-score: normalized-score,
                    risk-level: risk-level,
                    recommendations: (if (is-eq risk-level "high") 
                                       (list "seek-professional-help" "crisis-support" "regular-monitoring")
                                       (list "continue-self-care" "regular-check-ins")),
                    referral-needed: (is-eq risk-level "high"),
                    completed-at: stacks-block-height,
                    valid-until: (+ stacks-block-height u4320) ;; ~30 days
                }
            )
            ;; Trigger intervention if high risk
            (if (is-eq risk-level "high")
                (trigger-crisis-intervention "high-risk-assessment" risk-level)
                (ok assessment-id))
        )
    )
)

;; Trigger crisis intervention
(define-public (trigger-crisis-intervention
    (trigger-detected (string-ascii 128))
    (risk-assessment (string-ascii 16))
)
    (let ((intervention-level (assess-intervention-level risk-assessment)))
        (begin
            (map-set crisis-interventions
                { user: tx-sender, intervention-id: intervention-level }
                {
                    trigger-detected: trigger-detected,
                    risk-assessment: risk-assessment,
                    intervention-type: (if (is-eq risk-assessment "high") "immediate" "supportive"),
                    resources-provided: (list "crisis-hotline" "emergency-contacts" "safety-plan" "local-resources"),
                    follow-up-scheduled: true,
                    human-oversight-required: (is-eq risk-assessment "high"),
                    escalation-level: intervention-level,
                    intervention-timestamp: stacks-block-height
                }
            )
            (ok intervention-level)
        )
    )
)

;; Update progress tracking
(define-public (update-progress-tracking)
    (match (map-get? progress-tracking { user: tx-sender })
        progress (let ((new-session-count (+ (get total-sessions progress) u1)))
                    (begin
                        (map-set progress-tracking
                            { user: tx-sender }
                            (merge progress {
                                total-sessions: new-session-count,
                                last-progress-update: stacks-block-height,
                                overall-wellness-score: (min (+ (get overall-wellness-score progress) u1) u100)
                            })
                        )
                        (ok true)
                    )
                 )
        ;; Create new progress tracking
        (begin
            (map-set progress-tracking
                { user: tx-sender }
                {
                    total-sessions: u1,
                    consistent-usage-days: u1,
                    improvement-trajectory: 0,
                    goal-achievements: (list),
                    behavioral-changes: (list),
                    coping-strategies-learned: (list),
                    last-progress-update: stacks-block-height,
                    overall-wellness-score: u50
                }
            )
            (ok true)
        )
    )
)

;; Add therapeutic resource
(define-public (add-therapeutic-resource
    (resource-type (string-ascii 32))
    (title (string-ascii 128))
    (description (string-ascii 512))
    (category (string-ascii 32))
    (effectiveness-rating uint)
    (accessibility-level (string-ascii 16))
    (target-conditions (list 5 (string-ascii 32)))
)
    (if (is-eq tx-sender CONTRACT-OWNER)
        (let ((resource-id (var-get session-counter))) ;; Reuse counter for simplicity
            (begin
                (map-set therapeutic-resources
                    { resource-type: resource-type, resource-id: resource-id }
                    {
                        title: title,
                        description: description,
                        category: category,
                        effectiveness-rating: effectiveness-rating,
                        usage-count: u0,
                        accessibility-level: accessibility-level,
                        evidence-based: true,
                        target-conditions: target-conditions
                    }
                )
                (ok resource-id)
            )
        )
        ERR-NOT-AUTHORIZED
    )
)

;; Learn coping strategy
(define-public (learn-coping-strategy (strategy (string-ascii 64)))
    (match (map-get? progress-tracking { user: tx-sender })
        progress (let ((current-strategies (get coping-strategies-learned progress)))
                    (begin
                        (map-set progress-tracking
                            { user: tx-sender }
                            (merge progress {
                                coping-strategies-learned: (unwrap-panic (as-max-len? (append current-strategies strategy) u15))
                            })
                        )
                        (ok true)
                    )
                 )
        ;; Initialize progress tracking with first strategy
        (begin
            (map-set progress-tracking
                { user: tx-sender }
                {
                    total-sessions: u0,
                    consistent-usage-days: u0,
                    improvement-trajectory: 0,
                    goal-achievements: (list),
                    behavioral-changes: (list),
                    coping-strategies-learned: (list strategy),
                    last-progress-update: stacks-block-height,
                    overall-wellness-score: u50
                }
            )
            (ok true)
        )
    )
)

;; Read-only functions

;; Get therapy session (privacy protected)
(define-read-only (get-therapy-session (session-id uint))
    (map-get? therapy-sessions { user: tx-sender, session-id: session-id })
)

;; Get conversation (privacy protected)
(define-read-only (get-conversation (session-id uint) (conversation-id uint))
    (map-get? conversations { user: tx-sender, session-id: session-id, conversation-id: conversation-id })
)

;; Get mental health assessment
(define-read-only (get-assessment (assessment-id uint))
    (map-get? mental-health-assessments { user: tx-sender, assessment-id: assessment-id })
)

;; Get progress tracking
(define-read-only (get-progress-tracking)
    (map-get? progress-tracking { user: tx-sender })
)

;; Get crisis intervention
(define-read-only (get-crisis-intervention (intervention-id uint))
    (map-get? crisis-interventions { user: tx-sender, intervention-id: intervention-id })
)

;; Get therapeutic resource (public)
(define-read-only (get-therapeutic-resource (resource-type (string-ascii 32)) (resource-id uint))
    (map-get? therapeutic-resources { resource-type: resource-type, resource-id: resource-id })
)

;; Get session statistics
(define-read-only (get-session-statistics)
    (match (map-get? progress-tracking { user: tx-sender })
        progress (some {
                    total-sessions: (get total-sessions progress),
                    consistent-days: (get consistent-usage-days progress),
                    wellness-score: (get overall-wellness-score progress),
                    strategies-learned: (len (get coping-strategies-learned progress))
                  })
        none
    )
)

;; Get current counters
(define-read-only (get-session-counter)
    (var-get session-counter)
)

(define-read-only (get-conversation-counter)
    (var-get conversation-counter)
)

(define-read-only (get-assessment-counter)
    (var-get assessment-counter)
)


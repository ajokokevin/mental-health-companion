# Mental Health Companion

A blockchain-powered mental health support platform leveraging decentralized technology to provide secure, private, and personalized mental wellness tracking and therapeutic assistance.

## 🧠 Overview

The Mental Health Companion platform combines AI-powered therapeutic conversations with comprehensive mood tracking to create a holistic mental health support system. Built on the Stacks blockchain, it ensures data privacy, security, and user ownership while providing evidence-based mental health interventions.

## ✨ Core Features

### 🎭 Mood Tracking System
- **Daily Emotion Logging**: Track mood, energy, stress, anxiety levels with comprehensive data points
- **Trigger Identification**: Record and analyze personal triggers and patterns
- **Activity Correlation**: Monitor relationships between activities, sleep, and mental state
- **Privacy-First Design**: All personal data encrypted and user-controlled
- **Wellness Goal Setting**: Create and track personalized mental health objectives
- **Crisis Detection**: Automatic identification of concerning patterns with support escalation

### 🤖 AI Therapy Bot
- **Therapeutic Conversations**: Evidence-based conversational therapy using CBT, DBT, and mindfulness techniques
- **Mental Health Assessments**: Standardized screening tools (PHQ-9, GAD-7 equivalent) with risk assessment
- **Progress Tracking**: Long-term monitoring of therapeutic progress and goal achievements
- **Crisis Intervention**: Automatic detection and response to mental health emergencies
- **Coping Strategy Library**: Personalized collection of therapeutic resources and techniques
- **Session Management**: Structured therapy sessions with homework and follow-up tracking

### 🔒 Privacy & Security
- **Data Sovereignty**: Users maintain complete control over their mental health data
- **Zero-Knowledge Architecture**: Personal information never exposed to third parties
- **Blockchain Immutability**: Tamper-proof therapeutic progress records
- **Anonymous Research**: Contribute to mental health research while maintaining privacy
- **HIPAA-Inspired Compliance**: Mental health data protection standards

## 🏗️ Architecture

### Smart Contracts

#### Mood Tracker Contract (`mood-tracker.clar`)
- **Daily Mood Entries**: Comprehensive emotional state tracking with privacy protection
- **Wellness Goals**: Goal setting, progress tracking, and achievement recognition
- **Mood Insights**: Pattern recognition and personalized recommendations
- **Crisis Support**: Emergency contact management and safety planning
- **Anonymous Research**: Privacy-preserving data contribution for mental health research

**Key Functions:**
- `log-mood-entry`: Record daily emotional and physical wellness data
- `create-wellness-goal`: Set and track personal mental health objectives
- `generate-mood-insight`: AI-powered pattern recognition and recommendations
- `update-crisis-support-plan`: Manage emergency contacts and safety protocols
- `contribute-anonymous-data`: Support research while maintaining privacy

#### Therapy Bot Contract (`therapy-bot.clar`)
- **Session Management**: Start, conduct, and complete therapeutic sessions
- **Conversation Logging**: Secure storage of therapeutic interactions
- **Mental Health Assessments**: Standardized screening and risk assessment
- **Progress Tracking**: Long-term therapeutic outcome monitoring
- **Crisis Intervention**: Automatic detection and escalation protocols
- **Resource Management**: Therapeutic tools and coping strategy libraries

**Key Functions:**
- `start-therapy-session`: Initialize structured therapeutic sessions
- `log-conversation`: Record AI-human therapeutic interactions
- `conduct-assessment`: Perform standardized mental health screenings
- `trigger-crisis-intervention`: Automatic emergency response protocols
- `learn-coping-strategy`: Build personalized therapeutic toolkits

## 🌟 Blockchain Benefits

### For Users
- **Data Ownership**: Complete control over personal mental health information
- **Privacy Guarantee**: Cryptographic protection of sensitive psychological data
- **Portability**: Access mental health records across different platforms and providers
- **Transparency**: Clear audit trail of therapeutic progress and interventions
- **Accessibility**: 24/7 availability without geographic or economic barriers

### For Healthcare Systems
- **Interoperability**: Seamless integration with existing mental health infrastructure
- **Cost Reduction**: Scalable mental health support reducing burden on healthcare systems
- **Evidence Generation**: Anonymous aggregated data for mental health research
- **Quality Assurance**: Immutable records of therapeutic interventions and outcomes
- **Regulatory Compliance**: Built-in privacy and security standards

### For Society
- **Reduced Stigma**: Private, accessible mental health support normalizing help-seeking
- **Early Intervention**: Proactive identification of mental health concerns
- **Research Advancement**: Large-scale, privacy-preserving mental health data collection
- **Global Access**: Borderless mental health support reaching underserved populations
- **Cost Efficiency**: Scalable solution addressing global mental health workforce shortage

## 🛡️ Security & Compliance

### Data Protection
- **End-to-End Encryption**: All personal data encrypted before blockchain storage
- **Access Control**: Role-based permissions ensuring data privacy
- **Audit Logging**: Comprehensive tracking of data access and modifications
- **Data Minimization**: Only necessary information collected and stored

### Mental Health Standards
- **Evidence-Based Practices**: Therapeutic interventions based on clinical research
- **Crisis Protocols**: Established emergency intervention procedures
- **Professional Oversight**: Integration points for licensed mental health providers
- **Ethical AI**: Responsible AI development with bias mitigation and transparency

## 🎯 Educational Benefits

### Mental Health Literacy
- **Psychoeducation**: Learn about mental health concepts and strategies
- **Self-Awareness**: Develop emotional intelligence through tracking and reflection
- **Coping Skills**: Build practical tools for managing mental health challenges
- **Stigma Reduction**: Normalize mental health conversations and help-seeking

### Therapeutic Skills
- **Mindfulness Training**: Guided meditation and mindfulness exercises
- **Cognitive Restructuring**: Learn to identify and challenge negative thought patterns
- **Behavioral Activation**: Structured activity scheduling and mood correlation
- **Social Skills**: Communication and relationship building exercises

## 🚀 Getting Started

### Prerequisites
- Stacks wallet (Hiro Wallet, Xverse, or similar)
- Basic understanding of blockchain transactions
- Commitment to regular mental health tracking

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/mental-health-companion.git
   cd mental-health-companion
   ```

2. Install dependencies:
   ```bash
   clarinet install
   ```

3. Deploy contracts to testnet:
   ```bash
   clarinet deployments apply -p deployments/default.testnet-plan.yaml
   ```

### Usage Examples

#### Logging Daily Mood
```clarity
(contract-call? .mood-tracker log-mood-entry
  u7    ;; mood-score (1-10)
  u6    ;; energy-level
  u4    ;; stress-level
  u3    ;; anxiety-level
  u8    ;; sleep-quality
  u7    ;; social-interaction
  u5    ;; physical-activity
  "Had a good day overall, completed work tasks"
  (list "work-stress" "weather")  ;; triggers
  (list "exercise" "meditation" "reading")  ;; activities
  (list "medication-A")  ;; medications
)
```

#### Starting Therapy Session
```clarity
(contract-call? .therapy-bot start-therapy-session
  "anxiety-management"  ;; session-type
  u4    ;; mood-before (1-10)
  "CBT"  ;; therapeutic-approach
)
```

## 🧪 Testing

Run the test suite:
```bash
clarinet test
```

Individual contract tests:
```bash
clarinet test tests/mood-tracker_test.ts
clarinet test tests/therapy-bot_test.ts
```

## 🤝 Contributing

We welcome contributions to improve mental health accessibility and blockchain innovation:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Clarity best practices and security patterns
- Include comprehensive tests for new features
- Document all public functions and complex logic
- Respect privacy and mental health ethical considerations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This platform provides educational and supportive mental health tools but is not a substitute for professional mental healthcare. Users experiencing mental health crises should contact emergency services or qualified mental health professionals immediately.

## 🆘 Crisis Resources

- **National Suicide Prevention Lifeline**: 988 (US)
- **Crisis Text Line**: Text HOME to 741741
- **International Association for Suicide Prevention**: https://www.iasp.info/resources/Crisis_Centres/
- **Emergency Services**: 911 (US), 999 (UK), 112 (EU)

## 📞 Support

- **Documentation**: [Project Wiki](https://github.com/yourusername/mental-health-companion/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/mental-health-companion/issues)
- **Community**: [Discord Server](https://discord.gg/mental-health-companion)
- **Email**: support@mental-health-companion.com

---

*Building a more accessible, private, and effective mental health support ecosystem through blockchain technology.* 🌟

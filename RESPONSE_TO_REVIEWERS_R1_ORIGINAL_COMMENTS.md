Response to Reviewers - Revision 1
Adult-infant neural coupling mediates infants' selection of socially-relevant stimuli for learning across cultures

===================================================================

REVIEWER 1

Reviewer 1 (Remarks to the Author):

This is a very interesting topic, one that has the potential to reveal important socially-mediated mechanisms of learning in young children. The current manuscript examines what the authors term "adult-infant interpersonal neural coupling." However, there are several problems with the manuscript that would need to be dealt with before a publication decision could be made, including terminology, statistical approach, details about the study (N of subjects included in analyses, artifact rejection, and the N for epochs included).

-------------------------------------------------------------------

COMMENT 1.1

With regard to terminology, from the abstract on, the language used to describe what is being measured ("adult-infant neural coupling") implies that the participants were involved in a dynamic interaction, in which both participants are engaged and responding in real time to each other's cues. However, in the current study, there was no natural interaction. The adult videos were pre-recorded independently, and neural coupling was measured while infants watched these video recordings. This is certainly an interesting approach, as it allows researchers to isolate and measure specific behavioral variables (e.g., eye gaze). That said, the authors should revise the terminology to indicate that, in this case, the infants are watching adults on video. This fact requires adjustment of the overall conclusions as well.

Related manuscript sections:
- Title
- Abstract: Lines 34-40
- Introduction: Lines 45-60, 85-95
- Methods: Lines 220-235 (EEG recording procedure)
- Results: Lines 174-176, 200-215, 250-280
- Discussion: Lines 450-480
- Throughout manuscript

Required changes:
[To be filled in based on your response]

-------------------------------------------------------------------

COMMENT 1.2

Regarding the statistical approach, an important comparison appears to be missing: the neural coupling values (GPDC) should be compared directly between conditions (gaze/no gaze), not only against surrogate data. This would help validate whether specific connections are significantly stronger in the gaze condition, and whether these connections are associated with infants' attention, learning, and CDI scores. Also, in the current comparison to the surrogate data, it would also be useful to test specifically the connections identified in the gaze condition and include only them in the PLS model.

Related manuscript sections:
- Results: Lines 250-280 (GPDC connectivity findings)
- Methods: Lines 380-420 (GPDC statistical testing)
- Supplementary Figure S4

Required analyses:
[To be filled in based on your response]

-------------------------------------------------------------------

COMMENT 1.3

Regarding details, the statistics used in the results section are not clearly stated. How many infants are included? What is the df (98)? It would be more typical to conduct repeated measures ANOVA first, followed by t-tests between conditions. The authors need to explain their statistical approach. In the same vein, the authors should provide information on the number of participants included in the final EEG analysis for each condition, following the preprocessing procedures. It's also unclear whether artifact rejection included blinking detection. Finally, how many epochs were included in the GPDC analysis for each condition on average?

Related manuscript sections:
- Methods: Lines 180-190 (Participants)
- Methods: Lines 240-280 (EEG preprocessing)
- Methods: Lines 420-450 (Statistical analysis)
- Results: Lines 174-176 (Learning analysis)
- Supplementary Table S4 (attrition)
- Supplementary Table S7 (data quality)

Required additions:
[To be filled in based on your response]

===================================================================

REVIEWER 2

Reviewer 2 (Remarks to the Author):

Overall assessment

The manuscript examined how adult-infant neural coupling mediates infants' selective learning of artificial languages as a function of speaker gaze availability (Full/Partial/No gaze) using pre-recorded video stimuli. The study included 47 infants (mean age 9.4 months) from Singapore and the UK, with 42 participants contributing usable EEG data. Learning was assessed using preferential looking paradigms (nonword vs. word looking times), with data analyzed using paired t-tests, neural coupling was analyzed through generalized partial directed coherence (GPDC), and neural entrainment via cross-correlation with speech envelopes.

The paper's key findings demonstrated that learning occurred significantly only under Full gaze conditions (assessed via paired t-tests within each condition: t?? = 2.66, corrected p < .05), adult-to-infant GPDC connectivity predicted learning outcomes (explaining 24.6% of variance in a PLS model), and mediation analysis using the first PLS component as the mediator indicated that gaze modulated learning through its effects on neural coupling. Notably, while neural entrainment was sensitive to gaze conditions (significant only in Full gaze), it did not predict learning performance, creating a dissociation between different neural measures.

The manuscript addresses an important question in developmental neuroscience with technical competence, but several critical methodological and interpretive issues significantly limit its contribution. The primary concerns include statistical methodology that departs from standard hierarchical testing practices, circularity and target leakage in the mediation analysis, and a mismatch between the experimental design and theoretical framing.

-------------------------------------------------------------------

MAJOR ISSUE 2.1

Mismatch between experimental design and theoretical framing. The study's central theoretical claim is undermined by a critical design limitation: The adult EEG was pre-recorded during the video stimulus creation (Lines 152-153, 419-427), not recorded simultaneously while interacting with the infants. The authors explicitly acknowledge this constraint, noting that any infant-to-adult (IA) influence should be spurious. Despite this acknowledgment, the manuscript consistently uses terminology implying bidirectional "interpersonal coupling" throughout the title, abstract, and main text.

Notably, what the study actually measured is infant neural responses correlating with pre-recorded adult neural activity - fundamentally different from genuine bidirectional neural synchrony during live social interaction. This distinction is not merely semantic; it has profound implications for the ecological validity and theoretical interpretation of findings. Claims about social neural mechanisms or interpersonal synchrony should be reframed to reflect the nature of the design (infant neural responses to pre-recorded social stimuli).

Related manuscript sections:
- Title
- Abstract: Lines 34-48
- Introduction: Lines 45-95
- Methods: Lines 220-235
- Results: Throughout
- Discussion: Lines 450-550
- Limitations section

Required revisions:
[To be filled in based on your response]

-------------------------------------------------------------------

MAJOR ISSUE 2.2

Inappropriate statistical analysis for the primary research question. The primary research question about gaze effects on learning was addressed using separate paired t-tests within each gaze condition (Lines 174-176: Full gaze t?? = 2.66; Partial gaze t?? = 1.53; No gaze t?? = 0.81) rather than an omnibus test to compare learning across conditions.

This approach raises several methodological concerns, as this analysis bypasses hierarchical testing principles - standard practice would first test whether learning differs across the three gaze conditions before examining individual conditions. Additionally, the reported degrees of freedom (~98-99) are inconsistent with paired t-tests using 47 participants, which should yield df ≈ 46. These dfs imply trials were treated as independent observations, affecting the degrees of freedom and significance levels.

Notably, the Methods section indicates that "LME models were used to assess differences in learning and visual attention across gaze conditions" (Lines 611-614), but this omnibus analysis is not reported in the Results section. The recommended approach would employ a linear mixed-effects model with infant random intercepts, gaze condition as a fixed effect, and covariates for age, sex, and country, followed by corrected post-hoc contrasts if the omnibus effect reaches significance.

Related manuscript sections:
- Results: Lines 174-176 (learning analysis)
- Methods: Lines 420-450, 611-614 (statistical analysis)

Required changes:
[To be filled in based on your response]

-------------------------------------------------------------------

MAJOR ISSUE 2.3

Circular mediation analysis. The mediation analysis suffers from a fundamental circularity that inflates its apparent effects: The proposed mediator (first adult-infant GPDC PLS component) was derived specifically through an optimization procedure to maximize covariance with learning outcomes (Lines 225-227). While the resulting model explains a substantial portion of variance (24.6%), the authors then use this same component as the mediator to demonstrate that neural coupling "mediates" the relationship between gaze and learning.

This creates target leakage: the mediator was constructed to predict the outcome variable, making it circular to then use it for mediation analysis. While the variance explained is impressive, the fundamental logical circularity undermines causal interpretation. The mediation should be acknowledged as having inherent limitations and interpreted as exploratory rather than confirmatory evidence.

Related manuscript sections:
- Results: Lines 225-227, 300-330 (mediation analysis)
- Methods: Lines 480-520 (PLS and mediation procedures)
- Discussion: Lines 500-530

Required changes:
[To be filled in based on your response]

-------------------------------------------------------------------

MAJOR ISSUE 2.4

Insufficient sample size for analytical complexity. With only 42 participants contributing EEG data, the study employs an ambitious array of complex multivariate procedures that may exceed the sample's capacity to support reliable inference. The original power calculation (N=45, Lines 407-408) addressed only t-test, but the actual analyses included GPDC connectivity across 81 possible channel pairs (9×9 channels), PLS regression with cross-validation, mediation analyses, and neural entrainment analysis across multiple frequency bands and channels.

This analytical complexity raises serious concerns about overfitting and result stability. The multiple testing burden across conditions, frequency bands, and channels compounds these concerns. While the 24.6% variance explained appears impressive, the sample size limitations may compromise the generalizability of these multivariate results. The study should include the exact number of predictors in PLS models and provide specific power analyses for the complex multivariate procedures actually employed.

Related manuscript sections:
- Methods: Lines 180-190, 407-408 (sample size justification)
- Methods: Lines 480-520 (PLS procedures)
- Results: Lines 250-330 (multivariate analyses)
- Limitations section

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

MAJOR ISSUE 2.5

Systematic incomplete statistical reporting: Throughout the entire Results section, the statistical reporting lacks the transparency required for proper evaluation. Specific examples include: Key learning effects report only "corrected p < .05" (Line 174) rather than exact p-values; effect sizes are mentioned once (Cohen's d = 0.27, Line 371) but absent elsewhere; GPDC analyses report significance without exact statistics (Lines 225-236); PLS variance explanation claims (24.6%, Line 227) lack accompanying statistical details; neural entrainment results list significant channels but omit exact p-values (Lines 256-257); and BHFDR correction is mentioned but test families are not consistently defined.

This incomplete reporting pattern prevents readers from evaluating the strength and reliability of the evidence, particularly given the multiple comparisons across conditions, frequency bands, and channels.

Related manuscript sections:
- Results: Lines 174-350 (all results sections)
- Need to create: Supplementary Table with complete statistical reporting

Required changes:
[To be filled in based on your response]

-------------------------------------------------------------------

MAJOR ISSUE 2.6

Insufficient GPDC model validation in the main text. The study's conclusions depend heavily on GPDC connectivity results, yet important model validation details are relegated to the Supplementary. Essential MVAR diagnostics including model order selection, stability analysis etc. should be summarized in the main manuscript. These diagnostics are crucial because poor model specification can produce spurious connectivity patterns that would undermine the primary conclusions.

Additionally, the choice of 9 channels and the 6-9 Hz frequency band for both adult and infant data (Lines 553-563) requires better justification and robustness testing across alternative specifications.

Related manuscript sections:
- Methods: Lines 380-420, 553-563 (GPDC methods)
- Supplementary Materials (model validation details)

Required additions to main Methods:
[To be filled in based on your response]

-------------------------------------------------------------------

SECTION-SPECIFIC COMMENTS

Abstract

The abstract employs strong causal language ("regulated by"), which is inaccurate given the pre-recorded design and mediation circularity. For example, Line 34 states that "interpersonal neural coupling is regulated by the adult speaker's level of eye contact," but the adult was not responding to the infant's eye contact in real-time. Such language should be replaced with more cautious phrasing, reflecting the true design of the study and the correlational relationships.

No need to mention the word count.

Related manuscript sections:
- Abstract: Lines 34-48

Required changes:
[To be filled in based on your response]

-------------------------------------------------------------------

Introduction

The introduction suffers from inconsistent terminology that creates conceptual confusion. Examples include switching between "ostensive cues" (Line 49), "ostensive signals" (Line 78), and "social ostensive cues" without clear differentiation. Similarly, the text alternates between "cross-brain connectivity," "interpersonal coupling," "interbrain connectivity," and "adult-infant coupling" (Lines 104-119) without establishing consistent definitions.

Related manuscript sections:
- Introduction: Lines 49-119

Required changes:
[To be filled in based on your response]

-------------------------------------------------------------------

EEG Preprocessing

The preprocessing section reports overall data retention (32.9%, Lines 522-523) but lacks details about retention per condition and whether epoch counts were balanced across gaze conditions before GPDC analysis. Imbalanced data could bias connectivity estimates.

Related manuscript sections:
- Methods: Lines 522-523 (EEG preprocessing)
- Need to add: Per-condition retention details

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

GPDC Analysis

The 9-channel selection appears pragmatic, rather than theoretically motivated. The shared 6-9 Hz frequency band for adult and infant data requires better justification, given known developmental differences in oscillatory frequencies. Robustness analyses across different frequency bands and channel subsets could be reported.

Related manuscript sections:
- Methods: Lines 553-563 (GPDC analysis)

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

Results - Learning Analysis

As detailed in Major Issue #2, the condition-wise paired t-tests should be replaced with proper omnibus testing. The degrees of freedom suggest statistical modeling that could affect significance levels.

Related manuscript sections:
- Results: Lines 174-176

Required changes:
[To be filled in based on your response]

-------------------------------------------------------------------

Results - Connectivity Analysis

While the study appropriately acknowledges that infant-to-adult connections should be spurious, the PLS analysis lacks important validation details. The 24.6% variance explanation should be reported with confidence intervals, and detailed statistics comparing real versus surrogate data performance should be provided. Include the number of GPDC features entered, the cross-validation scheme (at the infant level), and CIs for the reported 24.6%.

Related manuscript sections:
- Results: Lines 225-236 (connectivity analysis)

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

Results - Mediation Analysis

The circular derivation of the mediator (detailed in Major Issue #3) should be explicitly acknowledged. The results should be framed as exploratory evidence requiring independent replication rather than confirmatory evidence for the proposed mechanism.

Related manuscript sections:
- Results: Lines 300-330 (mediation analysis)

Required changes:
[To be filled in based on your response]

-------------------------------------------------------------------

Discussion

The Discussion section does not fully address the fundamental ecological validity limitations imposed by the pre-recorded design. The authors should explicitly discuss how the stimulus-response nature of their measurements constrains generalization to genuine interactive contexts and implications for social neural mechanism theories.

The limitation section, as well, should better reflect the study's weak spots.

Related manuscript sections:
- Discussion: Lines 450-550
- Limitations section

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

RECOMMENDATIONS AND ESSENTIAL CORRECTIONS

1. Statistical reanalysis: Implement LME omnibus analysis across gaze conditions with appropriate random effects structure and covariates, followed by FDR-corrected post-hoc contrasts

2. Acknowledge mediation limitations: Explicitly recognize the circularity in mediator derivation and interpret results as exploratory

3. Correct theoretical framing: Replace "interpersonal coupling" terminology throughout with accurate descriptions of the study design

4. Complete statistical reporting: Provide exact p-values, effect sizes, and confidence intervals for all key effects

5. GPDC validation: Present essential model diagnostics in the main manuscript

-------------------------------------------------------------------

OVERALL ASSESSMENT

This study demonstrates ambitious scope and technical competence in addressing an important question in developmental neuroscience. The experimental design shows careful stimulus engineering and sophisticated analytical approaches combining multiple neural measures with behavioral outcomes in challenging infant populations.

However, several methodological and interpretive issues raise concerns about the reliability of the findings. The statistical approach for the primary research question departs from standard hierarchical testing practices and may increase Type I error rates. The circular derivation of the mediation variable limits causal interpretation, while framing these neural correlations as 'interpersonal coupling' does not accurately reflect the experimental design constraints. These are not minor technical details but core methodological problems that affect the reliability and interpretation of the primary findings. The technical sophistication evident throughout suggests the authors possess the skills necessary to address these concerns through appropriate analyses and more conservative interpretations.

With proper omnibus statistical testing, acknowledgment of mediation analysis limitations, and accurate characterization of the experimental design, this work could make a meaningful contribution to understanding neural correlates of social learning in infancy.

Recommendation: Major revision focusing on statistical reanalysis and interpretive corrections.

===================================================================

REVIEWER 3

Reviewer 3 (Remarks to the Author):

In their paper, the authors report an ambitious study on whether the visibility of a speaker's direct gaze can help infants to learn artificial grammars using interbrain synchrony between the pre-recorded EEG of the speaker and the infant participants.

The authors investigated the same mechanism in two different samples, one in Singapore and one in the UK.

The authors found that synchrony between the adult and the infant, in particular the Delta and Theta bands from adult to infant (but not other combinations) and the frontal electrodes from the Adult Fz to the infant F4 electrode. Neither infant-infant, adult-adult or the (impossible) infant-adult connection revealed significant connections. Although Singaporean and British infants differed in their attention to the face, they showed no evidence for differences in their learning from the actor. Overall, the authors suggest that these results show that inter brain synchrony - from the teacher to the learner - is a better predictor of learning than infants' or adults' internal states.

These results have important theoretical implications and could be interesting for theoretical perspectives that go beyond the literature discussed by the authors. For example, the finding that synchrony between brains, rather than the internal states of the interlocutors, potentially fits into enactivist frameworks, such as Participatory Sensemaking by De Jaegher and Di Paolo, E. (2007) or models of dialogue, such as Garrod and Pickering's Interactive Alignment model (2013,2014). The study also has potential implications for accounts on multi-sensory integration and ecological accounts of socio-communicative abilities in infancy.

-------------------------------------------------------------------

COMMENT 3.1 - Methodological considerations & Interpretation

This interpretation is slightly dampened that in the experimental paradigm that uses a pre-recorded speaker, and therefore does not provide an option for the child to influence the speaker—potentially providing feedback that in turn influences the speaker, influencing the child, and thereby creating the mutually self-reinforcing connections that are described in these accounts. Nevertheless, the predictions that can be derived from these theoretical accounts are very complex and are difficult to test empirically. Therefore the results from this study are highly interesting.

Overall, the study's methodology represents an attempt to find a middle ground between controlled stimuli presentation found in many typical neuropsychological research, and highly interactive live hyper-scanning research. This brings with it its own unique combination of strengths and weaknesses inherited from both methodologies, but can potentially help to bridge discrepant findings between both disciplines.

Given that the conclusions drawn by the authors potentially align well with ecological and enactive accounts, I think it would be interesting to add a (very short) discussion that considers more interactional theories, rather than only focussing on sender-receiver models, such as Natural Pedagogy. I wonder whether these theoretical accounts might align better with the authors' own conclusions, or whether the authors think that these other theories fit better with their data.

For example, if one takes the Natural Pedagogy interpretation of gaze as signalling meaningful information, one might interpret that the infants' own state (e.g. being in social learning mode) should be the best predictor of their learning, rather than aligning on a neural level. However, the way that the study is designed, it provides no feedback channel for the child to influence the adult, therefore it is not sufficiently interactive for dialogue as described by Pickering and Garrod or Participatory Sensemaking by De Jaegher and Di Paolo.

Related manuscript sections:
- Discussion: Lines 450-550 (theoretical interpretation)
- Need to add: Discussion of alternative theoretical frameworks

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

COMMENT 3.2 - Gaze as a marker of structural information

One essential aspect that is not clear to me from the study's methodology is to what extent the gaze of the video still provides structural information in the visual domain that might help infants in segmenting the visual information. For example, there are numbers findings that have found that direct gaze or blinks do not happen at random points during speech and action:

- Direct gaze modulates speech processing and eye blinks and eyebrow movements are used to convey communicative intentions and (see studies by Hömke et al. 2017, 2025; Holler et al. 2014, Holler 2025)
- Mothers teaching children about novel object functions use gaze at event boundaries, taking into account children's knowledge with more frequent looks for younger, less knowledgeable children (e.g. Brand et al., 2007)
- Communicative signals at action boundaries can help segment actions (Kliesch, et al., 2021)
- Direct gaze and blinks can interrupt working memory (Wang & Apperly, 2016)

Taken together, gaze might represent an important source of structural information and from the description in the methods it is not entirely clear to me what information might still be available to infants that might help their learning of auditory structures. Whether infants use the presence or absence of communicative signals to identify learning contexts or whether they use the structural information to bootstrap the communicative function based on the structural information available within communicative signals is a major point of contention between approaches rooted in Natural Pedagogy and more ecologically rooted accounts of early infant-learning (Nomikou et al., 2016, Rączaszek-Leonardi et al., 2018; Kliesch et al., 2021; Kliesch 2025).

I might have missed this in the description of the methods, but from what I understand, the video corresponded to the actual video that corresponds to the Adult's EEG being recorded and matches the speech signal. The methods section suggested that the following manipulations were done to the sound:

> "any naturally-occurring differences in intensity were removed by digital equalisation, with loudness equalised to a playback volume of 61 dB. We further selected recordings that were closely matched for pitch, to ensure no significant differences in mean pitch across gaze conditions"

Gaze might still provide important structural information that could potentially influence infants' learning. The functions of gaze might be minimal and potentially unnoticed by the speaker or coders without a fine-grained coding. A potential control condition might consist of presenting mismatching visual and auditory information, but I think that might be a question for a follow-up study, rather than including it in the current paper. However it would still be good to discuss which information might be available in the eye region of the stimuli, and which parts of the signal can be ruled out.

When considering the mechanisms, it would have been nice to have more fine-grained gaze data rather than what was afforded by looking times alone. For example, it would have been interesting to see whether infants distributed their attention differently across the different gaze conditions and presentation orders (e.g. eyes obscured followed by visible, vs the other way around). Alas, the paper is very complex already and this is more of a suggestion for future work.

Related manuscript sections:
- Methods: Lines 200-220 (stimulus description)
- Discussion: Need to address structural vs ostensive function of gaze

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

COMMENT 3.3 - Stimuli presentation and order

I am a bit concerned that the visibility was manipulated in a within-subject-presentation with three different grammars. Infants would have to ignore previously learned information, which might impede learning of the new information. Were there any order effects in children's successful learning of the grammatical structures across multiple blocks? Maybe number of usable trials and attrition rates, and ideally a measure of successful learning for each block/running order could be added to the SI Table S6.

Related manuscript sections:
- Methods: Lines 160-180 (design and counterbalancing)
- Results: Need to add order effect analysis
- Supplementary Table S4 (attrition - needs expansion by block)
- Supplementary Table S6 (presentation sequences)

Required analyses:
[To be filled in based on your response]

-------------------------------------------------------------------

COMMENT 3.4 - Reporting LMM analyses

Small point: The LME analyses reported in the SI require some more information, e.g. see Diedrick et al., (2009) - Given the differences between packages and even versions of the same software, this should include also the software package, statistical environment and version numbers. Typically, these should also be referenced.

Related manuscript sections:
- Methods: Lines 420-450 (Statistical analysis - needs software details)
- Supplementary Materials: All LME tables

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

COMMENT 3.5 - Limitations of this review

As I have not used synchrony-related analyses in my own work, I cannot comment on their appropriateness for this particular sample. I recommend soliciting additional review by someone who has published in the field.

[Note: This is for editor consideration]

-------------------------------------------------------------------

MINOR COMMENTS

It might be helpful for readers (and reviewers) if it was possible to share the stimuli videos for the speaker.

Related manuscript sections:
- Supplementary Materials
- Data Availability statement

Required additions:
[To be filled in based on your response]

-------------------------------------------------------------------

CONCLUSION

Overall, I think the study provides a valuable contribution to the literature. There are some potential constraints in the methodology, but they largely represent compromises that have to be made given the complexity of the data. Additionally, having a sample of mixed cultural backgrounds provides an important contribution to the literature. I think there are some interesting theoretical implications of the study's results that deserve at least a brief mention, even if an exhaustive discussion would likely go beyond the format of the journal.

My main methodological point concerns potential structural contributions of gaze in segmenting speech information. Here, it would be very interesting to code and analyse any potential information available from the eyes (blinks, eyebrow movements) or clarify that these should be absent in the videos. There might still be possibilities for small micro-changes influencing infants' learning and it might be helpful for readers (and reviewers) if it was possible to share the stimuli videos for the speaker. However, at the very least, the paper should mention this point in the discussion section, and the paper would need to make it explicit which visual information might still be available in the infant.

Finally, more information should be provided on the attrition rates for each order/block and the statistical packages used.

However, once these points are addressed, I think the paper would make an interesting and worthwhile contribution to the literature.

===================================================================

EDITORIAL REQUIREMENTS

The editor has requested the following actions:

1. SEX AND GENDER REPORTING
   - Include sex/gender considerations in Reporting Summary
   - Indicate if findings apply to only one sex/gender in title/abstract
   - Report whether sex/gender was considered in study design
   - Provide disaggregated data in source files

   Related manuscript sections:
   [To be filled in]

2. DATA AND CODE AVAILABILITY
   - Include Data Availability section after Methods
   - Include Code Availability section after Data Availability
   - Ensure GitHub code link is working
   - Consider using figshare repository for data

   Related manuscript sections:
   [To be filled in]

3. FIGURES - Replace bar graphs with distribution plots
   - Show all data points for n<10
   - Use box-and-whisker or violin plots for larger samples
   - Include measures of centrality, dispersion, error bars

   Affected figures:
   [To be filled in]

4. ORCID
   - All corresponding authors must link ORCID IDs
   - Notify all co-authors to link ORCIDs prior to acceptance

   Action required:
   [To be filled in]

5. STATISTICAL REPORTING
   - Follow Nature Communications statistical guidance
   - Consider sensitivity analyses per Lakens (2022)

   Related manuscript sections:
   [To be filled in]

===================================================================

End of Document

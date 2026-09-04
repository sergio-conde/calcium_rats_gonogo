# Prelimbic and Infralimbic Calcium Imaging During Go/No-Go and DRO Behavior

**Neuromodulation & Behavior Group, Netherlands Institute for Neuroscience (NIN), Amsterdam**

MATLAB code for the analysis of single-cell calcium imaging signals recorded from the
prelimbic (PL) and infralimbic (IL) cortices of rats performing a Go/No-Go task, and a
subsequent differential-reinforcement-of-omission (DRO) variant of the same task. This
repository accompanies the manuscript *"Functional dissociation of prelimbic and
infralimbic cortices during adaptive action control in a Go/No-go task for rats"*,
currently in preparation for submission (see [Citation](#citation) below).

## Background

The prelimbic and infralimbic subregions of the rat medial prefrontal cortex are thought
to play dissociable — and sometimes opposing — roles in the control of goal-directed
action, including the initiation and inhibition of responses. Disruption of this
PL/IL balance has been proposed as a candidate circuit mechanism in disorders
characterized by impaired response inhibition, such as obsessive-compulsive disorder
(OCD). This project uses single-photon miniscope calcium imaging to track the activity
of PL and IL neuronal populations across two behavioral contexts in the same animals,
in order to characterize how each region encodes sensory information and represents
actions during action control and action inhibition.

## Experimental design

- **Subjects:** 10 rats implanted with a GRIN lens and head-mounted miniscope for
  chronic single-cell calcium imaging.
  - **PL cohort:** n = 5
  - **IL cohort:** n = 5
- **Stage 1 — Go/No-Go task:** Animals performed a classic Go/No-Go task, and calcium
  activity in PL or IL was recorded during task execution.
- **Stage 2 — DRO task:** The same animals, with the same imaging field of view, were
  then recorded while performing a differential-reinforcement-of-omission (DRO)
  variant, in which the previously reinforced Go response now had to be withheld
  (i.e., the contingency for action control was reversed relative to Stage 1).

This within-animal, two-stage design allows direct comparison of how the same PL and IL
neurons represent task variables under opposite action-control demands (responding vs.
withholding).

## Analysis overview

For both task stages, activity in PL and IL was characterized at two levels:

1. **Single-cell responsivity** — identifying and quantifying individual neurons'
   responses to task-relevant sensory cues and to the animal's own actions
   (e.g., Go responses, omissions/withholding).
2. **Population-level activity** — analyzing the joint activity of simultaneously
   recorded cells around the same task events to assess whether PL and IL populations
   carry differentiated representations of sensory and action-related information,
   beyond what is captured by single units alone.

Together, these readouts are used to infer how PL and IL differentially contribute to
action control, and how that contribution changes when the task demands response
inhibition (DRO) rather than response execution (Go/No-Go).

## Repository structure

```
/functions   # Shared core utilities: project configuration, trial preprocessing,
             # dPCA wrapper, decoding, and responsive-cell detection
/behavior    # Trial building from raw traces + MedPC logs, and behavioral
             # performance analyses (Go/No-Go performance, latencies, DRO head entries)
/single_cell # Single-cell responsivity to task variables (linear mixed-effects
             # models vs. surrogate/shuffled data)
/population  # Population-level trajectory analyses (dPCA-based dimensionality
             # reduction, Go/No-Go decoding, shuffled controls)
```

Key files:

| File | Role |
|---|---|
| [functions/gonogo_mainconfig.m](functions/gonogo_mainconfig.m) | Central config: project paths, per-rat behavioral parameters, analysis/graphics settings, assembly-detection settings. Loaded at the top of most scripts. |
| [behavior/FV_BuildTrials.m](behavior/FV_BuildTrials.m) | Segments a continuous CNMF-E calcium trace (`result.C_raw`) into per-trial structures aligned to MedPC behavioral events; deconvolves traces (OASIS, AR(2)). |
| [functions/DataPreProcess_correct.m](functions/DataPreProcess_correct.m) | Z-scores, baseline-corrects, and time-aligns per-trial traces around the nose-poke entry, producing the trial × condition tensors used for dPCA. |
| [functions/dpca_gonogo_corr.m](functions/dpca_gonogo_corr.m) | Wraps the [dPCA toolbox](https://github.com/machenslab/dPCA) (Kobak et al.) to extract task- and time-related population components. |
| [functions/DecodeTrajs_correct.m](functions/DecodeTrajs_correct.m) / [functions/GoNogoPerf_correct.m](functions/GoNogoPerf_correct.m) | LDA decoding of Go vs. No-Go identity from population trajectories, and decoder performance summaries (real vs. shuffled). |
| [functions/FindCells.m](functions/FindCells.m) | Flags a cell as "responsive" by comparing an observed statistic to its shuffled/surrogate distribution (97.5th-percentile threshold). |
| [single_cell/omission_lem.m](single_cell/omission_lem.m), [single_cell/lem_resposive_cells.m](single_cell/lem_resposive_cells.m) | Fit linear mixed-effects models per cell against task variables (with surrogate shuffles) and identify/compare responsive cells across regular and omission (DRO) sessions. |
| [population/create_trajectory_files.m](population/create_trajectory_files.m), [population/shuffle_trajectories.m](population/shuffle_trajectories.m) | Build (real and shuffled) dPCA trajectories per animal from correct trials. |
| [population/create_traj_feats_files.m](population/create_traj_feats_files.m), [population/analysis_trajectories.m](population/analysis_trajectories.m), [population/rew_aligned_trajectories.m](population/rew_aligned_trajectories.m) | Extract trajectory features (explained variance, length, distance) and compare them across areas (PL/IL) and task stages (regular/DRO). |

**Note:** several helper functions called throughout these scripts (e.g., `pick_files`/`get_entry`,
`proj_organigram`, `ProcessMedPC`, `wfig`) are not yet included in this repository — they belong to
shared lab utilities. `TBD`: confirm whether these should be added here (e.g., under `functions/`)
or referenced as a separate dependency.

## Requirements

- MATLAB R2020a or later
- MATLAB Statistics and Machine Learning Toolbox (used for LDA decoding via `classify`)
- [dPCA toolbox](https://github.com/machenslab/dPCA) (Kobak et al.) for demixed principal component analysis
- OASIS calcium deconvolution (`deconvolveCa`, AR(2) model) — as used in [CaImAn](https://github.com/flatironinstitute/CaImAn-MATLAB)/CNMF-E pipelines
- Upstream source extraction via [CNMF-E](https://github.com/zhoupc/CNMF_E) (not part of this repository; scripts consume its `C_raw` output)
- `TBD`: any additional toolboxes (e.g., Statistics/LME-specific) used in `single_cell/omission_lem.m`

## Usage

> TBD — document the end-to-end pipeline order once data paths are finalized. Based on the code,
> the intended flow is:
> 1. Extract calcium traces with CNMF-E (external, upstream of this repo).
> 2. Build per-trial structures aligned to behavior: [behavior/FV_BuildTrials.m](behavior/FV_BuildTrials.m).
> 3. Run behavioral performance analyses: scripts in [behavior/](behavior).
> 4. Run single-cell responsivity analyses: scripts in [single_cell/](single_cell).
> 5. Build population trajectories and run decoding/feature analyses: scripts in [population/](population).

## Citation

If you use this code, please cite:

> F. Veen<sup>1,2</sup>, S. Conde-Ocazionez<sup>1,2</sup>, A. Parthasarathy<sup>1,2</sup>,
> B.J.G. van den Boom<sup>1,2,3</sup>, W.W. Lei<sup>1</sup>, F. Oostdijk<sup>1</sup>,
> G. Leschiutta<sup>1</sup>, N. Jamann<sup>1</sup>, M. Kole<sup>1</sup>,
> I. Willuhn<sup>1,2</sup>. **Functional dissociation of prelimbic and infralimbic
> cortices during adaptive action control in a Go/No-go task for rats.** *(manuscript
> in preparation; journal/preprint link to be added upon submission)*

**Author affiliations**

1. Netherlands Institute for Neuroscience, Royal Netherlands Academy of Arts and
   Sciences, Amsterdam, The Netherlands
2. Amsterdam UMC, location University of Amsterdam, Department of Psychiatry,
   Amsterdam, The Netherlands
3. B.J.G. van den Boom, current address: Bernardo Sabatini lab, Harvard University
4. W.W. Lei, current address: Paul Lucassen lab, UvA Science Park
5. N. Jamann, current address: Institute for Physiology I, Medical Faculty, University
   of Freiburg, Freiburg, Germany

## Contact

Analysis and repository maintained by S. Conde-Ocazionez (Neuromodulation & Behavior
Group, NIN). `TBD` — public contact email.

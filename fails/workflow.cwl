#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

inputs:
  - id: bam_path
    type: File

outputs:
  - id: bamtoreadgroup_output
    type:
      type: array
      items: File
    outputSource: bamtoreadgroup/output_readgroup
  - id: align_output
    type:
      type: array
      items: File
    outputSource: align/output_bam
  # - id: merged_bam
  #   type: File
  #   outputSource: merge/MERGED_OUTPUT

steps:
  - id: bamtoreadgroup
    run: unix_bamreadgroup_cmd.cwl
    in:
      - id: bam_path
        source: bam_path
    out:
      - id: output_readgroup

  - id: bamtofastq
    run: unix_bamtofastq_cmd.cwl
    in:
      - id: bam_path
        source: bam_path
    out:
      - id: output_fastq1
      - id: output_fastq2

  - id: align
    run: ../unix_align_cmd.cwl
    scatter: [align/fastq1_path, align/fastq2_path, align/readgroup_path]
    scatterMethod: "dotproduct"
    in:
      - id: fastq1_path
        source: bamtofastq/output_fastq1
      - id: fastq2_path
        source: bamtofastq/output_fastq2
      - id: readgroup_path
        source: bamtoreadgroup/output_readgroup
    out:
      - id: output_bam

  # - id: merge
  #   run: unix_merge_cmd.cwl
  #   in:
  #     - id: INPUT
  #       source: align/output_bam
  #     - id: OUTPUT
  #       source: bam_path
  #       valueFrom: $(self.basename)
  #   out:
  #     - id: MERGED_OUTPUT

task fitNull {
	File plink_file_bam
	File plink_file_bim
	File plink_file_fam
	String plink_file = sub(plink_file_bam, ".bam", "")

	File pheno_file
	String outcome
	String outcome_type
	String? covariate_string
	String id_col
	String label
	Int? threads




	File script



	Int memory
	Int disk

	command {
		R --vanilla --args ${plink_file} ${pheno_file} ${outcome} ${outcome_type} ${default="" covariate_string} ${id_col} ${label} ${default="1" threads} < ${script}
	}

	runtime {
		docker: "tmajarian/saige:0.2"
		disks: "local-disk ${disk} SSD"
		memory: "${memory}G"
	}

	output {
		File null_model = "${label}.rda"
		File variance_ratio = "${label}.varianceRatio.txt"
	}
}

workflow runSaige {
	File this_plink_file_bam
	File this_plink_file_bim
	File this_plink_file_fam
	File this_pheno_file
	String this_outcome
	String this_outcome_type
	String? this_covariate_string
	String this_id_col
	String this_label
	Int? this_threads


	File this_script




	Int fitNull_memory
	Int this_disk

	call fitNull {
		input: plink_file_bam = this_plink_file_bam, plink_file_bim = this_plink_file_bim, plink_file_fam = this_plink_file_fam, pheno_file = this_pheno_file, outcome = this_outcome, outcome_type = this_outcome_type, covariate_string = this_covariate_string, id_col = this_id_col, label = this_label, threads = this_threads, memory = fitNull_memory, disk = this_disk, script = this_script
	}
}
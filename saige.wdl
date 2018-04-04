task fitNull {
	File plink_file_bed
	File plink_file_bim
	File plink_file_fam
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
		pwd
		R --vanilla --args ${plink_file_bed} ${plink_file_bim} ${plink_file_fam} ${pheno_file} ${outcome} ${outcome_type} ${default="" covariate_string} ${id_col} ${label} ${default="1" threads} < ${script}
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

task assocTest {
	File vcf_file 
	File vcf_index 
	File sample_file 
	File null_file 
	File variance_file 
	String label 
	Float? min_maf 
	Int? min_mac 
	String? out_case_control_str
	String chromosome

	Int memory
	Int disk


	File script

	command {
		R --vanilla --args ${vcf_file} ${vcf_index} ${sample_file} ${null_file} ${variance_file} ${label} ${default="0.00001" min_maf} ${default="3" min_mac} ${default="FALSE" out_case_control_str} ${chromosome} < ${script}
	}

	runtime {
		docker: "tmajarian/saige:0.2"
		disks: "local-disk ${disk} SSD"
		memory: "${memory}G"
	}

	output {
		File results = "${label}.txt"
	}
}

workflow runSaige {
	File this_plink_file_bed
	File this_plink_file_bim
	File this_plink_file_fam
	File this_pheno_file
	String this_outcome
	String this_outcome_type
	String? this_covariate_string
	String this_id_col
	String this_label
	Int? this_threads

	File this_vcf_file
	File this_vcf_index 
	File this_sample_file 
	Float? this_min_maf 
	Int? this_min_mac 
	String? this_out_case_control_str
	String this_chromosome


	File this_script1
	File this_script2




	Int fitNull_memory
	Int this_disk
	Int assocTest_memory

	call fitNull {
		input: plink_file_bed = this_plink_file_bed, plink_file_bim = this_plink_file_bim, plink_file_fam = this_plink_file_fam, pheno_file = this_pheno_file, outcome = this_outcome, outcome_type = this_outcome_type, covariate_string = this_covariate_string, id_col = this_id_col, label = this_label, threads = this_threads, memory = fitNull_memory, disk = this_disk, script = this_script1
	}

	call assocTest {
		input: vcf_file = this_vcf_file, vcf_index = this_vcf_index, sample_file = this_sample_file, null_file = fitNull.null_model, variance_file = fitNull.variance_ratio, label = this_label, min_maf = this_min_maf, min_mac = this_min_mac, out_case_control_str = this_out_case_control_str, chromosome = this_chromosome, memory = assocTest_memory, disk = this_disk, script = this_script2
	}
}
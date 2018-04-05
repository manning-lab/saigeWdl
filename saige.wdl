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
	Int? num_markers
	String? inv_normalize




	File script



	Int memory
	Int disk

	command {
		echo "Input files" > fitNull_out.log
		echo "Bed file : ${plink_file_bed}" >> fitNull_out.log
		echo "Bim file : ${plink_file_bim}" >> fitNull_out.log
		echo "Fam file : ${plink_file_fam}" >> fitNull_out.log
		echo "Phenotypes : ${pheno_file}" >> fitNull_out.log
		echo "Outcome : ${outcome}" >> fitNull_out.log
		echo "Outcome type : ${outcome_type}" >> fitNull_out.log
		echo "Covariates : ${default='' covariate_string}" >> fitNull_out.log
		echo "ID column : ${id_col}" >> fitNull_out.log
		echo "ID column : ${id_col}" >> fitNull_out.log
		echo "Output prefix : ${label}" >> fitNull_out.log
		echo "Number of threads : ${default='1' threads}" >> fitNull_out.log
		echo "Number of markers for variance ratio : ${default='30' num_markers}" >> fitNull_out.log
		echo "Whether to inverse normalize outcome : ${default='FALSE' inv_normalize}" >> fitNull_out.log
		echo "Memory : ${memory}" >> fitNull_out.log
		echo "Disk : ${disk}" >> fitNull_out.log
		echo "" >> fitNull_out.log
		dstat -c -d -m --nocolor 10 1>>fitNull_out.log &
		R --vanilla --args ${plink_file_bed} ${plink_file_bim} ${plink_file_fam} ${pheno_file} ${outcome} ${outcome_type} ${default="" covariate_string} ${id_col} ${label} ${default="1" threads} ${default="30" num_markers} ${default="FALSE" inv_normalize} < ${script}
		echo "Output files" >> fitNull_out.log
		echo "Null model : ${label}.rda" >> fitNull_out.log
		echo "Variance ratio : ${label}.varianceRatio.txt" >> fitNull_out.log
	}

	runtime {
		docker: "tmajarian/saige:0.2"
		disks: "local-disk ${disk} SSD"
		memory: "${memory}G"
	}

	output {
		File null_model = "${label}.rda"
		File variance_ratio = "${label}.varianceRatio.txt"
		File markers_used = "${label}_${default'30' num_markers}markers.SAIGE.results.txt"
		File log_file = "fitNull_out.log"
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
		echo "Input files" > assocTest_out.log
		echo "Vcf file : ${vcf_file}" >> assocTest_out.log
		echo "Vcf index file : ${vcf_index}" >> assocTest_out.log
		echo "Sample file : ${sample_file}" >> assocTest_out.log
		echo "Null file : ${null_file}" >> assocTest_out.log
		echo "Variance file : ${variance_file}" >> assocTest_out.log
		echo "Output prefix : ${label}" >> assocTest_out.log
		echo "Minimum maf : ${default='0' min_maf}" >> assocTest_out.log
		echo "Minimum mac : ${default='3' min_mac}" >> assocTest_out.log
		echo "Output case and control stats? : ${default='FALSE' out_case_control_str}" >> assocTest_out.log
		echo "Chromosome : ${chromosome}" >> assocTest_out.log
		echo "Memory : ${memory}" >> assocTest_out.log
		echo "Disk : ${disk}" >> assocTest_out.log
		echo "" >> assocTest_out.log
		dstat -c -d -m --nocolor 10 1>>assocTest_out.log &
		R --vanilla --args ${vcf_file} ${vcf_index} ${sample_file} ${null_file} ${variance_file} ${label} ${default="0" min_maf} ${default="3" min_mac} ${default="FALSE" out_case_control_str} ${chromosome} < ${script}
		echo "Output files" >> assocTest_out.log
		echo "Results : ${label}.txt" >> assocTest_out.log
	}

	runtime {
		docker: "tmajarian/saige:0.2"
		disks: "local-disk ${disk} SSD"
		memory: "${memory}G"
	}

	output {
		File results = "${label}.txt"
		File log_file = "assocTest_out.log"
	}
}

task summary {
	Float? pvalue_threshold
	String label
	File assoc_files

	Int memory
	Int disk


	File script

	command {
		echo "Input files" > summary_out.log
		echo "Pvalue threshold : ${default='0.1' pvalue_threshold}" >> assocTest_out.log
		echo "Output prefix : ${label}" >> summary_out.log
		echo "Association files : ${assoc_files}" >> summary_out.log
		echo "Memory : ${memory}" >> summary_out.log
		echo "Disk : ${disk}" >> summary_out.log
		echo "" >> summary_out.log
		dstat -c -d -m --nocolor 10 1>>summary_out.log &
		R --vanilla --args ${pvalue_threshold} ${label} ${assoc_files} < ${script}
		echo "Output files" >> summary_out.log
		echo "Results : ${label}.txt" >> summary_out.log
	}

	runtime {
		docker: "tmajarian/saige:0.2"
		disks: "local-disk ${disk} SSD"
		memory: "${memory}G"
	}

	output {
		File all_associations = "${label}.assoc.csv"
		File top_associations = "${label}.topassoc.csv"
		File plots = "${label}.association.plots.png"
		File log_file = "summary_out.log"
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
	Int? this_num_markers
	String? this_inv_normalize

	File this_vcf_file
	File this_vcf_index 
	File this_sample_file 
	Float? this_min_maf 
	Int? this_min_mac 
	String? this_out_case_control_str
	String this_chromosome

	Float? this_pvalue_threshold
	


	File this_script1
	File this_script2
	File this_script3




	Int fitNull_memory
	Int this_disk
	Int assocTest_memory
	Int summary_memory

	call fitNull {
		input: plink_file_bed = this_plink_file_bed, plink_file_bim = this_plink_file_bim, plink_file_fam = this_plink_file_fam, pheno_file = this_pheno_file, outcome = this_outcome, outcome_type = this_outcome_type, covariate_string = this_covariate_string, id_col = this_id_col, label = this_label, threads = this_threads, num_markers = this_num_markers, inv_normalize = this_inv_normalize, memory = fitNull_memory, disk = this_disk, script = this_script1
	}

	call assocTest {
		input: vcf_file = this_vcf_file, vcf_index = this_vcf_index, sample_file = this_sample_file, null_file = fitNull.null_model, variance_file = fitNull.variance_ratio, label = this_label, min_maf = this_min_maf, min_mac = this_min_mac, out_case_control_str = this_out_case_control_str, chromosome = this_chromosome, memory = assocTest_memory, disk = this_disk, script = this_script2
	}

	call summary {
		input: pvalue_threshold = this_pvalue_threshold, label = this_label, assoc_files = assocTest.results, memory = summary_memory, disk = this_disk, script = this_script3
	}
}
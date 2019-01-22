"
Class with homeless methods... To be refactored into an API.
 
-------------
HandMorph doubleClickTime: 500.

Utility cloneReposAndGenerateCommitMetadata: '_projects.csv'.

Utility generateSelectedCommitFiles: '*_commits.csv'.

Utility generateLogicalCouplingCandidatePairsAndTransactions: '_commits_UIDs.csv'.

Utility generateClientImplementationPairsFiles: 'ClientImpPairs'.

Utility applyRenamingsToTransactions: '_projects.csv'.

Utility removeUnrelatedClassesFromTransactions: 'alexo-chess'.

""R generates the coupling pairs ""
Utility generateLogicalCouplingPairsWithR: 'c:/chgevo'.

""Utility generateMSEFilesForEachUID: '_commits_UIDs.csv'.""

Utility calculateCouplingIntersections.
""---------------- Single project pipeline ""
gitName := 'rhino'.
olderTag :='Rhino1_7_8_Release'.
newerTag := 'Rhino1_7_9_Release'.
loc := Utility cloneRepo: 'https://github.com/mozilla/rhino'.

gitName := 'cassandra'.
""olderTag :='cassandra-2.0.0-beta1'.""
olderTag :='cassandra-3.11.2'.
newerTag := 'cassandra-3.11.3'.
loc := Utility cloneRepo: 'https://github.com/apache/cassandra'.
startOIDString := '3dcde0821a40eb2bc633082916d8f3ff861efdb5'.
endOIDString := '50560aaf0f2d395271ade59ba9b900a84cae70f1'.
commitMetadata := Utility filterCommitsOnRepoLeftBranchOnly: loc from: startOIDString to: endOIDString.

""Utility filterCommitsOnRepo: loc withRange: ''.""

selectedCommits := Utility generateSelectedCommits: commitMetadata.
pairsAndTransactions := Utility generatePairsAndTransactions: selectedCommits.

""oid := Utility getOIDFromTag: newerTag on: loc.""
mseFileRef := Utility generateMSEFileFor: startOIDString reponame: loc basename.
""mseFileRef := Utility generateMSEFileFor: 'HEAD' reponame: loc basename.""

cimpFile := Utility generateClientImplementationPairs: mseFileRef.

""Renamings should do a check-out of the Revision to use renamings from that point? Otherwise, integrate the revision info into the git-log command.""
renamedTransactionsFile := Utility applyRenamingsToTransactions: pairsAndTransactions second usingRevision: startOIDString project: gitName.

removedTr := Utility removeUnrelatedClassesFromTransactions: gitName fromRevision: startOIDString.
Utility generateLogicalCouplingPairsWithRSingleFile: removedTr.
""Utility generateLogicalCouplingPairsWithRSingleFile: pairsAndTransactions second.""

Utility calculateCouplingIntersectionsFor: gitName at: startOIDString.

""-----------------------------------""

repoHandle := LGitRepository on: loc.
repoHandle open.
gitRef := LGitReference of: repoHandle.
result := gitRef reference_lookup: nil repo: repoHandle name: 'refs/tags/',newerTag.
result = 0 ifTrue:[^gitRef targetId].
gitRef targetId .

""mseDirRoot := FileLocator C / 'tmp' / 'data_mining'.
mseDirs := mseDirRoot directories.
dir := mseDirs first.
projectName := dir basename asString allButLast: '_master' size.
mseFiles := dir allChildrenMatching: '*.mse'.
mseFile := mseFiles first.
results := InterfaceMiner mineClientImplementationPairs: mseFile readStream withPrefix: ''.
newFileName := projectName , '_', mseFile basenameWithoutExtension , '_' , 'ClientImpPairs' , '.csv'.

mseFile := (FileStream readOnlyFileNamed: 'C:\tmp\data_mining\alexo-chess_master\HEAD.mse').
InterfaceMiner mineClientImplementationPairs: mseFile withPrefix: ''.""



""Only needed once...""
Utility extractIndividualProjectLogicalCouplingData: 'G:\My Drive\Congé sabbatique 2018-2019\Activités INRIA\Change Evolution Interface Clients\AC2017 JSS\logicalcoupling.csv'.


OSEnvironment current setEnv: 'BLAH' value: 'x'.
OSEnvironment current getEnv: 'BLAH'.
LibC uniqueInstance system: 'env | more'.

"
Class {
	#name : #GMUtility,
	#superclass : #Object,
	#classInstVars : [
		'cloneRoot'
	],
	#category : #GitMiner
}

{ #category : #'file service' }
GMUtility class >> applyRenamingsToTransactions: projectsFile [
	"comment stating purpose of message"

	| working projectRecords projectName tempRepoRoot transactionsExtension newTransactionExtension clientImplementationPairsExtension file csvInputStream clientImplementationPairsRecords classesToCheckRenamings perlErrors renameHistoryCSV clientsTemp implementationsTemp perlProgram |
	tempRepoRoot := 'c:/tmp/tempClonesPharo/'.
	transactionsExtension := '_commits_UIDs_transactions.csv'.
	newTransactionExtension := '_commits_UIDs_transactions_renamed.csv'.
	clientImplementationPairsExtension := '_HEAD_ClientImpPairs.csv'.
	renameHistoryCSV := '/tmp/_renamings_temp.csv'.
	perlProgram := '/tmp/hist2renamecsv.perl'.
	perlErrors := '/tmp/_perl_errors'.
	working := FileSystem disk workingDirectory.
	csvInputStream := (working / projectsFile) readStream.
	projectRecords := self loadProjectsList: csvInputStream.	"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"	"GitHub url"
	projectRecords
		do: [ :projectRecord | 
			| githubUrl cTransactionsOriginal renamedCTransactions cTransactions |
			githubUrl := projectRecord last.
			githubUrl = 'NA'
				ifFalse: [ projectName := projectRecord second.
					file := (projectName , transactionsExtension) asFileReference.
					cTransactionsOriginal := self loadCommitTransactions: file.
					cTransactions := cTransactionsOriginal copy.
					"Load clients and implementations"
					"Read in CSV of structural coupling (client-implementation)"
					file := (projectName , clientImplementationPairsExtension) asFileReference.
					clientImplementationPairsRecords := self loadClientImplementationPairs: file.
					clientImplementationPairsRecords isNotEmpty 
						ifTrue: [ "Client file name is second column"
							clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
							"Implementation file name is fifth column"
							implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
							classesToCheckRenamings := clientsTemp union: implementationsTemp.
							classesToCheckRenamings
								do: [ :class | 
									| projectRepoDir command result renamings dirs csvPath |
									"Generate git history"
									projectRepoDir := tempRepoRoot , projectName.
									command := 'cd ' , projectRepoDir , ' && git log --follow -p -- "' , class , '" | perl -0777 -n ' , perlProgram , ' > ' , renameHistoryCSV , ' 2>' , perlErrors.
									result := LibC uniqueInstance system: command.
									result = 0
										ifFalse: [ 0 halt ]
										ifTrue: [ "Load CSV of renamed names"
													dirs := renameHistoryCSV splitOn: $/.
													csvPath := FileLocator C.
													dirs
														do: [ :dir | 
															dir = ''
																ifFalse: [ csvPath := csvPath / dir ] ].
													renamings := self loadRenamings: csvPath.

													"For each transaction, replace any instance of a 'from' renaming with the current name"
													renamedCTransactions := OrderedCollection new.
													cTransactions
														do: [ :cTransaction | 
															| copyCTransaction i |
															"make copy of transaction record and add it to the new set"
															copyCTransaction := cTransaction copy.
															renamedCTransactions add: copyCTransaction .
															i := 0.
															cTransaction committedFileNames
																do: [ :classToMaybeRename | 
																	i := i + 1.
																	renamings
																				do: [ :renamingRecord | 
																					| fromRename percent |
																					percent := renamingRecord second.
																					fromRename := renamingRecord fourth.
																					copyCTransaction renameAll: fromRename to: class ] ]  .
													"Update for next class to check for renamings"
													cTransactions := renamedCTransactions ] ] ] ]

					"Check for case of no clients/implementations (no interfaces), just use original records (nothing to rename)"
					ifFalse: [ renamedCTransactions  := cTransactionsOriginal  copy ].

					self writeCommitTransactions: renamedCTransactions to: projectName , newTransactionExtension ] ]
		displayingProgress: [ :projectRecord | 'Applying renamings to project: ' , projectRecord second ]
]

{ #category : #'file service' }
GMUtility class >> applyRenamingsToTransactions: transactionsFile usingRevision: oid project: projectName [
	"For the commit transactions in a project, try to rename classes using the latest name.
	This works by taking the names at a specified revision (from MSE).
	Check out the git repo to that revision, then do a git history to get renamings."

	| cTransactionsOriginal renamedCTransactions cTransactions tempRepoRoot newTransactionExtension clientImplementationPairsExtension file clientImplementationPairsRecords classesToCheckRenamings perlErrors renameHistoryCSV clientsTemp implementationsTemp perlSubcommand |
	tempRepoRoot := 'c:/tmp/tempClonesPharo/'.
	newTransactionExtension := '_commits_tags_OIDs_TR_renamed.csv'.
	clientImplementationPairsExtension := '_' , oid, '_ClientImpPairs.csv'.
	renameHistoryCSV := '/tmp/_renamings_temp.csv'.
	perlErrors := '/tmp/_perl_errors'.
	file := transactionsFile asFileReference.
	cTransactionsOriginal := self loadCommitTransactions: file.
	cTransactions := cTransactionsOriginal copy.
	"Properly escape the double-quotes on this"
	perlSubcommand := 'perl -0777 -ne "while (/commit (.+)\n(?:.*\n)+?similarity index (\d+)+%\n(rename|copy) from (.+)\n\3 to (.+)\n/g) { printf (\"$1,$2,$3,$4,$5\n\")}"'.
	"Load clients and implementations"
	"Read in CSV of structural coupling (client-implementation)"
	file := (projectName , clientImplementationPairsExtension) asFileReference.
	clientImplementationPairsRecords := self loadClientImplementationPairs: file.
	clientImplementationPairsRecords isNotEmpty
		ifTrue: [ "Client file name is second column"
			"Check for case of no clients/implementations (no interfaces), just use original records (nothing to rename)"
			clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
			"Implementation file name is fifth column"
			implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
			classesToCheckRenamings := clientsTemp union: implementationsTemp.
			classesToCheckRenamings
				do: [ :class | 
					| projectRepoDir command result renamings dirs csvPath |
					"Generate git history"
					projectRepoDir := tempRepoRoot , projectName.
					command := 'cd ' , projectRepoDir , ' && git log --follow -p "' , oid , '^@" -- "' , class , '" | ' , perlSubcommand , ' > ' , renameHistoryCSV , ' 2>' , perlErrors.
					result := LibC uniqueInstance system: command.
					result = 0
						ifFalse: [ self error: 'LibC system command: '' , command , '' failed.' ]
						ifTrue: [ "Load CSV of renamed names"
							dirs := renameHistoryCSV splitOn: $/.
							csvPath := FileLocator C.
							dirs
								do: [ :dir | 
									dir = ''
										ifFalse: [ csvPath := csvPath / dir ] ].
							renamings := self loadRenamings: csvPath.

							"For each transaction, replace any instance of a 'from' renaming with the current name"
							renamedCTransactions := OrderedCollection new.
							cTransactions
								do: [ :cTransaction | 
									| copyCTransaction i |
									"make copy of transaction record and add it to the new set"
									copyCTransaction := cTransaction copy.
									renamedCTransactions add: copyCTransaction.
									i := 0.
									cTransaction committedFileNames
										do: [ :classToMaybeRename | 
											i := i + 1.
											renamings
												do: [ :renamingRecord | 
													| fromRename percent |
													percent := renamingRecord second.
													fromRename := renamingRecord fourth.
													copyCTransaction renameAll: fromRename to: class ] ].
									"Update for next class to check for renamings"
									cTransactions := renamedCTransactions ] ] ] displayingProgress: 'Renaming classes.' ]
		ifFalse: [ renamedCTransactions := cTransactionsOriginal copy ].
	^self writeCommitTransactions: renamedCTransactions to: projectName , newTransactionExtension
]

{ #category : #'file service' }
GMUtility class >> applyRenamingsToTransactionsFiles: projectsFile [
	"comment stating purpose of message"

	| working projectRecords projectName tempRepoRoot transactionsExtension newTransactionExtension clientImplementationPairsExtension file csvInputStream clientImplementationPairsRecords classesToCheckRenamings perlErrors renameHistoryCSV clientsTemp implementationsTemp perlProgram |
	tempRepoRoot := 'c:/tmp/tempClonesPharo/'.
	transactionsExtension := '_commits_UIDs_transactions.csv'.
	newTransactionExtension := '_commits_UIDs_transactions_renamed.csv'.
	clientImplementationPairsExtension := '_HEAD_ClientImpPairs.csv'.
	renameHistoryCSV := '/tmp/_renamings_temp.csv'.
	perlProgram := '/tmp/hist2renamecsv.perl'.
	perlErrors := '/tmp/_perl_errors'.
	working := FileSystem disk workingDirectory.
	csvInputStream := (working / projectsFile) readStream.
	projectRecords := self loadProjectsList: csvInputStream.	"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"	"GitHub url"
	projectRecords
		do: [ :projectRecord | 
			| githubUrl cTransactionsOriginal renamedCTransactions cTransactions |
			githubUrl := projectRecord last.
			githubUrl = 'NA'
				ifFalse: [ projectName := projectRecord second.
					file := (projectName , transactionsExtension) asFileReference.
					cTransactionsOriginal := self loadCommitTransactions: file.
					cTransactions := cTransactionsOriginal copy.
					"Load clients and implementations"
					"Read in CSV of structural coupling (client-implementation)"
					file := (projectName , clientImplementationPairsExtension) asFileReference.
					clientImplementationPairsRecords := self loadClientImplementationPairs: file.
					clientImplementationPairsRecords isNotEmpty 
						ifTrue: [ "Client file name is second column"
							clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
							"Implementation file name is fifth column"
							implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
							classesToCheckRenamings := clientsTemp union: implementationsTemp.
							classesToCheckRenamings
								do: [ :class | 
									| projectRepoDir command result renamings dirs csvPath |
									"Generate git history"
									projectRepoDir := tempRepoRoot , projectName.
									command := 'cd ' , projectRepoDir , ' && git log --follow -p -- "' , class , '" | perl -0777 -n ' , perlProgram , ' > ' , renameHistoryCSV , ' 2>' , perlErrors.
									result := LibC uniqueInstance system: command.
									result = 0
										ifFalse: [ 0 halt ]
										ifTrue: [ "Load CSV of renamed names"
													dirs := renameHistoryCSV splitOn: $/.
													csvPath := FileLocator C.
													dirs
														do: [ :dir | 
															dir = ''
																ifFalse: [ csvPath := csvPath / dir ] ].
													renamings := self loadRenamings: csvPath.

													"For each transaction, replace any instance of a 'from' renaming with the current name"
													renamedCTransactions := OrderedCollection new.
													cTransactions
														do: [ :cTransaction | 
															| copyCTransaction i |
															"make copy of transaction record and add it to the new set"
															copyCTransaction := cTransaction copy.
															renamedCTransactions add: copyCTransaction .
															i := 0.
															cTransaction committedFileNames
																do: [ :classToMaybeRename | 
																	i := i + 1.
																	renamings
																				do: [ :renamingRecord | 
																					| fromRename percent |
																					percent := renamingRecord second.
																					fromRename := renamingRecord fourth.
																					copyCTransaction renameAll: fromRename to: class ] ]  .
													"Update for next class to check for renamings"
													cTransactions := renamedCTransactions ] ] ] ]

					"Check for case of no clients/implementations (no interfaces), just use original records (nothing to rename)"
					ifFalse: [ renamedCTransactions  := cTransactionsOriginal  copy ].

					self writeCommitTransactions: renamedCTransactions to: projectName , newTransactionExtension ] ]
		displayingProgress: [ :projectRecord | 'Applying renamings to project: ' , projectRecord second ]
]

{ #category : #'file service' }
GMUtility class >> calculateCouplingIntersections [
	| logicalCouplingFiles arulesExtension clientImpExtension basename trimCurlyBraces linkString results |
	arulesExtension := '_renamed_apriori_rules.csv'.
	clientImpExtension := '_HEAD_ClientImpPairs.csv'.
	linkString := '->'.
	trimCurlyBraces := [ :string | string allButFirst allButLast ].
	results := OrderedCollection new.
	logicalCouplingFiles := FileLocator workingDirectory / 'arules'
		allChildrenMatching: '*' , arulesExtension.
	"	Transcript
		show: 'Processing files: ';
		cr.
	Transcript
		show: (' ' join: logicalCouplingFiles);
		cr."
	logicalCouplingFiles
		do: [ :logicalCouplingFile | 
			| clientImpFile lcInputStream lcRecords scRecords logicalCouplingSet protectedCouplingSet unprotectedCouplingSet logicalProtectedIntersection logicalUnprotectedIntersection |
			basename := logicalCouplingFile basename
				allButLast: arulesExtension size.
			clientImpFile := FileLocator workingDirectory
				/ (basename , clientImpExtension).
			"Transcript
				show: basename;
				cr."
			"Read in CSV of logical coupling"
			lcInputStream := logicalCouplingFile readStream.
			lcRecords := (NeoCSVReader on: lcInputStream)
				separator: $,;
				skipHeader;
				"ruleNumber LHS RHS support confidence lift count"
					addIntegerField;
				"ruleNumber"
					addFieldConverter: trimCurlyBraces;
				"{LHS} - note R puts {...} around the string"
					addFieldConverter: trimCurlyBraces;
				"{RHS}"
					addFloatField;
				"support"
					addFloatField;
				"confidence"
					addFloatField;
				"lift"
					addIntegerField;
				"count"
					upToEnd.

			"Read in CSV of structural coupling (client-implementation)"
			scRecords := self loadClientImplementationPairs: clientImpFile.

			"Create a set of logical coupling"
			logicalCouplingSet := (lcRecords
				collect: [ :each | each second , linkString , each third ]) asSet.
			"Transcript
				show: 'Logical coupling set size: ' , logicalCouplingSet size asString;
				cr."
			protectedCouplingSet := (scRecords
				collect: [ :each | 
					each sixth
						ifTrue: each second , linkString , each fifth ]) asSet.
			"Transcript
				show: 'Protected coupling set size: ' , protectedCouplingSet size asString;
				cr."
			unprotectedCouplingSet := (scRecords
				collect: [ :each | 
					each sixth
						ifFalse: each second , linkString , each fifth ]) asSet.
			"Transcript
				show: 'Unprotected coupling set size: ' , unprotectedCouplingSet size asString;
				cr."
			logicalProtectedIntersection := logicalCouplingSet
				intersection: protectedCouplingSet.
			logicalUnprotectedIntersection := logicalCouplingSet
				intersection: unprotectedCouplingSet.
			"Transcript
				show: 'Intersection of logical coupling and protected coupling set size:' , logicalProtectedIntersection size asString;
				cr."
			"						, (' ' join: logicalProtectedIntersection); cr."
			"Transcript
				show:
					'Intersection of logical coupling and unprotected coupling set size: '
						, logicalUnprotectedIntersection size asString;
				cr."
			"						, (' ' join: logicalUnprotectedIntersection); cr"
			results
				add:
					{basename.
					logicalCouplingSet size.
					protectedCouplingSet size.
					unprotectedCouplingSet size.
					logicalProtectedIntersection size.
					logicalUnprotectedIntersection size} ]
		displayingProgress: [ :file | 'Processing project ' , file basenameWithoutExtension ].
	"Save results to .CSV"
	FileStream
		forceNewFileNamed: 'Logical_and_Structural_Dependency_results.csv'
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut:
					#('Project' '|Logical Coupling|' '|Protected Structural Coupling|' '|Unprotected Structural Coupling|' '|Logical Coupling ^ Protected Structural Coupling|' '|Logical Coupling ^ Unprotected Structural Coupling|');
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ].
	^ results
]

{ #category : #'file service' }
GMUtility class >> calculateCouplingIntersectionsFor: project at: oid [
	| logicalCouplingFile arulesExtension clientImpExtension basename trimCurlyBraces linkString results clientImpFile lcInputStream lcRecords scRecords logicalCouplingSet protectedCouplingSet unprotectedCouplingSet logicalProtectedIntersection logicalUnprotectedIntersection outRef isOutFileNew |
	arulesExtension := '_renamed_only_clients_and_imps_TR_apriori_rules.csv'.
	clientImpExtension := '_' , oid , '_ClientImpPairs.csv'.
	linkString := '->'.
	trimCurlyBraces := [ :string | string allButFirst allButLast ].
	results := OrderedCollection new.
	logicalCouplingFile := FileLocator workingDirectory / 'arules'
		/ (project , arulesExtension).
	"	Transcript
		show: 'Processing files: ';
		cr.
	Transcript
		show: (' ' join: logicalCouplingFiles);
		cr."
	basename := logicalCouplingFile basename allButLast: arulesExtension size.
	clientImpFile := FileLocator workingDirectory / (basename , clientImpExtension).
	"Transcript
				show: basename;
				cr."
	"Read in CSV of logical coupling"
	lcInputStream := logicalCouplingFile readStream.
	lcRecords := (NeoCSVReader on: lcInputStream)
		separator: $,;
		skipHeader;
		"ruleNumber LHS RHS support confidence lift count"
			addIntegerField;
		"ruleNumber"
			addFieldConverter: trimCurlyBraces;
		"{LHS} - note R puts {...} around the string"
			addFieldConverter: trimCurlyBraces;
		"{RHS}"
			addFloatField;
		"support"
			addFloatField;
		"confidence"
			addFloatField;
		"lift"
			addIntegerField;
		"count"
			upToEnd.

	"Read in CSV of structural coupling (client-implementation)"
	scRecords := self loadClientImplementationPairs: clientImpFile.

	"Create a set of logical coupling"
	logicalCouplingSet := (lcRecords
		collect: [ :each | each second , linkString , each third ]) asSet.
	"Transcript
				show: 'Logical coupling set size: ' , logicalCouplingSet size asString;
				cr."
	protectedCouplingSet := Set new.
	scRecords
		do: [ :each | 
			each sixth
				ifTrue: [ protectedCouplingSet add: each second , linkString , each fifth ] ].
	"Transcript
				show: 'Protected coupling set size: ' , protectedCouplingSet size asString;
				cr."
	unprotectedCouplingSet := Set new.
	scRecords
		do: [ :each | 
			each sixth
				ifFalse: [ unprotectedCouplingSet add: each second , linkString , each fifth ] ].
	"Transcript
				show: 'Unprotected coupling set size: ' , unprotectedCouplingSet size asString;
				cr."
	logicalProtectedIntersection := logicalCouplingSet intersection: protectedCouplingSet.
	logicalUnprotectedIntersection := logicalCouplingSet intersection: unprotectedCouplingSet.
	"Transcript
				show: 'Intersection of logical coupling and protected coupling set size:' , logicalProtectedIntersection size asString;
				cr."
	"						, (' ' join: logicalProtectedIntersection); cr."
	"Transcript
				show:
					'Intersection of logical coupling and unprotected coupling set size: '
						, logicalUnprotectedIntersection size asString;
				cr."
	"						, (' ' join: logicalUnprotectedIntersection); cr"
	results
		add:
			{basename.
			logicalCouplingSet size.
			protectedCouplingSet size.
			unprotectedCouplingSet size.
			logicalProtectedIntersection size.
			logicalUnprotectedIntersection size}.
	"Append results to .CSV"
	outRef := 'Logical_and_Structural_Dependency_results.csv' asFileReference.
	isOutFileNew := outRef exists not.
	outRef
		writeStreamDo: [ :csvStream | 
			| streamWriter |
			"Append"
			csvStream setToEnd.
			streamWriter := NeoCSVWriter on: csvStream.
			isOutFileNew
				ifTrue: [ streamWriter
						nextPut:
							#('Project' '|Logical Coupling|' '|Protected Structural Coupling|' '|Unprotected Structural Coupling|' '|Logical Coupling ^ Protected Structural Coupling|' '|Logical Coupling ^ Unprotected Structural Coupling|') ].
			streamWriter
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ].
	^ results
]

{ #category : #'as yet unclassified' }
GMUtility class >> cloneRepo: url [
	"clone a repo of a project (if it doesn't already exist) and return its handle "

	| projectName location |
	"Get project name from URL, accounting for cases where it ends in .git"
	"Clone repo locally if not already there"
	projectName := self extractProjectNameFromURL: url.
	location := (self cloneRoot, projectName) asFileReference.
	location exists
		ifFalse: [ IceGitClone new
				location: location;
				url: url;
				execute ].
	^ location
]

{ #category : #'file service' }
GMUtility class >> cloneReposAndGenerateCommitMetadata: projectsFile [
	"For all repos in the 'projects.csv' file, make a *_commits.csv file with data regarding the repo"

	| working csvInputStream csvRecords i |
	working := FileSystem disk workingDirectory.
	csvInputStream := (working / projectsFile) readStream.
	csvRecords := self loadProjectsList: csvInputStream.	"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"	"GitHub url"
	i := 0.
	[ :job | 
	csvRecords
		do: [ :each | 
			| githubUrl |
			i := i + 1.
			job
				progress: i / csvRecords size;
				title: 'Generating CSV files for commits: ' , each second.
			githubUrl := each last.
			githubUrl = 'NA'
				ifFalse: [ GMCommitFilter filterCommitsOnRepository: githubUrl withRange: '' ] ] ]
		asJob run
]

{ #category : #accessing }
GMUtility class >> cloneRoot [
	^ cloneRoot
]

{ #category : #accessing }
GMUtility class >> cloneRoot: anObject [
	cloneRoot := anObject
]

{ #category : #'file service' }
GMUtility class >> extractIndividualProjectLogicalCouplingData: csvFile [
	"take a big CSV file and break it into smaller ones, project by project"

	| project csvWriter csvOutStream count |
	project := ''.
	csvWriter := nil.
	csvOutStream := nil.
	count := 0.
	[ :job | 
	csvFile asFileReference
		readStreamDo: [ :input | 
			(NeoCSVReader on: (ZnBufferedReadStream on: input))
				skipHeader;
				"Project	  From Class	  To Class	  Revision ID"
					addField;
				"Project"
					"NeoCSV grabs spaces between the ',' separators"
					addFieldConverter: [ :string | string trimBoth ];
				"From Class"
					addFieldConverter: [ :string | string trimBoth ];
				"To Class"
					addFieldConverter: [ :string | string trimBoth asInteger ];
				"Revision ID"
					do: [ :each | 
					each first = project
						ifFalse: [ project := each first.
							count := count + 1.
							"self logCr: 'Found new project: ', project."
							job
								progress: count / 80;
								"80 projects"
									title: 'Extracting data for ' , project asString.
							"init new csv file"
							csvOutStream := FileStream
								forceNewFileNamed: project , '_logicalcoupling_AS2017.csv'.
							csvWriter := NeoCSVWriter on: csvOutStream.
							csvWriter
								nextPut: #('Project' 'From class' 'To class' 'Revision ID');
								addFields: #(first second third fourth) ].
					csvWriter nextPut: each ]
			"			separator: $,;" ] ] asJob run
]

{ #category : #'as yet unclassified' }
GMUtility class >> extractProjectNameFromURL: url [
	| projectName |
	projectName := (url splitOn: '/') last.
	(projectName endsWith: '.git')
		ifTrue: [ projectName := projectName allButLast: '.git' size ].
	^ projectName
]

{ #category : #'as yet unclassified' }
GMUtility class >> filterCommitsOnRepo: location fromTag: fromTag toTag: toTag [
	"selects commits from a range specified by Git tags"

	| repoHandle revwalk newerCommit commitDataList nCommits relativeRevNumber projectName startTag endTag outFile |
	projectName := location path basename.
	repoHandle := LGitRepository on: location.
	repoHandle open.
	"Revwalk goes backwards, so we start at 'to' (latest) and end at 'from' (earliest)"
	startTag := 'tags/' , toTag , '*'.
	endTag := 'tags/' , fromTag , '*'.
	revwalk := self historyRevwalk: repoHandle from: startTag to: endTag.
	newerCommit := nil.
	commitDataList := LinkedList new.

	"Walk through just to count commits for progress bar"
	nCommits := 0.
	revwalk do: [ :commit | nCommits := nCommits + 1 ].
	nCommits > 2000
		ifTrue: [ (UIManager
				confirm:
					'This range has ' , nCommits asString
						, ' commits. Are you sure you want to mine it?')
				ifFalse: [ 0 halt ] ].

	"Revwalk reset didn't work, so we start over"
	revwalk := self historyRevwalk: repoHandle from: startTag to: endTag.

	"Get commit ids that have:
  - no added files (only changed files)
  - 10 or fewer files
  - at least one .java file."
	relativeRevNumber := 0.
	[ :job | 
	revwalk
		do: [ :commit | 
			| addedFiles difference atLeastOneJavaFile diffFiles |
			relativeRevNumber := relativeRevNumber + 1.
			newerCommit
				ifNotNil: [ difference := commit tree diffTo: newerCommit tree.
					diffFiles := difference files.
"					0halt."
					job
						progress: relativeRevNumber / nCommits;
						title:
							'Analyzing revision ' , (commit name truncateTo: 8) , ': '''
								, (commit message truncateTo: 25) , ''' ('
								, difference numberOfDeltas asString , ' files, isMerge=='
								, commit isMerge asString , ') ' , relativeRevNumber asString
								, '/' , nCommits asString.
					addedFiles := Set new.
					diffFiles
						do:
							[ :file | newerCommit tree entryByPath: file ifAbsent: [ addedFiles add: file ] ].
					atLeastOneJavaFile := difference files
						anySatisfy: [ :file | file endsWith: '.java' ].
					commitDataList
						add:
							{newerCommit name.
							(nCommits - relativeRevNumber + 1).	"Revwalk goes from latest to earliest"
							(Character space join: addedFiles).
							difference numberOfDeltas.
							atLeastOneJavaFile.
							(Character space join: diffFiles)} ].
			newerCommit := commit ] ] asJob run.
	outFile := projectName , '_' , fromTag , '-' , toTag
		, '_commits_tags.csv'.
	self writeCommitResults: commitDataList to: outFile.
	^ outFile
]

{ #category : #'as yet unclassified' }
GMUtility class >> filterCommitsOnRepo: location withRange: range [
	"generates a list of info about commits according to the queries within this method."

	| handle revwalk newerCommit commitDataList nCommits revisionNumber projectName outFile |
	projectName := location path basename.
	handle := LGitRepository on: location.
	handle open.
	revwalk := LGitRevwalk of: handle.
	range = ''
		ifFalse: [ revwalk pushRange: range ]
		ifTrue: [ revwalk pushHead ].

	"Get commit ids that have:
  - no added files (only changed files)
  - 10 or fewer files
  - at least one .java file."
	newerCommit := nil.
	commitDataList := LinkedList new.

	"Walk through just to count commits"
	nCommits := 0.
	revwalk do: [ :commit | nCommits := nCommits + 1 ].

	"Revwalk reset didn't work, so we start over"
	revwalk := LGitRevwalk of: handle.
	range = ''
		ifFalse: [ revwalk pushRange: range ]
		ifTrue: [ revwalk pushHead ].
	revisionNumber := 0.
	[ :job | 
	revwalk
		do: [ :commit | 
			| addedFiles difference atLeastOneJavaFile |
			revisionNumber := revisionNumber + 1.
			job
				progress: revisionNumber / nCommits;
				title: 'Analyzing revision ' , commit name.
			newerCommit = nil
				ifFalse: [ difference := newerCommit tree diffTo: commit tree.
					addedFiles := Set new.
					difference files
						do: [ :file | 
							newerCommit tree
								entryByPath: file
								ifAbsent:
									[ "Transcript show: 'File not found in newer commit: ', file ; cr." addedFiles add: file ] ].
					atLeastOneJavaFile := difference files
						anySatisfy: [ :file | file endsWith: '.java' ].
					commitDataList
						add:
							{newerCommit name.
							(nCommits - revisionNumber + 1).	"Revwalk goes from latest to earliest"
							(Character space join: addedFiles).
							difference numberOfDeltas.
							atLeastOneJavaFile.
							(Character space join: difference files)} ].
			newerCommit := commit ] ] asJob run.
	outFile := projectName , '_commits.csv'.
	self writeCommitResults: commitDataList to: outFile.
	^outFile
]

{ #category : #'as yet unclassified' }
GMUtility class >> filterCommitsOnRepoLeftBranchOnly: location from: startOIDString to: endOIDString [
	"selects commits from a range specified by Git tags"

	| repoHandle commitDataList nCommits relativeRevNumber projectName outFile commit parentCommit startCommit endCommit |
	projectName := location path basename.
	repoHandle := LGitRepository on: location.
	repoHandle open.
	commitDataList := LinkedList new.

	startCommit := repoHandle revparse: startOIDString.
	endCommit := repoHandle revparse: endOIDString.

	"Walk through to count commits for progress bar"
	nCommits := 0.
	commit := startCommit.
	[ (commit hasParents) & (commit ~= endCommit) ]
		whileTrue: [ nCommits := nCommits + 1.
			commit := commit parents first ].
	nCommits > 2000
		ifTrue: [ (UIManager
				confirm:
					'This range has ' , nCommits asString
						, ' commits. Are you sure you want to mine it?')
				ifFalse: [ UIManager default abort: 'User aborted.' title: 'Mining stopped.'.
					self error: 'need to terminate Mining pipeline.'
					 ] ].
			
	"Get commit ids that have:
  - no added files (only changed files)
  - 10 or fewer files
  - at least one .java file."
	relativeRevNumber := 0.
	commit := startCommit.
	parentCommit := startCommit parents first.
	[ :job | 
	[ (parentCommit hasParents) & (parentCommit ~= endCommit) ]
		whileTrue: [ | addedFiles difference atLeastOneJavaFile diffFiles |
			relativeRevNumber := relativeRevNumber + 1.
			difference := parentCommit tree diffTo: commit tree.
			diffFiles := difference files.
			job
				progress: relativeRevNumber / nCommits;
				title:
					'Analyzing revision ' , (commit name truncateTo: 8) , ': '''
						, (commit message truncateTo: 25) , ''' ('
						, difference numberOfDeltas asString , ' files, isMerge=='
						, commit isMerge asString , ') ' , relativeRevNumber asString
						, '/' , nCommits asString.
			addedFiles := Set new.
			diffFiles
				do:
					[ :file | commit tree entryByPath: file ifAbsent: [ addedFiles add: file ] ].
			atLeastOneJavaFile := difference files
				anySatisfy: [ :file | file endsWith: '.java' ].
			commitDataList
				add:
					{commit name.
					(nCommits - relativeRevNumber + 1).	"Revwalk goes from latest to earliest"
					(Character space join: addedFiles).
					difference numberOfDeltas.
					atLeastOneJavaFile.
					(Character space join: diffFiles)}.
			commit := parentCommit.
			parentCommit := commit parents first ] ] asJob run.
	outFile := projectName , '_' , (startCommit name first: 7), '-'
		, (endCommit name first: 7), '_commits_oids.csv'.
	self writeCommitResults: commitDataList to: outFile.
	^ outFile
]

{ #category : #'file service' }
GMUtility class >> generateClientImplementationPairs: mseFileRef [
	"For the given MSE file, mine the client-implementation pairs info"

	| results file |
	[ :job | 
	job title: 'Mining client-implementation pairs...'.
	results := GMInterfaceMiner
		mineClientImplementationPairs: mseFileRef
		withPrefix: ''.
	"results size = 0 ifTrue: 0halt."	"-> no interfaces will yield this"
	"Save results to .CSV"
	job
		title: 'Saving file...';
		progress: 0.5.
	file := self writeClientImplementationPairs: results file: mseFileRef ]
		asJob run.
	^ file
]

{ #category : #'file service' }
GMUtility class >> generateClientImplementationPairsFiles: extension [
	"For every MSE file in the data_mining directory tree, mine the client-implementation pairs info"

	| mseDirRoot mseDirs |
	mseDirRoot := FileLocator C / 'tmp' / 'data_mining'.
	mseDirs := mseDirRoot directories.
	mseDirs
		do: [ :dir | 
			| mseFiles results projectName |
			projectName := dir basename asString allButLast: '_master' size.
			mseFiles := dir allChildrenMatching: '*.mse'.
			mseFiles
				do: [ :mseFile | 
					results := GMInterfaceMiner mineClientImplementationPairs: mseFile withPrefix: ''.
					"results size = 0 ifTrue: 0halt." "-> no interfaces will yield this"
					"Save results to .CSV"
					FileStream
						forceNewFileNamed: projectName , '_', mseFile basenameWithoutExtension , '_' , 'ClientImpPairs' , '.csv'
						do: [ :csvStream | 
							(NeoCSVWriter on: csvStream)
								nextPut: #('Client' 'ClientFile' 'Interface' 'Implementation' 'ImplementationFile' 'Protected');
								addFields: #(first second third fourth fifth sixth);
								nextPutAll: results ] ] ]
		displayingProgress: [ :dir | 'Processing directory ' , dir fullName , '...' ]
]

{ #category : #'file service' }
GMUtility class >> generateLogicalCouplingCandidatePairsAndTransactions: fileEnding [
	"take files ending with '_commits_UIDs.csv' and create the logical coupling candidate pairs and transaction files"

	| working selectedCommitFiles |
	working := FileSystem disk workingDirectory.
	selectedCommitFiles := working allChildrenMatching: '*' , fileEnding.
	selectedCommitFiles
		do: [ :file | 
			| csvInputStream csvRecords logicalCouplingRecords project commitTransactions outFileName |
			"Parse the CSV and gather the UIDs for commits that match criteria"
			project := file basename allButLast: fileEnding size.
			csvInputStream := file readStream.
			csvRecords := (NeoCSVReader on: csvInputStream)
				separator: $,;
				skipHeader;
				addField;
				"Commit_id"
					addField;
				"Revision_number"
					addField;
				"committed_files"
					upToEnd.
			logicalCouplingRecords := OrderedCollection new.
			commitTransactions := OrderedCollection new.	"Transaction data: UID, item, item, ..."
			"Write out the logical coupling of java classes for the selected commits"
			"It's pairs of classes in the committed_files set"
			csvRecords
				do: [ :rec | 
					| committedFiles committedClasses classPairs uid revNum |
					uid := rec first.
					revNum := rec second.
					committedFiles := rec third splitOn: Character space.
					committedClasses := committedFiles
						select: [ :each | each endsWith: '.java' ].
					commitTransactions 
						addFirst: (GMCommitTransaction new uid:uid; committedFileNames: committedClasses). "ID, item, item, ...".
					"Note: this won't create pair-entries for commits with only one java file."
					classPairs := committedClasses combinations
						select: [ :each | each size = 2 ].
					classPairs
						do: [ :pair | 
							| sortedPair |
							sortedPair := pair asSortedCollection.
							"Add the pair twice - logical coupling could be either direction"
							logicalCouplingRecords
								addFirst:
									{project.
									pair first.
									pair second.
									uid.
									revNum}.
							logicalCouplingRecords
								addFirst:
									{project.
									pair second.
									pair first.
									uid.
									revNum} ] ].
			"self crLog: 'Creating file ', (file basenameWithoutExtension) , '_logicalcoupling.csv'."
			FileStream
				forceNewFileNamed: file basenameWithoutExtension , '_logicalcoupling.csv'
				do: [ :csvStream | 
					(NeoCSVWriter on: csvStream)
						nextPut: #('Project' 'Class_1' 'Class_2' 'Commit_ID' 'Revision_number');
						addFields: #(first second third fourth fifth);
						nextPutAll: logicalCouplingRecords ].
			"Generates a 'transactions' (basket) style file for arules in R"
			outFileName := file basenameWithoutExtension , '_transactions.csv'.
			self writeCommitTransactions: commitTransactions to: outFileName]
		displayingProgress: [ :file | 
			'Generating data to calculate logical coupling for ' , file basename
				allButLast: fileEnding size ]
]

{ #category : #'file service' }
GMUtility class >> generateLogicalCouplingPairsWithR: inputPath [
	| command |
	"TODO: Error check to remind user to add RScript.exe to path"
	command := 'RScript R/GenerateLogicalPairsFromTransactions.R ' , inputPath
		, ' 2> /tmp/R.errors.txt'.
	Transcript
		show: 'About to execute: ';
		cr;
		show: command.
	^ LibC uniqueInstance system: command
]

{ #category : #'file service' }
GMUtility class >> generateLogicalCouplingPairsWithRSingleFile: filePath [
	"Use R to do some calculations"

	| command pathToRFiles |
	self isRInPath
		ifFalse: [ UIManager default
				abort:
					'RScript.exe could not be found. R must be installed and RScript.exe''s directory must be added to the system path'.
			"Return non-zero means something bad happened"
			^ 1 ].
	pathToRFiles := (self locationOfProjectRepo / 'R/') pathString.
	command := 'RScript ' , pathToRFiles
		, '/GenerateLogicalPairsFromTransactionsSingleFile.R ' , filePath
		, ' 2> /tmp/R.errors.txt'.
	^ LibC uniqueInstance system: command
]

{ #category : #'file service' }
GMUtility class >> generateMSEFileFor: oid reponame: repoName [
	"Generate a Moose MSE for the OID -- OID can be hexString or 'HEAD' "
	
	| working destPath repoPath gitErrors jdt2FamixErrors revPath command result mseFile |
	destPath := '/tmp/data_mining'.
	gitErrors := '/tmp/errors_git'.
	jdt2FamixErrors := '/tmp/errors_jdt2famix'.
	working := FileSystem disk workingDirectory.

	"Create a new sub dir for the repos MSE dirs"
	(working / 'MSE') ensureCreateDirectory.
	repoPath := '/tmp/tempClonesPharo/' , repoName.
	revPath := destPath , '/' , repoName , '_master/' , oid.
	command := 'cd ' , repoPath , ' && git --work-tree=' , revPath , ' checkout ' , oid , ' -- . 2>' , gitErrors.
	revPath asFileReference ensureCreateDirectory.
	"self logCr: 'About to create directory: ', revPath ."
	OSEnvironment current setEnv: 'GIT_INDEX_FILE' value: revPath , '/.git'.
	"self logCr: 'About to execute command: ', command. result := 0."
	result := LibC uniqueInstance system: command.
	result = 0
		ifFalse: [ gitErrors asFileReference ]
		ifTrue: [ | mseDestination |
			"Make an MSE file"
			command := 'cd ' , revPath , ' && /jdt2famix-bin-1.0.12/jdt2famix.cmd 2>' , jdt2FamixErrors.
			result := LibC uniqueInstance system: command.
			"self logCr: 'About to execute command: ', command. result := 0."
			result = 0
				ifFalse: [ jdt2FamixErrors asFileReference ]
				ifTrue: [ "Move the file out of the directory"
					mseFile := (revPath , '/' , oid , '.mse') asFileReference.
					mseDestination := (destPath , '/' , repoName , '_master/' , oid , '.mse') asFileReference.
					"self logCr: 'About to move ', mseFile asString, ' to ', mseDestination asString."
					mseFile exists
						ifTrue: [ mseDestination exists
								ifTrue: [ mseDestination delete ].
							mseFile moveTo: mseDestination ] ].
			"Clean up the directories and files"
			"revPath asFileReference deleteAll" "Dangerous if buggy..." ].
		^ mseFile
]

{ #category : #'file service' }
GMUtility class >> generateMSEFilesForEachHEAD: uidFileSuffix [
	"For each *_UIDs.csv file, generate a Moose MSE for the HEAD of repo"

	| working uidFiles destPath repoPath gitErrors jdt2FamixErrors revPath |
	destPath := '/tmp/data_mining'.
	gitErrors := '/tmp/errors_git'.
	jdt2FamixErrors := '/tmp/errors_jdt2famix'.
	working := FileSystem disk workingDirectory.
	uidFiles := working allChildrenMatching: '*' , uidFileSuffix.

	"Create a new sub dir for the repos MSE dirs"
	(working / 'MSE') ensureCreateDirectory.
	uidFiles
		do: [ :file | 
			| repoName uidFileName uid command result |
			"Create a new sub dir for the repos MSE files"
			uidFileName := file basename.
			repoName := uidFileName allButLast: uidFileSuffix size.
			repoPath := '/tmp/tempClonesPharo/' , repoName.
			uid := 'HEAD'.
			revPath := destPath , '/' , repoName , '_master/' , uid.
			command := 'cd ' , repoPath , ' && git --work-tree=' , revPath , ' checkout ' , uid
				, ' -- . 2>' , gitErrors.
			revPath asFileReference ensureCreateDirectory.
			"self logCr: 'About to create directory: ', revPath ."
			OSEnvironment current setEnv: 'GIT_INDEX_FILE' value: revPath , '/.git'.
			result := LibC uniqueInstance system: command.
			"self logCr: 'About to execute command: ', command. result := 0."
			result = 0
				ifFalse: [ gitErrors asFileReference ]
				ifTrue: [ | mseFile mseDestination |
					"Make an MSE file"
					command := 'cd ' , revPath , ' && /jdt2famix-bin-1.0.12/jdt2famix.cmd 2>'
						, jdt2FamixErrors.
					result := LibC uniqueInstance system: command.
					"self logCr: 'About to execute command: ', command. result := 0."
					result = 0
						ifFalse: [ jdt2FamixErrors asFileReference ]
						ifTrue: [ "Move the file out of the directory"
							mseFile := (revPath , '/' , uid , '.mse') asFileReference.
							mseDestination := (destPath , '/' , repoName , '_master/' , uid , '.mse')
								asFileReference.
							"self logCr: 'About to move ', mseFile asString, ' to ', mseDestination asString."
							mseFile exists
								ifTrue: [ mseDestination exists
										ifTrue: [ mseDestination delete ].
									mseFile moveTo: mseDestination ] ].
					"Clean up the directories and files"
					revPath asFileReference deleteAll ] ]
		displayingProgress: [ :file | 'Generating MSE file for HEAD of: ' , file basename ]
]

{ #category : #'file service' }
GMUtility class >> generateMSEFilesForEachUID: uidFileSuffix [
"For each *_UIDs.csv file, generate a Moose MSE "

| working uidFiles destPath repoPath gitErrors jdt2FamixErrors revPath |
destPath := '/tmp/data_mining'.
gitErrors := '/tmp/errors_git'.
jdt2FamixErrors := '/tmp/errors_jdt2famix'.


working := FileSystem disk workingDirectory.
"uidFileSuffix := '_commits_UIDs.csv'."
uidFiles := working allChildrenMatching: ('*', uidFileSuffix) .

"Create a new sub dir for the repos MSE dirs"
(working / 'MSE') ensureCreateDirectory.

uidFiles do: [ :file | 
	| csvInputStream csvRecords selectedCommits repoName uidFileName | 
	"Parse the CSV and gather the UIDs for commits that match criteria"
	csvInputStream := file readStream.
	csvRecords := (NeoCSVReader on:  csvInputStream) 
		separator: $,;
		skipHeader;
		addField; "Commit_id"
		addField; "Revision_number"
		addField; "Committed_files"
		upToEnd.
	
	"Create a new sub dir for the repos MSE files"
	uidFileName := file basename.
	repoName := uidFileName allButLast: uidFileSuffix size.
   repoPath := '/tmp/tempClonesPharo/', repoName.	 

	csvRecords do: [ :csvRecord |
		| uid command result |
		uid := csvRecord first.
		revPath := destPath, '/',  repoName, '_master/', uid.
		command := 'cd ', repoPath, ' && git --work-tree=', revPath, ' checkout ', uid, ' -- . 2>', gitErrors.
		(revPath asFileReference ) ensureCreateDirectory.
		"self logCr: 'About to create directory: ', revPath ." 
		OSEnvironment current setEnv: 'GIT_INDEX_FILE' value: (revPath, '/.git').
		result := LibC uniqueInstance system: command.
		"self logCr: 'About to execute command: ', command. result := 0."

		result = 0 ifFalse: [ gitErrors asFileReference  ]
		ifTrue: [ 
			| mseFile mseDestination |
			"Make an MSE file"
			command := 'cd ', revPath, ' && /jdt2famix-bin-1.0.12/jdt2famix.cmd 2>', jdt2FamixErrors.
			result := LibC uniqueInstance system: command.
			"self logCr: 'About to execute command: ', command. result := 0." 
			result = 0 ifFalse: [ jdt2FamixErrors asFileReference ]
			ifTrue: [ 	
				"Move the file out of the directory"
				mseFile := (revPath, '/', uid, '.mse') asFileReference.
				mseDestination := (destPath , '/', repoName, '_master/', uid, '.mse' ) asFileReference.
				"self logCr: 'About to move ', mseFile asString, ' to ', mseDestination asString."
				mseFile exists ifTrue: [ 
					mseDestination exists ifTrue: [ mseDestination delete ].
					mseFile moveTo: mseDestination ]
			].
			"Clean up the directories and files"
			revPath asFileReference deleteAll.
		]
		
	] displayingProgress: [ :r | 'Processing UID: ', r first ].
	
] displayingProgress: [ :file | 'Processing: ', file basename  ].


]

{ #category : #'file service' }
GMUtility class >> generatePairsAndTransactions: selectedCommitsFile [
	"Create the logical coupling candidate pairs and transaction file from the set of selected commits"

	| selectedCommitsFileRef csvRecords logicalCouplingRecords project commitTransactions cp ct |
	"Parse the CSV and gather the UIDs for commits that match criteria"
	selectedCommitsFileRef := selectedCommitsFile asFileReference.
	project := selectedCommitsFileRef basenameWithoutExtension.
	csvRecords := self readSelectedCommitsFile: selectedCommitsFile.
	logicalCouplingRecords := OrderedCollection new.
	commitTransactions := OrderedCollection new.	"Transaction data: UID, item, item, ..."
	"Write out the logical coupling of java classes for the selected commits"
	"It's pairs of classes in the committed_files set"
	csvRecords
		do: [ :rec | 
			| committedFiles committedClasses classPairs uid revNum |
			uid := rec first.
			revNum := rec second.
			committedFiles := rec third splitOn: Character space.
			committedClasses := committedFiles
				select: [ :each | each endsWith: '.java' ].
			commitTransactions
				addFirst:
					(GMCommitTransaction new
						uid: uid;
						committedFileNames: committedClasses).	"ID, item, item, ..."
			classPairs := committedClasses combinations
				select: [ :each | each size = 2 ].
			"Note: this won't create pair-entries for commits with only one java file."
			classPairs
				do: [ :pair | 
					"Add the pair twice - logical coupling could be either direction"
					logicalCouplingRecords
						addFirst:
							{project.
							pair first.
							pair second.
							uid.
							revNum}.
					logicalCouplingRecords
						addFirst:
							{project.
							pair second.
							pair first.
							uid.
							revNum} ] ]
		displayingProgress: 'Selecting commits according to criteria...'.
	"self crLog: 'Creating file ', (file basenameWithoutExtension) , '_logicalcoupling.csv'."
	[ :job | 
	job title: 'Writing class pairs.'.
	cp := self
		writeClassPairs: logicalCouplingRecords
		file: selectedCommitsFile.
	job progress: 0.5;
	title: 'Writing transactions.'.
	"Generates a 'transactions' (basket) style file for arules in R"
	ct := self
		writeCommitTransactions: commitTransactions
		to: selectedCommitsFile ] asJob run.
	^ Array with: cp with: ct
]

{ #category : #'file service' }
GMUtility class >> generateSelectedCommitFiles: commitFileExtension [
"Selects commits from *_commits.csv files and writes out a list of UIDs that match (in a *_UIDs.csv file)"

| working commitFiles |
working := FileSystem disk workingDirectory.

"working := 'G:\My Drive\Congé sabbatique 2018-2019\Activités INRIA\Change Evolution Interface Clients\Pharo image' asFileReference."

commitFiles := working allChildrenMatching: commitFileExtension.

commitFiles do: [ :file | 
	| csvInputStream csvRecords selectedCommits commitID revisionNumber addedFiles countCommittedFiles hasJava committedFiles |
 
	"Parse the CSV and gather the UIDs for commits that match criteria"
	csvInputStream := file readStream.
	csvRecords := (NeoCSVReader on:  csvInputStream) 
		separator: $,;
		skipHeader;
		addField; "Commit_id"
		addField; "Revision_number"
		addField; "set of Added_files"
		addIntegerField; "n_committed_files"
		addField; "has_java"
		addField; "committed_files"
		upToEnd.

	"Transcript show: csvRecords; cr."

	selectedCommits := csvRecords select: [ :each | 
"		commitID := each first. 
		revisionNumber := each second. "
		addedFiles := each third. 
		countCommittedFiles := each fourth. 
		hasJava := each fifth. 
"		committedFiles := each sixth." 
		(addedFiles = nil "no added files") and: (countCommittedFiles <= 10 and: hasJava = 'true')].

	"Write out the list of UIDs for the selected commits"
	"self crLog: 'Creating file ', (file basenameWithoutExtension) , '_UIDs.csv'."
	FileStream
		forceNewFileNamed: (file basenameWithoutExtension) , '_UIDs.csv'
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Revision_number' 'committed_files');
				addFields: #(first second sixth);
				nextPutAll: selectedCommits ].
] displayingProgress: [ :file | 'Selecting UIDs in: ', file basename ]
]

{ #category : #accessing }
GMUtility class >> generateSelectedCommits: commitMetadataFile [
	"Selects commits from metadata file and writes the list"

	| csvRecords selectedCommits addedFiles countCommittedFiles hasJava |
	csvRecords := self loadCommitMetadataFile: commitMetadataFile.
	selectedCommits := csvRecords
		select: [ :each | 
			"		commitID := each first. 
		revisionNumber := each second. "
			addedFiles := each third.
			countCommittedFiles := each fourth.
			hasJava := each fifth.
			"		committedFiles := each sixth."
			addedFiles isNil & (countCommittedFiles <= 10) & (hasJava = 'true') ].
	^ self writeSelectedCommits: selectedCommits file: commitMetadataFile
]

{ #category : #'as yet unclassified' }
GMUtility class >> getOIDFromTag: tagString on: loc [
	"based on example from https://ben.straub.cc/2013/06/03/refs-tags-and-branching/ "
	| repoHandle gitRef result toReturn |
	toReturn := nil.
	repoHandle := LGitRepository on: loc.
	repoHandle open.
	gitRef := LGitReference of: repoHandle.
	result := gitRef reference_lookup: nil repo: repoHandle name: 'refs/tags/' , tagString.
	result = LGitReturnCodeEnum git_ok
		ifTrue: [ toReturn := gitRef targetId hexString ].
	^ toReturn
]

{ #category : #'as yet unclassified' }
GMUtility class >> historyRevwalk: repo from: startTag to: endTag [
	"inits an LGitRevwalk for history between two tags, formatted as 'tags/blah*' where 'blah' is the tag name"
	| revwalk |
	revwalk := LGitRevwalk of: repo.
	revwalk beSortedByCommitTime.
	revwalk beSortedParentsBeforeChildren.
	revwalk pushGlob: startTag.
	revwalk hideGlob: endTag.
	^ revwalk

]

{ #category : #initialization }
GMUtility class >> initialize [
	"init the variables used in mining"

	cloneRoot := 'c:/tmp/tempClonesPharo/'.
]

{ #category : #'as yet unclassified' }
GMUtility class >> isRInPath [
	"Make sure RScript.exe can be found"
	| result |
	result := LibC uniqueInstance system: 'RScript --version'.
	^ result = 0
]

{ #category : #'file service' }
GMUtility class >> loadClientImplementationPairs: fileReference [
	| scRecords scInputStream |
	scInputStream := fileReference  readStream.
	scRecords := (NeoCSVReader on: scInputStream)
		separator: $,;
		skipHeader;
		"Client ClientFile Interface Implementation ImplementationFile Protected"
			addField;
		"Client (Moose name)"
			addField;
		"ClientFile (file name)"
			addField;
		"Interface"
			addField;
		"Implementation (Moose name)"
			addField;
		"ImplementationFile (file name)"
			addFieldConverter: [ :string | string = 'true' ];
		"Protected"
			upToEnd.
	^ scRecords
]

{ #category : #'file service' }
GMUtility class >> loadCommitMetadataFile: fileName [ 
	"Parse the CSV and gather the UIDs for commits that match criteria"
	| csvInputStream csvRecords |
	csvInputStream := fileName asFileReference readStream.
	csvRecords := (NeoCSVReader on:  csvInputStream) 
		separator: $,;
		skipHeader;
		addField; "Commit_id"
		addField; "Revision_number"
		addField; "set of Added_files"
		addIntegerField; "n_committed_files"
		addField; "has_java"
		addField; "committed_files"
		upToEnd.
		^ csvRecords
]

{ #category : #'file service' }
GMUtility class >> loadCommitTransactions: transactionsFileReference [
	"Load commit transactions. Note NeoCSVReader doesn't support variable records, so we declare spots for many entries, and remove them after."

	| transactionRecords transactions csvInputStream |
	csvInputStream := transactionsFileReference  readStream.
	transactionRecords := (NeoCSVReader on: csvInputStream)
		separator: $,;
		"Commit UID"
			addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		upToEnd.

	"Get rid of the nil elements in the transactions"
	^ transactionRecords 
		collect: [ :transaction | 
			GMCommitTransaction transactionFromRecord:  (transaction asCollection select: #isNotNil) ]
]

{ #category : #'file service' }
GMUtility class >> loadProjectsList: csvInputStream [
	| csvRecords |
	csvRecords := (NeoCSVReader on: csvInputStream)
		separator: $,;
		skipHeader;
		"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"
			addIntegerField;
		addField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addField;
		addField;
		"GitHub url"
			upToEnd.
	^ csvRecords
]

{ #category : #'file service' }
GMUtility class >> loadRenamings: csvPath [
 	"Load csv file of renamings (from git history)"
	| records |
	records := (NeoCSVReader on: csvPath readStream)
		separator: $,;
		"UID"
		addField;
		"percentage"
		addIntegerField; 
		"operation (copy or rename)"
		addField;
		"from name"
		addField;
		"to name"
		addField;		
		upToEnd.
		^ records
]

{ #category : #'as yet unclassified' }
GMUtility class >> locationOfProjectRepo [
	"finds the location of the project (e.g., to find R files that are not part of Pharo)"

	| icebergRepository |
	icebergRepository := IceRepository registry
		detect: [ :repository | 
			repository workingCopy packages
				anySatisfy: [ :package | package name = 'GitMiner' ] ]
		ifNone:
			[ self error: 'No repository in Iceberg containing the needed files.' ].
	icebergRepository location exists
		ifFalse: [ self
				error:
					'The repository of the project does not have a pointer to a local clone to find the files' ].
	^ icebergRepository location
]

{ #category : #'file service' }
GMUtility class >> readSelectedCommitsFile: selectedCommitsFile [
	| csvRecords csvInputStream |
	csvInputStream := selectedCommitsFile asFileReference readStream.
	csvRecords := (NeoCSVReader on: csvInputStream)
		separator: $,;
		skipHeader;
		addField;
		"Commit_id"
			addField;
		"Revision_number"
			addField;
		"committed_files"
			upToEnd.
	^ csvRecords
]

{ #category : #'file service' }
GMUtility class >> removeUnrelatedClassesFromTransactions: project [
	"Go through renamed transaction files and remove the class names that aren't clients or implementations"
	 | cTransactions file clientImplementationPairsRecords clientsTemp implementationsTemp classesToInclude | 
	file := (project,'_commits_UIDs_transactions_renamed.csv') asFileReference .
	cTransactions := self loadCommitTransactions:  file.
	file := (project, '_HEAD_ClientImpPairs.csv') asFileReference .
	clientImplementationPairsRecords := self loadClientImplementationPairs: file.
	clientImplementationPairsRecords size > 0
	ifTrue: [ "Client file name is second column"
		clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
		"Implementation file name is fifth column"
		implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
		classesToInclude := clientsTemp union: implementationsTemp.
		cTransactions do: [ :cTran |
			cTran committedFileNames: (cTran committedFileNames intersection: classesToInclude )
			 ]
		].
	self writeCommitTransactions: cTransactions  to: project,'_commits_UIDs_transactions_renamed_only_clients_and_imps.csv'.	
	^cTransactions
]

{ #category : #'file service' }
GMUtility class >> removeUnrelatedClassesFromTransactions: project fromRevision: oid [
	"Go through renamed transaction files and remove the class names that aren't clients or implementations"
	 | cTransactions file clientImplementationPairsRecords clientsTemp implementationsTemp classesToInclude | 
	file := (project,'_commits_tags_OIDs_TR_renamed_TR.csv') asFileReference .
	cTransactions := self loadCommitTransactions:  file.
	file := (project, '_', oid , '_ClientImpPairs.csv') asFileReference .
	clientImplementationPairsRecords := self loadClientImplementationPairs: file.
	clientImplementationPairsRecords size > 0
	ifTrue: [ "Client file name is second column"
		clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
		"Implementation file name is fifth column"
		implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
		classesToInclude := clientsTemp union: implementationsTemp.
		cTransactions do: [ :cTran |
			cTran committedFileNames: (cTran committedFileNames intersection: classesToInclude )
			 ]
		].
	^self writeCommitTransactions: cTransactions  to: project,'_commits_UIDs_transactions_renamed_only_clients_and_imps.csv'
]

{ #category : #'file service' }
GMUtility class >> writeClassPairs: logicalCouplingRecords file: fromFileName [
	| newFileName |
	newFileName := fromFileName asFileReference basenameWithoutExtension
		, '_LC.csv'.
	newFileName asFileReference
		ensureDelete;
		writeStreamDo: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: #('Project' 'Class_1' 'Class_2' 'Commit_ID' 'Revision_number');
				addFields: #(first second third fourth fifth);
				nextPutAll: logicalCouplingRecords ].
	^ newFileName
]

{ #category : #writing }
GMUtility class >> writeClientImplementationPairs: results file: mseFileRef [
	"Save results to CSV file"

	| fileName projectName |
	projectName := mseFileRef parent basename allButLast: '_master' size.
	fileName := projectName , '_' , mseFileRef basenameWithoutExtension
		, '_' , 'ClientImpPairs' , '.csv'.
	[ :job | 
	job title: 'Writing client-implementation pairs.'.
	FileStream
		forceNewFileNamed: fileName
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut:
					#('Client' 'ClientFile' 'Interface' 'Implementation' 'ImplementationFile' 'Protected');
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ] ] asJob run.
	^ fileName
]

{ #category : #writing }
GMUtility class >> writeCommitResults: commitDataList to: fileName [
	" Generate a CSV with commit results"

	FileStream
		forceNewFileNamed: fileName
		do: [ :csvStream | 
			"{newerCommit . addedFiles . difference numberOfDeltas . atLeastOneJavaFile . committedFiles}"
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Revision_num' 'Added_files' 'n_commited_files' 'has_java' 'committed_files');
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: commitDataList ].
]

{ #category : #writing }
GMUtility class >> writeCommitTransactions: transactionRecords to: selectedCommitsFile [
	"Write out single column (with embedded commas!)"

	| concatRecords outFileName |
	outFileName := selectedCommitsFile asFileReference
		basenameWithoutExtension , '_TR.csv'.
	"Concatenate variable number of items with commas, since we can't use NeoCSV to write them"
	concatRecords := OrderedCollection new.
	transactionRecords
		ifNotNil: [ concatRecords := transactionRecords
				collect:
					[ :cTran | cTran uid , ',' , ($, join: cTran committedFileNames)	"ID, item, item, ..." ] ].
	outFileName asFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			concatRecords
				do: [ :rec | 
					stream
						nextPutAll: rec;
						cr ] ].
	^ outFileName
]

{ #category : #'file service' }
GMUtility class >> writeSelectedCommits: selectedCommits file: fileName [
	| file selCommitsFileName |
	file := fileName asFileReference.
	selCommitsFileName := file basenameWithoutExtension , '_UIDs.csv'.
	selCommitsFileName asFileReference
		ensureDelete;
		writeStreamDo: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Revision_number' 'committed_files');
				addFields: #(first second sixth);
				nextPutAll: selectedCommits ].
	^ selCommitsFileName
]

"
Class with homeless methods... To be refactored into an API.
"
Class {
	#name : #Utility,
	#superclass : #Object,
	#category : #'Fuhrman-MooseHerder'
}

{ #category : #'file service' }
Utility class >> extractIndividualProjectLogicalCouplingData: csvFile [
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

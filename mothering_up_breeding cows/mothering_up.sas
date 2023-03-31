
GOPTIONS DEVICE=activex GSFMODE=REPLACE cback=white ctext=black gunit=pct COLORS=(BLACK BLUE RED GREEN)
         ftext=swiss htitle=2 htext=2 hsize=12 vsize=8 ;
*IMAGE_DPI=400;
ods html style = minimal;
*BODY  = 'C:\Users\augus\Desktop\github_repositories\mothering-up\outputs\mothering1.html';
*GPATH = 'C:\Users\augus\Desktop\github_repositories\mothering-up\outputs\';

* database from automatic weighing;
proc import out=df1
datafile='C:\Users\augus\Desktop\github_repositories\databases\mothering up\1_Pye_136_WOW - Copy.xlsx'
DBMS = XLSX replace;
*USEDATE=YES;
sheet='SASinput';
getnames=yes;
*guessingrows=32767; /* this is the maximum for Base SAS 9.2 */
*USE_DATETYPE=YES;
*format time2 time.;
run;

* animal list;
proc import out=df2
datafile='C:\Users\augus\Desktop\github_repositories\databases\mothering up\6_PyeFarm_AnimalList1 - Copy.xlsx'
DBMS = XLSX replace;
*USEDATE=YES;
sheet='SASinput';
getnames=yes;
*guessingrows=32767; /* this is the maximum for Base SAS 9.2 */
*USE_DATETYPE=YES;
*format time2 time.;
run;

* merging both databases;
proc print data=df1 (obs=5);run;

data df1;
set df1;
drop File FID;
run;

proc print data=df1 (obs=5);run;

proc print data=df2 (obs=5);run;

data df2;
set df2;
drop location_list;
run;

proc print data=df2 (obs=5);run;

proc sort data=df1;
by EID;
run;

proc sort data=df2;
by EID;
run;

data df3;
merge df1 df2;
by EID;

run;

proc sort data=df3;
by NroObs;
run;

proc print data=df3 (obs=100);run;

data rawdata (drop= category_list subcategory_list) ;
set df3;

if missing(NroObs) or NroObs='.' then delete;
*else if Date lt '01JUL17'D then delete;
*else if Date gt '01FEB18'D THEN delete;
*else if missing(EID) or EID='.' then delete;
*else if missing(NroObs) or NroObs='.' then delete;
*else if missing(Weight) or Weight='.' then delete;
*else if missing(Date) or Date='.' then delete;
*else if missing(Time) or Time='.' then delete;
*else if missing(DateTime) or DateTime='.' then delete;
*else if missing(FID) or FID='.' then delete;
*else if missing(category_list) or category_list='.' then delete;
*else if missing(subcategory_list) or subcategory_list='.' then delete;
*else if missing(sex) or sex='.' then delete;

run;

proc sort data=df3;
by NroObs;
run;

proc print data=rawdata (obs=100);run;

*--------------MOTHERING-UP ALGORITHMS---------------;
title 'mothering up algorithms';

proc sort data=rawdata;
by NroObs;
run;

proc print data=rawdata (obs=10);run;

* detect the most followed animals lag1,lag2,lag3,etc detects EID from 2, 3 etc rows below;
proc sort data=rawdata;
by NroObs;
run;

proc print data=rawdata (obs=50);run;

data RawDataMothering;
set rawdata;

	LAG1EID=LAG(EID);
	LAG2EID=LAG2(EID);
	LAG3EID=LAG3(EID);
	LAG4EID=LAG4(EID);
	LAG5EID=LAG5(EID);
	LAG6EID=LAG6(EID);

	LAG1SEX=LAG(SEX);
run;

proc print data=RawDataMothering (obs=50);run;

proc sort data=RawDataMothering;
by descending NroObs;
run;

proc print data=RawDataMothering (obs=50);run;

*detecting lead animals;
data RawDataMothering;
set RawDataMothering;

	LEAD1EID=LAG(EID);
	LEAD2EID=LAG2(EID);
	LEAD3EID=LAG3(EID);
	LEAD4EID=LAG4(EID);
	LEAD5EID=LAG5(EID);
	LEAD6EID=LAG6(EID);

	LEAD1SEX=LAG(SEX);

run;

proc print data=RawDataMothering (obs=50);run;

proc sort data=RawDataMothering;
by EID FID sex NroObs;
run;

PROC FREQ DATA=RawDataMothering NOPRINT;
BY EID FID sex;
*TABLE LAG1EID*LAG1SEX  / OUT=MotherUpLAG1 (RENAME=(COUNT=COUNTLAG1));
TABLE LAG1EID*LAG1 / OUT=MotherUpLAG1 (RENAME=(COUNT=COUNTLAG1));
TABLE LAG2EID  / OUT=MotherUpLAG2 (RENAME=(COUNT=COUNTLAG2));
TABLE LAG3EID  / OUT=MotherUpLAG3 (RENAME=(COUNT=COUNTLAG3));
TABLE LAG4EID  / OUT=MotherUpLAG4 (RENAME=(COUNT=COUNTLAG4));
TABLE LAG5EID  / OUT=MotherUpLAG5 (RENAME=(COUNT=COUNTLAG5));
TABLE LAG6EID  / OUT=MotherUpLAG6 (RENAME=(COUNT=COUNTLAG6));

*TABLE EID*LEAD1SEX / OUT=MotherUpLAG6 (RENAME=(COUNT=COUNTLAG6));
*TABLE LEAD1EID*LEAD1SEX / OUT=MotherUpLEAD1 (RENAME=(COUNT=COUNTLEAD1));
TABLE LEAD1EID*LEAD1 / OUT=MotherUpLEAD1 (RENAME=(COUNT=COUNTLEAD1));
TABLE LEAD2EID / OUT=MotherUpLEAD2 (RENAME=(COUNT=COUNTLEAD2));
TABLE LEAD3EID / OUT=MotherUpLEAD3 (RENAME=(COUNT=COUNTLEAD3));
TABLE LEAD4EID / OUT=MotherUpLEAD4 (RENAME=(COUNT=COUNTLEAD4));
TABLE LEAD5EID / OUT=MotherUpLEAD5 (RENAME=(COUNT=COUNTLEAD5));
TABLE LEAD6EID / OUT=MotherUpLEAD6 (RENAME=(COUNT=COUNTLEAD6));
*OUTPUT OUT=MotherUP;
RUN;

PROC PRINT DATA=MotherUpLAG1 (OBS=150);
RUN;

* KEEP ONLY ROWS WITH VALUES GREATER THAN 1;
proc sort data = MotherUpLAG1;
by EID;
run;

data LAG1EID_more1;
set MotherUpLAG1;
by EID;
If missing(COUNTLAG1) OR COUNTLAG1=1 then delete;
run;

PROC PRINT DATA=LAG1EID_more1;
RUN;

* KEEP ONLY THE ROW WITH LARGEST VALUE;
proc sort data = MotherUpLAG1;
by EID descending COUNTLAG1;
run;

data LAG1EID_max;
set MotherUpLAG1;
by EID;
If first.EID then output LAG1EID_max;
run;


proc sort data = MotherUpLAG2;
by EID descending COUNTLAG2;
run;
data LAG2EID_max;
set MotherUpLAG2;
by EID;
If first.EID then output LAG2EID_max;
run;

proc sort data = MotherUpLAG3;
by EID descending COUNTLAG3;
run;
data LAG3EID_max;
set MotherUpLAG3;
by EID;
If first.EID then output LAG3EID_max;
run;

proc sort data = MotherUpLAG4;
by EID descending COUNTLAG4;
run;
data LAG4EID_max;
set MotherUpLAG4;
by EID;
If first.EID then output LAG4EID_max;
run;

proc sort data = MotherUpLAG5;
by EID descending COUNTLAG5;
run;
data LAG5EID_max;
set MotherUpLAG5;
by EID;
If first.EID then output LAG5EID_max;
run;

proc sort data = MotherUpLAG6;
by EID descending COUNTLAG6;
run;
data LAG6EID_max;
set MotherUpLAG6;
by EID;
If first.EID then output LAG6EID_max;
run;

proc sort data = MotherUpLEAD1;
by EID descending COUNTLead1;
run;
data lead1EID_max;
set MotherUpLEAD1;
by EID;
If first.EID then output lead1EID_max;
run;

proc sort data = MotherUpLEAD2;
by EID descending COUNTLead2;
run;
data lead2EID_max;
set MotherUpLEAD2;
by EID;
If first.EID then output lead2EID_max;
run;


proc sort data = MotherUpLEAD3;
by EID descending COUNTLead3;
run;
data lead3EID_max;
set MotherUpLEAD3;
by EID;
If first.EID then output lead3EID_max;
run;

proc sort data = MotherUpLEAD4;
by EID descending COUNTLead4;
run;
data lead4EID_max;
set MotherUpLEAD4;
by EID;
If first.EID then output lead4EID_max;
run;


proc sort data = MotherUpLEAD5;
by EID descending COUNTLead5;
run;
data lead5EID_max;
set MotherUpLEAD5;
by EID;
If first.EID then output lead5EID_max;
run;

proc sort data = MotherUpLEAD6;
by EID descending COUNTLead6;
run;
data lead6EID_max;
set MotherUpLEAD6;
by EID;
If first.EID then output lead6EID_max;
run;




PROC SORT DATA=LAG1EID_max; BY EID; RUN;
PROC SORT DATA=LAG2EID_max; BY EID; RUN;
PROC SORT DATA=LAG3EID_max; BY EID; RUN;
PROC SORT DATA=LAG4EID_max; BY EID; RUN;
PROC SORT DATA=LAG5EID_max; BY EID; RUN;
PROC SORT DATA=LAG6EID_max; BY EID; RUN;

PROC SORT DATA=lead1EID_max; BY EID; RUN;
PROC SORT DATA=lead2EID_max; BY EID; RUN;
PROC SORT DATA=lead3EID_max; BY EID; RUN;
PROC SORT DATA=lead4EID_max; BY EID; RUN;
PROC SORT DATA=lead5EID_max; BY EID; RUN;
PROC SORT DATA=lead6EID_max; BY EID; RUN;


DATA MotherUp;
MERGE LAG1EID_max LAG2EID_max LAG3EID_max LAG4EID_max LAG5EID_max LAG6EID_max lead1EID_max lead2EID_max lead3EID_max lead4EID_max lead5EID_max lead6EID_max;
BY EID;
		 IF COUNTLAG1 LE 1 AND (COUNTLEAD1 LE 1) THEN DELETE; * DELETE MOTHER UPS WITH VALUES OF 1;
* DELETE ALL LAGEID THAT ARE THE SAME AS EID, THE DAM IS THE CALF;
	ELSE IF EID EQ LAG1EID THEN DO; LAG1EID=''; COUNTLAG1=''; END;
	ELSE IF EID EQ LAG2EID THEN DO; LAG2EID=''; COUNTLAG2=''; END;
	ELSE IF EID EQ LAG3EID THEN DO; LAG3EID=''; COUNTLAG3=''; END;
	ELSE IF EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;
	ELSE IF EID EQ LEAD1EID THEN DO; LEAD1EID=''; COUNTLEAD1=''; END;
	ELSE IF EID EQ LEAD2EID THEN DO; LEAD2EID=''; COUNTLEAD2=''; END;
	ELSE IF EID EQ LEAD3EID THEN DO; LEAD3EID=''; COUNTLEAD3=''; END;
	ELSE IF EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

* DELETE REPEATED DAMS;
	ELSE IF LAG1EID EQ LAG2EID THEN DO; LAG2EID=''; COUNTLAG2=''; END;
	ELSE IF LAG1EID EQ LAG3EID THEN DO; LAG3EID=''; COUNTLAG3=''; END;
	ELSE IF LAG1EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF LAG1EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LAG1EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;

	ELSE IF LAG2EID EQ LAG3EID THEN DO; LAG3EID=''; COUNTLAG3=''; END;
	ELSE IF LAG2EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF LAG2EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LAG2EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;

	ELSE IF LAG3EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF LAG3EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LAG3EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;

	ELSE IF LAG4EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LAG4EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;

	ELSE IF LAG5EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;


	ELSE IF LEAD1EID EQ LEAD2EID THEN DO; LEAD2EID=''; COUNTLEAD2=''; END;
	ELSE IF LEAD1EID EQ LEAD3EID THEN DO; LEAD3EID=''; COUNTLEAD3=''; END;
	ELSE IF LEAD1EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF LEAD1EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LEAD1EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD2EID EQ LEAD3EID THEN DO; LEAD3EID=''; COUNTLEAD3=''; END;
	ELSE IF LEAD2EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF LEAD2EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LEAD2EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD3EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF LEAD3EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LEAD3EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD4EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LEAD4EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD5EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;


	ELSE IF LAG1EID EQ LEAD1EID THEN DO; LEAD1EID=''; COUNTLEAD1=''; END;
	ELSE IF LAG1EID EQ LEAD2EID THEN DO; LEAD2EID=''; COUNTLEAD2=''; END;
	ELSE IF LAG1EID EQ LEAD3EID THEN DO; LEAD3EID=''; COUNTLEAD3=''; END;
	ELSE IF LAG1EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF LAG1EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LAG1EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD1EID EQ LAG2EID THEN DO; LAG2EID=''; COUNTLAG2=''; END;
	ELSE IF LEAD1EID EQ LAG3EID THEN DO; LAG3EID=''; COUNTLAG3=''; END;
	ELSE IF LEAD1EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF LEAD1EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LEAD1EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;


* these are imposible mothers (another calf is the mother) have to be deleted because ;

*		 IF BRAND='2YP1' AND LAG1BRAND='2YP1' THEN DELETE;
*	ELSE IF BRAND='2YP1' AND LAG1BRAND='2YP5' THEN DELETE;
*	ELSE IF BRAND='2YP1' AND LAG1BRAND='2YP3' THEN DELETE;



RUN;

*PROC FREQ DATA=MotherUp noprint;
*TABLE EID*BRAND / OUT=MotherUpTest;
*RUN;

*proc print data=MotherUpTest;
*run;

*DELETE COWS THAT HAVE SEVERAL CALVES IN THOSE WITH LOWER COUNTS;
proc sort data = MotherUp;
by LAG1EID DESCENDING COUNTLAG1;
run;
data MotherUp;
set MotherUp;
	LAG1MOTHER=LAG(LAG1EID);
	IF LAG1MOTHER=LAG1EID AND (COUNTLAG1 LT LAG(COUNTLAG1)) THEN DELETE;

run;

PROC PRINT DATA=MotherUp (OBS=50);
RUN;

proc export data=MotherUp
 	outfile='R:\PRJ-AnimalTech\Day-to-day files\Ongoing analysis DEC 2017_up-to-date the folder\WOW herd\SAS Results WOW_05 02 2018\WoW Pye 2017 MotherUp raw data.CSV'
	dbms=csv
	replace;
run;

PROC SORT DATA=MotherUp;
BY EID;
RUN;

DATA MotherUp;
SET MotherUp;
*		 IF COUNTLAG1 LE 2 AND (COUNTLEAD1 LE 2) THEN DELETE; * DELETE MOTHER UPS WITH VALUES OF 1;

	IF COUNTLAG1 GE COUNTLEAD1 THEN DO;
		DamCalfEID=LAG1EID;
		FinalCount=COUNTLAG1;
		DamCalfSEX=LAG1SEX;
	END;
	ELSE DO;
		DamCalfEID=LEAD1EID;
		FinalCount=COUNTLEAD1;
		DamCalfSEX=LEAD1SEX;
	END;
RUN;

PROC PRINT DATA=MotherUp (OBS=50);
RUN;

DATA MotherUp;
SET MotherUp;


* THIS IS A MANUAL DELETION OF MOTHERED UP CALVES WHERE THE DAM WAS SELECTED FOR 2 OR MORE ANIMALS;
*		 IF EID='982 123518082289' THEN DamCalfEID='';
*	ELSE IF EID='982 125002808389' THEN DamCalfEID='';

RUN;


PROC SORT DATA= MotherUp;
BY DamCalfEID;
RUN;
DATA MotherUp;
MERGE MotherUp;
BY DamCalfEID;
		 IF MISSING(EID) THEN DELETE;
	ELSE IF MISSING(DamCalfEID) THEN DELETE;
RUN;

PROC FREQ DATA=MotherUp;
TABLE SEX;
RUN;

PROC FREQ DATA=MotherUp noprint;
*WHERE SEX2='Calf';
TABLE EID*SEX*DamCalfEID*DamCalfSEX / OUT=MotherUpFinal (drop=COUNT PERCENT);
RUN;

proc print data=MotherUpFinal;
run;

proc export data=MotherUp
 	outfile='C:\Users\augus\Desktop\github_repositories\mothering-up\outputs\XXYY.CSV'
	dbms=csv
	replace;
run;

proc export data=MotherUpFinal
 	outfile='C:\Users\augus\Desktop\github_repositories\mothering-up\outputs\MotherUp final.CSV'
	dbms=csv
	replace;
run;





DATA MotherUp;
MERGE MotherUp AnimalList (RENAME=(EID=DamCalfEID SEX=DamCalfSEX));
BY DamCalfEID;
		 IF MISSING(EID) THEN DELETE;
	ELSE IF MISSING(DamCalfEID) THEN DELETE;
RUN;



*--------------MOTHERING-UP ALGORITHMS---------------;
TITLE 'MOTHERING UP ALGORITHMS';
PROC SORT DATA=RawData0;
BY ObsNro;
RUN;

* CALCULATE LAG ANIMALS;
DATA RawDataMothering;
SET RawData0;
	
	LAG1EID=LAG(EID);
	LAG2EID=LAG2(EID);
	LAG3EID=LAG3(EID);
	LAG4EID=LAG4(EID);
	LAG5EID=LAG5(EID);
	LAG6EID=LAG6(EID);

	LAG1SEX=LAG(SEX);
RUN;


*CALCULATE LEAD ANIMALS;
PROC SORT DATA=RawData0 ;
BY DESCENDING ObsNro;
RUN;

DATA RawDataMothering;
SET RawDataMothering;
	LEAD1EID=LAG(EID);
	LEAD2EID=LAG2(EID);
	LEAD3EID=LAG3(EID);
	LEAD4EID=LAG4(EID);
	LEAD5EID=LAG5(EID);
	LEAD6EID=LAG6(EID);

	LEAD1SEX=LAG(SEX);

RUN;

PROC PRINT DATA=RawDataMothering (OBS=50);
RUN;

PROC SORT DATA=RawDataMothering;
BY EID FID SEX SEX2 OBSNRO;
RUN;

PROC FREQ DATA=RawDataMothering NOPRINT;
BY EID FID SEX SEX2 ;
TABLE LAG1EID*LAG1SEX  / OUT=MotherUpLAG1 (RENAME=(COUNT=COUNTLAG1));
TABLE LAG2EID  / OUT=MotherUpLAG2 (RENAME=(COUNT=COUNTLAG2));
TABLE LAG3EID  / OUT=MotherUpLAG3 (RENAME=(COUNT=COUNTLAG3));
TABLE LAG4EID  / OUT=MotherUpLAG4 (RENAME=(COUNT=COUNTLAG4));
TABLE LAG5EID  / OUT=MotherUpLAG5 (RENAME=(COUNT=COUNTLAG5));
TABLE LAG6EID  / OUT=MotherUpLAG6 (RENAME=(COUNT=COUNTLAG6));

*TABLE EID*LEAD1SEX / OUT=MotherUpLAG6 (RENAME=(COUNT=COUNTLAG6));

TABLE LEAD1EID*LEAD1SEX / OUT=MotherUpLEAD1 (RENAME=(COUNT=COUNTLEAD1));
TABLE LEAD2EID / OUT=MotherUpLEAD2 (RENAME=(COUNT=COUNTLEAD2));
TABLE LEAD3EID / OUT=MotherUpLEAD3 (RENAME=(COUNT=COUNTLEAD3));
TABLE LEAD4EID / OUT=MotherUpLEAD4 (RENAME=(COUNT=COUNTLEAD4));
TABLE LEAD5EID / OUT=MotherUpLEAD5 (RENAME=(COUNT=COUNTLEAD5));
TABLE LEAD6EID / OUT=MotherUpLEAD6 (RENAME=(COUNT=COUNTLEAD6));
*OUTPUT OUT=MotherUP;
RUN;

PROC PRINT DATA=MotherUpLAG1 (OBS=150);
RUN;

* KEEP ONLY ROWS WITH VALUES GREATER THAN 1;
proc sort data = MotherUpLAG1;
by EID;
run;

data LAG1EID_more1;
set MotherUpLAG1;
by EID;
If missing(COUNTLAG1) OR COUNTLAG1=1 then delete;
run;

PROC PRINT DATA=LAG1EID_more1;
RUN;

* KEEP ONLY THE ROW WITH LARGEST VALUE;
proc sort data = MotherUpLAG1;
by EID descending COUNTLAG1;
run;

data LAG1EID_max;
set MotherUpLAG1;
by EID;
If first.EID then output LAG1EID_max;
run;


proc sort data = MotherUpLAG2;
by EID descending COUNTLAG2;
run;
data LAG2EID_max;
set MotherUpLAG2;
by EID;
If first.EID then output LAG2EID_max;
run;

proc sort data = MotherUpLAG3;
by EID descending COUNTLAG3;
run;
data LAG3EID_max;
set MotherUpLAG3;
by EID;
If first.EID then output LAG3EID_max;
run;

proc sort data = MotherUpLAG4;
by EID descending COUNTLAG4;
run;
data LAG4EID_max;
set MotherUpLAG4;
by EID;
If first.EID then output LAG4EID_max;
run;

proc sort data = MotherUpLAG5;
by EID descending COUNTLAG5;
run;
data LAG5EID_max;
set MotherUpLAG5;
by EID;
If first.EID then output LAG5EID_max;
run;

proc sort data = MotherUpLAG6;
by EID descending COUNTLAG6;
run;
data LAG6EID_max;
set MotherUpLAG6;
by EID;
If first.EID then output LAG6EID_max;
run;

proc sort data = MotherUpLEAD1;
by EID descending COUNTLead1;
run;
data lead1EID_max;
set MotherUpLEAD1;
by EID;
If first.EID then output lead1EID_max;
run;

proc sort data = MotherUpLEAD2;
by EID descending COUNTLead2;
run;
data lead2EID_max;
set MotherUpLEAD2;
by EID;
If first.EID then output lead2EID_max;
run;


proc sort data = MotherUpLEAD3;
by EID descending COUNTLead3;
run;
data lead3EID_max;
set MotherUpLEAD3;
by EID;
If first.EID then output lead3EID_max;
run;

proc sort data = MotherUpLEAD4;
by EID descending COUNTLead4;
run;
data lead4EID_max;
set MotherUpLEAD4;
by EID;
If first.EID then output lead4EID_max;
run;


proc sort data = MotherUpLEAD5;
by EID descending COUNTLead5;
run;
data lead5EID_max;
set MotherUpLEAD5;
by EID;
If first.EID then output lead5EID_max;
run;

proc sort data = MotherUpLEAD6;
by EID descending COUNTLead6;
run;
data lead6EID_max;
set MotherUpLEAD6;
by EID;
If first.EID then output lead6EID_max;
run;




PROC SORT DATA=LAG1EID_max; BY EID; RUN;
PROC SORT DATA=LAG2EID_max; BY EID; RUN;
PROC SORT DATA=LAG3EID_max; BY EID; RUN;
PROC SORT DATA=LAG4EID_max; BY EID; RUN;
PROC SORT DATA=LAG5EID_max; BY EID; RUN;
PROC SORT DATA=LAG6EID_max; BY EID; RUN;

PROC SORT DATA=lead1EID_max; BY EID; RUN;
PROC SORT DATA=lead2EID_max; BY EID; RUN;
PROC SORT DATA=lead3EID_max; BY EID; RUN;
PROC SORT DATA=lead4EID_max; BY EID; RUN;
PROC SORT DATA=lead5EID_max; BY EID; RUN;
PROC SORT DATA=lead6EID_max; BY EID; RUN;


DATA MotherUp;
MERGE LAG1EID_max LAG2EID_max LAG3EID_max LAG4EID_max LAG5EID_max LAG6EID_max lead1EID_max lead2EID_max lead3EID_max lead4EID_max lead5EID_max lead6EID_max;
BY EID;
		 IF COUNTLAG1 LE 1 AND (COUNTLEAD1 LE 1) THEN DELETE; * DELETE MOTHER UPS WITH VALUES OF 1;
* DELETE ALL LAGEID THAT ARE THE SAME AS EID, THE DAM IS THE CALF;
	ELSE IF EID EQ LAG1EID THEN DO; LAG1EID=''; COUNTLAG1=''; END;
	ELSE IF EID EQ LAG2EID THEN DO; LAG2EID=''; COUNTLAG2=''; END;
	ELSE IF EID EQ LAG3EID THEN DO; LAG3EID=''; COUNTLAG3=''; END;
	ELSE IF EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;
	ELSE IF EID EQ LEAD1EID THEN DO; LEAD1EID=''; COUNTLEAD1=''; END;
	ELSE IF EID EQ LEAD2EID THEN DO; LEAD2EID=''; COUNTLEAD2=''; END;
	ELSE IF EID EQ LEAD3EID THEN DO; LEAD3EID=''; COUNTLEAD3=''; END;
	ELSE IF EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

* DELETE REPEATED DAMS;
	ELSE IF LAG1EID EQ LAG2EID THEN DO; LAG2EID=''; COUNTLAG2=''; END;
	ELSE IF LAG1EID EQ LAG3EID THEN DO; LAG3EID=''; COUNTLAG3=''; END;
	ELSE IF LAG1EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF LAG1EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LAG1EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;

	ELSE IF LAG2EID EQ LAG3EID THEN DO; LAG3EID=''; COUNTLAG3=''; END;
	ELSE IF LAG2EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF LAG2EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LAG2EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;

	ELSE IF LAG3EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF LAG3EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LAG3EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;

	ELSE IF LAG4EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LAG4EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;

	ELSE IF LAG5EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;


	ELSE IF LEAD1EID EQ LEAD2EID THEN DO; LEAD2EID=''; COUNTLEAD2=''; END;
	ELSE IF LEAD1EID EQ LEAD3EID THEN DO; LEAD3EID=''; COUNTLEAD3=''; END;
	ELSE IF LEAD1EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF LEAD1EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LEAD1EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD2EID EQ LEAD3EID THEN DO; LEAD3EID=''; COUNTLEAD3=''; END;
	ELSE IF LEAD2EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF LEAD2EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LEAD2EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD3EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF LEAD3EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LEAD3EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD4EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LEAD4EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD5EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;


	ELSE IF LAG1EID EQ LEAD1EID THEN DO; LEAD1EID=''; COUNTLEAD1=''; END;
	ELSE IF LAG1EID EQ LEAD2EID THEN DO; LEAD2EID=''; COUNTLEAD2=''; END;
	ELSE IF LAG1EID EQ LEAD3EID THEN DO; LEAD3EID=''; COUNTLEAD3=''; END;
	ELSE IF LAG1EID EQ LEAD4EID THEN DO; LEAD4EID=''; COUNTLEAD4=''; END;
	ELSE IF LAG1EID EQ LEAD5EID THEN DO; LEAD5EID=''; COUNTLEAD5=''; END;
	ELSE IF LAG1EID EQ LEAD6EID THEN DO; LEAD6EID=''; COUNTLEAD6=''; END;

	ELSE IF LEAD1EID EQ LAG2EID THEN DO; LAG2EID=''; COUNTLAG2=''; END;
	ELSE IF LEAD1EID EQ LAG3EID THEN DO; LAG3EID=''; COUNTLAG3=''; END;
	ELSE IF LEAD1EID EQ LAG4EID THEN DO; LAG4EID=''; COUNTLAG4=''; END;
	ELSE IF LEAD1EID EQ LAG5EID THEN DO; LAG5EID=''; COUNTLAG5=''; END;
	ELSE IF LEAD1EID EQ LAG6EID THEN DO; LAG6EID=''; COUNTLAG6=''; END;


* these are imposible mothers (another calf is the mother) have to be deleted because ;

*		 IF BRAND='2YP1' AND LAG1BRAND='2YP1' THEN DELETE;
*	ELSE IF BRAND='2YP1' AND LAG1BRAND='2YP5' THEN DELETE;
*	ELSE IF BRAND='2YP1' AND LAG1BRAND='2YP3' THEN DELETE;



RUN;

*PROC FREQ DATA=MotherUp noprint;
*TABLE EID*BRAND / OUT=MotherUpTest;
*RUN;

*proc print data=MotherUpTest;
*run;

*DELETE COWS THAT HAVE SEVERAL CALVES IN THOSE WITH LOWER COUNTS;
proc sort data = MotherUp;
by LAG1EID DESCENDING COUNTLAG1;
run;
data MotherUp;
set MotherUp;
	LAG1MOTHER=LAG(LAG1EID);
	IF LAG1MOTHER=LAG1EID AND (COUNTLAG1 LT LAG(COUNTLAG1)) THEN DELETE;

run;

PROC PRINT DATA=MotherUp (OBS=50);
RUN;

proc export data=MotherUp
 	outfile='R:\PRJ-AnimalTech\Day-to-day files\Ongoing analysis DEC 2017_up-to-date the folder\WOW herd\SAS Results WOW_05 02 2018\WoW Pye 2017 MotherUp raw data.CSV'
	dbms=csv
	replace;
run;

PROC SORT DATA=MotherUp;
BY EID;
RUN;

DATA MotherUp;
SET MotherUp;
*		 IF COUNTLAG1 LE 2 AND (COUNTLEAD1 LE 2) THEN DELETE; * DELETE MOTHER UPS WITH VALUES OF 1;

	IF COUNTLAG1 GE COUNTLEAD1 THEN DO;
		DamCalfEID=LAG1EID;
		FinalCount=COUNTLAG1;
		DamCalfSEX=LAG1SEX;
	END;
	ELSE DO;
		DamCalfEID=LEAD1EID;
		FinalCount=COUNTLEAD1;
		DamCalfSEX=LEAD1SEX;
	END;
RUN;

DATA MotherUp;
SET MotherUp;


* THIS IS A MANUAL DELETION OF MOTHERED UP CALVES WHERE THE DAM WAS SELECTED FOR 2 OR MORE ANIMALS;
*		 IF EID='982 123518082289' THEN DamCalfEID='';
*	ELSE IF EID='982 125002808389' THEN DamCalfEID='';

RUN;


PROC SORT DATA= MotherUp;
BY DamCalfEID;
RUN;
DATA MotherUp;
MERGE MotherUp AnimalList (RENAME=(EID=DamCalfEID SEX=DamCalfSEX));
BY DamCalfEID;
		 IF MISSING(EID) THEN DELETE;
	ELSE IF MISSING(DamCalfEID) THEN DELETE;
RUN;

PROC FREQ DATA=MotherUp;
TABLE SEX;
RUN;

PROC FREQ DATA=MotherUp noprint;
WHERE SEX2='Calf';
TABLE EID*SEX*DamCalfEID*DamCalfSEX / OUT=MotherUpFinal (drop=COUNT PERCENT);
RUN;

proc print data=MotherUpFinal;
run;

proc export data=MotherUp
 	outfile='R:\PRJ-AnimalTech\Day-to-day files\Ongoing analysis DEC 2017_up-to-date the folder\WOW herd\SAS Results WOW_05 02 2018\WoW Pye 2017 MotherUp all data.CSV'
	dbms=csv
	replace;
run;

proc export data=MotherUpFinal
 	outfile='R:\PRJ-AnimalTech\Day-to-day files\Ongoing analysis DEC 2017_up-to-date the folder\WOW herd\SAS Results WOW_05 02 2018\WoW Pye 2017 MotherUp final.CSV'
	dbms=csv
	replace;
run;


























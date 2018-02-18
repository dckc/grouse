-- cms_utsw_facts_build.sql: create a new blueherondata observation_fact
-- Copyright (c) 2017 University of Kansas Medical Center
-- Run against identified GROUSE server
-- NOTE: CODE HAS NOT BEEN TESTED YET

drop table i2b2demodatautcris.observation_fact_int purge;

CREATE TABLE i2b2demodatautcris.OBSERVATION_FACT_INT as  
select 
(ed.ENCOUNTER_NUM-(-229152720030522111800009)+200000000000000000000000) ENCOUNTER_NUM
, coalesce(dp.bene_id_deid, to_char((pd.patient_num-(-17199782))+30000000)) patient_num
  /*+ index(observation_fact OBS_FACT_PAT_NUM_BI) */
, ob.patient_num as patient_num_bh
, CONCEPT_CD 
-- , PROVIDER_ID -- Not using the UTSW provider_dimension
, ob.START_DATE - nvl(dp.BH_DATE_SHIFT_DAYS,0) + nvl(dp.cms_date_shift_days,0) START_DATE
, ob.END_DATE - nvl(dp.BH_DATE_SHIFT_DAYS,0) + nvl(dp.cms_date_shift_days,0) END_DATE
, ob.UPDATE_DATE - nvl(dp.BH_DATE_SHIFT_DAYS,0) + nvl(dp.cms_date_shift_days,0) UPDATE_DATE
, MODIFIER_CD
, INSTANCE_NUM -- CONFIRM**
, VALTYPE_CD
-- , TVAL_CHAR -- removing TVAL_CHAR on purpose 
, NVAL_NUM 
, VALUEFLAG_CD 
, QUANTITY_NUM
, UNITS_CD 
, LOCATION_CD 
, OBSERVATION_BLOB
, CONFIDENCE_NUM
, DOWNLOAD_DATE 
, IMPORT_DATE 
, SOURCESYSTEM_CD
, upload_id*(-1) UPLOAD_ID
from 
i2b2demodatautcris.new_observation_fact ob
left join
(
select distinct patient_num, bene_id, bene_id_deid, 
cms_date_shift_days, BH_DATE_SHIFT_DAYS,
cms_dob_shift_months, BH_DOB_DATE_SHIFT
from cms_id.cms_utsw_mapping 
where 
dups_bene_id = 0 and 
dups_pat_num = 0 and 
(dups_missing_map =0 or (bene_id is not null and xw_bene_id is not null))
and patient_num is not null and bene_id_deid is not null
) dp
on dp.patient_num = ob.patient_num;


  CREATE BITMAP INDEX "i2b2demodatautcris"."OBS_FACT_ENC_NUM_BI_INT" ON "i2b2demodatautcris"."OBSERVATION_FACT_INT" ("ENCOUNTER_NUM") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 NOLOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATAMARTS" 
  PARALLEL 2 ;

  CREATE BITMAP INDEX "i2b2demodatautcris"."OBS_FACT_PAT_NUM_BI_INT" ON "i2b2demodatautcris"."OBSERVATION_FACT_INT" ("PATIENT_NUM") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 NOLOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATAMARTS" 
  PARALLEL 2 ;

  CREATE BITMAP INDEX "i2b2demodatautcris"."OBS_FACT_CON_CODE_BI_INT" ON "i2b2demodatautcris"."OBSERVATION_FACT_INT" ("CONCEPT_CD") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 NOLOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATAMARTS" 
  PARALLEL 2 ;
  
  CREATE INDEX "i2b2demodatautcris"."OBSERVATION_FACT_UPLOAD_ID_INT" ON "i2b2demodatautcris"."OBSERVATION_FACT_INT" ("UPLOAD_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATAMARTS" ;


  CREATE BITMAP INDEX "i2b2demodatautcris"."OBS_FACT_MOD_CODE_BI_INT" ON "i2b2demodatautcris"."OBSERVATION_FACT_INT" ("MODIFIER_CD") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 NOLOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATAMARTS" 
  PARALLEL 2 ;

  CREATE BITMAP INDEX "i2b2demodatautcris"."OBS_FACT_NVAL_NUM_BI_INT" ON "i2b2demodatautcris"."OBSERVATION_FACT_INT" ("NVAL_NUM") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 NOLOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATAMARTS" 
  PARALLEL 2 ;


  CREATE BITMAP INDEX "i2b2demodatautcris"."OBS_FACT_VALTYP_CD_BI_INT" ON "i2b2demodatautcris"."OBSERVATION_FACT_INT" ("VALTYPE_CD") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 NOLOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATAMARTS" 
  PARALLEL 2 ;

-- ========== STATS

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());
EXEC dbms_stats.unlock_table_stats(ownname=>'i2b2demodatautcris', tabname=>'OBSERVATION_FACT');
EXEC dbms_stats.delete_table_stats(ownname=>'i2b2demodatautcris', tabname=>'OBSERVATION_FACT');
exec dbms_stats.set_table_stats(OWNNAME=>'i2b2demodatautcris', TABNAME=>'OBSERVATION_FACT', NUMROWS=>100000000000000000000000);
EXEC dbms_stats.lock_table_stats(ownname=>'i2b2demodatautcris', tabname=>'OBSERVATION_FACT');
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- ========== VERIFICATION
select count(patient_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT;

select count(distinct patient_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT;

select count(patient_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT
where patient_num>=30000000; -- UTSW patients who do not have GROUSE data. 

select count(patient_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT
where patient_num between 30000000 and 40000000; -- UTSW patients who do not have GROUSE data. 

select count(*) from 
i2b2demodatautcris.visit_dimension_int;

select count(*) from 
i2b2demodatautcris.visit_dimension;

select count(distinct encounter_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT
where encounter_num>=400000000; 
-- UTSW patients who do not have GROUSE data. 

select count(encounter_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT
where encounter_num between 200000000000000000000000 and 500000000000000000000000; 
-- UTSW patients who do not have GROUSE data. 

select count(distinct patient_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT;

select count(distinct patient_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT;

select count(distinct patient_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT
where patient_num>=30000000; -- UTSW patients who do not have GROUSE data. 

select count(distinct patient_num) from 
i2b2demodatautcris.OBSERVATION_FACT_INT
where patient_num between 1 and 19999999; -- UTSW patients who have GROUSE data. 
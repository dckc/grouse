'''cms_etl -- Load an i2b2 star schema from CMS RIF data

See README.md background and usage.

Integration Test Usage:

  (grouse-etl)$ python cms_etl.py

'''

import luigi

from etl_tasks import (
    DBAccessTask, SqlScriptTask, UploadTask, ReportTask,
    TimeStampParameter)
from script_lib import Script, Source, I2B2STAR, CMS_RIF


class CMSExtract(luigi.Config):
    download_date = TimeStampParameter()


class CDW(luigi.Config):
    star_schema = luigi.Parameter()  # ISSUE: get from I2B2Project task?
    cms_rif = luigi.Parameter()


class GrouseTask(luigi.Task):
    star_schema = luigi.Parameter(default=CDW().star_schema)
    cms_rif = luigi.Parameter(default=CDW().cms_rif)
    project_id = luigi.Parameter(default='GROUSE')
    source = luigi.EnumParameter(enum=Source, default=Source.cms)
    download_date = TimeStampParameter(default=CMSExtract().download_date)

    @property
    def variables(self):
        return {I2B2STAR: self.star_schema,
                CMS_RIF: self.cms_rif,
                Source.cms.name + '_source_cd': "'%s'" % (Source.cms.value,)}


class GrouseWrapper(luigi.WrapperTask, GrouseTask):
    pass


class GrouseETL(DBAccessTask, GrouseWrapper):
    def parts(self):
        return [
            _make_from(Demographics, self),
            _make_from(Encounters, self),
            _make_from(Diagnoses, self),
        ]

    def requires(self):
        return self.parts()


class GrouseRollback(GrouseETL):
    def complete(self):
        return False

    def requires(self):
        return []

    def run(self):
        for task in self.parts():
            task.rollback()


class PatientMappingTask(UploadTask, GrouseWrapper):
    script = Script.cms_patient_mapping


def _make_from(dest_class, src, **kwargs):
    names = dest_class.get_param_names(include_significant=True)
    src_args = src.param_kwargs
    kwargs = dict((name,
                   kwargs[name] if name in kwargs else
                   src_args[name] if name in src_args else
                   getattr(src, name))
                  for name in names)
    return dest_class(**kwargs)


class PatientDimensionTask(UploadTask, GrouseWrapper):
    script = Script.cms_patient_dimension

    def requires(self):
        return UploadTask.requires(self) + [
            _make_from(PatientMappingTask, self)]


class _DataReport(ReportTask, DBAccessTask, GrouseTask):
    def requires(self):
        return dict(
            data=_make_from(self.data_task, self),
            report=_make_from(SqlScriptTask, self,
                              script=self.script))

    def rollback(self):
        self.requires()['data'].rollback()


class Demographics(_DataReport):
    script = Script.cms_dem_dstats
    report_name = 'demographic_summary'
    data_task = PatientDimensionTask


class EncounterMappingTask(UploadTask, GrouseWrapper):
    script = Script.cms_encounter_mapping


class VisitDimensionTask(UploadTask, GrouseWrapper):
    script = Script.cms_visit_dimension

    def requires(self):
        return UploadTask.requires(self) + [
            _make_from(PatientMappingTask, self),
            _make_from(EncounterMappingTask, self)]

    def rollback(self):
        UploadTask.rollback(self)
        for task in self.requires()[-2:]:
            if isinstance(task, UploadTask):
                task.rollback()


class Encounters(_DataReport):
    script = Script.cms_enc_dstats
    report_name = 'encounters_per_visit_patient'
    data_task = VisitDimensionTask


class DiagnosesTransform(SqlScriptTask, GrouseWrapper):
    script = Script.cms_dx_txform


class DiagnosesLoad(UploadTask, GrouseWrapper):
    script = Script.cms_facts_load
    fact_view = 'observation_fact_cms_dx'

    @property
    def label(self):
        return DiagnosesTransform.script.title

    @property
    def transform_name(self):
        return self.fact_view

    @property
    def variables(self):
        return dict(GrouseWrapper().variables,
                    fact_view=self.fact_view)

    def requires(self):
        skip_fact_view = GrouseWrapper().variables
        return [
            _make_from(DiagnosesTransform, self,
                       variables=skip_fact_view),
            _make_from(PatientMappingTask, self,
                       variables=skip_fact_view),
            _make_from(EncounterMappingTask, self,
                       variables=skip_fact_view),
        ]


class Diagnoses(_DataReport):
    script = Script.cms_dx_dstats
    report_name = 'dx_by_enc_type'
    data_task = DiagnosesLoad


if __name__ == '__main__':
    luigi.build([GrouseETL()], local_scheduler=True)

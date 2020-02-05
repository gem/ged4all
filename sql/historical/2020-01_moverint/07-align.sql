ALTER TABLE ONLY cf_common.process_type ADD CONSTRAINT process_type_hazard_code_fkey FOREIGN KEY (hazard_code) REFERENCES cf_common.hazard_type(code);

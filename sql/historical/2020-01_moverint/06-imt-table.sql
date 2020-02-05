START TRANSACTION;

DROP TABLE IF EXISTS cf_common.imt;

ALTER TABLE cf_common.process_type DROP CONSTRAINT IF EXISTS 
	unique_code_hazard_code;
ALTER TABLE cf_common.process_type ADD CONSTRAINT 
	unique_code_hazard_code UNIQUE(code, hazard_code);

CREATE TABLE cf_common.imt(
	process_code VARCHAR NOT NULL,
	hazard_code VARCHAR NOT NULL,
	im_code VARCHAR NOT NULL PRIMARY KEY,
	description VARCHAR NOT NULL,
	units VARCHAR NOT NULL,
	FOREIGN KEY (process_code,hazard_code) 
		REFERENCES cf_common.process_type(code, hazard_code)
);
COPY cf_common.imt (process_code,hazard_code,im_code,description,units) 
FROM STDIN WITH (FORMAT csv);
QGM,EQ,PGA:g,Peak ground acceleration in g,g
QGM,EQ,PGA:m/s2,Peak ground acceleration in m/s2 (meters per second squared),m/s2
QGM,EQ,PGV:m/s,Peak ground velocity in m/s,m/s
QGM,EQ,SA(0.2):g,Spectral acceleration with 0.2s period,g
QGM,EQ,SA(0.3):g,Spectral acceleration with 0.3s period,g
QGM,EQ,SA(1.0):g,Spectral acceleration with 1.0s period,g
QGM,EQ,SA(3.0):g,Spectral acceleration with 3.0s period,g
QGM,EQ,SA(0.2):m/s2,Spectral acceleration with 0.2s period,m/s2
QGM,EQ,SA(0.3):m/s2,Spectral acceleration with 0.3s period,m/s2
QGM,EQ,SA(1.0):m/s2,Spectral acceleration with 1.0s period,m/s2
QGM,EQ,SA(3.0):m/s2,Spectral acceleration with 3.0s period,m/s2
QGM,EQ,Sd(T1):m,Spectral displacement,m
QGM,EQ,Sv(T1):m/s,Spectral velocity,m/s
QGM,EQ,PGDf:m,Permanent ground deformation,m
QGM,EQ,D_a5-95:s,Significant duration a5-95,s
QGM,EQ,D_a5-75 :s,Significant duration a5-75,s
QGM,EQ,IA:m/s,Arias intensity (Iα) or (IA) or (Ia),m/s
QGM,EQ,Neq:-,Effective number of cycles,-
QGM,EQ,EMS:-,European macroseismic scale,-
QGM,EQ,AvgSa:m/s2,Average spectral acceleration,m/s2
QGM,EQ,I_Np:m/s2,I_Np by Bojórquez and Iervolino,m/s2
QGM,EQ,MMI:-,Modified Mercalli Intensity,-
QGM,EQ,CAV:m/s,Cumulative absolute velocity,m/s
QGM,EQ,D_B:s,Bracketed duration,s
FFF,FL,d_fff:m,Flood water depth,m
FPF,FL,d_fpf:m,Flood water depth,m
FFF,FL,v_fff:m/s,Flood flow velocity,m/s
FPF,FL,v_fpf:m/s,Flood flow velocity,m/s
TCY,WI,v_tcy(3s):km/h,3-sec at 10m sustained wind speed (kph),km/h
ETC,WI,v_ect(3s):km/h,3-sec at 10m sustained wind speed (kph),km/h
TCY,WI,v_tcy(1m):km/h,1-min at 10m sustained wind speed (kph),km/h
ETC,WI,v_ect(1m):km/h,1-min at 10m sustained wind speed (kph),km/h
TCY,WI,v_tcy(10m):km/h,10-min sustained wind speed (kph),km/h
ETC,WI,v_etc(10m):km/h,10-min sustained wind speed (kph),km/h
TCY,WI,PGWS_tcy:km/h,Peak gust wind speed,km/h
ETC,WI,PGWS_ect:km/h,Peak gust wind speed,km/h
LSL,LS,d_lsl:m,Landslide flow depth,m
LSL,LS,I_DF:m3/s2,Debris-flow intensity index,m3/s2
LSL,LS,v_lsl:m/s2,Landslide flow velocity,m/s2
LSL,LS,MFD_lsl:m,Maximum foundation displacement,m
LSL,LS,SD_lsl:m,Landslide displacement,m
TSI,TS,Rh_tsi:m,Tsunami wave runup height,m
TSI,TS,d_tsi:m,Tsunami inundation depth,m
TSI,TS,MMF:m4/s2,Modified momentum flux,m4/s2
TSI,TS,F_drag:kN,Drag force,kN
TSI,TS,Fr:-,Froude number,-
TSI,TS,v_tsi:m/s,Tsunami velocity,m/s
TSI,TS,F_QS:kN,Quasi-steady force,kN
TSI,TS,MF:m3/s2,Momentum flux,m3/s2
TSI,TS,h_tsi:m,Tsunami wave height,m
TSI,TS,Fh_tsi:m,Tsunami Horizontal Force,kN
VAF,VO,h_vaf:m,Ash fall thickness,m
VAF,VO,L_vaf:kg/m2,Ash loading,kg/m2
FSS,CF,v_fss:m/s,Maximum water velocity,m/s
FSS,CF,d_fss:m,Storm surge inundation depth,m
DTA,DR,CMI:-,Crop Moisture Index,-
DTM,DR,PDSI:-,Palmer Drought Severity Index,-
DTM,DR,SPI:-,Standard Precipitation Index,-
\.

COMMIT;

--------------------------------------------------------
--  DDL for Package PK_FIS_HACIENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_FIS_HACIENDA" authid current_user IS
  PROCEDURE carga ( pinicio  IN NUMBER, --YYYYMM
		  		  pfinal   IN NUMBER, --YYYYMM
				  ppetici  IN NUMBER, -- 1->Pagos,2->Cobros,3->Dos,4->347,5->345
				  pcpagcob IN NUMBER, -- 1->Cobros, 2->Pagos
 				  pempres  IN NUMBER,
				  pnumpet  OUT NUMBER);

  PROCEDURE carga_aporta_347   ( pcramo   IN NUMBER,
  							     pcmodali IN NUMBER,
								 pctipseg IN NUMBER,
								 pccolect IN NUMBER,
								 pinicio  IN DATE,
								 pfinal   IN DATE,
								 psfiscab IN NUMBER,
								 pnumpet  IN NUMBER,
			 					 pempres  IN NUMBER,
								 preprese IN NUMBER);

  PROCEDURE carga_aporta_345   ( pcramo   IN NUMBER,
  							     pcmodali IN NUMBER,
								 pctipseg IN NUMBER,
								 pccolect IN NUMBER,
								 pinicio  IN DATE,
								 pfinal   IN DATE,
								 psfiscab IN NUMBER,
								 pnumpet  IN NUMBER,
			 					 pempres  IN NUMBER,
								 preprese IN NUMBER);

  PROCEDURE carga_rentas		(pcramo   IN NUMBER,
  							  	 pcmodali IN NUMBER,
							  	 pctipseg IN NUMBER,
							  	 pccolect IN NUMBER,
							  	 pinicio  IN DATE,
							  	 pfinal   IN DATE,
								 psfiscab IN NUMBER,
							  	 pnumpet  IN NUMBER, -- Nro. de Petición
		 					  	 pempres  IN NUMBER,
							  	 preprese IN NUMBER);-- Póliza con representante

  PROCEDURE carga_prestaciones  (pcramo   IN NUMBER,
		  					   	 pcmodali IN NUMBER,
						 	   	 pctipseg IN NUMBER,
						 	   	 pccolect IN NUMBER,
						 	   	 pinicio  IN DATE,
						 	   	 pfinal   IN DATE,
								 psfiscab IN NUMBER,
						 	   	 pnumpet  IN NUMBER, -- Nro. de Petición
			 					 pempres  IN NUMBER,
                         	   	 preprese IN NUMBER);-- Póliza con representante

  PROCEDURE carga_siniestros   	(pcramo   IN NUMBER,
  							   	 pcmodali IN NUMBER,
								 pctipseg IN NUMBER,
								 pccolect IN NUMBER,
								 pinicio  IN DATE,
								 pfinal   IN DATE,
								 psfiscab IN NUMBER,
								 pnumpet  IN NUMBER, -- Nro. de Petición
			 					 pempres  IN NUMBER,
								 preprese IN NUMBER);-- Póliza con representante

  PROCEDURE carga_vencimientos  (pcramo   IN NUMBER,
  							   	 pcmodali IN NUMBER,
								 pctipseg IN NUMBER,
								 pccolect IN NUMBER,
								 pinicio  IN DATE,
								 pfinal   IN DATE,
								 psfiscab IN NUMBER,
								 pnumpet  IN NUMBER, -- Nro. de Petición
			 					 pempres  IN NUMBER,
								 preprese IN NUMBER);-- Póliza con representante

  FUNCTION f_busca_num		    (psfiscab IN NUMBER,
  		   					   	 pnnumord OUT NUMBER)
    RETURN NUMBER;

  FUNCTION f_datos_personales   (psperson IN NUMBER,
  		   					     pnnumnif OUT VARCHAR2,
								 ptidenti OUT NUMBER,
								 pcpais   OUT NUMBER)
    RETURN NUMBER;

  FUNCTION GRABA_ERROR  (PSFISCAB IN NUMBER,
                         PNUMERR  IN NUMBER,
                         PSPERSON IN NUMBER,
                         PSSEGURO IN NUMBER,
                         PCIDIOMA IN NUMBER,
					     PNDOCUM  IN NUMBER,
					     PTIPO    IN NUMBER,
						 PNUMORD OUT NUMBER)
    RETURN NUMBER;


  FUNCTION dni_pos 				(numnif IN VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION f_validar_pagos 	  	(psfiscab   IN NUMBER,
 					 			 pcidioma   IN NUMBER,
					 			 pnumerr    OUT NUMBER)
    RETURN NUMBER;

  FUNCTION f_validar_cobros	  	(psfiscab   IN NUMBER,
 					 			 pcidioma   IN NUMBER,
					 			 pnumerr    OUT NUMBER)
    RETURN NUMBER;

  PROCEDURE carga_fis_irpf     ( psseguro IN NUMBER,
                                 psperson IN NUMBER,
                                 pANYO    IN NUMBER,
                                 psfiscab IN NUMBER,
                                 pnnumord IN OUT NUMBER);

END Pk_Fis_Hacienda;
 
 

/

  GRANT EXECUTE ON "AXIS"."PK_FIS_HACIENDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FIS_HACIENDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FIS_HACIENDA" TO "PROGRAMADORESCSI";

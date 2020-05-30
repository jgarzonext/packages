--------------------------------------------------------
--  DDL for Package Body AUTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."AUTOM" AS

 PROCEDURE inicio(nempresa IN NUMBER,
                  ano_proc IN NUMBER,
                  mes_proc IN NUMBER,
                  tipo_proc IN VARCHAR2)
  IS
  mesant      NUMBER;
  anoant      NUMBER;
 BEGIN
    autom.n_empresa := nempresa;
    autom.aaproc := ano_proc;
    autom.mmproc := mes_proc;
    anoant := ano_proc;
    mesant := mes_proc;
    autom.tip_proc := tipo_proc;
    autom.actualizar := TRUE;
    autom.cerrado := TRUE;
    autom.EOF := FALSE;
	long_grabada := 0;
	empresas     := 0;
	segmentos    := 0;
END inicio;

END autom;

/

  GRANT EXECUTE ON "AXIS"."AUTOM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."AUTOM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."AUTOM" TO "PROGRAMADORESCSI";

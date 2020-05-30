--------------------------------------------------------
--  DDL for Package PAC_VENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VENTAS" authid current_user IS
procedure PROCESO_BATCH_CIERRE(pmodo IN NUMBER,     pcempres IN NUMBER, pmoneda IN NUMBER,
                               pcidioma IN NUMBER,  pfperfin IN DATE,   pcerror OUT NUMBER,
                               psproces OUT NUMBER, pfproces OUT DATE);
function FECHA_CALCULO(pcempres IN NUMBER, pmodo IN NUMBER,pfcierre OUT DATE,pnmesven OUT NUMBER,
                       pnanyven OUT NUMBER)
         RETURN number;
function TRASPASO_A_HISVENTAS(psproces IN NUMBER, pcempres IN NUMBER,text_error OUT VARCHAR2)
         RETURN NUMBER;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_VENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VENTAS" TO "PROGRAMADORESCSI";

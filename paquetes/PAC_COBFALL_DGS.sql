--------------------------------------------------------
--  DDL for Package PAC_COBFALL_DGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_COBFALL_DGS" 
IS
   /*
   DESCR: Crea fitxer XML per enviar
   AUTOR: ATS5656
   FECHA: 16/05/2007
   */
   PROCEDURE p_enviar_fichero (
      fecha_ini    IN       DATE,
      fecha_fin   IN       DATE,
      pfichhost   IN       VARCHAR2,
      pfichext    IN       VARCHAR2,
      pnomfich    OUT      VARCHAR2,
      pproces     OUT      NUMBER
   );
   /*
   DESCR: Guarda el moviments per ser enviat
   AUTOR: ATS5656
   FECHA: 16/05/2007
   */
   PROCEDURE p_grabar_movimiento (psseguro IN NUMBER, pfefecto IN DATE, pcmotmov IN NUMBER);
END pac_cobfall_dgs;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_COBFALL_DGS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COBFALL_DGS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COBFALL_DGS" TO "PROGRAMADORESCSI";

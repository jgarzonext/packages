--------------------------------------------------------
--  DDL for Package PAC_FISC_PP_2007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FISC_PP_2007" 
AS
  fecha_ini_fisc DATE := TO_DATE ('20070101', 'YYYYMMDD');

  FUNCTION f_part_pres (
   psseguro       IN       NUMBER,
   pfcontig          IN       DATE,
   pnparant2007   OUT      NUMBER,
   pnparpos2006   OUT      NUMBER,
   pnparret          OUT       NUMBER,
   pcerror        OUT      NUMBER,
   plerror          OUT        VARCHAR2
   )
   RETURN NUMBER;

  FUNCTION f_part_tras (
   psseguro       IN       NUMBER,
   pnparant2007   OUT      NUMBER,
   pnparpos2006   OUT      NUMBER,
   pcerror          OUT        NUMBER,
   plerror          OUT       VARCHAR2
)
   RETURN NUMBER;

END pac_fisc_pp_2007;

/

  GRANT EXECUTE ON "AXIS"."PAC_FISC_PP_2007" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FISC_PP_2007" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FISC_PP_2007" TO "PROGRAMADORESCSI";

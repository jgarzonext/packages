--------------------------------------------------------
--  DDL for Package PAC_PPA_PLANES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PPA_PLANES" AUTHID CURRENT_USER IS
/****************************************************************************

   NOMBRE:       PAC_PPA_PLANES
   PROPÓSITO:  Funciones para PPA Planes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        20/04/2009   APD              Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
   3.0        28/04/2009   DCT              1-Modificación f_pargaranpro. Bug:0009783
   4.0         21/07/2009   jgm        fUNCIONS PER AL CALCUL DE ppaS

****************************************************************************/
   FUNCTION primas_pendientes_emitir(
      anyo NUMBER,
      modo NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION importe_recibos_pendientes(
      anyo NUMBER,
      modo NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION primas_permitidas(
      anyo NUMBER,
      psperson IN NUMBER,
      prima_periodo IN NUMBER,
      prima_extr IN NUMBER,
      pcforpag IN NUMBER,
      pmodo IN VARCHAR2,
      pfcarpro IN DATE,
      pfefecto IN DATE,
      pnrenova IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_fcarpro(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pnrenova IN NUMBER,
      pfefecto IN DATE)
      RETURN DATE;

   FUNCTION ff_limite_aportaciones(anyo IN NUMBER, pctipapor IN NUMBER, pedad IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_tipo_participe(psperson IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_tipo_aportante(psperson IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION calcula_importe_anual_persona(
      anyo NUMBER,
      modo NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   FUNCTION calcula_importe_maximo_persona(
      anyo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   FUNCTION ff_importe_por_aportar_persona(
      anyo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   FUNCTION calcula_importe_anual_poliza(
      anyo NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   FUNCTION calcula_importe_maximo_poliza(
      anyo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   FUNCTION ff_importe_por_aportar_poliza(
      anyo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      porigen IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   FUNCTION calcula_imp_maximo_simulacion(
      anyo IN NUMBER,
      pfnacimi IN DATE,
      pctipapor IN NUMBER)
      RETURN NUMBER;

   -- RSC 21/01/2008
   FUNCTION ff_total_aportaciones_per(
      psseguro IN NUMBER,
      pfechaini IN NUMBER,
      pfechafin IN NUMBER)
      RETURN NUMBER;

   -- RSC 21/01/2008
   FUNCTION ff_total_prestaciones_per(
      psseguro IN NUMBER,
      pfechaini IN NUMBER,
      pfechafin IN NUMBER)
      RETURN NUMBER;

   -- RSC 21/01/2008
   FUNCTION ff_total_traspasoentrada_per(
      psseguro IN NUMBER,
      pfechaini IN NUMBER,
      pfechafin IN NUMBER)
      RETURN NUMBER;

   -- RSC 21/01/2008
   FUNCTION ff_total_traspasosalida_per(
      psseguro IN NUMBER,
      pfechaini IN NUMBER,
      pfechafin IN NUMBER)
      RETURN NUMBER;

-----------------------------------------------------------------------------------------------
-- BUG 0010132 - 21/07/2009 - jgarciam - fUNCIONS PER AL CALCUL DE ppaS
-----------------------------------------------------------------------------------------------
/*************************************************************************
    FUNCTION ff_total_retenc_per
    Función que retornará El TOTAL RETENCIO
PSSEGURO IN NUMBER
PFECHAINI in date
pfechafin IN DATE
    return             : Devolverá una numérico con el TOTAL
*************************************************************************/
   FUNCTION ff_total_retenc_per(psseguro IN NUMBER, pfechaini IN NUMBER, pfechafin IN NUMBER)
      RETURN NUMBER;

   -- RSC 21/07/2009
   /*************************************************************************
       FUNCTION ff_total_REDUC_per
       Función que retornará El TOTAL REduccio
   PSSEGURO IN NUMBER
   PFECHAINI in date
   pfechafin IN DATE
       return             : Devolverá una numérico con el TOTAL
   *************************************************************************/
   FUNCTION ff_total_reduc_per(psseguro IN NUMBER, pfechaini IN NUMBER, pfechafin IN NUMBER)
      RETURN NUMBER;
-----------------------------------------------------------------------------------------------
-- fi BUG 0010132 - 21/07/2009 - jgarciam - fUNCIONS PER AL CALCUL DE ppaS
-----------------------------------------------------------------------------------------------
END pac_ppa_planes;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PPA_PLANES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PPA_PLANES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PPA_PLANES" TO "PROGRAMADORESCSI";

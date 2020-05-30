--------------------------------------------------------
--  DDL for Package PAC_FRM_ACTUARIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FRM_ACTUARIAL" AUTHID CURRENT_USER IS
     /******************************************************************************
      NOMBRE:     PAC_FRM_ACTUARIAL
      PROPÓSITO:  Funciones para el cálculo actuarial

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        01/02/2009   JRH                2. Bug-8782 Revisión cálculo capital garantizado en productos de Ahorro
   ******************************************************************************/
   fin_morta CONSTANT NUMBER := 126;
   maxtaula CONSTANT NUMBER := 127;
   m_1div2m CONSTANT NUMBER := 11 / 24;

   FUNCTION ff_lx(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      p_es_mensual IN NUMBER)
      RETURN NUMBER;

  /************************************************************************************
 Con la progresión
**************************************************************************************/
   FUNCTION ff_axprog2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      mes IN NUMBER,
      pedadini IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER;

   FUNCTION ff_axyprog_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      pfracc IN NUMBER DEFAULT 12,
      pedadini IN NUMBER,
      pedadini2 IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      prever IN NUMBER DEFAULT 100,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER;

   FUNCTION ff_a2prog_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      pfracc IN NUMBER DEFAULT 12,
      pedadini IN NUMBER,
      pedadini2 IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      prever IN NUMBER DEFAULT 100,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER;

   FUNCTION ff_aprog2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      mes IN NUMBER,
      pedadini IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0,
      desdeinicio IN BOOLEAN DEFAULT TRUE)
      RETURN NUMBER;

   FUNCTION f_morta_mes(
      nsesion IN NUMBER DEFAULT 1,
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnacim IN NUMBER)
      RETURN NUMBER;

 /************************************************************************************
**************************************************************************************/
   FUNCTION ff_a(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_a2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_a_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_ax(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_axy(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_axy_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfracc IN NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0,
      prever IN NUMBER DEFAULT 100)
      RETURN NUMBER;

   FUNCTION ff_axy_rever(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pvmin IN NUMBER,
      prever IN NUMBER,
      preval IN NUMBER DEFAULT 0,
      pfracc IN NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_ex(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfrac NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_factorprovi(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pro IN NUMBER,
      preserva IN NUMBER,
      pgastos IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_factorgaran(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pro IN NUMBER,
      preserva IN NUMBER,
      pgastos IN NUMBER,
      pv_e IN NUMBER,
      nitera IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

 /**************************************************************************************************
AQUI EMPIEZA RP JRH 01/2008
**************************************************************************************************/
   FUNCTION ff_exy(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfrac NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_exy_cab(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfrac NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_ax2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_axy2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      mes IN NUMBER,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION ff_axy_cab2(
      psesion IN NUMBER,
      ptabla IN NUMBER,
      psexo IN NUMBER,
      pedad IN NUMBER,
      psexo2 IN NUMBER,
      pedad2 IN NUMBER,
      pduraci IN NUMBER,
      pv IN NUMBER,
      pfracc IN NUMBER DEFAULT 12,
      p_es_mensual IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_cpg_ppj(sesion IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_progacumnat(
      psesion IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      nduraci IN NUMBER,
      mesini IN NUMBER DEFAULT 0,
      p_es_mensual IN NUMBER DEFAULT 0,
      esahorr NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION ff_progresionnat(
      psesion IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      nduraci IN NUMBER,
      mesini IN NUMBER DEFAULT 0,
      p_es_mensual IN NUMBER DEFAULT 0,
      esahorr NUMBER DEFAULT 1)
      RETURN NUMBER;

   /*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      Nos indica el tipo de efecto.
      return             : Tipo efecto
   *************************************************************************/
   FUNCTION pctipefe(psesion IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      Nos indica el si es ahorro
      return             : 1 si es ahorro 0 si no
   *************************************************************************/
   FUNCTION pesahorr(psesion IN NUMBER)
      RETURN NUMBER;
END pac_frm_actuarial;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_FRM_ACTUARIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FRM_ACTUARIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FRM_ACTUARIAL" TO "PROGRAMADORESCSI";

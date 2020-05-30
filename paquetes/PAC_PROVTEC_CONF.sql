--------------------------------------------------------
--  DDL for Package PAC_PROVTEC_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVTEC_CONF" IS
/****************************************************************************
   NOMBRE:       pac_provtec_conf
   PROPÓSITO:    Agrupa las funciones que calculan las provisiones técnicas de Confianza

   REVISIONES:
   Ver   Fecha       Autor  Descripción
   ----- ----------  -----  ------------------------------------------------
   1.0   10/11/2016  ERH    CONF-469 - Parametrizacion Cierres - Administracion y Finanzas - Creación del package
   1.1   27/10/2017  AAB    CONF-403 - Se adiciona en el proceso batch cierre el llamdo a la funcion
                                       pac_contab_conf.f_importe_provision para que realice el insert a las tablas
                                       resumen de provisiones.
****************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   FUNCTION f_commit_calcul_upr(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   /*
   FUNCTION f_commit_calcul_pplp(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;
   */
   FUNCTION f_commit_calcul_pppc(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;


   FUNCTION f_commit_calcul_pppc_pd(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R',
      pmetodo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_commit_calcul_pppc_oct(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;


   FUNCTION f_commit_calcul_rtpi(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   -- Bug 0022072 - 30/04/2012 - JMF
   FUNCTION f_commit_calcul_amocom(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   FUNCTION f_commit_calcul_ibnr(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

      FUNCTION f_commit_calcul_tasabomberil(
      pcempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R',
	  pfcierre IN DATE)
      RETURN NUMBER;


   -- BUG 27305 - MDS - 20/03/2014
   PROCEDURE p_calculo_diario_iprovres(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   -- BUG 27305 - MDS - 21/03/2014
   PROCEDURE p_calculo_cierre_iprovres(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pfecha IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVTEC_CONF" TO "PROGRAMADORESCSI";

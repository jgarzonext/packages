--------------------------------------------------------
--  DDL for Package PAC_REASEGURO_XL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REASEGURO_XL" AS
   /******************************************************************************
    NOMBRE:      PAC_REASEGURO_XL
    PROPÓSITO:   Proceso batch mensual que realiza liquidación al Reaseguro XL

    REVISIONES:
    Ver  Fecha       Autor  Descripción
    ---  ----------  -----  ------------------------------------
    1.0  --/--/----  ---    1. Creación del package.
    2.0  01/12/2011  JGR    2. 0020023: Reaseguro XL
    3.0  28/06/2013  KBR    3. 0022678: LCOL_A002-Qtracker: Gestión de contratos XL por Eventos.
    4.0  12/11/2013  KBR    4. 0027683: LCOL_A004-Qtracker: 8622 (9207, 9272): Cesion siniestro contrato no proporcional por evento XL
    5.0  09/12/2013  KBR    5. 0028991: (POSPG400)-Parametrizaci??e los siniestros en C??o.
    6.0  10/03/2014  KBR    6. 0026663: 0028991: (POSPG400)-Parametrizacion - Multitramos y Reinstalamientos
    7.0  13/06/2014  AGG    7. 0031306: POSDE400-Id 80 - Bono por no reclamaci??   8.0  25/05/2015  CJMR   8. 0033158: Actualización campo CCORRED en los cierres de Reaseguro
   ******************************************************************************/

   /*Autor: KBR
     Fech : 11/12/2013
     Estructura de datos para Siniestros (XL por Eventos)
     */
   CURSOR c_reg IS
      SELECT '                    ' AS cevento, 0 AS scumulo, 0 AS sproduc, 0 AS scontra,
             0 AS nversio, 0 ccompapr, 0 AS ctramo, 0 cgarant, 0 AS pago_total_sin,
             0 AS reserva_total_sin, 0 AS pago_total, 0 AS reserva_total, 0 AS nsinies,
             f_sysdate AS fsinies
        FROM DUAL;

   vpar_traza     VARCHAR2(80) := 'TRAZA_REA_XL';

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

   FUNCTION llena_liquidaxl_aux(
      pcempres IN NUMBER,
      pdefi IN NUMBER,
      pipc IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pfcierre IN DATE,   --AVT afegit pfcierre 01/06/2001
      pproces IN NUMBER,
      psql OUT VARCHAR2,
      pscesrea OUT NUMBER,
      pfperini IN DATE,   -- 0021411 - 22-02-2012 - JMF
      pfperfin IN DATE)   -- AVT canvi pfcierre -> pfperfin 01/06/2001
      RETURN NUMBER;

   FUNCTION llenar_tablas_defi(
      psql OUT VARCHAR2,
      pscesrea OUT NUMBER,
      pcempres IN NUMBER,
      pfperfin IN DATE)   -- AVT canvi pfcierre -> pfperfin 01/06/2001
      RETURN NUMBER;

   FUNCTION f_xl_siniestros(
      p_pcempres IN NUMBER,
      p_pdefi IN NUMBER,
      p_pipc IN NUMBER,
      p_pmes IN NUMBER,
      p_pany IN NUMBER,
      p_pfcierre IN DATE,
      p_pproces IN NUMBER,
      p_pscesrea OUT NUMBER,
      p_pfperini IN DATE,
      p_pfperfin IN DATE,
      o_plsql OUT VARCHAR2)
      RETURN NUMBER;

   /*
   Funci??Registra en MOVCTAAUX apuntes para diferentes conceptos del Reaseguro XL
   Fecha: 11/12/2013
   Autor: KBR
   Param. Entrada: p_ctadet =Param. de empresa que indica si se debe registrar detalle de siniestros
                   p_movsin =Estructura que contiene los datos del siniestro-evento
                   p_nnumlin=Nro. de l?a a insertar para el movimiento
                   p_concept=Nro. de concepto para el movimiento
                   p_import =Import del concepto
   */
   FUNCTION f_insertxl_movctatecnica(
      p_ctadet IN NUMBER,
      p_movsin IN c_reg%ROWTYPE,
      p_nnumlin IN NUMBER,
      p_concept IN NUMBER,
      p_cia IN NUMBER,
      p_import IN NUMBER,
      p_pproces IN NUMBER,
      p_cestado IN NUMBER,
      p_pcempres IN NUMBER,
      p_pcierre IN DATE,
      p_ccorred IN NUMBER)   -- 25/05/2015  CJMR  0033158: Actualización campo CCORRED en los cierres de Reaseguro
      RETURN NUMBER;

   FUNCTION f_xl_eventos(
      p_pcempres IN NUMBER,
      p_pdefi IN NUMBER,
      p_pipc IN NUMBER,
      p_pmes IN NUMBER,
      p_pany IN NUMBER,
      p_pfcierre IN DATE,
      p_pproces IN NUMBER,
      p_pscesrea OUT NUMBER,
      p_pfperini IN DATE,
      p_pfperfin IN DATE,
      o_plsql OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_insertar_pmd(
      p_pcempres IN NUMBER,
      p_pmes IN NUMBER,
      p_pproces IN NUMBER,
      p_pfperfin IN DATE,
      p_psql OUT VARCHAR2)
      RETURN NUMBER;

--bug 25860/149606 ETM 24/07/202013 INI---------------
/***********************************************************************************************
    Nova funci??    Funcio que retorna el % de tasa variable
    Parametres: pcempres, ctramotasa_, v_siniestralitat
    Sortida:w_ptasa

******************************************************************************************** */
   FUNCTION f_tasa_variable(
      pcempres IN NUMBER,
      pctasa IN NUMBER,
      psinies IN NUMBER,
      ptasa OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_prima_anual_reten(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pfperfin IN DATE,
      pccompani IN NUMBER,
      pctramo IN NUMBER DEFAULT NULL,
      pcramo IN NUMBER DEFAULT NULL,
      panuret OUT VARCHAR2)
      RETURN NUMBER;

--FIN bug 25860/149606 ETM 24/07/202013 ---------------
   FUNCTION f_insertar_bononr(
      ppsiniestralidad IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfperfin IN DATE,
      pccompani IN NUMBER,
      pcempres IN NUMBER,
      pproces IN NUMBER,
      pprimanetavg IN NUMBER,
      pprimanetavi IN NUMBER,
      pprimanetaap IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_saldo(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      psproces IN NUMBER,
      pstiporea IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   --CONFCC-5 Inicio
   FUNCTION f_costos_contrato(p_scontra      IN  NUMBER,
                              p_nversio      IN  NUMBER,
                              p_ctramo       IN  NUMBER,
                              p_ccompani     IN  NUMBER,
                              p_fecmov       IN  DATE)
   RETURN NUMBER;

   FUNCTION f_ajuste_contrato(p_scontra      IN  NUMBER,
                              p_nversio      IN  NUMBER,
                              p_ctramo       IN  NUMBER,
                              p_ccompani     IN  NUMBER,
                              p_fcierre      IN  DATE)
   RETURN NUMBER;

   FUNCTION f_calcula_ajustes(p_cempres      IN  NUMBER,
                              p_sproces      IN  NUMBER,
                              p_fperfin      IN  DATE)
   RETURN NUMBER;
   --CONFCC-5 Fin

END pac_reaseguro_xl;

/

  GRANT EXECUTE ON "AXIS"."PAC_REASEGURO_XL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REASEGURO_XL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REASEGURO_XL" TO "PROGRAMADORESCSI";

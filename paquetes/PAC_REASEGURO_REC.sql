--------------------------------------------------------
--  DDL for Package PAC_REASEGURO_REC
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PAC_REASEGURO_REC" 
/******************************************************************************
   NOMBRE:     pac_reaseguro_rec
   PROPOSITO:     Proceso batch mensual que realiza el Bordero de Reaseguro

   REVISIONES:
   Ver        Fecha        Autor             Descripcion
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creacion del package.
   2.0        07/09/2009   FAL                2. Bug 11051: CRE - Pagos sin cesiones. Creacion p_genera_ces_pago y f_genera_ces_pago para
                                                 generar cesion de pagos de siniestros.
   3.0        05/10/2009   FAL                3. Bug 11350: CRE - La tabla LIQRESREAAUX contemplara provision aunque el pago este creado. Se incluye f_reamovpagos
   4.0        04/04/2012   JMP                4. Bug 20836/111077: CRE800: Error cessions reemborsaments
   5.0        01/08/2012   AVT                5. 022799: AGM800-Cuenta tecnica del reaseguro
   6.0        22/05/2020   MPC                6. IAXIS-13164: Proceso para llenado de tabla LIQRESREAAUXDET.
******************************************************************************/
IS
-------------------------------------------------------------------
-- Nova versio de tancament de la Reasseguranca per detall de
-- rebut o periode (reasegemi, detreasegemi)
-------------------------------------------------------------------
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

    FUNCTION f_llenar_readeposito_aux(
    PCEMPRES IN NUMBER,
    PPROCES IN NUMBER)
    RETURN NUMBER;

   FUNCTION llenar_bordero_aux(
      pcempres IN NUMBER,
      pdefi IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pfcierre IN DATE,
      pproces IN NUMBER,
      psql OUT VARCHAR2,
      pscesrea OUT NUMBER,
      pfperfin IN DATE)
      RETURN NUMBER;

   FUNCTION llenar_tablas_defi(
      psql OUT VARCHAR2,
      pscesrea OUT NUMBER,
      pcempres IN NUMBER,
      pfperfin IN DATE)
      RETURN NUMBER;

   FUNCTION actu_dates(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pfcierre IN DATE,
      psql OUT VARCHAR2,
      pscesrea OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_buscomgarant(
      pscomrea IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      ppcomias OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_calcul_pb(pmodo IN NUMBER, pcempres IN NUMBER, pfperfin IN DATE, pany IN NUMBER, psproces IN NUMBER)
      RETURN NUMBER;

------------------
   FUNCTION f_liquidaresreas(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pffin IN DATE,
      pexperr IN OUT VARCHAR2,     --BUG 13164 22/05/2020 MPC Se CMODO = 3 Solo Llena tabla detalle ó CMODO = 0 continua proceso normal
      pcmodo  IN NUMBER DEFAULT 0) --BUG 13164 22/05/2020 MPC Se CMODO = 3 Solo Llena tabla detalle ó CMODO = 0 continua proceso normal
      RETURN NUMBER;

-- Omple la taula de reserves de sinistres del reass.
-- Es crida desde f_reserves_sini
------------------
   FUNCTION f_reserves_sini(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfcierre IN DATE,
      pcidioma IN NUMBER,           --BUG 13164 22/05/2020 MPC Se CMODO = 3 Solo Llena tabla detalle ó CMODO = 0 continua proceso normal
      pcmodo   IN NUMBER DEFAULT 0) --BUG 13164 22/05/2020 MPC Se CMODO = 3 Solo Llena tabla detalle ó CMODO = 0 continua proceso normal
      RETURN NUMBER;

-------
-- Reserves de sinistres a carrec dels reasseguradors
-------

   -- BUG 11051 - 07/09/2009 - FAL - Creacion p_genera_ces_pago y f_genera_ces_pago para generar cesion de pagos de siniestros
   /*************************************************************************
      Recupera los pagos de siniestros para generar la cesion
      param in pcempres   : codigo empresa
      param in pnsinies   : codigo siniestro
      param in pnpoliza   : codigo poliza
      param in psproces   : codigo proceso cierre reaseguro
      param in pcidioma   : codigo idioma
      param in pfcierre   : fecha cierre
   *************************************************************************/
   PROCEDURE p_genera_ces_pago(
      pcempres IN NUMBER,
      pnsinies IN NUMBER,
      pnpoliza IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE);

   /*************************************************************************
      Genera la cesion de los pagos de siniestros
      param in pnsinies   : codigo siniestro
      param in psidepag   : codigo pago siniestro
      param in pcgarant   : codigo garantia
      param in pfefepag   : fecha efecto pago
      param in pisinret   : importe siniestro
      param in pscontra   : codigo contrato
      param in pnversio   : codigo version
      param in psproces   : codigo proceso
      param in pcidioma   : codigo idioma
      param in pfcierre   : fecha cierre
   *************************************************************************/
   FUNCTION f_genera_ces_pago(
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      pcgarant IN NUMBER,
      pfefepag IN DATE,
      pisinret IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE)
      RETURN NUMBER;

-- FI Bug 11051 - 07/09/2009 - FAL

   -- BUG 11350 - 05/10/2009 - FAL - Creacio funcio f_reamovpagos que realitzara el calcul de reserves a nivell de pagament per aquells pagos encara pendents
   /*************************************************************************
      Realitza el calcul de reserves a nivell de pagament per aquells pagos encara pendents
      param in psproces   : codigo proceso
      param in pcempres   : codigo empresa
      param in pffin      : fecha fin orden de pago
      param in pexperr    : descripcion del error
   *************************************************************************/
   FUNCTION f_reamovpagos(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pffin IN DATE,
      pexperr OUT VARCHAR2)
      RETURN NUMBER;

-- FI Bug 11350 - 05/10/2009 - FAL
   -- BUG 20836/111077 - 04/04/2012 - JMP - CRE800: Error cessions reemborsaments
   /*************************************************************************
      Crea les cessions dels reemborsaments en base a les cessions existents.
      param in pnreemb     : Num. de reemborsament
      param in pnfact      : Num. de factura intern
      param in pnlinea     : Num. de linia
      param in psseguro    : Id. de seguro
      param in pcgarant    : Codi de garantia
      param in pnriesgo    : Num. de risc
      param in pfefecto    : Data d'efecte
      param in pipago      : Import a pagar (acceptat)
      param in pscontra    : Id. de contracte
      param in pnversio    : Versio del contracte
      param in pfcierre    : Data de tancament
      param in psproces    : Id. del proces
      param in pcidioma    : Codi idioma
      retorna              : 0 ok; 1 ko
   *************************************************************************/
   FUNCTION f_genera_ces_reemb(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pnlinea IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pipago IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pfcierre IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      En base als reemborsaments sense cessio, busca el contracte que li
      correspon segons data d'efecte i crida a la generacio de les cessions.
      param in pcempres   : codigo empresa
      param in pnpoliza   : codigo poliza
      param in pnreemb    : numero de reembolso
      param in psproces   : codigo proceso cierre reaseguro
      param in pcidioma   : codigo idioma
      param in pfcierre   : fecha cierre
   *************************************************************************/
   PROCEDURE p_genera_ces_reemb(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pnreemb IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE);

-- FI BUG 20836/111077 - 04/04/2012 - JMP - CRE800: Error cessions reemborsaments

   -- 22799 AVT 01/08/2012  AGM TREU EL C?LCUL DE RESERVES DEL TANCMENT PER FER-LO POST PPNC
   FUNCTION f_diposit_ppnc_rea(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      pproces IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************************************
        Nova funció:
        Funcio que retorna el % de comisión escalonada
        Parametres: pcempres, cia.comis_rea, v_siniestralitat
        Sortida:w_pcomias

        22/01/2013   AVT     0024998: MDP_T003-Comisiones Escalonadas
     ******************************************************************************************** */--bug 25860 ETM 08/04/202013 INI---------------
   FUNCTION f_com_escalonada(
      pcempres IN NUMBER,
      pccomis IN NUMBER,
      psinies IN NUMBER,
      pcomias OUT VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************************************
        Funcio que retorna el nº de una línea
        Parametres: p_scontra, p_nversio, p_ctramo, p_ccompani, p_error
        Sortida: nº de línea

        24/03/2014   AGG
     ********************************************************************************************  */
   FUNCTION f_obtener_numlin(
      p_scontra IN NUMBER,
      p_nversio IN NUMBER,
      p_ctramo IN NUMBER,
      p_ccompani IN NUMBER,
      p_error OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************************************
        Función que inserta un saldo en movctatecnica
        Parametros: pcempres, pmes, panu, psproces
        Sortida:w_pcomias

        24/03/2014   AGG
     ********************************************************************************************  */
   FUNCTION f_insert_saldo(
      pcempres IN NUMBER,
      pmes IN NUMBER,
      pany IN NUMBER,
      psproces IN NUMBER,
      pstiporea IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   /***********************************************************************************************
        Procedimiento que calcula la reexpresion de saldos

   ********************************************************************************************  */
   PROCEDURE p_reexpresion(p_cempres      IN  NUMBER,
                           p_sproces      IN  NUMBER,
                           p_sseguro      IN  NUMBER,
                           p_fecreex      IN  DATE,
                           p_scontra      IN  NUMBER,
                           p_ccompani     IN  NUMBER,
                           p_nversio      IN  NUMBER,
                           p_ctramo       IN  NUMBER,
                           p_sproduc      IN  NUMBER,
                           p_nmovimi      IN  NUMBER,
                           p_tipo         IN  NUMBER,
                           p_tipo_reexp   IN  NUMBER,
                           p_importe      IN  NUMBER,
                           p_imp_comision IN  NUMBER,
                           p_sfacult      IN  NUMBER,
                           p_nsinies      IN  NUMBER,
                           p_error        OUT NUMBER);

   /***********************************************************************************************
        Procedimiento que reexpresa saldos totales de cierres anteriores

   ********************************************************************************************  */
   PROCEDURE p_reexpresion_totales(p_cempres      IN  NUMBER,
                                   p_sproces      IN  NUMBER,
                                   p_fecreex      IN  DATE,
                                   p_tipo         IN  NUMBER,
                                   p_error        OUT NUMBER);

   /***********************************************************************************************
        Procedimiento que reexpresa saldos totales de cierres anteriores

   ********************************************************************************************  */
   PROCEDURE p_reexpresion_principal(p_cempres      IN  NUMBER,
                                     p_sproces      IN  NUMBER,
                                     p_fecreex      IN  DATE,
                                     p_error        OUT NUMBER);

   /***********************************************************************************************
        Función que indica si una Compañía reaseguradora se encuentra en Cut-Off

   ********************************************************************************************  */
   FUNCTION f_compania_cutoff(p_ccompani     IN  NUMBER,
                              p_fecmov       IN  DATE) RETURN NUMBER;

   /***********************************************************************************************
        Función que devuelve el valor total cedido (100%) de acuerdo a las compañías en CutOff

   ********************************************************************************************  */
   FUNCTION f_total_concutoff(p_scontra      IN  NUMBER,
                              p_nversio      IN  NUMBER,
                              p_ctramo       IN  NUMBER,
                              p_fecmov       IN  DATE,
                              p_valor        IN  NUMBER,
                              p_error        OUT NUMBER)
   RETURN NUMBER;

   --CONFCC-5
   /***********************************************************************************************
        Función que indica si una Compañia reaseguradora está excenta de retención (CERTIFICADO DE RESIDENCIA FISCAL)

   ********************************************************************************************  */
   FUNCTION f_compania_exenta(p_ccompani     IN  NUMBER,
                              p_fecmov       IN  DATE) RETURN NUMBER;

   /***********************************************************************************************
        Procedimiento que calcula la retención y devuelve tanto el valor total, como el retenido

   ********************************************************************************************  */
   PROCEDURE p_calcula_retencion(p_cempres      IN  NUMBER,
                                 p_sseguro      IN  NUMBER,
                                 p_cgenera      IN  NUMBER,
                                 p_ccompani     IN  NUMBER,
                                 p_fecmov       IN  DATE,
                                 p_valor        IN  NUMBER,
                                 p_valret       OUT NUMBER,
                                 p_error        OUT NUMBER);
   --
   --INI BUG 13164 22/05/2020 MPC Se adiciona procedimiento para llenado de tabla nueva de detalle
   PROCEDURE p_ins_liqresreaauxdet;
   --
   FUNCTION f_ext_sintramitareservadet(psproces IN NUMBER,
                                      pcempres IN NUMBER,
                                      pffin    IN DATE,
                                      pnsinies IN NUMBER DEFAULT NULL,
                                      pbandera IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   --FIN BUG 13164 22/05/2020 MPC Se adiciona procedimiento para llenado de tabla nueva de detalle
END pac_reaseguro_rec;

/

  GRANT EXECUTE ON "AXIS"."PAC_REASEGURO_REC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REASEGURO_REC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REASEGURO_REC" TO "PROGRAMADORESCSI";

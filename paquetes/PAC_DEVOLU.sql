--------------------------------------------------------
--  DDL for Package PAC_DEVOLU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DEVOLU" IS
/*-----------------------------------------------------------------------*/
/* Distribuci¿ de les devolucions de rebuts                              */
/* - Canvi format ccc                                                    */
/* - Canvi de c¿rrega de l'ordenant, pot tenir m¿s d'una                 */
/*                   remesa per data en la mateixa devoluci¿.            */
/* - Petits canvis per adaptar-ho a ALN                                  */
/* CPM 21/1/04: Es passa aquest package a B.D i s'estandaritza (i        */
/*              parametritza per a que es pugui utilitza en totes les    */
/*              aplicacions                                              */
/******************************************************************************
   NOMBRE:      PAC_DEVOLU
   PROP¿SITO: Funciones para la gesti¿n de las devoluciones

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/05/2009   XPL                1. Continuaci¿n del package.
   2.0        17/11/2010   ICV                2. 0016383: AGA003 - recargo por devoluci¿n de recibo (renegociaci¿n de recibos)
   3.0        09/11/2011   JMF                3. 0020038: Anulaci¿n de recibos seg¿n el convenio
   4.0        23/04/2012   JMF                0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
   5.0        16/05/2012   JGR                5. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943
   6.0        26/07/2012   JGR                6. 0022086: LCOL_A003-Devoluciones - Fase 2 - 0117715
   7.0        11/06/2012   APD                7. 0022342: MDP_A001-Devoluciones
   8.0        02/10/2012   JGR                8. 0023864: LCOL_A003-Terminacion por convenios - descuadre entre rescate y recibo - 0124752
******************************************************************************/
   lin            VARCHAR2(200);
   codreg         NUMBER(2);
   error          NUMBER := 0;
   bonus          NUMBER := 0;
   reg            NUMBER := 0;
   fecha_rem      DATE;
   v_regorden     NUMBER := 0;
   nombre_fichero VARCHAR2(100);

   --Ems indica si l'ordenant t¿ m¿s d'una remesa per la mateixa data
   FUNCTION f_carga_fichero_devo(
      pnom_fitxer VARCHAR2,
      pidioma VARCHAR2 DEFAULT '2',
      pproceso NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION caso_fichero(linea VARCHAR2, pidioma VARCHAR2)
      RETURN NUMBER;

   FUNCTION tratar_cpresentador(lin1 VARCHAR2)
      RETURN NUMBER;

   FUNCTION tratar_cordenante(lin1 VARCHAR2)
      RETURN NUMBER;

   FUNCTION tratar_registros(lin1 IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION tratar_tordenante(lin1 VARCHAR2)
      RETURN NUMBER;

   FUNCTION tratar_tgeneral(lin1 VARCHAR2)
      RETURN NUMBER;

   -- Bug 0020038 - 09/11/2011 - JMF
   FUNCTION tratar_devoluciones(
      pidioma VARCHAR2,
      par_sdevolu IN NUMBER DEFAULT NULL,
      par_sproces IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_impaga_rebut(
      pnrecibo IN NUMBER,
      pfecha IN DATE,
      pccobban IN NUMBER,
      pcmotivo IN NUMBER,
      pcrecimp IN NUMBER DEFAULT 0,   --Bug.: 16383 - ICV - 17/11/2010
      psproces IN NUMBER DEFAULT NULL,   --BUG 36911-209890 10/07/2015 KJSC Nuevo parametro de psproces
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- 26.  0022762: MDP_A001-Impago de recibos (impago masivo) - Inicio
   /*************************************************************************
    Funci¿n que que genera impago de recibos (2 parte)

    param in pnrecibo     : N¿ Recibo
    param in pfecha       : Fecha del impago
    param in pccobban     : Cobrador bancario
    param in pcmotivo     : Motivo
    param in pcrecimp     : Recibos impreso
    param in out psmovagr : C¿digo agrupador de movimientos

    return                : NUMBER (posible error)(0 OK)

   -- Se crea esta funci¿n con el cuerpo de la anterior f_impaga_rebut, para poder
   -- a¿adirle un par¿metro OUT sin que esto afecte a todas las llamadas existentes.
   -- "f_impaga_recibo" se deja para las llamadas antiguas, las que requieran
   -- que se les devuelva el SMOVAGR deber¿n llamar a esta "f_impaga_rebut_2"

   *************************************************************************/
   FUNCTION f_impaga_rebut_2(
      pnrecibo IN NUMBER,
      pfecha IN DATE,
      pccobban IN NUMBER,
      pcmotivo IN NUMBER,
      pcrecimp IN NUMBER DEFAULT 0,   --Bug.: 16383 - ICV - 17/11/2010
      psmovagr IN OUT NUMBER,
      psproces IN NUMBER DEFAULT NULL,   --BUG 36911-209890 10/07/2015 KJSC Nuevo parametro de psproces
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- 26.  0022762: MDP_A001-Impago de recibos (impago masivo) - Fin

   --XT
   pk_autom_fichero VARCHAR2(100);
   s_total_imp_llegit NUMBER := 0;
   --Import llegit de tot el fitxer
   s_total_imp_teoric NUMBER := 0;
   n_total_ind_ok_llegit NUMBER := 0;
   n_total_ind_ko NUMBER := 0;
   n_total_ind_ok_teoric NUMBER := 0;
   n_total_presentador NUMBER := 0;
   nif_ord1       VARCHAR2(9);
   nif_pres1      VARCHAR2(9);
   nif_ord2       VARCHAR2(9);
   nif_pres2      VARCHAR2(9);
   ttsufijo_pres1 VARCHAR2(3);
   ttsufijo_ord1  VARCHAR2(3);
   ttsufijo_pres2 VARCHAR2(3);
   ttsufijo_ord2  VARCHAR2(3);
   psproces       NUMBER;
   vsdevolu       NUMBER;
   ncartes        NUMBER;
   primera_vegada BOOLEAN;
   g_ccobban      NUMBER(3);

   FUNCTION f_devol_automatico(
      xcactimp1 NUMBER,
      xcactimp2 NUMBER,
      pidioma VARCHAR2 DEFAULT '2',
      pproceso NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- 8. 0023864: LCOL_A003-Terminacion por convenios - descuadre entre rescate y recibo - 0124752 - Inicio
   -- Se han declarado en la especificaci¿n la funci¿n "anula_poliza" para que puedan ser llamada desde el
   -- PAC_PROPIO.F_DEVOLU_ACCION_7. Anteriormente estaban dentro del "F_DEVOL_AUTOMATICO"
   PROCEDURE anula_poliza(psseguro IN NUMBER, pffejecu IN DATE, pcmotivo IN NUMBER);

   -- 42. 0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago - Inicio
   FUNCTION f_anula_poliza(psseguro IN NUMBER, pffejecu IN DATE, pcmotivo IN NUMBER)
      RETURN NUMBER;

   -- 42. 0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago - Final

   -- 8. 0023864: LCOL_A003-Terminacion por convenios - descuadre entre rescate y recibo - 0124752 - Inicio
   FUNCTION f_garan_suspendidas(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Funci¿n que seleccionar¿ informaci¿n sobre los procesos de devoluci¿
        param in pcempres     : codigo empresa
        param in psedevolu    : n¿ proceso de devoluci¿n
        param in pfsoport     : fecha confecci¿n del soporte
        param in pfcarga      : fecha carga del soporte
        param out psquery
        return                : NUMBER 0 / error
     *************************************************************************/
   FUNCTION f_get_consulta_devol(
      pcempres IN NUMBER,
      psdevolu IN NUMBER,
      pfsoport IN DATE,
      pfcarga IN DATE,
      pccobban IN NUMBER,   -- 25.  0022086 / 0117715
      psperson IN NUMBER,   -- 25.  0022086 / 0117715
      ptipo IN NUMBER,   -- 25.  0022086 / 0117715
      pfcargaini IN DATE,
      pfcargafin IN DATE,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Funci¿n que se encargar¿ de recuperar la informaci¿n de un procseo de
        devoluci¿n.
        param in psedevolu    : n¿ proceso de devoluci¿n
        param out psquery
        return                : NUMBER 0 / error
     *************************************************************************/
   FUNCTION f_get_datos_devolucion(psdevolu IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Funci¿n que se encargar¿ de devolver los recibos de una devoluci¿n
        param in psedevolu     : n¿ proceso de devoluci¿n
        param in pidioma
        param out psquery
        return                : NUMBER 0 / error
     *************************************************************************/
   FUNCTION f_get_datos_recibos_devol(
      psdevolu IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
         Funci¿n que recuperar¿ los recibos de un proceso de devoluci¿n y su estado de revisi¿n
         pnrecibo IN NUMBER,
         psdevolu IN NUMBER,
         pcdevsit IN NUMBER
         return                : NUMBER 0 / error
      *************************************************************************/
   FUNCTION f_set_rec_revis(pnrecibo IN NUMBER, psdevolu IN NUMBER, pcdevsit IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Funci¿n que se encargar¿ gde generar el listado de recibos devueltos para un proceso
        de devoluci¿n en concreto
        param in psedevolu     : n¿ proceso de devoluci¿n
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_listado_devol(
      psdevolu IN NUMBER,
      pidioma IN NUMBER,
      pnomfichero OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Funci¿n que se encargar¿ gde generar las cartas de devoluciones de recibos de un proceso de devoluci¿n
        de devoluci¿n en concreto
        param in psedevolu     : n¿ proceso de devoluci¿n
        param pidioma IN NUMBER
        return                : NUMBER 0 / error
        -- Bug 0022030 - 23/04/2012 - JMF
     *************************************************************************/
   FUNCTION f_get_cartas_devol(
      psdevolu IN NUMBER,
      pidioma IN NUMBER,
      pplantilla OUT NUMBER,
      pnomfichero OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Funci¿n que se encargar¿ de cargar los recibos especificados en el fichero de devoluciones informado por param.
        de devoluci¿n en concreto
        param in pnomfitxer   : nombre del fichero de devoluci¿n
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_carga_fichero(
      pcempres IN NUMBER,
      pnomfitxer IN VARCHAR2,
      pidioma IN NUMBER,
      psproces OUT NUMBER,
      p_fich_out OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Funci¿n que realizar¿ las devoluciones de los recibos especificados en el fichero y cargados en las
        tablas de devoluci¿n de recibos al hacer la carga previa del fichero.
        de devoluci¿n en concreto
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_exec_devolu(pidioma IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
          Funci¿n que seleccionar¿ informaci¿n sobre las cartas de devoluci¿n
          param in psgescarta     : Id. carta
          param in pnpoliza     : n¿ poliza
          param in pnrecibo     : n¿ recibo
          param in pcestimp     : estado de impresi¿n de carta
          param in pfini        : fecha inicio solicitud impresi¿n
          param in pffin        : fecha fin solicitud impresi¿n
          param in pidioma      : codigo del idioma
          param in pcempres      : codigo de la empresa
          param in pcramo      : codigo del ramo
          param in psproduc      : codigo del producto
          param in pcagente      : codigo del agente
          param in pcremban      : N¿mero de remesa interna de la entidad bancaria
          param out vsquery
          return                : NUMBER 0 / error
       *************************************************************************/
   -- Bug 22342 - APD - 11/06/2012 - se a¿aden los parametros pcempres, pcramo,
   -- psproduc, pcagente, pcremban
   FUNCTION f_get_consulta_cartas(
      psgescarta IN NUMBER,
      pnpoliza IN NUMBER,
      pnrecibo IN NUMBER,
      pcestimp IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      pidioma IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pcremban IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
          Funci¿n que modificar¿ el estado de impresi¿n de una carta
          param in psgescarta     : Id. carta
          param in pcestimp     : estado de impresi¿n de carta
          param out mensajes    : mensajes de error
          return                : NUMBER 0 / 1
       *************************************************************************/
   FUNCTION f_set_estimp_carta(psdevolu IN NUMBER, pnrecibo IN NUMBER, pcestimp IN NUMBER)
      RETURN NUMBER;

    --Ini Bug.: 16383 - ICV - 17/11/2010
   /*************************************************************************
            Funci¿n que crear¿ el recibo por recargo de impago
            param in pnrecibo     : N¿ Recibo
            return                : NUMBER 0 / error
         *************************************************************************/
   FUNCTION f_set_recargoimpago(pnrecibo IN NUMBER, pfecha IN DATE, pccobban IN NUMBER)
      RETURN NUMBER;

--Fin Bug
   -- 2. 0022268: LCOL_A001-Revision circuito domiciliaciones - Inicio

   /*************************************************************************
          Funci¿n que devuelve la fecha final del periodo de gracia de un recibo
          param in p_sseguro    : N¿ Seguro
          return                : NUMBER
       *************************************************************************/
   FUNCTION f_numdias_periodo_gracia(p_sseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
          Funci¿n que devuelve la fecha final del periodo de gracia de un recibo
          param in psproces     : N¿ de proceso
          param in pnrecibo     : N¿ Recibo
          return                : DATE
       *************************************************************************/
   FUNCTION f_fecha_periodo_gracia(psproces IN NUMBER, pnrecibo IN NUMBER)
      RETURN DATE;
-- 2. 0022268: LCOL_A001-Revision circuito domiciliaciones - Fin
END pac_devolu;

/

  GRANT EXECUTE ON "AXIS"."PAC_DEVOLU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DEVOLU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DEVOLU" TO "PROGRAMADORESCSI";

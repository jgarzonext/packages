
CREATE OR REPLACE PACKAGE "PAC_CUADRE_ADM" IS
/******************************************************************************
   NOMBRE:       PAC_CUADRE_ADM
   PROPÓSITO:

   REVISIONES:

   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    12        09/06/2010   PFA               12. 14942: AGA800 - Comptabilitat: Vida o no Vida
    11        24/04/2009   DCT                1. Modificar f_ccontban
    10        23/03/2009   DCT                1. Crear función f_ccontban
     9        26/02/2009   DCT                1. Cambiar Cursor principal de f_selec_cuenta
                                                 y f_select_cuenta_asient. Anadir
                                                 nueva procedure PROCESO_BATCH_CIERRE(copia MVIDA)
                                                 Quitar : 'AND d.cempres = 1'
                                                 Optimizar Select.Utilizamos tablas personas f_LPS_pais
     8        11/02/2009   DCT                1. Modificar función f_selec_cuenta
    13        23/12/2010   ICV               13. 0017033: CEM800 - Contabilidad - Proteger el cierre para que no se pueda hacer sobre un cálculo acumulado
    14        29/06/2011   ICV               14. 0018917: MSGV003 - Comptabilitat: El detall de la comptabilitat diaria no funciona.
    15        02/07/2012   DCG               15. 0022394: AGM003-AGM - Contabilida no cuadra.
    16        28/01/2013   APD               16. 0025558: LCOL_F003-Env?o Contabilidad en Interface de CxP
    17        27/11/2017   AAB               17. CONF-403:Se Ingresan cambios para la cabecera de contabilidad.
******************************************************************************/
/*-----------------------------------------------------------------------*/
/* Package per controlar l'accés dels diferents usuaris a les pòlisses i */
/* la seva informació                                                    */
/*-----------------------------------------------------------------------*/
   fdesde         DATE;
   fhasta         DATE;
   finicial       DATE;

--------------------------------------------------------------------------------------------
---  Borra las tablas "cuadre"
--------------------------------------------------------------------------------------------
   PROCEDURE p_cuadre_recibos(
      aaproc IN NUMBER,
      mmproc IN NUMBER,
      empresa IN NUMBER,
      pnummes IN NUMBER DEFAULT 1);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE01
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre01(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE02
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre02(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE03
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre03(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE04
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre04(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE05
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre05(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE06
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre06(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE07
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre07(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE08
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre08(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE001
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre001(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE002
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre002(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE003
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre003(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE004
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre004(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE005
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre005(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE006
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre006(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE_TOTAL01
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre_total01(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE_TOTAL02
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre_total02(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE_TOTAL03
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre_total03(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

--------------------------------------------------------------------------------------------
---  Graba la tabla CUADRE_TOTAL04
--------------------------------------------------------------------------------------------
   PROCEDURE p_gracuadre_total04(aaproc IN NUMBER, mmproc IN NUMBER, empresa IN NUMBER);

/************************************************************************************************
   Inserta en las tablas CONTAB y DETCONTAB
************************************************************************************************/
   PROCEDURE p_contabiliza(empresa IN NUMBER, pfecha IN DATE, pnummes IN NUMBER DEFAULT 1);

-------------------------------------------------------------
-- Procediment per traspasar a les taules definitivas
-- CPM 4/2/04
-------------------------------------------------------------
   PROCEDURE p_traspaso_his(empresa IN NUMBER, pfecha IN DATE);

-- BUG 14942: PFA - Comptabilitat: Vida o no Vida
-------------------------------------------------------------
-- Funció que indica si una poliza es de vida o de no vida
-- Devuelv  0: no es Vida; 1: si es vida
-------------------------------------------------------------
   FUNCTION f_es_vida(psseguro IN NUMBER)
      RETURN NUMBER;

-- Fi BUG 14942: PFA - Comptabilitat: Vida o no Vida

   -------------------------------------------------------------
-- Funció que indica si un mes està ja tancat o no
--   Retorna 0: no està tancat; 1: està tancat
-- CPM 4/2/04
-------------------------------------------------------------
   FUNCTION f_esta_cerrado(empresa IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

-------------------------------------------------------------
-- Funció que calcula la select utilitzada per extreure la informació
--   d'una certa select
--   Retorna la select
--     PActual indica si la select es fa sobre les taules actuals del
--         CUADRE (1) o sobre l'Historic (0)
-- CPM 4/2/04
-------------------------------------------------------------
   FUNCTION f_selec_cuenta_asient(
      pcuenta IN VARCHAR2,
      plinea IN NUMBER,
      pasient IN NUMBER,
      ptipo IN VARCHAR2,
      pfecha IN DATE,
      pempresa IN NUMBER DEFAULT 1,
      pactual IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

-------------------------------------------------------------
-- Funció que calcula la select utilitzada per extreure la informació
--   d'una certa select
--   Retorna la select
--     PActual indica si la select es fa sobre les taules actuals del
--         CUADRE (1) o sobre l'Historic (0)
-- CPM 4/2/04
-- BUG 0008989-  11/02/2009 - dciurans (DCT)
-- BUG 0008990- 26/02/2009 --dciurans (DCT) Arreglar   f_selec_cuenta y  f_selec_cuenta_asient.
--------------------------------------------------------------------------------
   FUNCTION f_selec_cuenta(
      pcuenta IN VARCHAR2,
      ptipo IN VARCHAR2,
      pfecha IN DATE,
      pempresa IN NUMBER DEFAULT 1,
      pactual IN NUMBER DEFAULT 0,
      pmes IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

-------------------------------------------------------------
-- Funció utilitzada per trobar el ple que li toca segons
--   el contracte del reaseguro
--   Retorna el ple (o límit que no es reasegura)
-- CPM 10/3/04
-------------------------------------------------------------
   FUNCTION f_contratorea(psseguro IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER;

-------------------------------------------------------------
-- Funció utilitzada per trobar el pais del prenedor d'una
--   pol·lissa per contabilitat
-- CPM 23/6/05
-- DCT 3/02/2009. Optimizar Select.Utilizamos tablas personas
-------------------------------------------------------------
   FUNCTION f_lps_pais(psseguro IN NUMBER)
      RETURN NUMBER;

-------------------------------------------------------------
-- Funció que retorna el map a executar que fa la generació
-- del fitxer de comptabilidad.
-- SBG 28/08/2008
-------------------------------------------------------------
   FUNCTION f_obtener_map(p_cempres IN NUMBER)
      RETURN VARCHAR2;

-------------------------------------------------------------------
-- 4857 jdomingo 28/2/2008 creem nou tancament procés contabilitat,
-- anàleg a altres cridats per la funció ejecutar_cierres
--DCT 03/03/2009    Anadir PROCESO_BATCH_CIERRE(Copia MVIDA)
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

--------------------------------------------------------------------
----  F_ccontban: Retorna el código contable de su cobrador bancario.
----  Funció utilitzada en comptabilitat
----- 20/03/2009 DCT
---------------------------------------------------------------------
   FUNCTION f_ccontban(pnrecibo NUMBER, sproduc NUMBER, pnsinies NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_contabiliza_diario(pcempres IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

-- Bug 0014782 - JMF - 03/09/2010
/*************************************************************************
  Función que busca selects dinámicas para detalle contabilidad diaria
  param in p_cempres   : Código empresa
  param in p_fcontab   : Fecha contabilidad
  retorna 0 si ha ido bien, 1 en casos contrario
  *************************************************************************/
   FUNCTION f_contabiliza_detallediario(
      p_cempres IN NUMBER,
      p_fcontab IN DATE,
      p_ccuenta IN VARCHAR2,
      p_nlinea IN NUMBER,
      p_smodcon IN NUMBER,
      p_cpais IN NUMBER,
      p_fefeadm IN DATE,
      p_cproces IN NUMBER)
      RETURN VARCHAR2;

-- Bug 0022394 - DCG - 02/07/2012
/*************************************************************************
  Función que busca selects dinámicas para detalle del MAP 311
  param in p_cempres   : Código empresa
  param in p_mes       : Mes
  param in p_ano       : Ano
  param in p_cpais     : País
  param in p_simulhist : Simulación o histórico
  *************************************************************************/
   FUNCTION f_list_map311(
      p_cempres IN NUMBER,
      p_mes IN NUMBER,
      p_ano IN NUMBER,
      p_cpais IN NUMBER,
      p_simulhist IN NUMBER)
      RETURN VARCHAR2;

/*************************************************************************
  Mapa que se ejecuta desde la pantalla axisadm007 Desglose Simul. Contable
  *************************************************************************/
   FUNCTION f_desglose_cuenta(
      pcuenta IN VARCHAR2,
      ptipo IN VARCHAR2,
      pfecha IN DATE,
      pempresa IN NUMBER DEFAULT 1,
      pactual IN NUMBER DEFAULT 0,
      pmes IN NUMBER DEFAULT 1,
      pasient IN NUMBER,
      plinea IN NUMBER)
      RETURN VARCHAR2;
/*************************************************************************
   Funcion que obtiene el IDPAGO tanto si debe ser concatenado o debe
   conservar el IDPAGO.
  *************************************************************************/
--Version 17
   FUNCTION f_idpago(pttippag IN NUMBER,
                     pidpago IN NUMBER,
                     pidmovimiento IN NUMBER)
   RETURN NUMBER;
--Version 17
   -- Bug 25558 - APD - 25/01/2013 - se crea la funcion
   FUNCTION f_contabiliza_interf(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pcempres IN NUMBER,
      pfecha IN DATE,
      pidmovimiento IN NUMBER)
      RETURN NUMBER;
 --IAXIS 4504 AABC Contabilidad de siniestros interfaz sap  
    FUNCTION f_conta_int_sini(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pcempres IN NUMBER,
      pfecha IN DATE,
      pidmovimiento IN NUMBER)
      RETURN NUMBER; 
	  
	  --Bug 5194 creacion de funcion de contabilidad para siniestros reservas
   FUNCTION f_conta_int_res(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pcempres IN NUMBER,
      pfecha IN DATE,
      pidmovimiento IN NUMBER,
      pnsinies in sin_siniestro.nsinies%type, 
      pntramit in number, 
      pctipres      in number, 
      pnmovres      in number,
      pnmovresdet   IN NUMBER,
      pcreexpre     IN NUMBER,
      pidres        IN NUMBER,
      pcmonres      IN NUMBER)
      RETURN NUMBER ;
	  
END pac_cuadre_adm;

/

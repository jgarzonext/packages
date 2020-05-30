--------------------------------------------------------
--  DDL for Package PAC_PSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PSU" IS
/******************************************************************************
   NOMBRE    : PAC_PSU
   ARCHIVO   : PAC_PSU.PKS
   PROPÓSITO : Package con funciones propias de la funcionalidad de
               Política de Subscripción.

   REVISIONES:
   Ver    Fecha      Autor     Descripción
   ------ ---------- --------- ------------------------------------------------
   1.0    28-05-2009 M.Redondo Creación del package.
   1.1    05-06-2009 M.Redondo Adapatació a rebre només resultats numèrics de
                               les fòrmules.
   1.2    10-06-2009 M.Redondo Actualització Controls Autoritzats/Rebutjats i
                               ref_cursor amb els controls existents.
   1.3    11-06-2009 M.Redondo S'incorpora CGARANT a CONTROLSEG i ESTCONTROLSEG
                               Es treu CTIPCONT de CODCONROL_PSU
                               Es crea la funció f_polizas_con_control
   1.4    22-06-2009 acc       Afegir funció f_grabaobservaciones
   1.5    01-07-2009 M.Redondo A la funció F_LEE_CONTROLES, s'afegeix el llegir
                               de les taules EST, segons el paràmetre P_TABLAS.
   1.6    18-01-2010 M.R.B.    Adaptació a la nova definició de les taules i
                               opcions (Nova Producció, Suplements i Renovació).
   2.0    22-10-2012 DRA       0023717: LCOL - Revisar y continuar con la parametrización de PSUs - Vida Grupo - Fase 2
   3.0    13/03/2013 ECP       0026092: LCOL_T031-LCOL - Fase 3 - (176-11) - Parametrizaci?n PSU's. Nota 140055
   4.0    11/03/2014 APD       0030448/169258: LCOL_T010-Revision incidencias qtracker (2014/03)
   5.0    02/07/2015 IGIL      0036596/208749 AIS_MANUAL_UNDERWRITING
******************************************************************************//*****************************************************************************
    Trata todas las reglas de Política de Subscripción del producto al cual
    pertenece la póliza.

    param in      : P_TABLAS  Determina tablas EST o SEG
    param in      : P_SSEGURO Número identificativo interno de SEGUROS
    param in      : P_AREA    Area a revisar de la Política de Subscripción
                              (1 = Emisión ; 2 = Siniestros)
    param in      : P_ACCION  Codi de l'acció que estem fent:
                              1 = Nova Producció
                              2 = Suplement
                              3 = Renovació
                              4 = Cotización
    param in      : P_CIDIOMA Codigo del idioma del Usuario
    param in out  : P_CRETENI 0 => No retener; 2 => Retener;
                    Sólo devolveremos 0 => No retener, si todos los controles
                    PSU, hayan quedado autorizados y el valor que nos ha llegado
                    en CRETENI también es cero. (Se respetan los otros controles
                    existentes).

    Devuelve      : 0 => Correcto ó 1 => Error.

   *****************************************************************************/
   FUNCTION f_inicia_psu(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      --p_area IN NUMBER,
      p_accion IN NUMBER,
      p_cidioma IN NUMBER,
      p_creteni IN OUT NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------

   /***************************************************************************
    Ejecuta las reglas de Política de Subscripción del producto al cual
    pertenece la póliza.

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_FEFECTO  Fecha del efecto de la póliza/suplemento
    param in      : P_SPRODUC  Código del producto
    param in      : P_CACTIVI  Código de la actividad
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CGARANT  Código de la garantía
    param in      : P_CCONTROL Código del Control que estamos tratando
    param in      : P_CFORMULA Codigo de la fórmula a ejecutar
    param out     : P_RESULTAT Resultado obtenido por la fórmula

    Devuelve      : 0 => Correcto ó 1 => Error.
   ***************************************************************************/
   FUNCTION f_trata_formulas_psu(
      p_sseguro IN NUMBER,
      p_fefecto IN DATE,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_cformula IN NUMBER,
      p_nmovimi IN NUMBER,   -- M.R.B. 2/12/2011 S'AFEGEIX BUTG 19684
      p_resultat OUT NUMBER,
      p_tablas IN VARCHAR2 DEFAULT 'EST',
      -- Ini Bug 26092 --ECP-- 13/03/2013
      origenpsu IN NUMBER DEFAULT NULL,
      pccambio  IN NUMBER DEFAULT NULL)
      -- Fin Bug 26092 --ECP-- 13/03/2013
   RETURN NUMBER;

----------------------------------------------------------------------------

   /***************************************************************************
    Busca en la tabla NIVEL_CONTROL_PSU, el nivel requerido para el control que
    estamos tratando, según el valor calculado por la fórmula asociada al control.
    Este valor siempre es un varchar2, pero en función del campo CTIPCONT de la
    tabla CODCONTROL_PSU, lo trataremos como Num(1), Varchar(2) o Fecha(3).

    param in      : P_CCONTROL Código del Control que estamos tratando
    param in      : P_AREA    Area a revisar de la Política de Subscripción
                              (1 = Emisión ; 2 = Siniestros)
    param in      : P_SPRODUC  Identificador del producto
    param in      : P_NVALOR   Valor que nos llega de ehjecutar la fórmula del control
    param out     : P_NIVREQ   Código del nivel requerido para el control
    param out     : P_INCIDEN  Texto que se grabará en obseraciones de las tabla CONTROLSEG

    Devuelve      : 0 => Correcto ó 1 => error.

   ***************************************************************************/
   FUNCTION f_nivel_requerido_psu(
      p_control IN NUMBER,
      --p_area IN NUMBER,
      p_sproduc IN NUMBER,
      p_valor IN NUMBER,
      p_nivreq OUT NUMBER,
      p_nivinf OUT NUMBER,
      p_nivsup OUT NUMBER,
      p_inciden OUT VARCHAR)
      RETURN NUMBER;

----------------------------------------------------------------------------

   /***************************************************************************
    Busca en la tabla USUAGRU_NIVEL_PSU, el nivel que tiene el usuario para el
    producto al que pertenece la póliza y dentro del área que estemos validando.

    La no existencia del Grupo al que pertenece el usuario, o el nivel para este
    producto, no provocará ningún error, sino que se devolverá el valor 0 (Cero)
    que corresponde al mínimo nivel. De esta manera, los usuarios que tengan el
    nivel mínimo, no hará falta introducirlos en el sistema PSU.

    param in      : P_USUARIO Identificador del usuario
    param in      : P_AREA    Area a revisar de la Política de Subscripción
                              (1 = Emisión ; 2 = Siniestros)
    param in      : P_SPRODUC Identificador del producto

    Devuelve      : Nivel del usuario para esta AREA y este PRODUCTO.

   ***************************************************************************/
   FUNCTION f_nivel_usuari_psu(p_usuario IN VARCHAR2, p_sproduc IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------

   /***************************************************************************
    Ejecuta las fórmula de Política de Subscripción del producto al cual
    pertenece la póliza y prepara la grabación de las tablas CONTROLSEG y
    ESTCONTROLSEG.

    param in      : P_TABLAS   Indica si tratamos tablas EST o SEG
    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_AREA     Area a revisar de la Política de Subscripción
                               (1 = Emisión ; 2 = Siniestros)
    param in      : P_CIDIOMA  Código del idioma
    param in      : P_FEFECTO  Fecha del efecto de la póliza/suplemento
    param in      : P_SPRODUC  Código del producto
    param in      : P_CACTIVI  Código de la actividad
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CGARANT  Código de la garantía
    param in      : P_CFORMULA Codigo de la fórmula a ejecutar
    param in      : P_CCONTROL Código del Control que estamos tratando
    param in      : P_NIVELUSU Código del Nivel del usuario para el producto

   ***************************************************************************/
   PROCEDURE prepara_graba_controles(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      --p_area IN NUMBER,
      p_cidioma IN NUMBER,
      p_fefecto IN DATE,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cformula IN NUMBER,
      p_ccontrol IN NUMBER,
      p_nivelusu IN NUMBER,
      p_cautmanual IN VARCHAR2,
      p_nocurre IN NUMBER,
      p_nmovimi IN NUMBER,
      -- Ini Bug 26092 --ECP-- 13/03/2013
      origenpsu IN NUMBER DEFAULT NULL,
      pccambio  IN NUMBER DEFAULT NULL
                                      -- Fin Bug 26092 --ECP-- 13/03/2013
   );   -- M.R.B. 2/12/2011 S'AFEGEIX BUG 19684

   FUNCTION f_grabar_retenidas(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pcusuret IN VARCHAR2,
      pffecret IN DATE,
      pcusuaut IN VARCHAR2,
      pffecaut IN DATE,
      pobserv IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------

   /***************************************************************************
    Graba la tablas de Política de Subscripción CONTROLSEG o ESTCONTROLSEG para
    cada Control efectuado para la póliza que se esta tratando.

    param in      : P_TABLAS   Determina tablas EST o SEG
    param in      : P_CIDIOMA  Código del Idioma
    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CGARANT  Códi de garantia
    param in      : P_CCONTROL Código del CONTROL
    param in      : P_AREA     Codi del àrea que tractem
    param in      : P_CNIVELR  Nivel requerido para superar el Control
    param in      : P_NVALOR   Valor(Numérico) devuelto por las fórmulas del Control
    param in      : P_CNIVELU  Nivel del Usuario
    param in      : P_OBSERV   Observaciones que se grabarán en CONTROLSEG/ESTCONTROLSEG
    param in      : P_SOLOMANUAL Si el control NO se autoriza automáticamente
    param in      : P_ESTABLOQUEA Si el control es Bloqueante
    param in      : P_ORDENBLOQUEA Orden del control dentro de los Bloqueantes
    param in      : P_AUTORIPREV Si se acepta en base a una autorización previa

   ***************************************************************************/
   PROCEDURE graba_tabla_controles_psu(
      p_tablas IN VARCHAR2,
      p_cidioma IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      --p_area IN NUMBER,
      p_cnivelr IN NUMBER,
      p_nvalor IN NUMBER,
      p_cnivelu IN NUMBER,
      p_observ IN VARCHAR,
      p_solomanual IN VARCHAR,
      p_establoquea IN VARCHAR,
      p_ordenbloquea IN NUMBER,
      p_autoriprev IN VARCHAR,
      p_nivinf IN NUMBER,
      p_nivsup IN NUMBER,
      p_cautmanual IN VARCHAR2,
      p_nocurre IN NUMBER);

   PROCEDURE p_control_anterior(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nocurre IN NUMBER,
      p_ccontrol IN NUMBER,
      p_cgarant IN NUMBER,
      p_nriesgo IN NUMBER);

----------------------------------------------------------------------------

   /***************************************************************************
    Recupera los datos del detalle del control tratado en la tabla CONTROLPRO

    param in      : P_CCONTROL     Código del CONTROL
    param in      : P_AREA         Codi del àrea que tractem
    param in      : P_SPRODUC      Codi del producte que tractem
    param out     : P_SOLOMANUAL Si el control NO se autoriza automáticamente
    param out     : P_ESTABLOQUEA  Control bloqueante
    param out     : P_ORDENBLOQUEA Orden dentro de los bloqueantes
    param out     : P_AUTORIPREV   Autorizamos según autorización previa (S-N)

    DEVUELVE      : 0 = O.K.;  1 => Error

   ***************************************************************************/
   FUNCTION f_detalle_control(
      p_ccontrol IN NUMBER,
      p_sproduc IN NUMBER,
      p_cgarant IN NUMBER,
      p_solomanual OUT VARCHAR,
      p_establoquea OUT VARCHAR,
      p_ordenbloquea OUT NUMBER,
      p_autoriprev OUT VARCHAR)
      RETURN NUMBER;

----------------------------------------------------------------------------

   /***************************************************************************
    Comprueba si el control ya había sido autorizado con anterioridad en otri
    movimiento de la póliza.

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CCONTROL Código del CONTROL
    param in      : P_CNIVELR  Nivel requerido para superar el Control
    param in      : P_NVALOR   Valor(Numérico) devuelto por las fórmulas del Control
    param out     : P_USUANTES Usuario que autorizó en su momento
    param out     : P_AUTMANUAL  Si el control NO se autoriza automáticamente

    Devuelve:     'S' => El control YA habia sido autorizado con anterioridad
                  'N' => El control NO se habia autorizado con anterioridad
   ***************************************************************************/
   FUNCTION f_autorizado_antes(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_ccontrol IN NUMBER,
      p_cnivelr IN NUMBER,
      p_nvalor IN NUMBER,
      p_cgarant IN NUMBER,
      p_nocurre IN NUMBER,
      p_nmovimi IN NUMBER,
      p_tablas IN VARCHAR2,
      p_usuantes OUT VARCHAR2,
      p_autmanual OUT VARCHAR2,
      p_cautrec OUT NUMBER,
      p_nvalortope OUT NUMBER,
      p_observ OUT VARCHAR2,
      p_iguales OUT NUMBER,
      p_nvalorant OUT NUMBER,
      p_cgarant_out OUT NUMBER,
      p_nvalorinf OUT NUMBER,
      p_fautrecant OUT DATE)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que actualitza l'estat del control, ja sigui autoritzat com rebutjat

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CGARANT  Codi de la garantia.
    param in      : P_CCONTROL Código del CONTROL
    param in      : P_CNIVELU  Nivel del Usuario que trata el control
    param in      : P_ACCIO    1 = Autorizar, 2 = Rechazar.
    param in      : P_OBSEV    Observaciones que se grabrán en ESTCONTROLSEG

    Devuelve:     : 0 => O.K. 1 => Error

   ***************************************************************************/
   FUNCTION f_actualiza(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_cnivelu IN NUMBER,
      p_accio IN VARCHAR2,
      p_observ IN VARCHAR2,
      p_nvalortope IN NUMBER,
      p_nocurre IN NUMBER,
      p_nvalor IN NUMBER,
      p_nvalorinf IN NUMBER,
      p_nvalorsuper IN NUMBER,
      p_nivelr IN NUMBER,
      p_establoquea IN NUMBER,
      p_autmanual IN NUMBER,
      p_tablas IN VARCHAR2,
      p_modo IN NUMBER,
      p_numriesgo IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna el nivell d'autorització, que determina els usuaris que
    poden autoritzar o rebutjar la proposta/pólissa.

    Té en compte el tema dels controls bloquejants i el seu ordre.

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS

    Devuelve:     : Nivel que tienen que tener los usarios que quieran
                    interactura con la propuesta/póliza con referencia a
                    la autorización o rechazo de los controles.

   ***************************************************************************/
   FUNCTION f_nivel_bpm(p_tablas IN VARCHAR, p_sseguro IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que llegix la capçalera dels controls d'una pòlissa retornan
    un sys_refcursor

    param in      : P_TABLAS   Determina tablas EST o SEG
    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NMOVIMI  Número de Movimiento
                    (Si el número de movimiento es nulo, devolverá todos los
                     controles del último movimiento en que exista un control,
                     de lo contrario, sólo devolverá los controles del movimiento
                     en particular).
    param in      : P_CIDIOMA  Código del idioma

    Devuelve      Literal a mostrar en la cabecera.
                  Nivel requerido global (NIVEL_BPM)

   ***************************************************************************/
   FUNCTION f_lee_retenidas(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN sys_refcursor;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que llegix tots els controls d'una pòlissa retornan un sys_refcursor

    param in      : P_TABLAS   Determina tablas EST o SEG
    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
                    (Si el número de riesgo es nulo, devolverá todos los
                     controles de todos los riesgos, de lo contrario, sólo
                     devolverá los controles del riesgo en particular).
    param in      : P_NMOVIMI  Número de Movimiento
                    (Si el número de movimiento es nulo, devolverá todos los
                     controles del último movimiento en que exista un control,
                     de lo contrario, sólo devolverá los controles del movimiento
                     en particular).
    param in      : CUSUARI    Usuario autorizador

    param in      : P_CIDIOMA  Código del idioma

    Devuelve      SYS_REFCURSOR Lista de los controles.

   ***************************************************************************/
   FUNCTION f_lee_controles(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cusuari IN VARCHAR2,
      p_cidioma IN NUMBER)
      RETURN sys_refcursor;

----------------------------------------------------------------------------

   /***************************************************************************
    param in      : P_SPRODUC    Codi del Producte
    param in      : P_NSOLICI    Nombre de la sol.licitut
    param in      : P_NPOLIZA    Nombre de la pòlissa
    param in      : P_AUTREC     0 => Pendent
                                 1 => Autoritzat
                                 2 => Rebutjat
    param in      : P_CIDIOMA    Códi del idioma

    Devuelve      : SYS_REFCURSOR amb les pòlisses i els seus controls i amb
                    un indicador de si el usuari pot autoritzar cada control.
   ***************************************************************************/
   FUNCTION f_polizas_con_control(
      p_sproduc IN NUMBER,
      p_nsolici IN NUMBER,
      p_npoliza IN NUMBER,
      p_cautrec IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN sys_refcursor;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la situació de les pòlisses (CSITUAC - DETVALORES = 61)

    param in      : P_CSITUAC    Codi de CSITUAC de SEGUROS
    param in      : P_CIDIOMA    Codi del Idioma

    Devuelve      : Descripció de la situació de la pòlissa
   ****************************************************************************/
   FUNCTION f_tcsituac(p_csituac IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció del resultat dels CONTROLS (CCONTROL -
    DESCONTROL_PSU)

    param in :  p_ccontrol   Codi del control
    param in :  p_cidioma    Codi del idioma
    param in :  p_sseguro    Codi del seguro
    param in :  p_nmovimi    numero de movimiento
    param in :  p_nriesgo    numero de riesgo
    param in :  p_tablas     Clasificacion de tablas EST y reales
    Devuelve      : Descripció del control
   ****************************************************************************/
   FUNCTION f_tccontrol(
      p_ccontrol IN NUMBER,
      p_cidioma IN NUMBER,
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_tablas IN VARCHAR2 DEFAULT 'EST',
      p_cgarant IN NUMBER)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció del dels RESULTATS del CONTROLS
   (PSU_DESRESULTADO)

    param in :  p_ccontrol   Codi del control
    param in :  p_sproduc    Codi del producte
    param in :  p_cidioma    Codi del idioma

    Devuelve      : Descripció del control
   ****************************************************************************/
   FUNCTION f_tdesresultado(
      p_ccontrol IN NUMBER,
      p_sproduc IN NUMBER,
      p_cnivel IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna l'estat dels CONTROLS (CAUTREC - DETVALORES = 1001)

    param in      : P_CCONTROL   Codi de CAUTREC de CONTROLSEG
    param in      : P_CIDIOMA    Codi del Idioma

    Devuelve      : Descripció de la situació de la pòlissa
   ****************************************************************************/
   FUNCTION f_tcautrec(
      p_ccontrol IN NUMBER,
      p_sproduc IN NUMBER,
      p_cautrec IN NUMBER,
      p_cidioma IN NUMBER,
      p_cgarant IN NUMBER)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció dels NIVELLS (CNIVEL - DESNIVEL_PSU)

    param in      : P_CNIVEL    Codi de CNIVEL de usuario o de control
    param in      : P_CIDIOMA   Codi del Idioma

    Devuelve      : Descripció del nivell
   ****************************************************************************/
   FUNCTION f_tcnivel(p_cnivel IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció del PRODUCTE

    param in      : P_SPRODUC   Codi del Producte
    param in      : P_CIDIOMA   Codi del Idioma

    Devuelve      : Descripció del nivell
   ****************************************************************************/
   FUNCTION f_tproducte(p_sproduc IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció de la garantía

    param in      : P_CGARANT   Codi de la Garantía
    param in      : P_CIDIOMA   Codi del Idioma

    Devuelve      : Descripció del nivell
   ****************************************************************************/
   FUNCTION f_tcgarant(p_cgarant IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Función que devuelve la descripción del riesgo.

    param in      : P_TABLAS   EST o SEGUROS
    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : C_IDIOMA   Código de Idioma

    Devuelve la descripción del riesgo.
   ***************************************************************************/
   FUNCTION f_descrisc(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que actualitza les observacions del control

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CGARANT  Codi de la garantia.
    param in      : P_CCONTROL Código del CONTROL
    param in      : P_OBSERV   Observaciones que se grabarán en ESTCONTROLSEG

    Devuelve:     : 0 = O.K.
   ***************************************************************************/
   FUNCTION f_grabaobservaciones(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_observ IN VARCHAR2)
      RETURN NUMBER;

----------------------------------------------------------------------------
/***************************************************************************
 Función para el período de pruebas.
 Se llama desde una fórmula. En concreto de la 500002 asociada a la garantía
 5103 (28-05-2009).

 param in      : PSESION   Sesión que estamos ejecutando
 param in      : SSEGURO  Número identificativo interno de SEGUROS
 param in      : ORIGEN      0 => Tablas SOL; 1 => Tabla EST; 2 => SEG
 param in      : CCONTROLPSU Código del CONTROL que estamos ejecutando.

 DEVUELVE      : Resultado de la fórmula
***************************************************************************/
   FUNCTION f_prova(
      psession IN NUMBER,
      sseguro IN NUMBER,
      origen IN NUMBER,
      ccontrolpsu IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------------
   FUNCTION f_get_colec_psu(
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_idioma IN idiomas.cidioma%TYPE,
      p_tablas IN VARCHAR2 DEFAULT NULL,
      p_vquery OUT VARCHAR2,
      p_testpol OUT VARCHAR2,
      p_cestpol OUT NUMBER,
      p_cnivelbpm OUT NUMBER,
      p_tnivelbpm OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_detcontrol(
      p_ccontrol IN NUMBER,
      psproduc IN NUMBER,
      pcnivel IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_lstniveles(pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER;

           /*Miraremos si hay controles manuales pendientes de autorizar,
   en caso de que hay devolveremos mensaje diciendo que no podemos autorizar/rechazar y se deberan
   tratar individualmente manualmente*/
   FUNCTION f_hay_controles_manuales(p_sseguro IN NUMBER, p_tablas IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_hay_controles_pendientes(p_sseguro IN NUMBER, p_tablas IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_inicia_psu_postcartera(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN VARCHAR2,
      pncertif IN NUMBER,
      pcaccion IN NUMBER,
      pidioma IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_esta_control_pendiente(
      p_sseguro IN NUMBER,
      p_tablas IN VARCHAR2,
      pccontrol IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   FUNCTION F_LEE_HIS_PSU_RETENIDAS(p_sseguro IN NUMBER, --ramiro
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_cidioma IN NUMBER,
		p_this_psu_retenidas OUT T_IAX_PSU_RETENIDAS,
		mensajes IN OUT t_iax_mensajes
)

    RETURN NUMBER;      --ramiro

 FUNCTION F_LEE_HIS_PSUCONTROLSEG( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_ccontrol IN NUMBER,
		p_cidioma IN NUMBER,
		p_this_psucontrolseg OUT T_IAX_PSU,
		mensajes IN OUT t_iax_mensajes

)
    RETURN NUMBER;    --ramiro


 FUNCTION F_LEE_PSU_SUBESTADOSPROP( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nversionsubest IN NUMBER,
		p_nmovimi IN NUMBER,
		p_cidioma IN NUMBER,
		p_tpsu_subestadosprop OUT T_IAX_PSU_SUBESTADOSPROP,
		p_mensajes IN OUT t_iax_mensajes

)
    RETURN NUMBER;      --ramiro

 FUNCTION F_INS_PSU_SUBESTADOSPROP( --ramiro
   p_sseguro IN NUMBER,
   p_nversion IN NUMBER,
	 p_nmovimi IN NUMBER,
	 p_csubestado IN NUMBER,
	 p_cobservaciones IN VARCHAR2
)
    RETURN NUMBER; --ramiro

FUNCTION f_get_subestadoprop( --ramiro
    p_sseguro IN NUMBER,
		p_csubestadoprop OUT VARCHAR2
)
    RETURN NUMBER;       --ramiro
END pac_psu;
--/

/

  GRANT EXECUTE ON "AXIS"."PAC_PSU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PSU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PSU" TO "PROGRAMADORESCSI";

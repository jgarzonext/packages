--------------------------------------------------------
--  DDL for Package PAC_MD_ADM
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "AXIS"."PAC_MD_ADM" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_ADMIN
      PROP¿SITO: Funciones para consultas recibos

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        18/062008   JMR               1. Creaci¿n del package.
      1.3        11/03/2009  MCC               4. Gesti¿n de Impagados
      2.0        02/09/2009  DCT               5.BUG 0011031: CEM - Eliminacion parametro mensajes en PAC_ADM y PAC_MD_ADM
      3.0        18/02/2010  JMF               6. 0012679 CEM - Treure la taula MOVRECIBOI
      4.0        11/10/2010  ICV               7. 0016140: AGA003 - filtro de estado de impresion en recibos
      5.0        04/11/2010  ICV               8. 0016325: CRT101 - Modificaci¿n de recibos para corredur¿a
      6.0        21/05/2010  ICV               9. 14586: CRT - A¿adir campo recibo compa¿ia
      7.0        17/06/2011  ICV              10. 0018838: CRT901 - Pantalla para modificar estado de un recibo
      8.0        18/07/2011  SRA              11. 0018908: LCOL003 - Modificaci¿n de las pantallas de gesti¿n de recibos
      9.0        29/05/2012  JGR              12. 0022327: MDP_A001-Consulta de recibos - 0115278
      9.1        30/05/2012  DCG              13. 0022327: MDP_A001-Consulta de recibos - 0115681
     10.0        12/09/2012  JGR              21. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028
     11.0        12/12/2012  JGR              22. 0024754: (POSDE100)-Desarrollo-GAPS Administracion-Id 156 - Las consultas de facturas se puedan hacer por sucursal y regional
     12.0        06/11/2013  CEC              23. 0026295: RSA702-Desarrollar el modulo de Caja
     13.0        21/06/2019  SGM              24. IAXIS-4134 Reporte de acuerdo de pago
     14.0        09/07/2019  DFR              13. IAXIS-3651 Proceso calculo de comisiones de outsourcing
     15.0        17/07/2019  DFR              15. IAXIS-3591 Visualizar los importes del recibo de manera ordenada y sin repetir conceptos.     
   ******************************************************************************/

   --Bug 9204-MCC-03/03/2009- Gesti¿n de impagados
   /*************************************************************************
          Funcion para obtener los datos de gesti¿n de impagados
          param in psseguro   : c¿digo de seguro
          param in pnrecibo   : N¿mero de recibo
          param in psmovrec   : Movimiento del recibo
          param out mensajes  : mensajes de error
          return           : 0 indica cambio realizado correctamente
                             <> 0 indica error
   *************************************************************************/
   FUNCTION f_get_impagados(psseguro IN NUMBER,
                            pnrecibo IN NUMBER,
                            psmovrec IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************************
     Selecciona informaci¿n sobre recibos dependiendo de los par¿metros de entrada
      param in pnrecibo   :   numero de recibo.
      param in pcempres   :   empresa.
      param in psproduc   :   producto
      param in pnpoliza   :   p¿liza
      param in pncertif   :   certificado.
      param in pciprec    :   tipo de recibo.
      param in pcestrec   :   estado del recibo.
      param in pfemisioini:   fecha de emisi¿n. (inicio del rango)
      param in pfemisiofin:   fecha de emisi¿n.  ( fin del rango)
      param in pfefeini   :   fecha inicio efecto.  (inicio del rango)
      param in pfefefin   :   fecha fin efecto.  (inicio del rango)
      param in ptipo      :   nos indicar¿ si es tomador o asegurado ( tomador :=1, asegurado =2)
              (check que nos permitir¿ indicar si buscamos por los datos del tomador o por los datos del asegurado)
      param in psperson   :   c¿digo identificador de la persona
      param in pcreccia   :   recibo compa¿ia.
      param in pcramo     :   c¿digo identificador del ramo
      param in pcsucursal :   c¿digo identificador de la sucursal
      param in pcagente   :   c¿digo del agente
      Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_consultarecibos(pnrecibo    IN NUMBER,
                                  pcempres    IN NUMBER,
                                  psproduc    IN NUMBER,
                                  pnpoliza    IN NUMBER,
                                  pncertif    IN NUMBER,
                                  pctiprec    IN NUMBER,
                                  pcestrec    IN NUMBER,
                                  pfemisioini IN DATE,
                                  pfemisiofin IN DATE,
                                  pfefeini    IN DATE,
                                  pfefefin    IN DATE,
                                  ptipo       IN NUMBER,
                                  psperson    IN NUMBER,
                                  pcreccia    IN VARCHAR2 DEFAULT NULL,
                                  --Bug 14586-PFA-21/05/2010- A¿adir campo recibo compa¿ia
                                  pcpolcia IN VARCHAR2 DEFAULT NULL,
                                  --Bug 14586-PFA-21/05/2010- A¿adir campo recibo compa¿ia
                                  -- Ini bug 18908 - 18/07/2011 - SRA
                                  pcramo     IN NUMBER,
                                  pcsucursal IN NUMBER,
                                  pcagente   IN NUMBER,
                                  pctipcob   IN NUMBER,
                                  -- Fin bug 18908 - 18/07/2011 - SRA
                                  pcondicion IN VARCHAR2,
                                  mensajes   IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
     Selecciona informaci¿n sobre recibos dependiendo de los par¿metros de entrada
      param in pnrecibo   :   numero de recibo.
      param in pcempres   :   empresa.
      param in psproduc   :   producto
      param in pnpoliza   :   p¿liza
      param in pncertif   :   certificado.
      param in pciprec    :   tipo de recibo.
      param in pcestrec   :   estado del recibo.
      param in pfemisioini:   fecha de emisi¿n. (inicio del rango)
      param in pfemisiofin:   fecha de emisi¿n.  ( fin del rango)
      param in pfefeini   :   fecha inicio efecto.  (inicio del rango)
      param in pfefefin   :   fecha fin efecto.  (inicio del rango)
      param in ptipo      :   nos indicar¿ si es tomador o asegurado ( tomador :=1, asegurado =2)
              (check que nos permitir¿ indicar si buscamos por los datos del tomador o por los datos del asegurado)
      param in psperson   :   c¿digo identificador de la persona.
      -- Ini bug 18908 - 18/07/2011 - SRA
      param in pcramo     :   c¿digo identificador del ramo
      param in psproduc   :   c¿digo identificador del producto
      param in pcsucursal :   c¿digo identificador de la oficina/sucursal
      param in pcagente   :   c¿digo identificador del agente
      param in pctipcob   :   tipo de cobro
      param in pdomi_sn   :   flag de domiciliaci¿n: 1 entidad de cobro, 2 gestor
      -- Fin bug 18908 - 18/07/2011 - SRA
      Mensajes del tipo t_iax_mensajes
      -- Bug 0012679 - 18/02/2010 - JMF
   *************************************************************************/
   FUNCTION f_get_consultarecibos_mv(pnrecibo    IN NUMBER,
                                     pcempres    IN NUMBER,
                                     psproduc    IN NUMBER,
                                     pnpoliza    IN NUMBER,
                                     pncertif    IN NUMBER,
                                     pctiprec    IN NUMBER,
                                     pcestrec    IN NUMBER,
                                     pfemisioini IN DATE,
                                     pfemisiofin IN DATE,
                                     pfefeini    IN DATE,
                                     pfefefin    IN DATE,
                                     ptipo       IN NUMBER,
                                     psperson    IN NUMBER,
                                     precunif    IN NUMBER,
                                     pcestimp    IN NUMBER, --Bug.: 16140 - 11/10/2010 - ICV
                                     pcreccia    IN VARCHAR2, --Bug.: 14586 - 16/11/2010 - ICV
                                     pcpolcia    IN VARCHAR2, --Bug.: 14586 - 16/11/2010 - ICV
                                     pccompani   IN NUMBER, --Bug.: 16310 - 24/12/2010 - JBN
                                     pliquidad   IN NUMBER, --Bug.: 18732 - 07/06/201 - JBN)
                                     pfiltro     IN NUMBER,
                                     -- Ini bug 18908 - 18/07/2011 - SRA
                                     pcramo     IN NUMBER,
                                     pcsucursal IN NUMBER,
                                     pcagente   IN NUMBER,
                                     pctipcob   IN NUMBER,
                                     pdomi_sn   IN NUMBER,
                                     -- Fin bug 18908 - 18/07/2011 - SRA
                                     -- Inici Bug 20326/99335 - BFP 05/12/2011
                                     cbanco     IN NUMBER,
                                     ctipcuenta IN NUMBER,
                                     -- Fi Bug 20326/99335 - BFP 05/12/2011
                                     cobban     IN NUMBER, --BUG20501 - JTS - 28/12/2011
                                     prebut_ini VARCHAR2 DEFAULT NULL, --Bug 22080 - 25/06/2012
                                     -- Inici Bug 22327/115681 - DCG 30/05/2011
                                     pnanuali  IN NUMBER DEFAULT NULL,
                                     pnfracci  IN NUMBER DEFAULT NULL,
                                     ptipnegoc IN NUMBER DEFAULT NULL,
                                     -- Fi Bug 22327/115681 - DCG 30/05/2011
                                     pcondicion IN VARCHAR2 DEFAULT NULL,
                                     mensajes   IN OUT t_iax_mensajes,
                                     pctipage01 IN NUMBER DEFAULT NULL, -- 22. 0024754 POS JGR 12/12/2012
                                     pnrecunif  IN VARCHAR2 DEFAULT NULL, --0031322/0175728:NSS:12/06/2014
                                     pnreccaj   IN NUMBER DEFAULT NULL, -- BUG CONF-441 - 14/12/2016 - JAEG
                                     pcmreca    IN NUMBER DEFAULT NULL -- BUG CONF-441 - 14/12/2016 - JAEG
                                     ) RETURN SYS_REFCURSOR;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_detrecibos_det(pnrecibo IN NUMBER,
                                 pconcep  IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detrecibo_det;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_detrecibos(pnrecibo IN NUMBER,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detrecibo;

   /*************************************************************************
       Se encarga de recuperar el vmovrecibo de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_vdetrecibos(pnrecibo IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_vdetrecibo;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_movrecibos(pnrecibo IN NUMBER,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_movrecibo;

   --Fin Bug 9204-MCC-03/03/2009- Gesti¿n de impagados

   /************************************************************************
      Recupera informaci¿n del producto -->>
   *************************************************************************/

   /*************************************************************************
       Se encarga de recuperar la informaci¿n de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       param in ptotagrup   :  0.- Importe del recibo 1.- Total agrupado
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_datosrecibo(pnrecibo  IN NUMBER,
                              ptotagrup IN NUMBER DEFAULT 0,
                              mensajes  IN OUT t_iax_mensajes)
      RETURN ob_iax_recibos;

   -- BUG12679:DRA:07/05/2010:Inici
   /*************************************************************************
       Se encarga de recuperar la informaci¿n de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
       param in ptotagrup   :  0.- Importe del recibo 1.- Total agrupado
       Mensajes del tipo t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_datosrecibo_mv(pnrecibo  IN NUMBER,
                                 ptotagrup IN NUMBER DEFAULT 0,
                                 mensajes  IN OUT t_iax_mensajes)
      RETURN ob_iax_recibos;

   -- BUG12679:DRA:07/05/2010:Fi

   /*************************************************************************
      Devuelve las descripciones para un cobrador bancario
      param in  p_ccobban    : Id. cobrador bancario
      param out p_tdescrip   : Descripci¿n del cobrador
      param out p_tcobban    : Nombre del cobrador
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_descobrador(p_ccobban  IN NUMBER,
                              p_tdescrip OUT VARCHAR2,
                              p_tcobban  OUT VARCHAR2,
                              mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Devuelve el nivel de cobbancario
      param in  pdetpoliza    : Detalle de la poliza
      param in  ptipo         : 1-Agente, 2banco, producto
      param out pnivel        : Si existe ese nivel 1 : existe, 0 no existe
      param in out mensajes   : Mensajes de error
      return                  : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_nivel_cobbancario(psproduc IN NUMBER,
                                ptipo    IN NUMBER,
                                pnivel   OUT NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      --BUG 14438 - JTS - 12/05/2010
      Funci¿n que realiza la unificaci¿n de recibos
      param in p_nrecibos    : Lista de recibos a unificar
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_agruparecibo(p_nrecibos       IN CLOB,
                           p_nrecunif       OUT NUMBER,
                           mensajes         IN OUT t_iax_mensajes,
                           p_lstrecibosunif OUT SYS_REFCURSOR) --0031322/0175728:NSS:12/06/2014
    RETURN NUMBER;

   /*************************************************************************
      --BUG 16325 - ICV - 04/11/2010
      Funci¿n que para actualizar los importes de los recibos
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_set_imprecibo(pnrecibo   IN NUMBER,
                            pnriesgo   IN NUMBER,
                            pit1dto    IN NUMBER,
                            piprinet   IN NUMBER,
                            pit1rec    IN NUMBER,
                            pit1con    IN NUMBER,
                            piips      IN NUMBER,
                            pidgs      IN NUMBER,
                            piarbitr   IN NUMBER,
                            pifng      IN NUMBER,
                            pfefecto   IN DATE,
                            pfvencim   IN DATE,
                            pcreccia   IN VARCHAR2,
                            picombru   IN NUMBER,
                            pcvalidado IN NUMBER,
                            mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      --BUG 18838 - ICV - 17/06/2011
      Funci¿n para modificar el estado de los recibos
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_set_estadorec(pnrecibo IN NUMBER,
                            pcestrec IN NUMBER,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      11/06/2012 - 19. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae informaci¿n extra del recibo.
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_datosrecibo_det(pcempres IN NUMBER,
                                  pnrecibo IN NUMBER,
                                  pcidioma IN NUMBER DEFAULT NULL,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /**********************************************************************************************
      11/06/2012 - 40. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la informaci¿n de la tala de complementos de recibos (hist¿rico de acciones)
      pnrecibo     IN Recibo.
      pcidioma     IN C¿digo de idioma
   ************************************************************************************************/
   FUNCTION f_get_recibos_comp(pnrecibo IN NUMBER,
                               pcidioma IN NUMBER DEFAULT NULL,
                               mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /**********************************************************************************************
      26/06/2012 - 43. 0022082: LCOL_A003-Mantenimiento de matriculas - 0117556
      Extrae la informaci¿n de las matr¿culas - para la consulta de matriculas
      pcempres     IN Empresa
      pnrecibo     IN Recibo.
      pccobban     IN Cobrador bancario
      pnmatric     IN N¿mero de matr¿cula
      pfenvini     IN Fecha env¿o desde
      pfenvfin     IN Fecha env¿o hasta
      pcidioma     IN C¿digo de idioma
      param out mensaje   : Tratamiento del mensaje
      return    = 0 indica cambio realizado correctamente
               <> 0 indica error
   ************************************************************************************************/
   FUNCTION f_get_matriculas(pcempres IN NUMBER,
                             pnpoliza IN NUMBER,
                             pncertif IN NUMBER,
                             pnrecibo IN NUMBER,
                             pccobban IN NUMBER,
                             pnmatric IN VARCHAR2,
                             pfenvini IN DATE,
                             pfenvfin IN DATE,
                             psperson IN NUMBER,
                             ptipo    IN NUMBER,
                             pcidioma IN NUMBER DEFAULT NULL,
                             mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /**********************************************************************************************
      26/06/2012 - 43. 0022082: LCOL_A003-Mantenimiento de matriculas - 0117556
      Extrae la informaci¿n de las matr¿culas - para la consulta de matriculas
      pcempres     IN Empresa
      pnrecibo     IN Recibo.
      pccobban     IN Cobrador bancario
      pnmatric     IN N¿mero de matr¿cula
      pfenvini     IN Fecha env¿o desde
      pfenvfin     IN Fecha env¿o hasta
      pcidioma     IN C¿digo de idioma
      param out mensaje   : Tratamiento del mensaje
      return    = 0 indica cambio realizado correctamente
               <> 0 indica error

   ************************************************************************************************/
   FUNCTION f_get_matriculas_det(pnmatric IN VARCHAR2,
                                 pcidioma IN NUMBER DEFAULT NULL,
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      29/05/2012 - 12. 0022327: MDP_A001-Consulta de recibos - 0115278
      Funci¿n que para actualizar los importes de los recibos
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_detrecibo_gtias(pnrecibo IN NUMBER,
                                  pcidioma IN NUMBER,
                                  pnriesgo IN NUMBER DEFAULT NULL,
                                  pcgarant IN NUMBER DEFAULT NULL,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      29/05/2012 - 12. 0022327: MDP_A001-Consulta de recibos - 0115278
      Funci¿n que para actualizar los importes de los recibos
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_adm_recunif(pnrecibo IN NUMBER,
                              pcidioma IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      17/07/2012 - 0022760: MDP_A001- Gedox a recibos
      Extrae los documentos asociados al recibo
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_get_recdocs(pnrecibo IN NUMBER,
                          mensajes IN OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************************
      17/07/2012 - 0022760: MDP_A001- Gedox a recibos
      Actualiza el contador de impresiones del recibo
      param in out mensajes  : Mensajes de error
      return                 : 0.- OK
                               1.- error
   *************************************************************************/
   FUNCTION f_set_docimp(pnrecibo IN NUMBER,
                         pndocume IN NUMBER,
                         mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   -- 10. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Inicio
   /*******************************************************************************
   FUNCION PAC_GESTION_REC.F_DESAGRUPARECIBO
   Funci¿n que realiza la desunificaci¿n de recibos y opcionalmente anula el recibo.
   Cuando el PFANULAC est¿ informado (IS NOT NULL).

   Par¿metros:
     param in pnrecunif : N¿mero del recibo agrupado
     param in pfanulac : Fecha de anulaci¿n
     param in pcidioma : C¿digo de idioma
     return: number un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
   ********************************************************************************/
   FUNCTION f_desagruparecibo(p_nrecibos IN CLOB,
                              pfanulac   IN DATE DEFAULT NULL,
                              pcidioma   IN NUMBER DEFAULT NULL,
                              mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;

   --23. 0026295: RSA702-Desarrollar el modulo de Caja
   FUNCTION f_get_consrecibos_multimoneda(pcempres IN NUMBER, -- La empresa se recoge de una variable global del contexto
                                          pnrecibo IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pnpoliza IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pitem    IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pcestrec IN NUMBER, -- Siempre 0
                                          pcmonpag IN NUMBER, -- Moneda en que se va a pagar
                                          ptipo    IN NUMBER, -- Si se informa por pantalla sino NULL. Debe aparecer en la pantalla 1-Contratante 2-Riesgos 3-Pagador (poner check en pantalla como en cobro manual de recibos)
                                          psperson IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pcidioma IN NUMBER,
                                          pfemisio IN DATE DEFAULT NULL,
                                          mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;
  --IGIL_INI-CONF_443-20161213
  FUNCTION f_get_detrecibos_det_fcambio(
      pnrecibo IN NUMBER,
      pconcep  IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
    RETURN t_iax_detrecibo_det;
  --IGIL_FI-CONF_443-20161213

   -- INI SGM IAXIS-4134 Reporte de acuerdo de pago
   /*******************************************************************************
   FUNCION PAC_IAX_ADM.f_get_recibos_saldos
   funcion que me trae todos los recibos que corresponden a una poliza, con su respectivo saldo por pagar

   Parametros:
     param in pnpoliza : Numero poliza
     param out cur     : cursor con listado recibos
     param out mensajes: manejo de errores
     return: number un numero con el id del error, en caso de que todo vaya OK, retornar un cero.
   ********************************************************************************/    
FUNCTION f_get_recibos_saldos(
			pnpoliza    IN     NUMBER,
			cur OUT sys_refcursor,
         mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
-- FIN SGM 13. IAXIS-4134 Reporte de acuerdo de pago
--
-- Inicio IAXIS-3651 09/07/2019 
--
/*************************************************************************
FUNCION f_calcula_comisiones
Funcion para calcular las comisiones del outsourcing por recibo gestionado
param in pnrecibo :  Número de recibo
return            :  0 indica comisión calculada correctamente. 
                  <> 0 Proceso incorrecto.
*************************************************************************/    
FUNCTION f_calcula_comisiones (pnrecibo IN NUMBER, 
                               mensajes OUT t_iax_mensajes)
   RETURN NUMBER;      
/*************************************************************************
 FUNCION f_get_info_pagos_out
 Funcion para obtener la información por orden de pago para cada outsourcing
 param in pnnumide :  Outsourcing
 param in pnnumord :  Número de orden de pago
 return            :  0 indica comisión calculada correctamente. 
                   <> 0 Proceso incorrecto.
 *************************************************************************/
--  
FUNCTION f_get_info_pagos_out (pnnumide IN VARCHAR2, 
                               pnnumord IN NUMBER, 
                               mensajes OUT t_iax_mensajes)
RETURN SYS_REFCURSOR; 
/*************************************************************************
 FUNCION f_set_info_pago_out
 Funcion para actualizar la información por orden de pago para cada outsourcing
 param in pnnumord :  Número de orden de pago
 param in pcesterp :  Estado pago ERP
 param in pnprcerp :  Número de proceso ERP
 param in pffecpagerp :  Fecha de pago ERP
 param in pivalpagerp :  Valor pago ERP
 return            :  0 indica comisión calculada correctamente. 
                   <> 0 Proceso incorrecto.
 *************************************************************************/
--
FUNCTION f_set_info_pago_out(pnnumord    IN NUMBER, 
                             pcesterp    IN NUMBER, 
                             pnprcerp    IN NUMBER, 
                             pffecpagerp IN DATE, 
                             pivalpagerp IN NUMBER, 
                            mensajes OUT t_iax_mensajes)
    RETURN NUMBER;   
--
-- Fin IAXIS-3651 09/07/2019
--
--
-- Inicio IAXIS-3591 17/07/2019
--
/*************************************************************************
 FUNCION f_get_info_coa
 Funcion para obtener los importes distribuidos en las compañías aceptantes 
 param in pnnrecibo :  Número de recibo
 return             :  Cursor con compañías aceptantes y sus respectivos importes.
 *************************************************************************/
--
FUNCTION f_get_info_coa(pnrecibo IN NUMBER,
                        mensajes OUT t_iax_mensajes)
    RETURN SYS_REFCURSOR;
--
-- Fin IAXIS-3591 17/07/2019
--         
END pac_md_adm;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ADM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ADM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ADM" TO "PROGRAMADORESCSI";

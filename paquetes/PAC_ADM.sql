--------------------------------------------------------
--  DDL for Package PAC_ADM
--------------------------------------------------------
CREATE OR REPLACE PACKAGE PAC_ADM IS
   /******************************************************************************
       NOMBRE:      PAC_ADM
       PROPÓSITO:   Funciones para la gestión de impagados

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------  ------------------------------------
       1.0        27/02/2009   MCC       1. Creación del package.Bug 9204
       2.0        09/07/2009   ETM       2.BUG 0010676: CEM - Días de gestión de un recibo
       4.0        22/09/2009   NMM       4. 10676: CEM - Días de gestión de un recibo ( canviar paràmetre).
       5.0        22/09/2009   XVM       5. BUG9028: Recibos temporales para tarificación
       6.0        18/02/2010   JMF       6. 0012679 CEM - Treure la taula MOVRECIBOI
       7.0        22/02/2010   JMC       7. BUG 13038 se añade función f_get_last_rec
       8.0        21/04/2010   DRA       8. 0014202: CRE - Parámetro nuevo para el pac_adm
       9.0        19/05/2010   DRA       9. 0014061: CEM - Fichero DWH
      14.0        03/06/2010   JTS      14. 14438: CEM - Unificación de recibos
      15.0        13/08/2010   RSC      15. 14775: AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
      16.0        11/10/2010   ICV      16. 0016140: AGA003 - filtro de estado de impresion en recibos
      17.0        04/11/2010   ICV      17. 0016325: CRT101 - Modificación de recibos para correduría
      18.0        21/05/2010   ICV      18. 14586: CRT - Añadir campo recibo compañia
      19.0        23/03/2011   DRA      19. 0018054: AGM003 - Administración - Secuencia de nrecibo.
      20.0        18/07/2011   SRA      20. 0018908: LCOL003 - Modificación de las pantallas de gestión de recibos
      21.0        22/11/2011   RSC      21. 0020241: LCOL_T004-Parametrización de Rescates (retiros)
      22.0        07/02/2012   JMF      22. 0021028 LCOL - Duplicar rebuts en rehabilitacions de polisses
      23.0        13/06/2012   JGR      23. 0022512: LCOL_A001-Modificacion medio de pago de Debito a Efectivo - No se modifica el subestado
      24.0        30/05/2012   DCG      24. 0022327: MDP_A001-Consulta de recibos - 0115681
      25.0        11/06/2012   JGR      25. 0022327: MDP_A001-Consulta de recibos - 0115278
      26.0        01/06/2012   JGR      26. 0022082: LCOL_A003-Mantenimiento de matriculas
      27.0        12/12/2012   JGR      27. 0024754: (POSDE100)-Desarrollo-GAPS Administracion-Id 156 - Las consultas de facturas se puedan hacer por sucursal y regional
      28.0        03/04/2013   DCG      28. 0026069: LCOL_F003-Fase 3 - Contabilidad de Autos
      29.0        11/09/2013   CEC      55. 0027691/149541: Incorporación de desglose de Recibos en la moneda del producto
      30.0        06/11/2013   CEC      56. 0026295: RSA702-Desarrollar el modulo de Caja
      31.0        20/03/2014   DRA      31. 0027421: POSAN600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 96 - Recibos remesados en anulaciones
      32.0        06/03/2015   KJSC     32. BUG 35103-200056.KJSC. Se debe sustituir w_empresa por el número de recibo (pnrecibo).
      33.0        21/06/2019   SGM      33. IAXIS-4134 Reporte de acuerdo de pago
      34.0        09/07/2019   DFR      34. IAXIS-3651 Proceso calculo de comisiones de outsourcing
      35.0        17/07/2019   DFR      35. IAXIS-3591 Visualizar los importes del recibo de manera ordenada y sin repetir conceptos.
      36.0        23/10/2019   DFR      36. IAXIS-4926: Anulación de póliza y movimientos con recibos abonados y Reversión de recaudos en recibos.
      37.0        18/11/2019   DFR      37. IAXIS-7627: Verificación de campo CSUBTIPREC de la tabla RECIBOS para efectos contables.
      38.0        19/01/2020   JLTS     38. IAXIS-3264: Se adiciona la funcón f_cmotmov_baja para evaluar la opción de suplemento de baja (239)
   ******************************************************************************/

   /*************************************************************************
          Funcion para obtener los datos de gestión de impagados
          param in pcempres   : código de la empresa
          param in pcmaqfisi  : Máquina física
          param in pcterminal : Terminal Axis
          return           : 0 indica cambio realizado correctamente
                             <> 0 indica error
   *************************************************************************/
   FUNCTION f_get_impagados(psseguro IN NUMBER,
                            pnrecibo IN NUMBER,
                            psmovrec IN NUMBER,
                            pcidioma IN NUMBER) -- BUG14202:DRA:22/04/2010
    RETURN VARCHAR2;

   /*************************************************************************
          Selecciona información sobre recibos dependiendo de los parámetros de entrada
           param in pnrecibo   :   numero de recibo.
           param in pcempres   :   empresa.
           param in psproduc   :   producto
           param in pnpoliza   :   póliza
           param in pncertif   :   certificado.
           param in pciprec    :   tipo de recibo.
           param in pcestrec   :   estado del recibo.
           param in pfemisioini:   fecha de emisión. (inicio del rango)
           param in pfemisiofin:   fecha de emisión.  ( fin del rango)
           param in pfefeini   :   fecha inicio efecto.  (inicio del rango)
           param in pfefefin   :   fecha fin efecto.  (inicio del rango)
           param in ptipo      :   nos indicará si es tomador o asegurado ( tomador :=1, asegurado =2)
                   (check que nos permitirá indicar si buscamos por los datos del tomador o por los datos del asegurado)
           param in psperson   :   código identificador de la persona
           param in pcreccia   :   recibo compañia.
           param in pcramo     :   código identificador del ramo
           param in pcsucursal :   código identificador de la sucursal
           param in pcagente   :   código del agente
   ******************************************************************************/
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
                                  pcreccia    IN VARCHAR2,
                                  --Bug 14586-PFA-21/05/2010- Añadir campo recibo compañia
                                  pcpolcia IN VARCHAR2,
                                  --Bug 14586-PFA-21/05/2010- Añadir campo recibo compañia
                                  pcidioma IN NUMBER, -- BUG14202:DRA:22/04/2010
                                  -- Ini bug 18908 - 18/07/2011 - SRA
                                  pcramo     IN NUMBER,
                                  pcsucursal IN NUMBER,
                                  pcagente   IN NUMBER,
                                  pcxtempres IN NUMBER,
                                  pctipcob   IN NUMBER,
                                  pcondicion IN VARCHAR2 DEFAULT NULL)
   -- Fin bug 18908 - 18/07/2011 - SRA
    RETURN VARCHAR2;

   /*************************************************************************
     Selecciona información sobre recibos dependiendo de los parámetros de entrada
      param in pnrecibo   :   numero de recibo.
      param in pcempres   :   empresa.
      param in psproduc   :   producto
      param in pnpoliza   :   póliza
      param in pncertif   :   certificado.
      param in pciprec    :   tipo de recibo.
      param in pcestrec   :   estado del recibo.
      param in pfemisioini:   fecha de emisión. (inicio del rango)
      param in pfemisiofin:   fecha de emisión.  ( fin del rango)
      param in pfefeini   :   fecha inicio efecto.  (inicio del rango)
      param in pfefefin   :   fecha fin efecto.  (inicio del rango)
      param in ptipo      :   nos indicará si es tomador o asegurado ( tomador :=1, asegurado =2)
              (check que nos permitirá indicar si buscamos por los datos del tomador o por los datos del asegurado)
      param in psperson   :   código identificador de la persona.
   -- Ini bug 18908 - 18/07/2011 - SRA
      param in pcramo     :   código identificador del ramo
      param in psproduc   :   código identificador del producto
      param in pcsucursal :   código identificador de la oficina/sucursal
      param in pcagente   :   código identificador del agente
      param in pctipcob   :   tipo de cobro
      param in pdomi_sn   :   flag de domiciliación: 1 entidad de cobro, 2 gestor
   -- Fin bug 18908 - 18/07/2011 - SRA
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
                                     pcidioma    IN NUMBER,
                                     precunif    IN NUMBER, -- BUG14202:DRA:22/04/2010
                                     pcestimp    IN NUMBER, --Bug.: 16140 - 11/10/2010 - ICV
                                     pcreccia    IN VARCHAR2, --Bug.: 14586 - 16/11/2010 - ICV
                                     pcpolcia    IN VARCHAR2,
                                     pccompani   IN NUMBER, --Bug.: 16310 - 24/12/2010 - JBN)
                                     pliquidad   IN NUMBER, --Bug.: 18732 - 07/06/201 - JBN)
                                     pfiltro     IN NUMBER,
                                     -- Ini bug 18908 - 18/07/2011 - SRA
                                     pcramo     IN NUMBER,
                                     pcsucursal IN NUMBER,
                                     pcagente   IN NUMBER,
                                     pctipcob   IN NUMBER,
                                     pdomi_sn   IN NUMBER,
                                     -- Inici Bug 20326/99335 - BFP 05/12/2011
                                     cbanco     IN NUMBER,
                                     ctipcuenta IN NUMBER, -- Inici Bug 20326/99335 - BFP 05/12/2011
                                     pcxtempres IN NUMBER,
                                     cobban     IN NUMBER, --BUG20501 - JTS - 28/12/2011
                                     prebut_ini VARCHAR2 DEFAULT NULL, --Bug 22080 - 25/06/2012
                                     -- Inici Bug 22327/115681 - DCG 30/05/2011
                                     pnanuali  IN NUMBER DEFAULT NULL,
                                     pnfracci  IN NUMBER DEFAULT NULL,
                                     ptipnegoc IN NUMBER DEFAULT NULL,
                                     -- Fi Bug 22327/115681 - DCG 30/05/2011
                                     pcondicion IN VARCHAR2 DEFAULT NULL,
                                     pctipage01 IN NUMBER DEFAULT NULL,
                                     -- 27. 0024754 POS JGR 12/12/2012
                                     pnrecunif IN VARCHAR2 DEFAULT NULL, --0031322/0175728:NSS:12/06/2014
                                     pnreccaj  IN NUMBER DEFAULT NULL, -- BUG CONF-441 - 14/12/2016 - JAEG
                                     pcmreca   IN NUMBER DEFAULT NULL -- BUG CONF-441 - 14/12/2016 - JAEG
                                     )
   -- Fin bug 18908 - 18/07/2011 - SRA
    RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_detrecibos_det(pcempres IN NUMBER,
                                 pnrecibo IN NUMBER,
                                 pconcep  IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_detrecibos(pcempres IN NUMBER,
                             pnrecibo IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de recuperar el vmovrecibo de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_vdetrecibos(pcempres IN NUMBER,
                              pnrecibo IN NUMBER,
                              pcidioma IN NUMBER)
   -- BUG14202:DRA:22/04/2010
    RETURN VARCHAR2;

   FUNCTION f_get_vdetrecibos_monpol(pcempres IN NUMBER,
                                     pnrecibo IN NUMBER,
                                     pcidioma IN NUMBER)
   -- 027691/149541
    RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_movrecibos(pnrecibo IN NUMBER,
                             pcidioma IN NUMBER)
   -- BUG14202:DRA:22/04/2010
    RETURN VARCHAR2;

   /*************************************************************************
          Se encarga de recuperar la información de un recibo en concreto
          param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_datosrecibo(pnrecibo IN NUMBER,
                              pcidioma IN NUMBER)
   -- BUG14202:DRA:22/04/2010
    RETURN VARCHAR2;

   -- BUG12679:DRA:07/05/2010:Inici
   /*************************************************************************
           Se encarga de recuperar la información de un recibo en concreto
           param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_datosrecibo_mv(pnrecibo IN NUMBER,
                                 pcidioma IN NUMBER) RETURN VARCHAR2;

   -- BUG12679:DRA:07/05/2010:Fi

   /*BUG 0010676: 09/07/2009 : ETM -- CEM - Días de gestión de un recibo */

   /*************************************************************************
       Se encarga de recuperar Nº de dias en los que un recibo pagado se considera que esta en periodo de gestion
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_diasgest(pnrecibo IN NUMBER,
                           pfestrec IN DATE DEFAULT NULL) RETURN NUMBER;

   /****************************************************************************
      F_RECRIES: Calcula  el recibo del seguro.
            pctipreb = 1 => Por tomador   (Solo un recibo)
            pctipreb = 2 => Por asegurado (Tantos recibos como riesgos haya)
            pctipreb = 3 => Por colectivo (Un recibo al tomador) Luego se pasa un prceso
                                        que junta los recibos por póliza incluyendo los certificados.
            pctipreb = 4 => Rebut per aportant (taula aportaseg)
      ALLIBADM
      1.- Devuelve el error que se produce en insrecibo o detrecibo
      2.- Si fallan todos los riesgos (error 103108) no da error
      3.- Se añade el parametro PCMOVIMI para pasarselo a f_insrecibo.
          Nos indica si es producto es de ahorro(pcmovimi not null)
          o no lo es (pcmovimi = null)
      4.- Se distingue entre el modo real y modo pruebas(informe previo)
          Se añade el parametro pcempres
      5.- Desaparece el parámetro psmovseg.
          Se añade el parámetro pnmovimi
      6.- Cambios para el caso de un recibo por riesgo

      7.- El tratamiento de recibo por riesgo no funciona cuando se
               trata de la baja de riesgos. SAVEPOINT anula el cursor cuando
               se hace el rollback. Se añaden los delete's.
      8.- Se hacen dos cursores de riesgos, uno para modo P y otro para modo R
      9.- Se cambia el error 103138 por el error generado por f_detrecibo
          para obtener más información.
      10.- Se añade un nuevo modo = 'H' para la rehabilitación de garantias
                y riesgos. Se lee de garancar y se graba en recibos.
      11.- Se añaden los deletes sobre RECIBOS, MOVRECIBO, RECIBOSREDCOM y
           RECIBOSCAR (pmodo='P') cuando el recibo es por tomador y la función
           F_DETRECIBO no graba ningún concepto y devuelve valor 103108.
           Deberá borrar los datos de AGENTESCOB y AGENTESCOBCAR para ese recibo.
           En F_DETRECIBO se ha vuelto a incorporar la funcionalidad que avisa
           que no se grabaron conceptos y deje de grabar el concepto 99 .
      12.- S'afegeix la gestió dels col.lectius de vida, amb rebuts per aportant
      13.- Se añade el parámetro pcgarant para el caso pmodo = 'A' poder
                pasar la garantía asociada (ahora se graba siempre la 282)
      14.- Se añaden los parametros funcion y tabla para el calculo del primer recibo al tarifar,
                el parametro tabla indica a que tablas tiene que ir a buscar importes ('EST','SOL',NULLL),
                el parametro función indica si estoy tarifando (TAR) o en la cartera o previo de cartera (CAR)
   ****************************************************************************/
   FUNCTION f_recries(pctipreb        IN NUMBER,
                      psseguro        IN NUMBER,
                      pcagente        IN NUMBER,
                      pfemisio        IN DATE,
                      pfefecto        IN DATE,
                      pfvencimi       IN DATE,
                      pctiprec        IN NUMBER,
                      pnanuali        IN NUMBER,
                      pnfracci        IN NUMBER,
                      pccobban        IN NUMBER,
                      pcestimp        IN NUMBER,
                      psproces        IN NUMBER,
                      ptipomovimiento IN NUMBER,
                      pmodo           IN VARCHAR2,
                      pcmodcom        IN NUMBER,
                      pfcaranu        IN DATE,
                      pnimport        IN NUMBER,
                      pcmovimi        IN NUMBER,
                      pcempres        IN NUMBER,
                      pnmovimi        IN NUMBER,
                      pcpoliza        IN NUMBER,
                      pnimport2       OUT NUMBER,
                      pnordapo        IN NUMBER DEFAULT NULL,
                      pcgarant        IN NUMBER DEFAULT NULL,
                      pttabla         IN VARCHAR2 DEFAULT NULL,
                      pfuncion        IN VARCHAR2 DEFAULT 'CAR',
                      ptraspasa       IN NUMBER DEFAULT 1) RETURN NUMBER;

   /****************************************************************************
      F_INSRECIBO : Insertar un registro en la tabla de recibos.
      A Gestión de datos referentes a los recibos
       Controlar error de si f_contador retorna 0
      (quiere decir que nrecibo = 0 (error))
       Afegim les insercions en RECIBOSREDCOM
       Afegim el camp CDELEGA a la taula RECIBOS
       Afegim els paràmetres pnriesgo, psmovseg,
      i la funció f_movrecibo.
      Segons el nou paràmetre pmodo, s' ha de
      grabar a la taula RECIBOS o RECIBOSCAR(es graba el nou paràmetre
      psproces).
      S' afegeix la funció f_insrecibor, per a grabar
      les dades a la xarxa comercial.
      Per correduria s'informen els camps cestaux y cestimp.
      De la select principal, se recuperan ctipemp y cforpag.
      S'afegeix el nou mode ='H' per rehabilitació de riscos i
                    garanties.
       Traballi amb l'agent de venda i permeti digits control "00"
    Si P_CCOBBAN es nulo hacía que el RECIBOS.CESTIMP se grabara
         con un 1 de pendiente de imprimir, incluso cuando el recibo es bancario,
         corregida 1a select para que lo decida dependiendo el CCOBBAN que grabamos en el recibo.

     {Se añaden los parametros funcion y tabla para el calculo del primer recibo al tarifar,
      el parametro tabla indica a que tablas tiene que ir a buscar importes ('EST','SOL',NULLL),
      el parametro función indica si estoy tarifando (TAR) o en la cartera o previo de cartera (CAR)
     }
      Se añade el ctipban (tipo de CCC) y se mofica la llamada a F_CCC
   ****************************************************************************/
   FUNCTION f_insrecibo_adm(psseguro IN NUMBER,
                            pcagente IN NUMBER,
                            pfemisio IN DATE,
                            pfefecto IN DATE,
                            pfvencim IN DATE,
                            pctiprec IN NUMBER,
                            pnanuali IN NUMBER,
                            pnfracci IN NUMBER,
                            pccobban IN NUMBER,
                            pcestimp IN NUMBER,
                            pnriesgo IN NUMBER,
                            pnrecibo IN OUT NUMBER,
                            pmodo    IN VARCHAR2,
                            psproces IN NUMBER,
                            pcmovimi IN NUMBER,
                            pnmovimi IN NUMBER,
                            pfmovini IN DATE,
                            ptipo    IN VARCHAR2 DEFAULT NULL,
                            pcforpag IN NUMBER DEFAULT NULL,
                            -- Si es passen el paràmetres
                            pcbancar IN VARCHAR2 DEFAULT NULL,
                            --  no s'agafen de seguros (dades de l'aportant)
                            pttabla  IN VARCHAR2 DEFAULT NULL,
                            pfuncion IN VARCHAR2 DEFAULT 'CAR',
                            pctipban IN NUMBER DEFAULT NULL) RETURN NUMBER;

   FUNCTION f_detrecibo(pnproces        IN NUMBER,
                        psseguro        IN NUMBER,
                        pnrecibo        IN NUMBER,
                        ptipomovimiento IN NUMBER,
                        pmodo           IN VARCHAR2,
                        pcmodcom        IN NUMBER,
                        pfemisio        IN DATE,
                        pfefecto        IN DATE,
                        pfvencim        IN DATE,
                        pfcaranu        IN DATE,
                        pnimport        IN NUMBER,
                        pnriesgo        IN NUMBER,
                        pnmovimi        IN NUMBER,
                        pcpoliza        IN NUMBER,
                        pnimport2       OUT NUMBER,
                        pcfpagapo       IN NUMBER DEFAULT NULL,
                        pctipapo        IN NUMBER DEFAULT NULL,
                        ppimpapo        IN NUMBER DEFAULT NULL,
                        piimpapo        IN NUMBER DEFAULT NULL,
                        pcgarant        IN NUMBER DEFAULT NULL,
                        pttabla         IN VARCHAR2 DEFAULT NULL,
                        pfuncion        IN VARCHAR2 DEFAULT 'CAR')
      RETURN NUMBER;

   /****************************************************************************
      F_instmpdetrec : Insertar un registro en la tabla de detrecibos.
      ALLIBADM - Gestión de datos referentes a los recibos
        funcion que inserta un registro a detrecibos
                    teniendo en cuenta si es coaseguro cedido, aceptado o no.
                    Esta funcion es llamada por f_detrecibo_coa
        se añaden los parametros psseguro y poragloc
                    para el calculo especial de las comisiones y retenciones.
                    poragloc : El porcentaje del agente en nuestra compañia
       Si nos llega un nuevo importe para un concepto de ese
                    riesgo, garantía lo sumamos.
        Cambios para grabar dos campos mas de la tabla tmp_adm_detrecibos
         Modificamos las selects para que vaya por nmovima
   ****************************************************************************/
   FUNCTION f_instmpdetrec(precibo   IN NUMBER,
                           pconcepto IN NUMBER,
                           pimporte  IN NUMBER,
                           pporcent  IN NUMBER,
                           pgarantia IN NUMBER,
                           priesgo   IN NUMBER,
                           pxctipcoa IN NUMBER,
                           pcageven  IN NUMBER DEFAULT NULL,
                           pnmovima  IN NUMBER DEFAULT 1,
                           pporagloc IN NUMBER DEFAULT 0,
                           psseguro  IN NUMBER DEFAULT 0,
                           pccomisi  IN NUMBER DEFAULT 1) RETURN NUMBER;

   FUNCTION f_trasrecibo(pcempres   IN NUMBER,
                         psseguro   IN NUMBER,
                         num_recibo IN NUMBER,
                         pmodo      IN VARCHAR2) RETURN NUMBER;

   FUNCTION f_tmp_vdetrecibos(pmodo    IN VARCHAR2,
                              pnrecibo IN NUMBER,
                              psproces IN NUMBER DEFAULT 0) RETURN NUMBER;

   FUNCTION f_imprecibos(pnproces        IN NUMBER,
                         pnrecibo        IN NUMBER,
                         ptipomovimiento IN NUMBER,
                         pmodo           IN VARCHAR2,
                         pnriesgo        IN NUMBER,
                         ppdtoord        IN NUMBER,
                         pcrecfra        IN NUMBER,
                         pcforpag        IN NUMBER,
                         pcramo          IN NUMBER,
                         pcmodali        IN NUMBER,
                         pctipseg        IN NUMBER,
                         pccolect        IN NUMBER,
                         pcactivi        IN NUMBER,
                         pcomisagente    IN NUMBER,
                         pretenagente    IN NUMBER,
                         psseguro        IN NUMBER,
                         pcmodcom        IN NUMBER,
                         pmoneda         IN NUMBER DEFAULT 1,
                         pprorata        IN NUMBER,
                         pttabla         IN VARCHAR2 DEFAULT NULL,
                         pfuncion        IN VARCHAR2 DEFAULT 'CAR')
      RETURN NUMBER;

   FUNCTION f_calculo_dtocampanya(psseguro IN NUMBER,
                                  pnriesgo IN NUMBER,
                                  pcgarant IN NUMBER,
                                  pnmovima IN NUMBER,
                                  pfefecto IN DATE,
                                  piprinet IN NUMBER,
                                  pprorata IN NUMBER,
                                  pttabla  IN VARCHAR2,
                                  pidtocam OUT NUMBER) RETURN NUMBER;

   FUNCTION f_extornpos(pnrecibo IN NUMBER,
                        pmodo    IN VARCHAR2,
                        psproces IN NUMBER) RETURN NUMBER;

   -- BUG : 13038 - 22-02-2010 - JMC - Se añade funcion.
   /*
    {Declaración de tipos}
   */
   TYPE rrecibo IS RECORD(
      nrecibo NUMBER,
      fefecto DATE,
      cestrec NUMBER,
      cestimp NUMBER,
      iprinet NUMBER,
      itotalr NUMBER -- BUG14061:DRA:19/05/2010
      );

   /***************************************************************************
      FUNCTION f_get_last_rec
      Dado un sseguro, obtenemos la fecha de efecto del último recibo que cumpla
      ciertas condiciones.
         param in  psseguro:  Código seguro.
         param in  pcestrec:  Estado del recibo 0-Pendiente 1-Cobrado 2-Anulado.
         param in  pcestimp:  Estado de impresión del recibo.
         return:              Record Recibo.
   ***************************************************************************/
   FUNCTION f_get_last_rec(psseguro IN NUMBER,
                           pcestrec IN NUMBER DEFAULT NULL,
                           pcestimp IN NUMBER DEFAULT NULL) RETURN rrecibo;

   -- FIN BUG : 13038 - 22-02-2010 - JMC

   /***************************************************************************
      FUNCTION f_consorci
      Funciones para el cálculo del consorcio.
   ***************************************************************************/
   FUNCTION f_consorci(psproces        IN NUMBER,
                       psseguro        IN NUMBER,
                       pnrecibo        IN NUMBER,
                       pnriesgo        IN NUMBER,
                       pfefecto        IN DATE,
                       pfvencim        IN DATE,
                       pcmodo          IN VARCHAR2,
                       ptipomovimiento IN NUMBER,
                       pcramo          IN NUMBER,
                       pcmodali        IN NUMBER,
                       pcactivi        IN NUMBER,
                       pccolect        IN NUMBER,
                       pctipseg        IN NUMBER,
                       pcduraci        IN NUMBER,
                       pnduraci        IN NUMBER,
                       pnmovimi        IN NUMBER,
                       pgrabar         OUT NUMBER,
                       pnmovimiant     IN NUMBER,
                       pfacconsor      IN NUMBER,
                       pfacconsorfra   IN NUMBER,
                       paltarisc       IN BOOLEAN,
                       pcapieve        IN NUMBER DEFAULT NULL,
                       pttabla         IN VARCHAR2 DEFAULT NULL,
                       pfuncion        IN VARCHAR2 DEFAULT 'CAR',
                       pctipapo        IN NUMBER DEFAULT NULL) RETURN NUMBER;

   /*************************************************************************
       Se encarga de recuperar la información de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_datostmprecibo(pnrecibo IN NUMBER,
                                 pcidioma IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_tmpdetrecibos(pnrecibo IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_tmpdetrecibos_det(pnrecibo IN NUMBER,
                                    pconcep  IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de recuperar la lista de movrecibos de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_tmpmovrecibos(pnrecibo IN NUMBER,
                                pcidioma IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de recuperar el vmovrecibo de un recibo en concreto
       param in pnrecibo   :   numero de recibo.
   *************************************************************************/
   FUNCTION f_get_tmpvdetrecibos(pnrecibo IN NUMBER,
                                 pcidioma IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
       Se encarga de generar el primer movimiento de recibo.
   *************************************************************************/
   FUNCTION f_tmpmovrecibo(pnrecibo  IN NUMBER,
                           pcestrec  IN NUMBER,
                           psmovagr  IN OUT NUMBER,
                           pfmovini  IN DATE,
                           pccobban  IN NUMBER,
                           pcdelega  IN NUMBER,
                           pcmotmov  IN NUMBER,
                           pnomovrec IN NUMBER DEFAULT NULL,
                           pctipcob  IN NUMBER DEFAULT NULL) RETURN NUMBER;

   FUNCTION f_tmprebnoimprim(pnrecibo IN NUMBER,
                             pfmovini IN DATE,
                             pcimprim OUT NUMBER,
                             pcestaux IN NUMBER) RETURN NUMBER;

   FUNCTION f_tmpprima_minima_extorn(psseguro IN NUMBER,
                                     pnrecibo IN NUMBER,
                                     pcestrec IN NUMBER,
                                     pfvalmov IN DATE,
                                     pccobban IN NUMBER,
                                     pcmotmov IN NUMBER,
                                     pcagente IN NUMBER,
                                     pfmovini DATE,
                                     sproduc  NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_tmpfusionsupcar(psseguro IN NUMBER,
                              pnreccar IN NUMBER,
                              pfefecar IN DATE,
                              pfemicar IN DATE,
                              pmodo    IN VARCHAR2,
                              psproces IN NUMBER) RETURN NUMBER;

   FUNCTION f_tmpinsrecibor(pnrecibo IN NUMBER,
                            pcempres IN NUMBER,
                            pcagente IN NUMBER,
                            pfemisio IN DATE) RETURN NUMBER;

   -- Bug 14775 - RSC - 13/08/2010- AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
   FUNCTION f_tmp_genera_prerecibos(p_sseguro IN NUMBER,
                                    p_idioma  IN NUMBER,
                                    psproces  IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
      --BUG 16325 - ICV - 04/11/2010
      Función que para actualizar los importes de los recibos
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
                            pcvalidado IN NUMBER) RETURN NUMBER;

   PROCEDURE p_emitir_propuesta_col(pcempres  IN NUMBER,
                                    pnpoliza  IN NUMBER,
                                    pncertif  IN NUMBER,
                                    pcramo    IN NUMBER,
                                    pcmodali  IN NUMBER,
                                    pctipseg  IN NUMBER,
                                    pccolect  IN NUMBER,
                                    pcactivi  IN NUMBER,
                                    pmoneda   IN NUMBER,
                                    pcidioma  IN NUMBER,
                                    pindice   OUT NUMBER,
                                    pindice_e OUT NUMBER,
                                    pcmotret  OUT NUMBER, -- BUG9640:DRA:16/04/2009
                                    psproces  IN NUMBER DEFAULT NULL,
                                    pnordapo  IN NUMBER DEFAULT NULL,
                                    pcommit   IN NUMBER DEFAULT NULL);

   -- BUG18054:DRA:23/03/2011:Inici
   FUNCTION f_get_seq_cont(pcempres IN NUMBER) RETURN NUMBER;

   -- BUG18054:DRA:23/03/2011:Fi

   /***************************************************************************
      FUNCTION f_es_recibo_ahorro
      Comprueba si el recibo es solo de ahorro.
         param in  pnrecibo: numero de recibo.
         return:  0-No, 1-Si
   ***************************************************************************/
   FUNCTION f_es_recibo_ahorro(pnrecibo IN NUMBER) RETURN NUMBER;

   /***************************************************************************
      FUNCTION f_es_recibo_riesgo
      Comprueba si el recibo es solo de ahorro.
         param in  pnrecibo: numero de recibo.
         return:  0-No, 1-Si
   ***************************************************************************/
   FUNCTION f_es_recibo_riesgo(pnrecibo IN NUMBER) RETURN NUMBER;

   /**********************************************************************************************
      Duplica un rebut.
      pmodali      IN Modalitat: 1- deixa el nou rebut amb estat Pendent, 2- Crea el rebut com a cobrat.
      pnrecibo     IN Recibo anterior a duplicar.
      pnreciboclon OUT : Nuevo número de recibo.
      psmovagr     IN OUT : Secuencial de agrupación recibos.
      pfefecto     IN Fecha efecto nuevo recibo, sino asigna la del recibo anterior.
      porigen      IN Origen peticion de clonar (1-Rehabilitacion).
      pctiprecclon IN Tipo de recibo con el que ha de quedar el clon (1- Suplemento, 9-Extorno) -- IAXIS-4926 23/10/2019
   ************************************************************************************************/
   -- BUG 0021028 - 07/02/2012 - JMF
   FUNCTION f_clonrecibo(pmodali      IN NUMBER,
                         pnrecibo     IN NUMBER,
                         pnreciboclon OUT NUMBER,
                         psmovagr     IN OUT NUMBER,
                         pfefecto     IN DATE DEFAULT NULL,
                         porigen      IN NUMBER DEFAULT 0,
                         pctiprecclon IN NUMBER DEFAULT NULL, -- IAXIS-4926 23/10/2019
                         pcsubtiprecclon IN NUMBER DEFAULT NULL) RETURN NUMBER; -- IAXIS-7627 18/11/2019

   /**********************************************************************************************
      13/06/2012 - 23. 0022512: LCOL_A001-Modificacion medio de pago de Debito a Efectivo - No se modifica el subestado
      Saber si una cuenta corriente de seguro-riesgo o recibo está validada
      pcbancar     Cuenta corriente .
      psseguro     Seguro            (opcional)
      pnriesgo     Número de riesgo  (opcional)
      pnrecibo     Recibo            (opcional)
   ************************************************************************************************/
   FUNCTION f_per_ccc_cvalida(pcbancar IN VARCHAR2,
                              psseguro IN NUMBER DEFAULT NULL,
                              pnriesgo IN NUMBER DEFAULT NULL,
                              pnrecibo IN NUMBER DEFAULT NULL) RETURN NUMBER;

   /**********************************************************************************************
      29/05/2012 - 25. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la información detallada del recibo por garantías.
      pnrecibo     IN Recibo.
      pcidioma     IN Código de idioma
      pnriesgo     IN número de riesgo (opcional)
      pcgarant     IN código de la garantía (opcional)
   ************************************************************************************************/
   FUNCTION f_get_detrecibo_gtias(pnrecibo IN NUMBER,
                                  pcidioma IN NUMBER DEFAULT NULL,
                                  pnriesgo IN NUMBER DEFAULT NULL,
                                  pcgarant IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /**********************************************************************************************
      29/05/2012 - 25. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la información de los recibos agrupados.
      pnrecibo     IN Recibo.
      pcidioma     IN Código de idioma
   ************************************************************************************************/
   FUNCTION f_get_adm_recunif(pnrecibo IN NUMBER,
                              pcidioma IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

   /**********************************************************************************************
      11/06/2012 - 25. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la información detallada extra del recibo.
      pnrecibo     IN Recibo.
      pcidioma     IN Código de idioma
   ************************************************************************************************/
   FUNCTION f_get_datosrecibo_det(pcempres IN NUMBER,
                                  pnrecibo IN NUMBER,
                                  pcidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /**********************************************************************************************
      11/06/2012 - 25. 0022327: MDP_A001-Consulta de recibos - 0115278
      Extrae la información de la tala de complementos de recibos (histórico de acciones)
      pnrecibo     IN Recibo.
      pcidioma     IN Código de idioma
   ************************************************************************************************/
   FUNCTION f_get_recibos_comp(pnrecibo IN NUMBER,
                               pcidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /**********************************************************************************************
      26/06/2012 - 26. 0022082: LCOL_A003-Mantenimiento de matriculas - 0117556
      Retorna el pagador
      psseguro     IN Seguro
      pnrecibo     IN Recibo.
      Retorna el SPERSON del pagador


   ************************************************************************************************/
   FUNCTION f_get_pagador_recibo(pnrecibo IN NUMBER) RETURN NUMBER;

   /**********************************************************************************************
      26/06/2012 - 26. 0022082: LCOL_A003-Mantenimiento de matriculas - 0117556
      Extrae la información de las matrículas - para la consulta de matriculas
      pcempres     IN Empresa
      pnrecibo     IN Recibo.
      pccobban     IN Cobrador bancario
      pnmatric     IN Número de matrícula
      pfenvini     IN Fecha envío desde
      pfenvfin     IN Fecha envío hasta
      pcidioma     IN Código de idioma
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
                             pcidioma IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

   /**********************************************************************************************
      26/06/2012 - 26. 0022082: LCOL_A003-Mantenimiento de matriculas - 0117556
      Extrae la información detallada de una matrícula - para la consulta de matriculas
      pnmatric     IN Número de matrícula
      pcidioma     IN Código de idioma
   ************************************************************************************************/
   FUNCTION f_get_matriculas_det(pnmatric IN VARCHAR2,
                                 pcidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /**********************************************************************************************
      03/04/2013 - 28. 0026069: LCOL_F003-Fase 3 - Contabilidad de Autos
      Extrae la información del Ramo de los productos de autos
      psproduc     IN Producto
      pcgarant     IN Garantía.
   ************************************************************************************************/
   FUNCTION f_cnvprodgaran_ext(psproduc IN NUMBER,
                               pcgarant IN NUMBER) RETURN VARCHAR2;

   /**********************************************************************************************
      Extrae recibos recalculando en pesos a fecha del dia
      psproduc     IN Producto
      pcgarant     IN Garantía.
   ************************************************************************************************/
   FUNCTION f_get_consrecibos_multimoneda(pcempres IN NUMBER,
                                          -- La empresa se recoge de una variable global del contexto
                                          pnrecibo IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pnpoliza IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pitem    IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pcestrec IN NUMBER, -- Siempre 0
                                          pcmonpag IN NUMBER, -- Moneda en que se va a pagar
                                          ptipo    IN NUMBER,
                                          -- Si se informa por pantalla sino NULL. Debe aparecer en la pantalla 1-Contratante 2-Riesgos 3-Pagador
                                          psperson IN NUMBER, -- Si se informa por pantalla sino NULL
                                          pcidioma IN NUMBER,
                                          pfemisio IN DATE DEFAULT NULL)
      RETURN VARCHAR2;

   -- BUG27421:DRA:Inici
   FUNCTION f_recibos_remesados(psseguro IN NUMBER) RETURN NUMBER;

   -- BUG27421:DRA:Fi

   /*******************************************************************************
   FUNCION F_AGRUPARECIBO
   Funci¿n que realiza la unificaci¿n de recibos desde pantalla.
   Tiene dos modalidades de ejecuci¿n:
    1.- Agrupa los recibos de cartera anterior a la fecha pasada por par¿metro.
    2.- Agrupa los recibos pasados en la colecci¿n T_LISTA_ID.

   Par¿metros:
     param in psproduc  : Codigo de producto
     param in pfecha    : Fecha de limite
     param in pfemisio  : Fecha de emisi¿n de la unificaci¿n
     param in pcempres  : C¿digo de empresa
     param in plistarec : Colecci¿n de recibos
     return: number un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
   ********************************************************************************/
   -- /* Formatted on 25/06/2014 17:00 (Formatter Plus v4.8.8) - (CSI-Factory Standard Format v.2.0) */
   --0031322/0175728:NSS;11/06/2014: Unificaci¿n de recibos
   FUNCTION f_agruparecibo_manual(psproduc       IN NUMBER,
                                  pfecha         IN DATE,
                                  pfemisio       IN DATE,
                                  pcempres       IN NUMBER,
                                  plistarec      IN t_lista_id DEFAULT NULL,
                                  pctiprec       IN NUMBER DEFAULT 3,
                                  pextornn       IN NUMBER DEFAULT 0,
                                  pcommitpag     IN NUMBER DEFAULT 1,
                                  pctipapor      IN NUMBER DEFAULT NULL,
                                  pctipaportante IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
  --IGIL_INI-CONF_443-20161213
  FUNCTION f_get_detrecibos_det_fcambio(
      pcempres IN NUMBER,
      pnrecibo IN NUMBER,
      pconcep  IN NUMBER )
    RETURN VARCHAR2;

  FUNCTION f_get_detrecibos_fcambio(
      pcempres IN NUMBER,
      pnrecibo IN NUMBER)
    RETURN VARCHAR2;
  --IGIL_FI-CONF_443-20161213
  FUNCTION f_get_posicion_retaplica_sap(pccodigo IN VARCHAR2)
    RETURN NUMBER;
   -- INI SGM IAXIS-4134 Reporte de acuerdo de pago
   /*******************************************************************************
   FUNCION PAC_IAX_ADM.f_get_recibos_saldos
   funcion que me trae todos los recibos que corresponden a una poliza, con su respectivo saldo por pagar

   Parametros:
     param in pnpoliza : Numero poliza
     param out psquery : query con los recibos y saldos
     param out mensajes: manejo de errores
     return: number un numero con el id del error, en caso de que todo vaya OK, retornar un cero.
   ********************************************************************************/    
FUNCTION f_get_recibos_saldos(
      pnpoliza    IN     NUMBER,
      psquery OUT VARCHAR2)
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
FUNCTION f_calcula_comisiones(pnrecibo IN NUMBER) RETURN NUMBER;
/*************************************************************************
 FUNCION f_get_info_pagos_out
 Funcion para obtener la información por orden de pago para cada outsourcing
 param in pnnumide :  Outsourcing
 param in pnnumord :  Número de orden de pago
 return            :  0 indica comisión calculada correctamente. 
                   <> 0 Proceso incorrecto.
 *************************************************************************/
--     
FUNCTION f_get_info_pagos_out(pnnumide IN VARCHAR2, pnnumord IN NUMBER) RETURN VARCHAR2;   
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
                             pivalpagerp IN NUMBER) 
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
FUNCTION f_get_info_coa(pnrecibo IN NUMBER) RETURN VARCHAR2;   
--
-- Fin IAXIS-3591 17/07/2019
-- 
  -- INI --IAXIS-3264 -19/01/2020
  /*************************************************************************
  FUNCION f_cmotmov_baja
  Funcion para obtener si el movimiento que se está realizando es un movimeinto de baja de amparo
  param in psseguro  :  Seguro
  param in pnmovimi  :  Movimiento
  param in pnnrecibo :  Recibo
  return             :  Cursor con compañías aceptantes y sus respectivos importes.
  *************************************************************************/
  FUNCTION f_cmotmov_baja(psseguro IN movseguro.sseguro%TYPE,
                          pnmovimi IN movseguro.nmovimi%TYPE,
                          pnrecibo IN recibos.nrecibo%TYPE) RETURN NUMBER;
  -- FIN --IAXIS-3264 -19/01/2020
  /************************************************************************************************
  FUNCION f_porc_comisi
  Funcion para  generar el porcentaje de comision por poliza y mov. del recibo
  param in psseguro  :  Seguro
  param in pnmovimi  :  Movimiento
  return             :  porcentaje de comision poliza.
   *************************************************************************************************/
  FUNCTION f_porc_comisi(pi_sseguro IN NUMBER ,pi_nmovimi IN NUMBER) RETURN NUMBER;
  
  /*************************************************************************************************/
  function f_get_import_vdetrecibos(
           pcempres   in   number,
           pnrecibo   in   number,
           pctipo   in   number)
   return varchar2;
   
   function f_get_import_vdetrecibos_mon(
           pcempres   in   number,
           pnrecibo   in   number,
           pctipo   in   number)
   return varchar2;

END pac_adm;
/

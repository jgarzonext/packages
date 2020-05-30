
  CREATE OR REPLACE PACKAGE BODY "PAC_MD_OBTENERDATOS" IS
   /******************************************************************************
   --      NOMBRE:       PAC_MD_OBTENERDATOS
   PROPOSITO: Recupera la informacion de la poliza guardada en la base de datos
   REVISIONES:
   Ver        Fecha        Autor             Descripcion
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/09/2007   ACC                1. Creacion del package.
   2.0        17/03/2009   RSC                2. Analisis adaptacion productos indexados
   3.0        15/04/2009   DRA                3. 0009314: APR - pesonalizacion de la aplicacion (configuracion de campos)
   4.0        23/04/2009   DRA                4. 0009718: IAX - clausulas especiales por producto
   5.0        20/04/2009   SBG                5. Modifs. en cridar a pac_md_listvalores.p_ompledadesdireccions (Bug 7624)
   6.0        13/05/2009   APD                6. Bug 9390: se comprueba si la poliza esta bloqueada o pignorada
   7.0        15/05/2009   APD                7. Bug 9639: se comprueba si la poliza esta programada para la anulacion en el proximo recibo
   7.1        19/05/2009   APD                7.1 Bug 8670 - Se revisa la creacion incorrecta de mensajes
   8.0        15/06/2009   RSC                8. Bug 10040 - Ajustes PPJ Dinamico y PLa Estudiant
   9.0        16/07/2009   RSC                9. 0010101: APR - Detalle de garantias (Consulta de Polizas)
   10.0       22/07/2009   XPL               10. Bug 10702 - Nueva pantalla para contratacion y suplementos que permita seleccionar cuentas aseguradas.
   11.0       29/07/2009   DRA               11. 0010519: CRE - Incidencia suplementos ramo salud (2)
   12.0       16/09/2009   AMC               12. 11165: Se sustitu¿e  T_iax_saldodeutorseg por t_iax_prestamoseg
   13.0       30/09/2009   DRA               13. 0011183: CRE - Suplemento de alta de asegurado ya existente
   14.0       02/11/2009   DRA               14. 0011618: AGA005 - Modificacion de red comercial y gestion de comisiones.
   15.0       16/12/2009   RSC               15. 0010690: APR - Provisiones en productos de cartera (PORTFOLIO)
   16.0       15/12/2009   NMM               16. 10831: CRE - Estado de polizas vigentes con fecha de efecto futura
   18.0       28/01/2010   RSC               19. 0011735: APR - suplemento de modificacion de capital /prima
   19.0       03/03/2010   FAL               20. 0013483: CEM998 - Afegir NCONTRATO a la consulta de p¿lisses
   20.0       27/04/2010   JRH               20. 0014285 CEM:Se a¿ade interes y fppren
   21.0       16/06/2010   RSC               21. 0013832: APRS015 - suplemento de aportaciones ¿nicas
   22.0       23/06/2010   RSC               22. 0014598: CEM800 - Informacion adicional en pantallas y documentos
   23.0       30/07/2010   XPL               23. 14429: AGA005 - Primes manuals pels productes de Llar, CTARMAN
   24.0       06/08/2010   PFA               24. 14598: CEM800 - Informacion adicional en pantallas y documentos
   25.0       10/06/2010   PFA               25. 14585: CRT001 - A¿adir campo poliza compa¿ia
   26.0       13/12/2010   APD               26. 16768: APR - Implementacion y parametrizacion del producto GROUPLIFE (II)
   27.0       30/06/2010   RSC               27. 0015057: field capital by provisions SRD
   28.0       11/04/2011   APD               28. 0018225: AGM704 - Realizar la modificacion de precision el cagente
   29.0       19/04/2011   DRA               29. 0018244: AGA301 - revision de la liquidacion del reaseguro 1er trimestre
   30.0       31/05/2011   APD               30. 0018362: LCOL003 - Parametros en clausulas y visualizacion clausulas automaticas
   31.0       09/05/2011   RSC               31. 0018342: LCOL003 - Revalorizacion de capital tipo 'Lista de valores'
   32.0       26/07/2011   RSC               32. 0019027: 0019027: LCOL003-Tamany del camp CRAMO
   33.0       26/07/2011   DRA               33. 0017255: CRT003 - Definir propuestas de suplementos en productos
   34.0       08/09/2011   APD               34. 0018848: LCOL003 - Vigencia fecha de tarifa
   35.0       20/10/2011   ICV               35. 0019152: LCOL_T001- Beneficiari Nominats - LCOL_TEC-02_Emision_Brechas01
   36.0       27/09/2011   DRA               36. 0019069: LCOL_C001 - Co-corretaje
   37.0       19/12/2011   RSC               37. 0020595: LCOL - UAT - TEC - Errors tarificant i aportacions
   38.0       05/01/2012   DRA               38. 0020431: CRE800 - Alta assegurats p?ses col¿lectives
   39.0       03/01/2012   JMF               39. 0020761 LCOL_A001- Quotes targetes
   40.0       12/01/2012   DRA               40. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
   41.0       01/03/2012   APD               41. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
   42.0       08/03/2012   JMF                0021592: MdP - TEC - Gestor de Cobro
   43.0       17/04/2012   ETM               43.0021924: MDP - TEC - Nuevos campos en pantalla de Gesti?Tipo de retribuci?Domiciliar 1¿ recibo, Revalorizaci?ranquicia)
   44.0       18/06/2012   MDS               44. 0021924: MDP - TEC - Nuevos campos en pantalla de Gesti?n (Tipo de retribuci?n, Domiciliar 1? recibo, Revalorizaci?n franquicia)
   45.0       04/06/2012   ETM               45. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
   46.0       31/07/2012   FPG               46. 0023075: LCOL_T010-Figura del pagador
   47.0       14/08/2012   DCG               47. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   48.0       03/09/2012   JMF               0022701: LCOL: Implementaci?n de Retorno
   49.0       29/10/2012   DRA               49. 0023991: LCOL: Proves comptabilitat de co-corretatge
   50.0       06/11/2012   XVM               50. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   51.0       05/12/2012   JLTS              51. 0024714: LCOL_T001-QT 5382: No existen movimientos de anulaci?n ni la causa siniestro/motivo para polizas prorrogadas/saldadas. Se adiciona campo CTIPO en f_leedatosreemplazos
   52.0       17/12/2012   ECP               52. 0025143: LCOL_T031-Adaptar el modelo de datos de autos
   53.0       08/01/2013   APD               53. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
   54.0       20/12/2012   MDS               54. 0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
   55.0       13/02/2013   MAL               53. 0025581: LCOL_C001-LCOL: Q-trackers de co-corretaje
   56.0       19/02/2013   MMS               56. 0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza ?hasta edad? y edades permitidas por producto- Modificar f_leedatosgestion i f_leedatosgenpoliza
   57.0       26/02/2013   JDS               57. 025964: LCOL - AUT - Experiencia
   58.0       04/03/2013   JDS               58. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V)
   56.0       25/02/2013   NMM               56. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
   59.0       21/02/2013   ECP               59. 0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
   60.0       25/06/2013   RCL               60. 0024697: Canvi mida camp sseguro
   61.0       15/07/2013   MDS               61. 0027304: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Rentas Vitalicias
   62.0       21/08/2013   JSV               62. 0027953: LCOL - Autos Garantias por Modalidad
   63.0       30/09/2013   JMF               0027305: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Conmutacion Pensional
   64.0       17/10/2013   FAL               63. 0027735: RSAG998 - Pago por cuotas
   65.0       12/11/2013   RCL               65. 0028455: LCOL_T031- TEC - Revisi?-Trackers Fase 3A II
   66.0       21/01/2014   JTT               66. 0026501: A?r el parametro PMT_NPOLIZA a las preguntas de tipo CONSULTA
   67.0       06/05/2014   ECP               67. 0031204: LCOL896-Soporte a cliente en Liberty (Mayo 2014) /0012459: Error en beneficiarios al duplicar Solicitudes
   68.0       15/05/2014   JTT               68. 0029943: Modificamos f_leerprovisionesgar, a?adimos el parametro TIPO_PB a la validacion
   69.0       05/06/2014   JTT               69. 0029943: Modificamos f_leegarantias ara que para el TIPO_PU=1 se trate como una poliza sin detalle de garantias
   70.0       06/06/2014   ELP               70. 0027500: Nueva operativa mandatos RSA
   71.0       02/9/2014    FAL               71. 0031992: LCOL_T010-Revisi?n incidencias qtracker (2014/07)
   72.0       11/05/2015   YDA               72. Se crea la funci?n f_evoluprovmatseg_scen y se incluye el parametro pnscenario en f_leeevoluprovmatseg
   73.0       04/06/2015   YDA               73. Se crea la funci?n f_evoluprovmatseg_minscen
   74.0       22/06/2015   CJMR              74. 36397/208377: PRB. Ajuste consulta de movimiento del suplemento de regularizaci¿n
   75.0       03/07/2015   YDA               74. 0036596: Se crea la funci¿n f_get_exclusiones
   76.0       05/08/2015   YDA               76. 0036596: Se crea la funci¿n f_lee_enfermedades
   77.0       10/08/2015   YDA               77. 0036596: Se crea la funci¿n f_lee_preguntas
   78.0       12/08/2015   YDA               78. 0036596: Se crea la funci¿n f_lee_acciones
   79.0       14/08/2015   JCP               79. 0036596: Se modifica la funcion f_get_exclusiones
   80.0       09/12/2015   FAL               80. 0036730: I - Producto Subsidio Individual
   82.0       17/03/2016   JAEG              82. 41143/229973: Desarrollo Dise¿o t¿cnico CONF_TEC-01_VIGENCIA_AMPARO
   83.0       07/03/2016   JAEG              83. 40927/228750: Desarrollo Dise¿o t¿cnico CONF_TEC-03_CONTRAGARANTIAS
   84.0       15/08/2019   CJMR              84. IAXIS-4205: Endosos RC. Ajustes de actividad
   85.0       23/09/2019   CJMR              85. IAXIS-5423: Ajustes deducibles.
   86.0       21/01/2020   JLTS              86. IAXIS-10627. Se ajustó la función f_leecorretaje incluyendo el parámetro NMOVIMI
   *****************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;
   vg_idioma      NUMBER := pac_md_common.f_get_cxtidioma;
   vpmode         VARCHAR2(3);
   vsolicit       NUMBER;
   vnmovimi       NUMBER;

   /*************************************************************************
   Devuelve los reemplazos de la poliza
   param in psseguro   : numero de seguro
   param in ptablas    : tablas donde hay que ir a buscar la informacion
   param out mensajes : mesajes de error
   return             : Impporte del capital
   Bug 19276 REEMPLAZOS
   *************************************************************************/
   FUNCTION f_leedatosreemplazos(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reemplazos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leedatosreemplazo';
      reemplazos     t_iax_reemplazos;
      reemplazo      ob_iax_reemplazos;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      reemplazos := t_iax_reemplazos();

      BEGIN
         IF ptablas = 'EST' THEN
            FOR cur IN (SELECT DISTINCT sseguro, sreempl, fmovdia, cusuario, cagente, ctipo
                                   FROM estreemplazos
                             START WITH sseguro = psseguro
                                     OR sreempl = psseguro
                             CONNECT BY PRIOR sreempl = sseguro
                               ORDER BY fmovdia) LOOP
               reemplazos.EXTEND;
               reemplazos(reemplazos.LAST) := ob_iax_reemplazos();
               reemplazos(reemplazos.LAST).sseguro := cur.sseguro;
               reemplazos(reemplazos.LAST).sreempl := cur.sreempl;
               reemplazos(reemplazos.LAST).fmovdia := cur.fmovdia;
               reemplazos(reemplazos.LAST).cusuario := cur.cusuario;
               reemplazos(reemplazos.LAST).cagente := cur.cagente;
               reemplazos(reemplazos.LAST).ctipo := cur.ctipo;

               --   BUG 24714 - JLTS - Se adiciona el campo CTIPO
               IF reemplazos(reemplazos.LAST).cagente IS NOT NULL THEN
                  reemplazos(reemplazos.LAST).tagente :=
                                             ff_desagente(reemplazos(reemplazos.LAST).cagente);
               END IF;

               SELECT npoliza,
                      ncertif
                 INTO reemplazos(reemplazos.LAST).npolizareempl,
                      reemplazos(reemplazos.LAST).ncertifreempl
                 FROM seguros
                WHERE sseguro = cur.sreempl;

               SELECT npoliza,
                      ncertif
                 INTO reemplazos(reemplazos.LAST).npolizanueva,
                      reemplazos(reemplazos.LAST).ncertifnueva
                 FROM seguros
                WHERE sseguro = cur.sseguro;
            END LOOP;
         ELSE
            FOR cur IN (SELECT DISTINCT sseguro, sreempl, fmovdia, cusuario, cagente, ctipo
                                   FROM reemplazos
                             START WITH sseguro = psseguro
                                     OR sreempl = psseguro
                             CONNECT BY PRIOR sreempl = sseguro
                               ORDER BY fmovdia) LOOP
               reemplazos.EXTEND;
               reemplazos(reemplazos.LAST) := ob_iax_reemplazos();
               reemplazos(reemplazos.LAST).sseguro := cur.sseguro;
               reemplazos(reemplazos.LAST).sreempl := cur.sreempl;
               reemplazos(reemplazos.LAST).fmovdia := cur.fmovdia;
               reemplazos(reemplazos.LAST).cusuario := cur.cusuario;
               reemplazos(reemplazos.LAST).cagente := cur.cagente;
               reemplazos(reemplazos.LAST).ctipo := cur.ctipo;

               --   BUG 24714 - JLTS - Se adiciona el campo CTIPO
               IF reemplazos(reemplazos.LAST).cagente IS NOT NULL THEN
                  reemplazos(reemplazos.LAST).tagente :=
                                             ff_desagente(reemplazos(reemplazos.LAST).cagente);
               END IF;

               SELECT npoliza,
                      ncertif
                 INTO reemplazos(reemplazos.LAST).npolizareempl,
                      reemplazos(reemplazos.LAST).ncertifreempl
                 FROM seguros
                WHERE sseguro = cur.sreempl;

               SELECT npoliza,
                      ncertif
                 INTO reemplazos(reemplazos.LAST).npolizanueva,
                      reemplazos(reemplazos.LAST).ncertifnueva
                 FROM seguros
                WHERE sseguro = cur.sseguro;
            END LOOP;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      RETURN reemplazos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leedatosreemplazos;

/*************************************************************************
Define con que tablas se trabajara
param in pmode     : modo a trabajar
param out mensajes : mesajes de error
*************************************************************************/
   PROCEDURE define_mode(pmode IN VARCHAR2, mensajes IN OUT t_iax_mensajes) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.Define_Mode';
   BEGIN
      SELECT DECODE(NVL(UPPER(pmode), 'SOL'), 'EST', 'EST', 'SOL', 'SOL', 'POL', 'POL', 'SOL')
        INTO vpmode
        FROM DUAL;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END define_mode;

/*************************************************************************
Devuelve la descripcion del riesgo
param in pmode     : modo a trabajar
param in psolicit  : n¿mero de seguro
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : descripcion del riesgo
*************************************************************************/
   FUNCTION f_desriesgos(
      pmode IN VARCHAR2,
      psolicit IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      descp          VARCHAR2(1000) := '**';
      --// ACC revisar pq si no te la taula riesgos no mostra el ** sino blank
      errnum         NUMBER;
      pcobjase       NUMBER;
      pfriesgo       DATE;
      w_triesgo1     VARCHAR2(250);
      w_triesgo2     VARCHAR2(250);
      w_triesgo3     VARCHAR2(250);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                  := 'pmode=' || pmode || ' psolicit=' || psolicit || ' pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_Desriesgos';
   BEGIN
      IF pmode = 'SOL' THEN
         RETURN '**';
      ELSIF pmode = 'EST' THEN
         vpasexec := 3;
         errnum := f_estdesriesgo1(psolicit, pnriesgo, NULL, descp, 300);

         IF errnum <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);
            RETURN '**';
         END IF;
      ELSE
         vpasexec := 5;
         errnum := f_desriesgo(psolicit, pnriesgo, NULL, vg_idioma, w_triesgo1, w_triesgo2,
                               w_triesgo3);

         IF errnum <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, errnum);
            RETURN '**';
         END IF;

         -- LPS (18/06/2008), para que no salgan guiones en el riesgo si son nulos los parametros.
         IF w_triesgo1 IS NOT NULL THEN
            descp := w_triesgo1;
         END IF;

         IF w_triesgo2 IS NOT NULL THEN
            IF descp IS NULL THEN
               descp := w_triesgo2;
            ELSE
               descp := descp || ' - ' || w_triesgo2;
            END IF;
         END IF;

         IF w_triesgo3 IS NOT NULL THEN
            IF descp IS NULL THEN
               descp := w_triesgo3;
            ELSE
               descp := descp || ' - ' || w_triesgo3;
            END IF;
         END IF;
      END IF;

      RETURN descp;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN '**';
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN '**';
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN '**';
   END f_desriesgos;

/*************************************************************************
Devuelve la descripcion del riesgo
param in pmode     : modo a trabajar
param in psseguro  : n¿mero de seguro
param in pnriesgo  : n¿mero de riesgo
return             : descripcion del riesgo
'***' si se ha produccido un error.
*************************************************************************/
   FUNCTION f_desriesgos(pmode IN VARCHAR2, psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2 IS
      vdescp         VARCHAR2(600);
      mensajes       t_iax_mensajes := t_iax_mensajes();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - pmode: ' || pmode || ' - psseguro: ' || psseguro || ' - pnriesgo: '
            || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_Desriesgos';
   BEGIN
      --Comprovacio de par¿metres d'entrada
      IF pmode IS NULL
         OR pmode NOT IN('EST', 'POL')
         OR psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vdescp := f_desriesgos(pmode, psseguro, pnriesgo, mensajes);

      IF vdescp IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vdescp;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN '***';
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN '***';
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN '***';
   END f_desriesgos;

/*************************************************************************
Devuelve el tipo de riesgo objeto asegurado
param in psolicit  : n¿mero de seguro
param in pmode     : modo a trabajar
param out mensajes : mesajes de error
return             : codigo objeto asegurado
*************************************************************************/
   FUNCTION f_getobjase(psolicit IN NUMBER, pmode IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cobjase        NUMBER;
      ssql           VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psolicit=' || psolicit || ' pmode=' || pmode;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_GetObjAse';
   BEGIN
      IF pmode = 'SOL' THEN
         ssql := 'SELECT cobjase FROM SOLSEGUROS WHERE ssolicit = ' || psolicit;
      ELSIF pmode = 'EST' THEN
         ssql := 'SELECT cobjase FROM ESTSEGUROS WHERE sseguro = ' || psolicit;
      ELSE
         ssql := 'SELECT cobjase FROM SEGUROS WHERE sseguro = ' || psolicit;
      END IF;

      EXECUTE IMMEDIATE ssql
                   INTO cobjase;

      RETURN cobjase;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_getobjase;

/*************************************************************************
Modifica el tomador para indicar que es asegurado
param in out tom  : objeto tomadores
*************************************************************************/
   PROCEDURE p_findistomador(tom IN OUT ob_iax_tomadores) IS
      msj            t_iax_mensajes;
      exist          NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'SPERSON=' || tom.sperson;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.P_FindIsTomador';
   BEGIN
      IF vpmode = 'EST' THEN
         SELECT COUNT(*)
           INTO exist
           FROM estassegurats
          WHERE sseguro = vsolicit
            AND sperson = tom.sperson
            AND ffecfin IS NULL;   -- BUG11183:DRA:30/09/2009
      ELSIF vpmode = 'POL' THEN
         SELECT COUNT(*)
           INTO exist
           FROM asegurados
          WHERE sseguro = vsolicit
            AND sperson = tom.sperson
            AND ffecfin IS NULL;   -- BUG11183:DRA:30/09/2009
      END IF;

      IF exist > 0 THEN
         tom.isaseg := 1;
      ELSE
         tom.isaseg := 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msj, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msj, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msj, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_findistomador;

/*************************************************************************
Inicializa ejecucion package
param in pmode     : modo a trabajar
param in pssolicit : codigo de seguro
param in pnmovimi  : n¿mero de movimientos
param out mensajes : mesajes de error
return             : 0 todo ha sido correcto
1 ha habido un error
*************************************************************************/
   FUNCTION f_inicializa(
      pmode IN VARCHAR2,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER DEFAULT 1,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                := 'pmode=' || pmode || ' pssolicit=' || pssolicit || ' pnmovimi=' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_Inicializa';
   BEGIN
      IF NVL(pssolicit, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001119);
         --'No se ha indicado un codigo correcto
         RAISE e_param_error;
      END IF;

      vsolicit := pssolicit;
      vnmovimi := NVL(pnmovimi, 1);
      define_mode(pmode, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_inicializa;

/*************************************************************************
Lee los datos de la poliza
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leedatospoliza(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_detpoliza IS
      CURSOR estseg IS
         SELECT s.*
           FROM estseguros s
          WHERE s.sseguro = vsolicit;

      CURSOR polseg IS
         SELECT s.*
           FROM seguros s
          WHERE s.sseguro = vsolicit;

      det_poliza     ob_iax_detpoliza := ob_iax_detpoliza();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeDatosPoliza';
   BEGIN
      IF vpmode = 'EST' THEN
         FOR eseg IN estseg LOOP
            det_poliza.sseguro := eseg.sseguro;
            det_poliza.ssegpol := eseg.ssegpol;
            det_poliza.nmovimi := NVL(vnmovimi, 1);
            det_poliza.nsuplem := eseg.nsuplem;
            det_poliza.npoliza := eseg.npoliza;
            det_poliza.ncertif := eseg.ncertif;
            det_poliza.cmodali := eseg.cmodali;
            det_poliza.ccolect := eseg.ccolect;
            det_poliza.cramo := eseg.cramo;
            det_poliza.ctipseg := eseg.ctipseg;
            --det_poliza.cactivi := eseg.cactivi;
            det_poliza.sproduc := eseg.sproduc;
            det_poliza.cagente := eseg.cagente;
            det_poliza.cobjase := eseg.cobjase;
            det_poliza.csituac := eseg.csituac;
            det_poliza.creteni := eseg.creteni;
            det_poliza.ctipreb := eseg.ctipreb;
            det_poliza.cagrpro := eseg.cagrpro;
            det_poliza.cempres := eseg.cempres;
            det_poliza.ctarman := eseg.ctarman;
            det_poliza.creccob := eseg.creccob;
            det_poliza.crevali := eseg.crevali;
            det_poliza.irevali := eseg.irevali;
            det_poliza.prevali := eseg.prevali;
            --det_poliza.crecfra := eseg.crecfra; mantis 7920.
            det_poliza.nrenova := eseg.nrenova;
            det_poliza.nanuali := eseg.nanuali;
            det_poliza.crecman := eseg.crecman;
            det_poliza.casegur := eseg.casegur;
            det_poliza.ccompani := eseg.ccompani;
            det_poliza.creafac := eseg.creafac;
            det_poliza.ctiprea := eseg.ctiprea;
            det_poliza.ctipcol := eseg.ctipcol;
            det_poliza.ctipcoa := eseg.ctipcoa;
            det_poliza.ncuacoa := eseg.ncuacoa;
            det_poliza.sfbureau := eseg.sfbureau;
            det_poliza.contragaran :=
               f_leecontgaran
                             (psseguro => eseg.sseguro,   -- Bug 40927/228750 - 07/03/2016 - JAEG
                                                       mensajes => mensajes);

            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
            IF eseg.ctipcoa IS NOT NULL THEN
               det_poliza.ttipcoa := ff_desvalorfijo(800109, pac_md_common.f_get_cxtidioma(),
                                                     eseg.ctipcoa);
            END IF;

            -- Fi Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
            det_poliza.cpolcia := eseg.cpolcia;
            -- BUG 14585 - PFA - Anadir campo poliza compania
            det_poliza.nfracci := eseg.nfracci;
            -- dra 22-12-2008: bug mantis 8121
            det_poliza.trevali := ff_desvalorfijo(62, pac_md_common.f_get_cxtidioma(),
                                                  eseg.crevali);
            -- fal 03-03-2010: bug 13483
            det_poliza.ncontrato := pac_propio.f_calc_contrato_interno(eseg.cagente,
                                                                       eseg.sseguro);

            IF eseg.ctiprea = 2 THEN
               det_poliza.creatip := 1;
            ELSIF eseg.creafac = 1 THEN
               det_poliza.creatip := 2;
            ELSE
               det_poliza.creatip := 0;
            END IF;

            -- xpl 22-07-2009: bug mantis 10702
            BEGIN
               SELECT icapmax
                 INTO det_poliza.icapmaxpol
                 FROM estsaldodeutorseg
                WHERE sseguro = vsolicit
                  AND nmovimi = NVL(vnmovimi, 1);
            -- BUG12421:DRA:28/01/2010
            EXCEPTION
               WHEN OTHERS THEN
                  det_poliza.icapmaxpol := NULL;
            END;

            -- bug 19372/91763-12/09/2011-AMC
            det_poliza.cpromotor := eseg.cpromotor;
            -- Fi bug 19372/91763-12/09/2011-AMC
            -- BUG20431:DRA:05/01/2011:Inici:Lo paso dentro del LOOP para que no de error si no recupera seguros
            -- bug 19276 reemplazos
            det_poliza.reemplazos := f_leedatosreemplazos(det_poliza.sseguro, vpmode, mensajes);
            -- fi bug 19276 reemplazos
            -- Bug 36596 IGIL INI
            det_poliza.citamedicas := f_leecitamedica(vsolicit, det_poliza.sseguro, 'EST',
                                                      mensajes);
            -- Bug 36596 IGIL FIN
            det_poliza.nmesextra := f_leermesesextra(det_poliza.sseguro, mensajes);
            det_poliza.cmodextra := f_leer_cmodextra(det_poliza.sproduc, mensajes);
         -- BUG20431:DRA:05/01/2011:Fi
         END LOOP;
      ELSE
         FOR pseg IN polseg LOOP
            det_poliza.sseguro := pseg.sseguro;
            det_poliza.nmovimi := NVL(vnmovimi, 1);
            det_poliza.nsuplem := pseg.nsuplem;
            det_poliza.npoliza := pseg.npoliza;
            det_poliza.ncertif := pseg.ncertif;
            det_poliza.cmodali := pseg.cmodali;
            det_poliza.ccolect := pseg.ccolect;
            det_poliza.cramo := pseg.cramo;
            det_poliza.ctipseg := pseg.ctipseg;
            --det_poliza.cactivi := pseg.cactivi;
            det_poliza.sproduc := pseg.sproduc;
            det_poliza.cagente := pseg.cagente;
            det_poliza.cobjase := pseg.cobjase;
            det_poliza.csituac := pseg.csituac;
            det_poliza.creteni := pseg.creteni;
            det_poliza.ctipreb := pseg.ctipreb;
            det_poliza.cagrpro := pseg.cagrpro;
            det_poliza.cempres := pseg.cempres;
            det_poliza.ctarman := pseg.ctarman;
            det_poliza.creccob := pseg.creccob;
            det_poliza.crevali := pseg.crevali;
            det_poliza.irevali := pseg.irevali;
            det_poliza.ccompani := pseg.ccompani;
            det_poliza.prevali := pseg.prevali;
            --det_poliza.crecfra := pseg.crecfra; mantis 7920
            det_poliza.nrenova := pseg.nrenova;
            det_poliza.nanuali := pseg.nanuali;
            det_poliza.crecman := pseg.crecman;
            det_poliza.casegur := pseg.casegur;
            det_poliza.creafac := pseg.creafac;
            det_poliza.ctiprea := pseg.ctiprea;
            det_poliza.ctipcol := pseg.ctipcol;
            det_poliza.ctipcoa := pseg.ctipcoa;
            det_poliza.ncuacoa := pseg.ncuacoa;
            det_poliza.nfracci := pseg.nfracci;
            det_poliza.cpolcia := pseg.cpolcia;
            det_poliza.sfbureau := pseg.sfbureau;
            det_poliza.contragaran :=
               f_leecontgaran
                             (psseguro => pseg.sseguro,   -- Bug 40927/228750 - 07/03/2016 - JAEG
                                                       mensajes => mensajes);
            -- BUG 14585 - PFA - Anadir campo poliza compania
            -- dra 22-12-2008: bug mantis 8121
            det_poliza.trevali := ff_desvalorfijo(62, pac_md_common.f_get_cxtidioma(),
                                                  pseg.crevali);
            -- fal 03-03-2010: bug 13483
            det_poliza.ncontrato := pac_propio.f_calc_contrato_interno(pseg.cagente,
                                                                       pseg.sseguro);
            -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
            det_poliza.ttipcoa := ff_desvalorfijo(800109, pac_md_common.f_get_cxtidioma(),
                                                  pseg.ctipcoa);

            -- Fi Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
            IF pseg.ctiprea = 2 THEN
               det_poliza.creatip := 1;
            ELSIF pseg.creafac = 1 THEN
               det_poliza.creatip := 2;
            ELSE
               det_poliza.creatip := 0;
            END IF;

            -- xpl 22-07-2009: bug mantis 10702
            BEGIN
               SELECT s.icapmax
                 INTO det_poliza.icapmaxpol
                 FROM saldodeutorseg s
                WHERE s.sseguro = vsolicit
                  AND s.nmovimi = (SELECT MAX(m.nmovimi)
                                     FROM saldodeutorseg m
                                    WHERE m.sseguro = s.sseguro);
            -- BUG12421:DRA:28/01/2010
            EXCEPTION
               WHEN OTHERS THEN
                  det_poliza.icapmaxpol := NULL;
            END;

            det_poliza.cpromotor := pseg.cpromotor;
            -- bug 19372/91763-12/09/2011-AMC
            -- BUG20431:DRA:05/01/2011:Inici:Lo paso dentro del LOOP para que no de error si no recupera seguros
            -- bug 19276 reemplazos
            det_poliza.reemplazos := f_leedatosreemplazos(det_poliza.sseguro, vpmode, mensajes);
            -- fi bug 19276 reemplazos
            det_poliza.nmesextra := f_leermesesextra(det_poliza.sseguro, mensajes);
            det_poliza.cmodextra := f_leer_cmodextra(det_poliza.sproduc, mensajes);
            -- BUG20431:DRA:05/01/2011:Fi
            -- Bug 36596 IGIL INI
            det_poliza.citamedicas := f_leecitamedica(vsolicit, det_poliza.sseguro, 'POL',
                                                      mensajes);
         -- Bug 36596 IGIL FIN
         END LOOP;
      END IF;

      RETURN det_poliza;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leedatospoliza;

/*************************************************************************
Lee los datos generales de la poliza
param in polObj    : envia el objeto persistente para recuperar la
informacion necesaria puede ser nulo en tal caso
se recupera de la db
param out mensajes : mesajes de error
return             : objeto general poliza
*************************************************************************/
   FUNCTION f_leedatosgenpoliza(polobj IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_genpoliza IS
      vnumerr        NUMBER(8);
      vobdatgenpoliza ob_iax_genpoliza;
      vobdetpoliza   ob_iax_detpoliza;
      vobgestion     ob_iax_gestion;
      vtsituac       VARCHAR2(100);
      vtreteni       VARCHAR2(100);
      vtduraci       VARCHAR2(100);
      vtforpag       VARCHAR2(100);
      vttipcob       VARCHAR2(100);
      vtproduc       VARCHAR2(100);
      vtincide       VARCHAR2(100);
      vtforpagren    VARCHAR2(100);
      vtrotulo       VARCHAR2(15);   --10032008 nou camp trotulo
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeDatosGenPoliza';
      v_polissa_ini  VARCHAR2(15);
      vttipban       tipos_cuentades.ttipo%TYPE;
      vtfprest       VARCHAR2(100);
      ret_csubestadoprop NUMBER;
      v_csubestadoprop VARCHAR2(200);
   -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
   --
   BEGIN
      vpasexec := 1;

      IF polobj IS NULL THEN
         --Recuperacion de los datos del detalle de la poliza
         vobdetpoliza := f_leedatospoliza(mensajes);

         IF vobdetpoliza IS NULL THEN
            vpasexec := 3;
            RAISE e_object_error;
         END IF;

         --Recuperacion de los datos de gestion de la poliza
         vobgestion := f_leedatosgestion(mensajes);

         IF vobgestion IS NULL THEN
            vpasexec := 5;
            RAISE e_object_error;
         END IF;
      ELSE
         --Recuperacion de los datos del detalle de la poliza
         vobdetpoliza := polobj;
         --Recuperacion de los datos de gestion de la poliza
         vobgestion := pac_iobj_prod.f_partpoldatosgestion(polobj, mensajes);
      END IF;

      IF vobdetpoliza.csituac = 4
         AND(pac_seguros.f_get_escertifcero(vobdetpoliza.npoliza) = 0
             OR pac_seguros.f_get_escertifcero(NULL, vobdetpoliza.sseguro) > 0) THEN
         vobdetpoliza.ncertif := 0;
      END IF;

      --Recupera la descripcion del producto
      vnumerr := f_dessproduc(vobdetpoliza.sproduc, 1, pac_md_common.f_get_cxtidioma, vtproduc);

      IF vnumerr <> 0 THEN
         vpasexec := 7;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      -- Recupera el rotulo del producto 10032008
      vnumerr := f_desproducto(vobdetpoliza.cramo, vobdetpoliza.cmodali, 2,
                               pac_md_common.f_get_cxtidioma, vtrotulo, vobdetpoliza.ctipseg,
                               vobdetpoliza.ccolect);

      IF vnumerr <> 0 THEN
         vpasexec := 9;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --Recuperacion de la descripcion de valores.
      vtsituac := pac_iax_listvalores.f_getdescripvalores(61, vobdetpoliza.csituac, mensajes);

      IF vobgestion.cduraci IS NOT NULL THEN
         vtduraci := pac_iax_listvalores.f_getdescripvalores(20, vobgestion.cduraci, mensajes);
      END IF;

      IF NVL(vobdetpoliza.creteni, 0) <> 0 THEN
         vtreteni := pac_iax_listvalores.f_getdescripvalores(66, vobdetpoliza.creteni,
                                                             mensajes);

         IF vobdetpoliza.creteni = 2 THEN   --ramiro
            ret_csubestadoprop := pac_psu.f_get_subestadoprop(vobdetpoliza.sseguro,
                                                              v_csubestadoprop);   --ramiro
            vtreteni := vtreteni || '/' || v_csubestadoprop;   --ramiro
         END IF;   --ramiro
      END IF;

      IF vobgestion.cforpag IS NOT NULL THEN
         vtforpag := pac_iax_listvalores.f_getdescripvalores(17, vobgestion.cforpag, mensajes);
      END IF;

      IF vobgestion.ctipcob IS NOT NULL THEN
         vttipcob := pac_iax_listvalores.f_getdescripvalores(552, vobgestion.ctipcob,
                                                             mensajes);
      END IF;

      -- Bug 10271 - 29/06/2009 - AMC - Se corrije el parametro de la llamada y se pone el correcto.
      IF vobgestion.cforpagren IS NOT NULL THEN
         vtforpagren := pac_iax_listvalores.f_getdescripvalores(17, vobgestion.cforpagren,
                                                                mensajes);
      END IF;

      -- Fi 10271 - 29/06/2009 - AMC
      -- Bug 10499 - 10/07/2009 - AMC
      IF vobgestion.ctipban IS NOT NULL THEN
         vnumerr := pac_descvalores.f_desctipocuenta(vobgestion.ctipban,
                                                     pac_md_common.f_get_cxtidioma, vttipban);
      END IF;

      -- Fi Bug 10499 - 10/07/2009 - AMC
      vpasexec := 11;

      -- 10831.NMM.01/2010.i.
      -- BUG13352:DRA:16/04/2010:Inici:Se analiza el origen de la poliza
      IF vpmode = 'EST' THEN
         vtincide := pac_seguros.ff_incidencias_poliza(vobdetpoliza.ssegpol,
                                                       pac_md_common.f_get_cxtidioma, NULL, 1);
      ELSE
         vtincide := pac_seguros.ff_incidencias_poliza(vobdetpoliza.sseguro,
                                                       pac_md_common.f_get_cxtidioma, NULL, 1);
      END IF;

      -- BUG13352:DRA:16/04/2010:Fi
      -- 10831.NMM.01/2010.f.
      vpasexec := 13;
      vobdatgenpoliza := ob_iax_genpoliza();
      vobdatgenpoliza.sseguro := vobdetpoliza.sseguro;
      vobdatgenpoliza.npoliza := vobdetpoliza.npoliza;
      vobdatgenpoliza.ncertif := vobdetpoliza.ncertif;
      vobdatgenpoliza.csituac := vobdetpoliza.csituac;
      vobdatgenpoliza.trotulo := vtrotulo;
      vobdatgenpoliza.tsituac := vtsituac;
      vobdatgenpoliza.creteni := vobdetpoliza.creteni;
      vobdatgenpoliza.treteni := vtreteni;
      vobdatgenpoliza.tincide := vtincide;
      vobdatgenpoliza.cmodali := vobdetpoliza.cmodali;
      vobdatgenpoliza.ccolect := vobdetpoliza.ccolect;
      vobdatgenpoliza.cramo := vobdetpoliza.cramo;
      vobdatgenpoliza.ctipseg := vobdetpoliza.ctipseg;
      vobdatgenpoliza.cactivi := vobgestion.cactivi;   --BUG 9916
      vobdatgenpoliza.sproduc := vobdetpoliza.sproduc;
      vobdatgenpoliza.tproduc := vtproduc;
      vobdatgenpoliza.csubpro := vobdetpoliza.csubpro;
      vobdatgenpoliza.sfbureau := vobdetpoliza.sfbureau;
      vobdatgenpoliza.cidioma := vobgestion.cidioma;
      vobdatgenpoliza.cforpag := vobgestion.cforpag;
      vobdatgenpoliza.tforpag := vtforpag;
      vobdatgenpoliza.ctipban := vobgestion.ctipban;
      vobdatgenpoliza.cbancar := vobgestion.cbancar;
      -- mandatos
      vobdatgenpoliza.cmandato := vobgestion.cmandato;
      vobdatgenpoliza.numfolio := vobgestion.numfolio;
      vobdatgenpoliza.fmandato := vobgestion.fmandato;
      vobdatgenpoliza.sucursal := vobgestion.sucursal;
      vobdatgenpoliza.haymandatprev := vobgestion.haymandatprev;
      vobdatgenpoliza.ffinvig := vobgestion.ffinvig;
      -- ini BUG 0020761 - 03/01/2012 - JMF
      vobdatgenpoliza.ncuotar := vobgestion.ncuotar;
      vobdatgenpoliza.tarjeta := pac_ccc.f_estarjeta(NULL, vobgestion.ctipban);
      -- fin BUG 0020761 - 03/01/2012 - JMF
      vobdatgenpoliza.fefecto := vobgestion.fefecto;
        
      IF vobdatgenpoliza.sproduc IN (80007,80008) THEN
        
        vobdatgenpoliza.fvencim := to_date(to_char(sysdate,'dd/mm')||'/'||(to_char(sysdate,'yyyy')+NVL (f_parproductos_v (80007, 'VIG_JUDIC'), 0)),'dd/mm/yyyy');
     
      ELSE   
        vobdatgenpoliza.fvencim := vobgestion.fvencim;
      
      END IF;
      
      vobdatgenpoliza.femisio := vobgestion.femisio;
      vobdatgenpoliza.fanulac := vobgestion.fanulac;
      vobdatgenpoliza.fcarant := vobgestion.fcarant;
      -- BUG 27076_0147930 - JLTS - 19/07/2013 - Se adiciona el NVL para que tome vobgestion.frenova
      vobdatgenpoliza.fcaranu := NVL(vobgestion.fcaranu, vobgestion.frenova);
      vobdatgenpoliza.fcarpro := vobgestion.fcarpro;
      vobdatgenpoliza.cduraci := vobgestion.cduraci;
      vobdatgenpoliza.cpolcia := vobdetpoliza.cpolcia;
      -- BUG 14585 - PFA - Anadir campo poliza compania
      -- BUG 21924 - 16/04/2012 - ETM--aqui
      vobdatgenpoliza.ctipretr := vobgestion.ctipretr;
      vobdatgenpoliza.cindrevfran := vobgestion.cindrevfran;
      vobdatgenpoliza.precarg := vobgestion.precarg;
      vobdatgenpoliza.pdtotec := vobgestion.pdtotec;
      vobdatgenpoliza.preccom := vobgestion.preccom;
      vobdatgenpoliza.cdomper := vobgestion.cdomper;

      -- BUG 21924 - MDS - 18/06/2012
      -- FIN BUG 21924 - 16/04/2012 - ETM
      -- BUG9314:DRA:15/04/2009: Inici
      IF vobgestion.cduraci IN(1, 2) THEN
         vtduraci := vobgestion.duracion || ' ' || vtduraci;
      END IF;

      -- BUG9314:DRA:15/04/2009: Fi
      vobdatgenpoliza.tduraci := vtduraci;
      vobdatgenpoliza.ctipcom := vobgestion.ctipcom;
      --Bug.: 19682
      vobdatgenpoliza.ttipcom := ff_desvalorfijo(55, pac_md_common.f_get_cxtidioma(),
                                                 vobdatgenpoliza.ctipcom);
      vobdatgenpoliza.ctipcob := vobgestion.ctipcob;
      vobdatgenpoliza.ttipcob := vttipcob;
      vobdatgenpoliza.cagente := vobdetpoliza.cagente;
      vobdatgenpoliza.csubage := vobgestion.csubage;
      -- BUG11618:DRA:02/11/2009: Ya estaba puesto, pero lo indico
      vobdatgenpoliza.cobjase := vobdetpoliza.cobjase;
      vobdatgenpoliza.dtocom := vobgestion.dtocom;
      vobdatgenpoliza.ndurper := vobgestion.ndurper;
      vobdatgenpoliza.pcapfall := vobgestion.pcapfall;
      vobdatgenpoliza.pdoscab := vobgestion.pdoscab;
      -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratacion
      vobdatgenpoliza.fppren := vobgestion.fppren;
      vobdatgenpoliza.inttec := vobgestion.inttec;
      -- Fi Bug 14285 - 26/04/2010 - JRH
      -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
      vobdatgenpoliza.cfprest := vobgestion.cfprest;

      --JRH Forma prestacion de la poliza
      IF vobgestion.cfprest IS NOT NULL THEN
         vtfprest := pac_iax_listvalores.f_getdescripvalores(205, vobgestion.cfprest,

                                                             --JRH IMP Es este detvalor?
                                                             mensajes);
      ELSE
         vtfprest := NULL;
      END IF;

      vobdatgenpoliza.tfprest := vtfprest;
      --JRH Forma prestacion de la poliza
      -- Fi Bug 16106 - 01/10/2010 - JRH
      vobdatgenpoliza.cforpagren := vobgestion.cforpagren;
      vobdatgenpoliza.tforpagren := vtforpagren;
      vobdatgenpoliza.frevisio := vobgestion.frevisio;
      vobdatgenpoliza.polissa_ini := vobgestion.polissa_ini;
      --JMR 06/2008
      vobdatgenpoliza.cempres := vobdetpoliza.cempres;
      vobdatgenpoliza.spertom := ff_sperson_tomador(vobdetpoliza.sseguro);
      vobdatgenpoliza.tnomtom := f_nombre(vobdatgenpoliza.spertom, 1, vobdetpoliza.cagente);
      -- dra 23-12-2008: bug mantis 8121
      vobdatgenpoliza.crevali := vobdetpoliza.crevali;
      vobdatgenpoliza.prevali := vobdetpoliza.prevali;
      -- Bug 20595 - RSC - 19/12/2011 - LCOL - UAT - TEC - Errors tarificant i aportacions
      --vobdatgenpoliza.trevali := vobdetpoliza.trevali;
      vobdatgenpoliza.trevali := ff_desvalorfijo(62, pac_md_common.f_get_cxtidioma(),
                                                 vobdetpoliza.crevali);
      -- Fin Bug 20595
      vobdatgenpoliza.irevali := vobdetpoliza.irevali;
      vnumerr := f_desempresa(vobdetpoliza.cempres, NULL, vobdatgenpoliza.tempres);
      -- Mantis 7919.#6.
      vobdatgenpoliza.ndurcob := vobgestion.ndurcob;
      vobdatgenpoliza.crecfra := vobgestion.crecfra;
      vobdatgenpoliza.nmesextra := vobdetpoliza.nmesextra;
      -- Bug 10499 - 10/07/2009 - AMC
      vobdatgenpoliza.ttipban := vttipban;
      -- Fi Bug 10499 - 10/07/2009 - AMC
      vobdatgenpoliza.icapmaxpol := vobdetpoliza.icapmaxpol;
      -- BUG12421:DRA:28/01/2010
      -- Bug 13483 - 04-03-2010 FAL
      vobdatgenpoliza.ncontrato := vobdetpoliza.ncontrato;
      -- Fi Bug 13483 - 04-03-2010 FAL
      -- Bug 19393 - JBN
      vobdatgenpoliza.tactivi := vobgestion.tactivi;
      vobdatgenpoliza.tramo := ff_desramo(vobdetpoliza.cramo, pac_iax_common.f_get_cxtidioma());
      vobdatgenpoliza.tcompani := ff_descompania(vobdetpoliza.ccompani);
      /*   SELECT nnumide
      INTO vobdatgenpoliza.nnumidetom
      FROM per_personas
      WHERE sperson = vobdatgenpoliza.spertom;*/
      -- Fi Bug 19393 - JBN
      -- Bug 19372/91763 - 07/09/2011 - AMC
      vobdatgenpoliza.cpromotor := vobdetpoliza.cpromotor;
      -- Fi Bug 19372/91763 - 07/09/2011 - AMC
      -- ini bug 19276 reemplazos
      vobdatgenpoliza.reemplazos := vobdetpoliza.reemplazos;
      -- fi bug 19276 reemplazos
      vobdatgenpoliza.cmonpol := vobgestion.cmonpol;
      vobdatgenpoliza.cmonpolint := vobgestion.cmonpolint;
      vobdatgenpoliza.tmonpol := vobgestion.tmonpol;
      -- Bug 0023183 - DCG - 14/08/2012
      vobdatgenpoliza.ctipcoa := vobdetpoliza.ctipcoa;
      vobdatgenpoliza.ttipcoa := vobdetpoliza.ttipcoa;
      vobdatgenpoliza.ncuacoa := vobdetpoliza.ncuacoa;
      -- Fi Bug 0023183 - DCG - 14/08/2012
      -- Bug 23940 - APD - 17/12/2012 - se a?ade el campo cbloqueocol
      vobdatgenpoliza.cbloqueocol := vobgestion.cbloqueocol;
      vobdatgenpoliza.tbloqueocol := vobgestion.tbloqueocol;
      -- fin Bug 23940 - APD - 17/12/2012 - se a?ade el campo cbloqueocol
      vobdatgenpoliza.nedamar := vobgestion.nedamar;
      -- BUG 25584/135342 - MMS - 19/02/2013
      vobdatgenpoliza.nanuali := vobdetpoliza.nanuali;   --Bug 39659 - 20160128 -AAC
      vobdatgenpoliza.fefeplazo := vobgestion.fefeplazo;   -- BUG 41143/229973 - 17/03/2016 - JAEG
      vobdatgenpoliza.fvencplazo := vobgestion.fvencplazo;   -- BUG 41143/229973 - 17/03/2016 - JAEG
      
      -- INI  IAXIS-4205  CJMR   15/08/2019
	  BEGIN
         SELECT cactivi
         INTO vobdatgenpoliza.cactivi
         FROM seguros
         WHERE npoliza = vobdetpoliza.npoliza;
	  EXCEPTION
         WHEN OTHERS THEN
		  BEGIN
			 SELECT cactivi
			 INTO vobdatgenpoliza.cactivi
			 FROM estseguros
			 WHERE npoliza = vobdetpoliza.npoliza;
		  EXCEPTION
			 WHEN OTHERS THEN
				NULL;
		  END;
	  END;
      -- FIN  IAXIS-4205  CJMR   15/08/2019
      
      RETURN(vobdatgenpoliza);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leedatosgenpoliza;

/*************************************************************************
Lee tomadores
param out mensajes : mesajes de error
return             : objeto tomadores
*************************************************************************/
   FUNCTION f_leetomadores(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tomadores IS
      CURSOR soltom IS
         SELECT s.*
           FROM soltomadores s
          WHERE s.ssolicit = vsolicit;

      CURSOR esttom IS
         SELECT   s.*
             FROM esttomadores s
            WHERE s.sseguro = vsolicit
         ORDER BY nordtom;

      CURSOR poltom IS
         SELECT   s.*
             FROM tomadores s
            WHERE s.sseguro = vsolicit
         ORDER BY nordtom;

      toma           t_iax_tomadores := t_iax_tomadores();
      ndirec         NUMBER;
      vcagente       NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeTomadores';
   BEGIN
      IF vpmode = 'SOL' THEN
         FOR stom IN soltom LOOP
            toma.EXTEND;
            toma(toma.LAST) := ob_iax_tomadores();
            toma(toma.LAST).sperson := 0;
            toma(toma.LAST).tapelli1 := stom.tapelli;
            toma(toma.LAST).tnombre := stom.tnombre;

            IF toma(toma.LAST).direcciones IS NULL THEN
               toma(toma.LAST).direcciones := t_iax_direcciones();
            END IF;

            toma(toma.LAST).direcciones.EXTEND;
            ndirec := toma(toma.LAST).direcciones.LAST;
            toma(toma.LAST).direcciones(ndirec) := ob_iax_direcciones();
            toma(toma.LAST).direcciones(ndirec).tdomici := stom.tdomici;
            toma(toma.LAST).direcciones(ndirec).cpoblac := stom.cpoblac;
            toma(toma.LAST).direcciones(ndirec).cpostal := stom.cpostal;
            toma(toma.LAST).direcciones(ndirec).cprovin := stom.cprovin;
            vpasexec := 3;

            BEGIN
               SELECT tpoblac
                 INTO toma(toma.LAST).direcciones(ndirec).tpoblac
                 FROM poblaciones
                WHERE cprovin = stom.cprovin
                  AND cpoblac = stom.cpoblac;
            EXCEPTION
               WHEN OTHERS THEN
                  toma(toma.LAST).direcciones(ndirec).tpoblac := '';
            END;

            vpasexec := 4;

            BEGIN
               SELECT tprovin
                 INTO toma(toma.LAST).direcciones(ndirec).tprovin
                 FROM provincias
                WHERE cprovin = stom.cprovin;
            EXCEPTION
               WHEN OTHERS THEN
                  toma(toma.LAST).direcciones(ndirec).tprovin := '';
            END;
         END LOOP;
      ELSIF vpmode = 'EST' THEN
         FOR etom IN esttom LOOP
            num_err := pac_seguros.f_get_cagente(etom.sseguro, 'EST', vcagente);
            toma.EXTEND;
            toma(toma.LAST) := ob_iax_tomadores();
            toma(toma.LAST).sperson := etom.sperson;
            toma(toma.LAST).nordtom := etom.nordtom;
            -- FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador
            toma(toma.LAST).cexistepagador := NVL(etom.cexistepagador, 0);
            toma(toma.LAST).cagrupa := etom.cagrupa; --IAXIS-2085 03/04/2019 AP
            vpasexec := 5;
            num_err := pac_md_persona.f_get_persona_agente(etom.sperson, vcagente, vpmode,
                                                           toma(toma.LAST), mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 6;
            p_findistomador(toma(toma.LAST));

            -- Bug 10101 - RSC - 28/07/2009 - Detalle de garantias (Consulta de poliza)
            -- Error detactado: no se hacia este IF y esto causaba errores al no estar inicializada
            IF toma(toma.LAST).direcciones IS NULL THEN
               toma(toma.LAST).direcciones := t_iax_direcciones();
            END IF;

            -- Fin Bug 10101
            toma(toma.LAST).direcciones.EXTEND;
            ndirec := toma(toma.LAST).direcciones.LAST;
            toma(toma.LAST).direcciones(ndirec) := ob_iax_direcciones();
            toma(toma.LAST).direcciones(ndirec).cdomici := etom.cdomici;
            vpasexec := 7;

            -- BUG 7624 - 20/04/2009 - SBG - S'afegeix par¿m. p_tmode
            -- a funcio pac_md_listvalores.p_ompledadesdireccions
            -- Bug 21049/104826 - 24/01/2012 - AMC
            IF etom.cdomici IS NOT NULL THEN
               pac_md_listvalores.p_ompledadesdireccions(etom.sperson, etom.cdomici, vpmode,
                                                         toma(toma.LAST).direcciones(ndirec),
                                                         mensajes);
            END IF;
         -- Fi Bug 21049/104826 - 24/01/2012 - AMC
         -- FINAL BUG 7624 - 20/04/2009 - SBG
         END LOOP;
      ELSE
         FOR ptom IN poltom LOOP
            num_err := pac_seguros.f_get_cagente(ptom.sseguro, 'REAL', vcagente);
            toma.EXTEND;
            toma(toma.LAST) := ob_iax_tomadores();
            toma(toma.LAST).sperson := ptom.sperson;
            toma(toma.LAST).nordtom := ptom.nordtom;
            -- FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador
            toma(toma.LAST).cexistepagador := NVL(ptom.cexistepagador, 0);
            toma(toma.LAST).cagrupa := ptom.cagrupa; --IAXIS-2085 03/04/2019 AP
            vpasexec := 8;
            num_err := pac_md_persona.f_get_persona_agente(ptom.sperson, vcagente, vpmode,
                                                           toma(toma.LAST), mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 9;
            p_findistomador(toma(toma.LAST));

            -- Bug 10101 - RSC - 28/07/2009 - Detalle de garantias (Consulta de poliza)
            -- Error detactado: no se hacia este IF y esto causaba errores al no estar inicializada
            IF toma(toma.LAST).direcciones IS NULL THEN
               toma(toma.LAST).direcciones := t_iax_direcciones();
            END IF;

            -- Fin Bug 10101
            toma(toma.LAST).direcciones.EXTEND;
            ndirec := toma(toma.LAST).direcciones.LAST;
            toma(toma.LAST).direcciones(ndirec) := ob_iax_direcciones();
            toma(toma.LAST).direcciones(ndirec).cdomici := ptom.cdomici;
            vpasexec := 10;

            -- BUG 7624 - 20/04/2009 - SBG - S'afegeix par¿m. p_tmode
            -- a funcio pac_md_listvalores.p_ompledadesdireccions
            -- Bug 21049/104826 - 24/01/2012 - AMC
            IF ptom.cdomici IS NOT NULL THEN
               pac_md_listvalores.p_ompledadesdireccions(ptom.sperson, ptom.cdomici, vpmode,
                                                         toma(toma.LAST).direcciones(ndirec),
                                                         mensajes);
            END IF;
         -- Fi Bug 21049/104826 - 24/01/2012 - AMC
         -- FINAL BUG 7624 - 20/04/2009 - SBG
         END LOOP;
      END IF;

      RETURN toma;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leetomadores;

/*************************************************************************
Lee los datos de gestion
param out mensajes : mesajes de error
return             : objeto gestion
*************************************************************************/
   FUNCTION f_leedatosgestion(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_gestion IS
      CURSOR estges IS
         SELECT s.*
           FROM estseguros s
          WHERE s.sseguro = vsolicit;

      CURSOR polges IS
         SELECT s.*
           FROM seguros s
          WHERE s.sseguro = vsolicit;

      gestion        ob_iax_gestion := ob_iax_gestion();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeDatosGestion';
      vcramo         codiram.cramo%TYPE;   -- Bug 19027 - RSC - 26/07/2011
      errnum         NUMBER;
      v_ctipcom      NUMBER;
      v_count        NUMBER;
      vcbloqueocol   seguros.cbloqueocol%TYPE;
   -- Bug 23940 - APD - 02/01/2013
   BEGIN
      vpasexec := 1;

      IF vpmode = 'EST' THEN
         vpasexec := 2;

         FOR eges IN estges LOOP
            vpasexec := 3;
            vcramo := eges.cramo;
            gestion.cidioma := eges.cidioma;
            gestion.cactivi := eges.cactivi;
            gestion.cforpag := eges.cforpag;
            gestion.ctipban := eges.ctipban;
            gestion.cbancar := eges.cbancar;
            -- ini BUG 0020761 - 03/01/2012 - JMF
            gestion.ncuotar := eges.ncuotar;
            gestion.tarjeta := pac_ccc.f_estarjeta(NULL, eges.ctipban);
            -- fin BUG 0020761 - 03/01/2012 - JMF
            gestion.fefecto := eges.fefecto;
            gestion.fvencim := eges.fvencim;
            gestion.femisio := eges.femisio;
            gestion.fanulac := eges.fanulac;
            gestion.cduraci := eges.cduraci;
            gestion.duracion := eges.nduraci;
            gestion.ctipcom := eges.ctipcom;
            gestion.ctipcob := eges.ctipcob;
            gestion.csubage := eges.csubage;   -- BUG11618:DRA:02/11/2009
            gestion.fcarant := eges.fcarant;
            gestion.fcaranu := eges.fcaranu;
            gestion.fcarpro := eges.fcarpro;
            gestion.ccobban := eges.ccobban;
            --SBG 04/2008
            gestion.polissa_ini := eges.polissa_ini;
            -- Mantis 7919.#6.i. 12/2008
            gestion.ndurcob := eges.ndurcob;
            gestion.crecfra := eges.crecfra;
            -- BUG 21924 - 16/04/2012 - ETM
            gestion.ctipretr := eges.ctipretr;
            gestion.cindrevfran := eges.cindrevfran;
            gestion.precarg := eges.precarg;
            gestion.pdtotec := eges.pdtotec;
            gestion.preccom := eges.preccom;
            gestion.dtocom := eges.pdtocom;
            -- FIN BUG 21924 - 16/04/2012 - ETM
            gestion.cdomper := eges.cdomper;   -- BUG 21924 - MDS - 18/06/2012
            gestion.frenova := eges.frenova;
            vpasexec := 4;
            gestion.nedamar := eges.nedamar;
            -- BUG 25584/135342 - MMS- 19/02/2013
            -- BUG 24685 2013-02-22 AEG. Asignacion preimpresos
            gestion.ctipoasignum := eges.ctipoasignum;
            gestion.npolizamanual := eges.npolizamanual;
            gestion.npreimpreso := eges.npreimpreso;
            --fin 24685 2013-02-22 AEG. Asignacion preimpresos
            gestion.nmescob := eges.nmescob;

            -- BUG 0027735 - FAL - 25/09/2013
            -- BUG 0023117 - FAL - 26/07/2012
            IF eges.cmoneda IS NOT NULL THEN
               gestion.cmonpol := eges.cmoneda;
            END IF;

            vpasexec := 5;

            IF gestion.cmonpol IS NOT NULL THEN
               gestion.tmonpol := pac_md_listvalores.f_get_tmoneda(gestion.cmonpol,
                                                                   gestion.cmonpolint,
                                                                   mensajes);
            END IF;

            vpasexec := 6;

            -- LPS 07/2008. Si ¿s una p¿lissa de ahorro, se obtienen los siguientes valores de ESTSEGUROS_AHO;
            IF NVL(f_parproductos_v(eges.sproduc, 'ES_PRODUCTO_AHO'), 0) = 1 THEN
               BEGIN
                  SELECT ndurper, frevisio, cfprest
                    INTO gestion.ndurper, gestion.frevisio, gestion.cfprest
                    -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                  FROM   estseguros_aho
                   WHERE sseguro = vsolicit;
               EXCEPTION
                  WHEN OTHERS THEN
                     gestion.ndurper := NULL;
                     gestion.frevisio := NULL;
                     gestion.cfprest := NULL;
               END;
            END IF;

            vpasexec := 7;

            -- LPS 07/2008. Si ¿s una p¿lissa de rendes, se obtienen los siguientes valores de ESTSEGUROSREN i ESTSEGUROS_AHO;
            IF NVL(f_parproductos_v(eges.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
               BEGIN
                  SELECT ndurper, frevisio, cfprest
                    INTO gestion.ndurper, gestion.frevisio, gestion.cfprest
                    -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                  FROM   estseguros_aho
                   WHERE sseguro = vsolicit;
               EXCEPTION
                  WHEN OTHERS THEN
                     gestion.ndurper := NULL;
                     gestion.frevisio := NULL;
                     gestion.cfprest := NULL;
               END;

               BEGIN
                  SELECT cforpag, pcapfall, pdoscab, fppren
                    -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratacion e inter¿s
                  INTO   gestion.cforpagren, gestion.pcapfall, gestion.pdoscab, gestion.fppren
                    --Fi  Bug 14285 - 26/04/2010 - JRH
                  FROM   estseguros_ren
                   WHERE sseguro = vsolicit;
               EXCEPTION
                  WHEN OTHERS THEN
                     gestion.cforpagren := NULL;
                     gestion.pcapfall := NULL;
                     gestion.pdoscab := NULL;
                     gestion.fppren := NULL;
               END;
            END IF;

            vpasexec := 8;

            IF pac_mdpar_productos.f_get_parproducto
                                                  ('ADMITE_CERTIFICADOS',
                                                   pac_iax_produccion.poliza.det_poliza.sproduc) =
                                                                                              1
               AND NOT pac_iax_produccion.isaltacol
               AND NOT pac_iax_produccion.issuplem THEN
               errnum :=
                  pac_productos.f_get_herencia_col
                                                (pac_iax_produccion.poliza.det_poliza.sproduc,
                                                 13, v_ctipcom);

               SELECT COUNT(1)
                 INTO v_count
                 FROM seguros
                WHERE ncertif = 0
                  AND npoliza = pac_iax_produccion.poliza.det_poliza.npoliza;

               IF NVL(v_ctipcom, 0) = 1
                  AND errnum = 0
                  AND v_count > 0 THEN
                  SELECT ctipcom
                    INTO v_ctipcom
                    FROM seguros
                   WHERE ncertif = 0
                     AND npoliza = pac_iax_produccion.poliza.det_poliza.npoliza;

                  gestion.ctipcom := v_ctipcom;
               END IF;
            END IF;

            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'INS_MANDATO'),
                   0) = 1 THEN
               BEGIN
                  --DC01-->
                  SELECT ms.numfolio, ms.fechamandato, ms.sucursal,
                         ms.haymandatprev, ms.ffinvig
                    INTO gestion.numfolio, gestion.fmandato, gestion.sucursal,
                         gestion.haymandatprev, gestion.ffinvig
                    FROM estmandatos_seguros ms, estmandatos em
                   WHERE ms.sseguro = vsolicit
                     AND ms.cmandato = em.cmandato
                     AND em.cestado <> 2;
               EXCEPTION
                  WHEN OTHERS THEN
                     BEGIN
                        SELECT ms.numfolio, ms.fechamandato, ms.sucursal,
                               ms.ffinvig
                          INTO gestion.numfolio, gestion.fmandato, gestion.sucursal,
                               gestion.ffinvig
                          FROM mandatos_seguros ms, mandatos em
                         WHERE ms.fbajarel IS NULL
                           AND ms.cusubajarel IS NULL
                           AND ms.sseguro = (SELECT ssegpol
                                               FROM estseguros
                                              WHERE sseguro = vsolicit)
                           AND ms.cmandato = em.cmandato
                           AND em.cestado <> 2;
                     --DC01<--
                     EXCEPTION
                        WHEN OTHERS THEN
                           gestion.numfolio := NULL;
                           gestion.fmandato := NULL;
                           gestion.sucursal := NULL;
                           gestion.haymandatprev := NULL;
                           gestion.ffinvig := NULL;
                     END;
               END;
            END IF;

            --
            gestion.fefeplazo := eges.fefeplazo;   -- BUG 41143/229973 - 17/03/2016 - JAEG
            gestion.fvencplazo := eges.fvencplazo;   -- BUG 41143/229973 - 17/03/2016 - JAEG
         --
         END LOOP;
      ELSE
         vpasexec := 9;

         FOR pges IN polges LOOP
            vpasexec := 10;
            vcramo := pges.cramo;
            gestion.cidioma := pges.cidioma;
            gestion.cactivi := pges.cactivi;
            gestion.cforpag := pges.cforpag;
            gestion.ctipban := pges.ctipban;
            gestion.cbancar := pges.cbancar;
            -- ini BUG 0020761 - 03/01/2012 - JMF
            gestion.ncuotar := pges.ncuotar;
            gestion.tarjeta := pac_ccc.f_estarjeta(NULL, pges.ctipban);
            -- fin BUG 0020761 - 03/01/2012 - JMF
            gestion.fefecto := pges.fefecto;
            gestion.fvencim := pges.fvencim;
            gestion.femisio := pges.femisio;
            gestion.fanulac := pges.fanulac;
            gestion.cduraci := pges.cduraci;
            gestion.duracion := pges.nduraci;
            gestion.ctipcom := pges.ctipcom;
            gestion.ctipcob := pges.ctipcob;
            gestion.csubage := pges.csubage;   -- BUG11618:DRA:02/11/2009
            gestion.fcarant := pges.fcarant;
            gestion.fcaranu := pges.fcaranu;
            gestion.fcarpro := pges.fcarpro;
            gestion.ccobban := pges.ccobban;
            -- BUG 21924 - 16/04/2012 - ETM
            gestion.ctipretr := pges.ctipretr;
            gestion.cindrevfran := pges.cindrevfran;
            gestion.precarg := pges.precarg;
            gestion.pdtotec := pges.pdtotec;
            gestion.preccom := pges.preccom;
            gestion.dtocom := pges.pdtocom;
            -- FIN BUG 21924 - 16/04/2012 - ETM
            gestion.frenova := pges.frenova;
            -- BUG 0023117 - FAL - 26/07/2012
            vpasexec := 11;
            gestion.nedamar := pges.nedamar;
            -- BUG 25584/135342 - MMS- 19/02/2013
            -- Ini BUG 21924 - MDS - 18/06/2012
            -- BUG 24685 2013-02-22 AEG. Asignacion preimpresos
            gestion.ctipoasignum := pges.ctipoasignum;
            gestion.npolizamanual := pges.npolizamanual;
            gestion.npreimpreso := pges.npreimpreso;
            --fin 24685 2013-02-22 AEG. Asignacion preimpresos
            gestion.nmescob := pges.nmescob;

            -- BUG 0027735 - FAL - 25/09/2013
            BEGIN
               SELECT m.cdomper
                 INTO gestion.cdomper
                 FROM movseguro m
                WHERE m.sseguro = vsolicit
                  AND m.nmovimi = (SELECT MAX(nmovimi)
                                     FROM movseguro
                                    WHERE sseguro = m.sseguro);
            EXCEPTION
               WHEN OTHERS THEN
                  gestion.cdomper := NULL;
            END;

            vpasexec := 12;

            -- Fin BUG 21924 - MDS - 18/06/2012
            IF pges.cmoneda IS NOT NULL THEN
               gestion.cmonpol := pges.cmoneda;
            END IF;

            vpasexec := 13;

            IF gestion.cmonpol IS NOT NULL THEN
               gestion.tmonpol := pac_md_listvalores.f_get_tmoneda(gestion.cmonpol,
                                                                   gestion.cmonpolint,
                                                                   mensajes);
            END IF;

            vpasexec := 14;

            --SBG 04/2008
            BEGIN
               SELECT s.polissa_ini
                 INTO gestion.polissa_ini
                 FROM cnvpolizas s
                WHERE s.sseguro = vsolicit;
            EXCEPTION
               WHEN OTHERS THEN
                  gestion.polissa_ini := NULL;
            END;

            vpasexec := 15;
            -- Mantis 7919.#6.i. 12/2008
            gestion.ndurcob := pges.ndurcob;
            -- Mantis 7920.#6.i. 12/2008
            gestion.crecfra := pges.crecfra;

            -- LPS 07/2008. Si ¿s una p¿lissa de ahorro, se obtienen los siguientes valores de ESTSEGUROS_AHO;
            IF NVL(f_parproductos_v(pges.sproduc, 'ES_PRODUCTO_AHO'), 0) = 1 THEN
               BEGIN
                  SELECT ndurper, frevisio, cfprest
                    -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                  INTO   gestion.ndurper, gestion.frevisio, gestion.cfprest
                    FROM seguros_aho
                   WHERE sseguro = vsolicit;
               EXCEPTION
                  WHEN OTHERS THEN
                     gestion.ndurper := NULL;
                     gestion.frevisio := NULL;
                     gestion.cfprest := NULL;
               END;
            END IF;

            vpasexec := 16;

            -- LPS 07/2008. Si ¿s una p¿lissa de rendes, se obtienen los siguientes valores de ESTSEGUROSREN i ESTSEGUROS_AHO;
            IF NVL(f_parproductos_v(pges.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
               BEGIN
                  SELECT ndurper, frevisio, cfprest
                    -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                  INTO   gestion.ndurper, gestion.frevisio, gestion.cfprest
                    FROM seguros_aho
                   WHERE sseguro = vsolicit;
               EXCEPTION
                  WHEN OTHERS THEN
                     gestion.ndurper := NULL;
                     gestion.frevisio := NULL;
                     gestion.cfprest := NULL;
               END;

               BEGIN
                  SELECT cforpag, pcapfall, pdoscab, fppren
                    -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratacion e inter¿s
                  INTO   gestion.cforpagren, gestion.pcapfall, gestion.pdoscab, gestion.fppren
                    FROM seguros_ren
                   -- Fi Bug 14285 - 26/04/2010 - JRH
                  WHERE  sseguro = vsolicit;
               EXCEPTION
                  WHEN OTHERS THEN
                     gestion.cforpagren := NULL;
                     gestion.pcapfall := NULL;
                     gestion.pdoscab := NULL;
                     gestion.fppren := NULL;
               END;
            END IF;

            vpasexec := 17;
            -- Bug 23940 - APD - 17/12/2012 - se a?ade el campo cbloqueocol
            gestion.cbloqueocol := pges.cbloqueocol;

            -- Si el campo cbloqueocol es nulo o 0.-No Bloqueo, el producto es 'ADMITE_CERTIFICADOS' = 1
            -- y no es el certificado 0, entonces buscar el valor del cbloqueocol del
            -- ncertif = 0
            IF NVL(gestion.cbloqueocol, 0) = 0
               AND NVL(f_parproductos_v(pges.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
               AND pac_seguros.f_get_escertifcero(NULL, vsolicit) = 0 THEN
               BEGIN
                  SELECT cbloqueocol
                    INTO vcbloqueocol
                    FROM seguros
                   WHERE npoliza = pges.npoliza
                     AND ncertif = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vcbloqueocol := 0;
                  WHEN OTHERS THEN
                     vcbloqueocol := 0;
               END;

               gestion.cbloqueocol := vcbloqueocol;
            END IF;

            vpasexec := 18;
            gestion.tbloqueocol := pac_md_listvalores.f_getdescripvalores(1111,
                                                                          gestion.cbloqueocol,
                                                                          mensajes);

            -- fin Bug 23940 - APD - 17/12/2012 - se a?ade el campo cbloqueocol
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'INS_MANDATO'),
                   0) = 1 THEN
               BEGIN
                  SELECT numfolio, fechamandato, sucursal, ffinvig
                    INTO gestion.numfolio, gestion.fmandato, gestion.sucursal, gestion.ffinvig
                    FROM mandatos_seguros
                   WHERE sseguro = vsolicit
                     AND fbajarel IS NULL
                     AND cusubajarel IS NULL;
               EXCEPTION
                  WHEN OTHERS THEN
                     gestion.numfolio := NULL;
                     gestion.fmandato := NULL;
                     gestion.sucursal := NULL;
                     gestion.ffinvig := NULL;
               END;
            END IF;
			
			 --BUG7413 AB SUCURSAL
            BEGIN
                 
					 SELECT PAC_REDCOMERCIAL.ff_desagente
					((SELECT DISTINCT(cpadre) FROM redcomercial WHERE CAGENTE=
					(SELECT CAGENTE from seguros WHERE SSEGURO=vsolicit)),pac_md_common.f_get_cxtidioma, null) INTO gestion.sucursal FROM dual;


               EXCEPTION
                  WHEN OTHERS THEN
                     gestion.sucursal := NULL; 
               END;

            --
            gestion.fefeplazo := pges.fefeplazo;   -- BUG 41143/229973 - 17/03/2016 - JAEG
            gestion.fvencplazo := pges.fvencplazo;   -- BUG 41143/229973 - 17/03/2016 - JAEG
         --
         END LOOP;
      END IF;

      vpasexec := 19;

      -- INI BUG: 18024 JBN
      IF gestion.cactivi IS NOT NULL THEN
         errnum := f_desactivi(gestion.cactivi, vcramo, pac_md_common.f_get_cxtidioma,
                               gestion.tactivi);
      END IF;

      -- FI BUG: 18024 JBN
      RETURN gestion;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leedatosgestion;

/*************************************************************************
Lee riesgos
param out mensajes             : mesajes de error
param in pnriesgo default null : n¿mero de riesgo
return                         : objeto riesgos
*************************************************************************/
   FUNCTION f_leeriesgos(mensajes IN OUT t_iax_mensajes, pnriesgo IN NUMBER DEFAULT NULL)
      RETURN t_iax_riesgos IS
      CURSOR estrie IS
         SELECT   s.cactivi cactivi_seg, s.cramo cramo_seg, r.*
             FROM estriesgos r, estseguros s
            WHERE s.sseguro = vsolicit
              AND r.sseguro = vsolicit
              AND(r.nriesgo = pnriesgo
                  OR pnriesgo IS NULL)
         ORDER BY nriesgo;

      CURSOR polrie IS
         SELECT   s.cactivi cactivi_seg, s.cramo cramo_seg, r.*
             FROM riesgos r, seguros s
            WHERE s.sseguro = vsolicit
              AND r.sseguro = vsolicit
              AND(r.nriesgo = pnriesgo
                  OR pnriesgo IS NULL)
         ORDER BY nriesgo;

      riesgos        t_iax_riesgos := t_iax_riesgos();
      cobjase        NUMBER;
      nnum           NUMBER;
      pri            ob_iax_primas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRiesgos';
      v_cactivi      seguros.cactivi%TYPE;
      --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
      v_ttexto       activisegu.tactivi%TYPE;
      --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
      errnum         NUMBER;
   --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
   BEGIN
      IF vpmode = 'EST' THEN
         FOR erie IN estrie LOOP
            riesgos.EXTEND;
            riesgos(riesgos.LAST) := ob_iax_riesgos();
            riesgos(riesgos.LAST).nriesgo := erie.nriesgo;
            riesgos(riesgos.LAST).triesgo := f_desriesgos(vpmode, vsolicit, erie.nriesgo,
                                                          mensajes);
            riesgos(riesgos.LAST).fefecto := erie.fefecto;
            riesgos(riesgos.LAST).nmovima := erie.nmovima;
            riesgos(riesgos.LAST).nmovimb := erie.nmovimb;
            riesgos(riesgos.LAST).fanulac := erie.fanulac;
            -- BUG10519:DRA:29/07/2009
            --// Recupera la descripcio del risc
            --riesgos(riesgos.last).P_DescRiesgo(cobjase,vsolicit);
            vpasexec := 2;
            riesgos(riesgos.LAST).primas := f_leeriesgoprimas(riesgos(riesgos.LAST), mensajes);
            vpasexec := 3;
            cobjase := f_getobjase(vsolicit, vpmode, mensajes);

            IF cobjase = 1 THEN   --PERSONAL
               vpasexec := 4;
               riesgos(riesgos.LAST).riespersonal :=
                                                   f_leeriesgopersonal(erie.nriesgo, mensajes);
               vpasexec := 5;
               riesgos(riesgos.LAST).riesgoase := f_leeasegurados(erie.nriesgo, mensajes);
            ELSIF cobjase = 2 THEN   --DIRECCION
               vpasexec := 6;
               riesgos(riesgos.LAST).riesdireccion :=
                                                f_leeriesgodirecciones(erie.nriesgo, mensajes);
               riesgos(riesgos.LAST).tnatrie := erie.tnatrie;
               vpasexec := 7;
               riesgos(riesgos.LAST).riesgoase := f_leeasegurados(erie.nriesgo, mensajes);
            ELSIF cobjase IN(3, 4) THEN
               --riesgos(riesgos.last).triesgo:=ERIE.tnatrie;
               riesgos(riesgos.LAST).tnatrie := erie.tnatrie;
               vpasexec := 8;
               riesgos(riesgos.LAST).riesdescripcion :=
                                                f_leeriesgodescripcion(erie.nriesgo, mensajes);
               vpasexec := 9;
               riesgos(riesgos.LAST).riesgoase := f_leeasegurados(erie.nriesgo, mensajes);
            ELSIF cobjase = 5 THEN
               vpasexec := 10;
               riesgos(riesgos.LAST).riesgoase := f_leeasegurados(erie.nriesgo, mensajes);
               vpasexec := 11;
               riesgos(riesgos.LAST).riesautos := f_leeriesgoauto(erie.nriesgo, mensajes);
            END IF;

            vpasexec := 12;
            riesgos(riesgos.LAST).preguntas := f_leepreguntasriesgo(erie.nriesgo, mensajes);
            vpasexec := 13;
            riesgos(riesgos.LAST).garantias := f_leegarantias(erie.nriesgo, mensajes);
            vpasexec := 14;
            riesgos(riesgos.LAST).beneficiario := f_leebeneficiarios(erie.nriesgo, mensajes);
            --JRH 03/2008
            vpasexec := 15;
            riesgos(riesgos.LAST).rentirreg := f_leerentasirreg(erie.nriesgo, mensajes);
            --CONVENIOS
            riesgos(riesgos.LAST).aseguradosmes :=
                                              f_leeraseguradosmes(erie.nriesgo, NULL, mensajes);
            --CONVENIOS
            riesgos(riesgos.LAST).cactivi := NVL(erie.cactivi, erie.cactivi_seg);
            vpasexec := 16;
            errnum := f_desactivi(riesgos(riesgos.LAST).cactivi, erie.cramo_seg,
                                  pac_md_common.f_get_cxtidioma, v_ttexto);
            --XPL 07/2009 bug 10702
            vpasexec := 17;
            -- Bug 11165 - 16/09/2009 - AMC
            riesgos(riesgos.LAST).prestamo := f_leesaldodeutors(mensajes);
            vpasexec := 18;
            --bfp bug 21947 ini
            riesgos(riesgos.LAST).att_garansegcom :=
                                        f_leergaransegcom(erie.sseguro, erie.nriesgo, mensajes);
            --bfp bug 21947 fin
            riesgos(riesgos.LAST).bonfranseg := f_leerfranquicias(erie.sseguro, erie.nriesgo,
                                                                  mensajes);
            riesgos(riesgos.LAST).cmodalidad := erie.cmodalidad;

            IF errnum = 0 THEN
               riesgos(riesgos.LAST).tactivi := v_ttexto;
            ELSE
               riesgos(riesgos.LAST).tactivi := NULL;
            END IF;

            riesgos(riesgos.LAST).tdescrie := erie.tdescrie;   -- BUG CONF-114 - 21/09/2016 - JAEG
         END LOOP;
      ELSE
         FOR prie IN polrie LOOP
            riesgos.EXTEND;
            riesgos(riesgos.LAST) := ob_iax_riesgos();
            riesgos(riesgos.LAST).nriesgo := prie.nriesgo;
            riesgos(riesgos.LAST).triesgo := f_desriesgos(vpmode, vsolicit, prie.nriesgo,
                                                          mensajes);
            riesgos(riesgos.LAST).fefecto := prie.fefecto;
            riesgos(riesgos.LAST).nmovima := prie.nmovima;
            riesgos(riesgos.LAST).nmovimb := prie.nmovimb;
            riesgos(riesgos.LAST).fanulac := prie.fanulac;
            -- BUG10519:DRA:29/07/2009
            vpasexec := 20;
            riesgos(riesgos.LAST).primas := f_leeriesgoprimas(riesgos(riesgos.LAST), mensajes);
            vpasexec := 21;
            cobjase := f_getobjase(vsolicit, vpmode, mensajes);

            --// Recupera la descripcio del risc
            --se comenta, porque ya recupera la descripcion arriba.
            --riesgos(riesgos.last).P_DescRiesgo(cobjase,vsolicit);
            IF cobjase = 1 THEN   --PERSONAL
               vpasexec := 22;
               riesgos(riesgos.LAST).riespersonal :=
                                                   f_leeriesgopersonal(prie.nriesgo, mensajes);
               vpasexec := 23;
               riesgos(riesgos.LAST).riesgoase := f_leeasegurados(prie.nriesgo, mensajes);
            ELSIF cobjase = 2 THEN   --DIRECCION
               vpasexec := 24;
               riesgos(riesgos.LAST).riesdireccion :=
                                                f_leeriesgodirecciones(prie.nriesgo, mensajes);
               riesgos(riesgos.LAST).tnatrie := prie.tnatrie;
               vpasexec := 25;
               riesgos(riesgos.LAST).riesgoase := f_leeasegurados(prie.nriesgo, mensajes);
            ELSIF cobjase IN(3, 4) THEN
               -- riesgos(riesgos.last).triesgo:=PRIE.tnatrie;
               riesgos(riesgos.LAST).tnatrie := prie.tnatrie;
               vpasexec := 26;
               riesgos(riesgos.LAST).riesdescripcion :=
                                                f_leeriesgodescripcion(prie.nriesgo, mensajes);
               vpasexec := 27;
               riesgos(riesgos.LAST).riesgoase := f_leeasegurados(prie.nriesgo, mensajes);
            ELSIF cobjase = 5 THEN
               vpasexec := 28;
               riesgos(riesgos.LAST).riesgoase := f_leeasegurados(prie.nriesgo, mensajes);
               vpasexec := 29;
               riesgos(riesgos.LAST).riesautos := f_leeriesgoauto(prie.nriesgo, mensajes);
            END IF;

            vpasexec := 30;
            riesgos(riesgos.LAST).preguntas := f_leepreguntasriesgo(prie.nriesgo, mensajes);
            vpasexec := 31;
            riesgos(riesgos.LAST).garantias := f_leegarantias(prie.nriesgo, mensajes);
            vpasexec := 32;
            riesgos(riesgos.LAST).beneficiario := f_leebeneficiarios(prie.nriesgo, mensajes);
            --JRH 03/2008
            vpasexec := 33;
            riesgos(riesgos.LAST).rentirreg := f_leerentasirreg(prie.nriesgo, mensajes);
            --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
            --CONVENIOS
            riesgos(riesgos.LAST).aseguradosmes :=
                                              f_leeraseguradosmes(prie.nriesgo, NULL, mensajes);
            --CONVENIOS
            riesgos(riesgos.LAST).cactivi := NVL(prie.cactivi, prie.cactivi_seg);
            vpasexec := 34;
            errnum := f_desactivi(riesgos(riesgos.LAST).cactivi, prie.cramo_seg,
                                  pac_md_common.f_get_cxtidioma, v_ttexto);
            --XPL 07/2009 bug 10702
            vpasexec := 35;
            -- Bug 11165 - 16/09/2009 - AMC
            riesgos(riesgos.LAST).prestamo := f_leesaldodeutors(mensajes);
            --bfp bug 21947 ini
            riesgos(riesgos.LAST).att_garansegcom :=
                                        f_leergaransegcom(prie.sseguro, prie.nriesgo, mensajes);
            --bfp bug 21947 fin
            riesgos(riesgos.LAST).bonfranseg := f_leerfranquicias(prie.sseguro, prie.nriesgo,
                                                                  mensajes);
            riesgos(riesgos.LAST).cmodalidad := prie.cmodalidad;

            IF errnum = 0 THEN
               riesgos(riesgos.LAST).tactivi := v_ttexto;
            ELSE
               riesgos(riesgos.LAST).tactivi := NULL;
            END IF;

            --FIN MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
            riesgos(riesgos.LAST).tdescrie := prie.tdescrie;   -- BUG CONF-114 - 21/09/2016 - JAEG
         END LOOP;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN NULL;
         END IF;
      END IF;

      RETURN riesgos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeriesgos;

/*************************************************************************
Lee riesgo
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto riesgo
*************************************************************************/
   FUNCTION f_leeriesgo(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_riesgos IS
      riesgos        t_iax_riesgos := t_iax_riesgos();
      riesgo         ob_iax_riesgos := ob_iax_riesgos();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRiesgo';
   BEGIN
      riesgos := f_leeriesgos(mensajes, pnriesgo);

      IF riesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
         --'No se ha encontrado el riesgo
         RETURN riesgo;
      ELSE
         IF riesgos.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
            --'No se ha encontrado el riesgo
            RETURN riesgo;
         END IF;
      END IF;

      RETURN riesgos(riesgos.LAST);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeriesgo;

/*************************************************************************
Lee clausulas
param out mensajes : mesajes de error
return             : objeto clausulas
*************************************************************************/
   FUNCTION f_leeclausulas(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_clausulas IS
      CURSOR estclau IS
         SELECT   c.*, cp.multiple
             /*,(SELECT cg.tclatex FROM clausugen cg
             WHERE c.sclagen=cg.sclagen
             AND cg.CIDIOMA=vg_idioma) tclatex*/
         FROM     estclaususeg c, clausupro cp, estseguros s
            WHERE c.sseguro = vsolicit
              AND c.ffinclau IS NULL
              AND s.sseguro = c.sseguro
              AND s.cramo = cp.cramo
              AND s.cmodali = cp.cmodali
              AND s.ctipseg = cp.ctipseg
              AND s.ccolect = cp.ccolect
              AND c.sclagen = cp.sclagen
         ORDER BY cp.norden;

      CURSOR esteclau IS
         SELECT   c.*
             /*,(SELECT cg.tclatex FROM  clausugen cg
             WHERE c.sclagen= cg.SCLAGEN
             AND cg.CIDIOMA=vg_idioma) tclatex*/
         FROM     estclausuesp c
            WHERE c.sseguro = vsolicit
              AND c.cclaesp <> 1
              AND c.ffinclau IS NULL
         ORDER BY c.nordcla;

      CURSOR polclau IS
         SELECT   c.*, cp.multiple
             /*,(SELECT cg.tclatex FROM clausugen cg
             WHERE c.sclagen=cg.sclagen
             AND cg.CIDIOMA=vg_idioma) tclatex*/
         FROM     claususeg c, clausupro cp, seguros s
            WHERE c.sseguro = vsolicit
              AND c.ffinclau IS NULL
              AND s.sseguro = c.sseguro
              AND s.cramo = cp.cramo
              AND s.cmodali = cp.cmodali
              AND s.ctipseg = cp.ctipseg
              AND s.ccolect = cp.ccolect
              AND c.sclagen = cp.sclagen
         ORDER BY cp.norden;

      --Bug AMA-353 - 05/07/2016 - AMC
      CURSOR poleclau IS
         SELECT   c.*, cg.tclatit, cp.norden
             /*,(SELECT cg.tclatex FROM clausugen cg
             WHERE c.sclagen= cg.SCLAGEN
             AND cg.CIDIOMA=vg_idioma) tclatex*/
         FROM     clausuesp c, clausupro cp, seguros s, clausugen cg
            WHERE c.sseguro = vsolicit
              AND c.cclaesp <> 1
              AND c.ffinclau IS NULL
              AND c.sclagen = cp.sclagen
              AND s.sseguro = c.sseguro
              AND s.cramo = cp.cramo
              AND s.cmodali = cp.cmodali
              AND s.ctipseg = cp.ctipseg
              AND s.ccolect = cp.ccolect
              AND cg.sclagen = c.sclagen
              AND cg.cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY cp.norden;

      --Fi Bug AMA-353 - 05/07/2016 - AMC
      clausulas      t_iax_clausulas := t_iax_clausulas();
      n              NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vnumerr        NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeClausulas';
      v_tclatit      VARCHAR2(1000);   -- BUG9718:DRA:23/04/2009

      -- Bug 18362 - APD - 31/05/2011 - si hay valores informados en los parametros
      -- se deben insertar en el objeto
      FUNCTION inserta_params(
         psclagen IN NUMBER,
         params IN OUT t_iax_clausupara,
         psseguro IN NUMBER,
         ptclausugen OUT VARCHAR2,
         ptablas IN VARCHAR2,
         pnordcla IN NUMBER)
         RETURN NUMBER IS
      BEGIN
         FOR vclau IN params.FIRST .. params.LAST LOOP
            IF params.EXISTS(vclau) THEN
               BEGIN
                  IF vpmode = 'EST' THEN
                     SELECT tparame, nordcla
                       INTO params(vclau).ttexto, params(vclau).nordcla
                       FROM estclauparaseg
                      WHERE sseguro = psseguro
                        AND sclagen = params(vclau).sclagen
                        AND nparame = params(vclau).nparame
                        AND nordcla = pnordcla;
                  -- I - JLB - I - SI REAL traspaso los valores de las reales
                  ELSE
                     SELECT tparame, nordcla
                       INTO params(vclau).ttexto, params(vclau).nordcla
                       FROM clauparaseg
                      WHERE sseguro = psseguro
                        AND sclagen = params(vclau).sclagen
                        AND nparame = params(vclau).nparame
                        AND nordcla = pnordcla;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     --params(vclau).ttexto := NULL;--'#' || params(vclau).nparame || '#';
                     NULL;
               END;
            END IF;
         END LOOP;

         ptclausugen := pac_mdpar_productos.f_get_descclausulapar(psclagen, psseguro, mensajes,
                                                                  ptablas);
         RETURN 0;
      END inserta_params;

-- Fin Bug 18362 - APD - 31/05/2011
--Bug AMA-353 - 05/07/2016 - AMC
      FUNCTION max_nordcla
         RETURN NUMBER IS
         v_max          NUMBER := 0;
      BEGIN
         IF clausulas IS NULL THEN
            RETURN 0;
         END IF;

         IF clausulas.COUNT = 0 THEN
            RETURN 0;
         END IF;

         FOR vclau IN clausulas.FIRST .. clausulas.LAST LOOP
            IF clausulas.EXISTS(vclau) THEN
               IF clausulas(vclau).cidentity > v_max THEN
                  v_max := clausulas(vclau).cidentity;
               END IF;
            END IF;
         END LOOP;

         RETURN v_max;
      END max_nordcla;
--Fi Bug AMA-353 - 05/07/2016 - AMC
   BEGIN
      IF vpmode = 'SOL' THEN
         RETURN NULL;
      ELSIF vpmode = 'EST' THEN
         FOR eclau IN estclau LOOP
            clausulas.EXTEND;
            clausulas(clausulas.LAST) := ob_iax_clausulas();

            IF eclau.multiple = 1 THEN
               clausulas(clausulas.LAST).ctipo := 8;
            ELSE
               clausulas(clausulas.LAST).ctipo := 4;
            END IF;

            clausulas(clausulas.LAST).cidentity := eclau.nordcla;
            clausulas(clausulas.LAST).sclagen := eclau.sclagen;
            --clausulas(clausulas.last).tclagen:= eclau.tclatex;
            clausulas(clausulas.LAST).finiclau := eclau.finiclau;
            -- Bug 18362 - APD - 31/05/2011
            clausulas(clausulas.LAST).parametros :=
               pac_mdpar_productos.f_get_clausulas(eclau.sclagen,
                                                   clausulas(clausulas.LAST).cparams, mensajes);

            IF clausulas(clausulas.LAST).cparams > 0 THEN
               vnumerr := inserta_params(eclau.sclagen, clausulas(clausulas.LAST).parametros,
                                         eclau.sseguro, clausulas(clausulas.LAST).tclagen,
                                         'EST', eclau.nordcla);
            --
            END IF;
         -- Fin Bug 18362 - APD - 31/05/2011
         END LOOP;

         FOR epclau IN esteclau LOOP
            clausulas.EXTEND;
            clausulas(clausulas.LAST) := ob_iax_clausulas();

            -- segons VF 64 Tipo de clausula del seguro
            IF epclau.cclaesp = 2 THEN
               -- Cl¿usula restrictiva (ACC ??? es la especial de poliza)
               --//ACC ??? clausulas(clausulas.last).ctipo:=4; -- General com a objecte
               clausulas(clausulas.LAST).ctipo := 1;
            -- Texte especial ACC???
            ELSIF epclau.cclaesp = 4 THEN   -- Lligada a preguntes
               clausulas(clausulas.LAST).ctipo := 2;
            -- Preguntes com a objecte
            ELSE
               -- 1 Beneficiari --> Beneficiari com a objecte
               -- 3 Lligada a garanties --> Garantias com a objecte
               clausulas(clausulas.LAST).ctipo := epclau.cclaesp;
            END IF;

            clausulas(clausulas.LAST).sclagen := epclau.sclagen;
            --clausulas(clausulas.last).tclagen:= EPCLAU.tclatex;
            clausulas(clausulas.LAST).tclaesp := epclau.tclaesp;
            clausulas(clausulas.LAST).cidentity := epclau.nordcla;
            -- n; BUG20498:DRA:12/01/2012
            clausulas(clausulas.LAST).finiclau := epclau.finiclau;
            -- Bug 18362 - APD - 31/05/2011
            clausulas(clausulas.LAST).parametros :=
               pac_mdpar_productos.f_get_clausulas(epclau.sclagen,
                                                   clausulas(clausulas.LAST).cparams, mensajes);

            IF clausulas(clausulas.LAST).cparams > 0 THEN
               vnumerr := inserta_params(epclau.sclagen, clausulas(clausulas.LAST).parametros,
                                         epclau.sseguro, clausulas(clausulas.LAST).tclagen,
                                         'EST', epclau.nordcla);
            END IF;

            -- Fin Bug 18362 - APD - 31/05/2011
            -- Bug 27539/151777 - 02/09/2013 - AMC
            clausulas(clausulas.LAST).nriesgo := epclau.nriesgo;
            -- Fi Bug 27539/151777 - 02/09/2013 - AMC
            n := n + 1;
         END LOOP;
      ELSE
         FOR pclau IN polclau LOOP
            clausulas.EXTEND;
            clausulas(clausulas.LAST) := ob_iax_clausulas();

            IF pclau.multiple = 1 THEN
               clausulas(clausulas.LAST).ctipo := 8;
            ELSE
               clausulas(clausulas.LAST).ctipo := 4;
            END IF;

            clausulas(clausulas.LAST).cidentity := pclau.nordcla;
            clausulas(clausulas.LAST).sclagen := NVL(pclau.sclagen, 0);
            clausulas(clausulas.LAST).parametros :=
               pac_mdpar_productos.f_get_clausulas(pclau.sclagen,
                                                   clausulas(clausulas.LAST).cparams, mensajes);
            --clausulas(clausulas.last).tclagen:= PCLAU.tclatex;
            clausulas(clausulas.LAST).tclagen := '';
            clausulas(clausulas.LAST).tclaesp := '';
            clausulas(clausulas.LAST).finiclau := pclau.finiclau;

            -- JLB - I - No recupera las clausulas al editar
            IF clausulas(clausulas.LAST).cparams > 0 THEN
               vnumerr := inserta_params(pclau.sclagen, clausulas(clausulas.LAST).parametros,
                                         pclau.sseguro, clausulas(clausulas.LAST).tclagen,
                                         'POL', pclau.nordcla);
            --
            END IF;
         END LOOP;

         FOR poepclau IN poleclau LOOP
            clausulas.EXTEND;
            clausulas(clausulas.LAST) := ob_iax_clausulas();

            -- segons VF 64 Tipo de clausula del seguro
            IF poepclau.cclaesp = 2 THEN
               -- Cl¿usula restrictiva (ACC ??? es la especial de poliza)
               --//ACC ??? clausulas(clausulas.last).ctipo:=4; -- General com a objecte
               clausulas(clausulas.LAST).ctipo := 1;
            -- Texte especial ACC???
            ELSIF poepclau.cclaesp = 4 THEN   -- Lligada a preguntes
               clausulas(clausulas.LAST).ctipo := 2;
            -- Preguntes com a objecte
            ELSE
               -- 1 Beneficiari --> Beneficiari com a objecte
               -- 3 Lligada a garanties --> Garantias com a objecte
               clausulas(clausulas.LAST).ctipo := poepclau.cclaesp;
            END IF;

            clausulas(clausulas.LAST).sclagen := poepclau.sclagen;

            --clausulas(clausulas.last).tclagen:= POEPCLAU.tclatex;
            -- BUG9718:DRA:23/04/2009:Inici
            --Bug AMA-353 - 05/07/2016 - AMC
            IF poepclau.tclaesp IS NOT NULL THEN
               clausulas(clausulas.LAST).tclaesp := poepclau.tclaesp;
               clausulas(clausulas.LAST).tclagen := poepclau.tclatit;
            ELSE
               vnumerr := pac_productos.f_get_clausugen(poepclau.sclagen,
                                                        pac_md_common.f_get_cxtidioma,
                                                        v_tclatit,
                                                        clausulas(clausulas.LAST).tclaesp);
               clausulas(clausulas.LAST).tclagen := v_tclatit;

               IF vnumerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END IF;

            -- BUG9718:DRA:23/04/2009:Inici
            --clausulas(clausulas.LAST).cidentity := poepclau.nordcla;
            clausulas(clausulas.LAST).cidentity := max_nordcla() + 1;
            --Fin Bug AMA-353 - 05/07/2016 - AMC
            -- n; BUG9107:DRA:18-02-2009
            clausulas(clausulas.LAST).finiclau := poepclau.finiclau;
            -- Bug 18362 - APD - 31/05/2011
            clausulas(clausulas.LAST).parametros :=
               pac_mdpar_productos.f_get_clausulas(poepclau.sclagen,
                                                   clausulas(clausulas.LAST).cparams, mensajes);

            -- Fin Bug 18362 - APD - 31/05/2011
            -- JLB - I - No recupera las clausulas al editar
            --Bug AMA-353 - 05/07/2016 - AMC
            IF clausulas(clausulas.LAST).cparams > 0 THEN
               vnumerr := inserta_params(poepclau.sclagen,
                                         clausulas(clausulas.LAST).parametros,
                                         poepclau.sseguro, clausulas(clausulas.LAST).tclaesp,
                                         'POL', poepclau.nordcla);
            --
            END IF;

            --Fin Bug AMA-353 - 05/07/2016 - AMC
            -- Bug 27539/151777 - 02/09/2013 - AMC
            clausulas(clausulas.LAST).nriesgo := poepclau.nriesgo;
            -- Fi Bug 27539/151777 - 02/09/2013 - AMC
            n := n + 1;
         END LOOP;
      END IF;

      RETURN clausulas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeclausulas;

/*************************************************************************
Lee las primas de la poliza
param in out detpoliza: objeto detalle poliza
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leeprimas(detpoliza IN OUT ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_primas IS
      primas         t_iax_primas := t_iax_primas();
      rie            ob_iax_riesgos;
      ries           t_iax_riesgos;
      pri            ob_iax_primas := ob_iax_primas();
      rpri           ob_iax_primas;
      nerr           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeePrimas';
   BEGIN
      IF detpoliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000644);
         --'No se ha inicializado correctamente
         RAISE e_param_error;
      END IF;

      detpoliza.p_set_needtarificar(0);
      primas := detpoliza.f_get_primas(vsolicit, vnmovimi, vpmode);
      --        ries :=PAC_IOBJ_PROD.F_Partpolriesgos(detpoliza,mensajes);
      --        IF ries is null THEN
      --            PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,98742,'No existen riesgos en la poliza');
      --            vpasexec:=1;
      --            RAISE e_object_error;
      --        ELSE
      --            IF ries.count=0 THEN
      --                PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,98742,'No existen riesgos en la poliza');
      --                vpasexec:=3;
      --                RAISE e_object_error;
      --            END IF;
      --        END IF;
      --        IF mensajes is not null THEN
      --            IF mensajes.count > 0 THEN
      --                vpasexec := 4;
      --                RAISE e_object_error;
      --            END IF;
      --        END IF;
      --        FOR vrie IN ries.FIRST..ries.LAST LOOP
      --            IF ries.exists(vrie) THEN
      --                vpasexec := 5;
      --                ries(vrie).P_Set_NeedTarificar(0);
      --                vpasexec := 6;
      --                rpri:= ries(vrie).F_Get_Primas(vsolicit,vnmovimi,vpmode);
      --                vpasexec := 7;
      --                pri.primaseguro := nvl(pri.primaseguro,0) + nvl(rpri.primaseguro,0);
      --                pri.impuestos   := nvl(pri.impuestos,0) + nvl(rpri.impuestos,0);
      --                pri.recargos    := nvl(pri.recargos,0) + nvl(rpri.recargos,0);
      --                pri.primatotal  := nvl(pri.primatotal,0) + nvl(rpri.primatotal,0);
      --                pri.primarecibo := nvl(pri.primarecibo,0) + nvl(rpri.primarecibo,0);
      --                pri.iextrap     := nvl(pri.iextrap,0) + nvl(rpri.iextrap,0);
      --                pri.iprianu     := nvl(pri.iprianu,0) + nvl(rpri.iprianu,0);
      --                pri.ipritar     := nvl(pri.ipritar,0) + nvl(rpri.ipritar,0);
      --                pri.ipritot     := nvl(pri.ipritot,0) + nvl(rpri.ipritot,0);
      --                pri.irecarg     := nvl(pri.irecarg,0) + nvl(rpri.irecarg,0);
      --                pri.itarifa     := nvl(pri.itarifa,0) + nvl(rpri.itarifa,0);
      --                pri.ICONSOR        := nvl(pri.ICONSOR,0) + nvl(rpri.ICONSOR,0);
      --                pri.IRECCON        := nvl(pri.IRECCON,0) + nvl(rpri.IRECCON,0);
      --                pri.IIPS        := nvl(pri.IIPS,0) + nvl(rpri.IIPS,0);
      --                pri.IDGS        := nvl(pri.IDGS,0) + nvl(rpri.IDGS,0);
      --                pri.IARBITR        := nvl(pri.IARBITR,0) + nvl(rpri.IARBITR,0);
      --                pri.IFNG        := nvl(pri.IFNG,0) + nvl(rpri.IFNG,0);
      --                pri.IRECFRA        := nvl(pri.IRECFRA,0) + nvl(rpri.IRECFRA,0);
      --                pri.ITOTPRI        := nvl(pri.ITOTPRI,0) + nvl(rpri.ITOTPRI,0);
      --                pri.ITOTDTO        := nvl(pri.ITOTDTO,0) + nvl(rpri.ITOTDTO,0);
      --                pri.ITOTCON        := nvl(pri.ITOTCON,0) + nvl(rpri.ITOTCON,0);
      --                pri.ITOTIMP     := nvl(pri.ITOTIMP,0) + nvl(rpri.ITOTIMP,0);
      --                pri.ITOTALR     := nvl(pri.ITOTALR,0) + nvl(rpri.ITOTALR,0);
      --                vpasexec := 8;
      --                nerr:=PAC_IOBJ_PROD.F_SET_PARTRIESGO(detpoliza,ries(vrie).nriesgo,ries(vrie),mensajes);
      --            END IF;
      --        END LOOP;
      --        vpasexec := 9;
      --        primas.extend;
      --        primas(primas.last) := pri;
      RETURN primas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeprimas;

/*************************************************************************
Lee las preguntas de la poliza
param out mensajes : mesajes de error
return             : objeto preguntas
*************************************************************************/
   FUNCTION f_leepreguntaspoliza(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas IS
      preg           t_iax_preguntas := t_iax_preguntas();
      pregtab        t_iax_preguntastab := t_iax_preguntastab();
      pregtab_col    t_iax_preguntastab_columns := t_iax_preguntastab_columns();
      curid          INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      vtab2          VARCHAR2(50);
      squery         VARCHAR2(2000);
      cpregun        NUMBER;
      crespue        FLOAT;
      trespue        VARCHAR2(2000);
      pmovimi        NUMBER;
      vmov           VARCHAR2(500);
      vmov2          VARCHAR2(500);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeePreguntasPoliza';

      CURSOR c_lista(cprg NUMBER, colum VARCHAR2) IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      vconsulta      VARCHAR2(4000);
      cur            sys_refcursor;
      catribu        NUMBER;
      tatribu        VARCHAR2(1000);
      vsproduc       NUMBER;
      vnpoliza       NUMBER;
      curid3         INTEGER;
      vtab3          VARCHAR2(50);
      squery3        VARCHAR2(2000);
      curid2         INTEGER;
      squery2        VARCHAR2(2000);
      ccolumna       VARCHAR2(50);
      nlinea         NUMBER;
      tvalor         VARCHAR2(250);
      fvalor         DATE;
      nvalor         NUMBER;
      vcagente       NUMBER;
   BEGIN
      IF vpmode = 'EST' THEN
         vtab := 'ESTPREGUNPOLSEG P';
         vtab2 := ',PREGUNPRO PR, ESTSEGUROS S';
         vtab3 := 'ESTPREGUNPOLSEGTAB S';
      ELSE
         vtab := 'PREGUNPOLSEG P';
         vtab2 := ',PREGUNPRO PR, SEGUROS S';
         vtab3 := 'PREGUNPOLSEGTAB S';
      END IF;

      SELECT sproduc, npoliza, cagente
        INTO vsproduc, vnpoliza, vcagente
        FROM (SELECT sproduc, npoliza, cagente
                FROM estseguros
               WHERE sseguro = vsolicit
                 AND vpmode = 'EST'
              UNION ALL
              SELECT sproduc, npoliza, cagente
                FROM seguros
               WHERE sseguro = vsolicit
                 AND NVL(vpmode, 'SEG') <> 'EST');

      vmov := ' NMOVIMI=(SELECT MAX (nmovimi)' || ' FROM ' || vtab || ' WHERE  sseguro = '
              || vsolicit || ') ';
      vmov2 := ' NMOVIMI=(SELECT MAX (nmovimi)' || ' FROM ' || vtab3 || ' WHERE  sseguro = '
               || vsolicit || ')';
      curid := DBMS_SQL.open_cursor;
      squery := 'SELECT P.CPREGUN,P.CRESPUE,P.TRESPUE,P.NMOVIMI ' || ' FROM ' || vtab || vtab2
                || ' WHERE P.CPREGUN = PR.CPREGUN AND S.SSEGURO = P.SSEGURO'
                || ' AND S.SPRODUC = PR.SPRODUC AND P.SSEGURO=' || vsolicit || ' AND ' || vmov
                || ' ORDER BY PR.NPREORD,P.CPREGUN';
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);
      DBMS_SQL.define_column(curid, 2, crespue);
      DBMS_SQL.define_column(curid, 3, trespue, 2000);
      DBMS_SQL.define_column(curid, 4, pmovimi);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         DBMS_SQL.COLUMN_VALUE(curid, 2, crespue);
         DBMS_SQL.COLUMN_VALUE(curid, 3, trespue);
         DBMS_SQL.COLUMN_VALUE(curid, 4, pmovimi);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := crespue;
         preg(preg.LAST).trespue := trespue;
         preg(preg.LAST).nmovimi := pmovimi;
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      curid := DBMS_SQL.open_cursor;
      curid2 := DBMS_SQL.open_cursor;
      curid3 := DBMS_SQL.open_cursor;
      squery := 'SELECT distinct(cpregun)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                || vsolicit || ' AND ' || vmov2;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := NULL;
         preg(preg.LAST).trespue := NULL;
         squery2 := 'SELECT distinct(NLINEA)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                    || vsolicit || ' AND S.CPREGUN = ' || cpregun || ' AND ' || vmov2;
         DBMS_SQL.parse(curid2, squery2, DBMS_SQL.v7);
         dummy := DBMS_SQL.EXECUTE(curid2);
         DBMS_SQL.define_column(curid2, 1, nlinea);

         LOOP
            EXIT WHEN DBMS_SQL.fetch_rows(curid2) = 0;
            DBMS_SQL.COLUMN_VALUE(curid2, 1, nlinea);
            pregtab.EXTEND;
            pregtab(pregtab.LAST) := ob_iax_preguntastab();
            pregtab(pregtab.LAST).cpregun := cpregun;
            pregtab(pregtab.LAST).nlinea := nlinea;
            pregtab(pregtab.LAST).nmovimi := pmovimi;
            pregtab_col := pac_iaxpar_productos.f_get_cabecera_preguntab('P', cpregun, NULL,
                                                                         mensajes);
            squery3 := 'SELECT CCOLUMNA,TVALOR,FVALOR, NVALOR' || ' FROM ' || vtab3
                       || ' WHERE S.SSEGURO=' || vsolicit || ' AND S.CPREGUN = ' || cpregun
                       || ' AND s.nlinea = ' || nlinea || ' AND ' || vmov2;
            DBMS_SQL.parse(curid3, squery3, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid3);
            DBMS_SQL.define_column(curid3, 1, ccolumna, 50);
            DBMS_SQL.define_column(curid3, 2, tvalor, 250);
            DBMS_SQL.define_column(curid3, 3, fvalor);
            DBMS_SQL.define_column(curid3, 4, nvalor);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows(curid3) = 0;
               DBMS_SQL.COLUMN_VALUE(curid3, 1, ccolumna);
               DBMS_SQL.COLUMN_VALUE(curid3, 2, tvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 3, fvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 4, nvalor);

               IF pregtab_col IS NOT NULL THEN
                  IF pregtab_col.COUNT <> 0 THEN
                     FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                        IF pregtab_col(k).ccolumna = ccolumna THEN
                           pregtab_col(k).ccolumna := ccolumna;
                           pregtab_col(k).tvalor := tvalor;
                           pregtab_col(k).fvalor := fvalor;
                           pregtab_col(k).nvalor := nvalor;

                           IF pregtab_col(k).ctipcol = 4 THEN
                              FOR rsp IN c_lista(cpregun, pregtab_col(k).ccolumna) LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                     rsp.clista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                     rsp.tlista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;
                              END LOOP;
                           ELSIF pregtab_col(k).ctipcol = 5 THEN
                              vconsulta := REPLACE(pregtab_col(k).tconsulta, ':PMT_IDIOMA',
                                                   pac_md_common.f_get_cxtidioma);
                              vconsulta := REPLACE(vconsulta, ':PMT_SPRODUC', vsproduc || ' ');
                              -- BUG26501 - 21/01/2014 - JTT: Afegim el parametre npoliza
                              vconsulta := REPLACE(vconsulta, ':PMT_NPOLIZA', vnpoliza || ' ');
                              vconsulta := REPLACE(vconsulta, ':PMT_CAGENTE', vcagente || ' ');
                              vpasexec := 14;
                              cur := pac_md_listvalores.f_opencursor(vconsulta, mensajes);
                              vpasexec := 15;

                              FETCH cur
                               INTO catribu, tatribu;

                              vpasexec := 16;

                              WHILE cur%FOUND LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                        catribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                        tatribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;

                                 FETCH cur
                                  INTO catribu, tatribu;

                                 vpasexec := 20;
                              END LOOP;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;

            pregtab(pregtab.LAST).tcolumnas := pregtab_col;
         END LOOP;

         preg(preg.LAST).tpreguntastab := pregtab;
         -- Bug 27768/157881 - JSV - 06/11/2013
         pregtab := t_iax_preguntastab();
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      DBMS_SQL.close_cursor(curid2);
      DBMS_SQL.close_cursor(curid3);
      RETURN preg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
   END f_leepreguntaspoliza;

/*************************************************************************
Lee gesti¿¿n comisi¿¿n
param out mensajes : mesajes de error
return             : objeto gesti¿¿n comisi¿¿n
*************************************************************************/
   FUNCTION f_leegstcomision(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gstcomision IS
      gstcom         t_iax_gstcomision := t_iax_gstcomision();
      curid          INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      squery         VARCHAR2(2000);
      cmodcom        NUMBER;
      pcomisi        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeGstComision';
      v_ctipcom      NUMBER;
      v_retenc       NUMBER;
      v_pcomisi      NUMBER;
      num_err        NUMBER := 0;
      vninialt       NUMBER;
      vnfinalt       NUMBER;
      v_count        NUMBER;
      vsseguro       NUMBER;   -- Bug 30642/169851 - 20/03/2014 - AMC

      CURSOR c_habitu IS
         SELECT catribu, tatribu
           FROM detvalores
          WHERE cvalor = 67
            AND cidioma = pac_md_common.f_get_cxtidioma();
   BEGIN
      IF vpmode = 'SOL' THEN
         RETURN NULL;
      ELSIF vpmode = 'EST' THEN
         vtab := 'ESTCOMISIONSEGU';
      ELSE
         vtab := 'COMISIONSEGU';
      END IF;

      --16363
      IF vpmode = 'EST' THEN
         SELECT ctipcom
           INTO v_ctipcom
           FROM estseguros
          WHERE sseguro = vsolicit;
      ELSE
         SELECT ctipcom
           INTO v_ctipcom
           FROM seguros
          WHERE sseguro = vsolicit;
      END IF;

      IF NVL(v_ctipcom, -1) = 0
         AND vpmode <> 'EST' THEN   --Habitual, para visualizacion en modificaciones de polizas
         FOR rc IN c_habitu LOOP
            num_err := f_pcomisi(vsolicit, rc.catribu, TRUNC(f_sysdate), v_pcomisi, v_retenc);

            IF num_err = 0 THEN
               gstcom.EXTEND;
               gstcom(gstcom.LAST) := ob_iax_gstcomision();
               gstcom(gstcom.LAST).cmodcom := rc.catribu;
               --num_err := f_pcomisi(vsolicit, rc.catribu, TRUNC(f_sysdate), v_pcomisi, v_retenc);
               gstcom(gstcom.LAST).pcomisi := v_pcomisi;
               gstcom(gstcom.LAST).tatribu :=
                  ff_desvalorfijo(67, pac_md_common.f_get_cxtidioma(),
                                  gstcom(gstcom.LAST).cmodcom);
            END IF;
         END LOOP;
      ELSE
         curid := DBMS_SQL.open_cursor;
         /*
         squery := 'SELECT CMODCOM,PCOMISI,NINIALT,NFINALT ' || ' FROM ' || vtab || ' S '
         || ' WHERE S.SSEGURO=' || vsolicit || ' AND S.NMOVIMI=' || vnmovimi;   -- Bug 30642/169851 - 20/03/2014 - AMC
         */
         squery := 'SELECT CMODCOM,PCOMISI,NINIALT,NFINALT ' || ' FROM ' || vtab || ' S '
                   || ' WHERE S.SSEGURO=' || vsolicit
                   || ' AND S.NMOVIMI= (select max(nmovimi) from ' || vtab
                   || ' where sseguro = ' || vsolicit || ')';   -- BUG 31992/0182634 - FAL - 02/09/2014 - QT: 13527

         IF pac_mdpar_productos.f_get_parproducto
                                                 ('ADMITE_CERTIFICADOS',
                                                  pac_iax_produccion.poliza.det_poliza.sproduc) =
                                                                                             1
            AND NOT pac_iax_produccion.isaltacol
            AND NOT pac_iax_produccion.issuplem THEN
            num_err :=
               pac_productos.f_get_herencia_col(pac_iax_produccion.poliza.det_poliza.sproduc,
                                                13, v_ctipcom);

            SELECT COUNT(1)
              INTO v_count
              FROM seguros
             WHERE ncertif = 0
               AND npoliza = pac_iax_produccion.poliza.det_poliza.npoliza;

            IF NVL(v_ctipcom, 0) = 1
               AND num_err = 0
               AND v_count > 0 THEN
               -- Bug 30642/169851 - 20/03/2014 - AMC
               SELECT sseguro
                 INTO vsseguro
                 FROM seguros
                WHERE npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
                  AND ncertif = 0;

               squery :=
                  'SELECT CMODCOM,PCOMISI,NINIALT,NFINALT FROM COMISIONSEGU S '
                  || ' WHERE S.SSEGURO IN (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA ='
                  || pac_iax_produccion.poliza.det_poliza.npoliza || ' AND NCERTIF = 0)'
                  || ' AND S.NMOVIMI = (select max(nmovimi) from comisionsegu where sseguro ='
                  || vsseguro || ')';
            -- Fi Bug 30642/169851 - 20/03/2014 - AMC
            END IF;
         END IF;

         DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
         dummy := DBMS_SQL.EXECUTE(curid);
         DBMS_SQL.define_column(curid, 1, cmodcom);
         DBMS_SQL.define_column(curid, 2, pcomisi);
         DBMS_SQL.define_column(curid, 3, vninialt);
         DBMS_SQL.define_column(curid, 4, vnfinalt);

         LOOP
            EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
            DBMS_SQL.COLUMN_VALUE(curid, 1, cmodcom);
            DBMS_SQL.COLUMN_VALUE(curid, 2, pcomisi);
            DBMS_SQL.COLUMN_VALUE(curid, 3, vninialt);
            DBMS_SQL.COLUMN_VALUE(curid, 4, vnfinalt);
            gstcom.EXTEND;
            gstcom(gstcom.LAST) := ob_iax_gstcomision();
            gstcom(gstcom.LAST).cmodcom := cmodcom;
            gstcom(gstcom.LAST).pcomisi := pcomisi;
            gstcom(gstcom.LAST).ninialt := vninialt;
            gstcom(gstcom.LAST).nfinalt := vnfinalt;
            gstcom(gstcom.LAST).tatribu := ff_desvalorfijo(67,
                                                           pac_md_common.f_get_cxtidioma(),
                                                           gstcom(gstcom.LAST).cmodcom);
         END LOOP;

         DBMS_SQL.close_cursor(curid);
      END IF;

      RETURN gstcom;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
   END f_leegstcomision;

/************************************************************************
Recupera informacion del riesgo -->>
*************************************************************************/
/************************************************************************
Funcion internar para recuperar los cursor de los distintos riesgos
param in pnriesgo : n¿mero de riesgo
return            : ref cursor
************************************************************************/
   FUNCTION f_getcurriesgo(pnriesgo IN NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_GetCurRiesgo';
      mensajes       t_iax_mensajes;
   BEGIN
      IF vpmode = 'SOL' THEN
         OPEN cur FOR
            SELECT r.*
              FROM solriesgos r
             WHERE r.ssolicit = vsolicit
               AND(r.nriesgo = pnriesgo
                   OR pnriesgo IS NULL);
      ELSIF vpmode = 'EST' THEN
         OPEN cur FOR
            SELECT r.*
              FROM estriesgos r
             WHERE r.sseguro = vsolicit
               AND(r.nriesgo = pnriesgo
                   OR pnriesgo IS NULL);
      ELSE
         OPEN cur FOR
            SELECT r.*
              FROM riesgos r
             WHERE r.sseguro = vsolicit
               AND(r.nriesgo = pnriesgo
                   OR pnriesgo IS NULL);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_getcurriesgo;

/*************************************************************************
Lee las primas del riesgo
param in riesgo    : objecte risc a omplir dades
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leeriesgoprimas(riesgo IN OUT ob_iax_riesgos, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_primas IS
      primas         ob_iax_primas := ob_iax_primas();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRiesgoPrimas';
      v_pdtocom      NUMBER;
      v_precarg      NUMBER;
      v_pdtotec      NUMBER;
      v_preccom      NUMBER;
   BEGIN
      riesgo.p_set_needtarificar(0);
      v_pdtocom := riesgo.primas.pdtocom;
      v_precarg := riesgo.primas.precarg;
      v_pdtotec := riesgo.primas.pdtotec;
      v_preccom := riesgo.primas.preccom;
      primas := riesgo.f_get_primas(vsolicit, vnmovimi, vpmode);
      riesgo.primas.pdtocom := v_pdtocom;
      riesgo.primas.precarg := v_precarg;
      riesgo.primas.pdtotec := v_pdtotec;
      riesgo.primas.preccom := v_preccom;
      RETURN primas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeriesgoprimas;

/*************************************************************************
Recuperar la informacion del riesgo personal
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leeriesgopersonal(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_personas IS
      person         t_iax_personas := t_iax_personas();
      nnum           NUMBER;
      cur            sys_refcursor;
      solrie         solriesgos%ROWTYPE;
      estrie         estriesgos%ROWTYPE;
      polrie         riesgos%ROWTYPE;
      vcagente       NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRiesgoPersonal';
   BEGIN
      cur := f_getcurriesgo(pnriesgo);

      IF vpmode = 'SOL' THEN
         vpasexec := 11;

         LOOP
            FETCH cur
             INTO solrie;

            EXIT WHEN cur%NOTFOUND;
            vpasexec := 13;
            person.EXTEND;
            nnum := person.LAST;
            person(nnum) := ob_iax_personas();
            person(nnum).tapelli1 := solrie.tapelli;
            person(nnum).tnombre := solrie.tnombre;
            person(nnum).fnacimi := solrie.fnacimi;
            person(nnum).csexper := solrie.csexper;
            person(nnum).sperson := solrie.sperson;
            vpasexec := 15;
            person(nnum).tsexper := pac_iax_listvalores.f_getdescripvalores(11,
                                                                            solrie.csexper,
                                                                            mensajes);
         END LOOP;
      ELSIF vpmode = 'EST' THEN
         vpasexec := 21;

         LOOP
            FETCH cur
             INTO estrie;

            EXIT WHEN cur%NOTFOUND;
            vpasexec := 23;
            num_err := pac_seguros.f_get_cagente(estrie.sseguro, 'EST', vcagente);
            person.EXTEND;
            nnum := person.LAST;
            person(nnum) := ob_iax_personas();
            person(nnum).sperson := estrie.sperson;
            vpasexec := 25;
            num_err := pac_md_persona.f_get_persona_agente(estrie.sperson, vcagente, vpmode,
                                                           person(nnum), mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;
         END LOOP;
      ELSE
         vpasexec := 31;

         LOOP
            FETCH cur
             INTO polrie;

            EXIT WHEN cur%NOTFOUND;
            vpasexec := 33;
            num_err := pac_seguros.f_get_cagente(polrie.sseguro, 'REAL', vcagente);
            person.EXTEND;
            nnum := person.LAST;
            person(nnum) := ob_iax_personas();
            person(nnum).sperson := polrie.sperson;
            vpasexec := 35;
            num_err := pac_md_persona.f_get_persona_agente(polrie.sperson, vcagente, vpmode,
                                                           person(nnum), mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;
         END LOOP;
      END IF;

      CLOSE cur;

      RETURN person;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leeriesgopersonal;

/*************************************************************************
Recuperar la informacion del riesgo direcciones
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leeriesgodirecciones(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_sitriesgos IS
      direc          ob_iax_sitriesgos := ob_iax_sitriesgos();
      nnum           NUMBER;
      cur            sys_refcursor;
      solrie         solriesgos%ROWTYPE;
      estrie         estriesgos%ROWTYPE;
      polrie         riesgos%ROWTYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRiesgoDirecciones';
      vnumerr        NUMBER;
   BEGIN
      cur := f_getcurriesgo(pnriesgo);

      IF vpmode = 'EST' THEN
         LOOP
            FETCH cur
             INTO estrie;

            EXIT WHEN cur%NOTFOUND;

            IF estrie.sperson IS NULL THEN
               vpasexec := 3;

               BEGIN
                  -- Bug 12668 - 17/02/2010 - AMC
                  SELECT tdomici, cprovin, cpostal, cpoblac,
                         csiglas, tnomvia, nnumvia, tcomple,
                         cciudad, fgisx, fgisy, fgisz, cvalida,
                         cviavp, clitvp, cbisvp, corvp,
                         nviaadco, clitco, corco, nplacaco,
                         cor2co, cdet1ia, tnum1ia, cdet2ia,
                         tnum2ia, cdet3ia, tnum3ia, iddomici,
                         localidad, fdefecto, descripcion
                    INTO direc.tdomici, direc.cprovin, direc.cpostal, direc.cpoblac,
                         direc.csiglas, direc.tnomvia, direc.nnumvia, direc.tcomple,
                         direc.cciudad, direc.fgisx, direc.fgisy, direc.fgisz, direc.cvalida,
                         direc.cviavp, direc.clitvp, direc.cbisvp, direc.corvp,
                         direc.nviaadco, direc.clitco, direc.corco, direc.nplacaco,
                         direc.cor2co, direc.cdet1ia, direc.tnum1ia, direc.cdet2ia,
                         direc.tnum2ia, direc.cdet3ia, direc.tnum3ia, direc.iddomici,
                         direc.localidad, direc.fdefecto, direc.descripcion
                    FROM estsitriesgo
                   WHERE sseguro = vsolicit
                     AND nriesgo = pnriesgo;

                  -- Fi Bug 12668 - 17/02/2010 - AMC
                  vpasexec := 4;
                  direc.tprovin :=
                     pac_iax_listvalores.f_getdescripvalor
                                          ('SELECT tprovin FROM PROVINCIAS WHERE cprovin ='
                                           || direc.cprovin,
                                           mensajes);
                  vpasexec := 5;
                  direc.tpoblac :=
                     pac_iax_listvalores.f_getdescripvalor
                                        ('SELECT tpoblac FROM POBLACIONES WHERE cprovin = '
                                         || direc.cprovin || ' AND cpoblac = ' || direc.cpoblac,
                                         mensajes);
                  vpasexec := 6;
                  direc.cpais := ff_cpais(direc.cprovin);
                  vpasexec := 7;
                  direc.tpais :=
                     pac_iax_listvalores.f_getdescripvalor
                                                 ('SELECT tpais FROM PAISES WHERE cpais = '
                                                  || direc.cpais,
                                                  mensajes);
                  -- Bug 20893/111636 - 02/05/2012 - AMC
                  direc.domicilios := t_iax_dir_domicilios();

                  FOR dom IN (SELECT iddomici
                                FROM estdir_riesgos
                               WHERE sseguro = vsolicit
                                 AND nriesgo = pnriesgo) LOOP
                     direc.domicilios.EXTEND;
                     vnumerr :=
                        pac_md_direcciones.f_get_departamento
                                                     (dom.iddomici,
                                                      direc.domicilios(direc.domicilios.LAST),
                                                      mensajes);
                  END LOOP;
               -- Fi Bug 20893/111636 - 02/05/2012 - AMC
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;
         END LOOP;
      ELSE
         LOOP
            FETCH cur
             INTO polrie;

            EXIT WHEN cur%NOTFOUND;

            IF polrie.sperson IS NULL THEN
               vpasexec := 3;

               BEGIN
                  -- Bug 12668 - 17/02/2010 - AMC
                  SELECT tdomici, cprovin, cpostal, cpoblac,
                         csiglas, tnomvia, nnumvia, tcomple,
                         cciudad, fgisx, fgisy, fgisz, cvalida,
                         cviavp, clitvp, cbisvp, corvp,
                         nviaadco, clitco, corco, nplacaco,
                         cor2co, cdet1ia, tnum1ia, cdet2ia,
                         tnum2ia, cdet3ia, tnum3ia, iddomici,
                         localidad, fdefecto, descripcion
                    INTO direc.tdomici, direc.cprovin, direc.cpostal, direc.cpoblac,
                         direc.csiglas, direc.tnomvia, direc.nnumvia, direc.tcomple,
                         direc.cciudad, direc.fgisx, direc.fgisy, direc.fgisz, direc.cvalida,
                         direc.cviavp, direc.clitvp, direc.cbisvp, direc.corvp,
                         direc.nviaadco, direc.clitco, direc.corco, direc.nplacaco,
                         direc.cor2co, direc.cdet1ia, direc.tnum1ia, direc.cdet2ia,
                         direc.tnum2ia, direc.cdet3ia, direc.tnum3ia, direc.iddomici,
                         direc.localidad, direc.fdefecto, direc.descripcion
                    FROM sitriesgo
                   WHERE sseguro = vsolicit
                     AND nriesgo = pnriesgo;

                  -- Fi Bug 12668 - 17/02/2010 - AMC
                  vpasexec := 4;
                  direc.tprovin :=
                     pac_iax_listvalores.f_getdescripvalor
                                          ('SELECT tprovin FROM PROVINCIAS WHERE cprovin ='
                                           || direc.cprovin,
                                           mensajes);
                  vpasexec := 5;
                  direc.tpoblac :=
                     pac_iax_listvalores.f_getdescripvalor
                                        ('SELECT tpoblac FROM POBLACIONES WHERE cprovin = '
                                         || direc.cprovin || ' AND cpoblac = ' || direc.cpoblac,
                                         mensajes);
                  vpasexec := 6;
                  direc.cpais := ff_cpais(direc.cprovin);
                  vpasexec := 7;
                  direc.tpais :=
                     pac_iax_listvalores.f_getdescripvalor
                                                 ('SELECT tpais FROM PAISES WHERE cpais = '
                                                  || direc.cpais,
                                                  mensajes);
                  -- Bug 20893/111636 - 02/05/2012 - AMC
                  direc.domicilios := t_iax_dir_domicilios();

                  FOR dom IN (SELECT iddomici
                                FROM dir_riesgos
                               WHERE sseguro = vsolicit
                                 AND nriesgo = pnriesgo) LOOP
                     direc.domicilios.EXTEND;
                     vnumerr :=
                        pac_md_direcciones.f_get_departamento
                                                     (dom.iddomici,
                                                      direc.domicilios(direc.domicilios.LAST),
                                                      mensajes);
                  END LOOP;
               -- Fi Bug 20893/111636 - 02/05/2012 - AMC
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;
         END LOOP;
      END IF;

      CLOSE cur;

      RETURN direc;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leeriesgodirecciones;

/*************************************************************************
Recuperar la informacion de los asegurados
param out mensajes : mesajes de error
param in pnriesgo  : n¿mero de riesgo
return             : objeto asegurados
*************************************************************************/
   FUNCTION f_leeasegurados(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_asegurados IS
      v_param        VARCHAR2(200) := '2_CABEZAS';

      CURSOR solaseg IS
         SELECT *
           FROM solasegurados
          WHERE ssolicit = vsolicit;

      CURSOR estaseg IS
         SELECT   ase.*
             FROM estassegurats ase, estseguros s
            WHERE ase.sseguro = vsolicit
              AND ase.sseguro = s.sseguro
              AND(NVL(pac_parametros.f_parproducto_n(s.sproduc, v_param), 0) = 1
                  OR(NVL(pac_parametros.f_parproducto_n(s.sproduc, v_param), 0) = 0
                     AND ase.norden = pnriesgo))
              AND ROWNUM < NVL(pac_parametros.f_parproducto_n(s.sproduc, 'N_MAX_ASE_RIES') + 1,
                               999)
         ORDER BY ase.norden;

      CURSOR polaseg IS
         SELECT   ase.*
             FROM asegurados ase, seguros s
            WHERE ase.sseguro = vsolicit
              AND ase.sseguro = s.sseguro
              AND(NVL(pac_parametros.f_parproducto_n(s.sproduc, v_param), 0) = 1
                  OR(NVL(pac_parametros.f_parproducto_n(s.sproduc, v_param), 0) = 0
                     AND ase.norden = pnriesgo))
              AND ROWNUM < NVL(pac_parametros.f_parproducto_n(s.sproduc, 'N_MAX_ASE_RIES') + 1,
                               999)
         ORDER BY ase.norden;

      aseg           t_iax_asegurados := t_iax_asegurados();
      ndirec         NUMBER;   --BUG 28455/158211 - RCL - 12/11/2013
      vcagente       NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeAsegurados';
   BEGIN
      IF vpmode = 'SOL' THEN
         FOR saseg IN solaseg LOOP
            aseg.EXTEND;
            aseg(aseg.LAST) := ob_iax_asegurados();
            aseg(aseg.LAST).norden := saseg.norden;
            aseg(aseg.LAST).fnacimi := saseg.fnacimi;
            aseg(aseg.LAST).csexper := saseg.csexper;
            aseg(aseg.LAST).tapelli1 := saseg.tapelli;
            aseg(aseg.LAST).tnombre := saseg.tnombre;
            vpasexec := 2;
            aseg(aseg.LAST).tsexper := pac_iax_listvalores.f_getdescripvalores(11,
                                                                               saseg.csexper,
                                                                               mensajes);

            --BUG 28455/158211 - RCL - 12/11/2013 - 0028455: LCOL_T031- TEC - Revisi?-Trackers Fase 3A II
            IF aseg(aseg.LAST).direcciones IS NULL THEN
               aseg(aseg.LAST).direcciones := t_iax_direcciones();
            END IF;
         END LOOP;
      ELSIF vpmode = 'EST' THEN
         FOR easeg IN estaseg LOOP
            num_err := pac_seguros.f_get_cagente(easeg.sseguro, 'EST', vcagente);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            aseg.EXTEND;
            aseg(aseg.LAST) := ob_iax_asegurados();
            aseg(aseg.LAST).norden := easeg.norden;
            aseg(aseg.LAST).sperson := easeg.sperson;
            aseg(aseg.LAST).ffecini := easeg.ffecini;
            aseg(aseg.LAST).ffecfin := easeg.ffecfin;
            aseg(aseg.LAST).ffecmue := easeg.ffecmue;
            aseg(aseg.LAST).fecretroact := easeg.fecretroact;
            aseg(aseg.LAST).cparen := easeg.cparen;
            vpasexec := 3;
            num_err := pac_md_persona.f_get_persona_agente(easeg.sperson, vcagente, vpmode,
                                                           aseg(aseg.LAST), mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 4;

            --P_FindIsTomador(easeg.sperson);
            --Inici - BUG 28455/158211 - RCL - 12/11/2013 - 0028455: LCOL_T031- TEC - Revisi?-Trackers Fase 3A II
            IF aseg(aseg.LAST).direcciones IS NULL THEN
               aseg(aseg.LAST).direcciones := t_iax_direcciones();
            END IF;

            aseg(aseg.LAST).direcciones.EXTEND;
            ndirec := aseg(aseg.LAST).direcciones.LAST;
            aseg(aseg.LAST).direcciones(ndirec) := ob_iax_direcciones();
            aseg(aseg.LAST).direcciones(ndirec).cdomici := easeg.cdomici;
            vpasexec := 7;

            IF easeg.cdomici IS NOT NULL THEN
               pac_md_listvalores.p_ompledadesdireccions(easeg.sperson, easeg.cdomici, vpmode,
                                                         aseg(aseg.LAST).direcciones(ndirec),
                                                         mensajes);
            END IF;
         --Fi - BUG 28455/158211 - RCL - 12/11/2013 - 0028455: LCOL_T031- TEC - Revisi?-Trackers Fase 3A II
         END LOOP;
      ELSE
         FOR saseg IN polaseg LOOP
            num_err := pac_seguros.f_get_cagente(saseg.sseguro, 'SEG', vcagente);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            aseg.EXTEND;
            aseg(aseg.LAST) := ob_iax_asegurados();
            aseg(aseg.LAST).norden := saseg.norden;
            aseg(aseg.LAST).sperson := saseg.sperson;
            aseg(aseg.LAST).ffecini := saseg.ffecini;
            aseg(aseg.LAST).ffecfin := saseg.ffecfin;
            aseg(aseg.LAST).ffecmue := saseg.ffecmue;
            aseg(aseg.LAST).fecretroact := saseg.fecretroact;
            aseg(aseg.LAST).cparen := saseg.cparen;
            vpasexec := 5;
            num_err := pac_md_persona.f_get_persona_agente(saseg.sperson, vcagente, vpmode,
                                                           aseg(aseg.LAST), mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 6;

            --P_FindIsTomador(saseg.sperson);
            --Inici - BUG 28455/158211 - RCL - 12/11/2013 - 0028455: LCOL_T031- TEC - Revisi?-Trackers Fase 3A II
            IF aseg(aseg.LAST).direcciones IS NULL THEN
               aseg(aseg.LAST).direcciones := t_iax_direcciones();
            END IF;

            aseg(aseg.LAST).direcciones.EXTEND;
            ndirec := aseg(aseg.LAST).direcciones.LAST;
            aseg(aseg.LAST).direcciones(ndirec) := ob_iax_direcciones();
            aseg(aseg.LAST).direcciones(ndirec).cdomici := saseg.cdomici;
            vpasexec := 10;

            IF saseg.cdomici IS NOT NULL THEN
               pac_md_listvalores.p_ompledadesdireccions(saseg.sperson, saseg.cdomici, vpmode,
                                                         aseg(aseg.LAST).direcciones(ndirec),
                                                         mensajes);
            END IF;
         --Fi - BUG 28455/158211 - RCL - 12/11/2013 - 0028455: LCOL_T031- TEC - Revisi?-Trackers Fase 3A II
         END LOOP;
      END IF;

      RETURN aseg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeasegurados;

/*************************************************************************
Recuperar la informacion de las preguntas
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto preguntas
*************************************************************************/
   FUNCTION f_leepreguntasriesgo(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas IS
      preg           t_iax_preguntas := t_iax_preguntas();
      pregtab        t_iax_preguntastab := t_iax_preguntastab();
      pregtab_col    t_iax_preguntastab_columns := t_iax_preguntastab_columns();
      curid          INTEGER;
      curid2         INTEGER;
      curid3         INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      vtab2          VARCHAR2(50);
      vtab3          VARCHAR2(50);
      vmov           VARCHAR2(500);
      vmov2          VARCHAR2(500);
      squery         VARCHAR2(2000);
      squery2        VARCHAR2(2000);
      squery3        VARCHAR2(2000);
      cpregun        NUMBER;
      crespue        FLOAT;
      trespue        VARCHAR2(2000);
      nmovimi        NUMBER;
      ccolumna       VARCHAR2(50);
      nlinea         NUMBER;
      tvalor         VARCHAR2(250);
      fvalor         DATE;
      nvalor         NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeePreguntasRiesgo';
      vtab4          VARCHAR2(50);   -- BUG 0036730 - FAL - 15/12/2015

      CURSOR c_lista(cprg NUMBER, colum VARCHAR2) IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      vconsulta      VARCHAR2(4000);
      cur            sys_refcursor;
      catribu        NUMBER;
      tatribu        VARCHAR2(1000);
      vsproduc       NUMBER;
      vnpoliza       NUMBER;
      vcagente       NUMBER;
   BEGIN
      IF vpmode = 'EST' THEN
         vtab := 'ESTPREGUNSEG S';
         vtab2 := ',PREGUNPRO PR, ESTSEGUROS SE';
         vtab3 := 'ESTPREGUNSEGTAB S';
         vtab4 := ',PREGUNPROACTIVI PR, ESTSEGUROS SE';
      -- BUG 0036730 - FAL - 15/12/2015
      ELSE
         vtab := 'PREGUNSEG S';
         vtab2 := ',PREGUNPRO PR, SEGUROS SE';
         vtab3 := 'PREGUNSEGTAB S';
         vtab4 := ',PREGUNPROACTIVI PR, SEGUROS SE';
      -- BUG 0036730 - FAL - 15/12/2015
      END IF;

      SELECT sproduc, npoliza, cagente
        INTO vsproduc, vnpoliza, vcagente
        FROM (SELECT sproduc, npoliza, cagente
                FROM estseguros
               WHERE sseguro = vsolicit
                 AND vpmode = 'EST'
              UNION ALL
              SELECT sproduc, npoliza, cagente
                FROM seguros
               WHERE sseguro = vsolicit
                 AND NVL(vpmode, 'SEG') <> 'EST');

      vmov := ' AND S.NMOVIMI=(SELECT MAX (nmovimi) ' || ' FROM ' || vtab
              || ' WHERE  sseguro = ' || vsolicit || '  AND   nriesgo = ' || pnriesgo || ')';
      vmov2 := ' AND S.NMOVIMI=(SELECT MAX (nmovimi) ' || ' FROM ' || vtab3
               || ' WHERE  sseguro = ' || vsolicit || '  AND   nriesgo = ' || pnriesgo || ')';
      curid := DBMS_SQL.open_cursor;
      squery :=
         'SELECT S.CPREGUN,S.CRESPUE,S.TRESPUE,NMOVIMI, NPREORD  ' || ' FROM ' || vtab || vtab2
         || ' WHERE S.SSEGURO=' || vsolicit || ' AND S.NRIESGO=' || pnriesgo
         || ' AND S.CPREGUN = PR.CPREGUN AND SE.SPRODUC = PR.SPRODUC'
         || ' AND SE.SSEGURO = S.SSEGURO' || vmov || ' UNION'   -- BUG 0036730 - FAL - 15/12/2015
         || ' SELECT S.CPREGUN,S.CRESPUE,S.TRESPUE,NMOVIMI, NPREORD ' || ' FROM ' || vtab
         || vtab4 || ' WHERE S.SSEGURO=' || vsolicit || ' AND S.NRIESGO=' || pnriesgo
         || ' AND S.CPREGUN = PR.CPREGUN AND SE.SPRODUC = PR.SPRODUC AND SE.CACTIVI = PR.CACTIVI'
         || ' AND SE.SSEGURO = S.SSEGURO' || vmov || ' ORDER BY NPREORD,CPREGUN';
      -- FI BUG 0036730 - FAL - 15/12/2015
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);
      DBMS_SQL.define_column(curid, 2, crespue);
      DBMS_SQL.define_column(curid, 3, trespue, 2000);
      DBMS_SQL.define_column(curid, 4, nmovimi);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         DBMS_SQL.COLUMN_VALUE(curid, 2, crespue);
         DBMS_SQL.COLUMN_VALUE(curid, 3, trespue);
         DBMS_SQL.COLUMN_VALUE(curid, 4, nmovimi);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := crespue;
         preg(preg.LAST).trespue := trespue;
         preg(preg.LAST).nmovimi := nmovimi;
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      curid := DBMS_SQL.open_cursor;
      curid2 := DBMS_SQL.open_cursor;
      curid3 := DBMS_SQL.open_cursor;
      squery := 'SELECT distinct(cpregun)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                || vsolicit || ' AND S.NRIESGO=' || pnriesgo || vmov2;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := NULL;
         preg(preg.LAST).trespue := NULL;
         squery2 := 'SELECT distinct(NLINEA)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                    || vsolicit || ' AND S.NRIESGO=' || pnriesgo || ' AND S.CPREGUN = '
                    || cpregun || vmov2;
         DBMS_SQL.parse(curid2, squery2, DBMS_SQL.v7);
         dummy := DBMS_SQL.EXECUTE(curid2);
         DBMS_SQL.define_column(curid2, 1, nlinea);

         LOOP
            EXIT WHEN DBMS_SQL.fetch_rows(curid2) = 0;
            DBMS_SQL.COLUMN_VALUE(curid2, 1, nlinea);
            pregtab.EXTEND;
            pregtab(pregtab.LAST) := ob_iax_preguntastab();
            pregtab(pregtab.LAST).cpregun := cpregun;
            pregtab(pregtab.LAST).nlinea := nlinea;
            pregtab(pregtab.LAST).nmovimi := nmovimi;
            pregtab_col := pac_iaxpar_productos.f_get_cabecera_preguntab('R', cpregun, NULL,
                                                                         mensajes);
            squery3 := 'SELECT CCOLUMNA,TVALOR,FVALOR, NVALOR' || ' FROM ' || vtab3
                       || ' WHERE S.SSEGURO=' || vsolicit || ' AND S.NRIESGO=' || pnriesgo
                       || ' AND S.CPREGUN = ' || cpregun || ' AND s.nlinea = ' || nlinea
                       || vmov2;
            DBMS_SQL.parse(curid3, squery3, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid3);
            DBMS_SQL.define_column(curid3, 1, ccolumna, 50);
            DBMS_SQL.define_column(curid3, 2, tvalor, 250);
            DBMS_SQL.define_column(curid3, 3, fvalor);
            DBMS_SQL.define_column(curid3, 4, nvalor);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows(curid3) = 0;
               DBMS_SQL.COLUMN_VALUE(curid3, 1, ccolumna);
               DBMS_SQL.COLUMN_VALUE(curid3, 2, tvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 3, fvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 4, nvalor);

               IF pregtab_col IS NOT NULL THEN
                  IF pregtab_col.COUNT <> 0 THEN
                     FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                        IF pregtab_col(k).ccolumna = ccolumna THEN
                           pregtab_col(k).ccolumna := ccolumna;
                           pregtab_col(k).tvalor := tvalor;
                           pregtab_col(k).fvalor := fvalor;
                           pregtab_col(k).nvalor := nvalor;

                           IF pregtab_col(k).ctipcol = 4 THEN
                              FOR rsp IN c_lista(cpregun, pregtab_col(k).ccolumna) LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                     rsp.clista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                     rsp.tlista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;
                              END LOOP;
                           ELSIF pregtab_col(k).ctipcol = 5 THEN
                              vconsulta := REPLACE(pregtab_col(k).tconsulta, ':PMT_IDIOMA',
                                                   pac_md_common.f_get_cxtidioma);
                              vconsulta := REPLACE(vconsulta, ':PMT_SPRODUC', vsproduc || ' ');
                              -- BUG26501 - 21/01/2014 - JTT: Afegim el parametre npoliza
                              vconsulta := REPLACE(vconsulta, ':PMT_NPOLIZA', vnpoliza || ' ');
                              vconsulta := REPLACE(vconsulta, ':PMT_CAGENTE', vcagente || ' ');
                              vpasexec := 14;
                              cur := pac_md_listvalores.f_opencursor(vconsulta, mensajes);
                              vpasexec := 15;

                              FETCH cur
                               INTO catribu, tatribu;

                              vpasexec := 16;

                              WHILE cur%FOUND LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                        catribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                        tatribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;

                                 FETCH cur
                                  INTO catribu, tatribu;

                                 vpasexec := 20;
                              END LOOP;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;

            pregtab(pregtab.LAST).tcolumnas := pregtab_col;
         END LOOP;

         preg(preg.LAST).tpreguntastab := pregtab;
         -- Bug 27768/157881 - JSV - 06/11/2013
         pregtab := t_iax_preguntastab();
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      DBMS_SQL.close_cursor(curid2);
      DBMS_SQL.close_cursor(curid3);
      RETURN preg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
   END f_leepreguntasriesgo;

/*************************************************************************
Recuperar la informacion de las garantias
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto garantias
*************************************************************************/
   FUNCTION f_leegarantias(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garantias IS
      cur            sys_refcursor;
      solgar         solgaranseg%ROWTYPE;
      estgar         estgaranseg%ROWTYPE;
      polgar         garanseg%ROWTYPE;
      garant         t_iax_garantias := t_iax_garantias();
      squery         VARCHAR2(2000);
      vtab           VARCHAR2(30);
      vfield         VARCHAR2(30);
      vfields        VARCHAR2(1000);
      pri            ob_iax_primas;
      sproduc        NUMBER;
      vtab2          VARCHAR2(30);
      vcond          VARCHAR2(500);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeGarantias';
      -- Bug 10101 - 22/05/2009 - RSC - Detalle de garantias
      v_garmas       ob_iax_masdatosgar;
      v_garmas2      ob_iax_masdatosgar;
      v_cgarant      garanseg.cgarant%TYPE;
      v_nmovimi      garanseg.nmovimi%TYPE;
      v_finiefe      garanseg.finiefe%TYPE;
      v_norden       garanseg.norden%TYPE;
      v_ifranqu      garanseg.ifranqu%TYPE;
      v_icaptot      garanseg.icaptot%TYPE;
      v_nmovima      garanseg.nmovima%TYPE;
      v_cfranq       garanseg.cfranq%TYPE;
      v_cderreg      garanseg.cderreg%TYPE;   -- BUG 19578 - FAL
      v_ndetgar      detgaranseg.ndetgar%TYPE;
      v_fefecto      detgaranseg.fefecto%TYPE;
      v_fvencim      detgaranseg.fvencim%TYPE;
      v_ndurcob      detgaranseg.ndurcob%TYPE;
      v_ctarifa      detgaranseg.ctarifa%TYPE;
      v_pinttec      detgaranseg.pinttec%TYPE;
      v_ftarifa      detgaranseg.ftarifa%TYPE;
      v_crevali      detgaranseg.crevali%TYPE;
      v_prevali      detgaranseg.prevali%TYPE;
      v_irevali      detgaranseg.irevali%TYPE;
      v_icapital     detgaranseg.icapital%TYPE;
      v_iprianu      detgaranseg.iprianu%TYPE;
      v_precarg      detgaranseg.precarg%TYPE;
      v_irecarg      detgaranseg.irecarg%TYPE;
      v_cparben      detgaranseg.cparben%TYPE;
      v_cprepost     detgaranseg.cprepost%TYPE;
      v_ffincob      detgaranseg.ffincob%TYPE;
      v_ipritar      detgaranseg.ipritar%TYPE;
      v_provmat0     detgaranseg.provmat0%TYPE;
      v_fprovmat0    detgaranseg.fprovmat0%TYPE;
      v_provmat1     detgaranseg.provmat1%TYPE;
      v_fprovmat1    detgaranseg.fprovmat1%TYPE;
      v_pintmin      detgaranseg.pintmin%TYPE;
      v_pdtocom      detgaranseg.pdtocom%TYPE;
      v_idtocom      detgaranseg.idtocom%TYPE;
      v_ctarman      detgaranseg.ctarman%TYPE;
      v_ipripur      detgaranseg.ipripur%TYPE;
      v_ipriinv      detgaranseg.ipriinv%TYPE;
      v_itarrea      detgaranseg.itarrea%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      NUMBER;
      v_crealiza     NUMBER;
      -- Fin Bug 10101
      v_nfactor      NUMBER;   -- Bug 30171/173304 - 13/05/2014 - AMC
   BEGIN
      IF vpmode = 'SOL' THEN
         SELECT sproduc, cactivi
           INTO v_sproduc, v_cactivi
           FROM solseguros
          WHERE sseguro = vsolicit;

         vfield := 'ssolicit';
         vtab := 'SOLGARANSEG';
         vtab2 := 'solseguros';
         vfields := '*';
         squery := 'SELECT ' || vfields || ' FROM ' || vtab || ' where ' || vfield || '='
                   || vsolicit || ' and ' || '       nriesgo=' || pnriesgo || vcond;
      ELSIF vpmode = 'EST' THEN
         SELECT sproduc, cactivi
           INTO v_sproduc, v_cactivi
           FROM estseguros
          WHERE sseguro = vsolicit;

         vfield := 'SSEGURO';
         vtab := 'ESTGARANSEG';
         vtab2 := 'estseguros';
         vfields := '*';
         vcond := ' AND ffinefe IS NULL  order by NORDEN asc';
         squery := 'SELECT ' || vfields || ' FROM ' || vtab || ' where ' || vfield || '='
                   || vsolicit || ' and ' || '       nriesgo=' || pnriesgo || vcond;
      ELSE
         SELECT sproduc, cactivi
           INTO v_sproduc, v_cactivi
           FROM seguros
          WHERE sseguro = vsolicit;

         -- Bug 29943 - 05/06/2014 - JTT: Los productos con detalle de garantia y TIPO_PB = 1
         -- los tratamos como un producto normal.
         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2)
            AND NVL(f_parproductos_v(v_sproduc, 'TIPO_PB'), 0) <> 1 THEN
            vfield := 'g.SSEGURO';
            vtab := 'GARANSEG g, DETGARANSEG dg';
            vtab2 := 'seguros';
            vfields :=
               'g.CGARANT, g.NMOVIMI, g.FINIEFE, g.NORDEN, g.IFRANQU, g.ICAPTOT, g.NMOVIMA, g.CFRANQ, dg.NDETGAR,
dg.FEFECTO, dg.FVENCIM, dg.NDURCOB, dg.CTARIFA, dg.PINTTEC, dg.FTARIFA, dg.CREVALI, dg.PREVALI, dg.IREVALI, dg.ICAPITAL,
dg.IPRIANU, dg.PRECARG, dg.IRECARG, dg.CPARBEN, dg.CPREPOST, dg.FFINCOB, dg.IPRITAR,
dg.PROVMAT0, dg.FPROVMAT0, dg.PROVMAT1, dg.FPROVMAT1, dg.PINTMIN, dg.PDTOCOM, dg.IDTOCOM, dg.CTARMAN, dg.IPRIPUR,
dg.IPRIINV, dg.ITARREA, g.cderreg, g.nfactor';
            -- Bug 30171/173304 - 13/05/2014 - AMC
            -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
            vcond := ' AND g.sseguro = dg.sseguro ' || 'AND g.nriesgo = dg.nriesgo '
                     || 'AND g.cgarant = dg.cgarant ' || 'AND g.finiefe = dg.finiefe '
                     || 'AND g.nmovimi = dg.nmovimi '
                     || 'AND dg.nmovimi = (SELECT MAX(dg2.nmovimi) '
                     || '                  FROM garanseg dg2 '
                     || '                  WHERE dg2.sseguro = dg.sseguro '
                     || '                    AND dg2.nriesgo = dg.nriesgo '
                     || '                    AND dg2.cgarant = dg.cgarant '
                     || '                    AND dg2.ffinefe IS NULL) '
                     || 'AND g.ffinefe IS NULL ' || 'ORDER BY norden, ndetgar ASC ';
         ELSE
            vfield := 'SSEGURO';
            vtab := 'GARANSEG g';
            vtab2 := 'seguros';
            vfields := '*';
            vcond := ' AND NMOVIMI = (SELECT MAX (b.nmovimi) ' || ' FROM GARANSEG b '
                     || ' WHERE  b.sseguro = ' || vsolicit || ' AND b.nriesgo = ' || pnriesgo
                     || ') order by norden asc ';
         END IF;

         squery := 'SELECT ' || vfields || ' FROM ' || vtab || ' WHERE ' || vfield || '='
                   || vsolicit || ' AND ' || ' g.nriesgo=' || pnriesgo || vcond;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);

      BEGIN
         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
            sproduc :=
               TO_NUMBER(pac_iax_listvalores.f_getdescripvalor('select sproduc from ' || vtab2
                                                               || ' where SSEGURO = '
                                                               || vsolicit,
                                                               mensajes));
         ELSE
            sproduc :=
               TO_NUMBER(pac_iax_listvalores.f_getdescripvalor('select sproduc from ' || vtab2
                                                               || ' where ' || vfield || '='
                                                               || vsolicit,
                                                               mensajes));
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            sproduc := NULL;
      END;

      IF vpmode = 'SOL' THEN
         LOOP
            FETCH cur
             INTO solgar;

            EXIT WHEN cur%NOTFOUND;
            garant.EXTEND;
            garant(garant.LAST) := ob_iax_garantias();
            garant(garant.LAST).cgarant := solgar.cgarant;
            garant(garant.LAST).icapital := solgar.icapital;
            --garant(garant.last).iprianu  := SOLGAR.iprianu;
            garant(garant.LAST).crevali := solgar.crevali;
            garant(garant.LAST).prevali := solgar.prevali;
            garant(garant.LAST).irevali := solgar.irevali;
            --garant(garant.last).precarg  := SOLGAR.precarg;
            garant(garant.LAST).cfranq := solgar.cfranq;
            garant(garant.LAST).ctarman := 0;
            --garant(garant.last).irecarg  := SOLGAR.irecarg;
            garant(garant.LAST).ifranqu := solgar.ifranqu;
            garant(garant.LAST).finiefe := solgar.finiefe;
            garant(garant.LAST).nmovimi := 1;
            garant(garant.LAST).norden := solgar.norden;
            garant(garant.LAST).excaprecomend :=
               NVL(pac_parametros.f_pargaranpro_n(sproduc, v_cactivi, solgar.cgarant,
                                                  'CAPRECOMEND'),
                   0);
            garant(garant.LAST).cpartida :=
               NVL(pac_parametros.f_pargaranpro_n(sproduc, v_cactivi, solgar.cgarant,
                                                  'PARTIDA'),
                   0);
            --  garant(garant.LAST).icaprecomend := solgar.icaprecomend;
            garant(garant.LAST).norden := solgar.norden;
            vpasexec := 2;
            garant(garant.LAST).preguntas := f_leepreguntasgarantia(pnriesgo, solgar.cgarant,
                                                                    mensajes);
            garant(garant.LAST).cobliga := NVL(solgar.cobliga, 1);
            vpasexec := 3;
            garant(garant.LAST).ctipgar := pac_iaxpar_productos.f_get_tipgar(solgar.cgarant,
                                                                             sproduc,
                                                                             mensajes);
            garant(garant.LAST).p_set_needtarificar(0);
            garant(garant.LAST).p_calc_primas(vsolicit, vnmovimi, vpmode, pnriesgo);
            garant(garant.LAST).ctipo :=
               pac_iaxpar_productos.f_get_pargarantia('TIPO', sproduc, solgar.cgarant,
                                                      v_cactivi);
            -- BUG 0036730 - FAL - 09/12/2015
            garant(garant.LAST).cdetalle :=
                       pac_mdpar_productos.f_get_detallegar(sproduc, solgar.cgarant, mensajes);
            garant(garant.LAST).desglose := f_lee_desglosegarantias(vsolicit, pnriesgo,
                                                                    solgar.cgarant, NULL,
                                                                    mensajes);
            -- Bug 21121 - APD - 01/03/2012 - se obtiene el detalle de primas de la garantia
            garant(garant.LAST).detprimas :=
               pac_md_obtenerdatos.f_lee_detprimas(vsolicit, pnriesgo, solgar.cgarant,
                                                   garant(garant.LAST).nmovimi,
                                                   garant(garant.LAST).finiefe, mensajes);
            -- fin Bug 21121 - APD - 01/03/2012
            garant(garant.LAST).cderreg := solgar.cderreg;
            -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
            garant(garant.LAST).finivig := solgar.finivig;   --BUG 41143/229973 - 07/03/2016 - JAEG
            garant(garant.LAST).ffinvig := solgar.ffinvig;   --BUG 41143/229973 - 07/03/2016 - JAEG
            garant(garant.LAST).ccobprima := solgar.ccobprima;   --BUG 41143/229973 - 07/03/2016 - JAEG
            garant(garant.LAST).ipridev := solgar.ipridev;   --BUG 41143/229973 - 07/03/2016 - JAEG

            BEGIN
               SELECT cmoncap
                 INTO garant(garant.LAST).cmoncap
                 FROM garanpro
                WHERE cgarant = solgar.cgarant
                  AND sproduc = v_sproduc
                  AND cactivi = v_cactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT cmoncap
                    INTO garant(garant.LAST).cmoncap
                    FROM garanpro
                   WHERE cgarant = solgar.cgarant
                     AND sproduc = v_sproduc
                     AND cactivi = 0;
            END;

            IF garant(garant.LAST).cmoncap IS NOT NULL THEN
               garant(garant.LAST).tmoncap :=
                  pac_md_listvalores.f_get_tmoneda(garant(garant.LAST).cmoncap,
                                                   garant(garant.LAST).cmoncapint, mensajes);
            END IF;

            IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1
               AND NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
               garant(garant.LAST).reglasseg :=
                  pac_md_obtenerdatos.f_leereglasseg(vsolicit, pnriesgo, polgar.cgarant,
                                                     polgar.nmovimi, mensajes);
            END IF;

            -- Bug 10101 - 22/05/2009 - RSC - Detalle de garantias
            /*
            garant(garant.LAST).masdatos :=  OB_IAX_MASDATOSGAR();
            garant(garant.LAST).masdatos.ndetgar := solgar.NDETGAR;
            garant(garant.LAST).masdatos.fefecto := solgar.FEFECTO;
            garant(garant.LAST).masdatos.fvencim := solgar.FVENCIM;
            garant(garant.LAST).masdatos.ndurcob := solgar.NDURCOB;
            garant(garant.LAST).masdatos.ffincob := solgar.FFINCOB;
            garant(garant.LAST).masdatos.pinttec := solgar.PINTTEC;
            garant(garant.LAST).masdatos.pintmin := solgar.PINTMIN;
            garant(garant.LAST).masdatos.fprovt0 := solgar.FPROVT0;
            garant(garant.LAST).masdatos.iprovt0 := solgar.IPROVT0;
            garant(garant.LAST).masdatos.fprovt1 := solgar.FPROVT1;
            garant(garant.LAST).masdatos.iprovt1 := solgar.IPROVT1;
            */
            -- Fin Bug 10101
            -- Bug 26662 - APD - 17/04/2013
            garant(garant.LAST).cplanbenef :=
               pac_planbenef.f_get_planbenef(vpmode, vsolicit, pnriesgo,
                                             garant(garant.LAST).nmovimi);
         -- fin Bug 26662 - APD - 17/04/2013
         END LOOP;
      ELSIF vpmode = 'EST' THEN
         LOOP
            FETCH cur
             INTO estgar;

            EXIT WHEN cur%NOTFOUND;
            garant.EXTEND;
            garant(garant.LAST) := ob_iax_garantias();
            garant(garant.LAST).cgarant := estgar.cgarant;
            garant(garant.LAST).icapital := estgar.icapital;
            --garant(garant.last).iprianu  := ESTGAR.iprianu;
            garant(garant.LAST).crevali := estgar.crevali;
            garant(garant.LAST).prevali := estgar.prevali;
            garant(garant.LAST).irevali := estgar.irevali;
            --garant(garant.last).precarg  := ESTGAR.precarg;
            garant(garant.LAST).cfranq := estgar.cfranq;
            garant(garant.LAST).ctarman := NVL(estgar.ctarman, 0);
            --garant(garant.last).irecarg  := ESTGAR.irecarg;
            garant(garant.LAST).ifranqu := estgar.ifranqu;
            garant(garant.LAST).nmovimi := estgar.nmovimi;
            garant(garant.LAST).nmovima := estgar.nmovima;
            garant(garant.LAST).norden := estgar.norden;
            garant(garant.LAST).cderreg := estgar.cderreg;
            -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
            garant(garant.LAST).finiefe := estgar.finiefe;
            garant(garant.LAST).excaprecomend :=
               NVL(pac_parametros.f_pargaranpro_n(sproduc, v_cactivi, estgar.cgarant,
                                                  'CAPRECOMEND'),
                   0);
            garant(garant.LAST).cpartida :=
               NVL(pac_parametros.f_pargaranpro_n(sproduc, v_cactivi, estgar.cgarant,
                                                  'PARTIDA'),
                   0);
            garant(garant.LAST).icaprecomend := estgar.icaprecomend;
            vpasexec := 4;
            garant(garant.LAST).p_set_needtarificar(0);
            garant(garant.LAST).p_calc_primas(vsolicit, vnmovimi, vpmode, pnriesgo);
            --                PRI:=garant(garant.last).F_Get_Primas(vsolicit,vnmovimi,
            --                                                      vpmode,pnriesgo);
            --                garant(garant.last).PRIMAS:=PRI;
            vpasexec := 5;
            garant(garant.LAST).preguntas := f_leepreguntasgarantia(pnriesgo, estgar.cgarant,
                                                                    mensajes);
            garant(garant.LAST).cobliga := NVL(estgar.cobliga, 1);
            vpasexec := 6;
            garant(garant.LAST).ctipgar := pac_iaxpar_productos.f_get_tipgar(estgar.cgarant,
                                                                             sproduc,
                                                                             mensajes);
            garant(garant.LAST).ctipo :=
               pac_iaxpar_productos.f_get_pargarantia('TIPO', sproduc, estgar.cgarant,
                                                      v_cactivi);
            -- BUG 0036730 - FAL - 09/12/2015
            --MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
            garant(garant.LAST).icaptot := estgar.icaptot;
            --FIN MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
            garant(garant.LAST).cdetalle :=
                       pac_mdpar_productos.f_get_detallegar(sproduc, estgar.cgarant, mensajes);
            garant(garant.LAST).desglose := f_lee_desglosegarantias(vsolicit, pnriesgo,
                                                                    estgar.cgarant, NULL,
                                                                    mensajes);
            -- Bug 21121 - APD - 01/03/2012 - se obtiene el detalle de primas de la garantia
            garant(garant.LAST).detprimas :=
               pac_md_obtenerdatos.f_lee_detprimas(vsolicit, pnriesgo, estgar.cgarant,
                                                   garant(garant.LAST).nmovimi,
                                                   garant(garant.LAST).finiefe, mensajes);

            -- fin Bug 21121 - APD - 01/03/2012
            IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1
               AND NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
               garant(garant.LAST).reglasseg :=
                  pac_md_obtenerdatos.f_leereglasseg(vsolicit, pnriesgo, estgar.cgarant,
                                                     estgar.nmovimi, mensajes);
            END IF;

            BEGIN
               SELECT cmoncap
                 INTO garant(garant.LAST).cmoncap
                 FROM garanpro
                WHERE cgarant = estgar.cgarant
                  AND sproduc = v_sproduc
                  AND cactivi = v_cactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT cmoncap
                    INTO garant(garant.LAST).cmoncap
                    FROM garanpro
                   WHERE cgarant = estgar.cgarant
                     AND sproduc = v_sproduc
                     AND cactivi = 0;
            END;

            IF garant(garant.LAST).cmoncap IS NOT NULL THEN
               garant(garant.LAST).tmoncap :=
                  pac_md_listvalores.f_get_tmoneda(garant(garant.LAST).cmoncap,
                                                   garant(garant.LAST).cmoncapint, mensajes);
            END IF;

            -- Bug 10101 - 22/05/2009 - RSC - Detalle de garantias
            /*
            garant(garant.LAST).masdatos :=  OB_IAX_MASDATOSGAR();
            garant(garant.LAST).masdatos.ndetgar := estgar.NDETGAR;
            garant(garant.LAST).masdatos.fefecto := estgar.FEFECTO;
            garant(garant.LAST).masdatos.fvencim := estgar.FVENCIM;
            garant(garant.LAST).masdatos.ndurcob := estgar.NDURCOB;
            garant(garant.LAST).masdatos.ffincob := estgar.FFINCOB;
            garant(garant.LAST).masdatos.pinttec := estgar.PINTTEC;
            garant(garant.LAST).masdatos.pintmin := estgar.PINTMIN;
            garant(garant.LAST).masdatos.fprovt0 := estgar.FPROVT0;
            garant(garant.LAST).masdatos.iprovt0 := estgar.IPROVT0;
            garant(garant.LAST).masdatos.fprovt1 := estgar.FPROVT1;
            garant(garant.LAST).masdatos.iprovt1 := estgar.IPROVT1;
            */
            -- Fin Bug 10101
            -- Bug 18848 - APD - 08/09/2011 - se inicializa el objeto ob_iax_masdatosgar
            -- para poder recuperar el valor de FTARIFA
            garant(garant.LAST).masdatos := ob_iax_masdatosgar();
            garant(garant.LAST).masdatos.ftarifa := estgar.ftarifa;
            -- Fin Bug 18848 - APD - 08/09/2011
            -- Bug 26662 - APD - 17/04/2013
            garant(garant.LAST).cplanbenef :=
               pac_planbenef.f_get_planbenef(vpmode, vsolicit, pnriesgo,
                                             garant(garant.LAST).nmovimi);
            -- fin Bug 26662 - APD - 17/04/2013
            garant(garant.LAST).nfactor := estgar.nfactor;
            -- Bug 30171/173304 - 13/05/2014 - AMC
            garant(garant.LAST).finivig := estgar.finivig;   --BUG 41143/229973 - 07/03/2016 - JAEG
            garant(garant.LAST).ffinvig := estgar.ffinvig;   --BUG 41143/229973 - 07/03/2016 - JAEG
            garant(garant.LAST).ccobprima := estgar.ccobprima;   --BUG 41143/229973 - 07/03/2016 - JAEG
            garant(garant.LAST).ipridev := estgar.ipridev;   --BUG 41143/229973 - 07/03/2016 - JAEG
         END LOOP;
      ELSE
         LOOP
            -- Bug 10101 - 22/05/2009 - RSC - Detalle de garantias
            IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2)
               AND NVL(f_parproductos_v(v_sproduc, 'TIPO_PB'), 0) <> 1 THEN
               FETCH cur
                INTO v_cgarant, v_nmovimi, v_finiefe, v_norden, v_ifranqu, v_icaptot,
                     v_nmovima, v_cfranq, v_ndetgar, v_fefecto, v_fvencim, v_ndurcob,
                     v_ctarifa, v_pinttec, v_ftarifa, v_crevali, v_prevali, v_irevali,
                     v_icapital, v_iprianu, v_precarg, v_irecarg, v_cparben, v_cprepost,
                     v_ffincob, v_ipritar, v_provmat0, v_fprovmat0, v_provmat1, v_fprovmat1,
                     v_pintmin, v_pdtocom, v_idtocom, v_ctarman, v_ipripur, v_ipriinv,
                     v_itarrea, v_cderreg, v_nfactor;

               -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
               -- Fin Bug 10101
               EXIT WHEN cur%NOTFOUND;
               garant.EXTEND;
               garant(garant.LAST) := ob_iax_garantias();
               garant(garant.LAST).cgarant := v_cgarant;
               garant(garant.LAST).icapital := v_icapital;
               garant(garant.LAST).crevali := v_crevali;
               garant(garant.LAST).prevali := v_prevali;
               garant(garant.LAST).irevali := v_irevali;
               garant(garant.LAST).cfranq := v_cfranq;
               garant(garant.LAST).ifranqu := v_ifranqu;
               garant(garant.LAST).nmovimi := v_nmovimi;
               garant(garant.LAST).ctarman := NVL(v_ctarman, 0);
               garant(garant.LAST).nmovima := v_nmovima;
               garant(garant.LAST).norden := v_norden;
               garant(garant.LAST).finiefe := v_finiefe;
               garant(garant.LAST).cderreg := v_cderreg;
               -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
               vpasexec := 7;
               garant(garant.LAST).p_set_needtarificar(0);
               garant(garant.LAST).p_calc_primas(vsolicit, vnmovimi, vpmode, pnriesgo);
               vpasexec := 8;
               garant(garant.LAST).preguntas := f_leepreguntasgarantia(pnriesgo, v_cgarant,
                                                                       mensajes);
               garant(garant.LAST).cobliga := 1;
               vpasexec := 901;
               garant(garant.LAST).ctipgar := pac_iaxpar_productos.f_get_tipgar(v_cgarant,
                                                                                sproduc,
                                                                                mensajes);
               vpasexec := 902;
               garant(garant.LAST).ctipo := pac_iaxpar_productos.f_get_pargarantia('TIPO',
                                                                                   sproduc,
                                                                                   v_cgarant,
                                                                                   v_cactivi);
               -- BUG 0036484 - FAL -9/11/2015
               vpasexec := 903;
               garant(garant.LAST).cdetalle :=
                            pac_mdpar_productos.f_get_detallegar(sproduc, v_cgarant, mensajes);
               vpasexec := 904;
               garant(garant.LAST).desglose := f_lee_desglosegarantias(vsolicit, pnriesgo,
                                                                       v_cgarant, NULL,
                                                                       mensajes);
               -- Bug 21121 - APD - 01/03/2012 - se obtiene el detalle de primas de la garantia
               garant(garant.LAST).detprimas :=
                  pac_md_obtenerdatos.f_lee_detprimas(vsolicit, pnriesgo, v_cgarant,
                                                      garant(garant.LAST).nmovimi,
                                                      garant(garant.LAST).finiefe, mensajes);
               -- fin Bug 21121 - APD - 01/03/2012
               --MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
               garant(garant.LAST).icaptot := v_icaptot;
               vpasexec := 905;

               BEGIN
                  SELECT cmoncap
                    INTO garant(garant.LAST).cmoncap
                    FROM garanpro
                   WHERE cgarant = v_cgarant
                     AND sproduc = v_sproduc
                     AND cactivi = v_cactivi;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT cmoncap
                       INTO garant(garant.LAST).cmoncap
                       FROM garanpro
                      WHERE cgarant = v_cgarant
                        AND sproduc = v_sproduc
                        AND cactivi = 0;
               END;

               vpasexec := 906;

               IF garant(garant.LAST).cmoncap IS NOT NULL THEN
                  garant(garant.LAST).tmoncap :=
                     pac_md_listvalores.f_get_tmoneda(garant(garant.LAST).cmoncap,
                                                      garant(garant.LAST).cmoncapint,
                                                      mensajes);
               END IF;

               vpasexec := 907;

               --FIN MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
               IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1
                  AND NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
                  garant(garant.LAST).reglasseg :=
                     pac_md_obtenerdatos.f_leereglasseg(vsolicit, pnriesgo, v_cgarant,
                                                        v_nmovimi, mensajes);
               END IF;

               vpasexec := 908;
               -- Bug 10101 - 22/05/2009 - RSC - Detalle de garantias
               v_garmas := ob_iax_masdatosgar();
               v_garmas.ndetgar := v_ndetgar;
               v_garmas.fefecto := v_fefecto;
               v_garmas.fvencim := v_fvencim;
               v_garmas.ndurcob := v_ndurcob;
               v_garmas.ffincob := v_ffincob;
               v_garmas.pinttec := v_pinttec;
               v_garmas.pintmin := v_pintmin;
               v_garmas.fprovt0 := v_fprovmat0;
               v_garmas.iprovt0 := v_provmat0;
               v_garmas.fprovt1 := v_fprovmat1;
               v_garmas.iprovt1 := v_provmat1;
               v_garmas2 := pac_md_obtenerdatos.f_leedatosgarantias(pnriesgo, v_cgarant,
                                                                    v_ndetgar, mensajes);
               vpasexec := 909;
               v_garmas.estado := v_garmas2.estado;
               v_garmas.testado := v_garmas2.testado;
               v_garmas.ctarifa := v_ctarifa;
               v_garmas.ftarifa := v_ftarifa;
               -- Bug 10101 - RSC - 16/07/2009 - 0010101: APR - Detalle de garantias (Consulta de Polizas)
               v_garmas.cunica := v_garmas2.cunica;
               v_garmas.cagente := v_garmas2.cagente;
               -- Bug 10690 - RSC - 16/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
               v_garmas.provmat := v_garmas2.provmat;
               v_garmas.ireducc := v_garmas2.ireducc;
               -- Fin Bug 10690
               garant(garant.LAST).masdatos := v_garmas;
               -- Fin Bug 10101
               -- Bug 26662 - APD - 17/04/2013
               garant(garant.LAST).cplanbenef :=
                  pac_planbenef.f_get_planbenef(vpmode, vsolicit, pnriesgo,
                                                garant(garant.LAST).nmovimi);
               -- fin Bug 26662 - APD - 17/04/2013
               garant(garant.LAST).nfactor := v_nfactor;
            -- Bug 30171/173304 - 13/05/2014 - AMC
            ELSE
               FETCH cur
                INTO polgar;

               EXIT WHEN cur%NOTFOUND;
               garant.EXTEND;
               garant(garant.LAST) := ob_iax_garantias();
               garant(garant.LAST).cgarant := polgar.cgarant;
               garant(garant.LAST).icapital := polgar.icapital;
               garant(garant.LAST).crevali := polgar.crevali;
               garant(garant.LAST).prevali := polgar.prevali;
               garant(garant.LAST).irevali := polgar.irevali;
               garant(garant.LAST).cfranq := polgar.cfranq;
               garant(garant.LAST).ifranqu := polgar.ifranqu;
               garant(garant.LAST).ctarman := NVL(polgar.ctarman, 0);
               garant(garant.LAST).nmovimi := polgar.nmovimi;
               garant(garant.LAST).nmovima := polgar.nmovima;
               garant(garant.LAST).norden := polgar.norden;
               garant(garant.LAST).finiefe := polgar.finiefe;
               garant(garant.LAST).excaprecomend :=
                  NVL(pac_parametros.f_pargaranpro_n(sproduc, v_cactivi, polgar.cgarant,
                                                     'CAPRECOMEND'),
                      0);
               garant(garant.LAST).cpartida :=
                  NVL(pac_parametros.f_pargaranpro_n(sproduc, v_cactivi, polgar.cgarant,
                                                     'PARTIDA'),
                      0);

               BEGIN
                  SELECT gg.cvisniv, gg.cgarpadre
                    INTO garant(garant.LAST).cvisniv, garant(garant.LAST).cgarpadre
                    FROM garanpro gg
                   WHERE gg.cgarant = polgar.cgarant
                     AND gg.cactivi = v_cactivi
                     AND gg.sproduc = v_sproduc;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT gg.cvisniv, gg.cgarpadre
                       INTO garant(garant.LAST).cvisniv, garant(garant.LAST).cgarpadre
                       FROM garanpro gg
                      WHERE gg.cgarant = polgar.cgarant
                        AND gg.cactivi = 0
                        AND gg.sproduc = v_sproduc;
               END;

               BEGIN
                  SELECT DECODE(gg.cgarant, gg.g01, 1, gg.g02, 2, gg.g03, 3, NULL)
                    INTO garant(garant.LAST).cnivgar
                    FROM garanprored gg
                   WHERE gg.sproduc = v_sproduc
                     AND gg.cactivi = v_cactivi
                     AND gg.cgarant = polgar.cgarant
                     AND gg.fmovfin IS NULL;
               EXCEPTION
                  WHEN OTHERS THEN
                     garant(garant.LAST).cnivgar := NULL;
               END;

               vpasexec :=
                  pac_cfg.f_get_user_accion_permitida(f_user, 'NIVEL_VISIONGAR', sproduc,
                                                      pac_md_common.f_get_cxtempresa(),
                                                      v_crealiza);

               -- la garantia sera visible o no en funcion de cfg_accion.crealiza y garanpro.cvisniv
               -- Se definen tres niveles de visi?n:
               -- Los usuarios que tengan el nivel 1 solo podr?n ver las garant?as del nivel 1.
               -- Los usuarios que tengan el nivel 2 podr?n ver las garant?as de nivel 1 y 2.
               -- Los usuarios que tengan el nivel 3 podr?n ver las garant?a de nivel 1, 2 y 3.
               -- si no hay configuracion en cfg_accion para la accion 'NIVEL_VISIONGAR' se entiende
               -- que la garantia es visible (se pone por defecto 3 que es el que permite ver todos
               -- los niveles de garantias)
               -- si s? que hay parametrizacion en cfg_accion si el nivel de vision de la garantia es
               -- mayor al nivel de vision permitido para el usuario, no se permite ver la garantia
               IF NVL(garant(garant.LAST).cvisniv, 1) > NVL(v_crealiza, 3) THEN
                  garant(garant.LAST).cvisible := 0;   -- garantia no visible
               ELSE
                  garant(garant.LAST).cvisible := 1;   -- garantia visible
               END IF;

               -- fin Bug 22049 - APD - 30/04/2012
               garant(garant.LAST).icaprecomend := polgar.icaprecomend;
               garant(garant.LAST).cderreg := polgar.cderreg;
               -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
               vpasexec := 7;
               garant(garant.LAST).p_set_needtarificar(0);
               garant(garant.LAST).p_calc_primas(vsolicit, vnmovimi, vpmode, pnriesgo);
               vpasexec := 8;
               garant(garant.LAST).preguntas := f_leepreguntasgarantia(pnriesgo,
                                                                       polgar.cgarant,
                                                                       mensajes);
               garant(garant.LAST).cobliga := 1;
               vpasexec := 911;
               garant(garant.LAST).ctipgar :=
                           pac_iaxpar_productos.f_get_tipgar(polgar.cgarant, sproduc, mensajes);
               vpasexec := 912;
               garant(garant.LAST).cdetalle :=
                        pac_mdpar_productos.f_get_detallegar(sproduc, polgar.cgarant, mensajes);
               vpasexec := 913;
               garant(garant.LAST).desglose := f_lee_desglosegarantias(vsolicit, pnriesgo,
                                                                       polgar.cgarant, NULL,
                                                                       mensajes);
               -- Bug 21121 - APD - 01/03/2012 - se obtiene el detalle de primas de la garantia
               garant(garant.LAST).detprimas :=
                  pac_md_obtenerdatos.f_lee_detprimas(vsolicit, pnriesgo, polgar.cgarant,
                                                      garant(garant.LAST).nmovimi,
                                                      garant(garant.LAST).finiefe, mensajes);
               -- fin Bug 21121 - APD - 01/03/2012
               vpasexec := 914;
               garant(garant.LAST).ctipo :=
                  pac_iaxpar_productos.f_get_pargarantia('TIPO', sproduc, polgar.cgarant,
                                                         v_cactivi);
               -- BUG 0036730 - FAL - 09/12/2015
               --MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
               garant(garant.LAST).icaptot := polgar.icaptot;
               vpasexec := 915;

               BEGIN
                  SELECT cmoncap
                    INTO garant(garant.LAST).cmoncap
                    FROM garanpro
                   WHERE cgarant = polgar.cgarant
                     AND sproduc = v_sproduc
                     AND cactivi = v_cactivi;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT cmoncap
                       INTO garant(garant.LAST).cmoncap
                       FROM garanpro
                      WHERE cgarant = polgar.cgarant
                        AND sproduc = v_sproduc
                        AND cactivi = 0;
               END;

               vpasexec := 916;

               IF garant(garant.LAST).cmoncap IS NOT NULL THEN
                  garant(garant.LAST).tmoncap :=
                     pac_md_listvalores.f_get_tmoneda(garant(garant.LAST).cmoncap,
                                                      garant(garant.LAST).cmoncapint,
                                                      mensajes);
               END IF;

               vpasexec := 917;

               --FIN MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
               IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1
                  AND NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
                  garant(garant.LAST).reglasseg :=
                     pac_md_obtenerdatos.f_leereglasseg(vsolicit, pnriesgo, polgar.cgarant,
                                                        polgar.nmovimi, mensajes);
               END IF;

               vpasexec := 918;

               -- Bug 29943 - 05/06/2014 - JTT - Detalle de garantias
               IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2)
                  AND NVL(f_parproductos_v(v_sproduc, 'TIPO_PB'), 0) = 1 THEN
                  garant(garant.LAST).masdatos :=
                     pac_md_obtenerdatos.f_leedatosgarantias(pnriesgo, polgar.cgarant, 0,
                                                             mensajes);
               END IF;

               -- Fin Bug 29943
               -- Bug 26662 - APD - 17/04/2013
               garant(garant.LAST).cplanbenef :=
                  pac_planbenef.f_get_planbenef(vpmode, vsolicit, pnriesgo,
                                                garant(garant.LAST).nmovimi);
               -- fin Bug 26662 - APD - 17/04/2013
               garant(garant.LAST).nfactor := polgar.nfactor;
               -- Bug 30171/173304 - 13/05/2014 - AMC
               garant(garant.LAST).finivig := polgar.finivig;   --BUG 41143/229973 - 07/03/2016 - JAEG
               garant(garant.LAST).ffinvig := polgar.ffinvig;   --BUG 41143/229973 - 07/03/2016 - JAEG
               garant(garant.LAST).ccobprima := polgar.ccobprima;   --BUG 41143/229973 - 07/03/2016 - JAEG
               garant(garant.LAST).ipridev := polgar.ipridev;   --BUG 41143/229973 - 07/03/2016 - JAEG
            END IF;
         END LOOP;
      END IF;

      CLOSE cur;

      RETURN garant;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leegarantias;

/*
FUNCTION f_leegarantias(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
RETURN t_iax_garantias IS
cur            sys_refcursor;
solgar         solgaranseg%ROWTYPE;
estgar         estgaranseg%ROWTYPE;
polgar         garanseg%ROWTYPE;
garant         t_iax_garantias := t_iax_garantias();
squery         VARCHAR2(1000);
vtab           VARCHAR2(20);
vfield         VARCHAR2(20);
vfields        VARCHAR2(100);
pri            ob_iax_primas;
sproduc        NUMBER;
vtab2          VARCHAR2(20);
vcond          VARCHAR2(300);
vpasexec       NUMBER(8) := 1;
vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeGarantias';
BEGIN
IF vpmode = 'SOL' THEN
vfield := 'ssolicit';
vtab := 'SOLGARANSEG';
vtab2 := 'solseguros';
vfields := '*';
--vfields:='cgarant,icapital,iprianu,crevali,prevali,irevali,precarg,cfranq,irecarg,ifranqu';
ELSIF vpmode = 'EST' THEN
vfield := 'SSEGURO';
vtab := 'ESTGARANSEG';
vtab2 := 'estseguros';
vfields := '*';
--vfields:='cgarant,icapital,iprianu,crevali,prevali,irevali,precarg,cfranq,irecarg,ifranqu,nmovimi';
vcond := 'AND ffinefe IS NULL  order by NORDEN asc';   --' and NMOVIMI='|| vnmovimi;
ELSE
vfield := 'SSEGURO';
vtab := 'GARANSEG';
vtab2 := 'seguros';
vfields := '*';
--vfields:='cgarant,icapital,iprianu,crevali,prevali,irevali,precarg,cfranq,irecarg,ifranqu,nmovimi';
vcond := 'AND NMOVIMI = (SELECT MAX (b.nmovimi) ' || ' FROM GARANSEG b '
|| ' WHERE  b.sseguro = ' || vsolicit || ' AND b.nriesgo = ' || pnriesgo
|| ') order by norden asc ';
END IF;
squery := 'SELECT ' || vfields || ' FROM ' || vtab || ' where ' || vfield || '='
|| vsolicit || ' and ' || '       nriesgo=' || pnriesgo || vcond;
cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
BEGIN
sproduc :=
TO_NUMBER(pac_iax_listvalores.f_getdescripvalor('select sproduc from ' || vtab2
|| ' where ' || vfield || '='
|| vsolicit,
mensajes));
EXCEPTION
WHEN OTHERS THEN
sproduc := NULL;
END;
IF vpmode = 'SOL' THEN
LOOP
FETCH cur
INTO solgar;
EXIT WHEN cur%NOTFOUND;
garant.EXTEND;
garant(garant.LAST) := ob_iax_garantias();
garant(garant.LAST).cgarant := solgar.cgarant;
garant(garant.LAST).icapital := solgar.icapital;
--garant(garant.last).iprianu  := SOLGAR.iprianu;
garant(garant.LAST).crevali := solgar.crevali;
garant(garant.LAST).prevali := solgar.prevali;
garant(garant.LAST).irevali := solgar.irevali;
--garant(garant.last).precarg  := SOLGAR.precarg;
garant(garant.LAST).cfranq := solgar.cfranq;
--garant(garant.last).irecarg  := SOLGAR.irecarg;
garant(garant.LAST).ifranqu := solgar.ifranqu;
garant(garant.LAST).finiefe := solgar.finiefe;
garant(garant.LAST).nmovimi := 1;
garant(garant.LAST).norden := solgar.norden;
vpasexec := 2;
garant(garant.LAST).preguntas := f_leepreguntasgarantia(pnriesgo, solgar.cgarant,
mensajes);
garant(garant.LAST).cobliga := NVL(solgar.cobliga, 1);
vpasexec := 3;
garant(garant.LAST).ctipgar := pac_iaxpar_productos.f_get_tipgar(solgar.cgarant,
sproduc,
mensajes);
garant(garant.LAST).p_set_needtarificar(0);
garant(garant.LAST).p_calc_primas(vsolicit, vnmovimi, vpmode, pnriesgo);
garant(garant.LAST).ctipo :=
pac_iaxpar_productos.f_get_pargarantia('TIPO', sproduc, solgar.cgarant);
END LOOP;
ELSIF vpmode = 'EST' THEN
LOOP
FETCH cur
INTO estgar;
EXIT WHEN cur%NOTFOUND;
garant.EXTEND;
garant(garant.LAST) := ob_iax_garantias();
garant(garant.LAST).cgarant := estgar.cgarant;
garant(garant.LAST).icapital := estgar.icapital;
--garant(garant.last).iprianu  := ESTGAR.iprianu;
garant(garant.LAST).crevali := estgar.crevali;
garant(garant.LAST).prevali := estgar.prevali;
garant(garant.LAST).irevali := estgar.irevali;
--garant(garant.last).precarg  := ESTGAR.precarg;
garant(garant.LAST).cfranq := estgar.cfranq;
--garant(garant.last).irecarg  := ESTGAR.irecarg;
garant(garant.LAST).ifranqu := estgar.ifranqu;
garant(garant.LAST).nmovimi := estgar.nmovimi;
garant(garant.LAST).nmovima := estgar.nmovima;
garant(garant.LAST).norden := estgar.norden;
garant(garant.LAST).finiefe := estgar.finiefe;
vpasexec := 4;
garant(garant.LAST).p_set_needtarificar(0);
garant(garant.LAST).p_calc_primas(vsolicit, vnmovimi, vpmode, pnriesgo);
--                PRI:=garant(garant.last).F_Get_Primas(vsolicit,vnmovimi,
--                                                      vpmode,pnriesgo);
--                garant(garant.last).PRIMAS:=PRI;
vpasexec := 5;
garant(garant.LAST).preguntas := f_leepreguntasgarantia(pnriesgo, estgar.cgarant,
mensajes);
garant(garant.LAST).cobliga := NVL(estgar.cobliga, 1);
vpasexec := 6;
garant(garant.LAST).ctipgar := pac_iaxpar_productos.f_get_tipgar(estgar.cgarant,
sproduc,
mensajes);
garant(garant.LAST).ctipo :=
pac_iaxpar_productos.f_get_pargarantia('TIPO', sproduc, estgar.cgarant);
--MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
garant(garant.LAST).icaptot := estgar.icaptot;
--FIN MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
END LOOP;
ELSE
LOOP
FETCH cur
INTO polgar;
EXIT WHEN cur%NOTFOUND;
garant.EXTEND;
garant(garant.LAST) := ob_iax_garantias();
garant(garant.LAST).cgarant := polgar.cgarant;
garant(garant.LAST).icapital := polgar.icapital;
--garant(garant.last).iprianu  := POLGAR.iprianu;
garant(garant.LAST).crevali := polgar.crevali;
garant(garant.LAST).prevali := polgar.prevali;
garant(garant.LAST).irevali := polgar.irevali;
--garant(garant.last).precarg  := POLGAR.precarg;
garant(garant.LAST).cfranq := polgar.cfranq;
--garant(garant.last).irecarg  := POLGAR.irecarg;
garant(garant.LAST).ifranqu := polgar.ifranqu;
garant(garant.LAST).nmovimi := polgar.nmovimi;
garant(garant.LAST).nmovima := polgar.nmovima;
garant(garant.LAST).norden := polgar.norden;
garant(garant.LAST).finiefe := polgar.finiefe;
vpasexec := 7;
garant(garant.LAST).p_set_needtarificar(0);
garant(garant.LAST).p_calc_primas(vsolicit, vnmovimi, vpmode, pnriesgo);
--                PRI:=garant(garant.last).F_Get_Primas(vsolicit,vnmovimi,
--                                                      vpmode,pnriesgo);
--                garant(garant.last).PRIMAS:=PRI;
vpasexec := 8;
garant(garant.LAST).preguntas := f_leepreguntasgarantia(pnriesgo, polgar.cgarant,
mensajes);
garant(garant.LAST).cobliga := 1;
vpasexec := 9;
garant(garant.LAST).ctipgar := pac_iaxpar_productos.f_get_tipgar(polgar.cgarant,
sproduc,
mensajes);
garant(garant.LAST).ctipo :=
pac_iaxpar_productos.f_get_pargarantia('TIPO', sproduc, polgar.cgarant);
--MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
garant(garant.LAST).icaptot := polgar.icaptot;
--FIN MCC -15/04/2009- 0009753: Es detectan suplements que deixen el camp ICAPTOT de garanseg a null
END LOOP;
END IF;
CLOSE cur;
RETURN garant;
EXCEPTION
WHEN e_param_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
IF cur%ISOPEN THEN
CLOSE cur;
END IF;
RETURN NULL;
WHEN e_object_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
IF cur%ISOPEN THEN
CLOSE cur;
END IF;
RETURN NULL;
WHEN OTHERS THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
psqcode => SQLCODE, psqerrm => SQLERRM);
IF cur%ISOPEN THEN
CLOSE cur;
END IF;
RETURN NULL;
END f_leegarantias;
*/
/*************************************************************************
Recuperar informacion de las de garantias -->>
*************************************************************************/
/*************************************************************************
Recuperar la informaicon de las preguntas de garantias
param in pnriesgo  : n¿mero de riesgo
param in pcgarant  : codigo de garantia
param out mensajes : mesajes de error
return             : objeto preguntas
*************************************************************************/
   FUNCTION f_leepreguntasgarantia(
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas IS
      preg           t_iax_preguntas := t_iax_preguntas();
      pregtab        t_iax_preguntastab := t_iax_preguntastab();
      pregtab_col    t_iax_preguntastab_columns := t_iax_preguntastab_columns();
      vtab           VARCHAR2(100);
      vtab2          VARCHAR2(100);
      squery         VARCHAR2(2000);
      cur            sys_refcursor;
      cprg           pregungaranseg%ROWTYPE;
      curid          INTEGER;
      dummy          INTEGER;
      cpregun        NUMBER;
      crespue        FLOAT;
      trespue        VARCHAR2(2000);
      pmovimi        NUMBER;
      pmovima        NUMBER;
      pfiniefe       DATE;
      --vcactivi NUMBER:= PAC_IAX_PRODUCCION.F_GET_ACTIVIDAD(mensajes);
      vmov           VARCHAR2(500);
      vmov2          VARCHAR2(500);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pnriesgo=' || pnriesgo || ' pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeePreguntasGarantia';

      CURSOR c_lista(cprg NUMBER, colum VARCHAR2) IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      vconsulta      VARCHAR2(4000);
      catribu        NUMBER;
      tatribu        VARCHAR2(1000);
      vsproduc       NUMBER;
      vnpoliza       NUMBER;
      curid3         INTEGER;
      vtab3          VARCHAR2(50);
      squery3        VARCHAR2(2000);
      curid2         INTEGER;
      squery2        VARCHAR2(2000);
      ccolumna       VARCHAR2(50);
      nlinea         NUMBER;
      tvalor         VARCHAR2(250);
      fvalor         DATE;
      nvalor         NUMBER;
      vmovimi        NUMBER;
      vcactivi       NUMBER;   -- 23915:ASN:10/10/2012
      vcagente       NUMBER;
   BEGIN
      IF vpmode = 'EST' THEN
         vtab := 'ESTPREGUNGARANSEG ';
         vtab2 := ',PREGUNPROGARAN PR, ESTSEGUROS S';
         vtab3 := 'ESTPREGUNGARANSEGTAB S';
      ELSIF vpmode = 'POL' THEN
         vtab := 'PREGUNGARANSEG ';
         vtab2 := ',PREGUNPROGARAN PR, SEGUROS S';
         vtab3 := 'PREGUNGARANSEGTAB S';
      END IF;

      -- 23915:ASN:10/10/2012 ini
      /*
      SELECT sproduc
      INTO vsproduc
      FROM (SELECT sproduc
      FROM estseguros
      WHERE sseguro = vsolicit
      AND vpmode = 'EST'
      UNION ALL
      SELECT sproduc
      FROM seguros
      WHERE sseguro = vsolicit
      AND vpmode <> 'EST');
      */
      SELECT sproduc, cactivi, npoliza, cagente
        INTO vsproduc, vcactivi, vnpoliza, vcagente
        FROM (SELECT sproduc, cactivi, npoliza, cagente
                FROM estseguros
               WHERE sseguro = vsolicit
                 AND vpmode = 'EST'
              UNION ALL
              SELECT sproduc, cactivi, npoliza, cagente
                FROM seguros
               WHERE sseguro = vsolicit
                 AND NVL(vpmode, 'SEG') <> 'EST');

      -- 23915:ASN:10/10/2012 fin
      vmov := ' and nmovimi=(SELECT MAX (b.nmovimi) ' || ' FROM ' || vtab || ' b '
              || ' WHERE  b.sseguro = ' || vsolicit || ' AND    b.nriesgo = ' || pnriesgo
              || ')';
      vmov2 := ' and nmovimi=(SELECT MAX (nmovimi) ' || ' FROM ' || vtab3
               || ' WHERE  sseguro = ' || vsolicit || ' AND    nriesgo = ' || pnriesgo || ')';
      curid := DBMS_SQL.open_cursor;
      squery := 'SELECT P.CPREGUN, P.CRESPUE, P.TRESPUE, P.NMOVIMI, P.FINIEFE, P.NMOVIMA'
                || ' FROM ' || vtab || ' P ' || vtab2 || ' WHERE P.sseguro=' || vsolicit
                || ' and P.nriesgo=' || pnriesgo || ' and P.cgarant=' || pcgarant
                || ' AND P.CPREGUN = PR.CPREGUN AND S.SSEGURO = P.SSEGURO'
                || ' AND P.CGARANT = PR.CGARANT '
                --MCC -23/03/2009 - Bug 9493 Consulta de preguntas por garantias
                -- Bug 41390/231687 - 07/04/2016 - Se incorpora la actividad
                || ' AND S.SPRODUC = PR.SPRODUC and s.cactivi = pr.cactivi ' || vmov
                || ' ORDER BY PR.NPREORD,P.CPREGUN';
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);
      DBMS_SQL.define_column(curid, 2, crespue);
      DBMS_SQL.define_column(curid, 3, trespue, 2000);
      DBMS_SQL.define_column(curid, 4, pmovimi);
      DBMS_SQL.define_column(curid, 5, pfiniefe);
      DBMS_SQL.define_column(curid, 6, pmovima);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         DBMS_SQL.COLUMN_VALUE(curid, 2, crespue);
         DBMS_SQL.COLUMN_VALUE(curid, 3, trespue);
         DBMS_SQL.COLUMN_VALUE(curid, 4, pmovimi);
         DBMS_SQL.COLUMN_VALUE(curid, 5, pfiniefe);
         DBMS_SQL.COLUMN_VALUE(curid, 6, pmovima);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := crespue;
         preg(preg.LAST).trespue := trespue;
         preg(preg.LAST).nmovimi := pmovimi;
         preg(preg.LAST).finiefe := pfiniefe;
         preg(preg.LAST).nmovima := pmovima;
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      curid := DBMS_SQL.open_cursor;
      curid2 := DBMS_SQL.open_cursor;
      curid3 := DBMS_SQL.open_cursor;
      squery := 'SELECT distinct(cpregun)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                || vsolicit || ' AND S.NRIESGO=' || pnriesgo || ' and cgarant=' || pcgarant
                || vmov2;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := NULL;
         preg(preg.LAST).trespue := NULL;
         preg(preg.LAST).finiefe := pfiniefe;
         preg(preg.LAST).nmovima := pmovima;
         preg(preg.LAST).nmovimi := pmovimi;
         squery2 := 'SELECT distinct(NLINEA)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                    || vsolicit || ' AND S.NRIESGO=' || pnriesgo || ' AND S.CPREGUN = '
                    || cpregun || ' and cgarant=' || pcgarant || vmov2;
         DBMS_SQL.parse(curid2, squery2, DBMS_SQL.v7);
         dummy := DBMS_SQL.EXECUTE(curid2);
         DBMS_SQL.define_column(curid2, 1, nlinea);

         LOOP
            EXIT WHEN DBMS_SQL.fetch_rows(curid2) = 0;
            DBMS_SQL.COLUMN_VALUE(curid2, 1, nlinea);
            pregtab.EXTEND;
            pregtab(pregtab.LAST) := ob_iax_preguntastab();
            pregtab(pregtab.LAST).cpregun := cpregun;
            pregtab(pregtab.LAST).nlinea := nlinea;
            pregtab(pregtab.LAST).nmovimi := pmovimi;
            -- 23915:ASN:10/10/2012 ini
            --            pregtab_col := pac_iaxpar_productos.f_get_cabecera_preguntab('G', cpregun,
            --                                                                         pcgarant, mensajes);
            pregtab_col :=
               pac_mdpar_productos.f_get_cabecera_preguntab(vsproduc, vcactivi, 'G', cpregun,
                                                            pcgarant,
                                                            pac_iax_produccion.issimul,
                                                            pac_iax_produccion.issuplem,
                                                            mensajes);
            -- 23915:ASN:10/10/2012 fin
            squery3 := 'SELECT CCOLUMNA,TVALOR,FVALOR, NVALOR, FINIEFE, NMOVIMA , NMOVIMI'
                       || ' FROM ' || vtab3 || ' WHERE S.SSEGURO=' || vsolicit
                       || ' AND S.NRIESGO=' || pnriesgo || ' AND S.CPREGUN = ' || cpregun
                       || ' AND s.nlinea = ' || nlinea || ' and cgarant=' || pcgarant || vmov2;
            DBMS_SQL.parse(curid3, squery3, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid3);
            DBMS_SQL.define_column(curid3, 1, ccolumna, 50);
            DBMS_SQL.define_column(curid3, 2, tvalor, 250);
            DBMS_SQL.define_column(curid3, 3, fvalor);
            DBMS_SQL.define_column(curid3, 4, nvalor);
            DBMS_SQL.define_column(curid3, 5, pfiniefe);
            DBMS_SQL.define_column(curid3, 6, pmovima);
            DBMS_SQL.define_column(curid3, 7, vmovimi);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows(curid3) = 0;
               DBMS_SQL.COLUMN_VALUE(curid3, 1, ccolumna);
               DBMS_SQL.COLUMN_VALUE(curid3, 2, tvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 3, fvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 4, nvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 5, pfiniefe);
               DBMS_SQL.COLUMN_VALUE(curid3, 6, pmovima);
               DBMS_SQL.COLUMN_VALUE(curid3, 7, vmovimi);
               preg(preg.LAST).finiefe := pfiniefe;
               preg(preg.LAST).nmovima := pmovima;
               preg(preg.LAST).nmovimi := vmovimi;
               pregtab(pregtab.LAST).nmovimi := vmovimi;

               IF pregtab_col IS NOT NULL THEN
                  IF pregtab_col.COUNT <> 0 THEN
                     FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                        IF pregtab_col(k).ccolumna = ccolumna THEN
                           pregtab_col(k).ccolumna := ccolumna;
                           pregtab_col(k).tvalor := tvalor;
                           pregtab_col(k).fvalor := fvalor;
                           pregtab_col(k).nvalor := nvalor;

                           IF pregtab_col(k).ctipcol = 4 THEN
                              FOR rsp IN c_lista(cpregun, pregtab_col(k).ccolumna) LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                     rsp.clista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                     rsp.tlista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;
                              END LOOP;
                           ELSIF pregtab_col(k).ctipcol = 5 THEN
                              vconsulta := REPLACE(pregtab_col(k).tconsulta, ':PMT_IDIOMA',
                                                   pac_md_common.f_get_cxtidioma);
                              vconsulta := REPLACE(vconsulta, ':PMT_SPRODUC', vsproduc || ' ');
                              vconsulta := REPLACE(vconsulta, ':PMT_CGARANT', pcgarant || ' ');
                              -- BUG26501 - 21/01/2014 - JTT: Afegim el parametre npoliza
                              vconsulta := REPLACE(vconsulta, ':PMT_NPOLIZA', vnpoliza || ' ');
                              vconsulta := REPLACE(vconsulta, ':PMT_CAGENTE', vcagente || ' ');
                              vpasexec := 14;
                              cur := pac_md_listvalores.f_opencursor(vconsulta, mensajes);
                              vpasexec := 15;

                              FETCH cur
                               INTO catribu, tatribu;

                              vpasexec := 16;

                              WHILE cur%FOUND LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                        catribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                        tatribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;

                                 FETCH cur
                                  INTO catribu, tatribu;

                                 vpasexec := 20;
                              END LOOP;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;

            pregtab(pregtab.LAST).tcolumnas := pregtab_col;
         END LOOP;

         preg(preg.LAST).tpreguntastab := pregtab;
         -- Bug 27768/157881 - JSV - 06/11/2013
         pregtab := t_iax_preguntastab();
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      DBMS_SQL.close_cursor(curid2);
      DBMS_SQL.close_cursor(curid3);
      RETURN preg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         RETURN NULL;
   END f_leepreguntasgarantia;

/*************************************************************************
Lee las primas de la garantia
param in pnriesgo  : n¿mero de riesgo
param in pcgarant  : codigo de garantia
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leeprimasgarantia(
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_primas IS
      primas         t_iax_primas := t_iax_primas();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo || ' pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeePrimasGarantia';
   BEGIN
      -- primas.extend;
      -- primas(primas.last) := PAC_IAX_PRODUCCION.F_GET_DETAILPRIMASGARANT(pnriesgo,pcgarant,mensajes);
      RETURN primas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeprimasgarantia;

/*************************************************************************
<<-- Recuperar informacion de las de garantias
*************************************************************************/
/*************************************************************************
Recuperar la informacion de beneficiarios
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto beneficiarios
*************************************************************************/
   FUNCTION f_leebeneficiarios(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_beneficiarios IS
      benef          ob_iax_beneficiarios := ob_iax_beneficiarios();
      vtab1          VARCHAR2(100);
      vtab2          VARCHAR2(100);
      squery         VARCHAR2(2000);
      cur            sys_refcursor;
      vctipo         NUMBER;
      vtclaesp       VARCHAR2(31000);
      vsclaben       NUMBER;
      vtclaben       VARCHAR2(200);
      vffinclau      DATE;
      vfiniclau      DATE;
      vnordcla       NUMBER;
      vmov           VARCHAR2(500) := ' AND ffinclau IS NULL ';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeBeneficiarios';
      --19152
      v_benef_esp    ob_iax_benespeciales := ob_iax_benespeciales();
      v_tapelli      VARCHAR2(4000);
      v_tnombre      VARCHAR2(4000);
      v_norden       NUMBER := 0;
      vcagente       NUMBER;
      -- BUG 0027305 - 30/09/2013 - JMF
      v_oculporcen_repleg NUMBER;
      -- Bug 30365/175325 - 29/05/2014 - AMC
      vnumerr        NUMBER;
      v_sseguro      NUMBER;
      v_chereda      NUMBER;
      vsperson_out   NUMBER;
      vheredado      NUMBER;

      -- 34866/209952
      -- Bug 24717 - MDS - 20/12/2012 : A?adir campo cestado
      CURSOR c_ben_ident(psseguro NUMBER, pcgarant NUMBER) IS
         SELECT bp.cgarant, bp.sperson, bp.sperson_tit, bp.finiben, bp.ffinben, bp.ctipben,
                bp.cparen, bp.pparticip, bp.cestado, bp.ctipocon   -- ozea 34866\210997
           FROM benespseg bp
          WHERE bp.cgarant = pcgarant
            AND vpmode = 'POL'
            AND bp.sseguro = psseguro
            AND bp.nriesgo = pnriesgo
            AND bp.ffinben IS NULL
         UNION
         SELECT bp.cgarant, bp.sperson, bp.sperson_tit, bp.finiben, bp.ffinben, bp.ctipben,
                bp.cparen, bp.pparticip, bp.cestado, bp.ctipocon   -- ozea 34866\210997
           FROM estbenespseg bp
          WHERE cgarant = pcgarant
            AND vpmode = 'EST'
            AND bp.sseguro = psseguro
            AND bp.nriesgo = pnriesgo
            AND bp.ffinben IS NULL;

      CURSOR c_ben_gar(psseguro NUMBER) IS
         SELECT   bp.cgarant
             FROM benespseg bp
            WHERE cgarant <> 0
              AND vpmode = 'POL'
              AND bp.sseguro = psseguro
              AND bp.nriesgo = pnriesgo
              AND bp.ffinben IS NULL
         GROUP BY bp.cgarant
         UNION
         SELECT   bp.cgarant
             FROM estbenespseg bp
            WHERE cgarant <> 0
              AND vpmode = 'EST'
              AND bp.sseguro = psseguro
              AND bp.nriesgo = pnriesgo
              AND bp.ffinben IS NULL
         GROUP BY bp.cgarant;

      -- Bug 30365/175325 - 29/05/2014 - AMC
      CURSOR c_ben_ident2(psseguro NUMBER, pcgarant NUMBER) IS
         SELECT bp.cgarant, bp.sperson, bp.sperson_tit, bp.finiben, bp.ffinben, bp.ctipben,
                bp.cparen, bp.pparticip, bp.cestado
           FROM benespseg bp
          WHERE bp.cgarant = pcgarant
            AND bp.sseguro = psseguro
            AND bp.nriesgo = pnriesgo
            AND bp.ffinben IS NULL;

      CURSOR c_ben_gar2(psseguro NUMBER) IS
         SELECT   bp.cgarant
             FROM benespseg bp
            WHERE cgarant <> 0
              AND bp.sseguro = psseguro
              AND bp.nriesgo = pnriesgo
              AND bp.ffinben IS NULL
         GROUP BY bp.cgarant;
   BEGIN
      vheredado := 0;
      -- BUG 0027305 - 30/09/2013 - JMF
      v_oculporcen_repleg := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                           'OCULPORCEN_REPLEG');

      IF vpmode = 'EST' THEN
         vtab1 := 'ESTCLAUSUESP';
         vtab2 := 'ESTCLAUBENSEG';
      ELSIF vpmode = 'POL' THEN
         vtab1 := 'CLAUSUESP';
         vtab2 := 'CLAUBENSEG';
      END IF;

      squery :=
         'SELECT 1 CTIPO, TCLAESP, NULL SCLABEN, NULL TCLABEN, FFINCLAU, FINICLAU, NORDCLA FROM '
         || vtab1 || ' WHERE CCLAESP = 1 and sseguro=' || vsolicit || ' and nriesgo='
         || pnriesgo || vmov
         || ' UNION SELECT 2 CTIPO, NULL TCLAESP, SCLABEN, NULL TCLABEN, FFINCLAU, FINICLAU , NULL NORDCLA FROM '
         || vtab2 || ' WHERE sseguro=' || vsolicit || ' and nriesgo=' || pnriesgo || vmov;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 2;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                  'ICV: ' || 'ENTRO1' || ' - ' || SQLERRM);

      LOOP
         FETCH cur
          INTO vctipo, vtclaesp, vsclaben, vtclaben, vffinclau, vfiniclau, vnordcla;

         EXIT WHEN cur%NOTFOUND;
         benef.ctipo := vctipo;
         benef.tclaesp := vtclaesp;
         benef.sclaben := vsclaben;
         benef.tclaben := vtclaben;
         benef.ffinclau := vffinclau;
         benef.finiclau := vfiniclau;
         benef.nordcla := vnordcla;
      END LOOP;

      CLOSE cur;

      vpasexec := 3;

      --Bug.: 19152 - 20/11/2011 - ICV
      -- Bug 30365/175325 - 29/05/2014 - AMC
      IF NOT pac_iax_produccion.issuplem THEN
         vnumerr :=
            pac_productos.f_get_herencia_col(pac_iax_produccion.poliza.det_poliza.sproduc, 19,
                                             v_chereda);

         IF v_chereda = 1 THEN
            vpasexec := 4;
            vpasexec := 5;

            IF pac_mdpar_productos.f_get_parproducto
                                                 ('ADMITE_CERTIFICADOS',
                                                  pac_iax_produccion.poliza.det_poliza.sproduc) =
                                                                                             1
               AND NOT pac_iax_produccion.isaltacol THEN
               vnumerr :=
                  pac_seguros.f_get_sseguro(pac_iax_produccion.poliza.det_poliza.npoliza, 0,
                                            'POL', v_sseguro);

               IF vpmode = 'EST' THEN   --ramiro
                  --ramiro
                  vnumerr := pac_seguros.f_get_cagente(v_sseguro, 'EST', vcagente);   --ramiro
               ELSIF vpmode = 'POL' THEN
                  --ramiro
                  vnumerr := pac_seguros.f_get_cagente(v_sseguro, 'POL', vcagente);   --ramiro
               END IF;   --ramiro

               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                           'ICV: ' || 'ENTRO2' || ' - ' || vcagente);

               --Beneficiarios identificados
               FOR rc IN c_ben_ident(vsolicit, 0) LOOP
                  benef.ctipo := 3;
                  benef.benefesp := ob_iax_benespeciales();

                  IF v_benef_esp.benef_riesgo IS NULL THEN
                     v_benef_esp.benef_riesgo := t_iax_beneidentificados();
                  END IF;

                  pac_persona.traspaso_tablas_per(rc.sperson, vsperson_out, v_sseguro,
                                                  pac_md_common.f_get_cxtagente());
                  v_benef_esp.benef_riesgo.EXTEND;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST) :=
                                                                     ob_iax_beneidentificados
                                                                                             ();
                  --Ini 31204/12459 --ECP -- 06/05/2014
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).cgarant := rc.cgarant;
                  --Fin 31204/12459 --ECP -- 06/05/2014
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).sperson :=
                                                                                   vsperson_out;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).sperson_tit :=
                                                                                 rc.sperson_tit;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).finiben := rc.finiben;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ffinben := rc.ffinben;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ctipben := rc.ctipben;

                  -- Ini Bug 24717 - MDS - 20/12/2012 : diferenciar la lista de valores espec?fica 800127 de la gen?rica 1053
                  IF pac_mdpar_productos.f_get_parproducto
                                                  ('ALTERNATIVO_BENEF',
                                                   pac_iax_produccion.poliza.det_poliza.sproduc) =
                                                                                              1 THEN
                     v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipben :=
                          ff_desvalorfijo(800127, pac_md_common.f_get_cxtidioma(), rc.ctipben);
                  ELSE
                     v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipben :=
                            ff_desvalorfijo(1053, pac_md_common.f_get_cxtidioma(), rc.ctipben);
                  END IF;

                  -- Fin Bug 24717 - MDS - 20/12/2012
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).cparen := rc.cparen;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).tparen :=
                              ff_desvalorfijo(1054, pac_md_common.f_get_cxtidioma(), rc.cparen);
                  -- BUG 28730 - 29/10/2013 JRB: Se revierten los cambios de representantes legales
                  -- BUG 0027305 - 30/09/2013 - JMF: Para Representantes legales ocultamos porcentaje
                  /*IF rc.ctipben = 3
                  AND v_oculporcen_repleg = 1 THEN
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).pparticip := NULL;
                  ELSE*/
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).pparticip :=
                                                                                   rc.pparticip;
                  --END IF;
                  -- Ini Bug 24717 - MDS - 20/12/2012 : A?adir campo cestado
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).cestado := rc.cestado;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).testado :=
                           ff_desvalorfijo(800128, pac_md_common.f_get_cxtidioma(), rc.cestado);
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ctipocon :=
                                                                                    rc.ctipocon;
                  -- ozea 34866\210997
                  -- Fin Bug 24717 - MDS - 20/12/2012 : A?adir campo cestado
                  v_norden := v_norden + 1;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).norden := v_norden;

                  BEGIN
                     IF vpmode <> 'EST' THEN
                        SELECT ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(),
                                               pp.ctipide),
                               pp.nnumide
                          INTO v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipide,
                               v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nnumide
                          FROM per_personas pp
                         WHERE pp.sperson = NVL(pac_persona.f_sperson_spereal(vsperson_out),
                                                vsperson_out);
                     ELSE
                        SELECT ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(),
                                               pp.ctipide),
                               pp.nnumide
                          INTO v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipide,
                               v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nnumide
                          FROM estper_personas pp
                         WHERE pp.sperson = vsperson_out;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipide :=
                                                                                          NULL;
                        v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nnumide :=
                                                                                          NULL;
                  END;

                  IF NVL(rc.sperson_tit, 0) <> 0 THEN
                     IF vpmode <> 'EST' THEN
                        v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nombre_tit :=
                           f_nombre(NVL(pac_persona.f_sperson_spereal(rc.sperson_tit),
                                        rc.sperson_tit),
                                    1, NVL(vcagente, pac_md_common.f_get_cxtagente()));
                     ELSE
                        v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nombre_tit :=
                           f_nombre_est(rc.sperson_tit, 1,
                                        NVL(vcagente, pac_md_common.f_get_cxtagente()));
                     END IF;
                  END IF;

                  IF vsperson_out IS NOT NULL THEN
                     IF vpmode <> 'EST' THEN
                        v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nombre_ben :=
                           f_nombre(NVL(pac_persona.f_sperson_spereal(rc.sperson),
                                        vsperson_out),
                                    1, NVL(vcagente, pac_md_common.f_get_cxtagente()));
                     ELSE
                        v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nombre_ben :=
                           f_nombre_est(vsperson_out, 1,
                                        NVL(vcagente, pac_md_common.f_get_cxtagente()));
                     END IF;
                  END IF;

                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).cheredado := 1;
                  vheredado := 1;
               END LOOP;

               FOR rc IN c_ben_gar2(v_sseguro) LOOP
                  benef.ctipo := 3;

                  IF benef.benefesp IS NULL THEN
                     benef.benefesp := ob_iax_benespeciales();
                  END IF;

                  IF v_benef_esp.benefesp_gar IS NULL THEN
                     v_benef_esp.benefesp_gar := t_iax_benespeciales_gar();
                  END IF;

                  v_benef_esp.benefesp_gar.EXTEND;
                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST) :=
                                                                     ob_iax_benespeciales_gar
                                                                                             ();
                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).cgarant := rc.cgarant;

                  BEGIN
                     SELECT gg.tgarant
                       INTO v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).tgarant
                       FROM garangen gg
                      WHERE gg.cgarant = rc.cgarant
                        AND gg.cidioma = pac_md_common.f_get_cxtidioma();
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).tgarant :=
                                                                                          '**';
                  END;

                  FOR rg IN c_ben_ident2(v_sseguro, rc.cgarant) LOOP
                     IF v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident IS NULL THEN
                        v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident :=
                                                                     t_iax_beneidentificados
                                                                                            ();
                     END IF;

                     pac_persona.traspaso_tablas_per(rg.sperson, vsperson_out, v_sseguro,
                                                     pac_md_common.f_get_cxtagente());
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.EXTEND;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST) :=
                                                                     ob_iax_beneidentificados
                                                                                             ();
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).sperson :=
                                                                                   vsperson_out;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).sperson_tit :=
                                                                                 rg.sperson_tit;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).finiben :=
                                                                                     rg.finiben;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ffinben :=
                                                                                     rg.ffinben;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ctipben :=
                                                                                     rg.ctipben;

                     -- Ini Bug 24717 - MDS - 20/12/2012 : diferenciar la lista de valores espec¿fica 800127 de la gen¿rica 1053
                     IF pac_mdpar_productos.f_get_parproducto
                                                  ('ALTERNATIVO_BENEF',
                                                   pac_iax_produccion.poliza.det_poliza.sproduc) =
                                                                                              1 THEN
                        v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                           (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipben :=
                           ff_desvalorfijo(800127, pac_md_common.f_get_cxtidioma(),
                                           rg.ctipben);
                     ELSE
                        v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                           (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipben :=
                            ff_desvalorfijo(1053, pac_md_common.f_get_cxtidioma(), rg.ctipben);
                     END IF;

                     -- Fin Bug 24717 - MDS - 20/12/2012
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).cparen :=
                                                                                      rg.cparen;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).tparen :=
                              ff_desvalorfijo(1054, pac_md_common.f_get_cxtidioma(), rg.cparen);
                     -- BUG 28730 - 29/10/2013 JRB: Se revierten los cambios de representantes legales
                     -- BUG 0027305 - 30/09/2013 - JMF: Para Representantes legales ocultamos porcentaje
                     /* IF rg.ctipben = 3
                     AND v_oculporcen_repleg = 1 THEN
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                     (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).pparticip :=
                     NULL;
                     ELSE*/
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).pparticip :=
                                                                                   rg.pparticip;
                     --END IF;
                     -- Ini Bug 24717 - MDS - 20/12/2012 : A¿adir campo cestado
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).cestado :=
                                                                                     rg.cestado;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).testado :=
                           ff_desvalorfijo(800128, pac_md_common.f_get_cxtidioma(), rg.cestado);
                     -- Fin Bug 24717 - MDS - 20/12/2012 : A¿adir campo cestado
                     v_norden := v_norden + 1;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).norden :=
                                                                                       v_norden;

                     BEGIN
                        IF vpmode <> 'EST' THEN
                           SELECT ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(),
                                                  pp.ctipide),
                                  pp.nnumide
                             INTO v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                                     (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipide,
                                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                                     (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nnumide
                             FROM per_personas pp
                            WHERE pp.sperson =
                                     NVL(pac_persona.f_sperson_spereal(vsperson_out),
                                         vsperson_out);
                        ELSE
                           SELECT ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(),
                                                  pp.ctipide),
                                  pp.nnumide
                             INTO v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                                     (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipide,
                                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                                     (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nnumide
                             FROM estper_personas pp
                            WHERE pp.sperson = vsperson_out;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                              (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipide :=
                                                                                          NULL;
                           v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                              (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nnumide :=
                                                                                          NULL;
                     END;

                     IF NVL(rg.sperson_tit, 0) <> 0 THEN
                        IF vpmode <> 'EST' THEN
                           v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                              (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nombre_tit :=
                              f_nombre(NVL(pac_persona.f_sperson_spereal(rg.sperson_tit),
                                           rg.sperson_tit),
                                       1, NVL(vcagente, pac_md_common.f_get_cxtagente()));
                        ELSE
                           v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                              (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nombre_tit :=
                              f_nombre_est(rg.sperson_tit, 1,
                                           NVL(vcagente, pac_md_common.f_get_cxtagente()));
                        END IF;
                     END IF;

                     IF rg.sperson IS NOT NULL THEN
                        IF vpmode <> 'EST' THEN
                           v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                              (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nombre_ben :=
                              f_nombre(NVL(pac_persona.f_sperson_spereal(vsperson_out),
                                           vsperson_out),
                                       1, NVL(vcagente, pac_md_common.f_get_cxtagente()));
                        ELSE
                           v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                              (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nombre_ben :=
                              f_nombre_est(vsperson_out, 1,
                                           NVL(vcagente, pac_md_common.f_get_cxtagente()));
                        END IF;
                     END IF;

                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).cheredado :=
                                                                                              1;
                  END LOOP;

                  vheredado := 1;
               END LOOP;
            END IF;
         END IF;
      END IF;

      IF vheredado = 0 THEN
         --Bug.: 19152 - 20/11/2011 - ICV
         vnumerr :=
            pac_productos.f_get_herencia_col(pac_iax_produccion.poliza.det_poliza.sproduc, 19,
                                             v_chereda);
         vnumerr := pac_seguros.f_get_sseguro(pac_iax_produccion.poliza.det_poliza.npoliza, 0,
                                              'POL', v_sseguro);

         IF vpmode = 'EST' THEN   --ramiro
            vnumerr := pac_seguros.f_get_cagente(v_sseguro, 'EST', vcagente);   --ramiro
         ELSIF vpmode = 'POL' THEN   --ramiro
            vnumerr := pac_seguros.f_get_cagente(v_sseguro, 'POL', vcagente);   --ramiro
         END IF;   --ramiro

         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ICV: ' || 'ENTRO3' || ' - ' || vcagente);

         --Beneficiarios identificados
         FOR rc IN c_ben_ident(vsolicit, 0) LOOP
            benef.ctipo := 3;
            benef.benefesp := ob_iax_benespeciales();

            IF v_benef_esp.benef_riesgo IS NULL THEN
               v_benef_esp.benef_riesgo := t_iax_beneidentificados();
            END IF;

            v_benef_esp.benef_riesgo.EXTEND;
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST) :=
                                                                     ob_iax_beneidentificados
                                                                                             ();
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).sperson := rc.sperson;
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).sperson_tit :=
                                                                                 rc.sperson_tit;
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).finiben := rc.finiben;
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ffinben := rc.ffinben;
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ctipben := rc.ctipben;

            -- Ini Bug 24717 - MDS - 20/12/2012 : diferenciar la lista de valores espec¿fica 800127 de la gen¿rica 1053
            IF pac_mdpar_productos.f_get_parproducto
                                                  ('ALTERNATIVO_BENEF',
                                                   pac_iax_produccion.poliza.det_poliza.sproduc) =
                                                                                              1 THEN
               v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipben :=
                          ff_desvalorfijo(800127, pac_md_common.f_get_cxtidioma(), rc.ctipben);
            ELSE
               v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipben :=
                            ff_desvalorfijo(1053, pac_md_common.f_get_cxtidioma(), rc.ctipben);
            END IF;

            -- Fin Bug 24717 - MDS - 20/12/2012
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).cparen := rc.cparen;
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).tparen :=
                              ff_desvalorfijo(1054, pac_md_common.f_get_cxtidioma(), rc.cparen);
            -- BUG 28730 - 29/10/2013 JRB: Se revierten los cambios de representantes legales
            -- BUG 0027305 - 30/09/2013 - JMF: Para Representantes legales ocultamos porcentaje
            /*IF rc.ctipben = 3
            AND v_oculporcen_repleg = 1 THEN
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).pparticip := NULL;
            ELSE*/
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).pparticip := rc.pparticip;
            --END IF;
            -- Ini Bug 24717 - MDS - 20/12/2012 : A¿adir campo cestado
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).cestado := rc.cestado;
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).testado :=
                           ff_desvalorfijo(800128, pac_md_common.f_get_cxtidioma(), rc.cestado);
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ctipocon := rc.ctipocon;
            -- ozea 34866\210997
            -- Fin Bug 24717 - MDS - 20/12/2012 : A¿adir campo cestado
            v_norden := v_norden + 1;
            v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).norden := v_norden;

            BEGIN
               IF vpmode <> 'EST' THEN
                  SELECT ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(), pp.ctipide),
                         pp.nnumide
                    INTO v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipide,
                         v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nnumide
                    FROM per_personas pp
                   WHERE pp.sperson = NVL(pac_persona.f_sperson_spereal(rc.sperson),
                                          rc.sperson);
               ELSE
                  SELECT ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(), pp.ctipide),
                         pp.nnumide
                    INTO v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipide,
                         v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nnumide
                    FROM estper_personas pp
                   WHERE pp.sperson = rc.sperson;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).ttipide := NULL;
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nnumide := NULL;
            END;

            IF NVL(rc.sperson_tit, 0) <> 0 THEN
               IF vpmode <> 'EST' THEN
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nombre_tit :=
                     f_nombre(NVL(pac_persona.f_sperson_spereal(rc.sperson_tit),
                                  rc.sperson_tit),
                              1, NVL(vcagente, pac_md_common.f_get_cxtagente()));
               ELSE
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nombre_tit :=
                     f_nombre_est(rc.sperson_tit, 1,
                                  NVL(vcagente, pac_md_common.f_get_cxtagente()));
               END IF;
            END IF;

            IF rc.sperson IS NOT NULL THEN
               IF vpmode <> 'EST' THEN
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nombre_ben :=
                     f_nombre(NVL(pac_persona.f_sperson_spereal(rc.sperson), rc.sperson), 1,
                              NVL(vcagente, pac_md_common.f_get_cxtagente()));
               ELSE
                  v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).nombre_ben :=
                     f_nombre_est(rc.sperson, 1,
                                  NVL(vcagente, pac_md_common.f_get_cxtagente()));
               END IF;
            END IF;

            -- Bug 30365/167876 - 03/06/2014 - AMC
            IF v_chereda = 1 THEN
               vnumerr :=
                  pac_seguros.f_get_sseguro(pac_iax_produccion.poliza.det_poliza.npoliza, 0,
                                            'POL', v_sseguro);

               FOR rr IN c_ben_ident2(v_sseguro, 0) LOOP
                  SELECT spereal
                    INTO vsperson_out
                    FROM estper_personas
                   WHERE sperson = rc.sperson;

                  IF vsperson_out = rr.sperson THEN
                     v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).cheredado := 1;
                  END IF;
               END LOOP;
            ELSE
               v_benef_esp.benef_riesgo(v_benef_esp.benef_riesgo.LAST).cheredado := 0;
            END IF;
         -- Fi Bug 30365/167876 - 03/06/2014 - AMC
         END LOOP;

         v_norden := 0;

         --Beneficiarios por garantia
         FOR rc IN c_ben_gar(vsolicit) LOOP
            benef.ctipo := 3;

            IF benef.benefesp IS NULL THEN
               benef.benefesp := ob_iax_benespeciales();
            END IF;

            IF v_benef_esp.benefesp_gar IS NULL THEN
               v_benef_esp.benefesp_gar := t_iax_benespeciales_gar();
            END IF;

            v_benef_esp.benefesp_gar.EXTEND;
            v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST) :=
                                                                     ob_iax_benespeciales_gar
                                                                                             ();
            v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).cgarant := rc.cgarant;

            BEGIN
               SELECT gg.tgarant
                 INTO v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).tgarant
                 FROM garangen gg
                WHERE gg.cgarant = rc.cgarant
                  AND gg.cidioma = pac_md_common.f_get_cxtidioma();
            EXCEPTION
               WHEN OTHERS THEN
                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).tgarant := '**';
            END;

            FOR rg IN c_ben_ident(vsolicit, rc.cgarant) LOOP
               IF v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident IS NULL THEN
                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident :=
                                                                     t_iax_beneidentificados
                                                                                            ();
               END IF;

               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.EXTEND;
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST) :=
                                                                     ob_iax_beneidentificados
                                                                                             ();
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).sperson :=
                                                                                     rg.sperson;
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).sperson_tit :=
                                                                                 rg.sperson_tit;
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).finiben :=
                                                                                     rg.finiben;
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ffinben :=
                                                                                     rg.ffinben;
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ctipben :=
                                                                                     rg.ctipben;

               -- Ini Bug 24717 - MDS - 20/12/2012 : diferenciar la lista de valores espec?fica 800127 de la gen?rica 1053
               IF pac_mdpar_productos.f_get_parproducto
                                                  ('ALTERNATIVO_BENEF',
                                                   pac_iax_produccion.poliza.det_poliza.sproduc) =
                                                                                              1 THEN
                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                     (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipben :=
                          ff_desvalorfijo(800127, pac_md_common.f_get_cxtidioma(), rg.ctipben);
               ELSE
                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                     (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipben :=
                            ff_desvalorfijo(1053, pac_md_common.f_get_cxtidioma(), rg.ctipben);
               END IF;

               -- Fin Bug 24717 - MDS - 20/12/2012
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).cparen :=
                                                                                      rg.cparen;
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).tparen :=
                              ff_desvalorfijo(1054, pac_md_common.f_get_cxtidioma(), rg.cparen);
               -- BUG 28730 - 29/10/2013 JRB: Se revierten los cambios de representantes legales
               -- BUG 0027305 - 30/09/2013 - JMF: Para Representantes legales ocultamos porcentaje
               /* IF rg.ctipben = 3
               AND v_oculporcen_repleg = 1 THEN
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
               (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).pparticip :=
               NULL;
               ELSE*/
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).pparticip :=
                                                                                   rg.pparticip;
               --END IF;
               -- Ini Bug 24717 - MDS - 20/12/2012 : A?adir campo cestado
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).cestado :=
                                                                                     rg.cestado;
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).testado :=
                           ff_desvalorfijo(800128, pac_md_common.f_get_cxtidioma(), rg.cestado);
               -- Fin Bug 24717 - MDS - 20/12/2012 : A?adir campo cestado
               v_norden := v_norden + 1;
               v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                      (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).norden :=
                                                                                       v_norden;

               BEGIN
                  IF vpmode <> 'EST' THEN
                     SELECT ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(), pp.ctipide),
                            pp.nnumide
                       INTO v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                               (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipide,
                            v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                               (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nnumide
                       FROM per_personas pp
                      WHERE pp.sperson = NVL(pac_persona.f_sperson_spereal(rg.sperson),
                                             rg.sperson);
                  ELSE
                     SELECT ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(), pp.ctipide),
                            pp.nnumide
                       INTO v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                               (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipide,
                            v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                               (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nnumide
                       FROM estper_personas pp
                      WHERE pp.sperson = rg.sperson;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).ttipide :=
                                                                                          NULL;
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nnumide :=
                                                                                          NULL;
               END;

               IF NVL(rg.sperson_tit, 0) <> 0 THEN
                  IF vpmode <> 'EST' THEN
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nombre_tit :=
                        f_nombre(NVL(pac_persona.f_sperson_spereal(rg.sperson_tit),
                                     rg.sperson_tit),
                                 1, NVL(vcagente, pac_md_common.f_get_cxtagente()));
                  ELSE
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nombre_tit :=
                        f_nombre_est(rg.sperson_tit, 1,
                                     NVL(vcagente, pac_md_common.f_get_cxtagente()));
                  END IF;
               END IF;

               IF rg.sperson IS NOT NULL THEN
                  IF vpmode <> 'EST' THEN
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nombre_ben :=
                        f_nombre(NVL(pac_persona.f_sperson_spereal(rg.sperson), rg.sperson),
                                 1, NVL(vcagente, pac_md_common.f_get_cxtagente()));
                  ELSE
                     v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                        (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).nombre_ben :=
                        f_nombre_est(rg.sperson, 1,
                                     NVL(vcagente, pac_md_common.f_get_cxtagente()));
                  END IF;
               END IF;

               -- Bug 30365/167876 - 03/06/2014 - AMC
               IF v_chereda = 1 THEN
                  vnumerr :=
                     pac_seguros.f_get_sseguro(pac_iax_produccion.poliza.det_poliza.npoliza,
                                               0, 'POL', v_sseguro);

                  FOR rr IN c_ben_ident2(v_sseguro, rc.cgarant) LOOP
                     SELECT spereal
                       INTO vsperson_out
                       FROM estper_personas
                      WHERE sperson = rg.sperson;

                     IF vsperson_out = rr.sperson THEN
                        v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                           (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).cheredado :=
                                                                                             1;
                     END IF;
                  END LOOP;
               ELSE
                  v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident
                     (v_benef_esp.benefesp_gar(v_benef_esp.benefesp_gar.LAST).benef_ident.LAST).cheredado :=
                                                                                             0;
               END IF;
            -- Fi Bug 30365/167876 - 03/06/2014 - AMC
            END LOOP;
         END LOOP;
      END IF;

      -- Fi Bug 30365/175325 - 29/05/2014 - AMC
      benef.benefesp := v_benef_esp;
      --End bug.:19152
      RETURN benef;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leebeneficiarios;

--JRH 03/2008
/*************************************************************************
Recuperar la informacion de las rentas irregulares
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto garantias
*************************************************************************/
   FUNCTION f_leerentasirreg(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_rentairr IS
      cur            sys_refcursor;
      estgar         estplanrentasirreg%ROWTYPE;
      polgar         planrentasirreg%ROWTYPE;
      garant         t_iax_rentairr := t_iax_rentairr();
      squery         VARCHAR2(500);
      vtab           VARCHAR2(20);
      vfield         VARCHAR2(20);
      vfields        VARCHAR2(100);
      pri            ob_iax_primas;
      sproduc        NUMBER;
      vtab2          VARCHAR2(20);
      vcond          VARCHAR2(100);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRentasIrreg';
      anyoini        NUMBER := 0;
   BEGIN
      IF vpmode IN('EST', 'SOL') THEN
         vfield := 'SSEGURO';
         vtab := 'estplanrentasirreg';
         vtab2 := 'estseguros';
         vfields := '*';
         --vfields:='cgarant,icapital,iprianu,crevali,prevali,irevali,precarg,cfranq,irecarg,ifranqu,nmovimi';
         vcond := ' order by anyo,mes ';   --' and NMOVIMI='|| vnmovimi;
      ELSE
         vfield := 'SSEGURO';
         vtab := 'planrentasirreg';
         vtab2 := 'seguros';
         vfields := '*';
         --vfields:='cgarant,icapital,iprianu,crevali,prevali,irevali,precarg,cfranq,irecarg,ifranqu,nmovimi';
         vcond := 'AND ffinefe IS NULL ';   --' and NMOVIMI='|| vnmovimi;
      END IF;

      squery := 'SELECT ' || vfields || ' FROM ' || vtab || ' where ' || vfield || '='
                || vsolicit || ' and ' || '       nriesgo=' || pnriesgo
                || ' order by anyo,mes ';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);

      BEGIN
         sproduc :=
            TO_NUMBER(pac_iax_listvalores.f_getdescripvalor('select sproduc from ' || vtab2
                                                            || ' where ' || vfield || '='
                                                            || vsolicit,
                                                            mensajes));
      EXCEPTION
         WHEN OTHERS THEN
            sproduc := NULL;
      END;

      IF vpmode IN('SOL', 'EST') THEN
         LOOP
            FETCH cur
             INTO estgar;

            EXIT WHEN cur%NOTFOUND;

            IF anyoini <> estgar.anyo THEN
               garant.EXTEND;
               garant(garant.LAST) := ob_iax_rentairr();
               garant(garant.LAST).nriesgo := estgar.nriesgo;
               garant(garant.LAST).nmovimi := estgar.nmovimi;
               garant(garant.LAST).anyo := estgar.anyo;
               anyoini := estgar.anyo;
            END IF;

            IF estgar.mes = 1 THEN
               garant(garant.LAST).mes1 := estgar.importe;
            END IF;

            IF estgar.mes = 2 THEN
               garant(garant.LAST).mes2 := estgar.importe;
            END IF;

            IF estgar.mes = 3 THEN
               garant(garant.LAST).mes3 := estgar.importe;
            END IF;

            IF estgar.mes = 4 THEN
               garant(garant.LAST).mes4 := estgar.importe;
            END IF;

            IF estgar.mes = 5 THEN
               garant(garant.LAST).mes5 := estgar.importe;
            END IF;

            IF estgar.mes = 6 THEN
               garant(garant.LAST).mes6 := estgar.importe;
            END IF;

            IF estgar.mes = 7 THEN
               garant(garant.LAST).mes7 := estgar.importe;
            END IF;

            IF estgar.mes = 8 THEN
               garant(garant.LAST).mes8 := estgar.importe;
            END IF;

            IF estgar.mes = 9 THEN
               garant(garant.LAST).mes9 := estgar.importe;
            END IF;

            IF estgar.mes = 10 THEN
               garant(garant.LAST).mes10 := estgar.importe;
            END IF;

            IF estgar.mes = 11 THEN
               garant(garant.LAST).mes11 := estgar.importe;
            END IF;

            IF estgar.mes = 12 THEN
               garant(garant.LAST).mes12 := estgar.importe;
            END IF;
         END LOOP;
      ELSE
         LOOP
            FETCH cur
             INTO polgar;

            EXIT WHEN cur%NOTFOUND;

            IF anyoini <> polgar.anyo THEN
               garant.EXTEND;
               garant(garant.LAST) := ob_iax_rentairr();
               garant(garant.LAST).nriesgo := polgar.nriesgo;
               garant(garant.LAST).nmovimi := polgar.nmovimi;
               garant(garant.LAST).anyo := polgar.anyo;
               anyoini := polgar.anyo;
            END IF;

            IF polgar.mes = 1 THEN
               garant(garant.LAST).mes1 := polgar.importe;
            END IF;

            IF polgar.mes = 2 THEN
               garant(garant.LAST).mes2 := polgar.importe;
            END IF;

            IF polgar.mes = 3 THEN
               garant(garant.LAST).mes3 := polgar.importe;
            END IF;

            IF polgar.mes = 4 THEN
               garant(garant.LAST).mes4 := polgar.importe;
            END IF;

            IF polgar.mes = 5 THEN
               garant(garant.LAST).mes5 := polgar.importe;
            END IF;

            IF polgar.mes = 6 THEN
               garant(garant.LAST).mes6 := polgar.importe;
            END IF;

            IF polgar.mes = 7 THEN
               garant(garant.LAST).mes7 := polgar.importe;
            END IF;

            IF polgar.mes = 8 THEN
               garant(garant.LAST).mes8 := polgar.importe;
            END IF;

            IF polgar.mes = 9 THEN
               garant(garant.LAST).mes9 := polgar.importe;
            END IF;

            IF polgar.mes = 10 THEN
               garant(garant.LAST).mes10 := polgar.importe;
            END IF;

            IF polgar.mes = 11 THEN
               garant(garant.LAST).mes11 := polgar.importe;
            END IF;

            IF polgar.mes = 12 THEN
               garant(garant.LAST).mes12 := polgar.importe;
            END IF;
         END LOOP;
      END IF;

      CLOSE cur;

      RETURN garant;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leerentasirreg;

/*************************************************************************
Recuperar la informacion de los beneficiarios nominales
param out mensajes : mesajes de error
return             : objeto beneficiarios nominales
*************************************************************************/
   FUNCTION f_leebenenominales(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_benenominales IS
      benef          t_iax_benenominales := t_iax_benenominales();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeBeneNominales';
   BEGIN
      RETURN benef;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leebenenominales;

/*************************************************************************
Recuperar la informaci¿¿n de dispositivos en el riesgo automoviles
param in pnriesgo  : n¿¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto detalle p¿¿liza
*************************************************************************/
   FUNCTION f_leedispositivosauto(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autdispositivos IS
      dispositius    t_iax_autdispositivos := t_iax_autdispositivos();
      vtab           VARCHAR2(2000);
      vnmov          VARCHAR2(2000);
      squery         VARCHAR2(2000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_leedispositivosauto';
      vsseguro       NUMBER;
      vnriesgo       NUMBER(6);
      vnmovimi       NUMBER(4);
      vcversion      VARCHAR2(11);
      vcmarcado      NUMBER(1);
      vcdispositivo  VARCHAR2(10);
      vcpropdisp     NUMBER;
      vtpropdisp     VARCHAR2(200);
      vfinicontrato  DATE;
      vffincontrato  DATE;
      vivaldisp      NUMBER;
      vtdesdisp      NUMBER;
      vncontrato     VARCHAR2(100);
   BEGIN
      IF vpmode = 'EST' THEN
         vtab := 'estautdisriesgos';
         vnmov := '';
      ELSIF vpmode = 'POL' THEN
         vtab := 'autdisriesgos';
         vnmov :=
            ' and nmovimi=(SELECT MAX (nmovimi)
FROM   autdisriesgos
WHERE  sseguro = ' || vsolicit || ' AND  nriesgo = ' || pnriesgo || ')';
      END IF;

      squery :=
         'SELECT SSEGURO, NRIESGO, NMOVIMI, CVERSION, CDISPOSITIVO, CPROPDISP, FINICONTRATO, FFINCONTRATO, IVALDISP, TDESCDISP, NCONTRATO'
         || ' FROM ' || vtab || ' WHERE sseguro=' || vsolicit || ' AND NRIESGO=' || pnriesgo
         || vnmov || ' UNION ALL'
         || ' SELECT NULL,NULL,NULL,CVERSION,CDISPOSITIVO,CPROPDISP,NULL,NULL,IVALPUBL,NULL,NULL'
         || ' FROM AUT_DISPOSITIVOS'
         || ' WHERE cversion != 0 and  (CVERSION,CDISPOSITIVO) NOT IN (SELECT CVERSION,CDISPOSITIVO'
         || ' FROM ' || vtab || ' WHERE SSEGURO =' || vsolicit || ' AND NRIESGO =' || pnriesgo
         || vnmov || ')';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 2;

      LOOP
         FETCH cur
          INTO vsseguro, vnriesgo, vnmovimi, vcversion, vcdispositivo, vcpropdisp,
               vfinicontrato, vffincontrato, vivaldisp, vtdesdisp, vncontrato;

         -- BUG15824:DRA:07/09/2010
         EXIT WHEN cur%NOTFOUND;
         dispositius.EXTEND;
         dispositius(dispositius.LAST) := ob_iax_autdispositivos();
         --BUG 9247-24022009-XVM
         dispositius(dispositius.LAST).sseguro := vsseguro;
         dispositius(dispositius.LAST).nriesgo := vnriesgo;
         dispositius(dispositius.LAST).nmovimi := vnmovimi;
         dispositius(dispositius.LAST).cversion := vcversion;
         dispositius(dispositius.LAST).cdispositivo := vcdispositivo;

         BEGIN
            SELECT tdispositivo
              INTO dispositius(dispositius.LAST).tdispositivo
              FROM aut_dispositivos
             WHERE cversion = 0
               AND cdispositivo = vcdispositivo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               dispositius(dispositius.LAST).tdispositivo := '';
         END;

         dispositius(dispositius.LAST).cpropdisp := vcpropdisp;
         vtpropdisp := pac_md_listvalores.f_getdescripvalores(8000912, vcpropdisp, mensajes);
         dispositius(dispositius.LAST).tpropdisp := vtpropdisp;
         dispositius(dispositius.LAST).finicontrato := vfinicontrato;
         dispositius(dispositius.LAST).ffincontrato := vffincontrato;
         dispositius(dispositius.LAST).ivaldisp := vivaldisp;
         dispositius(dispositius.LAST).tdescdisp := vtdesdisp;
         dispositius(dispositius.LAST).cmarcado := 1;
         dispositius(dispositius.LAST).ncontrato := vncontrato;
      END LOOP;

      vpasexec := 3;

      CLOSE cur;

      RETURN dispositius;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leedispositivosauto;

/*************************************************************************
Recuperar la informacion del detalle de automoviles
parma in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto riesgo automoviles
*************************************************************************/
   FUNCTION f_leeriesgoauto(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autriesgos IS
      riesgauto      t_iax_autriesgos := t_iax_autriesgos();
      vtab           VARCHAR2(2000);
      vnmov          VARCHAR2(2000);
      squery         VARCHAR2(2000);
      vcversion      VARCHAR2(11);
      vctipmat       NUMBER;
      vcmatric       VARCHAR2(12);
      vccolor        NUMBER;
      vnbastid       VARCHAR2(20);
      vnplazas       NUMBER;
      vfcompra       DATE;
      vcuso          VARCHAR2(3);
      vcsubuso       VARCHAR2(2);
      vnpmarem       NUMBER;
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRiesgoAuto';
      vsseguro       NUMBER;
      vnriesgo       NUMBER(6);
      vtversion      VARCHAR2(100);
      vcmodelo       VARCHAR2(4);
      vtmodelo       VARCHAR2(100);
      vcmarca        VARCHAR2(100);
      vtmarca        VARCHAR2(100);
      vctipveh       VARCHAR2(100);
      vcclaveh       VARCHAR2(5);
      vtclaveh       VARCHAR2(100);
      vtuso          VARCHAR2(100);
      vtsubuso       VARCHAR2(100);
      vfmatric       DATE;
      vnkilometros   NUMBER(11);
      vtkilometros   VARCHAR2(100);
      vtcolor        VARCHAR2(100);
      vcvehnue       NUMBER(12);
      vivehicu       NUMBER(15, 4);
      vnpma          NUMBER(10, 3);
      vntara         NUMBER(10, 3);
      vcmotor        VARCHAR2(100);
      vtmotor        VARCHAR2(100);
      vcgaraje       NUMBER(3);
      vcremolque     NUMBER(3);
      vtriesgo       VARCHAR2(300);
      vtgaraje       VARCHAR2(100);
      vcvehb7        NUMBER(3);
      vcusorem       NUMBER(3);
      vtremdesc      VARCHAR2(100);
      vttipmat       VARCHAR2(100);
      vtremolque     VARCHAR2(100);
      vnpuertas      NUMBER(2);
      vcpaisorigen   NUMBER(3);   -- bug 0025143 -- ECP-- 17/12/2012
      vcchasis       VARCHAR2(100);
      -- bug 0025143 -- ECP-- 17/12/2012
      vivehinue      NUMBER(15, 4);
      -- bug 0025143 -- ECP-- 17/12/2012
      vnkilometraje  NUMBER(15, 4);
      -- bug 0025143 -- ECP-- 17/12/2012
      vccilindraje   VARCHAR2(150);
      -- bug 0025143 -- ECP-- 17/12/2012
      vcodmotor      VARCHAR2(100);
      -- bug 0025143 -- ECP-- 17/12/2012
      vcpintura      NUMBER(6);   -- bug 0025143 -- ECP-- 17/12/2012
      vccaja         NUMBER(5);   -- bug 0025143 -- ECP-- 17/12/2012
      vccampero      NUMBER(5);   -- bug 0025143 -- ECP-- 17/12/2012
      vctipcarroceria NUMBER(5);   -- bug 0025143 -- ECP-- 17/12/2012
      vcservicio     NUMBER(5);   -- bug 0025143 -- ECP-- 17/12/2012
      vcorigen       NUMBER(5);   -- bug 0025143 -- ECP-- 17/12/2012
      vctransporte   NUMBER(4);   -- bug 0025143 -- ECP-- 17/12/2012
      vanyo          NUMBER(4);
      vffinciant     DATE;
      vciaant        NUMBER;
      vmotorriesgo   VARCHAR2(100);
      vivehicufasecolda NUMBER(15, 4);
      -- bug 0025143 -- ECP-- 17/12/2012
      vivehicufasecoldanue NUMBER(15, 4);
      -- bug 0025143 -- ECP-- 17/12/2012
      vcmodalidad    VARCHAR2(10);
      -- BUG: 0027953/0151258 - JSV 21/08/2013
      vcpeso         NUMBER;   --BUG 030256/166723 - 20/02/2014 - RCL
      vctransmision  NUMBER;   --BUG 030256/166723 - 20/02/2014 - RCL
   BEGIN
      IF vpmode = 'EST' THEN
         /*  vtab :=
         ' ESTAUTRIESGOS RIE, AUT_DESCLAVEH DCLA, AUT_MODELOS AMOD, AUT_MARCAS MAR, AUT_VERSIONES VER, AUT_DESUSO USO, AUT_DESSUBUSO SUBU ';*/
         vtab := ' ESTAUTRIESGOS RIE, AUT_VERSIONES VER';
         vnmov :=
            ' and rie.cversion = ver.cversion and nmovimi= (SELECT MAX (nmovimi) FROM estautriesgos WHERE sseguro = '
            || vsolicit || ' AND nriesgo = ' || pnriesgo || ')';   --vnmovimi|| ' and ';
      ELSIF vpmode = 'POL' THEN
         /*  vtab :=
         ' AUTRIESGOS RIE, AUT_DESCLAVEH DCLA, AUT_MODELOS AMOD, AUT_MARCAS MAR, AUT_VERSIONES VER, AUT_DESUSO USO, AUT_DESSUBUSO SUBU ';*/
         vtab := ' AUTRIESGOS RIE, AUT_VERSIONES VER  ';
         vnmov :=
            ' and rie.cversion = ver.cversion and nmovimi= (SELECT MAX (nmovimi) FROM autriesgos WHERE sseguro = '
            || vsolicit || ' AND nriesgo = ' || pnriesgo || ')';   --vnmovimi|| ' and ';
      END IF;

      squery :=
         'SELECT rie.sseguro, rie.nriesgo, rie.cversion, rie.ctipmat, rie.cmatric, '
         || 'rie.nbastid, rie.nplazas,  rie.cvehnue, rie.cuso, '
         || 'rie.csubuso,  rie.fmatric, rie.nkilometros, rie.ivehicu, '
         || 'rie.npma, rie.ntara, rie.ccolor, rie.cgaraje, rie.cusorem, rie.cremolque,rie.triesgo'
         || ', ver.cmodelo, '
         || 'ver.cmarca, ver.ctipveh, ver.cclaveh, ver.cmotor, rie.npuertas,'
         || ' rie.cpaisorigen, rie.cchasis,rie.ivehinue, rie.nkilometraje, rie.ccilindraje, '
         || ' rie.codmotor, rie.cpintura, rie.ccaja, rie.ccampero,rie.ctipcarroceria, rie.cservicio, rie.corigen,rie.ctransporte, rie.anyo,rie.cmotor motorriesgo, '
         --BUG: 0027953/0151258 - JSV 21/08/2013
         || ' rie.ffinciant, rie.ciaant, rie.cmodalidad, rie.cpeso, rie.ctransmision '
         || ' FROM ' || vtab   --BUG 030256/166723 - 20/02/2014 - RCL
                            || ' WHERE sseguro=' || vsolicit || ' and nriesgo=' || pnriesgo
         || vnmov;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 2;

      LOOP
         FETCH cur
          INTO vsseguro, vnriesgo, vcversion, vctipmat, vcmatric, vnbastid, vnplazas,
               vcvehnue, vcuso, vcsubuso, vfmatric, vnkilometros, vivehicu, vnpma, vntara,
               vccolor, vcgaraje, vcusorem, vcremolque, vtriesgo, vcmodelo, vcmarca, vctipveh,
               vcclaveh, vcmotor, vnpuertas, vcpaisorigen, vcchasis, vivehinue, vnkilometraje,
               vccilindraje, vcodmotor, vcpintura, vccaja, vccampero, vctipcarroceria,
               vcservicio, vcorigen, vctransporte, vanyo, vmotorriesgo, vffinciant, vciaant,

               --BUG: 0027953/0151258 - JSV 21/08/2013
               vcmodalidad, vcpeso, vctransmision;

         --BUG 030256/166723 - 20/02/2014 - RCL
         EXIT WHEN cur%NOTFOUND;
         vpasexec := 3;
         riesgauto.EXTEND;
         riesgauto(riesgauto.LAST) := ob_iax_autriesgos();
         riesgauto(riesgauto.LAST).sseguro := vsseguro;
         vpasexec := 4;
         riesgauto(riesgauto.LAST).nriesgo := vnriesgo;
         riesgauto(riesgauto.LAST).cversion := vcversion;
         riesgauto(riesgauto.LAST).tversion := pac_autos.f_desversion(vcversion);
         riesgauto(riesgauto.LAST).cmodelo := vcmodelo;
         riesgauto(riesgauto.LAST).tmodelo := pac_autos.f_desmodelo(vcmodelo, vcmarca);
         riesgauto(riesgauto.LAST).cmarca := vcmarca;
         riesgauto(riesgauto.LAST).tmarca := pac_autos.f_desmarca(vcmarca);
         riesgauto(riesgauto.LAST).ctipveh := vctipveh;
         vpasexec := 5;
         riesgauto(riesgauto.LAST).ttipveh :=
                                pac_autos.f_destipveh(vctipveh, pac_md_common.f_get_cxtidioma);
         riesgauto(riesgauto.LAST).cclaveh := vcclaveh;

         IF vcclaveh IS NOT NULL THEN
            riesgauto(riesgauto.LAST).tclaveh :=
                                pac_autos.f_desclaveh(vcclaveh, pac_md_common.f_get_cxtidioma);
         END IF;

         riesgauto(riesgauto.LAST).ctipmat := vctipmat;
         vttipmat := pac_md_listvalores.f_getdescripvalores(290, vctipmat, mensajes);
         riesgauto(riesgauto.LAST).ttipmat := vttipmat;
         riesgauto(riesgauto.LAST).cmatric := vcmatric;
         riesgauto(riesgauto.LAST).cuso := vcuso;
         riesgauto(riesgauto.LAST).tuso := pac_autos.f_desuso(vcuso,
                                                              pac_md_common.f_get_cxtidioma);
         riesgauto(riesgauto.LAST).csubuso := vcsubuso;
         riesgauto(riesgauto.LAST).tsubuso :=
                                    pac_autos.f_dessubuso(vcuso, pac_md_common.f_get_cxtidioma);
         riesgauto(riesgauto.LAST).fmatric := vfmatric;
         riesgauto(riesgauto.LAST).nkilometros := vnkilometros;
         vtkilometros := pac_md_listvalores.f_getdescripvalores(295, vnkilometros, mensajes);
         riesgauto(riesgauto.LAST).tkilometros := vtkilometros;
         riesgauto(riesgauto.LAST).cvehnue := vcvehnue;
         riesgauto(riesgauto.LAST).ivehicu := vivehicu;
         riesgauto(riesgauto.LAST).npma := vnpma;
         riesgauto(riesgauto.LAST).ntara := vntara;
         -- Ini Bug 252020 -- ECP-- 21/02/2013
         riesgauto(riesgauto.LAST).cpeso := vcpeso;
         --BUG 030256/166723 - 20/02/2014 - RCL
         riesgauto(riesgauto.LAST).tpeso :=
            pac_autos.f_despeso(pac_iax_produccion.poliza.det_poliza.sproduc, vcpeso,
                                pac_md_common.f_get_cxtidioma);   --BUG 030256/166723 - 20/02/2014 - RCL
         -- Fin Bug 252020 -- ECP-- 21/02/2013
         riesgauto(riesgauto.LAST).ccolor := vccolor;
         vtcolor := pac_md_listvalores.f_getdescripvalores(440, vccolor, mensajes);
         riesgauto(riesgauto.LAST).tcolor := vtcolor;
         riesgauto(riesgauto.LAST).nbastid := vnbastid;
         riesgauto(riesgauto.LAST).nplazas := vnplazas;
         riesgauto(riesgauto.LAST).cmotor := NVL(vmotorriesgo, vcmotor);
         vtmotor := pac_md_listvalores.f_getdescripvalores(291, NVL(vmotorriesgo, vcmotor),
                                                           mensajes);
         riesgauto(riesgauto.LAST).tmotor := vtmotor;
         riesgauto(riesgauto.LAST).cgaraje := vcgaraje;
         vtgaraje := pac_md_listvalores.f_getdescripvalores(296, vcgaraje, mensajes);
         riesgauto(riesgauto.LAST).tgaraje := vtgaraje;
         riesgauto(riesgauto.LAST).cvehb7 := vcvehb7;
         riesgauto(riesgauto.LAST).cusorem := vcusorem;
         riesgauto(riesgauto.LAST).cremolque := vcremolque;
         riesgauto(riesgauto.LAST).triesgo := vtriesgo;
         vtremolque := pac_md_listvalores.f_getdescripvalores(297, vcremolque, mensajes);
         riesgauto(riesgauto.LAST).tremdesc := vtremolque;
         riesgauto(riesgauto.LAST).accesorios := f_leeaccesoriosauto(vnriesgo, mensajes);
         riesgauto(riesgauto.LAST).dispositivos := f_leedispositivosauto(vnriesgo, mensajes);
         riesgauto(riesgauto.LAST).conductores := f_leeconductores(vnriesgo, mensajes);
         riesgauto(riesgauto.LAST).npuertas := vnpuertas;
         --BUG 030256/166723 - 20/02/2014 - RCL
         -- DRA:08/10/2009: Va sortir en una demo i aprofito per arreglar-ho
         riesgauto(riesgauto.LAST).cpaisorigen := vcpaisorigen;

         IF vcpaisorigen IS NOT NULL THEN
            riesgauto(riesgauto.LAST).tpaisorigen :=
                                     ff_despais(vcpaisorigen, pac_md_common.f_get_cxtidioma());
         END IF;

         riesgauto(riesgauto.LAST).codmotor := vcodmotor;
         riesgauto(riesgauto.LAST).cchasis := vcchasis;
         riesgauto(riesgauto.LAST).ivehinue := vivehinue;
         riesgauto(riesgauto.LAST).nkilometraje := vnkilometraje;
         riesgauto(riesgauto.LAST).ccilindraje := vccilindraje;
         riesgauto(riesgauto.LAST).cpintura := vcpintura;

         IF vcpintura IS NOT NULL THEN
            riesgauto(riesgauto.LAST).tpintura :=
                                ff_desvalorfijo(760, pac_md_common.f_get_cxtidioma, vcpintura);
         END IF;

         riesgauto(riesgauto.LAST).ccaja := vccaja;

         IF vccaja IS NOT NULL THEN
            riesgauto(riesgauto.LAST).tcaja := ff_desvalorfijo(8000907,
                                                               pac_md_common.f_get_cxtidioma,
                                                               vccaja);
         END IF;

         riesgauto(riesgauto.LAST).ccampero := vccampero;

         IF vccampero IS NOT NULL THEN
            riesgauto(riesgauto.LAST).tcampero :=
                                ff_desvalorfijo(758, pac_md_common.f_get_cxtidioma, vccampero);
         END IF;

         riesgauto(riesgauto.LAST).ctipcarroceria := vctipcarroceria;

         IF vctipcarroceria IS NOT NULL THEN
            riesgauto(riesgauto.LAST).ttipcarroceria :=
                          ff_desvalorfijo(761, pac_md_common.f_get_cxtidioma, vctipcarroceria);
         END IF;

         riesgauto(riesgauto.LAST).cservicio := vcservicio;

         IF vcservicio IS NOT NULL THEN
            riesgauto(riesgauto.LAST).tservicio :=
                           ff_desvalorfijo(8000904, pac_md_common.f_get_cxtidioma, vcservicio);
         END IF;

         riesgauto(riesgauto.LAST).corigen := vcorigen;

         IF vcorigen IS NOT NULL THEN
            riesgauto(riesgauto.LAST).torigen :=
                             ff_desvalorfijo(8000905, pac_md_common.f_get_cxtidioma, vcorigen);
         END IF;

         riesgauto(riesgauto.LAST).ctransporte := vctransporte;

         IF vctransporte IS NOT NULL THEN
            riesgauto(riesgauto.LAST).ttransporte :=
                             ff_desvalorfijo(307, pac_md_common.f_get_cxtidioma, vctransporte);
         END IF;

         IF vcversion IS NOT NULL
            AND vanyo IS NOT NULL THEN
            BEGIN
               SELECT vcomercial,
                      (SELECT vcomercial
                         FROM aut_versiones_anyo d
                        WHERE d.cversion = vcversion
                          AND anyo = (SELECT MAX(anyo)
                                        FROM aut_versiones_anyo d
                                       WHERE d.cversion = vcversion)) nuevo
                 INTO vivehicufasecolda,
                      vivehicufasecoldanue
                 FROM aut_versiones_anyo
                WHERE cversion = vcversion
                  AND anyo = vanyo;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         riesgauto(riesgauto.LAST).ivehicufasecolda := vivehicufasecolda;
         riesgauto(riesgauto.LAST).ivehicufasecoldanue := vivehicufasecoldanue;
         riesgauto(riesgauto.LAST).anyo := vanyo;
         riesgauto(riesgauto.LAST).ffinciant := vffinciant;
         riesgauto(riesgauto.LAST).ciaant := vciaant;
         riesgauto(riesgauto.LAST).ttara := '';   --todo
         --BUG: 0027953/0151258 - JSV 21/08/2013 - INI
         riesgauto(riesgauto.LAST).cmodalidad := vcmodalidad;
         riesgauto(riesgauto.LAST).ctransmision := vctransmision;

         --BUG 030256/166723 - 20/02/2014 - RCL
         IF vcmodalidad IS NOT NULL THEN
            BEGIN
               SELECT tmodalidad
                 INTO riesgauto(riesgauto.LAST).tmodalidad
                 FROM aut_desmodalidad
                WHERE cmodalidad LIKE vcmodalidad
                  AND cidioma = pac_md_common.f_get_cxtidioma;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;
      --BUG: 0027953/0151258 - JSV 21/08/2013 - FIN
      END LOOP;

      vpasexec := 3;

      CLOSE cur;

      RETURN riesgauto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leeriesgoauto;

/* Recupera informacion del detalle riesgo automovil -->> */
/*************************************************************************
Recuperar la informacion de los conductores
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto conductores
*************************************************************************/
   FUNCTION f_leeconductores(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autconductores IS
      conduct        t_iax_autconductores := t_iax_autconductores();
      vtab           VARCHAR2(2000);
      vnmov          VARCHAR2(2000);
      squery         VARCHAR2(2000);
      vnorden        NUMBER;
      vsperson       NUMBER;
      vfnacimi       DATE;
      vcsexo         NUMBER;
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeConductores';
      vsseguro       NUMBER;
      vnriesgo       NUMBER(6);
      vnmovimi       NUMBER(4);
      vfcarnet       DATE;
      vnpuntos       NUMBER(2);
      vexper_manual  NUMBER;
      vexper_cexper  NUMBER;
      vexper_sinie   NUMBER;
      vexper_sinie_manual NUMBER;
      vtsexo         VARCHAR2(100);
      vnumerr        NUMBER(10);
      vcagente       NUMBER;
      vcdomici       NUMBER(2);
      -- Bug 25368/133447 - 08/01/2013 - AMC
      vcprincipal    NUMBER(1);
      -- Bug 25368/135191 - 15/01/2013 - AMC
      -- Bug 18225 - APD - 11/04/2011 - la precision debe ser NUMBER
      direccion      ob_iax_direcciones := ob_iax_direcciones();
   BEGIN
      IF vpmode = 'EST' THEN
         vtab := 'ESTAUTCONDUCTORES';
         vnmov := '';
      ELSIF vpmode = 'POL' THEN
         vtab := 'AUTCONDUCTORES';
         vnmov :=
            'and nmovimi=(SELECT MAX (nmovimi)
FROM   autconductores
WHERE  sseguro = ' || vsolicit || '       AND    nriesgo = ' || pnriesgo || ')';
      --vnmovimi|| ' and ';
      END IF;

      -- Bug 25368/133447 - 08/01/2013 - AMC
      -- Bug 25368/135191 - 15/01/2013 - AMC
      squery :=
         'SELECT SSEGURO,NRIESGO, NMOVIMI, NORDEN, SPERSON, FNACIMI, CSEXO, FCARNET, NPUNTOS, CDOMICI, CPRINCIPAL, EXPER_MANUAL, EXPER_CEXPER, EXPER_SINIE, EXPER_SINIE_MANUAL '
         || ' FROM ' || vtab || ' WHERE sseguro=' || vsolicit || ' and ' ||
                                                                            --vnmov||
         '       nriesgo=' || pnriesgo || vnmov;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 2;

      LOOP
         FETCH cur
          INTO vsseguro, vnriesgo, vnmovimi, vnorden, vsperson, vfnacimi, vcsexo, vfcarnet,
               vnpuntos, vcdomici, vcprincipal, vexper_manual, vexper_cexper, vexper_sinie,
               vexper_sinie_manual;

         EXIT WHEN cur%NOTFOUND;
         conduct.EXTEND;
         conduct(conduct.LAST) := ob_iax_autconductores();
         --BUG 9247-24022009-XVM
         conduct(conduct.LAST).sseguro := vsseguro;
         conduct(conduct.LAST).nriesgo := vnriesgo;
         conduct(conduct.LAST).nmovimi := vnmovimi;
         conduct(conduct.LAST).norden := vnorden;
         conduct(conduct.LAST).sperson := vsperson;
         conduct(conduct.LAST).fnacimi := vfnacimi;
         conduct(conduct.LAST).fcarnet := vfcarnet;
         conduct(conduct.LAST).csexo := vcsexo;
         vtsexo := pac_md_listvalores.f_getdescripvalores(11, vcsexo, mensajes);
         conduct(conduct.LAST).tsexo := vtsexo;
         conduct(conduct.LAST).npuntos := vnpuntos;
         vnumerr := pac_seguros.f_get_cagente(vsseguro, vpmode, vcagente);
         conduct(conduct.LAST).persona := ob_iax_personas();

         -- BUG17255:DRA:27/07/2011:Inici
         IF vsperson IS NOT NULL THEN
            vnumerr := pac_md_persona.f_get_persona_agente(vsperson, vcagente, vpmode,
                                                           conduct(conduct.LAST).persona,
                                                           mensajes);
         END IF;

         -- BUG17255:DRA:27/07/2011:Fi
         --BUG 9247-24022009-XVM
         conduct(conduct.LAST).cdomici := vcdomici;

         -- Bug 26923/146932 - 18/06/2013 - AMC
         IF vcdomici IS NOT NULL THEN
            vnumerr := pac_md_persona.f_get_direccion(vsperson, vcdomici, direccion, mensajes,
                                                      vpmode);
            conduct(conduct.LAST).tdomici := direccion.tdomici || ', ' || direccion.tpoblac
                                             || ', ' || direccion.tprovin;
         END IF;

         -- Fi Bug 26923/146932 - 18/06/2013 - AMC
         conduct(conduct.LAST).cprincipal := vcprincipal;
         conduct(conduct.LAST).exper_manual := vexper_manual;
         conduct(conduct.LAST).exper_cexper := vexper_cexper;
         conduct(conduct.LAST).exper_sinie := vexper_sinie;
         conduct(conduct.LAST).exper_sinie_manual := vexper_sinie_manual;
      END LOOP;

      -- Fi Bug 25368/133447 - 08/01/2013 - AMC
      -- Fi Bug 25368/135191 - 15/01/2013 - AMC
      vpasexec := 3;

      CLOSE cur;

      RETURN conduct;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leeconductores;

/*************************************************************************
Recuperar la informacion de accesorios en el riesgo automoviles
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leeaccesoriosauto(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autaccesorios IS
      accesoris      t_iax_autaccesorios := t_iax_autaccesorios();
      vtab           VARCHAR2(2000);
      vnmov          VARCHAR2(2000);
      squery         VARCHAR2(2000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeAccesoriosAuto';
      vsseguro       NUMBER;
      vnriesgo       NUMBER(6);
      vnmovimi       NUMBER(4);
      vcversion      VARCHAR2(11);
      vcaccesorio    VARCHAR2(10);
      vctipacc       VARCHAR2(8);
      vttipacc       VARCHAR2(100);
      vfini          DATE;
      vivalacc       NUMBER;
      vtdesacc       VARCHAR2(100);
      vcmarcado      NUMBER(1);   -- BUG15824:DRA:07/09/2010
      vcasegurable   NUMBER;
   BEGIN
      IF vpmode = 'EST' THEN
         vtab := 'ESTAUTDETRIESGOS';
         vnmov := '';
      ELSIF vpmode = 'POL' THEN
         vtab := 'AUTDETRIESGOS';
         vnmov :=
            ' and nmovimi=(SELECT MAX (nmovimi)
FROM   autdetriesgos
WHERE  sseguro = ' || vsolicit || ' AND  nriesgo = ' || pnriesgo || ')';
      END IF;

      squery :=
         'SELECT SSEGURO, NRIESGO, NMOVIMI, CVERSION, CACCESORIO, CTIPACC, FINI, IVALACC, TDESACC, 1 CMARCADO,CASEGURABLE'
         || ' FROM ' || vtab || ' WHERE sseguro=' || vsolicit || ' AND NRIESGO=' || pnriesgo
         || vnmov || ' UNION ALL'
         || ' SELECT NULL,NULL,NULL,CVERSION,CACCESORIO,NULL,FINICIO,IVALPUBL,TACCESORIO, 0 CMARCADO,0 CASEGURABLE'
         || ' FROM AUT_ACCESORIOS'
         || ' WHERE cversion != 0 and  (CVERSION,CACCESORIO) NOT IN (SELECT CVERSION,CACCESORIO'
         || ' FROM ' || vtab || ' WHERE SSEGURO =' || vsolicit || ' AND NRIESGO =' || pnriesgo
         || vnmov || ')';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 2;

      LOOP
         FETCH cur
          INTO vsseguro, vnriesgo, vnmovimi, vcversion, vcaccesorio, vctipacc, vfini,
               vivalacc, vtdesacc, vcmarcado, vcasegurable;

         -- BUG15824:DRA:07/09/2010
         EXIT WHEN cur%NOTFOUND;
         accesoris.EXTEND;
         accesoris(accesoris.LAST) := ob_iax_autaccesorios();
         --BUG 9247-24022009-XVM
         accesoris(accesoris.LAST).sseguro := vsseguro;
         accesoris(accesoris.LAST).nriesgo := vnriesgo;
         accesoris(accesoris.LAST).nmovimi := vnmovimi;
         accesoris(accesoris.LAST).cversion := vcversion;
         accesoris(accesoris.LAST).caccesorio := vcaccesorio;

         BEGIN
            SELECT taccesorio
              INTO accesoris(accesoris.LAST).taccesorio
              FROM aut_accesorios
             WHERE cversion = 0
               AND caccesorio = vcaccesorio;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               accesoris(accesoris.LAST).taccesorio := '';
         END;

         accesoris(accesoris.LAST).ctipacc := vctipacc;
         vttipacc := pac_md_listvalores.f_getdescripvalores(292, vctipacc, mensajes);
         accesoris(accesoris.LAST).ttipacc := vttipacc;
         accesoris(accesoris.LAST).fini := vfini;
         accesoris(accesoris.LAST).ivalacc := vivalacc;
         accesoris(accesoris.LAST).tdesacc := vtdesacc;
         accesoris(accesoris.LAST).cmarcado := vcmarcado;
         accesoris(accesoris.LAST).casegurable := vcasegurable;
      -- BUG15824:DRA:07/09/2010
      --BUG 9247-24022009-XVM
      END LOOP;

      vpasexec := 3;

      CLOSE cur;

      RETURN accesoris;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leeaccesoriosauto;

/*    Recuperar la informacion del riesgo descripcion
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leeriesgodescripcion(pnriesgo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_descripcion IS
      descr          ob_iax_descripcion := ob_iax_descripcion();
      nnum           NUMBER;
      cur            sys_refcursor;
      estrie         estriesgos%ROWTYPE;
      polrie         riesgos%ROWTYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRiesgoDescripcion';
   BEGIN
      cur := f_getcurriesgo(pnriesgo);

      IF vpmode = 'EST' THEN
         LOOP
            FETCH cur
             INTO estrie;

            EXIT WHEN cur%NOTFOUND;
            vpasexec := 3;
            descr.nasegur := estrie.nasegur;
            descr.nedacol := estrie.nedacol;
            descr.csexcol := estrie.csexcol;
         END LOOP;
      ELSE
         LOOP
            FETCH cur
             INTO polrie;

            EXIT WHEN cur%NOTFOUND;
            vpasexec := 3;
            descr.nasegur := polrie.nasegur;
            descr.nedacol := polrie.nedacol;
            descr.csexcol := polrie.csexcol;
         END LOOP;
      END IF;

      CLOSE cur;

      RETURN descr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leeriesgodescripcion;

/* <<-- Recupera informacion del detalle riesgo automovil */
/* <<-- Recupera informacion del riesgo */
/*************************************************************************
Recuperar la informacion de los meses que tienen paga extra
param in psseguro  : n?mero de seguro
param out mensajes : mensajes de error
return             : objeto detalle meses paga extra
*************************************************************************/
   FUNCTION f_leermesesextra(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_nmesextra IS
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leermesesextra';
      pagas          ob_iax_nmesextra := ob_iax_nmesextra();
      vmesesextra    VARCHAR2(24);
      wimesosextra   VARCHAR2(500);
      num_err        NUMBER;
   --
   BEGIN
      vpasexec := 10;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_seguros.f_get_nmesextra(psseguro, vmesesextra);
      vpasexec := 20;

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RETURN NULL;
      END IF;

      IF vmesesextra IS NOT NULL THEN
         vpasexec := 30;
         num_err := pac_prod_rentas.f_leer_nmesextra(vmesesextra, pagas.nmes1, pagas.nmes2,
                                                     pagas.nmes3, pagas.nmes4, pagas.nmes5,
                                                     pagas.nmes6, pagas.nmes7, pagas.nmes8,
                                                     pagas.nmes9, pagas.nmes10, pagas.nmes11,
                                                     pagas.nmes12);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RETURN NULL;
         END IF;
      ELSE
         vpasexec := 50;
         RETURN NULL;
      END IF;

      -- Bug 24735.NMM.25.02.2013.i.
      num_err := pac_seguros.f_get_imesextra(psseguro, wimesosextra);
      vpasexec := 40;

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RETURN NULL;
      END IF;

      IF wimesosextra IS NOT NULL THEN
         vpasexec := 50;
         num_err := pac_prod_rentas.f_leer_imesextra(wimesosextra, pagas.imp_nmes1,
                                                     pagas.imp_nmes2, pagas.imp_nmes3,
                                                     pagas.imp_nmes4, pagas.imp_nmes5,
                                                     pagas.imp_nmes6, pagas.imp_nmes7,
                                                     pagas.imp_nmes8, pagas.imp_nmes9,
                                                     pagas.imp_nmes10, pagas.imp_nmes11,
                                                     pagas.imp_nmes12);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RETURN NULL;
         END IF;
      ELSE
         vpasexec := 60;
         RETURN NULL;
      END IF;

      -- Bug 24735.NMM.25.02.2013.f.
      vpasexec := 70;
      RETURN pagas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leermesesextra;

/*************************************************************************
Nos devuelve si un producto permite modificar las pagas extras en la poliza
param in psproduc  : n¿mero de producto
param out mensajes : mesajes de error
return             : el campo cmodextra
*************************************************************************/
   FUNCTION f_leer_cmodextra(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leer_cmodextra';
      vcmodextra     NUMBER;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT NVL(cmodextra, 0)
        INTO vcmodextra
        FROM producto_ren
       WHERE sproduc = psproduc;

      RETURN vcmodextra;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leer_cmodextra;

/*************************************************************************
Recuperar la informacion de los meses que tienen paga extra de un producto
param in psproduc  : n?mero de producto
param out mensajes : mesajes de error
return             : objeto detalle meses paga extra
*************************************************************************/
   FUNCTION f_leermesesextrapro(
      psproduc IN NUMBER,
      pcmodextra OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_nmesextra IS
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(100) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leermesesextrapro';
      pagas          ob_iax_nmesextra := ob_iax_nmesextra();
      vmesesextra    VARCHAR2(24);
      wimesosextra   VARCHAR2(500);
      num_err        NUMBER;
   BEGIN
      vpasexec := 10;

      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 20;
      num_err := pac_productos.f_get_mesesextra(psproduc, vmesesextra, pcmodextra);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RETURN NULL;
      END IF;

      vpasexec := 30;
      num_err := pac_prod_rentas.f_leer_nmesextra(vmesesextra, pagas.nmes1, pagas.nmes2,
                                                  pagas.nmes3, pagas.nmes4, pagas.nmes5,
                                                  pagas.nmes6, pagas.nmes7, pagas.nmes8,
                                                  pagas.nmes9, pagas.nmes10, pagas.nmes11,
                                                  pagas.nmes12);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RETURN NULL;
      END IF;

      -- Bug 24735.NMM.25.02.2013.i.
      vpasexec := 40;
      num_err := pac_productos.f_get_imesextra(psproduc, wimesosextra, pcmodextra);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RETURN NULL;
      END IF;

      vpasexec := 50;
      num_err := pac_prod_rentas.f_leer_imesextra(wimesosextra, pagas.imp_nmes1,
                                                  pagas.imp_nmes2, pagas.imp_nmes3,
                                                  pagas.imp_nmes4, pagas.imp_nmes5,
                                                  pagas.imp_nmes6, pagas.imp_nmes7,
                                                  pagas.imp_nmes8, pagas.imp_nmes9,
                                                  pagas.imp_nmes10, pagas.imp_nmes11,
                                                  pagas.imp_nmes12);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RETURN NULL;
      END IF;

      -- Bug 24735.NMM.25.02.2013.f.
      vpasexec := 60;
      RETURN pagas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leermesesextrapro;

/*************************************************************************
Lee distribucion (Especifico de Financieros de inversion - FINV)
param out mensajes : mesajes de error
return             : objeto clausulas
*************************************************************************/
-- Bug 9031 - 17/03/2009 - RSC -  iAxis: Analisis adaptacion productos indexados
-- Bug 10385 - 14/07/2009 - AMC - Se a¿ade el parametro psseguro, si viene a null se coge el vsolicit
   FUNCTION f_leedistribucionfinv(
      mensajes IN OUT t_iax_mensajes,
      psseguro IN NUMBER DEFAULT NULL)
      RETURN ob_iax_produlkmodelosinv IS
      CURSOR c_estdistr IS
         SELECT s1.*, f.ccodfon, f.tfonabv
           FROM estsegdisin2 s1, fondos f
          WHERE s1.sseguro = NVL(psseguro, vsolicit)
            AND s1.ccesta = f.ccodfon
            AND s1.ffin IS NULL;

      CURSOR c_distr IS
         SELECT s1.*, f.ccodfon, f.tfonabv
           FROM segdisin2 s1, fondos f
          WHERE s1.sseguro = NVL(psseguro, vsolicit)
            AND s1.ffin IS NULL
            AND s1.ccesta = f.ccodfon
            AND s1.nmovimi = (SELECT MAX(s2.nmovimi)
                                FROM segdisin2 s2
                               WHERE s2.sseguro = s1.sseguro
                                 AND s2.ffin IS NULL);

      /*  cursor c_modinvfondo IS
      SELECT s.*, mif.CCODFON, f.TFONABV, 0 pinvers, '' as cmodabo  FROM MODINVFONDO mif, SEGUROS s, SEGUROS_ULK su, fondos f  WHERE mif.CCODFON NOT IN (
      SELECT  f.ccodfon
      FROM estsegdisin2 s1, fondos f
      WHERE s1.sseguro = NVL(psseguro, vsolicit) AND
      s1.ccesta = f.ccodfon
      AND s1.ffin IS NULL
      UNION
      SELECT  f.ccodfon
      FROM segdisin2 s1, fondos f
      WHERE s1.sseguro = NVL(psseguro, vsolicit) AND
      s1.ffin IS NULL
      AND s1.ccesta = f.ccodfon
      AND s1.nmovimi = (SELECT MAX(s2.nmovimi)
      FROM segdisin2 s2
      WHERE s2.sseguro = s1.sseguro
      AND s2.ffin IS NULL))
      AND f.CCODFON = mif.CCODFON
      AND mif.CMODINV = su.cmodinv
      AND mif.CCOLECT = s.CCOLECT
      AND mif.CRAMO = s.CRAMO
      AND mif.CTIPSEG = s.CTIPSEG
      AND mif.CMODALI = s.cmodali
      AND su.sseguro = s.sseguro
      AND s.sseguro = NVL(psseguro, vsolicit);
      */
      distr          ob_iax_produlkmodelosinv := ob_iax_produlkmodelosinv();
      vcmodinv       seguros_ulk.cmodinv%TYPE;
      vtmodinv       codimodelosinversion.tmodinv%TYPE;
      n              NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leedistribucionFinv';
      vprovision     NUMBER := 0;
      vuniact        NUMBER := 0;
      vicestas       NUMBER := 0;
      vprovshw       NUMBER := 0;
      vuniactshw     NUMBER := 0;
      vicestasshw    NUMBER := 0;
      vnumerr        NUMBER;
      vsproduc       NUMBER;   -- Bug 36746/0211309 - APD - 17/09/2015
   BEGIN
      IF vpmode = 'SOL' THEN
         RETURN NULL;
      ELSIF vpmode = 'EST' THEN
         BEGIN
            SELECT cmodinv
              INTO vcmodinv
              FROM estseguros_ulk
             WHERE sseguro = NVL(psseguro, vsolicit);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN NULL;   -- Si no es FINV retornamos NULL y listo
         END;

         BEGIN
            -- Bug 10040 - RSC - 15/06/2009 - Ajustes productos PPJ Dinamico y Pla Estudiant
            -- Se introduce el ramo, etc en la consulta
            SELECT c.tmodinv, s.sproduc
              INTO vtmodinv, vsproduc
              FROM codimodelosinversion c, estseguros s
             WHERE c.cmodinv = vcmodinv
               AND c.cramo = s.cramo
               AND c.cmodali = s.cmodali
               AND c.ctipseg = s.ctipseg
               AND c.ccolect = s.ccolect
               AND s.sseguro = NVL(psseguro, vsolicit)
               AND c.cidioma = pac_md_common.f_get_cxtidioma;
         -- Fin Bug 10040
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN NULL;   -- Si no es FINV retornamos NULL y listo
         END;

         distr.cmodinv := vcmodinv;
         distr.tmodinv := vtmodinv;
         distr.modinvfondo := t_iax_produlkmodinvfondo();

         FOR regs IN c_estdistr LOOP
            distr.modinvfondo.EXTEND;
            distr.modinvfondo(distr.modinvfondo.LAST) := ob_iax_produlkmodinvfondo();
            distr.modinvfondo(distr.modinvfondo.LAST).ccodfon := regs.ccodfon;
            distr.modinvfondo(distr.modinvfondo.LAST).tcodfon := regs.tfonabv;
            distr.modinvfondo(distr.modinvfondo.LAST).pinvers := regs.pdistrec;
            distr.modinvfondo(distr.modinvfondo.LAST).cmodabo := regs.cmodabo;
            distr.modinvfondo(distr.modinvfondo.LAST).cobliga := 1;
            -- Bug 36746/0211309 - APD - 17/09/2015
            vnumerr :=
               pac_operativa_finv.f_cta_saldo_fondos_cesta
                                           (NVL(psseguro, vsolicit), TRUNC(f_sysdate),
                                            distr.modinvfondo(distr.modinvfondo.LAST).ccodfon,
                                            vuniact, vicestas, vprovision);

            IF NVL(pac_ctaseguro.f_tiene_ctashadow(NULL, vsproduc), 0) = 1 THEN
               vnumerr :=
                  pac_operativa_finv.f_cta_saldo_fondos_cesta_shw
                                           (NVL(psseguro, vsolicit), TRUNC(f_sysdate),
                                            distr.modinvfondo(distr.modinvfondo.LAST).ccodfon,
                                            vuniactshw, vicestasshw, vprovshw);

               IF NVL(vuniactshw, vuniact) < vuniact THEN
                  vuniact := vuniactshw;
               END IF;

               IF NVL(vicestasshw, vicestas) < vicestas THEN
                  vicestas := vicestasshw;
               END IF;
            END IF;

            distr.modinvfondo(distr.modinvfondo.LAST).nuniact := vuniact;
            distr.modinvfondo(distr.modinvfondo.LAST).ivalact := vicestas;
         -- fin Bug 36746/0211309 - APD - 17/09/2015
         END LOOP;
      ELSE
         BEGIN
            SELECT cmodinv
              INTO vcmodinv
              FROM seguros_ulk
             WHERE sseguro = NVL(psseguro, vsolicit);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN NULL;   -- Si no es FINV retornamos NULL y listo
         END;

         BEGIN
            -- Bug 10040 - RSC - 15/06/2009 - Ajustes productos PPJ Dinamico y Pla Estudiant
            -- Se introduce el ramo, etc en la consulta
            SELECT c.tmodinv, s.sproduc
              INTO vtmodinv, vsproduc
              FROM codimodelosinversion c, seguros s
             WHERE c.cmodinv = vcmodinv
               AND c.cramo = s.cramo
               AND c.cmodali = s.cmodali
               AND c.ctipseg = s.ctipseg
               AND c.ccolect = s.ccolect
               AND s.sseguro = NVL(psseguro, vsolicit)
               AND c.cidioma = pac_md_common.f_get_cxtidioma;
         -- Fin Bug 10040
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN NULL;   -- Si no es FINV retornamos NULL y listo
         END;

         distr.cmodinv := vcmodinv;
         distr.tmodinv := vtmodinv;
         distr.modinvfondo := t_iax_produlkmodinvfondo();

         FOR regs IN c_distr LOOP
            distr.modinvfondo.EXTEND;
            distr.modinvfondo(distr.modinvfondo.LAST) := ob_iax_produlkmodinvfondo();
            distr.modinvfondo(distr.modinvfondo.LAST).ccodfon := regs.ccodfon;
            distr.modinvfondo(distr.modinvfondo.LAST).tcodfon := regs.tfonabv;
            distr.modinvfondo(distr.modinvfondo.LAST).pinvers := regs.pdistrec;
            distr.modinvfondo(distr.modinvfondo.LAST).cmodabo := regs.cmodabo;
            distr.modinvfondo(distr.modinvfondo.LAST).cobliga := 1;
            -- Bug 36746/0211309 - APD - 17/09/2015
            vnumerr :=
               pac_operativa_finv.f_cta_saldo_fondos_cesta
                                           (NVL(psseguro, vsolicit), TRUNC(f_sysdate),
                                            distr.modinvfondo(distr.modinvfondo.LAST).ccodfon,
                                            vuniact, vicestas, vprovision);

            IF NVL(pac_ctaseguro.f_tiene_ctashadow(NULL, vsproduc), 0) = 1 THEN
               vnumerr :=
                  pac_operativa_finv.f_cta_saldo_fondos_cesta_shw
                                           (NVL(psseguro, vsolicit), TRUNC(f_sysdate),
                                            distr.modinvfondo(distr.modinvfondo.LAST).ccodfon,
                                            vuniactshw, vicestasshw, vprovshw);

               IF NVL(vuniactshw, vuniact) < vuniact THEN
                  vuniact := vuniactshw;
               END IF;

               IF NVL(vicestasshw, vicestas) < vicestas THEN
                  vicestas := vicestasshw;
               END IF;
            END IF;

            distr.modinvfondo(distr.modinvfondo.LAST).nuniact := vuniact;
            distr.modinvfondo(distr.modinvfondo.LAST).ivalact := vicestas;
         -- fin Bug 36746/0211309 - APD - 17/09/2015
         END LOOP;
      END IF;

      /*
      FOR regs IN c_modinvfondo LOOP
      distr.modinvfondo.EXTEND;
      distr.modinvfondo(distr.modinvfondo.LAST) := ob_iax_produlkmodinvfondo();
      distr.modinvfondo(distr.modinvfondo.LAST).ccodfon := regs.ccodfon;
      distr.modinvfondo(distr.modinvfondo.LAST).tcodfon := regs.tfonabv;
      distr.modinvfondo(distr.modinvfondo.LAST).pinvers := regs.pinvers;
      distr.modinvfondo(distr.modinvfondo.LAST).cmodabo := regs.cmodabo;
      distr.modinvfondo(distr.modinvfondo.LAST).cobliga := 0;
      END LOOP;
      */
      RETURN distr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leedistribucionfinv;

/*************************************************************************
Lee los datos de gestion
param out mensajes : mesajes de error
return             : objeto gestion
*************************************************************************/
   FUNCTION f_leedatosgarantias(
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pndetgar IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      psseguro IN NUMBER DEFAULT NULL)
      RETURN ob_iax_masdatosgar IS
      CURSOR estpoldetgar IS
         SELECT s.*
           FROM estdetgaranseg s, estgaranseg g
          WHERE s.sseguro = NVL(vsolicit, psseguro)
            AND s.nriesgo = pnriesgo
            AND s.cgarant = pcgarant
            AND s.ndetgar = pndetgar
            AND s.sseguro = g.sseguro
            AND s.nriesgo = g.nriesgo
            AND s.cgarant = g.cgarant
            AND s.nmovimi = g.nmovimi
            AND s.nmovimi = NVL(vnmovimi, 1)
            AND g.ffinefe IS NULL;

      CURSOR poldetgar IS
         SELECT s.*
           FROM detgaranseg s, garanseg g
          WHERE s.sseguro = NVL(vsolicit, psseguro)
            AND s.nriesgo = pnriesgo
            AND s.cgarant = pcgarant
            AND s.ndetgar = pndetgar
            AND s.sseguro = g.sseguro
            AND s.nriesgo = g.nriesgo
            AND s.cgarant = g.cgarant
            AND s.nmovimi = g.nmovimi
            AND g.nmovimi = (SELECT MAX(g2.nmovimi)
                               FROM garanseg g2
                              WHERE g2.sseguro = g.sseguro
                                AND g2.nriesgo = g.nriesgo
                                AND g2.cgarant = g.cgarant
                                AND g2.ffinefe IS NULL)
            AND g.ffinefe IS NULL;

      v_masdatos     ob_iax_masdatosgar := ob_iax_masdatosgar();
      v_sproduc      seguros.sproduc%TYPE;
      v_ndurcob      seguros.ndurcob%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_finiefe      garanseg.finiefe%TYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leedatosgarantias';
      v_tatribu      detvalores.tatribu%TYPE;
      v_res          NUMBER;
      v_iprianu      garanseg.iprianu%TYPE;
      v_icapital     garanseg.icapital%TYPE;
      v_ctarifa      garanseg.ctarifa%TYPE;
      v_ftarifa      garanseg.ftarifa%TYPE;
   BEGIN
      IF vpmode = 'EST' THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = NVL(vsolicit, psseguro);

         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
            FOR pmdatos IN estpoldetgar LOOP
               v_masdatos.ndetgar := pmdatos.ndetgar;
               v_masdatos.fefecto := pmdatos.fefecto;
               v_masdatos.fvencim := pmdatos.fvencim;
               v_masdatos.ndurcob := pmdatos.ndurcob;
               v_masdatos.ffincob := pmdatos.ffincob;
               v_masdatos.pinttec := pmdatos.pinttec;
               v_masdatos.pintmin := pmdatos.pintmin;
               v_masdatos.fprovt0 := pmdatos.fprovmat0;
               v_masdatos.iprovt0 := pmdatos.provmat0;
               v_masdatos.fprovt1 := pmdatos.fprovmat1;
               v_masdatos.iprovt1 := pmdatos.provmat1;
               -- Reducida / No reducida
               -- Bug 11232 - RSC - 23/10/2009 - APR - estado de las garantias ya pagadas
               v_masdatos.estado := pac_propio.f_garan_reducida(NVL(vsolicit, psseguro),
                                                                pmdatos.cgarant,
                                                                pmdatos.ndetgar, 'EST');

               -- Reducida / No reducida
               IF v_masdatos.estado = 1 THEN
                  v_res := f_desvalorfijo(61, pac_md_common.f_get_cxtidioma, 11, v_tatribu);
                  v_masdatos.testado := v_tatribu;
               ELSE
                  v_res := f_desvalorfijo(61, pac_md_common.f_get_cxtidioma, 9, v_tatribu);
                  v_masdatos.testado := v_tatribu;
               END IF;

               -- Fin Bug 11232
               v_masdatos.ctarifa := pmdatos.ctarifa;
               v_masdatos.ftarifa := pmdatos.ftarifa;
               -- Bug 10101 - RSC - 16/07/2009 - 0010101: APR - Detalle de garantias (Consulta de Polizas)
               v_masdatos.cunica := pmdatos.cunica;
               v_masdatos.cagente := pmdatos.cagente;
            -- Fin Bug 10101
            END LOOP;
         END IF;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = NVL(vsolicit, psseguro);

         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
            FOR pmdatos IN poldetgar LOOP
               v_masdatos.ndetgar := pmdatos.ndetgar;
               v_masdatos.fefecto := pmdatos.fefecto;
               v_masdatos.fvencim := pmdatos.fvencim;
               v_masdatos.ndurcob := pmdatos.ndurcob;
               v_masdatos.ffincob := pmdatos.ffincob;
               v_masdatos.pinttec := pmdatos.pinttec;
               v_masdatos.pintmin := pmdatos.pintmin;
               v_masdatos.fprovt0 := pmdatos.fprovmat0;
               v_masdatos.iprovt0 := pmdatos.provmat0;
               v_masdatos.fprovt1 := pmdatos.fprovmat1;
               v_masdatos.iprovt1 := pmdatos.provmat1;
               v_masdatos.estado := pac_propio.f_garan_reducida(NVL(vsolicit, psseguro),
                                                                pmdatos.cgarant,
                                                                pmdatos.ndetgar);

               -- Reducida / No reducida
               IF v_masdatos.estado = 1 THEN
                  v_res := f_desvalorfijo(61, pac_md_common.f_get_cxtidioma, 11, v_tatribu);
                  v_masdatos.testado := v_tatribu;
               ELSE
                  v_res := f_desvalorfijo(61, pac_md_common.f_get_cxtidioma, 9, v_tatribu);
                  v_masdatos.testado := v_tatribu;
               END IF;

               v_masdatos.ctarifa := pmdatos.ctarifa;
               v_masdatos.ftarifa := pmdatos.ftarifa;
               -- Bug 10101 - RSC - 16/07/2009 - 0010101: APR - Detalle de garantias (Consulta de Polizas)
               v_masdatos.cunica := pmdatos.cunica;
               v_masdatos.cagente := pmdatos.cagente;

               -- Fin Bug 10101
               -- Bug 10690 - RSC - 16/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
               -- Provision Actual a nivel de detalle
               BEGIN
                  v_masdatos.provmat :=
                     pac_provmat_formul.f_calcul_formulas_provi(NVL(vsolicit, psseguro),
                                                                TRUNC(f_sysdate), 'IPROVAC',
                                                                pcgarant, pmdatos.ndetgar);
               EXCEPTION
                  WHEN OTHERS THEN
                     v_masdatos.provmat := NULL;
               END;

               BEGIN
                  v_masdatos.ireducc :=
                     pac_provmat_formul.f_calcul_formulas_provi(NVL(vsolicit, psseguro),
                                                                TRUNC(f_sysdate), 'IREDUCC',
                                                                pcgarant, pmdatos.ndetgar);
               EXCEPTION
                  WHEN OTHERS THEN
                     v_masdatos.ireducc := NULL;
               END;
            -- Fin Bug 10690
            END LOOP;
         END IF;
      END IF;

      RETURN v_masdatos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leedatosgarantias;

/*************************************************************************
Bug 13884: CEM - Escut Total - Conversion a capital decreciente
Lee los datos de los del cuadro de prestamos
param out mensajes : mesajes de error
return             : objeto t_iax_prestcuadroseg
*************************************************************************/
   FUNCTION f_leeprestcuadroseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestcuadroseg IS
      CURSOR estseg IS
         SELECT d.*
           FROM estprestcuadroseg d
          WHERE d.sseguro = psseguro
            AND d.nmovimi = pnmovimi
            AND d.ctapres = pctapres;

      CURSOR polseg IS
         SELECT d.*
           FROM prestcuadroseg d
          WHERE d.sseguro = psseguro
            AND d.nmovimi = pnmovimi
            AND d.ctapres = pctapres;

      prestcuadroseg t_iax_prestcuadroseg := t_iax_prestcuadroseg();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leeprestcuadroseg';
   BEGIN
      IF vpmode = 'EST' THEN
         FOR eseg IN estseg LOOP
            prestcuadroseg.EXTEND;
            prestcuadroseg(prestcuadroseg.LAST) := ob_iax_prestcuadroseg();
            prestcuadroseg(prestcuadroseg.LAST).sseguro := eseg.sseguro;
            prestcuadroseg(prestcuadroseg.LAST).icapital := eseg.icapital;
            prestcuadroseg(prestcuadroseg.LAST).nmovimi := NVL(eseg.nmovimi, 1);
            prestcuadroseg(prestcuadroseg.LAST).ctapres := eseg.ctapres;
            prestcuadroseg(prestcuadroseg.LAST).finicuaseg := eseg.finicuaseg;
            prestcuadroseg(prestcuadroseg.LAST).ffincuaseg := eseg.ffincuaseg;
            prestcuadroseg(prestcuadroseg.LAST).fefecto := eseg.fefecto;
            prestcuadroseg(prestcuadroseg.LAST).fvencim := eseg.fvencim;
            prestcuadroseg(prestcuadroseg.LAST).iinteres := eseg.iinteres;
            prestcuadroseg(prestcuadroseg.LAST).icappend := eseg.icappend;
            prestcuadroseg(prestcuadroseg.LAST).falta := eseg.falta;
            prestcuadroseg(prestcuadroseg.LAST).icuota :=
                                                  NVL(eseg.icapital, 0)
                                                  + NVL(eseg.iinteres, 0);
         END LOOP;
      ELSE
         FOR pseg IN polseg LOOP
            prestcuadroseg.EXTEND;
            prestcuadroseg(prestcuadroseg.LAST) := ob_iax_prestcuadroseg();
            prestcuadroseg(prestcuadroseg.LAST).sseguro := pseg.sseguro;
            prestcuadroseg(prestcuadroseg.LAST).icapital := pseg.icapital;
            prestcuadroseg(prestcuadroseg.LAST).nmovimi := NVL(pseg.nmovimi, 1);
            prestcuadroseg(prestcuadroseg.LAST).ctapres := pseg.ctapres;
            prestcuadroseg(prestcuadroseg.LAST).finicuaseg := pseg.finicuaseg;
            prestcuadroseg(prestcuadroseg.LAST).ffincuaseg := pseg.ffincuaseg;
            prestcuadroseg(prestcuadroseg.LAST).fefecto := pseg.fefecto;
            prestcuadroseg(prestcuadroseg.LAST).fvencim := pseg.fvencim;
            prestcuadroseg(prestcuadroseg.LAST).iinteres := pseg.iinteres;
            prestcuadroseg(prestcuadroseg.LAST).icappend := pseg.icappend;
            prestcuadroseg(prestcuadroseg.LAST).falta := pseg.falta;
            prestcuadroseg(prestcuadroseg.LAST).icuota :=
                                                  NVL(pseg.icapital, 0)
                                                  + NVL(pseg.iinteres, 0);
         END LOOP;
      END IF;

      RETURN prestcuadroseg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeprestcuadroseg;

/*************************************************************************
Bug 10702 - Nueva pantalla para contratacion y suplementos que
permita seleccionar cuentas aseguradas. nova funcio XPL
Lee los datos de los saldos deutores
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
-- Bug 11165 - 16/09/2009 - AMC - Se sustitu¿e  T_iax_prestamoseg por t_iax_prestamoseg
   FUNCTION f_leesaldodeutors(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestamoseg IS
      CURSOR estseg IS
         SELECT s.icapmax icapmaxpol, d.*
           FROM estprestamoseg d, estsaldodeutorseg s
          WHERE d.sseguro = vsolicit
            AND d.nmovimi = (SELECT MAX(nmovimi)
                               FROM estprestamoseg es
                              WHERE es.sseguro = vsolicit)
            AND s.sseguro(+) = d.sseguro
            AND s.nmovimi(+) = d.nmovimi;

      CURSOR polseg IS
         SELECT s.icapmax icapmaxpol, d.*
           FROM prestamoseg d, saldodeutorseg s
          WHERE d.sseguro = vsolicit
            AND d.nmovimi = (SELECT MAX(nmovimi)
                               FROM prestamoseg es
                              WHERE es.sseguro = vsolicit)
            AND s.sseguro(+) = d.sseguro
            AND s.nmovimi(+) = d.nmovimi;

      prestamo       t_iax_prestamoseg := t_iax_prestamoseg();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_leesaldodeutors';
   BEGIN
      IF vpmode = 'EST' THEN
         FOR eseg IN estseg LOOP
            prestamo.EXTEND;
            prestamo(prestamo.LAST) := ob_iax_prestamoseg();
            prestamo(prestamo.LAST).sseguro := eseg.sseguro;
            prestamo(prestamo.LAST).icapmax := eseg.icapmax;
            prestamo(prestamo.LAST).nmovimi := NVL(eseg.nmovimi, 1);
            prestamo(prestamo.LAST).ctipcuenta := eseg.ctipcuenta;
            prestamo(prestamo.LAST).ttipcuenta :=
                        ff_desvalorfijo(401, pac_md_common.f_get_cxtidioma(), eseg.ctipcuenta);
            prestamo(prestamo.LAST).ctipban := eseg.ctipban;
            prestamo(prestamo.LAST).ttipban :=
                           ff_desvalorfijo(274, pac_md_common.f_get_cxtidioma(), eseg.ctipban);
            prestamo(prestamo.LAST).ctipimp := eseg.ctipimp;
            prestamo(prestamo.LAST).ttipimp :=
                           ff_desvalorfijo(402, pac_md_common.f_get_cxtidioma(), eseg.ctipimp);
            prestamo(prestamo.LAST).isaldo := eseg.isaldo;
            prestamo(prestamo.LAST).porcen := eseg.porcen;
            prestamo(prestamo.LAST).ilimite := eseg.ilimite;
            prestamo(prestamo.LAST).icapmax := eseg.icapmax;
            prestamo(prestamo.LAST).icapaseg := eseg.icapaseg;
            prestamo(prestamo.LAST).cmoneda := eseg.cmoneda;
            prestamo(prestamo.LAST).idcuenta := eseg.ctapres;
            prestamo(prestamo.LAST).selsaldo := 1;
            prestamo(prestamo.LAST).descripcion := eseg.descripcion;
            prestamo(prestamo.LAST).finiprest := eseg.finiprest;
            prestamo(prestamo.LAST).ffinprest := eseg.ffinprest;
            prestamo(prestamo.LAST).cuadro := f_leeprestcuadroseg(eseg.sseguro,
                                                                  NVL(eseg.nmovimi, 1),
                                                                  eseg.ctapres, mensajes);
         END LOOP;
      ELSE
         FOR pseg IN polseg LOOP
            prestamo.EXTEND;
            prestamo(prestamo.LAST) := ob_iax_prestamoseg();
            prestamo(prestamo.LAST).sseguro := pseg.sseguro;
            prestamo(prestamo.LAST).icapmax := pseg.icapmax;
            prestamo(prestamo.LAST).nmovimi := NVL(pseg.nmovimi, 1);
            prestamo(prestamo.LAST).ctipcuenta := pseg.ctipcuenta;
            prestamo(prestamo.LAST).ttipcuenta :=
                        ff_desvalorfijo(401, pac_md_common.f_get_cxtidioma(), pseg.ctipcuenta);
            prestamo(prestamo.LAST).ctipban := pseg.ctipban;
            prestamo(prestamo.LAST).ttipban :=
                           ff_desvalorfijo(274, pac_md_common.f_get_cxtidioma(), pseg.ctipban);
            prestamo(prestamo.LAST).ctipimp := pseg.ctipimp;
            prestamo(prestamo.LAST).ttipimp :=
                           ff_desvalorfijo(402, pac_md_common.f_get_cxtidioma(), pseg.ctipimp);
            prestamo(prestamo.LAST).isaldo := pseg.isaldo;
            prestamo(prestamo.LAST).porcen := pseg.porcen;
            prestamo(prestamo.LAST).ilimite := pseg.ilimite;
            prestamo(prestamo.LAST).icapmax := pseg.icapmax;
            prestamo(prestamo.LAST).icapaseg := pseg.icapaseg;
            prestamo(prestamo.LAST).cmoneda := pseg.cmoneda;
            prestamo(prestamo.LAST).idcuenta := pseg.ctapres;
            prestamo(prestamo.LAST).selsaldo := 1;
            prestamo(prestamo.LAST).descripcion := pseg.descripcion;
            prestamo(prestamo.LAST).finiprest := pseg.finiprest;
            prestamo(prestamo.LAST).ffinprest := pseg.ffinprest;
            prestamo(prestamo.LAST).cuadro := f_leeprestcuadroseg(pseg.sseguro,
                                                                  NVL(pseg.nmovimi, 1),
                                                                  pseg.ctapres, mensajes);
         END LOOP;
      END IF;

      RETURN prestamo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leesaldodeutors;

/*******************************************************************************
Bug 10690 - Nueva seccion en la consulta de poliza. Provisiones por garantia.
param IN sseguro : mesajes de error
param out mensajes : mesajes de error
return             : objeto detalle garantias
********************************************************************************/
-- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
   FUNCTION f_leeprovisionesgar(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garantias IS
      CURSOR poldetgar IS
         SELECT   gg.tgarant, s.*
             FROM detgaranseg s, garanseg g, garangen gg, seguros ss
            WHERE s.sseguro = psseguro
              AND s.sseguro = g.sseguro
              AND s.nriesgo = g.nriesgo
              AND s.cgarant = g.cgarant
              AND s.nmovimi = g.nmovimi
              AND g.nmovimi = (SELECT MAX(g2.nmovimi)
                                 FROM garanseg g2
                                WHERE g2.sseguro = g.sseguro
                                  AND g2.nriesgo = g.nriesgo
                                  AND g2.cgarant = g.cgarant
                                  AND g2.ffinefe IS NULL)
              AND g.ffinefe IS NULL
              AND g.cgarant = gg.cgarant
              AND gg.cidioma = pac_md_common.f_get_cxtidioma()
              AND g.sseguro = ss.sseguro
              AND NVL(f_pargaranpro_v(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, ss.cactivi,
                                      g.cgarant, 'REDUCIBLE'),
                      0) = 1
         ORDER BY g.norden, s.ndetgar ASC;

      -- Bug 19412 - RSC - 05/11/2011
      CURSOR poldetgar2 IS
         SELECT   gg.tgarant, g.*
             FROM garanseg g, garangen gg, seguros ss, garanpro gr
            WHERE g.sseguro = psseguro
              AND g.ffinefe IS NULL
              AND g.cgarant = gg.cgarant
              AND gg.cidioma = pac_md_common.f_get_cxtidioma()
              AND g.sseguro = ss.sseguro
              AND g.cgarant = gr.cgarant
              AND ss.sproduc = gr.sproduc
              -- Ini Bug 27403 - MDS - 15/07/2013
              --AND gr.ctipgar <> 8
              AND NVL(f_pargaranpro_v(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, ss.cactivi,
                                      g.cgarant, 'MOSTRAR_DETALLE_PROV'),
                      1) = 1
              -- Fin Bug 27403 - MDS - 15/07/2013
              AND NVL(f_pargaranpro_v(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, ss.cactivi,
                                      g.cgarant, 'TIPO'),
                      0) = 6
         ORDER BY g.norden ASC;

      v_sproduc      seguros.sproduc%TYPE;
      v_ip_iprovresgar NUMBER;
      -- Fin Bug 19412
      garantias      t_iax_garantias := t_iax_garantias();
      v_garmas       ob_iax_masdatosgar;
      v_garmas2      ob_iax_masdatosgar;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leeprovisiones';
      -- Bug 15057 - RSC - 30/06/2010 - field capital by provisions SRD
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_modo         NUMBER;
      -- Fin Bug 15057
      v_ip_valresc   NUMBER;   -- Bug 31154/0173547 - APD - 05/05/2014
   BEGIN
      -- Bug 15057 - RSC - 30/06/2010 - field capital by provisions SRD
      SELECT cramo, cmodali, ctipseg, ccolect, cactivi, sproduc
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      -- Fin Bug 15057
      -- Bug 19412 - RSC - 05/11/2011
      -- Bug 29943 - JTT - 15/05/2014 - A?adimos la validacion del parametro TIPO_PB
      IF (NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2))
         AND(NVL(f_parproductos_v(v_sproduc, 'TIPO_PB'), 0) <> 1) THEN
         -- Fin Bug 19412
         -- Fin Bug 29943
         FOR pseg IN poldetgar LOOP
            garantias.EXTEND;
            garantias(garantias.LAST) := ob_iax_garantias();
            garantias(garantias.LAST).cgarant := pseg.cgarant;
            garantias(garantias.LAST).tgarant := pseg.tgarant;
            -- Bug 15057 - RSC - 30/06/2010 - field capital by provisions SRD
            v_modo := f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                      pseg.cgarant, 'PREST_VINC');

            IF NVL(v_modo, 0) IN(1, 2) THEN
               garantias(garantias.LAST).icapital :=
                  pac_propio.f_cuadro_amortizacion(psseguro, pseg.fefecto, pseg.fvencim,
                                                   TRUNC(f_sysdate), pseg.cgarant,
                                                   pseg.icapital, v_modo);
            ELSE
               -- Fin Bug 15057
               garantias(garantias.LAST).icapital := pseg.icapital;
            -- Bug 15057 - RSC - 30/06/2010 - field capital by provisions SRD
            END IF;

            -- FIn Bug 15057
            garantias(garantias.LAST).primas := ob_iax_primas();
            garantias(garantias.LAST).primas.iprianu := pseg.iprianu;
            -- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
            v_garmas2 := pac_md_obtenerdatos.f_leedatosgarantias(pseg.nriesgo, pseg.cgarant,
                                                                 pseg.ndetgar, mensajes,
                                                                 psseguro);
            v_garmas := ob_iax_masdatosgar();
            v_garmas.ndetgar := pseg.ndetgar;
            v_garmas.cunica := v_garmas2.cunica;
            v_garmas.provmat := v_garmas2.provmat;
            v_garmas.ireducc := v_garmas2.ireducc;

            -- Fin Bug 10690
            -- Bug 31154/0173547 - APD - 05/05/2014
            BEGIN
               v_ip_valresc := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                          TRUNC(f_sysdate),
                                                                          'IVALRES',
                                                                          pseg.cgarant);
            EXCEPTION
               WHEN OTHERS THEN
                  v_ip_valresc := 0;
            END;

            v_garmas.valresc := v_ip_valresc;
            -- fin Bug 31154/0173547 - APD - 05/05/2014
            garantias(garantias.LAST).masdatos := v_garmas;
         END LOOP;
      -- Bug 19412 - RSC - 05/11/2011
      ELSE
         FOR pseg IN poldetgar2 LOOP
            garantias.EXTEND;
            garantias(garantias.LAST) := ob_iax_garantias();
            garantias(garantias.LAST).cgarant := pseg.cgarant;
            garantias(garantias.LAST).tgarant := pseg.tgarant;

            --garantias(garantias.LAST).icapital := pseg.icapital;
            --garantias(garantias.LAST).primas := ob_iax_primas();
            --garantias(garantias.LAST).primas.iprianu := pseg.iprianu;
            BEGIN
               v_ip_iprovresgar :=
                  pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(f_sysdate),
                                                             'IPROVRES', pseg.cgarant);
            EXCEPTION
               WHEN OTHERS THEN
                  v_ip_iprovresgar := 0;
            END;

            v_garmas := ob_iax_masdatosgar();
            --v_garmas.ndetgar := NULL;
            --v_garmas.cunica := NULL;
            --v_garmas.ireducc := NULL;
            v_garmas.provmat := v_ip_iprovresgar;

            -- Bug 31154/0173547 - APD - 05/05/2014
            BEGIN
               v_ip_valresc := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                          TRUNC(f_sysdate),
                                                                          'IVALRES',
                                                                          pseg.cgarant);
            EXCEPTION
               WHEN OTHERS THEN
                  v_ip_valresc := 0;
            END;

            v_garmas.valresc := v_ip_valresc;
            -- fin Bug 31154/0173547 - APD - 05/05/2014
            garantias(garantias.LAST).masdatos := v_garmas;
         END LOOP;
      END IF;

      -- Fin Bug 19412
      RETURN garantias;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeprovisionesgar;

/*********************************************************************************
Bug 10690 - Nueva seccion en la consulta de poliza. Provision por poliza.
param IN sseguro : mesajes de error
param out mensajes : mesajes de error
return             : objeto detalle garantias
**********************************************************************************/
-- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
   FUNCTION f_leeprovisionpol(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_datoseconomicos IS
      datecon        ob_iax_datoseconomicos;
      v_ip_provision NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leeprovisionpol';
   BEGIN
      IF vpmode = 'EST' THEN
         NULL;
      ELSE
         -- Provision Actual
         BEGIN
            vpasexec := 15;
            v_ip_provision := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                         TRUNC(f_sysdate),
                                                                         'IPROVAC');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         datecon := ob_iax_datoseconomicos();
         datecon.impprovision := NVL(v_ip_provision, 0);
      END IF;

      RETURN datecon;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeprovisionpol;

/*************************************************************************
Recuperar la informacion de las garantias (suplementos economicos)
param in pnriesgo  : n¿mero de riesgo
param out mensajes : mesajes de error
return             : objeto garantias
*************************************************************************/
-- Bug 11735 - RSC - 28/01/2010 - APR - suplemento de modificacion de capital /prima
   FUNCTION f_leegarantias_supl(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garantias IS
      cur            sys_refcursor;
      solgar         solgaranseg%ROWTYPE;
      estgar         estgaranseg%ROWTYPE;
      polgar         garanseg%ROWTYPE;
      garant         t_iax_garantias := t_iax_garantias();
      squery         VARCHAR2(2000);
      vtab           VARCHAR2(1000);
      vfield         VARCHAR2(1000);
      vfields        VARCHAR2(1000);
      pri            ob_iax_primas;
      sproduc        NUMBER;
      vtab2          VARCHAR2(30);
      vcond          VARCHAR2(1000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeGarantias';
      -- Bug 10101 - 22/05/2009 - RSC - Detalle de garantias
      v_garmas       ob_iax_masdatosgar;
      v_garmas2      ob_iax_masdatosgar;
      v_cgarant      estgaranseg.cgarant%TYPE;
      v_nmovimi      estgaranseg.nmovimi%TYPE;
      v_finiefe      estgaranseg.finiefe%TYPE;
      v_norden       estgaranseg.norden%TYPE;
      v_ifranqu      estgaranseg.ifranqu%TYPE;
      v_icaptot      estgaranseg.icaptot%TYPE;
      v_nmovima      estgaranseg.nmovima%TYPE;
      v_cfranq       estgaranseg.cfranq%TYPE;
      v_ndetgar      estdetgaranseg.ndetgar%TYPE;
      v_fefecto      estdetgaranseg.fefecto%TYPE;
      v_fvencim      estdetgaranseg.fvencim%TYPE;
      v_ndurcob      estdetgaranseg.ndurcob%TYPE;
      v_ctarifa      estdetgaranseg.ctarifa%TYPE;
      v_pinttec      estdetgaranseg.pinttec%TYPE;
      v_ftarifa      estdetgaranseg.ftarifa%TYPE;
      v_crevali      estdetgaranseg.crevali%TYPE;
      v_prevali      estdetgaranseg.prevali%TYPE;
      v_irevali      estdetgaranseg.irevali%TYPE;
      v_icapital     estdetgaranseg.icapital%TYPE;
      v_iprianu      estdetgaranseg.iprianu%TYPE;
      v_precarg      estdetgaranseg.precarg%TYPE;
      v_irecarg      estdetgaranseg.irecarg%TYPE;
      v_cparben      estdetgaranseg.cparben%TYPE;
      v_cprepost     estdetgaranseg.cprepost%TYPE;
      v_ffincob      estdetgaranseg.ffincob%TYPE;
      v_ipritar      estdetgaranseg.ipritar%TYPE;
      v_provmat0     estdetgaranseg.provmat0%TYPE;
      v_fprovmat0    estdetgaranseg.fprovmat0%TYPE;
      v_provmat1     estdetgaranseg.provmat1%TYPE;
      v_fprovmat1    estdetgaranseg.fprovmat1%TYPE;
      v_pintmin      estdetgaranseg.pintmin%TYPE;
      v_pdtocom      estdetgaranseg.pdtocom%TYPE;
      v_idtocom      estdetgaranseg.idtocom%TYPE;
      v_ctarman      estdetgaranseg.ctarman%TYPE;
      v_ipripur      estdetgaranseg.ipripur%TYPE;
      v_ipriinv      estdetgaranseg.ipriinv%TYPE;
      v_itarrea      estdetgaranseg.itarrea%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_tgarant      garangen.tgarant%TYPE;
   -- Fin Bug 10101
   BEGIN
      vtab2 := 'ESTSEGUROS g';
      vfield := 'g.SSEGURO';

      BEGIN
         sproduc :=
            TO_NUMBER(pac_iax_listvalores.f_getdescripvalor('select sproduc from ' || vtab2
                                                            || ' where ' || vfield || '='
                                                            || psseguro,
                                                            mensajes));
      EXCEPTION
         WHEN OTHERS THEN
            sproduc := NULL;
      END;

      IF NVL(f_parproductos_v(sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
         vtab := 'ESTGARANSEG g, ESTDETGARANSEG dg, GARANGEN gg';
         vfields :=
            'g.CGARANT, g.NMOVIMI, g.FINIEFE, g.NORDEN, g.IFRANQU, g.ICAPTOT, g.NMOVIMA, g.CFRANQ, dg.NDETGAR,
dg.FEFECTO, dg.FVENCIM, dg.NDURCOB, dg.CTARIFA, dg.PINTTEC, dg.FTARIFA, dg.CREVALI, dg.PREVALI, dg.IREVALI, dg.ICAPITAL,
dg.IPRIANU, dg.PRECARG, dg.IRECARG, dg.CPARBEN, dg.CPREPOST, dg.FFINCOB, dg.IPRITAR,
dg.PROVMAT0, dg.FPROVMAT0, dg.PROVMAT1, dg.FPROVMAT1, dg.PINTMIN, dg.PDTOCOM, dg.IDTOCOM, dg.CTARMAN, dg.IPRIPUR,
dg.IPRIINV, dg.ITARREA, gg.tgarant';
         vcond := ' AND g.sseguro = dg.sseguro ' || 'AND g.nriesgo = dg.nriesgo '
                  || 'AND g.cgarant = dg.cgarant ' || 'AND g.finiefe = dg.finiefe '
                  || 'AND g.nmovimi = dg.nmovimi ' || 'AND g.ffinefe IS NULL '
                  || 'AND g.cgarant = gg.cgarant ' || 'AND gg.cidioma = '
                  || pac_md_common.f_get_cxtidioma()
                  || ' AND g.cobliga = 1 order by g.NORDEN, dg.NDETGAR ASC';
      ELSE
         vtab := 'ESTGARANSEG';
         vfields := '*';
         vcond := ' AND ffinefe IS NULL  order by g.NORDEN asc';
      END IF;

      squery := 'SELECT ' || vfields || ' FROM ' || vtab || ' where ' || vfield || '='
                || psseguro || ' and ' || '       g.nriesgo=' || pnriesgo || vcond;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);

      LOOP
         FETCH cur
          INTO v_cgarant, v_nmovimi, v_finiefe, v_norden, v_ifranqu, v_icaptot, v_nmovima,
               v_cfranq, v_ndetgar, v_fefecto, v_fvencim, v_ndurcob, v_ctarifa, v_pinttec,
               v_ftarifa, v_crevali, v_prevali, v_irevali, v_icapital, v_iprianu, v_precarg,
               v_irecarg, v_cparben, v_cprepost, v_ffincob, v_ipritar, v_provmat0,
               v_fprovmat0, v_provmat1, v_fprovmat1, v_pintmin, v_pdtocom, v_idtocom,
               v_ctarman, v_ipripur, v_ipriinv, v_itarrea, v_tgarant;

         EXIT WHEN cur%NOTFOUND;
         garant.EXTEND;
         garant(garant.LAST) := ob_iax_garantias();
         garant(garant.LAST).cgarant := v_cgarant;
         garant(garant.LAST).tgarant := v_tgarant;
         garant(garant.LAST).icapital := v_icapital;
         garant(garant.LAST).crevali := v_crevali;
         garant(garant.LAST).prevali := v_prevali;
         garant(garant.LAST).irevali := v_irevali;
         garant(garant.LAST).cfranq := v_cfranq;
         garant(garant.LAST).ifranqu := v_ifranqu;
         garant(garant.LAST).nmovimi := v_nmovimi;
         garant(garant.LAST).nmovima := v_nmovima;
         garant(garant.LAST).norden := v_norden;
         garant(garant.LAST).finiefe := v_finiefe;
         garant(garant.LAST).primas.iprianu := v_iprianu;
         garant(garant.LAST).icaptot := v_icaptot;
         garant(garant.LAST).cdetalle := pac_mdpar_productos.f_get_detallegar(sproduc,
                                                                              v_cgarant,
                                                                              mensajes);
         garant(garant.LAST).desglose := f_lee_desglosegarantias(NVL(vsolicit, psseguro),
                                                                 pnriesgo, v_cgarant, NULL,
                                                                 mensajes);

         IF NVL(f_parproductos_v(sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
            garant(garant.LAST).masdatos.ndetgar := v_ndetgar;
            garant(garant.LAST).masdatos.fefecto := v_fefecto;
            garant(garant.LAST).masdatos.fvencim := v_fvencim;
            garant(garant.LAST).masdatos.ndurcob := v_ndurcob;
            garant(garant.LAST).masdatos.ffincob := v_ffincob;
            garant(garant.LAST).masdatos.pinttec := v_pinttec;
            garant(garant.LAST).masdatos.pintmin := v_pintmin;
            garant(garant.LAST).masdatos.fprovt0 := v_fprovmat0;
            garant(garant.LAST).masdatos.iprovt0 := v_provmat0;
            garant(garant.LAST).masdatos.fprovt1 := v_fprovmat1;
            garant(garant.LAST).masdatos.iprovt1 := v_provmat1;
            v_garmas2 := pac_md_obtenerdatos.f_leedatosgarantias(pnriesgo, v_cgarant,
                                                                 v_ndetgar, mensajes);
            garant(garant.LAST).masdatos.estado := v_garmas2.estado;
            garant(garant.LAST).masdatos.testado := v_garmas2.testado;
            garant(garant.LAST).masdatos.ctarifa := v_ctarifa;
            garant(garant.LAST).masdatos.ftarifa := v_ftarifa;
            garant(garant.LAST).masdatos.cunica := v_garmas2.cunica;

            -- Bug 13832 - RSC - 16/06/2010 - APRS015 - suplemento de aportaciones ¿nicas
            IF v_garmas2.cunica = 1 THEN
               garant(garant.LAST).masdatos.tunica :=
                                     f_axis_literales(101778, pac_md_common.f_get_cxtidioma());
            ELSE
               garant(garant.LAST).masdatos.tunica :=
                                     f_axis_literales(101779, pac_md_common.f_get_cxtidioma());
            END IF;

            -- Fin Bug 13832
            garant(garant.LAST).masdatos.cagente := v_garmas2.cagente;
            garant(garant.LAST).masdatos.provmat := v_garmas2.provmat;
            garant(garant.LAST).masdatos.ireducc := v_garmas2.ireducc;
         END IF;
      END LOOP;

      CLOSE cur;

      RETURN garant;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leegarantias_supl;

-- Fin Bug 11735
/*************************************************************************
Recuperar la informacion de evoluprovmatseg
param in sseguro   : numero de seguro
param in ptablas   : tablas a consultar
param out mensajes : mesajes de error
return             : objeto garantias
*************************************************************************/
-- Bug 14598 - RSC - 23/06/2010 - CEM800 - Informacion adicional en pantallas y documentos
   FUNCTION f_leeevoluprovmatseg(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      pnscenario IN NUMBER,
      -- Bug 14598 - PFA - 06/08/2010 - a?adir parametro ptablas
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_evoluprovmat IS
      cur            sys_refcursor;
      v_evoluprovmat t_iax_evoluprovmat := t_iax_evoluprovmat();
      squery         VARCHAR2(2000);
      vtab           VARCHAR2(1000);
      vtab2          VARCHAR2(1000);
      vfield         VARCHAR2(1000);
      vfields        VARCHAR2(1000);
      vcond          VARCHAR2(1000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
         := 'psseguro=' || psseguro || ' ptablas= ' || ptablas || ' pnscenario= '
            || pnscenario;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leeevoluprovmatseg';
      v_nanyo        evoluprovmatseg.nanyo%TYPE;
      v_fprovmat     evoluprovmatseg.fprovmat%TYPE;
      v_iprovmat     evoluprovmatseg.iprovmat%TYPE;
      v_prescate     evoluprovmatseg.prescate%TYPE;
      v_pinttec      evoluprovmatseg.pinttec%TYPE;
      v_ivalres      evoluprovmatseg.ivalres%TYPE;
      v_iprima       evoluprovmatseg.iprima%TYPE;
      v_nscenario    evoluprovmatseg.nscenario%TYPE;
   BEGIN
      -- Bug 14598 - PFA - 06/08/2010 - a¿adir parametro ptablas
      IF ptablas = 'EST' THEN
         vtab := 'ESTEVOLUPROVMATSEG e';
      ELSE
         vtab := 'EVOLUPROVMATSEG e';
      END IF;

      -- Fi Bug 14598 - PFA - 06/08/2010 - a¿adir parametro ptablas
      vfield := 'e.sseguro';
      vfields :=
         'e.nanyo, e.fprovmat, NVL(e.iprovmat,0), NVL(e.prescate, 0), NVL(e.pinttec,0), NVL(e.ivalres, 0), NVL(e.iprima, 0), e.nscenario';

      IF pnscenario IS NOT NULL THEN
         vcond := ' AND e.nscenario = ' || pnscenario;
      END IF;

      vcond := vcond || ' AND nmovimi = (SELECT MAX(nmovimi) FROM ' || vtab
               || ' WHERE sseguro = ' || psseguro || ' )  order by e.nanyo asc';
      squery := 'SELECT ' || vfields || ' FROM ' || vtab || ' where ' || vfield || '='
                || psseguro || vcond;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);

      LOOP
         FETCH cur
          INTO v_nanyo, v_fprovmat, v_iprovmat, v_prescate, v_pinttec, v_ivalres, v_iprima,
               v_nscenario;

         EXIT WHEN cur%NOTFOUND;
         v_evoluprovmat.EXTEND;
         v_evoluprovmat(v_evoluprovmat.LAST) := ob_iax_evoluprovmat();
         v_evoluprovmat(v_evoluprovmat.LAST).nanyo := v_nanyo;
         v_evoluprovmat(v_evoluprovmat.LAST).fprovmat := v_fprovmat;
         v_evoluprovmat(v_evoluprovmat.LAST).iprovmat := v_iprovmat;
         v_evoluprovmat(v_evoluprovmat.LAST).prescate := v_prescate;
         v_evoluprovmat(v_evoluprovmat.LAST).pinttec := v_pinttec;
         v_evoluprovmat(v_evoluprovmat.LAST).ivalres := v_ivalres;
         v_evoluprovmat(v_evoluprovmat.LAST).iprima := v_iprima;
         v_evoluprovmat(v_evoluprovmat.LAST).nscenario := v_nscenario;
      END LOOP;

      CLOSE cur;

      RETURN v_evoluprovmat;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leeevoluprovmatseg;

-- Fin Bug 14598
/*************************************************************************
Lee los datos del desglose de capitales de garantias
param out mensajes : mesajes de error
return             : objeto gestion
*************************************************************************/
   FUNCTION f_lee_desglosegarantias(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_desglose_gar IS
      CURSOR estpoldetgar IS
         SELECT s.*
           FROM estgarandetcap s, estgaranseg g
          WHERE s.sseguro = NVL(vsolicit, psseguro)
            AND s.nriesgo = pnriesgo
            AND s.cgarant = pcgarant
            AND s.norden = NVL(pnorden, s.norden)
            AND s.sseguro = g.sseguro
            AND s.nriesgo = g.nriesgo
            AND s.cgarant = g.cgarant
            AND s.nmovimi = g.nmovimi
            AND s.nmovimi = NVL(vnmovimi, 1)
            AND g.ffinefe IS NULL;

      CURSOR poldetgar IS
         SELECT s.*
           FROM garandetcap s, garanseg g
          WHERE s.sseguro = NVL(vsolicit, psseguro)
            AND s.nriesgo = pnriesgo
            AND s.cgarant = pcgarant
            AND s.norden = NVL(pnorden, s.norden)
            AND s.sseguro = g.sseguro
            AND s.nriesgo = g.nriesgo
            AND s.cgarant = g.cgarant
            AND s.nmovimi = g.nmovimi
            AND g.nmovimi = (SELECT MAX(g2.nmovimi)
                               FROM garanseg g2
                              WHERE g2.sseguro = g.sseguro
                                AND g2.nriesgo = g.nriesgo
                                AND g2.cgarant = g.cgarant
                                AND g2.ffinefe IS NULL)
            AND g.ffinefe IS NULL;

      v_masdatos     t_iax_desglose_gar := t_iax_desglose_gar();
      v_sproduc      seguros.sproduc%TYPE;
      v_ndurcob      seguros.ndurcob%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_finiefe      garanseg.finiefe%TYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_lee_desglosegarantias';
      v_tatribu      detvalores.tatribu%TYPE;
      v_res          NUMBER;
      v_iprianu      garanseg.iprianu%TYPE;
      v_icapital     garanseg.icapital%TYPE;
      v_ctarifa      garanseg.ctarifa%TYPE;
      v_ftarifa      garanseg.ftarifa%TYPE;
   BEGIN
      vpasexec := 11;

      IF vpmode = 'EST' THEN
         vpasexec := 2;

         FOR pmdatos IN estpoldetgar LOOP
            vpasexec := 3;
            v_masdatos.EXTEND;
            v_masdatos(v_masdatos.LAST) := ob_iax_desglose_gar();
            v_masdatos(v_masdatos.LAST).norden := pmdatos.norden;
            vpasexec := 4;
            v_masdatos(v_masdatos.LAST).cconcepto := pmdatos.cconcepto;
            v_masdatos(v_masdatos.LAST).tconcepto :=
                          ff_desvalorfijo(1, pac_md_common.f_get_cxtidioma, pmdatos.cconcepto);
            vpasexec := 5;
            v_masdatos(v_masdatos.LAST).tdescripcion := pmdatos.tdescrip;
            v_masdatos(v_masdatos.LAST).icapital := pmdatos.icapital;
            vpasexec := 6;
         END LOOP;

         vpasexec := 7;

         IF estpoldetgar%ISOPEN THEN
            CLOSE estpoldetgar;
         END IF;
      ELSE
         vpasexec := 8;

         FOR pmdatos IN poldetgar LOOP
            vpasexec := 9;
            v_masdatos.EXTEND;
            vpasexec := 10;
            v_masdatos(v_masdatos.LAST) := ob_iax_desglose_gar();
            v_masdatos(v_masdatos.LAST).norden := pmdatos.norden;
            v_masdatos(v_masdatos.LAST).cconcepto := pmdatos.cconcepto;
            vpasexec := 11;
            v_masdatos(v_masdatos.LAST).tconcepto :=
                          ff_desvalorfijo(1, pac_md_common.f_get_cxtidioma, pmdatos.cconcepto);
            vpasexec := 12;
            v_masdatos(v_masdatos.LAST).tdescripcion := pmdatos.tdescrip;
            v_masdatos(v_masdatos.LAST).icapital := pmdatos.icapital;
            vpasexec := 13;
         END LOOP;

         vpasexec := 14;

         IF poldetgar%ISOPEN THEN
            CLOSE poldetgar;
         END IF;
      END IF;

      vpasexec := 15;
      RETURN v_masdatos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_desglosegarantias;

/*************************************************************************
Lee reglas (APRA - GROUPLIFE)
param out mensajes : mesajes de error
return             : objeto clausulas
*************************************************************************/
   FUNCTION f_leereglassegtramos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reglassegtramos IS
      reglas         t_iax_reglassegtramos := t_iax_reglassegtramos();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leereglassegtramos';
      -- Bug 16768 - APD - 13/12/2010 - se elimina el sseguro en la SELECT
      vquery         VARCHAR2(4000)
         := ' SELECT   edadini, edadfin, t1copagemp, '
            || ' t1copagtra, t2copagemp, t2copagtra, t3copagemp, t3copagtra, t4copagemp, t4copagtra ';
      -- Fin Bug 16768 - APD - 13/12/2010
      cur            sys_refcursor;
      vedadini       NUMBER(3);
      vedadfin       NUMBER(3);
      vt1copagemp    NUMBER(5, 2);
      vt1copagtra    NUMBER(5, 2);
      vt2copagemp    NUMBER(5, 2);
      vt2copagtra    NUMBER(5, 2);
      vt3copagemp    NUMBER(5, 2);
      vt3copagtra    NUMBER(5, 2);
      vt4copagemp    NUMBER(5, 2);
      vt4copagtra    NUMBER(5, 2);
   BEGIN
      IF vpmode = 'SOL' THEN
         RETURN NULL;
      -- Bug 16768 - APD - 13/12/2010 - se a¿ade la variable vquery delante del FROM
      ELSIF vpmode = 'EST' THEN
         vquery := vquery || ' FROM estreglassegtramos ' || ' WHERE sseguro = '
                   || NVL(psseguro, vsolicit) || ' AND nriesgo = ' || pnriesgo
                   || ' AND cgarant = ' || pcgarant || ' AND nmovimi = ' || pnmovimi
                   || ' ORDER BY edadini';
      ELSE
         vquery := vquery || ' FROM reglassegtramos ' || ' WHERE sseguro = '
                   || NVL(psseguro, vsolicit) || ' AND nriesgo = ' || pnriesgo
                   || ' AND cgarant = ' || pcgarant || ' AND nmovimi = ' || pnmovimi
                   || ' ORDER BY edadini';
      END IF;

      -- Fin Bug 16768 - APD - 13/12/2010 -
      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);

      LOOP
         FETCH cur
          INTO vedadini, vedadfin, vt1copagemp, vt1copagtra, vt2copagemp, vt2copagtra,
               vt3copagemp, vt3copagtra, vt4copagemp, vt4copagtra;

         EXIT WHEN cur%NOTFOUND;
         reglas.EXTEND;
         reglas(reglas.LAST) := ob_iax_reglassegtramos();
         reglas(reglas.LAST).sseguro := psseguro;
         reglas(reglas.LAST).nriesgo := pnriesgo;
         reglas(reglas.LAST).cgarant := pcgarant;
         reglas(reglas.LAST).nmovimi := pnmovimi;
         reglas(reglas.LAST).edadini := vedadini;
         reglas(reglas.LAST).edadfin := vedadfin;
         reglas(reglas.LAST).t1copagemp := vt1copagemp;
         reglas(reglas.LAST).t1copagtra := vt1copagtra;
         reglas(reglas.LAST).t2copagemp := vt2copagemp;
         reglas(reglas.LAST).t2copagtra := vt2copagtra;
         reglas(reglas.LAST).t3copagemp := vt3copagemp;
         reglas(reglas.LAST).t3copagtra := vt3copagtra;
         reglas(reglas.LAST).t4copagemp := vt4copagemp;
         reglas(reglas.LAST).t4copagtra := vt4copagtra;
      END LOOP;

      CLOSE cur;

      RETURN reglas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leereglassegtramos;

/*************************************************************************
Lee reglas (APRA - GROUPLIFE)
param out mensajes : mesajes de error
return             : objeto clausulas
*************************************************************************/
-- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
   FUNCTION f_leereglasseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg IS
      reglas         ob_iax_reglasseg := ob_iax_reglasseg();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leereglasseg';
   BEGIN
      IF vpmode = 'SOL' THEN
         RETURN NULL;
      ELSIF vpmode = 'EST' THEN
         SELECT capmaxemp, capminemp, capmaxtra, capmintra
           INTO reglas.capmaxemp, reglas.capminemp, reglas.capmaxtra, reglas.capmintra
           FROM estreglasseg
          WHERE sseguro = NVL(psseguro, vsolicit)
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi;
      ELSE
         SELECT capmaxemp, capminemp, capmaxtra, capmintra
           INTO reglas.capmaxemp, reglas.capminemp, reglas.capmaxtra, reglas.capmintra
           FROM reglasseg
          WHERE sseguro = NVL(psseguro, vsolicit)
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi;
      END IF;

      reglas.sseguro := psseguro;
      reglas.nriesgo := pnriesgo;
      reglas.cgarant := pcgarant;
      reglas.nmovimi := pnmovimi;
      reglas.reglassegtramos := f_leereglassegtramos(psseguro, pnriesgo, pcgarant, pnmovimi,
                                                     mensajes);
      RETURN reglas;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN reglas;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leereglasseg;

-- Bug 16106
/*************************************************************************
Devuelve el capital de una garantia
param in psseguro   : numero de seguro
param in pnriesgo   : numero de riesgo
param in pcgarant   : codigo de la garantia
param in ptablas    : tablas donde hay que ir a buscar la informacion
param out mensajes : mesajes de error
return             : Impporte del capital
Bug 18342 - 24/05/2011 - AMC
*************************************************************************/
   FUNCTION f_leecapital(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vicapital      NUMBER;
      ssql           VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
         := 'psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' pcgarant=' || pcgarant
            || ' ptablas=' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leecapital';
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pcgarant IS NULL
         OR ptablas IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Bug 18342 - RSC - 09/05/2011 - LCOL003 - Revalorizacion de capital tipo 'Lista de valores'
      BEGIN
         IF ptablas = 'EST' THEN
            SELECT icapital
              INTO vicapital
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND ffinefe IS NULL;
         ELSE
            SELECT icapital
              INTO vicapital
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND ffinefe IS NULL;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      -- Fin Bug 18342
      /*IF ptablas = 'EST' THEN
      ssql := 'select icapital from estgaranseg where sseguro =' || psseguro
      || ' and nriesgo =' || pnriesgo || ' and cgarant =' || pcgarant
      || ' and ffinefe is null';
      ELSE
      ssql := 'select icapital from garanseg where sseguro =' || psseguro
      || ' and nriesgo =' || pnriesgo || ' and cgarant =' || pcgarant
      || ' and ffinefe is null';
      END IF;
      EXECUTE IMMEDIATE ssql INTO vicapital;*/
      RETURN vicapital;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leecapital;

-- BUG19069:DRA:27/09/2011:Inici
   -- INI -IAXIS-10627 -21/01/2020
   FUNCTION f_leecorretaje(pnmovimi IN NUMBER DEFAULT NULL,
		                       mensajes IN OUT t_iax_mensajes)
	 
	 -- FIN -IAXIS-10627 -21/01/2020
      RETURN t_iax_corretaje IS
      CURSOR estcorr IS
         SELECT s.*
           FROM estage_corretaje s
          WHERE s.sseguro = vsolicit
            AND s.nmovimi = (SELECT MAX(s1.nmovimi)
                               FROM estage_corretaje s1
                              WHERE s1.sseguro = s.sseguro);
      -- INI -IAXIS-10627 -21/01/2020
      CURSOR polcorr (w_nmovimi movseguro.nmovimi%TYPE) IS
         SELECT s.*
           FROM age_corretaje s
          WHERE s.sseguro = vsolicit
            AND s.nmovimi = NVL(w_nmovimi,(SELECT MAX(s1.nmovimi)
                                             FROM pregunpolseg
                                                  /*age_corretaje*/
                                             s1
                                            WHERE s1.sseguro = s.sseguro));
      -- FIN -IAXIS-10627 -21/01/2020
      corret         t_iax_corretaje := t_iax_corretaje();
      vcdomici       NUMBER;
      vsperson       NUMBER;
      vcagente_padre NUMBER;
      ndirec         NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_Leecorretaje';
      vpcomisi       NUMBER(5, 2);
      vpretenc       NUMBER(5, 2);
      vcramo         NUMBER(8);
      vcmodali       NUMBER(2);
      vctipseg       NUMBER(2);
      vccolect       NUMBER(2);
      vfefecto       DATE;
      vcactivi       NUMBER(4);
   BEGIN
      IF vpmode = 'EST' THEN
         vpasexec := 2;

         FOR ecorr IN estcorr LOOP
            -- Bug 28132/152950 - 19/09/2013 - AMC
            -- Si el % es del 100 es que solo hay un agente y por lo tanto no tiene co-corretaje
            IF ecorr.ppartici = 100 THEN
               EXIT;
            END IF;

            vpasexec := 3;
            corret.EXTEND;
            corret(corret.LAST) := ob_iax_corretaje();
            corret(corret.LAST).cagente := ecorr.cagente;
            corret(corret.LAST).nordage := ecorr.nordage;
            corret(corret.LAST).nmovimi := NVL(ecorr.nmovimi, 1);
            corret(corret.LAST).ppartici := ecorr.ppartici;
            corret(corret.LAST).islider := ecorr.islider;
            --BUG22408:DRA:09/06/2012:Inici
            vpasexec := 31;

            SELECT cramo, cmodali, ctipseg, ccolect, fefecto, cactivi
              INTO vcramo, vcmodali, vctipseg, vccolect, vfefecto, vcactivi
              FROM estseguros
             WHERE sseguro = ecorr.sseguro;

            vpasexec := 32;
            num_err := pac_corretaje.f_calcular_comision_corretaje(ecorr.sseguro, NULL,
                                                                   NVL(ecorr.nmovimi, 1),
                                                                   vfefecto, vcramo, vcmodali,
                                                                   vctipseg, vccolect,
                                                                   vcactivi, ecorr.cagente,
                                                                   vpmode, ecorr.ppartici,
                                                                   vpcomisi, vpretenc);

            IF num_err <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
               RAISE e_object_error;
            END IF;

            corret(corret.LAST).pcomisi := vpcomisi;

            --BUG22408:DRA:09/06/2012:Inici
            SELECT sperson, cdomici
              INTO vsperson, vcdomici
              FROM agentes
             WHERE cagente = ecorr.cagente;

            vpasexec := 4;
            num_err := pac_md_persona.f_get_persona_agente(vsperson, ecorr.cagente, 'POL',
                                                           corret(corret.LAST), mensajes);
            vpasexec := 5;

            BEGIN
               SELECT NVL(cpadre, cagente)
                 INTO vcagente_padre
                 FROM redcomercial
                WHERE cagente = ecorr.cagente
                  AND fmovfin IS NULL;

               ---MCA 27/10/2011
               vpasexec := 51;
               corret(corret.LAST).csucursal := vcagente_padre;
               --MAL 25581/134316 13/02/2013
               corret(corret.LAST).tsucursal :=
                   pac_redcomercial.ff_desagente(vcagente_padre, pac_md_common.f_get_cxtidioma);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  corret(corret.LAST).csucursal := NULL;
                  --MAL 25581/134316 13/02/2013
                  corret(corret.LAST).tsucursal := NULL;
            END;

            vpasexec := 52;
            corret(corret.LAST).tagente :=
                    pac_redcomercial.ff_desagente(ecorr.cagente, pac_md_common.f_get_cxtidioma);
            vpasexec := 6;
            num_err := pac_md_persona.f_get_persona_agente(vsperson, ecorr.cagente, vpmode,
                                                           corret(corret.LAST), mensajes);

            IF num_err <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
               RAISE e_object_error;
            END IF;

            vpasexec := 7;

            IF corret(corret.LAST).direcciones IS NULL THEN
               corret(corret.LAST).direcciones := t_iax_direcciones();
            END IF;

            corret(corret.LAST).direcciones.EXTEND;
            ndirec := corret(corret.LAST).direcciones.LAST;
            corret(corret.LAST).direcciones(ndirec) := ob_iax_direcciones();
            corret(corret.LAST).direcciones(ndirec).cdomici := NVL(vcdomici, 1);
            vpasexec := 8;
            pac_md_listvalores.p_ompledadesdireccions(vsperson, NVL(vcdomici, 1), vpmode,
                                                      corret(corret.LAST).direcciones(ndirec),
                                                      mensajes);
         END LOOP;
      ELSE
         -- INI -IAXIS-10627 -21/01/2020
         FOR pcorr IN polcorr(pnmovimi) LOOP
         -- FIN -IAXIS-10627 -21/01/2020
            IF pac_corretaje.f_tiene_corretaje(pcorr.sseguro, pcorr.nmovimi) = 1 THEN
               -- Bug 28132/152950 - 19/09/2013 - AMC
               -- Si el % es del 100 es que solo hay un agente y por lo tanto no tiene co-corretaje
               -- if pcorr.ppartici = 100 then
               --     EXIT;
               -- end if;
               corret.EXTEND;
               corret(corret.LAST) := ob_iax_corretaje();
               corret(corret.LAST).cagente := pcorr.cagente;
               corret(corret.LAST).nordage := pcorr.nordage;
               corret(corret.LAST).nmovimi := NVL(pcorr.nmovimi, 1);
               corret(corret.LAST).ppartici := pcorr.ppartici;
               corret(corret.LAST).islider := pcorr.islider;
               --BUG22408:DRA:09/06/2012:Inici
               vpasexec := 81;

               SELECT cramo, cmodali, ctipseg, ccolect, fefecto, cactivi
                 INTO vcramo, vcmodali, vctipseg, vccolect, vfefecto, vcactivi
                 FROM seguros
                WHERE sseguro = pcorr.sseguro;

               vpasexec := 82;
               num_err := pac_corretaje.f_calcular_comision_corretaje(pcorr.sseguro, NULL,
                                                                      NVL(pcorr.nmovimi, 1),
                                                                      vfefecto, vcramo,
                                                                      vcmodali, vctipseg,
                                                                      vccolect, vcactivi,
                                                                      pcorr.cagente, vpmode,
                                                                      pcorr.ppartici, vpcomisi,
                                                                      vpretenc);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  RAISE e_object_error;
               END IF;

               corret(corret.LAST).pcomisi := vpcomisi;
               --BUG22408:DRA:09/06/2012:Inici
               vpasexec := 9;

               SELECT sperson, cdomici
                 INTO vsperson, vcdomici
                 FROM agentes
                WHERE cagente = pcorr.cagente;

               vpasexec := 10;
               num_err := pac_md_persona.f_get_persona_agente(vsperson, pcorr.cagente, vpmode,
                                                              corret(corret.LAST), mensajes);
               vpasexec := 11;

               BEGIN
                  SELECT NVL(cpadre, cagente)
                    INTO vcagente_padre
                    FROM redcomercial
                   WHERE cagente = pcorr.cagente
                     AND fmovfin IS NULL;

                  ---MCA 27/10/2011
                  vpasexec := 111;
                  corret(corret.LAST).csucursal := vcagente_padre;
                  --MAL 25581/134316 13/02/2013
                  corret(corret.LAST).tsucursal :=
                     pac_redcomercial.ff_desagente(vcagente_padre,
                                                   pac_md_common.f_get_cxtidioma);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     corret(corret.LAST).csucursal := NULL;
                     --MAL 25581/134316 13/02/2013
                     corret(corret.LAST).tsucursal := NULL;
               END;

               vpasexec := 112;
               corret(corret.LAST).tagente :=
                    pac_redcomercial.ff_desagente(pcorr.cagente, pac_md_common.f_get_cxtidioma);
               vpasexec := 12;
               num_err := pac_md_persona.f_get_persona_agente(vsperson, pcorr.cagente, vpmode,
                                                              corret(corret.LAST), mensajes);

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  RAISE e_object_error;
               END IF;

               vpasexec := 13;

               IF corret(corret.LAST).direcciones IS NULL THEN
                  corret(corret.LAST).direcciones := t_iax_direcciones();
               END IF;

               corret(corret.LAST).direcciones.EXTEND;
               ndirec := corret(corret.LAST).direcciones.LAST;
               corret(corret.LAST).direcciones(ndirec) := ob_iax_direcciones();
               corret(corret.LAST).direcciones(ndirec).cdomici := NVL(vcdomici, 1);
               vpasexec := 14;
               pac_md_listvalores.p_ompledadesdireccions
                                                      (vsperson, NVL(vcdomici, 1), vpmode,
                                                       corret(corret.LAST).direcciones(ndirec),
                                                       mensajes);
            END IF;
         END LOOP;
      END IF;

      RETURN corret;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leecorretaje;

-- BUG19069:DRA:27/09/2011:Fi
/*************************************************************************
Lee los datos del detalle de primas de garantias
param out mensajes : mesajes de error
return             : objeto detprimas
*************************************************************************/
-- Bug 21121 - APD - 01/03/2012 - se crea la funcion
   FUNCTION f_lee_detprimas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pfiniefe IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detprimas IS
      CURSOR estdetprimas IS
         SELECT   s.*, ss.sproduc, ss.cactivi
             FROM estdetprimas s, estgaranseg g, estseguros ss
            WHERE s.sseguro = ss.sseguro
              AND s.sseguro = NVL(vsolicit, psseguro)
              AND s.nriesgo = pnriesgo
              AND s.cgarant = pcgarant
              AND s.finiefe = pfiniefe
              AND s.sseguro = g.sseguro
              AND s.nriesgo = g.nriesgo
              AND s.cgarant = g.cgarant
              AND s.nmovimi = g.nmovimi
              AND s.finiefe = g.finiefe
              AND s.nmovimi = pnmovimi
              AND g.ffinefe IS NULL
         ORDER BY DECODE(s.ccampo, 'TASA', 1, 'IPRITAR', 2, 'IPRIANU', 3, 4), s.norden;

      CURSOR detprimas IS
         SELECT   s.*, ss.sproduc, ss.cactivi
             FROM detprimas s, garanseg g, seguros ss
            WHERE s.sseguro = ss.sseguro
              AND s.sseguro = NVL(vsolicit, psseguro)
              AND s.nriesgo = pnriesgo
              AND s.cgarant = pcgarant
              AND s.finiefe = pfiniefe
              AND s.sseguro = g.sseguro
              AND s.nriesgo = g.nriesgo
              AND s.cgarant = g.cgarant
              AND s.nmovimi = g.nmovimi
              AND s.finiefe = g.finiefe
              AND g.nmovimi = pnmovimi
              AND g.ffinefe IS NULL
         ORDER BY DECODE(s.ccampo, 'TASA', 1, 'IPRITAR', 2, 'IPRIANU', 3, 4), s.norden;

      v_masdatos     t_iax_detprimas := t_iax_detprimas();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro = ' || psseguro || '; pnriesgo = ' || pnriesgo || '; pcgarant = '
            || pcgarant || '; pfiniefe = ' || TO_CHAR(pfiniefe, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_lee_detprimas';

      FUNCTION ff_tcampo(pccampo IN VARCHAR2)
         RETURN VARCHAR2 IS
         vtcampo        codcampo.tcampo%TYPE;
      BEGIN
         SELECT tcampo
           INTO vtcampo
           FROM codcampo
          WHERE ccampo = pccampo;

         RETURN vtcampo;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END ff_tcampo;

      FUNCTION ff_ndecvis(
         psproduc IN NUMBER,
         pcactivi IN NUMBER,
         pcgarant IN NUMBER,
         pccampo IN VARCHAR2,
         pcconcep IN VARCHAR2)
         RETURN NUMBER IS
         vndecvis       detgaranformula.ndecvis%TYPE;
      BEGIN
         BEGIN
            SELECT ndecvis
              INTO vndecvis
              FROM detgaranformula
             WHERE sproduc = psproduc
               AND cactivi = pcactivi
               AND cgarant = pcgarant
               AND ccampo = pccampo
               AND cconcep = pcconcep;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT ndecvis
                 INTO vndecvis
                 FROM detgaranformula
                WHERE sproduc = psproduc
                  AND cactivi = 0
                  AND cgarant = pcgarant
                  AND ccampo = pccampo
                  AND cconcep = pcconcep;
         END;

         RETURN vndecvis;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END ff_ndecvis;
   BEGIN
      vpasexec := 11;

      IF vpmode = 'EST' THEN
         vpasexec := 2;

         FOR pmdatos IN estdetprimas LOOP
            vpasexec := 3;
            v_masdatos.EXTEND;
            v_masdatos(v_masdatos.LAST) := ob_iax_detprimas();
            v_masdatos(v_masdatos.LAST).ccampo := pmdatos.ccampo;
            v_masdatos(v_masdatos.LAST).tcampo := ff_tcampo(pmdatos.ccampo);
            vpasexec := 4;
            v_masdatos(v_masdatos.LAST).cconcep := pmdatos.cconcep;
            v_masdatos(v_masdatos.LAST).tconcep := ff_tcampo(pmdatos.cconcep);
            v_masdatos(v_masdatos.LAST).norden := pmdatos.norden;
            vpasexec := 5;
            v_masdatos(v_masdatos.LAST).iconcep := pmdatos.iconcep;
            v_masdatos(v_masdatos.LAST).iconcep2 := pmdatos.iconcep2;
            v_masdatos(v_masdatos.LAST).ndecvis :=
               ff_ndecvis(pmdatos.sproduc, pmdatos.cactivi, pmdatos.cgarant, pmdatos.ccampo,
                          pmdatos.cconcep);
            vpasexec := 6;
         END LOOP;

         vpasexec := 7;

         IF estdetprimas%ISOPEN THEN
            CLOSE estdetprimas;
         END IF;
      ELSE
         vpasexec := 8;

         FOR pmdatos IN detprimas LOOP
            vpasexec := 9;
            v_masdatos.EXTEND;
            vpasexec := 10;
            v_masdatos(v_masdatos.LAST) := ob_iax_detprimas();
            v_masdatos(v_masdatos.LAST).ccampo := pmdatos.ccampo;
            v_masdatos(v_masdatos.LAST).tcampo := ff_tcampo(pmdatos.ccampo);
            vpasexec := 11;
            v_masdatos(v_masdatos.LAST).cconcep := pmdatos.cconcep;
            v_masdatos(v_masdatos.LAST).tconcep := ff_tcampo(pmdatos.cconcep);
            v_masdatos(v_masdatos.LAST).norden := pmdatos.norden;
            vpasexec := 12;
            v_masdatos(v_masdatos.LAST).iconcep := pmdatos.iconcep;
            v_masdatos(v_masdatos.LAST).iconcep2 := pmdatos.iconcep2;
            v_masdatos(v_masdatos.LAST).ndecvis :=
               ff_ndecvis(pmdatos.sproduc, pmdatos.cactivi, pmdatos.cgarant, pmdatos.ccampo,
                          pmdatos.cconcep);
            vpasexec := 13;
         END LOOP;

         vpasexec := 14;

         IF detprimas%ISOPEN THEN
            CLOSE detprimas;
         END IF;
      END IF;

      vpasexec := 15;
      RETURN v_masdatos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_detprimas;

/*************************************************************************
Lee gestor cobro
param out mensajes : mesajes de error
return             : objeto gestor cobro
*************************************************************************/
-- BUG 0021592 - 08/03/2012 - JMF
   FUNCTION f_leegescobro(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gescobros IS
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leegescobro';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      msj            t_iax_mensajes;   -- ERRORS DESTIMATS AL ELIMINAR UN ASEGURAT

      CURSOR estges IS
         SELECT s.*
           FROM estgescobros s
          WHERE s.sseguro = vsolicit;

      CURSOR polges IS
         SELECT s.*
           FROM gescobros s
          WHERE s.sseguro = vsolicit;

      gesc           t_iax_gescobros := t_iax_gescobros();
      ndirec         NUMBER;
      vcagente       NUMBER;
      num_err        NUMBER;
   BEGIN
      vpasexec := 100;

      IF vpmode = 'EST' THEN
         vpasexec := 110;

         FOR f1 IN estges LOOP
            vpasexec := 120;
            num_err := pac_seguros.f_get_cagente(f1.sseguro, 'EST', vcagente);
            vpasexec := 122;
            gesc.EXTEND;
            gesc(gesc.LAST) := ob_iax_gescobros();
            gesc(gesc.LAST).sperson := f1.sperson;
            gesc(gesc.LAST).cdomici := f1.cdomici;
            vpasexec := 124;
            num_err := pac_md_persona.f_get_persona_agente(f1.sperson, vcagente, vpmode,
                                                           gesc(gesc.LAST), mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            IF gesc(gesc.LAST).direcciones IS NULL THEN
               gesc(gesc.LAST).direcciones := t_iax_direcciones();
            END IF;

            vpasexec := 125;

            IF gesc(gesc.LAST).direcciones.COUNT = 0 THEN
               gesc(gesc.LAST).direcciones.EXTEND;
               gesc(gesc.LAST).direcciones(gesc(gesc.LAST).direcciones.LAST) :=
                                                                          ob_iax_direcciones
                                                                                            ();
            END IF;

            vpasexec := 126;
            gesc(gesc.LAST).direcciones(gesc(gesc.LAST).direcciones.LAST).cdomici := f1.cdomici;
            pac_md_listvalores.p_ompledadesdireccions
                                (f1.sperson, f1.cdomici, vpmode,
                                 gesc(gesc.LAST).direcciones(gesc(gesc.LAST).direcciones.LAST),
                                 msj);

            IF msj IS NOT NULL THEN
               IF msj.COUNT > 0 THEN
                  vpasexec := 127;
                  pac_iobj_mensajes.p_mergemensaje(mensajes, msj);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000832);
                  vpasexec := 128;
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      ELSE
         vpasexec := 130;

         FOR f2 IN polges LOOP
            vpasexec := 140;
            num_err := pac_seguros.f_get_cagente(f2.sseguro, 'REAL', vcagente);
            vpasexec := 142;
            gesc.EXTEND;
            gesc(gesc.LAST) := ob_iax_gescobros();
            gesc(gesc.LAST).sperson := f2.sperson;
            gesc(gesc.LAST).cdomici := f2.cdomici;
            vpasexec := 144;
            num_err := pac_md_persona.f_get_persona_agente(f2.sperson, vcagente, vpmode,
                                                           gesc(gesc.LAST), mensajes);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;

            IF gesc(gesc.LAST).direcciones IS NULL THEN
               gesc(gesc.LAST).direcciones := t_iax_direcciones();
            END IF;

            vpasexec := 145;

            IF gesc(gesc.LAST).direcciones.COUNT = 0 THEN
               gesc(gesc.LAST).direcciones.EXTEND;
               gesc(gesc.LAST).direcciones(gesc(gesc.LAST).direcciones.LAST) :=
                                                                          ob_iax_direcciones
                                                                                            ();
            END IF;

            vpasexec := 146;
            gesc(gesc.LAST).direcciones(gesc(gesc.LAST).direcciones.LAST).cdomici := f2.cdomici;
            pac_md_listvalores.p_ompledadesdireccions
                                (f2.sperson, f2.cdomici, vpmode,
                                 gesc(gesc.LAST).direcciones(gesc(gesc.LAST).direcciones.LAST),
                                 msj);

            IF msj IS NOT NULL THEN
               IF msj.COUNT > 0 THEN
                  vpasexec := 147;
                  pac_iobj_mensajes.p_mergemensaje(mensajes, msj);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000832);
                  vpasexec := 148;
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 150;
      RETURN gesc;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leegescobro;

   FUNCTION f_lee_riesgo(mensajes IN OUT t_iax_mensajes, pnriesgo IN NUMBER DEFAULT NULL)
      RETURN ob_iax_riesgos IS
      CURSOR estrie IS
         SELECT s.cactivi cactivi_seg, s.cramo cramo_seg, r.*
           FROM estriesgos r, estseguros s
          WHERE s.sseguro = vsolicit
            AND r.sseguro = vsolicit
            AND r.nriesgo = pnriesgo;

      CURSOR polrie IS
         SELECT s.cactivi cactivi_seg, s.cramo cramo_seg, r.*
           FROM riesgos r, seguros s
          WHERE s.sseguro = vsolicit
            AND r.sseguro = vsolicit
            AND r.nriesgo = pnriesgo;

      riesgos        ob_iax_riesgos := ob_iax_riesgos();
      cobjase        NUMBER;
      nnum           NUMBER;
      pri            ob_iax_primas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LeeRiesgos';
      v_cactivi      seguros.cactivi%TYPE;
      --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
      v_ttexto       activisegu.tactivi%TYPE;
      --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
      errnum         NUMBER;
   --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
   BEGIN
      IF vpmode = 'EST' THEN
         FOR erie IN estrie LOOP
            riesgos.nriesgo := erie.nriesgo;
            riesgos.triesgo := f_desriesgos(vpmode, vsolicit, erie.nriesgo, mensajes);
            riesgos.fefecto := erie.fefecto;
            riesgos.nmovima := erie.nmovima;
            riesgos.nmovimb := erie.nmovimb;
            riesgos.fanulac := erie.fanulac;   -- BUG10519:DRA:29/07/2009
            --// Recupera la descripcio del risc
            --riesgos(riesgos.last).P_DescRiesgo(cobjase,vsolicit);
            vpasexec := 2;
            riesgos.primas.pdtocom := erie.pdtocom;
            riesgos.primas.precarg := erie.precarg;
            riesgos.primas.pdtotec := erie.pdtotec;
            riesgos.primas.preccom := erie.preccom;
            vpasexec := 3;
            cobjase := f_getobjase(vsolicit, vpmode, mensajes);

            IF cobjase = 1 THEN   --PERSONAL
               vpasexec := 4;
               riesgos.riespersonal := f_leeriesgopersonal(erie.nriesgo, mensajes);
               vpasexec := 5;
               riesgos.riesgoase := f_leeasegurados(erie.nriesgo, mensajes);
            ELSIF cobjase = 2 THEN   --DIRECCION
               vpasexec := 6;
               riesgos.riesdireccion := f_leeriesgodirecciones(erie.nriesgo, mensajes);
               riesgos.tnatrie := erie.tnatrie;
               vpasexec := 7;
               riesgos.riesgoase := f_leeasegurados(erie.nriesgo, mensajes);
            ELSIF cobjase IN(3, 4) THEN
               --riesgos(riesgos.last).triesgo:=ERIE.tnatrie;
               riesgos.tnatrie := erie.tnatrie;
               vpasexec := 8;
               riesgos.riesdescripcion := f_leeriesgodescripcion(erie.nriesgo, mensajes);
               vpasexec := 9;
               riesgos.riesgoase := f_leeasegurados(erie.nriesgo, mensajes);
            ELSIF cobjase = 5 THEN
               vpasexec := 10;
               riesgos.riesgoase := f_leeasegurados(erie.nriesgo, mensajes);
               vpasexec := 11;
               riesgos.riesautos := f_leeriesgoauto(erie.nriesgo, mensajes);
            END IF;

            vpasexec := 12;
            riesgos.preguntas := f_leepreguntasriesgo(erie.nriesgo, mensajes);
            vpasexec := 13;
            riesgos.garantias := f_leegarantias(erie.nriesgo, mensajes);
            vpasexec := 14;
            riesgos.beneficiario := f_leebeneficiarios(erie.nriesgo, mensajes);
            --JRH 03/2008
            vpasexec := 15;
            riesgos.rentirreg := f_leerentasirreg(erie.nriesgo, mensajes);
            riesgos.cactivi := NVL(erie.cactivi, erie.cactivi_seg);
            vpasexec := 16;
            errnum := f_desactivi(riesgos.cactivi, erie.cramo_seg,
                                  pac_md_common.f_get_cxtidioma, v_ttexto);
            --XPL 07/2009 bug 10702
            vpasexec := 17;
            -- Bug 11165 - 16/09/2009 - AMC
            riesgos.prestamo := f_leesaldodeutors(mensajes);
            vpasexec := 18;

            IF errnum = 0 THEN
               riesgos.tactivi := v_ttexto;
            ELSE
               riesgos.tactivi := NULL;
            END IF;

            riesgos.tdescrie := erie.tdescrie;   -- BUG CONF-114 - 21/09/2016 - JAEG
         END LOOP;
      ELSE
         FOR prie IN polrie LOOP
            riesgos.nriesgo := prie.nriesgo;
            riesgos.triesgo := f_desriesgos(vpmode, vsolicit, prie.nriesgo, mensajes);
            riesgos.fefecto := prie.fefecto;
            riesgos.nmovima := prie.nmovima;
            riesgos.nmovimb := prie.nmovimb;
            riesgos.fanulac := prie.fanulac;   -- BUG10519:DRA:29/07/2009
            vpasexec := 20;
            riesgos.primas.pdtocom := prie.pdtocom;
            riesgos.primas.precarg := prie.precarg;
            riesgos.primas.pdtotec := prie.pdtotec;
            riesgos.primas.preccom := prie.preccom;
            vpasexec := 21;
            cobjase := f_getobjase(vsolicit, vpmode, mensajes);

            --// Recupera la descripcio del risc
            --se comenta, porque ya recupera la descripcion arriba.
            --riesgos(riesgos.last).P_DescRiesgo(cobjase,vsolicit);
            IF cobjase = 1 THEN   --PERSONAL
               vpasexec := 22;
               riesgos.riespersonal := f_leeriesgopersonal(prie.nriesgo, mensajes);
               vpasexec := 23;
               riesgos.riesgoase := f_leeasegurados(prie.nriesgo, mensajes);
            ELSIF cobjase = 2 THEN   --DIRECCION
               vpasexec := 24;
               riesgos.riesdireccion := f_leeriesgodirecciones(prie.nriesgo, mensajes);
               riesgos.tnatrie := prie.tnatrie;
               vpasexec := 25;
               riesgos.riesgoase := f_leeasegurados(prie.nriesgo, mensajes);
            ELSIF cobjase IN(3, 4) THEN
               -- riesgos(riesgos.last).triesgo:=PRIE.tnatrie;
               riesgos.tnatrie := prie.tnatrie;
               vpasexec := 26;
               riesgos.riesdescripcion := f_leeriesgodescripcion(prie.nriesgo, mensajes);
               vpasexec := 27;
               riesgos.riesgoase := f_leeasegurados(prie.nriesgo, mensajes);
            ELSIF cobjase = 5 THEN
               vpasexec := 28;
               riesgos.riesgoase := f_leeasegurados(prie.nriesgo, mensajes);
               vpasexec := 29;
               riesgos.riesautos := f_leeriesgoauto(prie.nriesgo, mensajes);
            END IF;

            vpasexec := 30;
            riesgos.preguntas := f_leepreguntasriesgo(prie.nriesgo, mensajes);
            vpasexec := 31;
            riesgos.garantias := f_leegarantias(prie.nriesgo, mensajes);
            vpasexec := 32;
            riesgos.beneficiario := f_leebeneficiarios(prie.nriesgo, mensajes);
            --JRH 03/2008
            vpasexec := 33;
            riesgos.rentirreg := f_leerentasirreg(prie.nriesgo, mensajes);
            --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
            riesgos.cactivi := NVL(prie.cactivi, prie.cactivi_seg);
            vpasexec := 34;
            errnum := f_desactivi(riesgos.cactivi, prie.cramo_seg,
                                  pac_md_common.f_get_cxtidioma, v_ttexto);
            --XPL 07/2009 bug 10702
            vpasexec := 35;
            -- Bug 11165 - 16/09/2009 - AMC
            riesgos.prestamo := f_leesaldodeutors(mensajes);

            IF errnum = 0 THEN
               riesgos.tactivi := v_ttexto;
            ELSE
               riesgos.tactivi := NULL;
            END IF;

            --FIN MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
            riesgos.tdescrie := prie.tdescrie;   -- BUG CONF-114 - 21/09/2016 - JAEG
         END LOOP;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN NULL;
         END IF;
      END IF;

      RETURN riesgos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_riesgo;

--bfp bug 21947 ini
   FUNCTION f_leergaransegcom(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garansegcom IS
      CURSOR c_estgaransegcom IS
         SELECT   s.*
             FROM estgaransegcom s, estgaranseg g
            WHERE s.sseguro = NVL(vsolicit, psseguro)
              AND s.nriesgo = pnriesgo
              AND s.sseguro = g.sseguro
              AND s.nriesgo = g.nriesgo
              AND s.cgarant = g.cgarant
              AND s.nmovimi = g.nmovimi
              AND g.iprianu <> 0
              AND s.nmovimi = NVL(vnmovimi, 1)
              AND s.finiefe = g.finiefe
              AND g.ffinefe IS NULL
         ORDER BY g.norden;

      CURSOR c_garansegcom IS
         SELECT   s.*
             FROM garansegcom s, garanseg g
            WHERE s.sseguro = NVL(vsolicit, psseguro)
              AND s.nriesgo = pnriesgo
              AND s.sseguro = g.sseguro
              AND s.nriesgo = g.nriesgo
              AND s.cgarant = g.cgarant
              AND s.finiefe = g.finiefe
              AND g.iprianu <> 0
              AND s.nmovimi = g.nmovimi
              AND g.nmovimi = (SELECT MAX(g2.nmovimi)
                                 FROM garanseg g2
                                WHERE g2.sseguro = g.sseguro
                                  AND g2.nriesgo = g.nriesgo
                                  AND g2.cgarant = g.cgarant
                                  AND g2.ffinefe IS NULL)
              AND g.ffinefe IS NULL
         ORDER BY g.norden;

      v_masdatos     t_iax_garansegcom := t_iax_garansegcom();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leergaransegcom';
      v_res          NUMBER;
   BEGIN
      vpasexec := 11;

      IF vpmode = 'EST' THEN
         vpasexec := 2;

         FOR pmdatos IN c_estgaransegcom LOOP
            vpasexec := 3;
            v_masdatos.EXTEND;
            vpasexec := 33;
            v_masdatos(v_masdatos.LAST) := ob_iax_garansegcom();
            vpasexec := 34;
            --            v_masdatos(v_masdatos.LAST).sseguro := pmdatos.sseguro;
            --            v_masdatos(v_masdatos.LAST).nriesgo := pmdatos.nriesgo;
            v_masdatos(v_masdatos.LAST).cgarant := pmdatos.cgarant;
            v_masdatos(v_masdatos.LAST).tgarant :=
                                ff_desgarantia(pmdatos.cgarant, pac_md_common.f_get_cxtidioma);
            vpasexec := 35;
            v_masdatos(v_masdatos.LAST).nmovimi := pmdatos.nmovimi;
            vpasexec := 36;
            v_masdatos(v_masdatos.LAST).finiefe := pmdatos.finiefe;
            vpasexec := 37;
            v_masdatos(v_masdatos.LAST).cmodcom := pmdatos.cmodcom;
            vpasexec := 38;
            v_masdatos(v_masdatos.LAST).tmodcom :=
                           ff_desvalorfijo(67, pac_md_common.f_get_cxtidioma, pmdatos.cmodcom);
            v_masdatos(v_masdatos.LAST).ninialt := pmdatos.ninialt;
            vpasexec := 4;
            v_masdatos(v_masdatos.LAST).pcomisi := pmdatos.pcomisi;
            v_masdatos(v_masdatos.LAST).nfinalt := pmdatos.nfinalt;
            v_masdatos(v_masdatos.LAST).pcomisicua := pmdatos.pcomisicua;
            vpasexec := 5;
            vpasexec := 6;
            vpasexec := 6;
         END LOOP;

         vpasexec := 7;

         IF c_estgaransegcom%ISOPEN THEN
            CLOSE c_estgaransegcom;
         END IF;
      ELSE
         vpasexec := 8;

         FOR pmdatos IN c_garansegcom LOOP
            vpasexec := 9;
            v_masdatos.EXTEND;
            vpasexec := 10;
            v_masdatos(v_masdatos.LAST) := ob_iax_garansegcom();
            --            v_masdatos(v_masdatos.LAST).sseguro := pmdatos.sseguro;
            --            v_masdatos(v_masdatos.LAST).nriesgo := pmdatos.nriesgo;
            v_masdatos(v_masdatos.LAST).tgarant :=
                                ff_desgarantia(pmdatos.cgarant, pac_md_common.f_get_cxtidioma);
            vpasexec := 35;
            v_masdatos(v_masdatos.LAST).nmovimi := pmdatos.nmovimi;
            vpasexec := 36;
            v_masdatos(v_masdatos.LAST).finiefe := pmdatos.finiefe;
            vpasexec := 37;
            v_masdatos(v_masdatos.LAST).cmodcom := pmdatos.cmodcom;
            vpasexec := 38;
            v_masdatos(v_masdatos.LAST).tmodcom :=
                           ff_desvalorfijo(67, pac_md_common.f_get_cxtidioma, pmdatos.cmodcom);
            v_masdatos(v_masdatos.LAST).ninialt := pmdatos.ninialt;
            vpasexec := 11;
            v_masdatos(v_masdatos.LAST).pcomisi := pmdatos.pcomisi;
            v_masdatos(v_masdatos.LAST).nfinalt := pmdatos.nfinalt;
            v_masdatos(v_masdatos.LAST).pcomisicua := pmdatos.pcomisicua;
            vpasexec := 12;
            --            v_masdatos(v_masdatos.LAST).falta := pmdatos.falta;
            --            v_masdatos(v_masdatos.LAST).cusualt := pmdatos.cusualt;
            --            v_masdatos(v_masdatos.LAST).fmodifi := pmdatos.fmodifi;
            --            v_masdatos(v_masdatos.LAST).cusumod := pmdatos.cusumod;
            vpasexec := 13;
         END LOOP;

         vpasexec := 14;

         IF c_garansegcom%ISOPEN THEN
            CLOSE c_garansegcom;
         END IF;
      END IF;

      vpasexec := 15;
      RETURN v_masdatos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leergaransegcom;

   FUNCTION f_leerfranquicias(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_bonfranseg IS
      CURSOR c_estfranq IS
         SELECT s.*
           FROM estbf_bonfranseg s
     INNER JOIN bf_proactgrup pag ON pag.cgrup = s.cgrup                                                                   -- IAXIS-5423 CJMR 23/09/2019
     INNER JOIN estseguros seg ON seg.sseguro = s.sseguro AND seg.sproduc = pag.sproduc AND seg.cactivi = pag.cactivi      -- IAXIS-5423 CJMR 23/09/2019
          WHERE s.sseguro = NVL(vsolicit, psseguro)
            AND s.nriesgo = pnriesgo
            AND s.nmovimi = NVL(vnmovimi, 1)
            AND s.ffinefe IS NULL
       ORDER BY pag.norden;                                                                                                -- IAXIS-5423 CJMR 23/09/2019

      CURSOR c_franq IS
         SELECT s.*
           FROM bf_bonfranseg s
     INNER JOIN bf_proactgrup pag ON pag.cgrup = s.cgrup                                                                   -- IAXIS-5423 CJMR 23/09/2019
     INNER JOIN seguros seg ON seg.sseguro = s.sseguro AND seg.sproduc = pag.sproduc AND seg.cactivi = pag.cactivi         -- IAXIS-5423 CJMR 23/09/2019
          WHERE s.sseguro = NVL(vsolicit, psseguro)
            AND s.nriesgo = pnriesgo
            AND s.nmovimi = (SELECT MAX(g2.nmovimi)
                               FROM bf_bonfranseg g2
                              WHERE g2.sseguro = s.sseguro
                                AND g2.nriesgo = s.nriesgo
                                AND g2.ffinefe IS NULL)
            AND s.ffinefe IS NULL
       ORDER BY pag.norden;                                                                                                -- IAXIS-5423 CJMR 23/09/2019

      v_masdatos     t_iax_bonfranseg := t_iax_bonfranseg();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leerfranquicias';
      v_res          NUMBER;
      vctipgrupsubgrup NUMBER;
      vnumerr        NUMBER;
      lvalor2        NUMBER;
      limpmin        NUMBER;
      limpmax        NUMBER;
      vid_listlibre  NUMBER;
      vvalor         NUMBER;
   BEGIN
      vpasexec := 11;

      IF vpmode = 'EST' THEN
         vpasexec := 2;

         FOR pmdatos IN c_estfranq LOOP
            vpasexec := 3;
            v_masdatos.EXTEND;
            vpasexec := 33;
            v_masdatos(v_masdatos.LAST) := ob_iax_bonfranseg();
            vpasexec := 34;
            v_masdatos(v_masdatos.LAST).cgrup := pmdatos.cgrup;
            vpasexec := 35;
            v_masdatos(v_masdatos.LAST).nmovimi := pmdatos.nmovimi;
            vpasexec := 36;
            v_masdatos(v_masdatos.LAST).csubgrup := pmdatos.csubgrup;
            vpasexec := 37;
            v_masdatos(v_masdatos.LAST).cnivel := pmdatos.cnivel;
            v_masdatos(v_masdatos.LAST).cniveldefecto := pmdatos.cniveldefecto;

            BEGIN
               SELECT bd.tgrup,
                      bc.ctipvisgrup,
                      ff_desvalorfijo(309, pac_md_common.f_get_cxtidioma, bc.ctipvisgrup)
                 INTO v_masdatos(v_masdatos.LAST).tgrup,
                      v_masdatos(v_masdatos.LAST).ctipvisgrup,
                      v_masdatos(v_masdatos.LAST).ttipvisgrup
                 FROM bf_desgrup bd, bf_codgrup bc
                WHERE bd.cgrup = pmdatos.cgrup
                  AND bd.cgrup = bc.cgrup
                  AND bd.cversion = bc.cversion
                  AND bd.cempres = bc.cempres
                  AND bd.cversion = pmdatos.cversion
                  AND bd.cempres = pac_md_common.f_get_cxtempresa
                  AND bd.cidioma = pac_md_common.f_get_cxtidioma;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_masdatos(v_masdatos.LAST).tgrup := '';
            END;

            BEGIN
               SELECT tgrupsubgrup, ctipgrupsubgrup
                 INTO v_masdatos(v_masdatos.LAST).tsubgrup, vctipgrupsubgrup
                 FROM bf_desgrupsubgrup bd, bf_grupsubgrup bg
                WHERE bd.cgrup = pmdatos.cgrup
                  AND bd.cversion = pmdatos.cversion
                  AND bd.cempres = pac_md_common.f_get_cxtempresa
                  AND bd.cidioma = pac_md_common.f_get_cxtidioma
                  AND bd.csubgrup = pmdatos.csubgrup
                  AND bd.cgrup = bg.cgrup
                  AND bd.csubgrup = bg.csubgrup
                  AND bd.cversion = bg.cversion
                  AND bd.cempres = bg.cempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_masdatos(v_masdatos.LAST).tsubgrup := '';
            END;

            BEGIN
               SELECT tnivel, id_listlibre
                 INTO v_masdatos(v_masdatos.LAST).tnivel, vid_listlibre
                 FROM bf_desnivel bd, bf_detnivel bt
                WHERE bd.cgrup = pmdatos.cgrup
                  AND bd.csubgrup = pmdatos.csubgrup
                  AND bd.cversion = pmdatos.cversion
                  AND bd.cempres = pac_md_common.f_get_cxtempresa
                  AND bd.cidioma = pac_md_common.f_get_cxtidioma
                  AND bd.cnivel = pmdatos.cnivel
                  AND bd.cgrup = bt.cgrup
                  AND bd.csubgrup = bt.csubgrup
                  AND bd.cversion = bt.cversion
                  AND bd.cempres = bt.cempres
                  AND bd.cnivel = bt.cnivel;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_masdatos(v_masdatos.LAST).tnivel := '';
            END;

            v_masdatos(v_masdatos.LAST).cversion := pmdatos.cversion;
            vpasexec := 4;
            v_masdatos(v_masdatos.LAST).finiefe := pmdatos.finiefe;
            v_masdatos(v_masdatos.LAST).ctipgrup := pmdatos.ctipgrup;
            v_masdatos(v_masdatos.LAST).cvalor1 := pmdatos.cvalor1;
            v_masdatos(v_masdatos.LAST).tvalor1 := '';
            v_masdatos(v_masdatos.LAST).impvalor1 := pmdatos.impvalor1;
            v_masdatos(v_masdatos.LAST).cvalor2 := pmdatos.cvalor2;
            v_masdatos(v_masdatos.LAST).tvalor2 := '';
            v_masdatos(v_masdatos.LAST).impvalor2 := pmdatos.impvalor2;
            v_masdatos(v_masdatos.LAST).cimpmin := pmdatos.cimpmin;
            v_masdatos(v_masdatos.LAST).timpmin := '';
            v_masdatos(v_masdatos.LAST).impmin := pmdatos.impmin;
            v_masdatos(v_masdatos.LAST).cimpmax := pmdatos.cimpmax;
            v_masdatos(v_masdatos.LAST).timpmax := '';
            v_masdatos(v_masdatos.LAST).ffinefe := pmdatos.ffinefe;
            v_masdatos(v_masdatos.LAST).impmax := pmdatos.impmax;
            v_masdatos(v_masdatos.LAST).ctipgrupsubgrup := vctipgrupsubgrup;

            IF vctipgrupsubgrup = 2 THEN
               v_masdatos(v_masdatos.LAST).tnivel := pmdatos.impvalor1;
            ELSIF vctipgrupsubgrup IN(3, 4) THEN
               IF pmdatos.cvalor1 IS NOT NULL THEN
                  SELECT id_listlibre_2, id_listlibre_min, id_listlibre_max, cvalor
                    INTO lvalor2, limpmin, limpmax, vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = vid_listlibre
                     AND catribu = pmdatos.cvalor1;

                  v_masdatos(v_masdatos.LAST).tvalor1 :=
                        ff_desvalorfijo(vvalor, pac_md_common.f_get_cxtidioma, pmdatos.cvalor1);
               END IF;

               IF pmdatos.cvalor2 IS NOT NULL
                  AND lvalor2 IS NOT NULL THEN
                  SELECT cvalor
                    INTO vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = lvalor2
                     AND catribu = pmdatos.cvalor2;

                  v_masdatos(v_masdatos.LAST).tvalor2 :=
                        ff_desvalorfijo(vvalor, pac_md_common.f_get_cxtidioma, pmdatos.cvalor2);
               END IF;

               IF pmdatos.cimpmin IS NOT NULL
                  AND limpmin IS NOT NULL THEN
                  SELECT cvalor
                    INTO vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = limpmin
                     AND catribu = pmdatos.cimpmin;

                  v_masdatos(v_masdatos.LAST).timpmin :=
                        ff_desvalorfijo(vvalor, pac_md_common.f_get_cxtidioma, pmdatos.cimpmin);
               END IF;

               IF pmdatos.cimpmax IS NOT NULL
                  AND limpmax IS NOT NULL THEN
                  SELECT cvalor
                    INTO vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = limpmax
                     AND catribu = pmdatos.cimpmax;

                  v_masdatos(v_masdatos.LAST).timpmax :=
                        ff_desvalorfijo(vvalor, pac_md_common.f_get_cxtidioma, pmdatos.cimpmax);
               END IF;
            END IF;

            vpasexec := 5;
         END LOOP;

         vpasexec := 7;

         IF c_estfranq%ISOPEN THEN
            CLOSE c_estfranq;
         END IF;
      ELSE
         vpasexec := 8;

         FOR pmdatos IN c_franq LOOP
            vpasexec := 3;
            v_masdatos.EXTEND;
            vpasexec := 33;
            v_masdatos(v_masdatos.LAST) := ob_iax_bonfranseg();
            vpasexec := 34;
            v_masdatos(v_masdatos.LAST).cgrup := pmdatos.cgrup;
            vpasexec := 35;
            v_masdatos(v_masdatos.LAST).nmovimi := pmdatos.nmovimi;
            vpasexec := 36;
            v_masdatos(v_masdatos.LAST).csubgrup := pmdatos.csubgrup;
            vpasexec := 37;
            v_masdatos(v_masdatos.LAST).cnivel := pmdatos.cnivel;
            v_masdatos(v_masdatos.LAST).cniveldefecto := pmdatos.cniveldefecto;
            v_masdatos(v_masdatos.LAST).tgrup := '';
            v_masdatos(v_masdatos.LAST).tsubgrup := '';

            BEGIN
               SELECT bd.tgrup,
                      bc.ctipvisgrup,
                      ff_desvalorfijo(309, pac_md_common.f_get_cxtidioma, bc.ctipvisgrup)
                 INTO v_masdatos(v_masdatos.LAST).tgrup,
                      v_masdatos(v_masdatos.LAST).ctipvisgrup,
                      v_masdatos(v_masdatos.LAST).ttipvisgrup
                 FROM bf_desgrup bd, bf_codgrup bc
                WHERE bd.cgrup = pmdatos.cgrup
                  AND bd.cgrup = bc.cgrup
                  AND bd.cversion = bc.cversion
                  AND bd.cempres = bc.cempres
                  AND bd.cversion = pmdatos.cversion
                  AND bd.cempres = pac_md_common.f_get_cxtempresa
                  AND bd.cidioma = pac_md_common.f_get_cxtidioma;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_masdatos(v_masdatos.LAST).tgrup := '';
            END;

            BEGIN
               SELECT tgrupsubgrup, ctipgrupsubgrup
                 INTO v_masdatos(v_masdatos.LAST).tsubgrup, vctipgrupsubgrup
                 FROM bf_desgrupsubgrup bd, bf_grupsubgrup bg
                WHERE bd.cgrup = pmdatos.cgrup
                  AND bd.cversion = pmdatos.cversion
                  AND bd.cempres = pac_md_common.f_get_cxtempresa
                  AND bd.cidioma = pac_md_common.f_get_cxtidioma
                  AND bd.csubgrup = pmdatos.csubgrup
                  AND bd.cgrup = bg.cgrup
                  AND bd.csubgrup = bg.csubgrup
                  AND bd.cversion = bg.cversion
                  AND bd.cempres = bg.cempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_masdatos(v_masdatos.LAST).tsubgrup := '';
            END;

            BEGIN
               SELECT tnivel, id_listlibre
                 INTO v_masdatos(v_masdatos.LAST).tnivel, vid_listlibre
                 FROM bf_desnivel bd, bf_detnivel bt
                WHERE bd.cgrup = pmdatos.cgrup
                  AND bd.csubgrup = pmdatos.csubgrup
                  AND bd.cversion = pmdatos.cversion
                  AND bd.cempres = pac_md_common.f_get_cxtempresa
                  AND bd.cidioma = pac_md_common.f_get_cxtidioma
                  AND bd.cnivel = pmdatos.cnivel
                  AND bd.cgrup = bt.cgrup
                  AND bd.csubgrup = bt.csubgrup
                  AND bd.cversion = bt.cversion
                  AND bd.cempres = bt.cempres
                  AND bd.cnivel = bt.cnivel;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_masdatos(v_masdatos.LAST).tnivel := '';
            END;

            v_masdatos(v_masdatos.LAST).cversion := pmdatos.cversion;
            vpasexec := 4;
            v_masdatos(v_masdatos.LAST).finiefe := pmdatos.finiefe;
            v_masdatos(v_masdatos.LAST).ctipgrup := pmdatos.ctipgrup;
            v_masdatos(v_masdatos.LAST).cvalor1 := pmdatos.cvalor1;
            v_masdatos(v_masdatos.LAST).tvalor1 := '';
            v_masdatos(v_masdatos.LAST).impvalor1 := pmdatos.impvalor1;
            v_masdatos(v_masdatos.LAST).cvalor2 := pmdatos.cvalor2;
            v_masdatos(v_masdatos.LAST).tvalor2 := '';
            v_masdatos(v_masdatos.LAST).impvalor2 := pmdatos.impvalor2;
            v_masdatos(v_masdatos.LAST).cimpmin := pmdatos.cimpmin;
            v_masdatos(v_masdatos.LAST).timpmin := '';
            v_masdatos(v_masdatos.LAST).impmin := pmdatos.impmin;
            v_masdatos(v_masdatos.LAST).impmax := pmdatos.impmax;
            v_masdatos(v_masdatos.LAST).cimpmax := pmdatos.cimpmax;
            v_masdatos(v_masdatos.LAST).timpmax := '';
            v_masdatos(v_masdatos.LAST).ffinefe := pmdatos.ffinefe;
            v_masdatos(v_masdatos.LAST).ctipgrupsubgrup := vctipgrupsubgrup;

            IF vctipgrupsubgrup = 2 THEN
               v_masdatos(v_masdatos.LAST).tnivel := pmdatos.impvalor1;
            ELSIF vctipgrupsubgrup IN(3, 4) THEN
               IF pmdatos.cvalor1 IS NOT NULL THEN
                  SELECT id_listlibre_2, id_listlibre_min, id_listlibre_max, cvalor
                    INTO lvalor2, limpmin, limpmax, vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = vid_listlibre
                     AND catribu = pmdatos.cvalor1;

                  v_masdatos(v_masdatos.LAST).tvalor1 :=
                        ff_desvalorfijo(vvalor, pac_md_common.f_get_cxtidioma, pmdatos.cvalor1);
               END IF;

               IF pmdatos.cvalor2 IS NOT NULL
                  AND lvalor2 IS NOT NULL THEN
                  SELECT cvalor
                    INTO vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = lvalor2
                     AND catribu = pmdatos.cvalor2;

                  v_masdatos(v_masdatos.LAST).tvalor2 :=
                        ff_desvalorfijo(vvalor, pac_md_common.f_get_cxtidioma, pmdatos.cvalor2);
               END IF;

               IF pmdatos.cimpmin IS NOT NULL
                  AND limpmin IS NOT NULL THEN
                  SELECT cvalor
                    INTO vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = limpmin
                     AND catribu = pmdatos.cimpmin;

                  v_masdatos(v_masdatos.LAST).timpmin :=
                        ff_desvalorfijo(vvalor, pac_md_common.f_get_cxtidioma, pmdatos.cimpmin);
               END IF;

               IF pmdatos.cimpmax IS NOT NULL
                  AND limpmax IS NOT NULL THEN
                  SELECT cvalor
                    INTO vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = limpmax
                     AND catribu = pmdatos.cimpmax;

                  v_masdatos(v_masdatos.LAST).timpmax :=
                        ff_desvalorfijo(vvalor, pac_md_common.f_get_cxtidioma, pmdatos.cimpmax);
               END IF;
            END IF;
         END LOOP;

         vpasexec := 14;

         IF c_franq%ISOPEN THEN
            CLOSE c_franq;
         END IF;
      END IF;

      vpasexec := 15;
      RETURN v_masdatos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leerfranquicias;

--bfp bug 21947 fin
--BUG 21657--ETM--04/06/2012
   FUNCTION f_leeinquiaval(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_inquiaval IS
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leeinquiaval';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vcagente       NUMBER;
      num_err        NUMBER;

      -- Solo maestro los inquilinos que estan vigentes, porque estoy en contrataci?n o suplemento
      CURSOR estinquival IS
         SELECT s.sseguro, s.sperson, s.nriesgo, s.nmovimi, s.ctipfig, s.cdomici, s.iingrmen,
                s.iingranual, s.ffecini, s.ffecfin, s.ctipcontrato, s.csitlaboral,
                s.csupfiltro
           FROM estinquiaval s
          WHERE s.sseguro = vsolicit
            AND s.nmovimi = (SELECT MAX(s1.nmovimi)
                               FROM estinquiaval s1
                              WHERE s1.sseguro = s.sseguro);

      CURSOR polinquival IS
         -- Aqui tengo que mostrar todos las figures que han formado parte de la vida de la p?liza
         SELECT s.*
           FROM inquiaval s
          WHERE s.sseguro = vsolicit
            AND(s.sperson, s.nmovimi) IN(SELECT   sperson, MAX(s1.nmovimi)
                                             FROM inquiaval s1
                                            WHERE s1.sseguro = s.sseguro
                                         GROUP BY sperson);

      vinquival      t_iax_inquiaval := t_iax_inquiaval();
   BEGIN
      IF vpmode = 'EST' THEN
         vpasexec := 1;

         FOR reg IN estinquival LOOP
            num_err := pac_seguros.f_get_cagente(reg.sseguro, 'EST', vcagente);
            vinquival.EXTEND;
            vinquival(vinquival.LAST) := ob_iax_inquiaval();
            vinquival(vinquival.LAST).sseguro := reg.sseguro;
            vinquival(vinquival.LAST).sperson := reg.sperson;
            vinquival(vinquival.LAST).nmovimi := reg.nmovimi;
            vinquival(vinquival.LAST).nriesgo := reg.nriesgo;
            vinquival(vinquival.LAST).ctipfig := reg.ctipfig;
            vinquival(vinquival.LAST).cdomici := reg.cdomici;
            vinquival(vinquival.LAST).iingrmen := reg.iingrmen;
            vinquival(vinquival.LAST).iingranual := reg.iingranual;
            vinquival(vinquival.LAST).ffecini := reg.ffecini;
            vinquival(vinquival.LAST).ffecfin := reg.ffecfin;
            vinquival(vinquival.LAST).ctipcontrato := reg.ctipcontrato;
            vinquival(vinquival.LAST).csitlaboral := reg.csitlaboral;
            vinquival(vinquival.LAST).csupfiltro := reg.csupfiltro;
            num_err := pac_md_persona.f_get_persona_agente(reg.sperson, vcagente, vpmode,
                                                           vinquival(vinquival.LAST),
                                                           mensajes);

            IF mensajes IS NOT NULL THEN
               IF mensajes.COUNT > 0 THEN
                  vpasexec := 2;
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      ELSE
         vpasexec := 3;

         FOR reg IN polinquival LOOP
            num_err := pac_seguros.f_get_cagente(reg.sseguro, 'REAL', vcagente);
            vinquival.EXTEND;
            vinquival(vinquival.LAST) := ob_iax_inquiaval();
            vinquival(vinquival.LAST).sseguro := reg.sseguro;
            vinquival(vinquival.LAST).sperson := reg.sperson;
            vinquival(vinquival.LAST).nmovimi := reg.nmovimi;
            vinquival(vinquival.LAST).nriesgo := reg.nriesgo;
            vinquival(vinquival.LAST).ctipfig := reg.ctipfig;
            vinquival(vinquival.LAST).cdomici := reg.cdomici;
            vinquival(vinquival.LAST).iingrmen := reg.iingrmen;
            vinquival(vinquival.LAST).iingranual := reg.iingranual;
            vinquival(vinquival.LAST).ffecini := reg.ffecini;
            vinquival(vinquival.LAST).ffecfin := reg.ffecfin;
            vinquival(vinquival.LAST).ctipcontrato := reg.ctipcontrato;
            vinquival(vinquival.LAST).csitlaboral := reg.csitlaboral;
            vinquival(vinquival.LAST).csupfiltro := reg.csupfiltro;
            num_err := pac_md_persona.f_get_persona_agente(reg.sperson, vcagente, vpmode,
                                                           vinquival(vinquival.LAST),
                                                           mensajes);

            IF mensajes IS NOT NULL THEN
               IF mensajes.COUNT > 0 THEN
                  vpasexec := 4;
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 5;
      RETURN vinquival;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeinquiaval;

--fin BUG 21657--ETM--04/06/2012
-- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
/*************************************************************************
Lee cuadro de coaseguro
param in psseguro         : Numero seguro
param in out mensajes     : mesajes de error
param in pmodo default 0  : Informa en que modo estamos:
1.-Alta poliza
otros. - No alta poliza.
return                    : objeto cuadro coa.
*************************************************************************/
   FUNCTION f_leercoacuadro(
      psseguro IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pmodo IN NUMBER DEFAULT 0)
      RETURN ob_iax_coacuadro IS
      CURSOR estcce IS
         SELECT c.sseguro, c.ncuacoa, c.ccompan, c.pcomcoa, c.pcomgas, c.pcomcon, c.pcescoa,
                c.pcesion
           FROM estcoacedido c
          WHERE c.sseguro = psseguro
            AND c.ncuacoa = NVL(vnmovimi, 1);

      CURSOR coaced IS
         SELECT c.sseguro, c.ncuacoa, c.ccompan, c.pcomcoa, c.pcomgas, c.pcomcon, c.pcescoa,
                c.pcesion
           FROM coacedido c
          WHERE c.sseguro = psseguro
            AND c.ncuacoa = (SELECT MAX(ncuacoa)
                               FROM coacedido
                              WHERE sseguro = psseguro
                                AND ncuacoa <= NVL(vnmovimi, 1));

      --BUG 0023183: XVM :26/10/2012--Cursor coacedido.
      CURSOR coacedido IS
         SELECT cc.sseguro, cc.ncuacoa, cc.ccompan, cc.pcomcoa, cc.pcomgas, cc.pcomcon,
                cc.pcescoa, cc.pcesion
           FROM seguros s, coacedido cc
          WHERE s.npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
            AND s.ncertif = 0
            AND cc.ncuacoa = (SELECT MAX(ncuacoa)
                                FROM coacedido
                               WHERE sseguro = s.sseguro)
            AND s.sseguro = cc.sseguro;

      vcoacuadro     ob_iax_coacuadro := ob_iax_coacuadro();
      cobjase        NUMBER;
      nnum           NUMBER;
      vcoace         t_iax_coacedido;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leercoacuadro';
      vsproduc       productos.sproduc%TYPE;
      v_coaseguro    NUMBER(1);
      vtipocoa       seguros.ctipcoa%TYPE;
      vncuacoa       seguros.ncuacoa%TYPE;
   BEGIN
      vcoace := t_iax_coacedido();
      vsproduc := pac_iax_produccion.poliza.det_poliza.sproduc;

      --BUG 0023183: XVM :26/10/2012--INI.
      IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', vsproduc) = 1
         AND NOT pac_iax_produccion.isaltacol
         AND pmodo = 1 THEN
         nnum := pac_productos.f_get_herencia_col(vsproduc, 14, v_coaseguro);

         IF NVL(v_coaseguro, 0) = 1
            AND nnum = 0 THEN
            SELECT ctipcoa, ncuacoa
              INTO vtipocoa, vncuacoa
              FROM seguros
             WHERE npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
               AND ncertif = 0;

            pac_iax_produccion.poliza.det_poliza.ctipcoa := vtipocoa;
            pac_iax_produccion.poliza.det_poliza.ncuacoa := vncuacoa;

            IF vtipocoa IS NOT NULL THEN
               pac_iax_produccion.poliza.det_poliza.ttipcoa :=
                            ff_desvalorfijo(800109, pac_md_common.f_get_cxtidioma(), vtipocoa);
            END IF;

            BEGIN
               SELECT e.ncuacoa, e.ploccoa, e.finicoa,
                      e.ffincoa, e.fcuacoa, e.ccompan,
                      e.npoliza, e.nendoso
                 INTO vcoacuadro.ncuacoa, vcoacuadro.ploccoa, vcoacuadro.finicoa,
                      vcoacuadro.ffincoa, vcoacuadro.fcuacoa, vcoacuadro.ccompan,
                      vcoacuadro.npoliza, vcoacuadro.endoso
                 FROM coacuadro e, seguros s
                WHERE s.npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
                  AND s.ncertif = 0
                  AND e.sseguro = s.sseguro
                  AND e.ncuacoa = (SELECT MAX(ee.ncuacoa)
                                     FROM coacuadro ee
                                    WHERE ee.sseguro = s.sseguro);
            --  and e.c.ncuacoa = NVL(vnmovimi, 1);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN NULL;
            END;

            IF vcoacuadro.ccompan IS NOT NULL THEN
               SELECT companias.tcompani
                 INTO vcoacuadro.tcompan
                 FROM companias
                WHERE ccompani = vcoacuadro.ccompan;
            END IF;

            FOR reg IN coacedido LOOP
               vcoace.EXTEND;
               vcoace(vcoace.LAST) := ob_iax_coacedido();
               vcoace(vcoace.LAST).ccompan := reg.ccompan;

               SELECT tcompani
                 INTO vcoace(vcoace.LAST).tcompan
                 FROM companias
                WHERE ccompani = reg.ccompan;

               vcoace(vcoace.LAST).pcomcoa := reg.pcomcoa;
               vcoace(vcoace.LAST).pcomgas := reg.pcomgas;
               vcoace(vcoace.LAST).pcomcon := reg.pcomcon;
               vcoace(vcoace.LAST).pcescoa := reg.pcescoa;
               vcoace(vcoace.LAST).pcesion := reg.pcesion;
            END LOOP;
         END IF;
      ELSE
         --BUG 0023183: XVM :26/10/2012--FIN.
         IF vpmode = 'EST' THEN
            BEGIN
               SELECT e.ncuacoa, e.ploccoa, e.finicoa,
                      e.ffincoa, e.fcuacoa, e.ccompan,
                      e.npoliza, e.nendoso
                 INTO vcoacuadro.ncuacoa, vcoacuadro.ploccoa, vcoacuadro.finicoa,
                      vcoacuadro.ffincoa, vcoacuadro.fcuacoa, vcoacuadro.ccompan,
                      vcoacuadro.npoliza, vcoacuadro.endoso
                 FROM estcoacuadro e
                WHERE e.sseguro = psseguro;
            --  and e.c.ncuacoa = NVL(vnmovimi, 1);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN NULL;
            END;

            IF vcoacuadro.ccompan IS NOT NULL THEN
               SELECT companias.tcompani
                 INTO vcoacuadro.tcompan
                 FROM companias
                WHERE ccompani = vcoacuadro.ccompan;
            END IF;

            FOR ecce IN estcce LOOP
               vcoace.EXTEND;
               vcoace(vcoace.LAST) := ob_iax_coacedido();
               vcoace(vcoace.LAST).ccompan := ecce.ccompan;

               SELECT tcompani
                 INTO vcoace(vcoace.LAST).tcompan
                 FROM companias
                WHERE ccompani = ecce.ccompan;

               vcoace(vcoace.LAST).pcomcoa := ecce.pcomcoa;
               vcoace(vcoace.LAST).pcomgas := ecce.pcomgas;
               vcoace(vcoace.LAST).pcomcon := ecce.pcomcon;
               vcoace(vcoace.LAST).pcescoa := ecce.pcescoa;
               vcoace(vcoace.LAST).pcesion := ecce.pcesion;
            END LOOP;
         ELSE
            BEGIN
               SELECT e.ncuacoa, e.ploccoa, e.finicoa,
                      e.ffincoa, e.fcuacoa, e.ccompan,
                      e.npoliza, e.nendoso
                 INTO vcoacuadro.ncuacoa, vcoacuadro.ploccoa, vcoacuadro.finicoa,
                      vcoacuadro.ffincoa, vcoacuadro.fcuacoa, vcoacuadro.ccompan,
                      vcoacuadro.npoliza, vcoacuadro.endoso
                 FROM coacuadro e
                WHERE e.sseguro = psseguro
                  AND e.ncuacoa = (SELECT MAX(ncuacoa)
                                     FROM coacuadro
                                    WHERE sseguro = psseguro
                                      AND ncuacoa <= NVL(vnmovimi, 1));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN NULL;
            END;

            IF vcoacuadro.ccompan IS NOT NULL THEN
               SELECT companias.tcompani
                 INTO vcoacuadro.tcompan
                 FROM companias
                WHERE ccompani = vcoacuadro.ccompan;
            END IF;

            FOR pcce IN coaced LOOP
               vcoace.EXTEND;
               vcoace(vcoace.LAST) := ob_iax_coacedido();
               vcoace(vcoace.LAST).ccompan := pcce.ccompan;

               SELECT tcompani
                 INTO vcoace(vcoace.LAST).tcompan
                 FROM companias
                WHERE ccompani = pcce.ccompan;

               --  coacedido(coacedido.LAST).tcompan := tcompani;
               vcoace(vcoace.LAST).pcomcoa := pcce.pcomcoa;
               vcoace(vcoace.LAST).pcomgas := pcce.pcomgas;
               vcoace(vcoace.LAST).pcomcon := pcce.pcomcon;
               vcoace(vcoace.LAST).pcescoa := pcce.pcescoa;
               vcoace(vcoace.LAST).pcesion := pcce.pcesion;
            END LOOP;
         END IF;
      END IF;

      vcoacuadro.coacedido := vcoace;
      --      IF mensajes IS NOT NULL THEN
      --         IF mensajes.COUNT > 0 THEN
      --            RETURN NULL;
      --         END IF;
      --      END IF;
      RETURN vcoacuadro;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leercoacuadro;

-- Fin Bug 0023183
-- ini Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_leeretorno(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_retorno IS
      CURSOR estretrn IS
         SELECT s.*
           FROM estrtn_convenio s
          WHERE s.sseguro = vsolicit
            AND s.nmovimi = (SELECT MAX(s1.nmovimi)
                               FROM estrtn_convenio s1
                              WHERE s1.sseguro = s.sseguro);

      CURSOR polretrn IS
         SELECT s.*
           FROM rtn_convenio s
          WHERE s.sseguro = vsolicit
            AND s.nmovimi = (SELECT MAX(s1.nmovimi)
                               FROM pregunpolseg
                                                /*rtn_convenio*/
                                    s1
                              WHERE s1.sseguro = s.sseguro);

      retrn          t_iax_retorno := t_iax_retorno();
      vcdomici       NUMBER;
      vsperson       NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_Leeretorno';
      vcagente       estseguros.cagente%TYPE;
      ndirec         NUMBER;
   BEGIN
      IF vpmode = 'EST' THEN
         FOR eretrn IN estretrn LOOP
            IF pac_retorno.f_tiene_retorno(NULL, eretrn.sseguro, eretrn.nmovimi, 'EST') = 1 THEN
               vpasexec := 3;
               retrn.EXTEND;
               retrn(retrn.LAST) := ob_iax_retorno();
               retrn(retrn.LAST).sperson := eretrn.sperson;
               retrn(retrn.LAST).pretorno := eretrn.pretorno;
               -- BUG 0023965 - 15/10/2012 - JMF
               retrn(retrn.LAST).idconvenio := eretrn.idconvenio;
               vpasexec := 31;

               SELECT cagente
                 INTO vcagente
                 FROM estseguros
                WHERE sseguro = eretrn.sseguro;

               vpasexec := 4;
               num_err := pac_md_persona.f_get_persona_agente(eretrn.sperson, vcagente, vpmode,
                                                              retrn(retrn.LAST), mensajes);
               vpasexec := 5;

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  RAISE e_object_error;
               END IF;

               vpasexec := 7;

               IF retrn(retrn.LAST).direcciones IS NULL THEN
                  retrn(retrn.LAST).direcciones := t_iax_direcciones();
               END IF;

               retrn(retrn.LAST).direcciones.EXTEND;
               ndirec := retrn(retrn.LAST).direcciones.LAST;
               retrn(retrn.LAST).direcciones(ndirec) := ob_iax_direcciones();
               num_err := pac_md_persona.f_get_direcciones(eretrn.sperson, vcagente,
                                                           retrn(retrn.LAST).direcciones,
                                                           mensajes, vpmode);
               vpasexec := 5;

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      ELSE
         FOR pretrn IN polretrn LOOP
            -- Nos aseguramos que haya retorno
            IF pac_retorno.f_tiene_retorno(NULL, pretrn.sseguro, pretrn.nmovimi, 'SEG') = 1 THEN
               retrn.EXTEND;
               retrn(retrn.LAST) := ob_iax_retorno();
               retrn(retrn.LAST).sperson := pretrn.sperson;
               retrn(retrn.LAST).pretorno := pretrn.pretorno;
               -- BUG 0023965 - 15/10/2012 - JMF
               retrn(retrn.LAST).idconvenio := pretrn.idconvenio;
               vpasexec := 81;

               SELECT cagente
                 INTO vcagente
                 FROM seguros
                WHERE sseguro = pretrn.sseguro;

               vpasexec := 10;
               num_err := pac_md_persona.f_get_persona_agente(pretrn.sperson, vcagente, vpmode,
                                                              retrn(retrn.LAST), mensajes);
               vpasexec := 11;

               IF retrn(retrn.LAST).direcciones IS NULL THEN
                  retrn(retrn.LAST).direcciones := t_iax_direcciones();
               END IF;

               retrn(retrn.LAST).direcciones.EXTEND;
               ndirec := retrn(retrn.LAST).direcciones.LAST;
               retrn(retrn.LAST).direcciones(ndirec) := ob_iax_direcciones();
               num_err := pac_md_persona.f_get_direcciones(pretrn.sperson, vcagente,
                                                           retrn(retrn.LAST).direcciones,
                                                           mensajes, vpmode);
               vpasexec := 5;

               IF num_err <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN retrn;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeretorno;

/*************************************************************************
Devuelve el caso bpm
param out mensajes : mesajes de error
return             : caso bpm
Bug 28263/153355 - 01/10/2013 - AMC
*************************************************************************/
   FUNCTION f_lee_caso_bpmseg(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_bpm IS
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_lee_caso_bpmseg';
      casobpm        ob_iax_bpm;
      pnnumcaso      NUMBER;
      vcempres       NUMBER;
   BEGIN
      vcempres := pac_md_common.f_get_cxtempresa;
      casobpm := ob_iax_bpm();

      IF vpmode = 'EST' THEN
         vpasexec := 3;

         BEGIN
            SELECT nnumcaso
              INTO pnnumcaso
              FROM estcasos_bpmseg
             WHERE sseguro = vsolicit
               AND cempres = vcempres;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pnnumcaso := NULL;
         END;
      ELSE
         BEGIN
            SELECT nnumcaso
              INTO pnnumcaso
              FROM casos_bpmseg
             WHERE sseguro = vsolicit
               AND cempres = vcempres
               AND nmovimi = vnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pnnumcaso := NULL;
         END;
      END IF;

      IF pnnumcaso IS NOT NULL THEN
         BEGIN
            SELECT nnumcaso, cusuasignado, ctipoproceso,
                   cestado, cestadoenvio, falta, fbaja,
                   cusualt, fmodifi, cusumod, sproduc,
                   cmotmov, ctipide, nnumide, tnomcom,
                   npoliza, ncertif, nmovimi, nnumcasop,
                   ncaso_bpm, nsolici_bpm, ctipmov_bpm,
                   caprobada_bpm
              INTO casobpm.nnumcaso, casobpm.cusuasignado, casobpm.ctipoproceso,
                   casobpm.cestado, casobpm.cestadoenvio, casobpm.falta, casobpm.fbaja,
                   casobpm.cusualt, casobpm.fmodifi, casobpm.cusumod, casobpm.sproduc,
                   casobpm.cmotmov, casobpm.ctipide, casobpm.nnumide, casobpm.tnomcom,
                   casobpm.npoliza, casobpm.ncertif, casobpm.nmovimi, casobpm.nnumcasop,
                   casobpm.ncaso_bpm, casobpm.nsolici_bpm, casobpm.ctipmov_bpm,
                   casobpm.caprobada_bpm
              FROM casos_bpm
             WHERE nnumcaso = pnnumcaso
               AND cempres = vcempres;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      RETURN casobpm;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_caso_bpmseg;

/*************************************************************************
Obtiene los asegurados mes del supemento de regularizaci?n
param out mensajes : mesajes de error
return             : caso bpm
Convenios
*************************************************************************/
   FUNCTION f_leeraseguradosmes(
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_aseguradosmes IS
      obj            ob_iax_aseguradosmes;
      vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_leeraseguradosmes';
      ventra         BOOLEAN := FALSE;
      vpasexec       NUMBER := 0;
      vfecha         DATE;
      vfsuplem       DATE;
      num_err        NUMBER;
   BEGIN
      obj := ob_iax_aseguradosmes();
      vpasexec := 1;

      IF vpmode IN('EST', 'SOL') THEN
         FOR reg IN (SELECT *
                       FROM estaseguradosmes
                      WHERE sseguro = vsolicit
                        AND nriesgo = pnriesgo) LOOP
            IF reg.nmes = 1 THEN
               obj.nmes1 := reg.naseg;
            ELSIF reg.nmes = 2 THEN
               obj.nmes2 := reg.naseg;
            ELSIF reg.nmes = 3 THEN
               obj.nmes3 := reg.naseg;
            ELSIF reg.nmes = 4 THEN
               obj.nmes4 := reg.naseg;
            ELSIF reg.nmes = 5 THEN
               obj.nmes5 := reg.naseg;
            ELSIF reg.nmes = 6 THEN
               obj.nmes6 := reg.naseg;
            ELSIF reg.nmes = 7 THEN
               obj.nmes7 := reg.naseg;
            ELSIF reg.nmes = 8 THEN
               obj.nmes8 := reg.naseg;
            ELSIF reg.nmes = 9 THEN
               obj.nmes9 := reg.naseg;
            ELSIF reg.nmes = 10 THEN
               obj.nmes10 := reg.naseg;
            ELSIF reg.nmes = 11 THEN
               obj.nmes11 := reg.naseg;
            ELSIF reg.nmes = 12 THEN
               obj.nmes12 := reg.naseg;
            ELSE
               RAISE e_object_error;
            END IF;

            vfecha := reg.fregul;
            vpasexec := 2;
            ventra := TRUE;
         END LOOP;
      ELSE
         FOR reg IN (SELECT *
                       FROM aseguradosmes a
                      WHERE a.sseguro = vsolicit
                        AND a.nriesgo = pnriesgo
                        AND a.nmovimi = NVL(pnmovimi,
                                            (SELECT MAX(s.nmovimi)
                                               FROM aseguradosmes s
                                              WHERE s.sseguro = a.sseguro
                                                AND s.nriesgo = a.nriesgo))) LOOP
            vpasexec := 4;

            IF reg.nmes = 1 THEN
               obj.nmes1 := reg.naseg;
            ELSIF reg.nmes = 2 THEN
               obj.nmes2 := reg.naseg;
            ELSIF reg.nmes = 3 THEN
               obj.nmes3 := reg.naseg;
            ELSIF reg.nmes = 4 THEN
               obj.nmes4 := reg.naseg;
            ELSIF reg.nmes = 5 THEN
               obj.nmes5 := reg.naseg;
            ELSIF reg.nmes = 6 THEN
               obj.nmes6 := reg.naseg;
            ELSIF reg.nmes = 7 THEN
               obj.nmes7 := reg.naseg;
            ELSIF reg.nmes = 8 THEN
               obj.nmes8 := reg.naseg;
            ELSIF reg.nmes = 9 THEN
               obj.nmes9 := reg.naseg;
            ELSIF reg.nmes = 10 THEN
               obj.nmes10 := reg.naseg;
            ELSIF reg.nmes = 11 THEN
               obj.nmes11 := reg.naseg;
            ELSIF reg.nmes = 12 THEN
               obj.nmes12 := reg.naseg;
            ELSE
               RAISE e_object_error;
            END IF;

            vfecha := reg.fregul;
            vpasexec := 5;
            ventra := TRUE;
         END LOOP;
      END IF;

      IF ventra THEN
         obj.fechaini := ADD_MONTHS(vfecha, -12);
         obj.fechafin := vfecha;
      ELSE
         IF vpmode IN('EST', 'SOL') THEN
            BEGIN
               SELECT DISTINCT (finiefe)
                          INTO vfsuplem
                          FROM estgaranseg
                         WHERE sseguro = vsolicit
                           AND ffinefe IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  vfsuplem := pac_iax_produccion.vfefecto;
            END;
         ELSE
            vfsuplem := pac_iax_produccion.vfefecto;
         END IF;

         obj.fechaini := ADD_MONTHS(vfsuplem, -12);
         obj.fechafin := vfsuplem;
      END IF;

      vpasexec := 6;
      RETURN obj;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeraseguradosmes;

/*************************************************************************
Lee  laversi?n convenio
param in psseguro         : Numero seguro
param in out mensajes     : mesajes de error
pa
return                    : objeto version
*************************************************************************/
   FUNCTION f_leer_convempvers(
      psseguro IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pmodo IN NUMBER DEFAULT 0)
      RETURN ob_iax_convempvers IS
      vconvempvers   ob_iax_convempvers := ob_iax_convempvers();
      vversionpadre  estcnv_conv_emp_seg.idversion%TYPE;
      vversionind    estcnv_conv_emp_seg.idversion%TYPE;
      vsseguropadre  seguros.sseguro%TYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_leer_convempvers';
      vsproduc       productos.sproduc%TYPE;
      v_version      NUMBER(1);
      nnum           NUMBER;
   BEGIN
      IF pac_md_convenios_emp.f_es_productoconvenios
                                                 (pac_iax_produccion.poliza.det_poliza.sproduc) <>
                                                                                             1 THEN
         RETURN NULL;
      END IF;

      vpasexec := 2;

      IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS',
                                               pac_iax_produccion.poliza.det_poliza.sproduc) =
                                                                                              1
         AND NOT pac_iax_produccion.isaltacol
         AND pmodo = 1 THEN
         nnum := pac_productos.f_get_herencia_col(vsproduc, 21, v_version);
         vpasexec := 3;

         IF NVL(v_version, 0) = 1
            AND nnum = 0 THEN
            SELECT sseguro
              INTO vsseguropadre
              FROM seguros
             WHERE npoliza = pac_iax_produccion.poliza.det_poliza.npoliza
               AND ncertif = 0;

            vpasexec := 4;
            vversionpadre := pac_convenios_emp.f_ultverscnv_poliza(vsseguropadre, 'SEG');

            IF vversionpadre IS NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907518);
               RAISE e_object_error;
            END IF;

            vpasexec := 5;

            IF vversionpadre IS NOT NULL THEN
               vconvempvers := pac_md_convenios_emp.f_get_versioncon(vsseguropadre,
                                                                     vversionpadre, 'SEG');
               vpasexec := 6;

               IF vconvempvers IS NULL THEN   -- BUG 34505 - FAL - 28/05/2015
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907518);
                  vpasexec := 7;
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      ELSE
         vpasexec := 75;
         --BUG 0023183: XVM :26/10/2012--FIN.
         vversionind := pac_convenios_emp.f_ultverscnv_poliza(psseguro, vpmode);
         vpasexec := 8;

         IF vversionind IS NULL
            AND NOT pac_iax_produccion.isaltacol THEN   -- BUG 34505 - FAL - 28/05/2015
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907518);
            RAISE e_object_error;
         END IF;

         vpasexec := 9;

         IF vversionind IS NOT NULL THEN
            vconvempvers := pac_md_convenios_emp.f_get_versioncon(psseguro, vversionind,
                                                                  vpmode);
            vpasexec := 10;

            IF vconvempvers IS NULL
               AND NOT pac_iax_produccion.isaltacol THEN   -- BUG 34505 - FAL - 28/05/2015
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907518);
               vpasexec := 11;
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      RETURN vconvempvers;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leer_convempvers;

-- JLTS
/************************************************************************
Recuperar la informacion de la agenda
param in pnriesgo  : secuencia del seguro
param out mensajes : mesajes de error
return             : objeto detalle poliza
*************************************************************************/
   FUNCTION f_leeragensegu(
      pmode IN VARCHAR2,
      psseguro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_agensegu IS
      CURSOR estcur IS
         SELECT r.*
           FROM estagensegu r
          WHERE r.sseguro = psseguro;

      CURSOR polcur IS
         SELECT r.*
           FROM agensegu r
          WHERE r.sseguro = psseguro;

      agenda         t_iax_agensegu := t_iax_agensegu();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_LEERAGENDA';
   BEGIN
      IF pmode = 'EST' THEN
         FOR estagenda IN estcur LOOP
            vpasexec := 3;
            agenda.EXTEND;
            agenda(agenda.LAST) := ob_iax_agensegu();
            agenda(agenda.LAST).sseguro := estagenda.sseguro;
            agenda(agenda.LAST).nlinea := estagenda.nlinea;
            agenda(agenda.LAST).npoliza := estagenda.sseguro;
            agenda(agenda.LAST).ncertif := 0;
            agenda(agenda.LAST).falta := estagenda.falta;
            agenda(agenda.LAST).ctipreg := estagenda.ctipreg;
            agenda(agenda.LAST).ttipreg := estagenda.ctipreg;
            agenda(agenda.LAST).cestado := estagenda.cestado;
            agenda(agenda.LAST).testado := estagenda.cestado;
            agenda(agenda.LAST).cusualt := estagenda.cusualt;
            agenda(agenda.LAST).ttitulo := estagenda.ttitulo;
            agenda(agenda.LAST).ffinali := estagenda.ffinali;
            agenda(agenda.LAST).ttextos := estagenda.ttextos;
            agenda(agenda.LAST).cmanual := estagenda.cmanual;
            agenda(agenda.LAST).tmanual := estagenda.cmanual;
            agenda(agenda.LAST).cusumod := estagenda.cusumod;
            agenda(agenda.LAST).fmodifi := estagenda.fmodifi;
         END LOOP;
      ELSE
         FOR polagenda IN polcur LOOP
            DBMS_OUTPUT.put_line('OJO SEGURO=' || polagenda.sseguro);
            vpasexec := 4;
            agenda.EXTEND;
            agenda(agenda.LAST) := ob_iax_agensegu();
            agenda(agenda.LAST).sseguro := polagenda.sseguro;
            agenda(agenda.LAST).nlinea := polagenda.nlinea;
            agenda(agenda.LAST).npoliza := polagenda.sseguro;
            agenda(agenda.LAST).ncertif := 0;
            agenda(agenda.LAST).falta := polagenda.falta;
            agenda(agenda.LAST).ctipreg := polagenda.ctipreg;
            agenda(agenda.LAST).ttipreg := polagenda.ctipreg;
            agenda(agenda.LAST).cestado := polagenda.cestado;
            agenda(agenda.LAST).testado := polagenda.cestado;
            agenda(agenda.LAST).cusualt := polagenda.cusualt;
            agenda(agenda.LAST).ttitulo := polagenda.ttitulo;
            agenda(agenda.LAST).ffinali := polagenda.ffinali;
            agenda(agenda.LAST).ttextos := polagenda.ttextos;
            agenda(agenda.LAST).cmanual := polagenda.cmanual;
            agenda(agenda.LAST).tmanual := polagenda.cmanual;
            agenda(agenda.LAST).cusumod := polagenda.cusumod;
            agenda(agenda.LAST).fmodifi := polagenda.fmodifi;
         END LOOP;
      END IF;

      RETURN agenda;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeragensegu;

-- JLTS
/*************************************************************************
funcion que retorna los cuadros de amortizacion de un prestamo.
param psseguro : codigo del seguro
param mensajes : mensajes registrados en el proceso
return : t_iax_prestcuadroseg tabla PL con objetos de cuadro de prestamo
Bug 35712 mnustes
*************************************************************************/
   FUNCTION f_lee_prestcuadroseg(
      psseguro IN seguros.sseguro%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prestcuadroseg IS
      --
      CURSOR estseg IS
         SELECT d.sseguro, d.icapital, d.nmovimi, d.ctapres, d.finicuaseg, d.ffincuaseg,
                d.fefecto, d.fvencim, d.iinteres, d.icappend, d.falta
           FROM estprestcuadroseg d
          WHERE d.sseguro = psseguro
            AND d.nmovimi = (SELECT MAX(l.nmovimi)
                               FROM estprestcuadroseg l
                              WHERE l.sseguro = d.sseguro);

      CURSOR polseg IS
         SELECT d.sseguro, d.icapital, d.nmovimi, d.ctapres, d.finicuaseg, d.ffincuaseg,
                d.fefecto, d.fvencim, d.iinteres, d.icappend, d.falta
           FROM prestcuadroseg d
          WHERE d.sseguro = psseguro
            AND d.nmovimi = (SELECT MAX(l.nmovimi)
                               FROM prestcuadroseg l
                              WHERE l.sseguro = d.sseguro);

      --
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_lee_prestcuadroseg';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parametros - psseguro: ' || psseguro;
      prestcuadroseg t_iax_prestcuadroseg := t_iax_prestcuadroseg();
   --
   BEGIN
      --
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      --
      IF vpmode = 'EST' THEN
         --
         FOR eseg IN estseg LOOP
            --
            prestcuadroseg.EXTEND;
            prestcuadroseg(prestcuadroseg.LAST) := ob_iax_prestcuadroseg();
            prestcuadroseg(prestcuadroseg.LAST).sseguro := eseg.sseguro;
            prestcuadroseg(prestcuadroseg.LAST).icapital := eseg.icapital;
            prestcuadroseg(prestcuadroseg.LAST).nmovimi := NVL(eseg.nmovimi, 1);
            prestcuadroseg(prestcuadroseg.LAST).ctapres := eseg.ctapres;
            prestcuadroseg(prestcuadroseg.LAST).finicuaseg := eseg.finicuaseg;
            prestcuadroseg(prestcuadroseg.LAST).ffincuaseg := eseg.ffincuaseg;
            prestcuadroseg(prestcuadroseg.LAST).fefecto := eseg.fefecto;
            prestcuadroseg(prestcuadroseg.LAST).fvencim := eseg.fvencim;
            prestcuadroseg(prestcuadroseg.LAST).iinteres := eseg.iinteres;
            prestcuadroseg(prestcuadroseg.LAST).icappend := eseg.icappend;
            prestcuadroseg(prestcuadroseg.LAST).falta := eseg.falta;
            prestcuadroseg(prestcuadroseg.LAST).icuota :=
                                                  NVL(eseg.icapital, 0)
                                                  + NVL(eseg.iinteres, 0);
         --
         END LOOP;
      --
      ELSE
         --
         FOR pseg IN polseg LOOP
            --
            prestcuadroseg.EXTEND;
            prestcuadroseg(prestcuadroseg.LAST) := ob_iax_prestcuadroseg();
            prestcuadroseg(prestcuadroseg.LAST).sseguro := pseg.sseguro;
            prestcuadroseg(prestcuadroseg.LAST).icapital := pseg.icapital;
            prestcuadroseg(prestcuadroseg.LAST).nmovimi := NVL(pseg.nmovimi, 1);
            prestcuadroseg(prestcuadroseg.LAST).ctapres := pseg.ctapres;
            prestcuadroseg(prestcuadroseg.LAST).finicuaseg := pseg.finicuaseg;
            prestcuadroseg(prestcuadroseg.LAST).ffincuaseg := pseg.ffincuaseg;
            prestcuadroseg(prestcuadroseg.LAST).fefecto := pseg.fefecto;
            prestcuadroseg(prestcuadroseg.LAST).fvencim := pseg.fvencim;
            prestcuadroseg(prestcuadroseg.LAST).iinteres := pseg.iinteres;
            prestcuadroseg(prestcuadroseg.LAST).icappend := pseg.icappend;
            prestcuadroseg(prestcuadroseg.LAST).falta := pseg.falta;
            prestcuadroseg(prestcuadroseg.LAST).icuota :=
                                                  NVL(pseg.icapital, 0)
                                                  + NVL(pseg.iinteres, 0);
         --
         END LOOP;
      --
      END IF;

      --
      RETURN prestcuadroseg;
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_prestcuadroseg;

/*************************************************************************
Recupera lista de escenarios de proyecciones de interes
param out mensajes : mesajes de error
return             : ref cursor
*************************************************************************/
   FUNCTION f_evoluprovmatseg_scen(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro = ' || psseguro || ' ptablas = ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_evoluprovmatseg_scen';
      terror         VARCHAR2(200) := 'Error al recuperar escenarios de proyecci?n';
      v_select       VARCHAR2(2000);
   BEGIN
      v_select :=
         'SELECT esc.nscenario AS catribu, esc.ninttec ||' || '''' || ' %' || ''''
         || ' AS tatribu ' || 'FROM (SELECT DISTINCT e.nscenario, d.ninttec FROM ' || ptablas
         || 'evoluprovmatseg e, ' || ptablas || 'seguros s, intertecprod p, intertecmovdet d'
         || ' WHERE e.sseguro = ' || psseguro
         || ' AND s.sseguro = e.sseguro AND p.sproduc = s.sproduc'
         || ' AND d.ncodint = p.ncodint AND d.ndesde = e.nscenario AND d.ctipo = 2'
         || ' AND d.finicio = (SELECT MAX(d1.finicio) FROM intertecmovdet d1 WHERE d1.ncodint = d.ncodint AND d1.ctipo = d.ctipo AND d1.finicio <= s.fefecto)'
         || ' UNION ' || ' SELECT DISTINCT d.ndesde AS nscenario, d.ninttec FROM ' || ptablas
         || 'seguros s, intertecprod p, intertecmovdet d WHERE s.sseguro = ' || psseguro
         || ' AND p.sproduc = s.sproduc AND d.ncodint = p.ncodint AND d.ctipo = 2'
         || ' AND d.finicio = (SELECT MAX(d1.finicio) FROM intertecmovdet d1 WHERE d1.ncodint = d.ncodint AND d1.ctipo = d.ctipo AND d1.finicio <= s.fefecto)'
         || ' AND NOT EXISTS (SELECT 1 FROM ' || ptablas
         || 'evoluprovmatseg e WHERE e.sseguro = s.sseguro)' || ') esc ORDER BY 1';

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_evoluprovmatseg_scen;

/*************************************************************************
Recupera el menor escenarios de proyecciones de interes
param out mensajes : mesajes de error
return             : number
*************************************************************************/
   FUNCTION f_evoluprovmatseg_minscen(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro = ' || psseguro || ' ptablas = ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_evoluprovmatseg_minscen';
      terror         VARCHAR2(200) := 'Error al recuperar menor escenario de proyecci?n';
      vminescena     NUMBER;
      v_select       VARCHAR2(2000);
   BEGIN
      v_select :=
         'SELECT DISTINCT DECODE(k.ndesde,0,1,k.ndesde) FROM intertecmovdet k, intertecprod pk, '
         || ptablas || 'seguros sk' || ' WHERE sk.sseguro = ' || psseguro
         || ' AND pk.sproduc = sk.sproduc AND k.ncodint = pk.ncodint AND k.ctipo = 2'
         || ' AND k.finicio = (SELECT MAX(k1.finicio) FROM intertecmovdet k1 WHERE k1.ncodint = k.ncodint AND k1.ctipo = k.ctipo AND k1.finicio <= sk.fefecto)'
         || ' AND k.ninttec = (SELECT DISTINCT MIN(esc.ninttec) FROM '
         || '(SELECT DISTINCT d.ninttec FROM ' || ptablas || 'evoluprovmatseg e,' || ptablas
         || 'seguros s, intertecprod p, intertecmovdet d WHERE e.sseguro = ' || psseguro
         || ' AND p.sproduc = s.sproduc AND d.ncodint = p.ncodint '
         || ' AND d.ndesde = e.nscenario AND d.ctipo = 2'
         || ' AND s.sseguro = e.sseguro AND d.finicio = (SELECT MAX(d1.finicio) FROM intertecmovdet d1 WHERE d1.ncodint = d.ncodint AND d1.ctipo = d.ctipo AND d1.finicio <= s.fefecto)'
         || ' UNION ' || ' SELECT DISTINCT d.ninttec FROM ' || ptablas
         || 'seguros s, intertecprod p, intertecmovdet d WHERE s.sseguro = ' || psseguro
         || ' AND p.sproduc = s.sproduc AND d.ncodint = p.ncodint AND d.ctipo = 2'
         || ' AND d.finicio = (SELECT MAX(d1.finicio) FROM intertecmovdet d1 WHERE d1.ncodint = d.ncodint AND d1.ctipo = d.ctipo AND d1.finicio <= s.fefecto)'
         || ' AND NOT EXISTS (SELECT 1 FROM ' || ptablas
         || 'evoluprovmatseg e WHERE e.sseguro = s.sseguro)' || ') esc)';

      OPEN cur FOR v_select;

      FETCH cur
       INTO vminescena;

      IF cur%FOUND THEN
         RETURN vminescena;
      ELSE
         RETURN NULL;
      END IF;

      CLOSE cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_evoluprovmatseg_minscen;

/*************************************************************************
Devuelve las exclusiones de una p¿liza
param in psseguro   : numero de seguro
param in pnriesgo   : numero de riesgo
param in ptablas    : tablas donde hay que ir a buscar la informaci¿n
param out mensajes  : mesajes de error
return              : Tabla de exclusiones
Bug 36596/208854 - YDA
*************************************************************************/
   FUNCTION f_get_exclusiones(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_exclusiones IS
      TYPE cur IS REF CURSOR;

      curexclu       cur;
      v_exclusiones  t_iax_exclusiones := t_iax_exclusiones();
      squery         VARCHAR2(2000);
      vtab           VARCHAR2(1000);
      vfields        VARCHAR2(1000);
      vcond          VARCHAR2(1000);
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(100)
              := 'psseguro=' || psseguro || 'pnriesgo=' || pnriesgo || ' ptablas= ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_get_exclusiones';
      v_codegar      exclusiones_undw.codegar%TYPE;
      v_label        exclusiones_undw.label%TYPE;
      v_codexclus    exclusiones_undw.codexclus%TYPE;
      v_texclus      desexclusiones_udw.texclus%TYPE;
      v_texclusdet   desexclusiones_udw.texclusdet%TYPE;
      vnmovimi       exclusiones_undw.nmovimi%TYPE := NVL(pac_iax_produccion.vnmovimi, 1);
      vsorden        exclusiones_undw.sorden%TYPE := NVL(pac_iax_produccion.vcaseid, 1);
   BEGIN
      vpasexec := 1;
      vfields := 'distinct e.label,e.codexclus,d.texclus,e.codegar,d.texclusdet';
      vtab := LOWER(ptablas) || 'exclusiones_undw e, desexclusiones_udw d';
      vcond := 'e.cempres = pac_md_common.f_get_cxtempresa' || ' AND d.cempres = e.cempres'
               || ' AND d.cidioma = pac_md_common.f_get_cxtidioma'
               || ' AND d.codexclus = e.codexclus' || ' AND e.sseguro = ' || psseguro
               || ' AND e.nriesgo = ' || pnriesgo || ' AND e.nmovimi = ' || vnmovimi
               || ' AND e.sorden  = ' || vsorden || ' ORDER BY e.codexclus';
      vpasexec := 2;
      squery := 'SELECT ' || vfields || ' FROM ' || vtab || ' WHERE ' || vcond;
      vpasexec := 3;

      OPEN curexclu FOR squery;

      vpasexec := 4;

      LOOP
         FETCH curexclu
          INTO v_label, v_codexclus, v_texclus, v_codegar, v_texclusdet;

         EXIT WHEN curexclu%NOTFOUND;
         v_exclusiones.EXTEND;
         v_exclusiones(v_exclusiones.LAST) := ob_iax_exclusiones();
         v_exclusiones(v_exclusiones.LAST).sseguro := psseguro;
         v_exclusiones(v_exclusiones.LAST).nriesgo := pnriesgo;
         v_exclusiones(v_exclusiones.LAST).nmovimi := vnmovimi;
         v_exclusiones(v_exclusiones.LAST).cempres := pac_md_common.f_get_cxtempresa;
         v_exclusiones(v_exclusiones.LAST).codexclus := v_codexclus;
         v_exclusiones(v_exclusiones.LAST).codegar := v_codegar;
         v_exclusiones(v_exclusiones.LAST).sorden := vsorden;
         v_exclusiones(v_exclusiones.LAST).label := v_label;
         v_exclusiones(v_exclusiones.LAST).texclus := v_texclus;
         v_exclusiones(v_exclusiones.LAST).texclusdet := v_texclusdet;
      END LOOP;

      CLOSE curexclu;

      RETURN v_exclusiones;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF curexclu%ISOPEN THEN
            CLOSE curexclu;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF curexclu%ISOPEN THEN
            CLOSE curexclu;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF curexclu%ISOPEN THEN
            CLOSE curexclu;
         END IF;

         RETURN NULL;
   END f_get_exclusiones;

-- Bug 36596 IGIL INI
/* Recupera informacion de las citas medicas -->> */
/*************************************************************************
Recuperar la informacion de los citamedica
*************************************************************************/
   FUNCTION f_leecitamedica(
      psseguro IN NUMBER,
      pssegpol IN NUMBER,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_citamedica IS
      citas          t_iax_citamedica := t_iax_citamedica();
      vtab           VARCHAR2(2000);
      vtab1          VARCHAR2(2000);
      vtab2          VARCHAR2(2000);
      vtab3          VARCHAR2(2000);
      squery         VARCHAR2(2000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.F_Leecitamedica';
      pnomaseg       VARCHAR2(2000);
      psperaseg      NUMBER;
      pspermed       NUMBER;
      pnommedi       VARCHAR2(2000);
      pceviden       NUMBER;
      pteviden       VARCHAR2(2000);
      pcodevid       VARCHAR2(1000);
      pfeviden       DATE;
      pcestado       NUMBER;
      ptestado       VARCHAR2(1000);
      pieviden       NUMBER;
      pnorden_r      NUMBER;
      pcpago         NUMBER;
      vorden         NUMBER := 0;
      vcempres       NUMBER;
      num_err        NUMBER;
      vcidioma       NUMBER;
      pnriesgo       NUMBER;
      pnmovimi       NUMBER;
      vsseguro       NUMBER;
      pctipevi       NUMBER;
      pcais          NUMBER;
   BEGIN
      IF pmodo = 'EST' THEN
         vtab := 'estcitamedica_undw';
         vtab1 := 'per_personas';
         vtab2 := 'per_detper';
         vtab3 := 'personas_publicas';
         vsseguro := pssegpol;
      ELSIF pmodo = 'POL' THEN
         vtab := 'citamedica_undw';
         vtab1 := 'per_personas';
         vtab2 := 'per_detper';
         vtab3 := 'personas_publicas';
         vsseguro := psseguro;
      END IF;

      vcempres := pac_md_common.f_get_cxtempresa();
      vcidioma := pac_md_common.f_get_cxtidioma();
      squery :=
         'SELECT  cita.nriesgo, cita.nmovimi, '
         || '(SELECT UNIQUE b.nnumide || '' - '' || a.tnombre ' || 'FROM ' || vtab2 || ' a, '
         || vtab1 || ' b ' || '
WHERE a.sperson = b.sperson '
         || ' AND a.sperson = NVL(pac_persona.f_sperson_spereal(cita.speraseg), cita.speraseg) '
         || ' and a.cagente = ff_agente_cpervisio((select cagente from seguros s where s.sseguro ='
         || psseguro || '))' || '), '
         || ' NVL(pac_persona.f_sperson_spereal(cita.speraseg) , cita.speraseg) speraseg, '
         || ' NVL(pac_persona.f_sperson_spereal(cita.spermed), cita.spermed) spermed, '
         || '(SELECT UNIQUE a.tnombre || a.tapelli1 || a.tapelli2 ' || ' FROM ' || vtab2
         || ' a, ' || vtab1 || ' b, ' || vtab3 || ' pp ' || 'WHERE a.sperson = b.sperson '
         || ' AND a.sperson = NVL(pac_persona.f_sperson_spereal(cita.spermed), cita.spermed) and rownum = 1 and a.sperson = pp.sperson)'
         || ', cita.ceviden, evi.teviden, evi.codevid, '
         || 'cita.feviden, cita.cestado, cita.ieviden, cita.cpago, cita.norden, '
         || '(SELECT ctipo FROM codevidencias_udw WHERE ceviden = cita.ceviden) ctipevi, cita.cais '
         || ' FROM ' || vtab || ' cita,  desevidencias_udw evi  ' || 'WHERE sseguro='
         || psseguro || ' and  nriesgo=' || NVL(pnriesgo, 1)
         || '  AND nmovimi=(SELECT MAX(nmovimi )  FROM ' || vtab || ' WHERE sseguro='
         || psseguro || ' and  nriesgo=' || NVL(pnriesgo, 1) || ') ' || '  AND evi.cempres = '
         || vcempres || '  AND evi.ceviden = cita.ceviden ' || '  AND evi.cidioma = '
         || vcidioma;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      num_err := pac_log.f_log_consultas(squery, vobject, 1);
      vpasexec := 2;

      LOOP
         FETCH cur
          INTO pnriesgo, pnmovimi, pnomaseg, psperaseg, pspermed, pnommedi, pceviden,
               pteviden, pcodevid, pfeviden, pcestado, pieviden, pcpago, pnorden_r, pctipevi,
               pcais;

         EXIT WHEN cur%NOTFOUND;
         citas.EXTEND;
         vorden := NVL(vorden, 0) + 1;
         citas(citas.LAST) := ob_iax_citamedica();
         citas(citas.LAST).norden := vorden;
         vpasexec := 5;
         citas(citas.LAST).sseguro := vsseguro;
         citas(citas.LAST).nriesgo := pnriesgo;
         vpasexec := 6;
         citas(citas.LAST).nmovimi := NVL(pnmovimi, 1);
         vpasexec := 7;
         citas(citas.LAST).nomaseg := pnomaseg;
         vpasexec := 8;
         citas(citas.LAST).sperson := psperaseg;
         vpasexec := 9;
         citas(citas.LAST).sperson_med := pspermed;
         vpasexec := 10;
         citas(citas.LAST).nommedi := pnommedi;
         vpasexec := 11;
         citas(citas.LAST).ceviden := pceviden;
         vpasexec := 12;
         citas(citas.LAST).teviden := pteviden;
         citas(citas.LAST).codevid := pcodevid;
         vpasexec := 13;
         -- 36596/211327 IGIL INI
         citas(citas.LAST).feviden := TO_CHAR(pfeviden, 'dd/MM/yyyy HH24:mi:ss');
         -- 36596/211327 IGIL FIN
         vpasexec := 14;
         citas(citas.LAST).cestado := pcestado;
         vpasexec := 15;
         num_err := f_desvalorfijo(8001025, vcidioma, pcestado, citas(citas.LAST).testado);
         vpasexec := 16;
         citas(citas.LAST).ieviden := pieviden;
         vpasexec := 17;
         citas(citas.LAST).cpago := pcpago;
         citas(citas.LAST).tpago := pac_md_listvalores.f_getdescripvalores(8001028, pcpago,
                                                                           mensajes);
         vpasexec := 18;
         citas(citas.LAST).norden_r := pnorden_r;
         citas(citas.LAST).ctipevi := pctipevi;
         citas(citas.LAST).cais := pcais;
      END LOOP;

      vpasexec := 19;

      CLOSE cur;

      RETURN citas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_leecitamedica;

-- Bug 36596 IGIL FIN
/*************************************************************************
Recuperar la informacion de las enfermedades
*************************************************************************/
   FUNCTION f_lee_enfermedades(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_enfermedades_undw IS
      CURSOR cenf IS
         SELECT   *
             FROM enfermedades_undw
            WHERE sseguro = psseguro
         ORDER BY codenf;

      v_enfermedades t_iax_enfermedades_undw := t_iax_enfermedades_undw();
      vparam         VARCHAR2(100) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_lee_enfermedades';
      vpasexec       NUMBER(8);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      FOR c IN cenf LOOP
         v_enfermedades.EXTEND;
         v_enfermedades(v_enfermedades.LAST) := ob_iax_enfermedades_undw();
         v_enfermedades(v_enfermedades.LAST).sseguro := c.sseguro;
         v_enfermedades(v_enfermedades.LAST).nriesgo := c.nriesgo;
         v_enfermedades(v_enfermedades.LAST).nmovimi := c.nmovimi;
         v_enfermedades(v_enfermedades.LAST).cempres := c.cempres;
         v_enfermedades(v_enfermedades.LAST).sorden := c.sorden;
         v_enfermedades(v_enfermedades.LAST).norden := c.norden;
         v_enfermedades(v_enfermedades.LAST).cindex := c.cindex;
         v_enfermedades(v_enfermedades.LAST).codenf := c.codenf;
         v_enfermedades(v_enfermedades.LAST).desenf := c.desenf;
      END LOOP;

      RETURN v_enfermedades;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_enfermedades;

/*************************************************************************
Recupera la informacion de las preguntas base
*************************************************************************/
   FUNCTION f_lee_preguntas(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_basequestion_undw IS
      CURSOR cques IS
         SELECT   *
             FROM basequestion_undw
            WHERE sseguro = psseguro
         ORDER BY POSITION;

      v_question     t_iax_basequestion_undw := t_iax_basequestion_undw();
      vparam         VARCHAR2(100) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_lee_preguntas';
      vpasexec       NUMBER(8);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      FOR c IN cques LOOP
         v_question.EXTEND;
         v_question(v_question.LAST) := ob_iax_basequestion_undw();
         v_question(v_question.LAST).sseguro := c.sseguro;
         v_question(v_question.LAST).nriesgo := c.nriesgo;
         v_question(v_question.LAST).nmovimi := c.nmovimi;
         v_question(v_question.LAST).cempres := c.cempres;
         v_question(v_question.LAST).sorden := c.sorden;
         v_question(v_question.LAST).norden := c.norden;
         v_question(v_question.LAST).code := c.code;
         v_question(v_question.LAST).POSITION := c.POSITION;
         v_question(v_question.LAST).CATEGORY := c.CATEGORY;
         v_question(v_question.LAST).question := c.question;
         v_question(v_question.LAST).answer := c.answer;
      END LOOP;

      RETURN v_question;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_preguntas;

/*************************************************************************
Recupera la informacion de las acciones de los asegurados
*************************************************************************/
   FUNCTION f_lee_acciones(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_actions_undw IS
      CURSOR cacc IS
         SELECT   s.sseguro, s.nriesgo, s.nmovimi, s.cempres, s.sorden, s.norden, s.action,
                  s.naseg,
                  p.tnombre1 || ' ' || p.tnombre2 || ' ' || p.tapelli1 || ' '
                  || p.tapelli2 nombre
             FROM actions_undw s, asegurados t, per_detper p
            WHERE s.sseguro = psseguro
              AND s.cempres = pac_md_common.f_get_cxtempresa()
              AND t.sseguro = s.sseguro
              AND t.norden = s.naseg
              AND p.sperson = t.sperson
         ORDER BY s.naseg, s.action;

      v_actions      t_iax_actions_undw := t_iax_actions_undw();
      vparam         VARCHAR2(100) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_OBTENERDATOS.f_lee_acciones';
      vpasexec       NUMBER(8);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      FOR c IN cacc LOOP
         v_actions.EXTEND;
         v_actions(v_actions.LAST) := ob_iax_actions_undw();
         v_actions(v_actions.LAST).sseguro := c.sseguro;
         v_actions(v_actions.LAST).nriesgo := c.nriesgo;
         v_actions(v_actions.LAST).nmovimi := c.nmovimi;
         v_actions(v_actions.LAST).cempres := c.cempres;
         v_actions(v_actions.LAST).sorden := c.sorden;
         v_actions(v_actions.LAST).norden := c.norden;
         v_actions(v_actions.LAST).action := c.action;
         v_actions(v_actions.LAST).naseg := c.naseg;
         v_actions(v_actions.LAST).nombre := c.nombre;
      END LOOP;

      RETURN v_actions;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_acciones;

/*************************************************************************
FUNCTION f_leecontgaran
param in psseguro    : psseguro
param in mensajes    : t_iax_mensajes
return               : t_iax_contragaran
*************************************************************************/
   FUNCTION f_leecontgaran(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      vpasexec       NUMBER := 1;
      vobject        VARCHAR2(200) := 'pac_md_obtenerdatos.f_leecontgaran';
      vparam         VARCHAR2(500);
      --
      vnum_err       NUMBER;
      --
      v_contgaran    t_iax_contragaran;
      v_t_contgaran  t_iax_contragaran;
   --
   BEGIN
      --
      vpasexec := 1;

      --
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      --
      v_t_contgaran := t_iax_contragaran();

      --
      IF vpmode = 'EST' THEN
         --
         vpasexec := 2;

         --
         FOR cur IN (SELECT sperson
                       FROM esttomadores
                      WHERE sseguro = psseguro) LOOP
            --
            vpasexec := 21;
            --
            v_contgaran := pac_contragarantias.f_get_contragaran_cab(psperson => cur.sperson,
                                                                     pnradica => NULL,
                                                                     psseguro => psseguro,
                                                                     mensajes => mensajes);

            --
            IF v_contgaran IS NOT NULL THEN
               --
               vpasexec := 22;

               --
               IF v_contgaran.COUNT > 0 THEN
                  --
                  vpasexec := 23;

                  --
                  FOR vctgaran IN v_contgaran.FIRST .. v_contgaran.LAST LOOP
                     --
                     vpasexec := 24;

                     --
                     IF v_contgaran.EXISTS(vctgaran) THEN
                        --
                        vpasexec := 25;
                        v_t_contgaran.EXTEND;
                        v_t_contgaran(v_t_contgaran.LAST) := v_contgaran(vctgaran);
                     --
                     END IF;
                  --
                  END LOOP;
               --
               END IF;
            --
            END IF;
         --
         END LOOP;
      --
      ELSE
         --
         vpasexec := 3;

         --
         FOR cur IN (SELECT sperson
                       FROM tomadores
                      WHERE sseguro = psseguro) LOOP
            --
            vpasexec := 31;
            --
            v_contgaran := pac_contragarantias.f_get_contragaran_cab(psperson => cur.sperson,
                                                                     pnradica => NULL,
                                                                     psseguro => psseguro,
                                                                     mensajes => mensajes);

            --
            IF v_contgaran IS NOT NULL THEN
               --
               vpasexec := 32;

               --
               IF v_contgaran.COUNT > 0 THEN
                  --
                  vpasexec := 33;

                  --
                  FOR vctgaran IN v_contgaran.FIRST .. v_contgaran.LAST LOOP
                     --
                     vpasexec := 34;

                     --
                     IF v_contgaran.EXISTS(vctgaran) THEN
                        --
                        vpasexec := 35;
                        v_t_contgaran.EXTEND;
                        v_t_contgaran(v_t_contgaran.LAST) := v_contgaran(vctgaran);
                     --
                     END IF;
                  --
                  END LOOP;
               --
               END IF;
            --
            END IF;
         --
         END LOOP;
      --
      END IF;

      --
      RETURN v_t_contgaran;
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leecontgaran;
END pac_md_obtenerdatos;

/

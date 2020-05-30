CREATE OR REPLACE PACKAGE BODY PAC_MD_GRABARDATOS AS
    /******************************************************************************
       NAME:       PAC_MD_GRABARDATOS
       PURPOSE: Grabar la informacion de la poliza en la base de datos

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        14/09/2007   ACC                1. Creacion del package.
       1.1        18/02/2008   JAS                2. Es treu el gravat a les taules 'POL', de manera que nomes es pot gravar a les taules 'EST'.
       1.2        26/02/2009   RSC                3. Adaptacion iAxis a productos colectivos con certificados
       1.3        11/03/2009   RSC                4. Analisis adaptacion productos indexados
       2.0        07/04/2009   DRA                5. BUG0009217: IAX - Suplement de clausules
       3.0        24/04/2009   SVJ                6. BUG0009164
       4.0        30/04/2009   DRA                7. 0009988: IAX - Preguntes opcionals amb valors NULLS
       5.0        03/06/2009   XVM                8. 0009369: IAX - Error grabar descripcion datos riesgo si texto contiene una comilla
       6.0        16/06/2009   ETM                9.0009916: IAX -ACTIVIDAD - Añadir la actividad a nivel de poliza
       7.0        10/07/2009   APD                10.0009513: CEM - Validacion de prima minima
       8.0        22/07/2009   XPL                11. Bug 10702 - Nueva pantalla para contratacion y suplementos que
                                                     permita seleccionar cuentas aseguradas.
       9.0        14/08/2009   XPL                12. 0010930: CRE - Simulacion de productos colectivos
       10.0       19/08/2009   JRH                13. 0010898: CRE - Mantener Capitales migrados en productos de salud al realizar suplemento
       11.0       08/09/2009   RSC                14. 0011075: APR - detalle de garantias
       12.0       17/07/2009   DRA                15. 0010519: CRE - Incidencia suplementos ramo salud (2)
       13.0       16/09/2009   AMC                16. 11165: Se sustituye  T_iax_saldodeutorseg por t_iax_prestamoseg
       14.0       26/10/2009   APD                17. 0011301: CRE080 - FOREIGNS DE PRESTAMOSEG
       18.0       02/11/2009   DRA                18. 0011618: AGA005 - Modificacion de red comercial y gestion de comisiones.
       19.0       21/01/2010   DRA                19. 0011737: APR - suplemento de cambio de revalorizacion
       20.0       29/01/2010   DRA                20. 0012421: CRE 80- Saldo deutors II
       21.0       20/01/2010   RSC                21. 0011735: APR - suplemento de modificacion de capital /prima
       22.0       09/03/2010   JRH                22. 0013549: CEM - REHABILITACIONS Estalvi - error en el tipus d'interes garantit
       23.0       27/04/2010   JRH                23. 0014285 CEM:Se añade interes y fppren
       24.0       12/05/2010   RSC                24. 0011735: APR - suplemento de modificacion de capital /prima
       25.0       09/06/2010   RSC                25. 0013832: APRS015 - suplemento de aportaciones unicas
       26.0       30/07/2010   XPL                26. 14429: AGA005 - Primes manuals pels productes de Llar, CTARMAN
       27.0       10/06/2010   PFA                27. 14585: CRT001 - Añadir campo poliza compañia
       28.0       23/11/2010   PFA                28. 16410:: Borramos los parametros existentes
       29.0       27/12/2010   APD                29. 17105: Ajustes producto GROUPLIFE (III)
       30.0       10/01/2011   APD                30. 17221: Se sustituye el valor del tramo 1363 por NVL(f_parproductos_v(v_sproduc, 'TRAMO_INTERES'), 0)
       31.0       02/02/2011   RSC                31. 0017341: APR703 - Suplemento de preguntas - FlexiLife
       32.0       23/06/2011   APD                32. 0018848: LCOL003 - Vigencia fecha de tarifa
       33.0       30/08/2011   JMF                33. 0019332: LCOL001 -numeracion de polizas y de solicitudes
       34.0       08/09/2011   APD                34. 0018848: LCOL003 - Vigencia fecha de tarifa
       35.0       20/09/2011   RSC                35. 0019513: Definir producto Transportes Colectivo para GIP
       36.0       27/09/2011   DRA                36. 0019069: LCOL_C001 - Co-corretaje
       37.0       26/11/2011   DRA                37. 0020234: AGM - Error en la pantalla AXISCTR005 (Multiriesgo innominado)
       38.0       03/01/2012   JMF                38. 0020761 LCOL_A001- Quotes targetes
       39.0       01/03/2012   APD                39. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
       40.0       08/03/2012   JMF                0021592: MdP - TEC - Gestor de Cobro
       41.0       12/04/2012   APD                0021708: MDP - TEC - Fecha tarifa en simulacion y control vigencia fecha tarifa
       42.0       17/04/2012   ETM                42.0021924: MDP - TEC - Nuevos campos en pantalla de Gestion (Tipo de retribucion, Domiciliar 1er recibo, Revalorizacion franquicia)
       43.0       10/05/2012   FAL                43. 0022094: GIP104 - Testes Transportes flotantes - Correccio dels punts detectats en els testes del 20120426
       44.0       11/05/2011   MDS                44. 0021907: MDP - TEC - Descuentos y recargos (tecnico y comercial) a nivel de poliza/riesgo/garantia
       45.0       18/06/2012   MDS                45. 0021924: MDP - TEC - Nuevos campos en pantalla de Gestion (Tipo de retribucion, Domiciliar 1er recibo, Revalorizacion franquicia)
       46.0       04/06/2012   ETM                46. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
       47.0       09/07/2012   DRA                47. 0022402: LCOL_C003: Adaptación del co-corretaje
       48.0       01/08/2012   FPG                48. 0023075: LCOL_T010-Figura del pagador
       49.0       14/08/2012   DCG                49. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
       50.0       03/09/2012   JMF                0022701: LCOL: Implementación de Retorno
       51.0       04/12/2012   JLTS               51. 0024714: LCOL_T001-QT 5382: No existen movimientos de anulaci?n ni la causa siniestro/motivo para polizas prorrogadas/saldadas
       52.0       20/12/2012   MDS                52. 0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
       53.0       19/02/2013   MMS                53. 0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza ?hasta edad? y edades permitidas por producto- Modificar f_grabardatospoliza
       54.0       26/02/2013   JDS                54. 0025964: LCOL - AUT - Experiencia
       55.0       04/03/2013   AEG                55. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
       55.0       03/2013      NMM                55. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
       56.0       21/02/2013   ECP                53. 0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
       57.0       26/07/2013   SHA                57. 27014: LCOL - Revisi?n QT's Documentaci?n Autos F3a - Se crea la funcion f_grabarprimasgaranseg
       58.0       22/08/2013   JSV                58. 0027953: LCOL - Autos Garantias por Modalidad
       59.0       17/10/2013   FAL                59. 0027735: RSAG998 - Pago por cuotas
       60.0       04/11/2013   RCL                60. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
       61.0       31/01/2014   JDS                61. 0029582: LCOL_T010-Revision incidencias qtracker (2014/01)
       62.0       04/01/2015   JDS                62. 0029582: LCOL_T010-Revision incidencias qtracker (2014/01)
       63.0       06/06/2014   ELP                63. 0027500: Nueva operativa mandatos RSA
       64.0       25/06/2014   FBL                64. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
       65.0       25/06/2014   FBL                65. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
       66.0       25/06/2014   RDD                65. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
       67.0       07/10/2014   JMF                65. 0032015  Control errores
       68.0       08/10/2014   RDD                68. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
       69.0       02/12/2014   RDD                69. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
       70.0       16/10/2014   MMS                70. 0032676: COLM004-Fecha fin de vigencia de mandato. Campo no obligatorio a informar en la pantallas que se informa la fecha de firma
       71.0       27/07/2015   AQ                 71. 0035375: AGM301-error al calcular la RC en el entorno de Real
       72.0       07/03/2016   JAEG               72. 41143/229973: Desarrollo Diseño técnico CONF_TEC-01_VIGENCIA_AMPARO
       73.0       23/01/2018   JLTS               73. CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
       74.0       22/08/2019   CES                74. Ajuste error en cambio de actividad para suplementos
       75.0       18/07/2019   SPV                75. Tarea IAXIS-4201 Deducibles
       76.0       13/09/2019   SPV                76. IAXIS-5247 Deducibles para Suplementos (Endosos)
       77.0       23/09/2019   CJMR               77. IAXIS-5423. Ajustes deducibles.
       78.0       28/11/2019   JLTS               78. IAXIS-5420: Se ajusta consulta para que tome el aseguado 1 (parproductos RIESGO_EN_ASEG_1)
       79.0       21/02/2020   CJMR               79. IAXIS-12896. Solución bug IAXIS-12896
       80.0       26/05/2020   ECP                80. IAXIS-13888. Gestión Agenda
       
       ******************************************************************************/
       e_param_error  EXCEPTION;
       e_object_error EXCEPTION;
       gidioma        NUMBER := pac_md_common.f_get_cxtidioma();
       vpmode         VARCHAR2(3);
       vsolicit       NUMBER;
       vnmovimi       NUMBER;

       /*************************************************************************
          Define con que tablas se trabajara
          param in pmode     : modo a trabajar
          param out mensajes : mesajes de error
       *************************************************************************/
       PROCEDURE define_mode(pmode IN VARCHAR2, mensajes IN OUT t_iax_mensajes) IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.Define_Mode';
       BEGIN
          SELECT DECODE(NVL(pmode, 'SOL'), 'EST', 'EST', 'SOL', 'SOL', 'POL', 'POL', 'SOL')
            INTO vpmode
            FROM DUAL;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
       END define_mode;

       /*************************************************************************
          Inicializa ejecucion package
          param in pmode     : modo a trabajar
          param in pssolicit : codigo de seguro
          param in pnmovimi  : numero de movimientos
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
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_Inicializa';
       BEGIN
          IF NVL(pssolicit, 0) = 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001119);
             RAISE e_object_error;
          END IF;

          vsolicit := pssolicit;
          vnmovimi := pnmovimi;
          define_mode(pmode, mensajes);
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_inicializa;

       /*************************************************************************
           Grabar los datos de la poliza
           param in poliza    : objeto detalle poliza
           param out mensajes : mesajes de error
           return             : 0 todo ha sido correcto
                                1 ha habido un error
        *************************************************************************/
       FUNCTION f_grabardatospoliza(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          -- Bug 32015 - JMF - 07/10/2014 Control errores
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarDatosPoliza';
          vparam         VARCHAR2(500);
          vpasexec       NUMBER(8) := 1;
          vnum           NUMBER(8);
          v_frevisio     DATE;
          -- Bug 8745 - 26/02/2009 - RSC - Adaptacion iAxis a productos colectivos con certificados
          vnpoliza       NUMBER;
       -- Fin Bug 8745
       BEGIN
          vpasexec := 100;

          -- Comprovacio pas de parametres correcte.
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vparam := 's=' || poliza.sseguro || ' m=' || poliza.nmovimi || ' p='
                       || poliza.sproduc;
             vpasexec := 110;

             SELECT COUNT(1)
               INTO vnum
               FROM estseguros
              WHERE sseguro = poliza.sseguro;

             IF vnum > 0 THEN   --existeix, updategem
                vpasexec := 120;

                UPDATE estseguros
                   SET
    --ni el poliza.nmovimi, ni el poliza.csubpto no te corresp a la taula seguros
                       cramo = poliza.cramo,
                       cmodali = poliza.cmodali,
                       ctipseg = poliza.ctipseg,
                       ccolect = poliza.ccolect,
                       -- cactivi = poliza.gestion.cactivi, 22/05/2019=>CES: Ajuste error en cambio de actividad para suplementos, No se ACTUALIZA la actividad para los suplementos o para las modificaciones.
                       /*bug 9916: ETM :16-06-09:--poliza.cactivi,*/
                       sproduc = poliza.sproduc,
                       cagente = poliza.cagente,
                       cobjase = poliza.cobjase,
                       crevali = poliza.crevali,
                       prevali = poliza.prevali,
                       irevali = poliza.irevali,
                       csituac = poliza.csituac,
                       cidioma = poliza.gestion.cidioma,
                       cforpag = poliza.gestion.cforpag,
                       ctipban = poliza.gestion.ctipban,
                       cbancar = poliza.gestion.cbancar,
                       fefecto = poliza.gestion.fefecto,
                       fvencim = poliza.gestion.fvencim,
                       femisio = poliza.gestion.femisio,
                       fanulac = poliza.gestion.fanulac,
                       cduraci = poliza.gestion.cduraci,
                       nduraci = poliza.gestion.duracion,
                       ctipcom = NVL(poliza.gestion.ctipcom, 0),
                       ctipcob = poliza.gestion.ctipcob,
                       ccobban = poliza.gestion.ccobban,
                       nrenova = poliza.nrenova,
                       cpolcia = poliza.cpolcia,
                                  -- BUG 14585 - PFA - Anadir campo poliza compania
                       --SBG 04/2008
                       polissa_ini = poliza.gestion.polissa_ini,
                       -- Mantis 7919.#6.
                       ndurcob = poliza.gestion.ndurcob,
                       crecfra = poliza.gestion.crecfra,
                       csubage = poliza.gestion.csubage,
                       -- BUG11618:DRA:02/11/2009
                       ccompani = poliza.ccompani,
                       cpromotor = poliza.cpromotor,
                       -- bug 19372/91763-12/09/2011-AMC
                       ctiprea = NVL(poliza.ctiprea, 0),
                       --Bug 18981/96013 - 03/11/2011 - JRB
                       creafac = NVL(poliza.creafac, 0),
                       --Bug 18981/96013 - 03/11/2011 - JRB
                       cmoneda = poliza.gestion.cmonpol,
                       ncuotar = poliza.gestion.ncuotar,
                                                  -- BUG 0020761 - 03/01/2012 - JMF
                       -- BUG 21924 - 16/04/2012 - ETM
                       ctipretr = poliza.gestion.ctipretr,
                       cindrevfran = poliza.gestion.cindrevfran,
                       precarg = poliza.gestion.precarg,
                       pdtotec = poliza.gestion.pdtotec,
                       preccom = poliza.gestion.preccom,
                       pdtocom = poliza.gestion.dtocom,
                       -- FIN BUG 21924 - 16/04/2012 - ETM
                       cdomper = poliza.gestion.cdomper,
                       -- BUG 21924 - MDS - 18/06/2012
                       frenova = poliza.gestion.frenova,
                       -- BUG 0023117 - FAL - 26/07/2012
                       -- Bug 23183/134308 - 14/01/2013
                       ctipcoa = poliza.ctipcoa,
                       ncuacoa = poliza.ncuacoa,   -- Fi Bug 23183/134308 - 14/01/2013
                       nedamar = poliza.gestion.nedamar,   -- Bug 25584/135342 - MMS - 19/02/2013
                       -- BUG 24685 2013-02-06 AEG
                       ctipoasignum = poliza.gestion.ctipoasignum,
                       npolizamanual = poliza.gestion.npolizamanual,
                       npreimpreso = poliza.gestion.npreimpreso,
                       -- fin BUG 24685 2013-02-06 AEG
                       nmescob = poliza.gestion.nmescob,   -- BUG 0027735 - FAL - 25/09/2013
                       fefeplazo  = poliza.gestion.fefeplazo,  -- BUG 41143/229973 - 17/03/2016 - JAEG
                       fvencplazo = poliza.gestion.fvencplazo  -- BUG 41143/229973 - 17/03/2016 - JAEG
                 WHERE sseguro = poliza.sseguro;

                -- Bug 10702
                IF NVL(f_parproductos_v(poliza.sproduc, 'ES_PRODUCTO_SALDODE'), 0) = 1
                                                                                      -- AND poliza.icapmaxpol IS NOT NULL  -- BUG12421:DRA:29/01/2010
                THEN
                   vpasexec := 130;

                   UPDATE estsaldodeutorseg
                      SET icapmax = poliza.icapmaxpol
                    WHERE sseguro = poliza.sseguro
                      AND nmovimi = poliza.nmovimi;
                END IF;

                IF NVL(f_parproductos_v(poliza.sproduc, 'ES_PRODUCTO_AHO'), 0) = 1 THEN
                   vpasexec := 140;

                   UPDATE estseguros_aho
                      SET ndurper = poliza.gestion.ndurper,
                          frevisio = poliza.gestion.frevisio
                                                            -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                   ,
                          cfprest = poliza.gestion.cfprest
                    -- Fi Bug 16106 - 01/10/2010 - JRH
                   WHERE  sseguro = poliza.sseguro;
                END IF;

                vpasexec := 150;

                --De momento nada para UNIT LINK
                --Si es una polissa d'un producte indexat, cal realitzar l'insercio a ESTSEGUROS_ULK
                --IF NVL(f_parproductos_v(poliza.sproduc,'ES_PRODUCTO_INDEXADO'),0) = 1 THEN
                --    INSERT INTO estseguros_ulk (sseguro, psalmin, isalcue, cseghos, cmodinv,cgasges,cgasred)
                --    VALUES (poliza.sseguro, NULL, NULL, NULL, NULL, NULL, NULL);
                --END IF;
                -- Bug 9031 - 11/03/2009 - RSC - Axis: Analisis adaptacion productos indexados  (Update)
                IF NVL(f_parproductos_v(poliza.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                   vpasexec := 160;

                   UPDATE estseguros_ulk
                      SET cmodinv = poliza.modeloinv.cmodinv
                    WHERE sseguro = poliza.sseguro;
                END IF;

                vpasexec := 170;

                --Si es una polissa de rendes, cal realitzar l'insercio a ESTSEGUROSREN i ESTSEGUROS_AHO;
                IF NVL(f_parproductos_v(poliza.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
                   vpasexec := 180;

                   UPDATE estseguros_aho
                      SET ndurper = poliza.gestion.ndurper,
                          frevisio = poliza.gestion.frevisio
                                                            -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                   ,
                          cfprest = poliza.gestion.cfprest
                    -- Fi Bug 16106 - 01/10/2010 - JRH
                   WHERE  sseguro = poliza.sseguro;

                   vpasexec := 190;

                   UPDATE estseguros_ren
                      SET cforpag = poliza.gestion.cforpagren,
                          pcapfall = poliza.gestion.pcapfall,
                          pdoscab = poliza.gestion.pdoscab,
                          -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratacion e interes
                          fppren = poliza.gestion.fppren,
                          f1paren = NVL(poliza.gestion.fppren, f_sysdate)
                    -- Fi Bug 14285 - 26/04/2010 - JRH
                   WHERE  sseguro = poliza.sseguro;
                END IF;
             ELSE
                vpasexec := 200;
                -- Ini IAXIS-138888 -- 26/05/2020
                -- Bug 8745 - 26/02/2009 - RSC - Adaptacion iAxis a productos colectivos con certificados
                -- INI IAXIS-12896 CJMR 21/02/2020
		--vnpoliza := poliza.sseguro;
                --vnpoliza := poliza.nsolici;
                -- FIN IAXIS-12896 CJMR 21/02/2020
                if poliza.sseguro is null then
                begin
                  select npoliza
                  into vnpoliza
                  from seguros where sseguro = poliza.sseguro;
                  
                exception when no_data_found then
                    vnpoliza := poliza.nsolici;
                end;
                else
                  vnpoliza := poliza.nsolici;
                end if;
                --  IAXIS-138888 -- 26/05/2020
                -- ini BUG 0019332 - 30/08/2011 - JMF
                DECLARE
                   v_numaddpoliza NUMBER;
                BEGIN
                   vpasexec := 210;
                   v_numaddpoliza := pac_parametros.f_parempresa_n(poliza.cempres, 'NUMADDPOLIZA');
                   -- INI IAXIS-12896 CJMR 21/02/2020
                   --vnpoliza := poliza.sseguro + NVL(v_numaddpoliza, 0);
                   vnpoliza := poliza.nsolici + NVL(v_numaddpoliza, 0);
                   -- FIN IAXIS-12896 CJMR 21/02/2020
                END;

                -- fin BUG 0019332 - 30/08/2011 - JMF
                vpasexec := 220;

                IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', poliza.sproduc) = 1 THEN
                   vnpoliza := poliza.npoliza;
                END IF;

                -- Fin Bug 8745

                -- Bug 8745 - 26/02/2009 - RSC - Adaptacion iAxis a productos colectivos con certificados
                vpasexec := 230;

                INSERT INTO estseguros
                            (sseguro, ssegpol, cmodali, ccolect,
                             cramo, ctipseg,
                             cactivi,
                             sproduc, cagente, cobjase, npoliza,
                             ncertif, ctipreb, cagrpro, ctarman,
                             crecman, csituac, nanuali, cempres,
                             casegur, creafac, ctiprea,
                             creccob, ctipcol, nrenova, ctipcoa,
                             nfracci, crevali, irevali, prevali,
                             creteni, nsuplem, nsolici,
                             cidioma, cforpag,
                             ctipban, cpolcia,
                                              -- BUG 14585 - PFA - Anadir campo poliza compania
                                              cbancar,
                             fefecto, fvencim,
                             femisio, fanulac,
                             cduraci, nduraci,
                             ctipcom, ctipcob,
                             ccobban, polissa_ini,
                             ndurcob,   -- Mantis 7919.#6.
                                     crecfra,
                             csubage, cmoneda,   -- BUG11618:DRA:02/11/2009
                             ncuotar,   -- BUG 0020761 - 03/01/2012 - JMF
                                     -- BUG 21924 - 16/04/2012 - ETM
                                     ctipretr,
                             cindrevfran, precarg,
                             pdtotec, preccom,
                             pdtocom,   -- FIN BUG 21924 - 16/04/2012 - ETM
                                     cdomper,   -- BUG 21924 - MDS - 18/06/2012
                             frenova,   -- BUG 0023117 - FAL - 26/07/2012
                                     ncuacoa, nedamar,   -- Bug 25584/135342 - MMS - 19/02/2013
                             -- BUG 24685 2013-02-06 AEG
                             ctipoasignum, npolizamanual,
                             npreimpreso,
                             -- fin BUG 24685 2013-02-06 AEG
                             nmescob,   -- BUG 0027735 - FAL - 25/09/2013
                             fefeplazo, -- BUG 41143/229973 - 17/03/2016 - JAEG
                             fvencplazo -- BUG 41143/229973 - 17/03/2016 - JAEG
                             )
                     VALUES (poliza.sseguro, poliza.ssegpol, poliza.cmodali, poliza.ccolect,
                             poliza.cramo, poliza.ctipseg,
                             poliza.gestion.cactivi /*bug 9916: ETM :16-06-09:--poliza.cactivi*/,
                             poliza.sproduc, poliza.cagente, poliza.cobjase, vnpoliza,
                             poliza.ncertif, poliza.ctipreb, poliza.cagrpro, poliza.ctarman,
                             poliza.crecman, poliza.csituac, poliza.nanuali, poliza.cempres,
                             poliza.casegur, NVL(poliza.creafac, 0), NVL(poliza.ctiprea, 0),
                             poliza.creccob, poliza.ctipcol, poliza.nrenova, poliza.ctipcoa,
                             poliza.nfracci, poliza.crevali, poliza.irevali, poliza.prevali,
                             poliza.creteni, poliza.nsuplem, poliza.nsolici,
                             poliza.gestion.cidioma, poliza.gestion.cforpag,
                             poliza.gestion.ctipban, poliza.cpolcia,
                                                                    -- BUG 14585 - PFA - Anadir campo poliza compania
                                                                    poliza.gestion.cbancar,
                             poliza.gestion.fefecto, poliza.gestion.fvencim,
                             poliza.gestion.femisio, poliza.gestion.fanulac,
                             poliza.gestion.cduraci, poliza.gestion.duracion,
                             NVL(poliza.gestion.ctipcom, 0), poliza.gestion.ctipcob,
                             poliza.gestion.ccobban,
                                                    -- SBG 04/2008
                                                    poliza.gestion.polissa_ini,
                             poliza.gestion.ndurcob,
                                                    -- Mantis 7919.#6.
                                                    poliza.gestion.crecfra,
                             poliza.gestion.csubage, poliza.gestion.cmonpol,   -- BUG11618:DRA:02/11/2009
                             poliza.gestion.ncuotar,
                                                                        -- BUG 0020761 - 03/01/2012 - JMF
                                                    -- BUG 21924 - 16/04/2012 - ETM
                                                    poliza.gestion.ctipretr,
                             poliza.gestion.cindrevfran, poliza.gestion.precarg,
                             poliza.gestion.pdtotec, poliza.gestion.preccom,
                             poliza.gestion.dtocom,
                                                   -- FIN BUG 21924 - 16/04/2012 - ETM
                                                   poliza.gestion.cdomper,
                             -- BUG 21924 - MDS - 18/06/2012
                             poliza.gestion.frenova, poliza.ncuacoa,   --JRH
                                                                    -- BUG 0023117 - FAL - 26/07/2012
                                                                    poliza.gestion.nedamar,   -- Bug 25584/135342 - MMS - 19/02/2013
                             -- BUG 24685 2013-02-06 AEG
                             poliza.gestion.ctipoasignum, poliza.gestion.npolizamanual,
                             poliza.gestion.npreimpreso,
                             -- fin BUG 24685 2013-02-06 AEG
                             poliza.gestion.nmescob,   -- BUG 0027735 - FAL - 25/09/2013
                             poliza.gestion.fefeplazo, -- BUG 41143/229973 - 17/03/2016 - JAEG
                             poliza.gestion.fvencplazo -- BUG 41143/229973 - 17/03/2016 - JAEG
                                                   );

                 -- Fin Bug 8745
                -- Bug 10702
                IF NVL(f_parproductos_v(poliza.sproduc, 'ES_PRODUCTO_SALDODE'), 0) = 1 THEN
                   BEGIN
                      vpasexec := 240;

                      INSERT INTO estsaldodeutorseg
                                  (sseguro, nmovimi, icapmax)
                           VALUES (poliza.sseguro, poliza.nmovimi, poliza.icapmaxpol);   -- BUG12421:DRA:29/01/2010
                   EXCEPTION
                      WHEN OTHERS THEN
                         NULL;
                   END;
                END IF;

                --A continuacio realitzarem la resta d'accions que s'han de realitzar la primera
                --vegada que es baixa la polissa a les taules 'EST'.

                --Si es un producte d'estalvi, cal realitzar l'insercio a ESTSEGUROS_AHO
                IF NVL(f_parproductos_v(poliza.sproduc, 'ES_PRODUCTO_AHO'), 0) = 1 THEN
                   vpasexec := 250;

                   INSERT INTO estseguros_aho
                               (sseguro, pinttec, pintpac, fsusapo, ndurper,
                                frevisio, cfprest)
                        VALUES (poliza.sseguro, NULL, NULL, NULL, poliza.gestion.ndurper,
                                poliza.gestion.frevisio, poliza.gestion.cfprest
                                                                               -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                               );   --JRH 03/2008 Duracion periodo
                END IF;

                -- Bug 9031 - 11/03/2009 - RSC - Axis: Analisis adaptacion productos indexados
                IF NVL(f_parproductos_v(poliza.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                   vpasexec := 260;

                   INSERT INTO estseguros_ulk
                               (sseguro, psalmin, isalcue, cseghos, cmodinv, cgasges,
                                cgasred)
                        VALUES (poliza.sseguro, NULL, NULL, NULL, poliza.modeloinv.cmodinv, NULL,
                                NULL);
                END IF;

                -- Fin Bug 9031

                --Si es una polissa de rendes, cal realitzar l'insercio a ESTSEGUROSREN i ESTSEGUROS_AHO;
                IF NVL(f_parproductos_v(poliza.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
                   vpasexec := 270;

                   INSERT INTO estseguros_aho
                               (sseguro, pinttec, pintpac, fsusapo, ndurper,
                                frevisio, cfprest)
                        VALUES (poliza.sseguro, NULL, NULL, NULL, poliza.gestion.ndurper,
                                poliza.gestion.frevisio, poliza.gestion.cfprest
                                                                               -- Bug 16106 - 01/10/2010 - JRH - Poner cfprest
                               );

                   vpasexec := 280;

                   INSERT INTO estseguros_ren
                               (sseguro, f1paren,
                                fuparen, cforpag, ibruren,
                                pcapfall, pdoscab,
                                fppren)
                        VALUES (poliza.sseguro, NVL(poliza.gestion.fppren, TRUNC(f_sysdate)),
                                TRUNC(f_sysdate), poliza.gestion.cforpagren, 0,
                                poliza.gestion.pcapfall, poliza.gestion.pdoscab,
                                poliza.gestion.fppren);   --JRH 03/2008 Datos rentas
                END IF;

                vpasexec := 290;

                --Insertem a ESTDETMOVSEGURO que es una 'Alta' de polisses.
                INSERT INTO estdetmovseguro
                            (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                             tvalord, cpregun)
                     VALUES (poliza.sseguro, 1, 100, 0, 0, NULL,
                             f_axis_literales(151347, poliza.gestion.cidioma), 0);
             END IF;
          END IF;

          -- Ini bug 19276, jbn, 19276
          vpasexec := 300;
          vnum := f_grabarreemplazos(poliza.reemplazos, mensajes);

          IF vnum <> 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum);
             RAISE e_object_error;
          END IF;

           -- fi bug 19276, jbn, 19276
          -- RSA MANDATOS
          IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'INS_MANDATO'), 0) =
                                                                                                  1 THEN
             vpasexec := 310;
             vnum := f_grabar_mandatos_seguros(poliza, mensajes);

             IF vnum <> 0 THEN
                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum);
                RAISE e_object_error;
             END IF;
          END IF;

          vpasexec := 320;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabardatospoliza;

       /*************************************************************************
          Grabar los datos del tomador
          param in tomador   : objeto tomador
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabartomadores(tomador IN t_iax_tomadores, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          numpd          NUMBER;
          nump           NUMBER;
          numtom         NUMBER;
          numdir         NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarTomadores';
       BEGIN
          IF tomador IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001120);
             RETURN 1;
          END IF;

          -- Comprovacio pas de parametres correcte.
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --// ACC afegit q quan gravi primer borri
             vpasexec := 13;

             DELETE FROM esttomadores
                   WHERE sseguro = vsolicit;

             vpasexec := 14;

             FOR i IN tomador.FIRST .. tomador.LAST LOOP
                vpasexec := 15;

                IF tomador.EXISTS(i) THEN
                   vpasexec := 16;

                   IF tomador(i).direcciones IS NOT NULL THEN
                      vpasexec := 17;

                      IF tomador(i).direcciones.COUNT > 0 THEN
                         vpasexec := 18;

                         FOR j IN tomador(i).direcciones.FIRST .. tomador(i).direcciones.LAST LOOP
                            vpasexec := 19;

                            IF tomador(i).direcciones.EXISTS(j) THEN
                               vpasexec := 20;
                               numdir := tomador(i).direcciones(j).cdomici;
                               EXIT;
                            END IF;
                         END LOOP;
                      END IF;
                   END IF;

                   vpasexec := 21;

                   --nordtom, l'atribut especific del prenedor
                   SELECT COUNT(*)
                     INTO numtom
                     FROM esttomadores t
                    WHERE t.sperson = tomador(i).sperson
                      AND t.sseguro = vsolicit;

                   IF numtom = 0 THEN
                      vpasexec := 22;

                      -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - incluir campo cexistepagador
                      INSERT INTO esttomadores
                                  (sperson, sseguro, nordtom, cdomici,
                                   cexistepagador,cagrupa)
                           VALUES (tomador(i).sperson, vsolicit, tomador(i).nordtom, numdir,
                                   tomador(i).cexistepagador, tomador(i).cagrupa);   -- 20847/103084 - 09/01/2012 - AMC --alejandra
                   ELSE
                      vpasexec := 23;

                      -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - incluir campo cexistepagador
                      UPDATE esttomadores t
                         SET t.sperson = tomador(i).sperson,
                             t.cdomici = numdir,
                             t.cexistepagador = tomador(i).cexistepagador, --IAXIS-2085 03/04/2019 AP
                             t.cagrupa = tomador(i).cagrupa
                       WHERE t.nordtom = tomador(i).nordtom
                         AND t.sseguro = vsolicit;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabartomadores;

       /*************************************************************************
          Grabar las preguntas de la poliza
          param in tomador   : objeto preguntas
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarpreguntes(preg IN t_iax_preguntas, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          num            NUMBER;
          nerr           NUMBER;
          vpasexec       NUMBER(8) := 1;
          -- Bug 32015 - JMF - 07/10/2014 Control errores
          vparam         VARCHAR2(500) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarPreguntes';
          pregtab        t_iax_preguntastab;
          pregtab_col    t_iax_preguntastab_columns;
       BEGIN
          vpasexec := 100;

          IF preg IS NULL THEN
             RETURN 0;
          END IF;

          IF preg.COUNT = 0 THEN
             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --// ACC afegit q quan gravi primer borri
             vparam := 's=' || vsolicit || ' m=' || vnmovimi;
             vpasexec := 110;

             DELETE FROM estpregunpolseg
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi;

             vpasexec := 120;

             DELETE FROM estpregunpolsegtab
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi;

             vpasexec := 130;

             FOR i IN preg.FIRST .. preg.LAST LOOP
                vpasexec := 140;

                IF preg.EXISTS(i) THEN
                   vpasexec := 150;

                   IF NVL(preg(i).crespue, -1) <> -1
                      OR NVL(preg(i).trespue, ' ') <> ' ' THEN
                      vpasexec := 160;

                      -- BUG9988:DRA:30/04/2009:Inici
                      SELECT COUNT(*)
                        INTO num
                        FROM estpregunpolseg
                       WHERE sseguro = vsolicit
                         AND nmovimi = vnmovimi
                         AND cpregun = preg(i).cpregun;

                      vparam := 's=' || vsolicit || ' m=' || vnmovimi || ' preg='
                                || preg(i).cpregun;

                      IF num > 0 THEN   -- NO existeix, insertem
                         vpasexec := 170;

                         UPDATE estpregunpolseg
                            SET crespue = NVL(preg(i).crespue, 0),
                                trespue = preg(i).trespue
                          WHERE sseguro = vsolicit
                            AND cpregun = preg(i).cpregun
                            AND nmovimi = vnmovimi;
                      ELSE
                         vpasexec := 180;

                         INSERT INTO estpregunpolseg
                                     (sseguro, cpregun, nmovimi,
                                      crespue, trespue)
                              VALUES (vsolicit, preg(i).cpregun, vnmovimi,
                                      NVL(preg(i).crespue, 0), preg(i).trespue);
                      END IF;
                   END IF;
                -- BUG9988:DRA:30/04/2009:Fi
                END IF;

                vpasexec := 190;
                pregtab := preg(i).tpreguntastab;

                IF pregtab IS NOT NULL THEN
                   --Antes de hacer el traspaso a las subtablas, borramos los registros anteriores para reflejar
                   --las modificaciones y eliminaciones
                   vpasexec := 200;

                   DELETE FROM estsubtabs_seg_det
                         WHERE sseguro = vsolicit
                           AND nmovimi = vnmovimi
                           AND cpregun = preg(i).cpregun;

                   IF pregtab.COUNT <> 0 THEN
                      vpasexec := 210;

                      FOR j IN pregtab.FIRST .. pregtab.LAST LOOP
                         pregtab_col := pregtab(j).tcolumnas;

                         IF pregtab_col IS NOT NULL THEN
                            IF pregtab_col.COUNT <> 0 THEN
                               vpasexec := 220;

                               FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                                  IF pregtab_col.EXISTS(k) THEN
                                     vpasexec := 230;

                                     BEGIN
                                        SELECT COUNT(*)
                                          INTO num
                                          FROM estpregunpolsegtab
                                         WHERE sseguro = vsolicit
                                           AND nmovimi = vnmovimi
                                           AND cpregun = preg(i).cpregun
                                           AND nlinea = pregtab(j).nlinea
                                           AND ccolumna = pregtab_col(k).ccolumna;
                                     EXCEPTION
                                        WHEN OTHERS THEN
                                           num := 0;
                                     END;

                                     IF num > 0 THEN
                                        vpasexec := 240;

                                        UPDATE estpregunpolsegtab
                                           SET nvalor = NVL(pregtab_col(k).nvalor, 0),
                                               tvalor = pregtab_col(k).tvalor,
                                               fvalor = pregtab_col(k).fvalor
                                         WHERE sseguro = vsolicit
                                           AND nmovimi = vnmovimi
                                           AND cpregun = preg(i).cpregun
                                           AND nlinea = pregtab(j).nlinea
                                           AND ccolumna = pregtab_col(k).ccolumna;
                                     ELSE
                                        vpasexec := 250;

                                        INSERT INTO estpregunpolsegtab
                                                    (sseguro, cpregun,
                                                     nlinea, nmovimi,
                                                     ccolumna,
                                                     nvalor,
                                                     tvalor, fvalor)
                                             VALUES (vsolicit, preg(i).cpregun,
                                                     pregtab(j).nlinea, vnmovimi,
                                                     pregtab_col(k).ccolumna,
                                                     NVL(pregtab_col(k).nvalor, 0),
                                                     pregtab_col(k).tvalor, pregtab_col(k).fvalor);
                                     END IF;
                                  END IF;
                               END LOOP;
                            END IF;
                         END IF;

                         vpasexec := 260;
                         nerr := pac_preguntas.f_traspaso_subtabs_seg('EST', vsolicit, vnmovimi,
                                                                      preg(i).cpregun, 'P',
                                                                      pregtab(j).nlinea, 1, 0,
                                                                      nerr);
                      END LOOP;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          vpasexec := 270;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarpreguntes;

       /*************************************************************************
          Grabar los riesgos de la poliza
          param in riesgo    : objeto riesgos
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarriesgos(riesgo IN t_iax_riesgos, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          nerr           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarRiesgos';
       BEGIN
          IF riesgo IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001121);
             RAISE e_object_error;
          ELSE
             vpasexec := 2;

             IF riesgo.COUNT = 0 THEN
                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001121);
                RAISE e_object_error;
             END IF;
          END IF;

          vpasexec := 3;
          --// ACC s'han de borrar tots els asegurats a nivell de polissa no de risc
          -- BUG20234:DRA:22/11/2011:Inici: S'esborren tots els riscos i els seus detalls de BDD
          nerr := pk_nueva_produccion.f_borrar_riesgo(vsolicit, NULL, 'EST', 'ALTA');

          IF nerr <> 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerr);
             RAISE e_object_error;
          END IF;

          -- BUG20234:DRA:22/11/2011:Fi
          FOR vr IN riesgo.FIRST .. riesgo.LAST LOOP
             vpasexec := 4;

             IF riesgo.EXISTS(vr) THEN
                vpasexec := 5;
                nerr := f_grabarriesgo(riesgo(vr), riesgo(vr).nriesgo, mensajes);

                IF nerr = 1 THEN
                   RAISE e_object_error;
                END IF;
             END IF;
          END LOOP;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarriesgos;

       /*************************************************************************
          Grabar un riesgo de la poliza
          param in riesgo    : objeto riesgos
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarriesgo(
          riesgo IN ob_iax_riesgos,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          cobjase        NUMBER;
          nerr           NUMBER := 0;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(100) := 'pnriesgo=' || pnriesgo;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarRiesgo';
       BEGIN
          IF riesgo IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001121);
             RAISE e_object_error;
          END IF;

          vpasexec := 2;
          cobjase := pac_md_obtenerdatos.f_getobjase(vsolicit, vpmode, mensajes);

          -- Bug 19513 - RSC - 20/09/2011 - Definir producto Transportes Colectivo para GIP
          IF NOT pac_iax_produccion.isaltacol THEN
             -- Fin Bug 19513
             IF cobjase = 1 THEN   -- PERSONAL
                vpasexec := 3;
                nerr := f_grabarriesgopersonal(riesgo.riespersonal, riesgo, mensajes);
             ELSIF cobjase = 2 THEN   -- DIRECCION
                vpasexec := 3;
                nerr := f_grabarriesgodireccion(riesgo.riesdireccion, riesgo, mensajes);
             ELSIF cobjase IN(3, 4) THEN   -- DESCRIPCIO
                vpasexec := 3;
                nerr := f_grabarriesgodescripcion(riesgo.riesdescripcion, riesgo, mensajes);
             ELSIF cobjase = 5 THEN   -- AUTOS
                -- Bug 9247 - APD - 01/04/2009 - Se añade el codigo para grabar autriesgos
                vpasexec := 4;
                nerr := f_grabarriesgoauto(riesgo.riesautos, riesgo, mensajes);
             -- Bug 9247 - APD - 01/04/2009 - Fin
             END IF;
          -- Bug 19513 - RSC - 20/09/2011 - Definir producto Transportes Colectivo para GIP
          ELSE
             -- Bug 0022094 - FAL - 10/05/2012
             IF cobjase IN(3, 4) THEN   -- DESCRIPCIO
                vpasexec := 3;
                nerr := f_grabarriesgodescripcion(riesgo.riesdescripcion, riesgo, mensajes);
             ELSE
                -- Fi bug 22094
                vpasexec := 3;
                nerr := f_grabarriesgopersonal(riesgo.riespersonal, riesgo, mensajes);
             END IF;
          END IF;

          -- Fin Bug 19513
          IF nerr = 0
             AND riesgo.riesgoase IS NOT NULL
             AND(cobjase NOT IN(2, 3, 4, 5)
                 OR riesgo.riesgoase.COUNT > 0) THEN
             vpasexec := 5;
             nerr := f_grabarasegurados(riesgo.riesgoase, riesgo.nriesgo, mensajes);
          END IF;

          IF nerr = 0
             AND riesgo.preguntas IS NOT NULL THEN
             vpasexec := 6;
             nerr := f_grabarpreguntasriesgo(riesgo.preguntas, riesgo.nriesgo, mensajes);
          END IF;

          IF nerr = 0 THEN
             vpasexec := 7;
             nerr := f_grabargarantias(riesgo.garantias, riesgo.nriesgo, mensajes);
          END IF;

          IF nerr = 0 THEN
             vpasexec := 78;
             nerr := f_grabarfranquicias(riesgo.bonfranseg, riesgo.nriesgo, mensajes);
          END IF;

          IF nerr = 0 THEN
             vpasexec := 8;
             nerr := f_grabarbeneficiarios(riesgo.beneficiario, riesgo.nriesgo, mensajes);
          END IF;

          IF nerr = 0 THEN
             --JRH 03/2008 Guardamos las rentas irregulares
             vpasexec := 9;
             nerr := f_grabar_rentasirreg(riesgo.nriesgo, riesgo.rentirreg, mensajes);
          END IF;

          IF nerr = 0 THEN
             --JRH 03/2008 Guardamos las rentas irregulares
             vpasexec := 9;
             nerr := f_grabar_aseguradosmes(riesgo.nriesgo, riesgo.aseguradosmes, mensajes);
          END IF;

          IF nerr = 0 THEN
             --XPL 22/2009 Guardamos los saldos deutores
             vpasexec := 10;
             -- Bug 11165 - 21/09/2009 - AMC
             nerr := f_grabarriesprestamos(riesgo.prestamo, riesgo.nriesgo, mensajes);
          END IF;

          -- bfp bug 21947 ini
          IF nerr = 0 THEN
             vpasexec := 11;
             nerr := pac_md_grabardatos.f_grabargaransegcom(riesgo.att_garansegcom,
                                                            riesgo.nriesgo, mensajes);
          END IF;

          -- bfp bug 21947 fi
          RETURN nerr;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarriesgo;

       /*************************************************************************
          Grabar las clausulas de la poliza
          param in clausula  : objeto clausula
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarclausulas(clausula IN t_iax_clausulas, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarClausulas';
       BEGIN
          IF clausula IS NULL THEN
             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --Esborrat de clausules existents.
             vpasexec := 4;

             DELETE FROM estclaususeg
                   WHERE sseguro = vsolicit;

             vpasexec := 5;

             DELETE FROM estclausuesp
                   WHERE sseguro = vsolicit
                     AND cclaesp <> 1;

             -- BUG16410:JBN 17/11/2010: Borramos los parametros existentes
             DELETE FROM estclauparaseg
                   WHERE sseguro = vsolicit;
          END IF;

          -- BUG9217:DRA:07/04/2009: Se traslada aqui la comprobacion
          IF clausula.COUNT = 0 THEN
             RETURN 0;
          END IF;

          FOR i IN clausula.FIRST .. clausula.LAST LOOP
             vpasexec := 6;

             IF clausula.EXISTS(i) THEN
                vpasexec := 7;

                IF vpmode = 'EST' THEN
                   vpasexec := 11;

                   IF clausula(i).ctipo IN(4, 8)
                      AND clausula(i).tclaesp IS NULL THEN
                      vpasexec := 12;

                      INSERT INTO estclaususeg
                                  (nmovimi, sseguro, sclagen, finiclau,
                                   ffinclau, nordcla)
                           VALUES (vnmovimi, vsolicit, clausula(i).sclagen, clausula(i).finiclau,
                                   clausula(i).ffinclau, NVL(clausula(i).cidentity, 1));
                   ELSE
                      vpasexec := 13;

                      -- BUG9107:DRA:19-02-2009:Se pone al nordcla el cidentity
                      INSERT INTO estclausuesp
                                  (nmovimi, sseguro,
                                   cclaesp,
                                   nordcla, nriesgo, finiclau,
                                   sclagen, tclaesp, ffinclau)
                           VALUES (vnmovimi, vsolicit,
                                   DECODE(clausula(i).ctipo, 4, 2, 2, 4, 1, 2, clausula(i).ctipo),
                                   clausula(i).cidentity, 0, clausula(i).finiclau,
                                   clausula(i).sclagen, clausula(i).tclaesp, clausula(i).ffinclau);
                   END IF;

                   -- BUG16410:JBN 17/11/2010: Si tiene parametros
                   IF clausula(i).cparams > 0 THEN
                      FOR z IN clausula(i).parametros.FIRST .. clausula(i).parametros.LAST LOOP
                         IF clausula(i).parametros.EXISTS(z) THEN
                            INSERT INTO estclauparaseg
                                        (sclagen, sseguro, nriesgo,
                                         nmovimi, nparame,
                                         tparame,
                                         nordcla)
                                 VALUES (clausula(i).parametros(z).sclagen, vsolicit, 0,
                                         vnmovimi, clausula(i).parametros(z).nparame,
                                         clausula(i).parametros(z).ttexto,
                                         NVL(clausula(i).cidentity, 1));
                         END IF;
                      END LOOP;
                   END IF;
                END IF;
             END IF;
          END LOOP;

          RETURN 0;   --Tot ok
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarclausulas;

       /*************************************************************************
          Grabar la gestion de comisiones de la poliza
          param in gstcomi   : objeto gestion de comisiones
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabargstcomision(gstcomi IN t_iax_gstcomision, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          num            NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarGstComision';
       BEGIN
          IF gstcomi IS NULL THEN
             RETURN 0;
          END IF;

          IF gstcomi.COUNT = 0 THEN
             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --// ACC afegit q quan gravi primer borri
             vpasexec := 6;

             -- Borrem perque buidarem l'objecte
             DELETE FROM estcomisionsegu
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi;   -- Bug 30642/169851 - 20/03/2014 - AMC

             FOR i IN gstcomi.FIRST .. gstcomi.LAST LOOP
                vpasexec := 7;

                IF gstcomi.EXISTS(i)
                   AND gstcomi(i).pcomisi IS NOT NULL THEN
                   vpasexec := 8;

                   IF gstcomi(i).pcomisi IS NOT NULL THEN
                      SELECT COUNT(*)
                        INTO num
                        FROM estcomisionsegu
                       WHERE sseguro = vsolicit
                         AND nmovimi = vnmovimi   -- Bug 30642/169851 - 20/03/2014 - AMC
                         AND cmodcom = gstcomi(i).cmodcom
                         AND ninialt = gstcomi(i).ninialt
                         AND nfinalt = gstcomi(i).nfinalt;

                      IF num > 0 THEN   --existeix, updatejem
                         vpasexec := 9;

                         UPDATE estcomisionsegu
                            SET cmodcom = gstcomi(i).cmodcom,
                                pcomisi = gstcomi(i).pcomisi,
                                ninialt = gstcomi(i).ninialt,
                                nfinalt = gstcomi(i).nfinalt
                          WHERE sseguro = vsolicit
                            AND nmovimi = vnmovimi   -- Bug 30642/169851 - 20/03/2014 - AMC
                            AND cmodcom = gstcomi(i).cmodcom;
                      ELSE
                         vpasexec := 10;

                         -- Bug 30642/169851 - 20/03/2014 - AMC
                         INSERT INTO estcomisionsegu
                                     (sseguro, cmodcom, pcomisi,
                                      ninialt, nfinalt, nmovimi)
                              VALUES (vsolicit, gstcomi(i).cmodcom, gstcomi(i).pcomisi,
                                      gstcomi(i).ninialt, gstcomi(i).nfinalt, vnmovimi);
                      END IF;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargstcomision;

    /*************************************************************************
        Grabar informacion del riesgo -->>
    *************************************************************************/

       /*************************************************************************
          Grabar riesgo personal de la poliza
          param in personas  : objeto personas
          param in riesgo    : objeto de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarriesgopersonal(
          personas IN t_iax_personas,
          riesgo IN ob_iax_riesgos,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vtab           VARCHAR2(200);
          ncount         NUMBER := 0;
          cur            sys_refcursor;
          curid          INTEGER;
          dummy          INTEGER;
          squery         LONG;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarRiesgoPersonal';
          v_sperson_1    per_personas.sperson%TYPE; -- IAXIS-5420 -- 28/11/2019

       BEGIN
          IF personas IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001122);
             RETURN 1;
          END IF;

          IF personas.COUNT = 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001122);
             RETURN 1;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vtab := 'estriesgos';
             --// ACC afegit q quan gravi primer borri
             vpasexec := 2;

             DELETE FROM estriesgos
                   WHERE sseguro = vsolicit
                     AND nmovima = riesgo.nmovima
                     AND nriesgo = riesgo.nriesgo;
          END IF;

          vpasexec := 3;

          OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro =' || vsolicit
                       || ' and nriesgo=' || riesgo.nriesgo || ' and nmovima=' || riesgo.nmovima;

          FETCH cur
           INTO ncount;

          CLOSE cur;
          -- INI -- IAXIS-5420 -- 28/11/2019
          IF NVL(pac_mdpar_productos.f_get_parproducto('RIESGO_EN_ASEG_1', pac_iax_produccion.poliza.det_poliza.sproduc), 0) = 1 AND 
						personas.EXISTS(personas.first) THEN
						v_sperson_1 := personas(personas.first).sperson;
            IF ncount = 0 THEN
               --ACC 15122008 afegeixo el fanulac/nmovimib
               IF riesgo.fanulac IS NOT NULL THEN
                  --MCC- 02/04/2009 - BUG 0009593: Nuevo campo cactivi
                  -- Bug 21907 - MDS - 17/05/2012, añadir los cuatro campos
                  squery :=
                     'insert into ' || vtab
                     || '(sseguro,nriesgo,nmovima,fefecto,sperson,fanulac,nmovimb,cactivi,PDTOCOM, PRECARG, PDTOTEC, PRECCOM) '
                     || ' values (' || vsolicit || ',' || riesgo.nriesgo || ','
                     || riesgo.nmovima || ',' || CHR(39) || riesgo.fefecto || CHR(39) || ','
                     || v_sperson_1 || ',' || CHR(39) || riesgo.fanulac || CHR(39)
                     || ',' || riesgo.nmovimb || ',' || CHR(39) || riesgo.cactivi || CHR(39)
                     || ',' || CHR(39) || riesgo.primas.pdtocom || CHR(39) || ',' || CHR(39)
                     || riesgo.primas.precarg || CHR(39) || ',' || CHR(39)
                     || riesgo.primas.pdtotec || CHR(39) || ',' || CHR(39)
                     || riesgo.primas.preccom || CHR(39) || ')';
               ELSE
                  --MCC- 02/04/2009 - BUG 0009593: Nuevo campo cactivi
                  -- Bug 21907 - MDS - 17/05/2012, añadir los cuatro campos
                  squery :=
                     'insert into ' || vtab
                     || '(sseguro,nriesgo,nmovima,fefecto,sperson,cactivi,PDTOCOM, PRECARG, PDTOTEC, PRECCOM) '
                     || ' values (' || vsolicit || ',' || riesgo.nriesgo || ','
                     || riesgo.nmovima || ',' || CHR(39) || riesgo.fefecto || CHR(39) || ','
                     || v_sperson_1 || ',' || CHR(39) || riesgo.cactivi || CHR(39)
                     || ',' || CHR(39) || riesgo.primas.pdtocom || CHR(39) || ',' || CHR(39)
                     || riesgo.primas.precarg || CHR(39) || ',' || CHR(39)
                     || riesgo.primas.pdtotec || CHR(39) || ',' || CHR(39)
                     || riesgo.primas.preccom || CHR(39) || ')';
               END IF;
            ELSE
               --ACC 15122008 afegeixo el fanulac/nmovimib
               --MCC- 02/04/2009 - BUG 0009593: Nuevo campo cactivi
               -- Bug 21907 - MDS - 17/05/2012, añadir los cuatro campos
               squery := 'update ' || vtab || ' set fefecto=' || CHR(39) || riesgo.fefecto
                         || CHR(39) || ', ' || ' sperson=' || v_sperson_1 || ', '
                         || ' fanulac=' || CHR(39) || NVL(riesgo.fanulac, 'null') || CHR(39)
                         || ', ' || ' nmovimb=' || CHR(39) || riesgo.nmovimb || CHR(39)
                         || ', ' || ' cactivi=' || CHR(39) || riesgo.cactivi || CHR(39)
                         || ', ' || ' pdtocom=' || CHR(39) || riesgo.primas.pdtocom || CHR(39)
                         || ', ' || ' precarg=' || CHR(39) || riesgo.primas.precarg || CHR(39)
                         || ', ' || ' pdtotec=' || CHR(39) || riesgo.primas.pdtotec || CHR(39)
                         || ', ' || ' preccom=' || CHR(39) || riesgo.primas.preccom || CHR(39)
                         || ' where sseguro=' || vsolicit || ' and ' || ' nriesgo='
                         || riesgo.nriesgo || ' and ' || ' nmovima=' || riesgo.nmovima;
            END IF;

            vpasexec := 6;
            curid := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid);
            DBMS_SQL.close_cursor(curid);

            IF dummy = 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001123);
               RETURN 1;
            END IF;
					ELSE
				  -- FIN -- IAXIS-5420 -- 28/11/2019
            FOR vper IN personas.FIRST .. personas.LAST LOOP
               vpasexec := 4;

               IF personas.EXISTS(vper) THEN
                  vpasexec := 5;

                  IF ncount = 0 THEN
                     --ACC 15122008 afegeixo el fanulac/nmovimib
                     IF riesgo.fanulac IS NOT NULL THEN
                        --MCC- 02/04/2009 - BUG 0009593: Nuevo campo cactivi
                        -- Bug 21907 - MDS - 17/05/2012, añadir los cuatro campos
                        squery :=
                           'insert into ' || vtab
                           || '(sseguro,nriesgo,nmovima,fefecto,sperson,fanulac,nmovimb,cactivi,PDTOCOM, PRECARG, PDTOTEC, PRECCOM) '
                           || ' values (' || vsolicit || ',' || riesgo.nriesgo || ','
                           || riesgo.nmovima || ',' || CHR(39) || riesgo.fefecto || CHR(39) || ','
                           || personas(vper).sperson || ',' || CHR(39) || riesgo.fanulac || CHR(39)
                           || ',' || riesgo.nmovimb || ',' || CHR(39) || riesgo.cactivi || CHR(39)
                           || ',' || CHR(39) || riesgo.primas.pdtocom || CHR(39) || ',' || CHR(39)
                           || riesgo.primas.precarg || CHR(39) || ',' || CHR(39)
                           || riesgo.primas.pdtotec || CHR(39) || ',' || CHR(39)
                           || riesgo.primas.preccom || CHR(39) || ')';
                     ELSE
                        --MCC- 02/04/2009 - BUG 0009593: Nuevo campo cactivi
                        -- Bug 21907 - MDS - 17/05/2012, añadir los cuatro campos
                        squery :=
                           'insert into ' || vtab
                           || '(sseguro,nriesgo,nmovima,fefecto,sperson,cactivi,PDTOCOM, PRECARG, PDTOTEC, PRECCOM) '
                           || ' values (' || vsolicit || ',' || riesgo.nriesgo || ','
                           || riesgo.nmovima || ',' || CHR(39) || riesgo.fefecto || CHR(39) || ','
                           || personas(vper).sperson || ',' || CHR(39) || riesgo.cactivi || CHR(39)
                           || ',' || CHR(39) || riesgo.primas.pdtocom || CHR(39) || ',' || CHR(39)
                           || riesgo.primas.precarg || CHR(39) || ',' || CHR(39)
                           || riesgo.primas.pdtotec || CHR(39) || ',' || CHR(39)
                           || riesgo.primas.preccom || CHR(39) || ')';
                     END IF;
                  ELSE
                     --ACC 15122008 afegeixo el fanulac/nmovimib
                     --MCC- 02/04/2009 - BUG 0009593: Nuevo campo cactivi
                     -- Bug 21907 - MDS - 17/05/2012, añadir los cuatro campos
                     squery := 'update ' || vtab || ' set fefecto=' || CHR(39) || riesgo.fefecto
                               || CHR(39) || ', ' || ' sperson=' || personas(vper).sperson || ', '
                               || ' fanulac=' || CHR(39) || NVL(riesgo.fanulac, 'null') || CHR(39)
                               || ', ' || ' nmovimb=' || CHR(39) || riesgo.nmovimb || CHR(39)
                               || ', ' || ' cactivi=' || CHR(39) || riesgo.cactivi || CHR(39)
                               || ', ' || ' pdtocom=' || CHR(39) || riesgo.primas.pdtocom || CHR(39)
                               || ', ' || ' precarg=' || CHR(39) || riesgo.primas.precarg || CHR(39)
                               || ', ' || ' pdtotec=' || CHR(39) || riesgo.primas.pdtotec || CHR(39)
                               || ', ' || ' preccom=' || CHR(39) || riesgo.primas.preccom || CHR(39)
                               || ' where sseguro=' || vsolicit || ' and ' || ' nriesgo='
                               || riesgo.nriesgo || ' and ' || ' nmovima=' || riesgo.nmovima;
                  END IF;

                  vpasexec := 6;
                  curid := DBMS_SQL.open_cursor;
                  for i in 0..round(nvl(length(squery),1)/240,0) loop
                      p_control_error('JLTS',i,substr(squery,i*240+1,240));
                  end loop;
                  DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
                  dummy := DBMS_SQL.EXECUTE(curid);
                  DBMS_SQL.close_cursor(curid);

                  IF dummy = 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001123);
                     RETURN 1;
                  END IF;
               END IF;
            END LOOP;
          END IF; -- IAXIS-5420 -- 28/11/2019
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
       END f_grabarriesgopersonal;

       /*************************************************************************
          Grabar informacion del riesgo direcciones
          param in direc     : objeto direcciones
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarriesgodirecciones(
          direc IN t_iax_direcciones,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarRiesgoDirecciones';
       BEGIN
          RETURN NULL;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarriesgodirecciones;

       /*************************************************************************
          Grabar informacion de los asegurados
          param in aseg      : objeto direcciones
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarasegurados(
          aseg IN t_iax_asegurados,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vtab           VARCHAR2(200);
          ncount         NUMBER := 0;
          cur            sys_refcursor;
          curid          INTEGER;
          dummy          INTEGER;
          squery         LONG;
          vfield         LONG;
          vcdomici       NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarAsegurados';
       BEGIN
          IF aseg IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001124);
             RETURN 1;
          END IF;

          IF aseg.COUNT = 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001124);
             RETURN 1;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vtab := 'estassegurats';
             --// ACC afegit q quan gravi primer borri
             vpasexec := 2;
          --// ACC 16062008 es passa a nivell risc general sino ho borra tot per risc
          --// delete from estassegurats where sseguro=vsolicit;
          END IF;

          FOR vasg IN aseg.FIRST .. aseg.LAST LOOP
             vpasexec := 3;

             IF aseg.EXISTS(vasg) THEN
                vpasexec := 4;
    --                open cur for 'select count(*) from '|| vtab||
    --                             ' where sseguro'||'='||vsolicit||
    --                             ' and norden='|| aseg(vasg).norden;
    --                fetch cur into ncount;
    --                close cur;
                vpasexec := 5;

                IF aseg(vasg).direcciones IS NOT NULL THEN
                   vpasexec := 6;

                   IF aseg(vasg).direcciones.COUNT > 0 THEN
                      vpasexec := 7;

                      FOR vdir IN aseg(vasg).direcciones.FIRST .. aseg(vasg).direcciones.LAST LOOP
                         vpasexec := 8;

                         IF aseg(vasg).direcciones.EXISTS(vdir) THEN
                            vpasexec := 9;
                            vcdomici := aseg(vasg).direcciones(vdir).cdomici;
                         END IF;
                      END LOOP;
                   END IF;
                END IF;

                IF ncount = 0 THEN
                   IF vpmode = 'EST' THEN
                      vpasexec := 10;

                      --ACC 15122008 afegeixo el ffecfin
                      INSERT INTO estassegurats
                                  (sseguro, sperson, norden, cdomici,
                                   ffecini, ffecfin,
                                   fecretroact, cparen)
                           VALUES (vsolicit, aseg(vasg).sperson, aseg(vasg).norden, vcdomici,
                                   aseg(vasg).ffecini, aseg(vasg).ffecfin,
                                   aseg(vasg).fecretroact, aseg(vasg).cparen);
                   END IF;
                ELSE
                   IF vpmode = 'EST' THEN
                      vpasexec := 12;

                      UPDATE estassegurats
                         SET sperson = aseg(vasg).sperson,
                             cdomici = vcdomici,
                             ffecfin = aseg(vasg).ffecfin,
                             fecretroact = aseg(vasg).fecretroact,
                             cparen = aseg(vasg).cparen
                       WHERE sseguro = vsolicit
                         AND norden = aseg(vasg).norden;
                   END IF;
                END IF;
             END IF;
          END LOOP;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;

             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;

             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);

             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;

             RETURN 1;
       END f_grabarasegurados;

       /*************************************************************************
          Grabar informacion de las preguntas
          param in pregun    : objeto preguntas
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarpreguntasriesgo(
          pregun IN t_iax_preguntas,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          -- Bug 32015 - JMF - 07/10/2014 Control errores
          ncount         NUMBER := 0;
          nerr           NUMBER;
          cur            sys_refcursor;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(500) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarPreguntasRiesgo';
          pregtab        t_iax_preguntastab;
          pregtab_col    t_iax_preguntastab_columns;
       BEGIN
          vpasexec := 100;

          IF pregun IS NULL THEN
             RETURN 0;
          END IF;

          IF pregun.COUNT = 0 THEN
             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vparam := 's=' || vsolicit || ' m=' || vnmovimi || ' r=' || pnriesgo;
             --// ACC afegit q quan gravi primer borri
             vpasexec := 110;

             DELETE FROM estpregunseg
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND nriesgo = pnriesgo;

             vpasexec := 120;

             DELETE FROM estpregunsegtab
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND nriesgo = pnriesgo;

             FOR vprg IN pregun.FIRST .. pregun.LAST LOOP
                vpasexec := 130;

                IF pregun.EXISTS(vprg) THEN
                   vpasexec := 140;
                   vparam := 's=' || vsolicit || ' m=' || vnmovimi || ' r=' || pnriesgo || ' p='
                             || pregun(vprg).cpregun;

                   BEGIN
                      SELECT COUNT(*)
                        INTO ncount
                        FROM estpregunseg
                       WHERE sseguro = vsolicit
                         AND nriesgo = pnriesgo
                         AND nmovimi = vnmovimi
                         AND cpregun = pregun(vprg).cpregun;
                   EXCEPTION
                      WHEN OTHERS THEN
                         ncount := 0;
                   END;

                   vpasexec := 150;

                   -- BUG9988:DRA:06/05/2009:Inici
                   IF NVL(pregun(vprg).crespue, -1) <> -1
                      OR NVL(pregun(vprg).trespue, ' ') <> ' ' THEN
                      IF ncount > 0 THEN
                         vpasexec := 160;

                         UPDATE estpregunseg
                            SET crespue = NVL(pregun(vprg).crespue, 0),
                                trespue = pregun(vprg).trespue
                          WHERE sseguro = vsolicit
                            AND nriesgo = pnriesgo
                            AND cpregun = pregun(vprg).cpregun
                            AND nmovimi = vnmovimi;
                      ELSE
                         vpasexec := 170;

                         INSERT INTO estpregunseg
                                     (sseguro, nriesgo, cpregun,
                                      crespue, nmovimi, trespue)
                              VALUES (vsolicit, pnriesgo, pregun(vprg).cpregun,
                                      NVL(pregun(vprg).crespue, 0), vnmovimi, pregun(vprg).trespue);
                      END IF;
                   END IF;
                -- BUG9988:DRA:06/05/2009:Fi
                END IF;

                vpasexec := 180;
                pregtab := pregun(vprg).tpreguntastab;

                IF pregtab IS NOT NULL THEN
                   --Antes de hacer el traspaso a las subtablas, borramos los registros anteriores para reflejar
                   --las modificaciones y eliminaciones
                   vpasexec := 190;

                   DELETE FROM estsubtabs_seg_det
                         WHERE sseguro = vsolicit
                           AND nriesgo = pnriesgo
                           AND nmovimi = vnmovimi
                           AND cpregun = pregun(vprg).cpregun;

                   vpasexec := 200;

                   IF pregtab.COUNT <> 0 THEN
                      FOR j IN pregtab.FIRST .. pregtab.LAST LOOP
                         vpasexec := 210;
                         pregtab_col := pregtab(j).tcolumnas;

                         IF pregtab_col IS NOT NULL THEN
                            IF pregtab_col.COUNT <> 0 THEN
                               vpasexec := 220;

                               FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                                  IF pregtab_col.EXISTS(k) THEN
                                     vpasexec := 230;

                                     BEGIN
                                        SELECT COUNT(*)
                                          INTO ncount
                                          FROM estpregunsegtab
                                         WHERE sseguro = vsolicit
                                           AND nriesgo = pnriesgo
                                           AND nmovimi = vnmovimi
                                           AND cpregun = pregun(vprg).cpregun
                                           AND nlinea = pregtab(j).nlinea
                                           AND ccolumna = pregtab_col(k).ccolumna;
                                     EXCEPTION
                                        WHEN OTHERS THEN
                                           ncount := 0;
                                     END;

                                     IF ncount > 0 THEN
                                        vpasexec := 240;

                                        UPDATE estpregunsegtab
                                           SET nvalor = NVL(pregtab_col(k).nvalor, 0),
                                               tvalor = pregtab_col(k).tvalor,
                                               fvalor = pregtab_col(k).fvalor
                                         WHERE sseguro = vsolicit
                                           AND nriesgo = pnriesgo
                                           AND nmovimi = vnmovimi
                                           AND cpregun = pregun(vprg).cpregun
                                           AND nlinea = pregtab(j).nlinea
                                           AND ccolumna = pregtab_col(k).ccolumna;
                                     ELSE
                                        vpasexec := 250;

                                        INSERT INTO estpregunsegtab
                                                    (sseguro, nriesgo, cpregun,
                                                     nlinea, nmovimi,
                                                     ccolumna,
                                                     nvalor,
                                                     tvalor, fvalor)
                                             VALUES (vsolicit, pnriesgo, pregun(vprg).cpregun,
                                                     pregtab(j).nlinea, vnmovimi,
                                                     pregtab_col(k).ccolumna,
                                                     NVL(pregtab_col(k).nvalor, 0),
                                                     pregtab_col(k).tvalor, pregtab_col(k).fvalor);
                                     END IF;
                                  END IF;
                               END LOOP;
                            END IF;
                         END IF;

                         vpasexec := 260;
                         nerr := pac_preguntas.f_traspaso_subtabs_seg('EST', vsolicit, vnmovimi,
                                                                      pregun(vprg).cpregun, 'R',
                                                                      pregtab(j).nlinea, pnriesgo,
                                                                      0, nerr);
                      END LOOP;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          vpasexec := 270;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarpreguntasriesgo;

       /*************************************************************************
          Grabar informacion de las garantias
          param in garan     : objeto garantias
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabargarantias(
          garan IN t_iax_garantias,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarGarantias';
          -- Bug 11735 - RSC - 20/01/2010 - APR - suplemento de modificacion de capital /prima
          v_sproduc      estseguros.sproduc%TYPE;
       -- Fin Bug 11735
          v_cactivi         NUMBER:= 0; -- CONF-1243 QT_724 -JLTS-23/01/2018
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vpasexec := 4;

             --// ACC afegit q quan gravi primer borri
             --// ACC nocal borrar les garantias les recuperem totes i temin el cobliga
             --       per informar de les seleccionades
             --delete from estgaranseg where sseguro=vsolicit  and nmovimi=vnmovimi;
             DELETE FROM estpregungaranseg
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND nriesgo = pnriesgo;

             DELETE FROM estpregungaransegtab
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND nriesgo = pnriesgo;

             -- Bug 31686/180369 - 22/07/2014 - AMC
             UPDATE estgaranseg
                SET cobliga = 0
              WHERE sseguro = vsolicit
                AND nmovimi = vnmovimi
                AND nriesgo = pnriesgo;

             -- Fi Bug 31686/180369 - 22/07/2014 - AMC
             vpasexec := 5;

             -- Taules EST
             -- Recorregut sobre la llista de garanties
             --XPL 0010930: CRE - Simulacion de productos colectivos, if para evitar que
             -- de error al acceder un riesgo que no tenga aun garantias.
             IF garan IS NOT NULL THEN
                IF garan.COUNT > 0 THEN
                   FOR i IN garan.FIRST .. garan.LAST LOOP
                      vpasexec := 6;

                      IF garan.EXISTS(i) THEN
                         vpasexec := 7;

                         -- Bug 11735 - RSC - 20/01/2010 - APR - suplemento de modificacion de capital /prima
                 -- CONF-1243 QT_724 -JLTS-23/01/2018 - Se adiciona cactivi
                         SELECT sproduc,cactivi
                           INTO v_sproduc,v_cactivi
                           FROM estseguros
                          WHERE sseguro = vsolicit;

                         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
                            -- Bug 11735 - RSC - 22/03/2010 - APR - suplemento de modificacion de capital /prima (añadimos isbajagar)
                            IF pac_iax_produccion.isaltagar THEN
                               vnum := f_grabargarantia_alta(garan(i), pnriesgo, mensajes);
                            ELSIF pac_iax_produccion.imodifgar THEN
                               vnum :=
                                  f_grabargarantia_modif(garan(i), pnriesgo, mensajes,

                                                         -- Bug 13832 - RSC - 08/06/2010 - APRS015 - suplemento de aportaciones unicas
                                                         pac_iax_suplementos.lstmotmov(1).cmotmov);
                            -- Fin Bug 13832
                            ELSIF pac_iax_produccion.isbajagar THEN
                               vnum := f_grabargarantia_baja(garan(i), pnriesgo, mensajes);
                            ELSE
                               vnum := f_grabargarantia(garan(i), pnriesgo, mensajes);
                            END IF;
                         ELSE
                            -- Fin Bug 11735
                            vnum := f_grabargarantia(garan(i), pnriesgo, mensajes);
                         END IF;
                      END IF;
                   END LOOP;
                END IF;
             END IF;
          END IF;

          RETURN vnum;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargarantias;

       /*************************************************************************
          Grabar informacion de la garantia
          param in garan     : objeto garantia
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabardesglosegarantia(
          desglose IN t_iax_desglose_gar,
          pnriesgo IN NUMBER,
          pcgarant IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_grabardesglosegarantia';
          vcapital       NUMBER;
          -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
          v_sproduc      seguros.sproduc%TYPE;
          v_fvencim      pregungaranseg.crespue%TYPE;
          v_ndurcob      pregungaranseg.crespue%TYPE;
          v_ffincob      detgaranseg.ffincob%TYPE;
          v_cactivi      seguros.cactivi%TYPE;
          v_pinttec      NUMBER;
          v_pintmin      NUMBER;
          v_cagente      seguros.cagente%TYPE;
          v_nmovimi      garanseg.nmovimi%TYPE;
          v_pregs        t_iax_preguntas;
          v_cramo        seguros.cramo%TYPE;
          v_cmodali      seguros.cmodali%TYPE;
          v_ctipseg      seguros.ctipseg%TYPE;
          v_ccolect      seguros.ccolect%TYPE;
          v_cobliga      estgaranseg.cobliga%TYPE;
          v_csituac      seguros.csituac%TYPE;   -- BUG11737:DRA:21/01/2010
          -- Fin Bug 10757
             -- Bug 13727 - RSC - 24/02/2010 - APR - Analisis/Implementacion de nuevas combinaciones de tarificacion Flexilife Nueva Emision
          v_ctarifa      NUMBER;
       -- Fin Bug 13727
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             DELETE      estgarandetcap
                   WHERE cgarant = pcgarant
                     AND sseguro = vsolicit
                     AND nriesgo = pnriesgo
                     AND nmovimi = vnmovimi;

             IF desglose IS NOT NULL
                AND desglose.COUNT > 0 THEN
                FOR i IN desglose.FIRST .. desglose.LAST LOOP
                   vpasexec := 7;

                   IF desglose.EXISTS(i) THEN
                      BEGIN
                         INSERT INTO estgarandetcap
                                     (sseguro, nriesgo, cgarant, nmovimi, norden,
                                      cconcepto, tdescrip,
                                      icapital)
                              VALUES (vsolicit, pnriesgo, pcgarant, vnmovimi, desglose(i).norden,
                                      desglose(i).cconcepto, desglose(i).tdescripcion,
                                      desglose(i).icapital);
                      EXCEPTION
                         WHEN DUP_VAL_ON_INDEX THEN
                            UPDATE estgarandetcap
                               SET cconcepto = desglose(i).cconcepto,
                                   tdescrip = desglose(i).tdescripcion,
                                   icapital = desglose(i).icapital
                             WHERE sseguro = vsolicit
                               AND nriesgo = pnriesgo
                               AND cgarant = pcgarant
                               AND nmovimi = vnmovimi
                               AND norden = desglose(i).norden;
                      END;
                   ELSE
                      DELETE      estgarandetcap
                            WHERE sseguro = vsolicit
                              AND nriesgo = pnriesgo
                              AND cgarant = pcgarant
                              AND nmovimi = vnmovimi
                              AND norden = i;
                   END IF;
                END LOOP;
             END IF;

             vpasexec := 10;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabardesglosegarantia;

       /*************************************************************************
          Grabar informacion de la garantia
          param in garan     : objeto garantia
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabargarantia(
          garan IN ob_iax_garantias,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          -- Bug 32015 - JMF - 07/10/2014 Control errores
          vparam         VARCHAR2(500) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarGarantia';
          vcapital       NUMBER;
          -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
          v_sproduc      seguros.sproduc%TYPE;
          v_fvencim      pregungaranseg.crespue%TYPE;
          v_ndurcob      pregungaranseg.crespue%TYPE;
          v_ffincob      detgaranseg.ffincob%TYPE;
          v_cactivi      seguros.cactivi%TYPE;
          v_pinttec      NUMBER;
          v_pintmin      NUMBER;
          v_cagente      seguros.cagente%TYPE;
          v_nmovimi      garanseg.nmovimi%TYPE;
          v_pregs        t_iax_preguntas;
          v_cramo        seguros.cramo%TYPE;
          v_cmodali      seguros.cmodali%TYPE;
          v_ctipseg      seguros.ctipseg%TYPE;
          v_ccolect      seguros.ccolect%TYPE;
          v_cobliga      estgaranseg.cobliga%TYPE;
          v_csituac      seguros.csituac%TYPE;   -- BUG11737:DRA:21/01/2010
          -- Fin Bug 10757
             -- Bug 13727 - RSC - 24/02/2010 - APR - Analisis/Implementacion de nuevas combinaciones de tarificacion Flexilife Nueva Emision
          v_ctarifa      NUMBER;
          -- Fin Bug 13727
          v_ftarifa      DATE;   -- Bug 18848 - APD - 22/06/2011
          -- FBL. 25/06/2014 MSV Bug 0028974
          v_ipriant      NUMBER;
          v_ipricom      NUMBER;
          --v_nmovimi      NUMBER;
       -- Fin FBL. 25/06/2014 MSV Bug 0028974
         -- INI BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
            v_finivig DATE := TO_DATE(NULL);
            v_ffinvig DATE := TO_DATE(NULL);
            v_extcontractual NUMBER := 0;
         -- FIN BUG CONF-1243 QT_724
       BEGIN
          vpasexec := 100;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vparam := 's=' || vsolicit || ' r=' || pnriesgo || ' g=' || garan.cgarant;

             --// ACC afegit q quan gravi primer borri
             --// ACC una sola garantia no borrar pas ndelete from estgaranseg where sseguro=vsolicit  and nmovimi=vnmovimi;
             --  Bug 10898 - 19/08/2009 - JRH - Mantener Capitales migrados en productos de salud al realizar suplemento
             IF garan.ctipo IN(8, 9, 5)
                OR(NVL(garan.ctipo, 0) IN(0, 6)
                   AND NVL(garan.cobliga, 0) <> 0) THEN
                 --Si no da problemas en los capitales calculados si icapital=null
                --  fi Bug 10898 - 19/08/2009 - JRH
                   --JRH Le ponemos informado el capital para que no se queje el pk_nuevaproduccion (que diga que es nula la prima). Pero habriamos de tocar el Pk_nuevaproduccion.
                IF garan.icapital IS NULL THEN
                   vcapital := 0;
    --JRH Le ponemos informado el capital para que no se queje el pk_nuevaproduccion (que diga que es nula la prima). Pero habriamos de tocar el Pk_nuevaproduccion.
                ELSE
                   vcapital := garan.icapital;
                END IF;
             ELSE   --JRH Asi nos tarifica y calcula primas y capitales
                vcapital := NULL;
             END IF;

             vpasexec := 110;

             SELECT COUNT(*)
               INTO vnum
               FROM estgaranseg g
              WHERE g.sseguro = vsolicit
                AND g.nriesgo = pnriesgo
                AND g.cgarant = garan.cgarant
                AND g.ffinefe IS NULL;

    --//ACC 18032009 no ha de controlar en nmovimi sino data fi --and g.nmovimi = vnmovimi

             -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
             vpasexec := 120;
             vnumerr := pac_seguros.f_get_sproduc(vsolicit, 'EST', v_sproduc);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             vparam := vparam || ' p=' || v_sproduc;
             -- Fin Bug 10757

             -- Bug 18848 - APD - 22/06/2011
             -- si 'FECHA_TARIFA' = 1.- Fecha de efecto --> tal y como funciona hasta ahora
             -- si 'FECHA_TARIFA' = 2.- Fecha de grabacion inicial --> FTARIFA = F_SYSDATE
             vpasexec := 130;

             IF NVL(f_parproductos_v(v_sproduc, 'FECHA_TARIFA'), 1) = 1 THEN   -- Fecha de efecto
                v_ftarifa := garan.finiefe;
             ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHA_TARIFA'), 1) = 2 THEN   -- Fecha de grabacion inicial
                -- Bug 21708 - APD - 12/04/2012 - se comenta el IF ya que parece que ya no
                -- es necesario
                --IF pac_iax_simulaciones.islimpiartemporales = TRUE THEN
                v_ftarifa := NVL(garan.masdatos.ftarifa, TRUNC(f_sysdate));
             --ELSE
             --   v_ftarifa := TRUNC(f_sysdate);
             --END IF;
             -- fin Bug 21708 - APD - 12/04/2012
             END IF;

             -- Fin Bug 18848 - APD - 22/06/2011
             -- Msv: calculamos la diferencia entre la prima anual actual y la del a??nterior
             -- Ini Bug 28974 - MSV - 11/12/2013 - FBL - Calcular el ipricom
             v_ipriant := 0;
             v_ipricom := 0;

             -- FBL. 25/06/2014 MSV Bug 0028974
             IF NVL(garan.cobliga, 0) <> 0 THEN
                BEGIN
                   vpasexec := 140;

                   SELECT g.iprianu
                     INTO v_ipriant
                     FROM estseguros s, garanseg g
                    WHERE s.sseguro = vsolicit
                      AND s.ssegpol = g.sseguro
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ffinefe IS NULL;

                   --    SELECT g.iprianu
                    --     INTO v_ipriant
                    --     FROM estgaranseg eg, estseguros s, garanseg g
                    --    WHERE eg.sseguro = vsolicit
                    --      AND eg.nriesgo = pnriesgo
                     --     AND eg.cgarant = garan.cgarant
                     --     AND eg.sseguro = s.sseguro
                     --     AND s.ssegpol = g.sseguro
                     --     And G.FFINEFE IS NULL;
                       --   AND g.nmovimi = (SELECT MAX(nmovimi)
                        --                     FROM garanseg g2
                        --                    WHERE g2.sseguro = s.ssegpol
                        --                      AND g2.nriesgo = pnriesgo
                         --                     AND g2.cgarant = garan.cgarant
                          --                    AND g2.nmovimi <= g.nmovimi);
                   IF (vnmovimi > 1) THEN
                      v_ipricom := NVL(garan.primas.iprianu, 0) - v_ipriant;
                   ELSE
                      v_ipricom := NVL(garan.primas.iprianu, 0);
                   END IF;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      -- si la select no encuentra datos, es porque es nueva producci??Entonces el importe es el de la anualidad
                      v_ipricom := garan.primas.iprianu;
                END;
             END IF;
            -- INI BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
            IF pac_iax_produccion.issuplem THEN
            IF pac_iax_suplementos.lstmotmov.count > 0 THEN
              IF pac_iax_suplementos.lstmotmov(1).cmotmov = 918 AND
                pac_iax_suplementos.lstmotmov(1).fefecto IS NOT NULL AND
                pac_iax_suplementos.lstmotmov(1).fvencim IS NOT NULL AND
                pac_iax_suplementos.lstmotmov(1).fvencplazo IS NOT NULL AND
                garan.cobliga = 1 THEN
                BEGIN
                                select e.cactivi
                    INTO v_cactivi
                    from estseguros e
                   where e.sseguro = vsolicit;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    v_sproduc := null;
                    v_cactivi := NULL;
                          END;
                v_extcontractual := NVL(pac_iaxpar_productos.f_get_pargarantia('EXCONTRACTUAL',
                                                                                v_sproduc,
                                                                                garan.cgarant,
                                                                                v_cactivi),0);


                IF v_extcontractual in (0) THEN
                  v_finivig := NVL(pac_iax_suplementos.lstmotmov(1).finiefe,garan.finivig);
                  v_ffinvig := NVL(pac_iax_suplementos.lstmotmov(1).fvencim,garan.ffinvig);
                  -- INI CONF-1286_QT_645 - JLTS - 20/02/2018 -- Se separa el contractual igual a uno (1)
                ELSIF v_extcontractual in (1) THEN
                  v_finivig := NVL(pac_iax_suplementos.lstmotmov(1).finiefe,garan.finivig);
                  v_ffinvig := NVL(pac_iax_suplementos.lstmotmov(1).fvencplazo,garan.ffinvig);
                  -- FIN CONF-1286_QT_645 - JLTS - 20/02/2018
                ELSIF v_extcontractual in (2) THEN
                  v_finivig := NVL(pac_iax_suplementos.lstmotmov(1).fvencplazo,garan.finivig);
                  v_ffinvig := NVL(pac_iax_suplementos.lstmotmov(1).fvencim,garan.ffinvig);
               END IF;
              ENd IF;
            END IF;
            END IF;
            -- FIN BUG CONF-1243 QT_724 - 23/01/2018

             -- Fin FBL. 25/06/2014 MSV Bug 0028974
             --and g.finiefe = garan.finiefe;
             IF vnum > 0 THEN
                vpasexec := 150;

                -- Bug 18848 - APD - 08/09/2011 - si se esta actualizando una garantia ya existente
                -- se busca su cobliga para saber si es una garantia que se acaba de seleccionar
                SELECT cobliga
                  INTO v_cobliga
                  FROM estgaranseg g
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant
                   AND g.ffinefe IS NULL;

                -- Fin Bug 18848 - APD - 08/09/2011

                --Ja existeix la garantia => La updategem.
                -- FBL. 25/06/2014 MSV Bug 0028974
                vpasexec := 160;

                UPDATE estgaranseg g
                   SET crevali = garan.crevali,
                       icapital = NVL(vcapital, garan.icapital),
                       icaptot = garan.icaptot,   --//ACC 17032008
                       iextrap = garan.primas.iextrap,
                       cfranq = garan.cfranq,
                       precarg = garan.primas.precarg,
                       irecarg = garan.primas.irecarg,
    -- Bug 13727 - RSC - 06/05/2010 - APR - Analisis/Implementacion de nuevas combinaciones de tarificacion Flexilife Nueva Emision
                       pdtocom = garan.primas.pdtocom,
                       prevali = garan.prevali,
                       irevali = garan.irevali,
                       cobliga = garan.cobliga,
                       -- Bug 9513 - APD - 10/07/2009 - CEM - Validacion de prima minima
                       iprianu = garan.primas.iprianu,
                       ipritar = garan.primas.ipritar,
                       itarifa = garan.primas.itarifa,
                       ipritot = garan.primas.ipritot,
                       ctarman = NVL(garan.ctarman, 0),
                       -- Bug 9513 - APD - 10/07/2009 - Fin CEM - Validacion de prima minima
                       cderreg = garan.cderreg,
    -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
                       -- Ini Bug 21907 - MDS - 23/04/2012
                       pdtotec = garan.primas.pdtotec,
                       preccom = garan.primas.preccom,
                       idtotec = garan.primas.idtotec,
                       ireccom = garan.primas.ireccom,
                       icaprecomend = garan.icaprecomend,
                       ipricom = v_ipricom,
                       -- Fin Bug 21907 - MDS - 23/04/2012
                       nfactor = garan.nfactor,   -- Bug 30171/173304 - 24/04/2014 - AMC
                       finivig  = NVL(v_finivig,garan.finivig),    -- BUG 41143/229973 - 17/03/2016 - JAEG -- CONF-1243 QT_724 -JLTS-23/01/2018
                       ffinvig  = NVL(v_ffinvig,garan.ffinvig),    -- BUG 41143/229973 - 17/03/2016 - JAEG -- CONF-1243 QT_724 -JLTS-23/01/2018
                       ccobprima = garan.ccobprima, -- BUG 41143/229973 - 17/03/2016 - JAEG
                       ipridev  = garan.ipridev     -- BUG 41143/229973 - 17/03/2016 - JAEG
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant
                   AND g.ffinefe IS NULL;

    -- Fin FBL. 25/06/2014 MSV Bug 0028974
    --//ACC 18032009 no ha de controlar en nmovimi sino data fi --and g.nmovimi = vnmovimi

                --and g.finiefe = garan.finiefe;

                -- Bug 18848 - APD - 08/09/2011 - si la garantia ya existia y se acaba de seleccionar
                -- se tiene que modificar su ftarifa segun el valor que le corresponda
                IF v_cobliga = 0
                   AND NVL(garan.cobliga, 0) = 1
                   AND NVL(f_parproductos_v(v_sproduc, 'FECHA_TARIFA'), 1) = 2 THEN
                   -- Bug 21708 - APD - 12/04/2012 - se sustituye la variable
                   -- v_ftarifa por TRUNC(f_sysdate)
                   vpasexec := 170;

                   UPDATE estgaranseg g
                      SET ftarifa = TRUNC(f_sysdate)   -- v_ftarifa
                    WHERE g.sseguro = vsolicit
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ffinefe IS NULL;
                -- fin Bug 21708 - APD - 12/04/2012
                END IF;
             -- Fin Bug 18848 - APD - 08/09/2011
             ELSE
                --No existeix la garantia => La insertem.
                vpasexec := 180;

                   -- Bug 18848 - APD - 22/06/2011
                   -- se sustituye el valor garan.finiefe por v_ftarifa que sera el que
                   -- se inserte en el campo estgaranseg.ftarifa
                   -- FBL. 25/06/2014 MSV Bug 0028974
                -- Ini Bug 21907 - MDS - 23/04/2012
                INSERT INTO estgaranseg
                            (cgarant, nriesgo, nmovimi, sseguro, finiefe,
                             norden, crevali, ctarifa, icapital,
                             precarg, iextrap, iprianu,
                             ffinefe, cformul, ctipfra, ifranqu, irecarg,
                             ipritar, pdtocom, idtocom,
                             prevali, irevali, itarifa, itarrea,
                             ipritot, icaptot, ftarifa,
                             crevalcar, cgasgar, pgasadq, pgasadm, pdtoint, idtoint, feprev,
                             fpprev, percre, cmatch, tdesmat, pintfin, cref, cintref, pdif,
                             pinttec, nparben, nbns, tmgaran, cderreg, ccampanya, nversio,
                             nmovima, cageven, nfactor, nlinea, cfranq, nfraver, ngrpfra,
                             ngrpgara, nordfra, pdtofra, cmotmov, finider, falta, ctarman,
                             cobliga, ctipgar, pdtotec,
                             preccom, idtotec, ireccom,
                             icaprecomend, ipricom,
                             finivig, ffinvig, ccobprima, ipridev  -- BUG 41143/229973 - 17/03/2016 - JAEG
                             )
                     VALUES
                            /*JAS tots els NULLS*/
                (            garan.cgarant, pnriesgo, vnmovimi, vsolicit, garan.finiefe,
                             garan.norden, garan.crevali, NULL, NVL(vcapital, garan.icapital),
                             garan.primas.precarg, garan.primas.iextrap, garan.primas.iprianu,
                             NULL, NULL, NULL, garan.ifranqu, garan.primas.irecarg,
                             garan.primas.ipritar, garan.primas.pdtocom, garan.primas.idtocom,
                             garan.prevali, garan.irevali, garan.primas.itarifa, NULL,
                             garan.primas.ipritot, garan.icaptot,   --//ACC 17032008
                                                                 v_ftarifa /*garan.finiefe*/,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, garan.cderreg, NULL, NULL,
    -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
                             garan.nmovima, NULL, garan.nfactor,   -- Bug 30171/173304 - 24/04/2014 - AMC
                                                                NULL, garan.cfranq, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NVL(garan.ctarman, 0),
                             garan.cobliga, garan.ctipgar,
                                                          -- Ini Bug 21907 - MDS - 23/04/2012
                                                          garan.primas.pdtotec,
                             garan.primas.preccom, garan.primas.idtotec, garan.primas.ireccom,
                             garan.icaprecomend, v_ipricom,
                             NVL(v_finivig,garan.finivig), NVL(v_ffinvig,garan.ffinvig), garan.ccobprima, garan.ipridev  -- BUG 41143/229973 - 17/03/2016 - JAEG  -- CONF-1243 QT_724 -JLTS-23/01/2018
                             );
               -- Fin Bug 21907 - MDS - 23/04/2012
               -- Fin Bug 18848 - APD - 22/06/2011
             -- Fin FBL. 25/06/2014 MSV Bug 0028974
             END IF;

             vpasexec := 190;
             vnumerr := pac_md_grabardatos.f_grabardesglosegarantia(garan.desglose, pnriesgo,
                                                                    garan.cgarant, mensajes);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             --JRH 03/2008
             IF garan.ctipo = 3 THEN
    --Informamos capital incial de la renta a partir del capitla del tipo 3 de la cobertura. Para usar en la tarificacion.
                vpasexec := 200;

                UPDATE estseguros_ren   --Si no hay registro no pasa nada.
                   SET icapren = garan.icapital
                 WHERE sseguro = vsolicit;
             END IF;

             --JRH 03/2008

             --Gravem les preguntes de la garantia
             vpasexec := 210;
             vnumerr := f_grabarpreguntasgarantia(garan.preguntas, pnriesgo, garan.cgarant,
                                                  mensajes);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- BUG11737:DRA:21/01/2010:Inici
             vpasexec := 220;
             vnumerr := pac_seguros.f_get_csituac(vsolicit, 'EST', v_csituac);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- BUG11737:DRA:21/01/2010:Fi
             -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
             -- Realizamos tratamiento del Detalle de garantia (APRA)
             IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2)
                AND NOT(pac_iax_produccion.issuplem
    -- BUG11737:DRA:21/01/2010: Que sea contratacion o edicio de una Prop. de alta
                        OR pac_iax_produccion.isconsult
                        OR(pac_iax_produccion.ismodifprop
                           AND v_csituac = 5)) THEN
                --
                vpasexec := 230;

                SELECT cramo, cmodali, ctipseg, ccolect
                  INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
                  FROM productos
                 WHERE sproduc = v_sproduc;

                vpasexec := 240;

                SELECT COUNT(*)
                  INTO vnum
                  FROM estdetgaranseg d, estgaranseg g
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant
                   AND g.ffinefe IS NULL
                   AND d.sseguro = g.sseguro
                   AND d.cgarant = g.cgarant
                   AND d.nriesgo = g.nriesgo
                   AND d.finiefe = g.finiefe
                   --AND d.nmovimi = vnmovimi
                   AND d.ndetgar = 0;

                --and g.finiefe = garan.finiefe;
                IF vnum > 0 THEN
                   -- Obtenemos la actividad del contrato
                   vpasexec := 250;
                   vnumerr := pac_seguros.f_get_cactivi(vsolicit, NULL, NULL, 'EST', v_cactivi);

                   IF vnumerr <> 0 THEN
                      RETURN vnumerr;
                   END IF;

                   vpasexec := 260;

                   SELECT cobliga
                     INTO v_cobliga
                     FROM estgaranseg g
                    WHERE g.sseguro = vsolicit
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ffinefe IS NULL;

                   IF v_cobliga = 1 THEN
                      IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                             garan.cgarant, 'TIPO'),
                             0) NOT IN(3, 4) THEN
                         -- Obtenemos la fecha de vencimiento de la garantia
                         vpasexec := 270;
                         vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                       pnriesgo, 1043, 'EST',
                                                                       v_fvencim);

                         IF vnumerr <> 0 THEN
                            -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                            IF vnumerr <> 120135 THEN
                               RETURN vnumerr;
                            ELSE
                               vpasexec := 280;

                               SELECT TO_NUMBER(TO_CHAR(fvencim, 'yyyymmdd'))
                                 INTO v_fvencim
                                 FROM estseguros
                                WHERE sseguro = vsolicit;
                            END IF;
                         -- Fin Bug 11075
                         END IF;

                         -- Obtenemos la fecha fin de pagos
                         vpasexec := 290;
                         vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                       pnriesgo, 1049, 'EST',
                                                                       v_ndurcob);

                         IF vnumerr <> 0 THEN
                            -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                            IF vnumerr <> 120135 THEN
                               RETURN vnumerr;
                            ELSE
                               vpasexec := 300;

                               SELECT ndurcob
                                 INTO v_ndurcob
                                 FROM estseguros
                                WHERE sseguro = vsolicit;

                               -- Bug 13727 - RSC - 18/03/2010 - APR - Analisis/Implementacion de nuevas
                               --                                      combinaciones de tarificacion Flexilife Nueva Emision
                               IF v_ndurcob IS NULL THEN
                                  vpasexec := 310;

                                  SELECT nduraci
                                    INTO v_ndurcob
                                    FROM estseguros
                                   WHERE sseguro = vsolicit;
                               END IF;
                            -- Fin Bug 13727
                            END IF;
                         -- Fin Bug 11075
                         END IF;

                         vpasexec := 320;
                         v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob * 12);
                      -- Fecha fin de pagos
                      END IF;
                   END IF;

                   vpasexec := 330;

                   UPDATE estdetgaranseg g
                      SET crevali = garan.crevali,
                          icapital = NVL(vcapital, garan.icapital),
                          precarg = garan.primas.precarg,
                          irecarg = garan.primas.irecarg,
    -- Bug 13727 - RSC - 06/05/2010 - APR - Analisis/Implementacion de nuevas combinaciones de tarificacion Flexilife Nueva Emision
                          pdtocom = garan.primas.pdtocom,
                          prevali = garan.prevali,
                          irevali = garan.irevali,
                          iprianu = garan.primas.iprianu,
                          ipritar = garan.primas.ipritar,
                          fvencim = DECODE(v_fvencim,
                                           NULL, NULL,
                                           0, NULL,
                                           TO_DATE(v_fvencim, 'yyyymmdd')),
                          ndurcob = v_ndurcob * 12,
                          ffincob = v_ffincob
                    WHERE g.sseguro = vsolicit
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ndetgar = 0
                      AND g.nmovimi = vnmovimi;
                ELSE
                   -- Obtenemos la actividad del contrato
                   vpasexec := 340;
                   vnumerr := pac_seguros.f_get_cactivi(vsolicit, NULL, NULL, 'EST', v_cactivi);

                   IF vnumerr <> 0 THEN
                      RETURN vnumerr;
                   END IF;

                   vpasexec := 350;

                   SELECT cobliga
                     INTO v_cobliga
                     FROM estgaranseg g
                    WHERE g.sseguro = vsolicit
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ffinefe IS NULL;

                   IF v_cobliga = 1 THEN
                      -- Obtenemos la fecha de vencimiento de la garantia
                      IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                             garan.cgarant, 'TIPO'),
                             0) NOT IN(3, 4) THEN
                         vpasexec := 360;
                         vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                       pnriesgo, 1043, 'EST',
                                                                       v_fvencim);

                         IF vnumerr <> 0 THEN
                            -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                            IF vnumerr <> 120135 THEN
                               RETURN vnumerr;
                            ELSE
                               vpasexec := 370;

                               SELECT TO_NUMBER(TO_CHAR(fvencim, 'yyyymmdd'))
                                 INTO v_fvencim
                                 FROM estseguros
                                WHERE sseguro = vsolicit;
                            END IF;
                         -- Fin Bug 11075
                         END IF;

                         -- Obtenemos la fecha fin de pagos
                         vpasexec := 380;
                         vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                       pnriesgo, 1049, 'EST',
                                                                       v_ndurcob);

                         IF vnumerr <> 0 THEN
                            -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                            IF vnumerr <> 120135 THEN
                               RETURN vnumerr;
                            ELSE
                               vpasexec := 390;

                               SELECT ndurcob
                                 INTO v_ndurcob
                                 FROM estseguros
                                WHERE sseguro = vsolicit;

                               -- Bug 13727 - RSC - 18/03/2010 - APR - Analisis/Implementacion de nuevas
                               --                                      combinaciones de tarificacion Flexilife Nueva Emision
                               IF v_ndurcob IS NULL THEN
                                  vpasexec := 400;

                                  SELECT nduraci
                                    INTO v_ndurcob
                                    FROM estseguros
                                   WHERE sseguro = vsolicit;
                               END IF;
                            -- Fin Bug 13727
                            END IF;
                         -- Fin Bug 11075
                         END IF;

                         vpasexec := 410;
                         v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob * 12);
                      -- Fecha fin de pagos
                      END IF;
                   END IF;

                   vpasexec := 420;
                   v_pintmin := pac_inttec.ff_int_gar_prod(v_sproduc, v_cactivi, garan.cgarant, 1,
                                                           f_sysdate, 0);   -- Interes minimo (Tarifa)

                   -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                   -- Si el producto es GROUPLIFE, v_ctarifa y v_pinttec se obtiene de la
                   -- pregunta 133 y su respuesta
                   IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                      AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                      vpasexec := 430;
                      vnumerr := pac_preguntas.f_get_pregunpolseg(vsolicit, 133, 'EST', v_ctarifa);

                      IF vnumerr <> 0 THEN
                         RETURN vnumerr;
                      END IF;

                      vpasexec := 440;
                      v_pinttec := vtramo(NULL,
                                          vtramo(NULL,
                                                 NVL(f_parproductos_v(v_sproduc, 'TRAMO_INTERES'),
                                                     0),
                                                 v_ctarifa),
                                          garan.cgarant);   -- Interes (Tarifa)
                   ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                      v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_VIGENTE');
                      v_pinttec := pac_inttec.ff_int_gar_seg('EST', vsolicit, garan.cgarant);   -- Interes (Tarifa)
                   END IF;

                   -- fin Bug 17105
                   -- Obtenemos el agente
                   vpasexec := 450;
                   vnumerr := pac_seguros.f_get_cagente(vsolicit, 'EST', v_cagente);

                   IF vnumerr <> 0 THEN
                      RETURN vnumerr;
                   END IF;

                   -- Bug 13727 - RSC - 18/03/2010 - APR - Analisis/Implementacion de nuevas
                   --                                      combinaciones de tarificacion Flexilife Nueva Emision
                   -- Bug 17105 - APD - 27/12/2010 - se comenta ya que se calcula mas arriba en funcion
                   -- del producto
                   --v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_VIGENTE');
                   -- fin Bug 17105

                   -- Fin Bug 11735
                   -- Bug 18848 - APD - 22/06/2011
                   -- se sustituye el valor garan.finiefe por v_ftarifa que sera el que
                   -- se inserte en el campo estdetgaranseg.ftarifa
                   vpasexec := 460;

                   INSERT INTO estdetgaranseg
                               (sseguro, cgarant, nriesgo, nmovimi, finiefe, ndetgar,
                                fefecto,
                                fvencim,
                                ndurcob, ctarifa, pinttec, ftarifa,
                                crevali, prevali, irevali,
                                icapital, iprianu,
                                precarg, irecarg, cparben, cprepost, ffincob,
                                ipritar, provmat0, fprovmat0, provmat1, fprovmat1, pintmin,
                                pdtocom, idtocom, ctarman, ipripur, ipriinv,
                                itarrea, cagente)
                        VALUES (vsolicit, garan.cgarant, pnriesgo, vnmovimi, garan.finiefe, 0,
                                garan.finiefe,
                                DECODE(v_fvencim,
                                       NULL, NULL,
                                       0, NULL,
                                       TO_DATE(v_fvencim, 'yyyymmdd')),
                                v_ndurcob * 12, v_ctarifa, v_pinttec, v_ftarifa /*garan.finiefe*/,
                                garan.crevali, garan.prevali, garan.irevali,
                                NVL(vcapital, garan.icapital), garan.primas.iprianu,
                                garan.primas.precarg, garan.primas.irecarg, NULL, NULL, v_ffincob,
                                garan.primas.ipritar, NULL, NULL, NULL, NULL, v_pintmin,
                                garan.primas.pdtocom, garan.primas.idtocom, NULL, NULL, NULL,
                                NULL, v_cagente);
                   -- Fin Bug 18848 - APD - 22/06/2011
                -- Fin Bug 10757
                END IF;
             END IF;

             --Gravem les regles
             vpasexec := 470;
             vnumerr := f_grabarreglasseg(garan.reglasseg, mensajes);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- Bug 21121 - APD - 01/03/2012 - se graba el detalle de primas de la garantia
             vpasexec := 480;
             vnumerr := pac_md_grabardatos.f_grabardetprimas(garan.detprimas, pnriesgo,
                                                             garan.cgarant, garan.finiefe,
                                                             mensajes);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- fin Bug 21121 - APD - 01/03/2012

             -- Bug 27014 - SHA - 26/07/2013 - se crea la funci?n f_grabarprimasgaranseg
             vpasexec := 490;
             vnumerr := pac_md_grabardatos.f_grabarprimasgaranseg(garan.primas, pnriesgo,
                                                                  garan.cgarant, garan.finiefe,
                                                                  mensajes);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;
             --fin Bug 27014 - SHA - 26/07/2013
          --
          END IF;

          vpasexec := 500;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargarantia;

       /*************************************************************************
          Actualitza la data efecte dels riscos
          Nomes es pot cridar quan sigui alta poliza i nmovimi igual a 1
          param in psseguro  : codi seguro
          param in pfefecto  : data efecte
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_actualizafefectoriesgo(
          psseguro IN NUMBER,
          pfefecto IN DATE,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarGarantia';
          vcapital       NUMBER;
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             pk_nueva_produccion.p_modificar_fefecto_seg(psseguro, pfefecto, 1);
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_actualizafefectoriesgo;

       /*************************************************************************
         Grabar informacion de las preguntas de garantias -->>
       *************************************************************************/

       /*************************************************************************
          Grabar informacion de las preguntas de garantias
          param in pregun    : objeto preguntas
          param in pnriesgo  : numero de riesgo
          param in pcgarant  : codigo de garantia
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarpreguntasgarantia(
          pregun IN t_iax_preguntas,
          pnriesgo IN NUMBER,
          pcgarant IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnum           NUMBER;
          nerr           NUMBER;
          vpasexec       NUMBER(8) := 1;
          -- Bug 32015 - JMF - 07/10/2014 Control errores
          vparam         VARCHAR2(500) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarPreguntasGarantia';
          pregtab        t_iax_preguntastab;
          pregtab_col    t_iax_preguntastab_columns;
          --71.0       27/07/2015   AQ                80. 0035375: AGM301-error al calcular la RC en el entorno de Real
          vempresa       NUMBER;
          vsproduc       NUMBER;
       BEGIN
          vpasexec := 100;

          --71.0       27/07/2015   AQ                80. 0035375: AGM301-error al calcular la RC en el entorno de Real
          SELECT sproduc
            INTO vsproduc
            FROM estseguros
           WHERE sseguro = vsolicit;

          IF pregun IS NULL THEN
             --71.0       27/07/2015   AQ                80. 0035375: AGM301-error al calcular la RC en el entorno de Real
             IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'ELI_PREGU_GARANSEG'), 0) = 1 THEN
                DELETE FROM estpregungaranseg
                      WHERE sseguro = vsolicit
                        AND nmovimi = vnmovimi
                        AND nriesgo = pnriesgo
                        AND cgarant = pcgarant;
             END IF;

             RETURN 0;
          END IF;

          IF pregun.COUNT = 0 THEN
             --71.0       27/07/2015   AQ                80. 0035375: AGM301-error al calcular la RC en el entorno de Real
             IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'ELI_PREGU_GARANSEG'), 0) = 1 THEN
                DELETE FROM estpregungaranseg
                      WHERE sseguro = vsolicit
                        AND nmovimi = vnmovimi
                        AND nriesgo = pnriesgo
                        AND cgarant = pcgarant;
             END IF;

             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vpasexec := 110;
             vparam := 's=' || vsolicit || ' m=' || vnmovimi || ' r=' || pnriesgo || ' g='
                       || pcgarant;

             --// ACC afegit q quan gravi primer borri
             DELETE FROM estpregungaranseg
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND nriesgo = pnriesgo
                     AND cgarant = pcgarant;

             vpasexec := 120;

             DELETE FROM estpregungaransegtab
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND nriesgo = pnriesgo
                     AND cgarant = pcgarant;

             -- Taules EST
             -- Recorregut sobre la llista de preguntes
             vpasexec := 130;

             FOR i IN pregun.FIRST .. pregun.LAST LOOP
                vpasexec := 140;

                IF pregun.EXISTS(i) THEN
                   vpasexec := 150;

                   SELECT COUNT(*)
                     INTO vnum
                     FROM estpregungaranseg p
                    WHERE p.sseguro = vsolicit
                      AND p.nmovimi = vnmovimi
                      AND p.nriesgo = pnriesgo
                      AND p.cgarant = pcgarant
                      AND TRUNC(p.finiefe) = pregun(i).finiefe
                      AND p.nmovima = pregun(i).nmovima
                      AND p.cpregun = pregun(i).cpregun;

                   -- BUG9988:DRA:06/05/2009:Inici
                   IF NVL(pregun(i).crespue, -1) <> -1
                      OR NVL(pregun(i).trespue, ' ') <> ' ' THEN
                      IF vnum > 0 THEN
                         vpasexec := 160;

                     --Ja existeix la pregunta => La updategem.
-- Inicio IAXIS-3398 19/07/2019 Marcelo Ozawa                     
--                     UPDATE estpregungaranseg p
--                        SET p.crespue = NVL(pregun(i).crespue, 0),
--                            p.trespue = pregun(i).trespue
--                      WHERE p.sseguro = vsolicit
--                        AND p.nmovimi = vnmovimi
--                        AND p.nriesgo = pnriesgo
--                        AND p.cgarant = pcgarant
--                        AND TRUNC(p.finiefe) = pregun(i).finiefe
--                        AND p.nmovima = pregun(i).nmovima
--                        AND p.cpregun = pregun(i).cpregun;
-- Fin IAXIS-3398 19/07/2019 Marcelo Ozawa
                  ELSE
                     vpasexec := 170;

                         --No existeix la pregunta => La insertem.
                         INSERT INTO estpregungaranseg
                                     (sseguro, nriesgo, cgarant, nmovimi, cpregun,
                                      crespue,
                                      nmovima,
                                      finiefe, trespue)
                              VALUES (vsolicit, pnriesgo, pcgarant, vnmovimi, pregun(i).cpregun,
                                      NVL(pregun(i).crespue, 0),
                                      pregun(i).nmovima /* ACC he tret el 1 JAS*/,
                                      pregun(i).finiefe, pregun(i).trespue);
                      END IF;
                   END IF;
                -- BUG9988:DRA:06/05/2009:Fi
                END IF;

                vpasexec := 180;
                pregtab := pregun(i).tpreguntastab;

                IF pregtab IS NOT NULL THEN
                   --Antes de hacer el traspaso a las subtablas, borramos los registros anteriores para reflejar
                   --las modificaciones y eliminaciones
                   vpasexec := 190;

                   DELETE FROM estsubtabs_seg_det
                         WHERE sseguro = vsolicit
                           AND nriesgo = pnriesgo
                           AND nmovimi = vnmovimi
                           AND cpregun = pregun(i).cpregun
                           AND cgarant = pcgarant;

                   vpasexec := 200;

                   IF pregtab.COUNT <> 0 THEN
                      FOR j IN pregtab.FIRST .. pregtab.LAST LOOP
                         vpasexec := 210;
                         pregtab_col := pregtab(j).tcolumnas;

                         IF pregtab_col IS NOT NULL THEN
                            IF pregtab_col.COUNT <> 0 THEN
                               vpasexec := 220;

                               FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                                  IF pregtab_col.EXISTS(k) THEN
                                     BEGIN
                                        vpasexec := 230;

                                        SELECT COUNT(*)
                                          INTO vnum
                                          FROM estpregungaransegtab
                                         WHERE sseguro = vsolicit
                                           AND nriesgo = pnriesgo
                                           AND nmovimi = vnmovimi
                                           AND cpregun = pregun(i).cpregun
                                           AND nlinea = pregtab(j).nlinea
                                           AND ccolumna = pregtab_col(k).ccolumna
                                           AND cgarant = pcgarant
                                           AND TRUNC(finiefe) = pregun(i).finiefe
                                           AND nmovima = NVL(pregun(i).nmovima, 1);
                                     EXCEPTION
                                        WHEN OTHERS THEN
                                           vnum := 0;
                                     END;

                                     IF vnum > 0 THEN
                                        vpasexec := 240;

                                        UPDATE estpregungaransegtab
                                           SET nvalor = NVL(pregtab_col(k).nvalor, 0),
                                               tvalor = pregtab_col(k).tvalor,
                                               fvalor = pregtab_col(k).fvalor
                                         WHERE sseguro = vsolicit
                                           AND nriesgo = pnriesgo
                                           AND nmovimi = vnmovimi
                                           AND cpregun = pregun(i).cpregun
                                           AND nlinea = pregtab(j).nlinea
                                           AND ccolumna = pregtab_col(k).ccolumna
                                           AND cgarant = pcgarant
                                           AND TRUNC(finiefe) = pregun(i).finiefe
                                           AND nmovima = NVL(pregun(i).nmovima, 1);
                                     ELSE
                                        vpasexec := 250;

                                        INSERT INTO estpregungaransegtab
                                                    (sseguro, nriesgo, cpregun,
                                                     nlinea, nmovimi,
                                                     ccolumna,
                                                     nvalor,
                                                     tvalor,
                                                     fvalor,
                                                     nmovima,
                                                     finiefe, cgarant)
                                             VALUES (vsolicit, pnriesgo, pregun(i).cpregun,
                                                     pregtab(j).nlinea, vnmovimi,
                                                     pregtab_col(k).ccolumna,
                                                     NVL(pregtab_col(k).nvalor, 0),
                                                     pregtab_col(k).tvalor,
                                                     pregtab_col(k).fvalor,
                                                     NVL(pregun(i).nmovima, 1),
                                                     pregun(i).finiefe, pcgarant);
                                     END IF;
                                  END IF;
                               END LOOP;
                            END IF;
                         END IF;

                         vpasexec := 260;
                         nerr := pac_preguntas.f_traspaso_subtabs_seg('EST', vsolicit, vnmovimi,
                                                                      pregun(i).cpregun, 'G',
                                                                      pregtab(j).nlinea, pnriesgo,
                                                                      pcgarant, nerr);
                      END LOOP;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          vpasexec := 270;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarpreguntasgarantia;

       /*************************************************************************
        <<-- Grabar informacion de las preguntas de garantias
       **************************************************************************/

       /*************************************************************************
          Grabar informacion de beneficiarios
          param in benef     : objeto beneficiarios
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarbeneficiarios(
          benef IN ob_iax_beneficiarios,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          num            NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarBeneficiarios';
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --// ACC afegit q quan gravi primer borri
             vpasexec := 10;

             DELETE FROM estclausuesp
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND cclaesp = 1
                     AND nriesgo = pnriesgo;

             vpasexec := 11;

             DELETE FROM estclaubenseg
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND nriesgo = pnriesgo;

             vpasexec := 12;

             DELETE FROM estbenespseg
                   WHERE sseguro = vsolicit
                     AND nmovimi = vnmovimi
                     AND nriesgo = pnriesgo;

             IF benef.ctipo = 1 THEN
                vpasexec := 13;

                IF NVL(benef.tclaesp, ' ') = ' ' THEN
                   RETURN 0;
                END IF;

                vpasexec := 14;

                SELECT COUNT(*)
                  INTO num
                  FROM estclausuesp
                 WHERE sseguro = vsolicit
                   AND nmovimi = vnmovimi
                   AND nordcla = benef.nordcla
                   AND cclaesp = 1   -- ha de ser especial
                   AND nriesgo = pnriesgo;

                IF num > 0 THEN   --existeix, updatejem
                   vpasexec := 15;

                   UPDATE estclausuesp
                      SET tclaesp = benef.tclaesp,
                          finiclau = benef.finiclau,
                          ffinclau = benef.ffinclau
                    WHERE sseguro = vsolicit
                      AND nmovimi = vnmovimi
                      AND nordcla = benef.nordcla
                      AND cclaesp = 1
                      AND nriesgo = pnriesgo;
                ELSE
                   vpasexec := 16;

                   INSERT INTO estclausuesp
                               (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau,
                                tclaesp, ffinclau)
                        VALUES (vnmovimi, vsolicit, 1, benef.nordcla, pnriesgo, benef.finiclau,
                                benef.tclaesp, benef.ffinclau);
                END IF;
             ELSIF benef.ctipo = 2 THEN
                vpasexec := 17;

                IF NVL(benef.sclaben, 0) = 0 THEN
                   RETURN 0;
                END IF;

                vpasexec := 18;

                SELECT COUNT(*)
                  INTO num
                  FROM estclaubenseg
                 WHERE sseguro = vsolicit
                   AND nmovimi = vnmovimi
                   AND nriesgo = pnriesgo
                   AND sclaben = benef.sclaben;

                IF num > 0 THEN   --existeix, updatejem
                   vpasexec := 19;

                   UPDATE estclaubenseg
                      SET finiclau = benef.finiclau,
                          ffinclau = benef.ffinclau
                    WHERE sseguro = vsolicit
                      AND nmovimi = vnmovimi
                      AND nriesgo = pnriesgo
                      AND sclaben = benef.sclaben;
                ELSE
                   vpasexec := 20;

                   INSERT INTO estclaubenseg
                               (nmovimi, sseguro, nriesgo, finiclau, sclaben,
                                ffinclau)
                        VALUES (vnmovimi, vsolicit, pnriesgo, benef.finiclau, benef.sclaben,
                                benef.ffinclau);
                END IF;
             ELSIF benef.ctipo = 3 THEN
                vpasexec := 21;

                IF benef.benefesp.benef_riesgo IS NULL
                   AND benef.benefesp.benefesp_gar IS NULL THEN
                   RETURN 0;
                END IF;

                vpasexec := 22;

                IF benef.benefesp.benef_riesgo IS NOT NULL THEN
                   --Insertamos beneficiarios por riesgo
                   IF benef.benefesp.benef_riesgo.COUNT <> 0 THEN
                      FOR i IN
                         benef.benefesp.benef_riesgo.FIRST .. benef.benefesp.benef_riesgo.LAST LOOP
                         IF benef.benefesp.benef_riesgo.EXISTS(i) THEN
                            SELECT COUNT(*)
                              INTO num
                              FROM estbenespseg
                             WHERE sseguro = vsolicit
                               AND nmovimi = vnmovimi
                               AND nriesgo = pnriesgo
                               AND cgarant = 0
                               AND sperson = benef.benefesp.benef_riesgo(i).sperson
                               AND sperson_tit = NVL(benef.benefesp.benef_riesgo(i).sperson_tit, 0);

                            IF num > 0 THEN   --existeix, updatejem
                               vpasexec := 23;

                               -- Bug 24717 - MDS - 20/12/2012 : A?r campo cestado
                               UPDATE estbenespseg
                                  SET finiben = benef.benefesp.benef_riesgo(i).finiben,
                                      ffinben = benef.benefesp.benef_riesgo(i).ffinben,
                                      ctipben = benef.benefesp.benef_riesgo(i).ctipben,
                                      cparen = benef.benefesp.benef_riesgo(i).cparen,
                                      pparticip = benef.benefesp.benef_riesgo(i).pparticip,
                                      cestado = benef.benefesp.benef_riesgo(i).cestado,
                                      ctipocon = benef.benefesp.benef_riesgo(i).ctipocon
                                WHERE sseguro = vsolicit
                                  AND nmovimi = vnmovimi
                                  AND nriesgo = pnriesgo
                                  AND cgarant = 0
                                  AND sperson = benef.benefesp.benef_riesgo(i).sperson
                                  AND sperson_tit = NVL(benef.benefesp.benef_riesgo(i).sperson_tit,
                                                        0);
                            ELSE
                               vpasexec := 24;

                               -- Bug 24717 - MDS - 20/12/2012 : A?r campo cestado
                               INSERT INTO estbenespseg
                                           (sseguro, nriesgo, cgarant, nmovimi,
                                            sperson,
                                            sperson_tit,
                                            finiben,
                                            ffinben,
                                            ctipben,
                                            cparen,
                                            pparticip,
                                            cestado,
                                            ctipocon)
                                    VALUES (vsolicit, pnriesgo, 0, vnmovimi,
                                            benef.benefesp.benef_riesgo(i).sperson,
                                            NVL(benef.benefesp.benef_riesgo(i).sperson_tit, 0),
                                            benef.benefesp.benef_riesgo(i).finiben,
                                            benef.benefesp.benef_riesgo(i).ffinben,
                                            benef.benefesp.benef_riesgo(i).ctipben,
                                            benef.benefesp.benef_riesgo(i).cparen,
                                            benef.benefesp.benef_riesgo(i).pparticip,
                                            benef.benefesp.benef_riesgo(i).cestado,
                                            benef.benefesp.benef_riesgo(i).ctipocon);
                            END IF;
                         END IF;
                      END LOOP;
                   END IF;
                END IF;

                IF benef.benefesp.benefesp_gar IS NOT NULL THEN
                   --Insertamos beneficiarios por garantia
                   IF benef.benefesp.benefesp_gar.COUNT <> 0 THEN
                      FOR i IN
                         benef.benefesp.benefesp_gar.FIRST .. benef.benefesp.benefesp_gar.LAST LOOP
                         IF benef.benefesp.benefesp_gar(i).benef_ident.COUNT <> 0 THEN
                            FOR gar IN
                               benef.benefesp.benefesp_gar(i).benef_ident.FIRST .. benef.benefesp.benefesp_gar
                                                                                                (i).benef_ident.LAST LOOP
                               IF benef.benefesp.benefesp_gar(i).benef_ident.EXISTS(gar) THEN
                                  SELECT COUNT(*)
                                    INTO num
                                    FROM estbenespseg
                                   WHERE sseguro = vsolicit
                                     AND nmovimi = vnmovimi
                                     AND nriesgo = pnriesgo
                                     AND cgarant = benef.benefesp.benefesp_gar(i).cgarant
                                     AND sperson =
                                            benef.benefesp.benefesp_gar(i).benef_ident(gar).sperson
                                     AND sperson_tit =
                                           NVL
                                              (benef.benefesp.benefesp_gar(i).benef_ident(gar).sperson_tit,
                                               0);

                                  IF num > 0 THEN   --existeix, updatejem
                                     vpasexec := 25;

                                     -- Bug 24717 - MDS - 20/12/2012 : A?r campo cestado
                                     UPDATE estbenespseg
                                        SET finiben =
                                               benef.benefesp.benefesp_gar(i).benef_ident(gar).finiben,
                                            ffinben =
                                               benef.benefesp.benefesp_gar(i).benef_ident(gar).ffinben,
                                            ctipben =
                                               benef.benefesp.benefesp_gar(i).benef_ident(gar).ctipben,
                                            cparen =
                                               benef.benefesp.benefesp_gar(i).benef_ident(gar).cparen,
                                            pparticip =
                                               benef.benefesp.benefesp_gar(i).benef_ident(gar).pparticip,
                                            cestado =
                                               benef.benefesp.benefesp_gar(i).benef_ident(gar).cestado,
                                            ctipocon =
                                               benef.benefesp.benefesp_gar(i).benef_ident(gar).ctipocon
                                      WHERE sseguro = vsolicit
                                        AND nmovimi = vnmovimi
                                        AND nriesgo = pnriesgo
                                        AND cgarant = benef.benefesp.benefesp_gar(i).cgarant
                                        AND sperson =
                                              benef.benefesp.benefesp_gar(i).benef_ident(gar).sperson
                                        AND sperson_tit =
                                              NVL
                                                 (benef.benefesp.benefesp_gar(i).benef_ident(gar).sperson_tit,
                                                  0);
                                  ELSE
                                     vpasexec := 26;

                                     -- Bug 24717 - MDS - 20/12/2012 : A?r campo cestado
                                     INSERT INTO estbenespseg
                                                 (sseguro, nriesgo,
                                                  cgarant,
                                                  nmovimi,
                                                  sperson,
                                                  sperson_tit,
                                                  finiben,
                                                  ffinben,
                                                  ctipben,
                                                  cparen,
                                                  pparticip,
                                                  cestado,
                                                  ctipocon)
                                          VALUES (vsolicit, pnriesgo,
                                                  benef.benefesp.benefesp_gar(i).cgarant,
                                                  vnmovimi,
                                                  benef.benefesp.benefesp_gar(i).benef_ident(gar).sperson,
                                                  NVL
                                                     (benef.benefesp.benefesp_gar(i).benef_ident
                                                                                               (gar).sperson_tit,
                                                      0),
                                                  benef.benefesp.benefesp_gar(i).benef_ident(gar).finiben,
                                                  benef.benefesp.benefesp_gar(i).benef_ident(gar).ffinben,
                                                  benef.benefesp.benefesp_gar(i).benef_ident(gar).ctipben,
                                                  benef.benefesp.benefesp_gar(i).benef_ident(gar).cparen,
                                                  benef.benefesp.benefesp_gar(i).benef_ident(gar).pparticip,
                                                  benef.benefesp.benefesp_gar(i).benef_ident(gar).cestado,
                                                  benef.benefesp.benefesp_gar(i).benef_ident(gar).ctipocon);
                                  END IF;
                               END IF;
                            END LOOP;
                         END IF;
                      END LOOP;
                   END IF;
                END IF;

                vpasexec := 27;
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarbeneficiarios;

       /*************************************************************************
          Grabar informacion de beneficiarios nominales
          param in benef     : objeto beneficiarios nominales
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarbenenominales(
          benef IN ob_iax_benenominales,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarBeneNominales';
       BEGIN
          NULL;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarbenenominales;

       /*************************************************************************
          Grabar informacion detalle de automoviles
          param in autries   : objeto riesgos automoviles
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarriesgoauto(
          autries IN t_iax_autriesgos,
          riesgo IN ob_iax_riesgos,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarRiesgoAuto';
          -- vnmovimi       NUMBER := 1;  -- BUG17255:DRA:25/07/2011
          vfefecto       DATE;
          vtab           VARCHAR2(200);
          ncount         NUMBER := 0;
          cur            sys_refcursor;
          curid          INTEGER;
          dummy          INTEGER;
          squery         LONG;
          nerr           NUMBER;
          v_sproduc      productos.sproduc%TYPE;   -- BUG 0025412 - FAL - 17/01/2013
          conductores    t_iax_autconductores;   -- Bug 0027876/0158962 - JSV - 15/11/2013
       BEGIN
    -- Bug 9247 - APD - 01/04/2009 - Se crea la funcion
          IF riesgo IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000643);
             -- No existen riesgos
             RETURN 1;
          END IF;

          -- Se graba en estriesgos
          vpasexec := 5;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vtab := 'estriesgos';
             --// ACC afegit q quan gravi primer borri
             vpasexec := 6;

             DELETE FROM estriesgos
                   WHERE sseguro = vsolicit
                     AND nriesgo = riesgo.nriesgo;
          END IF;

          OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro =' || vsolicit
                       || ' and nriesgo=' || riesgo.nriesgo;

          FETCH cur
           INTO ncount;

          CLOSE cur;

          IF ncount = 0 THEN
             -- BUG10519:DRA:10/09/2009:Inici
             IF riesgo.fanulac IS NOT NULL THEN
                squery :=
                   'insert into ' || vtab
                   || '(sseguro,nriesgo,nmovima,tnatrie,fefecto,cactivi,fanulac,nmovimb,pdtocom,precarg,pdtotec,preccom,cmodalidad) '
                   || ' values (' || vsolicit || ',' || riesgo.nriesgo || ',' || riesgo.nmovima
                   || ',' || CHR(39) || riesgo.tnatrie || CHR(39) || ',' || CHR(39)
                   || riesgo.fefecto || CHR(39) || ',' || CHR(39) || riesgo.cactivi || CHR(39)
                   || ',' || CHR(39) || riesgo.fanulac || CHR(39) || ',' || CHR(39)
                   || riesgo.nmovimb || CHR(39) || ',' || CHR(39) || riesgo.primas.pdtocom
                   || CHR(39) || ',' || CHR(39) || riesgo.primas.precarg || CHR(39) || ','
                   || CHR(39) || riesgo.primas.pdtotec || CHR(39) || ',' || CHR(39)
                   || riesgo.primas.preccom || CHR(39) || ',' || CHR(39) || riesgo.cmodalidad
                   || CHR(39) || ')';
             --etm 21924
             ELSE
                squery :=
                   'insert into ' || vtab
                   || '(sseguro,nriesgo,nmovima,tnatrie,fefecto,cactivi,pdtocom,precarg,pdtotec,preccom,cmodalidad) '
                   || ' values (' || vsolicit || ',' || riesgo.nriesgo || ',' || riesgo.nmovima
                   || ',' || CHR(39) || riesgo.tnatrie || CHR(39) || ',' || CHR(39)
                   || riesgo.fefecto || CHR(39) || ',' || CHR(39) || riesgo.cactivi || CHR(39)
                   || ',' || CHR(39) || riesgo.primas.pdtocom || CHR(39) || ',' || CHR(39)
                   || riesgo.primas.precarg || CHR(39) || ',' || CHR(39) || riesgo.primas.pdtotec
                   || CHR(39) || ',' || CHR(39) || riesgo.primas.preccom || CHR(39) || ','
                   || CHR(39) || riesgo.cmodalidad || CHR(39) || ')';
             --etm 21924
             END IF;
          ELSE
             squery := 'update ' || vtab || ' set cactivi = ' || CHR(39) || riesgo.cactivi
                       || CHR(39) || ', tnatrie=' || CHR(39) || riesgo.tnatrie || CHR(39)
                       || ', fanulac=' || CHR(39) || NVL(riesgo.fanulac, 'null') || CHR(39)
                       || ', nmovimb=' || CHR(39) || riesgo.nmovimb || CHR(39) || ', pdtocom='
                       || CHR(39) || riesgo.primas.pdtocom || CHR(39) || ', precarg=' || CHR(39)
                       || riesgo.primas.precarg || CHR(39) || ', pdtotec=' || CHR(39)
                       || riesgo.primas.pdtotec || CHR(39) || ', preccom=' || CHR(39)
                       || riesgo.primas.preccom || CHR(39) || ' where sseguro=' || vsolicit
                       || ' and nriesgo=' || riesgo.nriesgo || ' and nmovima=' || riesgo.nmovima
                       || ' and fefecto=' || CHR(39) || riesgo.fefecto || CHR(39)
                       || ' and cmodalidad=' || CHR(39) || riesgo.cmodalidad || CHR(39);
          --etm 21924

          -- BUG10519:DRA:10/09/2009:Fi
          END IF;

          curid := DBMS_SQL.open_cursor;
          DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
          dummy := DBMS_SQL.EXECUTE(curid);
          DBMS_SQL.close_cursor(curid);

          IF dummy = 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001466);
             RETURN 1;
          END IF;

    -------------------------------------------------------------------------------
          IF autries IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001466);
             RETURN 1;
          END IF;

          -- Se graba en estautriesgos
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vtab := 'estautriesgos';
             --// ACC afegit q quan gravi primer borri
             vpasexec := 2;

             DELETE FROM estautriesgos
                   WHERE sseguro = vsolicit
                     AND nriesgo = riesgo.nriesgo
                     AND nmovimi = vnmovimi;

             -- BUG 0025412 - FAL - 17/01/2013
             SELECT sproduc
               INTO v_sproduc
               FROM estseguros
              WHERE sseguro = vsolicit;
          END IF;

          FOR vautries IN autries.FIRST .. autries.LAST LOOP
             vpasexec := 4;

             IF autries.EXISTS(vautries) THEN
                vpasexec := 5;

                OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro =' || vsolicit
                             || ' and nriesgo=' || riesgo.nriesgo || ' and nmovimi=' || vnmovimi;

                FETCH cur
                 INTO ncount;

                CLOSE cur;

                IF ncount = 0 THEN
                   squery :=
                      'insert into ' || vtab
                      || '(sseguro,nriesgo,nmovimi,cversion,ctipmat,cmatric,cuso,csubuso,fmatric,nkilometros,'
                      || ' cvehnue,ivehicu,npma,ntara,ccolor,nbastid,nplazas,cgaraje,cusorem,cremolque,triesgo,'
                      || ' CPAISORIGEN, CMOTOR, CCHASIS,IVEHINUE, NKILOMETRAJE, CCILINDRAJE, CODMOTOR, CPINTURA, CCAJA, '
                      || ' CCAMPERO, CTIPCARROCERIA, CSERVICIO,  CORIGEN, CTRANSPORTE, ANYO,ciaant, ffinciant, cmodalidad, '
                      || ' CPESO, CTRANSMISION, NPUERTAS) '   --BUG 030256/166723 - 20/02/2014 - RCL
                      || ' values (' || CHR(39) || vsolicit || CHR(39) || ',' || CHR(39)
                      || riesgo.nriesgo || CHR(39) || ',' || CHR(39) || vnmovimi || CHR(39) || ','
                      || CHR(39) || autries(vautries).cversion || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ctipmat || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cmatric || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cuso || CHR(39) || ',' || CHR(39)
                      || autries(vautries).csubuso || CHR(39) || ',' || CHR(39)
                      || autries(vautries).fmatric || CHR(39) || ',' || CHR(39)
                      || autries(vautries).nkilometros || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cvehnue || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ivehicu || CHR(39) || ',' || CHR(39)
                      || autries(vautries).npma || CHR(39) || ',' || CHR(39)
                      -- Ini Bug 25202 -- ECP --21/02/2013
                      || autries(vautries).ntara || CHR(39)
                      || ','   --BUG 030256/166723 - 20/02/2014 - RCL
                            --|| NVL(autries(vautries).ntara, autries(vautries).cpeso) || CHR(39) || ','
                      || CHR(39)
                                -- Fin Bug 25202 -- ECP --21/02/2013
                      || autries(vautries).ccolor || CHR(39) || ',' || CHR(39)
                      || autries(vautries).nbastid || CHR(39) || ',' || CHR(39)
                      || autries(vautries).nplazas || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cgaraje || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cusorem || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cremolque || CHR(39) || ',' || CHR(39)
                      || autries(vautries).triesgo || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cpaisorigen || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cmotor || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cchasis || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ivehinue || CHR(39) || ',' || CHR(39)
                      || autries(vautries).nkilometraje || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ccilindraje || CHR(39) || ',' || CHR(39)
                      || autries(vautries).codmotor || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cpintura || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ccaja || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ccampero || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ctipcarroceria || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cservicio || CHR(39) || ',' || CHR(39)
                      || autries(vautries).corigen || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ctransporte || CHR(39) || ',' || CHR(39)
                      || autries(vautries).anyo || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ciaant || CHR(39) || ',' || CHR(39)
                      || autries(vautries).ffinciant || CHR(39) || ',' || CHR(39)
                      --BUG: 0027953/0151258 - JSV 21/08/2013
                      || autries(vautries).cmodalidad || CHR(39) || ',' || CHR(39)
                      || autries(vautries).cpeso || CHR(39) || ','
                      || CHR(39)   --BUG 030256/166723 - 20/02/2014 - RCL
                      || autries(vautries).ctransmision || CHR(39) || ','
                      || CHR(39)   --BUG 030256/166723 - 20/02/2014 - RCL
                      || autries(vautries).npuertas || CHR(39) || ')';   --BUG 030256/166723 - 20/02/2014 - RCL
                ELSE
                   squery := 'update ' || vtab || ' set cversion =' || CHR(39)
                             || autries(vautries).cversion || CHR(39) || ',' || 'ctipmat = '
                             || CHR(39) || autries(vautries).ctipmat || CHR(39) || ','
                             || 'cmatric = ' || CHR(39) || autries(vautries).cmatric || CHR(39)
                             || ',' || 'cuso = ' || CHR(39) || autries(vautries).cuso || CHR(39)
                             || ',' || 'csubuso = ' || CHR(39) || autries(vautries).csubuso
                             || CHR(39) || ',' || 'fmatric = ' || CHR(39)
                             || autries(vautries).fmatric || CHR(39) || ',' || 'nkilometros = '
                             || CHR(39) || autries(vautries).nkilometros || CHR(39) || ','
                             || 'cvehnue = ' || CHR(39) || autries(vautries).cvehnue || CHR(39)
                             || ',' || 'ivehicu = ' || CHR(39) || autries(vautries).ivehicu
                             || CHR(39) || ',' || 'npma = ' || CHR(39) || autries(vautries).npma
                             -- Ini Bug 25202 -- ECP --21/02/2013
                             || CHR(39) || ',' || 'ntara = ' || CHR(39)
                             || autries(vautries).ntara   --BUG 030256/166723 - 20/02/2014 - RCL
                             --|| NVL(autries(vautries).ntara, autries(vautries).cpeso)
                                                                                     -- Fin Bug 25202 -- ECP --21/02/2013
                             || CHR(39) || ',' || 'ccolor = ' || CHR(39)
                             || autries(vautries).ccolor || CHR(39) || ',' || 'nbastid = '
                             || CHR(39) || autries(vautries).nbastid || CHR(39) || ','
                             || 'nplazas = ' || CHR(39) || autries(vautries).nplazas || CHR(39)
                             || ',' || 'cgaraje = ' || CHR(39) || autries(vautries).cgaraje
                             || CHR(39) || ',' || 'cusorem = ' || CHR(39)
                             || autries(vautries).cusorem || CHR(39) || ',' || 'cremolque = '
                             || CHR(39) || autries(vautries).cremolque || CHR(39) || ','
                             || 'triesgo = ' || CHR(39) || autries(vautries).triesgo || CHR(39)
                             || ',' || 'cpaisorigen= ' || CHR(39) || autries(vautries).cpaisorigen
                             || CHR(39) || ',' || 'CCHASIS= ' || CHR(39)
                             || autries(vautries).cchasis || CHR(39) || ',' || 'IVEHINUE= '
                             || CHR(39) || autries(vautries).ivehinue || CHR(39) || ','
                             || 'NKILOMETRAJE= ' || CHR(39) || autries(vautries).nkilometraje
                             || CHR(39) || ',' || 'CCILINDRAJE= ' || CHR(39)
                             || autries(vautries).ccilindraje || CHR(39) || ',' || 'CODMOTOR= '
                             || CHR(39) || autries(vautries).codmotor || CHR(39) || ','
                             || 'CPINTURA= ' || CHR(39) || autries(vautries).cpintura || CHR(39)
                             || ',' || 'CCAJA= ' || CHR(39) || autries(vautries).ccaja || CHR(39)
                             || ',' || 'CCAMPERO= ' || CHR(39) || autries(vautries).ccampero
                             || CHR(39) || ',' || 'CTIPCARROCERIA= ' || CHR(39)
                             || autries(vautries).ctipcarroceria || CHR(39) || ',' || 'cmotor= '
                             || CHR(39) || autries(vautries).cmotor || CHR(39) || ','
                             || 'CSERVICIO= ' || CHR(39) || autries(vautries).cservicio || CHR(39)
                             || ',' || 'CORIGEN= ' || CHR(39) || autries(vautries).corigen
                             || CHR(39) || ',' || 'CTRANSPORTE= ' || CHR(39)
                             || autries(vautries).ctransporte || CHR(39) || ',' || 'ANYO= '
                             || CHR(39) || autries(vautries).anyo || CHR(39) || ',' || 'ciaant= '
                             || CHR(39) || autries(vautries).ciaant || CHR(39) || ','
                             || 'ffinciant= ' || CHR(39) || autries(vautries).ffinciant || CHR(39)
                             || ','
                                   --BUG: 0027953/0151258 - JSV 21/08/2013
                             || 'cmodalidad= ' || CHR(39) || autries(vautries).cmodalidad
                             || CHR(39) || ',' || 'CPESO= ' || CHR(39) || autries(vautries).cpeso
                             || CHR(39)   --BUG 030256/166723 - 20/02/2014 - RCL
                                       || ',' || 'CTRANSMISION= ' || CHR(39)
                             || autries(vautries).ctransmision
                             || CHR(39)   --BUG 030256/166723 - 20/02/2014 - RCL
                                       || ',' || 'NPUERTAS= ' || CHR(39)
                             || autries(vautries).npuertas
                             || CHR(39)   --BUG 030256/166723 - 20/02/2014 - RCL
                             || ' where sseguro=' || vsolicit || ' and nriesgo=' || riesgo.nriesgo
                             || ' and nmovimi=' || vnmovimi;
                END IF;

                vpasexec := 4;
                curid := DBMS_SQL.open_cursor;
                DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
                dummy := DBMS_SQL.EXECUTE(curid);
                DBMS_SQL.close_cursor(curid);

                IF dummy = 0 THEN
                   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001467);
                   RETURN 1;
                END IF;

                IF NVL(pac_mdpar_productos.f_get_parproducto('SIN_CONDUCTOR', v_sproduc), 0) = 0 THEN   -- BUG 0025412 - FAL - 17/01/2013
                   -- Se graba en estautconductores
                   -- Bug 0027876/0158962 - JSV - 15/11/2013
                   nerr := f_grabarconductores(autries(vautries).conductores, riesgo.nriesgo,
                                               mensajes);

                   IF nerr <> 0 THEN
                      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001468);
                      RETURN 1;
                   END IF;

                   -- Se graba en estautdetriesgos
                   nerr := f_grabaraccesoriosauto(autries(vautries).accesorios, riesgo.nriesgo,
                                                  autries(vautries).cversion, mensajes);

                   IF nerr <> 0 THEN
                      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001469);
                      RETURN 1;
                   END IF;

                   -- Se graba en estautdisriesgos
                   nerr := f_grabardispositivosauto(autries(vautries).dispositivos, riesgo.nriesgo,
                                                    autries(vautries).cversion, mensajes);

                   IF nerr <> 0 THEN
                      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001469);
                      RETURN 1;
                   END IF;
                END IF;
             END IF;
          END LOOP;

    -------------------------------------------------------------------------------
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarriesgoauto;

       /*************************************************************************
             Grabar informacion del detalle riesgo automovil -->>
       *************************************************************************/

       /*************************************************************************
          Grabar informacion de los conductores
          param in autries   : objeto riesgos automoviles conductores
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarconductores(
          conduc IN t_iax_autconductores,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          -- Bug 32015 - JMF - 07/10/2014 Control errores
          vparam         VARCHAR2(500) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarConductores';
          vtab           VARCHAR2(200);
          ncount         NUMBER := 0;
          cur            sys_refcursor;
          curid          INTEGER;
          dummy          INTEGER;
          squery         LONG;
       BEGIN
          vpasexec := 100;

    -- Bug 9247 - APD - 01/04/2009 - Se crea la funcion
          IF conduc IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001462);
             RETURN 1;
          END IF;

          -- Se graba en estautconductores
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vtab := 'estautconductores';
             --// ACC afegit q quan gravi primer borri
             vparam := 's=' || vsolicit || ' r=' || pnriesgo || ' m=' || vnmovimi;
             vpasexec := 110;

             DELETE FROM estautconductores
                   WHERE sseguro = vsolicit
                     AND nriesgo = pnriesgo
                     AND nmovimi = vnmovimi;
          END IF;

          vpasexec := 120;

          IF conduc.COUNT > 0 THEN
             FOR vconduc IN conduc.FIRST .. conduc.LAST LOOP
                vpasexec := 130;

                IF conduc.EXISTS(vconduc) THEN
                   vpasexec := 140;
                   vparam := 's=' || vsolicit || ' r=' || pnriesgo || ' m=' || vnmovimi || ' ord='
                             || conduc(vconduc).norden;

                   OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro =' || vsolicit
                                || ' and nriesgo=' || pnriesgo || ' and nmovimi=' || vnmovimi
                                || ' and norden=' || conduc(vconduc).norden;

                   FETCH cur
                    INTO ncount;

                   CLOSE cur;

                   -- Bug 25368/133447 - 08/01/2013 - AMC
                   -- Bug 25368/135191 - 15/01/2013 - AMC
                   IF ncount = 0 THEN
                      vpasexec := 150;
                      squery :=
                         'insert into ' || vtab
                         || '(sseguro,nriesgo,nmovimi,norden,sperson,fnacimi,fcarnet,csexo,npuntos,cdomici,cprincipal,exper_manual,exper_cexper,exper_sinie,exper_sinie_manual) '
                         || ' values (' || CHR(39) || vsolicit || CHR(39) || ',' || CHR(39)
                         || pnriesgo || CHR(39) || ',' || CHR(39) || vnmovimi || CHR(39) || ','
                         || CHR(39) || conduc(vconduc).norden || CHR(39) || ',' || CHR(39)
                         || conduc(vconduc).sperson || CHR(39) || ', to_date (' || CHR(39)
                         || TO_CHAR(conduc(vconduc).fnacimi, 'DD/MM/YYYY') || CHR(39)
                         || ', ''DD/MM/YYYY''), to_date (' || CHR(39)
                         || TO_CHAR(conduc(vconduc).fcarnet, 'DD/MM/YYYY') || CHR(39)
                         || ', ''DD/MM/YYYY''),' || CHR(39) || conduc(vconduc).csexo || CHR(39)
                         || ',' || CHR(39) || conduc(vconduc).npuntos || CHR(39) || ',' || CHR(39)
                         || conduc(vconduc).cdomici || CHR(39) || ',' || CHR(39)
                         || conduc(vconduc).cprincipal || CHR(39) || ',' || CHR(39)
                         || conduc(vconduc).exper_manual || CHR(39) || ',' || CHR(39)
                         || conduc(vconduc).exper_cexper || CHR(39) || ',' || CHR(39)
                         || conduc(vconduc).exper_sinie || CHR(39) || ',' || CHR(39)
                         || conduc(vconduc).exper_sinie_manual || CHR(39) || ')';
                   ELSE
                      vpasexec := 160;
                      squery := 'update ' || vtab || ' set sperson =' || CHR(39)
                                || conduc(vconduc).sperson || CHR(39) || ', fnacimi = to_date ('
                                || CHR(39) || TO_CHAR(conduc(vconduc).fnacimi, 'DD/MM/YYYY')
                                || CHR(39) || ', ''DD/MM/YYYY''),' || 'fcarnet = ' || CHR(39)
                                || TO_CHAR(conduc(vconduc).fcarnet, 'DD/MM/YYYY') || CHR(39)
                                || ', ''DD/MM/YYYY''), csexo = ' || CHR(39)
                                || conduc(vconduc).csexo || CHR(39) || ', npuntos = ' || CHR(39)
                                || conduc(vconduc).npuntos || CHR(39) || ', cdomici = ' || CHR(39)
                                || conduc(vconduc).cdomici || CHR(39) || ', cprincipal = '
                                || CHR(39) || conduc(vconduc).cprincipal || CHR(39)
                                || ', exper_manual = ' || CHR(39) || conduc(vconduc).exper_manual
                                || CHR(39) || ', exper_cexper = ' || CHR(39)
                                || conduc(vconduc).exper_cexper || CHR(39) || ', exper_sinie = '
                                || CHR(39) || conduc(vconduc).exper_sinie || CHR(39)
                                || ', exper_sinie_manual = ' || CHR(39)
                                || conduc(vconduc).exper_sinie_manual || CHR(39)
                                || ' where sseguro=' || vsolicit || ' and nriesgo=' || pnriesgo
                                || ' and nmovimi=' || vnmovimi || ' and norden='
                                || conduc(vconduc).norden;
                   END IF;

                   vpasexec := 170;
                   -- Fi Bug 25368/133447 - 08/01/2013 - AMC
                   -- Fi Bug 25368/135191 - 15/01/2013 - AMC
                   curid := DBMS_SQL.open_cursor;
                   DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
                   dummy := DBMS_SQL.EXECUTE(curid);
                   DBMS_SQL.close_cursor(curid);

                   IF dummy = 0 THEN
                      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001468);
                      -- No se han podido grabar los conductores del riesgo auto
                      RETURN 1;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          vpasexec := 180;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarconductores;

       /*************************************************************************
            Grabar informacion de dispositivos
            param in autacc    : objeto riesgos automoviles accesorios
            param in pnriesgo  : numero de riesgo
            param out mensajes : mesajes de error
            return             : 0 todo ha sido correcto
                                 1 ha habido un error
         *************************************************************************/
       FUNCTION f_grabardispositivosauto(
          autdisp IN t_iax_autdispositivos,
          pnriesgo IN NUMBER,
          pcversion IN VARCHAR2,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_grabardispositivosauto';
          vtab           VARCHAR2(200);
          ncount         NUMBER := 0;
          cur            sys_refcursor;
          curid          INTEGER;
          dummy          INTEGER;
          squery         LONG;
       BEGIN
          IF autdisp IS NOT NULL THEN
             IF autdisp.COUNT > 0 THEN
                -- Se graba en estautdetriesgos
                IF vpmode <> 'EST' THEN
                   RAISE e_param_error;
                ELSE
                   vtab := 'estautdisriesgos';
                   --// ACC afegit q quan gravi primer borri
                   vpasexec := 2;

                   DELETE FROM estautdisriesgos
                         WHERE sseguro = vsolicit
                           AND nriesgo = pnriesgo
                           AND nmovimi = vnmovimi;
                END IF;

                FOR vautdisp IN autdisp.FIRST .. autdisp.LAST LOOP
                   vpasexec := 4;

                   IF autdisp.EXISTS(vautdisp) THEN
                      vpasexec := 5;

                      IF NVL(autdisp(vautdisp).cmarcado, 0) = 1 THEN
                         OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro ='
                                      || vsolicit || ' and nriesgo=' || pnriesgo
                                      || ' and nmovimi=' || vnmovimi || ' and cversion='
                                      || autdisp(vautdisp).cversion || ' and cdispositivo= '
                                      || CHR(39) || autdisp(vautdisp).cdispositivo || CHR(39)
                                      || '';

                         FETCH cur
                          INTO ncount;

                         CLOSE cur;

                         IF ncount = 0 THEN
                            squery :=
                               'insert into ' || vtab
                               || '(sseguro,nriesgo,nmovimi,cversion, cdispositivo, cpropdisp,
                                   ivaldisp, finicontrato, ffincontrato,
                                   ncontrato, tdescdisp) '
                               || ' values (' || CHR(39) || vsolicit || CHR(39) || ',' || CHR(39)
                               || pnriesgo || CHR(39) || ',' || CHR(39) || vnmovimi || CHR(39)
                               || ',' || CHR(39) || pcversion || CHR(39) || ',' || CHR(39)
                               || autdisp(vautdisp).cdispositivo || CHR(39) || ',' || CHR(39)
                               || autdisp(vautdisp).cpropdisp || CHR(39) || ',' || CHR(39)
                               || autdisp(vautdisp).ivaldisp || CHR(39) || ',' || CHR(39)
                               || autdisp(vautdisp).finicontrato || CHR(39) || ',' || CHR(39)
                               || autdisp(vautdisp).ffincontrato || CHR(39) || ',' || CHR(39)
                               || autdisp(vautdisp).ncontrato || CHR(39) || ',' || CHR(39)
                               || autdisp(vautdisp).tdescdisp || CHR(39) || ')';
                         ELSE
                            squery := 'update ' || vtab || ' set cpropdisp =' || CHR(39)
                                      || autdisp(vautdisp).cpropdisp || CHR(39) || ','
                                      || ' finicontrato = ' || CHR(39)
                                      || autdisp(vautdisp).finicontrato || CHR(39) || ','
                                      || ' ffincontrato = ' || CHR(39)
                                      || autdisp(vautdisp).ffincontrato || CHR(39) || ','
                                      || ' tdescdisp = ' || CHR(39) || autdisp(vautdisp).tdescdisp
                                      || CHR(39) || ', ncontrato =' || CHR(39)
                                      || autdisp(vautdisp).ncontrato || CHR(39) || ', ivaldisp ='
                                      || CHR(39) || autdisp(vautdisp).ivaldisp || CHR(39)
                                      || 'where sseguro=' || vsolicit || ' and nriesgo='
                                      || pnriesgo || ' and nmovimi=' || vnmovimi
                                      || ' and cversion=' || autdisp(vautdisp).cversion
                                      || ' and cdispositivo=' || autdisp(vautdisp).cdispositivo;
                         END IF;

                         vpasexec := 4;
                         curid := DBMS_SQL.open_cursor;
                         DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
                         dummy := DBMS_SQL.EXECUTE(curid);
                         DBMS_SQL.close_cursor(curid);

                         IF dummy = 0 THEN
                            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001469);
                            -- No se han podido grabar los accesorios del riesgo auto
                            RETURN 1;
                         END IF;
                      END IF;
                   END IF;
                END LOOP;
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabardispositivosauto;

       /*************************************************************************
          Grabar informacion de accesorios
          param in autacc    : objeto riesgos automoviles accesorios
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabaraccesoriosauto(
          autacc IN t_iax_autaccesorios,
          pnriesgo IN NUMBER,
          pcversion IN VARCHAR2,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarAccesoriosAuto';
          vtab           VARCHAR2(200);
          ncount         NUMBER := 0;
          cur            sys_refcursor;
          curid          INTEGER;
          dummy          INTEGER;
          squery         LONG;
       BEGIN
       -- Bug 9247 - APD - 01/04/2009 - Se crea la funcion
    --       No es necesario hacer esta validacion pues no es obligatorio informar los accesorios de no serie
    --      IF autacc IS NULL THEN
    --         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9999999, 'No existen accesorios asociados al riesgo auto de la poliza');
    --         RETURN 1;
    --      END IF;

          -- Solo se grabaran los datos en estautdetriesgos si la coleccion esta inicializada
          IF autacc IS NOT NULL THEN
             IF autacc.COUNT > 0 THEN
                -- Se graba en estautdetriesgos
                IF vpmode <> 'EST' THEN
                   RAISE e_param_error;
                ELSE
                   vtab := 'estautdetriesgos';
                   --// ACC afegit q quan gravi primer borri
                   vpasexec := 2;

                   DELETE FROM estautdetriesgos
                         WHERE sseguro = vsolicit
                           AND nriesgo = pnriesgo
                           AND nmovimi = vnmovimi;
                END IF;

                FOR vautacc IN autacc.FIRST .. autacc.LAST LOOP
                   vpasexec := 4;

                   IF autacc.EXISTS(vautacc) THEN
                      vpasexec := 5;

                      IF NVL(autacc(vautacc).cmarcado, 0) = 1 THEN
                         OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro ='
                                      || vsolicit || ' and nriesgo=' || pnriesgo
                                      || ' and nmovimi=' || vnmovimi || ' and cversion='
                                      || autacc(vautacc).cversion || ' and caccesorio= '
                                      || CHR(39) || autacc(vautacc).caccesorio || CHR(39) || '';

                         FETCH cur
                          INTO ncount;

                         CLOSE cur;

                         IF ncount = 0 THEN
                            squery :=
                               'insert into ' || vtab
                               || '(sseguro,nriesgo,nmovimi,cversion,caccesorio,ctipacc,fini,ivalacc,tdesacc,casegurable) '
                               || ' values (' || CHR(39) || vsolicit || CHR(39) || ',' || CHR(39)
                               || pnriesgo || CHR(39) || ',' || CHR(39) || vnmovimi || CHR(39)
                               || ',' || CHR(39) || pcversion || CHR(39) || ',' || CHR(39)
                               || autacc(vautacc).caccesorio || CHR(39) || ',' || CHR(39)
                               || autacc(vautacc).ctipacc || CHR(39) || ',' || CHR(39)
                               || autacc(vautacc).fini || CHR(39) || ',' || CHR(39)
                               || autacc(vautacc).ivalacc || CHR(39) || ',' || CHR(39)
                               || autacc(vautacc).tdesacc || CHR(39) || ',' || CHR(39)
                               || autacc(vautacc).casegurable || CHR(39) || ')';
                         ELSE
                            squery := 'update ' || vtab || ' set ctipacc =' || CHR(39)
                                      || autacc(vautacc).ctipacc || CHR(39) || ',' || ' fini = '
                                      || CHR(39) || autacc(vautacc).fini || CHR(39) || ','
                                      || ' ivalacc = ' || CHR(39) || autacc(vautacc).ivalacc
                                      || CHR(39) || ',' || ' tdesacc = ' || CHR(39)
                                      || autacc(vautacc).tdesacc || CHR(39) || ', casegurable ='
                                      || CHR(39) || autacc(vautacc).casegurable || CHR(39)
                                      || 'where sseguro=' || vsolicit || ' and nriesgo='
                                      || pnriesgo || ' and nmovimi=' || vnmovimi
                                      || ' and cversion=' || autacc(vautacc).cversion
                                      || ' and caccesorio=' || autacc(vautacc).caccesorio;
                         END IF;

                         vpasexec := 4;
                         curid := DBMS_SQL.open_cursor;
                         DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
                         dummy := DBMS_SQL.EXECUTE(curid);
                         DBMS_SQL.close_cursor(curid);

                         IF dummy = 0 THEN
                            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001469);
                            -- No se han podido grabar los accesorios del riesgo auto
                            RETURN 1;
                         END IF;
                      END IF;
                   END IF;
                END LOOP;
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabaraccesoriosauto;

       /*************************************************************************
                  <<-- Grabar informacion del detalle riesgo automovil
       **************************************************************************/

       /*************************************************************************
        <<-- Grabar informacion del riesgo
    *************************************************************************/

       --JRH 03/2008
        /*************************************************************************
          Grabar tabla de intereses tecnicos
          param in   poliza: Objeto poliza
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabar_inttec(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabar_inttec';
          num_err        NUMBER;
          vinteres       NUMBER;
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          END IF;

          IF poliza IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 111360);
             RETURN 1;
          END IF;

    -- Bug 14285 - 26/04/2010 - JRH - 0014285: CEM303 - Informar fecha de primer pago de renta en la contratacion e interes
          IF poliza.gestion.inttec IS NULL THEN
             vinteres := NULL;
          ELSE
             vinteres := poliza.gestion.inttec;
          END IF;

    -- Fi Bug 14285 - 26/04/2010 - JRH
          -- Bug 13549 - JRH - 09/03/2010 - JRH - Esto solo se puede llamar desde la Nueva Produccion (o el supl. de cambio de interes que se hara en un fututo)
          IF NVL(vnmovimi, 1) = 1 THEN
             num_err := pac_prod_comu.f_grabar_inttec(poliza.sproduc, vsolicit,
                                                      poliza.gestion.fefecto, NVL(vnmovimi, 1),
                                                      vinteres);

             IF num_err <> 0 THEN
                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107403);
                RETURN 1;
             END IF;
          END IF;

          -- Fi Bug 13549 - JRH - 09/03/2010
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabar_inttec;

       --JRH 03/2008
           /*************************************************************************
             Grabar tabla penalizaciones
             param out mensajes : mesajes de error
             param in   poliza: Objeto poliza
             return             : 0 todo ha sido correcto
                                  1 ha habido un error
          *************************************************************************/
       FUNCTION f_grabar_penalizacion(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabar_penalizacion';
          num_err        NUMBER;
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          END IF;

          IF poliza IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 111360);
             RETURN 1;
          END IF;

          -- Bug 13549 - JRH - 09/03/2010 - JRH - Esto solo se puede llamar desde la Nueva Produccion (o el supl. de cambio de interes que se hara en un fututo)
          num_err := pac_prod_comu.f_grabar_penalizacion(1, poliza.sproduc, vsolicit,
                                                         poliza.gestion.fefecto, NVL(vnmovimi, 1));

          IF num_err <> 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 109096);
             RETURN 1;
          END IF;

          -- Fi Bug 13549 - JRH - 09/03/2010
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabar_penalizacion;

       --JRH 03/2008
        /*************************************************************************
          Grabar tabla EST rentas irregulares
          param in   pNRiesgo: Riesgo
          param in   rentaIrr: Objeto rentas irregulares
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabar_rentasirreg(
          pnriesgo IN NUMBER,
          rentairr IN t_iax_rentairr,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabar_rentasirreg';
          num_err        NUMBER;
          ii             NUMBER := 0;
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          END IF;

          --Borramos datos si existen
          DELETE FROM estplanrentasirreg
                WHERE sseguro = vsolicit
                  AND nriesgo = pnriesgo
                  AND nmovimi = NVL(vnmovimi, 1);

          IF rentairr IS NULL THEN
             RETURN 0;
          ELSE
             IF rentairr.COUNT = 0 THEN
                RETURN 0;
             END IF;
          END IF;

          FOR vprg IN rentairr.FIRST .. rentairr.LAST LOOP
             ii := ii + 1;
             vpasexec := 5 || ii;

             IF rentairr.EXISTS(vprg) THEN
                IF rentairr(vprg).mes1 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 1, rentairr(vprg).anyo,
                                rentairr(vprg).mes1);
                END IF;

                IF rentairr(vprg).mes2 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 2, rentairr(vprg).anyo,
                                rentairr(vprg).mes2);
                END IF;

                IF rentairr(vprg).mes3 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 3, rentairr(vprg).anyo,
                                rentairr(vprg).mes3);
                END IF;

                IF rentairr(vprg).mes4 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 4, rentairr(vprg).anyo,
                                rentairr(vprg).mes4);
                END IF;

                IF rentairr(vprg).mes5 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 5, rentairr(vprg).anyo,
                                rentairr(vprg).mes5);
                END IF;

                IF rentairr(vprg).mes6 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 6, rentairr(vprg).anyo,
                                rentairr(vprg).mes6);
                END IF;

                IF rentairr(vprg).mes7 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 7, rentairr(vprg).anyo,
                                rentairr(vprg).mes7);
                END IF;

                IF rentairr(vprg).mes8 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 8, rentairr(vprg).anyo,
                                rentairr(vprg).mes8);
                END IF;

                IF rentairr(vprg).mes9 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 9, rentairr(vprg).anyo,
                                rentairr(vprg).mes9);
                END IF;

                IF rentairr(vprg).mes10 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 10, rentairr(vprg).anyo,
                                rentairr(vprg).mes10);
                END IF;

                IF rentairr(vprg).mes11 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 11, rentairr(vprg).anyo,
                                rentairr(vprg).mes11);
                END IF;

                IF rentairr(vprg).mes12 IS NOT NULL THEN
                   INSERT INTO estplanrentasirreg
                               (sseguro, nriesgo, nmovimi, mes, anyo,
                                importe)
                        VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 12, rentairr(vprg).anyo,
                                rentairr(vprg).mes12);
                END IF;
             END IF;
          END LOOP;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabar_rentasirreg;

       /*************************************************************************
          Grabar riesgo direccion de la poliza
          param in sitriesgo  : objeto sitriesgos
          param in riesgo    : objeto de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarriesgodireccion(
          sitriesgo IN ob_iax_sitriesgos,
          riesgo IN ob_iax_riesgos,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vtab           VARCHAR2(200);
          ncount         NUMBER := 0;
          cur            sys_refcursor;
          curid          INTEGER;
          dummy          INTEGER;
          squery         LONG;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarRiesgoDireccion';
          -- vnmovimi       NUMBER := 1;  -- BUG17255:DRA:25/07/2011
          vfefecto       DATE;
          domicilio      VARCHAR2(300);
       BEGIN
          IF sitriesgo IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000650);
             RETURN 1;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vtab := 'estsitriesgo';
             --// ACC afegit q quan gravi primer borri
             vpasexec := 2;

             DELETE FROM estsitriesgo
                   WHERE sseguro = vsolicit
                     AND nriesgo = riesgo.nriesgo;
          END IF;

          vpasexec := 3;

          -- Bug 12668 - 17/02/2010 - AMC
          BEGIN
             INSERT INTO estsitriesgo
                         (sseguro, nriesgo, tdomici,
                          cprovin, cpostal,
                          cpoblac, csiglas,
                          tnomvia, nnumvia,
                          tcomple, cciudad,
                          fgisx, fgisy,
                          fgisz, cvalida,
                          cviavp, clitvp, cbisvp, corvp, nviaadco,
                             clitco, corco, nplacaco, cor2co, cdet1ia,
                             tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia,
                             iddomici, localidad, fdefecto, descripcion)
                  VALUES (vsolicit, riesgo.nriesgo,   --riesgo.tnatrie,
                                                   riesgo.riesdireccion.tdomici,
                          riesgo.riesdireccion.cprovin, riesgo.riesdireccion.cpostal,
                          riesgo.riesdireccion.cpoblac, riesgo.riesdireccion.csiglas,
                          riesgo.riesdireccion.tnomvia, riesgo.riesdireccion.nnumvia,
                          riesgo.riesdireccion.tcomple, riesgo.riesdireccion.cciudad,
                          riesgo.riesdireccion.fgisx, riesgo.riesdireccion.fgisy,
                          riesgo.riesdireccion.fgisz, riesgo.riesdireccion.cvalida,
                          riesgo.riesdireccion.cviavp, riesgo.riesdireccion.clitvp,
                          riesgo.riesdireccion.cbisvp, riesgo.riesdireccion.corvp,
                          riesgo.riesdireccion.nviaadco, riesgo.riesdireccion.clitco,
                          riesgo.riesdireccion.corco, riesgo.riesdireccion.nplacaco,
                          riesgo.riesdireccion.cor2co, riesgo.riesdireccion.cdet1ia,
                          riesgo.riesdireccion.tnum1ia, riesgo.riesdireccion.cdet2ia,
                          riesgo.riesdireccion.tnum2ia, riesgo.riesdireccion.cdet3ia,
                          riesgo.riesdireccion.tnum3ia, riesgo.riesdireccion.iddomici,
                          riesgo.riesdireccion.localidad, riesgo.riesdireccion.fdefecto,
                          riesgo.riesdireccion.descripcion);
          EXCEPTION
             WHEN DUP_VAL_ON_INDEX THEN
                UPDATE estsitriesgo
                   SET   --tdomici = riesgo.tnatrie,
                      tdomici = riesgo.riesdireccion.tdomici,
                      cprovin = riesgo.riesdireccion.cprovin,
                      cpostal = riesgo.riesdireccion.cpostal,
                      cpoblac = riesgo.riesdireccion.cpoblac,
                      csiglas = riesgo.riesdireccion.csiglas,
                      tnomvia = riesgo.riesdireccion.tnomvia,
                      nnumvia = riesgo.riesdireccion.nnumvia,
                      tcomple = riesgo.riesdireccion.tcomple,
                      cciudad = riesgo.riesdireccion.cciudad,
                      fgisx = riesgo.riesdireccion.fgisx,
                      fgisy = riesgo.riesdireccion.fgisx,
                      fgisz = riesgo.riesdireccion.fgisz,
                      cvalida = riesgo.riesdireccion.cvalida,
                      cviavp = riesgo.riesdireccion.cviavp,
                      clitvp = riesgo.riesdireccion.clitvp,
                      cbisvp = riesgo.riesdireccion.cbisvp,
                      corvp  = riesgo.riesdireccion.corvp,
                      nviaadco = riesgo.riesdireccion.nviaadco,
                      clitco  = riesgo.riesdireccion.clitco,
                      corco  = riesgo.riesdireccion.corco,
                      nplacaco = riesgo.riesdireccion.nplacaco,
                      cor2co = riesgo.riesdireccion.cor2co,
                      cdet1ia = riesgo.riesdireccion.cdet1ia,
                      tnum1ia = riesgo.riesdireccion.tnum1ia,
                      cdet2ia = riesgo.riesdireccion.cdet2ia,
                      tnum2ia = riesgo.riesdireccion.tnum2ia,
                      cdet3ia = riesgo.riesdireccion.cdet3ia,
                      tnum3ia = riesgo.riesdireccion.tnum3ia,
                      iddomici = riesgo.riesdireccion.iddomici,
                      localidad = riesgo.riesdireccion.localidad,
                      fdefecto = riesgo.riesdireccion.fdefecto,
                      descripcion = riesgo.riesdireccion.descripcion
                 WHERE sseguro = vsolicit
                   AND nriesgo = riesgo.nriesgo;
             WHEN OTHERS THEN
                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000649);
                RETURN 1;
          END;

          -- Fi Bug 12668 - 17/02/2010 - AMC

          -- Bug 20893/111636 - 02/05/2012 - AMC
          IF riesgo.riesdireccion.domicilios IS NOT NULL
             AND riesgo.riesdireccion.domicilios.COUNT > 0 THEN
             FOR i IN
                riesgo.riesdireccion.domicilios.FIRST .. riesgo.riesdireccion.domicilios.LAST LOOP
                BEGIN
                   INSERT INTO estdir_riesgos
                               (sseguro, nriesgo,
                                iddomici)
                        VALUES (vsolicit, riesgo.nriesgo,
                                riesgo.riesdireccion.domicilios(i).iddomici);
                EXCEPTION
                   WHEN DUP_VAL_ON_INDEX THEN
                      NULL;
                END;
             END LOOP;
          END IF;

          -- Fi Bug 20893/111636 - 02/05/2012 - AMC

          /*OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro =' || vsolicit
                       || ' and nriesgo=' || riesgo.nriesgo;

          FETCH cur
           INTO ncount;

          CLOSE cur;

          -- Bug 12668 - 17/02/2010 - AMC
          IF ncount = 0 THEN
             squery := 'insert into ' || vtab
                       || '(sseguro,nriesgo,tdomici,cprovin,cpostal,cpoblac,csiglas,tnomvia,nnumvia,'
                       ||'tcomple,cciudad,fgisx,fgisy,fgisz,cvalida) ' || ' values ('
                       || vsolicit || ',' || riesgo.nriesgo || ',' || CHR(39) || riesgo.tnatrie
                       || CHR(39) || ',' || riesgo.riesdireccion.cprovin || ',' || CHR(39)
                       || riesgo.riesdireccion.cpostal || CHR(39) || ','
                       || riesgo.riesdireccion.cpoblac ||','||riesgo.riesdireccion.csiglas||','||CHR(39)
                       || riesgo.riesdireccion.tnomvia || CHR(39)||','||riesgo.riesdireccion.nnumvia||','||CHR(39)
                       || riesgo.riesdireccion.tcomple ||CHR(39)||','||nvl(riesgo.riesdireccion.cciudad,0)||','
                       || riesgo.riesdireccion.fgisx ||','||riesgo.riesdireccion.fgisy||','
                       || riesgo.riesdireccion.fgisz ||','||riesgo.riesdireccion.cvalida||')';
          ELSE
             squery := 'update ' || vtab || ' set tdomici=' || CHR(39) || riesgo.tnatrie
                       || CHR(39) || ', cprovin=' || riesgo.riesdireccion.cprovin || ', cpostal='
                       || CHR(39) || riesgo.riesdireccion.cpostal || CHR(39) || ', cprovin='
                       || riesgo.riesdireccion.cpoblac ||',csiglas='||riesgo.riesdireccion.csiglas
                       || ',tnomvia='|| CHR(39) ||riesgo.riesdireccion.tnomvia||CHR(39)||',nnumvia='
                       || riesgo.riesdireccion.nnumvia || ',tcomple='||CHR(39)||riesgo.riesdireccion.tcomple ||CHR(39)
                       || ',cciudad='||riesgo.riesdireccion.cciudad||',fgisx='||riesgo.riesdireccion.fgisx
                       || ',fgisy='||riesgo.riesdireccion.fgisx||',fgisz='||riesgo.riesdireccion.fgisz
                       || ',cvalida='||riesgo.riesdireccion.cvalida
                       || ' where sseguro=' || vsolicit || ' and '
                       || ' nriesgo=' || riesgo.nriesgo;
          END IF;
          -- Fi Bug 12668 - 17/02/2010 - AMC
          vpasexec := 4;
          curid := DBMS_SQL.open_cursor;
          DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
          dummy := DBMS_SQL.EXECUTE(curid);
          DBMS_SQL.close_cursor(curid);

          IF dummy = 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000649);
             RETURN 1;
          END IF;*/

          --JRB.- Lo guardo en estriesgos tambien. PROVISIONAL
          vpasexec := 5;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vtab := 'estriesgos';
             --// ACC afegit q quan gravi primer borri
             vpasexec := 6;

             DELETE FROM estriesgos
                   WHERE sseguro = vsolicit
                     AND nriesgo = riesgo.nriesgo;
          END IF;

          OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro =' || vsolicit
                       || ' and nriesgo=' || riesgo.nriesgo;

          FETCH cur
           INTO ncount;

          CLOSE cur;

          SELECT fefecto
            INTO vfefecto
            FROM estseguros
           WHERE sseguro = vsolicit;

          -- Bug 16704 - 18/11/2010 - AMC
          domicilio := REPLACE(riesgo.tnatrie, CHR(39), CHR(146));

          IF ncount = 0 THEN
             --MCC- 02/04/2009 - BUG 0009593: Nuevo campo cactivi
             -- BUG10519:DRA:10/09/2009:Inici
             IF riesgo.fanulac IS NOT NULL THEN
                squery :=
                   'insert into ' || vtab
                   || '(sseguro,nriesgo,nmovima,tnatrie,fefecto,cactivi,fanulac,nmovimb,PDTOCOM, PRECARG, PDTOTEC, PRECCOM) '
                   --etm
                   --Bug 24657- XVM - 11/01/2013
                   --|| ' values (' || vsolicit || ',' || riesgo.nriesgo || ',' || vnmovimi || ','
                   || ' values (' || vsolicit || ',' || riesgo.nriesgo || ','
                   || NVL(riesgo.nmovima, vnmovimi) || ',' || CHR(39) || domicilio || CHR(39)
                   || ',' || CHR(39) || NVL(vfefecto, f_sysdate) || CHR(39) || ',' || CHR(39)
                   || riesgo.cactivi || CHR(39) || ',' || CHR(39) || riesgo.fanulac || CHR(39)
                   || ',' || CHR(39) || riesgo.nmovimb || CHR(39) || ',' || CHR(39)
                   || riesgo.primas.pdtocom || CHR(39) || ',' || CHR(39) || riesgo.primas.precarg
                   || CHR(39) || ',' || CHR(39) || riesgo.primas.pdtotec || CHR(39) || ','
                   || CHR(39) || riesgo.primas.preccom || CHR(39) || ')';
             --etm 21924
             ELSE
                squery :=
                   'insert into ' || vtab
                   || '(sseguro,nriesgo,nmovima,tnatrie,fefecto,cactivi,PDTOCOM, PRECARG, PDTOTEC, PRECCOM) '
                   --Bug 24657- XVM - 11/01/2013
                   --|| ' values (' || vsolicit || ',' || riesgo.nriesgo || ',' || vnmovimi || ','
                   || ' values (' || vsolicit || ',' || riesgo.nriesgo || ','
                   || NVL(riesgo.nmovima, vnmovimi) || ',' || CHR(39) || domicilio || CHR(39)
                   || ',' || CHR(39) || NVL(vfefecto, f_sysdate) || CHR(39) || ',' || CHR(39)
                   || riesgo.cactivi || CHR(39) || ',' || CHR(39) || riesgo.primas.pdtocom
                   || CHR(39) || ',' || CHR(39) || riesgo.primas.precarg || CHR(39) || ','
                   || CHR(39) || riesgo.primas.pdtotec || CHR(39) || ',' || CHR(39)
                   || riesgo.primas.preccom || CHR(39) || ')';
             --etm 21924
             END IF;
          ELSE
             --MCC- 02/04/2009 - BUG 0009593: Nuevo campo cactivi
             squery := 'update ' || vtab || ' set tnatrie=' || CHR(39) || domicilio || CHR(39)
                       || ', cactivi=' || CHR(39) || riesgo.cactivi || CHR(39) || ', fanulac='
                       || CHR(39) || NVL(riesgo.fanulac, 'null') || CHR(39) || ', nmovimb='
                       || CHR(39) || riesgo.nmovimb || CHR(39) || ', pdtocom=' || CHR(39)
                       || riesgo.primas.pdtocom || CHR(39) || ', precarg=' || CHR(39)
                       || riesgo.primas.precarg || CHR(39) || ', pdtotec=' || CHR(39)
                       || riesgo.primas.pdtotec || CHR(39) || ', preccom=' || CHR(39)
                       || riesgo.primas.preccom || CHR(39) || ' where sseguro=' || vsolicit
                       || ' and nriesgo=' || riesgo.nriesgo || ' and nmovima=' || vnmovimi
                       || ' and fefecto=' || CHR(39) || NVL(vfefecto, f_sysdate) || CHR(39);
          -- BUG10519:DRA:10/09/2009:Fi
          END IF;

          --Fi Bug 16704 - 18/11/2010 - AMC
          curid := DBMS_SQL.open_cursor;
          DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
          dummy := DBMS_SQL.EXECUTE(curid);
          DBMS_SQL.close_cursor(curid);
          --JRB.- FIN prueba.
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
       END f_grabarriesgodireccion;

           /*************************************************************************
          Grabar riesgo descripcion de la poliza
          param in sitriesgo  : objeto sitriesgos
          param in riesgo    : objeto de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarriesgodescripcion(
          descripcion IN ob_iax_descripcion,
          riesgo IN ob_iax_riesgos,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vtab           VARCHAR2(200);
          ncount         NUMBER := 0;
          cur            sys_refcursor;
          curid          INTEGER;
          dummy          INTEGER;
          squery         LONG;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarRiesgoDescripcion';
          vfefecto       DATE;
          v_riesgo       VARCHAR2(300);
          v_nerror       NUMBER;
       BEGIN
          IF descripcion IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000648);
             RETURN 1;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vtab := 'estriesgos';
             --// ACC afegit q quan gravi primer borri
             vpasexec := 2;

             DELETE FROM estriesgos
                   WHERE sseguro = vsolicit
                     AND nriesgo = riesgo.nriesgo
                     AND nmovima = riesgo.nmovima;
          END IF;

          vpasexec := 3;

          OPEN cur FOR 'select count(*) from ' || vtab || ' where sseguro =' || vsolicit
                       || ' and nriesgo=' || riesgo.nriesgo || ' and nmovima=' || riesgo.nmovima;

          FETCH cur
           INTO ncount;

          CLOSE cur;

          -- ini bug 29582#c164832  --JDS 04/02/2014
          --SELECT fefecto
            --INTO vfefecto
            --FROM estseguros
           --WHERE sseguro = vsolicit;
          -- fin bug 29582#c164832  --JDS 04/02/2014

          --BUG9369-03062009-XVM-- S'afegeix un replace per solucionar el problema dels apostrofs
          IF ncount = 0 THEN
             -- BUG10519:DRA:10/09/2009:Inici
             IF riesgo.fanulac IS NOT NULL THEN
                squery :=
                   'insert into ' || vtab
                   || '(sseguro,nriesgo,nmovima,tnatrie,nasegur,nedacol,csexcol,fefecto,cactivi,fanulac,nmovimb,pdtocom,precarg,pdtotec,preccom) '
                   || ' values (' || vsolicit || ',' || riesgo.nriesgo || ',' || riesgo.nmovima
                   || ',' || CHR(39) || REPLACE(riesgo.tnatrie, CHR(39), CHR(39) || CHR(39))
                   || CHR(39) || ',' || CHR(39) || riesgo.riesdescripcion.nasegur || CHR(39)
                   || ',' || CHR(39) || riesgo.riesdescripcion.nedacol || CHR(39) || ','
                   || CHR(39) || riesgo.riesdescripcion.csexcol || CHR(39) || ',' || CHR(39)
                   || NVL(riesgo.fefecto, vfefecto) || CHR(39) || ', ' || CHR(39)
                   || riesgo.cactivi || CHR(39) || ',' || CHR(39) || riesgo.fanulac || CHR(39)
                   || ',' || CHR(39) || riesgo.nmovimb || CHR(39) || ',' || CHR(39)
                   || riesgo.primas.pdtocom || CHR(39) || ',' || CHR(39) || riesgo.primas.precarg
                   || CHR(39) || ',' || CHR(39) || riesgo.primas.pdtotec || CHR(39) || ','
                   || CHR(39) || riesgo.primas.preccom || CHR(39) || ')';
             --etm 21924
             ELSE
                squery :=
                   'insert into ' || vtab
                   || '(sseguro,nriesgo,nmovima,tnatrie,nasegur,nedacol,csexcol,fefecto,cactivi,pdtocom,precarg,pdtotec,preccom) '
                   || ' values (' || vsolicit || ',' || riesgo.nriesgo || ',' || riesgo.nmovima
                   || ',' || CHR(39) || REPLACE(riesgo.tnatrie, CHR(39), CHR(39) || CHR(39))
                   || CHR(39) || ',' || CHR(39) || riesgo.riesdescripcion.nasegur || CHR(39)
                   || ',' || CHR(39) || riesgo.riesdescripcion.nedacol || CHR(39) || ','
                   || CHR(39) || riesgo.riesdescripcion.csexcol || CHR(39) || ',' || CHR(39)
                   || NVL(riesgo.fefecto, vfefecto) || CHR(39) || ', ' || CHR(39)
                   || riesgo.cactivi || CHR(39) || ',' || CHR(39) || riesgo.primas.pdtocom
                   || CHR(39) || ',' || CHR(39) || riesgo.primas.precarg || CHR(39) || ','
                   || CHR(39) || riesgo.primas.pdtotec || CHR(39) || ',' || CHR(39)
                   || riesgo.primas.preccom || CHR(39) || ')';
             --etm 21924
             END IF;
          ELSE
             squery := 'update ' || vtab || ' set cactivi = ' || CHR(39) || riesgo.cactivi
                       || CHR(39) || ',' || ' tnatrie=' || CHR(39)
                       || REPLACE(riesgo.tnatrie, CHR(39), CHR(39) || CHR(39)) || CHR(39)
                       || ', nasegur=' || CHR(39) || riesgo.riesdescripcion.nasegur || CHR(39)
                       || ', nedacol=' || CHR(39) || riesgo.riesdescripcion.nedacol || CHR(39)
                       || ', csexcol=' || CHR(39) || riesgo.riesdescripcion.csexcol || CHR(39)
                       || ', fanulac=' || CHR(39) || NVL(riesgo.fanulac, 'null') || CHR(39)
                       || ', nmovimb=' || CHR(39) || riesgo.nmovimb || CHR(39) || ', pdtocom='
                       || CHR(39) || riesgo.primas.pdtocom || CHR(39) || ', precarg=' || CHR(39)
                       || riesgo.primas.precarg || CHR(39) || ', pdtotec=' || CHR(39)
                       || riesgo.primas.pdtotec || CHR(39) || ', preccom=' || CHR(39)
                       || riesgo.primas.preccom || CHR(39) || ' where sseguro=' || vsolicit
                       || ' and nriesgo=' || riesgo.nriesgo || ' and nmovima=' || riesgo.nmovima
                       || ' and fefecto=' || CHR(39) || NVL(riesgo.fefecto, vfefecto) || CHR(39);
                       --etm 21924
          -- BUG10519:DRA:10/09/2009:Inici
          END IF;

          vpasexec := 4;
          curid := DBMS_SQL.open_cursor;
          DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
          dummy := DBMS_SQL.EXECUTE(curid);
          DBMS_SQL.close_cursor(curid);

          IF dummy = 0 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000647);
             RETURN 1;
          END IF;
          -- INI BUG CONF-114 - 21/09/2016 - JAEG
          UPDATE estriesgos
             SET tdescrie = riesgo.tdescrie
           WHERE sseguro = vsolicit
             AND nriesgo = riesgo.nriesgo
             AND nmovima = riesgo.nmovima
             AND fefecto = NVL(riesgo.fefecto, vfefecto);
          -- FIN BUG CONF-114 - 21/09/2016 - JAEG
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);

             IF DBMS_SQL.is_open(curid) THEN
                DBMS_SQL.close_cursor(curid);
             END IF;

             RETURN 1;
       END f_grabarriesgodescripcion;

       /*************************************************************************
          Grabar los meses que tienen paga extra
          param in psseguro  : numero de seguro
          param in pmesesextra  : objeto con los meses con paga extra
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarmesextra(
          psseguro IN NUMBER,
          pmesesextra IN ob_iax_nmesextra,
          mensajes OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 0;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabarmesextra';
          vmesesextra    VARCHAR2(30);
          num_err        NUMBER;
       BEGIN
          vpasexec := 10;

          --p_control_error('PAC_MD_GRABARDATOS','f_grabarmesextra','1.------psseguro:'||psseguro);

          --
          IF psseguro IS NULL
                             --OR pmesesextra IS NULL
          THEN
             RAISE e_param_error;
          END IF;

          vpasexec := 20;
          vmesesextra := pk_rentas.f_llenarnmesesextra(pmesesextra.nmes1, pmesesextra.nmes2,
                                                       pmesesextra.nmes3, pmesesextra.nmes4,
                                                       pmesesextra.nmes5, pmesesextra.nmes6,
                                                       pmesesextra.nmes7, pmesesextra.nmes8,
                                                       pmesesextra.nmes9, pmesesextra.nmes10,
                                                       pmesesextra.nmes11, pmesesextra.nmes12);
          vpasexec := 30;
          num_err := pac_prod_rentas.f_set_nmesextra(psseguro, vmesesextra);
          vpasexec := 40;

          IF num_err <> 0 THEN
             vpasexec := 50;
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
             RETURN 1;
          END IF;

          vpasexec := 60;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarmesextra;

       -- NMM.24735.03/2013.i
       /*************************************************************************
          Grava els imports dels mesos que tenen paga extra
          param in psseguro      : num. d seguro
          param in pimesosextra  : objeto con los meses con paga extra
          param out mensajes     : missatges d'error
          return                 : 0 Tot Ok
                                   1 Error
       *************************************************************************/
       FUNCTION f_gravaimesextra(
          psseguro IN NUMBER,
          pimesesextra IN ob_iax_nmesextra,
          mensajes OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 0;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_gravaimesextra';
          vimesesextra   VARCHAR2(300);
          num_err        NUMBER;
       BEGIN
          vpasexec := 10;

          IF psseguro IS NULL
                             --OR pimesesextra IS NULL
          THEN
             vpasexec := 20;
             RAISE e_param_error;
          END IF;

          vpasexec := 30;
          -- Aquesta funci?s retorna un string amb els imports dels mesos que tenen paga extra del tipus:
          -- 254.3||||||541.2|5214.122|6587.132|45.2|215.3|4654.122|
          vimesesextra := pk_rentas.f_ompleimesosextra(pimesesextra.imp_nmes1,
                                                       pimesesextra.imp_nmes2,
                                                       pimesesextra.imp_nmes3,
                                                       pimesesextra.imp_nmes4,
                                                       pimesesextra.imp_nmes5,
                                                       pimesesextra.imp_nmes6,
                                                       pimesesextra.imp_nmes7,
                                                       pimesesextra.imp_nmes8,
                                                       pimesesextra.imp_nmes9,
                                                       pimesesextra.imp_nmes10,
                                                       pimesesextra.imp_nmes11,
                                                       pimesesextra.imp_nmes12);
          vpasexec := 40;
          -- Grava l'string a la taula
          num_err := pac_prod_rentas.f_set_imesextra(psseguro, vimesesextra);

          IF num_err <> 0 THEN
             vpasexec := 50;
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
             RETURN(1);
          END IF;

          vpasexec := 60;
          RETURN(0);
       --
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN(1);
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN(1);
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN(1);
       END f_gravaimesextra;

       -- NMM.24735.03/2013.f
       /*************************************************************************
          Grabar la distribucion (perfil de inversion) de la poliza
          param in distribucion  : objeto ob_iax_produlkmodelosinv
          param in pfefecto  : Date con el efecto de la poliza
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       -- Bug 9031 - 11/03/2009 - RSC - Axis: Analisis adaptacion productos indexados
       FUNCTION f_grabardistribucion(
          distribucion IN ob_iax_produlkmodelosinv,
          pfefecto IN DATE,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabardistribucion';
          vsumpinvers    NUMBER := 0;
          v_pinvers      NUMBER;
          v_pmaxcont     NUMBER;
          max_sum_error  EXCEPTION;
          max_pinvers_error EXCEPTION;
          maxmin_pinvers_error EXCEPTION;
       BEGIN
          IF distribucion IS NULL THEN
             RETURN 0;
          END IF;

          IF distribucion.modinvfondo.COUNT = 0 THEN
             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --Esborrat de distribucions existents.
             vpasexec := 4;

             DELETE FROM estsegdisin2
                   WHERE sseguro = vsolicit;
          END IF;

          -- IF  NVL(f_parproductos_v(pac_iax_produccion.vproducto, 'PERFIL_LIBRE'), 0) = distribucion.cmodinv THEN
          FOR i IN distribucion.modinvfondo.FIRST .. distribucion.modinvfondo.LAST LOOP
             IF distribucion.modinvfondo(i).cobliga = 1 THEN
                IF (distribucion.modinvfondo(i).pinvers > 100
                    OR distribucion.modinvfondo(i).pinvers < 0) THEN
                   RAISE max_pinvers_error;
                END IF;

                SELECT pinvers, pmaxcont
                  INTO v_pinvers, v_pmaxcont
                  FROM modinvfondo
                 WHERE ccodfon = distribucion.modinvfondo(i).ccodfon
                   AND cmodinv = distribucion.cmodinv
                   AND(cramo, ctipseg, ccolect, cmodali) IN(
                                                   SELECT DISTINCT cramo, ctipseg, ccolect,
                                                                   cmodali
                                                              FROM estseguros
                                                             WHERE sseguro = vsolicit);

                IF v_pinvers > distribucion.modinvfondo(i).pinvers
                   OR(v_pmaxcont IS NOT NULL
                      AND v_pmaxcont > 0
                      AND distribucion.modinvfondo(i).pinvers > v_pmaxcont) THEN
                   RAISE maxmin_pinvers_error;
                END IF;

                vsumpinvers := vsumpinvers + distribucion.modinvfondo(i).pinvers;
             /*p_tab_error(f_sysdate, f_user, 'PAC_MD_GRABARDATOS.f_grabardistribucion', 121,
                         'vsumpinvers: ' || TO_CHAR(vsumpinvers) || ' ccodfon: '
                         || TO_CHAR(distribucion.modinvfondo(i).ccodfon) || ' cmodinv: '
                         || TO_CHAR(distribucion.cmodinv) || ' pinvers: '
                         || TO_CHAR(distribucion.modinvfondo(i).pinvers),
                         SQLERRM);*/
             END IF;
          END LOOP;

          IF vsumpinvers < 100
             OR vsumpinvers > 100 THEN
             RAISE max_sum_error;
          END IF;

          -- END IF;
          FOR i IN distribucion.modinvfondo.FIRST .. distribucion.modinvfondo.LAST LOOP
             vpasexec := 6;

             IF distribucion.modinvfondo.EXISTS(i) THEN
                vpasexec := 7;

                IF vpmode = 'EST' THEN
                   vpasexec := 11;

                   INSERT INTO estsegdisin2
                               (sseguro, nriesgo, nmovimi, finicio,
                                ccesta,
                                pdistrec,
                                cmodabo)
                        VALUES (vsolicit, 1, vnmovimi,   /*pfefecto*/
                                                      pac_iax_produccion.vfefecto,
                                distribucion.modinvfondo(i).ccodfon,
                                distribucion.modinvfondo(i).pinvers,
                                distribucion.modinvfondo(i).cmodabo);
                END IF;
             END IF;
          END LOOP;

          RETURN 0;   --Tot ok
       EXCEPTION
          WHEN maxmin_pinvers_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 9904012, vpasexec, vparam);
             RETURN 1;
          WHEN max_pinvers_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 9904942, vpasexec, vparam);
             RETURN 1;
          WHEN max_sum_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 9902398, vpasexec, vparam);
             RETURN 1;
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabardistribucion;

       /*************************************************************************
          Grabar los el saldo deutor a las tablas
          param in saldodeutors  : col. t_iax_saldodeutorseg
          param in riesgo  : num. riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       -- Bug 10702 - 22/07/2009 - XPL - Nueva pantalla para contratacion y suplementos que permita seleccionar cuentas aseguradas.
       -- Bug 11165 - 16/09/2009 - AMC - Se sustituye  T_iax_saldodeutorseg por t_iax_prestamoseg
       FUNCTION f_grabarriesprestamos(
          prestamo IN t_iax_prestamoseg,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabarriessaldodeutors';
          vfalta         DATE;   -- Bug 11301 - APD - 22/10/2009
          vnumerr        NUMBER;
       BEGIN
          IF prestamo IS NOT NULL
             AND prestamo.COUNT > 0 THEN
             IF vpmode = 'EST' THEN
                DELETE      estprestamoseg
                      WHERE sseguro = vsolicit;
             ELSE
                DELETE      prestamoseg
                      WHERE sseguro = vsolicit;
             END IF;

             FOR i IN prestamo.FIRST .. prestamo.LAST LOOP
                vpasexec := 6;

                IF prestamo.EXISTS(i) THEN
                   vpasexec := 7;

                   IF prestamo(i).selsaldo = 1 THEN   -- Si esta marcada la bajamos a base de datos.
                      /* DRA: Esto todavia no lo tenemos claro
                      vnumerr := pac_prestamos.f_fecha_ult_prest(prestamo(i).idcuenta, vfalta);

                      IF vnumerr <> 0 THEN
                         vfalta := f_sysdate;
                      END IF;*/
                      vfalta := f_sysdate;

                      IF vpmode = 'EST' THEN
                         vpasexec := 11;

                         BEGIN
                            -- Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el insert
                            -- la FALTA sera el f_sysdate
                            INSERT INTO estprestamoseg
                                        (sseguro, nriesgo, nmovimi,
                                         ctapres, ctipcuenta,
                                         ctipban, ctipimp,
                                         isaldo, porcen,
                                         ilimite, icapmax,
                                         icapital, cmoneda,
                                         icapaseg, falta, descripcion,
                                         finiprest, ffinprest)
                                 VALUES (vsolicit, pnriesgo, NVL(prestamo(i).nmovimi, 1),
                                         prestamo(i).idcuenta, prestamo(i).ctipcuenta,
                                         prestamo(i).ctipban, prestamo(i).ctipimp,
                                         prestamo(i).isaldo, prestamo(i).porcen,
                                         prestamo(i).ilimite, prestamo(i).icapmax,
                                         prestamo(i).icapital, prestamo(i).cmoneda,
                                         prestamo(i).icapaseg, vfalta, prestamo(i).descripcion,
                                         prestamo(i).finiprest, prestamo(i).ffinprest);
                         EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                               -- Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el update
                               -- la FALTA sera el f_sysdate
                               UPDATE estprestamoseg
                                  SET ctipcuenta = prestamo(i).ctipcuenta,
                                      ctipban = prestamo(i).ctipban,
                                      ctipimp = prestamo(i).ctipimp,
                                      isaldo = prestamo(i).isaldo,
                                      porcen = prestamo(i).porcen,
                                      ilimite = prestamo(i).ilimite,
                                      icapmax = prestamo(i).icapmax,
                                      icapital = prestamo(i).icapital,
                                      cmoneda = prestamo(i).cmoneda,
                                      icapaseg = prestamo(i).icapaseg,
                                      descripcion = prestamo(i).descripcion,
                                      falta = vfalta,
                                      finiprest = prestamo(i).finiprest,
                                      ffinprest = prestamo(i).ffinprest
                                WHERE sseguro = vsolicit
                                  AND nriesgo = pnriesgo
                                  AND nmovimi = NVL(prestamo(i).nmovimi, 1)
                                  AND ctapres = prestamo(i).idcuenta;
                         END;

                         vnumerr := f_grabarprestcuadroseg(prestamo(i).cuadro, mensajes);
                      ELSE
                         -- Bug 11301 - APD - 22/10/2009 - antes de insertar en la tabla Prestamoseg se debe
                         -- insertar en la tabla Prestamos ya que realmente al insertar en prestamoseg lo que
                         -- se esta haciendo es dar de alta un nuevo prestamo
                         -- la FALTA sera el f_sysdate tanto en Prestamos como en Prestamoseg
                         -- vfalta := f_sysdate;  -- se hace arriba
                         BEGIN
                            INSERT INTO prestamos
                                        (ctapres, icapini, falta)
                                 VALUES (prestamo(i).idcuenta, prestamo(i).isaldo, vfalta);
                         EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                               NULL;
                         END;

                         BEGIN
                            -- Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el insert
                            INSERT INTO prestamoseg
                                        (sseguro, nriesgo, nmovimi,
                                         ctapres, ctipcuenta,
                                         ctipban, ctipimp,
                                         isaldo, porcen,
                                         ilimite, icapmax,
                                         icapital, cmoneda,
                                         icapaseg, falta, descripcion,
                                         finiprest, ffinprest)
                                 VALUES (vsolicit, pnriesgo, NVL(prestamo(i).nmovimi, 1),
                                         prestamo(i).idcuenta, prestamo(i).ctipcuenta,
                                         prestamo(i).ctipban, prestamo(i).ctipimp,
                                         prestamo(i).isaldo, prestamo(i).porcen,
                                         prestamo(i).ilimite, prestamo(i).icapmax,
                                         prestamo(i).icapital, prestamo(i).cmoneda,
                                         prestamo(i).icapaseg, vfalta, prestamo(i).descripcion,
                                         prestamo(i).finiprest, prestamo(i).ffinprest);
                         EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                               -- Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el update
                               UPDATE prestamoseg
                                  SET ctipcuenta = prestamo(i).ctipcuenta,
                                      ctipban = prestamo(i).ctipban,
                                      ctipimp = prestamo(i).ctipimp,
                                      isaldo = prestamo(i).isaldo,
                                      porcen = prestamo(i).porcen,
                                      ilimite = prestamo(i).ilimite,
                                      icapmax = prestamo(i).icapmax,
                                      icapital = prestamo(i).icapital,
                                      cmoneda = prestamo(i).cmoneda,
                                      icapaseg = prestamo(i).icapaseg,
                                      descripcion = prestamo(i).descripcion,
                                      falta = vfalta,
                                      finiprest = prestamo(i).finiprest,
                                      ffinprest = prestamo(i).ffinprest
                                WHERE sseguro = vsolicit
                                  AND nriesgo = pnriesgo
                                  AND nmovimi = NVL(prestamo(i).nmovimi, 1)
                                  AND ctapres = prestamo(i).idcuenta;
                         END;
                      END IF;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          RETURN 0;   --Tot ok
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarriesprestamos;

    -- Fi Bug 11165 - 16/09/2009 - AMC - Se sustituye  T_iax_saldodeutorseg por t_iax_prestamoseg
       FUNCTION f_reinsertar_garantia(
          garan IN ob_iax_garantias,
          psolicit IN NUMBER,
          pcgarant IN NUMBER,
          pnriesgo IN NUMBER,
          psproduc IN NUMBER,
          pcramo IN NUMBER,
          pcmodali IN NUMBER,
          pctipseg IN NUMBER,
          pccolect IN NUMBER,
          pactivi IN NUMBER,
          pcagente IN NUMBER)
          RETURN NUMBER IS
          vsolicit       NUMBER;
          vcgarant       garanseg.cgarant%TYPE;
          vnriesgo       NUMBER;
          v_gar_tarif_dep NUMBER;
          v_ndetgar_est  detgaranseg.ndetgar%TYPE;
          v_cramo        seguros.cramo%TYPE;
          v_cmodali      seguros.cmodali%TYPE;
          v_ctipseg      seguros.ctipseg%TYPE;
          v_ccolect      seguros.ccolect%TYPE;
          v_cactivi      seguros.cactivi%TYPE;
          v_sproduc      productos.sproduc%TYPE;
          v_cagente      seguros.cagente%TYPE;
          v_fvencim      pregungaranseg.crespue%TYPE;
          v_ndurcob      detgaranseg.ndurcob%TYPE;
          v_ffincob      detgaranseg.ffincob%TYPE;
          v_ctarifa      detgaranseg.ctarifa%TYPE;
          v_pinttec      detgaranseg.pinttec%TYPE;
          v_pintmin      detgaranseg.pintmin%TYPE;
          vnumerr        NUMBER;
       BEGIN
          vsolicit := psolicit;
          vcgarant := pcgarant;
          vnriesgo := pnriesgo;
          v_cramo := pcramo;
          v_cmodali := pcmodali;
          v_ctipseg := pctipseg;
          v_ccolect := pccolect;
          v_cactivi := pactivi;
          v_sproduc := psproduc;
          v_cagente := pcagente;

          DELETE FROM estdetgaranseg
                WHERE sseguro = vsolicit
                  AND cgarant = vcgarant;

          INSERT INTO estdetgaranseg
                      (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar, fefecto, fvencim,
                       ndurcob, ctarifa, pinttec, ftarifa, crevali, prevali, irevali, icapital,
                       iprianu, precarg, irecarg, cparben, cprepost, ffincob, ipritar, provmat0,
                       fprovmat0, provmat1, fprovmat1, pintmin, pdtocom, idtocom, ctarman, ipripur,
                       ipriinv, itarrea, cagente, cunica)
             (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe, d.ndetgar, d.fefecto,
                     d.fvencim, d.ndurcob, d.ctarifa, d.pinttec, d.ftarifa, d.crevali, d.prevali,
                     d.irevali, 0, 0, d.precarg, d.irecarg, d.cparben, d.cprepost, d.ffincob, 0,
                     d.provmat0, d.fprovmat0, d.provmat1, d.fprovmat1, d.pintmin, d.pdtocom,
                     d.idtocom, d.ctarman, d.ipripur, d.ipriinv, d.itarrea, d.cagente, 3
                FROM detgaranseg d, garanseg g, estseguros s
               WHERE s.sseguro = vsolicit
                 AND g.sseguro = s.ssegpol
                 AND d.sseguro = g.sseguro
                 AND d.nriesgo = g.nriesgo
                 AND d.cgarant = g.cgarant
                 AND d.nmovimi = g.nmovimi
                 AND g.cgarant = vcgarant
                 AND g.ffinefe IS NULL);

          RETURN 0;
       END f_reinsertar_garantia;

       PROCEDURE f_reinsertar_garantia_real(
          psolicit IN NUMBER,
          pcgarant IN NUMBER,
          pnriesgo IN NUMBER) IS
          vsolicit       NUMBER;
          vcgarant       NUMBER;
          vnriesgo       NUMBER;
          v_gar_tarif_dep NUMBER;
          v_ndetgar_est  NUMBER;
       BEGIN
          vsolicit := psolicit;
          vcgarant := pcgarant;
          vnriesgo := pnriesgo;

          SELECT COUNT(*)
            INTO v_gar_tarif_dep
            FROM garanseg g, estseguros s
           WHERE s.sseguro = vsolicit
             AND s.ssegpol = g.sseguro
             AND g.cgarant = vcgarant
             AND g.ffinefe IS NULL;

          IF v_gar_tarif_dep > 0 THEN   -- Existe 2113 en las reales
             SELECT MAX(ndetgar)
               INTO v_ndetgar_est
               FROM garanseg g, detgaranseg d, estseguros s
              WHERE s.sseguro = vsolicit
                AND s.ssegpol = g.sseguro
                AND g.cgarant = vcgarant
                AND g.ffinefe IS NULL
                AND g.nriesgo = vnriesgo
                AND d.sseguro = g.sseguro
                AND d.cgarant = g.cgarant
                AND d.nriesgo = g.nriesgo
                AND d.nmovimi = g.nmovimi;

             DELETE      estdetgaranseg
                   WHERE sseguro = vsolicit
                     AND nriesgo = vnriesgo
                     AND cgarant = vcgarant
                     AND ndetgar > v_ndetgar_est
                     AND nmovimi = vnmovimi;

             FOR regs IN (SELECT d.*
                            FROM garanseg g, detgaranseg d, estseguros s
                           WHERE s.sseguro = vsolicit
                             AND s.ssegpol = g.sseguro
                             AND g.cgarant = vcgarant
                             AND g.ffinefe IS NULL
                             AND g.nriesgo = vnriesgo
                             AND d.sseguro = g.sseguro
                             AND d.cgarant = g.cgarant
                             AND d.nriesgo = g.nriesgo
                             AND d.nmovimi = g.nmovimi) LOOP
                UPDATE estdetgaranseg
                   SET fvencim = regs.fvencim,
                       ndurcob = regs.ndurcob,
                       ctarifa = regs.ctarifa,
                       pinttec = regs.pinttec,
                       icapital = regs.icapital,
                       ffincob = regs.ffincob,
                       pintmin = regs.pintmin,
                       cunica = regs.cunica,
                       precarg = regs.precarg,
                       irecarg = regs.irecarg,
                       crevali = regs.crevali,
                       prevali = regs.prevali,
                       irevali = regs.irevali,
                       pdtocom = regs.pdtocom,
                       idtocom = regs.idtocom,
                       iprianu = regs.iprianu,
                       ipritar = regs.ipritar,
                       ipriinv = regs.ipriinv,
                       ipripur = regs.ipripur,
                       itarrea = regs.itarrea
                 WHERE sseguro = vsolicit
                   AND nriesgo = vnriesgo
                   AND cgarant = regs.cgarant
                   AND ndetgar = regs.ndetgar
                   AND nmovimi = vnmovimi;
             END LOOP;

             FOR regs IN (SELECT g.*
                            FROM garanseg g, estseguros s
                           WHERE s.sseguro = vsolicit
                             AND s.ssegpol = g.sseguro
                             AND g.cgarant = vcgarant
                             AND g.ffinefe IS NULL
                             AND g.nriesgo = vnriesgo) LOOP
                UPDATE estgaranseg
                   SET icapital = regs.icapital,
                       iprianu = regs.iprianu,
                       ipritar = regs.ipritar,
                       itarrea = regs.itarrea,
                       ipritot = regs.ipritot,
                       icaptot = regs.icaptot
                 WHERE sseguro = vsolicit
                   AND nriesgo = vnriesgo
                   AND cgarant = regs.cgarant
                   AND nmovimi = vnmovimi;
             END LOOP;
          ELSE
             DELETE      estdetgaranseg
                   WHERE sseguro = vsolicit
                     AND nriesgo = pnriesgo
                     AND cgarant = vcgarant
                     AND ndetgar = 0
                     AND nmovimi = vnmovimi;
          END IF;
       END f_reinsertar_garantia_real;

       /*************************************************************************
          Grabar informacion de la garantia (suplementos economicos APRA).
          param in garan     : objeto garantia
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error

          Nota: FUNCION PROPIA DE APRA.
       *************************************************************************/
       -- Bug 11735 - RSC - 14/01/2010 - APR - suplemento de modificacion de capital /prima
       FUNCTION f_grabargarantia_alta(
          garan IN ob_iax_garantias,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabargarantia_alta';
          vcapital       NUMBER;
          -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
          v_sproduc      seguros.sproduc%TYPE;
          v_fvencim      pregungaranseg.crespue%TYPE;
          v_ndurcob      pregungaranseg.crespue%TYPE;
          v_ffincob      detgaranseg.ffincob%TYPE;
          v_cactivi      seguros.cactivi%TYPE;
          v_pinttec      NUMBER;
          v_pintmin      NUMBER;
          v_cagente      seguros.cagente%TYPE;
          v_nmovimi      garanseg.nmovimi%TYPE;
          v_pregs        t_iax_preguntas;
          v_cramo        seguros.cramo%TYPE;
          v_cmodali      seguros.cmodali%TYPE;
          v_ctipseg      seguros.ctipseg%TYPE;
          v_ccolect      seguros.ccolect%TYPE;
          v_cobliga      estgaranseg.cobliga%TYPE;
          -- Fin Bug 10757

          -- Bug 11735 - RSC - 14/01/2010 - APR - suplemento de modificacion de capital /prima
          v_csituac      estseguros.csituac%TYPE;
          v_num_gar      NUMBER;
          v_ctarifa      estdetgaranseg.ctarifa%TYPE;
          -- Fin Bug 11735

          -- Bug 11735 - RSC - 14/01/2010 - APR - suplemento de modificacion de capital /prima
          v_gar_tarif_dep NUMBER;
          v_ndetgar_est  estdetgaranseg.ndetgar%TYPE;
          v_conta_rel    NUMBER;
          vnum_aux       NUMBER;
          v_modificacio  BOOLEAN := FALSE;
       -- Fin Bug 11735
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --  Bug 10898 - 19/08/2009 - JRH - Mantener Capitales migrados en productos de salud al realizar suplemento
             IF garan.ctipo IN(8, 9, 5, 6)
                OR(NVL(garan.ctipo, 0) = 0
                   AND NVL(garan.cobliga, 0) <> 0) THEN
                 --Si no da problemas en los capitales calculados si icapital=null
                --  fi Bug 10898 - 19/08/2009 - JRH
                   --JRH Le ponemos informado el capital para que no se queje el pk_nuevaproduccion (que diga que es nula la prima). Pero habriamos de tocar el Pk_nuevaproduccion.
                IF garan.icapital IS NULL THEN
                   vcapital := 0;
    --JRH Le ponemos informado el capital para que no se queje el pk_nuevaproduccion (que diga que es nula la prima). Pero habriamos de tocar el Pk_nuevaproduccion.
                ELSE
                   vcapital := garan.icapital;
                END IF;
             ELSE   --JRH Asi nos tarifica y calcula primas y capitales
                vcapital := NULL;
             END IF;

             vpasexec := 7;
             -- Obtenemos la actividad del contrato
             vnumerr := pac_seguros.f_get_cactivi(vsolicit, NULL, NULL, 'EST', v_cactivi);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
             vnumerr := pac_seguros.f_get_sproduc(vsolicit, 'EST', v_sproduc);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- Fin Bug 10757
             SELECT COUNT(*)
               INTO v_num_gar
               FROM garanseg g, estseguros s
              WHERE s.sseguro = vsolicit
                AND s.ssegpol = g.sseguro
                AND g.cgarant = garan.cgarant
                AND g.ffinefe IS NULL;

    --------------------------
    ------- ESTGARANSEG ------
    --------------------------
             IF v_num_gar = 0 THEN   --->>>>>>>>>> Alta de garantia
                SELECT COUNT(*)
                  INTO vnum
                  FROM estgaranseg g
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant
                   AND g.ffinefe IS NULL;

                IF vnum > 0 THEN
                   vpasexec := 8;

                   UPDATE estgaranseg g
                      SET crevali = garan.crevali,
                          icapital = NVL(vcapital, garan.icapital),
                          icaptot = garan.icaptot,   --//ACC 17032008
                          iextrap = garan.primas.iextrap,
                          cfranq = garan.cfranq,
                          precarg = garan.primas.precarg,
                          irecarg = garan.primas.irecarg,
    -- Bug 13727 - RSC - 06/05/2010 - APR - Analisis/Implementacion de nuevas combinaciones de tarificacion Flexilife Nueva Emision
                          pdtocom = garan.primas.pdtocom,
                          prevali = garan.prevali,
                          irevali = garan.irevali,
                          cobliga = garan.cobliga,
                          iprianu = garan.primas.iprianu,
                          ipritar = garan.primas.ipritar,
                          itarifa = garan.primas.itarifa,
                          ipritot = garan.primas.ipritot,
                          cderreg = garan.cderreg
    -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
                   WHERE  g.sseguro = vsolicit
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ffinefe IS NULL;
                ELSE
                   --No existeix la garantia => La insertem.
                   vpasexec := 9;

                   INSERT INTO estgaranseg
                               (cgarant, nriesgo, nmovimi, sseguro, finiefe,
                                norden, crevali, ctarifa, icapital,
                                precarg, iextrap, iprianu,
                                ffinefe, cformul, ctipfra, ifranqu, irecarg,
                                ipritar, pdtocom, idtocom,
                                prevali, irevali, itarifa, itarrea,
                                ipritot, icaptot, ftarifa, crevalcar, cgasgar,
                                pgasadq, pgasadm, pdtoint, idtoint, feprev, fpprev, percre,
                                cmatch, tdesmat, pintfin, cref, cintref, pdif, pinttec, nparben,
                                nbns, tmgaran, cderreg, ccampanya, nversio, nmovima, cageven,
                                nfactor, nlinea, cfranq, nfraver, ngrpfra, ngrpgara, nordfra,
                                pdtofra, cmotmov, finider, falta, ctarman, cobliga, ctipgar)
                        VALUES (garan.cgarant, pnriesgo, vnmovimi, vsolicit, garan.finiefe,
                                garan.norden, garan.crevali, NULL, NVL(vcapital, garan.icapital),
                                garan.primas.precarg, garan.primas.iextrap, garan.primas.iprianu,
                                NULL, NULL, NULL, garan.ifranqu, garan.primas.irecarg,
                                garan.primas.ipritar, garan.primas.pdtocom, garan.primas.idtocom,
                                garan.prevali, garan.irevali, garan.primas.itarifa, NULL,
                                garan.primas.ipritot, garan.icaptot, garan.finiefe, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, garan.cderreg, NULL, NULL, garan.nmovima, NULL,
    -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
                                NULL, NULL, garan.cfranq, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL, garan.cobliga, garan.ctipgar);
                END IF;
             END IF;

             vpasexec := 10;
             --Gravem les preguntes de la garantia
             vnumerr := f_grabarpreguntasgarantia(garan.preguntas, pnriesgo, garan.cgarant,
                                                  mensajes);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

    --------------------------
    ---- ESTDETGARANSEG ------
    --------------------------
             IF v_num_gar = 0 THEN   ---->>>>>>>>> Alta de garantia
                SELECT cramo, cmodali, ctipseg, ccolect
                  INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
                  FROM productos
                 WHERE sproduc = v_sproduc;

                SELECT COUNT(*)
                  INTO vnum
                  FROM estdetgaranseg d, estgaranseg g
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant
                   AND g.ffinefe IS NULL
                   AND d.sseguro = g.sseguro
                   AND d.cgarant = g.cgarant
                   AND d.nriesgo = g.nriesgo
                   AND d.finiefe = g.finiefe
                   AND d.ndetgar = 0;

                --and g.finiefe = garan.finiefe;
                IF vnum > 0 THEN
                   -- Obtenemos la actividad del contrato
                   vnumerr := pac_seguros.f_get_cactivi(vsolicit, NULL, NULL, 'EST', v_cactivi);

                   IF vnumerr <> 0 THEN
                      RETURN vnumerr;
                   END IF;

                   IF garan.cobliga = 1 THEN
                      IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                             garan.cgarant, 'TIPO'),
                             0) NOT IN(3, 4) THEN
                         -- Obtenemos la fecha de vencimiento de la garantia
                         vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                       pnriesgo, 1043, 'EST',
                                                                       v_fvencim);

                         IF vnumerr <> 0 THEN
                            -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                            IF vnumerr <> 120135 THEN
                               RETURN vnumerr;
                            ELSE
                               SELECT TO_NUMBER(TO_CHAR(fvencim, 'yyyymmdd'))
                                 INTO v_fvencim
                                 FROM estseguros
                                WHERE sseguro = vsolicit;
                            END IF;
                         -- Fin Bug 11075
                         END IF;

                         -- Obtenemos la fecha fin de pagos
                         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(2) THEN
                            vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                          pnriesgo, 1049, 'EST',
                                                                          v_ndurcob);

                            IF vnumerr <> 0 THEN
                               -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                               IF vnumerr <> 120135 THEN
                                  RETURN vnumerr;
                               ELSE
                                  SELECT ndurcob
                                    INTO v_ndurcob
                                    FROM estseguros
                                   WHERE sseguro = vsolicit;
                               END IF;
                            -- Fin Bug 11075
                            END IF;

                            v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob * 12);
                         -- Fecha fin de pagos
                         ELSE
                            IF v_fvencim IS NOT NULL
                               AND v_fvencim <> 0 THEN
                               SELECT MONTHS_BETWEEN(TO_DATE(v_fvencim, 'YYYYMMDD'), garan.finiefe)
                                 INTO v_ndurcob
                                 FROM DUAL;

                               v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob);
                               -- Fecha fin de pagos
                               v_ndurcob := v_ndurcob / 12;
                            END IF;
                         END IF;

                               -- TARIFA VIGENTE (CTARIFA) --
                         -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                         -- Si el producto es GROUPLIFE, v_ctarifa  se obtiene de la
                         -- pregunta 133 y su respuesta
                         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                            AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                            vnumerr := pac_preguntas.f_get_pregunpolseg(vsolicit, 133, 'EST',
                                                                        v_ctarifa);

                            IF vnumerr <> 0 THEN
                               RETURN vnumerr;
                            END IF;
                         ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                            v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_VIGENTE');
                         END IF;
                      -- fin Bug 17105
                      END IF;

                      UPDATE estdetgaranseg g
                         SET crevali = garan.crevali,
                             icapital = NVL(vcapital, garan.icapital),
                             precarg = garan.primas.precarg,
                             irecarg = garan.primas.irecarg,
    -- Bug 13727 - RSC - 06/05/2010 - APR - Analisis/Implementacion de nuevas combinaciones de tarificacion Flexilife Nueva Emision
                             pdtocom = garan.primas.pdtocom,
                             prevali = garan.prevali,
                             irevali = garan.irevali,
                             iprianu = garan.primas.iprianu,
                             ipritar = garan.primas.ipritar,
                             fvencim = DECODE(v_fvencim,
                                              NULL, NULL,
                                              0, NULL,
                                              TO_DATE(v_fvencim, 'YYYYMMDD')),
                             ndurcob = v_ndurcob * 12,
                             ffincob = v_ffincob,
                             ctarifa = v_ctarifa
                       --,cunica = 3
                      WHERE  g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ndetgar = 0
                         AND g.nmovimi = vnmovimi;

                      -- Bug 11735 - RSC - 10/05/2010 - APR - suplemento de modificacion de capital /prima
                      IF garan.cgarant IN(2101, 2102, 2103, 2108, 2109, 2110, 2112) THEN
                         IF (garan.cgarant IN(2101, 2102, 2103)
                             AND garan.icapital IS NULL)
                            OR(garan.cgarant IN(2108, 2109, 2110, 2112)
                               AND garan.primas.iprianu IS NULL) THEN
                            v_modificacio := TRUE;

                            SELECT COUNT(*)
                              INTO vnum_aux
                              FROM estdetgaranseg d
                             WHERE d.sseguro = vsolicit
                               AND d.cgarant = 2113
                               AND d.nriesgo = pnriesgo
                               AND d.nmovimi = vnmovimi;

                            IF vnum_aux > 0 THEN
                               vnumerr := f_reinsertar_garantia(garan, vsolicit, 2113, pnriesgo,
                                                                v_sproduc, v_cramo, v_cmodali,
                                                                v_ctipseg, v_ccolect, v_cactivi,
                                                                v_cagente);

                               IF vnumerr <> 0 THEN
                                  RETURN vnumerr;
                               END IF;
                            END IF;

                            SELECT COUNT(*)
                              INTO vnum_aux
                              FROM estdetgaranseg d
                             WHERE d.sseguro = vsolicit
                               AND d.cgarant = 2115
                               AND d.nriesgo = pnriesgo
                               AND d.nmovimi = vnmovimi;

                            IF vnum_aux > 0 THEN
                               vnumerr := f_reinsertar_garantia(garan, vsolicit, 2115, pnriesgo,
                                                                v_sproduc, v_cramo, v_cmodali,
                                                                v_ctipseg, v_ccolect, v_cactivi,
                                                                v_cagente);

                               IF vnumerr <> 0 THEN
                                  RETURN vnumerr;
                               END IF;
                            END IF;
                         END IF;
                      END IF;
                   ELSE
                      DELETE      estdetgaranseg
                            WHERE sseguro = vsolicit
                              AND nriesgo = pnriesgo
                              AND cgarant = garan.cgarant
                              AND ndetgar = 0
                              AND nmovimi = vnmovimi;

                      -- Bug 11735 - RSC - 10/05/2010 - APR - suplemento de modificacion de capital /prima
                      IF garan.cgarant IN(2101, 2102, 2103, 2108, 2109, 2110, 2112) THEN
                         v_modificacio := FALSE;
                         f_reinsertar_garantia_real(vsolicit, 2113, pnriesgo);
                         f_reinsertar_garantia_real(vsolicit, 2115, pnriesgo);
                      END IF;
                   -- Fin Bug 11735
                   END IF;
                ELSE
                   IF garan.cobliga = 1 THEN
                      -- Obtenemos la fecha de vencimiento de la garantia
                      IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                             garan.cgarant, 'TIPO'),
                             0) NOT IN(3, 4) THEN
                         vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                       pnriesgo, 1043, 'EST',
                                                                       v_fvencim);

                         IF vnumerr <> 0 THEN
                            -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                            IF vnumerr <> 120135 THEN
                               RETURN vnumerr;
                            ELSE
                               SELECT TO_NUMBER(TO_CHAR(fvencim, 'yyyymmdd'))
                                 INTO v_fvencim
                                 FROM estseguros
                                WHERE sseguro = vsolicit;
                            END IF;
                         -- Fin Bug 11075
                         END IF;

                         -- Obtenemos la fecha fin de pagos
                         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(2) THEN
                            vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                          pnriesgo, 1049, 'EST',
                                                                          v_ndurcob);

                            IF vnumerr <> 0 THEN
                               -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                               IF vnumerr <> 120135 THEN
                                  RETURN vnumerr;
                               ELSE
                                  SELECT ndurcob
                                    INTO v_ndurcob
                                    FROM estseguros
                                   WHERE sseguro = vsolicit;
                               END IF;
                            -- Fin Bug 11075
                            END IF;

                            v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob * 12);
                         -- Fecha fin de pagos
                         ELSE
                            IF v_fvencim IS NOT NULL
                               AND v_fvencim <> 0 THEN
                               SELECT MONTHS_BETWEEN(TO_DATE(v_fvencim, 'YYYYMMDD'), garan.finiefe)
                                 INTO v_ndurcob
                                 FROM DUAL;

                               v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob);
                               -- Fecha fin de pagos
                               v_ndurcob := v_ndurcob / 12;
                            END IF;
                         END IF;

                         -- TARIFA VIGENTE (CTARIFA) --
                         -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                         -- Si el producto es GROUPLIFE, v_ctarifa  se obtiene de la
                         -- pregunta 133 y su respuesta
                         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                            AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                            vnumerr := pac_preguntas.f_get_pregunpolseg(vsolicit, 133, 'EST',
                                                                        v_ctarifa);

                            IF vnumerr <> 0 THEN
                               RETURN vnumerr;
                            END IF;
                         ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                            v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_VIGENTE');
                         END IF;
                      -- Fin Bug 17105
                      END IF;

                      -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                      -- Si el producto es GROUPLIFE, v_pinttec se obtiene de la
                      -- pregunta 133 y su respuesta
                      IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                         AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                         v_pinttec := vtramo(NULL,
                                             vtramo(NULL,
                                                    NVL(f_parproductos_v(v_sproduc,
                                                                         'TRAMO_INTERES'),
                                                        0),
                                                    v_ctarifa),
                                             garan.cgarant);   -- Interes (Tarifa)
                      ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                         v_pinttec := pac_inttec.ff_int_gar_seg('EST', vsolicit, garan.cgarant);   -- Interes (Tarifa)
                      END IF;

                      -- fin Bug 17105
                      v_pintmin := pac_inttec.ff_int_gar_prod(v_sproduc, v_cactivi, garan.cgarant,
                                                              1, f_sysdate, 0);   -- Interes minimo (Tarifa)
                      -- Obtenemos el agente
                      vnumerr := pac_seguros.f_get_cagente(vsolicit, 'EST', v_cagente);

                      IF vnumerr <> 0 THEN
                         RETURN vnumerr;
                      END IF;

                      INSERT INTO estdetgaranseg
                                  (sseguro, cgarant, nriesgo, nmovimi, finiefe, ndetgar,
                                   fefecto,
                                   fvencim,
                                   ndurcob, ctarifa, pinttec, ftarifa,
                                   crevali, prevali, irevali,
                                   icapital, iprianu,
                                   precarg, irecarg, cparben, cprepost,
                                   ffincob, ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
                                   pintmin, pdtocom, idtocom, ctarman,
                                   ipripur, ipriinv, itarrea, cagente, cunica)
                           VALUES (vsolicit, garan.cgarant, pnriesgo, vnmovimi, garan.finiefe, 0,
                                   garan.finiefe,
                                   DECODE(v_fvencim,
                                          NULL, NULL,
                                          0, NULL,
                                          TO_DATE(v_fvencim, 'yyyymmdd')),
                                   v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe,
                                   garan.crevali, garan.prevali, garan.irevali,
                                   NVL(vcapital, garan.icapital), garan.primas.iprianu,
                                   garan.primas.precarg, garan.primas.irecarg, NULL, NULL,
                                   v_ffincob, garan.primas.ipritar, NULL, NULL, NULL, NULL,
                                   v_pintmin, garan.primas.pdtocom, garan.primas.idtocom, NULL,
                                   NULL, NULL, NULL, v_cagente, 3);

                      -- Bug 11735 - RSC - 10/05/2010 - APR - suplemento de modificacion de capital /prima
                      IF garan.cgarant IN(2101, 2102, 2103, 2108, 2109, 2110, 2112) THEN
                         SELECT COUNT(*)
                           INTO v_gar_tarif_dep
                           FROM garanseg g, estseguros s
                          WHERE s.sseguro = vsolicit
                            AND s.ssegpol = g.sseguro
                            AND g.cgarant = 2113
                            AND g.ffinefe IS NULL;

                         -- Obtenemos la fecha de vencimiento de la garantia
                         IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                v_cactivi, 2113, 'TIPO'),
                                0) NOT IN(3, 4) THEN
                            vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, 2113,
                                                                          pnriesgo, 1043, 'EST',
                                                                          v_fvencim);

                            IF vnumerr <> 0 THEN
                               -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                               IF vnumerr <> 120135 THEN
                                  RETURN vnumerr;
                               ELSE
                                  SELECT TO_NUMBER(TO_CHAR(fvencim, 'yyyymmdd'))
                                    INTO v_fvencim
                                    FROM estseguros
                                   WHERE sseguro = vsolicit;
                               END IF;
                            -- Fin Bug 11075
                            END IF;

                            -- Obtenemos la fecha fin de pagos
                            IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(2) THEN
                               vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, 2113,
                                                                             pnriesgo, 1049,
                                                                             'EST', v_ndurcob);

                               IF vnumerr <> 0 THEN
                                  -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                                  IF vnumerr <> 120135 THEN
                                     RETURN vnumerr;
                                  ELSE
                                     SELECT ndurcob
                                       INTO v_ndurcob
                                       FROM estseguros
                                      WHERE sseguro = vsolicit;
                                  END IF;
                               -- Fin Bug 11075
                               END IF;

                               v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob * 12);
                            -- Fecha fin de pagos
                            ELSE
                               IF v_fvencim IS NOT NULL
                                  AND v_fvencim <> 0 THEN
                                  SELECT MONTHS_BETWEEN(TO_DATE(v_fvencim, 'YYYYMMDD'),
                                                        garan.finiefe)
                                    INTO v_ndurcob
                                    FROM DUAL;

                                  v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob);
                                  -- Fecha fin de pagos
                                  v_ndurcob := v_ndurcob / 12;
                               END IF;
                            END IF;

                            -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                            -- Si el producto es GROUPLIFE, v_ctarifa se obtiene de la
                            -- pregunta 133 y su respuesta
                            IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                               AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                               vnumerr := pac_preguntas.f_get_pregunpolseg(vsolicit, 133, 'EST',
                                                                           v_ctarifa);

                               IF vnumerr <> 0 THEN
                                  RETURN vnumerr;
                               END IF;
                            ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                               v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_VIGENTE');
                            END IF;
                         -- fin Bug 17105
                         END IF;

                         -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                         -- Si el producto es GROUPLIFE, v_pinttec se obtiene de la
                         -- pregunta 133 y su respuesta
                         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                            AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                            v_pinttec := vtramo(NULL,
                                                vtramo(NULL,
                                                       NVL(f_parproductos_v(v_sproduc,
                                                                            'TRAMO_INTERES'),
                                                           0),
                                                       v_ctarifa),
                                                2113);   -- Interes (Tarifa)
                         ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                            v_pinttec := pac_inttec.ff_int_gar_seg('EST', vsolicit, 2113);
                         -- Interes (Tarifa)
                         END IF;

                         -- fin Bug 17105
                         v_pintmin := pac_inttec.ff_int_gar_prod(v_sproduc, v_cactivi, 2113, 1,
                                                                 f_sysdate, 0);
                                                        -- Interes minimo (Tarifa)
                         -- Obtenemos el agente
                         vnumerr := pac_seguros.f_get_cagente(vsolicit, 'EST', v_cagente);

                         IF vnumerr <> 0 THEN
                            RETURN vnumerr;
                         END IF;

                         IF v_gar_tarif_dep > 0 THEN   -- La 2113 ya esta contratada antes del suplemento
                            SELECT MAX(ndetgar)
                              INTO v_ndetgar_est
                              FROM garanseg g, detgaranseg d, estseguros s
                             WHERE s.sseguro = vsolicit
                               AND s.ssegpol = g.sseguro
                               AND g.cgarant = 2113
                               AND g.ffinefe IS NULL
                               AND d.sseguro = g.sseguro
                               AND d.cgarant = g.cgarant
                               AND d.nriesgo = g.nriesgo
                               AND d.nmovimi = g.nmovimi;

                            v_ndetgar_est := v_ndetgar_est + 1;
                         ELSE
                            v_ndetgar_est := 0;
                         END IF;

                         BEGIN
                            INSERT INTO estdetgaranseg
                                        (sseguro, cgarant, nriesgo, nmovimi, finiefe,
                                         ndetgar, fefecto,
                                         fvencim,
                                         ndurcob, ctarifa, pinttec, ftarifa,
                                         crevali, prevali, irevali,
                                         icapital, iprianu,
                                         precarg, irecarg, cparben, cprepost,
                                         ffincob, ipritar, provmat0, fprovmat0, provmat1,
                                         fprovmat1, pintmin, pdtocom,
                                         idtocom, ctarman, ipripur, ipriinv, itarrea, cagente,
                                         cunica)
                                 VALUES (vsolicit, 2113, pnriesgo, vnmovimi, garan.finiefe,
                                         v_ndetgar_est, garan.finiefe,
                                         DECODE(v_fvencim,
                                                NULL, NULL,
                                                0, NULL,
                                                TO_DATE(v_fvencim, 'yyyymmdd')),
                                         v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe,
                                         garan.crevali, garan.prevali, garan.irevali,
                                         NVL(vcapital, garan.icapital), garan.primas.iprianu,
                                         garan.primas.precarg, garan.primas.irecarg, NULL, NULL,
                                         v_ffincob, garan.primas.ipritar, NULL, NULL, NULL,
                                         NULL, v_pintmin, garan.primas.pdtocom,
                                         garan.primas.idtocom, NULL, NULL, NULL, NULL, v_cagente,
                                         3);
                         EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                               NULL;
                         -- Si ya hemos creado un detalle de 2115 es que ya hemos dado de alta
                         -- una garantia basica relacionada con la ACRI A (2113).
                         END;

                         SELECT COUNT(*)
                           INTO v_gar_tarif_dep
                           FROM garanseg g, estseguros s
                          WHERE s.sseguro = vsolicit
                            AND s.ssegpol = g.sseguro
                            AND g.cgarant = 2115
                            AND g.ffinefe IS NULL;

                         -- Obtenemos la fecha de vencimiento de la garantia
                         IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                v_cactivi, 2115, 'TIPO'),
                                0) NOT IN(3, 4) THEN
                            vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, 2115,
                                                                          pnriesgo, 1043, 'EST',
                                                                          v_fvencim);

                            IF vnumerr <> 0 THEN
                               -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                               IF vnumerr <> 120135 THEN
                                  RETURN vnumerr;
                               ELSE
                                  SELECT TO_NUMBER(TO_CHAR(fvencim, 'yyyymmdd'))
                                    INTO v_fvencim
                                    FROM estseguros
                                   WHERE sseguro = vsolicit;
                               END IF;
                            -- Fin Bug 11075
                            END IF;

                            -- Obtenemos la fecha fin de pagos
                            IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(2) THEN
                               vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, 2115,
                                                                             pnriesgo, 1049,
                                                                             'EST', v_ndurcob);

                               IF vnumerr <> 0 THEN
                                  -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
                                  IF vnumerr <> 120135 THEN
                                     RETURN vnumerr;
                                  ELSE
                                     SELECT ndurcob
                                       INTO v_ndurcob
                                       FROM estseguros
                                      WHERE sseguro = vsolicit;
                                  END IF;
                               -- Fin Bug 11075
                               END IF;

                               v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob * 12);
                            -- Fecha fin de pagos
                            ELSE
                               IF v_fvencim IS NOT NULL
                                  AND v_fvencim <> 0 THEN
                                  SELECT MONTHS_BETWEEN(TO_DATE(v_fvencim, 'YYYYMMDD'),
                                                        garan.finiefe)
                                    INTO v_ndurcob
                                    FROM DUAL;

                                  v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob);
                                  -- Fecha fin de pagos
                                  v_ndurcob := v_ndurcob / 12;
                               END IF;
                            END IF;

                            -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                            -- Si el producto es GROUPLIFE, v_ctarifa se obtiene de la
                            -- pregunta 133 y su respuesta
                            IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                               AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                               vnumerr := pac_preguntas.f_get_pregunpolseg(vsolicit, 133, 'EST',
                                                                           v_ctarifa);

                               IF vnumerr <> 0 THEN
                                  RETURN vnumerr;
                               END IF;
                            ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                               v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_VIGENTE');
                            END IF;
                         -- fin Bug 17105
                         END IF;

                         -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                         -- Si el producto es GROUPLIFE, v_ctarifa y v_pinttec se obtiene de la
                         -- pregunta 133 y su respuesta
                         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                            AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                            v_pinttec := vtramo(NULL,
                                                vtramo(NULL,
                                                       NVL(f_parproductos_v(v_sproduc,
                                                                            'TRAMO_INTERES'),
                                                           0),
                                                       v_ctarifa),
                                                2115);   -- Interes (Tarifa)
                         ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                            v_pinttec := pac_inttec.ff_int_gar_seg('EST', vsolicit, 2115);
                         -- Interes (Tarifa)
                         END IF;

                         -- fin Bug 17105
                         v_pintmin := pac_inttec.ff_int_gar_prod(v_sproduc, v_cactivi, 2115, 1,
                                                                 f_sysdate, 0);
                                                        -- Interes minimo (Tarifa)
                         -- Obtenemos el agente
                         vnumerr := pac_seguros.f_get_cagente(vsolicit, 'EST', v_cagente);

                         IF vnumerr <> 0 THEN
                            RETURN vnumerr;
                         END IF;

                         IF v_gar_tarif_dep > 0 THEN   -- La 2115 ya esta contratada antes del suplemento
                            SELECT MAX(ndetgar)
                              INTO v_ndetgar_est
                              FROM garanseg g, detgaranseg d, estseguros s
                             WHERE s.sseguro = vsolicit
                               AND s.ssegpol = g.sseguro
                               AND g.cgarant = 2115
                               AND g.ffinefe IS NULL
                               AND d.sseguro = g.sseguro
                               AND d.cgarant = g.cgarant
                               AND d.nriesgo = g.nriesgo
                               AND d.nmovimi = g.nmovimi;

                            v_ndetgar_est := v_ndetgar_est + 1;
                         ELSE
                            v_ndetgar_est := 0;
                         END IF;

                         BEGIN
                            INSERT INTO estdetgaranseg
                                        (sseguro, cgarant, nriesgo, nmovimi, finiefe,
                                         ndetgar, fefecto,
                                         fvencim,
                                         ndurcob, ctarifa, pinttec, ftarifa,
                                         crevali, prevali, irevali,
                                         icapital, iprianu,
                                         precarg, irecarg, cparben, cprepost,
                                         ffincob, ipritar, provmat0, fprovmat0, provmat1,
                                         fprovmat1, pintmin, pdtocom,
                                         idtocom, ctarman, ipripur, ipriinv, itarrea, cagente,
                                         cunica)
                                 VALUES (vsolicit, 2115, pnriesgo, vnmovimi, garan.finiefe,
                                         v_ndetgar_est, garan.finiefe,
                                         DECODE(v_fvencim,
                                                NULL, NULL,
                                                0, NULL,
                                                TO_DATE(v_fvencim, 'yyyymmdd')),
                                         v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe,
                                         garan.crevali, garan.prevali, garan.irevali,
                                         NVL(vcapital, garan.icapital), garan.primas.iprianu,
                                         garan.primas.precarg, garan.primas.irecarg, NULL, NULL,
                                         v_ffincob, garan.primas.ipritar, NULL, NULL, NULL,
                                         NULL, v_pintmin, garan.primas.pdtocom,
                                         garan.primas.idtocom, NULL, NULL, NULL, NULL, v_cagente,
                                         3);
                         EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                               NULL;
                         -- Si ya hemos creado un detalle de 2115 es que ya hemos dado de alta
                         -- una garantia basica relacionada con la ACRI A (2113).
                         END;
                      END IF;
                   -- Fin Bug 11735
                   END IF;
                END IF;
             ELSE
                IF garan.cgarant NOT IN(2113, 2115) THEN
                   UPDATE estdetgaranseg
                      SET cunica = 2
                    WHERE sseguro = vsolicit
                      AND nriesgo = pnriesgo
                      AND cgarant = garan.cgarant
                      AND nmovimi = vnmovimi
                      AND ndetgar IN(SELECT d.ndetgar
                                       FROM garanseg g, detgaranseg d, estseguros s
                                      WHERE s.sseguro = vsolicit
                                        AND s.ssegpol = g.sseguro
                                        AND g.cgarant = garan.cgarant
                                        AND g.ffinefe IS NULL
                                        AND d.sseguro = g.sseguro
                                        AND d.cgarant = g.cgarant
                                        AND d.nriesgo = g.nriesgo
                                        AND d.nmovimi = g.nmovimi
                                        AND g.nriesgo = pnriesgo
                                        AND cunica <> 1)
                      AND cunica <> 1;
                -- cunica = 1 --> Aportacion extra. Estas se deben quedar como estan!
                END IF;
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargarantia_alta;

       -- INI BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
       /*************************************************************************
          Cargar y grabar la información de la garantia con los datos modificados
          por vigencia amparo
          param in riesgo     : objeto riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabargardat_vigamparo(
          psproduc IN SEGUROS.Sproduc%TYPE,
          pcactivi IN seguros.cactivi%TYPE,
          riesgos IN OUT t_iax_riesgos,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vparam         VARCHAR2(1) := NULL;
          vpasexec       NUMBER(8) := 1;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabargardat_vigamparo';
          v_extcontractual NUMBER := 0;
       BEGIN
          IF riesgos IS NULL THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000827);
             -- No existen riesgos
             RETURN 1;
          END IF;
          if pac_iax_produccion.issuplem THEN
            IF pac_iax_suplementos.lstmotmov.count > 0 THEN
              IF pac_iax_suplementos.lstmotmov(pac_iax_suplementos.lstmotmov.LAST).cmotmov = 918 AND
                pac_iax_suplementos.lstmotmov(pac_iax_suplementos.lstmotmov.LAST).fefecto IS NOT NULL AND
                pac_iax_suplementos.lstmotmov(pac_iax_suplementos.lstmotmov.LAST).fvencim IS NOT NULL AND
                pac_iax_suplementos.lstmotmov(pac_iax_suplementos.lstmotmov.LAST).fvencplazo IS NOT NULL THEN
                FOR i IN 1..riesgos.count LOOP
                  IF riesgos(i).garantias.count > 0 THEN
                    FOR j in 1..riesgos(i).garantias.count LOOP
                      IF riesgos(i).garantias(j).cobliga = 1 then
                        v_extcontractual := NVL(pac_iaxpar_productos.f_get_pargarantia('EXCONTRACTUAL',
                                                                                  psproduc,
                                                                                  riesgos(i).garantias(j).cgarant,
                                                                                  pcactivi),0);
                        IF v_extcontractual in (0) THEN
                          riesgos(i).garantias(j).finivig := pac_iax_suplementos.lstmotmov(1).finiefe;
                          riesgos(i).garantias(j).ffinvig := pac_iax_suplementos.lstmotmov(1).fvencim;
                            --INI CONF-1286_QT_645 - JLTS - 20/02/2018 -- Se separa el contractual igual a uno (1)
                        ELSIF v_extcontractual in (1) THEN
                          riesgos(i).garantias(j).finivig := pac_iax_suplementos.lstmotmov(1).finiefe;
                          riesgos(i).garantias(j).ffinvig := pac_iax_suplementos.lstmotmov(1).fvencplazo;
                            --FIN CONF-1286_QT_645 - JLTS - 20/02/2018
                        ELSIF v_extcontractual in (2) THEN
                          riesgos(i).garantias(j).finivig := pac_iax_suplementos.lstmotmov(1).fvencplazo;
                          riesgos(i).garantias(j).ffinvig := pac_iax_suplementos.lstmotmov(1).fvencim;
                        END IF;
                      END IF;
                    END LOOP;
                  END IF;
                END LOOP;
              END IF;
            END IF;
          END IF;
             RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
         END f_grabargardat_vigamparo;
       -- FIN BUG CONF-1243 QT_724 - 23/01/2018


        /*************************************************************************
          Grabar informacion de la garantia (suplementos economicos APRA).
          param in garan     : objeto garantia
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error

          Nota: FUNCION PROPIA DE APRA.
       *************************************************************************/
       FUNCTION f_grabargarantia_modif_supl(
          garan IN ob_iax_garantias,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes,
          -- Bug 13832 - RSC - 08/06/2010 - APRS015 - suplemento de aportaciones unicas)
          pcmotmov IN NUMBER)
          -- Fin Bug 13832
       RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabargarantia_modif';
          vcapital       NUMBER;
          -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
          v_sproduc      seguros.sproduc%TYPE;
          v_fvencim      pregungaranseg.crespue%TYPE;
          v_ndurcob      pregungaranseg.crespue%TYPE;
          v_ffincob      detgaranseg.ffincob%TYPE;
          v_cactivi      seguros.cactivi%TYPE;
          v_pinttec      NUMBER;
          v_pintmin      NUMBER;
          v_cagente      seguros.cagente%TYPE;
          v_nmovimi      garanseg.nmovimi%TYPE;
          v_pregs        t_iax_preguntas;
          v_cramo        seguros.cramo%TYPE;
          v_cmodali      seguros.cmodali%TYPE;
          v_ctipseg      seguros.ctipseg%TYPE;
          v_ccolect      seguros.ccolect%TYPE;
          v_cobliga      estgaranseg.cobliga%TYPE;
          -- Fin Bug 10757

          -- Bug 11735 - RSC - 14/01/2010 - APR - suplemento de modificacion de capital /prima
          v_csituac      estseguros.csituac%TYPE;
          v_num_gar      NUMBER;
          v_ctarifa      estdetgaranseg.ctarifa%TYPE;
          v_capgar       NUMBER;
          v_iprianu      NUMBER;
          v_diferencia   NUMBER;
          v_ndetgar      NUMBER;
          v_ndetgar_real NUMBER;
          v_ndetgar_est  NUMBER;
          v_ctipcap      garanpro.ctipcap%TYPE;
          v_sum_capital  NUMBER;
          v_sum_iprianu  NUMBER;
          v_idetalle     NUMBER;
          v_final        BOOLEAN := FALSE;
          v_ireducc      NUMBER;
          v_cap_totreal  NUMBER;
          v_ipri_totreal NUMBER;
          v_sseguro      estseguros.ssegpol%TYPE;
          v_gar_real     BOOLEAN := TRUE;
          -- Fin Bug 11735

          -- Bug 11735 - RSC - 11/05/2010 - APR - suplemento de modificacion de capital /prima
          v_gar_tarif_dep NUMBER;
          v_ndetgar_mod  NUMBER;
          v_modificacio  BOOLEAN := FALSE;
          -- Fin Bug 11735

          -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
          v_cunica       NUMBER;
          -- Fin Bug 13832

          -- Bug 13832 - RSC - 01/07/2010 - APRS015 - suplemento de aportaciones unicas
          v_pi           NUMBER;
       -- Fin Bug 13832
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --  Bug 10898 - 19/08/2009 - JRH - Mantener Capitales migrados en productos de salud al realizar suplemento
             IF garan.ctipo IN(8, 9, 5, 6)
                OR(NVL(garan.ctipo, 0) = 0
                   AND NVL(garan.cobliga, 0) <> 0) THEN
                 --Si no da problemas en los capitales calculados si icapital=null
                --  fi Bug 10898 - 19/08/2009 - JRH
                   --JRH Le ponemos informado el capital para que no se queje el pk_nuevaproduccion (que diga que es nula la prima). Pero habriamos de tocar el Pk_nuevaproduccion.
                IF garan.icapital IS NULL THEN
                   vcapital := 0;
    --JRH Le ponemos informado el capital para que no se queje el pk_nuevaproduccion (que diga que es nula la prima). Pero habriamos de tocar el Pk_nuevaproduccion.
                ELSE
                   vcapital := garan.icapital;
                END IF;
             ELSE   --JRH Asi nos tarifica y calcula primas y capitales
                vcapital := NULL;
             END IF;

             -- Obtenemos el sseguro real
             vpasexec := 11;

             SELECT ssegpol
               INTO v_sseguro
               FROM estseguros
              WHERE sseguro = vsolicit;

             vpasexec := 12;
             -- Obtenemos la actividad del contrato
             vnumerr := pac_seguros.f_get_cactivi(vsolicit, NULL, NULL, 'EST', v_cactivi);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             vpasexec := 13;
             vnumerr := pac_seguros.f_get_sproduc(vsolicit, 'EST', v_sproduc);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- Obtenemos el CTIPCAP de la garantia
             vpasexec := 14;

             SELECT ctipcap
               INTO v_ctipcap
               FROM garanpro
              WHERE sproduc = v_sproduc
                AND cgarant = garan.cgarant;

             vpasexec := 15;

             SELECT cramo, cmodali, ctipseg, ccolect
               INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
               FROM productos
              WHERE sproduc = v_sproduc;

             --Obtenemos la fecha de vencimiento de la garantia
             IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                    garan.cgarant, 'TIPO'),
                    0) NOT IN(3, 4)
                AND garan.cobliga = 1 THEN
    -------------------------------
    -- Valores de inicializacion --
    -------------------------------
                vpasexec := 16;
                vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant, pnriesgo,
                                                              1043, 'EST', v_fvencim);

                IF vnumerr <> 0 THEN
                   IF vnumerr <> 120135 THEN
                      RETURN vnumerr;
                   ELSE
                      SELECT TO_NUMBER(TO_CHAR(fvencim, 'yyyymmdd'))
                        INTO v_fvencim
                        FROM estseguros
                       WHERE sseguro = vsolicit;
                   END IF;
                END IF;

                -- Obtenemos la fecha fin de pagos
                IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(2) THEN
                   vpasexec := 17;
                   vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                 pnriesgo, 1049, 'EST', v_ndurcob);

                   IF vnumerr <> 0 THEN
                      IF vnumerr <> 120135 THEN
                         RETURN vnumerr;
                      ELSE
                         SELECT ndurcob
                           INTO v_ndurcob
                           FROM estseguros
                          WHERE sseguro = vsolicit;
                      END IF;
                   END IF;

                   v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob * 12);
                -- Fecha fin de pagos
                ELSE
                   IF v_fvencim IS NOT NULL
                      AND v_fvencim <> 0 THEN
                      SELECT MONTHS_BETWEEN(TO_DATE(v_fvencim, 'YYYYMMDD'), garan.finiefe)
                        INTO v_ndurcob
                        FROM DUAL;

                      v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob);
                      -- Fecha fin de pagos
                      v_ndurcob := v_ndurcob / 12;
                   END IF;
                END IF;

                -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                -- Si el producto es GROUPLIFE, v_ctarifa y v_pinttec se obtiene de la
                -- pregunta 133 y su respuesta
                IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                   AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                   vpasexec := 18;
                   vnumerr := pac_preguntas.f_get_pregunpolseg(vsolicit, 133, 'EST', v_ctarifa);

                   IF vnumerr <> 0 THEN
                      RETURN vnumerr;
                   END IF;

                   vpasexec := 19;
                   v_pinttec := vtramo(NULL,
                                       vtramo(NULL,
                                              NVL(f_parproductos_v(v_sproduc, 'TRAMO_INTERES'), 0),
                                              v_ctarifa),
                                       garan.cgarant);   -- Interes (Tarifa)
                ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                   vpasexec := 18;
                   v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_VIGENTE');
                   vpasexec := 19;
                   v_pinttec := pac_inttec.ff_int_gar_seg('EST', vsolicit, garan.cgarant);
                -- Interes (Tarifa)
                END IF;

                -- fin Bug 17105
                v_pintmin := pac_inttec.ff_int_gar_prod(v_sproduc, v_cactivi, garan.cgarant, 1,
                                                        f_sysdate, 0);   -- Interes minimo (Tarifa)
                -- Obtenemos el agente
                vpasexec := 20;
                vnumerr := pac_seguros.f_get_cagente(vsolicit, 'EST', v_cagente);

                IF vnumerr <> 0 THEN
                   RETURN vnumerr;
                END IF;

                --Gravem les preguntes de la garantia
                vpasexec := 21;
                vnumerr := f_grabarpreguntasgarantia(garan.preguntas, pnriesgo, garan.cgarant,
                                                     mensajes);

                IF vnumerr <> 0 THEN
                   RETURN vnumerr;
                END IF;

    -------------------------------
    -- Tratamiento de detalle    --
    -------------------------------
                vpasexec := 22;

                SELECT SUM(NVL(g.icapital, 0)), SUM(NVL(g.iprianu, 0))
                  INTO v_capgar, v_iprianu
                  FROM estdetgaranseg g
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant;

                vpasexec := 23;

                BEGIN
                   SELECT g.icapital, g.iprianu
                     INTO v_cap_totreal, v_ipri_totreal
                     FROM garanseg g, estseguros s
                    WHERE s.sseguro = vsolicit
                      AND g.sseguro = s.ssegpol
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ffinefe IS NULL;

                   v_gar_real := TRUE;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      -- Puede darse el caso que encadenemos Alta de garantias con Modificacion
                      -- en este caso la garantia o garantias que hemos dados de alta antes no se
                      -- encuentran en real.
                      v_gar_real := FALSE;

                      SELECT g.icapital, g.iprianu
                        INTO v_cap_totreal, v_ipri_totreal
                        FROM estgaranseg g
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL;
                END;

                -- Borrado - Insertado
                IF v_gar_real THEN
                   IF garan.cgarant NOT IN(2113, 2115) THEN
                      DELETE FROM estdetgaranseg
                            WHERE sseguro = vsolicit
                              AND cgarant = garan.cgarant;

                      INSERT INTO estdetgaranseg
                                  (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar, fefecto,
                                   fvencim, ndurcob, ctarifa, pinttec, ftarifa, crevali, prevali,
                                   irevali, icapital, iprianu, precarg, irecarg, cparben, cprepost,
                                   ffincob, ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
                                   pintmin, pdtocom, idtocom, ctarman, ipripur, ipriinv, itarrea,
                                   cagente, cunica)
                         (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                 d.ndetgar, d.fefecto, d.fvencim, d.ndurcob, d.ctarifa, d.pinttec,
                                 d.ftarifa, d.crevali, d.prevali, d.irevali, d.icapital, d.iprianu,
                                 d.precarg, d.irecarg, d.cparben, d.cprepost, d.ffincob, d.ipritar,
                                 d.provmat0, d.fprovmat0, d.provmat1, d.fprovmat1, d.pintmin,
                                 d.pdtocom, d.idtocom, d.ctarman, d.ipripur, d.ipriinv, d.itarrea,
                                 d.cagente, d.cunica
                            FROM detgaranseg d, garanseg g, estseguros s
                           WHERE s.sseguro = vsolicit
                             AND g.sseguro = s.ssegpol
                             AND d.sseguro = g.sseguro
                             AND d.nriesgo = g.nriesgo
                             AND d.cgarant = g.cgarant
                             AND d.nmovimi = g.nmovimi
                             AND g.cgarant = garan.cgarant
                             AND g.ffinefe IS NULL);

                      -- Bug 13832 - RSC - 01/07/2010 - APRS015 - suplemento de aportaciones unicas
                      IF garan.cgarant = 2106 THEN
                         DELETE FROM estdetgaranseg
                               WHERE sseguro = vsolicit
                                 AND cgarant = 2105;

                         INSERT INTO estdetgaranseg
                                     (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar,
                                      fefecto, fvencim, ndurcob, ctarifa, pinttec, ftarifa,
                                      crevali, prevali, irevali, icapital, iprianu, precarg,
                                      irecarg, cparben, cprepost, ffincob, ipritar, provmat0,
                                      fprovmat0, provmat1, fprovmat1, pintmin, pdtocom, idtocom,
                                      ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
                            (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                    d.ndetgar, d.fefecto, d.fvencim, d.ndurcob, d.ctarifa,
                                    d.pinttec, d.ftarifa, d.crevali, d.prevali, d.irevali,
                                    d.icapital, d.iprianu, d.precarg, d.irecarg, d.cparben,
                                    d.cprepost, d.ffincob, d.ipritar, d.provmat0, d.fprovmat0,
                                    d.provmat1, d.fprovmat1, d.pintmin, d.pdtocom, d.idtocom,
                                    d.ctarman, d.ipripur, d.ipriinv, d.itarrea, d.cagente,
                                    d.cunica
                               FROM detgaranseg d, garanseg g, estseguros s
                              WHERE s.sseguro = vsolicit
                                AND g.sseguro = s.ssegpol
                                AND d.sseguro = g.sseguro
                                AND d.nriesgo = g.nriesgo
                                AND d.cgarant = g.cgarant
                                AND d.nmovimi = g.nmovimi
                                AND g.cgarant = 2105
                                AND g.ffinefe IS NULL);
                      END IF;
                   -- Fin Bug 13832
                   END IF;
                END IF;

                vpasexec := 23;

                IF v_ctipcap = 5 THEN
                   IF garan.primas.iprianu > v_ipri_totreal THEN   -- Aumento de prima
                      v_modificacio := TRUE;
    ----------------------
    -- Aumento de prima --
                      v_diferencia := garan.primas.iprianu - v_ipri_totreal;
                      --v_iprianu;
                      vpasexec := 2;

                      UPDATE estgaranseg g
                         SET iprianu = garan.primas.iprianu,
                             ipritot = garan.primas.iprianu
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL;

                      vpasexec := 3;

                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_real
                        FROM detgaranseg d, garanseg g, estseguros s
                       WHERE s.sseguro = vsolicit
                         AND g.sseguro = s.ssegpol
                         AND g.nriesgo = pnriesgo
                         AND g.ffinefe IS NULL
                         AND g.sseguro = d.sseguro
                         AND g.cgarant = d.cgarant
                         AND g.nriesgo = d.nriesgo
                         AND g.nmovimi = d.nmovimi
                         AND g.cgarant = garan.cgarant;

                      -- Obtenemos el maximo detalle
                      vpasexec := 4;

                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_est
                        FROM estdetgaranseg d, estgaranseg g
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL
                         AND d.sseguro = g.sseguro
                         AND d.cgarant = g.cgarant
                         AND d.nriesgo = g.nriesgo
                         AND d.nmovimi = g.nmovimi;

                      IF v_ndetgar_real = v_ndetgar_est THEN
                         vpasexec := 5;

                         INSERT INTO estdetgaranseg
                                     (sseguro, cgarant, nriesgo, nmovimi, finiefe,
                                      ndetgar, fefecto,
                                      fvencim,
                                      ndurcob, ctarifa, pinttec, ftarifa,
                                      crevali, prevali, irevali, icapital,
                                      iprianu, precarg, irecarg,
                                      cparben, cprepost, ffincob, ipritar, provmat0, fprovmat0,
                                      provmat1, fprovmat1, pintmin, pdtocom,
                                      idtocom, ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
                              VALUES (vsolicit, garan.cgarant, pnriesgo, vnmovimi, garan.finiefe,
                                      (v_ndetgar_est + 1), garan.finiefe,
                                      DECODE(v_fvencim,
                                             NULL, NULL,
                                             0, NULL,
                                             TO_DATE(v_fvencim, 'yyyymmdd')),
                                      v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe,
                                      garan.crevali, garan.prevali, garan.irevali, NULL,
                                      v_diferencia, garan.primas.precarg, garan.primas.irecarg,
                                      NULL, NULL, v_ffincob, v_diferencia, NULL, NULL,
                                      NULL, NULL, v_pintmin, garan.primas.pdtocom,
                                      garan.primas.idtocom, NULL, NULL, NULL, NULL, v_cagente, 3);   -- Cunica = 3
                      ELSE
    -- v_ndetgar_real <> v_ndetgar_est -------> (v_ndetgar_real + 1) =  v_ndetgar_est
                         vpasexec := 6;

                         UPDATE estdetgaranseg
                            SET fvencim = DECODE(v_fvencim,
                                                 NULL, NULL,
                                                 0, NULL,
                                                 TO_DATE(v_fvencim, 'yyyymmdd')),
                                ndurcob = v_ndurcob * 12,
                                ctarifa = v_ctarifa,
                                pinttec = v_pinttec,
                                iprianu = v_diferencia,
                                ipritar = v_diferencia,
                                ffincob = v_ffincob,
                                pintmin = v_pintmin,
                                cunica = 3,
                                precarg = garan.primas.precarg,
                                irecarg = garan.primas.irecarg,
                                crevali = garan.crevali,
                                prevali = garan.prevali,
                                irevali = garan.irevali,
                                pdtocom = garan.primas.pdtocom,
                                idtocom = garan.primas.idtocom
                          WHERE sseguro = vsolicit
                            AND cgarant = garan.cgarant
                            AND nriesgo = pnriesgo
                            AND nmovimi = vnmovimi
                            AND ndetgar = v_ndetgar_est;
                      END IF;

                      -- Ponemos el resto de detalle para que no tarifen! (cunica = 1 no tarifa)
                      vpasexec := 7;

                      UPDATE estdetgaranseg
                         SET cunica = 2
                       WHERE sseguro = vsolicit
                         AND cunica NOT IN(1, 3);
                   -- cunica = 1 --> Aportacion extra. Estas se deben quedar como estan!
                   ELSIF garan.primas.iprianu < v_ipri_totreal THEN   --v_iprianu THEN -- Disminuion de prima
    ----------------------------
    -- Disminucion de capital --
    ----------------------------
                      v_modificacio := TRUE;

                      UPDATE estgaranseg g
                         SET iprianu = garan.primas.iprianu,
                             ipritot = garan.primas.iprianu
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL;

                      SELECT SUM(iprianu)
                        INTO v_sum_iprianu
                        FROM estdetgaranseg
                       WHERE sseguro = vsolicit
                         AND cgarant = garan.cgarant
                         AND nriesgo = pnriesgo
                         AND nmovimi = vnmovimi
                         AND cunica <> 1;

                      -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                      v_idetalle := 0;

                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_est
                        FROM estdetgaranseg d, estgaranseg g
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL
                         AND d.sseguro = g.sseguro
                         AND d.cgarant = g.cgarant
                         AND d.nriesgo = g.nriesgo
                         AND d.nmovimi = g.nmovimi;

                      -- Mientras la suma de capitales sea superior vamos reduciendo
                      WHILE v_sum_iprianu > garan.primas.iprianu
                       AND NOT v_final LOOP
                         -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                         SELECT cunica
                           INTO v_cunica
                           FROM estdetgaranseg
                          WHERE sseguro = vsolicit
                            AND cgarant = garan.cgarant
                            AND nriesgo = pnriesgo
                            AND nmovimi = vnmovimi
                            AND ndetgar = v_idetalle;

                         IF v_cunica <> 1 THEN
                            -- Los movimiento con CUNICA = 1 los dejamos sin alterar !!!
                                  -- Fin Bug 13832
                            BEGIN
                               IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                      v_cactivi, garan.cgarant, 'REDUCIBLE'),
                                      0) = 1 THEN
                                  v_ireducc :=
                                     pac_provmat_formul.f_calcul_formulas_provi(v_sseguro,
                                                                                garan.finiefe,
                                                                                'IREDUCC',
                                                                                garan.cgarant,
                                                                                v_idetalle);
                               ELSE
                                  v_ireducc := 0;
                               END IF;
                            EXCEPTION
                               WHEN OTHERS THEN
                                  RAISE e_object_error;
                            END;

                            -- Seguimos reduciendo el Capital -- Reducimos la garantia - Si reducible
                            --IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg,
                            --               v_ccolect, v_cactivi, garan.cgarant, 'REDUCIBLE'), 0) = 1 THEN
                            UPDATE estdetgaranseg
                               SET icapital = v_ireducc,
                                   iprianu = 0
                             WHERE sseguro = vsolicit
                               AND cgarant = garan.cgarant
                               AND nriesgo = pnriesgo
                               AND nmovimi = vnmovimi
                               AND ndetgar = v_idetalle;

                            -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                            --IF v_ndetgar_est = v_idetalle THEN
                            --   v_final := TRUE;
                            --END IF;

                            --v_idetalle := v_idetalle + 1;
                            -- Fin Bug 13832
                            SELECT SUM(iprianu)
                              INTO v_sum_iprianu
                              FROM estdetgaranseg
                             WHERE sseguro = vsolicit
                               AND cgarant = garan.cgarant
                               AND nriesgo = pnriesgo
                               AND nmovimi = vnmovimi
                               AND cunica <> 1;
                         -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                                             -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                         END IF;

                         -- Fin Bug 13832

                         -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                         IF v_ndetgar_est = v_idetalle THEN
                            v_final := TRUE;
                         END IF;

                         v_idetalle := v_idetalle + 1;
                      -- Fin Bug 13832
                      END LOOP;

                      IF v_sum_iprianu > garan.primas.iprianu THEN
                         -- La suma de capitales reducidos supera el capital indicado.
                         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9900974, vpasexec,
                                                           vparam);
                         RETURN 1;
                      END IF;

    ------------------------------------------------------------------
    -- Aumento de capital respecto a la suma de capitales reducidos --
    ------------------------------------------------------------------
                      v_diferencia := garan.primas.iprianu - v_sum_iprianu;

                      IF v_diferencia > 0 THEN
                         SELECT MAX(ndetgar)
                           INTO v_ndetgar_real
                           FROM detgaranseg d, garanseg g, estseguros s
                          WHERE s.sseguro = vsolicit
                            AND g.sseguro = s.ssegpol
                            AND g.nriesgo = pnriesgo
                            AND g.ffinefe IS NULL
                            AND g.sseguro = d.sseguro
                            AND g.cgarant = d.cgarant
                            AND g.nriesgo = d.nriesgo
                            AND g.nmovimi = d.nmovimi
                            AND g.cgarant = garan.cgarant;

                         IF v_ndetgar_real = v_ndetgar_est THEN
                            INSERT INTO estdetgaranseg
                                        (sseguro, cgarant, nriesgo, nmovimi,
                                         finiefe, ndetgar, fefecto,
                                         fvencim,
                                         ndurcob, ctarifa, pinttec, ftarifa,
                                         crevali, prevali, irevali, icapital,
                                         iprianu, precarg,
                                         irecarg, cparben, cprepost, ffincob,
                                         ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
                                         pintmin, pdtocom, idtocom,
                                         ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
                                 VALUES (vsolicit, garan.cgarant, pnriesgo, vnmovimi,
                                         garan.finiefe,(v_ndetgar_est + 1), garan.finiefe,
                                         DECODE(v_fvencim,
                                                NULL, NULL,
                                                0, NULL,
                                                TO_DATE(v_fvencim, 'yyyymmdd')),
                                         v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe,
                                         garan.crevali, garan.prevali, garan.irevali, NULL,
                                         v_diferencia, garan.primas.precarg,
                                         garan.primas.irecarg, NULL, NULL, v_ffincob,
                                         v_diferencia, NULL, NULL, NULL, NULL,
                                         v_pintmin, garan.primas.pdtocom, garan.primas.idtocom,
                                         NULL, NULL, NULL, NULL, v_cagente, 3);   -- Cunica = 3
                         ELSE
    -- v_ndetgar_real <> v_ndetgar_est -------> (v_ndetgar_real + 1) =  v_ndetgar_est
                            UPDATE estdetgaranseg
                               SET fvencim = DECODE(v_fvencim,
                                                    NULL, NULL,
                                                    0, NULL,
                                                    TO_DATE(v_fvencim, 'yyyymmdd')),
                                   ndurcob = v_ndurcob * 12,
                                   ctarifa = v_ctarifa,
                                   pinttec = v_pinttec,
                                   --icapital = v_diferencia,
                                   ffincob = v_ffincob,
                                   pintmin = v_pintmin,
                                   cunica = 3,
                                   iprianu = v_diferencia,
                                   ipritar = v_diferencia,
                                   precarg = garan.primas.precarg,
                                   irecarg = garan.primas.irecarg,
                                   crevali = garan.crevali,
                                   prevali = garan.prevali,
                                   irevali = garan.irevali,
                                   pdtocom = garan.primas.pdtocom,
                                   idtocom = garan.primas.idtocom
                             WHERE sseguro = vsolicit
                               AND cgarant = garan.cgarant
                               AND nriesgo = pnriesgo
                               AND nmovimi = vnmovimi
                               AND ndetgar = v_ndetgar_est;
                         END IF;
                      END IF;

                      -- Ponemos el resto de detalle para que no tarifen! (cunica = 1 no tarifa)
                      UPDATE estdetgaranseg
                         SET cunica = 2
                       WHERE sseguro = vsolicit
                         AND cunica NOT IN(1, 3);
                   -- cunica = 1 --> Aportacion extra. Estas se deben quedar como estan!
                   ELSIF garan.primas.iprianu = v_ipri_totreal THEN   --v_iprianu THEN
                      v_modificacio := FALSE;

                      IF garan.cgarant NOT IN(2113, 2115) THEN
                         UPDATE estgaranseg g
                            SET iprianu = garan.primas.iprianu,
                                ipritot = garan.primas.iprianu
                          WHERE g.sseguro = vsolicit
                            AND g.nriesgo = pnriesgo
                            AND g.cgarant = garan.cgarant
                            AND g.ffinefe IS NULL;

                         UPDATE estdetgaranseg
                            SET cunica = 2
                          WHERE sseguro = vsolicit
                            AND cgarant = garan.cgarant
                            AND nriesgo = pnriesgo
                            AND nmovimi = vnmovimi
                            AND cunica <> 1;
                      END IF;
                   END IF;
                ELSE
                   IF garan.icapital > v_cap_totreal THEN   --v_capgar THEN
                      v_modificacio := TRUE;
    ------------------------
    -- Aumento de capital --
    ------------------------
                      v_diferencia := NVL(vcapital, garan.icapital) - v_cap_totreal;   --v_capgar;

                      UPDATE estgaranseg g
                         SET icapital = NVL(vcapital, garan.icapital),
                             icaptot = garan.icaptot
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL;

                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_real
                        FROM detgaranseg d, garanseg g, estseguros s
                       WHERE s.sseguro = vsolicit
                         AND g.sseguro = s.ssegpol
                         AND g.nriesgo = pnriesgo
                         AND g.ffinefe IS NULL
                         AND g.sseguro = d.sseguro
                         AND g.cgarant = d.cgarant
                         AND g.nriesgo = d.nriesgo
                         AND g.nmovimi = d.nmovimi
                         AND g.cgarant = garan.cgarant;

                      -- Obtenemos el maximo detalle
                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_est
                        FROM estdetgaranseg d, estgaranseg g
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL
                         AND d.sseguro = g.sseguro
                         AND d.cgarant = g.cgarant
                         AND d.nriesgo = g.nriesgo
                         AND d.nmovimi = g.nmovimi;

                      IF v_ndetgar_real = v_ndetgar_est THEN
                         INSERT INTO estdetgaranseg
                                     (sseguro, cgarant, nriesgo, nmovimi, finiefe,
                                      ndetgar, fefecto,
                                      fvencim,
                                      ndurcob, ctarifa, pinttec, ftarifa,
                                      crevali, prevali, irevali, icapital,
                                      iprianu, precarg, irecarg, cparben,
                                      cprepost, ffincob, ipritar, provmat0, fprovmat0, provmat1,
                                      fprovmat1, pintmin, pdtocom,
                                      idtocom, ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
                              VALUES (vsolicit, garan.cgarant, pnriesgo, vnmovimi, garan.finiefe,
                                      (v_ndetgar_est + 1), garan.finiefe,
                                      DECODE(v_fvencim,
                                             NULL, NULL,
                                             0, NULL,
                                             TO_DATE(v_fvencim, 'yyyymmdd')),
                                      v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe,
                                      garan.crevali, garan.prevali, garan.irevali, v_diferencia,
                                      NULL, garan.primas.precarg, garan.primas.irecarg, NULL,
                                      NULL, v_ffincob, NULL, NULL, NULL, NULL,
                                      NULL, v_pintmin, garan.primas.pdtocom,
                                      garan.primas.idtocom, NULL, NULL, NULL, NULL, v_cagente, 3);   -- Cunica = 3

                         -- Bug 13832 - RSC - 01/07/2010 - APRS015 - suplemento de aportaciones unicas
                         IF garan.cgarant IN(2106) THEN
                            INSERT INTO estdetgaranseg
                                        (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar,
                                         fefecto, fvencim, ndurcob, ctarifa, pinttec, ftarifa,
                                         crevali, prevali, irevali, icapital, iprianu, precarg,
                                         irecarg, cparben, cprepost, ffincob, ipritar, provmat0,
                                         fprovmat0, provmat1, fprovmat1, pintmin, pdtocom,
                                         idtocom, ctarman, ipripur, ipriinv, itarrea, cagente,
                                         cunica)
                               (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                       (v_ndetgar_est + 1), d.fefecto, d.fvencim, d.ndurcob,
                                       d.ctarifa, d.pinttec, d.ftarifa, d.crevali, d.prevali,
                                       d.irevali, NULL, NULL, d.precarg, d.irecarg, d.cparben,
                                       d.cprepost, d.ffincob, NULL, d.provmat0, d.fprovmat0,
                                       d.provmat1, d.fprovmat1, d.pintmin, d.pdtocom, d.idtocom,
                                       d.ctarman, d.ipripur, d.ipriinv, d.itarrea, d.cagente, 3
                                  FROM detgaranseg d, garanseg g, estseguros s
                                 WHERE s.sseguro = vsolicit
                                   AND g.sseguro = s.ssegpol
                                   AND d.sseguro = g.sseguro
                                   AND d.nriesgo = g.nriesgo
                                   AND d.cgarant = g.cgarant
                                   AND d.nmovimi = g.nmovimi
                                   AND g.cgarant = 2105
                                   AND d.ndetgar = v_ndetgar_est
                                   AND g.ffinefe IS NULL);
                         END IF;
                      -- Bug 13832
                      ELSE
    -- v_ndetgar_real <> v_ndetgar_est -------> (v_ndetgar_real + 1) =  v_ndetgar_est
                         UPDATE estdetgaranseg
                            SET fvencim = DECODE(v_fvencim,
                                                 NULL, NULL,
                                                 0, NULL,
                                                 TO_DATE(v_fvencim, 'yyyymmdd')),
                                ndurcob = v_ndurcob * 12,
                                ctarifa = v_ctarifa,
                                pinttec = v_pinttec,
                                icapital = v_diferencia,
                                ffincob = v_ffincob,
                                pintmin = v_pintmin,
                                cunica = 3,
                                --iprianu = NULL,
                                --ipritar = NULL,
                                precarg = garan.primas.precarg,
                                irecarg = garan.primas.irecarg,
                                crevali = garan.crevali,
                                prevali = garan.prevali,
                                irevali = garan.irevali,
                                pdtocom = garan.primas.pdtocom,
                                idtocom = garan.primas.idtocom
                          WHERE sseguro = vsolicit
                            AND cgarant = garan.cgarant
                            AND nriesgo = pnriesgo
                            AND nmovimi = vnmovimi
                            AND ndetgar = v_ndetgar_est;

                         -- Bug 13832 - RSC - 01/07/2010 - APRS015 - suplemento de aportaciones unicas
                         IF garan.cgarant IN(2106) THEN
                            v_pi := pac_preguntas.ff_buscapregunpolseg(v_sseguro, 577, NULL);

                            UPDATE estdetgaranseg
                               SET icapital =(v_diferencia / v_pi)
                             WHERE sseguro = vsolicit
                               AND cgarant = 2105
                               AND nriesgo = pnriesgo
                               AND nmovimi = vnmovimi
                               AND ndetgar = v_ndetgar_est;
                         END IF;
                      -- Bug 13832
                      END IF;

                      -- Ponemos el resto de detalle para que no tarifen! (cunica = 1 no tarifa)
                      UPDATE estdetgaranseg
                         SET cunica = 2
                       WHERE sseguro = vsolicit
                         AND cunica NOT IN(1, 3);
                   -- cunica = 1 --> Aportacion extra. Estas se deben quedar como estan!
                         -- Bug 13832 - RSC - 16/06/2010 - APRS015 - suplemento de aportaciones unicas
                         --IF garan.cgarant IN (2105, 2106) THEN
                         --  v_pi := PAC_PREGUNTAS.ff_buscapregunpolseg(vsolicit, 577, NULL);
                         --END IF;
                         -- FIn Bug 13832
                   ELSIF garan.icapital < v_cap_totreal THEN   --v_capgar THEN
                      v_modificacio := TRUE;

    ----------------------------
    -- Disminucion de capital --
    ----------------------------
                      UPDATE estgaranseg g
                         SET icapital = NVL(vcapital, garan.icapital),
                             icaptot = NVL(vcapital, garan.icapital)
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL;

                      SELECT SUM(icapital)
                        INTO v_sum_capital
                        FROM estdetgaranseg
                       WHERE sseguro = vsolicit
                         AND cgarant = garan.cgarant
                         AND nriesgo = pnriesgo
                         AND nmovimi = vnmovimi
                         AND cunica <> 1;

                      -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                      v_idetalle := 0;

                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_est
                        FROM estdetgaranseg d, estgaranseg g
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL
                         AND d.sseguro = g.sseguro
                         AND d.cgarant = g.cgarant
                         AND d.nriesgo = g.nriesgo
                         AND d.nmovimi = g.nmovimi;

                      -- Mientras la suma de capitales sea superior vamos reduciendo
                      WHILE v_sum_capital > garan.icapital
                       AND NOT v_final LOOP
                         -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                         SELECT cunica
                           INTO v_cunica
                           FROM estdetgaranseg
                          WHERE sseguro = vsolicit
                            AND cgarant = garan.cgarant
                            AND nriesgo = pnriesgo
                            AND nmovimi = vnmovimi
                            AND ndetgar = v_idetalle;

                         IF v_cunica <> 1 THEN
                            -- Los movimiento con CUNICA = 1 los dejamos sin alterar !!!
                                  -- Fin Bug 13832
                            BEGIN
                               IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                      v_cactivi, garan.cgarant, 'REDUCIBLE'),
                                      0) = 1 THEN
                                  v_ireducc :=
                                     pac_provmat_formul.f_calcul_formulas_provi(v_sseguro,
                                                                                garan.finiefe,
                                                                                'IREDUCC',
                                                                                garan.cgarant,
                                                                                v_idetalle);
                               ELSE
                                  v_ireducc := 0;
                               END IF;
                            EXCEPTION
                               WHEN OTHERS THEN
                                  RAISE e_object_error;
                            END;

                            -- Seguimos reduciendo el Capital -- Reducimos la garantia - Si reducible
                            UPDATE estdetgaranseg
                               SET icapital = v_ireducc,
                                   iprianu = 0
                             WHERE sseguro = vsolicit
                               AND cgarant = garan.cgarant
                               AND nriesgo = pnriesgo
                               AND nmovimi = vnmovimi
                               AND ndetgar = v_idetalle;

                            -- Bug 13832 - RSC - 01/07/2010 - APRS015 - suplemento de aportaciones unicas
                            IF garan.cgarant IN(2106) THEN
                               v_pi := pac_preguntas.ff_buscapregunpolseg(v_sseguro, 577, NULL);

                               UPDATE estdetgaranseg
                                  SET icapital =(v_ireducc / v_pi)
                                WHERE sseguro = vsolicit
                                  AND cgarant = 2105
                                  AND nriesgo = pnriesgo
                                  AND nmovimi = vnmovimi
                                  AND ndetgar = v_idetalle;
                            END IF;

                            -- Bug 13832

                            -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                            --IF v_ndetgar_est = v_idetalle THEN
                            --   v_final := TRUE;
                            --END IF;

                            --v_idetalle := v_idetalle + 1;
                            -- Fin Bug 13832
                            SELECT SUM(icapital)
                              INTO v_sum_capital
                              FROM estdetgaranseg
                             WHERE sseguro = vsolicit
                               AND cgarant = garan.cgarant
                               AND nriesgo = pnriesgo
                               AND nmovimi = vnmovimi
                               AND cunica <> 1;
                         -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                                             -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                         END IF;

                         -- Fin Bug 13832

                         -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones unicas
                         IF v_ndetgar_est = v_idetalle THEN
                            v_final := TRUE;
                         END IF;

                         v_idetalle := v_idetalle + 1;
                      -- Fin Bug 13832
                      END LOOP;

                      IF v_sum_capital > garan.icapital THEN
                         -- La suma de capitales reducidos supera el capital indicado.
                         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9900974, vpasexec,
                                                           vparam);
                         RETURN 1;
                      END IF;

    ------------------------------------------------------------------
    -- Aumento de capital respecto a la suma de capitales reducidos --
    ------------------------------------------------------------------
                      v_diferencia := NVL(vcapital, garan.icapital) - v_sum_capital;

                      IF v_diferencia > 0 THEN
                         SELECT MAX(ndetgar)
                           INTO v_ndetgar_real
                           FROM detgaranseg d, garanseg g, estseguros s
                          WHERE s.sseguro = vsolicit
                            AND g.sseguro = s.ssegpol
                            AND g.nriesgo = pnriesgo
                            AND g.ffinefe IS NULL
                            AND g.sseguro = d.sseguro
                            AND g.cgarant = d.cgarant
                            AND g.nriesgo = d.nriesgo
                            AND g.nmovimi = d.nmovimi
                            AND g.cgarant = garan.cgarant;

                         IF v_ndetgar_real = v_ndetgar_est THEN
                            INSERT INTO estdetgaranseg
                                        (sseguro, cgarant, nriesgo, nmovimi,
                                         finiefe, ndetgar, fefecto,
                                         fvencim,
                                         ndurcob, ctarifa, pinttec, ftarifa,
                                         crevali, prevali, irevali,
                                         icapital, iprianu, precarg,
                                         irecarg, cparben, cprepost, ffincob, ipritar, provmat0,
                                         fprovmat0, provmat1, fprovmat1, pintmin, pdtocom,
                                         idtocom, ctarman, ipripur, ipriinv, itarrea, cagente,
                                         cunica)
                                 VALUES (vsolicit, garan.cgarant, pnriesgo, vnmovimi,
                                         garan.finiefe,(v_ndetgar_est + 1), garan.finiefe,
                                         DECODE(v_fvencim,
                                                NULL, NULL,
                                                0, NULL,
                                                TO_DATE(v_fvencim, 'yyyymmdd')),
                                         v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe,
                                         garan.crevali, garan.prevali, garan.irevali,
                                         v_diferencia, NULL, garan.primas.precarg,
                                         garan.primas.irecarg, NULL, NULL, v_ffincob, NULL, NULL,
                                         NULL, NULL, NULL, v_pintmin, garan.primas.pdtocom,
                                         garan.primas.idtocom, NULL, NULL, NULL, NULL, v_cagente,
                                         3);   -- Cunica = 3

                            -- Bug 13832 - RSC - 01/07/2010 - APRS015 - suplemento de aportaciones unicas
                            IF garan.cgarant IN(2106) THEN
                               INSERT INTO estdetgaranseg
                                           (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar,
                                            fefecto, fvencim, ndurcob, ctarifa, pinttec, ftarifa,
                                            crevali, prevali, irevali, icapital, iprianu, precarg,
                                            irecarg, cparben, cprepost, ffincob, ipritar,
                                            provmat0, fprovmat0, provmat1, fprovmat1, pintmin,
                                            pdtocom, idtocom, ctarman, ipripur, ipriinv, itarrea,
                                            cagente, cunica)
                                  (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                          (v_ndetgar_est + 1), d.fefecto, d.fvencim, d.ndurcob,
                                          d.ctarifa, d.pinttec, d.ftarifa, d.crevali, d.prevali,
                                          d.irevali, NULL, NULL, d.precarg, d.irecarg, d.cparben,
                                          d.cprepost, d.ffincob, NULL, d.provmat0, d.fprovmat0,
                                          d.provmat1, d.fprovmat1, d.pintmin, d.pdtocom,
                                          d.idtocom, d.ctarman, d.ipripur, d.ipriinv, d.itarrea,
                                          d.cagente, 3
                                     FROM detgaranseg d, garanseg g, estseguros s
                                    WHERE s.sseguro = vsolicit
                                      AND g.sseguro = s.ssegpol
                                      AND d.sseguro = g.sseguro
                                      AND d.nriesgo = g.nriesgo
                                      AND d.cgarant = g.cgarant
                                      AND d.nmovimi = g.nmovimi
                                      AND g.cgarant = 2105
                                      AND d.ndetgar = v_ndetgar_est
                                      AND g.ffinefe IS NULL);
                            END IF;
                         -- Bug 13832
                         ELSE
    -- v_ndetgar_real <> v_ndetgar_est -------> (v_ndetgar_real + 1) =  v_ndetgar_est
                            UPDATE estdetgaranseg
                               SET fvencim = DECODE(v_fvencim,
                                                    NULL, NULL,
                                                    0, NULL,
                                                    TO_DATE(v_fvencim, 'yyyymmdd')),
                                   ndurcob = v_ndurcob * 12,
                                   ctarifa = v_ctarifa,
                                   pinttec = v_pinttec,
                                   icapital = v_diferencia,
                                   ffincob = v_ffincob,
                                   pintmin = v_pintmin,
                                   cunica = 3,
                                   precarg = garan.primas.precarg,
                                   irecarg = garan.primas.irecarg,
                                   crevali = garan.crevali,
                                   prevali = garan.prevali,
                                   irevali = garan.irevali,
                                   pdtocom = garan.primas.pdtocom,
                                   idtocom = garan.primas.idtocom
                             WHERE sseguro = vsolicit
                               AND cgarant = garan.cgarant
                               AND nriesgo = pnriesgo
                               AND nmovimi = vnmovimi
                               AND ndetgar = v_ndetgar_est;

                            -- Bug 13832 - RSC - 01/07/2010 - APRS015 - suplemento de aportaciones unicas
                            IF garan.cgarant IN(2106) THEN
                               v_pi := pac_preguntas.ff_buscapregunpolseg(v_sseguro, 577, NULL);

                               UPDATE estdetgaranseg
                                  SET icapital =(v_diferencia / v_pi)
                                WHERE sseguro = vsolicit
                                  AND cgarant = 2105
                                  AND nriesgo = pnriesgo
                                  AND nmovimi = vnmovimi
                                  AND ndetgar = v_ndetgar_est;
                            END IF;
                         -- Bug 13832
                         END IF;
                      END IF;

                      -- Ponemos el resto de detalle para que no tarifen! (cunica = 1 no tarifa)
                      UPDATE estdetgaranseg
                         SET cunica = 2
                       WHERE sseguro = vsolicit
                         AND cunica NOT IN(1, 3);
                   -- cunica = 1 --> Aportacion extra. Estas se deben quedar como estan!
                   ELSIF garan.icapital = v_cap_totreal THEN   -- v_capgar THEN
                      v_modificacio := FALSE;

                      UPDATE estgaranseg g
                         SET icapital = NVL(vcapital, garan.icapital),
                             icaptot = NVL(vcapital, garan.icapital)
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL;

                      UPDATE estdetgaranseg
                         SET cunica = 2
                       WHERE sseguro = vsolicit
                         AND cgarant = garan.cgarant
                         AND nriesgo = pnriesgo
                         AND nmovimi = vnmovimi
                         AND cunica <> 1;

                      -- Bug 13832 - RSC - 01/07/2010 - APRS015 - suplemento de aportaciones unicas
                      IF garan.cgarant IN(2106) THEN
                         v_pi := pac_preguntas.ff_buscapregunpolseg(v_sseguro, 577, NULL);

                         UPDATE estgaranseg g
                            SET icapital =(NVL(vcapital, garan.icapital) / v_pi),
                                icaptot =(NVL(vcapital, garan.icapital) / v_pi)
                          WHERE g.sseguro = vsolicit
                            AND g.nriesgo = pnriesgo
                            AND g.cgarant = 2105
                            AND g.ffinefe IS NULL;

                         UPDATE estdetgaranseg
                            SET cunica = 2
                          WHERE sseguro = vsolicit
                            AND cgarant = 2105
                            AND nriesgo = pnriesgo
                            AND nmovimi = vnmovimi
                            AND cunica <> 1;
                      END IF;
                   -- Bug 13832
                   ELSE
                      NULL;
                   END IF;
                END IF;

                -- ACRI A
                SELECT COUNT(*)
                  INTO v_gar_tarif_dep
                  FROM garanseg g, estseguros s
                 WHERE s.sseguro = vsolicit
                   AND s.ssegpol = g.sseguro
                   AND g.cgarant = 2113
                   AND g.ffinefe IS NULL;

                IF v_gar_tarif_dep > 0 THEN   -- ACRI B contratada !
                   IF v_modificacio THEN
                      DELETE FROM estdetgaranseg
                            WHERE sseguro = vsolicit
                              AND cgarant = 2113;

                      INSERT INTO estdetgaranseg
                                  (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar, fefecto,
                                   fvencim, ndurcob, ctarifa, pinttec, ftarifa, crevali, prevali,
                                   irevali, icapital, iprianu, precarg, irecarg, cparben, cprepost,
                                   ffincob, ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
                                   pintmin, pdtocom, idtocom, ctarman, ipripur, ipriinv, itarrea,
                                   cagente, cunica)
                         (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                 d.ndetgar, d.fefecto, d.fvencim, d.ndurcob, d.ctarifa, d.pinttec,
                                 d.ftarifa, d.crevali, d.prevali, d.irevali, 0, 0, d.precarg,
                                 d.irecarg, d.cparben, d.cprepost, d.ffincob, 0, d.provmat0,
                                 d.fprovmat0, d.provmat1, d.fprovmat1, d.pintmin, d.pdtocom,
                                 d.idtocom, d.ctarman, d.ipripur, d.ipriinv, d.itarrea, d.cagente,
                                 3
                            FROM detgaranseg d, garanseg g, estseguros s
                           WHERE s.sseguro = vsolicit
                             AND g.sseguro = s.ssegpol
                             AND d.sseguro = g.sseguro
                             AND d.nriesgo = g.nriesgo
                             AND d.cgarant = g.cgarant
                             AND d.nmovimi = g.nmovimi
                             AND g.cgarant = 2113
                             AND g.ffinefe IS NULL);
                   END IF;
                END IF;

                -- ACRI C
                SELECT COUNT(*)
                  INTO v_gar_tarif_dep
                  FROM garanseg g, estseguros s
                 WHERE s.sseguro = vsolicit
                   AND s.ssegpol = g.sseguro
                   AND g.cgarant = 2115
                   AND g.ffinefe IS NULL;

                IF v_gar_tarif_dep > 0 THEN
                   IF v_modificacio THEN
                      DELETE FROM estdetgaranseg
                            WHERE sseguro = vsolicit
                              AND cgarant = 2115;

                      INSERT INTO estdetgaranseg
                                  (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar, fefecto,
                                   fvencim, ndurcob, ctarifa, pinttec, ftarifa, crevali, prevali,
                                   irevali, icapital, iprianu, precarg, irecarg, cparben, cprepost,
                                   ffincob, ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
                                   pintmin, pdtocom, idtocom, ctarman, ipripur, ipriinv, itarrea,
                                   cagente, cunica)
                         (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                 d.ndetgar, d.fefecto, d.fvencim, d.ndurcob, d.ctarifa, d.pinttec,
                                 d.ftarifa, d.crevali, d.prevali, d.irevali, 0, 0, d.precarg,
                                 d.irecarg, d.cparben, d.cprepost, d.ffincob, 0, d.provmat0,
                                 d.fprovmat0, d.provmat1, d.fprovmat1, d.pintmin, d.pdtocom,
                                 d.idtocom, d.ctarman, d.ipripur, d.ipriinv, d.itarrea, d.cagente,
                                 3
                            FROM detgaranseg d, garanseg g, estseguros s
                           WHERE s.sseguro = vsolicit
                             AND g.sseguro = s.ssegpol
                             AND d.sseguro = g.sseguro
                             AND d.nriesgo = g.nriesgo
                             AND d.cgarant = g.cgarant
                             AND d.nmovimi = g.nmovimi
                             AND g.cgarant = 2115
                             AND g.ffinefe IS NULL);
                   END IF;
                END IF;
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargarantia_modif_supl;

    -- Fin Bug 11735

       /*************************************************************************
          Grabar informacion de la garantia (suplementos economicos APRA).
          param in garan     : objeto garantia
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error

          Nota: FUNCION PROPIA DE APRA.
       *************************************************************************/
       -- Bug 11735 - RSC - 14/01/2010 - APR - suplemento de modificacion de capital /prima
       FUNCTION f_grabargarantia_baja(
          garan IN ob_iax_garantias,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabargarantia_baja';
          vcapital       NUMBER;
          -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
          v_sproduc      seguros.sproduc%TYPE;
          v_fvencim      pregungaranseg.crespue%TYPE;
          v_ndurcob      pregungaranseg.crespue%TYPE;
          v_ffincob      detgaranseg.ffincob%TYPE;
          v_cactivi      seguros.cactivi%TYPE;
          v_pinttec      NUMBER;
          v_pintmin      NUMBER;
          v_cagente      seguros.cagente%TYPE;
          v_nmovimi      garanseg.nmovimi%TYPE;
          v_pregs        t_iax_preguntas;
          v_cramo        seguros.cramo%TYPE;
          v_cmodali      seguros.cmodali%TYPE;
          v_ctipseg      seguros.ctipseg%TYPE;
          v_ccolect      seguros.ccolect%TYPE;
          v_cobliga      estgaranseg.cobliga%TYPE;
          -- Fin Bug 10757

          -- Bug 11735 - RSC - 10/01/2010 - APR - suplemento de modificacion de capital /prima
          v_csituac      estseguros.csituac%TYPE;
          v_num_gar      NUMBER;
          v_ctarifa      estdetgaranseg.ctarifa%TYPE;
          -- Fin Bug 11735

          -- Bug 11735 - RSC - 10/01/2010 - APR - suplemento de modificacion de capital /prima
          v_gar_tarif_dep NUMBER;
          v_modificacio  BOOLEAN;
       -- Fin Bug 11735
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vpasexec := 7;
             -- Obtenemos la actividad del contrato
             vnumerr := pac_seguros.f_get_cactivi(vsolicit, NULL, NULL, 'EST', v_cactivi);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
             vnumerr := pac_seguros.f_get_sproduc(vsolicit, 'EST', v_sproduc);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- Fin Bug 10757
             SELECT COUNT(*)
               INTO v_num_gar
               FROM garanseg g, estseguros s
              WHERE s.sseguro = vsolicit
                AND s.ssegpol = g.sseguro
                AND g.cgarant = garan.cgarant
                AND g.ffinefe IS NULL;

    --------------------------
    ------- ESTGARANSEG ------
    --------------------------
             IF v_num_gar = 1 THEN   --->>>>>>>>>> Alta de garantia
                SELECT COUNT(*)
                  INTO vnum
                  FROM estgaranseg g
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant
                   AND g.ffinefe IS NULL;

                IF vnum > 0 THEN
                   vpasexec := 8;

                   --Ja existeix la garantia => La updategem.
                   UPDATE estgaranseg g
                      SET cobliga = garan.cobliga
                    WHERE g.sseguro = vsolicit
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ffinefe IS NULL;
                END IF;
             END IF;

             vpasexec := 10;
             --Gravem les preguntes de la garantia
             vnumerr := f_grabarpreguntasgarantia(garan.preguntas, pnriesgo, garan.cgarant,
                                                  mensajes);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             IF garan.cgarant NOT IN(2113, 2115) THEN
                UPDATE estdetgaranseg
                   SET cunica = 2
                 WHERE sseguro = vsolicit
                   AND nriesgo = pnriesgo
                   AND cgarant = garan.cgarant
                   AND nmovimi = vnmovimi
                   AND cunica <> 1;
             -- Bug 13832 - RSC - 17/06/2010 - APRS015 - suplemento de aportaciones unicas
             END IF;

    --------------------------
    ---- ESTDETGARANSEG ------
    --------------------------
             IF v_num_gar = 1 THEN   ---->>>>>>>>> Alta de garantia
                SELECT cramo, cmodali, ctipseg, ccolect
                  INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
                  FROM productos
                 WHERE sproduc = v_sproduc;

                SELECT COUNT(*)
                  INTO vnum
                  FROM estdetgaranseg d, estgaranseg g
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant
                   AND g.ffinefe IS NULL
                   AND d.sseguro = g.sseguro
                   AND d.cgarant = g.cgarant
                   AND d.nriesgo = g.nriesgo
                   AND d.finiefe = g.finiefe
                   AND d.ndetgar = garan.masdatos.ndetgar;

                --and g.finiefe = garan.finiefe;
                IF vnum > 0 THEN
                   -- Obtenemos la actividad del contrato
                   vnumerr := pac_seguros.f_get_cactivi(vsolicit, NULL, NULL, 'EST', v_cactivi);

                   IF vnumerr <> 0 THEN
                      RETURN vnumerr;
                   END IF;

                   IF garan.cobliga <> 1 THEN
                      DELETE      estgaranseg
                            WHERE sseguro = vsolicit
                              AND nriesgo = pnriesgo
                              AND cgarant = garan.cgarant
                              AND nmovimi = vnmovimi;

                      DELETE      estdetgaranseg
                            WHERE sseguro = vsolicit
                              AND nriesgo = pnriesgo
                              AND cgarant = garan.cgarant
                              AND nmovimi = vnmovimi;

                      IF garan.cgarant IN(2101, 2102, 2103) THEN
                         DELETE      estgaranseg
                               WHERE sseguro = vsolicit
                                 AND nriesgo = pnriesgo
                                 AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                     pac_seguros.ff_get_actividad(vsolicit,
                                                                                  pnriesgo, 'EST'),
                                                     cgarant, 'TIPO') = 3
                                 AND nmovimi = vnmovimi;

                         DELETE      estdetgaranseg
                               WHERE sseguro = vsolicit
                                 AND nriesgo = pnriesgo
                                 AND cgarant = garan.cgarant
                                 AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                                     pac_seguros.ff_get_actividad(vsolicit,
                                                                                  pnriesgo, 'EST'),
                                                     cgarant, 'TIPO') = 3
                                 AND nmovimi = vnmovimi;
                      END IF;

                      -- Borramos tambien las garantias dependientes
                      FOR gar IN (SELECT *
                                    FROM garanpro
                                   WHERE cgardep = garan.cgarant
                                     AND sproduc = v_sproduc
                                     AND cactivi = pac_seguros.ff_get_actividad(vsolicit, pnriesgo,
                                                                                'EST')) LOOP
                         DELETE      estgaranseg
                               WHERE sseguro = vsolicit
                                 AND nriesgo = pnriesgo
                                 AND cgarant = gar.cgarant
                                 AND nmovimi = vnmovimi;

                         DELETE      estdetgaranseg
                               WHERE sseguro = vsolicit
                                 AND nriesgo = pnriesgo
                                 AND cgarant = gar.cgarant
                                 AND nmovimi = vnmovimi;
                      END LOOP;

                      -- Bug 11735 - RSC - 12/05/2010 - APR - suplemento de modificacion de capital /prima
                      IF garan.cgarant IN(2101, 2102, 2103, 2108, 2109, 2110, 2112) THEN
                         -- ACRI A
                         SELECT COUNT(*)
                           INTO v_gar_tarif_dep
                           FROM garanseg g, estseguros s
                          WHERE s.sseguro = vsolicit
                            AND s.ssegpol = g.sseguro
                            AND g.cgarant IN(2113)
                            AND g.ffinefe IS NULL;

                         IF v_gar_tarif_dep > 0 THEN   -- ACRI B contratada !
                            --IF v_modificacio THEN
                            DELETE FROM estdetgaranseg
                                  WHERE sseguro = vsolicit
                                    AND cgarant IN(2113);

                            -- Bug 13832 - RSC - 17/06/2010 - APRS015 - suplemento de aportaciones unicas (cunica = 3)
                            INSERT INTO estdetgaranseg
                                        (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar,
                                         fefecto, fvencim, ndurcob, ctarifa, pinttec, ftarifa,
                                         crevali, prevali, irevali, icapital, iprianu, precarg,
                                         irecarg, cparben, cprepost, ffincob, ipritar, provmat0,
                                         fprovmat0, provmat1, fprovmat1, pintmin, pdtocom, idtocom,
                                         ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
                               (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                       d.ndetgar, d.fefecto, d.fvencim, d.ndurcob, d.ctarifa,
                                       d.pinttec, d.ftarifa, d.crevali, d.prevali, d.irevali, 0, 0,
                                       d.precarg, d.irecarg, d.cparben, d.cprepost, d.ffincob, 0,
                                       d.provmat0, d.fprovmat0, d.provmat1, d.fprovmat1, d.pintmin,
                                       d.pdtocom, d.idtocom, d.ctarman, d.ipripur, d.ipriinv,
                                       d.itarrea, d.cagente, 3
                                  FROM detgaranseg d, garanseg g, estseguros s
                                 WHERE s.sseguro = vsolicit
                                   AND g.sseguro = s.ssegpol
                                   AND d.sseguro = g.sseguro
                                   AND d.nriesgo = g.nriesgo
                                   AND d.cgarant = g.cgarant
                                   AND d.nmovimi = g.nmovimi
                                   AND g.cgarant = 2113
                                   AND g.ffinefe IS NULL);
                         --END IF;
                         END IF;

                         -- ACRI C
                         SELECT COUNT(*)
                           INTO v_gar_tarif_dep
                           FROM garanseg g, estseguros s
                          WHERE s.sseguro = vsolicit
                            AND s.ssegpol = g.sseguro
                            AND g.cgarant IN(2115)
                            AND g.ffinefe IS NULL;

                         IF v_gar_tarif_dep > 0 THEN
                            --IF v_modificacio THEN
                            DELETE FROM estdetgaranseg
                                  WHERE sseguro = vsolicit
                                    AND cgarant IN(2115);

                            -- Bug 13832 - RSC - 17/06/2010 - APRS015 - suplemento de aportaciones unicas (cunica = 3)
                            INSERT INTO estdetgaranseg
                                        (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar,
                                         fefecto, fvencim, ndurcob, ctarifa, pinttec, ftarifa,
                                         crevali, prevali, irevali, icapital, iprianu, precarg,
                                         irecarg, cparben, cprepost, ffincob, ipritar, provmat0,
                                         fprovmat0, provmat1, fprovmat1, pintmin, pdtocom, idtocom,
                                         ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
                               (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                       d.ndetgar, d.fefecto, d.fvencim, d.ndurcob, d.ctarifa,
                                       d.pinttec, d.ftarifa, d.crevali, d.prevali, d.irevali, 0, 0,
                                       d.precarg, d.irecarg, d.cparben, d.cprepost, d.ffincob, 0,
                                       d.provmat0, d.fprovmat0, d.provmat1, d.fprovmat1, d.pintmin,
                                       d.pdtocom, d.idtocom, d.ctarman, d.ipripur, d.ipriinv,
                                       d.itarrea, d.cagente, 3
                                  FROM detgaranseg d, garanseg g, estseguros s
                                 WHERE s.sseguro = vsolicit
                                   AND g.sseguro = s.ssegpol
                                   AND d.sseguro = g.sseguro
                                   AND d.nriesgo = g.nriesgo
                                   AND d.cgarant = g.cgarant
                                   AND d.nmovimi = g.nmovimi
                                   AND g.cgarant = 2115
                                   AND g.ffinefe IS NULL);
                         --END IF;
                         END IF;
                      END IF;
                   -- Fin Bug 11735
                   END IF;
                END IF;
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargarantia_baja;

        /*************************************************************************
          Grabar informacion de la garantia (suplementos economicos APRA).
          param in garan     : objeto garantia
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error

          Nota: FUNCION PROPIA DE APRA.
       *************************************************************************/
       -- Bug 13832 - RSC - 09/06/2010 - APRS015 - suplemento de aportaciones unicas
       FUNCTION f_grabargarantia_modif(
          garan IN ob_iax_garantias,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes,
          pcmotmov IN NUMBER)
          RETURN NUMBER IS
          v_res          NUMBER;
       BEGIN
          IF pac_md_produccion.f_bloqueo_grabarobjectodb(pac_iax_produccion.vsseguro, pcmotmov,
                                                         mensajes) = 1 THEN
             v_res := f_grabargarantia_extra(garan, pnriesgo, mensajes, pcmotmov);
          ELSE
             v_res := f_grabargarantia_modif_supl(garan, pnriesgo, mensajes, pcmotmov);
          END IF;

          RETURN v_res;
       END f_grabargarantia_modif;

       -- Fin bug 13832

       /*************************************************************************
          Grabar informacion de la garantia (suplementos economicos APRA).
          param in garan     : objeto garantia
          param in pnriesgo  : numero de riesgo
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error

          Nota: FUNCION PROPIA DE APRA.
       *************************************************************************/
       -- Bug 13832 - RSC - 09/06/2010 - APRS015 - suplemento de aportaciones unicas
       FUNCTION f_grabargarantia_extra(
          garan IN ob_iax_garantias,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes,
          -- Bug 13832 - RSC - 08/06/2010 - APRS015 - suplemento de aportaciones unicas)
          pcmotmov IN NUMBER)
          -- Fin Bug 13832
       RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabargarantia_extra';
          vcapital       NUMBER;
          -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emision
          v_sproduc      seguros.sproduc%TYPE;
          v_fvencim      pregungaranseg.crespue%TYPE;
          v_ndurcob      pregungaranseg.crespue%TYPE;
          v_ffincob      detgaranseg.ffincob%TYPE;
          v_cactivi      seguros.cactivi%TYPE;
          v_pinttec      NUMBER;
          v_pintmin      NUMBER;
          v_cagente      seguros.cagente%TYPE;
          v_nmovimi      garanseg.nmovimi%TYPE;
          v_pregs        t_iax_preguntas;
          v_cramo        seguros.cramo%TYPE;
          v_cmodali      seguros.cmodali%TYPE;
          v_ctipseg      seguros.ctipseg%TYPE;
          v_ccolect      seguros.ccolect%TYPE;
          v_cobliga      estgaranseg.cobliga%TYPE;
          -- Fin Bug 10757

          -- Bug 11735 - RSC - 14/01/2010 - APR - suplemento de modificacion de capital /prima
          v_csituac      estseguros.csituac%TYPE;
          v_num_gar      NUMBER;
          v_ctarifa      estdetgaranseg.ctarifa%TYPE;
          v_capgar       NUMBER;
          v_iprianu      NUMBER;
          v_diferencia   NUMBER;
          v_ndetgar      NUMBER;
          v_ndetgar_real NUMBER;
          v_ndetgar_est  NUMBER;
          v_ctipcap      garanpro.ctipcap%TYPE;
          v_sum_capital  NUMBER;
          v_sum_iprianu  NUMBER;
          v_idetalle     NUMBER;
          v_final        BOOLEAN := FALSE;
          v_ireducc      NUMBER;
          v_cap_totreal  NUMBER;
          v_ipri_totreal NUMBER;
          v_sseguro      estseguros.ssegpol%TYPE;
          v_gar_real     BOOLEAN := TRUE;
          -- Fin Bug 11735

          -- Bug 11735 - RSC - 11/05/2010 - APR - suplemento de modificacion de capital /prima
          v_gar_tarif_dep NUMBER;
          v_ndetgar_mod  NUMBER;
          v_modificacio  BOOLEAN := FALSE;
       -- Fin Bug 11735
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --  Bug 10898 - 19/08/2009 - JRH - Mantener Capitales migrados en productos de salud al realizar suplemento
             IF garan.ctipo IN(8, 9, 5, 6)
                OR(NVL(garan.ctipo, 0) = 0
                   AND NVL(garan.cobliga, 0) <> 0) THEN
                 --Si no da problemas en los capitales calculados si icapital=null
                --  fi Bug 10898 - 19/08/2009 - JRH
                   --JRH Le ponemos informado el capital para que no se queje el pk_nuevaproduccion (que diga que es nula la prima). Pero habriamos de tocar el Pk_nuevaproduccion.
                IF garan.icapital IS NULL THEN
                   vcapital := 0;
    --JRH Le ponemos informado el capital para que no se queje el pk_nuevaproduccion (que diga que es nula la prima). Pero habriamos de tocar el Pk_nuevaproduccion.
                ELSE
                   vcapital := garan.icapital;
                END IF;
             ELSE   --JRH Asi nos tarifica y calcula primas y capitales
                vcapital := NULL;
             END IF;

             -- Obtenemos el sseguro real
             vpasexec := 11;

             SELECT ssegpol
               INTO v_sseguro
               FROM estseguros
              WHERE sseguro = vsolicit;

             vpasexec := 12;
             -- Obtenemos la actividad del contrato
             vnumerr := pac_seguros.f_get_cactivi(vsolicit, NULL, NULL, 'EST', v_cactivi);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             vpasexec := 13;
             vnumerr := pac_seguros.f_get_sproduc(vsolicit, 'EST', v_sproduc);

             IF vnumerr <> 0 THEN
                RETURN vnumerr;
             END IF;

             -- Obtenemos el CTIPCAP de la garantia
             vpasexec := 14;

             SELECT ctipcap
               INTO v_ctipcap
               FROM garanpro
              WHERE sproduc = v_sproduc
                AND cgarant = garan.cgarant;

             vpasexec := 15;

             SELECT cramo, cmodali, ctipseg, ccolect
               INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
               FROM productos
              WHERE sproduc = v_sproduc;

             --Obtenemos la fecha de vencimiento de la garantia
             IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                    garan.cgarant, 'TIPO'),
                    0) NOT IN(3, 4)
                AND garan.cobliga = 1 THEN
    -------------------------------
    -- Valores de inicializacion --
    -------------------------------
                vpasexec := 16;
                vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant, pnriesgo,
                                                              1043, 'EST', v_fvencim);

                IF vnumerr <> 0 THEN
                   IF vnumerr <> 120135 THEN
                      RETURN vnumerr;
                   ELSE
                      SELECT TO_NUMBER(TO_CHAR(fvencim, 'yyyymmdd'))
                        INTO v_fvencim
                        FROM estseguros
                       WHERE sseguro = vsolicit;
                   END IF;
                END IF;

                -- Obtenemos la fecha fin de pagos
                IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(2) THEN
                   vpasexec := 17;
                   vnumerr := pac_preguntas.f_get_pregungaranseg(vsolicit, garan.cgarant,
                                                                 pnriesgo, 1049, 'EST', v_ndurcob);

                   IF vnumerr <> 0 THEN
                      IF vnumerr <> 120135 THEN
                         RETURN vnumerr;
                      ELSE
                         SELECT ndurcob
                           INTO v_ndurcob
                           FROM estseguros
                          WHERE sseguro = vsolicit;
                      END IF;
                   END IF;

                   v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob * 12);
                -- Fecha fin de pagos
                ELSE
                   IF v_fvencim IS NOT NULL
                      AND v_fvencim <> 0 THEN
                      SELECT MONTHS_BETWEEN(TO_DATE(v_fvencim, 'YYYYMMDD'), garan.finiefe)
                        INTO v_ndurcob
                        FROM DUAL;

                      v_ffincob := ADD_MONTHS(garan.finiefe, v_ndurcob);
                      -- Fecha fin de pagos
                      v_ndurcob := v_ndurcob / 12;
                   END IF;
                END IF;

                vpasexec := 18;
                --v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_VIGENTE');
                v_ctarifa := f_parproductos_v(v_sproduc, 'CTARIFA_APORTEXTRA');

                -- Bug 17105 - APD - 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
                -- Si el producto es GROUPLIFE, v_pinttec se obtiene de la
                -- pregunta 133 y su respuesta
                IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                   AND NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
                   vpasexec := 19;
                   v_pinttec := vtramo(NULL,
                                       vtramo(NULL,
                                              NVL(f_parproductos_v(v_sproduc, 'TRAMO_INTERES'), 0),
                                              v_ctarifa),
                                       garan.cgarant);   -- Interes (Tarifa)
                ELSE   -- sino, tal y como se esta obteniedo hasta ahora
                   vpasexec := 19;
                   v_pinttec := pac_inttec.ff_int_gar_seg('EST', vsolicit, garan.cgarant);
                -- Interes (Tarifa)
                END IF;

                -- fin Bug 17105
                v_pintmin := pac_inttec.ff_int_gar_prod(v_sproduc, v_cactivi, garan.cgarant, 1,
                                                        f_sysdate, 0);   -- Interes minimo (Tarifa)
                -- Obtenemos el agente
                vpasexec := 20;
                vnumerr := pac_seguros.f_get_cagente(vsolicit, 'EST', v_cagente);

                IF vnumerr <> 0 THEN
                   RETURN vnumerr;
                END IF;

                --Gravem les preguntes de la garantia
                vpasexec := 21;
                vnumerr := f_grabarpreguntasgarantia(garan.preguntas, pnriesgo, garan.cgarant,
                                                     mensajes);

                IF vnumerr <> 0 THEN
                   RETURN vnumerr;
                END IF;

    -------------------------------
    -- Tratamiento de detalle    --
    -------------------------------
                vpasexec := 22;

                SELECT SUM(NVL(g.icapital, 0)), SUM(NVL(g.iprianu, 0))
                  INTO v_capgar, v_iprianu
                  FROM estdetgaranseg g
                 WHERE g.sseguro = vsolicit
                   AND g.nriesgo = pnriesgo
                   AND g.cgarant = garan.cgarant;

                vpasexec := 23;

                BEGIN
                   SELECT g.icapital, g.iprianu
                     INTO v_cap_totreal, v_ipri_totreal
                     FROM garanseg g, estseguros s
                    WHERE s.sseguro = vsolicit
                      AND g.sseguro = s.ssegpol
                      AND g.nriesgo = pnriesgo
                      AND g.cgarant = garan.cgarant
                      AND g.ffinefe IS NULL;

                   v_gar_real := TRUE;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      -- Puede darse el caso que encadenemos Alta de garantias con Modificacion
                      -- en este caso la garantia o garantias que hemos dados de alta antes no se
                      -- encuentran en real.
                      v_gar_real := FALSE;

                      SELECT g.icapital, g.iprianu
                        INTO v_cap_totreal, v_ipri_totreal
                        FROM estgaranseg g
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL;
                END;

                -- Borrado - Insertado
                IF v_gar_real THEN
                   IF garan.cgarant NOT IN(2113, 2115) THEN
                      DELETE FROM estdetgaranseg
                            WHERE sseguro = vsolicit
                              AND cgarant = garan.cgarant;

                      INSERT INTO estdetgaranseg
                                  (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar, fefecto,
                                   fvencim, ndurcob, ctarifa, pinttec, ftarifa, crevali, prevali,
                                   irevali, icapital, iprianu, precarg, irecarg, cparben, cprepost,
                                   ffincob, ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
                                   pintmin, pdtocom, idtocom, ctarman, ipripur, ipriinv, itarrea,
                                   cagente, cunica)
                         (SELECT d.cgarant, d.nriesgo, vnmovimi, vsolicit, garan.finiefe,
                                 d.ndetgar, d.fefecto, d.fvencim, d.ndurcob, d.ctarifa, d.pinttec,
                                 d.ftarifa, d.crevali, d.prevali, d.irevali, d.icapital, d.iprianu,
                                 d.precarg, d.irecarg, d.cparben, d.cprepost, d.ffincob, d.ipritar,
                                 d.provmat0, d.fprovmat0, d.provmat1, d.fprovmat1, d.pintmin,
                                 d.pdtocom, d.idtocom, d.ctarman, d.ipripur, d.ipriinv, d.itarrea,
                                 d.cagente, d.cunica
                            FROM detgaranseg d, garanseg g, estseguros s
                           WHERE s.sseguro = vsolicit
                             AND g.sseguro = s.ssegpol
                             AND d.sseguro = g.sseguro
                             AND d.nriesgo = g.nriesgo
                             AND d.cgarant = g.cgarant
                             AND d.nmovimi = g.nmovimi
                             AND g.cgarant = garan.cgarant
                             AND g.ffinefe IS NULL);
                   END IF;
                END IF;

                vpasexec := 23;

                IF v_ctipcap = 5 THEN
                   IF garan.esextra = 1 THEN
                      --IF garan.primas.iprianu > v_ipri_totreal THEN   -- Aumento de prima
                      v_modificacio := TRUE;
    ----------------------
    -- Aumento de prima --
                      v_diferencia := garan.primas.iprianu;   --v_iprianu;
                      vpasexec := 2;

                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_real
                        FROM detgaranseg d, garanseg g, estseguros s
                       WHERE s.sseguro = vsolicit
                         AND g.sseguro = s.ssegpol
                         AND g.nriesgo = pnriesgo
                         AND g.ffinefe IS NULL
                         AND g.sseguro = d.sseguro
                         AND g.cgarant = d.cgarant
                         AND g.nriesgo = d.nriesgo
                         AND g.nmovimi = d.nmovimi
                         AND g.cgarant = garan.cgarant;

                      -- Obtenemos el maximo detalle
                      vpasexec := 4;

                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_est
                        FROM estdetgaranseg d, estgaranseg g
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL
                         AND d.sseguro = g.sseguro
                         AND d.cgarant = g.cgarant
                         AND d.nriesgo = g.nriesgo
                         AND d.nmovimi = g.nmovimi;

                      IF v_ndetgar_real = v_ndetgar_est THEN
                         vpasexec := 5;

                         INSERT INTO estdetgaranseg
                                     (sseguro, cgarant, nriesgo, nmovimi, finiefe,
                                      ndetgar, fefecto,
                                      fvencim,
                                      ndurcob, ctarifa, pinttec, ftarifa, crevali,
                                      prevali, irevali, icapital, iprianu,
                                      precarg, irecarg, cparben, cprepost,
                                      ffincob, ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
                                      pintmin, pdtocom, idtocom,
                                      ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
                              VALUES (vsolicit, garan.cgarant, pnriesgo, vnmovimi, garan.finiefe,
                                      (v_ndetgar_est + 1), garan.finiefe,
                                      DECODE(v_fvencim,
                                             NULL, NULL,
                                             0, NULL,
                                             TO_DATE(v_fvencim, 'yyyymmdd')),
                                      v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe, 0,
                                      garan.prevali, garan.irevali, NULL, v_diferencia,
                                      garan.primas.precarg, garan.primas.irecarg, NULL, NULL,
                                      v_ffincob, v_diferencia, NULL, NULL, NULL, NULL,
                                      v_pintmin, garan.primas.pdtocom, garan.primas.idtocom,
                                      NULL, v_diferencia, NULL, NULL, v_cagente, 3);   -- Cunica = 3
                      ELSE
    -- v_ndetgar_real <> v_ndetgar_est -------> (v_ndetgar_real + 1) =  v_ndetgar_est
                         vpasexec := 6;

                         UPDATE estdetgaranseg
                            SET fvencim = DECODE(v_fvencim,
                                                 NULL, NULL,
                                                 0, NULL,
                                                 TO_DATE(v_fvencim, 'yyyymmdd')),
                                ndurcob = v_ndurcob * 12,
                                ctarifa = v_ctarifa,
                                pinttec = v_pinttec,
                                iprianu = v_diferencia,
                                ipritar = v_diferencia,
                                ffincob = v_ffincob,
                                pintmin = v_pintmin,
                                cunica = 3,
                                precarg = garan.primas.precarg,
                                irecarg = garan.primas.irecarg,
                                crevali = 0,   -- Las unicas no deben revalorizar
                                prevali = garan.prevali,
                                irevali = garan.irevali,
                                pdtocom = garan.primas.pdtocom,
                                idtocom = garan.primas.idtocom,
                                ipripur = v_diferencia
                          WHERE sseguro = vsolicit
                            AND cgarant = garan.cgarant
                            AND nriesgo = pnriesgo
                            AND nmovimi = vnmovimi
                            AND ndetgar = v_ndetgar_est;
                      END IF;

                      -- Ponemos el resto de detalle para que no tarifen! (cunica = 1 no tarifa)
                      vpasexec := 7;

                      UPDATE estdetgaranseg
                         SET cunica = 2
                       WHERE sseguro = vsolicit
                         AND cunica NOT IN(1, 3);
                   -- cunica = 1 --> Aportacion extra. Estas se deben quedar como estan!
                   END IF;
                ELSE
                   IF garan.esextra = 1 THEN
                      --IF garan.icapital > v_cap_totreal THEN   --v_capgar THEN
                      v_modificacio := TRUE;
    ------------------------
    -- Aumento de capital --
    ------------------------
                      v_diferencia := NVL(vcapital, garan.icapital);   --v_capgar;

                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_real
                        FROM detgaranseg d, garanseg g, estseguros s
                       WHERE s.sseguro = vsolicit
                         AND g.sseguro = s.ssegpol
                         AND g.nriesgo = pnriesgo
                         AND g.ffinefe IS NULL
                         AND g.sseguro = d.sseguro
                         AND g.cgarant = d.cgarant
                         AND g.nriesgo = d.nriesgo
                         AND g.nmovimi = d.nmovimi
                         AND g.cgarant = garan.cgarant;

                      -- Obtenemos el maximo detalle
                      SELECT MAX(ndetgar)
                        INTO v_ndetgar_est
                        FROM estdetgaranseg d, estgaranseg g
                       WHERE g.sseguro = vsolicit
                         AND g.nriesgo = pnriesgo
                         AND g.cgarant = garan.cgarant
                         AND g.ffinefe IS NULL
                         AND d.sseguro = g.sseguro
                         AND d.cgarant = g.cgarant
                         AND d.nriesgo = g.nriesgo
                         AND d.nmovimi = g.nmovimi;

                      IF v_ndetgar_real = v_ndetgar_est THEN
                         INSERT INTO estdetgaranseg
                                     (sseguro, cgarant, nriesgo, nmovimi, finiefe,
                                      ndetgar, fefecto,
                                      fvencim,
                                      ndurcob, ctarifa, pinttec, ftarifa, crevali,
                                      prevali, irevali, icapital, iprianu,
                                      precarg, irecarg, cparben, cprepost,
                                      ffincob, ipritar, provmat0, fprovmat0, provmat1, fprovmat1,
                                      pintmin, pdtocom, idtocom,
                                      ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
                              VALUES (vsolicit, garan.cgarant, pnriesgo, vnmovimi, garan.finiefe,
                                      (v_ndetgar_est + 1), garan.finiefe,
                                      DECODE(v_fvencim,
                                             NULL, NULL,
                                             0, NULL,
                                             TO_DATE(v_fvencim, 'yyyymmdd')),
                                      v_ndurcob * 12, v_ctarifa, v_pinttec, garan.finiefe, 0,
                                      garan.prevali, garan.irevali, v_diferencia, NULL,
                                      garan.primas.precarg, garan.primas.irecarg, NULL, NULL,
                                      v_ffincob, NULL, NULL, NULL, NULL, NULL,
                                      v_pintmin, garan.primas.pdtocom, garan.primas.idtocom,
                                      NULL, NULL, NULL, NULL, v_cagente, 3);   -- Cunica = 3
                      ELSE
    -- v_ndetgar_real <> v_ndetgar_est -------> (v_ndetgar_real + 1) =  v_ndetgar_est
                         UPDATE estdetgaranseg
                            SET fvencim = DECODE(v_fvencim,
                                                 NULL, NULL,
                                                 0, NULL,
                                                 TO_DATE(v_fvencim, 'yyyymmdd')),
                                ndurcob = v_ndurcob * 12,
                                ctarifa = v_ctarifa,
                                pinttec = v_pinttec,
                                icapital = v_diferencia,
                                ffincob = v_ffincob,
                                pintmin = v_pintmin,
                                cunica = 3,
                                precarg = garan.primas.precarg,
                                irecarg = garan.primas.irecarg,
                                crevali = 0,   -- Las unicas no deben revalorizar
                                prevali = garan.prevali,
                                irevali = garan.irevali,
                                pdtocom = garan.primas.pdtocom,
                                idtocom = garan.primas.idtocom
                          WHERE sseguro = vsolicit
                            AND cgarant = garan.cgarant
                            AND nriesgo = pnriesgo
                            AND nmovimi = vnmovimi
                            AND ndetgar = v_ndetgar_est;
                      END IF;

                      -- Ponemos el resto de detalle para que no tarifen! (cunica = 1 no tarifa)
                      UPDATE estdetgaranseg
                         SET cunica = 2
                       WHERE sseguro = vsolicit
                         AND cunica NOT IN(1, 3);
                   -- cunica = 1 --> Aportacion extra. Estas se deben quedar como estan!
                   END IF;
                END IF;
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargarantia_extra;

    /*************************************************************************
          Grabar los el cuadro de prestamos
          param in saldodeutors  : col. t_iax_prestcuadroseg
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarprestcuadroseg(
          pprestcuadroseg IN t_iax_prestcuadroseg,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabarprestcuadroseg';
          vnumerr        NUMBER;
       BEGIN
          IF pprestcuadroseg IS NOT NULL
             AND pprestcuadroseg.COUNT > 0 THEN
             FOR i IN pprestcuadroseg.FIRST .. pprestcuadroseg.LAST LOOP
                vpasexec := 6;

                IF pprestcuadroseg.EXISTS(i) THEN
                   vpasexec := 7;

                   IF vpmode = 'EST' THEN
                      vpasexec := 11;

                      BEGIN
                         INSERT INTO estprestcuadroseg
                                     (ctapres, sseguro,
                                      nmovimi,
                                      finicuaseg,
                                      ffincuaseg, fefecto,
                                      fvencim, icapital,
                                      iinteres, icappend,
                                      falta)
                              VALUES (pprestcuadroseg(i).ctapres, vsolicit,
                                      NVL(pprestcuadroseg(i).nmovimi, 1),
                                      pprestcuadroseg(i).finicuaseg,
                                      pprestcuadroseg(i).ffincuaseg, pprestcuadroseg(i).fefecto,
                                      pprestcuadroseg(i).fvencim, pprestcuadroseg(i).icapital,
                                      pprestcuadroseg(i).iinteres, pprestcuadroseg(i).icappend,
                                      pprestcuadroseg(i).falta);
                      EXCEPTION
                         WHEN DUP_VAL_ON_INDEX THEN
                            UPDATE estprestcuadroseg
                               SET finicuaseg = pprestcuadroseg(i).finicuaseg,
                                   ffincuaseg = pprestcuadroseg(i).ffincuaseg,
                                   fvencim = pprestcuadroseg(i).fvencim,
                                   icapital = pprestcuadroseg(i).icapital,
                                   iinteres = pprestcuadroseg(i).iinteres,
                                   icappend = pprestcuadroseg(i).icappend,
                                   falta = pprestcuadroseg(i).falta
                             WHERE sseguro = vsolicit
                               AND nmovimi = pprestcuadroseg(i).nmovimi
                               AND fefecto = pprestcuadroseg(i).fefecto
                               AND ctapres = pprestcuadroseg(i).ctapres;
                      END;
                   ELSE
                      BEGIN
                         INSERT INTO prestcuadroseg
                                     (ctapres, sseguro,
                                      nmovimi,
                                      finicuaseg,
                                      ffincuaseg, fefecto,
                                      fvencim, icapital,
                                      iinteres, icappend,
                                      falta)
                              VALUES (pprestcuadroseg(i).ctapres, vsolicit,
                                      NVL(pprestcuadroseg(i).nmovimi, 1),
                                      pprestcuadroseg(i).finicuaseg,
                                      pprestcuadroseg(i).ffincuaseg, pprestcuadroseg(i).fefecto,
                                      pprestcuadroseg(i).fvencim, pprestcuadroseg(i).icapital,
                                      pprestcuadroseg(i).iinteres, pprestcuadroseg(i).icappend,
                                      pprestcuadroseg(i).falta);
                      EXCEPTION
                         WHEN DUP_VAL_ON_INDEX THEN
                            UPDATE prestcuadroseg
                               SET finicuaseg = pprestcuadroseg(i).finicuaseg,
                                   ffincuaseg = pprestcuadroseg(i).ffincuaseg,
                                   fvencim = pprestcuadroseg(i).fvencim,
                                   icapital = pprestcuadroseg(i).icapital,
                                   iinteres = pprestcuadroseg(i).iinteres,
                                   icappend = pprestcuadroseg(i).icappend,
                                   falta = pprestcuadroseg(i).falta
                             WHERE sseguro = vsolicit
                               AND nmovimi = pprestcuadroseg(i).nmovimi
                               AND fefecto = pprestcuadroseg(i).fefecto
                               AND ctapres = pprestcuadroseg(i).ctapres;
                      END;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          RETURN 0;   --Tot ok
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarprestcuadroseg;

    /**************************************************************************/
       FUNCTION f_grabarreglassegtramos(
          reglas IN t_iax_reglassegtramos,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabarreglassegtramos';
          v_reglas       NUMBER;
       BEGIN
          IF reglas IS NULL THEN
             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vpasexec := 4;

             DELETE FROM estreglassegtramos
                   WHERE sseguro = reglas(reglas.FIRST).sseguro
                     AND nriesgo = reglas(reglas.FIRST).nriesgo
                     AND cgarant = reglas(reglas.FIRST).cgarant
                     AND nmovimi = vnmovimi;
          END IF;

          vpasexec := 11;

          FOR i IN reglas.FIRST .. reglas.LAST LOOP
             IF reglas.EXISTS(i) THEN
                INSERT INTO estreglassegtramos
                            (sseguro, nriesgo, cgarant, nmovimi,
                             edadini, edadfin, t1copagemp,
                             t1copagtra, t2copagemp, t2copagtra,
                             t3copagemp, t3copagtra, t4copagemp,
                             t4copagtra)
                     VALUES (reglas(i).sseguro, reglas(i).nriesgo, reglas(i).cgarant, vnmovimi,
                             reglas(i).edadini, reglas(i).edadfin, reglas(i).t1copagemp,
                             reglas(i).t1copagtra, reglas(i).t2copagemp, reglas(i).t2copagtra,
                             reglas(i).t3copagemp, reglas(i).t3copagtra, reglas(i).t4copagemp,
                             reglas(i).t4copagtra);
             END IF;
          END LOOP;

          RETURN 0;   --Tot ok
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarreglassegtramos;

       /*************************************************************************
          Grabar las reglas
          param in reglas  : objeto ob_iax_reglasseg
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       -- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementacion para el alta de colectivos
       FUNCTION f_grabarreglasseg(reglas IN ob_iax_reglasseg, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabarreglasseg';
          v_reglas       NUMBER;
       BEGIN
          IF reglas IS NULL THEN
             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vpasexec := 4;
          END IF;

          IF vpmode = 'EST' THEN
             vpasexec := 11;

             SELECT COUNT(*)
               INTO v_reglas
               FROM estreglasseg
              WHERE sseguro = reglas.sseguro
                AND nriesgo = reglas.nriesgo
                AND cgarant = reglas.cgarant
                AND nmovimi = vnmovimi;

    -- Bug 17341 - RSC - 02/02/2011 - APR703 - Suplemento de preguntas - FlexiLife
             IF v_reglas > 0 THEN
                UPDATE estreglasseg
                   SET capmaxemp = reglas.capmaxemp,
                       capminemp = reglas.capminemp,
                       capmaxtra = reglas.capmaxtra,
                       capmintra = reglas.capmintra
                 WHERE sseguro = reglas.sseguro
                   AND nriesgo = reglas.nriesgo
                   AND cgarant = reglas.cgarant
                   AND nmovimi = vnmovimi;
    -- Bug 17341 - RSC - 02/02/2011 - APR703 - Suplemento de preguntas - FlexiLife
             ELSE
                INSERT INTO estreglasseg
                            (sseguro, nriesgo, cgarant, nmovimi,
                             capmaxemp, capminemp, capmaxtra,
                             capmintra)
                     VALUES (vsolicit, reglas.nriesgo, reglas.cgarant, vnmovimi,
    -- Bug 17341 - RSC - 02/02/2011 - APR703 - Suplemento de preguntas - FlexiLife
                             reglas.capmaxemp, reglas.capminemp, reglas.capmaxtra,
                             reglas.capmintra);
             END IF;
          END IF;

          RETURN f_grabarreglassegtramos(reglas.reglassegtramos, mensajes);
       --Tot ok
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarreglasseg;

       /*************************************************************************
             F_GRABARDOCREQUERIDA
          Llama a la funcion PAC_DOCREQUERIDA.F_GRABARDOCREQUERIDA para insertar
          un registro en la tabla ESTDOCREQUERIDA, ESTDOCREQUERIDA_RIESGO o
          ESTDOCREQUERIDA_INQAVAL, dependiendo de la clase de documento que
          estamos insertando.
          param in pseqdocu                : numero secuencial de documento
          param in psproduc                : codigo de producto
          param in psseguro                : numero secuencial de seguro
          param in pcactivi                : codigo de actividad
          param in pnmovimi                : numero de movimiento
          param in pnriesgo                : numero de riesgo
          param in pninqaval               : numero de inquilino/avalista
          param in pcdocume                : codigo de documento
          param in pctipdoc                : tipo de documento
          param in pcclase                 : clase de documento
          param in pnorden                 : numero de orden documento
          param in ptdescrip               : descripcion del documento
          param in ptfilename              : nombre del fichero
          param in padjuntado              : indicador de fichero adjuntado
          param in out mensajes            : mensajes de error
          return                           : 0 todo correcto
                                             1 ha habido un error
       BUG 18351 - 11/05/2011 - JMP - Se crea la funcion
       *************************************************************************/
       FUNCTION f_grabardocrequerida(
          pseqdocu IN NUMBER,
          psproduc IN NUMBER,
          psseguro IN NUMBER,
          pcactivi IN NUMBER,
          pnmovimi IN NUMBER,
          pnriesgo IN NUMBER,
          pninqaval IN NUMBER,
          pcdocume IN NUMBER,
          pctipdoc IN NUMBER,
          pcclase IN NUMBER,
          pnorden IN NUMBER,
          ptdescrip IN VARCHAR2,
          ptfilename IN VARCHAR2,
          padjuntado IN NUMBER,
          psperson IN NUMBER,
          pctipben IN NUMBER,
          mensajes IN OUT t_iax_mensajes,
          pciddocgedox IN NUMBER DEFAULT NULL)
          RETURN NUMBER IS
          v_error        axis_literales.slitera%TYPE := 0;
          v_pasexec      NUMBER(3) := 1;
          v_object       VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabardocrequerida';
          v_param        VARCHAR2(500)
             := 'pseqdocu: ' || pseqdocu || ' - psproduc: ' || psproduc || ' - psseguro: '
                || psseguro || ' - pcactivi: ' || pcactivi || ' - pnmovimi: ' || pnmovimi
                || '- pnriesgo: ' || pnriesgo || ' - pninqaval: ' || pninqaval || ' - pctipben: '
                || pctipben;
       BEGIN
          -- BUG 28263/155705 - RCL - 04/11/2013 - Desarrollo modificaciones de iAxis para BPM
          v_error := pac_docrequerida.f_grabardocrequerida(pseqdocu, psproduc, psseguro, pcactivi,
                                                           pnmovimi, pnriesgo, pninqaval,
                                                           pcdocume, pctipdoc, pcclase, pnorden,
                                                           ptdescrip, ptfilename, padjuntado,
                                                           psperson, pctipben, pciddocgedox);

          IF v_error <> 0 THEN
             RAISE e_object_error;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabardocrequerida;

       -- Ini bug 19276, jbn, 19276
       /*************************************************************************
          Grabar los reemplazos de una poliza
          param in tomador   : Lista de  tomadores
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarreemplazos(reemplazos IN t_iax_reemplazos, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          numpd          NUMBER;
          nump           NUMBER;
          numtom         NUMBER;
          numdir         NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabarreemplazos';
       BEGIN
          IF reemplazos IS NOT NULL
             AND reemplazos.COUNT > 0 THEN
             -- Comprovacio pas de parametres correcte.
             IF vpmode <> 'EST' THEN
                RAISE e_param_error;
             ELSE
                --// ACC afegit q quan gravi primer borri
                vpasexec := 13;

                DELETE FROM estreemplazos
                      WHERE sseguro = vsolicit;

                vpasexec := 14;

                FOR i IN reemplazos.FIRST .. reemplazos.LAST LOOP
                   vpasexec := 15;

                   IF reemplazos.EXISTS(i) THEN
                      vpasexec := 16;

                      INSERT INTO estreemplazos
                                  (sseguro, sreempl,
                                   fmovdia, cusuario, cagente,
                                   ctipo)
                           VALUES (reemplazos(i).sseguro, reemplazos(i).sreempl,
                                   reemplazos(i).fmovdia, f_user, reemplazos(i).cagente,
                                   NVL(reemplazos(i).ctipo, 1));   --   BUG 24714 - JLTS - Se adiciona el campo CTIPO
                   END IF;
                END LOOP;
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarreemplazos;

    -- fi bug 19276, jbn, 19276

       -- BUG19069:DRA:27/09/2011:Inici
       FUNCTION f_grabarcorretaje(corretaje IN t_iax_corretaje, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          numcorr        NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarCorretaje';
       BEGIN
          vpasexec := 1;

          IF corretaje IS NULL THEN
             RETURN 0;
          END IF;

          vpasexec := 2;

          IF corretaje.COUNT = 0 THEN
             RETURN 0;
          END IF;

          vpasexec := 3;

          -- Comprovacio pas de parametres correcte.
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --// ACC afegit q quan gravi primer borri
             vpasexec := 4;

             DELETE FROM estage_corretaje
                   WHERE sseguro = vsolicit;

             vpasexec := 5;

             FOR i IN corretaje.FIRST .. corretaje.LAST LOOP
                vpasexec := 6;

                IF corretaje.EXISTS(i) THEN
                   vpasexec := 7;

                   SELECT COUNT(*)
                     INTO numcorr
                     FROM estage_corretaje t
                    WHERE t.nordage = corretaje(i).nordage
                      AND t.sseguro = vsolicit;

                   IF numcorr = 0 THEN
                      vpasexec := 8;

                      INSERT INTO estage_corretaje
                                  (sseguro, cagente, nmovimi,
                                   nordage, pcomisi, ppartici,
                                   islider)
                           VALUES (vsolicit, corretaje(i).cagente, NVL(vnmovimi, 1),
                                   corretaje(i).nordage, NULL,   --corretaje(i).pcomisi,
                                                              corretaje(i).ppartici,
                                   corretaje(i).islider);
                   ELSE
                      vpasexec := 9;

                      UPDATE estage_corretaje t
                         SET t.cagente = corretaje(i).cagente,
                             t.pcomisi = NULL,   --corretaje(i).pcomisi,
                             t.ppartici = corretaje(i).ppartici,
                             t.islider = corretaje(i).islider
                       WHERE t.nordage = corretaje(i).nordage
                         AND t.sseguro = vsolicit;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarcorretaje;

    -- BUG19069:DRA:27/09/2011:Fi

       /*************************************************************************
          Grabar el detalle de primas (DETPRIMAS de GARANSEG)
          param in detprimas   : Lista de detalle de primas
          param in nriesgo   : Numero de riesgo
          param in cgarant   : Codigo de la garantia
          param in finiefe   : Fecha inicio efecto garantia
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       -- Bug 21121 - APD - 01/03/2012 - se crea la funcion
       FUNCTION f_grabardetprimas(
          detprimas IN t_iax_detprimas,
          pnriesgo IN NUMBER,
          pcgarant IN NUMBER,
          pfiniefe IN DATE,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(200) := 'pnriesgo = ' || pnriesgo || ';pcgarant = ' || pcgarant;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_grabardetprimas';
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             DELETE      estdetprimas
                   WHERE cgarant = pcgarant
                     AND sseguro = vsolicit
                     AND nriesgo = pnriesgo
                     AND nmovimi = vnmovimi
                     AND finiefe = pfiniefe;

             IF detprimas IS NOT NULL THEN
                IF detprimas.COUNT > 0 THEN
                   FOR i IN detprimas.FIRST .. detprimas.LAST LOOP
                      vpasexec := 7;

                      BEGIN
                         INSERT INTO estdetprimas
                                     (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                                      ccampo, cconcep,
                                      norden, iconcep,
                                      iconcep2)
                              VALUES (vsolicit, pnriesgo, pcgarant, vnmovimi, pfiniefe,
                                      detprimas(i).ccampo, detprimas(i).cconcep,
                                      detprimas(i).norden, detprimas(i).iconcep,
                                      detprimas(i).iconcep2);
                      EXCEPTION
                         WHEN DUP_VAL_ON_INDEX THEN
                            UPDATE estdetprimas
                               SET iconcep = detprimas(i).iconcep,
                                   iconcep2 = detprimas(i).iconcep2,
                                   norden = detprimas(i).norden
                             WHERE sseguro = vsolicit
                               AND nriesgo = pnriesgo
                               AND cgarant = pcgarant
                               AND nmovimi = vnmovimi
                               AND finiefe = pfiniefe
                               AND ccampo = detprimas(i).ccampo
                               AND cconcep = detprimas(i).cconcep;
                      END;
                   END LOOP;
                END IF;
             END IF;

             vpasexec := 10;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabardetprimas;

    /*************************************************************************
          Grabar primas por garant?a (PRIMAS de GARANSEG)
          param in primas   : Objeto primas
          param in nriesgo   : Numero de riesgo
          param in cgarant   : Codigo de la garantia
          param in finiefe   : Fecha inicio efecto garantia
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/-- Bug 27014 - SHA - 26/07/2013 - se crea la funcion
       FUNCTION f_grabarprimasgaranseg(
          primas IN ob_iax_primas,
          pnriesgo IN NUMBER,
          pcgarant IN NUMBER,
          pfiniefe IN DATE,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(200) := 'pnriesgo = ' || pnriesgo || ';pcgarant = ' || pcgarant;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabarprimasgaranseg';
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             DELETE      estprimasgaranseg
                   WHERE cgarant = pcgarant
                     AND sseguro = vsolicit
                     AND nriesgo = pnriesgo
                     AND nmovimi = vnmovimi
                     AND finiefe = pfiniefe;

             IF primas IS NOT NULL THEN
                vpasexec := 7;

                BEGIN
                   INSERT INTO estprimasgaranseg
                               (sseguro, nmovimi, nriesgo, cgarant, finiefe, iextrap,
                                iprianu, ipritar, ipritot, precarg,
                                irecarg, pdtocom, idtocom, itarifa,
                                iconsor, ireccon, iips, idgs,
                                iarbitr, ifng, irecfra, itotpri,
                                itotdto, itotcon, itotimp, icderreg,
                                itotalr, needtarifar, iprireb,
                                itotanu, iiextrap, pdtotec, preccom,
                                idtotec, ireccom, itotrec,iivaimp,iprivigencia)
                        VALUES (vsolicit, vnmovimi, pnriesgo, pcgarant, pfiniefe, primas.iextrap,
                                primas.iprianu, primas.ipritar, primas.ipritot, primas.precarg,
                                primas.irecarg, primas.pdtocom, primas.idtocom, primas.itarifa,
                                primas.iconsor, primas.ireccon, primas.iips, primas.idgs,
                                primas.iarbitr, primas.ifng, primas.irecfra, primas.itotpri,
                                primas.itotdto, primas.itotcon, primas.itotimp, primas.icderreg,
                                primas.itotalr, primas.needtarifar, primas.iprireb,
                                primas.itotanu, primas.iiextrap, primas.pdtotec, primas.preccom,
                                primas.idtotec, primas.ireccom, primas.itotrec,primas.iivaimp,primas.iprivigencia);
                EXCEPTION
                   WHEN DUP_VAL_ON_INDEX THEN
                      UPDATE estprimasgaranseg
                         SET iextrap = primas.iextrap,
                             iprianu = primas.iprianu,
                             ipritar = primas.ipritar,
                             ipritot = primas.ipritot,
                             precarg = primas.precarg,
                             irecarg = primas.irecarg,
                             pdtocom = primas.pdtocom,
                             idtocom = primas.idtocom,
                             itarifa = primas.itarifa,
                             iconsor = primas.iconsor,
                             ireccon = primas.ireccon,
                             iips = primas.iips,
                             idgs = primas.idgs,
                             iarbitr = primas.iarbitr,
                             ifng = primas.ifng,
                             irecfra = primas.irecfra,
                             itotpri = primas.itotpri,
                             itotdto = primas.itotdto,
                             itotcon = primas.itotcon,
                             itotimp = primas.itotimp,
                             icderreg = primas.icderreg,
                             itotalr = primas.itotalr,
                             needtarifar = primas.needtarifar,
                             iprireb = primas.iprireb,
                             itotanu = primas.itotanu,
                             iiextrap = primas.iiextrap,
                             pdtotec = primas.pdtotec,
                             preccom = primas.preccom,
                             idtotec = primas.idtotec,
                             ireccom = primas.ireccom,
                             itotrec = primas.itotrec,
                             iivaimp = primas.iivaimp,
                             iprivigencia=primas.iprivigencia
                       WHERE cgarant = pcgarant
                         AND sseguro = vsolicit
                         AND nriesgo = pnriesgo
                         AND nmovimi = vnmovimi
                         AND finiefe = pfiniefe;
                END;
             END IF;

             vpasexec := 10;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarprimasgaranseg;

       /*************************************************************************
          Grabar los datos del gestor de cobro
          param in gestorcobro: objeto gestor cobro
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       -- BUG 0021592 - 08/03/2012 - JMF
       FUNCTION f_grabargescobro(gestorcobro IN t_iax_gescobros, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabargescobro';
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          numpd          NUMBER;
          nump           NUMBER;
          numtom         NUMBER;
          numdir         NUMBER;
          salir          EXCEPTION;
       BEGIN
          vpasexec := 100;

          IF gestorcobro IS NULL THEN
             -- Si el objeto esta vacio no grabamos nada.
             RAISE salir;
          END IF;

          IF gestorcobro.COUNT = 0 THEN
             -- Si el objeto esta vacio no grabamos nada.
             RAISE salir;
          END IF;

          -- Comprovacio pas de parametres correcte.
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vpasexec := 110;

             DELETE      estgescobros
                   WHERE sseguro = vsolicit;

             vpasexec := 120;

             FOR i IN gestorcobro.FIRST .. gestorcobro.LAST LOOP
                vpasexec := 130;

                IF gestorcobro.EXISTS(i) THEN
                   vpasexec := 140;

                   INSERT INTO estgescobros
                               (sseguro, sperson, cdomici, cusualt,
                                falta, cusuari, fmovimi)
                        VALUES (vsolicit, gestorcobro(i).sperson, gestorcobro(i).cdomici, f_user,
                                f_sysdate, NULL, NULL);
                END IF;
             END LOOP;
          END IF;

          vpasexec := 150;
          RETURN 0;
       EXCEPTION
          WHEN salir THEN
             DELETE      estgescobros
                   WHERE sseguro = vsolicit;

             RETURN 0;
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargescobro;

       -- FBL. 25/06/2014 MSV Bug 0028974
       -- Nueva función 28974 - MSV - 11/12/2013 - FBL
       -- Inserta en la tabla de detalle de comisiones el detalle de cada una de las comisiones definidas para la póliza.

       -- Fin FBL. 25/06/2014 MSV Bug 0028974

       -- bfp bug 21947 ini
       FUNCTION f_grabargaransegcom(
          pcomisgar IN t_iax_garansegcom,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          --nous
          dgaran         NUMBER := 0;
          dcom           NUMBER := 0;

          -- FBL. 25/06/2014 MSV Bug 0028974
          CURSOR c_seguro(vseguro NUMBER) IS
             SELECT *
               FROM estseguros
              WHERE sseguro = vseguro
                AND(ctipcom = 91
                    OR pac_parametros.f_parproducto_n(sproduc, 'AFECTA_COMISESPPROD') = 1);

          -- Fin FBL. 25/06/2014 MSV Bug 0028974
          CURSOR garanties(
             vcramo NUMBER,
             vcmodali NUMBER,
             vctipseg NUMBER,
             vccolect NUMBER,
             vcactivi NUMBER) IS
             SELECT *
               FROM estgaranseg
              WHERE cobliga = 1
                AND sseguro = vsolicit
                AND iprianu <> 0
                AND nriesgo = pnriesgo
                AND NVL(f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect, vcactivi, cgarant,
                                        'AFECTA_COMISESPECIAL'),
                        1) = 1;

          CURSOR comgar(
             vcramo NUMBER,
             vcmodali NUMBER,
             vctipseg NUMBER,
             vccolect NUMBER,
             vcactivi NUMBER,
             vcgarant NUMBER,
             vfecha DATE,
             pagente NUMBER) IS
             SELECT *
               FROM comisiongar cp
              WHERE cramo = vcramo   --rowestseguro.cramo
                AND cmodali = vcmodali   --rowestseguro.cmodali
                AND ctipseg = vctipseg   --rowestseguro.ctipseg
                AND ccolect = vccolect   --rowestseguro.ccolect
                AND cactivi = vcactivi   --rowestseguro.cactivi
                AND cgarant = vcgarant   --garanties(igaran).cgarant
                AND finivig = (SELECT finivig
                                 FROM comisionvig
                                WHERE ccomisi = cp.ccomisi
                                  AND cestado = 2
                                  AND TRUNC(vfecha) BETWEEN finivig AND NVL(ffinvig, TRUNC(vfecha)))
                AND cp.ccomisi = (SELECT ccomisi
                                    FROM agentes
                                   WHERE cagente = pagente);

          CURSOR comprod(
             vcramo NUMBER,
             vcmodali NUMBER,
             vctipseg NUMBER,
             vccolect NUMBER,
             vcactivi NUMBER,
             vfecha DATE,
             pagente NUMBER) IS
             SELECT *
               FROM comisionprod cp
              WHERE cramo = vcramo   --rowestseguro.cramo
                AND cmodali = vcmodali   --rowestseguro.cmodali
                AND ctipseg = vctipseg   --rowestseguro.ctipseg
                AND ccolect = vccolect   --rowestseguro.ccolect
                AND finivig = (SELECT finivig
                                 FROM comisionvig
                                WHERE ccomisi = cp.ccomisi
                                  AND cestado = 2
                                  AND TRUNC(vfecha) BETWEEN finivig AND NVL(ffinvig, TRUNC(vfecha)))
                AND cp.ccomisi = (SELECT ccomisi
                                    FROM agentes
                                   WHERE cagente = pagente);

          --de sempre
          vnumerr        NUMBER;
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GRABARGARANSEGCOM';
          vpcomisi       NUMBER;
          vpretenc       NUMBER;

          CURSOR c_grabar_comisiones(p_sseguro NUMBER, p_nriesgo NUMBER) IS
             SELECT eg.cgarant, eg.nmovimi, eg.ipricom, eg.finiefe, eg.nriesgo, eg.iprianu
               FROM estgaranseg eg, estseguros es
              WHERE eg.cobliga = 1
                AND eg.sseguro = p_sseguro
                AND eg.sseguro = es.sseguro
                AND eg.iprianu <> 0
                AND eg.nriesgo = p_nriesgo
                AND NVL(pac_parametros.f_parproducto_n(es.sproduc, 'AFECTA_COMISESPPROD'), 1) = 1;

          v_res          NUMBER;
          e_error_grabar_comisiones EXCEPTION;
    --      v_ipricom       NUMBER;
          v_parametros   VARCHAR2(4000);
       BEGIN
            -- FBL. 25/06/2014 MSV Bug 0028974
    --      IF pcomisgar IS NULL
    --         OR pcomisgar.COUNT <= 0 THEN
          FOR iseg IN c_seguro(vsolicit) LOOP
             dgaran := 1;

             FOR igaran IN garanties(iseg.cramo, iseg.cmodali, iseg.ctipseg, iseg.ccolect,
                                     iseg.cactivi) LOOP
                dcom := 0;

                FOR icom IN comgar(iseg.cramo, iseg.cmodali, iseg.ctipseg, iseg.ccolect,
                                   iseg.cactivi, igaran.cgarant, iseg.fefecto, iseg.cagente) LOOP
                   dcom := 1;
                   vpcomisi := icom.pcomisi;

                   BEGIN
                      IF NVL(pac_parametros.f_parproducto_n(icom.sproduc, 'AFECTA_COMISESPPROD'),
                             1) = 1 THEN
                         v_res :=
                            pac_comisiones.f_grabarcomisionmovimiento
                                                                     (p_cempres => iseg.cempres,
                                                                      p_sseguro => vsolicit,
                                                                      p_cgarant => icom.cgarant,
                                                                      p_nriesgo => pnriesgo,
                                                                      p_nmovimi => igaran.nmovimi,
                                                                      p_fecha => igaran.finiefe,
                                                                      p_modo => NULL   --'CAR'
                                                                                    ,
                                                                      p_ipricom => igaran.ipricom,
                                                                      p_cmodcom => icom.cmodcom,
                                                                      p_sproces => NULL,
                                                                      p_mensajes => mensajes);

                         IF v_res <> 0 THEN
                            RAISE e_error_grabar_comisiones;
                         END IF;
                      ELSE
                         INSERT INTO estgaransegcom
                                     (sseguro, nriesgo, cgarant, nmovimi,
                                      finiefe, cmodcom, ninialt, pcomisi, cmatch,
                                      tdesmat, pintfin, nfinalt, pcomisicua, ipricom)
                              VALUES (vsolicit, pnriesgo, igaran.cgarant, igaran.nmovimi,
                                      igaran.finiefe, icom.cmodcom, icom.ninialt, vpcomisi, NULL,
                                      NULL, NULL, icom.nfinalt, 1, igaran.ipricom);
                      END IF;
                   EXCEPTION
                      WHEN DUP_VAL_ON_INDEX THEN
                         NULL;
                   END;
                END LOOP;

                IF dcom = 0 THEN
                   FOR icomp IN comprod(iseg.cramo, iseg.cmodali, iseg.ctipseg, iseg.ccolect,
                                        iseg.cactivi, iseg.fefecto, iseg.cagente) LOOP
                      BEGIN
                         --a??mos llamada a  f_grabarcomisionmovimiento
                         IF NVL(pac_parametros.f_parproducto_n(iseg.sproduc,
                                                               'AFECTA_COMISESPPROD'),
                                1) = 1 THEN
                            v_res :=
                               pac_comisiones.f_grabarcomisionmovimiento
                                                                     (p_cempres => iseg.cempres,
                                                                      p_sseguro => vsolicit,
                                                                      p_cgarant => igaran.cgarant,
                                                                      p_nriesgo => pnriesgo,
                                                                      p_nmovimi => igaran.nmovimi,
                                                                      p_fecha => igaran.finiefe,
                                                                      p_modo => NULL   --'CAR'
                                                                                    ,
                                                                      p_ipricom => igaran.ipricom,
                                                                      p_cmodcom => icomp.cmodcom,
                                                                      p_sproces => NULL,
                                                                      p_mensajes => mensajes);

                            IF v_res <> 0 THEN
                               RAISE e_error_grabar_comisiones;
                            END IF;
                         ELSE
                            --FBL a?? ipricom al insert
                            vpcomisi := NVL(icomp.pcomisi, 0);

                            INSERT INTO estgaransegcom
                                        (sseguro, nriesgo, cgarant, nmovimi,
                                         finiefe, cmodcom, ninialt, pcomisi,
                                         cmatch, tdesmat, pintfin, nfinalt, pcomisicua, ipricom)
                                 VALUES (vsolicit, pnriesgo, igaran.cgarant, igaran.nmovimi,
                                         igaran.finiefe, icomp.cmodcom, icomp.ninialt, vpcomisi,
                                         NULL, NULL, NULL, icomp.nfinalt, 1, igaran.ipricom);
                         END IF;
                      EXCEPTION
                         WHEN DUP_VAL_ON_INDEX THEN
                            NULL;
                      END;
                   END LOOP;
                END IF;
             END LOOP;
          -- Fin FBL. 25/06/2014 MSV Bug 0028974
          END LOOP;

          IF dgaran = 0 THEN
             DELETE      estgaransegcom
                   WHERE sseguro = vsolicit;
    -- and cgarant = pcgarant and nriesgo = pnriesgo and nmovimi = vnmovimi and finiefe = pfiniefe;
          END IF;

    /*

    -- FBL. 25/06/2014 MSV Bug 0028974
    -- Se comenta toda esta parte que coge los datos del objeto.

          ELSE
             FOR tupla IN pcomisgar.FIRST .. pcomisgar.LAST LOOP
                DELETE FROM estgaransegcom
                      WHERE sseguro = vsolicit
                        AND nriesgo = pnriesgo
                        AND cgarant = pcomisgar(tupla).cgarant
                        AND nmovimi = pcomisgar(tupla).nmovimi
                        AND finiefe = pcomisgar(tupla).finiefe
                        AND cmodcom = pcomisgar(tupla).cmodcom
                        AND ninialt = pcomisgar(tupla).ninialt;
             END LOOP;

             COMMIT;

             FOR tupla IN pcomisgar.FIRST .. pcomisgar.LAST LOOP
                BEGIN
                   INSERT INTO estgaransegcom
                               (sseguro, nriesgo, cgarant,
                                nmovimi, finiefe,
                                cmodcom, pcomisi, cmatch, tdesmat,
                                pintfin, ninialt, pcomisicua,
                                nfinalt)
                        VALUES (vsolicit, pnriesgo, pcomisgar(tupla).cgarant,
                                pcomisgar(tupla).nmovimi, pcomisgar(tupla).finiefe,
                                pcomisgar(tupla).cmodcom, pcomisgar(tupla).pcomisi, NULL, NULL,
                                NULL, pcomisgar(tupla).ninialt, pcomisgar(tupla).pcomisicua,
                                pcomisgar(tupla).nfinalt);
                EXCEPTION
                   WHEN DUP_VAL_ON_INDEX THEN
                      NULL;
                END;
             END LOOP;

             COMMIT;
          END IF;
    */
          RETURN 0;
       EXCEPTION
          WHEN e_error_grabar_comisiones THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, v_res, vpasexec, vparam);
             RETURN 1;
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabargaransegcom;

    -- bfp bug 21947 fi
    --BUG 21657 --ETM --04/06/2012
       FUNCTION f_grabarinquiaval(pinquival IN t_iax_inquiaval, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          numcorr        NUMBER;
          vpasexec       NUMBER(8) := 0;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_Grabarinquiaval';
       BEGIN
          vpasexec := 1;

          IF pinquival IS NULL THEN
             RETURN 0;
          END IF;

          vpasexec := 2;

          IF pinquival.COUNT = 0 THEN
             RETURN 0;
          END IF;

          vpasexec := 3;

          -- Comprovacio pas de parametres correcte.
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vpasexec := 4;

             DELETE FROM estinquiaval
                   WHERE sseguro = vsolicit;

             vpasexec := 5;

             FOR i IN pinquival.FIRST .. pinquival.LAST LOOP
                vpasexec := 6;

                IF pinquival.EXISTS(i) THEN
                   vpasexec := 7;

                   IF pinquival(i).csitlaboral IS NOT NULL THEN
                      INSERT INTO estinquiaval
                                  (sseguro, sperson, nriesgo,
                                   nmovimi, ctipfig,
                                   cdomici, iingrmen,
                                   iingranual, ffecini,
                                   ffecfin, ctipcontrato,
                                   csitlaboral, csupfiltro)
                           VALUES (vsolicit, pinquival(i).sperson, pinquival(i).nriesgo,
                                   pinquival(i).nmovimi, pinquival(i).ctipfig,
                                   pinquival(i).cdomici, pinquival(i).iingrmen,
                                   pinquival(i).iingranual, pinquival(i).ffecini,
                                   pinquival(i).ffecfin, pinquival(i).ctipcontrato,
                                   pinquival(i).csitlaboral, pinquival(i).csupfiltro);
                   END IF;
                END IF;
             END LOOP;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarinquiaval;

    --fin BUG 21657--ETM--04/06/2012
    -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
        /*************************************************************************
          Grabar tabla coacuadro y coacedido
          param in  coacuadro: Objeto cuadro coaseguro
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabardetcoaseguro(pcoacuadro IN ob_iax_coacuadro, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabardetcoaseguro';
          num_err        NUMBER;
          ii             NUMBER := 0;
          vcoacedido     t_iax_coacedido;
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          END IF;

          --Borramos datos si existen
          DELETE FROM estcoacedido
                WHERE sseguro = vsolicit;

          --AND ncuacoa = pcoacuadro.ncuacoa;
          -- AND ccompan = pcoacuadro.ccompan;
          DELETE FROM estcoacuadro
                WHERE sseguro = vsolicit;

          --AND ncuacoa = pcoacuadro.ncuacoa;
          IF pcoacuadro IS NULL THEN
             RETURN 0;
          END IF;

          INSERT INTO estcoacuadro
                      (sseguro, ncuacoa, ploccoa, finicoa,
                       FFINCOA, FCUACOA, CCOMPAN,
                       npoliza,NENDOSO)
               VALUES (vsolicit, pcoacuadro.ncuacoa, pcoacuadro.ploccoa, pcoacuadro.finicoa,
                       PCOACUADRO.FFINCOA, PCOACUADRO.FCUACOA, PCOACUADRO.CCOMPAN,
                       pcoacuadro.npoliza,pcoacuadro.endoso);

          vcoacedido := pcoacuadro.coacedido;

          IF vcoacedido IS NULL THEN
             RETURN 0;
          ELSE
             IF vcoacedido.COUNT = 0 THEN
                RETURN 0;
             END IF;
          END IF;

          FOR vprg IN vcoacedido.FIRST .. vcoacedido.LAST LOOP
             ii := ii + 1;
             vpasexec := 5 || ii;

             IF vcoacedido.EXISTS(vprg) THEN
                IF vcoacedido(vprg).ccompan IS NOT NULL THEN
                   INSERT INTO estcoacedido
                               (sseguro, ncuacoa, ccompan,
                                pcomcoa, pcomgas,
                                pcomcon, pcescoa,
                                pcesion)
                        VALUES (vsolicit, pcoacuadro.ncuacoa, vcoacedido(vprg).ccompan,
                                vcoacedido(vprg).pcomcoa, vcoacedido(vprg).pcomgas,
                                vcoacedido(vprg).pcomcon, vcoacedido(vprg).pcescoa,
                                vcoacedido(vprg).pcesion);
                END IF;
             END IF;
          END LOOP;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabardetcoaseguro;

    -- Fin Bug 0023183

       -- Bug 0022701 - 03/09/2012 - JMF
       FUNCTION f_grabarretorno(retorno IN t_iax_retorno, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          numretrn       NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_GrabarRetorno';
       BEGIN
          IF retorno IS NULL THEN
             RETURN 0;
          END IF;

          IF retorno.COUNT = 0 THEN
             RETURN 0;
          END IF;

          -- Comprovació pas de parÃ metres correcte.
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             vpasexec := 13;

             DELETE FROM estrtn_convenio
                   WHERE sseguro = vsolicit;

             vpasexec := 14;

             FOR i IN retorno.FIRST .. retorno.LAST LOOP
                vpasexec := 15;

                IF retorno.EXISTS(i) THEN
                   vpasexec := 16;

                   SELECT COUNT(*)
                     INTO numretrn
                     FROM estrtn_convenio t
                    WHERE t.sperson = retorno(i).sperson
                      AND t.sseguro = vsolicit;

                   IF numretrn = 0 THEN
                      vpasexec := 22;

                      INSERT INTO estrtn_convenio
                                  (sseguro, sperson, nmovimi,
                                   pretorno)
                           VALUES (vsolicit, retorno(i).sperson, NVL(vnmovimi, 1),
                                   retorno(i).pretorno);
                   ELSE
                      vpasexec := 23;

                      UPDATE estrtn_convenio t
                         SET t.pretorno = retorno(i).pretorno
                       WHERE t.sperson = retorno(i).sperson
                         AND t.sseguro = vsolicit
                         AND t.nmovimi = vnmovimi;
                   END IF;
                END IF;
             END LOOP;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarretorno;

        /*************************************************************************
          Grabar las clausulas de la poliza
          param in clausula  : objeto clausula
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabarfranquicias(
          bonfranseg t_iax_bonfranseg,
          pnriesgo IN NUMBER,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnum           NUMBER;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.F_grabarfranquicias';
          vnumerr        NUMBER := 0;
          vidlistalibre  NUMBER;
          lvalor2        NUMBER;
          limpmin        NUMBER;
          limpmax        NUMBER;
          -- INI SPV AXIS-4201 Deducibles
          CURSOR c_bf_detnivel (p_cgrup NUMBER) IS
            SELECT *
             FROM bf_detnivel
            WHERE cgrup = p_cgrup
              AND cdefecto = 'S';
          --
          v_rec_bf_detnivel bf_detnivel%ROWTYPE;
		  v_cimpin bf_detnivel.cimpmin%TYPE; -- Variable para los tipos de importe
		  -- Caso cotizacion/suplemento
		  v_npoliza seguros.npoliza%TYPE;
		  v_sseguro seguros.sseguro%TYPE;
		  v_cnivel_cot bf_detnivel.cnivel%TYPE;								 					   								 
          -- FIN SPV IAXIS-4201 Deducibles
       BEGIN
          IF bonfranseg IS NULL THEN
             RETURN 0;
          END IF;

          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          ELSE
             --Esborrat de clausules existents.
             vpasexec := 4;

             DELETE FROM estbf_bonfranseg
                   WHERE sseguro = vsolicit;
          END IF;

          IF bonfranseg.COUNT = 0 THEN
             RETURN 0;
          END IF;

          FOR i IN bonfranseg.FIRST .. bonfranseg.LAST LOOP
             vpasexec := 6;
             vnumerr := 0;

             IF bonfranseg.EXISTS(i) THEN
                vpasexec := 7;

                IF vpmode = 'EST' THEN
                   vpasexec := 11;

                   IF bonfranseg(i).cnivel IS NOT NULL THEN
                      IF bonfranseg(i).ctipgrupsubgrup IN(3, 4) THEN   --franquicias libres
                         IF bonfranseg(i).cvalor1 IS NOT NULL
                            AND bonfranseg(i).impvalor1 IS NOT NULL THEN
                            SELECT id_listlibre
                              INTO vidlistalibre
                              FROM bf_detnivel b, bf_desnivel bdl
                             WHERE b.cempres = pac_md_common.f_get_cxtempresa
                               AND b.cempres = bdl.cempres
                               AND b.csubgrup = bonfranseg(i).csubgrup
                               AND b.cgrup = bonfranseg(i).cgrup
                               AND b.cgrup = bdl.cgrup
                               AND b.csubgrup = bdl.csubgrup
                               AND b.cversion = bdl.cversion
                               AND b.cversion = bonfranseg(i).cversion
                               AND bdl.cversion = b.cversion
                               AND b.cnivel = bdl.cnivel
                               AND b.cnivel = b.cnivel
                               AND b.cversion = bonfranseg(i).cversion
                               AND cidioma = pac_md_common.f_get_cxtidioma;

                            SELECT id_listlibre_2, id_listlibre_min, id_listlibre_max
                              INTO lvalor2, limpmin, limpmax
                              FROM bf_listlibre
                             WHERE cempres = pac_md_common.f_get_cxtempresa
                               AND id_listlibre = vidlistalibre
                               AND catribu = bonfranseg(i).cvalor1;

                            IF lvalor2 IS NOT NULL
                               AND(bonfranseg(i).cvalor2 IS NULL
                                   OR bonfranseg(i).impvalor2 IS NULL) THEN
                               vnumerr := 1;
                            END IF;

                            IF limpmin IS NOT NULL
                               AND(bonfranseg(i).cimpmin IS NULL
                                   OR bonfranseg(i).impmin IS NULL) THEN
                               vnumerr := 1;
                            END IF;

                            IF limpmax IS NOT NULL
                               AND(bonfranseg(i).cimpmax IS NULL
                                   OR bonfranseg(i).impmax IS NULL) THEN
                               vnumerr := 1;
                            END IF;
                         END IF;
                      END IF;

                      IF vnumerr != 1 THEN
                       -- INI SPV IAXIS-4201 Deducibles
                        --
                        OPEN c_bf_detnivel(bonfranseg(i).cgrup);
                        FETCH c_bf_detnivel INTO v_rec_bf_detnivel;
                        CLOSE c_bf_detnivel;
                        --
						-- Para casos de cotizaciones o suplementos se averigua si hay porcentajes para la solicitudes
						BEGIN
						  --
						  -- Buscar poliza de la cotizacion
						  SELECT npoliza
						    INTO v_npoliza
                           FROM estseguros
                         WHERE sseguro = vsolicit;
						 --
						 SELECT sseguro
						   INTO v_sseguro
                          FROM seguros
                         WHERE npoliza = v_npoliza;
						 -- Se coloca el valor guardado de impvalor1 poliza cotizacion/suplemento
						 SELECT  impvalor1,cnivel
						  INTO  v_rec_bf_detnivel.impvalor1, v_cnivel_cot
                          FROM  bf_bonfranseg
                         WHERE SSEGURO = v_sseguro
                           AND nriesgo = pnriesgo
                           AND cgrup = bonfranseg(i).cgrup;
						--
						/*IF v_rec_bf_detnivel.cnivel = 3 THEN  IAXIS-5423  CJMR 23/09/2019
						    --
							UPDATE bf_detnivel
							  SET cdefecto = 'N'
							 WHERE cnivel = 3
							  AND  cgrup = bonfranseg(i).cgrup;
							--
							UPDATE bf_detnivel
							  SET cdefecto = 'S'
							 WHERE cnivel = v_cnivel_cot
							  AND  cgrup = bonfranseg(i).cgrup;
							--
						ELSE  IAXIS-5423  CJMR 23/09/2019  */
						  --INI SPV  IAXIS-5247 Deducibles para Suplementos (Endosos)
                          --							  }
						  OPEN c_bf_detnivel(bonfranseg(i).cgrup);
                          FETCH c_bf_detnivel INTO v_rec_bf_detnivel;
                          CLOSE c_bf_detnivel;
						  --FIN SPV  IAXIS-5247 Deducibles para Suplementos (Endosos)
					    --END IF;  IAXIS-5423  CJMR 23/09/2019
						--
						EXCEPTION WHEN OTHERS THEN
						  --
						  v_npoliza := 0; -- Produccion
						  v_sseguro := 0;
						END;
						--
						--IF bonfranseg(i).cimpmin <> v_rec_bf_detnivel.cimpmin THEN  IAXIS-5423  CJMR 23/09/2019
						 --
						 v_cimpin := bonfranseg(i).cimpmin;
						 --
						/*ELSE    IAXIS-5423  CJMR 23/09/2019
						  --
						  v_cimpin := v_rec_bf_detnivel.cimpmin;
						  --
						END IF;  IAXIS-5423  CJMR 23/09/2019*/
						--
                        /*IF v_rec_bf_detnivel.cnivel <> bonfranseg(i).cnivel   IAXIS-5423  CJMR 23/09/2019
                          AND v_rec_bf_detnivel.impmin = bonfranseg(i).impmin THEN -- Ded. por defecto difiere del que viene por aplicacion
                          --
                          -- Insertamos con los datos del deducible por defecto
                          INSERT INTO estbf_bonfranseg
                                     (sseguro, nriesgo, cgrup,
                                      csubgrup, cnivel,
                                      cversion, nmovimi, finiefe,
                                      ctipgrup, cvalor1,
                                      impvalor1, cvalor2,
                                      impvalor2, cimpmin,
                                      impmin, cimpmax,
                                      impmax, ffinefe,
                                      cniveldefecto)
                              VALUES (vsolicit, pnriesgo, bonfranseg(i).cgrup,
                                      bonfranseg(i).csubgrup, v_rec_bf_detnivel.cnivel,
                                      bonfranseg(i).cversion, vnmovimi, bonfranseg(i).finiefe,
                                      bonfranseg(i).ctipgrup, v_rec_bf_detnivel.cvalor1,
                                      v_rec_bf_detnivel.impvalor1,bonfranseg(i).cvalor2,
                                      bonfranseg(i).impvalor2, v_cimpin,
                                      bonfranseg(i).impmin, bonfranseg(i).cimpmax,
                                      bonfranseg(i).impmax, bonfranseg(i).ffinefe,
                                      bonfranseg(i).cniveldefecto);
                           --	
                        ELSIF v_rec_bf_detnivel.cnivel = bonfranseg(i).cnivel 
                          AND v_rec_bf_detnivel.impmin <> bonfranseg(i).impmin THEN
                           --
                            INSERT INTO estbf_bonfranseg
                                     (sseguro, nriesgo, cgrup,
                                      csubgrup, cnivel,
                                      cversion, nmovimi, finiefe,
                                      ctipgrup, cvalor1,
                                      impvalor1, cvalor2,
                                      impvalor2, cimpmin,
                                      impmin, cimpmax,
                                      impmax, ffinefe,
                                      cniveldefecto)
                              VALUES (vsolicit, pnriesgo, bonfranseg(i).cgrup,
                                      bonfranseg(i).csubgrup, v_rec_bf_detnivel.cnivel,
                                      bonfranseg(i).cversion,vnmovimi, bonfranseg(i).finiefe,
                                      bonfranseg(i).ctipgrup,v_rec_bf_detnivel.cvalor1,
                                      v_rec_bf_detnivel.impvalor1, bonfranseg(i).cvalor2,
                                      bonfranseg(i).impvalor2, v_cimpin,
                                      bonfranseg(i).impmin,bonfranseg(i).cimpmax,
                                      bonfranseg(i).impmax, bonfranseg(i).ffinefe,
                                      bonfranseg(i).cniveldefecto);
                        ELSIF v_rec_bf_detnivel.cnivel <> bonfranseg(i).cnivel 
                          AND v_rec_bf_detnivel.impmin <> bonfranseg(i).impmin THEN
                           --
                            INSERT INTO estbf_bonfranseg
                                     (sseguro, nriesgo, cgrup,
                                      csubgrup, cnivel,
                                      cversion, nmovimi, finiefe,
                                      ctipgrup, cvalor1,
                                      impvalor1, cvalor2,
                                      impvalor2, cimpmin,
                                      impmin, cimpmax,
                                      impmax, ffinefe,
                                      cniveldefecto)
                              VALUES (vsolicit, pnriesgo, bonfranseg(i).cgrup,
                                      bonfranseg(i).csubgrup, v_rec_bf_detnivel.cnivel,
                                      bonfranseg(i).cversion,vnmovimi, bonfranseg(i).finiefe,
                                      bonfranseg(i).ctipgrup,v_rec_bf_detnivel.cvalor1,
                                      v_rec_bf_detnivel.impvalor1, bonfranseg(i).cvalor2,
                                      bonfranseg(i).impvalor2, v_cimpin,
                                      bonfranseg(i).impmin,bonfranseg(i).cimpmax,
                                      bonfranseg(i).impmax, bonfranseg(i).ffinefe,
                                      bonfranseg(i).cniveldefecto);
                        ELSE  IAXIS-5423  CJMR 23/09/2019 */ 
                          -- Se inserta como esta por defecto
                           BEGIN  -- IAXIS-5423  CJMR 23/09/2019
                           INSERT INTO estbf_bonfranseg
                                     (sseguro, nriesgo, cgrup,
                                      csubgrup, cnivel,
                                      cversion, nmovimi, finiefe,
                                      ctipgrup, cvalor1,
                                      impvalor1, cvalor2,
                                      impvalor2, cimpmin,
                                      impmin, cimpmax,
                                      impmax, ffinefe,
                                      cniveldefecto)
                              VALUES (vsolicit, pnriesgo, bonfranseg(i).cgrup,
                                      bonfranseg(i).csubgrup, bonfranseg(i).cnivel,
                                      bonfranseg(i).cversion, vnmovimi, bonfranseg(i).finiefe,
                                      bonfranseg(i).ctipgrup, bonfranseg(i).cvalor1,
                                      bonfranseg(i).impvalor1, bonfranseg(i).cvalor2,
                                      bonfranseg(i).impvalor2, v_cimpin,
                                      bonfranseg(i).impmin, bonfranseg(i).cimpmax,
                                      bonfranseg(i).impmax, bonfranseg(i).ffinefe,
                                      bonfranseg(i).cniveldefecto);
                           -- INI IAXIS-5423  CJMR 23/09/2019
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                              UPDATE estbf_bonfranseg
                              SET cvalor1 = bonfranseg(i).cvalor1,
                                  impvalor1 = bonfranseg(i).impvalor1,
                                  cimpmin = v_cimpin,
                                  impmin = bonfranseg(i).impmin
                              WHERE sseguro = vsolicit
                              AND nriesgo = pnriesgo
                              AND cgrup = bonfranseg(i).cgrup
                              AND csubgrup = bonfranseg(i).csubgrup
                              AND cnivel = bonfranseg(i).cnivel
                              AND cversion = bonfranseg(i).cversion
                              AND nmovimi = vnmovimi;
                           END;
                           -- FIN IAXIS-5423  CJMR 23/09/2019
                        --END IF;  IAXIS-5423  CJMR 23/09/2019
                        -- FIN SPV IAXIS-4201 Deducibles
                      END IF;
                   END IF;
                END IF;
             END IF;
          END LOOP;

          RETURN 0;   --Tot ok
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabarfranquicias;

       /*************************************************************************
          Grabar el caso bpm
          param in pnnumcaso : numero de caso bpm
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error

          Bug 28263/153355 - 01/10/2013 - AMC
       *************************************************************************/
       FUNCTION f_grabar_caso_bpmseg(pnnumcaso IN NUMBER, mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(100) := 'pnnumcaso:' || pnnumcaso;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabar_caso_bpmseg';
          vnumerr        NUMBER := 0;
       BEGIN
          IF pnnumcaso IS NULL THEN
             RAISE e_param_error;
          END IF;

          DELETE      estcasos_bpmseg
                WHERE sseguro = vsolicit;

          INSERT INTO estcasos_bpmseg
                      (sseguro, cempres, nnumcaso, cactivo)
               VALUES (vsolicit, pac_md_common.f_get_cxtempresa, pnnumcaso, 1);

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabar_caso_bpmseg;

          /*************************************************************************
          Grabar los mandatos de seguros
          param in tomador   : poliza
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabar_mandatos_seguros(
          poliza IN ob_iax_detpoliza,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vnmovimi       estmandatos_seguros.nmovimi%TYPE;
          vpasexec       NUMBER(8) := 1;
          vnum           NUMBER;
          vparam         VARCHAR2(200)
             := 'poliza.gestion.cmandato: ' || poliza.gestion.cmandato || 'poliza.sseguro'
                || poliza.sseguro || 'poliza.gestion.numfolio' || poliza.gestion.numfolio
                || 'poliza.gestion.sucursal' || poliza.gestion.sucursal;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabar_mandatos_seguros';
       BEGIN
          --RSA -- insertar en estmandatos_seguros
          IF poliza.gestion.cmandato IS NOT NULL
             AND poliza.gestion.numfolio IS NOT NULL THEN
             -- Comprovacio pas de parametres correcte.
             IF vpmode <> 'EST' THEN
                RAISE e_param_error;
             ELSE
                --// ACC afegit q quan gravi primer borri
                vpasexec := 10;

                --RSA -- insertar en estmandatos_seguros
                BEGIN
                   SELECT MAX(nmovimi) + 1
                     INTO vnmovimi
                     FROM mandatos_seguros
                    WHERE cmandato = poliza.gestion.cmandato
                      AND numfolio = poliza.gestion.numfolio;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      NULL;
                END;

                vpasexec := 20;

                DELETE FROM estmandatos_seguros
                      WHERE sseguro = poliza.sseguro;

                INSERT INTO estmandatos_seguros
                            (cmandato, numfolio,
                             sucursal, fechamandato, sseguro,
                             haymandatprev, faltarel, cusualtarel, fbajarel, cusubajarel,
                             nmovimi, ffinvig)   -- Bug 32676 16/10/2014   MMS
                     VALUES (poliza.gestion.cmandato, poliza.gestion.numfolio,
                             poliza.gestion.sucursal, poliza.gestion.fmandato, poliza.sseguro,
                             poliza.gestion.haymandatprev, f_sysdate, f_user, NULL, NULL,
                             NVL(vnmovimi, 1), poliza.gestion.ffinvig);   -- Bug 32676 16/10/2014   MMS
             END IF;
          END IF;

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabar_mandatos_seguros;

          --JRH 03/2008
        /*************************************************************************
          Grabar tabla EST los asegurados del mes en el suplemento de regularización
          param in   pNRiesgo: Riesgo
          param in   rentaIrr: Objeto rentas irregulares
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabar_aseguradosmes(
          pnriesgo IN NUMBER,
          pobasegmes IN ob_iax_aseguradosmes,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabar_aseguradosmes';
          num_err        NUMBER;
          ii             NUMBER := 0;
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          END IF;

          vpasexec := 1;

          --Borramos datos si existen
          DELETE FROM estaseguradosmes
                WHERE sseguro = vsolicit
                  AND nriesgo = pnriesgo
                  AND nmovimi = NVL(vnmovimi, 1);

          IF pobasegmes IS NULL THEN
             RETURN 0;
          END IF;

          vpasexec := 2;

          IF pobasegmes.nmes1 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 1, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes1);
          END IF;

          vpasexec := 3;

          IF pobasegmes.nmes2 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 2, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes2);
          END IF;

          vpasexec := 4;

          IF pobasegmes.nmes3 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 3, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes3);
          END IF;

          vpasexec := 5;

          IF pobasegmes.nmes4 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 4, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes4);
          END IF;

          vpasexec := 6;

          IF pobasegmes.nmes5 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 5, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes5);
          END IF;

          vpasexec := 7;

          IF pobasegmes.nmes6 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 6, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes6);
          END IF;

          vpasexec := 8;

          IF pobasegmes.nmes7 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 7, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes7);
          END IF;

          vpasexec := 9;

          IF pobasegmes.nmes8 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 8, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes8);
          END IF;

          vpasexec := 10;

          IF pobasegmes.nmes9 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 9, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes9);
          END IF;

          vpasexec := 11;

          IF pobasegmes.nmes10 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 10, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes10);
          END IF;

          vpasexec := 12;

          IF pobasegmes.nmes11 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 11, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes11);
          END IF;

          vpasexec := 13;

          IF pobasegmes.nmes12 IS NOT NULL THEN
             INSERT INTO estaseguradosmes
                         (sseguro, nriesgo, nmovimi, nmes, fregul,
                          naseg)
                  VALUES (vsolicit, pnriesgo, NVL(vnmovimi, 1), 12, pac_iax_produccion.vfefecto,
                          pobasegmes.nmes12);
          END IF;

          vpasexec := 14;
          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabar_aseguradosmes;

        /*************************************************************************
          Grabar tabla EST la versión de convenio de la póliza
          param in   pNRiesgo: Riesgo
          param in   rentaIrr: Objeto rentas irregulares
          param out mensajes : mesajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
       *************************************************************************/
       FUNCTION f_grabar_convempvers(
          pconvempvers IN ob_iax_convempvers,
          mensajes IN OUT t_iax_mensajes)
          RETURN NUMBER IS
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabar_aseguradosmes';
          num_err        NUMBER;
          ii             NUMBER := 0;
       BEGIN
          IF vpmode <> 'EST' THEN
             RAISE e_param_error;
          END IF;

          --Borramos datos si existen
          DELETE FROM estcnv_conv_emp_seg
                WHERE sseguro = vsolicit
                  AND nmovimi = vnmovimi;

          --AND ncuacoa = pcoacuadro.ncuacoa;
          IF pconvempvers IS NULL THEN
             RETURN 0;
          END IF;

          INSERT INTO estcnv_conv_emp_seg
                      (sseguro, nmovimi, idversion)
               VALUES (vsolicit, NVL(vnmovimi, 1), pconvempvers.idversion);

          RETURN 0;
       EXCEPTION
          WHEN e_param_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
             RETURN 1;
          WHEN e_object_error THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
             RETURN 1;
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                               psqcode => SQLCODE, psqerrm => SQLERRM);
             RETURN 1;
       END f_grabar_convempvers;
      -- CONF-274-25/11/2016-JLTS- Ini
    /*************************************************************************
       Grabar tabla EST la versi??e reinicio de la p??a
       param in   pNRiesgo: Riesgo
       param in   rentaIrr: Objeto rentas irregulares
       param out mensajes : mesajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
    *************************************************************************/
    FUNCTION f_grabar_reinicio(pssegpol NUMBER, psseguro NUMBER, pfinicio DATE, pffinal DATE,
                               pttexto VARCHAR2, pcmotmov NUMBER,
                               pnmovimi NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec            NUMBER(8) := 1;
      vparam              VARCHAR2(1) := NULL;
      vobject             VARCHAR2(200) := 'PAC_MD_GRABARDATOS.f_grabar_aseguradosmes';
      num_err             NUMBER;
      ii                  NUMBER := 0;
      v_hubo_reinicio_ant NUMBER := 0;
    BEGIN
      IF vpmode <> 'EST' THEN
        RAISE e_param_error;
      END IF;
      --Borramos datos si existen
      -- SSEGURO, FINICIO, CMOTMOV, NMOVIMI
      DELETE FROM estsuspensionseg
       WHERE sseguro = psseguro
         AND ffinal = pffinal
         AND cmotmov = pcmotmov
         AND nmovimi = pnmovimi;
      INSERT INTO estsuspensionseg
        (sseguro, finicio, ffinal, ttexto, cmotmov, nmovimi, fvigencia)
      VALUES
        (psseguro, pfinicio, pffinal, pttexto, pcmotmov, pnmovimi, NULL);
      -- si hay reinicio anterior, modificamos su fecha fin con el finicio de la suspension
      BEGIN
        SELECT 1
          INTO v_hubo_reinicio_ant
          FROM suspensionseg
         WHERE sseguro = psseguro
           AND cmotmov = pac_suspension.vcod_reinicio -- JLTS - OJO - Se cambia 392 por la variable vcod_reinicio
           AND nmovimi = (SELECT MAX(nmovimi)
                            FROM suspensionseg
                           WHERE sseguro = psseguro
                             AND cmotmov = pac_suspension.vcod_reinicio -- JLTS - OJO - Se cambia 392 por la variable vcod_reinicio
                             AND nmovimi < pnmovimi);
      EXCEPTION
        WHEN no_data_found THEN
          v_hubo_reinicio_ant := 0;
      END;
      IF v_hubo_reinicio_ant > 0 THEN
        UPDATE estsuspensionseg
           SET ffinal = pfinicio
         WHERE sseguro = psseguro
           AND cmotmov = pcmotmov
           AND nmovimi = pnmovimi;
      END IF;
      INSERT INTO anususpensionseg
        (sseguro, finicio, ffinal, ttexto, cmotmov, nmovimi, fvigencia)
        SELECT sseguro, finicio, ffinal, ttexto, cmotmov, nmovimi, fvigencia
          FROM suspensionseg
         WHERE sseguro = psseguro
           AND nmovimi = pnmovimi;
      SELECT MAX(nmovimi)
        INTO vnmovimi
        FROM movseguro
       WHERE sseguro = pssegpol
         AND cmovseg <> 52; -- No anulado
      RETURN 0;
    EXCEPTION
      WHEN e_param_error THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec,
                                          vparam);
        RETURN 1;
      WHEN e_object_error THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec,
                                          vparam);
        RETURN 1;
      WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec,
                                          vparam, psqcode => SQLCODE,
                                          psqerrm => SQLERRM||' - '||dbms_utility.format_error_backtrace());
        RETURN 1;
    END f_grabar_reinicio;
       -- CONF-274-25/11/2016-JLTS- Fin
    END pac_md_grabardatos;
/
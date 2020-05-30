CREATE OR REPLACE PACKAGE BODY pac_alctr126
IS
   /******************************************************************************
    NOMBRE:    PAC_ALCTR126
    PROPÓSITO: Funciones para traspaso de informacion entre las tablas reales y las de estudio
    REVISIONES:
    Ver        Fecha        Autor     Descripción
    ---------  ----------  --------  ------------------
    1.0        ??/??/????   ???      1. Creación del package.
    2.0        07/04/2009   DRA      2. 0009217: IAX - Suplement de clàusules
    3.0        07/05/2009   DRA      3. 0009329: IAX - Error gestió sobreprimes en pòlisses GUARDADES en l'emissió.
    4.0        01/06/2009   NMM      4. 0010240: CRE - Ajustes en pagos de renta extraordinarias.
    5.0        07/07/2009   RSC      5. 0010656: APRA - Error en suplemento de cambio de cuenta.
    6.0        21/07/2009   RSC      6. 0010757: APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emisión
    7.0        17/09/2009   DRA      7. 0011091: APR - error en la pantalla de simulacion
    8.0        18/09/2009   AMC      8. 0011165: Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
    9.0        30/09/2009   DRA      9. 0011305: APR - no se duplica detgaranseg
   10.0        22/09/2009   DRA     10. 0011183: CRE - Suplemento de alta de asegurado ya existente
   11.0        26/10/2009   DRA     11. 0011301: CRE080 - FOREIGNS DE PRESTAMOSEG
   12.0        02/11/2009   DRA     12. 0011618: AGA005 - Modificación de red comercial y gestión de comisiones.
   13.0        17/12/2009   JMF     13. 0010908 CRE - ULK - Parametrització del suplement automàtic d'actualització de patrimoni
   14.0        28/01/2010   DRA     14. 0012421: CRE 80- Saldo deutors II
   15.0        20/01/2010   RSC     15. 0011735: APR - suplemento de modificación de capital /prima
   16.0        26/05/2010   DRA     16. 0011288: CRE - Modificación de propuestas retenidas
   17.0        22/06/2010   RSC     17. 0014598: CEM800 - Información adicional en pantallas y documentos
   18.0        09/06/2010   DRA     18. 0014818: AGA003 - Clàusules de Beneficiaris
   19.0        10/06/2010   PFA     19. 14585: CRT001 - Añadir campo poliza compañia
   20.0        22/11/2010   JBN     20. 16410 -CRT003 - Clausulas con parametros
   21.0        10/01/2011   APD     21. 17221 - Ajustes GROUPLIFE
   22.0        13/01/2010   RSC     22. 16726: APR - clauses definition
   23.0        19/01/2011   ICV     23. 0015758: AGA005 - Dades complementàries a riscos Domicilis
   24.0        24/05/2011   ICV     24. 0018638: CRT - Nuevo campo garanseg ITOTANU (total prima anualizada)
   25.0        11/07/2011   JTS     25. 0017255: CRT003 - Definir propuestas de suplementos en productos
   26.0        25/07/2011   DRA     26. 0017255: CRT003 - Definir propuestas de suplementos en productos
   27.0        20/10/2011   ICV     27. 0019152: LCOL_T001- Beneficiari Nominats - LCOL_TEC-02_Emisión_Brechas01
   28.0        27/09/2011   DRA     28. 0019069: LCOL_C001 - Co-corretaje
   29.0        14/12/2011   RSC     29. 0019715: LCOL: Migración de productos de Vida Individual
   30.0        03/01/2012   JMF     30. 0020761 LCOL_A001- Quotes targetes
   31.0        21/01/2012   RSC     31. 0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos
   32.0        21/01/2012   APD     32. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
   33.0        08/03/2012   JMF     0021592: MdP - TEC - Gestor de Cobro
   34.0       17/04/2012    ETM     34.0021820: MDP_S001-SIN - Iconos consulta en gestión/consulta siniestros
   35.0        23/04/2011   MDS     35. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
   36.0        04/06/2012   ETM     36. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
   37.0        14/08/2012   DCG     37. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   38.0        03/09/2012   JMF     0022701: LCOL: Implementación de Retorno
   39.0        09/10/2012   MRB     23935 : MDP - PSU - Marca AUTORIPREV
   40.0        06/11/2012   AVT     0023184: LCOL_T020-COA-Circuit de Suplements i diferits amb coasseguran
   41.0        13/11/2012   APD     0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
   42.0        14/11/2012   DCT     0024505: LCOL_T001-QTracker: 4877: Hace cesion cuando hay movimientos de ahorro
   43.0        26/11/2012   LEC     0024714: LCOL_T001-QT 5382: No existen movimientos de anulaci?n ni la causa siniestro/motivo para polizas prorrogadas/saldadas
   44.0        29/11/2012   NMM     24657: MDP_T001-Pruebas de Suplementos
   45.0        10/12/2012   APD     24278: 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
   46.0        20/12/2012   MDS     46. 0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
   47.0        01/02/2013   ECP     47. 0025955: LCOL_T001-QT 5760: Al efectuar una modificaci?n duplica el registro de un prestamo en consultas de P?liza
   48.0        19/02/2013   MMS     48. 0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza ?hasta edad? y edades permitidas por producto- Modificar inserts/updates tablas ESTSEGUROS y SEGUROS
   49.0        26/02/2013   JDS     49. 0025964: LCOL - AUT - Experiencia
   50.0        04/03/2013   AEG     50. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
   3.0         11/02/2013   NMM     51. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
   52.0        25/06/2013   RCL     52. 0024697: Canvi mida camp sseguro
   53.0        24/07/2013   RCL     53. 0027304: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Rentas Vitalicias
   54.0        29/07/2013   SHA     54. 027014: LCOL - Revisión QT's Documentación Autos F3a
   55.0        21/08/2013   JSV     55. 0027953: LCOL - Autos Garantias por Modalidad
   56.0        15/10/2013   JSV     56. 0028547: Autos Accesorios
   57.0        10/02/2014   RCL     57. 0030064: LCOLF1ATEC-QT 0010916: Revisar en la Agenda de la p?liza que no est? cargando los datos de la prorroga correctamente.
   58.0        02/06/2014   ELP     58. 0027500: RSA Nueva operativa mandatos
   59.0        36/06/2014   FBL     59. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
   60.0        06/02/2015   AFM     60. 0034461, 0034462: Producto de convenios, suplementos retroactivos
   61.0        28/0|/2015   HRE     34107_0196851: QT-0014979: Se incluye campo nordeninc en las consultas e insercion de la
                                    tabla asegurados y assegurats.
   62.0        20/05/2015   YDA     62. 0034636 Se incluye el campo nscenario en el insert de la tabla evoluprovmat
   63.0        18/08/2015   IGIL    63. 0036596/211327 Se adiciona traspaso de citas medicas
   64.0        07/03/2016   JAEG    64. 40927/228750: Desarrollo Diseño técnico CONF_TEC-03_CONTRAGARANTIAS
   65.0        17/03/2016   JAEG    65. 41143/229973: Desarrollo Diseño técnico CONF_TEC-01_VIGENCIA_AMPARO
   66.0        03/04/2019   RABQ    66. IAXIS-3200: Eliminar cotizaciones mayores a 180 dias.
   67.0        06/07/2019   GEK     67. IAXIS-4205: Exclusión de cláusulas
   68.0        18/07/2019   SPV     68. IAXIS-4201: Deducibles
   69.0        28/11/2019   JLTS    69. IAXIS-5420: Se ajusta consulta para que tome el norden 1
   70.0        02/01/2020   ECP     70. IAXIS-3504. GEstión PAntallas Suplemento.
   71.0        19/05/2020   ECP     71. IAXIS-13888. Gesti�n Agenda
   ******************************************************************************/
   PROCEDURE borrar_tablas_est (psseguro IN NUMBER)
   IS
      /* Procediment per esborrar les taules d'estudis */
      c_ctapres   VARCHAR2 (34);

      CURSOR cur_personas
      IS
         SELECT sperson
           FROM estper_personas                     /*v_personas_estseguros*/
          WHERE sseguro = psseguro;

      v_pasexec   NUMBER        := 0;

      --INI SPV IAXIS-4201
      CURSOR c_cgrup
      IS
         SELECT cgrup
           FROM estbf_bonfranseg
          WHERE sseguro = psseguro;
   --FIN SPV IAXIS-4201
   BEGIN
      v_pasexec := 1;

      /* Primero borramos las tablas y luego las volvemos a llenar*/
      /*JTS 17/12/2008 APRA 8467*/
      DELETE FROM estseg_cbancar
            WHERE sseguro = psseguro;

      v_pasexec := 100;

      DELETE FROM est_supdesc
            WHERE sseguro = psseguro;

      v_pasexec := 101;

      DELETE FROM estreglassegtramos
            WHERE sseguro = psseguro;

      v_pasexec := 102;

      DELETE FROM estreglasseg
            WHERE sseguro = psseguro;

      v_pasexec := 2;

      DELETE FROM estasegurados
            WHERE sseguro = psseguro;

      v_pasexec := 3;

      DELETE FROM estclauparseg
            WHERE sseguro = psseguro;

      v_pasexec := 4;

      DELETE FROM estclauparesp
            WHERE sseguro = psseguro;

      v_pasexec := 5;

      DELETE FROM estclaususeg
            WHERE sseguro = psseguro;

      /* Bug 16726 - RSC - 13/01/2010 - APR - clauses definition*/
      DELETE FROM estclausubloq
            WHERE sseguro = psseguro;

      /* Fin bug 16726*/
      v_pasexec := 6;

      DELETE FROM estclaubenseg
            WHERE sseguro = psseguro;

      v_pasexec := 7;

      /* BUG16410:JBN 17/11/2010: Si tiene parametros*/
      DELETE FROM estclauparaseg
            WHERE sseguro = psseguro;

      DELETE FROM estclausuesp
            WHERE sseguro = psseguro;

      /* antes de borrar un estprestamoseg*/
      /* borramos las tablas del prestamo*/
      /* si no tiene polizas reales vinculadas*/
      v_pasexec := 8;
      /* DRA: comento esto porque esta petando al contratar un producto de saldos deudores *
                                                BEGIN
         SELECT ctapres
           INTO c_ctapres
           FROM estprestamoseg
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;   --no tiene contrato vinculado
      END;*/
      v_pasexec := 9;

      DELETE FROM estprestcuadroseg
            WHERE sseguro = psseguro;

      v_pasexec := 10;

      DELETE FROM estprestamoseg
            WHERE sseguro = psseguro;

      v_pasexec := 11;
      /* DRA: comento esto porque esta petando al contratar un producto de saldos deudores *
                                                IF c_ctapres IS NOT NULL THEN
         p_borrar_estprestamo(c_ctapres);
      END IF;*/
      v_pasexec := 12;

      DELETE FROM estcoacedido
            WHERE sseguro = psseguro;

      v_pasexec := 13;

      DELETE FROM estcoacuadro
            WHERE sseguro = psseguro;

      v_pasexec := 14;

      DELETE FROM estdetmovseguro
            WHERE sseguro = psseguro;

      v_pasexec := 15;

      DELETE FROM estintertecseg
            WHERE sseguro = psseguro;

      v_pasexec := 16;

      DELETE FROM estexclugarseg
            WHERE sseguro = psseguro;

      v_pasexec := 17;

      DELETE FROM estcomisionsegu
            WHERE sseguro = psseguro;

      v_pasexec := 18;

      DELETE FROM estgaransegcom
            WHERE sseguro = psseguro;

      v_pasexec := 19;

      DELETE FROM estgaranseggas
            WHERE sseguro = psseguro;

      v_pasexec := 20;

      DELETE FROM estgaranseg_sbpri
            WHERE sseguro = psseguro;

      v_pasexec := 21;

      DELETE FROM estpregungaranseg
            WHERE sseguro = psseguro;

      DELETE FROM estpregungaransegtab
            WHERE sseguro = psseguro;

      v_pasexec := 22;

      DELETE FROM estresulseg
            WHERE sseguro = psseguro;

      v_pasexec := 23;

      /* Bug 10757 - RSC - 21/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emisión*/
      DELETE FROM estdetgaranseg
            WHERE sseguro = psseguro;

      v_pasexec := 24;

      /* Fin Bug 10757*/
      /* Bug 21121 - APD - 21/02/2012 - borrar la tabla estdetprimas antes de borrar en la tabla estgaranseg*/
      DELETE FROM estdetprimas
            WHERE sseguro = psseguro;

      /* Fin Bug 21121*/
      /* Bug 27014 - SHA - 29/07/2013*/
      DELETE FROM estprimasgaranseg
            WHERE sseguro = psseguro;

      /* Fin Bug 27014*/
      /* INI BUG 34461, 34462 - Productos de CONVENIOS*/
      DELETE FROM esttramosregul
            WHERE sseguro = psseguro;

      /* FIN BUG 34461, 34462 - Productos de CONVENIOS*/
      DELETE FROM estgaranseg
            WHERE sseguro = psseguro;

      v_pasexec := 25;

      DELETE FROM estpregunseg
            WHERE sseguro = psseguro;

      DELETE FROM estpregunsegtab
            WHERE sseguro = psseguro;

      v_pasexec := 26;
      /* Bug 10702. Saldo deutors*/
      /* Bug 11165 - 16/09/2009 - AMC - Se sustituñe  estdetsaldodeutorseg por estprestamoseg*/
      /*DELETE FROM estprestamoseg
      WHERE sseguro = psseguro;*/
      v_pasexec := 27;

      DELETE FROM estsaldodeutorseg
            WHERE sseguro = psseguro;

      /* Fin Bug 10702. Saldo deutors*/
      v_pasexec := 28;

      /*(JAS)11.12.2007 - afegida gestió de preguntes a nivell de pòlissa*/
      DELETE FROM estpregunpolseg
            WHERE sseguro = psseguro;

      DELETE FROM estpregunpolsegtab
            WHERE sseguro = psseguro;

      DELETE FROM estsubtabs_seg_det
            WHERE sseguro = psseguro;

      v_pasexec := 29;

      DELETE      pds_estsegurosupl
            WHERE sseguro = psseguro;

      v_pasexec := 30;

      DELETE      pds_estsigform
            WHERE sseguro = psseguro;

      v_pasexec := 31;

      DELETE FROM estevoluprovmatseg
            WHERE sseguro = psseguro;

      v_pasexec := 32;

      /* **** Esborrat de taules de AUTOS ******************************/
      DELETE FROM estautconductores
            WHERE sseguro = psseguro;

      v_pasexec := 331;

      DELETE FROM estmotreten_rev
            WHERE sseguro = psseguro;

      v_pasexec := 332;

      DELETE FROM estmotretencion
            WHERE sseguro = psseguro;

      v_pasexec := 34;

      DELETE FROM estautdetriesgos
            WHERE sseguro = psseguro;

      DELETE FROM estautdisriesgos
            WHERE sseguro = psseguro;

      v_pasexec := 35;

      DELETE FROM estautriesgos
            WHERE sseguro = psseguro;

      v_pasexec := 36;

      /*      DELETE FROM estdetembarcriesgos*/
      /*            WHERE sseguro = psseguro;*/
      /*      v_pasexec := 37;*/
      /*      DELETE FROM estembarcriesgos*/
      /*            WHERE sseguro = psseguro;*/
      /*      v_pasexec := 38;*/
      DELETE FROM estsitriesgo
            WHERE sseguro = psseguro;

      v_pasexec := 39;

      DELETE FROM estriesgos
            WHERE sseguro = psseguro;

      v_pasexec := 40;

      DELETE FROM esttomadores
            WHERE sseguro = psseguro;

      v_pasexec := 41;

      DELETE FROM estassegurats
            WHERE sseguro = psseguro;

      v_pasexec := 42;

      DELETE FROM estseguros_assp
            WHERE sseguro = psseguro;

      v_pasexec := 43;

      /*modificació: XCG 05-01-2007 s'afegeixen aquestes dues taules----*/
      DELETE FROM estseguros_aho
            WHERE sseguro = psseguro;

/*------------------------------------------------------*/
      v_pasexec := 44;

      /* RSC 16-07-2007*/
      DELETE FROM estseguros_ulk
            WHERE sseguro = psseguro;

      v_pasexec := 45;

      DELETE FROM estsegdisin2
            WHERE sseguro = psseguro;

      v_pasexec := 46;

/*------------------------------------------------------*/
/*JRH  09/2007 Dues taules per a rendes*/
      DELETE FROM estseguros_ren
            WHERE sseguro = psseguro;

      v_pasexec := 47;

      DELETE FROM estseguros_act
            WHERE sseguro = psseguro;

      v_pasexec := 48;

      /*JRH  03/2008 Rentas irregulares*/
      DELETE FROM estplanrentasirreg
            WHERE sseguro = psseguro;

      v_pasexec := 50;

      DELETE FROM estpsucontrolseg
            WHERE sseguro = psseguro;

      v_pasexec := 5002;

      DELETE FROM estbasequestion_undw
            WHERE sseguro = psseguro;

      DELETE FROM estactions_undw
            WHERE sseguro = psseguro;

      DELETE FROM estexclusiones_undw
            WHERE sseguro = psseguro;

      DELETE FROM estenfermedades_undw
            WHERE sseguro = psseguro;

      v_pasexec := 502;

      DELETE FROM estriesgos_ir_ordenes
            WHERE sseguro = psseguro;

      v_pasexec := 503;

      DELETE FROM estriesgos_ir
            WHERE sseguro = psseguro;

      v_pasexec := 501;

      DELETE FROM estpsu_retenidas
            WHERE sseguro = psseguro;

      v_pasexec := 481;

      /* BUG19069:DRA:30/09/2011*/
      DELETE FROM estage_corretaje
            WHERE sseguro = psseguro;

      v_pasexec := 49;

      /*JRH 04/2008 Borramos de estper_... por si existen.*/
      FOR reg IN cur_personas
      LOOP
         pac_persona.borrar_tablas_estper (reg.sperson);
      END LOOP;

      v_pasexec := 50;

      /* Convenios*/
      DELETE FROM estcnv_conv_emp_seg
            WHERE sseguro = psseguro;

      /* convenios*/
      --IAXIS-13888 --19/05/2020
      -- CONF-108 AP
      DELETE FROM estagensegu
            WHERE sseguro = psseguro;

      -- CONF-108 AP
      -- CONF-274-25/11/2016-JLTS- Ini
      --IAXIS-13888 --19/05/2020
      DELETE FROM estsuspensionseg
            WHERE sseguro = psseguro;

      -- CONF-274-25/11/2016-JLTS- Fin
      DELETE FROM estseguros
            WHERE sseguro = psseguro;

      v_pasexec := 51;

      DELETE FROM estpenaliseg
            WHERE sseguro = psseguro;

/*--------*/
      v_pasexec := 52;

      /* **** Esborrat de taules dinàmiques i/o estàtiques ***** (sls)*/
      DELETE FROM tbestdettabla
            WHERE sseguro = psseguro;

      v_pasexec := 53;

      DELETE FROM tbestuserfilas
            WHERE sseguro = psseguro;

      v_pasexec := 54;

      DELETE FROM tbestfilastabla
            WHERE sseguro = psseguro;

      v_pasexec := 55;

      /*- **** Esborrat de taula intermitja de franquícies (NS)*/
      DELETE FROM garanfrqtmp
            WHERE sseguro = psseguro;

      v_pasexec := 56;

      /* borramos el titular del seguro que estamos borrando*/
      DELETE FROM estpresttitulares
            WHERE sseguro = psseguro;

      /* Mantis 10240.06/2009.NMM.*/
      /*DELETE FROM estplanrentasextra
      WHERE sseguro = psseguro;*/
      /* BUG 18351 - 10/05/2011 - JMP - Borrado de las tablas de documentación requerida*/
      v_pasexec := 57;

      DELETE FROM estdocrequerida
            WHERE sseguro = psseguro;

      v_pasexec := 58;

      DELETE FROM estdocrequerida_riesgo
            WHERE sseguro = psseguro;

      v_pasexec := 59;

      DELETE FROM estdocrequerida_inqaval
            WHERE sseguro = psseguro;

      /* FIN BUG 18351 - 10/05/2011 - JMP*/
      v_pasexec := 60;

      /* 19276*/
      DELETE FROM estreemplazos
            WHERE sseguro = psseguro;

      /*Bug.: 19152 - 20/11/2011 - ICV*/
      v_pasexec := 61;

      DELETE FROM estbenespseg
            WHERE sseguro = psseguro;

      /* BUG 0021592 - 08/03/2012 - JMF*/
      v_pasexec := 62;

      DELETE FROM estgescobros
            WHERE sseguro = psseguro;

      /* Bug 20893/111636 - 02/05/2012 - AMC*/
      v_pasexec := 63;

      DELETE FROM estdir_riesgos
            WHERE sseguro = psseguro;

      v_pasexec := 64;

      /* bug 21657--ETM-05/06/2012*/
      DELETE FROM estinquiaval
            WHERE sseguro = psseguro;

      /*fin bug 21657-ETM-05/06/2012*/
      /* BUG 0022701 - 03/09/2012 - JMF*/
      v_pasexec := 65;

      DELETE FROM estrtn_convenio
            WHERE sseguro = psseguro;

      v_pasexec := 66;

      -- INI SPV IAXIS-4201
      FOR i IN c_cgrup
      LOOP
         --
         UPDATE bf_detnivel
            SET cdefecto = 'N'
          WHERE cgrup = i.cgrup AND cdefecto = 'S';

         --
         UPDATE bf_detnivel
            SET cdefecto = 'S'
          WHERE cgrup = i.cgrup AND cnivel = 3;
      --
      END LOOP;

      --
      COMMIT;

      --
      -- FIN SPV IAXIS-4201
      DELETE FROM estbf_bonfranseg
            WHERE sseguro = psseguro;

      v_pasexec := 67;

      DELETE FROM est_texmovseguro
            WHERE sseguro = psseguro;

      /* Bug INI: 35095/199894 - 06/03/2015 - PRB*/
      DELETE FROM estasegurados_innom
            WHERE sseguro = psseguro;

      /* Bug FIN: 35095/199894 - 06/03/2015 - PRB*/
      /*CONVENIOS*/
      DELETE FROM estaseguradosmes
            WHERE sseguro = psseguro;

      /*CONVENIOS*/
      v_pasexec := 68;

      DELETE FROM estdocrequerida_benespseg
            WHERE sseguro = psseguro;

      /* Bug 28263/153355 - 01/10/2013 - AMC*/
      v_pasexec := 69;

      DELETE FROM estcasos_bpmseg
            WHERE sseguro = psseguro;

      v_pasexec := 70;

      DELETE FROM estmandatos_seguros
            WHERE sseguro = psseguro;

      /* Bug 34675/198727 - 24/02/2015 - AMC*/
      DELETE FROM estvalidacargapregtab
            WHERE sseguro = psseguro;

      /* Bug 36596 IGIL   ini*/
      v_pasexec := 71;

      DELETE FROM estcitamedica_undw
            WHERE sseguro = psseguro;

      /* Bug 36596 IGIL final*/

      -- INI BUG 40927/228750 - 07/03/2016 - JAEG
      DELETE      estper_contragarantia
            WHERE scontgar IN (
                     (SELECT p.scontgar
                        FROM estper_contragarantia p, estctgar_seguro cs
                       WHERE cs.sseguro = psseguro
                             AND p.scontgar = cs.scontgar));

      --
      DELETE      estctgar_seguro
            WHERE sseguro = psseguro;
   -- FIN BUG 40927/228750 - 07/03/2016 - JAEG
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_alctr126.borrar_tablas_est',
                      v_pasexec,
                      'borrado est',
                      SQLERRM
                     );
   END borrar_tablas_est;

/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
/* Procediment per traspassar de les taules d'estudis a les reals*/
   PROCEDURE traspaso_tablas_est (
      psseguro   IN       NUMBER,
      pfefecto   IN       DATE,
      pcdomper   IN       NUMBER,
      mens       OUT      VARCHAR2,
      programa   IN       VARCHAR2 DEFAULT 'ALCTR126',
      p_agecob            NUMBER DEFAULT NULL,
      pnmovimi   IN       NUMBER DEFAULT NULL,
      /* alsup003. si el movimiento no esta informado borraremos y cargaremos solo el movimiento, en el caso contrario cargarmos todo.*/
      pffinefe   IN       DATE DEFAULT NULL,
      /* Solo hay que informar de la fecha en el caso de que el movimiento este informado. Es decir cuando proceda la llamada del alsup003.*/
      pmovsegu   IN       NUMBER DEFAULT NULL
   )
   IS
      /* SBG 04/2008*/
      TYPE t_cnvpol IS RECORD (
         polissa_ini   VARCHAR2 (15),
         producte      VARCHAR2 (6),
         ram           NUMBER (8),
         moda          NUMBER (2),
         tipo          NUMBER (2),
         cole          NUMBER (2),
         npoliza       NUMBER,
         sseguro       NUMBER,
         activitat     VARCHAR2 (6)
      );

      v_cnvpol                 t_cnvpol;
      aux_ssegpol              NUMBER;
      /*vspertom      NUMBER;*/
      movi_ant                 NUMBER (6);
      v_csituac                NUMBER;
      reg_benseg               NUMBER;
      reg_esp                  NUMBER;
      reg_esp0                 NUMBER;
      reg_esp2                 NUMBER;
      reg_clau                 NUMBER;
      reg_clau2                NUMBER;
      reg_ben                  NUMBER;
      /* Variables para OCS --*/
      cc                       NUMBER;
      cg                       NUMBER;
      cs                       NUMBER;
      num_err                  NUMBER;
      prestamos                NUMBER;
      aux_fec_ren              DATE;                           /*JRH  Rentas*/
      nreser                   NUMBER;                         /*JRH  Rentas*/
      aux_prod                 NUMBER;                         /*JRH  Rentas*/
      salir                    EXCEPTION;
      v_f_act_hispsu           NUMBER;

      /*JRH 04/2008*/
      CURSOR cur_estper
      IS
         SELECT sperson
           FROM v_personas_estseguros
          WHERE sseguro = psseguro;

      -- CONF-108 AP
      CURSOR cur_estagensegu
      IS
         SELECT *
           FROM estagensegu e
          WHERE e.sseguro IN (SELECT sseguro
                                FROM estseguros a
                               WHERE a.ssegpol = psseguro);

      cur_estagensegu_r        cur_estagensegu%ROWTYPE;

      -- CONF-108 AP
      -- CONF-274-25/11/2016-JLTS- Ini
      CURSOR cur_estsuspensionseg
      IS
         SELECT *
           FROM estsuspensionseg e
          WHERE e.sseguro = psseguro;

      cur_estsuspensionseg_r   cur_estsuspensionseg%ROWTYPE;
      -- CONF-274-25/11/2016-JLTS- Fin
      pidioma                  NUMBER;
      aux_cempres              NUMBER;
      paso                     NUMBER                         := 0;
      vcagente                 agentes.cagente%TYPE;
      vcempres                 empresas.cempres%TYPE;
      /* Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
      v_nmov_dummy             NUMBER;
      /* Fin Bug 20672*/
      v_seqdocu                NUMBER;   /* Bug 24657/130885.NMM.2012.11.27.*/
      vcmovseg                 NUMBER;                           /*Convenios*/
      v_nlinea                 NUMBER;                           --CONF-108 AP

      /*-*/
       --INI SPV IAXIS-4201
      CURSOR c_cgrup
      IS
         SELECT cgrup
           FROM estbf_bonfranseg
          WHERE sseguro = psseguro;
   --FIN SPV IAXIS-4201
   BEGIN
      /*(JAS)11.12.2007 - Si no ens informen el número de moviment a traspassar, abortem.*/
      IF pnmovimi IS NULL
      THEN
         mens := '152102';
         RAISE salir;
      END IF;

      paso := 1;
      p_tab_error (f_sysdate,
                   f_user,
                   'ecp',
                   1,
                   'psseguro' || psseguro,
                   SQLERRM
                  );                                    /*etm quitar*/
                               /* SBG 04/2008*/
                               /*BUG8644-11032009-XVM: s'hafageix el cempres*/

      BEGIN
         SELECT ssegpol, csituac, polissa_ini,
                sproduc, cramo, cmodali,
                ctipseg, ccolect, npoliza,
                sseguro, cactivi, cagente, cempres
           INTO aux_ssegpol, v_csituac, v_cnvpol.polissa_ini,
                v_cnvpol.producte, v_cnvpol.ram, v_cnvpol.moda,
                v_cnvpol.tipo, v_cnvpol.cole, v_cnvpol.npoliza,
                v_cnvpol.sseguro, v_cnvpol.activitat, vcagente, vcempres
           FROM estseguros
          WHERE sseguro = psseguro;
      -- sseguro = (SELECT min(a.SSEGURO) FROM ESTSEGUROS A WHERE a.ssegpol = psseguro);
      --
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT ssegpol, csituac, polissa_ini,
                      sproduc, cramo, cmodali,
                      ctipseg, ccolect, npoliza,
                      sseguro, cactivi, cagente,
                      cempres
                 INTO aux_ssegpol, v_csituac, v_cnvpol.polissa_ini,
                      v_cnvpol.producte, v_cnvpol.ram, v_cnvpol.moda,
                      v_cnvpol.tipo, v_cnvpol.cole, v_cnvpol.npoliza,
                      v_cnvpol.sseguro, v_cnvpol.activitat, vcagente,
                      vcempres
                 FROM estseguros
                WHERE sseguro = (SELECT MIN (a.sseguro)
                                   FROM estseguros a
                                  WHERE a.ssegpol = psseguro);
            END;
      END;

--WHERE e.sseguro in (SELECT SSEGURO FROM ESTSEGUROS A WHERE a.ssegpol = psseguro
--                );
      paso := 2;
      p_tab_error (f_sysdate,
                   f_user,
                   'ecp',
                   2,
                      'psseguro'
                   || psseguro
                   || 'v_cnvpol.sseguro'
                   || v_cnvpol.sseguro
                   || 'aux_ssegpol '
                   || aux_ssegpol,
                   SQLERRM
                  );                                            /*etm quitar*/

      /*BEGIN*/
      /*   SELECT sperson*/
      /*   INTO   vspertom*/
      /*   FROM   esttomadores*/
      /*   WHERE  sseguro = psseguro*/
      /*   AND    nordtom = 1;*/
      /*EXCEPTION*/
      /*   WHEN OTHERS THEN*/
      /*      vspertom    := NULL;*/
      /*END;*/
      /* Primero borramos las tablas y luego las volvemos a llenar*/
      /*JTS 17/12/2008 APRA 8467*/
      /*CONVENIOS*/
      DELETE FROM tramosregul
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM aseguradosmes
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /*CONVENIOS*/
      DELETE FROM seg_cbancar
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* Bug INI: 35095/199894 - 06/03/2015 - PRB*/
      DELETE FROM asegurados_innom
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* Bug FIN: 35095/199894 - 06/03/2015 - PRB*/
      DELETE FROM clauparesp
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 3;

      DELETE FROM clauparseg
            WHERE sseguro = aux_ssegpol;

      paso := 4;

      DELETE FROM claubenseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 5;

      DELETE FROM clausuesp
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 51;

      /*Bug.: 19152 - 20/11/2011 - ICV*/
      DELETE FROM benespseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 6;

      /* BUG16410:JBN 17/11/2010:*/
      /*      DELETE FROM clauparaseg*/
      /*            WHERE sseguro = aux_ssegpol*/
      /*              AND nmovimi = NVL(movi_ant, nmovimi);*/
      /*      DELETE FROM claususeg*/
      /*            WHERE sseguro = aux_ssegpol*/
      /*              AND nmovimi = NVL(movi_ant, nmovimi);*/
      /*      -- Bug 16726 - RSC - 13/01/2010 - APR - clauses definition*/
      /*      DELETE FROM clausubloq*/
      /*            WHERE sseguro = aux_ssegpol*/
      /*              AND nmovimi = NVL(movi_ant, nmovimi);*/
      /* Fin Bug 16726*/
      /*JRH PRB - De la manera anterior seguro que no es porque se pierde todo el historico de clúausulas*/
      DELETE FROM clauparaseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM claususeg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      -- INI GEK IAXIS-4205 06/07/2019
      DELETE FROM clauparaseg cp
            WHERE cp.sclagen = sclagen
              AND cp.sseguro = (SELECT s.sseguro
                                  FROM seguros s
                                 WHERE npoliza = v_cnvpol.npoliza);

      DELETE FROM claususeg cs
            WHERE cs.sclagen = sclagen
              AND cs.sseguro = (SELECT s.sseguro
                                  FROM seguros s
                                 WHERE npoliza = v_cnvpol.npoliza);

      -- FIN GEK IAXIS-4205 06/07/2019

      /* Bug 16726 - RSC - 13/01/2010 - APR - clauses definition*/
      DELETE FROM clausubloq
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /*Fi JRH PRB - De la manera anterior seguro que no es porque se pierde todo el historico de clúausulas*/
      paso := 7;

      /* JDC 06/08/02*/
      DELETE FROM resulseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 8;

      /* Fi JDC*/
      DELETE FROM garanseggas
            WHERE sseguro = aux_ssegpol;

      paso := 9;

      /* Bug 21121 - APD - 21/02/2012 - borrar talba detprimas antes de la garansegcom*/
      DELETE FROM detprimas
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* fin Bug 21121 - APD - 21/02/2012*/
      DELETE FROM garansegcom
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 10;

      DELETE FROM garanseg_sbpri
            WHERE sseguro = aux_ssegpol;

      paso := 11;

      DELETE FROM coacedido
            WHERE sseguro = aux_ssegpol
                                       /* Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran*/
                  AND ncuacoa = NVL (pnmovimi, ncuacoa);

      /* Fin Bug 0023183*/
      paso := 12;

      /* INI BUG 34461, 34462 - Productos de CONVENIOS*/
      DELETE FROM cnv_conv_emp_seg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* FIN BUG 34461, 34462 - Productos de CONVENIOS*/
      DELETE FROM coacuadro
            WHERE sseguro = aux_ssegpol
                                       /* Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran*/
                  AND ncuacoa = NVL (pnmovimi, ncuacoa);

      /* Fin Bug 0023183*/
      paso := 13;

      DELETE FROM comisionsegu
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* Bug 32595/182234 - 28/08/2014 - AMC*/
      paso := 14;

      DELETE FROM v_rescate
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 15;

      DELETE FROM tbsegfilastabla
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 16;

      DELETE FROM tbseguserfilas
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 17;

      DELETE FROM tbsegdettabla
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 18;

      DELETE FROM garanfrqtmp
            WHERE sseguro = aux_ssegpol;

      paso := 19;

      /* Bug 11165 - 16/09/2009 - AMC - Se sustituñe  detsaldodeutorseg por prestamoseg*/
      DELETE FROM prestamoseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 20;

      DELETE FROM saldodeutorseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 217;
      p_control_error ('PAC_ALCTR126',
                       'traspaso_tablas_est',
                          '1. PASO 1, aux_ssegpol:'
                       || aux_ssegpol
                       || ' pnmovimi'
                       || pnmovimi
                      );
      p_tab_error (f_sysdate,
                   f_user,
                   'etm',
                   6,
                   'aux_ssegpol:' || aux_ssegpol || ' pnmovimi' || pnmovimi,
                   SQLERRM
                  );                                            /*etm quitar*/
      v_f_act_hispsu := f_act_hispsu (aux_ssegpol, pnmovimi);         --ramiro

      DELETE FROM psucontrolseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 218;

      DELETE FROM basequestion_undw
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM actions_undw
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM exclusiones_undw
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM enfermedades_undw
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 2199;

      DELETE FROM riesgos_ir_ordenes
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 219;

      DELETE FROM riesgos_ir
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      -- CONF-108 AP
      OPEN cur_estagensegu;

      FETCH cur_estagensegu
       INTO cur_estagensegu_r;

      IF cur_estagensegu%FOUND
      THEN
         v_nlinea := cur_estagensegu_r.nlinea;
      END IF;

      IF cur_estagensegu%ISOPEN
      THEN
         CLOSE cur_estagensegu;
      END IF;

      paso := 223;

      --Ini IAXIS -- 3504 --ECP --02/01/2020
        --IAXIS-13888 --19/05/2020
      DELETE FROM hisagensegu a
            WHERE sseguro = aux_ssegpol;

      DELETE FROM estagensegu a
            WHERE sseguro = aux_ssegpol;

--IAXIS-13888 --19/05/2020

      --Fin IAXIS -- 3504 --ECP --02/01/2020

      -- CONF-108 AP

      -- CONF-274-25/11/2016-JLTS- Ini
      OPEN cur_estsuspensionseg;

      FETCH cur_estsuspensionseg
       INTO cur_estsuspensionseg_r;

      IF cur_estsuspensionseg%FOUND
      THEN
         DELETE FROM suspensionseg a
               WHERE a.sseguro = aux_ssegpol
/*           AND a.finicio = cur_estsuspensionseg_r.finicio
           ANd a.cmotmov = cur_estsuspensionseg_r.cmotmov*/
                 AND a.nmovimi = cur_estsuspensionseg_r.nmovimi;
      END IF;

      paso := 224;

      IF cur_estsuspensionseg%ISOPEN
      THEN
         CLOSE cur_estsuspensionseg;
      END IF;

      -- CONF-274-25/11/2016-JLTS- Fin
      paso := 227;

      DELETE FROM psu_retenidas
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 237;

      /* BUG11288:DRA:20/10/2009:Inici*/
      DELETE FROM motreten_rev mr
            WHERE mr.sseguro = aux_ssegpol
              AND mr.nmovimi = NVL (pnmovimi, mr.nmovimi);

      DELETE FROM motretencion mot
            WHERE mot.sseguro = aux_ssegpol
              AND mot.nmovimi = NVL (pnmovimi, mot.nmovimi);

      /* BUG11288:DRA:20/10/2009:Fi*/
      DELETE FROM primasgaranseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 212;

      DELETE FROM pregunseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM pregunsegtab
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM subtabs_seg_det
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 22;

      /*(JAS) Esborrat de les preguntes a nivell de pòlissa.*/
      DELETE FROM pregunpolseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM pregunpolsegtab
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 23;

      DELETE FROM pregungaranseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      DELETE FROM pregungaransegtab
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 240;

      DELETE FROM bf_bonfranseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 243;

      DELETE FROM garandetcap
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* BUG11091:DRA:17/09/2009:Inici*/
      paso := 241;

      DELETE FROM detgaranseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* BUG11091:DRA:17/09/2009:Fi*/
      paso := 242;

      DELETE FROM garanseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 25;
      /*DELETE FROM asegurados*/
      /*WHERE       sseguro = aux_ssegpol;*/
      /*DELETE FROM tomadores*/
      /*WHERE       sseguro = aux_ssegpol;*/
      /* BUG20248:DRA:24/11/2011:Inici*/
      /*DELETE FROM detmovseguro*/
      /*      WHERE sseguro = aux_ssegpol*/
      /*        AND nmovimi = NVL(pnmovimi, nmovimi)*/
      /*        AND pnmovimi <> 1;*/
      /* BUG20248:DRA:24/11/2011:Fi*/
      paso := 26;

      /* 12/1/2004 -- Se incluye la tabla INTERTECSEG*/
      DELETE FROM intertecseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 27;
      /* Bug 11165 - 16/09/2009 - AMC - Se sustituñe  detsaldodeutorseg por prestamoseg*/
      /*
                                                DELETE FROM prestamoseg
            WHERE sseguro = aux_ssegpol
              AND nmovimi = NVL(pnmovimi, nmovimi);
      */
      paso := 28;

      DELETE FROM prestcuadroseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 29;

      /* JRH  09/2007 Rendes*/
      /*    DELETE FROM SEGUROS_REN
                                               WHERE sseguro = aux_ssegpol;
      DELETE FROM SEGUROS_ACT
      WHERE sseguro = aux_ssegpol;*/
      /* JRH  09/2007*/
      /*modificació: XCG  05-01-2007 s'afegeix aquesta taula----*/
      /*  DELETE FROM seguros_aho*/
      /*  WHERE           sseguro = psseguro;*/
      DELETE FROM penaliseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 290;

/*------------------------------------------------------*/
/* 16/07/2007 -- Se incluye la tabla SEGDISIN2*/
      DELETE FROM segdisin2
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* BUG19069:DRA:27/09/2011:Inici*/
      paso := 291;

      DELETE FROM age_corretaje
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      paso := 292;

      /* BUG 0022701 - 03/09/2012 - JMF*/
      DELETE FROM rtn_convenio
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* BUG 0021592 - 08/03/2012 - JMF*/
      paso := 293;

      DELETE FROM gescobros
            WHERE sseguro = aux_ssegpol;

      /* Bug 28263/153355 - 01/10/2013 - AMC*/
      paso := 294;

      DELETE FROM casos_bpmseg
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* Bug 36596 IGIL   ini*/
      paso := 71;

      DELETE FROM citamedica_undw
            WHERE sseguro = aux_ssegpol AND nmovimi = NVL (pnmovimi, nmovimi);

      /* Bug 36596 IGIL final*/
      /* Bug 34675/198727 - 24/02/2015 - AMC*/
      DELETE FROM validacargapregtab
            WHERE sseguro = aux_ssegpol;

      /* BUG19069:DRA:27/09/2011:Fi*/
      /*  DELETE FROM EXCLUGARSEG*/
      /*        WHERE SSEGURO = aux_ssegpol*/
      /*      AND nmovimi = NVL(pnmovimi, nmovimi);*/
      paso := 296;
      p_tab_error (f_sysdate,
                   f_user,
                   'ecp',
                   4,
                      ' psseguro'
                   || psseguro
                   || 'aux_ssegpol'
                   || aux_ssegpol
                   || 'v_cnvpol.sseguro'
                   || v_cnvpol.sseguro
                   || ' mens'
                   || mens,
                   SQLERRM
                  );                                            /*etm quitar*/
      traspaso_seguro (v_cnvpol.sseguro, aux_ssegpol, mens);
      p_tab_error (f_sysdate,
                   f_user,
                   'ecp',
                   5,
                      'antes psseguro'
                   || psseguro
                   || 'aux_ssegpol'
                   || aux_ssegpol
                   || ' mens'
                   || mens,
                   SQLERRM
                  );                                            /*etm quitar*/

      IF mens IS NOT NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'ecp',
                      6,
                         ' psseguro'
                      || psseguro
                      || 'aux_ssegpol'
                      || aux_ssegpol
                      || ' mens'
                      || mens,
                      SQLERRM
                     );                                         /*etm quitar*/
         RAISE salir;
      END IF;

      paso := 30;

      IF pmovsegu IS NULL
      THEN
         IF programa = 'ALCTR126'
         THEN
            traspaso_movseguro (aux_ssegpol, pfefecto, pcdomper, mens);
         END IF;
      END IF;

      paso := 31;

      IF mens IS NOT NULL
      THEN
         RAISE salir;
      END IF;

      /*JRH 04/2008*/
      FOR i IN cur_estper
      LOOP
         pac_persona.traspaso_tablas_estper (i.sperson, vcagente, vcempres);
      /* dra 29-9-08: bug mantis 7567*/
      END LOOP;

      paso := 32;

      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'INS_MANDATO'
                                            ),
              0
             ) = 1
      THEN
         FOR i IN cur_estper
         LOOP
            pac_mandatos.traspaso_tablas_estmandatos (i.sperson, mens);

            IF mens IS NOT NULL
            THEN
               RAISE salir;
            END IF;
         END LOOP;

         pac_mandatos.traspaso_mandatos_seguros (v_cnvpol.sseguro,
                                                 aux_ssegpol,
                                                 mens
                                                );

         IF mens IS NOT NULL
         THEN
            RAISE salir;
         END IF;
      END IF;

      /*(JAS)11.12.2007 - Gestió de preguntes per pòlissa*/
      /*// ACC 12022008 afegixo control del nmovimi*/
      /*// ACC 27022008 trec la comprovació de si es nivell poliza o risc*/
      INSERT INTO pregunpolseg
                  (sseguro, cpregun, crespue, trespue, nmovimi)
         (SELECT aux_ssegpol, cpregun, crespue, trespue, nmovimi
            FROM estpregunpolseg ep
           WHERE ep.sseguro = psseguro
             AND ep.nmovimi = NVL (pnmovimi, ep.nmovimi));

      INSERT INTO pregunpolsegtab
                  (sseguro, cpregun, nmovimi, nlinea, ccolumna, tvalor,
                   fvalor, nvalor)
         (SELECT aux_ssegpol, cpregun, nmovimi, nlinea, ccolumna, tvalor,
                 fvalor, nvalor
            FROM estpregunpolsegtab ep
           WHERE ep.sseguro = psseguro
             AND ep.nmovimi = NVL (pnmovimi, ep.nmovimi));

      /*SHA*/
      INSERT INTO subtabs_seg_det
                  (sseguro, nriesgo, cgarant, nmovimi, cpregun, nlinea, ccla1,
                   ccla2, ccla3, ccla4, ccla5, ccla6, ccla7, ccla8, ccla9,
                   ccla10, nval1, nval2, nval3, nval4, nval5, nval6, nval7,
                   nval8, nval9, nval10)
         (SELECT aux_ssegpol, nriesgo, cgarant, nmovimi, cpregun, nlinea,
                 ccla1, ccla2, ccla3, ccla4, ccla5, ccla6, ccla7, ccla8,
                 ccla9, ccla10, nval1, nval2, nval3, nval4, nval5, nval6,
                 nval7, nval8, nval9, nval10
            FROM estsubtabs_seg_det
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      /*SHA*/
      paso := 33;
      /*INSERT INTO tomadores*/
                                /*
                       (sperson, sseguro, nordtom, cdomici)*/
                                                              /* (
                SELECT
                       pac_persona.f_sperson_spereal (sperson),*/ /* aux_ssegpol,*/ /* nordtom,*/ /* cdomici*/
                                                                                                               /*
                  FROM
                       esttomadores*/
                                      /*
                 WHERE
                       sseguro = psseguro);*/
      traspaso_tomadores (psseguro, aux_ssegpol, pnmovimi, mens);

      IF mens IS NOT NULL
      THEN
         RAISE salir;
      END IF;

      paso := 34;
      /*INSERT INTO asegurados*/
                                 /*
                       (sseguro, sperson, norden, cdomici, ffecini, ffecfin,
                       */
                          /* ffecmue)*/
                                        /* (
                SELECT
                       aux_ssegpol,*/
                                      /* pac_persona.f_sperson_spereal (sperson),*/ /* norden,*/ /* cdomici,*/ /* ffecini,*/
                                                                                                                             /* ffecfin,
                       */
                          /* ffecmue*/
                                       /*
                  FROM
                       estassegurats*/
                                       /*
                 WHERE
                       sseguro = psseguro);*/
      traspaso_asegurados (psseguro, aux_ssegpol, pnmovimi, mens);

      IF mens IS NOT NULL
      THEN
         RAISE salir;
      END IF;

      paso := 35;
      traspaso_riesgos (psseguro, aux_ssegpol, programa, mens, pnmovimi);

      IF mens IS NOT NULL
      THEN
         RAISE salir;
      END IF;

      paso := 36;
      traspaso_segcbancar (psseguro, aux_ssegpol, pnmovimi, mens);

      IF mens IS NOT NULL
      THEN
         RAISE salir;
      END IF;

      /*bug 21657--ETM-05/06/2012*/
      paso := 90;
      p_traspaso_inquiaval (psseguro, aux_ssegpol, pnmovimi, pfefecto, mens);

      IF mens IS NOT NULL
      THEN
         paso := 91;
         RAISE salir;
      END IF;

      /*fin bug 21657-ETM-05/6/2012*/
      /* Bug 7926 - 01/06/2009 - RSC - Fecha de vencimiento a nivel de garantía*/
      /* Finalizamos seg_cbancar del movimiento anterior*/
      IF programa = 'ALSUP003'
      THEN
         BEGIN
            UPDATE seg_cbancar
               SET ffinefe = pffinefe
             WHERE sseguro = aux_ssegpol
               AND nmovimi <> pnmovimi
               AND ffinefe IS NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               mens := SQLERRM;
         END;

         IF mens IS NOT NULL
         THEN
            RAISE salir;
         END IF;
      END IF;

      /* Fin Bug 7926*/
      paso := 361;

      IF programa = 'ALCTR126'
      THEN
         p_ins_estgar_invisibles (psseguro, pnmovimi, pfefecto, mens);
      END IF;

      IF mens IS NOT NULL
      THEN
         RAISE salir;
      END IF;

      paso := 37;
      /* traspasamos las garantias*/
      traspaso_garantias (psseguro,
                          aux_ssegpol,
                          NULL,
                          programa,
                          mens,
                          pnmovimi,
                          pfefecto
                         );

      IF mens IS NOT NULL
      THEN
         RAISE salir;
      END IF;

      paso := 38;

      /**/
      /* Finalizamos las garantías del movimiento anterior en el caso de que*/
      /* la llamada proceda del ALSUP003.*/
      /**/
      IF programa = 'ALSUP003'
      THEN
         SELECT c.cmovseg
           INTO vcmovseg
           FROM codimotmov c, movseguro m
          WHERE m.sseguro = aux_ssegpol
            AND m.nmovimi = pnmovimi
            AND c.cmotmov = m.cmotmov;

         IF vcmovseg <> 6
         THEN
            BEGIN
               UPDATE garanseg
                  SET ffinefe = pffinefe
                WHERE sseguro = aux_ssegpol
                  AND nmovimi <> pnmovimi
                  AND ffinefe IS NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  mens := SQLERRM;
            END;

            IF mens IS NOT NULL
            THEN
               RAISE salir;
            END IF;
         END IF;
      END IF;

      paso := 39;

      BEGIN
         INSERT INTO primasgaranseg
                     (sseguro, nmovimi, nriesgo, cgarant, finiefe, iextrap,
                      iprianu, ipritar, ipritot, precarg, irecarg, pdtocom,
                      idtocom, itarifa, iconsor, ireccon, iips, idgs,
                      iarbitr, ifng, irecfra, itotpri, itotdto, itotcon,
                      itotimp, icderreg, itotalr, needtarifar, iprireb,
                      itotanu, iiextrap, pdtotec, preccom, idtotec, ireccom,
                      itotrec, iivaimp, iprivigencia)
            (SELECT aux_ssegpol, NVL (pnmovimi, nmovimi), nriesgo, cgarant,
                    finiefe, iextrap, iprianu, ipritar, ipritot, precarg,
                    irecarg, pdtocom, idtocom, itarifa, iconsor, ireccon,
                    iips, idgs, iarbitr, ifng, irecfra, itotpri, itotdto,
                    itotcon, itotimp, icderreg, itotalr, needtarifar,
                    iprireb, itotanu, iiextrap, pdtotec, preccom, idtotec,
                    ireccom, itotrec, iivaimp, iprivigencia
               FROM estprimasgaranseg ep
              WHERE ep.sseguro = psseguro
                AND ep.nmovimi = NVL (pnmovimi, ep.nmovimi));
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      /* Insertamos las preguntas por riesgo*/
      /*// ACC 12022008 afegixo control del nmovimi*/
      /*// ACC 27022008 trec la comprovació de si es nivell poliza o risc*/
      INSERT INTO pregunseg
                  (sseguro, nriesgo, cpregun, crespue, trespue, nmovimi)
         (SELECT aux_ssegpol, nriesgo, cpregun, crespue, trespue,
                 NVL (pnmovimi, nmovimi)
            FROM estpregunseg ep
           WHERE ep.sseguro = psseguro
             AND ep.nmovimi = NVL (pnmovimi, ep.nmovimi));

      INSERT INTO pregunsegtab
                  (sseguro, nriesgo, cpregun, nmovimi, nlinea, ccolumna,
                   tvalor, fvalor, nvalor)
         (SELECT aux_ssegpol, nriesgo, cpregun, NVL (pnmovimi, nmovimi),
                 nlinea, ccolumna, tvalor, fvalor, nvalor
            FROM estpregunsegtab ep
           WHERE ep.sseguro = psseguro
             AND ep.nmovimi = NVL (pnmovimi, ep.nmovimi));

      paso := 40;

      /* Bug 10702. Saldo deutors por riesgo*/
      INSERT INTO saldodeutorseg
                  (sseguro, nmovimi, icapmax)
         (SELECT aux_ssegpol, NVL (pnmovimi, nmovimi), icapmax
            FROM estsaldodeutorseg
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      paso := 457;

      INSERT INTO psu_retenidas
                  (sseguro, nmovimi, fmovimi, cmotret, cnivelbpm, cusuret,
                   ffecret, cusuaut, ffecaut, observ, postpper, perpost)
         (SELECT aux_ssegpol, NVL (pnmovimi, p.nmovimi), p.fmovimi, p.cmotret,
                 p.cnivelbpm, p.cusuret, p.ffecret, p.cusuaut, p.ffecaut,
                 p.observ, p.postpper, p.perpost
            FROM estpsu_retenidas p
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      paso := 417;

      INSERT INTO psucontrolseg
                  (sseguro, nmovimi, fmovpsu, ccontrol, nriesgo, cgarant,
                   cnivelr, nvalor, nvalorinf, nvalorsuper, nvalortope,
                   cusumov, cnivelu, cautrec, fautrec, cusuaur, observ,
                   nocurre, establoquea, autoriprev, autmanual, ordenbloquea,
                   isvisible)
         (SELECT aux_ssegpol, NVL (pnmovimi, p.nmovimi), p.fmovpsu,
                 p.ccontrol, NVL (p.nriesgo, 1), NVL (p.cgarant, 0),
                 p.cnivelr, p.nvalor, p.nvalorinf, p.nvalorsuper,
                 p.nvalortope, p.cusumov, p.cnivelu, p.cautrec, p.fautrec,
                 p.cusuaur, p.observ, NVL (p.nocurre, 1), p.establoquea,
                 p.autoriprev, p.autmanual, p.ordenbloquea, p.isvisible
            FROM estpsucontrolseg p
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      BEGIN
         paso := 416;

         INSERT INTO riesgos_ir
                     (sseguro, nriesgo, nmovimi, cinspreq, cresultr,
                      tperscontacto, ttelcontacto, tmailcontacto,
                      crolcontacto)
            (SELECT aux_ssegpol, NVL (nriesgo, 1), NVL (pnmovimi, nmovimi),
                    cinspreq, cresultr, tperscontacto, ttelcontacto,
                    tmailcontacto, crolcontacto
               FROM estriesgos_ir
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

         paso := 418;

         INSERT INTO riesgos_ir_ordenes
                     (sseguro, nriesgo, nmovimi, cempres, sorden, cnueva,
                      sinterf1, sinterf2)
            (SELECT aux_ssegpol, NVL (nriesgo, 1), NVL (pnmovimi, nmovimi),
                    cempres, sorden, cnueva, sinterf1, sinterf2
               FROM estriesgos_ir_ordenes
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

         paso := 419;

         INSERT INTO basequestion_undw
                     (sseguro, nriesgo, nmovimi, cempres, sorden, code,
                      POSITION, CATEGORY, norden, question, answer, naseg)
            (SELECT aux_ssegpol, NVL (nriesgo, 1), NVL (pnmovimi, nmovimi),
                    cempres, sorden, code, POSITION, CATEGORY, norden,
                    question, answer, naseg
               FROM estbasequestion_undw
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

         paso := 4190;

         INSERT INTO actions_undw
                     (sseguro, nriesgo, nmovimi, cempres, sorden, norden,
                      action, naseg)
            (SELECT aux_ssegpol, NVL (nriesgo, 1), NVL (pnmovimi, nmovimi),
                    cempres, sorden, norden, action, naseg
               FROM estactions_undw
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

         paso := 420;

         INSERT INTO exclusiones_undw
                     (sseguro, nriesgo, nmovimi, cempres, sorden, norden,
                      codegar, label, codexclus, naseg)
            (SELECT aux_ssegpol, NVL (nriesgo, 1), NVL (pnmovimi, nmovimi),
                    cempres, sorden, norden, codegar, label, codexclus,
                    naseg
               FROM estexclusiones_undw
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

         paso := 421;

         INSERT INTO enfermedades_undw
                     (sseguro, nriesgo, nmovimi, cempres, sorden, norden,
                      cindex, codenf, desenf)
            (SELECT aux_ssegpol, NVL (nriesgo, 1), NVL (pnmovimi, nmovimi),
                    cempres, sorden, norden, cindex, codenf, desenf
               FROM estenfermedades_undw
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

         paso := 422;
      EXCEPTION
         WHEN OTHERS
         THEN
            paso := 420;
      END;

      INSERT INTO bf_bonfranseg
                  (sseguro, nriesgo, cgrup, csubgrup, cnivel, cversion,
                   nmovimi, finiefe, ctipgrup, cvalor1, impvalor1, cvalor2,
                   impvalor2, cimpmin, impmin, cimpmax, impmax, ffinefe,
                   cniveldefecto)
         (SELECT aux_ssegpol, b.nriesgo, b.cgrup, b.csubgrup, b.cnivel,
                 b.cversion, b.nmovimi, b.finiefe, b.ctipgrup, b.cvalor1,
                 b.impvalor1, b.cvalor2, b.impvalor2, b.cimpmin, b.impmin,
                 b.cimpmax, b.impmax, b.ffinefe, b.cniveldefecto
            FROM estbf_bonfranseg b
           WHERE b.sseguro = psseguro
             AND b.nmovimi = NVL (pnmovimi, b.nmovimi)
             AND b.cnivel IS NOT NULL);

      -- INI SPV IAXIS-4201
      FOR i IN c_cgrup
      LOOP
         --
         UPDATE bf_detnivel
            SET cdefecto = 'N'
          WHERE cgrup = i.cgrup AND cdefecto = 'S';

         --
         UPDATE bf_detnivel
            SET cdefecto = 'S'
          WHERE cgrup = i.cgrup AND cnivel = 3;
      --
      END LOOP;

       -- FIN SPV IAXIS-4201
      /* Bug 11165 - 16/09/2009 - AMC - Se sustituñe  detsaldodeutorseg por prestamoseg*/
      /*INSERT INTO prestamoseg
                                                         (sseguro, nriesgo, nmovimi, ctapres, ctipcuenta, ctipban, ctipimp, isaldo,
                porcen, ilimite, icapmax, icapital, cmoneda, icapaseg)
      (SELECT aux_ssegpol, nriesgo, NVL(pnmovimi, nmovimi), ctapres, ctipcuenta, ctipban,
              ctipimp, isaldo, porcen, ilimite, icapmax, icapital, cmoneda, icapaseg
         FROM estprestamoseg
        WHERE sseguro = psseguro
          AND nmovimi = NVL(pnmovimi, nmovimi));*/
      /* Fin Bug 10702. Saldo deutors*/
      /* Otras tablas*/
      /* Bug 30642/169851 - 20/03/2014 - AMC*/
      INSERT INTO comisionsegu
                  (sseguro, cmodcom, pcomisi, ninialt, nfinalt, nmovimi)
         (SELECT aux_ssegpol, cmodcom, pcomisi, ninialt, nfinalt, nmovimi
            FROM estcomisionsegu
           WHERE sseguro = psseguro
             AND nmovimi =
                    NVL (pnmovimi, nmovimi)
                                      /* Bug 32595/182234 - 28/08/2014 - AMC*/
                                           );

      paso := 41;

      /* INI BUG 34461, 34462 - Productos de CONVENIOS*/
      INSERT INTO cnv_conv_emp_seg
                  (sseguro, nmovimi, idversion)
         (SELECT aux_ssegpol, nmovimi, idversion
            FROM estcnv_conv_emp_seg
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      /* FIN BUG 34461, 34462 - Productos de CONVENIOS*/
      INSERT INTO coacuadro
                  (sseguro, ncuacoa, finicoa, ffincoa, ploccoa, fcuacoa,
                   ccompan, npoliza, nendoso)
         (SELECT aux_ssegpol, NVL (pnmovimi, ncuacoa), finicoa, ffincoa,
                 ploccoa, f_sysdate, ccompan, npoliza, nendoso
            FROM estcoacuadro
           WHERE sseguro = psseguro                       /* Fin Bug 0023183*/
             AND ncuacoa = NVL (pnmovimi, ncuacoa));

      /* Fin Bug 0023183*/
      UPDATE seguros
         SET ncuacoa = NVL (pnmovimi, ncuacoa)
       WHERE sseguro = aux_ssegpol;

      paso := 42;

      INSERT INTO coacedido
                  (sseguro, ncuacoa, ccompan, pcescoa, pcomcoa, pcomcon,
                   pcomgas, pcesion)
         (SELECT aux_ssegpol, NVL (pnmovimi, ncuacoa), ccompan, pcescoa,
                 pcomcoa, pcomcon, pcomgas, pcesion
            FROM estcoacedido
           WHERE sseguro = psseguro                       /* Fin Bug 0023183*/
             AND ncuacoa = NVL (pnmovimi, ncuacoa));

      paso := 43;

      /* Cláusulas*/
      INSERT INTO claubenseg
                  (nmovimi, sclaben, sseguro, nriesgo, finiclau, ffinclau)
         (SELECT NVL (pnmovimi, nmovimi), sclaben, aux_ssegpol, nriesgo,
                 NVL (pfefecto, finiclau), ffinclau
            FROM estclaubenseg
           WHERE sseguro = psseguro
             AND nmovimi = NVL (pnmovimi, nmovimi)
             AND NVL (cobliga, 1) = 1);

      paso := 44;

      INSERT INTO clausuesp
                  (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau,
                   sclagen, tclaesp, ffinclau)
         (SELECT NVL (pnmovimi, nmovimi), aux_ssegpol, cclaesp, nordcla,
                 nriesgo, NVL (pfefecto, finiclau), sclagen, tclaesp,
                 ffinclau
            FROM estclausuesp
           WHERE sseguro = psseguro
             AND nmovimi = NVL (pnmovimi, nmovimi)
             AND cclaesp = DECODE (programa, 'ALCTR126', cclaesp, 1));

      paso := 45;

      /*Bug.: 19152 - 20/10/2011 - ICV*/
      /* Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado*/
      INSERT INTO benespseg
                  (sseguro, nriesgo, cgarant, nmovimi, sperson, sperson_tit,
                   finiben, ffinben, ctipben, cparen, pparticip, cestado,
                   ctipocon)
         (SELECT aux_ssegpol, nriesgo, cgarant, NVL (pnmovimi, nmovimi),
                 NVL (pac_persona.f_sperson_spereal (sperson), sperson),
                 NVL (NVL (pac_persona.f_sperson_spereal (sperson_tit),
                           sperson_tit
                          ),
                      0
                     ),
                 finiben, ffinben, ctipben, cparen, pparticip, cestado,
                 ctipocon
            FROM estbenespseg
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      paso := 451;

      /* BUG11288:DRA:20/10/2009:Inici*/
      INSERT INTO motretencion
                  (sseguro, nriesgo, nmovimi, cmotret, cusuret, freten,
                   nmotret)
         (SELECT aux_ssegpol, nriesgo, NVL (pnmovimi, nmovimi), cmotret,
                 cusuret, freten, nmotret
            FROM estmotretencion
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      paso := 451;

      INSERT INTO motreten_rev
                  (sseguro, nriesgo, nmovimi, cmotret, nmotret, nmotrev,
                   cusuauto, fusuauto, cresulta, tobserva)
         (SELECT aux_ssegpol, nriesgo, NVL (pnmovimi, nmovimi), cmotret,
                 nmotret, nmotrev, cusuauto, fusuauto, cresulta, tobserva
            FROM estmotreten_rev
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      /* BUG11288:DRA:20/10/2009:Fi*/
      paso := 46;

      UPDATE detmovseguro d
         SET d.tvalora =
                (SELECT ee.tvalora
                   FROM estdetmovseguro ee
                  WHERE ee.sseguro = psseguro
                    AND ee.nmovimi = d.nmovimi
                    AND ee.nriesgo = d.nriesgo
                    AND ee.cmotmov = d.cmotmov
                    AND ee.cgarant = d.cgarant
                    AND ee.cpregun = d.cpregun),
             d.tvalord =
                (SELECT ee.tvalord
                   FROM estdetmovseguro ee
                  WHERE ee.sseguro = psseguro
                    AND ee.nmovimi = d.nmovimi
                    AND ee.nriesgo = d.nriesgo
                    AND ee.cmotmov = d.cmotmov
                    AND ee.cgarant = d.cgarant
                    AND ee.cpregun = d.cpregun)
       WHERE (d.sseguro,
              d.nmovimi,
              d.nriesgo,
              d.cmotmov,
              d.cgarant,
              d.cpregun
             ) IN (
                SELECT aux_ssegpol, e.nmovimi, e.nriesgo, e.cmotmov,
                       e.cgarant, e.cpregun
                  FROM estdetmovseguro e
                 WHERE e.sseguro = psseguro
                   AND e.nmovimi = NVL (pnmovimi, e.nmovimi));

      paso := 47;

      /* Bug 24278 - APD - 10/12/2012 - se añade el campo cpropagasupl*/
      INSERT INTO detmovseguro
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                   tvalord, cpregun, cpropagasupl)
         (SELECT aux_ssegpol, NVL (pnmovimi, e.nmovimi), e.cmotmov, e.nriesgo,
                 e.cgarant, e.tvalora, e.tvalord, e.cpregun, e.cpropagasupl
            FROM estdetmovseguro e
           WHERE e.sseguro = psseguro
             AND e.nmovimi = NVL (pnmovimi, e.nmovimi)
             AND NOT EXISTS (
                    SELECT cmotmov
                      FROM detmovseguro
                     WHERE sseguro = aux_ssegpol
                       AND nmovimi = e.nmovimi
                       AND nriesgo = e.nriesgo
                       AND cmotmov = e.cmotmov
                       AND cgarant = e.cgarant
                       AND cpregun = e.cpregun));

      /* fin Bug 24278 - APD - 10/12/2012*/
      paso := 48;

      INSERT INTO penaliseg
                  (sseguro, nmovimi, ctipmov, niniran, nfinran, ipenali,
                   ppenali, clave)
         (SELECT aux_ssegpol, NVL (pnmovimi, e.nmovimi), e.ctipmov, e.niniran,
                 e.nfinran, e.ipenali, e.ppenali, e.clave
            FROM estpenaliseg e
           WHERE e.sseguro = psseguro);

      paso := 49;

      /* RSC 16-07-2007 (productos multilink) ---------------------------------------------------------------*/
      INSERT INTO segdisin2
                  (sseguro, nriesgo, nmovimi, finicio, ffin, ccesta, pdistrec,
                   pdistuni, pdistext)
         (SELECT aux_ssegpol, e.nriesgo, NVL (pnmovimi, e.nmovimi), e.finicio,
                 e.ffin, e.ccesta, e.pdistrec, e.pdistuni, e.pdistext
            FROM estsegdisin2 e
           WHERE e.sseguro = psseguro);

      paso := 50;

/*-----------------------------------------------------------------------------------------------------*/
/* Ini Bug 0025955 --ECP -- 01/02/2013*/
      IF NVL (pac_parametros.f_parproducto_n (v_cnvpol.producte,
                                              'PERMITE_PREST'
                                             ),
              0
             ) <> 1
      THEN
         /*
                                                   {antes de insertar  un nuevo registro nos aseguramos que hayan cambiado el procenataje}
         */
         IF programa = 'ALSUP003'
         THEN
            SELECT COUNT (1)
              INTO prestamos
              FROM prestamoseg p, estprestamoseg e
             WHERE e.sseguro = psseguro
               AND p.sseguro = aux_ssegpol
               AND (   NVL (p.pporcen, 0) <> NVL (e.pporcen, 0)
                    /* BUG11618:DRA:06/11/2009*/
                    OR NVL (p.ilimite, 0) <> NVL (e.ilimite, 0)
                    /* BUG11618:DRA:06/11/2009*/
                    OR NVL (p.icapmax, 0) <> NVL (e.icapmax, 0)
                    /* BUG11618:DRA:06/11/2009*/
                    OR NVL (p.icapital, 0) <> NVL (e.icapital, 0)
                    /* BUG11618:DRA:06/11/2009*/
                    OR NVL (p.icapaseg, 0) <> NVL (e.icapaseg, 0)
                    /* BUG11618:DRA:06/11/2009*/
                    OR NVL (p.isaldo, 0) <> NVL (e.isaldo, 0)
                   )                              /* BUG11618:DRA:06/11/2009*/
               AND p.ffinprest IS NULL;

            paso := 51;

            /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                              {Controlamos que no sea la primera vez que lo tratan
            */
            IF prestamos > 0
            THEN
               UPDATE prestamoseg
                  SET ffinprest = pffinefe
                WHERE ffinprest IS NULL AND sseguro = aux_ssegpol;
            END IF;
         END IF;

         paso := 52;

         /* ini Bug 0010908 - 11/01/2010 - JMF: Control duplicat*/
         /* buscar si existeix a la cabçelera i no en els fills.*/
         DECLARE
            CURSOR c1
            IS
               SELECT ctapres, isaldo, falta, ilimite
                 FROM estprestamoseg
                WHERE sseguro = psseguro
                      AND nmovimi = NVL (pnmovimi, nmovimi);

            d_altaold   DATE;
         BEGIN
            paso := 100;

            FOR f1 IN c1
            LOOP
               paso := 105;

               /* Bug 0010908 - 19/01/2010 - JMF*/
               SELECT MAX (a.falta)
                 INTO d_altaold
                 FROM prestamos a
                WHERE a.ctapres = f1.ctapres
                  AND a.fbaja IS NULL
                  AND TO_CHAR (a.falta, 'yyyymm') =
                                                  TO_CHAR (f1.falta, 'yyyymm');

               IF d_altaold IS NULL
               THEN
                  /* Bug 11301 - APD - 22/10/2009 - antes de insertar en la tabla Prestamoseg se debe*/
                  /* insertar en la tabla Prestamos ya que realmente al insertar en prestamoseg lo que*/
                  /* se está haciendo es dar de alta un nuevo prestamo*/
                  /* la FALTA será el mismo que hay en la tabla ESTPRESTAMOSEG*/
                  /* Bug 0010908 - 17/12/2009 - JMF: Afegir ilimite*/
                  BEGIN
                     paso := 110;

                     INSERT INTO prestamos
                                 (ctapres, icapini, falta, ilimite)
                        (SELECT ctapres, isaldo, falta, ilimite
                           FROM estprestamoseg
                          WHERE sseguro = psseguro
                            AND ctapres =
                                        f1.ctapres
                                                  /* BUG12421:DRA:28/01/2010*/
                            AND nmovimi = NVL (pnmovimi, nmovimi));
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                  END;
               ELSE
                  /* Actualitzar el registre de cabçelera*/
                  paso := 115;

                  UPDATE prestamos
                     SET icapini = f1.isaldo,
                         ilimite = f1.ilimite
                   WHERE ctapres = f1.ctapres AND falta = d_altaold;

                  paso := 116;

                  UPDATE estprestamoseg
                     SET falta = d_altaold
                   WHERE sseguro = psseguro
                     AND ctapres = f1.ctapres     /* BUG12421:DRA:28/01/2010*/
                     AND falta <> d_altaold
                     AND nmovimi = NVL (pnmovimi, nmovimi);
               END IF;
            END LOOP;
         END;

         /* fin Bug 0010908 - 11/01/2010 - JMF: Control duplicat*/
         paso := 53;

         /* Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el insert*/
         INSERT INTO prestamoseg
                     (sseguro, nriesgo, nmovimi, ctapres, finiprest,
                      ffinprest, ctipcuenta, ctipban, ctipimp, isaldo,
                      pporcen, porcen, ilimite, icapmax, icapital, cmoneda,
                      icapaseg, falta, descripcion)
            (SELECT aux_ssegpol, nriesgo, NVL (pnmovimi, nmovimi), ctapres,
                    NVL (finiprest, pffinefe), ffinprest, ctipcuenta, ctipban,
                    ctipimp, isaldo, pporcen, porcen, ilimite, icapmax,
                    icapital, cmoneda, icapaseg, falta, descripcion
               FROM estprestamoseg
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

         paso := 55;

         IF programa = 'ALSUP003'
         THEN
            /*
                                                     { Miramos si el cuadro ha sufrido alguna modificación}
            */
            BEGIN
               SELECT COUNT (1)
                 INTO prestamos
                 FROM (SELECT icapital, iinteres, icappend
                         FROM estprestcuadroseg
                        WHERE sseguro = psseguro
                       MINUS
                       SELECT icapital, iinteres, icappend
                         FROM prestcuadroseg
                        WHERE sseguro = aux_ssegpol AND ffincuaseg IS NULL);
            END;

            paso := 56;

            /*
                                                                           {Si hay suplemento y modifcaciones en el cuadro entonces lo duplicamos}
            */
            IF prestamos > 0
            THEN
               /*BEGIN*/
               UPDATE prestcuadroseg
                  SET ffincuaseg = pffinefe
                WHERE sseguro = aux_ssegpol AND ffincuaseg IS NULL;

               paso := 57;

               /* Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el insert*/
               INSERT INTO prestcuadroseg
                           (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg,
                            fefecto, fvencim, icapital, iinteres, icappend,
                            falta)
                  (SELECT ctapres, aux_ssegpol, NVL (pnmovimi, nmovimi),
                          NVL (pffinefe, finicuaseg), ffincuaseg, fefecto,
                          fvencim, icapital, iinteres, icappend, falta
                     FROM estprestcuadroseg
                    WHERE sseguro = psseguro
                      AND nmovimi = NVL (pnmovimi, nmovimi));

               paso := 57;
            /*EXCEPTION*/
            /*WHEN OTHERS THEN*/
            /*p_tahiti_error(null, 'traspàs',sqlerrm);*/
            /*END;*/
            END IF;
         ELSE
            /* Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el insert*/
            INSERT INTO prestcuadroseg
                        (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg,
                         fefecto, fvencim, icapital, iinteres, icappend,
                         falta)
               (SELECT ctapres, aux_ssegpol, NVL (pnmovimi, nmovimi),
                       NVL (pffinefe, finicuaseg), ffincuaseg, fefecto,
                       fvencim, icapital, iinteres, icappend, falta
                  FROM estprestcuadroseg
                 WHERE sseguro = psseguro
                   AND nmovimi = NVL (pnmovimi, nmovimi));

            paso := 58;
         END IF;

         /*JRH 09/2007 Tarea 2674: Intereses para LRC. Añadimos ndesde y nhasta.*/
         INSERT INTO intertecseg
                     (sseguro, nmovimi, fefemov, fmovdia, pinttec, ndesde,
                      nhasta, ninntec)
            (SELECT aux_ssegpol, nmovimi, fefemov, fmovdia, pinttec, ndesde,
                    nhasta, ninntec
               FROM estintertecseg
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

         paso := 59;

         INSERT INTO evoluprovmatseg
                     (sseguro, nmovimi, nanyo, fprovmat, iprovmat, icapfall,
                      prescate, pinttec, iprovest, ivalres, iprima, nscenario)
/* Bug 14598 - RSC - 22/06/2010 - CEM800 - Información adicional en pantallas y documentos*/
            (SELECT aux_ssegpol, nmovimi, nanyo, fprovmat, iprovmat, icapfall,
                    prescate, pinttec, iprovest, ivalres, iprima,
                    nscenario
/* Bug 14598 - RSC - 22/06/2010 - CEM800 - Información adicional en pantallas y documentos*/
               FROM estevoluprovmatseg
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));
      END IF;

      /* Fin  Bug 0025955 --ECP -- 01/02/2013*/
      paso := 60;

      /* INSERT INTO EXCLUGARSEG*/
                                   /*
                       (SSEGURO, NRIESGO, CGARANT, NMOVIMI, FINIEFE, NMOVIMA)*/
                                                                                /* (

                SELECT
                       AUX_SSEGPOL, NRIESGO, CGARANT, NMOVIMI, FINIEFE, NMOVIMA*/
                                                                                  /*

                  FROM
                       ESTEXCLUGARSEG*/
                                        /*
                 WHERE
                       sseguro = psseguro*/ /* and nmovimi = NVL(pnmovimi, nmovimi));*/
      IF programa = 'ALSUP003'
      THEN
         /* Si hemos hecho algún INSERT en ESTCLAUBENSEG o ESTCLASUESP
         (cclaesp = 1), ENTONCES*/ /* anulamos los registros del movimiento anterior*/
         SELECT COUNT (*)
           INTO reg_benseg
           FROM estclaubenseg e
          WHERE e.sseguro = psseguro
            AND e.nmovimi = pnmovimi
            AND NVL (cobliga, 1) = 1
            AND (e.nriesgo, e.sclaben) NOT IN (
                   SELECT c.nriesgo, c.sclaben
                     FROM claubenseg c
                    WHERE c.sseguro = aux_ssegpol
                      AND c.ffinclau IS NULL
                      AND c.nmovimi <> pnmovimi
                      AND e.sclaben = c.sclaben);

         paso := 61;

         /* Que la clausula sea nueva*/
         SELECT COUNT (*)
           INTO reg_esp
           FROM estclausuesp
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND cclaesp = 1
            AND (nriesgo, tclaesp) NOT IN (
                   SELECT nriesgo, tclaesp
                     FROM clausuesp
                    WHERE sseguro = aux_ssegpol
                      AND ffinclau IS NULL
                      AND cclaesp = 1
                      AND nmovimi < pnmovimi);

         paso := 62;
         /*Bug.: 19152 - 07/11/2011 - ICV*/
         paso := 631;
         /* SELECT COUNT(*)
                                                                          INTO reg_ben
           FROM estbenespseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND(nriesgo, cgarant,sperson_tit,sperson) NOT IN(SELECT nriesgo, cgarant,sperson_tit,sperson
                                           FROM benespseg
                                          WHERE sseguro = aux_ssegpol
                                            AND FFINBEN IS NULL
                                            AND nmovimi < pnmovimi);
         */
         paso := 632;
         /* if reg_ben > 0 then*/
         paso := 633;

         UPDATE benespseg
            SET ffinben = pffinefe
          WHERE sseguro = aux_ssegpol
            AND nmovimi <> pnmovimi
            AND ffinben IS NULL;

         /* else
                                                                          paso := 634;
            UPDATE benespseg
               SET FFINBEN = pffinefe
             WHERE sseguro = aux_ssegpol
               AND nmovimi <> pnmovimi
               AND FFINBEN IS NULL
               AND nriesgo IN(SELECT nriesgo
                                FROM riesgos
                               WHERE sseguro = aux_ssegpol
                                 AND nmovimb = pnmovimi);
         end if;  */
         paso := 635;

         /*fi Bug.: 19152*/
         /* Que la clausula la hayan modificado*/
         IF reg_esp = 0
         THEN
            SELECT COUNT (*)
              INTO reg_esp
              FROM estclausuesp
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND cclaesp = 1
               AND (nriesgo, tclaesp) NOT IN (
                      SELECT nriesgo, tclaesp
                        FROM clausuesp
                       WHERE sseguro = aux_ssegpol
                         AND cclaesp = 1
                         AND ffinclau IS NULL
                         AND nmovimi <> pnmovimi);
         END IF;

         paso := 63;

         IF reg_benseg + reg_esp > 0
         THEN
            /* si se han insertado registros nuevos*/
            UPDATE claubenseg
               SET ffinclau = pffinefe
             WHERE sseguro = aux_ssegpol
               AND nmovimi <> pnmovimi
               AND ffinclau IS NULL;

            paso := 64;

            /* Finalizamos las clausulas especiales del movimiento anterior*/
            UPDATE clausuesp
               SET ffinclau = pffinefe
             WHERE sseguro = aux_ssegpol
               AND nmovimi <> pnmovimi
               AND ffinclau IS NULL
               AND cclaesp = 1;

            paso := 65;
         ELSE
            /* miramos si han anulado algún riesgo, entonces sólo se finaliza el registro*/
            /* anterior*/
            UPDATE claubenseg
               SET ffinclau = pffinefe
             WHERE sseguro = aux_ssegpol
               AND ffinclau IS NULL
               AND nmovimi <> pnmovimi
               AND nriesgo IN (
                            SELECT nriesgo
                              FROM riesgos
                             WHERE sseguro = aux_ssegpol
                                   AND nmovimb = pnmovimi);

            paso := 66;

            UPDATE clausuesp
               SET ffinclau = pffinefe
             WHERE sseguro = aux_ssegpol
               AND nmovimi <> pnmovimi
               AND ffinclau IS NULL
               AND cclaesp = 1
               AND nriesgo IN (
                            SELECT nriesgo
                              FROM riesgos
                             WHERE sseguro = aux_ssegpol
                                   AND nmovimb = pnmovimi);

            paso := 67;

            DELETE      claubenseg
                  WHERE sseguro = aux_ssegpol AND nmovimi = pnmovimi;

            paso := 68;

            DELETE      clausuesp
                  WHERE sseguro = aux_ssegpol
                    AND nmovimi = pnmovimi
                    AND cclaesp = 1;

            paso := 69;

            /* BUG14818:DRA:09/06/2010:Inici: Miramos si han desmarcado o borrado la clàusula*/
            UPDATE claubenseg c
               SET c.ffinclau = pffinefe
             WHERE c.sseguro = aux_ssegpol
               AND c.nmovimi <> pnmovimi
               AND c.ffinclau IS NULL
               AND (c.nriesgo, c.sclaben) NOT IN (
                           SELECT e.nriesgo, e.sclaben
                             FROM estclaubenseg e
                            WHERE e.sseguro = psseguro
                                  AND e.nmovimi = pnmovimi);

            paso := 691;

            UPDATE clausuesp c
               SET c.ffinclau = pffinefe
             WHERE c.sseguro = aux_ssegpol
               AND c.nmovimi <> pnmovimi
               AND c.ffinclau IS NULL
               AND c.cclaesp = 1
               AND (c.nriesgo, c.tclaesp) NOT IN (
                      SELECT e.nriesgo, e.tclaesp
                        FROM estclausuesp e
                       WHERE e.sseguro = psseguro
                         AND e.nmovimi = pnmovimi
                         AND e.cclaesp = 1);
         /* BUG14818:DRA:09/06/2010:Fi*/
         END IF;

         /* Clausulas especiales ligadas a preguntas y garantias*/
         INSERT INTO clausuesp
                     (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau,
                      sclagen, tclaesp, ffinclau)
            (SELECT pnmovimi, aux_ssegpol, cclaesp, nordcla, nriesgo,
                    NVL (pffinefe, finiclau), sclagen, tclaesp, ffinclau
               FROM estclausuesp
              WHERE sseguro = psseguro
                AND nmovimi = pnmovimi
                AND cclaesp IN (3, 4));

         paso := 70;

         /* CLAUSULAS ESPECIALES*/
         INSERT INTO clausuesp
                     (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau,
                      sclagen, tclaesp, ffinclau)
            (SELECT pnmovimi, aux_ssegpol, cclaesp, nordcla, nriesgo,
                    NVL (pffinefe, finiclau), sclagen, tclaesp, ffinclau
               FROM estclausuesp
              WHERE sseguro = psseguro AND nmovimi = pnmovimi AND cclaesp = 2);

         paso := 71;

         /* Que la clausula sea nueva*/
         SELECT COUNT (*)
           INTO reg_esp0
           FROM estclausuesp e
          WHERE e.sseguro = psseguro
            AND e.nmovimi = pnmovimi
            AND e.cclaesp = 2
            AND (NOT EXISTS (
                    SELECT tclaesp
                      FROM clausuesp
                     WHERE sseguro = aux_ssegpol
                       AND ffinclau IS NULL
                       AND cclaesp = 2
                       AND nordcla = e.nordcla
                       AND nmovimi < pnmovimi)
                );

         paso := 72;

         /* Que la clausula la hayan modificado*/
         IF reg_esp0 = 0
         THEN
            SELECT COUNT (*)
              INTO reg_esp0
              FROM estclausuesp
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND cclaesp = 2
               AND tclaesp NOT IN (
                      SELECT tclaesp
                        FROM clausuesp
                       WHERE sseguro = aux_ssegpol
                         AND cclaesp = 2
                         AND ffinclau IS NULL
                         AND nmovimi <> pnmovimi);
         END IF;

         paso := 73;

         IF reg_esp0 > 0
         THEN
            /* si se han insertado registros nuevos*/
            UPDATE clausuesp
               SET ffinclau = pffinefe
             WHERE sseguro = aux_ssegpol
               AND nmovimi <> pnmovimi
               AND ffinclau IS NULL
               AND cclaesp = 2;

            paso := 74;
         ELSE
            /* BUG9217:DRA:7-04-2009: Inici*/
            /* Miramos si se ha dado de baja alguna clausula*/
            SELECT COUNT (*)
              INTO reg_esp0
              FROM clausuesp
             WHERE sseguro = aux_ssegpol
               AND nmovimi < pnmovimi
               AND ffinclau IS NULL
               AND cclaesp = 2
               AND tclaesp NOT IN (
                      SELECT tclaesp
                        FROM estclausuesp
                       WHERE sseguro = psseguro
                         AND nmovimi = pnmovimi
                         AND cclaesp = 2);

            IF reg_esp0 = 0
            THEN
               paso := 751;

               /* No se ha realizado ninguna modificación*/
               UPDATE clausuesp
                  SET ffinclau = pffinefe
                WHERE sseguro = aux_ssegpol
                  AND nmovimi <> pnmovimi
                  AND ffinclau IS NULL
                  AND cclaesp = 2
                  AND nriesgo IN (
                            SELECT nriesgo
                              FROM riesgos
                             WHERE sseguro = aux_ssegpol
                                   AND nmovimb = pnmovimi);

               paso := 752;

               DELETE      clausuesp
                     WHERE sseguro = aux_ssegpol
                       AND nmovimi = pnmovimi
                       AND cclaesp = 2;
            ELSE
               /* Se ha eliminado alguna clausula*/
               paso := 753;

               UPDATE clausuesp
                  SET ffinclau = pffinefe
                WHERE sseguro = aux_ssegpol
                  AND nmovimi < pnmovimi
                  AND ffinclau IS NULL
                  AND cclaesp = 2
                  AND tclaesp NOT IN (
                         SELECT tclaesp
                           FROM estclausuesp
                          WHERE sseguro = psseguro
                            AND nmovimi = pnmovimi
                            AND cclaesp = 2);

               paso := 754;

               DELETE      clausuesp
                     WHERE sseguro = aux_ssegpol
                       AND nmovimi = pnmovimi
                       AND cclaesp = 2;
            END IF;
         /* BUG9217:DRA:7-04-2009: Fi*/
         END IF;

         paso := 76;

         /* Si hemos hecho algún INSERT en ESTCLAUESP
         (cclaesp IN(3,4), ENTONCES*/ /* anulamos los registros del movimiento anterior*/
         SELECT COUNT (*)
           INTO reg_esp2
           FROM estclausuesp
          WHERE sseguro = psseguro AND nmovimi = pnmovimi
                AND cclaesp IN (3, 4);

         paso := 77;

         /*  IF reg_esp2 > 0*/
         /*THEN                          -- si se han insertado registros nuevos*/
         /* Finalizamos las clausulas especiales del movimiento anterior*/
         UPDATE clausuesp
            SET ffinclau = pffinefe
          WHERE sseguro = aux_ssegpol
            AND nmovimi <> pnmovimi
            AND ffinclau IS NULL
            AND cclaesp IN (3, 4);

         paso := 78;
      /*END IF;*/
      END IF;

      BEGIN
         INSERT INTO claususeg
                     (sseguro, sclagen, nmovimi, finiclau, ffinclau, nordcla)
            (SELECT aux_ssegpol, sclagen, pnmovimi, NVL (pfefecto, finiclau),
                    ffinclau, nordcla
               FROM estclaususeg
              WHERE sseguro = psseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      /* Bug 16726 - RSC - 13/01/2010 - APR - clauses definition*/
      BEGIN
         INSERT INTO clausubloq
                     (sseguro, nmovimi, nriesgo, sclagen)
            (SELECT aux_ssegpol, nmovimi, nriesgo, sclagen
               FROM estclausubloq
              WHERE sseguro = psseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      /* Fin Bug 16726*/
      paso := 79;

      IF programa = 'ALCTR126'
      THEN
         BEGIN
            INSERT INTO clauparseg
                        (sseguro, sclagen, nparame, tvalor, ctippar)
               (SELECT aux_ssegpol, sclagen, nparame, tvalor, ctippar
                  FROM estclauparseg
                 WHERE sseguro = psseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         INSERT INTO clauparesp
                     (sseguro, nriesgo, nmovimi, sclagen, nparame, cclaesp,
                      nordcla, tvalor, ctippar)
            (SELECT aux_ssegpol, nriesgo, nmovimi, sclagen, nparame, cclaesp,
                    nordcla, tvalor, ctippar
               FROM estclauparesp
              WHERE sseguro = psseguro);

         /* JDC 06/08/02*/
         INSERT INTO resulseg
                     (clave, sseguro, nriesgo, nmovimi, cgarant, finiefe,
                      nresult)
            (SELECT clave, aux_ssegpol, nriesgo, nmovimi, cgarant, finiefe,
                    nresult
               FROM estresulseg
              WHERE sseguro = psseguro);
      ELSE
         /**/
         /* ALSUP003*/
         /**/
         SELECT COUNT (*)
           INTO reg_clau
           FROM estclaususeg
          WHERE sseguro = psseguro AND nmovimi = pnmovimi;

         IF reg_clau > 0
         THEN
            UPDATE claususeg
               SET ffinclau = pffinefe
             WHERE sseguro = aux_ssegpol
               AND nmovimi <> pnmovimi
               AND ffinclau IS NULL;
         END IF;

         SELECT COUNT (*)
           INTO reg_clau2
           FROM estclauparseg
          WHERE sseguro = psseguro;

         IF reg_clau2 > 0
         THEN
            INSERT INTO clauparseg
                        (sseguro, sclagen, nparame, tvalor, ctippar)
               (SELECT aux_ssegpol, sclagen, nparame, tvalor, ctippar
                  FROM estclauparseg
                 WHERE sseguro = psseguro);
         END IF;

         INSERT INTO clauparesp
                     (sseguro, nriesgo, nmovimi, sclagen, nparame, cclaesp,
                      nordcla, tvalor, ctippar)
            (SELECT aux_ssegpol, nriesgo, pnmovimi, sclagen, nparame, cclaesp,
                    nordcla, tvalor, ctippar
               FROM estclauparesp
              WHERE sseguro = psseguro);
      END IF;                                                 -- de 'alctr126'

      paso := 80;

      /* **** insercció valors de taules dinàmiques i/o estàtiques ***** (sls)*/
      BEGIN
         INSERT INTO tbseguserfilas
                     (sseguro, nriesgo, nmovimi, stabla, nuserfila)
            (SELECT aux_ssegpol, nriesgo, nmovimi, stabla, nuserfila
               FROM tbestuserfilas
              WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      paso := 81;

      BEGIN
         INSERT INTO tbsegdettabla
                     (sseguro, nriesgo, nmovimi, stabla, nuserfila, cvalor,
                      nvalor, tvalor, dvalor)
            (SELECT aux_ssegpol, nriesgo, nmovimi, stabla, nuserfila, cvalor,
                    nvalor, tvalor, dvalor
               FROM tbestdettabla
              WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      paso := 82;

      BEGIN
         INSERT INTO tbsegfilastabla
                     (sseguro, nriesgo, nmovimi, stabla, nfila, tvalor)
            (SELECT aux_ssegpol, nriesgo, nmovimi, stabla, nfila, tvalor
               FROM tbestfilastabla
              WHERE sseguro = psseguro);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      paso := 83;

      /* SBG 04/2008*/
      /* INSERTEM EL POLISSA_INI A CNVPOLIZAS*/
      IF v_cnvpol.polissa_ini IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO num_err
                  /* UTILITZEM AQUESTA VARIABLE PER NO DECLARAR-NE UNA ALTRA*/
           FROM cnvpolizas
          WHERE sseguro = aux_ssegpol;

         IF num_err = 0
         THEN
            INSERT INTO cnvpolizas
                        (sistema, polissa_ini, producte, aplica,
                         ram, moda, npoliza,
                         sseguro, activitat, tipo,
                         cole, cdescuadre
                        )
                 VALUES ('0', v_cnvpol.polissa_ini, v_cnvpol.producte, 0,
                         v_cnvpol.ram, v_cnvpol.moda, v_cnvpol.npoliza,
                         aux_ssegpol, v_cnvpol.activitat, v_cnvpol.tipo,
                         v_cnvpol.cole, 0
                        );
         ELSE
            UPDATE cnvpolizas
               SET polissa_ini = v_cnvpol.polissa_ini
             WHERE sseguro = aux_ssegpol;
         END IF;
      END IF;

      paso := 84;

      /* BUG16410:JBN 17/11/2010: Insertem els paramatres de las clausulas*/
      BEGIN
         SELECT COUNT (*)
           INTO reg_clau2
           /* UTILITZEM AQUESTA VARIABLE PER NO DECLARAR-NE UNA ALTRA*/
         FROM   estclauparaseg
          WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi);

         IF reg_clau2 > 0
         THEN
            INSERT INTO clauparaseg
                        (sclagen, sseguro, nriesgo, nmovimi, nparame,
                         tparame, nordcla)
               (SELECT sclagen, aux_ssegpol, nriesgo, pnmovimi, nparame,
                       tparame, nordcla
                  FROM estclauparaseg
                 WHERE sseguro = psseguro
                   AND nmovimi = NVL (pnmovimi, nmovimi));
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'PAC_ALCTR126',
                         paso,
                         'traspaso_tablas_est.Error traspaso tablas EST.',
                         SQLERRM
                        );
      END;

      paso := 85;

      /* Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
      BEGIN
         SELECT DISTINCT nmovimi
                    INTO v_nmov_dummy
                    FROM docrequerida
                   WHERE sseguro = aux_ssegpol
                     AND nmovimi = NVL (pnmovimi, nmovimi);

         DELETE      docrequerida
               WHERE sseguro = aux_ssegpol
                 AND nmovimi = NVL (pnmovimi, nmovimi);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      /* Fin Bug 20672*/
      FOR regs IN (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                          cclase, tfilename, tdescrip, adjuntado, iddocgedox
                     FROM estdocrequerida
                    WHERE sseguro = psseguro
                      AND nmovimi = NVL (pnmovimi, nmovimi))
      LOOP
         BEGIN
            INSERT INTO docrequerida
                        (seqdocu, cdocume, sproduc,
                         cactivi, norden, ctipdoc,
                         cclase, sseguro, nmovimi, tfilename,
                         tdescrip, adjuntado, iddocgedox
                        )
                 VALUES (regs.seqdocu, regs.cdocume, regs.sproduc,
                         regs.cactivi, regs.norden, regs.ctipdoc,
                         regs.cclase, aux_ssegpol, pnmovimi, regs.tfilename,
                         regs.tdescrip, regs.adjuntado, regs.iddocgedox
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               UPDATE docrequerida
                  SET adjuntado = regs.adjuntado
                WHERE sseguro = aux_ssegpol
                  AND nmovimi = pnmovimi
                  AND seqdocu = regs.seqdocu;
         END;
      END LOOP;

      paso := 86;

      FOR regs IN (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                          cclase, nriesgo, tfilename, tdescrip, adjuntado,
                          iddocgedox
                     FROM estdocrequerida_riesgo
                    WHERE sseguro = psseguro
                      AND nmovimi = NVL (pnmovimi, nmovimi))
      LOOP
         /* Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
         BEGIN
            /* Bug 24657/130885.NMM.2012.11.27. Afegim seqdocu*/
            SELECT DISTINCT nmovimi, seqdocu
                       INTO v_nmov_dummy, v_seqdocu
                       FROM docrequerida_riesgo
                      WHERE sseguro = aux_ssegpol
                        AND nmovimi = NVL (pnmovimi, nmovimi)
                        AND nriesgo = regs.nriesgo
                        AND seqdocu = regs.seqdocu;

            /*BUG 027304 - 24/07/2013 - RCL - evitem que es borri la docu ja existent.*/
            DELETE      docrequerida_riesgo
                  WHERE sseguro = aux_ssegpol
                    AND nmovimi = NVL (pnmovimi, nmovimi)
                    AND nriesgo = regs.nriesgo
                    AND seqdocu = v_seqdocu;
         /* Bug 24657/130885.NMM.2012.11.27.Afegim seqdocu*/
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         /* Fin Bug 20672*/
         BEGIN
            INSERT INTO docrequerida_riesgo
                        (seqdocu, cdocume, sproduc,
                         cactivi, norden, ctipdoc,
                         cclase, sseguro, nmovimi, nriesgo,
                         tfilename, tdescrip, adjuntado,
                         iddocgedox
                        )
                 VALUES (regs.seqdocu, regs.cdocume, regs.sproduc,
                         regs.cactivi, regs.norden, regs.ctipdoc,
                         regs.cclase, aux_ssegpol, pnmovimi, regs.nriesgo,
                         regs.tfilename, regs.tdescrip, regs.adjuntado,
                         regs.iddocgedox
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               UPDATE docrequerida_riesgo
                  SET adjuntado = regs.adjuntado
                WHERE sseguro = aux_ssegpol
                  AND nmovimi = pnmovimi
                  AND seqdocu = regs.seqdocu
                  AND nriesgo = regs.nriesgo;
         END;
      END LOOP;

      paso := 87;

      FOR regs IN (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                          cclase, aux_ssegpol, pnmovimi, ninqaval, tfilename,
                          tdescrip, adjuntado, iddocgedox, sperson
                     FROM estdocrequerida_inqaval
                    WHERE sseguro = psseguro
                      AND nmovimi = NVL (pnmovimi, nmovimi))
      LOOP
         /* Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
         BEGIN
            SELECT DISTINCT nmovimi
                       INTO v_nmov_dummy
                       FROM docrequerida_inqaval
                      WHERE sseguro = aux_ssegpol
                        AND nmovimi = NVL (pnmovimi, nmovimi)
                        AND ninqaval = regs.ninqaval
                        AND sperson =
                                  pac_persona.f_sperson_spereal (regs.sperson)
                        AND seqdocu = regs.seqdocu;

            DELETE      docrequerida_inqaval
                  WHERE sseguro = aux_ssegpol
                    AND nmovimi = NVL (pnmovimi, nmovimi)
                    AND ninqaval = regs.ninqaval
                    AND sperson = pac_persona.f_sperson_spereal (regs.sperson)
                    AND seqdocu = regs.seqdocu;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         /* Fin Bug 20672*/
         BEGIN
            INSERT INTO docrequerida_inqaval
                        (seqdocu, cdocume, sproduc,
                         cactivi, norden, ctipdoc,
                         cclase, sseguro, nmovimi, ninqaval,
                         tfilename, tdescrip, adjuntado,
                         iddocgedox,
                         sperson
                        )
                 VALUES (regs.seqdocu, regs.cdocume, regs.sproduc,
                         regs.cactivi, regs.norden, regs.ctipdoc,
                         regs.cclase, aux_ssegpol, pnmovimi, regs.ninqaval,
                         regs.tfilename, regs.tdescrip, regs.adjuntado,
                         regs.iddocgedox,
                         pac_persona.f_sperson_spereal (regs.sperson)
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               UPDATE docrequerida_inqaval
                  SET adjuntado = regs.adjuntado
                WHERE sseguro = aux_ssegpol
                  AND nmovimi = pnmovimi
                  AND seqdocu = regs.seqdocu
                  AND ninqaval = regs.ninqaval
                  AND sperson = pac_persona.f_sperson_spereal (regs.sperson);
         END;
      END LOOP;

      paso := 871;

      FOR regs IN (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                          cclase, aux_ssegpol, pnmovimi, nriesgo, tfilename,
                          tdescrip, adjuntado, iddocgedox, sperson, ctipben
                     FROM estdocrequerida_benespseg
                    WHERE sseguro = psseguro
                      AND nmovimi = NVL (pnmovimi, nmovimi))
      LOOP
         /* Bug 20672 - RSC - 21/01/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos*/
         BEGIN
            SELECT DISTINCT nmovimi
                       INTO v_nmov_dummy
                       FROM docrequerida_benespseg
                      WHERE sseguro = aux_ssegpol
                        AND nmovimi = NVL (pnmovimi, nmovimi)
                        AND nriesgo = regs.nriesgo
                        AND sperson =
                                  pac_persona.f_sperson_spereal (regs.sperson)
                        AND seqdocu = regs.seqdocu
                        AND ctipben = regs.ctipben;

            DELETE      docrequerida_benespseg
                  WHERE sseguro = aux_ssegpol
                    AND nmovimi = NVL (pnmovimi, nmovimi)
                    AND nriesgo = regs.nriesgo
                    AND sperson = pac_persona.f_sperson_spereal (regs.sperson)
                    AND seqdocu = regs.seqdocu
                    AND ctipben = regs.ctipben;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         /* Fin Bug 20672*/
         BEGIN
            INSERT INTO docrequerida_benespseg
                        (seqdocu, cdocume, sproduc,
                         cactivi, norden, ctipdoc,
                         cclase, sseguro, nmovimi, nriesgo,
                         tfilename, tdescrip, adjuntado,
                         iddocgedox,
                         sperson,
                         ctipben
                        )
                 VALUES (regs.seqdocu, regs.cdocume, regs.sproduc,
                         regs.cactivi, regs.norden, regs.ctipdoc,
                         regs.cclase, aux_ssegpol, pnmovimi, regs.nriesgo,
                         regs.tfilename, regs.tdescrip, regs.adjuntado,
                         regs.iddocgedox,
                         pac_persona.f_sperson_spereal (regs.sperson),
                         regs.ctipben
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               UPDATE docrequerida_benespseg
                  SET adjuntado = regs.adjuntado
                WHERE sseguro = aux_ssegpol
                  AND nmovimi = pnmovimi
                  AND seqdocu = regs.seqdocu
                  AND nriesgo = regs.nriesgo
                  AND ctipben = regs.ctipben
                  AND sperson = pac_persona.f_sperson_spereal (regs.sperson);
         END;
      END LOOP;

      /* FIN BUG 18351 - 10/05/2011 - JMP*/
      paso := 88;

      INSERT INTO age_corretaje
                  (sseguro, cagente, nmovimi, nordage, pcomisi, ppartici,
                   islider)
         (SELECT aux_ssegpol, cagente, pnmovimi, nordage, pcomisi, ppartici,
                 islider
            FROM estage_corretaje
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      paso := 89;

      /* BUG 0021592 - 08/03/2012 - JMF*/
      INSERT INTO gescobros
                  (sseguro, sperson, cdomici, cusualt, falta, cusuari,
                   fmovimi)
         SELECT aux_ssegpol sseguro,
                pac_persona.f_sperson_spereal (sperson) sperson, cdomici,
                cusualt, falta, cusuari, fmovimi
           FROM estgescobros
          WHERE sseguro = psseguro;

      /* BUG 0022701 - 03/09/2012 - JMF*/
      /* BUG 0023965 - 15/10/2012 - JMF*/
      paso := 90;

      DECLARE
         CURSOR cur_rtn
         IS
            SELECT aux_ssegpol sseguro,
                   NVL (pac_persona.f_sperson_spereal (sperson),
                        sperson
                       ) sperson,
                   pnmovimi nmovimi, pretorno, idconvenio
              FROM estrtn_convenio
             WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi);

         v_conv   rtn_convenio.idconvenio%TYPE;
      BEGIN
         FOR for_rtn IN cur_rtn
         LOOP
            /* Validamos que el convenio sea el que corresponde a la persona/porcentaje*/
            SELECT MAX (idconvenio)
              INTO v_conv
              FROM rtn_mntbenefconvenio
             WHERE idconvenio = for_rtn.idconvenio
               AND sperson = for_rtn.sperson
               AND pretorno = for_rtn.pretorno;

            INSERT INTO rtn_convenio
                        (sseguro, sperson, nmovimi,
                         pretorno, idconvenio
                        )
                 VALUES (for_rtn.sseguro, for_rtn.sperson, for_rtn.nmovimi,
                         for_rtn.pretorno, v_conv
                        );
         END LOOP;
      END;

      paso := 91;

      INSERT INTO texmovseguro
                  (sseguro, nmovimi, tmovimi, finiefe, ffinefe)
         (SELECT aux_ssegpol, nmovimi, tmovimi, finiefe, ffinefe
            FROM est_texmovseguro
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      /*CONVENIOS*/
      INSERT INTO tramosregul
                  (sseguro, nriesgo, nmovimi, cgarant, nmovimiorg, fecini,
                   fecfin, ctipo, iprianuorg, iprianufin, icapitalorg,
                   icapitalfin, iimprecibo, finiorigar, ffinorigar)
         (SELECT aux_ssegpol, nriesgo, nmovimi, cgarant, nmovimiorg, fecini,
                 fecfin, ctipo, iprianuorg, iprianufin, icapitalorg,
                 icapitalfin, iimprecibo, finiorigar, ffinorigar
            FROM esttramosregul
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      INSERT INTO aseguradosmes
                  (sseguro, nriesgo, nmovimi, nmes, nanyo, fregul, naseg)
         (SELECT aux_ssegpol, nriesgo, nmovimi, nmes, nanyo, fregul, naseg
            FROM estaseguradosmes
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      /*CONVENIOS*/
      /* Bug INI: 35095/199894 - 06/03/2015 - PRB*/
      INSERT INTO asegurados_innom a
                  (a.sseguro, a.nmovimi, a.nriesgo, a.norden, a.nif, a.nombre,
                   a.apellidos, a.csexo, a.fnacim, a.falta, a.fbaja)
         (SELECT aux_ssegpol, e.nmovimi, e.nriesgo, e.norden, e.nif, e.nombre,
                 e.apellidos, e.csexo, e.fnacim, e.falta, e.fbaja
            FROM estasegurados_innom e
           WHERE e.sseguro = psseguro
                 AND e.nmovimi = NVL (pnmovimi, e.nmovimi));

      /* Bug FIN: 35095/199894 - 06/03/2015 - PRB*/
      /* Bug 28263/153355 - 01/10/2013 - AMC*/
      paso := 92;

      INSERT INTO casos_bpmseg
                  (sseguro, nmovimi, cempres, nnumcaso, cactivo)
         (SELECT aux_ssegpol, pnmovimi, cempres, nnumcaso, cactivo
            FROM estcasos_bpmseg
           WHERE sseguro = psseguro);

      /* Bug 34675/198727 - 24/02/2015 - AMC*/
      INSERT INTO validacargapregtab
                  (cpregun, sseguro, nmovimi, nriesgo, cgarant, norden,
                   sproces, cvalida, cusuari, fecha)
         (SELECT cpregun, aux_ssegpol, nmovimi, nriesgo, cgarant, norden,
                 sproces, cvalida, cusuari, fecha
            FROM estvalidacargapregtab
           WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));

      /* BUG 0022839 - FAL - 24/07/2012*/
      traspaso_seguroscol (psseguro, pnmovimi, aux_ssegpol, mens);
      /* FI BUG 0022839*/
      /* Bug 36596 IGIL INI*/
      traspaso_citas (psseguro, aux_ssegpol, pnmovimi, mens);
      /* Bug 36596 IGIL FIN*/
      -- INI BUG 40927/228750 - 07/03/2016 - JAEG
      traspaso_contgaran (psseguro      => psseguro,
                          pssegpol      => aux_ssegpol,
                          pnmovimi      => pnmovimi,
                          pmensaje      => mens
                         );

      IF mens IS NOT NULL
      THEN
         RAISE salir;
      END IF;
   -- FIN BUG 40927/228750 - 07/03/2016 - JAEG
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      paso,
                      'traspaso_tablas_est. Warning traspaso tablas EST.',
                         'mens= '
                      || mens
                      || ' psseguro =>,
                          '
                      || psseguro
                      || ' pssegpol => ,
                         '
                      || aux_ssegpol
                      || 'pnmovimi => '
                      || pnmovimi
                     );
         NULL;
      WHEN OTHERS
      THEN
         mens := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      paso,
                      'traspaso_tablas_est.Error traspaso tablas EST.',
                      SQLERRM
                     );
   END traspaso_tablas_est;

   /* BUG 0022839 - FAL - 24/07/2012*/
   PROCEDURE traspaso_seguroscol (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pssegpol   IN       NUMBER,
      mens       OUT      VARCHAR2
   )
   IS
      vcrespue4084   pregunpolseg.crespue%TYPE;
      vcrespue4790   pregunpolseg.crespue%TYPE;
      vcrespue4794   pregunpolseg.crespue%TYPE;
      vcrespue4078   pregunpolseg.crespue%TYPE;
      vcrespue4792   pregunpolseg.trespue%TYPE;
      /* BUG 0023640/0124171 - FAL - 21/09/2012*/
      vcrespue4793   pregunpolseg.trespue%TYPE;
      /* BUG 0023640/0124171 - FAL - 21/09/2012*/
      vcrespue4092   pregunpolseg.crespue%TYPE;
      vcrespue4791   pregunpolseg.crespue%TYPE;
      vcrespue535    pregunpolseg.crespue%TYPE;
      /* 23074 - I - JLB - 30/07/2012*/
      vcrespue4093   pregunpolseg.crespue%TYPE;
      vcrespue4094   pregunpolseg.crespue%TYPE;
      vcrespue4095   pregunpolseg.crespue%TYPE;
      /* 23074 - F - JLB - 30/07/2012*/
      num_err        NUMBER;
   BEGIN
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro,
                                           4084,
                                           'EST',
                                           vcrespue4084
                                          );                     -- tipo cobro
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4790, 'EST',
                                           vcrespue4790);     -- tipo vigencia
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4794, 'EST',
                                           vcrespue4794);   -- Agrupa recibos?
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4078, 'EST',
                                           vcrespue4078);
      /* modalidad (contributiva/no)*/
      num_err :=
         pac_preguntas.f_get_pregunpolseg_t (psseguro,
                                             4792,
                                             'EST',
                                             vcrespue4792
                                            );
      /* fecha corte        -- BUG 0023640/0124171 - FAL - 21/09/2012*/
      num_err :=
         pac_preguntas.f_get_pregunpolseg_t (psseguro,
                                             4793,
                                             'EST',
                                             vcrespue4793
                                            );
      /* fecha facturación  -- BUG 0023640/0124171 - FAL - 21/09/2012*/
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4092, 'EST',
                                           vcrespue4092);    -- tipo colectivo
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4791, 'EST',
                                           vcrespue4791);
      /* Cobro a Prorrata o periodos exactos*/
      num_err :=
          pac_preguntas.f_get_pregunpolseg (psseguro, 535, 'EST', vcrespue535);
      /* Recibos por Tomador, Asegurado*/
      /* 23074 - I - JLB - 30/07/2012*/
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4093, 'EST',
                                           vcrespue4093);
      /* Aplica gastos de expedición*/
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4094, 'EST',
                                           vcrespue4094);
      /* Periodicidad de los gastos*/
      num_err :=
         pac_preguntas.f_get_pregunpolseg (psseguro, 4095, 'EST',
                                           vcrespue4095);

      /* Importe de los gastos*/
      /* 23074 - F*/
      BEGIN
         INSERT INTO seguroscol
                     (sseguro, ctipcol, ctipcob, ctipvig,
                      recpor, cagrupa, prorrexa, cmodalid,
                      fcorte,
                      ffactura, /* 23074 - I - JLB*/ cagastexp,
                      cperiogast, iimporgast
                     )                                    /* 23074 - F - JLB*/
              VALUES (pssegpol, vcrespue4092, vcrespue4084, vcrespue4790,
                      vcrespue535, vcrespue4794, vcrespue4791, vcrespue4078,
                      TO_DATE (vcrespue4792, 'dd/mm/yyyy'),
                      /* BUG 0023640/0124171 - FAL - 21/09/2012*/
                      TO_DATE (vcrespue4793, 'dd/mm/yyyy')
                                                          /* 23074 - I - JLB -- BUG 0023640/0124171 - FAL - 21/09/2012*/
         ,            vcrespue4093,
                      vcrespue4094, vcrespue4095
                     );                                         /* 23074 - F*/
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE seguroscol
               SET ctipcol = vcrespue4092,
                   ctipcob = vcrespue4084,
                   ctipvig = vcrespue4790,
                   recpor = vcrespue535,
                   cagrupa = vcrespue4794,
                   prorrexa = vcrespue4791,
                   cmodalid = vcrespue4078,
                   fcorte = TO_DATE (vcrespue4792, 'dd/mm/yyyy'),
                   /* BUG 0023640/0124171 - FAL - 21/09/2012*/
                   ffactura = TO_DATE (vcrespue4793, 'dd/mm/yyyy')
                                                                  /* 23074 - I - JLB          -- BUG 0023640/0124171 - FAL - 21/09/2012*/
            ,
                   cagastexp = vcrespue4093,
                   cperiogast = vcrespue4094,
                   iimporgast = vcrespue4095
             /* 23074 - F*/
            WHERE  sseguro = pssegpol;
         WHEN OTHERS
         THEN
            mens := SQLERRM;
            p_tab_error
                   (f_sysdate,
                    f_user,
                    'PAC_ALCTR126',
                    1,
                    'traspaso_seguroscol. Error traspaso tablas SEGUROSCOL.',
                    mens
                   );
      END;
   END traspaso_seguroscol;

/* FI BUG 0022839*/
/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
   PROCEDURE traspaso_riesgos (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      programa   IN       VARCHAR2 DEFAULT 'ALCTR126',
      mens       OUT      VARCHAR2,
      pnmovimi   IN       NUMBER DEFAULT NULL
   )
   IS
      /* Procediment per traspassar les taules de riscos d'estudis a real*/
      /********************************************************************************************
                                                Sólo insertamos los riesgos nuevos, y modificamos todos los campos del resto
      *******************************************************************************************/
      v_moviant       NUMBER;

      /* Se modifican los riesgos que están en las dos tablas*/
      CURSOR riesgos_a_modificar
      IS
         SELECT e.nriesgo nriesgo_new, e.sseguro sseguro_new,
                e.nmovima nmovima_new, e.fefecto fefecto_new,
                pac_persona.f_sperson_spereal (e.sperson) sperson_new,
                e.cclarie cclarie_new, e.nmovimb nmovimb_new,
                e.fanulac fanulac_new, e.tnatrie tnatrie_new,
                e.cdomici cdomici_new, e.nasegur nasegur_new,
                e.nedacol nedacol_new, e.csexcol csexcol_new,
                e.sbonush sbonush_new, e.czbonus czbonus_new,
                e.ctipdiraut ctipdiraut_new, e.cactivi cactivi_new,
                
                /*MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo*/
                /* Ini Bug 21907 -- MDS -- 23/04/2012*/
                e.pdtocom pdtocom_new, e.precarg precarg_new,
                e.pdtotec pdtotec_new, e.preccom preccom_new,
                e.cmodalidad cmodalidad_new, e.tdescrie tdescrie_new,
                
                /* Fin Bug 21907 -- MDS -- 23/04/2012*/
                r.nriesgo nriesgo_old, r.sseguro sseguro_old,
                r.nmovima nmovima_old, r.fefecto fefecto_old,
                r.sperson sperson_old,
                                      /*pac_persona.f_sperson_spereal (r.sperson) sperson_old,*/
                                      r.cclarie cclarie_old,
                r.nmovimb nmovimb_old, r.fanulac fanulac_old,
                r.tnatrie tnatrie_old, r.cdomici cdomici_old,
                r.nasegur nasegur_old, r.nedacol nedacol_old,
                r.csexcol csexcol_old, r.sbonush sbonush_old,
                r.czbonus czbonus_old, r.ctipdiraut ctipdiraut_old,
                r.cactivi cactivi_old,
                                      /*MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo*/
                                      /* Ini Bug 21907 -- MDS -- 23/04/2012*/
                                      r.pdtocom pdtocom_old,
                r.precarg precarg_old, r.pdtotec pdtotec_old,
                r.preccom preccom_old, r.cmodalidad cmodalidad_old,
                r.tdescrie tdescrie_old   -- BUG CONF-114 - 21/09/2016 - JAEG
           /* Fin Bug 21907 -- MDS -- 23/04/2012*/
         FROM   estriesgos e, riesgos r
          WHERE r.sseguro = pssegpol
            AND e.nriesgo = r.nriesgo
            AND e.sseguro = psseguro
            /* INI --IAXIS-5420 -- 28/11/2019*/
            AND (   (SELECT cobjase
                       FROM seguros
                      WHERE sseguro = pssegpol) != 1
                 OR EXISTS (
                       SELECT 1
--MODIFICACION PARA QUE EL ENDOSO DE CAMBIO DE NATURALEZA DEL RIESGO FUNCIONE BJHB 09/01/2020
                         FROM estassegurats et
                        WHERE et.sseguro = e.sseguro
                          AND et.sperson = e.sperson
                          AND et.norden = 1)
                );

      /* FIN --IAXIS-5420 -- 28/11/2019 */

      /* Se insertan los riesgos que están en ESTIRESGOS y no están en RIESGOS*/
      CURSOR riesgos_a_insertar
      IS
         SELECT nriesgo, sseguro, nmovima, fefecto,
                pac_persona.f_sperson_spereal (e.sperson) sperson, cclarie,
                nmovimb, fanulac, tnatrie, cdomici, nasegur, nedacol, csexcol,
                sbonush, czbonus, ctipdiraut, spermin, cactivi,
                                                               /*MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo*/
                                                               /* Ini Bug 21907 -- MDS -- 23/04/2012*/
                                                               pdtocom,
                precarg, pdtotec, preccom, cmodalidad,
                tdescrie                   -- BUG CONF-114 - 21/09/2016 - JAEG
           /* Fin Bug 21907 -- MDS -- 23/04/2012*/
         FROM   estriesgos e
          WHERE sseguro = psseguro
            AND nriesgo NOT IN (SELECT nriesgo
                                  FROM riesgos
                                 WHERE sseguro = pssegpol);

      /* Se borran los riesgos que están en RIESGOS y no están en ESTRIESGOS*/
      CURSOR riesgos_a_borrar
      IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = pssegpol
            AND nriesgo NOT IN (SELECT nriesgo
                                  FROM estriesgos
                                 WHERE sseguro = psseguro);

      v_tdomici       sitriesgo.tdomici%TYPE;
      v_cprovin       NUMBER;
      v_cpostal       codpostal.cpostal%TYPE;
      v_cpoblac       NUMBER;
      v_csiglas       NUMBER;
      v_tnomvia       sitriesgo.tnomvia%TYPE;
      v_nnumvia       NUMBER;
      v_tcomple       sitriesgo.tcomple%TYPE;
      v_cciudad       NUMBER;
      v_fgisx         FLOAT;
      v_fgisy         FLOAT;
      v_fgisz         FLOAT;
      v_cvalida       NUMBER;
      v_cviavp        NUMBER;
      v_clitvp        NUMBER;
      v_cbisvp        NUMBER;
      v_corvp         NUMBER;
      v_nviaadco      NUMBER;
      v_clitco        NUMBER;
      v_corco         NUMBER;
      v_nplacaco      NUMBER;
      v_cor2co        NUMBER;
      v_cdet1ia       NUMBER;
      v_tnum1ia       VARCHAR2 (100);
      v_cdet2ia       NUMBER;
      v_tnum2ia       VARCHAR2 (100);
      v_cdet3ia       NUMBER;
      v_tnum3ia       VARCHAR2 (100);
      v_iddomici      NUMBER;
      v_localidad     VARCHAR2 (3000);
      v_fdefecto      NUMBER;
      v_descripcion   VARCHAR2 (1000);
      v_cversion      autriesgos.cversion%TYPE;              /* VARCHAR2(11)*/
      v_ctipmat       autriesgos.ctipmat%TYPE;                  /* NUMBER(6)*/
      v_cmatric       autriesgos.cmatric%TYPE;               /* VARCHAR2(12)*/
      v_cuso          autriesgos.cuso%TYPE;                   /* VARCHAR2(3)*/
      v_csubuso       autriesgos.csubuso%TYPE;                /* VARCHAR2(2)*/
      v_fmatric       autriesgos.fmatric%TYPE;                       /* DATE*/
      v_nkilometros   autriesgos.nkilometros%TYPE;              /* NUMBER(3)*/
      v_cvehnue       autriesgos.cvehnue%TYPE;                  /* NUMBER(3)*/
      v_ivehicu       autriesgos.ivehicu%TYPE;               /* NUMBER(15,4)*/
      v_npma          autriesgos.npma%TYPE;                  /* NUMBER(10,3)*/
      v_ntara         autriesgos.ntara%TYPE;                 /* NUMBER(10,3)*/
      v_ccolor        autriesgos.ccolor%TYPE;                   /* NUMBER(3)*/
      v_nbastid       autriesgos.nbastid%TYPE;               /* VARCHAR2(20)*/
      v_nplazas       autriesgos.nplazas%TYPE;                  /* NUMBER(3)*/
      v_cgaraje       autriesgos.cgaraje%TYPE;                  /* NUMBER(3)*/
      v_cusorem       autriesgos.cusorem%TYPE;                  /* NUMBER(3)*/
      v_cremolque     autriesgos.cremolque%TYPE;                /* NUMBER(3)*/
      v_triesgo       autriesgos.triesgo%TYPE;
      v_ffinciant     autriesgos.ffinciant%TYPE;
      v_ciaant        autriesgos.ciaant%TYPE;
      v_cobjase       NUMBER (2);
      num_err         NUMBER                        := 0;
      v_tab           NUMBER;
      salida          EXCEPTION;
   BEGIN
      SELECT cobjase
        INTO v_cobjase
        FROM estseguros
       WHERE sseguro = psseguro;

      /* ******************** Modificación de riesgos ya existentes *************************/
      FOR reg IN riesgos_a_modificar
      LOOP
         /*mirem si hi han canvis*/
         IF    reg.nmovima_new != reg.nmovima_old
            OR reg.fefecto_new != reg.fefecto_old
            OR reg.sperson_new != reg.sperson_old
            OR reg.cclarie_new != reg.cclarie_new
            OR reg.nmovimb_new != reg.nmovimb_old
            OR reg.fanulac_new != NVL (reg.fanulac_old, f_sysdate)
            OR NVL (reg.tnatrie_new, '-1##') != NVL (reg.tnatrie_old, '-1##')
            OR reg.cdomici_new != reg.cdomici_old
            OR reg.nasegur_new != reg.nasegur_old
            OR reg.nedacol_new != reg.nedacol_old
            OR reg.csexcol_new != reg.csexcol_old
            OR reg.sbonush_new != reg.sbonush_old
            OR reg.czbonus_new != reg.czbonus_old
            OR reg.ctipdiraut_new != reg.ctipdiraut_old
            OR reg.cactivi_new != reg.cactivi_old
            /* Ini Bug 21907 -- MDS -- 23/04/2012*/
            OR reg.pdtocom_new != reg.pdtocom_old
            OR reg.precarg_new != reg.precarg_old
            OR reg.pdtotec_new != reg.pdtotec_old
            OR reg.preccom_new != reg.preccom_old
            /* Fin Bug 21907 -- MDS -- 23/04/2012*/
            OR reg.cmodalidad_new != reg.cmodalidad_old
            OR reg.tdescrie_new != reg.tdescrie_old
         THEN
            /*MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo*/
            /*xvila: Bug 6008 fem el traspas al historic.*/
            num_err :=
               f_act_hisriesgo (pssegpol, reg.nriesgo_old, NVL (pnmovimi, 1));

            IF num_err <> 0
            THEN
               v_tab := 1;
               RAISE salida;
            END IF;

            -- Bug 42295/0236162 - El campo nmovima no se debe modificar nunca ya que indica el movimiento en el que el riesgo fue dado de alta
            UPDATE riesgos
               SET /*nmovima=reg.nmovima_new,*/ sperson = reg.sperson_new,
                                                fefecto = reg.fefecto_new,
                                                cclarie = reg.cclarie_new,
                                                nmovimb = reg.nmovimb_new,
                                                fanulac = reg.fanulac_new,
                                                tnatrie = reg.tnatrie_new,
                                                cdomici = reg.cdomici_new,
                                                nasegur = reg.nasegur_new,
                                                nedacol = reg.nedacol_new,
                                                csexcol = reg.csexcol_new,
                                                sbonush = reg.sbonush_new,
                                                czbonus = reg.czbonus_new,
                                                ctipdiraut =
                                                            reg.ctipdiraut_new,
                                                cactivi = reg.cactivi_new,
                                                /*MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo*/
                                                /* Ini Bug 21907 -- MDS -- 23/04/2012*/
                                                pdtocom = reg.pdtocom_new,
                                                precarg = reg.precarg_new,
                                                pdtotec = reg.pdtotec_new,
                                                preccom = reg.preccom_new,
                                                cmodalidad =
                                                            reg.cmodalidad_new,
                                                tdescrie =
                                                   reg.tdescrie_new
                                           -- BUG CONF-114 - 21/09/2016 - JAEG
             /* Fin Bug 21907 -- MDS -- 23/04/2012*/
            WHERE  sseguro = pssegpol AND nriesgo = reg.nriesgo_new;

            /* Si el riesgo es 'direcciones' modificamos también SITRIESGO*/
            /* Bug 12668 - 17/02/2010 - AMC*/
            BEGIN
               BEGIN
                  SELECT tdomici, cprovin, cpostal, cpoblac,
                         csiglas, tnomvia, nnumvia, tcomple,
                         cciudad, fgisx, fgisy, fgisz, cvalida,
                         cviavp, clitvp, cbisvp, corvp, nviaadco,
                         clitco, corco, nplacaco, cor2co, cdet1ia,
                         tnum1ia, cdet2ia, tnum2ia, cdet3ia,
                         tnum3ia, iddomici, localidad, fdefecto,
                         descripcion
                    INTO v_tdomici, v_cprovin, v_cpostal, v_cpoblac,
                         v_csiglas, v_tnomvia, v_nnumvia, v_tcomple,
                         v_cciudad, v_fgisx, v_fgisy, v_fgisz, v_cvalida,
                         v_cviavp, v_clitvp, v_cbisvp, v_corvp, v_nviaadco,
                         v_clitco, v_corco, v_nplacaco, v_cor2co, v_cdet1ia,
                         v_tnum1ia, v_cdet2ia, v_tnum2ia, v_cdet3ia,
                         v_tnum3ia, v_iddomici, v_localidad, v_fdefecto,
                         v_descripcion
                    FROM estsitriesgo
                   WHERE sseguro = psseguro AND nriesgo = reg.nriesgo_new;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;

               UPDATE sitriesgo
                  SET tdomici = v_tdomici,
                      cprovin = v_cprovin,
                      cpostal = v_cpostal,
                      cpoblac = v_cpoblac,
                      csiglas = v_csiglas,
                      tnomvia = v_tnomvia,
                      nnumvia = v_nnumvia,
                      tcomple = v_tcomple,
                      cciudad = v_cciudad,
                      fgisx = v_fgisx,
                      fgisy = v_fgisy,
                      fgisz = v_fgisz,
                      cvalida = v_cvalida,
                      cviavp = v_cviavp,
                      clitvp = v_clitvp,
                      cbisvp = v_cbisvp,
                      corvp = v_corvp,
                      nviaadco = v_nviaadco,
                      clitco = v_clitco,
                      corco = v_corco,
                      nplacaco = v_nplacaco,
                      cor2co = v_cor2co,
                      cdet1ia = v_cdet1ia,
                      tnum1ia = v_tnum1ia,
                      cdet2ia = v_cdet2ia,
                      tnum2ia = v_tnum2ia,
                      cdet3ia = v_cdet3ia,
                      tnum3ia = v_tnum3ia,
                      iddomici = v_iddomici,
                      localidad = v_localidad,
                      fdefecto = v_fdefecto,
                      descripcion = v_descripcion
                WHERE sseguro = pssegpol AND nriesgo = reg.nriesgo_new;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         /* Fi Bug 12668 - 17/02/2010 - AMC*/
         END IF;

         /* BUG17255:DRA:25/07/2011:Inici*/
         /* Si el riesgo es 'autos' modificamos también AUTRIESGO*/
         IF v_cobjase = 5
         THEN
            BEGIN
               /****************************************
                                                                              v_moviant := NULL;
               IF programa = 'ALSUP003' THEN
                  SELECT MAX(nmovimi)
                    INTO v_moviant
                    FROM autriesgos
                   WHERE sseguro = pssegpol
                     AND nriesgo = reg.nriesgo_new;
               END IF;
               SELECT cversion, ctipmat, cmatric, cuso, csubuso, fmatric,
                      nkilometros, cvehnue, ivehicu, npma, ntara, ccolor,
                      nbastid, nplazas, cgaraje, cusorem, cremolque, triesgo
                 INTO v_cversion, v_ctipmat, v_cmatric, v_cuso, v_csubuso, v_fmatric,
                      v_nkilometros, v_cvehnue, v_ivehicu, v_npma, v_ntara, v_ccolor,
                      v_nbastid, v_nplazas, v_cgaraje, v_cusorem, v_cremolque, v_triesgo
                 FROM estautriesgos
                WHERE sseguro = psseguro
                  AND nriesgo = reg.nriesgo_new;
               ****************************************/
               /* INSERT INTO autriesgos
                                                                                                                                 (sseguro, nriesgo, nmovimi, cversion, ctipmat, cmatric, cuso,
                         csubuso, fmatric, nkilometros, cvehnue, ivehicu, npma, ntara,
                         ccolor, nbastid, nplazas, cgaraje, cusorem, cremolque, triesgo)
               SELECT pssegpol, nriesgo, NVL(pnmovimi, 1), cversion, ctipmat, cmatric,
                      cuso, csubuso, fmatric, nkilometros, cvehnue, ivehicu, npma, ntara,
                      ccolor, nbastid, nplazas, cgaraje, cusorem, cremolque, triesgo
                 FROM estautriesgos
                WHERE sseguro = psseguro
                  AND nriesgo = reg.nriesgo_new;*/
               FOR reg2 IN
                  (SELECT nriesgo, cversion, ctipmat, cmatric, cuso, csubuso,
                          fmatric, nkilometros, cvehnue, ivehicu, npma,
                          ntara, ccolor, nbastid, nplazas, cgaraje, cusorem,
                          cremolque, triesgo, cpaisorigen, cchasis, ivehinue,
                          nkilometraje, ccilindraje, codmotor, cpintura,
                          ccaja, ccampero, ctipcarroceria, cservicio,
                          corigen, ctransporte, anyo, cmotor, ffinciant,
                          ciaant,
                                 /* BUG: 0027953/0151258 - JSV 21/08/2013*/
                                 cmodalidad, cpeso, ctransmision,
                          npuertas    /*BUG 30256/166723 - 21/02/2014 - RCL*/
                     FROM estautriesgos
                    WHERE sseguro = psseguro AND nriesgo = reg.nriesgo_new)
               LOOP
                  BEGIN
                     INSERT INTO autriesgos
                                 (sseguro, nriesgo, nmovimi,
                                  cversion, ctipmat, cmatric,
                                  cuso, csubuso, fmatric,
                                  nkilometros, cvehnue,
                                  ivehicu, npma, ntara,
                                  ccolor, nbastid, nplazas,
                                  cgaraje, cusorem,
                                  cremolque, triesgo,
                                  cpaisorigen, cchasis,
                                  ivehinue, nkilometraje,
                                  ccilindraje, codmotor,
                                  cpintura, ccaja, ccampero,
                                  ctipcarroceria, cservicio,
                                  corigen, ctransporte, anyo,
                                  cmotor, ffinciant, ciaant,
                                  /* BUG: 0027953/0151258 - JSV 21/08/2013*/
                                  cmodalidad, cpeso,
                                  ctransmision, npuertas
                                 )     /*BUG 30256/166723 - 21/02/2014 - RCL*/
                          VALUES (pssegpol, reg2.nriesgo, NVL (pnmovimi, 1),
                                  reg2.cversion, reg2.ctipmat, reg2.cmatric,
                                  reg2.cuso, reg2.csubuso, reg2.fmatric,
                                  reg2.nkilometros, reg2.cvehnue,
                                  reg2.ivehicu, reg2.npma, reg2.ntara,
                                  reg2.ccolor, reg2.nbastid, reg2.nplazas,
                                  reg2.cgaraje, reg2.cusorem,
                                  reg2.cremolque, reg2.triesgo,
                                  reg2.cpaisorigen, reg2.cchasis,
                                  reg2.ivehinue, reg2.nkilometraje,
                                  reg2.ccilindraje, reg2.codmotor,
                                  reg2.cpintura, reg2.ccaja, reg2.ccampero,
                                  reg2.ctipcarroceria, reg2.cservicio,
                                  reg2.corigen, reg2.ctransporte, reg2.anyo,
                                  reg2.cmotor, reg2.ffinciant, reg2.ciaant,
                                  /* BUG: 0027953/0151258 - JSV 21/08/2013*/
                                  reg2.cmodalidad, reg2.cpeso,
                                  reg2.ctransmision, reg2.npuertas
                                 );    /*BUG 30256/166723 - 21/02/2014 - RCL*/
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE autriesgos
                           SET cversion = reg2.cversion,
                               ctipmat = reg2.ctipmat,
                               cmatric = reg2.cmatric,
                               cuso = reg2.cuso,
                               csubuso = reg2.csubuso,
                               fmatric = reg2.fmatric,
                               nkilometros = reg2.nkilometros,
                               cvehnue = reg2.cvehnue,
                               ivehicu = reg2.ivehicu,
                               npma = reg2.npma,
                               ntara = reg2.ntara,
                               ccolor = reg2.ccolor,
                               nbastid = reg2.nbastid,
                               nplazas = reg2.nplazas,
                               cgaraje = reg2.cgaraje,
                               cusorem = reg2.cusorem,
                               cremolque = reg2.cremolque,
                               triesgo = reg2.triesgo,
                               cpaisorigen = reg2.cpaisorigen,
                               cmotor = reg2.cmotor,
                               cchasis = reg2.cchasis,
                               ivehinue = reg2.ivehinue,
                               nkilometraje = reg2.nkilometraje,
                               ccilindraje = reg2.ccilindraje,
                               codmotor = reg2.codmotor,
                               cpintura = reg2.cpintura,
                               ccaja = reg2.ccaja,
                               ccampero = reg2.ccampero,
                               ctipcarroceria = reg2.ctipcarroceria,
                               cservicio = reg2.cservicio,
                               corigen = reg2.corigen,
                               ctransporte = reg2.ctransporte,
                               anyo = reg2.anyo,
                               ffinciant = reg2.ffinciant,
                               ciaant = reg2.ciaant,
                               /* BUG: 0027953/0151258 - JSV 21/08/2013*/
                               cmodalidad = reg2.cmodalidad,
                               cpeso = reg2.cpeso,
                               /*BUG 30256/166723 - 21/02/2014 - RCL*/
                               ctransmision = reg2.ctransmision,
                               /*BUG 30256/166723 - 21/02/2014 - RCL*/
                               npuertas = reg2.npuertas
                         /*BUG 30256/166723 - 21/02/2014 - RCL*/
                        WHERE  sseguro = pssegpol
                           AND nriesgo = reg2.nriesgo
                           AND nmovimi = NVL (pnmovimi, 1);
                  END;
               END LOOP;

               /* Si el riesgo es 'autos' modificamos también AUTCONDUCTORES*/
               /* borramos los que hay y añadimos los nuevos*/
               /* BUG17255:DRA:25/07/2011:Inici*/
               /****************************************
                                                                                                                        DELETE FROM autconductores
                     WHERE sseguro = pssegpol
                       AND nriesgo = reg.nriesgo_new
                       AND nmovimi = NVL(pnmovimi, nmovimi);
               **********************************************/
               /* Bug 25368/133447 - 08/01/2013 - AMC*/
               /* Bug 25368/135191 - 15/01/2013 - AMC*/
               FOR reg3 IN
                  (SELECT nriesgo, norden,
                          pac_persona.f_sperson_spereal (e.sperson) sperson,
                          fnacimi, fcarnet, csexo, npuntos, cdomici,
                          cprincipal, exper_manual, exper_cexper, exper_sinie,
                          exper_sinie_manual
                     FROM estautconductores e
                    WHERE sseguro = psseguro AND nriesgo = reg.nriesgo_new)
               LOOP
                  BEGIN
                     INSERT INTO autconductores
                                 (sseguro, nriesgo, nmovimi,
                                  norden, sperson, fnacimi,
                                  fcarnet, csexo, npuntos,
                                  cdomici, cprincipal,
                                  exper_manual, exper_cexper,
                                  exper_sinie, exper_sinie_manual
                                 )
                          VALUES (pssegpol, reg3.nriesgo, NVL (pnmovimi, 1),
                                  reg3.norden, reg3.sperson, reg3.fnacimi,
                                  reg3.fcarnet, reg3.csexo, reg3.npuntos,
                                  reg3.cdomici, reg3.cprincipal,
                                  reg3.exper_manual, reg3.exper_cexper,
                                  reg3.exper_sinie, reg3.exper_sinie_manual
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE autconductores
                           SET sperson = reg3.sperson,
                               fnacimi = reg3.fnacimi,
                               fcarnet = reg3.fcarnet,
                               csexo = reg3.csexo,
                               npuntos = reg3.npuntos,
                               cdomici = reg3.cdomici,
                               cprincipal = reg3.cprincipal,
                               exper_manual = reg3.exper_manual,
                               exper_cexper = reg3.exper_cexper
                         WHERE sseguro = pssegpol
                           AND nriesgo = reg3.nriesgo
                           AND nmovimi = NVL (pnmovimi, 1)
                           AND norden = reg3.norden;
                  END;
               END LOOP;
            /* Fi Bug 25368/133447 - 08/01/2013 - AMC*/
            /* Fi Bug 25368/135191 - 15/01/2013 - AMC*/
            /*    INSERT INTO autconductores
                                                                                                                              (sseguro, nriesgo, nmovimi, norden, sperson, fnacimi, fcarnet,
                      csexo, npuntos)
            (SELECT pssegpol, nriesgo, NVL(pnmovimi, 1), norden,
                    pac_persona.f_sperson_spereal(e.sperson) sperson, fnacimi, fcarnet,
                    csexo, npuntos
               FROM estautconductores e
              WHERE sseguro = psseguro
                AND nriesgo = reg.nriesgo_new);*/
            EXCEPTION
               WHEN OTHERS
               THEN
                  mens := SQLERRM;
                  p_tab_error
                           (f_sysdate,
                            f_user,
                            'PAC_ALCTR126',
                            1,
                            'traspaso_riesgos. Error traspaso tablas AUTOS.',
                            mens
                           );
                  EXIT;
            END;

            BEGIN
               /*************************************
                                                                                                   DELETE FROM autdetriesgos
                     WHERE sseguro = pssegpol
                       AND nriesgo = reg.nriesgo_new;
               *************************************/
               /*  SELECT
               E.SSEGURO, E.NRIESGO, E.NMOVIMI,
               E.CVERSION, E.CDISPOSITIVO, E.CPROPDISP,
               E.IVALDISP, E.FINICONTRATO, E.FFINCONTRATO,
               E.NCONTRATO, E.TDESCDISP
               FROM ESTAUTDISRIESGOS E;*/
               /* Bug 0028547/0155965 - JSV - 15/10/2013*/
               DELETE FROM autdisriesgos
                     WHERE sseguro = pssegpol
                       AND nriesgo = reg.nriesgo_new
                       AND nmovimi = NVL (pnmovimi, nmovimi);

               FOR reg4 IN (SELECT e.sseguro, e.nriesgo, e.nmovimi,
                                   e.cversion, e.cdispositivo, e.cpropdisp,
                                   e.ivaldisp, e.finicontrato, e.ffincontrato,
                                   e.ncontrato, e.tdescdisp
                              FROM estautdisriesgos e
                             WHERE sseguro = psseguro
                               AND nriesgo = reg.nriesgo_new)
               LOOP
                  BEGIN
                     INSERT INTO autdisriesgos
                                 (sseguro, nriesgo, nmovimi,
                                  cversion, cdispositivo,
                                  cpropdisp, ivaldisp,
                                  finicontrato, ffincontrato,
                                  ncontrato, tdescdisp
                                 )
                          VALUES (pssegpol, reg4.nriesgo, NVL (pnmovimi, 1),
                                  reg4.cversion, reg4.cdispositivo,
                                  reg4.cpropdisp, reg4.ivaldisp,
                                  reg4.finicontrato, reg4.ffincontrato,
                                  reg4.ncontrato, reg4.tdescdisp
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE autdisriesgos
                           SET cpropdisp = reg4.cpropdisp,
                               finicontrato = reg4.finicontrato,
                               ffincontrato = reg4.ffincontrato,
                               ivaldisp = reg4.ivaldisp,
                               ncontrato = reg4.ncontrato,
                               tdescdisp = reg4.tdescdisp
                         WHERE sseguro = pssegpol
                           AND nriesgo = reg4.nriesgo
                           AND nmovimi = NVL (pnmovimi, 1)
                           AND cversion = reg4.cversion
                           AND cdispositivo = reg4.cdispositivo;
                  END;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  mens := SQLERRM;
                  p_tab_error
                     (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'traspaso_riesgos. Error traspaso tablas estautdisriesgos.',
                      mens
                     );
                  EXIT;
            END;

            /* Si el riesgo es 'autos' modificamos también AUTDETRIESGOS*/
            /* borramos los que hay y añadimos los nuevos*/
            BEGIN
               /*************************************
                                                                                                   DELETE FROM autdetriesgos
                     WHERE sseguro = pssegpol
                       AND nriesgo = reg.nriesgo_new;
               *************************************/
               /* Bug 0028547/0155965 - JSV - 15/10/2013*/
               DELETE FROM autdetriesgos
                     WHERE sseguro = pssegpol
                       AND nriesgo = reg.nriesgo_new
                       AND nmovimi = NVL (pnmovimi, nmovimi);

               FOR reg4 IN (SELECT nriesgo, cversion, caccesorio, ctipacc,
                                   fini, ivalacc, tdesacc, casegurable
                              FROM estautdetriesgos
                             WHERE sseguro = psseguro
                               AND nriesgo = reg.nriesgo_new)
               LOOP
                  BEGIN
                     INSERT INTO autdetriesgos
                                 (sseguro, nriesgo, nmovimi,
                                  cversion, caccesorio,
                                  ctipacc, fini, ivalacc,
                                  tdesacc, casegurable
                                 )
                          VALUES (pssegpol, reg4.nriesgo, NVL (pnmovimi, 1),
                                  reg4.cversion, reg4.caccesorio,
                                  reg4.ctipacc, reg4.fini, reg4.ivalacc,
                                  reg4.tdesacc, reg4.casegurable
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE autdetriesgos
                           SET ctipacc = reg4.ctipacc,
                               fini = reg4.fini,
                               ivalacc = reg4.ivalacc,
                               tdesacc = reg4.tdesacc,
                               casegurable = reg4.casegurable
                         WHERE sseguro = pssegpol
                           AND nriesgo = reg4.nriesgo
                           AND nmovimi = NVL (pnmovimi, 1)
                           AND cversion = reg4.cversion
                           AND caccesorio = reg4.caccesorio;
                  END;
               END LOOP;
            /*INSERT INTO autdetriesgos
                                                                                                                              (sseguro, nriesgo, nmovimi, cversion, caccesorio, ctipacc, fini,
                      ivalacc, tdesacc)
            (SELECT pssegpol, nriesgo, NVL(pnmovimi, 1), cversion, caccesorio, ctipacc,
                    fini, ivalacc, tdesacc
               FROM estautdetriesgos
              WHERE sseguro = psseguro
                AND nriesgo = reg.nriesgo_new);*/
            EXCEPTION
               WHEN OTHERS
               THEN
                  mens := SQLERRM;
                  p_tab_error
                     (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'traspaso_riesgos. Error traspaso tablas AUTDETRIESGOS.',
                      mens
                     );
                  EXIT;
            END;
         END IF;                                          /* cobjase = 5*/
                                               /* BUG17255:DRA:25/07/2011:Fi*/
      END LOOP;

      /* ******************** Borrado de riesgos *************************/
      IF mens IS NULL
      THEN
         FOR reg IN riesgos_a_borrar
         LOOP
            /*xvila: aqui s'hauria de fer el traspas al historic una altre vegada.*/
            num_err :=
                   f_act_hisriesgo (pssegpol, reg.nriesgo, NVL (pnmovimi, 1));

            IF num_err <> 0
            THEN
               v_tab := 2;
               RAISE salida;
            END IF;

            /* Primero borramos las tablas relacionadas con riesgos (como TARJETAS)*/
            DELETE FROM tarjetas
                  WHERE sseguro = pssegpol AND nriesgo = reg.nriesgo;

            DELETE FROM sitriesgo
                  WHERE sseguro = pssegpol AND nriesgo = reg.nriesgo;

            /* Taules autos*/
            DELETE FROM autconductores
                  WHERE sseguro = pssegpol AND nriesgo = reg.nriesgo;

            DELETE FROM autdetriesgos
                  WHERE sseguro = pssegpol AND nriesgo = reg.nriesgo;

            DELETE FROM autdisriesgos
                  WHERE sseguro = pssegpol AND nriesgo = reg.nriesgo;

            DELETE FROM autriesgos
                  WHERE sseguro = pssegpol AND nriesgo = reg.nriesgo;

            DELETE FROM riesgos
                  WHERE sseguro = pssegpol AND nriesgo = reg.nriesgo;
         END LOOP;

         /* ******************** Inserción de riesgos nuevos *************************/
         FOR reg IN riesgos_a_insertar
         LOOP
            /*MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo*/
            INSERT INTO riesgos
                        (nriesgo, sseguro, nmovima, fefecto,
                         sperson, cclarie, nmovimb, fanulac,
                         tnatrie, cdomici, nasegur, nedacol,
                         csexcol, sbonush, czbonus,
                         ctipdiraut, spermin, cactivi,
                         /* Ini Bug 21907 -- MDS -- 23/04/2012*/
                         pdtocom, precarg, pdtotec, preccom,
                         cmodalidad,
                         tdescrie          -- BUG CONF-114 - 21/09/2016 - JAEG
                        /* Fin Bug 21907 -- MDS -- 23/04/2012*/
                        )
                 VALUES (reg.nriesgo, pssegpol, reg.nmovima, reg.fefecto,
                         reg.sperson, reg.cclarie, reg.nmovimb, reg.fanulac,
                         reg.tnatrie, reg.cdomici, reg.nasegur, reg.nedacol,
                         reg.csexcol, reg.sbonush, reg.czbonus,
                         reg.ctipdiraut, reg.spermin, reg.cactivi,
                         /* Ini Bug 21907 -- MDS -- 23/04/2012*/
                         reg.pdtocom, reg.precarg, reg.pdtotec, reg.preccom,
                         reg.cmodalidad,
                         reg.tdescrie      -- BUG CONF-114 - 21/09/2016 - JAEG
                        /* Fin Bug 21907 -- MDS -- 23/04/2012*/
                        );

            /* Bug 12668 - 17/02/2010 - AMC*/
            INSERT INTO sitriesgo
                        (sseguro, nriesgo, tdomici, cprovin, cpostal, cpoblac,
                         csiglas, tnomvia, nnumvia, tcomple, cciudad, fgisx,
                         fgisy, fgisz, cvalida, cviavp, clitvp, cbisvp, corvp,
                         nviaadco, clitco, corco, nplacaco, cor2co, cdet1ia,
                         tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia,
                         iddomici, localidad, fdefecto, descripcion)
               (SELECT pssegpol, nriesgo, tdomici, cprovin, cpostal, cpoblac,
                       csiglas, tnomvia, nnumvia, tcomple, cciudad, fgisx,
                       fgisy, fgisz, cvalida, cviavp, clitvp, cbisvp, corvp,
                       nviaadco, clitco, corco, nplacaco, cor2co, cdet1ia,
                       tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, iddomici,
                       localidad, fdefecto, descripcion
                  FROM estsitriesgo
                 WHERE sseguro = psseguro AND nriesgo = reg.nriesgo);

            /* Fi Bug 12668 - 17/02/2010 - AMC*/
            /* Bug 20893/111636 - 02/05/2012 - AMC*/
            INSERT INTO dir_riesgos
                        (sseguro, nriesgo, iddomici)
               (SELECT pssegpol, nriesgo, iddomici
                  FROM estdir_riesgos
                 WHERE sseguro = psseguro AND nriesgo = reg.nriesgo);

            /* Fi Bug 20893/111636 - 02/05/2012 - AMC*/
            /* Si el riesgo es 'autos' insertamos AUTCONDUCTORES*/
            IF v_cobjase = 5
            THEN
               BEGIN
                  INSERT INTO autriesgos
                              (sseguro, nriesgo, nmovimi, cversion, ctipmat,
                               cmatric, cuso, csubuso, fmatric, nkilometros,
                               cvehnue, ivehicu, npma, ntara, ccolor,
                               nbastid, nplazas, cgaraje, cusorem, cremolque,
                               triesgo, cpaisorigen, cchasis, ivehinue,
                               nkilometraje, ccilindraje, codmotor, cpintura,
                               ccaja, ccampero, ctipcarroceria, cservicio,
                               corigen, ctransporte, anyo, cmotor, ffinciant,
                               ciaant,
                                      /* BUG: 0027953/0151258 - JSV 21/08/2013*/
                                      cmodalidad, cpeso, ctransmision,
                               npuertas)
                                      /*BUG 30256/166723 - 21/02/2014 - RCL*/
                     (SELECT pssegpol, nriesgo, NVL (pnmovimi, 1), cversion,
                             ctipmat, cmatric, cuso, csubuso, fmatric,
                             nkilometros, cvehnue, ivehicu, npma, ntara,
                             ccolor, nbastid, nplazas, cgaraje, cusorem,
                             cremolque, triesgo, cpaisorigen, cchasis,
                             ivehinue, nkilometraje, ccilindraje, codmotor,
                             cpintura, ccaja, ccampero, ctipcarroceria,
                             cservicio, corigen, ctransporte, anyo, cmotor,
                             ffinciant, ciaant,
                                   /* BUG: 0027953/0151258 - JSV 21/08/2013*/
                                               cmodalidad, cpeso,
                             ctransmision,
                             npuertas /*BUG 30256/166723 - 21/02/2014 - RCL*/
                        FROM estautriesgos
                       WHERE sseguro = psseguro AND nriesgo = reg.nriesgo);

                  INSERT INTO autdetriesgos
                              (sseguro, nriesgo, nmovimi, cversion,
                               caccesorio, ctipacc, fini, ivalacc, tdesacc,
                               casegurable)
                     (SELECT pssegpol, nriesgo, NVL (pnmovimi, 1), cversion,
                             caccesorio, ctipacc, fini, ivalacc, tdesacc,
                             casegurable
                        FROM estautdetriesgos
                       WHERE sseguro = psseguro AND nriesgo = reg.nriesgo);

                  INSERT INTO autdisriesgos
                              (sseguro, nriesgo, nmovimi, cversion,
                               cdispositivo, cpropdisp, ivaldisp,
                               finicontrato, ffincontrato, ncontrato,
                               tdescdisp)
                     (SELECT pssegpol, nriesgo, NVL (pnmovimi, 1), cversion,
                             cdispositivo, cpropdisp, ivaldisp, finicontrato,
                             ffincontrato, ncontrato, tdescdisp
                        FROM estautdisriesgos
                       WHERE sseguro = psseguro AND nriesgo = reg.nriesgo);

                  /* Bug 25368/133447 - 08/01/2013 - AMC*/
                  /* Bug 25368/135191 - 15/01/2013 - AMC*/
                  INSERT INTO autconductores
                              (sseguro, nriesgo, nmovimi, norden, sperson,
                               fnacimi, fcarnet, csexo, npuntos, cdomici,
                               cprincipal, exper_manual, exper_cexper,
                               exper_sinie, exper_sinie_manual)
                     (SELECT pssegpol, nriesgo, NVL (pnmovimi, 1), norden,
                                     /*JRH 04/2008 JRH IMP sperson,
                                                                           */
                             pac_persona.f_sperson_spereal (e.sperson)
                                                                     sperson,
                             fnacimi, fcarnet, csexo, npuntos, cdomici,
                             cprincipal, exper_manual, exper_cexper,
                             exper_sinie, exper_sinie_manual
                        FROM estautconductores e
                       WHERE sseguro = psseguro AND nriesgo = reg.nriesgo);
               /* Fi Bug 25368/133447 - 08/01/2013 - AMC*/
               /* Fi Bug 25368/135191 - 15/01/2013 - AMC*/
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     mens := SQLERRM;
                     EXIT;
               END;
            END IF;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN salida
      THEN
         /*mens := num_err; No pasem el literal sinó el SQLERRM*/
         mens := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      v_tab,
                      'traspaso_riesgos.Error traspaso tabla RIESGOS.',
                      SQLERRM
                     );
      WHEN OTHERS
      THEN
         /*mens := num_err; No pasem el literal sinó el SQLERRM*/
         mens := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      v_tab,
                      'traspaso_riesgos.Error traspaso tabla RIESGOS.',
                      SQLERRM
                     );
   END traspaso_riesgos;

/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
   PROCEDURE traspaso_garantias (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      pspertom   IN       NUMBER,           /* No se utiliza. Se pasa a NULO*/
      programa   IN       VARCHAR2 DEFAULT 'ALCTR126',
      mens       OUT      VARCHAR2,
      pnmovimi   IN       NUMBER DEFAULT NULL,
      pfefecto   IN       DATE DEFAULT NULL
   )
   IS
      /**/
      CURSOR garantias
      IS
         SELECT cgarant, nriesgo, nmovima, nmovimi
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nmovimi = NVL (pnmovimi, nmovimi)
            AND (NVL (cobliga, 1) = 1 OR ctipgar = 8);

      cc          NUMBER;
      cg          NUMBER;
      cs          NUMBER;
      co          NUMBER;
      /* Bug 10757 - RSC - 20/07/2009 - Grabar en la tabla DETGARANSEG en los productos de Nueva Emisión*/
      v_error     NUMBER;
      v_sproduc   NUMBER;
   /* Fin Bug 10757*/
   BEGIN
      /* insertamos las garantías*/
      BEGIN
         /* Ini Bug 21907 -- MDS -- 23/04/2012*/
         /* FBL. 25/06/2014 MSV Bug 0028974*/
         INSERT INTO garanseg
                     (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden,
                      crevali, ctarifa, icapital, precarg, iextrap, iprianu,
                      ffinefe, cformul, ctipfra, ifranqu, irecarg, ipritar,
                      pdtocom, idtocom, prevali, irevali, itarifa, itarrea,
                      ipritot, icaptot, pdtoint, idtoint, ftarifa, feprev,
                      fpprev, percre, crevalcar, cmatch, tdesmat, pintfin,
                      cref, cintref, pdif, pinttec, nparben, nbns, tmgaran,
                      cderreg, ccampanya, nversio, nmovima, cageven, nfactor,
                      nlinea, cmotmov, finider, falta, cfranq, nfraver,
                      ngrpfra, ngrpgara, pdtofra, ctarman, nordfra, itotanu,
                      pdtotec, preccom, idtotec, ireccom, icaprecomend,
                      ipricom, finivig, ffinvig, ccobprima, ipridev
                                                                   -- BUG 41143/229973 - 17/03/2016 - JAEG
                     )
            (SELECT cgarant, nriesgo, nmovimi, pssegpol,
                    NVL (pfefecto, finiefe), norden, crevali, ctarifa,
                    icapital, precarg, iextrap, iprianu, ffinefe, cformul,
                    ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom,
                    prevali, irevali, itarifa, itarrea, ipritot, icaptot,
                    pdtoint, idtoint, ftarifa, feprev, fpprev, percre,
                    crevalcar, cmatch, tdesmat, pintfin, cref, cintref, pdif,
                    pinttec, nparben, nbns, tmgaran, cderreg, ccampanya,
                    nversio, nmovima, cageven, nfactor, nlinea, cmotmov,
                    finider, falta, cfranq, nfraver, ngrpfra, ngrpgara,
                    pdtofra, ctarman, nordfra, itotanu, pdtotec, preccom,
                    idtotec, ireccom, icaprecomend, ipricom, finivig,
                    ffinvig,          -- BUG 41143/229973 - 17/03/2016 - JAEG
                            ccobprima,
                                      -- BUG 41143/229973 - 17/03/2016 - JAEG
                    ipridev           -- BUG 41143/229973 - 17/03/2016 - JAEG
               FROM estgaranseg
              WHERE sseguro = psseguro
                AND nmovimi = NVL (pnmovimi, nmovimi)
                AND (NVL (cobliga, 1) = 1 OR ctipgar = 8));
      /* Fin  Bug 21907 -- MDS -- 23/04/2012*/
      /* Fin FBL. 25/06/2014 MSV Bug 0028974*/
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            mens := SQLERRM;
         WHEN OTHERS
         THEN
            mens := SQLERRM;
      END;

      BEGIN
         INSERT INTO garandetcap
                     (sseguro, nriesgo, cgarant, nmovimi, norden, cconcepto,
                      tdescrip, icapital)
            (SELECT pssegpol, e.nriesgo, e.cgarant, e.nmovimi, e.norden,
                    e.cconcepto, e.tdescrip, e.icapital
               FROM estgarandetcap e
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            mens := SQLERRM;
         WHEN OTHERS
         THEN
            mens := SQLERRM;
      END;

      FOR c IN garantias
      LOOP
         /* DELETE      pregungaranseg*/
         /*      WHERE sseguro = psseguro*/
         /*      AND nmovimi = NVL(pnmovimi, nmovimi)*/
         /*    AND cgarant = c.cgarant*/
         /*  AND nriesgo = c.nriesgo*/
         /*AND nmovima = c.nmovima;*/
         BEGIN
            INSERT INTO pregungaranseg
                        (sseguro, nriesgo, cgarant, cpregun, crespue,
                         nmovimi, nmovima, finiefe, trespue)
               (SELECT pssegpol, nriesgo, cgarant, cpregun, crespue,
                       NVL (pnmovimi, nmovimi), nmovima,
                       NVL (pfefecto, finiefe), trespue
                  FROM estpregungaranseg
                 WHERE sseguro = psseguro
                   AND nmovimi = NVL (pnmovimi, nmovimi)
                   AND cgarant = c.cgarant
                   AND nriesgo = c.nriesgo
                   AND nmovima = c.nmovima);

            INSERT INTO pregungaransegtab
                        (sseguro, nriesgo, cgarant, cpregun, nmovimi, nmovima,
                         finiefe, nlinea, ccolumna, tvalor, fvalor, nvalor)
               (SELECT pssegpol, nriesgo, cgarant, cpregun,
                       NVL (pnmovimi, nmovimi), nmovima,
                       NVL (pfefecto, finiefe), nlinea, ccolumna, tvalor,
                       fvalor, nvalor
                  FROM estpregungaransegtab
                 WHERE sseguro = psseguro
                   AND nmovimi = NVL (pnmovimi, nmovimi)
                   AND cgarant = c.cgarant
                   AND nriesgo = c.nriesgo
                   AND nmovima = c.nmovima);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         /*ReglasSeguro*/
         BEGIN
            SELECT COUNT (1)
              INTO co
              FROM estreglassegtramos
             WHERE sseguro = psseguro
               AND nmovimi = c.nmovimi
               AND nriesgo = c.nriesgo
               AND cgarant = c.cgarant;

            IF co > 0
            THEN
               INSERT INTO reglasseg
                           (sseguro, nriesgo, cgarant, nmovimi, capmaxemp,
                            capminemp, capmaxtra, capmintra)
                  (SELECT pssegpol, nriesgo, cgarant, nmovimi, capmaxemp,
                          capminemp, capmaxtra, capmintra
                     FROM estreglasseg
                    WHERE sseguro = psseguro
                      AND nmovimi = c.nmovimi
                      AND nriesgo = c.nriesgo
                      AND cgarant = c.cgarant);

               INSERT INTO reglassegtramos
                           (sseguro, nriesgo, cgarant, nmovimi, edadini,
                            edadfin, t1copagemp, t1copagtra, t2copagemp,
                            t2copagtra, t3copagemp, t3copagtra, t4copagemp,
                            t4copagtra)
                  (SELECT pssegpol, nriesgo, cgarant, nmovimi, edadini,
                          edadfin, t1copagemp, t1copagtra, t2copagemp,
                          t2copagtra, t3copagemp, t3copagtra, t4copagemp,
                          t4copagtra
                     FROM estreglassegtramos
                    WHERE sseguro = psseguro
                      AND nmovimi = c.nmovimi
                      AND nriesgo = c.nriesgo
                      AND cgarant = c.cgarant);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         /* Bug 21121 - APD - 21/02/2012 - se incluye la tabla detprimas*/
         BEGIN
            /* Bug 23807 - APD - 08/10/2012 - se añade el nriesgo*/
            SELECT COUNT (*)
              INTO cc
              FROM estdetprimas
             WHERE sseguro = psseguro
               AND nmovimi = c.nmovimi
               AND nriesgo = c.nriesgo
               AND cgarant = c.cgarant;

            /* fin Bug 23807 - APD - 08/10/2012*/
            IF cc > 0
            THEN
               /* Bug 23807 - APD - 08/10/2012 - se añade el nriesgo*/
               INSERT INTO detprimas
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            ccampo, cconcep, norden, iconcep, iconcep2)
                  (SELECT pssegpol, nriesgo, cgarant, nmovimi,
                          NVL (pfefecto, finiefe), ccampo, cconcep, norden,
                          iconcep, iconcep2
                     FROM estdetprimas
                    WHERE sseguro = psseguro
                      AND nmovimi = c.nmovimi
                      AND nriesgo = c.nriesgo
                      AND cgarant = c.cgarant);
            /* fin Bug 23807 - APD - 08/10/2012*/
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
         /* fin Bug 21121 - APD - 21/02/2012*/
      /**/
      END LOOP;

      /* Bug 10757 - RSC - 20/07/2009 - Grabar en la tabla DETGARANSEG en los productos de Nueva Emisión*/
      v_error := pac_seguros.f_get_sproduc (psseguro, 'EST', v_sproduc);

      IF v_error <> 0
      THEN
         mens := f_axis_literales (v_error, -1);
      END IF;

      /*IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN   -- BUG11305:DRA:30/09/2009*/
      BEGIN
         INSERT INTO detgaranseg
                     (sseguro, cgarant, nriesgo, nmovimi, finiefe, ndetgar,
                      fefecto, fvencim, ndurcob, ctarifa, pinttec, ftarifa,
                      crevali, prevali, irevali, icapital, iprianu, precarg,
                      irecarg, cparben, cprepost, ffincob, ipritar, provmat0,
                      fprovmat0, provmat1, fprovmat1, pintmin, pdtocom,
                      idtocom, ctarman, ipripur, ipriinv, itarrea, cagente,
                      cunica)
            (SELECT pssegpol, g.cgarant, g.nriesgo,
                    NVL (pnmovimi, g.nmovimi), NVL (pfefecto, e.finiefe),
                    e.ndetgar, e.fefecto, e.fvencim, e.ndurcob, e.ctarifa,
                    e.pinttec, e.ftarifa, e.crevali, e.prevali, e.irevali,
                    e.icapital, e.iprianu, e.precarg, e.irecarg, e.cparben,
                    e.cprepost, e.ffincob, e.ipritar, e.provmat0,
                    e.fprovmat0, e.provmat1, e.fprovmat1, e.pintmin,
                    e.pdtocom, e.idtocom, e.ctarman, e.ipripur, e.ipriinv,
                    e.itarrea, e.cagente, DECODE (e.cunica, 1, 1, 0)
               FROM estgaranseg g, estdetgaranseg e
              WHERE g.sseguro = psseguro
                AND g.nmovimi = NVL (pnmovimi, g.nmovimi)
                AND (NVL (g.cobliga, 1) = 1 OR g.ctipgar = 8)
                AND e.sseguro = g.sseguro
                AND e.nriesgo = g.nriesgo
                AND e.cgarant = g.cgarant
                AND e.nmovimi = g.nmovimi
                AND e.finiefe = g.finiefe);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            mens := SQLERRM;
         WHEN OTHERS
         THEN
            mens := SQLERRM;
      END;

      /*END IF;*/
      /* Fin Bug 10757*/
      BEGIN
         SELECT COUNT (*)
           INTO cc
           FROM estgaransegcom
          WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi);
      END;

      IF cc > 0
      THEN
         /* FBL. 25/06/2014 MSV Bug 0028974*/
         INSERT INTO garansegcom
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, cmodcom,
                      pcomisi, ninialt, nfinalt, pcomisicua, ipricom,
                      cageven)
            (SELECT pssegpol, nriesgo, cgarant, nmovimi,
                    NVL (finiefe, pfefecto), cmodcom, pcomisi, ninialt,
                    nfinalt, pcomisicua, ipricom, cageven
               FROM estgaransegcom eg, estseguros es
              WHERE eg.sseguro = psseguro
                AND es.sseguro = eg.sseguro
                AND (   es.ctipcom = 91
                     OR NVL
                           (pac_parametros.f_parproducto_n
                                                        (es.sproduc,
                                                         'AFECTA_COMISESPPROD'
                                                        ),
                            1
                           ) = 1
                    )
                AND eg.nmovimi = NVL (pnmovimi, nmovimi));
      /* Fin FBL. 25/06/2014 MSV Bug 0028974*/
      END IF;

      BEGIN
         SELECT COUNT (*)
           INTO cg
           FROM estgaranseggas
          WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi);
      END;

      IF cg > 0
      THEN
         INSERT INTO garanseggas
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, cgastos,
                      pvalor, pvalres, nprima)
            (SELECT pssegpol, nriesgo, cgarant, nmovimi,
                    NVL (pfefecto, finiefe), cgastos, pvalor, pvalres,
                    nprima
               FROM estgaranseggas
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));
      END IF;

      BEGIN
         SELECT COUNT (*)
           INTO cs
           FROM estgaranseg_sbpri
          WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi);
      END;

      IF cs > 0
      THEN
         INSERT INTO garanseg_sbpri
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, norden,
                      ctipsbr, ccalsbr, pvalor, ncomisi)
            (SELECT pssegpol, nriesgo, cgarant, nmovimi,
                    NVL (pfefecto, finiefe), norden, ctipsbr, ccalsbr,
                    pvalor, ncomisi
               FROM estgaranseg_sbpri
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));
      END IF;
   END;

/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
   PROCEDURE traspaso_movseguro (
      psseguro   IN       NUMBER,
      pfefecto   IN       DATE,
      pcdomper   IN       NUMBER,
      mens       OUT      VARCHAR2
   )
   IS
      /********************************************************************************************
                           Si no existe movimiento de seguro para este seguro, lo insertamos, sino lo modificamos
      ********************************************************************************************/
      v_nmovimi   NUMBER;
      num_err     NUMBER;
      v_mov       NUMBER;
   BEGIN
      SELECT nmovimi
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

      UPDATE movseguro
         SET fefecto = pfefecto,
             cdomper = pcdomper
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         num_err :=
            f_movseguro (psseguro,
                         NULL,
                         100,
                         0,
                         pfefecto,
                         NULL,
                         0,
                         0,
                         NULL,
                         v_mov,
                         NULL,
                         pcdomper
                        );

         IF num_err <> 0
         THEN
            mens := 'Error en traspaso movseguro';
         END IF;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126.traspaso_movseguro',
                      '1',
                      '1',
                      SQLCODE || ' - ' || SQLERRM
                     );
         mens := 'Error en traspaso movseguro';
   END traspaso_movseguro;

/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
   PROCEDURE traspaso_seguro (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      mens       OUT      VARCHAR2
   )
   IS
      /* Procediment per traspassar de estseguros a seguros */
      cont                  NUMBER;
      aux_seguro            estseguros%ROWTYPE;
      aux_seguro_assp       estseguros_assp%ROWTYPE;
      aux_seguro_aho        estseguros_aho%ROWTYPE;
      aux_seguro_ulk        estseguros_ulk%ROWTYPE;       /* RSC 16-07-2007*/
                  /*JRH  Rentas 09/2007*/
      aux_seguro_ren        estseguros_ren%ROWTYPE;
      aux_seguro_act        estseguros_act%ROWTYPE;
      /*JRH  Rentas Irregulares 08/2007*/
      aux_planrentasirreg   planrentasirreg%ROWTYPE;
      aux_planrentasextra   planrentasextra%ROWTYPE;
      hay_assp              NUMBER;
      hay_aho               NUMBER;
      hay_ulk               NUMBER;
      /*JRH  Rentas 09/2007*/
      hay_ren               NUMBER;
      hay_act               NUMBER;
      /*JRH  Rentas Irregulares 08/2007*/
      hay_irr               NUMBER;
      hay_ext               NUMBER;
      vnmovimi              NUMBER;
      hay_reemplazos        NUMBER;                                /* 19276*/
      v_ncuacoa             NUMBER;                 /* 23184 AVT 06/11/2012*/
      hay_age               NUMBER;                             --CONF-108 AP
      hay_susp              NUMBER;               -- CONF-274-25/11/2016-JLTS
      cidioma_1             NUMBER;

      -- Ini IAXIS-13888 -- 22/05/2020
      CURSOR c_agenda
      IS
         SELECT nlinea, falta, ctipreg, cestado, cusualt, ttitulo, ffinali,
                ttextos, cmanual, cusumod, fmodifi
           FROM estagensegu e
          WHERE e.sseguro IN (SELECT sseguro
                                FROM estseguros a
                               WHERE a.ssegpol = aux_seguro.ssegpol);
   --IAXIS-13888 -- 22/05/2020
   BEGIN
      p_tab_error (f_sysdate,
                   f_user,
                   'etm',
                   6,
                      'pssegpol -->'
                   || pssegpol
                   || 'psseguro-->'
                   || psseguro
                   || ' aux_seguro.npreimpreso'
                   || aux_seguro.npreimpreso,
                   SQLERRM
                  );

      SELECT COUNT (*)
        INTO cont
        FROM seguros
       WHERE sseguro = pssegpol;

      /* IAXIS-13888  2020/05/20  */
      BEGIN
         SELECT *
           INTO aux_seguro
           FROM estseguros
          WHERE sseguro = psseguro AND creteni = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT *
                 INTO aux_seguro
                 FROM estseguros
                WHERE ssegpol = pssegpol AND creteni = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT *
                       INTO aux_seguro
                       FROM estseguros
                      WHERE ssegpol = pssegpol AND creteni = 0;
                  END;
            END;
      END;

/* IAXIS-13888  2020/05/20  */
      p_tab_error (f_sysdate,
                   f_user,
                   'etm',
                   6,
                      'aux_seguro.pssegpol -->'
                   || aux_seguro.ssegpol
                   || 'aux_seguro.psseguro-->'
                   || aux_seguro.sseguro
                   || ' aux_seguro.npreimpreso'
                   || aux_seguro.npreimpreso,
                   SQLERRM
                  );

      SELECT nvalpar
        INTO cidioma_1
        FROM parempresas
       WHERE cparam = 'IDIOMA_DEF';       --Inc 1559 confianza KJSC 29/11/2017

      /* Miramos si hay que traspasar ESTSEGUROS_ASSP*/
      SELECT COUNT (*)
        INTO hay_assp
        FROM estseguros_assp
       WHERE sseguro = psseguro;

      SELECT COUNT (*)
        INTO hay_aho
        FROM estseguros_aho
       WHERE sseguro = psseguro;

      SELECT COUNT (*)
        INTO hay_ren
        FROM estseguros_ren
       WHERE sseguro = psseguro;

      SELECT COUNT (*)
        INTO hay_act
        FROM estseguros_act
       WHERE sseguro = psseguro;

      SELECT COUNT (*)
        INTO hay_irr
        FROM estplanrentasirreg
       WHERE sseguro = psseguro;

      /* 19276*/
      SELECT COUNT (*)
        INTO hay_reemplazos
        FROM estreemplazos
       WHERE sseguro = psseguro;

      SELECT COUNT (*)
        INTO hay_ulk
        FROM estseguros_ulk
       WHERE sseguro = psseguro;

      -- CONF-108 AP
      SELECT COUNT (*)
        INTO hay_age
        FROM estagensegu e
       WHERE e.sseguro IN (SELECT sseguro
                             FROM estseguros a
                            WHERE a.ssegpol = aux_seguro.ssegpol);

      -- CONF-108 AP
      -- CONF-274-25/11/2016-JLTS- Ini
      SELECT COUNT (*)
        INTO hay_susp
        FROM estsuspensionseg e
       WHERE e.sseguro = psseguro;

      -- CONF-274-25/11/2016-JLTS- Fin
      IF hay_assp > 0
      THEN
         SELECT *
           INTO aux_seguro_assp
           FROM estseguros_assp
          WHERE sseguro = psseguro;
      END IF;

      IF hay_aho > 0
      THEN
         SELECT *
           INTO aux_seguro_aho
           FROM estseguros_aho
          WHERE sseguro = psseguro;
      END IF;

      IF hay_ulk > 0
      THEN
         SELECT *
           INTO aux_seguro_ulk
           FROM estseguros_ulk
          WHERE sseguro = psseguro;
      END IF;

      IF hay_ren > 0
      THEN
         SELECT *
           INTO aux_seguro_ren
           FROM estseguros_ren
          WHERE sseguro = psseguro;
      END IF;

      IF hay_act > 0
      THEN
         SELECT *
           INTO aux_seguro_act
           FROM estseguros_act
          WHERE sseguro = psseguro;
      END IF;

      /*JRH 03/2008*/
      IF hay_irr > 0
      THEN
         SELECT DISTINCT nmovimi
                    INTO vnmovimi
                    FROM estplanrentasirreg
                   WHERE sseguro = psseguro;
      END IF;

      /* Mantis 10240.06/2009.NMM.*/
      /*JRH 03/2008*/
      /*IF hay_ext > 0 THEN
                                                   SELECT *
           INTO aux_planrentasextra
           FROM estplanrentasextra
          WHERE sseguro = psseguro;
      END IF;*/
      /* 23184 AVT 06/11/2012*/
      BEGIN
         SELECT MAX (ncuacoa) + 1
           INTO v_ncuacoa
           FROM coacuadro
          WHERE sseguro = aux_seguro.ssegpol;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_ncuacoa := NULL;
      END;

      /* FI 23184 AVT 06/11/2012*/
      /* Si no existeix el seguro, el creem.*/
      IF cont = 0
      THEN
         INSERT INTO seguros
                     (sseguro, cmodali,
                      ccolect, ctipseg,
                      casegur, cagente,
                      cramo, npoliza,
                      ncertif, nsuplem,
                      fefecto, creafac,
                      ctarman, cobjase,
                      ctipreb, cactivi,
                      ccobban, ctipcoa,
                      ctiprea, crecman,
                      creccob, ctipcom,
                      fvencim, femisio,
                      fanulac, fcancel,
                      csituac, cbancar,
                      ctipcol, fcarant,
                      fcarpro, fcaranu,
                      cduraci, nduraci,
                      nanuali, iprianu,
                      cidioma,
                      nfracci, cforpag,
                      pdtoord, nrenova,
                      crecfra, tasegur,
                      creteni, ndurcob,
                      sciacoa, pparcoa,
                      npolcoa, nsupcoa,
                      tnatrie, pdtocom,
                      prevali, irevali,
                      ncuacoa,
                      nedamed, crevali,
                      cempres, cagrpro,
                      nsolici,
                      fimpsol, ccompani,
                      intpres, nmescob,
                      cnotibaja, ccartera,
                      nparben, nbns,
                      ctramo, cindext,
                      cpolcia,
                              /* BUG 14585 - PFA - Anadir campo poliza compania*/
                              pdispri,
                      idispri, cimpase,
                      cagencorr, sprodtar,
                      ctipcob,
                              /*// ACC 11012007 nou camp per controlar forma pagament*/
                              /*//jfd 20080117 CREDIT*/
                              ctipban,
                      csubage,
                              /* BUG11618:DRA:02/11/2009*/
                              cpromotor,
                      cmoneda,
                              /* Bug 19372/91763 - 07/09/2011 - AMC*/
                              ncuotar,
                      /* BUG 0020761 - 03/01/2012 - JMF*/
                      /* BUG 21924 - 16/04/2012 - ETM*/
                      ctipretr, cindrevfran,
                      precarg, pdtotec,
                      preccom,
                      /* FIN BUG 21924 - 16/04/2012 - ETM*/
                      frenova
                             /* BUG 0023117 - FAL - 26/07/2012*/
         ,
                      nedamar,
                              /* BUG 0025584 - MMS - 19/02/2013*/
                              /* bug 24685 2013-02-14 AEG*/
                              ctipoasignum,
                      npolizamanual,
                      npreimpreso            /* fin bug 24685 2013-02-14 AEG*/
                                 /* 24818 -- Indico proceso*/,
                      procesocarga, sproduc,
                      fefeplazo, fvencplazo
                     )                 -- BUG 41143/229973 - 17/03/2016 - JAEG
              VALUES (aux_seguro.ssegpol, aux_seguro.cmodali,
                      aux_seguro.ccolect, aux_seguro.ctipseg,
                      aux_seguro.casegur, aux_seguro.cagente,
                      aux_seguro.cramo, aux_seguro.npoliza,
                      aux_seguro.ncertif, aux_seguro.nsuplem,
                      aux_seguro.fefecto, aux_seguro.creafac,
                      aux_seguro.ctarman, aux_seguro.cobjase,
                      aux_seguro.ctipreb, aux_seguro.cactivi,
                      aux_seguro.ccobban, aux_seguro.ctipcoa,
                      aux_seguro.ctiprea, aux_seguro.crecman,
                      aux_seguro.creccob, aux_seguro.ctipcom,
                      aux_seguro.fvencim, aux_seguro.femisio,
                      aux_seguro.fanulac, aux_seguro.fcancel,
                      aux_seguro.csituac, aux_seguro.cbancar,
                      aux_seguro.ctipcol, aux_seguro.fcarant,
                      aux_seguro.fcarpro, aux_seguro.fcaranu,
                      aux_seguro.cduraci, aux_seguro.nduraci,
                      aux_seguro.nanuali, aux_seguro.iprianu,
                      NVL (aux_seguro.cidioma, cidioma_1),
                      aux_seguro.nfracci, aux_seguro.cforpag,
                                          --Inc 1559 confianza KJSC 29/11/2017
                      aux_seguro.pdtoord, aux_seguro.nrenova,
                      aux_seguro.crecfra, aux_seguro.tasegur,
                      aux_seguro.creteni, aux_seguro.ndurcob,
                      aux_seguro.sciacoa, aux_seguro.pparcoa,
                      aux_seguro.npolcoa, aux_seguro.nsupcoa,
                      aux_seguro.tnatrie, aux_seguro.pdtocom,
                      aux_seguro.prevali, aux_seguro.irevali,
                      NVL (v_ncuacoa, aux_seguro.ncuacoa),
                                                     /* 23184 AVT 06/11/2012*/
                      aux_seguro.nedamed, aux_seguro.crevali,
                      aux_seguro.cempres, aux_seguro.cagrpro,
                      NVL (aux_seguro.npreimpreso, aux_seguro.nsolici),
                      aux_seguro.fimpsol, aux_seguro.ccompani,
                      aux_seguro.intpres, aux_seguro.nmescob,
                      aux_seguro.cnotibaja, aux_seguro.ccartera,
                      aux_seguro.nparben, aux_seguro.nbns,
                      aux_seguro.ctramo, aux_seguro.cindext,
                      aux_seguro.cpolcia,
                                         /* BUG 14585 - PFA - Anadir campo poliza compania*/
                                         aux_seguro.pdispri,
                      aux_seguro.idispri, aux_seguro.cimpase,
                      aux_seguro.cagencorr, aux_seguro.sprodtar,
                      aux_seguro.ctipcob,
                                         /*// ACC 11012007 nou camp per controlar forma pagament*/
                                         /*//jfd 20080117 CREDIT*/
                                         aux_seguro.ctipban,
                      aux_seguro.csubage,         /* BUG11618:DRA:02/11/2009*/
                                         aux_seguro.cpromotor,
                      aux_seguro.cmoneda,
                                         /* Bug 19372/91763 - 07/09/2011 - AMC*/
                                         aux_seguro.ncuotar,
                      /* BUG 0020761 - 03/01/2012 - JMF*/
                      /* BUG 21924 - 16/04/2012 - ETM*/
                      aux_seguro.ctipretr, aux_seguro.cindrevfran,
                      aux_seguro.precarg, aux_seguro.pdtotec,
                      aux_seguro.preccom,
                                         /* FIN BUG 21924 - 16/04/2012 - ETM*/
                      aux_seguro.frenova /* BUG 0023117 - FAL - 26/07/2012*/,
                      aux_seguro.nedamar,  /* BUG 0025584 - MMS - 19/02/2013*/
                       /* bug 24685 2013-02-14 AEG*/ aux_seguro.ctipoasignum,
                      aux_seguro.npolizamanual,
                      aux_seguro.npreimpreso
                                            /* fin bug 24685 2013-02-14 AEG*/ /* 24818 -- Indico proceso*/
         ,
                      aux_seguro.procesocarga, aux_seguro.sproduc,
                      aux_seguro.fefeplazo, aux_seguro.fvencplazo
                     );                -- BUG 41143/229973 - 17/03/2016 - JAEG

         /* Si existeix el seguro, el modifiquem*/
         p_tab_error (f_sysdate,
                      f_user,
                      'etm',
                      6,
                         ' aux_seguro.ctipoasignum'
                      || aux_seguro.ctipoasignum
                      || 'aux_seguro.npolizamanual'
                      || aux_seguro.npolizamanual
                      || ' aux_seguro.npreimpreso'
                      || aux_seguro.npreimpreso,
                      SQLERRM
                     );                                         /*etm quitar*/
      ELSE
         UPDATE seguros
            SET sseguro = aux_seguro.ssegpol,
                cmodali = aux_seguro.cmodali,
                ccolect = aux_seguro.ccolect,
                ctipseg = aux_seguro.ctipseg,
                casegur = aux_seguro.casegur,
                cagente = aux_seguro.cagente,
                cramo = aux_seguro.cramo,
                npoliza = aux_seguro.npoliza,
                ncertif = aux_seguro.ncertif,
                nsuplem = aux_seguro.nsuplem,
                fefecto = aux_seguro.fefecto,
                creafac = aux_seguro.creafac,
                ctarman = aux_seguro.ctarman,
                cobjase = aux_seguro.cobjase,
                ctipreb = aux_seguro.ctipreb,
                cactivi = aux_seguro.cactivi,
                ccobban = aux_seguro.ccobban,
                ctipcoa = aux_seguro.ctipcoa,
                ctiprea = aux_seguro.ctiprea,
                crecman = aux_seguro.crecman,
                creccob = aux_seguro.creccob,
                ctipcom = aux_seguro.ctipcom,
                fvencim = aux_seguro.fvencim,
                femisio = aux_seguro.femisio,
                fanulac = aux_seguro.fanulac,
                fcancel = aux_seguro.fcancel,
                csituac = aux_seguro.csituac,
                cbancar = aux_seguro.cbancar,
                ctipcol = aux_seguro.ctipcol,
                fcarant = aux_seguro.fcarant,
                fcarpro = aux_seguro.fcarpro,
                fcaranu = aux_seguro.fcaranu,
                cduraci = aux_seguro.cduraci,
                nduraci = aux_seguro.nduraci,
                nanuali = aux_seguro.nanuali,
                iprianu = aux_seguro.iprianu,
                cidioma = NVL (aux_seguro.cidioma, cidioma_1),
                                          --Inc 1559 confianza KJSC 29/11/2017
                nfracci = aux_seguro.nfracci,
                cforpag = aux_seguro.cforpag,
                pdtoord = aux_seguro.pdtoord,
                nrenova = aux_seguro.nrenova,
                crecfra = aux_seguro.crecfra,
                tasegur = aux_seguro.tasegur,
                creteni = aux_seguro.creteni,
                ndurcob = aux_seguro.ndurcob,
                sciacoa = aux_seguro.sciacoa,
                pparcoa = aux_seguro.pparcoa,
                npolcoa = aux_seguro.npolcoa,
                nsupcoa = aux_seguro.nsupcoa,
                tnatrie = aux_seguro.tnatrie,
                pdtocom = aux_seguro.pdtocom,
                prevali = aux_seguro.prevali,
                irevali = aux_seguro.irevali,
                ncuacoa = NVL (v_ncuacoa, aux_seguro.ncuacoa),
                /* 23184 AVT 06/11/2012*/
                nedamed = aux_seguro.nedamed,
                crevali = aux_seguro.crevali,
                cempres = aux_seguro.cempres,
                cagrpro = aux_seguro.cagrpro,
                nsolici = aux_seguro.nsolici,
                fimpsol = aux_seguro.fimpsol,
                ccompani = aux_seguro.ccompani,
                intpres = aux_seguro.intpres,
                nmescob = aux_seguro.nmescob,
                cnotibaja = aux_seguro.cnotibaja,
                ccartera = aux_seguro.ccartera,
                nparben = aux_seguro.nparben,
                nbns = aux_seguro.nbns,
                ctramo = aux_seguro.ctramo,
                cindext = aux_seguro.cindext,
                pdispri = aux_seguro.pdispri,
                idispri = aux_seguro.idispri,
                cimpase = aux_seguro.cimpase,
                cagencorr = aux_seguro.cagencorr,
                sprodtar = aux_seguro.sprodtar,
                cpolcia = aux_seguro.cpolcia,
                /* BUG 14585 - PFA - Anadir campo poliza compania*/
                ctipcob = aux_seguro.ctipcob,
                /*// ACC 11012007 nou camp per controlar forma pagament*/
                ctipban = aux_seguro.ctipban,        /*//jfd 20080117 CREDIT*/
                csubage = aux_seguro.csubage,     /* BUG11618:DRA:02/11/2009*/
                cpromotor = aux_seguro.cpromotor,
                /* Bug 19372/91763 - 07/09/2011 - AMC*/
                cmoneda = aux_seguro.cmoneda,
                ncuotar = aux_seguro.ncuotar,
                /* BUG 0020761 - 03/01/2012 - JMF*/
                /* BUG 21924 - 16/04/2012 - ETM*/
                ctipretr = aux_seguro.ctipretr,
                cindrevfran = aux_seguro.cindrevfran,
                precarg = aux_seguro.precarg,
                pdtotec = aux_seguro.pdtotec,
                preccom = aux_seguro.preccom,
                /* FIN BUG 21924 - 16/04/2012 - ETM*/
                frenova =
                         aux_seguro.frenova /* BUG 0023117 - FAL - 26/07/2012*/,
                nedamar = aux_seguro.nedamar,
                /* BUG 0025584 - MMS - 19/02/2013*/
                /* bug 24685 2013-02-14 AEG*/
                ctipoasignum = aux_seguro.ctipoasignum,
                npolizamanual = aux_seguro.npolizamanual,
                npreimpreso = aux_seguro.npreimpreso
                                                    /* 24818 -- Indico proceso*/
         ,
                procesocarga = aux_seguro.procesocarga,
                sproduc = aux_seguro.sproduc,
                fefeplazo = aux_seguro.fefeplazo,
                                       -- BUG 41143/229973 - 17/03/2016 - JAEG
                fvencplazo =
                   aux_seguro.fvencplazo
                                       -- BUG 41143/229973 - 17/03/2016 - JAEG
          /* fin bug 24685 2013-02-14 AEG*/
         WHERE  sseguro = pssegpol;

         p_tab_error (f_sysdate,
                      f_user,
                      'etm',
                      7,
                         ' aux_seguro.ctipoasignum'
                      || aux_seguro.ctipoasignum
                      || 'aux_seguro.npolizamanual'
                      || aux_seguro.npolizamanual
                      || ' aux_seguro.npreimpreso'
                      || aux_seguro.npreimpreso,
                      SQLERRM
                     );                                         /*etm quitar*/

         UPDATE seguros_assp
            SET sseguro = pssegpol,
                ssegvin = aux_seguro_assp.ssegvin,
                iimppre = aux_seguro_assp.iimppre,
                fcarult = aux_seguro_assp.fcarult,
                pintpre = aux_seguro_assp.pintpre,
                ncaren = aux_seguro_assp.ncaren,
                nnumreci = aux_seguro_assp.nnumreci,
                cforamor = aux_seguro_assp.cforamor,
                ctapres = aux_seguro_assp.ctapres
          /*  ctipban = aux_seguro_assp.ctipban --//jfd 20080117 CREDIT*/
         WHERE  sseguro = pssegpol;
      END IF;

      IF hay_assp > 0
      THEN
         DELETE FROM seguros_assp
               WHERE sseguro = pssegpol;

         INSERT INTO seguros_assp
                     (sseguro, ssegvin,
                      iimppre, fcarult,
                      pintpre, ncaren,
                      nnumreci, cforamor,
                      ctapres /* ctipban --//jfd 20080117 CREDIT*/
                     )
              VALUES (pssegpol, aux_seguro_assp.ssegvin,
                      aux_seguro_assp.iimppre, aux_seguro_assp.fcarult,
                      aux_seguro_assp.pintpre, aux_seguro_assp.ncaren,
                      aux_seguro_assp.nnumreci, aux_seguro_assp.cforamor,
                      aux_seguro_assp.ctapres
                     /*aux_seguro_assp.ctipban --//jfd 20080117 CREDIT*/
                     );
      END IF;

      IF hay_aho > 0
      THEN
         DELETE FROM seguros_aho
               WHERE sseguro = pssegpol;

         INSERT INTO seguros_aho
                     (sseguro, pinttec,
                      pintpac, fsusapo,
                      ndurper, frevisio,
                      ndurrev, pintrev,
                      frevant, cfprest
                     )
              VALUES (pssegpol, aux_seguro_aho.pinttec,
                      aux_seguro_aho.pintpac, aux_seguro_aho.fsusapo,
                      aux_seguro_aho.ndurper, aux_seguro_aho.frevisio,
                      aux_seguro_aho.ndurrev, aux_seguro_aho.pintrev,
                      aux_seguro_aho.frevant, aux_seguro_aho.cfprest
                     );
      END IF;

      IF hay_ulk > 0
      THEN
         DELETE FROM seguros_ulk
               WHERE sseguro = pssegpol;

         INSERT INTO seguros_ulk
                     (sseguro, psalmin,
                      isalcue, cseghos,
                      cmodinv, cgasges,
                      cgasred
                     )
              VALUES (pssegpol, aux_seguro_ulk.psalmin,
                      aux_seguro_ulk.isalcue, aux_seguro_ulk.cseghos,
                      aux_seguro_ulk.cmodinv, aux_seguro_ulk.cgasges,
                      aux_seguro_ulk.cgasred
                     );
      END IF;

      /*JRH  09/2007 Rentas*/
      IF hay_ren > 0
      THEN
         DELETE FROM seguros_ren
               WHERE sseguro = pssegpol;

         INSERT INTO seguros_ren
                     (sseguro, f1paren,
                      fuparen, cforpag,
                      ibruren, ffinren,
                      cmotivo, cmodali,
                      fppren, ibrure2,
                      fintgar, cestmre,
                      cblopag, nduraint,
                      ptipoint, pdoscab,
                      icapren, pcapfall,
                      ireserva, frevant,
                      pcaprev, nmesextra,
                      imesextra /* NMM.24735.03.2013.*/
                     )
              VALUES (pssegpol, aux_seguro_ren.f1paren,
                      aux_seguro_ren.fuparen, aux_seguro_ren.cforpag,
                      aux_seguro_ren.ibruren, aux_seguro_ren.ffinren,
                      aux_seguro_ren.cmotivo, aux_seguro_ren.cmodali,
                      aux_seguro_ren.fppren, aux_seguro_ren.ibrure2,
                      aux_seguro_ren.fintgar, aux_seguro_ren.cestmre,
                      aux_seguro_ren.cblopag, aux_seguro_ren.nduraint,
                      aux_seguro_ren.ptipoint, aux_seguro_ren.pdoscab,
                      aux_seguro_ren.icapren, aux_seguro_ren.pcapfall,
                      aux_seguro_ren.ireserva, aux_seguro_ren.frevant,
                      aux_seguro_ren.pcaprev, aux_seguro_ren.nmesextra,
                      aux_seguro_ren.imesextra
                     /* NMM.24735.03.2013.*/
                     );
      END IF;

      /*JRH  09/2007 Rentas*/
      IF hay_act > 0
      THEN
         DELETE FROM seguros_act
               WHERE sseguro = pssegpol;

         INSERT INTO seguros_act
                     (sseguro, sactivo
                     )
              VALUES (pssegpol, aux_seguro_act.sactivo
                     );
      END IF;

      /*JRH  03/2008 Rentas*/
      IF hay_irr > 0
      THEN
         DELETE FROM planrentasirreg
               WHERE sseguro = pssegpol
                 AND nriesgo = aux_planrentasirreg.nriesgo
                 AND nmovimi = vnmovimi;

         FOR aux_planrentasirreg IN (SELECT *
                                       FROM estplanrentasirreg
                                      WHERE sseguro = psseguro)
         LOOP
            /*DELETE FROM PLANRENTASIRREG*/
            /*WHERE       sseguro = pssegpol AND NRIESGO=aux_PLANRENTASIRREG.NRIESGO;*/
            INSERT INTO planrentasirreg
                        (sseguro, nriesgo,
                         nmovimi,
                         mes, anyo,
                         importe
                        )
                 VALUES (pssegpol, aux_planrentasirreg.nriesgo,
                         aux_planrentasirreg.nmovimi,
                         aux_planrentasirreg.mes, aux_planrentasirreg.anyo,
                         aux_planrentasirreg.importe
                        );
         END LOOP;
      END IF;

      IF hay_ext > 0
      THEN
         DELETE FROM planrentasextra
               WHERE sseguro = pssegpol
                 AND nriesgo = aux_planrentasextra.nriesgo
                 AND nmovimi = vnmovimi;
      /* Mantis 10240.06/2009.NMM.*/
      /*FOR aux_planrentasextra IN (SELECT *
                                                                              FROM estplanrentasextra
                                   WHERE sseguro = psseguro) LOOP
         --DELETE FROM PLANRENTASIRREG
         --WHERE       sseguro = pssegpol AND NRIESGO=aux_PLANRENTASIRREG.NRIESGO;
         INSERT INTO planrentasextra
                     (sseguro, nriesgo, nmovimi,
                      fpago, ipago,
                      cestado, srecren)
              VALUES (pssegpol, aux_planrentasextra.nriesgo, aux_planrentasextra.nmovimi,
                      aux_planrentasextra.fpago, aux_planrentasextra.ipago,
                      aux_planrentasextra.cestado, aux_planrentasextra.srecren);
      END LOOP;*/
      END IF;

      /* Ini bug 19276, jbn, 19276*/
      IF hay_reemplazos > 0
      THEN
         BEGIN
            /*LECG 15/11/2012 BUG: 24714 - Inserta el campo CTIPO*/
            INSERT INTO reemplazos
                        (sseguro, sreempl, fmovdia, cusuario, cagente, ctipo)
               (SELECT pssegpol, sreempl, fmovdia, cusuario, cagente, ctipo
                  FROM estreemplazos
                 WHERE sseguro = psseguro);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               NULL;
         END;
      END IF;

      -- IAXIS-13888 -- 20/05/2020
      -- CONF-108 AP
      IF hay_age > 0
      THEN
         FOR i IN c_agenda
         LOOP
            BEGIN
               INSERT INTO agensegu
                           (sseguro, nlinea,
                            falta, ctipreg, cestado, cusualt,
                            ttitulo, ffinali, ttextos, cmanual,
                            cusumod, fmodifi
                           )
                    VALUES (aux_seguro.ssegpol, i.nlinea,
                            i.falta, i.ctipreg, i.cestado, i.cusualt,
                            i.ttitulo, i.ffinali, i.ttextos, i.cmanual,
                            i.cusumod, i.fmodifi
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  BEGIN
                     INSERT INTO agensegu
                                 (sseguro,
                                  nlinea, falta,
                                  ctipreg, cestado, cusualt,
                                  ttitulo, ffinali, ttextos,
                                  cmanual, cusumod, fmodifi
                                 )
                          VALUES (aux_seguro.ssegpol,
                                  i.nlinea + 1, i.falta,
                                  i.ctipreg, i.cestado, i.cusualt,
                                  i.ttitulo, i.ffinali, i.ttextos,
                                  i.cmanual, i.cusumod, i.fmodifi
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                  END;
            END;
         END LOOP;
      END IF;

      -- CONF-108 AP
      -- IAXIS-13888 -- 20/05/2020
      -- CONF-274-25/11/2016-JLTS- Ini
      IF hay_susp > 0
      THEN
         INSERT INTO suspensionseg
                     (sseguro, finicio, ffinal, ttexto, cmotmov, nmovimi,
                      fvigencia)
            SELECT pssegpol sseguro, finicio, ffinal, ttexto, cmotmov,
                   nmovimi, fvigencia
              FROM estsuspensionseg e
             WHERE e.sseguro = psseguro;
      END IF;
   -- CONF-274-25/11/2016-JLTS- Fin
   END traspaso_seguro;

   -- INI BUG 40927/228750 - 07/03/2016 - JAEG
   /*************************************************************************
      PROCEDURE p_traspaso_contgaran

      param in psseguro    : psseguro
      param in mensajes    : t_iax_mensajes
      return               : t_iax_contragaran
   *************************************************************************/
   PROCEDURE traspaso_contgaran (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pmensaje   OUT      VARCHAR2
   )
   IS
      --
      paso   NUMBER := 1;
   --
   BEGIN
      --
      INSERT INTO per_contragarantia
         (SELECT p.scontgar, pac_persona.f_sperson_spereal (p.sperson)
            FROM estper_contragarantia p, estctgar_seguro cs
           WHERE cs.sseguro = psseguro
             AND p.scontgar = cs.scontgar
             AND cs.nmovimi = (SELECT MAX (nmovimi)
                                 FROM ctgar_contragarantia
                                WHERE scontgar = cs.scontgar));

      --
      INSERT INTO ctgar_seguro
         (SELECT cs.scontgar, pssegpol, cs.nmovimi
            FROM estctgar_seguro cs
           WHERE cs.sseguro = psseguro
             AND cs.nmovimi = (SELECT MAX (nmovimi)
                                 FROM ctgar_contragarantia
                                WHERE scontgar = cs.scontgar));
   --
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         --
         NULL;
      --
      WHEN OTHERS
      THEN
         --
         pmensaje := 'Error traspaso contragarantías';
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      paso,
                      pmensaje,
                      SQLERRM
                     );
   --
   END traspaso_contgaran;

   -- FIN BUG 40927/228750 - 07/03/2016 - JAEG

   /*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
   PROCEDURE traspaso_tablas_seguros (
      psseguro   IN       NUMBER,
      mens       OUT      VARCHAR2,
      programa   IN       VARCHAR2 DEFAULT 'ALCTR126',
      pcmotmov   IN       NUMBER DEFAULT NULL,
      pfecha     IN       DATE DEFAULT NULL
   )
   IS
      /* Procediment per traspassar de les taules reals a les d'estudis*/
      aux_ssegpol     NUMBER;
      v_cobjase       NUMBER (2);
      v_nmovimi       NUMBER;
      v_nmovimi_new   NUMBER;                     /* BUG9329:DRA:21/05/2009*/
                            /*vnmovimi_aux   NUMBER;*/
      contador_pre    NUMBER;
      v_risc          NUMBER;
      cc              NUMBER;
      cg              NUMBER;
      cs              NUMBER;
      num_err         NUMBER;
      v_csituac       NUMBER;
      vsproduc        seguros.sproduc%TYPE;
      /* Bug 0025955 --ECP -- 01/02/2013*/
      v_nocurre       NUMBER;
      vcsubpro        NUMBER;
      v_polissa_ini   VARCHAR2 (15);
      vcagente        agentes.cagente%TYPE;
                                      /* dra 29-9-2008: bug mantis 7567*/
  /* Bug 10656 - 07/07/2009 - RSC - Error en suplemento de cambio de cuenta*/
      v_aux_ssegpol   seg_cbancar.sseguro%TYPE;
      v_mensajes      t_iax_mensajes;                                 /*RDD*/
      salida          EXCEPTION;                                      /*RDD*/

      /* Bug 10656*/
      CURSOR tomadores
      IS
         SELECT sperson
           FROM tomadores
          WHERE sseguro = psseguro;

      CURSOR cur_riesgos
      IS
         SELECT nriesgo, sperson
           FROM riesgos
          WHERE sseguro = psseguro AND fanulac IS NULL;

      /*JRH 04/2008*/
      /* bug 0025583 controlar persona informada*/
      CURSOR cur_personas
      IS                                              /* v_personas_seguros*/
         SELECT sperson
           FROM v_personas_seguros
          WHERE sseguro = psseguro AND sperson IS NOT NULL;

      vsperson        NUMBER;
      paso            NUMBER;
      vnmovimi_ir     NUMBER;
      vnmovimi_bpm    NUMBER;         /*Bug 28263/153355 - 02/10/2013 - AMC*/
   BEGIN
      paso := 1;

      /* Ini Bug 0025955 --ECP -- 01/02/2013*/
      SELECT cobjase, csituac, cagente,
             sproduc                       /* dra 29-9-2008: bug mantis 7567*/
        INTO v_cobjase, v_csituac, vcagente,
             vsproduc                      /* dra 29-9-2008: bug mantis 7567*/
        FROM seguros
       WHERE sseguro = psseguro;

      /* Fin  Bug 0025955 --ECP -- 01/02/2013*/
      paso := 2;

      SELECT sestudi.NEXTVAL
        INTO aux_ssegpol
        FROM DUAL;

      paso := 3;

      SELECT NVL (MAX (nmovimi), 0)
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

      /*         AND cmovseg <> 6;  -- BUG 34461, 34462 - Productos de CONVENIOS*/
      paso := 4;

      /* BUG9329:DRA:21/05/2009:Inici*/
      /* Bug 23940 - APD - 13/11/2012 - se añade del csituac = 17.-Prop. Cartera*/
      SELECT DECODE (v_csituac,
                     4, v_nmovimi,
                     5, v_nmovimi,
                     17, v_nmovimi,
                     v_nmovimi + 1
                    )
        INTO v_nmovimi_new
        FROM DUAL;

      paso := 5;

      /* BUG9329:DRA:21/05/2009:Fi*/
      BEGIN
         SELECT polissa_ini
           INTO v_polissa_ini
           FROM cnvpolizas
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_polissa_ini := NULL;
      END;

      paso := 6;

      INSERT INTO estseguros
                  (sseguro, cmodali, ccolect, ctipseg, casegur, cagente,
                   cramo, npoliza, ncertif, nsuplem, fefecto, creafac,
                   ctarman, cobjase, ctipreb, cactivi, ccobban, ctipcoa,
                   ctiprea, crecman, creccob, ctipcom, fvencim, femisio,
                   fanulac, fcancel, csituac, cbancar, ctipcol, fcarant,
                   fcarpro, fcaranu, cduraci, nduraci, nanuali, iprianu,
                   cidioma, nfracci, cforpag, pdtoord, nrenova, crecfra,
                   tasegur, creteni, ndurcob, sciacoa, pparcoa, npolcoa,
                   nsupcoa, tnatrie, pdtocom, prevali, irevali, ncuacoa,
                   nedamed, crevali, cempres, cagrpro, ssegpol, ctipest,
                   ccompani, nparben, nbns, ctramo, cpolcia,
                                                            /* BUG 14585 - PFA - Anadir campo poliza compania*/
                                                            cindext, pdispri,
                   idispri, cimpase, sproduc, intpres, nmescob, cnotibaja,
                   ccartera, cagencorr, nsolici, fimpsol, sprodtar, ctipcob,
                   
                   /*// ACC 11012007 nou camp per controlar forma pagament*/
                   ctipban,
                           /*//jfd 20080117 CREDIT*/
                           polissa_ini, csubage,
                                                /* BUG11618:DRA:02/11/2009*/
                                                cpromotor, cmoneda,
                                                                   /* Bug 19372/91763 - 07/09/2011 - AMC*/
                                                                   ncuotar,
                   
                   /* BUG 0020761 - 03/01/2012 - JMF*/
                   /* BUG 21924 - 16/04/2012 - ETM*/
                   ctipretr, cindrevfran, precarg, pdtotec, preccom, /* FIN BUG 21924 - 16/04/2012 - ETM*/ frenova
                                                                                                                  /* BUG 0023117 - FAL - 26/07/2012*/
                   ,
                   nedamar,
                           /* BUG 0025584 - MMS - 19/02/2013*/ /* bug 24685 2013-02-14 AEG*/
                           ctipoasignum, npolizamanual, npreimpreso
                                                                   /* fin bug 24685 2013-02-14 AEG*/ /* 24818 -- Añado proceso*/
                   ,
                   procesocarga, fefeplazo, fvencplazo)
                                       -- BUG 41143/229973 - 17/03/2016 - JAEG
         (SELECT aux_ssegpol, cmodali, ccolect, ctipseg, casegur, cagente,
                 cramo, npoliza, ncertif, nsuplem, fefecto, creafac, ctarman,
                 cobjase, ctipreb, cactivi, ccobban, ctipcoa, ctiprea,
                 crecman, creccob, ctipcom, fvencim, femisio, fanulac,
                 fcancel, csituac, cbancar, ctipcol, fcarant, fcarpro,
                 fcaranu, cduraci, nduraci, nanuali, iprianu, cidioma,
                 nfracci, cforpag, pdtoord, nrenova, crecfra, tasegur,
                 creteni, ndurcob, sciacoa, pparcoa, npolcoa, nsupcoa,
                 tnatrie, pdtocom, prevali, irevali, ncuacoa, nedamed,
                 crevali, cempres, cagrpro, sseguro, 0, ccompani, nparben,
                 nbns, ctramo, cpolcia,
                           /* BUG 14585 - PFA - Anadir campo poliza compania*/
                                       cindext, pdispri, idispri, cimpase,
                 sproduc, intpres, nmescob, cnotibaja, ccartera, cagencorr,
                 nsolici, fimpsol, sprodtar, ctipcob,
                       /* ACC 11012007 nou camp per controlar forma pagament*/
                                                     ctipban,
                                                      /* jfd 20080117 CREDIT*/
                                                             v_polissa_ini,
                 csubage,                         /* BUG11618:DRA:02/11/2009*/
                         cpromotor,    /* Bug 19372/91763 - 07/09/2011 - AMC*/
                                   cmoneda, ncuotar,
         /* BUG 0020761 - 03/01/2012 - JMF*/ /* BUG 21924 - 16/04/2012 - ETM*/
                                                    ctipretr, cindrevfran,
                 precarg, pdtotec, preccom,
                                         /* FIN BUG 21924 - 16/04/2012 - ETM*/
                 frenova /* BUG 0023117 - FAL - 26/07/2012*/, nedamar,
             /* BUG 0025584 - MMS - 19/02/2013*/ /* bug 24685 2013-02-14 AEG*/
                 ctipoasignum, npolizamanual,
                 npreimpreso /* fin bug 24685 2013-02-14 AEG*/ /* 24818 -- Añado proceso*/,
                 procesocarga, fefeplazo,
                 fvencplazo            -- BUG 41143/229973 - 17/03/2016 - JAEG
            FROM seguros
           WHERE sseguro = psseguro);

      paso := 7;

      FOR reg IN cur_personas
      LOOP
         pac_persona.borrar_tablas_estpereal (reg.sperson, aux_ssegpol);
         paso := 8;
         pac_persona.traspaso_tablas_per (reg.sperson,
                                          vsperson,
                                          aux_ssegpol,
                                          vcagente
                                         );
      END LOOP;

      paso := 9;

      /*(JAS)11.12.2007 - Gestió de preguntes per pòlissa*/
      /*// ACC 12022008 afegixo control del nmovimi*/
      INSERT INTO estpregunpolseg
                  (sseguro, cpregun, crespue, trespue, nmovimi)
         (SELECT aux_ssegpol, cpregun, crespue, trespue, v_nmovimi_new
            FROM pregunpolseg
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM pregunpolseg
                                                    WHERE sseguro = psseguro));

      INSERT INTO estpregunpolsegtab
                  (sseguro, cpregun, nmovimi, nlinea, ccolumna, tvalor,
                   fvalor, nvalor)
         (SELECT aux_ssegpol, cpregun, v_nmovimi_new, nlinea, ccolumna,
                 tvalor, fvalor, nvalor
            FROM pregunpolsegtab
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM pregunpolsegtab
                                                    WHERE sseguro = psseguro));

      paso := 10;

      /* FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador - Añadir CEXISTEPAGADOR*/
      INSERT INTO esttomadores
                  (sperson, sseguro, nordtom, cdomici, cexistepagador,
                   cagrupa)                         --IAXIS-2085 03/04/2019 AP
         (SELECT pac_persona.f_spereal_sperson (sperson, aux_ssegpol),
                 aux_ssegpol, nordtom, cdomici, cexistepagador,
                 cagrupa                            --IAXIS-2085 03/04/2019 AP
            FROM tomadores
           WHERE sseguro = psseguro);

      /*JRH 04/2008*/
      /*FOR c IN tomadores
                                                LOOP
         SELECT DECODE (v_csituac, 4, v_nmovimi, 5, v_nmovimi, v_nmovimi + 1)
         INTO   vnmovimi_aux
         FROM   DUAL;
         IF vnmovimi_aux > 1 THEN
            num_err    :=
               pk_suplementos.f_traspasar_direcciones (psseguro,
                                                       c.sperson,
                                                       vnmovimi_aux
                                                      );
         END IF;
      END LOOP;
      FOR c IN cur_riesgos
      LOOP
         SELECT DECODE (v_csituac, 4, v_nmovimi, 5, v_nmovimi, v_nmovimi + 1)
         INTO   vnmovimi_aux
         FROM   DUAL;
         IF vnmovimi_aux > 1 THEN
            num_err    :=
               pk_suplementos.f_traspasar_direcciones (psseguro,
                                                       c.sperson,
                                                       vnmovimi_aux
                                                      );
         END IF;
      END LOOP;*/
      paso := 11;

      INSERT INTO estseguros_assp
                  (sseguro, ssegvin, iimppre, fcarult, pintpre, ncaren,
                   nnumreci, cforamor, ctapres)
         (SELECT aux_ssegpol, ssegvin, iimppre, fcarult, pintpre, ncaren,
                 nnumreci, cforamor, ctapres
            FROM seguros_assp
           WHERE sseguro = psseguro);

      paso := 12;

      INSERT INTO estassegurats
                  (sseguro, sperson, norden, cdomici, ffecini, ffecfin,
                   ffecmue, fecretroact, cparen)
         (SELECT aux_ssegpol,
                 pac_persona.f_spereal_sperson (sperson, aux_ssegpol),
                                                                  /*sperson,*/
                                                                      norden,
                 cdomici, ffecini, ffecfin, ffecmue, fecretroact, cparen
            FROM asegurados
           WHERE sseguro = psseguro);

      paso := 13;

      /*MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo*/
      INSERT INTO estriesgos
                  (nriesgo, sseguro, nmovima, fefecto, sperson, cclarie,
                   nmovimb, fanulac, tnatrie, cdomici, nasegur, nedacol,
                   csexcol, sbonush, czbonus, ctipdiraut, cactivi,
                                         /* Ini Bug 21907 - MDS - 02/05/2012*/
                                                                  pdtocom,
                   precarg, pdtotec, preccom,
                   tdescrie                -- BUG CONF-114 - 21/09/2016 - JAEG
                           /* Fin Bug 21907 - MDS - 02/05/2012*/
                  )
         (SELECT nriesgo, aux_ssegpol, nmovima, fefecto,         /* sperson,*/
                 pac_persona.f_spereal_sperson (sperson, aux_ssegpol),
                 cclarie, nmovimb, fanulac, tnatrie, cdomici, nasegur,
                 nedacol, csexcol, sbonush, czbonus, ctipdiraut, cactivi,
                                         /* Ini Bug 21907 - MDS - 02/05/2012*/
                 pdtocom, precarg, pdtotec, preccom,
                                         /* Fin Bug 21907 - MDS - 02/05/2012*/
                 tdescrie                  -- BUG CONF-114 - 21/09/2016 - JAEG
            FROM riesgos
           WHERE sseguro = psseguro);

      paso := 14;

      /* Bug 12668 - 17/02/2010 - AMC*/
      INSERT INTO estsitriesgo
                  (sseguro, nriesgo, tdomici, cprovin, cpostal, cpoblac,
                   csiglas, tnomvia, nnumvia, tcomple, cciudad, fgisx, fgisy,
                   fgisz, cvalida)
         (SELECT aux_ssegpol, nriesgo, tdomici, cprovin, cpostal, cpoblac,
                 csiglas, tnomvia, nnumvia, tcomple, cciudad, fgisx, fgisy,
                 fgisz, cvalida
            FROM sitriesgo
           WHERE sseguro = psseguro);

      /* Fi Bug 12668 - 17/02/2010 - AMC*/
      paso := 15;

      /* Bug 20893/111636 - 02/05/2012 - AMC*/
      INSERT INTO estdir_riesgos
                  (sseguro, nriesgo, iddomici)
         (SELECT aux_ssegpol, nriesgo, iddomici
            FROM dir_riesgos
           WHERE sseguro = psseguro);

      /* Fi Bug 20893/111636 - 02/05/2012 - AMC*/
      FOR reg_risc IN cur_riesgos
      LOOP
         /***************** Inici de traspas de taules de autos *************/
         IF v_cobjase = 5
         THEN
            INSERT INTO estautriesgos
                        (sseguro, nriesgo, nmovimi, cversion, ctipmat,
                         cmatric, cuso, csubuso, fmatric, nkilometros,
                         cvehnue, ivehicu, npma, ntara, ccolor, nbastid,
                         nplazas, cgaraje, cusorem, cremolque, triesgo,
                         cpaisorigen, cchasis, ivehinue, nkilometraje,
                         ccilindraje, codmotor, cpintura, ccaja, ccampero,
                         ctipcarroceria, cservicio, corigen, ctransporte,
                         anyo, cmotor, ffinciant, ciaant,
                                                         /* BUG: 0027953/0151258 - JSV 21/08/2013*/
                                                         cmodalidad, cpeso,
                         ctransmision, npuertas)
                                      /*BUG 30256/166723 - 21/02/2014 - RCL*/
               (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cversion,
                       ctipmat, cmatric, cuso, csubuso, fmatric, nkilometros,
                       cvehnue, ivehicu, npma, ntara, ccolor, nbastid,
                       nplazas, cgaraje, cusorem, cremolque, triesgo,
                       cpaisorigen, cchasis, ivehinue, nkilometraje,
                       ccilindraje, codmotor, cpintura, ccaja, ccampero,
                       ctipcarroceria, cservicio, corigen, ctransporte, anyo,
                       cmotor, ffinciant, ciaant,
                                   /* BUG: 0027953/0151258 - JSV 21/08/2013*/
                                                 cmodalidad, cpeso,
                       ctransmision,
                       npuertas       /*BUG 30256/166723 - 21/02/2014 - RCL*/
                  FROM autriesgos
                 WHERE sseguro = psseguro
                   AND nriesgo = reg_risc.nriesgo
                   AND nmovimi =
                          (SELECT MAX (nmovimi)
                             FROM autriesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = reg_risc.nriesgo));

            paso := 16;

            /* Bug 25368/133447 - 08/01/2013 - AMC*/
            /* Bug 25368/135191 - 15/01/2013 - AMC*/
            INSERT INTO estautconductores
                        (sseguro, nriesgo, nmovimi, norden, sperson, fnacimi,
                         fcarnet, csexo, npuntos, cdomici, cprincipal,
                         exper_manual, exper_cexper, exper_sinie,
                         exper_sinie_manual)
               (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, norden,
                                                                  /*sperson,*/
                       pac_persona.f_spereal_sperson (sperson, aux_ssegpol),
                       fnacimi, fcarnet, csexo, npuntos, cdomici, cprincipal,
                       exper_manual, exper_cexper, exper_sinie,
                       exper_sinie_manual
                  FROM autconductores
                 WHERE sseguro = psseguro
                   AND nriesgo = reg_risc.nriesgo
                   AND nmovimi =
                          (SELECT MAX (nmovimi)
                             FROM autconductores
                            WHERE sseguro = psseguro
                              AND nriesgo = reg_risc.nriesgo));

            /* Fi Bug 25368/133447 - 08/01/2013 - AMC*/
            /* Fi Bug 25368/135191 - 15/01/2013 - AMC*/
            paso := 17;

            /* Bug 32009/0180910 - APD - 28/07/2014*/
            /* Al realizar el traspaso de las tablas REALES a las EST para las tablas ESTAUTDETRIESGOS y ESTAUTDISRIESGOS*/
            /* no debe buscar la informacion en las tablas REALES para el MAX(nmovimi) de su misma tabla (ya que puede ser*/
            /* que en el movimiento anterior no hayan datos) sino el MAX(nmovimi) de la tabla AUTRIESGOS*/
            INSERT INTO estautdetriesgos
                        (sseguro, nriesgo, nmovimi, cversion, caccesorio,
                         ctipacc, fini, ivalacc, tdesacc, casegurable)
               (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cversion,
                       caccesorio, ctipacc, fini, ivalacc, tdesacc,
                       casegurable
                  FROM autdetriesgos
                 WHERE sseguro = psseguro
                   AND nriesgo = reg_risc.nriesgo
                   AND nmovimi =
                          (SELECT MAX (nmovimi)
                             FROM autriesgos                 /*autdetriesgos*/
                            WHERE sseguro = psseguro
                              AND nriesgo = reg_risc.nriesgo));

            /* fin Bug 32009/0180910 - APD - 28/07/2014*/
            /* Bug 32009/0180910 - APD - 28/07/2014*/
            /* Al realizar el traspaso de las tablas REALES a las EST para las tablas ESTAUTDETRIESGOS y ESTAUTDISRIESGOS*/
            /* no debe buscar la informacion en las tablas REALES para el MAX(nmovimi) de su misma tabla (ya que puede ser*/
            /* que en el movimiento anterior no hayan datos) sino el MAX(nmovimi) de la tabla AUTRIESGOS*/
            INSERT INTO estautdisriesgos
                        (sseguro, nriesgo, nmovimi, cversion, cdispositivo,
                         cpropdisp, ivaldisp, finicontrato, ffincontrato,
                         ncontrato, tdescdisp)
               (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cversion,
                       cdispositivo, cpropdisp, ivaldisp, finicontrato,
                       ffincontrato, ncontrato, tdescdisp
                  FROM autdisriesgos
                 WHERE sseguro = psseguro
                   AND nriesgo = reg_risc.nriesgo
                   AND nmovimi =
                          (SELECT MAX (nmovimi)
                             FROM autriesgos                 /*autdisriesgos*/
                            WHERE sseguro = psseguro
                              AND nriesgo = reg_risc.nriesgo));
         /* fin Bug 32009/0180910 - APD - 28/07/2014*/
         END IF;

         BEGIN
            INSERT INTO estprimasgaranseg
                        (sseguro, nmovimi, nriesgo, cgarant, finiefe,
                         iextrap, iprianu, ipritar, ipritot, precarg,
                         irecarg, pdtocom, idtocom, itarifa, iconsor,
                         ireccon, iips, idgs, iarbitr, ifng, irecfra,
                         itotpri, itotdto, itotcon, itotimp, icderreg,
                         itotalr, needtarifar, iprireb, itotanu, iiextrap,
                         pdtotec, preccom, idtotec, ireccom, itotrec,
                         iivaimp, iprivigencia)
               (SELECT aux_ssegpol, v_nmovimi_new, nriesgo, cgarant, finiefe,
                       iextrap, iprianu, ipritar, ipritot, precarg, irecarg,
                       pdtocom, idtocom, itarifa, iconsor, ireccon, iips,
                       idgs, iarbitr, ifng, irecfra, itotpri, itotdto,
                       itotcon, itotimp, icderreg, itotalr, needtarifar,
                       iprireb, itotanu, iiextrap, pdtotec, preccom, idtotec,
                       ireccom, itotrec, iivaimp, iprivigencia
                  FROM primasgaranseg
                 WHERE sseguro = psseguro
                   AND nriesgo = reg_risc.nriesgo
                   AND nmovimi =
                          (SELECT MAX (nmovimi)
                             FROM primasgaranseg
                            WHERE sseguro = psseguro
                              AND nriesgo = reg_risc.nriesgo));
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         paso := 18;

         INSERT INTO estpregunseg
                     (sseguro, nriesgo, cpregun, crespue, trespue, nmovimi)
            (SELECT aux_ssegpol, nriesgo, cpregun, crespue, trespue,
                    v_nmovimi_new
               FROM pregunseg
              WHERE sseguro = psseguro
                AND nriesgo = reg_risc.nriesgo
                AND nmovimi =
                       (SELECT MAX (nmovimi)
                          FROM pregunseg
                         WHERE sseguro = psseguro
                           AND nriesgo = reg_risc.nriesgo));

         INSERT INTO estpregunsegtab
                     (sseguro, nriesgo, cpregun, nlinea, ccolumna, tvalor,
                      fvalor, nvalor, nmovimi)
            (SELECT aux_ssegpol, nriesgo, cpregun, nlinea, ccolumna, tvalor,
                    fvalor, nvalor, v_nmovimi_new
               FROM pregunsegtab
              WHERE sseguro = psseguro
                AND nriesgo = reg_risc.nriesgo
                AND nmovimi =
                       (SELECT MAX (nmovimi)
                          FROM pregunsegtab
                         WHERE sseguro = psseguro
                           AND nriesgo = reg_risc.nriesgo));
      END LOOP;

      INSERT INTO estbf_bonfranseg
                  (sseguro, nriesgo, cgrup, csubgrup, cnivel, cversion,
                   nmovimi, finiefe, ctipgrup, cvalor1, impvalor1, cvalor2,
                   impvalor2, cimpmin, impmin, cimpmax, impmax, ffinefe,
                   cniveldefecto)
         (SELECT aux_ssegpol, b.nriesgo, b.cgrup, b.csubgrup, b.cnivel,
                 b.cversion, v_nmovimi_new, b.finiefe, b.ctipgrup, b.cvalor1,
                 b.impvalor1, b.cvalor2, b.impvalor2, b.cimpmin, b.impmin,
                 b.cimpmax, b.impmax, b.ffinefe, b.cniveldefecto
            FROM bf_bonfranseg b
           WHERE b.sseguro = psseguro
             AND b.nmovimi = (SELECT MAX (nmovimi)
                                FROM bf_bonfranseg
                               WHERE sseguro = psseguro));

      paso := 19;

      IF v_nmovimi <> v_nmovimi_new
      THEN
         v_nocurre := 1;
      ELSE
         v_nocurre := NULL;
      END IF;

      INSERT INTO estpsucontrolseg
                  (sseguro, nmovimi, fmovpsu, ccontrol, nriesgo, nocurre,
                   cgarant, cnivelr, establoquea, ordenbloquea, autoriprev,
                   nvalor, nvalorinf, nvalorsuper, nvalortope, cusumov,
                   cnivelu, cautrec, autmanual, fautrec, cusuaur, observ,
                   isvisible)
         (SELECT aux_ssegpol, v_nmovimi_new, s.fmovpsu, s.ccontrol, s.nriesgo,
                 NVL (v_nocurre, s.nocurre), s.cgarant, s.cnivelr,
                 s.establoquea, s.ordenbloquea, s.autoriprev, s.nvalor,
                 s.nvalorinf, s.nvalorsuper, s.nvalortope, s.cusumov,
                 s.cnivelu, s.cautrec, s.autmanual, s.fautrec, s.cusuaur,
                 s.observ, s.isvisible
            FROM psucontrolseg s, psu_controlpro c
           WHERE c.ccontrol = s.ccontrol
             AND c.sproduc = (SELECT s1.sproduc
                                FROM seguros s1
                               WHERE s1.sseguro = s.sseguro)
             AND c.cgarant = s.cgarant
             AND s.sseguro = psseguro
                  /* 23935 MRB 09/10/2012 --*/ /* 29443 - APD - 19/12/2013*/
                                                                             /*
                         AND
                             NVL(s.autoriprev, 'S') != 'N'*/
             AND (   (    NVL (c.autoriprev, 'S') != 'N'
                      AND v_nmovimi <> v_nmovimi_new
                     )
                  OR (v_nmovimi = v_nmovimi_new)
                 )                                                        /**/
             AND s.nmovimi IN (
                            SELECT MAX (nmovimi)
                              FROM psucontrolseg
                             WHERE sseguro = psseguro
                                   AND ccontrol = s.ccontrol)
             AND s.nocurre IN (
                    SELECT MAX (nocurre)
                      FROM psucontrolseg
                     WHERE sseguro = psseguro
                       AND ccontrol = s.ccontrol
                       AND nmovimi IN (
                              SELECT MAX (nmovimi)
                                FROM psucontrolseg
                               WHERE sseguro = psseguro
                                 AND ccontrol = s.ccontrol)));

      paso := 416;

      SELECT MAX (nmovimi)
        INTO vnmovimi_ir
        FROM riesgos_ir
       WHERE sseguro = psseguro;

      IF vnmovimi_ir = v_nmovimi_new
      THEN
         INSERT INTO estbasequestion_undw
                     (sseguro, nriesgo, nmovimi, cempres, sorden, code,
                      POSITION, CATEGORY, norden, question, answer)
            (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cempres, sorden,
                    code, POSITION, CATEGORY, norden, question, answer
               FROM basequestion_undw
              WHERE sseguro = psseguro
                AND nmovimi IN (SELECT MAX (nmovimi)
                                  FROM basequestion_undw
                                 WHERE sseguro = psseguro));

         paso := 419;

         INSERT INTO estactions_undw
                     (sseguro, nriesgo, nmovimi, cempres, sorden, norden,
                      action, naseg)
            (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cempres, sorden,
                    norden, action, naseg
               FROM actions_undw
              WHERE sseguro = psseguro
                AND nmovimi IN (SELECT MAX (nmovimi)
                                  FROM actions_undw
                                 WHERE sseguro = psseguro));

         paso := 420;

         INSERT INTO estexclusiones_undw
                     (sseguro, nriesgo, nmovimi, cempres, sorden, norden,
                      codegar, label, codexclus, naseg)
            (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cempres, sorden,
                    norden, codegar, label, codexclus, naseg
               FROM exclusiones_undw
              WHERE sseguro = psseguro
                AND nmovimi IN (SELECT MAX (nmovimi)
                                  FROM exclusiones_undw
                                 WHERE sseguro = psseguro));

         paso := 421;

         INSERT INTO estenfermedades_undw
                     (sseguro, nriesgo, nmovimi, cempres, sorden, norden,
                      cindex, codenf, desenf)
            (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cempres, sorden,
                    norden, cindex, codenf, desenf
               FROM enfermedades_undw
              WHERE sseguro = psseguro
                AND nmovimi IN (SELECT MAX (nmovimi)
                                  FROM enfermedades_undw
                                 WHERE sseguro = psseguro));

         paso := 422;

         INSERT INTO estriesgos_ir_ordenes
                     (sseguro, nriesgo, nmovimi, cempres, sorden, cnueva,
                      sinterf1, sinterf2)
            (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cempres, sorden,
                    cnueva, sinterf1, sinterf2
               FROM riesgos_ir_ordenes
              WHERE sseguro = psseguro
                AND nmovimi IN (SELECT MAX (nmovimi)
                                  FROM riesgos_ir_ordenes
                                 WHERE sseguro = psseguro));

         paso := 418;

         INSERT INTO estriesgos_ir
                     (sseguro, nriesgo, nmovimi, cinspreq, cresultr,
                      tperscontacto, ttelcontacto, tmailcontacto,
                      crolcontacto)
            (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, cinspreq, cresultr,
                    tperscontacto, ttelcontacto, tmailcontacto, crolcontacto
               FROM riesgos_ir
              WHERE sseguro = psseguro
                AND nmovimi IN (SELECT MAX (nmovimi)
                                  FROM riesgos_ir
                                 WHERE sseguro = psseguro));

         paso := 199;
      END IF;

      INSERT INTO estpsu_retenidas
                  (sseguro, nmovimi, fmovimi, cmotret, cnivelbpm, cusuret,
                   ffecret, cusuaut, ffecaut, observ, postpper, perpost)
         (SELECT aux_ssegpol, v_nmovimi_new, fmovimi, cmotret, cnivelbpm,
                 cusuret, ffecret, cusuaut, ffecaut, observ, postpper,
                 perpost
            FROM psu_retenidas
           WHERE sseguro = psseguro AND nmovimi IN (SELECT MAX (nmovimi)
                                                      FROM psu_retenidas
                                                     WHERE sseguro = psseguro));

      paso := 200;

      /* Ini Bug 0025955 --ECP -- 01/02/2013*/
      /* Cuando permitet_prest = 1 no debe tratar los prestaamos porque no se duplican en los movimientos*/
      IF NVL (pac_parametros.f_parproducto_n (vsproduc, 'PERMITE_PREST'), 0) <>
                                                                             1
      THEN
         /* bug 10702*/
         INSERT INTO estsaldodeutorseg
                     (sseguro, nmovimi, icapmax)
            (SELECT aux_ssegpol, v_nmovimi_new, icapmax
               FROM saldodeutorseg
              WHERE sseguro = psseguro
                AND nmovimi IN (SELECT MAX (nmovimi)
                                  FROM saldodeutorseg
                                 WHERE sseguro = psseguro));

         paso := 20;

         /* Bug 11165 - 16/09/2009 - AMC - Se sustituñe  estdetsaldodeutorseg por estprestamoseg*/
         /* Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el update*/
         /* Bug 0010908 - 17/12/2009 - JMF: canvi saldodeutorseg per prestamoseg*/
         /* Bug 0010908 - 17/12/2009 - JMF: Afegir calcul falta*/
         INSERT INTO estprestamoseg
                     (sseguro, nriesgo, nmovimi, ctapres, ctipcuenta, ctipban,
                      ctipimp, isaldo, porcen, ilimite, icapmax, icapital,
                      cmoneda, icapaseg, descripcion, falta, finiprest,
                      ffinprest)
            (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, ctapres, ctipcuenta,
                    ctipban, ctipimp, isaldo, porcen, ilimite, icapmax,
                    icapital, cmoneda, icapaseg, descripcion,
                    NVL ((SELECT MAX (b.falta)
                            FROM prestamos b
                           WHERE b.ctapres = a.ctapres), a.falta) falta,
                    finiprest, ffinprest
               FROM prestamoseg a
              WHERE sseguro = psseguro
                AND nmovimi IN (SELECT MAX (nmovimi)
                                  FROM prestamoseg
                                 WHERE sseguro = psseguro));
      END IF;

      /* Fin Bug 0025955 --ECP -- 01/02/2013*/
      paso := 21;

      /*  Fin bug 10702*/
      /* FBL. 25/06/2014 MSV Bug 0028974*/
      /* Ini Bug 21907 - MDS - 02/05/2012*/
      INSERT INTO estgaranseg
                  (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden,
                   crevali, ctarifa, icapital, precarg, iextrap, iprianu,
                   ffinefe, cformul, ctipfra, ifranqu, irecarg, ipritar,
                   pdtocom, idtocom, prevali, irevali, itarifa, itarrea,
                   ipritot, icaptot, ftarifa, crevalcar, pdtoint, idtoint,
                   feprev, fpprev, percre, cmatch, tdesmat, pintfin, cref,
                   cintref, pdif, pinttec, nparben, nbns, tmgaran, cderreg,
                   ccampanya, nversio, nmovima, cageven, nfactor, nlinea,
                   cfranq, nfraver, ngrpfra, ngrpgara, nordfra, pdtofra,
                   cmotmov, finider, falta, ctarman, itotanu, pdtotec,
                   preccom, idtotec, ireccom, icaprecomend, ipricom, finivig,
                   ffinvig, ccobprima, ipridev
                                              -- BUG 41143/229973 - 17/03/2016 - JAEG
                  )
         (SELECT cgarant, nriesgo, v_nmovimi_new, aux_ssegpol,
                 NVL (pfecha, finiefe), norden, crevali, ctarifa, icapital,
                 precarg, iextrap, iprianu, ffinefe, cformul, ctipfra,
                 ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                 irevali, itarifa, itarrea, ipritot, icaptot, ftarifa,
                 crevalcar, pdtoint, idtoint, feprev, fpprev, percre, cmatch,
                 tdesmat, pintfin, cref, cintref, pdif, pinttec, nparben,
                 nbns, tmgaran, cderreg, ccampanya, nversio, nmovima, cageven,
                 nfactor, nlinea, cfranq, nfraver, ngrpfra, ngrpgara, nordfra,
                 pdtofra, cmotmov, NVL (finider, NVL (pfecha, finiefe)),
                 NVL (falta, NVL (pfecha, finiefe)), ctarman, itotanu,
                 pdtotec, preccom, idtotec, ireccom, icaprecomend, ipricom,
                 finivig, ffinvig,     -- BUG 41143/229973 - 17/03/2016 - JAEG
                                  ccobprima,
                                       -- BUG 41143/229973 - 17/03/2016 - JAEG
                 ipridev               -- BUG 41143/229973 - 17/03/2016 - JAEG
            FROM garanseg
           WHERE sseguro = psseguro AND ffinefe IS NULL);

      /* Fin Bug 21907 - MDS - 02/05/2012*/
      /* Fin FBL. 25/06/2014 MSV Bug 0028974*/
      INSERT INTO estgarandetcap
                  (sseguro, nriesgo, cgarant, nmovimi, norden, cconcepto,
                   tdescrip, icapital)
         (SELECT aux_ssegpol, nriesgo, cgarant, v_nmovimi_new, norden,
                 cconcepto, tdescrip, icapital
            FROM garandetcap
           WHERE sseguro =
                    psseguro
                          /* JLB -- I - COGE LOS DATOS DEL ULTIMO MOVIMIENTO*/
             AND nmovimi IN (SELECT MAX (nmovimi)
                               FROM garandetcap
                              WHERE sseguro = psseguro)
                          /* JLB -- F - COGE LOS DATOS DEL ULTIMO MOVIMIENTO*/
                                                       );

      paso := 22;

      /* BUG11305:DRA:30/09/2009:Inici*/
      /* Bug 11735 - RSC - 20/01/2010 - APR - suplemento de modificación de capital /prima*/
      INSERT INTO estdetgaranseg
                  (cgarant, nriesgo, nmovimi, sseguro, finiefe, ndetgar,
                   fefecto, fvencim, ndurcob, ctarifa, pinttec, ftarifa,
                   crevali, prevali, irevali, icapital, iprianu, precarg,
                   irecarg, cparben, cprepost, ffincob, ipritar, provmat0,
                   fprovmat0, provmat1, fprovmat1, pintmin, pdtocom, idtocom,
                   ctarman, ipripur, ipriinv, itarrea, cagente, cunica)
         (SELECT d.cgarant, d.nriesgo, v_nmovimi_new, aux_ssegpol,
                 NVL (pfecha, d.finiefe), d.ndetgar, d.fefecto, d.fvencim,
                 d.ndurcob, d.ctarifa, d.pinttec, d.ftarifa, d.crevali,
                 d.prevali, d.irevali, d.icapital, d.iprianu, d.precarg,
                 d.irecarg, d.cparben, d.cprepost, d.ffincob, d.ipritar,
                 d.provmat0, d.fprovmat0, d.provmat1, d.fprovmat1, d.pintmin,
                 d.pdtocom, d.idtocom, d.ctarman, d.ipripur, d.ipriinv,
                 d.itarrea, d.cagente, d.cunica  /*DECODE(d.cunica, 1, 1, 2)*/
            FROM detgaranseg d, garanseg g                      /* Bug 11735*/
           WHERE d.sseguro = psseguro
             AND d.sseguro = g.sseguro                          /* Bug 11735*/
             AND d.nriesgo = g.nriesgo                          /* Bug 11735*/
             AND d.cgarant = g.cgarant                          /* Bug 11735*/
             AND d.nmovimi = g.nmovimi                          /* Bug 11735*/
             AND g.ffinefe IS NULL);

      /* Bug 11735 - RSC - 20/01/2010 - APR - suplemento de modificación de capital /prima*/
      /*AND d.nmovimi = (SELECT MAX(d2.nmovimi)*/
      /*                   FROM detgaranseg d2*/
      /*                  WHERE d2.sseguro = psseguro*/
      /*                    AND d2.nriesgo = d.nriesgo));*/
      /* Fin Bug 11735*/
      paso := 23;

      /* BUG11305:DRA:30/09/2009:Fi*/
      INSERT INTO estpregungaranseg
                  (sseguro, nriesgo, cgarant, cpregun, crespue, nmovimi,
                   nmovima, finiefe, trespue)
         (SELECT aux_ssegpol, a.nriesgo, a.cgarant, a.cpregun, a.crespue,
                 v_nmovimi_new, a.nmovima, NVL (pfecha, a.finiefe), a.trespue
            FROM pregungaranseg a
           WHERE a.sseguro = psseguro
             AND a.nmovimi =
                       (SELECT MAX (b.nmovimi)
                          FROM pregungaranseg b
                         WHERE b.sseguro = psseguro AND b.nriesgo = a.nriesgo));

      INSERT INTO estpregungaransegtab
                  (sseguro, nriesgo, cgarant, cpregun, nmovimi, nmovima,
                   finiefe, nlinea, ccolumna, tvalor, fvalor, nvalor)
         (SELECT aux_ssegpol, a.nriesgo, a.cgarant, a.cpregun, v_nmovimi_new,
                 a.nmovima, NVL (pfecha, a.finiefe), nlinea, ccolumna, tvalor,
                 fvalor, nvalor
            FROM pregungaransegtab a
           WHERE a.sseguro = psseguro
             AND a.nmovimi =
                       (SELECT MAX (b.nmovimi)
                          FROM pregungaransegtab b
                         WHERE b.sseguro = psseguro AND b.nriesgo = a.nriesgo));

      paso := 24;

      /* Bug 30642/169851 - 20/03/2014 - AMC*/
      /* Bug 32595/182627 - 01/09/2014 - AMC*/
      INSERT INTO estcomisionsegu
                  (sseguro, cmodcom, pcomisi, ninialt, nfinalt, nmovimi)
         (SELECT aux_ssegpol, cmodcom, pcomisi, ninialt, nfinalt,
                 v_nmovimi_new
            FROM comisionsegu
           WHERE sseguro = psseguro AND nmovimi =
                                                 (SELECT MAX (b.nmovimi)
                                                    FROM comisionsegu b
                                                   WHERE b.sseguro = psseguro));

      paso := 25;

      /* INI BUG 34461, 34462 - Productos de CONVENIOS*/
      INSERT INTO estcnv_conv_emp_seg
                  (sseguro, nmovimi, idversion)
         (SELECT aux_ssegpol, v_nmovimi_new, idversion
            FROM cnv_conv_emp_seg
           WHERE sseguro = psseguro AND nmovimi IN (SELECT MAX (nmovimi)
                                                      FROM cnv_conv_emp_seg
                                                     WHERE sseguro = psseguro));

      /* FIN BUG 34461, 34462 - Productos de CONVENIOS*/
      /* 23184 AVT 06/11/2012 s'afegeix la companyia i la pòlissa*/
      INSERT INTO estcoacuadro
                  (sseguro, ncuacoa, finicoa, ffincoa, ploccoa, fcuacoa,
                   ccompan, npoliza, nendoso)
         (SELECT aux_ssegpol, v_nmovimi_new, finicoa, ffincoa, ploccoa,
                 fcuacoa, ccompan, npoliza,
                 nendoso                    --INC 1364 FACO CONFIANZA 29112017
            FROM coacuadro
           WHERE sseguro =
                    psseguro
/* Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran*/
             AND ncuacoa IN (SELECT MAX (ncuacoa)
                               FROM coacuadro
                              WHERE sseguro = psseguro));

      /* Bug INI: 35095/199894 - 06/03/2015 - PRB*/
      INSERT INTO estasegurados_innom e
                  (e.sseguro, e.nmovimi, e.nriesgo, e.norden, e.nif, e.nombre,
                   e.apellidos, e.csexo, e.fnacim, e.falta, e.fbaja)
         (SELECT aux_ssegpol, v_nmovimi_new, i.nriesgo, i.norden, i.nif,
                 i.nombre, i.apellidos, i.csexo, i.fnacim, i.falta, i.fbaja
            FROM asegurados_innom i
           WHERE i.sseguro = psseguro
             AND i.nmovimi IN (SELECT MAX (a.nmovimi)
                                 FROM asegurados_innom a
                                WHERE a.sseguro = psseguro));

      /* Bug INI: 35095/199894 - 06/03/2015 - PRB*/
      /* Fin Bug 0023183*/
      paso := 26;

      INSERT INTO estcoacedido
                  (sseguro, ncuacoa, ccompan, pcescoa, pcomcoa, pcomcon,
                   pcomgas, pcesion)
         (SELECT aux_ssegpol, v_nmovimi_new, ccompan, pcescoa, pcomcoa,
                 pcomcon, pcomgas, pcesion
            FROM coacedido
           WHERE sseguro =
                    psseguro
/* Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran*/
             AND ncuacoa IN (SELECT MAX (ncuacoa)
                               FROM coacuadro
                              WHERE sseguro = psseguro));

      paso := 27;

      /* Clausulas de tipo 1*/
      INSERT INTO estclaubenseg
                  (nmovimi, sclaben, sseguro, nriesgo, finiclau, ffinclau)
         (SELECT v_nmovimi_new, sclaben, aux_ssegpol, nriesgo,
                 NVL (pfecha, finiclau), ffinclau
            FROM claubenseg
           WHERE sseguro = psseguro AND ffinclau IS NULL);

      /*             AND nmovimi =
                                             (SELECT MAX (nmovimi)
      FROM (SELECT b.nmovimi
              FROM claubenseg b
             WHERE b.sseguro = psseguro
        --AND b.nriesgo = a.nriesgo
       AND b.ffinclau IS NULL
            UNION
            SELECT c.nmovimi
              FROM clausuesp c
             WHERE c.sseguro = psseguro
        --AND c.nriesgo = a.nriesgo
        AND c.cclaesp = 1
       AND c.ffinclau IS NULL))); */
      paso := 28;

      INSERT INTO estclausuesp
                  (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau,
                   sclagen, tclaesp, ffinclau)
         (SELECT v_nmovimi_new, aux_ssegpol, cclaesp, nordcla, nriesgo,
                 NVL (pfecha, finiclau), sclagen, tclaesp, ffinclau
            FROM clausuesp
           WHERE sseguro = psseguro AND cclaesp = 1 AND ffinclau IS NULL);

      /*Bug.: 19152 - 20/10/2011 - ICV*/
      paso := 281;

      /* Bug 24717 - MDS - 20/12/2012 : Añadir campo cestado*/
      INSERT INTO estbenespseg
                  (sseguro, nriesgo, cgarant, nmovimi, sperson, sperson_tit,
                   finiben, ffinben, ctipben, cparen, pparticip, cestado,
                   ctipocon)
         (SELECT aux_ssegpol, nriesgo, cgarant, v_nmovimi_new,
                 pac_persona.f_spereal_sperson (sperson, aux_ssegpol),
                 NVL (pac_persona.f_spereal_sperson (sperson_tit, aux_ssegpol),
                      0
                     ),
                 NVL (pfecha, finiben), ffinben, ctipben, cparen, pparticip,
                 cestado, ctipocon
            FROM benespseg a
           WHERE sseguro = psseguro
             AND ffinben IS NULL
             AND a.nmovimi =
                       (SELECT MAX (b.nmovimi)
                          FROM benespseg b
                         WHERE b.sseguro = psseguro AND b.nriesgo = a.nriesgo));

      /*             AND nmovimi =
                                             (SELECT MAX (nmovimi)
      FROM (SELECT nmovimi
              FROM claubenseg
             WHERE sseguro = psseguro
            UNION
            SELECT nmovimi
              FROM clausuesp
             WHERE sseguro = psseguro AND cclaesp = 1)));*/
      paso := 29;

      /*demas tipos de clausulas*/
      INSERT INTO estclausuesp
                  (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau,
                   sclagen, tclaesp, ffinclau)
         (SELECT v_nmovimi_new, aux_ssegpol, cclaesp, nordcla, nriesgo,
                 NVL (pfecha, finiclau), sclagen, tclaesp, ffinclau
            FROM clausuesp
           WHERE sseguro = psseguro AND cclaesp <> 1 AND ffinclau IS NULL);

      /*             AND nmovimi = (SELECT MAX (nmovimi)
                                                 FROM clausuesp
      WHERE sseguro = psseguro AND cclaesp <> 1));*/
      paso := 30;

      -- CONF-274-25/11/2016-JLTS- inclusión del max
      INSERT INTO estclaususeg
                  (sseguro, sclagen, nmovimi, finiclau, ffinclau, nordcla)
         (SELECT aux_ssegpol, sclagen, v_nmovimi_new, NVL (pfecha, finiclau),
                 ffinclau, nordcla
            FROM claususeg c
           WHERE sseguro = psseguro
             AND ffinclau IS NULL
             AND c.nmovimi =
                    (SELECT MAX (c1.nmovimi)
                       FROM claususeg c1
                      WHERE c1.sseguro = c.sseguro
                        AND c1.sclagen = c.sclagen
                        AND c.nordcla = c.nordcla));

      -- CONF-274-25/11/2016-JLTS- Fin

      /* Bug 16726 - RSC - 13/01/2010 - APR - clauses definition*/
      INSERT INTO estclausubloq
                  (sseguro, nmovimi, nriesgo, sclagen)
         (SELECT aux_ssegpol, v_nmovimi_new, nriesgo, sclagen
            FROM clausubloq
           WHERE sseguro = psseguro);

      /* Fin Bug 16726*/
      paso := 301;

      /* BUG16410:JBN 17/11/2010: Insertem els paramatres de las clausulas*/
      INSERT INTO estclauparaseg
                  (sclagen, sseguro, nriesgo, nmovimi, nparame, tparame,
                   nordcla)
         (SELECT sclagen, aux_ssegpol, nriesgo, v_nmovimi_new, nparame,
                 tparame, nordcla
            FROM clauparaseg
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM clauparaseg
                                                    WHERE sseguro = psseguro));

      paso := 31;

      INSERT INTO estclauparseg
                  (sseguro, sclagen, nparame, tvalor, ctippar)
         (SELECT aux_ssegpol, sclagen, nparame, tvalor, ctippar
            FROM clauparseg
           WHERE sseguro = psseguro);

      paso := 321;

      INSERT INTO estclauparesp
                  (sseguro, nriesgo, nmovimi, sclagen, nparame, cclaesp,
                   nordcla, tvalor, ctippar)
         (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, sclagen, nparame,
                 cclaesp, nordcla, tvalor, ctippar
            FROM clauparesp
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM clauparesp
                                                    WHERE sseguro = psseguro));

      paso := 322;

      /* BUG11288:DRA:20/10/2009:Inici*/
      INSERT INTO estmotretencion
                  (sseguro, nriesgo, nmovimi, cmotret, cusuret, freten,
                   nmotret)
         (SELECT aux_ssegpol, nriesgo, nmovimi, cmotret, cusuret, freten,
                 nmotret
            FROM motretencion
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM movseguro
                                                    WHERE sseguro = psseguro));

      paso := 323;

      INSERT INTO estmotreten_rev
                  (sseguro, nriesgo, nmovimi, cmotret, nmotret, nmotrev,
                   cusuauto, fusuauto, cresulta, tobserva)
         (SELECT aux_ssegpol, nriesgo, nmovimi, cmotret, nmotret, nmotrev,
                 cusuauto, fusuauto, cresulta, tobserva
            FROM motreten_rev
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM movseguro
                                                    WHERE sseguro = psseguro));

      /* BUG11288:DRA:20/10/2009:Fi*/
      paso := 33;

      INSERT INTO estexclugarseg
                  (sseguro, nriesgo, cgarant, nmovima, nmovimb)
         (SELECT aux_ssegpol, nriesgo, cgarant, nmovima, nmovimb
            FROM exclugarseg
           WHERE sseguro = psseguro);

      paso := 34;

      /*modificació XCG 05-01-2007 afegir el cam seguros_aho i est_seguros_aho*/
      INSERT INTO estseguros_aho
                  (sseguro, pinttec, pintpac, fsusapo, ndurper, frevisio,
                   ndurrev, pintrev, frevant, cfprest)
         (SELECT aux_ssegpol, pinttec, pintpac, fsusapo, ndurper, frevisio,
                 ndurrev, pintrev, frevant, cfprest
            FROM seguros_aho e
           WHERE e.sseguro = psseguro);

      paso := 35;

      /*-------------------------- RSC 16-07-2007 ---------------------------------*/
      INSERT INTO estseguros_ulk
                  (sseguro, psalmin, isalcue, cseghos, cmodinv, cgasges,
                   cgasred)
         (SELECT aux_ssegpol, e.psalmin, e.isalcue, e.cseghos, e.cmodinv,
                 e.cgasges, e.cgasred
            FROM seguros_ulk e
           WHERE e.sseguro = psseguro);

      paso := 36;

      INSERT INTO estsegdisin2
                  (sseguro, nriesgo, nmovimi, finicio, ffin, ccesta, pdistrec,
                   pdistuni, pdistext)
         (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, NVL (pfecha, finicio),
                 ffin, ccesta, pdistrec, pdistuni, pdistext
            FROM segdisin2
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM segdisin2
                                                    WHERE sseguro = psseguro));

      paso := 37;

/*-------------------------------------------------------------------------------------*/
/*JRH  Rentas 09/2007*/
      INSERT INTO estseguros_ren
                  (sseguro, f1paren, fuparen, cforpag, ibruren, ffinren,
                   cmotivo, cmodali, fppren, ibrure2, fintgar, cestmre,
                   cblopag, nduraint, ptipoint, pdoscab, icapren, pcapfall,
                   ireserva, frevant, pcaprev, nmesextra,
                   imesextra /* NMM.24735.03.2013.*/)
         SELECT aux_ssegpol, f1paren, fuparen, cforpag, ibruren, ffinren,
                cmotivo, cmodali, fppren, ibrure2, fintgar, cestmre, cblopag,
                nduraint, ptipoint, pdoscab, icapren, pcapfall, ireserva,
                frevant, pcaprev, nmesextra, imesextra /* NMM.24735.03.2013.*/
           FROM seguros_ren
          WHERE sseguro = psseguro;

      /*INSERT INTO ESTSEGUROS_ACT
                                                        (    sseguro, cactivo, iadqact,tcodact)
      SELECT aux_ssegpol,cactivo, iadqact,tcodact
        FROM SEGUROS_ACT
        WHERE sseguro = psseguro;*/
      paso := 38;

      INSERT INTO estseguros_act
                  (sseguro, sactivo)
         SELECT aux_ssegpol, sactivo
           FROM seguros_act
          WHERE sseguro = psseguro;

      paso := 39;

      /*JRH*/
      INSERT INTO estpenaliseg
                  (sseguro, nmovimi, ctipmov, niniran, nfinran, ipenali,
                   ppenali, clave)
         (SELECT aux_ssegpol, v_nmovimi_new, e.ctipmov, e.niniran, e.nfinran,
                 e.ipenali, e.ppenali, e.clave
            FROM penaliseg e
           WHERE e.sseguro = psseguro
             AND e.nmovimi = (SELECT MAX (nmovimi)
                                FROM penaliseg
                               WHERE sseguro = psseguro));

      /* Mantis 10240.06/2009.NMM.*/
      /*INSERT INTO estplanrentasextra
                                                         (sseguro, nriesgo, nmovimi, fpago, ipago, cestado, srecren)
      (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, fpago, ipago, cestado, srecren
         FROM planrentasextra
        WHERE sseguro = psseguro
          AND nmovimi = (SELECT MAX(nmovimi)
                           FROM planrentasextra
                          WHERE sseguro = psseguro));*/
      /* Bug 11165 - 16/09/2009 - AMC - Se sustituñe  estdetsaldodeutorseg por estprestamoseg*/
      /*INSERT INTO estprestamoseg
                                                         (ctapres, sseguro, nmovimi, finiprest, ffinprest, pporcen)
      (SELECT ctapres, aux_ssegpol, v_nmovimi_new, NVL(pfecha, finiprest), ffinprest,
              pporcen
         FROM prestamoseg
        WHERE sseguro = psseguro
          AND ffinprest IS NULL);*/
      paso := 40;

      /* Ini Bug 0025955 --ECP -- 01/02/2013*/
      IF NVL (pac_parametros.f_parproducto_n (vsproduc, 'PERMITE_PREST'), 0) <>
                                                                             1
      THEN
         /* Bug 11301 - APD - 22/10/2009 - se añade la columna FALTA en el insert*/
         INSERT INTO estprestcuadroseg
                     (ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg,
                      fefecto, fvencim, icapital, iinteres, icappend, falta)
            (SELECT ctapres, aux_ssegpol, v_nmovimi_new,
                    NVL (pfecha, finicuaseg), ffincuaseg, fefecto, fvencim,
                    icapital, iinteres, icappend, falta
               FROM prestcuadroseg
              WHERE sseguro = psseguro
                AND nmovimi = (SELECT MAX (nmovimi)
                                 FROM prestcuadroseg
                                WHERE sseguro = psseguro));
      END IF;

      /* Fin Bug 0025955 --ECP -- 01/02/2013*/
      paso := 41;

      /* JDC 06/08/02*/
      INSERT INTO estresulseg
                  (clave, sseguro, nriesgo, nmovimi, cgarant, finiefe,
                   nresult)
         (SELECT clave, aux_ssegpol, nriesgo, v_nmovimi_new, cgarant,
                 NVL (pfecha, finiefe), nresult
            FROM resulseg
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM resulseg
                                                    WHERE sseguro = psseguro));

      paso := 42;

      /* Bug 17221 - APD - 10/01/2011 - se añade el volcado a las tablas estreglasseg y estreglassegtramos*/
      INSERT INTO estreglasseg
                  (sseguro, nriesgo, cgarant, nmovimi, capmaxemp, capminemp,
                   capmaxtra, capmintra)
         (SELECT aux_ssegpol, nriesgo, cgarant, v_nmovimi_new, capmaxemp,
                 capminemp, capmaxtra, capmintra
            FROM reglasseg
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM reglasseg
                                                    WHERE sseguro = psseguro));

      paso := 43;

      INSERT INTO estreglassegtramos
                  (sseguro, nriesgo, cgarant, nmovimi, edadini, edadfin,
                   t1copagemp, t1copagtra, t2copagemp, t2copagtra, t3copagemp,
                   t3copagtra, t4copagemp, t4copagtra)
         (SELECT aux_ssegpol, nriesgo, cgarant, v_nmovimi_new, edadini,
                 edadfin, t1copagemp, t1copagtra, t2copagemp, t2copagtra,
                 t3copagemp, t3copagtra, t4copagemp, t4copagtra
            FROM reglassegtramos
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM reglassegtramos
                                                    WHERE sseguro = psseguro));

      /* Fin Bug 17221 - APD - 10/01/2011*/
      paso := 44;

      /* **** Traspàs de taules dinàmiques i/o estàtiques ***** (sls)*/
      INSERT INTO tbestuserfilas
                  (sseguro, nriesgo, nmovimi, stabla, nuserfila)
         (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, stabla, nuserfila
            FROM tbseguserfilas
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM tbseguserfilas
                                                    WHERE sseguro = psseguro));

      paso := 45;

      INSERT INTO tbestdettabla
                  (sseguro, nriesgo, nmovimi, stabla, nuserfila, cvalor,
                   nvalor, tvalor, dvalor)
         (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, stabla, nuserfila,
                 cvalor, nvalor, tvalor, dvalor
            FROM tbsegdettabla
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM tbsegdettabla
                                                    WHERE sseguro = psseguro));

      paso := 46;

      INSERT INTO tbestfilastabla
                  (sseguro, nriesgo, nmovimi, stabla, nfila, tvalor)
         (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, stabla, nfila, tvalor
            FROM tbsegfilastabla
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM tbsegfilastabla
                                                    WHERE sseguro = psseguro));

      paso := 47;

      /* Fi JDC*/
      /***************** Inici de traspas de taules de OCS *************/
      BEGIN
         SELECT COUNT (*)
           INTO cc
           FROM garansegcom
          WHERE sseguro = psseguro;
      END;

      paso := 48;

      IF cc > 0
      THEN
         /* FBL. 25/06/2014 MSV Bug 0028974*/
         /* INSERT INTO estgaransegcom
                  (sseguro, nriesgo, cgarant, nmovimi, finiefe, cmodcom, pcomisi, ninialt,
                   nfinalt, pcomisicua, ipricom, cageven)
         (SELECT aux_ssegpol, g.nriesgo, cgarant, v_nmovimi_new, NVL(pfecha, finiefe),
                 cmodcom, pcomisi, ninialt, nfinalt, pcomisicua, ipricom, cageven
            FROM garansegcom g, seguros s
           WHERE s.sseguro = psseguro
             AND g.sseguro = s.sseguro
             AND(s.ctipcom = 91
                 OR NVL(pac_parametros.f_parproducto_n(s.sproduc, 'AFECTA_COMISESPPROD'), 1) =
                                                                                           1)
             AND g.nmovimi = (SELECT DISTINCT nmovimi
                                         FROM garanseg
                                        WHERE sseguro = psseguro
                                           AND ffinefe IS NULL));*/
         FOR ii IN
            (SELECT s.cempres, aux_ssegpol sseguro, g.nriesgo, cgarant,
                    v_nmovimi_new nmovimi, NVL (pfecha, finiefe) finiefe,
                    cmodcom, pcomisi, ninialt, nfinalt, pcomisicua, ipricom,
                    cageven
               FROM garansegcom g, seguros s
              WHERE s.sseguro = psseguro
                AND g.sseguro = s.sseguro
                AND (   s.ctipcom = 91
                     OR NVL
                           (pac_parametros.f_parproducto_n
                                                        (s.sproduc,
                                                         'AFECTA_COMISESPPROD'
                                                        ),
                            1
                           ) = 1
                    )
                AND g.nmovimi =
                               (SELECT DISTINCT nmovimi
                                           FROM garanseg
                                          WHERE sseguro = psseguro
                                            AND ffinefe IS NULL))
         LOOP
            num_err :=
               pac_comisiones.f_grabarcomisionmovimiento
                                                    (p_cempres       => ii.cempres,
                                                     p_sseguro       => ii.sseguro,
                                                     p_cgarant       => ii.cgarant,
                                                     p_nriesgo       => ii.nriesgo,
                                                     p_nmovimi       => ii.nmovimi,
                                                     p_fecha         => ii.finiefe,
                                                     p_modo          => NULL,
                                                     p_ipricom       => ii.ipricom,
                                                     p_cmodcom       => ii.cmodcom,
                                                     p_sproces       => NULL,
                                                     p_mensajes      => v_mensajes
                                                    );

            IF num_err <> 0
            THEN
               RAISE salida;
            END IF;
         END LOOP;
      /* Fin FBL. 25/06/2014 MSV Bug 0028974*/
      END IF;

      /* Bug 21121 - APD - 21/02/2012 - se incluye la tabla estdetprimas*/
      BEGIN
         SELECT COUNT (*)
           INTO cc
           FROM detprimas
          WHERE sseguro = psseguro;
      END;

      paso := 48;

      IF cc > 0
      THEN
         INSERT INTO estdetprimas
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, ccampo,
                      cconcep, norden, iconcep, iconcep2)
            (SELECT aux_ssegpol, nriesgo, cgarant, v_nmovimi_new,
                    NVL (pfecha, finiefe), ccampo, cconcep, norden, iconcep,
                    iconcep2
               FROM detprimas
              WHERE sseguro = psseguro
                AND nmovimi = (SELECT DISTINCT nmovimi
                                          FROM garanseg
                                         WHERE sseguro = psseguro
                                           AND ffinefe IS NULL));
      END IF;

      /* fin Bug 21121 - APD - 21/02/2012*/
      paso := 49;

      BEGIN
         SELECT COUNT (*)
           INTO cg
           FROM garanseggas
          WHERE sseguro = psseguro;
      END;

      paso := 50;

      IF cg > 0
      THEN
         INSERT INTO estgaranseggas
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, cgastos,
                      pvalor, pvalres, nprima)
            (SELECT aux_ssegpol, nriesgo, cgarant, v_nmovimi_new,
                    NVL (pfecha, finiefe), cgastos, pvalor, pvalres, nprima
               FROM garanseggas
              WHERE sseguro = psseguro
                AND nmovimi = (SELECT nmovimi
                                 FROM garanseg
                                WHERE sseguro = psseguro AND ffinefe IS NULL));
      END IF;

      paso := 51;

      BEGIN
         SELECT COUNT (*)
           INTO cs
           FROM garanseg_sbpri
          WHERE sseguro = psseguro;
      END;

      paso := 52;

      IF cs > 0
      THEN
         INSERT INTO estgaranseg_sbpri
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, norden,
                      ctipsbr, ccalsbr, pvalor, ncomisi)
            (SELECT aux_ssegpol, nriesgo, cgarant, v_nmovimi_new,
                    NVL (pfecha, finiefe), norden, ctipsbr, ccalsbr, pvalor,
                    ncomisi
               FROM garanseg_sbpri
              WHERE sseguro = psseguro
                AND nmovimi = (SELECT nmovimi
                                 FROM garanseg
                                WHERE sseguro = psseguro AND ffinefe IS NULL));
      END IF;

      paso := 53;

      /*JRH  Rentas Irregulares 03/2008*/
      INSERT INTO estplanrentasirreg
                  (sseguro, nriesgo, nmovimi, mes, anyo, importe)
         SELECT aux_ssegpol, pi.nriesgo, v_nmovimi_new, pi.mes, pi.anyo,
                pi.importe
           FROM planrentasirreg pi
          WHERE pi.sseguro = psseguro
            AND pi.nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM planrentasirreg pi2
                     WHERE pi2.sseguro = pi.sseguro
                       AND pi2.nriesgo = pi.nriesgo);

      paso := 54;

      /*JTS 17/12/2008 APRA 8467*/
      /* Bug 10656 - 07/07/2009 - RSC - Error en suplemento de cambio de cuenta*/
      INSERT INTO estseg_cbancar
                  (sseguro, nmovimi, finiefe, cbancar, cbancob)
         (SELECT aux_ssegpol, v_nmovimi_new, NVL (pfecha, c.finiefe),
                 c.cbancar, c.cbancob
            FROM seg_cbancar c
           WHERE c.sseguro = psseguro
             AND c.nmovimi = (SELECT MAX (cc.nmovimi)
                                FROM seg_cbancar cc
                               WHERE cc.sseguro = c.sseguro));

      /* Fin Bug 10656*/
      /* BUG 18351 - 10/05/2011 - JMP - Tratamiento de las tablas de documentación requerida*/
      paso := 55;

      IF v_nmovimi = v_nmovimi_new
      THEN
         /* Gestion de propuestas retenidas*/
         INSERT INTO estdocrequerida
                     (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                      cclase, sseguro, nmovimi, tfilename, tdescrip,
                      adjuntado, iddocgedox)
            (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                    cclase, aux_ssegpol, v_nmovimi_new, tfilename, tdescrip,
                    adjuntado, iddocgedox
               FROM docrequerida
              WHERE sseguro = psseguro
                AND nmovimi = (SELECT MAX (nmovimi)
                                 FROM docrequerida
                                WHERE sseguro = psseguro));

         paso := 56;

         INSERT INTO estdocrequerida_riesgo
                     (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                      cclase, sseguro, nmovimi, nriesgo, tfilename, tdescrip,
                      adjuntado, iddocgedox)
            (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                    cclase, aux_ssegpol, v_nmovimi_new, nriesgo, tfilename,
                    tdescrip, adjuntado, iddocgedox
               FROM docrequerida_riesgo
              WHERE sseguro = psseguro
                    AND nmovimi = (SELECT MAX (nmovimi)
                                     FROM docrequerida_riesgo
                                    WHERE sseguro = psseguro));

         paso := 57;

         INSERT INTO estdocrequerida_inqaval
                     (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                      cclase, sseguro, nmovimi, ninqaval, tfilename, tdescrip,
                      adjuntado, iddocgedox, sperson)
            (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                    cclase, aux_ssegpol, v_nmovimi_new, ninqaval, tfilename,
                    tdescrip, adjuntado, iddocgedox,
                    pac_persona.f_spereal_sperson (sperson, aux_ssegpol)
               FROM docrequerida_inqaval
              WHERE sseguro = psseguro
                AND nmovimi = (SELECT MAX (nmovimi)
                                 FROM docrequerida_inqaval
                                WHERE sseguro = psseguro));

         /*Inici BUG 027304 - 24/07/2013 - RCL - No traspasa la docu requerida de tipus _benespseg*/
         INSERT INTO estdocrequerida_benespseg
                     (seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                      cclase, sseguro, nmovimi, nriesgo, tfilename, tdescrip,
                      adjuntado, iddocgedox, sperson, ctipben)
            (SELECT seqdocu, cdocume, sproduc, cactivi, norden, ctipdoc,
                    cclase, aux_ssegpol, v_nmovimi_new, nriesgo, tfilename,
                    tdescrip, adjuntado, iddocgedox,
                    pac_persona.f_spereal_sperson (sperson, aux_ssegpol),
                    ctipben
               FROM docrequerida_benespseg
              WHERE sseguro = psseguro
                AND nmovimi = (SELECT MAX (nmovimi)
                                 FROM docrequerida_benespseg
                                WHERE sseguro = psseguro));
      /*Fi BUG 027304 - 24/07/2013 - RCL - No traspasa la docu requerida de tipus _benespseg*/
      END IF;

      /* FIN BUG 18351 - 10/05/2011 - JMP*/
      paso := 58;

      /* Ini bug 19276, jbn, 19276*/
      /*LECG 15/11/2012 BUG: 24714 - Inserta el ctipo*/
      INSERT INTO estreemplazos
                  (sseguro, sreempl, fmovdia, cusuario, cagente, ctipo)
         (SELECT sseguro, sreempl, fmovdia, cusuario, cagente, ctipo
            FROM reemplazos
           WHERE sseguro = psseguro);

      paso := 59;

      /* Bug 27539/149064 - APD - 23/07/2013 - el max(nmovimi) para traspasar a las*/
      /* tablas EST debe ser de la tabla PREGUNPOLSEG ya que el co-corretaje*/
      /* depende de una pregunta*/
      INSERT INTO estage_corretaje
                  (sseguro, cagente, nmovimi, nordage, pcomisi, ppartici,
                   islider)
         (SELECT aux_ssegpol, crt.cagente, v_nmovimi_new, crt.nordage,
                 crt.pcomisi, crt.ppartici, crt.islider
            FROM age_corretaje crt
           WHERE crt.sseguro = psseguro
             AND crt.nmovimi = (SELECT MAX (p.nmovimi)
                                  FROM pregunpolseg p
                                 WHERE p.sseguro = crt.sseguro));

      /*
      AND crt.nmovimi = (SELECT MAX(crt1.nmovimi)
                           FROM age_corretaje crt1
                          WHERE crt1.sseguro = psseguro));*/
      /* fin Bug 27539/149064 - APD - 23/07/2013*/
      paso := 60;

      /* BUG 0021592 - 08/03/2012 - JMF*/
      INSERT INTO estgescobros
                  (sseguro, sperson, cdomici, cusualt, falta, cusuari,
                   fmovimi)
         SELECT aux_ssegpol sseguro,
                pac_persona.f_spereal_sperson (sperson, aux_ssegpol) sperson,
                cdomici, cusualt, falta, cusuari, fmovimi
           FROM gescobros
          WHERE sseguro = psseguro;

      /*bug 21657--ETM--04/06/2012*/
      paso := 61;

      INSERT INTO estinquiaval
                  (sseguro, sperson, nriesgo, nmovimi, ctipfig, cdomici,
                   iingrmen, iingranual, ffecini, ffecfin, ctipcontrato,
                   csitlaboral, csupfiltro)
         (SELECT aux_ssegpol sseguro,
                 pac_persona.f_spereal_sperson (sperson, aux_ssegpol),
                 nriesgo, v_nmovimi_new, ctipfig, cdomici, iingrmen,
                 iingranual, ffecini, ffecfin, ctipcontrato, csitlaboral,
                 csupfiltro
            FROM inquiaval
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM inquiaval
                                                    WHERE sseguro = psseguro));

      /*ul mov ?????*/
      /*fin bug 21657--etm---04/06/2012*/
      /* BUG 0022701 - 03/09/2012 - JMF*/
      /* BUG 0023965 - 15/10/2012 - JMF*/
      paso := 62;

      /* Bug 27539/149064 - APD - 23/07/2013 - el max(nmovimi) para traspasar a las*/
      /* tablas EST debe ser de la tabla PREGUNPOLSEG ya que el retorno*/
      /* depende de una pregunta*/
      INSERT INTO estrtn_convenio
                  (sseguro, sperson, nmovimi, pretorno, idconvenio)
         (SELECT aux_ssegpol,
                 pac_persona.f_spereal_sperson (sperson, aux_ssegpol) sperson,
                 v_nmovimi_new, pretorno, idconvenio
            FROM rtn_convenio r
           WHERE r.sseguro = psseguro
             AND r.nmovimi = (SELECT MAX (p.nmovimi)
                                FROM pregunpolseg p
                               WHERE p.sseguro = r.sseguro));

      /*
      AND nmovimi = (SELECT MAX(nmovimi)
                       FROM rtn_convenio
                      WHERE sseguro = psseguro));*/
      /* fin Bug 27539/149064 - APD - 23/07/2013*/
      /* Bug 28263/153355 - 01/10/2013 - AMC*/
      paso := 63;

      SELECT MAX (nmovimi)
        INTO vnmovimi_bpm
        FROM casos_bpmseg
       WHERE sseguro = psseguro;

      IF vnmovimi_bpm = v_nmovimi_new
      THEN
         INSERT INTO estcasos_bpmseg
                     (sseguro, cempres, nnumcaso, cactivo)
            (SELECT aux_ssegpol, cempres, nnumcaso, cactivo
               FROM casos_bpmseg
              WHERE sseguro = psseguro
                AND nmovimi = (SELECT MAX (nmovimi)
                                 FROM casos_bpmseg
                                WHERE sseguro = psseguro));
      END IF;

      /* Bug 34675/198727 - 24/02/2015 - AMC*/
      paso := 65;

      INSERT INTO estvalidacargapregtab
                  (cpregun, sseguro, nmovimi, nriesgo, cgarant, norden,
                   sproces, cvalida, cusuari, fecha)
         (SELECT cpregun, aux_ssegpol, nmovimi, nriesgo, cgarant, norden,
                 sproces, cvalida, cusuari, fecha
            FROM validacargapregtab
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM validacargapregtab
                                                    WHERE sseguro = psseguro));

      paso := 66;

      /* 36596/211327 IGIL INI*/
      INSERT INTO estcitamedica_undw
                  (sseguro, nriesgo, nmovimi, speraseg, spermed, ceviden,
                   norden, feviden, cpago, ieviden, cestado, cais)
         (SELECT aux_ssegpol, nriesgo, v_nmovimi_new, speraseg, spermed,
                 ceviden, norden, feviden, cpago, ieviden, cestado, cais
            FROM citamedica_undw
           WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                     FROM citamedica_undw
                                                    WHERE sseguro = psseguro));

      /* 36596/211327 IGIL FIN*/
      -- INI BUG 40927/228750 - 07/03/2016 - JAEG
      INSERT INTO estper_contragarantia
                  (scontgar, sperson)
         (SELECT p.scontgar,
                 pac_persona.f_spereal_sperson (p.sperson, aux_ssegpol)
            FROM per_contragarantia p, ctgar_seguro cs
           WHERE cs.sseguro = psseguro
             AND p.scontgar = cs.scontgar
             AND cs.nmovimi = (SELECT MAX (nmovimi)
                                 FROM ctgar_contragarantia
                                WHERE scontgar = cs.scontgar));

      --
      INSERT INTO estctgar_seguro
                  (scontgar, sseguro, nmovimi)
         (SELECT cs.scontgar, aux_ssegpol, cs.nmovimi
            FROM ctgar_seguro cs
           WHERE cs.sseguro = psseguro
             AND cs.nmovimi = (SELECT MAX (nmovimi)
                                 FROM ctgar_contragarantia
                                WHERE scontgar = cs.scontgar));
   -- FIN BUG 40927/228750 - 07/03/2016 - JAEG
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         mens := SQLERRM;
         p_tab_error
                    (f_sysdate,
                     f_user,
                     'PAC_ALCTR126',
                     paso,
                     'traspaso_tablas_seguros.Error traspaso tablas seguro.',
                     SQLERRM
                    );
   END traspaso_tablas_seguros;

   FUNCTION f_borrar_tabla_estresulseg (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      BEGIN
         DELETE FROM estresulseg
               WHERE sseguro = psseguro
                 AND nriesgo = pnriesgo
                 AND nmovimi = pnmovimi;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN -1;
      END;

      RETURN 0;
   END f_borrar_tabla_estresulseg;

   /*-*/
   PROCEDURE p_ins_estgar_invisibles (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      mens       OUT      VARCHAR2
   )
   IS
      /***************************************************************************
                            Función que inserta las garantias no visibles y obligatorias (ctipgar = 8)
       en estseguros, para cada uno de sus riesgos
      ****************************************************************************/
      CURSOR garantias (
         pcramo     IN   NUMBER,
         pcmodali   IN   NUMBER,
         pctipseg   IN   NUMBER,
         pccolect   IN   NUMBER
      )
      IS
         SELECT *
           FROM garanpro
          WHERE ctipgar = 8                                   /*No visibles*/
            AND cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;

      CURSOR riesgos
      IS
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = psseguro;

      vramo      NUMBER;
      vmodali    NUMBER;
      vtipseg    NUMBER;
      vcolect    NUMBER;
      vnmovimi   NUMBER;
   BEGIN
      mens := NULL;

      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO vramo, vmodali, vtipseg, vcolect
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            mens := SQLERRM;
      END;

      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi
           FROM estgaranseg
          WHERE sseguro = psseguro;
      ELSE
         vnmovimi := pnmovimi;
      END IF;

      IF mens IS NULL
      THEN
         FOR g IN garantias (vramo, vmodali, vtipseg, vcolect)
         LOOP
            FOR r IN riesgos
            LOOP
               BEGIN
                  INSERT INTO estgaranseg
                              (cgarant, nriesgo, nmovimi, sseguro,
                               finiefe, norden, crevali, ctarifa, icapital,
                               iprianu, ffinefe, cformul, irecarg, ipritar,
                               idtocom, prevali, irevali, itarifa, ipritot,
                               icaptot, ftarifa, ccampanya, nversio,
                               nparben, nbns, ctipfra, ifranqu, cmatch
                              )
                       VALUES (g.cgarant, r.nriesgo, vnmovimi, psseguro,
                               pfefecto, g.norden, g.crevali, g.ctarifa, 0,
                               0, NULL, g.cformul, 0, 0,
                               0, g.prevali, g.irevali, 0, 0,
                               0, pfefecto, NULL, NULL,
                               g.nparben, g.nbns, g.ctipfra, g.ifranqu, 0
                              );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     UPDATE estgaranseg
                        SET finiefe = pfefecto,
                            norden = g.norden,
                            crevali = g.crevali,
                            ctarifa = g.ctarifa,
                            icapital = 0,
                            iprianu = 0,
                            ffinefe = NULL,
                            cformul = g.cformul,
                            irecarg = 0,
                            ipritar = 0,
                            idtocom = 0,
                            prevali = g.prevali,
                            irevali = g.irevali,
                            itarifa = 0,
                            ipritot = 0,
                            icaptot = 0,
                            ftarifa = pfefecto,
                            ccampanya = NULL,
                            nversio = NULL,
                            nparben = g.nparben,
                            nbns = g.nbns,
                            ctipfra = g.ctipfra,
                            ifranqu = g.ifranqu,
                            cmatch = 0
                      WHERE sseguro = psseguro
                        AND nmovimi = vnmovimi
                        AND nriesgo = r.nriesgo
                        AND cgarant = g.cgarant
                        AND finiefe = pfefecto;
               END;
            END LOOP;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         mens := SQLERRM;
   END p_ins_estgar_invisibles;

   PROCEDURE p_borrar_estprestamo (c_ctapres IN VARCHAR2)
   IS
      num_err   NUMBER;
   BEGIN
      /*- Miramos si el contrato tiene alguna poliza en real*/
      BEGIN
         SELECT COUNT (1)
           INTO num_err
           FROM prestamoseg
          WHERE ctapres = c_ctapres;
      END;

      /* si no tiene ninguna borramos las tablas de prestamos*/
      IF num_err = 0
      THEN
         num_err := f_borrar_prestamo (c_ctapres);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'p_borrar_estprestamo',
                      'borrado_estprestamos',
                      SQLERRM,
                      SQLERRM
                     );
   END p_borrar_estprestamo;

   FUNCTION f_act_histom (
      pssegpol   IN   NUMBER,
      psperson   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err   NUMBER;
   BEGIN
      FOR tom IN (SELECT sperson
                    FROM tomadores
                   WHERE sseguro = pssegpol)
      LOOP
         BEGIN
            /* FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador - Añadir CEXISTEPAGADOR*/
            INSERT INTO histomadores
                        (sseguro, sperson, nmovimi, nordtom, cdomici,
                         cexistepagador, cagrupa)  --IAXIS-2085 03/04/2019 AP
               SELECT sseguro, sperson, pnmovimi, nordtom, cdomici,
                      cexistepagador, cagrupa      --IAXIS-2085 03/04/2019 AP
                 FROM tomadores
                WHERE sseguro = pssegpol AND sperson = tom.sperson;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               NULL;
         END;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         /*---mens    := SQLERRM;*/
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'f_act_histom.Error traspaso tabla HISTOMADORES.',
                      SQLERRM
                     );
         num_err := 1000499;
         RETURN num_err;
   END f_act_histom;

   FUNCTION f_act_hisaseg (
      pssegpol   IN   NUMBER,
      psperson   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pnorden    IN   NUMBER
   )                                              /* BUG11183:DRA:08/10/2009*/
      RETURN NUMBER
   IS
      num_err   NUMBER;
   BEGIN
      INSERT INTO hisasegurados
                  (sseguro, sperson, nmovimi, norden, cdomici, ffecini,
                   ffecfin, ffecmue, fecretroact, cparen)
                                /*BUG 24505: DCT 14/11/2012 Añadir ffecini*/
         SELECT sseguro, sperson, pnmovimi, norden, cdomici, ffecini,
                ffecfin, ffecmue, fecretroact, cparen
           FROM asegurados
          WHERE sseguro = pssegpol AND sperson = psperson
                AND norden = pnorden;            /* BUG11183:DRA:08/10/2009*/

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         /*----mens    := SQLERRM;*/
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'f_act_hisaseg.Error traspaso tabla HISASEGURADOS.',
                      SQLERRM
                     );
         num_err := 1000500;
         RETURN num_err;
   END f_act_hisaseg;

   FUNCTION f_act_hisriesgo (
      pssegpol   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err   NUMBER;
   BEGIN
      /*MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo*/
      INSERT INTO hisriesgos
                  (nriesgo, sseguro, nmovimi, tnatrie, cdomici, nasegur,
                   nedacol, csexcol, sbonush, czbonus, ctipdiraut, spermin,
                   cactivi,
                           /* Ini Bug 21907 -- MDS -- 23/04/2012*/
                           pdtocom, precarg, pdtotec, preccom,
                                      /* Fin Bug 21907 -- MDS -- 23/04/2012*/
                                                              tdescrie)
                                         -- BUG CONF-114 - 21/09/2016 - JAEG)
         SELECT nriesgo, sseguro, pnmovimi, tnatrie, cdomici, nasegur,
                nedacol, csexcol, sbonush, czbonus, ctipdiraut, spermin,
                cactivi,              /* Ini Bug 21907 -- MDS -- 23/04/2012*/
                        pdtocom, precarg, pdtotec, preccom,
                                      /* Fin Bug 21907 -- MDS -- 23/04/2012*/
                tdescrie                  -- BUG CONF-114 - 21/09/2016 - JAEG
           FROM riesgos
          WHERE sseguro = pssegpol AND nriesgo = pnriesgo;

      RETURN 0;
   EXCEPTION
      /* Bug 22294/115148 - 22/05/2012 - AMC*/
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE hisriesgos
            SET (tnatrie, cdomici, nasegur, nedacol, csexcol, sbonush,
                 czbonus, ctipdiraut, spermin, cactivi, pdtocom, precarg,
                 pdtotec, preccom, tdescrie)
                                           -- BUG CONF-114 - 21/09/2016 - JAEG
                                            =
                   (SELECT tnatrie, cdomici, nasegur, nedacol, csexcol,
                           sbonush, czbonus, ctipdiraut, spermin, cactivi,
                           pdtocom, precarg, pdtotec, preccom,
                           tdescrie        -- BUG CONF-114 - 21/09/2016 - JAEG
                      FROM riesgos ri
                     WHERE ri.sseguro = pssegpol AND ri.nriesgo = pnriesgo)
          WHERE sseguro = pssegpol AND nriesgo = pnriesgo
                AND nmovimi = pnmovimi;

         RETURN 0;
      /* Fi Bug 22294/115148 - 22/05/2012 - AMC*/
      WHEN OTHERS
      THEN
         /*---mens    := SQLERRM;*/
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'f_act_hisriesgo.Error traspaso tabla HISRIESGOS.',
                      SQLERRM
                     );
         num_err := 1000501;
         RETURN num_err;
   END f_act_hisriesgo;

   PROCEDURE traspaso_tomadores (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pmensaje   OUT      VARCHAR2
   )
   IS
      /***************************************************************************
                                                                      Procedimiento que se encarga de realizar el traspaso de esttomadores a tomadores
      ****************************************************************************/
      /*Se borran los Tomadores que están en TOMADORES y no están en ESTTOMADORES*/
      CURSOR c_tomadoresborrar
      IS
         SELECT sperson, sseguro
           FROM tomadores
          WHERE sseguro = pssegpol
            AND sperson NOT IN (
                                SELECT pac_persona.f_sperson_spereal (sperson)
                                  FROM esttomadores
                                 WHERE sseguro = psseguro);

      /* Se modifican los Tomadores que están en las dos tablas*/
      /* FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador - Añadir CEXISTEPAGADOR*/
      CURSOR c_tomadoresmodificar
      IS
         SELECT pac_persona.f_sperson_spereal (e.sperson) sperson_new,
                e.sseguro sseguro_new, e.cdomici cdomici_new,
                e.nordtom nordtom_new, t.sperson sperson_old,
                t.sseguro sseguro_old, t.cdomici cdomici_old,
                t.nordtom nordtom_old, e.cexistepagador cexistepagador_new,
                t.cexistepagador cexistepagador_old, e.cagrupa cagrupa_new,
                t.cagrupa cagrupa_old               --IAXIS-2085 03/04/2019 AP
           FROM esttomadores e, tomadores t
          WHERE t.sseguro = pssegpol
            AND pac_persona.f_sperson_spereal (e.sperson) = t.sperson
            AND e.sseguro = psseguro;

      /* Se insertan los Tomadores que están en ESTTOMADORES y no están en TOMADORES*/
      /* FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador - Añadir CEXISTEPAGADOR*/
      CURSOR c_tomadoresinsertar
      IS
         SELECT pac_persona.f_sperson_spereal (sperson) sperson, sseguro,
                cdomici, nordtom, cexistepagador,
                cagrupa                             --IAXIS-2085 03/04/2019 AP
           FROM esttomadores
          WHERE sseguro = psseguro
            AND pac_persona.f_sperson_spereal (sperson) NOT IN (
                                                      SELECT sperson
                                                        FROM tomadores
                                                       WHERE sseguro =
                                                                      pssegpol);

      num_err   NUMBER;
      salida    EXCEPTION;
      v_tab     NUMBER;
   BEGIN
      FOR reg IN c_tomadoresmodificar
      LOOP
         /*mirem si hi han canvis*/
         IF    NVL (reg.cdomici_new, 0) != NVL (reg.cdomici_old, 0)
            /*BUG 30448/0171481 , JDS. 04-04-2014*/
            /* FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador - Añadir CEXISTEPAGADOR - inicio*/
            OR NVL (reg.cexistepagador_new, 0) !=
                                               NVL (reg.cexistepagador_old, 0)
            /* FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador - Añadir CEXISTEPAGADOR - fin*/
            OR reg.nordtom_new != reg.nordtom_old
            OR reg.cagrupa_new != reg.cagrupa_old
         THEN
            /*xvila: Bug 6008 fem el traspas al historic.*/
            num_err :=
                  f_act_histom (pssegpol, reg.sperson_old, NVL (pnmovimi, 1));

            IF num_err <> 0
            THEN
               v_tab := 1;
               RAISE salida;
            END IF;

            /* FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador - Añadir CEXISTEPAGADOR*/
            UPDATE tomadores
               SET nordtom = reg.nordtom_new,
                   cdomici = reg.cdomici_new,
                   cexistepagador = reg.cexistepagador_new,
                   cagrupa = reg.cagrupa_new        --IAXIS-2085 03/04/2019 AP
             WHERE sseguro = pssegpol AND sperson = reg.sperson_old;
         END IF;
      END LOOP;

      /* ******************** Borrado de tomadores *************************/
      FOR reg IN c_tomadoresborrar
      LOOP
         /*xvila: aqui s'hauria de fer el traspas al historic una altre vegada.*/
         num_err := f_act_histom (pssegpol, reg.sperson, NVL (pnmovimi, 1));

         IF num_err <> 0
         THEN
            v_tab := 2;
            RAISE salida;
         END IF;

         DELETE FROM tomadores
               WHERE sseguro = pssegpol AND sperson = reg.sperson;
      END LOOP;

      /* FPG - 31-07-2012 - BUG 0023075: LCOL_T010-Figura del pagador - Añadir CEXISTEPAGADOR*/
      FOR reg IN c_tomadoresinsertar
      LOOP
         --JRH
         num_err := f_act_histom (pssegpol, reg.sperson, NVL (pnmovimi, 1));

         IF num_err <> 0
         THEN
            v_tab := 3;
            RAISE salida;
         END IF;

         --JRH
         INSERT INTO tomadores
                     (sperson, sseguro, cdomici, nordtom,
                      cexistepagador, cagrupa
                     )                              --IAXIS-2085 03/04/2019 AP
              VALUES (reg.sperson, pssegpol, reg.cdomici, reg.nordtom,
                      reg.cexistepagador, reg.cagrupa
                     );
      END LOOP;
   EXCEPTION
      WHEN salida
      THEN
         pmensaje := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'traspaso_tomadores.Error traspaso tabla TOMADORES.',
                      SQLERRM
                     );
      WHEN OTHERS
      THEN
         pmensaje := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'traspaso_tomadores.Error traspaso tabla TOMADORES.',
                      SQLERRM
                     );
   END traspaso_tomadores;

   PROCEDURE traspaso_asegurados (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pmensaje   OUT      VARCHAR2
   )
   IS
      /***************************************************************************
                                                 Procedimiento que se encarga de realizar el traspaso de estassegurats a asegurados
      ****************************************************************************/
      /*Se borran los Asegurados que están en ASEGURADOS y no están en ESTASSEGURATS*/
      CURSOR c_aseguradosborrar
      IS
         SELECT a.sseguro, a.sperson, a.norden, a.cdomici, a.ffecini,
                a.ffecfin, a.ffecmue, a.nriesgo,
                a.fecretroact                    /* BUG11183:DRA:22/09/2009*/
           FROM asegurados a
          WHERE a.sseguro = pssegpol
            AND NOT EXISTS (
                   SELECT 1
                     FROM estassegurats e
                    WHERE e.sseguro = psseguro
                      AND pac_persona.f_sperson_spereal (e.sperson) =
                                                                     a.sperson
                      AND e.norden = a.norden);

      /* BUG11183:DRA:22/09/2009: Se tiene que comparar con NORDEN*/
      /*AND sperson NOT IN(SELECT pac_persona.f_sperson_spereal(sperson)
                                                 FROM estassegurats
      WHERE sseguro = psseguro);*/
      /* Se modifican los Asegurados que están en las dos tablas*/
      CURSOR c_aseguradosmodificar
      IS
         SELECT e.sseguro sseguro_new,
                pac_persona.f_sperson_spereal (e.sperson) sperson_new,
                e.norden norden_new, e.cdomici cdomici_new,
                e.ffecini ffecini_new, e.ffecfin ffecfin_new,
                e.ffecmue ffecmue_new, a.sseguro sseguro_old,
                a.sperson sperson_old, a.norden norden_old,
                a.cdomici cdomici_old, a.ffecini ffecini_old,
                a.ffecfin ffecfin_old, a.ffecmue ffecmue_old,
                e.nriesgo nriesgo_new, a.nriesgo nriesgo_old,
                e.fecretroact fecretroact_new, a.fecretroact fecretroact_old,
                                                  /* BUG11183:DRA:22/09/2009*/
                e.nordeninc nordeninc_new,
                                  /* BUG 0014979  - Fecha (28/01/2015) ? HRE*/
                                          a.nordeninc nordeninc_old,
                                  /* BUG 0014979  - Fecha (28/01/2015) ? HRE*/
                a.cparen cparen_old, e.cparen cparen_new
           FROM estassegurats e, asegurados a
          WHERE a.sseguro = pssegpol
            AND pac_persona.f_sperson_spereal (e.sperson) = a.sperson
            AND e.sseguro = psseguro
            AND e.norden = a.norden;

      /* BUG11183:DRA:22/09/2009: Se tiene que comparar con NORDEN*/
      /* Se insertan los Asaegurados que están en ESTASSEEGURTATS y no están en ASEGURADOS*/
      CURSOR c_aseguradosinsertar
      IS
         SELECT e.sseguro, pac_persona.f_sperson_spereal (e.sperson) sperson,
                e.norden, e.cdomici, e.ffecini, e.ffecfin, e.ffecmue,
                e.nriesgo, e.fecretroact,
                e.nordeninc /* BUG11183:DRA:22/09/2009  -- BUG 0014979  - Fecha (28/01/2015) ? HRE*/,
                e.cparen
           FROM estassegurats e
          WHERE e.sseguro = psseguro
            AND NOT EXISTS (
                   SELECT 1
                     FROM asegurados a
                    WHERE a.sseguro = pssegpol
                      AND a.sperson =
                                     pac_persona.f_sperson_spereal (e.sperson)
                      AND a.norden = e.norden);

      /* BUG11183:DRA:22/09/2009: Se tiene que comparar con NORDEN*/
      /*AND pac_persona.f_sperson_spereal(e.sperson) NOT IN(SELECT sperson
                                                 FROM asegurados
      WHERE sseguro = pssegpol);*/
      num_err   NUMBER;
      salida    EXCEPTION;
   BEGIN
      FOR reg IN c_aseguradosmodificar
      LOOP
         /*mirem si hi han canvis*/
         IF    reg.norden_new != reg.norden_old
            OR (   reg.cdomici_new != reg.cdomici_old
                OR (reg.cdomici_new IS NOT NULL AND reg.cdomici_old IS NULL)
               )
            OR reg.ffecini_new != reg.ffecini_old
            OR reg.ffecfin_new != NVL (reg.ffecfin_old, f_sysdate)
            OR reg.ffecmue_new != reg.ffecmue_old
            OR reg.fecretroact_new != reg.fecretroact_old
            OR reg.nriesgo_new != reg.nriesgo_old /* BUG11183:DRA:22/09/2009*/
            OR reg.nordeninc_new !=
                  reg.nordeninc_old
                                  /* BUG 0014979  - Fecha (28/01/2015) ? HRE*/
            OR reg.cparen_new != reg.cparen_old
         THEN
            /*xvila: Bug 6008 fem el traspas al historic.*/
            num_err :=
               f_act_hisaseg (pssegpol,
                              reg.sperson_old,
                              NVL (pnmovimi, 1),
                              reg.norden_old
                             );

            IF num_err <> 0
            THEN
               RAISE salida;
            END IF;

            UPDATE asegurados
               SET sperson = reg.sperson_new,
                   norden = reg.norden_new,
                   cdomici = reg.cdomici_new,
                   ffecini = reg.ffecini_new,
                   ffecfin = reg.ffecfin_new,
                   ffecmue = reg.ffecmue_new,
                   nriesgo = reg.nriesgo_new,     /* BUG11183:DRA:22/09/2009*/
                   fecretroact = reg.fecretroact_new,
                   cparen = reg.cparen_new
             WHERE sseguro = pssegpol
               AND sperson = reg.sperson_old
               AND norden = reg.norden_old;
         /* BUG11183:DRA:22/09/2009: Se tiene que comparar con NORDEN*/
         END IF;
      END LOOP;

      /* ******************** Borrado de asegurados *************************/
      FOR reg IN c_aseguradosborrar
      LOOP
         /*xvila: aqui s'hauria de fer el traspas al historic una altre vegada.*/
         num_err :=
            f_act_hisaseg (pssegpol,
                           reg.sperson,
                           NVL (pnmovimi, 1),
                           reg.norden
                          );

         IF num_err <> 0
         THEN
            RAISE salida;
         END IF;

         DELETE FROM asegurados
               WHERE sseguro = pssegpol
                 AND sperson = reg.sperson
                 AND norden = reg.norden;
      /* BUG11183:DRA:22/09/2009: Se tiene que comparar con NORDEN*/
      END LOOP;

      /* ******************** Inserción de asegurados nuevos *************************/
      FOR reg IN c_aseguradosinsertar
      LOOP
         INSERT INTO asegurados
                     (sseguro, sperson, norden, cdomici,
                      ffecini, ffecfin, ffecmue, nriesgo,
                      fecretroact, nordeninc, cparen
                     )
        /* BUG11183:DRA:22/09/2009 -- BUG 0014979 - Fecha (28/01/2015) ? HRE*/
              VALUES (pssegpol, reg.sperson, reg.norden, reg.cdomici,
                      reg.ffecini, reg.ffecfin, reg.ffecmue, reg.nriesgo,
                      reg.fecretroact, reg.nordeninc, reg.cparen
                     );
        /* BUG11183:DRA:22/09/2009 -- BUG 0014979 - Fecha (28/01/2015) ? HRE*/
      END LOOP;
   EXCEPTION
      WHEN salida
      THEN
         pmensaje := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'traspaso_asegurados.Error traspaso tabla ASEGURADOS.',
                      SQLERRM
                     );
      WHEN OTHERS
      THEN
         pmensaje := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'traspaso_asegurados.Error traspaso tabla ASEGURADOS.',
                      SQLERRM
                     );
   END traspaso_asegurados;

/*-----------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------*/
/*JTS 17/12/2008 APRA 8467*/
   PROCEDURE traspaso_segcbancar (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      mens       OUT      VARCHAR2
   )
   IS
      xfiniefe   DATE;
      xffinefe   DATE;
      xcbancar   VARCHAR2 (34);
      xcbancob   VARCHAR2 (34);
   BEGIN
      SELECT finiefe, ffinefe, cbancar, cbancob
        INTO xfiniefe, xffinefe, xcbancar, xcbancob
        FROM estseg_cbancar
       WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      INSERT INTO seg_cbancar
                  (sseguro, nmovimi, finiefe, ffinefe, cbancar, cbancob
                  )
           VALUES (pssegpol, pnmovimi, xfiniefe, xffinefe, xcbancar, xcbancob
                  );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         mens := SQLERRM;
         p_tab_error
                    (f_sysdate,
                     f_user,
                     'PAC_ALCTR126',
                     1,
                     'traspaso_segcbancar.Error traspaso tabla SEG_CBANCAR.',
                     SQLERRM
                    );
   END traspaso_segcbancar;

   /*************************************************************************
                           Borrar registros en las tablas est que dependen de la actividad que seleccionemos
      param in psolicit   : nÃºmero de solicitud
      param in pnmovimi   : nÃºmero de movimiento
      param in pnriesgo   : nÃºmero de riesgo
      param in pcobjase   : tipo de riesgo
      param in ppmode   : Modo EST/POL
      param out mensajes  : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error o codigo error
   *************************************************************************/
   PROCEDURE p_limpiar_tablas (
      psolicit   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcobjase   IN   NUMBER,
      ppmode     IN   VARCHAR2
   )
   IS
   BEGIN
      IF ppmode = 'EST'
      THEN
         DELETE      estpregungaranseg
               WHERE sseguro = psolicit
                 AND nmovimi = NVL (pnmovimi, 1)
                 AND nriesgo = NVL (pnriesgo, 1);

         DELETE      estpregungaransegtab
               WHERE sseguro = psolicit
                 AND nmovimi = NVL (pnmovimi, 1)
                 AND nriesgo = NVL (pnriesgo, 1);

         DELETE FROM estdetgaranseg
               WHERE sseguro = psolicit
                 AND nmovimi = NVL (pnmovimi, 1)
                 AND nriesgo = NVL (pnriesgo, 1);

         DELETE FROM estgaranseg
               WHERE sseguro = psolicit
                 AND nmovimi = NVL (pnmovimi, 1)
                 AND nriesgo = NVL (pnriesgo, 1);

         IF pcobjase = 5
         THEN
            DELETE FROM autdetriesgos
                  WHERE sseguro = psolicit
                    AND nmovimi = NVL (pnmovimi, 1)
                    AND nriesgo = NVL (pnriesgo, 1);

            DELETE FROM autdisriesgos
                  WHERE sseguro = psolicit
                    AND nmovimi = NVL (pnmovimi, 1)
                    AND nriesgo = NVL (pnriesgo, 1);

            DELETE FROM estautriesgos
                  WHERE sseguro = psolicit
                    AND nmovimi = NVL (pnmovimi, 1)
                    AND nriesgo = NVL (pnriesgo, 1);
         END IF;
      ELSIF ppmode = 'POL'
      THEN
         DELETE      estpregungaranseg
               WHERE sseguro = psolicit
                 AND nmovimi = NVL (pnmovimi, 1)
                 AND nriesgo = NVL (pnriesgo, 1);

         DELETE      estpregungaransegtab
               WHERE sseguro = psolicit
                 AND nmovimi = NVL (pnmovimi, 1)
                 AND nriesgo = NVL (pnriesgo, 1);

         DELETE FROM detgaranseg
               WHERE sseguro = psolicit
                 AND nmovimi = NVL (pnmovimi, 1)
                 AND nriesgo = NVL (pnriesgo, 1);

         DELETE FROM garanseg
               WHERE sseguro = psolicit
                 AND nmovimi = NVL (pnmovimi, 1)
                 AND nriesgo = NVL (pnriesgo, 1);

         IF pcobjase = 5
         THEN
            DELETE FROM autdetriesgos
                  WHERE sseguro = psolicit
                    AND nmovimi = NVL (pnmovimi, 1)
                    AND nriesgo = NVL (pnriesgo, 1);

            DELETE FROM autdisriesgos
                  WHERE sseguro = psolicit
                    AND nmovimi = NVL (pnmovimi, 1)
                    AND nriesgo = NVL (pnriesgo, 1);

            DELETE FROM autriesgos
                  WHERE sseguro = psolicit
                    AND nmovimi = NVL (pnmovimi, 1)
                    AND nriesgo = NVL (pnriesgo, 1);
         END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ALCTR126',
                      1,
                      'p_limpiar_tablas',
                      SQLERRM
                     );
   END p_limpiar_tablas;

   PROCEDURE borrar_movimiento (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pmovseg    IN   NUMBER DEFAULT 0
   )
   IS
      v_pasexec   NUMBER := 0;
   BEGIN
      v_pasexec := 1;

      DELETE FROM bf_bonfranseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM garansegcom
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      /*CONVENIOS*/
      DELETE FROM tramosregul
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM aseguradosmes
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      /*CONVENIOS*/
      /* Bug 21121 - APD - 21/02/2012 - se incluye la tabla detprimas*/
      DELETE FROM detprimas
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      /* fin Bug 21121 - APD - 21/02/2012*/
      v_pasexec := 2;

      DELETE FROM notibajaseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 3;

      DELETE FROM notibajagar
            WHERE sseguro = psseguro AND nmovimb = pnmovimi;

      v_pasexec := 4;

      DELETE FROM excluseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 5;

      DELETE FROM carenseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 6;

      DELETE FROM primasgaranseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM pregunseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM pregunsegtab
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 7;

      DELETE FROM pregungaranseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM pregungaransegtab
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 8;

      DELETE FROM pregunpolseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM pregunpolsegtab
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 9;

      DELETE FROM saldodeutorseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 10;

      DELETE FROM comisigaranseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 11;

      DELETE FROM detgaranseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 12;

      DELETE FROM garanseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 13;

      DELETE FROM cesionesrea
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 14;

      DELETE FROM segdisin2
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 15;

      DELETE FROM v_rescate
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 16;

      DELETE FROM claubenseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 17;

      DELETE FROM psucontrolseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 18;

      DELETE FROM riesgos_ir
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM riesgos_ir_ordenes
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM basequestion_undw
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM actions_undw
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM exclusiones_undw
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      DELETE FROM enfermedades_undw
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 18;

      DELETE FROM psu_retenidas
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 19;

      DELETE FROM clauparesp
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 20;

      DELETE FROM clausuesp
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 21;

      DELETE FROM tarjetas
            WHERE sseguro = psseguro AND nmovima = pnmovimi;

      v_pasexec := 22;

      DELETE FROM claususeg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 23;

      DELETE FROM autconductores
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 24;

      DELETE FROM autdetriesgos
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 25;

      DELETE FROM autdisriesgos
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 251;

      DELETE FROM autriesgos
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 26;

      /*      DELETE      detembarcriesgos*/
      /*            WHERE nmovimi = pnmovimi*/
      /*              AND sseguro = psseguro;*/
      /*      v_pasexec := 27;*/
      /*      DELETE      embarcriesgos*/
      /*            WHERE nmovimi = pnmovimi*/
      /*              AND sseguro = psseguro;*/
      /*      v_pasexec := 28;*/
      DELETE      planrentasirreg
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 29;

      DELETE      intertecseggar
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 30;

      DELETE FROM prestamoseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 31;

      DELETE FROM prestcuadroseg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      v_pasexec := 32;

      DELETE FROM texmovseguro
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      /* Bug INI: 35095/199894 - 06/03/2015 - PRB*/
      DELETE FROM asegurados_innom
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      /* Bug FIN: 35095/199894 - 06/03/2015 - PRB*/
      v_pasexec := 33;

      DELETE      bloqueoseg
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 34;

      DELETE      seg_cbancar
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 35;

      DELETE      resulseg
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 36;

      DELETE      garanseggas
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 37;

      DELETE      garanseg_sbpri
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 38;

      DELETE      intertecseg
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 39;

      DELETE      evoluprovmatseg
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 40;

      DELETE      age_corretaje
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 41;

      DELETE      benespseg
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 42;

      DELETE      docrequerida
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 43;

      DELETE      docrequerida_riesgo
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 44;

      DELETE      docrequerida_inqaval
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      v_pasexec := 45;

      DELETE      docummovseg
            WHERE nmovimi = pnmovimi AND sseguro = psseguro;

      IF pmovseg = 1
      THEN
         v_pasexec := 46;

         DELETE      detmovseguro
               WHERE sseguro = psseguro AND nmovimi = pnmovimi;

         v_pasexec := 47;

         DELETE      movseguro
               WHERE sseguro = psseguro AND nmovimi = pnmovimi;
      END IF;

      /* Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran*/
      v_pasexec := 48;

      /* INI BUG 34461, 34462 - Productos de CONVENIOS*/
      DELETE FROM cnv_conv_emp_seg
            WHERE sseguro = psseguro AND nmovimi = pnmovimi;

      /* FIN BUG 34461, 34462 - Productos de CONVENIOS*/
      DELETE FROM coacuadro
            WHERE sseguro = psseguro AND ncuacoa = pnmovimi;

      v_pasexec := 49;

      DELETE FROM coacedido
            WHERE sseguro = psseguro AND ncuacoa = pnmovimi;
   /* Fin Bug 0023183*/
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_alctr126.borrar_movimiento',
                      v_pasexec,
                      'borrado est',
                      SQLERRM
                     );
   END borrar_movimiento;

   /**********************************************************************
                                       Funcion de traspado iquilinos y avalistas de las tablas EST a las reales
        param psseguro IN NUMBER,
        param   pssegpol IN NUMBER,
        param  pnmovimi IN NUMBER,
        param  pfefecto  IN DATE,
       param  mens OUT VARCHAR2
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   ***********************************************************************/
   /*bug 21657--ETM--05/06/2012*/
   PROCEDURE p_traspaso_inquiaval (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pfefecto   IN       DATE,
      mens       OUT      VARCHAR2
   )
   IS
      v_pasexec     NUMBER := 0;
      reg_inquiav   NUMBER;
      v_nmovimi     NUMBER;
   BEGIN
      v_pasexec := 1;

      SELECT NVL (MAX (nmovimi), 0)
        INTO v_nmovimi
        FROM inquiaval
       WHERE sseguro = pssegpol;

      IF v_nmovimi <> pnmovimi
      THEN
         INSERT INTO inquiaval
                     (sseguro, sperson, nriesgo, nmovimi, ctipfig, cdomici,
                      iingrmen, iingranual, ffecini, ffecfin, ctipcontrato,
                      csitlaboral, csupfiltro)
            (SELECT pssegpol, pac_persona.f_sperson_spereal (sperson),
                    nriesgo, nmovimi, ctipfig, cdomici, iingrmen, iingranual,
                    ffecini, ffecfin, ctipcontrato, csitlaboral, csupfiltro
               FROM estinquiaval
              WHERE sseguro = psseguro AND nmovimi = NVL (pnmovimi, nmovimi));
      END IF;

      v_pasexec := 2;

      /*Se ha eliminado algun inquiaval*/
      SELECT COUNT (*)
        INTO reg_inquiav
        FROM inquiaval
       WHERE sseguro = pssegpol
         AND nmovimi < pnmovimi
         AND ffecfin IS NULL
         AND sperson NOT IN (SELECT sperson
                               FROM estinquiaval
                              WHERE sseguro = psseguro AND nmovimi = pnmovimi);

      IF reg_inquiav <> 0
      THEN
         /* Se ha eliminado actualizamos nov anterior con fbaja*/
         v_pasexec := 3;

         UPDATE inquiaval
            SET ffecfin = pfefecto
          WHERE sseguro = pssegpol
            AND nmovimi < pnmovimi
            AND ffecfin IS NULL
            AND sperson NOT IN (
                               SELECT sperson
                                 FROM estinquiaval
                                WHERE sseguro = psseguro
                                      AND nmovimi = pnmovimi);
      END IF;

      v_pasexec := 4;
   EXCEPTION
      WHEN OTHERS
      THEN
         mens := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_alctr126.p_traspaso_inquiaval',
                      v_pasexec,
                      'traspaso inquiaval',
                      SQLERRM
                     );
   END p_traspaso_inquiaval;

   /*FIN BUG 21657--ETM-05/06/2012*/
   /* Bug 36596 IGIL INI*/
   /**********************************************************************
        Procedure de traspaso citas medicas de las tablas EST a las reales
        param psseguro IN NUMBER,
        param   pssegpol IN NUMBER,
        param  pnmovimi IN NUMBER,

       param  mensaje OUT VARCHAR2
   ***********************************************************************/
   PROCEDURE traspaso_citas (
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pmensaje   OUT      VARCHAR2
   )
   IS
      CURSOR c_citas
      IS
         SELECT NVL (pac_persona.f_sperson_spereal (cit.speraseg),
                     cit.speraseg
                    ) per1,
                NVL (pac_persona.f_sperson_spereal (cit.spermed),
                     cit.spermed
                    ) per2,
                cit.*
           FROM estcitamedica_undw cit
          WHERE cit.sseguro = psseguro;

      num_err     NUMBER;
      salida      EXCEPTION;
      v_tab       NUMBER;
      mensajes    t_iax_mensajes;
      v_object    VARCHAR2 (2000) := 'PAC_ALCTR126.traspaso_citas';
      v_pasexec   NUMBER          := 0;
   BEGIN
      v_pasexec := 1;

      FOR reg IN c_citas
      LOOP
         v_pasexec := 2;
         num_err :=
            pac_md_underwriting.f_insert_citasmedicas (pssegpol,
                                                       reg.nriesgo,
                                                       reg.nmovimi,
                                                       reg.per1,
                                                       reg.per2,
                                                       reg.ceviden,
                                                       reg.feviden,
                                                       reg.cestado,
                                                       'POL',
                                                       reg.ieviden,
                                                       reg.cpago,
                                                       reg.norden,
                                                       reg.cais,
                                                       mensajes
                                                      );
         v_pasexec := 3;
      END LOOP;

      v_pasexec := 4;
   EXCEPTION
      WHEN salida
      THEN
         pmensaje := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      v_object,
                      v_pasexec,
                      'traspaso_citas.Error traspaso tabla CITAMEDICA_UNDW.',
                      SQLERRM
                     );
      WHEN OTHERS
      THEN
         pmensaje := SQLERRM;
         p_tab_error (f_sysdate,
                      f_user,
                      v_object,
                      v_pasexec,
                      'traspaso_citas.Error traspaso tabla CITAMEDICA_UNDW.',
                      SQLERRM
                     );
   END traspaso_citas;

   /* Bug 36596 IGIL FIN*/

   /**********************************************************************
         Procedure de traspaso citas medicas de las tablas EST a las reales

    ***********************************************************************/
   FUNCTION f_act_hispsu (psseguro IN NUMBER,                         --ramiro
                                             pnmovimi IN NUMBER)      --ramiro
      RETURN NUMBER
   IS
      vsituac            NUMBER;
      num_err            NUMBER;
      vnversion          NUMBER;
      vpsu_retenidas     psu_retenidas%ROWTYPE;
      error_controlado   EXCEPTION;
      v_pasexec          NUMBER                  := 0;
      v_object           VARCHAR2 (200)
                        := 'psseguro ' || psseguro || 'pnmovimi ' || pnmovimi;

      CURSOR c_vpsu
      IS
         SELECT *
           FROM psucontrolseg p
          WHERE p.sseguro = psseguro
            AND p.nmovimi = pnmovimi
            AND p.nocurre IN (
                           SELECT MAX (s.nocurre)
                             FROM psucontrolseg s
                            WHERE s.sseguro = psseguro
                                  AND s.nmovimi = pnmovimi);
   BEGIN
      p_control_error ('PAC_ALCTR126', 'F_ACT_HISPDU', '1. PASO 1');
      p_tab_error (f_sysdate,
                   f_user,
                   'etm',
                   6,
                      'psseguro -->'
                   || psseguro
                   || 'aux_ssegpol: pnmovimi'
                   || pnmovimi,
                   SQLERRM
                  );                                            /*etm quitar*/
      v_pasexec := 111;

      SELECT s.csituac
        INTO vsituac
        FROM seguros s
       WHERE sseguro = psseguro;

      p_control_error ('PAC_ALCTR126',
                       'F_ACT_HISPDU',
                       '1. PASO 2, VSITUAC:' || vsituac
                      );
      v_pasexec := 2;
      p_tab_error (f_sysdate,
                   f_user,
                   v_object,
                   v_pasexec,
                   'Ramiro quitar PAC_ALCTR126.F_ACT_HISPSU',
                   vsituac
                  );
      --IF VSITUAC = 4 OR  VSITUAC = 5 THEN
      p_control_error ('PAC_ALCTR126', 'F_ACT_HISPDU', '1. PASO 3');
      v_pasexec := 3;

      BEGIN
         SELECT NVL (MAX (h.nversion), 0) + 1
           INTO vnversion
           FROM his_psucontrolseg h
          WHERE h.sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnversion := 0;
      END;

      v_pasexec := 4;
      p_control_error ('PAC_ALCTR126', 'F_ACT_HISPDU', '1. PASO 4');

-- Ini 13888 -- 20/05/2020
      FOR vpsucontrolseg IN c_vpsu
      LOOP
         BEGIN
            INSERT INTO his_psucontrolseg
                        (autmanual,
                         autoriprev, cautrec,
                         ccontrol, cgarant,
                         cnivelr, cnivelu,
                         cusuaur, cusumov,
                         establoquea, fautrec,
                         fmovpsu, isvisible,
                         nmovimi, nocurre,
                         nriesgo, nvalor,
                         nvalorinf,
                         nvalorsuper,
                         nvalortope, observ,
                         ordenbloquea, nversion,
                         sseguro
                        )
                 VALUES (vpsucontrolseg.autmanual,
                         vpsucontrolseg.autoriprev, vpsucontrolseg.cautrec,
                         vpsucontrolseg.ccontrol, vpsucontrolseg.cgarant,
                         vpsucontrolseg.cnivelr, vpsucontrolseg.cnivelu,
                         vpsucontrolseg.cusuaur, vpsucontrolseg.cusumov,
                         vpsucontrolseg.establoquea, vpsucontrolseg.fautrec,
                         vpsucontrolseg.fmovpsu, vpsucontrolseg.isvisible,
                         vpsucontrolseg.nmovimi, vpsucontrolseg.nocurre,
                         vpsucontrolseg.nriesgo, vpsucontrolseg.nvalor,
                         vpsucontrolseg.nvalorinf,
                         vpsucontrolseg.nvalorsuper,
                         vpsucontrolseg.nvalortope, vpsucontrolseg.observ,
                         vpsucontrolseg.ordenbloquea, vnversion,
                         vpsucontrolseg.sseguro
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               NULL;
         END;
      END LOOP;

      v_pasexec := 5;
      p_control_error ('PAC_ALCTR126', 'F_ACT_HISPDU', '1. PASO 5');

      IF pnmovimi > 1
      THEN
         BEGIN
            SELECT *
              INTO vpsu_retenidas
              FROM psu_retenidas p
             WHERE p.sseguro = psseguro AND p.nmovimi = pnmovimi - 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RAISE error_controlado;
         END;
      ELSE
         BEGIN
            SELECT *
              INTO vpsu_retenidas
              FROM psu_retenidas p
             WHERE p.sseguro = psseguro AND p.nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RAISE error_controlado;
         END;
      END IF;

      v_pasexec := 6;
      p_control_error ('PAC_ALCTR126',
                       'F_ACT_HISPDU',
                          '1. PASO 6, psseguro:'
                       || psseguro
                       || ' pnmovimi'
                       || pnmovimi
                      );

      BEGIN
         INSERT INTO his_psu_retenidas
                     (cmotret,
                      cnivelbpm,
                      cusuaut,
                      cusuret, ffecaut,
                      ffecret, fmovimi,
                      nmovimi, nversion,
                      observ, sseguro
                     )
              VALUES (NVL (vpsu_retenidas.cmotret, 1),
                      vpsu_retenidas.cnivelbpm,
                      NVL (vpsu_retenidas.cusuaut, f_user),
                      vpsu_retenidas.cusuret, vpsu_retenidas.ffecaut,
                      vpsu_retenidas.ffecret, vpsu_retenidas.fmovimi,
                      vpsu_retenidas.nmovimi, vnversion,
                      vpsu_retenidas.observ, vpsu_retenidas.sseguro
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            NULL;
      END;

       --END IF;
      -- Ini 13888 -- 20/05/2020
      p_tab_error (f_sysdate,
                   f_user,
                   v_object,
                   v_pasexec,
                   'Ramiro 2; sseguro = ' || psseguro || 'movimi = '
                   || pnmovimi,
                   SQLERRM
                  );
      RETURN 0;
   EXCEPTION
      WHEN error_controlado
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_object,
                      v_pasexec,
                      'PAC_ALCTR126.F_ACT_HISPSU',
                      SQLERRM
                     );
         RETURN 9909205;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_object,
                      v_pasexec,
                      'PAC_ALCTR126.F_ACT_HISPSU',
                      SQLERRM
                     );
         RETURN 9909205;
   END f_act_hispsu;                                                  --ramiro

   -- INI - IAXIS-3200
   PROCEDURE borrar_tablas (psseguro IN NUMBER)
   IS
      /* Procediment per esborrar les taules d'estudis */
      c_ctapres   VARCHAR2 (34);

      CURSOR cur_personas
      IS
         SELECT sperson
           FROM estper_personas                     /*v_personas_estseguros*/
          WHERE sseguro = psseguro;

      v_pasexec   NUMBER        := 0;
   BEGIN
      v_pasexec := 1;

       /* Primero borramos las tablas y luego las volvemos a llenar*/
      /*JTS 17/12/2008 APRA 8467*/
      DELETE      aportaseg
            WHERE sseguro = psseguro;

      DELETE FROM seg_cbancar
            WHERE sseguro = psseguro;

      v_pasexec := 100;
      v_pasexec := 101;

      DELETE FROM reglassegtramos
            WHERE sseguro = psseguro;

      v_pasexec := 102;

      DELETE FROM reglasseg
            WHERE sseguro = psseguro;

      v_pasexec := 2;

      DELETE FROM asegurados
            WHERE sseguro = psseguro;

      v_pasexec := 3;

      DELETE FROM clauparseg
            WHERE sseguro = psseguro;

      v_pasexec := 4;

      DELETE FROM clauparesp
            WHERE sseguro = psseguro;

      v_pasexec := 5;

      DELETE FROM claususeg
            WHERE sseguro = psseguro;

      /* Bug 16726 - RSC - 13/01/2010 - APR - clauses definition*/
      DELETE FROM clausubloq
            WHERE sseguro = psseguro;

      /* Fin bug 16726*/
      v_pasexec := 6;

      DELETE FROM claubenseg
            WHERE sseguro = psseguro;

      v_pasexec := 7;

      /* BUG16410:JBN 17/11/2010: Si tiene parametros*/
      DELETE FROM clauparaseg
            WHERE sseguro = psseguro;

      DELETE FROM clausuesp
            WHERE sseguro = psseguro;

      /* antes de borrar un  prestamoseg*/
      /* borramos las tablas del prestamo*/
      /* si no tiene polizas reales vinculadas*/
      v_pasexec := 8;
      /* DRA: comento  o porque  a petando al contratar un producto de saldos deudores *
                                                BEGIN
         SELECT ctapres
           INTO c_ctapres
           FROM  prestamoseg
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;   --no tiene contrato vinculado
      END;*/
      v_pasexec := 9;

      DELETE FROM prestcuadroseg
            WHERE sseguro = psseguro;

      v_pasexec := 10;

      DELETE FROM prestamoseg
            WHERE sseguro = psseguro;

      v_pasexec := 11;
      /* DRA: comento  o porque  a petando al contratar un producto de saldos deudores *
                                                IF c_ctapres IS NOT NULL THEN
         p_borrar_estprestamo(c_ctapres);
      END IF;*/
      v_pasexec := 12;

      DELETE FROM coacedido
            WHERE sseguro = psseguro;

      v_pasexec := 13;

      DELETE FROM coacuadro
            WHERE sseguro = psseguro;

      v_pasexec := 14;

      DELETE FROM detmovseguro
            WHERE sseguro = psseguro;

      v_pasexec := 15;

      DELETE FROM intertecseg
            WHERE sseguro = psseguro;

      v_pasexec := 16;

      DELETE FROM exclugarseg
            WHERE sseguro = psseguro;

      v_pasexec := 17;

      DELETE FROM comisionsegu
            WHERE sseguro = psseguro;

      v_pasexec := 18;

      DELETE FROM garansegcom
            WHERE sseguro = psseguro;

      v_pasexec := 19;

      DELETE FROM garanseggas
            WHERE sseguro = psseguro;

      v_pasexec := 20;

      DELETE FROM garanseg_sbpri
            WHERE sseguro = psseguro;

      v_pasexec := 21;

      DELETE FROM pregungaranseg
            WHERE sseguro = psseguro;

      DELETE FROM pregungaransegtab
            WHERE sseguro = psseguro;

      v_pasexec := 22;

      DELETE FROM resulseg
            WHERE sseguro = psseguro;

      v_pasexec := 23;

      /* Bug 10757 - RSC - 21/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emisión*/
      DELETE FROM detgaranseg
            WHERE sseguro = psseguro;

      v_pasexec := 24;

      /* Fin Bug 10757*/
      /* Bug 21121 - APD - 21/02/2012 - borrar la tabla  detprimas antes de borrar en la tabla  garanseg*/
      DELETE FROM detprimas
            WHERE sseguro = psseguro;

      /* Fin Bug 21121*/
      /* Bug 27014 - SHA - 29/07/2013*/
      DELETE FROM primasgaranseg
            WHERE sseguro = psseguro;

      /* Fin Bug 27014*/
      /* INI BUG 34461, 34462 - Productos de CONVENIOS*/
      DELETE FROM tramosregul
            WHERE sseguro = psseguro;

      /* FIN BUG 34461, 34462 - Productos de CONVENIOS*/
      DELETE FROM garanseg
            WHERE sseguro = psseguro;

      v_pasexec := 25;

      DELETE FROM pregunseg
            WHERE sseguro = psseguro;

      DELETE FROM pregunsegtab
            WHERE sseguro = psseguro;

      v_pasexec := 26;
      /* Bug 10702. Saldo deutors*/
      /* Bug 11165 - 16/09/2009 - AMC - Se sustituñe   detsaldodeutorseg por  prestamoseg*/
      /*DELETE FROM  prestamoseg
      WHERE sseguro = psseguro;*/
      v_pasexec := 27;

      DELETE FROM saldodeutorseg
            WHERE sseguro = psseguro;

      /* Fin Bug 10702. Saldo deutors*/
      v_pasexec := 28;

      /*(JAS)11.12.2007 - afegida gestió de preguntes a nivell de pòlissa*/
      DELETE FROM pregunpolseg
            WHERE sseguro = psseguro;

      DELETE FROM pregunpolsegtab
            WHERE sseguro = psseguro;

      DELETE FROM subtabs_seg_det
            WHERE sseguro = psseguro;

      v_pasexec := 29;

      DELETE      pds_estsegurosupl
            WHERE sseguro = psseguro;

      v_pasexec := 30;

      DELETE      pds_estsigform
            WHERE sseguro = psseguro;

      v_pasexec := 31;

      DELETE FROM evoluprovmatseg
            WHERE sseguro = psseguro;

      v_pasexec := 32;

      /* **** Esborrat de taules de AUTOS ******************************/
      DELETE FROM autconductores
            WHERE sseguro = psseguro;

      v_pasexec := 331;

      DELETE FROM motreten_rev
            WHERE sseguro = psseguro;

      v_pasexec := 332;

      DELETE FROM motretencion
            WHERE sseguro = psseguro;

      v_pasexec := 34;

      DELETE FROM autdetriesgos
            WHERE sseguro = psseguro;

      DELETE FROM autdisriesgos
            WHERE sseguro = psseguro;

      v_pasexec := 35;

      DELETE FROM autriesgos
            WHERE sseguro = psseguro;

      v_pasexec := 36;

      /*      DELETE FROM  detembarcriesgos*/
      /*            WHERE sseguro = psseguro;*/
      /*      v_pasexec := 37;*/
      /*      DELETE FROM  embarcriesgos*/
      /*            WHERE sseguro = psseguro;*/
      /*      v_pasexec := 38;*/
      DELETE FROM sitriesgo
            WHERE sseguro = psseguro;

      v_pasexec := 40;

      DELETE FROM tomadores
            WHERE sseguro = psseguro;

      v_pasexec := 41;

      DELETE FROM asegurados
            WHERE sseguro = psseguro;

      v_pasexec := 42;

      DELETE FROM seguros_assp
            WHERE sseguro = psseguro;

      v_pasexec := 43;

      /*modificació: XCG 05-01-2007 s'afegeixen aquestes dues taules----*/
      DELETE FROM seguros_aho
            WHERE sseguro = psseguro;

/*------------------------------------------------------*/
      v_pasexec := 44;

      /* RSC 16-07-2007*/
      DELETE FROM seguros_ulk
            WHERE sseguro = psseguro;

      v_pasexec := 45;

      DELETE FROM segdisin2
            WHERE sseguro = psseguro;

      v_pasexec := 46;

/*------------------------------------------------------*/
/*JRH  09/2007 Dues taules per a rendes*/
      DELETE FROM seguros_ren
            WHERE sseguro = psseguro;

      v_pasexec := 47;

      DELETE FROM seguros_act
            WHERE sseguro = psseguro;

      v_pasexec := 48;

      /*JRH  03/2008 Rentas irregulares*/
      DELETE FROM planrentasirreg
            WHERE sseguro = psseguro;

      v_pasexec := 50;

      DELETE FROM psucontrolseg
            WHERE sseguro = psseguro;

      v_pasexec := 5002;

      DELETE FROM basequestion_undw
            WHERE sseguro = psseguro;

      DELETE FROM actions_undw
            WHERE sseguro = psseguro;

      DELETE FROM exclusiones_undw
            WHERE sseguro = psseguro;

      DELETE FROM enfermedades_undw
            WHERE sseguro = psseguro;

      v_pasexec := 502;

      DELETE FROM riesgos_ir_ordenes
            WHERE sseguro = psseguro;

      v_pasexec := 503;

      DELETE FROM riesgos_ir
            WHERE sseguro = psseguro;

      v_pasexec := 501;

      DELETE FROM psu_retenidas
            WHERE sseguro = psseguro;

      v_pasexec := 481;

      /* BUG19069:DRA:30/09/2011*/
      DELETE FROM age_corretaje
            WHERE sseguro = psseguro;

      v_pasexec := 49;
      /*JRH 04/2008 Borramos de  per_... por si existen.*/
      v_pasexec := 50;

      /* Convenios*/
      DELETE FROM cnv_conv_emp_seg
            WHERE sseguro = psseguro;

      /* convenios*/

      --IAXIS-13888 --19/05/2020
       -- CONF-108 AP
      DELETE FROM hisagensegu
            WHERE sseguro = psseguro;

      DELETE FROM estagensegu
            WHERE sseguro IN (SELECT sseguro
                                FROM estseguros a
                               WHERE a.ssegpol = psseguro);

      --IAXIS-13888 --19/05/2020
      -- CONF-108 AP
      -- CONF-274-25/11/2016-JLTS- Ini
      DELETE FROM suspensionseg
            WHERE sseguro = psseguro;

      -- CONF-274-25/11/2016-JLTS- Fin
      DELETE FROM docummovseg
            WHERE sseguro = psseguro;

      DELETE FROM segurosredcom
            WHERE sseguro = psseguro;

      DELETE FROM seguredcom
            WHERE sseguro = psseguro;

      DELETE FROM penaliseg
            WHERE sseguro = psseguro;

/*--------*/
      v_pasexec := 52;

      /* **** Esborrat de taules dinàmiques i/o  àtiques ***** (sls)*/
      DELETE FROM tbestdettabla
            WHERE sseguro = psseguro;

      v_pasexec := 53;

      DELETE FROM tbestuserfilas
            WHERE sseguro = psseguro;

      v_pasexec := 54;

      DELETE FROM tbestfilastabla
            WHERE sseguro = psseguro;

      v_pasexec := 55;

      /*- **** Esborrat de taula intermitja de franquícies (NS)*/
      DELETE FROM garanfrqtmp
            WHERE sseguro = psseguro;

      v_pasexec := 56;
      /* borramos el titular del seguro que  amos borrando*/

      /* Mantis 10240.06/2009.NMM.*/
      /*DELETE FROM  planrentasextra
      WHERE sseguro = psseguro;*/
      /* BUG 18351 - 10/05/2011 - JMP - Borrado de las tablas de documentación requerida*/
      v_pasexec := 57;

      DELETE FROM docrequerida
            WHERE sseguro = psseguro;

      v_pasexec := 58;

      DELETE FROM docrequerida_riesgo
            WHERE sseguro = psseguro;

      v_pasexec := 59;

      DELETE FROM docrequerida_inqaval
            WHERE sseguro = psseguro;

      /* FIN BUG 18351 - 10/05/2011 - JMP*/
      v_pasexec := 60;

      /* 19276*/
      DELETE FROM reemplazos
            WHERE sseguro = psseguro;

      /*Bug.: 19152 - 20/11/2011 - ICV*/
      v_pasexec := 61;

      DELETE FROM benespseg
            WHERE sseguro = psseguro;

      /* BUG 0021592 - 08/03/2012 - JMF*/
      v_pasexec := 62;

      DELETE FROM gescobros
            WHERE sseguro = psseguro;

      /* Bug 20893/111636 - 02/05/2012 - AMC*/
      v_pasexec := 63;

      DELETE FROM dir_riesgos
            WHERE sseguro = psseguro;

      v_pasexec := 64;

      /* bug 21657--ETM-05/06/2012*/
      DELETE FROM inquiaval
            WHERE sseguro = psseguro;

      /*fin bug 21657-ETM-05/06/2012*/
      /* BUG 0022701 - 03/09/2012 - JMF*/
      v_pasexec := 65;

      DELETE FROM rtn_convenio
            WHERE sseguro = psseguro;

      v_pasexec := 66;

      DELETE FROM bf_bonfranseg
            WHERE sseguro = psseguro;

      v_pasexec := 67;

      /* Bug INI: 35095/199894 - 06/03/2015 - PRB*/
      DELETE FROM asegurados_innom
            WHERE sseguro = psseguro;

      /* Bug FIN: 35095/199894 - 06/03/2015 - PRB*/
      /*CONVENIOS*/
      DELETE FROM aseguradosmes
            WHERE sseguro = psseguro;

      /*CONVENIOS*/
      v_pasexec := 68;

      DELETE FROM docrequerida_benespseg
            WHERE sseguro = psseguro;

      /* Bug 28263/153355 - 01/10/2013 - AMC*/
      v_pasexec := 69;

      DELETE FROM casos_bpmseg
            WHERE sseguro = psseguro;

      v_pasexec := 70;

      DELETE FROM mandatos_seguros
            WHERE sseguro = psseguro;

      /* Bug 34675/198727 - 24/02/2015 - AMC*/
      DELETE FROM validacargapregtab
            WHERE sseguro = psseguro;

      /* Bug 36596 IGIL   ini*/
      v_pasexec := 71;

      DELETE FROM citamedica_undw
            WHERE sseguro = psseguro;

      /* Bug 36596 IGIL final*/

      -- INI BUG 40927/228750 - 07/03/2016 - JAEG
      DELETE      per_contragarantia
            WHERE scontgar IN (
                     (SELECT p.scontgar
                        FROM per_contragarantia p, ctgar_seguro cs
                       WHERE cs.sseguro = psseguro
                         AND p.scontgar = cs.scontgar));

      --
      DELETE      ctgar_seguro
            WHERE sseguro = psseguro;

      v_pasexec := 39;

      DELETE FROM riesgos
            WHERE sseguro = psseguro;

      DELETE FROM movseguro
            WHERE sseguro = psseguro;

      v_pasexec := 51;

      DELETE FROM seguros
            WHERE sseguro = psseguro;

      -- FIN BUG 40927/228750 - 07/03/2016 - JAEG
      --
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_alctr126.borrar_tablas',
                      v_pasexec,
                      'borrado sseguro' || psseguro,
                      SQLERRM
                     );
   END borrar_tablas;
-- FIN - IAXIS-3200
END pac_alctr126;
/
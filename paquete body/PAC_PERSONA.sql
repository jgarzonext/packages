CREATE OR REPLACE PACKAGE BODY PAC_PERSONA IS
/* Revision:# VJ/xvS/zw5AmZkeQpZrzZw== # */

   /******************************************************************************
    NOMBRE:       PAC_PERSONA
    PROPÓSITO: Funciones para gestionar personas

    REVISIONES:
    Ver        Fecha        Autor       Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        --           XXX         1. Creación del package.
    2.0        18/05/2009   JTS         2. 10074: Modificaciones en el Mantenimiento de Personas
    3.0        09/06/2009   JTS         3. 10371: APR - tipo de empresa
    4.0        02/07/2009   XPL         4. 10339 i 9227, APR - Campos extra en la búsqueda de personas i APR - Error al crear un agente
    5.0        08/09/2009   XPL         5. 10878: CEM - Persona es empleado de la empresa
    6.0        26/03/2010   AMC         6. 0012716: CEM - PPA - Cálculo de IRPF en prestaciones
    7.0        11/05/2010   DRA         7. 0014307: AGA005 - PERSONES: Parametrització inicial del mòdul
    8.0        31/05/2010   JMC         8. 0014055: ENSA001 - Carga tablas maestras, para que tambien tenga en cuenta el ctipide 25 NIF Individual Angola
    9.0        16/06/2010   JMC         9. 0015039: ENSA003 - Precisions sobre els documents a ENSA. Se añade ctipide 26 (Menor Angola).
   10.0        01/10/2010   JMC        10. 0015495: ENSA 003 - Direcciones red comercial, se modifica definición variable vtdomici en función F_TDOMICI
   11.0        15/11/2010   FAL        11. 0014365: CRT002 - Gestion de personas
   12.0        11/10/2010   ETM        12. 0018507: AGA800 : Concatenación de la descripción del domicilio
   13.0        15/06/2011   DRA        13. 0018808: CRE800 - Error en alta compte iban
   14.0        22/07/2011   DRA        14. 0017255: CRT003 - Definir propuestas de suplementos en productos
   15.0        27/07/2011   ICV        15. 0018941: LCOL_P001 - PER - Personas relacionadas. Representante legal
   16.0        13-09-2011   JMF        16. 0019426: Definir producto Transportes Individual para GIP
   17.0        26/09/2011   MDS        17. 0018943  Modulo SARLAFT en el mantenimiento de personas
   18.0        04/10/2011   MDS        18. 0018947: LCOL_P001 - PER - Posición global
   19.0        08/11/2011   JGR        19. 0019985  LCOL_A001-Control de las matriculas (prenotificaciones)
   20.0        21-11-2011   APD        20. 0019587: LCOL_P001 - PER - Validaciones dependiendo del tipo de documento
   21.0        23/11/2011   APD        21. 0018946: LCOL_P001 - PER - Visibilidad en personas
   22.0        23/11/2011   APD        22. 0020126: LCOL_P001 - PER - Documentación en personas
   23.0        14/12/2011   MDS        23. 0020486: LCOL_P001 - PER - Sarlaft
   24.0        29/12/2011   JGR        24. 0020735: Introduccion de cuenta bancaria, indicando tipo de cuenta y banco Nota:102170
   25.0        03/01/2012   APD        25. 0020790: LCOL - UAT - PER - Arreglar errores de personas de entorno UAT
   26.0        10/01/2012   JGR        26. 0020735/0103205 Modificaciones tarjetas y ctas.bancarias
   27.0        08/02/2012   JMP        27. 21270/106644: LCOL898 - Interfase persones. Enviar segon registre amb el RUT
   28.0        13/02/2012   JMP        28. 21270/107049: LCOL898 - Interfase persones. Tractament errors crida a PAC_CON.F_ALTA_PERSONA.
   29.0        29/02/2012   ETM        29. 0021406: MDP - PER - Añadir el nombre en la tabla contactos
   30.0        27/04/2012   MDS        30. 0022053: CALI003 - Parametritzacions / Configuracions erroneas i incidències
   31.0        24/05/2012   ETM        31. 0022355: MDP - PER - Personas Públicas
   32.0        04/07/2012   APD        32. 0022746: LCOL_P001 - PER - Snip SIN informar
   33.0        11/07/2012   ETM        33.0022263: LCOL_P001 - PER - Informaci?n relacionado con documentos identificativos.
   34.0        24/07/2012   ETM        34. 0022642: MDP - PER - Posición global. Inquilinos, avalistas y gestor de cobro
   35.0        10/10/2012   JLTS       35. 0023869: MDP - COM - Contratos, Cambiar en f_get_agentes contratosage por redcomercial
   36.0        20/11/2012   ECP        36. 0024672: LCOL_A003-Domiciliaciones - QT 0005339: Consultas en los aplciativosy validaciones pendientes
   37.0        11/12/2012   ETM        37. 0024780: RSA 701 - Preparar personas para Chile
   38.0        17/12/2012   NMM        38. 23410: MDP - PER - R1 - Ajustes personas.
   39.0        31/01/2013   JDS        39. 0025849: LCOL - PER - Posición global de personas : conductores
   40.0        11/02/2013   DCT        40. 0026057/0137564:LCOL - PER - Atuorizacion de contactos - Relación entre contactos y direcciones
   20.0        25/02/2013   NMM        20. 24497: POS101 - Configuraci?n Rentas Vitalicias
   41.0        12/02/2013   LCF        41. 0025959: RSA - PER - Personas relacionadas
   42.0        05/03/2013   MMS        42. 0024764: (POSDE300)-Desarrollo-GAPS Personas-Id 99 - Funcionario - Creacion . Reodenamos la lista de f_get_parpersona, quitamos la funcion f_get_conductores y la ponemos en PAC_MD_PERSONAS
   43.0        07/05/2013   JGR        43. 0026896: La númeración de las tarjetas VISA empieza pos "4", Master Card por "5".
   44.0        15/05/2013   JGR        44. 0026979: Mensaje de error inapropiado al borrar las cuentas bancarias. QT-0007317 - 0144586
   45.0        07/06/2013   JGR        45. 0027198: El mensaje de error que aparece al borrar una cuenta corriente con "Prenotificación en transito", no es correcto. QT-7319
   46.0        08/07/2013   RCL        46. 0025599: LCOL - PER - Revision incidencias qtracker y Releases
   47.0        12/11/2013   JDS        47. 0028104: LCOL - PER - Fecha de vencimiento tarjeta bancaria - anios anteriores
   48.0        01/10/2013   DCT        48. 0028402  LCOL - PER - El campo país de expedición no queda informado por defecto.
   23.0        10/10/2013   JMG        23. 0155391/0155391: POS - PER - Anotación en la agenda de las pólizas cuando se modifique los datos de un tercero.
   49.0        05/12/2013   RCL        49. 0029268: LCOL - PER - No permitir duplicar la persona en simulación.
   50.0        30/12/2013   dlF        50. 0029015: AGM800 - Moldeo oficial 346 - Error al recuperar los datos del agente.
   51.0        05/02/2014   GGR        51. 27314/164740: Duplicado de registros en la agenda.
   52.0        07/03/2014   ECP        52. 30417/11671: CAMPO CONTACTO TIPO TELEFONO PERMITIR SOLO VALORES NUMERICOS.
   53.0        18/03/2014   GGR        53  26318/167380: Creación de la persona como acreedor para enviarlas por interface a SAP.
   54.0        03/04/2014   FAL        54. 0030525: INT030-Prueba de concepto CONFIANZA
   55.0        02/06/2014   ELP        55  27500:  Nueva operativa de mandatos
   56.0        01/07/2014   GGR        56  27314/178602  Comprobación cuenta correo y tratamiento personas gubernamentales
   57.0        15/07/2014   GGR        57  27314/179831  Excluye el envío al interface cuando trata las tablas EST. Funcion (f_ins_parpersona)
   58.0        20/08/2014   GGR        58  27314/182070  Se añade exceptión para cuando un sperson tiene asignado más de un codigo de agente.
   59.0        14/10/2014   MMS        59. 0031135: Montar Entorno Colmena en VAL
   60.0        17/03/2015   KJSC       60. 34989/200761 Modificacion de la funcion f_set_nacionalidad.
   61.0        21/05/2015   CJMR       61. 35888/205345 Realizar la substitución del upper nnumnif o nnumide
   62.0        27/07/2015   JCP        62.34989/0210873. Modificar las vistas 'estcontactos' y 'contactos' para recoger el nuevo campo de la tabla ESTPER_CONTACTOS y PER_CONTACTOS CPREFIX.
   63.0        26/04/2016   VCG        63. 41414/233618 Cuando se elimina una dirección que tiene relación con otra sección, no debería permitir borrar dicha dirección
   64.0        23/06/2016   ERH        64. CONF-52 Modificación de la función f_set_persona_rel se adiciona al final el parametro • PTLIMIT VARCHAR2
   65.0        15/12/2017   ACL        65. CONF-564: Se agrega condición para el ctipide 96 en f_validanif.
   66.0        18/04/2018   VCG        66. 0001941: Cobro de IVA para personas exentas de IVA
   67.0        02/11/2018   ACL        67. Ajuste al 42% aceptación personas. Se ajusta la función f_set_contacto.
   68.0        21/11/2018   ACL        68. 00643 Spring1 - Se modifica la función f_get_parpersona, para el listado solicitado de la sección propiedades.
   69.0        23/11/2018   ACL        69. CP0727M_SYS_PERS_Val - Se modifica las funciones f_get_datsarlatf y f_set_datsarlatf agregando el campo corigenfon.
   70.0        30/11/2018   ACL        70. CP0036M_SYS_PERS - Se modifica la función f_validanif para la condición en f_validar_nif_col, con el tipo de identificación 93.
   71.0        18/12/2018   ACL        71. CP0416M_SYS_PERS Se agrega la función f_get_persona_sarlaf.
   72.0        16/12/2018   ACL        72. CP0416M_SYS_PERS Se agrega a la función f_get_persona_sarlaf, convertir los campos de las fechas a String para que sean leidas por la función del service.
   73.0      07/01/2019   SWAPNIL    73. Cambios para solicitudes múltiples
   74.0        17/01/2019   AP       74. TCS 468A 17/01/2019 AP Se modifica funcion f_set_persona_rel Consorcios y Uniones Temporales
   75.0        29/01/2019   AP         75. CP0615M_SYS_PERS Creacion de secuencia para datos Sarlaft
   76.0        01/02/2019   DFR        76. TCS-460: Funcionalidad para el manejo de pagadores alternativos.
   77.0      30/01/2019   SWAPNIL    77. Cambios para enviar error : start
   78.0        30/01/2019   WAJ        78. Se adiciona funcion para eliminar los indicadores de una persona
   79.0        11/02/2019   ACL        79. Se modifica la función f_get_persona_sarlaf, agregando campos en la consulta.
   80.0        12/02/2019  AABC        80. TC464 Actualización de f_set_persona para sperson_deud y sperson_acre
   81.0        12/02/2019   AP         81. TCS-9: Se adiciona campos en la funcion f_set_datsarlatf para clausulas.
   82.0        21/02/2019   ACL        82. TCS_1560 Se agrega formato a fechas en la funci¿n  f_get_datsarlatf.
   83.0        19/02/2019   CJMR       82. TCS-344: Nueva funcionalidad de marcas
   84.0        27/02/2019   AABC       84. IAXIS-2091 Convivencia pagador Alternativo TCS 1560
   85.0        28/02/2019   CES-WAJ    85. TCS1554 Convivencia Personas (Encabezado y Detalles)
   86.0      08/03/2019   Swapnil    86. Cambios para IAXIS-2015
   87.0        09/03/2019   CES        87. Ajuste Incidencia URL CONTACTOS IAXIS-3241
   88.0      21/03/2019  Swapnil     88. Cambios de IAXIS-3286
   89.0        01/04/2019   DFRP       89. IAXIS-3287:FCC (Formulario de Conocimiento de Cliente).
   90.0        09/04/2019   CES        90. Ajuste atributo de consorcios   
   91.0      30/04/2019 SWAPNIL    91. Cambios de IAXIS-3562
   92.0        24/05/2019   CES      92. IAXIS-4061: Ajuste modificación URL contacto personas.
   93.0        13/06/2019   ECP        93. IAXIS-3981. Marcas Integrantes Consorcios y Uniones Temporales
   94.0      25/06/2019 SWAPNIL    94. Cambios de Iaxis-4521
   95.0        27/06/2019   KK       95. CAMBIOS De IAXIS-4538
   96.0        06/07/2019   ECP        96. IAXIS-4212. Depuraciòn Manual
   97.0        05/07/2019   PK         97. Cambios de IAXIS-4728: Registros Sección Régimen Fiscal Personas
   98.0        18/07/2019   PK    98. Added function for IAXIS-4149 - Modificación Cuentas Bancarias
   99.0        19/07/2019   PK    99. Cambio de IAXIS-4844 - Optimizar Petición Servicio I017
   100.0       09/09/2019  DFRP   100. IAXIS-4832(7): Refinamiento revision final  
   101.0       26/12/2019  JRVG     101. IAXIS-7735 Pagadores Alternativos
   102.0       20/02/2020  JRVG     102.0 IAXIS-7629 Cargue VidaGrupo - modificacion Funcion f_set_Persona
   103.0       18/03/2020   SP      103.0 Cambios para tarea IAXIS-13044
   104.0       25/03/2020  ECP      104. IAXIS-13233. Funcionalidad Grupos Econ�micas
   105.0	   18/05/2020   SP      105 Cambios de IAXIS-13006
   ******************************************************************************/
   e_object_error EXCEPTION; -- IAXIS-3287 01/04/2019
   e_param_error  EXCEPTION; -- IAXIS-3287 01/04/2019
   ----------------------------------------------------------------------------------------
   PROCEDURE borrar_tablas_estpereal(
      pspereal IN per_personas.sperson%TYPE,
      psseguro IN estseguros.sseguro%TYPE) IS
      CURSOR cur_per IS
         SELECT sperson
           FROM estper_personas
          WHERE spereal = pspereal
            AND sseguro = psseguro;
   BEGIN
      FOR reg IN cur_per LOOP
         pac_persona.borrar_tablas_estper(reg.sperson);
      END LOOP;
   END borrar_tablas_estpereal;

   PROCEDURE borrar_tablas_estper_seg(psseguro IN estseguros.sseguro%TYPE) IS
      CURSOR cur_per IS
         SELECT sperson
           FROM estper_personas
          WHERE sseguro = psseguro;
   BEGIN
      FOR reg IN cur_per LOOP
         pac_persona.borrar_tablas_estper(reg.sperson);
      END LOOP;
   END borrar_tablas_estper_seg;

   PROCEDURE borrar_tablas_estper(
      psperson IN estper_personas.sperson%TYPE,
      psimul IN NUMBER DEFAULT NULL) IS
      vcont          NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcont
        FROM estper_personas ep, estseguros s
       WHERE ep.sperson = psperson
         AND s.sseguro = ep.sseguro
         AND s.csituac = 7;

      /*borrem la persona si no ve de simulacions o bé si es de simulacions i anem a borra expresament les persones de simulacions (psimul = 1)*/
      IF vcont = 0
         OR(vcont > 0
            AND psimul = 1) THEN
         DELETE FROM estper_irpfmayores
               WHERE sperson = psperson;

         DELETE FROM estper_irpfdescen
               WHERE sperson = psperson;

         DELETE FROM estper_irpf
               WHERE sperson = psperson;

         DELETE FROM estper_lopd
               WHERE sperson = psperson;

         DELETE FROM estper_vinculos
               WHERE sperson = psperson;

         DELETE FROM estper_contactos
               WHERE sperson = psperson;

         DELETE FROM estper_direcciones
               WHERE sperson = psperson;

         DELETE FROM estper_ccc
               WHERE sperson = psperson;

         /* RSA mandatos BUG 27500*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'INS_MANDATO'),
                0) = 1 THEN
            DELETE FROM estmandatos
                  WHERE sperson = psperson;
         END IF;

         /*JRH 05/2008 identificadores*/
         DELETE FROM estper_identificador
               WHERE sperson = psperson;

         /*JRH 05/2008*/
         DELETE FROM estper_nacionalidades
               WHERE sperson = psperson;

         /* Bug 11468 - 03/11/2009 - AMC*/
         DELETE FROM estper_parpersonas
               WHERE sperson = psperson;

         /*Fi Bug 11468 - 03/11/2009 - AMC*/
         DELETE FROM estper_detper
               WHERE sperson = psperson;

         DELETE FROM estper_personas
               WHERE sperson = psperson;

         DELETE FROM estper_regimenfiscal
               WHERE sperson = psperson;

         /* Bug 25542 - APD - 10/01/2013*/
         DELETE FROM estper_antiguedad
               WHERE sperson = psperson;

         /* fin Bug 25542 - APD - 10/01/2013*/
           /* JLB - I _ 18/02/2014*/
         DELETE FROM estper_cargas
               WHERE sperson = psperson;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'BORRAR_TABLAS_ESTPER. Error .  SPERSON = ' || psperson, SQLERRM);
   END borrar_tablas_estper;

/*-------------------------------------------------------------------------------------------------------*/
/* Función que sirve para traspasar los datos de personas de las tablas ESTUDIO a las tablas REALES*/
/* 09-07-2008*/
/*-------------------------------------------------------------------------------------------------------*/
   PROCEDURE traspaso_tablas_estper(
      psperson IN estper_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcempres IN empresas.cempres%TYPE) IS
      /*
          Traspasamo de las tablas "EST" a las "NORMALES"
          en este procedimiento no se puede borrar la cabecera, el detalle y dirección,
          se modificarán en el caso de que exista.
      */
      vsperson_new   per_personas.sperson%TYPE;
      num_err        NUMBER := 0;
      vtraza         NUMBER := 0;
      /* vcagente       AGENTES.CAGENTE%TYPE;*/
      vswpubli       per_personas.swpubli%TYPE;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcagente_det   agentes.cagente%TYPE;
      vcdefecto      NUMBER(1);
      /* Bug 14365. FAL. 15/11/2010*/
      vcterminal     usuarios.cterminal%TYPE;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      waccion        VARCHAR2(50);
      vcambio        NUMBER := 1;
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;   /* Cambios de IAXIS-4844 PK-19/07/2019 */
      /* Fi Bug 14365*/
      /*- cursores de borrado*/
      CURSOR cur_borrar_irpf(pc_spereal IN NUMBER) IS
         SELECT *
           FROM per_irpf c
          WHERE NOT EXISTS(SELECT cc.sperson
                             FROM estper_irpf cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND c.nano = cc.nano
                              AND c.cagente = cc.cagente
                              /* DRA 29-9-08: bug mantis 7567*/
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* Bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      CURSOR cur_borrar_irpfmayores(pc_spereal IN NUMBER) IS
         SELECT *
           FROM per_irpfmayores c
          WHERE NOT EXISTS(SELECT cc.sperson
                             FROM estper_irpfmayores cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.norden = c.norden
                              AND cc.nano = c.nano
                              AND cc.cagente = c.cagente
                              /* DRA 29-9-08: bug mantis 7567*/
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      CURSOR cur_borrar_irpfdescen(pc_spereal IN NUMBER) IS
         SELECT *
           FROM per_irpfdescen c
          WHERE NOT EXISTS(SELECT cc.sperson
                             FROM estper_irpfdescen cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.norden = c.norden
                              AND cc.nano = c.nano
                              AND cc.cagente = c.cagente
                              /* DRA 29-9-08: bug mantis 7567*/
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      CURSOR cur_borrar_vin(pc_spereal IN NUMBER) IS
         SELECT sperson, cvinclo, cagente
           FROM per_vinculos c
          WHERE NOT EXISTS(SELECT cc.sperson, cc.cvinclo
                             FROM estper_vinculos cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.cagente = c.cagente
                              AND cc.cvinclo = c.cvinclo
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      CURSOR cur_borrar_cont(pc_spereal IN NUMBER) IS
         SELECT sperson, cmodcon, cagente, cprefix
           FROM per_contactos c
          WHERE NOT EXISTS(SELECT cc.sperson, cc.cmodcon, cc.cprefix
                             FROM estper_contactos cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.cmodcon = c.cmodcon
                              AND cc.cagente = c.cagente
                              /* DRA 29-9-08: bug mantis 7567*/
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      CURSOR cur_borrar_direcc(pc_spereal IN NUMBER) IS
         SELECT sperson, cdomici, cagente
           FROM per_direcciones c
          WHERE NOT EXISTS(SELECT 1
                             FROM estper_direcciones cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.cdomici = c.cdomici
                              AND cc.cagente = c.cagente
                              /* DRA 29-9-08: bug mantis 7567*/
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      CURSOR cur_borrar_lopd(pc_spereal IN NUMBER) IS
         SELECT sperson
           FROM per_lopd c
          WHERE NOT EXISTS(SELECT 1
                             FROM estper_lopd cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal;

      CURSOR cur_borrar_detper(pc_spereal IN NUMBER) IS
         SELECT sperson, cagente
           FROM per_detper c
          WHERE NOT EXISTS(SELECT 1
                             FROM estper_detper cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.cagente = c.cagente
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      /*JRH 04/2008*/
      CURSOR cur_borrar_ccc(pc_spereal IN NUMBER) IS
         SELECT sperson, cnordban, cagente
           FROM per_ccc c
          WHERE NOT EXISTS(SELECT 1
                             FROM estper_ccc cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.cnordban = c.cnordban
                              AND cc.cagente = c.cagente
                              /* DRA 29-9-08: bug mantis 7567*/
                              AND cc.sperson = psperson)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      CURSOR cur_borrar_per(pc_spereal IN NUMBER) IS
         SELECT sperson
           FROM per_personas c
          WHERE c.sperson = pc_spereal
            AND 0 = (SELECT COUNT(1)
                       FROM per_detper
                      WHERE sperson = c.sperson);

      /* Borramos solo cuando no tenga detalles.*/
      /*NOT EXISTS (*/
      /*                   SELECT 1*/
      /*-                     FROM estper_personas cc*/
      /*                    WHERE (cc.spereal = c.sperson OR cc.spereal IS NULL)*/
      /*                      AND cc.sperson = psperson)*/
      /*           ;*/
      CURSOR cur_borrar_nacionalidades(pc_spereal IN NUMBER) IS
         SELECT sperson, cagente, cpais
           FROM per_nacionalidades c
          WHERE NOT EXISTS(SELECT 1
                             FROM estper_nacionalidades cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.cagente = c.cagente
                              AND cc.cpais = c.cpais)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      /* bug 7873 -- AND c.cagente = NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      CURSOR cur_borrar_identificadores(pc_spereal IN NUMBER) IS
         SELECT sperson, cagente, ctipide
           FROM per_identificador c
          WHERE NOT EXISTS(SELECT 1
                             FROM estper_identificador cc, estper_personas pp
                            WHERE (pp.spereal = c.sperson
                                   OR pp.spereal IS NULL)
                              AND pp.sperson = cc.sperson
                              AND cc.cagente = c.cagente
                              AND cc.ctipide = c.ctipide)
            AND c.sperson = pc_spereal
            AND c.cagente = vcagente_per;

      --INI BUG CONF-186  Fecha (22/08/2016) - HRE - proceso de marcas
      CURSOR cur_lista_clinton(psperson per_personas.sperson%TYPE) IS
      SELECT COUNT(0)
        FROM per_personas a
       WHERE sperson = psperson
         AND EXISTS (SELECT 'x'
                       FROM lre_personas  b
                      WHERE a.sperson = b.sperson
                        AND b.ctiplis = 5);


      CURSOR cur_lista_peps(psperson per_personas.sperson%TYPE) IS
      SELECT COUNT(0)
        FROM per_personas a
       WHERE sperson = psperson
         AND EXISTS (SELECT 'x'
                       FROM lre_personas  b
                      WHERE a.sperson = b.sperson
                        AND b.ctiplis = 45);

      v_clinton NUMBER;
      v_peps    NUMBER;
      --FIN BUG CONF-186  - Fecha (22/08/2016) - HRE
      /* bug 7873 -- NVL (pcagente, c.cagente);  -- DRA 29-9-08: bug mantis 7567*/
      sw_envio_rut   NUMBER(1);
   BEGIN
      vtraza := 1;
      pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per, 'EST');

      /*DCT 16/05/2007 Cambiamos reg.sperson por reg.spereal.*/
      /* insertamos en las tablas*/
      FOR reg IN (SELECT sperson, nnumide, nordide, ctipide, csexper, fnacimi, cestper,
                         fjubila, ctipper, cusuari, fmovimi, cmutualista, spereal, fdefunc,
                         snip, corigen, tdigitoide
                    /* Bug 14365. FAL. 15/11/2010*/
                  FROM   estper_personas
                   WHERE sperson = psperson) LOOP
         IF reg.spereal IS NULL THEN
            /* svj. Si no esta informado este campo significa que es una alta nueva*/
            /* Comprobamos si existe una persona en las tablas per_personas con el mismo nnumide-fnacimi-sexo*/
            /* Si existe consideramos que es la misma persona y devolvemos en la variable  vsperson_new el sperson de per_personas.sperson*/
              /* Si NO existe creamos un nuevo sperson de la secuencia buena.*/
            num_err := f_existe_persona(pcempres, reg.nnumide, reg.csexper, reg.fnacimi,
                                        vsperson_new, reg.snip, NULL, reg.ctipide);

            IF num_err = 0 THEN
               vsperson_new := NVL(vsperson_new, pac_persona.f_sperson);
            END IF;
         ELSE
            vsperson_new := reg.spereal;
         END IF;

         --INI BUG CONF-186  Fecha (22/08/2016) - HRE - proceso de marcas
         OPEN  cur_lista_clinton(vsperson_new);
         FETCH cur_lista_clinton INTO v_clinton;
         CLOSE cur_lista_clinton;

         IF (v_clinton > 0 ) THEN
            num_err := pac_marcas.f_set_marca_automatica(pcempres,
                                  vsperson_new,
                                  '0050');
         END IF;

         OPEN  cur_lista_peps(vsperson_new);
         FETCH cur_lista_peps INTO v_peps;
         CLOSE cur_lista_peps;

         IF (v_peps > 0 ) THEN
           num_err := pac_marcas.f_set_marca_automatica(pcempres,
                                  vsperson_new,
                                  '0041');
         END IF;
         --FIN BUG CONF-186  - Fecha (22/08/2016) - HRE

         vtraza := 2;

         /* BUG 21270/106644 - 08/02/2012 - JMP - Comprobamos si es la primera vez que se informa el TDIGITOIDE*/
         IF reg.tdigitoide IS NOT NULL THEN
            BEGIN
               SELECT DECODE(tdigitoide, NULL, 1, 0)
                 INTO sw_envio_rut
                 FROM per_personas
                WHERE sperson = vsperson_new;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  sw_envio_rut := 1;
            END;
         END IF;

         /* FIN BUG 21270/106644 - 08/02/2012 - JMP - Comprobamos si es la primera vez que se informa el TDIGITOIDE*/
         BEGIN
            /*DCT 15/05/2007 Ponemos en la columna SPERSON la secuencia real*/
            /* Insertamos la persona como no pública !! siempre por defecto*/
            /* Bug 22746 - APD - 04/07/2012 - se modifica reg.cestper por*/
                /* DECODE(reg.cestper,99,0,reg.cestper)*/
            INSERT INTO per_personas
                        (sperson, nnumide, nordide, ctipide,
                         csexper, fnacimi,
                         cestper, fjubila,
                         ctipper, cusuari, fmovimi,
                         cmutualista, fdefunc, snip, swpubli, tdigitoide,
             sperson_deud , sperson_acre ) --TC 464 AABC 08/02/2019 sperson para deudor y acreedor  V 80
                 VALUES (vsperson_new, reg.nnumide, reg.nordide, reg.ctipide,
                         DECODE(reg.ctipper, 2, NULL, reg.csexper), /*Bug 29738/166356 - 17/02/2013 - AMC*/ reg.fnacimi,
                         DECODE(reg.cestper, 99, 0, reg.cestper), reg.fjubila,
                         DECODE(reg.ctipper, 99, 0, reg.ctipper), reg.cusuari, reg.fmovimi,
                         reg.cmutualista, reg.fdefunc, reg.snip, 0, reg.tdigitoide,
                         vsperson_new , vsperson_new ); --TC 464 AABC 08/02/2019 sperson para deudor y acreedor  V 80

            /* Bug 22746 - APD - 04/07/2012*/
            waccion := 'INSERT';   -- Bug 14365. FAL. 15/11/2010
            vswpubli := 0;   /* No es pública*/
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               IF vcambio <> 0 THEN
                  SELECT COUNT(1)
                    INTO vcambio
                    FROM per_personas
                   WHERE sperson = vsperson_new
                     AND(nordide = reg.nordide
                         OR(nordide IS NULL
                            AND reg.nordide IS NULL))
                     AND(ctipide = reg.ctipide
                         OR(ctipide IS NULL
                            AND reg.ctipide IS NULL))
                     AND(csexper = reg.csexper
                         OR(csexper IS NULL
                            AND reg.csexper IS NULL))
                     AND(fnacimi = reg.fnacimi
                         OR(fnacimi IS NULL
                            AND reg.fnacimi IS NULL))
                     AND(cestper = reg.cestper
                         OR(cestper IS NULL
                            AND reg.cestper IS NULL))
                     AND(fjubila = reg.fjubila
                         OR(fjubila IS NULL
                            AND reg.fjubila IS NULL))
                     AND(ctipper = reg.ctipper
                         OR(ctipper IS NULL
                            AND reg.ctipper IS NULL))
                     /* AND (cusuari = reg.cusuari or (cusuari is null and reg.cusuari is null))*/
                     /* AND (fmovimi = reg.fmovimi or (fmovimi is null and reg.fmovimi is null))*/
                     AND(cmutualista = reg.cmutualista
                         OR(cmutualista IS NULL
                            AND reg.cmutualista IS NULL))
                     AND(fdefunc = reg.fdefunc
                         OR(fdefunc IS NULL
                            AND reg.fdefunc IS NULL))
                     AND(snip = reg.snip
                         OR(snip IS NULL
                            AND reg.snip IS NULL))
                     AND(tdigitoide = reg.tdigitoide
                         OR(tdigitoide IS NULL
                            AND reg.tdigitoide IS NULL));
               END IF;

               UPDATE per_personas
                  SET nordide = reg.nordide,
                      ctipide = reg.ctipide,
                      csexper = reg.csexper,
                      fnacimi = reg.fnacimi,
                      cestper = reg.cestper,
                      fjubila = reg.fjubila,
                      ctipper = reg.ctipper,
                      cusuari = reg.cusuari,
                      fmovimi = reg.fmovimi,
                      cmutualista = reg.cmutualista,
                      fdefunc = reg.fdefunc,
                      snip = reg.snip,
                      tdigitoide = reg.tdigitoide
                WHERE sperson = vsperson_new;

               waccion := 'UPDATE';   -- Bug 14365. FAL. 15/11/2010

               SELECT swpubli, cagente
                 INTO vswpubli, vcagente_det   /* Es pública ?? 1:Pública, 0:No pública*/
                 FROM per_personas
                WHERE sperson = vsperson_new;

               IF vswpubli = 1 THEN
                  vcagente_per := vcagente_det;
               END IF;
         END;

         vtraza := 29999;

         /* Modificamos la estpersonas para saber que sperson real hemos creado.*/
         UPDATE estper_personas
            SET spereal = vsperson_new
          WHERE sperson = reg.sperson;

         vtraza := 3;
         /* si la persona es pública, buscamos el código del agente que la dio de alta,*/
         /* Si todo esta bien esta select no puede petar, ya que si es pública tiene que existir en las tablas reales*/
         /* y solo puede haber un registro.*/
         /*Bug 29166/160004 - 29/11/2013 - AMC*/
         /*  IF vswpubli = 1 THEN
              SELECT cagente
                INTO vcagente_per
                FROM per_detper
               WHERE sperson = vsperson_new;
           -- BUG 7873       ELSE
           --            -- DRA 29-9-08: Lo ponemos a NULL para que en los inserts utilice el de las tablas EST
           --            vcagente := NULL;
           END IF;*/
         /*Fi Bug 29166/160004 - 29/11/2013 - AMC*/
         vtraza := 39999;

/*-----------------------*/
/* insertamos el detalle de la persona.*/
/*-----------------------*/
         FOR reg1 IN (SELECT *
                        FROM estper_detper
                       WHERE sperson = psperson
                         AND cagente = vcagente_per
                                                   /* bug 7873 -- NVL (pcagente, cagente)  -- DRA 29-9-08: bug mantis 7567*/
                    ) LOOP
            BEGIN
               INSERT INTO per_detper
                           (sperson, cagente, cidioma, tapelli1,
                            tapelli2, tnombre, tsiglas, cprofes,
                            tbuscar, cestciv,
                            cpais, cusuari, fmovimi, tnombre1,
                            tnombre2,
                            cocupacion /* Bug 25456/136037 - 23/01/2013 - AMC*/)
                    VALUES (vsperson_new, reg1.cagente, reg1.cidioma, reg1.tapelli1,
                            reg1.tapelli2, reg1.tnombre, reg1.tsiglas, reg1.cprofes,
                            reg1.tbuscar, DECODE(reg.ctipper, 2, NULL, reg1.cestciv),   /*Bug 29738/166356 - 17/02/2013 - AMC*/
                            reg1.cpais, reg1.cusuari, reg1.fmovimi, reg1.tnombre1,
                            reg1.tnombre2,
                            reg1.cocupacion /* Bug 25456/136037 - 23/01/2013 - AMC*/);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  IF vcambio <> 0 THEN
                     SELECT COUNT(1)
                       INTO vcambio
                       FROM per_detper
                      WHERE sperson = vsperson_new
                        AND(cagente = reg1.cagente
                            OR(cagente IS NULL
                               AND reg1.cagente IS NULL))
                        AND(cidioma = reg1.cidioma
                            OR(cidioma IS NULL
                               AND reg1.cidioma IS NULL))
                        AND(tapelli1 = reg1.tapelli1
                            OR(tapelli1 IS NULL
                               AND reg1.tapelli1 IS NULL))
                        AND(tapelli2 = reg1.tapelli2
                            OR(tapelli2 IS NULL
                               AND reg1.tapelli2 IS NULL))
                        AND(tnombre = reg1.tnombre
                            OR(tnombre IS NULL
                               AND reg1.tnombre IS NULL))
                        AND(tnombre1 = reg1.tnombre1
                            OR(tnombre1 IS NULL
                               AND reg1.tnombre1 IS NULL))
                        AND(tnombre2 = reg1.tnombre2
                            OR(tnombre2 IS NULL
                               AND reg1.tnombre2 IS NULL))
                        AND(tsiglas = reg1.tsiglas
                            OR(tsiglas IS NULL
                               AND reg1.tsiglas IS NULL))
                        AND(cprofes = reg1.cprofes
                            OR(cprofes IS NULL
                               AND reg1.cprofes IS NULL))
                        AND(tbuscar = reg1.tbuscar
                            OR(tbuscar IS NULL
                               AND reg1.tbuscar IS NULL))
                        AND(cestciv = reg1.cestciv
                            OR(cestciv IS NULL
                               AND reg1.cestciv IS NULL))
                        AND(cpais = reg1.cpais
                            OR(cpais IS NULL
                               AND reg1.cpais IS NULL))
                        /*AND (cusuari = reg1.cusuari or (cusuari is null and reg1.cusuari is null))*/
                        /*AND (fmovimi = reg1.fmovimi or (fmovimi is null and reg1.fmovimi is null))*/
                        AND(cocupacion = reg1.cocupacion
                            OR(cocupacion IS NULL
                               AND reg1.cocupacion IS NULL))   /* Bug 25456/136037 - 23/01/2013 - AMC*/
                                                            ;
                  END IF;

                  UPDATE per_detper
                     SET cidioma = reg1.cidioma,
                         tapelli1 = reg1.tapelli1,
                         tapelli2 = reg1.tapelli2,
                         tnombre = reg1.tnombre,
                         tnombre1 = reg1.tnombre1,
                         tnombre2 = reg1.tnombre2,
                         tsiglas = reg1.tsiglas,
                         cprofes = reg1.cprofes,
                         tbuscar = reg1.tbuscar,
                         cestciv = DECODE(reg.ctipper, 2, NULL, reg1.cestciv),
                         /*Bug 29738/166356 - 17/02/2013 - AMC ,*/
                         cpais = reg1.cpais,
                         cusuari = reg1.cusuari,
                         fmovimi = reg1.fmovimi,
                         cocupacion = reg1.cocupacion
                   /* Bug 25456/136037 - 23/01/2013 - AMC*/
                  WHERE  sperson = vsperson_new
                     AND cagente = reg1.cagente;


            END;

            /* insertamos las direcciones*/
            /* ini jtg*/
            /* con CORIGEN nulo*/
            FOR reg3 IN (SELECT *
                           FROM estper_direcciones
                          WHERE sperson = psperson
                            AND cagente = reg1.cagente
                            AND ctipdir != 99
                            /* Las de simulación no se traspasan*/
                            AND(corigen IS NULL
                                OR corigen != 'INT')) LOOP
               /* Bug 18940/92686 - 27/09/2011 - AMC*/
               BEGIN
                  INSERT INTO per_direcciones
                              (sperson, cagente, cdomici, ctipdir,
                               csiglas, tnomvia, nnumvia, tcomple,
                               tdomici, cpostal, cpoblac, cprovin,
                               cusuari, fmovimi, cviavp, clitvp,
                               cbisvp, corvp, nviaadco, clitco,
                               corco, nplacaco, cor2co, cdet1ia,
                               tnum1ia, cdet2ia, tnum2ia, cdet3ia,
                               tnum3ia, localidad, talias)  -- BUG CONF-441 - 14/12/2016 - JAEG
                       VALUES (vsperson_new, reg3.cagente, reg3.cdomici, reg3.ctipdir,
                               reg3.csiglas, reg3.tnomvia, reg3.nnumvia, reg3.tcomple,
                               reg3.tdomici, reg3.cpostal, reg3.cpoblac, reg3.cprovin,
                               reg3.cusuari, reg3.fmovimi, reg3.cviavp, reg3.clitvp,
                               reg3.cbisvp, reg3.corvp, reg3.nviaadco, reg3.clitco,
                               reg3.corco, reg3.nplacaco, reg3.cor2co, reg3.cdet1ia,
                               reg3.tnum1ia, reg3.cdet2ia, reg3.tnum2ia, reg3.cdet3ia,
                               reg3.tnum3ia, reg3.localidad, reg3.talias);  -- BUG CONF-441 - 14/12/2016 - JAEG

               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_direcciones
                         WHERE sperson = vsperson_new
                           AND(cdomici = reg3.cdomici
                               OR(cdomici IS NULL
                                  AND reg3.cdomici IS NULL))
                           AND(cagente = reg3.cagente
                               OR(cagente IS NULL
                                  AND reg3.cagente IS NULL))
                           AND(ctipdir = reg3.ctipdir
                               OR(ctipdir IS NULL
                                  AND reg3.ctipdir IS NULL))
                           AND(csiglas = reg3.csiglas
                               OR(csiglas IS NULL
                                  AND reg3.csiglas IS NULL))
                           AND(tnomvia = reg3.tnomvia
                               OR(tnomvia IS NULL
                                  AND reg3.tnomvia IS NULL))
                           AND(nnumvia = reg3.nnumvia
                               OR(nnumvia IS NULL
                                  AND reg3.nnumvia IS NULL))
                           AND(tcomple = reg3.tcomple
                               OR(tcomple IS NULL
                                  AND reg3.tcomple IS NULL))
                           AND(tdomici = reg3.tdomici
                               OR(tdomici IS NULL
                                  AND reg3.tdomici IS NULL))
                           AND(cpostal = reg3.cpostal
                               OR(cpostal IS NULL
                                  AND reg3.cpostal IS NULL))
                           AND(cpoblac = reg3.cpoblac
                               OR(cpoblac IS NULL
                                  AND reg3.cpoblac IS NULL))
                           AND(cprovin = reg3.cprovin
                               OR(cprovin IS NULL
                                  AND reg3.cprovin IS NULL))
                           /*AND (cusuari = reg3.cusuari or (cusuari is null and reg3.cusuari is null))*/
                           /*AND (fmovimi = reg3.fmovimi or (fmovimi is null and reg3.fmovimi is null))*/
                           AND(cviavp = reg3.cviavp
                               OR(cviavp IS NULL
                                  AND reg3.cviavp IS NULL))
                           AND(clitvp = reg3.clitvp
                               OR(clitvp IS NULL
                                  AND reg3.clitvp IS NULL))
                           AND(cbisvp = reg3.cbisvp
                               OR(cbisvp IS NULL
                                  AND reg3.cbisvp IS NULL))
                           AND(corvp = reg3.corvp
                               OR(corvp IS NULL
                                  AND reg3.corvp IS NULL))
                           AND(nviaadco = reg3.nviaadco
                               OR(nviaadco IS NULL
                                  AND reg3.nviaadco IS NULL))
                           AND(clitco = reg3.clitco
                               OR(clitco IS NULL
                                  AND reg3.clitco IS NULL))
                           AND(corco = reg3.corco
                               OR(corco IS NULL
                                  AND reg3.corco IS NULL))
                           AND(nplacaco = reg3.nplacaco
                               OR(nplacaco IS NULL
                                  AND reg3.nplacaco IS NULL))
                           AND(cor2co = reg3.cor2co
                               OR(cor2co IS NULL
                                  AND reg3.cor2co IS NULL))
                           AND(cdet1ia = reg3.cdet1ia
                               OR(cdet1ia IS NULL
                                  AND reg3.cdet1ia IS NULL))
                           AND(tnum1ia = reg3.tnum1ia
                               OR(tnum1ia IS NULL
                                  AND reg3.tnum1ia IS NULL))
                           AND(cdet2ia = reg3.cdet2ia
                               OR(cdet2ia IS NULL
                                  AND reg3.cdet2ia IS NULL))
                           AND(tnum2ia = reg3.tnum2ia
                               OR(tnum2ia IS NULL
                                  AND reg3.tnum2ia IS NULL))
                           AND(cdet3ia = reg3.cdet3ia
                               OR(cdet3ia IS NULL
                                  AND reg3.cdet3ia IS NULL))
                           AND(localidad = reg3.localidad
                               OR(localidad IS NULL
                                  AND reg3.localidad IS NULL))
                           AND(tnum3ia = reg3.tnum3ia
                               OR(tnum3ia IS NULL
                                  AND reg3.tnum3ia IS NULL));
                     END IF;

                     UPDATE per_direcciones
                        SET ctipdir = reg3.ctipdir,
                            csiglas = reg3.csiglas,
                            tnomvia = reg3.tnomvia,
                            nnumvia = reg3.nnumvia,
                            tcomple = reg3.tcomple,
                            tdomici = reg3.tdomici,
                            cpostal = reg3.cpostal,
                            cpoblac = reg3.cpoblac,
                            cprovin = reg3.cprovin,
                            cusuari = reg3.cusuari,
                            fmovimi = reg3.fmovimi,
                            cviavp = reg3.cviavp,
                            clitvp = reg3.clitvp,
                            cbisvp = reg3.cbisvp,
                            corvp = reg3.corvp,
                            nviaadco = reg3.nviaadco,
                            clitco = reg3.clitco,
                            corco = reg3.corco,
                            nplacaco = reg3.nplacaco,
                            cor2co = reg3.cor2co,
                            cdet1ia = reg3.cdet1ia,
                            tnum1ia = reg3.tnum1ia,
                            cdet2ia = reg3.cdet2ia,
                            tnum2ia = reg3.tnum2ia,
                            cdet3ia = reg3.cdet3ia,
                            tnum3ia = reg3.tnum3ia,
                            localidad = reg3.localidad,
          talias = reg3.talias  -- BUG CONF-441 - 14/12/2016 - JAEG
                      WHERE sperson = vsperson_new
                        AND cdomici = reg3.cdomici
                        AND cagente = reg3.cagente;
               /* DRA 29-9-08: bug mantis 7567*/

               END;
            /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
            END LOOP;

            /* con CORIGEN = 'INT'*/
            FOR reg3 IN (SELECT d.*
                           FROM estper_personas p, estper_direcciones d, esttomadores t
                          WHERE p.sperson = psperson
                            AND t.sseguro = p.sseguro
                            AND t.sperson = p.sperson
                            AND d.sperson = t.sperson
                            AND d.cdomici = t.cdomici
                            AND d.ctipdir != 99
                            /* Las de simulación no se traspasan*/
                            AND d.corigen = 'INT') LOOP
               /* Bug 18940/92686 - 27/09/2011 - AMC*/
               BEGIN
                  INSERT INTO per_direcciones
                              (sperson, cagente, cdomici, ctipdir,
                               csiglas, tnomvia, nnumvia, tcomple,
                               tdomici, cpostal, cpoblac, cprovin,
                               cusuari, fmovimi, cviavp, clitvp,
                               cbisvp, corvp, nviaadco, clitco,
                               corco, nplacaco, cor2co, cdet1ia,
                               tnum1ia, cdet2ia, tnum2ia, cdet3ia,
                               tnum3ia, localidad, talias)  -- BUG CONF-441 - 14/12/2016 - JAEG
                       VALUES (vsperson_new, reg3.cagente, reg3.cdomici, reg3.ctipdir,
                               reg3.csiglas, reg3.tnomvia, reg3.nnumvia, reg3.tcomple,
                               reg3.tdomici, reg3.cpostal, reg3.cpoblac, reg3.cprovin,
                               reg3.cusuari, reg3.fmovimi, reg3.cviavp, reg3.clitvp,
                               reg3.cbisvp, reg3.corvp, reg3.nviaadco, reg3.clitco,
                               reg3.corco, reg3.nplacaco, reg3.cor2co, reg3.cdet1ia,
                               reg3.tnum1ia, reg3.cdet2ia, reg3.tnum2ia, reg3.cdet3ia,
                               reg3.tnum3ia, reg3.localidad, reg3.talias);  -- BUG CONF-441 - 14/12/2016 - JAEG

               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_direcciones
                         WHERE sperson = vsperson_new
                           AND(cdomici = reg3.cdomici
                               OR(cdomici IS NULL
                                  AND reg3.cdomici IS NULL))
                           AND(cagente = reg3.cagente
                               OR(cagente IS NULL
                                  AND reg3.cagente IS NULL))
                           AND(ctipdir = reg3.ctipdir
                               OR(ctipdir IS NULL
                                  AND reg3.ctipdir IS NULL))
                           AND(csiglas = reg3.csiglas
                               OR(csiglas IS NULL
                                  AND reg3.csiglas IS NULL))
                           AND(tnomvia = reg3.tnomvia
                               OR(tnomvia IS NULL
                                  AND reg3.tnomvia IS NULL))
                           AND(nnumvia = reg3.nnumvia
                               OR(nnumvia IS NULL
                                  AND reg3.nnumvia IS NULL))
                           AND(tcomple = reg3.tcomple
                               OR(tcomple IS NULL
                                  AND reg3.tcomple IS NULL))
                           AND(tdomici = reg3.tdomici
                               OR(tdomici IS NULL
                                  AND reg3.tdomici IS NULL))
                           AND(cpostal = reg3.cpostal
                               OR(cpostal IS NULL
                                  AND reg3.cpostal IS NULL))
                           AND(cpoblac = reg3.cpoblac
                               OR(cpoblac IS NULL
                                  AND reg3.cpoblac IS NULL))
                           AND(cprovin = reg3.cprovin
                               OR(cprovin IS NULL
                                  AND reg3.cprovin IS NULL))
                           /*AND (cusuari = reg3.cusuari or (cusuari is null and reg3.cusuari is null))*/
                           /*AND (fmovimi = reg3.fmovimi or (fmovimi is null and reg3.fmovimi is null))*/
                           AND(cviavp = reg3.cviavp
                               OR(cviavp IS NULL
                                  AND reg3.cviavp IS NULL))
                           AND(clitvp = reg3.clitvp
                               OR(clitvp IS NULL
                                  AND reg3.clitvp IS NULL))
                           AND(cbisvp = reg3.cbisvp
                               OR(cbisvp IS NULL
                                  AND reg3.cbisvp IS NULL))
                           AND(corvp = reg3.corvp
                               OR(corvp IS NULL
                                  AND reg3.corvp IS NULL))
                           AND(nviaadco = reg3.nviaadco
                               OR(nviaadco IS NULL
                                  AND reg3.nviaadco IS NULL))
                           AND(clitco = reg3.clitco
                               OR(clitco IS NULL
                                  AND reg3.clitco IS NULL))
                           AND(corco = reg3.corco
                               OR(corco IS NULL
                                  AND reg3.corco IS NULL))
                           AND(nplacaco = reg3.nplacaco
                               OR(nplacaco IS NULL
                                  AND reg3.nplacaco IS NULL))
                           AND(cor2co = reg3.cor2co
                               OR(cor2co IS NULL
                                  AND reg3.cor2co IS NULL))
                           AND(cdet1ia = reg3.cdet1ia
                               OR(cdet1ia IS NULL
                                  AND reg3.cdet1ia IS NULL))
                           AND(tnum1ia = reg3.tnum1ia
                               OR(tnum1ia IS NULL
                                  AND reg3.tnum1ia IS NULL))
                           AND(cdet2ia = reg3.cdet2ia
                               OR(cdet2ia IS NULL
                                  AND reg3.cdet2ia IS NULL))
                           AND(tnum2ia = reg3.tnum2ia
                               OR(tnum2ia IS NULL
                                  AND reg3.tnum2ia IS NULL))
                           AND(cdet3ia = reg3.cdet3ia
                               OR(cdet3ia IS NULL
                                  AND reg3.cdet3ia IS NULL))
                           AND(tnum3ia = reg3.tnum3ia
                               OR(tnum3ia IS NULL
                                  AND reg3.tnum3ia IS NULL))
                           AND(localidad = reg3.localidad
                               OR(localidad IS NULL
                                  AND reg3.localidad IS NULL));
                     END IF;

                     UPDATE per_direcciones
                        SET ctipdir = reg3.ctipdir,
                            csiglas = reg3.csiglas,
                            tnomvia = reg3.tnomvia,
                            nnumvia = reg3.nnumvia,
                            tcomple = reg3.tcomple,
                            tdomici = reg3.tdomici,
                            cpostal = reg3.cpostal,
                            cpoblac = reg3.cpoblac,
                            cprovin = reg3.cprovin,
                            cusuari = reg3.cusuari,
                            fmovimi = reg3.fmovimi,
                            cviavp = reg3.cviavp,
                            clitvp = reg3.clitvp,
                            cbisvp = reg3.cbisvp,
                            corvp = reg3.corvp,
                            nviaadco = reg3.nviaadco,
                            clitco = reg3.clitco,
                            corco = reg3.corco,
                            nplacaco = reg3.nplacaco,
                            cor2co = reg3.cor2co,
                            cdet1ia = reg3.cdet1ia,
                            tnum1ia = reg3.tnum1ia,
                            cdet2ia = reg3.cdet2ia,
                            tnum2ia = reg3.tnum2ia,
                            cdet3ia = reg3.cdet3ia,
                            tnum3ia = reg3.tnum3ia,
                            localidad = reg3.localidad,
          talias = reg3.talias  -- BUG CONF-441 - 14/12/2016 - JAEG
                      WHERE sperson = vsperson_new
                        AND cdomici = reg3.cdomici
                        AND cagente = reg3.cagente;
               /* DRA 29-9-08: bug mantis 7567*/

               END;
            /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
            END LOOP;

            /* fin jtg*/
            vtraza := 5;

            /* insertamos los contactos*/
            FOR reg4 IN (SELECT *
                           FROM estper_contactos
                          WHERE sperson = psperson
                            AND cagente = reg1.cagente) LOOP
               BEGIN
                  INSERT INTO per_contactos
                              (sperson, cagente, cmodcon, ctipcon,
                               tcomcon, tvalcon, cdomici, cusuari,   /*24806*/
                               fmovimi, cobliga, cprefix)
                       VALUES (vsperson_new, reg4.cagente, reg4.cmodcon, reg4.ctipcon,
                               reg4.tcomcon, reg4.tvalcon, reg4.cdomici, reg4.cusuari,
                               reg4.fmovimi, reg4.cobliga, reg4.cprefix);

               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_contactos
                         WHERE sperson = vsperson_new
                           AND(cmodcon = reg4.cmodcon
                               OR(cmodcon IS NULL
                                  AND reg4.cmodcon IS NULL))
                           AND(cagente = reg4.cagente
                               OR(cagente IS NULL
                                  AND reg4.cagente IS NULL))
                           AND(ctipcon = reg4.ctipcon
                               OR(ctipcon IS NULL
                                  AND reg4.ctipcon IS NULL))
                           AND(tcomcon = reg4.tcomcon
                               OR(tcomcon IS NULL
                                  AND reg4.tcomcon IS NULL))
                           AND(tvalcon = reg4.tvalcon
                               OR(tvalcon IS NULL
                                  AND reg4.tvalcon IS NULL))
                           AND(cdomici = reg4.cdomici   /* bug 24806*/
                               OR(cdomici IS NULL
                                  AND reg4.cdomici IS NULL))
                           /*AND (cusuari = reg4.cusuari or (cusuari is null and reg4.cusuari is null))*/
                           /*AND (fmovimi = reg4.fmovimi or (fmovimi is null and reg4.fmovimi is null))*/
                           AND(cobliga = reg4.cobliga
                               OR(cobliga IS NULL
                                  AND reg4.cobliga IS NULL));
                     END IF;

                     UPDATE per_contactos
                        SET ctipcon = reg4.ctipcon,
                            tcomcon = reg4.tcomcon,
                            tvalcon = reg4.tvalcon,
                            cdomici = reg4.cdomici,   /*bug 24806*/
                            cusuari = reg4.cusuari,
                            fmovimi = reg4.fmovimi,
                            cobliga = reg4.cobliga,
                            cprefix = reg4.cprefix
                      WHERE sperson = vsperson_new
                        AND cmodcon = reg4.cmodcon
                        AND cagente = reg4.cagente;
               /* DRA 29-9-08: bug mantis 7567*/
               END;
            END LOOP;

            vtraza := 6;

            /* insertamos los vinculos*/
            FOR reg5 IN (SELECT *
                           FROM estper_vinculos
                          WHERE sperson = psperson
                            AND cagente = reg1.cagente) LOOP
               BEGIN
                  INSERT INTO per_vinculos
                              (sperson, cagente, cvinclo, cusuari,
                               fmovimi)
                       VALUES (vsperson_new, reg5.cagente, reg5.cvinclo, reg5.cusuari,
                               reg5.fmovimi);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_vinculos
                         WHERE sperson = vsperson_new
                           AND(cvinclo = reg5.cvinclo
                               OR(cvinclo IS NULL
                                  AND reg5.cvinclo IS NULL))
                           AND(cagente = reg5.cagente
                               OR(cagente IS NULL
                                  AND reg5.cagente IS NULL))
                                                            /*AND (cusuari = reg5.cusuari or (cusuari is null and reg5.cusuari is null))*/
                                                            /*AND (fmovimi = reg5.fmovimi or (fmovimi is null and reg5.fmovimi is null))*/
                        ;
                     END IF;

                     UPDATE per_vinculos
                        SET cusuari = reg5.cusuari,
                            fmovimi = reg5.fmovimi
                      WHERE sperson = vsperson_new
                        AND cvinclo = reg5.cvinclo
                        AND cagente = reg5.cagente;
               END;
            END LOOP;

            /* insertamos en irpf*/
            /* bug 12716 - 26/03/2010 - AMC*/
            FOR reg10 IN (SELECT *
                            FROM estper_irpf
                           WHERE sperson = psperson
                             AND cagente = reg1.cagente) LOOP
               BEGIN
                  INSERT INTO per_irpf
                              (sperson, cagente, csitfam, cnifcon,
                               cgrado, cayuda, ipension, ianuhijos,
                               cusuari, fmovimi, prolon, rmovgeo,
                               nano, fmovgeo, cpago)
                       VALUES (vsperson_new, reg10.cagente, reg10.csitfam, reg10.cnifcon,
                               reg10.cgrado, reg10.cayuda, reg10.ipension, reg10.ianuhijos,
                               reg10.cusuari, reg10.fmovimi, reg10.prolon, reg10.rmovgeo,
                               reg10.nano, reg10.fmovgeo, reg10.cpago);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_irpf
                         WHERE sperson = vsperson_new
                           AND(cagente = reg10.cagente
                               OR(cagente IS NULL
                                  AND reg10.cagente IS NULL))
                           AND(nano = reg10.nano
                               OR(nano IS NULL
                                  AND reg10.nano IS NULL))
                           AND(csitfam = reg10.csitfam
                               OR(csitfam IS NULL
                                  AND reg10.csitfam IS NULL))
                           AND(cnifcon = reg10.cnifcon
                               OR(cnifcon IS NULL
                                  AND reg10.cnifcon IS NULL))
                           AND(cgrado = reg10.cgrado
                               OR(cgrado IS NULL
                                  AND reg10.cgrado IS NULL))
                           AND(cayuda = reg10.cayuda
                               OR(cayuda IS NULL
                                  AND reg10.cayuda IS NULL))
                           AND(ipension = reg10.ipension
                               OR(ipension IS NULL
                                  AND reg10.ipension IS NULL))
                           AND(ianuhijos = reg10.ianuhijos
                               OR(ianuhijos IS NULL
                                  AND reg10.ianuhijos IS NULL))
                           /*AND (cusuari = reg10.cusuari or (cusuari is null and reg10.cusuari is null))*/
                           /*AND (fmovimi = reg10.fmovimi or (fmovimi is null and reg10.fmovimi is null))*/
                           AND(prolon = reg10.prolon
                               OR(prolon IS NULL
                                  AND reg10.prolon IS NULL))
                           AND(rmovgeo = reg10.rmovgeo
                               OR(rmovgeo IS NULL
                                  AND reg10.rmovgeo IS NULL))
                           AND(fmovgeo = reg10.fmovgeo
                               OR(fmovgeo IS NULL
                                  AND reg10.fmovgeo IS NULL))
                           AND(cpago = reg10.cpago
                               OR(cpago IS NULL
                                  AND reg10.cpago IS NULL));
                     END IF;

                     UPDATE per_irpf
                        SET csitfam = reg10.csitfam,
                            cnifcon = reg10.cnifcon,
                            cgrado = reg10.cgrado,
                            cayuda = reg10.cayuda,
                            ipension = reg10.ipension,
                            ianuhijos = reg10.ianuhijos,
                            cusuari = reg10.cusuari,
                            fmovimi = reg10.fmovimi,
                            prolon = reg10.prolon,
                            rmovgeo = reg10.rmovgeo,
                            fmovgeo = reg10.fmovgeo,
                            cpago = reg10.cpago
                      WHERE sperson = vsperson_new
                        AND cagente = reg10.cagente
                        AND nano = reg10.nano;
               END;
            END LOOP;

            vtraza := 13;

            /* insertamos en irpfdescen*/
            FOR reg11 IN (SELECT *
                            FROM estper_irpfdescen
                           WHERE sperson = psperson
                             AND cagente = reg1.cagente) LOOP
               BEGIN
                  INSERT INTO per_irpfdescen
                              (sperson, cagente, fnacimi, cgrado,
                               center, cusuari, fmovimi, norden,
                               nano, fadopcion)
                       VALUES (vsperson_new, reg11.cagente, reg11.fnacimi, reg11.cgrado,
                               reg11.center, reg11.cusuari, reg11.fmovimi, reg11.norden,
                               reg11.nano, reg11.fadopcion);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_irpfdescen
                         WHERE sperson = vsperson_new
                           AND(norden = reg11.norden
                               OR(norden IS NULL
                                  AND reg11.norden IS NULL))
                           AND(nano = reg11.nano
                               OR(nano IS NULL
                                  AND reg11.nano IS NULL))
                           AND(cagente = reg11.cagente
                               OR(cagente IS NULL
                                  AND reg11.cagente IS NULL))
                           AND(fnacimi = reg11.fnacimi
                               OR(fnacimi IS NULL
                                  AND reg11.fnacimi IS NULL))
                           AND(cgrado = reg11.cgrado
                               OR(cgrado IS NULL
                                  AND reg11.cgrado IS NULL))
                           AND(center = reg11.center
                               OR(center IS NULL
                                  AND reg11.center IS NULL))
                           /*AND (cusuari = reg11.cusuari or (cusuari is null and reg11.cusuari is null))*/
                           /*AND (fmovimi = reg11.fmovimi or (fmovimi is null and reg11.fmovimi is null))*/
                           AND(fadopcion = reg11.fadopcion
                               OR(fadopcion IS NULL
                                  AND reg11.fadopcion IS NULL));
                     END IF;

                     UPDATE per_irpfdescen
                        SET fnacimi = reg11.fnacimi,
                            cgrado = reg11.cgrado,
                            center = reg11.center,
                            cusuari = reg11.cusuari,
                            fmovimi = reg11.fmovimi,
                            fadopcion = reg11.fadopcion
                      WHERE sperson = vsperson_new
                        AND norden = reg11.norden
                        AND nano = reg11.nano
                        AND cagente = reg11.cagente;
               END;
            END LOOP;

            /* fi bug 12716 - 26/03/2010 - AMC*/
            vtraza := 14;

            /* insertamos en irpfmayores*/
            FOR reg12 IN (SELECT *
                            FROM estper_irpfmayores
                           WHERE sperson = psperson
                             AND cagente = reg1.cagente) LOOP
               BEGIN
                  INSERT INTO per_irpfmayores
                              (sperson, cagente, fnacimi, cgrado,
                               crenta, nviven, cusuari, fmovimi,
                               norden, nano)
                       VALUES (vsperson_new, reg12.cagente, reg12.fnacimi, reg12.cgrado,
                               reg12.crenta, reg12.nviven, reg12.cusuari, reg12.fmovimi,
                               reg12.norden, reg12.nano);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_irpfmayores
                         WHERE sperson = vsperson_new
                           AND(norden = reg12.norden
                               OR(norden IS NULL
                                  AND reg12.norden IS NULL))
                           AND(nano = reg12.nano
                               OR(nano IS NULL
                                  AND reg12.nano IS NULL))
                           AND(cagente = reg12.cagente
                               OR(cagente IS NULL
                                  AND reg12.cagente IS NULL))
                           AND(fnacimi = reg12.fnacimi
                               OR(fnacimi IS NULL
                                  AND reg12.fnacimi IS NULL))
                           AND(cgrado = reg12.cgrado
                               OR(cgrado IS NULL
                                  AND reg12.cgrado IS NULL))
                           AND(crenta = reg12.crenta
                               OR(crenta IS NULL
                                  AND reg12.crenta IS NULL))
                           AND(nviven = reg12.nviven
                               OR(nviven IS NULL
                                  AND reg12.nviven IS NULL))
                                                            /*AND (cusuari = reg12.cusuari or (cusuari is null and reg12.cusuari is null))*/
                                                            /*AND (fmovimi = reg12.fmovimi or (fmovimi is null and reg12.fmovimi is null))*/
                        ;
                     END IF;

                     UPDATE per_irpfmayores
                        SET fnacimi = reg12.fnacimi,
                            cgrado = reg12.cgrado,
                            crenta = reg12.crenta,
                            nviven = reg12.nviven,
                            cusuari = reg12.cusuari,
                            fmovimi = reg12.fmovimi
                      WHERE sperson = vsperson_new
                        AND norden = reg12.norden
                        AND nano = reg12.nano
                        AND cagente = reg12.cagente;
               END;
            END LOOP;

            vtraza := 15;

            /* Insertamos o Modificamos CCCC*/
            /* ini jtg*/
            /* para los CORIGEN is null*/
            FOR reg13 IN (SELECT *
                            FROM estper_ccc
                           WHERE sperson = psperson
                             AND cagente = reg1.cagente
                             AND(corigen IS NULL
                                 OR corigen != 'INT')) LOOP
               BEGIN
                  INSERT INTO per_ccc
                              (sperson, cagente, ctipban, cbancar,
                               fbaja, cdefecto, cusumov, fusumov,
                               cnordban, cvalida, cpagsin, fvencim,
                               tseguri)
                       VALUES (vsperson_new, reg13.cagente, reg13.ctipban, reg13.cbancar,
                               reg13.fbaja, reg13.cdefecto, reg13.cusumov, reg13.fusumov,
                               reg13.cnordban, reg13.cvalida, reg13.cpagsin, reg13.fvencim,
                               reg13.tseguri);

               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_ccc
                         WHERE sperson = vsperson_new
                           AND(cnordban = reg13.cnordban
                               OR(cnordban IS NULL
                                  AND reg13.cnordban IS NULL))
                           AND(cagente = reg13.cagente
                               OR(cagente IS NULL
                                  AND reg13.cagente IS NULL))
                           AND(fbaja = reg13.fbaja
                               OR(fbaja IS NULL
                                  AND reg13.fbaja IS NULL))
                           AND(cdefecto = reg13.cdefecto
                               OR(cdefecto IS NULL
                                  AND reg13.cdefecto IS NULL))
                           /*AND (cusumov = reg13.cusumov or (cusumov is null and reg13.cusumov is null))*/
                           /*AND (fusumov = reg13.fusumov or (fusumov is null and reg13.fusumov is null))*/
                           AND(cbancar = reg13.cbancar
                               OR(cbancar IS NULL
                                  AND reg13.cbancar IS NULL))
                           AND(ctipban = reg13.ctipban
                               OR(ctipban IS NULL
                                  AND reg13.ctipban IS NULL))
                           AND(cvalida = reg13.cvalida
                               OR(cvalida IS NULL
                                  AND reg13.cvalida IS NULL))
                           AND(cpagsin = reg13.cpagsin
                               OR(cpagsin IS NULL
                                  AND reg13.cpagsin IS NULL))
                           AND(fvencim = reg13.fvencim
                               OR(fvencim IS NULL
                                  AND reg13.fvencim IS NULL))
                           AND(tseguri = reg13.tseguri
                               OR(tseguri IS NULL
                                  AND reg13.tseguri IS NULL));
                     END IF;

                     UPDATE per_ccc
                        SET fbaja = reg13.fbaja,
                            cdefecto = reg13.cdefecto,
                            cusumov = reg13.cusumov,
                            fusumov = reg13.fusumov,
                            cbancar = reg13.cbancar,
                            ctipban = reg13.ctipban,
                            cvalida = reg13.cvalida,
                            cpagsin = reg13.cpagsin,
                            fvencim = reg13.fvencim,
                            tseguri = reg13.tseguri
                      WHERE sperson = vsperson_new
                        AND cnordban = reg13.cnordban
                        AND cagente = reg13.cagente;
               /* DRA 29-9-08: bug mantis 7567*/
               END;
            END LOOP;

            /* insertamos los CARNETS XPL#21531 08032012*/
            FOR reg4 IN (SELECT *
                           FROM estper_autcarnet
                          WHERE sperson = psperson
                            AND cagente = reg1.cagente) LOOP
               BEGIN
                  INSERT INTO per_autcarnet
                              (sperson, cagente, ctipcar, fcarnet,
                               cdefecto)
                       VALUES (vsperson_new, reg4.cagente, reg4.ctipcar, reg4.fcarnet,
                               reg4.cdefecto);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_autcarnet
                         WHERE sperson = vsperson_new
                           AND(ctipcar = reg4.ctipcar
                               OR(ctipcar IS NULL
                                  AND reg4.ctipcar IS NULL))
                           AND(cagente = reg4.cagente
                               OR(cagente IS NULL
                                  AND reg4.cagente IS NULL))
                           AND(fcarnet = reg4.fcarnet
                               OR(fcarnet IS NULL
                                  AND reg4.fcarnet IS NULL))
                           AND(cdefecto = reg4.cdefecto
                               OR(cdefecto IS NULL
                                  AND reg4.cdefecto IS NULL));
                     END IF;

                     UPDATE per_autcarnet
                        SET fcarnet = reg4.fcarnet
                      WHERE sperson = vsperson_new
                        AND ctipcar = reg4.ctipcar
                        AND cagente = reg4.cagente;
               END;
            END LOOP;

            /* para los CORIGEN = 'INT'*/
            FOR reg13 IN (SELECT c.*
                            FROM estper_personas p, estseguros s, estper_ccc c
                           WHERE p.sperson = psperson
                             AND s.sseguro = p.sseguro
                             AND c.sperson = p.sperson
                             AND c.cbancar = s.cbancar
                             AND c.corigen = 'INT') LOOP
               BEGIN
                  SELECT DECODE(COUNT(1), 0, 1, 0)   /*,1,0)*/
                    INTO vcdefecto
                    FROM per_ccc p
                   WHERE p.sperson = vsperson_new
                     AND p.cagente = reg13.cagente;

                  INSERT INTO per_ccc
                              (sperson, cagente, ctipban, cbancar,
                               fbaja, cdefecto, cusumov, fusumov,
                               cnordban, cvalida, cpagsin, fvencim,
                               tseguri)
                       VALUES (vsperson_new, reg13.cagente, reg13.ctipban, reg13.cbancar,
                               reg13.fbaja, vcdefecto, reg13.cusumov, reg13.fusumov,
                               reg13.cnordban, reg13.cvalida, reg13.cpagsin, reg13.fvencim,
                               reg13.tseguri);

               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_ccc
                         WHERE sperson = vsperson_new
                           AND(cnordban = reg13.cnordban
                               OR(cnordban IS NULL
                                  AND reg13.cnordban IS NULL))
                           AND(cagente = reg13.cagente
                               OR(cagente IS NULL
                                  AND reg13.cagente IS NULL))
                           AND(fbaja = reg13.fbaja
                               OR(fbaja IS NULL
                                  AND reg13.fbaja IS NULL))
                           /*AND (cusumov = reg13.cusumov or (cusumov is null and reg13.cusumov is null))*/
                           /*AND (fusumov = reg13.fusumov or (fusumov is null and reg13.fusumov is null))*/
                           AND(cbancar = reg13.cbancar
                               OR(cbancar IS NULL
                                  AND reg13.cbancar IS NULL))
                           AND(ctipban = reg13.ctipban
                               OR(ctipban IS NULL
                                  AND reg13.ctipban IS NULL))
                           AND(cvalida = reg13.cvalida
                               OR(cvalida IS NULL
                                  AND reg13.cvalida IS NULL))
                           AND(cpagsin = reg13.cpagsin
                               OR(cpagsin IS NULL
                                  AND reg13.cpagsin IS NULL))
                           AND(fvencim = reg13.fvencim
                               OR(fvencim IS NULL
                                  AND reg13.fvencim IS NULL))
                           AND(tseguri = reg13.tseguri
                               OR(tseguri IS NULL
                                  AND reg13.tseguri IS NULL));
                     END IF;

                     UPDATE per_ccc
                        SET fbaja = reg13.fbaja,
                            cusumov = reg13.cusumov,
                            fusumov = reg13.fusumov,
                            cbancar = reg13.cbancar,
                            ctipban = reg13.ctipban,
                            cvalida = reg13.cvalida,
                            cpagsin = reg13.cpagsin,
                            fvencim = reg13.fvencim,
                            tseguri = reg13.tseguri
                      WHERE sperson = vsperson_new
                        AND cnordban = reg13.cnordban
                        AND cagente = reg13.cagente;

               /* DRA 29-9-08: bug mantis 7567*/
               END;
            END LOOP;

            /* fin jtg*/
            /*JRH 05/2008*/
            FOR reg20 IN (SELECT *
                            FROM estper_identificador
                           WHERE sperson = psperson
                             AND cagente = reg1.cagente) LOOP
               BEGIN
                  INSERT INTO per_identificador
                              (sperson, cagente, ctipide, nnumide,
                               swidepri, femisio, fcaduca)
                       VALUES (vsperson_new, reg20.cagente, reg20.ctipide, reg20.nnumide,
                               reg20.swidepri, reg20.femisio, reg20.fcaduca);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_identificador
                         WHERE sperson = vsperson_new
                           AND(cagente = reg20.cagente
                               OR(cagente IS NULL
                                  AND reg20.cagente IS NULL))
                           AND(ctipide = reg20.ctipide
                               OR(ctipide IS NULL
                                  AND reg20.ctipide IS NULL))
                           AND(nnumide = reg20.nnumide
                               OR(nnumide IS NULL
                                  AND reg20.nnumide IS NULL))
                           AND(swidepri = reg20.swidepri
                               OR(swidepri IS NULL
                                  AND reg20.swidepri IS NULL))
                           AND(femisio = reg20.femisio
                               OR(femisio IS NULL
                                  AND reg20.femisio IS NULL))
                           AND(fcaduca = reg20.fcaduca
                               OR(fcaduca IS NULL
                                  AND reg20.fcaduca IS NULL));
                     END IF;

                     UPDATE per_identificador
                        SET nnumide = reg20.nnumide,
                            swidepri = reg20.swidepri,
                            femisio = reg20.femisio,
                            fcaduca = reg20.fcaduca
                      WHERE sperson = vsperson_new
                        AND cagente = reg20.cagente
                        AND ctipide = reg20.ctipide;
               END;
            END LOOP;

            vtraza := 16;

            /* Insert en nacionalidades*/
            FOR reg14 IN (SELECT *
                            FROM estper_nacionalidades
                           WHERE sperson = psperson
                             AND cagente = reg1.cagente) LOOP
               BEGIN
                  INSERT INTO per_nacionalidades
                              (sperson, cagente, cpais, cdefecto)
                       VALUES (vsperson_new, reg14.cagente, reg14.cpais, reg14.cdefecto);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     IF vcambio <> 0 THEN
                        SELECT COUNT(1)
                          INTO vcambio
                          FROM per_nacionalidades
                         WHERE sperson = vsperson_new
                           AND(cagente = reg14.cagente
                               OR(cagente IS NULL
                                  AND reg14.cagente IS NULL))
                           AND(cpais = reg14.cpais
                               OR(cpais IS NULL
                                  AND reg14.cpais IS NULL))
                           AND(cdefecto = reg14.cdefecto
                               OR(cdefecto IS NULL
                                  AND reg14.cdefecto IS NULL));
                     END IF;

                     UPDATE per_nacionalidades
                        SET cdefecto = reg14.cdefecto
                      WHERE sperson = vsperson_new
                        AND cagente = reg14.cagente
                        AND cpais = reg14.cpais;
               END;
            END LOOP;

            vtraza := 17;
         END LOOP;

         vtraza := 4;

         /* insertamos lopd de la persona.*/
         FOR reg2 IN (SELECT *
                        FROM estper_lopd
                       WHERE sperson = psperson) LOOP
            BEGIN
               INSERT INTO per_lopd
                           (sperson, cagente, fmovimi, cusuari,
                            cestado, norden, cesion, publicidad,
                            cancelacion, ctipdoc, ftipdoc, catendido,
                            fatendido, acceso, rectificacion)
                    VALUES (vsperson_new, reg2.cagente, reg2.fmovimi, reg2.cusuari,
                            reg2.cestado, reg2.norden, reg2.cesion, reg2.publicidad,
                            reg2.cancelacion, reg2.ctipdoc, reg2.ftipdoc, reg2.catendido,
                            reg2.fatendido, reg2.acceso, reg2.rectificacion);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  IF vcambio <> 0 THEN
                     SELECT COUNT(1)
                       INTO vcambio
                       FROM per_lopd
                      WHERE sperson = vsperson_new
                        AND(norden = reg2.norden
                            OR(norden IS NULL
                               AND reg2.norden IS NULL))
                        /*AND (fmovimi = reg2.fmovimi or (fmovimi is null and reg2.fmovimi is null))*/
                        /*AND (cusuari = reg2.cusuari or (cusuari is null and reg2.cusuari is null))*/
                        AND(cestado = reg2.cestado
                            OR(cestado IS NULL
                               AND reg2.cestado IS NULL))
                        AND(cesion = reg2.cesion
                            OR(cesion IS NULL
                               AND reg2.cesion IS NULL))
                        AND(publicidad = reg2.publicidad
                            OR(publicidad IS NULL
                               AND reg2.publicidad IS NULL))
                        AND(cancelacion = reg2.cancelacion
                            OR(cancelacion IS NULL
                               AND reg2.cancelacion IS NULL))
                        AND(ctipdoc = reg2.ctipdoc
                            OR(ctipdoc IS NULL
                               AND reg2.ctipdoc IS NULL))
                        AND(ftipdoc = reg2.ftipdoc
                            OR(ftipdoc IS NULL
                               AND reg2.ftipdoc IS NULL))
                        AND(catendido = reg2.catendido
                            OR(catendido IS NULL
                               AND reg2.catendido IS NULL))
                        AND(fatendido = reg2.fatendido
                            OR(fatendido IS NULL
                               AND reg2.fatendido IS NULL))
                        AND(acceso = reg2.acceso
                            OR(acceso IS NULL
                               AND reg2.acceso IS NULL))
                        AND(rectificacion = reg2.rectificacion
                            OR(rectificacion IS NULL
                               AND reg2.rectificacion IS NULL));
                  END IF;

                  UPDATE per_lopd
                     SET fmovimi = reg2.fmovimi,
                         cusuari = reg2.cusuari,
                         cestado = reg2.cestado,
                         cesion = reg2.cesion,
                         publicidad = reg2.publicidad,
                         cancelacion = reg2.cancelacion,
                         ctipdoc = reg2.ctipdoc,
                         ftipdoc = reg2.ftipdoc,
                         catendido = reg2.catendido,
                         fatendido = reg2.fatendido,
                         acceso = reg2.acceso,
                         rectificacion = reg2.rectificacion
                   WHERE sperson = vsperson_new
                     AND norden = reg2.norden;
            END;
         END LOOP;

         vtraza := 8;

         /* insertamos regimen fiscal de la persona.*/
         FOR reg2 IN (SELECT *
                        FROM estper_regimenfiscal
                       WHERE sperson = psperson) LOOP
            BEGIN
               INSERT INTO per_regimenfiscal
                           (sperson, cagente, anualidad, fefecto,
                            cregfiscal, cusualt, falta, cregfisexeiva)
                    VALUES (vsperson_new, reg2.cagente, reg2.anualidad, reg2.fefecto,
                            reg2.cregfiscal, reg2.cusualt, reg2.falta, reg2.cregfisexeiva);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  IF vcambio <> 0 THEN
                     SELECT COUNT(1)
                       INTO vcambio
                       FROM per_regimenfiscal
                      WHERE sperson = vsperson_new
                        AND(cagente = reg2.cagente
                            OR(cagente IS NULL
                               AND reg2.cagente IS NULL))
                        AND(fefecto = reg2.fefecto
                            OR(fefecto IS NULL
                               AND reg2.fefecto IS NULL))
                        AND(anualidad = reg2.anualidad
                            OR(anualidad IS NULL
                               AND reg2.anualidad IS NULL))
                        AND(cregfiscal = reg2.cregfiscal
                            OR(cregfiscal IS NULL
                               AND reg2.cregfiscal IS NULL));
                  END IF;

                  UPDATE per_regimenfiscal
                     SET anualidad = reg2.anualidad,
                         cregfiscal = reg2.cregfiscal,
                         cregfisexeiva = reg2.cregfisexeiva
                   WHERE sperson = vsperson_new
                     AND cagente = reg2.cagente
                     AND fefecto = reg2.fefecto;
            END;
         END LOOP;

         vtraza := 9;

         /* Bug 25542 - APD - 10/01/2013*/
         /* insertamos antiguedad de la persona.*/
         FOR reg2 IN (SELECT *
                        FROM estper_antiguedad
                       WHERE sperson = psperson) LOOP
            BEGIN
               INSERT INTO per_antiguedad
                           (sperson, cagrupa, norden, fantiguedad,
                            cestado, sseguro_ini, nmovimi_ini, ffin,
                            sseguro_fin, nmovimi_fin, falta, cusualt)
                    VALUES (vsperson_new, reg2.cagrupa, reg2.norden, reg2.fantiguedad,
                            reg2.cestado, reg2.sseguro_ini, reg2.nmovimi_ini, reg2.ffin,
                            reg2.sseguro_fin, reg2.nmovimi_fin, reg2.falta, reg2.cusualt);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  IF vcambio <> 0 THEN
                     SELECT COUNT(1)
                       INTO vcambio
                       FROM per_antiguedad
                      WHERE sperson = vsperson_new
                        AND(cagrupa = reg2.cagrupa
                            OR(cagrupa IS NULL
                               AND reg2.cagrupa IS NULL))
                        AND(norden = reg2.norden
                            OR(norden IS NULL
                               AND reg2.norden IS NULL))
                        AND(fantiguedad = reg2.fantiguedad
                            OR(fantiguedad IS NULL
                               AND reg2.fantiguedad IS NULL))
                        AND(cestado = reg2.cestado
                            OR(cestado IS NULL
                               AND reg2.cestado IS NULL))
                        AND(sseguro_ini = reg2.sseguro_ini
                            OR(sseguro_ini IS NULL
                               AND reg2.sseguro_ini IS NULL))
                        AND(nmovimi_ini = reg2.nmovimi_ini
                            OR(nmovimi_ini IS NULL
                               AND reg2.nmovimi_ini IS NULL))
                        AND(ffin = reg2.ffin
                            OR(ffin IS NULL
                               AND reg2.ffin IS NULL))
                        AND(sseguro_fin = reg2.sseguro_fin
                            OR(sseguro_fin IS NULL
                               AND reg2.sseguro_fin IS NULL))
                        AND(nmovimi_fin = reg2.nmovimi_fin
                            OR(nmovimi_fin IS NULL
                               AND reg2.nmovimi_fin IS NULL));
                  END IF;

                  UPDATE per_antiguedad
                     SET fantiguedad = reg2.fantiguedad,
                         cestado = reg2.cestado,
                         sseguro_ini = reg2.sseguro_ini,
                         nmovimi_ini = reg2.nmovimi_ini,
                         ffin = reg2.ffin,
                         sseguro_fin = reg2.sseguro_fin,
                         nmovimi_fin = reg2.nmovimi_fin,
                         falta = reg2.falta,
                         cusualt = reg2.cusualt,
                         fmodifi = reg2.fmodifi,
                         cusumod = reg2.cusumod
                   WHERE sperson = vsperson_new
                     AND cagrupa = reg2.cagrupa
                     AND norden = reg2.norden;
            END;
         END LOOP;

         /* I -JLB - 18/02/2014*/
         FOR reg2 IN (SELECT *
                        FROM estper_cargas
                       WHERE sperson = psperson) LOOP
            BEGIN
               INSERT INTO per_cargas
                           (sperson, tipo, proceso, cagente,
                            ccodigo, cusuari, fecha)
                    VALUES (vsperson_new, reg2.tipo, reg2.proceso, reg2.cagente,
                            reg2.ccodigo, reg2.cusuari, reg2.fecha);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            /* no actualizo ni hago nada, me interesa el registro original*/
            END;
         END LOOP;

         /* fin Bug 25542 - APD - 10/01/2013*/
         vtraza := 10;

         FOR reg2 IN (SELECT *
                        FROM estper_parpersonas
                       WHERE sperson = psperson) LOOP
            BEGIN
               INSERT INTO per_parpersonas
                           (cparam, sperson, cagente, nvalpar,
                            tvalpar, fvalpar)
                    VALUES (reg2.cparam, vsperson_new, reg2.cagente, reg2.nvalpar,
                            reg2.tvalpar, reg2.fvalpar);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  IF vcambio <> 0 THEN
                     SELECT COUNT(1)
                       INTO vcambio
                       FROM per_parpersonas
                      WHERE sperson = vsperson_new
                        AND(cagente = reg2.cagente
                            OR(cagente IS NULL
                               AND reg2.cagente IS NULL))
                        AND cparam = reg2.cparam
                        AND(nvalpar = reg2.nvalpar
                            OR(nvalpar IS NULL
                               AND reg2.nvalpar IS NULL))
                        AND(tvalpar = reg2.tvalpar
                            OR(tvalpar IS NULL
                               AND reg2.tvalpar IS NULL))
                        AND(fvalpar = reg2.fvalpar
                            OR(fvalpar IS NULL
                               AND reg2.fvalpar IS NULL));
                  END IF;

                  UPDATE per_parpersonas
                     SET nvalpar = reg2.nvalpar,
                         tvalpar = reg2.tvalpar,
                         fvalpar = reg2.fvalpar
                   WHERE sperson = vsperson_new
                     AND cparam = reg2.cparam
                     AND cagente = reg2.cagente;
            END;
         END LOOP;

        /* Cambios de IAXIS-4844 : start */
    BEGIN
    SELECT PP.TDIGITOIDE
      INTO VDIGITOIDE
      FROM PER_PERSONAS PP
     WHERE PP.SPERSON = vsperson_new
       AND ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(reg.ctipide,
                    UPPER(reg.nnumide));
    END;
  /* Cambios de IAXIS-4844 : end */

         /* Bug 14365. FAL. 15/11/2010*/
         IF (NVL(pac_parametros.f_parempresa_n(pcempres, 'ALTA_PERSONA_HOST'), 0) = 1
             AND NVL(reg.corigen, 0) <> 'INT'
             AND waccion = 'INSERT') THEN
            num_err := pac_user.f_get_terminal(f_user, vcterminal);
            num_err := pac_con.f_alta_persona(pcempres, vsperson_new, vcterminal, psinterf,
                                              terror, pac_md_common.f_get_cxtusuario, 1);

            /* BUG 21270/106644 - 08/02/2012 - JMP - Grabamos otro mensaje con NNUMIDE||TDIGITOIDE*/
            IF sw_envio_rut = 1 THEN
               /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
               v_host := NULL;

               /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_DEUDOR_HOST');
               END IF;
                /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pcempres, vsperson_new, vcterminal, psinterf,
                                                 terror, pac_md_common.f_get_cxtusuario, 1,
                                                 'ALTA', VDIGITOIDE, v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;

            /* FIN BUG 21270/106644 - 08/02/2012 - JMP -*/
            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(vsperson_new) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pcempres, vsperson_new, vcterminal, psinterf,
                                                 terror, pac_md_common.f_get_cxtusuario, 1,
                                                 'ALTA', VDIGITOIDE, v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;
         /*fin BUG 0026318 -- GGR --  17/03/2014*/
         END IF;

         /* Fi Bug 14365*/
         /*BUG 19201 - 03/10/2011 - JRB - Se añade llamada a host cuando es una modificación de persona.*/
         /*BUG 20921 - 16/01/2012 - JRB - Sólo se llamará cuando haya cambios. vcambio*/
         IF (NVL(pac_parametros.f_parempresa_n(pcempres, 'MODIF_PERSONA_HOST'), 0) = 1
             AND NVL(reg.corigen, 0) <> 'INT'
             AND waccion = 'UPDATE'
             AND vcambio = 0) THEN
            num_err := pac_user.f_get_terminal(f_user, vcterminal);

            /* BUG 21270/106644 - 08/02/2012 - JMP - Grabamos otro mensaje con NNUMIDE||TDIGITOIDE*/
            IF sw_envio_rut = 1 THEN
               /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
               v_host := NULL;

               /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_DEUDOR_HOST');
               END IF;
                /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pcempres, vsperson_new, vcterminal, psinterf,
                                                 terror, pac_md_common.f_get_cxtusuario, 1,
                                                 'ALTA', VDIGITOIDE, v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;

            /* FIN BUG 21270/106644 - 08/02/2012 - JMP -*/
            num_err := pac_con.f_alta_persona(pcempres, vsperson_new, vcterminal, psinterf,
                                              terror, pac_md_common.f_get_cxtusuario, 1, 'MOD');
            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, vsperson_new,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;
         /*fin BUG 0026318 -- GGR -- 17/03/2014*/
         END IF;
      END LOOP;

      vtraza := 33;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.TRASPASO_TABLAS_ESTPER', vtraza,
                     'TRASPASO_TABLAS_ESTPER. Error .  SPERSON = ' || psperson, SQLERRM);
         ROLLBACK;
   END traspaso_tablas_estper;

   PROCEDURE traspaso_tablas_per(
      psperson IN per_personas.sperson%TYPE,
      pficticia_sperson OUT estper_personas.sperson%TYPE,
      psseguro IN seguros.sseguro%TYPE DEFAULT NULL,
      pcagente IN agentes.cagente%TYPE DEFAULT NULL) IS
      /* I JLB*/
      PRAGMA AUTONOMOUS_TRANSACTION;
      /* F JLB*/
      vcont          NUMBER := 0;
      vcdomici       per_direcciones.cdomici%TYPE;
      vcnordban      per_ccc.cnordban%TYPE;
      vcmodcon       per_contactos.cmodcon%TYPE;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
   BEGIN
      /* DRA 29-09-2008: Bug mantis 7567*/
          /* He sustituido las CUSUARI y FMOVIMI por F_USER y F_SYSDATE*/
      pficticia_sperson := pac_persona.f_estsperson;
      /* DRA 26-09-2008: bug mantis 7567*/
      /* vcagente := pac_persona.f_buscaagente (psperson); Agente de visión lo recuperá la siguiente función*/
      pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per, 'POL');

      /* insertamos en las tablas*/
      INSERT INTO estper_personas
                  (sperson, nnumide, nordide, ctipide, csexper, fnacimi, cestper, fjubila,
                   ctipper, cusuari, fmovimi, cmutualista, spereal, fdefunc, snip, sseguro,
                   swpubli, tdigitoide, cagente /*Bug 29166/160004 - 29/11/2013 - AMC*/)
         (SELECT pficticia_sperson, nnumide, nordide, ctipide,
                 DECODE(ctipper, 2, NULL, csexper), /*Bug 29738/166356 - 17/02/2013 - AMC*/ fnacimi,
                 cestper, fjubila, ctipper, f_user, f_sysdate, cmutualista, sperson, fdefunc,
                 snip, psseguro, swpubli, tdigitoide, cagente
            FROM per_personas
           WHERE sperson = psperson);

      /*BUG10878-07092009-XPL: Actualizamos con el sperson ficticio por si en alguna acción más adelante necesitamos el parametro*/
      /*Ini Bug 0013861 - 06-04-2010 - JMC - En lugar de update se realiza insert en estper_parpersonas*/
      /*
      BEGIN
         UPDATE per_parpersonas
            SET sperson = pficticia_sperson
          WHERE cparam = 'EMPLEADO'
            AND sperson = psperson
            AND cagente = pcagente;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   --no existe
      END;
      */
      BEGIN
         INSERT INTO estper_parpersonas
                     (cparam, sperson, cagente, nvalpar, tvalpar, fvalpar)
            (SELECT cparam, pficticia_sperson, vcagente_per, nvalpar, tvalpar, fvalpar
               FROM per_parpersonas
              WHERE sperson = psperson
                AND cagente = vcagente_visio);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE estper_parpersonas
               SET nvalpar = (SELECT nvalpar
                                FROM per_parpersonas
                               WHERE sperson = psperson
                                 AND cagente = vcagente_per)
             WHERE sperson = pficticia_sperson
               AND cagente = vcagente_visio;
         WHEN OTHERS THEN
            NULL;
      END;

      /*Fin Bug 0013861 - 06-04-2010 - JMC*/
      /*Bug 29738/166356 - 17/02/2013 - AMC*/
      INSERT INTO estper_detper
                  (sperson, cagente, cidioma, tapelli1, tapelli2, tnombre, tsiglas, cprofes,
                   tbuscar, cestciv, cpais, cusuari, fmovimi, tnombre1, tnombre2,
                   cocupacion /* Bug 25456/136037 - 23/01/2013 - AMC*/)
         (SELECT pficticia_sperson, vcagente_per, pd.cidioma, pd.tapelli1, pd.tapelli2,
                 pd.tnombre, pd.tsiglas, pd.cprofes, pd.tbuscar,
                 DECODE(p.ctipper, 2, NULL, pd.cestciv), pd.cpais, f_user, f_sysdate,
                 pd.tnombre1, pd.tnombre2,
                 pd.cocupacion   /* Bug 25456/136037 - 23/01/2013 - AMC*/
            FROM per_detper pd, per_personas p
           WHERE pd.sperson = psperson
             AND pd.sperson = p.sperson
             AND pd.cagente = vcagente_visio);

      /*Fi Bug 29738/166356 - 17/02/2013 - AMC*/
      /* DRA 26-09-2008: bug mantis 7567*/
      INSERT INTO estper_lopd
                  (sperson, cagente, fmovimi, cusuari, cestado, norden, cesion, publicidad,
                   cancelacion, ctipdoc, ftipdoc, catendido, fatendido, acceso, rectificacion)
         (SELECT pficticia_sperson, cagente, f_sysdate, f_user, cestado, norden, cesion,
                 publicidad, cancelacion, ctipdoc, ftipdoc, catendido, fatendido, acceso,
                 rectificacion
            FROM per_lopd
           WHERE sperson = psperson);

      /* insertamos los CARNETS XPL#21531 08032012*/
      INSERT INTO estper_autcarnet
                  (sperson, cagente, ctipcar, fcarnet, cdefecto)
         (SELECT pficticia_sperson, cagente, ctipcar, fcarnet, cdefecto
            FROM per_autcarnet
           WHERE sperson = psperson);

      INSERT INTO estper_regimenfiscal
                  (sperson, cagente, anualidad, fefecto, cregfiscal, cusualt, falta,
                   cregfisexeiva, ctipiva)---QT-1941-VC-18/04/2018- Se adiciona Ctipiva
         (SELECT pficticia_sperson, cagente, anualidad, fefecto, cregfiscal, f_user, f_sysdate,
                 cregfisexeiva, ctipiva
            FROM per_regimenfiscal
           WHERE sperson = psperson);

      /* DRA 29-9-08: bug mantis 7567*/
      vcont := 0;

      /* Bug 18940/92686 - 27/09/2011 - AMC*/
      FOR rper IN (SELECT sperson, cagente, cdomici, ctipdir, csiglas, tnomvia, nnumvia,
                          tcomple, tdomici, cpostal, cpoblac, cprovin, cviavp, clitvp, cbisvp,
                          corvp, nviaadco, clitco, corco, nplacaco, cor2co, cdet1ia, tnum1ia,
                          cdet2ia, tnum2ia, cdet3ia, tnum3ia, localidad
                     FROM per_direcciones
                    WHERE sperson = psperson
                      AND cagente = vcagente_visio) LOOP
         /* DRA 03-10-2008: bug mantis 6352*/
         vcdomici := pac_persona.f_existe_direccion(rper.sperson, vcagente_per, rper.ctipdir,
                                                    rper.csiglas, rper.tnomvia, rper.nnumvia,
                                                    rper.tcomple, rper.tdomici, rper.cpostal,
                                                    rper.cpoblac, rper.cprovin);

         IF vcdomici IS NULL THEN
            BEGIN
               vcont := vcont + 1;

               SELECT NVL(MAX(cdomici), 0) + vcont
                 INTO vcdomici
                 FROM per_direcciones
                WHERE sperson = psperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcdomici := 1;
            END;
         END IF;

         INSERT INTO estper_direcciones
                     (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia, nnumvia, tcomple,
                      tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi, cviavp, clitvp,
                      cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co, cdet1ia,
                      tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, localidad,
          talias)  -- BUG CONF-441 - 14/12/2016 - JAEG
            (SELECT pficticia_sperson, vcagente_per, vcdomici, ctipdir, csiglas, tnomvia,
                    nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin, f_user, f_sysdate,
                    cviavp, clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                    cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, localidad,
        talias     -- BUG CONF-441 - 14/12/2016 - JAEG
               FROM per_direcciones
              WHERE sperson = rper.sperson
                AND cdomici = rper.cdomici
                AND cagente = rper.cagente);
      /* DRA 26-09-2008: bug mantis 7567*/
      END LOOP;

      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      /* DRA 29-9-08: bug mantis 7567*/
      vcont := 0;

      FOR rper IN (SELECT sperson, cmodcon, cagente, ctipcon, tcomcon, tvalcon, cdomici,
                          cprefix
                     FROM per_contactos
                    WHERE sperson = psperson
                      AND cagente = vcagente_visio) LOOP
         /* DRA 03-10-2008: bug mantis 6352*/
         vcmodcon := pac_persona.f_existe_contacto(rper.sperson, vcagente_per, rper.ctipcon,
                                                   rper.tcomcon, rper.tvalcon, rper.cdomici,
                                                   rper.cprefix);   /* bug 24806*/

         IF vcmodcon IS NULL THEN
            BEGIN
               vcont := vcont + 1;

               SELECT NVL(MAX(cmodcon), 0) + vcont
                 INTO vcmodcon
                 FROM per_contactos
                WHERE sperson = psperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcmodcon := 1;
            END;
         END IF;

         INSERT INTO estper_contactos
                     (sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon, cdomici, cusuari,
                      fmovimi, cobliga, cprefix)
            (SELECT pficticia_sperson, vcagente_per, vcmodcon, ctipcon, tcomcon, tvalcon,
                    cdomici, f_user, f_sysdate, cobliga, cprefix
               FROM per_contactos
              WHERE sperson = rper.sperson
                AND cmodcon = rper.cmodcon
                AND cagente = rper.cagente);
      /* DRA 26-09-2008: bug mantis 7567*/
      END LOOP;

      INSERT INTO estper_vinculos
                  (sperson, cagente, cvinclo, cusuari, fmovimi)
         (SELECT pficticia_sperson, vcagente_per, cvinclo, f_user, f_sysdate
            FROM per_vinculos
           WHERE sperson = psperson
             AND cagente = vcagente_visio);

      /* DRA 26-09-2008: bug mantis 7567*/
      /* bug 12716 - 26/03/2010 - AMC*/
      INSERT INTO estper_irpf
                  (sperson, csitfam, cnifcon, cgrado, cayuda, ipension, ianuhijos, cusuari,
                   fmovimi, prolon, rmovgeo, nano, cagente, fmovgeo, cpago)
         (SELECT pficticia_sperson, csitfam, cnifcon, cgrado, cayuda, ipension, ianuhijos,
                 f_user, f_sysdate, prolon, rmovgeo, nano, vcagente_per, /* DRA 26-09-2008: bug mantis 7567*/ fmovgeo,
                 cpago
            FROM per_irpf
           WHERE sperson = psperson
             AND cagente = vcagente_visio);

      /* DRA 26-09-2008: bug mantis 7567*/
      INSERT INTO estper_irpfdescen
                  (sperson, fnacimi, cgrado, center, cusuari, fmovimi, norden, nano, cagente,
                   fadopcion)
         (SELECT pficticia_sperson, fnacimi, cgrado, center, f_user, f_sysdate, norden, nano,
                 vcagente_per, fadopcion
            FROM per_irpfdescen
           WHERE sperson = psperson
             AND cagente = vcagente_visio);

      /* fi bug 12716 - 26/03/2010 - AMC*/
      /* DRA 26-09-2008: bug mantis 7567*/
      INSERT INTO estper_irpfmayores
                  (sperson, fnacimi, cgrado, crenta, nviven, cusuari, fmovimi, norden, nano,
                   cagente)
         (SELECT pficticia_sperson, fnacimi, cgrado, crenta, nviven, f_user, f_sysdate, norden,
                 nano, vcagente_per
            FROM per_irpfmayores
           WHERE sperson = psperson
             AND cagente = vcagente_visio);

      /* DRA 26-09-2008: bug mantis 7567*/
      /* DRA 29-9-08: bug mantis 7567*/
      vcont := 0;

      /* RCL 12-06-13: BUG 27156. Recuperamos solo las CC activas.*/
      FOR rper IN (SELECT sperson, cnordban, cagente, ctipban, cbancar
                     FROM per_ccc
                    WHERE sperson = psperson
                      AND cagente = vcagente_visio
                      AND fbaja IS NULL) LOOP
         /* DRA 03-10-2008: bug mantis 6352*/
         vcnordban := pac_persona.f_existe_ccc(rper.sperson, vcagente_per, rper.ctipban,
                                               rper.cbancar);

         IF vcnordban IS NULL THEN
            BEGIN
               vcont := vcont + 1;

               SELECT NVL(MAX(cnordban), 0) + vcont
                 INTO vcnordban
                 FROM per_ccc
                WHERE sperson = psperson;
            EXCEPTION
               WHEN OTHERS THEN
                  vcnordban := 1;
            END;
         END IF;

         INSERT INTO estper_ccc
                     (sperson, cagente, ctipban, cbancar, fbaja, cdefecto, cusumov, fusumov,
                      cnordban /* Bug 20790 - APD - 03/01/2012 - valdia la ccc*/, cvalida,
                      cpagsin, fvencim, tseguri, falta, cusualta)
            (SELECT pficticia_sperson, vcagente_per, ctipban, cbancar, fbaja, cdefecto,
                    cusumov, fusumov,
                    vcnordban /* Bug 20790 - APD - 03/01/2012 - valdia la ccc*/, cvalida,
                    cpagsin, fvencim, tseguri, falta, cusualta
               FROM per_ccc
              WHERE sperson = rper.sperson
                AND cnordban = rper.cnordban
                AND cagente = rper.cagente);

         /* DRA 26-09-2008: bug mantis 7567*/
         /* RSA MANDATOS BUG 27500*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'INS_MANDATO'),
                0) = 1 THEN
            INSERT INTO estmandatos
                        (sperson, cnordban, ctipban, cbancar, ccobban, cmandato, cestado,
                         ffirma, fusualta, cusualta, fvencim, tseguri)
               SELECT pficticia_sperson, vcnordban, ctipban, cbancar, ccobban, cmandato,
                      cestado, ffirma, fusualta, cusualta, fvencim, tseguri
                 FROM mandatos
                WHERE sperson = rper.sperson
                  AND cnordban = rper.cnordban;
         END IF;
      END LOOP;

      /*JRH 05/2008*/
      INSERT INTO estper_identificador
                  (sperson, cagente, ctipide, nnumide, swidepri, femisio, fcaduca)
         (SELECT pficticia_sperson, vcagente_per, ctipide, nnumide, swidepri, femisio, fcaduca
            FROM per_identificador
           WHERE sperson = psperson
             AND cagente = vcagente_visio);

      /* DRA 26-09-2008: bug mantis 7567*/
      INSERT INTO estper_nacionalidades
                  (sperson, cagente, cpais, cdefecto)
         (SELECT pficticia_sperson, vcagente_per, cpais, cdefecto
            FROM per_nacionalidades
           WHERE sperson = psperson
             AND cagente = vcagente_visio);

      /* DRA 26-09-2008: bug mantis 7567*/
      /* Bug 25542 - APD - 10/01/2013*/
      INSERT INTO estper_antiguedad
                  (sperson, cagrupa, norden, fantiguedad, cestado, sseguro_ini, nmovimi_ini,
                   ffin, sseguro_fin, nmovimi_fin, falta, cusualt, fmodifi, cusumod)
         (SELECT pficticia_sperson, cagrupa, norden, fantiguedad, cestado, sseguro_ini,
                 nmovimi_ini, ffin, sseguro_fin, nmovimi_fin, falta, cusualt, fmodifi, cusumod
            FROM per_antiguedad
           WHERE sperson = psperson);

      /* fin Bug 25542 - APD - 10/01/2013*/
      /* i - jlb - 18/02/2014*/
      INSERT INTO estper_cargas
                  (sperson, tipo, proceso, cagente, ccodigo, cusuari, fecha)
         (SELECT pficticia_sperson, tipo, proceso, cagente, ccodigo, cusuari, fecha
            FROM per_cargas
           WHERE sperson = psperson);

      /* I _ JLB*/
      COMMIT;
   /* - I JLB*/
   EXCEPTION
      WHEN OTHERS THEN
         COMMIT;
         /* deberia ser un rollback, pero ahora no se hace en ningun sitio*/
         p_tab_error(f_sysdate, NVL(f_user, f_user), 'PAC_PERSONA', 1,
                     'TRASPASO_TABLAS_PER. Error WHEN OTHERS.  SPERSON = ' || psperson,
                     SQLERRM);
   END traspaso_tablas_per;

   FUNCTION f_sperson
      RETURN NUMBER IS
      vsperson       per_personas.sperson%TYPE;
   BEGIN
      SELECT sperson.NEXTVAL
        INTO vsperson
        FROM DUAL;

      RETURN vsperson;
   END f_sperson;

   FUNCTION f_estsperson
      RETURN NUMBER IS
      vsperson       estper_personas.sperson%TYPE;
   BEGIN
      SELECT spereal.NEXTVAL
        INTO vsperson
        FROM DUAL;

      RETURN vsperson;
   END f_estsperson;

   FUNCTION f_shisper(psperson IN hisper_personas.sperson%TYPE)
      RETURN NUMBER IS
      vnorden        hisper_personas.norden%TYPE;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM hisper_personas
       WHERE sperson = psperson;

      RETURN vnorden;
   END f_shisper;

   FUNCTION f_sperson_spereal(psperson IN estper_personas.sperson%TYPE)
      RETURN NUMBER IS
      vspereal       estper_personas.spereal%TYPE;
   BEGIN
      SELECT spereal
        INTO vspereal
        FROM estper_personas
       WHERE sperson = psperson;

      RETURN vspereal;
   EXCEPTION
      /*JRH 04/2008*/
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      /*JRH 04/2008*/
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_sperson_spereal. Error .  SPERSON = ' || psperson, SQLERRM);
         RETURN NULL;
   END f_sperson_spereal;

   FUNCTION f_spereal_sperson(
      psperson IN estper_personas.spereal%TYPE,
      psseguro IN estseguros.sseguro%TYPE)
      RETURN NUMBER IS
      vsperson       estper_personas.sperson%TYPE;
   /* Devuelve el sperson ficticio */
   BEGIN
      SELECT sperson
        INTO vsperson
        FROM estper_personas
       WHERE spereal = psperson
         AND sseguro = psseguro;

      RETURN vsperson;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_spereal_sperson. Error .  SPERSON = ' || psperson, SQLERRM);
         RETURN NULL;
   END f_spereal_sperson;

   FUNCTION f_shisdet(
      psperson IN hisper_detper.sperson%TYPE,
      pcagente IN hisper_detper.cagente%TYPE)
      RETURN NUMBER IS
      vnorden        hisper_detper.norden%TYPE;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM hisper_detper
       WHERE sperson = psperson
         AND cagente = pcagente;

      RETURN vnorden;
   END f_shisdet;

   FUNCTION f_shiscon(
      psperson IN hisper_contactos.sperson%TYPE,
      pcmodcon IN hisper_contactos.cmodcon%TYPE)
      RETURN NUMBER IS
      vnorden        hisper_contactos.norden%TYPE;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM hisper_contactos
       WHERE sperson = psperson
         AND cmodcon = pcmodcon;

      RETURN vnorden;
   END f_shiscon;

   FUNCTION f_valida_codigosdireccion(
      pcpais IN NUMBER,
      pcpoblac IN estper_direcciones.cpoblac%TYPE,
      pcprovin IN estper_direcciones.cprovin%TYPE,
      pcpostal IN estper_direcciones.cpostal%TYPE)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      dummy          NUMBER(8);
   BEGIN
      IF pcpais IS NULL THEN
         /*País no pot ser NULL.*/
         RETURN 140384;
      END IF;

      IF pcpoblac IS NULL THEN
         /*Població no pot ser NULL.*/
         RETURN 140085;
      END IF;

      IF pcprovin IS NULL THEN
         /*Provincia no pot ser NULL.*/
         RETURN 140380;
      END IF;

      /* Bug 18940/96714 - 03/11/2011 - AMC*/
      IF pcpostal IS NULL
         AND NVL(pac_parametros.f_parempresa_n(f_empres, 'CPOSTAL_NO_OBLIGA'), 0) = 0 THEN
         /*Codi Postal no pot ser NULL.*/
         RETURN 140084;
      END IF;

      BEGIN
         SELECT 1
           INTO dummy
           FROM provincias
          WHERE cprovin = pcprovin
            AND cpais = pcpais;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151012;
      END;

      BEGIN
         SELECT 1
           INTO dummy
           FROM poblaciones
          WHERE cprovin = pcprovin
            AND cpoblac = pcpoblac;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103222;
      END;

      IF pcpostal IS NOT NULL THEN
         BEGIN
            SELECT 1
              INTO dummy
              FROM codpostal
             WHERE cprovin = pcprovin
               AND cpoblac = pcpoblac
               AND cpostal = NVL(UPPER(pcpostal), '0');
         /* BUG14307:DRA:18/05/2010*/
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 108080;
         END;
      END IF;

      /* Fi Bug 18940/96714 - 03/11/2011 - AMC*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_valida_codigosdireccion', 99,
                     'SQLCODE: ' || SQLCODE, SQLERRM);
         RETURN 1000001;
   END;

   FUNCTION f_set_direccion(
      psperson IN estper_direcciones.sperson%TYPE,
      pcagente IN estper_direcciones.cagente%TYPE,
      pcdomici IN OUT estper_direcciones.cdomici%TYPE,
      pctipdir IN estper_direcciones.ctipdir%TYPE,
      pcsiglas IN estper_direcciones.csiglas%TYPE,
      ptnomvia IN estper_direcciones.tnomvia%TYPE,
      pnnumvia IN estper_direcciones.nnumvia%TYPE,
      ptcomple IN estper_direcciones.tcomple%TYPE,
      ptdomici IN estper_direcciones.tdomici%TYPE,
      pcpostal IN estper_direcciones.cpostal%TYPE,
      pcpoblac IN estper_direcciones.cpoblac%TYPE,
      pcprovin IN estper_direcciones.cprovin%TYPE,
      pcusuari IN estper_direcciones.cusuari%TYPE,
      pfmovimi IN estper_direcciones.fmovimi%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      perrores OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      /* Bug 18940/92686 - 27/09/2011 - AMC*/
      pcviavp IN estper_direcciones.cviavp%TYPE,
      pclitvp IN estper_direcciones.clitvp%TYPE,
      pcbisvp IN estper_direcciones.cbisvp%TYPE,
      pcorvp IN estper_direcciones.corvp%TYPE,
      pnviaadco IN estper_direcciones.nviaadco%TYPE,
      pclitco IN estper_direcciones.clitco%TYPE,
      pcorco IN estper_direcciones.corco%TYPE,
      pnplacaco IN estper_direcciones.nplacaco%TYPE,
      pcor2co IN estper_direcciones.cor2co%TYPE,
      pcdet1ia IN estper_direcciones.cdet1ia%TYPE,
      ptnum1ia IN estper_direcciones.tnum1ia%TYPE,
      pcdet2ia IN estper_direcciones.cdet2ia%TYPE,
      ptnum2ia IN estper_direcciones.tnum2ia%TYPE,
      pcdet3ia IN estper_direcciones.cdet3ia%TYPE,
      ptnum3ia IN estper_direcciones.tnum3ia%TYPE,
      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      plocalidad IN estper_direcciones.localidad%TYPE,
                                                     -- Bug 24780/130907 - 05/12/2012 - AMC
      ptalias IN estper_direcciones.talias%TYPE      -- BUG CONF-441 - 14/12/2016 - JAEG
   )
      RETURN NUMBER IS
      vcdomici_est   NUMBER := 0;
      i              NUMBER := 1;
      verr           ob_error;
      /* jlb - i - bug mantis 6352*/
      vsperreal      estper_personas.spereal%TYPE;
      /* jlb - f - bug mantis 6352*/
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      vidioma        NUMBER;
      terror         VARCHAR2(300);
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
       /* Cambios de IAXIS-4844 : start */
    VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;    
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    /* Cambios de IAXIS-4844 : end */
   BEGIN
      perrores := t_ob_error();
      perrores.DELETE;

      IF pctipdir IS NULL THEN
         RETURN 0;
      END IF;

      /* bug 7873*/
      /* Esta función nos sirve para recuperar el código de agente*/
      /* con el que se ha de grabar a partir del de producción.*/
      pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per, ptablas);

      IF ptablas = 'EST' THEN
         /*JRH 04/2008*/
         IF pcdomici IS NULL
            OR pcdomici = 0 THEN
            /* DRA 03-10-2008: bug mantis 6352*/
              /* jlb - i - bug mantis 6352*/
            SELECT spereal
              INTO vsperreal
              FROM estper_personas
             WHERE sperson = psperson;

            /* jlb - F - bug mantis 6352*/
            pcdomici := pac_persona.f_existe_direccion(vsperreal,
                                                       /* jlb - i - bug mantis 6352*/
                                                       vcagente_per,
                                                       /* bug 7873*/
                                                       pctipdir, pcsiglas, ptnomvia, pnnumvia,
                                                       ptcomple, ptdomici, UPPER(pcpostal),

                                                       /* BUG14307:DRA:18/05/2010*/
                                                       pcpoblac, pcprovin);

            IF pcdomici IS NULL THEN
               SELECT NVL(MAX(e.cdomici), 0)
                 INTO vcdomici_est
                 FROM estper_direcciones e, estper_personas p
                WHERE e.sperson = psperson
                  AND p.sperson = e.sperson;

               SELECT GREATEST(vcdomici_est, NVL(MAX(c.cdomici), 0)) + 1
                 INTO pcdomici
                 FROM per_direcciones c, estper_personas p
                WHERE p.sperson = psperson
                  AND c.sperson(+) = p.spereal;
            END IF;
         END IF;

         BEGIN
            /* Bug 18940/92686 - 27/09/2011 - AMC*/
            INSERT INTO estper_direcciones
                        (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia,
                         nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin,
                         cusuari, fmovimi, cviavp, clitvp,
                         cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                         cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia,
                         localidad, /* Bug 24780/130907 - 05/12/2012 - AMC*/
       talias)  -- BUG CONF-441 - 14/12/2016 - JAEG
                 VALUES (psperson, vcagente_per, pcdomici, pctipdir, pcsiglas, ptnomvia,
                         pnnumvia, ptcomple, ptdomici, UPPER(pcpostal), /* BUG14307:DRA:18/05/2010*/ pcpoblac, pcprovin,
                         NVL(pcusuari, f_user), NVL(pfmovimi, f_sysdate), pcviavp, pclitvp,
                         pcbisvp, pcorvp, pnviaadco, pclitco, pcorco, pnplacaco, pcor2co,
                         pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia, ptnum3ia,
                         plocalidad, /* Bug 24780/130907 - 05/12/2012 - AMC*/
       ptalias);  -- BUG CONF-441 - 14/12/2016 - JAEG
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE estper_direcciones
                     SET cdomici = pcdomici,
                         ctipdir = pctipdir,
                         csiglas = pcsiglas,
                         tnomvia = ptnomvia,
                         nnumvia = pnnumvia,
                         tcomple = ptcomple,
                         tdomici = ptdomici,
                         cpostal = UPPER(pcpostal),
                         /* BUG14307:DRA:18/05/2010*/
                         cpoblac = pcpoblac,
                         cprovin = pcprovin,
                         cusuari = NVL(pcusuari, f_user),
                         fmovimi = NVL(pfmovimi, f_sysdate),
                         cviavp = pcviavp,
                         clitvp = pclitvp,
                         cbisvp = pcbisvp,
                         corvp = pcorvp,
                         nviaadco = pnviaadco,
                         clitco = pclitco,
                         corco = pcorco,
                         nplacaco = pnplacaco,
                         cor2co = pcor2co,
                         cdet1ia = pcdet1ia,
                         tnum1ia = ptnum1ia,
                         cdet2ia = pcdet2ia,
                         tnum2ia = ptnum2ia,
                         cdet3ia = pcdet3ia,
                         tnum3ia = ptnum3ia,
                         localidad = plocalidad,
       talias = ptalias  -- BUG CONF-441 - 14/12/2016 - JAEG
                   /* Bug 24780/130907 - 05/12/2012 - AMC*/
                  WHERE  sperson = psperson
                     AND cdomici = pcdomici;
               EXCEPTION
                  WHEN OTHERS THEN
                     perrores.EXTEND;
                     verr := ob_error.instanciar(140269,
                                                 f_axis_literales(140269, pcidioma) || '  '
                                                 || SQLERRM);
                     perrores(i) := verr;
               END;
            WHEN OTHERS THEN
               perrores.EXTEND;
               verr := ob_error.instanciar(140269,
                                           f_axis_literales(140269, pcidioma) || '  '
                                           || SQLERRM);
               perrores(i) := verr;
               RETURN 1;
         END;
      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      ELSE
         /* ESTAMOS EN LAS TABLAS REALES*/
         IF pcdomici IS NULL THEN
            SELECT NVL(MAX(cdomici), 0) + 1
              INTO pcdomici
              FROM per_direcciones
             WHERE sperson = psperson;
         END IF;

         /* Bug 18940/92686 - 27/09/2011 - AMC*/
         BEGIN
            INSERT INTO per_direcciones
                        (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia,
                         nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin,
                         cusuari, fmovimi, cviavp, clitvp,
                         cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                         cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia,
                         localidad, /* Bug 24780/130907 - 05/12/2012 - AMC*/
       talias)  -- BUG CONF-441 - 14/12/2016 - JAEG
                 VALUES (psperson, pcagente, pcdomici, pctipdir, pcsiglas, ptnomvia,
                         pnnumvia, ptcomple, ptdomici, UPPER(pcpostal), /* BUG14307:DRA:18/05/2010*/ pcpoblac, pcprovin,
                         NVL(pcusuari, f_user), NVL(pfmovimi, f_sysdate), pcviavp, pclitvp,
                         pcbisvp, pcorvp, pnviaadco, pclitco, pcorco, pnplacaco, pcor2co,
                         pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia, ptnum3ia,
                         plocalidad, /* Bug 24780/130907 - 05/12/2012 - AMC*/
       ptalias);  -- BUG CONF-441 - 14/12/2016 - JAEG

         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE per_direcciones
                     SET cdomici = pcdomici,
                         ctipdir = pctipdir,
                         csiglas = pcsiglas,
                         tnomvia = ptnomvia,
                         nnumvia = pnnumvia,
                         tcomple = ptcomple,
                         tdomici = ptdomici,
                         cpostal = UPPER(pcpostal),
                         /* BUG14307:DRA:18/05/2010*/
                         cpoblac = pcpoblac,
                         cprovin = pcprovin,
                         cusuari = NVL(pcusuari, f_user),
                         fmovimi = NVL(pfmovimi, f_sysdate),
                         cviavp = pcviavp,
                         clitvp = pclitvp,
                         cbisvp = pcbisvp,
                         corvp = pcorvp,
                         nviaadco = pnviaadco,
                         clitco = pclitco,
                         corco = pcorco,
                         nplacaco = pnplacaco,
                         cor2co = pcor2co,
                         cdet1ia = pcdet1ia,
                         tnum1ia = ptnum1ia,
                         cdet2ia = pcdet2ia,
                         tnum2ia = ptnum2ia,
                         cdet3ia = pcdet3ia,
                         tnum3ia = ptnum3ia,
                         localidad = plocalidad,
       talias = ptalias  -- BUG CONF-441 - 14/12/2016 - JAEG
                   /* Bug 24780/130907 - 05/12/2012 - AMC*/
                  WHERE  sperson = psperson
                     AND cdomici = pcdomici;
               EXCEPTION
                  WHEN OTHERS THEN
                     perrores.EXTEND;
                     verr := ob_error.instanciar(140269,
                                                 f_axis_literales(140269, pcidioma) || '  '
                                                 || SQLERRM);
                     perrores(i) := verr;
               END;
            WHEN OTHERS THEN
               perrores.EXTEND;
               verr := ob_error.instanciar(140269,
                                           f_axis_literales(140269, pcidioma) || '  '
                                           || SQLERRM);
               perrores(i) := verr;
               RETURN 1;
         END;

         /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'MODIF_PERSONA_HOST'),
                0) = 1
            AND ptablas = 'POL' THEN
            num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               perrores.EXTEND;
               verr := ob_error.instanciar(num_err, SQLERRM);
               perrores(i) := verr;
               RETURN num_err;
            END IF;

            /* Cambios de IAXIS-4844 : start */
              BEGIN
                SELECT PP.NNUMIDE,PP.TDIGITOIDE
                  INTO VPERSON_NUM_ID,VDIGITOIDE
                  FROM PER_PERSONAS PP
                 WHERE PP.SPERSON = psperson
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  SELECT PP.CTIPIDE, PP.NNUMIDE
                    INTO VCTIPIDE, VPERSON_NUM_ID
                    FROM PER_PERSONAS PP
                   WHERE PP.SPERSON = psperson;
                  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                                 UPPER(VPERSON_NUM_ID));
              END;
            /* Cambios de IAXIS-4844 : end */

            /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
            v_host := NULL;

            /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
            END IF;
            /* Cambios de IAXIS-4844 : start */
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                              v_host);
            /* Cambios de IAXIS-4844 : end */

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               perrores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               perrores(i) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               perrores.EXTEND;
               i := i + 1;
               perrores(i) := verr;
               RETURN num_err;
            END IF;

            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
            /* Cambios de IAXIS-4844 : end */

               IF num_err <> 0 THEN
                  perrores.EXTEND;
                  verr := ob_error.instanciar(num_err, terror);
                  perrores(i) := verr;
                  /*añado error del tmenin*/
                  verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                              pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                  perrores.EXTEND;
                  i := i + 1;
                  perrores(i) := verr;
                  RETURN num_err;
               END IF;
            END IF;
         /*fin BUG 0026318 -- GGR -- 17/03/2014*/
         
         /* Cambios de  tarea IAXIS-13044 :start */
                PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID, 1, 'S03502',PSINTERF);                 
         /* Cambios de  tarea IAXIS-13044 :end */          
         
         END IF;
      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      END IF;

      /* Bug 26318 - 10/10/2013 - JMG - Inicio #155391 Anotación en la agenda de las pólizas*/
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PER_AGENDA'), 0) =
                                                                                              1
         AND ptablas = 'POL' THEN
         num_err := f_set_agensegu_rol(psperson, 'DIR', pcidioma);

         IF num_err <> 0 THEN
            /*vtraza := 55;*/
            perrores.EXTEND;
            verr := ob_error.instanciar(num_err, SQLERRM);
            perrores(i) := verr;
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         perrores.DELETE;
         perrores.EXTEND;
         verr := ob_error.instanciar(140269,
                                     f_axis_literales(140269, pcidioma) || '  ' || SQLERRM);
         perrores(i) := verr;
         RETURN 1;
   END f_set_direccion;
   --
   -- Inicio IAXIS-2091 19/02/2019 AABC
   --
   /*************************************************************************
   FUNCTION f_act_ozpagalt
   Funcion que actualiza pagador alternativo en oziris.
   psperson     IN NUMBER Tercero
   psperson_rel IN NUMBER Pagador alternativo a agregar
   pcoperacion  IN NUMBER 1 - Agregar/Habilitar pagador alternativo; 2 - Dar de baja al Pagador Alternativo
   La funci¿n devuelve 0 si ha ido bien 1 si hay error
 2.0     01/04/2018    CES       2.0 IAXIS-2090: Ajuste parametro de activación o apagado convivencia.
   *************************************************************************/
   --
   FUNCTION f_act_ozpagalt (psperson     IN NUMBER,
                           psperson_rel IN NUMBER,
                           pcoperacion  IN NUMBER)
   RETURN NUMBER IS
   --
     vnit_alt      per_personas.nnumide%TYPE;
     vsperdeud     per_personas.sperson_deud%TYPE;
     vscont        NUMBER;
     vnerr         NUMBER;
     vdblink       VARCHAR2(30);
     vtabla        VARCHAR2(30);
     vselect       VARCHAR2(32000);
     vinsert       VARCHAR2(32000);
     SI_CONVIVENCIA VARCHAR2(1);  -- 0 => Apagado | 1 => Encendido
   --
   BEGIN
    --INI-CES IAXIS-2090
    SI_CONVIVENCIA := f_parempresa_t ('CONVIVENCIA',24);

     --
     -- Agregar/Habilitar Pagador Alternativo
     IF pcoperacion = 1 AND SI_CONVIVENCIA= '1' THEN
        --END-CESIAXIS-2090
        FOR X IN (SELECT * FROM per_personas WHERE sperson = psperson) LOOP
           --
           BEGIN
             --
             SELECT p.nnumide,p.sperson_deud
               INTO vnit_alt,vsperdeud
               FROM per_personas p
              WHERE sperson =  psperson_rel;
             --
            END;
           --Inicio IAXIS 2091 AABC
           vdblink := f_parinstalacion_t('DBLINK');
           vtabla := 'PAGADOR_ALT'||VDBLINK;
           vselect := ' begin SELECT COUNT (*) INTO :vscont FROM '|| VTABLA ||' WHERE CODDEU   = '|| x.SPERSON_DEUD ||' AND CODPAGALT = '|| vsperdeud ||' ;  end;';
           EXECUTE IMMEDIATE vselect
             USING OUT       vscont;
           --Fin IAXIS 2091 AABC
           IF vscont = 0 THEN
             --
             vinsert := ' begin INSERT INTO '||VTABLA||' (nit,coddeu,nitpagalt,codpagalt) VALUES ( :x.numide , to_char( :x.sperson_deud  ), :vnit_alt , to_char( :vsperdeud )) ;  end;';
             EXECUTE IMMEDIATE vinsert
             USING x.nnumide , x.sperson_deud , vnit_alt , vsperdeud ;
             --
           END IF;
           --
        END LOOP;
        --
    END IF;
   --
   RETURN 0;
   --
   EXCEPTION WHEN OTHERS THEN
     p_tab_error
            (f_sysdate,
             f_user,
             'PAC_PERSONA.',
             1,
             'f_act_ozpagalt. Error insertando o borrando pagador en Oziris.',
             SQLERRM
            );
     RETURN 1;
   END f_act_ozpagalt;
   -- FIn IAXIS 2091 AABC 19/02/2019
   -- Inicio TCS-460 01/02/2019
   --
   /*************************************************************************
   FUNCTION f_pagador_alt
   Funcion que agrega o quita los pagadores alternativos relacionados a un tercero
   psperson     IN NUMBER Tercero
   pcagente     IN NUMBER Agente
   psperson_rel IN NUMBER Pagador alternativo a agregar
   pctipper_rel IN NUMBER Tipo de persona relacionada
   pcoperacion  IN NUMBER 1 - Agregar/Habilitar pagador alternativo; 2 - Dar de baja al Pagador Alternativo
   La función devuelve 0 si ha ido bien 1 si hay error
   *************************************************************************/
   --
  FUNCTION f_pagador_alt (psperson     IN NUMBER,
                           psperson_rel IN NUMBER,
                           pctipper_rel IN NUMBER DEFAULT NULL,
                           pcoperacion  IN NUMBER)
   RETURN NUMBER IS
   --
     vsperson_cons per_personas.sperson%TYPE;
     vscont        NUMBER;
     vnerr         NUMBER;
     vcterm        usuarios.cterminal%TYPE;
     vterr         VARCHAR2(300);
     vsinterf      NUMBER;
     vcact         NUMBER; -- Es un tipo de pagador alternativo permitido. 1 - S¿; 0 - No
     vctippagalt   NUMBER; -- Mapeo de Tipo de Persona Relacionada a Tipo de Pagador Alternativo
     vcrafectado   NUMBER := 0; --Permite saber si se alter¿ un registro en la tabla o no.
     v_contexto number := 0;  -- IAXIS 2091 AABC 19/02/2019 Convivencia Pagador Alternativo
   --
   BEGIN
     --Inicio IAXIS 2091 AABC 19/02/2019 Convivencia Pagador Alternativo
     --Inicio IAXIS-7735 JRVG 26/12/2019 Pagador Alternativo
     IF pctipper_rel in (0,1,3) THEN
        --
        v_contexto := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24,'USER_BBDD'));
        --
     END IF;
     -- Fin IAXIS 2091 AABC 19/02/2019 Convivencia Pagador Alternativo
      /*vcact := NVL(pac_subtablas.f_vsubtabla( p_in_nsesion   => -1,
                                             p_in_csubtabla => 9000009,
                                             p_in_cquery    => 3,
                                             p_in_cval      => 1,
                                             p_in_ccla1     => pctipper_rel), 0);*/
     --
     -- Agregar/Habilitar Pagador Alternativo

     IF pcoperacion = 1 /*AND vcact = 1*/ THEN
       --
       IF pctipper_rel = 1 THEN 
          vctippagalt := 1; -- intermediario 
       ELSIF pctipper_rel = 0 THEN 
          vctippagalt := 2;-- consorcio / union t
       ELSIF pctipper_rel = 3 THEN
          vctippagalt := 3;-- osiris
       ELSE 
          vctippagalt := 4;-- otro
       END IF;

       /*vctippagalt := NVL(pac_subtablas.f_vsubtabla( p_in_nsesion   => -1,
                                                     p_in_csubtabla => 9000009,
                                                     p_in_cquery    => 3,
                                                     p_in_cval      => 2,
                                                     p_in_ccla1     => pctipper_rel), 0);*/
       --
       BEGIN
         -- Se verifica si ya existe el pagador alternativo
         SELECT COUNT(*)
           INTO vscont
           FROM per_pagador_alt
          WHERE sperson     = psperson
            AND sperson_rel = psperson_rel
            AND ctippagalt  = vctippagalt
            AND cestado     IN (0,1);
           --
       END;
         --
         -- Si no existe, se crea el pagador alternativo
         IF vscont = 0 THEN
           --
           INSERT INTO per_pagador_alt
             ( sperson, sperson_rel, ctippagalt, cestado )

           VALUES
             ( psperson, psperson_rel, vctippagalt, 1 );
           --
           vcrafectado := SQL%ROWCOUNT;
           --
         -- Si ya existe, se activa nuevamente si est¿ desactivado.
         ELSE
           --
           UPDATE per_pagador_alt
              SET cestado = 1,
                  cusubaj = NULL,
                  fusubaj = NULL
            WHERE sperson     = psperson
              AND sperson_rel = psperson_rel
              AND ctippagalt  = vctippagalt
              AND cestado     = 0;
           --
           vcrafectado := SQL%ROWCOUNT;
           --
         END IF;
     -- Baja del Pagador Alternativo
     ELSIF pcoperacion = 2 THEN
       --
       UPDATE per_pagador_alt
          SET cestado = 0,
              cusubaj = f_user,
              fusubaj = TO_DATE(SYSDATE,'DD/MM/YYYY')
        WHERE sperson     = psperson
          AND sperson_rel = psperson_rel
          AND ctippagalt  = vctippagalt
          AND cestado     = 1;
       --
       vcrafectado := SQL%ROWCOUNT;
       --
     --
     END IF;
 -- Inicio IAXIS 2091 AABC 19/02/2019 Convivencia Pagador Alternativo
     /*IF pctipper_rel <> 3 THEN
     --
        vnerr := f_act_ozpagalt(psperson,psperson_rel,pcoperacion);
        --
     END IF;*/
   -- FIN IAXIS-7735 JRVG 26/12/2019 Pagador Alternativo
   -- Fin IAXIS 2091 AABC 19/02/2019 Convivencia Pagador Alternativo

   -- Si todo ha ido bien, y se ha hecho alguna alteraci¿n, enviamos la lista actualizada de pagadores alternativos.

      IF vcrafectado > 0 THEN
       --

      /* vsinterf := NULL;
       /*vnerr    := pac_user.f_get_terminal(f_user, vcterm);
       vnerr    := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson, vcterm, vsinterf,
                                          vterr, pac_md_common.f_get_cxtusuario, 1);*/
       --
          return 1;
      else
          return 0;
      end if;

   --
   EXCEPTION WHEN OTHERS THEN
     p_tab_error
            (f_sysdate,
             f_user,
             'PAC_PERSONA.',
             1,
             'f_pagador_alt. Error Imprevisto insertando pagador alternativo.',
             SQLERRM
            );
     RETURN 1;
   END f_pagador_alt;
   --
   /*************************************************************************
    FUNCTION f_get_sperson_age: Devuelve el sperson del agente
    param in  pcagente      : Código del agente
    param out psperson_age  : Sperson del agente
    return              : 0.- OK, 1.- KO
    *************************************************************************/
   --
   FUNCTION f_get_sperson_age(pcagente IN NUMBER, psperson_age OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT a.sperson
        INTO psperson_age
        FROM agentes a
       WHERE a.cagente = pcagente;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         psperson_age := NULL;
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_persona.f_get_sperson_age', 1,
                     'when others pcagente =' || pcagente, SQLERRM);
         RETURN 1;
   END f_get_sperson_age;
   --
   -- Fin TCS-460 01/02/2019
   --
   PROCEDURE p_set_direccion(
      psperson IN estper_direcciones.sperson%TYPE,
      pcagente IN estper_direcciones.cagente%TYPE,
      pcdomici IN OUT estper_direcciones.cdomici%TYPE,
      pctipdir IN estper_direcciones.ctipdir%TYPE,
      pcsiglas IN estper_direcciones.csiglas%TYPE,
      ptnomvia IN estper_direcciones.tnomvia%TYPE,
      pnnumvia IN estper_direcciones.nnumvia%TYPE,
      ptcomple IN estper_direcciones.tcomple%TYPE,
      ptdomici IN estper_direcciones.tdomici%TYPE,
      pcpostal IN estper_direcciones.cpostal%TYPE,
      pcpoblac IN estper_direcciones.cpoblac%TYPE,
      pcprovin IN estper_direcciones.cprovin%TYPE,
      pcusuari IN estper_direcciones.cusuari%TYPE,
      pfmovimi IN estper_direcciones.fmovimi%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      perrores OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      /* Bug 18940/92686 - 27/09/2011 - AMC*/
      pcviavp IN estper_direcciones.cviavp%TYPE,
      pclitvp IN estper_direcciones.clitvp%TYPE,
      pcbisvp IN estper_direcciones.cbisvp%TYPE,
      pcorvp IN estper_direcciones.corvp%TYPE,
      pnviaadco IN estper_direcciones.nviaadco%TYPE,
      pclitco IN estper_direcciones.clitco%TYPE,
      pcorco IN estper_direcciones.corco%TYPE,
      pnplacaco IN estper_direcciones.nplacaco%TYPE,
      pcor2co IN estper_direcciones.cor2co%TYPE,
      pcdet1ia IN estper_direcciones.cdet1ia%TYPE,
      ptnum1ia IN estper_direcciones.tnum1ia%TYPE,
      pcdet2ia IN estper_direcciones.cdet2ia%TYPE,
      ptnum2ia IN estper_direcciones.tnum2ia%TYPE,
      pcdet3ia IN estper_direcciones.cdet3ia%TYPE,
      ptnum3ia IN estper_direcciones.tnum3ia%TYPE,
      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      plocalidad IN estper_direcciones.localidad%TYPE,
      /* Bug 24780/130907 - 05/12/2012 - AMC*/
      pfdefecto IN estper_direcciones.fdefecto%TYPE) IS
      vcdomici_est   NUMBER := 0;
      i              NUMBER := 1;
      verr           ob_error;
      /* jlb - i - bug mantis 6352*/
      vsperreal      estper_personas.spereal%TYPE;
      /* jlb - f - bug mantis 6352*/
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
   BEGIN
      perrores := t_ob_error();
      perrores.DELETE;
      /* bug 7873*/
      /* Esta función nos sirve para recuperar el código de agente*/
      /* con el que se ha de grabar a partir del de producción.*/
      pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per, ptablas);

      IF ptablas = 'EST' THEN
         /*JRH 04/2008*/
         IF pcdomici IS NULL
            OR pcdomici = 0 THEN
            /* DRA 03-10-2008: bug mantis 6352*/
              /* jlb - i - bug mantis 6352*/
            SELECT spereal
              INTO vsperreal
              FROM estper_personas
             WHERE sperson = psperson;

            /* jlb - F - bug mantis 6352*/
            pcdomici := pac_persona.f_existe_direccion(vsperreal,
                                                       /* jlb - i - bug mantis 6352*/
                                                       vcagente_per,
                                                       /* bug 7873*/
                                                       pctipdir, pcsiglas, ptnomvia, pnnumvia,
                                                       ptcomple, ptdomici, UPPER(pcpostal),

                                                       /* BUG14307:DRA:18/05/2010*/
                                                       pcpoblac, pcprovin);

            IF pcdomici IS NULL THEN
               SELECT NVL(MAX(e.cdomici), 0)
                 INTO vcdomici_est
                 FROM estper_direcciones e, estper_personas p
                WHERE e.sperson = psperson
                  AND p.sperson = e.sperson;

               SELECT GREATEST(vcdomici_est, NVL(MAX(c.cdomici), 0)) + 1
                 INTO pcdomici
                 FROM per_direcciones c, estper_personas p
                WHERE p.sperson = psperson
                  AND c.sperson(+) = p.spereal;
            END IF;
         END IF;

         BEGIN
            /* Bug 18940/92686 - 27/09/2011 - AMC*/
            INSERT INTO estper_direcciones
                        (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia,
                         nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin,
                         cusuari, fmovimi, cviavp, clitvp,
                         cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                         cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia,
                         localidad, fdefecto /* Bug 24780/130907 - 05/12/2012 - AMC*/)
                 VALUES (psperson, vcagente_per, pcdomici, pctipdir, pcsiglas, ptnomvia,
                         pnnumvia, ptcomple, ptdomici, UPPER(pcpostal), /* BUG14307:DRA:18/05/2010*/ pcpoblac, pcprovin,
                         NVL(pcusuari, f_user), NVL(pfmovimi, f_sysdate), pcviavp, pclitvp,
                         pcbisvp, pcorvp, pnviaadco, pclitco, pcorco, pnplacaco, pcor2co,
                         pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia, ptnum3ia,
                         plocalidad, pfdefecto /* Bug 24780/130907 - 05/12/2012 - AMC*/);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE estper_direcciones
                     SET cdomici = pcdomici,
                         ctipdir = pctipdir,
                         csiglas = pcsiglas,
                         tnomvia = ptnomvia,
                         nnumvia = pnnumvia,
                         tcomple = ptcomple,
                         tdomici = ptdomici,
                         cpostal = UPPER(pcpostal),
                         /* BUG14307:DRA:18/05/2010*/
                         cpoblac = pcpoblac,
                         cprovin = pcprovin,
                         cusuari = NVL(pcusuari, f_user),
                         fmovimi = NVL(pfmovimi, f_sysdate),
                         cviavp = pcviavp,
                         clitvp = pclitvp,
                         cbisvp = pcbisvp,
                         corvp = pcorvp,
                         nviaadco = pnviaadco,
                         clitco = pclitco,
                         corco = pcorco,
                         nplacaco = pnplacaco,
                         cor2co = pcor2co,
                         cdet1ia = pcdet1ia,
                         tnum1ia = ptnum1ia,
                         cdet2ia = pcdet2ia,
                         tnum2ia = ptnum2ia,
                         cdet3ia = pcdet3ia,
                         tnum3ia = ptnum3ia,
                         localidad = plocalidad
                   /* Bug 24780/130907 - 05/12/2012 - AMC*/
                  WHERE  sperson = psperson
                     AND cdomici = pcdomici;
               /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
               EXCEPTION
                  WHEN OTHERS THEN
                     perrores.EXTEND;
                     verr := ob_error.instanciar(140269,
                                                 f_axis_literales(140269, pcidioma) || '  '
                                                 || SQLERRM);
                     perrores(i) := verr;
               END;
            WHEN OTHERS THEN
               perrores.EXTEND;
               verr := ob_error.instanciar(140269,
                                           f_axis_literales(140269, pcidioma) || '  '
                                           || SQLERRM);
               perrores(i) := verr;
         END;
      ELSE
         /* ESTAMOS EN LAS TABLAS REALES*/
         IF pcdomici IS NULL THEN
            SELECT NVL(MAX(cdomici), 0) + 1
              INTO pcdomici
              FROM per_direcciones
             WHERE sperson = psperson;
         END IF;

         BEGIN
            /* Bug 18940/92686 - 27/09/2011 - AMC*/
            INSERT INTO per_direcciones
                        (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia,
                         nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin,
                         cusuari, fmovimi, cviavp, clitvp,
                         cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                         cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia,
                         localidad /* Bug 24780/130907 - 05/12/2012 - AMC*/)
                 VALUES (psperson, pcagente, pcdomici, pctipdir, pcsiglas, ptnomvia,
                         pnnumvia, ptcomple, ptdomici, UPPER(pcpostal), /* BUG14307:DRA:18/05/2010*/ pcpoblac, pcprovin,
                         NVL(pcusuari, f_user), NVL(pfmovimi, f_sysdate), pcviavp, pclitvp,
                         pcbisvp, pcorvp, pnviaadco, pclitco, pcorco, pnplacaco, pcor2co,
                         pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia, ptnum3ia,
                         plocalidad /* Bug 24780/130907 - 05/12/2012 - AMC*/);

         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE per_direcciones
                     SET cdomici = pcdomici,
                         ctipdir = pctipdir,
                         csiglas = pcsiglas,
                         tnomvia = ptnomvia,
                         nnumvia = pnnumvia,
                         tcomple = ptcomple,
                         tdomici = ptdomici,
                         cpostal = UPPER(pcpostal),
                         /* BUG14307:DRA:18/05/2010*/
                         cpoblac = pcpoblac,
                         cprovin = pcprovin,
                         cusuari = NVL(pcusuari, f_user),
                         fmovimi = NVL(pfmovimi, f_sysdate),
                         cviavp = pcviavp,
                         clitvp = pclitvp,
                         cbisvp = pcbisvp,
                         corvp = pcorvp,
                         nviaadco = pnviaadco,
                         clitco = pclitco,
                         corco = pcorco,
                         nplacaco = pnplacaco,
                         cor2co = pcor2co,
                         cdet1ia = pcdet1ia,
                         tnum1ia = ptnum1ia,
                         cdet2ia = pcdet2ia,
                         tnum2ia = ptnum2ia,
                         cdet3ia = pcdet3ia,
                         tnum3ia = ptnum3ia,
                         localidad = plocalidad
                   /* Bug 24780/130907 - 05/12/2012 - AMC*/
                  WHERE  sperson = psperson
                     AND cdomici = pcdomici;
               /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/

               EXCEPTION
                  WHEN OTHERS THEN
                     perrores.EXTEND;
                     verr := ob_error.instanciar(140269,
                                                 f_axis_literales(140269, pcidioma) || '  '
                                                 || SQLERRM);
                     perrores(i) := verr;
               END;
            WHEN OTHERS THEN
               perrores.EXTEND;
               verr := ob_error.instanciar(140269,
                                           f_axis_literales(140269, pcidioma) || '  '
                                           || SQLERRM);
               perrores(i) := verr;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         perrores.DELETE;
         perrores.EXTEND;
         verr := ob_error.instanciar(140269,
                                     f_axis_literales(140269, pcidioma) || '  ' || SQLERRM);
         perrores(i) := verr;
   END p_set_direccion;

   PROCEDURE p_del_direccion(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      errores OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      i              NUMBER := 1;
      verr           ob_error;
      vcont          NUMBER;
      vspereal       estper_personas.sperson%TYPE;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF ptablas = 'EST' THEN
         SELECT spereal
           INTO vspereal
           FROM estper_personas
          WHERE sperson = psperson;

         BEGIN
            SELECT COUNT(1)
              INTO vcont
              FROM per_direcciones d
             WHERE sperson = vspereal
               AND cdomici = pcdomici
               AND EXISTS(SELECT sperson, cdomici
                            FROM agentes a
                           WHERE a.sperson = vspereal
                             AND a.cdomici = pcdomici
                          UNION
                          SELECT sperson, cdomici
                            FROM asegurados a
                           WHERE a.sperson = vspereal
                             AND a.cdomici = pcdomici
                          UNION
                          SELECT sperson, cdomici
                            FROM tomadores t
                           WHERE t.sperson = vspereal
                             AND t.cdomici = pcdomici
                          UNION
                          SELECT sperson, cdomici
                            FROM riesgos r
                           WHERE r.sperson = vspereal
                             AND r.cdomici = pcdomici
                          UNION
                          SELECT sperson, cdomici
                            FROM per_contactos p
                           WHERE p.sperson = vspereal
                             AND p.cdomici = pcdomici);

            IF vcont > 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180045, f_axis_literales(9908980, pcidioma));
               errores(i) := verr;
            ELSE
               DELETE FROM estper_direcciones
                     WHERE sperson = psperson
                       AND cdomici = pcdomici;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(9908980,
                                           f_axis_literales(9908980, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      ELSE
         BEGIN
            SELECT COUNT(1)
              INTO vcont
              FROM per_direcciones d
             WHERE sperson = psperson
               AND cdomici = pcdomici
               AND EXISTS(SELECT sperson, cdomici
                            FROM agentes a
                           WHERE a.sperson = psperson
                             AND a.cdomici = pcdomici
                          UNION
                          SELECT sperson, cdomici
                            FROM asegurados a
                           WHERE a.sperson = psperson
                             AND a.cdomici = pcdomici
                          UNION
                          SELECT sperson, cdomici
                            FROM tomadores t
                           WHERE t.sperson = psperson
                             AND t.cdomici = pcdomici
                          UNION
                          SELECT sperson, cdomici
                            FROM riesgos r
                           WHERE r.sperson = psperson
                             AND r.cdomici = pcdomici
                          UNION
                          SELECT sperson, cdomici
                            FROM per_contactos p
                           WHERE p.sperson = psperson
                             AND p.cdomici = pcdomici);

            IF vcont > 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(9908980, f_axis_literales(9908980, pcidioma));
               errores(i) := verr;
            ELSE
               DELETE FROM per_direcciones
                     WHERE sperson = psperson
                       AND cdomici = pcdomici;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(9908980,
                                           f_axis_literales(9908980, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(9908980,
                                     f_axis_literales(9908980, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
   END;

   PROCEDURE p_del_nacionalidad(
      psperson IN estper_nacionalidades.sperson%TYPE,
      pcpais IN estper_nacionalidades.cpais%TYPE,
      pcagente IN estper_nacionalidades.cagente%TYPE,
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      i              NUMBER := 1;
      verr           ob_error;
      vcont          NUMBER;
      vspereal       estper_personas.sperson%TYPE;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF ptablas = 'EST' THEN
         BEGIN
            /* bug 7873*/
            /* Esta función nos sirve para recuperar el código de agente*/
                /* con el que se ha de grabar a partir del de producción.*/
            pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per,
                                        ptablas);

            DELETE FROM estper_nacionalidades
                  WHERE sperson = psperson
                    AND cpais = pcpais
                    AND cagente = vcagente_per;
         /* DRA 13-10-2008: bug mantis 7784*/
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180031,
                                           f_axis_literales(180031, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      ELSE
         BEGIN
            DELETE FROM per_nacionalidades
                  WHERE sperson = psperson
                    AND cpais = pcpais
                    AND cagente = pcagente;
         /* DRA 13-10-2008: bug mantis 7784*/
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180031,
                                           f_axis_literales(180031, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(180031,
                                     f_axis_literales(180031, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
   END;

   PROCEDURE p_del_contacto(
      psperson IN estper_contactos.sperson%TYPE,
      psmodcon IN estper_contactos.cmodcon%TYPE,
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      i              NUMBER := 1;
      verr           ob_error;
      vcont          NUMBER;
      vspereal       estper_personas.sperson%TYPE;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF ptablas = 'EST' THEN
         BEGIN
            DELETE FROM estper_contactos
                  WHERE sperson = psperson
                    AND cmodcon = psmodcon;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180031,
                                           f_axis_literales(180031, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      ELSE
         BEGIN
            DELETE FROM per_contactos
                  WHERE sperson = psperson
                    AND cmodcon = psmodcon;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180031,
                                           f_axis_literales(180031, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(180031,
                                     f_axis_literales(180031, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
   END;

   FUNCTION f_shisdir(
      psperson IN hisper_direcciones.sperson%TYPE,
      pcdomici IN hisper_direcciones.cdomici%TYPE)
      RETURN NUMBER IS
      vnorden        hisper_direcciones.norden%TYPE;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM hisper_direcciones
       WHERE sperson = psperson
         AND cdomici = pcdomici;

      RETURN vnorden;
   END f_shisdir;

   FUNCTION f_tdomici(
      pcsiglas IN per_direcciones.csiglas%TYPE,
      ptnomvia IN per_direcciones.tnomvia%TYPE,
      pnnumvia IN per_direcciones.nnumvia%TYPE,
      ptcomple IN per_direcciones.tcomple%TYPE,
      /* Bug 18940/92686 - 27/09/2011 - AMC*/
      pcviavp IN per_direcciones.cviavp%TYPE DEFAULT NULL,
      pclitvp IN per_direcciones.clitvp%TYPE DEFAULT NULL,
      pcbisvp IN per_direcciones.cbisvp%TYPE DEFAULT NULL,
      pcorvp IN per_direcciones.corvp%TYPE DEFAULT NULL,
      pnviaadco IN per_direcciones.nviaadco%TYPE DEFAULT NULL,
      pclitco IN per_direcciones.clitco%TYPE DEFAULT NULL,
      pcorco IN per_direcciones.corco%TYPE DEFAULT NULL,
      pnplacaco IN per_direcciones.nplacaco%TYPE DEFAULT NULL,
      pcor2co IN per_direcciones.cor2co%TYPE DEFAULT NULL,
      pcdet1ia IN per_direcciones.cdet1ia%TYPE DEFAULT NULL,
      ptnum1ia IN per_direcciones.tnum1ia%TYPE DEFAULT NULL,
      pcdet2ia IN per_direcciones.cdet2ia%TYPE DEFAULT NULL,
      ptnum2ia IN per_direcciones.tnum2ia%TYPE DEFAULT NULL,
      pcdet3ia IN per_direcciones.cdet3ia%TYPE DEFAULT NULL,
      ptnum3ia IN per_direcciones.tnum3ia%TYPE DEFAULT NULL,
      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      plocalidad IN per_direcciones.localidad%TYPE
            DEFAULT NULL   /* Bug 24780/130907 - 05/12/2012 - AMC*/
                        )
      RETURN VARCHAR2 IS
      vtsiglas       VARCHAR2(2) := NULL;
      vnnomvia       NUMBER;
      vnnumvia       NUMBER;
      vncomple       NUMBER;
      vtdomici       per_direcciones.tdomici%TYPE;
      /*JMC- 01/10/2010 - Bug 15495*/
      tviavp         VARCHAR2(250);
      tdet1ia        VARCHAR2(50);
      tdet2ia        VARCHAR2(50);
      tdet3ia        VARCHAR2(50);
      tclitvp        VARCHAR2(50);
      tbisvp         VARCHAR2(50);
      tcorvp         VARCHAR2(50);
      tlitco         VARCHAR2(50);
      tcorco         VARCHAR2(50);
      tor2co         VARCHAR2(50);
   BEGIN
      /* Bug 21703/110272 - 15/03/2012 - AMC*/
      RETURN pac_propio.f_tdomici(pcsiglas, ptnomvia, pnnumvia, ptcomple, pcviavp, pclitvp,
                                  pcbisvp, pcorvp, pnviaadco, pclitco, pcorco, pnplacaco,
                                  pcor2co, pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia,
                                  ptnum3ia,
                                  plocalidad   /* Bug 24780/130907 - 05/12/2012 - AMC*/
                                            );
   /* Fi Bug 21703/110272 - 15/03/2012 - AMC*/
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tdomici;

   FUNCTION f_shisvin(psperson IN hisper_personas.sperson%TYPE)
      RETURN NUMBER IS
      vnorden        hisper_personas.norden%TYPE;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM hisper_vinculos
       WHERE sperson = psperson;

      RETURN vnorden;
   END f_shisvin;

   FUNCTION f_shislopd(psperson IN hisper_personas.sperson%TYPE)
      RETURN NUMBER IS
      vnorden        hisper_personas.norden%TYPE;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM hisper_lopd
       WHERE sperson = psperson;

      RETURN vnorden;
   END f_shislopd;

   FUNCTION f_nordenlopd(psperson IN per_lopd.sperson%TYPE)
      RETURN NUMBER IS
      vnorden        per_lopd.norden%TYPE;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM per_lopd
       WHERE sperson = psperson;

      RETURN vnorden;
   END;

   FUNCTION f_shisirpf(psperson IN hisper_personas.sperson%TYPE)
      RETURN NUMBER IS
      vnorden        NUMBER;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM hisper_irpf
       WHERE sperson = psperson;

      RETURN vnorden;
   END;

   /*Modificar en las tablas est la cuenta*/
   /*Borrar de las tablas estper_ccc*/
   PROCEDURE p_del_ccc(
      psperson IN estper_ccc.sperson%TYPE,
      pcnordban IN estper_ccc.cnordban%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      errores OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      i              NUMBER := 1;
      verr           ob_error;
      vcagente       per_ccc.cagente%TYPE;
      vcdefecto      per_ccc.cdefecto%TYPE;
      vcvalida       per_ccc.cvalida%TYPE;
      vnumerr        NUMBER;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF ptablas = 'EST' THEN
         BEGIN
            /* recupero cagente*/
            SELECT cagente
              INTO vcagente
              FROM estper_ccc
             WHERE sperson = psperson
               AND cnordban = pcnordban;

            /* compruebo si es ccc x defecto*/
            SELECT cdefecto
              INTO vcdefecto
              FROM estper_ccc
             WHERE sperson = psperson
               AND cnordban = pcnordban;

            /* baja ccc*/
            UPDATE estper_ccc
               SET fbaja = f_sysdate,
                   cdefecto = 0
             WHERE sperson = psperson
               AND cnordban = pcnordban;

            IF vcdefecto = 1 THEN   /* actualizo ccc x defecto   BUG 9049*/
               UPDATE estper_ccc
                  SET cdefecto = 1
                WHERE sperson = psperson
                  AND cagente = vcagente
                  AND fbaja IS NULL
                  AND cnordban = (SELECT MIN(cnordban)
                                    FROM estper_ccc
                                   WHERE sperson = psperson
                                     AND cagente = vcagente
                                     AND fbaja IS NULL);
            END IF;

            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'INS_MANDATO'),
                   0) = 1 THEN
               vnumerr := pac_mandatos.f_anular_mandato(psperson, pcnordban, 'EST');

               IF vnumerr <> 0 THEN
                  errores.EXTEND;
                  verr := ob_error.instanciar(9906756,
                                              f_axis_literales(9906756, pcidioma) || '  '
                                              || SQLERRM);
                  errores(i) := verr;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(806207,
                                           f_axis_literales(806207, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      ELSE
         BEGIN
            /* recupero cagente*/
            SELECT cagente
              INTO vcagente
              FROM per_ccc
             WHERE sperson = psperson
               AND cnordban = pcnordban;

            /* compruebo si es ccc x defecto*/
            /* Bug 24672- 20/11/2012- ECP*/
            /* compruebo si tiene una prenotificaciòn en curso*/
            SELECT cdefecto, cvalida
              INTO vcdefecto, vcvalida
              FROM per_ccc
             WHERE sperson = psperson
               AND cnordban = pcnordban;

            /* baja ccc*/
            /* Bug 24672- 20/11/2012- ECP*/
            IF vcvalida <> 2
               OR vcvalida IS NULL   /* 44. 0026979 - 0144586*/
                                  THEN
               UPDATE per_ccc
                  SET fbaja = f_sysdate,
                      cdefecto = 0
                WHERE sperson = psperson
                  AND cnordban = pcnordban;

               IF vcdefecto = 1 THEN   /* actualizo ccc x defecto   BUG 9049*/
                  UPDATE per_ccc
                     SET cdefecto = 1
                   WHERE sperson = psperson
                     AND cagente = vcagente
                     AND fbaja IS NULL
                     AND cnordban = (SELECT MIN(cnordban)
                                       FROM per_ccc
                                      WHERE sperson = psperson
                                        AND cagente = vcagente
                                        AND fbaja IS NULL);
               END IF;

               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                    'INS_MANDATO'),
                      0) = 1 THEN
                  vnumerr := pac_mandatos.f_anular_mandato(psperson, pcnordban, 'POL');

                  IF vnumerr <> 0 THEN
                     errores.EXTEND;
                     verr := ob_error.instanciar(9906756,
                                                 f_axis_literales(9906756, pcidioma) || '  '
                                                 || SQLERRM);
                     errores(i) := verr;
                  END IF;
               END IF;
            ELSE
               errores.EXTEND;
               /* 44. 0026979: Mensaje de error inapropiado al borrar las cuentas bancarias. QT-0007317 - 0144586 - Inicio*/
               /*
               verr := ob_error.instanciar(9903190,
                                           f_axis_literales(9903190, pcidioma) || '  '
                                           || SQLERRM);
               */
               /* 9905578 - No se pueden eliminar cuentas bancarias en estado "Prenotificación en tránsito"*/
               /*verr := ob_error.instanciar(9905578,*/
               /*                            f_axis_literales(9905578, pcidioma) || '  '*/
                 /*                            || SQLERRM);*/
               verr := ob_error.instanciar(9905578, f_axis_literales(9905578, pcidioma));                                                                                /* 45. 0027198 - QT-7319*/
                                                                                            /* 44. 0026979: Mensaje de error inapropiado al borrar las cuentas bancarias. QT-0007317 - 0144586 - Final*/
               errores(i) := verr;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(806207,
                                           f_axis_literales(806207, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      END IF;
   END;

   /*Función que retorna el norden máximo para esa persona.*/
   FUNCTION f_shisccc(psperson IN hisper_ccc.sperson%TYPE)
      RETURN NUMBER IS
      vnorden        hisper_ccc.norden%TYPE;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM hisper_ccc
       WHERE sperson = psperson;

      RETURN vnorden;
   END f_shisccc;

   FUNCTION f_existe_persona(
      pcempres IN empresas.cempres%TYPE,
      pnnumide IN per_personas.nnumide%TYPE,
      pcsexper IN per_personas.csexper%TYPE,
      pfnacimi IN per_personas.fnacimi%TYPE,
      psperson_new OUT per_personas.sperson%TYPE,
      psnip IN per_personas.snip%TYPE,
      pspereal IN per_personas.sperson%TYPE DEFAULT NULL,
      /* t.9318*/
      pctipide IN per_personas.ctipide%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vpersonunica   NUMBER(5);
   /* Paràmetre per com validar l'existencia d'una persona

      1 : Persona única por snip
      2:  Persona única por nnumide
      3:  Persona única por nnumide, fnacimi y sexo
      4: Se permite duplicados (se puede realizar por perfil cfg's duplicanif y cargapersona cfg's)
      5: Persona única por nnumide(Numero de Censo/Pasaporte de la persona)
      y ctipide(Tipo de identificación persona ( V.F. 672.  NIf, pasaporte, etc.)
    */
   BEGIN
      /*
       -- En principio npac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec,
                                           vpara || ' - vpersonunica: ' || vpersonunica,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN persona;o puede haber más de una persona con los siguientes datos iguales:
          sexo
          Fecha de nacimiento
          Número identificador
       -- Solo se debería dar el caso si los datos fueran erroneos debido a migarción o por cualquier motivo.
       */
      vpasexec := 2;
      vpersonunica := pac_parametros.f_parempresa_n(pcempres, 'PER_DUPLICAR');
      vpasexec := 3;

      /* persona única por snip*/
      IF vpersonunica = 1 THEN
         /*cerca per SNIP*/
         vpasexec := 4;

         SELECT MAX(sperson)
           INTO psperson_new
           FROM per_personas
          WHERE snip = psnip
            AND sperson != NVL(pspereal, -1)
            AND swpubli = 0;
      /* persona única por número identificador*/
      ELSIF vpersonunica = 2 THEN
         vpasexec := 5;

         SELECT MAX(sperson)
           INTO psperson_new
           FROM per_personas
          WHERE nnumide = pnnumide
            AND sperson != NVL(pspereal, -1)
            AND swpubli = 0;
      /* persona única por número identificador, fnacimi y sexo fisica y nnumide juridica.*/
      ELSIF vpersonunica = 3 THEN
         /*cerca per fnacimi,sexe,nnumide*/
         vpasexec := 6;

         SELECT MAX(sperson)
           INTO psperson_new
           FROM per_personas
          WHERE ((nnumide = pnnumide
                  AND per_personas.ctipper = 2)
                 OR(nnumide = pnnumide
                    AND csexper = pcsexper
                    AND fnacimi = pfnacimi
                    AND per_personas.ctipper != 2))
            AND sperson != NVL(pspereal, -1)
            AND swpubli = 0;   /* t.9318*/
      ELSIF vpersonunica = 4 THEN
         vpasexec := 7;
         /* Permitimos duplicados.*/
         RETURN 0;
      ELSIF vpersonunica = 5 THEN
         vpasexec := 8;

         SELECT MAX(p.sperson)
           INTO psperson_new
           FROM per_personas p
          WHERE p.nnumide = pnnumide
            AND p.ctipide = pctipide
            AND p.sperson != NVL(pspereal, -1)
            AND p.swpubli = 0
            AND((p.ctipper = 2
                 AND NOT EXISTS(SELECT '1'
                                  FROM per_parpersonas pa
                                 WHERE pa.sperson = p.sperson
                                   AND pa.cparam = 'PER_OFICIAL'
                                   AND pa.nvalpar = 1))
                OR(p.ctipper = 1));
      END IF;

      vpasexec := 9;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         psperson_new := NULL;
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', vpasexec,
                     'f_existe_persona. Error . pnnumide: ' || pnnumide || ' pcsexper: '
                     || pcsexper || 'pfnacimi: ' || pfnacimi || 'pcempres: ' || pcempres
                     || ' psnip:' || psnip || '  vpersonunica: ' || vpersonunica,
                     ' ====  error === ' || SQLERRM);
         RETURN 100534;   /*PERSONA iNXEXISTENTE*/
   END f_existe_persona;

   /* JGM 20/02/2008- NUEVAS PROCEDURES Y FUNCIONES PARA NACIONALIDADES*/
   PROCEDURE p_validapersona(
      psperson IN per_personas.sperson%TYPE,
      pidioma_usu IN NUMBER,   /*¿ Idioma de los errores*/
      ctipper IN NUMBER,   /*¿ tipo de persona (física o jurídica)*/
      ctipide IN NUMBER,   /*¿ tipo de identificación de persona*/
      nnumide IN VARCHAR2,
      /*- Número identificativo de la persona.*/
      csexper IN NUMBER,   /* sexo de la pesona.*/
      fnacimi IN DATE,   /* Fecha de nacimiento de la persona*/
      psnip IN VARCHAR2,   /* snip*/
      cestper IN NUMBER,   /*¿ estado*/
      fjubila IN DATE,   /*¿*/
      cmutualista IN NUMBER,   /*¿*/
      fdefunc IN DATE,   /*¿*/
      nordide IN NUMBER,   /*¿*/
      cidioma IN NUMBER,   /*¿Código idioma*/
      tapelli1 IN VARCHAR2,   /*¿    Primer apellido*/
      tapelli2 IN VARCHAR2,   /*¿    Segundo apellido*/
      tnombre IN VARCHAR2,   /*¿    Nombre de la persona*/
      tsiglas IN VARCHAR2,   /*¿    Siglas persona jurídica*/
      cprofes IN VARCHAR2,   /*¿    Código profesión*/
      cestciv IN NUMBER,   /*¿Código estado civil. VALOR FIJO = 12*/
      cpais IN NUMBER,   /*¿    Código país de residencia*/
      ptablas IN VARCHAR2,
      pcempres IN empresas.cempres%TYPE,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      errores IN OUT t_ob_error,
      pcocupacion IN VARCHAR2   /* Bug 25456/133727 - 16/01/2013 - AMC*/
                             ) IS
      vnum_err       NUMBER := 0;
      j              NUMBER := 1;
      verr           ob_error;
      vcount         NUMBER;
      tpais          VARCHAR2(200);
      v_numide       VARCHAR2(20);
      existsnip      NUMBER;
      vsperreal_aux  per_personas.sperson%TYPE;
      vspereal       per_personas.sperson%TYPE;
      e_persona_identica EXCEPTION;
      e_error        EXCEPTION;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF cestper = 99 THEN
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'FNACIMI_OBLIGATORIO'), 1) = 1 THEN
            IF fnacimi IS NULL
               AND ctipper = 1 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(40202, f_axis_literales(40202, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CSEXPER_OBLIGATORIO'), 1) = 1 THEN
            IF csexper IS NULL
               AND ctipper = 1 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(40202, f_axis_literales(40202, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         /* Bug 20679 - APD - 03/0/2012 - la fecha de nacimiento no puede ser superior*/
           /* a la fecha del dia*/
         IF fnacimi IS NOT NULL THEN
            IF TRUNC(fnacimi) > TRUNC(f_sysdate) THEN
               errores.EXTEND;
               /*La Fecha de nacimiento no puede ser superior a la fecha de hoy.*/
               verr := ob_error.instanciar(120058, f_axis_literales(120058, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         /* fin Bug 20679 - APD - 03/0/2012*/
         /* Bug 20679 - APD - 03/0/2012 - la fecha de defuncion no puede ser superior*/
           /* a la fecha del dia*/
         IF fdefunc IS NOT NULL THEN
            IF TRUNC(fdefunc) > TRUNC(f_sysdate) THEN
               errores.EXTEND;
               /* La Fecha de defunción no puede ser superior a la fecha de hoy.*/
               verr := ob_error.instanciar(9903070, f_axis_literales(9903070, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         /* Bug 25229 -  27/12/2012  la fecha de jubiliación no puede ser superior a la de nacimiento*/
         IF fjubila IS NOT NULL THEN
            IF TRUNC(fjubila) < TRUNC(fnacimi) THEN
               errores.EXTEND;
               /* La Fecha de defunción no puede ser superior a la fecha de hoy.*/
               verr := ob_error.instanciar(9904696, f_axis_literales(9904696, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         /* fin Bug 20679 - APD - 03/0/2012*/
         /* Bug 20679 - APD - 03/0/2012 - la fecha de defuncion no puede ser superior*/
           /* a la fecha del dia*/
         IF fnacimi IS NOT NULL
            AND fdefunc IS NOT NULL THEN
            IF TRUNC(fnacimi) > TRUNC(fdefunc) THEN
               errores.EXTEND;
               /* La fecha de muerte debe ser superior a la de nacimiento*/
               verr := ob_error.instanciar(109264, f_axis_literales(109264, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;
      /* fin Bug 20679 - APD - 03/0/2012*/
      ELSE
         IF ptablas = 'EST' THEN
            SELECT SUM(existe)
              INTO existsnip
              FROM (SELECT COUNT(1) existe
                      FROM per_personas
                     WHERE snip = psnip
                       AND sperson NOT IN(SELECT NVL(spereal, -1)
                                            FROM estper_personas
                                           WHERE sperson = NVL(psperson, -1))
                    UNION
                    SELECT COUNT(1) existe
                      FROM estper_personas
                     WHERE sseguro IN(SELECT sseguro
                                        FROM estper_personas
                                       WHERE sperson = NVL(psperson, -1))
                       AND sperson != psperson
                       AND snip = psnip
                       AND spereal NOT IN(SELECT spereal
                                            FROM estper_personas
                                           WHERE sperson = psperson));

            /* ini t. 9318*/
            IF psperson IS NOT NULL THEN
               SELECT spereal
                 INTO vsperreal_aux
                 FROM estper_personas
                WHERE sperson = psperson;
            ELSE
               vsperreal_aux := NULL;
            END IF;
         /* fin t. 9318*/
         ELSE
            SELECT COUNT(1)
              INTO existsnip
              FROM per_personas
             WHERE snip = psnip
               AND sperson != NVL(psperson, -1);

            vsperreal_aux := NVL(psperson, -1);   /* t. 9318*/
         END IF;

         vnum_err := f_existe_persona(pcempres, nnumide, csexper, fnacimi, vspereal, psnip,
                                      vsperreal_aux, ctipide);

         IF vnum_err = 0 THEN
            IF vspereal IS NOT NULL THEN
               RAISE e_persona_identica;
            END IF;
         ELSE
            RAISE e_error;
         END IF;

         IF existsnip > 0 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9000779, f_axis_literales(9000779, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         IF nnumide IS NULL THEN
            errores.EXTEND;
            verr := ob_error.instanciar(180024, f_axis_literales(180024, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         v_numide := nnumide;

         IF ctipide IS NULL THEN
            errores.EXTEND;
            verr := ob_error.instanciar(110725, f_axis_literales(110725, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         IF ctipper IS NULL THEN
            errores.EXTEND;
            verr := ob_error.instanciar(180026, f_axis_literales(180026, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         IF tapelli1 IS NULL
            AND ctipper = 1 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(140376, f_axis_literales(140376, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         IF tnombre IS NULL
            AND ptnombre1 IS NULL
            AND ptnombre2 IS NULL
            AND ctipper = 1 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(140378, f_axis_literales(140378, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         IF tsiglas IS NULL
            AND ctipper = 2 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(180823, f_axis_literales(180823, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'FNACIMI_OBLIGATORIO'), 1) = 1 THEN
            IF fnacimi IS NULL
               AND ctipper = 1 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(40202, f_axis_literales(40202, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         /* 09/06/2009 : ETM : bug 0010342: IAX - validación del NRN no funciona--INI */
         vnum_err := pac_persona.f_validanif(v_numide, ctipide, csexper, fnacimi);

         IF vnum_err <> 0 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(vnum_err, f_axis_literales(vnum_err, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         /* Bug 7873-- Svj solo se validan los tipos de documento nif, cif, passaporte.*/
         /*
         IF ctipide IN(1, 2, 3) THEN
            vnum_err := f_nif(v_numide);

            IF vnum_err <> 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(vnum_err, f_axis_literales(vnum_err, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         --BUG8718-22/01/2009-JTS-Comprobación de documentos Belgas.
         ELSIF ctipide = 15 THEN
            vnum_err := f_validar_nrn(v_numide, fnacimi, csexper);

            IF vnum_err <> 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(vnum_err, f_axis_literales(vnum_err, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;*/
           /* 09/06/2009 : ETM : bug 0010342: IAX - validación del NRN no funciona--FIN */
         vnum_err := f_despais(cpais, tpais, pidioma_usu);

         IF vnum_err <> 0 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(vnum_err, f_axis_literales(vnum_err, pidioma_usu));
            errores(j) := verr;
            j := j + 1;
         END IF;

         /* Bug 20679 - APD - 03/0/2012 - la fecha de nacimiento no puede ser superior*/
           /* a la fecha del dia*/
         IF fnacimi IS NOT NULL THEN
            IF TRUNC(fnacimi) > TRUNC(f_sysdate) THEN
               errores.EXTEND;
               /*La Fecha de nacimiento no puede ser superior a la fecha de hoy.*/
               verr := ob_error.instanciar(120058, f_axis_literales(120058, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         /* fin Bug 20679 - APD - 03/0/2012*/
         /* Bug 20679 - APD - 03/0/2012 - la fecha de defuncion no puede ser superior*/
           /* a la fecha del dia*/
         IF fdefunc IS NOT NULL THEN
            IF TRUNC(fdefunc) > TRUNC(f_sysdate) THEN
               errores.EXTEND;
               /* La Fecha de defunción no puede ser superior a la fecha de hoy.*/
               verr := ob_error.instanciar(9903070, f_axis_literales(9903070, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         /* Bug 25229 -  27/12/2012  la fecha de jubiliación no puede ser superior a la de nacimiento*/
         IF fjubila IS NOT NULL THEN
            IF TRUNC(fjubila) < TRUNC(fnacimi) THEN
               errores.EXTEND;
               /* La Fecha de defunción no puede ser superior a la fecha de hoy.*/
               verr := ob_error.instanciar(9904696, f_axis_literales(9904696, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;

         /* fin Bug 20679 - APD - 03/0/2012*/
         /* Bug 20679 - APD - 03/0/2012 - la fecha de defuncion no puede ser superior*/
           /* a la fecha del dia*/
         IF fnacimi IS NOT NULL
            AND fdefunc IS NOT NULL THEN
            IF TRUNC(fnacimi) > TRUNC(fdefunc) THEN
               errores.EXTEND;
               /* La fecha de muerte debe ser superior a la de nacimiento*/
               verr := ob_error.instanciar(109264, f_axis_literales(109264, pidioma_usu));
               errores(j) := verr;
               j := j + 1;
            END IF;
         END IF;
      /* fin Bug 20679 - APD - 03/0/2012*/
      END IF;
   EXCEPTION
      WHEN e_persona_identica THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'p_validapersona.Error Personas identicas', 9001806);
         errores.EXTEND;
         verr := ob_error.instanciar(9001806, f_axis_literales(9001806, pidioma_usu));
         errores(j) := verr;
      WHEN e_error THEN
         errores.EXTEND;
         verr := ob_error.instanciar(vnum_err, f_axis_literales(vnum_err, pidioma_usu));
         errores(j) := verr;
         j := j + 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'p_validapersona.Error Imprevisto validar personas', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(806212, SQLERRM);
         errores(j) := verr;
   END p_validapersona;

   FUNCTION f_set_persona(
      pidioma_usu IN NUMBER,   /*¿ Idioma de los errores*/
      psseguro IN seguros.sseguro%TYPE,
      psperson IN OUT NUMBER,
      pspereal IN NUMBER,
      pcagente IN OUT NUMBER,
      pctipper IN NUMBER,   /*¿ tipo de persona (física o jurídica)*/
      pctipide IN NUMBER,   /*¿ tipo de identificación de persona*/
      pnnumide IN VARCHAR2,
      /*- Número identificativo de la persona.*/
      pcsexper IN NUMBER,   /* sexo de la pesona.*/
      pfnacimi IN DATE,   /* Fecha de nacimiento de la persona*/
      psnip IN VARCHAR2,   /* snip*/
      pcestper IN NUMBER,   /*¿ estado*/
      pfjubila IN DATE,   /*¿*/
      pcmutualista IN NUMBER,   /*¿*/
      pfdefunc IN DATE,   /*¿*/
      pnordide IN NUMBER,   /*¿*/
      pcidioma IN NUMBER,   /*¿Código idioma*/
      ptapelli1 IN VARCHAR2,   /*¿    Primer apellido*/
      ptapelli2 IN VARCHAR2,   /*¿    Segundo apellido*/
      ptnombre IN VARCHAR2,   /*¿    Nombre de la persona*/
      ptsiglas IN VARCHAR2,   /*¿    Siglas persona jurídica*/
      pcprofes IN VARCHAR2,   /*¿    Código profesión*/
      pcestciv IN NUMBER,   /*¿Código estado civil VALOR FIJO = 12*/
      pcpais IN NUMBER,   /* pais*/
      pcempres IN empresas.cempres%TYPE,
      ptablas IN VARCHAR2,
      pswpubli IN NUMBER DEFAULT 0,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      pswrut IN NUMBER DEFAULT 0,
      pcocupacion IN VARCHAR2 DEFAULT NULL   /* Bug 25456/133727 - 16/01/2013 - AMC*/
    /* Cambios para solicitudes múltiples : Start */
    ,
      pTipoosc IN NUMBER,
      pCIIU IN NUMBER,
      pSFINANCI IN NUMBER,
      pFConsti IN DATE,
      pCONTACTOS_PER IN T_IAX_CONTACTOS_PER,
      pDIRECCIONS_PER IN T_IAX_DIRECCIONES,
      pNacionalidad IN NUMBER,
      pDigitoide IN NUMBER
    /* Cambios para solicitudes múltiples : End */
  /* CAMBIOS De IAXIS-4538 : Start */
    ,pfefecto IN DATE, 
      pcregfiscal IN NUMBER, 
      pctipiva    IN NUMBER,  
      pIMPUETOS_PER IN T_IAX_PROF_IMPUESTOS
  /* CAMBIOS De IAXIS-4538 : End */
     )
      RETURN t_ob_error IS
      i              NUMBER := 1;
      verr           ob_error;
      errores        t_ob_error;
      num_err        NUMBER;
      vcount         NUMBER;
      vnordide       estper_personas.nordide%TYPE;
      vspereal       estper_personas.spereal%TYPE;
      v_cont         NUMBER;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcagente       agentes.cagente%TYPE;
      /* Bug 14365. FAL. 15/11/2010*/
      terror         VARCHAR2(300);
      vcterminal     usuarios.cterminal%TYPE;
      psinterf       NUMBER;
      werr           ob_error;
      werrores       t_ob_error;
      w_accion       VARCHAR2(50) := NULL;
      vcountd        NUMBER;
      vdigitoide     VARCHAR2(1);
      /* Fi Bug 14365*/
      sw_envio_rut   NUMBER(1);
      vsnip          per_personas.snip%TYPE;
      /* Bug 22746 - APD - 04/07/2012*/
      v_cempres      NUMBER;
      ss             VARCHAR2(3000);
      v_propio       VARCHAR2(500);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      retorno        VARCHAR2(1);
      vtraza         NUMBER;
      vparam         VARCHAR2(3000);
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
    -- Cambios de Swapnil Para Q1897 :Start
      v_nombreParaCompl VARCHAR2(2000) := NULL;
      -- Cambios de Swapnil Para Q1897 :End
  /* Cambios para solicitudes múltiples : Start */
      v_mensajes     t_iax_mensajes;
        wmodcon        NUMBER;
        pcdomici       NUMBER;
        vtdomici       VARCHAR2(1000);
        v_existe_contacto NUMBER;
        v_norden       NUMBER;
        v_cdefecto     NUMBER;
  /* Cambios para solicitudes múltiples : End */
  /* Cambios para IAXIS-2015 : Start */
       V_EXISTE_DIRECCION  NUMBER;
  /* Cambios para IAXIS-2015 : End */
  /* CAMBIOS De IAXIS-4538 : Start */
    x_sprofes NUMBER;  
    x_ccompani NUMBER;
      v_ccodvin NUMBER;
      v_ctipind  NUMBER;
      v_ccodagen NUMBER;
  /* CAMBIOS De IAXIS-4538 : End */
    vcodvinculo per_indicadores.codvinculo%type;

    
   BEGIN
      vtraza := 1;
      errores := t_ob_error();
      errores.DELETE;
      /* Bug 22745 - APD - 04/07/2012 - si el codigo de snip se debe obtener de*/
      /* manera automatica y no viene informado su valor, se debe calcular*/
      vtraza := 2;
      vsnip := psnip;
      vtraza := 3;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'SNIP_AUTOMATICO'),
             0) = 1 THEN
         IF psnip IS NULL THEN
            SELECT snip.NEXTVAL
              INTO vsnip
              FROM DUAL;
         END IF;
      END IF;

      vtraza := 4;

      /* fin Bug 22745 - APD - 04/07/2012*/
      IF ptablas = 'EST' THEN
         vtraza := 5;
         /* bug 7873*/
           /* Esta función nos sirve para recuperar el código de agente con el que se ha de grabar.*/
         pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per,
                                     ptablas);
         vtraza := 6;

          vcagente := vcagente_per; -- bug 967 Javier Herrera 13/07/2017

         /* Grabamos la cabecera estper_personas*/
         /* Si existe una persona con el mismo nif y diferente fnacimi o diferente sexo ..*/
           /* se incrementa el campo nordide que incica si una persona repetida por NIF.*/
         SELECT DECODE(COUNT(1), 0, 0, COUNT(1) + 1)
           INTO vnordide
           FROM per_personas
          WHERE nnumide = pnnumide
            AND((fnacimi = pfnacimi
                 AND csexper <> pcsexper)
                OR(fnacimi <> pfnacimi
                   AND csexper = pcsexper));

         /* SI EXISTE UNA PERSONA CON EL NIF Y FECHA DE NACIMIENTO y sexo*/
           /* CONSIDERAMOS QUE ES LA MISMA PERSONA.*/
         vtraza := 7;
         num_err := f_existe_persona(pcempres, pnnumide, pcsexper, pfnacimi, vspereal, vsnip,
                                     NULL, pctipide);
         vtraza := 8;

         IF pspereal IS NOT NULL THEN
            vspereal := pspereal;
         END IF;

         IF psperson IS NULL THEN
            psperson := pac_persona.f_estsperson;
         END IF;

         vtraza := 9;

         /* Bug 24780 - ETM - 11/12/2012*/
         IF pswrut = 1 THEN
            BEGIN
               SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'PAC_IDE_PERSONA')
                 INTO v_propio
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS THEN
                  v_propio := NULL;
            END;

            vtraza := 10;

            IF v_propio IS NOT NULL THEN
               vtraza := 11;
               ss := 'BEGIN ' || ' :RETORNO :=  PAC_IDE_PERSONA.' || v_propio || '('
                     || pctipide || ',' || UPPER(pnnumide) || ')' || ';' || 'END;';

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               vtraza := 11;
               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
               DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno, 20);
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);
               vtraza := 12;

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               vtraza := 13;
               vdigitoide := retorno;
            END IF;

            vtraza := 14;
         END IF;
-- IGIL CONFCC-7 INI
        -- Cambios de Swapnil Para Q1897 :Start
        if pctipper = 1 then
           select Decode(ptnombre1,NULL, NULL,' '||ptnombre1) || Decode(ptnombre2,NULL, NULL,' '||ptnombre2) || Decode(ptapelli1,NULL, NULL,' '||ptapelli1) || Decode(ptapelli2,NULL, NULL,' '||ptapelli2)
            into v_nombreParaCompl from dual;
        else
           v_nombreParaCompl := ptapelli1;
        end if;
        num_err := PAC_LISTARESTRINGIDA.f_consultar_compliance(psperson, UPPER(pnnumide), v_nombreParaCompl ,pctipide, pctipper);




        -- Cambios de Swapnil Para Q1897 :Start
-- IGIL CONFCC-7 FIN

         /*
                  IF pswrut = 1 THEN
                     vdigitoide := pac_ide_persona.f_digito_nif_col(pctipide, UPPER(pnnumide));
                  END IF;*//*fin bug 24780 - ETM - 11/12/2012*/
         BEGIN
            vtraza := 15;

            INSERT INTO estper_personas
                        (sperson, nnumide, nordide, ctipide,
                         csexper, fnacimi, cestper,
                         fjubila, ctipper, cusuari, fmovimi, cmutualista, fdefunc,
                         spereal, snip, sseguro, swpubli, tdigitoide,
                         cagente /*Bug 29166/160004 - 29/11/2013 - AMC*/)
                 VALUES (psperson, UPPER(pnnumide), NVL(vnordide, 0), pctipide,
                         DECODE(pctipper, 2, NULL, pcsexper), /*Bug 29738/166356 - 17/02/2013 - AMC*/ pfnacimi,                                                                     /* DECODE (pfjubila,
                                                                                                                NULL, NVL (pcestper, 0), 1), -- DRA 29/08/2008: bug mantis 7422*/ NVL
                                                                                                                                                                                    (pcestper,
                                                                                                                                                                                     0),
                         pfjubila, pctipper, f_user, f_sysdate, pcmutualista, pfdefunc,
                         vspereal, vsnip, psseguro, pswpubli, /* no pública*/ vdigitoide,
                         vcagente_per /*Bug 29166/160004 - 29/11/2013 - AMC*/);

            w_accion := 'INSERT';   -- Bug 14365. FAL. 15/11/2010
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vtraza := 16;

               UPDATE estper_personas
                  SET nordide = NVL(pnordide, 0),
                      nnumide = UPPER(pnnumide),
                      ctipide = pctipide,
                      csexper = DECODE(pctipper, 2, NULL, pcsexper),
                      /*Bug 29738/166356 - 17/02/2013 ,*/
                      fnacimi = pfnacimi,
                      cestper = NVL(pcestper, 0),
                      /* DRA 29/08/2008: bug mantis 7422*/
                      fjubila = pfjubila,
                      ctipper = pctipper,
                      cusuari = f_user,
                      fmovimi = f_sysdate,
                      cmutualista = pcmutualista,
                      fdefunc = pfdefunc,
                      snip = vsnip,
                      sseguro = psseguro,
                      spereal = vspereal,
                      swpubli = pswpubli,
                      tdigitoide = vdigitoide,
                      cagente = vcagente_per
                /*Bug 29166/160004 - 29/11/2013 - AMC*/
               WHERE  sperson = psperson;

               vtraza := 16;
               w_accion := 'UPDATE';   -- Bug 14365. FAL. 15/11/2010
         END;

         /* Bug 25456/133727 - 16/01/2013 - AMC*/
         BEGIN
            INSERT INTO estper_detper
                        (sperson, cagente, cidioma, tapelli1,
                         tapelli2, tnombre, tsiglas, cprofes,
                         cestciv, cpais, cusuari, fmovimi,
                         tnombre1, tnombre2, cocupacion)
                 VALUES (psperson, vcagente_per, pcidioma, NVL(ptapelli1, ptsiglas),
                         ptapelli2, ptnombre, ptsiglas, pcprofes,
                         DECODE(pctipper, 2, NULL, pcestciv), /*Bug 29738/166356 - 17/02/2013*/ pcpais, f_user, f_sysdate,
                         ptnombre1, ptnombre2, pcocupacion);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vtraza := 18;

               UPDATE estper_detper
                  SET cidioma = pcidioma,
                      tapelli1 = NVL(ptapelli1, ptsiglas),
                      tapelli2 = ptapelli2,
                      tnombre = ptnombre,
                      tnombre1 = ptnombre1,
                      tnombre2 = ptnombre2,
                      tsiglas = ptsiglas,
                      cprofes = pcprofes,
                      cestciv = DECODE(pctipper, 2, NULL, pcestciv),
                      /*Bug 29738/166356 - 17/02/2013*/
                      cpais = pcpais,
                      cusuari = f_user,
                      fmovimi = f_sysdate,
                      cocupacion = pcocupacion
                WHERE sperson = psperson
                  AND cagente = vcagente_per;
         END;

         /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
         vtraza := 19;

    BEGIN

        IF (NVL(pac_parametros.f_parempresa_n(pcempres, 'EMP_EXCENTO_CONTGAR'), 0) = 1 ) THEN

           INSERT INTO ESTPER_PARPERSONAS (CPARAM, SPERSON, CAGENTE, NVALPAR, TVALPAR, FVALPAR)
             VALUES ('PER_EXCENTO_CONTGAR', psperson, vcagente, 2, NULL, NULL);

        END IF;
     EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
           vtraza := 56;
     END;

         num_err := pac_persona.f_set_identificador(psperson, pcagente, pctipide, pnnumide,
                                                    errores, 1, ptablas, pidioma_usu);
      /* RETURN errores;  -- Bug 14365. FAL. 15/11/2010*/
      ELSE
         vtraza := 20;

         /* Si existe una persona con el mismo nif y diferente fnacimi o diferente sexo ..*/
           /* se incrementa el campo nordide que incica si una persona repetida por NIF.*/
         SELECT DECODE(COUNT(1), 0, 0, COUNT(1) + 1)
           INTO vnordide
           FROM per_personas
          WHERE nnumide = pnnumide
            AND((fnacimi = pfnacimi
                 AND csexper <> pcsexper)
                OR(fnacimi <> pfnacimi
                   AND csexper = pcsexper))
            AND sperson <> psperson;

         vtraza := 21;

         IF psperson IS NULL THEN
            psperson := pac_persona.f_sperson;
         END IF;

         vtraza := 22;

         /* Bug 24780 - ETM - 11/12/2012*/
         IF pswrut = 1 THEN
            BEGIN
               vtraza := 23;

               SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'PAC_IDE_PERSONA')
                 INTO v_propio
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS THEN
                  v_propio := NULL;
            END;

            vtraza := 24;

            IF v_propio IS NOT NULL THEN
               ss := 'BEGIN ' || ' :RETORNO :=  PAC_IDE_PERSONA.' || v_propio || '('
                     || pctipide || ',' || UPPER(pnnumide) || ')' || ';' || 'END;';

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               vtraza := 25;
               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
               DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno, 20);
               /**/
               vtraza := 26;
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);
               vtraza := 27;

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               vtraza := 29;
               vdigitoide := retorno;
               vtraza := 30;

               /* BUG 21270/106644 - 08/02/2012 - JMP - Comprobamos si es la primera vez que se informa el TDIGITOIDE*/
               BEGIN
                  SELECT DECODE(tdigitoide, NULL, 1, 0)
                    INTO sw_envio_rut
                    FROM per_personas
                   WHERE sperson = psperson;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     sw_envio_rut := 1;
               END;
            /* FIN BUG 21270/106644 - 08/02/2012 - JMP - Comprobamos si es la primera vez que se informa el TDIGITOIDE*/
            END IF;
         END IF;

         vtraza := 31;
         /*fin bug 24780 - ETM - 11/12/2012*/
           /*  IF pswrut = 1 THEN
                vdigitoide := pac_ide_persona.f_digito_nif_col(pctipide, UPPER(pnnumide));

                -- BUG 21270/106644 - 08/02/2012 - JMP - Comprobamos si es la primera vez que se informa el TDIGITOIDE
                BEGIN
                   SELECT DECODE(tdigitoide, NULL, 1, 0)
                     INTO sw_envio_rut
                     FROM per_personas
                    WHERE sperson = psperson;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      sw_envio_rut := 1;
                END;
             -- FIN BUG 21270/106644 - 08/02/2012 - JMP - Comprobamos si es la primera vez que se informa el TDIGITOIDE
             END IF;*/
         vtraza := 34;

         IF pcagente IS NULL THEN
            BEGIN
               SELECT ff_agente_cpervisio(cdelega, f_sysdate, f_empres)
                 INTO vcagente
                 FROM usuarios
                WHERE cusuari = f_user;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT cdelega
                    INTO vcagente
                    FROM usuarios
                   WHERE cusuari = f_user;
            END;
         ELSE
            vcagente := pcagente;
         END IF;
-- IGIL CONFCC-7 INI
     -- Cambios de Swapnil Para Q1897 :Start
        if pctipper = 1 then
           select Decode(ptnombre1,NULL, NULL,' '||ptnombre1) || Decode(ptnombre2,NULL, NULL,' '||ptnombre2) || Decode(ptapelli1,NULL, NULL,' '||ptapelli1) || Decode(ptapelli2,NULL, NULL,' '||ptapelli2)
                  into v_nombreParaCompl from dual;
        else
            v_nombreParaCompl := ptapelli1;
        end if;
         num_err := PAC_LISTARESTRINGIDA.f_consultar_compliance(psperson, UPPER(pnnumide), v_nombreParaCompl  ,pctipide, pctipper);

     -- Cambios de Swapnil Para Q1897 :Ends

-- IGIL CONFCC-7 FIN
         BEGIN
            vtraza := 32;

            INSERT INTO per_personas
                        (sperson, nnumide, nordide, ctipide,
                         csexper, fnacimi, cestper,
                         fjubila, ctipper, cusuari, fmovimi, cmutualista, fdefunc,
                         snip, swpubli, tdigitoide,
                         cagente, /*Bug 29166/160004 - 29/11/2013 - AMC*/
                         sperson_deud, sperson_acre ) --TC 464 AABC 08/02/2019 sperson para deudor y acreedor V 80

                 VALUES (psperson, UPPER(pnnumide), NVL(vnordide, 0), pctipide,
                         DECODE(pctipper, 2, NULL, pcsexper), /*Bug 29738/166356 - 17/02/2013*/ pfnacimi, NVL
                                                                                                            (pcestper,
                                                                                                             0),
                         pfjubila, pctipper, f_user, f_sysdate, pcmutualista, pfdefunc,
                         vsnip, pswpubli, pDigitoide,
                         vcagente, /*Bug 29166/160004 - 29/11/2013 - AMC*/
                         psperson, psperson ); --TC 464 AABC 08/02/2019 sperson para deudor y acreedor V 80

            w_accion := 'INSERT';   -- Bug 14365. FAL. 15/11/2010      
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vtraza := 33;

               UPDATE per_personas
                  SET nordide = NVL(pnordide, 0),
                      nnumide = UPPER(pnnumide),
                      ctipide = pctipide,
                      csexper = DECODE(pctipper, 2, NULL, pcsexper),
                      /*Bug 29738/166356 - 17/02/2013*/
                      --fnacimi = pfnacimi,
                      cestper = NVL(pcestper, 0),   /* 23410.#6.17.12.2012.*/
                      fjubila = pfjubila,
                      ctipper = pctipper,
                      cusuari = f_user,
                      fmovimi = f_sysdate,
                      cmutualista = pcmutualista,
                      fdefunc = pfdefunc,
                      snip = vsnip,
                      swpubli = pswpubli,
                      tdigitoide = pDigitoide,
                      cagente = vcagente   /*Bug 29166/160004 - 29/11/2013 - AMC*/
                WHERE sperson = psperson;

               w_accion := 'UPDATE';   -- Bug 14365. FAL. 15/11/2010
         END;

         vtraza := 36;

         /* Si es privada, Insertamos o modificamos el detalla*/
         IF NVL(pswpubli, 0) = 0 THEN
            /* Bug 25456/133727 - 16/01/2013 - AMC*/
            BEGIN
               INSERT INTO per_detper
                           (sperson, cagente, cidioma, tapelli1,
                            tapelli2, tnombre, tsiglas, cprofes,
                            cestciv, cpais, cusuari, fmovimi,
                            tnombre1, tnombre2, cocupacion)
                    VALUES (psperson, vcagente, pcidioma, NVL(ptapelli1, ptsiglas),
                            ptapelli2, ptnombre, ptsiglas, pcprofes,
                            DECODE(pctipper, 2, NULL, pcestciv), /*Bug 29738/166356 - 17/02/2013*/ pcpais, f_user, f_sysdate,
                            ptnombre1, ptnombre2, pcocupacion);           
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  vtraza := 38;

                  UPDATE per_detper
                     SET cidioma = pcidioma,
                         tapelli1 = NVL(ptapelli1, ptsiglas),
                         tapelli2 = ptapelli2,
                         tnombre = ptnombre,
                         tnombre1 = ptnombre1,
                         tnombre2 = ptnombre2,
                         tsiglas = ptsiglas,
                         cprofes = pcprofes,
                         cestciv = DECODE(pctipper, 2, NULL, pcestciv),
                         /*Bug 29738/166356 - 17/02/2013*/
                         cpais = pcpais,
                         cusuari = f_user,
                         fmovimi = f_sysdate,
                         cocupacion = pcocupacion
                   WHERE sperson = psperson
                     AND cagente = vcagente;
            END;
         /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
         /* Si es publica y ya existe el detalle lo modificamos por que no puede haber mas de un detalle.*/
         ELSE
            vtraza := 39;

            SELECT COUNT(1)
              INTO vcountd
              FROM per_detper
             WHERE sperson = psperson;

            IF vcountd > 0 THEN
               vtraza := 40;

               SELECT cagente
                 INTO vcagente
                 FROM per_detper
                WHERE sperson = psperson
                  AND ROWNUM = 1;

               /* Bug 25456/133727 - 16/01/2013 - AMC*/
               UPDATE per_detper
                  SET cidioma = pcidioma,
                      tapelli1 = NVL(ptapelli1, ptsiglas),
                      tapelli2 = ptapelli2,
                      tnombre = ptnombre,
                      tnombre1 = ptnombre1,
                      tnombre2 = ptnombre2,
                      tsiglas = ptsiglas,
                      cprofes = pcprofes,
                      cestciv = DECODE(pctipper, 2, NULL, pcestciv),
                      /*Bug 29738/166356 - 17/02/2013*/
                      cpais = pcpais,
                      cusuari = f_user,
                      fmovimi = f_sysdate,
                      cocupacion = pcocupacion
                WHERE sperson = psperson
                  AND cagente = vcagente;
            /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
            ELSE
               /* Bug 25456/133727 - 16/01/2013 - AMC*/
               INSERT INTO per_detper
                           (sperson, cagente, cidioma, tapelli1,
                            tapelli2, tnombre, tsiglas, cprofes,
                            cestciv, cpais, cusuari, fmovimi,
                            tnombre1, tnombre2, cocupacion)
                    VALUES (psperson, vcagente, pcidioma, NVL(ptapelli1, ptsiglas),
                            ptapelli2, ptnombre, ptsiglas, pcprofes,
                            DECODE(pctipper, 2, NULL, pcestciv), /*Bug 29738/166356 - 17/02/2013*/ pcpais, f_user, f_sysdate,
                            ptnombre1, ptnombre2, pcocupacion);
            /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
            END IF;
         /*         ELSE*/
         /*            -- les persones son public nomes haurien de tenir un detall. H*/
         /*            -- Per solucinar-ho o edites la persona a privada o esborres un detall*/
         /*            errores.EXTEND;*/
         /*            werr := ob_error.instanciar(9902389, SQLERRM);*/
         /*            errores(i) := werr;*/
         /*            RETURN errores;*/
         END IF;

         vtraza := 42;
         num_err := pac_persona.f_set_identificador(psperson, vcagente, pctipide, pnnumide,
                                                    errores, 1, ptablas, pidioma_usu);
         vtraza := 43;
      /* RETURN errores;  -- Bug 14365. FAL. 15/11/2010*/

    /* Cambios para solicitudes múltiples : Start */
     vtraza := 121;
         num_err := PAC_IAX_FINANCIERA.F_GRABAR_GENERAL(psperson,pSFINANCI,'1',null,null,null,null,null,null,null,pcpais,null,null,null,pCIIU,pTipoosc,null,null,null,pFConsti,null,v_mensajes);
   
    /* Inicio IAXIS-7629 JRVG 20/02/2020*/
     begin
       select codvinculo
         into vcodvinculo
         from per_indicadores
        where sperson = psperson
          and rownum = 1;
     exception
       when no_data_found then
         vcodvinculo := null;
     end;
     /* Fin IAXIS-7629 JRVG 20/02/2020*/
                
      vtraza := 122;
        IF PDIRECCIONS_PER IS NOT NULL THEN
          FOR I IN PDIRECCIONS_PER.FIRST .. PDIRECCIONS_PER.LAST LOOP
            IF PDIRECCIONS_PER(I).CTIPDIR IS NOT NULL THEN
               /* Cambios para IAXIS-2015 : Start */

               VTDOMICI := F_TDOMICI(PDIRECCIONS_PER(I).CSIGLAS,PDIRECCIONS_PER(I).TNOMVIA,PDIRECCIONS_PER(I).NNUMVIA,
                                         PDIRECCIONS_PER(I).TCOMPLE,PDIRECCIONS_PER(I).CVIAVP,PDIRECCIONS_PER(I).CLITVP,
                                         PDIRECCIONS_PER(I).CBISVP,PDIRECCIONS_PER(I).CORVP,PDIRECCIONS_PER(I).NVIAADCO,
                                         PDIRECCIONS_PER(I).CLITCO,PDIRECCIONS_PER(I).CORCO,PDIRECCIONS_PER(I).NPLACACO,
                                         PDIRECCIONS_PER(I).COR2CO,PDIRECCIONS_PER(I).CDET1IA,PDIRECCIONS_PER(I).TNUM1IA,
                                         PDIRECCIONS_PER(I).CDET2IA,PDIRECCIONS_PER(I).TNUM2IA,PDIRECCIONS_PER(I).CDET3IA,
                                         PDIRECCIONS_PER(I).TNUM3IA,PDIRECCIONS_PER(I).LOCALIDAD
                                         );
         VTDOMICI := REGEXP_SUBSTR(VTDOMICI,'[^,]+');
           
           /* Inicio IAXIS-7629 JRVG 20/02/2020*/
           
              IF vcodvinculo in (1,6)  THEN -- Asegurados y Beneficiarios VG  
                
                begin
                select cdomici
                  into v_existe_direccion
                  from per_direcciones
                 where cagente = VCAGENTE
                   and upper(tnomvia) = 'OPERACION VD XX XX XX'  --DATO DUMMY
                   and ctipdir IN (9, 10)
                   and sperson = psperson
                   and rownum = 1;
                  exception
                      when no_data_found then
                         v_existe_direccion :=null;
                  end;
                
              ELSE 
                
                begin
                    SELECT cdomici
                      INTO V_EXISTE_DIRECCION
                      FROM per_direcciones
                     WHERE cagente = VCAGENTE
                       AND ctipdir = PDIRECCIONS_PER(I).CTIPDIR
                       and replace(TDOMICI, '''', '') = VTDOMICI
                       and CPOBLAC = PDIRECCIONS_PER(I).CPOBLAC
                       and CPROVIN = PDIRECCIONS_PER(I).CPROVIN
                       and sperson = psperson
                       and rownum = 1;
                  exception
                      when no_data_found then
                         V_EXISTE_DIRECCION :=null;
                  end;
                
              END IF;
             /* fin IAXIS-7629 JRVG 20/02/2020*/

                if V_EXISTE_DIRECCION is null then
                  
                  SELECT NVL(MAX(cdomici), 0) + 1
                    INTO pcdomici
                    FROM per_direcciones
                   WHERE sperson = psperson;

                  INSERT INTO PER_DIRECCIONES(SPERSON,CAGENTE,CDOMICI,CTIPDIR,
                                              CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,
                                              TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,
                                              CUSUARI,FMOVIMI,CVIAVP,CLITVP,
                                              CBISVP,CORVP,NVIAADCO,CLITCO,
                                              CORCO,NPLACACO,COR2CO,CDET1IA,
                                              TNUM1IA,CDET2IA,TNUM2IA,
                                              CDET3IA,TNUM3IA,IDDOMICI,
                                              LOCALIDAD,TALIAS,FDEFECTO
                                              )
                  VALUES(PSPERSON,VCAGENTE,PCDOMICI,PDIRECCIONS_PER(I).CTIPDIR,
                         PDIRECCIONS_PER(I).CSIGLAS,PDIRECCIONS_PER(I).TNOMVIA,PDIRECCIONS_PER(I).NNUMVIA,
                         PDIRECCIONS_PER(I).TCOMPLE,VTDOMICI,PDIRECCIONS_PER(I).CPOSTAL,PDIRECCIONS_PER(I).CPOBLAC,
                         PDIRECCIONS_PER(I).CPROVIN,F_USER,F_SYSDATE,PDIRECCIONS_PER(I).CVIAVP,PDIRECCIONS_PER(I).CLITVP,
                         PDIRECCIONS_PER(I).CBISVP,PDIRECCIONS_PER(I).CORVP,PDIRECCIONS_PER(I).NVIAADCO,PDIRECCIONS_PER(I).CLITCO,
                         PDIRECCIONS_PER(I).CORCO,PDIRECCIONS_PER(I).NPLACACO,PDIRECCIONS_PER(I).COR2CO,
                         PDIRECCIONS_PER(I).CDET1IA,PDIRECCIONS_PER(I).TNUM1IA,PDIRECCIONS_PER(I).CDET2IA,PDIRECCIONS_PER(I).TNUM2IA,
                         PDIRECCIONS_PER(I).CDET3IA,PDIRECCIONS_PER(I).TNUM3IA,'',PDIRECCIONS_PER(I).LOCALIDAD,PDIRECCIONS_PER(I).TALIAS,PDIRECCIONS_PER(I).FDEFECTO
                         );         
                 else
                        UPDATE per_direcciones
                           SET ctipdir = PDIRECCIONS_PER(I).CTIPDIR,
                               csiglas = PDIRECCIONS_PER(I).CSIGLAS,
                               tnomvia = PDIRECCIONS_PER(I).TNOMVIA,
                               nnumvia = PDIRECCIONS_PER(I).NNUMVIA,
                               tcomple = PDIRECCIONS_PER(I).TCOMPLE,
                               tdomici = VTDOMICI,
                               cpostal = PDIRECCIONS_PER(I).CPOSTAL,
                               cpoblac = PDIRECCIONS_PER(I).CPOBLAC,
                               cprovin = PDIRECCIONS_PER(I).CPROVIN,
                               cusuari = f_user,
                               fmovimi = f_sysdate,
                               cviavp  = PDIRECCIONS_PER(I).CVIAVP,
                               clitvp  = PDIRECCIONS_PER(I).CLITVP,
                               cbisvp  = PDIRECCIONS_PER(I).CBISVP,
                               corvp   = PDIRECCIONS_PER(I).CORVP,
                               nviaadco = PDIRECCIONS_PER(I).NVIAADCO,
                               clitco  = PDIRECCIONS_PER(I).CLITCO,
                               corco   = PDIRECCIONS_PER(I).CORCO,
                               nplacaco = PDIRECCIONS_PER(I).NPLACACO,
                               cor2co  = PDIRECCIONS_PER(I).COR2CO,
                               cdet1ia = PDIRECCIONS_PER(I).CDET1IA,
                               tnum1ia = PDIRECCIONS_PER(I).TNUM1IA,
                               cdet2ia = PDIRECCIONS_PER(I).CDET2IA,
                               tnum2ia = PDIRECCIONS_PER(I).TNUM2IA,
                               cdet3ia = PDIRECCIONS_PER(I).CDET3IA,
                               tnum3ia = PDIRECCIONS_PER(I).TNUM3IA,
                               localidad = PDIRECCIONS_PER(I).LOCALIDAD,
                               talias    = PDIRECCIONS_PER(I).TALIAS
                        WHERE  sperson = psperson
                           AND CAGENTE = VCAGENTE
                           AND cdomici = V_EXISTE_DIRECCION;                 
                   end if;
            END IF;
          END LOOP;
        END IF;
        vtraza := 123;
        IF PCONTACTOS_PER IS NOT NULL THEN
           FOR I IN PCONTACTOS_PER.FIRST .. PCONTACTOS_PER.LAST LOOP
               IF PCONTACTOS_PER(I).TELEFO_FIJO IS NOT NULL THEN
                 
               /* Inicio IAXIS-7629 JRVG 20/02/2020*/ 
                IF vcodvinculo in (1,6)  THEN -- Asegurados y Beneficiarios VG  
                  
                 SELECT NVL(MAX(cdomici), 0)
                    INTO pcdomici
                    FROM per_direcciones
                   WHERE sperson = psperson;
                    
                  begin
                  select cmodcon
                    into v_existe_contacto
                    from per_contactos
                   where sperson = psperson
                     and cagente = VCAGENTE
                     and ctipcon = 1
                     and tvalcon = '3000000' -- dato dummy
                     and rownum = 1;
                  exception
                    when no_data_found then
                       v_existe_contacto :=null;
                  end;
                  
                 ELSE
                   
                   begin
                    SELECT cmodcon
                      INTO V_EXISTE_CONTACTO
                      FROM per_contactos
                     WHERE sperson = psperson
                       AND cagente = VCAGENTE
                       and CTIPCON = 1
                       and TVALCON = PCONTACTOS_PER(I).TELEFO_FIJO
                       and rownum = 1;
                  exception
                    when no_data_found then
                       V_EXISTE_CONTACTO :=null;
                  end;
                    
                 END IF;
                /* Fin IAXIS-7629 JRVG 20/02/2020*/
                 
                  IF V_EXISTE_CONTACTO IS NULL THEN
                   SELECT NVL(MAX(CMODCON), 0) + 1
                     INTO WMODCON
                     FROM PER_CONTACTOS
                    WHERE SPERSON = PSPERSON;

                      INSERT INTO PER_CONTACTOS
                             (SPERSON, CAGENTE, CMODCON, CTIPCON, TCOMCON,
                              TVALCON, CDOMICI, CPREFIX, CUSUARI, FMOVIMI,COBLIGA)
                      VALUES (PSPERSON, VCAGENTE, WMODCON,1 , '',
                              PCONTACTOS_PER(I).TELEFO_FIJO, pcdomici, PCONTACTOS_PER(I).PREFIJO_TELEFONICO_FIJO, F_USER, F_SYSDATE,0);                
                  ELSE
                    UPDATE PER_CONTACTOS
                    SET TVALCON = PCONTACTOS_PER(I).TELEFO_FIJO,
                        CDOMICI = PCDOMICI,
                        CPREFIX = PCONTACTOS_PER(I).PREFIJO_TELEFONICO_FIJO,
                        CUSUARI = F_USER,
                        FMOVIMI = F_SYSDATE
                    WHERE SPERSON = PSPERSON
                      AND CAGENTE = VCAGENTE
                      AND CMODCON = V_EXISTE_CONTACTO;           
                  END IF;
               END IF;
               IF PCONTACTOS_PER(I).TELEFO_MOVIL IS NOT NULL THEN
                 
               /* Inicio IAXIS-7629 JRVG 20/02/2020*/
               
                IF vcodvinculo in (1,6)  THEN -- Asegurados y Beneficiarios VG
                   
                  SELECT NVL(MAX(cdomici), 0)
                    INTO pcdomici
                    FROM per_direcciones
                   WHERE sperson = psperson;
                   
                 begin
                  SELECT cmodcon
                    INTO V_EXISTE_CONTACTO
                    FROM per_contactos
                   WHERE sperson = psperson
                     AND cagente = VCAGENTE
                     and CTIPCON = 6
                     and TVALCON = '3000000000' --DATO DUMMY
                     and rownum = 1;
                  exception
                    when no_data_found then
                       V_EXISTE_CONTACTO :=null;
                  end;
                  
                 ELSE 
                   
                    begin
                  SELECT cmodcon
                    INTO V_EXISTE_CONTACTO
                    FROM per_contactos
                   WHERE sperson = psperson
                     AND cagente = VCAGENTE
                     and CTIPCON = 6
                     and TVALCON = PCONTACTOS_PER(I).TELEFO_MOVIL
                     and rownum = 1;
                  exception
                    when no_data_found then
                       V_EXISTE_CONTACTO :=null;
                  end;
                  
                 END IF;
               /* Fin IAXIS-7629 JRVG 20/02/2020*/
                 
                 IF V_EXISTE_CONTACTO IS NULL THEN
                     SELECT NVL(MAX(CMODCON), 0) + 1
                       INTO WMODCON
                       FROM PER_CONTACTOS
                      WHERE SPERSON = PSPERSON;

                        INSERT INTO PER_CONTACTOS
                               (SPERSON, CAGENTE, CMODCON, CTIPCON, TCOMCON,
                                TVALCON, CDOMICI, CPREFIX, CUSUARI, FMOVIMI,COBLIGA)
                        VALUES (PSPERSON, VCAGENTE, WMODCON,6 , '',
                                PCONTACTOS_PER(I).TELEFO_MOVIL, pcdomici, PCONTACTOS_PER(I).PREFIJO_TELEFONICO_MOVIL, F_USER, F_SYSDATE,0);                
                 ELSE
                    UPDATE PER_CONTACTOS
                    SET TVALCON = PCONTACTOS_PER(I).TELEFO_MOVIL,
                        CDOMICI = PCDOMICI,
                        CPREFIX = PCONTACTOS_PER(I).PREFIJO_TELEFONICO_MOVIL,
                        CUSUARI = F_USER,
                        FMOVIMI = F_SYSDATE
                    WHERE SPERSON = PSPERSON
                      AND CAGENTE = VCAGENTE
                      AND CMODCON = V_EXISTE_CONTACTO;      
                  END IF;
               END IF;

               IF PCONTACTOS_PER(I).FAX IS NOT NULL THEN
                 begin
                  SELECT cmodcon
                    INTO V_EXISTE_CONTACTO
                    FROM per_contactos
                   WHERE sperson = psperson
                     AND cagente = VCAGENTE
                     and CTIPCON = 2
                     and TVALCON = PCONTACTOS_PER(I).FAX
                     and rownum = 1;
                  exception
                    when no_data_found then
                       V_EXISTE_CONTACTO :=null;
                  end;

                 IF V_EXISTE_CONTACTO IS NULL THEN
                      SELECT NVL(MAX(CMODCON), 0) + 1
                       INTO WMODCON
                       FROM PER_CONTACTOS
                      WHERE SPERSON = PSPERSON;
                      INSERT INTO PER_CONTACTOS
                             (SPERSON, CAGENTE, CMODCON, CTIPCON, TCOMCON,
                              TVALCON, CDOMICI, CPREFIX, CUSUARI, FMOVIMI,COBLIGA)
                      VALUES (PSPERSON, VCAGENTE, WMODCON,2 , '',
                              PCONTACTOS_PER(I).FAX, pcdomici, PCONTACTOS_PER(I).PREFIJO_TELEFONICO_FAX, F_USER, F_SYSDATE,0);              
                 ELSE
                    UPDATE PER_CONTACTOS
                    SET TVALCON = PCONTACTOS_PER(I).FAX,
                        CDOMICI = PCDOMICI,
                        CPREFIX = PCONTACTOS_PER(I).PREFIJO_TELEFONICO_FAX,
                        CUSUARI = F_USER,
                        FMOVIMI = F_SYSDATE
                    WHERE SPERSON = PSPERSON
                      AND CAGENTE = VCAGENTE
                      AND CMODCON = V_EXISTE_CONTACTO;           
                  END IF;
               END IF;
               IF PCONTACTOS_PER(I).CORREO_ELECTRANICO IS NOT NULL THEN
                 
               /* Inicio IAXIS-7629 JRVG 20/02/2020*/
               
                IF vcodvinculo in (1,6)  THEN -- Asegurados y Beneficiarios VG 
                  
                  SELECT NVL(MAX(cdomici), 0)
                    INTO pcdomici
                    FROM per_direcciones
                   WHERE sperson = psperson;
                   
                 begin
                  SELECT cmodcon
                    INTO V_EXISTE_CONTACTO
                    FROM per_contactos
                   WHERE sperson = psperson
                     AND cagente = VCAGENTE
                     and CTIPCON = 3
                     and UPPER(TVALCON) = 'OPERACIONVD@CONFIANZA.COM'
                     and rownum = 1;
                  exception
                    when no_data_found then
                       V_EXISTE_CONTACTO :=null;
                  end;
                  
                  ELSE
                    
                  /* Fin IAXIS-7629 JRVG 20/02/2020*/
                    
                     begin
                  SELECT cmodcon
                    INTO V_EXISTE_CONTACTO
                    FROM per_contactos
                   WHERE sperson = psperson
                     AND cagente = VCAGENTE
                     and CTIPCON = 3
                     and TVALCON = PCONTACTOS_PER(I).CORREO_ELECTRANICO
                     and rownum = 1;
                  exception
                    when no_data_found then
                       V_EXISTE_CONTACTO :=null;
                  end;
                 END IF;
                  
                 IF V_EXISTE_CONTACTO IS NULL THEN
                    SELECT NVL(MAX(CMODCON), 0) + 1
                     INTO WMODCON
                     FROM PER_CONTACTOS
                    WHERE SPERSON = PSPERSON;
                    INSERT INTO PER_CONTACTOS
                           (SPERSON, CAGENTE, CMODCON, CTIPCON, TCOMCON,
                            TVALCON, CDOMICI, CPREFIX, CUSUARI, FMOVIMI,COBLIGA)
                    VALUES (PSPERSON, VCAGENTE, WMODCON,3 , '',
                            PCONTACTOS_PER(I).CORREO_ELECTRANICO, '', '', F_USER, F_SYSDATE,0);             
                 ELSE
                   UPDATE PER_CONTACTOS
                      SET TVALCON = PCONTACTOS_PER(I).CORREO_ELECTRANICO,
                          CDOMICI = PCDOMICI,
                          CUSUARI = F_USER,
                          FMOVIMI = F_SYSDATE
                      WHERE SPERSON = PSPERSON
                        AND CAGENTE = VCAGENTE
                        AND CMODCON = V_EXISTE_CONTACTO;            
                  END IF;
               END IF;
               /* Cambios para IAXIS-2015 : End */
           END LOOP;
         END IF;
         vtraza := 124;
      -- Para Nacionalidad
       IF PNACIONALIDAD IS NOT NULL THEN
           IF pctipper = 1 THEN
              BEGIN
                 SELECT NVL(MAX(norden), 0) + 1
                   INTO v_norden
                   FROM per_nacionalidades
                  WHERE sperson = psperson
                    AND cagente = VCAGENTE;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    v_norden := 1;
              END;
              BEGIN
                 INSERT INTO per_nacionalidades
                             (sperson, cagente, cpais, cdefecto, norden)
                      VALUES (psperson, VCAGENTE, pNacionalidad, 1, v_norden);
              EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                    UPDATE per_nacionalidades
                       SET cdefecto = 1,
                           norden = v_norden
                     WHERE sperson = psperson
                       AND cagente = VCAGENTE
                       AND cpais = pNacionalidad;
              END;
              /*Fin BUG 34989/200761 KJSC Modificacion de la funcion f_set_nacionalidad*/
           SELECT cdefecto
                   INTO v_cdefecto
                   FROM per_nacionalidades
                  WHERE norden = v_norden
                    and sperson = psperson
                    AND cagente = VCAGENTE;
             IF v_cdefecto = 1 THEN
                 UPDATE per_nacionalidades   /*Ponemos los otros como no defecto*/
                    SET cdefecto = 0
                  WHERE sperson = psperson
                    AND cagente = VCAGENTE
                    AND cpais <> pNacionalidad;
             END IF;
           END IF;
        END IF;
    /* Cambios para solicitudes múltiples : End */
      END IF;

    /* Cambios de IAXIS-3286 : Start */
      BEGIN
             IF (NVL(pac_parametros.f_parempresa_n(pcempres, 'EMP_EXCENTO_CONTGAR'), 0) = 1 AND ptablas != 'EST' ) THEN
                    INSERT INTO PER_PARPERSONAS (CPARAM, SPERSON, CAGENTE, NVALPAR, TVALPAR, FVALPAR, CUSUARI, FMOVIMI)
                      VALUES ('PER_EXCENTO_CONTGAR', psperson, vcagente, 2, NULL, NULL, f_user, f_sysdate); 
               END IF;
      EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                    vtraza := 56;
      END;

      BEGIN
             IF (NVL(pac_parametros.f_parempresa_n(pcempres, 'PERSONA_CIFIN'), 0) = 1) THEN
                    INSERT INTO PER_PARPERSONAS (CPARAM, SPERSON, CAGENTE, NVALPAR, TVALPAR, FVALPAR, CUSUARI, FMOVIMI)
                      VALUES ('PERSONA_CIFIN', psperson, vcagente, 2, NULL, NULL, f_user, f_sysdate);            
               END IF;
      EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                    vtraza := 57;
      END;

      BEGIN
          INSERT INTO PER_PARPERSONAS (CPARAM, SPERSON, CAGENTE, NVALPAR, TVALPAR, FVALPAR, CUSUARI, FMOVIMI)
          VALUES ('UNIQUE_IDENTIFIER', psperson, vcagente,NULL , NULL, NULL, f_user, f_sysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
         vtraza := 59;
      END;
      /* Cambios de IAXIS-3286 : End */
    /* CAMBIOS De IAXIS-4538 : Start */
       BEGIN
        IF vcagente IS NOT NULL AND
           pfefecto IS NOT NULL AND
           pcregfiscal IS NOT NULL AND
           pctipiva IS NOT NULL
        THEN
         INSERT INTO per_regimenfiscal
                     (sperson, cagente, anualidad, fefecto, cregfiscal,
                      cregfisexeiva,ctipiva)
              VALUES (psperson, vcagente, TO_CHAR(pfefecto, 'rrrr'), pfefecto, pcregfiscal,
                      null, pctipiva);
        END IF;
       EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
           vtraza := 60;
        END;

      vtraza := 126;
     IF pIMPUETOS_PER IS NOT NULL AND pIMPUETOS_PER.COUNT > 0 THEN
          FOR I IN pIMPUETOS_PER.FIRST .. pIMPUETOS_PER.LAST LOOP

             v_ccodvin:= TO_NUMBER(pIMPUETOS_PER(I).tdesimp);--tdesimp is ccodvin 

             IF v_ccodvin IS NOT NULL THEN

               v_ctipind:= TO_NUMBER( pIMPUETOS_PER(I).ctipind);
               v_ccodagen:=TO_NUMBER(TO_NUMBER(pIMPUETOS_PER(I).tindica));--tindica is ccodagen

             BEGIN
               insert into per_indicadores (CODVINCULO, CODSUBVINCULO, SPERSON, CTIPIND, FALTA, CUSUALTA)
               values (v_ccodvin,pIMPUETOS_PER(I).tindica, psperson,pIMPUETOS_PER(I).ctipind, sysdate, pac_md_common.f_get_cxtusuario);
            EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                 vtraza := 61;
            END;

          if v_ccodvin in (2,7) then
               begin
                select sprofes
                      into x_sprofes
                from sin_prof_profesionales
                where sperson = psperson;
                exception when no_data_found then
                   x_sprofes := 0;
             end;

            if x_sprofes > 0 then
              insert into sin_prof_indicadores (sprofes,ctipind, falta, cusualta, cusumod)
                 values (x_sprofes, v_ctipind, sysdate, pac_md_common.f_get_cxtusuario, pac_md_common.f_get_cxtusuario);

            end if;
         end if;

         if v_ccodvin = 4 then
            begin
                select ccompani
                      into x_ccompani
                from companias
                where sperson = psperson;
                exception when no_data_found then
                   x_ccompani := 0;
            end;

             if x_ccompani > 0 then
              insert into indicadores_cias(ccompani,ctipind, nvalor, finivig, ffinvig, cenviosap, caplica, ffalta, fbaja, cusualta, cusumod)
                 values (x_ccompani, v_ctipind, 0, sysdate, null, 0, null, sysdate, null, pac_md_common.f_get_cxtusuario, pac_md_common.f_get_cxtusuario);

            end if;
         end if;             
                END IF;                
          END LOOP;
       END IF;
   /* CAMBIOS De IAXIS-4538 : End */

      vtraza := 44;
    /* Cambios de Iaxis-4521 : start */ 
      BEGIN
      SELECT PP.TDIGITOIDE
        INTO VDIGITOIDE
        FROM PER_PERSONAS PP
       WHERE PP.SPERSON = psperson
         AND ROWNUM = 1;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(pctipide,UPPER(pnnumide));
      END;
     /* Cambios de Iaxis-4521 : end */   

      /* Bug 14365. FAL. 15/11/2010*/
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'ALTA_PERSONA_HOST'), 0) = 1
         AND ptablas = 'POL'
         AND w_accion = 'INSERT' THEN
         vtraza := 45;
         num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

         IF num_err <> 0 THEN
            psperson := NULL;



            errores.EXTEND;
            werr := ob_error.instanciar(num_err, SQLERRM);
            errores(i) := werr;
            RETURN errores;
         END IF;

         /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
         v_host := NULL;

         /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
         IF pac_persona.f_gubernamental(psperson) = 1 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'DUPL_DEUDOR_HOST');
         END IF;

         vtraza := 46;
     /* Cambios de Iaxis-4521 : start */  
         num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                           vcterminal, psinterf, terror,
                                           pac_md_common.f_get_cxtusuario, 1, 'ALTA', VDIGITOIDE,
                                           v_host);
       /* Cambios de Iaxis-4521 : end */                         
         vtraza := 47;

         IF num_err <> 0 THEN
            psperson := NULL;
            errores.EXTEND;
            werr := ob_error.instanciar(num_err, terror);
            errores(i) := werr;
            /*añado error del tmenin*/
            werr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                        pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
            errores.EXTEND;
            i := i + 1;
            errores(i) := werr;
      RETURN errores;
         END IF;

         /* BUG 21270/106644 - 08/02/2012 - JMP - Grabamos otro mensaje con NNUMIDE||TDIGITOIDE*/
         IF sw_envio_rut = 1 THEN
            /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
            v_host := NULL;

            /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
            END IF;

            vtraza := 48;
      psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
     /* Cambios de Iaxis-4521 : start */      
            num_err := pac_con.f_alta_persona(pcempres, psperson, vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 0, 'ALTA', VDIGITOIDE,
                                              v_host);
       /* Cambios de Iaxis-4521 : end */                          
            vtraza := 49;

            IF num_err <> 0 THEN
               vtraza := 50;

               psperson := NULL;


               errores.EXTEND;
               werr := ob_error.instanciar(num_err, terror);
               errores(i) := werr;
               /*añado error del tmenin*/
               werr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               i := i + 1;
               errores(i) := werr;
               RETURN errores;
            END IF;
         END IF;

         /* FIN BUG 21270/106644 - 08/02/2012 - JMP -*/
         /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
           /* Por defecto se envía el acreedor con la cuenta P004*/
         v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'ALTA_PROV_HOST');

         /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
         IF v_host IS NOT NULL THEN
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_ACREEDOR_HOST');
            END IF;

            psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
            num_err := pac_user.f_get_terminal(f_user, vcterminal);
     /* Cambios de Iaxis-4521 : start */        
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 1, 'ALTA', VDIGITOIDE,
                                              v_host);
     /* Cambios de Iaxis-4521 : end */                          
         END IF;

         IF num_err <> 0 THEN
            psperson := NULL;
            errores.EXTEND;
            werr := ob_error.instanciar(num_err, terror);
            errores(i) := werr;
            /*añado error del tmenin*/
            werr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                        pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
            errores.EXTEND;
            i := i + 1;
            errores(i) := werr;
            RETURN errores;
         END IF;
      /*fin BUG 0026318 -- GGR -- 17/03/2014*/
      
      /* Cambios de  tarea IAXIS-13044 :start */
          PAC_CONVIVENCIA.P_SEND_DATA_CONVI(PNNUMIDE, 0, NULL, PSINTERF);                 
        /* Cambios de  tarea IAXIS-13044 :end */ 
      
      END IF;

      vtraza := 51;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MODIF_PERSONA_HOST'), 0) = 1
         AND ptablas = 'POL'
         AND w_accion = 'UPDATE' THEN
         num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);
         vtraza := 52;

         IF num_err <> 0 THEN

            psperson := NULL;


            errores.EXTEND;
            werr := ob_error.instanciar(num_err, SQLERRM);
            errores(i) := werr;
            RETURN errores;
         END IF;

         /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
         v_host := NULL;

         /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
         IF pac_persona.f_gubernamental(psperson) = 1 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'DUPL_DEUDOR_HOST');
         END IF;

         vtraza := 53;
     /* Cambios de Iaxis-4521 : start */
         num_err := pac_con.f_alta_persona(pcempres, psperson, vcterminal, psinterf, terror,
                                           pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOIDE, v_host);
     /* Cambios de Iaxis-4521 : end */                         

         IF num_err <> 0 THEN
            vtraza := 54;
            errores.EXTEND;
            werr := ob_error.instanciar(num_err, terror);
            errores(i) := werr;
            /*añado error del tmenin*/
            werr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                        pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
            errores.EXTEND;
            i := i + 1;
            errores(i) := werr;
            RETURN errores;
          END IF;

         /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
           /* Por defecto se envía el acreedor con la cuenta P004*/
         v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'ALTA_PROV_HOST');

         /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
         IF v_host IS NOT NULL THEN
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_ACREEDOR_HOST');
            END IF;

            psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
            num_err := pac_user.f_get_terminal(f_user, vcterminal);
      /* Cambios de Iaxis-4521 : start */
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                              v_host);
      /* Cambios de Iaxis-4521 : end */                         
         END IF;

         IF num_err <> 0 THEN
            vtraza := 55;
            psperson := NULL;
            errores.EXTEND;
            werr := ob_error.instanciar(num_err, terror);
            errores(i) := werr;
            /*añado error del tmenin*/
            werr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                        pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
            errores.EXTEND;

            i := i + 1;
            errores(i) := werr;
            RETURN errores;

         END IF;
      /*fin BUG 0026318 -- GGR -- 17/03/2014*/
  
      /* Cambios de  tarea IAXIS-13044 :start */
          PAC_CONVIVENCIA.P_SEND_DATA_CONVI(PNNUMIDE, 1, NULL,PSINTERF);                 
        /* Cambios de  tarea IAXIS-13044 :end */ 
           
      END IF;

      /* Bug 26318 - 10/10/2013 - JMG - Inicio #155391 Anotación en la agenda de las pólizas*/
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PER_AGENDA'), 0) =
                                                                                              1
         AND ptablas = 'POL' THEN
         num_err := f_set_agensegu_rol(psperson, 'PER', pcidioma);

         IF num_err <> 0 THEN
            vtraza := 55;
            errores.EXTEND;
            werr := ob_error.instanciar(num_err, SQLERRM);
            errores(i) := werr;
            RETURN errores;
         END IF;
      END IF;

      vtraza := 58;
      /* Bug 26318 - 10/10/2013 - JMG - Fin #155391 Anotación en la agenda de las pólizas*/
      RETURN errores;
   /* Fi Bug 14365*/
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', vtraza,
                     'f_set_persona.Error Imprevisto grabando personas',
                     vparam || ' Error = ' || SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(140268,
                                     f_axis_literales(140268, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
         RETURN errores;
   END f_set_persona;

   FUNCTION f_get_contacto_tipo(
      psperson per_personas.sperson%TYPE,
      pcagente agentes.cagente%TYPE,
      pctipcon NUMBER,
      psmodcon IN OUT NUMBER,
      ptvalcon OUT VARCHAR,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         IF pctipcon IN(1, 2, 6, 12) THEN
            SELECT DECODE(cprefix, NULL, '', '-', ' ', '+' || cprefix || ' ') || tvalcon,
                   cmodcon
              INTO ptvalcon,
                   psmodcon
              FROM estcontactos
             WHERE sperson = psperson
               AND ctipcon = pctipcon
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM estcontactos
                               WHERE sperson = psperson
                                 AND ctipcon = pctipcon);
         ELSE
            SELECT tvalcon, cmodcon
              INTO ptvalcon, psmodcon
              FROM estcontactos
             WHERE sperson = psperson
               AND ctipcon = pctipcon
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM estcontactos
                               WHERE sperson = psperson
                                 AND ctipcon = pctipcon);
         END IF;
      ELSE
         IF pctipcon IN(1, 2, 6, 12) THEN
            SELECT DECODE(cprefix, NULL, '', '-', ' ', '+' || cprefix || ' ') || tvalcon,
                   cmodcon
              INTO ptvalcon,
                   psmodcon
              FROM contactos
             WHERE sperson = psperson
               AND ctipcon = pctipcon
               AND((psmodcon IS NOT NULL
                    AND cmodcon = psmodcon)
                   OR(psmodcon IS NULL
                      AND cmodcon = (SELECT MIN(cmodcon)
                                       FROM contactos
                                      WHERE sperson = psperson
                                        AND ctipcon = pctipcon)));
         ELSE
            SELECT tvalcon, cmodcon
              INTO ptvalcon, psmodcon
              FROM contactos
             WHERE sperson = psperson
               AND ctipcon = pctipcon
               AND((psmodcon IS NOT NULL
                    AND cmodcon = psmodcon)
                   OR(psmodcon IS NULL
                      AND cmodcon = (SELECT MIN(cmodcon)
                                       FROM contactos
                                      WHERE sperson = psperson
                                        AND ctipcon = pctipcon)));
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_get_contacto_tipo.Error Imprevisto obteniendo contacto', SQLERRM);
         RETURN 103212;
   END f_get_contacto_tipo;

   FUNCTION f_get_dadespersona(
      psperson IN OUT per_personas.sperson%TYPE,
      pctipide IN per_personas.ctipide%TYPE,
      pnnumide IN per_personas.nnumide%TYPE,
      pcsexe IN per_personas.csexper%TYPE,
      pfnacimi IN per_personas.fnacimi%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psnip OUT per_personas.snip%TYPE,
      pnordide OUT per_personas.nordide%TYPE,
      pcestper OUT per_personas.cestper%TYPE,
      pfjubila OUT per_personas.fjubila%TYPE,
      pcmutualista OUT per_personas.cmutualista%TYPE,
      pfdefunc OUT per_personas.fdefunc%TYPE,
      ptdigitoide OUT per_personas.tdigitoide%TYPE)
      RETURN NUMBER IS
   BEGIN
      IF psperson IS NOT NULL
         OR(pctipide IS NOT NULL
            AND pnnumide IS NOT NULL
            AND pcsexe IS NOT NULL
            AND pfnacimi IS NOT NULL) THEN
         SELECT sperson, snip, nordide, cestper, fjubila, cmutualista, fdefunc,
                tdigitoide
           INTO psperson, psnip, pnordide, pcestper, pfjubila, pcmutualista, pfdefunc,
                ptdigitoide
           FROM per_personas
          WHERE sperson = NVL(psperson, sperson)
            AND ctipide = NVL(pctipide, ctipide)
            AND nnumide = NVL(pnnumide, nnumide)
            /* Bug 35888/205345 Realizar la substitución del upper nnumide - CJMR*/
            AND csexper = NVL(pcsexe, csexper)
            AND fnacimi = NVL(pfnacimi, fnacimi);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_get_dadespersona.Error Imprevisto:', SQLERRM);
         RETURN 103212;
   END f_get_dadespersona;

   FUNCTION f_get_contacto(
      psperson per_personas.sperson%TYPE,
      pcagente agentes.cagente%TYPE,
      pctipcon NUMBER,
      psmodcon IN OUT NUMBER,
      ptvalcon OUT VARCHAR,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT tvalcon, cmodcon
           INTO ptvalcon, psmodcon
           FROM estcontactos
          WHERE sperson = psperson
            AND ctipcon = pctipcon
            AND cmodcon = psmodcon;
      ELSE
         SELECT tvalcon, cmodcon
           INTO ptvalcon, psmodcon
           FROM contactos
          WHERE sperson = psperson
            AND ctipcon = pctipcon
            AND cmodcon = psmodcon
            AND cmodcon = psmodcon;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_get_contacto.Error Imprevisto obteniendo contacto', SQLERRM);
         RETURN 103212;
   END f_get_contacto;

   FUNCTION f_get_nacionalidaddefecto(
      psperson per_personas.sperson%TYPE,
      pcagente agentes.cagente%TYPE,
      pcpais OUT NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT cpais
           INTO pcpais
           FROM estnacionalidades
          WHERE sperson = psperson
            AND cdefecto = 1;
      ELSE
         SELECT cpais
           INTO pcpais
           FROM nacionalidades
          WHERE sperson = psperson
            AND cdefecto = 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error
            (f_sysdate, f_user, 'PAC_PERSONA', 1,
             'f_get_nacionalidaddefecto.Error Imprevisto obteniendo nacionalidad por defecto',
             SQLERRM);
         RETURN 103212;
   END f_get_nacionalidaddefecto;

   FUNCTION f_set_contacto(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipcon IN NUMBER,
      ptcomcon IN VARCHAR2,   /*etm 21406*/
      psmodcon IN OUT NUMBER,
      ptvalcon IN VARCHAR2,
      pcdomici IN NUMBER,   /*etm 24806*/
      pcprefix IN NUMBER,
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
      psup           NUMBER;
      j              NUMBER := 1;
      verr           ob_error;
      wmodcon        NUMBER;
      wmodcon_est    NUMBER;
      /* jlb - i - bug mantis 6352*/
      vsperreal      estper_personas.spereal%TYPE;
      /* jlb - f - bug mantis 6352*/
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      /* Ini bug 30417/11671 -- ECP -- 07/03/2014*/
      v_valcon       NUMBER;
      ex_error       EXCEPTION;
      /* Fin bug 30417/11671 -- ECP -- 07/03/2014*/
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
      control        NUMBER := 0;
   /* BUG 27314-178602 -- GGR -- 01/07/2014*/
    /* Cambios de IAXIS-4844 : start */
    VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;    
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    /* Cambios de IAXIS-4844 : end */

   BEGIN
      errores := t_ob_error();
      errores.DELETE;
      /* Inicio BUG 27314-178602 --GGR -- 01/07/2014*/
      /* Comprueba si el formato de la cuenta de correo electrónico es correcto solo para las empresas que tienen activado el parámetro*/
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PER_VAL_EMAIL'),
             0) = 1
         AND pctipcon = 3
         AND ptvalcon IS NOT NULL THEN
         SELECT DECODE
                   (REGEXP_SUBSTR(REGEXP_REPLACE(ptvalcon, '^http[s]?://(www\.)?|^www\.', '', 1), '\w+(\.\w+)+'),
                    NULL, 0,
                    1
                   )
           INTO control
           FROM DUAL;
         IF control = 0 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9909651,
                                        f_axis_literales(9909651,
                                                         pac_md_common.f_get_cxtidioma));
            errores(j) := verr;
            RETURN 9909651;
         END IF;
      END IF;

      IF psmodcon IS NULL THEN
         IF ptvalcon IS NOT NULL THEN
            /* Ini bug 30417/11671 -- ECP -- 07/03/2014*/
      -- Ini ajustes para el 42% personas ACL 02/11/2018
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                 'PER_VAL_TELEF'),
                   0) = 1 THEN
               IF pctipcon = 1 THEN
                SELECT LENGTH (ptvalcon)
                 INTO control
                FROM DUAL;
                  IF control <> 7 THEN
                      errores.EXTEND;
                  verr := ob_error.instanciar(9907933,
                                        f_axis_literales(9907933,
                                                         pac_md_common.f_get_cxtidioma));
                   errores(j) := verr;
                   RETURN 9907933;
                 END IF;
        END IF;

             IF pctipcon = 6 THEN
                SELECT LENGTH (ptvalcon)
                 INTO control
                FROM DUAL;
                 IF control <> 10 THEN
                      errores.EXTEND;
                  verr := ob_error.instanciar(9907933,
                                        f_axis_literales(9907933,
                                                         pac_md_common.f_get_cxtidioma));
                   errores(j) := verr;
                   RETURN 9907933;
                 END IF;
        END IF;
        -- Fin ajustes para el 42% personas ACL 02/11/2018
    --INI-CES-IAXIS-3241
               IF pctipcon IN(1, 2, 5, 6) THEN
    --END-CES-IAXIS-3241        
          BEGIN
                     v_valcon := TO_NUMBER(ptvalcon);
                  EXCEPTION
                     WHEN OTHERS THEN
                        RAISE ex_error;
                  END;
               END IF;
            END IF;


            /* Cambios de IAXIS-4844 : start */
              BEGIN
                SELECT PP.NNUMIDE,PP.TDIGITOIDE
                  INTO VPERSON_NUM_ID,VDIGITOIDE
                  FROM PER_PERSONAS PP
                 WHERE PP.SPERSON = psperson
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  SELECT PP.CTIPIDE, PP.NNUMIDE
                    INTO VCTIPIDE, VPERSON_NUM_ID
                    FROM PER_PERSONAS PP
                   WHERE PP.SPERSON = psperson;
                  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                                 UPPER(VPERSON_NUM_ID));
              END;
            /* Cambios de IAXIS-4844 : end */

            /* Fin bug 30417/11671 -- ECP -- 07/03/2014*/
            IF ptablas = 'EST' THEN
               pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per,
                                           'EST');

               /* jlb - i - bug mantis 6352*/
               SELECT spereal
                 INTO vsperreal
                 FROM estper_personas
                WHERE sperson = psperson;

               /* jlb - F - bug mantis 6352*/
                 /* DRA 03-10-2008: bug mantis 6352*/
               wmodcon := pac_persona.f_existe_contacto(vsperreal, vcagente_per, pctipcon,
                                                        ptcomcon,   /*etm 21406*/
                                                        ptvalcon, pcdomici, pcprefix);   /*bug 24806*/

               IF wmodcon IS NULL THEN
                  SELECT NVL(MAX(e.cmodcon), 0)
                    INTO wmodcon_est
                    FROM estper_contactos e, estper_personas p
                   WHERE e.sperson = p.sperson
                     AND p.sperson = psperson;

                  SELECT GREATEST(wmodcon_est, NVL(MAX(c.cmodcon), 0)) + 1
                    INTO wmodcon
                    FROM per_contactos c, estper_personas p
                   WHERE p.sperson = psperson
                     AND c.sperson(+) = p.spereal;
               END IF;

               INSERT INTO estper_contactos
                           (sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon,
                            cdomici, cprefix, cusuari, fmovimi)
                    VALUES (psperson, vcagente_per, wmodcon, pctipcon, ptcomcon, /*etm 21406*/ ptvalcon,
                            pcdomici, pcprefix, f_user, f_sysdate);   /*bug 24806*/
            ELSE
               SELECT NVL(MAX(cmodcon), 0) + 1
                 INTO wmodcon
                 FROM per_contactos
                WHERE sperson = psperson;

               INSERT INTO per_contactos
                           (sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon,
                            cdomici, cprefix, cusuari, fmovimi)
                    VALUES (psperson, pcagente, wmodcon, pctipcon, ptcomcon, ptvalcon,
                            pcdomici, pcprefix, f_user, /*etm 21406*/ f_sysdate);

               /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                    'MODIF_PERSONA_HOST'),
                      0) = 1
                  AND ptablas = 'POL' THEN
                  num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario,
                                                     vcterminal);

                  IF num_err <> 0 THEN
                     /*i:= i + 1;*/
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, SQLERRM);
                     errores(j) := verr;
                     RETURN num_err;
                  END IF;

                  /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
                  v_host := NULL;

                  /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
                  IF pac_persona.f_gubernamental(psperson) = 1 THEN
                     v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                             'DUPL_DEUDOR_HOST');
                  END IF;

                /* Cambios de IAXIS-4844 : start */
                  num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                    vcterminal, psinterf, terror,
                                                    pac_md_common.f_get_cxtusuario, 0, 'MOD',
                                                    VDIGITOIDE, v_host);
                /* Cambios de IAXIS-4844 : end */

                  IF num_err <> 0 THEN
                     /*i:= i + 1;*/
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, terror);
                     errores(j) := verr;
                     /*añado error del tmenin*/
                     verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                                 pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                     errores.EXTEND;
                     j := j + 1;
                     errores(j) := verr;
                     RETURN num_err;
                  END IF;

                  /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
                    /* Por defecto se envía el acreedor con la cuenta P004*/
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'ALTA_PROV_HOST');

                  /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
                  IF v_host IS NOT NULL THEN
                     IF pac_persona.f_gubernamental(psperson) = 1 THEN
                        v_host :=
                           pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                         'DUPL_ACREEDOR_HOST');
                     END IF;

                     psinterf := NULL;
                     /* Se inicia para que genere un nuevo codigo*/
                     num_err := pac_user.f_get_terminal(f_user, vcterminal);
                     /* Cambios de IAXIS-4844 : start */
                     num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa,
                                                       psperson, vcterminal, psinterf, terror,
                                                       pac_md_common.f_get_cxtusuario, 1,
                                                       'MOD', VDIGITOIDE, v_host);
                    /* Cambios de IAXIS-4844 : end */
                  END IF;

                  IF num_err <> 0 THEN
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, terror);
                     errores(1) := verr;
                     /*añado error del tmenin*/
                     verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                                 pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                     errores.EXTEND;
                     errores(2) := verr;
                     RETURN num_err;
                  END IF;
               /*fin BUG 0026318 -- GGR -- 17/03/2014*/
               
        /* Cambios de  tarea IAXIS-13044 :START */
              PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                                1,
                                                'S03502',
                                                PSINTERF);
                /* Cambios de  tarea IAXIS-13044 :END */
        END IF;
            END IF;

            psmodcon := wmodcon;
         END IF;
      ELSE
         IF ptvalcon IS NOT NULL THEN
         -- Ini ajustes para el 42% personas ACL 02/11/2018
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                 'PER_VAL_TELEF'),
                   0) = 1 THEN
               IF pctipcon = 1 THEN
                SELECT LENGTH (ptvalcon)
                 INTO control
                FROM DUAL;
                  IF control <> 7 THEN
                      errores.EXTEND;
                  verr := ob_error.instanciar(9907933,
                                        f_axis_literales(9907933,
                                                         pac_md_common.f_get_cxtidioma));
                   errores(j) := verr;
                   RETURN 9907933;
                 END IF;
        END IF;

             IF pctipcon = 6 THEN
                SELECT LENGTH (ptvalcon)
                 INTO control
                FROM DUAL;
                IF control <> 10 THEN
                      errores.EXTEND;
                  verr := ob_error.instanciar(9907933,
                                        f_axis_literales(9907933,
                                                         pac_md_common.f_get_cxtidioma));
                   errores(j) := verr;
                   RETURN 9907933;
                 END IF;
        END IF;
    -- Fin ajustes para el 42% personas ACL 02/11/2018
    --INI-CES-IAXIS-4061
               IF pctipcon IN(1, 2, 5, 6) THEN
  --END-CES-IAXIS-4061   
                  BEGIN
                     v_valcon := TO_NUMBER(ptvalcon);
                  EXCEPTION
                     WHEN OTHERS THEN
                        RAISE ex_error;
                  END;
               END IF;
            END IF;

       IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PER_VAL_TELEF'),
             0) = 1
         AND pctipcon = 1
         AND ptvalcon IS NOT NULL THEN
         SELECT LENGTH (ptvalcon)
           INTO control
           FROM DUAL;

         IF control <> 7 THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9907933,
                                        f_axis_literales(9907933,
                                                         pac_md_common.f_get_cxtidioma));
            errores(j) := verr;
            RETURN 9907933;
         END IF;
      END IF;

            IF ptablas = 'EST' THEN
               UPDATE estper_contactos
                  SET ctipcon = pctipcon,
                      tvalcon = ptvalcon,
                      tcomcon = ptcomcon,   /*ETM 21406*/
                      cdomici = pcdomici,   /*etm 24806*/
                      cprefix = pcprefix
                WHERE sperson = psperson
                  AND cmodcon = psmodcon;

               IF SQL%ROWCOUNT = 0 THEN   /*ETM 21406*/
                  RAISE NO_DATA_FOUND;
               END IF;
            ELSE
               UPDATE per_contactos
                  SET ctipcon = pctipcon,
                      tvalcon = ptvalcon,
                      tcomcon = ptcomcon,   /*ETM 21406*/
                      cdomici = pcdomici,   /*etm 24806*/
                      cprefix = pcprefix
                WHERE sperson = psperson
                  AND cmodcon = psmodcon;

               IF SQL%ROWCOUNT = 0 THEN   /*ETM 21406*/
                  RAISE NO_DATA_FOUND;
               END IF;

               /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                    'MODIF_PERSONA_HOST'),
                      0) = 1
                  AND ptablas = 'POL' THEN
                  num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario,
                                                     vcterminal);

                  IF num_err <> 0 THEN
                     /*i:= i + 1;*/
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, SQLERRM);
                     errores(j) := verr;
                     RETURN num_err;
                  END IF;
          /* Cambios de IAXIS-4844 : start */
                  num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                    vcterminal, psinterf, terror,
                                                    pac_md_common.f_get_cxtusuario, 0, 'MOD',VDIGITOIDE);
          /* Cambios de IAXIS-4844 : end */                         

                  IF num_err <> 0 THEN
                     /*i:= i + 1;*/
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, terror);
                     errores(j) := verr;
                     /*añado error del tmenin*/
                     verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                                 pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                     errores.EXTEND;
                     j := j + 1;
                     errores(j) := verr;
                     RETURN num_err;
                  END IF;

                  /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
                    /* Por defecto se envía el acreedor con la cuenta P004*/
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'ALTA_PROV_HOST');

                  /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
                  IF v_host IS NOT NULL THEN
                     IF pac_persona.f_gubernamental(psperson) = 1 THEN
                        v_host :=
                           pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                         'DUPL_ACREEDOR_HOST');
                     END IF;

                     psinterf := NULL;
                     /* Se inicia para que genere un nuevo codigo*/
                     num_err := pac_user.f_get_terminal(f_user, vcterminal);
                     /* Cambios de IAXIS-4844 : start */
                     num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa,
                                                       psperson, vcterminal, psinterf, terror,
                                                       pac_md_common.f_get_cxtusuario, 1,
                                                       'MOD', VDIGITOIDE, v_host);
                    /* Cambios de IAXIS-4844 : end */
                  END IF;

                  IF num_err <> 0 THEN
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, terror);
                     errores(1) := verr;
                     /*añado error del tmenin*/
                     verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                                 pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                     errores.EXTEND;
                     errores(2) := verr;
                     RETURN num_err;
                  END IF;
               /*fin BUG 0026318 -- GGR -- 17/03/2014*/
      /* Cambios de  tarea IAXIS-13044 :START */
            PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                              1,
                                              'S03502',
                                              PSINTERF);
            /* Cambios de  tarea IAXIS-13044 :END */

               END IF;
            END IF;
         /* IF SQL%ROWCOUNT = 0 THEN--ETM 21406
             RAISE NO_DATA_FOUND;
          END IF;*/
         ELSE
            IF ptablas = 'EST' THEN
               DELETE      estper_contactos
                     WHERE sperson = psperson
                       AND cmodcon = psmodcon;
            ELSE
               DELETE      per_contactos
                     WHERE sperson = psperson
                       AND cmodcon = psmodcon;

               /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                    'MODIF_PERSONA_HOST'),
                      0) = 1
                  AND ptablas = 'POL' THEN
                  num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario,
                                                     vcterminal);

                  IF num_err <> 0 THEN
                     /*i:= i + 1;*/
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, SQLERRM);
                     errores(j) := verr;
                     RETURN num_err;
                  END IF;

                  /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
                  v_host := NULL;

                  /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
                  IF pac_persona.f_gubernamental(psperson) = 1 THEN
                     v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                             'DUPL_DEUDOR_HOST');
                  END IF;

                    /* Cambios de IAXIS-4844 : start */
                  num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                    vcterminal, psinterf, terror,
                                                    pac_md_common.f_get_cxtusuario, 0, 'MOD',
                                                    VDIGITOIDE, v_host);
                    /* Cambios de IAXIS-4844 : end */

                  IF num_err <> 0 THEN
                     /*i:= i + 1;*/
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, terror);
                     errores(j) := verr;
                     /*añado error del tmenin*/
                     verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                                 pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                     errores.EXTEND;
                     j := j + 1;
                     errores(j) := verr;
                     RETURN num_err;
                  END IF;

                  /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
                    /* Por defecto se envía el acreedor con la cuenta P004*/
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'ALTA_PROV_HOST');

                  /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
                  IF v_host IS NOT NULL THEN
                     IF pac_persona.f_gubernamental(psperson) = 1 THEN
                        v_host :=
                           pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                         'DUPL_ACREEDOR_HOST');
                     END IF;

                     psinterf := NULL;
                     /* Se inicia para que genere un nuevo codigo*/
                     num_err := pac_user.f_get_terminal(f_user, vcterminal);
                     /* Cambios de IAXIS-4844 : start */
                     num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa,
                                                       psperson, vcterminal, psinterf, terror,
                                                       pac_md_common.f_get_cxtusuario, 1,
                                                       'MOD', VDIGITOIDE, v_host);
                    /* Cambios de IAXIS-4844 : end */
                  END IF;

                  IF num_err <> 0 THEN
                     errores.EXTEND;
                     verr := ob_error.instanciar(num_err, terror);
                     errores(1) := verr;
                     /*añado error del tmenin*/
                     verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                                 pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                     errores.EXTEND;
                     errores(2) := verr;
                     RETURN num_err;
                  END IF;
               /*fin BUG 0026318 -- GGR -- 17/03/2014*/

      /* Cambios de  tarea IAXIS-13044 :START */
            PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                              1,
                                              'S03502',
                                              PSINTERF);
            /* Cambios de  tarea IAXIS-13044 :END */

               END IF;
            END IF;

            psmodcon := NULL;
         END IF;
      END IF;

      /* INI RLLF 10/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PER_AGENDA'), 0) =
                                                                                              1
         AND ptablas = 'POL' THEN
         num_err := f_set_agensegu_rol(psperson, 'CNT', pac_md_common.f_get_cxtidioma);

         IF num_err <> 0 THEN
            /*vtraza := 55;*/
            errores.EXTEND;
            verr := ob_error.instanciar(num_err, SQLERRM);
            errores(j) := verr;
            RETURN 1;
         END IF;
      END IF;

      /* FIN RLLF 10/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
      RETURN 0;
   EXCEPTION
      /* Ini bug 30417/11671 -- ECP -- 07/03/2014*/
      WHEN ex_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_Contacto.Error '
                     || f_axis_literales(9906609, pac_md_common.f_get_cxtidioma),
                     SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(9906609,
                                     f_axis_literales(9906609, pac_md_common.f_get_cxtidioma));
         /*Valor No numérico para contacto telefónico.*/
         errores(j) := verr;
         RETURN 9906609;
      /* Fin bug 30417/11671 -- ECP -- 07/03/2014*/
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_Contacto.Error Imprevisto insertando contacto.', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(152961, SQLERRM);
         errores(j) := verr;
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_Contacto.Error Imprevisto insertando contacto.', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(152961, SQLERRM);
         errores(j) := verr;
         RETURN 1;
   END f_set_contacto;

   FUNCTION f_validanacionalidad(pctipper IN NUMBER, pcpais IN NUMBER)
      RETURN NUMBER IS
      tpais          VARCHAR2(200);
      vnum_err       NUMBER := 0;
   BEGIN
      /*      IF pctipper = 1*/
      /*      THEN*/
      /*         IF pcpais IS NULL*/
      /*         THEN*/
      /*            RETURN 151970;*/
      /*         END IF;*/
          /*      ELSE*/
      IF pctipper != 1
         AND pcpais IS NOT NULL THEN
         RETURN 151941;   /*Una persona juridica no puede tener nacionalidad.*/
      END IF;

      RETURN 0;
   END;

   FUNCTION f_gubernamental(psperson IN NUMBER)
      RETURN NUMBER IS
      vvalor         NUMBER := 0;
   BEGIN
      /* Comprueba si es una persona gubernamental para enviarlo con el codigo de cuenta P029*/
      SELECT nvalpar
        INTO vvalor
        FROM per_parpersonas
       WHERE sperson = psperson
         AND cparam = 'PER_OFICIAL'
         AND nvalpar = 1;

      RETURN vvalor;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_gubernamental;

   FUNCTION f_set_ccc(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcnordban IN OUT NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR,
      errores IN OUT t_ob_error,
      pcdefecto IN NUMBER DEFAULT 1,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pcpagsin IN NUMBER DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      pfvencim IN DATE DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      ptseguri IN VARCHAR2 DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      pctipcc IN VARCHAR2 DEFAULT NULL
                                      /* 20735/102170 Introduccion de cuenta bancaria*/
   )
      RETURN NUMBER IS
      psup           NUMBER;
      i              NUMBER := 1;
      j              NUMBER := 1;
      verr           ob_error;
      vnordban       NUMBER;
      vnordban_est   NUMBER;
      vswpubli       NUMBER;
      /* jlb - i - bug mantis 6352*/
      vsperreal      estper_personas.spereal%TYPE;
      /* jlb - f - bug mantis 6352*/
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      vctipcc        NUMBER;
      vctipban       NUMBER := pctipban;
      /* 20735/102170 Introduccion de cuenta bancaria*/
      vcbanco        VARCHAR2(200);
      /* 20735/102170 Introduccion de cuenta bancaria*/
      /* 43.0 0026896: La númeración de las tarjetas VISA empieza pos "4", Master Card por "5" - Inicio*/
      vprefijo       tipos_cuenta.prefijo%TYPE;
      vpos_entidad   tipos_cuenta.pos_entidad%TYPE;
      vlong_entidad  tipos_cuenta.long_entidad%TYPE;
      /* 43.0 0026896: La númeración de las tarjetas VISA empieza pos "4", Master Card por "5" - Final*/
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
      vccobban       mandatos.ccobban%TYPE;
      tarj_cuenta    NUMBER;
      vcestado       mandatos.cestado%TYPE;
      /* Cambios de IAXIS-4844 : start */
    VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;    
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    /* Cambios de IAXIS-4844 : end */

   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      /*Inicio BUG 29222/160288 - 09/12/2013 - RCL - 0029222: LCOL - PER - Fecha de vencimiento de tarjeta*/
      IF (EXTRACT(YEAR FROM pfvencim) < EXTRACT(YEAR FROM f_sysdate)) THEN
         RETURN 9905971;
      END IF;

      IF (EXTRACT(YEAR FROM pfvencim) = EXTRACT(YEAR FROM f_sysdate)
          AND EXTRACT(MONTH FROM pfvencim) < EXTRACT(MONTH FROM f_sysdate)) THEN
         RETURN 9905971;
      END IF;

      /*Fi BUG 29222/160288 - 09/12/2013 - RCL - 0029222: LCOL - PER - Fecha de vencimiento de tarjeta*/
      /* 29/12/2011 JGR 24. 0020735: Introduccion de cuenta bancaria, indicando tipo de cuenta y banco Nota:102170 - Inicio*/
      IF pctipcc IS NOT NULL
         AND vctipban IS NULL THEN
         BEGIN
            /* Cuentas corrientes y de ahorro*/
            /* 43.0 0026896 - Inicio*/
            /*SELECT ctipban*/
                /*  INTO vctipban*/
            BEGIN
               SELECT ctipban, prefijo, pos_entidad, long_entidad
                 INTO vctipban, vprefijo, vpos_entidad, vlong_entidad
                 /* 43.0 0026896 - Inicio*/
               FROM   tipos_cuenta
                WHERE ctipcc = pctipcc
                  AND(longitud = LENGTH(pcbancar)
                      OR longitud IS NULL)
                  AND(cbanco = SUBSTR(pcbancar, pos_entidad, long_entidad)
                      OR cbanco IS NULL);
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  SELECT ctipban, prefijo, pos_entidad, long_entidad
                    INTO vctipban, vprefijo, vpos_entidad, vlong_entidad
                    /* 43.0 0026896 - Inicio*/
                  FROM   tipos_cuenta
                   WHERE ctipcc = pctipcc
                     AND(longitud = LENGTH(pcbancar)
                         OR longitud IS NULL)
                     AND cbanco = SUBSTR(pcbancar, pos_entidad, long_entidad);
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               /* Las tarjetas al no tener informado el Banco las encontrará aquí*/
               BEGIN
                  /* 43.0 0026896 - Inicio*/
                  /*SELECT ctipban*/
                      /*  INTO vctipban*/
                  SELECT ctipban, prefijo, pos_entidad, long_entidad
                    INTO vctipban, vprefijo, vpos_entidad, vlong_entidad
                    /* 43.0 0026896 - Inicio*/
                  FROM   tipos_cuenta
                   WHERE ctipcc = pctipcc
                     AND pctipcc IN(4, 5, 6, 7, 9)   /*> Solo tarjetas*/
                     AND(longitud = LENGTH(pcbancar)
                         OR longitud IS NULL);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     /* 9903056 Formato de cuenta bancaria/tarjeta no es de este banco.*/
                     p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                                 'Por el banco de la cuenta cbancar(' || pcbancar
                                 || ') y tipo de cuenta CTIPCC(' || pctipcc
                                 || '). No se encuentra tipo de cuenta en TIPOS_CUENTA',
                                 SQLERRM);
                     RETURN 9903056;
                  WHEN OTHERS THEN
                     /* 180928 Error al buscar la descripció del tipus o format de compte ccc*/
                     p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                                 'Buscando tipo de banco para tarjetas segun pctipcc('
                                 || pctipcc || ') pcbancar(' || pcbancar || ')',
                                 SQLERRM);
                     RETURN 180928;
               END;
            WHEN OTHERS THEN
               /* 180928 Error al buscar la descripció del tipus o format de compte ccc*/
               p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                           'Buscando tipo de banco segun pctipcc(' || pctipcc || ') pcbancar('
                           || pcbancar || ')',
                           SQLERRM);
               RETURN 180928;
         END;

         /* 43.0 0026896: La númeración de las tarjetas VISA empieza pos "4", Master Card por "5". - Inicio*/
         IF vprefijo IS NOT NULL
            AND SUBSTR(pcbancar, NVL(vpos_entidad + vlong_entidad, 1)) NOT LIKE vprefijo || '%' THEN
            RETURN 9905517;   /* La numeración de la tarjeta es incorrecta*/
         END IF;
      /* 43.0 0026896: La númeración de las tarjetas VISA empieza pos "4", Master Card por "5". - Final*/
      END IF;

      /* 29/12/2011 JGR 24. 0020735: Introduccion de cuenta bancaria, indicando tipo de cuenta y banco Nota:102170 - Fin*/
      IF ptablas = 'EST' THEN
         IF pcbancar IS NOT NULL THEN
            /* BUG18808:DRA:15/06/2011:Inici*/
            /*Bug.: 15329 - ICV - 24/08/2010*/
              /* Esta función nos sirve para recuperar el código de agente con el que se ha de grabar.*/
            pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per,
                                        ptablas);

            /* BUG18808:DRA:15/06/2011:Fi*/
            BEGIN
               /* bug 7873*/
               IF pcnordban IS NULL THEN
                  /* DRA 03-10-2008: bug mantis 6352*/
                    /* jlb - i - bug mantis 6352*/
                  SELECT spereal
                    INTO vsperreal
                    FROM estper_personas
                   WHERE sperson = psperson;

                  /* jlb - F - bug mantis 6352*/
                    /* DRA 03-10-2008: bug mantis 6352*/
                  vnordban := pac_persona.f_existe_ccc(vsperreal,
                                                       /* jlb - i - bug mantis 6352*/
                                                       vcagente_per,
                                                       /* Bug 7873*/
                                                       /* 20735/102170 Introduccion de cuenta bancaria - Inicio*/
                                                       /* pctipban,*/
                                                       vctipban,
                                                       /* 20735/102170 Introduccion de cuenta bancaria - Fin*/
                                                       pcbancar);

                  IF vnordban IS NULL THEN
                     SELECT NVL(MAX(e.cnordban), 0)
                       INTO vnordban_est
                       FROM estper_ccc e, estper_personas p
                      WHERE e.sperson = p.sperson
                        AND p.sperson = psperson;

                     SELECT GREATEST(vnordban_est, NVL(MAX(c.cnordban), 0)) + 1
                       INTO vnordban
                       FROM per_ccc c, estper_personas p
                      WHERE p.sperson = psperson
                        AND c.sperson(+) = p.spereal;
                  END IF;
               ELSE
                  vnordban := pcnordban;
               END IF;

               /* Bug 20790 - APD - 03/01/2012 - valdia la ccc*/
               num_err := pac_persona.f_valida_ccc(psperson, vnordban, vcagente_per, pcbancar);

               IF num_err <> 0 THEN
                  /*errores.EXTEND;
                  verr := ob_error.instanciar(num_err, SQLERRM);
                  errores(j) := verr;
                  RETURN 1;*/
                  RETURN num_err;
               END IF;

               /* fin Bug 20790 - APD - 03/01/2012*/
               INSERT INTO estper_ccc
                           (sperson, cagente, ctipban, cbancar, fbaja, cusumov,
                            fusumov, cdefecto, cnordban, cpagsin, fvencim,
                            tseguri /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/)
                    VALUES (psperson, vcagente_per, /* 20735/102170 Introduccion de cuenta bancaria - Inicio*/ /* pctipban,*/ vctipban, /* 20735/102170 Introduccion de cuenta bancaria - Fin*/ pcbancar, NULL, f_user,
                            f_sysdate, pcdefecto, vnordban, pcpagsin, pfvencim,
                            ptseguri /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/);

               pcnordban := vnordban;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estper_ccc
                     SET cdefecto = pcdefecto,
                         /* cagente = pcagente,  -- DRA 13-10-2008: bug mantis 7784*/
                         /* 20735/102170 Introduccion de cuenta bancaria - Inicio*/
                         /*ctipban = pctipban,*/
                         ctipban = vctipban,
                         /* 20735/102170 Introduccion de cuenta bancaria - Fin*/
                         cbancar = pcbancar,
                         /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici*/
                         cpagsin = pcpagsin,
                         fvencim = pfvencim,
                         tseguri = ptseguri
                   /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi*/
                  WHERE  sperson = psperson
                     AND cnordban = vnordban;

                  IF SQL%ROWCOUNT = 0 THEN
                     RAISE NO_DATA_FOUND;
                  END IF;
            END;

            IF pcdefecto = 1 THEN
               UPDATE estper_ccc   /*Ponemos los otros como no defecto*/
                  SET cdefecto = 0
                WHERE sperson = psperson
                  AND cagente = vcagente_per
                  /* bug 7873 pcagente -- DRA 13-10-2008: bug mantis 7784*/
                  AND cnordban <> vnordban
                  AND cdefecto <> 0;
            END IF;

            /*RSA MANDATOS insertar o modificar en tabla estmandatos*/
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'INS_MANDATO'),
                   0) = 1 THEN
               /* Inicio Bug 31135 MMS 20141010*/
               /*tarj_cuenta := pac_ccc.f_estarjeta(NULL, vctipban);
               IF tarj_cuenta = 0 THEN
                  vccobban := 2;   -- Cobrador cuenta
               ELSE
                  vccobban := 1;   -- Cobrador tarjeta
               END IF;*/
               BEGIN
                  SELECT   cb.ccobban
                      INTO vccobban
                      FROM cobbancario cb, cobbancariosel cl, tipos_cuenta tc
                     WHERE cb.ccobban = cl.ccobban
                       AND tc.pos_entidad IS NOT NULL
                       AND tc.long_entidad IS NOT NULL
                       AND NVL(cb.ctarjeta, 0) = pac_ccc.f_estarjeta(tc.ctipcc, NULL)
                       AND TO_NUMBER(SUBSTR(pcbancar, tc.pos_entidad, tc.long_entidad)) =
                                                                                      cl.cbanco
                       AND tc.ctipban = vctipban
                       AND cl.cempres = pac_md_common.f_get_cxtempresa()
                  GROUP BY cb.ccobban;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_set_ccc', 4,
                                 'No se ha encontrado ningún cobrador bancario', SQLERRM);
                     RETURN 9907161;
                  WHEN TOO_MANY_ROWS THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_set_ccc', 4,
                                 'Existen más de un cobrador bancario', SQLERRM);
                     RETURN 9907162;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_set_ccc', 4,
                                 'Error al buscar el cobrador bancario', SQLERRM);
                     RETURN 9907163;
               END;

               /* Estado inical a pendiente, pendiente de mirar el estado segun perfil conectado*/
               vcestado := 0;
               num_err := pac_mandatos.f_set_mandatos('EST', psperson, vnordban, vctipban,
                                                      pcbancar, vccobban, vcestado, pfvencim,
                                                      ptseguri);

               IF num_err <> 0 THEN
                  errores.EXTEND;
                  verr := ob_error.instanciar(num_err, SQLERRM);
                  errores(j) := verr;
                  RETURN num_err;
               END IF;
            /* Fin Bug 31135 MMS 20141010*/
            END IF;
         ELSE
            UPDATE estper_ccc   /*Ponemos la cuenta como  no defecto*/
               SET cdefecto = 0
             WHERE sperson = psperson
               AND cnordban = pcnordban;
         END IF;
      ELSE
         IF pcbancar IS NOT NULL THEN
            BEGIN
               IF pcnordban IS NULL THEN
                  SELECT NVL(MAX(cnordban), 0) + 1
                    INTO vnordban
                    FROM per_ccc
                   WHERE sperson = psperson;
               ELSE
                  vnordban := pcnordban;
               END IF;

               /*Bug 29166/160004 - 29/11/2013 - AMC*/
               SELECT swpubli, DECODE(swpubli, 1, cagente, pcagente)
                 INTO vswpubli, vcagente_per
                 FROM per_personas
                WHERE sperson = psperson;

               /*XPL mirem si la persona és pública, si és pública només pot tenir un detall.*/
               /* per tant creem el registre amb aquest agent.*/
               /*     IF vswpubli IS NOT NULL
                       AND vswpubli = 1 THEN
                       BEGIN
                          SELECT cagente
                            INTO vcagente_per
                            FROM per_detper
                           WHERE sperson = psperson;
                       EXCEPTION
                          WHEN OTHERS THEN
                             errores.EXTEND;
                             verr := ob_error.instanciar(9901836, SQLERRM);
                             errores(j) := verr;
                             p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                                         'Buscando agente de la persona publica', SQLERRM);
                             RETURN 1;
                       END;
                    ELSE
                       -- BUG18808:DRA:15/06/2011:Si no és pública debe coger el valor del paràmetro
                       vcagente_per := pcagente;
                    END IF;*/
               /*Fi Bug 29166/160004 - 29/11/2013 - AMC*/
               /* Bug 20790 - APD - 03/01/2012 - valdia la ccc*/
               num_err := pac_persona.f_valida_ccc(psperson, vnordban, vcagente_per, pcbancar);

               IF num_err <> 0 THEN
                  /*errores.EXTEND;
                  verr := ob_error.instanciar(num_err, SQLERRM);
                  errores(j) := verr;
                  RETURN 1;*/
                  RETURN num_err;
               END IF;

               /* fin Bug 20790 - APD - 03/01/2012*/
               INSERT INTO per_ccc
                           (sperson, cagente, ctipban, cbancar, fbaja, cusumov,
                            fusumov, cdefecto, cnordban, cpagsin, fvencim,
                            tseguri /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/)
                    VALUES (psperson, vcagente_per, /* 20735/102170 Introduccion de cuenta bancaria - Inicio*/ /*pctipban,*/ vctipban, /* 20735/102170 Introduccion de cuenta bancaria - Fi*/ pcbancar, NULL, f_user,
                            f_sysdate, pcdefecto, vnordban, pcpagsin, pfvencim,
                            ptseguri /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/);

               pcnordban := vnordban;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE per_ccc
                     SET cdefecto = pcdefecto,
                         /* cagente = pcagente,  -- DRA 13-10-2008: bug mantis 7784*/
                         /* 20735/102170 Introduccion de cuenta bancaria - Inicio*/
                         /*ctipban = pctipban,*/
                         ctipban = vctipban,
                         /* 20735/102170 Introduccion de cuenta bancaria - Fi*/
                         cbancar = pcbancar,
                         /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici*/
                         cpagsin = pcpagsin,
                         fvencim = pfvencim,
                         tseguri = ptseguri
                   /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi*/
                  WHERE  sperson = psperson
                     AND cnordban = vnordban;

                  IF SQL%ROWCOUNT = 0 THEN
                     RAISE NO_DATA_FOUND;
                  END IF;
            END;

            IF pcdefecto = 1 THEN
               UPDATE per_ccc   /*Ponemos los otros como no defecto*/
                  SET cdefecto = 0
                WHERE sperson = psperson
                  AND cagente = vcagente_per
                  /* DRA 13-10-2008: bug mantis 7784*/
                  AND cnordban <> vnordban
                  AND cdefecto <> 0;

            END IF;

            /*RSA MANDATOS insertar o modificar en tabla mandatos*/
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'INS_MANDATO'),
                   0) = 1 THEN
               /* Inicio Bug 31135 MMS 20141010*/
               /* tarj_cuenta := pac_ccc.f_estarjeta(NULL, vctipban);

                IF tarj_cuenta = 0 THEN
                   vccobban := 2;   -- Cobrador cuenta
                ELSE
                   vccobban := 1;   -- Cobrador tarjeta
                END IF;*/
               BEGIN
                  SELECT   cb.ccobban
                      INTO vccobban
                      FROM cobbancario cb, cobbancariosel cl, tipos_cuenta tc
                     WHERE cb.ccobban = cl.ccobban
                       AND tc.pos_entidad IS NOT NULL
                       AND tc.long_entidad IS NOT NULL
                       AND NVL(cb.ctarjeta, 0) = pac_ccc.f_estarjeta(tc.ctipcc, NULL)
                       AND TO_NUMBER(SUBSTR(pcbancar, tc.pos_entidad, tc.long_entidad)) =
                                                                                      cl.cbanco
                       AND tc.ctipban = vctipban
                       AND cl.cempres = pac_md_common.f_get_cxtempresa()
                  GROUP BY cb.ccobban;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_set_ccc', 4,
                                 'No se ha encontrado ningún cobrador bancario', SQLERRM);
                     RETURN 9907161;
                  WHEN TOO_MANY_ROWS THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_set_ccc', 4,
                                 'Existen más de un cobrador bancario', SQLERRM);
                     RETURN 9907162;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_set_ccc', 4,
                                 'Error al buscar el cobrador bancario', SQLERRM);
                     RETURN 9907163;
               END;

               /* Estado inical a pendiente, pendiente de mirar el estado segun perfil conectado*/
               vcestado := 0;
               num_err := pac_mandatos.f_set_mandatos('POL', psperson, vnordban, vctipban,
                                                      pcbancar, vccobban, vcestado, pfvencim,
                                                      ptseguri);

               IF num_err <> 0 THEN
                  errores.EXTEND;
                  verr := ob_error.instanciar(num_err, SQLERRM);
                  errores(j) := verr;
                  RETURN num_err;
               END IF;
            /* Fin Bug 31135 MMS 20141010*/
            END IF;
         ELSE
            UPDATE per_ccc   /*Ponemos la cuenta como  no defecto*/
               SET cdefecto = 0
             WHERE sperson = psperson
               AND cnordban = pcnordban;
         END IF;

         /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'MODIF_PERSONA_HOST'),
                0) = 1
            AND ptablas = 'POL' THEN
            /*   SELECT NVL(ctipcc, 1) --BUG 20921 --ETM 0020921: LCOL898- Interfase sincronitzaci? de persones. Incid?ncies (I)
                 INTO vctipcc
                 FROM tipos_cuenta
                -- 20735/102170 Introduccion de cuenta bancaria - Inici
                --WHERE ctipban = pctipban;
               WHERE  ctipban = vctipban;

               -- 20735/102170 Introduccion de cuenta bancaria - Fi
               IF vctipcc = 1 THEN*/
            num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, SQLERRM);
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* Cambios de IAXIS-4844 : start */
              BEGIN
                SELECT PP.NNUMIDE,PP.TDIGITOIDE
                  INTO VPERSON_NUM_ID,VDIGITOIDE
                  FROM PER_PERSONAS PP
                 WHERE PP.SPERSON = psperson
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  SELECT PP.CTIPIDE, PP.NNUMIDE
                    INTO VCTIPIDE, VPERSON_NUM_ID
                    FROM PER_PERSONAS PP
                   WHERE PP.SPERSON = psperson;
                  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                                 UPPER(VPERSON_NUM_ID));
              END;
            /* Cambios de IAXIS-4844 : end */

            /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
            v_host := NULL;

            /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
            END IF;

            /* Cambios de IAXIS-4844 : start */
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOIDE,
                                              v_host);
            /* Cambios de IAXIS-4844 : end */

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(j) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               j := j + 1;
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;

            IF num_err <> 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(1) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               errores(2) := verr;
               RETURN num_err;
            END IF;
         /*fin BUG 0026318 -- GGR -- 17/03/2014*/
         /*END IF;*/
         
          /* Cambios de  tarea IAXIS-13044 :start */
             PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID, 1, 'S03502',PSINTERF);                 
          /* Cambios de  tarea IAXIS-13044 :end */          
         
         END IF;
      END IF;

      /* Bug 26318 - 10/10/2013 - JMG - Inicio #155391 Anotación en la agenda de las pólizas*/
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PER_AGENDA'), 0) =
                                                                                              1
         AND ptablas = 'POL' THEN
         num_err := f_set_agensegu_rol(psperson, 'CCC', pac_md_common.f_get_cxtidioma);

         IF num_err <> 0 THEN
            /*vtraza := 55;*/
            errores.EXTEND;
            verr := ob_error.instanciar(num_err, SQLERRM);
            errores(i) := verr;
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_ccc.Error Imprevisto insertando CCC.', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(120130, SQLERRM);
         errores(j) := verr;
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_ccc;.Error Imprevisto insertando CCC.', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(120130, SQLERRM);
         errores(j) := verr;
         RETURN 1;
   END f_set_ccc;

   FUNCTION f_set_nacionalidad(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcpais IN NUMBER,
      pcdefecto IN NUMBER DEFAULT 1,
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
      psup           NUMBER;
      j              NUMBER := 1;
      verr           ob_error;
      vctipper       NUMBER;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      v_host         VARCHAR2(10);                                /*BUG 26318/167380-- GGR -- 17/03/2014*/
                                     /*BUG 34989/200761 KJSC Modificacion de la funcion f_set_nacionalidad.*/
      v_norden       NUMBER := 1;
      /* Cambios de IAXIS-4844 : start */
    VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;    
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    /* Cambios de IAXIS-4844 : end */

   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF ptablas = 'EST' THEN
         /* bug 7873*/
           /* Esta función nos sirve para recuperar el código de agente con el que se ha de grabar.*/
         pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per,
                                     ptablas);

         SELECT ctipper
           INTO vctipper
           FROM estper_personas
          WHERE sperson = psperson;

         /* persona física*/
         IF vctipper = 1 THEN
            /*BEGIN
               INSERT INTO estper_nacionalidades
                           (sperson, cagente, cpais, cdefecto)
                    VALUES (psperson, vcagente_per, pcpais, pcdefecto);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estper_nacionalidades
                     SET cdefecto = pcdefecto
                   WHERE sperson = psperson
                     AND cagente = vcagente_per
                     AND cpais = pcpais;

                  IF SQL%ROWCOUNT = 0 THEN
                     RAISE NO_DATA_FOUND;
                  END IF;
            END;*/
            /*Inicio BUG 34989/200761 KJSC Modificacion de la funcion f_set_nacionalidad*/
            BEGIN
               SELECT NVL(MAX(norden), 0) + 1
                 INTO v_norden
                 FROM estper_nacionalidades
                WHERE sperson = psperson
                  AND cagente = vcagente_per;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_norden := 1;
            END;

            BEGIN
               INSERT INTO estper_nacionalidades
                           (sperson, cagente, cpais, cdefecto, norden)
                    VALUES (psperson, vcagente_per, pcpais, pcdefecto, v_norden);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estper_nacionalidades
                     SET cdefecto = pcdefecto,
                         norden = v_norden
                   WHERE sperson = psperson
                     AND cagente = vcagente_per
                     AND cpais = pcpais;

                  IF SQL%ROWCOUNT = 0 THEN
                     RAISE NO_DATA_FOUND;
                  END IF;
            END;

            /*Fin BUG 34989/200761 KJSC Modificacion de la funcion f_set_nacionalidad*/
            IF pcdefecto = 1 THEN
               UPDATE estper_nacionalidades
                  /*Ponemos los otros como no defecto*/
               SET cdefecto = 0
                WHERE sperson = psperson
                  AND cagente = vcagente_per
                  AND cpais <> pcpais;
            END IF;
         ELSE
            /*Una persona juridica no tiene nacionalidades*/
            DELETE      estper_nacionalidades
                  WHERE sperson = psperson
                    AND cagente = pcagente;

            RETURN 9000788;
         END IF;
      ELSE
         SELECT ctipper
           INTO vctipper
           FROM per_personas
          WHERE sperson = psperson;

         IF vctipper = 1 THEN
            /* BEGIN
                INSERT INTO per_nacionalidades
                            (sperson, cagente, cpais, cdefecto)
                     VALUES (psperson, pcagente, pcpais, pcdefecto);
             EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                   UPDATE per_nacionalidades
                      SET cdefecto = pcdefecto
                    WHERE sperson = psperson
                      AND cagente = pcagente
                      AND cpais = pcpais;

                   IF SQL%ROWCOUNT = 0 THEN
                      RAISE NO_DATA_FOUND;
                   END IF;
             END;*/
            /*Inicio BUG 34989/200761 KJSC Modificacion de la funcion f_set_nacionalidad*/
            BEGIN
               SELECT NVL(MAX(norden), 0) + 1
                 INTO v_norden
                 FROM per_nacionalidades
                WHERE sperson = psperson
                  AND cagente = pcagente;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_norden := 1;
            END;

            BEGIN
               INSERT INTO per_nacionalidades
                           (sperson, cagente, cpais, cdefecto, norden)
                    VALUES (psperson, pcagente, pcpais, pcdefecto, v_norden);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE per_nacionalidades
                     SET cdefecto = pcdefecto,
                         norden = v_norden
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND cpais = pcpais;

                  IF SQL%ROWCOUNT = 0 THEN
                     RAISE NO_DATA_FOUND;
                  END IF;
            END;

            /*Fin BUG 34989/200761 KJSC Modificacion de la funcion f_set_nacionalidad*/
            IF pcdefecto = 1 THEN
               UPDATE per_nacionalidades   /*Ponemos los otros como no defecto*/
                  SET cdefecto = 0
                WHERE sperson = psperson
                  AND cagente = pcagente
                  AND cpais <> pcpais;
            END IF;
         ELSE
            /*Una persona juridica no tiene nacionalidades*/
            DELETE      per_nacionalidades
                  WHERE sperson = psperson
                    AND cagente = pcagente;

            RETURN 9000788;
         END IF;

         /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'MODIF_PERSONA_HOST'),
                0) = 1
            AND ptablas = 'POL' THEN
            num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, SQLERRM);
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* Cambios de IAXIS-4844 : start */
              BEGIN
                SELECT PP.NNUMIDE,PP.TDIGITOIDE
                  INTO VPERSON_NUM_ID,VDIGITOIDE
                  FROM PER_PERSONAS PP
                 WHERE PP.SPERSON = psperson
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  SELECT PP.CTIPIDE, PP.NNUMIDE
                    INTO VCTIPIDE, VPERSON_NUM_ID
                    FROM PER_PERSONAS PP
                   WHERE PP.SPERSON = psperson;
                  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                                 UPPER(VPERSON_NUM_ID));
              END;
            /* Cambios de IAXIS-4844 : end */

            /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
            v_host := NULL;

            /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
            END IF;

            /* Cambios de IAXIS-4844 : start */
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOIDE,
                                              v_host);
            /* Cambios de IAXIS-4844 : end */

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(j) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               j := j + 1;
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;

            IF num_err <> 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(1) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               errores(2) := verr;
               RETURN num_err;
            END IF;
         /*fin BUG 0026318 -- GGR --  17/03/2014*/
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_Nacionalidad.Error Imprevisto insertando Nacionalidades.',
                     SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(151970, SQLERRM);
         errores(j) := verr;
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_Nacionalidad.Error Imprevisto insertando  Nacionalidades.',
                     SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(151970, SQLERRM);
         errores(j) := verr;
         RETURN 1;
   END f_set_nacionalidad;

   FUNCTION f_set_identificador(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      errores IN OUT t_ob_error,
      pdefecto IN NUMBER DEFAULT 0,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pcidioma IN idiomas.cidioma%TYPE,
      /* Bug 22263 - 11/07/2012 - ETM*/
      ppaisexp IN NUMBER DEFAULT NULL,
      pcdepartexp IN NUMBER DEFAULT NULL,
      pcciudadexp IN NUMBER DEFAULT NULL,
      pfechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      psup           NUMBER;
      j              NUMBER := 1;
      verr           ob_error;
      wmodcon        NUMBER;
      v_cont         NUMBER;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      /*0028402 - INICIO - DCT - LCOL - PER - El campo país de expedición no queda informado por defecto.*/
      v_ppaisexp     per_identificador.cpaisexp%TYPE;
      /*0028402 - FIN - DCT - LCOL - PER - El campo país de expedición no queda informado por defecto.*/
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;  /* Cambios de IAXIS-4844 PK-19/07/2019 */

   BEGIN
      errores := t_ob_error();
      errores.DELETE;
      /* bug 7873*/
      /* Esta función nos sirve para recuperar el código de agente con el que se ha de grabar.*/
      pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per, ptablas);

      /*0028402 - INICIO - DCT - LCOL - PER - El campo país de expedición no queda informado por defecto.*/
      IF ppaisexp IS NULL THEN
         v_ppaisexp := f_parinstalacion_n('PAIS_DEF');
      ELSE
         v_ppaisexp := ppaisexp;
      END IF;

      /*0028402 - FIN - DCT - LCOL - PER - El campo país de expedición no queda informado por defecto.*/
      /*
      if ptablas = 'EST' then

          SELECT COUNT (1)
            INTO v_cont
            FROM estper_identificador pi, estper_personas pp
           WHERE pi.sperson = pp.sperson
             AND pi.ctipide = pp.ctipide
             AND pi.ctipide = pctipide
             AND pi.sperson = psperson
             AND pi.cagente = vcagente_per -- Bug 7873 El identificador único es por persona/ agente
             AND pi.swidepri = 1;
      else
          SELECT COUNT (1)
            INTO v_cont
            FROM per_identificador pi, per_personas pp
           WHERE pi.sperson = pp.sperson
             AND pi.ctipide = pp.ctipide
             AND pi.ctipide = pctipide
             AND pi.sperson = psperson
             AND pi.cagente = pcagente -- Bug 7873 El identificador único es por persona/ agente
             AND pi.swidepri = 1;
      end if;

      IF v_cont > 0
      THEN
         errores.EXTEND;
         verr := ob_error.instanciar (9000429, f_axis_literales (9000429, pcidioma));
         errores (j) := verr;
         RETURN 1;
      END IF;
      */
      IF ptablas = 'EST' THEN
         BEGIN
            /* Bug 22263 - 11/07/2012 - ETM*/
            INSERT INTO estper_identificador
                        (sperson, cagente, ctipide, nnumide, femisio, swidepri,
                         cpaisexp, cdepartexp, cciudadexp, fechadexp)
                 VALUES (psperson, vcagente_per, pctipide, pnnumide, f_sysdate, pdefecto,
                         v_ppaisexp, pcdepartexp, pcciudadexp, pfechaexp);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               /* Bug 20441/101686 - 10/01/2012 - AMC*/
                 /*  UPDATE estper_identificador
                      SET nnumide = pnnumide,
                          swidepri = pdefecto
                    WHERE sperson = psperson
                      AND cagente = vcagente_per
                      AND ctipide = pctipide; */
               RETURN 9903106;
         /* Fi Bug 20441/101686 - 10/01/2012 - AMC*/
         END;

         IF pdefecto = 1 THEN
            UPDATE estper_identificador
               SET swidepri = 0
             WHERE sperson = psperson
               AND cagente = vcagente_per
               AND ctipide <> pctipide;
         END IF;
      ELSE
         BEGIN
            /* Bug 22263 - 11/07/2012 - ETM*/
            INSERT INTO per_identificador
                        (sperson, cagente, ctipide, nnumide, femisio, swidepri,
                         cpaisexp, cdepartexp, cciudadexp, fechadexp)
                 VALUES (psperson, pcagente, pctipide, pnnumide, f_sysdate, pdefecto,
                         v_ppaisexp, pcdepartexp, pcciudadexp, pfechaexp);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               /* Bug 20441/101686 - 10/01/2012 - AMC*/
                 /* UPDATE per_identificador
                     SET nnumide = pnnumide,
                         swidepri = pdefecto
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND ctipide = pctipide;*/
               RETURN 9903106;
         /* Fi Bug 20441/101686 - 10/01/2012 - AMC*/
         END;

         IF pdefecto = 1 THEN
            UPDATE per_identificador
               SET swidepri = 0
             WHERE sperson = psperson
               AND cagente = pcagente
               AND ctipide <> pctipide;
         END IF;

         /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'MODIF_PERSONA_HOST'),
                0) = 1
            AND ptablas = 'POL'
            AND pdefecto <> 1 THEN
            num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, SQLERRM);
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* Cambios de IAXIS-4844 : start */
              BEGIN
                SELECT PP.TDIGITOIDE
                  INTO VDIGITOIDE
                  FROM PER_PERSONAS PP
                 WHERE PP.SPERSON = psperson
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(pctipide,
                                                                 UPPER(pnnumide));
              END;
            /* Cambios de IAXIS-4844 : end */

            /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
            v_host := NULL;

            /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
            END IF;
            /* Cambios de IAXIS-4844 : start */
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOIDE,
                                              v_host);
            /* Cambios de IAXIS-4844 : end */

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(j) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               j := j + 1;
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
            /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;

            IF num_err <> 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(1) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               errores(2) := verr;
               RETURN num_err;
            END IF;
         /*fin BUG 0026318 -- GGR -- 17/03/2014*/
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_identificador.Error Imprevisto insertando identificador.',
                     SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(152961, SQLERRM);
         errores(j) := verr;
         RETURN 1;
   END f_set_identificador;

   /*************************************************************************
    Nueva funcion que se encarga de modificar un identificador
    return              : 0 Ok. 1 Error
    Bug 20441/101686 - 10/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_mod_identificador(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      errores IN OUT t_ob_error,
      pdefecto IN NUMBER DEFAULT 0,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pcidioma IN idiomas.cidioma%TYPE,
      /* Bug 22263 - 11/07/2012 - ETM*/
      ppaisexp IN NUMBER DEFAULT NULL,
      pcdepartexp IN NUMBER DEFAULT NULL,
      pcciudadexp IN NUMBER DEFAULT NULL,
      pfechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      psup           NUMBER;
      j              NUMBER := 1;
      verr           ob_error;
      wmodcon        NUMBER;
      v_cont         NUMBER;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;  /* Cambios de IAXIS-4844 PK-19/07/2019 */
   BEGIN
      errores := t_ob_error();
      errores.DELETE;
      /* Esta función nos sirve para recuperar el código de agente con el que se ha de grabar.*/
      pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per, ptablas);

      IF ptablas = 'EST' THEN
         /* Bug 22263 - 11/07/2012 - ETM*/
         UPDATE estper_identificador
            SET nnumide = pnnumide,
                swidepri = pdefecto,
                cpaisexp = ppaisexp,
                cdepartexp = pcdepartexp,
                cciudadexp = pcciudadexp,
                fechadexp = pfechaexp
          WHERE sperson = psperson
            AND cagente = vcagente_per
            AND ctipide = pctipide;

         IF pdefecto = 1 THEN
            UPDATE estper_identificador
               SET swidepri = 0
             WHERE sperson = psperson
               AND cagente = vcagente_per
               AND ctipide <> pctipide;
         END IF;
      ELSE
         /* Bug 22263 - 11/07/2012 - ETM*/
         UPDATE per_identificador
            SET nnumide = pnnumide,
                swidepri = pdefecto,
                cpaisexp = ppaisexp,
                cdepartexp = pcdepartexp,
                cciudadexp = pcciudadexp,
                fechadexp = pfechaexp
          WHERE sperson = psperson
            AND cagente = pcagente
            AND ctipide = pctipide;
            
            /* Inicio IAXIS-7629 JRVG 20/02/2020*/
            COMMIT;
            /* Fin IAXIS-7629 JRVG 20/02/2020*/

         IF pdefecto = 1 THEN
            UPDATE per_identificador
               SET swidepri = 0
             WHERE sperson = psperson
               AND cagente = pcagente
               AND ctipide <> pctipide;
         END IF;

         /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'MODIF_PERSONA_HOST'),
                0) = 1
            AND ptablas = 'POL'
            AND pdefecto <> 1 THEN
            num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, SQLERRM);
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* Cambios de IAXIS-4844 : start */
              BEGIN
                SELECT PP.TDIGITOIDE
                  INTO VDIGITOIDE
                  FROM PER_PERSONAS PP
                 WHERE PP.SPERSON = psperson
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(pctipide,
                                                                 UPPER(pnnumide));
              END;
            /* Cambios de IAXIS-4844 : end */

            /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
            v_host := NULL;

            /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
            END IF;

            /* Cambios de IAXIS-4844 : start */
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOIDE,
                                              v_host);
            /* Cambios de IAXIS-4844 : end */

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(j) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               j := j + 1;
               errores(j) := verr;
               RETURN num_err;
            END IF;   /* ini BUG 26318/167380-- GGR -- 17/03/2014*/

            /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;

            IF num_err <> 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(1) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               errores(2) := verr;
               RETURN num_err;
            END IF;
         /*fin BUG 0026318 -- GGR -- 17/03/2014*/
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_mod_identificador.Error Imprevisto modificando identificador.',
                     SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(152961, SQLERRM);
         errores(j) := verr;
         RETURN 1;
   END f_mod_identificador;

   /*Borrar de las tablas estper_ccc*/
   FUNCTION f_del_ident(
      psperson IN estper_identificador.sperson%TYPE,
      pcagente IN estper_identificador.cagente%TYPE,
      pctipide IN estper_identificador.ctipide%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
      v_cont         NUMBER;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
   BEGIN
      SELECT COUNT(1)
        INTO v_cont
        FROM per_identificador pi, per_personas pp
       WHERE pi.sperson = pp.sperson
         AND pi.ctipide = pp.ctipide
         AND pi.ctipide = pctipide
         AND pi.sperson = psperson
         AND pi.swidepri = 1;

      IF v_cont > 0 THEN
         RETURN 9000429;
      ELSE
         BEGIN
            IF ptablas = 'EST' THEN
               /* bug 7873*/
                 /* Esta función nos sirve para recuperar el código de agente con el que se ha de grabar.*/
               pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per,
                                           ptablas);

               /*JRH 04/2008 No hacemos un delete, hacemos un update de la fecha de baja y si se puede por pk.*/
               DELETE      estper_identificador
                     WHERE sperson = psperson
                       AND cagente = vcagente_per
                       AND ctipide = pctipide;
            ELSE
               DELETE      per_identificador
                     WHERE sperson = psperson
                       AND cagente = pcagente
                       AND ctipide = pctipide;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                           'f_del_identificadores.Error Borrando identificadorse', SQLERRM);
               RETURN 806207;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_del_identificadores.Error Borrando identificadorse Fi', SQLERRM);
         RETURN 806207;
   END;

   FUNCTION f_get_cuentapoliza(
      psperson per_personas.sperson%TYPE,
      pcagente agentes.cagente%TYPE,
      pctipban OUT NUMBER,
      pcbancar OUT VARCHAR2,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
      pcbancarsal    VARCHAR2(50);
      a              NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT ctipban, cbancar
           /*substr(cbancar,0,4)||'-'||substr(cbancar,4,4)||'-'||substr(cbancar,8,2)||'-'||substr(cbancar,10,10)*/
         INTO   pctipban, pcbancar
           FROM estccc
          WHERE sperson = psperson
            AND cdefecto = 1;
      ELSE
         SELECT ctipban, cbancar
           /*substr(cbancar,0,4)||'-'||substr(cbancar,4,4)||'-'||substr(cbancar,8,2)||'-'||substr(cbancar,10,10)*/
         INTO   pctipban, pcbancar
           FROM ccc
          WHERE sperson = psperson
            AND cdefecto = 1;
      END IF;

      /*a:=f_formatoccc (  pcbancarsal ,  pcbancar , pctipban );*/
      RETURN a;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_get_CuentaPoliza.Error Imprevisto obteniendo cuenta', SQLERRM);
         RETURN 120130;
   END f_get_cuentapoliza;

   /* DRA 26/09/2008: bug mantis 7567*/
   FUNCTION f_buscaagente(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      ptablas IN VARCHAR2)
      RETURN agentes.cagente%TYPE IS
      vcagente       per_detper.cagente%TYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT cagente
           INTO vcagente
           FROM (SELECT d.cagente
                   FROM estper_detper d
                  WHERE d.cagente = pcagente
                    AND d.sperson = psperson
                 UNION
                 SELECT d.cagente
                   FROM estper_detper d
                  WHERE d.cagente != pcagente
                    AND d.sperson = psperson
                    AND NOT EXISTS(SELECT 1
                                     FROM estper_detper dd
                                    WHERE sperson = psperson
                                      AND dd.cagente = pcagente)
                    AND d.fmovimi = (SELECT MAX(fmovimi)   /*bug 24822*/
                                       FROM estper_detper dd, agentes_agente aa2
                                      WHERE dd.sperson = d.sperson
                                        AND dd.cagente = aa2.cagente));                                                                /* Bug 24822*/
                                                                          /*                    AND d.fmovimi =*/
                                                                          /*                          (SELECT MAX(fmovimi)*/
                                                                          /*                             FROM estper_detper dd*/
                                                                          /*                            WHERE dd.sperson = d.sperson*/
                                                                          /*                              AND dd.cagente IN(SELECT     r.cagente*/
                                                                          /*                                                      FROM redcomercial r*/
                                                                          /*                                                     WHERE fmovfin IS NULL*/
                                                                          /*                                                       AND LEVEL =*/
                                                                          /*                                                             DECODE*/
                                                                          /*                                                                (ff_agente_cpernivel(pcagente),*/
                                                                          /*                                                                 1, LEVEL,*/
                                                                          /*                                                                 1)*/
                                                                          /*                                                START WITH cagente =*/
                                                                          /*                                                                  ff_agente_cpervisio(pcagente)*/
                                                                          /*                                                CONNECT BY PRIOR cagente = cpadre*/
                                                                          /*                                                       AND PRIOR fmovfin IS NULL))*/
                                                                          /*                    --Si hay mas de un detalle cogemos el más nuevo*/
                                                                          /*                    AND d.cagente IN(SELECT     r.cagente*/
                                                                          /*                                           FROM redcomercial r*/
                                                                          /*                                          WHERE fmovfin IS NULL*/
                                                                          /*                                            AND LEVEL =*/
                                                                          /*                                                  DECODE(ff_agente_cpernivel(pcagente),*/
                                                                          /*                                                         1, LEVEL,*/
                                                                          /*                                                         1)*/
                                                                          /*                                     START WITH cagente = ff_agente_cpervisio(pcagente)*/
                                                                          /*                                     CONNECT BY PRIOR cagente = cpadre*/
                                                                          /*                                            AND PRIOR fmovfin IS NULL));*/
      ELSE
         SELECT cagente
           INTO vcagente
           FROM (SELECT d.cagente
                   FROM per_detper d
                  WHERE d.cagente = pcagente
                    AND d.sperson = psperson
                 UNION
                 SELECT d.cagente
                   FROM per_detper d
                  WHERE d.cagente != pcagente
                    AND d.sperson = psperson
                    AND NOT EXISTS(SELECT 1
                                     FROM per_detper dd
                                    WHERE sperson = psperson
                                      AND dd.cagente = pcagente)
                    AND d.fmovimi = (SELECT MAX(fmovimi)   /*bug 24822*/
                                       FROM per_detper dd, agentes_agente aa2
                                      WHERE dd.sperson = d.sperson
                                        AND dd.cagente = aa2.cagente));                                                                /* Bug 24822*/
                                                                          /*                    AND d.fmovimi =*/
                                                                          /*                          (SELECT MAX(fmovimi)*/
                                                                          /*                             FROM per_detper dd*/
                                                                          /*                            WHERE dd.sperson = d.sperson*/
                                                                          /*                              AND dd.cagente IN(SELECT     r.cagente*/
                                                                          /*                                                      FROM redcomercial r*/
                                                                          /*                                                     WHERE fmovfin IS NULL*/
                                                                          /*                                                       AND LEVEL =*/
                                                                          /*                                                             DECODE*/
                                                                          /*                                                                (ff_agente_cpernivel(pcagente),*/
                                                                          /*                                                                 1, LEVEL,*/
                                                                          /*                                                                 1)*/
                                                                          /*                                                START WITH cagente =*/
                                                                          /*                                                                  ff_agente_cpervisio(pcagente)*/
                                                                          /*                                                CONNECT BY PRIOR cagente = cpadre*/
                                                                          /*                                                       AND PRIOR fmovfin IS NULL))*/
                                                                          /*                    --Si hay mas de un detalle cogemos el más nuevo*/
                                                                          /*                    AND d.cagente IN(SELECT     r.cagente*/
                                                                          /*                                           FROM redcomercial r*/
                                                                          /*                                          WHERE fmovfin IS NULL*/
                                                                          /*                                            AND LEVEL =*/
                                                                          /*                                                  DECODE(ff_agente_cpernivel(pcagente),*/
                                                                          /*                                                         1, LEVEL,*/
                                                                          /*                                                         1)*/
                                                                          /*                                     START WITH cagente = ff_agente_cpervisio(pcagente)*/
                                                                          /*                                     CONNECT BY PRIOR cagente = cpadre*/
                                                                          /*                                            AND PRIOR fmovfin IS NULL));*/
      END IF;

      RETURN vcagente;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_buscaagente', 1,
                     'Error Imprevisto obteniendo el agente', SQLERRM);
         RETURN NULL;
   END f_buscaagente;

   /*************************************************************************
   Traspasa a las EST las cuentas banacarias de una persona
   param in: psperson real , pficticia_sperson, persona de la tabla est
   *************************************************************************/
   PROCEDURE traspaso_ccc(
      psperson IN per_personas.sperson%TYPE,
      pficticia_sperson IN estper_personas.sperson%TYPE,
      pcagente IN estper_ccc.cagente%TYPE) IS
      vspereal       estper_personas.spereal%TYPE;
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         SELECT spereal
           INTO vspereal
           FROM estper_personas
          WHERE sperson = pficticia_sperson;
      END IF;

      DELETE FROM estper_ccc
            WHERE sperson = pficticia_sperson;

      pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per, 'POL');

      INSERT INTO estper_ccc
                  (sperson, cagente, ctipban, cbancar, fbaja, cdefecto, cusumov, fusumov,
                   cnordban /* Bug 20790 - APD - 03/01/2012 - valdia la ccc*/, cvalida,
                   cpagsin, fvencim, tseguri, falta, cusualta)
         (SELECT pficticia_sperson, vcagente_per, ctipban, cbancar, fbaja, cdefecto, cusumov,
                 fusumov, cnordban /* Bug 20790 - APD - 03/01/2012 - valdia la ccc*/, cvalida,
                 cpagsin, fvencim, tseguri, falta, cusualta
            FROM per_ccc
           WHERE sperson = NVL(psperson, vspereal)
             AND cagente = vcagente_visio /* bug 7873 solo ha de recuperar las que puede ver.*/);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, NVL(f_user, f_user), 'PAC_PERSONA', 1,
                     'traspaso_ccc . Error WHEN OTHERS.  SPERSON = ' || psperson, SQLERRM);
   END traspaso_ccc;

   /* DRA 3-10-2008: bug mantis 6352*/
   FUNCTION f_existe_direccion(
      psperson IN per_direcciones.sperson%TYPE,
      pcagente IN per_direcciones.cagente%TYPE,
      pctipdir IN per_direcciones.ctipdir%TYPE,
      pcsiglas IN per_direcciones.csiglas%TYPE,
      ptnomvia IN per_direcciones.tnomvia%TYPE,
      pnnumvia IN per_direcciones.nnumvia%TYPE,
      ptcomple IN per_direcciones.tcomple%TYPE,
      ptdomici IN per_direcciones.tdomici%TYPE,
      pcpostal IN per_direcciones.cpostal%TYPE,
      pcpoblac IN per_direcciones.cpoblac%TYPE,
      pcprovin IN per_direcciones.cprovin%TYPE)
      RETURN per_direcciones.cdomici%TYPE IS
      vcdomici       per_direcciones.cdomici%TYPE;
   BEGIN
      SELECT cdomici
        INTO vcdomici
        FROM per_direcciones
       WHERE sperson = psperson
         AND cagente = pcagente
         AND ctipdir = pctipdir
         AND NVL(csiglas, -1) = NVL(pcsiglas, -1)
         AND NVL(tnomvia, '-1') = NVL(ptnomvia, '-1')
         AND NVL(nnumvia, -1) = NVL(pnnumvia, -1)
         AND NVL(tcomple, '-1') = NVL(ptcomple, '-1')
         AND NVL(tdomici, '-1') = NVL(ptdomici, '-1')
         AND NVL(cpostal, '-1') = NVL(UPPER(pcpostal), '-1')
         /* BUG14307:DRA:18/05/2010*/
         AND NVL(cpoblac, -1) = NVL(pcpoblac, -1)
         AND NVL(cprovin, -1) = NVL(pcprovin, -1);

      RETURN vcdomici;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         /* Si no encuentra datos, debe retornar NULL*/
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_existe_direccion . Error WHEN OTHERS.  SPERSON = ' || psperson,
                     SQLERRM);
         RETURN NULL;
   END f_existe_direccion;

   /* DRA 3-10-2008: bug mantis 6352*/
   FUNCTION f_existe_ccc(
      psperson IN per_ccc.sperson%TYPE,
      pcagente IN per_ccc.cagente%TYPE,
      pctipban IN per_ccc.ctipban%TYPE,
      pcbancar IN per_ccc.cbancar%TYPE)
      RETURN per_ccc.cnordban%TYPE IS
      vcnordban      per_ccc.cnordban%TYPE;
   BEGIN
      SELECT cnordban
        INTO vcnordban
        FROM per_ccc
       WHERE sperson = psperson
         AND cagente = pcagente
         AND ctipban = pctipban
         AND cbancar = pcbancar
         AND fbaja IS NULL
         AND ROWNUM = 1;

      RETURN vcnordban;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         /* Si no encuentra datos, debe retornar NULL*/
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_existe_ccc . Error WHEN OTHERS.  SPERSON = ' || psperson, SQLERRM);
         RETURN NULL;
   END f_existe_ccc;

   /* DRA 3-10-2008: bug mantis 6352*/
   FUNCTION f_existe_contacto(
      psperson IN per_contactos.sperson%TYPE,
      pcagente IN per_contactos.cagente%TYPE,
      pctipcon IN per_contactos.ctipcon%TYPE,
      ptcomcon IN per_contactos.tcomcon%TYPE,
      ptvalcon IN per_contactos.tvalcon%TYPE,
      pcdomici IN per_contactos.cdomici%TYPE,
      pcprefix IN per_contactos.cprefix%TYPE)   /*etm 24806*/
      RETURN per_contactos.cmodcon%TYPE IS
      vcmodcon       per_contactos.cmodcon%TYPE;
   BEGIN
      SELECT cmodcon
        INTO vcmodcon
        FROM per_contactos
       WHERE sperson = psperson
         AND cagente = pcagente
         AND NVL(ctipcon, -1) = NVL(pctipcon, -1)
         AND NVL(tcomcon, '-1') = NVL(ptcomcon, '-1')
         AND NVL(tvalcon, '-1') = NVL(ptvalcon, '-1')
         AND NVL(cdomici, -1) = NVL(pcdomici, -1)
         AND NVL(cprefix, -1) = NVL(pcprefix, -1);   /*etm 24806*/

      RETURN vcmodcon;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         /* Si no encuentra datos, debe retornar NULL*/
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_existe_contacto . Error WHEN OTHERS.  SPERSON = ' || psperson,
                     SQLERRM);
         RETURN NULL;
   END f_existe_contacto;

   /* ini jtg*/
   FUNCTION f_persona_origen_int(psperson IN estper_personas.sperson%TYPE)
      RETURN NUMBER IS
      v_count        NUMBER(1);
   BEGIN
      SELECT COUNT(1)
        INTO v_count
        FROM estper_personas
       WHERE sperson = psperson
         AND corigen = 'INT';

      IF v_count = 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   END f_persona_origen_int;

   FUNCTION f_get_persona_trecibido(psperson IN estper_personas.sperson%TYPE)
      RETURN VARCHAR2 IS
      vtrecibido     estper_personas.trecibido%TYPE;
   BEGIN
      BEGIN
         SELECT trecibido
           INTO vtrecibido
           FROM estper_personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vtrecibido := NULL;
         WHEN TOO_MANY_ROWS THEN
            vtrecibido := NULL;
      END;

      RETURN vtrecibido;
   END f_get_persona_trecibido;

   FUNCTION f_direccion_origen_int(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE)
      RETURN NUMBER IS
      v_count        NUMBER(1);
   BEGIN
      SELECT COUNT(1)
        INTO v_count
        FROM estper_direcciones
       WHERE sperson = psperson
         AND cdomici = pcdomici
         AND corigen = 'INT';

      IF v_count = 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   END f_direccion_origen_int;

   FUNCTION f_get_direccion_trecibido(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE)
      RETURN VARCHAR2 IS
      vtrecibido     estper_direcciones.trecibido%TYPE;
   BEGIN
      BEGIN
         SELECT trecibido
           INTO vtrecibido
           FROM estper_direcciones
          WHERE sperson = psperson
            AND cdomici = pcdomici;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vtrecibido := NULL;
         WHEN TOO_MANY_ROWS THEN
            vtrecibido := NULL;
      END;

      RETURN vtrecibido;
   END f_get_direccion_trecibido;

   FUNCTION f_validanif(
      pnnumide IN per_personas.nnumide%TYPE,
      pctipide IN per_personas.ctipide%TYPE,
      csexper IN per_personas.csexper%TYPE,
      fnacimi IN per_personas.fnacimi%TYPE)
      RETURN NUMBER IS
      vnnumide       per_personas.nnumide%TYPE;
      vnum_err       NUMBER := 0;
   BEGIN
      IF pctipide IN(1, 2, 4) THEN
         /* Bug 7873-- Svj solo se validan los tipos de documento nif, cif.*/
         vnnumide := pnnumide;
         vnum_err := f_nif(pctipide, vnnumide);
      /* Bug 23417/123957 - 18/10/2012 - AMC*/
      ELSIF pctipide = 10 THEN
         /* BUG14307:DRA:11/05/2010:Inici: Validació del NUM. CASS*/
         vnum_err := f_valida_cass(pnnumide);
      /* BUG14307:DRA:11/05/2010:Fi*/
      ELSIF pctipide = 15 THEN
         /*BUG8718-22/01/2009-JTS-Comprobación de documentos Belgas.*/
         vnum_err := f_validar_nrn(pnnumide, fnacimi, csexper);
      /* 15039 16-06-2010 JMC Se añade    Validació Menor Angola (26)*/
      /* 14055 31-05-2010 JMC Se añade    Validació NIF Angola (25)*/
      /* 14467 13-05-2010 AVT Validació NIF Angola*/
      ELSIF pctipide >= 16
            AND pctipide <= 26 THEN
         vnum_err := pac_ide_persona.f_validar_nif_ang(pctipide, pnnumide);
      ELSIF pctipide = 28 THEN
         /* BUG 0019426 - 13-09-2011 - JMF : Validación nif Portugal*/
         vnum_err := pac_ide_persona.f_validar_nif_por(pctipide, pnnumide);
      ELSIF (pctipide >= 33
             AND pctipide <= 40)
            /*Añadimos NIT persona natural*/
            OR pctipide IN(44, 45, 93) THEN    -- CP0036M_SYS_PERS - ACL- 30/11/2018
         /* BUG 19587 - 21-11-2011 - APD : Validación nif Colombiano*/
         vnum_err := pac_ide_persona.f_validar_nif_col(pctipide, pnnumide, csexper);
      ELSIF pctipide = 3 THEN
         NULL;
      /*Si es pasaporte no validamos nada hasta que no se investigue el correcto algoritmo*/
      /* Bug 24780 - ETM - 11/12/2012*/
      ELSIF pctipide = 41 THEN
         vnum_err := pac_ide_persona.f_validar_nif_chile(pctipide, pnnumide);
      /*SI ES SWRUT cv*/
      /* Bug 24780 - ETM - 11/12/2012*/
      /* BUG 0026968/0147424 - FAL - 27/06/2013*/
      ELSIF pctipide = 42 THEN
         vnum_err := pac_ide_persona.f_validar_nif_chile_jurid(pctipide, pnnumide);
      /* FI BUG 0026968/0147424*/
      ELSIF(pctipide >= 51
            AND pctipide <= 56) THEN
         /* BUG 38922/220090*/
         vnum_err := pac_ide_persona.f_validar_nif_malta(pctipide, pnnumide);
/*----ECUADOR-----------------------------*/
      ELSIF pctipide >= 63
            AND pctipide <= 66 THEN
         vnum_err := pac_ide_persona.f_validar_nif_ecu(pctipide, pnnumide);
/*----ECUADOR-----------------------------*/
-- INI CONF-564 Se agrega validación ctipide = 96 -- ACL - 15/12/2017
/*----COLOMBIA-----------------------------*/
     ELSIF pctipide = 96 THEN
         vnum_err := pac_ide_persona.f_validar_nif_col(pctipide, pnnumide, csexper);
-- FIN CONF-564 Se agrega validación ctipide = 96 -- ACL - 15/12/2017
      END IF;

      RETURN vnum_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_validaNif, Error =' || pnnumide || ' pctipide' || pctipide, SQLERRM);
   END f_validanif;

   /* fin jtg*/
   /*Bug 29166/160004 - 29/11/2013 - AMC*/
   /*
   PROCEDURE p_busca_agentes(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcagente_visio OUT agentes.cagente%TYPE,
      pcagente_per OUT agentes.cagente%TYPE,
      ptablas IN VARCHAR2) IS
      vswpubli       NUMBER;
   BEGIN
      pcagente_visio := pac_persona.f_buscaagente(psperson, NVL(pcagente, ff_agenteprod()),
                                                  ptablas);
      pcagente_per := ff_agente_cpervisio(NVL(pcagente, ff_agenteprod()));

      -- BUG17255:DRA:22/07/2011:Inici
      IF ptablas = 'EST' THEN
         SELECT swpubli
           INTO vswpubli
           FROM estper_personas
          WHERE sperson = psperson;

         --XPL mirem si la persona és pública, si és pública només pot tenir un detall.
         -- per tant creem el registre amb aquest agent.
         IF vswpubli IS NOT NULL
            AND vswpubli = 1 THEN
            BEGIN
               SELECT cagente
                 INTO pcagente_per
                 FROM estper_detper
                WHERE sperson = psperson;
            EXCEPTION
               WHEN OTHERS THEN
                  pcagente_per := ff_agente_cpervisio(NVL(pcagente, ff_agenteprod()));
                  p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                              'Buscando agente de la persona publica p_busca_agentes',
                              SQLERRM);
            END;
         END IF;
      ELSE
         SELECT swpubli
           INTO vswpubli
           FROM per_personas
          WHERE sperson = psperson;

         --XPL mirem si la persona és pública, si és pública només pot tenir un detall.
         -- per tant creem el registre amb aquest agent.
         IF vswpubli IS NOT NULL
            AND vswpubli = 1 THEN
            BEGIN
               SELECT cagente
                 INTO pcagente_per
                 FROM per_detper
                WHERE sperson = psperson;
            EXCEPTION
               WHEN OTHERS THEN
                  pcagente_per := ff_agente_cpervisio(NVL(pcagente, ff_agenteprod()));
                  p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 2,
                              'Buscando agente de la persona publica p_busca_agentes',
                              SQLERRM);
            END;
         END IF;
      END IF;
   -- BUG17255:DRA:22/07/2011:Fi
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'p_busca_agentes, Error. psperson =' || psperson || ' pcagente='
                     || pcagente,
                     SQLERRM);
   END p_busca_agentes;*/
   /*Bug 29166/160004 - 29/11/2013 - AMC*/
   --
   /*
   Procedure p_paga_oz_iax procedimiento Oziris Iaxis pagador alternativo
     sperson  in number   numero de persona principal
     sperson_rel in number Numero del pagador alternativo
     IAXIS-2091 TCS 1560 Convivencia pagador Alternativo
   */
   PROCEDURE p_paga_oz_iax (
      psperson     IN per_pagador_alt.sperson%TYPE,
      psperson_rel IN per_pagador_alt.sperson_rel%TYPE) IS
      --
      nerror  NUMBER;
      --
   BEGIN
      --
      nerror := pac_persona.f_pagador_alt(psperson,psperson_rel,3,1);
      IF nerror <> 0 THEN
         --
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'p_paga_oz_iax, Error. psperson =' || psperson || ' psperson_rel='
                     || psperson_rel,
                     SQLERRM);
         --
      END IF;
      --
   END p_paga_oz_iax;
  --
   PROCEDURE p_busca_agentes(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcagente_visio OUT agentes.cagente%TYPE,
      pcagente_per OUT agentes.cagente%TYPE,
      ptablas IN VARCHAR2) IS
      vswpubli       NUMBER;
   BEGIN
      pcagente_visio := pac_persona.f_buscaagente(psperson, NVL(pcagente, ff_agenteprod()),
                                                  ptablas);
      pcagente_per := ff_agente_cpervisio(NVL(pcagente, ff_agenteprod()));

      IF ptablas != 'EST' THEN
         SELECT swpubli, DECODE(swpubli, 1, cagente, pcagente_per)
           INTO vswpubli, pcagente_per
           FROM per_personas
          WHERE sperson = psperson;
      ELSE
         SELECT swpubli, DECODE(swpubli, 1, cagente, pcagente_per)
           INTO vswpubli, pcagente_per
           FROM estper_personas
          WHERE sperson = psperson;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'p_busca_agentes, Error. psperson =' || psperson || ' pcagente='
                     || pcagente,
                     SQLERRM);
   END p_busca_agentes;

   FUNCTION f_get_datosper_axis(
      psip IN VARCHAR2,
      pfnacimi OUT DATE,
      ptdocidentif OUT VARCHAR2,
      psexo OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT fnacimi, nnumide, csexper
        INTO pfnacimi, ptdocidentif, psexo
        FROM per_personas
       WHERE snip = psip;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 2;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_get_datosper_axis, Error. psip =' || psip, SQLERRM);
         RETURN 1;
   END f_get_datosper_axis;

   /* ACC 15122008*/
   /* Comprova que la direcció d'un no estigui donada d'alta en un altre*/
   FUNCTION f_valida_misma_direccion(
      psperson1 IN NUMBER,
      pcdomici1 IN NUMBER,
      psperson2 IN NUMBER,
      pcdomici2 OUT NUMBER)
      RETURN NUMBER IS
/*-----------------------------------------------------------------------------------*/
/* Función que valida sí la dirección del asegurado 1 ya está dada de alta entre las direcciones del asegurado 2*/
/* Si la dirección no existe --> pcdomici2 = NULL*/
/* Si la dirección ya existe --> pcdomici2 = Nº de cdomici del asegurado 2*/
/**/
/* La función devuelve:*/
/*                 0 - Si todo OK*/
/*      codigo error - Si ha habido algún error*/
/*-----------------------------------------------------------------------------------*/
   BEGIN
      IF psperson1 IS NULL THEN
         RETURN 111066;   /* Es obligatorio informar la persona*/
      END IF;

      IF psperson2 IS NULL THEN
         RETURN 111066;   /* Es obligatorio informar la persona*/
      END IF;

      IF pcdomici1 IS NULL THEN
         RETURN 101290;   /* Falta la dirección del tomador*/
      END IF;

      /* Si no existe la dirección, entonces pcdomici2 valdrá null*/
      /* Si sí existe la dirección, entonces pcdomici2 valdrá el código del cdomici del aseguro 2*/
      /* para la misma dirección que el asegurado 1*/
      SELECT dir2.cdomici
        INTO pcdomici2
        FROM direcciones dir1, direcciones dir2
       WHERE dir1.tdomici = dir2.tdomici
         AND dir1.cpostal = dir2.cpostal
         AND dir1.cprovin = dir2.cprovin
         AND dir1.cpoblac = dir2.cpoblac
         AND dir1.csiglas = dir2.csiglas
         AND dir1.tnomvia = dir2.tnomvia
         AND dir1.nnumvia = dir2.nnumvia
         AND dir1.tcomple = dir2.tcomple
         AND dir1.sperson = psperson1
         AND dir1.cdomici = pcdomici1
         AND dir2.sperson = psperson2;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pcdomici2 := NULL;
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'PAC_PERSONAS.F_VALIDA_MISMA_DIRECCION', NULL,
                     'psperson1 = ' || psperson1 || ' pcdomici1 = ' || pcdomici1
                     || ' psperson2 = ' || psperson2,
                     SQLERRM);
         RETURN 104474;   /* Error al leer de la tabla DIRECCIONES*/
   END f_valida_misma_direccion;

   /* dra 9-1-08: bug mantis 8660 (funció sobrecarregada)*/
   /* Bug 29015 - 30-XII-2013 - dlF - AGM800 - Moldeo oficial 346*/
   /* trim de algunas columnas, para que se correspondan con la*/
   /* declaracion de la vista PERSONAS.*/
   FUNCTION f_get_dadespersona(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      persona OUT personas%ROWTYPE)
      RETURN NUMBER IS
      CURSOR c_per IS
         SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
                per.cestper, per.fjubila, per.ctipper, per.cusuari, per.fmovimi,
                per.cmutualista, per.fdefunc, per.snip, d.cagente, ff_agenteprod
                                                                                ()
                                                                                  cagenteprod,
                d.cidioma, d.tapelli1, d.tapelli2, d.tapelli1 || ' ' || d.tapelli2 tapelli,
                d.tnombre, d.tsiglas, d.cprofes, d.tbuscar, d.cestciv, d.cpais, c.cbancar,
                c.ctipban, per.swpubli, per.nnumide nnumnif, per.ctipide cpertip,
                per.nordide nnifdup, per.nordide nnifrep, per.cestper cestado,
                per.fmovimi finform, NULL nempleado, NULL nnumsoe, NULL tnomtot, NULL tperobs,
                NULL cnifrep, NULL pdtoint, NULL ccargos, NULL tpermis, NULL producte,
                NULL nsocio, NULL nhijos, NULL claboral, NULL cvip, NULL spercon,
                NULL fantigue, NULL ctrato, NULL num_contra,
                d.cocupacion   /* Bug 25456/133727 - 16/01/2013 - AMC*/
           FROM per_personas per, per_detper d, per_ccc c
          WHERE per.sperson = psperson
            AND d.sperson = per.sperson
            AND c.sperson(+) = d.sperson
            AND c.cagente(+) = d.cagente
            AND c.cdefecto(+) = 1   /* cuenta bacaria por defecto*/
            AND per.swpubli = 1
            AND per.cagente = d.cagente                                /*Bug 29166/160004 - 29/11/2013 - AMC*/
                                          /* La persona es pública y la puede ver todo el mundo*/
         UNION ALL
         SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
                per.cestper, per.fjubila, per.ctipper, per.cusuari, per.fmovimi,
                per.cmutualista, per.fdefunc, per.snip, d.cagente, ff_agenteprod
                                                                                () cagenteprod,
                d.cidioma, d.tapelli1, d.tapelli2, d.tapelli1 || ' ' || d.tapelli2 tapelli,
                d.tnombre tnombre, d.tsiglas tsiglas, d.cprofes, d.tbuscar, d.cestciv, d.cpais,
                c.cbancar, c.ctipban, per.swpubli, per.nnumide nnumnif, per.ctipide cpertip,
                per.nordide nnifdup, per.nordide nnifrep, per.cestper cestado,
                per.fmovimi finform, NULL nempleado, NULL nnumsoe, NULL tnomtot, NULL tperobs,
                NULL cnifrep, NULL pdtoint, NULL ccargos, NULL tpermis, NULL producte,
                NULL nsocio, NULL nhijos, NULL claboral, NULL cvip, NULL spercon,
                NULL fantigue, NULL ctrato, NULL num_contra,
                d.cocupacion   /* Bug 25456/133727 - 16/01/2013 - AMC*/
           FROM per_personas per, per_detper d, per_ccc c
          WHERE per.sperson = psperson
            AND d.sperson = per.sperson
            AND d.cagente = ff_agente_cpervisio(pcagente)
            AND c.sperson(+) = d.sperson
            AND c.cagente(+) = d.cagente
            AND c.cdefecto(+) = 1   /* cuenta bacaria por defecto*/
            AND per.swpubli = 0;
   /* fin Bug 29015 - 30-XII-2013 - dlF -*/
   BEGIN
      OPEN c_per;

      FETCH c_per
       INTO persona.sperson, persona.nnumide, persona.nordide, persona.ctipide,
            persona.csexper, persona.fnacimi, persona.cestper, persona.fjubila,
            persona.ctipper, persona.cusuari, persona.fmovimi, persona.cmutualista,
            persona.fdefunc, persona.snip, persona.cagente, persona.cagenteprod,
            persona.cidioma, persona.tapelli1, persona.tapelli2, persona.tapelli,
            persona.tnombre, persona.tsiglas, persona.cprofes, persona.tbuscar,
            persona.cestciv, persona.cpais, persona.cbancar, persona.ctipban, persona.swpubli,
            persona.nnumnif, persona.cpertip, persona.nnifdup, persona.nnifrep,
            persona.cestado, persona.finform, persona.nempleado, persona.nnumsoe,
            persona.tnomtot, persona.tperobs, persona.cnifrep, persona.pdtoint,
            persona.ccargos, persona.tpermis, persona.producte, persona.nsocio,
            persona.nhijos, persona.claboral, persona.cvip, persona.spercon, persona.fantigue,
            persona.ctrato, persona.num_contra, persona.cocupacion;   /* Bug 25456/133727 - 16/01/2013 - AMC*/

      CLOSE c_per;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         /* BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos*/
         IF c_per%ISOPEN THEN
            CLOSE c_per;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_get_dadespersona, Error. psperson =' || psperson || ', cagente ='
                     || pcagente,
                     SQLERRM);
         RETURN 1;
   END f_get_dadespersona;

   /*************************************************************************
          Nueva función que servirá para modificar los datos básicos de una persona
   *************************************************************************/
   FUNCTION f_set_basicos_persona(
      psperson IN per_personas.sperson%TYPE,
      pctipper IN per_personas.ctipper%TYPE,
      pctipide IN per_personas.ctipide%TYPE,
      pnnumide IN per_personas.nnumide%TYPE,
      pcsexper IN per_personas.csexper%TYPE,
      pfnacimi IN per_personas.fnacimi%TYPE,
      pswpubli IN per_personas.swpubli%TYPE,
      ptablas IN VARCHAR2,
      pswrut IN NUMBER,
      pcpreaviso IN per_personas.cpreaviso%TYPE,
      perrores OUT t_ob_error)   /* BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA*/
      RETURN NUMBER IS
      existe         NUMBER;
      vnumerror      NUMBER;
      vnnumide       per_personas.nnumide%TYPE;
      vnnumide_ant   per_personas.nnumide%TYPE;
      vctipide_ant   per_personas.ctipide%TYPE;
      vctipper_ant   per_personas.ctipper%TYPE;
      vmodiswpubli   NUMBER;
      vnomodificable NUMBER;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      vdigitoide     VARCHAR2(1);
      vdigitoide2    VARCHAR(1);
      verr           ob_error;
      sw_envio_rut   NUMBER(1);
      v_publi        NUMBER(10) := 0;
      ss             VARCHAR2(3000);
      v_propio       VARCHAR2(500);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      retorno        VARCHAR2(1);
      wnnumide       per_personas.nnumide%TYPE;
      /* BUG 26968/0155105 - FAL - 15/10/2013*/
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
      vpas           NUMBER;
      VDIGITOID      PER_PERSONAS.TDIGITOIDE%TYPE; /* Cambios de IAXIS-4844 PK-19/07/2019 */
      /* Cambios de IAXIS-13006 : start */
      V_NOMBREPARACOMPL VARCHAR2(2000);
      /* Cambios de IAXIS-13006 : end */  	  
   BEGIN
      vpas := 1;
      perrores := t_ob_error();
      perrores.DELETE;
      wnnumide := f_desformat_nif(pnnumide, pctipide);

      /* BUG 26968/0155105 - FAL - 15/10/2013*/
      SELECT SUM(existeix)
        INTO existe
        FROM (SELECT COUNT(1) existeix
                FROM per_personas
               WHERE nnumide = wnnumide
                 AND csexper = pcsexper
                 AND ctipide = pctipide
                 AND fnacimi = pfnacimi
                 AND ctipper = 1
                 AND sperson != psperson
              UNION
              SELECT COUNT(1) existeix
                FROM per_personas
               WHERE nnumide = wnnumide
                 AND ctipide = pctipide
                 AND ctipper = 2
                 AND sperson != psperson);

      vpas := 2;

      IF existe > 0 THEN
         /* bug 20850/103100 - 11/01/2012 - AMC*/
         SELECT nnumide, ctipide, ctipper
           INTO vnnumide_ant, vctipide_ant, vctipper_ant
           FROM (SELECT nnumide, ctipide, ctipper
                   FROM per_personas
                  WHERE nnumide = wnnumide
                    AND csexper = pcsexper
                    AND ctipide = pctipide
                    AND fnacimi = pfnacimi
                    AND ctipper = 1
                    AND sperson != psperson
                 UNION
                 SELECT nnumide, ctipide, ctipper
                   FROM per_personas
                  WHERE nnumide = wnnumide
                    AND ctipide = pctipide
                    AND ctipper = 2
                    AND sperson != psperson);

         vpas := 3;

         IF vnnumide_ant != wnnumide
            OR vctipide_ant != pctipide
            OR vctipper_ant != pctipper THEN
            RETURN 9000778;
         END IF;
      END IF;

      IF pfnacimi IS NOT NULL AND pctipper != 2 THEN
         IF TRUNC(pfnacimi) > TRUNC(f_sysdate) THEN
            /*La Fecha de nacimiento no puede ser superior a la fecha de hoy.*/
            RETURN 120058;
         END IF;
      END IF;

      vpas := 4;

      /* Fi bug 20850/103100 - 11/01/2012 - AMC*/
      IF pctipide = 0
         AND wnnumide IS NULL THEN
         vnumerror := f_snnumnif('Z', vnnumide);
      ELSIF pctipide = 96
            AND wnnumide IS NULL THEN
         vnumerror := f_snnumnif('4', vnnumide);
      ELSE
         vnnumide := wnnumide;
      END IF;

      vpas := 5;

      SELECT COUNT(1)
        INTO vmodiswpubli
        FROM per_personas
       WHERE sperson = psperson
         AND swpubli = pswpubli;

      IF vmodiswpubli = 0 THEN
         SELECT COUNT(1)
           INTO vnomodificable
           FROM v_personas_seguros
          WHERE sperson = psperson;

         IF vnomodificable > 0 THEN
            IF pswpubli = 0 THEN
               RETURN 9000807;   /*publica a privada*/
            ELSE
               RETURN 9000806;   /*privada a  publica*/
            END IF;
         END IF;
      END IF;

      vpas := 6;

      IF pswrut = 1 THEN
         /* Bug 24780 - ETM - 11/12/2012*/
         BEGIN
            SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'PAC_IDE_PERSONA')
              INTO v_propio
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
               v_propio := NULL;
         END;

         vpas := 7;

         IF v_propio IS NOT NULL THEN
            --Bug 42689/237758 - 24/05/2016 - AMC
            ss := 'BEGIN ' || ' :RETORNO := PAC_IDE_PERSONA.' || v_propio || '(' || pctipide
                  || ', upper(''' || wnnumide || '''))' || ';' || 'END;';

            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
            DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno, 20);
            v_filas := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            vdigitoide := retorno;

            /*fin bug 24780 - ETM - 11/12/2012*/
            /*IF pswrut = 1 THEN
                vdigitoide := pac_ide_persona.f_digito_nif_col(pctipide, UPPER(pnnumide));*/
            /* BUG 21270/106644 - 08/02/2012 - JMP - Comprobamos si es la primera vez que se informa el TDIGITOIDE*/
            IF ptablas = 'POL' THEN
               BEGIN
                  SELECT DECODE(tdigitoide, NULL, 1, 0)
                    INTO sw_envio_rut
                    FROM per_personas
                   WHERE sperson = psperson;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     sw_envio_rut := 1;
               END;
            END IF;
         /* FIN BUG 21270/106644 - 08/02/2012 - JMP - Comprobamos si es la primera vez que se informa el TDIGITOIDE*/
         END IF;
      /* BUG 26968/0155105 - FAL - 15/10/2013*/
      ELSE
         vpas := 8;

         BEGIN
            SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'PAC_IDE_PERSONA')
              INTO v_propio
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
               v_propio := NULL;
         END;

         IF v_propio IS NOT NULL THEN
            --Bug 42689/237758 - 24/05/2016 - AMC
            ss := 'BEGIN ' || ' :RETORNO := PAC_IDE_PERSONA.' || v_propio || '(' || pctipide
                  || ', upper(''' || wnnumide || '''))' || ';' || 'END;';

            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
            DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno, 20);
            v_filas := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            vdigitoide2 := retorno;
         END IF;

         IF ptablas = 'POL' THEN
            BEGIN
               SELECT tdigitoide
                 INTO vdigitoide
                 FROM per_personas
                WHERE sperson = psperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vdigitoide := NULL;
            END;
         ELSIF ptablas = 'EST' THEN
            BEGIN
               SELECT tdigitoide
                 INTO vdigitoide
                 FROM estper_personas
                WHERE sperson = psperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vdigitoide := NULL;
            END;
         END IF;

         IF vdigitoide != vdigitoide2 THEN
            vdigitoide := vdigitoide2;
         END IF;
      /* FI BUG 26968/0155105 - FAL - 15/10/2013*/
      END IF;

      vpas := 9;

      /* Bug 22355- 23/05/2012 - ETM*/
      /* Bug 27314/182070 - 20/08/2014 - GGR*/
      BEGIN
         SELECT sperson
           INTO v_publi
           FROM empresas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            v_publi := psperson;
         WHEN NO_DATA_FOUND THEN
            BEGIN
               vpas := 10;

               SELECT sperson
                 INTO v_publi
                 FROM companias
                WHERE sperson = psperson;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  v_publi := psperson;
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     vpas := 11;

                     SELECT sperson
                       INTO v_publi
                       FROM profesionales
                      WHERE sperson = psperson;
                  EXCEPTION
                     WHEN TOO_MANY_ROWS THEN
                        v_publi := psperson;
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           vpas := 12;

                           SELECT sperson
                             INTO v_publi
                             FROM agentes
                            WHERE sperson = psperson;
                        EXCEPTION
                           WHEN TOO_MANY_ROWS THEN
                              v_publi := psperson;
                           WHEN NO_DATA_FOUND THEN
                              v_publi := 0;
                        END;
                  END;
            END;
      END;

      vpas := 13;

      /* Fin Bug 27314/182070 - 20/08/2014 - GGR*/
      IF v_publi <> 0
         AND pswpubli <> 1 THEN
         RETURN 9903732;
      END IF;

      vpas := 14;

      /* fIN Bug 22355- 23/05/2012 - ETM*/
      IF ptablas = 'EST' THEN
         UPDATE estper_personas
            SET nnumide = UPPER(vnnumide),
                ctipide = pctipide,
                csexper = DECODE(pctipper, 2, NULL, pcsexper),
                /* Bug 29738/166356 - 17/02/2014 - AMC*/
                fnacimi = pfnacimi,
                ctipper = pctipper,
                swpubli = pswpubli,
                tdigitoide = vdigitoide
          WHERE sperson = psperson;

         vpas := 15;

         UPDATE estper_identificador
            SET nnumide = UPPER(vnnumide),
                ctipide = pctipide
          WHERE sperson = psperson
            AND swidepri = 1;
      ELSIF ptablas = 'POL' THEN
         vpas := 16;
         IF pctipper = 2 THEN
            UPDATE fin_general 
            SET fconsti = pfnacimi
            WHERE sperson = psperson;        
         END IF;

         UPDATE per_personas
            SET nnumide = UPPER(vnnumide),
                ctipide = pctipide,
                csexper = DECODE(pctipper, 2, NULL, pcsexper),
                /* Bug 29738/166356 - 17/02/2014 - AMC*/
                fnacimi = DECODE(pctipper, 2, NULL, pfnacimi),
                ctipper = pctipper,
                swpubli = pswpubli,
                tdigitoide = vdigitoide,
                cpreaviso = pcpreaviso,
                cagente = DECODE(pswpubli, 1, (SELECT MIN(cagente)
                                                 FROM per_detper
                                                WHERE sperson = psperson), NULL)
          WHERE sperson = psperson;
         vpas := 17;

         BEGIN
            UPDATE per_identificador
               SET nnumide = UPPER(vnnumide),
                   ctipide = pctipide
             WHERE sperson = psperson
               AND swidepri = 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 9000804;
         END;

         /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'MODIF_PERSONA_HOST'),
                0) = 1
            AND ptablas = 'POL' THEN
            num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               RETURN num_err;
            END IF;

            vpas := 18;
			
            /* Cambios de IAXIS-13006 : start */
            BEGIN
              SELECT NVL(TRIM(DECODE(P.CTIPPER,
                                     1,
                                     NVL(PERDET.TAPELLI1, ''),
                                     2,
                                     NVL(PERDET.TAPELLI1, ''),
                                     '') ||
                              RTRIM(NVL(' ' || PERDET.TAPELLI2, '')) ||
                              RTRIM(NVL(' ' || PERDET.TNOMBRE1, '')) ||
                              NVL(' ' || PERDET.TNOMBRE2, '')),
                         PERDET.TNOMBRE) NOMBRE
                INTO V_NOMBREPARACOMPL
                FROM PER_DETPER PERDET, PER_PERSONAS P
               WHERE P.SPERSON = PERDET.SPERSON
                 AND PERDET.SPERSON = PSPERSON;
            
              NUM_ERR := PAC_LISTARESTRINGIDA.F_CONSULTAR_COMPLIANCE(PSPERSON,
                                                                     UPPER(VNNUMIDE),
                                                                     V_NOMBREPARACOMPL,
                                                                     PCTIPIDE,
                                                                     PCTIPPER);
            EXCEPTION
              WHEN OTHERS THEN
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'PAC_PERSONA',
                            VPAS,
                            'F_SET_BASICOS_PERSONA.ERROR EN LLAMADA F_CONSULTAR_COMPLIANCE',
                            'VNNUMIDE : ' || VNNUMIDE ||                            
                            ' PSPERSON : ' || PSPERSON ||
                            ' PCTIPIDE : ' || PCTIPIDE || 
                            ' PCTIPPER : ' || PCTIPPER);
            END;
            /* Cambios de IAXIS-13006 : end */			

            /* Cambios de IAXIS-4844 : start */
              BEGIN
                SELECT PP.TDIGITOIDE
                  INTO VDIGITOID
                  FROM PER_PERSONAS PP
                 WHERE PP.SPERSON = psperson
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(pctipide,
                                                                 UPPER(pnnumide));
              END;
            /* Cambios de IAXIS-4844 : end */

            /* BUG 21270/106644 - 08/02/2012 - JMP - Grabamos otro mensaje con NNUMIDE||TDIGITOIDE*/
            IF sw_envio_rut = 1 THEN
            /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 0, 'ALTA', VDIGITOID);
            /* Cambios de IAXIS-4844 : end */
               vpas := 19;

               IF num_err <> 0 THEN
                  perrores.EXTEND;
                  verr := ob_error.instanciar(num_err, terror);
                  vpas := 20;
                  perrores(1) := verr;
                  /*añado error del tmenin*/
                  verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                              pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                  perrores.EXTEND;
                  perrores(2) := verr;
                  RETURN num_err;
               END IF;
            END IF;

            vpas := 21;
            /* FIN BUG 21270/106644 - 08/02/2012 - JMP -*/
              /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
            v_host := NULL;

            /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
            END IF;

            vpas := 22;
            /* Cambios de IAXIS-4844 : start */
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOID,
                                              v_host);
            /* Cambios de IAXIS-4844 : end */

            /* BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA*/
            IF num_err <> 0 THEN
               perrores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               vpas := 23;
               perrores(1) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               perrores.EXTEND;
               perrores(2) := verr;
               RETURN num_err;
            END IF;

            vpas := 24;
            /* FIN BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA*/
            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               vpas := 25;
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOID,
                                                 v_host);
                /* Cambios de IAXIS-4844 : end */
            END IF;

            IF num_err <> 0 THEN
               /* psperson := NULL;*/
               perrores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               vpas := 26;
               perrores(1) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               perrores.EXTEND;
               perrores(2) := verr;
               RETURN num_err;
            END IF;
         /*fin BUG 0026318 -- GGR -- 17/03/2014*/
         END IF;
      END IF;

      vpas := 27;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PER_AGENDA'), 0) =
                                                                                              1
         AND ptablas = 'POL' THEN
         num_err := f_set_agensegu_rol(psperson, 'PER', pac_md_common.f_get_cxtidioma);

         IF num_err <> 0 THEN
            perrores.EXTEND;
            verr := ob_error.instanciar(num_err, SQLERRM);
            perrores(perrores.COUNT + 1) := verr;
            RETURN num_err;
         END IF;
      END IF;

      vpas := 28;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', vpas,
                     'f_set_basicos_persona.Error Imprevisto grabando personas',
                     'psperson = ' || psperson || ' nnumide = ' || vnnumide || ' pctipide : '
                     || pctipide || 'Error = ' || SQLERRM);
         RETURN 108469;
   END f_set_basicos_persona;

   /*************************************************************************
          Borrará la información de las tablas per_irpfdescen ,
          per_irpfmayores y per_irpf, dependiendo del modo borra de las tablas "EST".
   *************************************************************************/
   FUNCTION f_del_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      ptablas IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         DELETE FROM estper_irpfdescen
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;

         DELETE FROM estper_irpfmayores
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;

         DELETE FROM estper_irpf
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;
      ELSE
         DELETE FROM per_irpfdescen
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;

         DELETE FROM per_irpfmayores
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;

         DELETE FROM per_irpf
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_del_irpf;

   /*************************************************************************
        Esta función debe realizar un insert  y en caso de existir un update sobre la tabla per_irpf,
        dependiendo del modo de entrada lo realizará sobre las tablas estper_irpf.

        Bug 12716 - 26/03/2010 - AMC - Se añade los parametros pfmovgeo y pcpago
   *************************************************************************/
   FUNCTION f_set_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pcsitfam IN NUMBER,
      pcnifcon IN VARCHAR2,
      pcgrado IN NUMBER,
      pcayuda IN NUMBER,
      pipension IN NUMBER,
      pianuhijos IN NUMBER,
      pprolon IN NUMBER,
      prmovgeo IN NUMBER,
      ptablas IN VARCHAR2,
      pfmovgeo IN DATE,
      pcpago IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            INSERT INTO estper_irpf
                        (sperson, csitfam, cnifcon, cgrado, cayuda, ipension,
                         ianuhijos, prolon, rmovgeo, nano, cagente, cusuari, fmovimi,
                         fmovgeo, cpago)
                 VALUES (psperson, pcsitfam, pcnifcon, pcgrado, pcayuda, pipension,
                         pianuhijos, pprolon, prmovgeo, pnano, pcagente, f_user, f_sysdate,
                         pfmovgeo, pcpago);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE estper_irpf
                     SET csitfam = pcsitfam,
                         cnifcon = pcnifcon,
                         cgrado = pcgrado,
                         ipension = pipension,
                         ianuhijos = pianuhijos,
                         prolon = pprolon,
                         rmovgeo = prmovgeo,
                         cusuari = f_user,
                         fmovimi = f_sysdate,
                         fmovgeo = pfmovgeo,
                         cpago = pcpago
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND nano = pnano;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 1;
               END;
            WHEN OTHERS THEN
               RETURN 1;
         END;

         DELETE FROM estper_irpfmayores
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;

         DELETE FROM estper_irpfdescen
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;
      ELSE
         BEGIN
            INSERT INTO per_irpf
                        (sperson, csitfam, cnifcon, cgrado, cayuda, ipension,
                         ianuhijos, prolon, rmovgeo, nano, cagente, cusuari, fmovimi,
                         fmovgeo, cpago)
                 VALUES (psperson, pcsitfam, pcnifcon, pcgrado, pcayuda, pipension,
                         pianuhijos, pprolon, prmovgeo, pnano, pcagente, f_user, f_sysdate,
                         pfmovgeo, pcpago);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE per_irpf
                     SET csitfam = pcsitfam,
                         cnifcon = pcnifcon,
                         cgrado = pcgrado,
                         ipension = pipension,
                         ianuhijos = pianuhijos,
                         prolon = pprolon,
                         rmovgeo = prmovgeo,
                         cusuari = f_user,
                         fmovimi = f_sysdate,
                         fmovgeo = pfmovgeo,
                         cpago = pcpago
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND nano = pnano;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 1;
               END;
            WHEN OTHERS THEN
               RETURN 1;
         END;

         DELETE FROM per_irpfmayores
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;

         DELETE FROM per_irpfdescen
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND nano = pnano;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_set_irpf;

   /*************************************************************************
        Realizará un insert y en caso de existir modificará el registro, tener en cuenta
        el campo ptablas indica si se realiza sobre las est o sobre las tablas reales.
    *************************************************************************/
   FUNCTION f_set_irpfmayores(
      psperson IN per_irpfmayores.sperson%TYPE,
      pcagente IN per_irpfmayores.cagente%TYPE,
      pnano IN per_irpfmayores.nano%TYPE,
      pnorden IN per_irpfmayores.norden%TYPE,
      pfnacimi IN per_irpfmayores.fnacimi%TYPE,
      pcgrado IN per_irpfmayores.cgrado%TYPE,
      pcrenta IN per_irpfmayores.crenta%TYPE,
      pnviven IN per_irpfmayores.nviven%TYPE,
      ptablas IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            INSERT INTO estper_irpfmayores
                        (sperson, fnacimi, cgrado, crenta, nviven, cusuari, fmovimi,
                         norden, nano, cagente)
                 VALUES (psperson, pfnacimi, pcgrado, pcrenta, pnviven, f_user, f_sysdate,
                         pnorden, pnano, pcagente);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE estper_irpfmayores
                     SET fnacimi = pfnacimi,
                         cgrado = pcgrado,
                         crenta = pcrenta,
                         nviven = pnviven,
                         cusuari = f_user,
                         fmovimi = f_sysdate
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND nano = pnano
                     AND norden = pnorden;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 1;
               END;
            WHEN OTHERS THEN
               RETURN 1;
         END;
      ELSE
         BEGIN
            INSERT INTO per_irpfmayores
                        (sperson, fnacimi, cgrado, crenta, nviven, cusuari, fmovimi,
                         norden, nano, cagente)
                 VALUES (psperson, pfnacimi, pcgrado, pcrenta, pnviven, f_user, f_sysdate,
                         pnorden, pnano, pcagente);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE per_irpfmayores
                     SET fnacimi = pfnacimi,
                         cgrado = pcgrado,
                         crenta = pcrenta,
                         nviven = pnviven,
                         cusuari = f_user,
                         fmovimi = f_sysdate
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND nano = pnano
                     AND norden = pnorden;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 1;
               END;
            WHEN OTHERS THEN
               RETURN 1;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_set_irpfmayores;

   /*************************************************************************
        Realizará un insert y en caso de existir modificará el registro, tener en cuenta
        el campo ptablas indica si se realiza sobre las est o sobre las tablas reales.

        Bug 12716 - 25/03/2010 - AMC - Se añade el parametro pfadopcion
    *************************************************************************/
   FUNCTION f_set_irpfdescen(
      psperson IN per_irpfdescen.sperson%TYPE,
      pcagente IN per_irpfdescen.cagente%TYPE,
      pnano IN per_irpfdescen.nano%TYPE,
      pnorden IN per_irpfdescen.norden%TYPE,
      pfnacimi IN per_irpfdescen.fnacimi%TYPE,
      pfadopcion IN per_irpfdescen.fadopcion%TYPE,
      pcenter IN per_irpfdescen.center%TYPE,
      pcgrado IN per_irpfdescen.cgrado%TYPE,
      ptablas IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            INSERT INTO estper_irpfdescen
                        (sperson, fnacimi, cgrado, center, cusuari, fmovimi, norden,
                         nano, cagente, fadopcion)
                 VALUES (psperson, pfnacimi, pcgrado, pcenter, f_user, f_sysdate, pnorden,
                         pnano, pcagente, pfadopcion);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE estper_irpfdescen
                     SET fnacimi = pfnacimi,
                         cgrado = pcgrado,
                         center = pcenter,
                         cusuari = f_user,
                         fmovimi = f_sysdate,
                         fadopcion = pfadopcion
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND nano = pnano
                     AND norden = pnorden;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 1;
               END;
            WHEN OTHERS THEN
               RETURN 1;
         END;
      ELSE
         BEGIN
            INSERT INTO per_irpfdescen
                        (sperson, fnacimi, cgrado, center, cusuari, fmovimi, norden,
                         nano, cagente, fadopcion)
                 VALUES (psperson, pfnacimi, pcgrado, pcenter, f_user, f_sysdate, pnorden,
                         pnano, pcagente, pfadopcion);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               BEGIN
                  UPDATE per_irpfdescen
                     SET fnacimi = pfnacimi,
                         cgrado = pcgrado,
                         center = pcenter,
                         cusuari = f_user,
                         fmovimi = f_sysdate,
                         fadopcion = pfadopcion
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND nano = pnano
                     AND norden = pnorden;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 1;
               END;
            WHEN OTHERS THEN
               RETURN 1;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_set_irpfdescen;

   FUNCTION f_get_irpfmayor(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      pidioma IN NUMBER,
      ptablas IN VARCHAR2,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_irpfmayor';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pcagente IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      psquery :=
         'select cagente, sperson, fnacimi, cgrado, crenta, nviven, norden, nano,
                 ff_desvalorfijo(688,'
         || pidioma
         || ', cgrado) tgrado, cusuari, fmovimi
              from estper_irpfmayores
              where sperson = '
         || psperson || '
                and ' || CHR(39) || ptablas || CHR(39)
         || ' = ''EST''
                and nano = ' || pnano || '
                 and norden = ' || pnorden
         || '
              union all
                select cagente, sperson, fnacimi, cgrado, crenta, nviven, norden, nano,
                 ff_desvalorfijo(688,'
         || pidioma
         || ', cgrado) tgrado, cusuari, fmovimi
              from per_irpfmayores
              where sperson = '
         || psperson || '
                and cagente = ' || pcagente || '
                and ' || CHR(39) || ptablas || CHR(39)
         || ' != ''EST''
                and nano = ' || pnano || '
          and norden = ' || pnorden || '
         ';
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9000689;
   END f_get_irpfmayor;

   FUNCTION f_get_irpfdescen(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      pidioma IN NUMBER,
      ptablas IN VARCHAR2,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_irpfmayor';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pcagente IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      psquery :=
         '     select cagente, sperson, fnacimi, cgrado, center,  norden, nano,
                 ff_desvalorfijo(688, '
         || pidioma
         || ', cgrado) tgrado, cusuari, fmovimi, fadopcion
              from estper_irpfdescen
              where sperson ='
         || psperson || '
                and ' || CHR(39) || ptablas || CHR(39)
         || ' = ''EST''
                and nano = ' || pnano || '
                 and norden = ' || pnorden
         || '
              union all
                select cagente, sperson, fnacimi, cgrado, center, norden, nano,
                ff_desvalorfijo(688, '
         || pidioma
         || ', cgrado) tgrado, cusuari, fmovimi, fadopcion
              from per_irpfdescen
              where sperson = '
         || psperson || '
                and cagente = ' || pcagente || '
                and ' || CHR(39) || ptablas || CHR(39)
         || ' != ''EST''
                and nano = ' || pnano || '
          and norden = ' || pnorden || '';
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9000689;
   END f_get_irpfdescen;

   FUNCTION f_get_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pidioma IN NUMBER,
      ptablas IN VARCHAR2,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_irpfmayor';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pcagente IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      /* bug 12716 - 26/03/2010 - AMC*/
      psquery :=
         ' select sperson, cagente, csitfam, cnifcon, cgrado, cayuda, ipension , ianuhijos,
                 cusuari,  prolon, rmovgeo, nano,  tgrado,  tsitfarm, fmovgeo, cpago
                 from
                 (   select sperson ,cagente, csitfam, cnifcon, cgrado, cayuda, ipension , ianuhijos,
                 cusuari,  prolon, rmovgeo, nano,  ff_desvalorfijo(688, '
         || pidioma || ', cgrado) tgrado,
                 ff_desvalorfijo(883,' || pidioma
         || ', csitfam) tsitfarm, fmovgeo, cpago
              from estper_irpf
              where sperson = '
         || psperson || '
                and ' || CHR(39) || ptablas || CHR(39)
         || ' = ''EST''
                and nano = ' || pnano
         || '
              union all
                  select sperson , cagente, csitfam, cnifcon, cgrado, cayuda, ipension , ianuhijos,
                 cusuari,  prolon, rmovgeo, nano,  ff_desvalorfijo(688,'
         || pidioma || ', cgrado) tgrado,
                 ff_desvalorfijo(883,' || pidioma
         || ', csitfam) tsitfarm, fmovgeo, cpago
              from per_irpf
              where sperson = '
         || psperson || '
                and cagente = ' || pcagente || '
                and ' || CHR(39) || ptablas || CHR(39)
         || ' != ''EST''
                and nano = ' || pnano || ')';
      /* fi bug 12716 - 26/03/2010 - AMC*/
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9000689;
   END f_get_irpf;

   /*************************************************************************
    función que devuelve número de años para declarar el irpf de una persona,
    si la persona existe se le devolverá el máximo más uno sino existiera se
    le devolvería el actual año
   *************************************************************************/
   FUNCTION f_get_anysirpf(psperson IN NUMBER, pcagente IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_anysirpf';
      v_cont         NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO v_cont
        FROM per_irpf
       WHERE sperson = NVL(psperson, -1)
         AND cagente = NVL(pcagente, -1);

      IF v_cont > 0 THEN
         psquery :=
            'select max(nano) + 1  NANO
                            from per_irpf
                            where sperson = nvl('
            || psperson || ',-1)
                            and cagente   = nvl(' || pcagente || ',-1)';
      ELSE
         psquery :=
            'select to_number(to_char(f_sysdate,''yyyy'')) NANO
                            from dual';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9000689;
   END f_get_anysirpf;

   /*************************************************************************
     función que recuperará todas la personas dependiendo del modo.
     publico o no. servirá para todas las pantallas donde quieran utilizar el
     buscador de personas.
   *************************************************************************/
   FUNCTION f_get_persona_generica(
      pnumide IN VARCHAR2,
      pnombre IN VARCHAR2,
      pnsip IN VARCHAR2,
      pnom IN VARCHAR2,
      pcognom1 IN VARCHAR2,
      pcognom2 IN VARCHAR2,
      pctipide IN NUMBER,
      pcagente IN NUMBER,
      pmodo_swpubli IN VARCHAR2,
      psquery OUT CLOB)
      RETURN NUMBER IS
      condicio1      VARCHAR2(1000);
      condicio2      VARCHAR2(1000);
      condicio3      VARCHAR2(1000);
      condicio4      VARCHAR2(1000);
      condicio5      VARCHAR2(1000);
      condicio6      VARCHAR2(1000);
      condicio7      VARCHAR2(1000);
      tlog           VARCHAR2(4000);
      nerr           NUMBER(10);
      auxnom         VARCHAR2(9000);
      condicion      VARCHAR2(9000);
      vmodo_swpubli  VARCHAR2(100);
      /*Bug 29166/160004 - 29/11/2013 - AMC*/
      vpervisionpublica NUMBER;
   BEGIN
      /*Bug 29166/160004 - 29/11/2013 - AMC*/
      vmodo_swpubli := pmodo_swpubli;
      vpervisionpublica :=
         NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                           'PER_VISIONPUBLICA'),
             0);

      IF NVL(vpervisionpublica, 0) = 1 THEN
         vmodo_swpubli := 'PERSONAS_PUBPRIV';
      END IF;

      /*Fi Bug 29166/160004 - 29/11/2013 - AMC*/
      IF pnombre IS NOT NULL THEN
         nerr := f_strstd(pnombre, auxnom);
         condicio1 := '%' || auxnom || '%';
         condicion := ' AND UPPER(tbuscar) LIKE UPPER(' || CHR(39) || condicio1 || CHR(39)
                      || ')';
      END IF;

      IF pnumide IS NOT NULL THEN
         condicio2 := ff_strstd(pnumide);
         /* Bug 35888/205345 Realizar la substitución del upper nnumnif o nnumide - CJMR D02 A01*/
         /*condicion := ' AND UPPER(per.nnumide) LIKE UPPER(' || CHR(39) || condicio2 || CHR(39)*/
           /*             || ')';*/
         condicion := ' AND per.nnumide LIKE ' || CHR(39) || condicio2 || CHR(39);
      END IF;

      IF pnumide IS NOT NULL THEN
         condicio2 := ff_strstd(pnumide);
         /* condicion := ' AND UPPER(per.nnumide) LIKE UPPER(' || CHR(39) || condicio2 || CHR(39) || ')';*/
         condicion := ' AND per.nnumide LIKE ' || CHR(39) || '%' || condicio2 || '%'
                      || CHR(39) || ' ';   -- 36190-206031
      END IF;

      IF pnsip IS NOT NULL THEN
         condicio3 := ff_strstd(pnsip);
         condicion := ' AND UPPER(per.snip) LIKE UPPER(' || CHR(39) || condicio3 || CHR(39)
                      || ')';
      END IF;

      IF pnom IS NOT NULL THEN
         condicio4 := '%' || ff_strstd(pnom) || '%';
         condicion := ' AND  ff_strstd(tnombre) LIKE (' || CHR(39) || condicio4 || CHR(39)
                      || ')';
      END IF;

      IF pcognom1 IS NOT NULL THEN
         condicio5 := '%' || ff_strstd(pcognom1) || '%';
         condicion := ' AND  ff_strstd(tapelli1) LIKE (' || CHR(39) || condicio5 || CHR(39)
                      || ')';
      END IF;

      IF pcognom2 IS NOT NULL THEN
         condicio6 := '%' || ff_strstd(pcognom2) || '%';
         condicion := ' AND  ff_strstd(tapelli2) LIKE (' || CHR(39) || condicio6 || CHR(39)
                      || ')';
      END IF;

      IF pctipide IS NOT NULL THEN
         condicio7 := TO_CHAR(pctipide);
         /* condicion := ' AND per.ctipide = ' || CHR(39) || condicio7 || CHR(39);*/
         condicion := condicion || ' AND per.ctipide = ' || CHR(39) || condicio7 || CHR(39);   /* 36190-206031*/
      END IF;

      /* Bug 25456/133727 - 16/01/2013 - AMC*/
      /*Bug 29166/160004 - 29/11/2013 - AMC*/
      IF vmodo_swpubli = 'PERSONAS_PUBLICAS' THEN
         psquery :=
            '         SELECT   sperson codi, cagente, ff_desagente(cagente) tagente, nnumide, tnombre || '' '' || tapelli nombre, pac_persona.F_FORMAT_NIF(nnumide,ctipide,sperson,''POL'') NNUMNIF
                     FROM (SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
                  per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
                  per.snip, d.cagente, ff_agenteprod() cagenteprod, d.cidioma,
                  SUBSTR(d.tapelli1, 0, 40) tapelli1, SUBSTR(d.tapelli2, 0, 20) tapelli2,
                  SUBSTR(d.tapelli1, 0, 40) || '' '' || SUBSTR(d.tapelli2, 0, 20) tapelli,
                  /* Se deberá quitar el substr cuando se prepare base de datos*/
                  SUBSTR(d.tnombre, 0, 20) tnombre,SUBSTR(d.tsiglas, 0, 20) tsiglas,d.cprofes,
                  d.tbuscar, d.cestciv, d.cpais, c.cbancar, c.ctipban, per.swpubli, per.ctipper,
                  per.nnumide nnumnif, per.ctipper cpertip, per.ctipide tidenti, per.nordide nnifdup,
                  per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
                  NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
                  NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
                  NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, d.cocupacion
             FROM per_personas per, per_detper d, per_ccc c, personas_publicas pu
            WHERE per.sperson = d.sperson
              AND c.sperson(+) = d.sperson
              AND c.cagente(+) = d.cagente
              AND per.cagente = d.cagente
              AND c.cdefecto(+) = 1   /* cuenta bacaria por defecto*/
              AND pu.sperson  = per.sperson '
            || condicion
            || ' )where ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      /* La persona es pública y la puede ver todo el mundo*/
      ELSIF vmodo_swpubli = 'PERSONAS_PRIVADAS' THEN
         /* Bug 12761 - 18/01/2010 - AMC - Se añade la condición*/
         psquery :=
            ' SELECT   sperson codi, cagente, ff_desagente(cagente) tagente, nnumide, tnombre || '' '' || tapelli nombre, pac_persona.F_FORMAT_NIF(nnumide,ctipide,sperson,''POL'') NNUMNIF
                     FROM(
                     SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
                  per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
                  per.snip, d.cagente, ff_agenteprod() cagenteprod, d.cidioma,
                  SUBSTR(d.tapelli1, 0, 40) tapelli1, SUBSTR(d.tapelli2, 0, 20) tapelli2,
                  SUBSTR(d.tapelli1, 0, 40) || '' '' || SUBSTR(d.tapelli2, 0, 20) tapelli,
                  SUBSTR(d.tnombre, 0, 20) tnombre,
                                                   SUBSTR(d.tsiglas, 0, 20) tsiglas,
                                                                                    d.cprofes,
                  d.tbuscar, d.cestciv, d.cpais, c.cbancar, c.ctipban, per.swpubli, per.ctipper,
                  per.nnumide nnumnif, per.ctipide cpertip, per.ctipide tidenti, per.nordide nnifdup,
                  per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
                  NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
                  NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
                  NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, d.cocupacion
             FROM per_personas per, per_detper d, per_ccc c
            WHERE per.sperson = d.sperson
              AND c.sperson(+) = d.sperson
              AND c.cagente(+) = d.cagente
              AND c.cdefecto(+) = 1   /* cuenta bacaria por defecto*/
              AND per.swpubli = 0
              AND d.cagente in ( select cagente from agentes_agente)'
            || condicion
            || ' )where ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      /*Fi Bug 12761 - 18/01/2010 - AMC - Se añade la condición*/
      ELSIF vmodo_swpubli = 'PERSONAS_PUBPRIV' THEN
         /* Personas publicas y privadas*/
         psquery :=
            ' SELECT   sperson codi, cagente, ff_desagente(cagente) tagente, nnumide, tnombre || '' '' || tapelli nombre, pac_persona.F_FORMAT_NIF(nnumide,ctipide,sperson,''POL'') NNUMNIF
                     FROM(
                     SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
                  per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
                  per.snip, per.cagente, ff_agenteprod() cagenteprod, per.cidioma,
                  per.tapelli1, per.tapelli2 ,
                  per.tapelli1 || '' '' || per.tapelli2 tapelli,
                  per.tnombre tnombre, per.tsiglas, per.cprofes,
                  per.tbuscar, per.cestciv, cpais, per.cbancar, per.ctipban, per.swpubli, per.ctipper,
                  per.nnumide nnumnif, per.ctipide cpertip, per.ctipide tidenti, per.nordide nnifdup,
                  per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
                  NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
                  NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
                  NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, per.cocupacion,
                  per.cocupacion
             FROM personas_detalles per
             WHERE 0=0 '
            || condicion
            || ' ) WHERE ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      END IF;

      /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_persona', 1, 'f_get_persona_generica', SQLERRM);
         RETURN 1;
   END f_get_persona_generica;

   /* fin t.8063*/
   FUNCTION f_buscaagente_publica(
      psperson IN per_personas.sperson%TYPE,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN per_detper.cagente%TYPE IS
      vcagente       per_detper.cagente%TYPE;
   BEGIN
      /*Bug 29166/160004 - 29/11/2013 - AMC*/
          /* SELECT cagente
           INTO vcagente
           FROM per_detper d
          WHERE d.sperson = psperson;*/
      IF ptablas = 'EST' THEN
         SELECT cagente
           INTO vcagente
           FROM estper_personas
          WHERE sperson = psperson;
      ELSE
         SELECT cagente
           INTO vcagente
           FROM per_personas
          WHERE sperson = psperson;
      END IF;

      /*Fi Bug 29166/160004 - 29/11/2013 - AMC*/
      RETURN vcagente;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_buscaagente_publica', 1,
                     'Error Imprevisto obteniendo el agente', psperson || ' - ' || SQLERRM);
         RETURN NULL;
   END f_buscaagente_publica;

   /* fin t.8063*/
   /*BUG 10074 - JTS - 18/05/2009*/
   /*************************************************************************
   Obté la select amb els profesionals associats a una persona
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_profesionales(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_profesionales';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      psquery :=
         ' SELECT pro.sprofes sprofes, det1.tatribu tactpro, det2.tatribu tsubpro, ret.ttipret, iva.ttipiva
                 FROM sin_prof_profesionales pro, descripcionret ret, descripcioniva iva, sin_prof_rol act, detvalores det1, detvalores det2
                  WHERE pro.sperson = '
         || psperson || 'AND pro.cretenc = ret.cretenc(+) AND ret.cidioma(+) = ' || pidioma
         || ' AND pro.ctipiva = iva.ctipiva(+) AND iva.cidioma(+) = ' || pidioma
         || ' AND pro.sprofes = act.sprofes
                      AND act.ctippro = det1.catribu AND det1.cvalor = 724 AND det1.cidioma = '
         || pidioma
         || ' AND act.csubpro = det2.catribu AND det2.cvalor = 725 AND det2.cidioma = '
         || pidioma;
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_profesionales;

   /*************************************************************************
   Obté la select amb les companyies associades a una persona
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_companias(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_companias';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      psquery := 'SELECT cia.tcompani, iva.ttipiva, com.tcomisi'
                 || ' FROM companias cia, descripcioniva iva, descomision com'
                 || ' WHERE cia.sperson = ' || psperson || '  AND cia.ctipiva = iva.ctipiva(+)'
                 || '  AND cia.ccomisi = com.ccomisi(+)' || '  AND iva.cidioma(+) = '
                 || pidioma || '  AND com.cidioma(+) = ' || pidioma;
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_companias;

   /*************************************************************************
   Obté la select amb els agents associats a una persona
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_agentes(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_agentes';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      psquery :=
         'SELECT distinct a.cagente, ag.tatribu tipagente, act.tatribu agactivo, e.tempres'
         || ' FROM redcomercial r, agentes a, empresas e, detvalores ag, detvalores act'
         || ' WHERE a.cagente = r.cagente' || ' AND r.cempres = e.cempres'
         || ' AND a.sperson = ' || psperson || ' AND ag.cvalor = 30' || ' AND act.cvalor = 31'
         || ' AND ag.catribu = a.ctipage' || ' AND act.catribu = a.cactivo'
         || ' AND ag.cidioma(+) = ' || pidioma || ' AND act.cidioma(+) = ' || pidioma;
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_agentes;

   /*************************************************************************
   Obté la select amb els sinistres associats a una persona
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_siniestros(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_siniestros';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      /* Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol*/
      psquery :=
         'SELECT SIN.cramo, SIN.cmodali, SIN.sproduc,'
         || ' f_desproducto_t(SIN.cramo, SIN.cmodali, SIN.ctipseg, SIN.ccolect, 2, 1) ttitpro,'
         || ' SIN.poliza, SIN.nsinies, SIN.fsinies, SIN.cestsin, SIN.testsin, SIN.tsinies,'
         || ' RTRIM(LTRIM((DECODE((SELECT COUNT(1) FROM tomadores t'
         || ' WHERE t.sseguro = SIN.sseguro AND t.sperson = SIN.sperson), 0, ' || CHR(39)
         || CHR(39) || ', f_axis_literales(101027, pac_md_common.f_get_cxtidioma)) || '' '''
         || ' || DECODE((SELECT COUNT(1) FROM riesgos ri'
         || ' WHERE ri.sseguro = SIN.sseguro AND ri.nriesgo = SIN.nriesgo'
         || ' AND ri.sperson = SIN.sperson), 0, ' || CHR(39) || CHR(39) || ','
         || ' f_axis_literales(101028, pac_md_common.f_get_cxtidioma)) || '' '''
         || ' || (decode((SELECT count(1) FROM sin_tramita_destinatario d'
         || ' WHERE d.nsinies = SIN.nsinies AND d.sperson = SIN.sperson),0, ' || CHR(39)
         || CHR(39)
         || ', f_axis_literales(9000909, pac_md_common.f_get_cxtidioma)))),'' ''),'' '') relacion,'
         || ' SIN.sperson, SIN.sseguro'
         || ' FROM (SELECT r.sperson, s.nsinies, s.nriesgo, fsinies, cestsin,'
         || ' ff_desvalorfijo(6, pac_md_common.f_get_cxtidioma, m.cestsin) testsin, tsinies,'
         || ' seg.sseguro, f_formatopol(seg.npoliza, seg.ncertif, 1) poliza, seg.cramo,'
         || ' cmodali, seg.ccolect, seg.ctipseg, seg.sproduc'
         || ' FROM seguros seg, sin_siniestro s, riesgos r, sin_movsiniestro m'
         || ' WHERE r.sseguro = s.sseguro AND r.nriesgo = s.nriesgo'
         || ' AND r.sseguro = seg.sseguro'
         || ' AND(seg.cagente, cempres) IN(SELECT cagente, cempres FROM agentes_agente_pol)'
         || ' AND m.nsinies = s.nsinies AND m.nmovsin IN(SELECT MAX(nmovsin)'
         || ' FROM sin_movsiniestro mm WHERE mm.nsinies = s.nsinies) UNION'
         || ' SELECT t.sperson, s.nsinies, s.nriesgo, fsinies, cestsin,'
         || ' ff_desvalorfijo(6, pac_md_common.f_get_cxtidioma, m.cestsin) testsin, tsinies,'
         || ' seg.sseguro, f_formatopol(seg.npoliza, seg.ncertif, 1) poliza, seg.cramo,'
         || ' cmodali, seg.ccolect, seg.ctipseg, seg.sproduc'
         || ' FROM seguros seg, sin_siniestro s, tomadores t, sin_movsiniestro m'
         || ' WHERE t.sseguro = s.sseguro AND seg.sseguro = s.sseguro'
         || ' AND(seg.cagente, cempres) IN(SELECT cagente, cempres FROM agentes_agente_pol)'
         || ' AND m.nsinies = s.nsinies AND m.nmovsin IN(SELECT MAX(nmovsin)'
         || ' FROM sin_movsiniestro mm WHERE mm.nsinies = s.nsinies) UNION'
         || ' SELECT d.sperson, s.nsinies, s.nriesgo, fsinies, cestsin,'
         || ' ff_desvalorfijo(6, pac_md_common.f_get_cxtidioma, m.cestsin) testsin, tsinies,'
         || ' seg.sseguro, f_formatopol(seg.npoliza, seg.ncertif, 1) poliza, seg.cramo,'
         || ' cmodali, seg.ccolect, seg.ctipseg, seg.sproduc'
         || ' FROM seguros seg, sin_siniestro s, sin_tramita_destinatario d, sin_movsiniestro m'
         || ' WHERE d.nsinies = s.nsinies AND seg.sseguro = s.sseguro'
         || ' AND(seg.cagente, cempres) IN(SELECT cagente, cempres FROM agentes_agente_pol)'
         || ' AND m.nsinies = s.nsinies AND m.nmovsin IN(SELECT MAX(nmovsin)'
         || ' FROM sin_movsiniestro mm WHERE mm.nsinies = s.nsinies)) SIN'
         || ' WHERE sperson = ' || psperson;
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_siniestros;

   /*************************************************************************
   Obté la select amb les pólisses en que una persona es prenedora
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_poltom(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_poltom';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      /* Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol*/
      psquery :=
         'SELECT s.sseguro, t.nordtom, f_formatopol(npoliza, ncertif, 1) poliza, s.cramo, s.cmodali,'
         || ' f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, ' || pidioma
         || ') tproducto, s.fanulac, s.cagente,' || ' f_desagente_t(s.cagente) tagente'
         || ' FROM seguros s, tomadores t' || ' WHERE s.sseguro = t.sseguro'
         || ' AND t.sperson = ' || psperson || ' AND s.cagente IN(SELECT cagente'
         || ' FROM agentes_agente_pol) order by 3';
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_poltom;

   /*************************************************************************
   Obté la select amb les pólisses en que una persona es assegurada
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_polase(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_polase';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      /* Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol*/
      psquery :=
         'SELECT s.sseguro, a.nriesgo, f_formatopol(npoliza, ncertif, 1) poliza, s.cramo, s.cmodali,'
         || ' f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, ' || pidioma
         || ') tproducto,'
         || ' NVL(a.fanulac, s.fanulac) fanulac, s.cagente, f_desagente_t(s.cagente) tagente, s.fefecto'
         || ' FROM seguros s,' || ' (SELECT norden nriesgo, sseguro, sperson, ffecfin fanulac'
         || ' FROM asegurados' || ' UNION' || ' SELECT nriesgo, sseguro, sperson, fanulac'
         || ' FROM riesgos) a' || ' WHERE s.sseguro = a.sseguro' || ' AND a.sperson = '
         || psperson || ' AND s.cagente IN(SELECT cagente'
         || ' FROM agentes_agente_pol) order by 3';
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_polase;

   /*Fi BUG 10074 - JTS - 18/05/2009*/
   /*BUG 10371 - JTS - 09/06/2009*/
   /*************************************************************************
   Obté la select amb els paràmetres per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pidioma    : Codi idioma
   param in ptots      : 0.- Només retorna els paràmetres contestats
                         1.- Retorna tots els paràmetres
   param in pctipper   : Codi Tipus persona
   param out psquery   : Select
   return              : 0.- OK, 1.- KO

    bug 24764-133188 - Se modifica la función para que recupere las agrupaciones de parametros
  3.0     09/04/2019     CES   Ajuste consorcios como atributo de personas.
   *************************************************************************/
   FUNCTION f_get_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pidioma IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      ptablas IN VARCHAR2,
      pctipper IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vumerr         NUMBER;
      vsquery        VARCHAR2(15000);
      vtabla1        VARCHAR2(500);
      vtabla2        VARCHAR2(500);
      vwhere         VARCHAR2(5000);
      vwhere2        VARCHAR2(5000);
      vwhere3        VARCHAR2(5000);
    vctipper       NUMBER;     -- Spring 1 - Inc. 643 - ACL - 21/11/2018
   BEGIN
      IF psperson IS NOT NULL THEN
         IF ptablas = 'EST' THEN
            vtabla1 := ' estper_parpersonas r';
            vtabla2 := ' estper_personas per';
         ELSE
            vtabla1 := ' per_parpersonas r';
            vtabla2 := ' per_personas per';
         END IF;

         IF pcvisible IS NOT NULL
            AND pcvisible <> 1 THEN
            vwhere2 := vwhere2 || ' and cp.cvisible = ' || pcvisible;
         END IF;

         IF psperson IS NOT NULL THEN
            vwhere := vwhere || ' AND per.sperson = ' || psperson;
         END IF;

         IF ptots = 0 THEN
            vwhere2 := vwhere2 || ' AND r.cparam = cp.cparam';

            IF ptablas <> 'EST' THEN
               vwhere2 := vwhere2 || ' AND r.cagente = ' || pcagente;
            END IF;

            IF psperson IS NOT NULL THEN
               vwhere2 := vwhere2 || ' AND r.sperson = ' || psperson;
            END IF;
         ELSE
            vwhere2 := vwhere2 || ' AND r.cparam(+) = cp.cparam';

            IF ptablas <> 'EST' THEN
               vwhere2 := vwhere2 || ' AND r.cagente(+) = ' || pcagente;
            END IF;

            IF psperson IS NOT NULL THEN
               vwhere2 := vwhere2 || ' AND r.sperson(+) = ' || psperson;
            END IF;
         END IF;
         --
         -- Inicio IAXIS-4832(7) 09/09/2019
         --
         -- Si no es consorcio se debe quitar el parámetro relacionado con "Tipo de asociación jurídica".
         IF f_consorcio(psperson) = 0 THEN
           vwhere2 := vwhere2 || ' AND c.cparam NOT IN (''PER_ASO_JURIDICA'')';
         END IF;  
         --
         -- Fin IAXIS-4832(7) 09/09/2019
         --
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'PARAGRUPA'),
                0) = 0 THEN
            vsquery :=
               'SELECT NULL norden_agr,  null cgrppar, null tgrppar,c.cutili, c.cparam, c.ctipo, d.tparam, cp.cvisible, cp.ctipper, r.tvalpar, r.nvalpar, r.fvalpar,'
               || ' (select det.tvalpar from detparam det where det.cparam = c.cparam and det.cidioma = d.cidioma and det.cvalpar = r.nvalpar) resp, 1 e, c.norden'
               || ' FROM codparam c, desparam d, codparam_per cp, ' || vtabla1 || ','
               || vtabla2 || ' WHERE c.cutili = 8' || ' AND d.cparam = c.cparam'
               || ' AND cp.cparam = c.cparam'
             /*  Ini Spring 1 - Inc. 643 - ACL - 21/11/2018  */
             /*  || ' AND (per.ctipper = cp.ctipper or  cp.ctipper = 0)'  */
               --INI CES 09/04/2019
         || ' AND cp.ctipper in (0,2)'
         --END CES 09/04/2019
               || ' AND cp.cvisible = 0'
             /*  Fin Spring 1 - Inc. 643 - ACL - 21/11/2018  */
                                                                      /*Bug 22693/119018 - 26/09/2012 - AMC*/
               || ' AND d.cidioma = ' || pidioma;
            vsquery := vsquery || vwhere2 || vwhere;
            vsquery := vsquery || ' ORDER BY NVL(C.NORDEN,0)';
         ELSE
            vsquery :=
               ' select norden_agr,  cgrppar,tgrppar,cutili,cparam,ctipo,tparam,cvisible,ctipper,tvalpar,nvalpar,fvalpar,resp,e ,norden'
               || ' from( '
               || ' select DISTINCT cd.norden norden_agr, d.cgrppar, tgrppar,null cutili,null cparam,null ctipo,null tparam,null cvisible,null ctipper, '
               || ' null tvalpar,null nvalpar,null fvalpar,null resp,1 e, 0 norden '
               /* Bug 24764 -- MMS -- 20130305 Reodenamos la lista de f_get_parpersona*/
               || ' from CODGRPPARAM cd, desgrpparam d, CODPARAM c,codparam_per cp, '
               || vtabla1 || ',' || vtabla2
               || ' where d.cgrppar = c.cgrppar  and cp.cparam = c.cparam   and cd.cgrppar = d.cgrppar '
               || ' and c.cutili = 8  AND (per.ctipper = cp.ctipper or  cp.ctipper = 0)  and cidioma = '
               || pidioma || vwhere2 || vwhere || ' union all '
               || ' SELECT cd.norden norden_agr, c.cgrppar,null tgrppar,c.cutili, c.cparam, c.ctipo, d.tparam, cp.cvisible, cp.ctipper, null tvalpar, null nvalpar, null fvalpar, '
               || ' null  resp,2 e, c.norden '
               || ' FROM  CODGRPPARAM cd, codparam c, desparam d, codparam_per cp,'
                                                                                   /* Bug 24764 -- MMS -- 20130305 Reodenamos la lista de f_get_parpersona*/
               || vtabla1 || ',' || vtabla2
               || ' WHERE c.cutili = 8 AND d.cparam = c.cparam and cd.cgrppar = c.cgrppar  '
               || ' AND cp.cparam = c.cparam  AND (per.ctipper = cp.ctipper or  cp.ctipper = 0) AND d.cidioma = '
               || pidioma || vwhere2 || vwhere
               || ' and cp.cparam not in (select r.cparam from ' || vtabla1
               || ' where r.sperson = per.sperson and r.cagente= ff_agente_cpervisio('
               || pcagente || '))' || ' union all '
               || ' SELECT cd.norden norden_agr, c.cgrppar,null tgrppar,c.cutili, c.cparam, c.ctipo, d.tparam, cp.cvisible, cp.ctipper, r.tvalpar, r.nvalpar, r.fvalpar,'
               || ' (select det.tvalpar from detparam det  where det.cparam = c.cparam and det.cidioma = d.cidioma and det.cvalpar = r.nvalpar) resp,3 e, c.norden'
               /* Bug 24764 -- MMS -- 20130305 Reodenamos la lista de f_get_parpersona*/
               || ' FROM CODGRPPARAM cd, codparam c, desparam d, codparam_per cp,' || vtabla1
               || ',' || vtabla2
               || ' WHERE c.cutili = 8 AND d.cparam = c.cparam  AND cd.cgrppar = c.cgrppar '
               || ' AND cp.cparam = c.cparam '
               || ' AND (per.ctipper = cp.ctipper or  cp.ctipper = 0)' || ' AND d.cidioma = '
               || pidioma || vwhere2 || vwhere || ' and r.sperson = per.sperson'
               || ' and r.cparam = cp.cparam'
               || ' ) order by norden_agr, decode(e,1,1,2), norden';
         /* Bug 24764 -- MMS -- 20130305 Reodenamos la lista de f_get_parpersona*/
         END IF;
      ELSE
         IF pctipper IS NOT NULL THEN
            vwhere3 := ' and (' || pctipper || ' = cp.ctipper or  cp.ctipper = 0) ';
         END IF;

         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'PARAGRUPA'),
                0) = 0 THEN
            vsquery :=
               'SELECT NULL norden_agr, null cgrppar, null tgrppar,c.cutili, c.cparam, c.ctipo, d.tparam, cp.cvisible, cp.ctipper, null, null,null ,'
               || ' null resp, 1 e, 0 norden'
               || ' FROM codparam c, desparam d, codparam_per cp ' || ' WHERE c.cutili = 8'
               || ' AND d.cparam = c.cparam' || ' AND cp.cparam = c.cparam '
               || ' AND d.cidioma = ' || pidioma;

            IF pcvisible IS NOT NULL
               AND pcvisible <> 1 THEN
               vsquery := vsquery || ' and cp.cvisible = ' || pcvisible;
            END IF;

            IF pctipper IS NOT NULL THEN
            /*  Ini Spring 1 - Inc. 643 - ACL - 21/11/2018 */
               vctipper := 1;
               vsquery := vsquery || ' AND (cp.ctipper = ' || vctipper
                          || ' or  cp.ctipper = 0) ';
            /*  Fin Spring 1 - Inc. 643 - ACL - 21/11/2018 */
            END IF;

            vsquery := vsquery || vwhere;
            /* Ini Bug 22053 - MDS - 27/04/2012*/
            vsquery := vsquery || ' ORDER BY NVL(C.NORDEN,0)';
         /* Ini Bug 22053 - MDS - 27/04/2012*/
         ELSE
            IF pcvisible IS NOT NULL
               AND pcvisible <> 1 THEN
               vwhere := ' and cp.cvisible = ' || pcvisible;
            END IF;

            vsquery :=
               'select norden_agr, cgrppar,tgrppar,cutili,cparam,ctipo,tparam,cvisible,ctipper,tvalpar,nvalpar,fvalpar,resp,e, norden '
               || ' from ('
               || ' select DISTINCT cd.norden norden_agr, d.cgrppar, tgrppar,null cutili,null cparam,null ctipo,null tparam,null cvisible,null ctipper,'
               || ' null tvalpar,null nvalpar,null fvalpar,null resp,1 e, 0 norden'
               || ' from CODGRPPARAM cd, desgrpparam d, CODPARAM c'
               || ' where d.cgrppar = c.cgrppar and d.cgrppar = cd.cgrppar'
               || ' and c.cutili = 8' || ' and cidioma = ' || pidioma || ' union all'
               || ' SELECT cd.norden norden_agr, c.cgrppar cgrppar,null tgrppar ,c.cutili, c.cparam, c.ctipo, d.tparam, cp.cvisible, cp.ctipper, null tvalpar, null nvalpar,'
               || ' null fvalpar,null resp, 2 e, c.norden'
               || ' FROM  CODGRPPARAM cd, codparam c, desparam d, codparam_per cp'
               || ' WHERE c.cutili = 8   AND d.cparam = c.cparam ' || vwhere3
               || '   AND cp.cparam = c.cparam and c.cgrppar = cd.cgrppar AND d.cidioma = '
               || pidioma || vwhere || ' )order by norden_agr, decode(e,1,1,2), norden';
         END IF;
      END IF;

      vumerr := pac_log.f_log_consultas(vsquery, 'PAC_PERSONA.F_GET_PARPERSONA', 1);
      psquery := vsquery;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_get_parpersona', 1, SQLCODE, SQLERRM);
         RETURN SQLCODE;
   END f_get_parpersona;

/*************************************************************************/
/*************************************************************************
Obté la select amb els paràmetres per persona
   pcparam IN NUMBER,
   pcidioma in number,
param out psquery   : Select
return              : 0.- OK, 1.- KO
*************************************************************************/
   FUNCTION f_get_obparpersona(pcparam IN VARCHAR2, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vtabla         VARCHAR2(500);
      vwhere         VARCHAR2(5000);
   BEGIN
      vsquery :=
         'SELECT c.cutili, c.cparam, c.ctipo, d.tparam, cp.cvisible, cp.ctipper, null, null,null ,'
         || ' null resp' || ' FROM codparam c, desparam d, codparam_per cp '
         || ' WHERE c.cutili = 8  AND d.cparam = c.cparam'
         || ' AND cp.cparam = c.cparam and c.cparam = ''' || pcparam || ''' AND d.cidioma = '
         || pcidioma;
      /**/
      /* Ini Bug 22053 - MDS - 27/04/2012*/
      vsquery := vsquery || ' ORDER BY NVL(C.NORDEN,0)';
      /* Ini Bug 22053 - MDS - 27/04/2012*/
      /**/
      psquery := vsquery;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_get_obparpersona', 1, SQLCODE, SQLERRM);
         RETURN SQLCODE;
   END f_get_obparpersona;

   /*************************************************************************
   Inserta el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numérica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      ptablas IN VARCHAR2,
      perrores OUT t_ob_error)   /* BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA*/
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      vcagente_visio NUMBER;
      vcagente_per   NUMBER;
      verr           ob_error;
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
      /* Cambios de IAXIS-4844 : start */
    VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    /* Cambios de IAXIS-4844 : end */

   BEGIN
      perrores := t_ob_error();
      perrores.DELETE;

      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF ptablas = 'EST' THEN
         pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per, 'EST');
      END IF;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pnvalpar IS NULL
         AND pfvalpar IS NULL THEN
         IF ptablas = 'EST' THEN
            INSERT INTO estper_parpersonas
                        (sperson, cagente, cparam, tvalpar)
                 VALUES (psperson, vcagente_per, pcparam, ptvalpar);
         ELSE
            INSERT INTO per_parpersonas
                        (sperson, cagente, cparam, tvalpar)
                 VALUES (psperson, pcagente, pcparam, ptvalpar);

         END IF;
      ELSIF vctipo IN(2, 4, 5)
            AND ptvalpar IS NULL
            AND pnvalpar IS NOT NULL
            AND pfvalpar IS NULL THEN
         IF ptablas = 'EST' THEN
            INSERT INTO estper_parpersonas
                        (sperson, cagente, cparam, nvalpar)
                 VALUES (psperson, vcagente_per, pcparam, pnvalpar);
         ELSE
            INSERT INTO per_parpersonas
                        (sperson, cagente, cparam, nvalpar)
                 VALUES (psperson, pcagente, pcparam, pnvalpar);
         END IF;
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pnvalpar IS NULL
            AND pfvalpar IS NOT NULL THEN
         IF ptablas = 'EST' THEN
            INSERT INTO estper_parpersonas
                        (sperson, cagente, cparam, fvalpar)
                 VALUES (psperson, vcagente_per, pcparam, pfvalpar);
         ELSE
            INSERT INTO per_parpersonas
                        (sperson, cagente, cparam, fvalpar)
                 VALUES (psperson, pcagente, pcparam, pfvalpar);
         END IF;
      ELSE
         RETURN 9001781;
      END IF;

      /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
      IF ptablas <> 'EST'
         AND NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                               'MODIF_PERSONA_HOST'),
                 0) = 1 THEN
         num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

         IF num_err <> 0 THEN
            /*i:= i + 1;*/
            RETURN num_err;
         END IF;

        /* Cambios de IAXIS-4844 : start */
    BEGIN
    SELECT PP.NNUMIDE,PP.TDIGITOIDE
      INTO VPERSON_NUM_ID,VDIGITOIDE
      FROM PER_PERSONAS PP
     WHERE PP.SPERSON = psperson
       AND ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT PP.CTIPIDE, PP.NNUMIDE
      INTO VCTIPIDE, VPERSON_NUM_ID
      FROM PER_PERSONAS PP
       WHERE PP.SPERSON = psperson;
      VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                             UPPER(VPERSON_NUM_ID));
    END;
  /* Cambios de IAXIS-4844 : end */

         /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
         v_host := NULL;

         /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
         IF pac_persona.f_gubernamental(psperson) = 1 THEN
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'DUPL_DEUDOR_HOST');
         END IF;
        /* Cambios de IAXIS-4844 : start */
         num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                           vcterminal, psinterf, terror,
                                           pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOIDE, v_host);
        /* Cambios de IAXIS-4844 : end */

         /* BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA*/
         IF num_err <> 0 THEN
            perrores.EXTEND;
            verr := ob_error.instanciar(num_err, terror);
            perrores(1) := verr;
            /*añado error del tmenin*/
            verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                        pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
            perrores.EXTEND;
            perrores(2) := verr;
            RETURN num_err;
         END IF;

         /* FIN BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA*/
         /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
           /* Por defecto se envía el acreedor con la cuenta P004*/
         v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'ALTA_PROV_HOST');

         /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
         IF v_host IS NOT NULL THEN
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_ACREEDOR_HOST');
            END IF;

            psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
            num_err := pac_user.f_get_terminal(f_user, vcterminal);
            /* Cambios de IAXIS-4844 : start */
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                              v_host);
            /* Cambios de IAXIS-4844 : end */
         END IF;

         IF num_err <> 0 THEN
            perrores.EXTEND;
            verr := ob_error.instanciar(num_err, terror);
            perrores(1) := verr;
            /*añado error del tmenin*/
            verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                        pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
            perrores.EXTEND;
            perrores(2) := verr;
            RETURN num_err;
         END IF;
      /*fin BUG 0026318 -- GGR -- 17/03/2014*/
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pnvalpar IS NULL
               AND pfvalpar IS NULL THEN
               IF ptablas = 'EST' THEN
                  UPDATE estper_parpersonas
                     SET tvalpar = ptvalpar
                   WHERE sperson = psperson
                     AND cparam = pcparam
                     AND cagente = pcagente;
               ELSE
                  UPDATE per_parpersonas
                     SET tvalpar = ptvalpar
                   WHERE sperson = psperson
                     AND cparam = pcparam
                     AND cagente = pcagente;
               END IF;
            /* bug 24764-133188*/
            ELSIF vctipo IN(2, 4, 5)
                  AND ptvalpar IS NULL
                  AND pnvalpar IS NOT NULL
                  AND pfvalpar IS NULL THEN
               IF ptablas = 'EST' THEN
                  UPDATE estper_parpersonas
                     SET nvalpar = pnvalpar
                   WHERE sperson = psperson
                     AND cparam = pcparam
                     AND cagente = pcagente;
               ELSE
                  UPDATE per_parpersonas
                     SET nvalpar = pnvalpar
                   WHERE sperson = psperson
                     AND cparam = pcparam
                     AND cagente = pcagente;
               END IF;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pnvalpar IS NULL
                  AND pfvalpar IS NOT NULL THEN
               IF ptablas = 'EST' THEN
                  UPDATE estper_parpersonas
                     SET fvalpar = pfvalpar
                   WHERE sperson = psperson
                     AND cparam = pcparam
                     AND cagente = pcagente;
               ELSE
                  UPDATE per_parpersonas
                     SET fvalpar = pfvalpar
                   WHERE sperson = psperson
                     AND cparam = pcparam
                     AND cagente = pcagente;
               END IF;
            ELSE
               RETURN 9001781;
            END IF;

            /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
            IF ptablas <> 'EST'
               AND NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                     'MODIF_PERSONA_HOST'),
                       0) = 1 THEN
               num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

               IF num_err <> 0 THEN
                  /*i:= i + 1;*/
                  RETURN num_err;
               END IF;

               /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
               v_host := NULL;

               /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_DEUDOR_HOST');
               END IF;
                /* Cambios de IAXIS-4844 : start */
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOIDE,
                                                 v_host);
                /* Cambios de IAXIS-4844 : end */

               /* BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA*/
               IF num_err <> 0 THEN
                  perrores.EXTEND;
                  verr := ob_error.instanciar(num_err, terror);
                  perrores(1) := verr;
                  /*añado error del tmenin*/
                  verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                              pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                  perrores.EXTEND;
                  perrores(2) := verr;
                  RETURN num_err;
               END IF;

               /* FIN BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA*/
               /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
                 /* Por defecto se envía el acreedor con la cuenta P004*/
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'ALTA_PROV_HOST');

               /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
               IF v_host IS NOT NULL THEN
                  IF pac_persona.f_gubernamental(psperson) = 1 THEN
                     v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                             'DUPL_ACREEDOR_HOST');
                  END IF;

                  psinterf := NULL;
                  /* Se inicia para que genere un nuevo codigo*/
                  num_err := pac_user.f_get_terminal(f_user, vcterminal);
                  /* Cambios de IAXIS-4844 : start */
                  num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                    vcterminal, psinterf, terror,
                                                    pac_md_common.f_get_cxtusuario, 1, 'MOD',
                                                    VDIGITOIDE, v_host);
                    /* Cambios de IAXIS-4844 : end */
               END IF;

               IF num_err <> 0 THEN
                  perrores.EXTEND;
                  verr := ob_error.instanciar(num_err, terror);
                  perrores(1) := verr;
                  /*añado error del tmenin*/
                  verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                              pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
                  perrores.EXTEND;
                  perrores(2) := verr;
                  RETURN num_err;
               END IF;
            /*fin BUG 0026318 -- GGR -- 17/03/2014*/
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_persona.f_ins_parpersona', 1,
                           'when others pcparam =' || pcparam, SQLERRM);
               RETURN 9001781;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_persona.f_ins_parpersona', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 9001781;
   END f_ins_parpersona;

   /*************************************************************************
   Esborra el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      ptablas IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         IF psperson IS NOT NULL
            AND pcparam IS NOT NULL
            AND pcagente IS NOT NULL THEN
            DELETE FROM estper_parpersonas
                  WHERE sperson = psperson
                    AND cparam = pcparam
                    AND cagente = pcagente;

            RETURN 0;
         ELSIF psperson IS NOT NULL
               AND pcagente IS NOT NULL THEN
            DELETE FROM estper_parpersonas
                  WHERE sperson = psperson
                    AND cagente = pcagente;
         ELSE
            RETURN 9001781;
         END IF;
      ELSE
         IF psperson IS NOT NULL
            AND pcparam IS NOT NULL
            AND pcagente IS NOT NULL THEN
            DELETE FROM per_parpersonas
                  WHERE sperson = psperson
                    AND cparam = pcparam
                    AND cagente = pcagente;

            RETURN 0;
         ELSIF psperson IS NOT NULL
               AND pcagente IS NOT NULL THEN
            DELETE FROM per_parpersonas
                  WHERE sperson = psperson
                    AND cagente = pcagente;
         ELSE
            RETURN 9001781;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_persona.f_del_parpersona', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 9001781;
   END f_del_parpersona;

   /*Fi BUG 10371 - JTS - 09/06/2009*/
   /*************************************************************************
    Devuelve el idioma del agente
    param in pcagente   : Codi agente
    param out pcidioma  : Idioma del agente
    return              : 0.- OK, 1.- KO

    Bug 10684 - 21/12/2009 - AMC
    *************************************************************************/
   FUNCTION f_get_idioma_age(pcagente IN NUMBER, pcidioma OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT e.cidioma
        INTO pcidioma
        FROM agentes a, per_detper e
       WHERE a.cagente = pcagente
         AND a.sperson = e.sperson;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pcidioma := NULL;
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_persona.f_get_idioma_age', 1,
                     'when others pcagente =' || pcagente, SQLERRM);
         RETURN 1;
   END f_get_idioma_age;

   /***********************************************************************
      Traspàs d'una determinada adreça a una determinada persona (taules EST)
      param in psperson_desti   : persona destí a la que se li assignarà l'adreça
      param in pcagente         : agent de visió a la qual se li ha d'assignar l'adreça
      param in pcidioma         : idioma
      param in psperson_origen  : adreça origen
      param in pcdomici_origen  : adreça origen
      param in pcdelete         : flag (0/1) per indicar si cal esborrar les adreces que ja tingui la persona
      return                    : O -> Tot ok
                                  codi_error -> Error
   ***********************************************************************/
   FUNCTION f_traspaso_direccion_fija(
      psperson_desti IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      psperson_origen IN NUMBER,
      pcdomici_origen IN NUMBER,
      pcdelete IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psperson_desti=' || psperson_desti || 'pcagente=' || pcagente || 'pcidioma='
            || pcidioma || ' psperson_origen=' || psperson_origen || ' pcdomici_origen='
            || pcdomici_origen;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_traspaso_direccion_fija';
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcdomici       per_direcciones.cdomici%TYPE;
      verrores       t_ob_error;
   BEGIN
      /* Control parametros entrada*/
      IF psperson_desti IS NULL
         OR psperson_origen IS NULL
         OR pcdomici_origen IS NULL
         OR pcagente IS NULL
         OR pcidioma IS NULL
         OR pcdelete IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(9000505));
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      vpasexec := 3;

      /*Comprovem si cal esborrar les adreces prèviament traspassades per la persona.*/
      IF pcdelete = 1 THEN
         DELETE FROM estper_direcciones
               WHERE sperson = psperson_desti;
      END IF;

      vpasexec := 5;

      /*Recuperem l'adreça fixe que volem traspassar (origen).*/
      /* Bug 18940/92686 - 27/09/2011 - AMC*/
      FOR cr_dir IN (SELECT p.sperson, p.cagente, p.cdomici, p.ctipdir, p.csiglas, p.tnomvia,
                            p.nnumvia, p.tcomple, p.tdomici, p.cpostal, p.cpoblac, p.cprovin,
                            p.cviavp, p.clitvp, p.cbisvp, p.corvp, p.nviaadco, p.clitco,
                            p.corco, p.nplacaco, p.cor2co, p.cdet1ia, p.tnum1ia, p.cdet2ia,
                            p.tnum2ia, p.cdet3ia, p.tnum3ia, p.localidad,
                            p.fdefecto   /* Bug 24780/130907 - 05/12/2012 - AMC*/
                       FROM per_direcciones p
                      WHERE p.sperson = psperson_origen
                        AND p.cdomici = pcdomici_origen) LOOP
         vpasexec := 7;
         /*Traspassem l'adreça origen, a la persona destí.*/
         pac_persona.p_set_direccion(psperson_desti, pcagente, vcdomici, cr_dir.ctipdir,
                                     cr_dir.csiglas, cr_dir.tnomvia, cr_dir.nnumvia,
                                     cr_dir.tcomple, cr_dir.tdomici, cr_dir.cpostal,
                                     cr_dir.cpoblac, cr_dir.cprovin, f_user, f_sysdate,
                                     pcidioma, verrores, 'EST', cr_dir.cviavp, cr_dir.clitvp,
                                     cr_dir.cbisvp, cr_dir.corvp, cr_dir.nviaadco,
                                     cr_dir.clitco, cr_dir.corco, cr_dir.nplacaco,
                                     cr_dir.cor2co, cr_dir.cdet1ia, cr_dir.tnum1ia,
                                     cr_dir.cdet2ia, cr_dir.tnum2ia, cr_dir.cdet3ia,
                                     cr_dir.tnum3ia, cr_dir.localidad,
                                     cr_dir.fdefecto   /* Bug 24780/130907 - 05/12/2012 - AMC*/
                                                    );

         /*Comprovació d'errors*/
         IF verrores IS NOT NULL THEN
            IF verrores.COUNT > 0 THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN 140269;
            END IF;
         END IF;
      END LOOP;

      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 140269;
   END f_traspaso_direccion_fija;

   /* BUG14307:DRA:11/05/2010:Inici*/
   /**************************************************************
     Funció que valida si un numero de CASS té el format correcte
   **************************************************************/
   FUNCTION f_valida_cass(pnumcass IN VARCHAR2)
      RETURN NUMBER IS
      /**/
      TYPE t_digits IS TABLE OF NUMBER(1)
         INDEX BY BINARY_INTEGER;

      v_digit        t_digits;
      v_ndespl       NUMBER(1);
      v_ndigitcheck  NUMBER;
      v_tdigitcheck  CHAR(1);
      v_naux         NUMBER(1);
   BEGIN
      /* Busquem a partir de quin dígit comencem*/
      /*SELECT DECODE(LENGTH(RTRIM(pnumcass)), 7, 0, 15, 8, 1),
             DECODE(SUBSTR(pnumcass, 1, 1), '9', 0, 1)
        INTO v_ndespl,
             v_naux
        FROM DUAL;*/
          /*Ini Bug.: 13422 - ICV - 01/03/2010 -- El cass ha de ser de 7 digitos*/
      SELECT DECODE(LENGTH(RTRIM(pnumcass)), 7, 0, 1),
             DECODE(SUBSTR(pnumcass, 1, 1), '9', 0, 1)
        INTO v_ndespl,
             v_naux
        FROM DUAL;

      /*Fin Bug.: 13422*/
      /* Si no té la longitud correcta, sortim amb error (aprofitem la variable v_ndespl)*/
      IF v_ndespl = 1 THEN
         RETURN 9001666;   /* BUG10320:DRA:02/06/2009*/
      END IF;

      /* Informem els digits X1 X2 X3 X4 X5 X6*/
      FOR i IN 1 .. 6 LOOP
         v_digit(i) := SUBSTR(pnumcass, i + v_ndespl, 1);
      END LOOP;

      IF v_digit(1) = 9 THEN
         v_ndigitcheck :=(v_digit(1) * 1000);
      ELSE
         v_ndigitcheck :=((v_digit(1) + 1) * 1000);
      END IF;

      /* Calculem el dígit de control N7 ó N15*/
      v_ndigitcheck := v_ndigitcheck -(v_digit(2) * 100) +(v_digit(3) * 100) -(v_digit(4) * 10)
                       +(v_digit(5) * 10) - v_digit(6);
      v_ndigitcheck := ABS(MOD(v_ndigitcheck, 23)) + 1;

      /* Apliquem taula de conversió*/
      SELECT DECODE(v_ndigitcheck,
                    1, 'A',
                    2, 'B',
                    3, 'C',
                    4, 'D',
                    5, 'E',
                    6, 'F',
                    7, 'G',
                    8, 'H',
                    9, 'J',
                    10, 'K',
                    11, 'L',
                    12, 'M',
                    13, 'N',
                    14, 'P',
                    15, 'R',
                    16, 'S',
                    17, 'T',
                    18, 'U',
                    19, 'V',
                    20, 'W',
                    21, 'X',
                    22, 'Y',
                    23, 'Z')
        INTO v_tdigitcheck
        FROM DUAL;

      /* Comparem resultat amb dígit control d'entrada (Si el d'entrada és en minúscula,*/
      /* retornarà diferent)*/
      IF v_tdigitcheck <> SUBSTR(RTRIM(pnumcass), -1, 1) THEN
         RETURN 9001666;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_valida_cass', NULL, SQLCODE, SQLERRM);
         RETURN 9001667;
   END f_valida_cass;

   /* BUG14307:DRA:11/05/2010:Fi*/
   /*************************************************************************
     FUNCTION función que nos comprueba si la persona tiene el mismo nnumide
     param in pnnumide    : Nnumide que vamos a comprobar
     param out pduplicada : Miramos si esta duplicada
     return           : código de error

      ---- Bug 17563 : AGA800 - data naixement - 08/03/2011 - XPL
   *************************************************************************/
   FUNCTION f_persona_duplicada(
      psperson IN NUMBER,
      pnnumide IN VARCHAR2,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      psnip IN VARCHAR2,
      pcagente IN NUMBER,
      pswpubli IN NUMBER,
      pctipide IN NUMBER,
      pduplicada OUT NUMBER,
      psolicit IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros -  ppnnumide: ' || pnnumide;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_persona_duplicada';
      vsperson       NUMBER(8);
      vpervisionpublica NUMBER;   /* Bug 29166/160964 - 09/12/2013 - AMC*/
   BEGIN
      BEGIN
         /* Bug 29166/160964 - 09/12/2013 - AMC*/
         vpervisionpublica :=
            NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'PER_VISIONPUBLICA'),
                0);

         /*miramos si existe alguna persona con el mismo nnumide*/
         SELECT SUM(suma)
           INTO pduplicada
           FROM (SELECT COUNT(1) suma
                   FROM per_personas p, per_detper pd
                  WHERE (nnumide = UPPER(pnnumide))   -- Bug 43040 - 30/05/2016 - AMC
                    /* Bug 35888/205345 Realizar la substitución del upper nnumide - CJMR*/
                    AND p.sperson = pd.sperson
                    AND(pswpubli IS NULL
                        OR p.swpubli = DECODE(vpervisionpublica, 1, p.swpubli, pswpubli))
                    AND pd.cagente IN(SELECT aa.cagente
                                        FROM agentes_agente aa)
                    AND((NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                           'EXIST_PERS_CTIPIDE'),
                             0) = 1
                         AND ctipide = pctipide)
                        OR NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                             'EXIST_PERS_CTIPIDE'),
                               0) = 0)
                 UNION ALL
                 SELECT COUNT(1) suma
                   /*INTO pduplicada*/
                 FROM   estper_personas p, estper_detper pd
                  WHERE (nnumide = UPPER(pnnumide))   -- Bug 43040 - 30/05/2016 - AMC
                    /* Bug 35888/205345 Realizar la substitución del upper nnumide - CJMR*/
                    AND p.sperson = pd.sperson
                    AND(pswpubli IS NULL
                        OR p.swpubli = DECODE(vpervisionpublica, 1, p.swpubli, pswpubli))
                    /*BUG 29268/160635 - 05/12/2013 - RCL - No permitir duplicar la persona en simulación.*/
                    AND((p.sseguro = psolicit
                         AND p.cestper = 99)   /* Personas de simulacion*/
                        OR((p.sseguro = psolicit
                            OR psolicit IS NULL)
                           AND p.cestper != 99))   /* Personas de nueva produccion*/
                    AND pd.cagente IN(SELECT aa.cagente
                                        FROM agentes_agente aa)
                    AND((NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                           'EXIST_PERS_CTIPIDE'),
                             0) = 1
                         AND ctipide = pctipide)
                        OR NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                             'EXIST_PERS_CTIPIDE'),
                               0) = 0));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pduplicada := 0;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_persona_duplicada', NULL, SQLCODE,
                     SQLERRM);
         RETURN 100534;
   END f_persona_duplicada;

   /**************************************************************
     Funció que nos devolerá el agente del detalle de la persona que el agente del usuario conectado
     puede visualizar.
   **************************************************************/
   FUNCTION f_get_agente_detallepersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
              := 'psperson=' || psperson || 'pcagente=' || pcagente || 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_cagente_detallepersona';
      vcagente_visio agentes.cagente%TYPE;
      vcagente_per   agentes.cagente%TYPE;
      vcdomici       per_direcciones.cdomici%TYPE;
      verrores       t_ob_error;
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pcagente IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(9000505));
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      SELECT p.cagente
        INTO vcagente_per
        FROM per_detper p, per_personas pp
       WHERE p.sperson = psperson
         AND p.sperson = pp.sperson
         AND((pp.swpubli = 1   /*Bug 17953#16032011#xpl inici*/
              AND p.cagente = pac_persona.f_buscaagente_publica(pp.sperson))
             OR(pp.swpubli = 0
                AND p.fmovimi = (SELECT MAX(fmovimi)   /*bug 24822*/
                                   FROM per_detper dd, agentes_agente aa2
                                  WHERE dd.sperson = p.sperson
                                    AND dd.cagente = aa2.cagente)));   /* Bug 24822*/

      /*                AND p.cagente IN(SELECT     r.cagente*/
      /*                                       FROM redcomercial r*/
      /*                                      WHERE fmovfin IS NULL*/
      /*                                        AND cempres = pcempres*/
      /*                                        AND LEVEL =*/
      /*                                              DECODE(ff_agente_cpernivel(pcagente),*/
      /*                                                     1, LEVEL,*/
      /*                                                     1)*/
      /*                                 START WITH cagente = ff_agente_cpervisio(pcagente)*/
      /*                                 CONNECT BY PRIOR cagente = cpadre*/
      /*                                        AND PRIOR fmovfin IS NULL)*/
      /*                -- La persona es privada y miramos si tenemos acceso a ver estos datos.*/
      /*                AND p.fmovimi IN(*/
      /*                      SELECT MAX(fmovimi)*/
      /*                        FROM per_detper dd*/
      /*                       WHERE dd.sperson = p.sperson*/
      /*                         AND dd.cagente IN(SELECT     r.cagente*/
      /*                                                 FROM redcomercial r*/
      /*                                                WHERE fmovfin IS NULL*/
      /*                                                  AND cempres = pcempres*/
      /*                                                  AND LEVEL =*/
      /*                                                        DECODE(ff_agente_cpernivel(pcagente),*/
      /*                                                               1, LEVEL,*/
      /*                                                               1)*/
      /*                                           START WITH cagente = ff_agente_cpervisio(pcagente)*/
      /*                                           CONNECT BY PRIOR cagente = cpadre*/
      /*                                                  AND PRIOR fmovfin IS NULL))*/
      /*Si hay mas de un detalle cogemos el más nuevo*/
      /*               ));*/
      IF vcagente_per IS NULL THEN
         pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per,
                                     ptablas);
      END IF;

      RETURN vcagente_per;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_get_agente_detallepersona;

   /**************************************************************
   Procedimiento para borrar una persona relacionada
   Bug.: 18941
   /**************************************************************/
   PROCEDURE p_del_persona_rel(
      psperson IN per_personas_rel.sperson%TYPE,
      pcagente IN per_personas_rel.cagente%TYPE,
      psperson_rel IN per_personas_rel.sperson_rel%TYPE,
      pcagrupa IN per_personas_rel.cagrupa%TYPE, --IAXIS-3670 16/04/2019 AP
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      i              NUMBER := 1;
      verr           ob_error;
      num_error      NUMBER; -- TCS-460 01/02/2019
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF ptablas != 'EST' THEN   --La parte de las EST de momento no se hace
         BEGIN
            DELETE FROM per_personas_rel
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND sperson_rel = psperson_rel
                    AND cagrupa = pcagrupa; --IAXIS-3670 16/04/2019 AP
      --
            -- Inicio TCS-460 01/02/2019
            --
            num_error := f_pagador_alt(psperson     => psperson,
                                       psperson_rel => psperson_rel,
                                       pcoperacion  => 2);
            --
            -- Fin TCS-460 01/02/2019
            --
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180031,
                                           f_axis_literales(180031, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(180031,
                                     f_axis_literales(180031, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
   END p_del_persona_rel;

   /**************************************************************
   Procedimiento para borrar una persona relacionada
   Bug.: 18941
   /**************************************************************/
   FUNCTION f_set_persona_rel(
      psperson          IN       NUMBER,
      pcagente          IN       NUMBER,
      psperson_rel      IN       NUMBER,
      pctipper_rel      IN       NUMBER,
      ppparticipacion   IN       NUMBER,
      pislider          IN       NUMBER,     -- BUG 0030525 - FAL - 01/04/2014
      errores           IN OUT   t_ob_error,
      ptablas           IN       VARCHAR2 DEFAULT 'EST',
      ptlimit           IN       VARCHAR2,
      pcagrupa          IN       NUMBER,
      pfagrupa          IN       DATE
   )
      RETURN NUMBER
   IS
      j            NUMBER   := 1;
      verr         ob_error;
      vsum         NUMBER;
      v_numlider   NUMBER;                  -- BUG 0030525 - FAL - 01/04/2014
      v_dupli      NUMBER := 0; --TCS 468A 17/01/2019 AP
      vsum_consor  NUMBER := 0; --TCS 468A 17/01/2019 AP
      dupl_consorcio NUMBER := 0;
      vnumerr1    NUMBER := 0;
      vnumerr2    NUMBER := 0;
      num_error    NUMBER; -- TCS-460 01/02/2019
-------------------Changes started for Iaxis-3981(11/06/2019)---------------------
      v_nmovimi        NUMBER;
      
      v_holding  NUMBER; -- Ini IAXIS-13233 -- ECP -- 25/03/2020

      CURSOR c2
      IS
         --THis query extracts the Consortia business rules
         SELECT 24 cempress, c.tatribu area, a.cmarca cmarca,
                a.descripcion descripcion,
                DECODE (b.ctipo,
                        0, '||''' || 'Manual' || '''||',
                           '||
                                 '''
                        || 'Automatica'
                        || '''||'
                       ) tipo,
                a.caacion, d.tatribu accion
           FROM agr_marcas a, per_agr_marcas b, detvalores c, detvalores d
          WHERE a.cempres = b.cempres
            AND a.cmarca = b.cmarca
            AND a.cempres = '24'
            AND b.sperson = psperson                     ----Consortia SPERSON
            ---------in (280834,281013,281484,4000312)
            AND a.carea = c.catribu
            AND c.cvalor = 8002004
            AND c.cidioma = pac_md_common.f_get_cxtidioma
            AND a.caacion = d.catribu
            AND d.cvalor = 8002008
            ----- AND d.catribu =0
            ----- and d.tatribu like '%Miembro de consorcio%'
            AND d.cidioma = pac_md_common.f_get_cxtidioma
            AND b.nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM per_agr_marcas e
                     WHERE b.cempres = e.cempres
                       AND b.cmarca = e.cmarca
                       AND b.sperson = e.sperson);                         --C
----------------------------- Changes Ends Iaxis-3981(11/06/2019)-------------------------------
   BEGIN
      errores := t_ob_error ();
      errores.DELETE;

      ----25959
      -- Ini IAXIS-13233 -- ECP -- 25/03/2020
      ----25959
      IF (psperson = psperson_rel) AND (pctipper_rel != 0 and pctipper_rel != 7)
      THEN
         RETURN 9904948;
      ELSE

       -- INI CP0363M_SYS_PERS - JLTS - 27/12/2018 - Se ajusta el código para que controle el porcentaje de participación
       --     independiente del tipo de relación.

       --comprobar el porcentaje de participación
       IF pctipper_rel IS NOT NULL AND ppparticipacion IS NOT NULL THEN
         IF ppparticipacion > 100 OR ppparticipacion < 0 OR ppparticipacion = 0 THEN
           RETURN 9901044;
         END IF;
         -- FI BUG 0029035 - FAL - 21/05/2014
       END IF;
       --INI TCS 468A 17/01/2019 AP
       IF pctipper_rel = 0 THEN

          BEGIN ----NO PUEDE ESTAR DUPLICADO EN EL MISMA AGRUPACION
                  SELECT COUNT(*)
                     INTO v_dupli
                     FROM per_personas_rel
                    WHERE sperson_rel = psperson_rel
                      AND sperson = psperson
                      AND cagrupa = pcagrupa;
          EXCEPTION WHEN OTHERS THEN
            v_dupli :=0;
          END;
          BEGIN --VALIDACION DE % PARTICIPACION X CONSORCIO 
                    SELECT SUM(pparticipacion)
                          INTO vsum_consor
                       FROM per_personas_rel
                      WHERE cagrupa = pcagrupa
                        AND sperson = psperson;
          EXCEPTION WHEN OTHERS THEN
                vsum_consor :=0;
          END; 

          vnumerr1 := F_CONSORCIO (psperson_rel);

          IF vnumerr1 <> 0 THEN
            RETURN 89906268;
          END IF; 
          ---
          vnumerr2 := F_CONSORCIO (psperson);

          IF vnumerr2 = 0 THEN
            RETURN 9910286;
          END IF;
        --INICIA VALIDACIONES DE CONSORCIOS IAXIS-3670 16/04/2019 AP
            IF ppparticipacion IS NULL OR ppparticipacion = 100 OR ppparticipacion > 100 THEN -- El porcentaje no puede ser menor de 0 o mayor que 100.
                RETURN 9904942;
            ELSIF v_dupli > 0 THEN --NO PUEDE ESTAR DUPLICADO EN EL MISMA AGRUPACION
                RETURN 9906277;
            ELSIF psperson = psperson_rel THEN --EL CONSORCIO NO PUEDE PARTICIPAR
                RETURN 806245;
            ELSIF (nvl(vsum_consor,0) + ppparticipacion) > 100 THEN -- EL CONSORCIO NO PUEDE SUPERAR EL 100
                       RETURN 104808;
            END IF;
        END IF;
       --FIN TCS 468A 17/01/2019 AP
       IF pctipper_rel IN (3,
                           5) -- BUG 0030525 - FAL - 01/04/2014
          AND ppparticipacion IS NOT NULL THEN
         SELECT SUM(pparticipacion)
           INTO vsum
           FROM per_personas_rel
          WHERE sperson = psperson
            AND cagente = pcagente
            AND ctipper_rel = pctipper_rel
               -- 3  -- BUG 0030525 - FAL - 01/04/2014
            AND pparticipacion IS NOT NULL;

         IF (nvl(vsum,
                 0) + ppparticipacion) > 100 THEN
           RETURN 104808;
         END IF;
         
         -- BUG 0030525 - FAL - 01/04/2014
         IF pctipper_rel = 5 THEN
           v_numlider := 0;

           SELECT COUNT(1)
             INTO v_numlider
             FROM per_personas_rel
            WHERE sperson = psperson
              AND cagente = pcagente
              AND ctipper_rel = pctipper_rel
                 -- BUG 0030525 - FAL - 01/04/2014
              AND islider = 1;

           IF v_numlider > 0 THEN
             RETURN 9906675;
           END IF;
         END IF;
         -- FI BUG 0030525 - FAL - 01/04/2014
         -- BUG 0029035 - FAL - 21/05/2014
       END IF;
       -- Ini IAXIS-13233 -- ECP-- 25/03/2020
--         p_tab_error (f_sysdate,
--                      f_user,
--                      'pac_persona',
--                      1,
--                      'Holding',
--                         ' v_holding-->'
--                      || v_holding

--                      || ' pctipper_rel-->'
--                      ||pctipper_rel
--                      || 'psperson '
--                      ||psperson
--                     );
          
         BEGIN
                  SELECT ctipper_rel
                     INTO v_holding
                     FROM per_personas_rel
                    WHERE sperson = psperson
                      and ctipper_rel = 7;
          EXCEPTION WHEN NO_DATA_FOUND THEN
            v_holding :=0;
          END;
--          p_tab_error (f_sysdate,
--                      f_user,
--                      'pac_persona',
--                      1,
--                      'Holding',
--                         ' v_holding-->'
--                      || v_holding

--                      || ' pctipper_rel-->'
--                      ||pctipper_rel
--                      || 'psperson '
--                      ||psperson
--                     );
--                     
                     
          if v_holding = 7  then
            if pctipper_rel != 8 then
             RETURN 89908037;
            elsif  pctipper_rel = 0 then
             RETURN 89908037;
               elsif pctipper_rel = 2 then
             RETURN 89908037;
             elsif pctipper_rel = 5 then
             RETURN 89908037;
             end if;
          end if;
         -- Fin IAXIS-13233 -- ECP-- 25/03/2020
       -- FIN CP0363M_SYS_PERS - JLTS - 27/12/2018 - Se ajusta el código para que controle el porcentaje de participación
       --     independiente del tipo de relación.

       IF ptablas != 'EST' THEN
         --De momento para las EST no se hace
         INSERT INTO per_personas_rel
           (sperson,
            cagente,
            sperson_rel,
            ctipper_rel,
            pparticipacion,
            islider,
            tlimita,
            cagrupa,
            fagrupa, CUSUARI, FMOVIMI)
         VALUES
           (psperson,
            pcagente,
            psperson_rel,
            pctipper_rel,
            ppparticipacion,
            pislider,
            ptlimit,
            pcagrupa,
            pfagrupa, f_user, f_sysdate);
     --
         -- Inicio TCS-460 01/02/2019
         --
         num_error := f_pagador_alt(psperson     => psperson,
                                    psperson_rel => psperson_rel,
                                    pctipper_rel => pctipper_rel,
                                    pcoperacion  => 1);
         --
         -- Fin TCS-460 01/02/2019
         --
         -- Fin IAXIS-13233 -- ECP -- 25/03/2020
       END IF;
       IF pislider = 1 THEN
         --UPDATE VALIDACION DE FECHA AGRUPACION CONSORCIO
         UPDATE per_personas_rel
            SET fagrupa = pfagrupa
          WHERE sperson = psperson
            AND cagente = pcagente
            AND cagrupa = pcagrupa;
       END IF;
     END IF;


-------------------Changes started for Iaxis-3981(11/06/2019)---------------------
      IF pctipper_rel = 0
      THEN                                        --Only for consortia members
         BEGIN
            BEGIN
               SELECT MAX (nmovimi) + 1
                 INTO v_nmovimi
                 FROM per_agr_marcas
                WHERE sperson = psperson_rel;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_nmovimi := 1;
            END;

            FOR i IN c2
            LOOP
               BEGIN
                  INSERT INTO per_agr_marcas
                              (cempres, sperson, cmarca,
                               nmovimi, ctipo, ctomador, cconsorcio,
                               casegurado, ccodeudor, cbenef, caccionista,
                               cintermed, crepresen, capoderado, cpagador,
                               observacion, cuser, falta, cproveedor
                              )
                       VALUES (i.cempress, psperson_rel, i.cmarca,
                               v_nmovimi, 1, 1, 1,
                               0, 0, 0, 0,
                               0, 0, 0, 0,
                               NULL, f_user, TRUNC (f_sysdate), 0
                              );
               END;

               COMMIT;
            END LOOP;
         END;
      END IF;

--------------------------Changes Ends Iaxis-3981(11/06/2019)----------

     RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             'PAC_PERSONA',
             1,
             'f_set_persona_rel.Error Imprevisto insertando persona relacionada.',
             SQLERRM
            );
         RETURN 108468;
      WHEN DUP_VAL_ON_INDEX
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             'PAC_PERSONA',
             1,
             'f_set_persona_rel.Registro duplicado insertanto persona relacionada.',
             SQLERRM
            );
         RETURN 108959;
      WHEN OTHERS
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             'PAC_PERSONA',
             1,
             'f_set_persona_rel.Error Imprevisto insertando persona relacionada.',
             SQLERRM
            );
         RETURN 108468;
   END f_set_persona_rel;

   /**************************************************************
   Procedimiento para borrar una persona relacionada
   Bug.: 18941
   /**************************************************************/
   PROCEDURE p_del_regimenfiscal(
      psperson IN per_personas_rel.sperson%TYPE,
      pcagente IN per_personas_rel.cagente%TYPE,
      pfefecto IN DATE,
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      i              NUMBER := 1;
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF ptablas != 'EST' THEN   --La parte de las EST de momento no se hace
         BEGIN
            DELETE FROM per_regimenfiscal
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND fefecto = pfefecto;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180031,
                                           f_axis_literales(180031, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(180031,
                                     f_axis_literales(180031, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
   END p_del_regimenfiscal;

   /*************************************************************************
       Nueva función que se encarga de insertar el régimen fiscal
       return              : 0 Ok. 1 Error
       Bug.: 18942
      *************************************************************************/
   FUNCTION f_set_regimenfiscal(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      pcregfiscal IN NUMBER,
      pcregfisexeiva IN NUMBER DEFAULT 0,   --AP CONF_190
      pctipiva       IN NUMBER,
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
      j              NUMBER := 1;
      verr           ob_error;
      vcterminal     usuarios.cterminal%TYPE;
      num_err        NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      vcagente_visio NUMBER;
      vcagente_per   NUMBER;
      v_host         VARCHAR2(10);   /*BUG 26318/167380-- GGR -- 17/03/2014*/
      vfefecto       DATE; /* For IAXIS-4728 -- PK -- 05/07/2019 */
    e_fecha_range_error   EXCEPTION; /* For IAXIS-4728 -- PK -- 08/07/2019 */
  /* Cambios de Iaxis-4521 : start */
      VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;    
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
  /* Cambios de Iaxis-4521 : end */ 

   BEGIN
      errores := t_ob_error();
      errores.DELETE;

  /* Cambios de Iaxis-4521 : start */ 
      BEGIN
        SELECT PP.NNUMIDE,PP.TDIGITOIDE
          INTO VPERSON_NUM_ID,VDIGITOIDE
          FROM PER_PERSONAS PP
         WHERE PP.SPERSON = psperson
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SELECT PP.CTIPIDE,pp.nnumide
            INTO VCTIPIDE,VPERSON_NUM_ID
            FROM PER_PERSONAS PP
           WHERE PP.SPERSON = psperson;
          VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                         UPPER(VPERSON_NUM_ID));
      END;  
   /* Cambios de Iaxis-4521 : end */      

      IF ptablas != 'EST' THEN   --De momento para las EST no se hace
            /* Start For IAXIS-4728 -- PK -- 05/07/2019 */
            BEGIN
                IF TRUNC(pfefecto) < TRUNC(SYSDATE) THEN
          RAISE e_param_error;
                END IF;
                --
                SELECT MAX(fefecto) INTO vfefecto
                FROM per_regimenfiscal
                WHERE sperson = psperson AND cagente = pcagente
          AND TO_CHAR(fefecto, 'rrrr') = TO_CHAR(pfefecto, 'rrrr');
                --
                IF TRUNC(pfefecto) BETWEEN TRUNC(SYSDATE) AND TRUNC(vfefecto) THEN
          RAISE e_fecha_range_error; /* For IAXIS-4728 -- PK -- 08/07/2019 */
                END IF;
            END;

            BEGIN
                INSERT INTO per_regimenfiscal
                    (sperson, cagente, anualidad, fefecto, cregfiscal,
                      cregfisexeiva,ctipiva)
                VALUES (psperson, pcagente, TO_CHAR(pfefecto, 'rrrr'), pfefecto, pcregfiscal,
                      pcregfisexeiva, pctipiva);
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    RAISE DUP_VAL_ON_INDEX;
            END;
            /* End For IAXIS-4728 -- PK -- 05/07/2019 */

         /*BUG 19201 - 19/12/2011 - JRB - Se añade llamada al host cuando modificas datos de persona*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'MODIF_PERSONA_HOST'),
                0) = 1
            AND ptablas = 'POL' THEN
            num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, SQLERRM);
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
            v_host := NULL;

            /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
            IF pac_persona.f_gubernamental(psperson) = 1 THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
            END IF;
      /* Cambios de Iaxis-4521 : start */   
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                              vcterminal, psinterf, terror,
                                              pac_md_common.f_get_cxtusuario, 0, 'MOD', VDIGITOIDE,
                                              v_host);
      /* Cambios de Iaxis-4521 : end */   
            IF num_err <> 0 THEN
               /*i:= i + 1;*/
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(j) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               j := j + 1;
               errores(j) := verr;
               RETURN num_err;
            END IF;

            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);
               /* Cambios de Iaxis-4521 : start */           
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
               /* Cambios de Iaxis-4521 : end */                               
            END IF;

            IF num_err <> 0 THEN
               errores.EXTEND;
               verr := ob_error.instanciar(num_err, terror);
               errores(0) := verr;
               /*añado error del tmenin*/
               verr := ob_error.instanciar(pac_con.f_tag(psinterf, 'cerror', 'TMENIN'),
                                           pac_con.f_tag(psinterf, 'terror', 'TMENIN'));
               errores.EXTEND;
               errores(1) := verr;
               RETURN num_err;
            END IF;
         /*fin BUG 0026318 -- GGR -- 17/03/2014*/
         END IF;
      ELSIF ptablas = 'EST' THEN
         BEGIN
            pac_persona.p_busca_agentes(psperson, pcagente, vcagente_visio, vcagente_per,
                                        ptablas);

            INSERT INTO estper_regimenfiscal
                        (sperson, cagente, anualidad, fefecto,
                         cregfiscal, cregfisexeiva,ctipiva)   -- AP CONF-190
                 VALUES (psperson, vcagente_per, TO_CHAR(pfefecto, 'rrrr'), pfefecto,
                         pcregfiscal, pcregfisexeiva,pctipiva);   -- AP CONF-190
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE estper_regimenfiscal
                  SET cregfiscal = pcregfiscal,
                      cregfisexeiva = pcregfisexeiva,   -- AP CONF-190
                      ctipiva = pctipiva--QT-1941
                WHERE sperson = psperson
                  AND cagente = pcagente
                  AND TO_CHAR(fefecto, 'rrrr') = TO_CHAR(pfefecto, 'rrrr');
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error
                   (f_sysdate, f_user, 'PAC_PERSONA', 1,
                    'f_set_regimenfiscal.Error Imprevisto insertando persona régimen fiscal.',
                    SQLERRM);
         /* errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
          errores(j) := verr;*/
         RETURN 108468;
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error
                   (f_sysdate, f_user, 'PAC_PERSONA', 1,
                    'f_set_regimenfiscal.Error Imprevisto insertando persona régimen fiscal.',
                    SQLERRM);
         /*  errores.EXTEND;
         verr := ob_error.instanciar(108959, SQLERRM);
           errores(j) := verr;*/
         RETURN 108959;
        /* Start For IAXIS-4728 -- PK -- 05/07/2019 */
      WHEN e_param_error THEN
         p_tab_error
                   (f_sysdate, f_user, 'PAC_PERSONA', 1,
                    'f_set_regimenfiscal.Error Imprevisto insertando persona régimen fiscal.',
                    SQLERRM);
         RETURN 89906343;
    WHEN e_fecha_range_error THEN
         p_tab_error
                   (f_sysdate, f_user, 'PAC_PERSONA', 1,
                    'f_set_regimenfiscal.Error Imprevisto insertando persona régimen fiscal.',
                    SQLERRM);
         RETURN 89906344;  /* For IAXIS-4728 -- PK -- 08/07/2019 */
      /* End For IAXIS-4728 -- PK -- 05/07/2019 */
      WHEN OTHERS THEN
         p_tab_error
                   (f_sysdate, f_user, 'PAC_PERSONA', 1,
                    'f_set_regimenfiscal.Error Imprevisto insertando persona régimen fiscal.',
                    SQLERRM);
         /*  errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
           errores(j) := verr;*/
         RETURN 108468;
   END f_set_regimenfiscal;

   /*************************************************************************
    Nueva funcion que se encarga de borrar un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_del_sarlaft(
      psperson IN per_personas_rel.sperson%TYPE,
      pcagente IN per_personas_rel.cagente%TYPE,
      pfefecto IN DATE,
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF ptablas != 'EST' THEN
         /* de momento solo se utiliza para las tablas reales, no se hace la parte de las EST*/
         BEGIN
            DELETE FROM per_sarlaft
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND fefecto = pfefecto;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180031,
                                           f_axis_literales(180031, pcidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
               RETURN 180031;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(180031,
                                     f_axis_literales(180031, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
         RETURN 108468;
   END f_del_sarlaft;

   /*************************************************************************
    Nueva funcion que se encarga de insertar un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_set_sarlaft(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      j              NUMBER := 1;
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      /* ini BUG 20846 - MDS - 14/12/2011*/
      /* comprobar que la fecha de efecto no supere la fecha de hoy*/
      IF pfefecto > TRUNC(f_sysdate) THEN
         RETURN 9902903;
      END IF;

      /* fin BUG 20846 - MDS - 14/12/2011*/
      IF ptablas != 'EST' THEN
         /* de momento solo se utiliza para las tablas reales, no se hace la parte de las EST*/
         INSERT INTO per_sarlaft
                     (sperson, cagente, fefecto)
              VALUES (psperson, pcagente, pfefecto);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_sarlaft.Error Imprevisto insertando persona datos sarlaft.',
                     SQLERRM);
         /* errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
          errores(j) := verr;*/
         RETURN 108468;
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_sarlaft.Registro duplicado insertando persona datos sarlaft.',
                     SQLERRM);
         /*  errores.EXTEND;
         verr := ob_error.instanciar(108959, SQLERRM);
           errores(j) := verr;*/
         RETURN 108959;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_sarlaft.Error Imprevisto insertando persona datos sarlaft.',
                     SQLERRM);
         /* errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
          errores(j) := verr;*/
         RETURN 108468;
   END f_set_sarlaft;

   /*************************************************************************
    Nueva funcion que obtiene información de los gestores/empleados de la persona
    param in psperson   : Codigo sperson
    param in pidioma    : Codigo idioma
    param out psquery   : Select
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_gestores_empleados(
      psperson IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_gestores_empleados';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /* Faltan parametros por informar*/
      END IF;

      psquery := 'SELECT e.ctipo, ff_desvalorfijo(800050,' || pidioma
                 || ',e.ctipo) ttipo, e.csubtipo, ' || 'ff_desvalorfijo(800052,' || pidioma
                 || ',e.ctipo) tsubtipo' || ' FROM empleados e ' || ' WHERE e.sperson = '
                 || psperson;
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_gestores_empleados;

   /*************************************************************************
    Nueva funcion que obtiene información de los representantes/promotores de la persona
    param in psperson   : Codigo sperson
    param in pidioma    : Codigo idioma
    param out psquery   : Select
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_represent_promotores(
      psperson IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_represent_promotores';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /* Faltan parametros por informar*/
      END IF;

      psquery := 'SELECT r.ctipo, ff_desvalorfijo(800054,' || pidioma
                 || ',r.ctipo) ttipo, r.csubtipo, ' || 'ff_desvalorfijo(800055,' || pidioma
                 || ',r.ctipo) tsubtipo, r.tcompania, r.tpuntoventa '
                 || ' FROM representantes r ' || ' WHERE r.sperson = ' || psperson;
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_represent_promotores;

   /*************************************************************************
    Nueva funcion que obtiene información de los representantes/promotores asociados a un coordinador
    param in psperson   : Codigo sperson
    param in pidioma    : Codigo idioma
    param out psquery   : Select
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_coordinadores(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_coordinadores';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /* Faltan parametros por informar*/
      END IF;

      psquery := 'SELECT r.ctipo, ff_desvalorfijo(800054,' || pidioma
                 || ',r.ctipo) ttipo, f_nombre(r.sperson,2,NULL) tnombre'
                 || ' FROM representantes r ' || ' WHERE r.spercoord = ' || psperson;
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_coordinadores;

   /*************************************************************************
    Nueva funcion que obtiene información de las listas oficiales del estado de la persona
    param in psperson   : Codigo sperson
    param in pcclalis   : Identificador de clase de lista
    param in pidioma    : Codigo idioma
    param out psquery   : Select
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_listas_oficiales(
      psperson IN NUMBER,
      pcclalis IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
             := 'psperson=' || psperson || ' pcclaslis=' || pcclalis || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_listas_oficiales';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pcclalis IS NULL
         OR pidioma IS NULL THEN
         RETURN 9000505;   /* Faltan parametros por informar*/
      END IF;

      /* Bug 24684/129519 - 20/11/2012 - AMC*/
      /* Bug 31411/175020 - 16/05/2014 - AMC*/
      psquery :=
         'SELECT  decode(l.cclalis,2,l.ctiplis,null) ctiplis, decode(l.cclalis,2,ff_desvalorfijo(800048,'
         || pidioma || ',l.ctiplis),null) ttiplis, l.finclus, l.cinclus, l.fexclus, l.nnumide,'
         || ' ff_desvalorfijo(800122,' || pidioma || ',l.cinclus ) tcinclus'
         || ' ,F_FORMATOPOLSEG(sseguro) npoliza, nmovimi,' || ' ff_desvalorfijo(800121,'
         || pidioma || ',caccion) ttipocaccion, nsinies,nrecibo' || ' FROM lre_personas l '
         || ' WHERE l.sperson = ' || psperson || ' and l.cclalis = ' || pcclalis;
      /* Fi Bug 24684/129519 - 20/11/2012 - AMC*/
      /* FiBug 31411/175020 - 16/05/2014 - AMC*/
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_listas_oficiales;

   /*************************************************************************
     función que recuperará todas la personas dependiendo del modo.
     publico o no. servirá para todas las pantallas donde quieran utilizar el
     buscador de personas.

     Bug 20044/97773 - 12/11/2011 - AMC
   *************************************************************************/
   FUNCTION f_get_persona_generica_cond(
      pnumide IN VARCHAR2,
      pnombre IN VARCHAR2,
      pnsip IN VARCHAR2,
      pnom IN VARCHAR2,
      pcognom1 IN VARCHAR2,
      pcognom2 IN VARCHAR2,
      pctipide IN NUMBER,
      pcagente IN NUMBER,
      pmodo_swpubli IN VARCHAR2,
      pcond IN VARCHAR2,
      psquery OUT CLOB)
      RETURN NUMBER IS
      condicio1      VARCHAR2(1000);
      condicio2      VARCHAR2(1000);
      condicio3      VARCHAR2(1000);
      condicio4      VARCHAR2(1000);
      condicio5      VARCHAR2(1000);
      condicio6      VARCHAR2(1000);
      condicio7      VARCHAR2(1000);
      condicio8      VARCHAR2(1000);
      tlog           VARCHAR2(4000);
      nerr           NUMBER(10);
      auxnom         VARCHAR2(9000);
      condicion      VARCHAR2(9000);
   BEGIN
      IF pnombre IS NOT NULL THEN
         nerr := f_strstd(pnombre, auxnom);
         condicio1 := '%' || auxnom || '%';
         condicion := ' AND UPPER(d.tbuscar) LIKE UPPER(' || CHR(39) || condicio1 || CHR(39)
                      || ')';
      END IF;

      IF pnumide IS NOT NULL THEN
         condicio2 := ff_strstd(pnumide);
         /* Bug 35888/205345 Realizar la substitución del upper nnumnif o nnumide - CJMR D02 A01*/
         condicion := condicion || ' AND per.nnumide LIKE ' || CHR(39) || '%' || condicio2
                      || '%' || CHR(39) || ' ';   -- 36190-206031
      END IF;

      IF pnsip IS NOT NULL THEN
         condicio3 := ff_strstd(pnsip);
         condicion := condicion || ' AND UPPER(per.snip) LIKE UPPER(' || CHR(39) || condicio3
                      || CHR(39) || ')';
      END IF;

      IF pnom IS NOT NULL THEN
         condicio4 := '%' || ff_strstd(pnom) || '%';
         condicion := condicion || ' AND  ff_strstd(d.tnombre) LIKE (' || CHR(39) || condicio4
                      || CHR(39) || ')';
      END IF;

      IF pcognom1 IS NOT NULL THEN
         condicio5 := '%' || ff_strstd(pcognom1) || '%';
         condicion := condicion || ' AND  ff_strstd(d.tapelli1) LIKE (' || CHR(39)
                      || condicio5 || CHR(39) || ')';
      END IF;

      IF pcognom2 IS NOT NULL THEN
         condicio6 := '%' || ff_strstd(pcognom2) || '%';
         condicion := condicion || ' AND  ff_strstd(d.tapelli2) LIKE (' || CHR(39)
                      || condicio6 || CHR(39) || ')';
      END IF;

      IF pctipide IS NOT NULL THEN
         condicio7 := TO_CHAR(pctipide);
         condicion := condicion || ' AND per.ctipide = ' || CHR(39) || condicio7 || CHR(39);
      END IF;

      IF pcond IS NOT NULL THEN
         condicion := condicion || ' ' || pcond;
      END IF;

      /* Bug 25456/133727 - 16/01/2013 - AMC*/
      /*Bug 29166/160004 - 29/11/2013 - AMC*/
      IF pmodo_swpubli = 'PERSONAS_PUBLICAS' THEN
         psquery :=
            '         SELECT   sperson codi, cagente, ff_desagente(cagente) tagente,  nnumide, tnombre || '' '' || tapelli nombre, pac_persona.F_FORMAT_NIF(nnumide,ctipide,sperson,''POL'') NNUMNIF
                     FROM (SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
                  per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
                  per.snip, d.cagente, ff_agenteprod() cagenteprod, d.cidioma,
                  SUBSTR(d.tapelli1, 0, 40) tapelli1, SUBSTR(d.tapelli2, 0, 20) tapelli2,
                  SUBSTR(d.tapelli1, 0, 40) || '' '' || SUBSTR(d.tapelli2, 0, 20) tapelli,
                  /* Se deberá quitar el substr cuando se prepare base de datos*/
                  SUBSTR(d.tnombre, 0, 20) tnombre,SUBSTR(d.tsiglas, 0, 20) tsiglas,d.cprofes,
                  d.tbuscar, d.cestciv, d.cpais, c.cbancar, c.ctipban, per.swpubli, per.ctipper,
                  per.nnumide nnumnif, per.ctipper cpertip, per.ctipide tidenti, per.nordide nnifdup,
                  per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
                  NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
                  NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
                  NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, d.cocupacion
             FROM per_personas per, per_detper d, per_ccc c
            WHERE per.sperson = d.sperson
              AND c.sperson(+) = d.sperson
              AND c.cagente(+) = d.cagente
              AND per.cagente = d.cagente
              AND c.cdefecto(+) = 1   /* cuenta bacaria por defecto*/
              AND per.swpubli = 1  '
            || condicion
            || ' )where ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      /* La persona es pública y la puede ver todo el mundo*/
      ELSIF pmodo_swpubli = 'PERSONAS_PRIVADAS' THEN
         /* Bug 12761 - 18/01/2010 - AMC - Se añade la condición*/
         psquery :=
            ' SELECT   sperson codi, cagente, ff_desagente(cagente) tagente, nnumide, tnombre || '' '' || tapelli nombre,  pac_persona.F_FORMAT_NIF(nnumide,ctipide,sperson,''POL'') NNUMNIF
                     FROM(
                     SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
                  per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
                  per.snip, d.cagente, ff_agenteprod() cagenteprod, d.cidioma,
                  SUBSTR(d.tapelli1, 0, 40) tapelli1, SUBSTR(d.tapelli2, 0, 20) tapelli2,
                  SUBSTR(d.tapelli1, 0, 40) || '' '' || SUBSTR(d.tapelli2, 0, 20) tapelli,
                  SUBSTR(d.tnombre, 0, 20) tnombre,
                                                   SUBSTR(d.tsiglas, 0, 20) tsiglas,
                                                                                    d.cprofes,
                  d.tbuscar, d.cestciv, d.cpais, c.cbancar, c.ctipban, per.swpubli, per.ctipper,
                  per.nnumide nnumnif, per.ctipide cpertip, per.ctipide tidenti, per.nordide nnifdup,
                  per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
                  NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
                  NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
                  NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, d.cocupacion
             FROM per_personas per, per_detper d, per_ccc c
            WHERE per.sperson = d.sperson
              AND c.sperson(+) = d.sperson
              AND c.cagente(+) = d.cagente
              AND c.cdefecto(+) = 1   /* cuenta bacaria por defecto*/
              AND per.swpubli = 0 '
            || condicion
            || ' AND d.cagente IN(SELECT     r.cagente
                                     FROM redcomercial r
                                    WHERE fmovfin IS NULL
                                      AND LEVEL = DECODE(ff_agente_cpernivel('
            || pcagente
            || '), 1, LEVEL, 1)
                                      START WITH cagente = ff_agente_cpervisio('
            || pcagente
            || ')
                                      CONNECT BY PRIOR cagente = cpadre
                                      AND PRIOR fmovfin IS NULL)
                                      )
                                      WHERE ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      /*Fi Bug 12761 - 18/01/2010 - AMC - Se añade la condición*/
      ELSIF pmodo_swpubli = 'PERSONAS_PUBPRIV' THEN
         /* Personas publicas y privadas*/
         psquery :=
            ' SELECT   sperson codi, cagente, ff_desagente(cagente) tagente, nnumide, tnombre || '' '' || tapelli nombre,  pac_persona.F_FORMAT_NIF(nnumide,ctipide,sperson,''POL'') NNUMNIF
                     FROM(
                     SELECT per.sperson, per.nnumide, per.nordide, per.ctipide, per.csexper, per.fnacimi,
                  per.cestper, per.fjubila, per.cusuari, per.fmovimi, per.cmutualista, per.fdefunc,
                  per.snip, d.cagente, ff_agenteprod() cagenteprod, d.cidioma,
                  SUBSTR(d.tapelli1, 0, 40) tapelli1, SUBSTR(d.tapelli2, 0, 20) tapelli2,
                  SUBSTR(d.tapelli1, 0, 40) || '' '' || SUBSTR(d.tapelli2, 0, 20) tapelli,
                  SUBSTR(d.tnombre, 0, 20) tnombre,
                                                   SUBSTR(d.tsiglas, 0, 20) tsiglas,
                                                                                    d.cprofes,
                  d.tbuscar, d.cestciv, d.cpais, c.cbancar, c.ctipban, per.swpubli, per.ctipper,
                  per.nnumide nnumnif, per.ctipide cpertip, per.ctipide tidenti, per.nordide nnifdup,
                  per.nordide nnifrep, per.cestper cestado, per.fmovimi finform, NULL nempleado,
                  NULL nnumsoe, NULL tnomtot, NULL tperobs, NULL cnifrep, NULL pdtoint, NULL ccargos,
                  NULL tpermis, NULL producte, NULL nsocio, NULL nhijos, NULL claboral, NULL cvip,
                  NULL spercon, NULL fantigue, NULL ctrato, NULL num_contra, d.cocupacion
             FROM per_personas per, per_detper d, per_ccc c, redcomercial rd
            WHERE per.sperson = d.sperson
              AND c.sperson(+) = d.sperson
              AND c.cagente(+) = d.cagente
              AND c.cdefecto(+) = 1   '
            || condicion
            || '
              AND ( (per.swpubli = 1 and d.cagente = pac_persona.f_buscaagente_publica(per.sperson) ) OR
               (per.swpubli = 0 '
            || ' AND d.cagente IN(SELECT     r.cagente
                                     FROM redcomercial r
                                    WHERE fmovfin IS NULL
                                     and cempres = '
            || pac_md_common.f_get_cxtempresa
            || '
                                      AND LEVEL = DECODE(ff_agente_cpernivel(' || pcagente
            || '), 1, LEVEL, 1)
                               START WITH cagente = ff_agente_cpervisio('
            || pcagente
            || ')
                               CONNECT BY PRIOR cagente = cpadre
                                      AND PRIOR fmovfin IS NULL)))
              AND rd.cagente = (SELECT Z.CAGENTE FROM redcomercial Z WHERE Z.CAGENTE = d.CAGENTE AND Z.FMOVFIN IS NULL and z.cempres = '
            || pac_md_common.f_get_cxtempresa
            || ')
              AND rd.fmovfin IS NULL ) WHERE ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      /*Bug 28773  Optimización select*/
      END IF;

      /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_persona', 1, 'f_get_persona_generica', SQLERRM);
         RETURN 1;
   END f_get_persona_generica_cond;

   /*************************************************************************
     Función que inserta o actualiza los datos de un documento asociado a la persona

     Bug 20126 - APD - 23/11/2011 - se crea la funcion
   *************************************************************************/
   FUNCTION f_set_docpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptdocumento IN NUMBER DEFAULT NULL,
      pedocumento IN NUMBER DEFAULT NULL,
      pfedo IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - pfcaduca: ' || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - ptobserva: '
            || ptobserva || ' - piddocgedox: ' || piddocgedox || ' - ptdocumento: '
            || ptdocumento || ' - pedocumento: ' || pedocumento || ' - pfedo: ' || pfedo;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_set_docpersona';
      salir          EXCEPTION;
      v_cagente NUMBER;  --Ini IAXIS-4212 -- ECP -- 06/07/2019
   BEGIN
   --Ini IAXIS-4212 -- ECP -- 06/07/2019
      IF psperson IS NULL
          OR piddocgedox IS NULL THEN
         vnumerr := 103135;   /*Faltan parámetros*/
         RAISE salir;
      END IF;

       if pcagente IS NULL then
          begin
            select cagente
            into v_cagente
            from per_detper
            where sperson = psperson;
            exception when no_data_found then v_cagente := 19000;
          end;
       end if;


      vpasexec := 2;

      BEGIN
         INSERT INTO per_documentos
                     (sperson, cagente, iddocgedox, fcaduca, tobserva, tdocumento,
                      edocumento, fedo)
              VALUES (psperson, nvl(pcagente,v_cagente), piddocgedox, pfcaduca, ptobserva, ptdocumento,
                      pedocumento, pfedo);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE per_documentos
               SET fcaduca = pfcaduca,
                   tobserva = ptobserva,
                   tdocumento = ptdocumento,
                   edocumento = pedocumento,
                   fedo = pfedo
             WHERE sperson = psperson
               AND cagente =  nvl(pcagente,v_cagente)
               AND iddocgedox = piddocgedox;
      END;
--Fin IAXIS-4212 -- ECP -- 06/07/2019
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, 'PAC_persona', vpasexec, 'f_set_docpersona',
                     f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_persona', vpasexec, 'f_set_docpersona', SQLERRM);
         RETURN 140999;   /* Error no controlado*/
   END f_set_docpersona;

/* BUG20790:APD:03/01/2012:Inici*/
/**************************************************************
  Funció que valida una CCC
**************************************************************/
   FUNCTION f_valida_ccc(
      psperson IN NUMBER,
      pcnordban IN NUMBER,
      pcagente IN NUMBER,
      pcbancar IN VARCHAR2)
      RETURN NUMBER IS
      /**/
      v_cont         NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO v_cont
        FROM per_ccc
       WHERE cnordban != pcnordban
         AND sperson = psperson
         AND cagente = pcagente
         AND cbancar = pcbancar
         AND(fbaja IS NULL
             OR fbaja > TRUNC(f_sysdate));

      IF v_cont <> 0 THEN
         RETURN 9903069;
      /*La persona no puede tener una misma cuenta bancaria para el mismo agente.*/
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_valida_ccc', NULL, SQLCODE, SQLERRM);
         RETURN 140999;   /* Error no controlado*/
   END f_valida_ccc;

   /* BUG20790:APD:03/01/2012:Fi*/
   /**************************************************************
     Funció que valida que si hay una ccc con pagos de siniestros
     param in psperson : codigo de persona
     param in pcagente : codigo del agente
     param out pcodilit : codigo del literal a mostrar
     return codigo error : 0 - ok ,codigo de error
     BUG 20958/104928 - 24/01/2012 - AMC

     Bug 21867/111852 - 29/03/2012 - AMC
   **************************************************************/
   FUNCTION f_valida_pagoccc(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcnordban IN NUMBER,
      pcodilit IN OUT NUMBER)
      RETURN NUMBER IS
      v_cpagsin      NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO v_cpagsin
        FROM per_ccc
       WHERE sperson = psperson
         AND cagente = pcagente
         AND cpagsin = 1
         AND cnordban <> pcnordban   /*Bug 21867/111852*/
         AND fbaja IS NULL;

      IF v_cpagsin = 0 THEN
         pcodilit := 9903164;
      /*En este momento esta persona no tiene definida ninguna cuenta bancaria como pago.*/
      ELSE
         pcodilit := 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_valida_pagoccc', NULL, SQLCODE,
                     SQLERRM);
         RETURN 140999;   /* Error no controlado*/
   END f_valida_pagoccc;

   /***************************************************************************
   Función que guarda la cessio o publicitat
   *****************************************************************************/
   FUNCTION f_set_persona_lopd(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcesion IN NUMBER,
      ppublicidad IN NUMBER,
      pacceso IN NUMBER,
      prectificacion IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'parámetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_set_persona_lopd';
      vcagente       NUMBER := pcagente;
      vcont          NUMBER;
      v_max_seg      NUMBER;
      vcestado       NUMBER;
      vcancelacion   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL(MAX(norden), 0) + 1
           INTO v_max_seg
           FROM per_lopd
          WHERE sperson = psperson
            AND cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_max_seg := 1;
      END;

      IF v_max_seg <> 1 THEN
         BEGIN
            SELECT cestado, cancelacion
              INTO vcestado, vcancelacion
              FROM per_lopd
             WHERE sperson = psperson
               AND cagente = pcagente
               AND norden = (SELECT MAX(norden)
                               FROM per_lopd
                              WHERE sperson = psperson
                                AND cagente = pcagente
                                AND cestado IS NOT NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcestado := NULL;
         END;

         IF vcestado = 4 THEN
            RETURN 9903254;
         END IF;

         INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden, acceso,
                      rectificacion)
            (SELECT psperson, f_sysdate, f_user, cestado, pcesion, ppublicidad, cancelacion,
                    NULL, NULL, NULL, NULL, pcagente, v_max_seg, pacceso, prectificacion
               FROM per_lopd
              WHERE sperson = psperson
                AND cagente = pcagente
                AND norden = v_max_seg - 1);
      ELSE
         INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden, acceso,
                      rectificacion)
              VALUES (psperson, f_sysdate, f_user, NULL, pcesion, ppublicidad, NULL,
                      NULL, NULL, NULL, NULL, pcagente, v_max_seg, pacceso,
                      prectificacion);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_set_persona_lopd', NULL, SQLCODE,
                     SQLERRM);
         RETURN 108468;
   END f_set_persona_lopd;

   FUNCTION f_inserta_docseg_lopd(psseguro IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      viddocbloq     NUMBER;
   BEGIN
      viddocbloq := pac_parametros.f_parempresa_n(pcempres, 'DOC_BLOQ_GEDOX');

      IF viddocbloq IS NOT NULL THEN
         FOR i IN (SELECT seqdocu, sseguro, nmovimi, iddocgedox
                     FROM docrequerida
                    WHERE sseguro = psseguro) LOOP
            BEGIN
               INSERT INTO docrequerida_lopd
                           (seqdocu, sseguro, nmovimi, iddocgedox)
                    VALUES (i.seqdocu, i.sseguro, i.nmovimi, i.iddocgedox);

               UPDATE docrequerida
                  SET iddocgedox = viddocbloq
                WHERE seqdocu = i.seqdocu
                  AND sseguro = i.sseguro
                  AND nmovimi = i.nmovimi;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;

         /*    FOR i IN (SELECT seqdocu, sseguro, nmovimi, iddocgedox
                         FROM docrequerida
                        WHERE sseguro = psseguro) LOOP
                BEGIN
                   INSERT INTO docrequerida_lopd
                               (seqdocu, sseguro, nmovimi, iddocgedox)
                        VALUES (i.seqdocu, i.sseguro, i.nmovimi, i.iddocgedox);

                EXCEPTION
                   WHEN DUP_VAL_ON_INDEX THEN
                      NULL;
                END;
             END LOOP;*/
         FOR i IN (SELECT seqdocu, sseguro, nmovimi, ninqaval, iddocgedox
                     FROM docrequerida_inqaval
                    WHERE sseguro = psseguro) LOOP
            BEGIN
               INSERT INTO docrequerida_lopd_inqaval
                           (seqdocu, sseguro, nmovimi, ninqaval, iddocgedox)
                    VALUES (i.seqdocu, i.sseguro, i.nmovimi, i.ninqaval, i.iddocgedox);

               UPDATE docrequerida_inqaval
                  SET iddocgedox = viddocbloq
                WHERE seqdocu = i.seqdocu
                  AND sseguro = i.sseguro
                  AND nmovimi = i.nmovimi
                  AND ninqaval = i.ninqaval;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;

         FOR i IN (SELECT seqdocu, sseguro, nmovimi, nriesgo, iddocgedox
                     FROM docrequerida_riesgo
                    WHERE sseguro = psseguro) LOOP
            BEGIN
               INSERT INTO docrequerida_lopd_riesgo
                           (seqdocu, sseguro, nmovimi, nriesgo, iddocgedox)
                    VALUES (i.seqdocu, i.sseguro, i.nmovimi, i.nriesgo, i.iddocgedox);

               UPDATE docrequerida_riesgo
                  SET iddocgedox = viddocbloq
                WHERE seqdocu = i.seqdocu
                  AND sseguro = i.sseguro
                  AND nmovimi = i.nmovimi
                  AND nriesgo = i.nriesgo;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;

         FOR i IN (SELECT seqdocu, sseguro, nmovimi, nriesgo, iddocgedox
                     FROM docrequerida_benespseg
                    WHERE sseguro = psseguro) LOOP
            BEGIN
               INSERT INTO docrequerida_lopd_benespseg
                           (seqdocu, sseguro, nmovimi, nriesgo, iddocgedox)
                    VALUES (i.seqdocu, i.sseguro, i.nmovimi, i.nriesgo, i.iddocgedox);

               UPDATE docrequerida_benespseg
                  SET iddocgedox = viddocbloq
                WHERE seqdocu = i.seqdocu
                  AND sseguro = i.sseguro
                  AND nmovimi = i.nmovimi
                  AND nriesgo = i.nriesgo;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;

         FOR i IN (SELECT sseguro, nmovimi, iddocgedox, corigen
                     FROM docummovseg
                    WHERE sseguro = psseguro) LOOP
            BEGIN
               INSERT INTO docummovseg_lopd
                           (sseguro, nmovimi, iddocgedox, corigen)
                    VALUES (i.sseguro, i.nmovimi, i.iddocgedox, i.corigen);

               UPDATE docummovseg
                  SET iddocgedox = viddocbloq
                WHERE sseguro = i.sseguro
                  AND nmovimi = i.nmovimi
                  AND iddocgedox = i.iddocgedox;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;
      END IF;

      /*    INSERT INTO docrequerida_lopd
                      (seqdocu, sseguro, nmovimi, iddocgedox)
             (SELECT seqdocu, sseguro, nmovimi, iddocgedox
                FROM docrequerida
               WHERE sseguro = psseguro);

          INSERT INTO docrequerida_lopd_inqaval
                      (seqdocu, sseguro, nmovimi, ninqaval, iddocgedox)
             (SELECT seqdocu, sseguro, nmovimi, ninqaval, iddocgedox
                FROM docrequerida_inqaval
               WHERE sseguro = psseguro);

          INSERT INTO docrequerida_lopd_riesgo
                      (seqdocu, sseguro, nmovimi, nriesgo, iddocgedox)
             (SELECT seqdocu, sseguro, nmovimi, nriesgo, iddocgedox
                FROM docrequerida_riesgo
               WHERE sseguro = psseguro);

          INSERT INTO docummovseg_lopd
                      (sseguro, nmovimi, iddocgedox, corigen)
             (SELECT sseguro, nmovimi, iddocgedox, corigen
                FROM docummovseg
               WHERE sseguro = psseguro);*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_inserta_docseg_lopd', v_traza,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN 1;
   END f_inserta_docseg_lopd;

   FUNCTION f_inserta_docsin_lopd(pnsinies IN VARCHAR2, pcempres IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      viddocbloq     NUMBER;
   BEGIN
      viddocbloq := pac_parametros.f_parempresa_n(pcempres, 'DOC_BLOQ_GEDOX');

      IF viddocbloq IS NOT NULL THEN
         FOR i IN (SELECT nsinies, ntramit, ndocume, iddoc
                     FROM sin_tramita_documento
                    WHERE nsinies = pnsinies
                      AND iddoc IS NOT NULL) LOOP
            BEGIN
               INSERT INTO sin_tramita_documento_lopd
                           (nsinies, ntramit, ndocume, iddoc)
                    VALUES (i.nsinies, i.ntramit, i.ndocume, i.iddoc);

               UPDATE sin_tramita_documento
                  SET iddoc = viddocbloq
                WHERE nsinies = i.nsinies
                  AND ntramit = i.ntramit
                  AND ndocume = i.ndocume;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_inserta_docsin_lopd', v_traza,
                     'pnsinies = ' || pnsinies, SQLERRM);
         RETURN 1;
   END f_inserta_docsin_lopd;

   FUNCTION f_bloqueo_documentacion(psperson IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      vnumerr        NUMBER := 0;
      vcont          NUMBER := 0;
   BEGIN
      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM tomadores aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_inserta_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM asegurados aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vcont := 1;
         vnumerr := f_inserta_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      /* IF vcont = 0 THEN*/
      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM riesgos aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_inserta_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM beneficiarios aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_inserta_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, tomadores t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND t.sperson = psperson
                   AND ss.nsinies = sm.nsinies
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_inserta_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, asegurados t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND t.sperson = psperson
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_inserta_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, riesgos t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND t.sperson = psperson
                   AND ss.nsinies = sm.nsinies
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_inserta_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM sin_siniestro ss, sin_movsiniestro sm, seguros s
                 WHERE (ss.sperson2 = psperson
                        OR ss.dec_sperson = psperson)
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_inserta_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM sin_siniestro ss, sin_movsiniestro sm, sin_tramita_destinatario std,
                       seguros s
                 WHERE (std.sperson = psperson)
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND ss.nsinies = std.nsinies
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_inserta_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_bloqueo_documentacion', v_traza,
                     'SPERSON = ' || psperson || ' cagente = ' || pcagente, SQLERRM);
         RETURN 1;
   END f_bloqueo_documentacion;

   /*
   Bloqueamos a la persona
   */
   FUNCTION f_persona_lopd_bloqueo(
      psperson IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vparam         VARCHAR2(500)
                        := 'parámetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.F_PERSONA_LOPD_BLOQUEO';

      CURSOR lopd IS
         SELECT sperson, cagente
           FROM per_lopd a
          WHERE a.cancelacion = 1
            AND a.cestado = 1
            AND(psperson IS NULL
                OR(psperson IS NOT NULL
                   AND psperson = a.sperson))
            AND(pcagente IS NULL
                OR(pcagente IS NOT NULL
                   AND pcagente = a.cagente))
            AND norden = (SELECT MAX(norden)
                            FROM per_lopd b
                           WHERE b.sperson = a.sperson
                             AND b.cagente = a.cagente);

      vnorden        NUMBER;
      v_aux          NUMBER;
      v_traza        NUMBER := 1;
      v_tperso       personas.sperson%TYPE;
      v_cagente      NUMBER;
      vnumerr        NUMBER;
   BEGIN
      FOR rc IN lopd LOOP
         v_tperso := rc.sperson;
         v_cagente := rc.cagente;
         v_traza := 1;

         /*Traspaso a las tablas per_lopd*/
         SELECT NVL(MAX(num_lopd), 0) + 1
           INTO vnorden
           FROM perlopd_personas
          WHERE sperson = rc.sperson;

         v_traza := 2;

         /*Cabecera Persona*/
         SELECT COUNT(1)
           INTO v_aux
           FROM perlopd_personas
          WHERE sperson = rc.sperson;

         IF v_aux = 0 THEN
            INSERT INTO perlopd_personas
                        (sperson, nnumide, nordide, ctipide, csexper, fnacimi, cestper,
                         fjubila, ctipper, cusuari, fmovimi, cmutualista, fdefunc, num_lopd,
                         flopd, swpubli, snip, tdigitoide)
               (SELECT sperson, nnumide, nordide, ctipide, DECODE(ctipper, 2, NULL, csexper),   /*Bug 29738/166356 - 17/02/2014 - AMC csexper,*/
                       fnacimi, cestper, fjubila, ctipper, cusuari, fmovimi, cmutualista,
                       fdefunc, vnorden, f_sysdate, swpubli, snip, tdigitoide
                  FROM per_personas
                 WHERE sperson = rc.sperson);
         END IF;

         v_aux := NULL;
         v_traza := 3;

         /*Detalle Persona*/
         /* Bug 25456/133727 - 16/01/2013 - AMC*/
         /*Bug 29738/166356 - 17/02/2014 - AMC*/
         INSERT INTO perlopd_detper
                     (sperson, cagente, cidioma, tapelli1, tapelli2, tnombre, tsiglas, cprofes,
                      tbuscar, cestciv, cpais, cusuari, fmovimi, num_lopd, flopd, cocupacion)
            (SELECT pd.sperson, pd.cagente, pd.cidioma, pd.tapelli1, pd.tapelli2, pd.tnombre,
                    pd.tsiglas, pd.cprofes, pd.tbuscar, DECODE(p.ctipper, 2, NULL, pd.cestciv),
                    pd.cpais, pd.cusuari, pd.fmovimi, vnorden, f_sysdate, pd.cocupacion
               FROM per_detper pd, per_personas p
              WHERE pd.sperson = rc.sperson
                AND pd.cagente = rc.cagente
                AND pd.sperson = p.sperson);

         /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
         /*Fi Bug 29738/166356 - 17/02/2014 - AMC*/
         v_traza := 4;

         /*Direcciones*/
         INSERT INTO perlopd_direcciones
                     (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia, nnumvia, tcomple,
                      tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi, num_lopd, flopd)
            (SELECT sperson, cagente, cdomici, ctipdir, csiglas, tnomvia, nnumvia, tcomple,
                    tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi, vnorden, f_sysdate
               FROM per_direcciones
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         v_traza := 5;

         /*Contactos*/
         INSERT INTO perlopd_contactos
                     (sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon, cusuari, fmovimi,
                      num_lopd, flopd)
            (SELECT sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon, cusuari, fmovimi,
                    vnorden, f_sysdate
               FROM per_contactos
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         INSERT INTO per_documentos_lopd
                     (sperson, cagente, iddocgedox, fcaduca, tobserva, cusualt, falta, cusuari,
                      fmovimi)
            (SELECT sperson, cagente, iddocgedox, fcaduca, tobserva, cusualt, falta, cusuari,
                    fmovimi
               FROM per_documentos
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         v_traza := 6;
         /*Vinculos*/
         /* INSERT INTO perlopd_vinculos
                      (sperson, cagente,  cvinclo,  cusuari, fmovimi, num_lopd,
                       flopd)
             (SELECT sperson, cagente,  cvinclo,  cusuari, fmovimi, vnorden,
                     f_sysdate
                FROM per_vinculos
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente);
         */
         v_traza := 7;
         /*Profesiones*/
         /* INSERT INTO perlopd_profesion
                      (cagente, cagente, sperson, cactpro, cretenc, ctipiva, ncolegi, numprof,
                       tempres, ccargo, fantigue, fjubila, iindeni, swpubli, fmovimi, cusuari,
                       num_lopd, flopd)
             (SELECT cagente, cagente, sperson, cactpro, cretenc, ctipiva, ncolegi, numprof,
                     tempres, ccargo, fantigue, fjubila, iindeni, swpubli, fmovimi, cusuari,
                     vnorden, f_sysdate
                FROM per_profesion
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente);*/
         v_traza := 8;

         /*CCC*/
         INSERT INTO perlopd_ccc
                     (sperson, cagente, ctipban, cbancar, fbaja, cdefecto, cusumov, fusumov,
                      num_lopd, flopd, cnordban)
            (SELECT sperson, cagente, ctipban, cbancar, fbaja, cdefecto, cusumov, fusumov,
                    vnorden, f_sysdate, cnordban
               FROM per_ccc
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         /*Traspaso de tablas HISPER*/
         v_traza := 9;

         /*Cabecera Persona*/
         SELECT COUNT(1)
           INTO v_aux
           FROM perlopd_personas
          WHERE sperson = rc.sperson;

         IF v_aux = 0 THEN
            INSERT INTO hisperlopd_personas
                        (sperson, nnumide, nordide, ctipide, csexper, fnacimi, cestper,
                         fjubila, ctipper, cusuari, fmovimi, cmutualista, fdefunc, num_lopd,
                         flopd, norden, swpubli, snip)
               (SELECT sperson, nnumide, nordide, ctipide, csexper, fnacimi, cestper, fjubila,
                       ctipper, cusuari, fmovimi, cmutualista, fdefunc, vnorden, f_sysdate,
                       norden, swpubli, snip
                  FROM hisper_personas
                 WHERE sperson = rc.sperson);
         END IF;

         v_aux := NULL;
         v_traza := 9;

         /*Detalle Persona*/
         /* Bug 25456/133727 - 16/01/2013 - AMC*/
         INSERT INTO hisperlopd_detper
                     (sperson, cagente, cidioma, tapelli1, tapelli2, tnombre, tsiglas, cprofes,
                      tbuscar, cestciv, cpais, cusuari, fmovimi, num_lopd, flopd, norden,
                      cocupacion)
            (SELECT sperson, cagente, cidioma, tapelli1, tapelli2, tnombre, tsiglas, cprofes,
                    tbuscar, cestciv, cpais, cusuari, fmovimi, vnorden, f_sysdate, norden,
                    cocupacion
               FROM hisper_detper
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
         v_traza := 10;

         /*Direcciones*/
         INSERT INTO hisperlopd_direcciones
                     (sperson, cagente, cdomici, ctipdir, csiglas, tnomvia, nnumvia, tcomple,
                      tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi, num_lopd, flopd,
                      norden)
            (SELECT sperson, cagente, cdomici, ctipdir, csiglas, tnomvia, nnumvia, tcomple,
                    tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi, vnorden, f_sysdate,
                    norden
               FROM hisper_direcciones
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         INSERT INTO hisper_documentos_lopd
                     (sperson, cagente, iddocgedox, fcaduca, tobserva, cusualt, falta, cusuari,
                      fmovimi)
            (SELECT sperson, cagente, iddocgedox, fcaduca, tobserva, cusualt, falta, cusuari,
                    fmovimi
               FROM hisper_documentos
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         v_traza := 11;

         /*Contactos*/
         INSERT INTO hisperlopd_contactos
                     (sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon, cusuari, fmovimi,
                      num_lopd, flopd, norden)
            (SELECT sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon, cusuari, fmovimi,
                    vnorden, f_sysdate, norden
               FROM hisper_contactos
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         v_traza := 12;
         /*Vinculos*/
         /*  INSERT INTO hisperlopd_vinculos
                       (sperson, cagente,  cvinclo, swpubli, cusuari, fmovimi, num_lopd,
                        flopd, norden)
              (SELECT sperson, cagente,  cvinclo,  cusuari, fmovimi, vnorden,
                      f_sysdate, norden
                 FROM hisper_vinculos
                WHERE sperson = rc.sperson
                  AND cagente = rc.cagente);

           v_traza := 13;

           --Profesiones
           INSERT INTO hisperlopd_profesion
                       (cagente,  sperson, cactpro, cretenc, ctipiva, ncolegi, numprof,
                        tempres, ccargo, fantigue, fjubila, iindeni, swpubli, fmovimi, cusuari,
                        num_lopd, flopd, norden)
              (SELECT cagente,  sperson, cactpro, cretenc, ctipiva, ncolegi, numprof,
                      tempres, ccargo, fantigue, fjubila, iindeni, swpubli, fmovimi, cusuari,
                      vnorden, f_sysdate, norden
                 FROM hisper_profesion
                WHERE sperson = rc.sperson
                  AND cagente = rc.cagente);
         */
         v_traza := 14;

         /*CCC*/
         INSERT INTO hisperlopd_ccc
                     (sperson, cagente, ctipban, cbancar, fbaja, cdefecto, cusumov, fusumov,
                      num_lopd, flopd, norden)
            (SELECT sperson, cagente, ctipban, cbancar, fbaja, cdefecto, cusumov, fusumov,
                    vnorden, f_sysdate, norden
               FROM hisper_ccc
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente);

         /*Ofuscación de datos personales*/
         v_traza := 14;

         SELECT COUNT(*)
           INTO v_aux
           FROM per_detper
          WHERE sperson = rc.sperson;

         v_traza := 15;
         /*  DELETE FROM per_personasnif
                 WHERE sperson = rc.sperson
                   AND cagente = rc.cagente;

           IF v_aux > 1 THEN   --La persona esta en más de una empresa.
              v_traza := 16;

              DECLARE
                 CURSOR personas IS   --Cojo todas las personas que no esten ya traspasadas ni la actual y las inserto en per_personasnif.
                    SELECT per.sperson, det.cagente, per.nnumide
                      FROM per_detper det, per_personas per
                     WHERE det.sperson = rc.sperson
                       AND det.cagente NOT IN(SELECT cagente
                                                FROM perlopd_detper
                                               WHERE sperson = rc.sperson)
                       AND det.cagente <> rc.cagente
                       AND per.sperson = det.sperson;
              BEGIN
                 FOR r_per IN personas LOOP
                    BEGIN
                       INSERT INTO per_personasnif
                                   (sperson, cagente,
                                    nnumide)
                            VALUES (r_per.sperson, r_per.cagente,
                                    DECODE(r_per.nnumide,
                                           'Z00000000', (SELECT DISTINCT nnumide
                                                                    FROM per_personasnif
                                                                   WHERE sperson = rc.sperson),
                                           r_per.nnumide));
                    EXCEPTION
                       WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                    END;
                 END LOOP;
              END;
           END IF;

           --Updates
           --Cabecera Persona
           v_traza := 17;

           UPDATE per_personas
              SET nnumide = 'Z00000000',
                  fnacimi = f_parinstalacion_f('FECHA_LOPD'),
                  fjubila = f_parinstalacion_f('FECHA_LOPD'),
                  fdefunc = f_parinstalacion_f('FECHA_LOPD')
            WHERE sperson = rc.sperson;
         */ -- Detalle Persona
         v_traza := 18;

         UPDATE per_detper
            SET tapelli1 = '*',
                tapelli2 = '*',
                tnombre = '*',
                tsiglas = '*',
                tbuscar = '*'
          /*  CBANCAR = '00000000000000000000'*/
         WHERE  sperson = rc.sperson
            AND cagente = rc.cagente;

         /*Direcciones*/
         v_traza := 19;

         UPDATE per_direcciones
            SET tnomvia = '*',
                tcomple = '*',
                tdomici = '*'
          WHERE sperson = rc.sperson
            AND cagente = rc.cagente;
         /*Contactos*/
         v_traza := 20;

         UPDATE per_contactos
            SET tcomcon = '*',
                tvalcon = '*'
          WHERE sperson = rc.sperson
            AND cagente = rc.cagente;

         DELETE      per_documentos
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         /*Profesiones*/
         v_traza := 21;
         /* UPDATE per_profesion
             SET ncolegi = '*',
                 numprof = '*',
                 tempres = '*',
                 fantigue = f_parinstalacion_f('FECHA_LOPD'),
                 fjubila = f_parinstalacion_f('FECHA_LOPD')
           WHERE sperson = rc.sperson
             AND cagente = rc.cagente;
         */ --CCC
         v_traza := 22;

         UPDATE per_ccc
            SET cbancar = '00000000000000000000',
                fbaja = f_parinstalacion_f('FECHA_LOPD')
          WHERE sperson = rc.sperson
            AND cagente = rc.cagente;

         /*Updates Hisper*/
         /*Cabecera Persona*/
         v_traza := 23;

         UPDATE hisper_personas
            SET nnumide = 'Z00000000',
                fnacimi = f_parinstalacion_f('FECHA_LOPD'),
                fjubila = f_parinstalacion_f('FECHA_LOPD'),
                fdefunc = f_parinstalacion_f('FECHA_LOPD')
          WHERE sperson = rc.sperson;

         /* Detalle Persona*/
         v_traza := 24;

         UPDATE hisper_detper
            SET tapelli1 = '*',
                tapelli2 = '*',
                tnombre = '*',
                tsiglas = '*',
                tbuscar = '*'
          /* CBANCAR = '00000000000000000000'*/
         WHERE  sperson = rc.sperson
            AND cagente = rc.cagente;

         /*Direcciones*/
         v_traza := 25;

         UPDATE hisper_direcciones
            SET tnomvia = '*',
                tcomple = '*',
                tdomici = '*'
          WHERE sperson = rc.sperson
            AND cagente = rc.cagente;

         /*Contactos*/
         v_traza := 26;

         UPDATE hisper_contactos
            SET tcomcon = '*',
                tvalcon = '*'
          WHERE sperson = rc.sperson
            AND cagente = rc.cagente;

         /*Profesiones*/
         v_traza := 27;
         /*    UPDATE hisper_profesion
                SET ncolegi = '*',
                    numprof = '*',
                    tempres = '*',
                    fantigue = f_parinstalacion_f('FECHA_LOPD'),
                    fjubila = f_parinstalacion_f('FECHA_LOPD')
              WHERE sperson = rc.sperson
                AND cagente = rc.cagente;*/
         /*CCC*/
         v_traza := 28;

         UPDATE hisper_ccc
            SET cbancar = '00000000000000000000',
                fbaja = f_parinstalacion_f('FECHA_LOPD')
          WHERE sperson = rc.sperson
            AND cagente = rc.cagente;

         /*Vinculos*/
         DELETE      per_vinculos
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         DELETE      hisper_vinculos
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         /*Modifico per_lopd*/
         v_traza := 29;

         UPDATE per_lopd a
            SET a.cestado = 2
          WHERE a.sperson = rc.sperson
            AND a.cagente = rc.cagente
            AND a.norden = (SELECT MAX(norden)
                              FROM per_lopd b
                             WHERE b.sperson = a.sperson
                               AND b.cagente = a.cagente);

         vnumerr := f_bloqueo_documentacion(rc.sperson, rc.cagente);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_persona_lopd_bloqueo', v_traza,
                     'SPERSON = ' || v_tperso || ' cagente = ' || v_cagente, SQLERRM);
         RETURN 1;
   END f_persona_lopd_bloqueo;

   /***************************************************************************
           Función bloquear una persona por LOPD
           Traspasará los datos de la persona a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_bloquear_persona(psperson IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'parámetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_bloquear_persona';
      vcagente       NUMBER := pcagente;
      vcont          NUMBER;
      vcont0         NUMBER;
      vcont1         NUMBER;
      vcont2         NUMBER;
      vcont3         NUMBER;
      vcont4         NUMBER;
      v_max_seg      NUMBER;
      vcestado       NUMBER;
      vcancelacion   NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcont
        FROM tomadores t, seguros s
       WHERE t.sseguro = s.sseguro
         AND sperson = psperson
         AND ff_agente_cpervisio(s.cagente) = pcagente
         AND csituac IN(0, 5, 12, 14);

      /*f_vigente(s.sseguro, NULL, f_sysdate) = 0;*/
      IF vcont > 0 THEN
         RETURN 9903232;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM asegurados t, seguros s
       WHERE t.sseguro = s.sseguro
         AND sperson = psperson
         AND ff_agente_cpervisio(s.cagente) = pcagente
         AND csituac IN(0, 5, 12, 14);

      /*AND f_vigente(s.sseguro, NULL, f_sysdate) = 0;*/
      IF vcont > 0 THEN
         RETURN 9903233;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM riesgos t, seguros s
       WHERE t.sseguro = s.sseguro
         AND sperson = psperson
         AND ff_agente_cpervisio(s.cagente) = pcagente
         AND csituac IN(0, 5, 12, 14);

      /* AND f_vigente(s.sseguro, NULL, f_sysdate) = 0;*/
      IF vcont > 0 THEN
         RETURN 9903234;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM beneficiarios t, seguros s
       WHERE t.sseguro = s.sseguro
         AND sperson = psperson
         AND ff_agente_cpervisio(s.cagente) = pcagente
         AND csituac IN(0, 5, 12, 14);

      /*AND f_vigente(s.sseguro, NULL, f_sysdate) = 0;*/
      IF vcont > 0 THEN
         RETURN 9903235;
      END IF;

      SELECT COUNT(1)
        INTO vcont0
        FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, tomadores t
       WHERE t.sseguro = s.sseguro
         AND ss.sseguro = s.sseguro
         AND t.sperson = psperson
         AND ss.nsinies = sm.nsinies
         AND ff_agente_cpervisio(s.cagente) = pcagente
         AND sm.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro
                            WHERE nsinies = ss.nsinies)
         AND sm.cestsin IN(0, 4, 5, 6);

      SELECT COUNT(1)
        INTO vcont1
        FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, asegurados t
       WHERE t.sseguro = s.sseguro
         AND ss.sseguro = s.sseguro
         AND ss.nsinies = sm.nsinies
         AND t.sperson = psperson
         AND ff_agente_cpervisio(s.cagente) = pcagente
         AND sm.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro
                            WHERE nsinies = ss.nsinies)
         AND sm.cestsin IN(0, 4, 5, 6);

      SELECT COUNT(1)
        INTO vcont2
        FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, riesgos t
       WHERE t.sseguro = s.sseguro
         AND ss.sseguro = s.sseguro
         AND t.sperson = psperson
         AND ss.nsinies = sm.nsinies
         AND ff_agente_cpervisio(s.cagente) = pcagente
         AND sm.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro
                            WHERE nsinies = ss.nsinies)
         AND sm.cestsin IN(0, 4, 5, 6);

      SELECT COUNT(1)
        INTO vcont3
        FROM sin_siniestro ss, sin_movsiniestro sm
       WHERE (ss.sperson2 = psperson
              OR ss.dec_sperson = psperson)
         AND ss.nsinies = sm.nsinies
         AND sm.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro
                            WHERE nsinies = ss.nsinies)
         AND sm.cestsin IN(0, 4, 5, 6);

      SELECT COUNT(1)
        INTO vcont4
        FROM sin_siniestro ss, sin_movsiniestro sm, sin_tramita_destinatario std
       WHERE (std.sperson = psperson)
         AND ss.nsinies = sm.nsinies
         AND ss.nsinies = std.nsinies
         AND sm.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro
                            WHERE nsinies = ss.nsinies)
         AND sm.cestsin IN(0, 4, 5, 6);

      vcont := NVL(vcont0, 0) + NVL(vcont1, 0) + NVL(vcont2, 0) + NVL(vcont3, 0)
               + NVL(vcont4, 0);

      IF vcont > 0 THEN
         RETURN 9903236;   --'Persona con siniestros ;
      END IF;

      BEGIN
         SELECT NVL(MAX(norden), 0) + 1
           INTO v_max_seg
           FROM per_lopd
          WHERE sperson = psperson
            AND cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_max_seg := 1;
      END;

      IF v_max_seg <> 1 THEN
         BEGIN
            SELECT cestado, cancelacion
              INTO vcestado, vcancelacion
              FROM per_lopd
             WHERE sperson = psperson
               AND cagente = pcagente
               AND norden = (SELECT MAX(norden)
                               FROM per_lopd
                              WHERE sperson = psperson
                                AND cagente = pcagente
                                AND cestado IS NOT NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcestado := NULL;
         END;

         IF vcestado IS NOT NULL THEN
            IF vcestado IN(4) THEN   /*NO SE PUEDE BLOQUEAR, persona borrada*/
               RETURN 9903240;
            ELSIF vcestado = 2 THEN
               RETURN 9903244;
            END IF;
         END IF;

         INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden)
            (SELECT psperson, f_sysdate, f_user, 1, cesion, publicidad, 1, NULL, NULL, NULL,
                    NULL, pcagente, v_max_seg
               FROM per_lopd
              WHERE sperson = psperson
                AND cagente = pcagente
                AND norden = v_max_seg - 1);
      ELSE
         INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden)
              VALUES (psperson, f_sysdate, f_user, 1, NULL, NULL, 1,
                      NULL, NULL, NULL, NULL, pcagente, v_max_seg);
      END IF;

      /*ponemos la columna cestado a 1 (Pendent de bloquejar dades (Autoritzat)) y la columna cancelacion a 1 y bloqueamos*/
      /*  BEGIN*/
      /*bloqueamos la persona*/
      vnumerr := f_persona_lopd_bloqueo(psperson, pcagente);

      IF vnumerr <> 0 THEN
         RETURN 9903237;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_bloquear_persona', NULL, SQLCODE,
                     SQLERRM);
         RETURN 9903237;
   END f_bloquear_persona;

   FUNCTION f_retroceso_docsin_lopd(pnsinies IN VARCHAR2, pcempres IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      viddocbloq     NUMBER;
   BEGIN
      FOR i IN (SELECT nsinies, ntramit, ndocume, iddoc
                  FROM sin_tramita_documento_lopd
                 WHERE nsinies = pnsinies) LOOP
         UPDATE sin_tramita_documento
            SET iddoc = i.iddoc
          WHERE nsinies = i.nsinies
            AND ntramit = i.ntramit
            AND ndocume = i.ndocume;
      END LOOP;

      DELETE      sin_tramita_documento_lopd
            WHERE nsinies = pnsinies;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_retroceso_docsin_lopd', v_traza,
                     'pnsinies = ' || pnsinies, SQLERRM);
         RETURN 1;
   END f_retroceso_docsin_lopd;

   FUNCTION f_retroceso_docseg_lopd(psseguro IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      viddocbloq     NUMBER;
   BEGIN
      FOR i IN (SELECT seqdocu, sseguro, nmovimi, iddocgedox
                  FROM docrequerida_lopd
                 WHERE sseguro = psseguro) LOOP
         UPDATE docrequerida
            SET iddocgedox = i.iddocgedox
          WHERE seqdocu = i.seqdocu
            AND sseguro = i.sseguro
            AND nmovimi = i.nmovimi;
      END LOOP;

      DELETE      docrequerida_lopd
            WHERE sseguro = psseguro;

      FOR i IN (SELECT seqdocu, sseguro, nmovimi, ninqaval, iddocgedox
                  FROM docrequerida_lopd_inqaval
                 WHERE sseguro = psseguro) LOOP
         UPDATE docrequerida_inqaval
            SET iddocgedox = i.iddocgedox
          WHERE seqdocu = i.seqdocu
            AND sseguro = i.sseguro
            AND nmovimi = i.nmovimi
            AND ninqaval = i.ninqaval;
      END LOOP;

      DELETE      docrequerida_lopd_inqaval
            WHERE sseguro = psseguro;

      FOR i IN (SELECT seqdocu, sseguro, nmovimi, nriesgo, iddocgedox
                  FROM docrequerida_lopd_riesgo
                 WHERE sseguro = psseguro) LOOP
         UPDATE docrequerida_riesgo
            SET iddocgedox = i.iddocgedox
          WHERE seqdocu = i.seqdocu
            AND sseguro = i.sseguro
            AND nmovimi = i.nmovimi
            AND nriesgo = i.nriesgo;
      END LOOP;

      DELETE      docrequerida_lopd_riesgo
            WHERE sseguro = psseguro;

      FOR i IN (SELECT seqdocu, sseguro, nmovimi, nriesgo, iddocgedox
                  FROM docrequerida_lopd_benespseg
                 WHERE sseguro = psseguro) LOOP
         UPDATE docrequerida_benespseg
            SET iddocgedox = i.iddocgedox
          WHERE seqdocu = i.seqdocu
            AND sseguro = i.sseguro
            AND nmovimi = i.nmovimi
            AND nriesgo = i.nriesgo;
      END LOOP;

      DELETE      docrequerida_lopd_benespseg
            WHERE sseguro = psseguro;

      FOR i IN (SELECT sseguro, nmovimi, iddocgedox, corigen
                  FROM docummovseg_lopd
                 WHERE sseguro = psseguro) LOOP
         UPDATE docummovseg
            SET iddocgedox = i.iddocgedox
          WHERE sseguro = i.sseguro
            AND nmovimi = i.nmovimi;
      END LOOP;

      DELETE      docummovseg_lopd
            WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_retroceso_docseg_lopd', v_traza,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN 1;
   END f_retroceso_docseg_lopd;

   FUNCTION f_retoceso_blq_documentacion(psperson IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      vnumerr        NUMBER := 0;
      vcont          NUMBER := 0;
   BEGIN
      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM asegurados aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vcont := 1;
         vnumerr := f_retroceso_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      /* IF vcont = 0 THEN*/
      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM tomadores aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_retroceso_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM riesgos aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_retroceso_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM beneficiarios aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_retroceso_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, tomadores t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND t.sperson = psperson
                   AND ss.nsinies = sm.nsinies
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_retroceso_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, asegurados t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND t.sperson = psperson
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_retroceso_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, riesgos t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND t.sperson = psperson
                   AND ss.nsinies = sm.nsinies
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_retroceso_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM sin_siniestro ss, sin_movsiniestro sm, seguros s
                 WHERE (ss.sperson2 = psperson
                        OR ss.dec_sperson = psperson)
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_retroceso_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM sin_siniestro ss, sin_movsiniestro sm, sin_tramita_destinatario std,
                       seguros s
                 WHERE (std.sperson = psperson)
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND ss.nsinies = std.nsinies
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_retroceso_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_bloqueo_documentacion', v_traza,
                     'SPERSON = ' || psperson || ' cagente = ' || pcagente, SQLERRM);
         RETURN 1;
   END f_retoceso_blq_documentacion;

   /*
   Retroceso de los datos de LOPD
   */
   FUNCTION f_persona_lopd_retroceso(
      psperson IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR lopd IS
         SELECT sperson, cagente
           FROM per_lopd a
          WHERE a.cancelacion = 1
            AND a.cestado = 2
            AND(psperson IS NULL
                OR(psperson IS NOT NULL))
            AND(pcagente IS NULL
                OR(pcagente IS NOT NULL
                   AND pcagente = a.cagente))
            AND norden = (SELECT MAX(norden)
                            FROM per_lopd b
                           WHERE b.sperson = a.sperson
                             AND b.cagente = a.cagente);

      v_aux          NUMBER;
      v_traza        NUMBER;
      v_tperso       NUMBER;
      v_cagente      NUMBER;

      /*Cabecera Persona*/
      CURSOR lopd_per(psperson NUMBER) IS
         SELECT *
           FROM perlopd_personas
          WHERE sperson = psperson;

      /*Detalle persona*/
      CURSOR lopd_detper(psperson NUMBER, pcempres NUMBER) IS
         SELECT *
           FROM perlopd_detper
          WHERE sperson = psperson
            AND cagente = pcagente;

      /*Direcciones*/
      CURSOR lopd_dir(psperson NUMBER, pcempres NUMBER) IS
         SELECT *
           FROM perlopd_direcciones
          WHERE sperson = psperson
            AND cagente = pcagente;

      /*Contactos*/
      CURSOR lopd_con(psperson NUMBER, pcempres NUMBER) IS
         SELECT *
           FROM perlopd_contactos
          WHERE sperson = psperson
            AND cagente = pcagente;

      /*Profesion*/
      /* CURSOR lopd_pro(psperson NUMBER, pcempres NUMBER) IS
          SELECT *
            FROM perlopd_profesion
           WHERE sperson = psperson
             AND cagente = pcagente;*/
      /*CCC*/
      CURSOR lopd_ccc(psperson NUMBER, pcempres NUMBER) IS
         SELECT *
           FROM perlopd_ccc
          WHERE sperson = psperson
            AND cagente = pcagente;

      /*HISTORICOS*/
      /*Cabecera Persona*/
      CURSOR his_per(psperson NUMBER) IS
         SELECT *
           FROM hisperlopd_personas
          WHERE sperson = psperson;

      /*Detalle persona*/
      CURSOR his_detper(psperson NUMBER, pcempres NUMBER) IS
         SELECT *
           FROM hisperlopd_detper
          WHERE sperson = psperson
            AND cagente = pcagente;

      /*Direcciones*/
      CURSOR his_dir(psperson NUMBER, pcempres NUMBER) IS
         SELECT *
           FROM hisperlopd_direcciones
          WHERE sperson = psperson
            AND cagente = pcagente;

      /*Contactos*/
      CURSOR his_con(psperson NUMBER, pcempres NUMBER) IS
         SELECT *
           FROM hisperlopd_contactos
          WHERE sperson = psperson
            AND cagente = pcagente;

      /*Profesion*/
      /*  CURSOR his_pro(psperson NUMBER, pcempres NUMBER) IS
           SELECT *
             FROM hisperlopd_profesion
            WHERE sperson = psperson
              AND cagente = pcagente;*/
      /*CCC*/
      CURSOR his_ccc(psperson NUMBER, pcempres NUMBER) IS
         SELECT *
           FROM hisperlopd_ccc
          WHERE sperson = psperson
            AND cagente = pcagente;

      vnumerr        NUMBER := 0;
   BEGIN
      FOR rc IN lopd LOOP
         v_tperso := rc.sperson;
         v_cagente := rc.cagente;
         v_traza := 1;

         /*Borro la persona actual de per_personasnif*/
         /*delete per_personasnif where sperson = rc.sperson and cempres = rc.cempres;*/
         /*Compruebo si queda algun detalle para esta persona en alguna otra empresa*/
         /*   SELECT COUNT(1)
              INTO v_aux
              FROM perlopd_detper
             WHERE sperson = rc.sperson
               AND cagente <> rc.cagente;

            IF v_aux = 0 THEN
               DELETE      per_personasnif
                     WHERE sperson = rc.sperson;
            END IF;

            --Cabecera Persona
            FOR r_1 IN lopd_per(rc.sperson) LOOP
               v_traza := 2;

               UPDATE per_personas
                  SET nnumide =
                         DECODE
                            (v_aux,
                             0, r_1.nnumide   --Si no queda ninguna persona en per_personasnif recupera el nif original
                                           ,
                             'Z00000000'),
                      fnacimi = r_1.fnacimi,
                      fjubila = r_1.fjubila,
                      fdefunc = r_1.fdefunc
                WHERE sperson = rc.sperson;
            END LOOP;
         */
         /* Detalle Persona*/
         FOR r_2 IN lopd_detper(rc.sperson, rc.cagente) LOOP
            v_traza := 3;

            UPDATE per_detper
               SET tapelli1 = r_2.tapelli1,
                   tapelli2 = r_2.tapelli2,
                   tnombre = r_2.tnombre,
                   tsiglas = r_2.tsiglas,
                   tbuscar = r_2.tbuscar
             /*  CBANCAR = r_2.cbancar*/
            WHERE  sperson = rc.sperson
               AND cagente = rc.cagente;

         END LOOP;

         /*Direcciones*/
         FOR r_3 IN lopd_dir(rc.sperson, rc.cagente) LOOP
            v_traza := 4;

            UPDATE per_direcciones
               SET tnomvia = r_3.tnomvia,
                   tcomple = r_3.tcomple,
                   tdomici = r_3.tdomici
             WHERE sperson = rc.sperson
               AND cagente = rc.cagente;

         END LOOP;

         /*Contactos*/
         FOR r_4 IN lopd_con(rc.sperson, rc.cagente) LOOP
            v_traza := 5;

            UPDATE per_contactos
               SET tcomcon = r_4.tcomcon,
                   tvalcon = r_4.tvalcon
             WHERE sperson = rc.sperson
               AND cagente = rc.cagente;

         END LOOP;

         /*Profesiones*/
         /*  FOR r_5 IN lopd_pro(rc.sperson, rc.cagente) LOOP
              v_traza := 6;

              UPDATE per_profesion
                 SET ncolegi = r_5.ncolegi,
                     numprof = r_5.numprof,
                     tempres = r_5.tempres,
                     fantigue = r_5.fantigue,
                     fjubila = r_5.fjubila
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;
           END LOOP;*/
         /*CCC*/
         FOR r_6 IN lopd_ccc(rc.sperson, rc.cagente) LOOP
            v_traza := 7;

            UPDATE per_ccc
               SET cbancar = r_6.cbancar,
                   fbaja = r_6.fbaja
             WHERE sperson = rc.sperson
               AND cagente = rc.cagente;

         END LOOP;

         /*Updates Hisper*/
         /*Cabecera Persona*/
         FOR r_7 IN his_per(rc.sperson) LOOP
            v_traza := 8;

            UPDATE hisper_personas
               SET nnumide = DECODE(v_aux, 0, r_7.nnumide, 'Z00000000'),
                   /*Si no queda ninguna persona en per_personasnif recupera el nif original*/
                   fnacimi = r_7.fnacimi,
                   fjubila = r_7.fjubila,
                   fdefunc = r_7.fdefunc
             WHERE sperson = rc.sperson;
         END LOOP;

         /* Detalle Persona*/
         FOR r_8 IN his_detper(rc.sperson, rc.cagente) LOOP
            v_traza := 9;

            UPDATE hisper_detper
               SET tapelli1 = r_8.tapelli1,
                   tapelli2 = r_8.tapelli2,
                   tnombre = r_8.tnombre,
                   tsiglas = r_8.tsiglas,
                   tbuscar = r_8.tbuscar
             /*CBANCAR = r_8.cbancar*/
            WHERE  sperson = rc.sperson
               AND cagente = rc.cagente;
         END LOOP;

         /*Direcciones*/
         FOR r_9 IN his_dir(rc.sperson, rc.cagente) LOOP
            v_traza := 10;

            UPDATE hisper_direcciones
               SET tnomvia = r_9.tnomvia,
                   tcomple = r_9.tcomple,
                   tdomici = r_9.tdomici
             WHERE sperson = rc.sperson
               AND cagente = rc.cagente;
         END LOOP;

         /*Contactos*/
         FOR r_10 IN his_con(rc.sperson, rc.cagente) LOOP
            v_traza := 11;

            UPDATE hisper_contactos
               SET tcomcon = r_10.tcomcon,
                   tvalcon = r_10.tvalcon
             WHERE sperson = rc.sperson
               AND cagente = rc.cagente;
         END LOOP;

         /*Profesiones*/
         /*FOR r_11 IN his_pro(rc.sperson, rc.cempres) LOOP
            v_traza := 12;

            UPDATE hisper_profesion
               SET ncolegi = r_11.ncolegi,
                   numprof = r_11.numprof,
                   tempres = r_11.tempres,
                   fantigue = r_11.fantigue,
                   fjubila = r_11.fjubila
             WHERE sperson = rc.sperson
               AND cempres = rc.cempres;
         END LOOP;*/
         /*CCC*/
         FOR r_12 IN his_ccc(rc.sperson, rc.cagente) LOOP
            v_traza := 13;

            UPDATE hisper_ccc
               SET cbancar = r_12.cbancar,
                   fbaja = r_12.fbaja
             WHERE sperson = rc.sperson
               AND cagente = rc.cagente;
         END LOOP;

         /*Vinculos*/
         v_traza := 14;
         /* INSERT INTO per_vinculos
                      (sperson, cempres, cagente, cvinclo, swpubli, cusuari, fmovimi)
             (SELECT sperson, cempres, cagente, cvinclo, swpubli, cusuari, fmovimi
                FROM perlopd_vinculos
               WHERE sperson = rc.sperson
                 AND cempres = rc.cempres);

          v_traza := 15;

          INSERT INTO hisper_vinculos
                      (sperson, cempres, cagente, cvinclo, swpubli, cusuari, fmovimi, norden)
             (SELECT sperson, cempres, cagente, cvinclo, swpubli, cusuari, fmovimi, norden
                FROM hisperlopd_vinculos
               WHERE sperson = rc.sperson
                 AND cempres = rc.cempres);
         */ --Borro los datos de lopd
         v_traza := 16;

         DELETE FROM hisperlopd_ccc
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         v_traza := 17;
         /*  DELETE FROM hisperlopd_profesion
                 WHERE sperson = rc.sperson
                   AND cempres = rc.cempres;
         */
         v_traza := 18;
         /*   DELETE FROM hisperlopd_vinculos
                  WHERE sperson = rc.sperson
                    AND cempres = rc.cempres;
         */
         v_traza := 19;

         DELETE FROM hisperlopd_contactos
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         v_traza := 20;

         DELETE FROM hisperlopd_direcciones
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         v_traza := 21;

         DELETE FROM hisperlopd_detper
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         v_traza := 22;

         SELECT COUNT(1)
           INTO v_aux
           FROM hisperlopd_detper
          WHERE sperson = rc.sperson;

         IF v_aux = 0 THEN
            v_traza := 23;

            DELETE FROM hisperlopd_personas
                  WHERE sperson = rc.sperson;
         END IF;

         v_aux := 0;
         /*Tablas PERLOPD*/
         v_traza := 24;

         DELETE FROM perlopd_ccc
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         v_traza := 25;

         /* DELETE FROM perlopd_profesion
                WHERE sperson = rc.sperson
                  AND cempres = rc.cempres;

          v_traza := 26;

          DELETE FROM perlopd_vinculos
                WHERE sperson = rc.sperson
                  AND cempres = rc.cempres;

          v_traza := 27;*/
         DELETE FROM perlopd_contactos
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         v_traza := 28;

         DELETE FROM perlopd_direcciones
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         v_traza := 29;

         DELETE FROM perlopd_detper
               WHERE sperson = rc.sperson
                 AND cagente = rc.cagente;

         v_traza := 30;

         SELECT COUNT(1)
           INTO v_aux
           FROM perlopd_detper
          WHERE sperson = rc.sperson;

         IF v_aux = 0 THEN
            v_traza := 30;

            DELETE FROM perlopd_personas
                  WHERE sperson = rc.sperson;
         END IF;

         /*Modifico per_lopd*/
         v_traza := 31;

         UPDATE per_lopd a
            SET a.cestado = 0
          WHERE a.sperson = rc.sperson
            AND a.cagente = rc.cagente
            AND a.norden = (SELECT MAX(norden)
                              FROM per_lopd b
                             WHERE b.sperson = a.sperson
                               AND b.cagente = a.cagente);

         vnumerr := f_retoceso_blq_documentacion(rc.sperson, rc.cagente);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.F_PERSONA_LOPD_RETROCESO', v_traza,
                     'SPERSON = ' || v_tperso || ' CAGENTE = ' || v_cagente, SQLERRM);
         RETURN 1;
   END f_persona_lopd_retroceso;

   /***************************************************************************
     Función desbloquear una persona por LOPD
     Volverá a deja la persona igual que antes que el traspaso a las tablas LOPD
     *****************************************************************************/
   FUNCTION f_desbloquear_persona(psperson IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'parámetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_desbloquear_persona';
      vcagente       NUMBER := pcagente;
      vcont          NUMBER;
      v_max_seg      NUMBER;
      vcestado       NUMBER;
      vcancelacion   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL(MAX(norden), 0) + 1
           INTO v_max_seg
           FROM per_lopd
          WHERE sperson = psperson
            AND cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_max_seg := 1;
      END;

      IF v_max_seg <> 1 THEN
         BEGIN
            SELECT cestado, cancelacion
              INTO vcestado, vcancelacion
              FROM per_lopd
             WHERE sperson = psperson
               AND cagente = pcagente
               AND norden = (SELECT MAX(norden)
                               FROM per_lopd
                              WHERE sperson = psperson
                                AND cagente = pcagente
                                AND cestado IS NOT NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcestado := NULL;
         END;

         IF vcestado IS NOT NULL
            AND vcestado IN(0, 1, 4) THEN
            /*NO SE PUEDE desBLOQUEAR, persona no bloqueada*/
            RETURN 9903241;
         END IF;

         INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden)
            (SELECT psperson, f_sysdate, f_user, 2, cesion, publicidad, 1, NULL, NULL, NULL,
                    NULL, pcagente, v_max_seg
               FROM per_lopd
              WHERE sperson = psperson
                AND cagente = pcagente
                AND norden = v_max_seg - 1);
      ELSE
         INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden)
              VALUES (psperson, f_sysdate, f_user, 2, NULL, NULL, 1,
                      NULL, NULL, NULL, NULL, pcagente, v_max_seg);
      END IF;

      /*ponemos la columna cestado a 1 (Pendent de bloquejar dades (Autoritzat)) y la columna cancelacion a 1 y bloqueamos*/
      /*  BEGIN*/
      /*   INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden)
              VALUES (psperson, f_sysdate, f_user, 2, NULL, NULL, 1,
                      NULL, NULL, NULL, NULL, pcagente, v_max_seg);
      */
      /* EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
             UPDATE per_lopd
                SET cestado = 1,
                    cancelacion = 1
              WHERE sperson = psperson
                AND cagente = pcagente;
       END;*/
      /*bloqueamos la persona*/
      vnumerr := f_persona_lopd_retroceso(psperson, pcagente);

      IF vnumerr <> 0 THEN
         RETURN 9903238;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_bloquear_persona', NULL, SQLCODE,
                     SQLERRM);
         RETURN 9903238;
   END f_desbloquear_persona;

   FUNCTION f_borrar_docsin_lopd(pnsinies IN VARCHAR2, pcempres IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      viddocbloq     NUMBER;
   BEGIN
      DELETE      sin_tramita_documento_lopd
            WHERE nsinies = pnsinies;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_retroceso_docsin_lopd', v_traza,
                     'pnsinies = ' || pnsinies, SQLERRM);
         RETURN 1;
   END f_borrar_docsin_lopd;

   FUNCTION f_borrar_docseg_lopd(psseguro IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      viddocbloq     NUMBER;
   BEGIN
      DELETE      docrequerida_lopd
            WHERE sseguro = psseguro;

      DELETE      docrequerida_lopd_inqaval
            WHERE sseguro = psseguro;

      DELETE      docrequerida_lopd_benespseg
            WHERE sseguro = psseguro;

      DELETE      docrequerida_lopd_riesgo
            WHERE sseguro = psseguro;

      DELETE      docummovseg_lopd
            WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_retroceso_docseg_lopd', v_traza,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN 1;
   END f_borrar_docseg_lopd;

   /*
   Bloqueamos

   */
   FUNCTION f_borrar_blq_documentacion(psperson IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      v_traza        NUMBER := 0;
      vnumerr        NUMBER := 0;
      vcont          NUMBER := 0;
   BEGIN
      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM asegurados aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vcont := 1;
         vnumerr := f_borrar_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      /* IF vcont = 0 THEN*/
      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM tomadores aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_borrar_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM riesgos aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_borrar_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT aaa.sseguro, s.cempres
                  FROM beneficiarios aaa, seguros s
                 WHERE aaa.sperson = psperson
                   AND aaa.sseguro = s.sseguro
                   AND ff_agente_cpervisio(s.cagente) = pcagente) LOOP
         vnumerr := f_borrar_docseg_lopd(i.sseguro, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, tomadores t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND t.sperson = psperson
                   AND ss.nsinies = sm.nsinies
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_borrar_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, asegurados t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND t.sperson = psperson
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_borrar_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM seguros s, sin_siniestro ss, sin_movsiniestro sm, riesgos t
                 WHERE t.sseguro = s.sseguro
                   AND ss.sseguro = s.sseguro
                   AND t.sperson = psperson
                   AND ss.nsinies = sm.nsinies
                   AND ff_agente_cpervisio(s.cagente) = pcagente
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_borrar_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM sin_siniestro ss, sin_movsiniestro sm, seguros s
                 WHERE (ss.sperson2 = psperson
                        OR ss.dec_sperson = psperson)
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_borrar_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      FOR i IN (SELECT ss.nsinies, s.cempres
                  FROM sin_siniestro ss, sin_movsiniestro sm, sin_tramita_destinatario std,
                       seguros s
                 WHERE (std.sperson = psperson)
                   AND ss.sseguro = s.sseguro
                   AND ss.nsinies = sm.nsinies
                   AND ss.nsinies = std.nsinies
                   AND sm.nmovsin = (SELECT MAX(nmovsin)
                                       FROM sin_movsiniestro
                                      WHERE nsinies = ss.nsinies)
                   AND sm.cestsin IN(0, 4, 5, 6)) LOOP
         vnumerr := f_borrar_docsin_lopd(i.nsinies, i.cempres);

         IF vnumerr <> 0 THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_bloqueo_documentacion', v_traza,
                     'SPERSON = ' || psperson || ' cagente = ' || pcagente, SQLERRM);
         RETURN 1;
   END f_borrar_blq_documentacion;

   /*
   Borra persona lopd
   */
   FUNCTION f_persona_lopd_borrar(
      psperson IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR lopd IS
         SELECT sperson, cagente
           FROM per_lopd a
          WHERE a.cancelacion = 1
            AND a.cestado = 3
            AND(psperson IS NULL
                OR(psperson IS NOT NULL
                   AND psperson = a.sperson))
            AND(pcagente IS NULL
                OR(pcagente IS NOT NULL
                   AND pcagente = a.cagente))
            AND norden = (SELECT MAX(norden)
                            FROM per_lopd b
                           WHERE b.sperson = a.sperson
                             AND b.cagente = a.cagente);

      vnorden        NUMBER;
      v_aux          NUMBER;
      v_ass          NUMBER := 0;
      v_traza        NUMBER := 1;
      v_tperso       personas.sperson%TYPE;
      v_cagente      NUMBER;
      vnumerr        NUMBER := 0;
   BEGIN
      FOR rc IN lopd LOOP
         v_aux := 0;
         v_ass := 0;
         v_tperso := rc.sperson;
         v_cagente := rc.cagente;
         v_traza := 1;

         /*Validación de poliza vigente*/
         SELECT COUNT(1)
           INTO v_aux
           FROM seguros s, tomadores t
          WHERE t.sperson = rc.sperson
            AND t.sseguro = s.sseguro
            AND ff_agente_cpervisio(s.cagente) = rc.cagente
            AND s.csituac IN(0, 5);

         SELECT COUNT(1)
           INTO v_ass
           FROM seguros s, asegurados a
          WHERE a.sperson = rc.sperson
            AND a.sseguro = s.sseguro
            AND ff_agente_cpervisio(s.cagente) = rc.cagente
            AND s.csituac IN(0, 5);

         v_aux := NVL(v_aux, 0) + NVL(v_ass, 0);

         IF v_aux = 0 THEN
            /*Si no tiene ninguna poliza vigente entonces*/
            DELETE FROM hisperlopd_ccc
                  WHERE sperson = rc.sperson
                    AND cagente = rc.cagente;

            v_traza := 2;
            /*  DELETE FROM hisperlopd_profesion
                    WHERE sperson = rc.sperson
                      AND cagente = rc.cagente;

              v_traza := 3;

              DELETE FROM hisperlopd_vinculos
                    WHERE sperson = rc.sperson
                      AND cagente = rc.cagente;*/
            v_traza := 4;

            DELETE FROM hisperlopd_contactos
                  WHERE sperson = rc.sperson
                    AND cagente = rc.cagente;

            v_traza := 5;

            DELETE FROM hisperlopd_direcciones
                  WHERE sperson = rc.sperson
                    AND cagente = rc.cagente;

            v_traza := 6;

            DELETE FROM hisperlopd_detper
                  WHERE sperson = rc.sperson
                    AND cagente = rc.cagente;

            v_traza := 7;

            SELECT COUNT(1)
              INTO v_aux
              FROM hisperlopd_detper
             WHERE sperson = rc.sperson;

            IF v_aux = 0 THEN
               v_traza := 8;

               DELETE FROM hisperlopd_personas
                     WHERE sperson = rc.sperson;
            END IF;

            v_aux := 0;
            /*Tablas PERLOPD*/
            v_traza := 9;

            DELETE FROM perlopd_ccc
                  WHERE sperson = rc.sperson
                    AND cagente = rc.cagente;

            v_traza := 10;
            /*  DELETE FROM perlopd_profesion
                    WHERE sperson = rc.sperson
                      AND cagente = rc.cagente;

              v_traza := 11;

              DELETE FROM perlopd_vinculos
                    WHERE sperson = rc.sperson
                      AND cagente = rc.cagente;
            */
            v_traza := 12;

            DELETE FROM perlopd_contactos
                  WHERE sperson = rc.sperson
                    AND cagente = rc.cagente;

            v_traza := 13;

            DELETE FROM perlopd_direcciones
                  WHERE sperson = rc.sperson
                    AND cagente = rc.cagente;

            v_traza := 14;

            DELETE FROM perlopd_detper
                  WHERE sperson = rc.sperson
                    AND cagente = rc.cagente;

            v_traza := 15;

            SELECT COUNT(1)
              INTO v_aux
              FROM perlopd_detper
             WHERE sperson = rc.sperson;

            IF v_aux = 0 THEN
               v_traza := 16;

               DELETE FROM perlopd_personas
                     WHERE sperson = rc.sperson;
            END IF;

            v_aux := 0;
            v_traza := 17;

            DELETE FROM hisper_lopd_cestado
                  WHERE sperson = rc.sperson;

            /*Modifico per_lopd (CESTADO = BORRADO)*/
            v_traza := 17;

            UPDATE per_lopd a
               SET cestado = 4
             WHERE a.sperson = rc.sperson
               AND a.cagente = rc.cagente
               AND a.norden = (SELECT MAX(norden)
                                 FROM per_lopd b
                                WHERE b.sperson = a.sperson
                                  AND b.cagente = a.cagente);

            vnumerr := f_borrar_blq_documentacion(rc.sperson, rc.cagente);
         ELSE
            p_tab_error(f_sysdate, f_user, 'P_PERSONA_LOPD_BORRAR', v_traza,
                        'La persona tiene polizas Vigentes ' || 'SPERSON = ' || v_tperso
                        || ' cagente = ' || v_cagente,
                        SQLERRM);
            RETURN 9903232;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.F_PERSONA_LOPD_BORRAR', v_traza,
                     'SPERSON = ' || v_tperso || ' cagente = ' || v_cagente, SQLERRM);
         RETURN 1;
   END f_persona_lopd_borrar;

   /***************************************************************************
   Función que prepara a la persona para ser borrada
   *****************************************************************************/
   FUNCTION f_borrar_persona_lopd(psperson IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'parámetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_borrar_persona';
      vcagente       NUMBER := pcagente;
      vcont          NUMBER;
      v_max_seg      NUMBER;
      vcestado       NUMBER;
      vcancelacion   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL(MAX(norden), 0) + 1
           INTO v_max_seg
           FROM per_lopd
          WHERE sperson = psperson
            AND cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_max_seg := 1;
      END;

      IF v_max_seg <> 1 THEN
         BEGIN
            SELECT cestado, cancelacion
              INTO vcestado, vcancelacion
              FROM per_lopd
             WHERE sperson = psperson
               AND cagente = pcagente
               AND norden = (SELECT MAX(norden)
                               FROM per_lopd
                              WHERE sperson = psperson
                                AND cagente = pcagente
                                AND cestado IS NOT NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcestado := NULL;
         END;

         IF vcestado IS NOT NULL
            AND vcestado NOT IN(2) THEN
            IF vcestado = 4 THEN
               RETURN 9903243;
            ELSE
               RETURN 9903242;
            END IF;
         ELSIF vcestado IS NULL THEN
            RETURN 9903242;
         END IF;

         INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden)
            (SELECT psperson, f_sysdate, f_user, 3, cesion, publicidad, 1, NULL, NULL, NULL,
                    NULL, pcagente, v_max_seg
               FROM per_lopd
              WHERE sperson = psperson
                AND cagente = pcagente
                AND norden = v_max_seg - 1);
      ELSE
         INSERT INTO per_lopd
                     (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                      ctipdoc, ftipdoc, catendido, fatendido, cagente, norden)
              VALUES (psperson, f_sysdate, f_user, 3, NULL, NULL, 1,
                      NULL, NULL, NULL, NULL, pcagente, v_max_seg);
      END IF;

      /*ponemos la columna cestado a 1 (Pendent de bloquejar dades (Autoritzat)) y la columna cancelacion a 1 y bloqueamos*/
      /*  BEGIN*/
      /*INSERT INTO per_lopd
                  (sperson, fmovimi, cusuari, cestado, cesion, publicidad, cancelacion,
                   ctipdoc, ftipdoc, catendido, fatendido, cagente, norden)
           VALUES (psperson, f_sysdate, f_user, 3, NULL, NULL, 1,
                   NULL, NULL, NULL, NULL, pcagente, v_max_seg);

      */
      /* EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
           UPDATE per_lopd
              SET cestado = 1,
                  cancelacion = 1
            WHERE sperson = psperson
              AND cagente = pcagente;
      END;*/
      /*bloqueamos la persona*/
      vnumerr := f_persona_lopd_borrar(psperson, pcagente);

      IF vnumerr <> 0 THEN
         IF vnumerr <> 1 THEN
            RETURN 9903239;
         ELSE
            RETURN vnumerr;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_borrar_persona_lopd', NULL, SQLCODE,
                     SQLERRM);
         RETURN 9903239;
   END f_borrar_persona_lopd;

   /*Se mira si la póliza tiene una figura bloqueada por LOPD.*/
   FUNCTION f_esta_persona_bloqueada(psseguro IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      vcont          NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcont
        FROM tomadores aaa, seguros s, per_lopd p
       WHERE aaa.sperson = p.sperson
         AND aaa.sseguro = s.sseguro
         AND s.sseguro = psseguro
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND ff_agente_cpervisio(s.cagente) = p.cagente;

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM asegurados aaa, seguros s, per_lopd p
       WHERE aaa.sperson = p.sperson
         AND aaa.sseguro = s.sseguro
         AND s.sseguro = psseguro
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND ff_agente_cpervisio(s.cagente) = p.cagente;

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM riesgos aaa, seguros s, per_lopd p
       WHERE aaa.sperson = p.sperson
         AND aaa.sseguro = s.sseguro
         AND s.sseguro = psseguro
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND ff_agente_cpervisio(s.cagente) = p.cagente;

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM beneficiarios aaa, seguros s, per_lopd p
       WHERE aaa.sperson = p.sperson
         AND aaa.sseguro = s.sseguro
         AND s.sseguro = psseguro
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND ff_agente_cpervisio(s.cagente) = p.cagente;

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_esta_persona_bloqueada', NULL, SQLCODE,
                     SQLERRM);
         RETURN 0;   /*Si hi ha error el donem com a no bloquejat*/
   END f_esta_persona_bloqueada;

   /*Se mira si la póliza tiene una figura bloqueada por LOPD en seguros y siniestros*/
   FUNCTION f_esta_persona_bloqueada_sinis(
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pcagente IN NUMBER)
      RETURN NUMBER IS
      vcont          NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcont
        FROM tomadores aaa, seguros s, per_lopd p
       WHERE aaa.sperson = p.sperson
         AND aaa.sseguro = s.sseguro
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND ff_agente_cpervisio(s.cagente) = p.cagente;

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM asegurados aaa, seguros s, per_lopd p
       WHERE aaa.sperson = p.sperson
         AND aaa.sseguro = s.sseguro
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND ff_agente_cpervisio(s.cagente) = p.cagente;

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM riesgos aaa, seguros s, per_lopd p
       WHERE aaa.sperson = p.sperson
         AND aaa.sseguro = s.sseguro
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND ff_agente_cpervisio(s.cagente) = p.cagente;

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM beneficiarios aaa, seguros s, per_lopd p
       WHERE aaa.sperson = p.sperson
         AND aaa.sseguro = s.sseguro
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND ff_agente_cpervisio(s.cagente) = p.cagente;

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM sin_siniestro ss, sin_movsiniestro sm, seguros s, per_lopd p
       WHERE (ss.sperson2 = p.sperson
              OR ss.dec_sperson = p.sperson)
         AND ss.sseguro = s.sseguro
         AND ss.nsinies = pnsinies
         AND ss.nsinies = sm.nsinies
         AND ff_agente_cpervisio(s.cagente) = p.cagente
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND sm.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro
                            WHERE nsinies = ss.nsinies);

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM sin_siniestro ss, sin_movsiniestro sm, sin_tramita_destinatario std, seguros s,
             per_lopd p
       WHERE (std.sperson = p.sperson)
         AND ss.sseguro = s.sseguro
         AND ss.nsinies = sm.nsinies
         AND ss.nsinies = std.nsinies
         AND ss.nsinies = pnsinies
         AND ff_agente_cpervisio(s.cagente) = p.cagente
         AND p.cestado IN(4, 2)   /*dades bloquejades o borrades*/
         AND p.norden = (SELECT MAX(pll.norden)
                           FROM per_lopd pll
                          WHERE pll.sperson = p.sperson
                            AND pll.cagente = p.cagente)
         AND sm.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro
                            WHERE nsinies = ss.nsinies);

      IF vcont > 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_esta_persona_bloqueada_sinis', NULL,
                     SQLCODE, SQLERRM);
         RETURN 0;   /*Si hi ha error el donem com a no bloquejat*/
   END f_esta_persona_bloqueada_sinis;

   /**************************************************************
    Funció que inserta en PER_CONTACTOS_AUT
    param in psperson : codigo de persona
    param in pcagente : codigo del agente
    param in pctipcon
    param in psmodcon
    param in ptvalcon
    param in ptipmov
    return codigo error : 0 - ok ,codigo de error
    BUG 18949/103391 - 31/01/2012 - AMC
   **************************************************************/
   FUNCTION f_ins_contacto_aut(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipcon IN NUMBER,
      psmodcon IN OUT NUMBER,
      ptvalcon IN VARCHAR2,
      ptipmov IN VARCHAR2,
      pcidioma IN NUMBER,
      pcdomici IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
      i              NUMBER := 1;
      vnorden        NUMBER;
      ex_error       EXCEPTION;
      v_valcon       NUMBER;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      /* Ini bug 30417/11671 -- ECP -- 07/03/2014*/
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PER_VAL_TELEF'),
             0) = 1 THEN
    --INI-CES-IAXIS-3241
               IF pctipcon IN(1, 2, 5, 6) THEN
    --END-CES-IAXIS-3241   
            BEGIN
               v_valcon := TO_NUMBER(ptvalcon);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE ex_error;
            END;
         END IF;
      END IF;

      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM per_contactos_aut
       WHERE sperson = psperson
         AND cmodcon = psmodcon;

      INSERT INTO per_contactos_aut
                  (sperson, cagente, cmodcon, norden, ctipcon, tvalcon, cusumod,
                   fusumod, fbaja, cestado, cdomici)
           VALUES (psperson, pcagente, psmodcon, vnorden, pctipcon, ptvalcon, f_user,
                   f_sysdate, DECODE(ptipmov, 'M', NULL, 'B', f_sysdate), 1, pcdomici);

      RETURN 0;
   EXCEPTION
      /* Ini bug 30417/11671 -- ECP -- 07/03/2014*/
      WHEN ex_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     'f_set_Contacto.Error '
                     || f_axis_literales(9906609, pac_md_common.f_get_cxtidioma),
                     SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(9906609,
                                     f_axis_literales(9906609, pac_md_common.f_get_cxtidioma));
         /*Valor No numérico para contacto telefónico.*/
         errores(i) := verr;
         RETURN 1;   /* Fin bug 30417/11671 -- ECP -- 07/03/2014*/
      WHEN OTHERS THEN
         errores.EXTEND;
         verr := ob_error.instanciar(140269,
                                     f_axis_literales(140269, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
         RETURN 1;   /* Error no controlado*/
   END f_ins_contacto_aut;

   /**************************************************************
     Funció que inserta en PER_DIRECCIONES_AUT
     return codigo error : 0 - ok ,codigo de error
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_ins_direccion_aut(
      psperson IN estper_direcciones.sperson%TYPE,
      pcagente IN estper_direcciones.cagente%TYPE,
      pcdomici IN OUT estper_direcciones.cdomici%TYPE,
      pctipdir IN estper_direcciones.ctipdir%TYPE,
      pcsiglas IN estper_direcciones.csiglas%TYPE,
      ptnomvia IN estper_direcciones.tnomvia%TYPE,
      pnnumvia IN estper_direcciones.nnumvia%TYPE,
      ptcomple IN estper_direcciones.tcomple%TYPE,
      ptdomici IN estper_direcciones.tdomici%TYPE,
      pcpostal IN estper_direcciones.cpostal%TYPE,
      pcpoblac IN estper_direcciones.cpoblac%TYPE,
      pcprovin IN estper_direcciones.cprovin%TYPE,
      pcusuari IN estper_direcciones.cusuari%TYPE,
      pfmovimi IN estper_direcciones.fmovimi%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      errores IN OUT t_ob_error,
      ptipmov IN VARCHAR2 DEFAULT 'M',
      pcviavp IN estper_direcciones.cviavp%TYPE,
      pclitvp IN estper_direcciones.clitvp%TYPE,
      pcbisvp IN estper_direcciones.cbisvp%TYPE,
      pcorvp IN estper_direcciones.corvp%TYPE,
      pnviaadco IN estper_direcciones.nviaadco%TYPE,
      pclitco IN estper_direcciones.clitco%TYPE,
      pcorco IN estper_direcciones.corco%TYPE,
      pnplacaco IN estper_direcciones.nplacaco%TYPE,
      pcor2co IN estper_direcciones.cor2co%TYPE,
      pcdet1ia IN estper_direcciones.cdet1ia%TYPE,
      ptnum1ia IN estper_direcciones.tnum1ia%TYPE,
      pcdet2ia IN estper_direcciones.cdet2ia%TYPE,
      ptnum2ia IN estper_direcciones.tnum2ia%TYPE,
      pcdet3ia IN estper_direcciones.cdet3ia%TYPE,
      ptnum3ia IN estper_direcciones.tnum3ia%TYPE,
      plocalidad IN estper_direcciones.localidad%TYPE
                                                     /* Bug 24780/130907 - 05/12/2012 - AMC*/
   )
      RETURN NUMBER IS
      verr           ob_error;
      i              NUMBER := 1;
      vnorden        NUMBER;
   BEGIN
      SELECT NVL(MAX(norden), 0) + 1
        INTO vnorden
        FROM per_direcciones_aut
       WHERE sperson = psperson
         AND cdomici = pcdomici;

      INSERT INTO per_direcciones_aut
                  (sperson, cagente, cdomici, norden, ctipdir, csiglas, tnomvia,
                   nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin, cusumod,
                   fusumod, cviavp, clitvp, cbisvp, corvp, nviaadco, clitco, corco,
                   nplacaco, cor2co, cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia,
                   tnum3ia, fbaja, cestado,
                   localidad /* Bug 24780/130907 - 05/12/2012 - AMC*/)
           VALUES (psperson, pcagente, pcdomici, vnorden, pctipdir, pcsiglas, ptnomvia,
                   pnnumvia, ptcomple, ptdomici, pcpostal, pcpoblac, pcprovin, f_user,
                   f_sysdate, pcviavp, pclitvp, pcbisvp, pcorvp, pnviaadco, pclitco, pcorco,
                   pnplacaco, pcor2co, pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia,
                   ptnum3ia, DECODE(ptipmov, 'M', NULL, 'B', f_sysdate), 1,
                   plocalidad /* Bug 24780/130907 - 05/12/2012 - AMC*/);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(140269,
                                     f_axis_literales(140269, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
         RETURN 1;   /* Error no controlado*/
   END f_ins_direccion_aut;

   /**************************************************************
     Funció que actualiza PER_CONTACTOS_AUT
     return codigo error : 0 - ok ,codigo de error
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_contacto_aut(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcmodcon IN NUMBER,
      pnorden IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcidioma IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
      i              NUMBER := 1;
   BEGIN
      UPDATE per_contactos_aut
         SET cestado = pcestado,
             tobserva = ptobserva,
             cusuaut = f_user,
             fautoriz = f_sysdate
       WHERE sperson = psperson
         AND cmodcon = pcmodcon
         AND norden = pnorden
         AND cagente = pcagente;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(140269,
                                     f_axis_literales(140269, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
         RETURN 1;   /* Error no controlado*/
   END f_set_contacto_aut;

   /**************************************************************
     Funció que actualiza PER_DIRECCIONES_AUT
     return codigo error : 0 - ok ,codigo de error
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_direccion_aut(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcdomici IN NUMBER,
      pnorden IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcidioma IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
      i              NUMBER := 1;
   BEGIN
      UPDATE per_direcciones_aut
         SET cestado = pcestado,
             tobserva = ptobserva,
             cusuaut = f_user,
             fautoriz = f_sysdate
       WHERE sperson = psperson
         AND cdomici = pcdomici
         AND norden = pnorden;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(140269,
                                     f_axis_literales(140269, pcidioma) || '  ' || SQLERRM);
         errores(i) := verr;
         RETURN 1;   /* Error no controlado*/
   END f_set_direccion_aut;

   /*INI BUG 22642 -- ETM --24/07/2012*/
   /**************************************************************
      FUNCION f_get_inquiaval
      Obtiene la select con los inquilinos avalistas
        param in psperson   : Codi sperson
         param in pctipfig    : Codi id de avalista o inqui(1 inquilino , 2 Avalista )
        param out psquery   : Select
        return              : 0.- OK, 1.- KO
   **************************************************************/
   FUNCTION f_get_inquiaval(
      psperson IN NUMBER,
      pctipfig IN NUMBER,
      /* 1 inquilino , 2 Avalista Desde java le pasamos el tipo*/
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
            := 'psperson=' || psperson || ' pctipfig=' || pctipfig || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_inquiaval';
   /*f_get_profesionales';*/
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pctipfig IS NULL
         OR pcidioma IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      vpasexec := 2;
      psquery :=
         'SELECT s.sseguro, a.nriesgo, f_formatopol(npoliza, ncertif, 1) poliza, s.cramo, s.cmodali,'
         || ' f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, ' || pcidioma
         || ') tproducto,'
         || ' NVL(a.FFECFIN, s.fanulac) fanulac, s.cagente, f_desagente_t(s.cagente) tagente, a.FFECINI,'
         || ' a.ctipfig ,ff_desvalorfijo(800099,' || pcidioma || ', a.ctipfig) tcipfig,'
         || ' a.iingrmen, a.iingranual,' || ' a.CSITLABORAL, ff_desvalorfijo(800087, '
         || pcidioma || ', a.CSITLABORAL) tsitlaboral,'
         || ' a.ctipcontrato, ff_desvalorfijo(800088, ' || pcidioma
         || ', a.ctipcontrato) ttipcontrato,' || ' a.csupfiltro, ff_desvalorfijo(108, '
         || pcidioma || ', a.csupfiltro) tsupfiltro' || ' FROM seguros s, inquiaval a'
         || ' WHERE s.sseguro = a.sseguro' || ' AND a.sperson =' || psperson
         || ' and a.ctipfig =' || pctipfig || ' AND s.cagente IN(SELECT cagente '
         || ' FROM agentes_agente_pol)' || ' ORDER BY 3';
      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_inquiaval;

   /**************************************************************
      FUNCION f_get_gescobro
      Obtiene la select con los gestores de cobro
        param in psperson   : Codi sperson
        paran in pcidioma  :codi de idioma
        param out psquery   : Select
        return              : 0.- OK, 1.- KO
   **************************************************************/
   FUNCTION f_get_gescobro(psperson IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psperson=' || psperson || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_gescobro';
   BEGIN
      /* Control parametros entrada*/
      IF psperson IS NULL
         OR pcidioma IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      vpasexec := 2;
      psquery :=
         'SELECT s.sseguro, f_formatopol(npoliza, ncertif, 1) poliza, s.cramo, s.cmodali, '
         || ' f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, ' || pcidioma
         || ' ) tproducto, s.fanulac,'
         || ' s.cagente, f_desagente_t(s.cagente) tagente, a.falta'
         || ' FROM seguros s, gescobros a' || ' WHERE s.sseguro = a.sseguro'
         || ' AND a.sperson = ' || psperson || ' AND s.cagente IN (SELECT cagente'
         || ' FROM agentes_agente_pol)';
      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 111715;
   END f_get_gescobro;

/*FIN BUG 22642 -- ETM --24/07/2012*/
/***********************************************************/
/*   F_NIF  : Obte el nif o el cif amb la lletra correcta.*/
/*            Si hi ha problema retorna un numero de error, si no 0.*/
/*   Retorna:*/
/*   0 - nif correcte.*/
/*   101249 - nif/cif null.*/
/*   101250 - longitud nif/cif incorrecte. --> 9902747*/
/*   101251 - lletra nif/cif incorrecte. --> 9903641*/
/*   101506 - digit cif incorrecte.*/
/*   101657 - nif sense lletra.*/
/*   MSR : Simplificacions i millora 29/01/2008*/
/*   JTS : Adaptació nou format d'identificador de sistema 14/01/2009*/
/*   Bug 23417/123957 - 18/10/2012 - AMC*/
/***********************************************************/
   FUNCTION f_nif(pctipide IN NUMBER, pnnumide IN OUT VARCHAR2)
      RETURN NUMBER IS
      lletresnif CONSTANT VARCHAR2(23) := 'TRWAGMYFPDXBNJZSQVHLCKE';
      lletresinicialscif CONSTANT VARCHAR2(20) := 'ABCDEFGJHNPQRSUVWYZ';
      lletrescif CONSTANT VARCHAR2(10) := 'ABCDEFGHIJ';
      w_caracter     VARCHAR2(1);   /* Primer caràcter*/
      w_long         NUMBER;
      w_c            VARCHAR2(1);   /* Caràcter*/
      w_n            VARCHAR2(8);   /* Part numèrica*/
      w_x            VARCHAR2(1);   /* Càracter final per CIF*/
      w_a            VARCHAR2(1);
      /* Lletra de la validació del CIF*/
      w_d            VARCHAR2(1);
      /* Dígit de la validació del CIF*/
      w_r_aux        NUMBER;
      sw_nif         NUMBER;
      w_r            NUMBER;
      w_dif          NUMBER;
   BEGIN
      w_caracter := UPPER(SUBSTR(pnnumide, 1, 1));
      /* Els que comencen per ZZ o CF no es validen*/
      /*Validem tots els NIF o CIF, idependentment com comencin, s'hauria de mirar per ctipdoc.*/
      /*Bug 22787 Nota : 118838*/
      /* IF SUBSTR(w_nif, 1, 2) = 'ZZ'
          OR SUBSTR(w_nif, 1, 2) = 'CF' THEN
          RETURN 0;
       END IF;*/
      w_long := LENGTH(pnnumide);

      IF w_long < 8
         OR w_long > 12 THEN
         /* Bug 22053 - MDS - 27/04/2012*/
           /*RETURN 101250;   -- longitud nif incorrecta*/
         RETURN 9902747;   /* longitud nif incorrecta*/
      END IF;

      IF pnnumide IS NULL
         OR pnnumide = ' ' THEN
         RETURN 101249;   /* nif null*/
      END IF;

      IF w_caracter IN('K', 'L', 'M') THEN
         sw_nif := 4;   /* NIF Especials*/
         w_c := w_caracter;
         w_n := SUBSTR(pnnumide, 2, 7);
         w_x := SUBSTR(pnnumide, 9, 1);
      ELSIF w_caracter IN('X', 'T', 'Y', 'Z') THEN
         sw_nif := 3;   /* NIE*/
         w_c := w_caracter;
         w_n := LPAD(SUBSTR(pnnumide, 2, 7), 7, '0');
         /* Nota: alguns NIE no ténen els 0 a l'esquerra*/
         w_x := SUBSTR(pnnumide, 9, 1);
      ELSIF ASCII(w_caracter) >= 65
            AND ASCII(w_caracter) <= 90 THEN   /* Lletres*/
         sw_nif := 2;   /* CIF;*/
         w_c := w_caracter;
         w_n := SUBSTR(pnnumide, 2, 7);
         w_x := SUBSTR(pnnumide, 9, 1);
      ELSIF ASCII(w_caracter) >= 48
            AND ASCII(w_caracter) <= 57 THEN   /* Números*/
         sw_nif := 1;   /* NIF*/
         w_x := SUBSTR(UPPER(pnnumide), 9, 1);
         w_n := SUBSTR(pnnumide, 1, 8);
      ELSE
         RETURN 101657;
      END IF;

      /* Bug 23417/123957 - 18/10/2012 - AMC*/
      IF (pctipide = 1
          AND sw_nif != 1
          AND sw_nif != 4)   /* NIF*/
         OR(pctipide = 4
            AND sw_nif != 3)   /* NIE*/
         OR(pctipide = 2
            AND sw_nif != 2)   /*CIF*/
                            THEN
         RETURN 9902749;
      END IF;

      /* Fi Bug 23417/123957 - 18/10/2012 - AMC*/
      BEGIN
         IF sw_nif = 1
            OR sw_nif = 3 THEN   /* NIE i NIF es validen igual*/
            IF (LENGTH(w_n) <> 8
                AND sw_nif = 1)
               OR(LENGTH(w_n) <> 7
                  AND sw_nif = 3) THEN
               /* Bug 22053 - MDS - 27/04/2012*/
               /* Bug 22053 - MDS - 27/04/2012*/
                 /*RETURN 101250;*/
               RETURN 9902747;
            END IF;

            IF w_x IS NULL THEN
               /* Bug 22053 - MDS - 27/04/2012*/
                 /*RETURN 101250;   -- Falta el dígit de control final*/
               RETURN 9902747;   /* Falta el dígit de control final*/
            END IF;

            /* MSR 17/12/2008*/
              /* Y i Z es calculen de forma especial*/
            w_n := TO_NUMBER(CASE w_caracter
                                WHEN 'Z' THEN '2' || TO_CHAR(w_n)
                                WHEN 'Y' THEN '1' || TO_CHAR(w_n)
                                ELSE TO_CHAR(w_n)
                             END);

            IF SUBSTR(lletresnif, MOD(TO_NUMBER(w_n), 23) + 1, 1) <> w_x THEN
               /* Bug 22053 - MDS - 27/04/2012*/
                 /*RETURN 101251;*/
               RETURN 9903641;
            END IF;
         ELSE   /* CIF i NIF especial es validen igual*/
            IF LENGTH(w_n) <> 7 THEN
               /* Bug 22053 - MDS - 27/04/2012*/
                 /*RETURN 101250;*/
               RETURN 9902747;
            END IF;

            IF w_x IS NULL THEN
               /* Bug 22053 - MDS - 27/04/2012*/
                 /*RETURN 101250;   -- Falta el dígit de control final*/
               RETURN 9902747;   /* Falta el dígit de control final*/
            END IF;

            w_r := 0;

            FOR i IN 1 .. 7 LOOP
               IF MOD(i, 2) = 0 THEN   /* posició parell*/
                  w_r := w_r + TO_NUMBER(SUBSTR(w_n, i, 1));
               ELSE
                  w_r_aux := TO_NUMBER(SUBSTR(w_n, i, 1)) * 2;
                  w_r := w_r + TRUNC(w_r_aux / 10) + MOD(w_r_aux, 10);
               END IF;
            END LOOP;

            w_dif := 10 - MOD(w_r, 10);
            w_a := SUBSTR(lletrescif, w_dif, 1);
            w_d := SUBSTR(TO_CHAR(w_dif), -1);

            /* En cas de 10 agafem el 0, per la resta el número*/
            IF w_x <> w_a
               AND w_x <> w_d THEN
               /* Bug 22053 - MDS - 27/04/2012*/
                 /*RETURN 101251;   -- Ni número ni lletra coincideixen*/
               RETURN 9903641;   /* Ni número ni lletra coincideixen*/
            END IF;
         END IF;
      EXCEPTION
         WHEN VALUE_ERROR THEN
            RETURN 9903982;   /* No són números els que haurien de ser-ho*/
      END;

      RETURN 0;
   END f_nif;

   /*Bug 25349 - XVM - 27/12/2012*/
   FUNCTION f_existe_identificador(
      pidenti IN identificadores.nnumide%TYPE,
      pctipide IN NUMBER,
      pspereal IN per_personas.sperson%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vpersonunica   NUMBER(5);
      vcempres       empresas.cempres%TYPE;
      v_cont         NUMBER(3);
   BEGIN
      vpasexec := 2;
      vcempres := pac_contexto.f_contextovalorparametro('IAX_EMPRESA');
      vpersonunica := pac_parametros.f_parempresa_n(vcempres, 'PER_DUPLICAR');
      vpasexec := 3;

      IF vpersonunica = 2 THEN
         vpasexec := 5;

         SELECT COUNT(sperson)
           INTO v_cont
           FROM per_identificador
          WHERE nnumide = pidenti
            AND ctipide = pctipide;

         IF v_cont > 0 THEN
            RETURN 9904701;
         END IF;
      ELSE
         vpasexec := 7;

         /* Permitimos duplicados para distintas personas, si es la misma no*/
         SELECT COUNT(sperson)
           INTO v_cont
           FROM per_identificador
          WHERE nnumide = pidenti
            AND ctipide = pctipide
            AND sperson = NVL(pspereal, -1);

         IF v_cont > 0 THEN
            RETURN 9904702;   /*Identificador ya existente para esta persona*/
         END IF;

         RETURN 0;
      END IF;

      vpasexec := 8;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', vpasexec,
                     'f_existe_identificador. Error . pidenti: ' || pidenti || ' pspereal: '
                     || pspereal,
                     ' ====  error === ' || SQLERRM);
         RETURN 9904703;   /*Error identificador*/
   END f_existe_identificador;

   /* Bug 25542 - APD - se crea la funcion*/
   FUNCTION f_actualiza_fantiguedad(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pfantiguedad IN DATE,
      pnmovimi IN NUMBER,
      pffin IN DATE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psperson=' || psperson || ' psseguro=' || psseguro || ' pfantiguedad='
            || TO_CHAR(pfantiguedad, 'dd/mm/yyyy') || ' pnmovimi=' || pnmovimi || ' pffin='
            || TO_CHAR(pffin, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_actualiza_fantiguedad';
      salir          EXCEPTION;
      num_err        NUMBER;
      vsproduc       seguros.sproduc%TYPE;
      vcagrupa       prodagrupa_antiguedad.cagrupa%TYPE;
      vnduraci       codagrupa_antiguedad.nduraci%TYPE;
      vcont          NUMBER;
      vnorden        per_antiguedad.norden%TYPE;
      vcestado       per_antiguedad.cestado%TYPE;
      vffin          DATE;
      vfantiguedad   DATE;
      vcobjase       productos.cobjase%TYPE;
   BEGIN
      vpasexec := 1;

      /* Control parametros entrada*/
      IF psperson IS NULL
         OR psseguro IS NULL
         OR pfantiguedad IS NULL
         OR pnmovimi IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      vpasexec := 2;

      /* Se busca el sproduc de la poliza*/
      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 101919;   /* Error al leer datos de la tabla SEGUROS*/
            RAISE salir;
      END;

      vpasexec := 3;

      /* Se busca el codigo de la agrupacion a la que pertenece el producto*/
      BEGIN
         SELECT cagrupa
           INTO vcagrupa
           FROM prodagrupa_antiguedad
          WHERE sproduc = vsproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
         /* Salimos si el producto no pertenece a ninguna agrupacion de antiguedad*/
         WHEN OTHERS THEN
            num_err := 9904769;
            /* Error al leer de la tabla PRODAGRUPA_ANTIGUEDAD*/
            RAISE salir;
      END;

      vpasexec := 4;

      BEGIN
         SELECT NVL(nduraci, 0)
           INTO vnduraci
           FROM codagrupa_antiguedad
          WHERE cagrupa = vcagrupa;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 9904767;
            /* Error al leer de la tabla CODAGRUPA_ANTIGUEDAD*/
            RAISE salir;
      END;

      vpasexec := 5;

      /* Se busca el Tipo de objeto asegurado (v.f. 65)*/
      BEGIN
         SELECT cobjase
           INTO vcobjase
           FROM productos
          WHERE sproduc = vsproduc;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 102705;   /* Error al leer la tabla PRODUCTOS*/
            RAISE salir;
      END;

      vpasexec := 6;

      /* Si mira si existe alguna antiguedad para la persona para la agrupacion del producto*/
      SELECT COUNT(1)
        INTO vcont
        FROM per_antiguedad
       WHERE sperson = psperson
         AND cagrupa = vcagrupa;

      vpasexec := 7;

      IF vcont = 0 THEN
         vpasexec := 8;
         /* No existe ninguna antiguedad para la persona por agrupacion --> se crea entonces la antiguedad*/
         vnorden := 1;
         /* norden = 1 ya que es el primer registro para la persona por agrupacion*/
         vcestado := 0;
         /* al crear una nueva antiguedad el estado debe ser 0.-Vigente*/
         vpasexec := 9;

         INSERT INTO per_antiguedad
                     (sperson, cagrupa, norden, fantiguedad, cestado, sseguro_ini,
                      nmovimi_ini, ffin, sseguro_fin, nmovimi_fin)
              VALUES (psperson, vcagrupa, vnorden, pfantiguedad, vcestado, psseguro,
                      pnmovimi, NULL, NULL, NULL);
      ELSE
         vpasexec := 10;

         /* Si existe una antiguedad para la persona, se mira si tiene una antiguedad vigente (ffin is null)*/
         SELECT COUNT(1)
           INTO vcont
           FROM per_antiguedad
          WHERE sperson = psperson
            AND cagrupa = vcagrupa
            AND ffin IS NULL;

         vpasexec := 11;

         /* Si vcont <> 0 --> la persona tiene una antiguedad vigente, por lo que no hay que hacer nada*/
         /* Si vcont = 0 --> la persona tiene una antiguedad anterior anulada, por lo que hay que mirar*/
         /* el tiempo que ha transcurrido desde la anulacion (per_antiguedad.ffin) hasta la nueva fecha*/
           /* de antiguedd (pfantiguedad) por si se mantiene la antiguedad o se debe crear otra*/
         IF vcont = 0 THEN
            vpasexec := 12;

            SELECT a.fantiguedad, a.ffin, norden, a.cestado
              INTO vfantiguedad, vffin, vnorden, vcestado
              FROM per_antiguedad a
             WHERE a.sperson = psperson
               AND a.cagrupa = vcagrupa
               AND a.ffin IS NOT NULL
               AND a.norden = (SELECT MAX(norden)
                                 FROM per_antiguedad a2
                                WHERE a2.sperson = a.sperson
                                  AND a2.cagrupa = a.cagrupa
                                  AND a2.ffin IS NOT NULL);

            vpasexec := 13;

            IF vcestado = 0 THEN
               /* se anula la antiguedad de la persona para que no existan dos registros para la misma*/
               /* persona y agrupacion con estado = 0 (si no se hubiera dado de alta otro registro*/
               /* para la antiguedad de la persona, ya sea con la misma fecha de antiguedad o no,*/
                 /* seria el proceso nocturno diario el que actualiza el cestado = 1)*/
               UPDATE per_antiguedad
                  SET cestado = 1
                WHERE sperson = psperson
                  AND cagrupa = vcagrupa
                  AND norden = vnorden;
            END IF;

            /* Se mira si desde la ultima fecha fin de antiguedad para esa persona y esa agrupación*/
            /* ha pasado mas de un cierto tiempo. Si ha pasado mas tiempo del permitido, se pierde*/
            /* la antiguedad y se inserta una nueva fecha de antiguedad. En el caso de que sea menos*/
            /* tiempo, se inserta un registro pero cogiendo como fecha de antiguedad la fecha de*/
              /* antiguedad del registro anulado para así mantener la antiguedad a la persona.*/
            IF (pfantiguedad - vnduraci) > vffin THEN
               /* se inserta un nuevo periodo de antiguedad*/
               vfantiguedad := pfantiguedad;
            ELSE
               /* se mantiene la antiguedad*/
               vfantiguedad := vfantiguedad;
            END IF;

            vpasexec := 14;
            /* estado debe ser 0.-Vigente*/
            /* sera en el proceso nocturno que se ejecuta diariamente donde se valide si se debe*/
              /* anular el estado*/
            vcestado := 0;
            vnorden := vnorden + 1;

            INSERT INTO per_antiguedad
                        (sperson, cagrupa, norden, fantiguedad, cestado, sseguro_ini,
                         nmovimi_ini, ffin, sseguro_fin, nmovimi_fin)
                 VALUES (psperson, vcagrupa, vnorden, vfantiguedad, vcestado, psseguro,
                         pnmovimi, NULL, NULL, NULL);
         END IF;
      END IF;

      vpasexec := 15;

      IF pffin IS NOT NULL THEN   /* Se quiere hacer una BAJA*/
         vpasexec := 16;

         /* Nos aseguramos que al menos exista un registro vigente*/
         SELECT COUNT(1)
           INTO vcont
           FROM per_antiguedad
          WHERE sperson = psperson
            AND cagrupa = vcagrupa
            AND ffin IS NULL;

         vpasexec := 17;

         IF vcont <> 0 THEN   /* existe un registro vigente*/
            vpasexec := 18;

            /* Miramos si a la agrupación a la que pertenece queda algún seguro vigente.*/
              /* Si no queda, el último registro vigente para esa agrupación lo finalizamos informándolo con la fecha de baja*/
            IF NVL(vcobjase, 0) = 1 THEN   /* Persona*/
               SELECT COUNT(1)
                 INTO vcont
                 FROM seguros s, asegurados a, prodagrupa_antiguedad paa
                WHERE s.sseguro = a.sseguro
                  AND s.sproduc = paa.sproduc
                  AND paa.cagrupa = vcagrupa
                  AND a.sperson = psperson
                  AND s.csituac = 0;
            ELSIF NVL(vcobjase, 0) = 5 THEN   /* Vehiculos*/
               SELECT COUNT(1)
                 INTO vcont
                 FROM seguros s, autconductores a, prodagrupa_antiguedad paa
                WHERE s.sseguro = a.sseguro
                  AND s.sproduc = paa.sproduc
                  AND paa.cagrupa = vcagrupa
                  AND a.sperson = psperson
                  AND s.csituac = 0;
            END IF;

            vpasexec := 19;

            /* no queda ningun seguro vigente*/
            IF vcont = 0 THEN
               vpasexec := 20;

               /* no se actualiza el estado, sera en p_proceso_antiguedad que se ejecuta diariamente*/
                 /* desde procesos nocturnos, donde se actualice el estado*/
               UPDATE per_antiguedad
                  SET ffin = pffin,
                      sseguro_fin = psseguro,
                      nmovimi_fin = pnmovimi
                WHERE sperson = psperson
                  AND cagrupa = vcagrupa
                  AND ffin IS NULL;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err));
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9904772;
   END f_actualiza_fantiguedad;

   /*************************************************************************
   Funcion que dado un sseguro (poliza) busca todas las personas asociadas a
   la poliza para actualizar la antiguedad de cada persona
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   /* Bug 25542 - APD - se crea la funcion*/
   FUNCTION f_antiguedad_personas_pol(psseguro IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := ' psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_PERSONA.f_antiguedad_personas_pol';
      salir          EXCEPTION;
      num_err        NUMBER;
      vsproduc       seguros.sproduc%TYPE;
      vcagrupa       prodagrupa_antiguedad.cagrupa%TYPE;
      vnmovimi       movseguro.nmovimi%TYPE;
      vfefecto       movseguro.fefecto%TYPE;
      vcsituac       seguros.csituac%TYPE;
      vfanulac       seguros.fanulac%TYPE;
      vffin          movseguro.fefecto%TYPE;
      vcobjase       productos.cobjase%TYPE;
   BEGIN
      vpasexec := 1;

      /* Control parametros entrada*/
      IF psseguro IS NULL THEN
         RETURN 9000505;   /*Faltan parametros por informar*/
      END IF;

      vpasexec := 2;

      /* Se busca el sproduc de la poliza*/
      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 101919;   /* Error al leer datos de la tabla SEGUROS*/
            RAISE salir;
      END;

      vpasexec := 3;

      /* Se busca el codigo de la agrupacion a la que pertenece el producto*/
      BEGIN
         SELECT cagrupa
           INTO vcagrupa
           FROM prodagrupa_antiguedad
          WHERE sproduc = vsproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
         /* Salimos si el producto no pertenece a ninguna agrupacion de antiguedad*/
         WHEN OTHERS THEN
            num_err := 9904769;
            /* Error al leer de la tabla PRODAGRUPA_ANTIGUEDAD*/
            RAISE salir;
      END;

      vpasexec := 4;
      /* Se busca el ultimo movimiento de la poliza*/
      vnmovimi := pac_movseguro.f_nmovimi_ult(psseguro);

      IF NVL(vnmovimi, -1) = -1 THEN
         num_err := 104349;   /* Error al leer de la tabla MOVSEGURO*/
         RAISE salir;
      END IF;

      /* Se busca la fefecto del ultimo movimiento de la poliza*/
      vfefecto := pac_movseguro.f_get_fefecto(psseguro, vnmovimi);

      IF vfefecto IS NULL THEN
         num_err := 104349;   /* Error al leer de la tabla MOVSEGURO*/
         RAISE salir;
      END IF;

      /* Se busca la situacion actual de la poliza y su fecha de anulacion (necesaria si la*/
      /* poliza está anulada)*/
      BEGIN
         SELECT csituac, fanulac
           INTO vcsituac, vfanulac
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 101919;   /* Error al leer datos de la tabla SEGUROS*/
            RAISE salir;
      END;

      /* si la poliza está anulada o vencida, se informa la ffin*/
      IF vcsituac IN(2, 3) THEN
         vffin := vfanulac;
      END IF;

      /* Se busca el Tipo de objeto asegurado (v.f. 65)*/
      BEGIN
         SELECT cobjase
           INTO vcobjase
           FROM productos
          WHERE sproduc = vsproduc;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 102705;   /* Error al leer la tabla PRODUCTOS*/
            RAISE salir;
      END;

      vpasexec := 5;

      IF NVL(vcobjase, 0) = 1 THEN                            /* Persona*/
                                     /* se buscan todos los asegurados de la poliza*/
         FOR reg IN (SELECT a.sperson
                       FROM seguros s, asegurados a
                      WHERE s.sseguro = a.sseguro
                        AND s.sseguro = psseguro) LOOP
            num_err := pac_persona.f_actualiza_fantiguedad(reg.sperson, psseguro, vfefecto,
                                                           vnmovimi, vffin);

            IF num_err <> 0 THEN
               EXIT;
            END IF;
         END LOOP;
      ELSIF NVL(vcobjase, 0) = 5 THEN                               /* Vehiculos*/
                                        /* se buscan todos los conductores de la poliza*/
         FOR reg IN (SELECT a.sperson
                       FROM seguros s, autconductores a
                      WHERE s.sseguro = a.sseguro
                        AND s.sseguro = psseguro) LOOP
            num_err := pac_persona.f_actualiza_fantiguedad(reg.sperson, psseguro, vfefecto,
                                                           vnmovimi, vffin);

            IF num_err <> 0 THEN
               EXIT;
            END IF;
         END LOOP;
      END IF;

      IF num_err <> 0 THEN
         RAISE salir;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err));
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;
   END f_antiguedad_personas_pol;

   /*************************************************************************
   Proceso diario que actualiza la antiguedad de una persona
   *************************************************************************/
   /* Bug 25542 - APD - se crea la funcion*/
   PROCEDURE p_proceso_antiguedad(
      psperson IN NUMBER,
      pcagrupa IN NUMBER,
      pfecha IN DATE,
      psproces OUT NUMBER) IS
      empresa        NUMBER;

      /*
         {proceso nocturno que actualiza la antiguedad de las personas}
      */
      CURSOR cur_per(p_sperson IN NUMBER, p_cagrupa IN NUMBER, p_fecha IN DATE) IS
         SELECT   p.sperson, p.cagrupa, p.norden, p.ffin
             FROM per_antiguedad p
            WHERE p.sperson = NVL(p_sperson, p.sperson)
              AND p.cagrupa = NVL(p_cagrupa, p.cagrupa)
              AND p.cestado = 0
              AND p.ffin IS NOT NULL
         ORDER BY norden DESC;

      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psperson=' || psperson || '; pcagrupa=' || pcagrupa || '; pfecha='
            || TO_CHAR(pfecha, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'pac_persona.p_proceso_antiguedad';
      num_err        NUMBER;
      vfecha         DATE;
      vnduraci       codagrupa_antiguedad.nduraci%TYPE;
      vtagrupa       desagrupa_antiguedad.tagrupa%TYPE;
      error          NUMBER;
      nprolin        NUMBER;
      cont_malos     NUMBER := 0;
      texto          VARCHAR2(150);
   BEGIN
      /*
         reservamos el numero de proceso para la anulacion
      */
      vpasexec := 1;

      BEGIN
         SELECT cempres
           INTO empresa
           FROM usuarios
          WHERE cusuari = f_user;
      END;

      vpasexec := 2;
      error := f_procesini(f_user, empresa, f_axis_literales(140423),
                           f_axis_literales(9904770), psproces);
      vpasexec := 3;
      vfecha := TRUNC(NVL(pfecha, f_sysdate));
      vpasexec := 4;

      FOR reg_per IN cur_per(psperson, pcagrupa, vfecha) LOOP
         vpasexec := 5;
         texto := NULL;

         SELECT NVL(c.nduraci, 0), d.tagrupa
           INTO vnduraci, vtagrupa
           FROM codagrupa_antiguedad c, desagrupa_antiguedad d
          WHERE c.cagrupa = reg_per.cagrupa
            AND c.cagrupa = d.cagrupa
            AND d.cidioma = pac_md_common.f_get_cxtidioma();

         vpasexec := 6;

         IF (vfecha - vnduraci) > reg_per.ffin THEN
            vpasexec := 7;

            /* se anula la antiguedad de la persona*/
            UPDATE per_antiguedad
               SET cestado = 1
             WHERE sperson = reg_per.sperson
               AND cagrupa = reg_per.cagrupa
               AND norden = reg_per.norden;

            vpasexec := 8;
            error := f_proceslin(psproces,
                                 f_axis_literales(9904771) || ' :  '
                                 || f_nombre(reg_per.sperson, 1, NULL) || ' ('
                                 || f_axis_literales(111471) || ' ' || vtagrupa || ')',
                                 reg_per.sperson, nprolin, 4);   /* Correcto*/
            COMMIT;
         END IF;
      END LOOP;

      vpasexec := 9;
      num_err := f_procesfin(psproces, cont_malos);
   EXCEPTION
      WHEN OTHERS THEN
         IF cur_per%ISOPEN THEN
            CLOSE cur_per;
         END IF;

         ROLLBACK;
         error := f_proceslin(psproces, f_axis_literales(9904772), NULL, nprolin, 1);   /* Error;*/
         cont_malos := cont_malos + 1;
         num_err := f_procesfin(psproces, cont_malos);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, f_axis_literales(9904772), SQLERRM);
   END p_proceso_antiguedad;

   /****************************************************************************
      F_PER_PERSONA: Obtenir el sexe i la data de naixement
        d'una persona.
   ****************************************************************************/
   /* 24497.NMM.#6.*/
   FUNCTION f_persona_dades(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psexe OUT NUMBER,
      pdatanaix OUT DATE)
      RETURN NUMBER IS
      werror         PLS_INTEGER := 0;
      vpasexec       PLS_INTEGER := 0;
      vobjectname    VARCHAR2(100) := 'f_persona_dades';
      vparam         VARCHAR2(100) := '--';
   BEGIN
      vpasexec := 10;

      /* Mirem si la person és a les taules EST*/
      BEGIN
         vpasexec := 20;

         SELECT csexper, fnacimi
           INTO psexe, pdatanaix
           FROM estper_personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            /* Si no existeix a les EST mirem les Definitives*/
            BEGIN
               vpasexec := 30;

               SELECT csexper, fnacimi
                 INTO psexe, pdatanaix
                 FROM per_personas
                WHERE sperson = psperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user,
                              vobjectname || ':sperson:' || psperson || ':sex:' || psexe
                              || ':datanaix:' || pdatanaix || ':sseguro:' || psseguro,
                              vpasexec, vparam, 'ERROR: ' || SQLERRM);
                  RETURN(100534);   /* Persona inexistent*/
            END;
      END;

      RETURN(0);
   /**/
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user,
                     vobjectname || ':sperson:' || psperson || ':sex:' || psexe
                     || ':datanaix:' || pdatanaix || ':sseguro:' || psseguro,
                     vpasexec, vparam, 'ERROR: ' || SQLERRM);
         RETURN(100534);
   /* Persona inexistent*/
   END f_persona_dades;

   /* BUG 26968 - FAL - 04/07/2013*/
   /****************************************************************************
      F_FORMAT_NIF: Formateo del Nif
        d'una persona.
   ****************************************************************************/
   FUNCTION f_format_nif(
      pnnumide IN VARCHAR2,
      pctipide IN NUMBER,
      psperson IN NUMBER,
      pmode IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_nnumide_format VARCHAR2(30);
      w_digit        VARCHAR2(2);
      wnnumide       per_personas.nnumide%TYPE;
   /* BUG 26968/0155105 - FAL - 15/10/2013*/
   BEGIN
      IF pctipide IN(41, 42) THEN   /* RUT chile*/
         wnnumide := f_desformat_nif(pnnumide, pctipide);

         /* BUG 26968/0155105 - FAL - 15/10/2013*/
         IF SUBSTR(wnnumide, 9, 1) IS NOT NULL THEN
            SELECT DECODE(SUBSTR(wnnumide, 9, 1),
                          NULL, TO_CHAR(SUBSTR(wnnumide, 1, 8), '99G999G999'),
                          (TO_CHAR(SUBSTR(wnnumide, 1, 8), '99G999G999') || '-'
                           || SUBSTR(wnnumide, 9, 1)))
              INTO v_nnumide_format
              FROM DUAL;
         ELSE
            IF pmode = 'EST' THEN
               SELECT DECODE(tdigitoide, NULL, NULL, '-' || tdigitoide)
                 INTO w_digit
                 FROM estper_personas
                WHERE sperson = psperson;
            ELSE
               SELECT DECODE(tdigitoide, NULL, NULL, '-' || tdigitoide)
                 INTO w_digit
                 FROM per_personas
                WHERE sperson = psperson;
            END IF;

            v_nnumide_format := TO_CHAR(SUBSTR(wnnumide, 1, 8), '99G999G999') || w_digit;
         END IF;
      ELSE
         /*q-tracker 0007811: Error al elegir un Conductor que se encuentra en listas restringidas externas - AU TOTAL CAR*/
           /*xpl, no s'ha de posar cap LPAD ja que no té perquè tenir 10 posicions el document*/
         v_nnumide_format := TRIM(pnnumide);
      END IF;

      RETURN v_nnumide_format;
   END f_format_nif;

   /* FI BUG 26968 - FAL - 04/07/2013*/
   /* Bug 26318 - 10/10/2013 - JMG - Inicio #155391 Anotación en la agenda de las pólizas*/
   /*************************************************************************
     FUNCTION f_set_agensegu_rol
        Obtiene los registros de las polizas asociadas al rol  e inserta un apunte en la agenda
        param in psperson: Codigo de la persona
        param in out errores: lista de errrores
     *************************************************************************/
   /*FUNCTION f_set_agensegu_rol(psperson IN NUMBER, pcidioma IN idiomas.cidioma%TYPE)
      RETURN NUMBER IS
      vpasexec       PLS_INTEGER := 0;
      vobjectname    VARCHAR2(100) := 'f_set_agensegu_rol';
      vparam         VARCHAR2(100) := '--';
      num_err        NUMBER;
      salir          EXCEPTION;

      CURSOR cur_agensegu_rol(psperson per_personas.sperson%TYPE) IS
         (SELECT sperson, sseguro,
                 9906113 slitera   -- TOMADORES(Los datos del tomador se han modificado desde el mantenimiento de cliente único)
            FROM tomadores
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro,
                 9906114 slitera   --ASEGURADOS(Los datos del asegurado se han modificado desde el mantenimiento de cliente único)
            FROM asegurados
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro,
                 9906115 slitera   --CONDUCTORES(Los datos del conductor se han modificado desde el mantenimiento de cliente único)
            FROM autconductores
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro,
                 9906116 slitera   -- BENEFICIARIOS (Los datos del beneficiario se han modificado desde el mantenimiento de cliente único)
            FROM benespseg
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro,
                 9906117 slitera   -- GESTOR DE COBRO(Los datos del gestor de cobro se han modificado desde el mantenimiento de cliente único)
            FROM gescobros
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro,
                 DECODE(ctipfig, 1, 9906118, 9906119) slitera   -- INQUILINOS O AVALISTAS(Los datos del inquilino de cobro se han modificado desde el mantenimiento de cliente único)
            FROM inquiaval
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro,
                 9906120 slitera   -- RETORNOS -- Los datos del gestor de cobro se han modificado desde...
            FROM rtn_convenio
           WHERE sperson = psperson);
   BEGIN
      FOR rg_agensegu IN cur_agensegu_rol(psperson) LOOP
         num_err := pac_agensegu.f_set_datosapunte(0, rg_agensegu.sseguro, 0,
                                                   f_axis_literales(9001830, pcidioma),
                                                   f_axis_literales(rg_agensegu.slitera,
                                                                    pcidioma),
                                                   6, 1, f_sysdate, f_sysdate, 0, 0);

         IF num_err <> 0 THEN
            RAISE salir;
         END IF;
      END LOOP;

      RETURN(0);
   --
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     f_axis_literales(num_err));
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user,
                     vobjectname || ':sperson:' || psperson || ':pcidioma:' || pcidioma,
                     vpasexec, vparam, 'ERROR: ' || SQLERRM);
         RETURN(9001151);
   END f_set_agensegu_rol;*/
   /* Bug 26318 - 10/10/2013 - JMG - Fin #155391 Anotación en la agenda de las pólizas*/
   /* BUG 26968/0155105 - FAL - 15/10/2013*/
   /****************************************************************************
      F_DESFORMAT_NIF: DesFormateo del Nif d'una persona.
   ****************************************************************************/
   FUNCTION f_desformat_nif(pnnumide IN VARCHAR2, pctipide IN NUMBER)
      RETURN VARCHAR2 IS
      v_nnumide_desformat per_personas.nnumide%TYPE;
   BEGIN
      IF pctipide IN(41, 42) THEN   /* RUT chile*/
         SELECT SUBSTR(REPLACE(REPLACE(pnnumide, ',', ''), '.', ''), 1,
                       DECODE(INSTR(REPLACE(REPLACE(pnnumide, ',', ''), '.', ''), '-') - 1,
                              -1, LENGTH(pnnumide),
                              INSTR(REPLACE(REPLACE(pnnumide, ',', ''), '.', ''), '-') - 1))
           INTO v_nnumide_desformat
           FROM DUAL;
      ELSE
         v_nnumide_desformat := pnnumide;
      END IF;

      RETURN v_nnumide_desformat;
   END f_desformat_nif;

   /* FI BUG 26968/0155105*/
   /* BUG 26968/0155105 - FAL - 15/10/2013*/
   /****************************************************************************
      F_DESFORMAT_NIF: DesFormateo del Nif d'una persona.
   ****************************************************************************/
   FUNCTION f_persona_duplicada_nnumide(psperson IN NUMBER)
      RETURN NUMBER IS
      vduplicada     NUMBER := 0;
      vpasexec       PLS_INTEGER := 0;
      vobjectname    VARCHAR2(100) := 'PAC_PERSONA.F_PERSONA_DUPLICADA_NNUMIDE';
      vparam         VARCHAR2(100) := '--';
   BEGIN
      SELECT DECODE(COUNT(1), 0, 0, 1)
        INTO vduplicada
        FROM per_personas
       WHERE (nnumide, ctipide) IN(SELECT nnumide, ctipide
                                     FROM per_personas
                                    WHERE sperson = psperson)
         AND sperson != psperson;

      RETURN vduplicada;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || ':sperson:' || psperson, 1,
                     ' sperson:' || psperson, 'ERROR: ' || SQLERRM);
         RETURN 0;
   END f_persona_duplicada_nnumide;

   /* FI BUG 26968/0155105*/
   /*************************************************************************
     FUNCTION f_set_agensegu_rol
        Obtiene los registros de las polizas asociadas al rol  e inserta un apunte en la agenda
        param in psperson: Codigo de la persona
        param in out errores: lista de errrores
     *************************************************************************/
   FUNCTION f_set_agensegu_rol(
      psperson IN NUMBER,
      pmodo IN VARCHAR2,
      pcidioma IN idiomas.cidioma%TYPE)
      RETURN NUMBER IS
      vpasexec       PLS_INTEGER := 0;
      vobjectname    VARCHAR2(100) := 'f_set_agensegu_rol';
      vparam         VARCHAR2(100) := '--';
      num_err        NUMBER;
      salir          EXCEPTION;
      vcambios       NUMBER;
      vcambiosn      NUMBER;
      vtcambios      VARCHAR2(4000);
      vtvalorant     VARCHAR2(100);
      vtvaloract     VARCHAR2(100);
      vvtvalorant    VARCHAR2(100);
      vvtvaloract    VARCHAR2(100);
      vnnumide_ant   hisper_personas.nnumide%TYPE;
      vctipide_ant   hisper_personas.ctipide%TYPE;
      vcexper_ant    hisper_personas.csexper%TYPE;
      vfnacimi_ant   hisper_personas.fnacimi%TYPE;
      vcestper_ant   hisper_personas.cestper%TYPE;
      vfjubila_ant   hisper_personas.fjubila%TYPE;
      vfdefunc_ant   hisper_personas.fdefunc%TYPE;
      vcmutualista_ant hisper_personas.cmutualista%TYPE;
      vsnip_ant      hisper_personas.snip%TYPE;
      vctipper_ant   hisper_personas.ctipper%TYPE;
      vtdigitoide_ant hisper_personas.tdigitoide%TYPE;
      vcpreaviso_ant hisper_personas.cpreaviso%TYPE;
      vnnumidet      per_personas.nnumide%TYPE;
      vctipidet      per_personas.ctipide%TYPE;
      vcexper        per_personas.csexper%TYPE;
      vfnacimi       per_personas.fnacimi%TYPE;
      vcestper       per_personas.cestper%TYPE;
      vfjubila       per_personas.fjubila%TYPE;
      vfdefunc       per_personas.fdefunc%TYPE;
      vcmutualista   per_personas.cmutualista%TYPE;
      vsnip          per_personas.snip%TYPE;
      vctipper       per_personas.ctipper%TYPE;
      vtdigitoide    per_personas.tdigitoide%TYPE;
      vcpreaviso     per_personas.cpreaviso%TYPE;
      vtnombre_ant   hisper_detper.tnombre%TYPE;
      vtnombre1_ant  hisper_detper.tnombre1%TYPE;
      vtnombre2_ant  hisper_detper.tnombre2%TYPE;
      vtapelli1_ant  hisper_detper.tapelli1%TYPE;
      vtapelli2_ant  hisper_detper.tapelli2%TYPE;
      vcprofes_ant   hisper_detper.cprofes%TYPE;
      vcocupacion_ant hisper_detper.cocupacion%TYPE;
      vcpais_ant     hisper_detper.cpais%TYPE;
      vcestciv_ant   hisper_detper.cestciv%TYPE;
      vcidioma_ant   hisper_detper.cidioma%TYPE;
      vtnombre       per_detper.tnombre%TYPE;
      vtnombre1      per_detper.tnombre1%TYPE;
      vtnombre2      per_detper.tnombre2%TYPE;
      vtapelli1      per_detper.tapelli1%TYPE;
      vtapelli2      per_detper.tapelli2%TYPE;
      vcprofes       per_detper.cprofes%TYPE;
      vcocupacion    per_detper.cocupacion%TYPE;
      vcpais         per_detper.cpais%TYPE;
      vcestciv       per_detper.cestciv%TYPE;
      vcidioma       per_detper.cidioma%TYPE;
      vctipdir_ant   hisper_direcciones.ctipdir%TYPE;
      vcviavp_ant    hisper_direcciones.cviavp%TYPE;
      vtnomvia_ant   hisper_direcciones.tnomvia%TYPE;
      vclitvp_ant    hisper_direcciones.clitvp%TYPE;
      vcbisvp_ant    hisper_direcciones.cbisvp%TYPE;
      vcorvp_ant     hisper_direcciones.corvp%TYPE;
      vnviaadco_ant  hisper_direcciones.nviaadco%TYPE;
      vclitco_ant    hisper_direcciones.clitco%TYPE;
      vcorco_ant     hisper_direcciones.corco%TYPE;
      vtnum3ia_ant   hisper_direcciones.tnum3ia%TYPE;
      vcpostal_ant   hisper_direcciones.cpostal%TYPE;
      vcprovin_ant   hisper_direcciones.cprovin%TYPE;
      vcpoblac_ant   hisper_direcciones.cpoblac%TYPE;
      vctipdir       per_direcciones.ctipdir%TYPE;
      vcviavp        per_direcciones.cviavp%TYPE;
      vtnomvia       per_direcciones.tnomvia%TYPE;
      vclitvp        per_direcciones.clitvp%TYPE;
      vcbisvp        per_direcciones.cbisvp%TYPE;
      vcorvp         per_direcciones.corvp%TYPE;
      vnviaadco      per_direcciones.nviaadco%TYPE;
      vclitco        per_direcciones.clitco%TYPE;
      vcorco         per_direcciones.corco%TYPE;
      vtnum3ia       per_direcciones.tnum3ia%TYPE;
      vcpostal       per_direcciones.cpostal%TYPE;
      vcprovin       per_direcciones.cprovin%TYPE;
      vcpoblac       per_direcciones.cpoblac%TYPE;
      vcdefecto_ant  hisper_ccc.cdefecto%TYPE;
      vfvencim_ant   hisper_ccc.fvencim%TYPE;
      vcdefecto      per_ccc.cdefecto%TYPE;
      vfvencim       per_ccc.fvencim%TYPE;
      vttipo         tipos_cuentades.ttipo%TYPE;
      vcbancar       per_ccc.cbancar%TYPE;
      vliteral       axis_literales.slitera%TYPE;
      /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464.*/
      vctipcon_ant   per_contactos.ctipcon%TYPE;
      vctvalcon_ant  per_contactos.tvalcon%TYPE;
      vctipcon       per_contactos.ctipcon%TYPE;
      vctvalcon      per_contactos.tvalcon%TYPE;
      vcmodcon_ant   hisper_contactos.cmodcon%TYPE;
      vnorden_ant    hisper_contactos.norden%TYPE;
      vdnorden       hisper_direcciones.norden%TYPE;
      vdcdomici      hisper_direcciones.cdomici%TYPE;
      vpnorden       hisper_personas.norden%TYPE;
      /* FIN RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464.*/
      /* Este parametro de tiempo en segundos se utiliza para que al hacer la seleccion no seleccione por la fecha del dia porque en este caso*/
      /* seleciona todos los registros hechs en elmismo dia y se muestan en la agenda duplicados. La solución es coger el registro con un rango de*/
      /* fecha entre la fecha de sistema y en este caso 10 segundos menos.*/
      vsegundo       NUMBER(6, 4) := 60 / 86400;

      CURSOR cur_agensegu_rol(psperson per_personas.sperson%TYPE) IS
         (SELECT sperson, sseguro, 9906113 slitera
            /* TOMADORES(Los datos del tomador se han modificado desde el mantenimiento de cliente único)*/
          FROM   tomadores
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro, 9906114 slitera
            /*ASEGURADOS(Los datos del asegurado se han modificado desde el mantenimiento de cliente único)*/
          FROM   asegurados
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro, 9906115 slitera
            /*CONDUCTORES(Los datos del conductor se han modificado desde el mantenimiento de cliente único)*/
          FROM   autconductores
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro, 9906116 slitera
            /* BENEFICIARIOS (Los datos del beneficiario se han modificado desde el mantenimiento de cliente único)*/
          FROM   benespseg
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro, 9906117 slitera
            /* GESTOR DE COBRO(Los datos del gestor de cobro se han modificado desde el mantenimiento de cliente único)*/
          FROM   gescobros
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro, DECODE(ctipfig, 1, 9906118, 9906119) slitera
            /* INQUILINOS O AVALISTAS(Los datos del inquilino de cobro se han modificado desde el mantenimiento de cliente único)*/
          FROM   inquiaval
           WHERE sperson = psperson
          UNION
          SELECT sperson, sseguro, 9906120 slitera
            /* RETORNOS -- Los datos del gestor de cobro se han modificado desde...*/
          FROM   rtn_convenio
           WHERE sperson = psperson);
   BEGIN
/*---------------------------------------------------*/
/* PERSONAS PER_PERSONAS, PER_DETPER ----------------*/
    /*---------------------------------------------------*/
      vtvalorant := f_axis_literales(9904557, f_usu_idioma);
      vtvaloract := f_axis_literales(9906269, f_usu_idioma);

      IF pmodo = 'PER' THEN   -- Modificación datos persona.
         SELECT COUNT(1)
           INTO vcambios
           FROM (SELECT hd.nnumide, hd.ctipide, hd.csexper, hd.fnacimi, hd.cestper, hd.fjubila,
                        hd.cmutualista, hd.snip, hd.ctipper, hd.tdigitoide, hd.cpreaviso,
                        hd.fdefunc
                   FROM hisper_personas hd
                  WHERE sperson = psperson
                    /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                    AND fusumod BETWEEN f_sysdate - vsegundo AND f_sysdate
                    AND norden IN(SELECT MAX(norden)
                                    FROM hisper_personas
                                   WHERE sperson = psperson)
                 MINUS
                 SELECT hd.nnumide, hd.ctipide, hd.csexper, hd.fnacimi, hd.cestper, hd.fjubila,
                        hd.cmutualista, hd.snip, hd.ctipper, hd.tdigitoide, hd.cpreaviso,
                        hd.fdefunc
                   FROM per_personas hd
                  WHERE sperson = psperson);

         /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
         IF (vcambios = 0) THEN
            SELECT COUNT(*)
              INTO vcambiosn
              FROM per_personas hd
             WHERE hd.sperson = psperson
               AND hd.fmovimi BETWEEN f_sysdate - vsegundo AND f_sysdate;
         END IF;

         /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
         IF vcambios > 0
            OR vcambiosn > 0 THEN
            /* Miramos cual es el cambio,*/
            BEGIN
               SELECT hd.nnumide, hd.ctipide, hd.csexper, hd.fnacimi, hd.cestper,
                      hd.fjubila, hd.cmutualista, hd.snip, hd.ctipper,
                      hd.tdigitoide, hd.cpreaviso, hd.fdefunc, hd.norden
                 INTO vnnumide_ant, vctipide_ant, vcexper_ant, vfnacimi_ant, vcestper_ant,
                      vfjubila_ant, vcmutualista_ant, vsnip_ant, vctipper_ant,
                      vtdigitoide_ant, vcpreaviso_ant, vfdefunc_ant, vdnorden
                 FROM hisper_personas hd
                WHERE sperson = psperson
                  /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                  AND fusumod BETWEEN f_sysdate - vsegundo AND f_sysdate
                  AND norden IN(SELECT MAX(norden)
                                  FROM hisper_personas
                                 WHERE sperson = psperson);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF (vpnorden IS NOT NULL) THEN
               SELECT hd.nnumide, hd.ctipide, hd.csexper, hd.fnacimi, hd.cestper, hd.fjubila,
                      hd.cmutualista, hd.snip, hd.ctipper, hd.tdigitoide, hd.cpreaviso,
                      hd.fdefunc
                 INTO vnnumidet, vctipidet, vcexper, vfnacimi, vcestper, vfjubila,
                      vcmutualista, vsnip, vctipper, vtdigitoide, vcpreaviso,
                      vfdefunc
                 FROM hisper_personas hd
                WHERE hd.sperson = psperson
                  AND hd.norden = vdnorden;
            ELSE
               SELECT hd.nnumide, hd.ctipide, hd.csexper, hd.fnacimi, hd.cestper, hd.fjubila,
                      hd.cmutualista, hd.snip, hd.ctipper, hd.tdigitoide, hd.cpreaviso,
                      hd.fdefunc
                 INTO vnnumidet, vctipidet, vcexper, vfnacimi, vcestper, vfjubila,
                      vcmutualista, vsnip, vctipper, vtdigitoide, vcpreaviso,
                      vfdefunc
                 FROM per_personas hd
                WHERE hd.sperson = psperson;
            END IF;

            IF ((vctipper_ant IS NOT NULL
                 AND vctipper IS NULL)
                OR(vctipper_ant IS NULL
                   AND vctipper IS NOT NULL)
                OR(vctipper_ant != vctipper)) THEN
               vvtvalorant := ff_desvalorfijo(85, f_usu_idioma, vctipper_ant);
               vvtvaloract := ff_desvalorfijo(85, f_usu_idioma, vctipper);
               vtcambios := f_axis_literales(102844, f_usu_idioma) || ' - ' || vtvalorant
                            || ' ' || vvtvalorant || ' - ' || vtvaloract || ' ' || vvtvaloract;
            END IF;

            IF ((vctipide_ant IS NOT NULL
                 AND vctipidet IS NULL)
                OR(vctipide_ant IS NULL
                   AND vctipidet IS NOT NULL)
                OR(vctipide_ant != vctipidet)) THEN
               vvtvalorant := ff_desvalorfijo(672, f_usu_idioma, vctipide_ant);
               vvtvaloract := ff_desvalorfijo(672, f_usu_idioma, vctipidet);
               vtcambios := vtcambios || CHR(13) || f_axis_literales(9904433, f_usu_idioma)
                            || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                            || vtvaloract || ' ' || vvtvaloract;
            END IF;

            IF ((vnnumide_ant IS NOT NULL
                 AND vnnumidet IS NULL)
                OR(vnnumide_ant IS NULL
                   AND vnnumidet IS NOT NULL)
                OR(vnnumide_ant != vnnumidet)) THEN
               vtcambios := vtcambios || CHR(13) || f_axis_literales(9904434, f_usu_idioma)
                            || ' - ' || vtvalorant || '  ' || vnnumide_ant || ' - '
                            || vtvaloract || ' ' || vnnumidet;
            END IF;

            IF ((vtdigitoide_ant IS NOT NULL
                 AND vtdigitoide IS NULL)
                OR(vtdigitoide_ant IS NULL
                   AND vtdigitoide IS NOT NULL)
                OR(vtdigitoide_ant != vtdigitoide)) THEN
               vtcambios := vtcambios || CHR(13) || f_axis_literales(9903068, f_usu_idioma)
                            || ' - ' || vtvalorant || '  ' || vtdigitoide_ant || ' - '
                            || vtvaloract || ' ' || vtdigitoide;
            END IF;

            IF ((vcexper_ant IS NOT NULL
                 AND vcexper IS NULL)
                OR(vcexper_ant IS NULL
                   AND vcexper IS NOT NULL)
                OR(vcexper_ant != vcexper)) THEN
               vvtvalorant := ff_desvalorfijo(11, f_usu_idioma, vcexper_ant);
               vvtvaloract := ff_desvalorfijo(11, f_usu_idioma, vcexper);
               vtcambios := vtcambios || CHR(13) || f_axis_literales(100962, f_usu_idioma)
                            || ' - ' || vtvalorant || ' ' || vvtvalorant || ' - '
                            || vtvaloract || ' ' || vvtvaloract;
            END IF;

            IF ((vfnacimi_ant IS NOT NULL
                 AND vfnacimi IS NULL)
                OR(vfnacimi_ant IS NULL
                   AND vfnacimi IS NOT NULL)
                OR(vfnacimi_ant != vfnacimi)) THEN
               /* Selecciona el literal para incluir en la agenda de cambios en funcion de si es tipo de persona es fisico o el resto*/
               IF vctipper = 1 THEN
                  vliteral := 1000064;
               ELSE
                  vliteral := 9902377;
               END IF;

               vtcambios := vtcambios || CHR(13) || f_axis_literales(vliteral, f_usu_idioma)
                            || ' - ' || vtvalorant || '  ' || vfnacimi_ant || ' - '
                            || vtvaloract || ' ' || vfnacimi;
            END IF;

            IF ((vcestper_ant IS NOT NULL
                 AND vcestper IS NULL)
                OR(vcestper_ant IS NULL
                   AND vcestper IS NOT NULL)
                OR(vcestper_ant != vcestper)) THEN
               vvtvalorant := ff_desvalorfijo(13, f_usu_idioma, vcestper_ant);
               vvtvaloract := ff_desvalorfijo(13, f_usu_idioma, vcestper);
               vtcambios := vtcambios || CHR(13) || f_axis_literales(9000793, f_usu_idioma)
                            || ' - ' || vtvalorant || ' ' || vvtvalorant || ' - '
                            || vtvaloract || ' ' || vvtvaloract;
            END IF;

            IF ((vfjubila_ant IS NOT NULL
                 AND vfjubila IS NULL)
                OR(vfjubila_ant IS NULL
                   AND vfjubila IS NOT NULL)
                OR(vfjubila_ant != vfjubila)) THEN
               vtcambios := vtcambios || CHR(13) || f_axis_literales(1000067, f_usu_idioma)
                            || ' - ' || vtvalorant || '  '
                            || TO_CHAR(vfjubila_ant, 'dd/mm/yyyy') || ' - ' || vtvaloract
                            || ' ' || TO_CHAR(vfjubila, 'dd/mm/yyyy');
            END IF;

            IF ((vfdefunc_ant IS NOT NULL
                 AND vfdefunc IS NULL)
                OR(vfdefunc_ant IS NULL
                   AND vfdefunc IS NOT NULL)
                OR(vfdefunc_ant != vfdefunc)) THEN
               vtcambios := vtcambios || CHR(13) || f_axis_literales(9000794, f_usu_idioma)
                            || ' - ' || vtvalorant || '  '
                            || TO_CHAR(vfdefunc_ant, 'dd/mm/yyyy') || ' - ' || vtvaloract
                            || ' ' || TO_CHAR(vfdefunc, 'dd/mm/yyyy');
            END IF;

            IF ((vcmutualista_ant IS NOT NULL
                 AND vcmutualista IS NULL)
                OR(vcmutualista_ant IS NULL
                   AND vcmutualista IS NOT NULL)
                OR(vcmutualista_ant != vcmutualista)) THEN
               vvtvalorant := ff_desvalorfijo(9, f_usu_idioma, vcmutualista_ant);
               vvtvaloract := ff_desvalorfijo(9, f_usu_idioma, vcmutualista);
               vtcambios := vtcambios || CHR(13) || f_axis_literales(180176, f_usu_idioma)
                            || ' - ' || vtvalorant || ' ' || vvtvalorant || ' - '
                            || vtvaloract || ' ' || vvtvaloract;
            END IF;

            IF ((vsnip_ant IS NOT NULL
                 AND vsnip IS NULL)
                OR(vsnip_ant IS NULL
                   AND vsnip IS NOT NULL)
                OR(vsnip_ant != vsnip)) THEN
               vtcambios := vtcambios || CHR(13) || f_axis_literales(1000088, f_usu_idioma)
                            || ' - ' || vtvalorant || '  ' || vsnip_ant || ' - ' || vtvaloract
                            || ' ' || vsnip;
            END IF;

            IF ((vcpreaviso_ant IS NOT NULL
                 AND vcpreaviso IS NULL)
                OR(vcpreaviso_ant IS NULL
                   AND vcpreaviso IS NOT NULL)
                OR(vcpreaviso_ant != vcpreaviso)) THEN
               vvtvalorant := ff_desvalorfijo(9, f_usu_idioma, vcpreaviso_ant);
               vvtvaloract := ff_desvalorfijo(9, f_usu_idioma, vcpreaviso);
               vtcambios := vtcambios || CHR(13) || f_axis_literales(9903597, f_usu_idioma)
                            || ' - ' || vtvalorant || ' ' || vvtvalorant || ' - '
                            || vtvaloract || ' ' || vvtvaloract;
            END IF;
         END IF;

         FOR reg IN (SELECT cagente
                       FROM per_detper
                      WHERE sperson = psperson) LOOP
            SELECT COUNT(1)
              INTO vcambios
              FROM (SELECT hd.cidioma, hd.tapelli1, hd.tapelli2, hd.tnombre, hd.cprofes,
                           hd.cestciv, hd.cpais, hd.tnombre1, hd.tnombre2, hd.cocupacion
                      FROM hisper_detper hd
                     WHERE hd.sperson = psperson
                       AND hd.cagente = reg.cagente
                       /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                       AND fusumod BETWEEN f_sysdate - vsegundo AND f_sysdate
                       AND hd.norden IN(SELECT MAX(norden)
                                          FROM hisper_detper
                                         WHERE sperson = psperson)
                    MINUS
                    SELECT d.cidioma, d.tapelli1, d.tapelli2, d.tnombre, d.cprofes, d.cestciv,
                           d.cpais, d.tnombre1, d.tnombre2, d.cocupacion
                      FROM per_detper d
                     WHERE sperson = psperson
                       AND cagente = reg.cagente);

            IF vcambios > 0 THEN
               /* Miramos cual es el cambio para*/
               SELECT hd.tapelli1, hd.tapelli2, hd.tnombre, hd.cprofes, hd.cestciv,
                      hd.cpais, hd.tnombre1, hd.tnombre2, hd.cocupacion, hd.cidioma
                 INTO vtapelli1_ant, vtapelli2_ant, vtnombre_ant, vcprofes_ant, vcestciv_ant,
                      vcpais_ant, vtnombre1_ant, vtnombre2_ant, vcocupacion_ant, vcidioma_ant
                 FROM hisper_detper hd
                WHERE hd.sperson = psperson
                  AND hd.cagente = reg.cagente
                  /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                  AND fusumod BETWEEN f_sysdate - vsegundo AND f_sysdate
                  AND hd.norden IN(SELECT MAX(norden)
                                     FROM hisper_detper
                                    WHERE sperson = psperson);

               SELECT hd.tapelli1, hd.tapelli2, hd.tnombre, hd.cprofes, hd.cestciv, hd.cpais,
                      hd.tnombre1, hd.tnombre2, hd.cocupacion, hd.cidioma
                 INTO vtapelli1, vtapelli2, vtnombre, vcprofes, vcestciv, vcpais,
                      vtnombre1, vtnombre2, vcocupacion, vcidioma
                 FROM per_detper hd
                WHERE hd.sperson = psperson
                  AND cagente = reg.cagente;

               IF ((vtnombre_ant IS NOT NULL
                    AND vtnombre IS NULL)
                   OR(vtnombre_ant IS NULL
                      AND vtnombre IS NOT NULL)
                   OR(vtnombre_ant != vtnombre)) THEN
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(105940, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vtnombre_ant || ' - '
                               || vtvaloract || ' ' || vtnombre;
               END IF;

               IF ((vtapelli1_ant IS NOT NULL
                    AND vtapelli1 IS NULL)
                   OR(vtapelli1_ant IS NULL
                      AND vtapelli1 IS NOT NULL)
                   OR(vtapelli1_ant != vtapelli1)) THEN
                  /*Selecciona el literal para incluir en la agenda de cambios en funcion de si es tipo de persona es fisico o el resto*/
                  IF vctipper = 1 THEN
                     vliteral := 108243;
                  ELSE
                     vliteral := 9902944;
                  END IF;

                  vtcambios := vtcambios || CHR(13) || f_axis_literales(vliteral, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vtapelli1_ant || ' - '
                               || vtvaloract || ' ' || vtapelli1;
               END IF;

               IF ((vtapelli2_ant IS NOT NULL
                    AND vtapelli2 IS NULL)
                   OR(vtapelli2_ant IS NULL
                      AND vtapelli2 IS NOT NULL)
                   OR(vtapelli2_ant != vtapelli2)) THEN
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(108246, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vtapelli2_ant || ' - '
                               || vtvaloract || ' ' || vtapelli2;
               END IF;

               IF ((vcprofes_ant IS NOT NULL
                    AND vcprofes IS NULL)
                   OR(vcprofes_ant IS NULL
                      AND vcprofes IS NOT NULL)
                   OR(vcprofes_ant != vcprofes)) THEN
                  IF vcprofes_ant IS NOT NULL THEN
                     SELECT p.tprofes
                       INTO vvtvalorant
                       FROM profesiones p
                      WHERE p.cidioma = pac_md_common.f_get_cxtidioma
                        AND p.cprofes = vcprofes_ant;
                  ELSE
                     vvtvalorant := '';
                  END IF;

                  IF vcprofes IS NOT NULL THEN
                     SELECT p.tprofes
                       INTO vvtvaloract
                       FROM profesiones p
                      WHERE p.cidioma = pac_md_common.f_get_cxtidioma
                        AND p.cprofes = vcprofes;
                  ELSE
                     vvtvaloract := '';
                  END IF;

                  vtcambios := vtcambios || CHR(13) || f_axis_literales(110978, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vcocupacion_ant IS NOT NULL
                    AND vcocupacion IS NULL)
                   OR(vcocupacion_ant IS NULL
                      AND vcocupacion IS NOT NULL)
                   OR(vcocupacion_ant != vcocupacion)) THEN
                  IF vcocupacion_ant IS NOT NULL THEN
                     SELECT p.tprofes
                       INTO vvtvalorant
                       FROM profesiones p
                      WHERE p.cidioma = pac_md_common.f_get_cxtidioma
                        AND p.cprofes = vcocupacion_ant;
                  ELSE
                     vvtvalorant := '';
                  END IF;

                  IF vcocupacion IS NOT NULL THEN
                     SELECT p.tprofes
                       INTO vvtvaloract
                       FROM profesiones p
                      WHERE p.cidioma = pac_md_common.f_get_cxtidioma
                        AND p.cprofes = vcocupacion;
                  ELSE
                     vvtvaloract := '';
                  END IF;

                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9904804, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vcpais_ant IS NOT NULL
                    AND vcpais IS NULL)
                   OR(vcpais_ant IS NULL
                      AND vcpais IS NOT NULL)
                   OR(vcpais_ant != vcpais)) THEN
                  IF vcpais_ant IS NOT NULL THEN
                     SELECT tpais
                       INTO vvtvalorant
                       FROM despaises
                      WHERE cidioma = pac_md_common.f_get_cxtidioma
                        AND cpais = vcpais_ant;
                  ELSE
                     vvtvalorant := '';
                  END IF;

                  IF vcpais IS NOT NULL THEN
                     SELECT tpais
                       INTO vvtvaloract
                       FROM despaises
                      WHERE cidioma = pac_md_common.f_get_cxtidioma
                        AND cpais = vcpais;
                  ELSE
                     vvtvaloract := '';
                  END IF;

                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9000789, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vcestciv_ant IS NOT NULL
                    AND vcestciv IS NULL)
                   OR(vcestciv_ant IS NULL
                      AND vcestciv IS NOT NULL)
                   OR(vcestciv_ant != vcestciv)) THEN
                  vvtvalorant := ff_desvalorfijo(12, f_usu_idioma, vcestciv_ant);
                  vvtvaloract := ff_desvalorfijo(12, f_usu_idioma, vcestciv);
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9900955, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;
            /* IF ((vcidioma_ant IS NOT NULL
               AND vcidioma IS NULL)
              OR(vcidioma_ant IS NULL
                 AND vcidioma IS NOT NULL)
              OR(vcidioma_ant != vcidioma)) THEN

               IF vcidioma_ant IS NOT NULL THEN
                SELECT tidioma
                  INTO vvtvalorant
                  FROM idiomas
                 WHERE cidioma = vcidioma_ant;
               ELSE
                  vvtvalorant := '';
               END IF;

              IF vcidioma IS NOT NULL THEN
                SELECT tidioma
                  INTO vvtvaloract
                  FROM idiomas
                 WHERE cidioma = vcidioma;
              ELSE
                  vvtvaloract := '';
              END IF;

                vtcambios := vtcambios || CHR(13) || f_axis_literales(1000246, f_usu_idioma)
                             || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                             || vtvaloract || ' ' || vvtvaloract;
             END IF;*/
            END IF;
         END LOOP;
      ELSIF pmodo = 'DIR' THEN
         FOR reg IN (SELECT cagente
                       FROM per_detper
                      WHERE sperson = psperson) LOOP
            SELECT COUNT(1)
              INTO vcambios
              FROM (SELECT hd.ctipdir, hd.cviavp, hd.tnomvia, hd.clitvp, hd.cbisvp, hd.corvp,
                           hd.nviaadco, hd.clitco, hd.corco, hd.tnum3ia, hd.cpostal, pv.cpais,
                           hd.cprovin, hd.cpoblac
                      FROM hisper_direcciones hd, provincias pv
                     WHERE sperson = psperson
                       AND hd.cagente = reg.cagente
                       AND hd.cprovin = pv.cprovin
                       /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                       AND fusumod BETWEEN f_sysdate - vsegundo AND f_sysdate
                       AND norden IN(SELECT MAX(norden)
                                       FROM hisper_direcciones
                                      WHERE sperson = psperson)
                    MINUS
                    SELECT hd.ctipdir, hd.cviavp, hd.tnomvia, hd.clitvp, hd.cbisvp, hd.corvp,
                           hd.nviaadco, hd.clitco, hd.corco, hd.tnum3ia, hd.cpostal, pv.cpais,
                           hd.cprovin, hd.cpoblac
                      FROM per_direcciones hd, provincias pv
                     WHERE sperson = psperson
                       AND cagente = reg.cagente
                       AND hd.cprovin = pv.cprovin);

            /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
            IF (vcambios = 0) THEN
               SELECT COUNT(*)
                 INTO vcambiosn
                 FROM per_direcciones hd, provincias pv
                WHERE sperson = psperson
                  AND cagente = reg.cagente
                  AND hd.cprovin = pv.cprovin
                  AND hd.fmovimi BETWEEN f_sysdate - vsegundo AND f_sysdate;
            END IF;

            /* FIN RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
            IF (vcambios > 0
                OR vcambiosn > 0) THEN
               /* Miramos cual es el cambio.*/
               /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
               /*IF (vcambiosn<1) THEN*/
               BEGIN
                  SELECT hd.ctipdir, hd.cviavp, hd.tnomvia, hd.clitvp, hd.cbisvp,
                         hd.corvp, hd.nviaadco, hd.clitco, hd.corco, hd.tnum3ia,
                         hd.cpostal, pv.cpais, hd.cprovin, hd.cpoblac, hd.norden,
                         hd.cdomici
                    INTO vctipdir_ant, vcviavp_ant, vtnomvia_ant, vclitvp_ant, vcbisvp_ant,
                         vcorvp_ant, vnviaadco_ant, vclitco_ant, vcorco_ant, vtnum3ia_ant,
                         vcpostal_ant, vcpais_ant, vcprovin_ant, vcpoblac_ant, vdnorden,
                         vdcdomici
                    FROM hisper_direcciones hd, provincias pv
                   WHERE sperson = psperson
                     AND hd.cagente = reg.cagente
                     AND hd.cprovin = pv.cprovin
                     /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                     AND fusumod BETWEEN f_sysdate - vsegundo AND f_sysdate
                     AND norden IN(SELECT MAX(norden)
                                     FROM hisper_direcciones
                                    WHERE sperson = psperson);
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               /*END IF;*/
               /* FIN RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
               IF (vdnorden IS NOT NULL
                   AND vdcdomici IS NOT NULL) THEN
                  SELECT hd.ctipdir, hd.cviavp, hd.tnomvia, hd.clitvp, hd.cbisvp, hd.corvp,
                         hd.nviaadco, hd.clitco, hd.corco, hd.tnum3ia, hd.cpostal, pv.cpais,
                         hd.cprovin, hd.cpoblac
                    INTO vctipdir, vcviavp, vtnomvia, vclitvp, vcbisvp, vcorvp,
                         vnviaadco, vclitco, vcorco, vtnum3ia, vcpostal, vcpais,
                         vcprovin, vcpoblac
                    FROM per_direcciones hd, provincias pv
                   WHERE sperson = psperson
                     AND hd.cagente = reg.cagente
                     AND hd.cprovin = pv.cprovin
                     /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
                     AND cdomici = vdcdomici;
               ELSE
                  SELECT hd.ctipdir, hd.cviavp, hd.tnomvia, hd.clitvp, hd.cbisvp, hd.corvp,
                         hd.nviaadco, hd.clitco, hd.corco, hd.tnum3ia, hd.cpostal, pv.cpais,
                         hd.cprovin, hd.cpoblac
                    INTO vctipdir, vcviavp, vtnomvia, vclitvp, vcbisvp, vcorvp,
                         vnviaadco, vclitco, vcorco, vtnum3ia, vcpostal, vcpais,
                         vcprovin, vcpoblac
                    FROM per_direcciones hd, provincias pv
                   WHERE sperson = psperson
                     AND hd.cagente = reg.cagente
                     AND hd.cprovin = pv.cprovin
                     /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
                     AND cdomici IN(SELECT MAX(cdomici)
                                      FROM per_direcciones
                                     WHERE sperson = psperson)
                                                              /* FIN RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
                  ;
               END IF;

               IF ((vctipdir_ant IS NOT NULL
                    AND vctipdir IS NULL)
                   OR(vctipdir_ant IS NULL
                      AND vctipdir IS NOT NULL)
                   OR(vctipdir_ant != vctipdir)) THEN
                  vvtvalorant := ff_desvalorfijo(191, f_usu_idioma, vctipdir_ant);
                  vvtvaloract := ff_desvalorfijo(191, f_usu_idioma, vctipdir);
                  vtcambios := f_axis_literales(100565, f_usu_idioma) || ' - ' || vtvalorant
                               || ' ' || vvtvalorant || ' - ' || vtvaloract || ' '
                               || vvtvaloract;
               END IF;

               IF ((vcviavp_ant IS NOT NULL
                    AND vcviavp IS NULL)
                   OR(vcviavp_ant IS NULL
                      AND vcviavp IS NOT NULL)
                   OR(vcviavp_ant != vcviavp)) THEN
                  IF vcviavp_ant IS NOT NULL THEN
                     SELECT tdenom
                       INTO vvtvalorant
                       FROM destipos_via
                      WHERE cidioma = pac_md_common.f_get_cxtidioma()
                        AND csiglas = vcviavp_ant;
                  ELSE
                     vvtvalorant := '';
                  END IF;

                  IF vcviavp IS NOT NULL THEN
                     SELECT tdenom
                       INTO vvtvaloract
                       FROM destipos_via
                      WHERE cidioma = pac_md_common.f_get_cxtidioma()
                        AND csiglas = vcviavp;
                  ELSE
                     vvtvaloract := '';
                  END IF;

                  vtcambios := f_axis_literales(9902408, f_usu_idioma) || ' - ' || vtvalorant
                               || ' ' || vvtvalorant || ' - ' || vtvaloract || ' '
                               || vvtvaloract;
               END IF;

               IF ((vtnomvia_ant IS NOT NULL
                    AND vtnomvia IS NULL)
                   OR(vtnomvia_ant IS NULL
                      AND vtnomvia IS NOT NULL)
                   OR(vtnomvia_ant != vtnomvia)) THEN
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9903010, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vtnomvia_ant || ' - '
                               || vtvaloract || ' ' || vtnomvia;
               END IF;

               IF ((vclitvp_ant IS NOT NULL
                    AND vclitvp IS NULL)
                   OR(vclitvp_ant IS NULL
                      AND vclitvp IS NOT NULL)
                   OR(vclitvp_ant != vclitvp)) THEN
                  vvtvalorant := ff_desvalorfijo(800043, f_usu_idioma, vclitvp_ant);
                  vvtvaloract := ff_desvalorfijo(800043, f_usu_idioma, vclitvp);
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9902409, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vcbisvp_ant IS NOT NULL
                    AND vcbisvp IS NULL)
                   OR(vcbisvp_ant IS NULL
                      AND vcbisvp IS NOT NULL)
                   OR(vcbisvp_ant != vcbisvp)) THEN
                  vvtvalorant := ff_desvalorfijo(800044, f_usu_idioma, vcbisvp_ant);
                  vvtvaloract := ff_desvalorfijo(800044, f_usu_idioma, vcbisvp);
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9902410, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vcorvp_ant IS NOT NULL
                    AND vcorvp IS NULL)
                   OR(vcorvp_ant IS NULL
                      AND vcorvp IS NOT NULL)
                   OR(vcorvp_ant != vcorvp)) THEN
                  vvtvalorant := ff_desvalorfijo(800046, f_usu_idioma, vcorvp_ant);
                  vvtvaloract := ff_desvalorfijo(800046, f_usu_idioma, vcorvp);
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9902411, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vnviaadco_ant IS NOT NULL
                    AND vnviaadco IS NULL)
                   OR(vnviaadco_ant IS NULL
                      AND vnviaadco IS NOT NULL)
                   OR(vnviaadco_ant != vnviaadco)) THEN
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9902414, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vnviaadco_ant || ' - '
                               || vtvaloract || ' ' || vnviaadco;
               END IF;

               IF ((vclitco_ant IS NOT NULL
                    AND vclitco IS NULL)
                   OR(vclitco_ant IS NULL
                      AND vclitco IS NOT NULL)
                   OR(vclitco_ant != vclitco)) THEN
                  vvtvalorant := ff_desvalorfijo(800043, f_usu_idioma, vclitco_ant);
                  vvtvaloract := ff_desvalorfijo(800043, f_usu_idioma, vclitco);
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9902409, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vcorco_ant IS NOT NULL
                    AND vcorco IS NULL)
                   OR(vcorco_ant IS NULL
                      AND vcorco IS NOT NULL)
                   OR(vcorco_ant != vcorco)) THEN
                  vvtvalorant := ff_desvalorfijo(800044, f_usu_idioma, vcorco_ant);
                  vvtvaloract := ff_desvalorfijo(800044, f_usu_idioma, vcorco);
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9902411, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vtnum3ia_ant IS NOT NULL
                    AND vtnum3ia IS NULL)
                   OR(vtnum3ia_ant IS NULL
                      AND vtnum3ia IS NOT NULL)
                   OR(vtnum3ia_ant != vtnum3ia)) THEN
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(9902414, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vtnum3ia_ant || ' - '
                               || vtvaloract || ' ' || vtnum3ia;
               END IF;

               IF ((vcpostal_ant IS NOT NULL
                    AND vcpostal IS NULL)
                   OR(vcpostal_ant IS NULL
                      AND vcpostal IS NOT NULL)
                   OR(vcpostal_ant != vcpostal)) THEN
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(101081, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vcpostal_ant || ' - '
                               || vtvaloract || ' ' || vcpostal;
               END IF;

               IF ((vcpais_ant IS NOT NULL
                    AND vcpais IS NULL)
                   OR(vcpais_ant IS NULL
                      AND vcpais IS NOT NULL)
                   OR(vcpais_ant != vcpais)) THEN
                  IF vcpais_ant IS NOT NULL THEN
                     SELECT tpais
                       INTO vvtvalorant
                       FROM paises
                      WHERE cpais = vcpais_ant;
                  ELSE
                     vvtvalorant := '';
                  END IF;

                  IF vcpais IS NOT NULL THEN
                     SELECT tpais
                       INTO vvtvaloract
                       FROM paises
                      WHERE cpais = vcpais;
                  ELSE
                     vvtvaloract := '';
                  END IF;

                  vtcambios := vtcambios || CHR(13) || f_axis_literales(100816, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vcprovin_ant IS NOT NULL
                    AND vcprovin IS NULL)
                   OR(vcprovin_ant IS NULL
                      AND vcprovin IS NOT NULL)
                   OR(vcprovin_ant != vcprovin)) THEN
                  IF vcprovin_ant IS NOT NULL THEN
                     SELECT tprovin
                       INTO vvtvalorant
                       FROM provincias
                      WHERE cprovin = vcprovin_ant;
                  ELSE
                     vvtvalorant := '';
                  END IF;

                  IF vcprovin IS NOT NULL THEN
                     SELECT tprovin
                       INTO vvtvaloract
                       FROM provincias
                      WHERE cprovin = vcprovin;
                  ELSE
                     vvtvaloract := '';
                  END IF;

                  vtcambios := vtcambios || CHR(13) || f_axis_literales(100756, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;

               IF ((vcpoblac_ant IS NOT NULL
                    AND vcpoblac IS NULL)
                   OR(vcpoblac_ant IS NULL
                      AND vcpoblac IS NOT NULL)
                   OR(vcpoblac_ant != vcpoblac)) THEN
                  IF vcpoblac_ant IS NOT NULL THEN
                     SELECT tpoblac
                       INTO vvtvalorant
                       FROM poblaciones
                      WHERE cpoblac = vcpoblac_ant
                        AND cprovin = vcprovin_ant;
                  ELSE
                     vvtvalorant := '';
                  END IF;

                  IF vcpoblac IS NOT NULL THEN
                     SELECT tpoblac
                       INTO vvtvaloract
                       FROM poblaciones
                      WHERE cpoblac = vcpoblac
                        AND cprovin = vcprovin;
                  ELSE
                     vvtvaloract := '';
                  END IF;

                  vtcambios := vtcambios || CHR(13) || f_axis_literales(100817, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;
            END IF;
         END LOOP;
      ELSIF pmodo = 'CCC' THEN
         FOR reg IN (SELECT cagente
                       FROM per_detper
                      WHERE sperson = psperson) LOOP
            /*Miramos primero cuentas bancarias: fvencim IS null*/
            SELECT COUNT(1)
              INTO vcambios
              FROM (SELECT hd.cdefecto
                      FROM hisper_ccc hd
                     WHERE sperson = psperson
                       AND cagente = reg.cagente
                       /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                       AND fusumov BETWEEN f_sysdate - vsegundo AND f_sysdate
                       AND fvencim IS NULL
                       AND norden IN(SELECT MAX(norden)
                                       FROM hisper_ccc
                                      WHERE sperson = psperson)
                    MINUS
                    SELECT hd.cdefecto
                      FROM per_ccc hd
                     WHERE sperson = psperson
                       AND cagente = reg.cagente
                       AND fvencim IS NULL
                       AND cnordban IN(SELECT MAX(cnordban)
                                         FROM per_ccc
                                        WHERE sperson = psperson));

            IF vcambios > 0 THEN
               /* Miramos cual es el cambio para*/
               SELECT hd.cdefecto
                 INTO vcdefecto_ant
                 FROM hisper_ccc hd
                WHERE sperson = psperson
                  AND cagente = reg.cagente
                  /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                  AND fusumov BETWEEN f_sysdate - vsegundo AND f_sysdate
                  AND fvencim IS NULL
                  AND norden IN(SELECT MAX(norden)
                                  FROM hisper_ccc
                                 WHERE sperson = psperson);

               SELECT hd.cdefecto
                 INTO vcdefecto
                 FROM per_ccc hd
                WHERE sperson = psperson
                  AND cagente = reg.cagente
                  AND fvencim IS NULL
                  AND cnordban IN(SELECT MAX(cnordban)
                                    FROM per_ccc
                                   WHERE sperson = psperson);

               /*Si las fechas de vencimiento estan vacias, estamos tratando con una cuenta bancaria*/
               IF vcdefecto_ant != vcdefecto THEN
                  vvtvalorant := ff_desvalorfijo(36, f_usu_idioma, vcdefecto_ant);
                  vvtvaloract := ff_desvalorfijo(36, f_usu_idioma, vcdefecto);
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(100713, f_usu_idioma)
                               || ' - ' || vtvalorant || '  ' || vvtvalorant || ' - '
                               || vtvaloract || ' ' || vvtvaloract;
               END IF;
            END IF;

            /*Miramos primero tarjetas bancarias: fvencim IS null*/
            SELECT COUNT(1)
              INTO vcambios
              FROM (SELECT hd.fvencim
                      FROM hisper_ccc hd
                     WHERE sperson = psperson
                       /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                       AND fusumov BETWEEN f_sysdate - vsegundo AND f_sysdate
                       AND fvencim IS NOT NULL
                       AND norden IN(SELECT MAX(norden)
                                       FROM hisper_ccc
                                      WHERE sperson = psperson)
                    MINUS
                    SELECT hd.fvencim
                      FROM per_ccc hd
                     WHERE sperson = psperson
                       AND fvencim IS NOT NULL
                       AND cnordban IN(SELECT MAX(cnordban)
                                         FROM per_ccc
                                        WHERE sperson = psperson));

            IF vcambios > 0 THEN
               /* Miramos cual es el cambio para*/
               SELECT hd.fvencim
                 INTO vfvencim_ant
                 FROM hisper_ccc hd
                WHERE sperson = psperson
                  /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                  AND fusumov BETWEEN f_sysdate - vsegundo AND f_sysdate
                  AND fvencim IS NOT NULL
                  AND norden IN(SELECT MAX(norden)
                                  FROM hisper_ccc
                                 WHERE sperson = psperson);

               SELECT hd.fvencim
                 INTO vfvencim
                 FROM per_ccc hd
                WHERE sperson = psperson
                  AND fvencim IS NOT NULL
                  AND cnordban IN(SELECT MAX(cnordban)
                                    FROM per_ccc
                                   WHERE sperson = psperson);

               /*Si las fechas de vencimiento no estan vacias, estamos tratando con una tarjeta*/
               IF vfvencim_ant != vfvencim THEN
                  vtcambios := vtcambios || CHR(13) || f_axis_literales(100885, f_usu_idioma)
                               || ' - ' || vtvalorant || '  '
                               || TO_CHAR(vfvencim_ant, 'mm/yyyy') || ' - ' || vtvaloract
                               || ' ' || TO_CHAR(vfvencim, 'mm/yyyy');
               END IF;
            END IF;

            /* BUG 27314/162960*/
            /* Graba registro del alta de la CCC en la agenda.*/
            SELECT COUNT(1)
              INTO vcambios
              FROM per_ccc hd
             WHERE sperson = psperson
               AND cagente = reg.cagente
               AND fvencim IS NULL
               AND falta IN(SELECT MAX(falta)
                              FROM per_ccc
                             WHERE sperson = psperson);

            IF vcambios > 0 THEN
               SELECT d.ttipo, cc.cbancar
                 INTO vttipo, vcbancar
                 FROM per_ccc cc, tipos_cuentades d
                WHERE sperson = psperson
                  AND cagente = reg.cagente
                  AND fvencim IS NULL
                  AND falta IN(SELECT MAX(falta)
                                 FROM per_ccc
                                WHERE sperson = psperson)
                  AND cc.ctipban = d.ctipban
                  AND d.cidioma = f_usu_idioma;

               vtcambios := vtcambios || CHR(13) || f_axis_literales(9000964, f_usu_idioma)
                            || ': ' || vttipo || '  ' || f_axis_literales(100965, f_usu_idioma)
                            || ': ' || vcbancar;
            END IF;
         END LOOP;
      /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
      ELSIF pmodo = 'CNT' THEN   -- CONTACTOS
         SELECT COUNT(1)
           INTO vcambios
           FROM (SELECT hd.ctipcon, hd.tvalcon
                   FROM hisper_contactos hd
                  WHERE sperson = psperson
                    /*AND hd.cagente = reg.cagente*/
                    /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                    AND hd.fusumod BETWEEN f_sysdate - vsegundo AND f_sysdate
                    AND hd.cmodcon IN(SELECT MAX(cmodcon)
                                        FROM hisper_contactos
                                       WHERE sperson = psperson)
                 MINUS
                 SELECT hd.ctipcon, hd.tvalcon
                   FROM per_contactos hd
                  WHERE hd.sperson = psperson
                                             /*AND   hd.cagente = reg.cagente*/
                );

         /* INI RLLF 10/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
         IF (vcambios = 0) THEN
            SELECT COUNT(*)
              INTO vcambiosn
              FROM per_contactos hd
             WHERE hd.sperson = psperson
               /*AND hd.cagente = reg.cagente*/
               AND hd.fmovimi BETWEEN f_sysdate - vsegundo AND f_sysdate;
         END IF;

         /* FIN RLLF 10/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
         IF (vcambios > 0
             OR vcambiosn > 0) THEN
            /* Miramos cual es el cambio.*/
            /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
            /*IF (vcambiosn<1) THEN*/
            BEGIN
               SELECT hd.ctipcon, hd.tvalcon, hd.cmodcon, hd.norden
                 INTO vctipcon_ant, vctvalcon_ant, vcmodcon_ant, vnorden_ant
                 FROM hisper_contactos hd
                WHERE hd.sperson = psperson
                  /*AND hd.cagente = reg.cagente*/
                  /* Intervalo en segundos para que solo inserte en la agenda un unico registro*/
                  AND hd.fusumod BETWEEN f_sysdate - vsegundo AND f_sysdate
                  AND hd.cmodcon IN(SELECT MAX(cmodcon)
                                      FROM hisper_contactos
                                     WHERE sperson = psperson);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            /*END IF;*/
            /* FIN RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
            IF (vcmodcon_ant IS NOT NULL
                AND vnorden_ant IS NOT NULL) THEN
               SELECT hd.ctipcon, hd.tvalcon
                 INTO vctipcon, vctvalcon
                 FROM per_contactos hd
                WHERE hd.sperson = psperson
                  AND hd.cmodcon = vcmodcon_ant;
            ELSE
               SELECT hd.ctipcon, hd.tvalcon
                 INTO vctipcon, vctvalcon
                 FROM per_contactos hd
                WHERE hd.sperson = psperson
                  /*AND hd.cagente = reg.cagente*/
                  /* INI RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
                  AND hd.cmodcon IN(SELECT MAX(cmodcon)
                                      FROM per_contactos
                                     WHERE sperson = psperson)
                                                              /* FIN RLLF 09/09/2015 No graba los movimientos en la agenda - sian bug-34464*/
               ;
            END IF;

            /* Comprobación de cambio en el tipo de contacto.*/
            IF ((vctipcon_ant IS NOT NULL
                 AND vctipcon IS NULL)
                OR(vctipcon_ant IS NULL
                   AND vctipcon IS NOT NULL)
                OR(vctipdir_ant != vctipdir)) THEN
               vvtvalorant := ff_desvalorfijo(15, f_usu_idioma, vctipcon_ant);
               vvtvaloract := ff_desvalorfijo(15, f_usu_idioma, vctipcon);
               vtcambios := f_axis_literales(100565, f_usu_idioma) || ' - ' || vtvalorant
                            || '  ' || vvtvalorant || ' - ' || vtvaloract || '  '
                            || vvtvaloract;
            END IF;

            /* Comprobación de cambio en el valor del contacto.*/
            IF ((vctvalcon_ant IS NOT NULL
                 AND vctvalcon IS NULL)
                OR(vctvalcon_ant IS NULL
                   AND vctvalcon IS NOT NULL)
                OR(vctvalcon_ant != vctvalcon)) THEN
               vtcambios := vtcambios || CHR(13) || f_axis_literales(101159, f_usu_idioma)
                            || ' - ' || vtvalorant || '  ' || vctvalcon_ant || ' - '
                            || vtvaloract || '  ' || vctvalcon;
            END IF;
         END IF;
      END IF;

      FOR rg_agensegu IN cur_agensegu_rol(psperson) LOOP
         IF vtcambios IS NOT NULL THEN
            num_err := pac_agensegu.f_set_datosapunte(0, rg_agensegu.sseguro, 0,
                                                      f_axis_literales(rg_agensegu.slitera,
                                                                       f_usu_idioma),
                                                      vtcambios, 6, 1, f_sysdate, f_sysdate,
                                                      0, 0);
         END IF;

         IF num_err <> 0 THEN
            RAISE salir;
         END IF;
      END LOOP;

      RETURN(0);
   /**/
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     f_axis_literales(num_err));
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user,
                     vobjectname || ':sperson:' || psperson || ':pcidioma:' || pcidioma,
                     vpasexec, vparam, 'ERROR: ' || SQLERRM);
         RETURN(9001151);
   END f_set_agensegu_rol;

   /****************************************************************************
      F_CONVERTIR_APUBLICA: Convierte una persona a pública

      Bug 29166/160004 - 29/11/2013 - AMC
   ****************************************************************************/
   FUNCTION f_convertir_apublica(psperson NUMBER)
      RETURN NUMBER IS
      vpervisionpublica NUMBER;
   BEGIN
      vpervisionpublica :=
         NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                           'PER_VISIONPUBLICA'),
             0);

      IF NVL(vpervisionpublica, 0) = 1 THEN
         UPDATE per_personas
            SET swpubli = 1,
                cagente = (SELECT MIN(cagente)
                             FROM per_detper
                            WHERE sperson = psperson)
          WHERE sperson = psperson;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_convertir_apublica', 1, 'psperson:' || psperson,
                     'ERROR:' || SQLERRM);
         RETURN 1;
   END f_convertir_apublica;

   /****************************************************************************
      F_EXISTE_ESTPERSONA: Mira si una persona ya ha sido traspasada a las tablas est

      Bug 29324/166247 - 21/12/2014- AMC
   ****************************************************************************/
   FUNCTION f_existe_estpersona(psperson IN NUMBER, psseguro IN NUMBER, pexiste IN OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT COUNT(1)
        INTO pexiste
        FROM estper_personas
       WHERE spereal = psperson
         AND sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_existe_estpersona', 1,
                     'psperson:' || psperson || ' psseguro:' || psseguro, 'ERROR:' || SQLERRM);
         RETURN 1;
   END f_existe_estpersona;

    /* Formatted on 24/10/2016 14:28 (Formatter Plus v4.8.8) - (CSI-Factory Standard Format v.2.0) */
FUNCTION f_get_datsarlatf(
   pssarlaft IN NUMBER,
   pfradica IN DATE,
   psperson IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN sys_refcursor IS
   v_cursor       sys_refcursor;
   vpasexec       NUMBER;
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_datsarlatf';
   vparam         VARCHAR2(500) := '';
BEGIN
   IF pssarlaft IS NOT NULL THEN
      OPEN v_cursor FOR
    /*  Ini CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018 */
         SELECT ssarlaft, fradica, sperson, fdiligencia, cauttradat, crutfcc, cestconf,
                fconfir, cvinculacion, tvinculacion, percdeptosol, pertdeptosol, percciusol, pertciusol,
                cvintomase, tvintomase, cvintomben, tvintombem,
                cvinaseben, tvinasebem, cactippal, persectorppal, nciiuppal, tcciiuppal, pertipoactivppal, tocupacion, tcargo, tempresa,csujetooblifacion, tindiqueoblig,pernacion2 as per_nacion2,
                tdirempresa, percdeptoofic, pertdeptoofic, percciuofic, pertciuofic, ttelempresa, cactisec, nciiusec, tcciiusec, tdirsec, ttelsec, tprodservcom,
                iingresos, iactivos, ipatrimonio, iegresos, ipasivos, iotroingreso,
                tconcotring, cmanrecpub, cpodpub, crecpub, cvinperpub, tvinperpub,
                cdectribext, tdectribext, torigfond, ctraxmodext, ttraxmodext, cprodfinext,
                cctamodext, totrasoper, creclindseg, tciudadsuc, tpaisuc, tdepatamentosuc, tciudad, tdepatamento, tpais,
                tlugarexpedidoc, resociedad, tnacionali2, ngradopod, ngozrec, nparticipa,
                nvinculo, ntipdoc, TO_CHAR(fexpedicdoc, 'DD/MM/YYYY') as fexpedicdoc, TO_CHAR(fnacimiento, 'DD/MM/YYYY') as fnacimiento, nrazonso, tnit, tdv, toficinapri,
                ttelefono, tfax, tsucursal, ttelefonosuc, tfaxsuc, ctipoemp, tcualtemp,
                tsector, cciiu, tactiaca, trepresentanle, tsegape, tnombres, tnumdoc,
                tlugnaci, tnacionali1, tindiquevin, perpapellido as per_papellido, persapellido as per_sapellido, pernombres as per_nombres,
                pertipdocument as per_tipdocument, perdocument as per_document, TO_CHAR (perfexpedicion, 'DD/MM/YYYY') as per_fexpedicion, perlugexpedicion as per_lugexpedicion,   -- TCS_1560 - ACL - 21/02/2019
                TO_CHAR (perfnacimi, 'DD/MM/YYYY') as per_fnacimi, perlugnacimi as per_lugnacimi, pernacion1 as per_nacion1, perdirereci as per_direreci, perpais as per_pais, perciudad as per_ciudad,  -- TCS_1560 - ACL - 21/02/2019
                perdepartament as per_departament, peremail as per_email, pertelefono as per_telefono, percelular as per_celular, nrecpub,
                tpresetreclamaci, pertlugexpedicion as per_tlugexpedicion, pertlugnacimi as per_tlugnacimi, pertnacion1 as per_tnacion1,
                pertnacion2 as per_tnacion2, pertpais as per_tpais, pertdepartament as per_tdepartament, pertciudad as per_tciudad, emptpais,
                emptdepatamento, emptciudad, emptpaisuc, emptdepatamentosuc, emptciudadsuc,
                emptlugnaci, emptnacionali1, emptnacionali2,
                perpaisexpedicion as per_paisexpedicion,pertpaisexpedicion as per_tpaisexpedicion,perdepexpedicion as per_depexpedicion,pertdepexpedicion as per_tdepexpedicion,
                perpaislugnacimi as per_paislugnacimi,pertpaislugnacimi as per_tpaislugnacimi,perdeplugnacimi as per_deplugnacimi,pertdeplugnacimi as per_tdeplugnacimi,
                emppaisexpedicion as emp_paisexpedicion,emptpaisexpedicion as emp_tpaisexpedicion,empdepexpedicion as emp_depexpedicion,emptdepexpedicion as emp_tdepexpedicion,
                emppaislugnacimi as emp_paislugnacimi,emptpaislugnacimi as emp_tpaislugnacimi,empdeplugnacimi as emp_deplugnacimi,emptdeplugnacimi as emp_tdeplugnacimi,
                emplugnacimi as emp_lugnacimi,emptlugnacimi as emp_tlugnacimi,empfexpedicion as emp_fexpedicion,emplugexpedicion as emp_lugexpedicion,emptlugexpedicion as emp_tlugexpedicion,
                cciusol, csucursal, ctipsol , csector , ctipact , cciuofc , cdepofc , tmailrepl, tdirsrepl, cciurrepl, tciurrepl, cdeprrepl, tdeprrepl, cpairrepl, tpairrepl, ttelrepl, tcelurepl,
                cdeptoentrev, tdeptoentrev, cciuentrev, tciuentrev, fentrevista, thoraentrev ,tagenentrev ,tasesentrev ,tobseentrev ,crestentrev ,tobseconfir ,thoraconfir ,templconfir, corigenfon, ff_desvalorfijo (790003, pac_md_common.f_get_cxtidioma, cestconf) as estado,
                cuser, falta, --TCS-9 AP 12/02/2019
                cclausula1, cclausula2, cconfir, tmailjurid, TO_CHAR(fconfirfor, 'DD/MM/YYYY') -- IAXIS-3287 01/04/2019
           FROM datsarlatf
          WHERE 1 = 1
            AND ssarlaft =  pssarlaft;


   ELSIF psperson IS NOT NULL THEN
      OPEN v_cursor FOR
         SELECT ssarlaft, fradica, sperson, fdiligencia, cauttradat, crutfcc, cestconf,
                fconfir, cvinculacion, tvinculacion, percdeptosol, pertdeptosol, percciusol, pertciusol,
                cvintomase, tvintomase, cvintomben, tvintombem,
                cvinaseben, tvinasebem, cactippal, persectorppal, nciiuppal, tcciiuppal, pertipoactivppal, tocupacion, tcargo, tempresa,csujetooblifacion, tindiqueoblig,pernacion2 as per_nacion2,
                tdirempresa, percdeptoofic, pertdeptoofic, percciuofic, pertciuofic, ttelempresa, cactisec, nciiusec, tcciiusec, tdirsec, ttelsec, tprodservcom,
                iingresos, iactivos, ipatrimonio, iegresos, ipasivos, iotroingreso,
                tconcotring, cmanrecpub, cpodpub, crecpub, cvinperpub, tvinperpub,
                cdectribext, tdectribext, torigfond, ctraxmodext, ttraxmodext, cprodfinext,
                cctamodext, totrasoper, creclindseg, tciudadsuc, tpaisuc, tdepatamentosuc, tciudad, tdepatamento, tpais,
                tlugarexpedidoc, resociedad, tnacionali2, ngradopod, ngozrec, nparticipa,
                nvinculo, ntipdoc, fexpedicdoc, fnacimiento, nrazonso, tnit, tdv, toficinapri,
                ttelefono, tfax, tsucursal, ttelefonosuc, tfaxsuc, ctipoemp, tcualtemp,
                tsector, cciiu, tactiaca, trepresentanle, tsegape, tnombres, tnumdoc,
                tlugnaci, tnacionali1, tindiquevin, perpapellido as per_papellido, persapellido as per_sapellido, pernombres as per_nombres,
                pertipdocument as per_tipdocument, perdocument as per_document, perfexpedicion as per_fexpedicion, perlugexpedicion as per_lugexpedicion,
                perfnacimi as per_fnacimi, perlugnacimi as per_lugnacimi, pernacion1 as per_nacion1, perdirereci as per_direreci, perpais as per_pais, perciudad as per_ciudad,
                perdepartament as per_departament, peremail as per_email, pertelefono as per_telefono, percelular as per_celular, nrecpub,
                tpresetreclamaci, pertlugexpedicion as per_tlugexpedicion, pertlugnacimi as per_tlugnacimi, pertnacion1 as per_tnacion1,
                pertnacion2 as per_tnacion2, pertpais as per_tpais, pertdepartament as per_tdepartament, pertciudad as per_tciudad, emptpais,
                emptdepatamento, emptciudad, emptpaisuc, emptdepatamentosuc, emptciudadsuc,
                emptlugnaci, emptnacionali1, emptnacionali2,
                perpaisexpedicion as per_paisexpedicion,pertpaisexpedicion as per_tpaisexpedicion,perdepexpedicion as per_depexpedicion,pertdepexpedicion as per_tdepexpedicion,
                perpaislugnacimi as per_paislugnacimi,pertpaislugnacimi as per_tpaislugnacimi,perdeplugnacimi as per_deplugnacimi,pertdeplugnacimi as per_tdeplugnacimi,
                emppaisexpedicion as emp_paisexpedicion,emptpaisexpedicion as emp_tpaisexpedicion,empdepexpedicion as emp_depexpedicion,emptdepexpedicion as emp_tdepexpedicion,
                emppaislugnacimi as emp_paislugnacimi,emptpaislugnacimi as emp_tpaislugnacimi,empdeplugnacimi as emp_deplugnacimi,emptdeplugnacimi as emp_tdeplugnacimi,
                emplugnacimi as emp_lugnacimi,emptlugnacimi as emp_tlugnacimi,empfexpedicion as emp_fexpedicion,emplugexpedicion as emp_lugexpedicion,emptlugexpedicion as emp_tlugexpedicion,
                cciusol, csucursal, ctipsol , csector , ctipact , cciuofc , cdepofc , tmailrepl, tdirsrepl, cciurrepl, tciurrepl, cdeprrepl, tdeprrepl, cpairrepl, tpairrepl, ttelrepl, tcelurepl,
                cdeptoentrev, tdeptoentrev, cciuentrev, tciuentrev, fentrevista, thoraentrev ,tagenentrev ,tasesentrev ,tobseentrev ,crestentrev ,tobseconfir ,thoraconfir ,templconfir, corigenfon, ff_desvalorfijo (790003, pac_md_common.f_get_cxtidioma, cestconf) as estado,
                cuser, falta, --TCS-9 AP 12/02/2019
                cclausula1, cclausula2, cconfir, tmailjurid, fconfirfor-- IAXIS-3287 01/04/2019
           FROM datsarlatf
          WHERE 1 = 1
            AND sperson = psperson
       ORDER BY ssarlaft asc;
     /*  Fin CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018 */
   END IF;

   RETURN v_cursor;
EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN NULL;
END f_get_datsarlatf;

FUNCTION f_set_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      pfdiligencia IN DATE,
      pcauttradat IN NUMBER,
      pcrutfcc IN NUMBER,
      pcestconf IN NUMBER,
      pfconfir IN DATE,
      pcvinculacion IN NUMBER,
      ptvinculacion IN VARCHAR2,
      per_cdeptosol IN NUMBER,
      per_tdeptosol IN VARCHAR2,
      per_cciusol IN NUMBER,
      per_tciusol IN VARCHAR2,
      pcvintomase IN NUMBER,
      ptvintomase IN VARCHAR2,
      pcvintomben IN NUMBER,
      ptvintombem IN VARCHAR2,
      pcvinaseben IN NUMBER,
      ptvinasebem IN VARCHAR2,
      pcactippal IN NUMBER,
      ppersectorppal IN NUMBER,
      pnciiuppal IN NUMBER,
      ptcciiuppal IN VARCHAR2,
      ppertipoactivppal IN VARCHAR2,
      ptocupacion IN VARCHAR2,
      ptcargo IN VARCHAR2,
      ptempresa IN VARCHAR2,
      ptdirempresa IN VARCHAR2,
      ppercdeptoofic IN NUMBER,
      ppertdeptoofic IN VARCHAR2,
      ppercciuofic IN NUMBER,
      ppertciuofic IN VARCHAR2,
      pttelempresa IN VARCHAR2,
      pcactisec IN VARCHAR2,
      pnciiusec IN NUMBER,
      ptcciiusec IN VARCHAR2,
      ptdirsec IN VARCHAR2,
      pttelsec IN VARCHAR2,
      ptprodservcom IN VARCHAR2,
      piingresos IN NUMBER,
      piactivos IN NUMBER,
      pipatrimonio IN NUMBER,
      piegresos IN NUMBER,
      pipasivos IN NUMBER,
      piotroingreso IN NUMBER,
      ptconcotring IN VARCHAR2,
      pcmanrecpub IN NUMBER,
      pcpodpub IN NUMBER,
      pcrecpub IN NUMBER,
      pcvinperpub IN NUMBER,
      ptvinperpub IN VARCHAR2,
      pcdectribext IN NUMBER,
      ptdectribext IN VARCHAR2,
      ptorigfond IN VARCHAR2,
      pctraxmodext IN NUMBER,
      pttraxmodext IN VARCHAR2,
      pcprodfinext IN NUMBER,
      pcctamodext IN NUMBER,
      ptotrasoper IN VARCHAR2,
      pcreclindseg IN NUMBER,
      ptciudadsuc IN NUMBER,
      ptpaisuc IN NUMBER,
      ptdepatamentosuc IN NUMBER,
      ptciudad IN NUMBER,
      ptdepatamento IN NUMBER,
      ptpais IN NUMBER,
      ptlugarexpedidoc IN NUMBER,
      presociedad IN NUMBER,
      ptnacionali2 IN NUMBER,
      pngradopod IN NUMBER,
      pngozrec IN NUMBER,
      pnparticipa IN NUMBER,
      pnvinculo IN NUMBER,
      pntipdoc IN NUMBER,
      pfexpedicdoc IN DATE,
      pfnacimiento IN DATE,
      pnrazonso IN VARCHAR2,
      ptnit IN VARCHAR2,
      ptdv IN VARCHAR2,
      ptoficinapri IN VARCHAR2,
      pttelefono IN VARCHAR2,
      ptfax IN VARCHAR2,
      ptsucursal IN VARCHAR2,
      pttelefonosuc IN VARCHAR2,
      ptfaxsuc IN VARCHAR2,
      pctipoemp IN VARCHAR2,
      ptcualtemp IN VARCHAR2,
      ptsector IN VARCHAR2,
      pcciiu IN NUMBER,
      ptactiaca IN VARCHAR2,
      ptmailjurid IN VARCHAR2,
      ptrepresentanle IN VARCHAR2,
      ptsegape IN VARCHAR2,
      ptnombres IN VARCHAR2,
      ptnumdoc IN VARCHAR2,
      ptlugnaci IN VARCHAR2,
      ptnacionali1 IN VARCHAR2,
      ptindiquevin IN VARCHAR2,
      pper_papellido IN VARCHAR2,
      pper_sapellido IN VARCHAR2,
      pper_nombres IN VARCHAR2,
      pper_tipdocument IN NUMBER,
      pper_document IN VARCHAR2,
      pper_fexpedicion IN DATE,
      pper_lugexpedicion IN NUMBER,
      pper_fnacimi IN DATE,
      pper_lugnacimi IN NUMBER,
      pper_nacion1 IN NUMBER,
      pper_direreci IN VARCHAR2,
      pper_pais IN NUMBER,
      pper_ciudad IN NUMBER,
      pper_departament IN NUMBER,
      pper_email IN VARCHAR2,
      pper_telefono IN VARCHAR2,
      pper_celular IN VARCHAR2,
      pnrecpub IN NUMBER,
      ptpresetreclamaci IN NUMBER,
      pper_tlugexpedicion IN VARCHAR2,
      pper_tlugnacimi IN VARCHAR2,
      pper_tnacion1 IN VARCHAR2,
      pper_tnacion2 IN VARCHAR2,
      pper_tpais IN VARCHAR2,
      pper_tdepartament IN VARCHAR2,
      pper_tciudad IN VARCHAR2,
      pemptpais IN VARCHAR2,
      pemptdepatamento IN VARCHAR2,
      pemptciudad IN VARCHAR2,
      pemptpaisuc IN VARCHAR2,
      pemptdepatamentosuc IN VARCHAR2,
      pemptciudadsuc IN VARCHAR2,
      pemptlugnaci IN VARCHAR2,
      pemptnacionali1 IN VARCHAR2,
      pemptnacionali2 IN VARCHAR2,
      pcsujetooblifacion IN NUMBER,
      ptindiqueoblig IN VARCHAR2,
      pper_paisexpedicion IN NUMBER,
      pper_tpaisexpedicion IN VARCHAR2,
      pper_depexpedicion IN NUMBER,
      pper_tdepexpedicion IN VARCHAR2,
      pper_paislugnacimi IN NUMBER,
      pper_tpaislugnacimi IN VARCHAR2,
      pper_deplugnacimi IN NUMBER,
      pper_tdeplugnacimi IN VARCHAR2,
      pemp_paisexpedicion IN NUMBER,
      pemp_tpaisexpedicion IN VARCHAR2,
      pemp_depexpedicion IN NUMBER,
      pemp_tdepexpedicion IN VARCHAR2,
      pemp_paislugnacimi IN NUMBER,
      pemp_tpaislugnacimi IN VARCHAR2,
      pemp_deplugnacimi IN NUMBER,
      pemp_tdeplugnacimi IN VARCHAR2,
      pemp_lugnacimi IN NUMBER,
      pemp_tlugnacimi IN VARCHAR2,
      pemp_fexpedicion IN DATE,
      pemp_lugexpedicion IN NUMBER,
      pemp_tlugexpedicion IN VARCHAR2,
      pper_nacion2 IN NUMBER,
      pper_pcciusol IN NUMBER DEFAULT NULL,
      pper_pcsucursal IN NUMBER, --CP0615M_SYS_PERS AP 28/12/2018
      pper_pctipsol IN NUMBER DEFAULT NULL,
      pper_pcsector IN NUMBER DEFAULT NULL,
      pper_pctipact IN VARCHAR2 DEFAULT NULL,
      pper_pcciuofc IN NUMBER DEFAULT NULL,
      pper_pcdepofc IN NUMBER DEFAULT NULL,
      pemp_tmailrepl IN VARCHAR2  DEFAULT NULL,
      pemp_tdirsrepl IN VARCHAR2 DEFAULT NULL,
      pemp_cciurrepl IN NUMBER DEFAULT NULL,
      pemp_tciurrepl IN VARCHAR2,
      pemp_cdeprrepl IN NUMBER DEFAULT NULL,
      pemp_tdeprrepl IN VARCHAR2,
      pemp_cpairrepl IN NUMBER DEFAULT NULL,
      pemp_tpairrepl IN VARCHAR2,
      pemp_ttelrepl IN NUMBER DEFAULT NULL,
      pemp_tcelurepl IN NUMBER DEFAULT NULL,
      pcdeptoentrev IN NUMBER DEFAULT NULL,
      ptdeptoentrev IN VARCHAR2,
      pcciuentrev  IN NUMBER DEFAULT NULL,
      ptciuentrev IN VARCHAR2,
      pfentrevista IN DATE DEFAULT NULL,
      pthoraentrev IN VARCHAR2 DEFAULT NULL,
      ptagenentrev IN VARCHAR2 DEFAULT NULL,
      ptasesentrev IN VARCHAR2 DEFAULT NULL,
      ptobseentrev IN VARCHAR2 DEFAULT NULL,
      pcrestentrev IN NUMBER DEFAULT NULL,
      ptobseconfir IN VARCHAR2 DEFAULT NULL,
      pthoraconfir IN VARCHAR2 DEFAULT NULL,
      ptemplconfir IN VARCHAR2 DEFAULT NULL,
    pcorigenfon  IN VARCHAR2 DEFAULT NULL,
      pcclausula1  IN NUMBER DEFAULT NULL, --TCS-9 AP 12/02/2019
      pcclausula2  IN NUMBER DEFAULT NULL, --TCS-9 AP 12/02/2019
      pcconfir     IN NUMBER DEFAULT NULL, --IAXIS-3287 01/04/2019
      mensajes OUT t_iax_mensajes)   -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018
   RETURN NUMBER IS
   vnumerr        NUMBER(8) := 0;
   vpasexec       NUMBER(8) := 1;
   vparam         VARCHAR2(500) := '';
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_set_datsarlatf';
   v_seq           NUMBER; --CP0615M_SYS_PERS AP 29/01/2019
   /* Cambios de  tarea IAXIS-13044 : Start */
   VPERSON_NUM_ID  number;
   /* Cambios de  tarea IAXIS-13044 : End */
BEGIN
   --IF pssarlaft IS NULL THEN
   BEGIN


      INSERT INTO datsarlatf
                  (ssarlaft, fradica, sperson, fdiligencia, cauttradat, crutfcc,
                   cestconf, fconfir, cvinculacion, tvinculacion, percdeptosol, pertdeptosol, percciusol, pertciusol,
                   cvintomase, tvintomase, cvintomben,
                   tvintombem, cvinaseben, tvinasebem, cactippal, persectorppal, nciiuppal, tcciiuppal, pertipoactivppal,
                   tocupacion, tcargo, tempresa, tdirempresa, percdeptoofic, pertdeptoofic, percciuofic, pertciuofic, ttelempresa, cactisec,
                   nciiusec, tcciiusec, tdirsec, ttelsec, tprodservcom, iingresos, iactivos,
                   ipatrimonio, iegresos, ipasivos, iotroingreso, tconcotring,
                   cmanrecpub, cpodpub, crecpub, cvinperpub, tvinperpub, cdectribext,
                   tdectribext, torigfond, ctraxmodext, ttraxmodext, cprodfinext,
                   cctamodext, totrasoper, creclindseg, tciudadsuc, tdepatamentosuc, tpaisuc, tciudad, tdepatamento,
                   tpais, tlugarexpedidoc, resociedad, tnacionali2, ngradopod, ngozrec,
                   nparticipa, nvinculo, ntipdoc, fexpedicdoc, fnacimiento, nrazonso,
                   tnit, tdv, toficinapri, ttelefono, tfax, tsucursal, ttelefonosuc,
                   tfaxsuc, ctipoemp, tcualtemp, tsector, cciiu, tactiaca, tmailjurid,
                   trepresentanle, tsegape, tnombres, tnumdoc, tlugnaci, tnacionali1,
                   tindiquevin, perpapellido, persapellido, pernombres,
                   pertipdocument, perdocument, perfexpedicion, perlugexpedicion,
                   perfnacimi, perlugnacimi, pernacion1, perdirereci, perpais,
                   perciudad, perdepartament, peremail, pertelefono, percelular,
                   nrecpub, tpresetreclamaci, pertlugexpedicion, pertlugnacimi,
                   pertnacion1, pertnacion2, pertpais, pertdepartament, pertciudad,
                   emptpais, emptdepatamento, emptciudad, emptpaisuc,
                   emptdepatamentosuc, emptciudadsuc, emptlugnaci, emptnacionali1,
                   emptnacionali2,csujetooblifacion, tindiqueoblig,perpaisexpedicion,pertpaisexpedicion,
                   perdepexpedicion,pertdepexpedicion,perpaislugnacimi,
                   pertpaislugnacimi,perdeplugnacimi,pertdeplugnacimi,emppaisexpedicion,
                   emptpaisexpedicion,empdepexpedicion,emptdepexpedicion,emppaislugnacimi,
                   emptpaislugnacimi,empdeplugnacimi,emptdeplugnacimi,emplugnacimi,emptlugnacimi,empfexpedicion, emplugexpedicion,
                   emptlugexpedicion,pernacion2,cciusol, csucursal, ctipsol , csector , ctipact ,
                   cciuofc , cdepofc , tmailrepl, tdirsrepl,
                   cciurrepl, tciurrepl, cdeprrepl, tdeprrepl, cpairrepl, tpairrepl,
                   ttelrepl , tcelurepl, cdeptoentrev, tdeptoentrev, cciuentrev, tciuentrev, fentrevista ,thoraentrev ,tagenentrev ,tasesentrev ,
                   tobseentrev ,crestentrev ,tobseconfir ,thoraconfir ,templconfir, corigenfon, cclausula1, cclausula2, cconfir, CUSER, FALTA, fconfirfor )   -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018 --IAXIS-3287 01/04/2019
           VALUES (pssarlaft, f_sysdate, psperson, pfdiligencia, pcauttradat, 1,
                   pcestconf, pfconfir, pcvinculacion, ptvinculacion, per_cdeptosol, per_tdeptosol, per_cciusol, per_tciusol,
                   pcvintomase, ptvintomase, pcvintomben,
                   ptvintombem, pcvinaseben, ptvinasebem, pcactippal, ppersectorppal, pnciiuppal, ptcciiuppal, ppertipoactivppal,
                   ptocupacion, ptcargo, ptempresa, ptdirempresa, ppercdeptoofic, ppertdeptoofic, ppercciuofic, ppertciuofic, pttelempresa, pcactisec,
                   pnciiusec, ptcciiusec, ptdirsec, pttelsec, ptprodservcom, piingresos, piactivos,
                   pipatrimonio, piegresos, pipasivos, piotroingreso, ptconcotring,
                   pcmanrecpub, pcpodpub, pcrecpub, pcvinperpub, ptvinperpub, pcdectribext,
                   ptdectribext, ptorigfond, pctraxmodext, pttraxmodext, pcprodfinext,
                   pcctamodext, ptotrasoper, pcreclindseg, ptciudadsuc, ptdepatamentosuc, ptpaisuc, ptciudad, ptdepatamento,
                   ptpais, ptlugarexpedidoc, presociedad, ptnacionali2, pngradopod, pngozrec,
                   pnparticipa, pnvinculo, pntipdoc, pfexpedicdoc, pfnacimiento, pnrazonso,
                   ptnit, ptdv, ptoficinapri, pttelefono, ptfax, ptsucursal, pttelefonosuc,
                   ptfaxsuc, pctipoemp, ptcualtemp, ptsector, pcciiu, ptactiaca, ptmailjurid,
                   ptrepresentanle, ptsegape, ptnombres, ptnumdoc, ptlugnaci, ptnacionali1,
                   ptindiquevin, pper_papellido, pper_sapellido, pper_nombres,
                   pper_tipdocument, pper_document, pper_fexpedicion, pper_lugexpedicion,
                   pper_fnacimi, pper_lugnacimi, pper_nacion1, pper_direreci, pper_pais,
                   pper_ciudad, pper_departament, pper_email, pper_telefono, pper_celular,
                   pnrecpub, ptpresetreclamaci, pper_tlugexpedicion, pper_tlugnacimi,
                   pper_tnacion1, pper_tnacion2, pper_tpais, pper_tdepartament, pper_tciudad,
                   pemptpais, pemptdepatamento, pemptciudad, pemptpaisuc,
                   pemptdepatamentosuc, pemptciudadsuc, pemptlugnaci, pemptnacionali1,
                   pemptnacionali2,pcsujetooblifacion, ptindiqueoblig,
                   pper_paisexpedicion,pper_tpaisexpedicion,pper_depexpedicion,
                   pper_tdepexpedicion,pper_paislugnacimi,pper_tpaislugnacimi,
                   pper_deplugnacimi,pper_tdeplugnacimi,pemp_paisexpedicion,
                   pemp_tpaisexpedicion,pemp_depexpedicion,pemp_tdepexpedicion,
                   pemp_paislugnacimi,pemp_tpaislugnacimi,pemp_deplugnacimi,
                   pemp_tdeplugnacimi,pemp_lugnacimi,pemp_tlugnacimi,pemp_fexpedicion, pemp_lugexpedicion,
                   pemp_tlugexpedicion,pper_nacion2,pper_pcciusol, pper_pcsucursal, pper_pctipsol , pper_pcsector , pper_pctipact,
                   pper_pcciuofc, pper_pcdepofc , pemp_tmailrepl, pemp_tdirsrepl,
                   pemp_cciurrepl, pemp_tciurrepl, pemp_cdeprrepl, pemp_tdeprrepl, pemp_cpairrepl, pemp_tpairrepl,
                   pemp_ttelrepl, pemp_tcelurepl, pcdeptoentrev, ptdeptoentrev, pcciuentrev, ptciuentrev, pfentrevista ,pthoraentrev ,
                   ptagenentrev ,ptasesentrev, ptobseentrev ,pcrestentrev ,ptobseconfir ,pthoraconfir ,ptemplconfir, pcorigenfon, pcclausula1, pcclausula2, pcconfir, f_user,f_sysdate,DECODE(pcconfir, 1, f_sysdate, NULL)); -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018 --IAXIS-3287 01/04/2019

               /* Cambios de  tarea IAXIS-13044 :start */
               BEGIN
                 SELECT PP.NNUMIDE
                   INTO VPERSON_NUM_ID
                   FROM PER_PERSONAS PP
                  WHERE PP.SPERSON = PSPERSON;
               
                 PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                                   0,
                                                   'S03512',
                                                   NULL);
                                                   
                 PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                                   1,
                                                   'S03502',
                                                   NULL);
               END;
               /* Cambios de  tarea IAXIS-13044 :end */   

      EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
      UPDATE datsarlatf
         SET fdiligencia = pfdiligencia,
             fradica=pfradica,
             cauttradat = pcauttradat,
             crutfcc = pcrutfcc,
             cestconf = pcestconf,
             fconfir = pfconfir,
             cvinculacion = pcvinculacion,
             tvinculacion = ptvinculacion,
             percdeptosol = per_cdeptosol,
             pertdeptosol = per_tdeptosol,
             percciusol = per_cciusol,
             pertciusol = per_tciusol,
             cvintomase = pcvintomase,
             tvintomase = ptvintomase,
             cvintomben = pcvintomben,
             tvintombem = ptvintombem,
             cvinaseben = pcvinaseben,
             tvinasebem = ptvinasebem,
             cactippal = pcactippal,
             persectorppal = ppersectorppal,
             nciiuppal = pnciiuppal,
             tcciiuppal = ptcciiuppal,
             pertipoactivppal = ppertipoactivppal,
             tocupacion = ptocupacion,
             tcargo = ptcargo,
             tempresa = ptempresa,
             tdirempresa = ptdirempresa,
             percdeptoofic = ppercdeptoofic,
             pertdeptoofic = ppertdeptoofic,
             percciuofic = ppercciuofic,
             pertciuofic = ppertciuofic,
             ttelempresa = pttelempresa,
             cactisec = pcactisec,
             nciiusec = pnciiusec,
             tcciiusec = ptcciiusec,
             tdirsec = ptdirsec,
             ttelsec = pttelsec,
             tprodservcom = ptprodservcom,
             iingresos = piingresos,
             iactivos = piactivos,
             ipatrimonio = pipatrimonio,
             iegresos = piegresos,
             ipasivos = pipasivos,
             iotroingreso = piotroingreso,
             tconcotring = ptconcotring,
             cmanrecpub = pcmanrecpub,
             cpodpub = pcpodpub,
             crecpub = pcrecpub,
             cvinperpub = pcvinperpub,
             tvinperpub = ptvinperpub,
             cdectribext = pcdectribext,
             tdectribext = ptdectribext,
             torigfond = ptorigfond,
             ctraxmodext = pctraxmodext,
             ttraxmodext = pttraxmodext,
             cprodfinext = pcprodfinext,
             cctamodext = pcctamodext,
             totrasoper = ptotrasoper,
             creclindseg = pcreclindseg,
             tciudadsuc = ptciudadsuc,
             tdepatamentosuc = ptdepatamentosuc,
             tpaisuc = ptpaisuc,
             tciudad = ptciudad,
             tdepatamento = ptdepatamento,
             tpais = ptpais,
             tlugarexpedidoc = ptlugarexpedidoc,
             resociedad = presociedad,
             tnacionali2 = ptnacionali2,
             ngradopod = pngradopod,
             ngozrec = pngozrec,
             nparticipa = pnparticipa,
             nvinculo = pnvinculo,
             ntipdoc = pntipdoc,
             fexpedicdoc = pfexpedicdoc,
             fnacimiento = pfnacimiento,
             nrazonso = pnrazonso,
             tnit = ptnit,
             tdv = ptdv,
             toficinapri = ptoficinapri,
             ttelefono = pttelefono,
             tfax = ptfax,
             tsucursal = ptsucursal,
             ttelefonosuc = pttelefonosuc,
             tfaxsuc = ptfaxsuc,
             ctipoemp = pctipoemp,
             tcualtemp = ptcualtemp,
             tsector = ptsector,
             cciiu = pcciiu,
             tactiaca = ptactiaca,
             tmailjurid = ptmailjurid,
             trepresentanle = ptrepresentanle,
             tsegape = ptsegape,
             tnombres = ptnombres,
             tnumdoc = ptnumdoc,
             tlugnaci = ptlugnaci,
             tnacionali1 = ptnacionali1,
             tindiquevin = ptindiquevin,
             perpapellido = pper_papellido,
             persapellido = pper_sapellido,
             pernombres = pper_nombres,
             pertipdocument = pper_tipdocument,
             perdocument = pper_document,
             perfexpedicion = pper_fexpedicion,
             perlugexpedicion = pper_lugexpedicion,
             perfnacimi = pper_fnacimi,
             perlugnacimi = pper_lugnacimi,
             pernacion1 = pper_nacion1,
             perdirereci = pper_direreci,
             perpais = pper_pais,
             perciudad = pper_ciudad,
             perdepartament = pper_departament,
             peremail = pper_email,
             pertelefono = pper_telefono,
             percelular = pper_celular,
             nrecpub = pnrecpub,
             tpresetreclamaci = ptpresetreclamaci,
             pertlugexpedicion = pper_tlugexpedicion,
             pertlugnacimi = pper_tlugnacimi,
             pertnacion1 = pper_tnacion1,
             pertnacion2 = pper_tnacion2,
             pertpais = pper_tpais,
             pertdepartament = pper_tdepartament,
             pertciudad = pper_tciudad,
             emptpais = pemptpais,
             emptdepatamento = pemptdepatamento,
             emptciudad = pemptciudad,
             emptpaisuc = pemptpaisuc,
             emptdepatamentosuc = pemptdepatamentosuc,
             emptciudadsuc = pemptciudadsuc,
             emptlugnaci = pemptlugnaci,
             emptnacionali1 = pemptnacionali1,
             emptnacionali2 = pemptnacionali2,
             csujetooblifacion=pcsujetooblifacion,
             tindiqueoblig = ptindiqueoblig,
             perpaisexpedicion=pper_paisexpedicion,
             pertpaisexpedicion=pper_tpaisexpedicion,
             perdepexpedicion=pper_depexpedicion,
             pertdepexpedicion=pper_tdepexpedicion,
             perpaislugnacimi=pper_paislugnacimi,
             pertpaislugnacimi=pper_tpaislugnacimi,
             perdeplugnacimi=pper_deplugnacimi,
             pertdeplugnacimi=pper_tdeplugnacimi,
             emppaisexpedicion=pemp_paisexpedicion,
             emptpaisexpedicion=pemp_tpaisexpedicion,
             empdepexpedicion=pemp_depexpedicion,
             emptdepexpedicion=pemp_tdepexpedicion,
             emppaislugnacimi=pemp_paislugnacimi,
             emptpaislugnacimi=pemp_tpaislugnacimi,
             empdeplugnacimi=pemp_deplugnacimi,
             emptdeplugnacimi=pemp_tdeplugnacimi,
             emplugnacimi=pemp_lugnacimi,
             emptlugnacimi=pemp_tlugnacimi,
             empfexpedicion=pemp_fexpedicion,
             emplugexpedicion=pemp_lugexpedicion,
             emptlugexpedicion=pemp_tlugexpedicion,
             pernacion2=pper_nacion2,
             cciusol      = pper_pcciusol    ,
             csucursal    = pper_pcsucursal  ,
             ctipsol      = pper_pctipsol    ,
             csector      = pper_pcsector    ,
             ctipact      = pper_pctipact    ,
             cciuofc      = pper_pcciuofc    ,
             cdepofc      = pper_pcdepofc    ,
             tmailrepl    = pemp_tmailrepl  ,
             tdirsrepl    = pemp_tdirsrepl  ,
             cciurrepl    = pemp_cciurrepl  ,
             tciurrepl    = pemp_tciurrepl  ,
             cdeprrepl    = pemp_cdeprrepl  ,
             tdeprrepl    = pemp_tdeprrepl  ,
             cpairrepl    = pemp_cpairrepl  ,
             tpairrepl    = pemp_tpairrepl  ,
             ttelrepl     = pemp_ttelrepl,
             tcelurepl    = pemp_tcelurepl,
             cdeptoentrev = pcdeptoentrev,
             tdeptoentrev = ptdeptoentrev,
             cciuentrev   = pcciuentrev,
             tciuentrev   = ptciuentrev,
             fentrevista  = pfentrevista,
             thoraentrev  = pthoraentrev,
             tagenentrev  = ptagenentrev,
             tasesentrev  = ptasesentrev,
             tobseentrev  = ptobseentrev,
             crestentrev  = pcrestentrev,
             tobseconfir  = ptobseconfir,
             thoraconfir  = pthoraconfir,
             templconfir  = ptemplconfir,
       corigenfon   = pcorigenfon,    -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018
             cclausula1   = pcclausula1, --TCS-9 AP 12/02/2019
             cclausula2   = pcclausula2, --TCS-9 AP 12/02/2019
       cconfir = pcconfir, --IAXIS-3287 01/04/2019
             fconfirfor   = DECODE(pcconfir, 1, f_sysdate, NULL),
             cuser        = f_user,
             falta        = f_sysdate
       WHERE 1 = 1
         AND sperson = psperson
         AND ssarlaft = pssarlaft;

         /* Cambios de  tarea IAXIS-13044 :start */
         BEGIN
           SELECT PP.NNUMIDE
             INTO VPERSON_NUM_ID
             FROM PER_PERSONAS PP
            WHERE PP.SPERSON = PSPERSON;
               
           PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                             1,
                                             'S03512',
                                             NULL);
                                                   
           PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                             1,
                                             'S03502',
                                             NULL);
         END;
         /* Cambios de  tarea IAXIS-13044 :end */   
               
        END;
         IF pcrutfcc = 4 THEN
           vnumerr := pac_marcas.f_set_marca_automatica(PAC_MD_COMMON.F_GET_CXTEMPRESA(), PSPERSON, '0052');
         ELSIF pcrutfcc IS NOT NULL THEN
           vnumerr := pac_marcas.f_del_marca_automatica(PAC_MD_COMMON.F_GET_CXTEMPRESA(), PSPERSON, '0052');
         END IF;

         /* INI CJMR TCS-344  19/02/2019
     IF pcestconf = 2 THEN
           vnumerr := pac_marcas.f_set_marca_automatica(PAC_MD_COMMON.F_GET_CXTEMPRESA(), PSPERSON, '0044');
         ELSIF pcestconf = 3 THEN
           vnumerr := pac_marcas.f_set_marca_automatica(PAC_MD_COMMON.F_GET_CXTEMPRESA(), PSPERSON, '0043');
         ELSIF pcestconf = 1 OR pcestconf = 4 THEN
           vnumerr := pac_marcas.f_del_marca_automatica(PAC_MD_COMMON.F_GET_CXTEMPRESA(), PSPERSON, '0044');
           vnumerr := pac_marcas.f_del_marca_automatica(PAC_MD_COMMON.F_GET_CXTEMPRESA(), PSPERSON, '0043');
         END IF;
     FIN CJMR TCS-344  19/02/2019  */
   --END IF;

         -- INI CJMR TCS-344  28/02/2019
         IF pcpodpub = 1 OR pnrecpub = 1 THEN
           vnumerr := pac_marcas.f_set_marca_automatica(pac_md_common.f_get_cxtempresa(), psperson, '0041');
         END IF;
         -- FIN CJMR TCS-344  28/02/2019

/* Cambios de IAXIS-3562 : start */
  /*
     IF v_seq IS NULL THEN --CP0615M_SYS_PERS AP 29/01/2019
      RETURN pssarlaft;
     ELSE
      RETURN v_seq; --CP0615M_SYS_PERS AP 29/01/2019
     END IF;
   */
      RETURN 0;
/* Cambios de IAXIS-3562 : Ends */   

EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN 1;
END f_set_datsarlatf;

FUNCTION f_del_datsarlatf(
   pssarlaft IN NUMBER,
   pfradica IN DATE,
   psperson IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN NUMBER IS
   i              NUMBER := 1;
   verr           ob_error;
BEGIN
   BEGIN
      IF pssarlaft IS NOT NULL THEN
         DELETE FROM datsarlatf
               WHERE 1 = 1
                 AND ssarlaft = pssarlaft;
      END IF;

      IF psperson IS NOT NULL AND pssarlaft IS NULL THEN
         DELETE FROM datsarlatf
               WHERE 1 = 1
                 AND sperson = psperson;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         verr := ob_error.instanciar(2292,
                                     f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         RETURN 2292;
   END;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      verr := ob_error.instanciar(2292,
                                  f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                  || '  ' || SQLERRM);
      RETURN 2292;
END f_del_datsarlatf;

FUNCTION f_del_detsarlatf_dec(
   pndeclara IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN NUMBER IS
   i              NUMBER := 1;
   verr           ob_error;
BEGIN
   BEGIN
      IF pndeclara IS NOT NULL THEN
         DELETE FROM detsarlatf_dec
               WHERE 1 = 1
                 AND ndeclara = pndeclara;
      END IF;

      IF psperson IS NOT NULL
         AND pssarlaft IS NOT NULL AND pndeclara IS NULL THEN
         DELETE FROM detsarlatf_dec
               WHERE 1 = 1
                 AND sperson = psperson
                 AND ssarlaft = pssarlaft;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         verr := ob_error.instanciar(2292,
                                     f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         RETURN 2292;
   END;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      verr := ob_error.instanciar(2292,
                                  f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                  || '  ' || SQLERRM);
      RETURN 2292;
END f_del_detsarlatf_dec;

FUNCTION f_get_detsarlatf_dec(
   pndeclara IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN sys_refcursor IS
   v_cursor       sys_refcursor;
   vpasexec       NUMBER;
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_detsarlatf_dec';
   vparam         VARCHAR2(500) := '';
BEGIN
   IF pndeclara IS NOT NULL THEN
      OPEN v_cursor FOR
         SELECT ndeclara, sperson, ssarlaft, ctipoid, cnumeroid, tnombre, cmanejarec,
                cejercepod, cgozarec, cdeclaraci, cdeclaracicual
           FROM detsarlatf_dec
          WHERE 1 = 1
            AND ndeclara = pndeclara
       ORDER BY ndeclara;
   END IF;

   IF psperson IS NOT NULL
      AND pssarlaft IS NOT NULL THEN
      OPEN v_cursor FOR
         SELECT ndeclara, sperson, ssarlaft, ctipoid, cnumeroid, tnombre, cmanejarec,
                cejercepod, cgozarec, cdeclaraci, cdeclaracicual
           FROM detsarlatf_dec
          WHERE 1 = 1
            AND sperson = psperson
            AND ssarlaft = pssarlaft
       ORDER BY ndeclara;
   END IF;

   RETURN v_cursor;
EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN NULL;
END f_get_detsarlatf_dec;

FUNCTION f_set_detsarlatf_dec(
   pndeclara IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   pctipoid IN NUMBER,
   pcnumeroid IN VARCHAR2,
   ptnombre IN VARCHAR2,
   pcmanejarec IN NUMBER,
   pcejercepod IN NUMBER,
   pcgozarec IN NUMBER,
   pcdeclaraci IN NUMBER,
   pcdeclaracicual IN VARCHAR2,
   mensajes OUT t_iax_mensajes)
   RETURN NUMBER IS
   vnumerr        NUMBER(8) := 0;
   vpasexec       NUMBER(8) := 1;
   vparam         VARCHAR2(500) := '';
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_set_detsarlatf_dec';
   cont           NUMBER;
BEGIN
   IF pndeclara IS NULL THEN
      INSERT INTO detsarlatf_dec
                  (ndeclara, sperson, ssarlaft, ctipoid, cnumeroid, tnombre,
                   cmanejarec, cejercepod, cgozarec, cdeclaraci, cdeclaracicual)
           VALUES ((select max(ndeclara)+1 from detsarlatf_dec), psperson, pssarlaft, pctipoid, pcnumeroid, ptnombre,
                   pcmanejarec, pcejercepod, pcgozarec, pcdeclaraci, pcdeclaracicual);
   ELSE
      UPDATE detsarlatf_dec
         SET ndeclara = pndeclara,
             sperson = psperson,
             ssarlaft = pssarlaft,
             ctipoid = pctipoid,
             cnumeroid = pcnumeroid,
             tnombre = ptnombre,
             cmanejarec = pcmanejarec,
             cejercepod = pcejercepod,
             cgozarec = pcgozarec,
             cdeclaraci = pcdeclaraci,
             cdeclaracicual = pcdeclaracicual
       WHERE 1 = 1
         AND sperson = psperson
         AND ssarlaft = pssarlaft;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN 1;
END f_set_detsarlatf_dec;

FUNCTION f_del_detsarlatf_act(
   pnactivi IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN NUMBER IS
   i              NUMBER := 1;
   verr           ob_error;
BEGIN
   BEGIN
      IF pnactivi IS NOT NULL THEN
         DELETE FROM detsarlatf_act
               WHERE 1 = 1
                 AND nactivi = pnactivi;
      END IF;

      IF psperson IS NOT NULL
         AND pssarlaft IS NOT NULL AND pnactivi IS NULL THEN
         DELETE FROM detsarlatf_act
               WHERE 1 = 1
                 AND sperson = psperson
                 AND ssarlaft = pssarlaft;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         verr := ob_error.instanciar(2292,
                                     f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         RETURN 2292;
   END;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      verr := ob_error.instanciar(2292,
                                  f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                  || '  ' || SQLERRM);
      RETURN 2292;
END f_del_detsarlatf_act;

FUNCTION f_get_detsarlatf_act(
   pnactivi IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN sys_refcursor IS
   v_cursor       sys_refcursor;
   vpasexec       NUMBER;
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_detsarlatf_act';
   vparam         VARCHAR2(500) := '';
BEGIN
   IF pnactivi IS NOT NULL THEN
      OPEN v_cursor FOR
         SELECT nactivi, sperson, ssarlaft, ctipoprod, cidnumprod, tentidad, cmonto, cciudad,
                cpais, cmoneda, scpais, stdepb, scciudad, tdepb
           FROM detsarlatf_act
          WHERE 1 = 1
            AND nactivi = pnactivi
       ORDER BY nactivi;
   END IF;

   IF psperson IS NOT NULL
      AND pssarlaft IS NOT NULL THEN
      OPEN v_cursor FOR
         SELECT nactivi, sperson, ssarlaft, ctipoprod, cidnumprod, tentidad, cmonto, cciudad,
                cpais, cmoneda, scpais, stdepb, scciudad, tdepb
           FROM detsarlatf_act
          WHERE 1 = 1
            AND sperson = psperson
            AND ssarlaft = pssarlaft
       ORDER BY nactivi;
   END IF;

   RETURN v_cursor;
EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN NULL;
END f_get_detsarlatf_act;

FUNCTION f_set_detsarlatf_act(
   pnactivi IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   pctipoprod IN VARCHAR2,
   pcidnumprod IN VARCHAR2,
   ptentidad IN VARCHAR2,
   pcmonto IN VARCHAR2,
   pcciudad IN NUMBER,
   pcpais IN NUMBER,
   pcmoneda IN VARCHAR2,
   pscpais IN VARCHAR2,
   pstdepb IN VARCHAR2,
   ptdepb IN NUMBER,
   pscciudad IN VARCHAR2,
   mensajes OUT t_iax_mensajes)
   RETURN NUMBER IS
   vnumerr        NUMBER(8) := 0;
   vpasexec       NUMBER(8) := 1;
   vparam         VARCHAR2(500) := '';
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_set_detsarlatf_act';
   cont           NUMBER;
BEGIN
   IF pnactivi IS NULL THEN
      INSERT INTO detsarlatf_act
                  (nactivi, sperson, ssarlaft, ctipoprod, cidnumprod, tentidad,
                   cmonto, cciudad, cpais, cmoneda, scpais, stdepb, tdepb, scciudad)
           VALUES ((select max(nactivi)+1 from detsarlatf_act), psperson, pssarlaft, pctipoprod, pcidnumprod, ptentidad,
                   pcmonto, pcciudad, pcpais, pcmoneda, pscpais, pstdepb, ptdepb, pscciudad);
   ELSE
      UPDATE detsarlatf_act
         SET ctipoprod = pctipoprod,
             cidnumprod = pcidnumprod,
             tentidad = ptentidad,
             cmonto = pcmonto,
             cciudad = pcciudad,
             cpais = pcpais,
             cmoneda = pcmoneda,
             scpais = pscpais,
             stdepb = pstdepb,
             tdepb = ptdepb,
             scciudad = pscciudad
       WHERE 1 = 1
         AND sperson = psperson
         AND ssarlaft = pssarlaft
         AND nactivi = pnactivi;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN 1;
END f_set_detsarlatf_act;

FUNCTION f_del_detsarlaft_rec(
   pnrecla IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN NUMBER IS
   i              NUMBER := 1;
   verr           ob_error;
BEGIN
   BEGIN
      IF pnrecla IS NOT NULL THEN
         DELETE FROM detsarlaft_rec
               WHERE 1 = 1
                 AND nrecla = pnrecla;
      END IF;

      IF psperson IS NOT NULL
         AND pssarlaft IS NOT NULL AND pnrecla IS NULL THEN
         DELETE FROM detsarlaft_rec
               WHERE 1 = 1
                 AND sperson = psperson
                 AND ssarlaft = pssarlaft;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         verr := ob_error.instanciar(2292,
                                     f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         RETURN 2292;
   END;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      verr := ob_error.instanciar(2292,
                                  f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                  || '  ' || SQLERRM);
      RETURN 2292;
END f_del_detsarlaft_rec;

FUNCTION f_get_detsarlaft_rec(
   pnrecla IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN sys_refcursor IS
   v_cursor       sys_refcursor;
   vpasexec       NUMBER;
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_detsarlaft_rec';
   vparam         VARCHAR2(500) := '';
BEGIN
   IF pnrecla IS NOT NULL THEN
      OPEN v_cursor FOR
         SELECT nrecla, sperson, ssarlaft, canio, cramo, tcompania, cvalor, tresultado
           FROM detsarlaft_rec
          WHERE 1 = 1
            AND nrecla = pnrecla
       ORDER BY nrecla;
   END IF;

   IF psperson IS NOT NULL
      AND pssarlaft IS NOT NULL THEN
      OPEN v_cursor FOR
         SELECT nrecla, sperson, ssarlaft, canio, cramo, tcompania, cvalor, tresultado
           FROM detsarlaft_rec
          WHERE 1 = 1
            AND sperson = psperson
            AND ssarlaft = pssarlaft
       ORDER BY nrecla;
   END IF;

   RETURN v_cursor;
EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN NULL;
END f_get_detsarlaft_rec;

FUNCTION f_set_detsarlaft_rec(
   pnrecla IN NUMBER,
   psperson IN NUMBER,
   pssarlaft IN NUMBER,
   pcanio IN NUMBER,
   pcramo IN VARCHAR2,
   ptcompania IN VARCHAR2,
   pcvalor IN VARCHAR2,
   ptresultado IN VARCHAR2,
   mensajes OUT t_iax_mensajes)
   RETURN NUMBER IS
   vnumerr        NUMBER(8) := 0;
   vpasexec       NUMBER(8) := 1;
   vparam         VARCHAR2(500) := '';
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_set_detsarlaft_rec';
   cont           NUMBER;
BEGIN
   IF pnrecla IS NULL THEN
      INSERT INTO detsarlaft_rec
                  (nrecla, sperson, ssarlaft, canio, cramo, tcompania, cvalor,
                   tresultado)
           VALUES ((select max(nrecla)+1 from detsarlaft_rec), psperson, pssarlaft, pcanio, pcramo, ptcompania, pcvalor,
                   ptresultado);
   ELSE
      UPDATE detsarlaft_rec
         SET canio = pcanio,
             cramo = pcramo,
             tcompania = ptcompania,
             cvalor = pcvalor,
             tresultado = ptresultado
       WHERE 1 = 1
         AND sperson = psperson
         AND ssarlaft = pssarlaft
         AND nrecla = pnrecla;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN 1;
END f_set_detsarlaft_rec;
/*************************************************************************
     FUNCTION f_get_tipiva
     Funcion que dado una PERSONA y una fecha retorna el % tipo de iva a la fecha
     que cobrara las comisiones.
     param in psperson   : Codigo sperson
     param in pfecha     : Fecha en activo
     return              : % Tipo de iva a aplicar
     Autor               : JVG 24/10/2017
    *************************************************************************/
   FUNCTION f_get_tipiva(psperson IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      pptipiva       NUMBER;
   BEGIN
      SELECT ptipiva
        INTO pptipiva
        FROM tipoiva t, per_regimenfiscal p
       WHERE p.sperson = psperson
         AND t.ctipiva = p.ctipiva
         AND p.fefecto = (select max(fefecto) from per_regimenfiscal where sperson = psperson)
         AND TRUNC(pfecha) >= TRUNC(t.finivig)
         AND TRUNC(pfecha) < TRUNC(NVL(t.ffinvig, pfecha + 1));

      RETURN pptipiva;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_get_tipiva', 1,
                     'psperson = ' || psperson || '; pfecha = '
                     || TO_CHAR(pfecha, 'dd/mm/yyyy'),
                     SQLERRM);
         RETURN NULL;
   END f_get_tipiva;


    FUNCTION f_set_cpep_sarlatf(
      PSSARLAFT   IN  NUMBER ,
      PIDENTIFICACION IN  NUMBER,
      PCTIPREL    IN  NUMBER,
      PTNOMBRE    IN   VARCHAR2,
      PCTIPIDEN   IN NUMBER ,
      PNNUMIDE    IN   VARCHAR2,
      PCPAIS      IN     NUMBER,
      PTPAIS      IN VARCHAR2,
      PTENTIDAD   IN VARCHAR2,
      PTCARGO     IN   VARCHAR2,
      PFDESVIN    IN   DATE
    ) RETURN NUMBER IS

      vcount    NUMBER := 1;
      videntif  NUMBER;
   BEGIN
      IF PIDENTIFICACION IS NULL THEN
         SELECT NVL(MAX(IDENTIFICACION),0)+1
           INTO videntif
           FROM SARLATFPEP
          WHERE SSARLAFT = PSSARLAFT;
         vcount := 0;
      END IF;

      IF vcount >= 1 THEN

         UPDATE SARLATFPEP
            SET
                CTIPREL  =  PCTIPREL,
                TNOMBRE  =  PTNOMBRE,
                CTIPIDEN =  PCTIPIDEN,
                NNUMIDE  =  PNNUMIDE,
                CPAIS    =  PCPAIS,
                TPAIS    =  PTPAIS,
                TENTIDAD =  PTENTIDAD,
                TCARGO   =  PTCARGO ,
                FDESVIN  =  PFDESVIN,
                FREGISTRO  = f_sysdate,
                CUSER      = f_user
          WHERE IDENTIFICACION =  PIDENTIFICACION
            AND SSARLAFT = PSSARLAFT;

      ELSE
        INSERT INTO SARLATFPEP
              (SSARLAFT,  IDENTIFICACION,  CTIPREL,  TNOMBRE,  CTIPIDEN,  NNUMIDE,  CPAIS,  TPAIS,  TENTIDAD,  TCARGO,  FDESVIN,  FREGISTRO, CUSER)
        VALUES(PSSARLAFT, videntif,        PCTIPREL, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PCPAIS, PTPAIS, PTENTIDAD, PTCARGO, PFDESVIN, f_sysdate, f_user);

      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
         RETURN 1;
   END f_set_cpep_sarlatf;

    FUNCTION f_get_cpep_sarlatf(
       PSSARLAFT   IN  NUMBER
    ) RETURN sys_refcursor IS

    v_cursor       sys_refcursor;
    BEGIN

       OPEN v_cursor FOR
          SELECT s.SSARLAFT,
                 s.IDENTIFICACION,
                 s.CTIPREL,
                 (ff_desvalorfijo(DECODE(p.ctipper,1,790000,8002025), pac_md_common.f_get_cxtidioma, s.CTIPREL)) TTIPREL,
                 s.TNOMBRE,
                 s.CTIPIDEN,
                 (ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma, s.CTIPIDEN)) TTIPIDEN,
                 s.NNUMIDE,
                 s.CPAIS,
                 s.TPAIS,
                 s.TENTIDAD,
                 s.TCARGO,
                 TO_CHAR(s.FDESVIN, 'dd/mm/yyyy') FDESVIN
            FROM SARLATFPEP s, datsarlatf d, per_personas p
           WHERE 1 = 1
             AND s.ssarlaft = pssarlaft
             AND s.ssarlaft = d.ssarlaft
             AND d.sperson = p.sperson;

    RETURN v_cursor;
    EXCEPTION
       WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                      ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
          RETURN NULL;
    END f_get_cpep_sarlatf;

    FUNCTION f_del_cpep_sarlatf(
      PSSARLAFT      IN  NUMBER ,
      PIDENTIFICACION IN NUMBER
    ) RETURN NUMBER IS

   v_cursor       sys_refcursor;
   BEGIN
       IF PSSARLAFT IS NOT NULL
       AND PIDENTIFICACION IS NOT NULL THEN
          DELETE FROM SARLATFPEP
                WHERE IDENTIFICACION = PIDENTIFICACION
                  AND SSARLAFT = PSSARLAFT;
       END IF;

   RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
         RETURN NULL;
   END f_del_cpep_sarlatf;

    FUNCTION f_set_caccionista_sarlatf  (
      PSSARLAFT   IN  NUMBER ,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI   IN  NUMBER,
      PTNOMBRE    IN   VARCHAR2,
      PCTIPIDEN   IN NUMBER ,
      PNNUMIDE    IN   VARCHAR2 ,
      PCBOLSA     IN  NUMBER,
      PCPEP       IN NUMBER,
      PCTRIBUEXT  IN     NUMBER
    ) RETURN NUMBER IS

      vcount    NUMBER := 1;
      videntif  NUMBER;
   BEGIN
      IF PIDENTIFICACION IS NULL THEN
         SELECT NVL(MAX(IDENTIFICACION),0)+1
           INTO videntif
           FROM SARLATFACC
          WHERE SSARLAFT = PSSARLAFT;
         vcount := 0;
      END IF;

      IF vcount >= 1 THEN

         UPDATE SARLATFACC
            SET
                PPARTICI =PPPARTICI ,
                TNOMBRE = PTNOMBRE,
                CTIPIDEN= PCTIPIDEN,
                NNUMIDE = PNNUMIDE,
                CBOLSA   =PCBOLSA,
                CPEP    = PCPEP,
                CTRIBUEXT=PCTRIBUEXT,
                FREGISTRO  = f_sysdate,
                CUSER      = f_user
          WHERE IDENTIFICACION =  PIDENTIFICACION
            AND SSARLAFT = PSSARLAFT;


      ELSE
        INSERT INTO SARLATFACC
                   (SSARLAFT,  IDENTIFICACION,  PPARTICI,  TNOMBRE,  CTIPIDEN,  NNUMIDE,  CBOLSA,  CPEP,  CTRIBUEXT,  FREGISTRO, CUSER)
             VALUES(PSSARLAFT, videntif,        PPPARTICI, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PCBOLSA, PCPEP, PCTRIBUEXT, f_sysdate, f_user);

      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
         RETURN 1;
   END f_set_caccionista_sarlatf;

    FUNCTION f_get_caccionista_sarlatf   (
       PSSARLAFT   IN  NUMBER
    )  RETURN sys_refcursor IS

    v_cursor       sys_refcursor;
    BEGIN

       OPEN v_cursor FOR
          SELECT SSARLAFT, IDENTIFICACION,  PPARTICI  ,  TNOMBRE   ,  CTIPIDEN, (ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma, CTIPIDEN) )  TTIPIDEN   ,  NNUMIDE  ,  CBOLSA    ,  CPEP      ,  CTRIBUEXT ,   FREGISTRO
            FROM SARLATFACC
           WHERE 1 = 1
             AND ssarlaft = pssarlaft;

    RETURN v_cursor;
    EXCEPTION
       WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                      ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
          RETURN NULL;
    END f_get_caccionista_sarlatf;

    FUNCTION f_del_caccionista_sarlatf   (
      PSSARLAFT      IN  NUMBER ,
      PIDENTIFICACION IN NUMBER
      )  RETURN NUMBER IS





   v_cursor       sys_refcursor;
   BEGIN
       IF PSSARLAFT IS NOT NULL
       AND PIDENTIFICACION IS NOT NULL THEN
          DELETE FROM SARLATFACC
                WHERE IDENTIFICACION = PIDENTIFICACION
                  AND SSARLAFT = PSSARLAFT;
       END IF;

   RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
         RETURN NULL;
   END f_del_caccionista_sarlatf;

   FUNCTION f_set_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI       IN  NUMBER,
      PTNOMBRE        IN  VARCHAR2,
      PCTIPIDEN       IN  NUMBER,
      PNNUMIDE        IN  VARCHAR2,
      PTSOCIEDAD      IN  VARCHAR2,
      PNNUMIDESOC     IN  VARCHAR2
      )  RETURN NUMBER IS

      vcount    NUMBER := 1;
      videntif  NUMBER;
   BEGIN
      IF PIDENTIFICACION IS NULL THEN
         SELECT NVL(MAX(IDENTIFICACION),0)+1
           INTO videntif
           FROM SARLATFBEN
          WHERE SSARLAFT = PSSARLAFT;
         vcount := 0;
      END IF;

      IF vcount >= 1 THEN
         UPDATE SARLATFBEN
            SET PPARTICI   = PPPARTICI,
                TNOMBRE    = PTNOMBRE,
                CTIPIDEN   = PCTIPIDEN,
                NNUMIDE    = PNNUMIDE,
                TSOCIEDAD  = PTSOCIEDAD,
                NNUMIDESOC = PNNUMIDESOC,
                FREGISTRO  = f_sysdate,
                CUSER      = f_user
          WHERE IDENTIFICACION =  PIDENTIFICACION
            AND SSARLAFT = PSSARLAFT;
      ELSE
         INSERT INTO SARLATFBEN
                    (SSARLAFT,  IDENTIFICACION , PPARTICI,  TNOMBRE,  CTIPIDEN,  NNUMIDE,  TSOCIEDAD ,  NNUMIDESOC,  FREGISTRO, CUSER)
              VALUES(PSSARLAFT, videntif, PPPARTICI, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PTSOCIEDAD , PNNUMIDESOC, f_sysdate, f_user);

      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
         RETURN 1;
   END f_set_accionista_sarlatf;

    FUNCTION f_get_accionista_sarlatf (
      PSSARLAFT   IN  NUMBER
    ) RETURN sys_refcursor IS

   v_cursor       sys_refcursor;
   BEGIN

      OPEN v_cursor FOR
         SELECT SSARLAFT, IDENTIFICACION,  PPARTICI  ,  TNOMBRE  ,  CTIPIDEN   ,  NNUMIDE  ,  TSOCIEDAD ,  NNUMIDESOC,  FREGISTRO
           FROM SARLATFBEN
          WHERE 1 = 1
            AND ssarlaft = pssarlaft;

   RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
         RETURN NULL;
   END f_get_accionista_sarlatf;


    FUNCTION f_del_accionista_sarlatf (
      PSSARLAFT      IN  NUMBER ,
      PIDENTIFICACION IN NUMBER
      ) RETURN NUMBER IS

   v_cursor       sys_refcursor;
   BEGIN
       IF PSSARLAFT IS NOT NULL
       AND PIDENTIFICACION IS NOT NULL THEN
          DELETE FROM SARLATFBEN
                WHERE IDENTIFICACION = PIDENTIFICACION
                  AND SSARLAFT = PSSARLAFT;
       END IF;

   RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1,
                     ' Error .  PSSARLAFT= ' || PSSARLAFT, SQLERRM);
         RETURN 2292;
   END f_del_accionista_sarlatf;

   FUNCTION f_get_ultimosestados_sarlatf   (

      PSPERSON   IN  NUMBER

      )  RETURN sys_refcursor IS
   v_cursor       sys_refcursor;
   v_maximo       NUMBER;
   BEGIN
      SELECT NVL(MAX(T.version), 0)
    INTO v_maximo
    FROM SARLATFEST T
    WHERE T.SPERSON = PSPERSON
    AND T.SSARLAFT = (SELECT MAX(D.SSARLAFT) FROM DATSARLATF D WHERE D.SPERSON = T.SPERSON);

      OPEN v_cursor FOR
         SELECT SSARLAFT, VERSION,  ff_desvalorfijo (790003, pac_md_common.f_get_cxtidioma, ESTACT) as estado  ,  CUSER, FALTA
           FROM SARLATFEST S
          WHERE S.SPERSON = PSPERSON
            AND VERSION <= v_maximo
            AND VERSION > v_maximo-3
            AND S.SSARLAFT = (SELECT MAX(SSARLAFT) FROM DATSARLATF F WHERE F.SPERSON = S.SPERSON)
       ORDER BY version desc;

   RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA.f_get_ultimosestados_sarlatf', 1,
                     ' Error .  PSSARLAFT= ' || PSPERSON, SQLERRM);
         RETURN NULL;
   END f_get_ultimosestados_sarlatf;

   FUNCTION f_get_persona_sarlaf(
   psperson IN NUMBER,
   mensajes IN OUT t_iax_mensajes)
   RETURN sys_refcursor IS
   v_cursor       sys_refcursor;
   vpasexec       NUMBER;
   vobject        VARCHAR2(200) := 'PAC_PERSONA.f_get_persona_sarlaf';
   vparam         VARCHAR2(500) := '';
   vctipper       NUMBER;
   vmaxssarlaft NUMBER;
   vmaxseq NUMBER;
BEGIN
   IF psperson IS NOT NULL THEN
     SELECT p.ctipper
     INTO vctipper
     FROM per_personas p
     WHERE p.sperson = psperson;
     
   BEGIN

      SELECT MAX(ssarlaft) INTO vmaxssarlaft FROM datsarlatf ;

      SELECT SSARLAFT.nextval INTO vmaxseq FROM dual;

      FOR i IN vmaxseq .. vmaxssarlaft LOOP
        IF vmaxseq <= vmaxssarlaft THEN
          SELECT SSARLAFT.nextval INTO vmaxseq FROM dual;
        END IF;  
      END LOOP;

     END;
   

     IF vctipper = 1 THEN
      OPEN v_cursor FOR
SELECT vmaxseq as PER_SSARLAFT,d.tapelli1 as PER_PAPELLIDO, d.tapelli2 as PER_SAPELLIDO, d.tnombre as PER_NOMBRES, per.ctipide as PER_TIPDOCUMENT, per.nnumide as PER_DOCUMENT, TO_CHAR (p.fechadexp, 'DD/MM/YYYY') as PER_FEXPEDICION,
   p.cpaisexp as PER_PAISEXPEDICION,
   (select pa.tpais from paises pa where pa.cpais = (SELECT id.cpaisexp
                   FROM per_identificador id
                  WHERE id.sperson = psperson)) as PER_TPAISEXPEDICION,
   p.cdepartexp as PER_DEPEXPEDICION,
   (select pr.tprovin from provincias pr where pr.cprovin = (SELECT id.cdepartexp
                   FROM per_identificador id
                  WHERE id.sperson = psperson)) as PER_TDEPEXPEDICION,
   p.cciudadexp as PER_LUGEXPEDICION,
    (select po.tpoblac from poblaciones po where po.cpoblac = (SELECT id.cciudadexp
                   FROM per_identificador id
                  WHERE id.sperson = psperson)
                  and po.cprovin = (SELECT id.cdepartexp
                   FROM per_identificador id
                  WHERE id.sperson = psperson)) as PER_TLUGEXPEDICION,
   TO_CHAR(per.fnacimi, 'DD/MM/YYYY') as PER_FNACIMI,
                 (SELECT n.cpais
                   FROM per_nacionalidades n
                  WHERE n.sperson = psperson
                    AND n.cagente = (select det.cagente from per_detper det
                                where det.sperson = psperson)
                    and n.cdefecto = 1) AS PER_NACION1,
                    (select pa.tpais from paises pa where pa.cpais = (SELECT n.cpais
                   FROM per_nacionalidades n
                  WHERE n.sperson = psperson
                    and n.cdefecto = 1)) as PER_TNACION1,
            (SELECT * FROM (SELECT dir.tdomici FROM per_direcciones dir
                                where dir.sperson = psperson
                                and dir.ctipdir = 9
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1) as PER_DIRERECI,
            (select pr.cpais
                   FROM provincias pr
                  WHERE pr.cprovin = (SELECT * FROM (SELECT dir.cprovin FROM per_direcciones dir
                                where dir.sperson = psperson
                                and dir.ctipdir = 9
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1))as PER_PAIS,
           (select pa.tpais from paises pa where pa.cpais = (SELECT pr.cpais
                   FROM provincias pr
                  WHERE pr.cprovin = (SELECT * FROM (SELECT dir.cprovin FROM per_direcciones dir
                                where dir.sperson = psperson
                                and dir.ctipdir = 9
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1)))as PER_TPAIS,
             (SELECT * FROM  (SELECT dir.cprovin FROM per_direcciones dir
                                where dir.sperson = psperson
                                and dir.ctipdir = 9
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1) as PER_DEPARTAMENT,
            (select pr.tprovin from provincias pr where pr.cprovin = (select * from (SELECT dir.cprovin FROM per_direcciones dir
                                where dir.sperson = psperson
                                and dir.ctipdir = 9
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1))as PER_TDEPARTAMENT,
            (select * from (SELECT dir.cpoblac FROM per_direcciones dir
                                where dir.sperson = psperson
                                and dir.ctipdir = 9
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1) as PER_CIUDAD,
            (select po.tpoblac from poblaciones po where po.cprovin = (SELECT * FROM (SELECT dir.cprovin FROM per_direcciones dir
                                where dir.sperson = psperson
                                and dir.ctipdir = 9
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1)
                                and po.cpoblac = (SELECT * FROM (SELECT dir.cpoblac FROM per_direcciones dir
                                where dir.sperson = psperson
                                and dir.ctipdir = 9
                                ORDER BY dir.cdomici asc) WHERE ROWNUM = 1)) as PER_TCIUDAD,
            (SELECT * FROM (select co.tvalcon from per_contactos co where co.sperson = psperson
             and co.ctipcon = 3
             ORDER BY co.cmodcon asc) WHERE ROWNUM = 1) as PER_EMAIL,
             (SELECT * FROM (select co.tvalcon from per_contactos co where co.sperson = psperson
             and co.ctipcon = 1
             ORDER BY co.cmodcon asc) WHERE ROWNUM = 1) as PER_TELEFONO,
              (SELECT * FROM (select co.tvalcon from per_contactos co where co.sperson = psperson
             and co.ctipcon = 6
             ORDER BY co.cmodcon asc) WHERE ROWNUM = 1) as PER_CELULAR,
             (SELECT f.CCIIU FROM per_ciiu pc INNER JOIN fin_general f
                 ON pc.cciiu = f.cciiu
                WHERE pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() AND f.sperson = psperson) as NCIIUPPAL,
            (SELECT pc.TCIIU FROM per_ciiu pc INNER JOIN fin_general f
                ON pc.cciiu = f.cciiu
               WHERE pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() AND  f.sperson = psperson) as TCCIIUPPAL,
               FF_DESCPROFES(d.cocupacion,PAC_MD_COMMON.F_Get_CXTIDIOMA(),PAC_MD_COMMON.F_GET_CXTEMPRESA()) as TOCUPACION
           FROM per_personas per, per_detper d, per_ccc c, per_identificador p
          WHERE per.sperson =  psperson
           AND d.sperson = per.sperson
           AND c.sperson(+) = d.sperson
           AND per.sperson = p.sperson
           AND per.swpubli in (0,1);
          -- AND per.cagente = d.cagente;
    END IF;
     IF vctipper = 2 THEN
      OPEN v_cursor FOR
       SELECT vmaxseq as PER_SSARLAFT,
              d.tapelli1 AS NRAZONSO,
              per.nnumide AS TNIT,
              pdp.tapelli1 AS TREPRESENTANLE,
              pdp.tapelli2 AS TSEGAPE,
              pdp.tnombre AS TNOMBRES,
              pp.ctipide AS NTIPDOC,
              pp.nnumide AS TNUMDOC,
              TO_CHAR(pi.fechadexp,'DD/MM/YYYY') AS RL_FEXPEDICION,
              pi.cpaisexp AS RL_PAISEXPEDICION,
              (SELECT p.tpais FROM paises p WHERE p.cpais = pi.cpaisexp) AS RL_TPAISEXPEDICION,
              pi.cdepartexp AS RL_DEPEXPEDICION,
              (SELECT p.tprovin FROM provinciAS p WHERE p.cprovin = pi.cdepartexp) AS RL_TDEPEXPEDICION,
              (pi.cciudadexp) AS RL_LUGEXPEDICION,
              (SELECT p.tpoblac
                 FROM poblaciones p
                WHERE p.cprovin = pi.cdepartexp
                  AND p.cpoblac = pi.cciudadexp) AS RL_TLUGEXPEDICION,
              TO_CHAR(pp.fnacimi,'DD/MM/YYYY') AS RL_FNACIMIENTO,
              (SELECT cpais
                 FROM per_nacionalidades
                WHERE sperson = pp.sperson
                  AND cdefecto = 1) AS RL_NACION1,
              (SELECT p.tpais
                 FROM paises p
                WHERE p.cpais = (SELECT cpais
                                   FROM per_nacionalidades
                                  WHERE sperson = pp.sperson
                                    AND cdefecto = 1)) AS RL_TNACION1,
              (SELECT cpais
                 FROM per_nacionalidades
                WHERE sperson = pp.sperson
                  AND cdefecto = 0
                  AND norden = 2) AS RL_NACION2,
              (SELECT p.tpais
                 FROM paises p
                WHERE p.cpais = (SELECT cpais
                                   FROM per_nacionalidades
                                  WHERE sperson = pp.sperson
                                    AND cdefecto = 0
                                    AND norden = 2)) AS RL_TNACION2,
              (SELECT cpais
                 FROM provinciAS a
                WHERE a.cprovin = (SELECT p.cprovin
                                     FROM per_direcciones p
                                    WHERE p.sperson = pp.sperson
                                      AND p.cdomici = 1)) AS RL_PAIS,
              (SELECT tpais
                 FROM paises
                WHERE cpais =
                      (SELECT cpais
                         FROM provincias a
                        WHERE a.cprovin = (SELECT p.cprovin
                                             FROM per_direcciones p
                                            WHERE p.sperson = pp.sperson
                                              AND p.cdomici = 1))) AS RL_TPAIS,
              (SELECT p.cprovin
                 FROM per_direcciones p
                WHERE p.sperson = pp.sperson
                  AND p.cdomici = 1) AS RL_DEPARTAMENT,

              (SELECT tprovin
                 FROM provinciAS
                WHERE cprovin = (SELECT p.cprovin
                                   FROM per_direcciones p
                                  WHERE p.sperson = pp.sperson
                                    AND p.cdomici = 1)) AS RL_TDEPARTAMENT,
              (SELECT p.cpoblac
                 FROM per_direcciones p
                WHERE p.sperson = pp.sperson
                  AND p.cdomici = 1) AS RL_CIUDAD,
              (SELECT p.tpoblac
                 FROM poblaciones p
                WHERE p.cprovin = (SELECT p.cprovin
                                     FROM per_direcciones p
                                    WHERE p.sperson = pp.sperson
                                      AND p.cdomici = 1)
                  AND p.cpoblac = (SELECT p.cpoblac
                                     FROM per_direcciones p
                                    WHERE p.sperson = pp.sperson
                                      AND p.cdomici = 1)) AS RL_TCIUDAD,
              (SELECT dir.tdomici
                 FROM per_direcciones dir
                WHERE dir.sperson = pp.sperson
                  AND dir.cdomici = 1) AS RL_DIRERECI,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = pp.sperson
                          AND co.ctipcon = 3
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS RL_EMAIL,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = pp.sperson
                          AND co.ctipcon = 1
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS RL_TELEFONO,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = pp.sperson
                          AND co.ctipcon = 6
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS RL_CELULAR,
              (SELECT *
                 FROM (SELECT dir.tdomici
                         FROM per_direcciones dir
                        WHERE dir.sperson = psperson
                        ORDER BY dir.cdomici ASC)
                WHERE ROWNUM = 1) AS TOFICINAPRI,
              (SELECT pr.cpais
                 FROM provinciAS pr
                WHERE pr.cprovin = (SELECT *
                                      FROM (SELECT dir.cprovin
                                              FROM per_direcciones dir
                                             WHERE dir.sperson = psperson
                                             ORDER BY dir.cdomici ASC)
                                     WHERE ROWNUM = 1)) AS TPAIS,
              (SELECT pa.tpais
                 FROM paises pa
                WHERE pa.cpais =
                      (SELECT pr.cpais
                         FROM provinciAS pr
                        WHERE pr.cprovin = (SELECT *
                                              FROM (SELECT dir.cprovin
                                                      FROM per_direcciones dir
                                                     WHERE dir.sperson = psperson
                                                     ORDER BY dir.cdomici ASC)
                                             WHERE ROWNUM = 1))) AS EMPTPAIS,
              (SELECT *
                 FROM (SELECT dir.cprovin
                         FROM per_direcciones dir
                        WHERE dir.sperson = psperson
                        ORDER BY dir.cdomici ASC)
                WHERE ROWNUM = 1) AS TDEPATAMENTO,
              (SELECT pr.tprovin
                 FROM provinciAS pr
                WHERE pr.cprovin = (SELECT *
                                      FROM (SELECT dir.cprovin
                                              FROM per_direcciones dir
                                             WHERE dir.sperson = psperson
                                             ORDER BY dir.cdomici ASC)
                                     WHERE ROWNUM = 1)) AS EMPTDEPATAMENTO,
              (SELECT *
                 FROM (SELECT dir.cpoblac
                         FROM per_direcciones dir
                        WHERE dir.sperson = psperson
                        ORDER BY dir.cdomici ASC)
                WHERE ROWNUM = 1) AS TCIUDAD,
              (SELECT po.tpoblac
                 FROM poblaciones po
                WHERE po.cprovin = (SELECT *
                                      FROM (SELECT dir.cprovin
                                              FROM per_direcciones dir
                                             WHERE dir.sperson = psperson
                                             ORDER BY dir.cdomici ASC)
                                     WHERE ROWNUM = 1)
                  AND po.cpoblac = (SELECT *
                                      FROM (SELECT dir.cpoblac
                                              FROM per_direcciones dir
                                             WHERE dir.sperson = psperson
                                             ORDER BY dir.cdomici ASC)
                                     WHERE ROWNUM = 1)) AS EMPTCIUDAD,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = psperson
                          AND co.ctipcon = 1
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS TTELEFONO,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = psperson
                          AND co.ctipcon = 2
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS TFAX,
                (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = psperson
                          AND co.ctipcon = 3
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) TMAILJURID,
              (SELECT f.CCIIU
                 FROM per_ciiu pc
                INNER JOIN fin_general f
                   ON pc.cciiu = f.cciiu
                WHERE pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA()
                  AND f.sperson = psperson) AS CCIIU,
              (SELECT pc.TCIIU 
                 FROM per_ciiu pc 
                INNER JOIN fin_general f
                   ON pc.cciiu = f.cciiu
                WHERE pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() 
                  AND  f.sperson = psperson) as TCCIIUPPAL     
         FROM per_personas      per,
              per_detper        d,
              per_ccc           c,
              per_identificador p,
              per_personas_rel  ppr,
              per_detper        pdp,
              per_personas      pp,
              per_identificador pi
        WHERE per.sperson = psperson
          AND d.sperson = per.sperson
          AND c.sperson(+) = d.sperson
          AND per.sperson = p.sperson
          AND ppr.sperson(+) = per.sperson
          AND ppr.ctipper_rel(+) = 1
          AND ppr.cagrupa(+) = 0 
          AND pdp.sperson(+) = ppr.sperson_rel
          AND pp.sperson(+) = ppr.sperson_rel
          AND pi.sperson(+) = ppr.sperson_rel
          AND pi.ctipide = pp.ctipide(+) 
          AND pi.nnumide = pp.nnumide(+)
          AND per.swpubli IN (0, 1);
       -- AND per.cagente = d.cagente;
        END IF;
   END IF;
   RETURN v_cursor;
EXCEPTION
   WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                        psqcode => SQLCODE, psqerrm => SQLERRM);
      RETURN NULL;
END f_get_persona_sarlaf;
--INI--WAJ
/**************************************************************/
     PROCEDURE p_del_impuesto(
      psperson IN number,
      pctipind IN number,
      errores OUT t_ob_error) IS
      i              NUMBER := 1;
      verr           ob_error;
      x_vinculo number;
      x_cimpret number;
      x_postal number;
      x_cagente number;
      x_sprofes number;
      x_ccompani number;

    vcterminal     usuarios.cterminal%TYPE;
      v_host         VARCHAR2(10);
      vsinterf       NUMBER;
      psinterf       NUMBER;
      terror         VARCHAR2(300);
      num_err        NUMBER;
    /* Cambios de Iaxis-4521 : start */
      VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;    
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    /* Cambios de Iaxis-4521 : end */   

   BEGIN
      errores := t_ob_error();
      errores.DELETE;

    begin
    select codvinculo
       into x_vinculo
    from per_indicadores
    where sperson = psperson
       and ctipind = pctipind;
    exception when no_data_found then
         x_vinculo := 999999999;
    end;

    begin
         select cimpret
            into x_cimpret
         from tipos_indicadores
         where ctipind = pctipind;
         exception when no_data_found then
              x_cimpret := 99;
    end;

  /* Cambios de Iaxis-4521 : start */ 
      BEGIN
        SELECT PP.NNUMIDE,PP.TDIGITOIDE
          INTO VPERSON_NUM_ID,VDIGITOIDE
          FROM PER_PERSONAS PP
         WHERE PP.SPERSON = psperson
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SELECT PP.CTIPIDE
            INTO VCTIPIDE
            FROM PER_PERSONAS PP
           WHERE PP.SPERSON = psperson;
          VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                         UPPER(VPERSON_NUM_ID));
      END;  
   /* Cambios de Iaxis-4521 : end */    

    if x_vinculo = 3 then
       if x_cimpret = 1 then
          update agentes
             set cdescriiva = ''
          where sperson = psperson;
       end if;
        if x_cimpret = 2 then
          update agentes
             set descricretenc = ''
          where sperson = psperson;
       end if;
        if x_cimpret = 3 then
          update agentes
             set descrifuente = ''
          where sperson = psperson;
       end if;
       if x_cimpret = 4 then
            begin
            select cpostal
               into x_postal
            from tipos_indicadores_det
            where ctipind = pctipind;
            exception when no_data_found then
                 x_postal := 99999999;
            end;

            begin
               select cagente
                  into x_cagente
               from per_direcciones
               where sperson = psperson
                  and cpostal = x_postal;
               exception when no_data_found then
                  x_cagente := 999999999;
            end;

            update agentes
             set cdescriica = ''
          where cagente = x_cagente;
       end if;
    end if;

    if (x_vinculo = 2 or x_vinculo = 7) then
       begin
            select sprofes
               into x_sprofes
            from sin_prof_profesionales
            where sperson = psperson;
            exception when no_data_found then
                 x_sprofes := 999999999;
        end;

        delete from sin_prof_indicadores
        where sprofes = x_sprofes
           and ctipind = pctipind;
    end if;

    if x_vinculo = 4 then
         begin
            select ccompani
               into x_ccompani
            from companias
            where  sperson = psperson;
            exception when no_data_found then
                 x_ccompani := 999999999;
        end;

        delete from indicadores_cias
        where ccompani = x_ccompani
           and ctipind = pctipind;
     end if;

     BEGIN
            DELETE FROM per_indicadores
                  WHERE sperson = psperson
                    AND ctipind = pctipind;
         EXCEPTION
            WHEN OTHERS THEN
               errores.EXTEND;
               verr := ob_error.instanciar(180031,
                                           f_axis_literales(180031, pac_md_common.f_get_cxtidioma) || '  '
                                           || SQLERRM);
               errores(i) := verr;
         END;

      num_err :=  pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'));

        IF 1 = 1 THEN
               /* Por defecto cuando v_host vale null envía al deudor con la cuenta C001*/
               v_host := NULL;

               /* Comprueba si es una persona gubernamental para enviarlo como deudor con la cuenta C008*/
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_DEUDOR_HOST');
               END IF;
         /* Cambios de Iaxis-4521 : start */  
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson, vcterminal, psinterf,
                                                 terror, pac_md_common.f_get_cxtusuario, 1,
                                                 'ALTA', VDIGITOIDE, v_host);
         /* Cambios de Iaxis-4521 : end */                         
            END IF;


            /* ini BUG 26318/167380-- GGR -- 17/03/2014*/
              /* Por defecto se envía el acreedor con la cuenta P004*/
            v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'ALTA_PROV_HOST');

            /* Comprueba si es una persona gubernamental para enviarlo como acreedor con la cuenta P029*/
            IF v_host IS NOT NULL THEN
               IF pac_persona.f_gubernamental(psperson) = 1 THEN
                  v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                          'DUPL_ACREEDOR_HOST');
               END IF;

               psinterf := NULL;   /* Se inicia para que genere un nuevo codigo*/
               num_err := pac_user.f_get_terminal(f_user, vcterminal);

         /* Cambios de Iaxis-4521 : start */  
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson,
                                                 vcterminal, psinterf, terror,
                                                 pac_md_common.f_get_cxtusuario, 1, 'MOD', VDIGITOIDE,
                                                 v_host);
         /* Cambios de Iaxis-4521 : end */                           
            END IF;

   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PERSONA', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(180031,
                                     f_axis_literales(180031, pac_md_common.f_get_cxtidioma) || '  ' || SQLERRM);
         errores(i) := verr;
   END p_del_impuesto;
--FIN--WAJ

-- Inicio IAXIS-3287 01/04/2019
    /*************************************************************************
    FUNCTION f_duplicar_sarlaft
    Permite duplicar un formulario SARLAFT ya confirmado
    param in  pssarlaft     : Código Sarlaft
    param out pssarlaftdest : Nuevo Sarlaft
    param out mensajes   : mesajes de error
    return               : number
   *************************************************************************/
    FUNCTION f_duplicar_sarlaft (
      pssarlaft     IN  NUMBER,
      pssarlaftdest OUT NUMBER,
      mensajes      OUT t_iax_mensajes) 
      RETURN NUMBER IS
      -- 
      vnumerr       NUMBER := 0;
      vobject       VARCHAR2(200) := 'PAC_PERSONA.f_duplicar_sarlaft';
      vparam        VARCHAR2(500) := 'pssarlaft = ' || pssarlaft;
      vpasexec      NUMBER := 0;
      vssarlaftdest NUMBER;
      vsperson      NUMBER;
      vctipper      NUMBER;
      --
      TYPE rec_infobas_per_nat IS RECORD(
         per_papellido       VARCHAR2(50),
         per_sapellido       VARCHAR2(50),
         per_nombres         VARCHAR2(50),
         per_tipdocument     NUMBER,
         per_document        VARCHAR2(50),
         per_fexpedicion     DATE,
         per_paisexpedicion  NUMBER,
         per_tpaisexpedicion VARCHAR(50),
         per_depexpedicion   NUMBER,
         per_tdepexpedicion  VARCHAR(50),
         per_lugexpedicion   NUMBER,
         per_tlugexpedicion  VARCHAR(50),
         per_fnacimi         DATE,
         per_nacion1         NUMBER,
         per_tnacion1        VARCHAR2(50),
         per_direreci        VARCHAR(1000),
         per_pais            NUMBER,
         per_tpais           VARCHAR2(50),
         per_departament     NUMBER,
         per_tdepartament    VARCHAR2(50),
         per_ciudad          NUMBER,
         per_tciudad         VARCHAR2(50),
         per_email           VARCHAR2(100),
         per_telefono        VARCHAR2(100),
         per_celular         VARCHAR2(100),
         nciiuppal           NUMBER,
         tcciiuppal          VARCHAR2(500),
         tocupacion          VARCHAR2(500)
      );

      TYPE rec_infobas_per_jur IS RECORD(
          nrazonso           VARCHAR2(200),
          tnit               VARCHAR2(50),
          trepresentanle     VARCHAR2(150),
          tsegape            VARCHAR2(150),
          tnombres           VARCHAR2(150),
          ntipdoc            NUMBER,
          tnumdoc            VARCHAR2(150),
          rl_fexpedicion     DATE,
          rl_paisexpedicion  NUMBER,
          rl_tpaisexpedicion VARCHAR2(150),
          rl_depexpedicion   NUMBER,
          rl_tdepexpedicion  VARCHAR2(150),
          rl_lugexpedicion   NUMBER,
          rl_tlugexpedicion  VARCHAR2(150),
          rl_fnacimiento     DATE,
          rl_nacion1         NUMBER,
          rl_tnacion1        VARCHAR2(150),
          rl_nacion2         NUMBER,
          rl_tnacion2        NUMBER,
          rl_pais            NUMBER,
          rl_tpais           VARCHAR2(150),
          rl_departament     NUMBER,
          rl_tdepartament    VARCHAR2(150),
          rl_ciudad          NUMBER,
          rl_tciudad         VARCHAR2(100),
          rl_direreci        VARCHAR2(2000),
          rl_email           VARCHAR2(2000),
          rl_telefono        VARCHAR2(2000),
          rl_celular         VARCHAR2(2000),
          toficinapri        VARCHAR2(1000),
          tpais              NUMBER,
          emptpais           VARCHAR2(50),
          tdepatamento       NUMBER,
          emptdepatamento    VARCHAR2(30),
          tciudad            NUMBER,
          emptciudad         VARCHAR(50),
          ttelefono          VARCHAR2(100),
          tfax               VARCHAR2(100),
          tmailjurid         VARCHAR2(2000),
          cciiu              NUMBER, 
          tciiu              VARCHAR2(2000)
          );
      --
      v_per_infobasica_nat rec_infobas_per_nat;
      v_per_infobasica_jur rec_infobas_per_jur;
      --
    BEGIN
      vpasexec := 1;
      IF pssarlaft IS NULL
      THEN
         RAISE e_param_error;
      END IF;
      --
      vpasexec := 2;
      --
      SELECT sperson
        INTO vsperson
        FROM datsarlatf
       WHERE ssarlaft = pssarlaft;
      --
      vpasexec := 3;
      --
      SELECT p.ctipper
        INTO vctipper
        FROM per_personas p
       WHERE p.sperson = vsperson;
      --
      vpasexec := 4;
      --
      vssarlaftdest := ssarlaft.nextval;
      --
      IF vctipper = 1 THEN
         --  
         vpasexec := 5;
         --
         SELECT d.tapelli1 as PER_PAPELLIDO,
                d.tapelli2 as PER_SAPELLIDO,
                d.tnombre as PER_NOMBRES,
                per.ctipide as PER_TIPDOCUMENT,
                per.nnumide as PER_DOCUMENT,
                p.fechadexp as PER_FEXPEDICION,
                p.cpaisexp as PER_PAISEXPEDICION,
                (select pa.tpais
                   from paises pa
                  where pa.cpais = (SELECT id.cpaisexp
                                      FROM per_identificador id
                                     WHERE id.sperson = vsperson)) as PER_TPAISEXPEDICION,
                p.cdepartexp as PER_DEPEXPEDICION,
                (select pr.tprovin
                   from provincias pr
                  where pr.cprovin = (SELECT id.cdepartexp
                                        FROM per_identificador id
                                       WHERE id.sperson = vsperson)) as PER_TDEPEXPEDICION,
                p.cciudadexp as PER_LUGEXPEDICION,
                (select po.tpoblac
                   from poblaciones po
                  where po.cpoblac = (SELECT id.cciudadexp
                                        FROM per_identificador id
                                       WHERE id.sperson = vsperson)
                    and po.cprovin = (SELECT id.cdepartexp
                                        FROM per_identificador id
                                       WHERE id.sperson = vsperson)) as PER_TLUGEXPEDICION,
                per.fnacimi as PER_FNACIMI,
                (SELECT n.cpais
                   FROM per_nacionalidades n
                  WHERE n.sperson = vsperson
                    AND n.cagente = (select det.cagente
                                       from per_detper det
                                      where det.sperson = vsperson)
                    and n.cdefecto = 1) AS PER_NACION1,
                (select pa.tpais
                   from paises pa
                  where pa.cpais = (SELECT n.cpais
                                      FROM per_nacionalidades n
                                     WHERE n.sperson = vsperson
                                       and n.cdefecto = 1)) as PER_TNACION1,
                (SELECT *
                   FROM (SELECT dir.tdomici
                           FROM per_direcciones dir
                          where dir.sperson = vsperson
                            and dir.ctipdir = 9
                          ORDER BY dir.cdomici asc)
                  WHERE ROWNUM = 1) as PER_DIRERECI,
                (select pr.cpais
                   FROM provincias pr
                  WHERE pr.cprovin = (SELECT *
                                        FROM (SELECT dir.cprovin
                                                FROM per_direcciones dir
                                               where dir.sperson = vsperson
                                                 and dir.ctipdir = 9
                                               ORDER BY dir.cdomici asc)
                                       WHERE ROWNUM = 1)) as PER_PAIS,
                (select pa.tpais
                   from paises pa
                  where pa.cpais =
                        (SELECT pr.cpais
                           FROM provincias pr
                          WHERE pr.cprovin = (SELECT *
                                                FROM (SELECT dir.cprovin
                                                        FROM per_direcciones dir
                                                       where dir.sperson = vsperson
                                                         and dir.ctipdir = 9
                                                       ORDER BY dir.cdomici asc)
                                               WHERE ROWNUM = 1))) as PER_TPAIS,
                (SELECT *
                   FROM (SELECT dir.cprovin
                           FROM per_direcciones dir
                          where dir.sperson = vsperson
                            and dir.ctipdir = 9
                          ORDER BY dir.cdomici asc)
                  WHERE ROWNUM = 1) as PER_DEPARTAMENT,
                (select pr.tprovin
                   from provincias pr
                  where pr.cprovin = (select *
                                        from (SELECT dir.cprovin
                                                FROM per_direcciones dir
                                               where dir.sperson = vsperson
                                                 and dir.ctipdir = 9
                                               ORDER BY dir.cdomici asc)
                                       WHERE ROWNUM = 1)) as PER_TDEPARTAMENT,
                (select *
                   from (SELECT dir.cpoblac
                           FROM per_direcciones dir
                          where dir.sperson = vsperson
                            and dir.ctipdir = 9
                          ORDER BY dir.cdomici asc)
                  WHERE ROWNUM = 1) as PER_CIUDAD,
                (select po.tpoblac
                   from poblaciones po
                  where po.cprovin = (SELECT *
                                        FROM (SELECT dir.cprovin
                                                FROM per_direcciones dir
                                               where dir.sperson = vsperson
                                                 and dir.ctipdir = 9
                                               ORDER BY dir.cdomici asc)
                                       WHERE ROWNUM = 1)
                    and po.cpoblac = (SELECT *
                                        FROM (SELECT dir.cpoblac
                                                FROM per_direcciones dir
                                               where dir.sperson = vsperson
                                                 and dir.ctipdir = 9
                                               ORDER BY dir.cdomici asc)
                                       WHERE ROWNUM = 1)) as PER_TCIUDAD,
                (SELECT *
                   FROM (select co.tvalcon
                           from per_contactos co
                          where co.sperson = vsperson
                            and co.ctipcon = 3
                          ORDER BY co.cmodcon asc)
                  WHERE ROWNUM = 1) as PER_EMAIL,
                (SELECT *
                   FROM (select co.tvalcon
                           from per_contactos co
                          where co.sperson = vsperson
                            and co.ctipcon = 1
                          ORDER BY co.cmodcon asc)
                  WHERE ROWNUM = 1) as PER_TELEFONO,
                (SELECT *
                   FROM (select co.tvalcon
                           from per_contactos co
                          where co.sperson = vsperson
                            and co.ctipcon = 6
                          ORDER BY co.cmodcon asc)
                  WHERE ROWNUM = 1) as PER_CELULAR,
                (SELECT f.CCIIU
                   FROM per_ciiu pc
                  INNER JOIN fin_general f
                     ON pc.cciiu = f.cciiu
                  WHERE pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA()
                    AND f.sperson = vsperson) as NCIIUPPAL,
                (SELECT pc.TCIIU
                   FROM per_ciiu pc
                  INNER JOIN fin_general f
                     ON pc.cciiu = f.cciiu
                  WHERE pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA()
                    AND f.sperson = vsperson) as TCCIIUPPAL,
                FF_DESCPROFES(d.cocupacion,
                              PAC_MD_COMMON.F_Get_CXTIDIOMA(),
                              PAC_MD_COMMON.F_GET_CXTEMPRESA()) as TOCUPACION
           INTO v_per_infobasica_nat
           FROM per_personas per, per_detper d, per_ccc c, per_identificador p
          WHERE per.sperson = vsperson
            AND d.sperson = per.sperson
            AND c.sperson(+) = d.sperson
            AND per.sperson = p.sperson
            AND per.swpubli in (0, 1);
          --
      vpasexec := 6;
      --
      -- Duplicar registro SARLAFT principal persona natural
      INSERT INTO datsarlatf
        (ssarlaft, fradica,sperson, fdiligencia, cauttradat, crutfcc, cestconf, fconfir,
             cvinculacion, cvintomase, tvintomase, cvintomben, tvintombem, cvinaseben, tvinasebem,
             nciiuppal, tocupacion, tcargo, tempresa, tdirempresa, ttelempresa, nciiusec,
             tdirsec, ttelsec, tprodservcom, iingresos, iactivos, ipatrimonio, iegresos,
             ipasivos, iotroingreso, tconcotring, cmanrecpub, cpodpub, crecpub, cvinperpub,
             tvinperpub, cdectribext, tdectribext, torigfond, ctraxmodext, cprodfinext,
             cctamodext, totrasoper, creclindseg, tciudadsuc, tpaisuc, tciudad, tpais,
             tlugarexpedidoc, resociedad, tnacionali2, ngradopod, ngozrec, nparticipa,
             nvinculo, ntipdoc, fexpedicdoc, fnacimiento, nrazonso, tnit, tdv, toficinapri,
             ttelefono, tfax, tsucursal, ttelefonosuc, tfaxsuc, ctipoemp, tcualtemp, tsector, tactiaca,
             trepresentanle, tsegape, tnombres, tnumdoc, tlugnaci, tnacionali1, tindiquevin,
             perpapellido, persapellido, pernombres, pertipdocument, perdocument,
             perfexpedicion, perlugexpedicion, perfnacimi, perlugnacimi, pernacion1, pernacion2,
             perdirereci, perpais, perciudad, perdepartament, peremail, pertelefono, percelular,
             nrecpub, tpresetreclamaci, pertlugexpedicion, pertlugnacimi, pertnacion1, pertnacion2,
             pertpais, pertdepartament, pertciudad, emptpais, emptdepatamento, emptciudad, emptpaisuc,
             emptdepatamentosuc, emptciudadsuc, emptlugnaci, emptnacionali1, emptnacionali2, csujetooblifacion,
             perpaisexpedicion, pertpaisexpedicion, perdepexpedicion, pertdepexpedicion, perpaislugnacimi,
             pertpaislugnacimi, perdeplugnacimi, pertdeplugnacimi, emppaisexpedicion, emptpaisexpedicion,
             empdepexpedicion, emptdepexpedicion, emppaislugnacimi, emptpaislugnacimi, empdeplugnacimi,
             emptdeplugnacimi, emplugnacimi, emptlugnacimi, empfexpedicion, emplugexpedicion, emptlugexpedicion,
             cciiu, cactippal, cactisec, tdepatamento, cciusol, ctipsol, csector, ctipact, cciuofc, cdepofc,
             tmailrepl, tdirsrepl, cciurrepl, cdeprrepl, cpairrepl, ttelrepl, tcelurepl, cciuentrev, fentrevista,
             thoraentrev, tagenentrev, tasesentrev, tobseentrev, crestentrev, tobseconfir, thoraconfir,
             templconfir, cuser, falta, csucursal, tvinculacion, percdeptosol, pertdeptosol, percciusol, 
             pertciusol, persectorppal, pertipoactivppal, tindiqueoblig, tcciiuppal, tcciiusec, tmailjurid,
             tdepatamentosuc, percdeptoofic, pertdeptoofic, percciuofic, pertciuofic, tpairrepl, tdeprrepl,
             tciurrepl, ttraxmodext, cdeptoentrev, tdeptoentrev, tciuentrev, corigenfon, cclausula1, cclausula2, cconfir)
        (SELECT vssarlaftdest, f_sysdate, sperson, f_sysdate, cauttradat, NULL, NULL, NULL, cvinculacion,
                cvintomase, tvintomase, cvintomben, tvintombem, cvinaseben, tvinasebem, v_per_infobasica_nat.nciiuppal,
                v_per_infobasica_nat.tocupacion, tcargo, tempresa, tdirempresa, ttelempresa, nciiusec, tdirsec,
                ttelsec, tprodservcom, iingresos, iactivos, ipatrimonio, iegresos, ipasivos, iotroingreso, tconcotring,
                cmanrecpub, cpodpub, crecpub, cvinperpub, tvinperpub, cdectribext, tdectribext, torigfond, ctraxmodext,
                cprodfinext, cctamodext, totrasoper, creclindseg, tciudadsuc, tpaisuc, tciudad, tpais, tlugarexpedidoc,
                resociedad, tnacionali2, ngradopod, ngozrec, nparticipa, nvinculo, ntipdoc, fexpedicdoc, fnacimiento,
                nrazonso, tnit, tdv, toficinapri, ttelefono, tfax, tsucursal, ttelefonosuc, tfaxsuc, ctipoemp, tcualtemp,
                tsector, tactiaca, trepresentanle, tsegape, tnombres, tnumdoc, tlugnaci, tnacionali1, tindiquevin,
                v_per_infobasica_nat.per_papellido, v_per_infobasica_nat.per_sapellido, v_per_infobasica_nat.per_nombres,
                v_per_infobasica_nat.per_tipdocument, v_per_infobasica_nat.per_document, v_per_infobasica_nat.per_fexpedicion,
                v_per_infobasica_nat.per_lugexpedicion, v_per_infobasica_nat.per_fnacimi, perlugnacimi, v_per_infobasica_nat.per_nacion1,
                pernacion2, v_per_infobasica_nat.per_direreci, v_per_infobasica_nat.per_pais, v_per_infobasica_nat.per_ciudad, v_per_infobasica_nat.per_departament,
                v_per_infobasica_nat.per_email, v_per_infobasica_nat.per_telefono, v_per_infobasica_nat.per_celular, nrecpub,
                tpresetreclamaci, v_per_infobasica_nat.per_tlugexpedicion, pertlugnacimi, v_per_infobasica_nat.per_tnacion1, pertnacion2,
                v_per_infobasica_nat.per_tpais, v_per_infobasica_nat.per_tdepartament, v_per_infobasica_nat.per_tciudad, emptpais,
                emptdepatamento, emptciudad, emptpaisuc, emptdepatamentosuc, emptciudadsuc, emptlugnaci, emptnacionali1, emptnacionali2,
                csujetooblifacion, v_per_infobasica_nat.per_paisexpedicion, v_per_infobasica_nat.per_tpaisexpedicion, v_per_infobasica_nat.per_depexpedicion,
                v_per_infobasica_nat.per_tdepexpedicion, perpaislugnacimi, pertpaislugnacimi, perdeplugnacimi, pertdeplugnacimi,                 emppaisexpedicion,
                emptpaisexpedicion, empdepexpedicion, emptdepexpedicion, emppaislugnacimi, emptpaislugnacimi, empdeplugnacimi, emptdeplugnacimi,
                emplugnacimi, emptlugnacimi, empfexpedicion, emplugexpedicion, emptlugexpedicion, cciiu, cactippal, cactisec, tdepatamento,
                cciusol, ctipsol, csector, ctipact, cciuofc, cdepofc, tmailrepl, tdirsrepl, cciurrepl, cdeprrepl, cpairrepl, ttelrepl,
                tcelurepl, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, f_user, f_sysdate, csucursal, tvinculacion, percdeptosol,
                pertdeptosol, percciusol, pertciusol, persectorppal, pertipoactivppal, tindiqueoblig, v_per_infobasica_nat.tcciiuppal, tcciiusec,
                tmailjurid, tdepatamentosuc, percdeptoofic, pertdeptoofic, percciuofic, pertciuofic, tpairrepl, tdeprrepl,
                tciurrepl, ttraxmodext, NULL, NULL, NULL, corigenfon, cclausula1, cclausula2, 0
           FROM datsarlatf
          WHERE ssarlaft = pssarlaft);
      --
      END IF;  
      --
      IF vctipper = 2 THEN
        SELECT d.tapelli1 AS NRAZONSO,
              per.nnumide AS TNIT,
              pdp.tapelli1 AS TREPRESENTANLE,
              pdp.tapelli2 AS TSEGAPE,
              pdp.tnombre AS TNOMBRES,
              pp.ctipide AS NTIPDOC,
              pp.nnumide AS TNUMDOC,
              pi.fechadexp AS RL_FEXPEDICION,
              pi.cpaisexp AS RL_PAISEXPEDICION,
              (SELECT p.tpais FROM paises p WHERE p.cpais = pi.cpaisexp) AS RL_TPAISEXPEDICION,
              pi.cdepartexp AS RL_DEPEXPEDICION,
              (SELECT p.tprovin FROM provinciAS p WHERE p.cprovin = pi.cdepartexp) AS RL_TDEPEXPEDICION,
              (pi.cciudadexp) AS RL_LUGEXPEDICION,
              (SELECT p.tpoblac
                 FROM poblaciones p
                WHERE p.cprovin = pi.cdepartexp
                  AND p.cpoblac = pi.cciudadexp) AS RL_TLUGEXPEDICION,
              pp.fnacimi AS RL_FNACIMIENTO,
              (SELECT cpais
                 FROM per_nacionalidades
                WHERE sperson = pp.sperson
                  AND cdefecto = 1) AS RL_NACION1,
              (SELECT p.tpais
                 FROM paises p
                WHERE p.cpais = (SELECT cpais
                                   FROM per_nacionalidades
                                  WHERE sperson = pp.sperson
                                    AND cdefecto = 1)) AS RL_TNACION1,
              (SELECT cpais
                 FROM per_nacionalidades
                WHERE sperson = pp.sperson
                  AND cdefecto = 0
                  AND norden = 2) AS RL_NACION2,
              (SELECT p.tpais
                 FROM paises p
                WHERE p.cpais = (SELECT cpais
                                   FROM per_nacionalidades
                                  WHERE sperson = pp.sperson
                                    AND cdefecto = 0
                                    AND norden = 2)) AS RL_TNACION2,
              (SELECT cpais
                 FROM provinciAS a
                WHERE a.cprovin = (SELECT p.cprovin
                                     FROM per_direcciones p
                                    WHERE p.sperson = pp.sperson
                                      AND p.cdomici = 1)) AS RL_PAIS,
              (SELECT tpais
                 FROM paises
                WHERE cpais =
                      (SELECT cpais
                         FROM provincias a
                        WHERE a.cprovin = (SELECT p.cprovin
                                             FROM per_direcciones p
                                            WHERE p.sperson = pp.sperson
                                              AND p.cdomici = 1))) AS RL_TPAIS,

              (SELECT p.cprovin
                 FROM per_direcciones p
                WHERE p.sperson = pp.sperson
                  AND p.cdomici = 1) AS RL_DEPARTAMENT,

              (SELECT tprovin
                 FROM provinciAS
                WHERE cprovin = (SELECT p.cprovin
                                   FROM per_direcciones p
                                  WHERE p.sperson = pp.sperson
                                    AND p.cdomici = 1)) AS RL_TDEPARTAMENT,
              (SELECT p.cpoblac
                 FROM per_direcciones p
                WHERE p.sperson = pp.sperson
                  AND p.cdomici = 1) AS RL_CIUDAD,
              (SELECT p.tpoblac
                 FROM poblaciones p
                WHERE p.cprovin = (SELECT p.cprovin
                                     FROM per_direcciones p
                                    WHERE p.sperson = pp.sperson
                                      AND p.cdomici = 1)
                  AND p.cpoblac = (SELECT p.cpoblac
                                     FROM per_direcciones p
                                    WHERE p.sperson = pp.sperson
                                      AND p.cdomici = 1)) AS RL_TCIUDAD,

              (SELECT dir.tdomici
                 FROM per_direcciones dir
                WHERE dir.sperson = pp.sperson
                  AND dir.cdomici = 1) AS RL_DIRERECI,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = pp.sperson
                          AND co.ctipcon = 3
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS RL_EMAIL,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = pp.sperson
                          AND co.ctipcon = 1
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS RL_TELEFONO,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = pp.sperson
                          AND co.ctipcon = 6
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS RL_CELULAR,
--              
              (SELECT *
                 FROM (SELECT dir.tdomici
                         FROM per_direcciones dir
                        WHERE dir.sperson = vsperson
                        ORDER BY dir.cdomici ASC)
                WHERE ROWNUM = 1) AS TOFICINAPRI,
              (SELECT pr.cpais
                 FROM provinciAS pr
                WHERE pr.cprovin = (SELECT *
                                      FROM (SELECT dir.cprovin
                                              FROM per_direcciones dir
                                             WHERE dir.sperson = vsperson
                                             ORDER BY dir.cdomici ASC)
                                     WHERE ROWNUM = 1)) AS TPAIS,
              (SELECT pa.tpais
                 FROM paises pa
                WHERE pa.cpais =
                      (SELECT pr.cpais
                         FROM provinciAS pr
                        WHERE pr.cprovin = (SELECT *
                                              FROM (SELECT dir.cprovin
                                                      FROM per_direcciones dir
                                                     WHERE dir.sperson = vsperson
                                                     ORDER BY dir.cdomici ASC)
                                             WHERE ROWNUM = 1))) AS EMPTPAIS,
              (SELECT *
                 FROM (SELECT dir.cprovin
                         FROM per_direcciones dir
                        WHERE dir.sperson = vsperson
                        ORDER BY dir.cdomici ASC)
                WHERE ROWNUM = 1) AS TDEPATAMENTO,
              (SELECT pr.tprovin
                 FROM provinciAS pr
                WHERE pr.cprovin = (SELECT *
                                      FROM (SELECT dir.cprovin
                                              FROM per_direcciones dir
                                             WHERE dir.sperson = vsperson
                                             ORDER BY dir.cdomici ASC)
                                     WHERE ROWNUM = 1)) AS EMPTDEPATAMENTO,
              (SELECT *
                 FROM (SELECT dir.cpoblac
                         FROM per_direcciones dir
                        WHERE dir.sperson = vsperson
                        ORDER BY dir.cdomici ASC)
                WHERE ROWNUM = 1) AS TCIUDAD,
              (SELECT po.tpoblac
                 FROM poblaciones po
                WHERE po.cprovin = (SELECT *
                                      FROM (SELECT dir.cprovin
                                              FROM per_direcciones dir
                                             WHERE dir.sperson = vsperson
                                             ORDER BY dir.cdomici ASC)
                                     WHERE ROWNUM = 1)
                  AND po.cpoblac = (SELECT *
                                      FROM (SELECT dir.cpoblac
                                              FROM per_direcciones dir
                                             WHERE dir.sperson = vsperson
                                             ORDER BY dir.cdomici ASC)
                                     WHERE ROWNUM = 1)) AS EMPTCIUDAD,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = vsperson
                          AND co.ctipcon = 1
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS TTELEFONO,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = vsperson
                          AND co.ctipcon = 2
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) AS TFAX,
              (SELECT *
                 FROM (SELECT co.tvalcon
                         FROM per_contactos co
                        WHERE co.sperson = vsperson
                          AND co.ctipcon = 3
                        ORDER BY co.cmodcon ASC)
                WHERE ROWNUM = 1) TMAILJURID,
              (SELECT f.CCIIU
                 FROM per_ciiu pc
                INNER JOIN fin_general f
                   ON pc.cciiu = f.cciiu
                WHERE pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA()
                  AND f.sperson = vsperson) AS CCIIU,
              (SELECT pc.TCIIU 
                 FROM per_ciiu pc 
                INNER JOIN fin_general f
                   ON pc.cciiu = f.cciiu
                WHERE pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() 
                  AND  f.sperson = vsperson) as TCCIIUPPAL   
         INTO v_per_infobasica_jur
         FROM per_personAS      per,
              per_detper        d,
              per_ccc           c,
              per_identificador p,
              per_personAS_rel  ppr,
              per_detper        pdp,
              per_personAS      pp,
              per_identificador pi
        WHERE per.sperson = vsperson
          AND d.sperson = per.sperson
          AND c.sperson(+) = d.sperson
          AND per.sperson = p.sperson
          AND ppr.sperson(+) = per.sperson
          AND ppr.ctipper_rel(+) = 1
          AND ppr.cagrupa(+) = 0 
          AND pdp.sperson(+) = ppr.sperson_rel
          AND pp.sperson(+) = ppr.sperson_rel
          AND pi.sperson(+) = ppr.sperson_rel
          AND pi.ctipide = pp.ctipide(+) 
          AND pi.nnumide = pp.nnumide(+)
          AND per.swpubli IN (0, 1);

           INSERT INTO datsarlatf
            (ssarlaft, fradica,sperson, fdiligencia, cauttradat, crutfcc, cestconf, fconfir,
             cvinculacion, cvintomase, tvintomase, cvintomben, tvintombem, cvinaseben, tvinasebem,
             nciiuppal, tocupacion, tcargo, tempresa, tdirempresa, ttelempresa, nciiusec,
             tdirsec, ttelsec, tprodservcom, iingresos, iactivos, ipatrimonio, iegresos,
             ipasivos, iotroingreso, tconcotring, cmanrecpub, cpodpub, crecpub, cvinperpub,
             tvinperpub, cdectribext, tdectribext, torigfond, ctraxmodext, cprodfinext,
             cctamodext, totrasoper, creclindseg, tciudadsuc, tpaisuc, tciudad, tpais,
             tlugarexpedidoc, resociedad, tnacionali2, ngradopod, ngozrec, nparticipa,
             nvinculo, ntipdoc, fexpedicdoc, fnacimiento, nrazonso, tnit, tdv, toficinapri,
             ttelefono, tfax, tsucursal, ttelefonosuc, tfaxsuc, ctipoemp, tcualtemp, tsector, tactiaca,
             trepresentanle, tsegape, tnombres, tnumdoc, tlugnaci, tnacionali1, tindiquevin,
             perpapellido, persapellido, pernombres, pertipdocument, perdocument,
             perfexpedicion, perlugexpedicion, perfnacimi, perlugnacimi, pernacion1, pernacion2,
             perdirereci, perpais, perciudad, perdepartament, peremail, pertelefono, percelular,
             nrecpub, tpresetreclamaci, pertlugexpedicion, pertlugnacimi, pertnacion1, pertnacion2,
             pertpais, pertdepartament, pertciudad, emptpais, emptdepatamento, emptciudad, emptpaisuc,
             emptdepatamentosuc, emptciudadsuc, emptlugnaci, emptnacionali1, emptnacionali2, csujetooblifacion,
             perpaisexpedicion, pertpaisexpedicion, perdepexpedicion, pertdepexpedicion, perpaislugnacimi,
             pertpaislugnacimi, perdeplugnacimi, pertdeplugnacimi, emppaisexpedicion, emptpaisexpedicion,
             empdepexpedicion, emptdepexpedicion, emppaislugnacimi, emptpaislugnacimi, empdeplugnacimi,
             emptdeplugnacimi, emplugnacimi, emptlugnacimi, empfexpedicion, emplugexpedicion, emptlugexpedicion,
             cciiu, cactippal, cactisec, tdepatamento, cciusol, ctipsol, csector, ctipact, cciuofc, cdepofc,
             tmailrepl, tdirsrepl, cciurrepl, cdeprrepl, cpairrepl, ttelrepl, tcelurepl, cciuentrev, fentrevista,
             thoraentrev, tagenentrev, tasesentrev, tobseentrev, crestentrev, tobseconfir, thoraconfir,
             templconfir, cuser, falta, csucursal, tvinculacion, percdeptosol, pertdeptosol, percciusol, 
             pertciusol, persectorppal, pertipoactivppal, tindiqueoblig, tcciiuppal, tcciiusec, tmailjurid,
             tdepatamentosuc, percdeptoofic, pertdeptoofic, percciuofic, pertciuofic, tpairrepl, tdeprrepl,
             tciurrepl, ttraxmodext, cdeptoentrev, tdeptoentrev, tciuentrev, corigenfon, cclausula1, cclausula2, cconfir)
              (SELECT vssarlaftdest, f_sysdate, sperson, f_sysdate, cauttradat, NULL, NULL, NULL,
                      cvinculacion, cvintomase, tvintomase, cvintomben, tvintombem, cvinaseben, tvinasebem,
                      nciiuppal, tocupacion, tcargo, tempresa, tdirempresa, ttelempresa, nciiusec, tdirsec, ttelsec,
                      tprodservcom, iingresos, iactivos, ipatrimonio, iegresos, ipasivos, iotroingreso, tconcotring,
                      cmanrecpub, cpodpub, crecpub, cvinperpub, tvinperpub, cdectribext, tdectribext, torigfond,
                      ctraxmodext, cprodfinext, cctamodext, totrasoper, creclindseg, tciudadsuc, tpaisuc, v_per_infobasica_jur.tciudad,
                      v_per_infobasica_jur.tpais, tlugarexpedidoc, resociedad, v_per_infobasica_jur.rl_nacion2, ngradopod, ngozrec, nparticipa, nvinculo, v_per_infobasica_jur.ntipdoc,
                      v_per_infobasica_jur.rl_fexpedicion, v_per_infobasica_jur.rl_fnacimiento, v_per_infobasica_jur.nrazonso, v_per_infobasica_jur.tnit, tdv, v_per_infobasica_jur.toficinapri, v_per_infobasica_jur.ttelefono, v_per_infobasica_jur.tfax, tsucursal, ttelefonosuc,
                      tfaxsuc, ctipoemp, tcualtemp, tsector, v_per_infobasica_jur.tciiu, v_per_infobasica_jur.trepresentanle, v_per_infobasica_jur.tsegape, v_per_infobasica_jur.tnombres, v_per_infobasica_jur.tnumdoc, tlugnaci,
                      v_per_infobasica_jur.rl_nacion1, tindiquevin, perpapellido, persapellido, pernombres, pertipdocument, perdocument, perfexpedicion,
                      perlugexpedicion, perfnacimi, perlugnacimi, pernacion1, pernacion2, perdirereci, perpais, perciudad, perdepartament,
                      peremail, pertelefono, percelular, nrecpub, tpresetreclamaci, pertlugexpedicion, pertlugnacimi, pertnacion1, pertnacion2,
                      pertpais, pertdepartament, pertciudad, v_per_infobasica_jur.emptpais, v_per_infobasica_jur.emptdepatamento, v_per_infobasica_jur.emptciudad, emptpaisuc, emptdepatamentosuc,
                      emptciudadsuc, emptlugnaci, v_per_infobasica_jur.rl_tnacion1, v_per_infobasica_jur.rl_tnacion2, csujetooblifacion, perpaisexpedicion, pertpaisexpedicion,
                      perdepexpedicion, pertdepexpedicion, perpaislugnacimi, pertpaislugnacimi, perdeplugnacimi, pertdeplugnacimi,
                      v_per_infobasica_jur.rl_paisexpedicion, v_per_infobasica_jur.rl_tpaisexpedicion, v_per_infobasica_jur.rl_depexpedicion, v_per_infobasica_jur.rl_tdepexpedicion, emppaislugnacimi, emptpaislugnacimi,
                      empdeplugnacimi, emptdeplugnacimi, emplugnacimi, emptlugnacimi, empfexpedicion, v_per_infobasica_jur.rl_lugexpedicion, v_per_infobasica_jur.rl_tlugexpedicion,
                      v_per_infobasica_jur.cciiu, cactippal, cactisec, v_per_infobasica_jur.tdepatamento, cciusol, ctipsol, csector, ctipact, cciuofc, cdepofc, v_per_infobasica_jur.rl_email, v_per_infobasica_jur.rl_direreci,
                      v_per_infobasica_jur.rl_ciudad, v_per_infobasica_jur.rl_departament, v_per_infobasica_jur.rl_pais, v_per_infobasica_jur.rl_telefono, v_per_infobasica_jur.rl_celular, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, f_user, f_sysdate, csucursal, tvinculacion, percdeptosol,
                      pertdeptosol, percciusol, pertciusol, persectorppal, pertipoactivppal, tindiqueoblig, tcciiuppal, tcciiusec, v_per_infobasica_jur.tmailjurid,
                      tdepatamentosuc, percdeptoofic, pertdeptoofic, percciuofic, pertciuofic, v_per_infobasica_jur.rl_tpais, v_per_infobasica_jur.rl_tdepartament,v_per_infobasica_jur.rl_tciudad, ttraxmodext,
                      NULL, NULL, NULL, corigenfon, cclausula1, cclausula2, 0
                 FROM datsarlatf
                WHERE ssarlaft = pssarlaft);

      END IF;    
      --
      vpasexec := 7;
      -- Duplicar registros de beneficiarios
      INSERT INTO sarlatfben
        (SELECT vssarlaftdest,
                identificacion,
                ppartici,
                tnombre,
                ctipiden,
                nnumide,
                tsociedad,
                nnumidesoc,
                fregistro,
                f_user
           FROM sarlatfben
          WHERE ssarlaft = pssarlaft);
              --
      vpasexec := 3;     
      -- Duplicar registros de accionistas
      INSERT INTO sarlatfacc
        (SELECT vssarlaftdest,
                identificacion,
                ppartici,
                tnombre,
                ctipiden,
                nnumide,
                cbolsa,
                cpep,
                ctribuext,
                fregistro,
                f_user
           FROM sarlatfacc
          WHERE ssarlaft = pssarlaft);
      --
      vpasexec := 4;
      -- Duplicar registros de personas expuestas públicamente
      INSERT INTO sarlatfpep
        (SELECT vssarlaftdest,
                identificacion,
                ctiprel,
                tnombre,
                ctipiden,
                nnumide,
                cpais,
                tpais,
                tentidad,
                tcargo,
                fdesvin,
                fregistro,
                f_user
           FROM sarlatfpep
          WHERE ssarlaft = pssarlaft);
      --
      vpasexec := 5;
      -- Duplicar reclamaciones en aseguradoras
      INSERT INTO detsarlaft_rec
        (SELECT nrecla,
                sperson,
                vssarlaftdest,
                canio,
                cramo,
                tcompania,
                cvalor,
                tresultado
           FROM detsarlaft_rec
          WHERE ssarlaft = pssarlaft);
      --
      vpasexec := 6;
      --     
      INSERT INTO detsarlatf_act
        (SELECT nactivi,
                sperson,
                vssarlaftdest,
                ctipoprod,
                cidnumprod,
                tentidad,
                cmonto,
                cciudad,
                cpais,
                cmoneda,
                scpais,
                stdepb,
                scciudad,
                tdepb
           FROM detsarlatf_act
          WHERE ssarlaft = pssarlaft);
        --
        vpasexec := 7;
        --  
        INSERT INTO detsarlatf_dec
          (SELECT ndeclara,
                  sperson,
                  vssarlaftdest,
                  ctipoid,
                  cnumeroid,
                  tnombre,
                  cmanejarec,
                  cejercepod,
                  cgozarec,
                  cdeclaraci,
                  cdeclaracicual
             FROM detsarlatf_dec
            WHERE ssarlaft = pssarlaft);
         --   
      vpasexec := 8;
      --
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;
      --
      vpasexec := 9;
      --
      pssarlaftdest := vssarlaftdest;
      --
      RETURN vnumerr;  
    EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, 
                                           psqcode  => SQLCODE, psqerrm  => SQLERRM);
         RETURN 1;
    END;
-- Fin IAXIS-3287 01/04/2019

  /*************************************************************************
  For IAXIS-4149 by PK-18/07/2019
  FUNCTION F_GET_CODITIPOBANC : Nueva funcion para obtener tipo de CUENTA.
    PCBANCO Código de Banco.
    PCTIPCC Que tipo de cuenta és.
  return              : 0 si ha ido bien, 1 si ha ido mal.
  *************************************************************************/
  FUNCTION F_GET_CODITIPOBANC(PCBANCO IN NUMBER,
              PCTIPCC  IN VARCHAR2,
              PCTIPBAN OUT NUMBER) RETURN NUMBER IS
    vnumerr   NUMBER(5) := 0;
        VTRAZA    NUMBER := 0;
    vparam    VARCHAR2(500) := 'parametros - PCBANCO: ' || PCBANCO || ' PCTIPCC' || PCTIPCC;
    vobject   VARCHAR2(200) := 'PAC_MD_PERSONA.F_GET_CODITIPOBANC';
    --
  BEGIN
    IF PCBANCO IS NULL OR PCTIPCC IS NULL THEN
      RAISE e_param_error;
    END IF;
    --
    BEGIN
      SELECT DISTINCT CTIPBAN
      INTO PCTIPBAN
      FROM TIPOS_CUENTA
      WHERE CBANCO = PCBANCO
      AND CTIPCC = PCTIPCC;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        PCTIPBAN := 1;
      WHEN OTHERS THEN
        PCTIPBAN := 1;
    END;
    --
    RETURN vnumerr;
    --
  EXCEPTION
    WHEN e_param_error THEN
            P_TAB_ERROR(F_SYSDATE, F_USER, vobject, VTRAZA, 'Error en PAC_PERSONA.F_GET_CODITIPOBANC', 'Error : ' || SQLERRM);
      RETURN 1;
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE, F_USER, vobject, VTRAZA, 'Error en PAC_PERSONA.F_GET_CODITIPOBANC', 'Error : ' || SQLERRM);
      RETURN 1;
    --
  END F_GET_CODITIPOBANC;

   --Inicio IAXIS-7735 JRVG 26/12/2019 Pagador Alternativo
   PROCEDURE P_PAGADOR_ALT(PI_SSEGURO IN NUMBER) IS
      P_NRECIBO   NUMBER;
      V_SPERSON   NUMBER;
      V_INTER     NUMBER;
      X_CORRETAJE NUMBER;
      VNERR       NUMBER;
      vsinterf    NUMBER;
      V_RESULT    NUMBER;
      P_PASEXEC   NUMBER(8) := 0;
      --
      CURSOR C_AGE_CORRETAJE(C_SSEGURO NUMBER) IS         
      SELECT DISTINCT AG.CAGENTE
        FROM AGE_CORRETAJE AG 
       WHERE AG.SSEGURO = C_SSEGURO;

      CURSOR C_RECIBOS (C_SSEGURO NUMBER) IS
      SELECT DISTINCT R.NRECIBO
        FROM RECIBOS R
       WHERE R.SSEGURO = C_SSEGURO;

    BEGIN

      SELECT T.SPERSON
        INTO V_SPERSON
        FROM TOMADORES T
       WHERE T.SSEGURO = PI_SSEGURO;


      FOR REC IN C_RECIBOS (PI_SSEGURO) LOOP

      --VALIDA INTERMEDICACION
       X_CORRETAJE := PAC_CONTAB_CONF.F_SSEGURO_CORETAJE(REC.NRECIBO);

       IF X_CORRETAJE <> 0 THEN

        FOR AGEN IN C_AGE_CORRETAJE(PI_SSEGURO) LOOP

         SELECT P.SPERSON
           INTO V_INTER 
           FROM AGENTES A, PER_PERSONAS P 
          WHERE A.SPERSON = P.SPERSON
            AND A.CAGENTE = AGEN.CAGENTE;

          VNERR := F_PAGADOR_ALT(V_SPERSON,V_INTER,1,1);
          IF VNERR = 1 THEN
            V_RESULT := VNERR;
          END IF;

        END LOOP;

       ELSE   

      SELECT P.SPERSON
        INTO V_INTER
        FROM SEGUROS S, PER_PERSONAS P, AGENTES A
       WHERE S.CAGENTE = A.CAGENTE
         AND A.SPERSON = P.SPERSON
         AND S.SSEGURO = PI_SSEGURO;

         VNERR := F_PAGADOR_ALT(V_SPERSON,V_INTER,1,1);

       V_RESULT := VNERR;

      END IF;

     END LOOP;
    IF V_RESULT = 1 THEN

       VSINTERF := NULL;
       PAC_REENVIO_SER.P_PAGADOR_I017(VSINTERF,V_SPERSON);

     END IF;

    EXCEPTION
      WHEN OTHERS THEN
        P_TAB_ERROR(F_SYSDATE,
                    F_USER,
                    'P_PAGADOR_ALT',
                     P_PASEXEC,'SSEGURO:'|| '' ||PI_SSEGURO,
                    SQLERRM);

    END P_PAGADOR_ALT;
  --Fin IAXIS-7735 JRVG 26/12/2019 Pagador Alternativo
END pac_persona;
/
create or replace PACKAGE BODY "PAC_MD_PERSONA" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_PERSONA
      PROPOSITO: Funciones para gestionar personas

      REVISIONES:
      Ver        Fecha        Autor             Descripcion
      ---------  ----------  ---------------  ------------------------------------
      1.0        04/04/2008   JRH                1. Creacion del package.
      2.0        18/05/2009   JTS                2. 10074: Modificaciones en el Mantenimiento de Personas
      3.0        09/06/2009   JTS                3. 10371: APR - tipo de empresa
      4.0        09/06/2009   ETM                4. 10342: IAX - validacion del NRN no funciona
      5.0        02/07/2009   XPL                5. 10339 i 9227, APR - Campos extra en la busqueda de personas
                                                   i APR - Error al crear un agente
      6.0        07/10/2009   XPL                6. 11079-APR - errores al crear una persona juridica
      7.0        16/11/2009   NMM                7. 11948: CEM - Alta de destinatatios.
      8.0        18/01/2010   NMM                8. 12009: CRE200- Incidencia mantenimiento de personas.
      9.0        09/02/2010   DRA                9. 11171: APR - campos de busqueda en el mto. de personas
     10.0        23/03/2010   JAS               10. 12675: CRE200 - Permitir contratar con productos con direccion fija para el tomador
     11.0        02/07/2010   ICV               11. 0015253: GRC - Busqueda de personas por direccion
     12.0        09/09/2010   DRA               12. 0015810: AGA003 - L'alta de persona no comprova be si la persona existeix o no
     13.0        22/11/2010   XPL               13. 16753: CRE - Pantalla destinatarios - 22/11/2010 - XPL
     14.0        11/04/2011   APD               14. 0018225: AGM704 - Realizar la modificacion de precision el cagente
     15.0        14/06/2011   APD               15. 0017931: CRE800 - Persones duplicades
     16.0        27/07/2011   ICV               16. 0018941: LCOL_P001 - PER - Personas relacionadas. Representante legal
     17.0        23/09/2011   MDS               17. 0018943  Modulo SARLAFT en el mantenimiento de personas
     18.0        10/10/2011   JMP               18. 0019545: ENSA800-Problema al recuperar la persona sin direccion
     19.0        04/10/2011   MDS               19. 0018947: LCOL_P001 - PER - Posicion global
     20.0        04/11/2011   APD               20. 0018946: LCOL_P001 - PER - Visibilidad en personas
     21.0        08/11/2011   JGR               21. 0019985  LCOL_A001-Control de las matriculas (prenotificaciones)
     22.0        16/11/2011   JGR               22. 0019985  LCOL_A001-Control de las matriculas (nota: 0097969)
     23.0        23/11/2011   APD               23. 0020126: LCOL_P001 - PER - Documentacion en personas
     24.0        24/11/2011   APD               24. 0019550: LCOL760-Catalogacion de tarjetas.
     25.0        03/01/2012   JGR               25. 0020735: LCOL_A001-ADM - Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
     26.0        10/01/2012   JGR               26. 0020735/0103205 Modificaciones tarjetas y ctas.bancarias
     27.0        17/01/2012   ETM               27. 0019896: LCOL_S001-SIN - Declarante del siniestro
     28.0        13/02/2012   JMP               28. 21270/107049: LCOL898 - Interfase persones. Tractament errors crida a PAC_CON.F_ALTA_PERSONA.
     29.0        16/02/2012   MDS               29. 0021392: MDP - PER - Cuentas bancarias que NO aceptan pagos de siniestros.
     30.0        29/02/2012   ETM               30. 0021406: MDP - PER - A?adir el nombre en la tabla contactos
     31.0        09/07/2012   ETM               31.0022263: LCOL_P001 - PER - Informaci?n relacionado con documentos identificativos.
     32.0        24/07/2012   ETM               32. 0022642: MDP - PER - Posicion global. Inquilinos, avalistas y gestor de cobro
     32.0        24/07/2012   ETM               32. 0022642: MDP - PER - Posicion global. Inquilinos, avalistas y gestor de cobro
     33.0        11/12/2012   ETM               33. 0024780: RSA 701 - Preparar personas para Chile
     34.0        21/01/2013   APD               34. 0025542: LCOL_T031- LCOL - AUT - (id 431) Fecha de antig?edad en personas por agrupaci?n
     35.0        30/01/2013   JDS               35. 0025859/0136289 : LCOL_T031-LCOL - AUT - Pantalla conductores (axisctr061)
     36.0        31/01/2013   JDS               36. 0025849/0136136: LCOL - PER - Posición global de personas : conductores
     37.0        11/02/2013   DCT               37. 0026057/0137564:LCOL - PER - Atuorizacion de contactos - Relación entre contactos y direcciones
     38.0        05/03/2013   MMS               38. 0024764: (POSDE300)-Desarrollo-GAPS Personas-Id 99 - Funcionario - Creacion . modif. la funcion f_get_conductores y la ponemos en PAC_MD_PERSONAS
     39.0        03/06/2013   JDS               39. 0027083: LCOL - PER - Revisión Q-Trackers Fase 3A
     40.0        05/07/2013   FAL               40. 0026968: RSAG101 - Producto RC Argentina. Incidencias (14/5)
     41.0        08/07/2013   RCL               41. 0025599: LCOL - PER - Revision incidencias qtracker y Releases
     42.0        05/08/2013   RCL               42. 0027814: LCOL - PER - Nuevo contacto en el alta rápida de personas Fax.
     43.0        30/09/2013   DCT               43. 0028400: LCOL - PER - Autorización de contactos y direcciones.
     44.0        23/10/2013   DCT               44. 0028400: LCOL - PER - Autorización de contactos y direcciones.
     45.0        13/10/2013   JDS               45. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
     46.0        13/03/2014   ECP               46. 30417/11671: CAMPO CONTACTO TIPO TELEFONO PERMITIR SOLO VALORES NUMERICOS.
     47.0        21/03/2014   JTT               47. 30670/170206: Recuperar la CCC para las SEDES
     48.0        03/04/2014   FAL               48. 0030525: INT030-Prueba de concepto CONFIANZA
     49.0        01/07/2015   IGIL              49  0035888/203837 quitar UPPER a NNUMNIF
     50.0        14/07/2015   BLA               50  0034989/210019 Se modifica consulta en función f_get_prefijospaises
     51.0        10/08/2015   JGR               51  0036097: COLM - Cambio de estado de recibos. Nota: 210485
     52.0        25/08/2015   CJMR              52  37437/212585: POS - Se agrega parámetro BUSQUEDA_NIF_COMPLET para mejorar búsqueda
     53.0        15/10/2015   BLA               53  33515-215632 MSV se  adicionan parametros pnnumvia, potros al llamado pac_propio.f_valdireccion en funcion f_set_direccion
     54.0        23/05/2016   VCG               54  0041766: AMA008-Bug cliente 0041719 - cross -Mantenimiento de compañías. (id ID0076 ) en funciones f_set_contactotlffijo y f_set_contactotlfmovil
     55.0        07/03/2016   JAEG              55. 40927/228750: Desarrollo Diseño técnico CONF_TEC-03_CONTRAGARANTIAS
     56.0        23/06/2016   ERH               24. CONF-52 Modificación de la función f_set_persona_rel se adiciona al final el parametro â€¢	PTLIMIT VARCHAR2
     57.0        03/08/2016   HRE               57  CONF-186: Se crean las funciones de marcas para la inclusion de marcas en la pantalla de personas, igualmente se
                                                    modifica la funcion f_get_persona para realizar el llamado a las funciones de marcas.
     58.0        09/06/2017   JEB               58  CONF-841: se agrega los campos del codigo ciiu y descripcion del codigo ciiu.
     59.0        25/08/2017   JGONZALEZ         59  CONF-1049: Llamado al web service de persona para dar de alta
     60.0        21/11/2018   JLTS              60. CP0025M_SYS_PERS - JLTS - 21/11/2018 - se intercambia el orden de los parámetros pctipiva y pcregfisexeiva
     61.0        23/11/2018   ACL               61. CP0727M_SYS_PERS_Val Se agrega en la función f_set_datsarlatf el parámetro pcorigenfon.
     62.0        18/12/2018   ACL               62. CP0416M_SYS_PERS Se agrega la función f_get_persona_sarlaf.
     63.0        07/01/2019   SWAPNIL           63. Cambios para solicitudes múltiples
     64.0        17/01/2019   AP                64. TCS 468A 17/01/2019 AP Se modifica funcion f_get_persona_rel Consorcios y Uniones Temporales
     65.0        30/01/2019   SWAPNIL           65. Cambios para enviar error
     66.0        29/01/2019   WAJ               66.Se crea funcion de impuestos
     67.0        01/02/2019   ACL               67. TCS_1569B: Se agrega la función f_get_persona_publica_imp.
     68.0        12/02/2019   AP                34. TCS-9: Se adiciona campos en la funcion f_set_datsarlatf para clausulas.
     69.0        19/02/2019   CJMR              69. TCS-344: Nuevo funcional Marcas
     70.0        01/03/2019   CES               70. TCS-1554 Conviviencia de Osiris - iAxis
     71.0        01/04/2019   DFRP              71. IAXIS-3287:FCC (Formulario de Conocimiento de Cliente).
     72.0        12/04/2019   CES               72. IAXIS-3471: Incidencias Modificacion Encabezado Personas
     73.0        27/06/2019   KK                73. CAMBIOS De IAXIS-4538
     74.0        03/07/2019   ROHIT             74.IAXIS 4697 El campo de IVA debe ser visible en este seccion en personas 
     75.0        03/07/2019   Shakti            75.IAXIS 4696 El campo de IVA debe ser visible en este seccion en personas
     76.0        09/07/2019   PK                76.For IAXIS-4728 -- Registros Sección Régimen Fiscal Personas
     77.0        18/07/2019   PK                77. Added function for IAXIS-4149 - Modificación Cuentas Bancarias
     78.0        10/02/2020   CJMR              78. IAXIS-3670: Solución bug IAXIS-11917. Modificación de la función f_valida_consorcios
	 79.0		 18/03/2020	  SP				79. Cambios de  tarea IAXIS-13044
******************************************************************************/

   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   pmode VARCHAR2(20);

   /*JRH 04/2008 Tarea ESTPERSONAS*/

   /*************************************************************************
   /*************************************************************************
      Recupera la lista de personas que coinciden con los criterios de consulta
      param in numide    : numero documento
      param in nombre    : texto que incluye nombre + apellidos
      param in nsip      : identificador externo de persona, puede ser nulo
      param out mensajes : mensajes de error
      param in psseguro  : identificador interno de seguro, puede ser nulo
      param in pnom      : nombre de la persona, puede ser nulo
      param in pcognom1  : apellido 1 de la persona, puede ser nulo
      param in pcognom2  : apellido 2 de la persona, puede ser nulo
      param in pctipide  : tipo de documento identificativo, puede ser nulo
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_personas(numide   IN VARCHAR2,
                           nombre   IN VARCHAR2,
                           nsip     IN VARCHAR2 DEFAULT NULL,
                           mensajes IN OUT t_iax_mensajes,
                           psseguro IN NUMBER DEFAULT NULL,
                           /*JRH 04/2008 Se pasa el seguro*/
                           pnom     IN VARCHAR2 DEFAULT NULL,
                           pcognom1 IN VARCHAR2 DEFAULT NULL,
                           pcognom2 IN VARCHAR2 DEFAULT NULL,
                           pctipide IN NUMBER DEFAULT NULL)
      RETURN SYS_REFCURSOR IS
      condicio1 VARCHAR2(1000);
      condicio2 VARCHAR2(1000);
      condicio3 VARCHAR2(1000);
      condicio4 VARCHAR2(1000);
      condicio5 VARCHAR2(1000);
      condicio6 VARCHAR2(1000);
      condicio7 VARCHAR2(1000);
      tlog      VARCHAR2(4000);
      cur       SYS_REFCURSOR;
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(2000) := 'numide= ' || numide || ', nombre= ' ||
                                  nombre || ', nsip= ' || nsip ||
                                  ', psseguro= ' || psseguro || ', pnom= ' || pnom ||
                                  ', pcognom1= ' || pcognom1 ||
                                  ', pcognom2= ' || pcognom2 ||
                                  ', pctipide= ' || pctipide;
      vobject   VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Personas';
      vnumerr   NUMBER := 0;
      terror    VARCHAR2(200) := 'Error recuperar personas';
      /*//ACC recuperar desde literales*/
      auxnom VARCHAR2(2000);
      nerr   NUMBER;
      /*//ACC recuperar desde literales*/
      /*//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);*/
   BEGIN
      IF nombre IS NOT NULL
      THEN
         nerr      := f_strstd(nombre, auxnom);
         condicio1 := '%' || auxnom || '%';
         tlog      := ' UPPER(tbuscar) LIKE UPPER (' || condicio1 ||
                      ') AND';
      END IF;

      IF numide IS NOT NULL
      THEN
         /*Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'), 0) = 1
         THEN
            tlog := tlog || ' UPPER(nnumnif) = UPPER (' || condicio2 ||
                    ') AND';
         ELSE
            condicio2 := numide;
            tlog      := tlog || ' nnumnif = ' || condicio2 || ' AND';
         END IF;
      END IF;

      IF nsip IS NOT NULL
      THEN
         condicio3 := nsip;
         tlog      := tlog || ' UPPER(snip) = UPPER (' || condicio3 ||
                      ') AND';
      END IF;

      IF pnom IS NOT NULL
      THEN
         condicio4 := '%' || ff_strstd(pnom) || '%';
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*tlog := ' FF_STRSTD(tnombre) LIKE ' || condicio4 || ' AND';*/
         tlog := tlog || ' UPPER(tnombre) LIKE ' || condicio4 || ' AND';
      END IF;

      IF pcognom1 IS NOT NULL
      THEN
         condicio5 := '%' || ff_strstd(pcognom1) || '%';
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*tlog := ' FF_STRSTD(tapelli1) LIKE ' || condicio5 || ' AND';*/
         tlog := tlog || ' UPPER(tapelli1) LIKE ' || condicio5 || ' AND';
      END IF;

      IF pcognom2 IS NOT NULL
      THEN
         condicio6 := '%' || ff_strstd(pcognom2) || '%';
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*tlog := ' FF_STRSTD(tapelli2) LIKE ' || condicio6 || ' AND';*/
         tlog := tlog || ' UPPER(tapelli2) LIKE ' || condicio6 || ' AND';
      END IF;

      IF pctipide IS NOT NULL
      THEN
         condicio7 := TO_CHAR(pctipide);
         tlog      := tlog || ' ctipide = ' || condicio7 || ' AND';
      END IF;

      IF tlog IS NOT NULL
      THEN
         -- Se elimina el ultimo 'AND'
         tlog := SUBSTR(tlog, 1, length(tlog) - 3);
      END IF;

      /*BUG10300-XVM-15/09/2009 inici*/
      vnumerr := pac_md_log.f_log_consultas('SELECT codi, coditablas, nnumnif, nombre FROM (' ||
                                            chr(10) ||
                                            '   SELECT sperson codi, ''POL'' coditablas, LPAD(nnumnif, 10, '' '') nnumnif, tnombre || '' '' || tapelli nombre' ||
                                            chr(10) || '   FROM personas' ||
                                            chr(10) || '   WHERE ' || tlog ||
                                            ' AND NOT EXISTS (' || chr(10) ||
                                            'SELECT sperson codi, ''EST'' coditablas, LPAD(nnumnif, 10, '' '') nnumnif, tnombre || '' '' || tapelli nombre FROM ' ||
                                            '(SELECT sperson codi, ''EST'' coditablas, LPAD(nnumnif, 10, '' '') nnumnif, tnombre || '' '' || tapelli nombre ' ||
                                            'FROM ESTPERSONAS WHERE SPREAL = PERSONAS.SPERSON AND SSEGURO = ' ||
                                            psseguro || chr(10) || 'UNION' ||
                                            chr(10) ||
                                            '   SELECT sperson codi, ''EST'' coditablas, LPAD(nnumnif, 10, '' '') nnumnif, tnombre || '' '' || tapelli nombre' ||
                                            chr(10) ||
                                            '   FROM estpersonas' ||
                                            chr(10) || '   WHERE ' || tlog ||
                                            'ORDER BY NOMBRE)
	                                                        WHERE AND ROWNUM<= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100))' ||
                                            ' AND SSEGURO = ' || psseguro ||
                                            chr(10) || ' ORDER BY NOMBRE)' ||
                                            'WHERE ROWNUM<= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)',
                                            'PAC_MD_PERSONA.F_GET_PERSONAS',
                                            1, 1, mensajes);

      /*
      -- SBG 30/05/2008 INICI
      vnumerr :=
         pac_md_log.f_log_consultas
            ('SELECT codi, coditablas, nnumnif, nombre FROM (' || CHR(10)
             || '   SELECT sperson codi, ''POL'' coditablas, LPAD(nnumnif, 10, '' '') nnumnif, tnombre || '' '' || tapelli nombre'
             || CHR(10) || '   FROM personas' || CHR(10) || '   WHERE ' || tlog
             || ' AND ROWNUM<=101 AND NOT EXISTS (' || CHR(10)
             || '      SELECT 1 FROM ESTPERSONAS WHERE SPREAL = PERSONAS.SPERSON AND SSEGURO = '
             || psseguro || CHR(10) || 'UNION' || CHR(10)
             || '   SELECT sperson codi, ''EST'' coditablas, LPAD(nnumnif, 10, '' '') nnumnif, tnombre || '' '' || tapelli nombre'
             || CHR(10) || '   FROM estpersonas' || CHR(10) || '   WHERE ' || tlog
             || ' AND ROWNUM<= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100) AND SSEGURO = ' || psseguro || CHR(10) || ') ORDER BY NOMBRE',
             'PAC_MD_PERSONA.F_GET_PERSONAS', 1, 1, mensajes);
      -- SBG 30/05/2008 FINAL
      */
      OPEN cur FOR
         SELECT codi,
                coditablas,
                nnumnif,
                nombre
           FROM (SELECT sperson codi,
                        'POL' coditablas,
                        lpad(nnumnif, 10, ' ') nnumnif,
                        tnombre || ' ' || tapelli nombre
                   FROM personas_agente p
                  WHERE ((condicio1 IS NULL OR
                        UPPER(tbuscar) LIKE UPPER(condicio1)) AND
                        (condicio2 IS NULL OR nnumnif = condicio2) AND
                        (condicio3 IS NULL OR
                        UPPER(snip) = UPPER(condicio3)) AND
                        (condicio4 IS NULL OR
                        ff_strstd(tnombre) LIKE condicio4) AND
                        (condicio5 IS NULL OR
                        ff_strstd(tapelli1) LIKE condicio5) AND
                        (condicio6 IS NULL OR
                        ff_strstd(tapelli2) LIKE condicio6) AND
                        (condicio7 IS NULL OR ctipide = condicio7))
                       /*AND ROWNUM <= f_parinstalacion_n('N_MAX_REG')*/
                    AND NOT EXISTS (SELECT 1
                           FROM estpersonas
                          WHERE spereal = p.sperson
                            AND sseguro = psseguro)
                 UNION
                 SELECT sperson codi,
                        'EST' coditablas,
                        lpad(nnumnif, 10, ' ') nnumnif,
                        tnombre || ' ' || tapelli nombre
                   FROM estpersonas
                  WHERE ((condicio1 IS NULL OR
                        UPPER(tbuscar) LIKE UPPER(condicio1)) AND
                        (condicio2 IS NULL OR nnumnif = condicio2) AND
                        (condicio3 IS NULL OR
                        UPPER(snip) = UPPER(condicio3)) AND
                        (condicio4 IS NULL OR
                        ff_strstd(tnombre) LIKE condicio4) AND
                        (condicio5 IS NULL OR
                        ff_strstd(tapelli1) LIKE condicio5) AND
                        (condicio6 IS NULL OR
                        ff_strstd(tapelli2) LIKE condicio6) AND
                        (condicio7 IS NULL OR ctipide = condicio7))
                    AND sseguro = psseguro
                  ORDER BY nombre)
          WHERE ROWNUM <=
                NVL(pac_parametros.f_parinstalacion_n('N_MAX_REG'), 100);

      /*BUG10300-XVM-15/09/2009 fi*/
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas;

   /*--------------------------------------------------------------------------*/
   /*  svj. bug 5912*/
   /* xpl 19/06/2009 : bug mantis 0010339 --afegir tdomici, cpostal i fnacimi*/
   /* JLTS 18/02/2013 : bug 25970/0138242 QT-6435 - Se mejoró el Query*/
   FUNCTION f_get_personas_agentes(numide    IN VARCHAR2,
                                   nombre    IN VARCHAR2,
                                   nsip      IN VARCHAR2,
                                   mensajes  IN OUT t_iax_mensajes,
                                   psseguro  IN NUMBER,
                                   pnom      IN VARCHAR2,
                                   pcognom1  IN VARCHAR2,
                                   pcognom2  IN VARCHAR2,
                                   pctipide  IN NUMBER,
                                   pfnacimi  IN DATE,
                                   ptdomici  IN VARCHAR2,
                                   pcpostal  IN VARCHAR2,
                                   phospital IN VARCHAR2 DEFAULT NULL,
                                   pfideico  IN VARCHAR2 DEFAULT NULL) --BUG 40927/228750 - 07/03/2016 - JAEG
    RETURN SYS_REFCURSOR IS
      condicio1 VARCHAR2(1000);
      condicio2 VARCHAR2(1000);
      condicio3 VARCHAR2(1000);
      condicio4 VARCHAR2(1000);
      condicio5 VARCHAR2(1000);
      condicio6 VARCHAR2(1000);
      condicio7 VARCHAR2(1000);
      tlog      VARCHAR2(4000);
      cur       SYS_REFCURSOR;
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(2000) := 'numide= ' || numide || ', nombre= ' ||
                                  nombre || ', nsip= ' || nsip ||
                                  ', psseguro= ' || psseguro || ', pnom= ' || pnom ||
                                  ', pcognom1= ' || pcognom1 ||
                                  ', pcognom2= ' || pcognom2 ||
                                  ', pctipide= ' || pctipide ||
                                  ', pfnacimi =  ' || pfnacimi ||
                                  ', ptdomici =  ' || ptdomici ||
                                  ',pcpostal =  ' || pcpostal;
      vobject   VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Personas_Agentes';
      vnumerr   NUMBER := 0;
      terror    VARCHAR2(200) := 'Error recuperar personas';
      /*//ACC recuperar desde literales*/
      auxnom  VARCHAR2(2000);
      nerr    NUMBER;
      vsquery VARCHAR2(4000);
      vtab1   VARCHAR2(1000);
      vtab2   VARCHAR2(1000);
      vtab4   VARCHAR2(1000);
      vtab5   VARCHAR2(1000);
      vwhere  VARCHAR2(4000);
      vtab0   VARCHAR2(1000);
      vhpl    BOOLEAN := FALSE;
      /*//ACC recuperar desde literales*/
      /*//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);*/
      vpervisionpublica NUMBER; --Bug 29166/160004 - 29/11/2013 - AMC
      vfid              BOOLEAN := FALSE; --BUG 40927/228750 - 07/03/2016 - JAEG
   BEGIN
      /*Bug 29166/160004 - 29/11/2013 - AMC*/
      vpervisionpublica := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                             'PER_VISIONPUBLICA'),
                               0);

      IF nombre IS NOT NULL
      THEN
         nerr   := f_strstd(nombre, auxnom);
         vwhere := ' AND UPPER(p.tbuscar) LIKE UPPER (''' || '%' || auxnom || '%' ||
                   ''') ';
      END IF;

      /* Bug 36596 IGIL INI*/
      IF phospital IS NOT NULL
      THEN
         /*IF phospital = 'HPL' THEN*/
         vhpl  := TRUE;
         vtab4 := ', per_parpersonas ppa';
         vtab5 := ', estper_parpersonas ppa';
         /*END IF;*/
      END IF;

      /* Bug 36596 IGIL FIN*/
      IF numide IS NOT NULL
      THEN
         /*Bug 37437/212585 CJMR 25/08/2015 INI*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'BUSQUEDA_NIF_COMPLET'), 0) = 1
         THEN
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                 'NNUMIDE_SENSITIVE'), 1) = 1
            THEN
               vwhere := vwhere || ' AND p.nnumnif = ''' ||
                         ff_strstd(numide) || ''' '; -- BUG 38344/217178 - 10/11/2015 - ACL
            ELSE
               vwhere := vwhere || ' AND p.nnumnif = UPPER (''' ||
                         ff_strstd(numide) || ''') '; -- BUG 38344/217178 - 10/11/2015 - ACL
            END IF;
         ELSE
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                 'NNUMIDE_SENSITIVE'), 1) = 1
            THEN
               vwhere := vwhere || ' AND p.nnumnif LIKE ''' || '%' ||
                         ff_strstd(numide) || '%' || ''' '; -- BUG 38344/217178 - 10/11/2015 - ACL
            ELSE
               vwhere := vwhere || ' AND p.nnumnif LIKE UPPER (''' || '%' ||
                         ff_strstd(numide) || '%' || ''') '; -- BUG 38344/217178 - 10/11/2015 - ACL
            END IF;
         END IF;
         /*Bug 37437/212585 CJMR 25/08/2015 FIN*/
      END IF;

      IF nsip IS NOT NULL
      THEN
         vwhere := vwhere || 'AND UPPER(p.snip) = UPPER (''' || nsip ||
                   ''') ';
      END IF;

      IF pnom IS NOT NULL
      THEN
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*vwhere := vwhere || 'AND FF_STRSTD(p.tnombre) LIKE UPPER (''' || '%'*/
         /*          || ff_strstd(pnom) || '%' || ''') ';*/
         vwhere := vwhere || 'AND UPPER(p.tnombre) LIKE UPPER (''' || '%' ||
                   ff_strstd(pnom) || '%' || ''') ';
      END IF;

      IF pcognom1 IS NOT NULL
      THEN
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*vwhere := vwhere || 'AND FF_STRSTD(p.tapelli1) LIKE UPPER (''' || '%'*/
         /*          || ff_strstd(pcognom1) || '%' || ''') ';*/
         vwhere := vwhere || 'AND UPPER(p.tapelli1) LIKE UPPER (''' || '%' ||
                   ff_strstd(pcognom1) || '%' || ''') ';
      END IF;

      IF pcognom2 IS NOT NULL
      THEN
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*vwhere := vwhere || 'AND FF_STRSTD(p.tapelli2) LIKE UPPER (''' || '%'*/
         /*          || ff_strstd(pcognom2) || '%' || ''') ';*/
         vwhere := vwhere || 'AND UPPER(p.tapelli2) LIKE UPPER (''' || '%' ||
                   ff_strstd(pcognom2) || '%' || ''') ';
      END IF;

      IF pctipide IS NOT NULL
      THEN
         vwhere := vwhere || 'AND p.ctipide = ' || TO_CHAR(pctipide);
      END IF;

      IF pfnacimi IS NOT NULL
      THEN
         vwhere := vwhere || 'AND trunc(p.fnacimi) = ''' || pfnacimi || '''';
      END IF;

      /*      IF ptdomici IS NOT NULL THEN*/
      /*         vwhere := vwhere || ' AND nvl(FF_STRSTD(d.tdomici),''%'') LIKE UPPER ('''*/
      /*                   || '%'   -- BUG 19545 - 10/10/2011 - JMP - Se a?ade NVL*/
      /*                   || ff_strstd(ptdomici) || '%' || ''') ';*/
      /*      END IF;*/
      /*      IF pcpostal IS NOT NULL THEN*/
      /*         vwhere := vwhere || ' AND d.cpostal LIKE ''' || pcpostal || '''';*/
      /*      END IF;*/
      /*      IF ptdomici IS NOT NULL*/
      /*         OR pcpostal IS NOT NULL THEN*/
      /*         vtab1 :=*/
      /*            ', p.fnacimi, d.tdomici, d.cpostal FROM personas_agente p, per_direcciones d where p.sperson = d.sperson(+) and p.cagente = d.cagente(+) and  ';*/
      /*         -- BUG 19545 - 10/10/2011 - JMP - Se a?ade OUTER JOIN*/
      /*         vtab2 :=*/
      /*            ', p.fnacimi, d.tdomici, d.cpostal FROM estpersonas p, estper_direcciones d where p.sperson = d.sperson(+) and p.cagente = d.cagente(+) and ';*/
      /*         -- BUG 19545 - 10/10/2011 - JMP - Se a?ade OUTER JOIN*/
      /*         vtab0 := ', fnacimi, tdomici, cpostal ';*/
      /*      ELSE*/
      vtab1  := ' FROM personas_agente p, per_detper pdet ' || vtab4 ||
                ' where';
      vtab2  := ' FROM estpersonas p, estper_detper pdet ' || vtab5 ||
                ' where';
      vwhere := vwhere ||
                ' AND p.sperson = pdet.sperson AND p.cagente = pdet.cagente';

      /*      END IF;*/
      /* Bug 36596 IGIL INI*/
      IF vhpl = TRUE
      THEN
         vwhere := vwhere ||
                   ' AND ppa.cparam = ''PER_ES_HOSPITAL'' AND ppa.nvalpar = 1 AND ppa.sperson = p.sperson ';
      END IF;

      /* Bug 36596 IGIL FIN*/
      --INI BUG 40927/228750 - 07/03/2016 - JAEG
      IF pfideico IS NOT NULL
      THEN
         IF pfideico = 'FID'
         THEN
            vfid  := TRUE;
            vtab4 := ', per_parpersonas pr';
            vtab5 := ', estper_parpersonas pr';
         END IF;
      END IF;
      --
      IF vfid = TRUE
      THEN
         vwhere := vwhere ||
                   ' AND pr.cparam = ''PER_ES_FIDEICOMIENTE'' AND pr.nvalpar = 1 AND pr.sperson = p.sperson ';
      END IF;
      --FIN BUG 40927/228750 - 07/03/2016 - JAEG
      /*BUG 25859 -JDS 30/01/2013 INICI*/
      /*BUG10300-XVM-15/09/2009 inici*/
      vsquery := 'SELECT DISTINCT codi, coditablas, nnumnif, nombre, tocupacion ' ||
                 vtab0 || '
	            FROM (SELECT p.sperson codi, ''POL'' coditablas, pac_persona.F_FORMAT_NIF(p.nnumide,p.ctipide,p.sperson,''SEG'') nnumnif, p.tnombre || '' '' || p.tapelli nombre,
	            FF_DESCPROFES(pdet.cocupacion,PAC_MD_COMMON.F_Get_CXTIDIOMA(),PAC_MD_COMMON.F_GET_CXTEMPRESA()) tocupacion ' ||
                 vtab1 || '  not exists(select 1 from per_lopd pl, perlopd_personas pp where pp.sperson = p.sperson
	         AND pp.sperson = pl.sperson
	         AND pp.sperson = pdet.sperson
	         AND pl.norden = (select max(pll.norden) from per_lopd pll where pll.sperson = pl.sperson and pll.cagente = p.cagente)
	         AND pl.cestado = 2   /*dades bloquejades*/
	         AND pl.cagente = p.cagente )' ||
                 '  and NOT EXISTS(SELECT 1
	                             FROM estpersonas
	                             WHERE spereal = p.sperson
                                   AND sseguro = ' ||
                 psseguro || ')  ' || vwhere || '
	            union all
	            SELECT p.sperson codi, ''EST'' coditablas, pac_persona.F_FORMAT_NIF(p.nnumide,p.ctipide,p.sperson,''EST'') nnumnif, p.tnombre || '' '' || p.tapelli nombre,
	            FF_DESCPROFES(pdet.cocupacion,PAC_MD_COMMON.F_Get_CXTIDIOMA(),PAC_MD_COMMON.F_GET_CXTEMPRESA()) tocupacion ' ||
                 vtab2 || '  p.sseguro = ' || psseguro || ' ' || vwhere;

      /*Bug 29166/160004 - 29/11/2013 - AMC*/
      IF NVL(vpervisionpublica, 0) = 1
      THEN
         vsquery := vsquery ||
                    ' union all
	                    SELECT pdet.sperson codi, ''POL'' coditablas, pac_persona.f_format_nif(p.nnumide, p.ctipide, p.sperson,''SEG'') nnumnif,
	                    pdet.tnombre || '' '' || pdet.tapelli1 || '' '' || pdet.tapelli2 nombre,
	                    ff_descprofes(pdet.cocupacion,pac_md_common.f_get_cxtidioma(),pac_md_common.f_get_cxtempresa()) tocupacion
	                    FROM personas p, per_detper pdet, personas_publicas pp  ' ||
                    vtab4 || '
	                    WHERE pdet.sperson = p.sperson AND p.sperson = pp.sperson AND p.cagente = pdet.cagente
	                    AND  pdet.cagente in ( select cagente from redcomercial where cempres = f_empres)
	                    AND NOT EXISTS(SELECT 1 FROM estpersonas WHERE spereal = p.sperson
	                    AND sseguro = ' || psseguro || ') ' ||
                    vwhere;
      END IF;

      /*Fi Bug 29166/160004 - 29/11/2013 - AMC*/
      vsquery := vsquery || ' ORDER BY nombre ) ' ||
                 'where rownum <= NVL(f_parinstalacion_n(''N_MAX_REG''),100)';
      /*BUG10300-XVM-15/09/2009 fi*/
      /*BUG  25859 -JDS 30/01/2013 FI*/
      /* SBG 30/05/2008 INICI*/
      vnumerr := pac_md_log.f_log_consultas(vsquery,
                                            'PAC_MD_PERSONA.F_GET_PERSONAS',
                                            1, 1, mensajes);
      cur     := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      /* SBG 30/05/2008 FINAL*/
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas_agentes;

   /*************************************************************************
      Recupera la lista de personas contra el HOST que coinciden con los criterios de consulta
      param in numide    : numero documento
      param in nombre    : texto que incluye nombre + apellidos
      param in nsip      : identificador externo de persona, puede ser nulo
      param out mensajes : mensajes de error
      param in psseguro  : identificador interno de seguro, puede ser nulo
      param in pnom      : nombre de la persona, puede ser nulo
      param in pcognom1  : apellido 1 de la persona, puede ser nulo
      param in pcognom2  : apellido 2 de la persona, puede ser nulo
      param in pctipide  : tipo de documento identificativo, puede ser nulo
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_personas_host(numide   IN VARCHAR2,
                                nombre   IN VARCHAR2,
                                nsip     IN VARCHAR2 DEFAULT NULL,
                                mensajes IN OUT t_iax_mensajes,
                                psseguro IN NUMBER DEFAULT NULL,
                                /*JRH 04/2008 Se pasa el seguro*/
                                pnom       IN VARCHAR2 DEFAULT NULL,
                                pcognom1   IN VARCHAR2 DEFAULT NULL,
                                pcognom2   IN VARCHAR2 DEFAULT NULL,
                                pctipide   IN NUMBER DEFAULT NULL,
                                pomasdatos OUT NUMBER) RETURN SYS_REFCURSOR IS
      vsinterf   NUMBER;
      verror     NUMBER;
      cur        SYS_REFCURSOR;
      vobject    VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Personas_HOST';
      terror     VARCHAR2(200) := 'Error recuperar personas HOST';
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(2000) := 'numide= ' || numide || ', nombre= ' ||
                                   nombre || ', nsip= ' || nsip ||
                                   ', psseguro= ' || psseguro || ', pnom= ' || pnom ||
                                   ', pcognom1= ' || pcognom1 ||
                                   ', pcognom2= ' || pcognom2 ||
                                   ', pctipide= ' || pctipide;
      vomasdatos NUMBER(1);
      vquery     VARCHAR2(1000);
   BEGIN
      vpasexec := 1;
      verror   := pac_md_con.f_busqueda_persona(nsip, pctipide, numide,
                                                NVL(nombre, pnom), vsinterf,
                                                mensajes, pcognom1, pcognom2,
                                                pomasdatos);
      vpasexec := 2;

      IF verror <> 0
      THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      vquery   := ' and not exists(select 1 from per_lopd pl, perlopd_personas pp where tdocidentif = pp.nnumide
	         AND pp.sperson = pl.sperson
	         AND pl.cestado = 2   /*dades bloquejades*/
	         AND pl.cagente = ff_agente_cpervisio(pac_md_common.f_get_cxtagente, f_sysdate,
	                                              pac_md_common.f_get_cxtempresa)
	         and pl.norden = (select max(pll.norden) from per_lopd pll
	                            where pll.sperson = pl.sperson and pll.cagente = pl.cagente)
	                                                        )';
      vpasexec := 3;
      verror   := pac_md_log.f_log_consultas('select null codi, ''INT'' codiTablas ,tdocidentif nnumnif ,tdocidentif nnumide ,tnombre||'' ''||tapelli1||'' ''||tapelli2 nombre, sip snip,
	             ff_agente_cpervisio( pac_md_common.F_GET_CXTAGENTE, f_sysdate, pac_md_common.F_GET_CXTEMPRESA) CAGENTE,
	             FF_DESAGENTE(ff_agente_cpervisio( pac_md_common.F_GET_CXTAGENTE, f_sysdate, pac_md_common.F_GET_CXTEMPRESA))  TAGENTE' ||
                                             ' from INT_DATOS_PERSONA where sinterf = ' ||
                                             vsinterf || vquery,
                                             'PAC_MD_PERSONA.f_get_personas_host',
                                             1, 1, mensajes);
      cur      := pac_md_listvalores.f_opencursor('select null codi, ''INT'' codiTablas ,tdocidentif nnumnif ,tdocidentif nnumide ,tnombre||'' ''||tapelli1||'' ''||tapelli2 nombre, sip snip,
	             ff_agente_cpervisio( pac_md_common.F_GET_CXTAGENTE, f_sysdate, pac_md_common.F_GET_CXTEMPRESA) CAGENTE,
	             FF_DESAGENTE(ff_agente_cpervisio( pac_md_common.F_GET_CXTAGENTE, f_sysdate, pac_md_common.F_GET_CXTEMPRESA))  TAGENTE' ||
                                                  ' from INT_DATOS_PERSONA where sinterf = ' ||
                                                  vsinterf || vquery,
                                                  mensajes);
      vpasexec := 4;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END;

   /*************************************************************************
   *************************************************************************/
   FUNCTION f_get_ccc_host(psperson IN VARCHAR2,
                           pnsip    IN VARCHAR2,
                           pcagente IN NUMBER,
                           porigen  IN VARCHAR2 DEFAULT 'EST',
                           mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      vsinterf NUMBER;
      verror   NUMBER;
      cur      SYS_REFCURSOR;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_CCC_HOST';
      terror   VARCHAR2(200) := 'Error recuperar personas HOST';
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := ' psperson= ' || psperson;
      vsquery  VARCHAR2(2000);
   BEGIN
      vpasexec := 1;
      verror   := pac_md_con.f_cuentas_persona(psperson, NULL, NULL, NULL,
                                               porigen, vsinterf, mensajes);
      vpasexec := 2;

      IF verror <> 0
      THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      vpasexec := 3;

      IF porigen = 'EST'
      THEN
         pac_con.traspaso_tablas_ccc_host(vsinterf, psperson, pcagente,
                                          porigen);
         cur := pac_md_produccion.f_get_tomadorccc(psperson, mensajes);
      ELSE
         /*(JAS) Estic en mode real. No traspaso les comptes a les taules reals ni a les taules EST.*/
         /*Deixo les comptes a les taules INT i treballo diractament des d'alla*/
         vsquery := 'SELECT PER.sperson, INT.CBANCAR,PAC_MD_COMMON.F_FormatCCC(INT.CTIPBAN,INT.CBANCAR) Tcbancar, INT.CTIPBAN, PER.SNIP
	                    FROM INT_DATOS_CUENTA INT ,PERSONAS PER
                        WHERE INT.SINTERF = ' ||
                    vsinterf || '
	                    AND PER.SPERSON =' || psperson;
         verror  := pac_md_log.f_log_consultas(vsquery,
                                               'PAC_MD_PERSONA.f_get_ccc_host',
                                               1, 1, mensajes);
         cur     := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      END IF;

      vpasexec := 4;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Traspasa a las EST si es necesario desde las tablas reales
      param out mensajes  : mensajes de error
      return              : Nulo si hay un error
   *************************************************************************/
   FUNCTION f_traspasar_errores_mensajes(errores IN t_ob_error)
      RETURN t_iax_mensajes IS
      vnumerr     NUMBER(8) := 0;
      mensajesdst t_iax_mensajes;
      errind      ob_error;
      msg         ob_iax_mensajes;
      vpasexec    NUMBER(8) := 1;
      vparam      VARCHAR2(500) := ' ';
      vobject     VARCHAR2(200) := 'PAC_MD_PERSONA.f_traspasar_errores_mensajes';
   BEGIN
      mensajesdst := t_iax_mensajes();

      IF errores IS NOT NULL
      THEN
         IF errores.count > 0
         THEN
            FOR vmj IN errores.first .. errores.last
            LOOP
               IF errores.exists(vmj)
               THEN
                  errind := errores(vmj);
                  mensajesdst.extend;
                  mensajesdst(mensajesdst.last) := ob_iax_mensajes();
                  mensajesdst(mensajesdst.last).tiperror := 1;
                  mensajesdst(mensajesdst.last).cerror := errind.cerror;
                  mensajesdst(mensajesdst.last).terror := errind.terror;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN mensajesdst;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN mensajesdst;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN mensajesdst;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN mensajesdst;
   END f_traspasar_errores_mensajes;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Traspasa a las EST si es necesario desde las tablas reales
      param out mensajes  : mensajes de error
      return              : 0 o codigo error
   *************************************************************************/
   FUNCTION f_traspasapersona(psperson IN NUMBER,
                              /* JLB - I 6353*/
                              pnsip IN VARCHAR2,
                              /* JLB - F 6353*/
                              pcagente     IN OUT NUMBER,
                              pcoditabla   IN VARCHAR2,
                              psperson_out OUT NUMBER,
                              psseguro     IN NUMBER,
                              p_modo       IN VARCHAR2, /* Bug 11948.*/
                              pmensapotup  OUT VARCHAR2,
                              mensajes     OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vnumerr2 NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente: ' || pcagente ||
                                ' - pcodiTabla: ' || pcoditabla ||
                                ' - psip:' || pnsip || ' - sseguro:' ||
                                psseguro;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_TraspasaPersona';
      /*    JLB - I 6353*/
      vsinterf NUMBER;
      /*    JLB - F 6353*/
      vcagente     NUMBER;
      vfnacimi     VARCHAR2(50);
      vtdocidentif VARCHAR2(50);
      vsip         VARCHAR2(50);
      vsexo        NUMBER;
      wfnacimi     VARCHAR2(50);
      wtdocidentif VARCHAR2(50);
      wsexo        NUMBER;
      vtexto       VARCHAR2(500);
      vtexto1      VARCHAR2(500);
      vtexto2      VARCHAR2(500);
      vtexto3      VARCHAR2(100);
      vtexto4      VARCHAR2(100);
      vtexto5      VARCHAR2(100);
      vtexto6      VARCHAR2(100);
      vtexto7      VARCHAR2(100);
      vtexto8      VARCHAR2(100);
      tsexo_host   VARCHAR2(20);
      tsexo_axis   VARCHAR2(20);
      errores      t_ob_error;
      /* ini Bug 0012675 - 23/03/2010 - JAS*/
      vsproduc      productos.sproduc%TYPE;
      vsperson_fija per_direcciones.sperson%TYPE;
      vcdomici_fija per_direcciones.cdomici%TYPE;
      vtparam_dir   VARCHAR2(100);
      /* fin Bug 0012675 - 23/03/2010 - JAS*/
      /*INICIO DCT -04/11/2015*/
      vctipide NUMBER;
      /*FIN DCT -04/11/2015*/
   BEGIN
      vpasexec := 1;

      IF psperson IS NULL
        /*    JLB - I 6353*/
         AND
         pnsip IS NULL
      /*    JLB - F 6353*/
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcoditabla = 'EST'
      THEN
         psperson_out := psperson;

         --INI BUG CONF-349 - 17/09/2016 - JAEG
         IF pac_iax_param.f_parinstalacion_nn(p_cparam => 'PERSONA_ONLINE',
                                              mensajes => mensajes) = 1 AND
            p_modo = 'POL'
         THEN
            --
            pac_persona.traspaso_tablas_estper(psperson => psperson,
                                               pcagente => pcagente,
                                               pcempres => f_empres);
            --
            psperson_out := pac_persona.f_sperson_spereal(psperson);
            --
         END IF;
         --FIN BUG CONF-349 - 17/09/2016 - JAEG

         /*    JLB - I 6353*/
         vpasexec := 5;
      ELSIF pcoditabla = 'INT'
      THEN
         vnumerr  := pac_md_con.f_datos_persona(pnsip, vcagente,
                                                /*retorna el cagente de la persona recuperada*/
                                                vsinterf, mensajes);
         vpasexec := 7;

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000608);
            /* error interno.*/
            RAISE e_object_error;
         END IF;

         vpasexec := 9;

         IF p_modo = 'POL'
         THEN
            vnumerr  := pac_con.f_get_datosper_host(vsinterf, vsip, vfnacimi,
                                                    vtdocidentif, vsexo,
                                                    vctipide);
            vpasexec := 11;
            vnumerr  := pac_persona.f_existe_persona(pac_md_common.f_get_cxtempresa,
                                                     vtdocidentif, vsexo,
                                                     vfnacimi, psperson_out,
                                                     vsip, NULL, vctipide);
            vpasexec := 13;

            IF psperson_out IS NOT NULL
            THEN
               IF pcagente IS NULL AND
                  vcagente IS NULL
               THEN
                  BEGIN
                     SELECT pd.cagente
                       INTO pcagente
                       FROM per_personas pp,
                            per_detper   pd
                      WHERE pp.sperson = psperson_out
                        AND pp.sperson = pd.sperson
                        AND pd.cagente = pac_md_common.f_get_cxtagente;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;
               ELSIF pcagente IS NULL
               THEN
                  pcagente := vcagente;
               END IF;

               RETURN 0;
            END IF;
         END IF;

         vpasexec := 15;

         IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                          'ERRSIDIFHOSTAXIS') = 1
         THEN
            vpasexec := 17;
            /*Recupero datos persona HOST*/
            vnumerr  := pac_con.f_get_datosper_host(vsinterf, vsip, vfnacimi,
                                                    vtdocidentif, vsexo,
                                                    vctipide);
            vpasexec := 19;
            /*Recupero datos BB.DD*/
            vnumerr2 := pac_persona.f_get_datosper_axis(vsip, wfnacimi,
                                                        wtdocidentif, wsexo);

            IF vnumerr = 0
            THEN
               IF (vfnacimi <> wfnacimi) OR
                  (vtdocidentif <> wtdocidentif) OR
                  (vsexo <> wsexo)
               THEN
                  tsexo_host  := ff_desvalorfijo(11,
                                                 pac_md_common.f_get_cxtidioma,
                                                 vsexo);
                  tsexo_axis  := ff_desvalorfijo(11,
                                                 pac_md_common.f_get_cxtidioma,
                                                 wsexo);
                  vtexto      := f_axis_literales(806298,
                                                  pac_md_common.f_get_cxtidioma) ||
                                 chr(13);
                  vtexto2     := f_axis_literales(806299,
                                                  pac_md_common.f_get_cxtidioma) ||
                                 chr(13);
                  vtexto3     := f_axis_literales(9000643,
                                                  pac_md_common.f_get_cxtidioma);
                  vtexto4     := f_axis_literales(9000644,
                                                  pac_md_common.f_get_cxtidioma);
                  vtexto5     := f_axis_literales(9000645,
                                                  pac_md_common.f_get_cxtidioma);
                  vtexto6     := f_axis_literales(9000646,
                                                  pac_md_common.f_get_cxtidioma);
                  vtexto7     := f_axis_literales(9000647,
                                                  pac_md_common.f_get_cxtidioma);
                  vtexto8     := f_axis_literales(9000648,
                                                  pac_md_common.f_get_cxtidioma);
                  vtexto1     := vtexto3 || vfnacimi || ' ' || vtexto4 ||
                                 wfnacimi || chr(13) || vtexto5 ||
                                 tsexo_host || ' ' || vtexto7 || tsexo_axis ||
                                 chr(13) || vtexto6 || vtdocidentif || ' ' ||
                                 vtexto8 || wtdocidentif || chr(13);
                  pmensapotup := vtexto || vtexto1 || vtexto2;
                  RETURN 1;
               END IF;
            ELSIF vnumerr <> 2 OR
                  vnumerr2 <> 2
            THEN
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 31;
         /*si la persona recupera de host tiene agente asociado, se pone ese agente, sino el pasado por parametro.*/
         errores  := pac_con.traspaso_tablas_per_host(vsinterf, psperson_out,
                                                      psseguro,
                                                      NVL(vcagente, pcagente),
                                                      pac_md_common.f_get_cxtidioma,
                                                      pac_md_common.f_get_cxtempresa,
                                                      p_modo /* bug 11948*/);
         vpasexec := 33;
         /*JRB*/
         mensajes := f_traspasar_errores_mensajes(errores);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RAISE e_object_error;
            END IF;
         END IF;
         /*    JLB - F 6353*/
      ELSE
         /* Significa que la persona esta solo en las tablas reales y lo que hacemos es*/
         /* traspasar sus datos a las tablas EST.*/
         vpasexec := 39;
         pac_persona.traspaso_tablas_per(psperson, psperson_out, psseguro,
                                         pcagente);
      END IF;

      vpasexec := 41;

      /*ini Bug 0012675 - 23/03/2010 - JAS*/
      /*Comprovem si el producte te parametritzada una adrea?a fixe per la contractacio*/
      IF pac_iax_produccion.poliza IS NOT NULL AND
         pac_iax_produccion.poliza.det_poliza IS NOT NULL AND
         pcoditabla IN ('INT', 'POL')
      THEN
         vpasexec    := 43;
         vsproduc    := pac_iax_produccion.poliza.det_poliza.sproduc;
         vtparam_dir := pac_parametros.f_parproducto_t(vsproduc,
                                                       'DIR_FIJA_CONTR');
         vpasexec    := 45;

         IF vtparam_dir IS NOT NULL
         THEN
            IF pcoditabla = 'INT'
            THEN
               vcagente := NVL(vcagente, pcagente);
            ELSE
               vcagente := pcagente;
            END IF;

            vpasexec := 47;

            /*Recuperem l'adrea?a fixe de contractacio definida pel producte (sperson + cdomici)*/
            SELECT SUBSTR(vtparam_dir, 1, INSTR(vtparam_dir, '-') - 1) sperson,
                   SUBSTR(vtparam_dir, INSTR(vtparam_dir, '-') + 1) tdomici
              INTO vsperson_fija,
                   vcdomici_fija
              FROM dual;

            vpasexec := 49;
            vnumerr  := pac_persona.f_traspaso_direccion_fija(psperson_out,
                                                              vcagente,
                                                              pac_md_common.f_get_cxtidioma,
                                                              vsperson_fija,
                                                              vcdomici_fija,
                                                              1);

            IF vnumerr <> 0
            THEN
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      /*fin Bug 0012675 - 23/03/2010 - JAS*/
      vpasexec := 51;

      IF pac_md_log.f_log_consultas('psperson = ' || psperson ||
                                    ', psperson_out = ' || psperson_out,
                                    'PAC_MD_PERSONA.F_TRASPASAPERSONA', 2, 1,
                                    mensajes) <> 0
      THEN
         RETURN 1;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_traspasapersona;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Valida la persona
      param out mensajes  : mensajes de error
      return              : 0 o codigo error
   *************************************************************************/
   FUNCTION f_validapersona(psperson    IN NUMBER,
                            pidioma_usu IN NUMBER,
                            ctipper     IN NUMBER, /* tipo de persona (fisica o juridica)*/
                            ctipide     IN NUMBER, /* tipo de identificacion de persona*/
                            nnumide     IN VARCHAR2,
                            /* Numero identificativo de la persona.*/
                            csexper       IN NUMBER, /* sexo de la pesona.*/
                            fnacimi       IN DATE, /* Fecha de nacimiento de la persona*/
                            snip          IN VARCHAR2, /* snip*/
                            cestper       IN NUMBER,
                            fjubila       IN DATE,
                            cmutualista   IN NUMBER,
                            fdefunc       IN DATE,
                            nordide       IN NUMBER,
                            cidioma       IN NUMBER, /*  Codigo idioma*/
                            tapelli1      IN VARCHAR2, /*      Primer apellido*/
                            tapelli2      IN VARCHAR2, /* Segundo apellido*/
                            tnombre       IN VARCHAR2, /*    Nombre de la persona*/
                            tsiglas       IN VARCHAR2, /*      Siglas persona juridica*/
                            cprofes       IN VARCHAR2, /*Codigo profesion*/
                            cestciv       IN NUMBER, /*Codigo estado civil. VALOR FIJO = 12*/
                            cpais         IN NUMBER, /* Codigo pais de residencia*/
                            cnacionalidad IN NUMBER,
                            ptablas       IN VARCHAR2,
                            ptnombre1     IN VARCHAR2,
                            ptnombre2     IN VARCHAR2,
                            pcocupacion   IN VARCHAR2, /* Bug 25456/133727 - 16/01/2013 - AMC*/
                            mensajes      OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(4000) := 'parametros -  psperson: ' || psperson ||
                                 ' pidioma_usu   : ' || pidioma_usu ||
                                 ' ctipper       :' || ctipper ||
                                 ' ctipide       :' || ctipide ||
                                 ' nnumide       :' || nnumide ||
                                 ' csexper       :' || csexper ||
                                 ' fnacimi       :' || fnacimi ||
                                 ' snip          :' || snip ||
                                 ' cestper       :' || cestper ||
                                 ' fjubila       :' || fjubila ||
                                 ' cmutualista   :' || cmutualista ||
                                 ' fdefunc       :' || fdefunc ||
                                 ' nordide       :' || nordide ||
                                 ' cidioma       :' || cidioma ||
                                 ' tapelli1      :' || tapelli1 ||
                                 ' tapelli2      :' || tapelli2 ||
                                 ' tnombre       :' || tnombre ||
                                 ' tsiglas       :' || tsiglas ||
                                 ' cprofes       :' || cprofes ||
                                 ' cestciv       :' || cestciv ||
                                 ' cpais         :' || cpais ||
                                 ' cnacionalidad :' || cnacionalidad ||
                                 ' ptnombre1         :' || ptnombre1 ||
                                 ' ptnombre2 :' || ptnombre2 ||
                                 ' pcocupacion   :' || pcocupacion;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_validaPersona';
      errores  t_ob_error;
   BEGIN
      /* bug 22626 -- Error de buffer por que se supera 500 tab_errr.tdescrip*/
      vparam := SUBSTR(vparam, 0, 500);
      pac_persona.p_validapersona(psperson, pidioma_usu, ctipper,
                                   /* tipo de persona (fisica o juridica)*/
                                  ctipide,
                                   /* tipo de identificacion de persona*/
                                  nnumide,
                                   /* Numero identificativo de la persona.*/
                                  csexper, /* sexo de la pesona.*/ fnacimi,
                                   /* Fecha de nacimiento de la persona*/
                                  snip, /* snip*/ cestper, fjubila,
                                  cmutualista, fdefunc, nordide, cidioma,
                                   /*   Codigo idioma*/ tapelli1,
                                   /*      Primer apellido*/ tapelli2,
                                   /* Segundo apellido*/ tnombre,
                                   /*    Nombre de la persona*/ tsiglas,
                                   /*     Siglas persona juridica*/ cprofes,
                                   /*Codigo profesion*/ cestciv,
                                   /*Codigo estado civil. VALOR FIJO = 12*/
                                  cpais, /* Codigo pais de residencia*/
                                  ptablas, pac_md_common.f_get_cxtempresa,
                                  ptnombre1, ptnombre2, errores, pcocupacion
                                   /* Bug 25456/133727 - 16/01/2013 - AMC*/);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      /*Solo validamos la nacionalidad si viene informada*/
      IF cnacionalidad IS NOT NULL
      THEN
         vnumerr := pac_persona.f_validanacionalidad(ctipper, cnacionalidad);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_validapersona;

   /*************************************************************************
      Valida el nif
      param out mensajes  : mensajes de error
      return              : 0 o codigo error
   *************************************************************************/
   FUNCTION f_validanif(pnnumide IN per_personas.nnumide%TYPE,
                        pctipide IN per_personas.ctipide%TYPE,
                        csexper  IN per_personas.csexper%TYPE,
                        /* -- sexo de la pesona.*/
                        fnacimi IN per_personas.fnacimi%TYPE,
                        /* -- Fecha de nacimiento de la persona*/
                        mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - pnnumide: ' || pnnumide ||
                                ' - pctipide: ' || pctipide;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_validaNIF';
      errores  t_ob_error;
   BEGIN
      vnumerr := pac_persona.f_validanif(pnnumide, pctipide, csexper,
                                         fnacimi);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_validanif;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Graba los datos de  persona en las EST
      param out mensajes  : mensajes de error
      return              : 0 o codigo error
   *************************************************************************/
   FUNCTION f_set_persona(psseguro IN NUMBER,
                          psperson IN OUT NUMBER,
                          pspereal IN NUMBER,
                          pcagente IN OUT  NUMBER,
                          ctipper  IN NUMBER,
                          /* ??A? tipo de persona (fisica o juridica)*/
                          ctipide IN NUMBER, /* ??A? tipo de identificacion de persona*/
                          nnumide IN VARCHAR2,
                          /*  -- Numero identificativo de la persona.*/
                          csexper     IN NUMBER, /*     -- sexo de la pesona.*/
                          fnacimi     IN DATE, /*   -- Fecha de nacimiento de la persona*/
                          snip        IN VARCHAR2, /*  -- snip*/
                          cestper     IN NUMBER,
                          fjubila     IN DATE,
                          cmutualista IN NUMBER,
                          fdefunc     IN DATE,
                          nordide     IN NUMBER,
                          cidioma     IN NUMBER, /*-      Codigo idioma*/
                          tapelli1    IN VARCHAR2, /*      Primer apellido*/
                          tapelli2    IN VARCHAR2, /*      Segundo apellido*/
                          tnombre     IN VARCHAR2, /*     Nombre de la persona*/
                          tsiglas     IN VARCHAR2, /*     Siglas persona juridica*/
                          cprofes     IN VARCHAR2, /*     Codigo profesion*/
                          cestciv     IN NUMBER, /* Codigo estado civil. VALOR FIJO = 12*/
                          cpais       IN NUMBER, /*     Codigo pais de residencia*/
                          ptablas     IN VARCHAR2,
                          pswpubli    IN NUMBER,
                          ppduplicada IN NUMBER,
                          ptnombre1   IN VARCHAR2,
                          ptnombre2   IN VARCHAR2,
                          pswrut      IN NUMBER,
                          pcocupacion IN VARCHAR2, /* Bug 25456/133727 - 16/01/2013 - AMC*/
						  /* Cambios para solicitudes múltiples : Start */
                          pTipoosc IN NUMBER,
                          pCIIU IN NUMBER,
                          pSFINANCI IN NUMBER,
                          pFConsti IN DATE,
                          pCONTACTOS_PER IN T_IAX_CONTACTOS_PER,
                          pDIRECCIONS_PER IN T_IAX_DIRECCIONES,
                          pNacionalidad IN NUMBER,
                          pDigitoide IN NUMBER,
						  /* Cambios para solicitudes múltiples : End */
                          mensajes    IN OUT t_iax_mensajes
						  /* CAMBIOS De IAXIS-4538 : Start */
						  ,pfefecto IN DATE, 
                          pcregfiscal IN NUMBER, 
                          pctipiva    IN NUMBER,  
                          pIMPUETOS_PER IN T_IAX_PROF_IMPUESTOS 
						  /* CAMBIOS De IAXIS-4538 : End */
						) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
	  /* Cambios para solicitudes múltiples : Start */
	  number_TELEFO_FIJO  number;
      number_TELEFO_MOVIL number;
      number_FAX          number;
      control             number;
	  /* Cambios para solicitudes múltiples : End */
      vparam   VARCHAR2(2000) := 'parametros -  psperson: ' || psperson ||
                                 '  psseguro     :' || psseguro ||
                                 '  psperson     :' || psperson ||
                                 '  pspereal     :' || pspereal ||
                                 '  pcagente     :' || pcagente ||
                                 '  ctipper      :' || ctipper ||
                                 '  ctipide      :' || ctipide ||
                                 '  nnumide      :' || nnumide ||
                                 '  csexper      :' || csexper ||
                                 '  fnacimi      :' || fnacimi ||
                                 '  snip         :' || snip ||
                                 '  cestper      :' || cestper ||
                                 '  fjubila      :' || fjubila ||
                                 '  cmutualista  :' || cmutualista ||
                                 '  fdefunc      :' || fdefunc ||
                                 '  nordide      :' || nordide ||
                                 '  cidioma      :' || cidioma
                                /*||'  tapelli1     :'||tapelli1
                                  ||'  tapelli2     :'||tapelli2
                                  ||'  tnombre      :'||tnombre      */
                                 || '  tsiglas      :' || tsiglas ||
                                 '  cprofes      :' || cprofes ||
                                 '  cestciv      :' || cestciv ||
                                 '  cpais        :' || cpais ||
                                 '  tnombre1     :' || ptnombre1 ||
                                 ' tnombre2      :' || ptnombre2 ||
                                 '  ptablas      :' || ptablas ||
                                 ' pcocupacion :' || pcocupacion
								 /* Cambios para solicitudes múltiples : Start */
								 ||' pTipoosc      :' || pTipoosc
                                 ||' pCIIU         :' || pCIIU
                                 ||' pSFINANCI     :' || pSFINANCI
                                 ||' pNacionalidad   :' || pNacionalidad
                                 ||' pDigitoide      :' || pDigitoide
								 /* Cambios para solicitudes múltiples : End */
								 /* CAMBIOS De IAXIS-4538 : Start */
								 || 'pfefecto       :'|| pfefecto
                                 || 'pcregfiscal    :'|| pcregfiscal
                                 || 'pctipiva       :'|| pctipiva
								 /* CAMBIOS De IAXIS-4538 : End */
								 ;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Set_Persona';
      errores  t_ob_error;
      wnnumide per_personas.nnumide%TYPE; /* BUG 26968/0155105 - FAL - 15/10/2013*/
--ini 1554 ces
      nFLAG number(1):=1;
--end 1554 ces
   BEGIN
--ini 1554 ces
      IF PSPERSON IS NULL THEN
        nFLAG := 0; --INSERT
      END IF;
--end 1554 ces

      wnnumide := pac_persona.f_desformat_nif(nnumide, ctipide); /* BUG 26968/0155105 - FAL - 15/10/2013*/
      pac_persona.p_validapersona(psperson, pac_md_common.f_get_cxtidioma(),
                                  ctipper,
                                   /* tipo de persona (fisica o juridica)*/
                                  ctipide,
                                   /* tipo de identificacion de persona*/
                                  wnnumide,
                                   /* Numero identificativo de la persona.*/
                                  csexper, /* sexo de la pesona.*/ fnacimi,
                                   /* Fecha de nacimiento de la persona*/
                                  snip, /* snip*/ cestper, fjubila,
                                  cmutualista, fdefunc, nordide, cidioma,
                                   /*   Codigo idioma*/ tapelli1,
                                   /*      Primer apellido*/ tapelli2,
                                   /* Segundo apellido*/ tnombre,
                                   /*    Nombre de la persona*/ tsiglas,
                                   /*     Siglas persona juridica*/ cprofes,
                                   /*Codigo profesion*/ cestciv,
                                   /*Codigo estado civil. VALOR FIJO = 12*/
                                  cpais, /* Codigo pais de residencia*/
                                  ptablas, pac_md_common.f_get_cxtempresa,
                                  ptnombre1, ptnombre2, errores, pcocupacion
                                   /* Bug 25456/133727 - 16/01/2013 - AMC*/);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF mensajes IS NOT NULL
      THEN
        IF mensajes.count > 0
         THEN
            RETURN 1;
        --INI - CES - 12/04/2019  Es necesario el ELSIF para modificar el encabezado de personas
		ELSIF psperson IS NULL THEN
		--END - CES - 12/04/2019
		 /* Cambios para solicitudes múltiples : Start */
        if pDIRECCIONS_PER is not null then
           FOR I IN PDIRECCIONS_PER.FIRST .. PDIRECCIONS_PER.LAST LOOP
              vnumerr := pac_propio.f_valdireccion(PDIRECCIONS_PER(I).cviavp,PDIRECCIONS_PER(I).tnomvia,PDIRECCIONS_PER(I).cdet1ia,
                                                   PDIRECCIONS_PER(I).tnum1ia,PDIRECCIONS_PER(I).cdet2ia,PDIRECCIONS_PER(I).tnum2ia,
                                                   PDIRECCIONS_PER(I).cdet3ia,PDIRECCIONS_PER(I).tnum3ia,PDIRECCIONS_PER(I).nnumvia,
                                                   PDIRECCIONS_PER(I).TCOMPLE
                                                   );
              if vnumerr <> 0 then
                   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                   RAISE e_object_error;
              end if;
           end loop;

            FOR I IN PDIRECCIONS_PER.FIRST .. PDIRECCIONS_PER.LAST LOOP
                 vnumerr := f_valida_direccion(psperson, pcagente, PDIRECCIONS_PER(I).ctipdir,
                                               PDIRECCIONS_PER(I).csiglas, PDIRECCIONS_PER(I).tnomvia, PDIRECCIONS_PER(I).nnumvia, PDIRECCIONS_PER(I).TCOMPLE,
                                               PDIRECCIONS_PER(I).cpostal, PDIRECCIONS_PER(I).cpoblac, PDIRECCIONS_PER(I).cprovin, PDIRECCIONS_PER(I).cpais,
                                               mensajes);
                if vnumerr <> 0 then
                   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                   RAISE e_object_error;
                end if;
            end loop;
        end if; -- Direction

        IF PCONTACTOS_PER IS NOT NULL THEN
              FOR I IN pCONTACTOS_PER.FIRST .. pCONTACTOS_PER.LAST LOOP
                 IF PCONTACTOS_PER(I).TELEFO_FIJO is not null THEN
                    BEGIN
                        number_TELEFO_FIJO := TO_NUMBER(PCONTACTOS_PER(I).TELEFO_FIJO);
                    EXCEPTION
                       WHEN OTHERS THEN
                          RAISE e_object_error;
                    END;
                 END IF;
                 IF PCONTACTOS_PER(I).TELEFO_MOVIL is not null then
                    BEGIN
                        number_TELEFO_MOVIL := TO_NUMBER(PCONTACTOS_PER(I).TELEFO_MOVIL);
                    EXCEPTION
                       WHEN OTHERS THEN
                          RAISE e_object_error;
                    END;
                 END IF;
                 IF PCONTACTOS_PER(I).FAX is not null then
                    BEGIN
                       number_FAX := TO_NUMBER(PCONTACTOS_PER(I).FAX);
                    EXCEPTION
                       WHEN OTHERS THEN
                          RAISE e_object_error;
                    END;
                 END IF;
                 IF CTIPPER <> 1 THEN
                   IF PCONTACTOS_PER(I).CORREO_ELECTRANICO is not null THEN
                       SELECT DECODE(REGEXP_SUBSTR(REGEXP_REPLACE(PCONTACTOS_PER(I).CORREO_ELECTRANICO, '^http[s]?://(www\.)?|^www\.', '', 1), '\w+(\.\w+)+'),
                                NULL, 0,1)
                       INTO control
                       FROM DUAL;

                     IF control = 0 THEN
                        RAISE e_object_error;
                     END IF;
                   END IF;
                 END IF;
              end loop;
         end if;  -- Contacto
		/* Cambios para solicitudes múltiples : End */
         --INI - CES - 12/04/2019
         END IF;
      END IF;
      --END - CES - 12/04/2019
        /* Start For IAXIS-4728 -- PK -- 09/07/2019 */
        IF TRUNC(pfefecto) < TRUNC(SYSDATE) THEN
            RAISE e_param_error;
        END IF;
        /* End For IAXIS-4728 -- PK -- 09/07/2019 */
      errores  := pac_persona.f_set_persona(pac_md_common.f_get_cxtidioma(),
                                            psseguro, psperson, pspereal,
                                            pcagente, ctipper, ctipide,
                                            wnnumide, csexper, fnacimi, snip,
                                            cestper, fjubila, cmutualista,
                                            fdefunc, nordide, cidioma,
                                            tapelli1, tapelli2, tnombre,
                                            tsiglas, cprofes, cestciv, cpais,
                                            pac_md_common.f_get_cxtempresa,
                                            ptablas, pswpubli, ptnombre1,
                                            ptnombre2, pswrut, pcocupacion
                                             /* Bug 25456/133727 - 16/01/2013 - AMC*/
											/* Cambios para solicitudes múltiples : Start */
											 ,pTipoosc,pCIIU,pSFINANCI,pFConsti,pCONTACTOS_PER,pDIRECCIONS_PER,pNacionalidad,pDigitoide
											/* Cambios para solicitudes múltiples : End */
											/* CAMBIOS De IAXIS-4538 : Start */
											,pfefecto, 
                                             pcregfiscal, 
                                             pctipiva, 
                                             pIMPUETOS_PER 
											/* CAMBIOS De IAXIS-4538 : End */
											 );
      mensajes := f_traspasar_errores_mensajes(errores);

      IF mensajes IS NOT NULL
      THEN
	   /* Cambios para enviar error : start */
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
           END IF;
--ini 1554 ces
	/* Cambios de  tarea IAXIS-13044 : start */
	/*
     IF NFLAG = 0 THEN
      PAC_CONVIVENCIA.P_SEND_DATA(PSPERSON,  nFLAG, NULL );
     END IF;
	 */
	/* Cambios de  tarea IAXIS-13044 : end */
--end 1554 ces
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 89906343,  /* For IAXIS-4728 -- PK -- 09/07/2019 */
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_persona;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
      param out mensajes  : mensajes de error
      return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_persona(psperson IN NUMBER,
                          pcagente IN NUMBER,
                          mensajes OUT t_iax_mensajes,
                          ptablas  IN VARCHAR2) RETURN ob_iax_personas IS
      vnumerr NUMBER(8) := 0;
      squery  VARCHAR(2000);
      cur     SYS_REFCURSOR;
      /* personas   t_iax_personas  := t_iax_personas ();*/
      persona  ob_iax_personas := ob_iax_personas();
      vidioma  NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente: ' || pcagente || ' ptablas: ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Persona';
      objpers  ob_iax_personas;
      numpers  NUMBER;
      numerr   NUMBER;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      IF ptablas = 'EST'
      THEN
         SELECT COUNT(*)
           INTO numpers
           FROM estper_personas
          WHERE sperson = psperson;
          

         vpasexec := 0;

         IF numpers <> 1
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         vpasexec := 3;
         /* Bug 25456/133727 - 16/01/2013 - AMC*/
         squery := 'select pdet.tapelli1, pdet.tapelli2, pdet.tnombre, pdet.tnombre1, pdet.tnombre2, pdet.cestciv, p.nordide, p.ctipper, p.ctipide,' ||
                   ' ff_desvalorfijo (672, PAC_MD_COMMON.F_Get_CXTIDIOMA(), p.ctipide) ttipide,' ||
                   ' p.nnumide, p.fnacimi, p.csexper,' ||
                   ' ff_desvalorfijo (11, PAC_MD_COMMON.F_Get_CXTIDIOMA(), p.csexper) tsexper,' ||
                   ' p.cestper, ff_desvalorfijo (13, PAC_MD_COMMON.F_Get_CXTIDIOMA(), p.cestper) testper,' ||
                   ' p.fjubila, p.fdefunc, f_user, p.fmovimi, p.cmutualista, pdet.cidioma,' ||
                   ' p.swpubli, p.spereal, pdet.cprofes,' ||
                   ' FF_DESCPROFES(pdet.cprofes,PAC_MD_COMMON.F_Get_CXTIDIOMA(),PAC_MD_COMMON.F_GET_CXTEMPRESA()) tprofes,' ||
                   ' pdet.cpais, (select max(pa.tpais)' ||
                   ' from despaises pa where pa.cpais=pdet.cpais' ||
                   ' and pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA()) tpais, pdet.tsiglas, p.snip' ||
                   ' ,pdet.tnombre1, pdet.tnombre2, pdet.cestciv, ff_desvalorfijo(12,PAC_MD_COMMON.F_Get_CXTIDIOMA(),pdet.cestciv), p.TDIGITOIDE, '
                  /*Bug.: 18948*/
                   || ' pdet.cocupacion,' ||
                   ' FF_DESCPROFES(pdet.cocupacion,PAC_MD_COMMON.F_Get_CXTIDIOMA(),PAC_MD_COMMON.F_GET_CXTEMPRESA()) tocupacion,' ||
                  ' (select f.CCIIU from per_ciiu pc inner join fin_general f on pc.cciiu = f.cciiu where pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() and  f.sperson = p.spereal) as cciiu,' ||
                   ' (select pc.TCIIU from per_ciiu pc inner join fin_general f on pc.cciiu = f.cciiu where pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() and  f.sperson = p.spereal) as dciiu ' ||
                   ' from estper_personas p, estper_detper pdet where p.sperson = ' ||
                   psperson || ' and p.sperson = pdet.sperson';
                                     
         /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
      ELSE
         vpasexec := 4;
         /*          SELECT COUNT (*)*/
         /*            INTO numpers*/
         /*            FROM personas*/
         /*           WHERE sperson = psperson;*/
         /* estpersonas*/
         /*          IF numpers <> 1*/
         /*          THEN*/
         /*             RAISE NO_DATA_FOUND;*/
         /*          END IF;*/
         /* Bug 25456/133727 - 16/01/2013 - AMC*/
         squery := 'select p.tapelli1, p.tapelli2, p.tnombre, p.tnombre1, p.tnombre2, p.cestciv, p.nordide, p.ctipper, p.ctipide,' ||
                   ' ff_desvalorfijo (672, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.ctipide) ttipide,' ||
                   ' pac_persona.F_FORMAT_NIF(p.NNUMIDE,p.CTIPIDE,p.SPERSON,''SEG'') nnumide, p.fnacimi, p.csexper,' ||
                   ' ff_desvalorfijo (11, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.csexper) tsexper,' ||
                   ' p.cestper, ff_desvalorfijo (13, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.cestper) testper,' ||
                   ' p.fjubila, p.fdefunc, f_user, p.fmovimi, p.cmutualista, p.cidioma,' ||
                   ' p.swpubli, NULL spereal, p.cprofes,' ||
                   ' FF_DESCPROFES(p.cprofes,PAC_MD_COMMON.F_Get_CXTIDIOMA(),PAC_MD_COMMON.F_GET_CXTEMPRESA()) tprofes,' ||
                   ' p.cpais, (select max(pa.tpais)' ||
                   ' from despaises pa where pa.cpais=p.cpais' ||
                   ' and pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA()) tpais, p.tsiglas, p.snip' ||
                   ' ,p.tnombre1, p.tnombre2, p.cestciv, ff_desvalorfijo(12,PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.cestciv), p.TDIGITOIDE,'
                  /*Bug.: 18948*/
                   || ' p.cocupacion,' ||
                   ' FF_DESCPROFES(p.cocupacion,PAC_MD_COMMON.F_Get_CXTIDIOMA(),PAC_MD_COMMON.F_GET_CXTEMPRESA()) tocupacion,' ||
                   ' (select f.CCIIU from per_ciiu pc inner join fin_general f on pc.cciiu = f.cciiu where pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() and  f.sperson =' || psperson || ') as cciiu,' ||
                   ' (select pc.TCIIU from per_ciiu pc inner join fin_general f on pc.cciiu = f.cciiu where pc.CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() and  f.sperson =' || psperson || ') as dciiu ' ||
                   ' from personas_detalles p where sperson = ' || psperson ||
                   ' and cagente = ' || pcagente;
         /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/                  
      END IF;


      vnumerr  := pac_md_log.f_log_consultas(squery,
                                             'PAC_MD_PERSONA.F_GET_PERSONA',
                                             1, 1, mensajes);
      cur      := pac_md_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 5;

      LOOP
         FETCH cur
            INTO persona.tapelli1,
                 persona.tapelli2,
                 persona.tnombre,
                 persona.tnombre1,
                 persona.tnombre2,
                 persona.cestciv,
                 persona.nordide,
                 persona.ctipper,
                 persona.ctipide,
                 persona.ttipide,
                 persona.nnumide,
                 persona.fnacimi,
                 persona.csexper,
                 persona.tsexper,
                 persona.cestper,
                 persona.testper,
                 persona.fjubila,
                 persona.fdefunc,
                 persona.cusuari,
                 persona.fmovimi,
                 persona.cmutualista,
                 persona.cidioma,
                 persona.swpubli,
                 persona.spereal,
                 persona.cprofes,
                 persona.tprofes,
                 persona.cpais,
                 persona.tpais,
                 persona.tsiglas,
                 persona.snip,
                 persona.tnombre1,
                 persona.tnombre2,
                 persona.cestciv,
                 persona.testciv,
                 persona.tdigitoide,
                 persona.cocupacion,
                 persona.tocupacion,
                 persona.cciiu,
                 persona.dciiu;


         EXIT WHEN cur%NOTFOUND;
         persona.cagente := pcagente;
         persona.sperson := psperson;
         vpasexec        := 6;


         IF persona.tdigitoide IS NOT NULL
         THEN
            persona.swrut := 1;
         ELSE
            persona.swrut := 0;
         END IF;

         numerr := f_get_direcciones(psperson, pcagente, persona.direcciones,
                                     mensajes, ptablas);

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         numerr   := f_get_contactos(psperson, pcagente, persona.contactos,
                                     mensajes, ptablas);

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 8;
         numerr   := f_get_nacionalidades(psperson, pcagente,
                                          persona.nacionalidades, mensajes,
                                          ptablas);

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 9;
         numerr   := f_get_cuentasbancarias(psperson, pcagente, NULL,
                                            persona.ccc, mensajes, ptablas, 1);
                                           

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 10;
         numerr   := f_get_identificadores(psperson, pcagente,
                                           persona.identificadores, mensajes,
                                           ptablas);                                          

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
         --INI BUG CONF-186  Fecha (22/08/2016) - HRE - proceso de marcas
         vpasexec := 101;
         numerr := f_get_permarcas(pac_md_common.f_get_cxtempresa(), psperson, persona.permarcas, mensajes, ptablas);

         IF numerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
         --FIN BUG CONF-186  Fecha (22/08/2016) - HRE - proceso de marcas
         vpasexec := 11;

         IF ptablas <> 'EST'
         THEN
            numerr := f_get_irpfs(psperson, pcagente, ptablas, persona.irpf,
                                  mensajes);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 12;
         /*Bug.: 18941 - 19/07/2011 - ICV*/
         numerr := f_get_personas_rel(psperson, pcagente, ptablas,
                                      persona.personas_rel, mensajes);                                      

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 13;
         /*End bug.: 18941*/
         /*Bug.: 18942 - 29/07/2011 - ICV*/
         numerr := f_get_regimenfiscales(psperson, pcagente, ptablas,
                                         persona.regimen_fiscal, mensajes);


         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

--INI--WAJ

         numerr := f_get_impuestos(psperson, ptablas,
                                         mensajes, persona.impuestos);                                       

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
--FIN--WAJ

         vpasexec := 14;
         /*End bug.: 18941*/
         /* Bug : 18943 - 26/09/2011 - MDS*/
         numerr := f_get_sarlafts(psperson, pcagente, ptablas,
                                  persona.datos_sarlaft, mensajes);                                 

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 15;
         /* End bug : 18943*/
         /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
         numerr := f_get_cuentasbancarias(psperson, pcagente, NULL,
                                          persona.tarjetas, mensajes, ptablas,
                                          2);                                         

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 16;
         /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
         /* Bug : 20126 - 23/11/2011 - APD*/
         numerr := f_get_documentacion(psperson, pcagente, ptablas,
                                       persona.datos_documentacion, mensajes);
                                    

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 17;

         IF pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                          'CONS_HIS_PER_REL') = 1
         THEN
            numerr := f_get_hispersonas_rel(psperson, pcagente, ptablas,
                                            persona.hispersonas_rel, mensajes);                                        

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         /*     XPL bug 21531#08032012*/
         numerr := f_get_perautcarnets(psperson, pcagente,
                                       persona.perautcarnets, mensajes,
                                       ptablas);                                     

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;


           vpasexec := 18;
        /*     Riesgo financiero*/
         numerr := f_get_riesgo_financiero(psperson,ptablas,
                                  persona.datos_riesgo_financiero, mensajes);                                

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         /* fin  Bug : 20126 - 23/11/2011 - APD*/
         IF ptablas <> 'EST'
         THEN
            numerr := f_get_perlopd(psperson, pcagente, persona.perlopd,
                                    persona.cestperlopd, persona.testperlopd,
                                    mensajes, ptablas);                                

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         /*Bug21765 - JTS - 04/06/2012*/
         IF ptablas <> 'EST'
         THEN
            BEGIN
               SELECT cpreaviso,
                      ff_desvalorfijo(108, pac_md_common.f_get_cxtidioma(),
                                      cpreaviso)
                 INTO persona.cpreaviso,
                      persona.tpreaviso
                 FROM per_personas
                WHERE sperson = persona.sperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END IF;

         /*Fi Bug21765*/

         -- 15/06/2016 - RSC
         -- Importante para que los parámetros de persona se vayan a buscar siempre!
         pac_iax_persona.parpersonas := NULL;
      END LOOP;

      CLOSE cur;

      RETURN persona;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_persona;

   /* BUG15810:DRA:08/09/2010:Inici*/
   /*************************************************************************
         Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
         param out mensajes  : mensajes de error
         return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_persona_est(psperson IN NUMBER,
                              pcagente IN NUMBER,
                              mensajes OUT t_iax_mensajes,
                              ptablas  IN VARCHAR2) RETURN ob_iax_personas IS
      vnumerr NUMBER(8) := 0;
      squery  VARCHAR(2000);
      cur     SYS_REFCURSOR;
      /* personas   t_iax_personas  := t_iax_personas ();*/
      persona  ob_iax_personas := ob_iax_personas();
      vidioma  NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente: ' || pcagente || ' ptablas: ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Persona_Est';
      objpers  ob_iax_personas;
      numpers  NUMBER;
      numerr   NUMBER;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      IF ptablas = 'EST'
      THEN
         SELECT COUNT(*)
           INTO numpers
           FROM estper_personas /* BUG15810:DRA:08/09/2010*/
          WHERE sperson = psperson;

         vpasexec := 2;

         IF numpers <> 1
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         vpasexec := 3;
         squery   := 'select d.tapelli1, d.tapelli2, d.tnombre, d.tnombre1, d.tnombre2, d.cestciv, p.nordide, p.ctipper, p.ctipide,' ||
                     ' ff_desvalorfijo (672, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.ctipide) ttipide,' ||
                     ' p.nnumide, p.fnacimi, p.csexper,' ||
                     ' ff_desvalorfijo (11, PAC_MD_COMMON.F_Get_CXTIDIOMA(), p.csexper) tsexper,' ||
                     ' p.cestper, ff_desvalorfijo (13, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.cestper) testper,' ||
                     ' p.fjubila, p.fdefunc, f_user, p.fmovimi, p.cmutualista, d.cidioma,' ||
                     ' p.swpubli, p.spereal, d.cprofes, (select max(pa.tprofes)' ||
                     ' from profesiones pa where pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA()' ||
                     ' and pa.cprofes=d.cprofes) tprofes, d.cpais, (select max(pa.tpais)' ||
                     ' from despaises pa where pa.cpais=d.cpais' ||
                     ' and pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA()) tpais, d.tsiglas, p.snip, p.tdigitoide' ||
                     ' from estper_personas p, estper_detper d where p.sperson = ' ||
                     psperson ||
                     ' and d.sperson(+) = p.sperson and d.cagente(+) = ' ||
                     NVL(pcagente, pac_md_common.f_get_cxtagenteprod());
      ELSE
         vpasexec := 4;
         squery   := 'select p.tapelli1, p.tapelli2, p.tnombre, p.tnombre1, p.tnombre2, p.cestciv, p.nordide, p.ctipper, p.ctipide,' ||
                     ' ff_desvalorfijo (672, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.ctipide) ttipide,' ||
                     ' p.nnumide, p.fnacimi, p.csexper,' ||
                     ' ff_desvalorfijo (11, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.csexper) tsexper,' ||
                     ' p.cestper, ff_desvalorfijo (13, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.cestper) testper,' ||
                     ' p.fjubila, p.fdefunc, f_user, p.fmovimi, p.cmutualista, p.cidioma,' ||
                     ' p.swpubli, NULL spereal, p.cprofes, (select max(pa.tprofes)' ||
                     ' from profesiones pa where pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA()' ||
                     ' and pa.cprofes=p.cprofes) tprofes, p.cpais, (select max(pa.tpais)' ||
                     ' from despaises pa where pa.cpais=p.cpais' ||
                     ' and pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA()) tpais, p.tsiglas, p.snip, p.tdigitoide' ||
                     ' from personas_detalles p where sperson = ' ||
                     psperson || ' and cagente = ' || pcagente;
      END IF;

      vnumerr  := pac_md_log.f_log_consultas(squery,
                                             'PAC_MD_PERSONA.f_get_persona_est',
                                             1, 1, mensajes);
      cur      := pac_md_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 5;

      LOOP
         FETCH cur
            INTO persona.tapelli1,
                 persona.tapelli2,
                 persona.tnombre,
                 persona.tnombre1,
                 persona.tnombre2,
                 persona.cestciv,
                 persona.nordide,
                 persona.ctipper,
                 persona.ctipide,
                 persona.ttipide,
                 persona.nnumide,
                 persona.fnacimi,
                 persona.csexper,
                 persona.tsexper,
                 persona.cestper,
                 persona.testper,
                 persona.fjubila,
                 persona.fdefunc,
                 persona.cusuari,
                 persona.fmovimi,
                 persona.cmutualista,
                 persona.cidioma,
                 persona.swpubli,
                 persona.spereal,
                 persona.cprofes,
                 persona.tprofes,
                 persona.cpais,
                 persona.tpais,
                 persona.tsiglas,
                 persona.snip,
                 persona.tdigitoide;

         EXIT WHEN cur%NOTFOUND;
         persona.cagente := pcagente;
         persona.sperson := psperson;

         IF persona.tdigitoide IS NOT NULL
         THEN
            persona.swrut := 1;
         ELSE
            persona.swrut := 0;
         END IF;

         persona.swrut := 1;
         vpasexec      := 6;
         numerr        := f_get_direcciones(psperson, pcagente,
                                            persona.direcciones, mensajes,
                                            ptablas);

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         numerr   := f_get_contactos(psperson, pcagente, persona.contactos,
                                     mensajes, ptablas);

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 8;
         numerr   := f_get_nacionalidades(psperson, pcagente,
                                          persona.nacionalidades, mensajes,
                                          ptablas);

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 9;
         numerr   := f_get_cuentasbancarias(psperson, pcagente, NULL,
                                            persona.ccc, mensajes, ptablas);

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 10;
         numerr   := f_get_identificadores(psperson, pcagente,
                                           persona.identificadores, mensajes,
                                           ptablas);

         IF numerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 11;

         IF ptablas <> 'EST'
         THEN
            numerr := f_get_irpfs(psperson, pcagente, ptablas, persona.irpf,
                                  mensajes);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 12;
      END LOOP;

      CLOSE cur;

      RETURN persona;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_persona_est;

   /* BUG15810:DRA:08/09/2010:Fi*/
   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Obtiene de parametros de salida los datos principales del contacto tipo telefono fijo.
     return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactotlffijo(psperson IN NUMBER,
                                  pcagente IN NUMBER,
                                  psmodcon OUT NUMBER,
                                  ptvalcon OUT VARCHAR2,
                                  mensajes IN OUT t_iax_mensajes,
                                  ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' cagente:' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_ContactoTlfFijo';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_contacto_tipo(psperson, pcagente, 1,
                                                 psmodcon, ptvalcon, ptablas);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contactotlffijo;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene de parametros de salida los datos principales del contacto  tipo telefono movil.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactotlfmovil(psperson IN NUMBER,
                                   pcagente IN NUMBER,
                                   psmodcon OUT NUMBER,
                                   ptvalcon OUT VARCHAR2,
                                   mensajes IN OUT t_iax_mensajes,
                                   ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente:' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_ContactoTlfMovil';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_contacto_tipo(psperson, pcagente, 6,
                                                 psmodcon, ptvalcon, ptablas);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contactotlfmovil;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene  de parametros de salida los datos principales del contacto  tipo mail.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactomail(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               psmodcon OUT NUMBER,
                               ptvalcon OUT VARCHAR2,
                               mensajes IN OUT t_iax_mensajes,
                               ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente:' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_ContactoMail';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_contacto_tipo(psperson, pcagente, 3,
                                                 psmodcon, ptvalcon, ptablas);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contactomail;

   /*************************************************************************
       Obtiene  de parametros de salida los datos principales del contacto  tipo fax.
           return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactofax(psperson IN NUMBER,
                              pcagente IN NUMBER,
                              psmodcon OUT NUMBER,
                              ptvalcon OUT VARCHAR2,
                              mensajes IN OUT t_iax_mensajes,
                              ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente:' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_ContactoFax';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_contacto_tipo(psperson, pcagente, 2,
                                                 psmodcon, ptvalcon, ptablas);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contactofax;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene el codigo del pais, nacionalidad por defecto.
      return              : Pais
   *************************************************************************/
   FUNCTION f_get_nacionalidaddefecto(psperson IN NUMBER,
                                      pcagente IN NUMBER,
                                      pcpais   OUT NUMBER,
                                      mensajes OUT t_iax_mensajes,
                                      ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' cagente:' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_NacionalidadDefecto';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_nacionalidaddefecto(psperson, pcagente,
                                                       pcpais, ptablas);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_nacionalidaddefecto;

   /*xpl 180708*/
   /*************************************************************************
      Obtiene el codigo del pais, nacionalidad por defecto.
      return              : Pais
   *************************************************************************/
   FUNCTION f_get_nacionalidades(psperson        IN NUMBER,
                                 pcagente        IN NUMBER,
                                 pnacionalidades OUT t_iax_nacionalidades,
                                 mensajes        OUT t_iax_mensajes,
                                 ptablas         IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'PCagente:' || pcagente || 'Ptablas:' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_nacionalidades';
      vtsiglas tipos_via.tsiglas%TYPE;
      vcpais   provincias.cpais%TYPE;

      CURSOR cur_direc IS
         SELECT sperson,
                cpais,
                cdefecto
           FROM (SELECT sperson,
                        cpais,
                        cdefecto
                   FROM estnacionalidades
                  WHERE sperson = psperson
                    AND ptablas = 'EST'
                 UNION ALL
                 SELECT sperson,
                        cpais,
                        cdefecto
                   FROM per_nacionalidades
                 /*FROM  nacionalidades*/
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND ptablas != 'EST');
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pnacionalidades := t_iax_nacionalidades();

      FOR reg IN cur_direc
      LOOP
         pnacionalidades.extend;
         pnacionalidades(pnacionalidades.last) := ob_iax_nacionalidades();
         vnumerr := f_get_nacionalidad(psperson, reg.cpais, pcagente,
                                       pnacionalidades(pnacionalidades.last),
                                       mensajes, ptablas);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      IF pnacionalidades IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104474);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_nacionalidades;

   FUNCTION f_get_nacionalidad(psperson     IN NUMBER,
                               pcpais       IN NUMBER,
                               pcagente     IN NUMBER,
                               nacionalidad OUT ob_iax_nacionalidades,
                               mensajes     IN OUT t_iax_mensajes,
                               ptablas      IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcnacionalidad = ' || pcpais ||
                                ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_nacionalidad';
      dummy    NUMBER;
   BEGIN
      IF psperson IS NULL OR
         pcpais IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      nacionalidad := ob_iax_nacionalidades();

      /* BUG 26968 - FAL - 05/07/2013*/
      /*
      SELECT cpais, tpais, cdefecto
        INTO nacionalidad.cpais, nacionalidad.tpais, nacionalidad.cdefecto
        FROM (SELECT cpais, ff_despais(cpais, pac_md_common.f_get_cxtidioma()) tpais, cdefecto
                FROM estnacionalidades en
               WHERE en.sperson = psperson
                 AND en.cpais = pcpais
                 AND ptablas = 'EST'
              UNION ALL
              SELECT cpais, ff_despais(cpais, pac_md_common.f_get_cxtidioma()) tpais, cdefecto
                FROM per_nacionalidades en
               WHERE en.sperson = psperson
                 AND en.cagente = pcagente
                 AND en.cpais = pcpais
                 AND ptablas != 'EST');
       */
      SELECT cpais,
             tpais,
             cdefecto
        INTO nacionalidad.cpais,
             nacionalidad.tpais,
             nacionalidad.cdefecto
        FROM (SELECT en.cpais,
                     p.tnacion tpais,
                     cdefecto
                FROM estnacionalidades en,
                     despaises         p
               WHERE en.sperson = psperson
                 AND en.cpais = pcpais
                 AND ptablas = 'EST'
                 AND en.cpais = p.cpais
                 AND p.cidioma = pac_md_common.f_get_cxtidioma()
              UNION ALL
              SELECT en.cpais,
                     p.tnacion tpais,
                     cdefecto
                FROM per_nacionalidades en,
                     despaises          p
               WHERE en.sperson = psperson
                 AND en.cagente = pcagente
                 AND en.cpais = pcpais
                 AND ptablas != 'EST'
                 AND en.cpais = p.cpais
                 AND p.cidioma = pac_md_common.f_get_cxtidioma());

      /* FI BUG 26968*/
      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
         /*      WHEN NO_DATA_FOUND THEN*/
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_nacionalidad;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Nueva funcion que recupera la cuenta bancaria que tiene primero se mirara a nivel de poliza,
      si no hay definida se mira a nivel de persona
      return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_get_cuentapoliza(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               psseguro IN NUMBER,
                               pctipban OUT NUMBER,
                               pcbancar OUT VARCHAR2,
                               mensajes OUT t_iax_mensajes,
                               ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' Cagente' || pcagente || ' psseguro' ||
                                psseguro;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_cuentaPoliza';
      vcbancar VARCHAR2(50);
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_cuentapoliza(psperson, pcagente,
                                                /*   psseguro,*/
                                                /*  mensajes,*/ pctipban,
                                                vcbancar, ptablas);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF pcbancar IS NOT NULL
      THEN
         vnumerr := f_formatoccc(vcbancar, pcbancar, pctipban);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cuentapoliza;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Nueva funcion que da formato a la cuenta bancaria dependiendo del tipo.
      pcbancar es cbancar pero formateado.
      return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_getformatoccc(pctipban IN NUMBER,
                            cbancar  IN VARCHAR2,
                            pcbancar OUT VARCHAR2,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - cbancar: ' || cbancar ||
                                ' pctipban' || pctipban;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_getFormatoCCC';
   BEGIN
      IF pctipban IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF cbancar IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*vnumerr:=PAC_MD_PERSONA.f_getFormatoCCC(pctipban,
                                                  cbancar,
                                                  mensajes ,
                                                  pcbancar);
      */
      vnumerr := f_formatoccc(cbancar, pcbancar, pctipban);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_getformatoccc;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Nueva funcion que valida la cuenta bancaria dependiendo del tipo.
      pcbancar es cbancar pero formateado.
      return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_validaccc(pctipban IN NUMBER,
                        cbancar  IN VARCHAR2,
                        mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr   NUMBER(8) := 0;
      pncontrol NUMBER;
      nsalida   VARCHAR2(100) := '1';
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(500) := 'parametros - cbancar: ' || cbancar ||
                                 ' pctipban' || pctipban;
      vobject   VARCHAR2(200) := 'PAC_MD_PERSONA.f_validaCCC';
   BEGIN
      IF pctipban IS NULL OR
         cbancar IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      vnumerr := f_ccc(cbancar, pctipban, pncontrol, nsalida);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_validaccc;

   /*************************************************************************
         Esta nueva funcion se encarga de grabar  un contacto
         return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contacto(psperson IN NUMBER,
                           cagente  IN NUMBER,
                           pctipcon IN NUMBER,
                           ptcomcon IN VARCHAR2,
                           ptvalcon IN VARCHAR2,
                           pcdomici IN NUMBER, /*bug 24806*/
                           psmodcon IN OUT NUMBER,
                           pcprefix IN NUMBER,
                           mensajes IN OUT t_iax_mensajes,
                           ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' Cagente:' || cagente || ' pctipcon:' ||
                                pctipcon || ' ptcomcon:' || ptcomcon ||
                                ' Tvalcon:' || ptvalcon || ' pcdomici:' ||
                                pcdomici || ' pcprefix:' || pcprefix; --bug 24806;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_Contacto';
      /*mensajes  T_IAX_MENSAJES;*/
      errores          t_ob_error;
      vmcontactoreqaut NUMBER;
      control          NUMBER;
      verr             ob_error;
   BEGIN
      IF psperson IS NULL OR
         cagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                           'PER_VAL_URL'), 0) = 1 AND
         pctipcon = 8 AND
         ptvalcon IS NOT NULL
      THEN
         SELECT DECODE(regexp_substr(regexp_replace(ptvalcon,
                                                    '^http[s]?://(www\.)?|^www\.',
                                                    '', 1), '\w+(\.\w+)+'),
                       NULL, 1, 0)
           INTO control
           FROM dual;
         IF control = 1
         THEN
            errores := t_ob_error();
            errores.extend;
            verr := ob_error.instanciar(9909651,
                                        f_axis_literales(9909651,
                                                          pac_md_common.f_get_cxtidioma));
            errores(1) := verr;
            mensajes := f_traspasar_errores_mensajes(errores);
            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         END IF;
      END IF;

      /* Bug 18949/103391 - 03/02/2012 - AMC*/
      IF ptablas = 'POL' AND
         psmodcon IS NOT NULL
      THEN
         /*         vmcontactoreqaut := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),*/
         /*                                                           'M_CONTACTO_REQ_AUT');*/
         vnumerr := pac_cfg.f_get_user_accion_permitida(f_user,
                                                        'AUTORIZACION_CONTACTOS',
                                                        0,
                                                        pac_md_common.f_get_cxtempresa(),
                                                        vmcontactoreqaut);

         /*0026057- INICIO - DCT - 11/02/2013 - LCOL - PER - Atuorizacion de contactos - Relación entre contacctos y direcciones*/
         IF NVL(vmcontactoreqaut, 0) = 1
         THEN
            vnumerr := pac_persona.f_ins_contacto_aut(psperson, cagente,
                                                      pctipcon, psmodcon,
                                                      ptvalcon, 'M',
                                                      pac_md_common.f_get_cxtidioma(),
                                                      pcdomici, errores);
            /*0026057- FIN - DCT - 11/02/2013 - LCOL - PER - Atuorizacion de contactos - Relación entre contacctos y direcciones*/
            mensajes := f_traspasar_errores_mensajes(errores);

            /* Ini bug 30417/11671 -- ECP -- 07/03/2014*/
            IF vnumerr <> 0
            THEN
               RAISE e_object_error;
            END IF;

            /* Fin bug 30417/11671 -- ECP -- 07/03/2014*/
            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         ELSE
            vnumerr  := pac_persona.f_set_contacto(psperson, cagente,
                                                   pctipcon, ptcomcon,
                                                   psmodcon, ptvalcon,
                                                    /*ETM 21406*/ pcdomici,
                                                   pcprefix, errores, ptablas); /*etm 24806*/
            mensajes := f_traspasar_errores_mensajes(errores);

            /* Ini bug 30417/11671 -- ECP -- 07/03/2014*/
            IF vnumerr <> 0
            THEN
               RAISE e_object_error;
            END IF;

            /* Fin bug 30417/11671 -- ECP -- 07/03/2014*/
            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         END IF;
      ELSE
         vnumerr  := pac_persona.f_set_contacto(psperson, cagente, pctipcon,
                                                ptcomcon, psmodcon, ptvalcon,
                                                pcdomici, /*etm 24806*/
                                                pcprefix, errores, ptablas);
         mensajes := f_traspasar_errores_mensajes(errores);

         /* Ini bug 30417/11671 -- ECP -- 07/03/2014*/
         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;

         /* Fin bug 30417/11671 -- ECP -- 07/03/2014*/
         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END IF;

      /* Fi Bug 18949/103391 - 03/02/2012 - AMC*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contacto;

   FUNCTION f_del_contacto(psperson IN NUMBER,
                           psmodcon IN NUMBER,
                           pcagente IN NUMBER,
                           mensajes IN OUT t_iax_mensajes,
                           ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr          NUMBER(8) := 0;
      a                NUMBER;
      vpasexec         NUMBER(8) := 1;
      vparam           VARCHAR2(500) := 'parametros - psperson: ' ||
                                        psperson || 'psmodcon ' || psmodcon;
      vobject          VARCHAR2(200) := 'PAC_MD_PERSONA.F_del_contacto';
      errores          t_ob_error;
      cont             NUMBER := 0;
      vmcontactoreqaut NUMBER;
      vobcontactos     ob_iax_contactos;
      vsmodcon         NUMBER;
   BEGIN
      vsmodcon := psmodcon;

      IF psperson IS NULL OR
         psmodcon IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'POL'
      THEN
         /**/
         SELECT COUNT(1)
           INTO cont
           FROM per_contactos
          WHERE sperson = psperson
            AND cagente = pcagente
            AND cmodcon = psmodcon;
      ELSIF ptablas = 'EST'
      THEN
         /**/
         SELECT COUNT(1)
           INTO cont
           FROM estper_contactos
          WHERE sperson = psperson
            AND cagente = pcagente
            AND cmodcon = psmodcon;
         /**/
      END IF;

      IF cont = 0
      THEN
         /*no existeix el contacte ha petat.*/
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      /* Bug 18949/103391 - 03/02/2012 - AMC*/
      IF ptablas = 'POL'
      THEN
         /*vmcontactoreqaut := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),*/
         /*                                                  'M_CONTACTO_REQ_AUT');*/
         vnumerr := pac_cfg.f_get_user_accion_permitida(f_user,
                                                        'AUTORIZACION_CONTACTOS',
                                                        0,
                                                        pac_md_common.f_get_cxtempresa(),
                                                        vmcontactoreqaut);

         IF NVL(vmcontactoreqaut, 0) = 1
         THEN
            vnumerr := f_get_contacto(psperson, pcagente, psmodcon,
                                      vobcontactos, mensajes, 'POL');

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;

            vnumerr  := pac_persona.f_ins_contacto_aut(psperson, pcagente,
                                                       vobcontactos.ctipcon,
                                                       vsmodcon,
                                                       vobcontactos.tvalcon,
                                                       'B',
                                                       pac_md_common.f_get_cxtidioma(),
                                                       NULL, errores);
            mensajes := f_traspasar_errores_mensajes(errores);
            vpasexec := 1;

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         ELSE
            pac_persona.p_del_contacto(psperson, psmodcon, errores,
                                       pac_md_common.f_get_cxtidioma(),
                                       ptablas);
            vpasexec := 2;
            mensajes := f_traspasar_errores_mensajes(errores);
            vpasexec := 3;

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         END IF;
      ELSE
         pac_persona.p_del_contacto(psperson, psmodcon, errores,
                                    pac_md_common.f_get_cxtidioma(), ptablas);
         vpasexec := 4;
         mensajes := f_traspasar_errores_mensajes(errores);
         vpasexec := 5;

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END IF;

      /* Fi Bug 18949/103391 - 03/02/2012 - AMC*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_contacto;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Esta nueva funcion se encarga de grabar  el contacto telefono fijo  en estper_contactos.
     return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactotlffijo(psperson IN NUMBER,
                                  pcagente IN NUMBER,
                                  ptvalcon IN VARCHAR2,
                                  psmodcon IN OUT NUMBER,
                                  pcprefix IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes,
                                  ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente || 'Tvalcon:' ||
                                ptvalcon;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_ContactoTlfFijo';
      /*mensajes  T_IAX_MENSAJES;*/
      errores t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_set_contacto(psperson, pcagente, 1, NULL,
                                             psmodcon, ptvalcon, NULL,
                                             pcprefix, errores, /*ETM 21406*/
                                             ptablas);
      mensajes := f_traspasar_errores_mensajes(errores);

      --Ini bug 41766-VCG- 23/05/2016
      -- IF vnumerr<>0 THEN
      --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 152961);

      --  RAISE e_object_error;
      --  END IF;
      --Fin bug 41766-VCG- 23/05/2016
      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contactotlffijo;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Esta nueva funcion se encarga de grabar  el contacto telefono movil  en estper_contactos.
     return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactotlfmovil(psperson IN NUMBER,
                                   pcagente IN NUMBER,
                                   ptvalcon IN VARCHAR2,
                                   psmodcon IN OUT NUMBER,
                                   pcprefix IN NUMBER,
                                   mensajes IN OUT t_iax_mensajes,
                                   ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente || 'Tvalcon:' ||
                                ptvalcon;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_ContactoTlfMovil';
      /*  mensajes  T_IAX_MENSAJES;*/
      errores t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_set_contacto(psperson, pcagente, 6, NULL,
                                             psmodcon, ptvalcon, NULL,
                                             pcprefix, errores, /*ETM 21406*/
                                             ptablas);
      mensajes := f_traspasar_errores_mensajes(errores);

      --Ini bug 41766-VCG- 23/05/2016
      --IF vnumerr<>0 THEN
      --  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 152961);

      --  RAISE e_object_error;
      --END IF;
      --Fin bug 41766-VCG- 23/05/2016
      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contactotlfmovil;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Esta nueva funcion se encarga de grabar  el contacto mail  en estper_contactos.
     return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactomail(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               ptvalcon IN VARCHAR2,
                               psmodcon IN OUT NUMBER,
                               mensajes IN OUT t_iax_mensajes,
                               ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente || 'Tvalcon:' ||
                                ptvalcon;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_ContactoMail';
      /*mensajes  T_IAX_MENSAJES;*/
      errores t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_set_contacto(psperson, pcagente, 3, NULL,
                                             psmodcon, ptvalcon, NULL, NULL,
                                             errores, /*ETM 21406*/ ptablas);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 152961);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contactomail;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Esta nueva funcion se encarga de grabar  la nacionalidad por defecto de una persona.
     return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_nacionalidaddefecto(psperson IN NUMBER,
                                      pcagente IN NUMBER,
                                      pcpais   IN NUMBER,
                                      mensajes OUT t_iax_mensajes,
                                      ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente || 'Cpais:' ||
                                pcpais;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_NacionalidadDefecto';
      errores  t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_set_nacionalidad(psperson, pcagente, pcpais,
                                                 1, errores, ptablas);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_nacionalidaddefecto;

   FUNCTION f_set_nacionalidad(psperson  IN NUMBER,
                               pcagente  IN NUMBER,
                               pcpais    IN NUMBER,
                               pcdefecto IN NUMBER,
                               mensajes  IN OUT t_iax_mensajes,
                               ptablas   IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente || 'Cpais:' ||
                                pcpais;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_Nacionalidad';
      errores  t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_set_nacionalidad(psperson, pcagente, pcpais,
                                                 pcdefecto, errores, ptablas);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 OR
         (mensajes IS NOT NULL AND mensajes.count > 0)
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_nacionalidad;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Esta nueva funcion se encarga de grabar  la cuenta bancaria  de una persona, sera la de por defecto
     si no existe hasta el momento si ya tiene una cuenta bancaria por defecto este campo no se modificara.
     return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_ccc(psperson  IN NUMBER,
                      pcagente  IN NUMBER,
                      pcnordban IN OUT NUMBER,
                      pctipban  IN NUMBER,
                      pcbancar  IN VARCHAR2,
                      pcdefecto IN NUMBER,
                      mensajes  IN OUT t_iax_mensajes,
                      ptablas   IN VARCHAR2,
                      pcpagsin  IN NUMBER DEFAULT NULL,
                      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                      pfvencim IN DATE DEFAULT NULL,
                      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                      ptseguri IN VARCHAR2 DEFAULT NULL,
                      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                      pctipcc IN VARCHAR2 DEFAULT NULL /* 20735/102170 Introduccion de cuenta bancaria*/)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente || 'CNordBan:' ||
                                pcnordban || 'pctipban:' || pctipban ||
                                'cbancar:' || pcbancar;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_CCC';
      vcbancar VARCHAR2(100);
      errores  t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pctipban IS NOT NULL
      THEN
         /* 20735/102170 Introduccion de cuenta bancaria-- 20735/102170 Introduccion de cuenta bancaria*/
         vnumerr := f_formatoccc(pcbancar, vcbancar, pctipban, 1);
      ELSE
         vcbancar := pcbancar;
      END IF;

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vnumerr  := pac_persona.f_set_ccc(psperson, pcagente, pcnordban,
                                        pctipban, vcbancar, errores,
                                        pcdefecto, ptablas, pcpagsin,
                                        pfvencim, ptseguri,
                                        /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                                        pctipcc
                                        /* 20735/102170 Introduccion de cuenta bancaria*/);
      vpasexec := 7;
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 9;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_ccc;

   FUNCTION f_get_contactos(psperson   IN NUMBER,
                            pcagente   IN NUMBER,
                            tcontactos OUT t_iax_contactos,
                            mensajes   OUT t_iax_mensajes,
                            ptablas    IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'PCagente:' || pcagente || 'Ptablas:' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_contactos';
      vtdomici VARCHAR2(3200);

      CURSOR cur_contact IS
         SELECT sperson,
                cagente,
                cmodcon,
                ctipcon,
                tcomcon,
                tvalcon,
                cdomici,
                cprefix
           FROM (SELECT sperson,
                        cagente,
                        cmodcon,
                        ctipcon,
                        tcomcon,
                        tvalcon,
                        cdomici,
                        cprefix
                   FROM estper_contactos
                 /*CAMPO AGENTE NUMBER CUANDO TENDRa?A Q SER VARCHAR2*/
                 /*FROM per_contactos*/
                  WHERE sperson = psperson
                    AND ptablas = 'EST'
                 UNION ALL
                 SELECT sperson,
                        cagente,
                        cmodcon,
                        ctipcon,
                        tcomcon,
                        tvalcon,
                        cdomici,
                        cprefix
                 /*from contactos*/
                   FROM per_contactos
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND ptablas != 'EST');

      psmodcon NUMBER;
      ptvalcon VARCHAR2(500);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      tcontactos := t_iax_contactos();

      FOR reg IN cur_contact
      LOOP
         tcontactos.extend;
         tcontactos(tcontactos.last) := ob_iax_contactos();
         tcontactos(tcontactos.last).cmodcon := reg.cmodcon;
         tcontactos(tcontactos.last).ctipcon := reg.ctipcon;
         tcontactos(tcontactos.last).tvalcon := reg.tvalcon;
         tcontactos(tcontactos.last).ttipcon := ff_desvalorfijo(15,
                                                                pac_md_common.f_get_cxtidioma(),
                                                                reg.ctipcon);
         tcontactos(tcontactos.last).tcomcon := reg.tcomcon; /*etm 21406*/
         tcontactos(tcontactos.last).cdomici := reg.cdomici;
         tcontactos(tcontactos.last).cprefix := reg.cprefix;

         IF reg.cdomici IS NOT NULL
         THEN
            BEGIN
               IF ptablas = 'POL'
               THEN
                  SELECT tdomici
                    INTO vtdomici
                    FROM per_direcciones
                   WHERE sperson = psperson
                     AND cdomici = reg.cdomici;
               ELSE
                  SELECT tdomici
                    INTO vtdomici
                    FROM estper_direcciones
                   WHERE sperson = psperson
                     AND cdomici = reg.cdomici;
               END IF;

               tcontactos(tcontactos.last).tdomici := vtdomici;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobject, 1, vparam,
                              SQLERRM);
            END;
         END IF;
      END LOOP;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contactos;

   /*************************************************************************
      Obtiene el contacto del sperson
      return              : ob_IAX_CONTACTOS   T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contacto(psperson    IN NUMBER,
                           pcagente    IN NUMBER,
                           pcmodcon    IN NUMBER,
                           obcontactos OUT ob_iax_contactos,
                           mensajes    OUT t_iax_mensajes,
                           ptablas     IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'PCagente:' || pcagente || 'pcmodcon:' ||
                                pcmodcon || 'Ptablas:' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_contacto';
      psmodcon NUMBER;
      ptvalcon VARCHAR2(500);
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      obcontactos := ob_iax_contactos();

      SELECT cmodcon,
             ctipcon,
             ttipcon,
             tcomcon,
             tvalcon,
             cdomici, /*bug 24806*/
             cobliga,
             tobliga,
             cprefix
        INTO obcontactos.cmodcon,
             obcontactos.ctipcon,
             obcontactos.ttipcon,
             obcontactos.tcomcon,
             obcontactos.tvalcon,
             obcontactos.cdomici,
             obcontactos.cobliga,
             obcontactos.tobliga,
             obcontactos.cprefix
        FROM (SELECT cmodcon,
                     ctipcon,
                     ff_desvalorfijo(15, pac_md_common.f_get_cxtidioma(),
                                     ctipcon) ttipcon,
                     tcomcon,
                     tvalcon,
                     cdomici,
                     NULL cobliga,
                     NULL tobliga,
                     c.cprefix
                FROM estper_contactos c
               WHERE c.sperson = psperson
                 AND c.cmodcon = pcmodcon
                 AND ptablas = 'EST'
              UNION ALL
              SELECT cmodcon,
                     ctipcon,
                     ff_desvalorfijo(15, pac_md_common.f_get_cxtidioma(),
                                     ctipcon) ttipcon,
                     tcomcon,
                     tvalcon,
                     cdomici,
                     NULL cobliga,
                     NULL tobliga,
                     c.cprefix
              /*from  contactos c*/
                FROM per_contactos c
               WHERE c.sperson = psperson
                 AND c.cagente = pcagente
                 AND c.cmodcon = pcmodcon
                 AND ptablas != 'EST');

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      IF obcontactos.cdomici IS NOT NULL
      THEN
         IF ptablas = 'POL'
         THEN
            SELECT tdomici
              INTO obcontactos.tdomici
              FROM per_direcciones
             WHERE sperson = psperson
               AND cagente = pcagente
               AND cdomici = obcontactos.cdomici;
         ELSE
            SELECT tdomici
              INTO obcontactos.tdomici
              FROM estper_direcciones
             WHERE sperson = psperson
               AND cagente = pcagente
               AND cdomici = obcontactos.cdomici;
         END IF;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contacto;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene las direcciones del sperson
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_direcciones(psperson    IN NUMBER,
                              pcagente    IN NUMBER,
                              direcciones OUT t_iax_direcciones,
                              mensajes    IN OUT t_iax_mensajes,
                              ptablas     IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'PCagente:' || pcagente || 'Ptablas:' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Direcciones';
      vtsiglas tipos_via.tsiglas%TYPE;
      vcpais   provincias.cpais%TYPE;

      CURSOR cur_direc IS
         SELECT sperson,
                cdomici,
                ctipdir,
                csiglas,
                tnomvia,
                nnumvia,
                tcomple,
                tdomici,
                cpostal,
                cpoblac,
                cprovin,
                cusuari,
                fmovimi,
                talias,
                nueva
           FROM (SELECT sperson,
                        cdomici,
                        ctipdir,
                        csiglas,
                        tnomvia,
                        nnumvia,
                        tcomple,
                        tdomici,
                        cpostal,
                        cpoblac,
                        cprovin,
                        cusuari,
                        fmovimi,
                        (select talias from per_direcciones where sperson = (select spereal from estper_personas where sperson = psperson and rownum = 1) and cdomici = ed.cdomici) as talias,
                        (SELECT COUNT(cdomici)
                           FROM estdirecciones  e,
                                estper_personas tp
                          WHERE e.sperson = tp.sperson
                            AND e.sperson = psperson
                            AND cdomici = ed.cdomici
                            AND cdomici NOT IN
                                (SELECT cdomici
                                   FROM per_direcciones p,
                                        estper_personas tp
                                  WHERE p.sperson = tp.spereal
                                    AND tp.sperson = psperson)) nueva
                   FROM estdirecciones ed
                  WHERE sperson = psperson
                    AND ptablas = 'EST'
                 UNION ALL
                 SELECT sperson,
                        cdomici,
                        ctipdir,
                        csiglas,
                        tnomvia,
                        nnumvia,
                        tcomple,
                        tdomici,
                        cpostal,
                        cpoblac,
                        cprovin,
                        cusuari,
                        fmovimi,
                        talias,
                        0 nueva
                   FROM per_direcciones
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND ptablas != 'EST');
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      direcciones := t_iax_direcciones();

      FOR reg IN cur_direc
      LOOP
         direcciones.extend;
         direcciones(direcciones.last) := ob_iax_direcciones();
         vnumerr := f_get_direccion(psperson, reg.cdomici,
                                    direcciones(direcciones.last), mensajes,
                                    ptablas);
         direcciones(direcciones.last).nueva := reg.nueva;

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      IF direcciones IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104474);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_direcciones;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Borra una direccion.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_del_direcciones(psperson IN NUMBER,
                              pcdomici IN NUMBER,
                              mensajes IN OUT t_iax_mensajes,
                              ptablas  IN VARCHAR2,
                              pcagente IN NUMBER) RETURN NUMBER IS
      vnumerr           NUMBER(8) := 0;
      cpais             NUMBER;
      vpasexec          NUMBER(8) := 1;
      vparam            VARCHAR2(500) := 'parametros - psperson: ' ||
                                         psperson || ' ' || pcdomici;
      vobject           VARCHAR2(200) := 'PAC_MD_PERSONA.F_del_Direcciones';
      errores           t_ob_error := t_ob_error();
      vmdireccionreqaut NUMBER;
      vdireccion        ob_iax_direcciones;
   BEGIN
      IF psperson IS NULL OR
         pcdomici IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /* Bug 18949/103391 - 03/02/2012 - AMC*/
      IF ptablas = 'POL'
      THEN
         /*vmdireccionreqaut := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),*/
         /*                                                   'M_DIRECCION_REQ_AUT');*/
         vnumerr := pac_cfg.f_get_user_accion_permitida(f_user,
                                                        'AUTORIZACION_DIRECCIONES',
                                                        0,
                                                        pac_md_common.f_get_cxtempresa(),
                                                        vmdireccionreqaut);

         IF NVL(vmdireccionreqaut, 0) = 1
         THEN
            vnumerr := f_get_direccion(psperson, pcdomici, vdireccion,
                                       mensajes, 'POL');

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;

            vnumerr  := pac_persona.f_ins_direccion_aut(psperson, pcagente,
                                                        vdireccion.cdomici,
                                                        vdireccion.ctipdir,
                                                        vdireccion.csiglas,
                                                        vdireccion.tnomvia,
                                                        vdireccion.nnumvia,
                                                        vdireccion.tcomple,
                                                        vdireccion.tdomici,
                                                        vdireccion.cpostal,
                                                        vdireccion.cpoblac,
                                                        vdireccion.cprovin,
                                                        f_user(), f_sysdate(),
                                                        pac_md_common.f_get_cxtidioma(),
                                                        errores, 'B',
                                                        vdireccion.cviavp,
                                                        vdireccion.clitvp,
                                                        vdireccion.cbisvp,
                                                        vdireccion.corvp,
                                                        vdireccion.nviaadco,
                                                        vdireccion.clitco,
                                                        vdireccion.corco,
                                                        vdireccion.nplacaco,
                                                        vdireccion.cor2co,
                                                        vdireccion.cdet1ia,
                                                        vdireccion.tnum1ia,
                                                        vdireccion.cdet2ia,
                                                        vdireccion.tnum2ia,
                                                        vdireccion.cdet3ia,
                                                        vdireccion.tnum3ia,
                                                        vdireccion.localidad
                                                         /* Bug 24780/130907 - 05/12/2012 - AMC*/);
            mensajes := f_traspasar_errores_mensajes(errores);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         ELSE
            pac_persona.p_del_direccion(psperson, pcdomici,
                                        pac_md_common.f_get_cxtidioma(),
                                        errores, ptablas);
            mensajes := f_traspasar_errores_mensajes(errores);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         END IF;
      ELSE
         pac_persona.p_del_direccion(psperson, pcdomici,
                                     pac_md_common.f_get_cxtidioma(),
                                     errores, ptablas);
         mensajes := f_traspasar_errores_mensajes(errores);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END IF;

      /* Fi Bug 18949/103391 - 03/02/2012 - AMC*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_direcciones;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Nueva funcion que se encarga de recuperar una direccion de una persona.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_direccion(psperson  IN NUMBER,
                            pcdomici  IN NUMBER,
                            direccion OUT ob_iax_direcciones,
                            mensajes  IN OUT t_iax_mensajes,
                            ptablas   IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcdomici = ' || pcdomici || ' ptablas = ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Direccion';
      dummy    NUMBER;
   BEGIN
      IF psperson IS NULL OR
         pcdomici IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      direccion := ob_iax_direcciones();

      /* Bug 18940/92686 - 27/09/2011 - AMC*/
      SELECT cdomici,
             tdomici,
             ctipdir,
             ttipdir,
             csiglas,
             tnomvia,
             nnumvia,
             tcomple,
             cpostal,
             cpoblac,
             tpoblac,
             cprovin,
             tprovin,
             cpais,
             tpais,
             cviavp,
             clitvp,
             cbisvp,
             corvp,
             nviaadco,
             clitco,
             corco,
             nplacaco,
             cor2co,
             cdet1ia,
             tnum1ia,
             cdet2ia,
             tnum2ia,
             cdet3ia,
             tnum3ia,
             localidad,
	     talias, -- BUG CONF-441 - 14/12/2016 - JAEG
             fdefecto /* Bug 24780/130907 - 05/12/2012 - AMC*/
        INTO direccion.cdomici,
             direccion.tdomici,
             direccion.ctipdir,
             direccion.ttipdir,
             direccion.csiglas,
             direccion.tnomvia,
             direccion.nnumvia,
             direccion.tcomple,
             direccion.cpostal,
             direccion.cpoblac,
             direccion.tpoblac,
             direccion.cprovin,
             direccion.tprovin,
             direccion.cpais,
             direccion.tpais,
             direccion.cviavp,
             direccion.clitvp,
             direccion.cbisvp,
             direccion.corvp,
             direccion.nviaadco,
             direccion.clitco,
             direccion.corco,
             direccion.nplacaco,
             direccion.cor2co,
             direccion.cdet1ia,
             direccion.tnum1ia,
             direccion.cdet2ia,
             direccion.tnum2ia,
             direccion.cdet3ia,
             direccion.tnum3ia,
             direccion.localidad,
	     direccion.talias, -- BUG CONF-441 - 14/12/2016 - JAEG
             direccion.fdefecto /* Bug 24780/130907 - 05/12/2012 - AMC*/
        FROM (SELECT cdomici,
                     tdomici,
                     ctipdir,
                     ff_desvalorfijo(191, pac_md_common.f_get_cxtidioma(),
                                     ctipdir) ttipdir,
                     csiglas,
                     tnomvia,
                     nnumvia,
                     tcomple,
                     cpostal,
                     cpoblac,
                     f_despoblac2(cpoblac, p.cprovin) tpoblac,
                     p.cprovin,
                     p.tprovin,
                     p.cpais,
                     ff_despais(p.cpais, pac_md_common.f_get_cxtidioma()) tpais, /* jtg*/
                     d.cviavp,
                     d.clitvp,
                     d.cbisvp,
                     d.corvp,
                     d.nviaadco,
                     d.clitco,
                     d.corco,
                     d.nplacaco,
                     d.cor2co,
                     d.cdet1ia,
                     d.tnum1ia,
                     d.cdet2ia,
                     d.tnum2ia,
                     d.cdet3ia,
                     d.tnum3ia,
                     d.localidad,
		     --d.talias, -- BUG CONF-441 - 14/12/2016 - JAEG
                     (select talias from per_direcciones where sperson = (select spereal from estper_personas where sperson = psperson and rownum = 1) and cdomici = pcdomici) as talias,
                     fdefecto /* Bug 24780/130907 - 05/12/2012 - AMC*/
                FROM estper_direcciones d,
                     provincias         p
               WHERE d.sperson = psperson
                 AND d.cdomici = pcdomici
                 AND p.cprovin(+) = d.cprovin
                 AND ptablas = 'EST'
              UNION ALL
              SELECT cdomici,
                     tdomici,
                     ctipdir,
                     ff_desvalorfijo(191, pac_md_common.f_get_cxtidioma(),
                                     ctipdir) ttipdir,
                     csiglas,
                     tnomvia,
                     nnumvia,
                     tcomple,
                     cpostal,
                     cpoblac,
                     f_despoblac2(cpoblac, p.cprovin) tpoblac,
                     p.cprovin,
                     p.tprovin,
                     p.cpais,
                     ff_despais(p.cpais, pac_md_common.f_get_cxtidioma()) tpais, /* jtg*/
                     d.cviavp,
                     d.clitvp,
                     d.cbisvp,
                     d.corvp,
                     d.nviaadco,
                     d.clitco,
                     d.corco,
                     d.nplacaco,
                     d.cor2co,
                     d.cdet1ia,
                     d.tnum1ia,
                     d.cdet2ia,
                     d.tnum2ia,
                     d.cdet3ia,
                     d.tnum3ia,
                     d.localidad,
		     d.talias, -- BUG CONF-441 - 14/12/2016 - JAEG
                     d.fdefecto /* Bug 24780/130907 - 05/12/2012 - AMC*/
                FROM per_direcciones d,
                     provincias      p
               WHERE d.sperson = psperson
                 AND d.cdomici = pcdomici
                 AND p.cprovin(+) = d.cprovin
                 AND ptablas != 'EST');

      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      IF direccion.csiglas IS NOT NULL
      THEN
         SELECT tsiglas
           INTO direccion.tsiglas
           FROM tipos_via
          WHERE csiglas = direccion.csiglas;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
         /*      WHEN NO_DATA_FOUND THEN*/
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_direccion;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Nueva funcion que se encarga de realizar las validaciones en la introduccion o modificacion de una direccion.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_valida_direccion(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               pctipdir IN NUMBER,
                               pcsiglas IN NUMBER,
                               ptnomvia IN VARCHAR2,
                               pnnumvia IN NUMBER,
                               ptcomple IN VARCHAR2,
                               pcpostal IN VARCHAR2,
                               pcpoblac IN NUMBER, /*Codigo poblacion*/
                               pcprovin IN NUMBER,
                               pcpais   IN NUMBER,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - CtipdiR: ' || pctipdir;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_valida_Direccion';
      dummy    NUMBER;
      pais     NUMBER;
   BEGIN
      IF pctipdir IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000456);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_persona.f_valida_codigosdireccion(pcpais, pcpoblac,
                                                       pcprovin, pcpostal);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_direccion;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
    Nueva funcion que inserta o modifica la direccion de una persona en estper_direcciones.
    return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_direccion(psperson IN NUMBER,
                            pcagente IN NUMBER,
                            pcdomici IN OUT NUMBER,
                            pctipdir IN NUMBER,
                            pcsiglas IN NUMBER,
                            ptnomvia IN VARCHAR2,
                            pnnumvia IN NUMBER,
                            potros   IN VARCHAR2,
                            pcpostal IN VARCHAR2,
                            pcpoblac IN NUMBER,
                            pcprovin IN NUMBER,
                            pcpais   IN NUMBER,
                            mensajes IN OUT t_iax_mensajes,
                            ptablas  IN VARCHAR2,
                            /* Bug 18940/92686 - 27/09/2011 - AMC*/
                            pcviavp   IN estper_direcciones.cviavp%TYPE,
                            pclitvp   IN estper_direcciones.clitvp%TYPE,
                            pcbisvp   IN estper_direcciones.cbisvp%TYPE,
                            pcorvp    IN estper_direcciones.corvp%TYPE,
                            pnviaadco IN estper_direcciones.nviaadco%TYPE,
                            pclitco   IN estper_direcciones.clitco%TYPE,
                            pcorco    IN estper_direcciones.corco%TYPE,
                            pnplacaco IN estper_direcciones.nplacaco%TYPE,
                            pcor2co   IN estper_direcciones.cor2co%TYPE,
                            pcdet1ia  IN estper_direcciones.cdet1ia%TYPE,
                            ptnum1ia  IN estper_direcciones.tnum1ia%TYPE,
                            pcdet2ia  IN estper_direcciones.cdet2ia%TYPE,
                            ptnum2ia  IN estper_direcciones.tnum2ia%TYPE,
                            pcdet3ia  IN estper_direcciones.cdet3ia%TYPE,
                            ptnum3ia  IN estper_direcciones.tnum3ia%TYPE,
                            /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
                            plocalidad IN estper_direcciones.localidad%TYPE, /* Bug 24780/130907 - 05/12/2012 - AMC*/
			    ptalias    IN estper_direcciones.talias%TYPE)     -- BUG CONF-441 - 14/12/2016 - JAEG
      RETURN NUMBER IS
      vnumerr           NUMBER(8) := 0;
      vpasexec          NUMBER(8) := 1;
      vparam            VARCHAR2(500) := 'parametros - psperson: ' ||
                                         psperson || ' cagente:' ||
                                         pcagente;
      vobject           VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_Direccion';
      verrores          t_ob_error;
      vtdomici          estper_direcciones.tdomici%TYPE;
      vmdireccionreqaut NUMBER;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pctipdir <> 99
      THEN
         /* CTIPDIR 99 es dirección desimulaciones que no necesita validación*/
         vnumerr := f_valida_direccion(psperson, pcagente, pctipdir,
                                       pcsiglas, ptnomvia, pnnumvia, potros,
                                       pcpostal, pcpoblac, pcprovin, pcpais,
                                       mensajes);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;

         /*Inicio Mantis 33515/215632  - BLA - DD15/MM10/2015.*/
         vnumerr := pac_propio.f_valdireccion(pcviavp, ptnomvia, pcdet1ia,
                                              ptnum1ia, pcdet2ia, ptnum2ia,
                                              pcdet3ia, ptnum3ia, pnnumvia,
                                              potros);

         /*Fin Mantis 33515/215632  - BLA - DD15/MM10/2015.*/
         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      vtdomici := pac_persona.f_tdomici(pcsiglas, ptnomvia, pnnumvia, potros,
                                        pcviavp, pclitvp, pcbisvp, pcorvp,
                                        pnviaadco, pclitco, pcorco, pnplacaco,
                                        pcor2co, pcdet1ia, ptnum1ia, pcdet2ia,
                                        ptnum2ia, pcdet3ia, ptnum3ia,
                                        plocalidad
                                         /* Bug 24780/130907 - 05/12/2012 - AMC*/);

      /* Bug 18949/103391 - 03/02/2012 - AMC*/
      IF ptablas = 'POL' AND
         pcdomici IS NOT NULL
      THEN
         /* vmdireccionreqaut := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),*/
         /*                                                   'M_DIRECCION_REQ_AUT');*/
         vnumerr := pac_cfg.f_get_user_accion_permitida(f_user,
                                                        'AUTORIZACION_DIRECCIONES',
                                                        0,
                                                        pac_md_common.f_get_cxtempresa(),
                                                        vmdireccionreqaut);

         IF NVL(vmdireccionreqaut, 0) = 1
         THEN
            vnumerr  := pac_persona.f_ins_direccion_aut(psperson, pcagente,
                                                        pcdomici, pctipdir,
                                                        pcsiglas, ptnomvia,
                                                        pnnumvia, potros,
                                                        vtdomici, pcpostal,
                                                        pcpoblac, pcprovin,
                                                        NULL, NULL,
                                                        pac_md_common.f_get_cxtidioma(),
                                                        verrores, 'M',
                                                        pcviavp, pclitvp,
                                                        pcbisvp, pcorvp,
                                                        pnviaadco, pclitco,
                                                        pcorco, pnplacaco,
                                                        pcor2co, pcdet1ia,
                                                        ptnum1ia, pcdet2ia,
                                                        ptnum2ia, pcdet3ia,
                                                        ptnum3ia, plocalidad
                                                         /* Bug 24780/130907 - 05/12/2012 - AMC*/);
            mensajes := f_traspasar_errores_mensajes(verrores);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         ELSE
            vnumerr  := pac_persona.f_set_direccion(psperson, pcagente,
                                                    pcdomici, pctipdir,
                                                    pcsiglas, ptnomvia,
                                                    pnnumvia, potros,
                                                    vtdomici, pcpostal,
                                                    pcpoblac, pcprovin, NULL,
                                                    NULL,
                                                    pac_md_common.f_get_cxtidioma(),
                                                    verrores, ptablas,
                                                    pcviavp, pclitvp, pcbisvp,
                                                    pcorvp, pnviaadco,
                                                    pclitco, pcorco,
                                                    pnplacaco, pcor2co,
                                                    pcdet1ia, ptnum1ia,
                                                    pcdet2ia, ptnum2ia,
                                                    pcdet3ia, ptnum3ia,
                                                    plocalidad,
						    ptalias -- BUG CONF-441 - 14/12/2016 - JAEG
                                                     /* Bug 24780/130907 - 05/12/2012 - AMC*/);
            mensajes := f_traspasar_errores_mensajes(verrores);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         END IF;
      ELSE
         vnumerr  := pac_persona.f_set_direccion(psperson, pcagente,
                                                 pcdomici, pctipdir, pcsiglas,
                                                 ptnomvia, pnnumvia, potros,
                                                 vtdomici, pcpostal, pcpoblac,
                                                 pcprovin, NULL, NULL,
                                                 pac_md_common.f_get_cxtidioma(),
                                                 verrores, ptablas, pcviavp,
                                                 pclitvp, pcbisvp, pcorvp,
                                                 pnviaadco, pclitco, pcorco,
                                                 pnplacaco, pcor2co, pcdet1ia,
                                                 ptnum1ia, pcdet2ia, ptnum2ia,
                                                 pcdet3ia, ptnum3ia,
                                                 plocalidad,
																 ptalias -- BUG CONF-441 - 14/12/2016 - JAEG
                                                  /* Bug 24780/130907 - 05/12/2012 - AMC*/);
         mensajes := f_traspasar_errores_mensajes(verrores);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END IF;

      /* Fi Bug 18949/103391 - 03/02/2012 - AMC*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 10000055,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 10000066,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 10000011,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_direccion;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene las direcciones del sperson
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_cuentasbancarias(psperson  IN NUMBER,
                                   pcagente  IN NUMBER,
                                   pfvigente IN DATE, /*xvm:bug 6466*/
                                   ccc       OUT t_iax_ccc,
                                   mensajes  IN OUT t_iax_mensajes,
                                   ptablas   IN VARCHAR2,
                                   pctipcc   IN NUMBER DEFAULT NULL
                                   /* 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_cuentasbancarias';
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ccc := t_iax_ccc();

      FOR reg IN (SELECT sperson,
                         cnordban
                    FROM estccc       c,
                         tipos_cuenta t
                  /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                   WHERE sperson = psperson
                     AND (fbaja > pfvigente OR pfvigente IS NULL OR
                         fbaja IS NULL)
                     AND ptablas = 'EST'
                        /* 20735 LCOL_A001-ADM - Introduccion de cuenta bancaria - 03/01/2012 - Inici*/
                        /*             -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici*/
                     AND t.ctipban = c.ctipban
                        /*             AND((NVL(t.ctipcc, 1) = 1*/
                        /*                  AND NVL(pctipcc, 1) = 1)*/
                        /*                 OR(NVL(t.ctipcc, 1) <> 1*/
                        /*                    AND NVL(pctipcc, 1) <> 1))*/
                        /*             -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi*/
                     AND ((NVL(t.ctipcc, 1) NOT IN (2, 4, 5, 6, 7, 9) AND
                         NVL(pctipcc, 1) = 1) OR
                         (NVL(t.ctipcc, 1) IN (2, 4, 5, 6, 7, 9) AND
                         NVL(pctipcc, 2) <> 1)) /* bug 36097 / c210485 - 04/08/15 JR*/
                  /* 20735 LCOL_A001-ADM - Introduccion de cuenta bancaria - 03/01/2012 - Fi*/
                  UNION ALL
                  SELECT sperson,
                         cnordban
                    FROM per_ccc      c,
                         tipos_cuenta t
                  /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                   WHERE sperson = psperson
                     AND
                        --INICIO Bug 38462
                        --cagente=pcagente AND
                         cagente = ff_agente_cpervisio(pcagente)
                     AND
                        --FIN Bug 38462
                         (fbaja > pfvigente OR pfvigente IS NULL OR
                         fbaja IS NULL)
                     AND ptablas != 'EST'
                        /* 20735 LCOL_A001-ADM - Introduccion de cuenta bancaria - 03/01/2012 - Inici*/
                        /*             -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici*/
                     AND t.ctipban = c.ctipban
                        /*             AND((NVL(t.ctipcc, 1) = 1*/
                        /*                  AND NVL(pctipcc, 1) = 1)*/
                        /*                 OR(NVL(t.ctipcc, 1) <> 1*/
                        /*                    AND NVL(pctipcc, 1) <> 1))*/
                        /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi*/
                     AND ((NVL(t.ctipcc, 1) NOT IN (2, 4, 5, 6, 7, 9) AND
                         NVL(pctipcc, 1) = 1) OR
                         (NVL(t.ctipcc, 1) IN (2, 4, 5, 6, 7, 9) AND
                         NVL(pctipcc, 2) <> 1)) /* bug 36097 / c210485 - 04/08/15 JR*/
                  /* 20735 LCOL_A001-ADM - Introduccion de cuenta bancaria - 03/01/2012 - Fi*/
                  )
      LOOP
         ccc.extend;
         vnumerr := f_get_ccc(reg.sperson, reg.cnordban, ccc(ccc.last),
                              mensajes, ptablas);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 2;
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cuentasbancarias;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Borra una cuenta.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_del_ccc(psperson  IN NUMBER,
                      pcnordban IN NUMBER,
                      mensajes  IN OUT t_iax_mensajes,
                      ptablas   IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      a        NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson || ' ' ||
                                pcnordban;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_del_CCC';
      vccc     ob_iax_ccc := ob_iax_ccc();
      errores  t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcnordban IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*-------  -- svj bug 0005912*/
      vnumerr := f_get_ccc(psperson, pcnordban, vccc, mensajes, ptablas);

      IF vccc IS NULL
      THEN
         /*no existeix la ccc o ha petat.*/
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 102413);
         RAISE e_object_error;
      ELSIF vccc.fbaja IS NOT NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000583);
         RAISE e_object_error;
      END IF;

      pac_persona.p_del_ccc(psperson, pcnordban,
                            pac_md_common.f_get_cxtidioma(), errores,
                            ptablas);
      vpasexec := 2;
      mensajes := f_traspasar_errores_mensajes(errores);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_ccc;

   FUNCTION f_del_nacionalidad(psperson IN NUMBER,
                               pcpais   IN NUMBER,
                               pcagente IN NUMBER,
                               mensajes IN OUT t_iax_mensajes,
                               ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr       NUMBER(8) := 0;
      a             NUMBER;
      vpasexec      NUMBER(8) := 1;
      vparam        VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                     'pcpais ' || pcpais;
      vobject       VARCHAR2(200) := 'PAC_MD_PERSONA.F_del_nacionalidad';
      vnacionalidad ob_iax_nacionalidades := ob_iax_nacionalidades();
      errores       t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcpais IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*-------  -- svj bug 0005912*/
      vnumerr := f_get_nacionalidad(psperson, pcpais, pcagente,
                                    vnacionalidad, mensajes, ptablas);

      IF vnacionalidad IS NULL
      THEN
         /*no existeix la nacionalitat o ha petat.*/
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      pac_persona.p_del_nacionalidad(psperson, pcpais, pcagente, errores,
                                     pac_md_common.f_get_cxtidioma(),
                                     ptablas);
      vpasexec := 2;
      mensajes := f_traspasar_errores_mensajes(errores);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_nacionalidad;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Nueva funcion que se encarga de recuperar una cuenta bancaria de una persona.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_ccc(psperson  IN NUMBER,
                      pcnordban IN NUMBER,
                      ccc       OUT ob_iax_ccc,
                      mensajes  IN OUT t_iax_mensajes,
                      ptablas   IN VARCHAR2,
                      pfvigente IN DATE DEFAULT NULL) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson || ' ' ||
                                pcnordban;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_CCC';
   BEGIN
      vpasexec := 1;
      ccc      := ob_iax_ccc.instanciar(1);

      BEGIN
         SELECT ctipban,
                cbancar,
                fbaja,
                cdefecto,
                cusumov,
                fusumov,
                cnordban,
                cvalida,
                cpagsin,
                fvencim,
                tseguri,
                falta,
                cusualta
           INTO ccc.ctipban,
                ccc.cbancar,
                ccc.fbaja,
                ccc.cdefecto,
                ccc.cusumov,
                ccc.fusumov,
                ccc.cnordban,
                ccc.cvalida,
                ccc.cpagsin,
                ccc.fvencim,
                ccc.tseguri,
                ccc.falta,
                ccc.cusualta
         /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
           FROM (SELECT ctipban,
                        cbancar,
                        fbaja,
                        cdefecto,
                        cusumov,
                        fusumov,
                        cnordban,
                        cvalida,
                        cpagsin,
                        fvencim,
                        tseguri,
                        falta,
                        cusualta
                 /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                   FROM estper_ccc
                  WHERE sperson = psperson
                    AND cnordban = pcnordban
                    AND (fbaja > pfvigente OR pfvigente IS NULL OR
                        fbaja IS NULL)
                    AND ptablas = 'EST'
                 UNION ALL
                 SELECT ctipban,
                        cbancar,
                        fbaja,
                        cdefecto,
                        cusumov,
                        fusumov,
                        cnordban,
                        cvalida,
                        cpagsin,
                        fvencim,
                        tseguri,
                        falta,
                        cusualta
                 /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                   FROM per_ccc
                  WHERE sperson = psperson
                    AND cnordban = pcnordban
                    AND (fbaja > pfvigente OR pfvigente IS NULL OR
                        fbaja IS NULL)
                    AND ptablas != 'EST');

         /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Inici*/
         BEGIN
            /*Bug 26857-XVM-27/06/2013*/
            SELECT f_descentidadsin(SUBSTR(ccc.cbancar, t.pos_entidad,
                                           t.long_entidad)),
                   NVL(t.ctipcc, 1),
                   ff_desvalorfijo(800049, pac_md_common.f_get_cxtidioma,
                                   t.ctipcc),
                   ff_desvalorfijo(386, pac_md_common.f_get_cxtidioma(),
                                   ccc.cvalida)
            /* 22 16/11/2011 19985-LCOL_A001-Control de las matriculas (nota: 0097969)*/
              INTO ccc.tbanco,
                   ccc.ctipcc,
                   ccc.ttiptarj,
                   ccc.tvalida
            /* 22 16/11/2011 19985-LCOL_A001-Control de las matriculas (nota: 0097969)*/
              FROM tipos_cuenta t
             WHERE t.ctipban = ccc.ctipban;
         EXCEPTION
            WHEN OTHERS THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 806204);
               RETURN 1;
         END;
         /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones) - Fi*/
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 806204);
            RETURN 1;
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 806204);
            RETURN 1;
      END;

      vpasexec := 2;

      BEGIN
         SELECT d.ttipo
           INTO ccc.ttipban
           FROM tipos_cuenta    c,
                tipos_cuentades d
          WHERE c.ctipban = d.ctipban
            AND d.cidioma = pac_md_common.f_get_cxtidioma
            AND c.ctipban = ccc.ctipban;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 806206);
            RETURN 1;
      END;

      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_ccc;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
       Nueva funcion que se encarga de recuperar la povicincia y poblacion a partir de un codigo postal
       A partir de un codigo postal obtenemos los codigos de pais, provincia, poblacion y sus respectivas  descripciones.
       return              : 0 si ha ido todo bien 1 si ha ido mal
       return : 0 si no ha encontrado coincidencias.
                1 si existe algun error.
                2 si existe mas de una provincia, pais o poblacion con el
                  codigo postal relacionado.
   *************************************************************************/
   FUNCTION f_get_provinpobla(pcodpostal IN VARCHAR2,
                              pcpais     OUT NUMBER,
                              ptpais     OUT VARCHAR2,
                              pcprovin   OUT NUMBER,
                              ptprovin   OUT VARCHAR2,
                              pcpoblac   OUT NUMBER,
                              ptpoblac   OUT VARCHAR2,
                              pautocalle OUT NUMBER, /* 34989/209710*/
                              mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      a        NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - pCodpostal: ' || pcodpostal || ' ' ||
                                pcodpostal;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_ProvinPobla';
   BEGIN
      /**/
      pautocalle := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                      'AUTORELLENA_CALLE'), 0);

      /**/
      IF pcodpostal IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /**/
      BEGIN
         /**/
         SELECT dp.cpais,
                dp.tpais,
                p.cprovin,
                p.tprovin,
                pb.cpoblac,
                DECODE(pautocalle, 1,
                       SUBSTR(pb.tpoblac, 1, INSTR(pb.tpoblac, '-', -1) - 1),
                       pb.tpoblac)
           INTO pcpais,
                ptpais,
                pcprovin,
                ptprovin,
                pcpoblac,
                ptpoblac
           FROM despaises   dp,
                provincias  p,
                poblaciones pb,
                codpostal   cp
          WHERE dp.cpais = p.cpais
            AND dp.cidioma = pac_md_common.f_get_cxtidioma()
            AND p.cprovin = pb.cprovin
            AND cp.cpostal = pcodpostal
            AND p.cprovin = cp.cprovin
            AND pb.cpoblac = cp.cpoblac;

         /**/
         vnumerr := 0;
         /**/
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            /**/
            vnumerr := 0;
            /**/
            pcpais   := NULL;
            ptpais   := NULL;
            pcprovin := NULL;
            ptprovin := NULL;
            pcpoblac := NULL;
            ptpoblac := NULL;
            /**/
         WHEN TOO_MANY_ROWS THEN
            /**/
            vnumerr := 2;
            /**/
            pcpais   := NULL;
            ptpais   := NULL;
            pcprovin := NULL;
            ptprovin := NULL;
            pcpoblac := NULL;
            ptpoblac := NULL;
            /**/
         WHEN OTHERS THEN
            vnumerr := 1;
      END;

      /**/
      RETURN vnumerr;
      /**/
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_provinpobla;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Esta nueva funci??n se encarga de grabar  un identificador
     return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_identificador(psperson  IN NUMBER,
                                pcagente  IN NUMBER,
                                pctipide  IN NUMBER,
                                pnnumide  IN VARCHAR2,
                                pcdefecto IN NUMBER,
                                mensajes  IN OUT t_iax_mensajes,
                                ptablas   IN VARCHAR2,
                                /* Bug 22263 - 11/07/2012 - ETM*/
                                ppaisexp    IN NUMBER DEFAULT NULL,
                                pcdepartexp IN NUMBER DEFAULT NULL,
                                pcciudadexp IN NUMBER DEFAULT NULL,
                                pfechaexp   IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par?!metros - psperson: ' || psperson ||
                                ' pcagente:' || pcagente || ' pCtipide:' ||
                                pctipide || ' pNNUMIDE:' || pnnumide ||
                                ' CPAISEXP:' || ppaisexp || ' CDEPARTEXP:' ||
                                pcdepartexp || ' CCIUDADEXP:' ||
                                pcciudadexp || ' FECHAEXP:' || pfechaexp;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_Identificador';
      errores  t_ob_error;
      vnif     VARCHAR2(50);
      /* 09/06/2009 : ETM : bug 0010342: IAX - validaci??n del NRN no funciona--INI */
      per personas%ROWTYPE;
      /* 09/06/2009 : ETM : bug 0010342: IAX - validaci??n del NRN no funciona--fIN */
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnif := pnnumide;
      /* 09/06/2009 : ETM : bug 0010342: IAX - validaci??n del NRN no funciona--INI */
      vnumerr := pac_persona.f_get_dadespersona(psperson, pcagente, per);

      IF vnumerr = 0
      THEN
         vnumerr := pac_persona.f_validanif(vnif, pctipide, per.csexper,
                                            per.fnacimi);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
         RAISE e_object_error;
      END IF;

      /*Bug 25349 - XVM - 27/12/2012*/
      vnumerr := pac_persona.f_existe_identificador(vnif, pctipide, psperson);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      /*
         IF pctipide <> 8 THEN
       vnumerr := f_nif(vnif);

       IF vnumerr <> 0 THEN
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
          RAISE e_object_error;
       END IF;
      END IF;
      */
      /* 09/06/2009 : ETM : bug 0010342: IAX - validaci??n del NRN no funciona--fIN */
      vnumerr  := pac_persona.f_set_identificador(psperson, pcagente,
                                                  pctipide, pnnumide, errores,
                                                  pcdefecto, ptablas,
                                                  pac_md_common.f_get_cxtidioma(),
                                                  ppaisexp, pcdepartexp,
                                                  pcciudadexp, pfechaexp);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_identificador;

   /*************************************************************************
     Esta nueva funci??n se encarga de modificar un identificador
     return              : 0 si ha ido todo bien , 1 en caso contrario.

     Bug 20441/101686 - 10/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_mod_identificador(psperson  IN NUMBER,
                                pcagente  IN NUMBER,
                                pctipide  IN NUMBER,
                                pnnumide  IN VARCHAR2,
                                pcdefecto IN NUMBER,
                                mensajes  IN OUT t_iax_mensajes,
                                ptablas   IN VARCHAR2,
                                /* Bug 22263 - 11/07/2012 - ETM*/
                                ppaisexp    IN NUMBER DEFAULT NULL,
                                pcdepartexp IN NUMBER DEFAULT NULL,
                                pcciudadexp IN NUMBER DEFAULT NULL,
                                pfechaexp   IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par?!metros - psperson: ' || psperson ||
                                ' pcagente:' || pcagente || ' pCtipide:' ||
                                pctipide || ' pNNUMIDE:' || pnnumide ||
                                ' CPAISEXP:' || ppaisexp || ' CDEPARTEXP:' ||
                                pcdepartexp || ' CCIUDADEXP:' ||
                                pcciudadexp || ' FECHAEXP:' || pfechaexp;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_mod_Identificador';
      errores  t_ob_error;
      vnif     VARCHAR2(50);
      /* 09/06/2009 : ETM : bug 0010342: IAX - validaci??n del NRN no funciona--INI */
      per personas%ROWTYPE;
      /* 09/06/2009 : ETM : bug 0010342: IAX - validaci??n del NRN no funciona--fIN */
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnif := pnnumide;
      /* 09/06/2009 : ETM : bug 0010342: IAX - validaci??n del NRN no funciona--INI */
      vnumerr := pac_persona.f_get_dadespersona(psperson, pcagente, per);

      IF vnumerr = 0
      THEN
         vnumerr := pac_persona.f_validanif(vnif, pctipide, per.csexper,
                                            per.fnacimi);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
         RAISE e_object_error;
      END IF;

      /* 09/06/2009 : ETM : bug 0010342: IAX - validaci??n del NRN no funciona--fIN */
      vnumerr  := pac_persona.f_mod_identificador(psperson, pcagente,
                                                  pctipide, pnnumide, errores,
                                                  pcdefecto, ptablas,
                                                  pac_md_common.f_get_cxtidioma(),
                                                  ppaisexp, pcdepartexp,
                                                  pcciudadexp, pfechaexp);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_mod_identificador;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Esta nueva funcion se encarga de grabar  un identificador
     return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_del_identificador(psperson IN NUMBER,
                                pcagente IN NUMBER,
                                pctipide IN NUMBER,
                                mensajes IN OUT t_iax_mensajes,
                                ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' cagente:' || pcagente || ' Ctipide:' ||
                                pctipide;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_del_Identificador';
      vnum_err NUMBER := 0;
   BEGIN
      IF psperson IS NULL OR
         pctipide IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*Borrar de las tablas estper_ccc*/
      vnum_err := pac_persona.f_del_ident(psperson, pcagente, pctipide,
                                          pac_md_common.f_get_cxtidioma(),
                                          ptablas);
      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_identificador;

   /*************************************************************************
   Obtiene los datos de los identificadores en un T_IAX_IDENTIFICADORES
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_identificadores(psperson         IN NUMBER,
                                  pcagente         IN NUMBER,
                                  pidentificadores OUT t_iax_identificadores,
                                  mensajes         IN OUT t_iax_mensajes,
                                  ptablas          IN VARCHAR2) RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_identificadores';
      dummy          NUMBER;
      pidentificador ob_iax_identificadores;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec         := 1;
      pidentificadores := t_iax_identificadores();
      pidentificadores.delete;
      vpasexec := 2;
      vpasexec := 3;

      /* Bug 22263 - 11/07/2012 - ETM*/
      FOR reg IN (SELECT cagente,
                         sperson,
                         ctipide,
                         NULL    cpaisexp,
                         NULL    cdepartexp,
                         NULL    cciudadexp,
                         NULL    fechadexp
                    FROM estidentificadores
                   WHERE sperson = psperson
                     AND ptablas = 'EST'
                  UNION ALL
                  SELECT cagente,
                         sperson,
                         ctipide,
                         cpaisexp,
                         cdepartexp,
                         cciudadexp,
                         fechadexp
                    FROM per_identificador
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND ptablas != 'EST')
      LOOP
         vnumerr := f_get_identificador(reg.sperson, reg.cagente,
                                        reg.ctipide, pidentificador, mensajes,
                                        ptablas);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;

         pidentificadores.extend;

         IF reg.cpaisexp IS NOT NULL
         THEN
            pidentificador.tpaisexp := ff_despais(reg.cpaisexp,
                                                  pac_md_common.f_get_cxtidioma());
         ELSE
            pidentificador.tpaisexp := NULL;
         END IF;

         IF reg.cdepartexp IS NOT NULL
         THEN
            pidentificador.tdepartexp := f_desprovin2(reg.cdepartexp,
                                                      reg.cpaisexp);
         ELSE
            pidentificador.tdepartexp := NULL;
         END IF;

         IF reg.cciudadexp IS NOT NULL
         THEN
            pidentificador.tciudadexp := f_despoblac2(reg.cciudadexp,
                                                      reg.cdepartexp);
         ELSE
            pidentificador.tciudadexp := NULL;
         END IF;

         pidentificadores(pidentificadores.last) := pidentificador;
      END LOOP;

      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_identificadores;

   /*************************************************************************
   Obtiene los datos de un tipo de identificador en un ob_iax_IDENTIFICADORES
   param out mensajes  : pIdentificadores que es ob_iax_IDENTIFICADORES
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_get_identificador(psperson         IN NUMBER,
                                pcagente         IN NUMBER,
                                pctipide         IN NUMBER,
                                pidentificadores OUT ob_iax_identificadores,
                                mensajes         IN OUT t_iax_mensajes,
                                ptablas          IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson || ' ' ||
                                pctipide;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Identificador';
      dummy    NUMBER;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec         := 1;
      pidentificadores := ob_iax_identificadores();
      vpasexec         := 2;

      /* Bug 22263 - 11/07/2012 - ETM*/
      SELECT ctipide,
             nnumide,
             swidepri,
             femisio,
             fcaduca,
             cpaisexp,
             cdepartexp,
             cciudadexp,
             fechadexp
        INTO pidentificadores.ctipide,
             pidentificadores.nnumide,
             pidentificadores.swidepri,
             pidentificadores.femisio,
             pidentificadores.fcaduca,
             pidentificadores.cpaisexp,
             pidentificadores.cdepartexp,
             pidentificadores.cciudadexp,
             pidentificadores.fechadexp
        FROM (SELECT ctipide,
                     nnumide,
                     swidepri,
                     femisio,
                     fcaduca,
                     NULL     cpaisexp,
                     NULL     cdepartexp,
                     NULL     cciudadexp,
                     NULL     fechadexp
                FROM estidentificadores
               WHERE sperson = psperson
                 AND ptablas = 'EST'
                 AND ctipide = pctipide
              UNION ALL
              SELECT ctipide,
                     nnumide,
                     swidepri,
                     femisio,
                     fcaduca,
                     cpaisexp,
                     cdepartexp,
                     cciudadexp,
                     fechadexp
                FROM per_identificador
               WHERE sperson = psperson
                 AND cagente = pcagente
                 AND ptablas != 'EST'
                 AND ctipide = pctipide);

      vpasexec                 := 3;
      pidentificadores.ttipide := pac_md_listvalores.f_getdescripvalores(672,
                                                                         pidentificadores.ctipide,
                                                                         mensajes);
      vpasexec                 := 4;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_identificador;

   /*************************************************************************
      Recupera la lista de valores del desplegable sexo
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipcontactos(mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_MD_persona.F_Get_TipContactos';
      terror   VARCHAR2(200) := 'Error recuperar tipos de TipContactos';
      /*//ACC recuperar desde literales*/
      /*//ACC recuperar desde literales*/
      /*//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);*/
   BEGIN
      cur := pac_md_listvalores.f_detvalores(15, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipcontactos;

   FUNCTION f_get_poltom(psperson IN NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      cur      SYS_REFCURSOR;
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_PolTom';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*BUG 10074 - JTS - 18/05/2009*/
      vnumerr := pac_persona.f_get_poltom(psperson,
                                          pac_md_common.f_get_cxtidioma,
                                          squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      /*Fi BUG 10074 - JTS - 18/05/2009*/
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN cur;
   END f_get_poltom;

   FUNCTION f_get_polase(psperson IN NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      cur      SYS_REFCURSOR;
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_PolAse';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*BUG 10074 - JTS - 18/05/2009*/
      vnumerr := pac_persona.f_get_polase(psperson,
                                          pac_md_common.f_get_cxtidioma,
                                          squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      /*Fi BUG 10074 - JTS - 18/05/2009*/
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN cur;
   END f_get_polase;

   /*************************************************************************
   Obtiene los datos de una persona pasandole el nif, sexo y fecha nacimiento
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_personaunica(pctipper    IN NUMBER,
                               pctipide    IN NUMBER,
                               pnnumnif    IN VARCHAR2,
                               pcsexper    IN NUMBER,
                               pfnacimi    IN DATE,
                               pmodo       IN VARCHAR2,
                               psseguro    IN NUMBER,
                               pcagente    IN NUMBER,
                               pswpubli    IN NUMBER,
                               ptablas     IN VARCHAR2,
                               ppduplicada IN NUMBER,
                               mensajes    OUT t_iax_mensajes)
      RETURN ob_iax_personas IS
      vnumerr          NUMBER(8) := 0;
      persona          ob_iax_personas := ob_iax_personas();
      vcempres         NUMBER := pac_md_common.f_get_cxtempresa;
      vpasexec         NUMBER(8) := 1;
      vparam           VARCHAR2(500) := 'parametros - pctipper: ' ||
                                        pctipper || ' - pctipide: ' ||
                                        pctipide || ' - pnnumnif: ' ||
                                        pnnumnif || ' - pcsexper: ' ||
                                        pcsexper || ' - pfnacimi: ' ||
                                        pfnacimi || ' - pmodo: ' || pmodo ||
                                        ' - psseguro: ' || psseguro ||
                                        ' - pcagente: ' || pcagente ||
                                        ' - pswpubli: ' || pswpubli ||
                                        ' - ptablas: ' || ptablas ||
                                        ' -ppduplicada:' || ppduplicada;
      vobject          VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_personaunica';
      vmensapop        VARCHAR2(500);
      numpers          NUMBER := NULL;
      vsperson2        NUMBER;
      vcoditablas      VARCHAR2(100);
      numerr           NUMBER;
      pnacionalidades  t_iax_nacionalidades;
      pdirecciones     t_iax_direcciones;
      pccc             t_iax_ccc;
      pcontactos       t_iax_contactos;
      pidentificadores t_iax_identificadores;
      irpfs            t_iax_irpf;
      obirpf           ob_iax_irpf;
      objdirecciones   ob_iax_direcciones;
      objccc           ob_iax_ccc;
      vcpais           NUMBER;
      vtpais           VARCHAR2(500);
      vcagente         NUMBER;
      /* Bug 18225 - APD - 11/04/2011 - la precision de cdelega debe ser NUMBER*/
      vcagente2 NUMBER;
      /* Bug 18225 - APD - 11/04/2011 - la precision de cdelega debe ser NUMBER*/
      vcagente_per NUMBER;
      /* Bug 18225 - APD - 11/04/2011 - la precision de cdelega debe ser NUMBER*/
      vpersonunica      NUMBER;
      vsnipaut          NUMBER;
      vpersonanova      NUMBER := 0;
      vpervisionpublica NUMBER; /*Bug 29166/160004 - 29/11/2013 - AMC*/
   BEGIN
      vpasexec := 1;
      /*   per_ducplicar posibles valores:
            1 : Persona unica por snip
           2:  Persona unica por nnumide
           3:  Persona unica por nnumide, fnacimi y sexo
           4: Se permite duplicados (se puede realizar por perfil cfg's duplicanif y cargapersona cfg's)
      */
      vpersonunica := NVL(pac_parametros.f_parempresa_n(vcempres,
                                                        'PER_DUPLICAR'), 4);
      vpasexec     := 2;
      vsnipaut     := NVL(pac_parametros.f_parempresa_n(vcempres,
                                                        'SNIP_AUTOMATICO'), 0);
      vpasexec     := 3;
      vcpais       := f_parinstalacion_n('PAIS_DEF');
      vtpais       := ff_despais(vcpais);
      vpasexec     := 4;
      /*Bug 29166/160004 - 29/11/2013 - AMC*/
      vpervisionpublica := NVL(pac_parametros.f_parempresa_n(vcempres,
                                                             'PER_VISIONPUBLICA'),
                               0);

      IF ptablas = 'POL' AND
         NVL(ppduplicada, 0) = 0
      THEN
         IF vpersonunica = 2
         THEN
            /* POR NNUMIDE*/
            vpasexec := 5;

            BEGIN
               SELECT p.sperson
                 INTO numpers
                 FROM per_personas p
                WHERE p.nnumide = pnnumnif
                     /*AND swpubli = NVL(pswpubli, swpubli)*/
                  AND swpubli =
                      DECODE(vpervisionpublica, 0, NVL(pswpubli, swpubli),
                             swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                  AND ROWNUM = 1 /* sE PONE ESTO DEBIDO A QUE LOS DATOS EN BASE DE DATOS ESTAN MAL EN DESA.*/
                  AND (pcagente IS NULL OR
                      pcagente IN
                      (SELECT cagente
                          FROM per_detper d
                         WHERE d.sperson = p.sperson));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT p.sperson
                       INTO numpers
                       FROM per_personas p
                      WHERE p.nnumide = pnnumnif
                           /* AND swpubli = NVL(pswpubli, swpubli)*/
                        AND swpubli =
                            DECODE(vpervisionpublica, 0,
                                   NVL(pswpubli, swpubli), swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                        AND ROWNUM = 1; /* sE PONE ESTO DEBIDO A QUE LOS DATOS EN BASE DE DATOS ESTAN MAL EN DESA.;*/
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        numpers := NULL;
                  END;
            END;
         ELSIF vpersonunica = 3
         THEN
            /* POR NNUMIDE, FNACIMI, CSEXPER*/
            vpasexec := 6;

            BEGIN
               SELECT sperson
                 INTO numpers
                 FROM per_personas p
                WHERE ((p.nnumide = pnnumnif AND p.ctipper = 2) /* Juridica*/
                      OR (p.nnumide = pnnumnif AND p.csexper = pcsexper AND
                      p.fnacimi = pfnacimi AND p.ctipper != 2) /*fisica*/
                      )
                     /*AND p.swpubli = NVL(pswpubli, swpubli)   -- t.9318*/
                  AND swpubli =
                      DECODE(vpervisionpublica, 0, NVL(pswpubli, swpubli),
                             swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                  AND ROWNUM = 1 /* sE PONE ESTO DEBIDO A QUE LOS DATOS EN BASE DE DATOS ESTAN MAL EN DESA.*/
                  AND (pcagente IS NULL OR
                      pcagente IN
                      (SELECT cagente
                          FROM per_detper d
                         WHERE d.sperson = p.sperson));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT sperson
                       INTO numpers
                       FROM per_personas p
                      WHERE ((p.nnumide = pnnumnif AND p.ctipper = 2) /* Juridica*/
                            OR
                            (p.nnumide = pnnumnif AND p.csexper = pcsexper AND
                            p.fnacimi = pfnacimi AND p.ctipper != 2) /*fisica*/
                            )
                           /*AND p.swpubli = NVL(pswpubli, swpubli)*/
                        AND p.swpubli =
                            DECODE(vpervisionpublica, 0,
                                   NVL(pswpubli, swpubli), p.swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                        AND ROWNUM = 1; /* sE PONE ESTO DEBIDO A QUE LOS DATOS EN BASE DE DATOS ESTAN MAL EN DESA.;*/
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        numpers := NULL;
                  END;
            END;
         ELSIF vpersonunica IN (1, 4, 5)
         THEN
            /* POR SNIP*/
            vpasexec := 7;
            numpers  := NULL; /*Nueva persona*/
         END IF;

         vpasexec := 8;

         /* sI EXISTE LA PERSONA*/
         BEGIN
            /* En este punto estamos desde el mant. de personas o alta de agentes,*/
            SELECT pd.cagente
              INTO vcagente
              FROM per_detper pd
             WHERE pd.sperson = numpers
               AND (cagente = pcagente OR
                   (pcagente IS NULL AND
                   cagente = pac_md_common.f_get_cxtagente) OR
                   pswpubli = 1);

            vpasexec := 9;
            persona  := f_get_persona(numpers, vcagente, mensajes, ptablas);
            vpasexec := 10;

            IF vsnipaut = 1 AND
               persona.snip IS NULL
            THEN
               SELECT snip.nextval INTO persona.snip FROM dual;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL; /* no tenemos detalle, se tiene que crear*/
         END;

         vpasexec := 10;

         /*XPL 11079 07102009*/
         IF vsnipaut = 1 AND
            persona.snip IS NULL
         THEN
            SELECT snip.nextval INTO persona.snip FROM dual;
         END IF;

         vpasexec        := 11;
         persona.ctipper := pctipper;
         vpasexec        := 12;

         IF pctipide IS NOT NULL
         THEN
            persona.ttipide := ff_desvalorfijo(672,
                                               pac_md_common.f_get_cxtidioma(),
                                               pctipide);
         END IF;

         vpasexec        := 13;
         persona.ctipide := pctipide;
         vpasexec        := 14;

         IF pctipide = 0 AND
            pnnumnif IS NULL
         THEN
            vnumerr := f_snnumnif('Z', persona.nnumide);
         ELSIF pctipide = 96 AND
               pnnumnif IS NULL
         THEN
            vnumerr := f_snnumnif('4', persona.nnumide);
         ELSE
            persona.nnumide := pnnumnif;
         END IF;

         vpasexec := 15;

         IF pcsexper IS NOT NULL
         THEN
            persona.csexper := pcsexper;
         END IF;

         vpasexec := 16;

         IF pfnacimi IS NOT NULL
         THEN
            persona.fnacimi := pfnacimi;
         END IF;

         vpasexec := 17;

         IF vpersonunica = 2 AND
            pcsexper IS NULL AND
            pfnacimi IS NULL
         THEN
            BEGIN
               SELECT sperson,
                      csexper,
                      fnacimi
                 INTO persona.sperson,
                      persona.csexper,
                      persona.fnacimi
                 FROM per_personas
                WHERE nnumide = pnnumnif
                     /*AND swpubli = NVL(pswpubli, swpubli)   --27000:Problemas con personas privadas y publicas*/
                  AND swpubli =
                      DECODE(vpervisionpublica, 0, NVL(pswpubli, swpubli),
                             swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                  AND ROWNUM = 1; /*dades incorrectes a desa;*/
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  persona.sperson := numpers;
            END;
         ELSE
            persona.sperson := numpers;
         END IF;

         numerr          := pac_persona.f_get_dadespersona(persona.sperson,
                                                           NULL, NULL, NULL,
                                                           NULL, ptablas,
                                                           persona.snip,
                                                           persona.nordide,
                                                           persona.cestper,
                                                           persona.fjubila,
                                                           persona.cmutualista,
                                                           persona.fdefunc,
                                                           persona.tdigitoide);
         vpasexec        := 19;
         persona.cagente := pcagente;
         vpasexec        := 20;
         persona.swpubli := NVL(pswpubli, 0); /*svj bug 0010339 --               persona.cestper := 0;*/
         vpasexec        := 21;

         IF persona.tdigitoide IS NOT NULL
         THEN
            persona.swrut := 1;
         ELSE
            persona.swrut := 0;
         END IF;

         vpasexec := 22;
         /************************************ ----  EST   --------  ***********************************************/
      ELSE
         /* tab?as EST*/
         vpasexec := 23;

         IF vpersonunica = 2
         THEN
            /* POR NNUMIDE*/
            vpasexec := 5;

            BEGIN
               SELECT sperson,
                      coditablas
                 INTO numpers,
                      vcoditablas
                 FROM (SELECT p.sperson,
                              'POL' coditablas
                         FROM per_personas p
                        WHERE p.nnumide = pnnumnif
                          AND swpubli = NVL(pswpubli, 0)
                          AND (pcagente IS NULL OR
                              pcagente IN
                              (SELECT cagente
                                  FROM per_detper d
                                 WHERE d.sperson = p.sperson))
                          AND sperson NOT IN
                              (SELECT NVL(spereal, -1)
                                 FROM estper_personas /* BUG15810:DRA:08/09/2010*/
                                WHERE sseguro = psseguro)
                       UNION
                       SELECT p.sperson,
                              'EST' coditablas
                         FROM estper_personas p
                        WHERE p.nnumide = pnnumnif
                             /*AND swpubli = NVL(pswpubli, 0)*/
                          AND swpubli =
                              DECODE(vpervisionpublica, 0, NVL(pswpubli, 0),
                                     swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                          AND (pcagente IS NULL OR
                              pcagente IN
                              (SELECT cagente
                                  FROM per_detper d
                                 WHERE d.sperson = p.sperson)))
                WHERE ROWNUM = 1; /*Se pone debido que los datos en desa son incorrectos*/
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT sperson,
                            coditablas
                       INTO numpers,
                            vcoditablas
                       FROM (SELECT p.sperson,
                                    'POL' coditablas
                               FROM per_personas p
                              WHERE p.nnumide = pnnumnif
                                   /*AND swpubli = NVL(pswpubli, 0)*/
                                AND swpubli =
                                    DECODE(vpervisionpublica, 0,
                                           NVL(pswpubli, 0), swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                                AND sperson NOT IN
                                    (SELECT NVL(spereal, -1)
                                       FROM estper_personas /* BUG15810:DRA:08/09/2010*/
                                      WHERE sseguro = psseguro)
                             UNION
                             SELECT p.sperson,
                                    'EST' coditablas
                               FROM estper_personas p
                              WHERE p.nnumide = pnnumnif
                                AND swpubli = NVL(pswpubli, 0))
                      WHERE ROWNUM = 1; /*Se pone debido que los datos en desa son incorrectos*/

                     vpersonanova := 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        numpers      := NULL; /*Nueva persona*/
                        vpersonanova := 1;
                        vcoditablas  := 'EST';
                  END;
            END;
         ELSIF vpersonunica = 3
         THEN
            /* POR NNUMIDE, FNACIMI, CSEXPER*/
            vpasexec := 6;

            BEGIN
               SELECT sperson,
                      coditablas
                 INTO numpers,
                      vcoditablas
                 FROM (SELECT sperson,
                              'POL' coditablas
                         FROM per_personas p
                        WHERE ((nnumide = pnnumnif AND p.ctipper = 2) /* Juridica*/
                              OR (p.nnumide = pnnumnif AND
                              p.csexper = pcsexper AND
                              p.fnacimi = pfnacimi AND p.ctipper != 2) /*fisica*/
                              )
                             /*AND p.swpubli = NVL(pswpubli, 0)   -- t.9318*/
                          AND p.swpubli =
                              DECODE(vpervisionpublica, 0, NVL(pswpubli, 0),
                                     p.swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                          AND (pcagente IS NULL OR
                              pcagente IN
                              (SELECT cagente
                                  FROM per_detper d
                                 WHERE d.sperson = p.sperson))
                          AND sperson NOT IN
                              (SELECT NVL(spereal, -1)
                                 FROM estper_personas /* BUG15810:DRA:08/09/2010*/
                                WHERE sseguro = psseguro)
                       UNION
                       SELECT sperson,
                              'EST' coditablas
                         FROM estper_personas p
                        WHERE ((nnumide = pnnumnif AND p.ctipper = 2) /* Juridica*/
                              OR (p.nnumide = pnnumnif AND
                              p.csexper = pcsexper AND
                              p.fnacimi = pfnacimi AND p.ctipper != 2) /*fisica*/
                              )
                             /*AND p.swpubli = NVL(pswpubli, 0)   -- t.9318*/
                          AND p.swpubli =
                              DECODE(vpervisionpublica, 0, NVL(pswpubli, 0),
                                     swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                          AND (pcagente IS NULL OR
                              pcagente IN
                              (SELECT cagente
                                  FROM per_detper d
                                 WHERE d.sperson = p.sperson)))
                WHERE ROWNUM = 1; /*Se pone debido que los datos en desa son incorrectos ;*/
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT sperson,
                            coditablas
                       INTO numpers,
                            vcoditablas
                       FROM (SELECT sperson,
                                    'POL' coditablas
                               FROM per_personas p
                              WHERE ((nnumide = pnnumnif AND p.ctipper = 2) /* Juridica*/
                                    OR (p.nnumide = pnnumnif AND
                                    p.csexper = pcsexper AND
                                    p.fnacimi = pfnacimi AND
                                    p.ctipper != 2) /*fisica*/
                                    )
                                   /*AND p.swpubli = NVL(pswpubli, 0)   -- t.9318*/
                                AND p.swpubli =
                                    DECODE(vpervisionpublica, 0,
                                           NVL(pswpubli, 0), p.swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                                AND sperson NOT IN
                                    (SELECT NVL(spereal, -1)
                                       FROM estper_personas /* BUG15810:DRA:08/09/2010*/
                                      WHERE sseguro = psseguro)
                             UNION
                             SELECT sperson,
                                    'EST' coditablas
                               FROM estper_personas p
                              WHERE ((nnumide = pnnumnif AND p.ctipper = 2) /* Juridica*/
                                    OR (p.nnumide = pnnumnif AND
                                    p.csexper = pcsexper AND
                                    p.fnacimi = pfnacimi AND
                                    p.ctipper != 2) /*fisica*/
                                    )
                                   /*AND p.swpubli = NVL(pswpubli, 0)   -- t.9318*/
                                AND p.swpubli =
                                    DECODE(vpervisionpublica, 0,
                                           NVL(pswpubli, 0), p.swpubli) /*Bug 29166/160004 - 29/11/2013 - AMC*/
                             )
                      WHERE ROWNUM = 1; /*Se pone debido que los datos en desa son incorrectos ;*/

                     vpersonanova := 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        numpers      := NULL; /*Nueva persona*/
                        vpersonanova := 1;
                        vcoditablas  := 'EST';
                  END;
            END;
         ELSIF vpersonunica IN (1, 4, 5)
         THEN
            /* POR SNIP*/
            vpasexec     := 7;
            numpers      := NULL; /*Nueva persona*/
            vpersonanova := 1;
            vcoditablas  := 'EST';
         END IF;

         vpasexec := 5;

         /* Si es de las tablas reales lo traspasamos a las EST.*/
         IF vcoditablas = 'POL'
         THEN
            vpasexec  := 6;
            vcagente2 := pac_md_common.f_get_cxtagenteprod;
            vnumerr   := f_traspasapersona(numpers, NULL, /*sip*/ vcagente2,
                                           vcoditablas, vsperson2, psseguro,
                                           'EST',
                                            -- Bug 11948
                                           vmensapop, mensajes);
            /* BUG15810:DRA:13/09/2010:Inici*/
            pac_persona.p_busca_agentes(numpers,
                                        pac_md_common.f_get_cxtagenteprod,
                                        vcagente2, vcagente_per, vcoditablas);
            numpers := vsperson2; /*Realizamos el traspaso para coger el nuevo sperson.*/

            /* BUG15810:DRA:13/09/2010:Fi*/
            IF vnumerr != 0
            THEN
               /* pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);*/
               RAISE e_object_error;
            END IF;
            /* BUG 26968 - FAL - 01/08/2013 -  en la 2Ã‚Âª vez de ingreso de misma personam recupera de las EST y no recupera todos los campos por culpa del agente. Se realiza misma busqueda de agentes que para vcoditablas = 'POL'.*/
         ELSIF vcoditablas = 'EST'
         THEN
            vcagente2 := pac_md_common.f_get_cxtagenteprod;
            pac_persona.p_busca_agentes(numpers,
                                        pac_md_common.f_get_cxtagenteprod,
                                        vcagente2, vcagente_per, vcoditablas);
            /* BUG 26968 - FAL - 01/08/2013*/
         END IF;

         vpasexec := 7;

         /* BUG15810:DRA:08/09/2010:Inici*/
         /* La pesrona ya existe*/
         IF NVL(vpersonanova, 0) = 0
         THEN
            persona := f_get_persona_est(numpers, vcagente_per, mensajes,
                                         ptablas);
         ELSE
            /*persona nueva, inicializamos*/
            /* BUG15810:DRA:08/09/2010:Fi*/
            vpasexec := 8;

            IF pctipper IS NOT NULL
            THEN
               persona.ctipper := pctipper;
            END IF;

            IF pctipide IS NOT NULL
            THEN
               persona.ttipide := ff_desvalorfijo(672,
                                                  pac_md_common.f_get_cxtidioma(),
                                                  pctipide);
               persona.ctipide := pctipide;
            END IF;

            IF pctipide = 0 AND
               pnnumnif IS NULL
            THEN
               vnumerr := f_snnumnif('Z', persona.nnumide);
            ELSE
               persona.nnumide := pnnumnif;
            END IF;

            IF pcsexper IS NOT NULL
            THEN
               persona.csexper := pcsexper;
            END IF;

            IF pfnacimi IS NOT NULL
            THEN
               persona.fnacimi := pfnacimi;
            END IF;

            IF vpersonunica = 2 AND
               pcsexper IS NULL AND
               pfnacimi IS NULL
            THEN
               BEGIN
                  SELECT sperson,
                         csexper,
                         fnacimi
                    INTO persona.sperson,
                         persona.csexper,
                         persona.fnacimi
                    FROM per_personas
                   WHERE nnumide = pnnumnif
                     AND ROWNUM = 1; /*dades incorrectes a desa;*/
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     persona.sperson := numpers;
               END;
            ELSE
               persona.sperson := numpers;
            END IF;

            numerr          := pac_persona.f_get_dadespersona(persona.sperson,
                                                              pctipide,
                                                              pnnumnif,
                                                              pcsexper,
                                                              pfnacimi,
                                                              ptablas,
                                                              persona.snip,
                                                              persona.nordide,
                                                              persona.cestper,
                                                              persona.fjubila,
                                                              persona.cmutualista,
                                                              persona.fdefunc,
                                                              persona.tdigitoide);
            persona.cagente := pcagente;
            persona.swpubli := NVL(pswpubli, 0); /*svj bug 0010339 --*/
            persona.cestper := 0;

            IF persona.tdigitoide IS NOT NULL
            THEN
               persona.swrut := 1;
            ELSE
               persona.swrut := 0;
            END IF;

            pnacionalidades := t_iax_nacionalidades();
            pnacionalidades.extend;
            pnacionalidades(pnacionalidades.last) := ob_iax_nacionalidades();
            persona.nacionalidades := pnacionalidades;
            pdirecciones := t_iax_direcciones();
            pdirecciones.extend;
            objdirecciones := ob_iax_direcciones();
            objdirecciones.cdomici := NULL;
            pdirecciones(pdirecciones.last) := objdirecciones;
            persona.direcciones := pdirecciones;
            pcontactos := t_iax_contactos();
            /*pcontactos.EXTEND;
            pcontactos(pcontactos.LAST) := ob_iax_contactos();*/
            persona.contactos := pcontactos;
            pccc              := t_iax_ccc();
            pccc.extend;
            objccc := ob_iax_ccc();
            objccc.cnordban := NULL;
            pccc(pccc.last) := objccc;
            persona.ccc := pccc;
            pidentificadores := t_iax_identificadores();
            pidentificadores.extend;
            pidentificadores(pidentificadores.last) := ob_iax_identificadores();
            persona.identificadores := pidentificadores;
            irpfs := t_iax_irpf();
            irpfs.extend;
            irpfs(irpfs.last) := ob_iax_irpf();
            persona.irpf := irpfs;
         END IF;

         /*XPL 11079 07102009*/
         IF vsnipaut = 1 AND
            persona.snip IS NULL
         THEN
            SELECT snip.nextval INTO persona.snip FROM dual;
         END IF;

         /**/
         IF vtpais IS NOT NULL AND
            persona.tpais IS NULL
         THEN
            persona.tpais := vtpais;
            persona.cpais := vcpais;
         END IF;

         vpasexec := 34;
      END IF;

      vpasexec := 99;
      RETURN persona;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec,
                                           vparam || ' - vpersonunica: ' ||
                                            vpersonunica);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec,
                                           vparam || ' - vpersonunica: ' ||
                                            vpersonunica);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec,
                                           vparam || ' - vpersonunica: ' ||
                                            vpersonunica, psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN persona;
   END f_get_personaunica;

   FUNCTION traspaso_ccc(psseguro          IN NUMBER,
                         psperson          IN per_personas.sperson%TYPE,
                         pficticia_sperson IN estper_personas.sperson%TYPE,
                         mensajes          OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pficticia_sperson:' || pficticia_sperson;
      vobject  VARCHAR2(200) := 'traspaso_ccc';
      errores  t_ob_error;
      vnumerr  NUMBER(8) := 0;
   BEGIN
      IF pficticia_sperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pac_persona.traspaso_ccc(psperson, pficticia_sperson,
                               f_cagente(psseguro));
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END traspaso_ccc;

   /* DRA 13-10-2008: bug mantis 7784*/
   FUNCTION f_buscaagente(psperson IN per_personas.sperson%TYPE,
                          pcagente IN agentes.cagente%TYPE,
                          ptablas  IN VARCHAR2,
                          mensajes OUT t_iax_mensajes)
      RETURN agentes.cagente%TYPE IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' - ptablas: ' || ptablas;
      vobject  VARCHAR2(200) := 'f_buscaagente';
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_persona.f_buscaagente(psperson, pcagente, ptablas);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_buscaagente;

   FUNCTION f_persona_origen_int(psperson IN estper_personas.sperson%TYPE,
                                 mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'f_persona_origen_int';
      vnumerr  NUMBER(10) := 0;
      vpasexec VARCHAR2(5) := 1;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_persona.f_persona_origen_int(psperson);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_persona_origen_int;

   FUNCTION f_get_persona_trecibido(psperson IN estper_personas.sperson%TYPE,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vparam   VARCHAR2(200) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_persona_trecibido';
      vnumerr  NUMBER(10) := 0;
      vpasexec VARCHAR2(5) := 1;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_persona.f_get_persona_trecibido(psperson);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_persona_trecibido;

   FUNCTION f_direccion_origen_int(psperson IN estper_direcciones.sperson%TYPE,
                                   pcdomici IN estper_direcciones.cdomici%TYPE,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam   VARCHAR2(200) := 'parametros - psperson: ' || psperson || '-' ||
                                pcdomici;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_direccion_origen_int';
      vnumerr  NUMBER(10) := 0;
      vpasexec VARCHAR2(5) := 1;
   BEGIN
      IF psperson IS NULL OR
         pcdomici IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_persona.f_direccion_origen_int(psperson, pcdomici);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_direccion_origen_int;

   FUNCTION f_get_direccion_trecibido(psperson IN estper_direcciones.sperson%TYPE,
                                      pcdomici IN estper_direcciones.cdomici%TYPE,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vparam   VARCHAR2(200) := 'parametros - psperson: ' || psperson || '-' ||
                                pcdomici;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_direccion_trecibido';
      vnumerr  NUMBER(10) := 0;
      vpasexec VARCHAR2(5) := 1;
   BEGIN
      IF psperson IS NULL OR
         pcdomici IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_persona.f_get_direccion_trecibido(psperson, pcdomici);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_direccion_trecibido;

   /* bug 7873*/
   FUNCTION f_get_cagentepol(psperson IN per_personas.sperson%TYPE,
                             ptablas  IN VARCHAR2,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vcagente NUMBER;
      vparam   VARCHAR2(200) := 'parametros - psperson: ' || psperson ||
                                '- ptablas ' || ptablas;
      vobject  VARCHAR2(200) := 'f_get_cagentePol';
      vnumerr  NUMBER(10) := 0;
      vpasexec VARCHAR2(5) := 1;
   BEGIN
      BEGIN
         IF ptablas = 'EST'
         THEN
            SELECT cagente
              INTO vcagente
              FROM estseguros
             WHERE sseguro IN (SELECT sseguro
                                 FROM estper_personas
                                WHERE sperson = psperson);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            /*when no_data_found then*/
            RETURN pac_iax_produccion.vagente;
      END;

      RETURN NVL(vcagente, pac_iax_produccion.vagente);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cagentepol;

   /*************************************************************************
      F_BUSQUEDA_MASDATOS
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_busqueda_masdatos(mensajes   IN OUT t_iax_mensajes,
                                pomasdatos OUT NUMBER) RETURN SYS_REFCURSOR IS
      vobject  VARCHAR2(200) := 'f_busqueda_masdatos';
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000);
      terror   VARCHAR2(200) := 'Error recuperar personas HOST';
      vsinterf NUMBER;
      verror   NUMBER;
      cur      SYS_REFCURSOR;
   BEGIN
      verror   := pac_md_con.f_busqueda_masdatos(vsinterf, mensajes,
                                                 pomasdatos);
      vpasexec := 2;

      IF verror <> 0
      THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      vpasexec := 3;
      cur      := pac_md_listvalores.f_opencursor('select null codi, ''INT'' codiTablas ,tdocidentif nnumnif ,tnombre||'' ''||tapelli1||'' ''||tapelli2 nombre, sip snip ' ||
                                                  ' from INT_DATOS_PERSONA where sinterf = ' ||
                                                  vsinterf, mensajes);
      vpasexec := 4;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_busqueda_masdatos;

   /***********************************************************************
      Dado un identificativo de persona llena el objeto personas
      param in sperson       : codigo de persona
      param in cagente       : codigo del agente
      param in out obpersona : objeto persona
      param in out mensajes  : mensajes de error
      retorno : 0 - ok
                1 - error
   ***********************************************************************/
   FUNCTION f_get_persona_agente(psperson  IN NUMBER,
                                 pcagente  IN NUMBER,
                                 pmode     IN VARCHAR2,
                                 obpersona IN OUT ob_iax_personas,
                                 mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vnumerr  NUMBER(8) := 0;
      vparam   VARCHAR2(100) := 'sperson= ' || psperson || ' pcagente= ' ||
                                pcagente || ' pmode= ' || pmode;
      vobject  VARCHAR2(200) := 'F_GET_PERSONA_AGENTE';

      /* Bug 25456/133727 - 16/01/2013 - AMC*/
      CURSOR c_person(psperson2 IN NUMBER) IS
         SELECT pd.sperson,
                pd.cagente,
                pd.cidioma,
                pd.tapelli1,
                pd.tapelli2,
                pd.tnombre,
                pd.tsiglas,
                pd.cprofes,
                pd.tbuscar,
                pd.cestciv,
                pd.cpais,
                pd.cusuari,
                pd.fmovimi,
                p.spereal,
                pac_persona.f_format_nif(p.nnumide, p.ctipide, p.sperson,
                                         'EST') nnumide,
                p.nordide,
                p.ctipide,
                p.csexper,
                p.fnacimi,
                p.cestper,
                p.fjubila,
                p.ctipper,
                p.cmutualista,
                p.fdefunc,
                p.snip,
                p.swpubli,
                pd.tnombre1,
                pd.tnombre2,
                pd.cocupacion
           FROM estper_detper   pd,
                estper_personas p
          WHERE pd.sperson = psperson2
            AND pd.sperson = p.sperson
            AND (pd.cagente = ff_agente_cpervisio(pcagente) OR
                (p.swpubli = 1 AND
                pd.cagente =
                pac_persona.f_buscaagente_publica(p.sperson, 'EST')));

      CURSOR c_person2(psperson IN NUMBER) IS
         SELECT pd.sperson,
                pd.cagente,
                pd.cidioma,
                pd.tapelli1,
                pd.tapelli2,
                pd.tnombre,
                pd.tsiglas,
                pd.cprofes,
                pd.tbuscar,
                pd.cestciv,
                pd.cpais,
                pd.cusuari,
                pd.fmovimi,
                pac_persona.f_format_nif(p.nnumide, p.ctipide, p.sperson,
                                         'SEG') nnumide,
                p.nordide,
                p.ctipide,
                p.csexper,
                p.fnacimi,
                p.cestper,
                p.fjubila,
                p.ctipper,
                p.cmutualista,
                p.fdefunc,
                p.snip,
                p.swpubli,
                pd.tnombre1,
                pd.tnombre2,
                pd.cocupacion
           FROM per_detper   pd,
                per_personas p
          WHERE pd.sperson = psperson
            AND pd.sperson = p.sperson
            AND pd.cagente =
                pac_persona.f_get_agente_detallepersona(p.sperson, pcagente,
                                                        pac_md_common.f_get_cxtempresa);
      /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /* Bug 12761 - 19/01/2010 - AMC*/
      IF obpersona IS NULL
      THEN
         obpersona := NEW ob_iax_personas();
      END IF;

      /* Bug 12761 - 19/01/2010 - AMC*/
      IF pmode = 'EST'
      THEN
         vpasexec := 2;

         FOR per IN c_person(psperson)
         LOOP
            /*dbms_output.put_line(per.sperson||'<>>'||per.tnombre);*/
            obpersona.sperson     := psperson;
            obpersona.spereal     := per.spereal;
            obpersona.tapelli1    := per.tapelli1;
            obpersona.tapelli2    := per.tapelli2;
            obpersona.tnombre     := per.tnombre;
            obpersona.nnumide     := per.nnumide;
            obpersona.csexper     := per.csexper;
            vpasexec              := 21;
            obpersona.tsexper     := SUBSTR(pac_md_listvalores.f_getdescripvalores(11,
                                                                                   per.csexper,
                                                                                   mensajes),
                                            1, 100);
            obpersona.direcciones := t_iax_direcciones();
            obpersona.fnacimi     := per.fnacimi;
            obpersona.ctipper     := per.ctipper;
            obpersona.ctipide     := per.ctipide;
            vpasexec              := 22;
            obpersona.ttipide     := SUBSTR(pac_md_listvalores.f_getdescripvalores(672,
                                                                                   per.ctipide,
                                                                                   mensajes),
                                            1, 100);
            obpersona.cestper     := per.cestper;
            vpasexec              := 23;
            obpersona.testper     := SUBSTR(pac_md_listvalores.f_getdescripvalores(13,
                                                                                   per.cestper,
                                                                                   mensajes),
                                            1, 100);
            obpersona.cidioma     := per.cidioma;
            obpersona.snip        := per.snip;
            /*JRH 04/2008 Tarea ESTPERSONAS*/
            obpersona.spereal   := per.spereal;
            obpersona.contactos := t_iax_contactos();
            /*bug 19896 --ETM -- 20/12/2011--A??adir el campo tmovil,temail al declarante--INI*/
            vnumerr := f_get_contactos(psperson, pcagente,
                                       obpersona.contactos, mensajes, pmode);
            /*FIN bug 19896 --ETM -- 20/12/2011--A??adir el campo tmovil,temail al declarante*/
            obpersona.ccc            := t_iax_ccc();
            obpersona.nacionalidades := t_iax_nacionalidades();
            obpersona.cprofes        := per.cprofes;
            obpersona.cpais          := per.cpais;
            vpasexec                 := 24;
            obpersona.tprofes        := ff_descprofes(per.cprofes,
                                                      pac_md_common.f_get_cxtidioma,
                                                      pac_md_common.f_get_cxtempresa);
            vpasexec                 := 25;
            obpersona.tpais          := ff_despais(per.cpais,
                                                   pac_md_common.f_get_cxtidioma);
            obpersona.tsiglas        := per.tsiglas;
            /*SBG 30/05/2008 - LOG CONSULTES*/
            vpasexec := 26;
            vnumerr  := pac_md_log.f_log_consultas('mode = ''' || pmode ||
                                                   ''', sperson = ' ||
                                                   psperson ||
                                                   ', spereal = ' ||
                                                   obpersona.spereal,
                                                   'PAC_MD_PERSONA.f_get_persona_agente',
                                                   2, 1, mensajes);
            /*JRH 04/2008*/
            obpersona.tnombre1 := per.tnombre1;
            obpersona.tnombre2 := per.tnombre2;
            /* NMM 02.2013.24497#c134060*/
            obpersona.cestciv := per.cestciv;
            /*     XPL bug 21531#08032012*/
            vnumerr := f_get_perautcarnets(psperson, pcagente,
                                           obpersona.perautcarnets, mensajes,
                                           pmode);

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            /* Bug 25456/133727 - 16/01/2013 - AMC*/
            obpersona.cocupacion := per.cocupacion;
            obpersona.tocupacion := ff_descprofes(per.cocupacion,
                                                  pac_md_common.f_get_cxtidioma,
                                                  pac_md_common.f_get_cxtempresa);
            /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
         END LOOP;
      ELSIF pmode = 'POL'
      THEN
         vpasexec := 3;

         FOR per IN c_person2(psperson)
         LOOP
            /*dbms_output.put_line(per.sperson||'<>>'||per.tnombre);*/
            obpersona.sperson := psperson;
            /* obpersona.spereal  := PER.spereal;*/
            obpersona.tapelli1    := per.tapelli1;
            obpersona.tapelli2    := per.tapelli2;
            obpersona.tnombre     := per.tnombre;
            obpersona.nnumide     := per.nnumide;
            obpersona.csexper     := per.csexper;
            vpasexec              := 31;
            obpersona.tsexper     := SUBSTR(pac_md_listvalores.f_getdescripvalores(11,
                                                                                   per.csexper,
                                                                                   mensajes),
                                            1, 100);
            obpersona.direcciones := t_iax_direcciones();
            obpersona.fnacimi     := per.fnacimi;
            obpersona.ctipper     := per.ctipper;
            obpersona.ctipide     := per.ctipide;
            vpasexec              := 32;
            obpersona.ttipide     := SUBSTR(pac_md_listvalores.f_getdescripvalores(672,
                                                                                   per.ctipide,
                                                                                   mensajes),
                                            1, 100);
            obpersona.cestper     := per.cestper;
            vpasexec              := 33;
            obpersona.testper     := SUBSTR(pac_md_listvalores.f_getdescripvalores(13,
                                                                                   per.cestper,
                                                                                   mensajes),
                                            1, 100);
            obpersona.cidioma     := per.cidioma;
            obpersona.snip        := per.snip;
            /*JRH 04/2008 Tarea ESTPERSONAS*/
            /*obpersona.spereal  := PER.spereal;*/
            obpersona.contactos := t_iax_contactos();
            /*bug 19896 --ETM -- 20/12/2011--A??adir el campo tmovil,temail al declarante--INI*/
            vnumerr := f_get_contactos(psperson, pcagente,
                                       obpersona.contactos, mensajes, pmode);
            /*FIN bug 19896 --ETM -- 20/12/2011--A??adir el campo tmovil,temail al declarante*/
            obpersona.ccc            := t_iax_ccc();
            obpersona.nacionalidades := t_iax_nacionalidades();
            obpersona.cprofes        := per.cprofes;
            obpersona.cpais          := per.cpais;
            vpasexec                 := 34;
            obpersona.tprofes        := ff_descprofes(per.cprofes,
                                                      pac_md_common.f_get_cxtidioma,
                                                      pac_md_common.f_get_cxtempresa);
            vpasexec                 := 35;
            obpersona.tpais          := ff_despais(per.cpais,
                                                   pac_md_common.f_get_cxtidioma);
            obpersona.tsiglas        := per.tsiglas;
            /*JRH 04/2008*/
            /*SBG 30/05/2008 - LOG CONSULTES*/
            vpasexec           := 36;
            vnumerr            := pac_md_log.f_log_consultas('mode = ''' ||
                                                             pmode ||
                                                             ''', sperson = ' ||
                                                             psperson ||
                                                             ', spereal = NULL',
                                                             'PAC_MD_PERSONA.F_GET_PERSONA_AGENTE',
                                                             2, 1, mensajes);
            obpersona.tnombre1 := per.tnombre1;
            obpersona.tnombre2 := per.tnombre2;
            /* NMM 02.2013.24497#c134060*/
            obpersona.cestciv := per.cestciv;
            /*     XPL bug 21531#08032012*/
            vnumerr := f_get_perautcarnets(psperson, pcagente,
                                           obpersona.perautcarnets, mensajes,
                                           pmode);

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            /* Bug 25456/133727 - 16/01/2013 - AMC*/
            obpersona.cocupacion := per.cocupacion;
            obpersona.tocupacion := ff_descprofes(per.cocupacion,
                                                  pac_md_common.f_get_cxtidioma,
                                                  pac_md_common.f_get_cxtempresa);
            /* Fi Bug 25456/133727 - 16/01/2013 - AMC*/
         END LOOP;
      ELSE
         RAISE e_param_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_persona_agente;

   FUNCTION f_validapersona(psperson IN estper_personas.sperson%TYPE,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vparam         VARCHAR2(200) := 'parametros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'f_validapersona';
      vnumerr        NUMBER(10) := 0;
      vpasexec       VARCHAR2(5) := 1;
      persona        ob_iax_personas;
      vcnacionalidad per_nacionalidades.cpais%TYPE;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      persona := f_get_persona(psperson, NULL, mensajes, 'EST');

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      /*    FOR i IN persona.nacionalidades.first .. persona.nacionalidades.last LOOP*/
      FOR i IN NVL(persona.nacionalidades.first, 0) .. NVL(persona.nacionalidades.last,
                                                           -1)
      LOOP
         vcnacionalidad := persona.nacionalidades(i).cpais;
         EXIT;
      END LOOP;

      vnumerr := f_validapersona(psperson, pac_md_common.f_get_cxtidioma(),
                                 persona.ctipper,

                                 /* tipo de persona (fisica o juridica)*/
                                 persona.ctipide,
                                 /* tipo de identificacion de persona*/
                                 persona.nnumide,
                                 /* Numero identificativo de la persona.*/
                                 persona.csexper, /* sexo de la pesona.*/
                                 persona.fnacimi,
                                 /* Fecha de nacimiento de la persona*/
                                 persona.snip, /* snip*/ persona.cestper,
                                 persona.fjubila, persona.cmutualista,
                                 persona.fdefunc, persona.nordide,
                                 persona.cidioma, /*  Codigo idioma*/
                                 persona.tapelli1, /*      Primer apellido*/
                                 persona.tapelli2, /* Segundo apellido*/
                                 persona.tnombre, /*    Nombre de la persona*/
                                 persona.tsiglas,
                                  /*      Siglas persona juridica*/
                                 persona.cprofes, /*Codigo profesion*/ NULL,
                                 /* no sale en el objeto persona.cestciv,  --Codigo estado civil. VALOR FIJO = 12*/
                                 persona.cpais, /* Codigo pais de residencia*/
                                 vcnacionalidad,
                                 /* esta en el objeto nacionalidad --persona.cnacionalidad,*/
                                 'EST', persona.tnombre1,
                                  --    Nombre de la persona
                                 persona.tnombre2,
                                  /*    Nombre de la persona*/
                                 persona.cocupacion,
                                  /* Bug 25456/133727 - 16/01/2013 - AMC*/
                                 mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_validapersona;

   FUNCTION f_valida_direccion(psperson IN estper_personas.sperson%TYPE,
                               pcdomici IN estper_direcciones.cdomici%TYPE,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vparam   VARCHAR2(200) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'f_valida_direccion';
      vnumerr  NUMBER(10) := 0;
      vpasexec VARCHAR2(5) := 1;
      persona  ob_iax_personas;
   BEGIN
      IF psperson IS NULL OR
         pcdomici IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      persona := f_get_persona(psperson, NULL, mensajes, 'EST');

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      /* f_validadirecciones*/
      FOR i IN persona.direcciones.first .. persona.direcciones.last
      LOOP
         IF persona.direcciones(i).cdomici = pcdomici
         THEN
            vnumerr := f_valida_direccion(psperson,
                                          pac_md_common.f_get_cxtagenteprod,
                                          persona.direcciones(i).ctipdir,
                                          persona.direcciones(i).csiglas,
                                          persona.direcciones(i).tnomvia,
                                          persona.direcciones(i).nnumvia,
                                          persona.direcciones(i).tcomple,
                                          persona.direcciones(i).cpostal,
                                          persona.direcciones(i).cpoblac,

                                          /*Codigo poblacion*/
                                          persona.direcciones(i).cprovin,
                                          persona.direcciones(i).cpais,
                                          mensajes);
            EXIT;
         END IF;
      END LOOP;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_direccion;

   /* JLB - F - ANDORRA*/
   /*************************************************************************
     funcion que recuperara todas la personas
     con sus detalles segun el nivel de vision
     del usuario que este consultando.
   *************************************************************************/
   FUNCTION f_get_det_persona(numide     IN VARCHAR2,
                              nombre     IN VARCHAR2,
                              nsip       IN VARCHAR2 DEFAULT NULL,
                              mensajes   IN OUT t_iax_mensajes,
                              pnom       IN VARCHAR2 DEFAULT NULL,
                              pcognom1   IN VARCHAR2 DEFAULT NULL,
                              pcognom2   IN VARCHAR2 DEFAULT NULL,
                              pctipide   IN NUMBER DEFAULT NULL,
                              pfnacimi   IN DATE, /* BUG11171:DRA:24/11/2009*/
                              ptdomici   IN VARCHAR2, /* BUG11171:DRA:24/11/2009*/
                              pcpostal   IN VARCHAR2, /* BUG11171:DRA:24/11/2009*/
                              pswpubli   IN NUMBER,
                              pestseguro IN NUMBER) RETURN SYS_REFCURSOR IS
      condicio1    VARCHAR2(1000);
      condicio4    VARCHAR2(1000);
      condicio5    VARCHAR2(1000);
      condicio6    VARCHAR2(1000);
      v_twhere     VARCHAR2(10000) := '0=0';
      v_twhere_est VARCHAR2(10000) := '0=0';
      tlog         VARCHAR2(4000);
      cur          SYS_REFCURSOR;
      vpasexec     NUMBER(8) := 1;
      vparam       VARCHAR2(2000) := 'numide= ' || numide || ', nombre= ' ||
                                     nombre || ', nsip= ' || nsip ||
                                     ',pnom= ' || pnom || ', pcognom1= ' ||
                                     pcognom1 || ', pcognom2= ' || pcognom2 ||
                                     ', pctipide= ' || pctipide ||
                                     ', pfnacimi= ' || pfnacimi ||
                                     ', ptdomici= ' || ptdomici ||
                                     ', pcpostal= ' || pcpostal;
      vobject      VARCHAR2(200) := 'F_GET_DET_PERSONA';
      vnumerr      NUMBER := 0;
      terror       VARCHAR2(200) := 'Error recuperar personas';
      /*//ACC recuperar desde literales*/
      auxnom            VARCHAR2(2000);
      nerr              NUMBER;
      v_select          VARCHAR2(4000);
      vcampos           VARCHAR2(200);
      vtab1             VARCHAR2(50);
      vwheredir         VARCHAR2(200);
      vpervisionpublica NUMBER; /* Bug 29166/161240 - 12/12/2013 - AMC*/
   BEGIN
      /* Bug 29166/161240 - 12/12/2013 - AMC*/
      vpervisionpublica := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                             'PER_VISIONPUBLICA'),
                               0);

      IF nombre IS NOT NULL
      THEN
         nerr         := f_strstd(nombre, auxnom);
         condicio1    := '''%' || auxnom || '%''';
         tlog         := ' UPPER(p.tbuscar) LIKE UPPER (' || condicio1 || ')';
         v_twhere     := v_twhere || ' and ' || tlog;
         tlog         := ' UPPER(pdet.tbuscar) LIKE UPPER (' || condicio1 || ')';
         v_twhere_est := v_twhere_est || ' and ' || tlog;
      END IF;

      IF numide IS NOT NULL
      THEN
         /*tlog := '  p.nnumide = ''' || numide || '''';*/
         /*Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'), 0) = 1
         THEN
            tlog         := '  UPPER(p.nnumide) LIKE UPPER(''' || '%' ||
                            ff_strstd(numide) || '%' || ''')'; -- BUG 38344/217178 - 10/11/2015 - ACL
            v_twhere     := v_twhere || ' and ' || tlog;
            v_twhere_est := v_twhere_est || ' and ' || tlog;
         ELSE
            tlog         := '  p.nnumide LIKE ''' || '%' ||
                            ff_strstd(numide) || '%' || ''' '; -- 36190-206031    -- BUG 38344/217178 - 10/11/2015 - ACL
            v_twhere     := v_twhere || ' and ' || tlog;
            v_twhere_est := v_twhere_est || ' and ' || tlog;
         END IF;
      END IF;

      IF nsip IS NOT NULL
      THEN
         tlog := ' UPPER(p.snip) = UPPER (''' || nsip || ''') ';
         /* 12009.NMM.01/2010.*/
         v_twhere     := v_twhere || ' and ' || tlog;
         v_twhere_est := v_twhere_est || ' and ' || tlog;
      END IF;

      IF pnom IS NOT NULL
      THEN
         condicio4 := '''%' || ff_strstd(pnom) || '%''';
         /*tlog := ' FF_STRSTD(p.tnombre) LIKE ' || condicio4;*/
         tlog     := ' UPPER(p.tnombre) LIKE ' || condicio4; -- BUG 38344/217178 - 06/11/2015 - CJM
         v_twhere := v_twhere || ' and ' || tlog;
         /*tlog := ' FF_STRSTD(pdet.tnombre) LIKE ' || condicio4;*/
         tlog         := ' UPPER(pdet.tnombre) LIKE ' || condicio4; -- BUG 38344/217178 - 06/11/2015 - CJM
         v_twhere_est := v_twhere_est || ' and ' || tlog;
      END IF;

      IF pcognom1 IS NOT NULL
      THEN
         condicio5 := '''%' || ff_strstd(pcognom1) || '%''';
         /*tlog := ' FF_STRSTD(p.tapelli1) LIKE ' || condicio5;*/
         tlog     := ' UPPER(p.tapelli1) LIKE ' || condicio5; -- BUG 38344/217178 - 06/11/2015 - CJM
         v_twhere := v_twhere || ' and ' || tlog;
         /*tlog := ' FF_STRSTD(pdet.tapelli1) LIKE ' || condicio5;*/
         tlog         := ' UPPER(pdet.tapelli1) LIKE ' || condicio5; -- BUG 38344/217178 - 06/11/2015 - CJM
         v_twhere_est := v_twhere_est || ' and ' || tlog;
      END IF;

      IF pcognom2 IS NOT NULL
      THEN
         condicio6 := '''%' || ff_strstd(pcognom2) || '%''';
         /*tlog := ' FF_STRSTD(p.tapelli2) LIKE ' || condicio6;*/
         tlog     := ' UPPER(p.tapelli2) LIKE ' || condicio6; -- BUG 38344/217178 - 06/11/2015 - CJM
         v_twhere := v_twhere || ' and ' || tlog;
         /*tlog := ' FF_STRSTD(pdet.tapelli2) LIKE ' || condicio6;*/
         tlog         := ' UPPER(pdet.tapelli2) LIKE ' || condicio6; -- BUG 38344/217178 - 06/11/2015 - CJM
         v_twhere_est := v_twhere_est || ' and ' || tlog;
      END IF;

      IF pctipide IS NOT NULL
      THEN
         tlog         := ' p.ctipide = ' || TO_CHAR(pctipide);
         v_twhere     := v_twhere || ' and ' || tlog;
         v_twhere_est := v_twhere_est || ' and ' || tlog;
      END IF;

      /* BUG11171:DRA:24/11/2009:inici*/
      IF pfnacimi IS NOT NULL
      THEN
         tlog         := ' trunc(p.fnacimi) = ''' || pfnacimi || '''';
         v_twhere     := v_twhere || ' and ' || tlog;
         v_twhere_est := v_twhere_est || ' and ' || tlog;
      END IF;

      IF ptdomici IS NOT NULL
      THEN
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*tlog := ' FF_STRSTD(pd.tdomici) LIKE UPPER (''' || '%' || ff_strstd(ptdomici) || '%'*/
         /*        || ''') ';*/
         tlog         := ' UPPER(pd.tdomici) LIKE UPPER (''' || '%' ||
                         ff_strstd(ptdomici) || '%' || ''') ';
         v_twhere     := v_twhere || ' and ' || tlog;
         v_twhere_est := v_twhere_est || ' and ' || tlog;
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*vwheredir := ' and ' || ' FF_STRSTD(pd2.tdomici) LIKE UPPER (''' || '%'*/
         /*             || ff_strstd(ptdomici) || '%' || ''') ';*/
         vwheredir := ' and ' || ' UPPER(pd2.tdomici) LIKE UPPER (''' || '%' ||
                      ff_strstd(ptdomici) || '%' || ''') ';
      END IF;

      IF pcpostal IS NOT NULL
      THEN
         tlog         := ' pd.cpostal LIKE ''' || pcpostal || '''';
         v_twhere     := v_twhere || ' and ' || tlog;
         v_twhere_est := v_twhere_est || ' and ' || tlog;
         vwheredir    := vwheredir || ' and ' || ' pd2.cpostal LIKE ''' ||
                         pcpostal || '''';
      END IF;

      /* Bug 29166/161240 - 12/12/2013 - AMC*/
      IF NVL(vpervisionpublica, 0) = 0
      THEN
         IF pswpubli IS NOT NULL
         THEN
            tlog     := ' p.swpubli = ' || TO_CHAR(pswpubli);
            v_twhere := v_twhere || ' and ' || tlog;
         END IF;
      END IF;

      /* BUG.: 15253 - 02/07/2010 - ICV*/
      /*IF ptdomici IS NOT NULL
         OR pcpostal IS NOT NULL THEN
         vcampos := ', d.tdomici, d.cpostal ';
         vtab1 := ', per_direcciones d ';
         vwheredir := ' AND D.sperson = P.sperson AND d.cagente = p.cagente ';
      ELSE
         vcampos := ', NULL tdomici, NULL cpostal ';
         vtab1 := NULL;
         vwheredir := NULL;
      END IF;*/
      /* BUG11171:DRA:24/11/2009:fi*/
      v_select := 'SELECT    codi, cagente, tagente, nnumide, nombre, fnacimi, tdomici, cpostal, modo,NIT_REPRESENTANTE,REPRESENTANTE,TELEFONO,TELEFONO_MOVIL FROM (
	         SELECT    codi, cagente, tagente, nnumide, nombre, fnacimi, tdomici, cpostal, ''POL'' modo,NIT_REPRESENTANTE,REPRESENTANTE,TELEFONO,TELEFONO_MOVIL FROM (' ||
                  ' SELECT p.sperson codi, p.cagente, p.tagente, p.nnumide, p.tnombre || '' '' || p.tapelli nombre' ||
                  ', TO_CHAR (p.fnacimi, ''DD-MM-YYYY'') fnacimi, pd.tdomici, p.swpubli, pd.cpostal,pac_isqlfor_conf.f_representante_legal(p.sperson,1)AS NIT_REPRESENTANTE,pac_isqlfor_conf.f_representante_legal(p.sperson,2)AS REPRESENTANTE,pac_isqlfor.f_telefono(p.sperson) as TELEFONO,pac_isqlfor.f_telefono_movil(p.sperson) as TELEFONO_MOVIL ' ||
                  vcampos ||
                  ' FROM personas_detalles p, per_direcciones pd ' ||
                  ' WHERE ' || v_twhere || ' AND pd.sperson(+) = p.sperson' ||
                  ' AND pd.cagente(+) = p.cagente' ||
                  '  AND NVL(pd.cdomici, 0) = (SELECT NVL(MAX(cdomici),0)
	                                             FROM per_direcciones pd2
	                                            WHERE pd2.sperson = pd.sperson
	                                              AND pd2.cagente = pd.cagente ' ||
                  vwheredir || '
	                                             ) AND not exists (select 1 from estper_personas e where e.sseguro = ' ||
                  NVL(pestseguro, 1) || ' and e.spereal = p.sperson)' ||
                  ' ORDER BY nombre)
	         union all
	         SELECT    codi, cagente, tagente, nnumide, nombre, fnacimi, tdomici, cpostal, ''EST'' modo,NIT_REPRESENTANTE,REPRESENTANTE,TELEFONO,TELEFONO_MOVIL FROM (' ||
                  ' SELECT p.sperson codi, pdet.cagente, ff_desagente(pdet.cagente) tagente, p.nnumide,
	                 pdet.tnombre || '' '' || pdet.tapelli1 || '' '' || pdet.tapelli2 nombre, TO_CHAR(p.fnacimi,
	                                                               ''DD-MM-YYYY'') fnacimi,
	                 pd.tdomici, p.swpubli, pd.cpostal,pac_isqlfor_conf.f_representante_legal(p.sperson,1)AS NIT_REPRESENTANTE,pac_isqlfor_conf.f_representante_legal(p.sperson,2)AS REPRESENTANTE,pac_isqlfor.f_telefono(p.sperson) as TELEFONO,pac_isqlfor.f_telefono_movil(p.sperson) as TELEFONO_MOVIL ' ||
                  vcampos ||
                  ' FROM estper_detper pdet, estper_personas p, estper_direcciones pd ' ||
                  ' WHERE ' || v_twhere_est ||
                  ' AND pd.sperson(+) = pdet.sperson
	             AND pd.cagente(+) = pdet.cagente
	             AND pdet.sperson = p.sperson
	             AND exists (select 1 from estper_personas e where e.sseguro = ' ||
                  NVL(pestseguro, 1) ||
                  ' and e.sperson = p.sperson) AND NVL(pd.cdomici, 0) = (SELECT NVL(MAX(cdomici),0)
	                                             FROM estper_direcciones pd2
	                                            WHERE pd2.sperson = pd.sperson
	                                              AND pd2.cagente = pd.cagente ' ||
                  vwheredir || '
	                                             )' ||
                  ' ORDER BY nombre))' ||
                  ' WHERE ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      /* Fin BUG.: 15253*/
      vnumerr := pac_md_log.f_log_consultas(v_select,
                                            'PAC_MD_PERSONA.f_get_det_persona',
                                            1, 1, mensajes);

      OPEN cur FOR v_select;

      /*BUG10300-XVM-17/09/2009 fi*/
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_det_persona;

   /*************************************************************************
     funcion que a partir de un sperson te devuelve los detalles
     de la persona, segun el nivel de vision del usuario
     que esta consultando.
   *************************************************************************/
   FUNCTION f_get_agentes_vision(psperson IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'sperson : ' || psperson;
      vobject  VARCHAR2(200) := 'F_GET_AGENTES_VISION';
      vnumerr  NUMBER := 0;
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT SPERSON CODI, CAGENTE, TAGENTE,  TNOMBRE NOMBRE
	                                                FROM PERSONAS_DETALLES
	                                                where sperson = ' ||
                                             psperson || ' order by nombre',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agentes_vision;

   /*************************************************************************
          Nueva funcion que servira para modificar los datos basicos de una persona
   *************************************************************************/
   FUNCTION f_set_basicos_persona(psperson   IN NUMBER,
                                  pctipper   IN NUMBER,
                                  pctipide   IN NUMBER,
                                  pnnumide   IN VARCHAR2,
                                  pcsexper   IN NUMBER,
                                  pfnacimi   IN DATE,
                                  pswpubli   IN NUMBER,
                                  ptablas    IN VARCHAR2,
                                  pswrut     IN NUMBER,
                                  pcpreaviso IN NUMBER,
                                  mensajes   IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      condicio VARCHAR2(1000);
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject  VARCHAR2(200) := 'F_SET_BASICOS_PERSONA';
      vnum_err NUMBER;
      verrores t_ob_error;
   BEGIN
      vnum_err := pac_persona.f_set_basicos_persona(psperson, pctipper,
                                                    pctipide, pnnumide,
                                                    pcsexper, pfnacimi,
                                                    pswpubli, 'POL', pswrut,
                                                    pcpreaviso, verrores);
      /* BUG 21270/107049 - 13/02/2012 - JMP - Se a?ade tratamiento de errores*/
      mensajes := f_traspasar_errores_mensajes(verrores);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      /* FIN BUG 21270/107049 - 13/02/2012 - JMP - Se a?ade tratamiento de errores*/
      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_basicos_persona;

   /*************************************************************
   Nueva funcion que llena la coleccion del t_iax_irpfmayores.
   **************************************************************/
   FUNCTION f_get_irpfmayores(psperson    IN NUMBER,
                              pcagente    IN NUMBER,
                              pnano       IN NUMBER,
                              ptablas     IN VARCHAR2,
                              irpfmayores OUT t_iax_irpfmayores,
                              mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER;
      squery   VARCHAR2(2000);
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pnano = ' || pnano || ' pcagente ' ||
                                 pcagente || ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_irpfmayores';
      vsquery  VARCHAR2(2000);

      CURSOR c_irpfmayor IS
         SELECT cagente,
                sperson,
                norden
           FROM estper_irpfmayores
          WHERE sperson = psperson
            AND nano = pnano
            AND ptablas = 'EST'
         UNION ALL
         SELECT cagente,
                sperson,
                norden
           FROM per_irpfmayores
          WHERE sperson = psperson
            AND nano = pnano
            AND cagente = pcagente
            AND ptablas != 'EST';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      irpfmayores := t_iax_irpfmayores();

      FOR reg IN c_irpfmayor
      LOOP
         irpfmayores.extend;
         irpfmayores(irpfmayores.last) := ob_iax_irpfmayores();
         vnumerr := f_get_irpfmayor(psperson, pcagente, pnano, reg.norden,
                                    ptablas, irpfmayores(irpfmayores.last),
                                    mensajes);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_irpfmayores;

   /*************************************************************
    funcion que llena el objeto ob_iax_irpfmayores.
   **************************************************************/
   FUNCTION f_get_irpfmayor(psperson    IN NUMBER,
                            pcagente    IN NUMBER,
                            pnano       IN NUMBER,
                            pnorden     IN NUMBER,
                            ptablas     IN VARCHAR2,
                            irpfmayores OUT ob_iax_irpfmayores,
                            mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pnano = ' || pnano || ' ptablas = ' ||
                                 ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_irpfmayor';
      vsquery  VARCHAR2(2000);
   BEGIN
      IF psperson IS NULL OR
         pnano IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      irpfmayores := ob_iax_irpfmayores();
      vnumerr     := pac_persona.f_get_irpfmayor(psperson, pcagente, pnano,
                                                 pnorden,
                                                 pac_md_common.f_get_cxtidioma,
                                                 ptablas, vsquery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         /* error interno.*/
         RAISE e_object_error;
      END IF;

      cur      := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      LOOP
         FETCH cur
            INTO irpfmayores.cagente,
                 irpfmayores.sperson,
                 irpfmayores.fnacimi,
                 irpfmayores.cgrado,
                 irpfmayores.crenta,
                 irpfmayores.nviven,
                 irpfmayores.norden,
                 irpfmayores.nano,
                 irpfmayores.tgrado,
                 irpfmayores.cusuari,
                 irpfmayores.fmovimi;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      CLOSE cur;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_irpfmayor;

   /*************************************************************
    funcion que llena la coleccion del t_iax_irpfdescen.
   **************************************************************/
   FUNCTION f_get_irpfdescens(psperson    IN NUMBER,
                              pcagente    IN NUMBER,
                              pnano       IN NUMBER,
                              ptablas     IN VARCHAR2,
                              irpfdescens OUT t_iax_irpfdescen,
                              mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER;
      squery   VARCHAR2(2000);
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pnano = ' || pnano || ' ptablas = ' ||
                                 ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_irpfdescens';

      CURSOR c_irpfdescens IS
         SELECT cagente,
                sperson,
                nano,
                norden
           FROM estper_irpfdescen
          WHERE sperson = psperson
            AND nano = pnano
            AND ptablas = 'EST'
         UNION ALL
         SELECT cagente,
                sperson,
                nano,
                norden
           FROM per_irpfdescen
          WHERE sperson = psperson
            AND nano = pnano
            AND cagente = pcagente
            AND ptablas != 'EST';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      irpfdescens := t_iax_irpfdescen();

      FOR reg IN c_irpfdescens
      LOOP
         irpfdescens.extend;
         irpfdescens(irpfdescens.last) := ob_iax_irpfdescen();
         vnumerr := f_get_irpfdescen(psperson, pcagente, pnano, reg.norden,
                                     ptablas, irpfdescens(irpfdescens.last),
                                     mensajes);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_irpfdescens;

   /*************************************************************
    funcion que llena el objeto ob_iax_irpfdescen.
   **************************************************************/
   FUNCTION f_get_irpfdescen(psperson   IN NUMBER,
                             pcagente   IN NUMBER,
                             pnano      IN NUMBER,
                             pnorden    IN NUMBER,
                             ptablas    IN VARCHAR2,
                             irpfdescen OUT ob_iax_irpfdescen,
                             mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pnano = ' || pnano || ' ptablas = ' ||
                                 ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_irpfdescen';
      vsquery  VARCHAR2(2000);
   BEGIN
      IF psperson IS NULL OR
         pnano IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      irpfdescen := ob_iax_irpfdescen();
      vnumerr    := pac_persona.f_get_irpfdescen(psperson, pcagente, pnano,
                                                 pnorden,
                                                 pac_md_common.f_get_cxtidioma,
                                                 ptablas, vsquery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         /* error interno.*/
         RAISE e_object_error;
      END IF;

      cur      := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      LOOP
         FETCH cur
            INTO irpfdescen.cagente,
                 irpfdescen.sperson,
                 irpfdescen.fnacimi,
                 irpfdescen.cgrado,
                 irpfdescen.center,
                 irpfdescen.norden,
                 irpfdescen.nano,
                 irpfdescen.tgrado,
                 irpfdescen.cusuari,
                 irpfdescen.fmovimi,
                 irpfdescen.fadopcion;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      CLOSE cur;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_irpfdescen;

   /*************************************************************
   funcion que llena la coleccion del t_iax_irpf.
   **************************************************************/
   FUNCTION f_get_irpfs(psperson IN NUMBER,
                        pcagente IN NUMBER,
                        ptablas  IN VARCHAR2,
                        pirpfs   OUT t_iax_irpf,
                        mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER;
      squery   VARCHAR2(2000);
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_irpf';

      CURSOR c_irpf IS(
         SELECT nano
           FROM estper_irpf
          WHERE sperson = psperson
            AND ptablas = 'EST'
         UNION ALL
         SELECT nano
           FROM per_irpf
          WHERE sperson = psperson
            AND cagente = pcagente
            AND ptablas != 'EST')
          ORDER BY nano DESC;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pirpfs := t_iax_irpf();

      FOR reg IN c_irpf
      LOOP
         pirpfs.extend;
         pirpfs(pirpfs.last) := ob_iax_irpf();
         vnumerr := f_get_irpf(psperson, pcagente, reg.nano, ptablas,
                               pirpfs(pirpfs.last), mensajes);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_irpfs;

   /*************************************************************
    funcion que llena el objeto ob_iax_irpfdescen.
   **************************************************************/
   FUNCTION f_get_irpf(psperson IN NUMBER,
                       pcagente IN NUMBER,
                       pnano    IN NUMBER,
                       ptablas  IN VARCHAR2,
                       pirpf    OUT ob_iax_irpf,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cur      SYS_REFCURSOR;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pnano = ' || pnano || 'pcagente ' ||
                                 pcagente || ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_irpf';
      vsquery  VARCHAR2(2000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pirpf := ob_iax_irpf();

      IF pnano IS NOT NULL
      THEN
         vnumerr := pac_persona.f_get_irpf(psperson, pcagente, pnano,
                                           pac_md_common.f_get_cxtidioma,
                                           ptablas, vsquery);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            /* error interno.*/
            RAISE e_object_error;
         END IF;

         cur      := pac_md_listvalores.f_opencursor(vsquery, mensajes);
         vpasexec := 4;

         LOOP
            /* bug 12716 - 26/03/2010 - AMC*/
            FETCH cur
               INTO pirpf.sperson,
                    pirpf.cagente,
                    pirpf.csitfam,
                    pirpf.cnifcon,
                    pirpf.cgrado,
                    pirpf.cayuda,
                    pirpf.ipension,
                    pirpf.ianuhijos,
                    pirpf.cusuari,
                    pirpf.prolon,
                    pirpf.rmovgeo,
                    pirpf.nano,
                    pirpf.tgrado,
                    pirpf.tsitfam,
                    pirpf.fmovgeo,
                    pirpf.cpago;

            /* fi bug 12716 - 26/03/2010 - AMC*/
            EXIT WHEN cur%NOTFOUND;
            vnumerr := f_get_irpfdescens(pirpf.sperson, pirpf.cagente,
                                         pirpf.nano, ptablas,
                                         pirpf.descendientes, mensajes);

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            vnumerr := f_get_irpfmayores(pirpf.sperson, pirpf.cagente,
                                         pirpf.nano, ptablas, pirpf.mayores,
                                         mensajes);

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END LOOP;

         CLOSE cur;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_irpf;

   /*************************************************************
    funcion que eliminar los registros de las tablas relacionadas a IRPF
   **************************************************************/
   FUNCTION f_del_irpf(psperson IN NUMBER,
                       pcagente IN NUMBER,
                       pnano    IN NUMBER,
                       ptablas  IN VARCHAR2,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_del_irpf';
   BEGIN
      vnumerr := pac_persona.f_del_irpf(psperson, pcagente, pnano, ptablas);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_irpf;

   /*************************************************************
   funcion que grabar los registros de las tablas relacionadas a IRPF
   **************************************************************/
   FUNCTION f_set_irpf(pobirpf  IN ob_iax_irpf,
                       ptablas  IN VARCHAR2,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vnumerr  NUMBER;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' ||
                                 pobirpf.sperson || ' ptablas = ' ||
                                 ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_irpf';
   BEGIN
      /* bug 12716 - 26/03/2010 - AMC*/
      vnumerr := pac_persona.f_set_irpf(pobirpf.sperson, pobirpf.cagente,
                                        pobirpf.nano, pobirpf.csitfam,
                                        pobirpf.cnifcon, pobirpf.cgrado,
                                        pobirpf.cayuda, pobirpf.ipension,
                                        pobirpf.ianuhijos, pobirpf.prolon,
                                        pobirpf.rmovgeo, ptablas,
                                        pobirpf.fmovgeo, pobirpf.cpago);
      /* fi bug 12716 - 26/03/2010 - AMC*/
      vpasexec := 2;

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001280);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;

      IF pobirpf.mayores IS NOT NULL AND
         pobirpf.mayores.count > 0
      THEN
         FOR i IN pobirpf.mayores.first .. pobirpf.mayores.last
         LOOP
            vpasexec := 33;
            vnumerr  := pac_persona.f_set_irpfmayores(pobirpf.mayores(i)
                                                      .sperson,
                                                      pobirpf.mayores(i)
                                                       .cagente,
                                                      pobirpf.mayores(i).nano,
                                                      pobirpf.mayores(i)
                                                       .norden,
                                                      pobirpf.mayores(i)
                                                       .fnacimi,
                                                      pobirpf.mayores(i)
                                                       .cgrado,
                                                      pobirpf.mayores(i)
                                                       .crenta,
                                                      pobirpf.mayores(i)
                                                       .nviven, ptablas);
            vpasexec := 34;

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001278);
               RAISE e_object_error;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 4;

      IF pobirpf.descendientes IS NOT NULL AND
         pobirpf.descendientes.count > 0
      THEN
         vpasexec := 40;

         FOR i IN pobirpf.descendientes.first .. pobirpf.descendientes.last
         LOOP
            vpasexec := 44;
            /* bug 12716 - 26/03/2010 - AMC*/
            vnumerr := pac_persona.f_set_irpfdescen(pobirpf.descendientes(i)
                                                    .sperson,
                                                    pobirpf.descendientes(i)
                                                     .cagente,
                                                    pobirpf.descendientes(i).nano,
                                                    pobirpf.descendientes(i)
                                                     .norden,
                                                    pobirpf.descendientes(i)
                                                     .fnacimi,
                                                    pobirpf.descendientes(i)
                                                     .fadopcion,
                                                    pobirpf.descendientes(i)
                                                     .center,
                                                    pobirpf.descendientes(i)
                                                     .cgrado, ptablas);
            /* fi bug 12716 - 26/03/2010 - AMC*/
            vpasexec := 45;

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001279);
               RAISE e_object_error;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_irpf;

   /*************************************************************************
    funcion que devuelve numero de a?os para declarar el irpf de una persona,
    si la persona existe se le devolvera el maximo mas uno sino existiera se
    le devolveria el actual a?o
   *************************************************************************/
   FUNCTION f_get_anysirpf(psperson IN NUMBER,
                           pcagente IN NUMBER,
                           pnanos   OUT SYS_REFCURSOR,
                           mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_anysIrpf';
      vsquery  VARCHAR2(200);
      vnum_err NUMBER;
      cur      SYS_REFCURSOR;
   BEGIN
      vnum_err := pac_persona.f_get_anysirpf(psperson, pcagente, vsquery);

      IF vnum_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         /* error interno.*/
         RAISE e_object_error;
      END IF;

      pnanos := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_anysirpf;

   /*************************************************************************
    funcion que torna l'agent de visio passant-li un agent
   *************************************************************************/
   FUNCTION f_agente_cpervisio(pcagente      IN NUMBER,
                               pcagentevisio OUT NUMBER,
                               mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec     NUMBER(8) := 1;
      vparam       VARCHAR2(2000) := 'pcagente= ' || pcagente;
      vobject      VARCHAR2(200) := 'PAC_MD_PERSONA.ff_agente_cpervisio';
      vsquery      VARCHAR2(200);
      vnum_err     NUMBER;
      cagentevisio NUMBER;
      cur          SYS_REFCURSOR;
   BEGIN
      IF pcagente IS NOT NULL
      THEN
         /*svj bug 0010339 --*/
         pcagentevisio := ff_agente_cpervisio(pcagente);

         IF pcagentevisio IS NULL
         THEN
            RAISE e_object_error;
         END IF;
      END IF; /*svj bug 0010339 --*/

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_agente_cpervisio;

   /*************************************************************************
     funcion que recuperara todas la personas dependiendo del modo.
     publico o no. servira para todas las pantallas donde quieran utilizar el
     buscador de personas.
   *************************************************************************/
   FUNCTION f_get_personas_generica(pnumide       IN VARCHAR2,
                                    pnombre       IN VARCHAR2,
                                    pnsip         IN VARCHAR2 DEFAULT NULL,
                                    mensajes      IN OUT t_iax_mensajes,
                                    pnom          IN VARCHAR2 DEFAULT NULL,
                                    pcognom1      IN VARCHAR2 DEFAULT NULL,
                                    pcognom2      IN VARCHAR2 DEFAULT NULL,
                                    pctipide      IN NUMBER DEFAULT NULL,
                                    pcagente      IN NUMBER DEFAULT NULL,
                                    pmodo_swpubli IN VARCHAR2)
      RETURN SYS_REFCURSOR IS
      condicio1   VARCHAR2(1000);
      condicio2   VARCHAR2(1000);
      condicio3   VARCHAR2(1000);
      condicio4   VARCHAR2(1000);
      condicio5   VARCHAR2(1000);
      condicio6   VARCHAR2(1000);
      condicio7   VARCHAR2(1000);
      condicion   VARCHAR2(8000);
      tlog        VARCHAR2(4000);
      cur         SYS_REFCURSOR;
      vpasexec    NUMBER(8) := 1;
      vparam      VARCHAR2(2000) := 'numide= ' || pnumide || ', nombre= ' ||
                                    pnombre || ', nsip= ' || pnsip ||
                                    ',pnom= ' || pnom || ', pcognom1= ' ||
                                    pcognom1 || ', pcognom2= ' || pcognom2 ||
                                    ', pctipide= ' || pctipide;
      vobjectname VARCHAR2(3000) := 'PAC_MD_PERSONA.f_get_persona_generica';
      vnumerr     NUMBER(10) := 0;
      terror      VARCHAR2(3000) := 'Error recuperar personas';
      /*//ACC recuperar desde literales*/
      auxnom       VARCHAR2(3000);
      nerr         NUMBER;
      cur_generica SYS_REFCURSOR;
      vsquery      CLOB;
      /*//ACC recuperar desde literales*/
      /*//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);*/
   BEGIN
      vnumerr := pac_persona.f_get_persona_generica(pnumide, pnombre, pnsip,
                                                    pnom, pcognom1, pcognom2,
                                                    pctipide, pcagente,
                                                    pmodo_swpubli, vsquery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      /*BUG10300-XVM-17092009*/
      vnumerr      := pac_md_log.f_log_consultas(vsquery,
                                                 'PAC_MD_PERSONA.F_GET_PERSONAS_GENERICA',
                                                 1, 1, mensajes);
      cur_generica := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur_generica;
      RETURN NULL;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005,
                                           vpasexec, vparam);

         IF cur_generica%ISOPEN
         THEN
            CLOSE cur_generica;
         END IF;

         RETURN cur_generica;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006,
                                           vpasexec, vparam, vnumerr);

         IF cur_generica%ISOPEN
         THEN
            CLOSE cur_generica;
         END IF;

         RETURN cur_generica;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur_generica%ISOPEN
         THEN
            CLOSE cur_generica;
         END IF;

         RETURN cur_generica;
   END f_get_personas_generica;

   /* ini t.8063*/
   /*************************************************************************
     funcion que recuperara todas la personas publicas
     con sus detalles segun el nivel de vision
     del usuario que este consultando.
   *************************************************************************/
   FUNCTION f_get_personas_publicas(numide   IN VARCHAR2,
                                    nombre   IN VARCHAR2,
                                    nsip     IN VARCHAR2 DEFAULT NULL,
                                    mensajes IN OUT t_iax_mensajes,
                                    pnom     IN VARCHAR2 DEFAULT NULL,
                                    pcognom1 IN VARCHAR2 DEFAULT NULL,
                                    pcognom2 IN VARCHAR2 DEFAULT NULL,
                                    pctipide IN NUMBER DEFAULT NULL)
      RETURN SYS_REFCURSOR IS
      condicio1 VARCHAR2(1000);
      condicio2 VARCHAR2(1000);
      condicio3 VARCHAR2(1000);
      condicio4 VARCHAR2(1000);
      condicio5 VARCHAR2(1000);
      condicio6 VARCHAR2(1000);
      condicio7 VARCHAR2(1000);
      tlog      VARCHAR2(4000);
      cur       SYS_REFCURSOR;
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(2000) := 'numide= ' || numide || ', nombre= ' ||
                                  nombre || ', nsip= ' || nsip || ',pnom= ' || pnom ||
                                  ', pcognom1= ' || pcognom1 ||
                                  ', pcognom2= ' || pcognom2 ||
                                  ', pctipide= ' || pctipide;
      vobject   VARCHAR2(200) := 'F_GET_PERSONAS_PUBLICAS';
      vnumerr   NUMBER := 0;
      terror    VARCHAR2(200) := 'Error recuperar personas';
      /*//ACC recuperar desde literales*/
      auxnom   VARCHAR2(2000);
      nerr     NUMBER;
      v_select VARCHAR2(4000);
   BEGIN
      IF nombre IS NOT NULL
      THEN
         nerr      := f_strstd(nombre, auxnom);
         condicio1 := '%' || auxnom || '%';
         tlog      := tlog || ' UPPER(tbuscar) LIKE UPPER (''' || condicio1 ||
                      ''') AND';
      END IF;

      IF numide IS NOT NULL
      THEN
         /*Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015*/
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'), 0) = 1
         THEN
            condicio2 := numide;
            tlog      := tlog || ' UPPER(nnumide) LIKE UPPER (''' ||
                         ff_strstd(condicio2) || ''') AND';
         ELSE
            condicio2 := numide;
            tlog      := tlog || ' nnumide = LIKE (''' || '%' ||
                         ff_strstd(condicio2) || '%' || ''') AND'; -- 36190-206031
         END IF;
      END IF;

      IF nsip IS NOT NULL
      THEN
         condicio3 := nsip;
         tlog      := tlog || ' UPPER(snip) = UPPER (''' || condicio3 ||
                      ''') AND';
      END IF;

      IF pnom IS NOT NULL
      THEN
         condicio4 := '%' || ff_strstd(pnom) || '%';
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*tlog := tlog || ' FF_STRSTD(tnombre) LIKE ''' || condicio4 || ''' AND';*/
         tlog := tlog || ' UPPER(tnombre) LIKE ''' || condicio4 || ''' AND';
      END IF;

      IF pcognom1 IS NOT NULL
      THEN
         condicio5 := '%' || ff_strstd(pcognom1) || '%';
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*tlog := tlog || ' FF_STRSTD(tapelli1) LIKE ''' || condicio5 || ''' AND';*/
         tlog := tlog || ' UPPER(tapelli1) LIKE ''' || condicio5 ||
                 ''' AND';
      END IF;

      IF pcognom2 IS NOT NULL
      THEN
         condicio6 := '%' || ff_strstd(pcognom2) || '%';
         /* BUG 38344/217178 - 06/11/2015 - CJM*/
         /*tlog := tlog || ' FF_STRSTD(tapelli2) LIKE ''' || condicio6 || ''' AND';*/
         tlog := tlog || ' UPPER(tapelli2) LIKE ''' || condicio6 ||
                 ''' AND';
      END IF;

      IF pctipide IS NOT NULL
      THEN
         condicio7 := TO_CHAR(pctipide);
         tlog      := tlog || ' ctipide = ' || condicio7 || ' AND';
      END IF;

      /*BUG10300-XVM-17092009 inici*/
      v_select := 'SELECT p.sperson codi, cagente, ff_desagente(cagente) tagente, LPAD(nnumide, 10, '' '') nnumide, tnombre || '' '' || tapelli1|| '' '' ||tapelli2 nombre
	         FROM(
	         SELECT p.sperson codi, cagente, ff_desagente(cagente) tagente, LPAD(nnumide, 10, '' '') nnumide, tnombre || '' '' || tapelli1|| '' '' ||tapelli2 nombre
	                   FROM PER_PERSONAS P, PER_DETPER D, personas_publicas pu
	                   WHERE ' || tlog || '
	                     D.SPERSON = P.SPERSON
	                     amd pu.sperson = p.sperson
	                     AND D.FMOVIMI IN ( SELECT MAX (FMOVIMI) FROM PER_DETPER DD WHERE DD.SPERSON = P.SPERSON )
	                     order by tnombre || '' '' || tapelli1|| '' '' ||tapelli2)
	         WHERE ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      /*BUG10300-XVM-17092009 inici*/
      vnumerr := pac_md_log.f_log_consultas(v_select,
                                            'PAC_MD_PERSONA.F_GET_PERSONAS_PUBLICAS',
                                            1, 1, mensajes);

      OPEN cur FOR v_select;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas_publicas;

   /*************************************************************************
      Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
      param out mensajes  : mensajes de error
      return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_persona_publica(psperson IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
      RETURN ob_iax_personas IS
      vnumerr  NUMBER(8) := 0;
      squery   VARCHAR(2000);
      cur      SYS_REFCURSOR;
      persona  ob_iax_personas := ob_iax_personas();
      vidioma  NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_persona_publica';
      objpers  ob_iax_personas;
      numpers  NUMBER;
      numerr   NUMBER;
      vtablas  VARCHAR2(15) := 'POL';
      vcagente per_detper.cagente%TYPE;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vcagente := pac_persona.f_buscaagente_publica(psperson);

      /* bug 29166/161240 - 12/12/2013 - AMC*/
      IF vcagente IS NULL
      THEN
         SELECT MAX(cagente)
           INTO vcagente
           FROM per_detper
          WHERE sperson = psperson;
      END IF;

      /* Fi bug 29166/161240 - 12/12/2013 - AMC*/
      IF vcagente IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000503);
      ELSE
         vpasexec := 2;
         squery   := 'select         p.tapelli1     ,
	                                p.tapelli2     ,
	                                p.tnombre      ,
	                                nordide       ,
	                                p.ctipper      ,
	                                p.ctipide      ,
	                                ff_desvalorfijo (672, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.ctipide) ttipide      ,
	                                p.nnumide      ,
	                                p.fnacimi      ,
	                                p.csexper      ,
	                                ff_desvalorfijo (11, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.csexper )  tsexper    ,
	                                p.cestper      ,
	                                ff_desvalorfijo (13, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.cestper )  testper    ,
	                                p.fjubila      ,
	                                p.fdefunc      ,
	                                f_user     ,
	                                p.fmovimi      ,
	                                p.cmutualista  ,
	                                p.cidioma      ,
	                                p.swpubli      ,
	                                NULL spereal    ,
	                                p.CPROFES,
	                                 (select max(pa.tprofes) from profesiones pa where pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA() and  pa.cprofes=p.cprofes) TPROFES ,
	                                p.CPAIS    ,
	                                (select max(pa.tpais) from despaises pa where pa.cpais=p.cpais and pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA()) TPAIS,
	                                tsiglas,
	                                snip
	                      from personas_detalles p
	                      where sperson = ' || psperson ||
                     ' and cagente = ' || vcagente || '';
         vpasexec := 3;
         vnumerr  := pac_md_log.f_log_consultas(squery,
                                                'PAC_MD_PERSONA.f_get_persona_publica',
                                                1, 1, mensajes);
         cur      := pac_md_listvalores.f_opencursor(squery, mensajes);
         vpasexec := 4;

         LOOP
            FETCH cur
               INTO persona.tapelli1,
                    persona.tapelli2,
                    persona.tnombre,
                    persona.nordide,
                    persona.ctipper,
                    persona.ctipide,
                    persona.ttipide,
                    persona.nnumide,
                    persona.fnacimi,
                    persona.csexper,
                    persona.tsexper,
                    persona.cestper,
                    persona.testper,
                    persona.fjubila,
                    persona.fdefunc,
                    persona.cusuari,
                    persona.fmovimi,
                    persona.cmutualista,
                    persona.cidioma,
                    persona.swpubli,
                    persona.spereal,
                    persona.cprofes,
                    persona.tprofes,
                    persona.cpais,
                    persona.tpais,
                    persona.tsiglas,
                    persona.snip;

            EXIT WHEN cur%NOTFOUND;
            persona.cagente := vcagente;
            persona.sperson := psperson;
            numerr          := f_get_direcciones(psperson, vcagente,
                                                 persona.direcciones,
                                                 mensajes, vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            numerr := f_get_contactos(psperson, vcagente, persona.contactos,
                                      mensajes, vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            numerr := f_get_nacionalidades(psperson, vcagente,
                                           persona.nacionalidades, mensajes,
                                           vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            numerr := f_get_cuentasbancarias(psperson, vcagente, NULL,
                                             persona.ccc, mensajes, vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            numerr := f_get_identificadores(psperson, vcagente,
                                            persona.identificadores, mensajes,
                                            vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            vpasexec := 6;
         END LOOP;

         CLOSE cur;
      END IF;

      RETURN persona;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_persona_publica;

   /* fin t.8063*/
   /*BUG 10074 - JTS - 18/05/2009*/
   /*************************************************************************
   Obte els profesionals associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_profesionales(psperson IN NUMBER,
                                pcur     OUT SYS_REFCURSOR,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_profesionales';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_profesionales(psperson,
                                                 pac_md_common.f_get_cxtidioma,
                                                 squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_profesionales;

   /*************************************************************************
   Obte les companyies associades a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_companias(psperson IN NUMBER,
                            pcur     OUT SYS_REFCURSOR,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_companias';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_companias(psperson,
                                             pac_md_common.f_get_cxtidioma,
                                             squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_companias;

   /*************************************************************************
   Obte els agents associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_agentes(psperson IN NUMBER,
                          pcur     OUT SYS_REFCURSOR,
                          mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_agentes';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_agentes(psperson,
                                           pac_md_common.f_get_cxtidioma,
                                           squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_agentes;

   /*************************************************************************
   Obte els sinistres associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_siniestros(psperson IN NUMBER,
                             pcur     OUT SYS_REFCURSOR,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_siniestros';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*BUG 12815 - 09/02/2010 - JRB - Se aplica la consulta de siniestros*/
      vnumerr := pac_persona.f_get_siniestros(psperson,
                                              pac_md_common.f_get_cxtidioma,
                                              squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      /*BUG 12815 - 09/02/2010 - JRB - Se aplica la consulta de siniestros*/
      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_siniestros;

   /*Fi BUG 10074 - JTS - 18/05/2009*/
   /*BUG 10371 - JTS - 09/06/2009*/
   /*************************************************************************
   Obte la select amb els para metres per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in ptots      : 0.- Nomes retorna els para metres contestats
                         1.- Retorna tots els para metres
   param in ctipper    : Codi tipus persona
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_parpersona(psperson  IN NUMBER,
                             pcagente  IN NUMBER,
                             pcvisible IN NUMBER,
                             ptots     IN NUMBER,
                             ptablas   IN VARCHAR2,
                             pctipper  IN NUMBER,
                             pcur      OUT SYS_REFCURSOR,
                             mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' - pcagente: ' || pcagente || ' - ptots: ' ||
                                ptots || ' - pctipper: ' || pctipper;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_Parpersona';
      squery   VARCHAR2(5000);
   BEGIN
      IF (psperson IS NULL AND ptablas != 'EST') OR
         ptots IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_parpersona(psperson,
                                              NVL(pcagente,
                                                   pac_md_common.f_get_cxtagente),
                                              pac_md_common.f_get_cxtidioma,
                                              pcvisible, ptots, ptablas,
                                              pctipper, squery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_parpersona;

   /*************************************************************************
   Obte la select amb els para metres per persona
        pcparam IN NUMBER,
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_obparpersona(pcparam       IN VARCHAR2,
                               pobparpersona OUT ob_iax_par_personas,
                               mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parmetros - psperson: ' || pcparam;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_obparpersona';
      squery   VARCHAR2(5000);
      pcur     SYS_REFCURSOR;
   BEGIN
      IF pcparam IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_obparpersona(pcparam,
                                                pac_md_common.f_get_cxtidioma,
                                                squery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcur          := pac_md_listvalores.f_opencursor(squery, mensajes);
      pobparpersona := ob_iax_par_personas();

      LOOP
         FETCH pcur
            INTO pobparpersona.cutili,
                 pobparpersona.cparam,
                 pobparpersona.ctipo,
                 pobparpersona.tparam,
                 pobparpersona.cvisible,
                 pobparpersona.ctipper,
                 pobparpersona.tvalpar,
                 pobparpersona.nvalpar,
                 pobparpersona.fvalpar,
                 pobparpersona.resp;

         EXIT WHEN pcur%NOTFOUND;
         pobparpersona := ob_iax_par_personas();
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_obparpersona;

   /*************************************************************************
   Inserta el para metre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numerica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_parpersona(psperson IN NUMBER,
                             pcagente IN NUMBER,
                             pcparam  IN VARCHAR2,
                             pnvalpar IN NUMBER,
                             ptvalpar IN VARCHAR2,
                             pfvalpar IN DATE,
                             ptablas  IN VARCHAR2,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' - pcagente: ' || pcagente ||
                                ' - pcparam: ' || pcparam ||
                                ' - pnvalpar: ' || pnvalpar ||
                                ' - ptvalpar: ' || ptvalpar ||
                                ' - pfvalpar: ' || pfvalpar;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Ins_Parpersona';
      verrores t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         pcparam IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_ins_parpersona(psperson, pcagente, pcparam,
                                               pnvalpar, ptvalpar, pfvalpar,
                                               ptablas, verrores);
      mensajes := f_traspasar_errores_mensajes(verrores);

      /* BUG 21270/107049 - 13/02/2012 - JMP - Se a?ade tratamiento de errores*/
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_ins_parpersona;

   /*************************************************************************
   Esborra el para metre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_parpersona(psperson IN NUMBER,
                             pcagente IN NUMBER,
                             pcparam  IN VARCHAR2,
                             ptablas  IN VARCHAR2,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parmetros - psperson: ' || psperson ||
                                ' - pcagente: ' || pcagente ||
                                ' - pcparam: ' || pcparam;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Del_Parpersona';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_del_parpersona(psperson, pcagente, pcparam,
                                              ptablas);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_parpersona;

   /*Fi BUG 10371 - JTS - 09/06/2009*/
   /**************************************************************************************************************************************************/
   /* I - 10567 - : CRE080 - Nueva interfaz para nueva produccion*/
   FUNCTION f_get_contratos_host(psperson IN NUMBER,
                                 porigen  IN VARCHAR2 DEFAULT 'EST',
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vsinterf NUMBER;
      verror   NUMBER;
      cur      SYS_REFCURSOR;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_CCC_HOST';
      terror   VARCHAR2(200) := 'Error recuperar personas HOST';
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := ' psperson= ' || psperson;
      vsquery  VARCHAR2(2000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      verror   := pac_md_con.f_get_datoscontratos(psperson, porigen,
                                                  vsinterf, mensajes);
      vpasexec := 2;

      IF verror <> 0
      THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      vpasexec := 3;
      vsquery  := 'SELECT ctipcon tipocontrato, CCONTRA contrato, TDESCRIP descripcion,
	                    IINICIAL capitalinicial, IACTUAL capitalactual, ILIMITE limite,
	                    int.CMONEDA moneda,
	                    ICUOTA cuota, CPERIODI peridocidad, FINICIO fechainicio, FFIN fechafin,
	                    CTIPINT tipointeres, ff_desvalorfijo(711, pac_md_common.f_get_cxtidioma(),CMODINT)  modalidadinteres
	                    FROM INT_DATOS_CONTRATO INT
	                    WHERE INT.SINTERF = ' || vsinterf;
      verror   := pac_md_log.f_log_consultas(vsquery,
                                             'PAC_MD_PERSONA.f_get_contratos_host',
                                             1, 1, mensajes);
      cur      := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_contratos_host;

   /* FIN - JLB*/
   /*************************************************************************
      Recupera las ccc en HOST con las cuentas de axis si esa persona ya esta traspasada.
      Solo personas que pertenecen a una poliza, es decir las personas no publicas no las devuelve
      param in nsip      : identificador externo de persona
      param in psperson      : identificador interno de persona
      param in porigen      : De que tablas extraer la informacion
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ccc_host_axis(psperson IN VARCHAR2,
                                psnip    IN VARCHAR2,
                                pcagente IN NUMBER,
                                porigen  IN VARCHAR2 DEFAULT 'EST',
                                mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      vsinterf  NUMBER;
      verror    NUMBER;
      cur       SYS_REFCURSOR;
      vobject   VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_ccc_host_axis';
      terror    VARCHAR2(200) := 'Error recuperar personas HOST';
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(2000) := ' psperson= ' || psperson;
      vsquery   VARCHAR2(2000);
      v_nccc    NUMBER;
      v_sperson per_personas.sperson%TYPE;
   BEGIN
      vpasexec := 10;

      /* Bug 30670 - 21/03/2014 - JTT*/
      /* Tratamiento sedes. Comprobamos si la persona tiene cuentas. Si no tiene, mramos si la persona es una sede de otra.*/
      /* en ese caso, busacmos las cuentas de esta persona.*/
      SELECT COUNT(*)
        INTO v_nccc
        FROM per_ccc per
       WHERE per.sperson = psperson
         AND per.cagente = NVL(pac_persona.f_get_agente_detallepersona(psperson,
                                                                       pac_md_common.f_get_cxtagente,
                                                                       pac_md_common.f_get_cxtempresa),
                               pac_md_common.f_get_cxtagente)
         AND per.fbaja IS NULL
         AND ((NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                 'SINI_CCC_CPAGSIN'), 0) = 1 AND
             per.cpagsin = 1) OR
             (NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                 'SINI_CCC_CPAGSIN'), 0) = 2 AND
             per.cpagsin <> 1));

      IF v_nccc = 0
      THEN
         BEGIN
            SELECT sperson
              INTO v_sperson
              FROM per_personas_rel
             WHERE ctipper_rel = 2
               AND sperson_rel = psperson;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_sperson := psperson;
         END;
      ELSE
         v_sperson := psperson;
      END IF;

      /* Fi Bug 30670 . Se sustituye el uso de la variable sperson por v_sperson en el resto de la funcion*/
      vpasexec := 20;

      IF porigen <> 'NUEVO'
      THEN
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'SINI_DEST_CCC_HOST'), 0) = 1
         THEN
            vpasexec := 1;
            verror   := pac_md_con.f_cuentas_persona(v_sperson, NULL, NULL,
                                                     NULL, porigen, vsinterf,
                                                     mensajes);
            vpasexec := 2;

            IF verror <> 0
            THEN
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                                 vpasexec, vparam, terror,
                                                 SQLCODE, SQLERRM);
            ELSE
               vpasexec := 3;
               /*(JAS) Estic en mode real. No traspaso les comptes a les taules reals ni a les taules EST.*/
               /*Deixo les comptes a les taules INT i treballo diractament des d'alla*/
               vsquery := 'SELECT PER.sperson, INT.CBANCAR,PAC_MD_COMMON.F_FormatCCC(INT.CTIPBAN,INT.CBANCAR) Tcbancar, INT.CTIPBAN
	                    FROM INT_DATOS_CUENTA INT ,PERSONAS PER
	                    WHERE INT.SINTERF = ' ||
                          vsinterf || '
	                    AND PER.SPERSON =' ||
                          v_sperson || ' UNION ';
            END IF;
         END IF;
      END IF;

      vsquery := vsquery ||
                 ' SELECT distinct PER.sperson, per.CBANCAR,PAC_MD_COMMON.F_FormatCCC(per.CTIPBAN,per.CBANCAR) Tcbancar, per.CTIPBAN
	                    FROM PER_CCC PER, per_personas pp
	                    WHERE pp.sperson = per.sperson and  PER.SPERSON =' ||
                 v_sperson ||
                 ' and per.cagente  = nvl(pac_persona.f_get_agente_detallepersona(' ||
                 v_sperson || ',' || pac_md_common.f_get_cxtagente || ',' ||
                 pac_md_common.f_get_cxtempresa || '),' || pcagente ||
                 ') and PER.FBAJA IS NULL';

      /* Bug 19550 - APD - 24/11/2011 - si 'SINI_CCC_CPAGSIN' = 1 se muestran la cuentas*/
      /*marcadas para el pago de siniestros*/
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                           'SINI_CCC_CPAGSIN'), 0) = 1
      THEN
         vsquery := vsquery || ' AND per.cpagsin = 1';
      END IF;

      /* fin Bug 19550 - APD - 24/11/2011*/
      /* ini BUG 21392 - MDS - 16/02/2012*/
      /* si 'SINI_CCC_CPAGSIN' = 2 se muestran las cuentas desmarcadas para el NO pago de siniestros*/
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                           'SINI_CCC_CPAGSIN'), 0) = 2
      THEN
         vsquery := vsquery || ' AND per.cpagsin <> 1';
      END IF;

      /* fin BUG 21392 - MDS - 16/02/2012*/
      verror   := pac_md_log.f_log_consultas(vsquery,
                                             'PAC_MD_PERSONA.f_get_ccc_host_axis',
                                             1, 1, mensajes);
      cur      := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ccc_host_axis;

   FUNCTION f_existe_ccc(psperson IN NUMBER,
                         pcagente IN NUMBER,
                         pcbancar IN VARCHAR2,
                         pctipban IN NUMBER,
                         mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vsinterf  NUMBER;
      verror    NUMBER;
      cur       SYS_REFCURSOR;
      vobject   VARCHAR2(200) := 'PAC_MD_PERSONA.f_existe_ccc';
      terror    VARCHAR2(200) := '';
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(2000) := ' psperson= ' || psperson;
      vsquery   VARCHAR2(2000);
      vcnordban NUMBER;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcnordban := pac_persona.f_existe_ccc(psperson, pcagente, pctipban,
                                            pcbancar);
      RETURN vcnordban;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);
         RETURN NULL;
   END f_existe_ccc;

   /*************************************************************************
      FUNCTION funcion que crea un detalle sino existe la persona con el detalle del agente
      que le estamos pasando
      param in psperson    : Persona de la qual el detalle vamos a duplicar
      param in pcagente    : Agente del qual hemos obtenido el detalle
      param in pcagente_prod : Agente del siniestros que estamos trabajando
      return           : codigo de error

       ---- Bug 16753: CRE - Pantalla destinatarios - 22/11/2010 - XPL
   *************************************************************************/
   FUNCTION f_inserta_detalle_per(psperson      IN NUMBER,
                                  pcagente      IN NUMBER,
                                  pcagente_prod IN NUMBER,
                                  mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'PAC_MD_SINIESTROS.f_inserta_Detalle_per';
      vparam      VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                   ' pcagente: ' || pcagente ||
                                   ' pcagente_prod: ' || pcagente_prod;
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      vexiste     NUMBER;
      v_sperson   NUMBER;
   BEGIN
      IF psperson IS NULL OR
         pcagente_prod IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(1)
        INTO vexiste
        FROM per_detper   pd,
             per_personas pp
       WHERE pd.sperson = psperson
         AND pd.sperson = pp.sperson
         AND (pd.cagente = pcagente_prod AND swpubli = 0);

      IF vexiste = 0
      THEN
         pac_persona.traspaso_tablas_per(psperson, v_sperson, NULL,
                                         pcagente_prod);
         pac_persona.traspaso_tablas_estper(v_sperson, pcagente_prod,
                                            pac_md_common.f_get_cxtempresa);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
                                           vpasexec, vparam, NULL, SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_inserta_detalle_per;

   /*************************************************************************
     FUNCTION funcion que nos comprueba si la persona tiene el mismo nnumide
     param in pnnumide    : Nnumide que vamos a comprobar
     param out pduplicada : Miramos si esta duplicada
     return           : codigo de error

      ---- Bug 17563 : AGA800 - data naixement - 08/03/2011 - XPL
   *************************************************************************/
   FUNCTION f_persona_duplicada(psperson   IN NUMBER,
                                pnnumide   IN VARCHAR2,
                                pcsexper   IN NUMBER,
                                pfnacimi   IN DATE,
                                psnip      IN VARCHAR2,
                                pcagente   IN NUMBER,
                                pswpubli   IN NUMBER,
                                pctipide   IN NUMBER,
                                pduplicada OUT NUMBER,
                                mensajes   OUT t_iax_mensajes,
                                psolicit   IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros -  ppnnumide: ' || pnnumide;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_persona_duplicada';
      vsperson NUMBER(8);
   BEGIN
      vnumerr := pac_persona.f_persona_duplicada(psperson, pnnumide,
                                                 pcsexper, pfnacimi, psnip,
                                                 pcagente, pswpubli, pctipide,
                                                 pduplicada, psolicit);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_persona_duplicada;

   /*************************************************************************
     FUNCTION funcion que recupera la informacion de las personas relacionadas
     param in psperson    : Persona
     param in pcagente    : Agente
     param in psperson_rel    : Persona rel
     pt_perrel out t_iax_personas_rel : Objeto de personas relacionadas
     return           : codigo de error
      ---- Bug 18941 - 26/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_persona_rel(psperson       IN NUMBER,
                              pcagente       IN NUMBER,
                              psperson_rel   IN NUMBER,
                              pobpersona_rel OUT ob_iax_personas_rel,
                              pcagrupa       IN NUMBER, --TCS 468A 17/01/2019 AP
                              mensajes       IN OUT t_iax_mensajes,
                              ptablas        IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente || ' ptablas = ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_persona_rel';
      dummy    NUMBER;

      CURSOR c1 IS
         SELECT sperson,
                cagente,
                sperson_rel,
                ctipper_rel,
                cusuari,
                fmovimi,
                pparticipacion,
                islider /* BUG 0030525 - FAL - 01/04/2014*/,
                cagrupa,
                fagrupa,
                (select dv.tatribu from detvalores dv where dv.cidioma = 8 and dv.cvalor='8002007' and dv.catribu= cagrupa) tatribu
           FROM per_personas_rel pr
          WHERE pr.sperson = psperson
            AND pr.cagente = pcagente
            AND pr.sperson_rel = psperson_rel
            and pr.cagrupa = pcagrupa --TCS 468A 17/01/2019 AP
            AND ptablas <> 'EST'  -- INI TCS 468A 19/02/2019 AP
            UNION
            SELECT sperson_rel,
                cagente,
                sperson,
                ctipper_rel,
                cusuari,
                fmovimi,
                pparticipacion,
                islider /* BUG 0030525 - FAL - 01/04/2014*/,
                cagrupa,
                fagrupa,
                (select dv.tatribu from detvalores dv where dv.cidioma = 8 and dv.cvalor='8002007' and dv.catribu= cagrupa) tatribu
           FROM per_personas_rel pr
          WHERE pr.sperson = psperson_rel
            AND pr.cagente = pcagente
            AND pr.sperson_rel = psperson
            and pr.cagrupa = pcagrupa -- FIN TCS 468A 19/02/2019 AP
            AND ptablas <> 'EST';
      /*De momento no se hace la parte de las EST*/
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pobpersona_rel := ob_iax_personas_rel();

      FOR rc IN c1
      LOOP
         pobpersona_rel.sperson        := rc.sperson;
         pobpersona_rel.cagente        := rc.cagente;
         pobpersona_rel.sperson_rel    := rc.sperson_rel;
         pobpersona_rel.ctipper_rel    := rc.ctipper_rel;
         pobpersona_rel.ttipper_rel    := ff_desvalorfijo(1037,
                                                          pac_md_common.f_get_cxtidioma(),
                                                          rc.ctipper_rel);
         pobpersona_rel.cusuari        := rc.cusuari;
         pobpersona_rel.fmovimi        := rc.fmovimi;
         pobpersona_rel.pparticipacion := rc.pparticipacion;
         pobpersona_rel.islider        := rc.islider; /* BUG 0030525 - FAL - 01/04/2014*/

		 pobpersona_rel.cagrupa := rc.cagrupa;
         pobpersona_rel.fagrupa := rc.fagrupa;
         pobpersona_rel.nagrupa := rc.tatribu;
         BEGIN
            SELECT tvalcon
              INTO pobpersona_rel.telefono
              FROM per_contactos
             WHERE sperson = rc.sperson_rel
               AND cagente = rc.cagente
               AND ctipcon = 1
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM per_contactos
                               WHERE sperson = rc.sperson_rel
                                 AND cagente = rc.cagente
                                 AND ctipcon = 1);
         EXCEPTION
            WHEN OTHERS THEN
               pobpersona_rel.telefono := NULL;
         END;

         BEGIN
            SELECT tvalcon
              INTO pobpersona_rel.mail
              FROM per_contactos
             WHERE sperson = rc.sperson_rel
               AND cagente = rc.cagente
               AND ctipcon = 3
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM per_contactos
                               WHERE sperson = rc.sperson_rel
                                 AND cagente = rc.cagente
                                 AND ctipcon = 3);
         EXCEPTION
            WHEN OTHERS THEN
               pobpersona_rel.mail := NULL;
         END;

         BEGIN
            SELECT tdomici
              INTO pobpersona_rel.direccion
              FROM per_direcciones pd
             WHERE pd.sperson = rc.sperson_rel
               AND pd.cagente = rc.cagente
               AND pd.cdomici =
                   (SELECT MIN(cdomici)
                      FROM per_direcciones pd2
                     WHERE pd2.sperson = pd.sperson
                       AND pd2.cagente = pd.cagente);
         EXCEPTION
            WHEN OTHERS THEN
               pobpersona_rel.direccion := NULL;
         END;

         BEGIN
            SELECT pp.nnumide,
                   f_nombre(pp.sperson, 1, pd.cagente) tnombre
              INTO pobpersona_rel.nnumide,
                   pobpersona_rel.tnombre
              FROM per_detper   pd,
                   per_personas pp
             WHERE pp.sperson = rc.sperson_rel
               AND pd.sperson = pp.sperson
               AND pd.cagente = rc.cagente;
         EXCEPTION
            WHEN OTHERS THEN
               pobpersona_rel.nnumide := NULL;
               pobpersona_rel.tnombre := NULL;
         END;
      END LOOP;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
         /*      WHEN NO_DATA_FOUND THEN*/
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_persona_rel;

   /*************************************************************************
   FUNCTION funcion que recupera la informacion de las personas relacionada
   param in psperson    : Persona
   param in pcagente    : Agente
   pt_perrel out t_iax_personas_rel : Coleccion de personas relacionadas
   return           : codigo de error
    ---- Bug 18941 - 19/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_personas_rel(psperson       IN NUMBER,
                               pcagente       IN NUMBER,
                               ptablas        IN VARCHAR2,
                               ptpersonas_rel OUT t_iax_personas_rel,
                               mensajes       IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pcagente = ' || pcagente ||
                                 ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_GET_PERSONAS_REL';

      CURSOR cur_perrel IS
         SELECT sperson,
                cagente,
                sperson_rel,CAGRUPA --TCS 468A 17/01/2019 AP
           FROM ( /*SELECT sperson, cagente, sperson_rel
                                                                          FROM estper_personas_relacionadas
                                                                         WHERE sperson = psperson
                                                                           AND ptablas = 'EST'
                                                                        UNION ALL*/
                 /*a futuro*/
                 SELECT sperson,
                         cagente,
                         sperson_rel,CAGRUPA --TCS 468A 17/01/2019 AP
                   FROM per_personas_rel
                  WHERE sperson = psperson -- INI TCS 468A 19/02/2019 AP
                  AND cagente = pcagente
                  AND ptablas != 'EST'
                UNION
                  SELECT sperson_rel,
                  cagente,
                  sperson,CAGRUPA --TCS 468A 17/01/2019 AP
                 FROM per_personas_rel
                WHERE sperson_rel = psperson
                  AND cagente = pcagente
                  AND ptablas != 'EST') -- FIN TCS 468A 19/02/2019 AP
          ORDER BY cagrupa;  --  IAXIS-3670  10/02/2020  CJMR
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ptpersonas_rel := t_iax_personas_rel();

      FOR reg IN cur_perrel
      LOOP
         ptpersonas_rel.extend;
         ptpersonas_rel(ptpersonas_rel.last) := ob_iax_personas_rel();
         vnumerr := f_get_persona_rel(reg.sperson, reg.cagente, reg.sperson_rel,
                                      ptpersonas_rel(ptpersonas_rel.last), reg.cagrupa, --TCS 468A 17/01/2019 AP
                                      mensajes, ptablas);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_personas_rel;

   /*************************************************************************
    Nueva funcion que se encarga de borrar una persona relacionada
    return              : 0 Ok. 1 Error
    Bug.: 18941
   *************************************************************************/
   FUNCTION f_del_persona_rel(psperson     IN NUMBER,
                              pcagente     IN NUMBER,
                              psperson_rel IN NUMBER,
                              pcagrupa IN NUMBER, --IAXIS-3670 16/04/2019 AP
                              mensajes     IN OUT t_iax_mensajes,
                              ptablas      IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'pcagente ' || pcagente ||
                                ' psperson_rel : ' || psperson_rel;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_del_persona_rel';
      errores  t_ob_error;
      cont     NUMBER;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         psperson_rel IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(1)
        INTO cont
        FROM per_personas_rel
       WHERE sperson = psperson
         AND cagente = pcagente
         AND sperson_rel = psperson_rel
         AND cagrupa = pcagrupa --IAXIS-3670 16/04/2019 AP
         AND ptablas <> 'EST'; --De momento solo se hace para las reales.

      IF cont = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      pac_persona.p_del_persona_rel(psperson, pcagente, psperson_rel, pcagrupa,
                                    errores, pac_md_common.f_get_cxtidioma(),
                                    ptablas);
      vpasexec := 2;
      mensajes := f_traspasar_errores_mensajes(errores);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_persona_rel;

   /*************************************************************************
    Nueva funcion que se encarga de insertar una persona relacionada
    return              : 0 Ok. 1 Error
    Bug.: 18941
   *************************************************************************/
   FUNCTION f_set_persona_rel(psperson        IN NUMBER,
                              pcagente        IN NUMBER,
                              psperson_rel    IN NUMBER,
                              pctipper_rel    IN NUMBER,
                              ppparticipacion IN NUMBER,
                              pislider        IN NUMBER,
                              mensajes        IN OUT t_iax_mensajes,
                              ptablas         IN VARCHAR2,
							  ptlimit         IN VARCHAR2 DEFAULT '',
                              pcagrupa        IN NUMBER,
                              pfagrupa        IN DATE) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente || 'psperson_rel:' ||
                                psperson_rel || 'pctipper_rel:' ||
                                pctipper_rel || 'ppparticipacion:' ||


                                ppparticipacion || 'pcagrupa:' || pcagrupa || 'pfagrupa:' || pfagrupa;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_persona_rel';
      /*mensajes  T_IAX_MENSAJES;*/
      errores t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         psperson_rel IS NULL OR
         pctipper_rel IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_set_persona_rel(psperson, pcagente,
                                                psperson_rel, pctipper_rel,
                                                ppparticipacion, pislider,

                                                errores, ptablas, ptlimit, pcagrupa, pfagrupa);

      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_persona_rel;

   /*************************************************************************
      FUNCTION funcion que recupera la informacion del regimen fiscal
      param in psperson    : Persona
      param in pcagente    : Agente
      param in pfefecto    : Fecha efectop
      poregimenfiscal out ob_iax_regimenfiscal : Objeto de regimen fiscal
      return           : codigo de error
       ---- Bug 18942 - 29/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_regimenfiscal(psperson        IN NUMBER,
                                pcagente        IN NUMBER,
                                pfefecto        IN DATE,
                                poregimenfiscal OUT ob_iax_regimenfiscal,
                                mensajes        IN OUT t_iax_mensajes,
                                ptablas         IN VARCHAR2) RETURN NUMBER IS
/*******************************************************************************
   NOMBRE:       f_get_regimenfiscal
  

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/07/2019   ROHIT			  1.IAXIS 4697 El campo de IVA debe ser visible en este seccion en personas 	
******************************************************************************/
								
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente ||
                                ' pfefecto = ' || pfefecto || ' ptablas = ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_regimenfiscal';

      CURSOR c1 IS
         SELECT anualidad,
                fefecto,
                cregfiscal,
                cregfisexeiva,
                CTIPIVA
           FROM per_regimenfiscal pr
          WHERE pr.sperson = psperson
            AND pr.cagente = pcagente
            AND pr.fefecto = pfefecto
            AND ptablas <> 'EST'
          ORDER BY fefecto DESC;
      /*De momento no se hace la parte de las EST*/
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      poregimenfiscal := ob_iax_regimenfiscal();

      FOR rc IN c1
      LOOP
         poregimenfiscal.sperson       := psperson;
         poregimenfiscal.cagente       := pcagente;
         poregimenfiscal.anualidad     := rc.anualidad;
         poregimenfiscal.fefecto       := rc.fefecto;
         poregimenfiscal.cregfiscal    := rc.cregfiscal;
         poregimenfiscal.tregfiscal    := ff_desvalorfijo(1045,
                                                          pac_md_common.f_get_cxtidioma(),
                                                          rc.cregfiscal);
         poregimenfiscal.cregfisexeiva := rc.cregfisexeiva;
		 /*START ADDED FOR IAXIS 4697 */
          poregimenfiscal.CTIPIVA:=FF_DESTIPIVA(rc.CTIPIVA,pac_md_common.f_get_cxtidioma());---added
         /*END ADDED FOR IAXIS 4697 */
      END LOOP;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
         /*      WHEN NO_DATA_FOUND THEN*/
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_regimenfiscal;

   /*************************************************************************
     FUNCTION funcion que recupera la informacion de las personas relacionada y devuelve una coleccion
     param in psperson    : Persona
     param in pcagente    : Agente
     ptregimenfiscal out t_iax_regimenfiscal : Coleccion de regimen fiscal
     return           : codigo de error
      ---- Bug 18942 - 29/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_regimenfiscales(psperson        IN NUMBER,
                                  pcagente        IN NUMBER,
                                  ptablas         IN VARCHAR2,
                                  ptregimenfiscal OUT t_iax_regimenfiscal,
                                  mensajes        IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pcagente = ' || pcagente ||
                                 ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_GET_REGIMENFISCALES';

      CURSOR c1 IS
         SELECT sperson,
                cagente,
                fefecto
           FROM ( /*SELECT sperson, cagente, fefecto
                                                                          FROM estper_regimenfiscal
                                                                         WHERE sperson = psperson
                                                                           AND ptablas = 'EST'
                                                                        UNION ALL*/
                 /*a futuro*/
                 SELECT sperson,
                         cagente,
                         fefecto
                   FROM per_regimenfiscal
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND ptablas != 'EST'
                  ORDER BY fefecto DESC);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ptregimenfiscal := t_iax_regimenfiscal();

      FOR reg IN c1
      LOOP
         ptregimenfiscal.extend;
         ptregimenfiscal(ptregimenfiscal.last) := ob_iax_regimenfiscal();
         vnumerr := f_get_regimenfiscal(psperson, pcagente, reg.fefecto,
                                        ptregimenfiscal(ptregimenfiscal.last),
                                        mensajes, ptablas);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_regimenfiscales;

   /*************************************************************************
   Nueva funcion que se encarga de borrar un regimen fiscal
   return              : 0 Ok. 1 Error
   Bug.: 18942
   *************************************************************************/
   FUNCTION f_del_regimenfiscal(psperson IN NUMBER,
                                pcagente IN NUMBER,
                                pfefecto IN DATE,
                                mensajes IN OUT t_iax_mensajes,
                                ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'pcagente ' || pcagente || ' pfefecto : ' ||
                                pfefecto;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_del_regimenfiscal';
      errores  t_ob_error;
      cont     NUMBER;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         pfefecto IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(1)
        INTO cont
        FROM per_regimenfiscal
       WHERE sperson = psperson
         AND cagente = pcagente
         AND fefecto = pfefecto
         AND ptablas <> 'EST'; --De momento solo se hace para las reales.

      IF cont = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      pac_persona.p_del_regimenfiscal(psperson, pcagente, pfefecto, errores,
                                      pac_md_common.f_get_cxtidioma(),
                                      ptablas);
      vpasexec := 2;
      mensajes := f_traspasar_errores_mensajes(errores);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_regimenfiscal;

   /*************************************************************************
    Nueva funcion que se encarga de insertar el regimen fiscal
    return              : 0 Ok. 1 Error
    Bug.: 18942
   *************************************************************************/
   FUNCTION f_set_regimenfiscal(psperson       IN NUMBER,
                                pcagente       IN NUMBER,
                                pfefecto       IN DATE,
                                pcregfiscal    IN NUMBER,
				-- CP0025M_SYS_PERS - JLTS - 21/11/2018 - se intercambia el orden de los parámetros pctipiva y pcregfisexeiva
                               /* pctipiva       IN NUMBER,
				pcregfisexeiva IN NUMBER DEFAULT 0, --AP CONF-190
			*/
		/* IAXIS-4696 Start*/

				pcregfisexeiva IN NUMBER DEFAULT 0,
				pctipiva       IN NUMBER,
  /* End IAXIS-4696 */

                                mensajes       IN OUT t_iax_mensajes,
                                ptablas        IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                'Cagente:' || pcagente || ' Fefecto:' ||
                                pcregfiscal || ' Cregfiscal:' ||
                                pcregfiscal || 'pcregfisexeiva' ||
                                pcregfisexeiva|| 'pctipiva' ||
                                pctipiva;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_Set_regimenfiscal';
      /*mensajes  T_IAX_MENSAJES;*/
      errores t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         pfefecto IS NULL OR
         pcregfiscal IS NULL
		 -- OR pctipiva IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_set_regimenfiscal(psperson, pcagente,
                                                  pfefecto, pcregfiscal,
                                                  pcregfisexeiva, pctipiva, errores,
                                                  ptablas);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_regimenfiscal;

   /*************************************************************************
    Nueva funcion que se encarga de recuperar informacion de un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   ************************************************************************/
   FUNCTION f_get_sarlaft(psperson  IN NUMBER,
                          pcagente  IN NUMBER,
                          pfefecto  IN DATE,
                          posarlaft OUT ob_iax_sarlaft,
                          mensajes  IN OUT t_iax_mensajes,
                          ptablas   IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente: ' || pcagente || ' pfefecto: ' ||
                                pfefecto || ' ptablas: ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_sarlaft';

      CURSOR c1 IS
         SELECT cusualt,
                falta
           FROM per_sarlaft
          WHERE sperson = psperson
            AND cagente = pcagente
            AND fefecto = pfefecto
            AND ptablas <> 'EST' -- de momento solo se hace para las reales
          ORDER BY fefecto DESC;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      posarlaft := ob_iax_sarlaft();

      FOR rc IN c1
      LOOP
         posarlaft.sperson := psperson;
         posarlaft.cagente := pcagente;
         posarlaft.fefecto := pfefecto;
         posarlaft.cusualt := rc.cusualt;
         posarlaft.falta   := rc.falta;
      END LOOP;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_sarlaft;

   /*************************************************************************
    Nueva funcion que se encarga de recuperar registros de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   ************************************************************************/
   FUNCTION f_get_sarlafts(psperson  IN NUMBER,
                           pcagente  IN NUMBER,
                           ptablas   IN VARCHAR2,
                           ptsarlaft OUT t_iax_sarlaft,
                           mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pcagente: ' || pcagente || ' ptablas: ' ||
                                 ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_sarlafts';

      CURSOR c1 IS
         SELECT sperson,
                cagente,
                fefecto
           FROM per_sarlaft
          WHERE sperson = psperson
            AND cagente = pcagente
            AND ptablas <> 'EST' -- de momento solo se hace para las reales
          ORDER BY fefecto DESC;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ptsarlaft := t_iax_sarlaft();

      FOR reg IN c1
      LOOP
         ptsarlaft.extend;
         ptsarlaft(ptsarlaft.last) := ob_iax_sarlaft();
         vnumerr := f_get_sarlaft(psperson, pcagente, reg.fefecto,
                                  ptsarlaft(ptsarlaft.last), mensajes,
                                  ptablas);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_sarlafts;

   /*************************************************************************
    Nueva funcion que se encarga de borrar un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_del_sarlaft(psperson IN NUMBER,
                          pcagente IN NUMBER,
                          pfefecto IN DATE,
                          mensajes IN OUT t_iax_mensajes,
                          ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente: ' || pcagente || ' pfefecto: ' ||
                                pfefecto;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_del_sarlaft';
      errores  t_ob_error;
      cont     NUMBER;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         pfefecto IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /* verificar que existe el registro en la tabla*/
      SELECT COUNT(1)
        INTO cont
        FROM per_sarlaft
       WHERE sperson = psperson
         AND cagente = pcagente
         AND fefecto = pfefecto
         AND ptablas <> 'EST'; -- de momento solo se hace para las reales

      IF cont = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      /* de momento solo se utiliza para las tablas reales, no se hace la parte de las EST*/
      vnumerr  := pac_persona.f_del_sarlaft(psperson, pcagente, pfefecto,
                                            errores,
                                            pac_md_common.f_get_cxtidioma(),
                                            'POL');
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_sarlaft;

   /*************************************************************************
    Nueva funcion que se encarga de insertar un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_set_sarlaft(psperson IN NUMBER,
                          pcagente IN NUMBER,
                          pfefecto IN DATE,
                          mensajes IN OUT t_iax_mensajes,
                          ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente: ' || pcagente || ' pfefecto: ' ||
                                pfefecto;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_sarlaft';
      errores  t_ob_error;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         pfefecto IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /* de momento solo se utiliza para las tablas reales, no se hace la parte de las EST*/
      vnumerr  := pac_persona.f_set_sarlaft(psperson, pcagente, pfefecto,
                                            errores, 'POL');
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_sarlaft;

   /*************************************************************************
    Nueva funcion que obtiene informacion de los gestores/empleados de la persona
    param in psperson   : Codigo sperson
    param out pcur      : Cursor con la informacion
    param out mensajes  : mensajes de error
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_gestores_empleados(psperson IN NUMBER,
                                     pcur     OUT SYS_REFCURSOR,
                                     mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_gestores_empleados';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_gestores_empleados(psperson,
                                                      pac_md_common.f_get_cxtidioma,
                                                      squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_gestores_empleados;

   /*************************************************************************
    Nueva funcion que obtiene informacion de los representantes/promotores de la persona
    param in psperson   : Codigo sperson
    param out pcur      : Cursor con la informacion
    param out mensajes  : mensajes de error
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_represent_promotores(psperson IN NUMBER,
                                       pcur     OUT SYS_REFCURSOR,
                                       mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_represent_promotores';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_represent_promotores(psperson,
                                                        pac_md_common.f_get_cxtidioma,
                                                        squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_represent_promotores;

   /*************************************************************************
    Nueva funcion que obtiene informacion de los representantes/promotores asociados a un coordinador
    param in psperson   : Codigo sperson
    param out pcur      : Cursor con la informacion
    param out mensajes  : mensajes de error
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_coordinadores(psperson IN NUMBER,
                                pcur     OUT SYS_REFCURSOR,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_coordinadores';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_coordinadores(psperson,
                                                 pac_md_common.f_get_cxtidioma,
                                                 squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_coordinadores;

   /*************************************************************************
    Nueva funcion que obtiene informacion de las listas oficiales del estado de la persona
    param in psperson   : Codigo sperson
    param in pcclalis   : Identificador de clase de lista
    param out pcur      : Cursor con la informacion
    param out mensajes  : mensajes de error
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_listas_oficiales(psperson IN NUMBER,
                                   pcclalis IN NUMBER,
                                   pcur     OUT SYS_REFCURSOR,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcclalis:' || pcclalis;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_listas_oficiales';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL OR
         pcclalis IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_listas_oficiales(psperson, pcclalis,
                                                    pac_md_common.f_get_cxtidioma,
                                                    squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_listas_oficiales;

   /* Bug 18946 - APD - 28/10/2011 - se crea la funcion*/
   FUNCTION ff_agente_cpolvisio(pcagente IN agentes.cagente%TYPE,
                                pfecha   IN DATE DEFAULT f_sysdate,
                                pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa)
      RETURN NUMBER IS
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(2000) := 'pcagente= ' || pcagente || '; pfecha= ' ||
                                   pfecha || '; pcempres= ' || pcempres;
      vobject    VARCHAR2(200) := 'PAC_MD_PERSONA.ff_agente_cpolvisio';
      xcpolvisio redcomercial.cpolvisio%TYPE;
      vfecha     DATE;
   BEGIN
      vfecha := pfecha;

      IF vfecha IS NULL
      THEN
         vfecha := f_sysdate;
      END IF;

      SELECT cpolvisio
        INTO xcpolvisio
        FROM redcomercial a
       WHERE a.cagente = pcagente
         AND a.fmovini <= vfecha
         AND a.cempres = pcempres
            /*Bug.: 0010422 - 25/06/2009 - ICV - Se a?ade la empresa como parametro por defecto la del contexto.*/
         AND (a.fmovfin >= vfecha OR a.fmovfin IS NULL);

      RETURN xcpolvisio;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, vparam, SQLERRM);
         RETURN NULL; /* error al leer el campo cpolvisio de la redcomercial*/
   END ff_agente_cpolvisio;

   /*************************************************************************
    funcion que torna l'agent de visio de polizas passant-li un agent
   *************************************************************************/
   /* Bug 18946 - APD - 28/10/2011 - se crea la funcion*/
   FUNCTION f_agente_cpolvisio(pcagente   IN agentes.cagente%TYPE,
                               pfecha     IN DATE DEFAULT f_sysdate,
                               pcempres   IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa(),
                               pcpolvisio IN OUT NUMBER,
                               mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pcagente= ' || pcagente || '; pfecha= ' ||
                                 pfecha || '; pcempres= ' || pcempres;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_agente_cpolvisio';
   BEGIN
      IF pcagente IS NOT NULL
      THEN
         pcpolvisio := pac_md_persona.ff_agente_cpolvisio(pcagente, pfecha,
                                                          pcempres);

         IF pcpolvisio IS NULL
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_agente_cpolvisio;

   /* Bug 18946 - APD - 28/10/2011 - se crea la funcion*/
   FUNCTION ff_agente_cpolnivel(pcagente IN agentes.cagente%TYPE,
                                pfecha   IN DATE DEFAULT f_sysdate,
                                pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa)
      RETURN NUMBER IS
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(2000) := 'pcagente= ' || pcagente || '; pfecha= ' ||
                                   pfecha || '; pcempres= ' || pcempres;
      vobject    VARCHAR2(200) := 'PAC_MD_PERSONA.ff_agente_cpolnivel';
      xcpolnivel redcomercial.cpolnivel%TYPE;
      vfecha     DATE;
   BEGIN
      vfecha := pfecha;

      IF vfecha IS NULL
      THEN
         vfecha := f_sysdate;
      END IF;

      SELECT cpolnivel
        INTO xcpolnivel
        FROM redcomercial a
       WHERE a.cagente = pcagente
         AND a.fmovini <= vfecha
         AND a.cempres = pcempres
            /*Bug.: 0010422 - 25/06/2009 - ICV - Se a?ade la empresa como parametro por defecto la del contexto.*/
         AND (a.fmovfin >= vfecha OR a.fmovfin IS NULL);

      RETURN xcpolnivel;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'FF_AGENTE_CPOLNIVEL ', 1,
                     '-- pcagente =' || pcagente || ' --  Pfecha ' ||
                      pfecha, SQLERRM);
         RETURN NULL; /* error al leer el campo cpolvisio de la redcomercial*/
   END ff_agente_cpolnivel;

   /*************************************************************************
    funcion que torna l'agent de nivel de polizas passant-li un agent
   *************************************************************************/
   /* Bug 18946 - APD - 28/10/2011 - se crea la funcion*/
   FUNCTION f_agente_cpolnivel(pcagente   IN agentes.cagente%TYPE,
                               pfecha     IN DATE DEFAULT f_sysdate,
                               pcempres   IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa(),
                               pcpolnivel IN OUT NUMBER,
                               mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(2000) := 'pcagente= ' || pcagente || '; pfecha= ' ||
                                 pfecha || '; pcempres= ' || pcempres;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_agente_cpolnivel';
   BEGIN
      IF pcagente IS NOT NULL
      THEN
         pcpolnivel := pac_md_persona.ff_agente_cpolnivel(pcagente, pfecha,
                                                          pcempres);

         IF pcpolnivel IS NULL
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_agente_cpolnivel;

   /*************************************************************************
     funcion que recuperara todas la personas dependiendo del modo.
     publico o no. servira para todas las pantallas donde quieran utilizar el
     buscador de personas.

     Bug 20044/97773 - 12/11/2011 - AMC
   *************************************************************************/
   FUNCTION f_get_personas_generica_cond(pnumide       IN VARCHAR2,
                                         pnombre       IN VARCHAR2,
                                         pnsip         IN VARCHAR2 DEFAULT NULL,
                                         mensajes      IN OUT t_iax_mensajes,
                                         pnom          IN VARCHAR2 DEFAULT NULL,
                                         pcognom1      IN VARCHAR2 DEFAULT NULL,
                                         pcognom2      IN VARCHAR2 DEFAULT NULL,
                                         pctipide      IN NUMBER DEFAULT NULL,
                                         pcagente      IN NUMBER DEFAULT NULL,
                                         pmodo_swpubli IN VARCHAR2,
                                         pcond         IN VARCHAR2)
      RETURN SYS_REFCURSOR IS
      condicio1   VARCHAR2(1000);
      condicio2   VARCHAR2(1000);
      condicio3   VARCHAR2(1000);
      condicio4   VARCHAR2(1000);
      condicio5   VARCHAR2(1000);
      condicio6   VARCHAR2(1000);
      condicio7   VARCHAR2(1000);
      condicion   VARCHAR2(8000);
      tlog        VARCHAR2(4000);
      cur         SYS_REFCURSOR;
      vpasexec    NUMBER(8) := 1;
      vparam      VARCHAR2(2000) := 'numide= ' || pnumide || ', nombre= ' ||
                                    pnombre || ', nsip= ' || pnsip ||
                                    ',pnom= ' || pnom || ', pcognom1= ' ||
                                    pcognom1 || ', pcognom2= ' || pcognom2 ||
                                    ', pctipide= ' || pctipide || ' pcond:' ||
                                    pcond;
      vobjectname VARCHAR2(3000) := 'PAC_MD_PERSONA.f_get_persona_generica_cond';
      vnumerr     NUMBER(10) := 0;
      terror      VARCHAR2(3000) := 'Error recuperar personas';
      /*//ACC recuperar desde literales*/
      auxnom       VARCHAR2(3000);
      nerr         NUMBER;
      cur_generica SYS_REFCURSOR;
      vsquery      CLOB;
      /*//ACC recuperar desde literales*/
      /*//ACC  PAC_IOBJ_MENSAJES.F_GET_DESCMENSAJE(XXX,PAC_MD_COMMON.F_GET_CXTIDIOMA);*/
   BEGIN
      vnumerr := pac_persona.f_get_persona_generica_cond(pnumide, pnombre,
                                                         pnsip, pnom,
                                                         pcognom1, pcognom2,
                                                         pctipide, pcagente,
                                                         pmodo_swpubli, pcond,
                                                         vsquery);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      /*BUG10300-XVM-17092009*/
      vnumerr      := pac_md_log.f_log_consultas(vsquery,
                                                 'PAC_MD_PERSONA.F_GET_PERSONAS_GENERICA_COND',
                                                 1, 1, mensajes);
      cur_generica := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur_generica;
      RETURN NULL;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005,
                                           vpasexec, vparam);

         IF cur_generica%ISOPEN
         THEN
            CLOSE cur_generica;
         END IF;

         RETURN cur_generica;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006,
                                           vpasexec, vparam, vnumerr);

         IF cur_generica%ISOPEN
         THEN
            CLOSE cur_generica;
         END IF;

         RETURN cur_generica;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001,
                                           vpasexec, vparam, terror, SQLCODE,
                                           SQLERRM);

         IF cur_generica%ISOPEN
         THEN
            CLOSE cur_generica;
         END IF;

         RETURN cur_generica;
   END f_get_personas_generica_cond;

   /*************************************************************************
     Funcion que inserta o actualiza los datos de un documento asociado a la persona

     Bug 20126 - APD - 23/11/2011 - se crea la funcion
   *************************************************************************/
   FUNCTION f_set_docpersona(psperson    IN NUMBER,
                             pcagente    IN NUMBER,
                             pfcaduca    IN DATE,
                             ptobserva   IN VARCHAR2,
                             piddocgedox IN OUT NUMBER,
                             ptdocumento IN NUMBER DEFAULT NULL,
                             pedocumento IN NUMBER DEFAULT NULL,
                             pfedo       IN DATE DEFAULT NULL,
                             mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' - pcagente: ' || pcagente ||
                                ' - pfcaduca: ' ||
                                TO_CHAR(pfcaduca, 'DD/MM/YYYY') ||
                                ' - ptobserva: ' || ptobserva ||
                                ' - piddocgedox: ' || piddocgedox ||
                                ' - ptdocumento: ' || ptdocumento ||
                                ' - pedocumento: ' || pedocumento ||
                                ' - pfedo: ' || pfedo;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_docpersona';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_set_docpersona(psperson, pcagente, pfcaduca,
                                              ptobserva, piddocgedox,
                                              ptdocumento, pedocumento, pfedo);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_docpersona;

   /*************************************************************************
     FUNCTION funcion que recupera la informacion de los datos de un documento
     asociado a la persona.
     param in psperson    : Persona
     param in pcagente    : Agente
     param in piddocgedox  : documento gedox
     pobdocpersona out ob_iax_docpersona : Objeto de documentos de personas
     return           : codigo de error
      ---- Bug 20126 - 23/11/2011 - APD
   *************************************************************************/
   FUNCTION f_get_docpersona(psperson      IN NUMBER,
                             pcagente      IN NUMBER,
                             piddocgedox   IN NUMBER,
                             ptablas       IN VARCHAR2,
                             pobdocpersona OUT ob_iax_docpersona,
                             mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente ||
                                ' piddocgedox = ' || piddocgedox ||
                                ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_docpersona';
      dummy    NUMBER;

      CURSOR c1 IS
         SELECT sperson,
                cagente,
                iddocgedox,
                fcaduca,
                tobserva,
                cusualt,
                falta,
                cusuari,
                fmovimi,
                tdocumento,
                edocumento,
                fedo
           FROM per_documentos pd
          WHERE pd.sperson = psperson
            AND pd.cagente = pcagente
            AND pd.iddocgedox = piddocgedox
            AND ptablas <> 'EST';
      /*De momento no se hace la parte de las EST*/
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pobdocpersona := ob_iax_docpersona();

      FOR rc IN c1
      LOOP
         pobdocpersona.sperson    := rc.sperson;
         pobdocpersona.cagente    := rc.cagente;
         pobdocpersona.iddocgedox := rc.iddocgedox;
         pobdocpersona.fcaduca    := rc.fcaduca;
         pobdocpersona.tobserva   := rc.tobserva;
         pobdocpersona.cusualt    := rc.cusualt;
         pobdocpersona.falta      := rc.falta;
         pobdocpersona.cusuari    := rc.cusuari;
         pobdocpersona.fmovimi    := rc.fmovimi;
         pobdocpersona.tdocumento := rc.tdocumento;
         pobdocpersona.edocumento := rc.edocumento;
         pobdocpersona.fedo       := rc.fedo;
         pobdocpersona.iddcat     := pac_axisgedox.f_get_catdoc(pobdocpersona.iddocgedox);
         pobdocpersona.tdescrip   := pac_axisgedox.f_get_descdoc(pobdocpersona.iddocgedox);
         pobdocpersona.fichero    := SUBSTR(pac_axisgedox.f_get_filedoc(pobdocpersona.iddocgedox),
                                            INSTR(pac_axisgedox.f_get_filedoc(pobdocpersona.iddocgedox),
                                                   '\', -1) + 1,
                                            length(pac_axisgedox.f_get_filedoc(pobdocpersona.iddocgedox)));
      END LOOP;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
         /*      WHEN NO_DATA_FOUND THEN*/
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_docpersona;

   /*************************************************************************
   FUNCTION funcion que recupera la informacion de los datos de un documento
   asociado a la persona.
   param in psperson    : Persona
   param in pcagente    : Agente
   ptdocpersona out t_iax_docpersona : Coleccion de objetos de documentos de personas
   return           : codigo de error
    ---- Bug 20126 - 23/11/2011 - APD
   *************************************************************************/
   FUNCTION f_get_documentacion(psperson     IN NUMBER,
                                pcagente     IN NUMBER,
                                ptablas      IN VARCHAR2,
                                ptdocpersona OUT t_iax_docpersona,
                                mensajes     IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pcagente = ' || pcagente ||
                                 ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_documentacion';

      CURSOR cur_perrel IS
         SELECT sperson,
                cagente,
                iddocgedox
           FROM ( /*SELECT sperson, cagente, iddocgedox
                                                                       FROM estper_documentos
                                                                      WHERE sperson = psperson
                                                                        AND cagente = pcagente
                                                                           AND ptablas = 'EST'
                                                                        UNION ALL*/
                 /*a futuro*/
                 SELECT sperson,
                         cagente,
                         iddocgedox
                   FROM per_documentos
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND ptablas != 'EST');
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ptdocpersona := t_iax_docpersona();

      FOR reg IN cur_perrel
      LOOP
         ptdocpersona.extend;
         ptdocpersona(ptdocpersona.last) := ob_iax_docpersona();
         vnumerr := f_get_docpersona(psperson, pcagente, reg.iddocgedox,
                                     ptablas, ptdocpersona(ptdocpersona.last),
                                     mensajes);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_documentacion;

   /***************************************************************************
   Funcin para obtener el dgito de control del documento de identidad de Colombia
   Tipos de documento a los que puede aplicar calcular el dgito de control
   Tipo de Documento ------------------- Tipo -------- Regla de validacin - Tamao -----
   36 - Cdula ciudadana                Numrico      Nmeros               Entre 3 y 10
   *****************************************************************************/
   FUNCTION f_digito_nif_col(pctipide IN NUMBER,
                             pnnumide IN VARCHAR2,
                             mensajes IN OUT t_iax_mensajes) RETURN VARCHAR2 IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par?!metros - pnnumide: ' || pnnumide ||
                                ' pctipide = ' || pctipide;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_digito_nif_col';
      digito   VARCHAR2(5);
      ss       VARCHAR2(3000);
      v_propio VARCHAR2(500);
      v_cursor NUMBER;
      v_filas  NUMBER;
      retorno  VARCHAR2(1);
      wnnumide per_personas.nnumide%TYPE; /* BUG 26968/0155105 - FAL - 15/10/2013*/
   BEGIN
      IF pctipide IS NULL OR
         pnnumide IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /* Bug 24780 - ETM - 11/12/2012*/
      BEGIN
         SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                              'PAC_IDE_PERSONA')
           INTO v_propio
           FROM dual;
      EXCEPTION
         WHEN OTHERS THEN
            v_propio := NULL;
      END;

      wnnumide := pac_persona.f_desformat_nif(pnnumide, pctipide); /* BUG 26968/0155105 - FAL - 15/10/2013*/

      IF v_propio IS NOT NULL
      THEN
         ss := 'BEGIN ' || ' :RETORNO :=  PAC_IDE_PERSONA.' || v_propio || '(' ||
               pctipide || ',' || UPPER(wnnumide) || ')' || ';' || 'END;';

         IF dbms_sql.is_open(v_cursor)
         THEN
            dbms_sql.close_cursor(v_cursor);
         END IF;

         v_cursor := dbms_sql.open_cursor;
         dbms_sql.parse(v_cursor, ss, dbms_sql.native);
         dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno, 20);
         v_filas := dbms_sql.execute(v_cursor);
         dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

         IF dbms_sql.is_open(v_cursor)
         THEN
            dbms_sql.close_cursor(v_cursor);
         END IF;

         digito := retorno;
      END IF;

      /*fin bug 24780 - ETM - 11/12/2012*/
      /* digito := pac_ide_persona.f_digito_nif_col(pctipide, pnnumide);*/
      RETURN digito;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_digito_nif_col;

   /**************************************************************
     Funcion que valida si hay una ccc con pagos de siniestros
     param in psperson : codigo de persona
     param in pcagente : codigo del agente
     param out pcodilit : codigo del literal a mostrar
     return codigo error : 0 - ok ,codigo de error
     BUG 20958/104928 - 24/01/2012 - AMC

     Bug 21867/111852 - 29/03/2012 - AMC
   **************************************************************/
   FUNCTION f_valida_pagoccc(psperson  IN NUMBER,
                             pcagente  IN NUMBER,
                             pcnordban IN NUMBER,
                             pcodilit  IN OUT NUMBER,
                             mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_valida_pagoccc';
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_valida_pagoccc(psperson, pcagente, pcnordban,
                                              pcodilit);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_pagoccc;

   /***************************************************************************
   Funcion bloquear una persona por LOPD
   Traspasara los datos de la persona a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_bloquear_persona(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_bloquear_persona';
      vcagente NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_bloquear_persona(psperson, pcagente,
                                                pac_md_common.f_get_cxtidioma);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_bloquear_persona;

   /***************************************************************************
   Funcion desbloquear una persona por LOPD
   Volvera a deja la persona igual que antes que el traspaso a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_desbloquear_persona(psperson IN NUMBER,
                                  pcagente IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_bloquear_persona';
      vcagente NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_desbloquear_persona(psperson, pcagente,
                                                   pac_md_common.f_get_cxtidioma);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_desbloquear_persona;

   /***************************************************************************
   Funcion borra persona de la lopd
   *****************************************************************************/
   FUNCTION f_borrar_persona_lopd(psperson IN NUMBER,
                                  pcagente IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_borrar_persona_lopd';
      vcagente NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_borrar_persona_lopd(psperson, pcagente,
                                                   pac_md_common.f_get_cxtidioma);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_borrar_persona_lopd;

   /*************************************************************************
       FUNCTION funcion que recupera la informacion de la lopd
       param in psperson    : Persona
       param in pcagente    : Agente
       return           : codigo de error
   *************************************************************************/
   FUNCTION f_get_perlopd(psperson IN NUMBER,
                          pcagente IN NUMBER,
                          pperlopd OUT t_iax_perlopd,
                          pcestado OUT NUMBER,
                          ptestado OUT VARCHAR2,
                          mensajes IN OUT t_iax_mensajes,
                          ptablas  IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente || ' ptablas = ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_perlopd';

      CURSOR c1 IS
         SELECT *
           FROM per_lopd pr
          WHERE pr.sperson = psperson
            AND pr.cagente = pcagente
            AND ptablas <> 'EST'
          ORDER BY norden DESC;
      /*De momento no se hace la parte de las EST*/
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pperlopd := t_iax_perlopd();

      FOR rc IN c1
      LOOP
         pperlopd.extend;
         pperlopd(pperlopd.last) := ob_iax_perlopd();
         pperlopd(pperlopd.last).sperson := psperson;
         pperlopd(pperlopd.last).cagente := pcagente;
         pperlopd(pperlopd.last).fmovimi := rc.fmovimi;
         pperlopd(pperlopd.last).cusuari := rc.cusuari;
         pperlopd(pperlopd.last).cestado := rc.cestado;
         pperlopd(pperlopd.last).testado := ff_desvalorfijo(276,
                                                            pac_md_common.f_get_cxtidioma(),
                                                            rc.cestado);
         pperlopd(pperlopd.last).ctipdoc := rc.ctipdoc;
         pperlopd(pperlopd.last).ttipdoc := ff_desvalorfijo(277,
                                                            pac_md_common.f_get_cxtidioma(),
                                                            rc.ctipdoc);
         pperlopd(pperlopd.last).ftipdoc := rc.ftipdoc;
         pperlopd(pperlopd.last).catendido := rc.catendido;
         pperlopd(pperlopd.last).fatendido := rc.fatendido;
         pperlopd(pperlopd.last).norden := rc.norden;
         pperlopd(pperlopd.last).cesion := rc.cesion;
         pperlopd(pperlopd.last).publicidad := rc.publicidad;
         pperlopd(pperlopd.last).cancelacion := rc.cancelacion;
         pperlopd(pperlopd.last).acceso := rc.acceso;
         pperlopd(pperlopd.last).rectificacion := rc.rectificacion;

         IF rc.cestado IS NOT NULL AND
            pcestado IS NULL
         THEN
            pcestado := rc.cestado;
            ptestado := pperlopd(pperlopd.last).testado;
         END IF;
      END LOOP;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
         /*      WHEN NO_DATA_FOUND THEN*/
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_perlopd;

   /***************************************************************************
   Funcion inserta un nuevo movimiento en LOPD
   *****************************************************************************/
   FUNCTION f_set_persona_lopd(psperson       IN NUMBER,
                               pcagente       IN NUMBER,
                               pcesion        IN NUMBER,
                               ppublicidad    IN NUMBER,
                               pacceso        IN NUMBER,
                               prectificacion IN NUMBER,
                               mensajes       IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente || ' pcesion = ' ||
                                pcesion || ' ppublicidad = ' || ppublicidad ||
                                ' pacceso = ' || pacceso ||
                                ' prectificacion = ' || prectificacion;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_persona_lopd';
      vcagente NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_set_persona_lopd(psperson, pcagente, pcesion,
                                                ppublicidad, pacceso,
                                                prectificacion,
                                                pac_md_common.f_get_cxtidioma);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_persona_lopd;

   /*************************************************************************
       FUNCTION que recupera los carnets de una persona
       param in psperson    : Persona
       param in pcagente    : Agente
       return           : codigo de error
       XPL bug 21531#08032012
   *************************************************************************/
   FUNCTION f_get_perautcarnets(psperson       IN NUMBER,
                                pcagente       IN NUMBER,
                                pperautcarnets OUT t_iax_perautcarnets,
                                mensajes       IN OUT t_iax_mensajes,
                                ptablas        IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente || ' ptablas = ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_perautcarnets';

      CURSOR c1 IS
         SELECT *
           FROM per_autcarnet pr
          WHERE pr.sperson = psperson
            AND pr.cagente = pcagente;

      CURSOR c2 IS
         SELECT * FROM estper_autcarnet pr WHERE pr.sperson = psperson;
      /* AND pr.cagente = pcagente;*/
      /*De momento no se hace la parte de las EST*/
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pperautcarnets := t_iax_perautcarnets();

      IF ptablas = 'EST'
      THEN
         FOR rc IN c2
         LOOP
            pperautcarnets.extend;
            pperautcarnets(pperautcarnets.last) := ob_iax_perautcarnets();
            pperautcarnets(pperautcarnets.last).sperson := psperson;
            pperautcarnets(pperautcarnets.last).cagente := pcagente;
            pperautcarnets(pperautcarnets.last).ctipcar := rc.ctipcar;
            pperautcarnets(pperautcarnets.last).ttipcar := ff_desvalorfijo(812,
                                                                           pac_md_common.f_get_cxtidioma,
                                                                           rc.ctipcar);
            pperautcarnets(pperautcarnets.last).cdefecto := rc.cdefecto;
            pperautcarnets(pperautcarnets.last).fcarnet := rc.fcarnet;
         END LOOP;
      ELSE
         FOR rc IN c1
         LOOP
            pperautcarnets.extend;
            pperautcarnets(pperautcarnets.last) := ob_iax_perautcarnets();
            pperautcarnets(pperautcarnets.last).sperson := psperson;
            pperautcarnets(pperautcarnets.last).cagente := pcagente;
            pperautcarnets(pperautcarnets.last).ctipcar := rc.ctipcar;
            pperautcarnets(pperautcarnets.last).ttipcar := ff_desvalorfijo(812,
                                                                           pac_md_common.f_get_cxtidioma,
                                                                           rc.ctipcar);
            pperautcarnets(pperautcarnets.last).cdefecto := rc.cdefecto;
            pperautcarnets(pperautcarnets.last).fcarnet := rc.fcarnet;
         END LOOP;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
         /*      WHEN NO_DATA_FOUND THEN*/
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_perautcarnets;

   /**************************************************************
   Funcio para obtener la lista de autorizaciones de contactos y la lista de autorizaciones de direcciones
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   return lista de autorizaciones
   BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_autorizaciones(psperson IN NUMBER,
                                 pcagente IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_personas_aut IS
      vnumerr          NUMBER(8) := 0;
      vpasexec         NUMBER(8) := 1;
      vparam           VARCHAR2(500) := 'parametros - psperson: ' ||
                                        psperson || ' pcagente:' ||
                                        pcagente;
      vobject          VARCHAR2(200) := 'PAC_MD_PERSONA.F_GET_AUTORIZACIONES';
      vpersona_aut     ob_iax_personas_aut;
      pdirecciones_aut t_iax_direcciones_aut;
      pcontactos_aut   t_iax_contactos_aut;
   BEGIN
      vpersona_aut         := ob_iax_personas_aut();
      vpersona_aut.sperson := psperson;
      vpersona_aut.cagente := pcagente;
      pdirecciones_aut     := t_iax_direcciones_aut();

      FOR cur IN (SELECT p.*,
                         1 a
                    FROM per_direcciones_aut p
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND cestado = 1
                  UNION
                  SELECT p.*,
                         2 a
                    FROM per_direcciones_aut p
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND cestado <> 1
                   ORDER BY a)
      LOOP
         pdirecciones_aut.extend;
         pdirecciones_aut(pdirecciones_aut.last) := ob_iax_direcciones_aut();
         /* vnumerr := f_get_direccion(psperson,cur.cdomici,pdirecciones_aut(pdirecciones_aut.LAST).DIRECCION,mensajes ,'POL');


         pdirecciones_aut(pdirecciones_aut.LAST).norden := cur.norden;
         pdirecciones_aut(pdirecciones_aut.LAST).cusumod := cur.cusumod;
         pdirecciones_aut(pdirecciones_aut.LAST).fusumod := cur.fusumod;
         pdirecciones_aut(pdirecciones_aut.LAST).fbaja := cur.fbaja;
         pdirecciones_aut(pdirecciones_aut.LAST).cusuaut := cur.cusuaut;
         pdirecciones_aut(pdirecciones_aut.LAST).fautoriz := cur.fautoriz;
         pdirecciones_aut(pdirecciones_aut.LAST).cestado := cur.cestado;
         pdirecciones_aut(pdirecciones_aut.LAST).testado := pac_md_listvalores.f_getdescripvalores(800072,cur.cestado,mensajes);
         pdirecciones_aut(pdirecciones_aut.LAST).tobserva := cur.tobserva;
         */
         vnumerr := f_get_direccion_aut(psperson, pcagente, cur.cdomici,
                                        cur.norden,
                                        pdirecciones_aut(pdirecciones_aut.last),
                                        mensajes);

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;
      END LOOP;

      vpersona_aut.direcciones_aut := pdirecciones_aut;
      pcontactos_aut               := t_iax_contactos_aut();

      FOR cur IN (SELECT p.*,
                         1 a
                    FROM per_contactos_aut p
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND cestado = 1
                  UNION
                  SELECT p.*,
                         2 a
                    FROM per_contactos_aut p
                   WHERE sperson = psperson
                     AND cagente = pcagente
                     AND cestado <> 1
                   ORDER BY a)
      LOOP
         pcontactos_aut.extend;
         pcontactos_aut(pcontactos_aut.last) := ob_iax_contactos_aut();
         /* vnumerr := f_get_contacto(psperson, pcagente,cur.cmodcon, pcontactos_aut(pcontactos_aut.LAST).contacto, mensajes, 'POL');
         pcontactos_aut(pcontactos_aut.LAST).norden := cur.norden;
         pcontactos_aut(pcontactos_aut.LAST).cusumod := cur.cusumod;
         pcontactos_aut(pcontactos_aut.LAST).fusumod := cur.fusumod;
         pcontactos_aut(pcontactos_aut.LAST).fbaja := cur.fbaja;
         pcontactos_aut(pcontactos_aut.LAST).cusuaut := cur.cusuaut;
         pcontactos_aut(pcontactos_aut.LAST).fautoriz := cur.fautoriz;
         pcontactos_aut(pcontactos_aut.LAST).cestado := cur.cestado;
         pcontactos_aut(pcontactos_aut.LAST).testado := pac_md_listvalores.f_getdescripvalores(800072,cur.cestado,mensajes);
         pcontactos_aut(pcontactos_aut.LAST).tobserva := cur.tobserva;
         */
         vnumerr := f_get_contacto_aut(psperson, pcagente, cur.cmodcon,
                                       cur.norden,
                                       pcontactos_aut(pcontactos_aut.last),
                                       mensajes);

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;
      END LOOP;

      vpersona_aut.contactos_aut := pcontactos_aut;
      RETURN vpersona_aut;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_autorizaciones;

   /**************************************************************
    Funcio para obtener la lista de autorizaciones de contactos
    param in psperson : codigo de persona
    param in pcagente : codigo del agente
    return codigo error : 0 - ok ,codigo de error
    BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_contacto_aut(psperson       IN NUMBER,
                               pcagente       IN NUMBER,
                               pcmodcon       IN NUMBER,
                               pnorden        IN NUMBER,
                               obcontacto_aut OUT ob_iax_contactos_aut,
                               mensajes       IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente:' || pcagente || ' pcmodcon:' ||
                                pcmodcon || ' pnorden:' || pnorden;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_GET_CONTACTO_AUT';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         pcmodcon IS NULL OR
         pnorden IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF obcontacto_aut IS NULL
      THEN
         obcontacto_aut          := ob_iax_contactos_aut();
         obcontacto_aut.contacto := ob_iax_contactos();
      END IF;

      SELECT norden,
             cusumod,
             fusumod,
             fbaja,
             cusuaut,
             fautoriz,
             cestado,
             tobserva,
             cmodcon,
             ctipcon,
             tcomcon,
             tvalcon,
             cobliga,
             ff_desvalorfijo(15, pac_md_common.f_get_cxtidioma(), ctipcon) ttipcon,
             cdomici
        INTO obcontacto_aut.norden,
             obcontacto_aut.cusumod,
             obcontacto_aut.fusumod,
             obcontacto_aut.fbaja,
             obcontacto_aut.cusuaut,
             obcontacto_aut.fautoriz,
             obcontacto_aut.cestado,
             obcontacto_aut.tobserva,
             obcontacto_aut.contacto.cmodcon,
             obcontacto_aut.contacto.ctipcon,
             obcontacto_aut.contacto.tcomcon,
             obcontacto_aut.contacto.tvalcon,
             obcontacto_aut.contacto.cobliga,
             obcontacto_aut.contacto.ttipcon,
             obcontacto_aut.contacto.cdomici
        FROM per_contactos_aut
       WHERE sperson = psperson
         AND cagente = pcagente
         AND cmodcon = pcmodcon
         AND norden = pnorden;

      /* vnumerr := f_get_contacto(psperson, pcagente,pcmodcon, obcontacto_aut.contacto, mensajes, 'POL');*/
      obcontacto_aut.testado := pac_md_listvalores.f_getdescripvalores(800072,
                                                                       obcontacto_aut.cestado,
                                                                       mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contacto_aut;

   /**************************************************************
   Funcio para obtener la lista de autorizaciones de direcciones
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   param in pcdomic : codigo del domicilio
   param in pnorden : numero de orden
   param out obdireccion_aut
   param out mensajes
   return codigo error : 0 - ok ,codigo de error
   BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_direccion_aut(psperson        IN NUMBER,
                                pcagente        IN NUMBER,
                                pcdomici        IN NUMBER,
                                pnorden         IN NUMBER,
                                obdireccion_aut OUT ob_iax_direcciones_aut,
                                mensajes        IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente:' || pcagente || ' pcdomici:' ||
                                pcdomici;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_GET_DIRECCION_AUT';
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         pcdomici IS NULL OR
         pnorden IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF obdireccion_aut IS NULL
      THEN
         obdireccion_aut           := ob_iax_direcciones_aut();
         obdireccion_aut.direccion := ob_iax_direcciones();
      END IF;

      SELECT d.norden,
             d.cusumod,
             d.fusumod,
             d.fbaja,
             d.cusuaut,
             d.fautoriz,
             d.cestado,
             d.tobserva,
             d.cdomici,
             d.tdomici,
             d.cpostal,
             p.cprovin,
             p.tprovin,
             d.cpoblac,
             f_despoblac2(cpoblac, p.cprovin) tpoblac,
             p.cpais,
             ff_despais(p.cpais, pac_md_common.f_get_cxtidioma()) tpais,
             d.ctipdir,
             ff_desvalorfijo(191, pac_md_common.f_get_cxtidioma(), d.ctipdir) ttipdir,
             d.csiglas,
             d.tnomvia,
             d.nnumvia,
             d.tcomple,
             d.cviavp,
             d.clitvp,
             d.cbisvp,
             d.corvp,
             d.nviaadco,
             d.clitco,
             d.corco,
             d.nplacaco,
             d.cor2co,
             d.cdet1ia,
             d.tnum1ia,
             d.cdet2ia,
             d.tnum2ia,
             d.cdet3ia,
             d.tnum3ia
        INTO obdireccion_aut.norden,
             obdireccion_aut.cusumod,
             obdireccion_aut.fusumod,
             obdireccion_aut.fbaja,
             obdireccion_aut.cusuaut,
             obdireccion_aut.fautoriz,
             obdireccion_aut.cestado,
             obdireccion_aut.tobserva,
             obdireccion_aut.direccion.cdomici,
             obdireccion_aut.direccion.tdomici,
             obdireccion_aut.direccion.cpostal,
             obdireccion_aut.direccion.cprovin,
             obdireccion_aut.direccion.tprovin,
             obdireccion_aut.direccion.cpoblac,
             obdireccion_aut.direccion.tpoblac,
             obdireccion_aut.direccion.cpais,
             obdireccion_aut.direccion.tpais,
             obdireccion_aut.direccion.ctipdir,
             obdireccion_aut.direccion.ttipdir,
             obdireccion_aut.direccion.csiglas,
             obdireccion_aut.direccion.tnomvia,
             obdireccion_aut.direccion.nnumvia,
             obdireccion_aut.direccion.tcomple,
             obdireccion_aut.direccion.cviavp,
             obdireccion_aut.direccion.clitvp,
             obdireccion_aut.direccion.cbisvp,
             obdireccion_aut.direccion.corvp,
             obdireccion_aut.direccion.nviaadco,
             obdireccion_aut.direccion.clitco,
             obdireccion_aut.direccion.corco,
             obdireccion_aut.direccion.nplacaco,
             obdireccion_aut.direccion.cor2co,
             obdireccion_aut.direccion.cdet1ia,
             obdireccion_aut.direccion.tnum1ia,
             obdireccion_aut.direccion.cdet2ia,
             obdireccion_aut.direccion.tnum2ia,
             obdireccion_aut.direccion.cdet3ia,
             obdireccion_aut.direccion.tnum3ia
        FROM per_direcciones_aut d,
             provincias          p
       WHERE d.sperson = psperson
         AND p.cprovin(+) = d.cprovin
         AND d.cagente = pcagente
         AND d.cdomici = pcdomici
         AND d.norden = pnorden;

      IF obdireccion_aut.direccion.csiglas IS NOT NULL
      THEN
         SELECT tsiglas
           INTO obdireccion_aut.direccion.tsiglas
           FROM tipos_via
          WHERE csiglas = obdireccion_aut.direccion.csiglas;
      END IF;

      /*vnumerr := f_get_direccion(psperson,pcdomici,obdireccion_aut.DIRECCION,mensajes ,'POL');*/
      obdireccion_aut.testado := pac_md_listvalores.f_getdescripvalores(800072,
                                                                        obdireccion_aut.cestado,
                                                                        mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_direccion_aut;

   /**************************************************************
   Funcio para guardar los contactos
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   param in pcmodcon : codigo del contacto
   param in pnorden : numero de orden
   param in pcestado : Codigo del estado
   param in ptobserva : Observaciones
   param out mensajes
   return codigo error : 0 - ok ,codigo de error
   BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_contacto_aut(psperson  IN NUMBER,
                               pcagente  IN NUMBER,
                               pcmodcon  IN NUMBER,
                               ptcomcon  IN VARCHAR2,
                               pnorden   IN NUMBER,
                               pcestado  IN NUMBER,
                               ptobserva IN VARCHAR2,
                               mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                      ' pcagente:' || pcagente ||
                                      ' pcmodcon:' || pcmodcon ||
                                      ' pnorden:' || pnorden ||
                                      ' pcestado:' || pcestado ||
                                      ' ptobserva:' || ptobserva;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.F_SET_CONTACTO_AUT';
      errores        t_ob_error;
      obcontacto_aut ob_iax_contactos_aut;
      vcmodcon       NUMBER;
   BEGIN
      IF psperson IS NULL OR
         pcagente IS NULL OR
         pcmodcon IS NULL OR
         pnorden IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vcmodcon := pcmodcon;
      vnumerr  := pac_persona.f_set_contacto_aut(psperson, pcagente,
                                                 pcmodcon, pnorden, pcestado,
                                                 ptobserva,
                                                 pac_md_common.f_get_cxtidioma,
                                                 errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF pcestado = 2
      THEN
         vnumerr := f_get_contacto_aut(psperson, pcagente, pcmodcon, pnorden,
                                       obcontacto_aut, mensajes);

         IF obcontacto_aut.fbaja IS NOT NULL
         THEN
            /*vnumerr :=  pac_persona.F_DEL_CONTACTO(psperson,pcmodcon,pcagente,mensajes,'POL');*/
            pac_persona.p_del_contacto(psperson, pcmodcon, errores,
                                       pac_md_common.f_get_cxtidioma(),
                                       'POL');
            mensajes := f_traspasar_errores_mensajes(errores);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         ELSE
            /*0026057/0137564: INICIO - DCT - 12/02/2013. Añadir obcontacto_aut.contacto.cdomici*/
            vnumerr := pac_persona.f_set_contacto(psperson, pcagente,
                                                  obcontacto_aut.contacto.ctipcon,
                                                  ptcomcon, vcmodcon,
                                                  obcontacto_aut.contacto.tvalcon,
                                                  obcontacto_aut.contacto.cdomici,
                                                  NULL, errores, 'POL');
            /*0026057/0137564: FIN - DCT - 12/02/2013*/
            mensajes := f_traspasar_errores_mensajes(errores);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contacto_aut;

   /**************************************************************
   Funcio para guardar las direcciones
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   param in pcdomici: codigo de la direccion
   param in pnorden : numero de orden
   param in pcestado : Codigo del estado
   param in ptobserva : Observaciones
   param out mensajes
   return codigo error : 0 - ok ,codigo de error
   BUG 18949/103391 - 03/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_direccion_aut(psperson  IN NUMBER,
                                pcagente  IN NUMBER,
                                pcdomici  IN NUMBER,
                                pnorden   IN NUMBER,
                                pcestado  IN NUMBER,
                                ptobserva IN VARCHAR2,
                                mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr         NUMBER(8) := 0;
      vpasexec        NUMBER(8) := 1;
      vparam          VARCHAR2(500) := 'parametros - psperson: ' ||
                                       psperson || ' pcagente:' || pcagente ||
                                       ' pcdomici:' || pcdomici ||
                                       ' pnorden:' || pnorden ||
                                       ' pcestado:' || pcestado ||
                                       ' ptobserva:' || ptobserva;
      vobject         VARCHAR2(200) := 'PAC_MD_PERSONA.F_SET_DIRECCION_AUT';
      errores         t_ob_error;
      obdireccion_aut ob_iax_direcciones_aut;
      vcdomici        NUMBER;
   BEGIN
      vcdomici := pcdomici;

      IF psperson IS NULL OR
         pcagente IS NULL OR
         pcdomici IS NULL OR
         pnorden IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr  := pac_persona.f_set_direccion_aut(psperson, pcagente,
                                                  pcdomici, pnorden, pcestado,
                                                  ptobserva,
                                                  pac_md_common.f_get_cxtidioma,
                                                  errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF pcestado = 2
      THEN
         vnumerr := f_get_direccion_aut(psperson, pcagente, pcdomici,
                                        pnorden, obdireccion_aut, mensajes);

         IF obdireccion_aut.fbaja IS NOT NULL
         THEN
            pac_persona.p_del_direccion(psperson, pcdomici,
                                        pac_md_common.f_get_cxtidioma(),
                                        errores, 'POL');
            mensajes := f_traspasar_errores_mensajes(errores);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RETURN 1;
               END IF;
            END IF;
         ELSE
            vnumerr  := pac_persona.f_set_direccion(psperson, pcagente,
                                                    vcdomici,
                                                    obdireccion_aut.direccion.ctipdir,
                                                    obdireccion_aut.direccion.csiglas,
                                                    obdireccion_aut.direccion.tnomvia,
                                                    obdireccion_aut.direccion.nnumvia,
                                                    obdireccion_aut.direccion.tcomple,
                                                    obdireccion_aut.direccion.tdomici,
                                                    obdireccion_aut.direccion.cpostal,
                                                    obdireccion_aut.direccion.cpoblac,
                                                    obdireccion_aut.direccion.cprovin,
                                                    f_user(), f_sysdate(),
                                                    pac_md_common.f_get_cxtidioma(),
                                                    errores, 'POL',
                                                    obdireccion_aut.direccion.cviavp,
                                                    obdireccion_aut.direccion.clitvp,
                                                    obdireccion_aut.direccion.cbisvp,
                                                    obdireccion_aut.direccion.corvp,
                                                    obdireccion_aut.direccion.nviaadco,
                                                    obdireccion_aut.direccion.clitco,
                                                    obdireccion_aut.direccion.corco,
                                                    obdireccion_aut.direccion.nplacaco,
                                                    obdireccion_aut.direccion.cor2co,
                                                    obdireccion_aut.direccion.cdet1ia,
                                                    obdireccion_aut.direccion.tnum1ia,
                                                    obdireccion_aut.direccion.cdet2ia,
                                                    obdireccion_aut.direccion.tnum2ia,
                                                    obdireccion_aut.direccion.cdet3ia,
                                                    obdireccion_aut.direccion.tnum3ia,
                                                    obdireccion_aut.direccion.localidad,
																	 NULL -- BUG CONF-441 - 14/12/2016 - JAEG
                                                    /* Bug 24780/130907 - 05/12/2012 - AMC*/);
            mensajes := f_traspasar_errores_mensajes(errores);

            IF mensajes IS NOT NULL
            THEN
               IF mensajes.count > 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_direccion_aut;

   /*INI BUG 22642--ETM --24/07/2012*/
   /**************************************************************
      FUNCION f_get_inquiaval
      Obtiene la select con los inquilinos avalistas
        param in psperson   : Codi sperson
         param in pctipfig    : Codi id de avalista o inqui(1 inquilino , 2 Avalista )
        param out psquery   : Select
        return              : 0.- OK, 1.- KO
   **************************************************************/
   FUNCTION f_get_inquiaval(psperson IN NUMBER,
                            pctipfig IN NUMBER, /*
                                                                                       1     inquilino
                                                                                       ,     2
                                                                                       Avalista Desde
                                                                                       java  le
                                                                                       pasamos el
                                                                                    tipo*/
                            pcur     OUT SYS_REFCURSOR,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(200) := 'psperson=' || psperson || ' pctipfig=' ||
                                pctipfig;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_inquiaval';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL OR
         pctipfig IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_inquiaval(psperson, pctipfig,
                                             pac_md_common.f_get_cxtidioma,
                                             squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_inquiaval;

   /**************************************************************
     FUNCION f_get_gescobro
     Obtiene la select con los gestores de cobro
       param in psperson   : Codi sperson
       param out pcur   : cursor con los datos de lo gestores
        param out mensajes
       return              : 0.- OK, 1.- KO
   **************************************************************/
   FUNCTION f_get_gescobro(psperson IN NUMBER,
                           pcur     OUT SYS_REFCURSOR,
                           mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(200) := 'psperson=' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_gescobro';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_persona.f_get_gescobro(psperson,
                                            pac_md_common.f_get_cxtidioma,
                                            squery);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      pcur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_gescobro;

   /*FIN BUG 22642--ETM --24/07/2012*/
   /*************************************************************************
   Funcion que recupera la informacion de la antiguedad de la persona
   return : cursor con el resultado
   *************************************************************************/
   /* Bug 25542 - APD - se crea la funcion*/
   FUNCTION f_get_antiguedad(psperson IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS
      cur      SYS_REFCURSOR;
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_antiguedad';
      squery   VARCHAR2(3000);
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*Inici Bug 25849 JDS 30-01-2013*/
      squery  := ' SELECT DISTINCT p.norden, d.cagrupa, d.tagrupa, p.fantiguedad, p.cestado, dv.tatribu testado, p.ffin,
	           TO_DATE(decode (p.ffin, null, null, p.ffin + (SELECT NVL(nduraci, 0) FROM codagrupa_antiguedad WHERE cagrupa = d.cagrupa))) f_fin_antiguedad
	       FROM per_antiguedad p, per_Detper pd, desagrupa_antiguedad d, detvalores dv
	       WHERE p.cagrupa = d.cagrupa
           AND d.cidioma =  ' ||
                 pac_md_common.f_get_cxtidioma || '  AND p.sperson =     ' ||
                 psperson || '
	       AND dv.cvalor = 1120
	       AND dv.catribu = p.cestado
	       AND dv.cidioma =  ' ||
                 pac_md_common.f_get_cxtidioma || '
	       AND p.sperson = pd.sperson AND pd.cagente in ( select cagente from agentes_agente)
	       AND p.norden IN(SELECT MAX(norden) FROM per_antiguedad pp WHERE pp.sperson = ' ||
                 psperson || ' and pp.cagrupa = p.cagrupa )
	       ORDER BY 1,3';
      vnumerr := pac_md_log.f_log_consultas(squery,
                                            'PAC_MD_PERSONA.f_get_antiguedad',
                                            1, 1, mensajes);
      /*Fi Bug 25849 JDS 30-01-2013*/
      /*         'SELECT c.cagrupa, d.tagrupa, c.norden, p.fantiguedad, p.cestado, p.sseguro_ini, p.ffin, p.sseguro_fin'*/
      /*         || ' FROM per_antiguedad p, codagrupa_antiguedad c, desagrupa_antiguedad d'*/
      /*         || ' WHERE p.cagrupa = c.cagrupa' || ' AND c.cagrupa = d.cagrupa'*/
      /*         || ' AND d.cidioma = ' || pac_md_common.f_get_cxtidioma || ' AND p.sperson = '*/
      /*         || psperson || ' ORDER BY 1,3';*/
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN cur;
   END f_get_antiguedad;

   /*************************************************************
    funcion que devuelve los conductores
   **************************************************************/
   FUNCTION f_get_conductores(psperson IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      /*      vnumerr        NUMBER;*/
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_conductores';
      cur      SYS_REFCURSOR;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      OPEN cur FOR
         SELECT s.sseguro,
                f_formatopol(npoliza, ncertif, 1) poliza,
                s.cramo,
                s.cmodali,
                f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1,
                                pac_md_common.f_get_cxtidioma) tproducto,
                s.fanulac fanulac,
                s.cagente cagente,
                f_desagente_t(s.cagente) tagente,
                a.npuntos npuntos,
                a.cprincipal cprincipal,
                a.fcarnet fcarnet
           FROM seguros        s,
                autconductores a
          WHERE s.sseguro = a.sseguro
            AND a.sperson = psperson
            AND s.cagente IN (SELECT cagente FROM agentes_agente_pol)
            AND a.nmovimi IN (SELECT MAX(nmovimi)
                                FROM autconductores a2
                               WHERE a2.sseguro = a.sseguro
                                 AND a2.sperson = a.sperson);

      RETURN cur;
      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_conductores;

   /*************************************************************************
     funcion que retorna la informacion de paises, provincias y poblaciones
     con un numero de codigo postal en comun.
     param pcpostal : codigo postal relacionado
     param mensajes : mensajes registrados en el proceso
     return : cursor con el resultado
     Bug 33977 mnustes
   *************************************************************************/
   FUNCTION f_get_provinpoblapais(pcpostal IN codpostal.cpostal%TYPE,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      /**/
      vobject  VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_provinpoblapais';
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - pcpostal: ' || pcpostal;
      srccur   SYS_REFCURSOR;
      /**/
   BEGIN
      /**/
      IF pcpostal IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /**/
      OPEN srccur FOR
         SELECT dp.cpais   scpais,
                dp.tpais   stpais,
                p.cprovin  scprovin,
                p.tprovin  stprovin,
                pb.cpoblac scpoblac,
                pb.tpoblac stpoblac
           FROM despaises   dp,
                provincias  p,
                poblaciones pb,
                codpostal   cp
          WHERE dp.cpais = p.cpais
            AND dp.cidioma = pac_md_common.f_get_cxtidioma()
            AND p.cprovin = pb.cprovin
            AND cp.cpostal = pcpostal
            AND p.cprovin = cp.cprovin
            AND pb.cpoblac = cp.cpoblac
          ORDER BY dp.cpais,
                   p.cprovin,
                   pb.cpoblac;

      RETURN srccur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN srccur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN srccur;
   END f_get_provinpoblapais;

   /*************************************************************************
     funcion que retorna la informacion de codigo postal por medio de los
     parametros pais, provincia, poblacion.
     param pcpais : codigo de pais
     param pcprovin : codigo de provincia
     param pcpoblac : codigo de poblacion
     param mensajes : mensajes registrados en el proceso
     return : cursor con el resultado
     Bug 33977 mnustes
   *************************************************************************/
   FUNCTION f_get_codpostal(pcpais   IN despaises.cpais%TYPE,
                            pcprovin IN provincias.cprovin%TYPE,
                            pcpoblac IN poblaciones.cpoblac%TYPE,
                            mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      /**/
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_codpostal';
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - pcpais: ' || pcpais ||
                                 ' pcprovin: ' || pcprovin || ' pcpoblac: ' ||
                                 pcpoblac;
      srccur   SYS_REFCURSOR;
      /**/
   BEGIN
      /**/
      vpasexec := 2;

      /**/
      OPEN srccur FOR
         SELECT cp.cpostal rccpostal,
                p.cpais    rccpais,
                dp.tpais   rctpais,
                p.cprovin  rccprovin,
                p.tprovin  rctprovin,
                pb.cpoblac rccpoblac,
                pb.tpoblac rctpoblac
           FROM codpostal   cp,
                provincias  p,
                poblaciones pb,
                despaises   dp
          WHERE cp.cprovin = p.cprovin
            AND cp.cpoblac = pb.cpoblac
            AND p.cpais = NVL(pcpais, p.cpais)
            AND pb.cprovin = p.cprovin
            AND p.cprovin = NVL(pcprovin, p.cprovin)
            AND pb.cpoblac = NVL(pcpoblac, pb.cpoblac)
            AND dp.cpais = p.cpais
            AND dp.cidioma = pac_md_common.f_get_cxtidioma()
          ORDER BY dp.cpais,
                   p.cprovin,
                   pb.cpoblac;

      RETURN srccur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN srccur;
   END f_get_codpostal;

   /*************************************************************
    funcion que devuelve CODISOTEL en la tabla paises
   **************************************************************/
   FUNCTION f_get_prefijospaises(mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      /**/
      vpasexec NUMBER := 1;
      vparam   VARCHAR2(1000) := 'parametros';
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_prefijospaises';
      v_cur    SYS_REFCURSOR;
      vsquery  VARCHAR2(4000);
      vnumerr  NUMBER := 0;
      /**/
   BEGIN
      /**/
      /*Inicio Mantis 34989/210019 - BLA - DD25/MM05/2015.*/
      vsquery := 'SELECT   d.codisotel, d.cpais, dd.tpais, d.codisoiban ' ||
                 'FROM paises d, despaises dd ' ||
                 'WHERE codisotel IS NOT NULL ' ||
                 'AND d.cpais = dd.cpais ' ||
                 'AND dd.cidioma = pac_md_common.f_get_cxtidioma() ' ||
                 'ORDER BY tpais';
      /* Fin Mantis 34989/210019 - BLA - DD14/MM07/2015.*/
      /**/
      vnumerr := pac_md_log.f_log_consultas(vsquery,
                                            'PAC_MD_PERSONA.f_get_prefijospaises',
                                            1, 1, mensajes);
      /**/
      v_cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      /**/
      RETURN v_cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);

         /**/
         IF v_cur%ISOPEN
         THEN
            CLOSE v_cur;
         END IF;

         /**/
         RETURN NULL;
   END f_get_prefijospaises;

   FUNCTION f_get_hispersonas_rel(psperson       IN NUMBER,
                                  pcagente       IN NUMBER,
                                  ptablas        IN VARCHAR2,
                                  ptpersonas_rel OUT t_iax_personas_rel,
                                  mensajes       IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' pcagente = ' || pcagente ||
                                 ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_hispersonas_rel';

      CURSOR cur_perrel IS
         SELECT sperson,
                cagente,
                sperson_rel
           FROM (SELECT sperson,
                        cagente,
                        sperson_rel
                   FROM hisper_personas_rel
                  WHERE sperson = psperson
                    AND cagente = pcagente
                    AND ptablas != 'EST');
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ptpersonas_rel := t_iax_personas_rel();

      FOR reg IN cur_perrel
      LOOP
         ptpersonas_rel.extend;
         ptpersonas_rel(ptpersonas_rel.last) := ob_iax_personas_rel();
         vnumerr := f_get_hispersona_rel(psperson, pcagente, reg.sperson_rel,
                                         ptpersonas_rel(ptpersonas_rel.last),
                                         mensajes, ptablas);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_hispersonas_rel;

   FUNCTION f_get_hispersona_rel(psperson       IN NUMBER,
                                 pcagente       IN NUMBER,
                                 psperson_rel   IN NUMBER,
                                 pobpersona_rel OUT ob_iax_personas_rel,
                                 mensajes       IN OUT t_iax_mensajes,
                                 ptablas        IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                                ' pcagente = ' || pcagente || ' ptablas = ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_hispersona_rel';
      dummy    NUMBER;

      CURSOR c1 IS
         SELECT sperson,
                cagente,
                sperson_rel,
                ctipper_rel,
                cusuari,
                fmovimi,
                pparticipacion,
                islider,
                fusumod
           FROM hisper_personas_rel pr
          WHERE pr.sperson = psperson
            AND pr.cagente = pcagente
            AND pr.sperson_rel = psperson_rel
            AND ptablas <> 'EST';
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pobpersona_rel := ob_iax_personas_rel();

      FOR rc IN c1
      LOOP
         pobpersona_rel.sperson        := rc.sperson;
         pobpersona_rel.cagente        := rc.cagente;
         pobpersona_rel.sperson_rel    := rc.sperson_rel;
         pobpersona_rel.ctipper_rel    := rc.ctipper_rel;
         pobpersona_rel.ttipper_rel    := ff_desvalorfijo(1037,
                                                          pac_md_common.f_get_cxtidioma(),
                                                          rc.ctipper_rel);
         pobpersona_rel.cusuari        := rc.cusuari;
         pobpersona_rel.fmovimi        := rc.fmovimi;
         pobpersona_rel.pparticipacion := rc.pparticipacion;
         pobpersona_rel.islider        := rc.islider; /* BUG 0030525 - FAL - 01/04/2014*/
         pobpersona_rel.fusumod        := rc.fusumod;

         BEGIN
            SELECT tvalcon
              INTO pobpersona_rel.telefono
              FROM per_contactos
             WHERE sperson = rc.sperson_rel
               AND cagente = rc.cagente
               AND ctipcon = 1
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM per_contactos
                               WHERE sperson = rc.sperson_rel
                                 AND cagente = rc.cagente
                                 AND ctipcon = 1);
         EXCEPTION
            WHEN OTHERS THEN
               pobpersona_rel.telefono := NULL;
         END;

         BEGIN
            SELECT tvalcon
              INTO pobpersona_rel.mail
              FROM per_contactos
             WHERE sperson = rc.sperson_rel
               AND cagente = rc.cagente
               AND ctipcon = 3
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM per_contactos
                               WHERE sperson = rc.sperson_rel
                                 AND cagente = rc.cagente
                                 AND ctipcon = 3);
         EXCEPTION
            WHEN OTHERS THEN
               pobpersona_rel.mail := NULL;
         END;

         BEGIN
            SELECT tdomici
              INTO pobpersona_rel.direccion
              FROM per_direcciones pd
             WHERE pd.sperson = rc.sperson_rel
               AND pd.cagente = rc.cagente
               AND pd.cdomici =
                   (SELECT MIN(cdomici)
                      FROM per_direcciones pd2
                     WHERE pd2.sperson = pd.sperson
                       AND pd2.cagente = pd.cagente);
         EXCEPTION
            WHEN OTHERS THEN
               pobpersona_rel.direccion := NULL;
         END;

         BEGIN
            SELECT pp.nnumide,
                   f_nombre(pp.sperson, 1, pd.cagente) tnombre
              INTO pobpersona_rel.nnumide,
                   pobpersona_rel.tnombre
              FROM per_detper   pd,
                   per_personas pp
             WHERE pp.sperson = rc.sperson_rel
               AND pd.sperson = pp.sperson
               AND pd.cagente = rc.cagente;
         EXCEPTION
            WHEN OTHERS THEN
               pobpersona_rel.nnumide := NULL;
               pobpersona_rel.tnombre := NULL;
         END;
      END LOOP;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_hispersona_rel;

   FUNCTION f_del_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_del_datsarlatf';
      cont           NUMBER;
   BEGIN
      vnumerr := pac_persona.f_del_datsarlatf(pssarlaft, pfradica, psperson, mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_datsarlatf;

   FUNCTION f_get_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_get_datsarlatf';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_persona.f_get_datsarlatf(pssarlaft, pfradica, psperson, mensajes);
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
      pemp_tmailrepl	IN VARCHAR2  DEFAULT NULL,
      pemp_tdirsrepl IN VARCHAR2 DEFAULT NULL,
      pemp_cciurrepl IN NUMBER DEFAULT NULL,
      pemp_tciurrepl IN VARCHAR2,
      pemp_cdeprrepl IN NUMBER DEFAULT NULL,
      pemp_tdeprrepl IN VARCHAR2,
      pemp_cpairrepl IN NUMBER DEFAULT NULL,
      pemp_tpairrepl IN VARCHAR2,
      pemp_ttelrepl	IN NUMBER DEFAULT NULL,
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
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_set_datsarlatf';
      cont           NUMBER;
   BEGIN
      vnumerr := pac_persona.f_set_datsarlatf(pssarlaft, pfradica, psperson, pfdiligencia,
                                              pcauttradat, pcrutfcc, pcestconf, pfconfir,
                                              pcvinculacion, ptvinculacion, per_cdeptosol, per_tdeptosol, per_cciusol, per_tciusol,
                                              pcvintomase, ptvintomase,
                                              pcvintomben, ptvintombem, pcvinaseben,
                                              ptvinasebem, pcactippal, ppersectorppal, pnciiuppal, ptcciiuppal, ppertipoactivppal,
                                              ptocupacion, ptcargo, ptempresa, ptdirempresa, ppercdeptoofic, ppertdeptoofic, ppercciuofic, ppertciuofic,
                                              pttelempresa, pcactisec, pnciiusec, ptcciiusec, ptdirsec,
                                              pttelsec, ptprodservcom, piingresos, piactivos,
                                              pipatrimonio, piegresos, pipasivos,
                                              piotroingreso, ptconcotring, pcmanrecpub,
                                              pcpodpub, pcrecpub, pcvinperpub, ptvinperpub,
                                              pcdectribext, ptdectribext, ptorigfond,
                                              pctraxmodext, pttraxmodext, pcprodfinext,
                                              pcctamodext, ptotrasoper, pcreclindseg,
                                              ptciudadsuc, ptpaisuc, ptdepatamentosuc, ptciudad, ptdepatamento, ptpais,
                                              ptlugarexpedidoc, presociedad, ptnacionali2,
                                              pngradopod, pngozrec, pnparticipa, pnvinculo,
                                              pntipdoc, pfexpedicdoc, pfnacimiento, pnrazonso,
                                              ptnit, ptdv, ptoficinapri, pttelefono, ptfax,
                                              ptsucursal, pttelefonosuc, ptfaxsuc, pctipoemp,
                                              ptcualtemp, ptsector, pcciiu, ptactiaca, ptmailjurid,
                                              ptrepresentanle, ptsegape, ptnombres, ptnumdoc,
                                              ptlugnaci, ptnacionali1, ptindiquevin,
                                              pper_papellido, pper_sapellido, pper_nombres,
                                              pper_tipdocument, pper_document,
                                              pper_fexpedicion, pper_lugexpedicion,
                                              pper_fnacimi, pper_lugnacimi, pper_nacion1,
                                              pper_direreci, pper_pais, pper_ciudad,
                                              pper_departament, pper_email, pper_telefono,
                                              pper_celular, pnrecpub, ptpresetreclamaci,
                                              pper_tlugexpedicion, pper_tlugnacimi,
                                              pper_tnacion1, pper_tnacion2, pper_tpais,
                                              pper_tdepartament, pper_tciudad, pemptpais,
                                              pemptdepatamento, pemptciudad, pemptpaisuc,
                                              pemptdepatamentosuc, pemptciudadsuc,
                                              pemptlugnaci, pemptnacionali1, pemptnacionali2,
                                              pcsujetooblifacion, ptindiqueoblig, pper_paisexpedicion,
                                              pper_tpaisexpedicion, pper_depexpedicion,
                                              pper_tdepexpedicion, pper_paislugnacimi,
                                              pper_tpaislugnacimi, pper_deplugnacimi,
                                              pper_tdeplugnacimi, pemp_paisexpedicion,
                                              pemp_tpaisexpedicion, pemp_depexpedicion,
                                              pemp_tdepexpedicion, pemp_paislugnacimi,
                                              pemp_tpaislugnacimi, pemp_deplugnacimi,
                                              pemp_tdeplugnacimi, pemp_lugnacimi,
                                              pemp_tlugnacimi, pemp_fexpedicion,
                                              pemp_lugexpedicion, pemp_tlugexpedicion,
                                              pper_nacion2, pper_pcciusol, pper_pcsucursal,
                                              pper_pctipsol , pper_pcsector , pper_pctipact , pper_pcciuofc ,
                                              pper_pcdepofc , pemp_tmailrepl, pemp_tdirsrepl,
                                              pemp_cciurrepl, pemp_tciurrepl, pemp_cdeprrepl, pemp_tdeprrepl, pemp_cpairrepl, pemp_tpairrepl,
                                              pemp_ttelrepl	, pemp_tcelurepl, pcdeptoentrev, ptdeptoentrev, pcciuentrev, ptciuentrev,
                                              pfentrevista ,pthoraentrev ,ptagenentrev ,ptasesentrev ,
                                              ptobseentrev ,pcrestentrev ,ptobseconfir ,pthoraconfir ,ptemplconfir ,pcorigenfon,pcclausula1,pcclausula2, pcconfir, mensajes);  -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018 --IAXIS-3287 01/04/2019
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_datsarlatf;

   FUNCTION f_del_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_del_detsarlatf_dec';
      cont           NUMBER;
   BEGIN
      vnumerr := pac_persona.f_del_detsarlatf_dec(pndeclara, psperson, pssarlaft, mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_detsarlatf_dec;

   FUNCTION f_get_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_get_detsarlatf_dec';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_persona.f_get_detsarlatf_dec(pndeclara, psperson, pssarlaft, mensajes);
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
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_set_detsarlatf_dec';
      cont           NUMBER;
   BEGIN
      vnumerr := pac_persona.f_set_detsarlatf_dec(pndeclara, psperson, pssarlaft, pctipoid,
                                                  pcnumeroid, ptnombre, pcmanejarec,
                                                  pcejercepod, pcgozarec, pcdeclaraci,
                                                  pcdeclaracicual, mensajes);
      COMMIT;
      RETURN vnumerr;
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
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_del_detsarlatf_act';
      cont           NUMBER;
   BEGIN
      vnumerr := pac_persona.f_del_detsarlatf_act(pnactivi, psperson, pssarlaft, mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_detsarlatf_act;

   FUNCTION f_get_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_get_detsarlatf_act';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_persona.f_get_detsarlatf_act(pnactivi, psperson, pssarlaft, mensajes);
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
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_set_detsarlatf_act';
      cont           NUMBER;
   BEGIN
      vnumerr := pac_persona.f_set_detsarlatf_act(pnactivi, psperson, pssarlaft, pctipoprod,
                                                  pcidnumprod, ptentidad, pcmonto, pcciudad,
                                                  pcpais, pcmoneda, pscpais, pstdepb, ptdepb,
                                                  pscciudad, mensajes);
      COMMIT;
      RETURN vnumerr;
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
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_del_detsarlaft_rec';
      cont           NUMBER;
   BEGIN
      vnumerr := pac_persona.f_del_detsarlaft_rec(pnrecla, psperson, pssarlaft, mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_detsarlaft_rec;

   FUNCTION f_get_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_get_detsarlaft_rec';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_persona.f_get_detsarlaft_rec(pnrecla, psperson, pssarlaft, mensajes);
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
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_set_detsarlaft_rec';
      cont           NUMBER;
   BEGIN
      vnumerr := pac_persona.f_set_detsarlaft_rec(pnrecla, psperson, pssarlaft, pcanio,
                                                  pcramo, ptcompania, pcvalor, ptresultado,
                                                  mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_detsarlaft_rec;
   --INI BUG CONF-186  Fecha (22/08/2016) - HRE - proceso de marcas
   /*************************************************************************
    FUNCTION f_get_permarcas
    Permite obtener las marcas de una persona
    param in pcempres    : codigo de la empresa
    param in psperson    : codigo de la persona
    param out ppermarcas : objeto marcas
    ptablas in           : tablas defiitivas o est.
    param out mensajes   : mesajes de error
    return               : number
   *************************************************************************/
   FUNCTION f_get_permarcas(
      pcempres  IN NUMBER,
      psperson  IN NUMBER,
      permarcas OUT t_iax_permarcas,
      mensajes  IN OUT t_iax_mensajes,
      ptablas   IN VARCHAR2)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - pcempres: ' || pcempres || ' psperson:' || psperson ||
            'ptablas:'|| ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_permarcas';

      CURSOR cur_permarcas IS
         SELECT cempres, sperson, cmarca, nmovimi
           FROM per_agr_marcas a
          WHERE cempres = pcempres
            AND sperson = psperson
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM per_agr_marcas b
                            WHERE a.cempres= b.cempres
                              AND a.sperson = b.sperson
                              AND a.cmarca  = b.cmarca);
   BEGIN
      IF pcempres IS NULL OR psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      permarcas := t_iax_permarcas();

      FOR reg IN cur_permarcas LOOP
         permarcas.EXTEND;
         permarcas(permarcas.LAST) := ob_iax_permarcas();
         vnumerr := f_get_permarca(pcempres, psperson, reg.cmarca, reg.nmovimi,
                                   permarcas(permarcas.LAST),
                                    mensajes, ptablas);

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      IF permarcas IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9909289);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
         END IF;
      END IF;

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
   END f_get_permarcas;

   /*************************************************************************
    FUNCTION f_get_permarca
    Permite obtener la marca de una persona
    param in pcempres   : codigo de la empresa
    param in psperson   : codigo de la persona
    param in pnmovimi   : numero de movimiento
    param out ppermarca : objeto marcas
    param out mensajes  : mesajes de error
    return              : number
   *************************************************************************/
   FUNCTION f_get_permarca(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      pcmarca  IN VARCHAR2,
      pnmovimi IN NUMBER,
      permarca OUT ob_iax_permarcas,
      mensajes IN OUT t_iax_mensajes,
      ptablas  IN VARCHAR2)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - pcempres: ' || pcempres || ' psperson = ' || psperson
            ||' pcmarca:'||pcmarca||' pnmovimi:'||pnmovimi||' ptablas = ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_permarca';
      dummy          NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR psperson IS NULL
         OR pcmarca IS NULL
         THEN
         RAISE e_param_error;
      END IF;

      permarca := ob_iax_permarcas();

      SELECT a.cempres, a.sperson, a.cmarca, b.descripcion, a.nmovimi, a.ctipo, a.ctomador, a.cconsorcio, a.casegurado, a.ccodeudor,
             a.caccionista, a.cintermed, a.crepresen, a.capoderado, a.cpagador, a.cproveedor, a.cbenef,     --CJMR TCS-344 19/02/2019
             CASE
               WHEN a.ctomador = 0 AND a.cconsorcio = 0 AND a.casegurado = 0 AND a.ccodeudor = 0
                    AND a.caccionista = 0 AND a.cintermed = 0 AND a.crepresen = 0 AND a.capoderado = 0
                    AND a.cpagador = 0 AND a.cproveedor = 0  AND a.cbenef = 0                                          --CJMR TCS-344 19/02/2019
               THEN 0
               ELSE 1
             END cvalor, a.cuser, a.falta
        INTO permarca.cempres, permarca.sperson, permarca.cmarca, permarca.descripcion, permarca.nmovimi,
             permarca.ctipo, permarca.ctomador, permarca.cconsorcio, permarca.casegurado, permarca.ccodeudor,
             permarca.caccionista, permarca.cintermed, permarca.crepresen, permarca.capoderado, permarca.cpagador, permarca.cproveedor, permarca.cbenef, --CJMR TCS-344 19/02/2019
             permarca.cvalor, permarca.cuser, permarca.falta
        FROM per_agr_marcas a, agr_marcas b
       WHERE a.cempres = b.cempres
         AND a.cmarca  = b.cmarca
         AND a.cempres = pcempres
         AND a.sperson = psperson
         AND a.cmarca  = pcmarca
         AND ((pnmovimi IS NOT NULL AND a.nmovimi = pnmovimi)
               OR
              (pnmovimi IS NULL and a.nmovimi = (SELECT MAX(nmovimi)
                                                 FROM per_agr_marcas b
                                                WHERE a.cempres = b.cempres
                                                  AND a.sperson = b.sperson
                                                  AND a.cmarca = b.cmarca
                                               )
               )
             );

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;
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
   END f_get_permarca;
   --FIN BUG CONF-186  Fecha (22/08/2016) - HRE - proceso de marcas


    /*************************************************************************
    Nueva funcion que se encarga de recuperar registros de riesgo_financiero
    return              : 0 Ok. 1 Error
    Bug.: 18943
   ************************************************************************/
   FUNCTION f_get_riesgo_financiero(psperson  IN NUMBER,
                           ptablas   IN VARCHAR2,
                           ptriesgo_financiero OUT t_iax_riesgo_financiero,
                           mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_riesgo_financiero';

      CURSOR c1 IS
       SELECT his.SPERSON , his.nmovimi
        FROM RIE_HIS_RIESGO his
        WHERE his.sperson = psperson
        order by  his.nmovimi  desc;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ptriesgo_financiero := t_iax_riesgo_financiero();

      FOR reg IN c1
      LOOP
         ptriesgo_financiero.extend;
         ptriesgo_financiero(ptriesgo_financiero.last) := ob_iax_riesgo_financiero();

         vnumerr := f_get_riesgo(psperson, reg.nmovimi,
                               ptriesgo_financiero(ptriesgo_financiero.last), mensajes,
                                 ptablas);

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_riesgo_financiero;


FUNCTION f_get_riesgo(psperson  IN NUMBER,pnmovimi  IN NUMBER,
                          ptriesgo_financiero OUT ob_iax_riesgo_financiero,
                          mensajes  IN OUT t_iax_mensajes,
                          ptablas   IN VARCHAR2) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_riesgo';

    --INI - AXIS 2554 - 08/5/2019 - AABG - SE ADICIONAN LOS NUEVOS ATRIBUTOS DE LA TABLA AL CURSOR Y AL OBJETO IAX
      CURSOR c1 IS
         SELECT  his.NRIESGO,
        (select TDESRIESGO from RIE_NIVELRIESGO  where SNIVRIESGO = his.NRIESGO) DESRIESGO,
        his.MONTO ,
        his.FEFECTO,
        his.NPROBINCUMPLIMIENTO,
        his.SDESCRIPCION,
        his.NPUNTAJESCORE,
        his.SCALIFICACION,
        his.NINGMINIMOPROBABLE,
        his.NCUPOGARANTIZADO,
        his.STIPOPERSONA
        FROM RIE_HIS_RIESGO his
        WHERE his.sperson = psperson
        and his.nmovimi = pnmovimi ;
      
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ptriesgo_financiero := ob_iax_riesgo_financiero();
      FOR rc IN c1
      LOOP
         ptriesgo_financiero.sperson := psperson;
         ptriesgo_financiero.nriesgo := rc.nriesgo;
         ptriesgo_financiero.desriesgo := rc.desriesgo;
         ptriesgo_financiero.monto := rc.monto;
         ptriesgo_financiero.fefecto   := rc.fefecto;
         ptriesgo_financiero.nprobincumplimiento := rc.NPROBINCUMPLIMIENTO;
         ptriesgo_financiero.sdescripcion := rc.SDESCRIPCION;
         ptriesgo_financiero.npuntajescore := rc.NPUNTAJESCORE;
         ptriesgo_financiero.scalificacion := rc.SCALIFICACION;
         ptriesgo_financiero.ningminimoprobable := rc.NINGMINIMOPROBABLE;
         ptriesgo_financiero.ncupogarantizado := rc.NCUPOGARANTIZADO;
         ptriesgo_financiero.stipopersona := rc.STIPOPERSONA;

      END LOOP;
    --FIN - AXIS 2554 - 08/5/2019 - AABG - SE ADICIONAN LOS NUEVOS ATRIBUTOS DE LA TABLA AL CURSOR Y AL OBJETO IAX 
      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_riesgo;

   FUNCTION f_set_persona_cifin(vnnumide IN VARCHAR2,
                                mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr          NUMBER(8) := 0;
      vpasexec         NUMBER(8) := 1;
      vparam           VARCHAR2(2000) := 'parametros -   nnumide      :' || vnnumide;
      vobject          VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_persona_cifin';
      errores          t_ob_error;
      wnnumide         per_personas.nnumide%TYPE; /* BUG 26968/0155105 - FAL - 15/10/2013*/
      psperson         NUMBER;
      ctipide          NUMBER;
      existe_persona   NUMBER;
      existe_cifin     NUMBER;
      vsinterf         NUMBER;
      v_msg            VARCHAR2 (32000);
      v_msgout         VARCHAR2 (32000);
      vparser          xmlparser.parser;
      v_domdoc         xmldom.domdocument;
      verror           int_resultado.terror%TYPE;
      contador         NUMBER := 0;
      v_ctipper        NUMBER;
      v_ctipide        NUMBER;
      v_nnumide        VARCHAR2(12);
      v_sexo           NUMBER;
      v_nombre1_dq     VARCHAR2(250);
      v_nombre2_dq     VARCHAR2(250);
      v_apellido1_dq   VARCHAR2(250);
      v_apellido2_dq   VARCHAR2(250);
      v_pais           NUMBER;
      vtipo_id         NUMBER;
      v_cdocimi_1      NUMBER;
      v_cdocimi_2      NUMBER;
      v_cdocimi_3      NUMBER;
      v_con_tel_1      NUMBER;
      v_con_tel_2      NUMBER;
      v_con_tel_3      NUMBER;
      v_con_cel_1      NUMBER;
      v_con_cel_2      NUMBER;
      v_con_cel_3      NUMBER;
      v_con_cor_1      NUMBER;
      v_con_cor_2      NUMBER;
      v_con_cor_3      NUMBER;
      v_cod_ciiu       NUMBER;
      v_dir_1          VARCHAR2(250);
      v_cod_ciudad1_1  NUMBER;
      v_cod_depto1_1   NUMBER;
      v_dir_2          VARCHAR2(250);
      v_cod_ciudad2_2  NUMBER;
      v_cod_depto1_2   NUMBER;
      v_dir_3          VARCHAR2(250);
      v_cod_ciudad1_3  NUMBER;
      v_cod_depto1_3   NUMBER;
      v_tel_1          VARCHAR2(50);
      v_cel_1          VARCHAR2(50);
      v_correo_1       VARCHAR2(50);
      v_tel_2          VARCHAR2(50);
      v_cel_2          VARCHAR2(50);
      v_correo_2       VARCHAR2(50);
      v_tel_3          VARCHAR2(50);
      v_cel_3          VARCHAR2(50);
      v_correo_3       VARCHAR2(50);
      pcagente         number;


   BEGIN

      SELECT COUNT(*)
        INTO existe_persona
        FROM per_personas
       WHERE nnumide =vnnumide;

      IF existe_persona = 0 THEN

          SELECT COUNT(*)
            INTO existe_cifin
            FROM cifin_intermedio
           WHERE no_id = vnnumide;

          IF existe_cifin = 0 THEN

             contador := 0;

             FOR v_ctipper IN 1..2 LOOP

                 pac_int_online.p_inicializar_sinterf;
                 vsinterf := pac_int_online.f_obtener_sinterf;
                 v_msg := '<?xml version="1.0"?>
                                 <cifin_out>
                                   <sinterf>'||vsinterf||'</sinterf>
                                   <cempres>'||pac_md_common.f_get_cxtempresa||'</cempres>
                                   <codigoInformacion>'||pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'CIFIN_CODINFO')||'</codigoInformacion>
                                   <motivoConsulta>'||pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'CIFIN_MOTIVO')||'</motivoConsulta>
                                   <numeroIdentificacion>'||vnnumide||'</numeroIdentificacion>
                                   <tipoIdentificacion>'||v_ctipper||'</tipoIdentificacion>
                                 </cifin_out> ';

                 vpasexec := 4;

                 INSERT INTO int_mensajes (sinterf,cinterf,finterf,tmenout,tmenin )
                        VALUES(vsinterf,'I070',f_sysdate,v_msg,NULL);

                 COMMIT;

                 pac_int_online.peticion_host(pemp      => pac_md_common.f_get_cxtempresa,
                                              p_tipoint => 'I070',
                                              p_msg     => v_msg,
                                              p_msgout  => v_msgout);
                 parsear (v_msgout, vparser);
                 v_domdoc := xmlparser.getdocument (vparser);
                 verror := NVL(pac_xml.buscarnodotexto (v_domdoc, 'error'),0);

                 IF verror <> 0 THEN
                     contador := contador + 1;
                 END IF;
             END LOOP;

          END IF;

          IF contador = 2 THEN
             RAISE no_data_found;
          END IF;

          SELECT DECODE(genero, 'HOMBRE', 1, 2) sexo,
                 nombre1_dq,
                 nombre2_dq,
                 apellido1_dq,
                 apellido2_dq,
                 170 pais,
                 tipo_id,
                 codigo_ciiu,
                 direccion_1,
                 codigo_ciudad1_1,
                 codigo_depto1_1,
                 direccion_2,
                 codigo_ciudad2_2,
                 codigo_depto1_2,
                 direccion_3,
                 codigo_ciudad1_3,
                 codigo_depto1_3,
                 telefono_1,
                 celular_1,
                 correo_1,
                 telefono_2,
                 celular_2,
                 correo_3,
                 telefono_3,
                 celular_3,
                 correo_3
            INTO v_sexo,
                 v_nombre1_dq,
                 v_nombre2_dq,
                 v_apellido1_dq,
                 v_apellido2_dq,
                 v_pais,
                 vtipo_id,
                 v_cod_ciiu,
                 v_dir_1,
                 v_cod_ciudad1_1,
                 v_cod_depto1_1,
                 v_dir_2,
                 v_cod_ciudad2_2,
                 v_cod_depto1_2,
                 v_dir_3,
                 v_cod_ciudad1_3,
                 v_cod_depto1_3,
                 v_tel_1,
                 v_cel_1,
                 v_correo_1,
                 v_tel_2,
                 v_cel_3,
                 v_correo_2,
                 v_tel_3,
                 v_cel_3,
                 v_correo_3
            FROM cifin_intermedio c
           WHERE no_id = vnnumide;

          IF vtipo_id IN (1,2,3,4,5,9,10) THEN

              IF vtipo_id = 1 THEN
                ctipide := 36;
              ELSIF vtipo_id = 2 THEN
                ctipide := 37;
              ELSIF vtipo_id = 3 THEN
                ctipide := 33;
              ELSIF vtipo_id = 4 THEN
                ctipide := 34;
              ELSIF vtipo_id = 5 THEN
                ctipide := 24;
              ELSIF vtipo_id = 9 THEN
                ctipide := 35;
              ELSIF vtipo_id = 10 THEN
                ctipide := 44;
              END IF;

              pac_persona.p_validapersona(psperson    => psperson,                       pidioma_usu => pac_md_common.f_get_cxtidioma(),
                                          ctipper     => vtipo_id,                       ctipide     => ctipide,
                                          nnumide     => vnnumide,                       csexper     => v_sexo,
                                          fnacimi     => NULL,                           psnip       => NULL,
                                          cestper     => 1,                              fjubila     => NULL,
                                          cmutualista => NULL,                           fdefunc     => NULL,
                                          nordide     => NULL,                           cidioma     => pac_md_common.f_get_cxtidioma(),
                                          tapelli1    => v_apellido1_dq,                 tapelli2    => v_apellido2_dq,
                                          tnombre     => v_nombre1_dq,                   tsiglas     => NULL,
                                          cprofes     => NULL,                           cestciv     => NULL,
                                          cpais       => v_pais,                         ptablas     => 'POL',
                                          pcempres    => pac_md_common.f_get_cxtempresa, ptnombre1   => v_nombre1_dq,
                                          ptnombre2   => v_nombre2_dq,                   errores     => errores,
                                          pcocupacion => NULL);

              mensajes := f_traspasar_errores_mensajes(errores);

              IF mensajes IS NOT NULL
              THEN
                 IF mensajes.count > 0
                 THEN
                    RETURN 1;
                 END IF;
              END IF;
              pcagente  := pac_md_common.f_get_cxtagente();
              errores  := pac_persona.f_set_persona(pidioma_usu  => pac_md_common.f_get_cxtidioma(),
                                                    psseguro     => NULL,           psperson     => psperson,
                                                    pspereal     => NULL,           pcagente     => pcagente,
                                                    pctipper     => vtipo_id,       pctipide     => ctipide,
                                                    pnnumide     => vnnumide,       pcsexper     => v_sexo,
                                                    pfnacimi     => NULL,           psnip        => NULL,
                                                    pcestper     => 0,              pfjubila     => NULL,
                                                    pcmutualista => NULL,           pfdefunc     => NULL,
                                                    pnordide     => NULL,           pcidioma     => pac_md_common.f_get_cxtidioma,
                                                    ptapelli1    => v_apellido1_dq, ptapelli2    => v_apellido2_dq,
                                                    ptnombre     => v_nombre1_dq,   ptsiglas     => NULL,
                                                    pcprofes     => NULL,           pcestciv     => NULL,
                                                    pcpais       => v_pais,         pcempres     => pac_md_common.f_get_cxtempresa,
                                                    ptablas      => 'PO',          pswpubli     => 1,
                                                    ptnombre1    => v_nombre1_dq,   ptnombre2    => v_nombre2_dq,
                                                    pswrut       => NULL,           pcocupacion  => NULL
													/* Cambios para solicitudes múltiples : Start */
													,pTipoosc => NULL
                                                    ,pCIIU => v_cod_ciiu
                                                    ,pSFINANCI => 0
                                                    ,pFConsti => null
                                                    ,pCONTACTOS_PER => NULL
                                                    ,pDIRECCIONS_PER => NULL
                                                    ,pNacionalidad => null
                                                    ,pDigitoide => null
													/* Cambios para solicitudes múltiples : End */
													/* CAMBIOS De IAXIS-4538 : Start */
													,pfefecto =>null 
                                                    ,pcregfiscal =>null 
                                                    ,pctipiva  =>null 
                                                    ,pIMPUETOS_PER =>null 
													/* CAMBIOS De IAXIS-4538 : End */
													);

              mensajes := f_traspasar_errores_mensajes(errores);

              IF mensajes IS NOT NULL
              THEN
                 IF mensajes.count > 0
                 THEN
                    RETURN 1;
                 END IF;
              END IF;

			/* Cambios para solicitudes múltiples : Start */
			  /* Vas a actualizar Ciiu con pac_persona
              IF v_cod_ciiu IS NOT NULL THEN
                  vnumerr := pac_financiera.f_grabar_general(psperson  => psperson,
                                                             psfinanci => NULL, pcmodo    => NULL,
                                                             ptdescrip => NULL, pfccomer  => f_sysdate,
                                                             pcfotorut => NULL, pfrut     => NULL,
                                                             pttitulo  => NULL, pcfotoced => NULL,
                                                             pfexpiced => NULL, pcpais    => NULL,
                                                             pcprovin  => NULL, pcpoblac  => NULL,
                                                             ptinfoad  => NULL,
                                                             pcciiu    => v_cod_ciiu,
                                                             pctipsoci => NULL, pcestsoc  => NULL,
                                                             ptobjsoc  => NULL, ptexperi  => NULL,
                                                             pfconsti  => NULL, ptvigenc  => NULL,
                                                             mensajes  => mensajes);

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;
			  */
			  /* Cambios para solicitudes múltiples : End */
              IF v_dir_1 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_direccion(psperson   => psperson,        pcagente   => pac_md_common.f_get_cxtagente,
                                                         pcdomici   => v_cdocimi_1,       pctipdir   => 9,
                                                         pcsiglas   => NULL,            ptnomvia   => v_dir_1,
                                                         pnnumvia   => NULL,            ptcomple   => NULL,
                                                         ptdomici   => '''' || v_dir_1 || '''',
                                                         pcpostal   => v_cod_ciudad1_1, pcpoblac   => substr(v_cod_ciudad1_1, -3),
                                                         pcprovin   => v_cod_depto1_1,  pcusuari   => f_user,
                                                         pfmovimi   => f_sysdate,       pcidioma   => pac_md_common.f_get_cxtidioma,
                                                         perrores   => errores,         ptablas    => 'PO',
                                                         pcviavp    => NULL,            pclitvp    => NULL,
                                                         pcbisvp    => NULL,            pcorvp     => NULL,
                                                         pnviaadco  => NULL,            pclitco    => NULL,
                                                         pcorco     => NULL,            pnplacaco  => NULL,
                                                         pcor2co    => NULL,            pcdet1ia   => NULL,
                                                         ptnum1ia   => NULL,            pcdet2ia   => NULL,
                                                         ptnum2ia   => NULL,            pcdet3ia   => NULL,
                                                         ptnum3ia   => NULL,            plocalidad => NULL,
                                                         ptalias    => NULL);

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                    RETURN 1;
                  END IF;
              END IF;

              IF v_dir_2 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_direccion(psperson   => psperson,        pcagente   => pac_md_common.f_get_cxtagente,
                                                         pcdomici   => v_cdocimi_2,       pctipdir   => 9,
                                                         pcsiglas   => NULL,            ptnomvia   => v_dir_2,
                                                         pnnumvia   => NULL,            ptcomple   => NULL,
                                                         ptdomici   => '''' || v_dir_2 || '''',
                                                         pcpostal   => v_cod_ciudad2_2, pcpoblac   => substr(v_cod_ciudad2_2, -3),
                                                         pcprovin   => v_cod_depto1_2,  pcusuari   => f_user,
                                                         pfmovimi   => f_sysdate,       pcidioma   => pac_md_common.f_get_cxtidioma,
                                                         perrores   => errores,         ptablas    => 'PO',
                                                         pcviavp    => NULL,            pclitvp    => NULL,
                                                         pcbisvp    => NULL,            pcorvp     => NULL,
                                                         pnviaadco  => NULL,            pclitco    => NULL,
                                                         pcorco     => NULL,            pnplacaco  => NULL,
                                                         pcor2co    => NULL,            pcdet1ia   => NULL,
                                                         ptnum1ia   => NULL,            pcdet2ia   => NULL,
                                                         ptnum2ia   => NULL,            pcdet3ia   => NULL,
                                                         ptnum3ia   => NULL,            plocalidad => NULL,
                                                         ptalias    => NULL);

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_dir_3 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_direccion(psperson   => psperson,        pcagente   => pac_md_common.f_get_cxtagente,
                                                         pcdomici   => v_cdocimi_3,       pctipdir   => 9,
                                                         pcsiglas   => NULL,            ptnomvia   => v_dir_3,
                                                         pnnumvia   => NULL,            ptcomple   => NULL,
                                                         ptdomici   => '''' || v_dir_3 || '''',
                                                         pcpostal   => v_cod_ciudad1_3, pcpoblac   => substr(v_cod_ciudad1_3, -3),
                                                         pcprovin   => v_cod_depto1_3,  pcusuari   => f_user,
                                                         pfmovimi   => f_sysdate,       pcidioma   => pac_md_common.f_get_cxtidioma,
                                                         perrores   => errores,         ptablas    => 'PO',
                                                         pcviavp    => NULL,            pclitvp    => NULL,
                                                         pcbisvp    => NULL,            pcorvp     => NULL,
                                                         pnviaadco  => NULL,            pclitco    => NULL,
                                                         pcorco     => NULL,            pnplacaco  => NULL,
                                                         pcor2co    => NULL,            pcdet1ia   => NULL,
                                                         ptnum1ia   => NULL,            pcdet2ia   => NULL,
                                                         ptnum2ia   => NULL,            pcdet3ia   => NULL,
                                                         ptnum3ia   => NULL,            plocalidad => NULL,
                                                         ptalias    => NULL);

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_tel_1 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 1,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_tel_1,
                                                        ptvalcon => v_tel_1,
                                                        pcdomici => NULL,
                                                        pcprefix => 57,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_cel_1 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 6,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_cel_1,
                                                        ptvalcon => v_cel_1,
                                                        pcdomici => NULL,
                                                        pcprefix => NULL,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_correo_1 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 3,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_cor_1,
                                                        ptvalcon => v_correo_1,
                                                        pcdomici => NULL,
                                                        pcprefix => NULL,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_tel_2 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 1,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_tel_2,
                                                        ptvalcon => v_tel_2,
                                                        pcdomici => NULL,
                                                        pcprefix => 57,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_cel_2 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 6,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_cel_2,
                                                        ptvalcon => v_cel_2,
                                                        pcdomici => NULL,
                                                        pcprefix => NULL,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_correo_2 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 3,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_cor_2,
                                                        ptvalcon => v_correo_2,
                                                        pcdomici => NULL,
                                                        pcprefix => NULL,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_tel_3 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 1,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_tel_3,
                                                        ptvalcon => v_tel_3,
                                                        pcdomici => NULL,
                                                        pcprefix => 57,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_cel_3 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 6,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_cel_3,
                                                        ptvalcon => v_cel_3,
                                                        pcdomici => NULL,
                                                        pcprefix => NULL,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              IF v_correo_3 IS NOT NULL THEN
                  vnumerr := pac_persona.f_set_contacto(psperson => psperson,
                                                        pcagente => pac_md_common.f_get_cxtagente,
                                                        pctipcon => 3,
                                                        ptcomcon => NULL,
                                                        psmodcon => v_con_cor_3,
                                                        ptvalcon => v_correo_3,
                                                        pcdomici => NULL,
                                                        pcprefix => NULL,
                                                        errores  => errores,
                                                        ptablas  => 'PO');

                  mensajes := f_traspasar_errores_mensajes(errores);

                  IF mensajes IS NOT NULL
                  THEN
                     IF mensajes.count > 0
                     THEN
                        RETURN 1;
                     END IF;
                  END IF;

                  IF vnumerr <> 0 THEN
                        RETURN 1;
                  END IF;
              END IF;

              BEGIN
                  UPDATE per_parpersonas
                     SET nvalpar = 1
                   WHERE cparam = 'PERSONA_CIFIN'
                     AND sperson = psperson;
              EXCEPTION
                 WHEN OTHERS THEN
                    NULL;
              END;

          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9908875);

          END IF;
      ELSE
         vnumerr := 1;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001806);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN no_data_found THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 109617,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_set_persona_cifin;


   PROCEDURE parsear (p_clob IN CLOB, p_parser IN OUT xmlparser.parser)
   IS
   BEGIN
      p_parser := xmlparser.newparser;
      xmlparser.setvalidationmode (p_parser, FALSE);

      IF DBMS_LOB.getlength (p_clob) > 32767
      THEN
         xmlparser.parseclob (p_parser, p_clob);
      ELSE
         xmlparser.parsebuffer (p_parser,
                                DBMS_LOB.SUBSTR (p_clob,
                                                 DBMS_LOB.getlength (p_clob),
                                                 1
                                                )
                               );
      END IF;
   END;

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
      PFDESVIN    IN   DATE,
      mensajes    IN OUT t_iax_mensajes
    ) RETURN NUMBER IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_cpep_sarlatf';
   BEGIN
      vnumerr := pac_persona.f_set_cpep_sarlatf(PSSARLAFT, PIDENTIFICACION, PCTIPREL, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PCPAIS, PTPAIS, PTENTIDAD, PTCARGO, PFDESVIN);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_cpep_sarlatf;

    FUNCTION f_get_cpep_sarlatf(
      PSSARLAFT   IN  NUMBER ,
      mensajes IN OUT t_iax_mensajes
    ) RETURN sys_refcursor   IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_cpep_sarlatf';
      v_cursor       sys_refcursor;
    BEGIN
       v_cursor := pac_persona.f_get_cpep_sarlatf(PSSARLAFT);
       COMMIT;
       RETURN v_cursor;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN NULL;
    END f_get_cpep_sarlatf;

    FUNCTION f_del_cpep_sarlatf(
      PSSARLAFT      IN  NUMBER ,
      PIDENTIFICACION IN NUMBER,
      mensajes  IN OUT t_iax_mensajes
    ) RETURN NUMBER  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_del_cpep_sarlatf';
    BEGIN
       vnumerr := pac_persona.f_del_cpep_sarlatf(PSSARLAFT, PIDENTIFICACION);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_del_cpep_sarlatf;



    FUNCTION f_set_caccionista_sarlatf   (
      PSSARLAFT   IN  NUMBER ,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI   IN  NUMBER,
      PTNOMBRE	  IN   VARCHAR2,
      PCTIPIDEN	  IN NUMBER ,
      PNNUMIDE	  IN   VARCHAR2 ,
      PCBOLSA     IN  NUMBER,
      PCPEP    	  IN NUMBER,
      PCTRIBUEXT  IN     NUMBER,
      mensajes  IN OUT t_iax_mensajes
    )  RETURN NUMBER IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_caccionista_sarlatf';
    BEGIN
       vnumerr := pac_persona.f_set_caccionista_sarlatf(PSSARLAFT, PIDENTIFICACION, PPPARTICI, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PCBOLSA, PCPEP, PCTRIBUEXT);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_set_caccionista_sarlatf;

    FUNCTION f_get_caccionista_sarlatf   (
      PSSARLAFT   IN  NUMBER ,
      mensajes IN OUT t_iax_mensajes
    )  RETURN sys_refcursor   IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_caccionista_sarlatf';
      v_cursor       sys_refcursor;
    BEGIN
       v_cursor := pac_persona.f_get_caccionista_sarlatf(PSSARLAFT);
       COMMIT;
       RETURN v_cursor;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN NULL;
    END f_get_caccionista_sarlatf;

    FUNCTION f_del_caccionista_sarlatf   (
      PSSARLAFT      IN  NUMBER ,
      PIDENTIFICACION IN NUMBER,
      mensajes  IN OUT t_iax_mensajes
    )  RETURN NUMBER  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_del_caccionista_sarlatf';
    BEGIN
       vnumerr := pac_persona.f_del_caccionista_sarlatf(PSSARLAFT, PIDENTIFICACION);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_del_caccionista_sarlatf;


    FUNCTION f_set_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI       IN  NUMBER,
      PTNOMBRE        IN  VARCHAR2,
      PCTIPIDEN       IN  NUMBER,
      PNNUMIDE        IN  VARCHAR2,
      PTSOCIEDAD      IN  VARCHAR2,
      PNNUMIDESOC     IN  VARCHAR2,
      mensajes  IN OUT t_iax_mensajes
    ) RETURN NUMBER  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_accionista_sarlatf';
    BEGIN
       vnumerr := pac_persona.f_set_accionista_sarlatf(PSSARLAFT, PIDENTIFICACION,PPPARTICI, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PTSOCIEDAD, PNNUMIDESOC);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_set_accionista_sarlatf;

    FUNCTION f_get_accionista_sarlatf (
      PSSARLAFT   IN  NUMBER ,
      mensajes  IN OUT t_iax_mensajes
    ) RETURN sys_refcursor  IS






      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_accionista_sarlatf';
      v_cursor       sys_refcursor;
    BEGIN
          v_cursor := pac_persona.f_get_accionista_sarlatf(PSSARLAFT);
       COMMIT;
       RETURN v_cursor;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN NULL;
    END f_get_accionista_sarlatf;

    FUNCTION f_del_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER ,
      PIDENTIFICACION IN NUMBER,
      mensajes  IN OUT t_iax_mensajes
    ) RETURN NUMBER  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_del_accionista_sarlatf';
    BEGIN
       vnumerr := pac_persona.f_del_accionista_sarlatf(PSSARLAFT, PIDENTIFICACION);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_del_accionista_sarlatf;





    FUNCTION f_get_ultimosestados_sarlatf (
      PSPERSON   IN  NUMBER ,
      mensajes  IN OUT t_iax_mensajes
    ) RETURN sys_refcursor  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSPERSON: ' || PSPERSON;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_ultimosestados_sarlatf';
      v_cursor       sys_refcursor;
    BEGIN
       v_cursor := pac_persona.f_get_ultimosestados_sarlatf(PSPERSON);

       COMMIT;
       RETURN v_cursor;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN NULL;
    END f_get_ultimosestados_sarlatf;

   FUNCTION f_get_persona_sarlaf(
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_persona.f_get_persona_sarlaf';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_persona.f_get_persona_sarlaf(psperson, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_persona_sarlaf;

---------------------------------------------------------------------------------------------
   --INI--WAJ
    FUNCTION f_get_impuestos(psperson        IN NUMBER,
                                  ptablas         IN VARCHAR2,
                                  mensajes        IN OUT t_iax_mensajes,
                                  ptimpuestos OUT t_iax_impuestos
                                  )
      RETURN NUMBER IS
      vnumerr  NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'parametros - psperson: ' || psperson ||
                                 ' ptablas = ' || ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_GET_IMPUESTOS';

          CURSOR c1 IS
          SELECT ctipind
                  FROM per_indicadores
                  WHERE sperson = psperson;


   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      ptimpuestos := t_iax_impuestos();

      FOR reg IN c1
      LOOP
         ptimpuestos.extend();
         ptimpuestos (ptimpuestos.last):= ob_iax_impuestos();
         vnumerr := f_get_impuesto(psperson,  ptablas, reg.ctipind,
                                        mensajes,
                                        ptimpuestos(ptimpuestos.last)
                                        );

         IF mensajes IS NOT NULL
         THEN
            IF mensajes.count > 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_impuestos;

   /*************************************************************************/
 FUNCTION f_get_impuesto(psperson        IN NUMBER,
                                            ptablas         IN VARCHAR2,
                                            psctipind    IN NUMBER,
                                            mensajes        IN OUT t_iax_mensajes,
                               poimpuestos OUT ob_iax_impuestos
                               )
                                RETURN NUMBER IS


      vnumerr  NUMBER(8) := 0;
      cpais    NUMBER;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson ||
                              ' ptablas = ' ||
                                ptablas;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_impuestos';

      CURSOR c1 IS
        select a.ccodimp, a.tdesimp, b.ctipind, c.tindica, b.cusualta, b.falta
         from sin_imp_desimpuesto a, per_indicadores b, tipos_indicadores c
       where b.sperson = psperson
          and b.ctipind = psctipind
          and b.ctipind = c.ctipind
          AND c.cimpret = a.ccodimp
          and a.cidioma = pac_md_common.f_get_cxtidioma;

   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      poimpuestos := ob_iax_impuestos();

      FOR rc IN c1
      LOOP
         poimpuestos.ccodimp       := rc.ccodimp;
         poimpuestos.tdesimp       := rc.tdesimp;
         poimpuestos.ctipind     := rc.ctipind;
         poimpuestos.tindica       := rc.tindica;
         poimpuestos.cusuari    := rc.cusualta;
         poimpuestos.falta    := rc.falta;

      END LOOP;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      vpasexec := 3;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
         /*      WHEN NO_DATA_FOUND THEN*/
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_get_impuesto;
 /****************************************************************************/
    FUNCTION f_del_impuesto(psperson IN NUMBER,
                                pctipind IN NUMBER,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vnumerr  NUMBER(8) := 0;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_del_impuesto';
      errores  t_ob_error;
      cont     NUMBER;
   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(1)
        INTO cont
        FROM per_indicadores
       WHERE sperson = psperson
         AND ctipind = pctipind;

      IF cont = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      pac_persona.p_del_impuesto(psperson, pctipind, errores);

      vpasexec := 2;
      mensajes := f_traspasar_errores_mensajes(errores);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN 1;
   END f_del_impuesto;


    FUNCTION f_get_tipo_vinculacion(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_tipo_vinculacion';
      vparam         VARCHAR2(500) := 'parametros - psperson: ' || psperson;
   BEGIN
       v_cursor := pac_md_listvalores.f_opencursor('SELECT CODVINCULO,VINCULACION,CODSUBVINCULO,SUBVINCULO,CTIPIVA,
                      (select TTIPIVA FROM DESCRIPCIONIVA WHERE CTIPIVA = T.CTIPIVA AND CIDIOMA = PAC_MD_COMMON.F_Get_CXTIDIOMA() AND ROWNUM <= 1)
                      AS TTIPIVA FROM ( select CODVINCULO,ff_desvalorfijo(328,PAC_MD_COMMON.F_Get_CXTIDIOMA(),CODVINCULO) as VINCULACION,
                      CODSUBVINCULO,ff_desvalorfijo(800102,PAC_MD_COMMON.F_Get_CXTIDIOMA(),CODSUBVINCULO) as SUBVINCULO,
                        (SELECT CTIPIVA FROM (SELECT CTIPIVA FROM PER_REGIMENFISCAL WHERE SPERSON = ' || psperson || ' ORDER BY FEFECTO DESC ) WHERE ROWNUM <= 1)
                      AS CTIPIVA from per_indicadores WHERE SPERSON = ' || psperson || ') T', mensajes);

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
    END f_get_tipo_vinculacion;
--FIN--WAJ

   -- Ini TCS_1569B - ACL - 01/02/2019
 /*************************************************************************
      Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
      param out mensajes  : mensajes de error
      return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_persona_publica_imp(psperson IN NUMBER,
                                  pctipage IN NUMBER DEFAULT NULL,
                                 -- pcdomici IN NUMBER DEFAULT NULL,
                                  mensajes OUT t_iax_mensajes)
      RETURN ob_iax_personas IS
      vnumerr  NUMBER(8) := 0;
      squery   VARCHAR(2000);
      cur      SYS_REFCURSOR;
      persona  ob_iax_personas := ob_iax_personas();
      vidioma  NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'parametros - psperson: ' || psperson || ' pctipage: ' || pctipage;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.F_Get_persona_publica_imp';
      objpers  ob_iax_personas;
      numpers  NUMBER;
      numerr   NUMBER;
      vtablas  VARCHAR2(15) := 'POL';
      vcagente per_detper.cagente%TYPE;
      v_ctipind1  tipos_indicadores.ctipind%TYPE;
      v_tindica1  tipos_indicadores.tindica%TYPE;
      v_ctipind2  tipos_indicadores.ctipind%TYPE;
      v_tindica2  tipos_indicadores.tindica%TYPE;
      v_ctipind3  tipos_indicadores.ctipind%TYPE;
      v_tindica3  tipos_indicadores.tindica%TYPE;

   BEGIN
      IF psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vcagente := pac_persona.f_buscaagente_publica(psperson);
      IF vcagente IS NULL
      THEN
         SELECT MAX(cagente)
           INTO vcagente
           FROM per_detper
          WHERE sperson = psperson;
      END IF;

      IF vcagente IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000503);
      ELSE
         vpasexec := 2;
         squery   := 'select        p.tapelli1     ,
	                                p.tapelli2     ,
	                                p.tnombre      ,
	                                nordide       ,
	                                p.ctipper      ,
	                                p.ctipide      ,
	                                ff_desvalorfijo (672, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.ctipide) ttipide      ,
	                                p.nnumide      ,
	                                p.fnacimi      ,
	                                p.csexper      ,
	                                ff_desvalorfijo (11, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.csexper )  tsexper    ,
	                                p.cestper      ,
	                                ff_desvalorfijo (13, PAC_MD_COMMON.F_Get_CXTIDIOMA(),p.cestper )  testper    ,
	                                p.fjubila      ,
	                                p.fdefunc      ,
	                                f_user     ,
	                                p.fmovimi      ,
	                                p.cmutualista  ,
	                                p.cidioma      ,
	                                p.swpubli      ,
	                                NULL spereal    ,
	                                p.CPROFES,
	                                 (select max(pa.tprofes) from profesiones pa where pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA() and  pa.cprofes=p.cprofes) TPROFES ,
	                                p.CPAIS    ,
	                                (select max(pa.tpais) from despaises pa where pa.cpais=p.cpais and pa.cidioma=PAC_MD_COMMON.F_Get_CXTIDIOMA()) TPAIS,
	                                tsiglas,
	                                snip
	                      from personas_detalles p
	                      where sperson = ' || psperson ||
                     ' and cagente = ' || vcagente || '';

		--IF pctipage IS NOT NULL THEN
		  BEGIN
				  select t.ctipind, t.tindica
				   into v_ctipind1, v_tindica1
					from tipos_indicadores t, per_indicadores p
					where p.CTIPIND = t.CTIPIND
					and t.CIMPRET = 1
					and p.sperson = psperson
					and p.codvinculo = 3;
					--and p.codsubvinculo = pctipage;
		   EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		  END;
		   BEGIN
				select t.ctipind, t.tindica
				   into v_ctipind2, v_tindica2
					from tipos_indicadores t, per_indicadores p
					where p.CTIPIND = t.CTIPIND
					and t.CIMPRET = 2
					and p.sperson = psperson
					and p.codvinculo = 3;
					--and p.codsubvinculo = pctipage;
				EXCEPTION
				 WHEN NO_DATA_FOUND THEN
					NULL;
					END;
		   BEGIN
				select t.ctipind, t.tindica
				   into v_ctipind3, v_tindica3
					from tipos_indicadores t, per_indicadores p
					where p.CTIPIND = t.CTIPIND
					and t.CIMPRET = 3
					and p.sperson = psperson
					and p.codvinculo = 3;
					--and p.codsubvinculo = pctipage;
				EXCEPTION
				 WHEN NO_DATA_FOUND THEN
					NULL;
		  END;
		--END IF;

				 vpasexec := 3;
				 vnumerr  := pac_md_log.f_log_consultas(squery,
														'PAC_MD_PERSONA.f_get_persona_publica',
														1, 1, mensajes);
				 cur      := pac_md_listvalores.f_opencursor(squery, mensajes);
				 vpasexec := 4;

         LOOP
            FETCH cur
               INTO persona.tapelli1,
                    persona.tapelli2,
                    persona.tnombre,
                    persona.nordide,
                    persona.ctipper,
                    persona.ctipide,
                    persona.ttipide,
                    persona.nnumide,
                    persona.fnacimi,
                    persona.csexper,
                    persona.tsexper,
                    persona.cestper,
                    persona.testper,
                    persona.fjubila,
                    persona.fdefunc,
                    persona.cusuari,
                    persona.fmovimi,
                    persona.cmutualista,
                    persona.cidioma,
                    persona.swpubli,
                    persona.spereal,
                    persona.cprofes,
                    persona.tprofes,
                    persona.cpais,
                    persona.tpais,
                    persona.tsiglas,
                    persona.snip;

            EXIT WHEN cur%NOTFOUND;
            persona.cagente := vcagente;
            persona.sperson := psperson;
            persona.tsiglas := v_tindica1;
            persona.testperlopd := v_tindica2;
            persona.tocupacion := v_tindica3;
            numerr          := f_get_direcciones(psperson, vcagente,
                                                 persona.direcciones,
                                                 mensajes, vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            numerr := f_get_contactos(psperson, vcagente, persona.contactos,
                                      mensajes, vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            numerr := f_get_nacionalidades(psperson, vcagente,
                                           persona.nacionalidades, mensajes,
                                           vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            numerr := f_get_cuentasbancarias(psperson, vcagente, NULL,
                                             persona.ccc, mensajes, vtablas);

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            numerr := f_get_identificadores(psperson, vcagente,
                                            persona.identificadores, mensajes,
                                            vtablas);
            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            vpasexec := 6;
         END LOOP;

         CLOSE cur;
      END IF;

      RETURN persona;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006,
                                           vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_persona_publica_imp;
  -- Fin TCS_1569B - ACL - 01/02/2019

  --Inicio Bartolo Herrera 04-03-2019 ---- IAXIS-2826
	/*************************************************************************
    FUNCTION f_get_parpersona_cont
    Permite obtener los valores de un parametro de persona
    param in psperson    : codigo de la persona
    param in pcparam     : codigo del parametro
    param out mensajes   : mesajes de error
    return               : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_parpersona_cont(
      psperson IN NUMBER,
      pcparam IN  VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_parpersona_cont';
      vparam         VARCHAR2(500) := 'psperson = ' || psperson || ' - pcparam = ' || pcparam;
   BEGIN
        v_cursor := pac_md_listvalores.f_opencursor('select nvalpar, tvalpar, fvalpar from per_parpersonas where cparam = ''' || pcparam || ''' and sperson = ' || psperson || ' and rownum <= 1', mensajes);
		RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_parpersona_cont;

    /*************************************************************************
    FUNCTION f_get_cupo_persona
    Permite obtener el cupo asignado en ficha financiera de la persona
    param in psperson    : codigo de la persona
    param out mensajes   : mesajes de error
    return               : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_cupo_persona(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_cupo_persona';
      vparam         VARCHAR2(500) := 'psperson = ' || psperson;
   BEGIN
      v_cursor := pac_md_listvalores.f_opencursor('select f_cupo_garantizado(' || psperson || ') as cupo from dual', mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cupo_persona;
  --Fin Bartolo Herrera 04-03-2019 ---- IAXIS-2826

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
      vnumerr  NUMBER := 0;
      vobject  VARCHAR2(200) := 'PAC_MD_PERSONA.f_duplicar_sarlaft';
      vparam   VARCHAR2(500) := 'pssarlaft = ' || pssarlaft;
      vpasexec NUMBER := 0;
      --
    BEGIN
      IF pssarlaft IS NULL
      THEN
         RAISE e_param_error;
      END IF;
      vpasexec := 1;
      vnumerr  := pac_persona.f_duplicar_sarlaft(pssarlaft, pssarlaftdest, mensajes );
      vpasexec := 2;

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
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
	--INI IAXIS-3670 16/04/2019 AP
    /*************************************************************************
    FUNCTION f_valida_consorcios
    Valida la participacion de la agrupacion de consorcios
    param in psperson    : codigo de la persona
    param out mensajes   : mesajes de error
    return               : sys_refcursor
   *************************************************************************/
   FUNCTION f_valida_consorcios(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec      NUMBER;
      vobject       VARCHAR2(200) := 'PAC_md_persona.f_valida_consorcios';
      vparam        VARCHAR2(500) := 'psperson = ' || psperson;
      vnumerr       NUMBER := 0;
      v_tienea_agrp BOOLEAN := FALSE;
      
      CURSOR c_agrup IS
        SELECT cagrupa, SUM(pparticipacion)tot_part
          FROM per_personas_rel
         WHERE sperson = psperson
           AND ctipper_rel = 0
           AND cagrupa <> 0
      GROUP BY cagrupa
      ORDER BY cagrupa;
        
        
   BEGIN
        vnumerr := f_consorcio(psperson);
        
        IF vnumerr = 0 THEN --No es consorcio
            RETURN 0;
        END IF;
        
        FOR agrup IN c_agrup LOOP
            v_tienea_agrp := TRUE;
            IF agrup.tot_part < 100 THEN
                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,1,NULL,replace(f_axis_literales(89906267,8),'#1#',agrup.cagrupa));
                RETURN 1;
            END IF;
        END LOOP;
        
        IF v_tienea_agrp = FALSE THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,1,NULL,f_axis_literales(89908018,8));
            RETURN 1;
        END IF;
        
        RETURN 0;

   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_valida_consorcios;
    --FIN IAXIS-3670 16/04/2019 AP


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
		vnumerr   NUMBER(8) := 0;
		VTRAZA    NUMBER := 0;
		vparam    VARCHAR2(500) := 'parametros - PCBANCO: ' || PCBANCO || ' PCTIPCC' || PCTIPCC;
		vobject   VARCHAR2(200) := 'PAC_MD_PERSONA.F_GET_CODITIPOBANC';
		--
	BEGIN
		IF PCBANCO IS NULL OR PCTIPCC IS NULL THEN
			RAISE e_object_error;
		END IF;
		--
		vnumerr := PAC_PERSONA.F_GET_CODITIPOBANC(PCBANCO, PCTIPCC, PCTIPBAN);
		--
		IF vnumerr <> 0 THEN
			RAISE e_object_error;
		END IF;
		--
		RETURN vnumerr;
		--
	EXCEPTION
		WHEN e_object_error THEN
			P_TAB_ERROR(F_SYSDATE, F_USER, vobject, VTRAZA, 'Error en PAC_MD_PERSONA.F_GET_CODITIPOBANC', 'Error : ' || SQLERRM);
			RETURN 1;
		WHEN OTHERS THEN
			P_TAB_ERROR(F_SYSDATE, F_USER, vobject, VTRAZA, 'Error en PAC_MD_PERSONA.F_GET_CODITIPOBANC', 'Error : ' || SQLERRM);
			RETURN 1;
	END F_GET_CODITIPOBANC;


END pac_md_persona;
/

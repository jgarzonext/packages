CREATE OR REPLACE PACKAGE BODY "PAC_CON" IS
/******************************************************************************
   NOMBRE:      PAC_CON
   PROPÓSITO:   Preparación para conexiones con interfaces
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.1                                     1. Creación del package.
   1.2        02/09/2009  JMF              2. 0010875: CEM - Búsqueda de personas por NIF con letra minúscula
   2          07/09/2009  XPL              3. 10878: CEM - Persona es empleado de la empresa
   3.         07/09/2009  NMM              4. 11948: CEM - Alta de destinatatios.
   4.         05/01/2010  JAS              5. 12574: CRE - Error en la generació del justificant de factures de reemborsaments en PDF
   6.0        26/08/2010  SRA              6. 14365: CRT002 - Gestion de personas
   7.0        01/09/2010  FAL              7. 14365: CRT002 - Gestion de personas
   8.0        22/11/2010  JAS              8. 13266: CIVF001 - Modificación interfases apertura y cierre de puesto (parte PL)
   9.0        07/02/2011  ICV              9. 0017247: ENSA103 - Instalar els web-services als entorns CSI
   10.0       17/02/2010  ETM              10. 0017389: ENSA103 - SAP - Modificacions procés pagaments
   11.0       13/09/2011  DRA              11. 0018682: AGM102 - Producto SobrePrecio- Definición y Parametrización
   12.0       28/11/2011  JRB              12. 0020211: LCOL898 - Encolamiento de errores comunciación AxisConnect
   13.0       08/02/2012  JMP              13. 21270/106644: LCOL898 - Interfase persones. Enviar segon registre amb el RUT
   14.0       21/02/2012  JMP              14. 21431/107888: LCOL898-Sincronització tercers - Crear taula d'excepcions d'enviaments de persones
   15.0       29/02/2012  ETM              15. 0021406: MDP - PER - Añadir el nombre en la tabla contactos
   16.0       01/03/2012  DRA              16. 0021467: AGM- Quitar en la descripción de riesgos el plan y al final se muestran caracteres raros
   17.0       10/04/2012  JMF              0021190 CRE998-CRE - Sistema de comunicaci Axis - eCredit (ver 0021187)
   18.0       09/10/2012  XVM              18. 0023687: Release 2. Webservices de Mutua de Propietarios
   19.0       28/01/2013  APD              19. 0025558: LCOL_F003-Env?o Contabilidad en Interface de CxP
   20.0       17/04/2013  AMJ              20. 0026170: LCOL800-Eliminaci? de taules temporals
   21.0       27/03/2013  ECP              21. 0026513: LCOL898- Reintentos envios JDE. Nota 141109
   22.0       04/06/2013  ETM             0026318: POSS038-(POSIN011)-Interfaces:IAXIS-SAP: Interfaz de Personas
   23.0       01/07/2013  RDD              23. 0027351: LCOL_F003-Revisar QT de contabilidad de Autos - Fase 3A
   24.0       24/10/2013  JMG              24. 0028644-156855 : POS - PER - Reproceso de interfaz de personas.
   25.0       11/02/2014  JDS              25. 29315#c165209   LCOL_T031-Revisi?n Q-Trackers Fase 3A III
   26.0       26/02/2014  MMM              26. 0030340: LCOL_F003-0011631 / 0011632: No Se Reflejan CxP Siniestros Vida Grupo
   27.0       19/08/2014  GGR              0027314: Cambio funcion f_persona_duplicada_nnumide por f_gubernamental
   28.0       12/05/2017  AAB              28. CONF-403: Se realiza cambios en f_emision_pagorec adicionando un query para cambio en el XML.
   29.0       07/01/2019  Swapnil      	   29. Cambios para solicitudes múltiples
   30.0	      25/06/2019  SWAPNIL	       30. Cambios de Iaxis-4521
   31.0		  27/06/2019  KK 			   31. CAMBIOS De IAXIS-4538
   32.0		  19/07/2019  SWAPNIL		   32. Cambios de IAXIS-4711	
   33.0		  27/01/2020  Swapnil 		   33. Cambios de Swapnil para : Defecto de SIN. y RES.
******************************************************************************/
------------------------------------------------------------------------------------
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   PROCEDURE p_recupera_error(
      psinterf IN int_resultado.sinterf%TYPE,
      presultado OUT int_resultado.cresultado%TYPE,
      perror OUT int_resultado.terror%TYPE,
      pnerror OUT int_resultado.nerror%TYPE) IS
   BEGIN
      -- Recupero el error
      SELECT r1.cresultado, r1.terror, r1.nerror
        INTO presultado, perror, pnerror
        FROM int_resultado r1
       WHERE r1.sinterf = psinterf
         AND r1.smapead = (SELECT MAX(r2.smapead)
                             FROM int_resultado r2
                            WHERE r2.sinterf = psinterf);
   EXCEPTION
      WHEN OTHERS THEN
         presultado := NULL;
         perror := NULL;
         pnerror := NULL;
   END;

   FUNCTION f_validar_usuario(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pvalidado OUT NUMBER,
      poficina OUT NUMBER,
      ptnombre OUT VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pusuario || '|' || ppassword || '|' || pempresa;
      -- JLB - las @ se utilizan como seperador en pac_int_online
      vlineaini := REPLACE(vlineaini, '@', '[$#ARROBA#$]');
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I001', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      BEGIN
         SELECT tparam
           INTO pvalidado
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'VALIDADO';
      EXCEPTION
         WHEN OTHERS THEN
            pvalidado := NULL;
      END;

      BEGIN
         SELECT tparam
           INTO poficina
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'OFICINA';
      EXCEPTION
         WHEN OTHERS THEN
            poficina := NULL;
      END;

      BEGIN
         SELECT tparam
           INTO ptnombre
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'NOMBRE';
      EXCEPTION
         WHEN OTHERS THEN
            ptnombre := NULL;
      END;

      perror := NULL;
      RETURN vnerror;   -- 0 todo ok otro valor si error.
   EXCEPTION
      WHEN OTHERS THEN
         perror := SQLCODE;
         RETURN 2;
   END f_validar_usuario;

   FUNCTION f_busqueda_persona(
      pempresa IN NUMBER,
      psip IN VARCHAR2,
      pctipdoc IN NUMBER,
      ptdocidentif IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pterminal IN VARCHAR2,
      pmasdatos IN NUMBER,
      pomasdatos OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pusuario IN VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      -- Bug 0010875 - 02/09/2009 - JMF NIF en majuscules
      vlineaini := pempresa || '|' || psip || '|' || pctipdoc || '|' || UPPER(ptdocidentif)
                   || '|' || ptnombre || '|' || pterminal || '|' || pmasdatos || '|'
                   || pcognom1 || '|' || pcognom2 || '|' || pusuario;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I002', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      BEGIN
         SELECT tparam
           INTO pomasdatos
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'MASDATOS';
      EXCEPTION
         WHEN OTHERS THEN
            pomasdatos := 0;
      END;

      RETURN 0;   --devuelvo el interfaz de la tabla int_datos_persona
   END f_busqueda_persona;

   FUNCTION f_datos_persona(
      pempresa IN NUMBER,
      psip IN VARCHAR2,
      pterminal IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pempresa || '|' || psip || '|' || pterminal || '|' || pusuario;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I003', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      RETURN 0;   -- ok
   END f_datos_persona;

   FUNCTION f_cuentas_persona(
      pempresa IN NUMBER,
      psperson IN VARCHAR2,
      pcrol IN NUMBER,
      pcestado IN NUMBER,
      pcsaldo IN NUMBER,
      pcoperador IN VARCHAR2,
      poficina IN VARCHAR2,
      pterminal IN VARCHAR2,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
      vsnip          estper_personas.snip%TYPE;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      -- recupero el snip
      IF NVL(porigen, '*') = 'EST' THEN
         SELECT snip
           INTO vsnip
           FROM estper_personas
          WHERE sperson = psperson;
      ELSE
         SELECT snip
           INTO vsnip
           FROM per_personas
          WHERE sperson = psperson;
      END IF;

      vlineaini := pempresa || '|' || vsnip || '|' || pcrol || '|' || pcestado || '|'
                   || pcsaldo || '|' || pcoperador || '|' || poficina || '|' || pterminal
                   || '|' || pusuario;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I004', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      RETURN 0;   -- ok
   END f_cuentas_persona;

   FUNCTION f_cobro_recibo(
      pempresa IN NUMBER,
      pnrecibo IN NUMBER,
      pterminal IN VARCHAR2,
      pcobrado OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pempresa || '|' || pnrecibo || '|' || pterminal || '|' || pusuario;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I005', vlineaini);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      BEGIN
         SELECT tparam
           INTO pcobrado
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'COBRADO';
      EXCEPTION
         WHEN OTHERS THEN
            pcobrado := NULL;
      END;

      RETURN 0;   --
   END f_cobro_recibo;

   FUNCTION f_abrir_puesto(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      psinterf IN OUT NUMBER,
      poficina OUT NUMBER,
      ptermlog OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vpasexec       NUMBER(10);
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
      vcempleado     usuarios.cempleado%TYPE;
      vtermlogic     VARCHAR2(50);
      vtermfisic     VARCHAR2(50);
      voficina       NUMBER(10);
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 3;
      vnerror := pac_user.f_get_empleado(pusuario, vcempleado);

      IF vnerror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_abrir_puesto', vpasexec,
                     'Error recuperar empleado', 'Error: ' || vnerror);
         RETURN vnerror;
      END IF;

      vpasexec := 4;
      vnerror := pac_user.f_get_termfisic(pusuario, vtermfisic);

      IF vnerror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_abrir_puesto', vpasexec,
                     'Error recuperar terminal fisic', 'Error: ' || vnerror);
         RETURN vnerror;
      END IF;

      vpasexec := 41;
      vnerror := pac_user.f_get_cagente(pusuario, voficina);

      IF vnerror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_abrir_puesto', vpasexec,
                     'Error recuperar oficina', 'Error: ' || vnerror);
         RETURN vnerror;
      END IF;

      vpasexec := 5;
      vlineaini := pempresa || '|' || vcempleado || '|' || ppassword || '|' || vtermlogic
                   || '|' || voficina || '|' || vtermfisic;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I006', vlineaini);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      vpasexec := 6;
      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_abrir_puesto', vpasexec,
                     'Error recuperant errors interficie', 'Error: ' || vnerror);
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_abrir_puesto', vpasexec,
                     'Error recuperant errors interficie', 'Error: ' || vnerror);
         RETURN vnerror;
      END IF;

      vpasexec := 7;

      BEGIN
         SELECT tparam
           INTO voficina
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'OFICINA';
      EXCEPTION
         WHEN OTHERS THEN
            voficina := NULL;
      END;

      vpasexec := 8;

      BEGIN
         SELECT tparam
           INTO vtermlogic
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'TERM_VIRTUAL';
      EXCEPTION
         WHEN OTHERS THEN
            vtermlogic := NULL;
      END;

      poficina := voficina;
      ptermlog := vtermlogic;
      RETURN 0;   -- 0 todo ok.
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_abrir_puesto', vpasexec, SQLCODE, SQLERRM);
         RETURN 1;
   END f_abrir_puesto;

   -- cerrar puesto
   FUNCTION f_cerrar_puesto(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vpasexec       NUMBER(10);
      vccompani      NUMBER := pempresa;
      vcempleado     usuarios.cempleado%TYPE;
      vtermlogic     VARCHAR2(50);
      vtermfisic     VARCHAR2(50);
      voficina       NUMBER(10);
   BEGIN
      vpasexec := 1;

      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 3;
      vnerror := pac_user.f_get_empleado(pusuario, vcempleado);

      IF vnerror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_cerrar_puesto', vpasexec,
                     'Error recuperar empleado', 'Error: ' || vnerror);
         RETURN vnerror;
      END IF;

      vpasexec := 4;
      vnerror := pac_user.f_get_terminal(pusuario, vtermlogic);

      IF vnerror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_cerrar_puesto', vpasexec,
                     'Error recuperar terminal', 'Error: ' || vnerror);
         RETURN vnerror;
      END IF;

      vpasexec := 5;
      vnerror := pac_user.f_get_termfisic(pusuario, vtermfisic);

      IF vnerror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_abrir_puesto', vpasexec,
                     'Error recuperar terminal fisic', 'Error: ' || vnerror);
         RETURN vnerror;
      END IF;

      vpasexec := 6;
      vnerror := pac_user.f_get_cagente(pusuario, voficina);

      IF vnerror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_abrir_puesto', vpasexec,
                     'Error recuperar oficina', 'Error: ' || vnerror);
         RETURN vnerror;
      END IF;

      vpasexec := 7;
      vlineaini := pempresa || '|' || vcempleado || '|' || vtermlogic || '|' || voficina || '|'
                   || vtermfisic;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I007', vlineaini);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      vpasexec := 9;
      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      RETURN 0;   -- 0 todo ok
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_cerrar_puesto', vpasexec, SQLCODE, SQLERRM);
         RETURN 1;
   END f_cerrar_puesto;

   --
   FUNCTION f_proceso_alta(
      pempresa IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pop IN VARCHAR2,
      pusuario IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vterminal      NUMBER;
      vccompani      NUMBER := pempresa;
      vpasexec       NUMBER(10) := 1;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 2;
      vnerror := pac_user.f_get_terminal(pusuario, vterminal);

      IF vnerror <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_proceso_alta', vpasexec,
                     'Error recuperar terminal', 'Error: ' || vnerror);
         RAISE NO_DATA_FOUND;
      END IF;

      vlineaini := pempresa || '|' || psseguro || '|' || pop || '|' || vterminal || '|'
                   || pnmovimi;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I009', vlineaini);

      IF vresultado <> 0 THEN
         --RETURN vresultado; --error
         RAISE NO_DATA_FOUND;
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vnerror := pac_log.f_log_interfases(pusuario, f_sysdate, psinterf, 'I009', vresultado,
                                          perror, NULL, NULL, NULL);
      RETURN 0;   --todo ok
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         vnerror := pac_log.f_log_interfases(pusuario, f_sysdate, psinterf, 'I009',
                                             vresultado, SQLERRM, NULL, NULL, NULL);
         RETURN -1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_con.f_proceso_alta', SQLCODE,
                     'Error indeterminado', 'Error: ' || SQLERRM);
         RETURN -1;
   END f_proceso_alta;

   -- Bug 21458/108087 - 23/02/2012 - AMC
   -- Se añaden nuevos parametros de entrada
   FUNCTION f_convertir_documento(
      pempresa IN NUMBER,
      ptipoorigen IN VARCHAR2,
      ptipodestino IN VARCHAR2,
      pficheroorigen IN VARCHAR2,
      pficherodestino IN VARCHAR2,
      pplantillaorigen IN VARCHAR2,   --BUG11404 - JTS - 16/10/2009
      psinterf IN OUT NUMBER,
      pfirmadigital IN VARCHAR2,
      pfirmadigitalalias IN VARCHAR2,
      pfirmaelectronicacliente IN VARCHAR2,
      pfirmaelectronicaclienteimagen IN VARCHAR2,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(1000);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := ptipoorigen || '|' || ptipodestino || '|' || pficheroorigen || '|'
                   || pficherodestino || '|' || pplantillaorigen || '|' || pfirmadigital || '|'
                   || pfirmadigitalalias || '|' || pfirmaelectronicacliente || '|'
                   || pfirmaelectronicaclienteimagen;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I008', vlineaini);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      RETURN 0;   --todo ok
   END f_convertir_documento;

   -- FUNCIONES DE CONVERSION DE DATOS
   FUNCTION f_obtener_valor_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalemp IN VARCHAR2)
      RETURN VARCHAR2 IS
      vvalaxis       int_codigos_emp.cvalaxis%TYPE;
   BEGIN
      vvalaxis := pac_int_online.f_obtener_valor_axis(pemp, pcampo, pvalemp);
      RETURN vvalaxis;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_obtener_valor_axis', 1,
                     pemp || ' ' || pcampo || ' ' || pvalemp, SQLERRM);
         RETURN '@@SINVALOR@@';
   END f_obtener_valor_axis;

   FUNCTION f_obtener_valor_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2, pvalaxis IN VARCHAR2)
      RETURN VARCHAR2 IS
      vvalemp        int_codigos_emp.cvalemp%TYPE;
   BEGIN
      vvalemp := pac_int_online.f_obtener_valor_emp(pemp, pcampo, pvalaxis);
      RETURN vvalemp;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_obtener_valor_emp', 1,
                     pemp || ' ' || pcampo || ' ' || pvalaxis, SQLERRM);
         RETURN '@@SINVALOR@@';
   END f_obtener_valor_emp;

   FUNCTION traspaso_tablas_per_host(
      psinterf IN NUMBER,
      pficticia_sperson OUT estper_personas.sperson%TYPE,
      psseguro IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pcempres IN empresas.cempres%TYPE,
      p_modo IN VARCHAR2   -- Bug 11948
                        )
      RETURN t_ob_error IS
      v_pasexec      NUMBER := 0;
      /* Para insertar personas */
      vspereal       NUMBER;
      vtidenti       NUMBER;   --¿ tipo de persona (física o jurídica)
      vctipide       NUMBER;   --¿ tipo de identificación de persona
      vnnumide       estper_personas.nnumide%TYPE;
      --- Número identificativo de la persona.
      vcsexper       NUMBER;   -- sexo de la pesona.
      vfnacimi       DATE;   -- Fecha de nacimiento de la persona
      vsnip          estper_personas.snip%TYPE;   -- snip
      vcestper       NUMBER;   --¿ estado
      vfjubila       DATE;   --¿
      vcmutualista   NUMBER;   --¿
      vfdefunc       DATE;   --¿
      vnordide       NUMBER;   --¿
      vtapelli1      estper_detper.tapelli1%TYPE;   --¿    Primer apellido
      vtapelli2      estper_detper.tapelli2%TYPE;   --¿    Segundo apellido
      vtnombre       estper_detper.tnombre%TYPE;   --¿    Nombre de la persona
      vtsiglas       estper_detper.tsiglas%TYPE;   --¿    Siglas persona jurídica
      vcprofes       estper_detper.cprofes%TYPE;   --¿    Código profesión
      vtotpersona    estper_personas.trecibido%TYPE;
      vcestciv       NUMBER;   --¿Código estado civil VALOR FIJO = 12
      vcpais         estper_nacionalidades.cpais%TYPE;
      vcnacioni      estper_nacionalidades.cpais%TYPE;
      /* Para insertar direcciones*/
      vsperson       estper_direcciones.sperson%TYPE;
      vcagente       estper_direcciones.cagente%TYPE;
      vcdomici       estper_direcciones.cdomici%TYPE;
      vcsiglas       estper_direcciones.csiglas%TYPE;
      vtdomici       estper_direcciones.tdomici%TYPE;
      vcusuari       estper_direcciones.cusuari%TYPE;
      vfmovimi       estper_direcciones.fmovimi%TYPE;
      vcidioma       idiomas.cidioma%TYPE;
      /* Contactos */
      vsmodcon       NUMBER;
      vtcomcon       VARCHAR2(100);
      /*CCC */
      vcnordban      NUMBER;
      /*Identificador*/
      verrores       t_ob_error;
      nerror         NUMBER;
      v_cont_prof    NUMBER;
      v_esempleado   NUMBER;
      vcagente_visio NUMBER;
      vcagente_per   NUMBER;
   BEGIN
      --DCT 16/05/2007 Modificamos todas las tablas est.
      --Cambiamos sperson por  pac_persona.f_estsperson
      v_pasexec := 1;

      IF pcagente IS NULL THEN
         SELECT cdelega
           INTO vcagente
           FROM usuarios
          WHERE cusuari = f_user;
      ELSE
         vcagente := pcagente;
      END IF;

      vcusuari := f_user;
      vfmovimi := f_sysdate;
      vcidioma := pcidioma;
      vcestper := 0;
      vnordide := NULL;
      vtsiglas := NULL;
      v_pasexec := 2;

      SELECT tdocidentif, ctipdoc, csexo, TO_DATE(fnacimi, 'YYYY-MM-DD'),
             TO_DATE(fjubila, 'YYYY-MM-DD'), ctipper, cmutualista,
             TO_DATE(fdefunc, 'YYYY-MM-DD'), sip, tapelli1, tapelli2, tnombre, cprofes,
             cestciv, cpais, totpersona, cidioma, cnacioni, empleado
        INTO vnnumide, vctipide, vcsexper, vfnacimi,
             vfjubila, vtidenti, vcmutualista,
             vfdefunc, vsnip, vtapelli1, vtapelli2, vtnombre, vcprofes,
             vcestciv, vcpais, vtotpersona, vcidioma, vcnacioni, v_esempleado
        FROM int_datos_persona
       WHERE sinterf = psinterf;

      IF vtidenti = 2 THEN   -- juridica
         vtsiglas := vtapelli1;
      END IF;

      IF vcprofes IS NOT NULL THEN
         SELECT COUNT('x')
           INTO v_cont_prof
           FROM profesiones
          WHERE cprofes = vcprofes;

         IF v_cont_prof = 0 THEN
            vcprofes := NULL;
         END IF;
      END IF;

      IF p_modo = 'POL' THEN
         nerror := pac_persona.f_existe_persona(pcempres, vnnumide, vcsexper, vfnacimi,
                                                pficticia_sperson, vsnip, NULL, vctipide);

         IF pficticia_sperson IS NULL THEN
            pficticia_sperson := pac_persona.f_sperson;
         END IF;
      ELSE
         pficticia_sperson := pac_persona.f_estsperson;
      END IF;

      vspereal := NULL;   --pac_persona.f_sperson;
      vsperson := pficticia_sperson;
      v_pasexec := 3;
      verrores := pac_persona.f_set_persona(vcidioma,   --¿ Idioma de los errores
                                            psseguro, vsperson, vspereal, vcagente, vtidenti,   --¿ tipo de persona (física o jurídica)
                                            vctipide,   --¿ tipo de identificación de persona
                                            vnnumide,   -- Número identificativo de la persona.
                                            vcsexper,   -- sexo de la pesona.
                                            vfnacimi,   -- Fecha de nacimiento de la persona
                                            vsnip,   -- snip
                                            vcestper,   --¿ estado
                                            vfjubila,   --¿
                                            vcmutualista,   --¿
                                            vfdefunc, vnordide,   --¿
                                            vcidioma,   --¿Código idioma
                                            vtapelli1,   --¿    Primer apellido
                                            vtapelli2,   --¿    Segundo apellido
                                            vtnombre,   --¿    Nombre de la persona
                                            vtsiglas,   --¿    Siglas persona jurídica
                                            vcprofes,   --¿    Código profesión
                                            vcestciv,   --¿Código estado civil VALOR FIJO = 12
                                            vcpais,   -- pais
                                            pcempres, p_modo   -- bug 11948
                                            , 0, NULL, NULL --bug 18948
                       /* Cambios para solicitudes múltiples : Start */
                                             ,NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL
                       /* Cambios para solicitudes múltiples : End */
						/* CAMBIOS De IAXIS-4538 : Start */
											 ,NULL,
                                             NULL,
                                             NULL,
                                             NULL
						/* CAMBIOS De IAXIS-4538 : End */
                                             );
      --BUG8644-11032009-XVM: s'afegeix el paràmetre cempres
      v_pasexec := 4;

      IF verrores IS NOT NULL THEN
         IF verrores.COUNT > 0 THEN
            RAISE NO_DATA_FOUND;
         END IF;
      END IF;

      IF p_modo = 'EST' THEN
         -- marco el origen como INT
         UPDATE estper_personas
            SET corigen = 'INT',
                trecibido = vtotpersona
          WHERE sperson = vsperson;
      END IF;

      v_pasexec := 5;
      vcsiglas := NULL;
      vtdomici := NULL;
      v_pasexec := 6;

      FOR reg IN (SELECT 1 ctipdir, SUBSTR(tnomvia, 1, 40) tnomvia, nnumvia nnumvia,
                         SUBSTR(tdesc, 1, 15) tcomple, cpostal cpostal, cpoblac cpoblac,
                         cprovin cprovin, totdireccion totdireccion, csiglas ctipvia,
                         (CASE
                             WHEN SUBSTR(ctipdir, 1, 2) = 2 THEN 1
                             ELSE 0
                          END) fdefecto
                    FROM int_datos_direccion
                   WHERE sinterf = psinterf) LOOP
         vcdomici := NULL;
         vtdomici := SUBSTR(NVL(RTRIM(reg.tnomvia || ' ' || reg.nnumvia || ' ' || reg.tcomple),
                                reg.totdireccion),
                            1, 100);
         pac_persona.p_set_direccion(vsperson, vcagente, vcdomici, reg.ctipdir, reg.ctipvia,
                                     reg.tnomvia, reg.nnumvia, reg.tcomple, vtdomici,
                                     reg.cpostal, reg.cpoblac, reg.cprovin, vcusuari,
                                     vfmovimi, vcidioma, verrores, p_modo,   -- bug 11948
                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, NULL,   -- Bug 18940/92686 - 28/09/2011 - AMC
                                     NULL, reg.fdefecto   -- Bug 24780/130907 - 05/12/2012 - AMC
                                                       );

         --inserto en las est
         IF verrores IS NOT NULL THEN
            IF verrores.COUNT > 0 THEN
               RAISE NO_DATA_FOUND;
            END IF;
         END IF;

         IF p_modo = 'EST' THEN
            UPDATE estper_direcciones
               SET corigen = 'INT',
                   trecibido = reg.totdireccion
             WHERE sperson = vsperson
               AND vcdomici = cdomici;
         END IF;
      END LOOP;

      -- marco el origen como INT
      v_pasexec := 7;

      FOR reg IN (SELECT ctipcon ctipcon, tvalcon tvalcon
                    FROM int_datos_contacto
                   WHERE sinterf = psinterf) LOOP
         vsmodcon := NULL;
         vtcomcon := NULL;   --etm 21406
         vcdomici := NULL;
         nerror := pac_persona.f_set_contacto(vsperson, vcagente, reg.ctipcon, vtcomcon,
                                              vsmodcon, reg.tvalcon, vcdomici, NULL, verrores,
                                              p_modo);   -- bug 11948

         IF verrores IS NOT NULL THEN
            IF verrores.COUNT > 0 THEN
               RAISE NO_DATA_FOUND;
            END IF;
         END IF;
      END LOOP;

      v_pasexec := 8;

      FOR reg IN (SELECT ctipban ctipban, cbancar cbancar
                    FROM int_datos_cuenta
                   WHERE sinterf = psinterf) LOOP
         vcnordban := NULL;
         nerror := pac_persona.f_set_ccc(vsperson, vcagente, vcnordban, reg.ctipban,
                                         reg.cbancar, verrores, 1, p_modo);   -- bug 11948

         IF verrores IS NOT NULL THEN
            IF verrores.COUNT > 0 THEN
               RAISE NO_DATA_FOUND;
            END IF;
         END IF;

         IF p_modo = 'EST' THEN
            -- marco el origen como INT
            UPDATE estper_ccc
               SET corigen = 'INT'
             WHERE sperson = vsperson
               AND cnordban = vcnordban;
         END IF;
      END LOOP;

      v_pasexec := 9;

      --JRH 05/2008
      SELECT ctipdoc, tdocidentif
        INTO vctipide, vnnumide
        FROM int_datos_persona
       WHERE sinterf = psinterf;

      nerror := pac_persona.f_set_identificador(vsperson, vcagente, vctipide, vnnumide,
                                                verrores, 0, p_modo,   -- bug 11948
                                                vcidioma);

      IF verrores IS NOT NULL THEN
         IF verrores.COUNT > 0 THEN
            RAISE NO_DATA_FOUND;
         END IF;
      END IF;

      v_pasexec := 10;

      IF vcnacioni IS NOT NULL THEN   -- si este nacionalidad la insertamos
         nerror := pac_persona.f_set_nacionalidad(vsperson, vcagente, vcnacioni, 1, verrores,
                                                  p_modo);

         IF verrores IS NOT NULL THEN
            IF verrores.COUNT > 0 THEN
               RAISE NO_DATA_FOUND;
            END IF;
         END IF;
      END IF;

      --BUG10878-07092009-XPL: Añadimos un registro en la tabla de per_parpersonas para tenerla en cuenta más adelante
      --con el parámetreo de esEmpleado, 0 No, 1 Si
      pac_persona.p_busca_agentes(vsperson, vcagente, vcagente_visio, vcagente_per, p_modo);

      IF p_modo = 'EST' THEN
         BEGIN
            INSERT INTO estper_parpersonas
                        (cparam, sperson, cagente, nvalpar, tvalpar, fvalpar)
                 VALUES ('EMPLEADO', vsperson, vcagente_per, v_esempleado, NULL, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE estper_parpersonas
                  SET nvalpar = v_esempleado
                WHERE cparam = 'EMPLEADO'
                  AND sperson = vsperson
                  AND cagente = vcagente_per;
            WHEN OTHERS THEN
               p_tab_error
                       (f_sysdate, f_user, 'PAC_CON', v_pasexec,
                        'Insertando en estper_parpersonas. Error WHEN OTHERS.  SPERSON = '
                        || vsperson || ' - ' || 'CAGENTE = ' || vcagente || 'esEmpleado = '
                        || v_esempleado,
                        SQLERRM);
         END;
      END IF;

      RETURN verrores;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CON', v_pasexec,
                     'TRASPASO_TABLAS_PER_HOST. Error WHEN OTHERS.  SPERSON hola= '
                     || pficticia_sperson || ' - ' || 'sperson = ' || psinterf,
                     SQLERRM);
         RETURN verrores;
   END traspaso_tablas_per_host;

   PROCEDURE traspaso_tablas_ccc_host(
      psinterf IN NUMBER,
      psperson IN estper_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      porigen IN VARCHAR2 DEFAULT 'EST') IS
      vcnordban      NUMBER;
      verrores       t_ob_error;
      nerror         NUMBER;
      v_pasexec      NUMBER := 0;
   BEGIN
      DELETE FROM estper_ccc
            WHERE sperson = psperson;

      --borro al tabla de cuentas (si ya existian y las recargo con las nuevas
      FOR reg IN (SELECT ctipban ctipban, cbancar cbancar
                    FROM int_datos_cuenta
                   WHERE sinterf = psinterf) LOOP
         vcnordban := NULL;
         v_pasexec := 1;
         nerror := pac_persona.f_set_ccc(psperson, pcagente, vcnordban, reg.ctipban,
                                         reg.cbancar, verrores, 1, porigen);

         IF verrores IS NOT NULL THEN
            IF verrores.COUNT > 0 THEN
               RAISE NO_DATA_FOUND;
            END IF;
         END IF;

         UPDATE estper_ccc
            SET corigen = 'INT'
          WHERE sperson = psperson
            AND cnordban = vcnordban;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CON', v_pasexec,
                     'TRASPASO_TABLAS_CCCHOST. Error WHEN OTHERS.  SPERSON = ' || psperson,
                     SQLERRM);
   END traspaso_tablas_ccc_host;

   FUNCTION f_get_datosper_host(
      psinterf IN VARCHAR2,
      psip OUT VARCHAR2,
      pfnacimi OUT DATE,
      ptdocidentif OUT VARCHAR2,
      psexo OUT NUMBER,
      pctipide OUT NUMBER)
      RETURN NUMBER IS
      vfnacimi       VARCHAR2(20);
   BEGIN
      SELECT fnacimi, tdocidentif, sip, csexo, ctipdoc
        INTO vfnacimi, ptdocidentif, psip, psexo, pctipide
        FROM int_datos_persona
       WHERE sinterf = psinterf;

      BEGIN
         pfnacimi := TO_DATE(vfnacimi, 'dd/mm/yyyy');
      EXCEPTION
         WHEN OTHERS THEN
            pfnacimi := TO_DATE(vfnacimi, 'yyyy-mm-dd');
      END;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 2;   -- No hay datos pero no es un error
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CON', 1,
                     'f_get_datosper_host, Error. psinterf =' || psinterf, SQLERRM);
         RETURN 1;
   END f_get_datosper_host;

-----------------------------------------------------------------------------
/*************************************************************************
                           Traspassa de taules INT  a taules HISINT.( Mantis 9692.#6.)
   return    NUMBER         : 0 -> Traspàs correcte.
                            : 1 -> Error.
*************************************************************************/
   FUNCTION f_traspaso_int_his
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_err          NUMBER;

----------------------------------------------------------------------------
      PROCEDURE p_trasp_contcuentdir IS
      BEGIN
         v_err := 9001682;   -- Error en insertar a HISINT_DATOS_CONTACTO

         INSERT INTO hisint_datos_contacto
            SELECT i.*, f_sysdate()
              FROM int_datos_contacto i;

         v_err := 9001694;   -- Error al esborrar de INT_DATOS_CONTACTO.

         DELETE      int_datos_contacto;

         v_err := 9001683;   -- Error en insertar a HISINT_DATOS_CUENTA

         INSERT INTO hisint_datos_cuenta
            SELECT i.*, f_sysdate()
              FROM int_datos_cuenta i;

         v_err := 9001695;   -- Error al esborrar de INT_DATOS_CUENTA.

         DELETE      int_datos_cuenta;

         v_err := 9001684;   -- Error en insertar a HISINT_DATOS_DIRECCION.

         INSERT INTO hisint_datos_direccion
            SELECT i.*, f_sysdate()
              FROM int_datos_direccion i;

         v_err := 9001696;   -- Error al esborrar de INT_DATOS_DIRECCION.

         DELETE      int_datos_direccion;

         COMMIT;
      END p_trasp_contcuentdir;

----------------------------------------------------------------------------
      PROCEDURE p_trasp_percuaderr IS
      BEGIN
         v_err := 9001685;   -- Error en insertar a hisint_datos_persona

         INSERT INTO hisint_datos_persona
            SELECT sinterf, cmapead, smapead, sip, ctipdoc, tdocidentif, tnombre, tapelli1,
                   tapelli2, csexo, fnacimi, ctipper, cestciv, cprofes, cnae, cpais, cnacioni,
                   fjubila, fdefunc, cmutualista, totpersona, cagente, cidioma, f_sysdate(),
                   empleado
              FROM int_datos_persona i;

         v_err := 9001697;   -- Error al esborrar de int_datos_persona.

         DELETE      int_datos_persona;

         v_err := 9001686;   -- Error en insertar a hisint_datos_sim_prest_cuadro

         INSERT INTO hisint_datos_sim_prest_cuadro
            SELECT i.*, f_sysdate()
              FROM int_datos_sim_prest_cuadro i;

         v_err := 9001698;   -- Error al esborrar de int_datos_sim_prest_cuadro.

         DELETE      int_datos_sim_prest_cuadro;

         v_err := 9001687;   -- Error en insertar a hisint_errores.

         INSERT INTO hisint_errores
            SELECT i.*, f_sysdate()
              FROM int_errores i;

         v_err := 9001699;   -- Error al esborrar de int_errores.

         DELETE      int_errores;

         COMMIT;
      END p_trasp_percuaderr;

----------------------------------------------------------------------------
      PROCEDURE p_trasp_mensres IS
      BEGIN
         v_err := 9001688;   -- Error en insertar a hisint_mensajes

         INSERT INTO hisint_mensajes
            SELECT i.*, f_sysdate()
              FROM int_mensajes i;

         v_err := 9001700;   -- Error al esborrar de int_mensajes.

         DELETE      int_mensajes;

         v_err := 9001689;   -- Error en insertar a hisint_resultado

         INSERT INTO hisint_resultado
            SELECT i.*, f_sysdate()
              FROM int_resultado i;

         v_err := 9001701;   -- Error al esborrar de int_resultado.

         DELETE      int_resultado;

         -- BUG:26170 17/04/2013 AMJ LCOL800-Eliminaci? de taules temporals Ini
         v_err := 9001687;   -- Error en insertar a HISINT_ERRORES

         INSERT INTO hisint_errores
            SELECT i.*, f_sysdate()
              FROM int_errores i;

         v_err := 9001699;   -- Error al borrar de INT_ERRORES.

         DELETE      int_errores;

         --  BUG:26170 17/04/2013 AMJ LCOL800-Eliminaci? de taules temporals Fin
         COMMIT;
      END p_trasp_mensres;
----------------------------------------------------------------------------
   BEGIN
      -- Taules int_datos_contacto, int_datos_cuenta, int_datos_direccion
      p_trasp_contcuentdir;
      -- Taules int_datos_persona, int_datos_sim_prest_cuadro, int_errores
      p_trasp_percuaderr;
      -- Taules int_mensajes, int_resultado
      p_trasp_mensres;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CON.F_TRASPASO_INT_HIS', 1,
                     'error no controlat : ' || SQLCODE, SQLERRM);
         RETURN(v_err);
   END f_traspaso_int_his;

   FUNCTION f_lista_polizas(
      pcempres IN NUMBER,
      psnip IN VARCHAR2,
      pcsituac IN NUMBER,
      vsquery OUT VARCHAR2,
      psinterf OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(200) := 'pac_con.f_lista_polizas';
      vpar           VARCHAR2(200) := 'e=' || pcempres || ' s=' || psnip || ' c=' || pcsituac;
      vpasexec       NUMBER(4);
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 3;
      vsquery :=
         'SELECT  s.npoliza,  d.tnombre TNOM, d.tapelli1 TAPELLI1, d.tapelli2  TAPELLI2,'
         || ' F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,1) producte ,'
         || ' PAC_OPERATIVA_FINV.FF_PROVMAT ( null, s.sseguro, '
         || TO_CHAR(f_sysdate, 'yyyymmdd') || ', null )' || ' saldo, ''EUR'' moneda ,'
         || ' NULL isocode, s.csituac ,  Ff_DESVALORFIJO(61,1,S.CSITUAC) TSITUAC,'
         || ' decode(s.creteni,1,1,( SELECT nvl(max(1),0) FROM ctaseguro WHERE sseguro=s.sseguro AND cesta IS NOT NULL AND nunidad IS NULL ))'
         || ' CRETENI,''AXIS'' origen, s.sproduc'
         || ' FROM seguros s, asegurados a, per_personas p, per_detper d' || ' WHERE P.SNIP = '
         || CHR(39) || psnip || CHR(39)
         || ' AND a.sseguro = s.sseguro AND a.sseguro = s.sseguro'
         || ' AND d.sperson = p.sperson AND p.sperson = a.sperson'
         || ' and d.fmovimi = (select max(d2.fmovimi) from per_detper d2 where d2.sperson=d.sperson)'
         || ' AND a.norden = (select nvl(min(a2.norden),1)'
         || ' from asegurados a2 where a2.sseguro = s.sseguro)';
      vpasexec := 5;

      IF pcsituac IS NOT NULL THEN
         vsquery := vsquery || ' and s.csituac=' || pcsituac;
      END IF;

      RETURN 0;   -- 0 todo ok.
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9002054;
   END f_lista_polizas;

   FUNCTION f_extracto_polizas(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      vsquery OUT VARCHAR2,
      psinterf OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER(10);
      vpasexec       NUMBER(10);
      vnerror        NUMBER(10);
      vccompani      NUMBER := pcempres;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 3;
      vpasexec := 5;
      /*   vlineaini := pcempres || '|' || pnpoliza || '|' || pfini || '|' || pffin;
                                                                                                                                 vresultado := pac_int_online.f_int(vccompani, psinterf, 'I011', vlineaini);
         IF vresultado <> 0 THEN
            RETURN vresultado;   --error
         END IF;
         -- Recupero el error
         p_recupera_error(psinterf, vresultado, perror, vnerror);
         IF vresultado <> 0 THEN
            RETURN vresultado;
         END IF;
         IF NVL(vnerror, 0) <> 0 THEN
            RETURN vnerror;
         END IF;*/
      vsquery :=
         'SELECT to_char(s.fefecto,''rrrrmmdd'') FEFECTO, d.tatribu TMOVIMI, d.catribu CMOVIMI,
          to_char(c.fvalmov,''rrrrmmdd'') FVALMOV, c.imovimi IMPORTE, c.nunidad NPARTICIPACIONES,
          (select sum(imovimi) from ctaseguro where sseguro = s.sseguro and fvalmov like c.fvalmov and nunidad is not null) TOTAL,
          null COTIZACIONES
                     FROM seguros s, ctaseguro c, detvalores d
                     WHERE s.npoliza = '
         || pnpoliza
         || '        and d.cvalor = 83
                     and d.catribu = c.cmovimi
                     and d.cidioma = '
         || pac_md_common.f_get_cxtidioma() || '
                     and s.cempres = ' || pcempres
         || '        and c.nnumlin in (select max(nnumlin) from ctaseguro where sseguro = s.sseguro)
                     and s.sseguro = c.sseguro';
      RETURN 0;   -- 0 todo ok.
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9002055;
   END f_extracto_polizas;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_extracto_polizas_asegurado(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      vsquery OUT VARCHAR2,
      psinterf OUT NUMBER,
      perror OUT VARCHAR2,
      psnip IN VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER(10);
      vpasexec       NUMBER(10);
      vnerror        NUMBER(10);
      vccompani      NUMBER := pcempres;
      vsnip          per_personas.snip%TYPE;
      v_ini          VARCHAR2(100);
      v_fin          VARCHAR2(100);
      v_indexado     NUMBER(1);
      v_wherefechas  VARCHAR2(999);
      v_whereindexa  VARCHAR2(999);
   BEGIN
      vpasexec := 3;

      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      SELECT NVL(f_parproductos_v(MAX(sproduc), 'ES_PRODUCTO_INDEXADO'), 0)
        INTO v_indexado
        FROM seguros
       WHERE npoliza = pnpoliza;

      IF v_indexado = 1 THEN
         v_whereindexa := ' AND (cesta IS NOT NULL or cmovimi IN(0, 53))';
      ELSE
         v_whereindexa := NULL;
      END IF;

      IF psnip IS NOT NULL THEN
         vsnip := psnip;
      ELSE
         SELECT MAX(c.snip)
           INTO vsnip
           FROM seguros a, asegurados b, per_personas c
          WHERE a.npoliza = pnpoliza
            AND b.sseguro = a.sseguro
            AND c.sperson = b.sperson
            AND b.norden = (SELECT MIN(b1.norden)
                              FROM asegurados b1
                             WHERE b1.sseguro = b.sseguro
                               AND ffecfin IS NULL);

         IF vsnip IS NULL THEN
            SELECT MAX(c.snip)
              INTO vsnip
              FROM seguros a, asegurados b, per_personas c
             WHERE a.npoliza = pnpoliza
               AND b.sseguro = a.sseguro
               AND c.sperson = b.sperson
               AND b.norden = (SELECT MIN(b1.norden)
                                 FROM asegurados b1
                                WHERE b1.sseguro = b.sseguro);
         END IF;
      END IF;

      IF pfini IS NOT NULL THEN
         v_ini := 'to_date(' || CHR(39) || TO_CHAR(pfini, 'dd-mm-yyyy') || CHR(39) || ','
                  || CHR(39) || 'dd-mm-yyyy' || CHR(39) || ')';
      END IF;

      IF pffin IS NOT NULL THEN
         v_fin := 'to_date(' || CHR(39) || TO_CHAR(pffin, 'dd-mm-yyyy') || CHR(39) || ','
                  || CHR(39) || 'dd-mm-yyyy' || CHR(39) || ')';
      END IF;

      v_wherefechas := NULL;

      IF v_ini IS NOT NULL THEN
         v_wherefechas := v_wherefechas || ' and fvalmov>=' || v_ini;
      END IF;

      IF v_fin IS NOT NULL THEN
         v_wherefechas := v_wherefechas || ' and fvalmov<=' || v_fin;
      END IF;

      vpasexec := 5;
      vsquery :=
         'SELECT to_char(s.fefecto,''rrrrmmdd'') FEFECTO, d.tatribu TMOVIMI, d.catribu CMOVIMI,'
         || ' to_char(c.fvalmov,''rrrrmmdd'') FVALMOV, c.imovimi IMPORTE, c.nunidad NPARTICIPACIONES,'
         || ' (select sum(nunidad) from ctaseguro where sseguro = s.sseguro and NNUMLIN <= c.nnumlin and nunidad is not null) TOTAL,'
         || ' (SELECT max(iuniact) FROM tabvalces WHERE ccesta = c.cesta AND fvalor = TRUNC(c.fvalmov) ) COTIZACIONES,'
         || ' decode(pac_propio.f_esta_reducida(s.sseguro),1,1,0) reducida,'
         || ' s.sproduc, to_char(c.ffecmov,''rrrrmmdd'')  FFECMOV'
         || ' FROM seguros s, ctaseguro c, detvalores d, asegurados e, per_personas p'
         || ' WHERE s.npoliza = ' || pnpoliza || '  and d.cvalor = 83'
         || '  and d.catribu = c.cmovimi' || '  and d.cidioma = '
         || pac_md_common.f_get_cxtidioma() || '  and s.cempres = '
         || pcempres   --         ||'  and c.nnumlin in (select max(nnumlin) from ctaseguro where sseguro = s.sseguro'
                       --         ||' '||v_wherefechas
                       --         ||' '||v_whereindexa
                       --         ||'  )'
         || '  and s.sseguro = c.sseguro' || '  and p.snip = ' || CHR(39) || vsnip || CHR(39)
         || '  AND e.sseguro = s.sseguro' || '  and p.sperson = e.sperson' || ' '
         || v_wherefechas || ' ' || v_whereindexa || ' order by c.ffecmov desc';
      RETURN 0;   -- 0 todo ok.
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9002055;
   END f_extracto_polizas_asegurado;

   FUNCTION f_detalle_poliza(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      psquery OUT VARCHAR2,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER(10);
      vpasexec       NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pnpoliza;
      vsquery        VARCHAR(1000);
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 3;
      vpasexec := 5;
      --      vlineaini := pnpoliza;
      --  vresultado := pac_int_online.f_int(vccompani, psinterf, 'I012', vlineaini);
      psquery :=
         'SELECT s.npoliza, ''AXIS'' origen, F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,1) PRODUCTO, ''EUR'' MONEDA,
        to_char(s.fefecto,''rrrrmmdd'') FEFECTO, null ISOCODE, to_char(s.fvencim,''rrrrmmdd'') FVENCIM,
        d.tnombre TNOMTOM, d.tapelli1 TAPELLI1TOM, d.tapelli2  TAPELLI2TOM,
        d2.tnombre TNOMASEG, d2.tapelli1 TAPELLI1ASE, d2.tapelli2  TAPELLI2ASE, (select imovimi from ctaseguro
        where sseguro = s.sseguro and cmovimi = 0 and nnumlin in (select max(nnumlin) from ctaseguro where sseguro = s.sseguro
        and cmovimi = 0)) ICAPITAL, s.cbancar CBANCAR, s.iprianu IPRIMA,
        decode(length(nrenova),3, substr(nrenova,1,1),4,substr(nrenova,1,2)) NRENOVA, ff_desvalorfijo(62,1,s.crevali) TREVALI , s.crevali,
        s.irevali IREVALI, to_char(s.fcarpro,''rrrrmmdd'') FCARPRO,
        s.cforpag CFORPAG, ff_desvalorfijo(17,1,s.cforpag) TFORPAG,
        s.csituac, ff_desvalorfijo(61,1,  s.csituac) TSITUAC,
        decode(s.cramo,31,decode(decode(s.cmodali,25,1,26,1,0),1,
              (SELECT ttitulo FROM titulopro WHERE cramo = s.cramo AND cmodali = s.cmodali and cidioma = '
         || pac_md_common.f_get_cxtidioma() || ')
              ,' || CHR(39) || CHR(39) || '),' || CHR(39) || CHR(39)
         || ') TFONDO,
        1 NPARFONDO, 1 VLIQUIDA, 1 ICAPITALMUERTE, 1 ITOTAL
  FROM seguros s, tomadores t, per_personas p, per_detper d, asegurados a, per_personas p2, per_detper d2
 WHERE s.npoliza = '
         || pnpoliza
         || '
   AND p.sperson = t.sperson
   and t.nordtom = 1
   and t.sseguro = s.sseguro
   AND d.sperson = p.sperson
   and d.fmovimi = (select max(dd.fmovimi) from per_detper dd where dd.sperson=d.sperson)
   and p2.sperson = a.sperson
   and a.norden = 1
   and a.sseguro = s.sseguro
   and d2.fmovimi = (select max(dd2.fmovimi) from per_detper dd2 where dd2.sperson=d2.sperson)
   AND d2.sperson = p2.sperson';
      RETURN 0;   -- 0 todo ok.
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9002055;
   END f_detalle_poliza;

   -- Bug 0021190 - 10/04/2012 - JMF
   FUNCTION f_detalle_poliza_asegurado(
      pnpoliza IN NUMBER,
      psinterf OUT NUMBER,
      psquery OUT VARCHAR2,
      perror OUT VARCHAR2,
      psnip IN VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(500) := 'pac_con.f_detalle_poliza_asegurado';
      vpar           VARCHAR2(500) := 'pol=' || pnpoliza || ' snip=' || psnip;
      vresultado     NUMBER(10);
      vpasexec       NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pnpoliza;
      vsnip          per_personas.snip%TYPE;
      v_indexado     NUMBER(1);
      v_cagrpro      productos.cagrpro%TYPE;
      v_garantits    NUMBER(1);
      v_seguro       seguros.sseguro%TYPE;
      v_saldo        NUMBER;
      v_emp          seguros.cempres%TYPE;
      v_ret          seguros.creteni%TYPE;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 3;

      SELECT a.sseguro, NVL(f_parproductos_v(a.sproduc, 'ES_PRODUCTO_INDEXADO'), 0),
             b.cagrpro, a.cempres, a.creteni
        INTO v_seguro, v_indexado,
             v_cagrpro, v_emp, v_ret
        FROM seguros a, productos b
       WHERE a.npoliza = pnpoliza
         AND b.sproduc = a.sproduc;

      IF v_indexado = 0
         AND v_cagrpro = 2 THEN
         v_garantits := 1;
      ELSE
         v_garantits := 0;
      END IF;

      IF psnip IS NOT NULL THEN
         vsnip := psnip;
      ELSE
         SELECT MAX(c.snip)
           INTO vsnip
           FROM seguros a, asegurados b, per_personas c
          WHERE a.npoliza = pnpoliza
            AND b.sseguro = a.sseguro
            AND c.sperson = b.sperson
            AND b.norden = (SELECT MIN(b1.norden)
                              FROM asegurados b1
                             WHERE b1.sseguro = b.sseguro
                               AND ffecfin IS NULL);

         IF vsnip IS NULL THEN
            SELECT MAX(c.snip)
              INTO vsnip
              FROM seguros a, asegurados b, per_personas c
             WHERE a.npoliza = pnpoliza
               AND b.sseguro = a.sseguro
               AND c.sperson = b.sperson
               AND b.norden = (SELECT MIN(b1.norden)
                                 FROM asegurados b1
                                WHERE b1.sseguro = b.sseguro);
         END IF;
      END IF;

      v_saldo := pac_operativa_finv.ff_provmat(NULL, v_seguro, TO_CHAR(f_sysdate, 'yyyymmdd'),
                                               NULL);

      IF v_saldo IS NOT NULL THEN
         v_saldo := v_saldo * 100;
      END IF;

      v_ret := 0;

      IF v_ret = 1 THEN
         --v_ret := 6;
         v_ret := 1;
      ELSE
         vnerror := pac_operativa_finv.f_op_pdtes_valorar(v_emp, v_seguro, 1, psquery);

         IF psquery IS NOT NULL THEN
            psquery := NULL;
            --v_ret := 6;
            v_ret := 1;
         ELSE
            v_ret := 0;
         END IF;
      END IF;

      vpasexec := 5;
      --  vlineaini := pnpoliza;
      --  vresultado := pac_int_online.f_int(vccompani, psinterf, 'I012', vlineaini);
      psquery :=
         'SELECT (select nvl(max(polissa_ini),s.npoliza) from cnvpolizas where sseguro=s.SSEGURO) npoliza,'
         || ' ''AXIS'' origen, F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,1) PRODUCTO, ''EUR'' MONEDA,'
         || ' to_char(s.fefecto,''rrrrmmdd'') FEFECTO, null ISOCODE, to_char(s.fvencim,''rrrrmmdd'') FVENCIM,'
         || ' d.tnombre TNOMTOM, d.tapelli1 TAPELLI1TOM, d.tapelli2  TAPELLI2TOM,'
         || ' d2.tnombre TNOMASEG, d2.tapelli1 TAPELLI1ASE, d2.tapelli2  TAPELLI2ASE, (select imovimi from ctaseguro'
         || ' where sseguro = s.sseguro and cmovimi = 0 and nnumlin in (select max(nnumlin) from ctaseguro where sseguro = s.sseguro'
         || ' and cmovimi = 0)) ICAPITAL, s.cbancar CBANCAR,'
         || ' (select icapital from garanseg gg where gg.cgarant=48 and gg.sseguro=s.sseguro'
         || ' and gg.nmovimi = (select max(gg2.nmovimi) from garanseg gg2 where gg2.cgarant=48 and gg2.sseguro=s.sseguro)'
         || ' ) IPRIMA,'
         || ' decode(length(nrenova),3, substr(nrenova,1,1),4,substr(nrenova,1,2)) NRENOVA,'
         || ' ff_desvalorfijo(62,1,s.crevali) TREVALI , s.crevali,'
         || ' s.irevali IREVALI, to_char(s.fcarpro,''rrrrmmdd'') FCARPRO,'
         || ' s.cforpag CFORPAG, ff_desvalorfijo(17,1,s.cforpag) TFORPAG,'   --|| ' nvl('||chr(39)||v_ret||chr(39)||',s.csituac) CSITUAC, ff_desvalorfijo(61,1,  s.csituac) TSITUAC,'
         || ' s.csituac CSITUAC, ff_desvalorfijo(61,1,  s.csituac) TSITUAC,'
         || ' decode(s.cramo,31,decode(decode(s.cmodali,25,1,26,1,0),1,'
         || ' (SELECT ttitulo FROM titulopro WHERE cramo = s.cramo AND cmodali = s.cmodali'
         || ' and cidioma = ' || pac_md_common.f_get_cxtidioma() || ') ,' || CHR(39) || CHR(39)
         || '),' || CHR(39) || CHR(39) || ') TFONDO,'
         || ' 1 NPARFONDO, 1 VLIQUIDA, 1 ICAPITALMUERTE, ' || v_saldo || '/100 ITOTAL,'
         || ' decode(pac_propio.f_esta_reducida(s.sseguro),1,1,0) reducida, s.sproduc, '
         || v_garantits || ' garantits,'
         || ' (SELECT SUM( nvl(nunidad,0) ) FROM ctaseguro WHERE sseguro = s.sseguro AND nvl(nunidad,0)>0) parts,'
         --|| ' (SELECT SUM( nvl(nunidad,0) ) FROM ctaseguro WHERE sseguro = s.sseguro AND nunidad IS NOT NULL) net_contributions,'
         || ' (select  sum(decode(cmovimi,51,-1,31,-1,33,-1,34,-1,53,-1,19,-1,1)*nvl(imovimi,0))'
         || ' from   ctaseguro' || ' where (' || '       cmovimi in (1,2,4,8,51) '
         || '       OR  ' || '       (cmovimi IN(31, 33, 34, 53) AND NVL(cmovanu,0)=0)'
         || '       OR' || '       cmovimi in (9,19) ' || '       )  '
         || ' and  sseguro=s.sseguro) net_contributions, '
         || ' (SELECT icapital FROM garanseg ra WHERE ra.cgarant=60 AND ra.sseguro=s.sseguro'
         || ' AND ra.nmovimi = (SELECT MAX(ra2.nmovimi) FROM garanseg ra2 WHERE ra2.cgarant=60 AND ra2.sseguro=s.sseguro)) risk_amount,'
         || ' ' || v_ret || ' RETEN'
         || ' FROM seguros s, tomadores t, per_personas p, per_detper d, asegurados a, per_personas p2, per_detper d2'
         || ' WHERE s.npoliza = ' || pnpoliza || ' AND p.sperson = t.sperson'
         || ' and t.nordtom = 1' || ' and t.sseguro = s.sseguro'
         || ' AND d.sperson = p.sperson'
         || ' and d.fmovimi = (select max(dd.fmovimi) from per_detper dd where dd.sperson=d.sperson)'
         || ' and p2.sperson = a.sperson' || ' and p2.SNIP = ' || CHR(39) || vsnip || CHR(39)
         || ' and a.norden = 1' || ' and a.sseguro = s.sseguro'
         || ' and d2.fmovimi = (select max(dd2.fmovimi) from per_detper dd2 where dd2.sperson=d2.sperson)'
         || ' AND d2.sperson = p2.sperson';
      RETURN 0;   -- 0 todo ok.
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9002055;
   END f_detalle_poliza_asegurado;

   FUNCTION f_get_listado_doc(
      pempresa IN NUMBER,
      psip IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
      vterminal      terminales.cterminal%TYPE;
      vnpoliza       seguros.npoliza%TYPE;
      vncertif       seguros.ncertif%TYPE;
      vnpolcia       VARCHAR2(20);
   --vsnip          estper_personas.snip%TYPE;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      BEGIN
         SELECT npoliza, ncertif, pac_propio.f_calc_contrato_interno(cagente, psseguro)
           INTO vnpoliza, vncertif, vnpolcia
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            vnpoliza := NULL;
            vncertif := NULL;
            vnpolcia := NULL;
      END;

      vlineaini := pempresa || '|' || psip || '|' || psseguro || '|' || pnmovimi || '|'
                   || vnpoliza || '|' || vncertif || '|' || vnpolcia;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I014', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      RETURN 0;   -- ok
   END f_get_listado_doc;

   FUNCTION f_get_detalle_doc(
      pempresa IN NUMBER,
      pid IN VARCHAR2,
      pdestino IN VARCHAR2,
      pnombre IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
      vterminal      terminales.cterminal%TYPE;
   --vsnip          estper_personas.snip%TYPE;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pempresa || '|' || pusuario || '|' || pid || '|' || pdestino || '|'
                   || pnombre;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I015', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      RETURN 0;   -- ok
   END f_get_detalle_doc;

   FUNCTION f_get_datoscontratos(
      pempresa IN NUMBER,
      psperson IN VARCHAR2,
      pterminal IN VARCHAR2,
      poperador IN VARCHAR2,
      poficina IN NUMBER,
      porigen IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
      vterminal      terminales.cterminal%TYPE;
      vsnip          estper_personas.snip%TYPE;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      -- recupero el snip
      IF NVL(porigen, '*') = 'EST' THEN
         SELECT snip
           INTO vsnip
           FROM estper_personas
          WHERE sperson = psperson;
      ELSE
         SELECT snip
           INTO vsnip
           FROM per_personas
          WHERE sperson = psperson;
      END IF;

      vlineaini := pempresa || '|' || vsnip || '|' || poperador || '|' || poficina || '|'
                   || pterminal;
      vresultado := pac_int_online.f_int(vccompani, psinterf, 'I013', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      RETURN 0;   -- ok
   END f_get_datoscontratos;

   -- Bug 14365 - 01/09/2010 - FAL - Alta de personas en el C.I
   FUNCTION f_alta_persona(
      pempresa IN NUMBER,
      psip IN VARCHAR2,
      pterminal IN VARCHAR2,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pobligarepr IN NUMBER DEFAULT 0,
      paltamod IN VARCHAR2 DEFAULT 'ALTA',
      pdigitoide IN NUMBER DEFAULT 0,   -- BUG 21270/106644 - 08/02/2012 - JMP
      penviopers IN VARCHAR2 DEFAULT NULL,
      pdiferido IN NUMBER DEFAULT 0)   -- ini BUG 0026318 -- ETM -- 28/05/2013
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
      vnumerr        NUMBER;
      v_interficie   VARCHAR2(100) := 'I017';
      vrepr          NUMBER := 0;
      -----ptipopago      NUMBER := 10;  -- bug 26513 -- ECP -- 27/03/2013
      ptipopago      NUMBER := 99;
      vreprocesar    NUMBER := 0;
      v_cnoenviar    int_personas_excep.cnoenviar%TYPE;
      vdigitoide     VARCHAR2(1) := NULL;
      v_host         VARCHAR2(100);
   BEGIN
      IF (pdiferido != 2) THEN
         -- BUG 21431/107888 - 21/02/2012 - JMP - Se añade control de excepciones de envío
         BEGIN
            SELECT cnoenviar
              INTO v_cnoenviar
              FROM per_personas p, int_personas_excep e
             WHERE p.sperson = psip
               AND e.cempres = pempresa
               AND e.cmapead = v_interficie
               AND e.ctipide = p.ctipide;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_cnoenviar := 0;
         END;

         IF v_cnoenviar = 1 THEN
            RETURN 0;
         END IF;

         -- FIN BUG 21431/107888 - 21/02/2012 - JMP - Se añade control de excepciones de envío
         IF psinterf IS NULL THEN
            pac_int_online.p_inicializar_sinterf;
            psinterf := pac_int_online.f_obtener_sinterf;
         END IF;

         v_host := penviopers;

         IF penviopers IS NULL THEN
               v_host := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'DUPL_DEUDOR_HOST');
         END IF;

         vlineaini := pempresa || '|' || psip || '|' || paltamod || '|' || pterminal || '|'
                      || pusuario || '|' || pdigitoide || '|' || v_host;


         vresultado := pac_int_online.f_int(vccompani, psinterf, 'I017', vlineaini);

         IF vresultado <> 0 THEN
            --BUG 20211 - 09/01/2012 - JRB - Si hay que reprocesar todos INT_REPROCESAR = 1 si filtra INT_REPROCESAR = 2
            IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
               AND vrepr = 0 THEN
               vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                            perror, f_user, psip, NULL, 10);
               vrepr := 1;

               IF vnumerr <> 0 THEN
                  perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
                  RETURN vresultado;   --error de interfaz
               ELSE
                  perror := NULL;
               END IF;
            ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
               IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11
                  OR pobligarepr = 1 THEN
                  IF pobligarepr = 1 THEN
                     vreprocesar := 1;
                  ELSE
                     vnumerr := f_accion_reproceso(psip, NULL, ptipopago, pempresa,
                                                   vreprocesar);
                  END IF;

                  IF vrepr = 0
                     AND vreprocesar = 1 THEN
                     vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa,
                                                  vlineaini, perror, f_user, psip, NULL,
                                                  ptipopago);
                     vrepr := 1;

                     IF vnumerr <> 0 THEN
                        --RETURN vresultado;   --error
                        perror := f_axis_literales(9903126, pac_md_common.f_get_cxtidioma());
                        RETURN 9903126;
                     ELSE
                        perror := NULL;
                     END IF;
                  ELSE
                     perror := f_axis_literales(9903126, pac_md_common.f_get_cxtidioma());
                     RETURN 9903126;
                  END IF;
               ELSE
                  IF vrepr = 0 THEN
                     vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa,
                                                  vlineaini, perror, f_user, psip, NULL, 10);
                     vrepr := 1;

                     IF vnumerr <> 0 THEN
                        --RETURN vresultado;   --error
                        RETURN 9903126;
                     ELSE
                        perror := NULL;
                     END IF;
                  END IF;
               END IF;
            ELSE
               perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
               RETURN vresultado;   --error de interfaz
            END IF;
         END IF;

         -- Recupero el error
         p_recupera_error(psinterf, vresultado, perror, vnerror);

         IF vresultado <> 0 THEN
            IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
               AND vrepr = 0 THEN
               vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                            perror, f_user, psip, NULL, 10);
               vrepr := 1;

               IF vnumerr <> 0 THEN
                  RETURN vresultado;   --error
               ELSE
                  perror := NULL;
               END IF;
            ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
               IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11
                  OR pobligarepr = 1 THEN
                  IF pobligarepr = 1 THEN
                     vreprocesar := 1;
                  ELSE
                     vnumerr := f_accion_reproceso(psip, NULL, ptipopago, pempresa,
                                                   vreprocesar);
                  END IF;

                  IF vrepr = 0
                     AND vreprocesar = 1 THEN
                     vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa,
                                                  vlineaini, perror, f_user, psip, NULL,
                                                  ptipopago);
                     vrepr := 1;

                     IF vnumerr <> 0 THEN
                        --RETURN vresultado;   --error
                        perror := f_axis_literales(9903126, pac_md_common.f_get_cxtidioma());
                        RETURN 9903126;
                     ELSE
                        perror := NULL;
                     END IF;
                  ELSE
                     perror := f_axis_literales(9903126, pac_md_common.f_get_cxtidioma());
                     RETURN 9903126;
                  END IF;
               ELSE
                  IF vrepr = 0 THEN
                     vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa,
                                                  vlineaini, perror, f_user, psip, NULL, 10);
                     vrepr := 1;

                     IF vnumerr <> 0 THEN
                        --RETURN vresultado;   --error
                        RETURN 9903126;
                     ELSE
                        perror := NULL;
                     END IF;
                  END IF;
               END IF;
            ELSE
               RETURN vresultado;   --error
            END IF;
         END IF;

         IF vnerror <> 0 THEN
            IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
               AND vrepr = 0 THEN
               vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                            perror, f_user, psip, NULL, 10);
               vrepr := 1;

               IF vnumerr <> 0 THEN
                  RETURN vnerror;   -- error de la interficie
               ELSE
                  perror := NULL;
               END IF;
            ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
               IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11
                  OR pobligarepr = 1 THEN
                  IF pobligarepr = 1 THEN
                     vreprocesar := 1;
                  ELSE
                     vnumerr := f_accion_reproceso(psip, NULL, ptipopago, pempresa,
                                                   vreprocesar);
                  END IF;

                  IF vrepr = 0
                     AND vreprocesar = 1 THEN
                     vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa,
                                                  vlineaini, perror, f_user, psip, NULL,
                                                  ptipopago);
                     vrepr := 1;

                     IF vnumerr <> 0 THEN
                        --RETURN vresultado;   --error
                        perror := f_axis_literales(9903126, pac_md_common.f_get_cxtidioma());
                        RETURN 9903126;
                     ELSE
                        perror := NULL;
                     END IF;
                  ELSE
                     perror := f_axis_literales(9903126, pac_md_common.f_get_cxtidioma());
                     RETURN 9903126;
                  END IF;
               ELSE
                  IF vrepr = 0 THEN
                     vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa,
                                                  vlineaini, perror, f_user, psip, NULL, 10);
                     vrepr := 1;

                     IF vnumerr <> 0 THEN
                        --RETURN vresultado;   --error
                        RETURN 9903126;
                     ELSE
                        perror := NULL;
                     END IF;
                  END IF;
               END IF;
            ELSE
               RETURN vnerror;   -- error de la interficie
            END IF;
         END IF;

         --BUG 21479 - 27/02/2012 - JRB - Cuando sea una modificación y exista RUT, enviar modificación del RUT
         IF paltamod = 'MOD'
	    -- IAXIS-5154 - SWAP - 09/09/2019 - Se ajusta el 0 por null
            AND pdigitoide is null  THEN
            BEGIN
               SELECT tdigitoide
                 INTO vdigitoide
                 FROM per_personas p
                WHERE p.sperson = psip;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vdigitoide := NULL;
            END;

            IF vdigitoide IS NOT NULL THEN
               psinterf := NULL;
			   /* Cambios de Iaxis-4521 : start */
               vnerror := f_alta_persona(pempresa, psip, pterminal, psinterf, perror,
                                         pusuario, pobligarepr, paltamod, vdigitoide);
			   /* Cambios de Iaxis-4521 : end */										 
            END IF;
         END IF;
      ELSE   -- Si el parámetro es 2 no se envía la persona y se registra en la tabla de procesos diferidos.
         INSERT INTO int_envio_persdif
                     (empresa, sip, terminal, sinterf, merror, usuario, obligarepr,
                      altamod, digitoide, enviopers, procesado)
              VALUES (pempresa, psip, pterminal, psinterf, perror, pusuario, pobligarepr,
                      paltamod, pdigitoide, penviopers, 0);
      END IF;

      RETURN 0;   -- ok
   END f_alta_persona;

   -- Fi Bug 14365 - 01/09/2010 - FAL

   -- Bug 14365 - 26/08/2010 - SRA - función que devuelve un cursor con todas las equivalencias entre códigos origen de la empresa
   -- y su código equivalente en AXIS
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion de mensajes.
   FUNCTION f_obtener_valores_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(200) := 'PAC_CON.f_obtener_valores_axis';
      vparam         VARCHAR2(500) := 'parámetros - pemp: ' || pemp || ' - pcampo: ' || pcampo;
      vpasexec       NUMBER := 0;
      cur_vvalaxis   sys_refcursor;
   BEGIN
      vpasexec := 1;

      BEGIN
         cur_vvalaxis := pac_int_online.f_obtener_valores_axis(pemp, pcampo);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_object_error;
      END;

      vpasexec := 2;
      RETURN cur_vvalaxis;
   EXCEPTION
      -- BUG 21546_108727- 23/02/2012 -JLTS- Se eliminan las excepciones
      WHEN OTHERS THEN
         OPEN cur_vvalaxis FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalaxis;
   END f_obtener_valores_axis;

   -- Bug 14365 - 26/08/2010 - SRA - función que devuelve un cursor con todas las equivalencias entre códigos origen en AXIS
   -- y su código equivalente en la empresa
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion de mensajes.
   FUNCTION f_obtener_valores_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(200) := 'PAC_CON.f_obtener_valores_emp';
      vparam         VARCHAR2(500) := 'parámetros - pemp: ' || pemp || ' - pcampo: ' || pcampo;
      vpasexec       NUMBER := 0;
      cur_vvalemp    sys_refcursor;
   BEGIN
      vpasexec := 1;

      BEGIN
         cur_vvalemp := pac_int_online.f_obtener_valores_emp(pemp, pcampo);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_object_error;
      END;

      vpasexec := 2;
      RETURN cur_vvalemp;
   EXCEPTION
      -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion de mensajes.
      WHEN e_object_error THEN
         OPEN cur_vvalemp FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalemp;
      WHEN OTHERS THEN
         OPEN cur_vvalemp FOR
            SELECT NULL AS co, NULL AS ce
              FROM DUAL;

         RETURN cur_vvalemp;
   END f_obtener_valores_emp;

   --Ini Bug.: 17247 - ICV - 07/02/2011
   /*************************************************************************
                        Función que se llamará al emitir un pago para comunicarse con AXISCONNECT
      pempres number : Codigo de empresa
      paccion number : Acción con la que se llama (1.- Emisión, 2.- Consulta, 3.- Actualización)
      ptipopago number : Tipo de pago (1- Pago de siniestro, 2- Pago de prestación de renta, 3- Pago de renta, 4- Emisión recibo)
      pidPago number: Identificador del pago (srecren  (2,3), sidepag (1), nrecibo (4))
      pidmovimiento number: Número de movimiento (nmovpag de movpagren para tipo (2,3), nmovpag de sin tramita_movpago para tipo 1, smovrec de movrecibos para tipo 4)
      pnumevento number : Número de evento
      pcoderrorin : si hay error al cobrar en AXIS
      return    NUMBER         : 0 -> Traspàs correcte.
                               : 1 -> Error.
   *************************************************************************/
   FUNCTION f_emision_pagorec(
      pempresa IN NUMBER,
      paccion IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pidmovimiento IN NUMBER,
      pterminal IN VARCHAR2,
      pemitido OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pnumevento IN NUMBER DEFAULT NULL,
      pcoderrorin IN NUMBER DEFAULT NULL,
      pdescerrorin IN VARCHAR2 DEFAULT NULL,
      ppasocuenta IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vresultado2    NUMBER(10);
      vnerror        NUMBER(10);
      vnumerr        NUMBER(10);
      --vccompani      NUMBER := pempresa;
      v_interficie   VARCHAR2(100);
      vrepr          NUMBER(1) := 0;
      vreprocesar    NUMBER(1) := 0;
      v_asient       NUMBER;
      --Version 28
      l_idpago       NUMBER;
      l_idmovimi     NUMBER;
      --Version 28
   BEGIN
	
	  /* Cambios de 4711 : Starts ***
	  
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      -- Bug 25558 - APD - 25/01/2013 - se llama a la funcion f_contabiliza_interf para
      -- insertar los datos en la tabla contab_asient_interf necesarios para el map I021S
      vnumerr := pac_cuadre_adm.f_contabiliza_interf(psinterf, ptipopago, pidpago, pempresa,
                                                     TRUNC(f_sysdate), pidmovimiento);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      SELECT COUNT(1)
        INTO v_asient
        FROM contab_asient_interf
       WHERE sinterf = psinterf;

      IF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
         AND v_asient = 0 THEN
         RETURN 0;
      END IF;
      --Version 28.

      BEGIN
      SELECT DISTINCT c.idpago,c.idmov
        INTO l_idpago,l_idmovimi
        FROM contab_asient_interf c
       WHERE sinterf = psinterf
       and idpago = pidpago||pidmovimiento;

        EXCEPTION WHEN no_data_found THEN

        SELECT DISTINCT c.idpago,c.idmov
        INTO l_idpago,l_idmovimi
        FROM contab_asient_interf c
       WHERE sinterf = psinterf;
               END;

       P_CONTROL_ERROR('LIZCO','PAC_CON select 2',psinterf|| ' pidpago: ' || pidpago||pidmovimiento);

      -- fin Bug 25558 - APD - 25/01/2013
      v_interficie := pac_parametros.f_parempresa_t(pempresa, 'INTERFICIE_ERP');   --Bug.: 19887
      vlineaini := pempresa || '|' || ptipopago || '|' || paccion || '|' || l_idpago || '|'
                   || l_idmovimi || '|' || pterminal || '|' || pusuario || '|' || pnumevento
                   || '|' || pcoderrorin || '|' || pdescerrorin || '|' || ppasocuenta;
      vresultado := pac_int_online.f_int(pempresa, psinterf, v_interficie, vlineaini);
      --Version 28.
      IF Vresultado <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vresultado;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               --RETURN vresultado;   --error de interfaz
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vresultado;   --error
         END IF;
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado2, perror, vnerror);

      IF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
         AND(NVL(vresultado, 1) <> 0
             OR NVL(vresultado2, 1) <> 0
             OR NVL(vnerror, 1) <> 0) THEN
         vnumerr := f_cont_reproceso(psinterf, 2);
      ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
            AND NVL(vresultado2, 1) = 0 THEN
         vnumerr := f_cont_reproceso(psinterf, 1);
      END IF;

      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vresultado;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vresultado;   --error
         END IF;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vnerror;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vnerror;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2
               AND vrepr = 0 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vnerror;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vnerror;   --error
         END IF;
      END IF;

      BEGIN
         SELECT tparam
           INTO pemitido
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'EMITIDO';
      EXCEPTION
         WHEN OTHERS THEN
            pemitido := NULL;
      END;
	 
	  *** Cambios de 4711 : Ends ***/
	  
      RETURN 0;   --
   END f_emision_pagorec;

   --Fin Bug.: 17247
   --IAXIS 4504 Creacion de funcion de conexion a sap contabilidad 
     /*************************************************************************
      Función que se llamará al emitir un pago para comunicarse con AXISCONNECT
      pempres number : Codigo de empresa
      paccion number : Acción con la que se llama (1.- Emisión, 2.- Consulta, 3.- Actualización)
      ptipopago number : Tipo de pago (1- Pago de siniestro, 2- Pago de prestación de renta, 3- Pago de renta, 4- Emisión recibo)
      pidPago number: Identificador del pago (srecren  (2,3), sidepag (1), nrecibo (4))
      pidmovimiento number: Número de movimiento (nmovpag de movpagren para tipo (2,3), nmovpag de sin tramita_movpago para tipo 1, smovrec de movrecibos para tipo 4)
      pnumevento number : Número de evento
      pcoderrorin : si hay error al cobrar en AXIS
      return    NUMBER         : 0 -> Traspàs correcte.
                               : 1 -> Error.
   *************************************************************************/
   FUNCTION f_contab_siniestro(
      pempresa IN NUMBER,
      paccion IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pidmovimiento IN NUMBER,
      pterminal IN VARCHAR2,
      pemitido OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pnumevento IN NUMBER DEFAULT NULL,
      pcoderrorin IN NUMBER DEFAULT NULL,
      pdescerrorin IN VARCHAR2 DEFAULT NULL,
      ppasocuenta IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vresultado2    NUMBER(10);
      vnerror        NUMBER(10);
      vnumerr        NUMBER(10);
      v_interficie   VARCHAR2(100);
      vrepr          NUMBER(1) := 0;
      vreprocesar    NUMBER(1) := 0;
      v_asient       NUMBER;
      l_idpago       NUMBER;
      l_idmovimi     NUMBER;
   BEGIN
	  
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      -- insertar los datos en la tabla contab_asient_interf necesarios para el map I021S
      vnumerr := pac_cuadre_adm.f_conta_int_sini(psinterf, ptipopago, pidpago, pempresa,
                                                     TRUNC(f_sysdate), pidmovimiento);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      SELECT COUNT(1)
        INTO v_asient
        FROM contab_asient_interf
       WHERE sinterf = psinterf;

      IF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
         AND v_asient = 0 THEN
         RETURN 0;
      END IF;
      --Version 28.

      BEGIN
      SELECT DISTINCT c.idpago,c.idmov
        INTO l_idpago,l_idmovimi
        FROM contab_asient_interf c
       WHERE sinterf = psinterf
       and idpago = pidpago;

        EXCEPTION WHEN no_data_found THEN

        SELECT DISTINCT c.idpago,c.idmov
        INTO l_idpago,l_idmovimi
        FROM contab_asient_interf c
       WHERE sinterf = psinterf;
               END;
      v_interficie := pac_parametros.f_parempresa_t(pempresa, 'INTERFICIE_ERP');   --Bug.: 19887
      vlineaini := pempresa || '|' || ptipopago || '|' || paccion || '|' || l_idpago || '|'
                   || l_idmovimi || '|' || pterminal || '|' || pusuario || '|' || pnumevento
                   || '|' || pcoderrorin || '|' || pdescerrorin || '|' || ppasocuenta;
      vresultado := pac_int_online.f_int(pempresa, psinterf, v_interficie, vlineaini);
	  
	  RETURN vresultado;
	  
	  /* Cambios de Swapnil para : Defecto de SIN. y RES. : Start
      --Version 28. 
	  	  
      IF Vresultado <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vresultado;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               --RETURN vresultado;   --error de interfaz
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vresultado;   --error
         END IF;
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado2, perror, vnerror);

      IF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
         AND(NVL(vresultado, 1) <> 0
             OR NVL(vresultado2, 1) <> 0
             OR NVL(vnerror, 1) <> 0) THEN
         vnumerr := f_cont_reproceso(psinterf, 2);
      ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
            AND NVL(vresultado2, 1) = 0 THEN
         vnumerr := f_cont_reproceso(psinterf, 1);
      END IF;

      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vresultado;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;
			
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vresultado;   --error
         END IF;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vnerror;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vnerror;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2
               AND vrepr = 0 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vnerror;
               RETURN 9903126;
            END IF;
			
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vnerror;   --error
         END IF;
      END IF;

      BEGIN
         SELECT tparam
           INTO pemitido
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'EMITIDO';
      EXCEPTION
         WHEN OTHERS THEN
            pemitido := NULL;
      END;
	  RETURN 0;
	   Cambios de Swapnil para : Defecto de SIN. y RES. : Start */
   END f_contab_siniestro;
   --IAXIS 4504 Creacion de funcion de conexion a sap contabilidad 
	--IAXIS 5194 Creacion de funcion de conexion a sap contabilidad reservas
     /*************************************************************************
      Función que se llamará al emitir un pago para comunicarse con AXISCONNECT
      pempres number : Codigo de empresa
      paccion number : Acción con la que se llama (1.- Emisión, 2.- Consulta, 3.- Actualización)
      ptipopago number : Tipo de pago (1- Pago de siniestro, 2- Pago de prestación de renta, 3- Pago de renta, 4- Emisión recibo)
      pidPago number: Identificador del pago (srecren  (2,3), sidepag (1), nrecibo (4))
      pidmovimiento number: Número de movimiento (nmovpag de movpagren para tipo (2,3), nmovpag de sin tramita_movpago para tipo 1, smovrec de movrecibos para tipo 4)
      pnumevento number : Número de evento
      pcoderrorin : si hay error al cobrar en AXIS
      return    NUMBER         : 0 -> Traspàs correcte.
                               : 1 -> Error.
   *************************************************************************/
   FUNCTION f_contab_siniestro_res(
      pempresa IN NUMBER,
      paccion IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pidmovimiento IN NUMBER,
      pterminal IN VARCHAR2,
      pemitido OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pnumevento IN NUMBER DEFAULT NULL,
      pcoderrorin IN NUMBER DEFAULT NULL,
      pdescerrorin IN VARCHAR2 DEFAULT NULL,
      ppasocuenta IN NUMBER DEFAULT NULL,
      pnsinies in sin_siniestro.nsinies%type, 
      pntramit in number, 
      pctipres      in number, 
      pnmovres      in number,
      pnmovresdet   IN NUMBER,
      pcreexpre     IN NUMBER, 
      pidres        IN NUMBER,
      pcmonres      IN NUMBER)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vresultado2    NUMBER(10);
      vnerror        NUMBER(10);
      vnumerr        NUMBER(10);
      v_interficie   VARCHAR2(100);
      vrepr          NUMBER(1) := 0;
      vreprocesar    NUMBER(1) := 0;
      v_asient       NUMBER;
      l_idpago       NUMBER;
      l_idmovimi     NUMBER;
   BEGIN
	  
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf; 
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      -- insertar los datos en la tabla contab_asient_interf necesarios para el map I021S
      p_control_error('EDIER5194','1','5'||pnsinies);
      vnumerr := pac_cuadre_adm.f_conta_int_res(psinterf, ptipopago, pidpago, pempresa,
                                                TRUNC(f_sysdate), pidmovimiento,pnsinies ,
                                                pntramit,pctipres,pnmovres,pnmovresdet,pcreexpre,pidres,pcmonres);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      SELECT COUNT(1)
        INTO v_asient
        FROM contab_asient_interf
       WHERE sinterf = psinterf;

      IF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
         AND v_asient = 0 THEN
         RETURN 0;
      END IF;
      --Version 28.

      BEGIN
      SELECT DISTINCT c.idpago,c.idmov
        INTO l_idpago,l_idmovimi
        FROM contab_asient_interf c
       WHERE sinterf = psinterf
       and idpago = pidpago;

        EXCEPTION WHEN no_data_found THEN

        SELECT DISTINCT c.idpago,c.idmov
        INTO l_idpago,l_idmovimi
        FROM contab_asient_interf c
       WHERE sinterf = psinterf;
               END;
      v_interficie := pac_parametros.f_parempresa_t(pempresa, 'INTERFICIE_ERP');   --Bug.: 19887
      vlineaini := pempresa || '|' || ptipopago || '|' || paccion || '|' || l_idpago || '|'
                   || l_idmovimi || '|' || pterminal || '|' || pusuario || '|' || pnumevento
                   || '|' || pcoderrorin || '|' || pdescerrorin || '|' || ppasocuenta;
      vresultado := pac_int_online.f_int(pempresa, psinterf, v_interficie, vlineaini);
	  
	  RETURN vresultado;  
	  
	  /* Cambios de Swapnil para : Defecto de SIN. y RES. : Start
      --Version 28.
      IF Vresultado <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vresultado;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               --RETURN vresultado;   --error de interfaz
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vresultado;   --error
         END IF;
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado2, perror, vnerror);

      IF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
         AND(NVL(vresultado, 1) <> 0
             OR NVL(vresultado2, 1) <> 0
             OR NVL(vnerror, 1) <> 0) THEN
         vnumerr := f_cont_reproceso(psinterf, 2);
      ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'CONTAB_ONLINE'), 0) = 1
            AND NVL(vresultado2, 1) = 0 THEN
         vnumerr := f_cont_reproceso(psinterf, 1);
      END IF;

      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vresultado;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2 THEN
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vresultado;
               RETURN 9903126;
            END IF;
			
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vresultado;   --error
         END IF;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 1
            AND vrepr = 0 THEN
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vnerror;
               RETURN 9903126;
            END IF;

            -- JLB - F - 23830
            vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                         perror, f_user, pidpago, pidmovimiento, ptipopago);
            vrepr := 1;

            IF vnumerr <> 0 THEN
               RETURN vnerror;   --error
            ELSE
               perror := NULL;
            END IF;
         ELSIF NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR'), 0) = 2
               AND vrepr = 0 THEN
            -- JLB - I - 23830 - miro si la liquidación reaseguro se tiene que reprocesar si hay error.
            IF ptipopago IN(8, 9)   -- es liquidación
               AND NVL(pac_parametros.f_parempresa_n(pempresa, 'INT_REPROCESAR_LIQUI'), 0) = 0 THEN
               p_recupera_error(psinterf, vresultado, perror, vnerror);
               --return  vnerror;
               RETURN 9903126;
            END IF;
			
            IF f_tag(psinterf, 'cerror', 'TMENIN') <> 11 THEN
               vnumerr := f_accion_reproceso(pidpago, pidmovimiento, ptipopago, pempresa,
                                             vreprocesar);

               IF vrepr = 0
                  AND vreprocesar = 1 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               ELSE
                  RETURN 9903126;
               END IF;
            ELSE
               IF vrepr = 0 THEN
                  vnumerr := f_crear_reproceso(psinterf, v_interficie, 1, pempresa, vlineaini,
                                               perror, f_user, pidpago, pidmovimiento,
                                               ptipopago);
                  vrepr := 1;

                  IF vnumerr <> 0 THEN
                     --RETURN vresultado;   --error
                     RETURN 9903126;
                  ELSE
                     perror := NULL;
                  END IF;
               END IF;
            END IF;
         ELSE
            RETURN vnerror;   --error
         END IF;
      END IF;

      BEGIN
         SELECT tparam
           INTO pemitido
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'EMITIDO';
      EXCEPTION
         WHEN OTHERS THEN
            pemitido := NULL;
      END;
      RETURN 0;
	  Cambios de Swapnil para : Defecto de SIN. y RES. : End */
   END f_contab_siniestro_res;
   --IAXIS 5194 Creacion de funcion de conexion a sap contabilidad 

   --Ini Bug.: 17389 - ETM - 17/02/2011
    /*************************************************************************
                       FUNTION F_PESQUISAR_EVENTO  nos devuelve la lista los recibos que están pendientes de actualizar en AXIS.
      pempresa IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pterminal IN VARCHAR2,
      pconsulta OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2
      pnumevento IN NUMBER
    La función devuelve  0 si ha ido bien 1 si hay error
   *************************************************************************/
   FUNCTION f_pesquisar_evento(
      pempresa IN NUMBER,
      ptipopago IN NUMBER,
      pidpago IN NUMBER,
      pterminal IN VARCHAR2,
      pconsulta OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2,
      pnumevento IN NUMBER)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vobject        VARCHAR2(500) := 'PAC_CON.F_PESQUISAR_EVENTO';
      vparam         VARCHAR2(4000)
         := ' pempresa=' || pempresa || ' ptipopago=' || ptipopago || ' pidpago=' || pidpago
            || ' pterminal=' || pterminal || ' pconsulta=' || pconsulta || ' psinterf='
            || psinterf || ' perror=' || perror || ' pusuario=' || pusuario || ' pnumevento='
            || pnumevento;
      vpasexec       NUMBER(5) := 1;
   --vccompani      NUMBER := pempresa;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := ptipopago || '|' || pidpago || '|' || pnumevento || '|' || pempresa || '|'
                   || pterminal || '|' || pusuario;
      vresultado := pac_int_online.f_int(pempresa, psinterf, 'I019', vlineaini);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      BEGIN
         SELECT tparam
           INTO pconsulta
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'CONSULTA';   --pdte
      EXCEPTION
         WHEN OTHERS THEN
            pconsulta := NULL;
      END;

      RETURN 0;   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: ' || vparam, SQLERRM);
         RETURN NULL;
   END f_pesquisar_evento;

   --fin Bug.: 17389 - ETM - 17/02/2011

   -- BUG18682:DRA:23/08/2011:Inici
   FUNCTION f_get_datos_host(pempresa IN NUMBER, psinterf IN OUT NUMBER, perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(2000);
      vcmapead       VARCHAR2(10);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vobject        VARCHAR2(500) := 'pac_con.f_get_datos_host';
      vparam         VARCHAR2(4000)
         := ' pempresa=' || pempresa || ' - psinterf=' || psinterf || ' - vlineaini='
            || vlineaini || ' - vcmapead=' || vcmapead;
      vpasexec       NUMBER(5) := 0;
      datpol         ob_int_datos_poliza := ob_int_datos_poliza();
      pregpol        t_int_preg_poliza := t_int_preg_poliza();
      vcur           VARCHAR2(2000);
   BEGIN
      IF pempresa IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      -- Cargamos los objetos con los datos grabados en la capa MD de los objetos de la IAX
      FOR cur IN (SELECT cnivel, tvalores
                    FROM int_datos_pol_preg
                   WHERE sinterf = psinterf) LOOP
         IF cur.cnivel = 'DATPOL' THEN
            vcur := ' || ' || cur.tvalores;
            datpol.cempres := pac_map.f_valor_linia('|', cur.tvalores, 0, 1);
            datpol.sseguro := pac_map.f_valor_linia('|', cur.tvalores, 1, 1);
            datpol.ssegpol := pac_map.f_valor_linia('|', cur.tvalores, 1, 2);
            datpol.nsolici := pac_map.f_valor_linia('|', cur.tvalores, 1, 3);
            datpol.nmovimi := pac_map.f_valor_linia('|', cur.tvalores, 1, 4);
            datpol.nsuplem := pac_map.f_valor_linia('|', cur.tvalores, 1, 5);
            datpol.npoliza := pac_map.f_valor_linia('|', cur.tvalores, 1, 6);
            datpol.ncertif := pac_map.f_valor_linia('|', cur.tvalores, 1, 7);
            datpol.fefecto := pac_map.f_valor_linia('|', cur.tvalores, 1, 8);
            datpol.cmodali := pac_map.f_valor_linia('|', cur.tvalores, 1, 9);
            datpol.ccolect := pac_map.f_valor_linia('|', cur.tvalores, 1, 10);
            datpol.cramo := pac_map.f_valor_linia('|', cur.tvalores, 1, 11);
            datpol.ctipseg := pac_map.f_valor_linia('|', cur.tvalores, 1, 12);
            datpol.cactivi := pac_map.f_valor_linia('|', cur.tvalores, 1, 13);
            datpol.sproduc := pac_map.f_valor_linia('|', cur.tvalores, 1, 14);
            datpol.cagente := pac_map.f_valor_linia('|', cur.tvalores, 1, 15);
            datpol.cobjase := pac_map.f_valor_linia('|', cur.tvalores, 1, 16);
            datpol.csubpro := pac_map.f_valor_linia('|', cur.tvalores, 1, 17);
            datpol.cforpag := pac_map.f_valor_linia('|', cur.tvalores, 1, 18);
            datpol.csituac := pac_map.f_valor_linia('|', cur.tvalores, 1, 19);
            datpol.creteni := pac_map.f_valor_linia('|', cur.tvalores, 1, 20);
            datpol.cpolcia := pac_map.f_valor_linia('|', cur.tvalores, 1, 21);
            datpol.ccompani := pac_map.f_valor_linia('|', cur.tvalores, 1, 22);
            datpol.cpromotor := pac_map.f_valor_linia('|', cur.tvalores, 1, 23);
            datpol.npoliza_ini := pac_map.f_valor_linia('|', cur.tvalores, 1, 24);
            datpol.cidioma := pac_map.f_valor_linia('|', cur.tvalores, 1, 25);
         ELSIF cur.cnivel = 'PREGPOL' THEN
            vcur := ' || ' || cur.tvalores;
            pregpol.EXTEND;
            pregpol(pregpol.LAST) := ob_int_preg_poliza();
            pregpol(pregpol.LAST).cpregun := pac_map.f_valor_linia('|', cur.tvalores, 0, 1);
            pregpol(pregpol.LAST).crespue := pac_map.f_valor_linia('|', cur.tvalores, 1, 1);
            pregpol(pregpol.LAST).trespue := pac_map.f_valor_linia('|', cur.tvalores, 1, 2);
            pregpol(pregpol.LAST).ctipprg := pac_map.f_valor_linia('|', cur.tvalores, 1, 3);
            pregpol(pregpol.LAST).cnivel := pac_map.f_valor_linia('|', cur.tvalores, 1, 4);
         END IF;
      END LOOP;

      vcur := NULL;
      vpasexec := 2;

      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vpasexec := 3;
      vlineaini := pac_propio_int.f_pre_int_datos_host(datpol, pregpol, vcmapead);

      IF vlineaini IS NOT NULL
         AND vcmapead IS NOT NULL THEN
         vpasexec := 4;
         vresultado := pac_int_online.f_int(pempresa, psinterf, vcmapead, vlineaini);
         vpasexec := 5;

         IF vresultado <> 0 THEN
            perror := f_axis_literales(151304, 1);
            RETURN vresultado;   --error de interfaz
         END IF;
      END IF;

      vpasexec := 9;
      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      vnerror := pac_propio_int.f_post_int(psinterf, datpol, pregpol, vcmapead);

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      RETURN 0;   -- ok
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN 101901;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: ' || vparam || vcur,
                     SQLERRM);
         RETURN 140999;
   END f_get_datos_host;

   -- BUG18682:DRA:23/08/2011:Fi
   FUNCTION f_crear_reproceso(
      psinterf IN NUMBER,
      pcinterf IN VARCHAR2,
      pcestado IN NUMBER,
      pcempres IN NUMBER,
      plineaini IN VARCHAR2,
      perror IN VARCHAR2,
      pcusuari IN VARCHAR2,
      pid1 IN NUMBER,
      pid2 IN NUMBER,
      ptipo IN NUMBER,
      psinterfpadre IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   /***********************************************************************
                        F_CREAR_REPROCESO: Función que inserta registros en la tabla int_reproceso
                         para poder reprocesar los maps que lanzan las distintas
                         interficies.
                         Estados disponibles:
                           0 - Procesado correctamente, no se ha de reprocesar
                           1 - Error en la ejecución de la interficie, queda en cola para reprocesar
                           2 - Registro parado, no se reprocesará
                           3 - Reprocesando actualmente
                           4 - Registro reprocesado y erróneo, no se reprocesará (reprocesaran sus psinterf-hijos)
   ***********************************************************************/
   BEGIN
      INSERT INTO int_reproceso
                  (sinterf, cinterf, cestado, factualiza, cempres, vlineaini, terror,
                   cusuari, sinterfpadre, id1, id2, tipo)
           VALUES (psinterf, pcinterf, pcestado, f_sysdate, pcempres, plineaini, perror,
                   pcusuari, psinterfpadre, pid1, pid2, ptipo);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE int_reproceso
            SET cestado = pcestado,
                factualiza = f_sysdate,
                cempres = pcempres,
                vlineaini = plineaini,
                terror = perror,
                cusuari = pcusuari,
                sinterfpadre = psinterfpadre
          WHERE sinterf = psinterf
            AND pcinterf = cinterf;

         COMMIT;
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_crear_reproceso', 1,
                     'Error incontrolado ' || SQLCODE, SQLERRM);
         RETURN 1;
   END f_crear_reproceso;

   PROCEDURE p_int_reprocesar(pcinterf IN VARCHAR2 DEFAULT NULL) IS
      /***********************************************************************
                           P_INT_REPROCESAR: Proceso que reprocesa los registros en la tabla int_reproceso.
                            Estados disponibles:
                              0 - Procesado correctamente, no se ha de reprocesar
                              1 - Error en la ejecución de la interficie, queda en cola para reprocesar
                              2 - Registro parado, no se reprocesará
                              3 - Reprocesando actualmente
                              4 - Registro reprocesado y erróneo, no se reprocesará (reprocesaran sus psinterf-hijos)
      ***********************************************************************/
      CURSOR cur_reproceso IS
         SELECT   *
             FROM int_reproceso
            WHERE cestado = 1
              -- Bug 28644 - 24/10/2013 - JMG -Reproceso de interfaz de personas.
              AND cinterf = NVL(pcinterf, cinterf)
         ORDER BY factualiza;

      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      perror         VARCHAR2(2200);
      vnumerr        NUMBER;
      psinterf       NUMBER;
      vpendientes    NUMBER := 0;
      v_sseguro      NUMBER;
      v_idpago       contab_asient_interf.idpago%TYPE;
      v_ttippag      contab_asient_interf.ttippag%TYPE;
   BEGIN
      FOR v_reproceso IN cur_reproceso LOOP
         IF NVL(pac_parametros.f_parempresa_n(v_reproceso.cempres, 'INT_REPROCESAR'), 0) <> 0
            AND pac_contexto.f_inicializarctx(v_reproceso.cusuari) = 0 THEN
            pac_int_online.p_inicializar_sinterf;
            psinterf := pac_int_online.f_obtener_sinterf;

            UPDATE int_reproceso
               SET cestado = 4
             -- factualiza = f_sysdate
            WHERE  sinterf = v_reproceso.sinterf
               AND cinterf = v_reproceso.cinterf;

            vnumerr := f_crear_reproceso(psinterf, v_reproceso.cinterf, 3, v_reproceso.cempres,
                                         v_reproceso.vlineaini, perror, v_reproceso.cusuari,
                                         v_reproceso.id1, v_reproceso.id2, v_reproceso.tipo,
                                         v_reproceso.sinterf);
            v_idpago := NULL;
            v_ttippag := NULL;

            IF NVL(pcinterf, v_reproceso.cinterf) != 'I017' THEN
               BEGIN
                  SELECT idpago, ttippag
                    INTO v_idpago, v_ttippag
                    FROM contab_asient_interf
                   WHERE sinterf = v_reproceso.sinterf;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_idpago := v_reproceso.id1;
                     v_ttippag := v_reproceso.tipo;
               END;

               IF v_idpago IS NOT NULL THEN
                  vnumerr := pac_cuadre_adm.f_contabiliza_interf(psinterf, v_ttippag,
                                                                 v_idpago,
                                                                 v_reproceso.cempres,
                                                                 TRUNC(f_sysdate), NULL);

                  IF vnumerr <> 0 THEN
                     p_recupera_error(psinterf, vnumerr, perror, vnerror);
                     RETURN;   -- vnumerr;
                  END IF;
               END IF;
            END IF;

            vresultado := pac_int_online.f_int(v_reproceso.cempres, psinterf,
                                               v_reproceso.cinterf, v_reproceso.vlineaini);
            COMMIT;
            -- Recupero el error
            p_recupera_error(psinterf, vresultado, perror, vnerror);

            IF vresultado <> 0
               OR vnerror <> 0 THEN
               vnumerr := f_crear_reproceso(psinterf, v_reproceso.cinterf, 1,
                                            v_reproceso.cempres, v_reproceso.vlineaini,
                                            perror, v_reproceso.cusuari, v_reproceso.id1,
                                            v_reproceso.id2, v_reproceso.tipo,
                                            v_reproceso.sinterf);
            ELSE
               vnumerr := f_crear_reproceso(psinterf, v_reproceso.cinterf, 0,
                                            v_reproceso.cempres, v_reproceso.vlineaini,
                                            perror, v_reproceso.cusuari, v_reproceso.id1,
                                            v_reproceso.id2, v_reproceso.tipo,
                                            v_reproceso.sinterf);

               --Se ha reprocesado correctamente. Ahora a actualizar la póliza si es tipo recibo y no quedan más por reprocesar de esta póliza.
               IF v_reproceso.tipo = 4 THEN
                  SELECT sseguro
                    INTO v_sseguro
                    FROM recibos r
                   WHERE r.nrecibo = v_reproceso.id1;

                  SELECT COUNT('1')
                    INTO vpendientes
                    FROM int_reproceso ir, recibos r
                   WHERE r.nrecibo = ir.id1
                     AND ir.tipo = 4
                     AND ir.cestado = 1   --Error
                     AND r.sseguro = v_sseguro;

                  --Si esta retenida por envio fallido a SAP y ya no tiene ningún envio fallido, la desretenmos
                  IF vpendientes = 0 THEN
                     UPDATE seguros
                        SET creteni = 0
                      WHERE sseguro = v_sseguro
                        AND creteni = 6;   --Solamente si está retenida por este motivo.

                     COMMIT;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'p_int_reprocesar', 1,
                     'Error incontrolado ' || SQLCODE, SQLERRM);
   END p_int_reprocesar;

   FUNCTION f_tag(psinterf IN VARCHAR2, ptag IN VARCHAR2, pcampo IN VARCHAR2 DEFAULT 'TMENOUT')
      RETURN VARCHAR2 IS
      vretorno       VARCHAR2(2000);
      vselect        VARCHAR2(5000);
   BEGIN
      vselect := 'SELECT SUBSTR(' || pcampo || ', INSTR(' || pcampo || ', ''<' || ptag
                 || '>'') + LENGTH(''<' || ptag || '>''),
                 INSTR(' || pcampo || ', ''</' || ptag || '>'') -(INSTR(' || pcampo || ', ''<'
                 || ptag || '>'') + LENGTH(''<' || ptag
                 || '>'')))
     FROM int_mensajes
    WHERE sinterf = ' || psinterf;

      EXECUTE IMMEDIATE vselect
                   INTO vretorno;

      RETURN vretorno;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tag;

   FUNCTION f_accion_reproceso(
      pidpago IN NUMBER,
      pidmovimiento IN NUMBER,
      ptipopago IN NUMBER,
      pcempres IN NUMBER,
      prepr OUT NUMBER)
      RETURN NUMBER IS
      vctiprec       NUMBER;
      vcestpago      NUMBER;
   BEGIN
      prepr := 0;

      IF ptipopago IN(1, 4) THEN
         BEGIN
            SELECT DISTINCT (ctiprec), cestpago
                       INTO vctiprec, vcestpago
                       FROM vista_interf_pagos
                      WHERE cempres = pcempres
                        AND ttippag = ptipopago
                        AND idpago = pidpago
                        AND idmovimiento = pidmovimiento;
         EXCEPTION
            WHEN OTHERS THEN
               vctiprec := NULL;
               vcestpago := NULL;
         END;

           -- Ini Bug 26513 -- ECP -- 27/03/2013
         /*IF vctiprec IS NOT NULL
            AND vcestpago IS NOT NULL THEN*/
         BEGIN
            SELECT creprocesar
              INTO prepr
              FROM int_acciones
             WHERE ttippag = ptipopago
               AND NVL(ctiprec, 0) = NVL(vctiprec, 0)
               AND NVL(cestpago, 0) = NVL(vcestpago, 0)
               AND cempres = pcempres;
         EXCEPTION
            WHEN OTHERS THEN
               prepr := 0;
         END;
        -- END IF;
        -- Fin Bug 26513 -- ECP -- 27/03/2013
      -- Ini Bug 26513 -- ECP -- 27/03/2013  Se cambia  ptipopago = 10 por  ptipopago = 99
      ELSIF ptipopago = 99 THEN   --personas
         -- Fin Bug 26513 -- ECP -- 27/03/2013
         prepr := 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         prepr := 0;
         p_tab_error(f_sysdate, f_user, 'f_accion_reproceso', 1,
                     'Error incontrolado ' || SQLCODE, SQLERRM);
         RETURN 1;
   END f_accion_reproceso;

   FUNCTION f_importe_financiacion_pdte(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      psinterf IN OUT NUMBER,
      pimporte OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(2000);
      vcmapead       VARCHAR2(10) := 'I022';
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vobject        VARCHAR2(500) := 'pac_con.f_importe_financiacion_pdte';
      vparam         VARCHAR2(4000)
         := 'pcempres=' || pcempres || ' - psseguro=' || psseguro || ' - psinterf='
            || psinterf || ' - vlineaini=' || vlineaini || ' - vcmapead=' || vcmapead;
      vpasexec       NUMBER(5) := 0;
      vcur           VARCHAR2(2000);
      vimporte       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vsproduc       NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      SELECT npoliza, ncertif, sproduc
        INTO vnpoliza, vncertif, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 3;
      vlineaini := psseguro || '|' || vnpoliza || '|' || vncertif || '|' || vsproduc;

      IF vlineaini IS NOT NULL
         AND vcmapead IS NOT NULL THEN
         vpasexec := 4;
         vresultado := pac_int_online.f_int(pcempres, psinterf, vcmapead, vlineaini);
         vpasexec := 5;

         IF vresultado <> 0 THEN
            perror := f_axis_literales(151304, 1);
            RETURN vresultado;   --error de interfaz
         END IF;
      END IF;

      vpasexec := 9;
      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'psinterf' || psinterf,
                  'vresultado:' || vresultado);
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'psinterf' || psinterf,
                  'perror:' || perror);
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'psinterf' || psinterf,
                  'vnerror:' || vnerror);
      vpasexec := 10;

      IF vresultado <> 0 THEN
         RETURN vresultado;
      END IF;

      vpasexec := 11;

      IF NVL(vnerror, 0) <> 0 THEN
         RETURN vnerror;
      END IF;

      vpasexec := 12;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'psinterf' || psinterf,
                  'vcmapead:' || vcmapead);

      SELECT TO_NUMBER(NVL(REPLACE(SUM(tparam), '.', ','), 0))
        INTO vimporte
        FROM int_parametros
       WHERE sinterf = psinterf
         AND cmapead = vcmapead || 'E'
         AND cparam = 'VALOR';

      p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'psinterf' || psinterf,
                  'vimporte:' || vimporte);
      vpasexec := 13;
      pimporte := vimporte;
      vpasexec := 14;
      RETURN 0;   -- ok
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN 101901;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: ' || vparam || vcur,
                     SQLERRM);
         RETURN 140999;
   END f_importe_financiacion_pdte;

   -- Ini Bug 23687 - XVM - 09/10/2012

   /*************************************************************************
                        Función f_desencrip_pwd: función que obtiene el password desencriptado de un usuario
      param in  pcusuari:       Código de usuario
      param out ptexto          password desencriptado
      return                    0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_desencrip_pwd(pcusuari IN VARCHAR2, ptexto OUT VARCHAR2)
      RETURN NUMBER IS
      vnerror        NUMBER(10);
      vppswd         VARCHAR2(100);
   BEGIN
      vnerror := pac_user.f_get_password(pcusuari, vppswd);

      IF vnerror <> 0 THEN
         RETURN vnerror;
      END IF;

      ptexto :=
         RTRIM
            (UTL_RAW.cast_to_varchar2
                (DBMS_OBFUSCATION_TOOLKIT.desdecrypt
                                            (input => vppswd,
                                             KEY => UTL_RAW.cast_to_raw(UPPER(RPAD(pcusuari,
                                                                                   32, ' '))))),
             ' ');
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9904306;   -- Error en el desencriptado de contraseña
   END f_desencrip_pwd;

   /*************************************************************************
                                                                                                                                                      Función f_cuerpo: función para recuperar el cuerpo de un correo
      param in  pscorreo:       Código de correo
      param in  pcidioma:       Código de idioma
      param in  pcusuari:       Código de usuario
      param out ptexto          Texto cuerpo
      return                    0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_cuerpo(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      pcusuari IN VARCHAR2,
      ptexto OUT VARCHAR2)
      RETURN NUMBER IS
      pos            NUMBER;
      v_despwd       VARCHAR2(100);
      vnerror        NUMBER(10);
   BEGIN
      BEGIN
         SELECT cuerpo
           INTO ptexto
           FROM desmensaje_correo
          WHERE scorreo = pscorreo
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151422;
      --No existe ningún Subject para este tipo de correo.
      END;

      --sustitución del nombre de usuario
      pos := INSTR(ptexto, '#CUSUARI#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#CUSUARI#', pcusuari);
      END IF;

      --sustitución del password
      vnerror := f_desencrip_pwd(pcusuari, v_despwd);

      IF vnerror <> 0 THEN
         RETURN vnerror;
      END IF;

      pos := INSTR(ptexto, '#CPASSWORD#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#CPASSWORD#', v_despwd);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 152556;   -- Error en el cuerpo del mensaje
   END f_cuerpo;

   /*************************************************************************
                                                                                                                                                Función f_asunto: función para recuperar el asunto de un correo
      param in  pscorreo:       Código de correo
      param in  pcidioma:       Código de idioma
      param out psubject        Texto asunto
      return                    0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_asunto(pscorreo IN NUMBER, pcidioma IN NUMBER, psubject OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         SELECT asunto
           INTO psubject
           FROM desmensaje_correo
          WHERE scorreo = pscorreo
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151422;
      --No esixte ningún Subject para este tipo de correo.
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 180285;   -- Error en el Subject del mensaje
   END f_asunto;

   /*************************************************************************
                                                                                                                                                Función f_recordarpwd: su finalidad es enviar un correo al usuario
      a la dirección pasada por parámetro notificándole su password de acceso a la aplicación
      param in  pcempres:       Código de empresa
      param in  pcidioma:       Código de idioma
      param in  pcusuari:       Código de usuario
      param in  pto:            Dirección de correo a enviar (sería el "Para:" del correo)
      param out perror          Mensaje de error
      return                    0/nºerr -> Todo OK/Código de error
   *************************************************************************/
   FUNCTION f_recordarpwd(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcusuari IN VARCHAR2,
      pto IN VARCHAR2,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vobject        VARCHAR2(500) := 'PAC_CON.f_recordarpwd';
      vparam         VARCHAR2(4000)
         := 'pcempres:' || pcempres || ', pcidioma:' || pcidioma || ', pcusuari:' || pcusuari
            || ', pto:' || pto;
      vpasexec       NUMBER(5) := 0;
      vcur           VARCHAR2(2000);
      v_subject      VARCHAR2(250);
      v_texto        VARCHAR2(4000);
      v_scorreo      NUMBER(7);
      vfrom          VARCHAR2(100);
      v_aux          usuarios.cusuari%TYPE;
   BEGIN
      IF pcusuari IS NULL
         OR pto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      BEGIN
         SELECT cusuari
           INTO v_aux
           FROM usuarios
          WHERE LOWER(cusuari) = LOWER(pcusuari);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9904379;   --Usuario inexistente
      END;

      SELECT scorreo
        INTO v_scorreo
        FROM cfg_notificacion
       WHERE cempres = pcempres
         AND cmodo = 'GENERAL'
         AND tevento = 'RECORDATORIO_PWD'
         AND sproduc = 0;

      vpasexec := 2;
      -- Obtenemos el asunto
      vnerror := f_asunto(v_scorreo, pcidioma, v_subject);

      IF vnerror <> 0 THEN
         RETURN vnerror;
      END IF;

      vpasexec := 3;
      -- Obtenemos el cuerpo del correo
      vnerror := f_cuerpo(v_scorreo, pcidioma, pcusuari, v_texto);

      IF vnerror <> 0 THEN
         RETURN vnerror;
      END IF;

      SELECT remitente
        INTO vfrom
        FROM mensajes_correo
       WHERE scorreo = v_scorreo;

      vpasexec := 4;

      BEGIN
         p_enviar_correo(vfrom, pto, NULL, NULL, v_subject, v_texto);
      EXCEPTION
         WHEN OTHERS THEN
            --Nos da igual cualquier tipo de error al enviar el correo.
            RETURN 9904380;   --Error al enviar el correo.
      END;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN 101901;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: ' || vparam || vcur,
                     SQLERRM);
         RETURN 140999;
   END f_recordarpwd;

   -- Fin Bug 23687 - XVM - 09/10/2012

   -- Bug 024791 - 01/09/2010 - JLB -Nuevas interfaces de autos
   FUNCTION f_ultimosegurovehiculo(
      pempresa IN NUMBER,
      ptipomatricula IN VARCHAR2,
      pmatricula IN VARCHAR2,
      pfechaultimavig OUT DATE,
      pcompani OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
   BEGIN
      IF NVL(psinterf, 0) = 0 THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pempresa || '|' || ptipomatricula || '|' || pmatricula;
      vresultado := pac_int_online.f_int(pempresa, psinterf, 'I027', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      BEGIN
         SELECT TO_DATE(tparam, 'YYYY-MM-DD')
           INTO pfechaultimavig
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'FECHAULTIMAVIGENCIA';
      EXCEPTION
         WHEN OTHERS THEN
            pfechaultimavig := NULL;
      END;

      BEGIN
         SELECT tparam
           INTO pcompani
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'COMPANIAULTIMAVIGENCIA';
      EXCEPTION
         WHEN OTHERS THEN
            pcompani := NULL;
      END;

      perror := NULL;
      RETURN vnerror;   -- 0 todo ok otro valor si error.
   EXCEPTION
      WHEN OTHERS THEN
         perror := SQLCODE;
         RETURN 2;
   END f_ultimosegurovehiculo;

   FUNCTION f_antiguedadconductor(
      pempresa IN NUMBER,
      ptipodoc IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pantiguedad OUT NUMBER,
      pcompani OUT NUMBER,
      psinies OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pempresa || '|' || ptipodoc || '|' || pnnumide;
      vresultado := pac_int_online.f_int(pempresa, psinterf, 'I028', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      BEGIN
         SELECT tparam
           INTO pantiguedad
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'ANTIGUEDAD';
      EXCEPTION
         WHEN OTHERS THEN
            pantiguedad := NULL;
      END;

      BEGIN
         SELECT tparam
           INTO pcompani
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'COMPANIAULTIMAVIGENCIA';
      EXCEPTION
         WHEN OTHERS THEN
            pcompani := NULL;
      END;

      BEGIN
         SELECT tparam
           INTO psinies
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'SINIESTROULTIMAVIGENCIA';
      EXCEPTION
         WHEN OTHERS THEN
            pcompani := NULL;
      END;

      perror := NULL;
      RETURN vnerror;   -- 0 todo ok otro valor si error.
   EXCEPTION
      WHEN OTHERS THEN
         perror := SQLCODE;
         RETURN 2;
   END f_antiguedadconductor;

--
/*************************************************************************
      Función  f_solicitar_inspeccion: Funcion para pedir orden de inspección
        param in  pempresa:         Código de empresa
        param in  psseguro:  Identificador de seguro
        param in  pnriesgo:  Identificador de riesgo
        param in  pnmovimi:  Identificador de movimiento
        param out ptabla:  Tablas sobre la que obtener datos 'EST' o Relase
        param out pnordenext:   Nº identificador de orden de petición
        param out psinterf:    codigo secuencial de interfaz
        param out terror            Mensajes de error
        return                      0 ok /nºerr -> Código de error
     *************************************************************************/
   FUNCTION f_solicitar_inspeccion(
      pempresa IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmotinspec IN NUMBER,
      ptabla IN VARCHAR2,
      pnordenext OUT NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vcagente       seguros.cagente%TYPE;
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      --BUG 24791 - INICIO - 23/05/2013 - DCT - Añadimos el cagente en la vlineaini
      IF ptabla = 'EST' THEN
         SELECT NVL(TO_CHAR(SUBSTR(cagente, -5)), '')
           INTO vcagente
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT NVL(TO_CHAR(SUBSTR(cagente, -5)), '')
           INTO vcagente
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      vlineaini := pempresa || '|' || pmotinspec || '|' || psseguro || '|' || pnriesgo || '|'
                   || pnmovimi || '|' || NVL(ptabla, 'EST') || '|' || vcagente;
      --BUG 24791 - FIN - 23/05/2013 - DCT - Añadimos el cagente en la vlineaini
      vresultado := pac_int_online.f_int(pempresa, psinterf, 'I026', vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      BEGIN
         SELECT tparam
           INTO pnordenext
           FROM int_parametros
          WHERE sinterf = psinterf
            AND cparam = 'NORDENEXT';
      EXCEPTION
         WHEN OTHERS THEN
            pnordenext := NULL;
      END;

      perror := NULL;
      RETURN vnerror;   -- 0 todo ok otro valor si error.
   EXCEPTION
      WHEN OTHERS THEN
         perror := SQLCODE;
         RETURN 2;
   END f_solicitar_inspeccion;

   FUNCTION f_cont_reproceso(psinterf IN NUMBER, pestado IN NUMBER)
      RETURN NUMBER IS
   /***********************************************************************
                        f_cont_reproceso: Función que actualiza el estado de la tabla contab_asient_interf
                         para poder reprocesar los maps que lanzan las distintas
                         interficies.
                         Estados disponibles:
                           0 pendiente,
                           1 correcto,
                           2 erroneo,
                           3 reprocesado.
   ***********************************************************************/
   BEGIN
      UPDATE contab_asient_interf
         SET cestado = pestado,
             festado = f_sysdate
       WHERE sinterf = psinterf;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_cont_reproceso', 1,
                     'Error incontrolado ' || SQLCODE, SQLERRM);
         RETURN 1;
   END f_cont_reproceso;

   PROCEDURE p_int_cont_reproceso(pcempres IN NUMBER) IS
      /***********************************************************************
                           P_INT_CONT_REPROCESO: Proceso que reprocesa los registros en la tabla contab_asient_interf.
                            Estados disponibles:
                                0 pendiente,
                                1 correcto,
                                2 erroneo,
                                3 reprocesado.
                                4 problema para reprocesar
                                5,6 duplicados
      ***********************************************************************/
      CURSOR cur_repr IS
         SELECT   sinterf, ttippag, idpago, idmov
             FROM contab_asient_interf
            WHERE cestado = 2
         GROUP BY sinterf, ttippag, idpago, idmov
         ORDER BY sinterf;

      CURSOR cur_reproceso IS
         SELECT   sinterf, ttippag, idpago
             FROM contab_asient_interf
            WHERE cestado = 2
         GROUP BY sinterf, ttippag, idpago
         ORDER BY sinterf;

      CURSOR c_duplicados IS
         SELECT *
           FROM (SELECT   COUNT(1) cont, ttippag, idpago, nasient, nlinea, ccuenta, iapunte,
                          cenlace, tapunte, NVL(idmov, 0) idmov
                     FROM contab_asient_interf
                    WHERE cestado = 5
                 GROUP BY ttippag, idpago, nasient, nlinea, ccuenta, iapunte, cenlace, tapunte,
                          NVL(idmov, 0))
          WHERE cont >= 1;

      variab         NUMBER := 0;
      vsinterf       NUMBER;
      vresultado     NUMBER(10);
      vresultado2    NUMBER(10);
      vnerror        NUMBER(10);
      perror         VARCHAR2(2200);
      vnumerr        NUMBER;
      psinterf       NUMBER;
      vpendientes    NUMBER := 0;
      v_sseguro      NUMBER;
      v_idpago       contab_asient_interf.idpago%TYPE;
      v_ttippag      contab_asient_interf.ttippag%TYPE;
      vlineaini      VARCHAR2(500);
      v_interficie   VARCHAR2(100);
      vrepr          NUMBER(1) := 0;
      vreprocesar    NUMBER(1) := 0;
      v_asient       NUMBER;
      vterminal      VARCHAR2(200);
      v_contar       NUMBER;
   BEGIN
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CONTAB_ONLINE'), 0) = 1 THEN
         FOR v_repr IN cur_repr LOOP
            --duplicar contab_asient_interf para reprocesar
            pac_int_online.p_inicializar_sinterf;
            psinterf := pac_int_online.f_obtener_sinterf;
            vnumerr := pac_cuadre_adm.f_contabiliza_interf(psinterf, v_repr.ttippag,
                                                           v_repr.idpago, pcempres,
                                                           TRUNC(f_sysdate), v_repr.idmov);

            /*INSERT INTO contab_asient_interf
                        (sinterf, ttippag, idpago, fconta, nasient, nlinea, ccuenta,
                         ccoletilla, tapunte, iapunte, tdescri, fefeadm, otros, cenlace,
                         tlibro, cusuari, falta, cmanual, cestado, festado)
               SELECT psinterf, ttippag, idpago, fconta, nasient, nlinea, ccuenta, ccoletilla,
                      tapunte, iapunte, tdescri, fefeadm, otros, cenlace, tlibro, cusuari,
                      falta, cmanual, cestado, festado
                 FROM contab_asient_interf
                WHERE sinterf = v_repr.sinterf;*/
            UPDATE contab_asient_interf
               SET cestado = 2
             WHERE sinterf = psinterf;

            --  COMMIT;
            SELECT COUNT(sinterf)
              INTO v_contar
              FROM contab_asient_interf
             WHERE sinterf = psinterf;

            psinterf := NULL;

            IF v_contar > 0 THEN
               vnumerr := f_cont_reproceso(v_repr.sinterf, 3);
            ELSE
               --cuando no se crea registro nuevo para reprocesar es que ha cambiado el estado inicial del recibo, póliza, proceso o pago.
               --Esto no debería pasar a no ser que hayan hecho algún cambio manual.
               vnumerr := f_cont_reproceso(v_repr.sinterf, 4);
            END IF;
         END LOOP;

--antes de lanzar el reproceso, procedemos a eliminar los registros que hayan podido duplicarse en una emisión errónea.
         BEGIN
            UPDATE contab_asient_interf
               SET cestado = 5
             WHERE cestado = 2;

            --COMMIT;
            FOR c_reg IN c_duplicados LOOP
               SELECT COUNT(1)
                 INTO variab
                 FROM contab_asient_interf
                WHERE cestado = 2
                  AND ttippag = c_reg.ttippag
                  AND idpago = c_reg.idpago
                  AND nasient = c_reg.nasient
                  AND nlinea = c_reg.nlinea
                  AND ccuenta = c_reg.ccuenta
                  AND iapunte = c_reg.iapunte
                  AND tapunte = c_reg.tapunte
                  AND cenlace = c_reg.cenlace;

               SELECT MAX(sinterf)
                 INTO vsinterf
                 FROM contab_asient_interf
                WHERE cestado = 5
                  AND ttippag = c_reg.ttippag
                  AND idpago = c_reg.idpago
                  AND nasient = c_reg.nasient
                  AND nlinea = c_reg.nlinea
                  AND ccuenta = c_reg.ccuenta
                  AND iapunte = c_reg.iapunte
                  AND tapunte = c_reg.tapunte
                  AND cenlace = c_reg.cenlace;

               IF variab = 0 THEN
                  UPDATE contab_asient_interf
                     SET cestado = 2
                   WHERE ttippag = c_reg.ttippag
                     AND idpago = c_reg.idpago
                     AND nasient = c_reg.nasient
                     AND nlinea = c_reg.nlinea
                     AND ccuenta = c_reg.ccuenta
                     AND iapunte = c_reg.iapunte
                     AND tapunte = c_reg.tapunte
                     AND cenlace = c_reg.cenlace
                     AND sinterf = vsinterf
                     AND cestado = 5;
               -- COMMIT;
               END IF;
            END LOOP;

            UPDATE contab_asient_interf
               SET cestado = 6
             WHERE cestado = 5;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               p_tab_error(f_sysdate, f_user, 'p_int_cont_reproceso', 1,
                           'Error al buscar duplicados ' || SQLCODE, SQLERRM);
         END;

         FOR v_reproceso IN cur_reproceso LOOP
            v_interficie := pac_parametros.f_parempresa_t(pcempres, 'INTERFICIE_ERP');   --Bug.: 19887
            vlineaini := pcempres || '|' || v_reproceso.ttippag || '|' || 1 || '|'
                         || v_reproceso.idpago || '|' || NULL || '|' || vterminal || '|'
                         || f_user || '|' || NULL || '|' || NULL || '|' || NULL || '|' || NULL;
            pac_int_online.vsinterf := v_reproceso.sinterf;
            vresultado := pac_int_online.f_int(pcempres, v_reproceso.sinterf, v_interficie,
                                               vlineaini);
            COMMIT;
            -- Recupero el error
            p_recupera_error(v_reproceso.sinterf, vresultado2, perror, vnerror);

            IF (NVL(vresultado, 1) <> 0
                OR NVL(vresultado2, 1) <> 0
                OR NVL(vnerror, 1) <> 0) THEN
               vnumerr := f_cont_reproceso(v_reproceso.sinterf, 2);
            ELSIF NVL(vresultado2, 1) = 0 THEN
               vnumerr := f_cont_reproceso(v_reproceso.sinterf, 1);

               IF v_reproceso.ttippag = 4 THEN
                  UPDATE seguros
                     SET creteni = 0
                   WHERE sseguro IN(SELECT sseguro
                                      FROM recibos
                                     WHERE nrecibo = v_reproceso.idpago)
                     AND creteni = 6;

                  UPDATE movseguro m
                     SET femisio = TRUNC(f_sysdate)
                   WHERE m.sseguro IN(SELECT sseguro
                                        FROM recibos
                                       WHERE nrecibo = v_reproceso.idpago)
                     AND femisio IS NULL
                     AND nmovimi IN(SELECT MAX(nmovimi)
                                      FROM movseguro
                                     WHERE sseguro = m.sseguro
                                       AND femisio IS NULL);

                  COMMIT;
               END IF;
            END IF;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'p_int_cont_reproceso', 2,
                     'Error incontrolado ' || SQLCODE, SQLERRM);
   END p_int_cont_reproceso;

   FUNCTION f_connect_estandar(
      pempresa IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2,
      pxml IN CLOB,
      pop IN NUMBER,
      servicio IN VARCHAR2 DEFAULT NULL,
      pcinterf IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     int_resultado.cresultado%TYPE;   --NUMBER(10);
      vnerror        int_resultado.nerror%TYPE;   --NUMBER(10);
      vseqxml        NUMBER;
      v_action       NUMBER;
      v_usuario      VARCHAR2(25);
      v_tpwd         VARCHAR2(100);
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      IF pxml IS NOT NULL THEN
         SELECT seqxml.NEXTVAL
           INTO vseqxml
           FROM DUAL;

         v_action := pop;

         INSERT INTO int_datos_xml
                     (sxml, datos_xml, paccion, sinterf)
              VALUES (vseqxml, pxml, pop, psinterf);

         COMMIT;
      END IF;

      SELECT pac_iax_common.f_get_cxtusuario
        INTO v_usuario
        FROM DUAL;

      SELECT tpwd
        INTO v_tpwd
        FROM usuarios
       WHERE cusuari = v_usuario
         AND cempres = pempresa;

      vlineaini := pempresa || '|' || v_usuario || '|' || v_tpwd || '|' || servicio || '|'
                   || 'INT_DATOS_XML#' || vseqxml || '|' || v_action;
      vresultado := pac_int_online.f_int(pempresa, psinterf, pcinterf, vlineaini);

      IF vresultado <> 0 THEN
         perror := f_axis_literales(151304, pac_md_common.f_get_cxtidioma());
         RETURN vresultado;   --error de interfaz
      END IF;

      -- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      perror := NULL;
      RETURN vnerror;   -- 0 todo ok otro valor si error.
   EXCEPTION
      WHEN OTHERS THEN
         perror := SQLCODE;
         p_tab_error(f_sysdate, f_user, 'p_int_cont_reproceso', 1,
                     'Error incontrolado ' || SQLCODE, SQLERRM);
         RETURN 2;
   END f_connect_estandar;
END pac_con;

/

